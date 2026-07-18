#charset "utf-8"

#include <tads.h>
#include "advlite.h"


/*   
 *   EXERCISE 19 - LOCKS AND GADGETS
 *
 *   A demonstration of Locks, Keys, Gadgets and Controls.
 *
 *   This is a complete game insofar as there is an objective and it's 
 *   possible to win, but it's not really complete in terms of implementing 
 *   everything that ought to be implemented in a real game. It's basically 
 *   a coding demonstration.
 *
 *   The main purpose of this demo is to illustrate the use of the various 
 *   Lockable, Key, gadget and control-type classes. It has, of course, been 
 *   necessary to include some objects from various other class-families as 
 *   well in order to make a coherent game, but in the main these have been 
 *   kept to a minimum.
 */


/*
 *   VERSION INFO
 *
 *   Our game credits and version information.  This object isn't required 
 *   by the system, but our GameInfo initialization above needs this for 
 *   some of its information.
 *
 *   You'll have to customize some of the text below, as marked: the name of 
 *   your game, your byline, and so on.
 */
versionInfo: GameID
    IFID = '49d00c5d-5706-4d5d-a55d-8a80fb003aa1'
    name = 'Övning 19 - Lock(s) och Gadget(s)'
    byline = 'av Eric Eve (Översatt av Tomas Öberg)'
    htmlByline = 'av <a href="mailto:eric.eve@hmc.ox.ac.uk">Eric Eve</a>'
    version = '1'
    authorEmail = 'Eric Eve <eric.eve@hmc.ox.ac.uk>'
    desc = 'Ett demo av adv3Lite Lock(s), Key(s), Gadget(s) och Control(s)'
    htmlDesc = 'Ett demo av adv3Lite Lock(s), Key(s), Gadget(s) och Control(s)'
;

/*
 *   GAME MAIN
 *
 *   The "gameMain" object lets us set the initial player character and 
 *   control the game's startup procedure.  Every game must define this 
 *   object.  For convenience, we inherit from the library's GameMainDef 
 *   class, which defines suitable defaults for most of this object's 
 *   required methods and properties.  
 */
gameMain: GameMainDef
    /* Define the initial player character; this is compulsory */
    initialPlayerChar = me
    
    showIntro()
    {
        /*"Baron Lothar von Erpresser is out; you know because you arranged for
        him to be sent an invitation to the reception at the Patagonian
        embassy, which he was unable to resist. His house will be empty for the
        next few hours, affording you the best opportunity to recover that
        unfortunate letter. You're not prepared to pay the price he's asking
        for it, and if he carries out his threat to send it to your betrothed
        your marriage prospects will be seriously compromised.\b
        You're pretty sure he's keeping the incriminating letter in a safe in
        his study. You're well equipped to recover it; all you need to do now
        is enter the house, recover the letter, and make a quick getaway. The
        baron has such a poor memory for numbers that you feel sure he'll have
        written down the combination somewhere. \b";
        */

        "Baron Lothar von Erpresser är inte hemma; du vet detta, eftersom du 
        ordnade så att han fick en inbjudan till mottagningen på Patagoniens 
        ambassad, vilket han inte kunde motstå. Hans hus kommer att stå tomt 
        under de närmaste timmarna, vilket ger dig det bästa tillfället att 
        återfå det känsliga brevet. Du är inte beredd att betala priset han 
        begär för det, och om han fullföljer sitt hot att skicka det till 
        din fästman kommer dina äktenskapsmöjligheter att äventyras
        allvarligt.\b
    
        Du är ganska säker på att han förvarar det avslöjande brevet i 
        ett kassaskåp i sitt arbetsrum. Du är väl utrustad för att återfå 
        det; allt du behöver göra nu är att gå in i huset, förskaffa dig 
        brevet och snabbt fly därifrån. Baronen har så dåligt minne för 
        siffror att du är säker på att han har skrivit ner kombinationen 
        någonstans.\b";
    }
;

/*  
 *   ENUMERATOR
 *
 *   We can define an enumerator with whatever names we like. Here we'll 
 *   define a couple of values to keep track of the nationality of the player
 *   (character).
 */

enum british, american;


/*   We'll modify Thing to give every portable object a default bulk of 1 */

modify Thing
    bulk = (isFixed ? 0 : 1)
;


/* 
 *   OUTDOOR ROOM
 *
 *   Starting location - we'll use this as the player character's initial 
 *   location.  The name of the starting location isn't important to the 
 *   library, but note that it has to match up with the initial location for 
 *   the player character, defined in the "me" object below.
 *
 *   Our definition defines two strings.  The first string, which must be in 
 *   single quotes, is the "name" of the room; the name is displayed on the 
 *   status line and each time the player enters the room.  The second 
 *   string, which must be in double quotes, is the "description" of the 
 *   room, which is a full description of the room.  This is displayed when 
 *   the player types "look around," when the player first enters the room, 
 *   and any time the player enters the room when playing in VERBOSE mode.
 *
 */
