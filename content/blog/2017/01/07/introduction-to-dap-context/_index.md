+++
title = "Introduction to Dap Context"
path = "/blog/2017/01/07/introduction-to-dap-context/"
template = "blog_post.html"

[extra]
date = "2017-01-07"
author = "YJ Park"
tags = ["code", "doc"]
+++

Back in 2013, I was working on my first Unity3d game, it's a simplified RTS game for tablets, the first version took us (3 developers including me) about 2 years to hit the iOS app store, did learned quite some lessons during the process, wanted to write some blogs for a long time, though never really did.

We released the game at 2015, but the game wasn't successful commercially, and our small start-up company run out of money. I was still making games after that, planned to reuse some lib codes created along the way. Then I realised that the quality of these libs can be improved much (due to time pressure, and lack of experiences)

The most useful module was a custom data context class I wroted, it was rather simple, just an object with a bunch of properties, and event channels, both can be watched, e.g. when a property been set to a new value, all listeners will be triggered by a callback. On top of these properties and channels, I create a simple layer to interact with the data context via requests, such as `get` or `set` or `fire`, then on top of that, I create a simple text parser so diffrent section in config files can trigger different action in the system, e.g.

```
"selection" : {
    "_": [
        "sprite/destroy?key=selection",
        "sprite/do?key=selection&prefab=squads.effect_sprite#color=1,1,1,0&sprite=flash&zoom=1.0&play.flash&done.flash=destroy",
    ]
},
```



The first command will destroy the old selection sprite, the second command will create a new one (these objects are managed by a pool, so performance won't be affected), then change it's color, sprite, zoom value, then fire an event `play.flash` which is an animation created by HoTween in the prefab, then when the event `done.flash` been triggered (when the tween finished), destroy itself.

This is used in our effect system, in the code, a bunch of entry points were defined, when certain things happened, the logic will check according section in the config file, then parse these commands and run them through the request system, which operates on the data contexts eventually.

This works rather smoothly, so when non-dev members wants to tweak effects, they can just create prefabs, and writing commands to operate these prefabs, no code writing envolved, it's a small challenge for them to learn and master the syntax, though after some documents and practice, the art works and dev works were de-coupled properly.

Later the same system was used for GUI elements, in slightly different way, and also been used for charactor's properties storage, though quite some boilerplate codes was written to make things work, the parsing logic became quite messy after adding more features, such as delayed execution, relative value changes...

What's Dap
----------

So I was working on the second version of my library codes, C# version, mainly used in Unity3d, though much of the codes are not limited to Unity3d, and can been used with DotNet, Mono, and Xamarin as well.

`Dap` stands for `Distributed Application Platform`, the plan is to create conventions, api, and libraries for distributed applications, in my mind, it means:

- Multiple platform support
- Multiple devices at the same time
- Real-time communication and colabration from these devices

This is rather big scope, when I started thinking about this, was mainly focus on application dev, though much of the ideas are suitable for game dev as well, especially for network games. 

What's Dap Context, Aspect
--------------------------

Dap is following ECS (Entity Component System), has following core concepts:

- Context, it's the entity in Dap, a little like Unity's GameObject, though you can create subclass of Contexts.
- Aspect, it's the component in Dap, everything related to a Context most likely are aspects
- The system in Dap can be done by either subclass from context, or with manners (special Aspects designed for sharing logic in defferent type of Entities)
- Env, it's the runtime environment of the Dap system, there is only one env instance in the system, which is holding all the contexts

Aspects are grouped to certain different categories in Context, these are the basic ones for all Contexts (you can also add new categories to subclasses as well):

### Properties

Holding values, which can be watched, when the valued been changed, all listeners will be notified. The value can be serialized, so can be saved to files or transfered over network.

You can also provide checkers on the value, so can implement validation or authentication to the underlining values.

### Channels

Channels are used to fire events, which can be watched as well, each event can have a data with it.

Note: here the data is a simple serialization format, support basic types.

### Handlers

Handlers are used for request handling, requests can be sent to handlers, they will check the request data, do according operation, and then return a result.

### Bus

Bus is for more loose notification, e.g. since you can only listen to a channel when it's already created, there is a timing issue to listen to future channels. Bus is just a simple message, with no data with it. You can also check whether a certain message have been sent as well.

### Vars

Wrapping for internal values or runtime values (not able to be serialized)

### Manners

Behaviors that can be added to multiple kind of contexts, e.g. Tickable is implemented as a Manner, means will listen to system's tick channel, create a own tick channel, and fire a tick event accordingly.

Also network logic are created as Manner, so they can be added to existing classes, so by following some simple rules (mostly naming conventions), a single player game can be turned into a network one by adding proper manners at client and server sides, the code changes should be rather small.

Where's the Code
----------------

The core lib is available at github, there is no documents at the moment, and extra libraries (not open sourced yet) are needed to use it properly in real project, but the source codes can be used for understanding the concepts, so if you are interested, feel free to clone or fork:

- https://github.com/angeldnd/dap.core.csharp
