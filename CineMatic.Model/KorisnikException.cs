using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model
{
    public class KorisnikException : Exception
    {
        public KorisnikException(string message) : base(message) { }
    }
}