drive: Room 'Uppfart'
    "Langtree House, en vidsträckt edwardiansk herrgård, ligger framför dig 
    strax söderut, medan uppfarten norrut leder tillbaka ner till vägen. "
    south = frontDoorOutside
    in asExit(south)
    
    north: TravelConnector {        
        
        /* 
         *   We prevent the player character from leaving towards the road 
         *   until s/he is carrying the letter. When the player character 
         *   does leave for the road, we'll end the game.
         */
        canTravelerPass(traveler) { return letter.isIn(traveler); }
        explainTravelBarrier(traveler)
        {
            "Du går <i>inte</i> härifrån utan det där brevet!";            
        }
        
        /*  
         *   Once the PC travels via this connector, the game is won, so we 
         *   end the game in victory (i.e. display a YOU HAVE WON message 
         *   and end the game.
         */
        
        noteTraversal(traveler)
        {
            "När du går nerför uppfarten stoppar du in brevet säkert i din 
            rock. Baronen kommer inte tillbaka än på flera timmar; när han 
            väl upptäcker att brevet inte står att finna kommer det att ha 
            brunnit ner till aska i din eldstad. Och vad kan han göra då? 
            Anmäla stölden till polisen?\b
            Du skrockar glatt åt tanken när du går ut på vägen.\b";

            finishGameMsg(ftVictory, [finishOptionUndo, finishOptionAmusing]);
        }
    }
;

/* 
 *   The player character object. This doesn't have to be called me, but me is a
 *   convenient name. If you change it to something else, rememember to change
 *   gameMain.initialPlayerChar accordingly.
 */

+ me: Player 'you'   
    "Du är helt klädd i svart, så som det anstår en inbrottstjuv. "
    
    /*  
     *   A custom property that will be used later on. The possible values 
     *   are british and american.
     */
    nationality = british
;

/*  
 *   FLASHLIGHT
 *
 *   A Flashlight is both a gadget and a Light Source, being a special kind of 
 *   Switch.  
 *
 *   The ostensible purpose of this torch/flashlight is to allow the player 
 *   character to see in the darkened hall, and it is indeed the kind of 
 *   thing one might expect some intended burglary to be carrying. The real 
 *   purpose is to guess when the player is more comfortable with British or 
 *   American English. A British player will most likely call this device a 
 *   'grey torch' while an American will be more likely to refer to it is a 
 *   'gray flashlight'.
 */

++ torch: Flashlight 'plast|rör+et; plastig+a grå+a färglös+a; plast+en fick|lampa+n med[prep] knapp+en lykta+n' 
    "<<if name == 'plastic tube'>>Det är ett plaströr med en färg mitt 
    emellan svart och vitt, med en strömbrytare som kan slås på och av för 
    att producera ljus. <<else>>Det är en <<name>> av plast. "
       
    
    /*  
     *   The normal purpose of matchNameCommon() is to decide whether we 
     *   want to interfere with the parser's choice of this object as match 
     *   for what the player typed. We don't interfere with that here at 
     *   all; instead we take advantage of the fact that this routine is 
     *   called whenever the player refers to this object to see what words 
     *   the player used to refer to it.
     */
    
    matchNameCommon(tokens, phrases, excludes)
    {
        
        
        /* 
         *   Don't worry too much if the next statement looks like a piece of
         *   arcane mumbo-jumbo. The adjustedTokens parameter will contain a
         *   list that looks something like ['grey', &adjective, 'torch', 
         *   &noun]. What the following statement does is to ensure that all 
         *   the string values in the list are converted to lower case while 
         *   leaving the others untouched. This makes it easier to see 
         *   whether words like 'torch' or 'flashlight' occur in the list 
         *   without worrying whether the player typed them in upper or 
         *   lower case.
         */
        
        local lst = tokens.mapAll({x: dataType(x) == 
                                          TypeSString ? x.toLower() : x});
        
        /* 
         *   Test first to see if the player has used the word 'torch' or 
         *   'flashlight', and if so use that to determine the name of this 
         *   object (and the nationality of the player). Otherwise see if 
         *   'grey' or 'gray' has been used.
         */
        // Notera att detta inte gick att översätta alldeles enkelt, 
        // detta är bara en nödlösning för att bibehålla kodexemplet
        if(lst.indexOf('fackla') || lst.indexOf('lykta'))
            name = britishName;
        else if (lst.indexOf('lampa') || lst.indexOf('ficklampa')) 
            name = americanName;
        else if(lst.indexOf('grå'))
            name = britishName;
        else if(lst.indexOf('färglös'))
            name = americanName;
               
        /* 
         *   Now set the nationality of the player according to the name of 
         *   this object. Note that if the player refers to us a plastic 
         *   tube we can't make a decision on nationality and so we won't 
         *   change it.
         */
        
        if(name == britishName)
            me.nationality = british;
        if(name == americanName)
            me.nationality = american;
            
        return inherited(tokens, phrases, excludes);
    }
    britishName = 'grå lykta'
    americanName = 'färglös ficklampa'
;

/*  
 *   LOCKABLE CONTAINER
 *
 *   This is a basic LockableContainer; it has a lock but no key is needed to
 *   unlock it, and opening the case will perform an implicit unlock 
 *   action, so the lock performs virtually no function in practice. We'll 
 *   meet some more challenging lockable containers below.
 */

++ LockableContainer 'li:ten+lla svart+a fodral+et' 
    "Den är väldigt liten, inte så stor att den hindra dina rörelser, 
    endast stor nog för att rymma viktig utrustning för själva jobbet. "
    
    /* 
     *   We've described the case as very small, so let's make its 
     *   bulkCapacity match that.
     */
    bulkCapacity = 3
    bulk = 3
;

/*   
 *   KEY
 *
 *   As its name implies, this skeleton key will be able to open just about 
 *   any keyed lock in the game. This will be used to illustrate that one 
 *   key can open several locks, and that several keys can be defined as 
 *   opening the same lock.
 */

