#charset "utf-8"

#include <tads.h>
#include "advlite.h"

/*   
 *   EXERCISE 17 - LIGHT SOURCES
 *
 *   This is a demonstration of how to use and adapt the standard library light
 *   source classes. It's not at all an exciting game, and playing it straight
 *   through will not be particularly informative. You'll get more out of it by
 *   experimenting with the different kind of light sources provided.
 */

versionInfo: GameID
    IFID = 'c0cc995b-54ce-4f2a-9bdc-ff7a40100ffa'
    name = 'Exercise 17 - Light Sources'
    byline = 'av Eric Eve (Översatt av Tomas Öberg)'
    htmlByline = 'av <a href="mailto:eric.eve@hmc,ox.ac.uk">Eric Eve</a>'
    version = '1'
    authorEmail = 'Eric Eve <eric.eve@hmc,ox.ac.uk>'
    desc = 'A ett kort spel för att illustrera olika slags ljuskällor.'
    htmlDesc = 'A ett kort spel för att illustrera olika slags ljuskällor'
;

gameMain: GameMainDef
    /* Define the initial player character; this is compulsory */
    initialPlayerChar = me
    
    showIntro()
    {
        "Du har färdats långt för att nå hit, men slutligen har du nått 
        grottorna där den legendariska magiska kristallen sägs hållas dold.         
        Besluten att övervinna alla faror och svårigheter står du redo att
        ge dig ut på ditt uppdrag att återfinna Kristallen Som Lyser I Mörkret!\b";

    }
;


/*
 *   Starting location - we'll use this as the player character's initial
 *   location.  The name of the starting location isn't important to the
 *   library, but note that it has to match up with the initial location
 *   for the player character, defined in the "me" object below.
 *   
 *   Our definition defines two strings.  The first string, which must be
 *   in single quotes, is the "name" of the room; the name is displayed on
 *   the status line and each time the player enters the room.  The second
 *   string, which must be in double quotes, is the "description" of the
 *   room, which is a full description of the room.  This is displayed when
 *   the player types "look around," when the player first enters the room,
 *   and any time the player enters the room when playing in VERBOSE mode.
 *   
 *   The name "startRoom" isn't special - you can change this any other
 *   name you'd prefer.  The player character's starting location is simply
 *   the location where the "me" actor is initially located.  
 */
