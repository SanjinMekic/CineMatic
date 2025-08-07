using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model.Requests
{
    public class GlumciUpdateRequest
    {
        public string? Ime { get; set; }

        public string? Prezime { get; set; }

        public DateTime? DatumRodjenja { get; set; }

        public string? Opis { get; set; }

        public string? SlikaBase64 { get; set; }
    }
}
