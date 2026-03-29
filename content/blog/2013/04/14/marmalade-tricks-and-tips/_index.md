+++
title = "Marmalade Tricks and Tips"
path = "/blog/2013/04/14/marmalade-tricks-and-tips/"
template = "blog_post.html"

[extra]
date = "2013-04-14"
author = "YJ Park"
tags = "marmalade"
+++

During the days to develop our first game: [Day Day Birds](https://itunes.apple.com/us/app/day-day-birds/id608802879?mt=8&uo=4), I went through the progress of learning to use Marmalade, generally it's very easy to use, and save me lot of time, though there are some little things that I hoped that I know earlier.

Stack Size
----------
The game started to crash randomly before I noticed, it's quite hard to debug, especially without the tools in Xcode or other IDEs provide. And it never crash in the simulator, so the debugging is quite awkward, a lot of guess, build, test-run going on.

When it crashed on iOS device, some information were provided, though full stack trace is not availabe, and the place of crash is not consistent. After 2 or 3 days and nights figihting with this bug, finally found out the root cause, which is very surprising.



It's caused by stack overflow, since Marmalade is designed to support many different mobile devices, many of them are with limited hardware, the stack size is 32k by default, since I'm having a LUA layer, and also allocated some string buffer in stack for convinience, it got overflowed, so caused the random crash.

There is actually a [forum thread](http://www.madewithmarmalade.com/devnet/forum/advice-anyone-experiencing-heap-corruption-3) mentioned this.

Since I only plan to support the modern devices (iPhone, iPad, maybe Android as well), gave it a much bigger setting fix the crash perfectly.

```
   [s3e]
   SysStackSize=4000000
```

Accelerate framework
--------------------
I'm using libBass for the audio playpack, for some reason it require Accelarate frame under iOS to compile. so I add `iphone-link-opts="-weak_framework Accelerate"` into the mkf file.

For unknown reason, the Accelerate.framework stub in `/Developer/Marmalade/6.2/s3e/deploy/plugins/iphone/sys_libs/System/Library/Frameworks/Accelerate.frameworks/Accelerate` is not working, might be the nested frameworks inside it. 

Not really understand how the stub frameworks work in Marmalade, seems a smart way to use the system's SDK libraries, though a hacky solution make it compiled.

Current fix is to copy the framework from `/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS6.1.sdk/System/Library/Frameworks/Accelerate.framework`. Not sure whether there is side effects.

```
cp -r /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS6.1.sdk/System/Library/Frameworks/Accelerate.framework/* /Developer/Marmalade/6.2/s3e/deploy/plugins/iphone/sys_libs/System/Library/Frameworks/Accelerate.framework/
```

iOS device crash report
-----------------------

This page explains how to read the crash report nicely, also don't forget to save the mapping file of the version you submitted to app store, otherwise you will have no idea to debug when get crash logs from Apple.

[How to map iPhone crash log addressed to your code](https://marmalade.zendesk.com/entries/22126117-how-to-map-iphone-crash-log-addresses-to-your-code)

Some mkb settings
-----------------
```
deployments
{
    name="Slingshot"
    version=1.0

    ["Default"]
    iphone-provisioning-profile="data/provisions/DayDayBirdsDev.mobileprovision"
    iphone-enable-4inch-retina=1
    iphone-no-splash=1
    iphone-prerendered-icon=1
    iphone-icon="data/icon/Icon.png"
    iphone-icon-high-res="data/icon/Icon@2x.png"
    iphone-icon-ipad="data/icon/Icon-72.png"
    iphone-icon-ipad-high-res="data/icon/Icon-72@2x.png"
    iphone-icon-ipad-search="data/icon/Icon-Small-50.png"
    iphone-icon-ipad-search-high-res="data/icon/Icon-Small-50@2x.png"
    iphone-icon-settings="data/icon/Icon-Small.png"
    iphone-icon-settings-high-res="data/icon/Icon-Small@2x.png"
    
    #Android
    android-icon="data/android/icon/icon_48.png"
    android-icon-gallery="data/android/icon/icon_170.png"
    android-icon-hdpi="data/android/icon/icon_72.png"
    android-icon-ldpi="data/android/icon/icon_36.png"
    android-icon-mdpi="data/android/icon/icon_48.png"
}
```
`iphone-enable-4inch-retina=1` enabled the iPhone 5 wide screen mode.

Some app.icf settings
---------------------
```
DispFixRot="Landscape"
IOSDispScaleFactor=200

{ID=IPHONE "iPad1,1"}
[s3e]
memSize = 30000000
SysStackSize=1000000
{ID=IPHONE "iPad2,1","iPad2,2","iPad2,3","iPad2,4","iPad2,5","iPad2,6","iPad2,7"}
[s3e]
memSize = 64000000
{ID=IPHONE "iPod1,1","iPod2,1","iPod3,1","iPod4,1","iPhone1,1","iPhone1,2","iPhone2,1"}
[s3e]
memSize = 34000000
SysStackSize=1000000
{ID=IPHONE "iPod5,1","iPhone3,1","iPhone3,2","iPhone4,1","iPhone4,2"}
[s3e]
memSize = 64000000
{OS=ANDROID}
[s3e]
memSize = 80000000
{OS=OSX}
[s3e]
memSize = 256000000
{}
```

`DispFixRot="Landscape"` is to lock the screen rotation to be landscape only, I've met quite some problem with landscape, probably will write another post about it.

`IOSDispScaleFactor=200` is used to activate the retina screen support, so the resolution of retina iPad will be 2048 x 1536, 

It took me quite some efforts to learn how to do the device-specific settings in app.icf, the syntax is quite complex, the marmalade documents actually cover this, though lacking good samples.
