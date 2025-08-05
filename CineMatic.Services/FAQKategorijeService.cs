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
    public class FAQKategorijeService : BaseCRUDService<Model.Faqkategorije, FAQKategorijeSearchObject, Database.Faqkategorije, FAQKategorijeUpsertRequest, FAQKategorijeUpsertRequest>, IFAQKategorijeService
    {
        public FAQKategorijeService(Ib210083Context context, IMapper mapper) : base(context, mapper)
        {
        }
        public override IQueryable<Database.Faqkategorije> AddFilter(FAQKategorijeSearchObject search, IQueryable<Database.Faqkategorije> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search?.NazivGTE))
            {
                filteredQuery = query.Where(x => x.Naziv.Contains(search.NazivGTE));
            }

            return filteredQuery;
        }
    }
}
