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
    public class HraneIpićaController : BaseCRUDController<HraneIpića, HraneIpićaSearchObject, HraneIpićaInsertRequest, HraneIpićaUpdateRequest>
    {
        public HraneIpićaController(IHraneIpićaService service) : base(service)
        {
        }

        [Authorize(Roles = "Administrator")]
        public override HraneIpića Insert(HraneIpićaInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Administrator")]
        public override HraneIpića Update(int id, HraneIpićaUpdateRequest request)
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
