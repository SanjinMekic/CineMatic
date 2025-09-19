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
    [AllowAnonymous]
    public class KorisniciController : BaseCRUDController<Korisnici, KorisniciSearchObject, KorisniciInsertRequest, KorisniciUpdateRequest>
    {
        private readonly IKorisniciService _service;
        public KorisniciController(IKorisniciService service) : base(service)
        {
            _service = service;
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

        [HttpPut("{id}/aktiviraj")]
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
