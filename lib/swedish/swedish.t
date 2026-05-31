#charset "utf-8"
#include "advlite.h"

/*
 *   Den huvudsakliga svenska språkmodulen.
 *   
 *   Detta är den svenska implementeringen av de generiska språkgränssnitten.
 *   All kod här är specifik för svenska, så andra språkmoduler
 *   kommer att ersätta den faktiska implementeringen. Men vissa av metoderna
 *   och egenskaperna är en del av det generiska gränssnittet - detta innebär att
 *   varje språkmodul måste definiera metoder och egenskaper med dessa
 *   namn, och med det abstrakta beteendet som beskrivs. Hur de faktiskt
 *   implementerar beteendet är upp till dem.
 *   
 *   Metoder och egenskaper som är en del av det generiska gränssnittet är
 *   identifierade med [Required].  
 */

property pluralTokens; 

/* ------------------------------------------------------------------------ */
/*
 *   Svenska modulalternativ. 
 */
swedishOptions: object
    /* decimaltecken */
    decimalPt = '.'

    /* gruppseparator i stora tal */
    numGroupMark = ','
;


/* ------------------------------------------------------------------------ */
/*
 *   LMentionable är den språksspecifika basklassen för Mentionable.
 *   
 *   Detta är rotklassen för objekt som spelaren kan nämna i
 *   kommandon. Nyckelfunktionen för dessa objekt är att de kan matcha
 *   substantivfraser i kommandoinmatning. Biblioteket underklasser denna basklass
 *   med Mentionable. Denna klass tillhandahåller den del av klassen som
 *   varierar beroende på språk.  
 *   
 *   [Required] 
 */
class LMentionable: object
    /*
     *   Hämta den obestämda formen av namnet, nominativt fall.
     *   
     *   [Required] 
     */
    aName = (ifPronoun(&name, aNameFrom(name)))

    /*
     *   Hämta den bestämda formen av namnet, nominativt fall.
     *   
     *   [Required] 
     */
    theName = (ifPronoun(&name, theNameFrom(name)))

    /* Bestämt namn, objektivt fall. */
    theObjName = (ifPronoun(&objName, theNameFrom(name)))

    /*
     *   Hämta den objektiva formen av namnet. Den vanliga 'name' egenskapen
     *   ger den subjektiva formen - dvs formen som visas som
     *   subjekt för ett verb. 'objName' ger formen som visas som en
     *   direkt eller indirekt objekt. Till skillnad från många språk, böjer svenska inte
     *   vanliga substantiv alls för dessa två fall - den objektiva formen av
     *   "bok" eller "nyckel" eller "widget" är identisk med den subjektiva formen.
     *   Den enda platsen där fall gör skillnad på svenska är
     *   pronomen: "jag" och "mig", "han" och "honom", etc. Så, denna rutin
     *   returnerar helt enkelt den subjektiva namnsträngen som standard, vilket kommer
     *   att fungera för alla objekt med ett vanligt substantiv som sitt namn. Generellt,
     *   detta behöver bara åsidosättas för spelarens karaktärsobjekt,
     *   som vanligtvis använder ett pronomen som sitt namn ("du" för ett
     *   andrapersonsspel, "jag" för ett förstapersonsspel).  
     */
    objName = (name)

    /*  
     *   A special version of the name we can use with the <<mention name *>> template. By default
     *   we just use the object's name
     */
    mentionName = (name)

    /*
     * I svenska behöver vi hålla reda på neutrum/utrum också
     * för att kunna avgöra: din/ditt en/ett etc
     */
    isNeuter = nil

    /*
     *   Hämta den possessiva adjektivliknande formen av namnet. Detta är formen av namnet vi använder som
     *   en kvalificerande fras när vi visar ett objekt vi äger. Den svenska regeln för vanliga substantiv
     *   är bara att lägga till apostrof-s till namnet: "Bob" blir "Bobs", "Orc vakt" blir "Orc
     *   vakts". Detta fungerar för nästan alla substantiv på svenska, men du kan åsidosätta detta om regeln
     *   ger fel resultat för ett visst namn. Men om substantivet är plural och dess
     *   namn slutar med ett 's' bör vi bara lägga till en apostrof - så vi gör detta via possEnding
     *   egenskapen.
     *
     *   Men det varierar för pronomen. Som standard kontrollerar vi namnet för att se om det är ett
     *   pronomen, och tillämpar rätt pronomenmappning om så är fallet.
     */
    possAdj = ifPronoun(&possAdj, '<<theName>><<possEnding>>')

    /* Possessivt adjektiv som kongruerar med neutrum ägd substantiv, t.ex. 'ditt', 'mitt', 'vårt'. */
    possAdjT = (ifPronoun(&possAdjT, '<<theName>><<possEnding>>'))

    /* Possessivt adjektiv som kongruerar med plural ägd substantiv, t.ex. 'dina', 'mina', 'våra'. */
    possAdjPl = (ifPronoun(&possAdjPl, '<<theName>><<possEnding>>'))

    /*
     *   Hämta den possessiva substantivliknande formen av namnet. Detta är formen
     *   av den possessiva vi använder i en genetiv "av" fras eller en "är"
     *   predikat, såsom "det är en bok av Bobs" eller "den boken är
     *   Bobs". På svenska är detta nästan alltid identiskt med
     *   den possessiva adjektivformen för ett vanligt substantiv - det är bara samma
     *   apostrof-s ord som adjektivformen.
     *   
     *   Men det skiljer sig för några av pronomenerna: "min" vs "mitt",
     *   "hennes" vs "hennes", "deras" vs "deras", "vår" vs "vårt". Vi kontrollerar
     *   namnet för att se om det är ett pronomen, och tillämpar den lämpliga
     *   pronomenmappningen om så är fallet.  
     */
    possNoun = (ifPronoun(&possNoun, '<<theName>><<possEnding>>'))
    
    /*
     *   Den korrekta ändelsen för vår possessiva form. Vanligtvis 's', förutom när
     *   substantivet redan slutar på 's', i vilket fall vi inte lägger till något.
     */
    possEnding = (theName.endsWith('s') ? '' : 's')

    /* Det subjektiva fallets pronomen för detta objekt. Vi försöker härleda pronomenet från
     *   köns- och antalflaggorna: om plural, 'de'; om isHim, 'han'; om isHer 'hon'; annars 'det'.
     */
    heName = (pronoun().name)

    /*
     *   Det objektiva fallets pronomen för detta objekt. Vi försöker härleda
     *   pronomenet från köns- och antalflaggorna: om plural, 'dem';
     *   om isHim, 'honom'; om isHer 'henne'; annars 'det'.  
     */
    himName = (pronoun().objName)

    /*
     *   Det possessiva adjektivpronom för detta objekt. Vi försöker
     *   härleda pronomenet från köns- och antalflaggorna: om plural,
     *   'deras'; om isHim, 'hans'; om isHer, 'hennes'; annars
     *   'dess'.  
     */
    herName = (pronoun().possAdj)

    /*
     *   Det possessiva substantivpronom för detta objekt. Vi försöker härleda
     *   pronomenet från köns- och antalflaggorna: om plural, 'deras';
     *   om isHim, 'hans'; om isHer, 'hennes'; annars 'dess'.  
     */
    hersName = (pronoun().possNoun)

    /*
     *   Demonstrativt pronomen för detta objekt, nominativt fall. För en
     *   singular könsbestämd objekt, eller ett första- eller andrapersonsobjekt,
     *   använder vi det vanliga pronomenet (jag, du, han, hon). För något annat
     *   singularobjekt, använder vi 'det', och för plural, 'de'.  
     */
    thatName = (pronoun().thatName)

    /*
     *   Demonstrativt pronomen, objektivt fall. För ett singular
     *   könsbestämt objekt, eller ett första- eller andrapersonsobjekt, använder vi
     *   det vanliga pronomenet (mig, dig, honom, henne). För något annat singular
     *   objekt, använder vi 'det', och för plural, 'de'.  
     */
    thatObjName = (pronoun().thatObjName)
    
    /*  Reflexivt namn som ett pronomen, t.ex. sig, sig, sig */
    reflexiveName = (pronoun().reflexive.name)    

    /*
     *   Emfatisk reflexiv form: 'sig själv', 'sig självt', 'sig själva' etc.
     *   Beräknas utifrån objektets egna genus/numerus-egenskaper, eftersom
     *   pronomenobjektet Itself delas av utrum och neutrum och inte kan
     *   hålla båda formerna som ett fast värde.
     */
    reflexiveObjName {
        local base = pronoun().reflexive.name;
        if(plural) return base + ' själva';
        if(isNeuter) return base + ' självt';
        return base + ' själv';
    }


    // TODO: refactor to this instead?
    // hersName = getPronounForm(&possNoun);
    // himName  = getPronounForm(&objName);
    getPronounForm(form) {
        if(form == &possNoun)
            return isNeuter ? 'mitt' : 'min';
        if(form == &objName)
            return 'dig';
        return nil;
    }

    /*
     *   Pronomen-eller-namn mappare. Om vårt namn är ett pronomen, returnera det
     *   givna pronomenets namn egenskap. Annars returnera den givna namn
     *   strängen.  
     */
    ifPronoun(prop, str)
    {
        /* kontrollera om vårt namn är ett pronomen */
        local p = LMentionable.pronounMap[name];
        if (p != nil)
        {
            /* vårt namn är ett pronomen - returnera pronomenegenskapen */
            return p.(prop);
        }
        else
        {
            /* inte ett pronomen - använd namnsträngen */
            return str;
        }
    }

    /*
     *   VocabWords lista för tomma objekt. Dessa är ord (vanligtvis
     *   adjektiv) som kan tillämpas på ett objekt som kan
     *   särskiljas från liknande objekt genom dess innehåll ("låda med
     *   papper", "hink med vatten"), för tider när det är tomt. Detta är en
     *   lista över VocabWords objekt för matchning under parsning.
     *   
     *   [Required] 
     */
    emptyVocabWords = static [new VocabWord('tom', MatchAdj)]

    
    /* 
     *   Flagga, vill vi att vårt theName ska konstrueras från vår ägares namn,
     *   t.ex. "Bobs plånbok" istället för "plånboken".
     */
    ownerNamed = nil
    
    /*
     *   Hämta den bestämda formen av namnet, givet namnsträngen under
     *   konstruktion. Den svenska standarden är "den <name>", om inte objektet
     *   redan är kvalificerat, i vilket fall det bara är basnamnet. Om,
     *   dock, vi är ownerNamed och vi har en nominalOwner, returnera vår
     *   ägares possessiva adjektiv följt av vårt namn (t.ex. "Bobs
     *   plånbok").
     */
    theNameFrom(str)
    {
        if(ownerNamed && nominalOwner != nil) {
            local p = nominalOwner.pronoun();
            local poss = plural   ? p.possAdjPl
                       : isNeuter ? p.possAdjT
                       :            p.possAdj;
            return poss + ' ' + str;
        }
        if (qualified) {
            return str;
        }
        if(definiteForm) {
            return definiteForm;
        }
        if(self.ofKind(Room)) {
            return name;
        }
        return 'den <<str>>';
    }

    /* Bestäm könet för detta objekt */
    isHim = nil
    isHer = nil
    isGenderNeutral = nil 
    
    /*  
     *   Som standard är ett objekt neutrum om det varken är maskulint eller feminint,
     *   men det kan åsidosättas i fall där något kan hänvisas
     *   till som antingen 'han' eller 'det' till exempel.
     */
    isIt = (!(isHim || isHer))
    
    
    /*   
     *   Namnet med en bestämd artikel (eller bara det korrekta eller kvalificerade namnet)
     *   följt av den lämpliga formen av verbet 'att vara'. Detta kan vara
     *   användbart för att producera meningar där detta objekt är subjektet.
     */
    theNameIs()
    {
        local obj = self;
        
        /* 
         *   Returnera theName plus den lämpliga böjningen av verbet 'att
         *   vara', som vi får från conjugateBe() funktionen, som förväntar
         *   sig ett ctx objekt som dess första parameter; vi skapar istället
         *   ett inline objekt och ställer in dess subj egenskap till det
         *   aktuella objektet (vilket är allt som conjugateBe() funktionen
         *   behöver).
         */
         
        return theName + ' ' + conjugateBe(object {subj = obj; }, nil);

    }
    
    /*
     *   Klassinitialisering. Biblioteket kallar detta vid preinit tid,
     *   innan du anropar construct() på några instanser, för att ställa in några
     *   förbyggda tabeller i klassen. Det finns ingen obligatorisk implementering
     *   här - detta är enbart för språkmodulens bekvämlighet att göra
     *   något initialt uppsättningsarbete.
     *   
     *   För den svenska versionen tar vi tillfället i akt att ställa in
     *   huvudparser Dictionary objektet, och initialisera plural tabellen.
     *   Plural tabellen är en uppslagstabell vi bygger från plural listan,
     *   för snabbare åtkomst under körning.
     *   
     *   [Required] 
     */
    classInit()
    {
        /* initialisera ordbokskomparatorn */
        cmdDict.setComparator(Mentionable.dictComp);

        /* skapa uppslagstabellen för pluralerna och a/an orden */
        local plTab = irregularPlurals = new LookupTable(128, 256);
        local anTab = specialAOrAn = new LookupTable(128, 256);

        /* ställ in ett/en mönstret */
        local aAnPat = R'^(ett|en)<space>+(.*)$';

        /* fyll våra tabeller från de CustomVocab objekt vi hittar */
        forEachInstance(CustomVocab, function(cv) {

            /* ställ in de oregelbundna pluralerna */
            for (local lst = cv.irregularPlurals, local i = 1, 
                 local len = lst.length() ; i <= len ; i += 2)
            {
                /* lägg till associationen för singular -> plural */
                plTab[lst[i]] = lst[i+1];
                
                /* 
                 *   lägg också till en association för plural -> plural, i fall vi
                 *   stöter på ord som 'data' som redan är plural 
                 */
                plTab[lst[i+1][1]] = lst[i+1];
            }

            /* ställ in de speciella a/an orden */
            for (local lst = cv.specialAOrAn, local i = 1,
                 local len = lst.length() ; i <= len ; ++i)
            {
                /* analysera posten */
                rexMatch(aAnPat, lst[i]);

                /* 
                 *   Ställ in dess tabellpost - 1 för 'ett', 2 för 'en'. (Vi
                 *   använder ett heltal istället för att lagra hela 'ett' eller
                 *   'en' strängen för att göra tabellen lite mindre
                 *   minnesmässigt. Att lagra strängarna skulle kräva ett
                 *   objekt per sträng. Eftersom det bara finns två
                 *   möjligheter, är det enkelt att lagra ett heltal istället,
                 *   och det sparar lite utrymme.)  
                 */
                anTab[rexGroup(2)[3]] = rexGroup(1)[3] == 'ett' ? 1 : 2;
            }

            /* vi är klara med dessa listor - för att spara utrymme, glöm dem */
            cv.irregularPlurals = nil;
            cv.specialAOrAn = nil;
        });
    }

    /*
     *   Matcha ett pronomen. Detta returnerar sant om detta objekt är en giltig
     *   antecedent för detta pronomen grammatiskt: det vill säga, det matchar pronomenet
     *   i kön, antal och andra attribut som pronomenet
     *   bär.
     *   
     *   Svenska pronomen har kön och antal. (Vissa andra språk
     *   har andra attribut, såsom animation - om de
     *   hänvisar till levande varelser.)
     *   
     *   Denna rutin berättar inte om objektet är en *aktuell*
     *   antecedent för pronomenet. Den aktuella antecedenten är en funktion
     *   av kommandohistoriken. Denna rutin berättar bara om detta
     *   objekt är en match i termer av grammatiska attribut för
     *   pronomenet.
     *   
     *   Observera att denna rutin kan och bör ignorera första person och
     *   andra person pronomen. Dessa pronomen är relativa till
     *   talaren, så parsern hanterar dem direkt.
     *   
     *   [Required] 
     */
    matchPronoun(p)
    {
        /*
         *   - Om vi har plural användning, matchar vi Dem
         *.  - Om vi är könsbestämda, matchar vi Honom eller Henne som lämpligt
         *.  - Om vi har singular neutrum användning, matchar vi Det
         */
        return (p == Them && (plural || ambiguouslyPlural)
                || p == Him && isHim
                || p == Her && isHer
                || p == ItNeuter && isIt && isNeuter && (!plural || ambiguouslyPlural)
                || p == It && isIt && !isNeuter && (!plural || ambiguouslyPlural));
    }

    /*
     *   Hämta pronomenet att använda för detta objekt. Detta returnerar Pronoun
     *   objektet som är lämpligt för att representera detta objekt i ett genererat
     *   meddelande.
     *   
     *   [Required] 
     */
    pronoun()   
    {
        switch(person)
        {
        case 1:
            return (plural ? Us : Me);
        case 2:
            return (plural ? Yall : You);
        default:
            return ((plural || isGenderNeutral) 
            ? Them :
                isHim ? Him : isHer ? Her : isNeuter ? ItNeuter : It);    
        }
    }
    
    /* Det lämpliga pronomenet för att lämna (komma ut ur) detta objekt */
    objOutOfPrep
    {
        switch(contType)
        {
        case On:
            return 'av';
        case Under:
            return 'ut från under';
        case Behind:
            return 'ut från bakom';
        default:
            return 'ut ur';
        }
    }
    
    /* 
     *   Den prepositionella frasen för något som finns inuti detta objekt, t.ex.
     *   'i lådan' eller 'på bordet
     */
    objInName = (objInPrep + ' ' + theName)
    
    
    /* 
     *   Den prepositionella frasen för något som flyttas inuti detta objekt, t.ex.
     *   'in i lådan' eller 'på bordet
     */
    objIntoName = (objIntoPrep + ' ' + theName)
    
    /*   
     *   Den pronominala frasen för något som lämnar detta objekt, t.ex. 'ut ur
     *   lådan'
     */
    objOutOfName = (objOutOfPrep + ' ' + theName)
    
    
    
    
    /*
     *   initVocab() - Analysera 'vocab' strängen. Detta kallas under preinit
     *   och vid dynamisk konstruktion av en ny Mentionable, för att initialisera objektets
     *   vokabulär för användning av parsern.
     *
     *   Vocab strängen är utformad för att göra det så snabbt och enkelt som möjligt
     *   att definiera ett objekts namn och vokabulär. Så långt som möjligt,
     *   härleder vi vokabulären från namnet, så för många objekt kommer hela
     *   definitionen att bara se ut som objektets namn. Men vi gör det också möjligt att definiera så mycket extra vokabulär utöver namnet som
     *   behövs, och att kontrollera hur orden som utgör namnet hanteras
     *   i termer av deras ordklasser.
     *
     *   Vocab strängen har denna övergripande syntax:
     *
     *.    vocab = 'artikel kort namn; adjektiv; substantiv; pronomen'
     *
     *   Du behöver inte inkludera alla delar; du kan helt enkelt sluta när
     *   du är klar, så det är giltigt, till exempel, att bara skriva 'kort namn'
     *   delen. Det är också okej att inkludera en tom del: om du har extra substantiv
     *   att lista, men inga adjektiv, kan du säga 'kort namn;;substantiv'.
     *
     *   'Artikeln' är valfri. Detta kan vara en av 'en', 'ett', 'några', eller
     *   '()'. Om det är 'en' eller 'ett', och detta skiljer sig från vad vi skulle
     *   automatiskt generera baserat på det första ordet i kortnamnet, vi
     *   automatiskt lägga till det första ordet i listan över specialfall för
     *   a/an ord. Om det är 'några', ställer vi automatiskt in massNoun=true för
     *   objektet. Om det är '-', ställer vi in qualified=true ('()' betyder att
     *   namnet inte tar någon artikel alls).
     *
     *   Observera att om du vill använda 'en', 'ett', 'några', eller '()' som det första
     *   ordet i det faktiska kortnamnet, behöver du bara lägga till den önskade
     *   artikeln framför det: 'en en bricka från ett scrabble set'.
     *
     *   Kortnamnet ger namnet som vi visar när parsern behöver visa
     *   objektet i en lista, en tillkännagivande, etc.
     *
     *   Om kortnamnet består helt av versaler (det vill säga, om
     *   varje ord börjar med en versal), och 'proper' inte är
     *   uttryckligen inställt för detta objekt, ställer vi in 'proper' till true för att
     *   indikera att detta är ett egennamn.
     *
     *   Vi försöker också härleda objektets vokabulärord från kortnamnet.
     *   Vi bryter först av eventuella prepositionella fraser, om vi ser prepositionerna
     *   'till', 'av', 'från', 'med', eller 'för'. Vi antar sedan att
     *   den FÖRSTA frasen är av formen 'adj adj adj... substantiv' - det vill säga, noll
     *   eller fler adjektiv följt av ett substantiv; och att den ANDRA och
     *   efterföljande fraser är helt adjektiv. Du kan åsidosätta
     *   ordklasshärledningen genom att sätta den faktiska ordklassen
     *   omedelbart efter ett ord (utan mellanslag) inom hakparenteser: 'John[n]
     *   Smith' åsidosätter antagandet att 'John' är ett adjektiv. Använd [n]
     *   för att göra ett ord till ett substantiv, [adj] för att göra det till ett adjektiv, [prep] för att göra det
     *   till en preposition, och [pl] för att göra det till en plural. Du kan också lägga till [weak] för att
     *   göra det till en svag token (en som objektet inte kommer att matcha ensam),
     *   eller motsvarande, omsluta ordet i parenteser. Dessa annoteringar
     *   tas bort från namnet när det visas.
     *
     *   Vi anser att ALLA ord i kortnamnets andra och efterföljande
     *   fraser (de prepositionella fraserna) är adjektiv, förutom
     *   prepositionsorden själva, som vi anser vara prepositioner.
     *   Detta beror på att dessa fraser alla effektivt kvalificerar huvudfrasen,
     *   så vi anser dem inte som "viktiga" för objektets namn. Detta
     *   hjälper parsern att vara smartare om disambiguering, utan att besvära
     *   användaren med klargörande frågor hela tiden. När spelaren skriver
     *   "garage", matchar vi "nyckel till garaget" objektet såväl som
     *   "garage" objektet, men om båda objekten är närvarande, vet vi att vi ska välja
     *   garaget över nyckeln eftersom substantivanvändningen är en bättre matchning för
     *   vad användaren skrev.
     *
     *   Vi ignorerar automatiskt artiklar (en, ett, den, och några) som vokabulärord
     *   när de omedelbart följer prepositioner i kortnamnet. 
     *   Till exempel, i 'nyckel till garaget', utelämnar vi 'den' som ett vokabulärord för
     *   objektet eftersom det omedelbart följer 'till'. Vi utelämnar också 'till',
     *   eftersom vi inte anger prepositionerna som vokabulär. Vi gör det
     *   kompletterande arbetet vid parsning, genom att ignorera dessa ord när vi ser dem
     *   i kommandoinmatningen i de rätta positionerna. Dessa ord är verkligen
     *   strukturella delar av grammatiken snarare än delar av objektnamnen,
     *   så parsern kan göra ett bättre jobb med att känna igen substantivfraser genom
     *   att överväga de grammatiska funktionerna hos dessa ord.
     *
     *   För många (om inte de flesta) objekt, kommer kortnamnet inte att vara tillräckligt för att ange
     *   alla vokabulärord du vill känna igen för objektet i
     *   kommandoinmatning. Att försöka klämma in varje möjligt vokabulärord i
     *   kortnamnet skulle vanligtvis göra ett otympligt visningsnamn.
     *   Lyckligtvis är det enkelt att lägga till inmatningsvokabulärord som inte visas i
     *   namnet. Lägg bara till ett semikolon, sedan adjektiven, sedan
     *   ett annat semikolon, sedan substantiven.
     *
     *   Observera att det inte finns någon sektion för att lägga till extra prepositioner, men du kan
     *   fortfarande lägga till dem. Sätt prepositionerna i adjektivlistan, och
     *   ange uttryckligen var och en som en preposition genom att lägga till "[prep]" i slutet, som i "till[prep]".
     *
     *   Nästa, det handlar om pluraler. För varje substantiv, försöker vi
     *   automatiskt härleda en plural enligt stavningsmönstret. Vi har också
     *   en tabell över vanliga oregelbundna pluraler som vi tillämpar. För
     *   oregelbundna ord som inte finns i tabellen, kan du åsidosätta
     *   stavningsbaserade pluraler genom att sätta den verkliga pluralen inom klamrar
     *   omedelbart efter substantivet, utan mellanslag. Börja med ett bindestreck för att
     *   ange ett suffix; annars skriv bara hela pluralordet. Till
     *   exempel, du kan skriva 'man{men}' eller 'child{-ren}' (även om dessa
     *   specifika oregelbundna pluraler redan finns i vår specialfallista, så
     *   de anpassade pluralerna behövs inte egentligen i dessa fall). Du kan använda
     *   pluralannoteringar i kortnamnet såväl som den extra substantivlistan;
     *   de tas bort från kortnamnet när det visas. Vi försöker inte generera en plural för ett egennamn (ett substantiv som börjar med en
     *   versal), men du kan tillhandahålla uttryckliga pluraler.
     *
     *   För ord längre än trunkeringslängden i strängkomparatorn,
     *   kan du ställa in ordet att matcha exakt genom att lägga till '=' som sista
     *   tecken. Detta kräver också exakt teckenmatchning, snarare än
     *   att tillåta accentuerade teckenapproximationer (t.ex. att matcha 'a' i
     *   inmatningen till 'a-umlaut' i ordboken).
     *
     *   Vi antar automatiskt att pluraler ska matchas utan
     *   trunkering. Detta beror på att svenska pluraler vanligtvis bildas med
     *   suffix; om användaren vill ange en plural, måste de skriva hela
     *   ordet ändå, eftersom det är det enda sättet att nå hela vägen
     *   till suffixet. Du kan åsidosätta detta antagande för en given plural genom
     *   att lägga till '~' i slutet av pluralen. Detta tillåter uttryckligen trunkerade
     *   och teckenapproximationer.
     *
     *   Slutligen, 'pronouns' sektionen ger en lista över de pronomen som detta
     *   ord kan matcha. Du kan inkludera 'det', 'honom', 'henne', och 'dem' i denna
     *   sektion. Vi ställer automatiskt in egenskaperna isIt, isHim, isHer, och plural
     *   till true när vi ser de motsvarande pronomenerna.
     *
     *   [Required]
     */
    initVocab()
    {
        /* Om vi är ett singular första person objekt, är vårt namn 'jag' eller 'vi' */
        if(person == 1)
            name = plural ? 'vi' : 'jag';
        
        /* Om vi är ett andra person objekt, är vårt namn 'du' */
        if(person == 2)
            name = 'du';
        
        /* om vi inte har en vocab sträng, finns det inget att göra */
        if (vocab == nil || vocab == '') {
            return;
        }
        // Specialhantering för att kunna använda '+'-tecken för ändelser i svenska
        // Syfte: det är smidigt att kunna använda '+' då det är ett tecken som 
        // inte kräver någon tangentbordskombination. 

        // Kruxet:
        // + används även för ange ärvda vocab(s) från objektets superklass. 
        // Men + används då i isolation innan eller efter orden. 
        // 
        // Enklaste lösning är ersätta dessa tecken globalt med ett annat ($) 
        // innan detta arv sker.

        // Vi vill bara ersätta de tecken som sätter ihop ett ord med ett annat 
        // utan mellanslag.

        // T ex: 'hund+en', 'kaffe+t' med 'hund$en' 'kaffe$t'
        // I övriga fall, får de betydelsen 'arv', t ex:
        // 'knapp+en +'
        // Vi matchar ord+ändelse och lämnar enskilda ' + '-tecken kvar
        local str = vocab.findReplace(R'<Space>?<Plus>)', {s: s.length == 2 ? s : '$' });
        // tadsSay('\n"<<vocab>>" = "<<str>>"\b');


        /* ärva eventuellt vocab från våra superklasser */
        inheritVocab();
                
        /* rensa vår vokabulärordlista */
        vocabWords = new Vector(10);
        /* 
         *   få den initiala strängen; vi kommer att bryta ner den medan vi arbetar
         *   Samtidigt ändra eventuella svaga tokens av formen
         *   (tok) till tok[weak], så att de effektivt behandlas
         *   som prepositioner (dvs de kommer inte att matcha ensamma)
         */
        str = str.findReplace(R'<lparen>.*?<rparen>', 
                                      {s: s.substr(2, s.length - 2) +
                                      (s == '()' ? '()' : '[weak]')});

        /* dra ut de stora delarna, avgränsade med semikolon */
        local parts = str.split(';').mapAll({x: x.trim()});
        
        
 #ifdef __DEBUG

        if(parts.length > 4)
        {
            "<b><FONT COLOR=RED>VARNING!</b></FONT> ";
            "För många semikolon i vocab strängen '<<vocab>>'; det borde vara en
            maximalt tre som separerar fyra olika sektioner.\n";
        }
 #endif

        /* den första delen är kortnamnet */
        local shortName = parts[1].trim();
 

        /* 
         *   om kortnamnet är helt i versaler, och 'proper' inte är
         *   uttryckligen inställt eller vi ersätter vocab, markera det som ett egennamn 
         */
        if ((propDefined(&proper, PropDefGetClass) == Mentionable || replacingVocab)
            && rexMatch(properNamePat, shortName) != nil)
            proper = true;

        /* notera det preliminära namnvärdet */
        local tentativeName = shortName;

        /* dela upp namnet i enskilda ord */
        local wlst = shortName.split(' '), wlen = wlst.length();

        /* kontrollera om det finns en artikel i början av frasen */
        local i = 1;
        if (wlen > 0 && wlst[1] is in('en', 'ett', 'några', 'den', 'det', '()'))
        {
            /* kontrollera vilket ord vi har */
            switch (wlst[1])
            {

            // OBS: vi försöker inte härleda ändelse utifrån artikel 
            // i svenskan då det är krångligt och felbenäget. 
            // Bestämda ordets ändelse är dock perfekt till just detta.

            // Så istället för "ett äpple" skriver vi helt enkelt "äpple+t"

            // Det är smidigast att skriva ändelsen till ordet istället:
            // Detta för att det är jättesvårt att göra en korrekt 
            // härledning av ändelsen på svenska utifrån
            
            // Dessa kan likväl finnas om man för tydlighets skull vill definiera
            // neutrum i text. Det kommer ha samma betydelse som att sätta isNeuter=true/nil
            // direkt i objektet.

            // Detta kommer i så fall bypassa det neutrum/utrum som skulle härletts ur själva 
            // ändelsen vid plusnotation.

            case 'ett':
                isNeuter = true;
                break;
            case 'en':
                isNeuter = nil;
                /* 
                 *   om detta inte matchar vad vi skulle syntetisera som standard
                 *   från det andra ordet, lägg till ordet som ett specialfall 
                 */
                /*
                if (wlen > 1 && aNameFrom(wlst[2]) != '<<wlst[1]>> <<wlst[2]>>') {
                    specialAOrAn[wlst[2]] = (wlst[1] == 'ett' ? 1 : 2);
                    tadsSay('***SÄTTER <<wlst[2]>> till <<specialAOrAn[wlst[2]]>>');
                }
                break;
            */

            case 'lite':
            case 'några':
                /* markera detta som ett mass substantiv */
                massNoun = true;
                break;
                
            case '()':            
                /* markera detta som ett kvalificerat namn */
                qualified = true;
                break;               
            
            case 'den':
            case 'det':
                qualified = true;
                wlst[1] = '!!!&&&';
                break;
            }

            /* det är en specialflagga, inte ett vokabulärord - hoppa över det */
            ++i;

            /* trimma detta ord från det preliminära namnet också */
            tentativeName = tentativeName.findReplace(
                wlst[1], '', ReplaceOnce).trim();

        }

        /* 
         *   Bearbeta varje ord i kortnamnet. Anta att varje är en
         *   adjektiv förutom det sista ordet i den första frasen, som vi
         *   antar är ett substantiv. Vi behandlar allt i en prepositionell
         *   fras (dvs någon fras utöver den första) som ett adjektiv,
         *   eftersom det effektivt modifierar huvudfrasen: en "hög med
         *   papper" är effektivt en pappershög; en "nyckel till ytterdörren
         *   av huset" är effektivt en ytterdörrshusnyckel.  
         */
        local firstPhrase = true;
        for ( ; i <= wlen ; ++i)
        {
            /* få detta ord och nästa */
            local w = wlst[i].trim();
            local wnxt = (i + 1 <= wlen ? wlst[i+1] : nil);

            /* 
             *   Om detta ord är en av våra prepositioner, ange det utan
             *   en ordklass - det räknas inte som en match när
             *   parsning av inmatning, eftersom det är så ospecifikt.  
             *   
             *   Om *nästa* ord är en preposition, eller om det inte finns något nästa
             *   ord, är detta det sista ordet i en underfras. Om detta är
             *   den första underfrasen, ange ordet som ett substantiv.
             *   Annars, ange det som ett adjektiv.  
             */
            local pos;
            if (rexMatch(prepWordPat, w) != nil)
            {
                /* det är en preposition */
                pos = MatchPrep;

                /* 
                 *   Om nästa ord är en artikel, hoppa över det. Artiklar i
                 *   namnfrasen räknas inte som vokabulärord, eftersom
                 *   parsern tar bort dessa när den matchar objekt till
                 *   inmatning. (Det betyder inte att parsern ignorerar
                 *   artiklar, dock. Den analyserar dem i inmatning och
                 *   respekterar den betydelse de förmedlar, men den gör det
                 *   internt, vilket sparar objektets namn-matchare besväret
                 *   att hantera dem.)  
                 */
                if (wnxt is in ('en', 'ett', 'den', 'det', 'några'))
                    ++i;
            }
            else if (rexMatch(weakWordPat, w) != nil)
            {
                /* Det är en svag token */
                pos = MatchWeak;
            }
            
            else if (firstPhrase
                     && (wnxt == nil || rexMatch(prepWordPat, wnxt) != nil))
            {
                /* det är det sista ordet i den första frasen - det är ett substantiv */
                pos = MatchNoun;

                /* vi har precis lämnat den första frasen */
                firstPhrase = nil;
            }
            else
            {
                /* allt annat är ett adjektiv */
                pos = MatchAdj;
            }

            /* ange ordet under den ordklass vi bestämde oss för */
            initVocabWord(w, pos);
        }

        
        /* den andra sektionen är listan över adjektiv */
        if (parts.length() >= 2 && parts[2] != '') 
        {
            parts[2].split(' ').forEach(
                {x: initVocabWord(x.trim(), MatchAdj)});
            
#ifdef __DEBUG
            /* 
             *   Om vi kompilerar för felsökning, utfärda en varning om ett pronomen
             *   visas i adjektivsektionen. Vi utesluter 'hennes' från
             *   listan över pronomener vi testar för här eftersom 'hennes' i adjektivsektionen
             *   kan vara avsedd som det kvinnliga possessiva pronomenet. Men
             *   utför endast denna kontroll för en Thing, eftersom en Topic kan
             *   lagligt ha pronomener i vilken sektion som helst.
             */
            parts[2].split(' ').forEach(function(x){
                if(ofKind(Thing) && x is in ('honom', 'det', 'dem', 'dem!'))
                {
                    "<b><FONT COLOR=RED>VARNING!</FONT></B> ";
                    "Pronomen '<<x>>' visas i adjektivsektionen (efter första
                    semikolonet) av vocab strängen '<<vocab>>'. Detta kan betyda att
                    vocab strängen har för få semikolon.\n";
                }
                
            });
#endif
            
        }


        /* den tredje sektionen är listan över substantiv */
        if (parts.length() >= 3 && parts[3] != '')
        {            
            parts[3].split(' ').forEach(
                {x: initVocabWord(x.trim(), MatchNoun)});
            
#ifdef __DEBUG
            /* 
             *   Om vi kompilerar för felsökning, utfärda en varning om ett pronomen
             *   visas i substantivsektionen.
             */
            parts[3].split(' ').forEach(function(x){
                if(ofKind(Thing) && x is in ('honom', 'henne', 'det', 'dem', 'dem!'))
                {
                    "<b><FONT COLOR=RED>VARNING!</FONT></B> ";
                    "Pronomen '<<x>>' visas i substantivsektionen (efter andra
                    semikolonet) av vocab strängen '<<vocab>>'. Detta betyder förmodligen
                    att denna vocab sträng har för få semikolon.\n";
                }
                
            });
