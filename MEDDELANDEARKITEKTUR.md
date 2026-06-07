# Meddelandearkitektur — adv3LiteSwe

Hur `{parametrar}` i strängar faktiskt expanderas: pipelines, kontext,
subjektupplösning, adjektivkongruens och verbkonjugering.

> **Notation:** `[generellt]` = del av adv3Lite:s kärna (messages.t / advlite.h),
> fungerar likadant i den engelska versionen.
> `[svenska]` = definierat i swedish.t, specifikt för den svenska översättningen.

---

## Två distinkta pipelines `[generellt]`

Strängar med `{...}`-parametrar når expansionsmotorn via **två helt separata vägar**.
Det är avgörande att förstå skillnaden.

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PIPELINE A — Meddelandetabellen  (swe_messages.t / Msg(...))  [generellt]  │
│                                                                         │
│  Msg(already open, '{Ref subj dobj} {är} redan öpp{en/et/na}.')        │
│          │                                                              │
│          ▼                                                              │
│  1. langAdjust()    öpp{en/et/na} → {conjadj öpp en/et/na}  [svenska]  │
│                     öppna{r/de/t} → {conj öppna r/de/t}                │
│          │                                                              │
│          ▼                                                              │
│  2. Tvåpassexpansion  (prescan → endPreScan → expansion)                │
│          │                                                              │
│          ▼                                                              │
│  3. swedishMessageParams.expand(ctx, params)  för varje {token ...}    │
│     (engelska: EnglishMessageParams.expand — samma mekanism)  [generellt] │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│  PIPELINE B — Vanlig TADS-kod  (dubbelciterade strängar)  [generellt]  │
│                                                                         │
│  " (<<container.objInPrep>> {curobj container}{conjadj vilk en/et/a}) " │
│          │                                                              │
│          ▼                                                              │
│  langAdjust() körs INTE                                                 │
│          │                                                              │
│          ▼                                                              │
│  TADS VM:s inbyggda {}-hanterare anropar                                │
│  swedishMessageParams.expand(ctx, params)  för varje {token ...}       │
└─────────────────────────────────────────────────────────────────────────┘
```

**Konsekvens:** Kortformen `vilk{en/et/a}` och `öppna{r/de/t}` fungerar
**bara i Pipeline A**. I Pipeline B måste du skriva `{conjadj vilk en/et/a}`
och `{conj öppna r/de/t}` direkt, eftersom `langAdjust` inte körs.

---

## Meddelandekontexten (MessageCtx) `[generellt]`

En ny `MessageCtx` skapas för varje strängexpansion och lever bara så länge
expansionen pågår — efter att funktionen returnerat kastas objektet.
Det finns ingen global `ctx` som lever kvar mellan strängar eller actions.
Det innebär att det är helt säkert att sätta `ctx.curObj` (eller andra fält)
inifrån en parameterhanterare: läckage till nästa strängexpansion är omöjligt.

Det enda som är globalt i kedjan är `gAction.setMessageParams(...)` som
`gMessageParams` skriver till — men det är ett medvetet anrop och skrivs
ändå över vid nästa action.

Den håller all information som parameterhanterarna delar på under expansionen.

```
MessageCtx
├── cmd          → gCommand (Command-objektet för pågående handling)
│    ├── dobj   → direktobjektet
│    ├── iobj   → indirekt objekt
│    └── actor  → den agerande karaktären
├── args[]       → extra argument från Msg(..., arg1, arg2, ...)
├── subj         → grammatiskt subjekt (sätts av {jag}, {ref subj obj}, {dummy}, ...)
├── vobj         → grammatiskt objekt (sätts av {ref obj}, {obj obj}, ...)
├── curObj       → adjektivkongruensobjekt (sätts av {curobj obj})  [svenska]
├── gotVerb      → har vi sett ett verb i meningen? (för meningsordningslogik)
├── prescan      → sant under förstapasningen, nil under expansion
├── lastParam    → senaste paramvärdet (för {s}/{es}-logik)
└── reflexiveAnte[] → antecedentlista för reflexiva pronomen
```

### Subjektupplösningskedja

`adjustAdjectiveAgreement` `[svenska]` och verbkonjugeringen slår upp objektet i denna ordning:

```
Adjektivkongruens ({conjadj}):  [svenska]
  1. ctx.curObj       — sätts explicit med {curobj obj}
  2. ctx.cmd.dobj     — direktobjektet i pågående kommando
  3. ctx.actor        — den agerande karaktären

