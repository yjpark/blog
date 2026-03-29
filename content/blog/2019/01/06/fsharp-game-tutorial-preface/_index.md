+++
title = "[F# Game Tutorial] Preface"
path = "/blog/2019/01/06/fsharp-game-tutorial-preface/"
template = "blog_post.html"

[extra]
date = "2019-01-06"
author = "YJ Park"
tags = ["fsharp", "game", "tutorial"]
+++

Before start writing individual posts, I'd like to talk about some general ideas about this tutorial.

## Target Audience (Who)
- Familiar with at least one programming language, and don't mind to try a new one (if you don't know F# before).
- Interested in game development, want to create some simple games for fun.
- Have some time to spare, to really learn something like writing a game from scratch, plan to spend a lot time on it, it's really fun to me, but also quite hard at first.

##  Planned Contents (What)
- I will write serious of posts about how to create this tank game from scratch, talking about what tasks need to be done, how to get each step forward, readers with no experiences should be able to follow these posts, and hopefully learn enough to create their own game.
- Along the way, I may also write some posts on specific topics, which may not directly related to current steps, but related to game development in general.

- Posts will be in different categories, I plan to cover the followings (at least briefly):
    - **Platform**: development and runtime environment of the game, mainly DotNet Core and MonoGame
    - **Engine**: will create a very basic game engine for learning purpose, include world management, ECS (Entity Component System), physics integration...
    - **Library**: reusable component for multiple games, e.g. tiled map display, GUI framework, art assets management...
    - **Tool**: related tools, either from 3rd parties, or create from scratch.
    - **Logic**: specific to the tank game, not meant for reused in other games, though some logic might be abstracted later and put into library if possible.
    - **Misc**: other topics not in above categories.
- Current planned topics
    - Setup environment (platform)
    - Choose dependencies (platform, engine)
    - Game abstraction (engine, library)
    - Atlas integration (engine, library, tool)
    - ECS (engine)
    - Tiled map (engine, library, tool)
    - GUI framework (library)
    - Tank movement (logic)
    - Weapon system (logic)
    - Physics integration (engine, tool)
- Will maintain a wiki page at github repo of the latest plan, feel free to make a suggestion on topics you are interested (just create an issue).

## Structure of This Tutorial (How)
- This is a **hand-on** tutorial, you need to do actual works to really learn something, just reading the posts can only give you some basic idea about making game, but not the confidence that you can create one by yourself.
- This is **NOT** a _step-by-step_ tutorial, I will not add screenshots to tell you which buttons to click, and what snippets to paste. I'll show how I did certain tasks briefly, and give links to related information, but won't cover them in details.
- This is **NOT** a _quick-how-to_ guide, even though the demo itself is quite simple, I'll try to treat it as real project, with proper structure and try to create these simple feature in a maintainable way.
- I want to explain on **why** I make certain technical decisions and write the codes in current way, may not directly related to game itself, but can benefit further development.

## Suggestion for Potential Readers
- Better think about some simple game that you want to create, Tetris, Candy Crash, Platformer, anything you feel happy working on, you can use this tutorial as a guideline about how to create a game from scratch, and can create your own game along the way (can reuse the common components)
- It's also a very good idea to create a different tank game, based on my codes, but make it working in your ways.
- Any way, the only way to learn how to write a game is by doing it, so you have to write quite some codes to really get it, I will try to give some hints for experiments, but it's best to work on your own ideas.
- If you are serious to follow this tutorial, please create a fork of the repository, and write your own codes there, I can look into it if you need help later.
- Also, for any kind of communication (suggestions, questions, ...), feel free to create issues in GitHub.

## Some Caveats
- I'm not a native English speaker, writing in English is for broader audience and to improve my writing ability, I'll try to make it easy to understand but some time it's really hard to write technical stuffs clearly.
- This is a side project for me, not very busy with my main projects at the moment, but can't be sure about how much I can finish in the end.
- The codes is for learning purpose, not meant for real games, it'll be simplified in many aspects, and won't have proper test cases to make sure it's bugless, so if you need some thing ready for real games, please develop your game based on mature solutions.
- Since the codes is not finished, if you create your code base on it, might need to merge my later changes in, or need to maintain some own logic in your fork, which can be annoying, but it's also a common part in most coding projects, I'll try to make the code easier to be working with.
- The `master` branch will be the latest code, which will be ahead of posts, so if you want to work on own game, better create your branch from master and try update with it, and if you want to some experiments based on certain post, better branch out from the post's branch.

----
Code: https://github.com/yjpark/FSharpGameTutorial
