---
layout: post
status: draft
published: false
title: Handling results from complex operations
date: '2017-03-28 10:20:00 +0100'
date_gmt: '2017-03-28 10:20:00 +0100'
categories:
- C#
---

In this article I am going to look at a number of different approaches to model the results of a complex operation in C#.

I'll be using the following logic in all my scenarios:

``` c
if length(s) is even
    return length(s);
else
    return "Length is odd";
```

And there is a requirement for exception handling too, all errors in the complex operation are to be captured and returned.

This is actually something I have had to implement at work in a number of cases.
I want to try an operation, then depending on the outcome handle it in the most appropriate way.

In the examples I'll be using `Console.WriteLine` for simplicity, but in the real world there could be database
calls, UI updates, HTML rendering, service calls, whatever makes testing hard.

The inputs to and outputs from every example will be the same.

Inputs:

- `"Food"` (returns *4*)
- `"Foo"` (returns *Length is odd.*)
- `null` (returns *NullReferenceException*)

# 1. Just do it

Here's the most trivial approach to solve the issue:

``` csharp
void Main()
{
    ComplexOperation("Food");
    ComplexOperation("Foo");
    ComplexOperation(null);
}

void ComplexOperation(String input)
{
    try
    {
        if (input.Length % 2 == 0)
            Console.WriteLine($"Even length: {input.Length}.");
        else
            Console.WriteLine("Length is odd.");
    }
    catch (Exception ex)
    {
        Console.WriteLine(ex);
    }
}
```

OK, this meets our requirements, but lets see if we can see a few issues with it.

Firstly, it isn't possible to test the Complex Operation on it's own, you have no way to mock out the dependencies.
Secondly, you're mixing business logic, with side effects. Readers of Mark Seemann's [blog][1] will know that this
makes code harder to reason about.

A common approach to solve this is to introduce a type to model the result of the complex operation. The remaining
examples look at different approaches to do this.

# 2. Implicit Results

Let's start with an Implicit Result type:

``` csharp
class Result
{
    public String FailureMessage { get; set;}
    public Int32? EvenLength { get; set; }
    public Exception Error { get; set;}
}
```

I call it Implicit because if I passed you an instance of it, you have no obvious way of knowing what the result is,
or how to figure out what happened. You could check that `EvenLength` is not null and assume success, but what's to
say I didn't put set it to `0` and populate `FailureMessage`.

Here's the complex operation:

``` csharp
void Main()
{
    var inputs = new[] { "Food", "Foo", null, };

    foreach (var result in inputs.Select(ComplexOperation))
    {
        if (result.Error != null)
            Console.WriteLine(result.Error);
        else if (result.FailureMessage != null)
            Console.WriteLine(result.FailureMessage);
        else
            Console.WriteLine($"Even length: {result.EvenLength}.");
    }
}

Result ComplexOperation(String input)
{
    try
    {
        if (input.Length % 2 == 0)
            return new Result { EvenLength = input.Length, };
        else
            return new Result { FailureMessage = "Length is odd.", };
    }
    catch (Exception ex)
    {
        return new Result { Error = ex, };
    }
}
```

Now you see the implementation you know there is no funny business, but I made you read the complex operation to be sure.

There are some other problems with this too. The type is mutable, meaning something might change the result after the operation.
When the type is constructed, it is half-full, some members will have values, some won't. You have to know how to process a
result, I'd find myself asking *can an error also have a message?*. This also violates the [Open/closed principle][2] because
changes to Success, Failure or Error require a change to this one type.

This does, however, separate the operation from the outputs, making the operation testable without it needing any *additional*
depencies for the output. The operation is now Pure, which is why I'm using `Select` on each input to return the result.

# 3. Explicit Results

I've harped on enough about how bad it it that the result is implied in the previous example. So let's have a go at been
more explicit.

Here's a result type with an enum to tell you what happened:

``` csharp
class Result
{
    public String FailureMessage { get; set;}
    public Int32? EvenLength { get; set; }
    public Exception Error { get; set; }
    public ResultType Type { get; set; }
}

enum ResultType
{
    Success,
    Failure,
    Error,
}
```

Now when you get a result you can first check the `Type` and know it is an error.

Here's the application code for it:

