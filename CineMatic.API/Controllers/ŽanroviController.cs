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
    public class ŽanroviController : BaseCRUDController<Žanrovi, ŽanroviSearchObject, ŽanroviUpsertRequest, ŽanroviUpsertRequest>
    {
        public ŽanroviController(IŽanroviService service) : base(service)
        {
        }

        [Authorize(Roles = "Administrator")]
        public override Žanrovi Insert(ŽanroviUpsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Administrator")]
        public override Žanrovi Update(int id, ŽanroviUpsertRequest request)
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
