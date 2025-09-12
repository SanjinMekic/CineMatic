using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model
{
    public partial class RezervacijeSjedištum
    {
        public int RezervacijaId { get; set; }

        public int SjedišteId { get; set; }

        public virtual Sjedištum Sjedište { get; set; }
    }
}
