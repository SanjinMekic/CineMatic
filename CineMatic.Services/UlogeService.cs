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
    public class UlogeService : BaseCRUDService<Model.Uloge, UlogeSearchObject, Database.Uloge, UlogeUpsertRequest, UlogeUpsertRequest>, IUlogeService
    {
        public UlogeService(Ib210083Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Uloge> AddFilter(UlogeSearchObject search, IQueryable<Uloge> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.NazivGTE))
            {
                filteredQuery = filteredQuery.Where(x => x.Naziv.StartsWith(search.NazivGTE));
            }

            return filteredQuery;
        }
    }
}
