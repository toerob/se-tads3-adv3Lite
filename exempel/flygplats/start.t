#charset "utf-8"

#include <tads.h>
#include "advlite.h"

versionInfo: GameID
    IFID = 'bcb7d5c4-81ee-30b0-5aec-7672b10e2cd6' 
    name = 'Flygplats'
    byline = 'by Michael Roberts (och Eric Eve), översatt av Tomas Öberg'
    htmlByline = 'by <a href="mailto:an.author@somemail.com">
                  A.N. Author</a>'
    version = '1'
    authorEmail = 'A.N. Author <an.author@somemail.com>'
    desc = 'Your blurb here.'
    htmlDesc = 'Your blurb here.'    
    
;

gameMain: GameMainDef
    /* Define the initial player character; this is compulsory */
    initialPlayerChar = me
    paraBrksBtwnSubcontents = nil
    
    showIntro()
    {           
       "<font size=+2><b>Flygplats</b></font>\b
       De är ute efter dig. Nej, dem är verkligen det --- <q>de</q> är de 
       lokala knarkbaronerna. Du har precis fått tag i bevisen som kommer att 
       sätta  dem bakom galler för resten av århundradet, och nu är du 
       desperat att ge dig av med dem medan du fortfarande kan, eftersom 
       El Diablo och hans hantlangare  kommer att vara lika desperata att 
       stoppa dig --- för gott. De har förföljt dig så långt som till 
       flygplatsen och nu är ditt enda  hopp att få ut det första planet 
       härifrån.\b";
    }     
    
    usePastTense = nil
;


/* The starting location; this can be called anything you like */

terminal: Room 'Terminalen' 'terminal'   
    "Du befinner dig i flygplatsens huvudterminal. Till öster ser du några biljettdiskar 
    och till norr ligger samlingshallen. Huvudutgången till staden och parkeringsplatserna 
    ligger direkt söderut."
    east = ticketArea
    north = securityGate
    south 
    { 
        "Om du går tillbaka ut genom den vägen kommer du troligtvis att springa rakt in 
        i en hagelskur av kulor.";
    }
        
    out asExit(south)
;

/* 
 *   The player character object. This doesn't have to be called me, but me is a
 *   convenient name. If you change it to something else, rememember to change
 *   gameMain.initialPlayerChar accordingly.
 */

+ me: Actor 'du'   
    "Hemliga agenter är normalt menade att vara välutrustade, men den snabba 
    flykt du just behövde göra innebar att du var tvungen att lämna nästan
    allt bakom dig förutom det du har på dig, och det är inte mycket. Du kan 
    inte ens gå tillbaka för att hämta din plånbok eller ditt kreditkort. "

    isFixed = true    
    proper = true
    ownsContents = true
    person = 2   
    contType = Carrier    
;


ticketArea: Room 'Biljettområdet' 'biljettområdet'
    "Du är i biljettkassan. Biljettkassorna kantar den norra 
    väggen; så många människor står i kö att du är säker på att 
    du aldrig kommer att lyckas komma till en agent. 
    Huvudterminalen ligger baktill till väst."
    west = terminal
;

+ counter: Surface, Fixture 'biljett|kassa+n; obevakad+e' 
    "Biljettkassan går runt två sidor av området och är bemannad av för 
    få hårt ansträngda expediter, medan minst hälften är helt obevakad."
;

++ IDcard: Key 'ett ID-kort+et;identifikation dålig+t; foto+t id|kort+et id+t'     
    "Enligt vad som står på framsidan tillhör den tydligen en viss Antonio 
    Velaquez. Som tur är är det bifogade fotot så dåligt att det skulle 
    kunna vara på nästan vem som helst, till och med dig. En magnetremsa 
    löper längs baksidan."
    
    actualLockList = [securityDoor]
    plausibleLockList = [securityDoor]
    
    bulk = 1
    
    dobjFor(ShowTo)   {  preCond = [objHeld]   }
;

//magnetremsa; magnetisk brun metallisk; remsa
//+++ Fixture 'magnetic stripe; mag metallic brown; strip'
+++ remsa: Fixture 'magnetisk+a remsa+n; mag metallisk+a brun+a'
    "Det är en brun metallisk remsa som löper längs kortets baksida."
    name = 'magnetisk remsa'
    
    cannotTakeMsg = 'Det skulle vara ganska svårt att dra bort 
    magnetremsan från kortet, och det skulle nästan säkert göra kortet 
    oanvändbart om du gjorde det.'
;

