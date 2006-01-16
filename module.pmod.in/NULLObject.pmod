import Public.Parser.JSON;

                        /*
                        public object clone()
                        {
                                return this;
                        }
                        */
                        public int(0..1) equals(object obj)
                        {
                                return (obj == 0) || (obj == this);
                        }
      /// <summary>
      /// Overriden to return "null"
      /// </summary>
      /// <returns>null</returns>
                        public string ToString()
                        {
                                //return base.ToString ();
                                return "null";
                        }

