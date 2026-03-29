+++
title = "Build DotNet Projects with Fake"
path = "/blog/2018/11/27/build-dotnet-projects-with-fake/"
template = "blog_post.html"

[extra]
date = "2018-11-27"
author = "YJ Park"
tags = ["code", "fsharp", "fake"]
+++

I've been doing quite some F# coding lately, which is really nice, plan to write more about F# later, here I'm gonna talk about how to build DotNet projects with Fake.



I've put common logic as libraries, then can share them easily across multiple projects, so I need to create NuGet packages. I've already created more than a dozen individual libraries, it's clear that I need an automated process to manage them, or it's very tedious to keep proper version of libraries in each project.



I've did some small work around Fake to make such process, which works quite nicely for me, I plan to write two articles on this, this one will explain the basic structure, and how I use it to manage multiple projects easily, the next one will talk about how to create NuGet package, and how to use a hacky way to do local development easily.





What's Fake and Why Need It.
-----------------------------------



Here is the slogan form Fake's official site: https://fake.build/



`F# MAKE 5 - A DSL FOR BUILD TASKS AND MORE THE POWER OF F# - ANYWHERE - ANYTIME`



It's a `make` like system, but instead of a special purpose DSL, it's standard F#, with addition of modules and syntax to make common tasks easily. You can define dependencies of targets (a task in Fake's terminology) very easily with it's `==>` operator.



Since it's standard F#, you can have type check for the make script, and quite nice IDE support in VS Code (haven't tried other IDEs yet). Here is the code snippet from tutorial



{{< highlight fsharp >}}
// Targets
Target.create "Clean" (fun _ ->
  Shell.cleanDir buildDir
)

Target.create "BuildApp" (fun _ ->
  !! "src/app/**/*.csproj"
    |> MSBuild.runRelease id buildDir "Build"
    |> Trace.logItems "AppBuild-Output: "
)

Target.create "Default" (fun _ ->
  Trace.trace "Hello World from FAKE"
)

open Fake.Core.TargetOperators

"Clean"
  ==> "BuildApp"
  ==> "Default"

// start build
Target.runOrDefault "Default"
{{< /highlight >}}



Nice and clean, isn't it?



Though in practice, this kind of simple approach not working for me.

- First of all, don't really like the build targets as string here, which is error prune, and won't benefit from compiler for checks, a union type will be better, though won't fit to fake's API easily, the best approach to me is that no need to define these standard targets manually, should be able to generate them by convention. 
- Secondly, since building several projects can take time, I would like to be able to just operate on specific project if I want to, I can `cd` to certain folder and run `dotnet` commands there in a shell, though it's a bit tedious to switch current folder back and forth all the time. 
- Also, most projects are having similar tasks, but with the out-of-box fake, still need to write some boilerplate codes for each project, which is quite tedious.



## Introducing Dap.Build



So after some time tinkering around it, I've create a simple package for this, which is on GitHub and NuGet:

- https://github.com/yjpark/dap.build.fsharp

- https://www.nuget.org/packages/dap.build



The following example is used in a library project (not open sourced yet, pushed to private nuget ATM), which includes 13 libraries, with just 30 lines of codes, all of them have individual tasks to clean/restore/build/pack/push... and aggragated tasks to build all, restore all ... and all the targets are with properly dependencies. 

{{< highlight fsharp >}}
#r "paket: groupref Build //"
#load ".fake/build.fsx/intellisense.fsx"

open Fake.Core
open Fake.IO.Globbing.Operators

module NuGet = Dap.Build.NuGet

let feed =
    NuGet.Feed.Create (
        server = NuGet.ProGet "https://nuget.yjpark.org/nuget/dap",
        apiKey = NuGet.Environment "API_KEY_nuget_yjpark_org"
    )

let projects =
    !! "lib/Dap.FlatBuffers/*.csproj"
    ++ "src/Fable.Dap.Prelude/*.fsproj"
    ++ "src/Dap.Prelude/*.fsproj"
    ++ "src/Fable.Dap.Context/*.fsproj"
    ++ "src/Dap.Context/*.fsproj"
    ++ "src/Fable.Dap.Platform/*.fsproj"
    ++ "src/Dap.Platform/*.fsproj"
    ++ "src/Fable.Dap.WebSocket/*.fsproj"
    ++ "src/Dap.WebSocket/*.fsproj"
    ++ "src/Fable.Dap.Remote/*.fsproj"
    ++ "src/Dap.Remote/*.fsproj"
    ++ "src/Fable.Dap.Dsl/*.fsproj"
    ++ "src/Dap.Archive/*.fsproj"

