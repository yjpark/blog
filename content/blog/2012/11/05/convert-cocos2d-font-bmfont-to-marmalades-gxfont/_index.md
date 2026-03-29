+++
title = "Convert Cocos2D Font (BMFont) to Marmalade's GxFont"
path = "/blog/2012/11/05/convert-cocos2d-font-bmfont-to-marmalades-gxfont/"
template = "blog_post.html"

[extra]
date = "2012-11-05"
author = "YJ Park"
tags = ["marmalade", "pfgame", "code"]
+++

In 2D games, it's typical to use image based font for UI elements, which can provide better graphic result, fast rendering, and usually smaller then true type fonts (especially if you want to support languages with big character set, e.g. Chinese).

There are quite some tools to generate such font images, I'm using [bmGlyph](http://www.bmglyph.com/) as the font generator, it can publish the popular "Cocos2d / BMFont" format, though it's not directly usable in Marmalade.

Marmalade is using its own font format, and provide a font generator in the SDK, though it only support plain color, and when I feed it with some Chinese characators, they are not included in the generated files. I'm using the OS X version of the font builder, not sure about how the Windows version works.

My first thought was to add function to use the BMFont generated, though it's not an easy task, also I want to use IwGame's label components, which are based on Marmalade's GxFont and Truetype support. 

After reading [GxFont Reference](http://docs.madewithmarmalade.com/native/api_reference/iwgxfontapidocumentation/iwgxfontapioverview/iwgxfontfiles.html), turns out it's using a fairly simple format, so I decided to write a converter to create gxfont files.


Code of the Converter
---------------------
I've put the codes at [Github](https://github.com/yjpark/marmalade-tools), feel free to clone it, and try to run it. see the github pages for more details about it.

The converter support UTF-8 characters with no problem, the size of the tga files is a bit big comparing to the Cocos2d version, since more empty spaces are needed for GxFont format.

It's kind of a straight-forward implementation, and probably there are ways to make it better, especially if the bmGlyph's console support is out (in the coming feature list now), the whole process of extracting characters from data file, create Cocos2d font, convert to GxFont can be fully automatied.

Just read the code if you're interested in the implementation details. :)
