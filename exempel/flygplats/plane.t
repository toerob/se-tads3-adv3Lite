#charset "utf-8"

#include <tads.h>
#include "advlite.h"

planeRegion: Region
//    travelerLeaving(traveler, dest) { "You're about to leave the plane. "; }
//    travelerEntering(traveler, dest) 
//    { 
//        "You're about to enter the plane. ";
//        new Fuse(self, &edesc, 0);
//    }
//    edesc = "You've just boarded the plane. "
;

cockpit: Room 'Cockpit' 'cockpit'
    "Cockpiten är ganska liten men har allt man kan förvänta sig: en 
    vindruta som tittar framåt, en pilotstol från vilken man kan manövrera
    alla de vanliga reglagen och en dörr som leder ut akterut."

    aft = cabinDoor
    south asExit(aft)
    out asExit(aft)
    
    regions = [planeRegion]
    
    travelerEntering(traveler, dest) 
    {
        if(traveler == gPlayerChar)
            cockpitAchievement.awardPointsOnce();
    }
;

+ cabinDoor: LockablePlaneDoor 'hytt|dörr+en;;kabindörr+en'
    otherSide = cockpitDoor
;

+ pilotSeat: Fixture, Platform 'pilot|säte+t;;pilot|stol+en'
        
    dobjFor(Enter) asDobjFor(Board)
    
    allowReachOut(obj)
    {
        return obj.isOrIsIn(controls);
    }
;

+ controls: Fixture 'reglage+n;; kontroller+na;dem'
    "De instrument och reglage som är mest intressanta för dig är 
    <<makeListStr(contents, &theName)>>. "
    
    checkReach(actor)
    {
        if(!actor.isIn(pilotSeat))
            "Du behöver sitta i pilotsätet innan du kan använda reglagen. ";
    }
;

++ controlColumn: Fixture 'styr|spak+en;;spak|stång+en'
    "Det är i princip en spak som kan skjutas framåt eller dras bakåt, med ett hjul fäst högst upp. Den är för närvarande <<positionDesc>>."
    listOrder = 10
    
    position = 0
    
    positionDesc = ['helt tillbakadragen', 'vertikal', 
        'framskjuten hela vägen'][position + 2]
    
    dobjFor(Push)
    {
        check()
        {
            if(position > 0)
                "Den är redan framskjuten så långt det går att få den. ";
        }
        
        action()
        {
            position++;
            "Du trycker fram styrspaken så att den nu är <<positionDesc>>. ";
        }
    }
    
    dobjFor(Pull)
    {
        check()
        {
            if(position < 0)
                "Den är redan så långt tillbakadragen som det går att få den. ";
        }
        
        action()
        {
            position--;
            "Du drar bak styrspaken så att den nu är <<positionDesc>>. ";
        }
    }
;

+++ wheel: Fixture 'ratt+en'
    "Ratten kan vridas åt babord eller styrbord för att styra flygplanet. 
    Den är för närvarande <<angleDesc>>."
    
    isTurnable = true
    angle = 0
    
    angleDesc()
    {
        switch(angle)
        {
        case -60:
            "svår att styra mer babords";
            break;
        case -30:
            "något åt babords";
            break;
        case 0:
            "midskepps";
            break;
        case 30:
            "lite åt styrbords";
            break;
        case 60:
            "svår att styra mer styrbords";
            break;
        }
    }
    
    dobjFor(TurnRight)
    {
        check()
        {
            if(angle >= 60)
                "Den är redan vriden så långt styrbords som det går att få den. ";
        }
        
        action()
        {
            angle += 30;
            "Du vrider hjulet 30 grader styrbords så den blir <<angleDesc>>. ";
        }
    }
    
    dobjFor(TurnLeft)
    {
        check()
        {
            if(angle <= -60)
                "Den är redan vriden så långt babords som det går att få den. ";            
        }
        
        action()
        {
            angle -= 30;
            "Du vrider hjulet 30 grader babords så den blir <<angleDesc>>. ";
        }
    }
    
    dobjFor(Push)
    {
        remap = controlColumn
    }
    
    dobjFor(Pull)
    {
        remap = controlColumn
    }
;

