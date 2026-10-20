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

- Unit tests (Swift Testing) live in `TilipaivaTests/`. Keep them passing; don't
  track how many there are here.
- `CODE_SIGNING_ALLOWED=NO` avoids signing for simulator runs. Entitlements are
  not validated on an unsigned simulator build.
- To eyeball the UI: `xcrun simctl install <device> <app>` then `launch`, and
  screenshot with `xcrun simctl io <device> screenshot out.png`. The language and
  locale follow the device — the booted iPhone 18 Pro Max renders English, not
  Finnish — so pass `-AppleLanguages '(fi)' -AppleLocale fi_FI`, or `'(en)'`, when
  the language matters.
- Xcode 27 ships **no Simulator.app**, so nothing can be tapped from the command
  line: a screenshot is the only way to check a screen, and anything reachable
  only by tapping (Settings) has to be reviewed by hand.
- To seed payments for a screenshot, write the store the app reads and relaunch.
  The unsigned simulator build gets the App Group suite, and `defaults` has to
  run inside the simulator against its view of the path — writing the plist from
  the host is ignored by `cfprefsd`:
  ```sh
  APP=$(xcrun simctl get_app_container booted fi.ruupert.Tilipaiva data)
  HEX=$(xxd -p sources.json | tr -d '\n')
  xcrun simctl spawn booted defaults write \
    "/var/mobile/Containers/Data/Application/$(basename "$APP")/Library/Preferences/group.fi.ruupert.Tilipaiva" \
    paymentSources -data "$HEX"
  ```
  After the app has run, the group plist in the container and what `defaults read`
  reports inside the simulator can disagree — the app's own writes turned up in
  the plist, the seeded sources the other way round. Read both (`plutil -p` on the
  file, `defaults read` in the sim) before believing that a stored value is gone.
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
That list holds `AppIcon.icon`, `Assets.xcassets`, `ContentView.swift` and
`TilipaivaApp.swift`, so the app-only folders below are compiled into the widget
as well (it builds, but that is not the intent; the widget's object files show
it).

> **A folder added to that exception list by hand does not stay there.**
> `Notifications` was added when the reminder arrived and was gone again after
> the next build that touched a synchronized folder: Xcode 27 rewrites
> `project.pbxproj` from its own model, and an entry written into the file drops
> out. Add app-only code through Xcode if it has to be excluded, or accept that
> the widget compiles it — the widget's build log says which way it went.

Folders:

- `Tilipaiva/Payday/` — the domain engine (shared with the widget).
- `Tilipaiva/Shared/` — shared views, `Design` constants, `Localizable.xcstrings`.
  `CountdownDayView` lives here because both the app's hero and the Lock Screen
  circular widget draw the same number-over-unit label.
- `Tilipaiva/Home/`, `SourceEditor/`, `Settings/`, `Notifications/` — app-only UI
  and the local notification the app sends.
- `TilipaivaWidget/` — widget target.
- `TilipaivaTests/` — tests. `docs/` — GitHub Pages site (`tilipäivä.ruupert.fi`).
- `AppStore.md` — App Store metadata draft.

## Domain engine (`Tilipaiva/Payday/`)

- `BankingCalendar` — `isBankingDay`, `bankingDay(onOrBefore/onOrAfter:)`,
  `next/previousBankingDay`, `start/lastDay(of:)`, `first/lastBankingDay(of:)`,
  `lastWeekday(of:)`, `nthBankingDay(_:of:)`, `day(_:of:)`, `holidays(in:)`,
  `adding(days:to:)`, `dayCount(from:to:)`. Holidays are derived (fixed dates +
  Easter via `Easter.monthAndDay`); no yearly data.
- `PaymentRule` — Codable enum with a `type` discriminator; supports
  `fixedDayOfMonth` (with `shift` and `alsoShiftOnWeekdays`),
  `firstBankingDayOfMonth`, `lastBankingDayOfMonth`, `lastWeekdayOfMonth`,
  `nthBankingDayOfMonth`, `nthWeekdayOfMonth`, and `everyNthWeek` (an anchored
  series: `startingOn` plus whole multiples of `n` weeks, for pay every two,
  three or four weeks).
