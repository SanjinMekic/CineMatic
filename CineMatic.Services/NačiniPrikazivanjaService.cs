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
    public class NačiniPrikazivanjaService : BaseCRUDService<Model.NačiniPrikazivanja, NačiniPrikazivanjaSearchObject, Database.NačiniPrikazivanja, NačiniPrikazivanjaUpsertRequest, NačiniPrikazivanjaUpsertRequest>, INačiniPrikazivanjaService
    {
        public NačiniPrikazivanjaService(Ib210083Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<NačiniPrikazivanja> AddFilter(NačiniPrikazivanjaSearchObject search, IQueryable<NačiniPrikazivanja> query)
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
