using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model.Izvjestaji
{
    public class TopKorisnik
    {
        public int? Korisnikd { get; set; }
        public string? Ime { get; set; }
        public string? Prezime { get; set; }
        public decimal? UkupnoPotrosenoNovca { get; set; }
    }
}
