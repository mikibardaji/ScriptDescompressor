# ScriptDescompressor

Aquest script permet descomprimir un fitxer `.zip` principal i, si dins hi ha més fitxers `.zip`, els descomprimeix recursivament. És útil quan tens un paquet amb diversos zip i no vols fer-ho manualment.

## Característiques principals

- Descomprimeix el fitxer `.zip` principal en una carpeta amb el mateix nom del fitxer.
- Si hi ha més `.zip` dins del contingut descomprimit, els descomprimeix també automàticament.
- Per evitar problemes amb noms de rutes massa llargs, les carpetes de les subcarpetes derivades es creen amb els **30 primers caràcters del nom del fitxer ZIP**. Si el nom és més curt, es fa servir tot el nom.
- Els zips interns, un cop descomprimits els elimina.

## Com executar-lo

Obre CMD o PowerShell i executa:

```powershell
powershell -ExecutionPolicy Bypass -File SuperDescompresorOk.ps1 -ZipPath "NomFitxer.zip"
```
