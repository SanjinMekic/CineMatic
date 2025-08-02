using System;
using System.Collections.Generic;

namespace CineMatic.Services.Database;

public partial class Sjedištum
{
    public int Id { get; set; }

    public string? Naziv { get; set; }

    public virtual ICollection<ProjekcijeSjedištum> ProjekcijeSjedišta { get; set; } = new List<ProjekcijeSjedištum>();

    public virtual ICollection<RezervacijeSjedištum> RezervacijeSjedišta { get; set; } = new List<RezervacijeSjedištum>();
}
