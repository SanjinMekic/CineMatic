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
    public class RecenzijeService : BaseCRUDService<Model.Rezencije, RecenzijeSearchObject, Database.Rezencije, RecenzijeInsertRequest, RecenzijeUpdateRequest>, IRecenzijeService
    {
        public RecenzijeService(Ib210083Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Database.Rezencije> AddFilter(RecenzijeSearchObject search, IQueryable<Database.Rezencije> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if(search.Ocjena.HasValue)
            {
                filteredQuery = filteredQuery.Where(x => x.Ocjena == search.Ocjena);
            }

            if(search.isKorisniciFilmoviIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.Korisnik).Include(x => x.Film);
            }

            return filteredQuery;
        }
    }
}