+++ skeletonKey: Key 'huvud|nyckel+n; tunn+a av[prep] metall+iska;metall|nyckel+n'
    "Det är en tunn metallnyckel, med listigt utformade tänder. "
    
    /* The skeleton key works in a number of locks. */
    actualLockList = [frontDoorOutside, frontDoorInside, whiteBox]
;


/*  
 *   ENTERABLE
 *
 *   We use an Enterable to represent the house and point its connector 
 *   property to the front door (so that ENTER HOUSE will attempt to take 
 *   the PC through the front door.
 */

+ Enterable 'hus+et; langträd edwardian+sk vidsträckt+a; herr|gård+en'     
    "Det ser lite dystert och skrämmande ut i skymningen, men mest av allt 
    ogillar man att det bebos av en man som tjänar sina pengar på ett så
    avskyvärt sätt. "
    
    connector = frontDoorOutside
;



/*
 *   A DOOR THAT CAN BE LOCKED WITH A KEY
 *
 *   A door is an obvious thing to lock and unlock with a key, and here we 
 *   provide a simple example. The description provides a hint for a 
 *   combination to be used just inside. Since the door describes itself as 
 *   hard to break, we provide a corresponding custom shouldNotBreakMsg to 
 *   respond to an attempt to break the door.
 */

+ frontDoorOutside: Door 'ytter|dörr+en; solid+a av[prep] ek; dörr|över|stycke+t' 
    "Datumet som är inristat i dörröverstycket, 1908, bekräftar att huset 
    verkligen är edwardianskt. Själva dörren är av massiv ek; det finns inte 
    en chans att du skulle kunna ta sönder den. "

    otherSide = frontDoorInside
    
    shouldNotBreakMsg = 'Dörren är av massiv ek; det finns inte en chans att 
    du skulle kunna ta sönder den. '
    
    lockability = lockableWithKey
    
    isLocked = true     
;

/*   
 *   KEY HIDDEN UNDER POT
 *
 *   Hiding a key under a pot just by the door hardly constitutes an exciting
 *   puzzle, but here the point is simply to provide an example of two keys 
 *   opening the same door.
 */

+ pot: Thing 'blom|kruka+n; gam:mal+la'
    initSpecialDesc = "En gammal blomkruka står på marken nära ytterdörren. "
    
    hiddenUnder = [doorKey]
;


/*  
 *   KEY
 *
 *   This is the other key that will unlock the front door. 
 */

doorKey: Key 'li:ten+lla mässning|nyckel+n'
    actualLockList = [frontDoorOutside, frontDoorInside]
;


//------------------------------------------------------------------------------
/*  
 *   TRAVEL BARRIER
 *
 *   We define this TravelBarrier object here so that we can go on to use it 
 *   on three different connectors inside the house. The idea is to prevent 
 *   the PC from going beyond the hall until s/he's turned off the burglar 
 *   alarm.
 */

alarmBarrier: TravelBarrier
    canTravelerPass(traveler, connector) { return !alarmPanel.isOn; }
    explainTravelBarrier(traveler, connector)
    {
        "Du vågar inte gå längre in i huset innan du har avaktiverat 
        larmet. ";
    }
;

hall: Room 'Hall'
    "Hallen återspeglar en sorts avtagande storslagenhet, som om den kämpade 
    för att minnas de lyckligare dagarna av kejserlig prakt när den byggdes, 
    långt innan den föll i händerna på en lömsk utpressande utlänning. Vägen 
    till den jävelns arbetsrum går direkt österut. Den dystra hallen 
    fortsätter söderut mot köket medan en bred trappa leder upp till våningen 
    ovanför. Ytterdörren ligger norrut, med en låda i oförenligt modernt vitt, 
    placerad på väggen precis bredvid den. "
    
    north = frontDoorInside
    out asExit(north)
    
    /* 
     *   This ONE WAY ROOM CONNECTOR is in place simply so we can put the 
     *   alarm barrier on it. The player can't go east from the hall until 
     *   the alarm has been switched off.
     */
    
    east: TravelConnector
    {
        destination = study
        travelBarriers = [alarmBarrier]
    }
    
    /*   
     *   This fake TRAVEL CONNECTOR exists simply to make the house appear
     *   bigger than the number of rooms we're actually implementing (since we
     *   described it as a sprawling mansion from the outside). Note that the PC
     *   can't actually travel via this connector under any circumstances, but
     *   that different reasons will be given depending on whether the alarm is
     *   on or off; while the alarm is on the travelBarrier will take precedence
     *   over the travelDesc message.
     */
    
    south: TravelConnector 
    { 
        travelDesc = "<<one of>>Du upptäcker att den <<or>>Den <<stopping>> vägen
            leder till köket, men du behöver inte mat just nu. " 
        travelBarriers = [alarmBarrier]
        destination = hall
    }
    up = hallStairs
    
    isLit = nil
;


/*  
 *   DOOR LOCKABLE WITH KEY, DOOR 
 *
 *   This is the other side of the outside of the front door, defined above; 
 *   and the definition is much the same.
 */

+ frontDoorInside: Door 'ytter|dörr+en' 
    otherSide = frontDoorOutside
    lockability = lockableWithKey
    isLocked = true    
;

