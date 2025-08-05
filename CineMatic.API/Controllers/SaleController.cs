using CineMatic.Model;
using CineMatic.Model.Requests;
using CineMatic.Model.SearchObject;
using CineMatic.Services;
using Microsoft.AspNetCore.Mvc;

namespace CineMatic.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class SaleController : BaseCRUDController<Sale, SaleSearchObject, SaleUpsertRequest, SaleUpsertRequest>
    {
        public SaleController(ISaleService service) : base(service)
        {
        }
    }
}
