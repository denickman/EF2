#!/bin/bash

export SECRET_KEY="12345678"
export CERTIFICATE_PASSWORD="12345"

export APPSTORE_USERNAME="yaremdennis@gmail.com"
export APPSTORE_PASSWORD="pcji-hchb-pixa-azan"
#!/bin/bash

# Шаг 1. Установим provisioning profile
echo "Install provisioning profiles"
gpg --quiet --batch --yes --decrypt --passphrase="$SECRET_KEY" --output .github/deployment/prodprofile.mobileprovision .github/deployment/prodprofile.mobileprovision.gpg
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp .github/deployment/prodprofile.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/

# Установим сертификаты
echo "Install keychain prod certificate"
gpg --quiet --batch --yes --decrypt --passphrase="$SECRET_KEY" --output .github/deployment/dev_certificate.p12 .github/deployment/dev_certificate.p12.gpg
security create-keychain -p "" build.keychain
security import .github/deployment/dev_certificate.p12 -t agg -k ~/Library/Keychains/build.keychain -P "$CERTIFICATE_PASSWORD" -A

gpg --quiet --batch --yes --decrypt --passphrase="$SECRET_KEY" --output .github/deployment/prod_certificate.p12 .github/deployment/prod_certificate.p12.gpg
security import .github/deployment/prod_certificate.p12 -t agg -k ~/Library/Keychains/build.keychain -P "$CERTIFICATE_PASSWORD" -A

security list-keychains -s ~/Library/Keychains/build.keychain
security default-keychain -s ~/Library/Keychains/build.keychain
security unlock-keychain -p "" ~/Library/Keychains/build.keychain
security set-key-partition-list -S apple-tool:,apple: -s -k "" ~/Library/Keychains/build.keychain

# Шаг 2. Выведем список установленных provisioning profiles и сертификатов
security find-identity -p codesigning -v
ls ~/Library/MobileDevice/Provisioning\ Profiles

# Шаг 3. Выберем Xcode
echo "Select Xcode"
sudo xcode-select -switch /Applications/Xcode_16.0.app

# Шаг 4. Проверим версию Xcode
echo "Xcode version"
xcodebuild -version

# Шаг 5. Увеличим номер сборки и установим его в Info.plist
echo "Increment Build Number and Set CFBundleVersion"
buildNumber=$((GITHUB_RUN_NUMBER + 10))  # Добавьте смещение, если нужно
echo "New build number: $buildNumber"
plutil -replace CFBundleVersion -string "$buildNumber" EssentialApp/EssentialApp/Info.plist
echo "Current CFBundleVersion:"
plutil -p EssentialApp/EssentialApp/Info.plist | grep CFBundleVersion

# Шаг 6. Сборка проекта
echo "Build"
xcodebuild clean archive \
  -sdk iphoneos \
  -workspace EssentialApp.xcworkspace \
  -configuration "Release" \
  -scheme "EssentialApp" \
  -derivedDataPath "DerivedData" \
  -archivePath "DerivedData/Archive/EssentialApp.xcarchive"

# Шаг 7. Экспортируем IPA
echo "Export"
xcodebuild -exportArchive -archivePath DerivedData/Archive/EssentialApp.xcarchive -exportOptionsPlist .github/deployment/ExportOptions.plist -exportPath DerivedData/ipa

# Шаг 8. Развертывание на App Store
echo "Deploy"
xcrun altool --upload-app --type ios --file "DerivedData/ipa/EssentialApp.ipa" --username "$APPSTORE_USERNAME" --password "$APPSTORE_PASSWORD" --verbose
