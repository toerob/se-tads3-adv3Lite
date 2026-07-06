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

| Ändelse | Genus |
|---|---|
| `t`, `et` | neutrum |
| `n`, `en`, `an` | utrum |

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

Adjektiv läggs normalt i sektion 2. Varje adjektiv anges med sin grundform och
böjd form separerade med `+`:

```tads3
apple: Thing 'äpple+t;stor+a röd+a';
// adjektiv: stor, stora, röd, röda
// substantiv: äpple, äpplet
// name = 'äpple',  theName = 'äpplet'
```

Adjektiv utan `+` tas som de är och skapar bara ett ord:

```tads3
boll: Thing 'boll+en;rund';
// adjektiv: rund
```

### Adjektiv i sektion 1 — adjektiv som del av name

Placeras ett adjektiv **i sektion 1**, före substantivet, inkluderas det
automatiskt i `name` och `theName`:

```tads3
blåStol: Thing 'blå+a stol+en;bekväm+a';
// name    = 'blå stol'
// theName = 'den blåa stolen'
// aName   = 'en blå stol'
// adjektiv (sökord): blå, blåa, bekväm, bekväma
// substantiv (sökord): stol, stolen
```

Artikeln i `theName` väljs automatiskt:

| Objekt | Artikel |
|---|---|
| Singular utrum | `den` |
| Singular neutrum | `det` |
| Plural eller massNoun | `de` |

Adjektiv i sektion 1 genererar sökord precis som adjektiv i sektion 2.
Använd sektion 1 när adjektivet ska vara en del av objektets namn (som det
visas i spelet), och sektion 2 när adjektivet bara ska vara ett sökord.

### Prepositioner i sektion 1 — hur ordklassen avgörs

När sektion 1 (kortnamnet) analyseras går parsern igenom orden ett i taget
och avgör varje ords ordklass enligt denna prioritetsordning:

1. **Preposition** — ordet matchar `prepList` (standard: `till|av|från|med`),
   eller är uttryckligen annoterat `[prep]`. Prepositioner registreras som
   sökord men bidrar aldrig till `name`/`definiteForm`.
2. **Svag token** — ordet är annoterat `[weak]` (eller skrevs inom `(...)` i
   vocab-strängen).
3. **Substantiv** — ordet är det **sista ordet i första frasen**, dvs.
   nästa ord är antingen inget alls eller en preposition (enligt punkt 1).
   Det första ordet som uppfyller detta blir objektets huvudsubstantiv och
   sätter `name`/`definiteForm`.
4. **Adjektiv** — allt annat. Adjektiv **före** huvudsubstantivet samlas i
   `name`/`shortNameAdjDef` (se ovan). Adjektiv **efter** huvudsubstantivet
   (dvs. i en prepositionsfras) registreras bara som sökord — de räknas
   inte in i `name`/`definiteForm`/`shortNameAdjDef`.

Exempel:

```tads3
nyckel: Thing 'nyckel+n till dörren';
// 'till' finns i prepList, så det tolkas som en preposition
// 'nyckel+n' är sista ordet innan prepositionen, så det blir substantivet:
//   name='nyckel', definiteForm='nyckeln'
// 'dörren' kommer efter prepositionen, så det blir bara ett sökord — ingår inte i name
// Resultat: du kan skriva "nyckeln" eller "nyckeln till dörren", båda matchar,
//   men det visas alltid bara som "nyckeln"

hog: Thing 'hög+en med papper';
// 'med' finns i prepList, så det tolkas som en preposition
// 'hög+en' blir därmed substantivet: name='hög', definiteForm='högen'
// 'papper' är bara ett sökord efter prepositionen
```

Detta är avsiktligt: en efterställd prepositionsfras behandlas som en
valfri, disambiguerande kvalificerare (jämför engelskans "key to the door"
vs. bara "key") — inte som en del av objektets vanliga visningsnamn.

**Lägg inte till fler ord i `prepList` i onödan.** Det är en global lista
som påverkar *alla* vocab-strängar i spelet, och konsekvensen av att ett ord
plötsligt tolkas som preposition är att allt efter det ordet försvinner ur
`name`/`definiteForm` (se nästa avsnitt för ett konkret exempel med `soppa på
burk`, där `på` medvetet **inte** ingår i `prepList` eftersom det skulle
knuffa ut hela "på burk"-frasen ur namnet).

