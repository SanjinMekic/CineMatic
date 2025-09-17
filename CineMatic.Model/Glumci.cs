using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model
{
    public partial class Glumci
    {
        public int Id { get; set; }

        public string? Ime { get; set; }

        public string? Prezime { get; set; }

        public DateTime? DatumRodjenja { get; set; }

        public string? Opis { get; set; }

        public string? Uspjesi { get; set; }

        public string? UlogeUfilmovima { get; set; }

        public string? SlikaBase64 { get; set; }
    }
}