++ thrustLever: Settable, Lever 'drivkrafts|spak+en;drivkraft;tryckspak+en kraftspak+en'
    "Det är en spak som tryckas framåt eller dras bakåt. Den är för närvarande <<settingDesc>>. "
    listOrder = 20
    
    settingDesc()
    {
        switch(curSetting)
        {
        case '0':
            return 'tillbakadragen hela vägen till 0';
        case '5':
            return 'framskjuten hela vägen till 5';
        default:
            return 'i position <<curSetting>> ';
        }
    }
    
    curSetting = '0'
    minSetting = 0
    maxSetting = 5
    
    isValidSetting(val)
    {
        return delegated NumberedDial(val);
    }
    
    makeSetting(val)
    {
        local oldVal = curSetting;
        inherited(val);
        "Du <<if oldVal < val>> trycker drivkraftsspaken framåt<<else>> drar 
        drivkraftsspaken bakåt<<end>> till <<curSetting>>. ";
        
        if(ignitionButton.isOn)
        {
            "Motorns vinande <<if oldVal < val>>ökar <<else>>
            minskar<<end>> i tonhöjd och volym<<if val=='0'>> och dör ut till en
            knappt hörbar viskning<<end>>. ";
        }
        
    }
    
    makePulled(stat)
    {        
        makeSetting(stat ? '0' : '5');
    }
    
    isPulled = (curSetting == '0')
    isPushed = (curSetting == '5')
;

++ ignitionButton: Button '() motorns tändnings|knapp+en; stor+a grön+a'
    "Det är en stor grön knapp. "
    listOrder = 30
    isOn = nil
    
    makePushed()
    {
        if(isOn)
            "Motorerna är redan igång. ";
        else
        {
            isOn = true;
            "Flygplanet skakar till när motorerna dånar till liv. ";
        }
    }
;



++ asi: Fixture 'luft|hastighets|indikator+n; lufthastighet+en; siffror+na asi+n'
    "Den mäter för närvarande en flyghastighet på <<lufthastighet>> knop. 
    De flesta siffrorna runt urtavlan är markerade med vitt, men 115 knop är 
    markerat med grönt. "
    listOrder = 40
    
    airspeed = 0
;

++ altimeter: Fixture 'höjdmätare+n'
    "Den indikerar för närvarande en altitud av <<altitude>> fot. "
    listOrder = 50
    
    altitude = 0
;

++ fuelGauge: Fixture 'bränsle|mätare+n'
    "Den mäter för närvarande full tank. "
    listOrder = 60
;

+ windscreen: Fixture 'vind|ruta+n;; fönst:er+ret'
    desc()
    {
        if(takeoff.isHappening)
            takeoffDesc();
        else
            "Ljuset börjar blekna utanför, men du kan lätt urskilja 
            terminalen på babords sida och sista minuten-jäkten av 
            förberedelser runt ditt flygplan. ";

            // "The light is starting to fade outside, but you can easily makeout
            // the terminal off to the port side and the last-minute bustle of
            // preparations around your plane. ";            
    }
    
    takeoffDesc()
    {
        local dt = takeoff.distanceTraveled/5;
        
        "Det är ganska mörkt ute nu, men du kan se landningsljusen som markerar
        landningsbanans bana <<if asi.airspeed == 0>>stationerade på vardera 
        sida <<else if asi.airspeed < 30>> röra sig långsamt förbi <<else>> rusa 
        förbi<<end>>. 
        <<if dt < 10>> Nästan hela banans längd sträcker ut sig framför dig
        <<else if dt < 33>> Större delen av banan ligger fortfarande framför dig
        << else if dt < 67>> Såvitt du kan bedöma ligger bara ungefär hälften av 
        banan fortfarande framför dig
        <<else if dt < 85>> Banan börjar att ta slut
        <<else>> Du är nästan framme vid slutet på banan<<end>>.";
    }
    
    
    dobjFor(LookThrough) asDobjFor(Examine)
;

+ terminalBuilding: Distant 'terminal+byggnad+en; sjaskig+a vit+a stor+a; struktur+en'
    "Det är en stor vit byggnad precis åt babord. I det avtagande ljuset kan man inte 
    riktigt se hur sjaskig den egentligen ser ut. "
;

landingLights: Distant 'landnings|ljus+en; röd+a grön+a;;dem'
    "De röda ljusen är åt babord och de gröna åt styrbord. "
;

