using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model.Requests
{
    public class ProjekcijeInsertRequest
    {
        public int FilmId { get; set; }

        public int SalaId { get; set; }

        public int NačinProjekcijeId { get; set; }

        public DateTime DatumIvrijeme { get; set; }

        public decimal Cijena { get; set; }

        public string StateMachine { get; set; } = "hidden";
    }
}
