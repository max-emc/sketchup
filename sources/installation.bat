@echo off

set "dossier=C:\Users\%USERNAME%\AppData\Roaming\SketchUp"

for /f "delims=" %%a in ('dir /B /AD "%dossier%"') do (
    set "version=%%a"
    goto :fin
)

:fin

set "chemin=C:\Users\%USERNAME%\AppData\Roaming\SketchUp\%version%\SketchUp\Plugins"

if not exist "%chemin%" (
    echo Le chemin "%chemin%" n'existe pas.
    pause
    exit /b
)

set "repertoire=%~dp0"
set "fichier=deplacement.rb"
set "sous_dossier=deplacement"

set "chemin_deplacement=%repertoire%%fichier%"
set "chemin_sous_dossier=%repertoire%%sous_dossier%"

mkdir "%chemin%\%sous_dossier%" 2>nul

copy "%chemin_deplacement%" "%chemin%"
copy "%chemin_sous_dossier%" "%chemin%\%sous_dossier%"

echo Fichiers copiés avec succès.
pause
