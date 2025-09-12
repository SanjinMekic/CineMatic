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
    public interface IRezervacijeService : ICRUDService<Rezervacije, RezervacijeSearchObject, RezervacijeInsertRequest, RezervacijeUpdateRequest>
    {
        List<RezervacijaFilmDTO> RezervacijaPoKorisnikId(int userId);
        string GenerateQRCode(int reservationId);
    }
}
