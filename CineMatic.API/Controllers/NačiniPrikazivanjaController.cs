using CineMatic.Model;
using CineMatic.Model.Requests;
using CineMatic.Model.SearchObject;
using CineMatic.Services;
using Microsoft.AspNetCore.Mvc;

namespace CineMatic.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class NačiniPrikazivanjaController : BaseCRUDController<NačiniPrikazivanja, NačiniPrikazivanjaSearchObject, NačiniPrikazivanjaUpsertRequest, NačiniPrikazivanjaUpsertRequest>
    {
        public NačiniPrikazivanjaController(INačiniPrikazivanjaService service) : base(service)
        {
        }
    }
}