/*  
 *   FAKE STAIRWAY UP
 *
 *   We can use StairwayUp to make a staircase that will never be climbed. While
 *   the alarm is on the alarmBarrier will take precedence for explaining why
 *   not, but once it's off the travelDesc will provide the expanation.
 *
 *   Again, the purpose of this staircase is simply to suggest that the house is
 *   larger inside than we've really made it.
 */

+ hallStairs: StairwayUp 'trapp+an;;trapp|steg+en trappor+na[pl];det dem'
   travelDesc = "På övervåningen hittar du bara sovrum och badrum, och du 
        vill inte sova eller tvätta dig just nu."      
    
    travelBarriers = [alarmBarrier]
;

/*   
 *   KEYED CONTAINER
 *
 *   A KeyedContainer does need a key to lock it and unlock it. We define 
 *   this one so that either the skeleton key or the silver key will unlock 
 *   it.
 */

+ whiteBox: KeyedContainer, Fixture 'vit+a låda+n; oförenlig:t+a li:lla+ten modern+a'
    "Den är ganska liten och sitter ungefär i axelhöjd precis bredvid 
    ytterdörren. "
    cannotTakeMsg = 'Lådan är ordentligt fäst vid väggen. '
        
    /* 
     *   Listening to the box should give the sound of the beep, but only if the
     *   alarm panel is on.
     */
    listenDesc()
    {
        if(alarmPanel.isOn)
            beep.desc;
    }
;

/*  
 *   FIXTURE
 *
 *   This panel object is used to represent the innards of the burglar alarm 
 *   control box. Note that we override isListedInContents and isListed so 
 *   that this panel is clearly announced as being in the box once the box is
 *   opened.
 */

++ alarmPanel: Fixture 'alarm|panel+en;;knappsats+en' 
    "Den har en knappsats med tio knappar, numrerade från 0 till 9. <<isOn ? 'Ett rött ljus
        blinkar på panelen' : 'Det röda ljuset är av'>>. "
    isListedInContents = true
    isListed = true
    
    /* 
     *   Here we provide the code for turning off the alarm by typing the 
     *   correct code on the keypad. Note that the combination matches the 
     *   date on the door lintel outside, but by defining a custom 
     *   combination property we make it easy to change it to anything we 
     *   like.
     */
    
    combination = '1908'
    dobjFor(TypeOn)
    {
        verify() {}
        
        /*  
         *   Since the keypad is described as having buttons numbered 0 to 9 
         *   we need to rule out the attempt to type any other characters on 
         *   it.
         */
        
        check()
        {                        
            for(local i=1; i <= gLiteral.length; i++)                
            {
                local cur = gLiteral.substr(i, 1);
                if(cur < '0' || cur > '9')
                {
                    " Du kan bara skriva siffror på tangentbordet; <q><<cur>></q>
                    är inte ett nummer. ";
                }
            }
        }
        
        /*  
         *   If what the player types matches the combination, turn off the 
         *   alarm.
         */        
        action()
        {
            "Okej, du skriver <<gLiteral>> på tangentbordet";
            if(gLiteral == combination)
            {
                "; det röda ljuset slutar blinka och pipandet stoppas";
                alarmPanel.isOn = nil;
            }
            ". ";
        }
    }
    isOn = true
    
    /* Make ENTER XXXX ON KEYPAD equivalent to TYPE XXX ON KEYPAD */
    
    dobjFor(EnterOn) asDobjFor(TypeOn)

;

/*  
 *   BUTTON
 *
 *   Our example of the Button class has a couple of little tricks to it. 
 *   First of all, when it's pressed all it does is to tell the player to 
 *   try typing on the keypad instead (so instead of typing PUSH BUTTON 1, 
 *   PUSH BUTTON 9, PUSH BUTTON 0, PUSH BUTTON 8, they just need to type 
 *   TYPE 1908 ON KEYPAD). Secondly we make one Button object represent all 
 *   10 buttons. As we've defined the vocabWords below our button will match 
 *   BUTTON 0, BUTTON 1, and so on all the way up to BUTTON 9. So whichever 
 *   (valid) button the player tries to press s/he'll be told to type on the 
 *   keypad instead.
 */

+++ Button 'knapp+en; li:ten+lla 0 1 2 3 4 5 6 7 8 9; knapp+en' 
    
    "Det finns tio små knappar, numrerade från 0 till 9. "
    
    makePushed = "Istället för att trycka på enskilda knappar, 
        skriv bara in siffran PÅ KNAPPSATSEN."    
;

/*   
 *   COMPONENT
 *
 *   This simply represents the red light that's mentioned in the 
 *   description of the alarm panel.
 */

+++ redLight: Component 'röd+a ljus+et' 
    "Det <<alarmPanel.isOn ? 'blinkar' : 'är avstängt'>>. "
;

/*  
 *   NOISE
 *
 *   Until the alarm is switched off it beeps continuously. The Noise represents
 *   the beep. Until the alarm is switched off the player will be told that "A
 *   beeping comes from the white box" on every turn. This will also be the
 *   response to LISTEN, or LISTEN TO BEEP or LISTEN TO BOX.
 *
 *   Note that in this case we don't locate the beep in the box, or it will be
 *   out of scope when the box is closed.
 */

+ beep: Noise 'pipande ljud+et;;pip+et' 
    "Ett pipande ljud kommer från den vita lådan. "
      
    /*  We want this sound to stop once the alarm is switched off. */
    isEmanating = (alarmPanel.isOn)
    
    /*  
     *   We want this sound to be mentioned every turn that the alarm is on.
     *   Here we'll just use the beep's afterAction method to do the trick; a
     *   more sophisticated implementation could make use of the sensory
     *   extension.
     */
    afterAction()
    {
        if(!gActionIn(Listen, ListenTo) && isEmanating)
            desc;
    }
