using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model
{
    public partial class Rezencije
    {
        public int Id { get; set; }

        public int? KorisnikId { get; set; }

        public int? FilmId { get; set; }

        public int? Ocjena { get; set; }

        public DateTime? DatumIvrijeme { get; set; }

        public string? Komentar { get; set; }

        public virtual Filmovi? Film { get; set; }

        public virtual Korisnici? Korisnik { get; set; }
    }
}
