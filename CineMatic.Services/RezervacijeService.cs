using CineMatic.Model.DTO;
using CineMatic.Model.Requests;
using CineMatic.Model.SearchObject;
using CineMatic.Services.Database;
using Mapster;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using QRCoder;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CineMatic.Services
{
    public class RezervacijeService : BaseCRUDService<Model.Rezervacije, RezervacijeSearchObject, Database.Rezervacije, RezervacijeInsertRequest, RezervacijeUpdateRequest>, IRezervacijeService
    {
        private readonly IKorisniciService _korisniciService;
        private readonly Ib210083Context _context;
        private readonly UplateService _uplateService;
        public RezervacijeService(Ib210083Context context, IMapper mapper, IKorisniciService korisniciService, UplateService uplateService) : base(context, mapper)
        {
            _korisniciService = korisniciService;
            _context = context;
            _uplateService = uplateService;
        }

        public override IQueryable<Rezervacije> AddFilter(RezervacijeSearchObject search, IQueryable<Rezervacije> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (search.ProjekcijaId.HasValue)
            {
                filteredQuery = filteredQuery.Where(r => r.ProjekcijaId == search.ProjekcijaId.Value);
            }
            if (search.KorisnikId.HasValue)
            {
                filteredQuery = filteredQuery.Where(r => r.KorisnikId == search.KorisnikId.Value);
            }

            if (search?.isKorisnikIncluded == true)
                filteredQuery = filteredQuery.Include(x => x.Korisnik);

            if (search?.IsProjekcijaIncluded == true)
                filteredQuery = filteredQuery.Include(x => x.Projekcija);

            if (search?.isSjedistaIncluded == true)
            {
                filteredQuery = filteredQuery
                    .Include(r => r.RezervacijeSjedišta)
                    .ThenInclude(rs => rs.Sjedište);
            }

            if (search?.isPlacanjeIncluded == true)
                filteredQuery = filteredQuery.Include(x => x.Uplata);

            if (search?.isHranaPiceIncluded == true)
            {
                filteredQuery = filteredQuery
                    .Include(r => r.RezervacijeHraneIpićas)
                    .ThenInclude(rs => rs.HranaIpiće);
            }

            return filteredQuery;
        }

        public override Model.PagedResult<Model.Rezervacije> GetPaged(RezervacijeSearchObject search)
        {
            var query = Context.Rezervacijes.AsQueryable();

            query = AddFilter(search, query);

            int count = query.Count();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);
            }

            var entities = query.ToList();

            var models = entities.Select(entity =>
            {
                var model = new Model.Rezervacije
                {
                    Id = entity.Id,
                    KorisnikId = entity.KorisnikId,
                    ProjekcijaId = entity.ProjekcijaId,
                    UplataId = entity.UplataId, 
                    BrojUlaznica = entity.BrojUlaznica,
                    UkupnaCijena = entity.UkupnaCijena,
                    NačinPlaćanja = entity.NačinPlaćanja,
                    QrcodeBase64 = entity.QrcodeBase64,
                    DatumIvrijeme = entity.DatumIvrijeme,
                    RezervacijeSjedišta = new List<Model.RezervacijeSjedištum>(),
                    RezervacijeHraneIpićas = new List<Model.RezervacijeHraneIpića>(),
                };

                // Mapiranje korisnika
                if (search?.isKorisnikIncluded == true && entity.Korisnik != null)
                {
                    model.Korisnik = new Model.Korisnici
                    {
                        Id = entity.Korisnik.Id,
                        Ime = entity.Korisnik.Ime,
                        Prezime = entity.Korisnik.Prezime,
                        Email = entity.Korisnik.Email,
                        KorisnickoIme = entity.Korisnik.KorisnickoIme
                    };
                }

                // Mapiranje rezervisanih sjedista
                if (search?.isSjedistaIncluded == true && entity.RezervacijeSjedišta != null)
                {
                    model.RezervacijeSjedišta = entity.RezervacijeSjedišta
                        .Where(rs => rs.Sjedište != null)
                        .Select(rs => new Model.RezervacijeSjedištum
                        {
                            RezervacijaId = rs.RezervacijaId,
                            SjedišteId = rs.SjedišteId,
                            Sjedište = new Model.Sjedištum
                            {
                                Id = rs.Sjedište.Id,
                                Naziv = rs.Sjedište.Naziv,
                            }
                        }).ToList();
                }

                if (search?.isHranaPiceIncluded == true && entity.RezervacijeHraneIpićas != null)
                {
                    model.RezervacijeHraneIpićas = entity.RezervacijeHraneIpićas
                        .Where(rs => rs.HranaIpiće != null)
                        .Select(rs => new Model.RezervacijeHraneIpića
                        {
                            RezervacijaId = rs.RezervacijaId,
                            HranaIpićeId = rs.HranaIpićeId,
                            HranaIpiće = new Model.HraneIpića
                            {
                                Id = rs.HranaIpiće.Id,
                                Naziv = rs.HranaIpiće.Naziv,
                                Cijena = rs.HranaIpiće.Cijena,
                            }
                        }).ToList();
                }

                if (search?.isPlacanjeIncluded == true && entity.Uplata != null)
                {
                    model.Uplata = new Model.Uplate
                    {
                        Id = entity.Uplata.Id,
                        Iznos = entity.Uplata.Iznos,
                        DatumIvrijeme = entity.Uplata.DatumIvrijeme,
                        Izdavač = entity.Uplata.Izdavač,
                    };
                }

                // Mapiranje projekcije (samo osnovni podaci)
                if (search?.IsProjekcijaIncluded == true && entity.Projekcija != null)
                {
                    model.Projekcija = new Model.Projekcije
                    {
                        Id = entity.Projekcija.Id,
                        FilmId = entity.Projekcija.FilmId,
                        SalaId = entity.Projekcija.SalaId,
                        NačinProjekcijeId = entity.Projekcija.NačinProjekcijeId,
                        DatumIvrijeme = entity.Projekcija.DatumIvrijeme,
                        Cijena = entity.Projekcija.Cijena,
                        Stanje = entity.Projekcija.Stanje
                    };
                }

                return model;
            }).ToList();

            return new Model.PagedResult<Model.Rezervacije>
            {
                ResultList = models,
                Count = count
            };
        }

        public override Model.Rezervacije GetById(int id)
        {
            var entity = Context.Rezervacijes
                .Include(r => r.Korisnik)
                .Include(r => r.Projekcija)
                    .ThenInclude(s => s.Film)
                .Include(r => r.Projekcija)
                    .ThenInclude(s => s.Sala)
                .Include(r => r.Projekcija)
                    .ThenInclude(s => s.NačinProjekcije)
                .Include(r => r.RezervacijeSjedišta)
                    .ThenInclude(rs => rs.Sjedište)
                .Include(r => r.Uplata)
                        .FirstOrDefault(r => r.Id == id);

            if (entity != null)
            {
                var model = new Model.Rezervacije
                {
                    Id = entity.Id,
                    KorisnikId = entity.KorisnikId,
                    ProjekcijaId = entity.ProjekcijaId,
                    UplataId = entity.UplataId,
                    DatumIvrijeme = entity.DatumIvrijeme,
                    BrojUlaznica = entity.BrojUlaznica,
                    UkupnaCijena = entity.UkupnaCijena,
                    NačinPlaćanja = entity.NačinPlaćanja,
                    QrcodeBase64 = entity.QrcodeBase64
                };

                model.RezervacijeSjedišta = entity.RezervacijeSjedišta.Select(rs => new Model.RezervacijeSjedištum
                {
                    RezervacijaId = rs.RezervacijaId,
                    SjedišteId = rs.SjedišteId,
                    Sjedište = rs.Sjedište.Adapt<Model.Sjedištum>()
                }).ToList();

                model.RezervacijeHraneIpićas = entity.RezervacijeHraneIpićas.Select(rs => new Model.RezervacijeHraneIpića
                {
                    RezervacijaId = rs.RezervacijaId,
                    HranaIpićeId = rs.HranaIpićeId,
                    HranaIpiće = rs.HranaIpiće.Adapt<Model.HraneIpića>()
                }).ToList();

                model.Korisnik = entity.Korisnik != null ? new Model.Korisnici
                {
                    Id = entity.Korisnik.Id,
                    Ime = entity.Korisnik.Ime,
                    Prezime = entity.Korisnik.Prezime,
                    Email = entity.Korisnik.Email,
                    KorisnickoIme = entity.Korisnik.KorisnickoIme,
                } : null;

                model.Projekcija = entity.Projekcija != null ? new Model.Projekcije
                {
                    Id = entity.Projekcija.Id,
                    FilmId = entity.Projekcija.FilmId,
                    SalaId = entity.Projekcija.SalaId,
                    NačinProjekcijeId = entity.Projekcija.NačinProjekcijeId,
                    DatumIvrijeme = entity.Projekcija.DatumIvrijeme,
                    Cijena = entity.Projekcija.Cijena,
                    Stanje = entity.Projekcija.Stanje,

                    Film = entity.Projekcija.Film != null ? new Model.Filmovi
                    {
                        Id = entity.Projekcija.Film.Id,
                        Naziv = entity.Projekcija.Film.Naziv,
                        Trajanje = entity.Projekcija.Film.Trajanje,
                        Opis = entity.Projekcija.Film.Opis,
                    } : null,

                    Sala = entity.Projekcija.Sala != null ? new Model.Sale
                    {
                        Id = entity.Projekcija.Sala.Id,
                        Naziv = entity.Projekcija.Sala.Naziv,
                    } : null,

                    NačinProjekcije = entity.Projekcija.NačinProjekcije != null ? new Model.NačiniPrikazivanja
                    {
                        Id = entity.Projekcija.NačinProjekcije.Id,
                        Naziv = entity.Projekcija.NačinProjekcije.Naziv
                    } : null

                } : null;

                model.Uplata = entity.Uplata != null ? new Model.Uplate
                {
                    Id = entity.Uplata.Id,
                    Izdavač = entity.Uplata.Izdavač,
                    TransakcijaId = entity.Uplata.TransakcijaId,
                    Iznos = entity.Uplata.Iznos,
                    DatumIvrijeme = entity.Uplata.DatumIvrijeme,
                } : null;

                return model;
            }
            return null;
        }

        public string GenerateQRCode(int reservationId)
        {
            var rezervacija = GetById(reservationId);
            if (rezervacija == null)
            {
                throw new Exception("Rezervacija nije pronadjena");
            }

            var qrCodeContent = $"Rezervacija ID: {rezervacija.Id}\n" +
                                $"Korisnik: {rezervacija.Korisnik?.Ime} {rezervacija.Korisnik?.Prezime}\n" +
                                $"Film: {rezervacija.Projekcija?.Film?.Naziv}\n" +
                                $"Datum: {rezervacija.Projekcija?.DatumIvrijeme:dd-MM-yyyy HH:mm}\n" +
                                $"Sala: {rezervacija.Projekcija?.Sala?.Naziv}\n" +
                                $"Način prikazivanja: {rezervacija.Projekcija?.NačinProjekcije?.Naziv}\n" +
                                $"Cijena ulaznice: {rezervacija.Projekcija?.Cijena}\n" +
                                $"Datum rezervacije: {rezervacija.DatumIvrijeme:dd-MM-yyyy HH:mm}\n" +
                                $"Sjedista: {string.Join(", ", rezervacija.RezervacijeSjedišta.Select(s => s.Sjedište.Naziv))}\n" +
                                $"Ukupna cijena: {rezervacija.UkupnaCijena}\n" +
                                $"Nacin placanja: {rezervacija.NačinPlaćanja}\n";

            QRCodeGenerator qrGenerator = new QRCodeGenerator();
            QRCodeData qrCodeData = qrGenerator.CreateQrCode(qrCodeContent, QRCodeGenerator.ECCLevel.Q);
            PngByteQRCode qrCode = new PngByteQRCode(qrCodeData);
            byte[] qrCodeImage = qrCode.GetGraphic(20);

            return Convert.ToBase64String(qrCodeImage);
        }

        public override Model.Rezervacije Insert(RezervacijeInsertRequest request)
        {
            using var transaction = Context.Database.BeginTransaction();

            try
            {
                int currentUserId = _korisniciService.GetCurrentUserId();
                request.KorisnikId = currentUserId;

                ValidateSeatsAvailability(request.ProjekcijaId, request.SjedisteId);

                var screening = GetScreeningById(request.ProjekcijaId);

                if (screening.Stanje != "active")
                {
                    throw new InvalidOperationException("Projekcija mora biti aktivna da bi se napravila rezervacija.");
                }

                var reservation = CreateReservationEntity(request, screening);

                Context.Add(reservation);
                Context.SaveChanges();

                if (!string.IsNullOrEmpty(request.StripePaymentIntentId))
                {
                    var payment = _uplateService.ProcessStripePayment(request.StripePaymentIntentId, reservation.UkupnaCijena.Value);
                    reservation.UplataId = payment.Id;
                    reservation.NačinPlaćanja = "Stripe";
                    reservation.Uplata = payment;
                }

                if (request.SjedisteId != null && request.SjedisteId.Any())
                {
                    ReserveSeatsForReservation(request.SjedisteId, request.ProjekcijaId, reservation.Id);
                }

                if (request.HranePicaId != null && request.HranePicaId.Any())
                {
                    RezervisiHranuIPice(request.HranePicaId, request.KolicineHranePica, reservation.Id);
                }

                var fullEntity = GetFullReservationById(reservation.Id);

                var model = MapToModel(fullEntity);

                string qrCodeBase64 = GenerateQRCode(reservation.Id);

                reservation.QrcodeBase64 = qrCodeBase64;

                Context.SaveChanges();

                transaction.Commit();

                return model;
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }

        private void ValidateSeatsAvailability(int screeningId, List<int> seatIds)
        {
            var unavailableSeats = Context.ProjekcijeSjedišta
                .Where(ss => ss.ProjekcijaId == screeningId && seatIds.Contains(ss.SjedišteId) && ss.Rezervisano.Value)
                .Select(ss => ss.SjedišteId)
                .ToList();

            if (unavailableSeats.Any())
            {
                throw new InvalidOperationException($"Ova sjedista su vec rezervisana: {string.Join(", ", unavailableSeats)}");
            }
        }

        private Database.Projekcije GetScreeningById(int screeningId)
        {
            var screening = Context.Projekcijes.FirstOrDefault(s => s.Id == screeningId);
            if (screening == null)
            {
                throw new InvalidOperationException("Projekcija nije pronadjena.");
            }
            return screening;
        }

        private Database.Rezervacije CreateReservationEntity(RezervacijeInsertRequest request, Database.Projekcije screening)
        {
            var numberOfTickets = request.SjedisteId?.Count ?? 0;
            var totalPrice = screening.Cijena * numberOfTickets;

            if (request.HranePicaId != null && request.HranePicaId.Any())
            {
                var hranaPicaList = _context.HraneIpićas
                    .Where(h => request.HranePicaId.Contains(h.Id))
                    .ToList();

                foreach (var hrana in hranaPicaList)
                {
                    totalPrice += hrana.Cijena ?? 0;
                }
            }

            var entity = Mapper.Map<Database.Rezervacije>(request);
            entity.BrojUlaznica = numberOfTickets;
            entity.UkupnaCijena = totalPrice;
            entity.DatumIvrijeme = DateTime.Now;

            if (entity.UplataId == null)
            {
                entity.NačinPlaćanja = "Gotovina";
            }

            return entity;
        }

        private void ReserveSeatsForReservation(List<int> seatIds, int screeningId, int reservationId)
        {
            foreach (var seatId in seatIds)
            {
                var reservationSeat = new Database.RezervacijeSjedištum
                {
                    RezervacijaId = reservationId,
                    SjedišteId = seatId,
                    DatumIvrijeme = DateTime.Now
                };

                Context.RezervacijeSjedišta.Add(reservationSeat);

                var screeningSeat = Context.ProjekcijeSjedišta
                    .FirstOrDefault(ss => ss.ProjekcijaId == screeningId && ss.SjedišteId == seatId);

                if (screeningSeat != null)
                {
                    screeningSeat.Rezervisano = true;
                }
            }

            Context.SaveChanges();
        }

        private void RezervisiHranuIPice(List<int> hranePicaIds, List<int> kolicineHranePica, int reservationId)
        {
            var counter = 0;
            foreach (var hranaPiceId in hranePicaIds)
            {
                var rezervisiHranu = new Database.RezervacijeHraneIpića
                {
                    RezervacijaId = reservationId,
                    HranaIpićeId = hranaPiceId,
                    Kolicina = kolicineHranePica[counter]
                };

                Context.RezervacijeHraneIpićas.Add(rezervisiHranu);

                var hranaPice = Context.HraneIpićas.FirstOrDefault(h => h.Id == hranaPiceId);
                if (hranaPice == null)
                    throw new Exception($"Proizvod sa ID={hranaPiceId} ne postoji!");

                if (!hranaPice.KoličinaUskladištu.HasValue || hranaPice.KoličinaUskladištu <= 0)
                    throw new Exception($"Proizvod '{hranaPice.Naziv}' je rasprodan!");

                hranaPice.KoličinaUskladištu -= kolicineHranePica[counter];

                counter++;
            }

            Context.SaveChanges();
        }

        private Database.Rezervacije GetFullReservationById(int reservationId)
        {
            return Context.Rezervacijes
                .Include(r => r.Korisnik)
                .Include(r => r.Projekcija)
                .Include(r => r.RezervacijeSjedišta)
                    .ThenInclude(rs => rs.Sjedište)
                .FirstOrDefault(r => r.Id == reservationId);
        }

        private Model.Rezervacije MapToModel(Database.Rezervacije fullEntity)
        {
            if (fullEntity == null)
                return null;

            var model = new Model.Rezervacije
            {
                Id = fullEntity.Id,
                KorisnikId = fullEntity.KorisnikId,
                ProjekcijaId = fullEntity.ProjekcijaId,
                UkupnaCijena = fullEntity.UkupnaCijena,
                NačinPlaćanja = fullEntity.NačinPlaćanja,
                QrcodeBase64 = fullEntity.QrcodeBase64,
                BrojUlaznica = fullEntity.BrojUlaznica,
                RezervacijeSjedišta = fullEntity.RezervacijeSjedišta?
                    .Select(rs => new Model.RezervacijeSjedištum
                    {
                        RezervacijaId = rs.RezervacijaId,
                        SjedišteId = rs.SjedišteId
                    })
                    .ToList(),

                RezervacijeHraneIpićas = fullEntity.RezervacijeHraneIpićas?
                    .Select(rs => new Model.RezervacijeHraneIpića
                    {
                        RezervacijaId = rs.RezervacijaId,
                        HranaIpićeId = rs.HranaIpićeId
                    })
                    .ToList(),
                Uplata = fullEntity.Uplata != null ? new Model.Uplate
                {
                    Id = fullEntity.Uplata.Id,
                    Iznos = fullEntity.Uplata.Iznos,
                    DatumIvrijeme = fullEntity.Uplata.DatumIvrijeme
                } : null
            };

            return model;
        }

        public override Model.Rezervacije Update(int id, RezervacijeUpdateRequest request)
        {
            throw new NotImplementedException("Operacija nije dozvoljena za rezervacije");
        }

        public override void Delete(int id)
        {
            using var transaction = Context.Database.BeginTransaction();

            try
            {
                var reservation = Context.Rezervacijes
                    .Include(r => r.RezervacijeSjedišta)
                    .Include(r => r.RezervacijeHraneIpićas)
                    .Include(r => r.Projekcija)
                    .FirstOrDefault(r => r.Id == id);

                if (reservation == null)
                {
                    throw new Exception("Rezervacija nije pronadjena");
                }

                var currentUserId = _korisniciService.GetCurrentUserId();
                if (reservation.KorisnikId != currentUserId)
                {
                    throw new UnauthorizedAccessException("Dozvoljeno je brisati samo vlastite rezervacije");
                }

                if (reservation.NačinPlaćanja == "Stripe")
                {
                    throw new InvalidOperationException("Rezervacije placene putem Stripe servisa ne mogu biti obrisane");
                }

                if (reservation.Projekcija.DatumIvrijeme < DateTime.Now)
                {
                    throw new InvalidOperationException("Rezervacije koje su zavrsene ne mogu biti obrisane");
                }

                foreach (var reservationSeat in reservation.RezervacijeSjedišta)
                {
                    var screeningSeat = Context.ProjekcijeSjedišta
                        .FirstOrDefault(ss => ss.ProjekcijaId == reservation.ProjekcijaId && ss.SjedišteId == reservationSeat.SjedišteId);

                    if (screeningSeat != null)
                    {
                        screeningSeat.Rezervisano = false;
                    }
                }

                foreach (var item in reservation.RezervacijeHraneIpićas)
                {
                    var hranaPice = Context.HraneIpićas.FirstOrDefault(h => h.Id == item.HranaIpićeId);
                    if (hranaPice != null && hranaPice.KoličinaUskladištu.HasValue)
                    {
                        hranaPice.KoličinaUskladištu += item.Kolicina;
                    }
                }

                Context.RezervacijeHraneIpićas.RemoveRange(reservation.RezervacijeHraneIpićas);
                Context.RezervacijeSjedišta.RemoveRange(reservation.RezervacijeSjedišta);
                Context.Rezervacijes.Remove(reservation);

                Context.SaveChanges();
                transaction.Commit();
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }

        public List<RezervacijaFilmDTO> RezervacijaPoKorisnikId(int userId)
        {
            var reservations = _context.Rezervacijes
             .Include(r => r.Projekcija)
             .ThenInclude(s => s.Film)
             .Where(r => r.KorisnikId == userId)
             .Select(r => new RezervacijaFilmDTO
             {
                 RezervacijaId = r.Id,
                 DatumRezervacije = r.DatumIvrijeme ?? DateTime.MinValue,
                 NacinPlacanja = r.NačinPlaćanja,
                 ProjekcijaId = r.ProjekcijaId ?? 0,
                 DatumProjekcije = r.Projekcija.DatumIvrijeme ?? DateTime.MinValue,
                 SjedistaIds = r.RezervacijeSjedišta.Select(rs => rs.SjedišteId).ToList(),
                 HranaPiceIds = r.RezervacijeHraneIpićas.Select(rs => rs.HranaIpićeId).ToList(),

                 FilmId = r.Projekcija.Film.Id,
                 NazivFilma = r.Projekcija.Film.Naziv,
                 TrajanjeFilma = r.Projekcija.Film.Trajanje,
                 Opis = r.Projekcija.Film.Opis,
                 FilmaSlikaBase64 = r.Projekcija.Film.Slika != null ? Convert.ToBase64String(r.Projekcija.Film.Slika) : null
             })
             .ToList();

            return reservations;
        }

        public List<Model.Rezervacije> RezervacijePoProjekcijaId(int screeningId)
        {
            var reservations = _context.Rezervacijes
                .Include(r => r.Korisnik)
                .Include(r => r.Projekcija)
                    .ThenInclude(s => s.Film)
                .Include(r => r.Projekcija)
                    .ThenInclude(s => s.Sala)
                .Include(r => r.Projekcija)
                    .ThenInclude(s => s.NačinProjekcije)
                .Include(r => r.RezervacijeSjedišta)
                    .ThenInclude(rs => rs.Sjedište)
                .Include(rs => rs.RezervacijeHraneIpićas)
                    .ThenInclude(rs => rs.HranaIpiće)
                .Include(r => r.Uplata)
                .Where(r => r.ProjekcijaId == screeningId)
                .ToList();

            var reservationModels = reservations.Select(r => new Model.Rezervacije
            {
                Id = r.Id,
                KorisnikId = r.KorisnikId,
                ProjekcijaId = r.ProjekcijaId,
                DatumIvrijeme = r.DatumIvrijeme,
                BrojUlaznica = r.BrojUlaznica,
                UkupnaCijena = r.UkupnaCijena,
                UplataId = r.UplataId,
                NačinPlaćanja = r.NačinPlaćanja,
                RezervacijeSjedišta = r.RezervacijeSjedišta.Select(rs => new Model.RezervacijeSjedištum
                {
                    RezervacijaId = rs.RezervacijaId,
                    SjedišteId = rs.SjedišteId,
                    Sjedište = rs.Sjedište != null ? new Model.Sjedištum
                    {
                        Id = rs.Sjedište.Id,
                        Naziv = rs.Sjedište.Naziv
                    } : null
                }).ToList(),
                RezervacijeHraneIpićas = r.RezervacijeHraneIpićas.Select(rs => new Model.RezervacijeHraneIpića
                {
                    RezervacijaId = rs.RezervacijaId,
                    HranaIpićeId = rs.HranaIpićeId,
                    HranaIpiće = rs.HranaIpiće != null ? new Model.HraneIpića
                    {
                        Id = rs.HranaIpiće.Id,
                        Naziv = rs.HranaIpiće.Naziv
                    } : null
                }).ToList(),
                Korisnik = r.Korisnik != null ? new Model.Korisnici
                {
                    Id = r.Korisnik.Id,
                    Ime = r.Korisnik.Ime,
                    Prezime = r.Korisnik.Prezime,
                    Email = r.Korisnik.Email,
                    KorisnickoIme = r.Korisnik.KorisnickoIme
                } : null,
                Projekcija = r.Projekcija != null ? new Model.Projekcije
                {
                    Id = r.Projekcija.Id,
                    FilmId = r.Projekcija.FilmId,
                    SalaId = r.Projekcija.SalaId,
                    NačinProjekcijeId = r.Projekcija.NačinProjekcijeId,
                    DatumIvrijeme = r.Projekcija.DatumIvrijeme,
                    Cijena = r.Projekcija.Cijena,
                    Film = r.Projekcija.Film != null ? new Model.Filmovi
                    {
                        Id = r.Projekcija.Film.Id,
                        Naziv = r.Projekcija.Film.Naziv,
                        Trajanje = r.Projekcija.Film.Trajanje,
                        Opis = r.Projekcija.Film.Opis,
                        SlikaBase64 = r.Projekcija.Film.Slika != null ? Convert.ToBase64String(r.Projekcija.Film.Slika) : null,
                        Glumacs = r.Projekcija.Film.Glumacs.Select(a => new Model.Glumci
                        {
                            Id = a.Id,
                            Ime = a.Ime,
                        }).ToList(),
                        Žanrs = r.Projekcija.Film.Žanrs.Select(g => new Model.Žanrovi
                        {
                            Id = g.Id,
                            Naziv = g.Naziv
                        }).ToList()
                    } : null,
                    // Dodaj mapiranje za salu i način projekcije:
                    Sala = r.Projekcija.Sala != null ? new Model.Sale
                    {
                        Id = r.Projekcija.Sala.Id,
                        Naziv = r.Projekcija.Sala.Naziv
                    } : null,
                    NačinProjekcije = r.Projekcija.NačinProjekcije != null ? new Model.NačiniPrikazivanja
                    {
                        Id = r.Projekcija.NačinProjekcije.Id,
                        Naziv = r.Projekcija.NačinProjekcije.Naziv
                    } : null
                } : null,
                Uplata = r.Uplata != null ? new Model.Uplate
                {
                    Id = r.Uplata.Id,
                    Izdavač = r.Uplata.Izdavač,
                    TransakcijaId = r.Uplata.TransakcijaId,
                    Iznos = r.Uplata.Iznos,
                    DatumIvrijeme = r.Uplata.DatumIvrijeme
                } : null
            }).ToList();

            return reservationModels;
        }
    }
}
