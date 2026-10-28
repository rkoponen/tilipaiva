# Tilipäivä — App Store metadata

Draft copy for App Store Connect. Verify against the current App Store Connect fields before submitting.

## Listing

| Field | Value |
| --- | --- |
| Name | Tilipäivä |
| Subtitle | Päivät tilipäivään |
| Primary category | Finance |
| Secondary category | Utilities (optional) |
| Support URL | https://tilipäivä.ruupert.fi/ |
| Marketing URL | https://tilipäivä.ruupert.fi/ |
| Privacy policy URL | https://tilipäivä.ruupert.fi/privacy.html |
| Copyright | © 2026 Ruupert Koponen |
| Price | Free |

The support, marketing, and privacy URLs use the IDN **tilipäivä.ruupert.fi** —
the same domain in Unicode that the app links to. If a form rejects the non-ASCII
host, its punycode form is `xn--tilipiv-9wac.ruupert.fi` (same pages).

Keywords (100 characters, comma-separated, no spaces):

```
tilipäivä,maksupäivä,palkka,kela,etuudet,lapsilisä,opintotuki,eläke,pankkipäivä,tulot,muistutus
```

## Privacy

- App Privacy: **Data Not Collected**.
- `ITSAppUsesNonExemptEncryption = NO` is set, so no export-compliance documents are required.
- `PrivacyInfo.xcprivacy` declares no tracking, no collected data, and no required-reason APIs.

## Promotional text (fi)

Näe tulevat tilipäivät vilauksella.

## Description (fi)

Montako päivää on seuraavaan maksuun? Tilipäivä vastaa.

Päivät lasketaan suomalaisilla pankkipäiväsäännöillä: arkipäivät ilman pankkivapaapäiviä, pääsiäinen ja juhannus mukaan lukien.

Lisää palkka tai Kelan etuus ja valitse sääntö. Kuukauden päivä, ensimmäinen tai viimeinen pankkipäivä, n:s viikonpäivä tai joka toinen viikko. Loput hoitaa sovellus.

Widget näyttää jäljellä olevat päivät koti- ja lukitusnäytöllä. Maksupäivänä saat halutessasi muistutuksen, ja sovellus juhlii sitä konfetilla.

Maksupäivät ovat arvioita. Tarkista ajantasainen tieto OmaKelasta.

Ei tilejä, ei mainoksia, ei tiedonkeruuta.

## Description (en)

How many days until payday? Tilipäivä answers it at a glance.

Tilipäivä works out your next payment for you, and knows the Finnish banking-day rules: weekdays excluding bank holidays, Easter and Midsummer included. No more entering dates by hand every month.

- Your next payday as one big number and date
- Salary and Kela benefits in one place
- Flexible rules: day of month, first or last banking day, last weekday of the month, the Nth banking day, and the Nth weekday
- Kela benefits: national pension, rehabilitation allowance and disability pension, child maintenance allowance, child benefit, study grant, child home care allowance, and flexible and partial care allowance
- Home Screen and Lock Screen widgets
- A reminder on the morning of a payment day

Kela payment days are estimates. Always check the up-to-date information in OmaKela.

Tilipäivä collects no data. Everything is calculated on your device.

## What's New (1.0)

First release.