- `PaymentResolver` — resolves dates/occurrences; `dates(for:in:)` returns every
  date a rule has in a month (a monthly rule has at most one, a week-interval
  rule up to three), `date(for:in:)` the first of them,
  `upcoming(for:onOrAfter:limit:)` returns `[UpcomingPayment]` and
  `next(for:onOrAfter:)` returns one. It also looks backwards:
  `previousOccurrence(for:onOrBefore:)` and `cycle(endingAt:)`.
- `PaymentCycle` — one wait between two payments of a source (`previous` →
  `next`) and `fraction(on:)`, how much of it has passed in whole days.
- `Benefits.json` + `BenefitCatalog` — the 7 Tier-1 Kela benefits as data.
- `PaymentSource`, `PaymentOccurrence`, `UpcomingPayment`, `Month` (with `next`
  and `previous`), `Weekday`.
- `SharedDefaults` + `PaymentSourceStore` — sources persisted as JSON in the
  App Group `group.fi.ruupert.Tilipaiva` (suite fallback to `.standard`).
- App side: `PaymentSourcesModel` (`@Observable`, MainActor) owns sources and
  calls `WidgetCenter.shared.reloadAllTimelines()` on change.

Note: `PaymentSource` uses the synthesized Codable, so JSON must include `name`
(required); `benefitID` is optional. The name may be blank — a salary's name is
optional in the editor, and `title` shows the localized word for the kind
instead, resolved when it is shown so it follows the app's language rather than
the one the source was added in.

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
- Design constants live in `Shared/Design.swift` (`heroNumberSize`,
  `heroRingSize`, `ringLineWidth`). Respect Dynamic Type (`@ScaledMetric` for the
  hero number and its ring); icon-only buttons need text labels.
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
- **A new salary pays on the last banking day of the month**, the most common
  Finnish payday: `SourceEditorItem.create` starts as `lastBankingDayOfMonth`.
  That is also what "the last day of the month" resolves to in practice, because
  Finnish law requires an agreed payday that falls on a weekend, a public
  holiday, or any other non-banking day to be paid on the preceding banking day
  — which is why `RuleDraft.shift` defaults to `.previousBankingDay`.
  `PaymentRule`'s decoder still falls back to `.none` for stored sources that
  omit `shift`, so existing user data is untouched.
- **The picker no longer offers "Last weekday"** (`RuleDraft.Kind.selectable`
  leaves out `.lastWeekday`). The rule itself stays: `kotihoidontuki` takes it
  from `Benefits.json`, and a source saved earlier must still resolve and
  round-trip. `RuleEditorView` shows the current kind even when it is no longer
  on offer, so such a source still displays what it is.
- App Group id `group.fi.ruupert.Tilipaiva`; both `Tilipaiva.entitlements` and
  `TilipaivaWidget.entitlements` declare it.
