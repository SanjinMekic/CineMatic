using CineMatic.Services.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CineMatic.Services.UserAdminSeed
{
    public class UserAdminSeed : IUserAdminSeed
    {
        private readonly Ib210083Context _context;
        public UserAdminSeed(Ib210083Context context)
        {
            _context = context;
        }
        public async Task Ucitaj()
        {
            if (!_context.Korisnicis.Any(u => u.Email == "admin@gmail.com"))
            {
                var administrator = new Korisnici
                {
                    KorisnickoIme = "admin",
                    Email = "admin@gmail.com",
                    Ime = "Admin",
                    Prezime = "Admin"
                };

                var password = "admin";
                var salt = KorisniciService.GenerateSalt();
                var hashedPassword = KorisniciService.GenerateHash(salt, password);

                administrator.PasswordSalt = salt;
                administrator.PasswordHash = hashedPassword;

                _context.Korisnicis.Add(administrator);
                await _context.SaveChangesAsync();

                await _context.Database.ExecuteSqlInterpolatedAsync(
                    $"INSERT INTO KorisniciUloge (KorisnikID, UlogaID) VALUES ({administrator.Id}, 2)");
            }

            if (!_context.Korisnicis.Any(u => u.Email == "user@gmail.com"))
            {
                var korisnik = new Korisnici
                {
                    KorisnickoIme = "user",
                    Email = "user@gmail.com",
                    Ime = "User",
                    Prezime = "User"
                };

                var password = "user";
                var salt = KorisniciService.GenerateSalt();
                var hashedPassword = KorisniciService.GenerateHash(salt, password);

                korisnik.PasswordSalt = salt;
                korisnik.PasswordHash = hashedPassword;

                _context.Korisnicis.Add(korisnik);
                await _context.SaveChangesAsync();

                await _context.Database.ExecuteSqlInterpolatedAsync(
                    $"INSERT INTO KorisniciUloge (KorisnikID, UlogaID) VALUES ({korisnik.Id}, 1)");
            }

            if (!_context.Korisnicis.Any(u => u.Email == "blagajnik@gmail.com"))
            {
                var blagajnik = new Korisnici
                {
                    KorisnickoIme = "blagajnik",
                    Email = "blagajnik@gmail.com",
                    Ime = "Blagajnik",
                    Prezime = "Blagajnik"
                };

                var password = "blagajnik";
                var salt = KorisniciService.GenerateSalt();
                var hashedPassword = KorisniciService.GenerateHash(salt, password);

                blagajnik.PasswordSalt = salt;
                blagajnik.PasswordHash = hashedPassword;

                _context.Korisnicis.Add(blagajnik);
                await _context.SaveChangesAsync();

                await _context.Database.ExecuteSqlInterpolatedAsync(
                    $"INSERT INTO KorisniciUloge (KorisnikID, UlogaID) VALUES ({blagajnik.Id}, 3)");
            }

            await _context.SaveChangesAsync();
        }
    }
}
