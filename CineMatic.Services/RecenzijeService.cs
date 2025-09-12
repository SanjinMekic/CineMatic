using CineMatic.Model;
using CineMatic.Model.Requests;
using CineMatic.Model.SearchObject;
using CineMatic.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CineMatic.Services
{
    public class RecenzijeService : BaseCRUDService<Model.Recenzije, RecenzijeSearchObject, Database.Rezencije, RecenzijeInsertRequest, RecenzijeUpdateRequest>, IRecenzijeService
    {
        readonly Ib210083Context _context;
        readonly IMapper _mapper;
        readonly IKorisniciService _korisniciService;
        public RecenzijeService(Ib210083Context context, IMapper mapper, IKorisniciService korisniciService) : base(context, mapper)
        {
            _context = context;
            _mapper = mapper;
            _korisniciService = korisniciService;
        }

        public override IQueryable<Database.Rezencije> AddFilter(RecenzijeSearchObject search, IQueryable<Database.Rezencije> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if(search.Ocjena.HasValue)
            {
                filteredQuery = filteredQuery.Where(x => x.Ocjena == search.Ocjena);
            }

            if(search.isKorisniciFilmoviIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.Korisnik).Include(x => x.Film);
            }

            return filteredQuery;
        }

        public override Model.Recenzije Insert(RecenzijeInsertRequest request)
        {
            if (request.Ocjena < 1 || request.Ocjena > 5)
            {
                throw new ArgumentOutOfRangeException(nameof(request.Ocjena), "Ocjena mora biti izmedju 1 i 5");
            }

            var currentUserId = _korisniciService.GetCurrentUserId();
            if (OcijenjenoPrije(currentUserId, request.FilmId))
            {
                throw new InvalidOperationException("Vec ste ocijenili ovaj film!");
            }

            request.KorisnikId = currentUserId;
            var rating = base.Insert(request);

            var user = Context.Korisnicis.Find(currentUserId);
            var movie = Context.Filmovis.Find(request.FilmId);

            if (user?.Slika != null)
            {
                rating.Korisnik.SlikaBase64 = Convert.ToBase64String(user.Slika);
            }

            rating.Film = Mapper.Map<Model.Filmovi>(movie);

            return rating;
        }

        public bool OcijenjenoPrije(int userId, int movieId)
        {
            return Context.Recenzijes.Any(r => r.KorisnikId == userId && r.FilmId == movieId);
        }

        public override void Delete(int id)
        {
            var rating = Context.Recenzijes.Find(id);
            if (rating == null)
            {
                throw new Exception("Recenzija nije pronadjena!");
            }

            var currentUserId = _korisniciService.GetCurrentUserId();
            var currentUserRoles = _korisniciService.GetCurrentUserRoles();

            if (!currentUserRoles.Contains("Administrator") && rating.KorisnikId != currentUserId)
            {
                throw new UnauthorizedAccessException("Mozete brisati samo vlastite recenzije");
            }

            Context.Recenzijes.Remove(rating);
            Context.SaveChanges();
        }

        public override Model.Recenzije Update(int id, RecenzijeUpdateRequest request)
        {
            if (request.Ocjena < 1 || request.Ocjena > 5)
            {
                throw new ArgumentOutOfRangeException(nameof(request.Ocjena), "Ocjena mora biti izmedju 1 i 5");
            }

            var rating = Context.Recenzijes.Include(r => r.Film).FirstOrDefault(r => r.Id == id);
            if (rating == null)
            {
                throw new Exception("Recenzija nije pronadjena!");
            }

            var currentUserId = _korisniciService.GetCurrentUserId();
            if (rating.KorisnikId != currentUserId)
            {
                throw new UnauthorizedAccessException("Mozete updateovati samo svoje komentare");
            }

            var updatedRating = base.Update(id, request);
            updatedRating.Film = Mapper.Map<Model.Filmovi>(rating.Film);

            return updatedRating;
        }

        public async Task<List<Model.Recenzije>> GetByFilmIdAsync(int filmId)
        {
            var query = _context.Recenzijes
                .Include(x => x.Korisnik)
                .Include(x => x.Film)
                .Where(x => x.FilmId == filmId);

            var entities = await query.ToListAsync();
            return _mapper.Map<List<Model.Recenzije>>(entities);
        }
    }
}
