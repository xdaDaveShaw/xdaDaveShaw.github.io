---
layout: post
status: publish
published: true
title: Xmas List Parser
date: '2019-12-22 11:00:00 +0000'
date_gmt: '2019-12-22 11:00:00 +0000'
categories:
- FSharp
---

> This post is part of the [F# Advent Calendar 2019][1]. Many thanks to Sergey Tihon for organizing these.

[Last year][2] I wrote an [app][3] for Santa to keep track of his list of presents to buy for the nice children
of the world.

Sadly, the development team didn't do proper research into Santa's requirements; they couldn't be bothered with
a trek to the North Pole and just sat at home watching "The Santa Clause" and then reckoned they knew it all.
Luckily no harm came to Christmas 2018.

Good news is, Santa's been in touch and the additional requirements for this year are:

1. *I don't want to retype all the bloomin' letters.*
1. *I'd like to send presents to naughty children*.

![Raymond Brigg's Father Christmas][4]

## The Problem

This year I'm going to walk through how you can solve Santa's problem using something I've recently
began playing with - [FParsec][5].

> FParsec is parser combinator library for F#.

I'd describe it as: a library that lets you write a parser by combining functions.

This is only my second go at using it, my first was to solve [Mike Hadlow's "Journeys" coding challenge][6].
So this might not be the most idiomatic way to write a parser.

We'll assume that Santa has bought some off the shelf OCR software and has scanned in some Christmas lists into
a text file.

### Example

```plain

Alice: Nice
 - Bike
 - Socks * 2

Bobby: Naughty
 - Coal

Claire:Nice
 -Hat
- Gloves  * 2
 -   Book

Dave : Naughty
- Nothing

```

As you can see the OCR software hasn't done too well with the whitespace. We need a parser that is able
to parse this into some nice F# records and handle the lack of perfect structure.

### Domain

When writing solutions in F# I like to model the domain first:

```fsharp
module Domain =
    type Behaviour = Naughty | Nice

    type Gift = {
        Gift: string
        Quantity: int
    }

    type Child = {
        Name: string
        Behaviour: Behaviour
        Gifts: Gift list
    }
```

First the `Behaviour` is modelled as a discriminated union: either `Naughty` or `Nice`.

A record for the `Gift` holds the name of a gift and the quantity.

The `Child` record models the name of the child, their behaviour and a list of gifts they are getting.
The overall output of a successfully parsing the text will be a list of `Child` records.

### Parsing

Initially I thought it would be a clever idea to parse the text directly into the domain model. That didn't work
out so, instead I defined my own [AST][7] to parse into, then later map that into the domain model.

```fsharp
type Line =
    | Child of string * Domain.Behaviour
    | QuantifiedGift of string * int
    | SingleGift of string
```

A `Child` line represents a child and their `Behaviour` this year. A `QuantifiedGift` represents a gift that was specified
with a quantity (e.g. "Bike * 2") and a `SingleGift` represents a gift without a quantity.

Modelling this way avoids putting domain logic into your parser - for example, what is the quantity of a single gift?
It might seem trivial, but the less the parser knows about your domain the easier it is to create.

Before we get into the actual parsing of the lines, there's a helper I added called `wsAround`:

```fsharp
open FParsec

let wsAround c =
    spaces >>. skipChar c >>. spaces
```

This is a function that creates a parser based on a single character `c` and allows the character `c` to be
surrounded by whitespace (`spaces` function). The `skipChar` function says that I don't care about
parsing the value of `c`, just that `c` has to be there. I'll go into the `>>.` later on, but it is one of
FParsec's custom operators for combining parsers.

So `wsAround ':'` lets me parse `:` with potential whitespace either side of it.

It can be used as part of parsing any of the following:

```plain
a : b
a:b
a:    b
```

And as the examples above show, there are a few places where we don't care about whitespace either side of a separator:

- Either side of the `:` separating the name and behaviour.
- Before/after the `-` that precedes either types of gift.
- Either side of the `*` for quantified gifts.

#### Parsing Children

A child line is defined as "a name and behaviour separated by a `:`".

For example: `Dave : Nice`

And as stated above, there can be any amount (or none) of whitespace around the `:`.

The `pName` function defines how to parse a name:

```fsharp
let pName =
    let endOfName = wsAround ':'
    many1CharsTill anyChar endOfName |>> string
```

`many1CharsTill` is a parser that runs two other parsers. The first argument is the parser it will look
for "many chars" from, the second argument is the parser that tells it when to stop.

Here it parses any character using `anyChar` until it reaches the `endOfName` parser, which is a function that looks for
`:` with whitespace around it.

The result of the parser is then converted into a `string` using the `|>>`
operator.

The `pBehaviour` function parses naughty or nice into the discriminated union:

```fsharp
let pBehaviour =
    (pstringCI "nice" >>% Domain.Nice)
    <|>
    (pstringCI "naughty" >>% Domain.Naughty)
```

This defines 2 parsers, one for each case, and uses the `<|>` operator to choose between them.
`pstringCI "nice"` is looking to parse the string `nice` case-insensitive and then the `>>%` operator discards the
parsed string and just returns `Domain.Nice`.

These 2 functions are combined to create the `pChild` function that can parse the full line of text into a `Child` line.

```fsharp
let pChild =
    let pName = //...
    let pBehaviour = //...

    pName .>>. pBehaviour |>> Child
```

`pName` and `pBehaviour` are combined with the `.>>.` operator to create a tuple of each parsers result, then the result
or that is passed to the `Child` line constructor by the `|>>` operator.

#### Parsing Gifts

Both gifts make use of the `startOfGiftName` parser function:

```fsharp
let startOfGiftName = wsAround '-'
```

A single gift is parsed with:

```fsharp
let pSingleGift =
    let allTillEOL = manyChars (noneOf "\n")
    startOfGiftName >>. allTillEOL |>> SingleGift
```

The `allTillEOL` function was taken from [this StackOverflow answer][8] and parses everything up to the end of a line.

This is combined with `startOfGiftName` using the `>>.` operator, which is similar to the `.>>.` operator, but in this case
I only want the result from the right-hand side parser - in this case the `allTillEOL`, this is then passed into the `SingleGift`
union case constructor.

A quantified gift is parsed with:

```fsharp
let pQuantifiedGift =
    let endOfQty = wsAround '*'
    let pGiftName =
        startOfGiftName >>. manyCharsTill anyChar endOfQty
    pGiftName .>>. pint32 |>> QuantifiedGift
```

This uses `endOfQty` and `pGiftName` combined in a similar way to the `pName` in `pChild`. Parsing all characters up until the
`*` and only keeping the name part.

`pGiftName` is combined with `pint32` with the `.>>.` function to get the result of both parsers in a tuple and is fed into the
`QuantifiedGift` union case.

#### Putting it all together

The top level parser is `pLine` which parses each line of the text into one of the cases from the `Line` discriminated union.

```fsharp
let pLine =
    attempt pQuantifiedGift
    <|>
    attempt pSingleGift
    <|>
    pChild
```

This uses the `<|>` that was used for the `Behaviour`, but it also requires the `attempt` function before the first two parsers.
This is because these parsers consume some of the input stream as they execute. Without the `attempt` it would start on
a quantified gift, then realise it is actually a single gift and have no way to go into the next choice.
Using `attempt` allows the parser to "rewind" when it has a problem - like a quantified gift missing a `*`.

If you want to see how this works, you need to decorate your parser functions with the `<!>` operator that is defined [here][9].
This shows the steps the parser takes and allows you to see that it has "gone the wrong way".

Finally a helper method called `parseInput` is used to parse the entire file:

```fsharp
let parseInput input =
    run (sepBy pLine newline) input
```

This calls the `run` function passing in a `sepBy` parser for each `pLine` separated by a `newline`. This way each line is processed on it's own.

That is the end of the parser module.

### Mapping to the Domain

The current output of `parseInput` is a `ParserResult<Line list, unit>`. Assuming success there is now a list of `Line` union cases
that need to be mapped into a list of `Child` from the domain.

These have separate structures:

- A `Child` record is hierarchical - it contains a list of `Gift`s.
- The list of `Line`s has structure defined by the order of elements, `Gift`s follow the `Child` they relate to.

Initially I thought about using a `fold` to go through each line, if the line was a child, add a child to the head of
the results, if the line was a gift add it to the head of the list of gifts of the first child in the list, this was the code:

```fsharp
let folder (state: Child list) (line : Line) : Child list =

    let addGift nm qty =
        let head::tail = state
        let newHead = { head with Gifts = {Gift = nm; Quantity = qty; } :: head.Gifts; }
        newHead :: tail

    match line with
    | Child (name, behaviour) -> { Name = name; Behaviour = behaviour; Gifts = []; } :: state
    | SingleGift name -> addGift name 1
    | QuantifiedGift (name, quantity) -> addGift name quantity
```

This worked, but because F# lists are implemented as singly linked lists you add to the head of the list instead of the tail. This
had the annoying feature that the `Child` items were revered in the list - not so bad, but then the list of gifts in each child was backwards too.
I could have sorted both lists, but it would require recreating the results as the lists are immutable and I wanted to keep to idiomatic F# as
much as I could.

A `foldBack` on the other hand works backwards "up" the list, which meant I could get the results in the order I wanted, but there
was a complication. When going forward, the first line was always a child, so I always had a child to add gifts to. Going backwards
there is just gifts until you get to a child, so you have to maintain a list of gifts, until you reach a child line, then you can
create a child assign the gifts, then clear the list.

This is how I implemented it:

```fsharp
module Translation =

    open Domain
    open Parser

    let foldLine line state = //Line -> Child list * Gift list -> Child list * Gift list

        let cList, gList = state

        let addChild name behaviour =
            { Name = name; Behaviour = behaviour; Gifts = gList; } :: cList

        let addGift name quantity =
            { Gift = name; Quantity = quantity; } :: gList

        match line with
        | Child (name, behaviour) -> addChild name behaviour, []
        | SingleGift name -> cList, addGift name 1
        | QuantifiedGift (name, quantity) -> cList, addGift name quantity
```

The `state` is a tuple of lists, the first for the `Child list` (the result we want) and the second for keeping track of the gifts
that are not yet assigned to children.

First this function deconstructs `state` into the child and gift lists - `cList` and `gList` respectively.

Next I've declared some helper functions for adding to either the `Child` or `Gift` list:

- `addChild` creates a new `Child` with the `Gifts` set to the accumulated list of Gifts (`gList`) and prepends it onto `cList`.
- `addGift` creates a new `Gift` and prepends it onto `gList`.

Then the correct function is called based on the type of Line.

- Children return a new `Child list` with a *Empty* `Gift list`.
- The gifts return the existing `Child list`, with the current item added to the `Gift list`.

The overall result is a tuple of all the `Child` records correctly populated, and an empty list of `Gift` records, as the last item will be the
first row and that will be a `Child`.

```fsharp
let mapLinesToDomain lines = //ParserResult<Line list, unit> -> Child list
    let initState = [],[]

    let mapped =
        match lines with
        | Success (lines, _, _) -> Seq.foldBack foldLine lines initState
        | Failure (err, _, _) -> failwith err

    fst mapped
```

Finally, the output of `parseInput` can be piped into `mapLinesToDomain` to get the `Child list` we need:

```fsharp
let childList =
    Parser.parseInput input  //Input is just a string from File.ReadAllText
    |> Translation.mapLinesToDomain
```

## Summing up

I really like how simple parsers can be once written, but it takes some time to get used to how they work
and how you need to separate the parsing and domain logic.

My main pain points were:

- Trying to get the domain model in the parser - adding Gifts to Children, setting default quantity to 1, etc resulted
in a lot of extra code. Once I stopped this and just focussed on mapping to the AST it was much simpler. Another benefit
was not having to map things into Records, just using tuples and discriminated unions allowed a much cleaner implementation.
- Not knowing about using `attempt`, I just assumed `<|>` worked like pattern matching, turns out, it doesn't.

I made heavy use of the F# REPL and found it helped massively as I worked my way through writing each parser and then combining
them together. For example, I first wrote the Behaviour parser and tested it worked correctly on just "Naughty" and "Nice".
Then I wrote a parser for the Child's name and `:` and tested it on "Dave : Nice", but only getting the name.
Then I could write a function to combine the two together and check that the results were correct again. The whole development
process was done this way, just add a bit more code, bit more example, test in the REPL and repeat.

The whole code for this is on [GitHub][10] - it is only 115 lines long, including code to print the list of Children
back out so I could see the results.

 [1]: https://sergeytihon.com/2019/11/05/f-advent-calendar-in-english-2019/
 [2]: {{site.url}}/blog/santas-xmas-list-in-fable/
 [3]: https://xmaslist.s3-eu-west-1.amazonaws.com/index.html
 [4]: {{site.contenturl}}xmas-2019-father-xmas.png
 [5]: https://www.quanttec.com/fparsec/
 [6]: https://twitter.com/xdaDaveShaw/status/1189683003074760716
 [7]: https://en.wikipedia.org/wiki/Abstract_syntax_tree
 [8]: https://stackoverflow.com/a/4252829/383710
 [9]: https://www.quanttec.com/fparsec/users-guide/debugging-a-parser.html#tracing-a-parser
 [10]: https://github.com/xdaDaveShaw/xmas-list-parser
