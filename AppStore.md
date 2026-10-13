# Tilipäivä — App Store metadata

Draft copy for App Store Connect. Verify against the current App Store Connect fields before submitting.

## Listing

| Field | Value |
| --- | --- |
| Name | Tilipäivä |
| Subtitle | Päivät tilipäivään |
| Primary category | Finance |
| Secondary category | Utilities (optional) |
| Support URL | https://tilipaiva.ruupert.fi/ |
| Marketing URL | https://tilipaiva.ruupert.fi/ |
| Privacy policy URL | https://tilipaiva.ruupert.fi/privacy.html |
| Copyright | © 2026 Ruupert Koponen |
| Price | Free (see open questions in the build spec) |

Keywords (100 characters, comma-separated, no spaces):

```
tilipäivä,maksupäivä,palkka,kela,etuudet,lapsilisä,opintotuki,eläke,pankkipäivä,tulot
```

## Privacy

- App Privacy: **Data Not Collected**.
- `ITSAppUsesNonExemptEncryption = NO` is set, so no export-compliance documents are required.
- `PrivacyInfo.xcprivacy` declares no tracking, no collected data, and no required-reason APIs.

## Promotional text (fi)

Tilipäivä laskee seuraavan tilipäivän ja yleisimpien Kelan etuuksien maksupäivät automaattisesti suomalaisella pankkipäivälogiikalla. Ei tilejä, ei mainoksia, ei tiedonkeruuta.

## Description (fi)

Montako päivää tilipäivään? Tilipäivä vastaa yhdellä silmäyksellä.

Tilipäivä laskee seuraavan maksupäivän puolestasi ja osaa suomalaiset pankkipäiväsäännöt: arkipäivät ilman pankkivapaapäiviä, pääsiäinen ja juhannus mukaan lukien. Joka kuukausi ei tarvitse syöttää päivämääriä käsin.

- Seuraava tilipäivä isolla numerolla ja päivämäärällä
- Palkka ja Kelan etuudet samassa näkymässä
- Monipuoliset maksusäännöt: kuukauden päivä, ensimmäinen tai viimeinen pankkipäivä, kuukauden viimeinen arkipäivä, n:s pankkipäivä ja n:s viikonpäivä
- Kelan tuet: kansaneläke, kuntoutustuki ja työkyvyttömyyseläke, elatustuki, lapsilisä, opintotuki, lasten kotihoidon tuki sekä joustava ja osittainen hoitoraha
- Widget koti- ja lukitusnäytölle

Maksupäivät ovat arvioita. Tarkista ajantasainen tieto OmaKelasta.

Tilipäivä ei kerää mitään tietoja. Kaikki lasketaan laitteellasi.

## Description (en)

How many days until payday? Tilipäivä answers it at a glance.

Tilipäivä works out your next payment for you, and knows the Finnish banking-day rules: weekdays excluding bank holidays, Easter and Midsummer included. No more entering dates by hand every month.

- Your next payday as one big number and date
- Salary and Kela benefits in one place
- Flexible rules: day of month, first or last banking day, last weekday of the month, the Nth banking day, and the Nth weekday
- Kela benefits: national pension, rehabilitation allowance and disability pension, child maintenance allowance, child benefit, study grant, child home care allowance, and flexible and partial care allowance
- Home Screen and Lock Screen widgets

Kela payment days are estimates. Always check the up-to-date information in OmaKela.

Tilipäivä collects no data. Everything is calculated on your device.

## What's New (1.0)

First release.
