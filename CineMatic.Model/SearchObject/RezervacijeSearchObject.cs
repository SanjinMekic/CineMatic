using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model.SearchObject
{
    public class RezervacijeSearchObject : BaseSearchObject
    {
        public int? ProjekcijaId { get; set; }
        public int? KorisnikId { get; set; }
        public bool? IsProjekcijaIncluded { get; set; }
        public bool? isKorisnikIncluded { get; set; }
        public bool? isSjedistaIncluded { get; set; }
        public bool? isPlacanjeIncluded { get; set; }
        public bool? isHranaPiceIncluded { get; set; }
    }
}
