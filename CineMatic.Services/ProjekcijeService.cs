using CineMatic.Model;
using CineMatic.Model.Requests;
using CineMatic.Model.SearchObject;
using CineMatic.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CineMatic.Services
{
    public class ProjekcijeService : BaseCRUDService<Model.Projekcije, ProjekcijeSearchObject, Database.Projekcije, ProjekcijeInsertRequest, ProjekcijeUpdateRequest>, IProjekcijeService
    {
        public ProjekcijeService(Ib210083Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Database.Projekcije> AddFilter(ProjekcijeSearchObject search, IQueryable<Database.Projekcije> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.Naziv))
            {
                filteredQuery = filteredQuery.Where(x => x.Film.Naziv.ToLower().Contains(search.Naziv.ToLower()));

            }

            if (search.isFilmoviIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.Film);
            }

            if (search.isNačiniProjekcijeIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.NačinProjekcije);
            }

            if (search.isSaleIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.Sala);
            }

            if (search.Datum.HasValue)
            {
                filteredQuery = filteredQuery.Where(x => x.DatumIvrijeme.Value.Date == search.Datum.Value.Date);
            }

            return filteredQuery;
        }

        public override PagedResult<Model.Projekcije> GetPaged(ProjekcijeSearchObject search)
        {
            var pagedProjekcije = base.GetPaged(search);

            foreach(var projekcija in pagedProjekcije.ResultList)
            {
                if(search.isFilmoviIncluded == true)
                {
                    var dbProjekcija = Context.Projekcijes.Include(p => p.Film).FirstOrDefault(p => p.Id == projekcija.Id);
                    if(dbProjekcija.Film != null)
                    {
                        projekcija.Film.SlikaBase64 = dbProjekcija.Film.Slika != null ? Convert.ToBase64String(dbProjekcija.Film.Slika) : null;
                    }
                }
            }

            return pagedProjekcije; 
        }

        public override Model.Projekcije GetById(int id)
        {
            var entity = Context.Projekcijes.Include(p => p.Film).Include(p => p.Sala).Include(p => p.NačinProjekcije).FirstOrDefault(p => p.Id == id);
        
            if(entity != null)
            {
                var model = Mapper.Map<Model.Projekcije>(entity);

                if(entity.Film != null)
                {
                    model.Film.SlikaBase64 = entity.Film.Slika != null ? Convert.ToBase64String(entity.Film.Slika) : null;
                }

                return model;
            }
            return null;
        }

        public override void BeforeInsert(ProjekcijeInsertRequest request, Database.Projekcije entity)
        {
            var movie = Context.Filmovis.FirstOrDefault(f => f.Id == request.FilmId);
            if (movie == null)
                throw new Exception("Film nije pronadjen");

            var hall = Context.Sales.FirstOrDefault(s => s.Id == request.SalaId);
            if (hall == null)
                throw new Exception("Sala nije pronadjena");

            var viewMode = Context.NačiniPrikazivanjas.FirstOrDefault(n => n.Id == request.NačinProjekcijeId);
            if (viewMode == null)
                throw new Exception("Nacin projekcije nije pronadjen");

            base.BeforeInsert(request, entity);
        }

        public override void BeforeUpdate(ProjekcijeUpdateRequest request, Database.Projekcije entity)
        {
            base.BeforeUpdate(request, entity);

            var movie = Context.Filmovis.FirstOrDefault(f => f.Id == request.FilmId);
            if (movie == null)
                throw new Exception("Film nije pronadjen");

            var hall = Context.Sales.FirstOrDefault(s => s.Id == request.SalaId);
            if (hall == null)
                throw new Exception("Sala nije pronadjena");

            var viewMode = Context.NačiniPrikazivanjas.FirstOrDefault(n => n.Id == request.NačinProjekcijeId);
            if (viewMode == null)
                throw new Exception("Nacin projekcije nije pronadjen");
        }

        public override Model.Projekcije Insert(ProjekcijeInsertRequest request)
        {
            if (request.DatumIvrijeme <= DateTime.Now)
                throw new Exception("Datum mora biti u budućnosti");

            var entity = Mapper.Map<Database.Projekcije>(request);

            Context.Add(entity);
            Context.SaveChanges();

            var sjedista = Context.Sjedišta.ToList();

            foreach (var sjediste in sjedista)
            {
                var projekcijaSjediste = new Database.ProjekcijeSjedištum
                {
                    ProjekcijaId = entity.Id,
                    SjedišteId = sjediste.Id,
                    Rezervisano = false,
                };

                Context.ProjekcijeSjedišta.Add(projekcijaSjediste);
                Context.SaveChanges();
            }

            var projekcija = Context.Projekcijes
            .Include(s => s.Film)
            .Include(s => s.Sala)
            .Include(s => s.NačinProjekcije)
            .FirstOrDefault(s => s.Id == entity.Id);

            return Mapper.Map<Model.Projekcije>(projekcija);
        }

        public override Model.Projekcije Update(int id, ProjekcijeUpdateRequest request)
        {
            var entity = Context.Projekcijes
                .Include(p => p.Film)
                .Include(p => p.Sala)
                .Include(p => p.NačinProjekcije)
                .FirstOrDefault(p => p.Id == id);

            if (entity == null)
                throw new Exception("Projekcija nije pronađena");

            if (request.FilmId.HasValue)
            {
                var film = Context.Filmovis.FirstOrDefault(f => f.Id == request.FilmId.Value);
                if (film == null)
                    throw new Exception("Film nije pronađen");
                entity.FilmId = request.FilmId.Value;
            }

            if (request.SalaId.HasValue)
            {
                var sala = Context.Sales.FirstOrDefault(s => s.Id == request.SalaId.Value);
                if (sala == null)
                    throw new Exception("Sala nije pronađena");
                entity.SalaId = request.SalaId.Value;
            }

            if (request.NačinProjekcijeId.HasValue)
            {
                var način = Context.NačiniPrikazivanjas.FirstOrDefault(n => n.Id == request.NačinProjekcijeId.Value);
                if (način == null)
                    throw new Exception("Način projekcije nije pronađen");
                entity.NačinProjekcijeId = request.NačinProjekcijeId.Value;
            }

            if (request.DatumIvrijeme.HasValue)
            {
                if (request.DatumIvrijeme <= DateTime.Now)
                    throw new Exception("Datum mora biti u budućnosti");
                entity.DatumIvrijeme = request.DatumIvrijeme;
            }

            if (request.Cijena.HasValue)
            {
                entity.Cijena = request.Cijena;
            }

            if (!string.IsNullOrWhiteSpace(request.StateMachine))
            {
                entity.StateMachine = request.StateMachine;
            }

            Context.SaveChanges();

            var updatedEntity = Context.Projekcijes
                .Include(p => p.Film)
                .Include(p => p.Sala)
                .Include(p => p.NačinProjekcije)
                .FirstOrDefault(p => p.Id == id);

            return Mapper.Map<Model.Projekcije>(updatedEntity);
        }
    }
}