#endif
        }


            
            /* den fjärde sektionen är listan över pronomener */
            if (parts.length() >= 4 && parts[4] != '')
            {
                local map = [
                    'det', &isIt,
                    'den', &isIt,
                    'honom', &isHim,
                    'henne', &isHer,
                    'dem', &plural,
                    'dem!', &isGenderNeutral ];
                
                local explicitlySingular = nil;
                
                               
                parts[4].split(' ').forEach(function(x) {
                    
                    local i = map.indexOf(x.trim());
                    if (i != nil)
                        self.(map[i+1]) = true;
                    
                    if(x.trim() != 'dem')                    
                        explicitlySingular = true;     
                                          
                });
                
                /* 
                 *   Om vi är både uttryckligen singular och plural (dvs både ett
                 *   singular pronomen och 'dem' har visats i vår pronomen
                 *   lista) måste vi vara tvetydigt plural.
                 */
                
                if(explicitlySingular && plural)
                {
                    ambiguouslyPlural = true;
                    
                    /* 
                     *   Vi är faktiskt plural endast om 'dem' är det första
                     *   pronomenet som påträffas; så om det inte är det är vi faktiskt
                     *   singular.
                     */
                    
                    if(!parts[4].trim().startsWith('dem'))
                        plural = nil;
                    
                }
#ifdef __DEBUG
            /* 
             *   Om vi kompilerar för felsökning, utfärda en varning om en
             *   något annat än ett pronomen visas i pronomen sektionen.
             */
            parts[4].split(' ').forEach(function(x){
                if(x not in ('honom', 'henne', 'den', 'det', 'dem', 'dem!'))
                {
                    "<b><FONT COLOR=RED>VARNING!</FONT></B> ";
                    "Icke-pronomen '<<x>>' visas i pronomen sektionen (efter tredje
                    semikolonet) av vocab strängen '<<vocab>>'. Kontrollera att denna
                    vocab sträng inte har för många semikolon.\n";
                }
                
            });
#endif
            }
        
        

            
        /* gör om vocabWords till en lista */
        vocabWords = vocabWords.toList();


        /* 
         *   Om det inte finns någon 'name' egenskap redan, tilldela namnet från
         *   kortnamnssträngen. Ta bort eventuella specialannoteringar
         *   för ordklasser eller pluralformer. 
         */
        if (name == nil && tentativeName != '')
            name = tentativeName.findReplace(deannotatePat, '', ReplaceAll);


        local isNeuterDefinedAlready = propDefined(&isNeuter, PropDefDirectly);

        // Såvida inte isNeuter tilldelas redan
        if(!isNeuterDefinedAlready && definiteForm) {
            // Avgör utrum/neutrum baserat på den definitiva formens ändelse
            local isUterEnding = definiteForm.endsWith('n') || definiteForm.endsWith('na');
            isNeuter = !isUterEnding;
        }

        /*
        TODO: frågan är om detta behövs eller ej - theName sköter detta via qualified-flaggan
        if(proper && definiteForm == nil) {
            definiteForm = name;
        }
        */

    }

    /* 
     *   mönster för att upptäcka ett egennamn - varje ord börjar med en
     *   versal 
     */
    properNamePat = R'(<upper><^space>*)(<space>+<upper><^space>*)*'

       
    /*   
     *   Ärva vocab från våra superklasser enligt följande schema:
     *.  1. Ett + tecken i namnsektionen kommer att ersättas med namnet från vår
     *   superklass.
     *.  2. Om inte adjektiv- och substantivsektionen börjar med ett -, kommer alla
     *   adjektiv och substantiv från våra superklassers vocab att läggas till i respektive
     *   sektion.
     *.  3. Om vår pronomen sektion är tom eller innehåller ett +, ärva pronomener
     *   från vår superklass, annars lämna den oförändrad.
     */
    inheritVocab()
    {
        /* 
         *   Om vi inte har något vocab, finns det inget arbete att göra.
         */
        if(vocab == nil || vocab == '')            
            return;
        
        
        foreach(local cls in getSuperclassList)
        {   
            /* 
             *   Om superklassen inte anger något vocab, behöver vi inte
             *   bearbeta det.
             */
            if(cls.vocab not in (nil, ''))
                continue;
            
            /* Den ärvda vocab, uppdelad i delar */               
            cls.inheritVocab();
        }
          
        
        /* 
         *   Om vi inte definierar vår egen vocab egenskap direkt, finns det inget mer
         *   arbete att göra; allt har gjorts på våra föräldraklasser. Det finns också
         *   inget mer arbete att göra om ingen av våra föräldraklasser definierar något vocab.
         */
        if(!propDefined(&vocab, PropDefDirectly) 
           || getSuperclassList.indexWhich({c: c.vocab not in (nil, '')}) == nil)
            return;
        
        /* Vår lista över vocab, uppdelad i delar. */
        local vlist = vocab.split(';').mapAll({x: x.trim()});
        
        /* för bekvämlighet, se till att vi slutar med fyra delar */
        for(local i = vlist.length; i < 4; i++)
            vlist += '';
        
        foreach(local cls in getSuperclassList)
        {  
            /* 
             *   Om denna klass inte anger något vocab, behöver vi inte
             *   bearbeta det.
             */
            if(cls.vocab is in (nil, ''))
                continue;
            
            /* Den ärvda vocab, uppdelad i delar */               
            local ilist = cls.vocab.split(';').mapAll({x: x.trim()});
            
            /* För bekvämlighet, se till att vi har fyra delar. */
            for(local i = ilist.length; i < 4; i++)
                ilist += '';
        
            /* Ersätt eventuellt + tecken i den första delen med det ärvda namnet */
            vlist[1] = vlist[1].findReplace('+', ilist[1]);
            
            /* 
             *   För den andra och tredje delen, om de inte börjar med -, lägg till
             *   de ärvda adjektiven och substantiven.
             */
            
            for(local i in 2..3)
            {
                if(!vlist[i].startsWith('-'))
                    vlist[i] = vlist[i] + ' ' + ilist[i];
            }
            
            /* 
             *   För den fjärde (pronomen) delen, lägg till eventuella ärvda pronomener endast om
             *   vi inte har några egna eller det finns ett + i pronomen delen
             */
            
            if((vlist[4] == '' || vlist[4].find('+') != nil) && ilist[4] != '')
                vlist[4] = vlist[4] + ' ' + ilist[4];
            
        }
        
        /* Ta bort eventuella ledande - i delarna 2 och 3 */
        for(local i in 2..3)
        {
            if(vlist[i].startsWith('-'))
                vlist[i] = vlist[i].substr(2);
        }
        
        /* Ta bort eventuella + i del 4 */
        vlist[4] = vlist[4].findReplace('+', '');
            
        /* Sätt ihop listan tillbaka till en vocab sträng */
        vocab = vlist.join(';');
    }
    
    
    
    
    
    /* 
     *   Initiera vokabulär för ett ord från 'vocab' listan. 'w' är
     *   ordtexten, med valfria ordklass- och pluralforms
     *   annoteringar ([nr] [nt], [n], [pn], [adj], [prep], [pl], (-s)). Det kan också ha en
     *   specialflagga som sitt sista tecken: '=' för en exakt
     *   matchning (ingen trunkering och inga teckenapproximationer), eller '~' för
     *   oskarpa matchningar (trunkering och approximation tillåten).
     *   
     *   'matchFlags' är en kombination av MatchXxx värden. Detta bör
     *   minimalt tillhandahålla ordklassen som en av MatchAdj,
     *   MatchNoun, eller MatchPlural. Du kan också inkludera MatchNoTrunc för
     *   att ange att användarinmatning endast kan matcha detta ord utan någon
     *   trunkering, och MatchNoApprox för att ange att inmatning endast kan matcha
     *   utan teckenapproximationer (t.ex. 'a' som matchar 'a-umlaut').
     */
    



    //-------------------------------
    // Hantering av sammansatta ord. 
    //-------------------------------
    // Nu inledningsvis används bara splitWithDelimiterPattern för att dela upp 
    // ett ord i dels sin huvudform, dels med ändelse. Till detta 
    // behövs bara wordPartDelPat. 

    // Tillåter sammansatt ord med '+' som avskiljare, med ändelsen sist
    // t ex: 'vit+a sten+en' blir ajektiv: vit, vita och substantiv sten, stenen
    // t ex: 'vit+a sten+en' blir ajektiv: vit, vita och substantiv sten, stenen
    combineVocabWords = true 

    // Om true, kortas 3 eller fler i följd upprepande tecken ner till 2, 
    // från alla ord som skapas med combineVocabWords
    enableShortenRepeatingCharacters = true 

    tripleLetterPat = static new RexPattern('.*?((<Alpha>)%2{2,}).*')
    wordPartDelPat = static new RexPattern('(.*?)(<vbar|dollar>)')
    plusNotationPat = static new RexPattern('.+(<vbar|dollar>.+)+')

    //-------------------------------
    definiteForm = nil // Det definitiva ordet
    //-------------------------------
    
    initVocabWord(w, matchFlags)
    {
        // anta att detta kommer att anges i ordboken som ett substantiv 
        local partOfSpeech = &noun;


        /* 
         *   om det finns en uttrycklig ordklassannotering, åsidosätter den
         *   den antagna ordklassen 
         */
        if (w.find(posPat) != nil)
        {
            /* rensa de gamla ordklassflaggorna */
            matchFlags &= ~(MatchPrep | MatchAdj | MatchNoun | MatchPlural | MatchWeak 
                            /*| MatchGenusFormR | MatchGenusFormT
                            */
                            );
            
            local ann = rexGroup(1)[3];
            
            /* notera den nya ordklassen */
            switch (ann)
            {
            case 'n':
            case 'pn':
                matchFlags |= MatchNoun;
                break;

            case 'adj':
                matchFlags |= MatchAdj;
                break;
 
            case 'weak':    
                matchFlags |= MatchWeak;
                break;
                
            case 'prep':                
                matchFlags |= MatchPrep;
                break;

            case 'pl':
                matchFlags |= MatchPlural;
                break;
            }

            /* ta bort annoteringen från ordsträngen */
            w = w.findReplace(posPat, '', ReplaceOnce);
            
            /* Om w har markerats som ett plural substantiv, lägg till det i våra plural tokens. */
            if(ann == 'pn')
                pluralTokens = valToList(pluralTokens).appendUnique([w]);
        }

        // Vi kollar både om flaggan combineVocabWords är satt till true 
        // likväl som att mönstret faktiskt används. 
        // Används det inte, gör vi som vanligt

        if(combineVocabWords) {
            local matchCombineVocabWordsNotation = rexMatch(plusNotationPat, w);
            
            if(!matchCombineVocabWordsNotation) {
                // Ord utan kombination får antas komma i qualified-form, 
                // så som "David" eller "fröken Ur"
                // qualified = true;
                // definiteForm = w;
                if(!propDefined(&name, PropDefDirectly)) {
                    name = w;
                }
                addDictWord(w, partOfSpeech, matchFlags); 
            } else {
                local forms = createCompoundWordVariations(self, w, partOfSpeech, matchFlags, enableShortenRepeatingCharacters);
                w = forms.standardForm;

                // Såvida inte &name, &definiteForm tilldelats redan, använd värdena från resultatet
                if(partOfSpeech == &noun) {
                    if(!propDefined(&name, PropDefDirectly)) {
                        name = forms.standardForm;
                    }
                    if(!propDefined(&definiteForm, PropDefDirectly)) {
                        definiteForm = forms.definiteForm; 
                    }
                }
            }
        }

        /* 
         *   Om vi kompilerar för felsökning, försök att varna författaren om eventuella olagliga
         *   ordklassetiketter som oavsiktligt kan ha smugit sig in i en vocab
         *   sträng.
         */
#ifdef __DEBUG
    else if(w.find(R'<lsquare>.*<rsquare>') != nil && !w.endsWith('s'))
    {
        "<B><FONT COLOR=RED>VARNING!</FONT></B> ";
        "Olaglig ordklassetikett för '<<w>>' i vocab strängen '<<vocab>>'\n";
    }
        
#endif        
        

        /* 
         *   om detta är ett adjektiv som slutar med apostrof-S, använd den formen
         *   av ordet 
         */
//        if (rexMatch(apostSPat, w))
//        {
//            /* notera det befintliga värdet av w*/
//            local wOld = w;
//            
//            /* 
//             *   ta bort apostrof-S, eftersom tokenizern kommer att göra
//             *   detta när den analyserar inmatningen 
//             */
//            w = rexGroup(1)[3];
//
//            /* markera det som ett apostrof-S ord i ordboken */
//            partOfSpeech = &nounApostS;
//                      
//            w += '^s';
//            
//            apostropheSPreParser.addEntry(wOld, w);
//        }
        
        if (rexMatch(apostSPat, w))
        {
            /* markera det som ett apostrof-S ord i ordboken */
            partOfSpeech = &nounApostS;
            
            /* 
             *   Lägg till ett ordboksord utan apostrof-S, eftersom tokenizern kommer att separera
             *   apostrof-S som en separat token, därför behöver vi kunna slå upp basordet i
             *   ordboken. Men fortsätt sedan med vår vanliga hantering med
             *   hela ordet också, eftersom parsern kommer att sätta ihop
             *   hela token med apostrof-S för den faktiska substantivfras
             *   matchningen.
             */
            cmdDict.addWord(dictionaryPlaceholder, rexGroup(1)[3],
                            partOfSpeech);
        }
        
        
        /* om det finns en plural annotering, notera det */
        if ((matchFlags & MatchPlural) != 0
            || partOfSpeech == &nounApostS)
        {
            /* 
             *   Antingen är detta redan markerat som en plural, eller så har det en
             *   apostrof-S. I båda fallen är det redan så böjt
             *   som ett svenskt ord kan bli, så vi vill inte försöka
             *   böja det ytterligare med en plural bildning.  
             */
        }
        else if (w.find(pluralPat) != nil)
        {
            /* det finns en uttrycklig plural - hämta den */
            local pl = rexGroup(1)[3];

            /* ta bort det ur strängen */
            w = w.findReplace(pluralPat, '', ReplaceOnce);

            /* dela upp list elementen, om det finns flera poster */
            pl = pl.split(',').mapAll({x: x.trim()});

            /* för varje plural som ges som ett suffix, lägg till det till ordet */
            pl = pl.mapAll({x: x.startsWith('-') ? w + x.substr(2) : x});

            /* lägg till varje plural; anta att trunkering inte är tillåten */
            pl.forEach({x: initVocabWord(x, MatchPlural | MatchNoTrunc)});
        }

        /*
        
        OBS: bortkommenterad del för härledd plural. 
        I svenskan vill vi troligen aldrig härleda plural då det enbart går
        att komma nära med hjälp av heurestik. 
        else if (nil && matchFlags == MatchNoun && rexMatch(properPat, w) == nil)
        {
        */
            /* 
             *   det är ett substantiv, det är inte ett egennamn, och ingen plural form
             *   angavs uttryckligen, så härled en 
             */
            // local pl = [pluralWordFrom(w, '\'')];

            /* 
             *   om det är en akronym eller ett nummer, lägg till apostrof-s plural
             *   som ett alternativ (1990's, LCD's) 
             */
            /*
            if (rexMatch(acronymPluralPat, w) != nil
                || w.length() == 1)
                pl += ['<<w>>s'];
            */
            /* 
             *   Om det är en oregelbunden plural form, lägg till eventuella variationer.
             *   (Den första oregelbundna kommer redan att ha plockats upp, så
             *   vi behöver bara lägga till den andra och andra variationer här.)
             */
            /*
            local irr;
            if ((irr = irregularPlurals[w]) != nil && irr.length() > 1)
                pl += irr.sublist(2);
            */
            /* 
             *   Ta bort det ursprungliga ordet från plural listan, om det
             *   finns där. Vissa ord är sina egna pluraler, såsom "fisk"
             *   eller "får". Praktiskt taget är det bättre att behandla
             *   dessa ord som singular i parsern. Det är lätt att
             *   uttryckligen göra en fras plural: du sätter bara ALLT framför
             *   det (LÄGG ALLA FISKAR I SKÅLEN). Men det finns ingen motsats; om
             *   vi behandlade FISK som plural, skulle det inte finnas något bra sätt att
             *   singularisera det när du bara ville prata om en
             *   fisk.
             *   
             *   (Observera att vi måste ta bort dessa ord här. Vi vill inte
             *   ta bort dem från listan över oregelbundna pluraler,
             *   eftersom vi också använder den listan för att syntetisera plural namn,
             *   och vi vill definitivt ha rätt ord för det ändamålet.
             *   Vi vill inte heller ta bort dem i initVocabWord(),
             *   eftersom spelet kan anropa det för att uttryckligen lägga till en
             *   plural som matchar ett substantiv. Den rätta platsen att ta bort
             *   dem är precis här, eftersom vi bara vill ta bort dem
             *   från implicit genererade listor över vokabulär pluraler.)  
             */
            // pl -= w;

            /* lägg till varje plural; anta att trunkering inte är tillåten */
            // pl.forEach({x: initVocabWord(x, MatchPlural | MatchNoTrunc)});
        // }

        /* kontrollera för exakta och inexakta flaggor */
        if (w.endsWith('='))
        {
            matchFlags |= MatchNoTrunc | MatchNoApprox;
            w = w.left(-1);
        }
        else if (w.endsWith('~'))
        {
            matchFlags &= ~(MatchNoTrunc | MatchNoApprox);
            w = w.left(-1);
        }

        // Detta tas om hand av createCompoundWordVariations
        // om combineVocabWords är aktiv:
        if(!combineVocabWords) {
            /* lägg till detta ord till ordboken och till vår interna vokabulärlista */
            addDictWord(w, partOfSpeech, matchFlags); 
        }
    }

    getNeuterForm(word) {
        local lastTwoChars = word.substr(word.length()-1);
        local isLastCharVocal = (word.lastChar().match(vocalPat) != nil);
        // TESTA avgör om sista bokstaven är en vokal, isåfall bara 't', annars 'et'
        // TODO: matcha hellre mot regex-uttryck här []
        local form = (lastTwoChars == 'et' || lastTwoChars == 'at' )
            ? '' 
            : isLastCharVocal ? 't' : 'et';
        return '<<word>><<form>>';
    }
    
    getUterForm(word) {
        local lastTwoChars = word.substr(word.length()-1);
        local isLastCharVocal = (word.lastChar().match(vocalPat) != nil);

        // TESTA avgör om sista bokstaven är en vokal, isåfall bara 'n', annars 'en'
        // Gör inget om ordet redan slutar på 'an' eller 'en'
        // TODO: matcha hellre mot regex-uttryck här []
        local form = (lastTwoChars == 'en' || lastTwoChars == 'an' )
            ? '' 
            : isLastCharVocal ? 'n' : 'en';
        return '<<word>><<form>>';
    }

    /* mönster för apostrof-s ord */
    apostSPat = R'^(.*)(\'|&rsquo;|\u2019)s$'

    /* 
     *   Lägg till ett ord till ordboken och till vår vokabulärlista för de
     *   givna matchningsflaggorna.  
     */
    addDictWord(w, partOfSpeech, matchFlags)
    {
        /* för ordbokssyften, vill vi ha allt i gemener */
        w = w.toLower();

        /* 
         *   Lägg till det till ordboken. Observera att vår parser inte använder
         *   ordbokens objektassocieringsfunktion; men vi behöver *något* objekt för posten, så använd
         *   ordbokens platshållarobjekt som det associerade objektet. Att använda platshållaren
         *   minimerar ordbokens minnesbehov genom att skapa endast en post för varje ord.  
         */
        cmdDict.addWord(dictionaryPlaceholder, w, partOfSpeech);

        /* lägg till det till vår interna vokabulärlista */
        vocabWords = vocabWords.append(new VocabWord(w, matchFlags));
    }

    /* 
     *   initiera om vokabulären för detta objekt från början, med hjälp av strängen
     *   voc istället för den ursprungliga vocab egenskapen. 
     */
    
    replaceVocab(voc)
    {
        /* rensa ut det befintliga namnet */
        name = nil;
        
        /* Återställ till nil de olika egenskaper som kan ställas in av initVocab() */
        proper = nil;
        
        /* 
         *   Notera att vi ersätter vocab så att initVocab kan ställa in proper till true om det är lämpligt
         */
        replacingVocab = true;
        
        /* Återställ andra vocab egenskaper till nil. */
        plural = nil;
        ambiguouslyPlural = nil;
        isHim = nil;
        isHer = nil;
        isGenderNeutral = nil;
        massNoun = nil;
        isNeuter = nil;
        
        /* Återställ standarduttrycket för qualified. */
        setMethod(&qualified, {: proper });
        
        /* Återställ standarduttrycket för isIt. */
        setMethod(&isIt, { : !(isHim || isHer || isGenderNeutral)} );
        
        
        /* Ställ in vår vocab egenskap till vocab vi ersätter den med */
        vocab = voc;
       
        /* Rensa ut eventuella befintliga vocabWords */
        vocabWords = [];
        
        /* Initiera vokabulären igen */
        initVocab();
    }
    
    /* 
     *   Flagga för internt bruk endast; ersätter vi vocab? Metoden replaceVocab() ställer in detta till
     *   true för användning av initVocab().
     */
    replacingVocab = nil
                 
    /*  
     *   Lägg till ytterligare vokabulärord till de som redan används för detta objekt. Om
     *   vi anger namn delen kommer detta att ersätta det befintliga namnet för
     *   objektet.
     */
    addVocab(voc)
    {
        /* 
         *   Kontrollera först om vi har något i namn delen. Om så är fallet, anta
         *   att det är avsett att ersätta det befintliga namnet.
         */
        local parts = voc.split(';');
        if(parts[1] > '')
            name = nil;
        
        /* 
         *   Notera de befintliga vocabWords, eftersom de kommer att åsidosättas
         *   när vi lägger till de nya.
         */
        local vocWords = vocabWords;
        
        /*   Kopiera den nya vocab strängen till vår vocab egenskap. */
        vocab = voc;
        
        /*  Initiera våra vocabWords med hjälp av den nya strängen. */
        initVocab();
        
        /*  Lägg tillbaka våra gamla vocabWords, utan några dubbletter */
        vocabWords = vocabWords.appendUnique(vocWords);
        
    }
    
    
    /* 
     *   Ta bort ett ord från detta objekts vokabulär. Om matchFlags
     *   parametern anges bör den vara en av MatchNoun, MatchAdj,
     *   MatchPrep eller MatchPlural, i vilket fall endast VocabWords som matchar den
     *   motsvarande ordklassen (samt ord) kommer att tas bort.
     */
    removeVocabWord(word, matchFlags?)
    {
        if(matchFlags)            
            vocabWords = vocabWords.subset({v: v.wordStr != word || v.posFlags !=
                                           matchFlags});
        else
            vocabWords = vocabWords.subset({v: v.wordStr != word});
    }
    
    addVocabWord(word, matchFlags)
    {
        initVocabWord(word, matchFlags);
    }
    
    /* 
     *   Regelbunden uttrycksmönster för att matcha ett enda prepositionsord.
     *   Ett ord är en preposition om det finns i vår prepositionslista, ELLER det är
     *   uttryckligen annoterat med "[prep]" i slutet. 
     */
    prepWordPat = static new RexPattern(
        '^(<<prepList>>)$|.*<lsquare>prep<rsquare>$')
    
    weakWordPat = static new RexPattern(
        '.*<lsquare>weak<rsquare>$')

    /* prepositionslista, som ett regelbundet uttryck ELLER mönster */
    prepList = 'till|av|från|med|för'

    /* regelbundet uttryck för att ta bort annoteringar från ett kortnamn */
    deannotatePat =
        R"<lsquare><alpha>+<rsquare>|<lbrace><alphanum|-|'|,|~|=>+<rbrace>"

    /* mönster för ordklassannoteringar */
    //posPat = R'<lsquare>(en|n|pn|adj|pl|prep|weak)<rsquare>'
    posPat = R'<lsquare>(nr|nt|n|pn|adj|pl|prep|weak)<rsquare>' // nr/nt - substantiv + genus (en/ett)

    vocalPat = R'[aeiouy]' // nr/nt - substantiv + genus (en/ett)

    /* mönster för pluralannoteringar */
    pluralPat = R"<lbrace>(<alphanum|-|'|space|,|~|=>+)<rbrace>"

    /* 
     *   mönster för egennamn: börjar med en versal, och minst en
     *   gemen bokstav inom 
     */
    properPat = R'^<upper>(.*<lower>.*)'

    /*
     *   Generera det "distingerade namnet" för detta objekt, givet en lista över
     *   Distinguisher objekt som vi använder för att skilja det från
     *   andra i en lista.
     *   
     *   'article' anger vilken typ av artikel som ska användas: Bestämd
     *   ("den"), Obestämd ("en", "ett", "några"), eller nil (ingen artikel).
     *   'distinguishers' är en lista över Distinguisher objekt som används
     *   för att identifiera detta objekt unikt. Vårt jobb är att utarbeta
     *   objektets namn med alla kvalificerande fraser som antyds av
     *   distinguishers.
     *   
     *   [Required] 
     */
    distinguishedName(article, distinguishers)
    {
        //tadsSay('[distinguishedName]');
        local ret;

        /* notera vilka distinguishers som finns */
        local dis = distinguishers.indexOf(disambigNameDistinguisher) != nil;
        local poss = distinguishers.indexOf(ownerDistinguisher) != nil;
        local loc = distinguishers.indexOf(locationDistinguisher) != nil;
        local cont = distinguishers.indexOf(contentsDistinguisher) != nil;

        /* 
         *   börja med kärnnamnet: detta är antingen basnamnet eller
         *   disambiguation namnet, beroende på om det finns en
         *   disambigNameDistinguisher i listan 
         */
        ret = (dis ? disambigName : name);

        /* lägg till eventuella tillståndsadjektiv */
        foreach (local d in distinguishers)
        {
            if (d.ofKind(StateDistinguisher))
                ret = d.state.addToName(self, ret);
        }

        /* lägg till det possessiva, om det inte är ett kvalificerat namn */      
        if (poss && !qualified)
        {
            local o = nominalOwner();
            if (o != nil)
                ret = nominalOwner().possessify(article, self, ret);
            // Om detta objekt är oägt och ingen lokational distinguisher finns
            // och objektet ligger på marken, måste vi fortfarande beskriva det.
            else if (!loc && self.location == gActor.getOutermostRoom())
            {
                ret = self.location.locify(self, ret);
            }
        }    

        /* lägg till innehållskvalificeraren */
        if (cont)
        {
            local c = nominalContents();
            if (c != nil)
                ret = c.contify(self, ret);
            else
                ret = 'tom <<ret>>';
        }

        /* lägg till den lokationala kvalificeraren */
        if (loc)
        {
            if (location != nil)
                ret = location.locify(self, ret);
        }

        /* 
         *   Om en artikel önskas, lägg till den. Undantag: lägg inte till en
         *   bestämd artikel om det finns en possessiv, eftersom possessiven
         *   tar platsen för den bestämda artikeln. 
         */
        if (article == Indefinite)
            ret = (poss ? aNameFromPoss(ret) : aNameFrom(ret));
        else if (article == Definite && !poss)
            ret = theNameFrom(ret);

        /* returnera resultatet */
        return ret;
    }

    /*
     *   Generera ett possessivt namn för ett objekt som vi äger, givet en
     *   sträng under konstruktion för objektets namn. 'obj' är det
     *   objekt vi äger ('self' är ägaren), och 'str' är namnsträngen under
     *   konstruktion, utan några possessiva eller artikel
     *   kvalificerare ännu.
     *   
     *   Observera att vi måste lägga till 'str', inte basnamnet på
     *   objektet. Vi kanske använder en variation på namnet (såsom
     *   disambiguation namnet), eller vi kanske redan har prytt namnet
     *   med andra kvalificerare.  
     *   
     *   'article' anger användningen: Bestämd, Obestämd, eller nil för ingen
     *   artikel. Vi lägger INTE faktiskt till artikeln här; snarare, detta
     *   berättar för oss formen som namnet kommer att ta när anroparen är klar
     *   med det, så vi bör använda en lämplig form av possessiv
     *   frasering i den mån den varierar beroende på artikel. På svenska
     *   varierar det. I det bestämda fallet, ersätter possessiven
     *   effektivt artikeln: "boken" blir "Bobs bok". I det obestämda
     *   fallet, måste possessiven omformuleras prepositionellt så att
     *   artikeln fortfarande kan inkluderas: "en bok" blir "en bok av Bobs".
     *   Mass substantiv är ett ytterligare specialfall: "några vatten"
     *   blir "några av Bobs vatten".
     *   
     *   Standardbeteendet är som följer. I det bestämda fallet, returnerar vi
     *   "<name>'s <string>". I det obestämda fallet, returnerar vi "<string> av
     *   <name>" (för ett slutresultat som "en bok av Bobs").
     */
    possessify(article, obj, str)
    {
        /*
         *   Bestämd: bok -> Bobs bok -> Bobs bok
         *.  Ingen artikel: bok -> Bobs bok -> Bobs bok
         *.  Obestämd mass substantiv: vatten -> Bobs vatten -> några av Bobs vatten
         *.  Obestämd räkne substantiv: bok -> bok av Bobs -> en bok av Bobs
         */
        if (article is in (Definite, nil)
            || (article == Indefinite && obj.massNoun)) {
            local poss = obj.plural   ? possAdjPl
                       : obj.isNeuter ? possAdjT
                       :                possAdj;
            return '<<poss>> <<str>>';
        }
        else
            return '<<str>> av <<possNoun>>';
    }

    /*
     *   Applicera en lokational kvalificerare på namnet för ett objekt som finns
     *   inom mig. 'obj' är objektet (något bland mitt innehåll), och
     *   'str' är namnsträngen under konstruktion. Vi lägger till den lämpliga
     *   prepositionella frasen: "lådan UNDER BORDET".  
     */
    locify(obj, str)
    {        
        if (obj.location == gActor.getOutermostRoom()
            && obj.location.floorObj != nil)
            return '<<str>> <<obj.location.floorObj.objInName>> ';
        else
            return '<<str>> <<obj.locType.prep>> <<theName>>';
    }

    /*
     *   Applicera en innehållskvalificerare på namnet för min behållare. 'obj' är
     *   objektet (min behållare), och 'str' är namnsträngen under
     *   konstruktion. Vi lägger till den lämpliga prepositionella frasen:
     *   "hinken MED VATTEN".  
     */
    contify(obj, str)
    {
        return '<<str>> med <<name>>';
    }

    /*
     *   Applicera en obestämd artikel ("en låda", "ett äpple", "några ludd") på
     *   den givna namnsträngen 'str' för detta objekt. Vi försöker lista ut
     *   vilken obestämd artikel som ska användas baserat på vilken typ av substantiv
     *   fras vi använder för vårt namn (singular, plural, eller ett "mass substantiv"
     *   som "ludd"), och vår stavning.
     *   
     *   Som standard använder vi artikeln "en" om namnet börjar med en
     *   konsonant, eller "ett" om det börjar med en vokal.
     *   
     *   Om namnet börjar med ett "y", tittar vi på den andra bokstaven; om
     *   det är en konsonant, använder vi "ett", annars "en" (därav "ett yttrium
     *   block" men "en gul tegelsten").
     *   
     *   Om objektet är markerat som ett mass substantiv eller har plural användning, använder vi
     *   "några" som artikeln ("några vatten", "några buskar"). Om
     *   strängen har en possessiv kvalificerare, gör vi det till "några av"
     *   istället ("några av Bobs vatten").
     *   
     *   Vissa objekt vill åsidosätta standardbeteendet, eftersom
     *   de lexikala reglerna om när man ska använda "en" och "ett" inte är utan
     *   undantag. Till exempel, tysta-"h" ord ("heder") skrivs
     *   med "ett", och "h" ord med ett uttalat men svagt betonat
     *   initialt "h" används ibland med "ett" ("ett historiker"). Också,
     *   vissa 'y' ord kanske inte följer den generiska 'y' regeln.
     *   
     *   'U' ord är särskilt sannolika att inte följa någon lexikal regel -
     *   alla 'u' ord som låter som om de börjar med 'y' bör använda 'en'
     *   istället för 'ett', men det finns inget bra sätt att lista ut det bara
     *   genom att titta på stavningen (tänk på "oansenlig", " oviktig
     *   ord", eller "en enhällig beslut" och "ett oansenlig man").  
     */
    aNameFrom(str)
    {
        if (qualified)
            return str;
        if (massNoun)
            return str;
        if (plural)
            return 'några <<str>>';
        return isNeuter ? 'ett <<str>>' : 'en <<str>>';
    }

    /*
     *   Hämta det obestämda namnet för en version av vårt namn som har en
     *   possessiv kvalificerare. Anroparen är ansvarig för att säkerställa att
     *   possessiven redan är i ett lämpligt format för att lägga till en
     *   obestämd artikel - vanligtvis något som "bok av Bobs", så
     *   att vi kan göra detta till "en bok av Bobs".
     *   
     *   På svenska finns det ett specialfall där den vanliga obestämda
     *   namnformatet skiljer sig från possessivformatet, vilket är varför vi
     *   behöver denna separata metod i den svenska modulen. Specifikt, om
     *   basnamnet är ett plural eller mass substantiv, måste vi använda "några av"
     *   i possessivfallet, snarare än det vanliga "några": "några vatten"
     *   i det vanliga fallet, men "några av Bobs vatten" i possessiv
     *   fallet.  
     */
    aNameFromPoss(str)
    {
        /* 
         *   för mass substantiv och pluraler, använd "några av"; annars använd den
         *   vanliga a-namnet 
         */
        return (massNoun || plural ? 'några av <<str>>' : aNameFrom(str));
    }

    /* 
     *   uppslagstabell över specialfall a/an ord (vi bygger detta
     *   automatiskt under classInit från CustomVocab objekt) 
     */
    specialAOrAn = nil

    /* förkompilera några regelbundna uttryck för aName */
    tagOrQuotePat = R'[<"\']'
    leadingTagOrQuotePat = R'(<langle><^rangle>+<rangle>|"|\')+'
    firstWordPat =
        R'(?:<langle><^rangle>+<rangle>|"|\'|<space>)*(<alphanum>+)%>'
    oneLetterWordPat = R'<alpha>(<^alpha>|$)'
    oneLetterAnWordPat = R'<nocase>[aefhilmnorsx]'
    alphaCharPat = R'<alpha>'
    elevenEighteenPat = R'1[18](<^digit>|$)'

    /*
     *   Hämta pluralformen av det givna namnet. Om strängen slutar med
     *   vokal-plus-'y' eller något annat än 'y', lägger vi till ett 's';
     *   annars ersätter vi 'y' med 'ies'. Vi hanterar också
     *   förkortningar och enskilda bokstäver speciellt.
     *   
     *   Detta kan bara hantera enkla adjektiv-substantiv former. För mer
     *   komplicerade former, särskilt för sammansatta ord, måste det åsidosättas
     *   (t.ex. "Attorney General" -> "Attorneys General",
     *   "man-of-war" -> "men-of-war"). Vi känner igen en ganska omfattande
     *   uppsättning specialfall (barn -> barn, man -> män), som anges i
     *   oregelbundna plural listorna i eventuella CustomVocab objekt. Lägg till nya
     *   objekt till listan över oregelbundna pluraler genom att skapa en eller flera
     *   CustomVocab objekt med sina egna oregelbundna plural listor.  
     */
    pluralNameFrom(str)
    {
        local str2;
        
        /* kontrollera om det finns ett 'fras prep fras' format */
        if (str.find(prepPhrasePat) != nil)
        {
            /*
             *   Dra ut de två delarna - delen upp till 'av' är den 
             *   delen vi faktiskt kommer att pluralisera, och resten är ett suffix 
             *   vi lägger till i slutet av den pluraliserade delen. 
             */
            str = rexGroup(1)[3];
            str2 = rexGroup(2)[3];

            /*
             *   nu pluralisera delen upp till 'av' med hjälp av de vanliga
             *   reglerna, lägg sedan till resten i slutet av den pluraliserade delen
             */
            return pluralNameFrom(str) + str2;
        }

        /* analysera ut det sista ordet */
        rexMatch(lastWordPat, str);

        /* pluralisera det sista ordet */
        str = rexGroup(1)[3];
        str2 = rexGroup(2)[3];
        return str + pluralWordFrom(str2);
    }

    /* 
     *   om vi behöver lägga till 's som pluraländelse - detta bör vara antingen
     *   ett enkelt rakt citattecken ('\''), eller HTML markup för ett krulligt citattecken
     *   regelbundet uttryck för att separera huvudfrasen och
     *   prepositionell fras från en "substantiv prep substantiv" fras 
     */
    prepPhrasePat = static new RexPattern(
        '^(.+)(<space>+(<<prepList>>)<space>+.+)$')

    /* mönster för att dra ut det sista ordet ur en fras */
    lastWordPat = R'^(.*?)(<^space>*)<space>*$'

    /*
     *   Hämta pluralformen av det givna ordet. Om det finns en oregelbunden plural
     *   post för ordet, returnerar vi det; annars härleder vi pluralen
     *   från stavningen. 'apost' är strängen som ska användas för en apostrof
     *   ('&rsquo;').  
     */
    /*
     *   Returnerar pluralformen av ett ord. Slår upp oregelbundna former i
     *   irregularPlurals-tabellen (fylls från CustomVocab-objekt). Hanterar
     *   inbyggt -man → -män. Returnerar oförändrat ord för okänd form
     *   tills svenska pluralregler implementeras.
     */
    pluralWordFrom(str)
    {
        local irr;

        /* Slå upp oregelbunden plural */
        if ((irr = irregularPlurals[str]) != nil)
            return irr[1];

        /* Ord på -man → -män (brandman → brandmän) */
        if (rexMatch(menPluralPat, str))
            return '<<rexGroup(1)[3]>>män';

        /* Tom sträng */
        if (str.length() == 0)
            return '';

        /* Grupp 1: -a → -or (älva→älvor, hylla→hyllor, bilaga→bilagor) */
        if (str.endsWith('a'))
            return str.substr(1, str.length() - 1) + 'or';

        /* -are → oförändrad (läkare→läkare, spelare→spelare) — före -e-regeln */
        if (str.endsWith('are'))
            return str;

        /* -ie → +r (bakterie→bakterier, serie→serier) — före -e-regeln */
        if (str.endsWith('ie'))
            return str + 'r';

        /* -e (ej -ie, -are) → drop -e, +ar (galge→galgar) */
        if (str.endsWith('e'))
            return str.substr(1, str.length() - 1) + 'ar';

        /* -s (ej -us) → +er (analys→analyser, diagnos→diagnoser) */
        if (str.endsWith('s') && !str.endsWith('us'))
            return str + 'er';

        /* -ion → +er (nation→nationer, station→stationer) */
        if (str.endsWith('ion'))
            return str + 'er';

        /* -het/-tet → +er (frihet→friheter, kvalitet→kvaliteter) */
        if (str.endsWith('het') || str.endsWith('tet'))
            return str + 'er';

        /* -ism → +er (socialism→socialismer, turism→turismer) */
        if (str.endsWith('ism'))
            return str + 'er';

        /* -el → drop -el, +lar (cykel→cyklar, spegel→speglar) */
        if (str.endsWith('el'))
            return str.substr(1, str.length() - 2) + 'lar';

        /* Lånord på -eo → +r: video→videor */
        if (str.endsWith('eo'))
            return str + 'r';

        /* Lånord på -io → +s: studio→studios */
        if (str.endsWith('io'))
            return str + 's';

        /* Lånord på -mo → +s: memo→memos */
        if (str.endsWith('mo'))
            return str + 's';

        /* Lånord på övrig -o → +n: foto→foton, piano→pianon */
        if (str.endsWith('o'))
            return str + 'n';

        /* Standard grupp 2: +ar (svamp→svampar, hund→hundar) */
        return str + 'ar';
    }

    /* uppslagstabell för oregelbundna pluraler - vi bygger detta vid preinit tid */
    irregularPlurals = nil

    /* regelbundet uttryck för att trimma ledande och avslutande mellanslag */
    trimPat = R'^<space>+|<space>+$'

    /* mönster för ord som slutar med 'man' (brandman → brandmän) */
    menPluralPat = R'^(.*)man$'

    /* klass egenskap: huvudordboken StringComparator */
    dictComp = static new StringComparator(truncationLength, nil, nil)

    /* 
     *   klass egenskap: trunkeringslängden att använda för huvudordboken
     *   StringComparator. 
     */
    truncationLength = 8
    
    
    /* klass egenskap: pronomen uppslagstabell (byggd under preinit) */
    pronounMap = nil
 
    
    /* 
     *   DummyName är en egenskap som inte visar något, för användning när vi vill
     *   använda ett objekt i en mening utan att faktiskt visa någon text för
     *   det (t.ex. för att tillhandahålla ett subjekt för ett verb att överensstämma med).
     */
    dummyName = ''
   
    /* 
     *   Om vi är tvetydigt plural (vilket betyder att vi kan hänvisas till med antingen singular eller plural
     *   substantiv) kan vi lista de plural substantiv i pluralToken så att vi kan se om ett av dem användes i spelarens inmatning som hänvisar till oss. Alternativt kan vi annotera eventuella sådana plural substantiv i vår vocab egenskap genom att annotera det med [pn] och biblioteket kommer att lägga till vår pluralTokens lista för oss, t.ex.:
     *
     *   Dekoration 'löv[pn]; riklig; lövverk; dem det' ;
     */
    // pluralTokens = []
    
    /* 
     *   Använde spelaren en av våra plural tokens när de hänvisade till oss på denna tur? Spelkod kan anropa denna metod för att kontrollera om vi hänvisades till med ett plural eller singular namn och justera vårt svar därefter.
     */
    usedPluralToken()
    {
        return propDefined(&pluralTokens) && 
            valToList(pluralTokens).overlapsWith(gCommand.verbProd.tokenList.mapAll({x:
                getTokVal(x)}));
    } 
