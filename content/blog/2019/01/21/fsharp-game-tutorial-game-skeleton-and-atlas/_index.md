+++
title = "[F# Game Tutorial] Game Skeleton and Atlas"
path = "/blog/2019/01/21/fsharp-game-tutorial-game-skeleton-and-atlas/"
template = "blog_post.html"

[extra]
date = "2019-01-21"
author = "YJ Park"
tags = ["fsharp", "game", "tutorial"]
+++

Was down with a really bad flu last week, can't work on anything at all, feeling much better today.

## What to Cover in this Post
We've setup the environment, got these command line tools to be running: `dotnet`, `paket`, `fake`, now we are gonna use these tools to start development.

Since this is a *from scratch* tutorial, I'll try to explain how I create the game itself and the game engine underneath, also will talk about some reasons behind the way I chose.

This post will focus on the basic skeleton of the game, How I organize the codes and assets, use the libaries to create a minimal runnable game that can load an image and show it on the screen.



## Why Start with Atlas

Since I had near to zero experience when I start this project, I need to do some experiments to learn something, I started with this one: *create a game window and show a tank in it using atlas*, this is a good candidate for experiments for following reasons:

- Very basic, without this feature, it's very hard to take next steps
- Well defined, plenty tutorials and documents around
- Complex enough, need to some learning to finish
- Flexible enough, can experiment with different ways

### What is Atlas and Why Need It

In 2D game engines, a `Sprite` usually means a rectangle area that can be drawn on screen, it's the very basic building block in 2D games. `Texture` is a chunk of memory that holding image data that can be used when drawing sprites.

Usually textures are loaded from images files, you can load individual images separately and create textures for each of them, though in most cases, we will use `Atlas` which is just a bigger images with several smaller images inside, and create textures for each atlas, main reasons for this way:

- Performance for rendering, it's related to more low level concepts used in GPU, basically is that when rendering a lot of sprites on screen, if they are from same texture, GPU can batch many of them together, which is much faster than individually.
- Performance for texture transfer, all texture need to be transferred from CPU to GPU before they can used for rendering, fewer bigger textures are much faster comparing to many smaller ones, also it take fewer memory in this way.
- Cleaner asset pipeline, easier to manage, e.g. you may want to create different version of images for different screen resolution, then you can just create different sets of atlas, and choose proper one at runtime.

Here is the atlas been used in the game

{{< figure src="http://github.com/yjpark/FSharpGameTutorial/blob/posts/game-skeleton-and-atlas/src/Tank.Playground/Content/Tank.png?raw=true" title="Tank.png" width="80%" >}}

### Notes about Asset Pipeline
Some sort of metadata about the individual images are needed to split them later, the format is different to the tool and library.

Also the textures is only part of the assets, in game development, usually artists will create all sort of art assets, such as images, audio, music... It's usually pass through so called *pipelines*, for different kinds of processes, e.g. change image format from PSD to PNG, pack individual images together. Ideally done by some automatic way.

MonoGame has its own pipeline and tools, I spent a little time to try with it, think it's not really needed in this stage and might make this tutorial more complex, so not using it yet at the moment.

### Original Assets
The original assets are from *Top-down Tanks Redux by Kenney Vleugels*, which is free to use thanks for the author.

- https://www.kenney.nl/assets/topdown-tanks-redux

It already include atlas version, though the format is not the one used in MonoGame.

### Texture Packer

Texture Packer is a very nice tool to create atlas, a free version is provided with limited feature, it's really worth the money if you're serious about making 2D games.

- https://www.codeandweb.com/texturepacker

it can export metadata for MonoGame, provide library to load and draw, also can export csharp code that defines constants for images names.

## Organization of the Codes

When start a new project, I often spend some time on the way to organize codes first, normally I'll try to separate the parts that can be reused in other projects and parts that are mostly relavent to specific project only. I think even if the parts are never used in other projects, a clear structure is helpful to produce better code, and can keep my mind clear when working on it.

It's typical for me that I need to tweak the structure a couple times until I feel comfortable with it, since when start working on it, I don't really understand the problems that I'm solving, and can't anticipate what issues might meet, and usually I need to do a few iterations to improve the structure. My experience is that I'll try to slow down feature development a bit at first, get some basic logic, then try to refactor the codes to nicer organization, then add a few more logic, then tweak the structure, try to keep a flexible skeleton, do a few experiments before make big decision, and try not to be too hurry.

### Library and Application Projects

There are 2 type of projects in .NET Core, library and application, library will output `.dll` files, which will be used in applications. You can run application projects, and can also publish to be run on other machines, check `dotnet publish --help` for more details.

Usually I will create the project folder manually, cd to it, then run `dotnet new classlib -lang F#` or `dotnet new console -lang F#` to create the project file.

#### `Tank.Core/Tank.Core.fsproj`

```
<?xml version="1.0" encoding="utf-8"?>
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>netstandard2.0</TargetFramework>
  </PropertyGroup>
  <ItemGroup>
    <Compile Include="Game.fs" />
  </ItemGroup>
  <ItemGroup>
    <ProjectReference Include="..\Tank.Content\Tank.Content.csproj" />
  </ItemGroup>
  <Import Project="..\..\.paket\Paket.Restore.targets" />
</Project>
```

