#charset "utf-8"

#include <tads.h>
#include "advlite.h"


/*   
 *   BEDSITTERLAND
 *
 *   A demonstration of adv3Lite Nested Rooms (non-Room Things that can contain
 *   actors and/or the player character).
 *.
 *
 *   This is only minimally a game; there's nothing for the player to do but try
 *   out the various kinds of Nested Room. The 'game' is also fairly minimal in
 *   that very little has been implemented apart from what's necessary to show
 *   the various Nested Room classes.
 */


versionInfo: GameID
    IFID = '9ac9903f-75b8-436f-b1c5-263427d1ea00'
    name = 'Exercise 18 - Bedsitterland'
    byline = 'av Eric Eve (Översatt av Tomas Öberg)'
    htmlByline = 'av <a href="mailto:eric.eve@hmc.ox.ac.uk">Eric Eve</a>'
    version = '1'
    authorEmail = 'Eric Eve <eric.eve@hmc.ox.ac.uk>'
    desc = 'En demonstration av nästlade rum i adv3Lite.'
    htmlDesc = 'En demonstration av nästlade rum i adv3Lite.'
;

gameMain: GameMainDef
    /* Define the initial player character; this is compulsory */
    initialPlayerChar = me
    
    showIntro()
    {
        "Den här sovsalen var den bästa inhysningen du kunde hitta med kort
        varsel; nu ser det ut som att du kommer att vara fast här 
        åtminstone de närmaste månaderna, så du kan lika gärna prova 
        möblerna.\b";
    }
;

//==============================================================================
/* 
 *   A MODIFICATION TO PLATFORM
 *
 *   By default the library enforces no reachability conditions when the 
 *   actor is in an ordinary Platform, but this can seem a bit 
 *   unrealistic. For example the standard library behaviour would allow the 
 *   PC to open the wardrobe while lying on the bed, and this is surely 
 *   rather implausible.
 *
 *   The following modification to Platform changes that behaviour by 
 *   making an actor leave a Platform in order to perform an action that 
 *   requires touching an object that's not in the Platform.
 * 
 */
 
modify Platform
     /* 
     *   Check whether the actor can reach out of this object to touch obj, if
     *   obj is not in this object.
     */    
    allowReachOut(obj) { return nil; }          
;


/* 
 *   ROOM
 *
 *   Starting location - we'll use this as the player character's initial
 *   location.  The name of the starting location isn't important to the
 *   library, but note that it has to match up with the initial location for the
 *   player character, defined in the "me" object below.
 *
 *   Our definition defines three strings.  The first string, which must be in
 *   single quotes, is the "name" of the room; the name is displayed on the
 *   status line and each time the player enters the room.  The second (which is
 *   option) is in single quotes and defines the vocab property for the room.
 *   The third string, which must be in double quotes, is the "description" of
 *   the room, which is a full description of the room.  This is displayed when
 *   the player types "look around," when the player first enters the room, and
 *   any time the player enters the room when playing in VERBOSE mode.
 *
 *   The name "startRoom" isn't special - you can change this any other name
 *   you'd prefer.  The player character's starting location is simply the
 *   location where the "me" actor is initially located.
 */
startRoom: Room 'Din sovsal' '() din sovsal;; rum+met'
    "Något man kan säga om det här rummet är att det är åtminstone någorlunda 
    stort. Den som möblerade det verkar ha varit tveksam om sovplatserna, 
    eftersom det förutom den vanliga sängen i ett hörn, finns en våningssäng 
    högt uppe på ena väggen, ovanför en kort träbänk. Som tur är är bänken inte
    det enda man kan sitta på, eftersom det också finns en bekväm fåtölj och en
    lång soffa. Det finns också ett stort skrivbord, placerat under en bokhylla 
    som är obekvämt högt uppe på väggen, och en inbyggd garderob som är 
    tillräckligt stor för att gå in i."
    
    north = door
        
;

/* 
 *   The player character object. This doesn't have to be called me, but me is a
 *   convenient name. If you change it to something else, rememember to change
 *   gameMain.initialPlayerChar accordingly.
 */

+ me: Player 'du'   
    "Du orkar inte se på dig själv just nu; du har sjunkit så lågt för att 
    hamna här! "
;


/*   
 *   DOOR
 *
 *   Even a bedsit must have a door, but we'll provide one that doesn't go 
 *   anywhere, giving a reason why the PC doesn't want to go out right now.
 */

