using System;
using System.Collections.Generic;

namespace CineMatic.Services.Database;

public partial class Korisnici
{
    public int Id { get; set; }

    public string? Ime { get; set; }

    public string? Prezime { get; set; }

    public string? KorisnickoIme { get; set; }

    public string? Email { get; set; }

    public byte[]? Slika { get; set; }

    public string? PasswordSalt { get; set; }

    public string? PasswordHash { get; set; }

    public virtual ICollection<Rezencije> Rezencijes { get; set; } = new List<Rezencije>();

    public virtual ICollection<Rezervacije> Rezervacijes { get; set; } = new List<Rezervacije>();

    public virtual ICollection<Uplate> Uplates { get; set; } = new List<Uplate>();

    public virtual ICollection<Uloge> Ulogas { get; set; } = new List<Uloge>();
}
