using CineMatic.Model;
using CineMatic.Model.RecommenderSystemModels;
using CineMatic.Model.Requests;
using CineMatic.Model.SearchObject;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CineMatic.Services
{
    public interface IFilmoviService : ICRUDService<Filmovi, FilmoviSearchObject, FilmoviInsertRequest, FilmoviUpdateRequest>
    {
        IEnumerable<FilmDTO> DohvatiSveFilmove();
    }
}
