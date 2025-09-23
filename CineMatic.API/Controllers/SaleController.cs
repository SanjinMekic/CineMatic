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
    public class SaleController : BaseCRUDController<Sale, SaleSearchObject, SaleUpsertRequest, SaleUpsertRequest>
    {
        public SaleController(ISaleService service) : base(service)
        {
        }

        [Authorize(Roles = "Administrator")]
        public override Sale Insert(SaleUpsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Administrator")]
        public override Sale Update(int id, SaleUpsertRequest request)
        {
            return base.Update(id, request);
        }

        [Authorize(Roles = "Administrator")]
        public override void Delete(int id)
        {
            base.Delete(id);
        }
    }
}
