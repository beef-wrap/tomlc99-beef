using System;
using System.Diagnostics;
using static System.Runtime;

using static tomlc99.tomlc99;

namespace example;

static class Program
{
	const String array_of_tables = """
		x = [ {'a'= 1}, {'a'= 2} ]
	""";

	const String inline_array = """
		x = [1,2,3]
	""";

	const String inline_table = """
		x = {'a'= 1, 'b'= 2 }
	""";

	const String sample = """
		[server]
			host = "example.com"
			port = [ 8080, 8181, 8282 ]
	""";

	static int Main(params String[] args)
	{
		char8[200] errbuf = ?;

		toml_table_t* conf = toml_parse	(sample, &errbuf, sizeof(char8) * 200);

		if (conf == null)
		{
			Debug.WriteLine($"cannot parse - {errbuf}");
		}

		// 2. Traverse to a table.
		toml_table_t* server = toml_table_in(conf, "server");

		if (server == null)
		{
			Debug.WriteLine("missing [server]", "");
		}

		// 3. Extract values
		toml_datum_t host = toml_string_in(server, "host");
		if (host.ok == 0)
		{
			Debug.WriteLine("cannot read server.host");
		}

		toml_array_t* portarray = toml_array_in(server, "port");
		if (portarray == null)
		{
			Debug.WriteLine("cannot read server.port");
		}

		Debug.WriteLine($"host: {StringView(host.u.s)}\n");
		Debug.WriteLine("port: ");
		for (int32 i = 0;; i++)
		{
			toml_datum_t port = toml_int_at(portarray, i);
			if (port.ok == 0) break;
			Debug.WriteLine($"{(int)port.u.i}");
		}

		Debug.WriteLine("");

		// 4. Free memory
		Internal.StdFree(host.u.s);

		toml_free(conf);

		return 0;
	}
}