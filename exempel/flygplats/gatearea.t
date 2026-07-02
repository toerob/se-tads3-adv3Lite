#charset "utf-8"

#include <tads.h>
#include "advlite.h"

gateArea: Room 'Gateområde' 'gateområdet'
    "Vägarna till gate 1, 2 och 3 är skyltade mot nordväst, norr respektive nordost,
    medan en skylt monterad högt uppe på väggen visar vilka flyg som bordas och 
    avgår var och när. Omedelbart österut finns en metalldörr, medan 
    huvudsamlingshallen ligger söderut."
    
    south = concourse
    northwest = gate1
    north = gate2
    northeast = gate3
    east = maintenanceRoomDoor
;


+ maintenanceRoomDoor: Door 'metall|dörr+en'
    "Den är märkt <q>Personal de Mantenimiento S&oacute;lo</q>, och <<if isOpen>>
    är för närvarande öppen<<else>> ser ut att vara ordentligt stängd<<end>>."
    
    otherSide = mrDoorOut
    lockability = lockableWithKey
    isLocked = true
    
    lockedMsg = (inherited + '<.reveal maintenance-door-locked>')
;


+ Distant 'display+en' //'display board'
    //"The display imparts the following information:\b
    "Displayen visar följande information:\b
    TI 179 till Buenos Aires <FONT COLOR=GREEN>BOARDING GATE 3</FONT>\n
    RO 359 till Mexico City <FONT COLOR=RED>FÖRSENAD</FONT>\n
    PZ 87 till Houston <FONT COLOR=RED>FÖRSENAD</FONT>\n
    BU 4567 till Bogota <FONT COLOR=RED>FÖRSENAD</FONT>"
 
    decorationActions = [Examine, GoTo, Read]
    readDesc = desc
;


maintenanceRoom: Room 'Underhållsrum' 'underhållsrummet'
    "<<one of>>När du kommer in i rummet lägger du omedelbart märke till<<or>>Detta är ett 
    litet, fyrkantigt rum med<<stopping>> ett par stålskåp monterade mot ena väggen, det ena
    mycket högre än det andra. Den enda vägen ut är genom en dörr mot väster. "

    eng = "<<one of>>On entering the room you immediately notice<<or>>This is a small
    square room with<<stopping>> a pair of steel cabinets mounted against one
    wall, one much taller than the other. The only way out is through a door to
    the west. "
    west = mrDoorOut
    out asExit(west)
;

+ mrDoorOut: Door 'metall|dörr+en; vanlig+a'
    "Det är bara en vanlig metalldörr, för närvarande <<if isOpen>> öppen<<else>>
    stängd<<end>>. "
    
    otherSide = maintenanceRoomDoor    
    lockability = lockableWithKey
    isLocked = true
;

+ tallCabinet: OpenableContainer, Fixture 'hög+a metall|kabinett+en; två meter målad+e institutions|grön+a'
    "Den är hela två meter hög och målad i en institutionsgrön färg."
    
    bulkCapacity = 20
;

+ shortCabinet: Fixture 'låg+a metall|kabinett+en; lätt+a låg+a ljus|grå+a'
    "Den är ungefär en meter hög och målad i ljusgrått. "
    remapIn: SubComponent 
    {
        isOpenable = true
        lockability = lockableWithKey
        isLocked = true
        bulkCapacity = 5        
    }
    
    remapOn: SubComponent { bulkCapacity = 10 }
    
;

//++ powerSwitch: Fixture, Switch 'big red switch{-zz}' // TODO: vad gjorde -zz?
++ powerSwitch: Fixture, Switch 'stor+a röd+a ström|brytare+en'
    "Den är märkt <q>Metalldetektor</q> och är för närvarande i 
    <<if isOn>>PÅ<<else>>AV<<end>>-position. "

    isOn = true
    subLocation = &remapIn
    
    makeOn(stat)
    {
        inherited(stat);
        if(stat == nil)
            powerAchievement.awardPointsOnce();
    }
;

++ Decoration 'strömbrytar:e+na[pl]; de andra av[prep]; uppsättning+en rad+er rad+en; dem'
    "Det finns fyra rader med strömbrytare i en mängd olika färger, men din 
    uppmärksamhet dras snabbt till den stora röda märkta <q>Metalldetektor</q>."

    notImportantMsg = 'Det är bara den stora röda strömbrytaren som är av något 
    intresse för dig; du vill inte riskera att dra till dig uppmärksamhet genom att 
    mixtra med någon av de andra.'
    
    subLocation = &remapIn
    specialDesc = "En uppsättning brytare är monterade på baksidan av skåpet. "
;

    
++ potPlant: Thing 'krukväxt+en; li:ten:lla; kaktus+en'
    "Det ser ut som en liten kaktus. "
    
    maxBulkHiddenUnder = 1
    hiddenUnder = [silverKey]
    canPutUnderMe = (locType == On || location.ofKind(Room))
    
    subLocation = &remapOn
    
    cannotPutUnderMsg = '{Jag} {kan} inte stoppa något under krukväxten såvida den inte 
    står på någonting. '