Behöver du att just **ett enskilt objekts** vocab-sträng ska tolka ett visst
ord som preposition — utan att ändra den globala `prepList` och därmed
påverka alla andra objekt — annotera ordet direkt med `[prep]` istället:

```tads3
bok: Thing 'bok+en på[prep] hylla+n';
// 'på' är inte med i prepList, men annoteras uttryckligen som preposition
// här — bara för det här ordet, bara i det här objektet.
// 'bok+en' blir då sista ordet innan prepositionen, alltså substantivet:
//   name='bok', definiteForm='boken'
// 'hylla+n' hamnar efter prepositionen, så det blir bara ett sökord — ingår inte i name
// Resultat: visas alltid som "boken", men "hylla"/"hyllan" är ändå registrerade
//   sökord för matchning
```

Notera skillnaden mot `soppa på burk`: där ska "på burk" vara en del av det
vanliga visningsnamnet (inte bara en disambiguerande kvalificerare), så där
används istället en direkt satt `definiteForm` (se nästa avsnitt) snarare än
`[prep]`-annotering.

### Varför 'för' inte är med i prepList

Den engelska adv3Lite-motsvarigheten till `prepList` är `'to|of|from|with|for'`.
Fyra av dessa fem ord har direkta, oproblematiska svenska motsvarigheter
(`till|av|från|med`) — men `för` är **medvetet uteslutet**, till skillnad från
den engelska förlagan.

Anledningen är att engelska "for" bara har den betydelse vi vill fånga här:
ett syfte eller en mottagare, som i "instructions **for** use" eller "medicine
**for** headaches". Svenska "för" har samma betydelse ("instruktioner **för**
användning"), men är också det vanligaste ordet för förstärkningen
"för mycket"/"för stort" ("too much"/"too big") — en betydelse engelska "for"
inte delar. Om `för` stod kvar i `prepList` skulle en kortnamnsfras som

```tads3
tradigInstruktion: Thing 'för tråkig+a instruktion+en';
// avsedd betydelse: "the too boring instruction"
```

feltolkas: `instruktion+en` skulle bli substantivet (sista ordet innan `för`),
och `för tråkiga` — den del av namnet författaren faktiskt ville visa — skulle
tyst falla bort ur `name`. Med `för` borttaget ur `prepList` tolkas `för` och
`tråkig+a` istället som två vanliga ord före substantivet (samma mekanism som
`blå+a stol+en`), så hela frasen bevaras:

```tads3
// name         = 'för tråkig instruktion'
// aName        = 'en för tråkig instruktion'
```

(`theName` blir dock `'den tråkiga instruktionen'` — `för` saknar egen
`+`-notation och bidrar därför inte till `shortNameAdjDef`, precis som vilket
annat oböjligt adjektiv utan `+`-notation som helst i sektion 1. Behövs `för`
även i den bestämda formen, sätt `definiteForm` direkt enligt nästa avsnitt.)

De legitima "for"-fallen fungerar fortfarande precis som förut — annotera bara
`för` med `[prep]` i det specifika objektets vocab-sträng:

```tads3
instruktion: Thing 'instruktion+en för[prep] användning+en';
// name = 'instruktion', definiteForm = 'instruktionen'
// 'användning+en' hamnar efter prepositionen, ingår inte i name
```

