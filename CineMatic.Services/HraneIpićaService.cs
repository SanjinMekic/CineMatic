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
    public class HraneIpićaService : BaseCRUDService<Model.HraneIpića, HraneIpićaSearchObject, Database.HraneIpića, HraneIpićaInsertRequest, HraneIpićaUpdateRequest>, IHraneIpićaService
    {
        public HraneIpićaService(Ib210083Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<HraneIpića> AddFilter(HraneIpićaSearchObject search, IQueryable<HraneIpića> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search?.NazivGTE))
            {
                query = query.Where(x => x.Naziv.StartsWith(search.NazivGTE));
            }

            if (search.CijenaMin.HasValue)
            {
                query = query.Where(x => x.Cijena >= search.CijenaMin);
            }

            if (search.CijenaMax.HasValue)
            {
                query = query.Where(x => x.Cijena <= search.CijenaMax);
            }

            if (search.isKategorijeIncluded == true)
            {
                query = query.Include(x => x.Kategorija);
            }

            return query;
        }

        public override void BeforeInsert(HraneIpićaInsertRequest request, HraneIpića entity)
        {
            if (!string.IsNullOrEmpty(request.SlikaBase64))
            {
                entity.Slika = Convert.FromBase64String(request.SlikaBase64);
            }

            var kategorija = Context.KategorijeHraneIpićas.FirstOrDefault(u => u.Id == request.KategorijaId);
            if (kategorija == null)
                throw new Exception($"Kategorija sa ID {request.KategorijaId} nije pronađena");
        }

        public override void BeforeUpdate(HraneIpićaUpdateRequest request, HraneIpića entity)
        {
            var kategorija = Context.KategorijeHraneIpićas.FirstOrDefault(u => u.Id == request.KategorijaId);
            if (kategorija == null)
                throw new Exception($"Kategorija sa ID {request.KategorijaId} nije pronađena");
        }
    }
}