This is a library project, it's quite simple, just list of F# source codes, other projects that it depends on, and packages with paket.

#### `Tank.Playground/Tank.Playground.fsproj`

```
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>netcoreapp2.2</TargetFramework>
  </PropertyGroup>
  <ItemGroup>
    <Compile Include="Program.fs" />
  </ItemGroup>
  <ItemGroup>
    <ProjectReference Include="..\Tank.Core\Tank.Core.fsproj" />
  </ItemGroup>
  <Import Project="..\..\.paket\Paket.Restore.targets" />
</Project>
```

This is an application project, run `fake -t tank.playground.run` at project root, or cd to `src/Tank.Playground` and run `dotnet run` to run the application

#### Tank.Content
It's not possible to mix csharp codes in fsharp project, so I create a very simple csharp project to hold the generated csharp codes and the texture packer library

#### `build.fsx`
{{< highlight fsharp "linenos=inline" >}}
...
let allProjects =
    !! "src/Tank.Core/*.fsproj"
    ++ "src/Tank.Content/*.csproj"
    ++ "src/Tank.Playground/*.fsproj"

DotNet.create NuGet.debug allProjects

Target.runOrDefault DotNet.Build
{{< /highlight >}}

I'm using a simple package for writing the fake config, run `fake --list` to list all targets, and can run `fake -t TARGET` to run certain target.

More details:

- https://github.com/yjpark/dap.build.fsharp
- http://blog.yjpark.org/blog/2018/09/01/build-dotnet-projects-with-fake/

## Code Explanation
Did spend quite some time to learn the very basic about MonoGame, following some tutorials and samples, tried a few ways, the final codes is quite simple, I'll add some comments to the source codes to explain a bit, these comments will be added **before** the codes.

Check MonoGame documentation for some
- http://www.monogame.net/documentation/

### `Tank.Core/Game.fs`
All logic are implemented here, most of them will be generalize to be reused in other games.

{{< highlight fsharp >}}
[<AutoOpen>]
module Tank.Core.Game

open Microsoft.Xna.Framework
open Microsoft.Xna.Framework.Graphics
open Microsoft.Xna.Framework.Input

open TexturePackerLoader

open Tank.Content

type BaseGame = Microsoft.Xna.Framework.Game

(* Create a simple record to put graphics related objects together
 *)
type Graphics = {
    Device : GraphicsDevice
    SpriteBatch : SpriteBatch
    SpriteRender : SpriteRender
    SpriteSheet : SpriteSheet
}

type Game () =
    inherit BaseGame ()

    (* The timing here is a bit tricky, can not create graphics manager here
     * since it need the object itself, but it's not working properly during
     * initialization, so using an option here.
     *)
    let mutable graphicsManager : GraphicsDeviceManager option = None
    let mutable graphics : Graphics option = None

    let mutable testSprite : SpriteFrame option = None
    member private this.Init () =
        this.Content.RootDirectory <- Tank.Content.Const.Root
        graphicsManager <- Some <| new GraphicsDeviceManager (this)

    static member CreateAndRun () =
        let game = new Game ()
        game.Init ()
        (* Start the game loop and show game window, exit after window been closed *)
        game.Run ()
        game

    member __.Graphics = graphics |> Option.get

    override this.Initialize () =
        (* Create the graphic instance *)
        let spriteBatch = new SpriteBatch (this.GraphicsDevice)
        let spriteSheetLoader = new SpriteSheetLoader(this.Content, this.GraphicsDevice)
        graphics <- Some {
            Device = this.GraphicsDevice
            SpriteBatch = spriteBatch
            SpriteRender = new SpriteRender (spriteBatch)
            SpriteSheet = spriteSheetLoader.Load(Tank.Content.Const.Texture)
        }
        (* Create a sprite for tank image *)
        testSprite <- Some <| this.Graphics.SpriteSheet.Sprite (Sprites.TankBody_huge);
        base.IsMouseVisible <- true
        base.Initialize ()

    override this.Update (gameTime : GameTime) =
        base.Update (gameTime)

    override this.Draw (gameTime : GameTime) =
        this.Graphics.Device.Clear (Color.Black)
        this.Graphics.SpriteBatch.Begin ()
        (* Draw the tank image *)
        this.Graphics.SpriteRender.Draw (testSprite.Value, Vector2(100.0f, 100.0f))
        this.Graphics.SpriteBatch.End ()
        base.Draw (gameTime)
{{< /highlight >}}

### `Tank.Playground/Program.fs`
{{< highlight fsharp >}}
module Tank.Playground.Program

open System

open Tank.Core

[<EntryPoint>]
let main argv =
    use game = Game.CreateAndRun ()
    0 // return an integer exit code
{{< /highlight >}}

## Summary
As you can see, it's very simple so far, after all, there is no much functionality yet, though I think it's a solid start, all codes are organized cleanly, and we have an atlas loaded.

In next post, I'll start working on the game engine side, put reusable logic into it, after that, will add some basic GUI elements.

----
Code: https://github.com/yjpark/FSharpGameTutorial/tree/posts/game-skeleton-and-atlas
