+++
title = "[F# Game Tutorial] GUI Addon"
path = "/blog/2019/02/03/fsharp-game-tutorial-gui-addon/"
template = "blog_post.html"

[extra]
date = "2019-02-03"
author = "YJ Park"
tags = ["fsharp", "game", "tutorial"]
+++

It's been a few days since last post, in this one, I want to talk about basic GUI implementation in the game, how to create a very simple addon system to support flexible extensions.

After we've got the very limited version of the game running (we can load an atlas and show sprites with it after last post), next steps will be adding more features, at this points, it's better to have a way to communicate with the running game easily. For example, when I want to tweak some parameters in game, it's not very efficient to repeatedly do these steps: change it in code, recompile, rerun to find the best value, instead I prefer to run the game, and use some way to change the parameters while the game is still running.

There are different ways to support this kind of communication:

- Provide some REPL (read, evaluate, print, loop) for running game, this is a very powerful way, but need quite some logic to support, especially for a compiled language like F#, many game engine will use some dynamic language for scripting purpose.
- Special development environment to provide extra features, e.g. when you run your game in Unity Editor, you can see many runtime information with editor UI, and can adjust many values with built-in inspector, 3rd party tools, or your editor extensions.
- In game GUI, menu bar, tool bar, or any UI you created for in game control purpose



Since we are creating our own game engine here, and use F# as programming language, the first 2 approaches are not easy to use, so I'll use the 3rd option here.

## Choose a GUI Framework

Implementing a GUI framework is a non trivial task, also it's not a essential part of this tutorial, so ideally I want to use an existing framework for this.

I look into the community list of MonoGame libraries at https://github.com/aloisdeniel/awesome-monogame, there are 3 GUI libraries listed:

### [EmptyKeys](https://github.com/EmptyKeys/UI_Engines)

The short description says: *Create UI from a WPF like XAML*, which is not the intended way I planned, was thinking about a more simple pure code approach, so pass for now.

### [GeonBit.UI](https://github.com/RonenNess/GeonBit.UI)

From it's github readme: *GeonBit.UI is the UI / HUD system of the GeonBit engine*, and *GeonBit is an Entity-Component-System based game engine*, I planned to create my own implementation on ECS for tutorial purpose, so this may make things a bit complicate for the readers, not ideal for my special requirements.

### [Myra](https://github.com/rds1983/Myra)

This seems to be the best fit, has a rich feature set, not extra dependencies, it also came with a UI editor, which can be handy later.

So I did some reading and experimenting with Myra, so far so good, then I decide to use it as the GUI framework in this tutorial.

## Some Thoughts on Choosing Libraries

It's very common for most projects nowadays to depend on external libraries, so parts of software developers' job are to choose when to use external libraries, and what particular libraries to use.

I've done this process many times, here are some thoughts that I think worth mentioning.

### Always Do Some Research Before Big Implementation

As developers, we love writing codes, it's both fun and feels nice when you can create new features, so in many cases (especially when you are not very experienced yet), when we see a requirement, we start coding very soon. Though it's always good to slow down a bit at this stage, do some research, see what's available out there first, and even if in the end you implement your own version, these research can help you to learn and design API in a better way.

Though it take time to use libraries too, especially for big and heavy ones, and in some cases, you may not be clear about what you want at the beginning, choose a library not fitting very well may cause trouble later. My feeling is that this is highly related to your experiences, so don't be afraid to make mistakes, do more practices, and you can get better from time.

### If Possible, Wrap the Library, or Limit Direct Dependencies

One strategy that works well for me is to create a thin wrapper for the library you chose, that should be the only place in your codes that directly depend on this library, so in the future if you want to switch to a different one, technically you can keep all other codes intact, and only update this wrapper. Of course this is a simplified description, in real world it's usually not that easy to have a fully independent wrapper layer, but if you have this in mind, then if you need to switch, it's much less painful to do.

For some critical part of your application, it might be even better to create a generic wrapping API, than support multiple wrappers with more than one libraries with same APIs, in this way, it's very flexible to switch implementation, but this approach take considerable efforts to make it right, since your common API needs to be generic, also it's much harder to use the library's full power.

