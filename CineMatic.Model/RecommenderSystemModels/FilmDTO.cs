using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model.RecommenderSystemModels
{
    public class FilmDTO
    {
        public int Id { get; set; }
        public string Naslov { get; set; }
        public string[] Zanrovi { get; set; }
        public string[] Glumci { get; set; }
        public string? ImageBase64 { get; set; }
    }
}
