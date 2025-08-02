using CineMatic.Model;
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
    public class ŽanroviService : BaseCRUDService<Model.Žanrovi, ŽanroviSearchObject, Database.Žanrovi, ŽanroviUpsertRequest, ŽanroviUpsertRequest>, IŽanroviService
    {
        public ŽanroviService(Ib210083Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Database.Žanrovi> AddFilter(ŽanroviSearchObject search, IQueryable<Database.Žanrovi> query)
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