takeoff: Scene
    startsWhen = (ignitionButton.isOn == true)
    
    whenStarting()
    {
        "Några ögonblick senare bogserar en lastbil bort ditt plan från 
        landningsbanan, och efter instruktioner från kontrolltornet rullar 
        du planet till början av landningsbana 2 precis när solen äntligen 
        försvinner under horisonten. Ungefär en minut senare; får du en ny 
        startklarering. ";

        /* reset all controls to their initial positions */
        thrustLever.curSetting = '0';
        wheel.angle = 0;
        controlColumn.position = 0;
        
        /* close off the exit from the plane */
        
        planeFront.port = 'Du kan inte lämna planet nu när det har lämnat passagerarbryggan. ';
        
        landingLights.moveInto(cockpit);
        terminalBuilding.moveInto(nil);
    }
    
    /* The total distance traveled along the runway */
    distanceTraveled = 0
    
    eachTurn()
    {
        local oldSpeed = asi.airspeed;
        
        if(controlColumn.position < 0)
        {
            if(asi.airspeed >= 115)
            {
                // "The aircraft leaves the ground and continues up into the sky,
                // climbing rapidly above the city. Once you've gained enough
                // height you turn the plane --- not south towards Bogota but north
                // towards Miami. Hopefully those hoodlums back in passenger cabin
                // won't notice, though, at least, not until it's far too late. You
                // reach for the radio to call ahead and arrange a suitable
                // reception committee, and then settle back in your seat, content
                // with a job well done. ";

                "Flygplanet lämnar marken och fortsätter upp i luften, och stiger 
                snabbt upp ovan staden. När du väl har nått tillräckligt med höjd 
                svänger du planet --- inte söderut mot Bogotá utan norrut mot Miami. 
                Förhoppningsvis märker inte de där ligisterna i passagerarkabinen 
                det, åtminstone inte förrän det är alldeles för sent. Du sträcker 
                dig efter radion för att anropa i förväg och ordna med en lämplig 
                mottagningskommitté, och lutar dig sedan tillbaka i din stol, 
                nöjd med ett väl utfört jobb. ";
                
                flyingAchievement.awardPointsOnce();
                
                finishGameMsg(ftVictory, [finishOptionUndo, finishOptionFullScore]);
            }
            else if(asi.airspeed > 90)
            {
                "Flygplanet lämnar marken ett ögonblick och stannar sedan, tappar 
                snabbt fart och stöter tillbaka ner på banan. ";

                
                asi.airspeed -= 30;
            }
            else
                "Flygplanet skakar lite men inget annat händer; det flyger inte alls 
                tillräckligt snabbt för att lyfta. ";
        }
        
        local thrust = toInteger(thrustLever.curSetting) * 400 - asi.airspeed;
        
        asi.airspeed += (thrust/100);
        
        if(asi.airspeed < 0)
            asi.airspeed = 0;
        
        distanceTraveled += ((asi.airspeed + oldSpeed)/2);        
       
        
        /* The following commented-out lines were for testing purposes only */
//         "The aircraft has covered <<distanceTraveled>>m and is now travelling at
//        <<asi.airspeed>> knots. ";   
        
        
        /* If we go too far, we run off the end of the runway */
        if(distanceTraveled > 500)
        {
            /*"The plane reaches the end of the runway, ploughs through the fences
            and crashes into some buildings. What happens after that you never
            know, but it seems a terribly destructive way to displose of a
            plane-load of hoodlums. ";*/
            "Planet når slutet av landningsbanan, plöjer igenom stängslen och 
            kraschar in i några byggnader. Vad som händer efter detta vet man 
            aldrig, men det verkar vara ett fruktansvärt destruktivt sätt att 
            göra sig av med en flygplanslast med ligister. ";
            
            finishGameMsg(ftDeath, [finishOptionUndo, finishOptionFullScore]);
        }
            
        
        /* 
         *   If we turn the wheel while the plane is moving along the runway,
         *   the results are likely to be catastrophic.
         */        
        
        if(wheel.angle != 0 && asi.airspeed > 0)
        {
            /*"The plane lurches off the <<if wheel.angle < 0>> port <<else>>
            starboard<<end>> side of the runway <<one of>>into the path of a
            taxying airliner <<or>> and smashes into a hangar <<or>> and
            collides with a stationary airliner <<or>> and runs into a group of
            sheds <<purely at random>> with predictably disastrous consequences.
            Fortunately, you won't be around to answer for your incompetence. ";*/
            
            "Flygplanet kränger av <<if wheel.angle < 0>> babord <<else>>
            styrbordssidan <<end>> av banan <<one of>> in i banan för ett taxande 
            flygplan <<or>> och krockar med en hangar <<or>> och kolliderar 
            med ett stillastående flygplan <<eller>> och kör in i en grupp skjul 
            <<purely at random>>> med förutsägbara katastrofala konsekvenser.
            Som tur är kommer du inte hänga kvar för att stå till svars för 
            din inkompetens. ";
            finishGameMsg(ftDeath, [finishOptionUndo, finishOptionFullScore]);
        }
        
        /* 
         *   If nothing else dramatic has intervened, report what's happening to
         *   the speed.
         */
        
        if(asi.airspeed > oldSpeed && oldSpeed == 0)
            "The plane starts moving forward. ";
        else if (asi.airspeed > oldSpeed)
            "The plane continues to pick up speed. ";
        
        if(asi.airspeed < oldSpeed && asi.airspeed == 0)
            "The plane comes to a halt. ";
        else if(asi.airspeed < oldSpeed)
            "The plane is losing speed. ";
    }   
