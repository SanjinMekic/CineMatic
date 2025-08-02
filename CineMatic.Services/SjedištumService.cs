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
    public class SjedištumService : BaseCRUDService<Model.Sjedištum, SjedištumSearchObject, Database.Sjedištum, SjedištumUpsertRequest, SjedištumUpsertRequest>, ISjedištumService
    {
        public SjedištumService(Ib210083Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Sjedištum> AddFilter(SjedištumSearchObject search, IQueryable<Sjedištum> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search?.NazivGTE))
            {
                filteredQuery = filteredQuery.Where(x => x.Naziv.Contains(search.NazivGTE));
            }

            return filteredQuery;
        }
    }
}
