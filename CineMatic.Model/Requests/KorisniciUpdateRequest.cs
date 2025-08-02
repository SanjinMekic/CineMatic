using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model.Requests
{
    public class KorisniciUpdateRequest
    {
        public string? Ime { get; set; } = null!;

        public string? Prezime { get; set; } = null!;

        public string? Email { get; set; }

        public string? KorisnickoIme { get; set; } = null!;

        public string? SlikaBase64 { get; set; }

        public string? Lozinka { get; set; }

        public string? LozinkaPotvrda { get; set; }

        public List<int> UlogaId { get; set; } = new List<int>();   
    }
}
