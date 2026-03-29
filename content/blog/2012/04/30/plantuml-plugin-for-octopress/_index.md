+++
title = "PlantUML Plugin for Octopress"
path = "/blog/2012/04/30/plantuml-plugin-for-octopress/"
template = "blog_post.html"

[extra]
date = "2012-04-30"
author = "YJ Park"
tags = ["tool", "code"]
+++

What is PlantUML?
-----------------
[PlantUML](http://plantuml.sourceforge.net/) is a component that allows to quickly write:

 * sequence diagram,
 * use case diagram,
 * class diagram,
 * activity diagram,
 * component diagram,
 * state diagram
 * object diagram

I really like the idea of writing UML diagram with plain text. Since it's totally plaintext, it's very easy to do diff and version track, also you don't need to do anything about the layout (the text itself looks pretty good too).

Also the syntax of it is very well designed, and the generated diagrams looks really nice, so I use PlantUML for technical documentation with trac and sphinx.

The Plugin
----------
After switching [Octopress](http://octopress.org/) to my blog platform, I was looking for a way to integrate PlantUML within it, though I can't find one, so I wrote this very simple jekyll plugin (Octopress is based on [Jekyll](http://jekyllrb.com/)).

[jekyll-plantuml](https://github.com/yjpark/jekyll-plantuml)



Configuration
-------------
You need to download the plantuml.jar file from [http://plantuml.sourceforge.net/download.html](http://plantuml.sourceforge.net/download.html)

In your \_config.xml, setup plantuml\_jar to the downloaded jar file, e.g.

```
plantuml_jar: ../_lib/plantuml.jar
plantuml_background_color: "#f8f8f8"
```

The plantuml_background_color is optional, which will change the background of the generated diagram.

Usage
-----
Just wrap the diagram text in "plantuml" block, e.g.

```
{% plantuml %}
Alice -> Bob: Authentication Request
Bob --> Alice: Authentication Response

Alice -> Bob: Another authentication Request
Alice <-- Bob: another authentication Response
{% endplantuml %}
```

An Example
----------

![](/img/plantuml/plantuml-example.png)

<!--
{% plantuml %}
   actor Tester as QA
   participant "Issue Tracking\nSystem" as CQ
   actor Developer as RD
   participant "Configuration" as P4C
   participant "Component\nTopic Branch" as P4CTB
   participant "Customer\nRelease Branch" as P4CRB
   actor "Release Engineer" as BM

   QA   ->      CQ:     Critical bug\n reported
   group Fix
      RD   <--     CQ:     Assigned
      RD   ->      P4C:    Create bugfix\n configuration
      RD   ->      P4CTB:  Create topic branch (by tools)
      RD   ->      P4CTB:  Working on the bugfix
      RD   ->      CQ:     Resolve
   end group
   group Virification
      QA   <--     CQ:     Verify
      QA   <-      P4C:    Get target to verify
      QA   ->      CQ:     Confirm
   end group
   group Release
      BM   <--     CQ:     Release request received
      loop Multiple customers
         BM   ->      P4CRB:  Update customer\n branches
         P4CTB ->     P4CRB:  Auto integrate\n (by tools)
      end loop
   end group
{% endplantuml %}
-->
