using System;
using System.Collections.Generic;

namespace CineMatic.Services.Database;

public partial class KategorijeHraneIpića
{
    public int Id { get; set; }

    public string Naziv { get; set; } = null!;

    public virtual ICollection<HraneIpića> HraneIpićas { get; set; } = new List<HraneIpića>();
}
