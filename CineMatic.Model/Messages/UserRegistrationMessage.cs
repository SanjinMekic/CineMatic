using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model.Messages
{
    public class UserRegistrationMessage
    {
        public string Email { get; set; }
        public string Name { get; set; }
        public int Role { get; set; }
        public string Password { get; set; }
        public string korisnickoIme { get; set; }
    }
}