;


//Front of Plane' 'framsidan[n] av planet;;flygplan flygplan'
planeFront: Room 'Framsidan av Planet' '() framsida+n[n] av plan+et;;flyg|plan+et flyg+et'
    "Huvudgången slutar vid babords utgång på planet, men fortsätter akterut 
    förbi sätet. Lite längre fram finns en dörr som <<unless gPlayerChar
    .hasSeen(cockpit)>>förmodligen<<end>> leder in i cockpiten."

    fore = cockpitDoor
    north asExit(fore)
    port = jetway
    west asExit(port)
    out asExit(port)
    aft = planeRear
    south asExit(aft)
    
    regions = [planeRegion]
;

+ cockpitDoor: PlaneDoor 'cockpit|dörr+en'
    otherSide = cabinDoor
;


planeRear: Room 'Baksidan av planet' '() baksida+n[n] av plan+et;;flyg|plan+et flyg+et'
    "Huvudgången fortsätter framåt till planets främre del och akterut till 
    toaletten mellan raderna av rödfärgade säten."
    fore: TravelConnector
    {
        destination = planeFront
        canTravelerPass(traveler)
        {
            return !takeover.isHappening || cleanerItemCount(traveler) > 3;
        }
        
        explainTravelBarrier(traveler)
        {       
            "Du tar ett steg framåt mot planets främre del, men ";
            
            switch(cleanerItemCount(traveler))
            {                
            case 0:
            case 1:
                "Du tar ett steg framåt mot planets främre del, men när du gör 
                det får du syn på Pablo Cortez, en av El Diablos mest 
                hänsynslösa hantlangare, som står nära utgången, så du tar ett 
                hastigt steg tillbaka in i passagerarvimlet innan han kan känna 
                igen dig, och undrar hur du ska kunna förklä dig själv. ";
                break;
            case 2:
                "du får syn på Pablo Cortez, El Diablos onde löjtnant, som står 
                vid utgången och ser alltmer otålig ut över passagerarnas 
                oorganiserade avfärd. Du backar hastigt, inte alls säker på att 
                han kommer att missta dig för en städare. ";
                break;
            case 3:
                "i det ögonblicket tittar Pablo Cortez, El Diablos särskilt 
                otrevliga högra hand, bakåt från planets framsida, som om han 
                försöker placera dig. Du kans inte bär på tillräckligt mycket 
                för att misstas för en städare, så du tar ett hastigt steg 
                tillbaka. ";

                break;
                
            }
        }
        
        travelDesc = "<<if takeover.isHappening>>Du greppar tag i hinken och 
        sopsäcken på ett sådant sätt att du gömmer dig så mycket som möjligt, 
        och tränger dig fram mellan passagerarna som rör sig i gången, i hopp 
        om att undvika Pablo Cortez blick. Om han fångar dig kommer du att 
        vara död innan du hinner säga <q>begravningskostnader</q>! 
        <<else>>Du ignorerar passagerarna som sitter på vardera sidan av 
        gången och återvänder till planets främre del. <<end>>"
        
        cleanerItemCount(traveler)
        {
            return traveler.allContents.countWhich(
                { o: o is in (bucket, sponge, garbageBag, brassKey) } );
                
        }
    }
    
    north asExit(fore)
    aft = bathroomDoor
    south asExit(aft)
    
    regions = [planeRegion]    
;

+ bathroomDoor: PlaneDoor 'toalett|dörr+en; toa+n lavatory'
    otherSide = bathroomDoorInside
;

