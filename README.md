## 🎬 CineMatic

CineMatic je informacioni sistem za kino koji omogućava digitalizaciju procesa kupovine karata, rezervacija, praćenja projekcija i ostavljanja recenzija.
Sistem obuhvata desktop aplikaciju za administratore i mobilnu aplikaciju za korisnike i blagajnike (uposlenike kina), te backend razvijen u ASP.NET Core.

---

### 🚀 Upute za pokretanje

#### 🔹 Backend setup

1. Klonirati CineMatic repozitorij.

2. Pozicionirati se u klonirani repozitorij te u terminalu pokrenuti komandu: docker-compose up --build

3. Sačekati da se backend i baza uspješno buildaju. ⏳

---

#### 🔹 Desktop aplikacija (admin)

1. Extractovati arhivu: fit-build-2025-10-01-desktop

2. U folderu Release pokrenuti fajl: cinematic_desktop.exe

3. Prijaviti se pomoću admin kredencijala (kredencijali u nastavku...).

---

#### 🔹 Mobilna aplikacija (korisnici i blagajnici)

1. Prije instalacije provjeriti da na emulatoru/uređaju nije instalirana stara verzija aplikacije. Ako jeste → deinstalirati.

2. Extractovati arhivu: fit-build-2025-10-01-mobile

3. U folderu flutter-apk nalazi se fajl: app-release.apk
   → prevući na emulator ili fizički uređaj i sačekati da se aplikacija instalira.

4. Pokrenuti aplikaciju i prijaviti se pomoću testnih kredencijala (kredencijali u nastavku...).

---

#### 🔐 Kredencijali za prijavu

##### Administrator (desktop)

- username: admin
- password: admin

##### Korisnik (mobilna aplikacija)

- username: user
- password: user

##### Blagajnik (mobilna aplikacija)

- username: blagajnik
- password: blagajnik
- Preporuka: koristiti fizički uređaj radi testiranja modula za skeniranje i poništavanje QR kod karti, ukoliko ne postoji ta mogućnost, postoji opcija za ručno poništavanje karte.

---

#### 💳 Stripe testiranje

Za testiranje plaćanja u mobilnoj aplikaciji koristite sljedeće podatke:

1. Broj kartice: 4242 4242 4242 4242

2. Datum isteka: bilo koji budući datum

3. CVC: bilo koji trocifreni broj

4. ZIP kod: bilo koji petocifreni broj

---

#### 📩 RabbitMQ integracija

CineMatic koristi RabbitMQ mikroservis za automatsko slanje email obavijesti u sljedećim slučajevima:

- Registracija novog korisnika na mobilnoj aplikaciji

- Kreiranje novog administratora/blagajnika ili korisnika od strane administratora putem desktop aplikacije (administratori i blagajnici putem emaila dobiju korisničko ime i privremenu lozinku)

---

#### 🛠️ Tehnologije

- Backend: ASP.NET Core (C#), EF Core

- Frontend: Flutter (desktop i mobilna aplikacija)

- Baza podataka: SQL Server

- Autentifikacija & autorizacija: BasicAuth

- Message Broker: RabbitMQ

- Plaćanje: Stripe

- Containerization: Docker

---

📌 Projekt razvijen u sklopu predmeta Razvoj softvera 2 na Fakultetu informacijskih tehnologija Mostar.
