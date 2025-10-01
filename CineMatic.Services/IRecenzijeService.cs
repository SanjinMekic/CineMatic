using CineMatic.Model;
using CineMatic.Model.Requests;
using CineMatic.Model.SearchObject;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CineMatic.Services
{
    public interface IRecenzijeService : ICRUDService<Recenzije, RecenzijeSearchObject, RecenzijeInsertRequest, RecenzijeUpdateRequest>
    {
        Task<List<Recenzije>> GetByFilmIdAsync(int filmId);
        Task<List<Recenzije>> GetByFilmIdAndRatingAsync(int filmId, int? ocjena);
        double? ProsjecnaOcjena(int movieId);
        bool OcijenjenoPrije(int userId, int movieId);
    }
}
