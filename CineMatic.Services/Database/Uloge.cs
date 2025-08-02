using System;
using System.Collections.Generic;

namespace CineMatic.Services.Database;

public partial class Uloge
{
    public int Id { get; set; }

    public string? Naziv { get; set; }

    public virtual ICollection<Korisnici> Korisniks { get; set; } = new List<Korisnici>();
}
