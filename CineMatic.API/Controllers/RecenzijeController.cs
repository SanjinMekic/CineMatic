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
            if (User.IsInRole("User"))
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
