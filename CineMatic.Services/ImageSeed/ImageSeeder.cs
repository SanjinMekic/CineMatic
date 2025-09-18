using CineMatic.Services.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CineMatic.Services.ImageSeeder
{
    public class ImageSeeder : IImageSeeder
    {
        private readonly Ib210083Context _context;
        private readonly string _putanjaDoSlika;

        public ImageSeeder(Ib210083Context context, string putanjaDoSlika)
        {
            _context = context;
            _putanjaDoSlika = putanjaDoSlika;
        }
        public async Task UcitajSlike()
        {
            var filmovi = await _context.Filmovis.Where(m => m.Slika == null).ToListAsync();
            var glumci = await _context.Glumcis.Where(m => m.Slika == null).ToListAsync();
            var reziseri = await _context.Režiseris.Where(m => m.Slika == null).ToListAsync();
            var hrane = await _context.HraneIpićas.Where(a => a.Slika == null).ToListAsync();

            foreach (var film in filmovi)
            {
                var putanjaSlike = Path.Combine(_putanjaDoSlika, $"film{film.Id}.jpg");
                if (File.Exists(putanjaSlike))
                {
                    film.Slika = await File.ReadAllBytesAsync(putanjaSlike);
                }
            }

            foreach (var glumac in glumci)
            {
                var putanjaSlike = Path.Combine(_putanjaDoSlika, $"glumac{glumac.Id}.jpg");
                if (File.Exists(putanjaSlike))
                {
                    glumac.Slika = await File.ReadAllBytesAsync(putanjaSlike);
                }
            }

            foreach (var reziser in reziseri)
            {
                var putanjaSlike = Path.Combine(_putanjaDoSlika, $"reziser{reziser.Id}.jpg");
                if (File.Exists(putanjaSlike))
                {
                    reziser.Slika = await File.ReadAllBytesAsync(putanjaSlike);
                }
            }

            foreach (var hrana in hrane)
            {
                var putanjaSlike = Path.Combine(_putanjaDoSlika, $"hrana{hrana.Id}.jpg");
                if (File.Exists(putanjaSlike))
                {
                    hrana.Slika = await File.ReadAllBytesAsync(putanjaSlike);
                }
            }

            await _context.SaveChangesAsync();
        }
    }
}
