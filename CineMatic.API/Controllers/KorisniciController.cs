using CineMatic.Model;
using CineMatic.Model.Requests;
using CineMatic.Model.SearchObject;
using CineMatic.Services;
using Microsoft.AspNetCore.Mvc;

namespace CineMatic.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class KorisniciController : BaseCRUDController<Korisnici, KorisniciSearchObject, KorisniciInsertRequest, KorisniciUpdateRequest>
    {
        public KorisniciController(IKorisniciService service) : base(service)
        {
        }

        [HttpPost("login")]
        public ActionResult<Model.Korisnici> Login([FromBody] LoginRequest loginRequest)
        {
            var user = (_service as IKorisniciService).Login(loginRequest.Username, loginRequest.Password);
            if (user == null)
            {
                return Unauthorized("Pogresno korisnicko ime ili lozinka");
            }
            return Ok(user);
        }
    }
}