``` csharp
void Main()
{
    var inputs = new[] { "Food", "Foo", null, };

    foreach (var result in inputs.Select(ComplexOperation))
    {
        switch (result.Type)
        {
            case ResultType.Success:
                Console.WriteLine($"Even length: {result.EvenLength}.");
                break;
            case ResultType.Failure:
                Console.WriteLine(result.FailureMessage);
                break;
            case ResultType.Error:
                Console.WriteLine(result.Error);
                break;
        }
    }
}

Result ComplexOperation(String input)
{
    try
    {
        if (input.Length % 2 == 0)
            return new Result { EvenLength = input.Length, Type = ResultType.Success, };
        else
            return new Result { FailureMessage = "Length is odd.", Type = ResultType.Failure, };
    }
    catch (Exception ex)
    {
        return new Result { Error = ex, Type = ResultType.Error, };
    }
}
```

This still has some of the problems of the previous version: mutability, Open/closed principle, mixed bag of properties, and not
knowing what to do with them. It also has the problem that nothing is forcing you to check the `Type`, I might just say
*It's OK, this won't fail, just get my the `EvenLength`* - famous last words...

So, whilst it is a little better, it can still lead to unreasonable code.

# 4. Explicit - with factory methods

To solve the problem of people creating a "mixed bag" of properties and them been mutable, a factory method could be created
on the type to initialise the result in the correct state depending on the outcome of the operation.

``` csharp
class Result
{
    public String FailureMessage { get; private set; }
    public Int32? EvenLength { get; private set; }
    public Exception Error { get; private set; }
    public ResultType Type { get; private set; }

    public static Result CreateFailure(String message)
    {
        return new Result { FailureMessage = message, Type = ResultType.Failure, };
    }

    public static Result CreateSuccess(Int32 value)
    {
        return new Result { EvenLength = value, Type = ResultType.Success, };
    }

    public static Result CreateError(Exception ex)
    {
        return new Result { Error = ex, Type = ResultType.Error, };
    }
}
```

This changes the complex operation to look like this:

``` csharp
Result ComplexOperation(String input)
{
    try
    {
        if (input.Length % 2 == 0)
            return Result.CreateSuccess(input.Length);
        else
            return Result.CreateFailure("Length is odd.");
    }
    catch (Exception ex)
    {
        return Result.CreateError(ex);
    }
}
```

The rest of the program is unchanged from the previous version.

We now have a way to know that the Result with the type success will only have an `EvenValue`, however we still need
to ignore the other properties that don't relate to success. There's still nothing forcing people to check the `Type`,
and this requires additional factory methods for every state.

I've seen a number of people stop at this level, and call it "good enough" to avoid having to go to the next level.
You still have unreasonable code, and have to understand things in the operation.

# 5. Type per Result

I've now harped one enough about not knowing what to do with results. This example removes the ambiguity and uses a
separate type for each result.

``` csharp
class Success : Result
{
    public Int32 EvenLength { get; }
    public Success(Int32 value) { EvenLength = value; }
}
class Failure : Result
{
    public String FailureMessage { get; }
    public Failure(String message) { FailureMessage = message; }
}

class Error : Result
{
    public Exception Exception { get; }
    public Error(Exception ex) { Exception = ex; }
}

abstract class Result
{
}
```

Each result now has its own type. Each type only has properties relating to that type of result. The results are immutable.

The base class in this case is empty, but it might capture the input, elapsed time, or anything else you need in every result.

The program and complex operation now are much easier to reason about, and it is a lot harder to mix things up:

``` csharp
void Main()
{
    var inputs = new[] { "Food", "Foo", null, };

    foreach (var result in inputs.Select(ComplexOperation))
    {
        switch (result)
        {
            case Success s:
                Console.WriteLine($"Even length: {s.EvenLength}.");
                break;
            case Failure f:
                Console.WriteLine(f.FailureMessage);
                break;
            case Error e:
                Console.WriteLine(e.Exception);
                break;
        }
    }
}

Result ComplexOperation(String input)
{
    try
    {
        if (input.Length % 2 == 0)
            return new Success(input.Length);
        else
            return new Failure("Length is odd.");
    }
    catch (Exception ex)
    {
        return new Error(ex);
    }
}
```

I'm using C# 7's [Pattern Matching][3] feature in the program to compare each type of the result. When I get a match it is already
cast into the correct type, so `s` will be an instance of `Success`, and `Success` only has properties relating to a successful outcome.