MultiLoc, Decoration 'flyplans|säten+a; röd+a; 
                      flyg|stolar+ar flyg|stol+en sitt|platser+na[pl] sitt|plats+en säten[pl] säte+t; dem'
    "Liksom alla flygstolar ser dessa ut som om de var designade för hur mycket 
    en genomsnittlig person vägde för ett och ett halvt sekel sedan."
    
    notImportantMsg = '<<if takeover.isHappening>>Du kan inte komma åt sätena på
    grund av trängseln av passagerare i gången<<else>>Alla platser här runt omkring
     verkar vara upptagna, så det är bäst att du lämnar dem ifred.<<end>>. '
    
    locationList = [planeFront, planeRear]
;

airlinePassengers: MultiLoc, Decoration 'passagerar:e+na;;män+nen[pl] kvinnor+na[pl]; dem'
    "<<if takeover.isHappening>>De verkar lika förvirrade som de är irriterade
    <<else>>Du känner en otålighet omkring dem, som om de alla undrar när 
    flygplanet äntligen ska lyfta<<end>>. "
    
    notImportantMsg = 'Bäst att låta bli dem; du vill inte dra på dig onödig
        uppmärksamhet. ' 
    
    locationList = [planeFront, planeRear]
    
    specialDesc = "Gången är full av passagerare som försöker lämna sina säten,
        plocka ner sitt bagage, och bege sig mot planets <<if me.isIn(planeRear)>>
        framsida <<else>>utgången<<end>>. "
    
    useSpecialDesc = (takeover.isHappening)  
    
;



bathroom: Room 'Toaletten' 'toalett+en;;toa+n lavatory wc bås+et'
    "Toaletten är bara ett litet bås med alla de typiska beslag du kan förvänta dig. "
    
    fore = bathroomDoorInside
    north asExit(fore)
    out asExit(fore)    
    
    regions = [planeRegion] 
;

+ bathroomDoorInside: LockablePlaneDoor 'hytt|dörr+en;;kabin|dörr+en'
    otherSide = bathroomDoor
;

+ Decoration 'beslag+en; 
              tvätt; 
              tvätt|ställ+et blandar+na blandare+n kranar+na kran+en skål+en; 
              washbasin basin taps; dem'
    
    "Handfatet och toalettstolen ser åtminstone någorlunda rena ut. "
    
    notImportantMsg = 'Du behöver inte använda någon av dessa faciliteter just nu. '
;

+ bucket: Container 'gul+a plast|hink+en; vanlig+a plastig+a; spann+et'
    "Det är bara en vanlig gul plasthink. "
    initSpecialDesc = "Någon städare verkar ha lämnat alla sina saker här:
        <<list of location.listableContents.subset({x: x.moved == nil})>>. "
    
    bulk = 6
    bulkCapacity = 6
    
;

+ sponge: Thing 'tvätt|svamp+en;turkos+a'
    "det är en slags turkos färg. "
    
    bulk = 3
;

+ garbageBag: Container 'sop|säck+en; stor+a grön+a plast|avfall+et; påse'
    "Det är i princip bara en stor grön plastpåse. "
    
    bulk = (2 + getBulkWithin)    
    bulkCapacity = 10
;

+ brassKey: Key 'li:ten+lla mässing|nyckel+n; yale;yale-|dubb+nyckel+n'
    "Den ser ut precis som vilken \"yale\"-dubbnyckel du har sett förut. "
    
    actualLockList = [maintenanceRoomDoor, mrDoorOut]
    plausibleLockList = [maintenanceRoomDoor, mrDoorOut]
    
    bulk = 1
;

Doer 'gå dir'
    execAction(c)
    {
        "Ombordsanvisningar har inte så stor betydelse här. ";
        abort;
    }
    
    direction = [portDir, starboardDir, foreDir, aftDir]
    when = (!gPlayerChar.isIn(planeRegion))
;


class PlaneDoor: Door 
    desc = "Den {är} <<if isOpen>>öppen<<else>>stängd<<end>>. "
    lockability = indirectLockable
    indirectLockableMsg = 'Det ser ut som denna dörr bara kan 
                           låsas och låsas upp från andra sidan'
    isLocked = nil
;

class LockablePlaneDoor: Door
    desc = "Den är för närvarande <<if isOpen>>öppen<<else>>stängd och <<if isLocked>>
        låst<<else>>olåst<<end>><<end>>. "
    lockability = lockableWithoutKey
    isLocked = nil
;

