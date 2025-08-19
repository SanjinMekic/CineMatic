using CineMatic.Model;
using CineMatic.Model.Requests;
using CineMatic.Model.SearchObject;
using CineMatic.Services;
using Microsoft.AspNetCore.Mvc;

namespace CineMatic.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ProjekcijeController : BaseCRUDController<Projekcije, ProjekcijeSearchObject, ProjekcijeInsertRequest, ProjekcijeUpdateRequest>
    {
        public ProjekcijeController(IProjekcijeService service) : base(service)
        {
        }
    }
}
