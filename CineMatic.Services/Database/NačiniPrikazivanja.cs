using System;
using System.Collections.Generic;

namespace CineMatic.Services.Database;

public partial class NačiniPrikazivanja
{
    public int Id { get; set; }

    public string? Naziv { get; set; }

    public virtual ICollection<Projekcije> Projekcijes { get; set; } = new List<Projekcije>();
}
