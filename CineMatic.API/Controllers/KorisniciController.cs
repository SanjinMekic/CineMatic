using CineMatic.Model;
using CineMatic.Model.Requests;
using CineMatic.Model.SearchObject;
using CineMatic.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace CineMatic.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class KorisniciController : BaseCRUDController<Korisnici, KorisniciSearchObject, KorisniciInsertRequest, KorisniciUpdateRequest>
    {
        private readonly IKorisniciService _service;
        public KorisniciController(IKorisniciService service) : base(service)
        {
            _service = service;
        }

        [HttpPost("login")]
        [AllowAnonymous]
        public ActionResult<Model.Korisnici> Login([FromBody] LoginRequest loginRequest)
        {
            var user = (_service as IKorisniciService).Login(loginRequest.Username, loginRequest.Password);
            if (user == null)
            {
                return Unauthorized("Pogresno korisnicko ime ili lozinka");
            }
            return Ok(user);
        }

        [AllowAnonymous]
        public override Korisnici Insert(KorisniciInsertRequest request)
        {
            return base.Insert(request);
        }

        [AllowAnonymous]
        public override PagedResult<Korisnici> GetList([FromQuery] KorisniciSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [HttpGet("provjeri-korisnicko-ime")]
        [AllowAnonymous]
        public async Task<IActionResult> ProvjeriKorisnickoIme(string username)
        {
            var isTaken = await _service.ProvjeriKorisnickoIme(username);
            return Ok(isTaken);
        }

        [AllowAnonymous]
        public override Korisnici Update(int id, KorisniciUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [HttpPut("{id}/aktiviraj")]
        [Authorize(Roles = "Administrator")]
        public IActionResult AktivirajObrisanogKorisnika(int id)
        {
            try
            {
                _service.AktivirajObrisanogKorisnika(id);
                return Ok($"Korisnik sa ID {id} je uspješno aktiviran.");
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(ex.Message);
            }
        }
    }
}
