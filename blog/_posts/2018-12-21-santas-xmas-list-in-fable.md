---
layout: post
status: publish
published: true
title: Santa's Xmas List in F# and Fable
date: '2018-12-21 09:30:00 +0000'
date_gmt: '2018-12-21 09:30:00 +0000'
categories:
- FSharp
---

> This post is part of the [F# Advent Calendar 2018][1]. Many thanks to Sergey Tihon for organizing these.

So this year I decided to write something for the F# Advent Calendar, and even though I picked a date far enough in the future, panic still set in.
I'm not one for "ideas on demand", and after a bit of deliberating about Xmas themed games, I finally settled on something that let me explore my favourite parts of F# at the moment:

- Domain Modelling
- Testing
- Event Sourcing
- Fable & Elmish

## The Concept

My initial design was for something a bit more complicated, but I scaled it down into simple Web App where Santa can:

- Record children's names
- Who's been Naughty and who's been Nice
- What presents Nice children are getting
- See an overall list of all the presents he needs to sent to the elves

![Screen shot][6]

### [Click here to have a play][13]

The app is written in F#, using Fable, Elmish and Fulma (which I also used to write [Monster Splatter][2]) and all the associated tooling in SAFE stack. I did consider writing a back-end for it, but decided to keep things simple.

## The Domain Model

A common problem with any Model-View-*X* architecture is that everything that isn't POCO (Model) or UI (View) related ends up *X*, so I look for ways to make sure the Domain logic can be quickly broken out and separated from *X*.

With Elmish, this was very easy. I began my modelling the Domain and the Operations that can be performed on it:

```fsharp
type Item = {
  Description: string
}

type NaughtyOrNice =
  | Undecided
  | Nice of Item list
  | Naughty

type Child = {
  Name: string
  NaughtyOrNice: NaughtyOrNice
}

type SantasItem = {
  ItemName: string
  Quantity: int
}

type Model = {
  CurrentEditor: CurrentEditorState //Not shown
  ChildrensList: Child list
  SantasList: SantasItem list
}

type AddChild = string -> Model -> Model * EventStore.Event
type AddItem = string -> Item -> Model -> Model * EventStore.Event
type ReviewChild = string -> NaughtyOrNice -> Model -> Model * EventStore.Event
```

There's a few things above, so let's go through the types:

1. The `Model` holds a list of `Child` records and `SantaItem` records.
1. A child has a name and a Naughty or Nice status. If they are Nice, they can also have a list of Items.
1. Santa's items have a quantity with them.
1. I didn't separate the UI stuff (`CurrentEditor`) from the Domain model, this was just to keep things simple.

And the functions:

1. `AddChild` takes in a `string` for the childs name as well as the current model and returns an updated model and `Event` (see below)
1. `AddItem` takes in a child's name, an item, and the current state and also returns an updated model and `Event`.
1. `ReviewChild` also takes in a child's name and if they are naughty or nice, as well as the current state, and guess what, returns an updated model and `Event`.
1. The `Event` is explained in the Event Sourcing section below, but is simple a Union Case representing what just happened.

There's no need to go into implementation of the Domain, it's pretty basic, but it is worth pointing out that Adding an item to a Nice child, also adds an item to `SantasList`, or increments the quantity of an existing item.

### Reuse-Reuse-Reuse

The main take away here is that the Domain module contains pure F#, no Fable, no Elmish, just my Domain code. This means if I wanted to run it on my F# Services I could use the exact same file and be guaranteed the exact same results.

Full source can be [seen here][4].

## Testing

I just said I could be *guaranteed the exact same results* if I ran this code on my Services... but how?

Fable transpiles my F# into JavaScript and runs it in the browser, how could I know this works the same in .NET Core when run on the server?

The answer is **Testing** - the only way you can be sure of anything in software.

Using the Fable Compiler's tests as inspiration and the [Fable bindings for Jest][3], I've created a suite of tests that can be run against the generated JavaScript and the compiled .NET code.

> As of writing there is a [Bug][11] with Fable 2 and the Jest Bindings, but you can work around them.

The trick is to use the `FABLE_COMPILER` compiler directive to produce different code under Fable and .NET.

For example the `testCase` function is declared as:

```fsharp
let testCase (msg: string) (test: unit->unit) =
  msg, box test
```

in Fable, but as:

```fsharp
open Expecto

let testCase (name: string) (test: unit -> unit) : Test =
  testCase name test
```

in .NET Code.

Full source can be [seen here][5].

What this gives me is a test can now be written once and run many times depending how the code is compiled:

```fsharp
testCase "Adding children works" <| fun () ->
    let child1 = "Dave"
    let child2 = "Shaw"

    let newModel =
        addChild child1 defaultModel
        |> addChild child2

    let expected = [
        { Name = child1; NaughtyOrNice = Undecided }
        { Name = child2; NaughtyOrNice = Undecided } ]

    newModel.ChildrensList == expected
```

What's really cool, is how you can run these tests.

The JS Tests took 2 different NPM packages to get running:

- fable-splitter
- Jest

Both of these operated in "Watch Mode", so I could write a failing test, Ctrl+S, watch it fail a second later. Then write the code to make it pass, Ctrl+S again, and watch it pass. No building, no run tests, just write and Save.

As the .NET tests are in Expecto, I can have the same workflow for them too with `dotnet watch run`.

I have all 3 tasks setup in VS Code and can set them running with the "Run Test Task" command.
See my [tasks.json][7] and [packages.json][8] files for how these are configured.

![Test Terminals][9]

I have a CI/CD Pipeline setup in Azure Dev Ops running these tests on both Windows and Ubuntu build agents. That takes 25 written tests to 100 running tests.

## Event Sourcing

As I decided to avoid building a back-end for this I wanted a way to maintain the state on the client by persisting it into Local Storage in the browser.

Instead of just serializing the current Model into JSON and storing it, I thought I'd try out storing each of the users actions as an Event and
then playing them back when the user (re)loads the page.

This isn't a *pure* event sourcing implementation, but one that uses events instead of CRUD for persistence. If you want to read a more
complete introduction to F# and Event Sourcing, try [Roman Provazník's Advent Post][16].

Most of the application is operating on the "View / Projection" of the events, instead of the Stream of events.

To model each event I create a simple discriminated union for the `Event` and also used type aliases for all the strings, just to make it clearer what all these strings are:

```fsharp
type Name = string
type Item = string
type Review = string

type Event =
  | AddedChild of Name
  | AddedItem of Name * Item
  | ReviewedChild of Name * Review
```

These are what are returned from the Domain model representing what has just changed. They are exactly what the user input, no normalising strings
for example.

The "Event Store" in this case is a simple `ResizeArray<Event>` (aka  `List<T>`), and each event is appended onto it.

Every time an event is appended to the Store, the entire store is persisted into Local Storage. Fable has "bindings" for access local storage which
mean you only need to call:

```fsharp
//Save
Browser.localStorage.setItem(key, json)

//Load
let json = Browser.localStorage.getItem(key)
```

![Local Storage][14]

For serialization and deserialization I used [Thoth.Json][10] and just used the "Auto mode" on the list of Events.

When the page is loaded all the Events are loaded back into the "Event Store", but now we need to some how convert them back into the Model and recreate the state that was there before.

In F# this is actually really easy.

```fsharp
let fromEvents : FromEvents =
  fun editorState events ->

    let processEvent m ev =
      let updatedModel, _ =
        match ev with
        | EventStore.AddedChild name -> m |> addChild name
        | EventStore.ReviewedChild (name, non) -> m |> reviewChild name (stringToNon non)
        | EventStore.AddedItem (name, item) -> m |> addItem name { Description = item }
      updatedModel

    let state0 =
      createDefaultModel editorState

    (state0, events)
    ||> List.fold processEvent
```

It starts by declaring a function to process each event, which will be used by the `fold` function.

The `processEvent` function takes in the current state `m` and the event to process `ev`, matches and deconstructs the values from `ev` and passes them to the correct Domain function, along with the current model (`m`) and returns the updated model (ignoring the returned event as we don't need them here).

Next it creates `state0` using the `createDefaultModel` function - you can ignore the `editorState`, as I mentioned above, it has leaked in a little.

Then it uses a `fold` to iterate over each event, passing in the initial state (`state0`) and returning a new state. Each time the fold goes through an event in the list, the updated state from the previous iteration is passed in, this is why you need to start with an empty model, which is then built up on with the events.

## Summing Up

There's a lot more I could have talked about here:

- How I used Fulma / Font Awesome for the Styling.
- How I used Fable React for the UI.
- How I used Azure Pipelines for the CI/CD Pipeline to S3.
- How I never needed to run a Debugger once.
- How I used FAKE for x-plat build scripts.

But, I think this post has gone on too long already.

What I really wanted to highlight and show off are the parts of [F# I love][15].
Along with that, the power of the SAFE-Stack for building apps that are using the same tech stacks people
are currently using, like React for UI and Jest for Testing, but show how Fable enables
developers to do so much more:

- 100% re-usable code
- Type safe code
- Domain modelling using Algebraic Data Types
- Event Sourcing
- Familiarity with .NET
- Functional Architecture (Elmish).

I also wanted to share my solutions to some of the problems I've had, like running the tests, or setting up webpack, or using FAKE.

It doesn't do everything that the SAFE Demo applications do, but I hope someone can find it a useful starting point for doing
more than just TODO lists. Please go checkout the [source][12], clone it and have a play.

If anyone has any questions or comments, you can find me on Twitter, or open an [Issue in the Repo][12].

### [Don't forget to have a play][13] ;)

 [1]: https://sergeytihon.com/2018/10/22/f-advent-calendar-in-english-2018/
 [2]: {{site.url}}/blog/playing-with-fable/
 [3]: https://github.com/jgrund/fable-jest
 [4]: https://github.com/xdaDaveShaw/XmasList/blob/master/src/Domain.fs
 [5]: https://github.com/xdaDaveShaw/XmasList/blob/master/tests/Util.fs
 [6]: {{site.contenturl}}advent-2018-screen.png
 [7]: https://github.com/xdaDaveShaw/XmasList/blob/master/.vscode/tasks.json
 [8]: https://github.com/xdaDaveShaw/XmasList/blob/master/package.json
 [9]: {{site.contenturl}}advent-2018-tests.png
 [10]: https://mangelmaxime.github.io/Thoth/json/v2/decode.html
 [11]: https://github.com/jgrund/fable-jest/issues/13
 [12]: https://github.com/xdaDaveShaw/XmasList/
 [13]: https://xmaslist.s3-eu-west-1.amazonaws.com/index.html
 [14]: {{site.contenturl}}advent-2018-storage.png
 [15]: https://skillsmatter.com/skillscasts/11439-keynote-f-sharp-code-i-love
 [16]: https://medium.com/@dzoukr/event-sourcing-step-by-step-in-f-be808aa0ca18
