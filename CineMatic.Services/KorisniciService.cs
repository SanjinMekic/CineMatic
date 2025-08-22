using CineMatic.Model;
using CineMatic.Model.Requests;
using CineMatic.Model.SearchObject;
using CineMatic.Services.Database;
using MapsterMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace CineMatic.Services
{
    public class KorisniciService : BaseCRUDService<Model.Korisnici, KorisniciSearchObject, Database.Korisnici, KorisniciInsertRequest, KorisniciUpdateRequest>, IKorisniciService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;
        public KorisniciService(Ib210083Context context, IMapper mapper, IHttpContextAccessor httpContextAccessor) : base(context, mapper)
        {
            httpContextAccessor = _httpContextAccessor;
        }

        public override IQueryable<Database.Korisnici> AddFilter(KorisniciSearchObject search, IQueryable<Database.Korisnici> query)
        {
            query = base.AddFilter(search, query);
            if (!string.IsNullOrWhiteSpace(search?.ImeGTE))
            {
                query = query.Where(x => x.Ime.StartsWith(search.ImeGTE));
            }

            if (!string.IsNullOrWhiteSpace(search?.PrezimeGTE))
            {
                query = query.Where(x => x.Prezime.StartsWith(search.PrezimeGTE));
            }

            if (!string.IsNullOrWhiteSpace(search?.Email))
            {
                query = query.Where(x => x.Email == search.Email);
            }

            if (!string.IsNullOrWhiteSpace(search?.KorisnickoIme))
            {
                query = query.Where(x => x.KorisnickoIme == search.KorisnickoIme);
            }

            if (search.isUlogeIncluded == true)
            {
                query = query.Include(x => x.Ulogas);
            }

            return query;
        }

        public override PagedResult<Model.Korisnici> GetPaged(KorisniciSearchObject search)
        {
            var pagedKorisnici = base.GetPaged(search);

            foreach (var korisnik in pagedKorisnici.ResultList)
            {
                var databaseKorisnik = Context.Set<Database.Korisnici>().Find(korisnik.Id);
                if (databaseKorisnik != null)
                {
                    korisnik.SlikaBase64 = databaseKorisnik.Slika != null ? Convert.ToBase64String(databaseKorisnik.Slika) : null;
                }
            }

            return pagedKorisnici;
        }

        public override Model.Korisnici GetById(int id)
        {
            var entity = Context.Korisnicis.Include(k => k.Ulogas).FirstOrDefault(k => k.Id == id);

            if (entity != null)
            {
                var model = Mapper.Map<Model.Korisnici>(entity);    

                model.SlikaBase64 = entity.Slika != null ? Convert.ToBase64String(entity.Slika) : null;

                return model;
            }
            else
            {
                return null;
            }
        }

        public override Model.Korisnici Insert(KorisniciInsertRequest request)
        {
            var entity = Mapper.Map<Database.Korisnici>(request);

            BeforeInsert(request, entity);

            Context.Add(entity);
            Context.SaveChanges();

            var model = Mapper.Map<Model.Korisnici>(entity);

            model.SlikaBase64 = entity.Slika != null
                ? Convert.ToBase64String(entity.Slika)
                : null;

            return model;
        }

        public override Model.Korisnici Update(int id, KorisniciUpdateRequest request)
        {
            var set = Context.Set<Database.Korisnici>();

            var entity = set.Find(id);

            if (entity == null)
                return null;

            Mapper.Map(request, entity);

            BeforeUpdate(request, entity);

            Context.SaveChanges();

            var model = Mapper.Map<Model.Korisnici>(entity);

            model.SlikaBase64 = entity.Slika != null
                ? Convert.ToBase64String(entity.Slika)
                : null;

            return model;
        }

        public override void BeforeInsert(KorisniciInsertRequest request, Database.Korisnici entity)
        {
            if (request.Lozinka != request.LozinkaPotvrda)
            {
                throw new Exception("Lozinka i LozinkaPotvrda moraju biti iste!");
            }

            entity.PasswordSalt = GenerateSalt();
            entity.PasswordHash = GenerateHash(entity.PasswordSalt, request.LozinkaPotvrda);

            if (!string.IsNullOrEmpty(request.SlikaBase64))
            {
                entity.Slika = Convert.FromBase64String(request.SlikaBase64);
            }

            foreach (var ulogaId in request.UlogaId)
            {
                var uloga = Context.Uloges.FirstOrDefault(u => u.Id == ulogaId);
                if (uloga == null)
                    throw new Exception($"Uloga sa ID {ulogaId} nije pronadjena");

                entity.Ulogas.Add(uloga);
            }

            base.BeforeInsert(request, entity);
        }
        public static string GenerateSalt()
        {
            var byteArray = RNGCryptoServiceProvider.GetBytes(16);
            return Convert.ToBase64String(byteArray);
        }

        public static string GenerateHash(string salt, string password)
        {
            byte[] src = Convert.FromBase64String(salt);
            byte[] bytes = Encoding.Unicode.GetBytes(password);
            byte[] dst = new byte[src.Length + bytes.Length];

            System.Buffer.BlockCopy(src, 0, dst, 0, src.Length);
            System.Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

            HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
            byte[] inArray = algorithm.ComputeHash(dst);
            return Convert.ToBase64String(inArray);
        }

        public override void BeforeUpdate(KorisniciUpdateRequest request, Database.Korisnici entity)
        {
            base.BeforeUpdate(request, entity);
            if (request.Lozinka != null)
            {
                if (request.Lozinka != request.LozinkaPotvrda)
                {
                    throw new Exception("Lozinka i LozinkaPotvrda moraju biti iste!");
                }

                entity.PasswordSalt = GenerateSalt();
                entity.PasswordHash = GenerateHash(entity.PasswordSalt, request.Lozinka);
            }

            if (!string.IsNullOrEmpty(request.SlikaBase64))
            {
                entity.Slika = Convert.FromBase64String(request.SlikaBase64);
            }

            if(request.UlogaId != null)
            {
                entity.Ulogas.Clear();
                foreach (var ulogaId in request.UlogaId)
                {
                    var uloga = Context.Uloges.FirstOrDefault(u => u.Id == ulogaId);
                    if (uloga == null)
                        throw new Exception($"Uloga sa ID {ulogaId} nije pronadjena");

                    entity.Ulogas.Add(uloga);
                }
            }
        }

        public Model.Korisnici Login(string username, string password)
        {
            var entity = Context.Korisnicis.Include(x => x.Ulogas).FirstOrDefault(x => x.KorisnickoIme == username);

            if (entity == null)
                return null;

            var hash = GenerateHash(entity.PasswordSalt, password);

            if (hash != entity.PasswordHash)
                return null;

            return this.Mapper.Map<Model.Korisnici>(entity);
        }

        public int GetCurrentUserId()
        {
            var username = _httpContextAccessor.HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(username))
            {
                throw new UnauthorizedAccessException("Korisnik nije autentifikovan.");
            }

            var user = Context.Korisnicis.FirstOrDefault(u => u.KorisnickoIme == username);
            if (user == null)
            {
                throw new UnauthorizedAccessException("Korisnik nije pronadjen.");
            }

            return user.Id;
        }
    }
}
