#charset "utf-8"

#include <tads.h>
#include "advlite.h"


/*   
 *   EXERCISE 15 - BOMB DISPOSAL
 *
 *   This game is primarily intended as a demonstration of FUSES and DAEMONS,
 *   but this these classes can hardly be demonstrated in the abstract, so 
 *   we embed the demonstration in a brief game. We also take the 
 *   opportunity to demonstrate the INITOBJECT, PREINITOBJECT, 
 *   COLLECTIVEGROUP and CONSULTABLE classes, all of which fit neatly in the 
 *   game, but don't obviously fit in any other demo.
 */




versionInfo: GameID
    IFID = 'a78974ac-6485-414a-92bc-72411c1a81f1'
    name = 'Exercise 15 - Bomb Disposal'
    byline = 'av Eric Eve (Översatt av Tomas Öberg)'
    htmlByline = 'av <a href="mailto:eric.eve@hmc.ox.ac.uk">Eric Eve</a>'
    version = '1'
    authorEmail = 'Eric Eve <eric.eve@hmc.ox.ac.uk>'
    desc = 'En demonstration av Fuse och Daemon klasserna (och även InitObject,
        PreinitObject, CollectiveGroup samt Consultable).'
    htmlDesc = 'En demonstration av Fuse och Daemon klasserna (och även
        InitObject, PreinitObject, CollectiveGroup samt Consultable).'
;

gameMain: GameMainDef
    /* Define the initial player character; this is compulsory */
    initialPlayerChar = me
    
    showIntro()
    {
        "Det var en till bombräd över London igår natt. Många hus skadades, 
        men i detta hus var det en bomb som misslyckades att explodera. Ditt 
        jobb är att desarmera den före den gör det. \b";
    }
;

/*   
 *   INITOBJECT
 *
 *   An InitObject is an object with an execute() method that's automatically
 *   invoked when the game starts, so it can be a useful place to put code 
 *   we want to execute at the start of the game. InitObject can be used as a
 *   standalone, or mixed in with some other class (typically to add 
 *   initialization behaviour to an object).
 *
 *   An InitObject is a good place to set up a Daemon we want to start at the
 *   beginning of the game, which is how we're using it here. In this case 
 *   we mix InitObject with a ShuffledEventList we'll use to display random 
 *   atmosphere strings. There are only two rooms in this game, and we want 
 *   these strings to be displayed in both of them, so this provides a good 
 *   alternative to using the atmosphereList properties of the individual 
 *   rooms.  
 */

/* 
 *   An InitObject is an object who execute() methos is executed at the start of the game. We use to
 *   it to create a Daemon (which cannot be done at PreInit),
 */
InitObject, ShuffledEventList
    [
        'Det hörs ett högt klirrande från en brandbil som skyndar nerför gatan. ',
        'Din sergeant sticker in huvudet genom dörren för att se hur det går för er.
            Du skickar bort honom igen; ni behöver inte båda bli sprängda om det här går fel. ',
        'Ett flygplan dundrar ovanför. ',
        'En siren tjuter i fjärran. ',
        'Någonstans i fjärran skäller en hund. ',
        'Du hör ljudet av springande fötter utanför huset. ',
        'Utanför huset ropar en polis till en grupp barn att hålla sig borta. '
    ]

    
    /*  
     *   DAEMON
     *
     *   The execute method is called when the game starts. The code in this 
     *   execute() method creates a Daemon that will run every turn. What 
     *   this Daemon will do is to call the doScript() method on self (i.e. 
     *   this object) every turn. We don't need to store a reference to this 
     *   Daemon since it will carry on running for as long as the game 
     *   continues.
     */
    
    execute() { new Daemon(self, &doScript, 1); }
        
    /*   
     *   Once we've displayed all these messages once, reduce their 
     *   frequency to 50%. We make the compiler do the work of counting the 
     *   number of items in the eventList; using the static keyword means 
     *   that the compiler will compute the value and store it in the 
     *   eventReduceAfter property, so the expression won't need to be 
     *   evaluated each time during game-play.
     */    
    eventReduceTo = 50
    eventReduceAfter =  static eventList.length()
;


/*   
 *   ONE_TIME_PROMPT_DAEMON
 *
 *   A PromptDaemon is a special kind of Daemon that runs every turn just 
 *   before the command prompt is displayed. A OneTimePromptDaemon is a 
 *   special kind of PromptDaemon that runs only once (and then disables 
 *   itself); it's useful to make something happen at the very end of a 
 *   single turn, or, as here, just before the first command prompt (after 
 *   the opening text and the room description have been displayed). Here We 
 *   use an InitObject to set up a OneTimePromptDaemon that displays a 
 *   message just before the first command prompt.
 */
