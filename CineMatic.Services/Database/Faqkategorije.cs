using System;
using System.Collections.Generic;

namespace CineMatic.Services.Database;

public partial class Faqkategorije
{
    public int Id { get; set; }

    public string Naziv { get; set; } = null!;

    public virtual ICollection<Faq> Faqs { get; set; } = new List<Faq>();
}
