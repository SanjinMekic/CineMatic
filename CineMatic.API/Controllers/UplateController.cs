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
    public class UplateController : ControllerBase
    {
        private readonly UplateService _uplateService;
        public UplateController(UplateService uplateService)
        {
            _uplateService = uplateService;
        }

        [HttpPost("create-payment-intent")]
        public async Task<IActionResult> CreatePaymentIntent([FromBody] PaymentIntentCreateRequest request)
        {
            try
            {
                var paymentIntent = await _uplateService.CreatePaymentIntentAsync(request.Iznos);
                return Ok(new { clientSecret = paymentIntent.ClientSecret });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpPost("status/{paymentIntentId}")]
        public async Task<IActionResult> CheckPaymentStatus(string paymentIntentId)
        {
            try
            {
                var status = await _uplateService.CheckPaymentStatusAsync(paymentIntentId);
                return Ok(new { status });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }
    }
}