- Widget families: `systemSmall`, `systemMedium`, `accessoryCircular`,
  `accessoryInline`, `accessoryRectangular`. The rectangular one
  (`RectangularCountdownView`: the payment's name over its countdown and date)
  was added early, removed, and brought back when the Lock Screen text widget was
  wanted — the note that removed it ("no Lock Screen widget occupies two circular
  slots") was about the layout being unfamiliar, not about it not existing.
- **Only the home screen widgets carry a background.** `WidgetBackground`, which
  `PaymentWidgetView` puts in `containerBackground`, draws `PaymentBackground()`
  for `systemSmall`/`systemMedium` and `Color.clear` for the three Lock Screen
  accessories, which sit on the wallpaper the way the system's own do.
- Home layout: hero countdown owns ~55% of the screen; the upcoming list is a
  light, secondary, dividered list below it. With no sources the empty state
  takes the whole area and centres itself in it instead of hanging off the top.
  The app is a two-tab `TabView` — **Home** (`house`) and **Settings**
  (`gearshape`). Tabs rather than a sheet because a bar pinned with
  `safeAreaInset` had no background and let the list scroll through it. The
  floating `+` belongs to the Home tab and stays top-right; it is the only
  chrome outside the tab bar.
  `PaymentBackground()` has to be applied **inside** the Home tab: a `TabView`
  draws over a background set on the `TabView` itself, and the screen goes flat
  black without it.
- **The hero's ring holds only the day count; the payment's name and date sit
  below it.** Stacking all four inside the ring read as a crammed list, so the
  ring answers "how long" and the two lines under it answer "what and when".
  `CountdownDayView` (shared with the Lock Screen circular widget) draws the
  number with its unit always stacked underneath. A phrase like "6 days" at hero
  size is wider than the ring, and putting the unit beside the number pushed the
  number off-centre — a trial of both is why the unit sits where it does now.
  The unit is the full word (`day`/`days` → "päivä"/"päivää"), not an
  abbreviation, and it is set in the rounded design to match the number. Only the
  circular widget shortens it — see below.
- **The hero's progress shows the wait between two payments**, not the calendar
  month: `PaymentCycle.previous` → `next`, always drawn as a ring. There was a
  style preference (a `bar` option first, then a switch between `ring` and
  `none`); both went, and the ring is the only option, so there is no
  `ProgressStyle` and nothing to store. A ring needs a wait to measure: when the
  source has no earlier payment to count from, the ring is left out and the
  countdown stands on its own. The ring is decoration and is hidden from
  assistive technologies. The Lock Screen's circular widget wears the same wait
  as a ring, and its own count inside — see below.
- **The Lock Screen accessories are the same content in three shapes.**
  `CountdownDayView.UnitStyle.short` is used in the circular one, because the
  Finnish "päivää" is wider than the circle it would sit in: the `day (short)` and
  `days (short)` keys are "pv" in Finnish and stay "day"/"days" in English. The
  full word overflows, and it has no `minimumScaleFactor` to shrink it; the hero
  keeps the full word, since its ring has the room.
  - The circular one (`accessoryCircular`) is the day count and its short unit
    inside the system's own progress ring: `CircularCountdownView` puts
    `CountdownDayView` in the `currentValueLabel` of a
    `Gauge(value:).gaugeStyle(.accessoryCircularCapacity)`, whose value is
    `PaymentCycle.fraction(on:)` for the entry's day. The ring is the system's
    rather than a drawn one because it is the ring the neighbouring Lock Screen
    widgets wear, so the countdown sits in their company; the hero keeps its own
    heavier `PaymentRing` at 12 pt, as its own look.
    - `.accessoryCircularCapacity` ignores the gauge's `label`, so the euro disc
      the App Icon wears does not appear here. It was tried inside the value slot
      beside the count and crowded the unit; the count is what the card is for.
      The same style leaves the number a step smaller than it was — `title3`
      instead of `title2` — because the ring takes the circle's edge.
    - Do not use plain `.accessoryCircular` for this: that style is a dial, not a
      ring — an arc open at the bottom with a dot for the value — and it draws its
      `label` into that opening, on top of the unit. It was rendered beside the
      capacity style in the simulator and read as a speedometer.
    - Without a cycle — a source with no earlier payment — there is no share to
      draw, so the count stands alone, as in the hero. The gauge needs a value,
      which is why the `fraction` is optional and the ring is the conditional part.
    - `PaymentEntry` carries the `PaymentCycle` for it, which the provider
      resolves alongside the next payment. For the record, the system's own
      accessory circular ring (the Weather widget's) measures 5.6 pt across a
      58 pt circle — measured by rendering
      `Gauge(value:).gaugeStyle(.accessoryCircularCapacity)` in the simulator and
      scanning the pixels.
  - The inline one (`accessoryInline`) is one line, "Palkka · 6 päivää", with the
    countdown last so that a long name gives way to it when the line truncates.
  - The rectangular one (`accessoryRectangular`) is two lines: the payment's name,
    and the countdown below it in the rounded design the hero's count uses. Both
    are a step below the sizes they wear elsewhere — `subheadline` for the name,
    `title2` for the count, rather than the hero's `headline` and 88 pt — because
    the card is meant to sit quietly on the Lock Screen. The date used to be there
    too, first beside the count — where the two of them competed for the line
    until the count, the one thing the card is for, was the part that gave way
    ("3 p… ti 20.10.") — and then on a line with the name, before being dropped as
    unnecessary. A `minimumScaleFactor(0.6)` stays behind the count.
- **A payday is celebrated once, when the app is first opened that day.** The hero
  already says "Today!", so the celebration only decorates it:
  `PaydayCelebrationView` drops euro signs and green flakes over the Home tab for
  about three and a half seconds, and `PaydayHaptics` adds a flourish — four taps
  that get firmer and tighter, landing on a thump with two faint sparks after it.
  That shape is why it is written out with Core Haptics: the system's own patterns
  are single events, and `.success` (two even taps) and a lone `.impact` both came
  and went as too flat for the moment. The engine and the pattern are built in
  `prepare()` before the tap is due, because a cold engine starts too slowly; if
  the engine will not start, the same four-tap rise is played with the impact
  generators, and the sparks are dropped there since a light impact is too dull to
  read as one. The tap waits a third of a second before it fires: feedback asked
  for while the launch transition is still running can be dropped, and the day is
  already marked as played, so a dropped tap would not come round again. Nothing
  is written in words, which is why the celebration needs no localization, and it
  is decoration, so assistive technologies skip it and it never takes a tap. The
  pieces come from a seeded generator (`ConfettiParticle.burst()`), so the burst
  scatters but is the same on every launch and a screenshot stays comparable with
  the last one; a euro sign only leans on the way down, since a tilted `eurosign`
  reads as a scrambled glyph. Under Reduce Motion the pieces do not fall — they
  fade in where they rest. `PaydayCelebration` remembers the day it last played in
  the shared defaults, so a second launch that day stays quiet, and the day it
  compares is the Finnish one, the same day the payment rules use. It is on by
  default, and its switch ("Celebrate a payday" under "Celebration") is the app's
  first real preference in Settings.
- **The celebration is triggered from `ContentView`, next to `scenePhase`**, and
  not from the hero: `.task` covers a launch, since `scenePhase` can already be
  `.active` on the first render and never change. Both paths ask the same gate,
  which marks the day as played before the animation starts, so the two cannot
  play it twice.
- **The one notification is local and pre-scheduled, not pushed.** There is no
  server and no account, so the reminder is a `UNCalendarNotificationTrigger`
  per payment day — delivered by the system even if the app never runs again.
  A repeating trigger cannot express a payday: banking-day shifting moves the
  date month to month. `PaydayReminderSchedule` (app-only, in
  `Notifications/`) is the pure part — sources and a date in, one
  `PaydayReminder` per payment day out, grouped with `ListFormatter` so two
  sources paying the same day are one banner ("Palkka ja elatustuki saapuvat
  tänään"); the unit tests cover it. `PaydayNotifications` is the thin part that
  owns `UNUserNotificationCenter`.
  - The reminder is scheduled **at 7 a.m. Finnish time** — early enough to
    greet the payment day rather than half of it — carried as components in
    `BankingCalendar.timeZone`, so it follows the payment day rather than the
    device's. A day whose Finnish morning has gone is left out.
  - `PaydayReminderSchedule.limit` is 20 days — iOS keeps at most 64 pending
    requests, so it is a sliding window rather than every date the rules can
    produce. `ContentView` reschedules on launch, on every return to the
    foreground and whenever the sources change; `PaydayNotifications` clears its
    own `payday.`-prefixed pending requests before adding the new ones.
  - The permission is asked **when the first source is saved**, not at launch:
    there is nothing to remind about before that. `PaydayNotifications` keeps
    the prompt and the switch in one place, so a refusal leaves the switch off
    and turns the Settings row into "Turn on in Settings". The preference key
    (`paydayRemindersEnabled`) means **off** when absent, unlike the
    celebration's.
  - No `UNUserNotificationCenterDelegate`: a notification arriving while the app
    is open is not presented, so the reminder never lands on top of the payday
    confetti.
- Brand accent is a "payday green" (light `#1F8A5A`, dark `#4FD1A0`); the App
  Icon is a gold coin with a cream € on it, centred at 1.5× over a gradient of
  that green (the `fill` and the `position` in `icon.json`), made with Icon
  Composer (`Tilipaiva/AppIcon.icon`). The source artwork is
  `Tilipaiva/AppIcon.icon/Assets/tilipaiva-kolikko.svg`, authored in Inkscape —
  edit and re-export from there, and keep `icon.json`'s `image-name` in sync with
  the asset file name. **The SVG must contain no `<text>` elements** (Icon
  Composer warns about font-dependent text): convert type with
  `Path → Object to Path` and save as **Inkscape SVG**. Saving as *Plain SVG*
  silently drops the layer
  and the icon renders as an empty background square.

## Docs site (GitHub Pages)

The repo is `rkoponen/tilipaiva` on GitHub, and `origin` tracks `main`, so the
site and the app ship from the same push.

`docs/` is published to GitHub Pages at **https://tilipäivä.ruupert.fi** with the
same setup as Viikkonumero: source `main` / `/docs`, legacy build, the custom
domain in `docs/CNAME`, HTTPS enforced.

The custom domain is an **IDN**: `tilipäivä.ruupert.fi` = punycode
`xn--tilipiv-9wac.ruupert.fi`. Both `docs/CNAME` and the Pages setting use the
punycode, and `AppStore.md` / `SettingsView.swift` use the readable Unicode form
(`URL(string:)` IDNA-encodes a Unicode host). The plain ASCII
`tilipaiva.ruupert.fi` is a **different name and has no DNS record** — don't use
it.

- **Publishing is just a push.** Any commit to `main` that touches `docs/`
  triggers a build; nothing else to run. A first auto-build can occasionally
  race and fail right after the Pages site is created — re-run it with
  `gh api -X POST repos/rkoponen/tilipaiva/pages/builds`.
- Enable/repair the site with the `gh` CLI:
  ```sh
  gh api -X POST repos/rkoponen/tilipaiva/pages \
    -f 'source[branch]=main' -f 'source[path]=/docs'
  gh api repos/rkoponen/tilipaiva/pages --jq '{status,cname,https_enforced}'
  ```
- **DNS lives in Cloudflare (zone `ruupert.fi`), set to DNS-only ("grey cloud"),
  not proxied** — proxying blocks GitHub's certificate issuance. Record:
  `CNAME xn--tilipiv-9wac -> rkoponen.github.io`. Viikkonumero uses the identical
  `CNAME viikkonumero -> rkoponen.github.io` (which resolves to GitHub's
  `185.199.x` IPs). Cloudflare is manual and needs an API token; there is no
  token/CLI on this machine.
- HTTPS is enforced (certificate approved). Re-apply Pages settings with a
  **typed boolean** — `-f` sends the string `"true"` and 422s:
  `gh api -X PUT repos/rkoponen/tilipaiva/pages -F https_enforced=true`.
  Certificate state shows up as `https_certificate` on the Pages API.

## Pending / manual

- **App Group must be registered on both App IDs in the developer portal**, and
  the app signed with the real team, before the widget reads shared data on a
  device. Simulator builds don't validate this.
- `Tilipaiva.xcodeproj/xcuserdata/...` is already ignored and untracked — nothing
  to clean up (done).
- App Store Connect submission, screenshots, and final icon art are manual.
- **The reminder has been seen working on a device.** The alert was answered,
  the switch in Settings came on with it, and a banner arrived on a payment day.
  The only path left untried is the refusal — the "Turn on in Settings" row that
  replaces the switch once the permission has been taken away again.
- **The Lock Screen widgets have only been seen as rendered images.** A widget
  cannot be added to the Lock Screen without tapping it in the Simulator, and
  Xcode 27 ships no Simulator.app, so the circular, inline and rectangular
  accessories all want a hand check on a device: what they *look* like there
  (vibrancy, the wallpaper, the user's tint) is not what a rendered PNG shows.
  The circular one's ring is the most interesting of the three to check, since it
  was chosen from a render in the app over `AccessoryWidgetBackground()` rather
  than on a wall — the shape is right, but the gauge's ring and the count inside
  it have not been seen in the Lock Screen's own rendering.
- **The celebration and its switch still want a hand check on a device.** The
  haptic tap does not play in the simulator and Settings cannot be tapped from the
  command line, so neither has been seen working. Two things are worth knowing
  when it cannot be felt on a device: the ring/silent switch does **not** suppress
  haptics (its "Play Haptics in Silent Mode" setting is about ring and alert
  vibration), while the system-wide Haptics switch under Settings → Sounds &
  Haptics does, and iPads and iPods have no Taptic Engine at all. The confetti
  itself is on screen for a few seconds, which is easy to miss when screenshotting
  a launch; the reliable way to photograph it is to raise `ConfettiParticle`'s
  `duration` for one build.
- The app icon art came from the designer as an Inkscape SVG; further artwork
  polish should come as a new SVG, not by editing `icon.json` geometry.
