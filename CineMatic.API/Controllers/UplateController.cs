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

        //[HttpPost("create-payment-intent")]
        //public async Task<IActionResult> CreatePaymentIntent([FromBody] PaymentIntentCreateRequest request)
        //{
        //    try
        //    {
        //        var paymentIntent = await _uplateService.CreatePaymentIntentAsync(request.Iznos);
        //        return Ok(new { clientSecret = paymentIntent.ClientSecret });
        //    }
        //    catch (Exception ex)
        //    {
        //        return BadRequest(new { error = ex.Message });
        //    }
        //}

        [HttpPost("CreatePaymentIntent")]
        public async Task<IActionResult> CreatePaymentIntent([FromQuery] int amount)
        {
            try
            {
                // Kreiraj PaymentIntent odmah kao potvrđen
                var options = new Stripe.PaymentIntentCreateOptions
                {
                    Amount = amount,
                    Currency = "usd",
                    Confirm = true, // Odmah potvrđuje uplatu
                    AutomaticPaymentMethods = new Stripe.PaymentIntentAutomaticPaymentMethodsOptions
                    {
                        Enabled = true,
                        AllowRedirects = "never" // Sprječava zahtjev za return_url
                    },
                    PaymentMethod = "pm_card_visa" // Test payment method (Stripe test kartica)
                };

                var service = new Stripe.PaymentIntentService();
                var paymentIntent = await service.CreateAsync(options);

                return Ok(new
                {
                    paymentIntent.Id,
                    paymentIntent.Status,
                    paymentIntent.Amount,
                    paymentIntent.Currency
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpPost("ConfirmPayment")]
        public IActionResult ConfirmPayment([FromQuery] string paymentIntentId, [FromQuery] decimal amount)
        {
            var result = _uplateService.ProcessStripePayment(paymentIntentId, amount);
            return Ok(result);
        }
    }
}
