# Aerol-8 / "mech" — custom cards for EDOPro

22 custom Yu-Gi-Oh! cards for **Project Ignis: EDOPro**: a Level 1 / Rank 1 /
Link 1 WIND Insect–Winged Beast–Machine engine that locks itself into tier-1
monsters in exchange for a very dense opponent-turn game.

Five families — **Hummech**, **Dragonflymech**, **Butterflymech**, **Mothmech**
and **Ultimech** — under the shared `"mech"` archetype, plus the `"Aerol"` Field
Spells they revolve around.

> **Both players need these cards installed.** Custom cards are not transmitted
> during a duel; each client simulates locally, so a missing card on either side
> breaks the game.

---

## Install — auto-updating (recommended)

Add this repository to EDOPro and it will pull updates on every launch.

Open `config/user_configs.json` in your EDOPro folder and put this inside the
`"repos"` array:

```json
{
  "url": "https://github.com/Stander158/Aerol8-CustomCards",
  "repo_name": "Aerol-8 / mech custom set",
  "repo_path": "./repositories/aerol8",
  "data_path": "",
  "script_path": "script",
  "pics_path": "pics",
  "should_update": true,
  "should_read": true
}
```

So the file looks like:

```json
{
	"repos": [
		{ "url": "https://github.com/Stander158/Aerol8-CustomCards", "repo_name": "Aerol-8 / mech custom set", "repo_path": "./repositories/aerol8", "data_path": "", "script_path": "script", "pics_path": "pics", "should_update": true, "should_read": true }
	],
	"urls": [],
	"servers": []
}
```

Restart EDOPro. It clones into `repositories/aerol8` and stays current from then
on — no re-downloading when cards change.

## Install — manual

Download the repository as a ZIP and copy into your EDOPro folder:

| From the ZIP | To |
| --- | --- |
| `custom-cards.cdb` | `expansions/custom-cards.cdb` |
| `strings.conf` | `expansions/strings.conf` |
| `script/*.lua` | `expansions/script/` |
| `pics/*.png` | `expansions/pics/` |
| `pics/field/*.png` | `expansions/pics/field/` |
| `deck/Aerol-8 mech.ydk` | `deck/` |

> If you already have `expansions/strings.conf` from another custom set, **do
> not overwrite it** — append the `!setname` lines from this one instead. That
> file is shared between sets.

## Turn on custom cards — required either way

These are registered in the **Custom** card scope (they show a `CSTM` label and
are deliberately not treated as real OCG/TCG cards), so they stay hidden until
you opt in:

1. In the **Deck Editor**, tick **"Alternate formats"**.
2. In duel settings, set **Allowed cards** to a setting that permits custom cards.

Missing step 1 is the usual reason someone thinks the install failed — searches
simply return nothing.

## Playing online

**Custom cards do not work on the public Project Ignis servers.** Those validate
decks against their own database and will report

```
"…" cannot be identified by the host.
```

Use a direct connection instead: one player hosts (default port **7911**), the
other joins on their address. Same network works as-is; across the internet,
either forward TCP 7911 or put both machines on a private network with
Tailscale, ZeroTier or Radmin VPN.

## Cards

Passcodes `900000101`–`900000603`, a range checked against every database EDOPro
ships and confirmed unused.

| Passcode | Card | | |
| --- | --- | --- | --- |
| 900000101 | Hummech Communicator "Phorgia" | Hummech | Level 1 / 300 / 600 |
| 900000102 | Hummech Dasher "Techneas" | Hummech | Level 1 / 100 / 200 |
| 900000103 | Hummech Interrupter "Ryea" | Hummech | Level 1 / 200 / 400 |
| 900000104 | Hummech House | Hummech | Xyz · Rank 1 / 1000 / 2000 |
| 900000105 | Hummech Sabotager "Telethia" | Hummech | Level 1 / 0 / 0 |
| 900000106 | Hummech Relaxation | Hummech | Normal Spell |
| 900000107 | Hummech Restore | Hummech | Normal Trap |
| 900000201 | Dragonflymech Rescuer | Dragonflymech | Level 1 / 600 / 300 |
| 900000202 | Dragonflymech Immobilizer | Dragonflymech | Level 1 / 800 / 400 |
| 900000203 | Dragonflymech Carrier | Dragonflymech | Fusion · Level 1 / 2000 / 1000 |
| 900000204 | Dragonflymech Assault | Dragonflymech | Counter Trap |
| 900000205 | Dragonflymech Attachment | Dragonflymech | Equip Spell |
| 900000301 | Butterflymech Beacon | Butterflymech | Link-1 ▼ / ATK 0 |
| 900000302 | Butterflymech Traveller "Ayers" | Butterflymech | Level 1 / 300 / 600 |
| 900000303 | Butterflymech Voyage | Butterflymech | Continuous Trap |
| 900000401 | Mothmech Disrupter "Ein" | Mothmech | Level 1 / 0 / 0 |
| 900000501 | Ultimech Locator "AI-ers" | Ultimech | Level 1 / 0 / 0 |
| 900000502 | Ultimech Dasher "Techtoneas" | Ultimech | Level 1 / 100 / 200 |
| 900000503 | Ultimech Interrupter "Rheanita" | Ultimech | Level 1 / 300 / 600 |
| 900000601 | Bionic Lab Aerol-8 | Aerol | Field Spell |
| 900000602 | Ultimech Lab Aerol-8 | Ultimech | Field Spell |
| 900000603 | Aerol-8 Accel | Aerol | Trap (activatable from hand) |

A ready-made 40+9 deck is included at `deck/Aerol-8 mech.ydk`.

See [MANUAL.md](MANUAL.md) for how the deck plays, sample combo lines,
troubleshooting and known limitations.

## Artwork

Placeholder. Each card shows its own name on a tile coloured by archetype, over
a gradient keyed to its category (monster / Extra Deck / Spell / Trap). Names,
stats and effect text are all fully rendered — only the illustration is a stand-in.

## Credits

Cards designed and scripted by **Stander158**.

Card frames, attribute icons, level and rank pips, link arrows, Spell/Trap
subtype icons and the card fonts come from
[linziyou0601/yugioh-card-maker](https://github.com/linziyou0601/yugioh-card-maker),
MIT licensed, © 2021 林子佑.

Yu-Gi-Oh! is © Konami. These are unofficial fan-made cards, for private play
only.
