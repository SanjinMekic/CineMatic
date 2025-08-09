using CineMatic.Model.Requests;
using CineMatic.Model.SearchObject;
using CineMatic.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CineMatic.Services
{
    public class GlumciService : BaseCRUDService<Model.Glumci, GlumciSearchObject, Database.Glumci, GLumciInsertRequest, GlumciUpdateRequest>, IGlumciService
    {
        public GlumciService(Ib210083Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Glumci> AddFilter(GlumciSearchObject search, IQueryable<Glumci> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.ImeGTE))
            {
                filteredQuery = filteredQuery.Where(x => x.Ime.StartsWith(search.ImeGTE));
            }

            if (!string.IsNullOrWhiteSpace(search.PrezimeGTE))
            {
                filteredQuery = filteredQuery.Where(x => x.Prezime.StartsWith(search.PrezimeGTE));
            }

            return filteredQuery;
        }

        public override Model.PagedResult<Model.Glumci> GetPaged(GlumciSearchObject search)
        {
            var pagedGlumci = base.GetPaged(search);

            foreach (var glumac in pagedGlumci.ResultList)
            {
                var databaseGlumac = Context.Set<Database.Glumci>().Find(glumac.Id);
                if(databaseGlumac != null)
                {
                    glumac.SlikaBase64 = databaseGlumac.Slika != null ? Convert.ToBase64String(databaseGlumac.Slika) : null;
                }
            }

            return pagedGlumci;
        }

        public override Model.Glumci GetById(int id)
        {
            var entity = Context.Set<Database.Glumci>().Find(id);

            if(entity != null)
            {
                var model = Mapper.Map<Model.Glumci>(entity);

                model.SlikaBase64 = entity.Slika != null ? Convert.ToBase64String(entity.Slika) : null;

                return model;
            }
            else
            {
                return null;
            }
        }

        public override Model.Glumci Insert(GLumciInsertRequest request)
        {
            var entity = Mapper.Map<Database.Glumci>(request);

            BeforeInsert(request, entity);

            Context.Add(entity);
            Context.SaveChanges();

            var model = Mapper.Map<Model.Glumci>(entity);

            model.SlikaBase64 = entity.Slika != null
                ? Convert.ToBase64String(entity.Slika)
                : null;

            return model;
        }

        public override Model.Glumci Update(int id, GlumciUpdateRequest request)
        {
            var set = Context.Set<Database.Glumci>();

            var entity = set.Find(id);

            if (entity == null)
                return null;

            Mapper.Map(request, entity);

            BeforeUpdate(request, entity);

            Context.SaveChanges();

            var model = Mapper.Map<Model.Glumci>(entity);

            model.SlikaBase64 = entity.Slika != null
                ? Convert.ToBase64String(entity.Slika)
                : null;

            return model;
        }

        public override void BeforeInsert(GLumciInsertRequest request, Glumci entity)
        {
            if (!string.IsNullOrEmpty(request.SlikaBase64))
            {
                entity.Slika = Convert.FromBase64String(request.SlikaBase64);
            }
        }

        public override void BeforeUpdate(GlumciUpdateRequest request, Glumci entity)
        {
            if (!string.IsNullOrEmpty(request.SlikaBase64))
            {
                entity.Slika = Convert.FromBase64String(request.SlikaBase64);
            }
        }
    }
}
