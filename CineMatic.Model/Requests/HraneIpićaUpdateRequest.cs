using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model.Requests
{
    public class HraneIpićaUpdateRequest
    {
        public int? KategorijaId { get; set; }

        public string? Naziv { get; set; }

        public decimal? Cijena { get; set; }

        public string? Opis { get; set; }

        public int? KoličinaUskladištu { get; set; }

        public string? SlikaBase64 { get; set; }
    }
}