;


modify SubComponent
    /* 
     *   Förutom de egenskaper som kopieras vid den ursprungliga definitionen av denna
     *   klass i hans metod, behöver vi kopiera alla andra namnrelaterade
     *   egenskaper hos föräldraobjektet som spelkonstruktörer kan tänkas
     *   anpassa.
     */
    nameAs(parent)
    {
        /* Utför den ärvda hanteringen. */
        inherited(parent);
        
        /* Kopiera sedan alla andra namnrelaterade egenskaper. */
        aName = parent.aName;
        theName = parent.theName;
        theObjName = parent.theObjName;
        objName = parent.objName;
        possAdj = parent.possAdj;
        possNoun = parent.possNoun;
//        objInName = parent.objInName;
//        objIntoName = parent.objIntoName;
//        objOutOfName = parent.objOutOfName;
        
    }
    
;


/* ------------------------------------------------------------------------ */
/*
 *   LState är den språksspecifika basklassen för State objekt.
 *   
 *   [Required] 
 */
class LState: object
    /*
     *   Lägg till tillståndsnamnet till ett objektnamn under konstruktion. 'obj' är
     *   objektet, och 'str' objektnamnet som byggs. Detta lägger till det
     *   lämpliga adjektivet för tillståndet till namnet.
     *   
     *   [Required] 
     */
    addToName(obj, str)
    {
        /* hämta adjektivlistans post för objektets aktuella tillstånd */
        local st = obj.(stateProp);
        local adj = adjectives.valWhich({ ele: ele[1] == st });

        /* lägg till det till namnet */
        return '<<adj[2][1]>> <<str>>';
    }

    /*
     *   Initiera ett tillståndsadjektiv. Basbiblioteket kallar detta under
     *   preinit för varje ord, givet som en sträng. Språkmodulen
     *   måste definiera denna rutin, men den behöver inte göra något. Den
     *   svenska versionen lägger till ordet till ordboken, så att
     *   stavningskontrollern kan känna igen det.
     *   
     *   [Required] 
     */
    initWord(w)
    {
        /* lägg till det till ordboken */
        cmdDict.addWord(dictionaryPlaceholder, w, &noun);
    }
    
    /*  
     *   Ytterligare information som ska läggas till objektnamnet när det visas i en
     *   lista och är i motsvarande tillstånd
     */
    additionalInfo = []
    
    /* 
     *   Hämta strängen som ger ytterligare information om detta objekt när det är i
     *   ett visst tillstånd (såsom '(ger ljus)', den enda ytterligare
     *   tillståndsinformationen som faktiskt definieras i det svenska biblioteket)
     */
    getAdditionalInfo(obj)
    {
        /* hämta informationslistans post för objektets aktuella tillstånd */
        local st = obj.(stateProp);
        local info = additionalInfo.valWhich({ ele: ele[1] == st });
        
        return info != nil ? info[2] : '';
    }
;


/* ------------------------------------------------------------------------ */
/*
 *   Vanliga objekt tillstånd. Objekten själva är tvärspråkliga och
 *   är därför obligatoriska, men basbiblioteket lämnar det upp till språk
 *   modulerna att tillhandahålla de faktiska definitionerna, eftersom kroppen av varje
 *   definition är mestadels vokabulärord.  
 */

/*
 *   Tänd/Släckt tillstånd. Detta är användbart för ljuskällor och brännbara
 *   objekt.
 *   
 *   [Required] 
 */
LitUnlit: State
    stateProp = &isLit
    adjectives = [[nil, ['släckt']], [true, ['tänd']]]
    appliesTo(obj) { return obj.isLightable || obj.isLit; }
    //additionalInfo = [[true, ' ({ger} ljus)']]
    additionalInfo = [[true, ' (som {avger} ljus)']]
    //additionalInfo = [[true, ' (avgivandes ljus)']]
;

/*
 *   Öppen/Stängd tillstånd. Detta är användbart för saker som dörrar och
 *   behållare.  
 */
OpenClosed: State
    stateProp = &isOpen
    adjectives = [[nil, ['stängd']], [true, ['öppen']]]
    appliesTo(obj) { return obj.isOpenable; }
;

/*  
 *   DirState. Detta är användbart för SymConnectors och liknande, vars riktning
 *   vokabulär kan ändras beroende på vilken riktning de närmas från.
 */
DirState: State
    stateProp = &attachedDir

    /* 
     *   Vi gör alla dessa vokabulärord svaga tokens eftersom vi inte vill matcha på riktning
     *   namnet ensam, t.ex. X NORD.
     */
    vocabWords = [
        [&north, 'norr', MatchWeak],
        [&north, 'n', MatchWeak],
        [&south, 'söder', MatchWeak],
        [&south, 's', MatchWeak],
        [&east, 'öster', MatchWeak],
        [&east, 'e', MatchWeak],
        [&west, 'väster', MatchWeak],
        [&west, 'w', MatchWeak],
        [&southeast, 'sydost', MatchWeak],
        [&southeast, 'se', MatchWeak],
        [&southwest, 'sydväst', MatchWeak],
        [&southwest, 'sw', MatchWeak],
        [&northwest, 'nordväst', MatchWeak],
        [&northwest, 'nw', MatchWeak],
        [&southwest, 'sydväst', MatchWeak],
        [&southwest, 'sw', MatchWeak],
        [&port, 'babord', MatchWeak],
        [&port, 'p', MatchWeak],
        [&starboard, 'styrbord', MatchWeak],
        [&starboard, 'sb', MatchWeak],
        [&fore, 'för', MatchWeak],
        [&fore, 'framåt', MatchWeak],
        [&fore, 'f', MatchWeak],
        [&aft, 'akter', MatchWeak],
        [&up, 'upp', MatchWeak],
        [&up, 'uppåt', MatchWeak],
        [&down, 'ner', MatchWeak],
        [&down, 'd', MatchWeak],
        [&down, 'nedåt', MatchWeak],
        [&in, 'in', MatchWeak],
        [&in, 'inre', MatchWeak],
        [&in, 'inåt', MatchWeak],
        [&out, 'ut', MatchWeak],
        [&out, 'yttre', MatchWeak],
        [&out, 'utåt', MatchWeak]        
    ]
    
        
    appliesTo(obj)
    {
        /* 
         *   Vi utesluter DStairway eftersom inkludering av 'upp' eller 'ner' i dess vokabulär förvirrar
         *   parserns tolkning av KLÄTTRA UPP och KLÄTTRA NER.
         */
        if(defined(DSStairway) && obj.ofKind(DSStairway))
            return nil;
        else
            return inherited(obj);
    }
;


/*  
 *   Modifieringar av TopicPhrase för att få det att fungera bättre med den
 *   svenska specifika delen av biblioteket.
 */
modify TopicPhrase
    matchNameScope(cmd, scope)
    {
        
        local toks = tokens;
        local ret;
        
        /* 
         *   Ta bort eventuella apostrof-S från våra tokens eftersom vokabulärorden
         *   initialiseringen kommer att ha gjort detsamma
         */        
        tokens = tokens.subset({x: x != '\'s'});
        
        /* 
         *   Ta bort eventuella artiklar från tokens. Vi behöver göra detta i den
         *   svenska biblioteket för att säkerställa att vi får en rimlig matchning till en Topic
         *   när spelarens inmatning inkluderar artiklar (t.ex. FRÅGA OM DEN
         *   MÖRKA), eftersom parsern först kommer att försöka matcha objekt som inkluderar
         *   tokens 'den' och 'mörka' i deras vokabulärord, med resultat som
         *   kanske inte är vad vi vill.
         */        
        tokens = tokens.subset({x: x not in ('en', 'den', 'det', 'ett')});
        
        
        try
        {
            /* Utför den ärvda hanteringen och lagra resultatet */
            ret = inherited(cmd, scope);
        }
        finally
        {
            /* Återställ de ursprungliga tokens på vägen ut. */
            tokens = toks;
        }
        
        /* Returnera resultatet av den ärvda hanteringen. */
        return ret;
    }
    
;

/* 
 *   Modifiering av ResolvedTopic för användning med den svenska
 *   specifika delen av biblioteket.
 */
modify ResolvedTopic
    
    /* 
     *   Den svenska Tokenizer separerar apostrof-S från ordet det är en del
     *   av, så vid återställning av den ursprungliga texten måste vi sätta ihop eventuella apostrof-S
     *   tillbaka till ordet det separerades från.
     */    
    getTopicText()
    {
        local str = tokens.join(' ').trim();
        str = str.findReplace(' \'s', '\'s', ReplaceAll);
        return str;        
    }
    
;

/* 
 *   Modifiering av Topic klassen så att när man konstruerar en ny Topic en
 *   separat apostrof-S token sätts ihop med föregående ord när
 *   man lagrar namnet (vilket ångrar effekten på att bygga namnet av vad den
 *   svenska tokenizern gör med apostrof-S).
 */
modify Topic
    construct(name_)
    {
        name_ = name_.findReplace(' \'s', '\'s', ReplaceAll);
        inherited(name_);
    }
    
;

/* 
 *   Modifiering av Command klassen så att när man återställer en kommando
 *   sträng från dess tokens en separat apostrof-S token sätts ihop med
 *   föregående ord när man lagrar namnet (vilket ångrar effekten på
 *   att bygga namnet av vad den svenska tokenizern gör med
 *   apostrof-S).
 */
modify Command
    buildCommandString()
    {
        /* Få en lista över tokens som utgör kommandot vi vill omtolka. */
        local toks = valToList(verbProd.tokenList).mapAll({x: getTokVal(x)});

        //tadsSay('TEST');
        
        /* 
         *   Om det finns en punkt eller semikolon i kommandoraden (vilket indikerar mer än ett
         *   kommando på raden), ta bort eventuella igen kommandon från tok listan som följer efter
         *   skiljetecknet så att vi inte slutar med att upprepa ett igen kommando tills det finns en stack
         *   overflow. Vi vill inte ta bort G eller IGEN om det förekommer före skiljetecknet eftersom
         *   det kan vara en legitim del av det ursprungliga kommandot, t.ex. TRYCK PÅ KNAPP G.
         */
             
        local str = toks.join(' ');
        
        /* Dela strängen i en lista vid punkter och/eller semikolon       */        
        local lst = str.split(R'<period>|;');
            
        /* Ta bort eventuella instanser av igen kommandon från listan */
        lst = lst.subset({x: x.toLower().trim() not in ('g', 'igen')});
        
        /* Sätt ihop kommandosträngen igen från den justerade listan. */
        str = lst.join('.');
        
        /* 
         *   Tokenizern separerar 's från substantivet det kvalificerar, så vi tar bort eventuella oönskade mellanslag
         *   före 's.
         */
        str = str.findReplace(' \'s', '\'s', ReplaceAll);
        
        /* Returnera den justerade kommandosträngen. */
        return str;         
    }
;

/* ------------------------------------------------------------------------ */
/*
 *   Svenska modifieringar för Thing. Detta lägger till några metoder som varierar beroende på
 *   språk, så de kan inte definieras i den generiska Thing klassen.  
 */
modify Thing
    /*
     *   Visa den inbäddade rums underrubriken. Detta visar aktörens omedelbara
     *   behållare som ett tillägg till rumsnamnet i rumsbeskrivningen
     *   rubrik.
     *   
     *   [Required] 
     */
    roomSubhead(pov)
    {
        " (<<childLocType(pov).prep>> <<theName>>)";
    }
    
    /* Matchade spelarens kommando att TRYCKA detta objekt? */
    matchPushOnly = (gVerbWord == 'tryck')
    
    /* Matchade spelarens kommando att DRA detta objekt? */
    matchPullOnly = (gVerbWord is in ('dra', 'släpa'))
    
    /* 
     *   Kontrollera om vi behöver lägga till eller ta bort LitUnlit State från vår lista
     *   av tillstånd.
     */
    makeLit(stat)
    {
        inherited(stat);
        
        if(LitUnlit.appliesTo(self))
            states = states.appendUnique([LitUnlit]);
        else
            states -= LitUnlit;
    }
    
    /* 
     *   Tillkännage Bästa Val namn. Detta kan användas i de sällsynta fall där
     *   du vill åsidosätta namnet som parsern använder för att beskriva ett objekt
     *   när du tillkännager dess bästa val av objekt. Till exempel, om du har en
     *   flaska vin från vilken du kan fylla ett glas, kanske du föredrar '(med
     *   vin från flaskan)' till '(med flaskan vin)' efter FYLL GLAS; action är den åtgärd som utförs för vilken objektet har
     *   valts och role(DirectObject eller IndirectObject) är den roll det valda objektet spelar i åtgärden. Som standard returnerar denna metod bara theName.
     */
    abcName(action, role)
    {
        return theName;
    }
    
    /* 
     *   Hämta list suffixet för diverse föremål inom vårt rum när aktören (vanligtvis spelarkaraktären) är inne i denna Thing. Om misxListSuffix är definierad (icke-nil) på denna Thing, eller om vår plats är nil (förmodligen för att vi är ett rum snarare än någon form av inbäddat rum). returnera då vår miscListSuffix.
     *
     *   Vi gör det på detta sätt för att tillåta spelkoden att antingen anpassa vår misc list suffix (som, som standard, är bara 'här' på aktörens plats (om det är ett inbäddat rum) eller på aktörens rum, i vilket fall pov parametern kan användas för att variera suffixet beroende på aktörens plats (vilket kan spara arbete om, till exempel, rummet innehåller flera bås och vi vill ha samma prefix för varje).
     */
    getMiscListSuffix(pov)
    {
        return miscListSuffix || location == nil ? miscListSuffix :
        location.getMiscListSuffix(pov);  
        
    }
    
    /* 
     *   Suffixet att visa i slutet av en lista över de diverse föremål som finns direkt i vårt rum , t.ex. 'liggande på golvet' skulle anpassa listan till "Du ser X, Y och Z liggande på golvet" istället för standarden "!Du ser X, Y och Z här."
     */
    miscListSuffix = nil

    /* 
     *   Flag - do we want Remove on this object to be an action separate from both TAKE and DOFF?
     *   See removeDoer below.
     */
    separateRemove = nil

;



/*-------------------------------------------------------------------------- */
/*  
 *   Svenska språkmodifieringar till Room. Här tillåter vi helt enkelt ett rum att ta
 *   sin vokabulär från dess roomTitle egenskap om vocab inte redan är definierad; detta
 *   minskar behovet av att skriva samma text två gånger när de två är effektivt
 *   desamma.
 */
modify Room
    initVocab()
    {
        /* 
         *   Om vår vocab egenskap inte redan är definierad, ta den från vår
         *   roomTitle, konvertera den till gemener, förutsatt att proper är false.
         */
        if(vocab == nil && autoName && roomTitle)            
            vocab = proper ? roomTitle : roomTitle.toLower() ;
        
        /* Utför den ärvda hanteringen */
        inherited();
    }
    
    /* 
     *   Flagga: vill vi att detta rum ska ta sin vokabulär (och därmed sitt namn) från
     *   dess roomTitle egenskap om dess vocab egenskap inte uttryckligen är definierad?
     *   Som standard gör vi det.
     */
    autoName = true
    
    /* 
     *   Som standard är list suffixet för föremål direkt i ett rum helt enkelt 'här'. Detta kan ändras för enskilda rum eller åsidosättas på Room klassen. eller genom att åsidosätta rummets getMiscListSuffix(pove) metod, eller genom att använda ett CustomMessages objekt.
     */
    miscListSuffix = BMsg(misc list suffix, '{här}');
;



/* 
 *   Modifieringar av Pronoun för att säkerställa att aName, theName och theObjName
 *   returnerar de lämpliga resultaten.
 */
modify Pronoun
    aName = (name)
    theName = (name)
    theObjName = (objName)   
;

/* It - third-person neuter singular */
ItNeuter: It;
MeAll: Pronoun
    resolve() { return Me.resolve(); }
    person = 1
;
UsAll: Us
    /* delar namn/objName med Us — hålls utanför pronounMap för att undvika kollision */
    skipPronounMap = true
;

/* ------------------------------------------------------------------------ */
/*
 *   Basbibliotekets vokabulärinitialisering. För den svenska modulens egen
 *   bekvämlighet, lägger vi till vokabulärord till ett antal abstrakta
 *   grammatikrelaterade objekt definierade i basbibliotekets parser. Bas
 *   biblioteket kan inte definiera vokabulär, av uppenbara skäl, så vi måste
 *   lägga till vokabulärorden själva.  
 */
property prep;
pronounPreinit: PreinitObject
    execBeforeMe = []
    execute()
    {
        /* 
         *   Initiera pronomen namnen. Dessa används endast inom den
         *   svenska biblioteket. Andra språkmoduler kommer förmodligen att
         *   behöva definiera vokabulär för pronomener också, men de specifika
         *   egenskaperna är upp till översättaren. Språk som har fler
         *   substantivfall än svenska kan lägga till egenskaper för de extra substantiv
         *   fallen efter behov.  
         */
        It.name = It.objName = 'den';
        It.possAdj = It.possNoun = 'dess';
        It.thatName = It.thatObjName = 'den';
	    It.reflexive = Itself;

        ItNeuter.name = ItNeuter.objName = 'det';
        ItNeuter.possAdj = ItNeuter.possNoun = 'dess';
        ItNeuter.thatName = ItNeuter.thatObjName = 'det';
        ItNeuter.reflexive = Itself;

        Her.name = 'hon';
        Her.objName = 'henne';
        Her.possAdj = Her.possNoun = 'hennes';
	    Her.reflexive = Herself;

        Him.name = 'han';
        Him.objName = 'honom';
        Him.possAdj = Him.possNoun = 'hans';
	    Him.reflexive = Himself;

        Them.name = 'de';
        Them.objName = 'dem';
        Them.possAdj = 'deras';
        Them.possNoun = 'deras';
        Them.thatName = Them.thatObjName = 'de';
	    Them.reflexive = Themselves;
        Them.plural = true;
        
        //local dinEllerDitt = 'din';
        
        You.name = 'du';
        You.objName = 'dig';
        You.possAdj = 'din';
        You.possAdjT = 'ditt';
        You.possAdjPl = 'dina';
        You.possNoun = 'din';
	    You.reflexive = Yourself;

        Yall.name = Yall.objName = 'dina';
        Yall.possAdj = 'dina';
        Yall.possAdjT = 'ert';
        Yall.possAdjPl = 'era';
        Yall.possNoun = 'dina';
	    Yall.reflexive = Yourselves;
        Yall.plural = true;

        MeAll.name = MeAll.objName = 'mina';
        MeAll.possAdj = 'mina';
        MeAll.possNoun = 'mina';
	    MeAll.reflexive = Myself;
        MeAll.plural = true;

        Me.name = 'jag';
        Me.objName = 'mig';
        Me.possAdj = Me.possNoun = 'min';
        Me.possAdjT = 'mitt';
        Me.possAdjPl = 'mina';
    	Me.reflexive = Myself;

        Us.name = 'vi';
        Us.objName = 'oss';
        Us.possAdj = 'vår';
        Us.possAdjT = 'vårt';
        Us.possAdjPl = 'våra';
        Us.possNoun = 'vår';
	    Us.reflexive = Ourselves;
        Us.plural = true;

        UsAll.possAdj = 'våra';
        UsAll.possNoun = 'våra';
	    UsAll.reflexive = Ourselves;
        UsAll.plural = true;

        /* 3:e persons possessiver är invarianta — possAdjT = possAdjPl = possAdj */
        It.possAdjT = It.possAdjPl = It.possAdj;
        ItNeuter.possAdjT = ItNeuter.possAdjPl = ItNeuter.possAdj;
        Him.possAdjT = Him.possAdjPl = Him.possAdj;
        Her.possAdjT = Her.possAdjPl = Her.possAdj;
        Them.possAdjT = Them.possAdjPl = Them.possAdj;

        Myself.name = Myself.objName = 'mig';

        /* objName används av reflexiveObjName (via pronoun().reflexive.name)
         * för att ge basen till den emfatiska formen — 'sig', 'dig', 'oss' etc.
         * Genusböjningen (själv/självt/själva) beräknas i Thing.reflexiveObjName. */
        Yourself.objName = 'dig';
        Itself.objName = 'sig';
        Herself.objName = 'sig';
        Himself.objName = 'sig';
        Ourselves.objName = 'oss';
        Yourselves.objName = 'er';
        Themselves.objName = 'sig';


        Yourself.name = 'dig'; 
        Itself.name = 'sig';
        Herself.name = 'sig';
        Himself.name = 'sig';
        Ourselves.name = 'oss';
        Yourselves.name = 'er';
        Themselves.name = 'sig';

        /* 
         *   Ställ in standard 'det' namnet för varje pronomen till dess vanliga
         *   namn. Vi använder det vanliga pronomenet istället för 'det' för något
         *   könsbestämt substantiv eller första- eller andrapersons objekt.  
         */
        foreach (local pro in Pronoun.all)
        {
            if (pro.thatName == nil)
                pro.thatName = pro.name;
            if (pro.thatObjName == nil)
                pro.thatObjName = pro.objName;
        }

        /* skapa pronomen mappen för LMentionable */
        LMentionable.pronounMap = new LookupTable(16, 32);
        forEachInstance(Pronoun, function(p) {
            /* hoppa över pronomen som delar namn/objName med ett annat pronomen */
            if (p.skipPronounMap) return;
            LMentionable.pronounMap[p.name] = p;
            if (p.objName != nil)
                LMentionable.pronounMap[p.objName] = p;
        });

        /* 
         *   Initiera LocType prepositionerna. 'prep' egenskapen är
         *   svenska specifik och används INTE av basbiblioteket, men
         *   andra språkmoduler kommer förmodligen att behöva någon typ av
         *   motsvarande vokabulär för varje LocType.  
         */
        In.prep = 'i';
        Outside.prep = 'på';
        On.prep = 'på';
        Under.prep = 'under';
        Behind.prep = 'bakom';
        Held.prep = 'hållen av';
        Worn.prep = 'buren av';
        Attached.prep = 'fäst vid';
        PartOf.prep = 'del av';
    }