InitObject
    execute() { new OneTimePromptDaemon(self, &toolMessage); }
    toolMessage = "Du lämnade din verktygsväska ute i hallen; du måste hämta dem 
                  när du har tagit en snabb titt på bomben. "
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
startRoom: Room 'Vardagsrum'
    "Vardagsrummet är ett kaos. Ett lager med dam och spillror 
    täcker allt, förmodligen nerduschat från det gapande hålet i taket. "
    north = lrDoor
    out asExit(north)
;

/* 
 *   The player character object. This doesn't have to be called me, but me is a
 *   convenient name. If you change it to something else, rememember to change
 *   gameMain.initialPlayerChar accordingly.
 */

+ me: Player 'du'          
;

+ lrDoor: Door 'dörr+en'
    otherSide = hallDoor
;


/*   
 *   INITOBJECT
 *
 *   Here we use InitObject combined with a physical game object to set up a 
 *   couple of Fuses associated with it.
 *
 *   A Fuse in adv3Lite is an event that executes at some specified number of 
 *   turns after it is first set up. Unlike a Daemon which executes every 
 *   turn (or every so many turns) it executes only once and is then removed.
 *
 *   Although a Fuse can be used for anything, the term naturally conjurs up 
 *   the idea of an explosion, and that's how we're using it here -- in 
 *   conjunction with a bomb!
 */
+ bomb: InitObject, Surface, Immovable 
    'bomb+en; oexploderad+e svart+a slätt+a; hölje+t uxb' 
    "Det är en lång best, med ett svart slätt hölje. <<cap.isIn(self) ? 
    'I ena änden sitter locket som täcker detonatorn. ' : ''>>"
    
    /*  This method will be called when the game starts. */
    execute()
    {
        /*   
         *   FUSE
         *
         *   The next statement sets up a Fuse that will call the explode() 
         *   method on the bomb in 25 turns from now. We need to store a 
         *   reference to the Fuse since we'll want to stop it if the player 
         *   succeeds in disabling the bomb before it explodes.
         *
         *   There are only two rooms in the game, and the player character 
         *   will be equally aware of the bomb exploding (and equally dead 
         *   as a result) whichever of the two rooms he's in when it goes 
         *   off, so a simple Fuse will do here (as opposed to a SenseFuse).
         */
        fuseID = new Fuse(self, &explode, 25);
        
        
        /*
         *   SENSEFUSE
         *
         *   A SenseFuse is much like a Fuse, except that anything it tries 
         *   to display when it executes is only displayed if the PC is in a 
         *   position to sense it. In this case we will make the bomb start 
         *   to tick louder after 20 turns (as a hint to the player that 
         *   time is running out), but obviously the player character won't 
         *   hear that unless he's in the same room as the bomb, so we use a 
         *   SenseFuse to ensure that the output from the Fuse is only 
         *   displayed if the player can hear the bomb at that point (this 
         *   is what the final two parameters define: self -- the object to 
         *   be sensed, and sound -- the sense in question). The first three 
         *   parameters have the same meaning as before; unless it's 
         *   disabled first this senseFuse will call ticking.louden() in 20 
         *   turns from the start of the game.
         */             
        senseFuseID = new SenseFuse(ticking, &louden, 20, &canHear);        
    }
    
    /*   
     *   fuseID and senseFuseID are custom properties we use to store 
     *   references to the Fuse and the SenseFuse. We need to store them 
     *   both so we can disable both fuses if the player succeeds in 
     *   defusing the bomb.
     */
    fuseID = nil
    senseFuseID = nil
    
    
    /*  
     *   A custom method which describes the explosion of the bomb and ends 
     *   the game in the PC's death when the bomb explodes. Note that this 
     *   can be called either as a result of the Fuse executing or as a 
     *   result of the PC cutting the wrong wire when attempting to defuse 
     *   the bomb.
     */
    explode()
    {
        "Med ett högt dån och ett moln av rök och flygande bråte exploderar
        bomben!\b";
        finishGameMsg(ftDeath, [finishOptionUndo]);
    }
    
    /*   
     *   The makeSafe() method is a custom method that disables both fuses 
     *   if and when the player manages to defuse the bomb.
     */    
    makeSafe()
    {
        fuseID.removeEvent();
        senseFuseID.removeEvent();
        fuseID = nil;
        senseFuseID = nil;
        
        /*   
         *   PROMPT DAEMON
         *
         *   A PromptDaemon is a special kind of Daemon that's called each 
         *   turn, just before the command prompt is displayed. Here we set 
         *   up a PromptDaemon to display a message to prompt the player to 
         *   leave the house (and so end the game) once the bomb has been 
         *   defused.
         */
        new PromptDaemon(self, &safeMessage);
    }
    
    /*   The message to display each turn once the bomb has been defused. */
    safeMessage = "<.p>Nu när du har desarmerat bomben är det bäst att du 
                    går ut och berättar för alla att det är säkert. "
     
    
    specialDesc = "En oexploderad bomb ligger i mitten av rummet. "
    listenDesc = ticking.desc
    
    /*   
     *   The lookUnderMsg is displayed in response to the command LOOK 
     *   UNDER THE BOMB. The manual (implemented below) provides hints that 
     *   the player needs to find this model number somewhere on the bomb 
     *   casing.
     */
    lookUnderMsg = 'På undersidan av höljet kan du precis uttyda tecknen ZP640. '
