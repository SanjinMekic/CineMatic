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
    public class NačiniPrikazivanjaController : BaseCRUDController<NačiniPrikazivanja, NačiniPrikazivanjaSearchObject, NačiniPrikazivanjaUpsertRequest, NačiniPrikazivanjaUpsertRequest>
    {
        public NačiniPrikazivanjaController(INačiniPrikazivanjaService service) : base(service)
        {
        }

        [Authorize(Roles = "Administrator")]
        public override NačiniPrikazivanja Insert(NačiniPrikazivanjaUpsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Administrator")]
        public override NačiniPrikazivanja Update(int id, NačiniPrikazivanjaUpsertRequest request)
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
