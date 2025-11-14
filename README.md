# react-native-tus-client

React Native client for the **tus** resumable upload protocol [tus.io](https://tus.io) inspired to [tus-js-client](https://github.com/tus/tus-js-client).

It provides a native tus compliant implementation through the official [TUSKit](https://github.com/tus/TUSKit) and [tus-android-client](https://github.com/tus/tus-android-client) libraries.

## Getting started

`$ npm install react-native-tus-client --save`

or

`$ yarn add react-native-tus-client`

### Mostly automatic installation

```
# RN >= 0.60
cd ios && pod install

# RN < 0.60
react-native link react-native-tus-client
```

### Manual installation

#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-tus-client` and add `RNTusClient.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNTusClient.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`

- Add `import com.vinzscam.RNTusClientPackage;` to the imports at the top of the file
- Add `new RNTusClientPackage()` to the list returned by the `getPackages()` method

2. Append the following lines to `android/settings.gradle`:
   ```
   include ':react-native-tus-client'
   project(':react-native-tus-client').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-tus-client/android')
   ```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
   ```
     compile project(':react-native-tus-client')
   ```

## TUSKit Bug Fix

### Problem

TUSKit (iOS dependency via CocoaPods) has a bug in `TUSFileData.m` on line 23:

- It uses `url.filePathURL` instead of `url.path`
- `filePathURL` does not exist as a property of `NSURL`
- This causes a crash: `-[NSURL length]: unrecognized selector sent to instance`

### Solution

This fork includes an automatic fix script that patches the TUSKit bug during `pod install`. The script `ios/fix_tuskit.sh` automatically replaces `url.filePathURL` with `url.path` in the TUSKit source files.

### Installation

To use the automatic fix, add the following `post_install` hook to your `Podfile`:

```ruby
post_install do |installer|
  # Fix TUSKit bug in TUSFileData.m
  tus_client_script = File.join(__dir__, '..', 'node_modules', 'react-native-tus-client', 'ios', 'fix_tuskit.sh')

  if File.exist?(tus_client_script)
    system("PODS_ROOT=#{installer.sandbox.root} #{tus_client_script}")
  end
end
```

The script will:

1. Locate the TUSKit source file in the Pods directory
2. Check if the fix has already been applied
3. Replace `url.filePathURL` with `url.path` if needed
4. Print a confirmation message when the fix is applied

**Note:** The fix is applied automatically each time you run `pod install`, so you don't need to worry about it being overwritten.

## Usage

All you need to know to upload a file to a [tus](https://tus.io/) server is the **local absolute path where the file is stored**.
If you know it, you can just invoke the library as described in the snippet at the end of this section.
If you don't know where your file is stored, some other library like [react-native-image-picker](https://github.com/react-community/react-native-image-picker) might help you.

### Upload a file by its absolute path

```javascript
import { Upload } from 'react-native-tus-client';

const absoluteFilePath = // absolute path to your file;
const upload = new Upload(absoluteFilePath, {
  endpoint: 'https://master.tus.io/files/', // use your tus server endpoint instead
  onError: error => console.log('error', error),
  onSuccess: () => {
    console.log('Upload completed! File url:', upload.url);
  },
  onProgress: (uploaded, total) => console.log(
    `Progress: ${(uploaded/total*100)|0}%`)
});
upload.start();

```

### Upload an image using [react-native-image-picker](https://github.com/react-community/react-native-image-picker)

```javascript
import ImagePicker from "react-native-image-picker";
import { Upload } from "react-native-tus-client";

new Promise((resolve, reject) => {
  ImagePicker.showImagePicker({}, ({ uri, error, path }) => {
    return uri ? resolve(path || uri) : reject(error || null);
  });
})
  .then((file) => {
    const upload = new Upload(file, {
      endpoint: "https://master.tus.io/files/", // use your tus server endpoint instead
      onError: (error) => console.log("error", error),
      onSuccess: () => {
        console.log("Upload completed. File url:", upload.url);
      },
      onProgress: (uploaded, total) =>
        console.log(`Progress: ${((uploaded / total) * 100) | 0}%`),
    });
    upload.start();
  })
  .catch((e) => console.log("error", e));
```

## API

### Class Upload

Class representing a tus upload.

#### Constructor

`new Upload(file, settings)`

##### Parameters:

| Name    | Type   | Description                                                    |
| ------- | ------ | :------------------------------------------------------------- |
| file    | string | The file absolute path                                         |
| options | object | The options argument used to setup your tus upload. See below. |

#### Options:

| Property   | Type     | Mandatory | Description                                                                                                                                                                               |
| ---------- | -------- | --------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| endpoint   | string   | **Yes**   | URL used to create the upload                                                                                                                                                             |
| headers    | object   | No        | An object with custom header values used in all requests.                                                                                                                                 |
| metadata   | object   | No        | An object with string values used as additional meta data which will be passed along to the server when (and only when) creating a new upload. Can be used for filenames, file types etc. |
| onError    | function | No        | a function called once an error appears. The arguments will be an `Error` instance.                                                                                                       |
| onProgress | function | No        | a function that will be called each time progress information is available. The arguments will be `bytesSent` and `bytesTotal`                                                            |
| onSuccess  | function | No        | a function called when the upload finished successfully.                                                                                                                                  |

#### Methods

| Name  | Description                                                                                                                 |
| ----- | :-------------------------------------------------------------------------------------------------------------------------- |
| start | Start or resume the upload using the specified file. If no file property is available the error handler will be called.     |
| abort | Abort the currently running upload request and don't continue. You can resume the upload by calling the start method again. |
