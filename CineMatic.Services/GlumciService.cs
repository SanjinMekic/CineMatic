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