;

/*  
 *   IMMOVABLE
 *
 *   The hatstand provides a rather implausible excuse for illustrating a 
 *   spring lever (see below). We make it Immovable rather than a Fixture, 
 *   say, because it's not clearly impossible for the PC to take the 
 *   hatstand, we'll just rule it out as pointless instead.
 */


+ hatStand: Immovable 'hattstativ+et; hög+a gam:mal+la av[prep] trä (hatt); hatt|ställ+et'   
    "Det är ett högt träställ med ett antal pinnar för att hänga hattar på. 
    Det finns inga hattar på stället för tillfället, men en närmare granskning 
    påvisar att en av pinnarna är gångjärnsförsedd."
    
    specialDesc = "En gammal hattställ i trä lurar på ena sidan. "
    
    cannotTakeMsg = 'Du vill inte belasta dig meddet, så du kan lika 
        gärna lämna det där det är. '
;

/*  
 *   SPRING LEVER
 *
 *   As Spring Lever is a lever that returns to its original position when it 
 *   is released, making it functionally equivalent to a Button. This 
 *   somewhat contrived example of a Spring Lever drops the alarm box key 
 *   onto the floor when it is first pulled. It hardly matters if the player 
 *   doesn't discover this since the skeleton key in the black case will do 
 *   the job just as well.
 */

++ peg: Lever, Component 'gångjärn:et^s+försedd+a pinne+n;av[prep] järn;järn+et'
    dobjFor(Pull)
    {
        action()
        {
            if(silverKey.isIn(nil))
            {
                "När du drar i pinnen faller en silvernyckel ner på golvet. ";
                silverKey.moveInto(hall);
            }
            else
                "Du drar ut stiftet men det fjädrar tillbaka igen när väl du 
                släpper det. ";
        }
    }
    
;

/*  
 *   Another KEY. 
 */

silverKey: Key 'li:ten+lla silver|nyckel+n'    
    actualLockList = [whiteBox]
;


//------------------------------------------------------------------------------
/*  ROOM */

study: Room 'Arbetsrum'
    "Ett stort träskrivbord står mitt i rummet, mitt emot en TV i hörnet. 
    Utgången till hallen ligger västerut men i norra väggen har en dörrstor 
    panel monterats fast. "

    west = hall
    out asExit(west)
    north = panel
;

/*  
 *   INDIRECT LOCKABLE, DOOR
 *
 *   An Indirect Lockable is something that is locked and unlocked by some
 *   mechanism other than a key. We'll meet the odd mechanism for unlocking this
 *   door below.
 *
 *   Note the use of ->cubbyPanel in the template. This is an alternative way of
 *   defining the otherSide property.
 */

+ panel: Door ->cubbyPanel 'panel+en; dörr|stor+a prep[av] dörrstorlek+en'
    "Det handlar om formen och storleken på en dörr, men det finns inget 
    handtag eller lås -- åtminstone inget synligt. "
    
    lockability = indirectLockable
;

/*  
 *   SURFACE, HEAVY
 *
 *   A study ought to have a desk it it, if nothing else, so we'll provide 
 *   one. This desk will have a drawer that contains a clue to finding the 
 *   safe and opening it.
 */

+ Surface, Heavy 'skriv|bord+et; stor+a av[prep] trä; ovansida+n' 
    "Baronen måste ha mycket prydliga arbetsvanor, eftersom ovansidan av hans skrivbord
    ser <<contents.length() > 0 ? 'nästan' : ''>> helt tom ut. Du noterar dock,
    att skrivbordet har en låda. "

    /* 
     *   Redirect opening, closing, locking, unlocking and looking in to the 
     *   drawer.
     */
    remapIn = drawer
;

/*  
 *   KEYED CONTAINER
 *
 *   The drawer is another KeyedContainer. Again it can be unlocked either with
 *   its own key or with the PC's skeleton key. This time we'll show the other
 *   way of defining the relationship between locks and keys by listing the keys
 *   that can unlock it in its keyList property.
 */

++ drawer: KeyedContainer, Component 'låda+n; li:ten+lla'
    "Den är inte särskilt stor. "
    
    keyList = [skeletonKey, drawerKey]
    dobjFor(Pull) asDobjFor(Open)
    dobjFor(Push) asDobjFor(Close)
    
;

/*  
 *   AN OPENABLE NOTEBOOK
 *
 *   Most openable objects will be either doors or containers, but a few 
 *   other things can be opened as well, such as books. To illustrate this 
 *   we'll make this notebook openable.
 */


+++ notebook: Thing 'li:ten+lla röd+a anteckning^s+bok+en;;'
    "Det är en liten röd anteckningsbok.. "
    /*readDesc = "Most of the pages are blank, but towards the back you find
        someone has written <q><<tvDial.advertising>> is safe:
        <<dial.combination>></q>"*/

        
//TODO: tvDial.advertising is either 'advertising' or 'home shopping'
    /*
    e.g: "Most of the pages are blank, but towards the back you find
        someone has written <q>home shopping is safe: 123464</q>"
    or: "Most of the pages are blank, but towards the back you find
        someone has written <q>advertising is safe: 123464</q>"
    */
    readDesc = "De flesta sidorna är tomma, men längst bak ser du att 
        någon har skrivit <q><<tvDial.advertising>> är kassaskåp: 
        <<dial.combination>></q>"



    
    isOpenable = true
    dobjFor(Read) { preCond = [objHeld, objOpen] }
