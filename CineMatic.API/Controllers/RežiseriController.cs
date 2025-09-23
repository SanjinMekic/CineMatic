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

        [Authorize(Roles = "Administrator")]
        public override Režiseri Insert(RežiseriInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Administrator")]
        public override Režiseri Update(int id, RežiseriUpdateRequest request)
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
