using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model.DTO
{
    public class RezervacijaFilmDTO
    {
        public int RezervacijaId { get; set; }
        public DateTime DatumRezervacije { get; set; }
        public string? NacinPlacanja { get; set; }
        public int ProjekcijaId { get; set; }
        public DateTime DatumProjekcije { get; set; }
        public List<int> SjedistaIds { get; set; } = new List<int>();
        public List<int> HranaPiceIds { get; set; } = new List<int>();

        public int FilmId { get; set; }
        public string? NazivFilma { get; set; }
        public int? TrajanjeFilma { get; set; }
        public string? Opis { get; set; }
        public string? FilmaSlikaBase64 { get; set; }
    }
}