;

silverKey: Key 'silver|nyckel+n; li:ten+lla'
    
    bulk = 1
    actualLockList = [shortCabinet]
    plausibleLockList = [shortCabinet]
;


gate1: Room 'Gate 1' 'gate[n] 1[adj]; ett första'
    "Misströstande passagerare sitter och väntar på ett flyg som aldrig verkar
    komma fram. Gaten västerut är stängd, så den enda vägen ut är tillbaka mot 
    sydost."
    
    southeast = gateArea    
;

+ Decoration 'misströstande passagerare;;;dem'    
;
 
+ Decoration 'säten+a;;;dem'
;    

gate2: Room 'Gate 2' 'gate[n] 2[adj]; två andra'
    "Det här området är helt öde, som om alla slutat förvänta sig att ett flyg 
    någonsin kommer att bordas här. Gaten mot norr ser ordentligt låst ut, så 
    den enda praktiska vägen härifrån verkar vara att gå tillbaka till söder. "

    south = gateArea
;

gate3: Room 'Gate 3' 'gate[n] 3[adj]; tre+dje '
    "Området är praktiskt taget öde, bortsett från en och annan försenad 
    passagerare som rusar iväg genom den öppna porten mot öster."
    
    southwest = gateArea
    east = openGate
;

+ Decoration 'säten+a; tom+ma övergiv:en+na otag:en+na oupptag:en+na ledig+a ledigt; sitt|platser+na; dem'
    "Alla platser vid denna avgångsgate är lediga, vilket tyder på att alla passagerare 
    för den aktuella flygningen redan har gått ombord på planet."    
;

+ openGate: Passage 'öpp:en+na gate+n; obevakad+e vid+a'
    "Gaten står vidöppen, och av någon anledning helt obevakad. Det verkar
    knappast som en hög säkerhetsnivå. "
    cannotOpenMsg = 'Den är redan öppen. '
    cannotCloseMsg = 'Det verkar knappast passande att göra. '
    
    destination = jetway
;

jetway: Room 'Passagerarbrygga' 'passagerar|brygga+n;kort+a inneslut:en+na; land|gång+en'
    "Detta är inte mycket mer än en kort, sluten gångväg som leder väst-öst från gaten 
    till planet. <<if takeover.isHappening>> Just nu kryllar det av en ström av missnöjda 
    passagerare som just har tvingats gå av sitt flyg. <<else unless takeover.hasHappened>>
    Du verkar vara den enda personen här, som om alla andra redan har gått ombord.<<end>>"

    west = gate3
    east: TravelConnector
    {
        destination = planeFront
        
        canTravelerPass(traveler) { return !takeover.isHappening; }
        explainTravelBarrier(traveler)
        {
            "Du vågar inte gå tillbaka ombord på planet förrän du har hittat en mer 
            effektiv förklädnad än en handfull rengöringsartiklar. ";
        }
    }
    
    travelerEntering(traveler, dest) 
    {
        if(traveler == gPlayerChar && takeover.isHappening)
            escapeAchievement.awardPointsOnce();
    }    
;

announcementObj: ShuffledEventList
    eventList =
    [
        '<<prefix>><q>Sista anropet för passagerare på Flight TI 179 till Buenos Aires; 
        detta flyg bordas nu vid Gate 3.</q> ', 
 
        '<<prefix>><q>Ultima llamada a pasajeros en Vuelo TI 179 a Buenos Aires;
        este vuelo se aloja ahora en la Puerta 3.</q> ',
        
        '<<prefix>><q>La derni&egrave;re demande des passagers sur le Vol TI 179
        &agrave; Buenos Aires; ce vol est maintenant boarding &agrave; la Porte
        3.</q> ',

        '<<prefix>><q>Chamada &uacute;ltima a passageiros em TI de V&ocirc;o
        179 a Buenos Aires; este v&ocirc;o est&acute; embarcando agora na Porta
        3.</q> ',

        '<<prefix>><q>Passagerare Quixote, vänligen infinn dig vid flygplatsens informationsdisk.</q> ',

        '<<prefix>><q>Detta är ett säkerhetsmeddelande. Allt obevakat bagage kommer att tas bort och 
        auktioneras bort till förmån för flygplatsens säkerhetspersonals välgörenhetsfond.</q> '
    ]
    
    eventPercent = 67
    eventReduceTo = 33
    eventReduceAfter = static eventList.length
   
    
    start()
    {
        if(daemonID == nil)
            daemonID = new Daemon(self, &announce, 1);       
    }
    
    stopDaemon()
    {
        if(daemonID != nil)
        {
            daemonID.removeEvent();
            daemonID = nil;
        }
    }
    
    daemonID = nil
    
    announce()
    {
        if(!gPlayerChar.isIn(planeRegion))
           doScript();
    }
    
    prefix = 'Ett meddelande hörs via högtalarsystemet: '
;


