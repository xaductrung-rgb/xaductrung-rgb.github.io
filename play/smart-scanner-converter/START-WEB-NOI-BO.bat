@echo off
chcp 65001 >nul
title A4 CleanScan Pro - Máy Chủ Web Nội Bộ (Không Quảng Cáo)
cd /d "%~dp0"
echo Đang khởi động Web Nội Bộ tại http://localhost:8088 ...
start "" "http://localhost:8088"
"C:\Program Files\nodejs\node.exe" server.mjs
pause
