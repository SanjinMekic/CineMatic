using System;
using System.Collections.Generic;

namespace CineMatic.Services.Database;

public partial class DobneRestrikcije
{
    public int Id { get; set; }

    public string? Restrikcija { get; set; }

    public string? Opis { get; set; }

    public virtual ICollection<Filmovi> Filmovis { get; set; } = new List<Filmovi>();
}
