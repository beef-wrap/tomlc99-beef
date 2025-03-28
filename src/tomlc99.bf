/*
  MIT License

  Copyright (c) CK Tan
  https://github.com/cktan/tomlc99

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
*/

using System;
using System.Interop;

namespace tomlc99;

public static class tomlc99
{
	typealias FILE = void*;
	typealias size_t = uint;
	typealias char = c_char;

	typealias int8_t = int8;
	typealias int16_t = int16;
	typealias int32_t = int32;
	typealias int64_t = int64;

	typealias uint8_t = uint8;
	typealias uint16_t = uint16;
	typealias uint32_t = uint32;
	typealias uint64_t = uint64;

	public struct toml_table_t;
	public struct toml_array_t;

	/* Parse a file. Return a table on success, or 0 otherwise.
	* Caller must toml_free(the-return-value) after use.
	*/
	[CLink] public static extern toml_table_t* toml_parse_file(FILE* fp, char* errbuf, c_int errbufsz);

	/* Parse a string containing the full config.
	* Return a table on success, or 0 otherwise.
	* Caller must toml_free(the-return-value) after use.
	*/
	[CLink] public static extern toml_table_t* toml_parse(char* conf, /* NUL terminated, please. */ char* errbuf, c_int errbufsz);

	/* Free the table returned by toml_parse() or toml_parse_file(). Once
	* this function is called, any handles accessed through this tab
	* directly or indirectly are no longer valid.
	*/
	[CLink] public static extern void toml_free(toml_table_t* tab);

	/* Timestamp types. The year, month, day, hour, minute, second, z
	* fields may be NULL if they are not relevant. e.g. In a DATE
	* type, the hour, minute, second and z fields will be NULLs.
	*/
	[CRepr]
	public struct toml_timestamp_t
	{
		public struct
		{ /* internal. do not use. */
			c_int year, month, day;
			c_int hour, minute, second, millisec;
			char[10] z;
		} __buffer;
		c_int* year;
		c_int* month;
		c_int* day;
		c_int* hour;
		c_int* minute;
		c_int* second;
		c_int* millisec;
		char* z;
	}

	[Union]
	public struct toml_datum_u
	{
		public toml_timestamp_t* ts; /* ts must be freed after use */
		public char* s; /* string value. s must be freed after use */
		public c_int b; /* bool value */
		public int64_t i; /* c_int value */
		public double d; /* double value */
	}

	/*-----------------------------------------------------------------
	*  Enhanced access methods
	*/
	[CRepr]
	public struct toml_datum_t
	{
		public c_int ok;
		public toml_datum_u u;
	}

	/* on arrays: */
	/* ... retrieve size of array. */
	[CLink] public static extern c_int toml_array_nelem(toml_array_t* arr);

	/* ... retrieve values using index. */
	[CLink] public static extern toml_datum_t toml_string_at(toml_array_t* arr, c_int idx);

	[CLink] public static extern toml_datum_t toml_bool_at(toml_array_t* arr, c_int idx);

	[CLink] public static extern toml_datum_t toml_int_at(toml_array_t* arr, c_int idx);

	[CLink] public static extern toml_datum_t toml_double_at(toml_array_t* arr, c_int idx);

	[CLink] public static extern toml_datum_t toml_timestamp_at(toml_array_t* arr, c_int idx);

	/* ... retrieve array or table using index. */
	[CLink] public static extern toml_array_t* toml_array_at(toml_array_t* arr, c_int idx);

	[CLink] public static extern toml_table_t* toml_table_at(toml_array_t* arr, c_int idx);

	/* on tables: */
	/* ... retrieve the key in table at keyidx. Return 0 if out of range. */
	[CLink] public static extern char* toml_key_in(toml_table_t* tab, c_int keyidx);

	/* ... returns 1 if key exists in tab, 0 otherwise */
	[CLink] public static extern c_int toml_key_exists(toml_table_t* tab, char* key);

	/* ... retrieve values using key. */
	[CLink] public static extern toml_datum_t toml_string_in(toml_table_t* arr, char* key);

	[CLink] public static extern toml_datum_t toml_bool_in(toml_table_t* arr, char* key);

	[CLink] public static extern toml_datum_t toml_int_in(toml_table_t* arr, char* key);

	[CLink] public static extern toml_datum_t toml_double_in(toml_table_t* arr, char* key);

	[CLink] public static extern toml_datum_t toml_timestamp_in(toml_table_t* arr, char* key);

	/* .. retrieve array or table using key. */
	[CLink] public static extern toml_array_t* toml_array_in(toml_table_t* tab, char* key);

	[CLink] public static extern toml_table_t* toml_table_in(toml_table_t* tab, char* key);

	/*-----------------------------------------------------------------
	* lesser used
	*/
	/* Return the array kind: 't'able, 'a'rray, 'v'alue, 'm'ixed */
	[CLink] public static extern char toml_array_kind(toml_array_t* arr);

	/* For array kind 'v'alue, return the type of values
	i:c_int, d:double, b:bool, s:string, t:time, D:date, T:timestamp, 'm'ixed
	0 if unknown
	*/
	[CLink] public static extern char toml_array_type(toml_array_t* arr);

	/* Return the key of an array */
	[CLink] public static extern char* toml_array_key(toml_array_t* arr);

	/* Return the number of key-values in a table */
	[CLink] public static extern c_int toml_table_nkval(toml_table_t* tab);

	/* Return the number of arrays in a table */
	[CLink] public static extern c_int toml_table_narr(toml_table_t* tab);

	/* Return the number of sub-tables in a table */
	[CLink] public static extern c_int toml_table_ntab(toml_table_t* tab);

	/* Return the key of a table*/
	[CLink] public static extern char* toml_table_key(toml_table_t* tab);

	/*--------------------------------------------------------------
	* misc
	*/
	[CLink] public static extern c_int toml_utf8_to_ucs(char* orig, c_int len, int64_t* ret);

	[CLink] public static extern c_int toml_ucs_to_utf8(int64_t code, char[6] buf);

	[CLink] public static extern void toml_set_memutil(function void*(size_t) xxmalloc, function void(void*) xxfree);


	/*--------------------------------------------------------------
	*  deprecated
	*/
	/* A raw value, must be processed by toml_rto* before using. */
	typealias toml_raw_t = char*;

	[CLink] public static extern toml_raw_t toml_raw_in(toml_table_t* tab, char* key);

	[CLink] public static extern toml_raw_t toml_raw_at(toml_array_t* arr, c_int idx);

	[CLink] public static extern c_int toml_rtos(toml_raw_t s, char** ret);

	[CLink] public static extern c_int toml_rtob(toml_raw_t s, c_int* ret);

	[CLink] public static extern c_int toml_rtoi(toml_raw_t s, int64_t* ret);

	[CLink] public static extern c_int toml_rtod(toml_raw_t s, double* ret);

	[CLink] public static extern c_int toml_rtod_ex(toml_raw_t s, double* ret, char* buf, c_int buflen);

	[CLink] public static extern c_int toml_rtots(toml_raw_t s, toml_timestamp_t* ret);
}