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
    public class KategorijeHraneIpićaController : BaseCRUDController<KategorijeHraneIpića, KategorijeHraneIpićaSearchObject, KategorijeHraneIpićaUpsertRequest, KategorijeHraneIpićaUpsertRequest>
    {
        public KategorijeHraneIpićaController(IKategorijeHraneIpićaService service) : base(service)
        {
        }

        [Authorize(Roles = "Administrator")]
        public override KategorijeHraneIpića Insert(KategorijeHraneIpićaUpsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Administrator")]
        public override KategorijeHraneIpića Update(int id, KategorijeHraneIpićaUpsertRequest request)
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
