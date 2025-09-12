using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace CineMatic.Services.Database;

public partial class Ib210083Context : DbContext
{
    public Ib210083Context()
    {
    }

    public Ib210083Context(DbContextOptions<Ib210083Context> options)
        : base(options)
    {
    }

    public virtual DbSet<DobneRestrikcije> DobneRestrikcijes { get; set; }

    public virtual DbSet<Faq> Faqs { get; set; }

    public virtual DbSet<Faqkategorije> Faqkategorijes { get; set; }

    public virtual DbSet<Filmovi> Filmovis { get; set; }

    public virtual DbSet<Glumci> Glumcis { get; set; }

    public virtual DbSet<HraneIpića> HraneIpićas { get; set; }

    public virtual DbSet<KategorijeHraneIpića> KategorijeHraneIpićas { get; set; }

    public virtual DbSet<Korisnici> Korisnicis { get; set; }

    public virtual DbSet<NačiniPrikazivanja> NačiniPrikazivanjas { get; set; }

    public virtual DbSet<Projekcije> Projekcijes { get; set; }

    public virtual DbSet<ProjekcijeSjedištum> ProjekcijeSjedišta { get; set; }

    public virtual DbSet<Recenzije> Recenzijes { get; set; }

    public virtual DbSet<Rezervacije> Rezervacijes { get; set; }

    public virtual DbSet<RezervacijeHraneIpića> RezervacijeHraneIpićas { get; set; }

    public virtual DbSet<RezervacijeSjedištum> RezervacijeSjedišta { get; set; }

    public virtual DbSet<Režiseri> Režiseris { get; set; }

    public virtual DbSet<Sale> Sales { get; set; }

    public virtual DbSet<Sjedištum> Sjedišta { get; set; }

    public virtual DbSet<Uloge> Uloges { get; set; }

    public virtual DbSet<Uplate> Uplates { get; set; }

    public virtual DbSet<Žanrovi> Žanrovis { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Server=localhost; Database=IB210083; Integrated Security=True; TrustServerCertificate=True;");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<DobneRestrikcije>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__DobneRes__3214EC27EB3B297F");

