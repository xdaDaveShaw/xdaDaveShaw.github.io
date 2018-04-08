<Query Kind="Program">
  <Connection>
    <ID>a8a0f9a2-9940-4d06-91b1-0d32fd4d5679</ID>
    <Persist>true</Persist>
    <Server>(localdb)\MSSQLLocalDB</Server>
    <Database>Dave</Database>
    <ShowServer>true</ShowServer>
  </Connection>
</Query>

const String _connectionString = @"Initial Catalog=Dave;Data Source=(localdb)\MSSQLLocalDB;Integrated Security=SSPI";

void Main()
{
	"ExecuteNonQuery".Dump();
	TestWith(ExecuteNonQuery);
	"".Dump();
	
	"ExecuteReaderOnly".Dump();
	TestWith(ExecuteReaderOnly);
	"".Dump();

	"ExecuteReaderReadOneResultSet".Dump();
	TestWith(ExecuteReaderReadOneResultSet);
	"".Dump();

	"ExecuteReaderLookForAnotherResultSet".Dump();
	TestWith(ExecuteReaderLookForAnotherResultSet);
	"".Dump();
}

void TestWith(Action<SqlCommand> body)
{
	Execute("ThrowFirst", body).Dump();
	Execute("ThrowSecond", body).Dump();
	Execute("Works", body).Dump();
}

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

String Execute(String procName, Action<SqlCommand> body)
{
	try
	{
		using (var tx = new TransactionScope())
		using (var cx = new SqlConnection(_connectionString))
		{
			cx.Open();
			using (var cmd = new SqlCommand(procName, cx))
			{
				body(cmd);
			}

			tx.Complete();
			return $"{procName}: true";
		}
	}
	catch
	{
		return $"{procName}: false";
	}
}