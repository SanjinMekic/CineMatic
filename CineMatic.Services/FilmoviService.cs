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

            if (search.isDobneRestrikcijeIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.DobnaRestrikcija);
            }

            if (search.isGlumciIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.Glumacs).AsSplitQuery();
            }

            if (search.isRežiseriIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.Režisers).AsSplitQuery();
            }

            if (search.isŽanroviIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.Žanrs).AsSplitQuery();
            }

            return filteredQuery;
        }

        public override Model.PagedResult<Model.Filmovi> GetPaged(FilmoviSearchObject search)
        {
            var query = Context.Set<Database.Filmovi>().AsQueryable();
            query = AddFilter(search, query);

            int count = query.Count();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
                query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);

            var list = query.ToList();
            var result = Mapper.Map<List<Model.Filmovi>>(list);

            foreach (var film in result)
            {
                var dbFilm = list.First(x => x.Id == film.Id);
                film.SlikaBase64 = dbFilm.Slika != null ? Convert.ToBase64String(dbFilm.Slika) : null;

                if (search?.isGlumciIncluded == true && film.Glumacs != null)
                {
                    foreach (var glumac in film.Glumacs)
                    {
                        var dbGlumac = dbFilm.Glumacs?.FirstOrDefault(g => g.Id == glumac.Id);
                        if (dbGlumac != null)
                        {
                            glumac.SlikaBase64 = dbGlumac.Slika != null ? Convert.ToBase64String(dbGlumac.Slika) : null;
                        }
                    }
                }
                else
                {
                    film.Glumacs = new List<Model.Glumci>();
                }

                if (search?.isRežiseriIncluded == true && film.Režisers != null)
                {
                    foreach (var režiser in film.Režisers)
                    {
                        var dbGRežiser = dbFilm.Režisers?.FirstOrDefault(g => g.Id == režiser.Id);
                        if (dbGRežiser != null)
                        {
                            režiser.SlikaBase64 = dbGRežiser.Slika != null ? Convert.ToBase64String(dbGRežiser.Slika) : null;
                        }
                    }
                }
                else
                {
                    film.Režisers = new List<Model.Režiseri>();
                }

                if (search?.isŽanroviIncluded != true)
                {
                    film.Žanrs = new List<Model.Žanrovi>();
                }
            }

            return new Model.PagedResult<Model.Filmovi>
            {
                ResultList = result,
                Count = count
            };
        }

        public override Model.Filmovi GetById(int id)
        {
            var entity = Context.Filmovis.Include(f => f.DobnaRestrikcija)
                                         .Include(f => f.Glumacs)
                                         .Include(f => f.Režisers)
                                         .Include(f => f.Žanrs).AsSplitQuery()
                                         .FirstOrDefault(f => f.Id == id);

            if (entity != null)
            {
                var filmModel = Mapper.Map<Model.Filmovi>(entity);

                filmModel.SlikaBase64 = entity.Slika != null ? Convert.ToBase64String(entity.Slika) : null;

                if (entity.Glumacs != null)
                {
                    foreach (var glumac in filmModel.Glumacs)
                    {
                        var dbGlumac = entity.Glumacs.FirstOrDefault(a => a.Id == glumac.Id);
                        if (dbGlumac != null)
                        {
                            glumac.SlikaBase64 = dbGlumac.Slika != null ? Convert.ToBase64String(dbGlumac.Slika) : null;
                        }
                    }

                    foreach (var režiser in filmModel.Režisers)
                    {
                        var dbRežiser = entity.Režisers.FirstOrDefault(a => a.Id == režiser.Id);
                        if (dbRežiser != null)
                        {
                            režiser.SlikaBase64 = dbRežiser.Slika != null ? Convert.ToBase64String(dbRežiser.Slika) : null;
                        }
                    }
                }

                return filmModel;
            }
            else return null;
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

            if (request.GlumciID != null)
            {
                foreach (var glumacId in request.GlumciID)
                {
                    var glumac = Context.Glumcis.FirstOrDefault(a => a.Id == glumacId);
                    if (glumac == null)
                        throw new Exception($"Glumac sa ID: {glumacId} nije pronadjen");

                    entity.Glumacs.Add(glumac);
                }
            }

            if (request.RežiseriID != null)
            {
                foreach (var režiserId in request.RežiseriID)
                {
                    var režiser = Context.Režiseris.FirstOrDefault(a => a.Id == režiserId);
                    if (režiser == null)
                        throw new Exception($"Režiser sa ID: {režiserId} nije pronadjen");

                    entity.Režisers.Add(režiser);
                }
            }

            if (request.ŽanroviID != null)
            {
                foreach (var žanrId in request.ŽanroviID)
                {
                    var žanr = Context.Žanrovis.FirstOrDefault(a => a.Id == žanrId);
                    if (žanr == null)
                        throw new Exception($"Žanr sa ID: {žanrId} nije pronadjen");

                    entity.Žanrs.Add(žanr);
                }
            }
        }

        public override void BeforeUpdate(FilmoviUpdateRequest request, Filmovi entity)
        {
            if (!string.IsNullOrEmpty(request.SlikaBase64))
            {
                entity.Slika = Convert.FromBase64String(request.SlikaBase64);
            }

            Context.Entry(entity).Collection(e => e.Glumacs).Load();
            Context.Entry(entity).Collection(e => e.Režisers).Load();
            Context.Entry(entity).Collection(e => e.Žanrs).Load();

            if (request.GlumciID != null)
            {
                entity.Glumacs.Clear();
                foreach (var glumacId in request.GlumciID)
                {
                    var glumac = Context.Glumcis.FirstOrDefault(a => a.Id == glumacId);
                    if (glumac == null)
                        throw new Exception($"Glumac sa ID: {glumacId} nije pronađen");

                    if (!entity.Glumacs.Any(g => g.Id == glumacId))
                    {
                        entity.Glumacs.Add(glumac);
                    }
                }
            }

            if (request.RežiseriID != null)
            {
                entity.Režisers.Clear();
                foreach (var režiserId in request.RežiseriID)
                {
                    var režiser = Context.Režiseris.FirstOrDefault(a => a.Id == režiserId);
                    if (režiser == null)
                        throw new Exception($"Režiser sa ID: {režiserId} nije pronađen");

                    if (!entity.Režisers.Any(g => g.Id == režiserId))
                    {
                        entity.Režisers.Add(režiser);
                    }
                }
            }

            if (request.ŽanroviID != null)
            {
                entity.Žanrs.Clear();
                foreach (var žanrId in request.ŽanroviID)
                {
                    var žanr = Context.Žanrovis.FirstOrDefault(a => a.Id == žanrId);
                    if (žanr == null)
                        throw new Exception($"Žanr sa ID: {žanrId} nije pronađen");

                    if (!entity.Žanrs.Any(g => g.Id == žanrId))
                    {
                        entity.Žanrs.Add(žanr);
                    }
                }
            }
        }
    }
}