To me this is very clear what I can do next after a complex operation and what happened in the operation.

I do use this in places where I feel it is suitable. It is reassuring to know
that if I have a `Success` type I can only see properties relating to a successful operation, I can pass the result to another method,
that accepts an instance of `Success` knowing it can't be called with an `Error` by mistake - the type safety in the language is
on your side.

Consider these 2 methods:

```csharp
void DisplaySuccess(Result r) { }
void DisplaySuccess(Success s) { }
```

In all previous examples you had to have the first version, and that would either assume you called it correctly, or would have to
check that `r` is a success. The second method can only be called with an instance of `Success`, you cannot pass an `Error` to it,
making it much harder to get wrong.

There are a few negatives to this approach, in C#'s pattern matching the compiler doesn't check you have every case matched, adding a new result type means I need to find all instances of result handlers and update them. If you have only one handler, then this isn't so bad.

Another consideration is that the result's "next step" logic - what happens next - is separated from the type.
Sometimes this could be desirable, other times you might want it contained in a single place, it depends on how your application
is designed and what works best. The next exmaple looks at keeping the behaviour with the result.

# 6. Types with Behaviour

I've fleshed the following code out a little more, to highlight one of the drawbacks of the approach.
In all previous examples, I've left out how you might test the entire operation - passing in test doubles
for `Console.WriteLine` into the program from the composition root would be trivial. 

However, in this case I wanted to show the extra effort needed to keep things testable.

First, we'll look at the base result type:

``` csharp
abstract class Result
{
    public Result(IProcessor processor)
    {
        Processor = processor;
    }

    protected IProcessor Processor { get;}

    public abstract void Process();
}

interface IProcessor
{
    void WriteMessage(Object message);
}

class Processor : IProcessor
{
    public void WriteMessage(Object message) => Console.WriteLine(message);
}
```

There's now an additional `Process` member on every result and every result needs access to a `IProcessor` which facilitates
the injection of the dependencies for the `Process` method.

This is what the calling program will use to handle the result:

``` csharp
void Main()
{
    var inputs = new[] { "Food", "Foo", null, };

    foreach (var result in inputs.Select(ComplexOperation))
    {
        result.Process();
    }
}
```

This looks very neat, I get a result, I call `Process`.

The problems are getting the dependencies managed in an nice way.
When deriving instances of the `Result` you need to write the code to pass `IProcessor` through:

``` csharp
class Success : Result
{
    public Int32 EvenLength { get; }
    public Success(IProcessor p, Int32 value) : base(p) { EvenLength = value; }
    public override void Process() => Processor.WriteMessage($"Even length: {EvenLength}.");
}

class Failure : Result
{
    public String FailureMessage { get; }
    public Failure(IProcessor p, String message) : base(p) { FailureMessage = message; }
    public override void Process() => Processor.WriteMessage(FailureMessage);
}

class Error : Result
{
    public Exception Exception { get; }
    public Error(IProcessor p, Exception ex) : base(p) { Exception = ex; }
    public override void Process() => Processor.WriteMessage(Exception);
}
```

Each result now has an implementation of the logic to handle it. If you want to know what happens given a success,
I can just look at the `Success` type.

But when you create an instance, you also need to pass in an `IProcessor`, so the complex operation will have to do this:

```csharp
IProcessor processor = new Processor();

Result ComplexOperation(String input)
{
    try
    {
        if (input.Length % 2 == 0)
            return new Success(processor, input.Length);
        else
            return new Failure(processor, "Length is odd.");
    }
    catch (Exception ex)
    {
        return new Error(processor, ex);
    }
}
```

This is quite a lot of ceremony, and now the complex operation has knowledge of the `IProcessor`. An instance of an `IProcessor` would
have to be injected so that it can be passed into each result. The complex operation doesn't depend on `IProcessor` though, just the
results, making this a kind of transient dependency.

This example isn't perfect, but I have used it in a number of places where I wanted to keep the logic of what
to do with a result with the result, and not separated out across the code base. Usually when there's a lot of code
related to handling the result.

I also like that I am able to write code such as:

``` csharp
var result = ComplexOperation(input);
resut.Process();
```

