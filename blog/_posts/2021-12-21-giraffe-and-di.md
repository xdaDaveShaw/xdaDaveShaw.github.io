---
layout: post
status: publish
published: true
title: Giraffe and Dependency Injection
date: '2021-11-21 09:00:00 +0000'
date_gmt: '2021-11-21 09:00:00 +0000'
categories:
- FSharp
- Xmas
---

# TODO
- Rename article
- Proof read
- Fix Linting complaints
- Update Date

> This post is part of the [F# Advent Calendar 2021][adv]. Many thanks to Sergey Tihon for organising these.
> Go checkout the other many and excellent posts.

## Giraffe and Dependency Injection

This year, I've run out of Xmas themed topics. Instead, I'm just sharing a few tips
from a recent project I've been working on.

I'm going to show...

 - Dev Containers for F# Development
 - A simple Giraffe Web Server
 - Automated HTTP Tests
 - Working with ASP.Net dependencies

### Dev Containers

[Dev Containers][dc] are a feature of VS Code I was introduced to earlier this year and have since taken to using
in all my projects.

They allow you to have a self contained development environment in DockerFile, including all the dependencies your
application requires and extensions for Visual Studio Code.

If you have ever looked at the amount of things you have installed for various projects and wondered where it all came
from and if you still need it - Dev Containers solves that problem. They also give you a very simple way to share things
with your collaborators, no longer do I need a 10-step installation guide in a Readme file. 
Once you are setup for Dev Containers, getting going with a project that uses them is easy.

This blog is a GitHub Pages Site, and to develop and test it locally I had to install Ruby and a bunch of Gems, and 
Installing those on Windows is tricky at best.
VS Code comes with some pre-defined Dev Container templates, so I just used the Jekyll one, and now I don't have to
install anything on my PC.

### Dev Container for .NET

To get started, you will need WSL2 and the [Remote Development Tools pack][rd] VS Code extension installed.

Then it just a matter of launching VS Code from in my WSL2 instance:

```sh
cd ~/xmas-2021
code .
```

Now in the VS Code **Command Palette** I select **Remote Containers: Add Development Container Configuration Files...**
A quick search for "F#" helps get the extensions I need installed. In this case I just picked the defaults.

Once the DockerFile was created I changed the `FROM` to use the standard .NET format that Microsoft uses (the F# template
may have changed by the time you read this) to pull in the latest .NET 6 Bullseye base image.

**Before**

```docker
FROM mcr.microsoft.com/vscode/devcontainers/dotnet:0-5.0-focal
```

**After**

```docker
# [Choice] .NET version: 6.0, 5.0, 3.1, 6.0-bullseye, 5.0-bullseye, 3.1-bullseye, 6.0-focal, 5.0-focal, 3.1-focal
ARG VARIANT=6.0-bullseye
FROM mcr.microsoft.com/vscode/devcontainers/dotnet:0-${VARIANT}
```

VS Code will then prompt to Repen in the Dev Container, selecting this will relaunch VS Code and build the docker file. 
Once complete, we're good to go.

### Creating the Projects

Now that I'm in VS Code, using the Dev Container, I can run `dotnet` commands against the terminal inside VS Code. This is
what I'll be using to create the skeleton of the website:

```sh
# install the template
dotnet new -i "giraffe-template::*"

# create the projects
dotnet new giraffe -o site
dotnet new xunit --language f# -o tests

# create the sln
dotnet new sln
dotnet sln add site/
dotnet sln add tests/

# add the reference from tests -> site
cd tests/
dotnet add reference ../site/
cd ..
```

I also update the projects target framework to net6.0 as the templates defaulted to net5.0.

For the `site/` I updated to the latest giraffe 6 pre-release (alpha-2 as of now) and removed the reference to `Ply`
which is no longer needed.

That done I could run the site and the tests from inside the dev container:

```sh
dotnet run --project site/

dotnet test
```

Next, I'm going to rip out most of the code from the Giraffe template, just to give a simpler site to play with.

Excluding the `open`'s it is only a few lines:

```fsharp
let demo = 
    text "hello world"

let webApp =
    choose [
        GET >=>
            choose [
                route "/" >=> demo
            ] ]

let configureApp (app : IApplicationBuilder) =
    app.UseGiraffe(webApp)

let configureServices (services : IServiceCollection) =
    services.AddGiraffe() |> ignore

[<EntryPoint>]
let main args =
    Host.CreateDefaultBuilder(args)
        .ConfigureWebHostDefaults(
            fun webHostBuilder ->
                webHostBuilder
                    .Configure(configureApp)
                    .ConfigureServices(configureServices)
                    |> ignore)
        .Build()
        .Run()
    0
```

I could have trimmed it further, but I'm going to use some of the constructs later.

When run you can perform a `curl localhost:5000` against the site and get a "hello world" response.

### Testing

I wanted to try out [self-hosted tests][sh] against this API, so that I'm performing real HTTP calls
and mocking as little as possible.

As Giraffe is based on ASP.NET you can follow the same process as you would for testing as ASP.NET application.

You will need to add the TestHost package to the tests project:

```
dotnet add package Microsoft.AspNetCore.TestHost
```

You can then create a basic XUnit test like so:

```fsharp
let createTestHost () =
  WebHostBuilder()
    .UseTestServer()
    .Configure(configureApp)    // from the "Site" project
    .ConfigureServices(configureServices)   // from the "Site" project
    
[<Fact>]
let ``First test`` () =
    task {
        use server = new TestServer(createTestHost())
        use msg = new HttpRequestMessage(HttpMethod.Get, "/")

        use client = server.CreateClient()
        use! response = client.SendAsync msg
        let! content = response.Content.ReadAsStringAsync()

        let expected = "hello test"
        Assert.Equal(expected, content)
    }
```

If you `dotnet test`, it should fail because the tests expects "hello test" instead of "hello world".
However, you have now invoked your Server from your tests.

### Dependencies

With this approach you can configure the site's dependencies how you like, but as an example 
I'm going to show two different types of dependencies:

1. App Settings
1. Service Lookup

#### App Settings

Suppose your site relies on settings from the "appsettings.json" file, but you want to test with a different
value.

Let's add an app settings to the Site first, then we'll update the tests...

```json
{
    "MySite": {
        "MyValue": "100"
    }
}
```

I've removed everything else for the sake of brevity.

We need to make a few minor changes to the `demo` function and also create a new type to represent the settings

```fsharp
[<CLIMutable>]
type Settings = { MyValue: int }

let demo = 
    fun (next : HttpFunc) (ctx : HttpContext) ->

        let settings = ctx.GetService<IOptions<Settings>>()

        let greeting = sprintf "hello world %d" settings.Value.MyValue
        text greeting next ctx
```

And we need to update the `configureServices` function to load the settings:

```fsharp
let serviceProvider = services.BuildServiceProvider()
let settings = serviceProvider.GetService<IConfiguration>()
services.Configure<Settings>(settings.GetSection("MySite")) |> ignore
```

If you run the tests now, you get "hello world 0" returned.

However, if you `dotnet run` the site, and use `curl` you will see `hello world 100` returned.

This proves the configuration is loaded and read, however, it isn't used by the tests - because the 
`appsettings.json` file isn't part of the tests. You could copy the file into the tests and that would solve the problem,
but if you wanted different values for the tests you could create your own appsettings.json file for the tests

```json
{
    "MySite": {
        "MyValue": "3"
    }
}
```

To do that we need function that will load the test configuration, and the add it into the pipeline for creating
the TestHost:

```fsharp
let configureAppConfig (app: IConfigurationBuilder) =
  app.AddJsonFile("appsettings.tests.json") |> ignore
  ()

let createTestHost () =
  WebHostBuilder()
    .UseTestServer()
    .ConfigureAppConfiguration(configureAppConfig)   // Use the test's config
    .Configure(configureApp)    // from the "Site" project
    .ConfigureServices(configureServices)   // from the "Site" project
```

Note: you will also need to tell the test project to include the `appsettings.tests.json` file.

```xml
<ItemGroup>
    <Content Include="appsettings.tests.json" CopyToOutputDirectory="always" />
</ItemGroup>
```

If you would like to use the same value from the config file in your tests you can access it via the test server:


```fsharp
let config = server.Services.GetService(typeof<IConfiguration>) :?> IConfiguration

let expectedNumber = config["MySite:MyValue"] |> int

let expected = sprintf "hello world %d" expectedNumber
```

#### Services

In F# it's nice to keep everything pure and functional, but sooner or later you will realise you need to interact with
the outside world, and when testing from the outside like this, you may need to control those things.

Here I'm going to show you the same approach you would use for a C# ASP.NET site - using the built in dependency
injection framework.

```fsharp
type IMyService =
    abstract member GetNumber : unit -> int

type RealMyService() =
    interface IMyService with
        member _.GetNumber() = 42

let demo = 
    fun (next : HttpFunc) (ctx : HttpContext) ->

        let settings = ctx.GetService<IOptions<Settings>>()
        let myService = ctx.GetService<IMyService>()

        let configNo = settings.Value.MyValue
        let serviceNo = myService.GetNumber()

        let greeting = sprintf "hello world %d %d" configNo serviceNo
        text greeting next ctx
```

I've create a `IMyService` interface and a class to implement it `RealMyService`.

Then in `configureServices` I've added it as a singleton:

```fsharp
services.AddSingleton<IMyService>(new RealMyService()) |> ignore
```

Now the tests fail again because `42` is appended to the results.

To make the tests pass, I want to pass in a mocked `IMyService` that has a number that I want.

```fsharp
let luckyNumber = 8

type FakeMyService() =
    interface IMyService with
        member _.GetNumber() = luckyNumber

let configureTestServices (services: IServiceCollection) = 
  services.AddSingleton<IMyService>(new FakeMyService()) |> ignore
  ()

let createTestHost () =
  WebHostBuilder()
    .UseTestServer()
    .ConfigureAppConfiguration(configureAppConfig)   // Use the test's config
    .Configure(configureApp)    // from the "Site" project
    .ConfigureServices(configureServices)   // from the "Site" project
    .ConfigureServices(configureTestServices) // mock services after real ones
```

Then in the tests I can expect the `luckyNumber`:

```fsharp
let expected = sprintf "hello world %d %d" expectedNumber luckyNumber
```

And everything passes.

## Conclusion

TODO: MORE

You can see the full source code for this blog post [here][gh].

 [adv]: https://sergeytihon.com/2021/10/18/f-advent-calendar-2021/
 [rd]: https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack
 [dc]: https://code.visualstudio.com/docs/remote/containers
 [bl]: https://github.com/xdaDaveShaw/xdaDaveShaw.github.io
 [sh]: https://blog.ploeh.dk/2021/01/25/self-hosted-integration-tests-in-aspnet/
 [gh]: https://github.com/xdaDaveShaw/xmas-2021