# Meddelandesyntax — adv3LiteSwe

Meddelanden i adv3Lite skrivs som strängar med `{parametrar}` som expanderas
automatiskt beroende på kontext. Parametrarna hanterar saker som tempus,
genuskongruens och vilket objekt som avses.

```tads
Msg(already open, '{Ref subj dobj} {är} redan öpp{en/et/na}.')
// → "Dörren är redan öppen."   (utrum singular)
// → "Skåpet är redan öppet."   (neutrum singular)
// → "Dörrarna är redan öppna." (plural)
```

Stor begynnelsebokstav ges av att parameterns nyckelord skrivs med versal:
`{Ref ...}` → stor bokstav, `{ref ...}` → liten.

---

## Tempus

`Narrator.tense` styr vilket tempus som används. Möjliga värden:

| Konstant | Betydelse |
|---|---|
| `Present` | presens (standard) |
| `Past` | preteritum |
| `Perfect` | perfekt |
| `PastPerfect` | pluskvamperfekt |
| `Future` | futurum |
| `FuturePerfect` | futurum exaktum |

### Explicit tense-switch i strängen

Skriv `{presensform\|preteritumform}` för att byta form per tempus utan
ett fullständigt konjugeringmönster — praktiskt för oregelbundna verb:

```
'{jag} {tar|tog} {1}.'
// presens:    "Jag tar nyckeln."
// preteritum: "Jag tog nyckeln."
```

---

## Subjekt och objektreferenser

Dessa parametrar producerar rätt namnform för ett objekt och sätter
det som grammatiskt subjekt eller objekt för efterföljande verb.

*Med **karaktär** avses det Actor-objekt som utför handlingen — spelaren (PC) eller en NPC.*

| Parameter | Beskrivning | Exempel |
|---|---|---|
| `{jag}` / `{du}` | Karaktärens namn, subjektsform | `"Jag"` / `"Du"` |
| `{vi}` | Karaktärens namn, subjektsform (vi-form) | `"Vi"` |
| `{mig}` / `{dig}` / `{sig}` | Karaktärens namn, objektsform | `"mig"` / `"dig"` |
| `{oss}` | Karaktärens namn, objektsform (vi-form) | `"oss"` |
| `{ref subj dobj}` | Bestämd form av dobj, subjektsroll | `"Dörren"` |
| `{Ref subj dobj}` | Som ovan, stor begynnelsebokstav | `"Dörren"` |
| `{ref dobj}` | Bestämd form av dobj, objektsroll | `"dörren"` |
| `{ref dobjs}` | Possessiv form av dobj | `"dörrens"` |
| `{ett subj dobj}` | Obestämd form, subjektsroll | `"en dörr"` / `"ett skåp"` |
| `{en subj dobj}` | Obestämd form, subjektsroll | som `{ett ...}` |
| `{obj obj}` | Objektsform av givet objekt | |

Rollnamn som kan användas: `dobj`, `iobj`, `actor`, eller ett
argumentnummer som `1`, `2`, `3`.

```tads
Msg(too heavy, '{Ref subj dobj} {är} för tung{t/a} för {mig} att bära.')
// → "Äpplet är för tungt för mig att bära."
```

---

## Possessiv

### {poss ägare ägt} — kongruent possessiv
Väljer rätt possessivform baserat på det ägda objektets genus och antal.
Fungerar korrekt för alla personer (min/mitt/mina, din/ditt/dina, hans/hennes/dess/deras).

```
'{poss actor dobj}'
// actor = spelare (person 2):  "din" / "ditt" / "dina"
// actor = Bob (isHim):          "hans"
```

`ägare` och `ägt` kan vara rollnamn (`actor`, `dobj`) eller argumentindex (`1`, `2`).

```tads
Msg(report take, '{jag} {tar|tog} {poss actor 1}.')
// "Jag tar din korg." / "Jag tar ditt äpple." / "Jag tar dina skor."
```

### {min}, {vår}, {våran} — karaktärens possessiv
Returnerar karaktärens possessiva adjektiv utan kongruens med det ägda objektet.
Använd `{poss}` när genus eller antal på det ägda objektet varierar.

| Parameter | Beskrivning | Exempel (spelare = du) |
|---|---|---|
| `{min}` | Possessivt adjektiv, karaktären | `"din"` |
| `{vår}` / `{våran}` | Possessivt adjektiv, karaktären (vi-form) | `"vår"` |

### {hans obj}, {hennes obj}, {dess obj}, {deras obj}
Returnerar ägaren `obj`:s possessiva adjektiv. Kongruerar med ägarens genus
(han→"hans", hon→"hennes", det→"dess", de→"deras") men inte med det ägda
objektets genus eller antal — använd `{poss}` när det ägda objektet varierar.

---

## Pronomen

