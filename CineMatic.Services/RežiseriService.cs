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
    public class RežiseriService : BaseCRUDService<Model.Režiseri, RežiseriSearchObject, Database.Režiseri, RežiseriInsertRequest, RežiseriUpdateRequest>, IRežiseriService
    {
        public RežiseriService(Ib210083Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Režiseri> AddFilter(RežiseriSearchObject search, IQueryable<Režiseri> query)
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

        public override Model.PagedResult<Model.Režiseri> GetPaged(RežiseriSearchObject search)
        {
            var pagedRežiseri = base.GetPaged(search);

            foreach (var režiser in pagedRežiseri.ResultList)
            {
                var databaseRežiser = Context.Set<Database.Režiseri>().Find(režiser.Id);
                if (databaseRežiser != null)
                {
                    režiser.SlikaBase64 = databaseRežiser.Slika != null ? Convert.ToBase64String(databaseRežiser.Slika) : null;
                }
            }

            return pagedRežiseri;
        }

        public override Model.Režiseri GetById(int id)
        {
            var entity = Context.Set<Database.Režiseri>().Find(id);

            if (entity != null)
            {
                var model = Mapper.Map<Model.Režiseri>(entity);

                model.SlikaBase64 = entity.Slika != null ? Convert.ToBase64String(entity.Slika) : null;

                return model;
            }
            else
            {
                return null;
            }
        }

        public override void BeforeInsert(RežiseriInsertRequest request, Režiseri entity)
        {
            if (!string.IsNullOrEmpty(request.SlikaBase64))
            {
                entity.Slika = Convert.FromBase64String(request.SlikaBase64);
            }
        }

        public override void BeforeUpdate(RežiseriUpdateRequest request, Režiseri entity)
        {
            if (!string.IsNullOrEmpty(request.SlikaBase64))
            {
                entity.Slika = Convert.FromBase64String(request.SlikaBase64);
            }
        }
    }
}