takeover: Scene
    startsWhen = (bathroom.visited)
    
    whenStarting()
    {
        "Ett meddelande hörs via intercom: <q>På grund av problem med 
        tidtabellen ombeds passagerare vänligen att gå av flygplanet och 
        återvända till flygplatsloungen. Kom ihåg att ta med alla dina 
        personliga tillhörigheter.</q>\b Meddelandet möts omedelbart av en 
        klagokör av stönanden från kabinen. ";
        
        announcementObj.stopDaemon();
        disembarkingPassengers.moveInto(jetway);
        darkSuits.moveInto(nil);
    }
    
    endsWhen = (uniform.wornBy == gPlayerChar)
    
    whenEnding()
    {
        disembarkingPassengers.moveInto(nil);
        airlinePassengers.moveInto(nil);
        criminalPassengers.moveInto(planeFront);
    }
;

criminalPassengers: Decoration 'passagera:re+rna; elegant+a mörk+a av[prep]; män+nen gangster+s
    kostym+er löjtnanter+na gäng+et folk+et; dem'
    "De må alla vara klädda i eleganta mörka kostymer, men du är väl medveten 
    om att de inte är mycket mer än ett gäng gangsters, högre löjtnanter till 
    män som El Diablo som skulle skar halsen av sina egna mormödrar för ett 
    par pesos. "

    notImportantMsg = 'Du vill verkligen inte göra något som kan få någon av 
    de där människorna att lägga märke till dig.'
    
    beforeTravel(traveler, connector)
    {
        if(traveler == gPlayerChar && connector == planeRear)
        {
            "Du vill verkligen inte dra till dig uppmärksamhet genom att gå 
            förbi passagerarna längst bak i planet, eftersom även den mest 
            enkla gangstern kommer att tycka att det är konstigt om piloten 
            går någon annanstans än in i cockpiten.";
            
            exit;
        }
    }
;


disembarkingPassengers: Decoration 'missnöjda passagera:re+na; 
                                    avstigande trängande muttrande+t från[prep]; 
                                    män+nen kvinnor+na trängsel+n människor+na ström+en folkmassa+n;
                                    dem'
    "Några av passagerarna som tvingades gå av planet står bara där och muttrar,
    några andra är på väg tillbaka in i terminalen, 
    medan andra fortsätter att komma ut ur planet."
    
    notImportantMsg = 'Du har inte tid för de här människorna just nu. '
;

Doer 'släpp Thing'
    execAction(c)
    {
        "Det är bäst att inte börja sätta ner saker här; det kanske får Cortez
        att lägga märke till dig. ";
        exit;
    }
    
    where = planeFront
    during = takeover
;

VerbRule(PushForward)
    'tryck' multiDobj 'framåt'
    | 'tryck' 'framåt' 'på' multiDobj
    : VerbProduction
    action = Push
    verbPhrase = 'trycka/trycker framåt (vad)'
    missingQ = 'vad vill du trycka framåt'
//    dobjReply = singleNoun
//    priority = 60

;

modify VerbRule(Pull)
    ( ('dra'|'drag') multiDobj ( | 'bak'|'bakåt')) 
    | ('dra'|'drag') ('bakåt'|'bakåt') 'på' multiDobj    
    : 
;

DefineTAction(TurnLeft)
;

DefineTAction(TurnRight)
;

VerbRule(TurnLeft)
    'vrid' singleDobj (| 'till' ) ('vänster' | 'babord')
    : VerbProduction
    action = TurnLeft
    verbPhrase = 'vrida/vrider (vad) vänster'
    missinqQ = 'vad vill du vrida till vänster'
    priority = 60
;

VerbRule(TurnRight)
    'vrid' singleDobj (| 'till' ) ('höger' | 'styrbord')
    : VerbProduction
    action = TurnRight
    verbPhrase = 'vrida/vrider (vad) höger'
    missinqQ = 'vad vill du vrida till höger'
    priority = 60
;

modify Thing
    dobjFor(TurnLeft)
    {
        preCond = [touchObj]
        
        verify()
        {
            if(!isTurnable)
                illogical(cannotTurnMsg);
        }
                
        report()
        {
            "Att vrida <<gActionListStr>> till vänster ger inget. ";
        }
        
    }
    
    dobjFor(TurnRight)
    {
        preCond = [touchObj]
        
        verify()
        {
            if(!isTurnable)
                illogical(cannotTurnMsg);
        }
        
        report()
        {
            "Att vrida <<gActionListStr>> till höger ger inget. ";
        }
        
    }
;

modify VerbRule(SetTo)
    ('sätt' | 'flytta' | 'tryck' | 'dra') singleDobj 'till' literalIobj
    :
;