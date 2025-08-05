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
    public class SaleService : BaseCRUDService<Model.Sale, SaleSearchObject, Database.Sale, SaleUpsertRequest, SaleUpsertRequest>, ISaleService
    {
        public SaleService(Ib210083Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Sale> AddFilter(SaleSearchObject search, IQueryable<Sale> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.NazivGTE))
            {
                query = query.Where(x => x.Naziv.StartsWith(search.NazivGTE));
            }

            return query;
        }
    }
}
