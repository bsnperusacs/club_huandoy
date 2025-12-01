@echo off
setlocal EnableDelayedExpansion

set FILE=pubspec.yaml

echo =========================================
echo        🔥 ACTUALIZANDO VERSION 🔥
echo =========================================

:: Leer version actual
for /f "tokens=1,* delims=: " %%A in ('findstr /b "version:" "%FILE%"') do (
    set CURRENT=%%B
)

:: Separar version y build
for /f "tokens=1,2 delims=+" %%A in ("%CURRENT%") do (
    set VERSION=%%A
    set BUILD=%%B
)

:: Separar major.minor.patch
for /f "tokens=1,2,3 delims=." %%A in ("%VERSION%") do (
    set MAJOR=%%A
    set MINOR=%%B
    set PATCH=%%C
)

echo Versión actual: %MAJOR%.%MINOR%.%PATCH%+%BUILD%

:: Incrementar version PATCH y BUILD
set /a NEW_PATCH=%PATCH%+1
set /a NEW_BUILD=%BUILD%+1

set NEW_VERSION=%MAJOR%.%MINOR%.!NEW_PATCH!
set NEW_LINE=version: !NEW_VERSION!+!NEW_BUILD!

echo Nueva versión: !NEW_VERSION!+!NEW_BUILD!

:: Reemplazar pubspec.yaml
powershell -Command "(Get-Content '%FILE%') -replace 'version: .*', '%NEW_LINE%' | Set-Content '%FILE%'"

echo =========================================
echo        🚀 GENERANDO APK RÁPIDO
echo =========================================

:: 🟢 SIN flutter clean (NO borra nada, NO demora)
call flutter pub get
call flutter build apk --release

echo =========================================
echo   ✔ APK GENERADO SIN LIMPIAR NADA
echo =========================================
echo   Ruta: build/app/outputs/flutter-apk/app-release.apk
echo =========================================

pause