Also in many cases, create a wrapper is not practical and not have much benefits, even in these cases, you can still limit direct dependencies to a smaller scope, that make the 3rd party related logic cleaner, and in case of migration, much easier to do.

And even for some libraries that you are 100% with the usage in a project, treat it this way is still helpful, for cases like version updates with backward incompatible changes. Without proper isolation, many projects normally stuck to a particular version and can't take advantages from upstream improvements, some times this can lead to security risks in production system.

## Addon System

I'd like to keep the core part of the game engine minimal and flexible, an addon system can help me to achieve this, and this is a very common feature in game development, so I think it's worthy to create a basic addon system in early stage.

Addon, Add-in, Plugin, Extension, are similar concepts, with some designed differences, I think the terminology is not really standard, e.g. I feel that addon or add-in means that they are added in development time, while plugins means that it can be attached later in runtime, but this is just my thoughts. But in general, they means by defining some extension points, we can extend new functionalities in a clean way.

### `Game.Engine/Types.fs`
Define interfaces for IAddon, and add support in IGame

{{< highlight fsharp >}}
type IGame =
    ...
    abstract Addons : Map<string, IAddon>
    abstract Register : (IGame -> IAddon) -> unit

and IAddon =
    inherit ILogger
    abstract Kind : string with get
    abstract Game : IGame with get
    abstract Update : unit -> unit
    abstract Draw : unit -> unit
    abstract LateUpdate : unit -> unit
    abstract LateDraw : unit -> unit
{{< /highlight >}}

### `Game.Engine/BaseAddons.fs`
This is the common base class for creating a new addon, just provide a few extension points, and default empty implementation.

{{< highlight fsharp >}}
[<AbstractClass>]
type BaseAddon (kind : string, game : IGame) =
    let logger : ILogger = getLogger <| sprintf "%s:%s" game.Param.Name kind

    abstract member Update : unit -> unit
    abstract member Draw : unit -> unit
    abstract member LateUpdate : unit -> unit
    abstract member LateDraw : unit -> unit

    default __.Update () = ()
    default __.Draw () = ()
    default __.LateUpdate () = ()
    default __.LateDraw () = ()

    interface IAddon with
        member __.Kind = kind
        member __.Game = game
        member this.Update () = this.Update ()
        member this.Draw () = this.Draw ()
        member this.LateUpdate () = this.LateUpdate ()
        member this.LateDraw () = this.LateDraw ()
    interface ILogger with
        member __.Log evt = logger.Log evt
{{< /highlight >}}

### `Game.Engine/Internal/Game.fs`
The game class will just maintain a list of addons, and calling their extension points at right time.