Kort sagt: `för` som **syfte/mottagare** ("for use", "for headaches") kräver nu
`[prep]`-annotering per objekt. `för` som **förstärkning** ("too big", "too
boring") fungerar automatiskt utan någon annotering alls, eftersom det inte
längre riskerar att tolkas som en preposition.

### Manuell definiteForm för ovanliga fraser

Notationen ovan täcker "adjektiv + substantiv". Den täcker **inte** ett
substantiv följt av en oföränderlig prepositionsfras som alltid ska synas i
namnet, t.ex. "soppa på burk" (bestämd form: "soppan på burk"). Ord efter
substantivet i sektion 1 tolkas som en efterställd, valfri kvalificerare
(jämför "nyckel till dörren") och räknas därför inte in i `name`/`definiteForm`
annat än av en slump.

Sätt istället `definiteForm` direkt på objektet:

```tads3
soppburken: Container 'soppa+n på burk+en;;konservburk+en'
    definiteForm = 'soppan på burk'
;
// name       = 'soppa på burk'   (byggs som vanligt av vocab-strängen)
// definiteForm = 'soppan på burk' (satt direkt, används ordagrant)
// theName    = 'soppan på burk'  (inget artikelprefix läggs till)
// aName      = 'en soppa på burk'
```

När `definiteForm` sätts direkt genereras inget automatiskt adjektivprefix
(`shortNameAdjDef`) — `theNameFrom` returnerar då `definiteForm` precis som
den skrevs, utan `den`/`det`/`de` framför. Genus (`isNeuter`) härleds i så
fall från **första ordet** i `definiteForm` (här ger "soppan" utrum), så det
behöver normalt inte sättas manuellt även för flerordsfraser.

**Obs:** sätt inte `theName` direkt i detta syfte — det har ingen effekt.
Parsern bygger objektreferenser (t.ex. standardmeddelandet "Du ser inget
speciellt med ...") via `distinguishedName()`, som anropar `theNameFrom(name)`
direkt och aldrig läser `theName`-egenskapen. Hävstången för att styra hur ett
objekt refereras till bestämt är alltså `definiteForm`, inte `theName`.

### Sammansättning eller manuell definiteForm — vilket ska man välja?

`soppa på burk` är ett exempel på en **oföränderlig kvalificerare** som hör till
objektets identitet ("den här typen av soppa"). Men ibland vill man länka två
substantiv med `av` av en helt annan anledning: för att peka ut en **specifik
referent** — vem/vad något föreställer, inte vilken typ eller vilket material
det är gjort av. Då räcker det inte att bara skriva om vocab-strängen med
sammansättningsnotation (`+`/`^s`/`:`), och lösningen blir densamma som ovan:
sätt `name`/`definiteForm` direkt.

Jämför de två fallen:

```tads3
// Material/kategori: sammansättning fungerar utmärkt, inget 'av' behövs
papperslappsbit: Thing 'gul+a papper:et^s+lapp^s+bit+en';
// → papper/papperet, papperslapp/papperslappen, papperslappsbit/papperslappsbiten
// name='gul papperslappsbit', theName='den gula papperslappsbiten'

// Specifik referens (avbildning): sammansättning duger inte här
staty: Thing 'staty+n av kung+en'
    name = 'staty av kungen'
    definiteForm = 'statyn av kungen'
;
// name         = 'staty av kungen'
// definiteForm = 'statyn av kungen'
// theName      = 'statyn av kungen'
// aName        = 'en staty av kungen'
```

Varför fungerar inte sammansättning för `staty av kungen`? `kungastaty` skulle
bara betyda "en staty föreställande en kung i allmänhet" — en generisk kategori
av statyer. Den bestämda referensen till just **den här** kungen, som ligger i
`kungen`s `+en`-ändelse, går förlorad så fort ordet pressas in som ett
sammansättningsled (som alltid använder den obestämda stammen). Samma
begränsning gäller `porträttet av drottningen`, `fotografiet av Anna`, `kartan
av ön` — närhelst "av" pekar ut något specifikt snarare än en generisk
egenskap.

Tumregel:

| Situation | Lösning |
|---|---|
| Material/kategori | Sammansättning (`trästol`, `papperslappsbit`) |
| Specifik referens/avbildning | Manuell `definiteForm` (`staty av kungen`) |

I det senare fallet hamnar `staty+n` ändå som huvudsubstantiv i vocab-strängen
(`av` finns i `prepList`), så utan den manuella överskrivningen hade "av
kungen" tyst fallit bort som en efterställd, valfri kvalificerare — exakt
samma mekanism som beskrivs ovan för `soppa på burk`.

---

## Pluralformer

Pluralformer placeras i sektion 3 (extra substantiv) och markeras med `[pl]`:

```tads3
apple: Thing 'äpple+t;;äpplen+a[pl]';
// singular: äpple, äpplet
// plural:   äpplen, äpplena

vindruvor: Thing 'vindruvor+na[pl];;;dem';
// plural: vindruvor, vindruvorna   (sektion 1 med [pl] ger plural=true)
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
| `'blå+a stol+en;bekväm+a'` | blå, blåa, stol, stolen, bekväm, bekväma — name='blå stol', theName='den blåa stolen' | utrum |
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
ändelsen (se tabellen i "Plusnotationen" ovan). Använd dem bara när ändelsen
inte ger tillräcklig information eller du vill vara explicit.

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
artikelspecificerare), lägg till rätt specifierare dessförinnan: skriver du
`'en en bricka'` konsumeras specifieraren `en`, och kortnamnet blir "en bricka".

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
