+++
title = "[F# Game Tutorial] Setup Environment"
path = "/blog/2019/01/08/fsharp-game-tutorial-setup-environment/"
template = "blog_post.html"

[extra]
date = "2019-01-08"
author = "YJ Park"
tags = ["fsharp", "game", "tutorial"]
+++

In this post, I'll explain how to setup development environment for this tutorial, you should be able to build and run the demo after following the steps.

## Platform Components

### .NET Core
.NET Core is the free, cross-platform, open source .NET platform, which is supported on Linux, macOS, Windows, you need the current version (v2.2.101) to run the tutorial codes.

- Official web site: https://dotnet.microsoft.com/
- Source code: https://github.com/dotnet

Reasons to choose .NET Core:



- Good structure and tool chain, the old version of .NET (Windows, or Mono) generally need a IDE for the project file (Visual Studio, or Xamarin Studio), not very friendly to console usage. the core version use very simple and straight-forward project file format, and have really good command line tool.
- Good package ecosystem, tons of useful packages can be found at [nuget.org](https://www.nuget.org/), many 3rd party system provide good library for .NET platform.
- C# language, C# is a very good language, and it's also very popular in game development, supported in [Unity](https://unity3d.com/), [Xenko](https://xenko.com/), [Godot](https://godotengine.org/), [wave engine](https://waveengine.net/), and more.
- F# language, personally I really like F#, it gives you many powerful features as functional language, but also fully compatible with object-oriented paradigm, and can access C# libraries seamlessly. It's very happy to work with, and learning F# can help you to write better C# codes, so it's a very worthy investment with your time IMO.

### MonoGame
MonoGame is an Open Source implementation of the Microsoft XNA 4 Framework.

- Official web site: http://www.monogame.net/
- Source code: https://github.com/MonoGame/MonoGame

Reasons to choose MonoGame:

- It's a library instead of a whole development environment, so we can focus on the codes instead of art pipeline tools (e.g. scene editor).
- Cross-platform, works on Linux, macOS, Windows.
- It's very stable and been used in many games.
- It's a low level framework, in other words, it's not a complete engine, since I want to create own simple engine, this is a plus to me.

### Notes

I'm using the .NET Core version of MonoGame created by github user [cra0zy](https://github.com/cra0zy), which is not the latest version (v3.7.0.7 vs v3.7.1.189), but fully compatible with .NET Core environment, working perfectly on Linux, macOS and Windows 10 for me.

- https://www.nuget.org/packages/MonoGame.Framework.DesktopGL.Core/

MonoGame supports more platforms with Mono runtime (iOS, Android, and more), it's should be possible to make the demo code support these platform, but I will keep it simple and clean, only support Linux, macOS and Windows.

There are some game engines on top of MonoGame, you can have a look if you want to use a full feature engine in your code

- https://github.com/aloisdeniel/awesome-monogame#engines

## Development Tools

### Paket
Use NuGet directly require much manual works, also you need to update versions manually (Visual Studio has GUI support, but I would rather not use it), Paket is a dependency manager for .NET, it works quite nice, and I use it to manage packages in all my .NET projects, so I also use it in this tutorial.

- Official web site: https://fsprojects.github.io/Paket/

Paket itself is not supported on .NET Core yet, it require .NET Desktop or Mono to run at the moment, so you need to install Mono on your system to run it on Linux and macOS

- https://github.com/fsprojects/Paket/issues/2875
- https://www.mono-project.com/docs/getting-started/install/
- https://fsprojects.github.io/Paket/bootstrapper.html#Magic-mode

I've add the paket.bootstrapper.exe to repo as `.paket/paket.exe` , execute it will work as the magic mode.

Personally I create this alias to run paket at project's root folder:

- Fish & Bash: `alias paket='mono .paket/paket.exe'`
- PowerShell: `Set-Alias -Name paket -Value .paket\paket.exe`

### Fake
Fake is a DSL for build tasks and more, it's really good for managing tasks for multiple projects, I also use a nuget package I created to simplify build.fsx

- Official web site: https://fake.build/
- Dap.Build: https://github.com/yjpark/dap.build.fsharp

### Visual Studio Code
I'm a long time vim (neovim) user, so I did try to use neovim for F# development, though the result was not very nice, so I tried visual studio code later, which is surprisingly good, nowadays I use vscode for most of my .NET development.

- Official web site: https://code.visualstudio.com/
- My config: https://github.com/yjpark/dotfiles/tree/master/vscode

Reasons to use:

- Really good performance
- Actively developed, many good features came since my first use
- Very good extension for C# and F#, also many good extensions for other purposes
- Very nice vim key binding, so many of y muscle memories still works
- Cross-platform, also quite easy to config

A few issues:

- Some time the auto complete process take much CPU, might be this issue
  - might be this issue: https://github.com/fsharp/FsAutoComplete/issues/105
  - bash script to kill fsautocomplete processes: https://github.com/yjpark/dotfiles/blob/master/bin/common/kill-ionide-autocomplete
- Default setting might replace your partial input to non-relative content by auto-complete, this drives me (and others) crazy, personally I can't understand why it's the default, so you better add this line to your config if you feel the auto-complete is working against you.

```
"editor.acceptSuggestionOnCommitCharacter": false,
```

## Walk through Steps
Quite some information already, and it may not be easy if you have no much experience with .NET. I'll briefly show what need to be done in more details, feel free to skip if you know how to do these already, or you rather learn by yourself.

If you met any difficulties and need some help, please let me know, just leave a comment here or create an issue in github, it's really crucial to get the system running properly, otherwise it's very hard to catch up the following posts.

### Install .NET Core
- Download the SDK for your platform at https://dotnet.microsoft.com/download
- Install it, it should setup path for the executables properly
- Run `dotnet --version` in shell to confirm it's installed correctly

### Clone codes
- `git clone git@github.com:yjpark/FSharpGameTutorial.git`
- **Note**: also good idea to clone from your fork, and you need to know how to use git for this tutorial

### Install Paket
- Install Mono if you're not on Windows: https://www.mono-project.com/docs/getting-started/install/
- Windows: `.paket\paket.exe restore`
- Linux, macOS: `mono .paket/paket.exe restore`
- If it works fine, a bunch of packages will be downloaded into `~/.nuget/packages/`
- **Note**: full paket will be downloaded, if your network is not stable, might end up with partial download, in that case, you need to remove the partial file manually

### Install Visual Studio Code
- Won't cover details here, just follow the official site to install.
- Menu: `File -> Open Workspace...`, then open `FSharpGameTutorial.code-workspace`

### Install Fake
- Install: `dotnet tool install --global fake-cli`
- You need to add `~/.dotnet/tools/` to `PATH`
- Run `fake --version` in shell to confirm it's installed correctly
- **Note**: the fake version I'm using is v5.11.1, if you're using an much older version, may need to update.
- Update to latest version: `dotnet tool update --global fake-cli`

### Run Fake Targets
- `fake build --list` should give you a list of targets (tasks)
- `fake build -t tank.sandbox:run` can build the demo, and run it
- **Note**: target name in fake parameter is case insensitive

### That's It
- If you see the demo game on your screen, then it's all set, you can have a quick look in the code, maybe you start reading F# syntax, get ready for the next posts.
- If you got any problem, then need to do some troubleshooting, just try to identify the source of the problem, which step is not working, then probably just Google a bit first.

----
Code: https://github.com/yjpark/FSharpGameTutorial/tree/posts/setup-environment