;



/*  
 *   MULTIPLEX CONTAINER
 *
 *   The small wooden box is going to be used to illustrate the Settable 
 *   class (in the form of a slider used to unlock it). Note that we have to 
 *   make the box a Multiplex Container, because we're going to add an external 
 *   component; if we made smallBox an lockable container directly (a very 
 *   easy trap to fall into) we'd find that the external component (the 
 *   slider) actually ended up locked up inside the box, where it would be 
 *   permanently inaccessible.
 */

++ smallBox: Thing 'li:ten+lla trä|låda+n; snidad+e täljd+a'
    "Den är fint snidad och har ett märkligt skjutreglage på ena sidan. "
    
    /* 
     *   INDIRECT LOCKABLE
     *
     *   The subContainer provides an example of an IndirectLockable 
     *   OpenableContainer, that is a container locked and unlocked by some 
     *   means other than a key.
     */
    
    remapIn: SubComponent, OpenableContainer
    {
        bulkCapacity = 2
        lockability = indirectLockable
    }
;

/*  
 *   KEY
 *
 *   Inside the small wooden box we put the key to the desk drawer. Since we've
 *   listed this key in the keyList property of the drawer, we don't need to
 *   define this key's actualLockList property.
 */

+++ drawerKey: Key 'li:ten+lla guld|nyckel+n' 
    subLocation = &remapIn    
;

/*   
 *   SETTABLE
 *
 *   As an example of the base Settable class we'll implement a slider on the
 *   outside of the box that's used to unlock it. To unlock the box the 
 *   player must spell out OPEN with the initial letters of the composers' 
 *   names. It doesn't matter here that this isn't a particularly fair 
 *   puzzle (a) because the player can always use the skeleton key instead 
 *   and (b) this is only a demo, after all, and the point is to illustrate 
 *   the Setter class, not to create a great puzzle.
 *
 *   It's more important that Settable only provides a framework, so that to 
 *   make it work as a slider we shall have to do quite a bit of the work 
 *   ourselves.
 */
 

+++ slider: Settable, Component 'skjut|reglage+t;;pekare+n' 
    "Skjutreglaget har en pekare som kan ställas in på ett av namnen 
    som är ingraverade längs dess längd (som alla verkar vara namn på 
    kompositörer): Elgar, Nielsen, Offenbach eller Pachabel. Den är 
    för närvarande inställd på <<curSetting>>"

    curSetting = 'Elgar'
    
    /* 
     *   This is not a standard library property on Settable (although it is 
     *   on some of Settable's subclasses); it's one we're defining for 
     *   ourselves.
     */
     // OBS: det här får trots översättning fortsätta vara 'O', 'P', 'E', 'N' 
    validSettings = ['Elgar', 'Nielsen', 'Offenbach', 'Pachabel']
    
    
    /*  
     *   We define a custom settingHistory property to contain a record of 
     *   the initial letters of the last four settings the player moved the 
     *   slider to (so we can check if this ever spells 'OPEN')
     */
    
    settingHistory = ''
    
    makeSetting(val)
    {
        inherited(val);
        
        /* Add the first letter of the setting string to the settingHistory */
        settingHistory += val.substr(1,1);
        
        /* 
         *   If settingHistory is longer than four letters, keep only the 
         *   last four letters
         */
        if(settingHistory.length() > 4)
            settingHistory = settingHistory.substr(-1, 4);
            
    }
    
    /* Make the setting initially capitalized */
    canonicalizeSetting(val)
    {
        return val.substr(1,1).toUpper() + val.substr(2).toLower();
    }
    
    dobjFor(SetTo)
    {
        action()
        {
                        
            inherited();
            
            /* 
             *   If the latest setting makes the last four settings 
             *   (including the latest) spell OPEN then unlock the box; 
             *   otherwise lock it.
             */
            if(settingHistory == 'open')
            {
                smallBox.remapIn.makeLocked(nil);
                "När du ställer in pekaren på <<curSetting>> hör du ett 
                svagt klick från lådan.";
            }
            else
            {
                "Du ställer in pekaren på <<curSetting>>. ";
                smallBox.remapIn.makeLocked(true);
            }
        }
                
    }
;


/*  
 *   HEAVY 
 *
 *   A television may seem a highly unlikely device for opening a door, but 
 *   Baron von Epresser is a bit of a weirdo, and the TV allows us to 
 *   illustrate a few more devices and contraptions.
 */