Verbkonjugering ({är}, {conj}, ...):  [svenska params, generell ctx.subj-logik]
  1. ctx.subj         — sätts av {jag}/{du}/{ref subj obj}/{dummy}/...
                        defaultar till dummy_ om inget setts
  2. ctx.subj.person  — 1/2/3 (avgör form i de få fall där person spelar roll)
  3. ctx.subj.plural  — för pluralkongruens
```

---

## Tvåpassexpansionen `[generellt]`

Varje mening expanderas i **två pass** för att hantera att subjektet ibland
kommer efter verbet i meningen.

```
Pass 1 — Prescan
  För varje {token ...} i meningen:
    expand(ctx, params)  ← körs men resultatet kastas
    Sidoeffekter lagras: ctx.subj sätts, ctx.gotVerb uppdateras, etc.

endPreScan()
  ctx.prescan = nil
  ctx.lastParam = nil
  ctx.reflexiveAnte töms

Pass 2 — Expansion
  För varje {token ...} i meningen (samma ordning):
    expand(ctx, params)  ← nu används resultatet
    Strängen byggs upp token för token
```

**Varför två pass?** Svenska (SVO) har subjektet före verbet, men
parameterhanteraren måste ändå veta om subjektet är pluralt *innan* den
expanderar verbet, även om subjektparametern råkar komma efter i strängen.

---

## langAdjust — förbearbetning (Pipeline A) `[svenska]`

`langAdjust` körs på strängen *innan* parameterexpansion i Pipeline A.
`messages.t` kallar alltid `langAdjust(txt)` — hookpunkten är generell, men
funktionens innehåll är helt och hållet definierat av språkmodulen.
Den letar efter mönstret `rot{mönster}` med regex och skriver om det:

```
Adjektivkongruens:
  öpp{en/et/na}   →  {conjadj öpp en/et/na}
  tung{t/a}       →  {conjadj tung t/a}
  ladda{d/t/de}   →  {conjadj ladda d/t/de}

Verbkonjugering:
  öppna{r/de/t}   →  {conj öppna r/de/t}
  tryck{er/te/t}  →  {conj tryck er/te/t}
  bo{r/dde/tt}    →  {conj bo r/dde/tt}
```

Igenkänningsregler:
- Adjektivmönster: `a` | `t/a` | `n/t/na` | `d/t/de` | `d/t/a` | `d/t/da` |
  `en/et/a` | `en/et/na`
- Verbmönster: `r/de` | `r/de/t` | `er/te/t` | `er/de/t` | `r/dde/tt`

Enkel presens/preteritum (`{er/te}`, `{er/e}`) hanteras **inte** av `langAdjust`
— de är direkta parameteruppslag.

---

## Adjektivkongruenspipelinen ({conjadj}) `[svenska]`

```
Steg 1 — langAdjust  (Pipeline A)
  öpp{en/et/na}  →  {conjadj öpp en/et/na}

Steg 2 — parameterexpansion
  token 'conjadj' → anropar adjustAdjectiveAgreement(ctx, ['conjadj','öpp','en/et/na'])

Steg 3 — adjustAdjectiveAgreement
  1. Hämta objekt:  ctx.curObj → ctx.cmd.dobj → ctx.actor
  2. Välj ändelse:
     obj.plural   → pluralform   (+na → "öppna")
     obj.isNeuter → neutrumform  (+et → "öppet")
     annars       → uterumform   (+en → "öppen")
  3. Returnera: rot + vald ändelse
```

### Mönsteröversikt

| Mönster | Utrum | Neutrum | Plural | Exempel |
|---|---|---|---|---|
| `a` | rot | rot | rot+a | låst/låst/låsta |
| `t/a` | rot | rot+t | rot+a | tung/tungt/tunga |
| `n/t/na` | rot+n | rot+t | rot+na | sann/sant/sanna |
| `d/t/a` | rot+d | rot+t | rot+a | |
| `d/t/da` | rot+d | rot+t | rot+da | tänd/tänt/tända |
| `d/t/de` | rot+d | rot+t | rot+de | laddad/laddat/laddade |
| `en/et/a` | rot+en | rot+et | rot+a | öppen/öppet/öppna |
| `en/et/na` | rot+en | rot+et | rot+na | skriven/skrivet/skrivna |
| `en/et/a` med rot `vilk` | vilken | vilket | vilka | ← specialfall |

---

## Verbkonjugeringspipelinen ({conj}) `[svenska]`

```
Steg 1 — langAdjust  (Pipeline A)
  öppna{r/de/t}  →  {conj öppna r/de/t}

