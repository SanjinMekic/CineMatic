using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model
{
    public partial class Projekcije
    {
        public int Id { get; set; }

        public int? FilmId { get; set; }

        public int? SalaId { get; set; }

        public int? NačinProjekcijeId { get; set; }

        public DateTime? DatumIvrijeme { get; set; }

        public decimal? Cijena { get; set; }

        public string? StateMachine { get; set; }

        public virtual Filmovi? Film { get; set; }

        public virtual NačiniPrikazivanja? NačinProjekcije { get; set; }

        public virtual ICollection<ProjekcijeSjedištum> ProjekcijeSjedišta { get; set; } = new List<ProjekcijeSjedištum>();

        public virtual ICollection<Rezervacije> Rezervacijes { get; set; } = new List<Rezervacije>();

        public virtual Sale? Sala { get; set; }
    }
}
