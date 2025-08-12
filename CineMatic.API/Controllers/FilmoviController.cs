using CineMatic.Model;
using CineMatic.Model.Requests;
using CineMatic.Model.SearchObject;
using CineMatic.Services;
using Microsoft.AspNetCore.Mvc;

namespace CineMatic.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class FilmoviController : BaseCRUDController<Filmovi, FilmoviSearchObject, FilmoviInsertRequest, FilmoviUpdateRequest>
    {
        public FilmoviController(IFilmoviService service) : base(service)
        {
        }
    }
}
