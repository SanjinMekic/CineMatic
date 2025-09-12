using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model
{
    public partial class RezervacijeHraneIpića
    {
        public int RezervacijaId { get; set; }

        public int HranaIpićeId { get; set; }

        public virtual HraneIpića HranaIpiće { get; set; }

        public virtual Rezervacije Rezervacija { get; set; }
    }
}
