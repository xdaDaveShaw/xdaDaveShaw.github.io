---
layout: post
status: publish
published: true
title: Santa's Xmas List in F# and Fable
date: '2018-12-21 22:49:00 +0100'
date_gmt: '2018-12-21 22:49:00 +0100'
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
- What presents Nice children are getting,
- See an overall list of all the presents he needs to sent to the elves.

![Screen shot][6]

The app is written in F#, using Fable, Elmish and Fulma (which I also used to write [Monster Splatter][2]) and all the associated tooling in SAFE stack. I decided to leave out a back end to keep things simple.

## The Domain Model

My problem with any Model-View-`X` architecture is that everything that isn't a POCO or UI related goes in `X`, so I look for ways to make sure the Domain logic can be quickly broken out and separated from `X`. 

With Elmish, this was very easy. I created began my modelling the Domain and the Operations that can be performed on it:

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

type CurrentEditorState = {
  EditingChildName: string
  CurrentItem: (string * string) option
  ClearingStorage: bool
}

type Model = {
  CurrentEditor: CurrentEditorState
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

1. Add child, takes in a name as a String and the current state and returns an updated model and Event (see below)
1. Add item, takes in a child's name, an item and the current state and also returns an updated model and Event.
1. Review child, also takes in a child's name and if they are naughty or nice, as well as the current state, and guess what, returns an updated model and Event.
1. The Event is explained in the Event Sourcing section, but is simple a Union Case representing what just happened.

There's no need to go into implementation of the Domain, it's pretty basic, but it is worth pointing out that Adding an item to a Nice child, also adds an item to `SantasList`, or increments the quantity of an existing item.

### Reuse-Reuse-Reuse

The main take away here is that the Domain module contains pure F#, no Fable, no Elmish, just my Domain code. This means if I wanted to run it on my F# Services I could use the exact same file and be guaranteed the exact same results.

Full source can be [seen here][4].

## Testing

I just said I could be guaranteed the exact same results if I ran this code on my Services... but how...

Fable transpiles my F# into JavaScript and runs it in the browser, how can I know this works the same in .NET Core on the server?

The answer as **Testing** - the only way you can be sure of anything in software.

Using the Fable Compiler's tests as inspiration and the [Fable bindings for Jest][3], I've managed to create a suite of tests that can be run against the generated JavaScript and the compiled .NET code.

The trick is to `FABLE_COMPILER` compiler directive to produce different code under Fable and .NET.

For example the `testCase` funciton is declared as:

```fsharp
let testCase (msg: string) (test: unit->unit) =
  msg, box test
```

in Fable, but as:

```fsharp
open Expecto

let testList (name: string) (tests : Test list) =
  testList name tests
```

Full source can be [seen here][5].

But a test can now be written once and run many times depending how the code is compiled:

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

What I found amazing was the way I could run these tests. The JS Tests took 2 different tools to get running:

- fable-splitter
- Jest

Both of these operated in "Watch Mode", so I could write a failing test, Ctrl+S, watch it fail a second later. Then write the code to make it pass, Ctrl+S again, and watch it pass. No building, no run tests, just write and Save.

As the .NET tests are in Expecto, I can have the same workflow for them too with `dotnet watch run`.

I have all 3 tasks setup in VS Code and can run them a simple command.

[SCREEN SHOT]

## Event Sourcing

As I decided to avoid building a back end for this I wanted a way to maintain the state on the client by persisting it into Local Storage in the browser.

To do this I create a simple discriminated union for the Event and used type aliases for all the strings:

```fsharp
type Name = string
type Item = string
type Review = string

type Event =
  | AddedChild of Name
  | AddedItem of Name * Item
  | ReviewedChild of Name * Review
```

These are what are returned from the Domain model representing what has just changed. They are exactly what the user input, no cleaning strings.

The "Event Store" in this case is a simple `ResizeArray<Event>` (`List<T>`) that each event is added to the end of.

Storing these in Local Storage uses the Fable bindings for the browser and `Thoth.Json` in Auto mode for serialization. Deserialization is the same process in reverse, Load from Local Storage, pass to `Thoth.Json` decoder in Auto mode.

Once all the events are loaded we need to some how convert them back into the Model with the state that was there before.

In F# this is actually really easy.

```fsharp
let fromEvents : FromEvents =
  fun editorState events ->

    let processEvent m ev =
      let model, _ =
        match ev with
        | EventStore.AddedChild name -> m |> addChild name
        | EventStore.ReviewedChild (name, non) -> m |> reviewChild name (stringToNon non)
        | EventStore.AddedItem (name, item) -> m |> addItem name { Description = item }
      model

    let model =
      createDefaultModel editorState

    events
    |> List.fold processEvent model
```

Start by getting an empty `model` from the function `createDefaultModel`.

Then you use a `fold` to iterate over each event passing in the current state and returning a new state. Each time the fold goes through an event in the list, the updated state from the previous iteration is passed in, this is why you need to start with an empty model.

The `processEvent` function matches and deconstructs the values from the event and passes them to the correct Domain function - which already returns the updated model, so it works perfectly with the `fold`.

 [1]: https://sergeytihon.com/2018/10/22/f-advent-calendar-in-english-2018/
 [2]: {{site.url}}/blog/playing-with-fable/
 [3]: https://github.com/jgrund/fable-jest
 [4]: https://github.com/xdaDaveShaw/XmasList/blob/master/src/Domain.fs
 [5]: https://github.com/xdaDaveShaw/XmasList/blob/master/tests/Util.fs
 [6]: {{site.contenturl}}advent-2018-screen.png