//+ Decoration 'people; of[prep]; line queue tourists businesspeople; dem'

+ Decoration 'folk+et; av[prep]; kö+n turist+er affärsmän+nen; dem'
    "En brokig samling turister och affärsmän, så vitt man kan bedöma, många 
    av dem ser alltmer frustrerade ut över köns längd."
    
    /*e = "A motley collection of tourists and businesspeople, so far as you can
    tell, many of them looking increasingly frustrated at the length of the
    queue. "*/
  
    notImportantMsg = 'Du har inte tid att bry dig om dem, och du vill inte 
    riskera att dra uppmärksamhet till dig själv.'
;

+ Decoration 'bokningsbiträden+a; biljett+er man+nen kvinna+n hårt pressad+e; 
            män+nen kvinnor+na agenter+na agent|biträde+n Boknings|personal+en; dem'
    "Bokningspersonalen, ungefär lika många män och kvinnor, verkar alla  
    sakna den brådska som krävs för att betjäna de ständigt längre köerna."
    notImportantMsg = 'Dessvärre kan du inte komma i närheten till någon av dem. '
;


securityGate: Room 'Säkerhetsgrind' 'Säkerhetsgrinden'
    "Du är vid säkerhetsgrinden som leder in till samlingshallen 
    och ombordstigningsgaten. Samlingshallen ligger norrut, genom en 
    metalldetektor. Terminalen ligger bakåt, söderut."
    north = metalDetector
    south = terminal
;

+ metalDetector: Passage 'metall|detektor+n; enkel; metall+ram+en'
    "Metalldetektorn är inte mycket mer än en enkel metallram, precis 
    stor nog att kliva igenom, med en strömkabel som släpar över golvet."
    destination = concourse
    
    isOn = (powerSwitch.isOn == true)
    
    canTravelerPass(traveler)
    {
        return !isOn || !IDcard.isIn(traveler);
    }
    
    explainTravelBarrier(traveler)
    {
        "Metalldetektorn surrar ursinnigt när du passerar igenom den. 
        Säkerhetsvakten vinkar omedelbart tillbaka dig med ett skarpt knack 
        med sin hölsterpistol. Efter ett snabbt sökande upptäcker han 
        ID-kortet och tar det ifrån dig med en ogillande huvudskakning, 
        innan han räcker det till en kollega som går iväg med det. 
        <.reveal kort-konfiskerat> ";

        /*eng = "The metal detector buzzes furiously as you pass through it. The
        security guard beckons you back immediately, with a pointed
        tap of his holstered pistol. After a brisk search, he discovers the ID
        card and takes it off you with a disapproving shake of his head,
        before handing it to a colleague who walks off with it. <.reveal
        card-confiscated> ";*/
        
        IDcard.moveInto(counter);
    }
    
    travelDesc()
    {
        "Du passerar metalldektorn utan någon incident. ";
        
        if(takeover.startedAt == nil)
            announcementObj.start();
    }
;

+ powerCable: Decoration 'el|kabel+n; släpande; sladd+en tråd+en trådar+na[pl]'
    "Kabeln släpar ganska slakt från ena sidan av metalldetektorn över golvet 
    och sedan utom synhåll bakom ett skrivbord till höger på den bortre sidan. 
    Du är inte säker på att det är ett arrangemang som skulle uppskattas av 
    hälso- och säkerhetsinspektörerna därhemma, men det verkar fungera."

    /*eng = "The cable trails rather slackly from one side of the metal detector across
    the floor and then out of sight behind a desk over to the right on the far
    side. You're not sure it's an arrangement that would find favour with health
    and safety inspectors back home, but it appears to do the job. "*/
    
    notImportantMsg = 'Du är moraliskt säker på att säkerhetsvakten inte kommer 
    låta dig komma i närheten av den. '
        
;

//Hall' 'hall; lång; korridor'
concourse: Room 'Samlingshallen' 'samlingshall+en; lång+a; hall+en'
    "Du är i en lång korridor som förbinder terminalbyggnaden 
    (som ligger söderut) med gaterna (som ligger norrut). I öster 
    finns en snack bar och en dörr som leder västerut. Bredvid dörren till 
    väster, är en liten springa som ser ut som den accepterar magnetiska 
    ID-kort för att manövrera dörrlåset. "

    /*eng = "You are in a long hallway connecting the terminal
    building (which lies to the south) to the boarding gates (which are
    to the north). To the east is a snack bar, and a door leads west.
    Next to the door on the west in a small slot that looks like it
    accepts magnetic ID cards to operate the door lock. "*/
    
    north = gateArea
    south = securityGate
    east = snackBar
    west = securityDoor
