using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model
{
    public partial class FAQs
    {
        public int Id { get; set; }
        public int KategorijaId { get; set; }
        public string Pitanje { get; set; }
        public string Odgovor { get; set; }
    }
}
