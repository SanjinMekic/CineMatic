using CineMatic.Model;
using CineMatic.Model.Requests;
using CineMatic.Model.SearchObject;
using CineMatic.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stripe;

namespace CineMatic.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class ProjekcijeController : BaseCRUDController<Projekcije, ProjekcijeSearchObject, ProjekcijeInsertRequest, ProjekcijeUpdateRequest>
    {
        private readonly IProjekcijeService _service;
        public ProjekcijeController(IProjekcijeService service) : base(service)
        {
            _service = service; 
        }

        [HttpGet("PoFilmu/{filmId}")]
        public IActionResult ProjekcijePoFilmId(int filmId)
        {
            try
            {
                var result = _service.GetProjekcijePoFilmId(filmId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet("Sjedista/{screeningId}")]
        public async Task<IActionResult> GetSeatsForScreening(int screeningId)
        {
            var seats = await _service.GetSjedistaZaProjekciju(screeningId);

            if (seats == null || seats.Count == 0)
            {
                return NotFound(new { message = "Nema dostupnih sjedista!" });
            }

            return Ok(seats);
        }
    }
}
