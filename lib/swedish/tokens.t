#charset "utf-8"
#include <dict.h>
#include <strcomp.h>
#include <tok.h>
#include "advlite.h"


/* ------------------------------------------------------------------------ */
/*
 *   Ytterligare token typer för svenska.
 */

/* special "apostrof-s" token */
enum token tokApostropheS;

/* special förkortningspunkt token */
enum token tokAbbrPeriod;

/* special "#nnn" numerisk token */
enum token tokPoundInt;

/* ------------------------------------------------------------------------ */
/*
 *   Är den givna token ett ord? Detta tar emot ett token-element i samma
 *   format som returneras av Tokenizer.tokenize(). Returnerar sant om token
 *   representerar ett ord som kan slås upp i ordboken, nil om det är något
 *   annat (såsom skiljetecken, ett nummer eller en citerad bokstavlig).
 *   
 *   [Required] 
 */
isWordToken(tok)
{
    /* på svenska är ordtoken av typen tokWord och tokAbbrPeriod */
    return getTokType(tok) is in (tokWord, tokAbbrPeriod);
}

/* ------------------------------------------------------------------------ */
/*
 *   Konkatenation av två token. Detta tar två token-element i samma
 *   format som returneras av Tokenizer.tokenize(), och returnerar ett
 *   kombinerat element i samma format. Resultatet ska vara som om
 *   den ursprungliga token-paret hade sammanfogats i inmatningssträngen.
 */
concatTokens(a, b)
{
    /* 
     *   Returnera de sammanfogade token-värdena och originaltexten. Använd
     *   den andra tokenens typ som den kombinerade typen. I de flesta fall
     *   kommer de två typerna att vara desamma, eftersom det vanligtvis bara
     *   är meningsfullt att kombinera token av samma slag.
     */
    return [getTokVal(a) + getTokVal(b),
            getTokType(b),
            getTokOrig(a) + getTokOrig(b)];
}

/* ------------------------------------------------------------------------ */
/*
 *   Kommando-tokenizer för svenska. Andra språkmoduler bör
 *   tillhandahålla sina egna tokenizers för att tillåta skillnader i
 *   skiljetecken och andra lexikala element.
 *   
 *   [Required] 
 */