NuGet.createAndRun NuGet.release feed project
{{< /highlight >}}



This example use `paket` to manage packages, need the following snippet in `paket.dependencies`

```paket
group Build
    source https://www.nuget.org/api/v2
    storage: none
    framework: netstandard2.0

    nuget Dap.Build
```



Full list of targets are:

```text
The following targets are available:
   Build - Build 13 Projects
   Clean - Clean 13 Projects
   Dap.Archive:Build - Build Dap.Archive
   Dap.Archive:Clean - Clean Dap.Archive
   Dap.Archive:Fetch - Fetch Dap.Archive
   Dap.Archive:Inject - Inject Dap.Archive
   Dap.Archive:Pack - Pack Dap.Archive
   Dap.Archive:Push - Push Dap.Archive
   Dap.Archive:Recover - Recover Dap.Archive
   Dap.Archive:Restore - Restore Dap.Archive
   Dap.Context:Build - Build Dap.Context
   Dap.Context:Clean - Clean Dap.Context
   Dap.Context:Fetch - Fetch Dap.Context
   Dap.Context:Inject - Inject Dap.Context
   Dap.Context:Pack - Pack Dap.Context
   Dap.Context:Push - Push Dap.Context
   Dap.Context:Recover - Recover Dap.Context
   Dap.Context:Restore - Restore Dap.Context
   Dap.FlatBuffers:Build - Build Dap.FlatBuffers
   Dap.FlatBuffers:Clean - Clean Dap.FlatBuffers
   Dap.FlatBuffers:Fetch - Fetch Dap.FlatBuffers
   Dap.FlatBuffers:Inject - Inject Dap.FlatBuffers
   Dap.FlatBuffers:Pack - Pack Dap.FlatBuffers
   Dap.FlatBuffers:Push - Push Dap.FlatBuffers
   Dap.FlatBuffers:Recover - Recover Dap.FlatBuffers
   Dap.FlatBuffers:Restore - Restore Dap.FlatBuffers
   Dap.Platform:Build - Build Dap.Platform
   Dap.Platform:Clean - Clean Dap.Platform
   Dap.Platform:Fetch - Fetch Dap.Platform
   Dap.Platform:Inject - Inject Dap.Platform
   Dap.Platform:Pack - Pack Dap.Platform
   Dap.Platform:Push - Push Dap.Platform
   Dap.Platform:Recover - Recover Dap.Platform
   Dap.Platform:Restore - Restore Dap.Platform
   Dap.Prelude:Build - Build Dap.Prelude
   Dap.Prelude:Clean - Clean Dap.Prelude
   Dap.Prelude:Fetch - Fetch Dap.Prelude
   Dap.Prelude:Inject - Inject Dap.Prelude
   Dap.Prelude:Pack - Pack Dap.Prelude
   Dap.Prelude:Push - Push Dap.Prelude
   Dap.Prelude:Recover - Recover Dap.Prelude
   Dap.Prelude:Restore - Restore Dap.Prelude
   Dap.Remote:Build - Build Dap.Remote
   Dap.Remote:Clean - Clean Dap.Remote
   Dap.Remote:Fetch - Fetch Dap.Remote
   Dap.Remote:Inject - Inject Dap.Remote
   Dap.Remote:Pack - Pack Dap.Remote
   Dap.Remote:Push - Push Dap.Remote
   Dap.Remote:Recover - Recover Dap.Remote
   Dap.Remote:Restore - Restore Dap.Remote
   Dap.WebSocket:Build - Build Dap.WebSocket
   Dap.WebSocket:Clean - Clean Dap.WebSocket
   Dap.WebSocket:Fetch - Fetch Dap.WebSocket
   Dap.WebSocket:Inject - Inject Dap.WebSocket
   Dap.WebSocket:Pack - Pack Dap.WebSocket
   Dap.WebSocket:Push - Push Dap.WebSocket
   Dap.WebSocket:Recover - Recover Dap.WebSocket
   Dap.WebSocket:Restore - Restore Dap.WebSocket
   Fable.Dap.Context:Build - Build Fable.Dap.Context
   Fable.Dap.Context:Clean - Clean Fable.Dap.Context
   Fable.Dap.Context:Fetch - Fetch Fable.Dap.Context
   Fable.Dap.Context:Inject - Inject Fable.Dap.Context
   Fable.Dap.Context:Pack - Pack Fable.Dap.Context
   Fable.Dap.Context:Push - Push Fable.Dap.Context
   Fable.Dap.Context:Recover - Recover Fable.Dap.Context
   Fable.Dap.Context:Restore - Restore Fable.Dap.Context
   Fable.Dap.Dsl:Build - Build Fable.Dap.Dsl
   Fable.Dap.Dsl:Clean - Clean Fable.Dap.Dsl
   Fable.Dap.Dsl:Fetch - Fetch Fable.Dap.Dsl
   Fable.Dap.Dsl:Inject - Inject Fable.Dap.Dsl
   Fable.Dap.Dsl:Pack - Pack Fable.Dap.Dsl
   Fable.Dap.Dsl:Push - Push Fable.Dap.Dsl
   Fable.Dap.Dsl:Recover - Recover Fable.Dap.Dsl
   Fable.Dap.Dsl:Restore - Restore Fable.Dap.Dsl
   Fable.Dap.Platform:Build - Build Fable.Dap.Platform
   Fable.Dap.Platform:Clean - Clean Fable.Dap.Platform
   Fable.Dap.Platform:Fetch - Fetch Fable.Dap.Platform
   Fable.Dap.Platform:Inject - Inject Fable.Dap.Platform
   Fable.Dap.Platform:Pack - Pack Fable.Dap.Platform
   Fable.Dap.Platform:Push - Push Fable.Dap.Platform
   Fable.Dap.Platform:Recover - Recover Fable.Dap.Platform
   Fable.Dap.Platform:Restore - Restore Fable.Dap.Platform
   Fable.Dap.Prelude:Build - Build Fable.Dap.Prelude
   Fable.Dap.Prelude:Clean - Clean Fable.Dap.Prelude
   Fable.Dap.Prelude:Fetch - Fetch Fable.Dap.Prelude
   Fable.Dap.Prelude:Inject - Inject Fable.Dap.Prelude
   Fable.Dap.Prelude:Pack - Pack Fable.Dap.Prelude
   Fable.Dap.Prelude:Push - Push Fable.Dap.Prelude
   Fable.Dap.Prelude:Recover - Recover Fable.Dap.Prelude
   Fable.Dap.Prelude:Restore - Restore Fable.Dap.Prelude
   Fable.Dap.Remote:Build - Build Fable.Dap.Remote
   Fable.Dap.Remote:Clean - Clean Fable.Dap.Remote
   Fable.Dap.Remote:Fetch - Fetch Fable.Dap.Remote
   Fable.Dap.Remote:Inject - Inject Fable.Dap.Remote
   Fable.Dap.Remote:Pack - Pack Fable.Dap.Remote
   Fable.Dap.Remote:Push - Push Fable.Dap.Remote
   Fable.Dap.Remote:Recover - Recover Fable.Dap.Remote
   Fable.Dap.Remote:Restore - Restore Fable.Dap.Remote
   Fable.Dap.WebSocket:Build - Build Fable.Dap.WebSocket
   Fable.Dap.WebSocket:Clean - Clean Fable.Dap.WebSocket
   Fable.Dap.WebSocket:Fetch - Fetch Fable.Dap.WebSocket
   Fable.Dap.WebSocket:Inject - Inject Fable.Dap.WebSocket
   Fable.Dap.WebSocket:Pack - Pack Fable.Dap.WebSocket
   Fable.Dap.WebSocket:Push - Push Fable.Dap.WebSocket
   Fable.Dap.WebSocket:Recover - Recover Fable.Dap.WebSocket
   Fable.Dap.WebSocket:Restore - Restore Fable.Dap.WebSocket
   Fetch - Fetch 13 Projects
   Inject - Inject 13 Projects
   Pack - Pack 13 Projects
   Push - Push 13 Projects
   Recover - Recover 13 Projects
   Restore - Restore 13 Projects
```



I am really happy with it, can do most operation easily. The nuget related feature is very nice, I didn't find much information about how other developers work with nugets, what commands to pack and push them, currently Dap.Build support both nuget.org and ProGit, will have another post on this part later.



The missing part is auto complete for targets, though since I'm using fish, it's command history can replace auto completion mostly, so this is not an urgent feature to me.