;

+ securityDoor: Door 'säkerhets|dörr+en'
    "Den är tydligt markerad PRIVADO och är <<if isOpen>> för närvarande öppen<<else>>
    ordentligt stängd<<end>>. "
    
    otherSide = concourseDoor
    
    lockability = lockableWithKey    
    isLocked = true    
    
    makeLocked(stat)
    {
        inherited(stat);
        if(stat == nil)
        {
            makeOpen(true);
            "Dörren öppnas upp en bråkdel när den låses upp. ";
        }
    }
    
    makeOpen(stat)
    {
        inherited(stat);
        if(stat == nil && !gAction.isImplicit)
        {
            makeLocked(true);
            "Du hör ett svagt klick när dörren låser sig själv när du stänger den. ";            
        }
        
        if(stat)
            securityAchievement.awardPointsOnce();       
        
    }
    
    
;

// TODO: bättre ord för slot
+ cardslot: Fixture 'kort|fack+et;;kort|plats+en'  
    "Facket verkar acceptera speciella ID-kort med magnetisk kodning. Om du hade 
    ett lämpligt ID-kort kunde du sätta in det i facket för att öppna dörren."
    /*"The slot appears to accept special ID cards with magnetic encoding. If you
    had an appropriate ID card, you could put it in the slot to open the door. "*/
    
    cannotPutInMsg = '{Ref subj dobj} {ser} inte ut som om {han dobj} är menad att
        passa in där. '
;

Doer 'sätt IDcard i cardslot'
    execAction(c)
    {
        doInstead(UnlockWith, securityDoor, IDcard);
    }
;

Doer 'lås securityDoor; lås securityDoor med IDcard'
    execAction(c)
    {
        doInstead(Close, securityDoor);
    }    
;

snackBar: Room 'Matställe' 'matstället'
    "Matstället verkar vara full av resenärer som trängs med varandra för att 
    komma till serveringsdisken, eller äter sina homogeniserade snacks vid de 
    trånga borden, även om det av någon anledning fortfarande finns ett bord 
    ledigt. Västerut ligger den relativa lugnet i hallen"

    /*"Snack baren seems to be full of passengers jostling one another to get at
    the serving counter, or consuming their homogenized snacks at the crowded
    tables, though for some reason, one table remains free. To the west lies
    the relative calm of the concourse. "*/

    west = concourse
    out asExit(west)
;
    
+ Decoration 'resenärer+na; ; lokala amerikansk+a människor+na; dem'

    "Av ljudet att döma från deras röster verkar de vara en blandning av 
    amerikaner och lokalbefolkning, alla lika ledigt klädda
    <<if darkSuits.isIn(location)>> -- förutom en handfull män i mörka kostymer<<end>>."

    /*"From the sound of their voices they seem to be a mixture of Americans and
    locals, all alike casually dressed<< if darkSuits.isIn(location)>> -- except
    for a handful of men in dark suits<<end>>. "*/
;

+ darkSuits: Decoration 'män[n] i[prep] mörk+a kostymer; ondskefull+a senior+a; 
    löjtnanter+na; dem'    
    "Även för det otränade ögat skulle de förmodligen se ganska ondskefulla ut. 
    För dig ser de än värre ut än så; du är ganska säker på att de är några av 
    El Diablos högre löjtnanter. Som tur är verkar de för upptagna av sin 
    diskussion i den andra änden av rummet just nu för att lägga märke till dig."
    
    notImportantMsg = 'Just nu, vill du inte gå närheten av dem. '
;

+ Decoration 'fullsatt+a bord+en;;;dem'
    
;

+ Surface, Fixture 'bord+et;oupptag:et+na fri:a+tt li:tet+lla run:t+da'
    "Kanske är anledningen till att detta bord ej är upptaget är för att det inte
    finns några stolar runt det; förmodligen har de alla lånats åt resenärerna
    vid de andra borden. "
    name = 'oupptaget bord'
;

