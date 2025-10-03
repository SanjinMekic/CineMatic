using CineMatic.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CineMatic.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize(Roles = "Administrator")]
    public class IzvjestajiController : ControllerBase
    {
        private readonly IIzvjestajiService _izvjestajiService;

        public IzvjestajiController(IIzvjestajiService izvjestajiService)
        {
            _izvjestajiService = izvjestajiService;
        }

        [HttpGet("brojKorisnika")]
        public async Task<IActionResult> GetUserCount()
        {
            var userCount = await _izvjestajiService.GetUserCountAsync();
            return Ok(new { UserCount = userCount });
        }

        [HttpGet("brojAdmina")]
        public async Task<IActionResult> GetAdminCount()
        {
            var adminCount = await _izvjestajiService.GetAdminCountAsync();
            return Ok(new { AdminCount = adminCount });
        }

        [HttpGet("brojBlagajnika")]
        public async Task<IActionResult> GetBlagajnikCount()
        {
            var blagajnikCount = await _izvjestajiService.GetBlagajnikCountAsync();
            return Ok(new { BlagajnikCount = blagajnikCount });
        }

        [HttpGet("ukupnaZarada")]
        public async Task<IActionResult> GetTotalCinemaIncome()
        {
            var totalIncome = await _izvjestajiService.GetTotalCinemaIncomeAsync();
            return Ok(new { TotalIncome = totalIncome });
        }

        [HttpGet("ukupnaZaradaHranaPice")]
        public async Task<IActionResult> GetFoodDrinkIncome()
        {
            var totalFoodDrinkIncome = await _izvjestajiService.GetFoodAndDrinkIncome();
            return Ok(new { TotalFoodDrinkIncome = totalFoodDrinkIncome });
        }

        [HttpGet("top5korisnika")]
        public async Task<IActionResult> GetTop5Customers()
        {
            var top5Customers = await _izvjestajiService.GetTop5CustomersAsync();
            return Ok(top5Customers);
        }

        [HttpGet("top5najgledanijihFilmova")]
        public async Task<IActionResult> GetTop5ReservedMovies()
        {
            var top5Movies = await _izvjestajiService.GetTop5WatchedMoviesAsync();
            return Ok(top5Movies);
        }
    }
}
