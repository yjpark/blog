+++
title = "Movable Write Open Sourced"
path = "/blog/2012/04/22/movable-write-open-sourced/"
template = "blog_post.html"

[extra]
date = "2012-04-22"
author = "YJ Park"
tags = ["pettyfun", "ios", "movablewrite", "code"]
+++

What is Movable Write
---------------------

Back in 2010, I already had some experiences on iOS development. Did wrote some very simple application to fetch information over HTTP-RPC to a trac instance, and wrote a very simple game with Cocos2D and Box2D. Did spend some time to catch up with the versions or iOS updates and read about the new APIs.

But my feeling was that by only spend small amount of time like it, I can never learn enough to have real experience on it, and I've been working on Web development for a few years. So I decided to work part-time in the company, and use the other half time to develop a real application, by real I mean with proper quality and released at app-store.

I just got a iPad1 as development device, and tried a few apps, I liked note plus a lot, it's very powerful, but a bit too powerful for my need, I want to write words most of the time, and I want to write largely, but view the written lines small.

So I decided to write a note taking app for myself, after 3 months, Movable Write was released at app store. 

 * [App store link](http://itunes.apple.com/us/app/movable-write/id416413981?mt=8)
 * [A nice introduction from wolfewithane.com](http://wolfewithane.com/blog/2011/6/22/review-hand-notes-over-to-movable-write.html)
 * [Another nice introduction from iapp.com.tw (in Chinese)](http://iapp.com.tw/ex/topic_inside.php?id=2447)



What is missed
--------------

I did implement support for USB transfer for backup/restore, though didn't write document about this feature, the plan was to implement synchronization for it, Dropbox and/or iCloud, though didn't get time for it.

Another interesting possibility is Evernote integration, the code should be very easy to be runnable on OSX, also can be added as image or pdf.

A bigger change is adding bigger element into page, e.g. a photo then wrap the lines around it. I've done some experiments about bigger writing area, it's not easy to put it into the current structure though.

Another bigger one is OCR for the written words, there are open-source libraries, though not sure how mature they are, all the original writing information are saved in file, it might be easy to add this feature.

A small one is to replay the writing process of the note, since all the timing infomation was saved too, this is not hard to implement.

...

Why open sourced
----------------

It's sadly that I can't put more dedicated time into it, since it didn't bring much money as a product for a small group of people, though I get quite some very good comments from some users.

I feel very happy that some people found it useful and use it frequently, so in case any of them are programmer, I decided to put all the source codes at github, please fork it if you're interesting.

 * [Movable Write at Github](https://github.com/pettyfun/MovableWrite)

Might write more about the technical side of the project later, what I've learned, and how to extend it.
