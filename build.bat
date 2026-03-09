@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo 清理旧文件...
if exist dist rmdir /s /q dist
if exist build rmdir /s /q build
if exist *.spec del *.spec

echo 开始打包...
pyinstaller --onefile ^
  --windowed ^
  --icon=NONE ^
  --collect-all=paramiko ^
  --collect-all=cryptography ^
  --collect-all=bcrypt ^
  --collect-all=nacl ^
  --hidden-import=paramiko ^
  --hidden-import=cryptography ^
  --hidden-import=pycryptodome ^
  --hidden-import=bcrypt ^
  --hidden-import=nacl ^
  --hidden-import=nacl.bindings ^
  --hidden-import=nacl.utils ^
  --hidden-import=nacl.pwhash ^
  --hidden-import=nacl.secret ^
  --hidden-import=nacl.hash ^
  --hidden-import=nacl.signing ^
  --hidden-import=nacl.encoding ^
  --hidden-import=nacl.exceptions ^
  --noupx ^
  main.py

if %errorlevel% equ 0 (
    echo.
    echo ✓ 打包成功！EXE 文件在 dist 文件夹中
    pause
) else (
    echo.
    echo ✗ 打包失败！
    pause
)