;

/*  We'll give this bomb a suitably menacing tick. */
++ ticking: Noise 'svag:t+a tickande ljud+et' 
    "<<if isEmanating>>Ett <<name>> kommer från bomben<<else>>Bomben har tystnat<<end>>. "
    
    /*  
     *   The ticking stops once the bomb has been defused. In adv3Lite
     *   isEmanating is a custom property we've defined for this object, not a
     *   property defined in the library
     */
    isEmanating = (bomb.fuseID != nil)
    
    /*  
     *   Make the ticking get louder. Change the name to 'loud ticking 
     *   sound' and amend the vocabulary to suit, then display a message to 
     *   say that the ticking has got louder.
     */
    louden()
    {
        replaceVocab('hög:t+a tickande ljud+et');
       
        "Bomben börjar plötsligt att ticka högre. ";
    }
   
    /* 
     *   If the ticking sound is still emanating and the player didn't
     *   explicitly issue a Listen command we'll display a message about the
     *   ticking of the bomb on each turn.
     */
    afterAction()
    {
        if(isEmanating && !gActionIn(Listen, ListenTo))
            desc;
    }
;


/*  To get at the detonator the PC first has to remove this cap. */
++ cap: Fixture 'metall|lock+et; rund+a svart+a metall|detonator+n' 
    "Det är ett runt metallock, svart såsom resten av bomben. "
    
    /* 
     *   To remove the cap the player character needs to turn it with his 
     *   spanner, so we need custom handling for the TurnWith handling.
     */
    dobjFor(TurnWith)
    {        
        verify() {}
        action()
        {
            "Du vrider {ref dobj} med {ref iobj}, och avlägsnar det från 
            bomben, vilket synliggör detonatorutrymmet (där du kan se fem 
            kablar: en röd, en gul, en grön, en blå och en svart). ";
            
            /*  
             *   Since the cap behaves rather differently once it's been 
             *   removed from the bomb, it's easier to implement it as two 
             *   different game objects (which will look like the same 
             *   object to the player). It would be possible to use a single 
             *   object, but probably messier and more bug-prone.
             *
             *   So when the cap is unscrewed, we need to replace it with the
             *   object representing the unscrewed cap.
             */
            moveInto(nil);
            cap2.moveInto(gActor);
        }
    }
 
    
    /*  
     *   Provide custom messages for some obvious actions that might be 
     *   tried on this cap.
     */
    cannotUnscrewMsg = 'Det går inte att göra det med dina bara händer. '
    cannotTurnMsg = (cannotUnscrewMsg)
    cannotTakeMsg = 'Det går inte; den är hårt fastskruvad. '
    cannotOpenMsg = 'Du behöver skruva loss det. '
    cannotPushMsg = (cannotOpenMsg)
    cannotPullMsg = (cannotOpenMsg)
    cannotMoveMsg = (cannotOpenMsg)
    
    isTurnable = nil
    
    /*  
     *   So far as the player is concerned, cap and cap2 are the same 
     *   object, so we make sure the parser knows this. This ensures that if 
     *   the player types TURN CAP WITH SPANNER followed by X IT, the 
     *   EXAMINE command will still work, even though cap will have been 
     *   replaced by cap2 in the course of carrying out the first command.
     */
    getFacets = [cap2]
;