It is nice to be able to look at all result handling in one place. If you need to add a new result, type (e.g. Timeout) you can do so by
just deriving a new type from `Result` and implementing all the logic there. The only other place that needs a change is the
complex operation to return `new Timeout(processor)`, the program doesn't have to change.

# 7. Exceptions for control flow

This is another approach I have seen used, I do not like it, but I thought I would include it, as I *almost* used it
years ago before using one of the above.

``` csharp
void Main()
{
    var inputs = new[] { "Food", "Foo", null, };

    foreach (var input in inputs)
    {
        try
        {
            var result = ComplexOperation(input);
            Console.WriteLine($"Even length: {result}.");
        }
        catch (BusinessException be)
        {
            switch (be)
            {
                case FailureException f:
                    Console.WriteLine(f.Message);
                    break;
                case ErrorException e:
                    Console.WriteLine(e.InnerException);
                    break;
                default:
                    throw;
            }
        }
    }
}

Int32 ComplexOperation(String input)
{
    try
    {
        if (input.Length % 2 == 0)
            return input.Length;
        else
            throw new FailureException("Length is odd.");
    }
    catch (Exception ex) when (!(ex is BusinessException))
    {
        throw new ErrorException(ex);
    }
}

class FailureException : BusinessException
{
    public FailureException(String message) : base(message) { }
}

class ErrorException : BusinessException
{
    public ErrorException(Exception inner) : base(inner) { }
}

abstract class BusinessException : Exception
{
    public BusinessException(String message) : base(message) { }
    public BusinessException(Exception inner) : base("Something bad happened", inner) { }
}
```

I've introduced the concept of a `BusinessException` that the program will handle in a `try...catch` block.
All problems in the complex operation will throw some sort of exception derived from `BusinessException`,
which the program will then type match on. I've used pattern matching again, but I've see other approaches such
as a `Dictionary<Exception, Action<Exception>>` that has a list of exceptions and the delegate to call.

Using exceptions like this is the equivelent of `goto`, many people have said it before, so I won't go into detail on
that aspect. I did notice when writing this how hard it is to not accidentally catch your own `BusinessException`, this
is why I have an exception filter to not handle them twice: `catch (Exception ex) when (!(ex is BusinessException))`. I
could imagine the case where one stray `try...catch` could cause a lot of problems.

# 8. Bonus F# version

I am a big fan of F# so I thought I would model the same problem in F#.

I've deliberately kept it similar to the C# examples to avoid it getting too functional. This is quite close
to example #5 above.

``` fsharp
type Result =
    | Success of int
    | Failure of string
    | Error of Exception

//Unchecked.defaultof<String> is used for null to make it crash - F# doesn't do null really.
let inputs = [ "Food"; "Foo"; Unchecked.defaultof<String>; ]

let complexOp (input: string) =
    try
        if input.Length % 2 = 0 then
            Success input.Length
        else
            Failure "Length is odd."
    with
    | ex -> Error ex

let processResult r =
    match r with
    | Success s -> printfn "Even length: %d" s
    | Failure f -> printfn "%s" f
    | Error e -> printfn "%A" e

let main () =
    let results =
        inputs
        |> Seq.map complexOp

    results |> Seq.iter processResult

main ()
```

I've modelled the result as a [Discriminated Union][4] with 3 cases, one for each outcome. The complex operation, like the
C# version returns one of these 3 cases. What is nice in F# is that in `processResult` where I take in a single result
and handle it, the pattern match must be complete. If I added another case to the `Result` type, the compiler will complain
that is isn't handled in the `match`.

# Conclusion

This won't be an exhaustive list of ways to handle results, but it does provide some different approaches to the problem
that should help keep your code base a little cleaner. Options 5 and 6 are ones I would use in C#, the rest create
unreasonable code that I would not like to have to think about. The complex operation is never going to be a few lines
of code like below, it might be many classes working to do many different operations, building a final result. I like it
when I don't have to know the operation to know what the behaviour is for a given outcome.

  [1]: http://blog.ploeh.dk/2017/02/02/dependency-rejection/
  [2]: https://en.wikipedia.org/wiki/Open/closed_principle
  [3]: https://docs.microsoft.com/en-us/dotnet/csharp/whats-new/csharp-7#pattern-matching
  [4]: https://docs.microsoft.com/en-us/dotnet/fsharp/language-reference/discriminated-unions