Steg 2 — parameterexpansion
  token 'conj' → anropar conjugateSwedish(ctx, ['conj','öppna','r/de/t'])

Steg 3 — conjugateSwedish
  1. Läs Narrator.tense
  2. Välj form ur mönstret:
     r/de/t   →  presens: rot+r,    pret: rot+de,  perf: rot+t, inf: rot
     r/de     →  alias för r/de/t (identisk konjugering för alla tempus)
     er/te/t  →  presens: stam+er,  pret: stam+te, perf: stam+t, inf: stam+a
     er/de/t  →  presens: stam+er,  pret: stam+de, perf: stam+t, inf: stam+a
     r/dde/tt →  presens: stam+r,   pret: stam+dde, perf: stam+tt, inf: stam
  3. Futurum och perfekttider byggs upp runt vald form
```

### Konjugeringstabellen

| Tempus | r/de/t | er/te/t | er/de/t | r/dde/tt |
|---|---|---|---|---|
| Presens | öppnar | trycker | lever | bor |
| Preteritum | öppnade | tryckte | levde | bodde |
| Perfekt | har öppnat | har tryckt | har levt | har bott |
| Pluskvamperfekt | hade öppnat | hade tryckt | hade levt | hade bott |
| Futurum | ska öppna | ska trycka | ska leva | ska bo |
| Fut. exakt | ska ha öppnat | ska ha tryckt | ska ha levt | ska ha bott |

---

## Subjektets dummy-objekt `[generellt]`

Tre inbyggda dummyobjekt hanterar fall utan naturligt subjekt (definierade i
messages.t, gemensamma för alla språk):

| Param | Objekt | person | plural | Returnerar | Användning |
|---|---|---|---|---|---|
| `{dummy}` | `dummy_` | 3 | false | `''` | Singular "det/det" utan utskrivet subjekt |
| `{sing}` | `dummy_` | 3 | false | `''` | Synonym till `{dummy}` |
| `{plural}` | `pluralDummy_` | 3 | true | `''` | Plural utan utskrivet subjekt |

`{dummy}` och `{sing}` skiljer sig från `{plural}` enbart i `plural`-flaggan.
Alla returnerar tom sträng — de existerar enbart för sidoeffekten att sätta
`ctx.subj`.

```tads
// Utan dummy: oklart vad {är} ska kongruera med
'{dummy} {är} stängt.'
// → "är stängt."  (dummy skriver inte ut något)

// Funkar också i retur från en funktion:
return '{dummy} {är} ' + makeListStr(objList);
```

---

## Namngivna meddelandeparametrar (gMessageParams) `[generellt]`

`gMessageParams(obj)` registrerar ett objekt under sitt variabelnamn så att
`{ref subj container}` och liknande kan hitta det via strängen `"container"`.

```tads
// Makroutvidgning:
gMessageParams(container)
  → gAction.setMessageParams('container', container)

// Uppslagskedja i findStrParam('container', vObject):
  1. gAction.getMessageParam('container')  ← hittas här om satt ovan
  2. libGlobal.nameTable_['container']     ← alternativt om globalParamName sätts
  3. NounRole.all där r.name == 'container'
  4. Hittas inte → dummy_ med felnamn [container]
