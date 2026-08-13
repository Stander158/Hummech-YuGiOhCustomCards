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

Edit `config/user_configs.json` in your EDOPro folder — use that file rather
than `configs.json`, so an official EDOPro update can't overwrite your entry.
If the whole file is new, this is all it needs:

```json
{
	"repos": [
		{
			"url": "https://github.com/Stander158/Hummech-YuGiOhCustomCards",
			"repo_name": "Hummech custom cards",
			"repo_path": "./repositories/hummech",
			"should_update": true,
			"should_read": true
		}
	]
}
```

**If you already have entries in `"repos"`** (from another custom set), add just
the object above alongside them — and remember the comma between entries:

```json
{
	"repos": [
		{ ... someone else's set ... },
		{
			"url": "https://github.com/Stander158/Hummech-YuGiOhCustomCards",
			"repo_name": "Hummech custom cards",
			"repo_path": "./repositories/hummech",
			"should_update": true,
			"should_read": true
		}
	]
}
```

The layout here matches what EDOPro expects by default — database at the root,
scripts in `script/`, images in `pics/` — so no path settings are needed.

Restart EDOPro, then check the **Repositories** button at the top left: the
progress bar for *Hummech custom cards* should reach 100%. If it stalls, the
problem is almost always the JSON — a missing comma, or the file in the wrong
folder.

From then on it updates itself on every launch. Nothing to re-download when
cards change.

## Install — manual

Green **Code** button → **Download ZIP**, then extract it straight into

```
.../ProjectIgnis/expansions/
```

The folder layout here is already the `expansions/` layout, so the database,
`script/` and `pics/` all land where they belong.

Two things to watch:

- **`deck/Aerol-8 mech.ydk` is the exception** — move it to `ProjectIgnis/deck/`,
  not `expansions/deck/`, or the deck list won't show it.
- **If `expansions/strings.conf` already exists** from another custom set, do
  **not** overwrite it. Open both and append the `!setname` lines from this one.
  That file is shared between sets.

You'll need to repeat this each time the cards change, which is why Method 1 is
worth the one-time setup.

## Turn on custom cards — required either way

These are registered in the **Custom** card scope — they show a `CSTM` label and
are deliberately not treated as real OCG/TCG cards — so they stay hidden until
you opt in, in two separate places:

1. **Deck Editor:** tick the **Alternate formats** checkbox, or searches return
   nothing at all. This is the usual reason someone thinks the install failed.
2. **Duel setup:** set **Allowed cards** to **Anything goes**. Custom cards
   aren't legal in any other format, so nothing else will let them through.

## Playing

**Against the AI** — main menu → **LAN + AI** → **Host**, set *Allowed cards* to
*Anything goes*, and add a bot. The AI can't pilot this deck (there's no
executor for it), but it's a fine punching bag for testing your own cards.

**Against a person** — the same *Anything goes* setting applies, plus:

> **Custom cards do not work on the public Project Ignis servers.** Those
> validate decks against their own database and will report
> `"…" cannot be identified by the host.`

So use a direct connection: one player hosts (default port **7911**), the other
joins on their address. Options:

- Same house — just use the host's local `192.168.x.x`.
- Port-forward TCP **7911** to the host and use their public IP.
- Or put both machines on a private network with **Tailscale**, **ZeroTier** or
  **Radmin VPN**, then join on the address it hands out. No port forwarding.

Both players need the card database to see what the cards are, and the **host**
needs the scripts for the effects to run — simplest is for both to install the
whole set.

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