+ door: Door 'dörr+en' 
    beforeTravel(traveler, connector)
    {
        if(connector == self)
        {
            say(cannotOpenMsg);
            
            exit;
        }
    }      
    
    isOpenable = nil
    cannotOpenMsg = '''Du vill inte gå ut just nu. Du kanske stöter på din 
        hyresvärdinna i hallen, och hon kommer bara att börja avkräva dig hyran! '''
    
    /* 
     *   This is the standard trick for a door that doesn't actually lead
     *   anywhere; it stops the library from warning us that we've forgotten to
     *   define the otherSide property on this Door.
     */
    otherSide = self
;



/*  
 *   CHAIR
 *
 *   A chair is something that you would normally sit on and possibly stand on.
 *
 *   Since adv3Lite doesn't track postures, it doesn't distinguish between
 *   objects you can stand on, sit on or lie on (platforms, chairs and beds),
 *   but simply uses the Platform class for all three. We'll make this Platform
 *   an Immovable, since it's not something the PC is meant to walk around with.
 */
 

+ armchair: Platform, Immovable 'fåtölj+en; armstöd+da neutral+a grå+a bekväm+a; 
                                stol+en möbler+na[pl] sitt|platser+na[pl]'

    "Den är i en naturlig grå färg, men ser bekväm nog ut. "
    
    cannotTakeMsg = 'Du kan ta fåtöljen med dig, men den skulle vara en klumpig 
                     sak att gå runt med, så du slipper helst. '
    
    /* 
     *   This chair isn't big enough to lie on. Although adv3Lite doesn't
     *   actually track postures, it does allow commands like STAND ON, SIT ON
     *   and LIE ON. While in reality these mean the same as GET ON, the
     *   player's choice of command may indicate the particular item of
     *   furniture s/he has in mind, so it can be useful to control which
     *   commands are applicable to which objects.
     */
    canLieOnMe = nil
;


/*   
 *   CHAIR 
 *
 *   By default a Chair cannot be lain on, but a sofa might be long enough to
 *   allow someone to lie on, so here we'll override allowedPosture to allow
 *   this. We'll make the sofa a Heavy as well, since something that size 
 *   would presumably be too heavy to pick up.
 */

+ sofa: Platform, Heavy 'soffa+n; lång+a; soffa+n möbler+na[pl] sitt|platser+na[pl]' 
    "Den rymmer lätt tre personer; alternativt har den gott om plats för dig att 
    sträcka ut dig på. "
    
    standOnScore = 90
   
;

/*  
 *   BED
 *
 *   A bed is something that you would normally lie on, although by default 
 *   you can also sit or stand on a Bed. Since people are more likely to sit 
 *   on a bed than stand on one, sitting is also among the obviousPostures 
 *   but standing is not. 
 *
 *   LIE ON BED is equivalent to GET ON BED.
 */


+ bed: Platform, Heavy 'säng+en; enkla; enkelsäng+en möbler+na[pl]' 
    "Det är bara en enkelsäng i standardstorlek, ungefär en meter bred och 
    två och en halv meter lång. Utrymmet under den upptas av en låda där 
    du kan förvara några av dina saker."

    lookUnderMsg = 'Utrymmet under sängen upptas av lådan.'
    
    /* 
     *   Although we're not really modelling postures, we can adjust the
     *   suitability of different Platforms for different commands, so here we
     *   can make the bed particularly suitable for lying on, less suitable for
     *   for sitting on, and even less suitable for standing on, while note
     *   ruling out any of these. The default value of each of these three
     *   scores would be 100. Adjusting these scores can help the parser's
     *   choice of object in cases of ambiguity.
     */        
        
    lieOnScore = 110
    sitOnScore = 90
    standOnScore = 80
;

/*  
 *   OPENABLE CONTAINER
 *
 *   Since we described the bed as having a drawer underneath, we should 
 *   implement it.
 */

++ drawer: OpenableContainer, Fixture 'låda+n; lång+a'    
    "Det hade varit mer logiskt att ha ett par lådor under sängen, men det 
    finns bara en. "
;

+++ pillow: Thing 'reserv|kudde+n'
    bulk = 3
;

/*  
 *   BOOTH
 *
 *   A Booth is something an actor can enter. By default GET IN BOOTH is 
 *   treated as STAND ON (i.e. IN) BOOTH, but sitting or lying are regarded 
 *   as both allowed and obvious.
 */

+ wardrobe: Booth, Fixture 'garderob+en; inbyggd+a vit+a vit|målad+e stor+a'     
    "Den är målad i vitt och är stor nog att gå in i. <<isOpen ? 'Inne i
        garderoben finns en metallskena. ' : ''>>"      
    
    isOpenable = true
    isOpen = nil
    
    /* 
     *   Force an actor inside the wardrobe to leave the wardrobe in order to
     *   reach (i.e. touch) anything outside it.
     */
    allowReachOut(obj) { return nil; }   
    
