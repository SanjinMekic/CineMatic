using CineMatic.Model.Izvjestaji;
using CineMatic.Services.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CineMatic.Services
{
    public class IzvjestajiService : IIzvjestajiService
    {
        private readonly Ib210083Context _context;

        public IzvjestajiService(Ib210083Context context)
        {
            _context = context;
        }
        public async Task<int> GetUserCountAsync()
        {
            var brojKorisnika = await _context.Korisnicis
                .Where(u => u.Ulogas.Any(r => r.Naziv == "Korisnik"))
                .CountAsync();

            return brojKorisnika;
        }

        public async Task<int> GetAdminCountAsync()
        {
            var brojAdmina = await _context.Korisnicis
                .Where(u => u.Ulogas.Any(r => r.Naziv == "Administrator"))
                .CountAsync();

            return brojAdmina;
        }

        public async Task<int> GetBlagajnikCountAsync()
        {
            var brojAdmina = await _context.Korisnicis
                .Where(u => u.Ulogas.Any(r => r.Naziv == "Blagajnik"))
                .CountAsync();

            return brojAdmina;
        }

        public async Task<decimal> GetFoodAndDrinkIncome()
        {
            var ukupnaCijena = await _context.RezervacijeHraneIpićas
            .SumAsync(r => (decimal?)r.HranaIpiće.Cijena);

            return ukupnaCijena ?? 0;
        }

        public async Task<decimal> GetTotalCinemaIncomeAsync()
        {
            var totalIncome = await _context.Rezervacijes
                .Where(r => r.NačinPlaćanja == "Gotovina" || r.NačinPlaćanja == "Stripe")
                .SumAsync(r => r.UkupnaCijena);

            return totalIncome ?? 0;
        }

        public async Task<List<TopKorisnik>> GetTop5CustomersAsync()
        {
            var top5korisnika = await _context.Rezervacijes
                .GroupBy(r => r.KorisnikId)
                .Select(g => new TopKorisnik
                {
                    Korisnikd = g.Key,
                    Ime = g.FirstOrDefault().Korisnik.Ime,
                    Prezime = g.FirstOrDefault().Korisnik.Prezime,
                    UkupnoPotrosenoNovca = g.Sum(r => r.UkupnaCijena) ?? 0
                })
                .OrderByDescending(c => c.UkupnoPotrosenoNovca)
                .Take(5)
                .ToListAsync();

            return top5korisnika;
        }

        public async Task<List<BrojSjedistaPoFilmu>> GetTop5WatchedMoviesAsync()
        {
            var top5Movies = await _context.Rezervacijes
                .SelectMany(r => r.RezervacijeSjedišta)
                .GroupBy(rs => rs.Rezervacija.Projekcija.FilmId)
                .Select(g => new BrojSjedistaPoFilmu
                {
                    FilmId = g.Key ?? 0,
                    Naziv = g.FirstOrDefault().Rezervacija.Projekcija.Film.Naziv,
                    BrojSjedista = g.Count()
                })
                .OrderByDescending(m => m.BrojSjedista)
                .Take(5)
                .ToListAsync();

            return top5Movies;
        }
    }
}
