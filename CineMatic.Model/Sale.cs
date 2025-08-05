using System;
using System.Collections.Generic;
using System.Text;

namespace CineMatic.Model
{
    public partial class Sale
    {
        public int Id { get; set; }

        public string? Naziv { get; set; }

        public virtual ICollection<Projekcije> Projekcijes { get; set; } = new List<Projekcije>();
    }
}
