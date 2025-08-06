using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model.SearchObject
{
    public class HraneIpićaSearchObject : BaseSearchObject
    {
        public string? NazivGTE { get; set; }
        public decimal? CijenaMin { get; set; }
        public decimal? CijenaMax { get; set; }
        public bool isKategorijeIncluded { get; set; }
    }
}
