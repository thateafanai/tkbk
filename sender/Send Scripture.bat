@echo off
rem Double-click to launch the Apatani Biisi Kheta sender.
rem Opens the composer in your browser and starts the local server.
cd /d "%~dp0"
start "" http://localhost:4000
node server.js
pause
