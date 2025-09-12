using System;
using System.Collections.Generic;

namespace CineMatic.Services.Database;

public partial class RezervacijeHraneIpića
{
    public int RezervacijaId { get; set; }

    public int HranaIpićeId { get; set; }

    public int? Kolicina { get; set; }

    public virtual HraneIpića HranaIpiće { get; set; } = null!;

    public virtual Rezervacije Rezervacija { get; set; } = null!;
}
