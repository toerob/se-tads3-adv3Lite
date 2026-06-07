# Vocab-notation — adv3LiteSwe

Den svenska översättningen av adv3Lite använder en utökad vocab-notation med `+`-tecken
för att automatiskt generera ändelser och sammansatta ord.

## Grundformat

adv3Lites vocab-sträng har fyra sektioner separerade med semikolon:

```
'namn ; adjektiv ; substantiv ; pronomen'
```

| Sektion | Innehåll | Exempel |
|---|---|---|
| 1 — namn | Primärt substantiv med ändelse | `äpple+t` |
| 2 — adjektiv | Noll eller fler adjektiv | `stor+a röd+a` |
| 3 — substantiv | Extra namnformer och plural | `frukt+en frukter+na[pl]` |
| 4 — pronomen | `honom`, `henne`, `det`, `dem` | `honom` |

De tre sista sektionerna är valfria. Sektioner som saknas lämnas tomma, men
semikolonen i mitten kan utelämnas om allt till höger saknas.

### Jämförelse med adv3

I adv3 används `/` för att separera namnvarianter och `*` inför pluraler:

```tads3
// adv3:
apple: Thing 'äpple+t/frukt+en*frukter+na';

// adv3Lite:
apple: Thing 'äpple+t;rö:tt+da;frukt+en frukter+na[pl]';
```

Skillnaden är alltså att adv3Lite följer standardformatet med semikolon och
lägger adjektiven i en egen sektion, medan plural markeras med `[pl]` i stället
för `*`.

---

## Plusnotationen

`+` markerar var ändelsen börjar i ett ord. Grundformen (utan ändelse) och
den bestämda formen (med ändelse) skapas automatiskt.

```tads3
apple: Thing 'äpple+t';
// → äpple, äpplet   (neutrum)

dörr: Thing 'dörr+en';
// → dörr, dörren    (utrum)
```

Grammatiskt genus (`isNeuter`) härledas automatiskt från ändelsen:
ändelserna `t`, `et` → neutrum; `n`, `en`, `an` → utrum.

Minst namnform + bestämdhetstecken bör alltid anges för att genus ska kunna
härledas korrekt.

### Sammansatta ord

Lägg till fler komponenter med `+` — varje komponent genererar även egna
kortformer:

```tads3
cykelkorg: Thing 'cykel+korg+en';
// → cykel, cykeln, cykelkorg, cykelkorgen
```

### Foge-s

Använd `^s` för foge-s:

```tads3
tranbarsjuice: Thing 'tranbär^s+juice+n';
// → tranbär, tranbären, tranbärsjuice, tranbärsjuicen
```

### Alternativ obestämd form (kolon)

Kolon separerar alternativ böjning från ändelsen. Används när bestämd och
obestämd form inte delar samma stam:

```tads3
fonstret: Thing 'fönst:er+ret';
// → fönster, fönstret
```

Minnesregel: obestämd form kommer före `:`, bestämd form (med genus) efter `+`.

Kolon kan också byta genus på en del av ett sammansatt ord utan att påverka
slutändelsen:

```tads3
ansvarskanslan: Thing 'ansvar:et^s+känsla+n';
// → ansvar, ansvaret  (neutrum)  +  ansvarskänsla, ansvarskänslan  (utrum)
```

### Delkomponent utan egna ord

Använd `|` i stället för `+` om ett led inte ska genereras som eget ord:

```tads3
cykelslang: Thing 'cykel|slang+en';
// → cykelslang, cykelslangen, slang, slangen
// cykel och cykeln skapas INTE
```

---

## Adjektivsektionen

Adjektiv läggs i sektion 2. Varje adjektiv anges med sin grundform och
böjd form separerade med `+`:

```tads3
apple: Thing 'äpple+t;stor+a röd+a';
// adjektiv: stor, stora, röd, röda
// substantiv: äpple, äpplet
```

Adjektiv utan `+` tas som de är och skapar bara ett ord:

```tads3
boll: Thing 'boll+en;rund';
// adjektiv: rund
```

