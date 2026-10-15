# Tilipäivä — project instructions

Tilipäivä is a minimal, widget-first Finnish iOS app that counts down to the next
payday and to common Kela payment days, using correct Finnish banking-day logic.
Free, no accounts, no ads, no data collection. Finnish + English.

Read this file first; it is the durable project memory. Keep it up to date when
you make decisions or change conventions.

## Build & test

`xcodebuild` is **not** on the default toolchain (active developer dir is
CommandLineTools), so always set `DEVELOPER_DIR`:

```sh
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcodebuild -list -project Tilipaiva.xcodeproj
xcodebuild test -scheme Tilipaiva \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' \
  CODE_SIGNING_ALLOWED=NO
```

- 33 unit tests (Swift Testing) live in `TilipaivaTests/`. Keep them passing.
- `CODE_SIGNING_ALLOWED=NO` avoids signing for simulator runs. Entitlements are
  not validated on an unsigned simulator build.
- To eyeball the UI: `xcrun simctl install <device> <app>` then `launch`, and
  screenshot with `xcrun simctl io <device> screenshot out.png`. The simulator's
  default language here is Finnish; force English with
  `-AppleLanguages '(en)' -AppleLocale en_US`.
- Toolkit: Xcode 27.0, Swift 6.4 compiler, `SWIFT_VERSION = 5.0`,
  `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`.

## Targets & project layout

Three targets in `Tilipaiva.xcodeproj`, using **file-system synchronized groups**
(files are picked up automatically; no pbxproj edit per file):

- `Tilipaiva` (app) → `fi.ruupert.Tilipaiva`
- `TilipaivaWidgetExtension` → `fi.ruupert.Tilipaiva.widget`
- `TilipaivaTests` → `fi.ruupert.TilipaivaTests`

iPhone-only, `IPHONEOS_DEPLOYMENT_TARGET = 26.0`, `TARGETED_DEVICE_FAMILY = 1`,
display name "Tilipäivä".

The widget target compiles the app's folder **minus an exception list** in
`project.pbxproj` (`PBXFileSystemSynchronizedBuildFileExceptionSet`, id `...045`).
It currently excludes: `About`, `AppIcon.icon`, `Assets.xcassets`,
`ContentView.swift`, `Home`, `SourceEditor`, `TilipaivaApp.swift`.

> **When you add an app-only file or folder under `Tilipaiva/`, add it to that
> exception list**, or the widget will try to compile it.

Folders:

- `Tilipaiva/Payday/` — the domain engine (shared with the widget).
- `Tilipaiva/Shared/` — shared views, `Design` constants, `Localizable.xcstrings`.
- `Tilipaiva/Home/`, `SourceEditor/`, `About/` — app-only UI.
- `TilipaivaWidget/` — widget target.
- `TilipaivaTests/` — tests. `docs/` — GitHub Pages site (`tilipaiva.ruupert.fi`).
- `AppStore.md` — App Store metadata draft.

## Domain engine (`Tilipaiva/Payday/`)

- `BankingCalendar` — `isBankingDay`, `bankingDay(onOrBefore/onOrAfter:)`,
  `next/previousBankingDay`, `first/lastBankingDay(of:)`, `lastWeekday(of:)`,
  `nthBankingDay(_:of:)`, `holidays(in:)`, `dayCount(from:to:)`. Holidays are
  derived (fixed dates + Easter via `Easter.monthAndDay`); no yearly data.
- `PaymentRule` — Codable enum with a `type` discriminator; supports
  `fixedDayOfMonth` (with `shift` and `alsoShiftOnWeekdays`),
  `firstBankingDayOfMonth`, `lastBankingDayOfMonth`, `lastWeekdayOfMonth`,
  `nthBankingDayOfMonth`, `nthWeekdayOfMonth`.
- `PaymentResolver` — resolves dates/occurrences; `upcoming(for:onOrAfter:limit:)`
  returns `[UpcomingPayment]` and `next(for:onOrAfter:)` returns one.