++ newspaper: Thing 'tidning+en; narcosia; papper:et^s+härold+en'
    "Det är den senaste utgåvan av <i>Narcosia Herald</i>."
    

    readDesc =  '''En snabb skumning av tidningen avslöjar inget ovanligt för denna del 
                av världen. Ännu en minister förnekar anklagelser om 
                korruption, penningtvätt och njuta av ett överflöd av älskarinnor vars 
                kombinerade ålder skulle bara gå jämnt upp med hans. Bara arton 
                gängrelaterade mord begicks på gatorna i Narcosia i går, vilket gjorde 
                det  till en ovanligt lugn dag i huvudstaden. Presidenten hade försvarat 
                spenderingar på ytterligare tjugo miljarder biljoner terapesos (ungefär 
                en halv miljard dollar) på ännu en storslagen förlängning av hans palats
                på tomten med att det är avgörande för nationell prestige och säkerligen 
                kommer att locka den typen av utländska investeringar som kommer att 
                lyfta de fattigaste åttio procent av nationen till något närmare 
                svältgränsen. Försvarsministern gratuleras för hans skicklighet att köpa 
                upp aktier i Polemicorp International före han lägger en stor vapenorder 
                hos dem; ekonomiministern citeras för att säga att detta är precis den 
                sorten entreprenörsanda som landet behöver. Polisen har återigen 
                misslyckades med att göra några arresteringar av de driftiga 
                knarkbaronerna som till stor del finansierar deras pensionspottar. 
                Sammantaget är det business as usual -- förutom vissa redaktionella 
                spekulationer om att El Diablo kanske planerar något <i>stort</i>, men 
                det visste du ändå; det var det som förde dig till detta gudsförgätna 
                helveteshål. '''

    /*
    readDescEng = '''A quick skim of the paper reveals nothing unusual for this part
        of the world. Yet another government minister is denying charges of
        corruption, money-laundering and enjoying a surfeit of mistresses whose
        combined age would only just add up to his. Only eighteen gang-related
        killings were committed on the streets of Narcosia yesterday, making it
        an unusually quiet day in the capital. The President had defended
        spending another twenty billion trillion terapesos (about half a billion
        dollars) on yet another grand extension to his palace on the grounds
        that it vital to national prestige and will surely attract the kind of
        foreign investment that will lift the poorest eighty per cent of the
        nation slightly closer to the breadline. The defence minister is
        congratulated for his acumen in buying up stock in Polemicorp
        International before placing a large arms order with them; the finance
        minister is quoted as saying that this is just the kind of
        entrepreneurial spirit the country needs. The police have once again
        failed to make any arrests of the enterprising drug barons who are
        largely funding their pension pots. All in all, it's business as usual
        -- except for some editorial speculation that El Diablo may be planning
        something <i>big</i>, but you knew that anyway; that's what brought you
        to this godforsaken hell-hole. '''
   */ 
    hiddenIn = [ticket]
    
    revealOnMove()
    {
        
        if(hiddenIn.length > 0)
        {

            //"As you pick up the newspaper <<list of hiddenIn>> {prev} {falls}
            //out of it and land{s/ed} on the floor. ";

            "När du hämtar tidningen {faller} <<list of hiddenIn>> ut ur den
            och landa{r/de} på golvet. ";
            
            moveHidden(&hiddenIn, getOutermostRoom);
        }
    }
    
    lookInMsg = (readDesc)
    
    bulk = 4
;

ticket: Thing 'biljett+en'
    "Det är en biljett för flyg TI 179 till Buenos Aires. "
    
    readDesc = (desc)
    specialDesc = "En biljett ligger på på golvet. " // TODO: eller marken?
    useSpecialDesc = (location == getOutermostRoom)
    
    bulk = 1
    
    dobjFor(Take)
    {
        action()
        {
            inherited;
            ticketAchievement.awardPointsOnce();
        }   
    }
;

securityArea: Room 'Säkerhetsområde' 'säkerhetsområde'
    "Detta något kala rum verkar vara lobbyn för andra områden. Det finns 
    utgångar  åt söder och väster, medan vägen ut tillbaka till hallen går 
    genom dörren österut."
        
    east = concourseDoor
    south = lounge
    west = securityCentre
    out asExit(east)
    
;

+ concourseDoor: Door 'dörr+en'
    "Den är för nuvarande <<if isOpen>>öppen <<else>>stängd<<end>>. "
    
    otherSide = securityDoor
;

// TODO: bookmark
lounge: Room 'Pilotloungen' 'pilotloungen'
    "Även om den något bleka inredningen i det här rummet inte antyder att det är 
    tänkt till att vara någon sorts relaxavdelning, så är det tydligt nog med tanke 
    på den långa soffan som löper längs ena väggen samt de utspridda fåtöljerna. Den 
    enda vägen ut är norrut."


    // eng = "Even if the somewhat faded decor of this room didn't suggest that it was
    // meant to be some sort of relaxation area, this is plain enough from the long
    // settee that runs along one wall and the scattering of easy chairs. The only
    // way out is to the north. "

    
    north = securityArea
    out asExit(north)
