using CineMatic.Model;
using CineMatic.Model.Requests;
using CineMatic.Model.SearchObject;
using CineMatic.Services;
using Microsoft.AspNetCore.Mvc;

namespace CineMatic.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class FAQsController : BaseCRUDController<FAQs, FAQsSearchObject, FAQsUpsertRequest, FAQsUpsertRequest>
    {
        public FAQsController(IFAQsService service) : base(service)
        {
        }
    }
}
