using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model.Requests
{
    public class FilmoviUpdateRequest
    {
        public string? Naziv { get; set; }

        public int? Trajanje { get; set; }

        public string? Opis { get; set; }

        public string? SlikaBase64 { get; set; }

        public int? DobnaRestrikcijaId { get; set; }
    }
}