;

+ suitcase: Thing 'res|väska+n;svart+a' 
    "Det är en svart resväska med ett kombinationslås och ett tydligt
    klistermärke med en fransk trikolor och sloganen <q>Vive la revolution 
    francaise!</q>."
    // "It's a black suitcase with a combination lock and a prominent sticker
    // bearing a French tricolor and the slogan <q>Vive la revolution
    // francaise!</q>. "
    initSpecialDesc = "En resväska står prydligt placerad brevid soffan. "  
    
    bulk = 8
    
    remapIn: SubComponent
    {
        isOpenable = true
        lockability = indirectLockable
        isLocked = true
        bulkCapacity = 8
        indirectLockableMsg = 'Du måste använda kombinationslåset för det. '
        
        makeOpen(stat)
        {
            inherited(stat);
            if(stat)
                suitcaseAchievement.awardPointsOnce();
        }
    }
;
    

++ Fixture 'klister|märke+t; framträdande fransk+a; trikolor'
    "Klistermärket är tydligt markerat med en trikolor och bär sloganen
    <q>Vive la revolution francaise!</q> – Länge leve den franska 
    revolutionen!"  
    
    readDesc = (desc)
;

++ comboLock: Fixture 'kombinations|lås+et'
    "Kombinationslåset består av fyra små mässinghjul, varav vardera kan 
    rullas till ett valfritt tal mellan 0 och 9. Just nu visar de 
    kombinationen <<currentCombo>>."
    
    currentCombo = (wheel1.curSetting + wheel2.curSetting + wheel3.curSetting +
                    wheel4.curSetting)
    
    correctCombo = '1789'
    
    checkCombo()
    {
        if(currentCombo == correctCombo)
        {
            reportAfter('Du tycker dig höra ett svagt klick från låset.');
            location.remapIn.makeLocked(nil);            
        }
        else
            location.remapIn.makeLocked(true);
    }
    
;



+++ wheel1: ComboWheel 'mässing|hjulet;första 1+a li:ten+lla'
    name = 'första mässinghjulet'
    curSetting = '3'
    listOrder = 1
;

+++ wheel2: ComboWheel 'mässing|hjulet;andra 2+a li:ten+lla'
    name = 'andra mässinghjulet'
    curSetting = '5'
    listOrder = 2
;

+++ wheel3: ComboWheel 'mässing|hjulet;tredje 3+e li:ten+lla'
    name = 'tredje mässinghjulet'
    curSetting = '9'
    listOrder = 3
;

+++ wheel4: ComboWheel 'mässing|hjulet;fjärde 4+e li:ten+lla'
    name = 'fjärde mässinghjulet'
    curSetting = '2'
    listOrder = 4
;


++ uniform: Wearable 'pilot|uniform+en; timo stor+a large'  
    "Det är en uniform för en Timo Airlines-pilot. Den är lite för stor för dig, men
    <<if wornBy == gPlayerChar>> den passar inte så dåligt<<else>>du skulle nog kunna
    bära den <<end>>. "

    // eng = "It's a uniform for a Timo Airlines pilot. It's a little large for you, but
    // <<if wornBy == gPlayerChar>> it's not too bad a f<<else>>you could probably wear
    // <<end>>it. "
    
    bulk = 6
    subLocation = &remapIn
    
    dobjFor(Doff)
    {
        check()
        {
            "Efter all mödan det innebar att få tag på den här uniformen har 
            du ingen större brådska att ta av dig den. ";

            // "After going to all that trouble to get this uniform you're in no
            // hurry to take it off. ";
        }
    }
    
    makeWorn(stat)
    {
        inherited(stat);
        if(stat)
            uniformAchievement.awardPointsOnce();
    }
;

+ Decoration 'soffa+n;;lång+a' name = 'lång soffa';

+ Decoration 'fåtöljer+na[pl];;;dem'
;

class ComboWheel: NumberedDial
    desc = "Det är ett litet mässingshjul som kan vridas till valfritt tal 
        mellan 0 och 9, och det står för närvarande på <<curSetting>>. "
    
    // eng = "It's a small brass wheel that can be turned to any number between 0
    //     and 9, and is currently at <<curSetting>>. "
    
    maxSetting = 9
    
    cannotTakeMsg = 'Det kan du inte; det är en del av kombinationslåset.' 
                    //'You can\'t; it\'s part of the combination lock. '
    
    makeSetting(val)
    {
        inherited(val);
        location.checkCombo();
    }
