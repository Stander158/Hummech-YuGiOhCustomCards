# Aerol-8 / "mech" — custom card set for EDOPro

22 custom cards for **Project Ignis: EDOPro**. A Level 1 / Rank 1 / Link 1 WIND
Insect–Winged Beast–Machine engine that locks itself into tier-1 monsters in
exchange for a very dense opponent-turn game.

These are unofficial fan-made cards. They only exist on machines that install
them — **both players in a duel need this package installed**, or the duel will
desync.

---

## 1. Install

You need EDOPro already installed. Find your EDOPro folder:

| Platform | Typical location |
| --- | --- |
| macOS | `/Applications/ProjectIgnis/` |
| Windows | `C:\ProjectIgnis\` (wherever you extracted it) |
| Linux | `~/ProjectIgnis/` |

It's the folder containing `expansions/`, `deck/`, `script/`, and `config/`.

**Copy the two folders from this package into it, merging with what's there:**

```
expansions/custom-cards.cdb          →  <EDOPro>/expansions/custom-cards.cdb
expansions/strings.conf              →  <EDOPro>/expansions/strings.conf
expansions/script/*.lua              →  <EDOPro>/expansions/script/
expansions/pics/*.png                →  <EDOPro>/expansions/pics/
expansions/pics/field/*.png          →  <EDOPro>/expansions/pics/field/
deck/Aerol-8 mech.ydk                →  <EDOPro>/deck/
```

Nothing here overwrites an EDOPro file — `custom-cards.cdb` is a new database
and every script and image has a new filename.

> **One caution:** if you already have `expansions/strings.conf` from another
> custom set, do **not** replace it. Open both and append the `!setname` lines
> from this one to the end of yours. That file is a shared list; overwriting it
> will break the other set's archetype names.

Then start EDOPro. The database and images are read at launch, so if it was
already running, restart it.

## 2. Turn on custom cards — required

These cards are registered in the **Custom** card scope, so they show a
**CSTM** label under the card image and are deliberately not treated as real
OCG/TCG cards. That means they are hidden until you opt in:

1. In the **Deck Editor**, tick **"Alternate formats"**.
2. When creating or joining a duel, set **Allowed cards** to a setting that
   permits custom cards.

Miss step 1 and the cards simply won't appear in any search — the most common
"it didn't install" report is actually this.

### Check it worked

1. Deck Editor → tick **Alternate formats** → search `Hummech`. Seven cards.
2. Load the deck **Aerol-8 mech** — 40 main, 9 extra, no red "unknown card"
   entries.

If a card's archetype shows as `0xa51` instead of `Hummech`, `strings.conf`
didn't land in `expansions/`.

### About the artwork

**The art is placeholder.** Instead of an illustration, each card's artwork
window shows the card's own name on a coloured tile — intentional, not a broken
install. The tiles encode two things:

| Background gradient | Card category |
| --- | --- |
| amber → brown | main-deck monster |
| indigo → violet | Extra Deck monster |
| teal → green | Spell |
| magenta → plum | Trap |

The **text colour** tells you the archetype: Hummech gold, Dragonflymech aqua,
Butterflymech pink, Mothmech lavender, Ultimech coral, Aerol white.

Names, stats, and effect text are all real and fully rendered — only the
illustration is a placeholder. (The Slot column in the card list below is just
a reading aid for this manual; it isn't printed on the cards.)

## 3. Card list

Passcodes run `900000101`–`900000603`. That range was checked against every
database EDOPro ships and is unused, so nothing here collides with a real card.

| Slot | Passcode | Card | Archetype | |
| --- | --- | --- | --- | --- |
| M1 | 900000101 | Hummech Communicator "Phorgia" | Hummech | Level 1 / 300 / 600 |
| M2 | 900000102 | Hummech Dasher "Techneas" | Hummech | Level 1 / 100 / 200 |
| M3 | 900000103 | Hummech Interrupter "Ryea" | Hummech | Level 1 / 200 / 400 |
| M4 | 900000105 | Hummech Sabotager "Telethia" | Hummech | Level 1 / 0 / 0 |
| M5 | 900000201 | Dragonflymech Rescuer | Dragonflymech | Level 1 / 600 / 300 |
| M6 | 900000202 | Dragonflymech Immobilizer | Dragonflymech | Level 1 / 800 / 400 |
| M7 | 900000302 | Butterflymech Traveller "Ayers" | Butterflymech | Level 1 / 300 / 600 |
| M8 | 900000401 | Mothmech Disrupter "Ein" | Mothmech | Level 1 / 0 / 0 |
| M9 | 900000501 | Ultimech Locator "AI-ers" | Ultimech | Level 1 / 0 / 0 |
| M10 | 900000502 | Ultimech Dasher "Techtoneas" | Ultimech | Level 1 / 100 / 200 |
| M11 | 900000503 | Ultimech Interrupter "Rheanita" | Ultimech | Level 1 / 300 / 600 |
| E1 | 900000104 | Hummech House | Hummech | Xyz · Rank 1 / 1000 / 2000 |
| E2 | 900000203 | Dragonflymech Carrier | Dragonflymech | Fusion · Level 1 / 2000 / 1000 |
| E3 | 900000301 | Butterflymech Beacon | Butterflymech | Link-1 ▼ / ATK 0 |
| S1 | 900000106 | Hummech Relaxation | Hummech | Normal Spell |
| S2 | 900000205 | Dragonflymech Attachment | Dragonflymech | Equip Spell |
| S3 | 900000601 | Bionic Lab Aerol-8 | Aerol | Field Spell |
| S4 | 900000602 | Ultimech Lab Aerol-8 | Ultimech | Field Spell |
| T1 | 900000107 | Hummech Restore | Hummech | Normal Trap |
| T2 | 900000204 | Dragonflymech Assault | Dragonflymech | Counter Trap |
| T3 | 900000303 | Butterflymech Voyage | Butterflymech | Continuous Trap |
| T4 | 900000603 | Aerol-8 Accel | Aerol | Trap (activatable from hand) |

**"mech"** is a real archetype here, covering all five families, and **"Aerol"**
covers the three Aerol cards. Both are searchable in the deck editor.

## 4. How the deck actually works

Three ideas carry the whole set.

**Everything is Level 1 / Rank 1 / Link 1**, and most cards lock you into that
after use. The lock is a cost, not a drawback — it's what the payoffs are priced
against.

**Type-granting is the engine.** Techneas and Rescuer don't do much themselves.
Used as **material**, they grant the summoned WIND monster a lingering effect:

- **Techneas** → your Level 1/Rank 1/Link 1 **Machines** are also **Winged Beast**
- **Rescuer** → your Level 1/Rank 1/Link 1 **Machines** are also **Insect**
- **Techtoneas** → an Xyz monster made with it is also **both** Winged Beast
  and Machine

Hummech House and Dragonflymech Carrier are Machines whose effects fire **once
per Type they currently have**. Build House with Techneas and Rescuer among the
materials and it is Machine + Winged Beast + Insect — all three bullets resolve.

These granted effects are switched off while the monster's effects are negated,
and come back when the negation ends.

**The field spells buy opponent-turn access.** Bionic Lab Aerol-8 turns your
Hummech / Dragonflymech / Butterflymech monster effects into **Quick Effects**,
so hand cards like Phorgia and Ryea become interruption. It shuffles itself away
in the End Phase, so the real trick is putting it down *late* — Relaxation,
Restore, and Ayers all activate it from Deck or GY during an End Phase, so it
survives into your opponent's turn.

### A line worth trying first

Confirms most of the engine in one go:

1. Opponent's Main Phase, they control 3+ more cards than you → reveal **Ayers**
2. Ayers' second effect → activate **Bionic Lab Aerol-8** from hand or Deck,
   then Special Summon Ayers
3. Bionic Lab sees that Summon → Link Summon **Beacon** using Ayers
4. Beacon came out of the Extra Deck on your opponent's turn → its search fires

### And the type-granting one

1. Special Summon **Techneas** from hand
2. Link Summon **Beacon** with it
3. Beacon should now read **Machine / Winged Beast**

## 5. Known limitations

Please report anything odd, but these are already known:

- **Artwork is placeholder** — see section 2.
- **Bionic Lab's "Fusion" Summon option is not implemented.** Its text says
  *Fusion/Xyz/Link Summon*; only Xyz and Link are wired up.
- **Aerol-8 Accel's Quick Effect clause currently does nothing.** It grants
  Quick speed to Level 1/Rank 1/Link 1 "mech" monsters *you control*, and every
  activated effect in the set is used from the hand. That is deliberate
  groundwork for later cards, not a bug.
- Lightly tested: Butterflymech Voyage's "cannot be responded to" clause,
  Telethia's draw lock, and Immobilizer's damage-step ATK gain.

## 6. Playing against each other

> **Custom cards do not work on the public Project Ignis servers.**

If you pick a room from the official server list, that server validates every
deck against **its own** card database — which will never contain these cards.
You get:

```
"Butterflymech … [9000003xx]" cannot be identified by the host.
```

That message is EDOPro telling you the *host* has no such passcode. Your own
client is fine; it printed the card's name, so it clearly knows the card.

**Use a direct connection instead.** One of you hosts on your own machine (the
default port is `7911`) and the other joins by address. Now the host is a real
EDOPro client with the cards installed, and validation passes.

| Situation | What you need |
| --- | --- |
| Same house / Wi-Fi | Nothing. Host, and the other joins your local `192.168.x.x` on port 7911 |
| Different locations, router access | Port-forward TCP **7911** to the host, join on the host's public IP |
| Different locations, no router access or CGNAT | Virtual LAN software |

For virtual LAN, **Tailscale** is the easiest (works through CGNAT), with
**ZeroTier** and **Radmin VPN** as alternatives. Hamachi works but its free tier
caps at 5 devices. Any of them gives the host an address to type into EDOPro's
join field.

Both players still need the package. Custom cards are not transmitted; each
client simulates the duel locally, so a missing card on either side breaks the
game even if the deck check is bypassed.

As a last resort the host can tick **"Don't check Deck contents"** when creating
the room. That only silences the validation; it does not give the host the
cards, so do this only if you are certain both installs are complete.

## 7. Troubleshooting

**Cards don't appear in the deck editor.**
First check **Alternate formats** is ticked (section 2) — that's the usual
cause. Otherwise `custom-cards.cdb` must sit directly in `expansions/`, not in
a subfolder, and EDOPro must be restarted.

**A card is in the editor but does nothing in a duel.**
Its script is missing or misplaced. Every `c9000xxxxx.lua` must be in
`expansions/script/`, and `aerol8_common.lua` must be there too — every card
loads it, so without it none of them work.

**Archetype names show as hex.**
`strings.conf` is missing from `expansions/`.

**Cards show a blank frame instead of a coloured tile.**
The images didn't land. They belong in `expansions/pics/`, with the two field
images in `expansions/pics/field/`.

**"… cannot be identified by the host."**
The host's client has no such passcode. Either you are on a public server
(see section 6 — custom cards can't work there), or the host's install is
incomplete. Have the host search `Hummech` in their own deck editor with
Alternate formats on: if nothing appears, their install is the problem.

**Duel desyncs or your opponent sees blank cards.**
They don't have the package installed. Both players need it.

**A card is greyed out in the deck editor.**
The duel's *Allowed cards* setting doesn't permit custom cards — see section 2.

## 8. Uninstall

Delete these, and nothing else:

- `expansions/custom-cards.cdb`
- `expansions/script/aerol8_common.lua` and `expansions/script/c9000*.lua`
- `expansions/pics/9000*.png` and `expansions/pics/field/9000*.png`
- `deck/Aerol-8 mech.ydk`
- the `!setname 0xa50`–`0xa56` lines from `expansions/strings.conf`
  (delete the whole file only if this set put it there)