cmdTokenizer: Tokenizer
    /*
     *   Listan över tokeniseringsregler. Detta är faktiskt inte nödvändigt
     *   att definieras av språkmodulen, eftersom du *kan* använda de
     *   standardregler som ärvts från bas-Tokenizer-klassen, men det är
     *   troligt att varje språk kommer att ha några egenheter som kräver
     *   anpassade regler.
     */
    rules_ = static
    [
        /* hoppa över mellanslag */
        ['whitespace', new RexPattern('<Space>+'), nil, &tokCvtSkip, nil],

        /* vissa skiljetecken */
        ['punctuation', new RexPattern('<' + punctChars + '>'),
         tokPunct, nil, nil],

        /*
         *   Vi har en specialregel för stavade nummer från 21 till 99:
         *   när vi ser ett 'tens' ord följt av ett bindestreck följt av ett
         *   'digits' ord, kommer vi att dra ut 'tens' ordet, bindestrecket och
         *   'digits' ordet som separata token.
         */
        ['spelled number',
         new RexPattern('<NoCase>(tjugo|trettio|fyrtio|femtio|sextio|'
                        + 'sjuttio|åttio|nittio)-'
                        + '(ett|två|tre|fyra|fem|sex|sju|åtta|nio)'
                        + '(?!<AlphaNum>)'),
         tokWord, &tokCvtSpelledNumber, nil],

        /* heltal */
        ['integer', new RexPattern('[0-9]+' + endAssert),
         tokInt, nil, nil],
        
//        ['real', new RexPattern('[0-9]+<period>[0-9]+' + endAssert), tokReal,
//            nil, nil],

        /* nummer med ett '#' före */
        ['integer with #', new RexPattern('#[0-9]+' + endAssert),
         tokPoundInt, nil, nil],

        /*
         *   Initialer. Vi letar efter strängar med tre eller två initialer,
         *   avgränsade av punkter men utan mellanslag. Vi letar efter
         *   tre-bokstavs initialer först ("G.H.W. Billfold"), sedan
         *   två-bokstavs initialer ("X.Y. Zed"), så att vi hittar den längsta
         *   sekvensen som faktiskt finns i ordboken. Observera att vi
         *   inte har en separat regel för enskilda initialer, eftersom
         *   vi kommer att plocka upp det med den vanliga förkortade ordregeln
         *   nedan.
         *
         *   Vissa spel kan tänkas utöka detta för att tillåta strängar av
         *   initialer med fyra bokstäver eller längre, men i praktiken tenderar
         *   folk att utelämna punkterna i längre uppsättningar initialer, så att
         *   initialerna blir en akronym, och därmed skulle passa den
         *   vanliga ordtokenregeln.
         */
        ['three initials',
         new RexPattern('<alpha><period><alpha><period><alpha><period>'),
         tokWord, &tokCvtAbbr, &acceptAbbrTok],

        ['two initials',
         new RexPattern('<alpha><period><alpha><period>'),
         tokWord, &tokCvtAbbr, &acceptAbbrTok],

        /*
         *   Förkortat ord - detta är ett ord som slutar med en punkt, såsom
         *   "Mr.". Denna regel kommer före den vanliga ordregeln
         *   eftersom vi bara kommer att betrakta punkten som en del av ordet
         *   (och inte en separat token), men endast om hela strängen
         *   inklusive punkten finns i ordboken.
         */
        ['abbreviation',
         new RexPattern('<AlphaNum|' + wordPunct + '>+<period>'),
         tokWord, &tokCvtAbbr, &acceptAbbrTok],

        /*
         *   Ett ord som slutar med en apostrof-s. Vi analyserar detta som två
         *   separata token: en för ordet och en för apostrof-s.
         */
        ['apostrophe-s word',
         new RexPattern('<AlphaNum|' + wordPunct + '>+<' + squote + '>[sS]%>'),
         tokWord, &tokCvtApostropheS, nil],

        /*
         *   Ord - observera att vi konverterar allt till gemener. Ett ord
         *   måste börja med en alfabetisk tecken, ett bindestreck eller ett
         *   ampersand; efter det inledande tecknet kan ett ord innehålla
         *   alfabetiska tecken, siffror, bindestreck, ampersands och
         *   apostrofer.
         */
        ['word',
         new RexPattern('<AlphaNum|' + wordPunct + '|' + squote + '>+'),
         tokWord, nil, nil],

        /* strängar med ASCII "raka" citattecken */
        ['string ascii-quote',
         new RexPattern('<min>([`\'"])(.*)%1' + endAssert),
         tokString, nil, nil],

        /* vissa människor gillar att använda enkla citattecken som `detta' */
        ['string back-quote',
         new RexPattern('<min>`(.*)\'' + endAssert), tokString, nil, nil],

        /* strängar med Latin-1 krulliga citattecken (enkla och dubbla) */
        ['string curly single-quote',
         new RexPattern('<min>\u2018(.*)\u2019'), tokString, nil, nil],
        ['string curly double-quote',
         new RexPattern('<min>\u201C(.*)\u201D'), tokString, nil, nil],

        /*
         *   oavslutad sträng - om vi inte just matchade en avslutad
         *   sträng, men vi har något som ser ut som början på en sträng,
         *   matcha till slutet av raden
         */
        ['string unterminated',
         new RexPattern('([`\'"\u2018\u201C](.*)'), tokString, nil, nil],

        /* 
         *   Acceptera alla andra grupper av tecken, förutom mellanslag och
         *   skiljetecken som vi hanterar speciellt, som om de vore ord. Detta
         *   är en fångst-allt för allt som de andra reglerna inte hanterar, och
         *   kommer bara att göra ett grundläggande ord av vilken grupp av
         *   tecken som helst som avgränsas av en av våra normala avgränsare.
         */
        ['any characters', new RexPattern('<^space|' + punctChars + '>+'),
         tokWord, nil, nil]
    ]

    /* token-separerande skiljetecken, som ett <alpha|x|y> mönster */
    punctChars = '.|,|;|:|?|!'

    /* slutet-av-token påstående */
    endAssert = static ('(?=$|<space|' + punctChars + '>)')

    /* 
     *   Lista över tecken som består av ett enkelt citattecken. Detta inkluderar
     *   vanliga ASCII raka citattecken samt unicode krulliga citattecken.
     *   Detta är för att klistra in i ett <alpha|x|y> mönster.
     */
    squote = 'squote|\u8216|\u8217'

    /* 
     *   lista över acceptabla skiljetecken inom ord; detta är för
     *   att klistra in i ett <alpha|x|y> mönster 
     */
    wordPunct = static
        '~|@|#|$|%|^|*|(|)|{|}|[|]|vbar|_|=|+|/|\\|langle|rangle|-|&'

    /*
     *   Hantera ett apostrof-s ord. Vi returnerar detta som två separata
     *   token: en för ordet före apostrofen-s, och en för
     *   apostrofen-s själv.
     */
    tokCvtApostropheS(txt, typ, toks)
    {
        local w;
        local s;

        /*
         *   dra ut delen upp till men inte inklusive apostrofen, och
         *   dra ut apostrofen-s delen
         */
        w = txt.left(-2);
        s = txt.right(2);

        /* lägg till delen före apostrofen som huvudtoken-typ */
        toks.append([w, typ, w]);

        /* lägg till apostrofen-s som en separat specialtoken */
        toks.append([s, tokApostropheS, s]);
    }

    /*
     *   Hantera ett stavat bindestrecksnummer från 21 till 99. Vi
     *   returnerar detta som tre separata token: ett ord för tiotalet, ett
     *   ord för bindestrecket och ett ord för enheterna.
     */
    tokCvtSpelledNumber(txt, typ, toks)
    {
        /* analysera numret i dess tre delar med ett reguljärt uttryck */
        rexMatch(patAlphaDashAlpha, txt);

        /* lägg till delen före bindestrecket */
        toks.append([rexGroup(1)[3], typ, rexGroup(1)[3]]);

        /* lägg till bindestrecket */
        toks.append(['-', typ, '-']);

        /* lägg till delen efter bindestrecket */
        toks.append([rexGroup(2)[3], typ, rexGroup(2)[3]]);
    }
    patAlphaDashAlpha = static new RexPattern('(<alpha>+)-(<alpha>+)')

    /*
     *   Kontrollera om vi vill acceptera en förkortad token - detta är
     *   en token som slutar med en punkt, som vi använder för förkortade ord
     *   som "Mr." Vi accepterar token endast om den visas
     *   som given - inklusive punkten - i ordboken. Observera att
     *   vi ignorerar trunkerade matchningar, eftersom det enda sättet vi accepterar en
     *   punkt i en ordtoken är som det sista tecknet; det finns alltså inget
     *   sätt att en token som slutar med en punkt kan vara en trunkering av någon
     *   längre giltig token.
     */
    acceptAbbrTok(txt)
    {
        /* slå upp ordet, filtrera bort trunkerade resultat */
        return cmdDict.isWordDefined(
            txt, {result: (result & StrCompTrunc) == 0});
    }

    /*
     *   Bearbeta en förkortad token.
     *
     *   När vi hittar en förkortning, lägger vi in den med det förkortade
     *   ordet minus den avslutande punkten, plus punkten som en separat
     *   token. Vi markerar punkten som en "förkortningspunkt" så att
     *   grammatikregler kommer att kunna överväga att behandla den som en
     *   förkortning - men eftersom det också är en vanlig punkt, kommer
     *   grammatikregler som behandlar punkter som vanliga skiljetecken också
     *   att kunna försöka matcha resultatet. Detta kommer att säkerställa att
     *   vi försöker båda sätten - som förkortning och som ett ord med
     *   skiljetecken - och väljer det som ger oss det bästa resultatet.
     */
    tokCvtAbbr(txt, typ, toks)
    {
        local w;

        /* lägg till delen före punkten som den vanliga token */
        w = txt.left(-1);
        toks.append([w, typ, w]);

        /* lägg till token för "förkortningspunkten" */
        toks.append(['.', tokAbbrPeriod, '.']);
    }

    /*
     *   Givet en lista med token-strängar, bygg om den ursprungliga
     *   inmatningssträngen. Vi kan inte återställa den exakta
     *   inmatningssträngen, eftersom tokeniseringsprocessen kastar bort
     *   information om mellanslag, men vi kan åtminstone komma fram till
     *   något som kommer att visas rent och producera samma resultat när
     *   det körs genom tokeniseraren.
     *   
     *   [Required] 
     */
    buildOrigText(toks)
    {
        local str;

        /* börja med en tom sträng */
        str = '';

        /* sammanfoga varje token i listan */
        for (local i = 1, local len = toks.length() ; i <= len ; ++i)
        {
            /* lägg till den aktuella token till strängen */
            str += getTokOrig(toks[i]);

            /*
             *   om detta ser ut som ett bindestrecksnummer som vi plockade
             *   isär i två token, sätt ihop det igen utan
             *   mellanslag
             */
            if (i + 2 <= len
                && rexMatch(patSpelledTens, getTokVal(toks[i])) != nil
                && getTokVal(toks[i+1]) == '-'
                && rexMatch(patSpelledUnits, getTokVal(toks[i+2])) != nil)
            {
                /*
                 *   det är ett bindestrecksnummer, allt rätt - sätt ihop de tre
                 *   tokenen igen utan några mellanliggande mellanslag,
                 *   så ['twenty', '-', 'one'] blir 'twenty-one'
                 */
                str += getTokOrig(toks[i+1]) + getTokOrig(toks[i+2]);

                /* hoppa fram med de två extra token vi lade till */
                i += 2;
            }
            else if (i + 1 <= len
                     && getTokType(toks[i]) == tokWord
                     && getTokType(toks[i+1]) == tokApostropheS)
            {
                /*
                 *   det är ett ord följt av en apostrof-s token - dessa
                 *   läggs ihop utan några mellanliggande mellanslag
                 */
                str += getTokOrig(toks[i+1]);

                /* hoppa över den extra token vi lade till */
                ++i;
            }

            /*
             *   om en annan token följer, och nästa token inte är ett
             *   skiljetecken, lägg till ett mellanslag före nästa token
             */
            if (i < len && rexMatch(patPunct, getTokVal(toks[i+1])) == nil)
                str += ' ';
        }

        /* returnera resultatsträngen */
        return str;
    }

        /* några förkompilerade reguljära uttryck */
        patSpelledTens = static new RexPattern(
            '<nocase>tjugo|trettio|fyrtio|femtio|sextio|sjuttio|åttio|nittio')
        patSpelledUnits = static new RexPattern(
            '<nocase>ett|två|tre|fyra|fem|sex|sju|åtta|nio')
        patPunct = static new RexPattern('[.,;:?!]')
    ;


