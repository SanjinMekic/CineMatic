using CineMatic.Model.Requests;
using CineMatic.Model.SearchObject;
using CineMatic.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CineMatic.Services
{
    public class FilmoviService : BaseCRUDService<Model.Filmovi, FilmoviSearchObject, Database.Filmovi, FilmoviInsertRequest, FilmoviUpdateRequest>, IFilmoviService
    {
        public FilmoviService(Ib210083Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Filmovi> AddFilter(FilmoviSearchObject search, IQueryable<Filmovi> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.NazivGTE))
            {
                filteredQuery = filteredQuery.Where(x => x.Naziv.StartsWith(search.NazivGTE));
            }

            if(search.isDobneRestrikcijeIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.DobnaRestrikcija);
            }

            return filteredQuery;
        }

        public override Model.PagedResult<Model.Filmovi> GetPaged(FilmoviSearchObject search)
        {
            var pagedFilmovi = base.GetPaged(search);

            foreach (var film in pagedFilmovi.ResultList)
            {
                var databaseFilm = Context.Set<Database.Glumci>().Find(film.Id);
                if (databaseFilm != null)
                {
                    film.SlikaBase64 = databaseFilm.Slika != null ? Convert.ToBase64String(databaseFilm.Slika) : null;
                }
            }

            return pagedFilmovi;
        }

        public override Model.Filmovi GetById(int id)
        {
            var entity = Context.Set<Database.Filmovi>().Find(id);

            if (entity != null)
            {
                var model = Mapper.Map<Model.Filmovi>(entity);

                model.SlikaBase64 = entity.Slika != null ? Convert.ToBase64String(entity.Slika) : null;

                return model;
            }
            else
            {
                return null;
            }
        }

        public override Model.Filmovi Insert(FilmoviInsertRequest request)
        {
            var entity = Mapper.Map<Database.Filmovi>(request);

            BeforeInsert(request, entity);

            Context.Add(entity);
            Context.SaveChanges();

            var model = Mapper.Map<Model.Filmovi>(entity);

            model.SlikaBase64 = entity.Slika != null
                ? Convert.ToBase64String(entity.Slika)
                : null;

            return model;
        }

        public override Model.Filmovi Update(int id, FilmoviUpdateRequest request)
        {
            var set = Context.Set<Database.Filmovi>();

            var entity = set.Find(id);

            if (entity == null)
                return null;

            Mapper.Map(request, entity);

            BeforeUpdate(request, entity);

            Context.SaveChanges();

            var model = Mapper.Map<Model.Filmovi>(entity);

            model.SlikaBase64 = entity.Slika != null
                ? Convert.ToBase64String(entity.Slika)
                : null;

            return model;
        }

        public override void BeforeInsert(FilmoviInsertRequest request, Filmovi entity)
        {
            if (!string.IsNullOrEmpty(request.SlikaBase64))
            {
                entity.Slika = Convert.FromBase64String(request.SlikaBase64);
            }

            var dobnaRestrikcija = Context.DobneRestrikcijes.FirstOrDefault(u => u.Id == request.DobnaRestrikcijaId);
            if (dobnaRestrikcija == null)
                throw new Exception($"Dobna restrikcija sa ID {request.DobnaRestrikcijaId} nije pronađena");
        }

        public override void BeforeUpdate(FilmoviUpdateRequest request, Filmovi entity)
        {
            if (!string.IsNullOrEmpty(request.SlikaBase64))
            {
                entity.Slika = Convert.FromBase64String(request.SlikaBase64);
            }

            if (request.DobnaRestrikcijaId.HasValue)
            {
                var dobnaRestrikcija = Context.KategorijeHraneIpićas
                    .FirstOrDefault(u => u.Id == request.DobnaRestrikcijaId.Value);

                if (dobnaRestrikcija == null)
                    throw new Exception($"Kategorija sa ID {request.DobnaRestrikcijaId} nije pronađena");
            }
        }
    }
}
