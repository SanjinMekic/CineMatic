using CineMatic.Model;
using CineMatic.Model.RecommenderSystemModels;
using CineMatic.Services.RecommenderSystem;
using System;
using System.Collections.Generic;
using System.Linq;

namespace CineMatic.Services
{
    public class RecommenderService : IRecommenderService
    {
        private readonly IFilmoviService _filmoviService;
        private readonly List<string> _sviZanrovi;
        private readonly List<string> _sviGlumci;

        public RecommenderService(IFilmoviService filmoviService)
        {
            _filmoviService = filmoviService;

            // Dohvati sve žanrove i glumce iz baze
            _sviZanrovi = _filmoviService.DohvatiSveFilmove()
                                       .SelectMany(f => f.Zanrovi)
                                       .Distinct()
                                       .ToList();

            _sviGlumci = _filmoviService.DohvatiSveFilmove()
                                      .SelectMany(f => f.Glumci)
                                      .Distinct()
                                      .ToList();
        }

        public List<FilmDTO> DobaviPreporuceneFilmove(int filmId, int brojPreporuka = 5)
        {
            var ciljFilm = _filmoviService.GetById(filmId);
            if (ciljFilm == null) throw new Exception($"Nije pronadjen film sa ID: {filmId}");

            var filmDto = MapirajFilmDto(ciljFilm);
            var ciljVektor = PretvoriUFeatureVektor(filmDto);

            var sviOstaliFilmovi = _filmoviService.DohvatiSveFilmove()
                                               .Where(f => f.Id != filmId)
                                               .ToList();

            var rezultati = new List<(FilmDTO film, float score)>();

            foreach (var film in sviOstaliFilmovi)
            {
                var vektor = PretvoriUFeatureVektor(film);
                float score = IzracunajKosinusSlicnost(ciljVektor, vektor);

                rezultati.Add((film, score));
            }

            // Sortiraj po opadajućem score-u i uzmi prvih N
            return rezultati.OrderByDescending(r => r.score)
                            .Take(brojPreporuka)
                            .Select(r => r.film)
                            .ToList();
        }

        private float[] PretvoriUFeatureVektor(FilmDTO film)
        {
            var vektorZanrova = OneHotKodirajZanrove(film.Zanrovi);
            var vektorGlumaca = OneHotKodirajGlumce(film.Glumci);

            return vektorZanrova.Concat(vektorGlumaca).ToArray();
        }

        private float[] OneHotKodirajZanrove(string[] zanrovi)
        {
            var vektor = new float[_sviZanrovi.Count];
            foreach (var zanr in zanrovi)
            {
                int index = _sviZanrovi.IndexOf(zanr);
                if (index >= 0) vektor[index] = 1;
            }
            return vektor;
        }

        private float[] OneHotKodirajGlumce(string[] glumci)
        {
            var vektor = new float[_sviGlumci.Count];
            foreach (var glumac in glumci)
            {
                int index = _sviGlumci.IndexOf(glumac);
                if (index >= 0) vektor[index] = 1;
            }
            return vektor;
        }

        private float IzracunajKosinusSlicnost(float[] v1, float[] v2)
        {
            if (v1.Length != v2.Length) throw new Exception("Vektori moraju biti iste dužine");

            float dot = 0;
            float normA = 0;
            float normB = 0;

            for (int i = 0; i < v1.Length; i++)
            {
                dot += v1[i] * v2[i];
                normA += v1[i] * v1[i];
                normB += v2[i] * v2[i];
            }

            return dot / (float)(Math.Sqrt(normA) * Math.Sqrt(normB) + 1e-5f);
        }

        private FilmDTO MapirajFilmDto(Filmovi film)
        {
            return new FilmDTO
            {
                Id = film.Id,
                Naslov = film.Naziv,
                Zanrovi = film.Žanrs.Select(g => g.Naziv).ToArray(),
                Glumci = film.Glumacs.Select(a => $"{a.Ime} {a.Prezime}").ToArray(),
                ImageBase64 = film.SlikaBase64
            };
        }
    }
}
