using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model.Requests
{
    public class RezervacijeInsertRequest
    {
        public int KorisnikId { get; set; }
        public int ProjekcijaId { get; set; }
        public List<int> SjedisteId { get; set; } = new List<int>();
        public List<int> HranePicaId { get; set; } = new List<int>();
        public List<int> KolicineHranePica { get; set; } = new List<int>();
        public string StripePaymentIntentId { get; set; }
    }
}