;

/*  
 *   Just to make a wardrobe slightly less boring, we'll put a couple of 
 *   things inside it.
 */

++ Surface, Fixture 'metall|skena+n; upphängning+en; metall|stång+en' 
    "Metallhängskenan löper längs hela garderoben. "
    
    notifyInsert(obj)
    {
        if(obj != hanger)
        {
            "Du kan inte placera <<obj.theName>> på skenan.";            
            exit;
        }           
    }    
    
;

+++ hanger: Thing 'tråd|galge+n;; kläd|hängare+n'
    
;



/*  
 *   PLATFORM
 *
 *   A Platform is something one would normally stand on, although one could 
 *   equally well sit or lie on it. 
 *
 *   GET ON PLATFORM is treated as equivalent to STAND ON PLATFORM
 *
 *   To make it a bit more interesting, we'll make our first example of a 
 *   Platform a desk which things can be put under as well as on top of 
 *   (although one might normally think of a Desk as a Surface, it's usually 
 *   possible to sit or stand on a desk, and even to lie on it if it's big 
 *   enough). To allow this we need to make the desk itself a 
 *   Multiplex Container and attach the Platform to its remapOn.
 */


+ desk: Heavy 'skriv|bord+et;; möbler+na[pl]' 
    remapOn: SubComponent, Platform
    {       
        /* 
         *   We must be able to reach the bookshelf and anything on the
         *   bookshelf from the desk, or else we'll defeat the obiect of making
         *   the bookshelf only reachable from the desk.
         */   
        allowReachOut(obj)
        {
            return obj.isOrIsIn(bookshelf);
        }
        
        
    }
    remapUnder: SubComponent {  }   
;

++ ladder: Platform 'kort+a stege+n; trä+iga av[prep] trä+d'
    
    /* 
     *   Put the ladder under the desk. Note the special syntax for placing 
     *   something within a subXXXXX of a ComplexContainer.
     */
    subLocation = &remapUnder // or just sLoc(Under)
    
    /*  
     *   Normally you can sit, stand, or lie on a Platform, but in the case 
     *   of a ladder its only standing that makes much sense.
     */
    canSitOnMe = nil
    canLieOnMe = nil
        
    
    /*   
     *   It would be natural to try to climb, climb up or climb down a 
     *   ladder, so we redirect these actions appopriately.
     */
    dobjFor(Climb) asDobjFor(StandOn)
    dobjFor(ClimbUp) asDobjFor(StandOn)
    dobjFor(ClimbDown) asDobjFor(GetOff)
    
    /*   
     *   Add a custom property to keep track of the notional position of the 
     *   ladder.
     */    
    leaningAgainst = nil
    
    /*   
     *   We'll only allow the ladder to be used to reach the bunk when it's 
     *   leaning against the bunk, so we need to provide an action that 
     *   allows the player to put the ladder in the appropriate place. We'll 
     *   use MoveTo.
     */
    
    dobjFor(MoveTo)
    {
        action()
        {
            if(gIobj == bunk)
            {
                actionMoveInto(bunk.location);
                leaningAgainst = bunk;
                "Du lutar stegen mot våningssängen. ";
            }
            else
                inherited;
        }
    }
    
    /*  
     *   Whenever the ladder is taken, it can no longer be leaning against 
     *   the bunk (or anything else), so we need to override the action 
     *   handling for Take accordingly.
     */
    
    dobjFor(Take)
    {
        action()
        {
            inherited;
            leaningAgainst = nil;
        }
    }
    
    /*  If the ladder is in position, make UP equivalent to STAND ON LADDER */
    
    beforeAction()
    {
        if(gActionIs(Up) && leaningAgainst != nil)
            replaceAction(StandOn, self);
    }
    
    /* 
     *   The purpose of the ladder is to enable the player character to 
     *   reach the bunk. We need to make sure we can touch the bunk (which 
     *   is outside us) when we're the staging location for the bunk. Here 
     *   we generalize the code to allow an actor inside us to touch 
     *   anything for which we are a staging location.
     */    
    
    allowReachOut(obj)
    {
        /* 
         *   Note that we can't be sure that the object we're trying to touch
         *   will have a stagingLocations property. By using the nilToList 
         *   function we avoid the run-time error that would otherwise occur 
         *   if we tried this test on a dest object for which 
         *   stagingLocations is nil.
         */
        return obj.stagingLocation == self;    
    }
    
;

