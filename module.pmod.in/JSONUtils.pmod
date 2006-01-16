import Public.Parser.JSON;
		/// <summary>
		/// Produce a string in double quotes with backslash sequences in all the right places.
		/// </summary>
		/// <param name="s">A String</param>
		/// <returns>A String correctly formatted for insertion in a JSON message.</returns>
		public string Enquote(string s) 
		{
			if (!s || sizeof(s) == 0) 
			{
				return "\"\"";
			}
			int         c;
			int          i;
			int          len = sizeof(s);
			String.Buffer sb = String.Buffer(len + 4);
			string       t;

			sb+=("\"");
			for (i = 0; i < len; i += 1) 
			{
				c = s[i];
				if ((c == '\\') || (c == '"') || (c == '>'))
				{
					sb+=("\\");
					sb+=String.int2char(c);
				}
				else if (c == '\b')
					sb+=("\\b");
				else if (c == '\t')
					sb+=("\\t");
				else if (c == '\n')
					sb+=("\\n");
				else if (c == '\f')
					sb+=("\\f");
				else if (c == '\r')
					sb+=("\\r");
				else
				{
					if (c < ' ') 
					{
						sb += sprintf("\\u%04x", c);;
					} 
					else 
					{
						sb+=String.int2char(c);
					}
				}
			}
			sb+=("\"");
			return sb->get();
		}
