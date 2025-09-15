using CineMatic.Model;
using CineMatic.Model.DTO;
using CineMatic.Model.Requests;
using CineMatic.Model.SearchObject;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CineMatic.Services
{
    public interface IProjekcijeService : ICRUDService<Projekcije, ProjekcijeSearchObject, ProjekcijeInsertRequest, ProjekcijeUpdateRequest>
    {
        public List<Model.Projekcije> GetProjekcijePoFilmId(int filmId);
        public Task<List<SjedisteDTO>> GetSjedistaZaProjekciju(int projekcijaId);
    }
}