/*  
 *   PUTTING SOMETHING OUT OF REACH
 *
 *   To make something out of reach we can use its checkReach() method. Here we make the bookshelf
 *   (and its contents) out of reach to any actor who isn't on the desk (or rather, in the desk's
 *   Platform subcomponent.
 */


+ bookshelf: Surface, Fixture 
    'bok|hylla+n; lång+a trä+d av[prep];'
    "Det är en lång bokhylla i trä, monterad alldeles för högt upp på 
    väggen för enkel åtkomst. "
    
    /* 
     *   Define the conditions under which this object can be 
     *   reached. sctor is the object attempting the reaching -- typically an 
     *   actor. An actor can reach this shelf if s/he's standing on the 
     *   desk, so we need to test both that the actor is is on the desk.
     */
    checkReach(actor)
    {
        if(!actor.isIn(desk.remapOn))
            "Du kan inte nå hyllan härifrån. ";
    }
        
;

/*  
 *   READABLE
 *
 *   To demonstrate putting something out or reaach fully we need to put something on the bookshelf,
 *   and the obvious thing to put there is a book.
 */ 

++ book: Thing 'röd+a bok+en'
    "Det heter <i>Livet i Sovrumslandet</i>. "
    readDesc = "Du slutar läsa efter några sidor. Självklart återger boken någon
        annans upplevelse av livet i sovrumslandet, men att framtidsutsikten de 
        närmaste månaderna ska visa sig vara något liknande för dig är bara för 
        deprimerande. "
        
    /*  
     *   One would normally hold a book in order to read it, and if we don't 
     *   enforce either objHeld or touchObj here, the player would be able to
     *   read the book without taking it off the shelf.
     */
    dobjFor(Read) { preCond = [objHeld] }
;


/*   
 *   CHAIR
 *
 *   So far all our examples of Nested Rooms have been NonPortable, but a 
 *   Nested Room can also be portable, as the following Chair object 
 *   demonstrates.
 */


+ Platform 'snurr|stol+en; svart+a; möbler+na[pl] sitt|platser+na[pl]' 
    "Den är svart, och den snurrar. "
    specialDesc = "En snurrstol har placerats precis bredvid skrivbordet. "
    
    /*  
     *   Since it's described as a swivel chair we'd better allow the player 
     *   to turn it.
     */    
    dobjFor(Turn)
    {
        verify() {}
        check() {}
        action()
        {
            "Du snurrar runt stolen några gånger. Så spännande! Vad kul! ";
        }
    }
    
    /* 
     *   A swivel chair might not be all that safe to stand on, so we'll 
     *   restrict the allowedPostures to sitting.
     */    
    canStandOnMe = nil
    canLieOnMe = nil
    
    cannotStandOnMsg = 'Eftersom snurrstolen snurrar så lätt är den inte 
        säker att stå på. '
;

/*  
 *   MAKING A NESTED ROOM TOO HIGH TOO REACH
 *
 *   We can created a nested room that's regarded as being too high up to reach
 *   except via a special staging location (such as a ladder). The example here
 *   is a bunk high up on the east wall which can only be reached via the ladder
 *   once the ladder has been placed against the bunk.
 */

+ bunk: Platform, Fixture 'smal+a vånings|säng+en; hård+a; sängar+na[pl] brits+en slaf+en slafar+na[pl]'
    "Den är ganska smal och ser lite hård ut, men den skulle åtminstone göra det 
    möjligt för dig att få en besökare att stanna. Den är också ganska högt upp 
    på väggen. "
    
    /* 
     *   Normally you could stand on a bed, but there's not enough headroom 
     *   above the bunk.
     */
    canStandOnMe = nil
    cannotStandOnMsg = 'Det finns inte tillräckligt med takhöjd för att stå här. '
    
    /*  
     *   To reach this high nested room an actor has to be the appropriate staging location, so the
     *   stagingLocation property defines how the bunk can be reached. We define stagingLocation so
     *   that the ladder can only be used as a staging location when it's in the right state
     *   (leaning against the bunk).
     */
    stagingLocation = (ladder.leaningAgainst == self ? ladder : nil)
    
    checkReach(actor)
    {
        if(actor.location != stagingLocation)
            "Våningssängen är för hög för att nås. ";
    }
    
    
    /*  
     *   In order to get the ladder into the right state the bunk must be a 
     *   possible target of a MoveTo command.
     */    
    iobjFor(MoveTo) 
    { 
        preCond = [objVisible]
        verify() {} 
    }
    
    

    
    lookUnderMsg = 'Under våningssängen finns en kort träbänk och en sovande katt. '
;

+ Decoration 'norr+a vägg+en; (n)'
    "En smal våningssäng har fästs högt uppe på norra väggen, med en kort träbänk under. "
