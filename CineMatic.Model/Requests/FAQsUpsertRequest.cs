using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model.Requests
{
    public partial class FAQsUpsertRequest
    {
        public int KategorijaId { get; set; }
        public string? Pitanje { get; set; }
        public string? Odgovor { get; set; }
    }
}
