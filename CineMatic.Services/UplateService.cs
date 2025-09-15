using CineMatic.Services.Database;
using Stripe;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CineMatic.Services
{
    public class UplateService
    {
        private readonly Ib210083Context _context;

        public UplateService(string stripeSecretKey, Ib210083Context context)
        {
            StripeConfiguration.ApiKey = stripeSecretKey;
            _context = context;
        }

        public Uplate ProcessStripePayment(string paymentIntentId, decimal amount)
        {
            var service = new PaymentIntentService();
            var paymentIntent = service.Get(paymentIntentId);

            if (paymentIntent.Status != "succeeded")
            {
                throw new InvalidOperationException("Payment not successful.");
            }

            var payment = new Uplate
            {
                Izdavač = "Stripe",
                TransakcijaId = paymentIntent.Id,
                Iznos = amount,
                DatumIvrijeme = DateTime.Now
            };

            _context.Uplates.Add(payment);
            _context.SaveChanges();

            return payment;
        }

        public async Task<PaymentIntent> CreatePaymentIntentAsync(int amount)
        {
            var options = new PaymentIntentCreateOptions
            {
                Amount = amount,
                Currency = "usd",
                PaymentMethodTypes = new List<string> { "card" },
                ConfirmationMethod = "automatic",
                Confirm = false
            };
            var service = new PaymentIntentService();
            return await service.CreateAsync(options);
        }

        public async Task<string> CheckPaymentStatusAsync(string paymentIntentId)
        {
            var service = new PaymentIntentService();
            var paymentIntent = await service.GetAsync(paymentIntentId);

            return paymentIntent.Status;
        }
    }
}
