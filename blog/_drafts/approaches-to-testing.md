


## Summary

I've read many many articles on unit testing and the approaches that other people take
to writing and describing their preferred approach to testing. I'm going to describe
the approach I take when writing and testing code.

This is an approach I've taken on a number of complex projects, and it mostly focuses
on back-end development and API's as opposed to UI development. It may not be suitable
for all solutions and your mileage may vary.

## Introduction

As many others have come to realise, defining a "unit" test is hard. There are 2 extremes,
between testing one class and anything that has a `[TestMethod]` attribute,
and there's a full spectrum between.

I'm going to avoid describing anything that I would consider a "slow" test, this is purely
looking at "fast", deterministic tests that only test your code.

### "Slow" tests

Slow tests are what I categorise and tests that do the following (or similar):

- Use filesystem
- Use a database
- Use any external services over the network
- Performance tests

These all have their place, and I'm not dismissing them, I'm just focussing on the
day to day tests you write as you code.

### "Fast" tests

Fast tests are what I categorise as the opposite of the slow tests:

- Run Fast (obviously)
- Can Run locally
- Are deterministic
- Test *your* code

## Writing Tests

Within the category of "fast" tests I have a few categories.

### Traditional Test

A traditional test is the one that most jumps to mind after reading about unit testing.
It is a usually a test for a function that has a single responsibility.

Suitable code for this sort of testing could be:

- Algorithms - e.g. `List<T> -> List<T>`
- Simple Parsers - e.g. `String -> DTO`
- Validation - e.g. `Request -> Result<ValidRequest, ErrorMessage>`
- Decision node - e.g. `State, Option -> Boolean`

These tests are for code with a large number of inputs and the tests would exhaustively test
the code, with as many examples as possible.
For example, for a simple parser, the tests would cover every possible combination of input that is
available.

I would say that these are also suitable for [property based testing][propTest].

### Composite Test

A composite test is similar to a traditional test, but they now begin to focus on scenarios
by combining the "units" of the Traditional Test together. The tests should [specific][uncleBob], but
may also [test side effects][stateTesting].

Leaning on the above scenarios, these tests may test the functions for the interaction
between the Validation and a Decision Node.

For example the following code uses 2 functions `validateRequest` and `canProcessRequest` together.

```fsharp
let processRequest request state =
    match validateRequest request with
    | Ok r -> canProcessRequest r state
    | Error _ -> false
```

Assuming that both of these pure functions, but non-trivial and require a lot of tests,
then they would be covered by Traditional Tests.

A composite test would just test the scenarios from the composition of the 2 functions, up to a
possible 4 combinations:

|Request|State|
|-|-|
|OK|Processing allowed|
|OK|Processing not allowed|
|Error|Processing allowed|
|Error|Processing not allowed|

You could choose to write 3 tests, just one for Error, however, I would test all 4 possibilities
even though I know the implementation doesn't call it as I like to read my tests to know what my
code does and what tests I have.

In a composite test I am deliberately not testing the validation or "can process", both of which could
have 100's to possibilities. I will create 2 requests, one valid and one obviously invalid.
This is instead of creating test double, which I will come to later.

### Tests that don't need Traditional Tests, just start at the Composition Test
TODO

### When I Mock, and why I don't
TODO

 [propTest]: https://fsharpforfunandprofit.com/posts/property-based-testing/
 [uncleBob]:https://blog.cleancoder.com/uncle-bob/2017/10/03/TestContravariance.html
 [stateTesting]: https://blog.ploeh.dk/2019/02/18/from-interaction-based-to-state-based-testing/



 TODO:
 Think about writing all about parsers and how they combine?
