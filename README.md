|[Introduction](#cordova-plugin-ml-text) | [Supported_Platforms](#supported-platforms) | [Installation_Steps](#installation-steps) | [Plugin_Usage](#plugin-usage) | [Working_Examples](#working-examples) | [More_about_us!](#more-about-us)|
|:---:|:------:|:---:|:---:|:---:|:---:|
|||||||


# cordova-plugin-ml-text

> This plugin was made possible because of Google's [ML Kit](https://firebase.google.com/docs/ml-kit/) SDK, as it is a dependency of this plugin. The supported languages are listed [here](https://developers.google.com/vision/android/text-overview). This plugin is absolutely free and will work offline once install is complete. All required files required for Text Recognition are downloaded during install if necessary space is available.

This plugin defines a global `mltext` object, which provides an method that accepts image uri or base64 inputs. If some text was detected in the image, this text will be returned in an object. The imageuri or base64 can be send to the plugin using any another plugin like [cordova-plugin-camera](https://github.com/apache/cordova-plugin-camera) or [cordova-plugin-document-scanner](https://github.com/NeutrinosPlatform/cordova-plugin-document-scanner). Although the object is attached to the global scoped `window`, it is not available until after the `deviceready` event.

```
document.addEventListener("deviceready", onDeviceReady, false);
function onDeviceReady() {
console.log(mltext);
}
```

# Supported Platforms

- Android
- iOS

# Installation Steps

This requires cordova 7.1.0+ , cordova android 6.4.0+ and cordova ios 4.3.0+

`cordova plugin add cordova-plugin-ml-text`

> Note : This might take a while!

**Optional installation variable for Android**
*MLKIT_TEXT_RECOGNITION_VERSION*
Version of `com.google.android.gms:play-services-mlkit-text-recognition`. This defaults to `16.1.0` but by using this variable you can specify a different version if you like:

`cordova plugin add cordova-plugin-ml-text --variable MLKIT_TEXT_RECOGNITION_VERSION=16.1.0`

Also add the following plugin :- 

- `cordova plugin add cordova-plugin-camera`


**Firebase Setup :-**
This version of the plugin only uses the on-device functionality and no longer requires Firebase.

# Plugin Usage

`mltext.getText(onSuccess, onFail, options);`
- **mltext.getText**
The **`mltext.getText`** function accepts image data as uri or base64 and uses google mobile vision to recognize text and return the recognized text as string on its successcallback.
- **options**
Object that takes the following key - value pairs :-
> Exampe **options** object :-  `{imgType : 0,imgSrc : imageData}` where imageData is obtained from the camera or scan plugin.
- **imgType**
The **`imgType`** parameter can take values 0,1,2,3 or 4 each of which are explained in detail in the table below. `sourceType` is an `Int` within the native code.

| imgType        | imgSrc     | Accuracy      | Recommendation  | Notes       |
| :-------------:   |:-------------:|:-------------:|:-------------:  |:-------------:  |
| 0                 | NORMFILEURI   | Very High     | Recommended     | On android this is same as NORMNATIVEURI |
| 1                 | NORMNATIVEURI | Very High     | Not Recommended (See note below)     | On android this is same as NORMFILEURI |
| 2                 | FASTFILEURI   | Very Low      | Not Recommended | On android this is same as FASTNATIVEURI. Compression allows for faster processing but sacrifices a lot of accuracy. Best used if ocr images will always be extremely large with large text in them. |
| 3                 | FASTNATIVEURI | Very Low      | Not Recommended | On android this is same as FASTFILEURI. Compression allows for faster processing but sacrifices a lot of accuracy. Best used if ocr images will always be extremely large with large text in them. |
| 4                 | BASE64        | Very High     | Not Recommended | Extremely memory intensive and thus not recommended

>*Note :- NORMNATIVEURI & FASTNATIVEURI for iOS uses deprecated methods to access images. This is to support the [camera](https://github.com/apache/cordova-plugin-camera) plugin which still uses the deprecated methods to return native image URI's using [ALAssetsLibrary](https://developer.apple.com/documentation/assetslibrary/alassetslibrary). This plugin uses non deprecated [PHAsset](https://developer.apple.com/documentation/photokit/phasset?language=objc) library whose deprecated method [fetchAssets(withALAssetURLs:options:)](https://developer.apple.com/documentation/photokit/phasset/1624782-fetchassets) is used to retrieve the image data.*

- **imgSrc**
The plugin accepts image uri or base64 data in **`imgSrc`** which is obtained from another plugin like cordova-plugin-document-scanner or cordova-plugin-camera.  This `imgSrc` is then used by the plugin and via the ML Kit libary, it detects the text on the image. The data required for OCR is initially downloaded when the app is first installed. 

> Example imgSrc for NORMFILEURI or FASTFILEURI as obtained from [camera plugin](https://github.com/apache/cordova-plugin-camera) or [scanner plugin](https://github.com/NeutrinosPlatform/cordova-plugin-document-scanner) :- file:///var/mobile/Containers/Data/Application/FF505EA5-F16E-4CBA-8F8B-76A219EDA407/tmp/cdv_photo_001.jpg

> Example imgSrc for NORMNATIVEURI or FASTNATIVEURI as obtained from [camera plugin](https://github.com/apache/cordova-plugin-camera). [scanner plugin](https://github.com/NeutrinosPlatform/cordova-plugin-document-scanner) doesn't return this :- assets-library://asset/asset.JPG?id=EFBA7BCD-3031-4646-9874-49368849749A&ext=JPG

- **successCallback**
The return value is sent to the **`successCallback`** callback function, in string format if no errors occured. [Sample object](#example-objects)  received from the successCallback can be found at the very bottom of this readme ([iOS Sample Object](#ios-example-object) & [Android Sample Object](#android-example-object)). The following image gives a better understanding of Blocks, Lines and Words as used in the return object.

![N|Solid](https://developers.google.com/vision/images/text-structure.png "Difference between blocks, lines and words")

The value imgWidth and imgHeight return the size of the processed image. Depending on the imgType the image could be resized.
- **errorCallback**
The **`errorCallback`** function returns `Scan Failed: Found no text to scan` if no text was detected on the image. It also return other messages based on the error conditions.

>*Note :- After install the OCR App using this plugin does not need an internet connection for Optical Character Recognition since all the required data is downloaded locally on install.*

You can do whatever you want with the string obtained from this plugin, for example:
- **Render the text** in an `<p>` tag.
- `<p id="pp">nothing yet. wait</p>` in html
- `var element = document.getElementById('pp');
element.innerHTML=recognizedText.blocks.blocktext;` in js

> *Note :- This plugin doesn't handle permissions as it only requires the URIs or Base64 data of images and thus expects the other plugins that provide it the URI or Base64 data to handle permissions.*

# Working Examples
Please use `cordova plugin add cordova-plugin-camera` or `cordova plugin add cordova-plugin-document-scanner` before using the following examples.

>*Note :- The cordova-plugin-mobile-ocr plugin will not automatically download either of these plugins as dependencies (This is because this plugin can be used as standalone plugin which can accept URIs or Base64 data through any method or plugin).*

**Using [cordova-plugin-camera](https://github.com/apache/cordova-plugin-camera)** 
```js 
navigator.camera.getPicture(onSuccess, onFail, { quality: 100, correctOrientation: true });

function onSuccess(imageData) {
      mltext.getText(onSuccess, onFail,{imgType : 0, imgSrc : imageData});
      // for imgType Use 0,1,2,3 or 4
      function onSuccess(recognizedText) {
            //var element = document.getElementById('pp');
            //element.innerHTML=recognizedText.blocks.blocktext;
            //Use above two lines to show recognizedText in html
            console.log(recognizedText);
            alert(recognizedText.blocks.blocktext);
      }
      function onFail(message) {
            alert('Failed because: ' + message);
      }
}
function onFail(message) {
      alert('Failed because: ' + message);
}

```

**Using [cordova-plugin-document-scanner](https://github.com/NeutrinosPlatform/cordova-plugin-document-scanner)** 
>*Note :- base64 and NATIVEURIs won't work with cordova-plugin-document-scanner plugin*
```js 
scan.scanDoc(successCallback, errorCallback, {sourceType : 1, fileName : "myfilename", quality : 1.0, returnBase64 : false}); 

function successCallback(imageURI) {
      mltext.getText(onSuccess, onFail,{imgSrc : imageData}); 
      // for imgType Use 0,2 // 1,3,4 won't work
      function onSuccess(recognizedText) {
            //var element = document.getElementById('pp');
            //element.innerHTML=recognizedText.lines.linetext;
            //Use above two lines to show recognizedText in html
            console.log(recognizedText);
            alert(recognizedText.lines.linetext);
      }
      function onFail(message) {
            alert('Failed because: ' + message);
      }
}
function errorCallback(message) {
      alert('Failed because: ' + message);
}
```

# More about us
Find out more or contact us directly here :- https://www.neutrinos.co/

Facebook :- https://www.facebook.com/Neutrinos.co/ <br/>
LinkedIn :- https://www.linkedin.com/company/25057297/ <br/>
Twitter :- https://twitter.com/Neutrinosco <br/>
Instagram :- https://www.instagram.com/neutrinos.co/

[![N|Solid](https://image4.owler.com/logo/neutrinos_owler_20171023_142541_original.jpg "Neutrinos")](https://www.neutrinos.co/) 

# Example Objects
The five properties text, languages, confidence, points and frame are obtained as arrays and are associated with each other using the index of the array.

>For example :- 
The text **linetext[0]** contains the languages **linelanguages[0]** and have a confidence of **lineconfidence[0]** with **linepoints[0]** and **lineframe [0]**. 

>Refer the examples to see how the points and frame are returned. Points hold four (x,y) point values that can be used to draw a box around each text. The Frame holds the origin x,y value, the height and the width of the rectangle that can be drawn around the text. The x,y value returned from the Frame property usually correspond to x1 and y4 of the Points property. The Points and Frame values can be used to obtain the placement of the text on the image

The basic structure of the object is as follows :- 

> **foundText** was added in plugin version 3.0.0 and above. In earlier plugin versions if image did not contain text the error callback was called. From 3.0.0 onwards all success callbacks will contain the `foundText` key with a boolean value. Letting the user know if a text was present in the image. if `foundText` is false, text was not found and hence the `blocks`, `lines`, `words` keys won't be returned

 - **foundText** - **boolean** value that is true if image contains text else false
 - **blocks**
   - **blocktext** - **Array** that contains each text block
   - **blockpoints** - **Array** of objects of four points each that represent a block drawn around the text
     - x1 - Key (Example to get x1 of the first text block :- recognizedText.blocks.blockpoints[0].x1)
     - y1 - Key
     - x2 - Key
     - y2 - Key
     - x3 - Key
     - y3 - Key
     - x4 - Key
     - y4 - Key
   - **blockframe** - **Array** of objects that contain origin point and size of the rectangle that holds text
     - x - Key (Example to get x from blockframe of the first text block :- recognizedText.blocks.blockframe[0].x)
     - y - Key
     - height - Key
     - width - Key
 - **lines**
   - **linetext** - **Array** that contains each text block
   - **linepoints** - **Array** of objects of four points each that represent a block drawn around the text
        - x1 - Key
        - y1 - Key
        - x2 - Key
        - y2 - Key
        - x3 - Key
        - y3 - Key
        - x4 - Key
        - y4 - Key
   - **lineframe** - **Array** of objects that contain origin point and size of the rectangle that holds text
     - x - Key
     - y - Key
     - height - Key
     - width - Key
 - **words**
   - **wordtext** - **Array** that contains each text block
   - **wordpoints** - **Array** of objects of four points each that represent a block drawn around the text
        - x1 - Key
        - y1 - Key
        - x2 - Key
        - y2 - Key
        - x3 - Key
        - y3 - Key
        - x4 - Key
        - y4 - Key
   - **wordframe** - **Array** of objects that contain origin point and size of the rectangle that holds text
     - x - Key
     - y - Key
     - height - Key
     - width - Key
# Example Object when no text in image
```json
{
  "foundText" : false
}
```
# iOS Example Object
```json
{
  "foundText" : true,
  "imgWidht": 600,
  "imgHeight": 600,
  "text": "# 3\n2\nQ\nW\nE\nA\nS\nD\nz\nx",
  "blocks": {
    "blockpoints": [
      {
        "x3": "2338.143066",
        "y1": "52.000000",
        "x1": "2073.000000",
        "y4": "656.654541",
        "x4": "1972.193848",
        "y2": "113.009895",
        "x2": "2438.949219",
        "y3": "717.664429"
      },
      {
        "x3": "1204.772949",
        "y1": "255.000000",
        "x1": "942.000000",
        "y4": "537.928284",
        "x4": "865.838440",
        "y2": "346.237946",
        "x2": "1280.934570",
        "y3": "629.166199"
      },
      {
        "x3": "628.515869",
        "y1": "1192.000000",
        "x1": "398.000000",
        "y4": "1452.757080",
        "x4": "386.741180",
        "y2": "1202.439209",
        "x2": "639.774719",
        "y3": "1463.196289"
      },
      {
        "x3": "1787.353516",
        "y1": "1257.000000",
        "x1": "1495.000000",
        "y4": "1482.905884",
        "x4": "1488.478027",
        "y2": "1265.628662",
        "x2": "1793.875488",
        "y3": "1491.534546"
      },
      {
        "x3": "2804.546387",
        "y1": "1267.000000",
        "x1": "2495.000000",
        "y4": "1547.713013",
        "x4": "2468.088867",
        "y2": "1299.255127",
        "x2": "2831.457520",
        "y3": "1579.968140"
      },
      {
        "x3": "939.620850",
        "y1": "2279.000000",
        "x1": "587.000000",
        "y4": "2548.592773",
        "x4": "572.175903",
        "y2": "2299.204590",
        "x2": "954.444946",
        "y3": "2568.797363"
      },
      {
        "x3": "1968.580078",
        "y1": "2307.000000",
        "x1": "1776.000000",
        "y4": "2534.936768",
        "x4": "1770.634888",
        "y2": "2311.659180",
        "x2": "1973.945190",
        "y3": "2539.595947"
      },
      {
        "x3": "2982.085693",
        "y1": "2334.000000",
        "x1": "2793.000000",
        "y4": "2544.980225",
        "x4": "2790.103760",
        "y2": "2336.635254",
        "x2": "2984.981934",
        "y3": "2547.615479"
      },
      {
        "x3": "1426.792480",
        "y1": "3287.000000",
        "x1": "1072.000000",
        "y4": "3611.215088",
        "x4": "1037.933228",
        "y2": "3327.859375",
        "x2": "1460.859253",
        "y3": "3652.074463"
      },
      {
        "x3": "2455.617920",
        "y1": "3346.000000",
        "x1": "2255.000000",
        "y4": "3559.973633",
        "x4": "2251.643066",
        "y2": "3349.199951",
        "x2": "2458.974854",
        "y3": "3563.173584"
      }
    ],
    "blocktext": [
      "# 3",
      "2",
      "Q",
      "W",
      "E",
      "A",
      "S",
      "D",
      "Z",
      "X"
    ],
    "blockframe": [
      {
        "y": "52.000000",
        "x": "1972.000000",
        "height": "666.000000",
        "width": "467.000000"
      },
      {
        "y": "255.000000",
        "x": "865.000000",
        "height": "375.000000",
        "width": "416.000000"
      },
      {
        "y": "1192.000000",
        "x": "386.000000",
        "height": "272.000000",
        "width": "254.000000"
      },
      {
        "y": "1257.000000",
        "x": "1488.000000",
        "height": "235.000000",
        "width": "306.000000"
      },
      {
        "y": "1267.000000",
        "x": "2468.000000",
        "height": "313.000000",
        "width": "364.000000"
      },
      {
        "y": "2279.000000",
        "x": "572.000000",
        "height": "290.000000",
        "width": "383.000000"
      },
      {
        "y": "2307.000000",
        "x": "1770.000000",
        "height": "233.000000",
        "width": "204.000000"
      },
      {
        "y": "2334.000000",
        "x": "2790.000000",
        "height": "214.000000",
        "width": "195.000000"
      },
      {
        "y": "3287.000000",
        "x": "1037.000000",
        "height": "366.000000",
        "width": "424.000000"
      },
      {
        "y": "3346.000000",
        "x": "2251.000000",
        "height": "218.000000",
        "width": "208.000000"
      }
    ]
  },
  "lines": {
    "lineframe": [
      {
        "y": "53.000000",
        "x": "2048.000000",
        "height": "231.000000",
        "width": "264.000000"
      },
      {
        "y": "342.000000",
        "x": "1979.000000",
        "height": "369.000000",
        "width": "405.000000"
      },
      {
        "y": "255.000000",
        "x": "865.000000",
        "height": "375.000000",
        "width": "416.000000"
      },
      {
        "y": "1192.000000",
        "x": "386.000000",
        "height": "272.000000",
        "width": "254.000000"
      },
      {
        "y": "1257.000000",
        "x": "1488.000000",
        "height": "235.000000",
        "width": "306.000000"
      },
      {
        "y": "1267.000000",
        "x": "2468.000000",
        "height": "313.000000",
        "width": "364.000000"
      },
      {
        "y": "2279.000000",
        "x": "572.000000",
        "height": "290.000000",
        "width": "383.000000"
      },
      {
        "y": "2307.000000",
        "x": "1770.000000",
        "height": "233.000000",
        "width": "204.000000"
      },
      {
        "y": "2334.000000",
        "x": "2790.000000",
        "height": "214.000000",
        "width": "195.000000"
      },
      {
        "y": "3287.000000",
        "x": "1037.000000",
        "height": "366.000000",
        "width": "424.000000"
      },
      {
        "y": "3346.000000",
        "x": "2251.000000",
        "height": "218.000000",
        "width": "208.000000"
      }
    ],
    "linetext": [
      "#",
      "3",
      "2",
      "Q",
      "W",
      "E",
      "A",
      "S",
      "D",
      "Z",
      "X"
    ],
    "linepoints": [
      {
        "x3": "2279.747070",
        "y1": "53.000000",
        "x1": "2081.000000",
        "y4": "245.345245",
        "x4": "2048.932861",
        "y2": "91.480637",
        "x2": "2311.814209",
        "y3": "283.825897"
      },
      {
        "x3": "2295.458252",
        "y1": "342.000000",
        "x1": "2067.000000",
        "y4": "605.842957",
        "x4": "1979.416382",
        "y2": "446.911316",
        "x2": "2383.041992",
        "y3": "710.754272"
      },
      {
        "x3": "1204.772949",
        "y1": "255.000000",
        "x1": "942.000000",
        "y4": "537.928284",
        "x4": "865.838440",
        "y2": "346.237946",
        "x2": "1280.934570",
        "y3": "629.166199"
      },
      {
        "x3": "628.515869",
        "y1": "1192.000000",
        "x1": "398.000000",
        "y4": "1452.757080",
        "x4": "386.741180",
        "y2": "1202.439209",
        "x2": "639.774719",
        "y3": "1463.196289"
      },
      {
        "x3": "1787.353516",
        "y1": "1257.000000",
        "x1": "1495.000000",
        "y4": "1482.905884",
        "x4": "1488.478027",
        "y2": "1265.628662",
        "x2": "1793.875488",
        "y3": "1491.534546"
      },
      {
        "x3": "2804.546387",
        "y1": "1267.000000",
        "x1": "2495.000000",
        "y4": "1547.713013",
        "x4": "2468.088867",
        "y2": "1299.255127",
        "x2": "2831.457520",
        "y3": "1579.968140"
      },
      {
        "x3": "939.620850",
        "y1": "2279.000000",
        "x1": "587.000000",
        "y4": "2548.592773",
        "x4": "572.175903",
        "y2": "2299.204590",
        "x2": "954.444946",
        "y3": "2568.797363"
      },
      {
        "x3": "1968.580078",
        "y1": "2307.000000",
        "x1": "1776.000000",
        "y4": "2534.936768",
        "x4": "1770.634888",
        "y2": "2311.659180",
        "x2": "1973.945190",
        "y3": "2539.595947"
      },
      {
        "x3": "2982.085693",
        "y1": "2334.000000",
        "x1": "2793.000000",
        "y4": "2544.980225",
        "x4": "2790.103760",
        "y2": "2336.635254",
        "x2": "2984.981934",
        "y3": "2547.615479"
      },
      {
        "x3": "1426.792480",
        "y1": "3287.000000",
        "x1": "1072.000000",
        "y4": "3611.215088",
        "x4": "1037.933228",
        "y2": "3327.859375",
        "x2": "1460.859253",
        "y3": "3652.074463"
      },
      {
        "x3": "2455.617920",
        "y1": "3346.000000",
        "x1": "2255.000000",
        "y4": "3559.973633",
        "x4": "2251.643066",
        "y2": "3349.199951",
        "x2": "2458.974854",
        "y3": "3563.173584"
      }
    ]
  },
  "words": {
    "wordtext": [
      "#",
      "3",
      "2",
      "Q",
      "W",
      "E",
      "A",
      "S",
      "D",
      "Z",
      "X"
    ],
    "wordpoints": [
      {
        "x3": "2279.747070",
        "y1": "53.000000",
        "x1": "2081.000000",
        "y4": "245.345245",
        "x4": "2048.932861",
        "y2": "91.480637",
        "x2": "2311.814209",
        "y3": "283.825897"
      },
      {
        "x3": "2295.458252",
        "y1": "342.000000",
        "x1": "2067.000000",
        "y4": "605.842957",
        "x4": "1979.416382",
        "y2": "446.911316",
        "x2": "2383.041992",
        "y3": "710.754272"
      },
      {
        "x3": "1204.772949",
        "y1": "255.000000",
        "x1": "942.000000",
        "y4": "537.928284",
        "x4": "865.838440",
        "y2": "346.237946",
        "x2": "1280.934570",
        "y3": "629.166199"
      },
      {
        "x3": "628.515869",
        "y1": "1192.000000",
        "x1": "398.000000",
        "y4": "1452.757080",
        "x4": "386.741180",
        "y2": "1202.439209",
        "x2": "639.774719",
        "y3": "1463.196289"
      },
      {
        "x3": "1787.353516",
        "y1": "1257.000000",
        "x1": "1495.000000",
        "y4": "1482.905884",
        "x4": "1488.478027",
        "y2": "1265.628662",
        "x2": "1793.875488",
        "y3": "1491.534546"
      },
      {
        "x3": "2804.546387",
        "y1": "1267.000000",
        "x1": "2495.000000",
        "y4": "1547.713013",
        "x4": "2468.088867",
        "y2": "1299.255127",
        "x2": "2831.457520",
        "y3": "1579.968140"
      },
      {
        "x3": "939.620850",
        "y1": "2279.000000",
        "x1": "587.000000",
        "y4": "2548.592773",
        "x4": "572.175903",
        "y2": "2299.204590",
        "x2": "954.444946",
        "y3": "2568.797363"
      },
      {
        "x3": "1968.580078",
        "y1": "2307.000000",
        "x1": "1776.000000",
        "y4": "2534.936768",
        "x4": "1770.634888",
        "y2": "2311.659180",
        "x2": "1973.945190",
        "y3": "2539.595947"
      },
      {
        "x3": "2982.085693",
        "y1": "2334.000000",
        "x1": "2793.000000",
        "y4": "2544.980225",
        "x4": "2790.103760",
        "y2": "2336.635254",
        "x2": "2984.981934",
        "y3": "2547.615479"
      },
      {
        "x3": "1426.792480",
        "y1": "3287.000000",
        "x1": "1072.000000",
        "y4": "3611.215088",
        "x4": "1037.933228",
        "y2": "3327.859375",
        "x2": "1460.859253",
        "y3": "3652.074463"
      },
      {
        "x3": "2455.617920",
        "y1": "3346.000000",
        "x1": "2255.000000",
        "y4": "3559.973633",
        "x4": "2251.643066",
        "y2": "3349.199951",
        "x2": "2458.974854",
        "y3": "3563.173584"
      }
    ],
    "wordframe": [
      {
        "y": "53.000000",
        "x": "2048.000000",
        "height": "231.000000",
        "width": "264.000000"
      },
      {
        "y": "342.000000",
        "x": "1979.000000",
        "height": "369.000000",
        "width": "405.000000"
      },
      {
        "y": "255.000000",
        "x": "865.000000",
        "height": "375.000000",
        "width": "416.000000"
      },
      {
        "y": "1192.000000",
        "x": "386.000000",
        "height": "272.000000",
        "width": "254.000000"
      },
      {
        "y": "1257.000000",
        "x": "1488.000000",
        "height": "235.000000",
        "width": "306.000000"
      },
      {
        "y": "1267.000000",
        "x": "2468.000000",
        "height": "313.000000",
        "width": "364.000000"
      },
      {
        "y": "2279.000000",
        "x": "572.000000",
        "height": "290.000000",
        "width": "383.000000"
      },
      {
        "y": "2307.000000",
        "x": "1770.000000",
        "height": "233.000000",
        "width": "204.000000"
      },
      {
        "y": "2334.000000",
        "x": "2790.000000",
        "height": "214.000000",
        "width": "195.000000"
      },
      {
        "y": "3287.000000",
        "x": "1037.000000",
        "height": "366.000000",
        "width": "424.000000"
      },
      {
        "y": "3346.000000",
        "x": "2251.000000",
        "height": "218.000000",
        "width": "208.000000"
      }
    ]
  }
}
```
# Android Example Object
```json
{
  "foundText" : true,
  "blocks": {
    "blocktext": [
      "Home",
      "Ins",
      "PgUp",
      "PgDn",
      "Del"
    ],
    "blockpoints": [
      {
        "x1": 270,
        "y1": 346,
        "x2": 652,
        "y2": 346,
        "x3": 652,
        "y3": 468,
        "x4": 270,
        "y4": 468
      },
      {
        "x1": 913,
        "y1": 2459,
        "x2": 1215,
        "y2": 2459,
        "x3": 1215,
        "y3": 2627,
        "x4": 913,
        "y4": 2627
      },
      {
        "x1": 1497,
        "y1": 292,
        "x2": 1907,
        "y2": 292,
        "x3": 1907,
        "y3": 496,
        "x4": 1497,
        "y4": 496
      },
      {
        "x1": 1543,
        "y1": 1722,
        "x2": 1953,
        "y2": 1722,
        "x3": 1953,
        "y3": 1878,
        "x4": 1543,
        "y4": 1878
      },
      {
        "x1": 1659,
        "y1": 2451,
        "x2": 1900,
        "y2": 2451,
        "x3": 1900,
        "y3": 2585,
        "x4": 1659,
        "y4": 2585
      }
    ],
    "blockframe": [
      {
        "x": 270,
        "y": 468,
        "height": 122,
        "width": 382
      },
      {
        "x": 913,
        "y": 2627,
        "height": 168,
        "width": 302
      },
      {
        "x": 1497,
        "y": 496,
        "height": 204,
        "width": 410
      },
      {
        "x": 1543,
        "y": 1878,
        "height": 156,
        "width": 410
      },
      {
        "x": 1659,
        "y": 2585,
        "height": 134,
        "width": 241
      }
    ]
  },
  "lines": {
    "linetext": [
      "Home",
      "Ins",
      "PgUp",
      "PgDn",
      "Del"
    ],
    "linepoints": [
      {
        "x1": 270,
        "y1": 346,
        "x2": 652,
        "y2": 346,
        "x3": 652,
        "y3": 468,
        "x4": 270,
        "y4": 468
      },
      {
        "x1": 913,
        "y1": 2459,
        "x2": 1215,
        "y2": 2459,
        "x3": 1215,
        "y3": 2627,
        "x4": 913,
        "y4": 2627
      },
      {
        "x1": 1497,
        "y1": 292,
        "x2": 1907,
        "y2": 292,
        "x3": 1907,
        "y3": 496,
        "x4": 1497,
        "y4": 496
      },
      {
        "x1": 1543,
        "y1": 1722,
        "x2": 1953,
        "y2": 1722,
        "x3": 1953,
        "y3": 1878,
        "x4": 1543,
        "y4": 1878
      },
      {
        "x1": 1659,
        "y1": 2451,
        "x2": 1900,
        "y2": 2451,
        "x3": 1900,
        "y3": 2585,
        "x4": 1659,
        "y4": 2585
      }
    ],
    "lineframe": [
      {
        "x": 270,
        "y": 468,
        "height": 122,
        "width": 382
      },
      {
        "x": 913,
        "y": 2627,
        "height": 168,
        "width": 302
      },
      {
        "x": 1497,
        "y": 496,
        "height": 204,
        "width": 410
      },
      {
        "x": 1543,
        "y": 1878,
        "height": 156,
        "width": 410
      },
      {
        "x": 1659,
        "y": 2585,
        "height": 134,
        "width": 241
      }
    ]
  },
  "words": {
    "wordtext": [
      "Home",
      "Ins",
      "PgUp",
      "PgDn",
      "Del"
    ],
    "wordpoints": [
      {
        "x1": 270,
        "y1": 346,
        "x2": 652,
        "y2": 346,
        "x3": 652,
        "y3": 468,
        "x4": 270,
        "y4": 468
      },
      {
        "x1": 913,
        "y1": 2459,
        "x2": 1215,
        "y2": 2459,
        "x3": 1215,
        "y3": 2627,
        "x4": 913,
        "y4": 2627
      },
      {
        "x1": 1497,
        "y1": 292,
        "x2": 1907,
        "y2": 292,
        "x3": 1907,
        "y3": 496,
        "x4": 1497,
        "y4": 496
      },
      {
        "x1": 1543,
        "y1": 1722,
        "x2": 1953,
        "y2": 1722,
        "x3": 1953,
        "y3": 1878,
        "x4": 1543,
        "y4": 1878
      },
      {
        "x1": 1659,
        "y1": 2451,
        "x2": 1900,
        "y2": 2451,
        "x3": 1900,
        "y3": 2585,
        "x4": 1659,
        "y4": 2585
      }
    ],
    "wordframe": [
      {
        "x": 270,
        "y": 468,
        "height": 122,
        "width": 382
      },
      {
        "x": 913,
        "y": 2627,
        "height": 168,
        "width": 302
      },
      {
        "x": 1497,
        "y": 496,
        "height": 204,
        "width": 410
      },
      {
        "x": 1543,
        "y": 1878,
        "height": 156,
        "width": 410
      },
      {
        "x": 1659,
        "y": 2585,
        "height": 134,
        "width": 241
      }
    ]
  }
}
```
