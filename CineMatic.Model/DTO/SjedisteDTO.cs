using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model.DTO
{
    public class SjedisteDTO
    {
        public int Id { get; set; }
        public string? Naziv { get; set; }
        public bool? Rezervisano { get; set; }
    }
}