/*  
 *   Implementing a container-like object that only becomes accessible (and 
 *   indeed, visible) once a cap or lid is removed is just a little tricky. 
 *   Here we do it with something that's a mix of several classes.
 *
 *   We're also making this an InitObject so that it can make a random 
 *   choice of which is the safe wire to cut at the start of the game.
 *
 *   We make the detonator a RestrictedContainer so that it can contain, and 
 *   if necessarily conceal, its existing contents (five wires), without 
 *   allowing anything else to be put in it.
 */
++ detonator: InitObject, Fixture, Container 
    'detonator|utrymme+t;;detonator|fack+et' 
    
    /*  
     *   The detonator compartment becomes accessible when the cap is removed.
     *   We can simulate that by making it hidden while the cap is on the bomb.
     */
    isHidden = (cap.isIn(bomb))
    
    /*  
     *   By making this Container open only when it is discovered, we ensure 
     *   that its contents are inaccessible only when the cap is removed. 
     *   Note that a Container can have an isOpen property even if it is not 
     *   an OpenableContainer; it can still be opened and closed under 
     *   program control, though not by the player issuing OPEN and CLOSE 
     *   commands.
     */
    isOpen = (!isHidden)

    /*  Choose a random wire to be the right one to cut. */
    execute()
    {
        /* 
         *   Normally we'd want this random choice to give a different 
         *   result each time, so we'd call randomize() to re-seed the 
         *   random number generator. But when we're testing it's useful if 
         *   the 'random' results are the same each time through, so we'll 
         *   exclude the call to randomize() from the debug build.
         */
      #ifndef __DEBUG
        randomize();
      #endif
        
        safeWire = rand(redWire, blueWire, greenWire, yellowWire, blackWire);
        safeWire.safeToCut = true;
    }
    
    safeWire = nil
    
    notifyInsert(obj)
    {
        "Det är bäst att inte stoppa in något där; du kan råka utlösa bomben! ";
        exit;
    }

;

/*  
 *   The contents of this detonator are fairly basic: we just put five 
 *   coloured wires there. The Wire class is defined below. 
 */

+++ redWire: Wire 'röd+a *'
;

+++ blueWire: Wire 'blå+a *'
;

+++ greenWire: Wire  'grön+a *'
;

+++ yellowWire: Wire 'gul+a *'      
;

+++ blackWire: Wire 'svart+a *'
;

/*   
 *   COLLECTIVE GROUP
 *
 *   We can use a CollectiveGroup to stand in for all five wires when the 
 *   player uses a command including the plural WIRES. This can often give a 
 *   better response than having the parser list a response for each 
 *   individual wire. 
 *
 *   We define wireGroup with only the plural vocabulary for wires. 
 */