;
    

/* ------------------------------------------------------------------------ */
/*
 *   CustomVocab objekt definierar specialfall vokabulär för parsern och
 *   namn genereringsrutiner.
 *   
 *   Biblioteket tillhandahåller ett CustomVocab objekt med många vanliga
 *   specialfall ord, men spel och tillägg kan utöka de inbyggda
 *   listorna genom att definiera sina egna CustomVocab objekt som följer samma
 *   mönster. Biblioteket inkluderar automatiskt alla specialord
 *   listor i alla CustomVocab objekt som definieras i hela spelet.  
 */
class CustomVocab: object
    /* 
     *   Listan över specialfall a/an ord. Att välja 'a' eller 'an' är
     *   rent fonetiskt, och svenska ortografi är notoriskt
     *   inkonsekvent fonetiskt. Vad mer är, valet för många ord
     *   varierar beroende på dialekt, accent och personlig stil. Vi försöker täcka så
     *   mycket som möjligt med våra stavningsbaserade regler, men det är hopplöst att
     *   täcka alla baser enbart med stavning. Vid någon tidpunkt måste vi bara
     *   vända oss till en tabell med specialfall.
     *   
     *   Vi tillämpar specialreglerna baserat på det första ordet i ett namn. Det
     *   första ordet är helt enkelt den första sammanhängande gruppen av alfanumeriska
     *   tecken. Om det första ordet i ett namn finns i denna lista,
     *   åsidosätter inställningen här eventuella stavningsregler.
     *   
     *   Posterna här är helt enkelt strängar av formen 'en ord' eller 'ett
     *   ord'. Börja med den lämpliga formen av en/ett, lägg sedan till ett mellanslag,
     *   sedan det speciella ordet att matcha.
     */
    specialAOrAn = []

    /* 
     *   Oregelbunden plural lista. Detta är en lista över ord med pluraler som
     *   inte kan härledas från några av de vanliga stavningsreglerna. Posterna är i
     *   par: singular, [pluraler]. Pluralerna ges
     *   i en lista, eftersom vissa ord har mer än en giltig plural. Den
     *   första pluralen är den föredragna; de återstående posterna är
     *   alternativ.  
     */
    irregularPlurals = []

    /*
     *   Verb för substitutionsparametersträngar. Detta är en lista över
     *   strängar, med följande mall:
     *   
     *.     'infinitiv/presens3/dåtid/dåtid-particip'
     *   
     *   'infinitiv' är 'att' formen av verbet (att gå, att titta, att
     *   se), men *utan* ordet 'att'. 'presens3' är tredje person
     *   presens formen (är, går, ser). 'dåtid' är dåtid formen
     *   (gick, tittade, såg). 'dåtid-particip' är dåtid particip formen; detta är valfritt, och behövs endast för verb med distinkta
     *   dåtid och particip former (t.ex. såg/sedd, gick/gått). De flesta
     *   regelbundna verb - de med dåtid bildad genom att lägga till -ed till infinitiv - har identiska dåtid och particip former.
     *   
     *   För varje svenskt verb förutom "att vara", kan hela presens och dåtid
     *   böjningar härledas från dessa tre bitar av information.
     *   Dåtid perfekt, framtid och framtid perfekt böjningar kan också
     *   härledas från denna information, för alla verb förutom "att vara" och
     *   hjälpverben (kunde, borde, etc). Det svenska biblioteket
     *   fördefinierar "att vara" och alla hjälpverben, så det finns inget
     *   behov av att definiera dem med denna mekanism.  
     */

    verbParams = []
;

/*
 *   Anpassad svensk vokabulär. Här definierar vi en grundläggande ordbok av
 *   oregelbundna pluraler, a/an ord och verb parametrar. Spel som vill
 *   spara lite kompilerad filstorlek kanske vill ersätta detta med en
 *   uppsättning som endast definierar de ord som faktiskt behövs i spelet. Spel
 *   är fria att definiera ytterligare anpassade vokabulärord genom att lägga till sina
 *   egna CustomVocab objekt; biblioteket kommer automatiskt att hitta och slå samman
 *   dem i ordboken under preinit.  
 */
 
swedishCustomVocab: CustomVocab
    // oregelbundna pluralsformer — lägg till spelspecifika ord här
    irregularPlurals = [
        /* umlautpluraler — genuint oregelbundna */
        'bok', ['böcker'],
        'bonde', ['bönder'],
        'brand', ['bränder'],
        'bror', ['bröder'],
        'dotter', ['döttrar'],
        'fot', ['fötter'],
        'gås', ['gäss'],
        'hand', ['händer'],
        'land', ['länder'],
        'lus', ['löss'],
        'mus', ['möss'],
        'natt', ['nätter'],
        'rand', ['ränder'],
        'rot', ['rötter'],
        'son', ['söner'],
        'stad', ['städer'],
        'strand', ['stränder'],
        'tand', ['tänder'],
        'tång', ['tänger'],

        /* rotvokalfall — vokal faller bort i stammen */
        /* (cykel, nyckel, fågel m.fl. täcks av -el-regeln) */
        'finger', ['fingrar'],
        'kamel', ['kameler'],   /* undantag: -el-regeln ger fel 'kamlar' */
        'muskel', ['muskler'],  /* undantag: -el-regeln ger fel 'musklar' */
        'regel', ['regler'],    /* undantag: -el-regeln ger fel 'reglar' */
        'sommar', ['sommrar'],
        'syster', ['systrar'],
        'vinter', ['vintrar'],
        'åker', ['åkrar'],

        /* grupp 4 neutrum — slutar på -e, får -en (ej -ar) */
        'äpple', ['äpplen'],
        'byte', ['byten'],
        'läge', ['lägen'],
        'löfte', ['löften'],
        'märke', ['märken'],
        'minne', ['minnen'],
        'möte', ['möten'],
        'nöje', ['nöjen'],
        'öde', ['öden'],
        'rike', ['riken'],
        'stycke', ['stycken'],

        /* slutar på -a men får -an/-on, inte -or */
        'hjärta', ['hjärtan'],
        'öga', ['ögon'],
        'öra', ['öron'],

        /* latinska specialformer som avviker från svenska regler */
        'kriterium', ['kriterier'],
        'memorandum', ['memorandum'],
        'schema', ['scheman'],
        'symposium', ['symposier'],

        /* oförändrad plural (grupp 5) */
        'ägg', ['ägg'],
        'barn', ['barn'],
        'blad', ['blad'],
        'byxor', ['byxor'],
        'data', ['data'],
        'fel', ['fel'],
        'fenomen', ['fenomen'],
        'filter', ['filter'],
        'fönster', ['fönster'],
        'får', ['får'],
        'glasögon', ['glasögon'],
        'hammare', ['hammare'],
        'högkvarter', ['högkvarter'],
        'hus', ['hus'],
        'index', ['index'],
        'kläder', ['kläder'],
        'lager', ['lager'],
        'lejon', ['lejon'],
        'liv', ['liv'],
        'medel', ['medel'],
        'möbler', ['möbler'],
        'monster', ['monster'],
        'nummer', ['nummer'],
        'själv', ['själv'],
        'shorts', ['shorts'],
        'slut', ['slut'],
        'tecken', ['tecken'],
        'tillägg', ['tillägg'],
        'träd', ['träd'],
        'vapen', ['vapen'],
        'vatten', ['vatten'],

        /* djur med dubbel plural */
        'fisk', ['fisk', 'fiskar'],
        'hjort', ['hjort', 'hjortar'],
        'öring', ['öring', 'öringar'],
        'torsk', ['torsk', 'torskar'],

        /* lånord med oförutsägbar plural */
        'automat', ['automater'],

        /* undantag till -are-regeln (som annars ger oförändrad) */
        'hare', ['harar'],

        /* -ss → -ar (vår -s-regel ger annars fel -er) */
        'buss', ['bussar'],

        /* grupp 3 (-er) — stavningen ger inte ledtråd om -ar vs -er */
        'alg', ['alger'],
        'art', ['arter'],
        'bacill', ['baciller'],
        'barack', ['baracker'],
        'kerub', ['keruber'],
        'larv', ['larver'],
        'läroplan', ['läroplaner'],
        'pincett', ['pincetter'],
        'ryggrad', ['ryggrader'],
        'seraf', ['serafer'],
        'sopran', ['sopraner']
    ]

    // specialfall 'en' vs 'ett' ord 
    specialAOrAn = [
        // N/A i svenska
    ]

    // verb parametrar, för {xxx} tokens i meddelandesträngar
    verbParams = [ 
        'se/ser/såg/sett',
        'kunna/kan/kunde/kunnat',
        'ha/har/hade/haft',
        'göra/gör/gjorde',        
        'visa/visar/visade/visat',    
        'vilja/vill/ville/velat',
        'uppstå/uppstår/uppstod/uppstått',        
        'vakna/vaknar/vaknade/vaknat',        
        'bära/bär/bar/buren',
        'bäras/bärs/bars/buren',
        'slå/slår/slog/slagen',
        'bli/blir/blev/blivit',
        'börja/börjar/började/börjat',
        'öppna/öppnar/öppnade/öppnat',
        'böja/böjer/böjde',
        'satsa/satsar/satsade',
        'bjuda/bjuder/bjöd/bjuden',
        'binda/binder/band',
        'bita/biter/bet/bitten',
        'blöda/blöder/blödde',
        'blåsa/blåser/blåste/blåst',                
        'bryta/bryter/bröt/bruten',
        'avla/avlar/avlade/avlat',
        'hälsa/hälsar/hälsade/hälsat',
        'prata/pratar/pratade/pratat',
        'bygga/bygger/byggde/byggt',
        'bränna/bränner/brände',
        'bryta/bryter/bröt',
        'köpa/köper/köpte',
        'kasta/kastar/kastade',
        'fånga/fångar/fångade',
        'välja/väljer/valde/valt',
        'klappa/klappar/klappade',        
        'klänga/klänger/klängde',        
        'låsa/låser/låste/låst',                
        'komma/kommer/kom',        
        'krypa/kryper/krypte',
        'skära/skär/skärde',
        'hantera/hanterar/hanterade',        
        'gräva/gräver/grävde',
        'dyka/dyker/dök/dykt',
        'rita/ritar/ritade/ritad',
        'drömma/drömmer/drömde',
        'dricka/dricker/drack/druckit',
        'köra/kör/körde/kört',        
        'bo/bor/bodde',
        'äta/äter/åt/ätit',        
        'falla/faller/föll/fallit',        
        'mata/matar/matade',
        'känna/känner/kände/känt',
        'röra/rör/rörde/rört',
        //'attackera/attackerar/attackerade/attackerat', // TODO: regelbundet
        'slåss/slåss/slogs',
        'hitta/hittar/hittade',
        'slunga/slungar/slungade',        
        'flyga/flyger/flög/flugit',        
        'förbjuda/förbjuder/förbjöd/förbjuden',
        'frysa/fryser/frös/frusen',
        'få/får/fick/fått',
        'ge/ger/gav/given',
        'avge/avger/avgav/avgett',
        'gå/går/gick/gått',
        'mala/malar/malade',
        'växa/växer/växte/vuxit',
        'handskriva/handskriver/handskrev/handskriven',        
        'hänga/hänger/hängde',
        'ha/har/hade',
        'gömma/gömmer/gömde/gömd',
        'slå/slår/slog',
        'hålla/håller/höll',
        'skada/skadar/skadade',
        'inlägga/inlägger/inlagd',
        'mata/matar/matade',
        'interlägga/interlägger/interlagd',        
        'hålla/håller/höll',
        'knäböja/knäböjer/knäböjde',
        'sticka/sticker/stickade',
        'veta/vet/visste/vetat',        
        'lägga/lägger/lagt',
        'leda/leder/ledde',
        'luta/lutar/lutade',
        'hoppa/hoppar/hoppade',
        'lära/lär/lärde',
        'befinna/befinner/befann/befunnit',
        'lämna/lämnar/lämnade',
        'låna/lånar/lånade',
        'låta/låter/lät',
        'ligga/ligger/liggde',
        'tända/tänder/tände',        
        'förlora/förlorar/förlorade',
        'göra/gör/gjorde',
        'betyda/betyder/betydde',
        'möta/möter/mötte',
        'smälta/smälter/smält/smält',
        'vilseleda/vilseleder/vilseledde',
        'missta/misstänker/misstog/misstagit',
        'missförstå/missförstår/missförstod',
        'missgifta/missgifter/missgift',        
        'klippa/klipper/klippte/klippt',        
        'överdriva/överdriver/överdrev/överdriven',
        'överhöra/överhör/överhörde',
        'överta/övertar/övertog/övertagen',        
        'betala/betalar/betalade',        
        'förinställa/förinställer/förinställd',
        'bevisa/bevisar/bevisade/bevisad',
        'svara/svarar/svarade/svarat',
        'sätta/sätter/satte',
        'sluta/slutar/slutade',        
        'läsa/läser/läste',
        'befria/befriar/befriade',
        'rida/rider/red/ridit',
        'ringa/ringer/ringde/ringt',
        'stiga/stiger/steg/stigit',
        'riva/river/rev/riven',        
        'springa/springer/sprang/sprungit',        
        'såga/sågar/sågade/sågad',
        'sy/syr/sydde/sydd',
        'säga/säger/sa',
        'se/ser/såg/sett',        
        'sätta/sätter/satt',
        'skaka/skakar/skakade/skakad',
        'raka/rakar/rakade/rakad',
        'klippa/klipper/klippte',
        'fälla/fäller/fällde',
        'skina/skiner/sken',
        'sko/skor/skodde',
        'skjuta/skjuter/sköt',        
        'visa/visar/visade/visad',
        'krympa/krymper/krympte/krympt',
        'stänga/stänger/stängde',
        'sjunga/sjunger/sjöng/sjungit',
        'sitta/sitter/satt',
        'döda/dödar/dödade/dödad',
        'sova/sover/sov',
        'glida/glider/glid',
        'slunga/slungar/slungade',
        'slinka/slinker/slink',
        'slita/sliter/slet',
        'lukta/luktar/luktade',
        'smyga/smyger/smög',
        'spå/spår/spådde',
        'så/sår/sådde/sådd',
        'tala/talar/talade/talat',
        'snabba/snabb/snabbade',
        'stava/stavar/stavade',
        'spendera/spenderar/spenderade',
        'spilla/spiller/spillde',
        'snurra/snurrar/snurrade',
        'spotta/spottar/spottade',
        'dela/delar/delade',
        'förstöra/förstör/förstörde',
        'sprida/sprider/spred',
        'springa/springer/sprang/sprungit',
        'stå/står/stod',
        'stjäla/stjäl/stal/stulit',
        'sticka/sticker/stuckit',
        'stinka/stinker/stank/stunkit',
        'stiga/stiger/steg/stigit',
        'slå/slår/slog/slagen',
        'sträva/strävar/strävade/strävat',
        'hyra/hyr/hyrde/hyrd',
        'solbränna/solbränner/solbränd',
        'svära/svär/svor/svuren',
        'svettas/svettas/svettades',
        'sopa/sopar/sopade',
        'svälla/sväller/svällde/svullen',
        'simma/simmar/simmade/simmat',
        'svinga/svingar/svingade',        
        'ta/tar/tog/tagen',        
        'lära/lärde/lärde',
        'riva/river/rev/riven',
        'berätta/berättar/berättade',
        'tänka/tänker/tänkte',
        'trivas/trivs/trivdes/trivts',
        'kasta/kastar/kastade/kastad'
    
    ]
;


/* ------------------------------------------------------------------------ */
/*
 *   Generera en utskriven version av det angivna talvärdet, eller helt enkelt en
 *   strängrepresentation av numret. Vi följer ganska standard
 *   engelska stilregler:
 *   
 *.    - vi stavar ut siffror under 100
 *.    - vi stavar också ut runda siffror över 100 som kan uttryckas
 *.      i två ord (t.ex. "femton tusen" eller "trettio miljoner")
 *.    - för miljoner och miljarder skriver vi, t.ex. "1,7 miljoner", om möjligt
 *.    - för allt annat returnerar vi decimalerna, med kommatecken för att
 *.      separera grupper av tusentals (t.ex. 120 400)
 *   
 *   Andra språk kan ha olika stilregler, så valet att använda
 *   ett utskrivet nummer eller siffror kan variera beroende på språk.
 *   
 *   [Krävs] 
 */
spellNumber(n)
{
    /* hämta nummerformateringsalternativen */
    local dot = swedishOptions.decimalPt;
    local comma = swedishOptions.numGroupMark;
    
    /* om det är ett BigNumber med en bråkdel, skriv som siffror */
    if (dataType(n) == TypeObject
        && n.ofKind(BigNumber)
        && n.getFraction() != 0)
    {
        /* 
         *   formatera det och konvertera decimaler och gruppseparatorer enligt
         *   alternativen 
         */
        return n.formatString(n.getPrecision(), BignumCommas).findReplace(
            ['.', ','], [dot, comma]);
    }

    /* om det är mindre än noll, använd "minus sju" eller "-123" */
    if (n < 0)
    {
        /* få den stavade versionen av det absoluta värdet */
        local s = spellNumber(-n);

        /* om det har några bokstäver, använd "minus", annars "-" */
        return (s.find(R'<alpha>') != nil ? 'minus ' : '-') + s;
    }

    /* stava allt under 100 */
    if (n < 100)
    {
        if (n < 20)
            return ['noll', 'ett', 'två', 'tre', 'fyra', 'fem', 'sex',
                    'sju', 'åtta', 'nio', 'tio', 'elva', 'tolv',
                    'tretton', 'fjorton', 'femton', 'sexton',
                    'sjutton', 'arton', 'nitton'][n+1];
        else
            return ['tjugo', 'trettio', 'fyrtio', 'femtio', 'sextio',
                    'sjuttio', 'åttio', 'nittio'][n/10-1]
            + ['', '-ett', '-två', '-tre', '-fyra', '-fem', '-sex',
               '-sju', '-åtta', '-nio'][n%10 + 1];
    }

    /* stava ut ensiffriga multiplar av 100 */
    if (n % 100 == 0 && n/100 < 10)
        return '<<spellNumber(n/100)>> hundra';
    
    /* 
     *   Stava ut ensiffriga multiplar av varje tiopotens från tusen till
     *   en miljard.
     */
    if (n % 1000000000 == 0 && n/1000000000 < 10)
        return '<<spellNumber(n/1000000000)>> miljard';
    if ((n % 1000000 == 0 && n/1000000 < 10)
        || (n % 10000000 == 0 && n/10000000 < 10)
        || (n % 100000000 == 0 && n/100000000 < 10))
        return '<<spellNumber(n/1000000)>> miljon';
    if ((n % 1000 == 0 && n/1000 < 10)
        || (n % 10000 == 0 && n/10000 < 10)
        || (n % 100000 == 0 && n/100000 < 10))
        return '<<spellNumber(n/1000)>> tusen';

    /*
     *   kontrollera om det kan uttryckas som ett heltal av miljoner eller
     *   miljarder, eller som miljoner eller miljarder med upp till tre signifikanta
     *   siffror ("1,75 miljoner", "17,5 miljarder")
     */
    if (n % 1000000 == 0 && n/1000000 < 1000)
        return '<<n/1000000>> miljon';
    if (n % 100000 == 0 && n/1000000 < 100)
        return '<<n/1000000>><<dot>><<n%1000000 / 100000>> miljon';
    if (n % 10000 == 0 && n/1000000 < 10)
        return '<<n/1000000>><<dot>><<n%1000000 / 10000>> miljon';
    if (n % 1000000000 == 0 && n/1000000000 < 1000)
        return '<<n/1000000000>> miljard';
    if (n % 100000000 == 0 && n/1000000000 < 100)
        return '<<n/1000000000>><<dot>><<n%1000000000 / 100000000>> miljard';
    if (n % 10000000 == 0 && n/1000000000 < 10)
        return '<<n/1000000000>><<dot>><<n%1000000000 / 10000000>> miljard';

    /* konvertera till siffror */
    local s = toString(n);

    /* sätt in kommatecken vid tusentals */
    for (local i = s.length() - 2 ; i > 1 ; i -= 3)
        s = s.splice(i, 0, comma);

    /* returnera resultatet */
    return s;
}

/* 
 *   Försök att konvertera ett utskrivet nummer (t.ex. 'nittiosex') till dess heltalsrepresentation.
 *   Om detta misslyckas, returnera nil.
 */
spelledToInt(str)
{
    /* Tokenisera inmatningssträngen */
    local toks = cmdTokenizer.tokenize(str);
    
    /* Försök att analysera tokenen mot spelledNumber-produktionen */
    local lst = spelledNumber.parseTokens(toks, cmdDict);
    
    /*  Om det finns ett giltigt resultat, konvertera det till ett heltal. */
    if(lst.length > 0)
        return lst[1].numval();
    
    /* Annars returnera nil */
    return nil;
}

  
   


/* ------------------------------------------------------------------------ */
/*
 *   Listvisningsrutiner
 */
modify Lister
    /* 
     *   Visa listan som en 'och'-lista, det vill säga en lista över aNames för varje
     *   objekt i lst formaterat med kommatecken mellan listelement och 'och'
     *   mellan de två sista objekten i listan.
     */
    showList(lst, pl, paraCnt)
    {        
        "<<andList(lst.mapAll({ o: o.aName }))>>";
    }
    
;

/* 
 *   Modifieringar av ItemLister (bas klassen för lister som listar
 *   fysiska objekt) för den engelskspråkiga delen av biblioteket.
 */
modify ItemLister    
    
    // /* 
    //  *   För en item lister använder vi listName-metoden för lister istället för
    //  *   aName-egenskapen för objektet för att tillhandahålla ett namn för objektet;
    //  *   detta gör att lister kan lägga till status-specifik information som '(ger
    //  *   ljus)' eller '(bärs)' till namnet som det visas i listan.
    //  */
    // showList(lst, pl, parent)   
    // {        
    //     "<<andList(lst.mapAll({ o: listName(o) }))>>";        
    // }

    /* 
     *   Show a simple list of things. For an item lister we use the listName method of the lister
     *   rather than the aName property of the object to provide a name for the object; this allows
     *   the lister to add status-specific information like '(providing light)' or '(being worn)' to
     *   the name as it appears in the list.
     */
    showSimpleList(lst)
    {
        "<<andList(lst.mapAll({ o: listName(o) }))>>";  
    }

    /* 
     *   ListName är aName för o plus all status-specifik information vi
     *   kanske vill ska visas i listan, som '(ger ljus)'
     */
    listName(o)
    {
        /* Spara objektets namn i en lokal variabel */
        local lName = o.aName;
        
        /* 
         *   Lägg till all ytterligare status-specifik information, som ' (ger
         *   ljus)', till namnet på detta objekt.
         */
        if(showAdditionalInfo)
        {
            foreach(local state in o.states)
                lName += state.getAdditionalInfo(o);
        }            

        /* 
         *   Om detta objekt bärs och vi vill visa information om
         *   objekt som bärs, lägg till ' (buren)' till namnet
         */
        if(o.wornBy != nil && showWornInfo)
            lName += BMsg(being worn, ' (buren)');
        
               
        /* 
         *   Om detta objekt har flyttats till ett annat objekt, och vi vill visa information om
         *   denna notional plats, lägg till ' {vid vad som helst)' till namnet.
         */
        if(o.movedTo != nil && showMovedToInfo)
        {
            local obj = o.movedTo;
            gMessageParams(obj);
            lName += BMsg(moved to, ' (vid {ref obj})');
        }
        
        /* 
         *   Om objektet som listas har synligt innehåll, och vill ha sitt innehåll sublistat,  
         *   lista dess synliga innehåll rekursivt.
         *   Gör sedan samma sak för alla remapIn- eller remapOn-underdelar.
         */ 
        if(showSubListing && o.(subContentsListedProp))
        {
            local lists = [o];
            
            if(o.remapIn)
                lists += o.remapIn;
            
            if(o.remapOn)                
                lists += o.remapOn;
            
            foreach(local s in lists)
            {
                if(s.contents != nil && s.contents.length > 0 && s.canSeeIn)          
                {
                    lName += subLister.buildList(s.contents);
                    s.contents.subset({ o: listed(o) }).forEach({x: x.mentioned = true});
                }
                
            }
        }     
        
               
        /* 
         *   Returnera resultatet, dvs. aName för objektet plus all ytterligare
         *   information om dess status och/eller innehåll.
         */
        return lName;
    }
    
    
    /* 
     *   Flagga: vill vi visa ytterligare information som '(ger
     *   ljus)' efter namnen på objekt som listas i inventariet.
     *   Som standard gör vi det.
     */
    showAdditionalInfo = true
    
    
    /* 
     *   Flagga: vill vi visa (bärs) efter objekt i en inventarielista
     *   som spelar karaktären bär. Som standard gör vi det om vi visar
     *   ytterligare information.
     */
    showWornInfo = (showAdditionalInfo)
    
    /*  
     *   Flagga: vill vi visa {vid vad som helst) om efter objekt som har notional flyttats
     *   till närheten av vad som helst.
     */
    showMovedToInfo = true
    
    /* 
     *   Flagga: vill vi visa innehållet i objekt som listas i inventariet (i
     *   parenteser efter namnet, t.ex. en väska (i vilken är en blå boll)). Som
     *   standard gör vi det om aktören är spelar karaktären. 
     */
    showSubListing = (gActor == gPlayerChar)
;

/* English-language modfications to the base ListGroup class. */
modify ListGroup
    /* 
     *   Show a simple list of items lst using lister. Here we just create a simple and list: "a, b,
     *   c, ... and x"
     */
    showSimpleList(lister, lst)
    {
        "<<andList(lst.mapAll({ o: lister.listName(o) }))>>";
    }    
;


/*  
 *   Engelskspråkiga modifieringar av lister som används för diverse objekt
 *   när man tittar runt i ett rum.
 */
modify lookLister
    showListPrefix(lst, pl, paraCnt)
    {
        "{Jag} {kan} se ";
    }
    
    
    /* 
     *   Vi hämtar listsuffixet från suffixet som aktörens (vanligtvis spelarens karaktärs)
     *   plats vill att vi ska använda för att möjliggöra anpassning till något som kan vara mer
     *   lämpligt än standarden 'här'.
     */
    showListSuffix(lst, pl, paraCnt)    {
        
        " <<gActor.location.getMiscListSuffix(gActor)>>.";
    }
    
    showSubListing = (gameMain.useParentheticalListing)
;

/* 
 *   Engelskspråkiga modifieringar av lister som används för att lista objekt som bärs
 *   av spelar karaktären.
 */
modify inventoryLister
    showListPrefix(lst, pl, paraCnt)
    {
        "<<if paraCnt == 0>>{Jag}<<else>>, och<<end>> bär på ";
    }
    
    showListSuffix(lst, pl, paraCnt)
    {
        ".";
    }
    
    showListEmpty(paraCnt)
    {
        "{Jag} {är} tomhänt. ";
    }    
;

/* 
 *   Engelskspråkiga modifieringar av lister som används för att lista objekt som bärs
 *   av spelar karaktären.
 */
modify wornLister
    showListPrefix(lst, pl, paraCnt)
    {
        "{Jag} bär ";
    }
    
    showListSuffix(lst, pl, paraCnt)
    {
        
    }
    
    showListEmpty(paraCnt)
    {
        
    }
     
    /* 
     *   Vi vill inte visa "(bärs)" efter objekt som listas efter "Du är
     *   bär" eftersom detta tydligt skulle vara överflödigt.
     */
    showWornInfo = nil
;

// conjAdjObj - kör adjustAdjectiveAgreement på valfritt objekt 
// Användning:  conjAdjObj(obj, 'vilk','en/et/a')
// Exempel: " (<<container.objInPrep>> <<conjAdjObj(container, 'vilk', 'en/et/a')>> {är} ";
function conjAdjObj(obj, stam, expansion) {
    return adjustAdjectiveAgreement(object {curObj = obj},  ['conjadj', stam, expansion]);
}

/* 
 *   SubLister används av andra lister som inventoryLister och
 *   wornLister för att visa innehållet i listade objekt i parenteser (t.ex. '(i
 *   vilket är en penna, en penna och ett papper). Djupet av inbäddning är
 *   begränsat av egenskapen maxNestingDepth. 
 */
subLister: ItemLister
    showListPrefix(lst, pl, paraCnt)
    {
        local container = lst[1].location;
        gMessageParams(container);
        " (<<container.objInPrep>> {curobj container}{conjadj vilk en/et/a} {är} ";
    }
    
    showListSuffix(lst, pl, paraCnt) { ")"; }
    
    showListEmpty(paraCnt) { }
   
    /* Bygg listinnehållet från lst till ett maximalt inbäddningsdjup */
    buildList(lst)
    {
        /* öka inbäddningsdjupet med 1 */
        nestingDepth++;
        
        /* 
         *   om vi har gått bortom det maximala inbäddningsdjupet, returnera helt enkelt en
         *   tom sträng för att sluta gå djupare.
         */
        if(nestingDepth > maxNestingDepth)
        {
            /* minska inbäddningsdjupet med 1 */
            nestingDepth--;
            
            /* returnera en tom sträng. */
            return '';
        }
    
        /* 
         *   Utför den ärvda hanteringen och spara resultatet i en lokal
         *   variabel.
         */
        local str = inherited(lst);
        
        /* Minska inbäddningsdjupet med 1 */
        nestingDepth--;
        
        /* Returnera resultatet */
        return str;
    }
    
    showList(lst, pl, paraCnt)
    {
        "<<andList(lst.mapAll({ o: listName(o) }))>>";
    }
    
    /* Det maximala inbäddningsdjupet som denna subLister får nå */
    maxNestingDepth = 1
    
    /* Det aktuella inbäddningsdjupet för denna subLister */
    nestingDepth = 0
    
    
    showSubListing = true 
    
    listed(o) { return o.lookListed; }
;


/* 
 *   Engelskspråkiga modifieringar av descContentsLister, som används för att
 *   lista innehållet i en behållare när den undersöks.
 */
modify descContentsLister
    showListPrefix(lst, pl, parent)
    {
        gMessageParams(parent);
        
        /* 
         *   Om objektet vars innehåll vi listar vill rapportera sin
         *   öppna-eller-stängda status, börja listningen med att rapportera att den är
         *   öppen och säg sedan 'och innehåller'
         */
        if(parent.openStatusReportable == UsePronoun)
            "{Han parent}{\'s} öppen och innehåller{s/ed} ";  
        
        else if(parent.openStatusReportable)
            "{The subj parent} {är} öppen och innehåller{s/ed} ";  
        
        /*  
         *   Annars börja listningen utan att uttryckligen nämna att
         *   behållaren är öppen.
         */

// TODO: >x träd -> "I äppelträdet så se du ett äpple.""

        else
            "{I parent} {ser|såg} {jag} ";               
        
    }

    showListSuffix(lst, pl, paraCnt)
    {
        ".";
    }
    
    /* 
     *   Om det inte finns något innehåll att lista, men objektet vars innehåll vi försökte
     *   lista vill rapportera sin öppna-eller-stängda status, ange helt enkelt
     *   att den är öppen eller stängd.
     */
    showListEmpty(parent)  
    {
        gMessageParams(parent);
        if(parent.openStatusReportable == UsePronoun)
            "{Han parent}{\'s} <<if parent.isOpen>>öppen<<end>>. ";
        
        else if(parent.openStatusReportable)
            "\^<<parent.theNameIs>> <<if parent.isOpen>>öppen<<end>>. ";
    }
    
    /* 
     *   Flagga: Visa en underlistning (dvs. innehållet i objekten i vår
     *   omedelbara innehåll, i parenteser efter namnet på objektet, om
     *   gameMain-alternativet useParentheticalListing är sant.
     */
    showSubListing = (gameMain.useParentheticalListing)
