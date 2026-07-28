#charset "utf-8"

#include <tads.h>
#include "advlite.h"


/*  
 *   EXERCISE 22 - ATTACHMENT
 *
 *   A demonstration of adv3Lite Attachable classes.
 *
 *   Handling Attachables is not always straightforward, to say the least, so
 *   this is the most complex of the demo games. If you have not already done
 *   so, you may want to become familiar with the other demo games first.
 *
 *   Attachables are complicated because there is so many different ways in
 *   which they could behave that the library classes can only provide a general
 *   framework which the game author must customize to suit each particular
 *   case. For example, if I attach a rope to a heavy box lying on the floor and
 *   then try to walk out of the room still holding the rope, a number of
 *   different things might happen, including:
 *
 *   (1)    I walk into the next room, still holding the rope, dragging the box
 *   along behind me.
 *
 *   (2)    I walk into the next room, still holding the rope, but it becomes
 *   detached from the box.
 *
 *   (3)    I walk into the next room, still holding the rope, which is so long
 *   that it has not yet become taut.
 *
 *   (4)    I am jerked to a halt by the rope, which has become taut, and cannot
 *   leave the room while I am holding the rope.
 *
 *   (5)    I walk into the room, but am forced to let go of the rope in the
 *   process.
 *
 *   And those are just the possibilitis involving a rope attached to a box;
 *   many other kind of attachment relationships are possible.
 *
 *   Given the vast number of possibilities, this demonstration game cannot hope
 *   to cover them all, and will only attempt a small range by way of
 *   illustration.
 *
 *   Also, because this game is already quite complex enough, and is intended
 *   primarily to illustrate the use of Attachables, this comments in the source
 *   code will be largely restricted to those parts of the code relating to the
 *   implementation of Attachable objects.
 *
 *   Finally, in adv3Lite the Attachable classes all descend from
 *   SimpleAttachable which implements simpler cases of attachment.
 */

versionInfo: GameID
    IFID = '7aa136e2-0442-4c01-9d0b-2cf9ad94a903'
    name = 'Övning 22 - Fastsättning'
    byline = 'av Eric Eve'
    htmlByline = 'av <a href="mailto:eric.eve@hmc.ox.ac.uk">Eric Eve</a>'
    version = '1'
    authorEmail = 'Eric Eve <eric.eve@hmc.ox.ac.uk>'
    desc = 'En demonstration av adv3Lites Attachable-klasser.'
    htmlDesc = 'En demonstration av adv3Lites Attachable-klasser.'
    
    showAbout()
    {
        "Detta är främst en demonstration av adv3Lites Attachables. Spelet kan 
        spelas till ett vinnande slut (eller ett förlorande!), men det har 
        utformats i syfte att demonstrera Attachables snarare än att göra ett
        särskilt bra spel.\b
        Om du vill spela igenom spelet och upptäcker att du kör fast, kom ihåg 
        att detta är en demonstration av fästbara objekt. Det mesta du behöver 
        göra i det här spelet kommer att involvera att fästa (eller lossa) 
        objekt till varandra.<.p>";
    }
;

gameMain: GameMainDef
    /* Define the initial player character; this is compulsory */
    initialPlayerChar = me
    
    showIntro()
    {
        "Du var inte förtjust alls i att vara den som beordrades att gå ut och 
        fixa sändningsantennen, men den där rymdpromenaden räddade förmodligen 
        ditt liv.\b 
        Federationens krigsskepp (det du åtminstone antog var ett Federationens
        krigsskepp) dök upp som från ingenstans och slog till utan förvarning, 
        med ett enda skott av sin laserkanon genomborrade det det lilla 
        spionskeppet och kastade omkull dig från din sköra avsats. Du tvivlar 
        starkt på att någon inuti skeppet kunde ha överlevt -- ingen annan hade 
        på sig rymddräkt och dekompressionen måste ha dödat dem nästan 
        omedelbart.\b 
        Lyckligtvis försvann det fientliga krigsskeppet lika plötsligt som det 
        dök upp, antagligen förutsatte man att arbetet var klart och brydde sig
        inte ens om att leta efter överlevande. Det fanns nästan inga; det tog 
        dig över en timme att ta dig tillbaka till skeppet och in genom 
        luftslussen, vid vilken tidpunkt syret i din tank var nästan slut. Du 
        tog av dig hjälmen och kippade tacksamt efter luften i luftslussen, och
        du kom ihåg att släcka din hjälmlampa eftersom den också började dämpas.\b
        Det verkar dock inte som att dina problem på nära är över än.\b";
    }
;


/*  
 *   The game takes place entirely aboard a spaceship, so compass directions
 *   will have no meaning. We therefore override Room to disallow movement in
 *   compass directions, and provide players with an explanation of the
 *   directions that can be used for moving around the ship.
 */

modify Room
    /* 
     *   Compass directions are not allowed (because they have no meaning)
     *   aboard the ship.
     */
    allowCompassDirections = nil
    
    /* On the other hand we want to allow shipboard directions everywhere */
    allowShipboardDirections = true
    
    /* 
     *   A custom property representing the air pressure in the room (in 
     *   bar). In this game this will be either 0 or 1.
     */
    pressure = 0
    
    /* At the start of the game the power is off and all rooms are dark. */
    isLit = (powerSwitch.isOn)
;

/* The floor of a ship is called the deck */
modify Floor
    vocab = 'däck+et;; golv+et mark+en'
;

