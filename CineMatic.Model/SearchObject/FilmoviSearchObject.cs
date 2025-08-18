using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model.SearchObject
{
    public class FilmoviSearchObject : BaseSearchObject
    {
        public string? NazivGTE { get; set; }
        public bool? isDobneRestrikcijeIncluded { get; set; }
        public bool? isGlumciIncluded { get; set; }
        public bool? isRežiseriIncluded { get; set; }
        public bool? isŽanroviIncluded { get; set; }
    }
}
