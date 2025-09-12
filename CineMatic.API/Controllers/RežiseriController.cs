using CineMatic.Model;
using CineMatic.Model.Requests;
using CineMatic.Model.SearchObject;
using CineMatic.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CineMatic.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class RežiseriController : BaseCRUDController<Režiseri, RežiseriSearchObject, RežiseriInsertRequest, RežiseriUpdateRequest>
    {
        public RežiseriController(IRežiseriService service) : base(service)
        {
        }
    }
}
