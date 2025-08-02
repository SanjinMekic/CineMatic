using System;
using System.Collections.Generic;
using System.Numerics;
using System.Text;

namespace CineMatic.Model
{
    public partial class Korisnici
    {
        public int Id { get; set; }

        public string? Ime { get; set; }

        public string? Prezime { get; set; }

        public string? KorisnickoIme { get; set; }

        public string? Email { get; set; }

        public byte[]? Slika { get; set; }

        public virtual ICollection<Uloge> Ulogas { get; set; } = new List<Uloge>();
    }

}
