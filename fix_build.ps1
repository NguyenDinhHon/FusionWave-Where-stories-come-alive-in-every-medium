# Script để fix lỗi build Flutter trên Windows
# Chạy: .\fix_build.ps1

Write-Host "Cleaning Flutter build..." -ForegroundColor Yellow

# Đóng các process có thể đang lock file
Write-Host "Closing Chrome processes..." -ForegroundColor Yellow
Get-Process chrome -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# Xóa các thư mục build
Write-Host "Removing build directories..." -ForegroundColor Yellow
Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path ".dart_tool" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "windows\flutter\ephemeral" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "ios\Flutter\ephemeral" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "macos\Flutter\ephemeral" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "linux\flutter\ephemeral" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Running flutter clean..." -ForegroundColor Yellow
flutter clean

Write-Host "Getting dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host "Done! You can now run: flutter run -d chrome" -ForegroundColor Green

