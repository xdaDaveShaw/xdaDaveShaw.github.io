


## Summary

I've read many many articles on unit testing and the approaches other people take
to writing and describing their preferred approach to testing. I'm going to describe
the approach I take when writing and testing code.

This is an approach I've taken on a number of complex projects, and it mostly focuses
on back-end development and API's as opposed to UI development. It may not be suitable
for all solutions and your mileage may vary.

## Introduction

As many others have come to realise, defining a "unit" test is hard, some people swear it
should only test one class, some people just mean anything with a `[TestMethod]` attribute.

I'm going to avoid describing anything that would be considered a "slow" test, this is purely
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

- Run locally
- Run Fast
- Are deterministic
- Test your code

## Writing Tests

Within the category of "fast" tests I us