;

/* 
 *   Engelskspråkiga modifieringar av lister som används för att lista innehållet i
 *   behållare när man tittar runt i ett rum.
 */
modify lookContentsLister
    showListPrefix(lst, pl, parent)
    {
        "\^<<parent.remoteObjInName(gActor)>> {kan} {jag} se ";   //TODO: sere/
    }

    showListSuffix(lst, pl, paraCnt)
    {
        ".";
    }    
    
    /* 
     *   Flagga: Visa en underlistning (dvs. innehållet i objekten i vår
     *   omedelbara innehåll, i parenteser efter namnet på objektet, om
     *   gameMain-alternativet useParentheticalListing är sant.
     */
    showSubListing = (gameMain.useParentheticalListing)
    
;

/* 
 *   Engelskspråkiga modifieringar av lister som används för att beskriva innehållet
 *   av en öppningsbar behållare när den just har öppnats.
 */
modify openingContentsLister
    showListPrefix(lst, pl, parent)
    {
        gMessageParams(parent);
        "Öppnar <<parent.theName>> {dummy} avslöjar{r/de} ";        
    }

    showListSuffix(lst, pl, paraCnt)
    {
        ".\n";
    }
    
    showListEmpty(parent)  
    {
        "{Jag} öppnar{s/ed} {the dobj}. ";
    }
    
    showSubListing = (gameMain.useParentheticalListing)
;


/* 
 *   Engelskspråkiga modifieringar av lister som används för att lista innehållet i
 *   något som undersöks (eller söks).
 */
modify lookInLister
    showListPrefix(lst, pl, parent)
    {
        gMessageParams(parent);
        "{Jag parent} {se} ";        
    }

    showListSuffix(lst, pl, paraCnt)
    {
        ".\n";
    }
    
    showListEmpty(parent)  
    {
       
    }
    
    showSubListing = (gameMain.useParentheticalListing)
; 
    
/* 
 *   Engelskspråkiga modifieringar av lister som används för att lista objekt som är
 *   fästa vid en SimpleAttachable.
 */
modify simpleAttachmentLister
    showListPrefix(lst, pl, parent)
    {
        "{Jag} {ser} ";        
    }

    showListSuffix(lst, pl, parent)
    {
        " fäst vid <<parent.theName>>. ";
    }
     
    showSubListing = (gameMain.useParentheticalListing) 
;

/*  
 *   Engelskspråkiga modifieringar av lister som används för att lista objekt som är
 *   anslutna till en PlugAttachable.
 */
modify plugAttachableLister
    showListSuffix(lst, pl, parent)
    {
        " ansluten till <<parent.theName>>. ";
    }    
;

/* 
 *   Lister som används för att lista alternativen som spelaren kan välja mellan när
 *   spelet tar slut.
 */
finishOptionsLister: Lister
    showList(lst, pl, paraCnt)
    {
        /* 
         *   Lista alternativen som alternativ (med ett 'eller' mellan de två sista
         *   objekten).
         */
        "<<orList(lst.mapAll({ o: o.desc }))>>";
    }
    
    showListPrefix(lst, pl, parent)
    {
        cquoteOutputFilter.deactivate();
         "<.p>Vill du ";       
    }
    
    
    showListSuffix(lst, pl, paraCnt)
    {
        /* avsluta frågan, lägg till en tom rad */
        "?\b";
        cquoteOutputFilter.activate();
    }
    
    showSubListing = nil
    
    
;

/* 
 *   Ta en lista med objekt som tillhandahålls i objList och returnera en formaterad lista i en
 *   enda citerad sträng, efter att först ha sorterat objekten i objList i ordning
 *   av deras listOrder-egenskap.
 *
 *   Om nameProp-parametern tillhandahålls använder vi den egenskapen för namnet
 *   av varje objekt i listan; annars använder vi aName-egenskapen som standard.
 *
 *   Som standard separeras de två sista objekten i listan med 'och', men vi
 *   kan välja en annan konjunktion genom att tillhandahålla konjunktionsparametern.
 */ 
makeListStr(objList, nameProp = &aName, conjunction = 'och', suppressStateInfo = nil)
//makeListStr(objList, nameProp = &aName, conjunction = 'och')
{
    local lst = [];
    local i = 0;
    local obj;
    objList = valToList(objList);
    
    /* 
     *   Sortera listan efter listOrder, men bara om objekten den innehåller tillhandahåller
     *   egenskapen, och bara om de använder den för att definiera en ordning. Om alla
     *   objekt i listan har samma sortOrder vill vi inte blanda om
     *   dem ur deras ursprungliga ordning genom att utföra en onödig sortering.
     */       
    if(objList.length > 0 && objList[1].propDefined(&listOrder) &&
       objList.indexWhich({x: x.listOrder != objList[1].listOrder}))
        objList = objList.sort(SortAsc, {a, b: a.listOrder - b.listOrder});
    
    /* Gå igenom varje objekt i vår sorterade lista */
    for(i = 1, obj in objList ; ; ++i)
    {
        /* Markera det som nämnt i en lista */
        obj.mentioned = true;        
        
        /* Spara värdet av nameProp-egenskapen i en lokal variabel */
        local desc = obj.(nameProp);
        
        /* Lägg till all status-specifik information */
        if(!suppressStateInfo)
        {
            foreach(local state in obj.states)
                desc += state.getAdditionalInfo(obj);
        }

        /* Lägg till det utökade namnet till vår lista med strängar. */
        lst += desc;
    }
    
    
    /* 
     *   Notera om listan skulle göra ett singular eller plural grammatiskt
     *   subjekt om det hänvisades till med {prev}-taggen.
     */        
    if(objList.length > 1 || (objList.length > 0 && objList[1].plural))
        prevDummy_.plural = true;
    else
        prevDummy_.plural = nil;   
          
    
    /* 
     *   Om listan är tom returnera 'ingenting', annars använd genList()
     *   funktionen för att konstruera strängrepresentationen av listan och returnera
     *   det.
     */
    return lst == [] ? 'ingenting' : genList(lst, conjunction);
       
}

/* 
 *   Funktion att använda med <<mention a *>> strängmallen. Detta markerar
 *   objektet som nämnt i en rumbeskrivning och tillåter det att användas som
 *   föregångare till en {prev}-tagg, för att säkerställa verböverensstämmelse.
 */
mentionA(obj)
{
    /* Notera att objektet har nämnts */
    obj.mentioned = true;
    
    /* Notera att objektet har setts */
    obj.noteSeen();
    
    /* 
     *   Ställ in pluraliteten av prevDummy_-objektet till pluraliteten av
     *   objektet vi nämner (så att prevDummy_ kan användas för att säkra
     *   grammatisk överensstämmelse med ett efterföljande verb).
     */
    prevDummy_.plural = obj.plural;
    
    /* Returnera aName för vårt obj. */
    return obj.aName;    
}

mentionObj(obj)
{
    /* Note that the object has been mentioned */
    obj.mentioned = true;
    
    /* Note that the object has been seen */
    obj.noteSeen();
    
    /* 
     *   Set the plurality of the prevDummy_ object to the plurality of the
     *   object we're mentioning (so that prevDummy_ can be used to secure
     *   grammatical agreement with a subsequent verb).
     */
    prevDummy_.plural = obj.plural;
    
    /* Return the mentionName of our obj. */
    return obj.mentionName;
}



/* 
 *   Funktion att använda med <<mention the *>> strängmallen. Detta markerar
 *   objektet som nämnt i en rumbeskrivning och tillåter det att användas som
 *   föregångare till en {prev}-tagg, för att säkerställa verböverensstämmelse.
 */
mentionThe(obj)
{
    /* Notera att objektet har nämnts */
    obj.mentioned = true;
    
    /* Notera att objektet har setts */
    obj.noteSeen();
    
    /* 
     *   Ställ in pluraliteten av prevDummy_-objektet till pluraliteten av
     *   objektet vi nämner (så att prevDummy_ kan användas för att säkra
     *   grammatisk överensstämmelse med ett efterföljande verb).
     */
    prevDummy_.plural = obj.plural;
    
    /* Returnera theName för vårt obj. */
    return obj.theName;
}

/* 
 *   En version av makeListStr som bara använder en parameter, för användning av
 *   <<list of *>>strängmallen
 */
makeListInStr(objList)
{   
     return makeListStr(objList);    
}

/* 
 *   En version av makeListStr som använder theName-egenskapen, för användning av
 *   <<list of *>>strängmallen
 */
makeTheListStr(objList)
{    
    return makeListStr(objList, &theName);
}

/* 
 *   Funktion för användning med <<is list of *>> strängmallen, prefixar en
 *   lista med rätt form av verbet att vara för att matcha den grammatiska
 *   siffran i listan (t.ex. "Det finns en låda och en handske här" eller "Det finns
 *   låda här").
 */
isListStr(objList)
{
    return '{dummy} {är} ' + makeListStr(objList);
}
   
/*  
 *   Funktion för användning av <<list of * is>> strängmallen, som returnerar en
 *   formaterad lista följt av rätt form av verbet 'att vara' i
 *   grammatisk överensstämmelse med den listan.
 */
listStrIs(objList)
{    
    return makeListStr(objList) + ' {prev} {är}';
}


/*
 *   Konstruera en utskrivbar lista med strängar separerade med "eller"-konjunktioner.
 */
orList(lst)
{
    return genList(lst, 'eller');
}

/*
 *   Konstruera en utskrivbar lista med strängar separerade med "och"-konjunktioner.
 */
andList(lst)
{
    return genList(lst, 'och');
}

/*
 *   Allmän listkonstruktör 
 */
genList(lst, conj)
{
    /* börja med en tom sträng */
    local ret = new StringBuffer();

    /* kombinera eventuella dubbletter i listan */
    lst = mergeDuplicates(lst); 
   
    /* lägg till varje element */
    local i = 1, len = lst.length();
    foreach (local str in lst)
    {
        /* lägg till en separator om detta inte är det första objektet */
        if (i > 1)
        {
            if (len == 2)
                ret.append(' <<conj>> ');
            else if (i == len)
                ret.append(' <<conj>> ');
            else
                ret.append(', ');
        }

        /* lägg till detta objekt */
        ret.append(str);

        /* räkna objektet */
        ++i;
    }

    /* returnera strängen */
    return toString(ret);
}

/* 
 *   Ta en lista med strängar i formen ['en bok', 'en katt', 'en bok'] och slå samman
 *   dubblettobjekten för att returnera en lista i formen ['två böcker', 'en katt']
 */     
mergeDuplicates(lst)
{
    /* En vektor för att lagra objekt som har dubbletter */
    local dupVec = new Vector(10);
    
    /* Vektorn vi bygger för att returnera den bearbetade listan */
    local processedVec = new Vector(10);
    
    /* Gå igenom varje objekt i vår lista */
    foreach(local cur in lst)
    {
        /* 
         *   Om vi redan har behandlat detta objekt (eller ett identiskt med det),
         *   hoppa över det.
         */
        if(dupVec.indexOf(cur))
            continue;
        
        /*   Räkna hur många gånger det aktuella objektet förekommer i listan */
        local num = lst.countWhich({x: x == cur});
        
        /*   
         *   Om det inte förekommer mer än en gång, lägg helt enkelt till det i den bearbetade
         *   listan och fortsätt till nästa objekt.
         */
        if(num < 2)
        {
            processedVec.append(cur);
            continue;
        }
        
        /*  
         *   Annars få den lämpliga pluralen enligt antalet gånger objektet visas
         *   i listan; t.ex. om 'en guldmynt' visas tre gånger i listan, kommer pl att vara 'tre guldmynt'
         */
        
        local pl = makeCountedPlural(cur, num);
        {
            /* 
             *   Om makeCountedPlural()-funktionen returnerade det aktuella värdet
             *   oförändrat, lägg helt enkelt till det i den bearbetade listan, annars lägg till
             *   pluralformen till den bearbetade listan och den aktuella formen till
             *   listan över duplicerade objekt.
             */
            if(pl == cur)
                processedVec.append(cur);
            else
            {
                processedVec.append(pl);
                dupVec.append(cur);                    
            }
        }
        
    }
    
    /* Konvertera den bearbetade vektorn till en lista och returnera den */
    return processedVec.toList();
}

/* 
 *   Ta strängrepresentationen av ett namn (str) och ett nummer (num) och
 *   returnera en sträng med numret utskrivet och namnet pluraliserat, t.ex.
 *   makeCountPlural('en katt', 3) -> 'tre katter' Ändrad för att hantera den mer
 *   komplexa fallet ('ta myntet'), 3) -> 'ta tre mynt'); dvs. metoden ersätter nu numret
 *   för den första förekomsten av en artikel, om det finns en.
 */
makeCountedPlural(str, num)
{
    /* Dela upp strängen i en lista med ord för att göra det lättare att manipulera */
    local strList = str.split(' ');
    
    /* 
     *   Försök inte att pluralisera namnet om det inte innehåller singular
     *   obestämd artikel eller bestämd artikel
     */
    local idx = strList.indexWhich({s: s is in ('en', 'ett', 'den', 'det')});
    if(idx == nil)
        return str;

    /*  Ersätt numret med artikeln */
    strList[idx] = spellNumber(num);
    
    
    /* Leta efter någon del av namnet inom parentes */
    local idx1 = strList.indexWhich({x: x.startsWith('(')});
    local idx2 = strList.indexWhich({x: x.endsWith(')')});
    
    /* 
     *   Om namnet slutar med en sektion inom parentes, pluralisera delen av
     *   namnet före parenteserna och lägg sedan till den parentetiska
     *   sektionen.
     */    
    if(idx1 != nil && idx2 != nil && idx2 >= idx1 && idx2 == strList.length)
    {
        local plStr = strList.sublist(1, idx1 - 1).join(' ');
        local parStr = strList.sublist(idx1).join(' ');
        return LMentionable.pluralNameFrom(plStr) + ' ' + parStr;
    }
    
    /* Annars returnera hela strängen pluraliserad */
    return LMentionable.pluralNameFrom(strList.join(' '));
}

/* 
 *   Ta bort eventuell bestämd eller obestämd artikel som förekommer i början av
 *   txt och returnera den resulterande strängen i gemener.
 */
stripArticle(txt)
{
    txt = txt.toLower();
    
    txt = txt.findReplace(R'^(den|en|ett|några) ','');
    return txt;
}


/* ------------------------------------------------------------------------ */
/*
 *   avslutaSpel-alternativ. Vi tillhandahåller beskrivningar och nyckelord för
 *   alternativobjekten här, eftersom dessa är inneboende språkberoende.
 *   
 *   Observera att vi tillhandahåller hyperlänkar för våra beskrivningar när det är möjligt.
 *   När vi är i textläge kan vi inte visa länkar, så vi visar istället en alternativ form med
 *   den enstaka bokstavsresponsen markerad i texten. Vi markerar inte den enstaka bokstavsresponsen i
 *   den hyperlänkade versionen eftersom (a) om användaren vill ha en genväg kan de
 *   helt enkelt klicka på hyperlänken, och (b) de flesta användargränssnitt som visar hyperlänkar
 *   visar ett distinkt utseende för själva hyperlänken, så att lägga till ännu mer markeringar inom
 *   hyperlänken börjar se väldigt upptagen ut.  
 */
modify finishOptionQuit
    desc = '<<aHrefAlt('quit', 'QUIT', '<b>Q</b>UIT', 'Lämna berättelsen')>>'
    responseKeyword = 'quit'
    responseChar = 'q'
;

modify finishOptionRestore
    desc = '''<<aHrefAlt('restore', 'RESTORE', '<b>R</b>ESTORE',
            'Återställ en sparad position')>> en sparad position'''
    responseKeyword = 'restore'
    responseChar = 'r'
;

modify finishOptionRestart
    desc = '''<<aHrefAlt('restart', 'RESTART', 'RE<b>S</b>TART',
            'Starta om berättelsen från början')>> berättelsen'''
    responseKeyword = 'restart'
    responseChar = 's'
;

modify finishOptionUndo
    desc = '''<<aHrefAlt('undo', 'UNDO', '<b>U</b>NDO',
            'Ångra det senaste draget')>> det senaste draget'''
    responseKeyword = 'undo'
    responseChar = 'u'
;

modify finishOptionCredits
    desc = '''se <<aHrefAlt('credits', 'CREDITS', '<b>C</b>REDITS',
            'Visa krediter')>>'''
    responseKeyword = 'credits'
    responseChar = 'c'
;

modify finishOptionFullScore
    desc = '''se din <<aHrefAlt('full score', 'FULL SCORE',
            '<b>F</b>ULL SCORE', 'Visa fullständig poäng')>>'''
    responseKeyword = 'full score'
    responseChar = 'f'
;

modify finishOptionAmusing
    desc = '''se några <<aHrefAlt('amusing', 'AMUSING', '<b>A</b>MUSING',
            'Visa några roliga saker att prova')>> saker att prova'''
    responseKeyword = 'amusing'
    responseChar = 'a'
;

modify restoreOptionStartOver
    desc = '''<<aHrefAlt('start', 'START', '<b>S</b>TART',
            'Starta från början')>> spelet från början'''
    responseKeyword = 'start'
    responseChar = 's'
;

modify restoreOptionRestoreAnother
    desc = '''<<aHrefAlt('restore', 'RESTORE', '<b>R</b>ESTORE',
            'Återställ en annan sparad position')>> en annan sparad position'''
;

/* ------------------------------------------------------------------------ */
/* Engelskspråkig tillägg till defaultGround för att ge det lämplig vokabulär */

modify defaultGround
    vocab = 'mark;;golv'
;


/* ------------------------------------------------------------------------ */
/*
 *   Fråga efter en saknad substantivfras. Parsern anropar detta när spelaren
 *   anger ett kommando som utelämnar en nödvändig substantivfras, som PUT KEY eller
 *   bara TAKE.
 *   
 *   'cmd' är Command-objektet. De andra objekten i kommandot, om
 *   några, har lösts så mycket som möjligt när detta anropas.
 *   'roll' är NounRole-objektet som talar om för oss vilken predikatroll som saknas
 *   (DirectObject, IndirectObject, etc).
 *   
 *   [Krävs] 
 */
askMissingNoun(cmd, role)
{
    "\^<<nounRoleQuestion(cmd, role)>>?\n";
}

/*
 *   Fråga om hjälp med ett tvetydigt substantiv. Parsern anropar detta när
 *   spelaren anger en substantivfras som är tvetydig, och vi behöver be om
 *   förtydligande.
 *   
 *   'cmd' är kommandot, 'roll' är substantivfrasens roll i
 *   predikatet (DirectObject, etc), och 'nameList' är en lista med strängar
 *   bestämd av Distinguisher-processen.
 *   
 *   [Krävs] 
 */
askAmbiguous(cmd, role, names)
{
    /* 
     *   För direktobjektet eller aktörsrollen, håll det enkelt och fråga bara "vilken
     *   menar du".
     *   
     *   För andra roller, var mer specifik: använd den grundläggande predikat
     *   frågan för rollen, så det är tydligt vilket objekt vi frågar
     *   om. Ersätt 'vad' med 'vilken' i dessa frågor.  
     */
    local q;
    if (role is in (DirectObject, ActorRole))
        q = BMsg(which do you mean, 'Vilken menar du');
    else
        q = nounRoleQuestion(cmd, role)
        .findReplace('vad', 'vilken', ReplaceOnce);
    
    
    /* 
     *   Om alternativet att räkna upp dimabigiationsmöjligheterna är inställt, prefixa varje objekt i
     *   listan med ett nummer, förutsatt att vi har högst 20 alternativ (parsern verkar inte kunna
     *   hantera mer än så).
     */
    if(libGlobal.enumerateDisambigOptions && names.length < 20)
    {
        /* Ställ in en ny lista för att hålla de numrerade namnen */
        local numbered_names = [];
        
        /* Det aktuella objektet i listan med namn */
        local item;
        
        /* För varje objekt i listan med namn, lägg till dess nummer i listan. */
        for(local i in 1 .. names.length)
        {
            /* 
             *   Lägg till numret som representerade platsen i listan till namnet på objektet i
             *   listan.
             */
            item = '<b>(' + toString(i) + ')</b> ' + names[i];
            
            /* Lägg till det numrerade objektet i listan med numrerade namn; */
            numbered_names += item;
        }
        
        /* Kopiera den numrerade listan till den ursprungliga listan med namn. */
        names = numbered_names;
        
        /* Notera antalet tillgängliga val. */
        libGlobal.disambigLen = names.length;
    }
    
    /* ställ frågan */
    "\^<<q>>, <<orList(names)>>?\n";
}

/*
 *   Få den grundläggande frågan för en substantivroll. Detta vänder på verbet
 *   till en fråga om en av dess roller. Till exempel, för (Open,
 *   DirectObject), skulle vi returnera "vad vill du öppna". För (AttachTo
 *   IndirectObject), "vad vill du ansluta det till".  
 */
nounRoleQuestion(cmd, role)
{
    /* hämta den saknade frågan från verbet och dela upp den i dess delar */
    local q = cmd.verbProd.missingQ.split(';');

    /* plocka ut den lämpliga frågan */
    q = q[role == DirectObject ? 1 : role == IndirectObject ? 2 : 3];

    /* den underförstådda ordningen av objektreferenserna är dobj-iobj-acc */
    local others = [DirectObject, IndirectObject, AccessoryObject];
    local otheridx = 1;

    /* ställ in ersättningsfunktionen */
    local f = function(match, idx, str) {

        /* få den uttryckliga eller underförstådda andra-objektsrollen */
        local r;
        if (rexGroup(3) != nil)
        {
            r = rexGroup(3)[3];
            r = (r == 'dobj' ? DirectObject :
                 r == 'iobj' ? IndirectObject :
                 AccessoryObject);
        }
        else
        {
            /* 
             *   nej -rollsuffix, så det är underförstått: få nästa roll, men
             *   hoppa över rollen vi frågar om 
             */
            while ((r = others[otheridx++]) == role) ;
        }

        /* få prepositionen, om den tillhandahålls */
        local prep = (rexGroup(1) != nil ? rexGroup(1)[3].substr(2) : '');

        /* returnera substantivfrasen */
        return npListPronoun(rexGroup(2)[3], cmd.(r.npListProp), prep);
    };

    /* ersätt varje annan-objektfras och returnera resultatet */    
   return q.findReplace(
        R'(<lparen><alpha|space>+)?%<(det|detta)(-<alpha>+)?%><rparen>?',
        f).trim();   
   
}

/* Fråga efter en saknad bokstav för en LiteralAction eller LiteralTAction */
askMissingLiteralQ(action, role)
{
    "\^<<literalRoleQuestion(action, role)>>?\n";
}

/* 
 *   Få frågan att ställa för en saknad bokstav. Vi gör detta mer direkt än för en
 *   saknat substantiv, eftersom sammanhanget vanligtvis ger mindre information. Åtgärdsparametern kan vara
 *   antingen den åtgärd vi vill utföra (som den är när den anropas av biblioteket) eller en
 *   motsvarande Command-objekt) tillåtet för konsekvens med askMissingNoun).
 */
literalRoleQuestion(action, role)
{
    /* Om åtgärdsargumentet tillhandahölls som ett kommando, extrahera den associerade åtgärden. */
    if(action.ofKind(Command))
        action = action.action;
    
    /* hämta den saknade frågan från verbet och dela upp den i dess delar */
    local q = action.verbRule.missingQ.split(';');

    /* plocka ut den lämpliga frågan */
    q = q[role == DirectObject ? 1 : role == IndirectObject ? 2 : 3];

    /* Returnera resultatet */
    return q;    
}



/* 
 *   Tillkännage vårt val av objekt när askForIobj() eller askForDobj() väljer det
 *   bästa valet på spelarens vägnar. Vi hittar delen av verbPhrase
 *   lämplig för direkt- eller indirekt objekt (t.ex. '(vad)' eller '(på vad)')
 *   och ersätt 'vad' med objektets namn.
 */
announceBestChoice(action, obj, role)
{    
    /* Strängen för att visa objektmeddelandet */
    local ann;
    
    /* Hämta verbfrasen för åtgärden */
    local vp = action.verbRule.verbPhrase;
    
    /* 
     *   Ställ in ett rex-mönster för att söka efter den kortaste matchningen till något i
     *   parenteser.
     */
    local pat = R'(<lparen>.*?<rparen>)';
    
    /* Plocka ut den första parentessektionen */
    local rm = rexSearch(pat, vp);
    
    /* 
     *   Some VerbRules (notably VerbRule(LookUp) for the ConsultAbout action) reverse the dobj and
     *   iobj roles in their notional grammatical slots. We need to correct for this reversal in
     *   extracting the correct section of the verb rule's verbPhrase for the purpose of this object
     *   announcement.
     */
    if(role == DirectObject && action.verbRule.rolesReversed)
        role = IndirectObject;        

    /* 
     *   Om vi letar efter det indirekta objektet, plocka ut nästa
     *   parentessektion
     */
    if(role == IndirectObject)
        rm = rexSearch(pat, vp, rm[1] + rm[2]);
    
    /*  Ersätt 'vad' med objektets namn */
    ann = rm[3].findReplace('vad', obj.abcName(action, role));
    
    /* 
     *   Även om vi förmodligen vill att meddelandet ska vara inneslutet i parenteser, bör detta definieras av
     *   <.aasume> stiltaggen, så vi ersätter de omgivande parenteserna med
     *   lämpliga stiltaggar.
     */
    ann = ann.findReplace('(', '<.assume>');
    ann = ann.findReplace(')', '<./assume>');
    
    /*  Visa meddelandet */
    "<<ann>>\n";
}

/*
 *   Få pronomenet för en löst (eller delvis löst) NounPhrase-lista
 *   från ett kommando. 
 */
npListPronoun(pro, nplst, prep)
{
    /* 
     *   prepositionen börjar med '(', det betyder att vi ska utelämna denna roll
     *   från frågor om andra roller 
     */
    if (prep.startsWith('('))
        return '';

    /* om det inte finns någon substantivfras, returnera ingenting */
    if (nplst.length() == 0)
        return '';

    /* om vi har mer än en substantivfras är det uppenbarligen 'dem' */
    if (nplst.length() > 1)
        return '<<prep>> dem';

    /* vi har en enda substantivfras - hämta den */
    local np = nplst[1];

    /* om det uttryckligen hänvisar till flera objekt, använd 'dem' */
    if (np.matches.length() > 1 && np.isMultiple())
        return '<<prep>> dem';

    /* gå igenom matchningarna och kontrollera kön */
    local him = true, her = true, them = true;
    foreach (local m in np.matches)
    {
        if (!m.obj.isHim)
            him = nil;
        if (!m.obj.isHer)
            her = nil;
        if (!m.obj.plural)
            them = nil;
    }

    /* om alla matchningar är överens om ett pronomen, använd det, annars använd 'det' */
    if (them)
        return '<<prep>> dem';
    if (him)
        return '<<prep>> honom';
    if (her)
        return '<<prep>> henne';
    else
        return '<<prep>> <<pro>>';
}

/* 
 *   libMessages-objektet innehåller ett antal meddelanden/strängvärden som behövs
 *   av menysystemet och WebUI. Det används inte för några andra bibliotek
 *   meddelanden.
 */
libMessages: object
    
    /*
     *   Kommandonyckellista för menysystemet. Detta använder formatet
     *   definierad för MenuItem.keyList i menysystemet. Nycklar måste vara
     *   ges som gemener för att matcha inmatning, eftersom menyn
     *   systemet konverterar inmatningstangenter till gemener innan nycklar matchas till
     *   denna lista.  
     *   
     *   Observera att det första objektet i varje lista är vad som kommer att ges i
     *   navigationsmenyn, vilket är anledningen till att den femte listan innehåller 'ENTER'
     *   som sitt första objekt, även om detta aldrig kommer att matcha en tangenttryckning.
     */
    menuKeyList = [
                   ['q'],
                   ['p', '[left]', '[bksp]', '[esc]'],
                   ['u', '[up]'],
                   ['d', '[down]'],
                   ['ENTER', '\n', '[right]', ' ']
                  ]

    /* länk titel för 'föregående meny' navigeringslänk */
    prevMenuLink = '<font size=-1>Föregående</font>'

    /* länk titel för 'nästa ämne' navigeringslänk i ämneslistor */
    nextMenuTopicLink = '<font size=-1>Nästa</font>'

    /*
     *   huvudprompttext för textlägesmenyer - detta visas varje
     *   gång vi ber om en tangenttryckning för att navigera i en meny i textläge 
     */
    textMenuMainPrompt(keylist)
    {
        "\bVälj ett ämnesnummer eller tryck på &lsquo;<<
        keylist[M_PREV][1]>>&rsquo; för föregående
        meny eller &lsquo;<<keylist[M_QUIT][1]>>&rsquo; för att avsluta:\ ";
    }

    /* prompttext för ämneslistor i textlägesmenyer */
    textMenuTopicPrompt()
    {
        "\bTryck på mellanslagstangenten för att visa nästa rad,
        &lsquo;<b>P</b>&rsquo; för att gå till föregående meny, eller
        &lsquo;<b>Q</b>&rsquo; för att avsluta.\b";
    }

    /*
     *   Positionsindikator för ämneslistobjekt - detta visas efter
     *   ett ämneslistobjekt för att visa det aktuella objektnumret och det totala
     *   antalet objekt i listan, för att ge användaren en uppfattning om var
     *   de är i den övergripande listan.  
     */
    menuTopicProgress(cur, tot) { " [<<cur>>/<<tot>>]"; }

    /*
     *   Meddelande att visa i slutet av en ämneslista. Vi visar
     *   detta efter att vi har visat alla tillgängliga objekt från en
     *   MenuTopicItems lista med objekt, för att låta användaren veta att det
     *   finns inga fler objekt tillgängliga.  
     */
    menuTopicListEnd = '[Slutet]'

    /*
     *   Meddelande att visa i slutet av ett "långt ämne" i menyn
     *   system. Vi visar detta i slutet av det långa ämnets
     *   innehåll.  
     */
    menuLongTopicEnd = '[Slutet]'

    /*
     *   instruktionstext för bannerlägesmenyer - detta visas i
     *   instruktionsfältet högst upp på skärmen, ovanför menyn
     *   bannerområde 
     */
    menuInstructions(keylist, prevLink)
    {
        "<tab align=right ><b>\^<<keylist[M_QUIT][1]>></b>=Avsluta <b>\^<<
        keylist[M_PREV][1]>></b>=Föregående meny<br>
        <<prevLink != nil ? aHrefAlt('previous', prevLink, '') : ''>>
        <tab align=right ><b>\^<<keylist[M_UP][1]>></b>=Upp <b>\^<<
        keylist[M_DOWN][1]>></b>=Ner <b>\^<<
        keylist[M_SEL][1]>></b>=Välj<br>";
    }

    /* visa en 'nästa kapitel'-länk */
    menuNextChapter(keylist, title, hrefNext, hrefUp)
    {
        "Nästa: <<aHref(hrefNext, title)>>;
        <b>\^<<keylist[M_PREV][1]>></b>=<<aHref(hrefUp, 'Meny')>>";
    }

    
    /* 
     *   Standard dialogtitlar, för WebUI. Dessa visas i
     *   titelområdet i WebUI-dialogrutan som används för inputDialog()-anrop.
     *   Dessa motsvarar InDlgIconXxx-ikonerna. De konventionella
     *   tolkarna använder inbyggda titlar när titlar behövs alls,
     *   men i WebUI måste vi generera dessa själva. 
     */
    dlgTitleNone = 'Notera'
    dlgTitleWarning = 'Varning'
    dlgTitleInfo = 'Notera'
    dlgTitleQuestion = 'Fråga'
    dlgTitleError = 'Fel'

    /*
     *   Standard dialogknappetiketter, för WebUI. Dessa är inbyggda
     *   till de konventionella tolkarna, men i WebUI måste vi
     *   generera dessa själva.  
     */
    dlgButtonOk = 'OK'
    dlgButtonCancel = 'Avbryt'
    dlgButtonYes = 'Ja'
    dlgButtonNo = 'Nej'
    
      /* webUI-varning när en ny användare har gått med i en multi-användarsession */
    webNewUser(name) { "\b[<<name>> har gått med i sessionen.]\n"; }
    
    
    /*
     *   Varningsprompt för inputFile()-varningar som genereras vid läsning av en
     *   skriptfil, för WebUI. Tolken visar normalt
     *   dessa varningar direkt, men i WebUI-läge är programmet
     *   ansvarig, så vi behöver lokaliserade meddelanden.  
     */
    inputFileScriptWarning(warning, filename)
    {
        /* ta bort den tvåbokstaviga felkoden i början av strängen */
        warning = warning.substr(3);

        /* bygg meddelandet */
        return warning + ' Vill du fortsätta?';
    }
    inputFileScriptWarningButtons = [
        '&Ja, använd den här filen', '&Välj en annan fil', '&Stoppa skriptet']
    
    /* WebUI inputFile-fel: uppladdad fil är för stor */
    webUploadTooBig = 'Filen du valde är för stor för att ladda upp.'
   
 
