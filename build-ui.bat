@echo off
setlocal EnableDelayedExpansion

echo ========================================
echo   Go-LDAP-Admin UI Build Script
echo ========================================
echo.

set SCRIPT_DIR=%~dp0
set UI_DIR=%SCRIPT_DIR%go-ldap-admin-ui
set ADMIN_DIR=%SCRIPT_DIR%go-ldap-admin
set STATIC_DIR=%ADMIN_DIR%\public\static\dist

echo [Step 1] Checking UI directory...
if not exist "%UI_DIR%\package.json" (
    echo Error: UI directory not found at %UI_DIR%
    exit /b 1
)
echo UI directory found: %UI_DIR%

echo.
echo [Step 2] Installing dependencies...
cd /d "%UI_DIR%"
call npm install
if %ERRORLEVEL% neq 0 (
    echo Error: npm install failed
    exit /b 1
)

echo.
echo [Step 3] Building UI...
call npm run build:prod
if %ERRORLEVEL% neq 0 (
    echo Error: npm run build:prod failed
    exit /b 1
)

echo.
echo [Step 4] Cleaning old static files...
if exist "%STATIC_DIR%" (
    rmdir /s /q "%STATIC_DIR%"
)

echo.
echo [Step 5] Copying built files to admin static directory...
if not exist "%STATIC_DIR%" (
    mkdir "%STATIC_DIR%"
)

xcopy /s /e /y "%UI_DIR%\dist\*" "%STATIC_DIR%\"
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to copy files
    exit /b 1
)

echo.
echo ========================================
echo   Build completed successfully!
echo ========================================
echo.
echo UI files have been copied to:
echo   %STATIC_DIR%
echo.
echo You can now build the admin service:
echo   cd go-ldap-admin ^&^& go build
echo.

cd /d "%SCRIPT_DIR%"
endlocal
