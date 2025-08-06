using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model
{
    public partial class HraneIpića
    {
        public int Id { get; set; }

        public int? KategorijaId { get; set; }

        public string? Naziv { get; set; }

        public decimal? Cijena { get; set; }

        public string? Opis { get; set; }

        public int? KoličinaUskladištu { get; set; }

        public virtual KategorijeHraneIpića? Kategorija { get; set; }
    }
}
