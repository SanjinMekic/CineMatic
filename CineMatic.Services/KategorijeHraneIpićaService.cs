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
    public class KategorijeHraneIpićaService : BaseCRUDService<Model.KategorijeHraneIpića, KategorijeHraneIpićaSearchObject, Database.KategorijeHraneIpića, KategorijeHraneIpićaUpsertRequest, KategorijeHraneIpićaUpsertRequest>, IKategorijeHraneIpićaService
    {
        public KategorijeHraneIpićaService(Ib210083Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<KategorijeHraneIpića> AddFilter(KategorijeHraneIpićaSearchObject search, IQueryable<KategorijeHraneIpića> query)
        {
            var filteredQuery =  base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.NazivGTE))
            {
                filteredQuery = filteredQuery.Where(x => x.Naziv.Contains(search.NazivGTE));
            }

            return filteredQuery;
        }
    }
}
