using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model.SearchObject
{
    public class KorisniciSearchObject : BaseSearchObject
    {
        public string? ImeGTE { get; set; }
        public string? PrezimeGTE { get; set; }
        public string? KorisnickoIme { get; set; }
        public string? Email { get; set; }
        public bool? isUlogeIncluded { get; set; }
    }
}
