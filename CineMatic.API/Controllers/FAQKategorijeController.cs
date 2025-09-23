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
    public class FAQKategorijeController : BaseCRUDController<Faqkategorije, FAQKategorijeSearchObject, FAQKategorijeUpsertRequest, FAQKategorijeUpsertRequest>
    {
        public FAQKategorijeController(IFAQKategorijeService service) : base(service)
        {
        }

        [Authorize(Roles = "Administrator")]
        public override Faqkategorije Insert(FAQKategorijeUpsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Administrator")]
        public override Faqkategorije Update(int id, FAQKategorijeUpsertRequest request)
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
