---
layout: post
status: publish
published: true
title: You might not be seeing exceptions from SQL Server
date: '2018-04-08 16:23:00 +0000'
date_gmt: '2018-04-08 17:23:00 +0100'
categories:
- SQL Server
- .NET
---

This post describes a problem I noticed whereby I wasn't seeing errors from my SQL code appearing
in my C#/.NET code.

I was recently debugging a problem with a stored procedure that was crashing. I figured what caused the stored
procedure to crash and replicated the crash in SQL Management Studio, but calling it from the application code
on my development environment didn't throw an exception.
What was even stranger was that the bug report *was* from an exception thrown in the C# code, I had the stack trace
to prove it.

After a bit of digging through the code, I noticed a difference between my environment and production that
meant I wasn't reading all the results from the `SqlDataReader`.

The C# was something like this:

```csharp
var reader = command.ExecuteReader();

if (someSetting) //Some boolean I didn't have set locally.
{
    if (reader.Read())
    {
        //reading results stuff.
    }
    reader.NextResult();
}
```

Changing `someSetting` to `true` in my development environment resulted in the exception been thrown.

## What's going on?

The stored procedure that was crashing looked something like this:

```sql
create procedure ThrowSecond
as

--Selecting something, anything
select name
from sys.databases

raiserror (N'Oops', 16, 1); --This was a delete violating a FK, but I've kept it simple for this example.
```

It turns out that if SQL raises an error in a result set other than the first **and** you don't try and
read that result set, you won't get an exception thrown in your .NET code.

I'll say that again, there are circumstances where SQL Server raises an error, and you will not see it thrown
in your .NET Code.

## Beware transactions

The worst part of this... if you are using transactions in your application code, e.g. using `TransactionScope`,
you will not get an exception raised, meaning nothing will stop it calling `Complete` and committing the transaction,
even though part of your operation failed.

```csharp
void Update()
{
    using (var tx = TransactionScope())
    {
        DeleteExisting(); //Delete some data
        InsertNew(); //Tries to save some data, but SQL Errors, but the exception doesn't reach .NET

        tx.Complete();
    }
}
```

In the above hypothentical example if `InsertNew()` happens to call a stored procedure like before and is using C# like in the
previous examples. It **will** delete the existing entry, but **will not** insert a new entry.

## When does it happen?

To figure out when this does and doesn't happen I wrote a number of tests.

Using 3 different stored procedures and 4 different ways of calling it from C#.

### Stored Procedures

```sql
create procedure ThrowFirst
as
raiserror (N'Oops', 16, 1);

select name
from sys.databases
go

create procedure ThrowSecond
as
select name
from sys.databases

raiserror (N'Oops', 16, 1);
go

create procedure Works
as
select name
from sys.databases
go
```

### CSharp

```csharp
void ExecuteNonQuery(SqlCommand cmd)
{
    cmd.ExecuteNonQuery();
}

void ExecuteReaderOnly(SqlCommand cmd)
{
    using (var reader = cmd.ExecuteReader())
    {
    }
}

void ExecuteReaderReadOneResultSet(SqlCommand cmd)
{
    using (var reader = cmd.ExecuteReader())
    {
        var names = new List<String>();
        while(reader.Read())
            names.Add(reader.GetString(0));
    }
}

void ExecuteReaderLookForAnotherResultSet(SqlCommand cmd)
{
    using (var reader = cmd.ExecuteReader())
    {
        var names = new List<String>();
        while (reader.Read())
            names.Add(reader.GetString(0));
        reader.NextResult();
    }
}
```

### Results

The results are as follows:

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

The two problematic examples have a ❌ against them.

Those are when you call `ExecuteReader` with the `ThrowSecond` stored procedure, and don't go near the
second result set.

The only times where calling `ThrowSecond` will raise an exception in the .NET code is when using either,
`ExecuteNonQuery()` (no good if you have results) or you call `reader.NextReslt()` even when you only expect a
single result set.

### XACT_ABORT

I tried setting `SET XACT_ABORT ON` but that made no difference, so I've left it out of the example.

## Conclusion

I'm not sure what my conclusion is for this. I could say, *don't write SQL like this*. Perform all your data-manipulation (DML)
queries first, then return the data you want. This should stop errors from the DML been a problem because they will always be
prior to the result set you try and read.

However, I don't like that. SQL Management Studio does raise the error and I wouldn't want to advocate writing your
SQL to suite how .NET works. This feels like a .NET problem, not a SQL one.

I will say don't write stored procedures that return results, and then write C# that ignores them. That's just wasteful.

The only other solution would be to ensure you leave an extra `reader.NextResult()` after reading all of your expected
result sets. This feels a little unusual too, and would probably be removed by the next developer, who could be unaware
of why it is there in the first place.

So in the end, I don't know what's the best approach, if anyone has any thoughts/comments about this, feel free to contact
me on twitter.

## Downloads

You can download the fully runnable examples from here:

- [SQL]({{ site.contenturl }}data-reader-gotcha-sql.linq)
- [C#]({{ site.contenturl }}data-reader-gotcha-csharp.linq)

They are LINQPad scripts that run against a LocalDB called "Dave".