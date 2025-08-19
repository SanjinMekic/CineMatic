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
    public class ProjekcijeSjedištumService : BaseCRUDService<Model.ProjekcijeSjedištum, ProjekcijeSjedištumSearchObject, Database.ProjekcijeSjedištum, ProjekcijeSjedištumInsertRequest, ProjekcijeSjedištumUpdateRequest>, IProjekcijeSjedištumService
    {
        public ProjekcijeSjedištumService(Ib210083Context context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
