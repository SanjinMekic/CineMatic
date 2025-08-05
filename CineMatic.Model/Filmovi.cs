using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model
{
    public partial class Filmovi
    {
        public int Id { get; set; }

        public string? Naziv { get; set; }

        public int? Trajanje { get; set; }

        public string? Opis { get; set; }

        public byte[]? Slika { get; set; }

        public int? DobnaRestrikcijaId { get; set; }

        public virtual DobneRestrikcije? DobnaRestrikcija { get; set; }

        public virtual ICollection<Projekcije> Projekcijes { get; set; } = new List<Projekcije>();

        public virtual ICollection<Rezencije> Rezencijes { get; set; } = new List<Rezencije>();

        public virtual ICollection<Glumci> Glumacs { get; set; } = new List<Glumci>();

        public virtual ICollection<Režiseri> Režisers { get; set; } = new List<Režiseri>();

        public virtual ICollection<Žanrovi> Žanrs { get; set; } = new List<Žanrovi>();
    }

}
