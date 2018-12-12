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

> This post is part of the [F# Advent Calendar 2018][1].

So this year I decided to write something for the F# Advent Calendar, and even though I picked a date far enough in the future, panic still set in.
I'm not one for "ideas on demand", and after a bit of deliberating about Xmas themed games, I finally settled on something that let me explore my favourite parts of F#:

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

[SCREEN SHOT]

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

 [1]: https://sergeytihon.com/2018/10/22/f-advent-calendar-in-english-2018/
 [2]: {{site.url}}/blog/playing-with-fable/