+ tv: Heavy 'TV;;television+en dumburk+en tv+n tv-|skärm+en televisions|apparat+en' 
    "Under skärmen har TV:n en strömbrytare och en ratt. <<tvSwitch.isOn ?
      reportResponse(tvDial.curSetting, nil) : 'Skärmen är för närvarande blank. '>>"
    
    /* 
     *   The reportResponse() method shows what's on the TV screen when the 
     *   dial is turned to val. If trigger is true it also unlocks and opens 
     *   the panel when val is 'advertising' (we don't want this effect when 
     *   reportResponse() is called from desc(), i.e. when the player is 
     *   simply examining the TV).
     */
    
    reportResponse(val, trigger)
    {
        
        "Skärmen visar ";
        switch(val.toLower())
        {
            case 'sport': 
            case 'idrott': "en amerikansk fotbollsmatch. "; 
                break;
            case 'såpopera': "episod 34,954,221,345 av världens längsta långkörande 
                 såpopera, där Amöbafamiljen fortfarande grälar över evolutionära 
                 utmaningar. ";
                break;
            case 'nyheter': 
                "en nyhetssändning som ser ännu mer deprimerande ut än vanligt: det 
                parti som du favoriserar minst ligger 12 procentenheter före i 
                opinionsmätningarna, räntorna väntas fördubblas och alla 
                nyckelpersoner inom den offentliga sektorn strejkar på obestämd tid
                i väntan på att fackföreningarnas krav på 53 veckors semester per 
                år beviljas.";
                break;
            case 'väder': "den senaste väderprognosen: spridda skurar, solperioder,
                hagel, snö, värmebölja, torka och översvämningar vid olika tidpunkter 
                och på enstaka udda platser. "; 
                break;
            case 'drama': "en särskilt blodig produktion av <i>Hamlet</i>. "; 
                break;
            case 'musik': "en klassisk koncert -- en av Mahlers extralånga
                symfonier av utseendet att döma. "; 
                break;
            case 'advertising': 
            case 'home shopping': "en serie reklam för värdelösa saker du aldrig 
                visste att du ville ha och definitivt inte har råd med."; 
            if(trigger)
            {
                "Panelen <<panel.isOpen ? 'glider ihop' : 'öppnas'>>. ";
                panel.makeLocked(!panel.isLocked);
                panel.makeOpen(!panel.isOpen);                    
            }
            
            break;
            default: "inget av intresse. "; break;
        }
    }
    
    dobjFor(SwitchOn) { remap = tvSwitch }
    dobjFor(SwitchOff) { remap= tvSwitch }
;


/*  
 *   SWITCH 
 *
 *   We could simply have made the TV a switch, since most people will 
 *   probably try to turn it on an off directly (which we also allow through 
 *   the remap statements above). But since the description of the TV refers 
 *   to it as a separate object we may as well implement it separately.
 *
 *   Note that Switch is a subclass of OnOffControl and behaves almost 
 *   identically except that it also responds to the commands SWITCH and 
 *   FLIP, which toggle it between its on and off states. Since the two 
 *   classes are so similar we shall not provide a separate example of an 
 *   OnOffControl.
 */

++ tvSwitch: Switch, Component 'av/på-|knapp+en; av/på'
    "Det är bara en enkel av/på-knapp. "
    makeOn(val)
    {
        inherited(val);
        if(val)
            tv.reportResponse(tvDial.curSetting, true);
        else
            "Skärmen blir blank. ";
    }
;


/*  
 *   DIAL
 *
 *   A Dial is a specialization of Settable, representing a dial that 
 *   can be turned to a number of author-defined settings. 
 */

++ tvDial: Dial, Component 'dial'
    "Ratten kan vridas till <<listSettings()>>; den är för närvarande 
    inställd på <<curSetting>>. "
    
    /* 
     *   validSettings is a library property on LabeledDial, but we need to 
     *   define what the valid settings are.
     *
     *   Note that while five of the settings have been defined with literal 
     *   strings, two have been defined with properties of the dial object. 
     *   This incidentally shows that properties and strings can safely be 
     *   mixed in a list such as this, but it also shows how we might make 
     *   the list adaptive.
     */
    validSettings = [sport, 'såpopera', 'nyheter', 'väder', 'drama',
        advertising, 'musik' ]
    
    
    curSetting = validSettings[1]
    
    /*  
     *   listSettings() is a custom method we are defining here so that the 
     *   description of the dial will automatically (and accurately) reflect 
     *   the validSettings defined above.
     */
    listSettings()
    {
        foreach(local cur in validSettings)                
        {            
            if(validSettings.indexOf(cur) == validSettings.length())
                "eller <<cur>>";
            else
                "<<cur>>, ";
        }
    }
    makeSetting(val)
    { 
        inherited(val);
        
        /* 
         *   If the TV is on, we need to change what it displays in 
         *   accordance with the new setting, and report the change.
         */
        if(tvSwitch.isOn)
            tv.reportResponse(val, true);
    }    
    
    /*  
     *   We define these two settings through properties since British and 
     *   American players might expect to see them described differently.
     */
    
    // Notera att detta inte var helt enkelt att översätta till svenska,
    // nödlösning här också:
    advertising = (me.nationality == british ? 'reklam' : 'TV-shopping')
    sport = ( me.nationality == british ? 'sport' : 'idrott') 
;


//------------------------------------------------------------------------------
/* ROOM */

cubbyHole: Room 'Litet fack'
    "Det här är egentligen inget mer än ett litet fack, där halva utrymmet 
    upptas av ett enormt kassaskåp. Det enda andra intressanta här är den 
    gröna spaken som sitter i väggen, bredvid skjutpanelen söderut. "

    south = cubbyPanel
    out asExit(south)
;

/*  
 *   INDIRECT LOCKABLE, DOOR
 *
 *   The cubby panel represents the other side of the panel in the study. It 
 *   too is an indirect lockable, but we'll provide a different (and simpler)
 *   mechanism for locking and unlocking it from this side.
 */

+ cubbyPanel: Door  ->panel 'panel+en; glidande'
;

