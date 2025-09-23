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
    public class GlumciController : BaseCRUDController<Glumci, GlumciSearchObject, GLumciInsertRequest, GlumciUpdateRequest>
    {
        public GlumciController(IGlumciService service) : base(service)
        {
        }

        [Authorize(Roles = "Administrator")]
        public override Glumci Insert(GLumciInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Administrator")]
        public override Glumci Update(int id, GlumciUpdateRequest request)
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
