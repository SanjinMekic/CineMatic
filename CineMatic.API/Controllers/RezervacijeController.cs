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
    public class RezervacijeController : BaseCRUDController<Rezervacije, RezervacijeSearchObject, RezervacijeInsertRequest, RezervacijeUpdateRequest>
    {
        public RezervacijeController(IRezervacijeService service) : base(service)
        {
        }

        [HttpGet("projekcija/{projekcijaId}")]
        [Authorize(Roles = "Administrator")]
        public ActionResult<List<Rezervacije>> GetReservationsByScreeningId(int projekcijaId)
        {
            try
            {
                var rezervacije = ((RezervacijeService)_service).RezervacijePoProjekcijaId(projekcijaId);
                return Ok(rezervacije);
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }

        [HttpGet("projekcijaKorisnik/{korisnikId}")]
        [Authorize(Roles = "Korisnik")]
        public ActionResult<List<Rezervacije>> GetReservationsByUserId(int korisnikId)
        {
            try
            {
                var rezervacije = ((RezervacijeService)_service).RezervacijaPoKorisnikId(korisnikId);
                return Ok(rezervacije);
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }
    }
}
