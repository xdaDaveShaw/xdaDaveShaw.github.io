---
layout: post
status: publish
published: true
title: You might not be handling exceptions from SQL Server
date: '2018-03-29 16:37:00 +0000'
date_gmt: '2018-03-29 16:37:00 +0100'
categories:
- SQL Server
- .NET
---

|Test                                           |Procedure  |Throws Exception|
|-----------------------------------------------|-----------|----------------|
|ExecuteNonQuery                                |ThrowFirst | ✅             |
|ExecuteNonQuery                                |ThrowSecond| ✅             |
|ExecuteNonQuery                                |Works      | n/a            |
|ExecuteReader Only                             |ThrowFirst | ✅             |
|ExecuteReader Only                             |ThrowSecond| ❌             |
|ExecuteReader Only                             |Works      | n/a            |
|ExecuteReader Read One ResultSet               |ThrowFirst | ✅             |
|ExecuteReader Read One ResultSet               |ThrowSecond| ❌             |
|ExecuteReader Read One ResultSet               |Works      | n/a            |
|ExecuteReader Look For Another ResultSet       |ThrowFirst | ✅             |
|ExecuteReader Look For Another ResultSet       |ThrowSecond| ✅             |
|ExecuteReader Look For Another ResultSet       |Works      | n/a            |
