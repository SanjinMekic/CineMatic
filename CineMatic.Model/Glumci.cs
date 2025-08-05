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

        public byte[]? Slika { get; set; }

        public virtual ICollection<Filmovi> Films { get; set; } = new List<Filmovi>();
    }
}
