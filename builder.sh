#!/bin/bash

certificate_name="Azim Gadzhiagayev local"
project_name="BorderControl"
configuration="Debug"

parent_build_dir=$(xcodebuild -project BorderControl.xcodeproj -scheme BorderControl -showBuildSettings | grep -w "BUILD_DIR" | awk -F' =' '{print $2}' | awk '{$1=$1};1')

endpoint_security_app_dir="$parent_build_dir/Debug/BorderControl.app"
endpoint_extension_dir="$parent_build_dir/Debug/BorderControl.app/Contents/Library/SystemExtensions/com.azimgd.BorderControl.Security.systemextension"
network_extension_dir="$parent_build_dir/Debug/BorderControl.app/Contents/Library/SystemExtensions/com.azimgd.BorderControl.Network.systemextension"

sudo systemextensionsctl uninstall - com.azimgd.BorderControl.Security
sudo systemextensionsctl uninstall - com.azimgd.BorderControl.Network
sudo systemextensionsctl uninstall B6BB88CAP5 com.azimgd.BorderControl.Security
sudo systemextensionsctl uninstall B6BB88CAP5 com.azimgd.BorderControl.Network

echo "------------------------------------------"
echo "Listing directories under parent build dir"
echo "------------------------------------------"
echo "main-app: $endpoint_security_app_dir"
echo "network-ext: $endpoint_extension_dir"
echo "endpoint-ext: $network_extension_dir"
echo "------------------------------------------"
codesign --verify --entitlements ./BorderControl/BorderControl.entitlements --force --deep --sign "$certificate_name" $endpoint_security_app_dir
codesign --verify --entitlements ./Security/Security.entitlements --force --deep --sign "$certificate_name" $endpoint_extension_dir
codesign --verify --entitlements ./Network/Network.entitlements --force --deep --sign "$certificate_name" $network_extension_dir
echo "------------------------------------------"
echo "executing from the sudo mode, need to enter root password"
sudo open -n $endpoint_security_app_dir --args -AppCommandLineArg
