+++
title = "SILP: Simple Individual Line Preprocessor"
path = "/blog/2014/04/12/silp-simple-individual-line-preprocessor/"
template = "blog_post.html"

[extra]
date = "2014-04-12"
author = "YJ Park"
tags = ["code", "tool", "silp"]
+++

Why bother with a preprocessor?
-------------------------------

I was quite busy working on our [RTS game on iPad](http://emberconflict.com/) for almost a year, we are quite close to our first public version now. It's developed with Unity3d, using uLink as the network library. Created a quite nice data context system on Unity3d, so non-developers can update pure visual part of the system without developers' help, will write some entries on it later when got time.

SILP is a very small side project come from the process working on it. It's a simple language-agnostic preprocessor. 

There are many discussions about whether a programming language should include preprocessor, most people seems agree that preprocessor is too error-prune and sacrifice readability too badly, and there should be seldom cases that an alternative can't be find to replace the preprocessor usage.

I agree that in most cases we don't need preprocessor though there are several cases that I would like to have a preprocessor in my tool set for cleaner codes or can remove some trivial typing. Here are 2 examples: 



### Common Import Statements ###

In each project, most likely there will be some very common import statements that every source file want to include, e.g. logging and other utilities. In dynamic languages such as Python, it's not hard to inject them into the global namespace in some bootstrap functions, though in Java or Go it's not quite possible, each file has to have these lines.

Since Go support and recommend import from a git url, this is a bit more annoying. Here is a quick example.

```go
import "github.com/golang/glog"
```

It's both longer to type, and harder to change in the future, what if we need to change something in the source codes of the library? We can fork the source repository, and working on it, though we have to go over every source file and change the url of the import. It's not too hard with some tools like sed, though it's a bit ugly and fragile to me since we have to replace in text level.

Of course with just one import, it's not a big problem, though in practice, it's very easy to have several imports for every file, and quite some other imports grouped by file types (e.g. services that need db library, services that provide RPC calls...)

### Duplicate Codes ###

Some time, it's not very easy to use usual way to remove duplicated codes, here is an example in Unity3d, it's a piece of our codes to check whether a user is already online in the system.

```csharp
private IEnumerator SaveArmyAsync(LobbyClient client, ArmyInfo armyInfo) {
    float startTime = Monitor.AddStartedEvent(LobbyMonitor.ARMY_SAVE_ARMY);

    string error = LobbyNetError.ACCOUNT_ONLINE_WITH_OTHER_DEVICE;
    IEnumerator checkOnline = client.CheckOnlinePlayer(_OnlinePlayerInfoBucket, () => {
        error = null;
    });
    while (checkOnline.MoveNext()) yield return checkOnline.Current;

    if (error != null) {
        LobbyRPCUtils.SendNak(this, client, LobbyMonitor.ARMY_SAVE_ARMY, "RPC_SaveArmyFailed", error);
        yield break;
    }
```

The logic here may not be very clear without full context, basically what it did is to create a event and send to our [istatd server](https://github.com/imvu-open/istatd), save the time into `startTime`, calling `client.CheckOnlinePlayer()` to check whether the user is logged in the system from other device, and calling `LobbyRPCUtils.SendNak()` to send a RPC call to the client if the user is already online.

The same structure is almost identical for all our server side RPC functions, only difference are the event id and RPC name, in this case `LobbyMonitor.ACCOUNT_LOGIN` and `RPC_OnLoginFailed`. As you can see, common functions are created to do most logic. But it's not very easy to make the whole pattern into a shorter format, because we have to follow the coroutine style here.

For example, line 3 ~ 7 are running `client.CheckOnlinePlayer()` in the coroutine way, and line 9 ~ 12 are handling the error case. We can't yield break in `client.CheckOnlinePlayer()` since it will only break it's own coroutine, instead of the outer one here.

Passing callback function into `client.CheckOnlinePlayer()` can solve the error handling, though still need the first trick, and the code will be less readable comparing with this way (using the callback style in many other places though). 

If we are using a language supporting preprocessor, then we can easily create a macro here to do the duplicated works, though not possible in C#, until I created the SILP project, Our only option was just copy-paste.

So What is SILP?
----------------

After we have more RPC calls in the system sharing the similar code structure shown in last example, I decided to do something to improve it. Solve it in the language scope seems not a good option to me (only possible approach I figured possible was to wrap coroutine somehow and use some customized data structure to provide cleaner interface, both heavy and unnecessary), and I was thinking about finding a language-agnostic preprocessor for a while, so I spent some time to look for a existing project that I can use.

After a quick research, was a bit disappointed with the result, most of the preprocessors either are heavily limited to one language or provide way too much power than I need (so it's harder to learn and use). It's very clear that all I need is just a simple text substitution tools, so I created SILP and spend a whole day on it, the result is quite satisfying. 

### How Simple SILP Is? ###

There is zero logic in the syntax, currently all supported feature is parameter substitution in the template, and unless super useful, no complex feature will be added in the future.

SILP only handle individual line as well. All generated lines will be put back to the original file after the line with SILP syntax.

### When Should Use SILP? ###

- Standard code block that's hard to be eliminated by regular technique.
- Some small piece of logic that you don't want to wrap in a function and the language doesn't support inline functions.

### When Should NOT Use SILP? ###

- If you can remove duplicated code in language supported way.
- The logic is not standard, and using SILP make them harder to read.

Full Example With SILP
----------------------
After implementing SILP, here is how I can remove the duplicated codes in the previous online player checking logic, here is the `silp_cs.md` file:

```markdown
# LOBBY_SERVER_RPC_CHECK_ONLINE_PLAYER(eventId, nakRPC) #
```C#
float startTime = Monitor.AddStartedEvent(${eventId});

string error = LobbyNetError.ACCOUNT_ONLINE_WITH_OTHER_DEVICE;
IEnumerator checkOnline = client.CheckOnlinePlayer(_OnlinePlayerInfoBucket, () => {
    error = null;
});
while (checkOnline.MoveNext()) yield return checkOnline.Current;
if (error != null) {
    LobbyRPCUtils.SendNak(this, client, ${eventId}, ${nakRPC}, error);
    yield break;
}
```

The format is actually a valid [github flavored markdown](https://help.github.com/articles/github-flavored-markdown), only supported syntax is the h1 title (has to be like `# macro(param1, param2) #`), and code block.

Here is the rendered image with the above example by [Marked](http://markedapp.com/), looks nice isn't it? (note that you need to toggle the `convert fenced code block` option)

![View By Marked](/img/silp/silp_example_marked.png)

Now all the RPC calls will be like this:

```csharp
private IEnumerator SaveArmyAsync(LobbyClient client, ArmyInfo armyInfo) {
    //SILP: LOBBY_SERVER_RPC_CHECK_ONLINE_PLAYER(LobbyMonitor.ARMY_SAVE_ARMY, "RPC_SaveArmyFailed")
    float startTime = Monitor.AddStartedEvent(LobbyMonitor.ARMY_SAVE_ARMY);                            //__SILP__
                                                                                                       //__SILP__
    string error = LobbyNetError.ACCOUNT_ONLINE_WITH_OTHER_DEVICE;                                     //__SILP__
    IEnumerator checkOnline = client.CheckOnlinePlayer(_OnlinePlayerInfoBucket, () => {                //__SILP__
        error = null;                                                                                  //__SILP__
    });                                                                                                //__SILP__
    while (checkOnline.MoveNext()) yield return checkOnline.Current;                                   //__SILP__
    if (error != null) {                                                                               //__SILP__
        LobbyRPCUtils.SendNak(this, client, LobbyMonitor.ARMY_SAVE_ARMY, "RPC_SaveArmyFailed", error); //__SILP__
        yield break;                                                                                   //__SILP__
    }                                                                                                  //__SILP__
```

All lines end with `//__SILP__` are generated automatically, and can be regenerated with SILP, so if you want to adjust the logic in the future, should be very easy to do, and create a new RPC call is trivial as well, only need to write one line, and run SILP again (current manually, though it should be easy to make it automatically)

What's Next
-----------

Here is the repository: https://github.com/yjpark/silp

It's also available through PyPi, you can install with 

```
pip install silp
```

Will first finish the documentation for what's working now, maybe adding more languages to default setting (mainly just how to add the special comments).

Maybe put the language configuration into the `silp_xx.md` file as well, though it might be more complicate to use and error-prone, so not sure about how to do this yet.

There are some interesting possibilities with editors here, e.g. set up code folding for SILP line and the generated line.
