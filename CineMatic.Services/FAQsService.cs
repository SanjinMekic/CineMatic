using CineMatic.Model;
using CineMatic.Model.Requests;
using CineMatic.Model.SearchObject;
using CineMatic.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CineMatic.Services
{
    public class FAQsService : BaseCRUDService<Model.Faq, FAQsSearchObject, Database.Faq, FAQsUpsertRequest, FAQsUpsertRequest>, IFAQsService
    {
        public FAQsService(Ib210083Context context, IMapper mapper) : base(context, mapper)
        {
        }
        public override IQueryable<Database.Faq> AddFilter(FAQsSearchObject search, IQueryable<Database.Faq> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search?.PitanjeOdgovorGTE))
            {
                filteredQuery = query.Where(x => x.Pitanje.Contains(search.PitanjeOdgovorGTE) || x.Odgovor.Contains(search.PitanjeOdgovorGTE));
            }

            filteredQuery = filteredQuery.Include(x => x.Kategorija);

            return filteredQuery;
        }

        public override void BeforeInsert(FAQsUpsertRequest request, Database.Faq entity)
        {
            base.BeforeInsert(request, entity);

            var kategorija = Context.Faqkategorijes.FirstOrDefault(u => u.Id == request.KategorijaId);
            if (kategorija == null)
                throw new Exception($"Kategorija sa ID {request.KategorijaId} nije pronađena");
        }

        public override void BeforeUpdate(FAQsUpsertRequest request, Database.Faq entity)
        {
            base.BeforeUpdate(request, entity);
            var kategorija = Context.Faqkategorijes.FirstOrDefault(u => u.Id == request.KategorijaId);
            if (kategorija == null)
                throw new Exception($"Kategorija sa ID {request.KategorijaId} nije pronađena");
        }
    }
}
