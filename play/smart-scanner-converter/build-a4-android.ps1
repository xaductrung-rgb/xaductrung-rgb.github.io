$ErrorActionPreference = "Stop"
$srcWeb = "C:\Users\xaduc\.gemini\antigravity\scratch\smart-scanner-converter"
$targetApp = "C:\Users\xaduc\.gemini\antigravity\scratch\a4-cleanscan-app"
$releaseDir = "$targetApp\release"

$env:JAVA_HOME = "C:\Program Files\Microsoft\jdk-21.0.12.101-hotspot"
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$env:Path = "$env:JAVA_HOME\bin;C:\Program Files\nodejs;$env:Path"
$bt = "$env:ANDROID_HOME\build-tools\36.0.0"

New-Item -ItemType Directory -Path "$targetApp\www" -Force | Out-Null
New-Item -ItemType Directory -Path $releaseDir -Force | Out-Null

# Copy web files (index.html + offline tailwindcss.min.js)
Copy-Item "$srcWeb\index.html" "$targetApp\www\index.html" -Force
Copy-Item "$srcWeb\tailwindcss.min.js" "$targetApp\www\tailwindcss.min.js" -Force

Set-Location $targetApp
npx cap sync android

Write-Host "Building Android APK & AAB for A4 CleanScan Pro..."
Set-Location "$targetApp\android"
.\gradlew.bat --no-daemon assembleRelease bundleRelease
if ($LASTEXITCODE -ne 0) { throw "Gradle build failed" }

$ks = "C:\Users\xaduc\.gemini\antigravity\scratch\pengu-hop-app\pengu-release.keystore"
$info = "C:\Users\xaduc\.gemini\antigravity\scratch\pengu-hop-app\KEYSTORE-INFO-GIU-KY.txt"
$pw = ((Get-Content $info | Select-String "Password").Line -split ": ")[1].Trim()

$outName = "A4CleanScanPro"

# Sign AAB
$aab = "app\build\outputs\bundle\release\app-release.aab"
Copy-Item $aab "$releaseDir\$outName.aab" -Force
jarsigner -keystore $ks -storepass $pw -keypass $pw -sigalg SHA256withRSA -digestalg SHA-256 "$releaseDir\$outName.aab" pengu

# Sign APK
$apkU = Get-ChildItem "app\build\outputs\apk\release" -Filter *.apk | Select-Object -First 1
& "$bt\zipalign.exe" -f -p 4 $apkU.FullName "$env:TEMP\a4cleanscan-aligned.apk"
& "$bt\apksigner.bat" sign --ks $ks --ks-pass "pass:$pw" --key-pass "pass:$pw" --out "$releaseDir\$outName.apk" "$env:TEMP\a4cleanscan-aligned.apk"
& "$bt\apksigner.bat" verify "$releaseDir\$outName.apk"

# Also copy APK to the local web directory so phones on WiFi can download it directly!
Copy-Item "$releaseDir\$outName.apk" "$srcWeb\$outName.apk" -Force

Get-Item "$releaseDir\$outName.apk", "$releaseDir\$outName.aab" | Select-Object Name, FullName, @{n = "MB"; e = { [math]::Round($_.Length / 1MB, 2) } }
Write-Host "SUCCESSFULLY BUILT AND SIGNED A4CleanScanPro!"