+++ wireGroup: CollectiveGroup 'kablar+na[pl]'
    "Det är fem kablar i detonatorn: en röd, en gul, en grön, 
    en blå och en svart. <<detonator.safeWire.hasBeenCut ? '\^' +
      detonator.safeWire.theName + ' har klippts.' : ''>>"
    
    /*  
     *   Define which actions we want this CollectiveGroup to handle when the
     *   player directs a command to WIRES in the plural; all other commands
     *   will be handled by each of the individual wires.
     *
     *   We'll handle EXAMINE, CUTWITH, PULL, BREAK, MOVE, PUSH and TAKE
     */    
    
    collectiveActions = [Examine, CutWith, Pull, Break, Move, Push, Take]
    
    dobjFor(CutWith) 
    { 
        verify()         
        {
            /*  Warn the player that cutting all the wires would be fatal. */
            illogical('Om du klipper alla kablar kommer du säkerligen
             att detonera bomben. ');
        }
    }
    
    /*  
     *   Provide a suitable message refusing to TAKE WIRES, MOVE WIRES, PUSH 
     *   WIRES, PULL WIRES or BREAK WIRES. This is much neater than having 
     *   the parser respond with the same message five times over, once for 
     *   each wire.
     */
    dobjFor(Take) { verify() { illogical(Wire.cannotTakeMsg); } }
    dobjFor(Move) { verify() { illogical(Wire.cannotTakeMsg); } }
    dobjFor(Push) { verify() { illogical(Wire.cannotTakeMsg); } }
    dobjFor(Pull) { verify() { illogical(Wire.cannotTakeMsg); } }
    dobjFor(Break) { verify() { illogical(Wire.cannotTakeMsg); } }
;

/*   Define the custom Wire class. */
class Wire: Immovable 'kabel+n'
    "\^<<theName>> <<hasBeenCut ? 'har klippts' : 'är intakt'>>. "
    
    cannotTakeMsg = 'Du vet mycket väl att om du rör till någon av de 
                    där trådarna kan bomben explodera. '
    
    cannotCutMsg = 'Du {kaninte} klippa {ref dobj} med dina bara händer. '
    
    /* This is set on the 'right' wire to cut at the start of the game. */
    safeToCut = nil
    
    /* 
     *   Keep track of whether this wire has been cut so it can describe 
     *   itself accordingly.
     */
    hasBeenCut = nil    
    
    /*   Define the custom handling for CUT whichever WIRE (with cutter) */
    dobjFor(CutWith)
    {
        preCond = [touchObj]
        verify()
        {
            /*  
             *   Once it's been cut, there's no point in trying to cut it 
             *   again.
             */
            if(hasBeenCut)
                illogicalNow('{Ref subj dobj} har redan klippts. ');
        }
        action()
        {
            hasBeenCut = true;
            
            /*  
             *   If we're the safe wire, say so and make the bomb safe (stop 
             *   the fuses).
             */
            if(safeToCut)
            {
                "Du klipper {ref dobj} och bomben slutar att ticka. ";
                bomb.makeSafe();
            }
            else
                /* Otherwise, the bomb explodes. */
                bomb.explode();
        }
    }        
    
    /*  
     *   Although this is a Immovable, we want the wires to be listed 
     *   in response to LOOK IN DETONATOR.
     */
    isListedInContents = true
    
    /*  The CollectiveGroup object for all Wires. */
    collectiveGroups = [wireGroup]
;


+ Decoration 'lite skräp+et;;spillror+na[pl] damm+et'
    "Ett lager av damm och skräp täcker allt i rummet."
;

+ Decoration 'möbler+na[pl]; grå+a; stolar+na soffa+n bord+et;det dem' 
    "Hur möblerna än såg ut före bomben, är de grå av damm nu: bord, 
    stolar och soffa, alla lika förstörda. "
;

+ Distant 'tak+et; gapande; hål+et' 
    "Ett gapande hål i taket indikerar var bomben föll igenom innan den 
    landade på golvet och misslyckades med att explodera. "
    
    specialDesc = "Det är ett gapande hål i taket. "
;


   
    /*  Treat UNSCREW CAP WITH X as equivalent to TURN CAP WITH X */

Doer 'skruva loss cap med Thing'
    execAction(c)
    {
        doInstead(TurnWith, cap, gIobj);
    }
;

//------------------------------------------------------------------------------


hall: Room 'Korridor'
    "Denna lilla, trånga korridor är i linje med husets i övrigt blygsamma 
    proportioner. Ytterdörren är norrut, medan andra dörrar är till väst, 
    öst och syd och en trappa leder upp till våningen ovanför. "

    east() { "Det finns ingen anledning att gå in iandra delar av huset;
    bomben du är bekymrad över är i vardagsrummet, precis söderut. "; }
    west() { east; }
    south = hallDoor    
    up = hallStairs
    north = frontDoor
    out asExit(north)
    in asExit(south)
    
    
;

+ hallDoor: Door 'vardagsrums|dörr+en'
    otherSide = lrDoor
;

+ frontDoor: Door 'ytter|dörr+en'
    /* Don't let the PC leave until the bomb has been defused. */
    canTravelerPass(traveler)  {  return bomb.fuseID == nil; }
    explainTravelBarrier(traveler)
    {
        "Du går inte förrän du är säker på att bomben är säker! ";
    }
    
    /*  Once the player goes through the door, the game is over (and won). */
    noteTraversal(traveler)
    {
        "Du lämnar huset med vetskapen om att du har gjort ett bra jobb. Du är också ganska glad över att komma ut levande!\b ";
        finishGameMsg(ftVictory, [finishOptionUndo]);
    }
    
    /* 
     *   This door doesn't really go anywhere, but to satisfy the library and to
     *   allow the noteTraversal() method to execute to end the game, we can
     *   employ the trick of making this door its own other side.
     */
    otherSide = self
;

/*  
 *   StairwayUp with canTravelerPass restriction to make a flight of stairs that
 *   can't actually be climbed.
 */
+ hallStairs: StairwayUp 
    'trappor+na[pl];;trapp+an trapp|steg+en;det dem'
    
    canTravelerPass(traveler) { return nil; }
    explainTravelBarrier(traveler)
    {
        "Det går inte att veta vilken skada bomben gjorde när den föll genom 
        huset, så det är förmodligen inte säkert att gå upp; men det är 
        ingenting du behöver göra oavsett. ";
    }
;

/*   
 *   We put a rat in the hall to provide an example of a SenseDaemon, 
 *   although in practice if we really wanted a rat like this we'd probably 
 *   implement it a little differently (see the NPC demo: what we'd probably 
 *   do is to give the rat a HermitActorState that was also a 
 *   ShuffledEventList and we'd get the SenseDaemon behaviour for free).  
 */
+ rat: InitObject, Thing, ShuffledEventList     
    'råtta+n; li:ten+lla grå:tt+a; gnagare+n dägg|djur+et' 
    
    "Det är ett litet grått däggdjur. "
    
    /*   
     *   SENSEDAEMON
     *
     *   We use a SenseDaemon to display the messages describing what the 
     *   rat is doing since we only want these messages to appear when the 
     *   rat is in the same room as the PC.
     *
     *   Since rat is also an InitObject, its execute() method will be 
     *   called on the first turn. This method sets up a SenseDaemon (we 
     *   don't actually need to store a reference to it here, but we'll just 
     *   illustrate how it's done). The SenseDaemon will call the rat's 
     *   doScript method every turn, but will only display the output when 
     *   the rat can be seen by the PC.     
     */         
    execute() { daemonID = new SenseDaemon(self, &doScript, 1); }
    daemonID = nil

    eventList =
    [
        'Råttan blickar nyfiket upp på dig. ',
        'Råttan klapprar in i ett hörn. ',
        'Råttan klöser på ytterdörren. ',
        'Råttan gnager på golvet. ',
        'Råttan lägger sig ner. ',
        'Råttan närmar sig dig, nyfiket sniffandes. ',
        'Råttan springer runt i rummet, som om den jagas av en fantomkatt. ',
        'Råttan försöker gömma sig i en skugga. '
    ]
    eventReduceAfter = static eventList.length()
    eventReduceTo = 50
    
    /*  
     *   The following method will display "A rat has found its way into the 
     *   hall" the first time the rat is mentioned in the room description 
     *   and "The rat is still in the hall" each time thereafter.
     */
    specialDesc = "<<one of>>En råtta har letat sig in i <<or>>Råttan är fortfarande
        kvar i <<stopping>> hallen. " 
    
    cannotTakeMsg = 'Råttan klapprar iväg och undviker ditt grepp. '
    
    /* 
     *   It's not illogical to attempt to attack a rat; we'll just make it
     *   futile
     */
    isAttackable = true
    futileToAttackMsg = (cannotTakeMsg)
;

/*  The PC's bag of tools. */
+ blackBag: OpenableContainer 'svart+a påse+n'
    "Det är påsen som du alltid bär runt med ditt bombdetonatorkit i."
    owner = me
    specialDesc = "Din svarta påse ligger i mitten av korridoren, precis där du lämnat  den. "
;

++ spanner: Thing 'skiftnyckel+n; justerbar+a;' 
    "Den är justerbar och din upplevelse är att den vanligtvis vrider allt som kan vridas. "
    iobjFor(TurnWith)
    {
        preCond =[objHeld]
        verify() {}
    }
;

++ wireCutter: Thing 'avbitare+n'
    "Du har klippt många kablar med den och den har inte gjort dig besviken hittills. "
    iobjFor(CutWith)
    {
        preCond = [objHeld]
        verify() {}
    }
;


/*   
 *   CONSULTABLE
 *
 *   A Consultable is something we can look things up in, using commands like
 *   CONSULT MANUAL ABOUT BOMB or LOOK UP BOMBS IN MANUAL. It's an ideal 
 *   class to use for something like a bomb-disposal manual.
 *
 *   We also givee the manual a readDesc, both because it's obviously 
 *   something that the player might try to read, and also so that reading 
 *   can provide information on how to use it. 
 */
++ manual: Consultable 'bomb disposal manual; dark thick blue; book'      
    "Det är en tjock blå bok som blir tjockare för varje vecka som allt
    eftersom du och dina kollegor lär dig mer och mer om bomberna som 
    Luftwaffe fortsätter att släppa över Storbritannien. "
    
    readDesc =  "Manualen understryker att Luftwaffe fortsätter att byta 
    detonatorer på sina bomber med varje ny modell med det uttryckliga 
    syftet att göra livet svårt -- rentav osäkert -- för människor 
    som du. Det är viktigt att du fastställer vilken bombmodell det är 
    innan du vidtar någon åtgärd, annars kommer du förmodligen att spränga 
    dig själv i luften. När du väl har fastställt bombmodellen kan du slå 
    upp proceduren för att inaktivera den i den här manualen."
    
    /* 
     *   We'll make it that the PC has to hold the manual to read it (or look
     *   things up in it).
     */
    dobjFor(Read) { preCond = [objHeld] }
    dobjFor(ConsultAbout) { preCond = [objHeld] }     
        
;

/*   
 *   CONSULT TOPIC
 *
 *   We use ConsultTopics to implement the various items of information 
 *   contained in a Consultable (just as we use TopicEntries - AskTopic and 
 *   the like - to provide conversational responses for an NPC.
 *
 *   LOOK UP BOMB is an obvious thing for the player to try, so we'll start 
 *   by provided a response to that. We do that by matching this 
 *   ConsultTopic to the bomb object. We'll then simply repeat the response 
 *   you'd get from READ MANUAL. 
 */     
+++ ConsultTopic @bomb
    "<<manual.readDesc>>"
;

/*  
 *   Reading the manual tells the player that it's necessary to discover 
 *   which model of bomb we're dealing with, so the player might try LOOK UP 
 *   BOMB MODEL or LOOK UP MODEL OF BOMB or some variant of that. We'll 
 *   provide a response to this by matching this ConsultTopic on the tModel 
 *   topic (defined below). The response should nudge the player towards 
 *   trying to find a bomb model number on the casing.
 */     
+++ ConsultTopic @tModel
    "Enligt manualen så ska en bombs modellnummer vara antingen stämplat eller 
    graverat någonstans på höljet. " 

;


/*  
 *   LOOK UNDER BOMB reveals the model number to be ZP640, so we need to 
 *   provide a response to that which tells the player which wire to cut. We 
 *   could create another topic to match on, but instead we'll demonstrate 
 *   matching on a regular expression. If the regular expression syntax is a 
 *   bit baffling, don't worry about it too much: this one will match on 
 *   ZP640, or TYPE ZP640 or MODEL ZP640
 */
+++ ConsultTopic '(type|model){0,1}<space>*zp640'
    "Manualen föreslår att på en bomb av typen ZP640 behöver du klippa
    <<detonator.safeWire.theName>>. "
;

/*  
 *   We can also use regular expressions to match more general patterns. This
 *   ConsultTopic will match any purely numeric entry (e.g. LOOK UP 12345) 
 *   and display a response explaining that purely numeric codes are not used.
 */
+++ ConsultTopic +70 '^<digit>+$'
    "Det finns inget uppslag för det. Tyskarna verkar inte använda rent numeriska 
    koder för deras bomber; deras koder tenderar att antingen vara några enstaka
    bokstäver följt av några nummer eller några nummer följt av några bokstäver. "
    
;

/*   
 *   PREINIT OBJECT
 *
 *   The manual is described as being a thick one, so we might expect to find
 *   entries for bomb codes other than ZP640. This ConsultTopic will match 
 *   on any pattern consisting of 1-4 letters followed by 1-4 numbers, or 1-4
 *   numbers followed by 1-4 letters, so that the manual will seem to have 
 *   entries for a vast range of codes. It will then assign a random 
 *   description to the wire that would need to be cut for that kind of bomb.
 *
 *   One complication is that we don't want this ConsultTopic to match 
 *   ZP640, so we give it a lower matchScore than the ZP640 ConsultTopic (80 
 *   instead of the default 100, which is what the +80 in the template means).
 *
 *   The second complication is that if the player enters the same code 
 *   twice, s/he ought to see the same response. If we kept returning a 
 *   random description, then repeatedly looking up, say, PTR534 would tell 
 *   the player first to cut the green wire, then the pink wire, and then 
 *   the long wire (say) and this would look wrong. We therefore store the 
 *   random response this ConsultTopic gives in a LookupTable, so that if 
 *   the player subsequently looks up the same code, this ConsultTopic will 
 *   give the same response. 
 *
 *   That's where the PreinitObject comes in -- we use the execute() method 
 *   of PreinitObject to set up the LookupTable. A PreinitObject is much 
 *   like an InitObject except that its execute() method is run as the last 
 *   stage of compilation rather than at game setup. This means that the 
 *   results of the PreinitObject's execute() method are stored in the game 
 *   image file and don't have to be recomputed each time the game starts. 
 *   PreinitObjects can't be used to display anything or start up Fuses or 
 *   Daemons, but they can be used to perform calculations or, as here, set 
 *   up data structures. 
 */


+++ PreinitObject, ConsultTopic +80 
    '^(<alpha>{1,4}<digit>{1,4}|<digit>{1,4}<alpha>{1,4})$'
    "Manualen anger att den korrekta proceduren för att inaktivera bombtypen 
    <<gTopicText.toUpper>> är att klippa den <<wireDesc(gTopicText.toUpper)>>
    kabeln. "
    
    /* 
     *   The custom method we define to return an appropriate description of 
     *   the wire that needs to be cut for this type of bomb.
     */
    wireDesc(txt)
    {
        /* 
         *   First see if we've already stored an entry for this type of 
         *   bomb in our LookupTable.
         */
        local resp = descTab[txt];
        
        /*   
         *   If not, pick a random description from the list and enter it 
         *   into the LookupTable against this kind of bomb.
         */
        if(resp == nil)
        {
            resp =  rand('gröna', 'röda', 'blåa', 'orange', 'lila', 'svarta', 
                         'vita', 'grå', 'rosa', 'korta', 'långa', 'tjocka', 
                         'tunna', 'raka', 'krulliga');
            
            descTab[txt] = resp;
        }
        
        /*  Either way, then return the result. */
        return resp;
    }
    
    descTab = nil
    
    /*   
     *   Set up the LookupTable in Preinit and then populate it with a few 
     *   sample values.
     */
    execute()
    {
        descTab = new LookupTable(10, 20);
        /*  
         *   We don't really need these entries, but this illustrates how we 
         *   can set up data at Preinit; it also illustrates how a 
         *   LookupTable is used. We store an entry into a table by setting 
         *   tab[key] = value, and then retrieve it by asking for tab[key]. 
         */
        descTab['A1'] = 'bästa';
        descTab['M25'] = 'orbitala';
        descTab['K9'] = 'hundörade';
    }
;

/*  
 *   We've allowed MODEL ZP640 or TYPE ZP640 in addition to just ZP640 as a 
 *   possible target of a LookUp command that references the bomb we actually
 *   need. The following ConsultTopic uses a regular expression to trap 
 *   LOOK UP MODEL/TYPE anything else and show a message telling the player 
 *   simply to enter the code (and the format of codes expected) without 
 *   preceding it with MODEL or TYPE. We don't want this ConsultTopic to 
 *   match TYPE ZP640 or MODEL ZP640, though, so we give it a matchScore of 
 *   90 (lower than the default of 100 used on the ZP640 ConsultTopic).
 */
+++ ConsultTopic +90 '^(model|type).+'
    "Det finns ingen anledning att ange MODELL eller TYP, bara slå upp koden, 
    t.ex. LETA UPP RD99; observera att modellnumret för dessa tyska bomber 
    normalt är en till fyra siffror följt av en till fyra bokstäver, eller 
    en till fyra bokstäver följt av en till fyra siffror. "
;

/*   
 *   DEFAULT CONSULT TOPIC
 *
 *   Finally, we provide a DefaultConsultTopic to respond to anything not 
 *   covered by the foregoing ConsultTopics, e.g. LOOK UP GLOBAL WARMING or 
 *   CONSULT MANUAL ABOUT BAKED BEANS.
 */
+++ DefaultConsultTopic
    "Manualen har inget vettigt att säga om det. "
;

/*   The Topic object used above. */
tModel: Topic 'bomb|modell;modellens; modellens num:mer+ret';






//------------------------------------------------------------------------------

/*   
 *   The other object representing the cap, once it's been removed from the 
 *   detonator. For the most part it's just an ordinary Thing, which is given
 *   the same description as the cap.
 */
cap2: Thing 'metall|lock+et; metall (detonator+n)'
    "<<cap.desc>>"
    
    /* Let the parser know we're really the same physical object as cap. */
    getFacets = [cap]
    
    /* 
     *   Assume that PUT CAP ON BOMB means replace it on the detonator; in 
     *   which case we move the original cap object back to the bomb and 
     *   move cap2 back into nil.
     */
    dobjFor(PutOn)
    {
        action()
        {
            if(gIobj == bomb)
            {
                //"You replace the cap on the bomb. ";
                "Du sätter tillbaka locket på bomben. ";
                moveInto(nil);
                cap.moveInto(bomb);
            }
        }
    }
;