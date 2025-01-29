---
layout: post
status: publish
published: true
title: Using Dependabot to Maintain Docker Image Dependencies
date: '2025-01-29 20:27:00 +0000'
date_gmt: '2025-01-29 20:27:00 +0000'
image: https://imgs.xkcd.com/comics/dependency.png
categories:
- DevOps
- GitHub
---

One of the common challenges in modern software development, is keeping on 
top of your dependencies. 

There are many tools out there to help you wrangle your dependencies; if you use GitHub
you most likely have come across [Dependabot][gh-intro]. This post isn't an introduction to Dependabot. 

It presents a way to 
automatically maintain Docker image versions referenced by your infrastructure,
without giving up control of when those updates happen.

<figure>
  <img src="https://imgs.xkcd.com/comics/dependency.png" alt="XKCD 2347: Someday ImageMagick will finally break for good and we'll have a long period of scrambling as we try to reassemble civilization from the rubble."/>
  <figcaption>
    Image from <a href="https://xkcd.com/2347/">XKCD 2347</a> -
    Creative Commons Attribution-NonCommercial 2.5 License
  </figcaption>
</figure>

----

## Overview of Dependabot Docker

Dependabot already supports updating a large number of different types of dependencies,
including DockerFiles. You just need to add a [configuration][gh-docker] and it
will automatically raise pull requests when there is a new version of your
base Docker image.

For example, I might have a Docker image built from the base image `ubuntu:24.04`:


```dockerfile
# ./DockerFile
FROM ubuntu:24.04

WORKDIR /app
# COPY files/install things, etc
```

When a new version of the ubuntu image is released, I get a Pull Request...

```diff
-FROM ubuntu:24.04
+FROM ubuntu:24.10

WORKDIR /app
# COPY files/install things, etc
```

I can then review the Pull Request, read the release notes, check for any issues, 
and accept the new version of Ubuntu, if all is well.

This all works out of the box, but having a clear understanding of this will help
me explain the solution later.

## The Problem

When you host a container application, such as in AWS Elastic Container
Service (ECS) or Azure's Container Apps you can either host your own image from
your own repository (e.g. Elastic/Azure Container Registry), or reference an image
from a public registry such as Docker Hub / AWS Public ECR.

If you are building your application into a Docker image and running that image 
in a container service, you won't have this problem because you will be tagging
the image and instructing the container service to use it when you deploy a new
version.

For example, an abridged deployment might be:

1. Container Service Running `MyApp:v1`
1. Build and Publish `MyApp:v2` (e.g. docker build and push)
1. Instruct Container Service to run `MyApp:v2` (e.g. update via terraform)
1. Container Service Running `MyApp:v2`

However, there are cases where you are running some public image in your Container
Service. It might be [nginx][nginx] acting as a reverse proxy, or 
[fluentbit][fluentbit] in a sidecar configuration to provide advanced logging
capabilities.

In these cases you have two choices as to how you tell your container service
which image you would like:

1. Use the `latest` tag, e.g. `nginx:latest`
1. Use a specific version tag, e.g. `nginx:1.27-perl`

Both have their pros and cons:

| Approach     | Pros                               | Cons                         |
|--------------|------------------------------------|------------------------------|
| Latest tag   | Low maintenance, automatic updates | Lack of control over updates |
| Specific tag | Control over versions              | Requires manual updates      |

The tag you use will usually end up stored somewhere in your infrastructure as 
code. For example, for AWS ECS and Terraform you have it in your 
[ECS Task Definition JSON][td-json]:

```json
"containerDefinitions": [{
    "name": "nginx",
    "image": "public.ecr.aws/nginx/nginx:latest",
    "memory": 256,
    "etc": "etc",  
}]
```

If you are using the `latest` tag approach, you lose control of when your application
takes an updated version of the image. 

If there is a new `latest` tag of `nginx`
and that contains a critical problem, next time a new ECS Task is deployed you 
will get that problem in your application. 
You won't be able to rollback either, because it will still use the `latest` image.

If you are using a specific version tag, like `1.27-perl` you no longer get 
automatic updates. Instead, you have to remember 
to check for updates to `nginx` at regular intervals, and watch out for [CVEs][cve]
that might place your application at risk, and then go in and manually change the
version number.

The benefit of Dependabot is that it just tells you when there's a new version. 
Wouldn't it be good if you could still reference a specific version tag, but also
have Dependabot tell you when there is an update available via a Pull Request.

## The Solution

To get the best of both worlds you need a way for Dependabot to monitor a
specific version tag that is buried in your code. 
We already know Dependabot can maintain a base Docker image version.

> I'll continue the example assuming you are using AWS ECS and images from their
> public ECR. This should work fine for Azure and other Container Service Providers,
> as well as other Docker image Registries like DockerHub - so long as Dependabot
> supports the Image Registry.

First, we need to get the specific version tag out into a place where Dependabot
can deal with it.

### Fake Docker File

