using CineMatic.Model;
using CineMatic.Model.Requests;
using CineMatic.Model.SearchObject;
using CineMatic.Services;
using Microsoft.AspNetCore.Mvc;

namespace CineMatic.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class DobneRestrikcijeController : BaseCRUDController<DobneRestrikcije, DobneRestrikcijeSearchObject, DobneRestrikcijeInsertRequest, DobneRestrikcijeUpdateRequest>
    {
        public DobneRestrikcijeController(IDobneRestrikcijeService service) : base(service)
        {
        }
    }
}
