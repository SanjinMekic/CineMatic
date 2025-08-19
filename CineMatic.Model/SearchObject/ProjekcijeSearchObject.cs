using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model.SearchObject
{
    public class ProjekcijeSearchObject : BaseSearchObject
    {
        public string? Naziv { get; set; }
        public string? Žanr { get; set; }
        public DateTime? Datum { get; set; }
        public bool? isFilmoviIncluded { get; set; }
        public bool? isNačiniProjekcijeIncluded { get; set; }
        public bool? isSaleIncluded { get; set; }
    }
}
