+++
title = "Initial Release of s3eBass - Marmalade extension for BASS audio engine"
path = "/blog/2012/11/06/initial-release-of-s3ebass-marmalade-extension-for-bass-audio-engine/"
template = "blog_post.html"

[extra]
date = "2012-11-06"
author = "YJ Park"
tags = ["marmalade", "pfgame", "code"]
+++

The audio and music are playing a very important role in games, for our future games, I want them to have good quality of audio and music, e.g. don't use short loop of mp3 music, but something much longer and more dynamic without taking much space. My first thought is to use MIDI+soundfonts or some mod-based music, so I spent some time to try to see the possibility.

There are quite some libraries to support xm playback, though I can't find any Marmalade extensions on the web, in the forum someone mentioned that they made use of FMOD in their game, though there is no code shared, and FMOD is quite expansive.

After some search, I decided to use [BASS audio engine](http://www.un4seen.com/bass.html), which is quite powerful, with well designed API, not bad documentation and sample, and a reasonable price for small projects (the shareware license can cover product with small price).

Now I've got a working extension(though the only test I did was to play a xm file on OSX, iOS and Android), think other people maybe interesting in the extension or how to create similar extensions, so I'm going to share the extension and some experiences I've learn from the process(not in this post).


Quick Note about Implementation
-------------------------------
BASS itself support many platform, the platforms I need are: OSX, iOS, Android. It's pure C, so it shouldn't be too hard to make it work with Marmalade. Though it took me quite a while to get some basic idea about the Marmalade extension system.

Most documentation from Marmalade about extensions seems focusing on writing platform specific codes in custom extension, in this case, it's actually much more easier since BASS is already platform independent, all we need is to make it work with Marmalade's build system.

Will write more about how to wrap C libraries into Marmalade extension in other posts later.

Code of the Extension
---------------------
Since basically I have no idea about how to use BASS now, I just tried to use some codes from the BASS examples, it works pretty good, the xm files sounds quite good. 
      
Think I will write some wrapper layer around the C function calls to expose audio functionalities to C++, XML and Lua codes. Guess I will have much better idea about it in a couple of months after our first game get done.

I've put the codes at [Github](https://github.com/yjpark/s3eBass), feel free to clone it, and give it a try. see the github pages for more details about it.