;


securityCentre: Room 'Säkerhetscentral' 'säkerhetscentralen'
    // "Judging by the monitors on the walls, this must be some sort of security
    // centre. Otherwise the room is mostly bare apart from the utilitarian desk
    // located somewhere in the middle. The only way out is to the east. "
    "Av bildskärmarna på väggarna att döma måste detta vara någon sorts 
    säkerhetscentral. Rummet är annars mestadels tomt, förutom det funktionella 
    skrivbordet placerat någonstans i mitten. Den enda vägen ut är österut."

    
    east = securityArea
    out asExit(east)
;

+ Decoration 'säkerhets|monitorer+na; svart+a; skärmar+na ;dem'
    "De är alla blanka; antingen är de avstängda eller så fungerar de inte."
    
    notImportantMsg = 'Du har verkligen inte tid att leka med bildskärmarna.'
    //'You really don\'t have time to play around with the monitors. '
;

+ desk: Heavy 'metall|skrivbord; praktisk:a+t '
    "Det är ett praktiskt metallskrivobord med en enda låda. "
    
    remapIn = drawer
    remapOn: SubComponent { }    
;

++ drawer: Fixture, OpenableContainer 'låda+n'
    
    bulkCapacity = 5
    
    cannotTakeMsg = 'Lådan är en del av skrivbordet. '
;

+++ notebook: Thing 'anteckning^s+bok+en; li:ten+lla grön+a; skrivbok+en'
    "Det är bara en liten grön bok med text i. "
    
    readDesc = "Det visar sig vara fullt av flera slumpmässiga 
        tecken, alla överstrukna förutom det sista, som lyder 
        <<password>>. "
    
    
    // "It turns to be full of lots of sets of random-looking
    //     characters, all crossed out apart from the last, which reads
    //     <<password>>. "

    password = 'B49qJt0'
    
    dobjFor(Open) asDobjFor(Read)
;

++ computer: Heavy, Consultable 'dator+n;; pc+n tangentbord+et tangenter+na[pl] skärm+en'
    "Datorn är för närvarande <<if isOn>>påslagen och <<if passwordEntered>> redo
    att användas<<else>> väntar på att du ska skriva in ett lösenord<<end>> <<else>>
    avstängd<<end>>."
    
    specialDesc = "En dator stär rätvinkligt på ovanpå skrivbordet. "
    subLocation = &remapOn
    
    isSwitchable = true
    
    makeOn(stat)
    {
        inherited(stat);
        if(stat)
        {
            "Datorn bootar raskt igång och visar upp en skärm som ber dig att 
            skriva in ett lösenord. ";
            passwordEntered = nil;
        }
        else
            "Datorn stänger raskt ner. ";
    }
    
    passwordEntered = nil
    
    dobjFor(ConsultAbout)
    {
        check()
        {
            if(!isOn)
                "Du kan inte göra det förrän datorn har slagits på. ";
            else if(!passwordEntered)
                "Du behöver skriva in ett lösenord först. ";
        }
    }
    
    canEnterOnMe = true
    
    dobjFor(EnterOn)
    {
        check()
        {
            if(!isOn)
                "Du kan inte göra det förrän datorn har slagits på. ";
            
            else if(passwordEntered)
                
                "Du har redan knappat in lösenordet;  detta är inte rätt läge att börja 
                experimentera med slumpmässiga kommandon ";
        }
        
        action()
        {
            if(gLiteral == notebook.password)
            {
                //"The computer displays WELCOME for a few seconds, and then
                //clears to allow you to enter commands. ";
                
                "Datorn visar VÄLKOMMEN i några sekunder och sedan 
                försvinner texten så att du kan ange kommandon. ";

                
                passwordEntered  = true;
            }
            else
                //"The computer flashes PASSWORD NOT RECOGNIZED at you. ";
                "Datorn blinkar med texten OIGENKÄNNLIGT LÖSENORD. ";
                
        }
    }
 
    dobjFor(TypeOn) asDobjFor(EnterOn)
    
;

+++ ConsultTopic @tFrenchRevolution
    "Enligt Wikipedia började den franska revolutionen 1789. Artikeln fortsätter 
    med att berätta en hel del mer om den, men du har inte tid att läsa allt nu."

    // "According to Wikipedia, the French Revolution began in 1789. The article
    // goes on to tell you quite a bit more about it, but you don't have time to
    // read it all now. "
