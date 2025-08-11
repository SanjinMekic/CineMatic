using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model.SearchObject
{
    public class RecenzijeSearchObject : BaseSearchObject
    {
        public int? Ocjena { get; set; }
        public bool? isKorisniciFilmoviIncluded { get; set; }
    }
}
