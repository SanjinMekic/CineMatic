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