;

+++ ConsultTopic @tFlightDepartures

    "Så vitt du kan se utifrån informationen som visas, kommer Timo Flight 179 
    till Buenos Aires sannolikt att vara den enda flygningen som kommer 
    härifrån under de närmaste timmarna, alla andra är försenade av en mängd 
    olika irriterande orsaker, såsom strejker, sjukdom och dåligt väder."

    // "So far as you can tell from the information displayed, Timo Flight 179 to
    // Buenos Aires is likely to be the only one out of here for the next several
    // hours, all the others being delayed for a variety of annoying reasons such
    // as strikes, illness and inclement weather. "
;

+++ DefaultConsultTopic
    "Detta är inte av omedelbart intresse för dig just nu; du har mer brådskande 
    saker att ta itu med."
    // "That's of no immediate interest to you right now; you have more urgent
    // things to attend to. "
;

tFrenchRevolution: Topic 'fransk+a revolution+en';
tFlightDepartures: Topic '() flight flyg|avgångar+na; plan+et; flyg|tider+na[pl] tidsplaner+na[pl]';
tPilot: Topic 'pilot+en';
tDoingTonight: Topic 'hon gör ikväll; hon är du ära';
tEnjoyWork: Topic 'hon tycker om sitt arbete+t; du tycker om ditt gillar jobb+et; ditt jobb+et';
                // she enjoys her work; you enjoy your like likes; job';

VerbRule(GoogleFor)
    'googla' ('efter'|'om'|'på'|) topicIobj 'på' singleDobj
    : VerbProduction
    action = ConsultAbout
    
    verbPhrase = 'slå/slår upp (vad) (i vad)'
    missingQ = 'vad vill du googla det på;vad vill du googla'
    dobjReply = singleNoun
;

ticketAchievement: Achievement +10 "hitta flygbiljetten";
boardingAchievement: Achievement +10 "gå ombord på planet";
escapeAchievement: Achievement +10 "fly Pablo Cortez";
powerAchievement: Achievement +10 "stänga av strömmen till metalldetektorn";
securityAchievement: Achievement +10 "öppna säkerhetsdörren";
suitcaseAchievement: Achievement +15 "öppna resväskan";
uniformAchievement: Achievement +10 "ta på sig pilotens uniform";
cockpitAchievement: Achievement +10 "gå in i cockpiten";
flyingAchievement: Achievement +15 "flyg planet";


TopHintMenu;

+ Goal 'Var kan jag hitta en flygbiljett?'
    [
        'Du har inte medel att köpa en. ',
        'Men det kanske är någon annan som har förlagt bort sin. ',
        'Om du söker runt lite kanske du kan hitta den. ',
        'Vart brukar folk på en flygplats gå medan de väntar på ett flyg? ',
        'Särskilt om de är lite sugna. ',
        'Har du besökt matstället? ',
        'Har du sett något kvarliggandes där? ',
        'Försök ta en närmare titt på den där tidningen. '
    ]
    
    openWhenSeen = angela
    closeWhenAchieved = ticketAchievement
;

+ Goal 'Hur får jag ID-kortet genom metalldetektorn?'
    [
        'Har du tagit en närmare titt på ID-kortet? ',
        'Har du hittat det igen efter att det konfiskerades? ',
        'Om inte, vart tror du att den andra säkerhetsvakten kan ha gått med det?',
        'Kan det ha lämnats någonstans för att ägaren skulle hämta det? ',
        'Kan det vara därför det lämnades där från början? ',
        'Vad kan magnetremsan på kortet göra med metalldetektorn? ',
        'Hur noga har du undersökt metalldetektorn? ',
        'Vad antyder strömkabeln som leder till metalldetektorn? ',
        powerHint
    ]

    openWhenRevealed = 'card-confiscated'
    closeWhenAchieved = powerAchievement
;

++ powerHint: Hint 
    'Kan det finnas något sätt att stänga av strömmen till metalldetektorn? '
    [powerGoal]
;

+ powerGoal: Goal 'Hur stänger jag av strömmen till metalldetektorn?'
    [
        'I vilken riktning leder strömkabeln? ',
        'Vad mer finns i ungefär den riktningen? ',
        'Vad är det som ligger bortom metalldetektorn? ',
        'Varifrån kan strömmen styras? ',
        maintenanceHint
    ]
    closeWhenAchieved = powerAchievement
;
++ maintenanceHint: Hint
    'Vad kan underhållsrummet vara till för? '
    [maintenanceGoal]
;