;


/* 
 *   gör ett felmeddelande till en mening genom att versalisera den första bokstaven och
 *   lägga till en punkt i slutet om den inte redan har en
 */
makeSentence(msg)
{
    return rexReplace(
        ['^<space>*[a-z]', '(?<=[^.?! ])<space>*$'], msg,
        [{m: m.toUpper()}, '.']);
}

/* 
 *   Dummy-objektet används för att tillhandahålla en {dummy}-parameter i ett meddelande
 *   parameterersättning för att tillhandahålla ett grammatiskt subjekt i en mening för
 *   vilket inget faktiskt spelobjekt är tillgängligt; t.ex. "Det {dummy}{är}
 *   ingenting här" ger ett subjekt för {är} utan att visa någon text.
 */
modify dummy_ 
    dummyName = ''
    name = ''
    noteName(src)
    {
        name = src;
    }
;

/*  
 *   pluralDummy_ har samma funktion som dummy_ när ett pluraliskt subjekt är
 *   krävs i en mening.
 */
modify pluralDummy_ 
    dummyName = ''
    name = ''
    noteName(src)
    {
        name = src;
    }
    
    plural = true
;


/* 
 *   prevDummy_ används av {prev}-meddelandeparameterersättningen för att möjliggöra en
 *   efterföljande verb att överensstämma med en tidigare lista definierad genom en av
 *   strängmallarna.
 */
prevDummy_: Mentionable
    dummyName = ''
    name = ''
    noteName(src)
    {
        name = src;
    }
    
    plural = true    
;

/* 
 *   När aktören har flera verb per mening kan vi använda detta för att hålla expansionen på
 *   spår.
 */
actorActionContinuer_: dummy_ {
    person = (gActor == nil ? 3 : gActor.person)
    plural = (gActor == nil ? nil : gActor.plural)
}



/* ------------------------------------------------------------------------ */
/*
 *   Meddelandeparametrar-objektet. Språkmodulen måste tillhandahålla en
 *   instans av MessageParams, för att fylla i den språk specifika listan över
 *   parameternamn och expansionsfunktioner.
 *   
 *   [Krävs] 
 */
swedishMessageParams: MessageParams
    /*
     *   Språkets allmänna meningsordning. Detta bör vara en sträng
     *   innehållande bokstäverna S, V och O i lämplig ordning för
     *   språket. S är för Subjekt, V är för Verb och O är för
     *   Objekt. Till exempel är engelska ett SVO-språk, eftersom den
     *   allmänna ordningen för en engelsk mening är Subjekt Verb Objekt.
     *   
     *   Detta kan lämnas som nil för språk utan någon rådande menings
     *   ordning.  
     */
    sentenceOrder = 'SVO'

    /*
     *   De engelska parametermappningarna. Basbiblioteket använder inte någon
     *   av dessa direkt, så parameternamn och mappningar är helt upp till
     *   språkmodulen. Den enda delen av biblioteket som använder
     *   parametrarna är bibliotekets meddelandesträngar, som alla är
     *   definierade av språkmodulen själv. Andra översättningar är
     *   fria att använda olika parameternamn och behöver inte replikera
     *   1-för-1 de parametrar som definieras för engelska. Översättningar behöver bara
     *   definiera de parametrar som behövs för deras egna bibliotek
     *   meddelanden (plus eventuella andra de vill tillhandahålla för användning av spel
     *   författare, naturligtvis).
     *   
     *   [Krävs] 
     */
    params = [

        /*
         *   {curobj namngivetobj} — sätt ctx.curObj utan att skriva ut något.
         *   Används när adjektivkongruens ({conjadj}) ska ske mot ett objekt som
         *   varken är cmd.dobj eller actor. Kräver gMessageParams(obj) först.
         *
         *   ctx är lokalt per strängexpansion och firgörs när expansionen är klar.
         *
         *   Exempel på användning (subLister.showListPrefix):
         *      ...
         *      gMessageParams(container);
         *      " (<<container.objInPrep>> {curobj container}{conjadj vilk en/et/a} {är} ";
         *      ...
         */
        ['curobj', function(ctx, params) {
            ctx.curObj = findStrParam(params[2], vObject);
            return '';
        }],

        /* {lb} är en bokstavlig vänsterparentes */
        [ 'lb', { ctx, params: '{' } ],

        /* {rb} är en bokstavlig högerparentes */
        [ 'rb', { ctx, params: '}' } ],

        /* {bar} är en bokstavlig vertikal stapel */
        [ 'bar', { ctx, params: '|' } ],

        /* 
         *   {s}, {es} och {ies} är kontextkänsliga pluraländelser:
         *   dessa expanderar till ingenting om den föregående parametern var
         *   singular, eller 's', 'es' och 'ies' om plural. Om den föregående
         *   parametern var ett numeriskt värde, 1 är singular och allt annat
         *   är plural; om det var en Mentionable, 'plural'-egenskapen
         *   bestämmer det.  
         */

        // t ex: trycker/tryckte, tänder/tände
        [ 'er/te', { ctx, params: Narrator.tense == Present ? 'er' : 'te' } ],
        [ 'er/e', { ctx, params: Narrator.tense == Present ? 'er' : 'e' } ],
        

        /* {den}/{det}/{de} väljer den/det/de baserat på dobj:s genus och numerus.
         * Alla tre är synonyma determinativer — se {de}-funktionen längre ned för
         * varför {de} även hanterar pronomenanvändningen {de obj}. */
        [ 'den', { ctx, params: ctx.cmd.dobj.plural? 'de' : ctx.cmd.dobj.isNeuter? 'det' : 'den' } ],
        [ 'det', { ctx, params: ctx.cmd.dobj.plural? 'de' : ctx.cmd.dobj.isNeuter? 'det' : 'den' } ],

        [ 'detta', { ctx, params: ctx.cmd.dobj.plural? 'dessa' : ctx.cmd.dobj.isNeuter? 'detta' : 'denna' } ],
        [ 'dessa', { ctx, params: ctx.cmd.dobj.plural? 'dessa' : ctx.cmd.dobj.isNeuter? 'detta' : 'denna' } ],
        [ 'denna', { ctx, params: ctx.cmd.dobj.plural? 'dessa' : ctx.cmd.dobj.isNeuter? 'detta' : 'denna' } ],
        [ 'dehär', { ctx, params: ctx.cmd.dobj.plural? 'de här' : ctx.cmd.dobj.isNeuter? 'det här' : 'den här' } ],
        [ 'dethär', { ctx, params: ctx.cmd.dobj.plural? 'de här' : ctx.cmd.dobj.isNeuter? 'det här' : 'den här' } ],
        [ 'denhär', { ctx, params: ctx.cmd.dobj.plural? 'de här' : ctx.cmd.dobj.isNeuter? 'det här' : 'den här' } ],

        /* {1} till {9} ersätter bokstavliga textsträngsargument 1-9 */
        [ '1',
         { ctx, params: ctx.paramToString(ctx.noteParam(ctx.args[1])) } ],
        [ '2',
         { ctx, params: ctx.paramToString(ctx.noteParam(ctx.args[2])) } ],
        [ '3',
         { ctx, params: ctx.paramToString(ctx.noteParam(ctx.args[3])) } ],
        [ '4',
         { ctx, params: ctx.paramToString(ctx.noteParam(ctx.args[4])) } ],
        [ '5',
         { ctx, params: ctx.paramToString(ctx.noteParam(ctx.args[5])) } ],
        [ '6',
         { ctx, params: ctx.paramToString(ctx.noteParam(ctx.args[6])) } ],
        [ '7',
         { ctx, params: ctx.paramToString(ctx.noteParam(ctx.args[7])) } ],
        [ '8',
         { ctx, params: ctx.paramToString(ctx.noteParam(ctx.args[8])) } ],
        [ '9',
         { ctx, params: ctx.paramToString(ctx.noteParam(ctx.args[9])) } ],

        /* {# n} - stavar numret som ges av heltalsargument n (1-9) */
        [ '#', { ctx, params:
         spellNumber(ctx.paramToNum(ctx.noteParam(
             ctx.args[toInteger(params[2])]))) } ],

        /* 
         *   {and n} - visar listan som ges av heltalsargument n (1-9) som
         *   en grundläggande "och"-lista ("x, y och z")
         */
        [ 'och', { ctx, params:
         andList(ctx.noteParam(ctx.args[toInteger(params[2])])
                 .mapAll({ x: ctx.paramToString(x) })) } ],

        /* 
         *   {or n} - visar listan som ges av heltalsargument n (1-9) som en
         *   grundläggande "eller"-lista ("x, y eller z") 
         */
        [ 'eller', { ctx, params:
         orList(ctx.noteParam(ctx.args[toInteger(params[2])])
                .mapAll({ x: ctx.paramToString(x) })) } ],
        

        /* {Jag} är adressatens namn i subjektiv form */
        [ 'jag',  { ctx, params: cmdInfo(ctx, &actor, &theName, vSubject) } ],
        [ 'du',  { ctx, params: cmdInfo(ctx, &actor, &theName, vSubject) } ],

        /* {me} är adressatens namn i objektiv form */
        
        // TODO: blir reflexivt "dig själv"
        [ 'mig', { ctx, params: cmdInfo(ctx, &actor, &theObjName, vObject) } ],
        [ 'dig', { ctx, params: cmdInfo(ctx, &actor, &theObjName, vObject) } ],
        [ 'sig', { ctx, params: cmdInfo(ctx, &actor, &theObjName, vObject) } ],
        
        [ 'obj', { ctx, params: cmdInfo(ctx, params[2], &theObjName, vObject) } ],

        /*
         *   {min} är possessivt adjektiv för adressaten: "min bok", "ditt skåp".
         *
         *   Notera: i engelska skiljer man på possAdj ("my") och possNoun ("mine").
         *   I svenska är formerna identiska — "min bok" och "boken är min" använder
         *   samma ord — så possNoun-varianten är redundant och har tagits bort.
         *   possAdj väljs som den semantiskt korrekta egenskapen eftersom {min}
         *   nästan alltid förekommer attributivt (före ett substantiv) i meddelandesträngar.
         */
        [ 'min', { ctx, params: cmdInfo(ctx, &actor, &possAdj, vPossessive) } ],

        /*
         *   {poss ägare ägt} — possessivt adjektiv med kongruens med det ägda objektet.
         *   Väljer possAdj/possAdjT/possAdjPl beroende på ägt.plural/ägt.isNeuter.
         *
         *   Bakgrund — herName-problemet: herName = pronoun().possAdj ger alltid
         *   utrum-formen (t.ex. "din", "min") oavsett ägt objekts genus, eftersom
         *   herName inte vet vilket substantiv den ska modifiera. Substitutet {hans actor}
         *   använder herName och ger felaktigt "din" även när det ägda objektet är neutrum
         *   (borde vara "ditt") eller plural (borde vara "dina"). {poss actor dobj} löser
         *   detta genom att välja rätt form baserat på dobj.isNeuter och dobj.plural.
         */
        [ 'poss', function(ctx, params) {
            local ownedSrc = params[3];
            local ownedObj = nil;
            if (dataType(ownedSrc) == TypeSString) {
                if (rexMatch(R'<digit>+', ownedSrc) != nil)
                    ownedObj = ctx.args[toInteger(ownedSrc)];
                else
                    ownedObj = findStrParam(ownedSrc, vObject);
            } else if (dataType(ownedSrc) == TypeObject)
                ownedObj = ownedSrc;
            local prop = (ownedObj != nil && ownedObj.plural) ? &possAdjPl
                       : (ownedObj != nil && ownedObj.isNeuter) ? &possAdjT
                       : &possAdj;
            return cmdInfo(ctx, params[2], prop, vPossessive);
        } ],
        
        /* {jagsjälv} är det reflexiva pronomenet för adressaten */
        [ 'jagsjälv', { ctx, params: cmdInfo(ctx, &actor, &reflexiveName, vObject) } ],

        /* {vi} är adressatens namn i subjektiv form */
        [ 'vi',  { ctx, params: cmdInfo(ctx, &actor, &theName, vSubject) } ],

        /* {oss} är adressatens namn i objektiv form */
        [ 'oss', { ctx, params: cmdInfo(ctx, &actor, &theObjName, vObject) } ],

        /* {vår} är ett possessivt adjektiv för adressaten */
        [ 'vår', { ctx, params: cmdInfo(ctx, &actor, &possAdj, vPossessive) } ],

        /* {våran} är ett possessivt adjektiv för adressaten (plural/grupp-form) */
        [ 'våran', { ctx, params: cmdInfo(ctx, &actor, &possAdj, vPossessive) } ],
        
        /* 
         *   {dummy} tillhandahåller ett singulariskt subjekt för ett efterföljande verb utan
         *   att visa någon text
         */
        [ 'dummy', { ctx, params: cmdInfo(ctx, dummy_, &dummyName, vSubject) } ],
        
        /* 
         *   {sing} tillhandahåller ett singulariskt subjekt för ett efterföljande verb utan
         *   att visa någon text
         */
        [ 'sing', { ctx, params: cmdInfo(ctx, dummy_, &dummyName, vSubject) } ],
        
        /* 
         *   {plural} tillhandahåller ett pluraliskt subjekt för ett efterföljande verb utan
         *   att visa någon text
         */
        [ 'plural', { ctx, params: cmdInfo(ctx, pluralDummy_, &dummyName, vSubject) } ],
        
        /*
         *   {prev} och {aac} är bortkommenterade eftersom svenska verb inte
         *   böjs efter subjektets person eller numerus. Den subjektsinformation
         *   de bär (listans pluralitet resp. aktörens person/numerus) påverkar
         *   aldrig vad som skrivs ut. I engelska är distinktionen meningsfull
         *   ("walks and falls" vs "walk and fall"); i svenska är verbformen
         *   densamma oavsett subjekt.
         *
         *   {prev}: sätter ctx.subj till prevDummy_, vars plural-flagga speglar
         *   senast nämnda listas numerus. Används i engelska för att låta ett
         *   efterföljande verb kongruera med en lista, t.ex. "there {prev} {is}
         *   a box" vs "there {prev} {are} boxes".
         *
         *   {aac} (actor action continuer): sätter ctx.subj till
         *   actorActionContinuer_, som dynamiskt läser gActor.person/plural.
         *   Tänkt för meningar med flera verb: "{Du} skriker och {aac} släpper
         *   taget." I engelska avgör detta verbformen; i svenska inte.
         */
        //[ 'prev', { ctx, params: cmdInfo(ctx, prevDummy_, &dummyName, vSubject) } ],
        //[ 'aac', { ctx, params: cmdInfo(ctx, actorActionContinuer_, &dummyName, vSubject) } ],

        /* 
         *   {här} är adressatens plats, i förhållande till PC:n.
         *   
         *   Om aktören är PC:n översätts detta till "här" för nuvarande
         *   tid, och "där" för andra tider. Vi använder "där" för
         *   tider utom nuet eftersom andra tider inför en
         *   avstånd mellan berättelsen och händelserna. När
         *   berättelsen är separerad från händelserna i tid, är det
         *   implicit separerad i rymden också. Att säga "här" i det
         *   förfluten tid verkar antyda att berättaren står vid en
         *   senare tidpunkt på samma plats där händelserna ägde rum.
         *   Att byta till "där" fixar detta genom att göra den rumsliga platsen
         *   av berättelsen obestämd på samma sätt som tiden gör
         *   den temporala platsen obestämd.
         *   
         *   Om aktören är en NPC översätts detta till ingenting alls (vi
         *   använder den speciella "backspace"-notationen för att radera eventuella föregående
         *   utrymme). Vi skulle kunna säga något som "där" eller "i köket" eller "där Bob är", men det verkar vanligtvis mer tilltalande
         *   att inte säga något alls i dessa fall. När en annan aktör är
         *   specifikt nämnd, är implikationen att vi pratar
         *   om den aktörens plats är vanligtvis tillräckligt stark för att det
         *   verkar överflödigt att ange det uttryckligen.  
         */
        [ 'här',
         { ctx, params:
           ctx.actorIsPC() ? (Narrator.tense == Present ? 'här' : 'där') :
           '\010' } ],
        
        /*[ 'here',
         { ctx, params:
           ctx.actorIsPC() ? (Narrator.tense == Present ? 'here' : 'there') :
           '\010' } ],*/
        /*
         *   {then} översätts till "nu" om vi är i nuvarande tid,
         *   "då" annars. 
         */
        [ 'då',
         { ctx, params: Narrator.tense == Present ? 'nu' : 'då' } ],

        /*
         *   {now} översätts till "nu" om vi är i nuvarande tid,
         *   ingenting annars. Det finns tillfällen då vi vill lägga till "nu"
         *   till en tanke, men mer som en smakpartikel än som en exakt
         *   specifikation av tid: "Du kan inte göra det nu". Smak
         *   partikeln verkar inte ha någon motsvarighet i andra tider,
         *   så det är bättre att bara lämna det helt: "Du kunde inte göra
         *   det".  
         */
        [ 'nu',
         { ctx, params: Narrator.tense == Present ? 'nu' : '\010' } ],

        /*
         *   Engelska
         *   {the subj obj} - namn, subjektiv form
         *.  {the obj} - namn, objektiv form
         *.  {the obj's} - namn, possessiv form

         *   Svenska
         *   {ref subj obj} - namn, subjektiv form
         *.  {ref obj}      - namn, objektiv form
         *.  {ref objs}     - namn, possessiv form

         */
        [ 'ref', function(ctx, params) {
            if (params[2] == 'subj') {
                return cmdInfo(ctx, params[3], &theName, vSubject);
            } else if (params[2].endsWith('s')) {
                //return cmdInfo(ctx, params[2].left(-2), &possAdj, vObject);
                return cmdInfo(ctx, params[2].left(-1), &possAdj, vObject);
            } else {
                return cmdInfo(ctx, params[2], &theObjName, vAmbig);
            }
        }
        ],

        /* Motsvarar 'name' i den engelska versionen */
        ['namn', function(ctx, params) {
        
        if (params[2] == 'subj')
           return cmdInfo(ctx, params[3], &name, vSubject);
        else if (params[2].endsWith('\'s'))
           return cmdInfo(ctx, params[2].left(-2), &possAdj, vObject);
        else
           return cmdInfo(ctx, params[2], &name, vAmbig);
        }
        ],

        /*
         *   {ett subj obj} - aName, subjektiv form
         *.  {ett obj} - namn, objektiv form         
         */
        [ 'ett', function(ctx, params) {
        
        if (params[2] == 'subj')
           return cmdInfo(ctx, params[3], &aName, vSubject);       
        else
           return cmdInfo(ctx, params[2], &aName, vAmbig);
        }
        ],
    
        /*
         *   {en subj obj} - aName, subjektiv form
         *.  {en obj} - namn, objektiv form         
         */
        [ 'en', function(ctx, params) {
            if (params[2] == 'subj') {
                return cmdInfo(ctx, params[3], &aName, vSubject);       
            } else {
                return cmdInfo(ctx, params[2], &aName, vAmbig);
            }
        
        }
        ],
    
        /* 
         *   {i obj} - den lämpliga innehållsprepositionen (i, på, under
         *   eller bakom) följt av theName för objektet (t.ex. 'i
         *   badet')
         */
        [ 'i', { ctx, params: cmdInfo(ctx, params[2], &objInName, vObject) } ],

        /* {platsprep obj} objInPrep (i, på, under eller bakom) för obj */
        ['platsprep' , { ctx, params: cmdInfo(ctx, params[2], &objInPrep, vObject) } ], 

    /* 
     *   {inuti obj} - den lämpliga rörelseprepositionen (in i, på, under eller
     *   bakom) följt av theName för objektet (t.ex. 'in i badet')
     */
        [ 'inuti', { ctx, params: cmdInfo(ctx, params[2], &objIntoName, vObject) } ],

    /* 
     *   {utur obj} den lämpliga utgångsprepositionen följt av theName för obj, t.ex. 'ut ur
     *   badet'
     */ 
        ['utur', { ctx, params: cmdInfo(ctx, params[2], &objOutOfName, vObject) } ],

    /* {han obj} - pronomen, subjektiv form */
        [ 'han',
        { ctx, params: cmdInfo(ctx, params[2], &heName, vSubject) } ],

    /* {hon obj} - pronomen, subjektiv form */
        [ 'hon',
        { ctx, params: cmdInfo(ctx, params[2], &heName, vSubject) } ],

    /*
     *   {de} — dubbel användning: determinativ utan argument, pronomen med argument.
     *
     *   Som determinativ (inget argument): {de} väljer den/det/de baserat på dobj:s
     *   genus och numerus, precis som {den} och {det} gör. Alla tre är synonyma
     *   determinativer — skillnaden är bara vilken form spelaren skriver i meddelandet.
     *
     *   Som pronomen (med argument): {de obj} returnerar subjektivt pronomen för obj
     *   (han/hon/den/det/de), precis som {han obj} och {hon obj}.
     *
     *   Varför en funktion i stället för två separata token-poster?
     *   Token-nycklar är unika: en andra post med nyckeln 'de' vore död kod —
     *   params-listan är en sekventiell sökning och den tidigare träffen vinner.
     *   'de' kolliderar naturligt med sin pronomenform ('de gick hem') och sin
     *   determinativform ('de stora husen'). Samma kollision uppstår inte för {den}
     *   och {det} eftersom deras pronomenformer stavas 'dem' ({dem obj}), inte 'den'
     *   eller 'det'. För 'de' sammanfaller bestämd determinativ och subjektivt
     *   pronomen i skriven form, varför vi löser ambiguiteten i en funktion:
     *   ges ett objekt-argument beter den sig som pronomen; annars som determinativ.
     */
        [ 'de', function(ctx, params) {
            if (params.length >= 2)
                return cmdInfo(ctx, params[2], &heName, vSubject);
            else
                return ctx.cmd.dobj.plural? 'de'
                    : ctx.cmd.dobj.isNeuter? 'det' : 'den';
        } ],

    
        /* {honom obj} - pronomen, objektiv form */
        [ 'honom',
         { ctx, params: cmdInfo(ctx, params[2], &himName, vObject) } ],

     /* {dem obj} - pronomen, objektiv form */
        [ 'dem',
         { ctx, params: cmdInfo(ctx, params[2], &himName, vObject) } ],

        /*
         *   Possessiva pronomen för tredje person: {hans obj}, {hennes obj},
         *   {dess obj}, {deras obj} — alla mappar till &herName (possessivt adjektiv).
         *
         *   I engelska skiljer man på possAdj ("her") och possNoun ("hers").
         *   I svenska är formerna identiska — "hennes bok" och "boken är hennes"
         *   använder samma ord — så hersName-varianterna är redundanta och har tagits bort.
         *   &herName väljs av samma skäl som för {min}: possAdj är den semantiskt
         *   korrekta egenskapen för attributiv användning.
         */
        [ 'hans',  { ctx, params: cmdInfo(ctx, params[2], &herName, vPossessive) } ],
        [ 'hennes', { ctx, params: cmdInfo(ctx, params[2], &herName, vPossessive) } ],
        [ 'dess',  { ctx, params: cmdInfo(ctx, params[2], &herName, vPossessive) } ],
        [ 'deras', { ctx, params: cmdInfo(ctx, params[2], &herName, vPossessive) } ],
    
    /* {sigsjälv obj} - emfatisk reflexiv form: 'sig själv', 'sig självt', 'sig själva'
     * beroende på obj:s genus/numerus (beräknas i Thing.reflexiveObjName) */
    [ 'sigsjälv',
      { ctx, params: cmdInfo(ctx, params[2], &reflexiveObjName, vObject) } ],
        

        /*
         *.  {pron subj obj} - demonstrativt pronomen, subjektivt (det, de)
         *.  {pron obj} - demonstrativt pronomen, objektivt
         */
        [ 'pron', function(ctx, params) {
            if (params[2] == 'subj')
                return cmdInfo(ctx, params[3], &thatName, vSubject);
            else
                return cmdInfo(ctx, params[2], &thatObjName, vObject);
        } ],

        /* {är}, {ärinte} */
        [ 'är', conjugateBe ],
        [ 'ärinte', conjugateIsnt ],

        /* {var}, {varinte} */
        [ 'var', conjugateWas ],
        [ 'varinte', conjugateWasnt ],

        /* {harinte} — inget fristående {har} finns */
        [ 'harinte', conjugateHavnt ],

        /* {kaninte} — {kan} hanteras av conjugate() via verbParams 'kunna/kan/...' */
        [ 'kaninte', conjugateKanInte ],

        /* {måste <verb>} - den andra token är ett verb infinitiv */
        [ 'måste', { ctx, params: conjugateMust(ctx, params) } ],
        
        [ 'actionliststr', {ctx, params: gActionListStr } ],

        ['conj', {ctx, params: conjugateSwedish(ctx, params) } ],

        ['conjadj', {ctx, params: adjustAdjectiveAgreement(ctx, params) } ],

        ['posture', {ctx, params: ctx.subj.postureDesc } ]

    ]

    /*
     *   Kontrollera reflexiva i cmdInfo. Detta anropas när vi ser en
     *   substantivfras som används som ett objekt för verbet (dvs. i en roll
     *   annat än som subjekt för verbet). Om lämpligt kan vi
     *   returnera ett reflexivt pronomen istället för substantivet vi normalt skulle
     *   generera. Om inget reflexivt krävs returnerar vi nil och
     *   anroparen kommer att använda det normala substantivet eller pronomenet istället.  
     */
    cmdInfoReflexive(ctx, srcObj, objProp)
    {
        /* 
         *   om detta objekt redan har använts i meningen i en
         *   objektiv roll, använd ett reflexivt pronomen istället 
         */
        
        /* 
         *   Observera att detta verkar ge ganska konstiga resultat, så jag ska försöka
         *   kommentera ut det.
         */        
        if (ctx.reflexiveAnte.indexOf(srcObj) != nil) {
            /* {sigsjälv} begär explicit den emfatiska formen */
            if (objProp == &reflexiveObjName)
                return srcObj.reflexiveObjName;
            return srcObj.pronoun().reflexive.name;
        }

        /* det är inte reflexivt - använd det normala substantivet eller pronomenet */
        return nil;
    }

    /*
     *   Vid konstruktion, fyll i verbparametrarna från CustomVocab
     *   objekt.  
     */
    construct()
    {
        /* skapa verbformstabellen */
        verbTab = new LookupTable(128, 256);

        /* lägg till verbparametrarna för alla CustomVocab-objekt */
        forEachInstance(CustomVocab, function(cv) {

            /* ställ in en vektor för mappningen */
            local vec = new Vector(cv.verbParams.length() * 2);

            /* ställ in en mappning för varje verb */
            foreach (local p in cv.verbParams)
            {
                /* tokenisera verbkonjugationssträngen */
                local toks = p.split('/').mapAll({ s: s.trim() });

                /* 
                 *   om det bara finns tre element (oändligt, presens,
                 *   och förflutet), så blir participet identiskt med det förflutet 
                 */
                if (toks.length() == 3)
                    toks += toks[3];

                /* lägg till verbformerna till verbtabellen */
                verbTab[toks[1]] = toks;
                verbTab[toks[2]] = toks;

                /* 
                 *   i huvudparametertabellen, peka verbet till
                 *   generisk regelbunden verbkonjugator 
                 */
                vec.append([toks[1], conjugate]);
                vec.append([toks[2], conjugate]);
            }

            /* lägg till alla verbmappningar till vår parameterlista */
            params += vec;
        });

        /* 
         *   Gör basklasskonstruktionen. Observera att vi var tvungna att vänta med
         *   att göra detta *efter* vi skannar CustomVocab-objekten, eftersom den
         *   ärvda konstruktören kommer att fylla parametertabellen från
         *   parametern listan. 
         */
        inherited();
    }

    /* verbtabell - vi bygger detta vid preinit från verbparametrarna */
    verbTab = nil
    
    /* 
     *   Bokstavskombinationer i slutet av ord som är besvärliga att följa med en
     *   kontraherat verb som 've.
     */
    sLetters = ['s', 'x', 'z', 'sh', 'ch']

    /* 
     *   Slutar namnet med en av bokstavskombinationerna i sLetters, i vilket fall
     *   det är besvärligt att följa det med en sammandragning.
     */
    awkwardEnding(nam)
    {
        return sLetters.indexWhich({lts: nam.endsWith(lts)})!= nil;
    }

    
;

/* 
 *   Regelbunden verbkonjugator. Detta tar listan över CustomVocab
 *   verbParmas-token byggda under preinit och returnerar den
 *   lämplig konjugation för subjektet och tiden.  
 */
conjugate(ctx, params)
{
    /* hämta listan med former för verbet */
    local toks = swedishMessageParams.verbTab[params[1]];
    if (toks == nil)
        return nil;

    switch (Narrator.tense)
    {
    case Present:
        /* "Jag går"/"han går" - returnera lämplig presens */
        return toks[2];
    case Past:
        /* "Jag gick" - alla personer och nummer använder samma förflutna form */
        return toks[3];
    case Perfect:
        /* "Jag har gått" - "har" plus participet */
        return 'har <<toks[4]>>';
    case PastPerfect:
        /* "Jag hade gått" - "hade" plus participet */
        return 'hade <<toks[4]>>';
        
    case Future:
        /* "Jag kommer att gå" - "kommer att" plus infinitivet */
        return 'kommer att <<toks[1]>>';
        
    case FuturePerfect:
        /* "Jag kommer att ha gått" - "kommer att ha" plus participet */
        return 'kommer att ha <<toks[4]>>';
    }
    
    return nil;
}

/*
 * langAdjust driver två pipelines — adjektivkongruens och verbkonjugering.
 * Båda följer samma tre steg:
 *
 *  1. langAdjust (här): anropas av messages.t INNAN parameterersättning.
 *     Regex fångar rot + mönster och skriver om rot{mönster} till
 *     {token rot mönster}.
 *
 *  2. Parameterersättningsmekanismen ser token ('conjadj' / 'conj') och
 *     anropar rätt funktion med params = [token, rot, mönster].
 *
 *  3. Funktionen returnerar rätt form.
 *
 * --- Adjektivkongruens ({conjadj} → adjustAdjectiveAgreement) -----------
 *  Ändelse väljs utifrån obj.plural / obj.isNeuter
 *  (obj = ctx.curObj → ctx.cmd.dobj → ctx.actor).
 *
 *   a        →                  plural +a         (t.ex. låst/låsta)
 *   t/a      → neutrum +t,      plural +a         (t.ex. tung/tungt/tunga)
 *   d/t/a    → utrum +d, neutrum +t, plural +a
 *   d/t/da   → utrum +d, neutrum +t, plural +da   (t.ex. tänd/tänt/tända)
 *   en/et/a|en/et/na → utrum +en, neutrum +et, plural +na (t.ex. öppen/öppet/öppna)
 *   n/t/na   → utrum +n, neutrum +t,  plural +na (t.ex. sann/sant/sanna)
 *   ad/at/ade → utrum +ad, neutrum +at, plural +ade (t.ex. laddad/laddat/laddade)
 *
 * --- Verbkonjugering ({conj} → conjugateSwedish) ------------------------
 *  Form väljs utifrån Narrator.tense.
 *  Mönster: presens/preteritum/supinum  (tre delar, skilda av /)
 *  Infinitiv = rot + 'a' utom grupp 3 (r/dde/tt) där infinitiv = rot.
 *
 *   ar/ade/at → grupp 1  (t.ex. öppn{ar/ade/at}: öppnar/öppnade/öppnat)
 *   er/te/t   → grupp 2a (t.ex. tryck{er/te/t}: trycker/tryckte/tryckt)
 *   er/de/t   → grupp 2b (t.ex. lev{er/de/t}: lever/levde/levt)
 *   r/dde/tt  → grupp 3  (t.ex. bo{r/dde/tt}: bor/bodde/bott)
 *
 *  OBS: enkelt presens/preteritum utan supinum → använd params-tabellens
 *  er/te eller er/e direkt (t.ex. tryck{er/te}) — de behöver inte langAdjust.
 */
langAdjust(txt)
{
    if(txt == nil)
        return '';

    local adjPat = R'([^ {}]+)<lbrace>(a|t/a|n/t/na|ad/at/ade|d/t/a|d/t/da|en/et/a|en/et/na)<rbrace>';
    for(;;)
    {
        local rf = rexSearch(adjPat, txt);
        if(rf == nil) break;
        local root = rexGroup(1)[3];
        local ending = rexGroup(2)[3];
        txt = txt.findReplace(root + '{' + ending + '}',
                              '{conjadj ' + root + ' ' + ending + '}');
    }

    local verbPat = R'([^ {}]+)<lbrace>(ar/ade/at|er/te/t|er/de/t|r/dde/tt)<rbrace>';
    for(;;)
    {
        local rf = rexSearch(verbPat, txt);
        if(rf == nil) break;
        local root = rexGroup(1)[3];
        local ending = rexGroup(2)[3];
        txt = txt.findReplace(root + '{' + ending + '}',
                              '{conj ' + root + ' ' + ending + '}');
    }

    return txt;
}



