using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model
{
    public partial class RezervacijeSjedištum
    {
        public int RezervacijaId { get; set; }

        public int SjedišteId { get; set; }

        public DateTime? DatumIvrijeme { get; set; }

        public virtual Rezervacije Rezervacija { get; set; } = null!;

        public virtual Sjedištum Sjedište { get; set; } = null!;
    }
}