startRoom: Room 'Utanför grotta'
    "Grottan du har kommit för att besöka, står precis norrut.
    Söderut ligger vägen tillbaka till civilisationen. "
    north = smallCave
    in asExit(north)
    south: TravelConnector
    {
        /* 
         *   Don't allow travel this way until the PC has seen the crystal 
         *   and is carrying it.
         */
        
        canTravelerPass(traveler)
        {
            return me.hasSeen(crystal) && crystal.isIn(me);
        }
        explainTravelBarrier(traveler)
        {
            "Du har färdats hela vägen hit för att få tag i kristallen
            och du beger dig inte härifrån utan den! ";
        }
        
        /*  
         *   When travel is allowed, simply end the game with a message 
         *   saying that the player has won.
         */
        
        noteTraversal(traveler)
        {
            "Kristallen återhämtad, du går triumferande iväg. ";
            finishGameMsg(ftVictory, [finishOptionUndo, finishOptionAmusing]);
        }
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
 *   READABLE
 *
 *   To make an object readable in adv3Lite we just need to define its 
 *   readDesc property.
 */
++ Thing 'anteckning+en; handskriv:en+na' 
    "Det är en handskriven lapp från den vän som tipsade dig om den 
    magiska kristallen. "
    readDesc = "Det står, <q>Du borde hitta kristallen i den djupaste 
        grottan.</q> "
;

// TODO: (} ? 
++ matchbox: OpenableContainer 'tändsticks|ask+en; enk:el+la gul+a; ask+en med[prep] (kvalitets|tänd|stickor+na[pl]) (kvalitets|tändsticks|ask+en)'
    "Det är en enkel gul ask, märkt <q>Lätta kvalitetständstickor</q>. "
;

/* The Matchstick class is defined below. */
+++ Matchstick;
+++ Matchstick;
+++ Matchstick;
+++ Matchstick;
+++ Matchstick;


/*  ENTERABLE */

+ Enterable 'grott|ingång+en; trång+a'
    "Grottingången precis till norrut är trång, men vid nog för dig att ta dig in. "
    
    destination = smallCave
;

//------------------------------------------------------------------------------
/*  
 *   DARKROOM: Note the DarkRoom class is not defined in the adv3Lite library;
 *   we define our own custom DarkRoom class below.
 */

smallCave: DarkRoom 'Liten grotta'
    "Det är trångt som i en kappsäck här. Utgången ligger till söder, och du 
    skulle också kunna klämma dig igenom den smala springan till nordväst. "
    south = startRoom
    out asExit(south)
    northwest = gap
;


/*  
 *   CANDLE
 *
 *   A Candle is an object that can be lit and will stay alight for a certain
 *   length of time before going out. We can base it on the FueledLightSource
 *   class we go on define below.
 */

+ candle: FueledLightSource 'röd+a ljus+et' 
    /* 
     *   A candle is effectively its own fuel, so we make its length reflect the
     *   amount of 'fuel' remaining.
     */
    "Ljuset är ungeför <<spellNumber(fuelLevel)*2.5>> centimeter långt; det är <<isLit ? 'tänt' : 'otänt'>>. "
    
    initSpecialDesc = "Ett röd ljus ligger på marken. "
      
    /* 
     *   These warning messages will be displayed when the candle comes close to
     *   being fully burned down; they warn the player that s/he needs to find
     *   another light source quickly.
     */
    warningMessage()
    {
        switch(fuelLevel)
        {
            case 2: "Ljuset brinner väldigt lågt."; break; 
            case 1: "Det som är kvar av ljusrännorna, är på väg att slockna.";
            break;
        }
    }
    
    sayBurnedOut()
    {
        "Ljuset slocknar och bara en utbränd ljusstump blir kvar.";
        
        /* 
         *   We use the replaceVocab() method here both to give the candle a new
         *   name and to change the vocab words that can be used to refer to it.
         *   This effectively changes it from candle to stub.
         */

        // TODO: replaceVocab hanterar inte sammansatt ord särskilt bra, fixa så
        // man slipper skriva så här utförligt
        replaceVocab('ljusstump; röd röda utbränd utbrända; ljusstumpen');
        
        /*  
         *   A the same time and for the same reason we change its description;
         *   we can't change the desc property using a statement like desc =
         *   "whatever", but we can change it using setMethod as shown below.
         */
        setMethod(&desc, 'Det är bara en utbränd ljusstump. ');
    }
    
    sayNoFuel = "Det finns inte nog mycket kvar av stumpen för att kunna tända det. "
;

/*  
 *   PASSAGE
 *
 *   Since we mentioned a narrow gap in the room description we should 
 *   probably implement it.
 */

+ gap: Passage 'trång+a springa+n; smala+a; spricka+n gap+et' 
    "Det är tur att du bantade innan du kom hit; du borde precis 
        kunna ta dig igenom det."
    
    destination = largeCave
;


//------------------------------------------------------------------------------

largeCave: DarkRoom 'Stor grotta'
    "Denna grotta är så stor att du nästan skulle kunna gå vilse i den; trots att 
    det står tydligt nog att de enda rimliga utgångarna är sydost, nordost och väst. "
    southeast = smallCave
    northeast = roundCave
    west = deadEnd
;


/*  
 *   FUELED LIGHT SOURCE
 *
 *   A FueledLightSource is a light source that consumes fuel as it burns. The
 *   Library provides quite a bit of the implementation for this class, but we
 *   need to do more work to make it function in a particular object (unless we
 *   use the Candle subclass). Here we'll use a FueledLightSource to implement
 *   an oil lamp.
 */

+ oilLamp: FueledLightSource 'olje|lampa+n; fin+a gam:mal+la mässing'
    "Det är en fin gammal oljelampa i mässing. "
        
        
    /*  
     *   We'll start the lamp very low on oil, so we'll need to allow it to 
     *   be refueled. We'll assume it can be refuelled by pouring oil into 
     *   it, so we add an action handler for the PourInto action with the 
     *   lamp as the indirect object.
     */
        
    iobjFor(PourInto)
    {
        verify() 
        {
            if(fuelLevel == maxFuelLevel)
                illogicalNow('Oljelampan är redan full. ');
            if(isLit)
                illogicalNow('Du kan inte hälla något i lampan medan den är tänd. ');
        }
        check()
        {
            if(gDobj != oilCan)
                "Du skulle inte tillföra något! ";
        }
        action()
        {
            "Du häller så pass mycket olja i lampan så den fylls. ";
            fuelLevel = maxFuelLevel;
        }
    }
    
    /* Start the lamp off nearly out of fuel. */
    
    fuelLevel = 4
    
    /* 
     *   This is a custom property we are defining for our own use, not a 
     *   library property.
     */
    maxFuelLevel = 50
    
    /*  
     *   Our custom FueledLightSource class included a warningMessage method
     *   which we can override to display messages when the lamp is about to go
     *   out.
     */
   
   
    warningMessage()
    {
        switch(fuelLevel)
        {
            case 3: "<.p>Lampan börjar dämpas. "; break;
            case 2: "<.p>Lampan flimrar, då den är på väg att slocka. "; break;
            case 1: "<.p>Lampans låga flämtar; den är verkligen på väg att slockna. "; 
            break;
        }
    }
    
    /* Customize the message for the lamp running out of fuel. */    
    sayBurnedOut()
    {
        "Oljelampan flimrar till och slockar. ";
    }
;

//------------------------------------------------------------------------------

deadEnd: DarkRoom 'Återvändsgränd'
    "Passagen från den stora grottan mynnar snabbt ut i denna återvändsgränd. 
    Vägen tillbaka är österut. "
    east = largeCave
    out asExit(east)
;

+ oilCan: Thing 'olje|kanna+n;med[prep]; olje|kann:a^S+olja+n'
    initSpecialDesc = "En oljekanna vilar på golvet. "
    
    dobjFor(PourInto)
    {
        preCond = [objHeld]        
    }
    
    /* We use the fluidName property to name the fluid contained by or poured from the can.*/
    fluidName = 'olja'
    isPourable = true
;

//------------------------------------------------------------------------------

roundCave: DarkRoom 'Rund grotta'   
    "Grottan är i stort sett rund och ser ut som om den en gång i tiden haft 
    utgångar i alla riktningar, men stenras har blockerat alla utom två av 
    dem, de till öst och sydväst."
    east = squareCave
    southwest = largeCave
;

/*  
 *   FLASHLIGHT 
 *
 *   A Flashlight is a LightSource that can be turned on and off. 
 */

+ Flashlight 'fick|lampa+n; gam:mal+la svart+a plast; lykta+n' 
    "Det är en gammal svart plastficklampa. "
    initSpecialDesc = "En ficklampa ligger övergiven i mitten av grottan.
        "
;

/*  
 *   DECORATION 
 *
 *   Since we mentioned rockfalls in the room description we'll give them a 
 *   minimal implementation - as a Decoration.
 */

+ Decoration 'sten|ras+en; sten; utgångar; dem' 
    "Stenras blockerar alla utgångar förutom de till öst och sydväst. "    
;

//------------------------------------------------------------------------------

squareCave: DarkRoom 'Fyrkantig grotta'
    "Den här grpttan är så perfekt fyrkantig att du misstänker att den måste 
    vara artificiell.  Den enda utgången är till väst. "
    west = roundCave
    out asExit(west)
;

/*  
 *   OPENABLE CONTAINER 
 *
 *   Rather than leaving the crystal in plain view we'll put it in a box.
 */

+ OpenableContainer 'järn|låda+n; rostig+a gam:mal+la'
    "Den har börjat rosta. << moved ? '' : 'Den ser ut som kan ha stått här en bra tid'>>. "
    initSpecialDesc = "En järnlåda ligger inbäddad mot en vägg. "  
    //An iron box nestles against a wall.
;

/*  
 *   LIGHT SOURCE
 *
 *   A plain LightSource is a Thing that gives off constant light. To make 
 *   this one more interesting we'll make it light up only when it would 
 *   otherwise be dark.
 */


++ crystal: Thing 'magisk+a kristall+en; blå+a' 
    "Den <<isLit ? 'glöder med ett stadigt ljus' : 'har en matt blå färg'>>. "
    
    /* 
     *   After each turn when the crystal is in scope, check whether it 
     *   would be light if the crystal were not lit. If it would and the 
     *   crystal was previously unlit, report that the crystal has ceased to 
     *   glow. If it would be dark without the crystal and the crystal was 
     *   previously unlit, make it lit and report the fact.
     */
    afterAction()
    {
        /* Keep track of whether the crystal was lit when we started. */
        local wasLit = isLit;
        
        /* 
         *   Make it unlit so we can test what the light would be like 
         *   without it.
         */
        isLit = nil;
        
        /*   Then test the light level. */
        if(getOutermostRoom.isIlluminated)            
        {
            if(wasLit)
            {
               "Kristallen mattas av och slutar glöda. ";
               return;
            }
        }
        else if(!wasLit)
        {
            "Kristallen börjar glöda. ";
            isLit = true;
            return;
        }
        
        /* 
         *   Restore the crystal to its starting lit/unlit state if we didn't
         *   report any change.
         */
        isLit = wasLit;
    }
;

/*  
 *   STATES
 *
 *   The library defines lightSourceStateOn and lightSourceStateOff as the 
 *   States for a LightSource. Here we provide customized versions to 
 *   cater for the extra vocabulary (glowing, dim, dull) associated with the 
 *   two states/
 */

crystalLitUnlitState: State
    stateProp = &isLit
    adjectives = [[nil, ['dämpad', 'slö', 'släckt']], [true, ['glödande', 'tänd']]]
    appliesTo(obj) { return obj == crystal; }
;


/* 
 *   DARKROOM
 *
 *   The adv3Lite library doesn't define a DarkRoom class, but there's nothing
 *   to stop us defining our own, which may be convenient in a game with quite a
 *   few unlit rooms.
 */
class DarkRoom: Room
    isLit = nil
    regions = [caveRegion]
;

/* 
 *   REGION
 *
 *   Since all the DarkRooms in this game will be in the caves, we'll take the
 *   opportunity to demonstrate the use of a Region and illustrate the use of
 *   regionBeforeAction and regionAfterAction.
 */
caveRegion: Region
    regionBeforeAction()
    {
        if(gActionIs(Jump))
        {
            "Taket är för lågt här för att kunna hoppa; du kan råka slå i huvudet!";
            exit;
        }
    }
    
    regionAfterAction
    {
        if(gActionIs(Yell))
        {
            "Din röst ekar runt i grottan. ";
        }
    }
    
;


/*  
 *   FUELED LIGHT SOURCE
 *
 *   The adv3Lite library doesn't define a FueledLightSource class (to represent a light source with
 *   a limited life) as standard, but again, there's nothing to stop us defining our own, as here.
 *   Alternatively, we coulld use the FueledLightSource class provided by the Fuerled extension that
 *   comes with adv3Lite (but is not incldued in your game unless you explicitly add it).
 */

class FueledLightSource: Thing
    /* 
     *   The current fuelLevel of our light source, representing the number of
     *   turns until it burns out.
     *
     *   Note that while we're defining our own FueledLightSource class here we
     *   could instead use the one that comes in the Fueled Light Source
     *   extension.
     */
    fuelLevel = 10
        
    daemonID = nil
    
    /*   A method that runs every turn while we're lit. */
    burnDaemon()
    {        
        /* Display a message warning that we're about to burn out. */
        warningMessage();
        
        /* 
         *   Reduce the fuel level by one. If we're out of fuel, make us unlit
         *   and display a message saying we've gone out.
         */
        if(fuelLevel-- < 1)
        {            
            makeLit(nil);
            sayBurnedOut;
        }
    }
    
    /*  
     *   A warning message to display when we're running low on fuel. By default
     *   we do nothing here but specific instances can override this to display
     *   a warning message depending on the fuelLevel when the fuelLevel is
     *   running low.
     */
    warningMessage() {}
    
    /*   
     *   Override the standard library makeLit() method to carry out some
     *   additional handling based on fuelLevel.
     */
    makeLit(stat)
    {
        if(stat)
        {
            /* 
             *   If something wants to light us and we have no fuel, display a
             *   message saying we can't be lit instead.
             */
            if(fuelLevel < 1)
            {
                sayNoFuel();
                exit;
            }
            /*  Otherwise, if we're being lit, start our burn daemon */
            else if(daemonID == nil)
                daemonID = new SenseDaemon(self, &burnDaemon, 1);                
        }
        /* Otherwise, if we're being put out, stop our burn daemon */
        else if(daemonID != nil)
        {
            daemonID.removeEvent();
            daemonID = nil;
        }
            
        /*  Finally, carry out the inherited handling. */
        inherited(stat);           
    }
    
    /*  
     *   Display a message saying we won't light (because our fuel is exhausted)
     */
    sayNoFuel = "\^<<theName>> går ej att tända. "
    
    /*  Display a message to say we're going out when we're out of fuel. */
    sayBurnedOut = "\^<<theName>> slockar. "
    
    /*  We're definitely something that can be lit. */
    isLightable = true
    
    /*  
     *   But we may need an external light (of the naked flame sort) to light us
     *   with. If this flag is nil, we can be lit without the use of another
     *   light (flame) source.
     */
    needsExternalLight = true
    
    dobjFor(Light)
    {
        action()
        {
            /* 
             *   If we need an external light source to light us with, then ask
             *   which one to use (if there's only one possible candidate, the
             *   library will automatically pick it).
             */
            if(needsExternalLight)
                askForIobj(BurnWith);
            else
                /* 
                 *   othewise carry out the inherited handling (and make us
                 *   lit).
                 */
                inherited;
        }
    }
        
    /* Treat BURN ITEM as equivalent to LIGHT ITEM */
    dobjFor(Burn) asDobjFor(Light)
    
    /* Handling for lighting me with an external light source */
    dobjFor(BurnWith)
    {
        verify()
        {
            /* If I'm already lit there's no point trying to light me */
            if(isLit)
                illogicalNow('{Ref subj dobj} {är} redan tän{t/d/da}. ');           
        }
        
        action()
        {
            makeLit(true);
            "{Jag} {tänder} {ref dobj} med {ref iobj}. ";
        }
    }
    
    /*  
     *   All our FueledLightSources can be used to light other
     *   FueledLightSources with provided the FueledLightSource we want to light
     *   with is already lit itself.
     */
    iobjFor(BurnWith)
    {
        verify()
        {
            if(!isLit)
                illogicalNow('{Ref subj dobj} {kaninte} användas för att antända 
                någonting annat medan den inte själv är tänd. ');
        }
    }
;

/* A Matchstick is a FueledLightSource with a short life */
class Matchstick: FueledLightSource 'tänd|sticka+n;vanlig+a;tänd|stickor+na[pl]'
    "Det är bara en vanlig tändsticka<<if isLit>>, för 
    närvarande brinner den med en svag låg<<end>>. "
    
    /* A Matchstick won't stay alight very long */
    fuelLevel = 3
    
    sayBurnedOut()
    {
        "Tändstickan fladdrar till och dör <<if !getOutermostRoom.isIlluminated>>
        och du omfamnas av mörkret, <<end>>så du kastar bort den nu utbrända tändstickan.";
        
        /* 
         *   We assume there's not enough left of the burnt-out match to be
         *   worth keeping, so we just move it off-stage.
         */
        moveInto(nil);
    }
    
    /* 
     *   We don't need an external light source to light a match with (though we
     *   do need the matchbox to strike it against -- see below).
     */
    needsExternalLight = nil
        
    dobjFor(Examine) 
    {
        verify() {
            // För att inte blanda ihop med "asken med tändstickor" höjer vi rankningen 
            // vad vad spelaren menar då tändstickorna är med bland alternativen
            logicalRank(120); 
        }
    }
    dobjFor(Light)
    {
        /* 
         *   In order to light a match I must be holding both the match and the
         *   matchbox to strike it against.
         */
        preCond = [objHeld, new ObjectPreCondition(matchbox, objHeld)]
        
        action()
        {
            inherited();
            "Du tänder en tändsticka, och den fladdrar till liv med en svag låga. ";
        }
    }
;

/* 
 *   DOER
 *
 *   STRIKE MATCH means the same as LIGHT MATCH, so this Doer converts the first
 *   action into the second. By making the Doer 'strict', we prevent it
 *   operating on synonyms of STRIKE such as HIT MATCH or ATTACK MATCH; this
 *   Doer only takes effect if the Attack action is triggered through the
 *   command STRIKE.
 */     
     
Doer 'tänd Matchstick'
    execAction(c)
    {
        doInstead(Light, gDobj);
    }
    
    strict = true
;


//==============================================================================
/*   
 *   SUPPLYING THE AMUSING OPTION
 */
     

modify finishOptionAmusing
    doOption()
    {
        
        "Försök att hoppa och ropa i grottorna.\b";

        if(!oilCan.seen)
            "Försök att gå västerut från den stora grottan och se vad du hittar.\b";
        else if(oilLamp.fuelLevel < 5)
            "Försök att fylla på oljelampan.\b";
        
        "När du har återfått kristallen, försök att släcka alla andra 
        ljuskällor medan du fortfarande är i grottorna.\b";

        "Försök sedan att tända någon av dina andra ljuskällor igen.\b";        
        
        /* 
         *   this option has now had its full effect, so tell the caller
         *   to go back and ask for a new option 
         */

        return true;
    }
;



//==============================================================================
/*   
 *   MODIFYING A VERBRULE
 *
 *   At one point the game describes a gap the PC could squeeze through, so 
 *   it would be good to make SQUEEZE THROUGH a synonym for GO THROUGH. We 
 *   can do this either with a new VerbRule or by modifying an existing one. 
 *   Here we'll illustrate the second method.
 */

modify VerbRule(GoThrough)
    ('gå' | ( ('kläm'|'tryck'|'pressa') 'dig')) ('igenom' | 'genom')
        singleDobj
    :
;

/*  
 *   The player might type FILL LAMP WITH OIL instead of POUR OIL INTO LAMP; 
 *   defining the following VerbRule makes the two synoynmous. Note how we 
 *   fill the iobj and dobj roles in this new VerbRule: FILL X WITH Y is the 
 *   same as POUR Y INTO X, so in the FILL version the normal roles of 
 *   direct and indirect object are reversed from that of the normal way of 
 *   phrasing the PourIntoAction.
 */

VerbRule(FillWith)
    'fyll' ('på'|) singleIobj 'med' singleDobj
    : VerbProduction
    action = PourInto
    verbPhrase = 'fylla/fyller (vad) (med vad)'
    missingQ = 'vad vill du fylla; vad vill du fylla med'
;

/*  
 *   The player might also type just FILL LAMP; this VerbRule handles that by
 *   treating it as an incomplete PourIntoAction and prompting for what 
 *   should be used to fill it.
 */

VerbRule(FillWithWhat)
    [badness 500] 'fyll' singleIobj
    : VerbProduction
    action = PourInto
    /* 
     *   This verbPhrase looks back to front; this is a consequence of 
     *   reversing the normal dobj and iobj roles. If the player types FILL 
     *   LAMP, this VerbRule takes Lamp to be the Indirect object of a 
     *   PourInto command (effectively POUR SOMETHING INTO LAMP) and then 
     *   prompts for (or in this game, chooses a default) direct object. The 
     *   parser will then construct the default object announcement on the 
     *   assumption that the dobj comes before the iobj placeholder in the 
     *   verbPhrase string, but we want the iobj announcement to say 'filling
     *   with the oil lamp' not 'filling the oil lamp'.
     */
    verbPhrase = 'fylla/fyller (vad) (med vad)'
    missingQ = 'vad vill du fylla med; vad vill du fylla'
    askDobjResponseProd = withSingleNoun
    missingRole = DirectObject
    
;