| Parameter | Beskrivning | Exempel |
|---|---|---|
| `{han obj}` | Subjektspronomen | `"han"` / `"hon"` / `"den"` / `"det"` / `"de"` |
| `{Hon obj}` | Som ovan, stor bokstav | `"Han"` / `"Hon"` / `"Den"` |
| `{de obj}` | Synonym till `{han obj}` — naturligare vid pluralreferens | `"de"` / `"han"` / `"hon"` / `"den"` / `"det"` |
| `{honom obj}` | Objektspronomen | `"honom"` / `"henne"` / `"den"` / `"det"` / `"dem"` |
| `{dem obj}` | Synonym till `{honom obj}` — naturligare vid pluralreferens | `"dem"` / `"honom"` / `"henne"` / `"den"` / `"det"` |
| `{sigsjälv obj}` | Reflexivt objektspronomen | `"sig själv"` / `"dig själv"` |
| `{själv obj}` | Reflexivt subjektspronomen | `"sig"` / `"dig"` |

---

## Adjektivkongruens

Skriv adjektivroten direkt följd av böjningsmönstret inom klamrar.
`langAdjust` identifierar roten automatiskt och väljer rätt ändelse
baserat på direktobjektets genus och antal.

| Mönster | Utrum | Neutrum | Plural | Typiska adjektiv |
|---|---|---|---|---|
| `rot{t/a}` | rot | rot+t | rot+a | tung/tungt/tunga, stor/stort/stora |
| `rot{a}` | rot | rot | rot+a | låst/låst/låsta |
| `rot{d/t/a}` | rot+d | rot+t | rot+a | |
| `rot{d/t/da}` | rot+d | rot+t | rot+da | tänd/tänt/tända |
| `rot{en/et/na}` | rot+en | rot+et | rot+na | öppen/öppet/öppna, skriven/skrivet/skrivna |
| `rot{n/t/na}` | rot+n | rot+t | rot+na | sann/sant/sanna |
| `rot{d/t/de}` | rot+d | rot+t | rot+de | laddad/laddat/laddade |

```tads
Msg(already open,   '{Ref subj dobj} {är} redan öpp{en/et/na}.')
Msg(already lit,    '{Ref subj dobj} {är} redan tän{d/t/da}.')
Msg(too heavy,      '{Ref subj dobj} {är} för tung{t/a} för {mig} att bära.')
Msg(not important,  '{Ref subj dobj} {är} inte viktig{t/a}.')
```

### Adjektivkongruens mot godtyckligt objekt

Standardmönstret `rot{mönster}` kongruerar alltid med `dobj`. När adjektivet
ska kongruera med ett annat objekt finns två alternativ:

**`conjAdjObj(obj, stam, mönster)`** — funktionsanrop, används i vanlig TADS-kod:

```tads
// I en dubbelciterad sträng, t.ex. i showListPrefix:
" (<<container.objInPrep>> <<conjAdjObj(container, 'vilk', 'en/et/a')>> {är} ";
// container = lådan (utrum):    "(i lådan, vilken är"
// container = skåpet (neutrum): "(i skåpet, vilket är"
// container = skorna (plural):  "(i skorna, vilka är"
```

**`{curobj obj}`** — parameterform, används i meddelandesträngar när man vill
hålla sig inom `{...}`-syntaxen. Kräver `gMessageParams(obj)` innan strängen
och att kongruenstokenet skrivs ut explicit som `{conjadj stam mönster}`:

```tads
gMessageParams(container);
" (<<container.objInPrep>> {curobj container}{conjadj vilk en/et/a} {är} ";
```

`{curobj}` sätter kongruensobjektet tyst (skriver inte ut något) och påverkar
bara den pågående strängexpansionen.

---

## Verbkonjugering

### Fullständig konjugering — alla tempus

Skriv verbstammen följd av `{presens/preteritum/supinum}`.
`langAdjust` omvandlar detta till ett `{conj}`-token och
`conjugateSwedish` väljer rätt form baserat på `Narrator.tense`.

| Mönster | Grupp | Presens | Preteritum | Perfekt | Futurum | Exempelverb |
|---|---|---|---|---|---|---|
| `rot{r/de/t}` | 1 | +r | +de | har +t | ska rot | öppna, flytta, stänga |
| `stam{er/te/t}` | 2a | +er | +te | har +t | ska +a | trycka, låsa, köpa |
| `stam{er/de/t}` | 2b | +er | +de | har +t | ska +a | leva, välja |
| `stam{r/dde/tt}` | 3 | +r | +dde | har +tt | ska stam | bo, tro, sy |

> **Grupp 1 och 3:** roten används direkt som infinitiv (`öppna`, `bo`, `tro`).
> **Grupp 2:** infinitiv = stam + `a` (`trycka`, `leva`).
>
> `rot{r/de}` (utan `/t`) är ett alias för `rot{r/de/t}` och ger samma konjugering för alla tempus.

```tads
// Grupp 1
'{jag} öppna{r/de/t} dörren.'
// presens:        "Jag öppnar dörren."
// preteritum:     "Jag öppnade dörren."
// perfekt:        "Jag har öppnat dörren."
// pluskvamperfekt:"Jag hade öppnat dörren."
// futurum:        "Jag ska öppna dörren."
// futurum exakt:  "Jag ska ha öppnat dörren."

// Grupp 3
'{jag} bo{r/dde/tt} i tornet.'
// presens:    "Jag bor i tornet."
// preteritum: "Jag bodde i tornet."
// perfekt:    "Jag har bott i tornet."
// futurum:    "Jag ska bo i tornet."
```

