using System;
using System.Collections.Generic;

namespace CineMatic.Services.Database;

public partial class Žanrovi
{
    public int Id { get; set; }

    public string? Naziv { get; set; }

    public virtual ICollection<Filmovi> Films { get; set; } = new List<Filmovi>();
}