- `Benefits.json` + `BenefitCatalog` — the 7 Tier-1 Kela benefits as data.
- `PaymentSource`, `PaymentOccurrence`, `UpcomingPayment`, `Month`, `Weekday`.
- `SharedDefaults` + `PaymentSourceStore` — sources persisted as JSON in the
  App Group `group.fi.ruupert.Tilipaiva` (suite fallback to `.standard`).
- App side: `PaymentSourcesModel` (`@Observable`, MainActor) owns sources and
  calls `WidgetCenter.shared.reloadAllTimelines()` on change.

Note: `PaymentSource` uses the synthesized Codable, so JSON must include `name`
(required); `benefitID` is optional.

## Conventions

- Write SwiftUI to the `swiftui-pro` skill standard (deprecated API, data flow,
  accessibility, localization, performance). Prefer `foregroundStyle`,
  `clipShape(.rect(cornerRadius:))`, `.sheet(item:)`, two-parameter `onChange`.
- **One type per file.** Prefer extracting subviews into `View` structs over
  computed `some View` helpers.
- Domain types are `nonisolated` + `Sendable` so they work in the widget; the app
  relies on MainActor default isolation.
- Localization: all user-facing strings go in
  `Tilipaiva/Shared/Localizable.xcstrings` (source `en`, provide `fi`). Use
  literal keys; the plural key is `%lld days`. Benefit names come from
  `Benefits.json`, not the catalog.
- Design constants live in `Shared/Design.swift`. Respect Dynamic Type
  (`@ScaledMetric` for the hero number); icon-only buttons need text labels.
- Required Kela disclaimer string ships wherever Kela dates appear
  (`PaymentDisclaimer`): "Payment days are estimates. Check the up-to-date
  information in OmaKela."

## Key decisions (don't silently reverse these)

- **Kansaneläke uses the 7th, previous banking day** — not the first banking day.
  Verified against `kela.fi/maksupaivat` (the build spec said first banking day,
  which is wrong; työeläke, a non-Kela insurer pension, is the first-banking-day
  one). `kansanelake` and `kuntoutustuki` therefore share a rule.
- Kela rules: `kuntoutustuki` 7th prev-BD, `elatustuki` 10th prev-BD,
  `lapsilisa` 26th prev-BD + forced shift when the 26th is a Monday,
  `opintotuki` 1st next-BD, `kotihoidontuki` last weekday, `hoitoraha` last BD.
- **The default salary rule shifts to the previous banking day.** Finnish law
  requires an agreed payday that falls on a weekend, a public holiday, or any
  other non-banking day to be paid on the preceding banking day, so a new
  salary source starts as `fixedDayOfMonth(day: 15, shift: .previousBankingDay)`.
  `RuleDraft.shift` defaults to `.previousBankingDay` too. `PaymentRule`'s
  decoder still falls back to `.none` for stored sources that omit `shift`, so
  existing user data is untouched.
- App Group id `group.fi.ruupert.Tilipaiva`; both `Tilipaiva.entitlements` and
  `TilipaivaWidget.entitlements` declare it.
- Widget families: `systemSmall`, `systemMedium`, `accessoryCircular`,
  `accessoryInline`. An `accessoryRectangular` (+`RectangularCountdownView`) was
  added then removed — no Lock Screen widget occupies "two circular slots".
- Home layout: hero countdown owns ~55% of the screen; the upcoming list is a
  light, secondary, dividered list below it. About is a quiet footer link, not a
  top button (only `+` floats top-right).
- Brand accent is a "payday green" (light `#1F8A5A`, dark `#4FD1A0`); the App
  Icon is a green calendar with a marked day, made with Icon Composer
  (`Tilipaiva/AppIcon.icon`).

## Pending / manual

- **App Group must be registered on both App IDs in the developer portal**, and
  the app signed with the real team, before the widget reads shared data on a
  device. Simulator builds don't validate this.
- `Tilipaiva.xcodeproj/xcuserdata/...` is still tracked despite `.gitignore`;
  `git rm --cached -r Tilipaiva.xcodeproj/xcuserdata` would finish the cleanup.
- App Store Connect submission, screenshots, and final icon art are manual.
- The app icon artwork is a deliberate placeholder; a designer pass is welcome.
