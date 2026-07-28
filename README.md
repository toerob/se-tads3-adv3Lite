# Svensk översättning av adv3Lite till Tads3

Detta bibliotek möjliggör skapandet av Tads3-spel på svenska med
[adv3Lite](https://github.com/EricEve/adv3lite) — Eric Eves
ersättningsstandardbibliotek för adv3. (Söker du efter den svenska
översättningen av det ursprungliga adv3-biblioteket istället, se
[se-tads3](https://github.com/toerob/se-tads3).)

# Installation

1. Installera adv3Lite (om det inte redan finns) i din Tads3-installation,
   vanligtvis under `/usr/local/share/frobtads/tads3/lib/adv3Lite`.
2. Antingen kopiera `swedish`-katalogen dit (bredvid `english`) eller skapa en symbolisk länk från detta
   repos `lib/swedish`-katalog in i den installationen:

   ```bash
   sudo ln -s /absolut/sökväg/till/se-tads3-adv3Lite/lib/swedish /usr/local/share/frobtads/tads3/lib/adv3Lite/swedish
   ```

   Fördelen med symbolisk länk är att du enkelt kan hålla dig à jour med de senaste förändringarna
   i detta repository utan att behöva kopiera något varje gång det kommer en uppdatering.

   (TIPS: använd absolut sökväg om du skapar symbolisk länk, inte relativ.)

3. Lägg till `-D LANGUAGE=swedish` i din spelmakefil (`.t3m`) så att
   adv3Lite laddar den svenska översättningen.

# Kom igång!

1. Navigera till `exempel/snabbstart`.
2. Anpassa sökvägarna i `Makefile.t3m` om det behövs. Följande rader måste
   peka på rätt plats för din maskin:

   ```t3m
   -FI /usr/local/share/frobtads/tads3/include
   -FL /usr/local/share/frobtads/tads3/lib
   ```

3. Kompilera och kör `run_swe.sh` (använd `chmod +x run_swe.sh` om nödvändigt).

(Kommandot `frob -k utf8 -i plain game.t3` i `run_swe.sh` gör att svenska
tecken fungerar att läsa/skriva direkt i terminalen. Du kan givetvis även
använda en annan interpreter, t ex `spatterlight`, `gargoyle` eller
`lectrote`, dessa stödjer unicode och visar svenska tecken. Det är bara
frob som utgår från ascii (vilket du ändrar med -k parametern), samt att
plain mode (-i) är ett måste pga av en begränsning/bugg i frob.)

# Teckenkodning

Använd `#charset "utf-8"` överst i dina `.t`-filer för svenska tecken.

# Sammansatta ord och ändelser

Till skillnad från engelska, där ord som "tea kettle" skrivs isär och saknar
ändelser som "tekannan", behöver vi i svenskan hantera både sammansättningar
och ändelser. Den svenska adv3Lite-notationen använder `+` för det:

```tads3
apple: Thing 'äpple+t;stor+a röd+a;frukt+en';
// → substantiv: äpple, äpplet, frukt, frukten (neutrum, härlett från "+t")
// → adjektiv:   stor, stora, röd, röda
```

Kortfattat:

- `+` markerar var ändelsen börjar — genererar grundform och bestämd form,
  och härleder grammatiskt genus automatiskt.
- `^s` används för foge-s (`tranbär^s+juice+n` → tranbär, tranbären,
  tranbärsjuice, tranbärsjuicen).
- `:` anger en alternativ obestämd form eller byter genus på en
  sammansättningsdel.
- `|` slår ihop ord till ett sammansatt ord utan att skapa upp
  delkomponenterna som egna sökord.
- Vocab-strängen är uppdelad i fyra semikolon-separerade sektioner: namn,
  adjektiv, substantiv och pronomen — till skillnad från adv3 där `/` och `*`
  används.

Kompilera med `-D __DEBUG` och skriv `ord <objekt>` i spelet för att se
vilka ord som genererats för ett objekt.

Se **[VOCABNOTATION.md](VOCABNOTATION.md)** för fullständig dokumentation:
adjektivsektionen, pluralformer, vocab-arv, matchningsmodifierare, svaga
tokens och alla notationsexempel.

# Meddelanden och stränginterpolation

Meddelanden skrivs som strängar med `{parametrar}` som expanderas
automatiskt beroende på kontext — tempus, genuskongruens, vem/vad som
avses:

```tads3
Msg(already open, '{Ref subj dobj} {är} redan öpp{en/et/na}.')
// → "Dörren är redan öppen."   (utrum singular)
// → "Skåpet är redan öppet."   (neutrum singular)
// → "Dörrarna är redan öppna." (plural)
```

Stor begynnelsebokstav ges av att parameterns nyckelord skrivs med versal:
`{Ref ...}` → stor bokstav, `{ref ...}` → liten.

Några vanliga byggstenar:

- `{jag}`, `{du}`, `{ref subj dobj}` — subjekt- och objektreferenser.
- `{poss actor dobj}`, `{min}`, `{hans obj}` — possessiv.
- `{han obj}`, `{honom obj}`, `{sigsjälv obj}` — pronomen.
- `rot{en/et/na}` — adjektivkongruens (öppen/öppet/öppna).
- `rot{r/de/t}` — verbkonjugering genom alla tempus (öppnar/öppnade/öppnat).
- `{och N}`, `{eller N}` — listor av argument.

Se **[MEDDELANDESYNTAX.md](MEDDELANDESYNTAX.md)** för samtliga parametrar,
tempushantering, possessivformer och konjugeringsmönster. Vill du förstå
_hur_ expansionen fungerar under huven, se
**[MEDDELANDEARKITEKTUR.md](MEDDELANDEARKITEKTUR.md)**.

# Tester och exempel

Tester finns i `tester`-katalogen — kör dem med respektive `run-*.sh`-skript
(t ex `run-vocab-tests.sh`, `run-grammar-tests.sh`).

Färdiga exempelspel som löser övningarna i _Learning TADS 3 With Adv3Lite_
finns i `exempel/ovningar`, med en översikt och länkar till varje
källfil i [exempel/ovningar/ovningar.md](exempel/ovningar/ovningar.md).

I `exempel/flygplats` finns dessutom en svensk översättning av
[Airport](https://github.com/EricEve/airport) — exempelspelet från Eric Eves
egen adv3Lite-tutorial.

# Bidrag

Hittar du fel eller har förbättringsförslag, skapa gärna en issue eller pull
request.

# För andra nordiska språk

Känner du dig inspirerad att översätta till andra nordiska språk? Använd
gärna detta bibliotek som utgångspunkt!
