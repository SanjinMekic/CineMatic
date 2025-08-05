using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model
{
    public partial class ProjekcijeSjedištum
    {
        public int ProjekcijaId { get; set; }

        public int SjedišteId { get; set; }

        public bool? Rezervisano { get; set; }

        public virtual Projekcije Projekcija { get; set; } = null!;

        public virtual Sjedištum Sjedište { get; set; } = null!;
    }
}
