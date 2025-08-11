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

    }

}
