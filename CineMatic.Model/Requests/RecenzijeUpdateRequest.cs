using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model.Requests
{
    public class RecenzijeUpdateRequest
    {
        public int KorisnikId { get; set; }

        public int FilmId { get; set; }

        public int? Ocjena { get; set; }

        public DateTime DatumIvrijeme { get; set; }

        public string? Komentar { get; set; }
    }
}