CustomMessages
    messages = [
        Msg(no compass directions, 'Den riktningen har ingen betydelse här; 
        ombord på ett fartyg kan du gå babord (B), styrbord (SB), förut (F) eller
        akterut (A).')
    ]
;


/* Define a message that'll be shown just before the first command prompt. */

InitObject
    execute()
    {
        new OneTimePromptDaemon(self, &introMessage);
    }
    
    introMessage =  "Luftslussens lampa slocknade just, ytterligare ett offer 
    för skadorna som orsakats av Federationens krigsskepp. Den artificiella 
    gravitationen verkar dock fortfarande fungera, så vissa reservbatterier 
    måste fortfarande ha lite laddning kvar i sig. Under tiden fingrar du
    instinktivt på din hjälmlampa. "
;

/*  
 *   A Custom class for Doors that are opened and closed by an external 
 *   mechanism, not by using OPEN and CLOSE commands.
 */

class IndirectDoor: Door
    isOpenable = nil
    lockability = notLockable
    
    cannotOpenMsg = '{Ref subj dobj} {är} manövreras med en spak. '
    cannotCloseMsg = (cannotOpenMsg)
    notLockableMsg = '{Ref subj dobj} {har} inget lås. ' 
;

/*  
 *   DoorLever is custom class we use for the code common to the two levers 
 *   that control the doors in the airlock.
 */
class DoorLever: Lever, Fixture
    
    /* A custom property - the other lever (used for various purposes). */
    otherLever = nil
    
    /* The door controlled by this lever. */
    myDoor = nil
    
    dobjFor(Pull)
    {
        verify()
        {
            
            inherited;
            /* 
             *   This lever can't be pulled when the other one is, since we 
             *   shouldn't have both airlock doors open at once.
             */
            local other = otherLever;
            gMessageParams(other);
            if(otherLever.isPulled)
                illogicalNow('{Ref subj dobj} {är} temporärt fastlåst
                    medan {ref subj other} {är} nerdragen, för att förhindra
                    att båda luftslussdörrarna är öppna samtidigt. ');
        }
        
        check()
        {
            inherited();
            /* 
             *   Don't let the player open a door if there's a vacuum on the 
             *   other side and the player is not wearing both suit and 
             *   helmet, since that would be fatal.
             */            
            if((helmet.wornBy != gActor || spaceSuit.wornBy != gActor)
               && myDoor.destination.pressure == 0)
                "Att öppna <<myDoor.theName>> skulle vara ett fatalt misstag
                av dig just nu. ";
        }
    }
    
    /* Pulling the lever opens the corresponding door; pushing it closes it. */
    
    makePulled(stat)
    {
        inherited(stat);
        myDoor.makeOpen(stat);
        "\^<<myDoor.theName>> skjuts <<stat ? 'isär' : 'ihop'>>. ";
        if(stat && airlock.pressure != myDoor.destination.pressure)
        {   
            "Det blir ett plötsligt luftdrag. ";
            airlock.pressure = myDoor.destination.pressure;
        }
    }
    
    
    cannotTakeMsg = '{Ref subj dobj} är ordentligt monterad i fästet. '

;
    

//------------------------------------------------------------------------------

/* The starting location. */

airlock: Room 'Huvudluftsluss'
    "Denna lilla luftsluss, på babords sida av fartyget, är nästan stor nog 
    för att en man ska kunna stå i den -- två skulle vara obehagligt mysigt. 
    Ett par spakar styr luftslussdörrarna, och tre mätare visar lufttrycket 
    inuti och utanför luftslussen."
    starboard = innerDoor
    port = outerDoor
    pressure = 1
    out asExit(starboard)
    roomBeforeAction()
    {
        if(gActionIs(GoOut) && outerDoor.isOpen)
            goInstead(port);    
    }
;

+ redLever: DoorLever 'röd+a spak+en'
    "Den är märkt <q>Yttre dörr</q>. "
    otherLever = greenLever
    myDoor = outerDoor
    collectiveGroups = [leverGroup]

;

+ greenLever: DoorLever 'grön+a spak+en'
    "Den är märkt <q>Inre dörr</q>. "
    otherLever = redLever
    myDoor = innerDoor
    
    dobjFor(Push)
    {
        verify()
        {
            if(hawser.isIn(airlock))
                illogicalNow('Du kan inte stänga innerdörren medan trossen går igenom den.');
            inherited;
        }
    }
    collectiveGroups = [leverGroup]
;

/* 
 *   COLLECTIVE GROUP
 *
 *   Using this CollectiveGroup allows us to provide a collective description of
 *   the two levers as a pair, rather than two individual descriptions, in
 *   response to EXAMINE.
 */

+ leverGroup: CollectiveGroup, Fixture 'spakar'
    "Det finns en röd spak (som styr ytterdörren) och en grön spak 
    (som styr innerdörren)."
;

+ portDial: Fixture 'babords|mätare+n;babord+s åt[prep]'
    "Babordsmätaren visar lufttrycket bortom babords (yttre) dörr; d.v.s. utanför
    fartyget; den registrerar för närvarande 0 bar"
    collectiveGroups = [dialGroup]
;

+ centreDial: Fixture 'central+a mitt|mätare+n; i[prep] mitt+en'     
    "Den centrala mätaren visar lufttrycket inuti luftslussen; den registrerar 
    för närvarande <<airlock.pressure>> bar."
    collectiveGroups = [dialGroup]
;

+ starboardDial: Fixture 'stybords|mätare+n;styrbord+s åt[prep]'
    "Styrbordsmätaren visar lufttrycket bortom styrbords (inre) dörr, den 
    registrerar för närvarande <<storageCompartment.pressure>> bar."
    collectiveGroups = [dialGroup]
;

/* 
 *   COLLECTIVE GROUP
 *
 *   This CollectiveGroup similarly allows the three dials to be described
 *   together.
 */

+ dialGroup: CollectiveGroup, Fixture 'rattar+na;;;dem'
    "Babordsmätaren visar att lufttrycket bortom babords (yttre) dörr är för 
    närvarande 0 bar. Den centrala mätaren visar att lufttrycket inuti 
    luftslussen för närvarande är <<airlock.pressure>> bar. Styrbordsmätaren 
    visar att lufttrycket bortom styrbords (inre) dörr, dvs. inuti fartyget, 
    är för närvarande <<storageCompartment.pressure>> bar."
;

+ innerDoor: IndirectDoor -> airlockDoor 'inner|dörr+en' 
;

+ outerDoor: IndirectDoor 'ytter|dörr+en'    
    
    destination: Room { pressure = 0 }
    otherSide = self
    canTravelerPass(traveler) { return nil; }
    explainTravelBarrier(traveler)
    {
        "Du vill inte återvända dit ut igen; du har rymdpromenerat så att det
        räcker nu. ";
    }
;


/* 
 *   The player character object. This doesn't have to be called me, but me is a
 *   convenient name. If you change it to something else, rememember to change
 *   gameMain.initialPlayerChar accordingly.
 */

+ me: Player 'du'       
;

/*  
 *   SIMPLE ATTACHABLE
 *
 *   We make the spaceSuit a SimpleAttachable so that an OxygenTank can be
 *   attached to it.
 *
 *   SimpleAttachable is designed to model an asymmetric attachment, where one
 *   of the attached objects is the major attachment and all the others are its
 *   minor attachments (we'd consider a limpet mine to be attached to a
 *   battleship, not the other way round - the battleship would be the major
 *   attachment and the mine the minor attachment). If the major attachment is
 *   moved, its minor attachments (those listed in its attachments property)
 *   move with it. If a minor attachment is moved (e.g. by the player character
 *   taking it) it becomes detached from the major attachment (think of a magnet
 *   attached to a fridge).
 *
 *   By default, a SimpleAttachable is designed to be used with other
 *   SimpleAttacables: both the major attachment and its minor attachments
 *   should be of class SimpleAttachable.
 */
++ spaceSuit: SimpleAttachable, Wearable 'rymd|dräkt+en; mörk:t+a blå+a mörkblå+a (rymd);'
    "Den är mörkblå, färgen av en marinuniform. "
    wornBy = me
    owner = me
     
    /* 
     *   The space suit is the major attachable here (any oxygen tank 
     *   attached to it will move round with it). We set it up as the major 
     *   attachments by listing the minor attachments that can be attached 
     *   to it.
     */
    allowableAttachments = [emptyTank, fullTank]    
    
    
    /* Prevent the player removing the space suit in a vacuum. */
    dobjFor(Doff)
    {
        check()
        {
            if(gActor.getOutermostRoom.pressure == 0)
                "Det skulle ett vara fatalt misstag; det finns ingen luft 
                på denna plats. ";
        }
    }
;


/*       
 *   OxygenTank is a custom class defined below; it inherits from 
 *   SimpleAttachable. By locating emptyTank in spaceSuit we ensure that the 
 *   empty tank starts out attached to the space suit at the start of the 
 *   game.
 */

+++ emptyTank : OxygenTank 'tom+ma *'    
    airLevel = 4
    
    initiallyAttachedTo = spaceSuit
;


/*  
 *   The helmet is another SimpleAttachable so we can attach a lamp to it 
 *   (and detach the lamp from it), or plug and unplug the lamp.
 */

++ helmet: PlugAttachable,SimpleAttachable, Wearable 'hjälm+en; (rymd); standard|hjälm+en'
    "Det är en standardutgåva av en rymdhjälm."
    
    /* The lamp is the only object that can be attached to the helmet. */
    allowableAttachments = [lamp]
    
    
    /* 
     *   While the player character is wearing the helmet, he's dependent on 
     *   the air it contains (or can get from the oxygen cylinder) to 
     *   breathe, so we need to model the breathing and air supply. We do 
     *   this with a DAEMON.
     */    
    breathingDaemonID = nil
    
    breathingDaemon()
    {
        /* Reduce the airLevel by one each turn the helmet is worn. */
        airLevel --;
        
        /* 
         *   If there's an oxygen tank attached to the space suit and the 
         *   tank contains enough air, refresh the air supply in the helmet.
         */
        if(myTank && myTank.airLevel > 0)
        {
            local newAir = min(myTank.airLevel, maxLevel - airLevel);
            if(newAir > 1)
                "Det kommer plötsligt in en ström med färskt syre i din 
                hjälm. ";
            airLevel += newAir;
            myTank.airLevel -= newAir;
        }
        
        /* 
         *   If the air in the helmet is running out, display a warning 
         *   message.
         */
        switch(airLevel)
        {
            case 4: "Luften inuti din hjälm börjar kännas väldigt unken.
            "; break;
            case 3: "Luften i din hjälm är knappt andningsbar. "; break;
            case 2: "Luften i din hjälm är så unken att du börjar svimma. "; break;
            case 1: "Du kan knappt andas alls; du håller på att svimma.
            "; break;
            /* 
             *   Once there's no air left, the player character dies of 
             *   asphyxiation.
             */
            case 0: "På grund av brist på andningsbar luft förlorar du medvetandet. ";
            finishGameMsg(ftDeath, [finishOptionUndo] );           
        }
        
    }
    
    /* 
     *   A custom property defining which oxygen tank the helmet is getting 
     *   its air supply from. This will be the tank attached to the suit. 
     */
    myTank = (spaceSuit.attachments.valWhich({x: x.ofKind(OxygenTank) }))
    
    /* The amount of air in the helmet (a custom property). */
    airLevel = 5
    
    /* The maximum amount of air the helment can hold. */
    maxLevel = 5
    
    dobjFor(Wear)
    {
        action()
        {            
            inherited;
            /* 
             *   When the helmet is put on, it starts full of air, but we 
             *   then need to start the breathing daemon.
             */
            airLevel = maxLevel;
            breathingDaemonID = new Daemon(self, &breathingDaemon, 1);
        }
        
    }
    
    dobjFor(Doff)
    {
        check()
        {
            /* 
             *   Don't allow the player character to remove the helmet in a 
             *   vacuum.
             */
            if(gActor.getOutermostRoom.pressure == 0)
                "Det vore en säker död; den här platsen är helt trycklös. ";
        }
        
        action()
        {
            inherited;
            
            /* When the helmet is removed, stop the breathing daemon. */
            if(breathingDaemonID)
            {
                breathingDaemonID.removeEvent();
                breathingDaemonID = nil;
            }
            
        }
    }
;


/*  
 *   PLUG ATTACHABLE
 *
 *   PlugAttachable is a mix-in class for use with other Attachable classes to
 *   make PLUG INTO and UNPLUG FROM behave like ATTACH TO and DETACH FROM.
 *
 *   We make the lamp a PlugAttachable so it can be plugged into a charging
 *   socket.
 *
 *   It's also a SimpleAttachable. It can be attached either to the helmet or to
 *   the charging socket, but that's defined on them.
 *
 *   Had we wanted to, we could have saved ourselves a bit of work here by using
 *   the FueledLightSource class from the FueledLightSource extension.
 */

+++ lamp: PlugAttachable, SimpleAttachable, Flashlight 'lampa+n; (hjälm+ens)'
    "Den är utformad för att fästas på hjälmen, men kan tas loss för laddning.
    Den kan även slås på och av. "
    
    /*  
     *   Make it visible in the dark when off so it's still in scope for the 
     *   player to turn it on.
     */
    visibleInDark = true
    
        
    /*  
     *   When the lamp is attached to the socket, it is charged up again. We 
     *   control this with a charging daemon, so that the longer it's plugged
     *   in, the more charge it receives.
     */
    chargeDaemonID = nil
    
    attachTo(other)
    {
        inherited(other);
        
        /* Start the charging daemon when we're plugged into the socket. */
        if(other == chargingSocket)
        {
            chargeDaemonID = new Daemon(self, &chargeDaemon, 1);
            if(fuelLevel < 10)
            {
                "Lampan börjar skina starkare så fort den är inkopplad. ";
                fuelLevel = 10;
            }
        }
    }
    
    detachFrom(other)
    {
        inherited(other);
        
        /* Stop the charging daemon when we're removed from the socket. */
        if(other == chargingSocket)
        {
            chargeDaemonID.removeEvent();
            chargeDaemonID = nil;
        }            
    }
    
    chargeDaemon()
    {
        /* Increase the charge in the lamp each turn it's plugged in. */
        if(fuelLevel < maxCharge)
            fuelLevel += 20;
    }
    
    /* 
     *   fuelDaemon() is a custom method we use to track the amount of charge
     *   left in the lamp.
     */
    
    fuelDaemon()
    {           
        switch(fuelLevel--)
        {
            case 5: "Lampan är definitivt svagare."; break;
            case 4: "Lampan börjar blinka."; break;
            case 3: "Lampan verkar väldigt svag nu."; break;
            case 2: "Lampan är på väg att slockna."; break;
            case 1: "Lampan ger ifrån sig slutliga blinkar."; break;

            case 0:
                "Lampan slocknar. ";
            makeOn(nil);
            fuelLevel = 0;
            if(!getOutermostRoom.isIlluminated)
                "Du omsluts av mörker. ";
            break;
            
        }
        
    }
    
    fuelDaemonID = nil
    
    makeOn(stat)
    {
        inherited(stat);
        
        /* 
         *   In addition to the standard (inherited) handling for turning a
         *   Flashlight on or off we need to start or stop the Daemon that
         *   consumes the lamp's "fuel" (or charge) each turn it's on.
         */
        if(stat && fuelDaemonID == nil)
            fuelDaemonID = new SenseDaemon(self, &fuelDaemon, 1);
        if(!stat && fuelDaemonID != nil)
            fuelDaemonID.removeEvent();
        
    }
      
    dobjFor(SwitchOn)
    {
        check()
        {
            if(fuelLevel < 1)
                "Lampan är helt urladdad; den tänds inte. ";
        }
    }
    
    maxCharge = 100000
    
    fuelLevel = 15
    
    initiallyAttachedTo = helmet   
;


//==============================================================================
/*  
 *   Define the custom OxygenTank class. 
 *
 *   It's another SIMPLE ATTACHABLE, but it's made a bit more complicated by 
 *   the fact that only one OxygenTank can be attached to the space suit at 
 *   a time.
 */
class OxygenTank: SimpleAttachable 'syrgas+stank+en; silver|metall|luft+en; cylinder+n'
     
    /* 
     *   If there's another OxygenCylinder attached to the space suit when 
     *   the player tries to attach this one, insist that the other one is 
     *   detached first. 
     */    
    dobjFor(AttachTo)
    {
        check()
        {
            if(gIobj == spaceSuit && gIobj.attachments.indexWhich({x:
            x.ofKind(OxygenTank) && x != self }) != nil)
                "Du måste ta bort den andra tanken först. ";
        }        
    }
;



//------------------------------------------------------------------------------


storageCompartment: Room 'Förvaringsfack'
    "<<first time>>Denna plats verkar i stort sett vara oskadad av explosionen
     från fiendens krigsfartyg, även om allt som inte spikats fast troligen 
     svepts bort av den explosiva dekompressionen till någon annanstans i 
     fartyget, eftersom det inte fanns tid att täta skiljeväggarna. 
     <<only>>Utrustningsskåpet ser säkert ut, liksom matfrysen. Luftslussdörren
    är åt babord och styrs av en röd knapp, medan maskinrummet ligger akterut 
    och bostadsutrymmena är fören. Det finns ett laddningsuttag på skiljeväggen
    och en vinsch åt ena sidan (vanligtvis används för att transportera 
    förnödenheter ombord på fartyget)."
    
    aft = engineRoom
    port = airlockDoor
    fore = livingQuarters    
;

+ airlockDoor: Door ->innerDoor 'luft|sluss|dörr+en'
    lockability = indirectLockable
;

/* 
 *   In sdv3Lite a Button is fixed in place by default, since it's usually part
 *   of something else.
 */
+ Button 'röd+a knapp+en' 
    dobjFor(Push)
    {
        
        action()
        {
            if(hawser.isIn(airlock) && airlockDoor.isOpen)
                "Du kan inte stänga slussluckan medan kabeln löper genom den. ";
            
            airlockDoor.makeOpen(!airlockDoor.isOpen);
                "Luftslussdörren skjuts <<airlockDoor.isOpen ? 'upp' : 'ihop'>>. ";            
        }
    }
;

+ Container, Fixture 'ställ+et' 
;

/* OxygenTank is a custom class defined below. */

++ fullTank: OxygenTank 'full+a *' 
    initSpecialDesc = "En enda syrgasbehållare står kvar i stället vid luftslussen;
        du hoppas att den fortfarande är full. "
    airLevel = 5000
;

/* 
 *   PLUG ATTACHABLE, SIMPLE ATTACHABLE 
 *
 *   The charging socket is both a PlugAttachable (so we can plug things into
 *   it) and a SimpleAttachable (which means anything attached to it will 
 *   be moved into it, as we'll make it the major attachment).
 */

+ chargingSocket: PlugAttachable, SimpleAttachable, Fixture     
    'laddnings|uttag+et'
    "<< powerSwitch.isOn ? 'Med strömmen påslagen igen borde det inte vara några svårigheter att ladda från uttaget' : 'Även om huvudströmmen är avstängd har laddningsuttaget ett reservbatteri som förhoppningsvis borde ha behållit tillräckligt med laddning för dina ändamål' >>."

    /* The list of items that can be attached to the charging socket. */
    allowableAttachments = [lamp, blackCable]
;
    
+ equipmentLocker: LockableContainer, Fixture 'utrustnings|skåp+et' 
;

++ Decoration 'utrustning+en;delar+na prep[av];;dem' "<<notImportantMsg>>"
    name = 'delar av utrustning'
    definiteForm = 'delarna av utrustningen'

    notImportantMsg = (livingQuarters.seen ? 'Det finns inget annat du behöver
        här just nu.' : 'När du har bedömt skadan vet du vad du behöver för 
        att reparera den.')
    isListed = true
    isListedInContents = true
    
    aName = ('diverse ' + name)
;

/*  
 *   CableConnector (NEARBY ATTACHABLE)
 *
 *   A CableConnector is another custom class (defined below). As can be seen
 *   below, CableConnector subclasses from NearbyAttachable. The purpose of 
 *   CableConnectors is to join two lengths of cable together.
 *
 */

++ redConnector: CableConnector 'röd+a *' 
    isHidden = true
;

++ yellowConnector: CableConnector 'gul+a *'     
    isHidden = true
;

/*  
 *   PLUG ATTACHABLE / ATTACHABLE
 *
 *   The black cable is a PlugAttachable so it can be plugged into things. It's
 *   also of class Cable, which is defined below. Cable derives from Attachable
 *   so that it can be connected to two things at once to establish an
 *   electrical connection between them.
 */

++ blackCable: PlugAttachable, Attachable, Cable 'svart+a längd|kabel+n'
    "Det är en vanlig elkabel, ungefär ett par meter lång. "
    isHidden = true
    
    
    /*  
     *   After every ATTACH TO action involving an ElectricalConnector (a custom
     *   class defined below), check to see whether the action has completed an
     *   electrical connection between the two sections of cable that need to be
     *   re-connected.
     */    
    afterAction()
    {
        if(gActionIs(AttachTo) && gDobj.ofKind(ElectricalConnector) &&
            aftCable.isElectricallyConnectedTo(foreCable))
            "Du färdigställer anslutningen mellan den främre och bakre delen av den 
            avskurna kabeln. ";
    }
;


++ roll: Thing 'skrov|reparations|tyg+et; grå+a med[prep];skrov|reparations|rulle+n skrov|reparations|duk+en'
    "Materialet är grått med ett svagt metalliskt utseende. Det kan användas för 
    att göra tillfälliga reparationer av sprickor i skrovet. Det skyddar inte mot
    stötar från stora föremål eller vapeneld, men det är tillräckligt bra för att
    hålla borta lätt damm för att skydda mot skadlig kosmisk strålning. Det är 
    också tillräckligt bra för att skapa en lufttät tätning så att fartyget kan 
    trycksättas på nytt. "
    name = 'rulle med skrovreparationstyg'
    definiteForm = 'rullen med skrovreparationstyg'


    isHidden = true
    dobjFor(Take)
    {
        check()
        {
            if(fabric.moved)
                "Du behöver inte något mer av reparationsmaterialet nu. ";
        }
        action()
        {
            /* 
             *   The fabric object, representing a square of fabric cut from
             *   this roll, is defined below.
             */
            fabric.actionMoveInto(gActor);
            "Du rullar ut duken, klipper av en kvadrat i den storlek du behöver,
            och lägger tillbaka rullen i skåpet. ";
        }
    }
;


+ freezer: LockableContainer, Fixture 'frys+en; stor+a'
    "Det är en stor frys; den behöver vara det för att förse besättningen med 
    proviant i flera veckor. "
;

++ Decoration 'viss mat' 
    "Det finns gott om mat i alla fall; vad som än dödar dig, så kommer det 
    inte att vara svält. "

    isListedInContents = true
    isListed = true
    
    notImportantMsg = ( helmet.wornBy == me ? 'Du kan inte äta medan 
        hjälmen är på, så du kan lika gärna låta bli maten för stunden.' 
        : 'Du kan bekymmra dig om att äta när du väl har lyckats få bort 
            skeppet härifrån. ')   
;

/*  
 *   PLUG ATTACHABLE     SIMPLE ATTACHABLE
 *
 *   We make the winch a PlugAttachable and the SimpleAttachable so the black
 *   cable can be plugged into it.
 */
+ winch: PlugAttachable, SimpleAttachable, Fixture 'vinsch+en;;hölje+t'
    "Vinschen, som är fast fäst vid golvet, används för att flytta tunga 
    laster runt fartyget. Den styrs med den blå knappen på höljet. "
    allowableAttachments = [blackCable]
    
    socketCapacity = 2
;

++ Button, Component 'blå+a knapp+en'
     dobjFor(Push)
    {
        action()
        {
            /*  
             *   If power hasn't been restored, the only way to get the 
             *   winch to work is to connect it to the charging socket with 
             *   the black cable. For this connection to be made the black 
             *   cable must be attached both to the winch and to the socket.
             */            
            if(!powerSwitch.isOn && !(blackCable.isAttachedTo(winch) &&
                                      blackCable.isAttachedTo(chargingSocket)))
            {
                "Ingenting händer, förmodligen för att vinschen inte har någon ström. ";
                return;
            }
            
            if(hawser.isIn(storageCompartment))
                "Vinschen ger ifrån sig ett kort gnällande ljud och trossen 
                rycker till ett par gånger, men eftersom trossen nästan är 
                helt upprullad händer inget mer. ";
            else if(hawser.isAttachedTo(debris))
            {
                "Vinschen gnäller och trossen spänns. Tonhöjden på gnället ökar 
                när vinschen anstränger sig för att flytta trossen. I ett 
                ögonblick eller två händer ingenting mer, men sedan hörs ett högt 
                skrapande ljud uppåt, och trossen drar långsamt tillbaka en massa 
                skräp in i förvaringskammaren. ";
                debris.actionMoveInto(storageCompartment);
            }
            else
            {
                "Vinschen väcks till liv och lindar tillbaka trossen hela vägen 
                tillbaka in i förvaringsfacket. ";
                hawser.moveInto(storageCompartment);
            }
        }
    }
;


/*  
 *   SIMPLE ATTACHABLE 
 *
 *   We make the hawser a SimpleAttachable so that (a) we can attach it to 
 *   things (in this game, only the debris) and (b) so it moves with whatever
 *   its attached to).
 */
+ hawser: SimpleAttachable 
    'tross+en; vinschens lös+a fri+a från[prep]; längd+en kabel|ände+n' 
    "<<specialDesc>>"
    
    /* Vary the description of the hawser depending on where it is. */
    specialDesc()
    {
        switch(getOutermostRoom)
        {
            case storageCompartment: "En kort tross hänger från vinschen."; break;
            case bridge:
            case livingQuarters: "Trossen löper akterut."; break;
            case engineRoom: "Trossen löper iväg förut."; break;
            case airlock:
            case cabin: "Trossen löper ut genom dörren till babord."; break;
        }
    }
    specialDescBeforeContents = nil
    specialDescListingOrder = 100
    getFacets = [proxyHawser1, proxyHawser2]
    aName = (theName)
;

/* 
 *   If the hawser object is not in the storage compartment, there must be a 
 *   length of hawser running from the the winch to wherever the other end 
 *   of the hawser is. In that case we need a proxy object to describe the 
 *   length of hawser that's visible inside the storage compartment.
 *   ProxyHawser is a custom class defined below.
 */
+ proxyHawser1: ProxyHawser 'tross+en; vinschens med[prep] kabellängd+en; '
    "Trossen från vinschen löper <<cableDir()>>. "
    
    /* 
     *   We want this length of hawser to be visible only when the real 
     *   hawser object is elsewhere.
     */
    isHidden = (hawser.isIn(storageCompartment))
      
    /* 
     *   Describe which way the hawser runs depending on where the other end 
     *   of the hawser is.
     */
    cableDir()
    {
        switch(hawser.getOutermostRoom)
        {
            case engineRoom: "akterut"; break;
            case airlock: "åt babord, in i luftslussen"; break;
            default: "framåt"; break;
        }
    }
    
    /* 
     *   The other objects that can represents sections of the hawser are 
     *   facets of this object.
     */
    getFacets = [hawser, proxyHawser2]
    
;


//------------------------------------------------------------------------------
/*  
 *   Define our custom CABLE CONNECTOR class.
 *
 *   This descends from our custom ElecticalConnector class (defined below), 
 *   which in turn descends from NearbyAttachable.
 */
class CableConnector: ElectricalConnector 
    'kabel|kontakt+en; av[prep] plast+iga; ring+en'
    "Utseendemässigt ser den ut som en plastring. Dess funktion är att 
    sammankoppla en kabellängd till en annan."

    
    allowableAttachments = [blackCable]
;

/* 
 *   Definition of the custom CABLE class.
 *
 *   Cable derives from our custom ElectricalConnector class (defined 
 *   immediately below). The only customization required on this class is to 
 *   define what a Cable can connect to: Cables can connect to 
 *   CableConnectors.
 */
class Cable: ElectricalConnector
    allowAttach(obj)
    {
        return obj.ofKind(CableConnector);                        
    }   
;

/*   
 *   ELECTRICAL CONNECTOR     NEARBY ATTACHABLE
 *
 *   Our custom ElectricalConnector class derives from the library's 
 *   NearbyAttachable class. A NearbyAttachable is an Attachable that 
 *   enforces the condition that the attached objects must be in a 
 *   particular location. By default this is the location that one of the 
 *   objects is already in, but this can be customised by overriding 
 *   attachedLocation. 
 */
class ElectricalConnector: NearbyAttachable
    
    /* 
     *   isElectricallyConnectedTo() is a custom method to test whether an 
     *   electrical connection exists between two ElectricalConnectors. An 
     *   electrical connection exists if the two ElectricalConnectors are 
     *   directly or indirectly attached; they're indirectly attached if 
     *   there's a chain of attached objects between them.    
     */    
    isElectricallyConnectedTo(obj)
    {
        local vec = new Vector(10, [self]);
        local i = 0, cur;
               
        while(i < vec.length)           
        {
            cur = vec[++i];
            vec.appendUnique(cur.attachments);
            vec.appendUnique(cur.attachedToList);
            if(vec.indexOf(obj))
                return true;                       
        } 
        
        return nil;
    }
    
        
;

//------------------------------------------------------------------------------
engineRoom: Room 'Maskinrum'
    "Maskinrummet ser också oskadat ut. Såvitt du kan se vid en snabb 
    genomsökning av instrumenten är huvudmotorn oskadad. <<controls.desc>> "
    fore = storageCompartment
    out asExit(fore)
;

+ controls: Decoration 'instrument+en; massa+n av[prep]; kontroller+na; dem' 
    "Det finns en massa instrument och kontroller här, men 
    \v<<controls.notImportantMsg>>"
    
    notImportantMsg = 'de enda som berör dig just nu är den stora röda 
        strömbrytaren som styr fartygets kraft, den gula spaken som 
        styr lufttillförseln och tryckmätaren som visar lufttrycket inuti 
        fartyget. '
;

+ powerSwitch: Switch, Fixture 'stor+a röd+a ström|brytare+n' 
    "Strömbrytaren är för närvarande <<if isOn>> på<<else>> av<<end>>. "
    makeOn(stat)
    {
        if(stat)
        {
            if(!aftCable.isElectricallyConnectedTo(foreCable))
            {
                "'Brytaren snäpper tillbaka till det avstängda läget; som en 
                säkerhetsåtgärd förblir den inte påslagen när det blir ett 
                större fel någonstans i systemet. ";
                exit;
            }
            "Ljusen tänds över hela fartyget. ";
        }
        else
            "Fartygets ljus stängs av igen. ";
    
        inherited(stat);
    }
;

+ airLever: Lever, Fixture 'gul+a spak+en'
    dobjFor(Pull)
    {
        check()
        {
            if(!lqWall.repaired)
                "Om du slår på lufttillförseln utan att först reparera skadorna
                på skrovet, kommer du bara att slösa bort all luft; den
                kommer att försvinna ut genom öppningen i skrovet i lika snabbt
                som den försöker fylla fartyget. ";
        }
    }
    
    makePulled(stat)
    {
        inherited(stat);
        if(stat && location.pressure == 0)
        {
            "Det hörs ett väsande luftdrag från ventilationsöppningar över hela
            fartyget, och nålen på tryckmätaren börjar stiga. ";
            forEachInstance(Room, { loc: loc.pressure = 1 } );
        }
    }
;

+ Fixture 'tryck|mätare+n; nål+en'
    "Nålen på mätaren visar att trycket inuti fartyget för närvarande är 
    <<location.pressure>> bar. "
;

//------------------------------------------------------------------------------
livingQuarters: Room 'Bostadsutrymme'
    "<<if lqWall.repaired>>Hålet i skrovet på styrbordsidan har lagats igen med 
    en bit reparationstyg, men det<<else>>Det<<end>> var uppenbarligen detta 
    område som fick ta den största smällen av laserstrålen
    
    <<unless lqWall.repaired>>. Om det inte var direkt uppenbart från det 
    gapande hålet i skrovet där styrbordshytterna borde vara, så framgår
    det av vraket att detta <<else>>, vilket framgår av vraket som<<end>> 

    en gång i tiden var besättningssalongen, även om det ser ut som om en av 
    sovhytterna till babord fortfarande kan användas. Förvaringsutrymmet ligger
    akterut, medan vägen framåt leder till bryggan. <<first time>>

    \bDet finns inga tecken på några andra besättningsmedlemmar. De sögs mest 
    troligt ut genom hålet i skrovet vid den snabba dekompressionen. 
    <<equipmentLocker.contents.forEach({o: o.discover})>><<only>>"

    aft = storageCompartment
    port = cabinDoor
    fore = bridge
 
;

/*  
 *   SIMPLE ATTACHABLE
 *
 *   SimpleAttachable is the base class for all the other Attachable classes we 
 *   have seen. 
 *
 *   Here we use it to define a wall to which something (namely, a piece of 
 *   fabric) can be attached.
 */ 
+ lqWall: SimpleAttachable, Fixture 'skrov+et; mot[prep] styrbord|sidan+n; vägg+en'
    desc = "<<repaired ? 'Styrbords skrov ser nu lufttätt ut' : 'Det är ett gapande 
    hål i skrovet'>>. "
    
    /* 
     *   The starboard hull is always 'the starboard hull', never 'a 
     *   starboard hull'
     */
    aName = (theName)
    

    allowableAttachments = [fabric]
    
    /*  
     *   repaired is a custom property to indicate when the wall has been 
     *   repaired by attaching the piece of fabric.
     */
    repaired = (isAttachedTo(fabric))
;

+ gapingHole: Component 'hål+et;gapande;gap+et' 
    "Den är runt på ett ungefär och cirka en meter i diameter."
    name = 'gapande hål'
    definiteForm = 'gapande hålet'
    
    /* 
     *   Make ATTACH FABRIC TO HOLE equivalent to ATTACH FABRIC TO STARBOARD 
     *   WALL.
     */
    iobjFor(AttachTo) { remap = lqWall }
    
    /* Once the hull is repaired, the hole is no longer visible. */
    isHidden = lqWall.repaired
;


/*  
 *   DOOR
 */

+ cabinDoor:  SimpleAttachable, Door ->cabinDoorInside 'hytt|dörr+en; 
    bleka fläck+iga; fläck+en'
    "<<unless sign.isIn(self)>>En något ljusare fläck på dörren indikerar var
    något kan ha fallit av.<<end>> "
    
    lockability = lockableWithoutKey
    
    /*  
     *   Normally making both sides of a Door a Lockable (as opposed to
     *   LockableWithKey or IndirectLockable) doesn't achieve much, since the
     *   door csn simply be unlocked an UNLOCK command. In this case, however,
     *   we can achieve a significant effect by using a check condition to
     *   restrict unlocking the door - the door won't unlock until the ship has
     *   been pressurized.
     */         
    dobjFor(Unlock)
    {
        check() 
        {
            if(location.pressure == 0)
            {
                "Hyttdörren går inte att låsa upp; det måste vara den enda 
                trycktätningen som håller, i såna fall kommer du inte få upp 
                dörren förrän du återställer trycket i skeppet. Det kan vara 
                lika bra, förstås; för om det finns någon kvar i hytten kan 
                denna trycktätning faktiskt vara det enda som håller dem 
                vid liv. ";
            }
        }
    }
    
    
    /* The door can't be closed if there's a hawser running through it. */
    dobjFor(Close)
    {
        verify()
        {
            if(hawser.isIn(cabin))
                illogicalNow('Du lan inte stänga dörren medan kabeln löper 
                    genom den. ');
            inherited;
        }
    }    
    
    allowableAttachments = [sign]
;

/*  
 *   ATTACHABLE COMPONENT
 *
 *   An AttachableComponent is something that would normally be part of
 *   something else, but which may either start out detached from it or may
 *   later become detached (such as a handle that can be unscrewed, perhaps).
 *   For this example we use a sign that would normally be fixed to a door.
 */

+ sign: AttachableComponent 'skylt+en' 
    "Skylt+en säger <q>KAPTEN</q>. "    
    
    initSpecialDesc = "En skylt ligger på golvet, till synes rubbad från sin 
        vanliga plats av explosionen. "
    initiallyAttached = nil
;

/* 
 *   The conduit running along the floor of the living quarters starts out
 *   covered with debris which needs to be moved before it can be accessed.
 */

+ conduit: Container, Fixture 'kabel|rör+et' 
    
    useInitSpecialDesc = (!aftCable.isElectricallyConnectedTo(foreCable))
    initSpecialDesc = "Explosionen har bland annat blottlagt 
        huvudströmledningen som löper längs golvet, vilket visar att en del av
        huvudströmkabeln har bränts bort helt och hållet. 
        <<unless debris.moved>>Tyvärr ser det ut som om skräpet från 
        explosionen kommer göra det svårt att komma åt strömledningen. <<end>>"
    
    
    /*  
     *   Customise the way our contents are listed, so that when the cables 
     *   are all joined up our listing says so.
     */
    examineLister: descContentsLister 
    {
        showListSuffix(lst, pl, paraCnt)
        { 
            /* 
             *   Note the use of lexicalParent here: we want to refer to the
             *   isInInitState property of the conduit, not the examineLister.
             */
             "<< lexicalParent.useInitSpecialDesc ? '' : ', med alla kablar nu 
                sammanfogade i en kontinuerlig slinga'>>. ";
        }              
    }

    
    
    /* 
     *   The conduit starts off covered with debris that makes it difficult to
     *   get at, although we can see what's inside. To simulate that we use the
     *   checkReachIn method to display a message prohibiting access until the
     *   debris is moved.
     */    
    
    checkReachIn(actor, target?)  
    {
        if(!debris.moved)
            "Skräpet som täcker röret blockerar din åtkomst till det.  ";
            
    }
;


/* 
 *   FixedCable is a custom class defined below (inheriting from
 *   NearbyAttachable). Since the fore and aft sections of the cable are meant
 *   to be a couple of metres apart, the same CableConnector can't be
 *   simultaneously attached to both the foreCable and the aftCable. But since a
 *   CableConnector is a SimpleAttachable, this constraint is enforced in any
 *   case: a SimpleAttachable can only be attached to one thing at at time.
 */
++ aftCable: FixedCable 'akter +' 
    "Det är en kort kabel som löper från den bakre änden av röret tills den 
    slutar ungefär två meter före den främre änden, med den centrala delen av 
    kabeln bortbränd. "

    /* 
     *   We use the initSpecialDesc of the aftCable to describe the foreCable as
     *   well, so we include <<exclude foreCable>> in this description to ensure
     *   that foreCable doesn't get a separate listing.
     */
    initSpecialDesc = "I vardera änden av röret ser du de avskurna ändarna av 
        kabeln som löper framåt och bakåt.<<exclude foreCable>>"
    useInitSpecialDesc = (location.useInitSpecialDesc)
    
    specialDescBeforeContents = true
;

++ foreCable: FixedCable 'främre +;föröverut' 
    "Det är en kort kabel som löper från den främre änden av röret
    tills den når fram till ungefär två meter före akteränden, med den 
    centrala delen av kabeln bortbränd. "
;

/*  
 *   SIMPLE ATTACHABLE 
 *
 *   The debris is a SimpleAttachable so we can attach the hawser to it to 
 *   drag it out of the way using the winch. We also make it of class Heavy 
 *   so we can't move it by hand.
 */

+ debris: SimpleAttachable, Heavy 'hög+en med bråte+n; samman|smält+a metall+enb; metall|massa+n'
    "Det är en metallmassa som smält samman av laserstrålningen som 
    genomborrade skeppet; en grov gissning är att det är kvarresterna av
    salongsbordet plus delar av styrbordshytterna. "
    
    /* Allow the hawser to be attached to the debris. */
    allowableAttachments = [hawser]
    
    specialDesc = "En smält massa av metallskräp ligger utspridd över däcket."
;


/* 
 *   As with proxyHawser1 above, we need an object to represent the section 
 *   of hawser running through the living quarters if the end of the hawser 
 *   has been taken beyond the living quarters to either the bridge or the 
 *   cabin. ProxyHawser is a custom class defined below.
 */
+ proxyHawser2: ProxyHawser
    desc = "Trossen löper akterut tillbaka till förvaringsfacket och 
        <<cableDir()>>. "
    isHidden = !(hawser.isIn(bridge) || hawser.isIn(cabin))
    
    cableDir()
    {
        switch(hawser.getOutermostRoom)
        {
            
            case bridge: "framåt till bryggan"; break; 
            case cabin: "babord, in i hytten"; break; 
            default: "framåt"; break;
        }
    }
    getFacets = [hawser, proxyHawser1]   
;


/*  
 *   Define the custom ProxyHawser class to represent lengths of hawser 
 *   passing through a location when the free end of the hawser is elsewhere.
 */
class ProxyHawser: Fixture 'tross+en;;vinch|tross+en kabellängd+en'
    specialDescBeforeContents = nil
    specialDesc = (desc)
    
    cannotTakeMsg = 'Det är ingen större mening att plocka upp mitten av 
        trossen. '
    dobjFor(Pull)
    {
        verify() {}
        check()
        {
            if(hawser.isAttachedTo(debris))
                "Du kan inte dra trossen för hand; lasten i dess bortre ände är
                 för tung. ";
        }
        
        action()
        {            
            hawser.moveInto(gActor.location);
            "Du fortsätter att dra i trossen tills dess lösa ände dyker upp. ";
        }
    }
;

/*  
 *   Define the custom FixedCable class, used to define the two ends of the 
 *   cable left in the conduit.
 */
class FixedCable: Cable, Fixture 'kabel|ände+n;avskurna avskuren av[prep]; 
                                  sektion+en kabel+n'
    isListedInContents = true
    isListed = true
    aName = theName
;

//------------------------------------------------------------------------------

cabin: Room 'Sovhytt'
    "Den här hytten verkar ha klarat sig utan allvarliga skador, och det finns 
    en våningssäng som du kan sova i om du någonsin får tid att sova, med ett 
    nattduksbord praktiskt placerat bredvid. "

    starboard = cabinDoorInside
    out asExit(starboard)
;

+ cabinDoorInside: Door -> cabinDoor 'hytt|dörr+en'
    /* We can\'t close the door if the hawser is running through it. */
    dobjFor(Close)
    {
        verify()
        {
            if(hawser.isIn(cabin))
                illogicalNow('Du kan inte stänga dörren medan kabeln löper 
                    genom den.');
            inherited;
        }
    }
;

+ Platform, Fixture 'brits+en;;säng+en'
;

+ Fixture 'nattduks|bord+et; li:tet+lla metall|skåp+et'
    "Det är ett litet metallskåp med en dörr."
    remapOn: SubComponent {}
    remapIn: SubComponent, LockableContainer 
    { 
        dobjFor(Open) { preCond = [touchObj, objUnlocked]}
    }
;

++ ContainerDoor 'metall|skåps|dörr+en'
    
;

/* 
 *   SIMPLE ATTACHMENT
 *
 *   This one really is simple. 
 */

++ securityCard: SimpleAttachable, Thing    
    'säkerhetskort+et;vit+a lil+a; markeringar+na'
    "Det är ett vanligt vitt kort, cirka 8 cm x 4 cm, med lila markeringar."
    subLocation = &remapIn
;


//------------------------------------------------------------------------------


bridge: Room 'Brygga'
    "<q>Brygga</q> är kanske en storslagen titel för denna lilla kontrollhytt,
    men det är funktionellt sett bryggan, eftersom det är härifrån skeppet 
    flygs ifrån. En enda stol, ordentligt fastsatt i golvet, vetter mot en rad 
    instrument; det brukade finnas en annan stol för personen som tittade på 
    spaningsavläsningar, men den måste ha sugits ut av dekompressionen, eftersom 
    vägen ut akterut är öppen. "
    aft = livingQuarters
    out asExit(aft)
    
;

+ bridgeChair: Platform, Fixture 'pilotstol; stor' 
    "Det är en stor stol, placerad mittemot instrumentpanelen som används för
    att flyga skeppet. "    
   
    cannotTakeMsg = 'Stolen är ordentligt fäst i golvet; det är därför den 
        fortfarande står kvar trots dekompressionen. '
    
    canLieOnMe = nil
       
;

+ Decoration 'instrument|panel+en; 
            fler|färgad+e; 
            kontrolldisplayer+na skärmar+na knappar+na/brytare+n vred+en rattar+na avläsningspanel+en; 
            det dem'

    "Det finns flerfärgade displayer, skärmar, knappar, strömbrytare, vred, 
    rattar och avläsningar i överflöd, ingen av dem är aktiv. Allt kan slås på 
    genom att trycka på den gröna knappen mitt i kontrollpanelen panelen
    <<conditions()>>. "
    
    conditions()
    {
        local cardOK = (securityCard.isAttachedTo(cardReader));
        if(powerSwitch.isOn && cardOK)
            return;
        ", men ingenting kommer att hända förrän ";
        if(!powerSwitch.isOn)
            "huvudströmförsörjningen är påslagen <<cardOK ? '' : 'och '>>";
        if(!cardOK)
            "ett säkerhetskort är anslutet till kortläsaren";
    }
    
    notImportantMsg = 'Vid det här laget behöver du bara bry dig om den gröna 
                      knappen och kortläsaren.'    
;


+ greenButton: Button  'grön+a knapp+en' 
    dobjFor(Push)
    {
        action()
        {
            if(!powerSwitch.isOn)
                "Det händer ingenting; det saknas ström. ";
            else if(!securityCard.isAttachedTo(cardReader))
                "Det händer ingenting; den här fartygsmodellen svarar inte
                på kontrollerna om inte ett säkerhetskort är anslutet till
                kortläsaren. ";
            else
            {
                "Instrumenten väcks till liv, vilket indikerar att skeppet är 
                redo att flyga. Det är osannolikt att Federationens krigsskepp
                som attackerade tidigare kommer tillbaka för en andra titt, 
                men det finns inget att vinna på att dröja kvar, så du sätter 
                kurs mot närmaste imperialistiska värld och beger dig tillbaka 
                till säkerheten.\b";
                finishGameMsg(ftVictory, [finishOptionUndo]);
            }
        }
    }
;

/* 
 *   SIMPLE ATTACHMENT 
 *
 *   Another SimpleAttachment that's actuall simple. We just define the 
 *   allowableAttachments property to contain the list of things that can be
 *   attached to it: in this case, just the securityCard.
 */
+ cardReader: SimpleAttachable, Fixture 'kort|läsare+n' 
    "Den är ungefär 8 cm gånger 4 cm. "
    allowableAttachments = [securityCard]
;

//==============================================================================


/*  
 *   SIMPLE ATTACHABLE
 *
 *   The piece of fabric used to repair the ship's hull can be handled quite 
 *   simply with a SimpleAttachable.
 */
fabric: SimpleAttachable 'kvadratisk+a skrov|reparations|tyg+et; matt+a grå+a metallisk+a; lapp+en'
    "Den är drygt en kvadratmeter stor och har en matt metallgrå färg.
    <<isAttachedTo(lqWall) ? 'Nu när' : 'Då'>> den är fäst vid styrbords skrov och täcker hålet ger 
    den en lufttät tätning."
    
    /* 
     *   attachTo() is a standard library method of SimpleAttachable that
     *   handles the effects of attaching one object to another. Here we carry
     *   out the inherited handling and then explain what happened.
     */    
    attachTo(other)
    {
        inherited(other);
        if(other == lqWall)
        {            
            "Du placerar tyget över hålet och täcker det helt. De yttre 
            kanterna av tyget fäster vid innerskrovet och skapar en tätning 
            som ska vara tillräckligt lufttät för att du ska kunna trycksätta 
            fartyget igen. ";
        }
    }
    
    /* 
     *   Once the patch has been fixed to the wall, we don't want it to be
     *   detached again.
     */
    isDetachable = nil
    
    /* Explain why we can't detach the fabric from the wall. */
    cannotDetachMsg = 'Nu när du har täckt hålet vill du inte blotta det igen.'
    
;







