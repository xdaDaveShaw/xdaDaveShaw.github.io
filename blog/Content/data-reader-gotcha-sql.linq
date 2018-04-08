<Query Kind="SQL">
  <Connection>
    <ID>a8a0f9a2-9940-4d06-91b1-0d32fd4d5679</ID>
    <Persist>true</Persist>
    <Server>(localdb)\MSSQLLocalDB</Server>
    <Database>master</Database>
    <ShowServer>true</ShowServer>
  </Connection>
</Query>

use Dave;

if object_id('ThrowFirst') is not null
	drop procedure ThrowFirst;
go

create procedure ThrowFirst
as
raiserror (N'Oops', 16, 1);

select name
from sys.databases
go

if object_id('ThrowSecond') is not null
	drop procedure ThrowSecond;
go

create procedure ThrowSecond
as
select name
from sys.databases

raiserror (N'Oops', 16, 1);
go

if object_id('Works') is not null
	drop procedure Works;
go

create procedure Works
as
select name
from sys.databases
go