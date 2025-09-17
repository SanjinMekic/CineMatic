using CineMatic.Model.RecommenderSystemModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CineMatic.Services.RecommenderSystem
{
    public interface IRecommenderService
    {
        List<FilmDTO> DobaviPreporuceneFilmove(int filmId, int brojPreporuka = 5);
    }
}