{{< highlight fsharp >}}
type internal Game (param : GameParam) =
    inherit Microsoft.Xna.Framework.Game ()
    ...
    let mutable addons : Map<string, IAddon> = Map.empty
    ...
    override this.Update (gameTime : GameTime) =
        time <- gameTime
        param.ExitKey
        |> Option.iter (fun key ->
            if Keyboard.isKeyDown key then
                this.Exit ()
        )
        addons
        |> Map.iter (fun _kind addon -> addon.Update ())
        base.Update (gameTime)
        addons
        |> Map.iter (fun _kind addon -> addon.LateUpdate ())
    override __.Draw (gameTime : GameTime) =
        time <- gameTime
        param.ClearColor
        |> Option.iter (fun color ->
            graphics.Value.Device.Clear (color)
        )
        graphics.Value.SpriteBatch.Begin (camera.Value)
        addons
        |> Map.iter (fun _kind addon -> addon.Draw ())
        graphics.Value.SpriteBatch.End ()
        base.Draw (gameTime)
        addons
        |> Map.iter (fun _kind addon -> addon.LateDraw ())
    interface IGame with
        ...
        member this.Register (create : IGame -> IAddon) =
            let addon = create this
            let kind = addon.Kind
            match Map.tryFind kind addons with
            | Some addon' ->
                logError this "Register" "Addon_Already_Exist" (kind, addon', addon)
            | None ->
                addons <- Map.add kind addon addons
                logInfo this "Register" "Addon_Added" (kind, addon)
    ...
{{< /highlight >}}

### `Game.Gui/Types.fs`

Define IGui in gui addon, also provide a generic version to get the root widget with type.

{{< highlight fsharp >}}
type IGui =
    inherit IAddon
    abstract Menu : Menu with get
    abstract Root0 : Widget with get

type IGui<'root when 'root :> Widget> =
    inherit IGui
    abstract Root : 'root with get
{{< /highlight >}}

### `Game.Gui/Internal/Gui.fs`

The implementation is just simple and straightforward, here to assume all games will have a menu bar and a root widget, each game that uses this addon will add elements into the root panel to construct proper GUI elements.

{{< highlight fsharp >}}
type internal Gui<'root when 'root :> Widget> (kind : string, game : IGame) =
    inherit BaseAddon (kind, game)

    do (
        MyraEnvironment.Game <- game.Xna
    )
    let desktop : Desktop = new Desktop ()
    let menu : Menu = new Menu ()
    let root : 'root =
        Activator.CreateInstance (typeof<'root>, [| |])
        :?> 'root

    do (
        desktop.Widgets.Add menu
        root.GridPositionY <- 1
        root.Top <- 32
        desktop.Widgets.Add root
    )

    override __.Draw () =
        desktop.Bounds <- new Rectangle(0, 0, game.Width, game.Height)
        desktop.Render()
    interface IGui with
        member __.Menu = menu
        member __.Root0 = root :> Widget

    interface IGui<'root> with
        member __.Root = root
{{< /highlight >}}

### `Game.Gui/Gui.fs`

Also adding some extension and helper functions to make it easier to use.

{{< highlight fsharp >}}
type IGui with
    member this.AddMenuItems ([<ParamArray>] items : MenuItem array) =
        this.Menu.AddItems items
        this

type IGui<'root when 'root :> Widget> with
    member this.AddChildren ([<ParamArray>] children : Widget array) =
        match this.Root0 with
        | :? Container as container ->
            container.AddChildren children
        | _ ->
            failWith "Not_Container" <| this.Root.GetType ()
        this

let create<'root when 'root :> Widget> (game : IGame) =
    let gui = new Gui<'root> (Kind, game)
    gui :> IGui<'root>
{{< /highlight >}}

### `Tank.Playground/MainGui.fs`

In game projects, can use the gui addon to show a menuitem to quit the game properly, also create a few button to move camera's position (panning).

Here the menu items and buttons are created with a very simple internal DSL created with F# computation expression, more details will be written in a future post.

Also the camera feature is provided by [Comora](https://github.com/aloisdeniel/Comora)

{{< highlight fsharp >}}
let private initMenu (gui : IGui) =
    gui.AddMenuItems (
        menuItem {
            text "Quit"
            onSelected (fun _args -> gui.Game.Xna.Exit ())
        }
    )

let create game =
    Gui.create<Panel> game
    |> CameraGui.init
    |> initMenu
{{< /highlight >}}

### `Tank.Playground/Program.fs`

By setting up a instance of GameParam, can create a game instance, and run it.

{{< highlight fsharp >}}
let initialize =
    withAddon MainGui.create

let execute (args : ParseResults<Args>) =
    let consoleMinLevel =
        if args.Contains Verbose then
            LogLevelInformation
        else
            LogLevelWarning
    setupConsole consoleMinLevel |> ignore

    use _game = Game.tank initialize
    0 // return an integer exit code
{{< /highlight >}}

## Some Comments

I won't have line by line explanation here, I think the structure is simple here, nothing really fancy.

I added a GameParam record to represent the information about how to create a game instance to make the API a bit cleaner, you can browse the code base for more details

You may feel that the codes here is a bit over design, after all, all these codes above are not adding features, they are only provide a more flexible way to organize codes together, e.g. you can just add a root gui into base game, then you'll have much fewer lines. In some sense this is true, we are over designing at this moment, but since I'm pretty sure that the GUI usage will be much more complicate in the future, and also we can create more addons for cleaner codes (actually I've change the tank display logic into an addon as well), I think it's worthy to implement the addon system now.

Any way, hope you enjoy this post, in the next one, I want to discuss about some details of the internal DSL for GUI elements, I think it's a pretty neat way and can show the power and easy to use of F# computation expression.

----
Code: https://github.com/yjpark/FSharpGameTutorial/tree/posts/gui-addon
