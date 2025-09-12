using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model
{
    public class ForbidException : Exception
    {
        public ForbidException(string message) : base(message) { }
    }
}
