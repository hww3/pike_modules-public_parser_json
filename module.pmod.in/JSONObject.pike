import Public.Parser.JSON;
/*
 * A JSONObject is an unordered collection of name/value pairs. Its
 * external form is a string wrapped in curly braces with colons between the
 * names and values, and commas between the values and names. The internal form
 * is an object having get() and opt() methods for accessing the values by name,
 * and put() methods for adding or replacing values by name. The values can be
 * any of these types: Boolean, JSONArray, JSONObject, Number, String, or the
 * JSONObject.NULL object.
 * <p>
 * The constructor can convert an external form string into an internal form
 * Java object. The toString() method creates an external form string.
 * <p>
 * A get() method returns a value if one can be found, and throws an exception
 * if one cannot be found. An opt() method returns a default value instead of
 * throwing an exception, and so is useful for obtaining optional values.
 * <p>
 * The generic get() and opt() methods return an object, which you can cast or
 * query for type. There are also typed get() and opt() methods that do typing
 * checking and type coersion for you.
 * <p>
 * The texts produced by the toString() methods are very strict.
 * The constructors are more forgiving in the texts they will accept.
 * <ul>
 * <li>An extra comma may appear just before the closing brace.</li>
 * <li>Strings may be quoted with single quotes.</li>
 * <li>Strings do not need to be quoted at all if they do not contain leading
 *     or trailing spaces, and if they do not contain any of these characters:
 *     { } [ ] / \ : , </li>
 * <li>Numbers may have the 0- (octal) or 0x- (hex) prefix.</li>
 * </ul>
 * <p>
 * Public Domain 2002 JSON.org
 * @author JSON.org
 * @version 0.1
 * <p>
 * Ported to C# by Are Bjolseth, teleplan.no
 * TODO:
 * 1. Implement Custom exceptions
 * 2. Add indexer JSONObject[i] = object,     and object = JSONObject[i];
 * 3. Add indexer JSONObject["key"] = object, and object = JSONObject["key"]
 * 4. Add unit testing
 * 5. Add log4net
 */
  /// <summary>
  /// <para>
  /// A JSONArray is an ordered sequence of values. Its external form is a string
  /// wrapped in square brackets with commas between the values. The internal form
  /// is an object having get() and opt() methods for accessing the values by
  /// index, and put() methods for adding or replacing values. The values can be
  /// any of these types: Boolean, JSONArray, JSONObject, Number, String, or the
  /// JSONObject.NULL object.
  /// </para>
  /// <para>
  /// The constructor can convert a JSON external form string into an
  /// internal form Java object. The toString() method creates an external
  /// form string.
  /// </para>
  /// <para>
  /// A get() method returns a value if one can be found, and throws an exception
  /// if one cannot be found. An opt() method returns a default value instead of
  /// throwing an exception, and so is useful for obtaining optional values.
  /// </para>
  /// <para>
  /// The generic get() and opt() methods return an object which you can cast or
  /// query for type. There are also typed get() and opt() methods that do typing
  /// checking and type coersion for you.
  ///</para>
  /// <para>
  /// The texts produced by the toString() methods are very strict.
  /// The constructors are more forgiving in the texts they will accept.
  /// </para>
  /// <para>
  /// <list type="bullet">
  /// <item><description>An extra comma may appear just before the closing bracket.</description></item>
  /// <item><description>Strings may be quoted with single quotes.</description></item>
  /// <item><description>Strings do not need to be quoted at all if they do not contain leading
  ///     or trailing spaces, and if they do not contain any of these characters:
  ///     { } [ ] / \ : , </description></item>
  /// <item><description>Numbers may have the 0- (octal) or 0x- (hex) prefix.</description></item>
  /// </list>
  /// </para>
  /// <para>
  /// Public Domain 2002 JSON.org
  /// @author JSON.org
  /// @version 0.1
  ///</para>
  /// Ported to C# by Are Bjolseth, teleplan.no
  /// TODO:
  /// 1. Implement Custom exceptions
  /// 2. Add indexer JSONObject[i] = object,     and object = JSONObject[i];
  /// 3. Add indexer JSONObject["key"] = object, and object = JSONObject["key"]
  /// 4. Add unit testing
  /// 5. Add log4net
  /// 6. Make get/put methods private, to force use of indexer instead?
  /// </summary>

		///<summary>The hash map where the JSONObject's properties are kept.</summary>
		private mapping myHashMap;

		///<summary>A shadow list of keys to enable access by sequence of insertion</summary>
		private array myKeyIndexList;

		/// <summary>
		/// It is sometimes more convenient and less ambiguous to have a NULL
		/// object than to use C#'s null value.
		/// JSONObject.NULL.toString() returns "null".
		/// </summary>

		/// <summary>
		///  Construct an empty JSONObject.
		/// </summary>
		static void create(void|string|JSONTokener|mapping x)
		{ 
			myHashMap      = ([]);
			myKeyIndexList = ({});

                     if(objectp(x))
                     {
                       fromtokener(x);
                     }
                     if(stringp(x))
                     {
                       fromtokener(JSONTokener(x));
                     }
                     if(mappingp(x))
                     {
			myHashMap      = copy_value(x);
			myKeyIndexList = indices(x);
                     }
		}

		/// <summary>
		/// Construct a JSONObject from a JSONTokener.
		/// </summary>
		/// <param name="x">A JSONTokener object containing the source string.</param>
		private void fromtokener(JSONTokener x)
		{
			int c;
			string key;
			if (x->next() == '%') 
			{
				x->unescape();
			}
			x->back();
			if (x->nextClean() != '{') 
			{
				throw(Error.Generic("A JSONObject must begin with '{'"));
			}
			while (1)
			{
				c = x->nextClean();
				switch (c) 
				{
					case 0:
						throw(Error.Generic("A JSONObject must end with '}'"));
					case '}':
						return;
					default:
						x->back();
						key = (string)x->nextObject();
						break;
				}
				if (x->nextClean() != ':') 
				{
					throw(Error.Generic("Expected a ':' after a key"));
				}
				object obj = x->nextObject();
				myHashMap[key] = obj;
				myKeyIndexList+=({key});
				switch (x->nextClean()) 
				{
					case ',':
						if (x->nextClean() == '}') 
						{
							return;
						}
						x->back();
						break;
					case '}':
						return;
					default:
						throw(Error.Generic("Expected a ',' or '}'"));
				}
			}
		}


		/// <summary>
		/// Construct a JSONObject from a string.
		/// </summary>
		/// <param name="sJSON">A string beginning with '{' and ending with '}'.</param>

		// public JSONObject(Hashtable map)
		// By changing to arg to interface, all classes that implements IDictionary can be used
		// public interface IDictionary : ICollection, IEnumerable
		// Classes that implements IDictionary
		// 1. BaseChannelObjectWithProperties - Provides a base implementation of a channel object that wants to provide a dictionary interface to its properties.
		// 2. DictionaryBase - Provides the abstract (MustInherit in Visual Basic) base class for a strongly typed collection of key-and-value pairs.
		// 3. Hashtable - Represents a collection of key-and-value pairs that are organized based on the hash code of the key.
		// 4. HybridDictionary - Implements IDictionary by using a ListDictionary while the collection is small, and then switching to a Hashtable when the collection gets large.
		// 5. ListDictionary - Implements IDictionary using a singly linked list. Recommended for collections that typically contain 10 items or less.
		// 6. PropertyCollection - Contains the properties of a DirectoryEntry.
		// 7. PropertyDescriptorCollection - Represents a collection of PropertyDescriptor objects.
		// 8. SortedList - Represents a collection of key-and-value pairs that are sorted by the keys and are accessible by key and by index.
		// 9. StateBag - Manages the view state of ASP.NET server controls, including pages. This class cannot be inherited.
		// See ms-help://MS.VSCC.2003/MS.MSDNQTR.2003FEB.1033/cpref/html/frlrfsystemcollectionsidictionaryclasstopic.htm


		/// <summary>
		/// Construct a JSONObject from a IDictionary
		/// </summary>
		/// <param name="map"></param>

		/// <summary>
		/// Accumulate values under a key. It is similar to the put method except
		/// that if there is already an object stored under the key then a
		/// JSONArray is stored under the key to hold all of the accumulated values.
		/// If there is already a JSONArray, then the new value is appended to it.
		/// In contrast, the put method replaces the previous value.
		/// </summary>
		/// <param name="key">A key string.</param>
		/// <param name="val">An object to be accumulated under the key.</param>
		/// <returns>this</returns>
		public JSONObject accumulate(string key, object val)
		{
			JSONArray a;
			object obj = opt(key);
			if (obj == 0)
			{
				put(key, val);
			}
			else if (Program.implements(object_program(obj), JSONArray))
			{
				a = obj;
				a->put(sizeof(a), val);
			}
			else
			{
				a = JSONArray();
				a->put(sizeof(a), obj);
				a->put(sizeof(a), val);
				put(key,a);
			}
			return this;
		}


		/// <summary>
		/// Return the key for the associated index
		/// </summary>
		static mixed `[](mixed i)
		{
                  if(intp(i))
  		    return (string)myKeyIndexList[i];
                  else if(stringp(i))
                    return getValue(i);
		}

                static void `[]=(mixed key, mixed value)
                {
                  put(key,value);
		}

		/// <summary>
		/// Return the number of JSON items in hashtable
		/// </summary>
		static int _sizeof()
		{
				return sizeof(myHashMap);
		}


		/// <summary>
		/// Alias to Java get method
		/// Get the value object associated with a key.
		/// </summary>
		/// <param name="key">A key string.</param>
		/// <returns>The object associated with the key.</returns>
		public object getValue(string key)
		{
			//return myHashMap[key];
			mixed obj = opt(key);
			if (!obj && zero_type(obj))
			{
				throw(Error.Generic("No such element"));
			}
			return obj;
		}

		/// <summary>
		/// Get the boolean value associated with a key.
		/// </summary>
		/// <param name="key">A key string.</param>
		/// <returns>The truth.</returns>
		public int(0..1) getBool(string key)
		{
			mixed o = getValue(key);
			if (intp(o))
			{
                                if(o) return 1;
				else return 0;
			}
			string msg = sprintf("JSONObject[%O] is not a Boolean",JSONUtils.Enquote(key));
			throw(Error.Generic(msg));
		}

		/// <summary>
		/// Get the double value associated with a key.
		/// </summary>
		/// <param name="key">A key string.</param>
		/// <returns>The double value</returns>
		public float getDouble(string key)
		{
			mixed o = getValue(key);
			if (floatp(o))
				return o;

			if (stringp(o))
			{
                                float f;
                                sscanf(o, "%f", f);
				return f;
			}
			string msg = sprintf("JSONObject[%O] is not a double",JSONUtils.Enquote(key));
			throw(Error.Generic(msg));
		}

		/// <summary>
		/// Get the int value associated with a key.
		/// </summary>
		/// <param name="key">A key string</param>
		/// <returns> The integer value.</returns>
		public int getInt(string key)
		{
			mixed o = getValue(key);
			if (intp(o))
			{
				return (int)o;
			}

			if (stringp(o))
			{
				return (int)(o);
			}
			string msg = sprintf("JSONObject[%O] is not a int",JSONUtils.Enquote(key));
			throw(Error.Generic(msg));
		}

		/// <summary>
		/// Get the JSONArray value associated with a key.
		/// </summary>
		/// <param name="key">A key string</param>
		/// <returns>A JSONArray which is the value</returns>
		public JSONArray getJSONArray(string key)
		{
			mixed o = getValue(key);
			if (objectp(o) && Program.implements(object_program(o), JSONArray))
			{
				return o;
			}
			string msg = sprintf("JSONObject[%O] is not a JSONArray",JSONUtils.Enquote(key));
			throw(Error.Generic(msg));
		}

		/// <summary>
		/// Get the JSONObject value associated with a key.
		/// </summary>
		/// <param name="key">A key string.</param>
		/// <returns>A JSONObject which is the value.</returns>
		public JSONObject getJSONObject(string key)
		{
		        mixed o = getValue(key);
			if (objectp(o) && Program.implements(object_program(o), JSONObject))
			{
				return o;
			}
			string msg = sprintf("JSONObject[%O] is not a JSONArray",JSONUtils.Enquote(key));
			throw(Error.Generic(msg));
		}

		/// <summary>
		/// Get the string associated with a key.
		/// </summary>
		/// <param name="key">A key string.</param>
		/// <returns>A string which is the value.</returns>
		public string getString(string key)
		{
			return (string)getValue(key);
		}


		/// <summary>
		/// Determine if the JSONObject contains a specific key.
		/// </summary>
		/// <param name="key">A key string.</param>
		/// <returns>true if the key exists in the JSONObject.</returns>
		public int(0..1) has(string key)
		{
                        if( myHashMap[key])
  			  return 1;
                        else return 0;
		}


		/// <summary>
		/// Get an enumeration of the keys of the JSONObject.
		/// Added to be true to orginal Java implementation
		/// Indexers are easier to use
		/// </summary>
		/// <returns></returns>
		static array _indices()
		{
			return indices(myHashMap);
		}

		static array _values()
		{
			return values(myHashMap);
		}

		/// <summary>
		/// Determine if the value associated with the key is null or if there is no value.
		/// </summary>
		/// <param name="key">A key string</param>
		/// <returns>true if there is no value associated with the key or if the valus is the JSONObject.NULL object</returns>
		public int(0..1) isNull(string key)
		{
			return NULLObject.equals(opt(key));
		}

		/// <summary>
		/// Get the number of keys stored in the JSONObject.
		/// </summary>
		/// <returns>The number of keys in the JSONObject.</returns>
		public int Length()
		{
			return sizeof(myHashMap);
		}


		/// <summary>
		/// Produce a string from a number.
		/// </summary>
		/// <param name="number">Number value type object</param>
		/// <returns>String representation of the number</returns>
		public string numberToString(mixed number)
		{
			if (floatp(number) && !(float)number)
			{
				throw(Error.Generic("object must be a valid number"));
			}

			// Shave off trailing zeros and decimal point, if possible
			string s = lower_case((string)number);
			if (search(s, 'e') < 0 && search(s, '.') > 0)
			{
				while(has_suffix(s, "0"))
				{
					s= s[0..sizeof(s)-2];
				}
				if (has_suffix(s, "."))
				{
					s=s[0.. sizeof(s)-2];
				}
			}
werror("returning %O\n", s);
			return s;
		}

		/// <summary>
		/// Get an optional value associated with a key.
		/// </summary>
		/// <param name="key">A key string</param>
		/// <returns>An object which is the value, or null if there is no value.</returns>
		public mixed opt(string key)
		{
			if (!key)
			{
				throw(Error.Generic("Null key"));
			}
			return myHashMap[key];
		}


		/// <summary>
		/// Get an optional value associated with a key.
		/// It returns false if there is no such key, or if the value is not
		/// Boolean.TRUE or the String "true".
		/// </summary>
		/// <param name="key">A key string.</param>
		/// <param name="defaultValue">The preferred return value if conversion fails</param>
		/// <returns>bool value object</returns>
		public int(0..1) optBoolean(string key, void|int(0..1) defaultValue)
		{
			mixed obj = opt(key);
			if (obj)
			{
				if (intp(obj))
                                {
                                   if(obj)
                                   {
                                     return 1;
                                   }
                                   else return 0;
                                }
				if (stringp(obj))
				{
                                  if(obj == "true")
                                    return 1;
                                  if(obj == "false")
                                    return 0;
				}
			}
			return defaultValue;
		}


		/// <summary>
		/// Get an optional double associated with a key,
		/// or NaN if there is no such key or if its value is not a number.
		/// If the value is a string, an attempt will be made to evaluate it as
		/// a number.
		/// </summary>
		/// <param name="key">A string which is the key.</param>
		/// <param name="defaultValue">The default</param>
		/// <returns>A double value object</returns>
		public float optFloat(string key, float|void defaultValue)
		{
			mixed obj = opt(key);
			if (obj)
			{
				if (floatp(obj))
                                  return obj;
                                if(intp(obj))
                                  return (float)obj;
				if (stringp(obj))
				{
					return (float)obj;
				}
			}
			return defaultValue;

		}

		/// <summary>
		///  Get an optional double associated with a key, or the
		///  defaultValue if there is no such key or if its value is not a number.
		///  If the value is a string, an attempt will be made to evaluate it as
		///  number.
		/// </summary>
		/// <param name="key">A key string.</param>
		/// <param name="defaultValue">The default value</param>
		/// <returns>An int object value</returns>
		public int optInt(string key, int|void defaultValue)
		{
			mixed obj = opt(key);
			if (obj)
			{
				if (intp(obj))
					return (int)obj;
				if (stringp(obj))
					return (int)obj;
			}
			return defaultValue;
		}

		/// <summary>
		/// Get an optional JSONArray associated with a key.
		/// It returns null if there is no such key, or if its value is not a JSONArray
		/// </summary>
		/// <param name="key">A key string</param>
		/// <returns>A JSONArray which is the value</returns>
		public JSONArray optJSONArray(string key)
		{
			mixed obj = opt(key);
			if (objectp(obj) && Program.implements(object_program(obj), JSONArray))
			{
				return obj;
			}
			return 0;
		}

		/// <summary>
		/// Get an optional JSONObject associated with a key.
		/// It returns null if there is no such key, or if its value is not a JSONObject.
		/// </summary>
		/// <param name="key">A key string.</param>
		/// <returns>A JSONObject which is the value</returns>
		public JSONObject optJSONObject(string key)
		{
			mixed obj = opt(key);
			if (obj && Program.implements(object_program(obj), JSONObject))
			{
				return obj;
			}
			return 0;
		}

		/// <summary>
		/// Get an optional string associated with a key.
		/// It returns an empty string if there is no such key. If the value is not
		/// a string and is not null, then it is coverted to a string.
		/// </summary>
		/// <param name="key">A key string.</param>
		/// <returns>A string which is the value.</returns>

		/// <summary>
		/// Get an optional string associated with a key.
		/// It returns the defaultValue if there is no such key.
		/// </summary>
		/// <param name="key">A key string.</param>
		/// <param name="defaultValue">The default</param>
		/// <returns>A string which is the value.</returns>
		public string optString(string key, string|void defaultValue)
		{
			mixed obj = opt(key);
			if (obj)
			{
				return (string)obj;
			}
			return defaultValue ||"";
		}

		// OMITTED - all put methods can be replaced by a indexer in C#
		//         - ===================================================
		// public JSONObject put(String key, boolean value)
		// public JSONObject put(String key, double value)
		// public JSONObject put(String key, int value)

		/// <summary>
		/// Put a key/value pair in the JSONObject. If the value is null,
		/// then the key will be removed from the JSONObject if it is present.
		/// </summary>
		/// <param name="key"> A key string.</param>
		/// <param name="val">
		/// An object which is the value. It should be of one of these
		/// types: Boolean, Double, Integer, JSONArray, JSONObject, String, or the
		/// JSONObject.NULL object.
		/// </param>
		/// <returns>JSONObject</returns>
		public JSONObject put(string key, mixed val)
		{
			if (!key)
			{
				throw(Error.Generic("key cannot be null"));
			}
			if (!val && !zero_type(val))
			{
				if (!myHashMap[key] && !zero_type(myHashMap[key]))
				{
					myHashMap[key]=val;
					myKeyIndexList+=({key});
				}
				else
				{
					myHashMap[key]=val;
				}
			}
			else 
			{
				remove(key);
			}
			return this;
		}

    /// <summary>
    /// Add a key value pair
    /// </summary>
    /// <param name="key"></param>
    /// <param name="val"></param>
    /// <returns></returns>
		public JSONObject putOpt(string key, mixed val)
		{
			if (!val && !zero_type(val))
			{
				put(key,val);
			}
			return this;
		}


    /// <summary>
    /// Remove a object assosiateted with the given key
    /// </summary>
    /// <param name="key"></param>
    /// <returns></returns>
		public mixed remove(string key)
		{
			if (myHashMap[key] || !zero_type(myHashMap[key]))
			{
				// TODO - does it really work ???
				mixed obj = myHashMap[key];
				m_delete(myHashMap, key);
				myKeyIndexList-=({key});
				return obj;
			}
			return UNDEFINED;
		}

    /// <summary>
    /// Append an array of JSONObjects to current object
    /// </summary>
    /// <param name="names"></param>
    /// <returns></returns>
		public JSONArray toJSONArray(JSONArray names)
		{
			if (!names || sizeof(names) == 0)
				return UNDEFINED;

			JSONArray ja = JSONArray();
			for (int i=0; i<sizeof(names); i++)
			{
			  ja->put(sizeof(ja), this->opt(names->getString(i)));
			}
			return ja;
		}

static mixed cast(string to)
{
  if(to =="string")
    return ToString();
  if(to =="mapping")
    return copy_value(myHashMap);
}

    /// <summary>
    /// Overridden to return a JSON formattet object as a string
    /// </summary>
    /// <returns>JSON object as formatted string</returns>
		public string ToString()
		{
			mixed obj;
			//string s;
			String.Buffer sb = String.Buffer();

			sb+=("{");
			foreach (myHashMap;string key;mixed val)  //NOTE! Could also use myKeyIndexList !!!
			{
				if (obj)
					sb+=(",");
				obj = myHashMap[key];
				if (obj)
				{
					sb+=(JSONUtils.Enquote(key));
					sb+=(":");

					if (stringp(obj))
					{
					   sb+=(JSONUtils.Enquote(obj));
					}
					else if (floatp(obj))
					{
                                               werror("encoding float\n");
						sb+=(numberToString(obj));
					}
					// boolean is a problem...
					else
					{
						sb+=((string)obj);
					}
				}
			}
			sb+=("}");
			return sb->get();
		}