;


/* 
 *   CHAIR 
 *
 *   Since the bunk is high up on the wall, we may as well put something 
 *   underneath it.
 */

+ bench: Platform, Fixture 'bänk+en; kort+a trä+iga; stolar[pl] möbler+na[pl] 
    sitt|platser+na[pl]'     

    "Ärligt talat är du inte säker på vad den gör där; den ser varken bekväm 
    eller dekorativ ut. Din bästa gissning är att det en gång fanns en 
    underslaf som sedan länge har tagits bort och någon satte dit bänken 
    för att ta upp utrymmet (och/eller täcka över ett märke på väggen). "
    
    canSitOnMe = true
    canLieOnMe = true
    lieOnScore = 80
    
    cannotTakeMsg = 'Den verkar vara fixerad på stället. '
    cannotStandOnMsg = 'Det finns inte tillräckligt med plats att stå på bänken; 
        du skulle slå huvudet i slafen ovanför. '
;


/*  
 *   CAT
 *
 *   Finally, the cat that's mentioned as sleeping under the bunk. Since it
 *   stays asleep during the course of the game its implentation can be fairly
 *   minimal.
 */

+ cat: Immovable 'katt+en; svart+a sovande sover; 
    djur+et katt|hane+n han|katt+en som[prep]; honom det'

    "Det är en svart katt, som för närvarande ser ut att vara i djup sömn. "
    
    /*  
     *   Obviously it's possible to pick up a cat, so we'll customise the 
     *   cannotTakeMsg.
     */
    cannotTakeMsg = 'Det vore snällare att låta sovande katter ligga ifred. '
    
    /*  
     *   By setting owner = me we ensure that the parser will recognize 'your
     *   cat' or 'my cat' as referring to the cat.
     */
    owner = me
    
    
    /*  
     *   We'll also have the cat referred to as 'your cat' rather than 'the 
     *   cat'
     */
    theName = 'din katt'
    
    /*   
     *   Throwing something at the cat would wake it up, which we don't want;
     *   also the default response for throwing things can look rather 
     *   ludicrous when the target is animate. So we'll override 
     *   iobjFor(ThrowAt) to disallow this, using the same failure message 
     *   as for take.
     */    
    iobjFor(ThrowAt)
    {
        check()
        {
            say(cannotTakeMsg);
        }
    }
    
    cannotAttackMsg = 'Du vill hellre inte det; du är faktiskt rätt§ förtjust i
                      din katt, och han är i stort sett den enda vän du har här. '
    
    specialDesc = "Din katt sover under våningssängen. "
;


//==============================================================================
/* Modifying verb grammar */

/*   
 *   MOVE LADDER TO BUNK might not be the most obvious phrasing, so we'll add
 *   some alternative phrasings in a new VerbRule, but still assign them to 
 *   the MoveTo action.
 */


VerbRule(LeanAgainst)
    'luta' singleDobj ('på' | 'mot') singleIobj 
    | ('lägg'|'placera') singleDobj 'mot' singleIobj
    : VerbProduction
    action = MoveTo
    verbPhrase = 'luta/lutar (vad) (mot vad)'
    missingQ = 'vad vill du luta; vad vill du luta mot'
;

/*  
 *   Since we have an object called a swivel chair it seems likely that a 
 *   player might try to SWIVEL it, so we'll add 'swivel' to the standard 
 *   grammar for TurnAction.
 *
 *   Note the slightly unusual syntax for modifying a VerbRule, with the 
 *   colon after the grammar definition line. In this case the original 
 *   VerbRule(Turn) was copied and pasted from en_us.t and 'swivel' simply 
 *   added. 
 */         

modify VerbRule(Turn)
    ('vrid' | 'rotera' | 'snurra') multiDobj
    :
;

/* 
 *   There's no particular reason why we modified VerbRule(Turn) and added a 
 *   new VerbRule(LeanAgainst), other than to illustrate both methods; but 
 *   the fact that just adding 'swivel' was a simpler change than the 
 *   additional grammar for MoveToAction helped determine that we did it 
 *   this way round.
 */


/*  
 *   There's a bed here, to the player might reasonably try to sleep. If the PC
 *   is not already on the bed when the command is issued, it makes sense to
 *   move him/her there with an implicit command first.
 */

modify Sleep
    execAction(cmd)
    {
        if(!me.isIn(bed))
        {
            tryImplicitAction(LieOn, bed);
            "<<buildImplicitActionAnnouncement(me.isIn(bed))>>";
        }
        "Du somnar och drömmer om bättre tider. Du vaknar sedan upp 
        igen efter en obestämd tid har gått. ";
    }
;