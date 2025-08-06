using CineMatic.Model;
using CineMatic.Model.Requests;
using CineMatic.Model.SearchObject;
using CineMatic.Services;
using Microsoft.AspNetCore.Mvc;

namespace CineMatic.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class HraneIpićaController : BaseCRUDController<HraneIpića, HraneIpićaSearchObject, HraneIpićaInsertRequest, HraneIpićaUpdateRequest>
    {
        public HraneIpićaController(IHraneIpićaService service) : base(service)
        {
        }
    }
}