            entity.ToTable("DobneRestrikcije");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Restrikcija).HasMaxLength(10);
        });

        modelBuilder.Entity<Faq>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__FAQs__3214EC27CDE5B83F");

            entity.ToTable("FAQs");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.KategorijaId).HasColumnName("KategorijaID");

            entity.HasOne(d => d.Kategorija).WithMany(p => p.Faqs)
                .HasForeignKey(d => d.KategorijaId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__FAQs__Kategorija__01142BA1");
        });

        modelBuilder.Entity<Faqkategorije>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__FAQKateg__3214EC27C4CA802A");

            entity.ToTable("FAQKategorije");

            entity.HasIndex(e => e.Naziv, "UQ__FAQKateg__603E8146801BB03E").IsUnique();

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Naziv)
                .HasMaxLength(100)
                .IsUnicode(false);
        });

        modelBuilder.Entity<Filmovi>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Filmovi__3214EC27FBFA0D8C");

            entity.ToTable("Filmovi");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.DobnaRestrikcijaId).HasColumnName("DobnaRestrikcijaID");
            entity.Property(e => e.Naziv).HasMaxLength(100);

            entity.HasOne(d => d.DobnaRestrikcija).WithMany(p => p.Filmovis)
                .HasForeignKey(d => d.DobnaRestrikcijaId)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("FK__Filmovi__DobnaRe__412EB0B6");

            entity.HasMany(d => d.Glumacs).WithMany(p => p.Films)
                .UsingEntity<Dictionary<string, object>>(
                    "FilmoviGlumci",
                    r => r.HasOne<Glumci>().WithMany()
                        .HasForeignKey("GlumacId")
                        .HasConstraintName("FK__FilmoviGl__Gluma__4CA06362"),
                    l => l.HasOne<Filmovi>().WithMany()
                        .HasForeignKey("FilmId")
                        .HasConstraintName("FK__FilmoviGl__FilmI__4BAC3F29"),
                    j =>
                    {
                        j.HasKey("FilmId", "GlumacId").HasName("PK__FilmoviG__DA650C700805D8A1");
                        j.ToTable("FilmoviGlumci");
                        j.IndexerProperty<int>("FilmId").HasColumnName("FilmID");
                        j.IndexerProperty<int>("GlumacId").HasColumnName("GlumacID");
                    });

            entity.HasMany(d => d.Režisers).WithMany(p => p.Films)
                .UsingEntity<Dictionary<string, object>>(
                    "FilmoviRežiseri",
                    r => r.HasOne<Režiseri>().WithMany()
                        .HasForeignKey("RežiserId")
                        .HasConstraintName("FK__FilmoviRe__Režis__52593CB8"),
                    l => l.HasOne<Filmovi>().WithMany()
                        .HasForeignKey("FilmId")
                        .HasConstraintName("FK__FilmoviRe__FilmI__5165187F"),
                    j =>
                    {
                        j.HasKey("FilmId", "RežiserId").HasName("PK__FilmoviR__DDCBEC4E35A2354A");
                        j.ToTable("FilmoviRežiseri");
                        j.IndexerProperty<int>("FilmId").HasColumnName("FilmID");
                        j.IndexerProperty<int>("RežiserId").HasColumnName("RežiserID");
                    });

            entity.HasMany(d => d.Žanrs).WithMany(p => p.Films)
                .UsingEntity<Dictionary<string, object>>(
                    "FilmoviŽanrovi",
                    r => r.HasOne<Žanrovi>().WithMany()
                        .HasForeignKey("ŽanrId")
                        .HasConstraintName("FK__FilmoviŽa__ŽanrI__46E78A0C"),
                    l => l.HasOne<Filmovi>().WithMany()
                        .HasForeignKey("FilmId")
                        .HasConstraintName("FK__FilmoviŽa__FilmI__45F365D3"),
                    j =>
                    {
                        j.HasKey("FilmId", "ŽanrId").HasName("PK__FilmoviŽ__3A8AE31030E8A3EF");
                        j.ToTable("FilmoviŽanrovi");
                        j.IndexerProperty<int>("FilmId").HasColumnName("FilmID");
                        j.IndexerProperty<int>("ŽanrId").HasColumnName("ŽanrID");
                    });
        });

        modelBuilder.Entity<Glumci>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Glumci__3214EC27771E84C4");

            entity.ToTable("Glumci");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.DatumRodjenja).HasColumnType("datetime");
            entity.Property(e => e.Ime).HasMaxLength(50);
            entity.Property(e => e.Opis).IsUnicode(false);
            entity.Property(e => e.Prezime).HasMaxLength(50);
        });

        modelBuilder.Entity<HraneIpića>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__HraneIPi__3214EC278819989A");

            entity.ToTable("HraneIPića");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Cijena).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.KategorijaId).HasColumnName("KategorijaID");
            entity.Property(e => e.KoličinaUskladištu).HasColumnName("KoličinaUSkladištu");
            entity.Property(e => e.Naziv).HasMaxLength(100);
            entity.Property(e => e.Opis).IsUnicode(false);

            entity.HasOne(d => d.Kategorija).WithMany(p => p.HraneIpićas)
                .HasForeignKey(d => d.KategorijaId)
                .HasConstraintName("FK__HraneIPić__Kateg__72C60C4A");
        });

        modelBuilder.Entity<KategorijeHraneIpića>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Kategori__3214EC27A186A97E");

            entity.ToTable("KategorijeHraneIPića");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Naziv).HasMaxLength(100);
        });

        modelBuilder.Entity<Korisnici>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Korisnic__3214EC2710A3E7E3");

            entity.ToTable("Korisnici");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Email)
                .HasMaxLength(100)
                .IsUnicode(false);
            entity.Property(e => e.Ime).HasMaxLength(50);
            entity.Property(e => e.KorisnickoIme).HasMaxLength(50);
            entity.Property(e => e.PasswordHash).HasMaxLength(128);
            entity.Property(e => e.PasswordSalt).HasMaxLength(128);
            entity.Property(e => e.Prezime).HasMaxLength(50);

            entity.HasMany(d => d.Ulogas).WithMany(p => p.Korisniks)
                .UsingEntity<Dictionary<string, object>>(
                    "KorisniciUloge",
                    r => r.HasOne<Uloge>().WithMany()
                        .HasForeignKey("UlogaId")
                        .HasConstraintName("FK__Korisnici__Uloga__3C69FB99"),
                    l => l.HasOne<Korisnici>().WithMany()
                        .HasForeignKey("KorisnikId")
                        .HasConstraintName("FK__Korisnici__Koris__3B75D760"),
                    j =>
                    {
                        j.HasKey("KorisnikId", "UlogaId").HasName("PK__Korisnic__2D7ADF5FCF517FE3");
                        j.ToTable("KorisniciUloge");
                        j.IndexerProperty<int>("KorisnikId").HasColumnName("KorisnikID");
                        j.IndexerProperty<int>("UlogaId").HasColumnName("UlogaID");
                    });
        });

        modelBuilder.Entity<NačiniPrikazivanja>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__NačiniPr__3214EC27EFB314A2");

            entity.ToTable("NačiniPrikazivanja");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Naziv).HasMaxLength(50);
        });

        modelBuilder.Entity<Projekcije>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Projekci__3214EC2754435A3E");

            entity.ToTable("Projekcije");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Cijena).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.DatumIvrijeme)
                .HasColumnType("datetime")
                .HasColumnName("DatumIVrijeme");
            entity.Property(e => e.FilmId).HasColumnName("FilmID");
            entity.Property(e => e.NačinProjekcijeId).HasColumnName("NačinProjekcijeID");
            entity.Property(e => e.SalaId).HasColumnName("SalaID");
            entity.Property(e => e.Stanje).HasMaxLength(50);

            entity.HasOne(d => d.Film).WithMany(p => p.Projekcijes)
                .HasForeignKey(d => d.FilmId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__Projekcij__FilmI__59063A47");

            entity.HasOne(d => d.NačinProjekcije).WithMany(p => p.Projekcijes)
                .HasForeignKey(d => d.NačinProjekcijeId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__Projekcij__Način__5AEE82B9");

            entity.HasOne(d => d.Sala).WithMany(p => p.Projekcijes)
                .HasForeignKey(d => d.SalaId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__Projekcij__SalaI__59FA5E80");
        });

        modelBuilder.Entity<ProjekcijeSjedištum>(entity =>
        {
            entity.HasKey(e => new { e.ProjekcijaId, e.SjedišteId }).HasName("PK__Projekci__75A0063CAEC53D95");

            entity.Property(e => e.ProjekcijaId).HasColumnName("ProjekcijaID");
            entity.Property(e => e.SjedišteId).HasColumnName("SjedišteID");
            entity.Property(e => e.Rezervisano).HasDefaultValue(false);

            entity.HasOne(d => d.Projekcija).WithMany(p => p.ProjekcijeSjedišta)
                .HasForeignKey(d => d.ProjekcijaId)
                .HasConstraintName("FK__Projekcij__Proje__60A75C0F");

            entity.HasOne(d => d.Sjedište).WithMany(p => p.ProjekcijeSjedišta)
                .HasForeignKey(d => d.SjedišteId)
                .HasConstraintName("FK__Projekcij__Sjedi__619B8048");
        });

        modelBuilder.Entity<Recenzije>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Recenzij__3214EC27C0902DAC");

            entity.ToTable("Recenzije");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.DatumIvrijeme)
                .HasColumnType("datetime")
                .HasColumnName("DatumIVrijeme");
            entity.Property(e => e.FilmId).HasColumnName("FilmID");
            entity.Property(e => e.KorisnikId).HasColumnName("KorisnikID");

            entity.HasOne(d => d.Film).WithMany(p => p.Recenzijes)
                .HasForeignKey(d => d.FilmId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__Recenzije__FilmI__7B5B524B");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.Recenzijes)
                .HasForeignKey(d => d.KorisnikId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__Recenzije__Koris__7A672E12");
        });

        modelBuilder.Entity<Rezervacije>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Rezervac__3214EC27E23FC007");

            entity.ToTable("Rezervacije");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.DatumIvrijeme)
                .HasColumnType("datetime")
                .HasColumnName("DatumIVrijeme");
            entity.Property(e => e.KorisnikId).HasColumnName("KorisnikID");
            entity.Property(e => e.NačinPlaćanja)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasDefaultValue("Gotovina");
            entity.Property(e => e.ProjekcijaId).HasColumnName("ProjekcijaID");
            entity.Property(e => e.QrcodeBase64).HasColumnName("QRCodeBase64");
            entity.Property(e => e.UkupnaCijena).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.UplataId).HasColumnName("UplataID");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.Rezervacijes)
                .HasForeignKey(d => d.KorisnikId)
                .HasConstraintName("FK__Rezervaci__Koris__68487DD7");

            entity.HasOne(d => d.Projekcija).WithMany(p => p.Rezervacijes)
                .HasForeignKey(d => d.ProjekcijaId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__Rezervaci__Proje__693CA210");

            entity.HasOne(d => d.Uplata).WithMany(p => p.Rezervacijes)
                .HasForeignKey(d => d.UplataId)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("FK__Rezervaci__Uplat__6A30C649");
        });

        modelBuilder.Entity<RezervacijeHraneIpića>(entity =>
        {
            entity.HasKey(e => new { e.RezervacijaId, e.HranaIpićeId }).HasName("PK__Rezervac__FAB9901029530086");

            entity.ToTable("RezervacijeHraneIPića");

            entity.Property(e => e.RezervacijaId).HasColumnName("RezervacijaID");
            entity.Property(e => e.HranaIpićeId).HasColumnName("HranaIPićeID");
            entity.Property(e => e.Kolicina).HasDefaultValue(1);

            entity.HasOne(d => d.HranaIpiće).WithMany(p => p.RezervacijeHraneIpićas)
                .HasForeignKey(d => d.HranaIpićeId)
                .HasConstraintName("FK__Rezervaci__Hrana__778AC167");

            entity.HasOne(d => d.Rezervacija).WithMany(p => p.RezervacijeHraneIpićas)
                .HasForeignKey(d => d.RezervacijaId)
                .HasConstraintName("FK__Rezervaci__Kolic__76969D2E");
        });

        modelBuilder.Entity<RezervacijeSjedištum>(entity =>
        {
            entity.HasKey(e => new { e.RezervacijaId, e.SjedišteId }).HasName("PK__Rezervac__569D2F5A402093A6");

            entity.Property(e => e.RezervacijaId).HasColumnName("RezervacijaID");
            entity.Property(e => e.SjedišteId).HasColumnName("SjedišteID");
            entity.Property(e => e.DatumIvrijeme)
                .HasColumnType("datetime")
                .HasColumnName("DatumIVrijeme");

            entity.HasOne(d => d.Rezervacija).WithMany(p => p.RezervacijeSjedišta)
                .HasForeignKey(d => d.RezervacijaId)
                .HasConstraintName("FK__Rezervaci__Rezer__6D0D32F4");

            entity.HasOne(d => d.Sjedište).WithMany(p => p.RezervacijeSjedišta)
                .HasForeignKey(d => d.SjedišteId)
                .HasConstraintName("FK__Rezervaci__Sjedi__6E01572D");
        });

        modelBuilder.Entity<Režiseri>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Režiseri__3214EC27C61B6C33");

            entity.ToTable("Režiseri");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.DatumRodjenja).HasColumnType("datetime");
            entity.Property(e => e.Ime).HasMaxLength(50);
            entity.Property(e => e.Prezime).HasMaxLength(50);
        });

        modelBuilder.Entity<Sale>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Sale__3214EC27EDFD2AA9");

            entity.ToTable("Sale");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Naziv).HasMaxLength(50);
        });

        modelBuilder.Entity<Sjedištum>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Sjedišta__3214EC27AD8F9561");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Naziv).HasMaxLength(10);
        });

        modelBuilder.Entity<Uloge>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Uloge__3214EC2740DE8020");

            entity.ToTable("Uloge");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Naziv).HasMaxLength(50);
        });

        modelBuilder.Entity<Uplate>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Uplate__3214EC27AEFE03B2");

            entity.ToTable("Uplate");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.DatumIvrijeme)
                .HasColumnType("datetime")
                .HasColumnName("DatumIVrijeme");
            entity.Property(e => e.Izdavač)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.Iznos).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.KorisnikId).HasColumnName("KorisnikID");
            entity.Property(e => e.TransakcijaId)
                .HasMaxLength(255)
                .IsUnicode(false)
                .HasColumnName("TransakcijaID");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.Uplates)
                .HasForeignKey(d => d.KorisnikId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__Uplate__Korisnik__6477ECF3");
        });

        modelBuilder.Entity<Žanrovi>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Žanrovi__3214EC2781C6B829");

            entity.ToTable("Žanrovi");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Naziv).HasMaxLength(50);
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