/*   
 *   LEVER
 *
 *   A Lever can be in one of two states: pushed and pulled. It can then be 
 *   pulled and pushed respectively to change states. Here we use a Lever to 
 *   provide a simple mechanism for opening/unlocking and closing/locking the
 *   sliding panel from inside the cubby hole.
 */

+ Lever, Fixture 'grön+a spak+en' 
    "Den är placerad på en bekväm höjd i väggen. "
    makePulled(stat)
    {
        cubbyPanel.makeOpen(stat);
        cubbyPanel.makeLocked(!stat);
        "Panelen <<stat ? 'glider upp' : 'stängs'>>. ";
    }
;



/*  
 *   MULTIPLEX CONTAINER
 *
 *   Like the small wooden box on the desk above, the safe needs to be 
 *   implemented as a Mutiplex Container since it has an exterior component, in
 *   this case the dial used to unlock it.
 */

+ safe: Heavy 'kassa|skåp+et; enorm+a; dörr+en' 
    "Förutom att det ser enormt och ointagligt ut, är den mest intressanta 
    egenskapen hos kassaskåpet den svarta ratten som sitter mitt på dörren. " 
    
    remapOn: SubComponent { }
    remapIn: SubComponent, OpenableContainer 
    {
        cannotLockMsg = 'Antagligen behöver du använda ratten. '
        cannotUnlockMsg = (cannotLockMsg)
        lockability = indirectLockable
    }
    
;

/*   
 *   NUMBERED DIAL
 *
 *   NumberedDial is a specialization of Dial. As its name suggests it can be
 *   used to represent a dial that can be turned to a range of mumeric values.
 *   Here we use it for a classic combination lock.
 */


++ dial: NumberedDial, Component 'svart+a ratt+en' 
    "Det är en svart ratt som kan vridas till ett valfritt nummer mellan 0 
    och 99; den är för närvarande inställd på <<curSetting>>. "
    
    /* 
     *   The following three properties are standard library properties for a
     *   NumberedDial. Note the oddity that while minSetting and maxSetting 
     *   have to be defined with integer values, curSetting has to be 
     *   defined (and used) as a string.
     */
    minSetting = 0
    maxSetting = 99
    curSetting = '15'
    
    /*   
     *   Since we're using the dial as a combination lock, we'd better give 
     *   it a combination. Again, this is a string property (since it will be
     *   matched against values of curSetting, which is a string). 
     */
    combination = '239756'
    
    /*   
     *   We also need a property to store the numbers to which the dial has 
     *   been turned, so that we can tell when the correct combination has 
     *   been entered.
     */
    numbersDialled = ['0','0','0']
    
    
    dobjFor(SetTo)
    {
        action()
        {
            inherited;
            
            /* Keep a record of the last three numbers dialled */
            numbersDialled[1] = numbersDialled[2];
            numbersDialled[2] = numbersDialled[3];
            numbersDialled[3] = curSetting;
            
            /* 
             *   If the last three numbers dialled match the combination, 
             *   unlock the safe, otherwise lock it if it is closed.
             */
            
            if(numbersDialled[1] + numbersDialled[2] + numbersDialled[3] ==
               combination)
            {
                safe.remapIn.makeLocked(nil);
                "Då du vrider ratten till <<curSetting>>, så hörs ett
                tillfredsställande <i>klick</i> från kassaskåpet. ";
            }
            else if(!safe.remapIn.isOpen)
            {
                safe.remapIn.makeOpen(nil);
            }
        }
        
    }
;

/*   
 *   READABLE 
 *
 *   Finally, we implement the letter the PC has come to retrieve. In a real 
 *   game we'd doubtless want to put other things in the safe as well, but 
 *   since this is a demo the letter alone will do.
 */

++ letter: Thing 'brev+et; kärlek belastand+e komprometterande avslöjande känslig+a; kärleksbrev+et'
    "En blick räcker för att avgöra att det här är brevet du kom för att 
    återta: en ungdomlig indiskretion, skriven till en olämplig älskare. 
    Du har ingen lust att läsa igenom det; bara att minnas det är 
    pinsamt nog. När du väl har gett dig av härifrån kommer du att 
    förstöra det. "

    subLocation = &remapIn
    
    readDesc = "Du har ingen lust att läsa det just nu. Du vet alltför väl  
        vad som står i det. "
;

//==============================================================================

modify finishOptionAmusing
    doOption()
    {

        if(!me.hasSeen(skeletonKey))
            "Försök att titta i det svarta fodralet du bär.\b";

        if(!me.hasSeen(doorKey))
            "Försök att titta under blomkrukan.\b";

        if(torch.name == 'plaströr')
            "Försök att kalla plaströret vid dess rätta namn nästa gång.";

        if(torch.name == torch.britishName)
            "Nästa gång, se vad som händer om du kallar ficklampan för en lykta/fackla.\b";

        if(torch.name == torch.americanName)
            "Nästa gång, se vad som händer om du kallar ficklampan för en lampa/ficklampa.\b";

        if(!me.hasSeen(silverKey))
            "Försök att titta närmare på hattstället i hallen och se om det finns något du kan dra i det.\b";

        if(!me.hasSeen(drawerKey))
            "Ta en närmare titt på lådan på skrivbordet och se om du kan få den att ÖPPNAS.\b";

            "Försök att vrida på ratten på TV:n för att se vad som finns på de olika kanalerna.\b";        
        
        /* 
         *   We need to return true to tell the caller that we've done with 
         *   this option and we want to display the list of options again.
         */
        return true;
    }
;
    



