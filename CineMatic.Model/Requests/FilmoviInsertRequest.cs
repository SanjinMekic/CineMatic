using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model.Requests
{
    public class FilmoviInsertRequest
    {
        public string Naziv { get; set; }

        public int Trajanje { get; set; }

        public string Opis { get; set; }

        public string SlikaBase64 { get; set; }

        public int DobnaRestrikcijaId { get; set; }
        public List<int> GlumciID { get; set; } = new List<int>();
        public List<int> RežiseriID { get; set; } = new List<int>();
        public List<int> ŽanroviID { get; set; } = new List<int>();
    }
}
