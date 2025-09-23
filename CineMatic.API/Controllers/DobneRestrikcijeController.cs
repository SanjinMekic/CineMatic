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
    public class DobneRestrikcijeController : BaseCRUDController<DobneRestrikcije, DobneRestrikcijeSearchObject, DobneRestrikcijeInsertRequest, DobneRestrikcijeUpdateRequest>
    {
        public DobneRestrikcijeController(IDobneRestrikcijeService service) : base(service)
        {
        }

        [Authorize(Roles = "Administrator")]
        public override DobneRestrikcije Insert(DobneRestrikcijeInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Administrator")]
        public override void Delete(int id)
        {
            base.Delete(id);
        }

        [Authorize(Roles = "Administrator")]
        public override DobneRestrikcije Update(int id, DobneRestrikcijeUpdateRequest request)
        {
            return base.Update(id, request);
        }
    }
}
