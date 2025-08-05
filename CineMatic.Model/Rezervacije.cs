using System;
using System.Collections.Generic;
using System.Numerics;
using System.Text;

namespace CineMatic.Model
{
    public partial class Rezervacije
    {
        public int Id { get; set; }

        public int? KorisnikId { get; set; }

        public int? ProjekcijaId { get; set; }

        public int? UplataId { get; set; }

        public DateTime? DatumIvrijeme { get; set; }

        public int? BrojUlaznica { get; set; }

        public decimal? UkupnaCijena { get; set; }

        public string? NačinPlaćanja { get; set; }

        public string? QrcodeBase64 { get; set; }

        public virtual Korisnici? Korisnik { get; set; }

        public virtual Projekcije? Projekcija { get; set; }

        public virtual ICollection<RezervacijeSjedištum> RezervacijeSjedišta { get; set; } = new List<RezervacijeSjedištum>();

        public virtual Uplate? Uplata { get; set; }

        public virtual ICollection<HraneIpića> HranaIpićes { get; set; } = new List<HraneIpića>();
    }
}
