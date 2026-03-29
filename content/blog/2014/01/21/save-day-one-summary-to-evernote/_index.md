+++
title = "Save Day One Summary to Evernote"
path = "/blog/2014/01/21/save-day-one-summary-to-evernote/"
template = "blog_post.html"

[extra]
date = "2014-01-21"
author = "YJ Park"
tags = ["code", "tool"]
+++

Why Not Just Use Evernote?
--------------------------
I've been using Evernote for several years, which is great, the best features to me are:

- Multi devices synchronization
- High quality app on iOS/Android and OSX
- Very good search in notes (even in the photos)

Though lately I found myself write less an less in Evernote, if I'm writing something long, then usually I will use MacVim, may copy the text back to Evernote. If I need to write a couple of line, the process to write in Evernote is like this:

- Switch to Evernote
- Find the note for current day (each day I will have a new note.)
- Go to the end of the note
- Write something
- Switch back

Feels a bit heavy, also there is no information about when I did add the line into the note.



Day One
-------
Since 2013 I started to use [Day One](http://dayoneapp.com/), which is a very beautiful application(has OSX and iOS versions) for note taking. Here is the reasons that I like it:

- Quick note adding widget in menubar, which can be triggered by a global shortcut
- Markdown format, rendered very nicely as well.
- Dropbox synchronization, iCloud supported as well.
- Every note has a timestamp.
- Calendar view for all the notes.
- Look and feels very nice.

Then the process to add a quick note will be:

- Using the global shortcut.
- Type, then Cmd-Enter to save it.

It's much more light-weigh comparing to the Evernote way.

Why Not Just Use Day One?
-------------------------
One major missed part in ```Day One``` is the lack of Android support, also the search is not as good as evernote, another problem is that you can not see all the notes in one day at once, you have to mouse over each item to see the whole content, which is a bit annoying IMO.

Dayone 2 Evernote
-----------------
So I wrote a very simple script to export ```Day One``` entries as a summary note in Evernote.

Timestamps will be added in front of each entry.

The summary note will look like:
```
[00:25]
One note written in Day One

[19:17]
Another note in Day One

...
```
They will not be converted to HTML format, since I prefer to keep the plain text format in Evernote, and MarkDown notes looks very nice as plain text to me.

Note that since I used the applescript to save the note, it only works on OSX. Also there is some tricks to keep track of the last saved date. Check the README in the repository for more informations.

The code is: https://github.com/yjpark/dayone2evernote
