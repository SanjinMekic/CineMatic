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
    public class FAQsController : BaseCRUDController<Faq, FAQsSearchObject, FAQsUpsertRequest, FAQsUpsertRequest>
    {
        public FAQsController(IFAQsService service) : base(service)
        {
        }

        [Authorize(Roles = "Administrator")]
        public override Faq Insert(FAQsUpsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Administrator")]
        public override Faq Update(int id, FAQsUpsertRequest request)
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
