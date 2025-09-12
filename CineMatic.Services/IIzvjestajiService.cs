using CineMatic.Model.Izvjestaji;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CineMatic.Services
{
    public interface IIzvjestajiService
    {
        Task<int> GetUserCountAsync();
        Task<decimal> GetTotalCinemaIncomeAsync();
        Task<decimal> GetFoodAndDrinkIncome();
        Task<int> GetAdminCountAsync();
        Task<List<TopKorisnik>> GetTop5CustomersAsync();
        Task<List<BrojSjedistaPoFilmu>> GetTop5WatchedMoviesAsync();
    }
}
