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
    public class RecenzijeController : BaseCRUDController<Recenzije, RecenzijeSearchObject, RecenzijeInsertRequest, RecenzijeUpdateRequest>
    {
        readonly IRecenzijeService _service;
        public RecenzijeController(IRecenzijeService service) : base(service)
        {
            _service = service; 
        }

        [HttpGet("ByFilm/{filmId}")]
        public async Task<IActionResult> GetByFilm(int filmId)
        {
            var result = await _service.GetByFilmIdAsync(filmId);
            return Ok(result);
        }

        [HttpGet("ByFilmAndRating/{filmId}")]
        public async Task<IActionResult> GetByFilmAndRating(int filmId, [FromQuery] int? ocjena)
        {
            var result = await _service.GetByFilmIdAndRatingAsync(filmId, ocjena);
            return Ok(result);
        }

        [HttpGet("prosjecnaOcjena/{filmId}")]
        public IActionResult GetAverageRating(int filmId)
        {
            var prosjecnaOcjena = _service.ProsjecnaOcjena(filmId);
            return Ok(new { ocjena = prosjecnaOcjena });
        }

        [HttpGet("vecOcijenjeno/{korisnikId}/{filmId}")]
        public IActionResult ProvjeriDaLiJeVecOcijenjenFilm(int korisnikId, int filmId)
        {
            var prosjecnaOcjena = _service.OcijenjenoPrije(korisnikId, filmId);
            return Ok(new { ocjena = prosjecnaOcjena });
        }

        [HttpPost]
        public override Recenzije Insert(RecenzijeInsertRequest request)
        {
            if (User.IsInRole("Korisnik"))
            {
                return _service.Insert(request);
            }
            throw new ForbidException("Samo korisnici sa ulogom 'Korisnik' mogu dodavati recenzije");
        }

        [HttpPut("{id}")]
        public override Recenzije Update(int id, RecenzijeUpdateRequest request)
        {
            if (User.IsInRole("Korisnik"))
            {
                return _service.Update(id, request);
            }
            throw new ForbidException("Samo korisnici sa ulogom 'Korisnik' mogu uredjivati recenzije");
        }

        [HttpDelete("{id}")]
        public override void Delete(int id)
        {
            if (User.IsInRole("Administrator"))
            {
                _service.Delete(id);
            }
            else if (User.IsInRole("Korisnik"))
            {
                _service.Delete(id);
            }
            else
            {
                throw new ForbidException("Niste autorizovani za brisanje recenzija!");
            }
        }
    }
}
