using CineMatic.Model;
using CineMatic.Model.Requests;
using CineMatic.Model.SearchObject;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CineMatic.Services
{
    public interface IUlogeService : ICRUDService<Uloge, UlogeSearchObject, UlogeUpsertRequest, UlogeUpsertRequest>
    {
    }
}
