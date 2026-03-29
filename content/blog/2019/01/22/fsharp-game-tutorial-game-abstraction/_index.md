+++
title = "[F# Game Tutorial] Game Abstraction"
path = "/blog/2019/01/22/fsharp-game-tutorial-game-abstraction/"
template = "blog_post.html"

[extra]
date = "2019-01-22"
author = "YJ Park"
tags = ["fsharp", "game", "tutorial"]
+++

In last post, we did load an atlas and show a simple sprite from it, this one is mainly on refactoring, extract common logic for all games, which can be reused later.

## Game.TexturePacker
Moved the texture packer library from Tank.Content here.

## Game.Engine
Move game abstraction here, it's very simple now, the logic is same from last post, just create base class, and ways for customization.



### BaseGame.fs
{{< highlight fsharp >}}
type BaseGame (param : GameParam) =
    inherit Microsoft.Xna.Framework.Game ()

    let mutable graphicsManager : GraphicsDeviceManager option = None
    let mutable graphics : Graphics option = None
    let mutable atlas : Atlas option = None
    let mutable time : GameTime option = None

    member this.Setup () =
        this.Content.RootDirectory <- ContentRoot
        graphicsManager <- Some <| new GraphicsDeviceManager (this)

    (* Expose properties
     *)
    member __.Graphics = graphics |> Option.get
    member __.Atlas = atlas |> Option.get
    member __.Time = time |> Option.get

    (* Extension points for subclasses, with default implementation
     *)
    abstract member DoInit : unit -> unit
    abstract member DoUpdate : unit -> unit
    abstract member DoDraw : unit -> unit
    default __.DoInit () = ()
    default __.DoUpdate () = ()
    default __.DoDraw () = ()

    override this.Initialize () =
        let spriteBatch = new SpriteBatch (this.GraphicsDevice)
        let spriteSheetLoader = new SpriteSheetLoader(this.Content, this.GraphicsDevice)
        graphics <- Some {
            Device = this.GraphicsDevice
            SpriteBatch = spriteBatch
            SpriteRender = new SpriteRender (spriteBatch)
            SpriteSheetLoader = spriteSheetLoader
        }
        atlas <- Some <| Atlas.Create ^<| spriteSheetLoader.Load (param.AtlasImage)
        base.IsMouseVisible <- param.IsMouseVisible
        this.DoInit ()
        base.Initialize ()

    override this.Update (gameTime : GameTime) =
        time <- Some gameTime
        this.DoUpdate ()
        base.Update (gameTime)

    override this.Draw (gameTime : GameTime) =
        time <- Some gameTime
        param.ClearColor
        |> Option.iter (fun color ->
            this.Graphics.Device.Clear (color)
        )
        this.Graphics.SpriteBatch.Begin ()
        this.DoDraw ()
        this.Graphics.SpriteBatch.End ()
        base.Draw (gameTime)
{{< /highlight >}}

### GameParam.fs

Record type been created for params of game, cleaner and easier to use than individual variables, more params will be added later, such as initial resolution, full screen mode, etc.

{{< highlight fsharp >}}
type GameParam = {
    AtlasImage : string
    IsMouseVisible : bool
    ClearColor : Color option
} with
    static member Create (atlasImage : string, ?isMouseVisible : bool, ?clearColor : Color) : GameParam =
        {
            AtlasImage = atlasImage
            IsMouseVisible = defaultArg isMouseVisible true
            ClearColor = clearColor
        }
{{< /highlight >}}

## Tank.Core Changes

### Game.fs
By using BaseGame, now the subclass only have logic specific to this particular game.

{{< highlight fsharp >}}
let param = GameParam.Create(Textures.Tank, clearColor = Color.Black)

type Game () =
    inherit BaseGame (param)
    let mutable testSprite : SpriteFrame option = None

    static member CreateAndRun () =
        let game = new Game ()
        game.Setup ()
        game.Run ()
        game
    override this.DoInit () =
        testSprite <- Some <| this.Atlas.SpriteSheet.Sprite (Sprites.TankBody_huge);
    override this.DoDraw () =
        this.Graphics.SpriteRender.Draw (testSprite.Value, Vector2(100.0f, 100.0f))
{{< /highlight >}}

## Summary
Only very simple refactoring this time, in next post, I will add a GUI library as addon, and create a very basic menu.

----
Code: https://github.com/yjpark/FSharpGameTutorial/tree/posts/game-abstraction