+ maintenanceGoal: Goal 'Hur öppnar jag dörren till underhållsrummet?'
    [
        'Vad hindrar dörren från att öppnas? ',
        'Vem kan ha nyckeln till den? ',
        'Vilka platser kan en sådan person besöka i sitt arbete? ',
        'Var kan han städa? ',
        'Var kan du hitta ett badrum eller en toalett? ',
        'Kan det finnas något sådant ombord på planet? '
    ]
    openWhenRevealed = 'maintenance-door-locked'
    closeWhenSeen = maintenanceRoom
;

+ Goal 'Var hittar jag strömbrytaren till metalldetektorn?'
    [
        'I vilket rum kan du förvänta dig att hitta den?',
        'Vad kan du se i det rummet?',
        'Du tittar i underhållsrummet, eller hur?',
        'Vad kan finnas i de där skåpen?',
        'Var skulle någon gömma skåpnyckeln?',
        'Vad finns ovanpå det kortare skåpet?',
        'Vad kan finnas under krukväxten?',
        'Vad finns inuti det kortare skåpet?'
    ]    
    openWhenTrue = maintenanceRoom.seen && gRevealed('card-confiscated') 
    && (powerCable.examined || powerGoal.goalState == OpenGoal)
    
    closeWhenAchieved = powerAchievement
;


//CustomMessages
//    messages = [
//       Msg(currently no hints, 'You\'re too soon for hints! ')
//    ]    
//;

#ifdef __DEBUG    
foo: Test 'foo' ['x me', 'i']
    
;

bar: Test
    testName = 'bar'
    testList =
    [
        'titta',
        'lyssna'
    ]
;

allTest: Test
    testName = 'allt'
    testList =
    [
        'test foo',
        'test bar'
    ]
; 

Test 'uniform' ['bär uniform'] [uniform] @gate1;
#endif


//VerbRule(Order)     
//    ('order'  ('a' | 'an' | 'the' | 'some' |) literalDobj)
//   : VerbProduction
//   verbPhrase = 'order/ordering (what)'
//   action = Order
//   missingQ = 'what do you want to order'
//;
//
//VerbRule(OrderThing) 'orderthing' singleDobj : VerbProduction
//   verbPhrase = 'order/ordering (what)'
//   action = OrderThing
//   missingQ = 'what do you want to order'
//;
//
////DefineLiteralAction(Order)
////    execAction(cmd) {
////
////        switch(gLiteral.toLower) {
////        case 'food':
////        case 'some food':
////            "I wasn't hungry, but I was in the mood for a drink. ";
////            break;
////        case 'drink':
////        case 'a drink':
////            if (!client.arrives)
////                "I was originally going to help myself to a Mr. Pibb, but you
////                know what? Let's party; I got myself a Pibb Extra. ";
////            else
////                "I only needed one drink. ";
////            break;
////        default:
////            
////            Parser.parse('orderthing ' + gLiteral.toLower);
////            break;
////      }
////   }
////;
//
//DefineTAction(OrderThing)
//   includeInUndo = nil
//   actionTime = 0
//;
//
//modify Thing
//   dobjFor(OrderThing) 
//        { verify() { illogical('{I} {aren\'t} sure how to do that. '); } }
// 
//;
//

//VerbRule(Order)
//    'order' topicDobj
//    : VerbProduction
//    action = Order
//    verbPhrase = 'order/ordering (what)'
//    missingQ = 'What do you want to order'
//;
//
//DefineTopicAction(Order)
//    execAction(cmd)
//    {
//        local topic; 
//        
//        if(cmd.dobj.ofKind(ResolvedTopic))
//            topic = cmd.dobj.topicList[1];
//        else
//            topic = cmd.dobj;
//        
//        switch(topic)
//        {
//        case tFood:
//             "I wasn't hungry, but I was in the mood for a drink. ";
//            break;
//            
//        case tDrink:
//            if (!client.arrives)
//                "I was originally going to help myself to a Mr. Pibb, but you
//                know what? Let's party; I got myself a Pibb Extra. ";
//            else
//                "I only needed one drink. ";
//            break;
//            
//        default:
//            if(Q.scopeList(gActor).toList().indexOf(topic) == nil)
//                "{I} {see} no <<topic.name>> here. ";
//            else
//                "{I} {aren\'t} sure how to do that. ";
//                
//            
//        }
//    }
//;
//
//tDrink: Topic 'drink';
//tFood: Topic 'food; some';
//                  
//    
//    
//    
//client: object arrives = nil;