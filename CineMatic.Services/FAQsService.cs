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
    public class FAQsService : BaseCRUDService<FAQs, FAQsSearchObject, Faq, FAQsUpsertRequest, FAQsUpsertRequest>, IFAQsService
    {
        public FAQsService(Ib210083Context context, IMapper mapper) : base(context, mapper)
        {
        }
        public override IQueryable<Faq> AddFilter(FAQsSearchObject search, IQueryable<Faq> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search?.PitanjeOdgovorGTE))
            {
                filteredQuery = query.Where(x => x.Pitanje.Contains(search.PitanjeOdgovorGTE) || x.Odgovor.Contains(search.PitanjeOdgovorGTE));
            }

            return filteredQuery;
        }
    }
}
