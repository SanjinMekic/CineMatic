using CineMatic.Model.Requests;
using CineMatic.Model.SearchObject;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CineMatic.Services
{
    public interface ISjedištumService : ICRUDService<Model.Sjedištum, SjedištumSearchObject, SjedištumUpsertRequest, SjedištumUpsertRequest>
    {
    }
}