// Steg 3 i adjektivkongruens-pipelinen — se kommentaren ovanför langAdjust.
// params = ['conjadj', rot, mönster], t.ex. ['conjadj', 'tung', 't/a'].
adjustAdjectiveAgreement(ctx, params)
{
    local root = params[2];
    if(ctx == nil)
        return root;

    local uterEnding = '';
    local neuterEnding = '';
    local pluralEnding = '';

    switch(params[3])
    {
    case 'a':
        pluralEnding = 'a';
        break;
    case 't/a':
        neuterEnding = 't';
        pluralEnding = 'a';
        break;
    case 'n/t/na':
        uterEnding = 'n';
        neuterEnding = 't';
        pluralEnding = 'na';
        break;
    case 'ad/at/ade':
        uterEnding = 'ad';
        neuterEnding = 'at';
        pluralEnding = 'ade';
        break;
    case 'en/et/a':
        uterEnding = 'en';
        neuterEnding = 'et';
        pluralEnding = 'a';
        break;
    case 'en/et/na':
        uterEnding = 'en';
        neuterEnding = 'et';
        pluralEnding = 'na';
        break;
    case 'd/t/a':
        uterEnding = 'd';
        neuterEnding = 't';
        pluralEnding = 'a';
        break;
    case 'd/t/da':
        uterEnding = 'd';
        neuterEnding = 't';
        pluralEnding = 'da';
        break;
    }

    local obj;
    if (ctx.curObj != nil)
        obj = ctx.curObj;
    else if (ctx.cmd != nil && ctx.cmd.dobj != nil)
        obj = ctx.cmd.dobj;
    else
        obj = ctx.actor;

    if(obj == nil)
        return root;

    if(obj.plural)
        return root + pluralEnding;
    if(obj.isNeuter)
        return root + neuterEnding;
    return root + uterEnding;
}


// Steg 3 i verbkonjugerings-pipelinen — se kommentaren ovanför langAdjust.
// params = ['conj', rot, mönster], t.ex. ['conj', 'öppn', 'ar/ade/at'].
conjugateSwedish(ctx, params)
{
    local root = params[2];
    local presentEnding = '';
    local pastEnding = '';
    local supinumEnding = '';
    local infinitive = root + 'a';

    switch(params[3])
    {
    case 'ar/ade/at':
        presentEnding = 'ar';
        pastEnding = 'ade';
        supinumEnding = 'at';
        break;
    case 'er/te/t':
        presentEnding = 'er';
        pastEnding = 'te';
        supinumEnding = 't';
        break;
    case 'er/de/t':
        presentEnding = 'er';
        pastEnding = 'de';
        supinumEnding = 't';
        break;
    case 'r/dde/tt':
        presentEnding = 'r';
        pastEnding = 'dde';
        supinumEnding = 'tt';
        infinitive = root;
        break;
    }

    switch(Narrator.tense)
    {
    case Present:     return root + presentEnding;
    case Past:        return root + pastEnding;
    case Perfect:     return 'har ' + root + supinumEnding;
    case PastPerfect: return 'hade ' + root + supinumEnding;
    case Future:      return 'ska ' + infinitive;
    case FuturePerfect: return 'ska ha ' + root + supinumEnding;
    }
    return root + presentEnding;
}

/* 
 *   Bilda det förflutna participet av ett verb, som antingen kan ges i formen
 *   xxx, i vilket fall vi antar att det är ett oregelbundet verb som ska slås upp i
 *   tabellen över oregelbundna verb, eller i formen xxx[y/z], i vilket fall vi antar
 *   det är ett regelbundet verb som ska konjugeras enligt
 *   [y/z] slutet.
 */
pastParticiple(verb)
{
    local b1 = verb.find('[');
    local b2 = verb.find(']');
    
    
    if(b1 != nil && b2 != nil && b2 > b1)
    {
        local stem = verb.substr(1, b1 - 1);
        local suffix = verb.substr(b1 + 1, b2 - b1 - 1);
        local dash = suffix.find('/');
        local ending = suffix;
        if(dash)
        {    
            ending = suffix.substr(dash + 1, suffix.length - 2);
            
        }
        
        if(ending.startsWith('?'))
        {
            stem = stem + stem.substr(-1, 1);
            ending = ending.substr(2);
        }
        return stem + ending;
                                     
    }
    else
        return swedishMessageParams.verbTab[verb][4];
    
}


/* {1}–{9} ska ge theName (bestämd form) i svenska, inte det obest. namn-strängen */
modify MessageCtx
    paramToString(val)
    {
        if (dataType(val) == TypeObject && val.ofKind(Mentionable))
            return val.theName;
        return inherited(val);
    }
;

conjugateKanInte(ctx, params)
{
    local t = Narrator.tense;
    if (t == Present)       return 'kan inte';
    if (t == Past)          return 'kunde inte';
    if (t == Perfect)       return 'har inte kunnat';
    if (t == PastPerfect)   return 'hade inte kunnat';
    if (t == Future)        return 'kommer inte att kunna';
    if (t == FuturePerfect) return 'kommer inte att ha kunnat';
    return nil;
}

/*
 *   Konjugera "att vara". Detta är en hanteringsfunktion för meddelandeparameter
 *   expansion, för "vara"-verbparametrarna ({am}, {is}, {are}).
 */
conjugateBe(ctx, params)
{
    /* 
     *   hämta presens/preteritum konjugationsindex för den grammatiska personen
     *   och nummer: [Jag är, du är, han/hon/det är, vi är, du är, de
     *   är] 
     */
    local idx = ctx.subjEffectivelyPlural ? 4 : ctx.subj.person;

    /* 
     *   för andra tider, kokar konjugationen ner till högst två
     *   alternativ: tredje person singular och allt annat 
     */
    local idx2 = ctx.subj.person == 3 && !ctx.subj.plural ? 2 : 1;

    /* slå upp konjugationen i den aktuella tiden */
    switch (Narrator.tense)
    {
    case Present:
        return ['är', 'är', 'är', 'är'][idx];

    case Past:
        return ['var', 'var', 'var', 'var'][idx];

    case Perfect:
        return ['har varit', 'har varit'][idx2];

    case PastPerfect:
        return 'hade varit';

    case Future:
        return 'kommer att vara';

    case FuturePerfect:
        return 'kommer att ha varit';
    }

    return nil;
}

/*
 *   Konjugera "att vara" i negativa sinnen. Detta är en hanteringsfunktion för
 *   meddelandeparametrar med negativ användning
 *   (kan inte, kommer inte, etc).  
 */
conjugateBeNot(ctx, params)
{
    /* 
     *   hämta presens/preteritum konjugationsindex för den grammatiska personen
     *   och nummer: [Jag är, du är, han/hon/det är, vi är, du är, de
     *   är] 
     */
    local idx = ctx.subjEffectivelyPlural ? 4 : ctx.subj.person;

    /* 
     *   för andra tider, kokar konjugationen ner till högst två
     *   alternativ: tredje person singular och allt annat 
     */
    local idx2 = ctx.subj.person == 3 && !ctx.subj.plural ? 2 : 1;

    /* slå upp konjugationen i den aktuella tiden */
    switch (Narrator.tense)
    {
    case Present:
        return '<<['är', 'är', 'är', 'är'][idx]>> inte';

    case Past:
        return '<<['var', 'var', 'var', 'var'][idx]>> inte';

    case Perfect:
        return ['har inte varit', 'har inte varit'][idx2];

    case PastPerfect:
        return 'hade inte varit';

    case Future:
        return 'kommer inte att vara';

    case FuturePerfect:
        return 'kommer inte att ha varit';
    }

    return nil;
}

/*
 *   Konjugera "är inte". Detta är en hanteringsfunktion för meddelandeparameter
 *   expansion, för "vara"-verbparametrarna med "inte"-kontraktioner ({är
 *   inte}, {är inte}, {är inte}).  
 */
conjugateIsnt(ctx, params)
{
    /* 
     *   hämta presens/preteritum konjugationsindex för den grammatiska personen
     *   och nummer: [Jag är, du är, han/hon/det är, vi är, du är, de
     *   är] 
     */
    local idx = ctx.subjEffectivelyPlural ? 4 : ctx.subj.person;

    /* 
     *   för andra tider, kokar konjugationen ner till högst två
     *   alternativ: tredje person singular och allt annat 
     */
    local idx2 = ctx.subj.person == 3 && !ctx.subjEffectivelyPlural ? 2 : 1;

    /* slå upp konjugationen i den aktuella tiden */
    switch (Narrator.tense)
    {
    case Present:
        return ['är inte', 'är inte', 'är inte', 'är inte'][idx];

    case Past:
        return ['var inte', 'var inte', 'var inte', 'var inte'][idx];

    case Perfect:
        return ['har inte varit', 'har inte varit'][idx2];

    case PastPerfect:
        return 'hade inte varit';

    case Future:
        return 'kommer inte att vara';

    case FuturePerfect:
        return 'kommer inte att ha varit';
    }

    return nil;
}

/*
 *   Konjugera "att vara" sammandragningar - jag är, du är, han är, hon är, etc. Detta
 *   är en hanteringsfunktion för meddelandeparameterexpansion, för "vara"
 *   verbparametrar med sammandragning ({jag är}, {han är}, {du är}).  
 */
conjugateIm(ctx, params)
{
    /* 
     *   hämta presens/preteritum konjugationsindex för den grammatiska personen
     *   och nummer: [Jag är, du är, han/hon/det är, vi är, du är, de
     *   är] 
     */
    local idx = ctx.subjEffectivelyPlural ? 4 : ctx.subj.person;

    /* 
     *   för andra tider, kokar konjugationen ner till högst två
     *   alternativ: tredje person singular och allt annat 
     */
    local idx2 = ctx.subj.person == 3 && !ctx.subjEffectivelyPlural ? 2 : 1;

    /* slå upp konjugationen i den aktuella tiden */
    switch (Narrator.tense)
    {
    case Present:
        return ['\'m', '\'re', '\'s', '\'re'][idx];

    case Past:
        return [' var', ' var', ' var', ' var'][idx];

    case Perfect:
        return ['\'ve varit', '\'s varit'][idx2];

    case PastPerfect:
        return '\'d varit';

    case Future:
        return '\'ll vara';

    case FuturePerfect:
        return '\'ll ha varit';
    }

    return nil;
}

/* 
 *   Konjugera det förflutna av "att vara" där vi vill använda det förflutna i
 *   ett nuvarande sammanhang (t.ex. "Du kan se att Kilroy var här."). Detta är en
 *   hanteringsfunktion för {var} eller {var}.
 */

conjugateWas(ctx, params)
{ 
    switch (Narrator.tense)
    {
    case Present:
        return ctx.subjEffectivelyPlural || ctx.subj.person == 2 ? 'var' : 'var';
        
    case Past:
    case Perfect:
    case PastPerfect:
        return 'hade varit';
        
    case Future:
    case FuturePerfect:
        return 'kommer att ha varit';
    }
    
    return nil;
}

conjugateWasnt(ctx, params)
{ 
    switch (Narrator.tense)
    {
    case Present:
        return ctx.subjEffectivelyPlural || ctx.subj.person == 2 ? 'var inte' : 'var inte';
        
    case Past:
    case Perfect:
    case PastPerfect:
        return 'hade inte varit';
        
    case Future:
    case FuturePerfect:
        return 'kommer inte att ha varit';
    }
    
    return nil;
}
    
conjugateWasnot(ctx, params)
{ 
    switch (Narrator.tense)
    {
    case Present:
        return ctx.subj.plural || ctx.subj.person == 2 ? 'var inte' : 'var inte';
        
    case Past:
    case Perfect:
    case PastPerfect:
        return 'hade inte varit';
        
    case Future:
    case FuturePerfect:
        return 'kommer inte att ha varit';
    }
    
    return nil;
}

/* 
 *   Konjugera 've (sammandragning av have). Efter vissa ord är det bättre att inte
 *   kontrakt (t.ex. Liz's eller Jesus'd är lite besvärligt) så vi använder hela
 *   'har' eller 'hade' form för sådana ämnen och den kontrakterade formen annars.
 */

conjugateIve(ctx, params)
{
    local fullForm = swedishMessageParams.awkwardEnding(ctx.subj.name);
    
    switch (Narrator.tense)
    {
    case Present:
        if(fullForm)
            return !ctx.subjEffectivelyPlural && ctx.subj.person == 3 ? ' har' : ' har';
        else
            return !ctx.subjEffectivelyPlural && ctx.subj.person == 3 ? '\'s' : '\'ve';
        
        
        
    case Past:
    case Perfect:
    case PastPerfect:
        return fullForm ? ' hade' : '\'d';       
        
    case Future:
    case FuturePerfect:
        return fullForm ? ' kommer att ha' : '\'ll ha'; 
    }
    
    return nil;
}    

/* Konjugera haven\'t (kontraherat har inte) */
conjugateHavnt(ctx, params)
{
    switch (Narrator.tense)
    {
    case Present:       
            return !ctx.subjEffectivelyPlural && ctx.subj.person == 3 ? 'har inte' 
            : 'har inte';      
        
    case Past:
    case Perfect:
    case PastPerfect:
        return 'hade inte';       
        
    case Future:
    case FuturePerfect:
        return 'kommer inte att ha' ;
    }
    
    return nil;
}


conjugateHavenot(ctx, params)
{
    switch (Narrator.tense)
    {
    case Present:       
            return !ctx.subjEffectivelyPlural && ctx.subj.person == 3 ? 'har inte' 
            : 'har inte';      
        
    case Past:
    case Perfect:
    case PastPerfect:
        return 'hade inte';       
        
    case Future:
    case FuturePerfect:
        return 'kommer inte att ha' ;
    }
    
    return nil;
}

/*
 *   Konjugera {kan} / {kaninte}. Negationsform identifieras via att present
 *   innehåller 'inte'. beFunc-parametern finns kvar av historiska skäl men
 *   används inte — svenska former är explicita för alla tempus.
 */
conjugateCan(ctx, params, beFunc, present, past)
{
    local neg = (present.find('inte') != nil);
    switch (Narrator.tense)
    {
    case Present:
        return present;

    case Past:
        return past;

    case Perfect:
        return neg ? 'har inte kunnat' : 'har kunnat';

    case PastPerfect:
        return neg ? 'hade inte kunnat' : 'hade kunnat';

    case Future:
        return neg ? 'kommer inte att kunna' : 'kommer att kunna';

    case FuturePerfect:
        return neg ? 'kommer inte att ha kunnat' : 'kommer att ha kunnat';
    }

    return nil;
}

/*
 *   Konjugera "måste" plus ett verb. I nuet är detta "Jag måste <x>";
 *   i andra tider är detta en konjugation av "att ha <x>": Jag var tvungen att
 *   <x>, Jag måste ha <xed>, Jag var tvungen att ha <xed>, Jag kommer att behöva <x>, Jag
 *   kommer att behöva ha <xed>.  
 */
conjugateMust(ctx, params)
{
    local inf = params[2].split('[')[1];    
    
    local part = pastParticiple(params[2]);
    local idx = ctx.subj.person == 3 && !ctx.subjEffectivelyPlural ? 2 : 1;

    switch (Narrator.tense)
    {
    case Present:
        return 'måste <<inf>>';

    case Past:
        return 'var tvungen att <<inf>>';

    case Perfect:
        return ['måste ha ', 'måste ha '][idx] + part;
        
    case PastPerfect:
        return 'var tvungen att ha <<part>>';
        
    case Future:
        return 'kommer att behöva <<inf>>';
        
    case FuturePerfect:
        return 'kommer att behöva ha <<part>>';
    }

    return nil;
}


/* 
 *   Språkspecifika modifieringar av Action-klasser, främst för att möjliggöra
 *   konstruktionen av implicita åtgärdsmeddelanden.
 */
modify Action
     getVerbPhrase(inf, ctx)
     {
        /*
         *   analysera verbPhrase till delarna före och efter
         *   snedstrecket och eventuell ytterligare text efter snedstrecksdelen
         */
        rexMatch('(.*)/(<alphanum|-|squote>+)(.*)', verbRule.verbPhrase);

        /* returnera de lämpliga delarna */
        if (inf)
        {
            /*
             *   infinitiv - vi vill ha delen före snedstrecket, plus de
             *   extra prepositioner (eller vad som helst) efter den växlade delen
             */
            return rexGroup(1)[3] + rexGroup(3)[3];
        }
        else
        {
            /* particip - det är delen efter snedstrecket */
            return rexGroup(2)[3] + rexGroup(3)[3];
        }
    }
  
    /* 
     *   Flagga - vill vi visa implicita åtgärdsrapporter för denna åtgärd? Som
     *   standard gör vi det.
     */
    reportImplicitActions = true
    
    
    /* 
     *   Konstruera meddelandet om en implicit åtgärd beroende på om
     *   den implicita åtgärden lyckas (framgång = sant) eller misslyckas (framgång = nil)
     *
     *   [Krävs]
     */
    buildImplicitActionAnnouncement(success, clearReports = true)
    {
        
        /* 
         *   Om vi inte vill visa implicita åtgärdsrapporter för denna åtgärd,
         *   gör då ingenting alls här; returnera helt enkelt en tom sträng
         *   på en gång.
         */       
        if(!reportImplicitActions)
            return '';
        
        local rep = '';
        local cur;
        
        
        /* 
         *   Om den aktuella åtgärden är en implicit åtgärd, lägg till den i listan över
         *   implicita åtgärdsrapporter, antingen i participformen om det är en
         *   framgång (t.ex. 'öppna dörren') eller i infinitivformen
         *   föregås av 'försöker' om det är ett misslyckande (t.ex. 'försöker öppna
         *   dörren')
         */
        if(isImplicit)
        {    
            cur = implicitAnnouncement(success);
            
            if(cur != nil)
                gCommand.implicitActionReports += cur;
        }    
            
        
        /* 
         *   Om denna implicita åtgärd misslyckades måste vi rapportera denna implicita
         *   åtgärd. Om vi inte är en implicit åtgärd måste vi rapportera den
         *   tidigare uppsättningen implicita åtgärder, om det finns några.
         */
        
        if((success == nil || !isImplicit) &&
           gCommand.implicitActionReports.length > 0)
        {
            
            local lst = mergeDuplicates(gCommand.implicitActionReports);
            
            
            /* 
             *   Börja vår rapport med en öppningsparentes och ordet
             *   'först'
             */
            rep = BMsg(implicit action report start, '<.assume> ');
            //rep = '(';

            /* 
             *   Gå sedan igenom alla implicita åtgärdsrapporter på den aktuella
             *   Command-objektet, lägg till dem i vår rapportsträng.
             */
            for (cur in lst, local i = 1 ;; ++i)
            {    
                rep += cur;
                
                /* 
                 *   om vi inte har nått den sista rapporten, lägg till ', sedan ' för
                 *   separera en rapport från nästa
                 */
                if(i < lst.length)
                    rep += BMsg(implicit action report separator, ' sedan ');
            }
            
            local prp = getPostImplicitReports();
            
            if(clearReports)
            {
                /* Vi är klara med denna lista med rapporter, så rensa dem */
                gCommand.implicitActionReports = [];
                
                gCommand.postImplicitReports = [];
            }
            
            /* Returnera den färdiga implicita åtgärdsrapporten */
            return rep + BMsg(implicit action report terminator, '<./assume>\n') + prp;
        }
        
        /* 
         *   om vi inte behöver rapportera något, returnera en tom sträng, eftersom
         *   denna rutin kan ha anropats spekulativt för att se om det fanns
         *   något att rapportera.
         */
        
        return '';
    }
    
       
    /*  
     *   Returnera en sträng som ger det implicita åtgärdsmeddelandet för den aktuella
     *   åtgärd beroende på om det är en framgång (t.ex. "ta skeden") eller
     *   ett misslyckande (t.ex. "försöker ta skeden"). Vi gör detta till en separat
     *   metod för att göra det lite lättare för spelkoden att anpassa implicit
     *   åtgärdsmeddelanden.
     *
     *   Ett returvärde på nil kommer att undertrycka den implicita åtgärdsrapporten för detta
     *   åtgärd altogeher.
     */
    implicitAnnouncement(success)
    {
        return success ? getVerbPhrase(nil, nil) : 
              BMsg(implicit action report failure, 'försöker ') 
            + getVerbPhrase(true, nil);
    }
    
    
    
    /* lägg till ett mellanslag prefix/suffix till en sträng om strängen inte är tom */
    spPrefix(str) { return (str == '' ? str : ' ' + str); }
    spSuffix(str) { return (str == '' ? str : str + ' '); }
    
    /* 
     *   Tillkännage ett objekt (för att användas för att introducera en rapport om vad en åtgärd
     *   gör till ett visst objekt när det är ett av flera objekt som åtgärden
     *   agerar på)
     */
    announceObject(obj)
    {
        "<.announceObj><<obj.name>>:<./announceObj> ";
    }
;

modify TAction
    /* 
     *   VerbPhrase att använda för detta objekt när du konstruerar implicita åtgärdsrapporter. Som standard
     *   returnerar vi bara verbPhrase definierat på vår verbRule men spelkoden kan åsidosätta detta för
     *   returnera en anpassad verbPhrase för ett visst objekt (eller, på en TIAction, kombination av
     *   objekt).
     */
    vPhrase(dobj, iobj?)
    {
        return verbRule.verbPhrase;
    }
    
     /* hämta verbfrasen i infinitiv eller participform */
    getVerbPhrase(inf, ctx)
    {
        local dobj;
        local dobjText;
        local dobjIsPronoun;
        local ret;

        /* hämta direktobjektet */
        dobj = curDobj;
         
        /* Anta att direktobjektet inte är ett pronomen */
        dobjIsPronoun = nil;        

        /* hämta direktobjektets namn */ 
        dobjText = dobj.theName;

        /* hämta fraseringen */
//        ret = getVerbPhrase1(inf, verbRule.verbPhrase, dobjText, dobjIsPronoun);
        ret = getVerbPhrase1(inf, vPhrase(dobj), dobjText, dobjIsPronoun);

        /* returnera resultatet */
        return ret;
    }

    /*
     *   Givet texten i direktobjektfrasen, bygg verbfrasen
     *   för ett en-objekts verb. Detta är en klassmetod som kan användas av
     *   andra typer av verb (dvs. icke-TActions) som använder frasering som en
     *   enda objekt.
     *
     *   'inf' är en flagga som indikerar om infinitivformen ska användas
     *   (sant) eller presens participform (nil); 'vp' är
     *   verbPhrase-strängen; 'dobjText' är texten i direktobjektfrasen;
     *   och 'dobjIsPronoun' är sant om dobj-texten återges som en
     *   pronomen.
     */
    getVerbPhrase1(inf, vp, dobjText, dobjIsPronoun)
    {
        local ret;
        local dprep;
        local vcomp;

        /*
         *   analysera verbPhrase: plocka ut 'infinitiv/particip'
         *   del, komplementdel upp till '(vad)' direkt
         *   objektplatshållare och eventuell preposition inom '(vad)'
         *   specifikator
         */
        rexMatch('(.*)/(<alphanum|-|squote>+)(.*) '
                 + '<lparen>(.*?)<space>*?<alpha>+<rparen>(.*)',
                 vp);

        /* börja med infinitiv eller particip, efter önskemål */
        if (inf)
            ret = rexGroup(1)[3];
        else
            ret = rexGroup(2)[3];

        /* hämta prepositionskomplementet */
        vcomp = rexGroup(3)[3];

        /* hämta direktobjektets preposition */
        dprep = rexGroup(4)[3];

        /*
         *   om direktobjektet inte är ett pronomen, sätt komplementet
         *   FÖRE direktobjektet (den 'upp' i "PICKING UP THE BOX")
         */
        if (!dobjIsPronoun)
            ret += spPrefix(vcomp);

        /* lägg till direktobjektets preposition */
        ret += spPrefix(dprep);

        /* lägg till direktobjektet, med pronomenformen om tillämpligt */
        ret += ' ' + dobjText;

        /*
         *   om direktobjektet är ett pronomen, sätt komplementet
         *   EFTER direktobjektet (den 'upp' i "PICKING IT UP")
         */
        if (dobjIsPronoun)
            ret += spPrefix(vcomp);

        /*
         *   om det finns något suffix efter direktobjektet
         *   platshållare, lägg till det i slutet av frasen
         */
        ret += rexGroup(5)[3];

        /* returnera den kompletta frassträngen */
        return ret;
    }
;

modify TIAction
     /* hämta verbfrasen i infinitiv eller participform */
    getVerbPhrase(inf, ctx)
    {
        local dobj, dobjText, dobjIsPronoun;
        local iobj, iobjText;
        local ret;

        /* hämta information om direktobjektet */
        dobj = curDobj;
        
        dobjText = dobj.theName;
        dobjIsPronoun = nil;

        /* hämta information om indirekt objekt */
        iobj = curIobj;

        iobjText = (iobj != nil ? iobj.theName : nil);

        /* hämta fraseringen */
        ret = getVerbPhrase2(inf, vPhrase(dobj, iobj), 
                             dobjText, dobjIsPronoun, iobjText);
//         ret = getVerbPhrase2(inf, verbRule.verbPhrase,
//                             dobjText, dobjIsPronoun, iobjText);

        
        /* returnera resultatet */
        return ret;
    }

    /*
     *   Hämta verbfrasen för en två-objekts (dobj + iobj) frasering. Detta
     *   är en klassmetod, så att den kan återanvändas av orelaterade (dvs.,
     *   icke-TIAction) klasser som också använder två-objekts syntax men med
     *   andra interna strukturer. Detta är två-objektsmotsvarigheten till
     *   TAction.getVerbPhrase1().
     */
    getVerbPhrase2(inf, vp, dobjText, dobjIsPronoun, iobjText)
    {
        local ret;
        local vcomp;
        local dprep, iprep;

        /* analysera verbPhrase till dess komponentdelar */
        rexMatch('(.*)/(<alphanum|-|squote>+)(?:<space>+(<^lparen>*))?'
                 + '<space>+<lparen>(.*?)<space>*<alpha>+<rparen>'
                 + '<space>+<lparen>(.*?)<space>*<alpha>+<rparen>',
                 vp);

        /* börja med infinitiv eller particip, efter önskemål */
        if (inf)
            ret = rexGroup(1)[3];
        else
            ret = rexGroup(2)[3];

        /* hämta komplementet */
        vcomp = (rexGroup(3) == nil ? '' : rexGroup(3)[3]);

        /* hämta prepositionerna för direkt och indirekt objekt */
        dprep = rexGroup(4)[3];
        iprep = rexGroup(5)[3];

        /*
         *   lägg till komplementet FÖRE direktobjektet, om
         *   direktobjektet visas som ett fullständigt namn ("PICK UP BOX")
         */
        if (!dobjIsPronoun)
            ret += spPrefix(vcomp);

        /*
         *   lägg till direktobjektet och dess preposition, med ett pronomen om
         *   tillämpligt
         */
        ret += spPrefix(dprep) + ' ' + dobjText;

        /*
         *   lägg till komplementet EFTER direktobjektet, om direkt
         *   objektet visas som ett pronomen ("PICK IT UP")
         */
        if (dobjIsPronoun)
            ret += spPrefix(vcomp);

        /* om vi har ett indirekt objekt, lägg till det med dess preposition */
        if (iobjText != nil)
            ret += spPrefix(iprep) + ' ' + iobjText;

        /* returnera resultatfrasen */
        return ret;
    }
;

/* -------------------------------------------------------------------------- */
/* 
 *   Engelskspråkiga modifieringar av de olika pronomenobjekten för att tillhandahålla
 *   dem med ett lämpligt engelskt namn i deras prep-egenskaper.
 */

modify LocType
    prep = ''
    intoPrep = prep
;


modify In
    prep = 'i'  
    intoPrep = 'in i'
;


modify Outside
    prep = 'del av'
;


modify On
    prep = 'på'    
    intoPrep = 'in i'
;

modify Under
    prep = 'under'
;

modify Behind
    prep = 'bakom'
;


modify Held
    prep = 'hållen av'
;


modify Worn
    prep = 'bärs av'
;


modify Into
    prep = 'in i'
;

modify OutOf
    prep = 'ut ur'
;

modify Down
    prep = 'ner'
;

modify Up
    prep = 'upp';
;

modify Through
    prep = 'genom';
;

modify Carrier
    prep = 'buren av'
;

/* 
 *   [måste definieras] Den språk specifika delen av CommandTopicHelper. */

property myAction;

class LCommandTopicHelper: object
    
    /* 
     *   bygger åtgärdsfrasen för kommandot, t.ex. 'hoppa', 'ta den röda
     *   bollen', 'lägg den blå bollen i korgen'. Detta kan användas för att hjälpa
     *   konstruera spelarens kommando till aktören i ämnessvaret,
     *   t.ex. "<q>\^<<actionPhrase>>!</q> du ropar. "
     */    
    actionPhrase()
    {
        if(myAction == nil || myAction.verbRule == nil)
            return 'gör något'; 
        /* 
         *   Hitta den längsta grammatikmallen som börjar med samma ord på
         *   verbfrasen. Detta är sannolikt den mest kompletta versionen i
         *   en rimligt kanonisk form.
         *
         */
        local txt = '';
        
        /*   
         *   Hämta verbet från den första delen av verbPhrase av
         *   verbRule för åtgärden som matchas av denna CommandTopic.
         */
        local verb = myAction.verbRule.verbPhrase.split('/')[1];
        
        /*  
         *   Gå igenom alla grammatikmallar som är associerade med åtgärden
         *   matchas av denna CommandTopic och plocka ut den längsta som
         *   börjar med verbet vi just identifierat; vi tar detta som
         *   den 'kanoniska' formen (som en grov tumregel fungerar detta
         *   ganska bra)
         */
        foreach(local cur in myAction.grammarTemplates)
        {
            if(cur.length > txt.length && cur.startsWith(verb))
                txt = cur;
        }
        
        /* 
         *   Om den matchade åtgärden har ett direkt objekt, ersätt strängen
         *   'dobj' i vår txt-sträng med namnet på direktobjektet
         */
        if(myAction.curDobj != nil)            
            txt = txt.findReplace('(dobj)', getName(myAction.curDobj));
           
        /* 
         *   Om den matchade åtgärden har ett indirekt objekt, ersätt strängen
         *   'iobj' i vår txt-sträng med namnet på det indirekta objektet
         */
        if(myAction.curIobj != nil)        
            txt = txt.findReplace('(iobj)', getName(myAction.curIobj));
        
        if(gCommand.verbProd.dirMatch)
            txt = txt.findReplace('(direction)',
                                  gCommand.verbProd.dirMatch.dir.name);
        return txt;
    }
    
    /* 
     *   Hämta lämpligt namn för ett objekt att använda åtgärdsfrasen för en
     *   CommandTopic.
     */
    getName(obj)
    {
        /* Om objektet är spelar karaktären, bör det visas som 'jag' */
        if(obj == gPlayerChar)
            return 'jag';
        
        /* 
         *   Om objektet är aktören som kommandot riktas till,
         *   det bör visas som singular eller plural form av andra
         *   personligt reflexivt pronomen
         */
        if(obj == gActor)
            return gActor.plural ? 'er själva' : 'dig själv';
        
        /* Annars använd bara theName-egenskapen för objektet */
        return obj.theName;   
    }
;
    

/* ------------------------------------------------------------------------ */
/*
 *   Enkla ja/nej bekräftelser. Anroparen måste visa en prompt; vi
 *   läser ett kommandoradsvar och returnerar true om det är ett jakande
 *   svar, nil om inte.
 */
yesOrNo()
{
    /* växla till inget-kommando-läge för den interaktiva inmatningen */
    "<.commandnone>";

    /*
     */
    local str = inputManager.getInputLine(nil);

    /* växla tillbaka till mitt-kommando-läge */
    "<.commandmid>";

    /*
     */
    return rexMatch('<space>*[jJ]', str) != nil;
}


/*
 * Behöver ersätta den definition som finns i attachables.t
 */
replace reverseAttachableDoer: Doer 'fäst SimpleAttachable till Attachable'
    execAction(c)
    {
        if(gIobj.reverseConnect(gDobj))
            doInstead(Attach, gIobj, gDobj);
        else
            inherited(c);            
    }    
;

/* 
 *   På svenska kan "ta bort X" betyda att ta av det (om vi bär det) eller ta
 *   det (om det bara är ett fristående objekt). Vi hanterar detta med en Doer i
 *   den svenska specifika delen av biblioteket (a) eftersom denna tvetydighet
 *   kan vara språkberoende och (b) eftersom remap nu är föråldrad.
 */