---

## Pluralformer

Pluralformer placeras i sektion 3 (extra substantiv) och markeras med `[pl]`:

```tads3
apple: Thing 'äpple+t;;äpplen+a[pl]';
// singular: äpple, äpplet
// plural:   äpplen, äpplena

vindruvor: Thing 'vindruvor+na[pl];;;dem';
// plural: vindruvor, vindruvorna   (sektion 1 med [pl] → plural=true)
```

Sätts `[pl]` i sektion 1 tolkas hela objektet som plural och `plural` sätts
till `true`.

---

## Pronomen

Sektion 4 styr vilka pronomina parsern accepterar samt sätter `isHim`, `isHer`
och `plural` automatiskt:

| Pronomen | Effekt |
|---|---|
| `honom` | `isHim = true` |
| `henne` | `isHer = true` |
| `det` | `isIt = true` (objektet svarar på pronomenet "det") |
| `den` | `isIt = true` (objektet svarar på pronomenet "den") |
| `dem` | `plural = true` |

```tads3
croupier: Actor 'croupier+n;;;honom';
// → isHim = true

flygvardinna: Actor 'flyg|värdinna+n;;;henne';
// → isHer = true

vindruvor: Thing 'vindruvor+na[pl];;;dem';
// → plural = true
```

---

## Notationsexempel

| Notation | Genererade ord | Genus / antal |
|---|---|---|
| `'äpple+t'` | äpple, äpplet | neutrum |
| `'dörr+en'` | dörr, dörren | utrum |
| `'äpple+t;stor+a röd+a'` | äpple, äpplet, stor, stora, röd, röda | neutrum |
| `'äpple+t;;frukt+en'` | äpple, äpplet, frukt, frukten | neutrum |
| `'äpple+t;;äpplen+a[pl]'` | äpple, äpplet, äpplen, äpplena | neutrum + plural |
| `'vindruvor+na[pl]'` | vindruvor, vindruvorna | plural |
| `'tranbär^s+juice+n'` | tranbär, tranbären, tranbärsjuice, tranbärsjuicen | utrum |
| `'ansvar:et^s+känsla+n'` | ansvar, ansvaret, ansvarskänsla, ansvarskänslan | blandat |
| `'fönst:er+ret'` | fönster, fönstret | neutrum |
| `'cykel\|slang+en'` | cykelslang, cykelslangen, slang, slangen | utrum |

---

## Artikelspecificering

Det allra första ordet i sektion 1 kan vara en explicit artikelspecificerare.
Det konsumeras av parsern och läggs inte till som vokabulärord — det styr
bara grammatikegenskaper på objektet. Bara sektion 1 kontrolleras; ord i
sektion 2–4 påverkas inte.

| Värde | Effekt |
|---|---|
| `en` | `isNeuter = nil` (utrum) — sällan nödvändigt, ändelsen räcker oftast |
| `ett` | `isNeuter = true` (neutrum) — sällan nödvändigt, ändelsen räcker oftast |
| `lite` | `massNoun = true` — oräknebart ämnesord ("lite vatten") |
| `några` | `massNoun = true` — oräknebart ämnesord, mer naturligt för plurala ämnesord |
| `()` | `qualified = true` — objektet tar aldrig obestämd artikel |
| `den` / `det` | `qualified = true` — som `()` men skrivs naturligare för egennamn |

`en` och `ett` behövs normalt inte eftersom genus härleds automatiskt från
ändelsen (`+n`/`+en`/`+an` → utrum, `+t`/`+et` → neutrum). Använd dem bara
när ändelsen inte ger tillräcklig information eller du vill vara explicit.

```tads3
vatten: Thing 'lite vatt:en+et';
// → massNoun = true, substantiv: vatten, vattnet

korn: Thing 'några korn+en';
// → massNoun = true, substantiv: korn, kornen

sokrates: Actor '() Sokrates';
// → qualified = true, visas aldrig som "en Sokrates"

gudinna: Actor 'den Stora Gudinnan';
// → qualified = true
```