### Enkel konjugering — presens/preteritum

För fall där du bara behöver presens och preteritum utan supinum:

| Parameter | Presens | Preteritum | Typiska verb |
|---|---|---|---|
| `stam{er/te}` | +er | +te | trycka, köpa, leka |
| `stam{er/e}` | +er | +e | tända, välja |

```tads
'Du tryck{er/te} på knappen.'
// presens:    "Du trycker på knappen."
// preteritum: "Du tryckte på knappen."
```

### Oregelbundna verb — explicit tense-switch

```
'{jag} {tar|tog} {1}.'           // ta/tog
'{jag} {går|gick} norrut.'        // gå/gick
'{jag} {ser|såg} {ref dobj}.'     // se/såg
'{jag} {lägger|lade} {1} {i 2}.'  // lägga/lade
```

---

## Hjälpverb

| Parameter | Presens | Preteritum | Notering |
|---|---|---|---|
| `{är}` | är | var | kongruerar med subjekt |
| `{var}` | var | hade varit | historisk dåtid i presensberättelse |
| `{är inte}` | är inte | var inte | |
| `{kan}` | kan | kunde | |
| `{kan inte}` | kan inte | kunde inte | |
| `{måste verb}` | måste | var tvungen att | verb = infinitiv |
| `{har inte}` | har inte | hade inte | |

```tads
'{Ref subj dobj} {kan inte} öppnas.'
// presens:    "Dörren kan inte öppnas."
// preteritum: "Dörren kunde inte öppnas."

'{jag} {måste öppna} dörren.'
// presens:    "Jag måste öppna dörren."
// preteritum: "Jag var tvungen att öppna dörren."
```

---

## Determinativer och demonstrativa

Alla dessa böjs automatiskt efter direktobjektets genus och antal.

| Parameter | Utrum | Neutrum | Plural |
|---|---|---|---|
| `{den}` / `{det}` / `{de}` | den | det | de |
| `{denna}` / `{detta}` / `{dessa}` | denna | detta | dessa |
| `{denhär}` / `{dethär}` / `{dehär}` | den här | det här | de här |

`{de}` utan argument är ett **bestämningsord** (determinativ) — det placeras
framför ett substantiv och väljer automatiskt rätt form (den/det/de) baserat
på dobj:s genus och numerus. `{den}`, `{det}` och `{de}` är synonyma; välj
den form som passar meningen du skriver:

```
'Varför vill du ha {den} {ref dobj}?'
// dobj = dörren (utrum):    "Varför vill du ha den dörren?"
// dobj = skåpet (neutrum):  "Varför vill du ha det skåpet?"
// dobj = skorna (plural):   "Varför vill du ha de skorna?"
```

OBS: Med argument — `{de obj}` — fungerar det i stället som ett fristående pronomen
utan substantiv efter sig, identiskt med `{han obj}`. Se pronomen-avsnittet ovan.

---

## Prepositioner och plats

| Parameter | Beskrivning | Exempel |
|---|---|---|
| `{i obj}` | Innehållspreposition + namn | `"i lådan"` / `"på bordet"` |
| `{inuti obj}` | Rörelsepreposition + namn | `"in i lådan"` / `"upp på bordet"` |
| `{utur obj}` | Utgångspreposition + namn | `"ut ur lådan"` / `"ner från bordet"` |
| `{platsprep obj}` | Enbart prepositionen | `"i"` / `"på"` / `"under"` |
| `{här}` | Platsadverb relativt PC | `"här"` (presens) / `"där"` (preteritum) |
| `{då}` | Tidsadverb | `"nu"` (presens) / `"då"` (preteritum) |
| `{nu}` | "Nu" i presens, tomt annars | `"nu"` / *(ingenting)* |

---

## Listor och argument

| Parameter | Beskrivning |
|---|---|
| `{1}` – `{9}` | Argumentet på position 1–9 (theName) |
| `{# N}` | Argument N stavat ut som ord (`"tre"`) |
| `{och N}` | Argument N som "och"-lista: `"x, y och z"` |
| `{eller N}` | Argument N som "eller"-lista: `"x, y eller z"` |

---

## Diverse

| Parameter | Beskrivning |
|---|---|
| `{lb}` | Bokstavlig `{` |
| `{rb}` | Bokstavlig `}` |
| `{bar}` | Bokstavlig `\|` |
| `{dummy}` / `{sing}` | Osynligt singular-subjekt för efterföljande verb |
| `{plural}` | Osynligt plural-subjekt för efterföljande verb |
| `{posture}` | Karaktärens hållningsbeskrivning (`"stående"`, `"sittande"` etc.) |
| `{actionliststr}` | Lista på genomförda handlingar |