Start by creating a new folder for "3rd Party Images" and in there a folder for
each image tag. Then create a `DockerFile` referencing a specific tag.

```bash
# Create a new folder for 3rd Party Images and an nginx sub folder
mkdir -p ./third-party-docker-images/nginx/
# Change to that new folder
cd ./third-party-docker-images/nginx/
# Create a DockerFile
echo "FROM public.ecr.aws/nginx/nginx:1.27-perl" > DockerFile
```

This will leave you with a DockerFile like so:

```dockerfile
FROM public.ecr.aws/nginx/nginx:1.27-perl
```

This will be a "Fake DockerFile" who's only purpose is to be monitored and updated
by Dependabot. You don't need to do anything else with it, but adding some comments
or a readme file will help.

If you have other images, add another folder in `./third-party-docker-images/`
with another `DockerFile`.

### Configure Dependabot

Next [configure Dependabot][gh-docker] to keep an eye on a Fake DockerFile:

```yml
# ./.github/dependabot.yml

version: 2
updates:
  # Update nginx third party image
  - package-ecosystem: "docker"
    directory: "/third-party-docker-images/nginx/"
    schedule:
      interval: "weekly"
      
  # Lots of other dependencies to watch...
```

Whenever Dependabot runs it will raise a Pull Request if there is a newer
version of `nginx`.

### Wiring the Version

The next step is to get the image tag from the DockerFile so that you can 
reference it in your infrastructure as code.

Use whatever scripting language you are comfortable to read the file and
get the image tag:

Some examples in bash and PowerShell are below:

#### Bash

```bash
# Read the first line of the file
contents=$(head -n 1 ./DockerFile)

# Get the full image tag
imagetag=$(echo $contents | sed -E "s/FROM (.*)/\1/g")

# Get just the version
version=$(echo $contents | sed -E "s/FROM.*:(.*)/\1/g")
```

#### PowerShell 7

```powershell
# Read the first line of the file
$contents = Get-Content .\DockerFile -Head 1

# Get the full image tag
$imagetag = $contents.Split(" ")[1]

# Get just the version
$contents -match "FROM.*:(.*)"
$version = $Matches[1]
```

> These are **not** fool proof ways to parse DockerFiles, but work for simple
> examples. Your mileage may vary.

If your Task Definition is using the full image tag from a public Docker Registry
then you can just use the `$imagetag` variable and pass that into your Infrastructure
as code.

You just need some place in your deployment script to get the value of the image
tag and pass it into terraform:

e.g. 
```bash
export TF_VAR_nginx_image_tag="$imagetag"
#or
terraform plan -var 'nginx_image_tag=$imagetag'
```

And in your Task Definition JSON:

```terraform
"containerDefinitions": [{
    "name": "nginx",
    "image": "${var.nginx_image_tag}",
    "memory": 256,
    "etc": "etc",  
}]
```

### Using a Pull Through Cache

The reason I have shown the `$version` variable is because I use a 
[Pull Through Cache on ECR][ecr-pull] - just to ensure public images 
don't disappear on me - and that has a different repository address to the 
public one:

```terraform
"containerDefinitions": [{
    "name": "nginx",
    "image" : "${var.ecr_cache}/nginx/nginx:${var.nginx_version}",
    "memory": 256,
    "etc": "etc",  
}]
```

In my Fake DockerFile I still reference AWS's Public ECR. But in my Task 
Definition JSON I am referencing a variable pointing to my Pull Through Cache's
address (which is dynamically constructing it from other variables in terraform).

> You could have `nginx/nginx:1.27-perl` in the `$version` variable, if you prefer
> to do things that way, just update the script to parse the `FROM ...` correctly.

## Conclusion

You can't always have your cake and eat it. 

But, after been burned by a rouge `latest` tag (it **wasn't** from `nginx`
by the way) I needed a way to be able to take control of when new versions were 
introduced into my application. 
I needed to have a way to be able to revert them if they went rouge.
And at the same time, I wanted Dependabot to manage it alongside
all the other dependency updates that were going on.

Another benefit to this approach, is that it centralises the Docker image versions
in a repository, so if you have multiple applications, each using the same version
of a Docker image you can keep them in sync. If you don't want to sync them, you
can just have two separate DockerFiles - e.g. one to take minor updates, one to take 
nightly updates.

With the above changes I managed to get the best of both.

 [gh-intro]: https://docs.github.com/en/code-security/getting-started/dependabot-quickstart-guide
 [gh-docker]: https://docs.github.com/en/code-security/dependabot/working-with-dependabot/dependabot-options-reference
 [nginx]: https://hub.docker.com/_/nginx
 [fluentbit]: https://docs.fluentbit.io/manual/installation/docker
 [td-json]: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/example_task_definitions.html
 [cve]: https://en.wikipedia.org/wiki/Common_Vulnerabilities_and_Exposures
 [ecr-pull]: https://docs.aws.amazon.com/AmazonECR/latest/userguide/pull-through-cache-working-pulling.html