Behöver kortnamnet faktiskt börja med ett av dessa ord som vanligt ord (inte
artikelspecificerare), lägg till rätt specifierare dessförinnan:
`'en en bricka'` → specifieraren `en` konsumeras, kortnamnet blir "en bricka".

---

## Arv av vocab

Det finns två former av vocab-arv, som täcker olika situationer.

> **Skillnad mot engelska:** Den engelska adv3Lite använder `+` som arvsmarkör
> (`red +`). Eftersom det svenska biblioteket redan använder `+` för
> ändelsebindning (`kiwi+n`) ersätts arvsmarkören här med `*`.

### Med `*` — subklassen lånar superklassens substantiv

Använd `*` när subklassen inte har något eget namn utan ska benämnas med
superklassens substantiv. `*` expanderas till superklassens namnvokabulär och
placeras i sektion 1 tillsammans med egna adjektiv:

```tads3
class Penna: Thing 'penn+an; blyerts';
rodPenna: Penna 'röd+a *';
// → substantiv (från *): penna, pennan
// → adjektiv (egna):     röd, röda
// → adjektiv (ärvda):    blyerts
// Svarar på: röd, röda, penna, pennan, blyerts
```

### Utan `*` — subklassen har eget namn

Definierar subklassen sitt eget substantivnamn utan `*`, behåller den det
namnet och ärver bara adjektiv och plural från superklassen — inte substantivet:

```tads3
class Frukt: Thing 'frukt+en; mog:en+na; frukter[pl]';
kiwi: Frukt 'kiwi+n';
// → substantiv (eget):  kiwi, kiwin
// → adjektiv (ärvda):   mogen, mogna
// → plural (ärvd):      frukter
// Svarar INTE på: frukt, frukten
```

### Blockera arv

Börjar sektion 2 eller 3 i subklassens vocab med `-`, ärvs inte den sektionen
från superklassen. Det ledande `-` tas bort och resten används som vanligt:

```tads3
kiwi: Frukt 'kiwi+n; -';
// → kiwi, kiwin  — inga adjektiv alls, varken egna eller ärvda
```

### Bindestreck i ord

`-` är bara en styrsignal när det är det allra första tecknet i en sektion.
Bindestreck mitt i ord (t.ex. `t-shirt`, `e-post`) kräver ingen escaping och
fungerar som vanliga tecken.

---

## Matchningsmodifierare

Dessa läggs direkt efter ett ord, utan mellanslag.

| Suffix | Effekt |
|---|---|
| `=` | Exakt matchning — ingen trunkering, inga teckenapproximationer |
| `~` | Fuzzy matchning — trunkering och teckenapproximationer tillåts |

```tads3
Thing 'databas+en; SQL=';
// SQL måste skrivas exakt — 'SQ' eller 'sql' matchar inte

Thing 'färg+en; röd~';
// 'rod' och 'rö' matchar 'röd'
```

Pluraler antas som standard inte tillåta trunkering. Lägg till `~` på en
plural för att uttryckligen tillåta det.

---

## Svaga tokens

`[weak]` (eller omslutande parenteser) markerar ett ord som svagt — parsern
accepterar det inte ensamt utan bara i kombination med andra ord:

```tads3
Thing 'låda (av) trä';
// 'av' matchas bara i frasen "låda av trä", aldrig ensamt
```

---

## Avaktivera notationen

Sätt `combineVocabWords = nil` för att stänga av `+`-notationen och skriva
alla former manuellt:

```tads3
plustecknet: Thing '+tecknet;;+tecken +-tecken +-tecknet plustecken plustecknet'
    combineVocabWords = nil
;
```

Detta kan behövas om något av tecknen `+ ^ : |` behöver ingå i ett ord.

---

## Felsökning

Kompilera med `-D __DEBUG` och skriv `ord <objekt>` i spelet för att se
vilka ord som genererats för ett objekt. Ytterligare exempel finns i
`tester/vocab-tests.t`.
