using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model
{
    public partial class Uplate
    {
        public int Id { get; set; }

        public int? KorisnikId { get; set; }

        public string? Izdavač { get; set; }

        public string? TransakcijaId { get; set; }

        public decimal? Iznos { get; set; }

        public DateTime? DatumIvrijeme { get; set; }

        public virtual Korisnici? Korisnik { get; set; }

        public virtual ICollection<Rezervacije> Rezervacijes { get; set; } = new List<Rezervacije>();
    }
}
