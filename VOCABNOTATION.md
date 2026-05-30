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
