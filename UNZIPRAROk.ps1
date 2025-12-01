param(
    [Parameter(Mandatory = $true)]
    [string]$ZipPath
)

function Expand-ArchiveFile($archiveFile, $destination) {
    # Crea la carpeta destino si no existe
    if (-not (Test-Path $destination)) {
        New-Item -ItemType Directory -Path $destination | Out-Null
    }

    # Determina la extensión del archivo
    $extension = [System.IO.Path]::GetExtension($archiveFile).ToLower()

    try {
        switch ($extension) {
            ".zip" {
                # Descomprimir ZIP nativo
                Expand-Archive -LiteralPath $archiveFile -DestinationPath $destination -Force -ErrorAction Stop
            }
            ".rar" {
                # Descomprimir RAR usando 7-Zip
                Write-Host "🗜️  Descomprimiendo RAR con 7-Zip: $archiveFile"
                & 7z x $archiveFile "-o$destination" -y | Out-Null
            }
            default {
                Write-Warning "⚠️ Formato no soportado: $archiveFile"
                return
            }
        }
    }
    catch {
        Write-Warning "⚠️ Error al descomprimir: $archiveFile"
        return
    }
}

function Expand-CompressedRecursively($filePath, $destination) {
    # Descomprime el archivo recibido
    Expand-ArchiveFile -archiveFile $filePath -destination $destination

    # Busca más ZIP o RAR dentro de la carpeta descomprimida
    Get-ChildItem -Path $destination -Recurse -Include *.zip, *.rar -ErrorAction SilentlyContinue | ForEach-Object {
        $innerFile = $_.FullName

        # Limita la longitud del nombre de carpeta
        $shortName = if ($_.BaseName.Length -gt 30) { $_.BaseName.Substring(0,30) } else { $_.BaseName }

        $innerDest = Join-Path $_.DirectoryName $shortName
        Write-Host "📦 Descomprimiendo: $innerFile en $innerDest"

        # Llamada recursiva
        Expand-CompressedRecursively -filePath $innerFile -destination $innerDest

        # 🔥 Eliminar el archivo comprimido interno tras descomprimirlo
        try {
            Remove-Item -LiteralPath $innerFile -Force -ErrorAction Stop
            Write-Host "🗑️  Eliminado: $innerFile"
        }
        catch {
            Write-Warning "⚠️ No se pudo eliminar $innerFile"
        }
    }
}

# --- EJECUCIÓN PRINCIPAL ---
if (-not (Test-Path $ZipPath)) {
    Write-Host "❌ No se ha encontrado el archivo: $ZipPath"
    exit 1
}

# Convertir a ruta absoluta si es necesario
if (-not ([System.IO.Path]::IsPathRooted($ZipPath))) {
    $ZipPath = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $ZipPath))
}

$parentDir = Split-Path $ZipPath -Parent
if ([string]::IsNullOrWhiteSpace($parentDir)) {
    $parentDir = (Get-Location).Path
}

$baseName = [System.IO.Path]::GetFileNameWithoutExtension($ZipPath)
$targetFolder = Join-Path $parentDir $baseName

Write-Host "🚀 Iniciando descompresión de $ZipPath en $targetFolder ..."
Expand-CompressedRecursively -filePath $ZipPath -destination $targetFolder
Write-Host "✅ ¡Todo descomprimido correctamente!"
