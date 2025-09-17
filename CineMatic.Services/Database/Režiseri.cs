using System;
using System.Collections.Generic;

namespace CineMatic.Services.Database;

public partial class Režiseri
{
    public int Id { get; set; }

    public string? Ime { get; set; }

    public string? Prezime { get; set; }

    public DateTime? DatumRodjenja { get; set; }

    public string? Opis { get; set; }

    public byte[]? Slika { get; set; }

    public string? Uspjesi { get; set; }

    public string? RezisiraniFilmovi { get; set; }

    public virtual ICollection<Filmovi> Films { get; set; } = new List<Filmovi>();
}
