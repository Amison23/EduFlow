# iOS Build Instructions

This directory contains the iOS-specific configurations for the EduFlow mobile application.

## Critical Step for First-Time Setup

If you are running this project on a Mac for the first time or if new native plugins have been added, you **must** install the CocoaPods dependencies.

Run the following commands from the `mobile` directory:

```bash
cd ios
pod install
```

This will generate or update the `Runner.xcworkspace` file, which should be used to open the project in Xcode.

## Note for Windows Users
CocoaPods requires macOS. If you are on Windows, you can continue developing Flutter code, but you will not be able to build or run the iOS version of the app.
