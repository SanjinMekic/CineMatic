using CineMatic.Model;
using CineMatic.Model.Requests;
using CineMatic.Model.SearchObject;
using CineMatic.Services;
using CineMatic.Services.RecommenderSystem;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CineMatic.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class FilmoviController : BaseCRUDController<Filmovi, FilmoviSearchObject, FilmoviInsertRequest, FilmoviUpdateRequest>
    {
        private readonly IRecommenderService _filmRecommenderService;
        public FilmoviController(IFilmoviService service, IRecommenderService filmRecommenderService) : base(service)
        {
            _filmRecommenderService = filmRecommenderService;
        }

        [HttpGet("{id}/recommendations")]
        public IActionResult DobaviPreporuke(int id)
        {
            var recommendations = _filmRecommenderService.DobaviPreporuceneFilmove(id);

            if (recommendations == null || recommendations.Count == 0)
                return NotFound("Nema slicnih filmova za preporuciti!");

            return Ok(recommendations);
        }

        [Authorize(Roles = "Administrator")]
        public override Filmovi Insert(FilmoviInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Administrator")]
        public override Filmovi Update(int id, FilmoviUpdateRequest request)
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