```

`gAction` måste existera. Under normal spelarkommandobearbetning finns det
alltid; i rent interna listers callback som `showListPrefix` finns det
också (det är den senaste handlingen).

### Rollnamn utan gMessageParams

Dessa fungerar alltid utan `gMessageParams` eftersom de slås upp direkt
i `cmd`-objektet:

| Namn | Källa |
|---|---|
| `dobj` | `ctx.cmd.dobj` |
| `iobj` | `ctx.cmd.iobj` |
| `actor` | `ctx.cmd.actor` |
| `1`–`9` | `ctx.args[n]` |

---

## {curobj} — sätt adjektivkongruensobjektet explicit `[svenska]`

Adderat i `swedishMessageParams.params`:

```tads
['curobj', function(ctx, params) {
    ctx.curObj = findStrParam(params[2], vObject);
    return '';
}],
```

Används när det objekt adjektiv ska kongruera med **varken** är `cmd.dobj`
eller `actor` — typexempel: `subLister.showListPrefix` där `container` är
listans platsbehållare, inte direktobjektet för spelkommandot.

```tads
showListPrefix(lst, pl, paraCnt)
{
    local container = lst[1].location;
    gMessageParams(container);
    " (<<container.objInPrep>> {curobj container}{conjadj vilk en/et/a} {är} ";
}
// container = lådan (utrum):   "(i lådan, vilken är"
// container = skåpet (neutrum): "(i skåpet, vilket är"
// container = skorna (plural):  "(i skorna, vilka är"
```

Utan `{curobj}` hade `{conjadj}` fallit tillbaka på `cmd.dobj`, vilket i
ett `Inventory`-kommando hade gett fel kongruens.

**Alternativet** — direktanrop till `adjustAdjectiveAgreement`:

```tads
function vilkenVilket(obj) {
    return adjustAdjectiveAgreement(object {curObj = obj}, ['conjadj', 'vilk', 'en/et/a']);
}

" (<<container.objInPrep>> <<vilkenVilket(container)>> {är} ";
```

Funktionen konstruerar ett syntetiskt ctx med `curObj = obj`, kringgår
parameterexpansionen helt och är idiomatisk för engångsfall utan
`gMessageParams`.

---

## Hela flödet — fullständigt exempel

```
Spelaren skriver: >ÖPPNA DÖRREN

gAction = OpenAction, gAction.dobj = dörren (utrum, singular)

Msg(already open, '{Ref subj dobj} {är} redan öpp{en/et/na}.')

Pipeline A:
  ┌─ langAdjust ───────────────────────────────────────────────┐
  │  '{Ref subj dobj} {är} redan öpp{en/et/na}.'              │
  │                   →                                        │
  │  '{Ref subj dobj} {är} redan {conjadj öpp en/et/na}.'     │
  └────────────────────────────────────────────────────────────┘

  ┌─ Ny MessageCtx ────────────────────────────────────────────┐
  │  cmd.dobj = dörren, subj = nil, curObj = nil               │
  └────────────────────────────────────────────────────────────┘

  ┌─ Pass 1 (prescan) ─────────────────────────────────────────┐
  │  {Ref subj dobj}:  ctx.subj = dörren  (sidoeffekt)        │
  │  {är}:             noterar ctx.gotVerb  (sidoeffekt)       │
  │  {conjadj öpp en/et/na}: ctx.curObj == nil → dobj = dörren │
  │  Alla returvärden kastas                                   │
  └────────────────────────────────────────────────────────────┘

  ┌─ endPreScan ───────────────────────────────────────────────┐
  │  ctx.prescan = nil                                         │
  └────────────────────────────────────────────────────────────┘

  ┌─ Pass 2 (expansion) ───────────────────────────────────────┐
  │  {Ref subj dobj}:          "Dörren"                        │
  │  {är}:   subj=dörren, p=3, singular → "är"  (presens)     │
  │  redan:                    "redan"                         │
  │  {conjadj öpp en/et/na}:  dörren.isNeuter=nil → +en       │
  │                            → "öppen"                       │
  └────────────────────────────────────────────────────────────┘

Resultat: "Dörren är redan öppen."
```

---

## Sammanfattning — vad styr vad

```
Vad du vill                       Hur du gör det
─────────────────────────────────────────────────────────────────
Adjektiv kongruerar med dobj      Skriv rot{mönster} — langAdjust fixar resten
Adjektiv kongruerar med annat obj {curobj namngivetobj}{conjadj rot mönster}
                                  (kräver gMessageParams(obj) och Pipeline B:
                                   skriv {conjadj} direkt, inte rot{mönster})
Verb konjugerar korrekt           Skriv rot{r/de/t} (grupp 1) etc. i Pipeline A,
                                  eller {conj rot r/de/t} i Pipeline B
Verb utan utskrivet subjekt       {dummy} (singular) / {plural} (plural)
Specifikt objekt som subjekt      gMessageParams(obj); {ref subj obj}
                                  (skriver ut namnet och sätter ctx.subj)
Engångsjustering av adjektiv      Funktionsanrop: adjustAdjectiveAgreement(
                                    object{curObj=obj}, ['conjadj','rot','mönster'])
```
