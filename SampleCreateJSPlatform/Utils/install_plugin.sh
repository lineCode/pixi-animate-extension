#!/bin/bash

BUILD_TARGET=$1;
BUILD_SCHEME="";

# verify the command line args
if [ ${BUILD_TARGET} == "debug" ]; then
    BUILD_SCHEME="Debug";
elif [ ${BUILD_TARGET} == "release" ]; then
    BUILD_SCHEME="Release";
else
    echo "not a valid argument. please specify 'debug' or 'release'";
    exit 1;
fi

# build the xcode project to produce the plugin file
xcodebuild -project ../Plugin/SampleCreateJSPlugin/project/mac/SampleCreateJSPlugin.mp.xcodeproj -scheme SampleCreateJSPlugin.${BUILD_SCHEME} build

PLUGIN_FILE=../Plugin/SampleCreateJSPlugin/lib/mac/${BUILD_TARGET}/JiboPixiJSPlugin.fcm.plugin

# the plugin file needs to be placed in the eclipse project directory so it can be exported to a zxp
echo "Copy the plugin to the Eclipse Project directory";
\cp -r ${PLUGIN_FILE} ../EclipseProject/ExtensionContent/plugin/lib/mac/JiboPixiJSPlugin.fcm.plugin

# make sure the previous runs output has been cleared from the adobe flash extensions directory
echo "Deleting the previously created zxp file and the unpacked contents";
rm -rf /Library/Application\ Support/Adobe/CEP/extensions/JiboPixiJSPlugin/*

# create a zxp file in the adobe flash extensions directory from the previously created plugin
mkdir -p /Library/Application\ Support/Adobe/CEP/extensions/JiboPixiJSPlugin

echo "Sign and create the ZXP file from the plugin";
./ZXPSignCmd -sign ../EclipseProject /Library/Application\ Support/Adobe/CEP/extensions/JiboPixiJSPlugin/JiboPixiJSPlugin.zxp ../certificate.p12 password

# unpack the produced zxp file
tar -xzvf /Library/Application\ Support/Adobe/CEP/extensions/JiboPixiJSPlugin/JiboPixiJSPlugin.zxp -C /Library/Application\ Support/Adobe/CEP/extensions/JiboPixiJSPlugin

mv /Library/Application\ Support/Adobe/CEP/extensions/JiboPixiJSPlugin/.staged-extension/* /Library/Application\ Support/Adobe/CEP/extensions/JiboPixiJSPlugin 

mv /Library/Application\ Support/Adobe/CEP/extensions/JiboPixiJSPlugin/ExtensionContent/* /Library/Application\ Support/Adobe/CEP/extensions/JiboPixiJSPlugin 

exit 0;