removeDoer: Doer 'ta bort Thing'

    execAction(c)
    {
        /* 
         *   If we want REMOVE to be handed as s separate action on the dobj, set the dobj's
         *   separateRemove property to true.
         */
        if(c.dobj.separateRemove)
            inherited(c);        
        else if(c.dobj.wornBy == c.actor)
            redirect(c, Doff, dobj: c.dobj);
        else
            redirect(c, Take, dobj: c.dobj);
    }    
;

/*  
 *   Att lägga något på ett Golv-objekt eller kasta något på ett Golv-objekt
 *   är likvärdigt med att släppa det; eftersom detta beror på
 *   den svenska språkets grammatik för de berörda handlingarna måste det
 *   visas i den svenska specifika delen av biblioteket.
 */
putOnGroundDoer: Doer 'lägg Thing på Floor; kasta Thing på Floor'
    execAction(c)
    {
        /* 
         *   Spelaren har bett att lägga något på marken, så vi borde
         *   åsidosätt aktörens plats dropLocation vid detta tillfälle för att
         *   säkerställa att det är där det tappade objektet faktiskt hamnar
         */        
        local oldDropLocation;
        local oldLocation;
        try
        {
            /* Notera den ursprungliga dropLocation */
            oldLocation = gActor.location;
            oldDropLocation = oldLocation.dropLocation;
            
            /* Ändra dropLocation till rummet */
            oldLocation.dropLocation = gActor.getOutermostRoom;
            
            /* omdirigera åtgärden till Drop */
            redirect(c, Drop, dobj: c.dobj);
        }
        finally
        {
            /* Återställ den ursprungliga dropLocation */
            oldLocation.dropLocation = oldDropLocation;
        }
    }
;

/* 
 *   'Stå på golvet' eller 'gå på golvet' gör ingenting om spelaren redan är
 *   direkt i ett rum, så i så fall visar vi bara ett lämpligt meddelande;
 *   annars tar vi kommandot som likvärdigt med att gå ut ur aktörens
 *   omedelbara behållare.
 */
getOnGroundDoer: Doer 'stå på Floor; gå på Floor'
    execAction(c)
    {
        if(gPlayerChar.location.ofKind(Room))
            "{Jag} {är} stående på {the dobj}. ";
        else
            redirect(c, GetOut);    
    }
;

/*  På svenska betyder att ta en stig att gå längs den */
takePathDoer: Doer 'ta PathPassage'
    execAction(c)
    {
        redirect(c, GoThrough);
    }
    
    /* 
     */
    strict = true
    
    /* 
     */
    ignoreError = true
;
/* 
 *   Förparser för att fånga nummer som anges med en decimalpunkt, så att
 *   decimalpunkten inte behandlas som att den avslutar en mening i kommandot.
 *   Detta fungerar genom att omsluta numret i dubbla citattecken, så all kod
 *   som vill göra något med decimaltalet måste först ta bort citattecknen.
 */

decimalPreParser: StringPreParser
    doParsing(str, which)
    {
        str = str.findReplace( R'<digit>+<period><digit>+',
                              { match, index, orig: '"'+match+'"' }  );
        
        return str;
    }
;

/* 
 *   Förparser för att konvertera ett nummer som spelaren anger (t.ex. 1 eller 2)
 *   som svar på en disambiguationsprompt till motsvarande ordningstal (t.ex.
 *   första eller andra) så att parsern känner igen det som att välja ett av
 *   alternativen.
 */

disambigPreParser: StringPreParser
    doParsing(str, which)
    {
        /* 
         *   Om vi disambigerar och alternativet att räkna upp listan med möjliga svar är
         *   inställt, se om spelaren har angett ett nummer och konvertera det till dess motsvarande
         *   ordningstal (t.ex. '1' till 'första')
         */
        if(which == rmcDisambig && libGlobal.enumerateDisambigOptions)
        {
            
            /* Först ta bort eventuella överflödiga parenteser som spelaren kan ha skrivit. */
            local str2 = str.findReplace(['(', ')'], '');
            
            /* Försök sedan att konvertera spelarens inmatning till ett heltal. */                       
            local num = tryInt(str2);            
            
            /* 
             *   Om vi har ett heltal och det är mindre än antalet ordningstal som vi definierar, och
             *   det är inom det tillåtna intervallet för disambig-alternativ, returnera motsvarande
             *   ordningstal.
             */
            if(num && num <= ordinals.length && num > 0)
            {    
                if(num <= libGlobal.disambigLen)
                    return ordinals[num];    
                
                "Det fanns bara <<libGlobal.disambigLen>> alternativ.<.p>";
                return nil;
            }
        }       
        
           
        /* returnera den ursprungliga strängen oförändrad */
        return str;
    }
    
    /* 
     *   Listan över ordningstal. Vi listar bara de första 20 här eftersom det verkar högst osannolikt
     *   att en spelare skulle presenteras med en lista med mer än tolv disambiguationsalternativ. I
     *   alla fall verkar parsern inte kunna hantera ett svar på mer än 'tjugonde'.
     */
    ordinals = ['första', 'andra', 'tredje', 'fjärde' ,'femte', 'sjätte', 'sjunde',
        'åttonde', 'nionde', 'tionde', 'elfte', 'tolvte', 'trettonde', 'fjortonde',
        'femtonde', 'sextonde', 'sjuttonde', 'artonde', 'nittonde',
        'tjugonde'
    ];
;

modify SpecialVerb
    /* 
     */
    prepositions = ['i', 'på', 'med', 'till', 'under', 'bakom', 'från']
    
    /* en lista över artiklar vi vill att SpecialVerb ska ignorera när vi matchar vokabulär. */
    articles = ['den', 'det', 'en', 'ett', 'några']
;

/* 
 *   Definiera en LookupTable som översätter namnen på olika enums till deras
 *   strängmotsvarigheter. Detta används av say() funktionen för att visa namnen
 *   på dessa enums. Detta definieras i den språkberoende delen av biblioteket
 *   för att möjliggöra anpassning till andra språk.
 */
enumTabObj: object
    enumTab = 
    [
        dubious -> 'tvivelaktig',
        likely -> 'sannolik',
        unlikely -> 'osannolik',
        untrue -> 'osann',
        small -> 'liten',
        medium -> 'medium',
        large -> 'stor',
        notLockable -> 'inte låsbar',
        lockableWithoutKey -> 'låsbar utan nyckel',
        lockableWithKey -> 'låsbar med nyckel',
        indirectLockable -> 'indirekt låsbar',
        masculine -> 'maskulin',
        feminine -> 'feminin',
        neuter -> 'neuter',
        OpenGoal -> 'Öppet mål',
        ClosedGoal -> 'Stängt mål',
        UndiscoveredGoal -> 'Oupptäckt mål',
        null -> 'null',
        oneToOne -> 'en till en',
        oneToMany -> 'en till många',
        manyToOne -> 'många till en',
        manyToMany -> 'många till många',
        normalRelation -> 'normal relation',
        reverseRelation -> 'omvänd relation'
    ]
    
    reverseEnumTab =
    [
        'tvivelaktig' -> dubious,
        'sannolik' -> likely,
        'osannolik' -> unlikely,
        'osann' -> untrue
    ]
    
    /* Konvertera enum till motsvarande strängvärde eller vice versa. */
    getEnum(arg)
    {
        switch(dataType(arg))
        {
        case TypeSString:
            return reverseEnumTab[arg];
        case TypeEnum:
            return enumTab[arg];
        default:
            return nil;
        }
    }
;

enum normalRelation, reverseRelation;
/* 
 *   Möjligen en tillfällig åtgärd för att ersätta apostrofen i possessivformer
 *   i vissa ord i spelarens inmatning med en karat för att möjliggöra
 *   matchning av vokabulär.
 */


/* 
 *   Definitioner för stämningar. Vi definierar dem i den språkberoende delen av
 *   biblioteket så att översättare kan använda mer lämpliga namn för sina språk.
 */

DefStance(amorous, 50);
DefStance(loving, 40);
DefStance(warm, 30);
DefStance(friendly, 20);
DefStance(lukewarm, 10);
DefStance(neutral, 0);
DefStance(cool, -10);
DefStance(unfriendly, -20);
DefStance(hostile, -30);
DefStance(rancorous, -40);
DefStance(loathing, -50);

/* 
 *   Definitioner för stämningar. Vi definierar dem i den språkberoende delen av
 *   biblioteket så att översättare kan använda mer lämpliga namn för sina språk.
 *   Spelkod kan enkelt definiera fler stämningar om det behövs.
 */
DefMood(neutral);
DefMood(calm);
DefMood(happy);
DefMood(euphoric);
DefMood(contented);
DefMood(sad);
DefMood(depressed);
DefMood(angry);
DefMood(furious);
DefMood(afraid);
DefMood(terrified);
DefMood(confident);
DefMood(bold);
DefMood(lonely);
DefMood(bored);
DefMood(excited);

/* Som standard börjar aktörer med neutral stämning och hållning. */

modify libGlobal
    defaultStance = neutralStance
    defaultMood = neutralMood
;

modify MessageCtx
    /* En lista över objekt egenskaper som hänvisar till pronomen. */
    pronounProps = [&heName, &himName, &herName, &hersName, &reflexiveName  ]
    
    /* 
     */
    pronounUsed = pronounProps.indexOf(sourceProp)
    
    
    /* 
     */
    subjEffectivelyPlural = subj.plural || (pronounUsed && subj.pronoun.plural)
;










/* Returnerar bas-pronomenet för given person. possAdj/possAdjT/possAdjPl på det
 * returnerade objektet används sedan för att välja rätt possessivform utifrån
 * det ägda objektets genus/antal. */
function pronounParams(person, plural, isNeuter, isGenderNeutral, isHim, isHer, isIt) {
    switch(person)
    {
    case 1:
        return (plural ? Us : Me);
    case 2:
        return (plural ? Yall : You);
    default:
        return ((plural || isGenderNeutral)
        ? Them :
            isHim ? Him : isHer ? Her : isNeuter ? ItNeuter : It);
    }
}




// works similar to the string split function
// But returns an array of pairs where for each pair there's the word and the delimiter
// As default, it will search for words that ends in either the '+' or '|'-delimiter
//
// e.g: calling splitWithDelimiterPattern('stols|ben+et') 
// will return:  [ [stols, '|'], ['ben','+'], [et, nil] ]
//  
function splitWithDelimiterPattern(str, pat) {
    local pairs = new Vector();
    local idx = 1; // Begin searching the pattern at position 1 

    // Keep looping as long as the index is less than the length of the string
    while(idx <= str.length) {

      local result = rexMatch(pat, str, idx);
      if(result == nil) {
        // If no delimiter was found it's becasue it is the last word, 
        // just add nil as delimiter and step out of the loop
        pairs += [[str.substr(idx, str.length), nil]];
        break;
      } 

      // Add a pair to the result that will be returned eventually
      local word = rexGroup(1)[3];
      local delimiter = rexGroup(2)[3];
      pairs += [[word, delimiter]];

      // Update the index to be +1 after where the last delimiter was found
      idx = rexGroup(2)[1] + 1; 
    }
    return pairs;
};

// Rensa bort alla eventuella trippelbokstäver som uppstått på grund 
// av ordsammansättningarna:
function shortenRepeatingCharacters(word) {
    local match = rexMatch(LMentionable.tripleLetterPat, word);
    if(match) {
        local groupOfRepeats = rexGroup(1);
        if(groupOfRepeats.length > 2) {
            //tadsSay('<<groupOfRepeats>>\n');
            local startPos = groupOfRepeats[1];
            local similarCount = groupOfRepeats[2];
            local lengthToRemove = similarCount - 2;
            local pruned =  word.splice(startPos, lengthToRemove, '');
            //tadsSay('Rensar bort trippelbokstäver: <<w>> -> <<pruned>> (startpos: <<startPos>>, similarCount: <<similarCount>>, remove: <<lengthToRemove>> )\n');
            return pruned;
        }
    }
    return word;
}



// Konstruktion som har som syfte att hålla en ordkomponent med ändelse och eventuellt foge-s.
class WordPart: object {
    word = nil
    ending = nil
    jointS = nil
    useIndividually = nil
    // Alternativ obestämd ändelse: när stammens obestämda form inte är
    // stammen ensam. T ex 'fönst:er+ret' → altEnding='er', fönster/fönstret.
    altEnding = nil
    construct(word, ending, jointS, useIndividually, altEnding = nil) {
        self.word = word;
        self.ending = ending;
        self.jointS = jointS;
        self.useIndividually = useIndividually;
        self.altEnding = altEnding;
    }
}

// Denna funktion skapar variationer från vocabWords
// förutsatt att den följer följande mall:
// äpple+t, äppel+kaka+n, papper+et eller papper^s+flyg+plan+et
// 
// Med andra ord, som enklast, lägg in en ändelse för bestämd form, så som "äpple+t"
// Om det finns foge-s med i ordet, använd ^s, så som: ansvar^s+känsla+n
// Om det ordets totala forms genus skiljer sig från enskilda ord går det att ändra 
// enligt:
//
// sten:+häll:^s+altare+t
// 
// Det fungerar så här, då stenhällsaltaret slutar på t och vi märker ut det med +t
// så antas hela ordets ändelse vara neutrum.
// Om du vill göra avvikelser från detta, kan du skriva in ett ':' för att få 
// skifta genus från neutrum till utrum för bara den ord komponenten, i detta fallet
// "sten:", som nu blir utrum sten-en i sin enskildhet
// samma med "häll:" som blir "häll-en" i sin enskildhet
// 
// Som bäst lyckas genusformen härledas automatiskt genom att bara skriva :,
// men skulle det misslyckas och inte bli rätt, så kan du själv skriva in ändelsen 
// direkt efter kolonet, t ex: "sten:en+häll:en^s+altare+t"
// eller "tranbär:en^s+juice+n"
// för att få automatgenererade ord: "tranbär, tranbären, juice, juicen, tranbär, tranbärjuice, tranbärsjuicen

// TODO: hantera sectPart annorlunda i adv3Lite
function createCompoundWordVariations(obj, cur, partOfSpeech, matchFlags, enableShortenRepeatingCharacters = true) {
    
    // wordParts är en behållare för objekt av typen WordPart, 
    // som i sin tur håller koll på ord, foge-s samt ändelse,
    // per ordkomponent. Detta ger flexibilitet vid 
    // permutationsskapandet, där foge-s och ändelse vid vissa 
    // lägen ska vara med, annars inte.
    local wordParts = new Vector();

    // wordVariations är en vector som får hålla alla sammansatta
    // varianter innan de förs över till cmdDict på slutet.
    local wordVariations = new Vector(); 

    // Inleder med att dela upp alla ordets sammansatta komponenter
    // som är avskiljda med '+', '|'-tecken, eller ingen avskiljare alls (nil)
    local parts = splitWithDelimiterPattern(cur, LMentionable.wordPartDelPat);



    // Håll reda på sista ändelsen för ordet. Den definitiva formen går att 
    // använda för att härleda neutrum/utrum.
    local ending = parts[parts.length][1]; 

    // Beroende på vilken sektion av vocabWords vi nu befinner oss i 
    // skapas boolesker för att hålla koll på om vi är i pluralläge
    // eller singularläge med ett substantiv i plural bestämt utrum. 
    // T ex: äpple+n, äpple+na,

    // TODO: kombinera flaggorna MatchNoun och MatchPlural så en jämförelse-operation kan göras
    local isNounOrPluralEndingUter = ((matchFlags & MatchNoun) != 0 || (matchFlags & MatchPlural) != 0 )
                                  && (ending.endsWith('n') || ending.endsWith('na'));

    // Gör samma för ett adjektiv i bestämd utrum-form
    // Slutet på ett adjektiv i bestämd form. 
    // T ex: ljus+a, grön+a, adekvat+a, överväldigand+e, välartikulerad+e.
    local isAdjectiveEndingUter = (matchFlags & MatchAdj) != 0 
                               && (ending.endsWith('e') || ending.endsWith('a'));

    // Vi anger bara om ett objekt är neutrum (med isNeutrum) då utrum är vanligast
    // och därmed blir default. Negation används på för att det generellt sett är 
    // lättare att matcha mot utrum än neutrum.
    local isEndingNeuter = !isNounOrPluralEndingUter && !isAdjectiveEndingUter;

    //local ending = parts[parts.length][1]; 
    //local definiteForm = w + ending;
    //tadsSay(' * "<<cur>>" (ändelse: "<<ending>>" antas vara <<isEndingNeuter?'neutrum':'utrum'>> \n');

    // Skapar upp individuella WordPart(s)-objekt av alla ordets komponenter 
    // Skippa den sista ändelsen (som redan finns i variabeln 'ending')
    for(local i = 1; i<=parts.length-1; i++) {
        local part = parts[i][1];
        //tadsSay(part);
        // Fånga in själva ordet isolerat, samt optionell 'genus-inverter (:)' och optionellt foge-S (^s)
        local match = rexMatch('([^<:^>]+)(:<alpha>*)?(<caret>s)?', part);
        if(match == nil) {
            // Varna om felaktig notation använts
            tadsSay('\n<font color=red>VARNING: Notationsmismatch av "<<cur>>"\n.Använd enligt följande mall: äpple+n, äppel+kaka+n,papper+et eller papper^s+flyg+plan+et</font>\n');
            continue;
        }
        local word = rexGroup(1)[3];        // Plocka ut själva ordet utan ändelse
        
        // Kontrollera om ordet bara ska vara med i en större sammansättning och inte enskilt
        // Om ordet slutar på | så kommer inte ett enskilt ord att skapas för komponenten. 
        local useIndividually =  parts[i][2] != '|';

        local jointS = rexGroup(3) != nil;  // Plocka ut true/false för foge-S
        local genderMod = rexGroup(2);      // Plocka grammatisk genus-moddning som boolesk
        local genderModContent = genderMod ? rexGroup(2)[3] : nil; // Plocka ut alternativ ändelse, annars nil

        // Den sista ordkomponenten (steget precis innan globaländelsen) hanteras separat.
        // Globaländelsen används alltid för bestämd form. Om komponenten har ':suffix'
        // utan foge-s sparas suffixet som altEnding och används för obestämd form
        // i stället för den nakna stammen.
        //
        // Exempel: 'fönst:er+ret' → word='fönst', ending='ret', altEnding='er'
        //   obestämd: fönster  (fönst + er)
        //   bestämd:  fönstret (fönst + ret)
        //
        // Exempel: 'tak+fönst:er+ret' → samma mekanism, nu i ett längre sammansatt ord
        //   tak/taket, takfönster/takfönstret, fönster/fönstret
        if(i == parts.length-1) {
            local altEnding = nil;
            if(genderMod && genderModContent && !jointS) {
                local suffix = genderModContent.findReplace(':', '', ReplaceAll);
                if(suffix.length() > 0)
                    altEnding = suffix;
            }
            wordParts.append(new WordPart(word, ending, nil, useIndividually, altEnding));
            break;
        } 

        // Annars, kontrollera om det finns ett undantag till genus, 
        // detta mönster inleds av användaren med kolon och en eventuellt 
        // bifogad annan ändelse. Om ingen ändelse anges, kommer kolon 
        // betyda motsatsen till den slutliga ändelsen för ordet.
        
        local partEnding = ending;  // Utgå från att komponenten får samma ändelse som ändelsen för helhetsordet

        if(genderMod) {
            if(genderModContent) {
                // Om kolon + eventuell ny ändelse har påträffas behöver det hanteras
                // Kontrollera om det finns en ändelse bifogad efter kolonet, och skriv i så fall 
                // över partEnding.
                genderModContent = genderModContent.findReplace('^s', '', ReplaceAll);
                genderModContent = genderModContent.findReplace(':', '', ReplaceAll);
                partEnding = genderModContent;
            } else {
                // Om genus-ändelsen saknas försöker vi härleda genus så gott det går
                // Om ordet slutar på vokal eller inte är en god guidning till ett flertal fall
                local endsWithVocal = rexMatch('.*[aeioyu]$', word);

                // Ett-ord, kan sluta på vokal: äpple-t,  eller konsonant, träd-et, lock-et
                // OBS: fixar inte former så som skimmer/skimret, dessa får läggas till som separata ord
                if(isEndingNeuter) {
                    // Neutrum  som slutar vokal, t ex: äpple-t 
                    // Alternativ konsonant, så som: träd-et
                    partEnding = endsWithVocal? 't' : 'et'; 
                
                } else {
                    if(endsWithVocal) {
                        partEnding = 'n'; // en-ord som slutar på vokal, t ex: fura, pinne,
                    } else {
                        // Utrum (-en-ord) som slutar på konsonant.
                        // Här är det omöjligt att veta säker, men en gissning är att om ordet 
                        // slutar på -el, -er, -or eller -al kan vi lägga på ett enkelt 'n'
                        // så som, cykel-n dator-n, teater-n
                        partEnding = rexMatch('.*(el|er|or|al)$', word) ? 'n' : 'en';
                        //tadsSay('SLUTAR PÅ KONSONANT UTRUM: <<word>> = <<partEnding>>');
                    }
                }
            }
        } else {
            local endsWithVocal = rexMatch('.*[aeioyu]$', word);
            // PLURAL
            
            if((matchFlags & MatchPlural) != 0) {
                // Vid plural gör vi ingenting än så länge... oftast skriver man formen direkt i obestämd+bestämd
                // form, t ex: äpplen+a
                // Utarbeta detta vid behov.
            } else if(isEndingNeuter) {
                partEnding = endsWithVocal? 't' : 'et';   // NEUTRUM
            } else {
                if(endsWithVocal) {
                    partEnding = 'n';                     // UTRUM, t ex: fura, pinne får "n" som ändelse.
                } else {
                    // Omöjligt att egentligen veta, men en god gissning är att om ordet slutar på el,er,or eller al
                    partEnding = rexMatch('.*(el|er|or|al)$', word) ? 'n' : 'en';
                    //tadsSay('SLUTAR PÅ KONSONANT UTRUM: <<word>> = <<partEnding>>');
                }
            }
        }
        wordParts.append(new WordPart(word,partEnding,jointS, useIndividually));
    }
    local wordPartsList = wordParts.toList();
    local nParts = wordPartsList.length;

    // Beräkna longestCompoundWord för standardForm/definiteForm i returvärdet.
    // Det är alltid hela prefixet (start=1, len=nParts).
    local longestCompoundWord = wordPartsList
        .mapAll({x: '<<x.word>><<x.jointS?'s':''>>'})
        .join('');
    if(wordPartsList[nParts].jointS)
        longestCompoundWord = longestCompoundWord.substr(1, -1);

    // Generera alla angränsande delfönster (start, längd) och lägg till
    // både grundform och bestämd form för varje fönster.
    // Täcker enskilda ord (len=1), mellansummansättningar och hela sammansättningen.
    for(local start = 1; start <= nParts; start++) {
        for(local len = 1; start + len - 1 <= nParts; len++) {
            local sub = wordPartsList.sublist(start, len);
            local lastPart = sub[sub.length];

            local compound = sub.mapAll({x: '<<x.word>><<x.jointS?'s':''>>'}).join('');
            if(lastPart.jointS) compound = compound.substr(1, -1);

            if(lastPart.useIndividually) {
                // Obestämd form: om altEnding finns (t ex 'fönst:er') används
                // stam+altEnding i stället för den nakna stammen.
                wordVariations.append(lastPart.altEnding != nil
                    ? compound + lastPart.altEnding
                    : compound);
                wordVariations.append(compound + lastPart.ending);
            }
        }
    }

    // Obestämd och bestämd form för hela sammansättningen.
    // Om sista WordPart har altEnding används den för obestämd form.
    local lastWordPart = wordPartsList[nParts];
    local wordWithoutEnding = lastWordPart.altEnding != nil
        ? longestCompoundWord + lastWordPart.altEnding
        : longestCompoundWord;
    local wordWithEnding = longestCompoundWord + ending;

    if(enableShortenRepeatingCharacters) {
        wordVariations = wordVariations.mapAll(shortenRepeatingCharacters);
        wordWithoutEnding = shortenRepeatingCharacters(wordWithoutEnding);
        wordWithEnding = shortenRepeatingCharacters(wordWithEnding);
    }

    // Ta bort dubbletter, kanske onödigt då cmdDict redan är ett table, så när dessa 
    // adderas dit kommer bara dubbletter skrivas över ändå.
    wordVariations = wordVariations.getUnique();
    //tadsSay('Word variations: ' + wordVariations.mapAll({x: '<<x.word>>'}).join(', '));
    wordVariations.forEach(function(wordVariation) {
        //tadsSay(wordVariation);
        obj.addDictWord(wordVariation, partOfSpeech, matchFlags);
        //cmASdDict.addWord(obj, wordVariation, matchFlags);  
        /*
        #ifdef __DEBUG
            displayWordPart(sectPart, wordVariation, obj);
        #endif
        */
    });

    //tadsSay(wordWithoutEnding, '\ ');
    //tadsSay(wordWithEnding,'\n');
    return object {
        standardForm = wordWithoutEnding
        definiteForm = wordWithEnding
    };
}




#ifdef __DEBUG

//###############################
//### SVENSKA DEBUGFUNKTIONER ###
//###############################

// 'vokab' listar alla ord och vilken kategori de tillhör (substantiv, adjektiv, plural)
DefineIAction(Vocab)
    execAction(cmd) {
        displayVocab();
    }
;

function displayVocab() {
    local objList = [];
    local stringList = [];
    local propList = [];
            
    local nounList = [];
    local adjectiveList = [];
    local pluralList = [];
    local adjApostSList = [];
    local litAdjList = [];

    cmdDict.forEachWord({ x,y,z: objList += x});
    cmdDict.forEachWord({ x,y,z: stringList += y});
    cmdDict.forEachWord({ x,y,z: propList += z});
    
    local len = objList.length();
    for (local i = 1; i < len; i++) {
        local obj = propList[i];
        switch(obj) {
            case &noun:               nounList += stringList[i]; break;
            case &adjective:          adjectiveList += stringList[i]; break;
            case &plural:             pluralList += stringList[i]; break;
            case &adjApostS:          adjApostSList += stringList[i]; break;
            case &literalAdjective:   litAdjList += stringList[i]; break;
        }
    }
    "<.p>[NOUNS]<.p>";              foreach (local cur in nounList)         "\^<<cur>> ";
    "<.p>[ADJECTIVES]<.p>";         foreach (local cur in adjectiveList)    "\^<<cur>> ";
    "<.p>[PLURALS]<.p>";            foreach (local cur in pluralList)       "\^<<cur>> ";
    "<.p>[ADJAPOSTS]<.p>";          foreach (local cur in adjApostSList)    "\^<<cur>> ";    
    "<.p>[LITERALADJECTIVE]<.p>";   foreach (local cur in litAdjList)       "\^<<cur>> ";
}

DefineLiteralAction(Vokabular);

VerbRule(Vokabular)
    'vokab' | 'voc' | 'vocab' | 'vokabulär' | 'vokabulär'
    : VerbProduction
    action = Vocab 
    verbPhrase = 'se/ser vokabulär'
; 

DefineTAction(Ord)
    execAction(cmd) {
        //local obj = cmdDict.findWord(gCommand.verbProd.tokenList[1][1])[1];
        //tadsSay(cmd.dobj);
        local str = new Vector();
        for(local vw in cmd.dobj.vocabWords) {
            str.append(' * <<vw.wordStr>> <<vw.posFlags>>\n'); 
        }
        str.sort();
        local explain =  'Hittade objektet: [<<obj>>], 
        \bFöljande ord finns definierade:
        \b';
        say(toString(explain + str.join('')));
    }
    afterAction() { }
    turnSequence() { }
;

VerbRule(Ord)
    ('ord'|'ordgranska') singleDobj
    : VerbProduction
    action = Ord  
    verbPhrase = 'ordgranska/ordgranskar (vad)'
    missingQ = 'vad vill du ordgranska'
; 

function displayGrammarInfo(o) {
    say('Needs to be adapted to adv3Lite');
    /*
    local str = new StringBuffer();
    str.append('\n');
    cmdDict.forEachWord(function(obj, word, wordPart) {
        try {
            if(obj == o) {
                local grammarFunction = 'okänd';
                if(wordPart == &noun) grammarFunction = 'substantiv';
                else if(wordPart == &literalAdjective) grammarFunction = 'literalAdjective';
                else if(wordPart == &adjApostS) grammarFunction = 'adjApostS';
                else if(wordPart == &plural) grammarFunction = 'plural';
                else if(wordPart == &adjective) grammarFunction = 'adjektiv';
                str.append('<<word>> (<<grammarFunction>>) \n');
            }
        } catch(Exception e) {
            tadsSay('Felaktig jämförelse: <<e>>\n');
        }
    });
    str.append('\b');
    return toString(str);
    */
}

function displayWordPartOnly(wordPart) {
    if(wordPart == &noun) {
        tadsSay(' &noun ');
    }
    if(wordPart == &plural) {
        tadsSay(' &plural ');
    }
    if(wordPart == &adjective) {
        tadsSay(' &noun ');
    }
    if(wordPart == &literalAdjective) {
        tadsSay(' &literalAdjective ');
    }
    if(wordPart == &adjApostS) {
        tadsSay(' &adjApostS ');
    }
}

function displayWordPart(wordPart, cur, obj) {
    if(wordPart == &noun) {
        tadsSay('\ <<cur>> (substantiv)');
    }
    if(wordPart == &plural) {
        tadsSay('\ <<cur>> (plural)');
    }
    if(wordPart == &adjective) {
        tadsSay('\ <<cur>> (adjektiv)');
    }
    if(wordPart == &literalAdjective) {
        tadsSay('\ <<cur>> (literalAdjective)');
    }
    if(wordPart == &adjApostS) {
        tadsSay('\ <<cur>> (adjApostS)');
    }
    tadsSay('\t\t\t\t\t\t -> \ [<<obj.name>>]\n');
}



// We need to modify this because the original uses openTextFile with 'us-ascii' hardcoded
modify Test
    run()
    {
        "====================================\n";
        "Test: \"<<testName>>\"\n";

        if(restartBeforeTest) {
            local hld = allNewTests.savedState();
            if(allNewTests.restoregame(&restartSaveFile) == nil) {
                allNewTests.isTesting = nil;    // failed so quit the test
                return;
            }
            allNewTests.restoreState(hld);
        }

        /* we save the entire game at this point by default to restore it */
        if(restoreStartStateAfterTest)
            allNewTests.savegame(&revertSaveFile); // save the current state

        /* 
         *   If a location is specified, first move the actor into that
         *   location.
         */
        if (location && gPlayerChar.location != location)
        {
            gPlayerChar.moveInto(location);	
            
            /* If we want to report the move, show the new room description */
            if(reportMove)
                gPlayerChar.getOutermostRoom.lookAroundWithin();
        }
        
        /*   Move any required objects into the actor's inventory */
        getHolding();

        /* Export a file to use */
        local txt;
        local temp = new TemporaryFile();
        local f = File.openTextFile(temp, FileAccessWrite, 'utf-8'); // NOTE: why we need to modify this class

        local testVec = new Vector(testList);

        /*   Preparse and execute each command in the list */
        local linecnt = 0;
        testVec.forEach(new function(x)  {
            local c = x.trim();
            f.writeFile('><<c>>\n');
            ++linecnt;
        });
        f.closeFile();
        allNewTests.isTesting = true;
        setScriptFile(temp,ScriptFileNonstop);
        do
        {
            /* Display score notifications if the score module is included. */
            if(defined(scoreNotifier) && scoreNotifier.checkNotification())
                ;
            
            /* run any PromptDaemons if the events module is included */
            if(defined(eventManager) && eventManager.executePrompt())
                ;
        
            try
            {
                /* Output a paragraph break */
                "<.p>";
                
                /* Read a new command from the keyboard. */
                "<.inputline>";
                DMsg(command prompt, '>');
                txt = inputManager.getInputLine();
                "<./inputline>\n";   
                
                if(clearAssertBufferBeforeCmd && !txt.startsWith('assert'))
                    allNewTests.lastMsg = '';
                
                
                /* Pass the command through all our StringPreParsers */
                txt = StringPreParser.runAll(txt, Parser.rmcType());
                
                /* 
                 *   If the txt is now nil, a StringPreParser has fully dealt with
                 *   the command, so go back and prompt for another one.
                 */        
                if(txt == nil)
                    continue;
                
                /* Parse and execute the command. */
                Parser.parse(txt);
            }
            catch(TerminateCommandException tce)
            {
                
            }
            
            /* Update the status line. */
            statusLine.showStatusLine();
 
        } while (--linecnt > 0 && allNewTests.isTesting);

        if(restoreStartStateAfterTest) {

            local hld = allNewTests.savedState();
            allNewTests.restoregame(&revertSaveFile); // restore the saved state
            allNewTests.restoreState(hld);
        }
        // this means an error happened so this script needs to go away
        if(!allNewTests.isTesting)
            setScriptFile(nil);
        temp.deleteFile();        
    }
;

#endif



