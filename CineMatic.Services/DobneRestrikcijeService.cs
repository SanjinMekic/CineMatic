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
    public class DobneRestrikcijeService : BaseCRUDService<Model.DobneRestrikcije, DobneRestrikcijeSearchObject, Database.DobneRestrikcije, DobneRestrikcijeInsertRequest, DobneRestrikcijeUpdateRequest>, IDobneRestrikcijeService
    {
        public DobneRestrikcijeService(Ib210083Context context, IMapper mapper) : base(context, mapper)
        {
        }
        public override IQueryable<DobneRestrikcije> AddFilter(DobneRestrikcijeSearchObject search, IQueryable<DobneRestrikcije> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search?.RestrikcijaOrOpis))
            {
                filteredQuery = query.Where(x => x.Restrikcija.Contains(search.RestrikcijaOrOpis) || x.Opis.Contains(search.RestrikcijaOrOpis));
            }

            return filteredQuery;
        }
    }
}
