using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model.Requests
{
    public class ProjekcijeSjedištumInsertRequest
    {
        public int ProjekcijaId { get; set; }

        public int SjedišteId { get; set; }

        public bool Rezervisano { get; set; } = false;
    }
}
