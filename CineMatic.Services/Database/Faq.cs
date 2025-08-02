using System;
using System.Collections.Generic;

namespace CineMatic.Services.Database;

public partial class Faq
{
    public int Id { get; set; }

    public int? KategorijaId { get; set; }

    public string Pitanje { get; set; } = null!;

    public string Odgovor { get; set; } = null!;

    public virtual Faqkategorije? Kategorija { get; set; }
}
