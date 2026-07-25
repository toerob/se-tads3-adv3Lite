#charset "utf-8"

#include <tads.h>
#include "advlite.h"

/*
 *   SENSE & SENSIBILITY
 *
 *   A demonstration of Senses, SenseRegions, MultiLocs and the like.
 */

versionInfo: GameID
    IFID = '0c5628bc-e220-496d-ac6d-10dcadcb7015'
    name = 'Övning 21 - Förnuft och Känsla'
    byline = 'av Eric Eve (Översatt av Tomas Öberg)'
    htmlByline = 'av <a href="mailto:eric.eve@hmc.ox.ac.uk">Eric Eve</a>'
    version = '1'
    authorEmail = 'Eric Eve <eric.eve@hmc.ox.ac.uk>'
    desc = 'En demonstration av Senses, Multilocs och liknande i adv3Lite.'
    htmlDesc = 'En demonstration av Senses, Multilocs och liknande i adv3Lite.'
;

gameMain: GameMainDef
    /* Define the initial player character; this is compulsory */
    initialPlayerChar = me
    
    showIntro()
    {
        "Det ser ut som en fin dag nu, men det har varit flera dagar 
        med utomordentligt kraftigt regn. Vattnet öser nu ner från kullarna, 
        vilket gör att floden sväller, och flera allvarliga 
        översvämningsvarningar är utfärdade. Ditt jobb är att säkerställa 
        att det inte finns någon kvar i den här delen av staden. \b";
    }
;

/*  
 *   CUSTOM SOUND EVENT CLASS
 *
 *   We define a custom SoundEvent class to allow certain objects to respond to
 *   'sound events' that are triggered in their hearing. An alternative would
 *   have been to use the SoundEvent class defined in the sensory.t extension,
 *   but here we show how to build one from scratch.
 */
class SoundEvent: object
    /* 
     *   Triggering a sound event causes the notifySoundEvent() method to be
     *   called on every object that can hear its source (provided in the obj
     *   parameter). Most objects don't define (our custom) notifySoundEvent()
     *   method, so this will mostly do nothing, but a couple of objects below
     *   do.     
     */
    triggerEvent(obj) 
    {
        /* Get a list of everything in obj's Room */
        local lst = obj.getOutermostRoom.allContents;
        
        /* Add all the items in rooms with an audio connection to obj's room */
        foreach(local rm in obj.getOutermostRoom.audibleRooms)
            lst = lst.appendUnique(rm.allContents);
        
        /* 
         *   Reduce the list to the subset of objects that can actually hear obj
         */
        lst = lst.subset({o: Q.canHear(o, obj)});
        
        /*   
         *   Call the notifySoundEvent event method on every item in our reduced
         *   list.
         */
        foreach(local cur in lst)
            cur.notifySoundEvent(self, obj);    
        
    }
;
/* 
 *   REGIONS
 *
 *   We define a couple of regions; an outdoorRegion to represent every room
 *   that's outdoors, and a squareRegion that's a SenseRegion containing every
 *   room in the square.
 */

outdoorRegion: Region
;

/*  
 *   SENSE REGION
 *
 *   A SenseRegion is a region with sensory connections between its rooms. The
 *   squareRegion is also in the outdoorRegion (all the rooms in the square are
 *   oudoors).
 */
squareRegion: SenseRegion
    regions = [outdoorRegion]
;

/*  
 *   We'll define a custom SquareRoom class to save ourselves a bit of 
 *   typing on each of the rooms representing the four corners of the square.
 */

class SquareRoom: Room
    /* 
     *   corner is a custom property. It will be used to hold a string saying
     *   which corner of the square this is: northeast, northwest, 
     *   southeast, or southwest.
     */
    corner = ''
    
    /*   
     *   We next use the custom corner property to construct the destName (a 
     *   standard library property) of this square).
     */
    vocab = ('det ' + corner + ' hörnet av torget')
      
    
    regions = [squareRegion]
;





//------------------------------------------------------------------------------
/*  
 *   We now create a square comprising four corners. These will be joined by 
 *   a SenseRegion (see below) so that the player character can see 
 *   from any part of the square into any other part.
 */

squareNW: SquareRoom 'Stora torget (NV)'
    "Detta torg sägs vara från 1300-talet, och av de omgivande byggnadernas 
    skick kan man mycket väl tro på detta. Torget fortsätter söderut och 
    österut, med en stor prydnadsfontän i mitten av torget som blockerar 
    vägen diagonalt över torget i sydost.
    En lång byggnad löper längs torgets norra sida; dess ingång är österut, 
    även om ett litet fönster har utsikt över detta hörn av torget.
    Västerut ligger vägen in i parken. "
    
    corner = 'nordvästra'
    south = squareSW
    east = squareNE
    west = parkS
    
    /*  
     *   Below we shall be defining a SenseConnector representing a window 
     *   between this room and a chamber in the building to the north. This 
     *   means that when the PC is in squareNW objects inside the chamber 
     *   will also be listed. To make it clear where they are and how the PC 
     *   can see them we want them to be listed specially, preceded by 
     *   "Through the window, you see...". We do this be overriding 
     *   remoteRoomContentsLister().
     */
    
    remoteContentsLister() 
    { 
        if(gPlayerChar.isIn(chamber))
            
            /*  
             *   CUSTOM ROOM LISTER
             *
             *   A lister that can be customized very simply by supplying two
             *   strings: a prefix string that comes before the list of 
             *   objects listed in the other location (here 'Through the 
             *   window you see') and a suffix string that comes after it 
             *   (here just a full-stop/period).
             */
            return new CustomRoomLister('Genom fönstret, {ser} {jag}'); 
        else
            return inherited;
    } 
    
    regions = [squareRegion, windowRegion]
;

/* 
 *   The player character object. This doesn't have to be called me, but me is a
 *   convenient name. If you change it to something else, rememember to change
 *   gameMain.initialPlayerChar accordingly.
 */

+ me: Player'du'  
    "Du är en ung polis. "    
;


+ Fixture 'byggnad+en; gamm:al+la förfallande'
    "Den är väldigt gammal och ser lite sönderfallande ut, men den har legat 
    där i flera århundraden och kommer förmodligen att finnas kvar i flera 
    århundraden framöver. Omedelbart norrut vetter ett fönster ut från 
    byggnaden över torget. "
;

//------------------------------------------------------------------------------

squareNE: SquareRoom 'Stora torget (NE)'
    "Från detta hörn av torget leder en dörr in i byggnaden mot norr. Torget 
    fortsätter söderut och västerut, med fontänen i mitten mot sydväst. "

    corner = 'nordöstra'
    south = squareSE
    west = squareNW
    
    north = doorOutside
;

+ Enterable 'building; grand'
    "Byggnaden löper längs hela torgets norra sida och ser ganska ståtlig ut, 
    på ett något blekt slags sätt. Dörren in till byggnaden är bara strax norrut. "
    
    connector = doorOutside
;

++ doorOutside: Door ->doorInside 'dörr+en;;ingång+en'
;

//------------------------------------------------------------------------------

squareSW: SquareRoom 'Stora torget (SW)'
    "Huvudgatan ut från torget går söderut härifrån. Torget fortsätter norrut 
    och österut. Fontänen i mitten av torget blockerar vägen nordost. "
        
    corner = 'sydvästra'
    north = squareNE
    east = squareSE
    south {  "Du kan inte gå härifrån förrän du har försäkrat dig om att du 
        säkert fått bort alla från området. ";
    }
;

/*  
 *   TRAVEL PUSHABLE
 *
 *   A Travel Pushable is an object that can be pushed from one location to
 *   another but not picked up and carried. We make an ordinary object into a
 *   Travel Pushable by defining its canPushTravel property to be true.
 */
+ barrelOrgan: Heavy 'pip|orgel+n; prålig+a röd+a'
    "Den är målad i en prålig röd färg och har ett handtag som kan vridas för 
    att dra igång en melodi. "
    
    /* 
     *   A Heavy is would nor normally be listed in a room description, but
     *   since this one is moveable we'd like it to be, so we override isListed
     *   to make it so.
     */
    isListed = true
    
    
    canPushTravel = true    

    /* 
     *   By overriding this method we can customize the message used to announce
     *   the barrel organ's arrival in its new location.
     */
    describeMovePushable (connector, dest)
    {
        "Piporgeln saktar ner och stannar. ";
    }
    
;

++ handle: Component 'hand|tag+et' 
    dobjFor(Turn)
    {
        verify() { }
        action()
        {
            "Du vrider på handtaget på piporgeln några gånger; den vevar ut
            en väsande version av någon Verdi-aria. ";
            
            /* When the music plays, trigger the associated SoundEvent. */
            organEvent.triggerEvent(self);
        }
    }
;

/* This DOER turns PLAY ORGAN into TURN HANDLE */
Doer 'spela barrelOrgan'
    execAction(c)
    {
        doInstead(Turn, handle);
    }
;

/* 
 *   The SoundEvent that's triggered by playing the organ. SoundEvent is a
 *   custom class we defined above.
 */
organEvent: SoundEvent;

//------------------------------------------------------------------------------
squareSE: SquareRoom 'Stora torget (SE)'
    "En lång träbänk står i torgets sydöstra hörn, till förfogande till dem 
    som vill vila benen. Torget fortsätter norrut och västerut, men direkt 
    tillgång till det nordvästra hörnet härifrån är blockerat av fontänen i 
    mitten av torget. "

    corner = 'sydöstra'
    north = squareNE
    west = squareSW    
;

+ bench: Platform, Heavy 'bänk+en; lång:t+a väderbit:et+na trä+t'
    "Den ser ut att vara väl väderbiten, och du minns vagt att den placerades 
    där till minne av någon värdig lokalinvånare i början av förra seklet. "

    bulkCapacity = 30
      
;

/*   
 *   ACTOR 
 *
 */
++ oldLady: Actor 'gam:mal+la dam+en; förvirrad+e; kvinna+n någon person+en; henne'     
    "Hon ser ganska förvirrad ut. Man kan undra om hon är lika gammal som bänken hon 
    sitter på."
    
    
    /*  
     *   The notifySoundEvent method is where we put the code defining the old
     *   lady's response to a SoundEvent.
     */
    notifySoundEvent(event, source) 
    { 
        /*  
         *   We'll make the old lady's response differ according to whether 
         *   the source of hand is close by or in a different corner of the 
         *   square.
         */
        if(source.isIn(getOutermostRoom))
            /* 
             *   There are a number of different soundEvents in the game, 
             *   and we'd like them to provoke different responses. We could 
             *   do this with a series of if statements or a switch 
             *   statement here, but it's neater and more in common with 
             *   TADS 3 programming style to farm actor responses out to 
             *   TopicEntry objects as possible, and we can do that by 
             *   calling initiateTopic here and defining the different 
             *   responses on a series of InitiateTopics.
             */
            initiateTopic(event);
           
        else
        {
            "<.p>Kvinnan rycker till, vaknar till ett ögonblick och ser 
            förvirrad ut, sedan lägger hon sig ner för att sova igen. ";
        }
    }
    cannotAttackMsg = 'Du kommer att bli avskedad från polisen och förlora din pension om du 
        börjar attackera gamla damer. '

    /* 
     *   Override the normal handling of greeting an Actot to have this old lady ignore the player
     *   character.
     */
    sayHello = "Den gamla damen sover djupt." 
;

/*   
 *   ACTOR STATE
 *
 *   We could almost use a HermitActorState here, except that we want the 
 *   InitiateTopics to work.
 */

+++ ActorState
    /*  The old lady starts out in this ActorState. */
    isInitState = true
    
    /*  This will be appended to her description. */
    stateDesc = "Hon ser djupt sovande ut. "
    
    /*  
     *   This is how she will be listed in a room description when the player
     *   character is in the same room as her.
     */
    specialDesc = "En gammal dam sover på bänken.<.reveal dam>"
    
    /*   
     *   This is how she will be listed in a room description when the PC is 
     *   in a different part of the square.
     */
    remoteSpecialDesc(actor) 
    { 
        /*  
         *   When the PC first sees the old lady from a distance, it's not 
         *   clear who or what she is, so we just describe her as 'someone'. 
         *   Once the PC has seen the old lady close too, it'll be apparent 
         *   even from a distance that she's still the same old lady, so 
         *   we'll switch to calling her that.
         */        
        "<<gRevealed('lady') ? 'Den gamla damen' : 'Någon'>> sitter på bänken
        i det sydöstra hörnet på torget. "; 
    }
    
;

/*   
 *   INITIATE TOPIC
 *
 *   An InitiateTopic is executed in response to calling initateTopic() on 
 *   the actor. In this game we're doing that in response to SoundEvents.
 */
++++ InitiateTopic @whistleEvent
    "<.p>Den gamla kvinnan öppnar ögonen och täcker för öronen. Hon ger dig en 
    ursinnig blick och fräser till. <q>Sluta upp med det där <i>hemska</i> oväsendet, 
    konstapel! Ser du inte att jag försöker sova?</q> Utan att vänta på svar 
    slumrar hon till igen. "
;

++++ InitiateTopic @yellEvent
    "<.p>Den gamla damen vaknar med ett ryck och blänger ilsket på dig. <q>Det 
    finns ingen anledning att skrika!</q> säger hon till dig, <q>Det är helt 
    onödigt! När jag var flicka brukade unga människor behandla sina äldre med 
    respekt!</q>\b
    När hennes tillrättavisning uttalats slumrar hon till direkt igen. "
;    


/*  
 *   Playing the trumpet in the presence of the old lady finally succeeds in 
 *   getting her attention, and so wins the game.
 */
++++ InitiateTopic @trumpetEvent
    topicResponse()
    {
        "<.p>Den gamla kvinnan vaknar med ett ryck och springer hastigt till uppmärksamhet. Nu när du har hennes uppmärksamhet förklarar du om den förestående översvämningen, och ni två lämnar torget tillsammans.<.p>";

        /*"<.p>The old woman wakes up with a start and springs smartly to
        attention. Now that you have her attention you explain about the
        imminent flooding, and the two of you leave the square together.<.p>";*/
        finishGameMsg(ftVictory, [finishOptionUndo]);
    }
;

/*  
 *   CATCH-ALL INITIATE TOPIC 
 *
 *   We use this Catch-all InitiateTopic to deal with any SoundEvent for which 
 *   we haven't defined an InitiateTopic above.
 */

++++ InitiateTopic +80 @SoundEvent
    "<.p>Den gamla kvinnan vaknar och kastar en ondskefull blick på dig. <q>Kan du inte låta en gammal kvinna sova?</q> klagar hon. Utan att vänta på svar lutar hon sig tillbaka, sluter ögonen och slumrar direkt till igen. "
    /*"<.p>The old woman wakes up and throws you a baleful glance. <q>Can't you
    let an old woman sleep?</q> she complains. Without waiting for a reply, she
    leans back, closes her eyes, and dozes straight off again. "*/
;

/*   
 *   DEFAULT ANY TOPIC
 *
 *   We use this DefaultAnyTopic to provide a response to any conversational 
 *   command addressed to the old lady.
 */
++++ DefaultAnyTopic
    "Hon ignorerar dig och föredrar att sova vidare. "    // "She ignores you, preferring to snooze on. "
;

/*  
 *   MULTILOC
 *
 *   The fountain stands at the centre of the square, and is thus equally 
 *   accessible from all four corners. We can represent this by making the 
 *   fountain a MultiLoc (which must be mixed-in with one or more 
 *   Thing-derived classes in order to represent a physical object) and 
 *   locating it in all four corners of the square.
 */
fountain: MultiLoc, Container, Fixture 'sten|fontän+en; av[prep] sten; sten+figur+en pool+en' 
    "Oavsett om stenfiguren ursprungligen var i mitten av fontänen, har den sedan länge varit 
    nötts till oigenkännlighet av vattnet som ständigt strömmar ner från ner i poolen. "

    /*"Whatever the stone figure originally was at the centre of the fountain, it
    has long since been worn unrecognizable by the water constantly pouring from
    it into the pool. "   */
    locationList = [squareRegion]
    
    listenDesc = "Ett milt porlande ljud kommer från fontänen. " 
;

/*  
 *   Note that while this coin is in the fountain it can be taken from any 
 *   corner of the square.
 */
+ coin: Thing 'koppar|mynt+et; gam:mal+la av[prep] koppar' 
    "Det är bara ett gammalt kopparmynt. "
    
    sightSize = small
;

/*  
 *   SIMPLE NOISE
 *
 *   The sound of the fountain doesn't need to be described different under 
 *   different circumstances, so we can use a SimpleNoise to represent it.
 */
+ Noise 'porlande+t; mil:t+da kling+ande; ljud+et' 
    "Det är det mjuka ljudet av porlande vatten. "
;

+ Decoration 'vatt:en+net; rinnande' 
    "Det är rätt genomskinligt, och otveksamt blött. "
    notImportantMsg = 'Du är nöjd med att låta bli vattnet. '
;


/*  
 *   MULTILOC, DISTANT
 *
 *   We can also use a MultiLoc to represent a distant object that can be 
 *   seen (and looks much the same) from a number of different locations. 
 *   One obvious example would be the sun, which should be visible from 
 *   every outdoor location.
 */
MultiLoc, Distant 'sol+en; ljus+a skinande lysande;sol|ljus+sken+et'
    "Solen skiner starkt idag -- alldeles för starkt för att titta rakt på. "
    
    /*  
     *   Rather than listing each OutdoorRoom, we can simply specify that 
     *   the sun should appear in every OutdoorRoom.
     */
    locationList = [outdoorRegion]
;

//------------------------------------------------------------------------------

hall: Room 'Hall'
    "Den här hallen är nästan tom; den som bor här har uppenbarligen vidtagit 
    försiktighetsåtgärden att packa undan allting och förvara det i säkert 
    förvar i väntan på en översvämning. En dörr leder ut mot söder, och en andra 
    utgång leder västerut. "

    south = doorInside
    west = chamber
    out asExit(south)
;

+ doorInside: Door ->doorOutside 'dörr+en' 
;

+ ladder: Platform 'stege+n; lång+a robust+a; trästege+n'
    "Den är ganska lång och ser hyfsat robust ut. "
    initSpecialDesc = "En lång trästege lutar mot väggen. "
    dobjFor(Climb) asDobjFor(Board)
    dobjFor(ClimpUp) asDobjFor(Board)
    dobjFor(ClimbDown) asDobjFor(GetOff)
    bulk = 8
    
    /*  
     *   You can't lie down on a ladder, and you wouldn't normally think of 
     *   sitting on one.
     */
    canLieOnMe = nil
    sitOnScore = 70
;

//------------------------------------------------------------------------------

/* 
 *   ANOTHER SENSE REGION
 *
 *   We define another SenseRegion to represent the SensoryConnection between
 *   the rooms on either side of the window.
 */

windowRegion: SenseRegion
    
    
;

/*  
 *   WINDOW
 *
 *   Both squareNW and chamber mention a window - the same window, in fact, 
 *   seen from different sides. 
 *
 *   One can often open and close windows, so we should make it openable 
 *   too.
 */


window: MultiLoc, Fixture 'fönst:er+ret; lilla'
    "Det är <<if isOpen>>öppet, men det är för litet att klättra genom<<else>>
    stängt<<end>>. "
    
    isOpenable = true
    
    locationList = [windowRegion]
    
    
    /*  
     *   One obviously ought to be able to Look Through a window, but we 
     *   need to define handling for this specially.
     */         
    dobjFor(LookThrough)
    {
        action()
        {
            /* 
             *   First print some introductory text depending on the 
             *   location of the actor who's doing the looking.
             */
            "Du tittar <<gActor.isIn(chamber) ? 'ut' : 'in'>> genom 
            fönstret och ser <<gActor.isIn(chamber) ? 'torget' : 'en
                kammare'>>";
            
            /*   
             *   Then list the objects that can be seen through the window 
             *   from the point of view of the actor. Here we do this by 
             *   constructing a list of listable objects.
             */
            
            local other = gActor.isIn(chamber) ? squareNW : chamber;
            
            local lst = other.contents.subset({o: o.isListed});
            if(lst.length > 0)
                ", där du kan se <<makeListStr(lst)>>";
            
            ".\b";
        }
    }
    
        
    cannotGoThroughMsg = 'Fönstret är inte tillräckligt stort för att du ska kunna komma genom det. '
    cannotEnterMsg = (cannotGoThroughMsg)
;



//------------------------------------------------------------------------------

chamber: Room 'Chamber'
    "Det här rummet är nästan lika tomt som hallen, och förmodligen av ungefär 
    samma skäl; nästan allt har packats undan på ett säkert sätt någon annanstans 
    i händelse av översvämning. Av rummets form och storlek och stilen på 
    tapeterna att döma skulle man kunna gissa att det under normala tider skulle 
    kunna vara ett vardagsrum. Ett fönster har utsikt över torget norrut, men 
    den enda vägen ut är österut. "

    east = hall
    out asExit(east)
    
    regions = [windowRegion]
    
    inRoomName(pov)
    {
        if(pov.isIn(squareNW))
            return 'genom fönstret';
        else
            return inherited(pov);
    }
    
    /* 
     *   We have put the chamber and the northwest corner of the square in a
     *   common SenseRegion, since they're connected by a window, but we only
     *   want sound to pass through the window when the window is open. To
     *   enforce this we can use the canHearOutTo() method of the hall, so that
     *   it returns true only when the window is open. By default this will mean
     *   that canHearInFrom(loc) on the hall will follow the same condition.
     *   Note that these methods can only be used to impose additional
     *   restrictions on sense passing - they can't be used to provide sensory
     *   connections that aren't already provided by a SenseRegion.
     */
    canHearOutTo(loc)
    {
        return window.isOpen;
    }
    
    /* Logically it makes sense that a closed window would block smells too. */
    canSmellOutTo(loc) { return window.isOpen; }
;

+ Decoration 'tapet+en; grön+a randig+a'
    "Den är randig, i alternerande gröna nyanser. "
;

+ OpenableContainer 'stor trä|låda+n;; packning pack|låda+n'
    "Det verkar vara någon form av packlåda. "
    /*  
     *   By specifying that the box is made of 'paper' we allow sounds and 
     *   smells (but not sight or touch) to pass through it even when it's 
     *   closed. This means that we can hear the radio (when it's on) even 
     *   when it's shut in the box.
     */
    
    bulkCapacity = 4
;

/*  
 *   SWITCH
 *
 *   A Switch is something that can be switched on and off. Here we use it to
 *   implement a radio that makes a noise only when it's turned on.
 */
++ radio: Switch 'radio+n' 
    isOn = true
    makeOn(stat)
    {
        inherited(stat);
        if(stat)
        {
            "När du slår på radion väller ett plötsligt utbrott av hög musik fram. ";
            /* 
             *   When the radio is turned on, trigger a SoundEvent to 
             *   represent the sudden incidence of a loud noise that wasn't 
             *   there before.
             */
            musicEvent.triggerEvent(radio);
        }
        else
            "Radion tystnar. ";
    }
    
    listenDesc = "<<if isOn>><<if Q.canSee(gPlayerChar, self)>>Radion spelar hög musik. 
        <<else>>Det spelas hög musik.<<end>>
        <<else>>Radion är ganska tyst. <<end>>"
   
    soundSize = large
    
    /* 
     *   Don't mention our listenDesc in response to a LISTEN command unless
     *   we're on
     */
    isProminentNoise = isOn
    

;

/*  
 *   NOISE
 *
 *   We can create a Noise object to represent the sound the radio makes when
 *   it's turned on. Note the distinction between this Noise (which represents
 *   the ongoing Sensory Emanation that occurs for as long as the radio is on)
 *   and the musicEvent SensoryEvent which represents the event of the radio
 *   being turned on (a continuously playing radio might fade into the
 *   background of our consciousness; a radio suddenly turned on is likely to
 *   burst in on our consciousness; the Noise represents the former and the
 *   SoundEvent the latter.
 *
 *   Note that it would probably have been easier to do this by using the
 *   definition of Noise provided in the sensory.t extension (which does quite a
 *   bit of the work for us), but here we're sticking to features provided in
 *   the main library.
 */
+++ Noise '() musik+en; högljudd+a hög+a av[prep]; opera|musik+en opera|aktig+a opera operett ljud+et brus+et wagner'
    "<<if Q.canSee(gPlayerChar, self)>> <<descWithSource>> <<else>>
    <<descWithoutSource>> <<end>>"
    
    /*  The noise is only audible when the radio is turned on. */
    isEmanating = (radio.isOn)
    
    isHidden = !isEmanating
    
    /*  The response to LISTEN TO MUSIC when we can see the radio. */
    descWithSource = "Radion spelar något högljutt och operaliknande -- Wagner 
        kanske."
    
    /*  The response to LISTEN TO MUSIC when we can't see the radio. */
    descWithoutSource = "Musiken låter högljudd och operaliknande -- Wagner
        kanske. "
    
   
;

+ whistle: Instrument 'vissel|pipa+n; av[prep] silver silvrig+a'
    "Den är silverfärgad, lite lik en polisvissla. "
    
    /*  
     *   The following two properties are custom properties we define on our 
     *   custom Instrument class, for which see below. Since there are two 
     *   musical instruments in the game -- this whistle and a trumpet -- we 
     *   can save ourselves some work by defining a new class to implement 
     *   their common behaviour and then just customizing individual 
     *   Instruments with these two properties. 
     *
     *   When the whistle is blown, whistleEvent will be triggered, and the 
     *   message "You bloe a shrill blast on the whistle" displayed.
     */
    soundEvent = whistleEvent
    playDesc = 'Du blåser en gäll stöt i visselpipan. '
;

/*  The two SoundEvents referred to above. */

musicEvent: SoundEvent;
whistleEvent: SoundEvent;

//------------------------------------------------------------------------------
/*  
 *   REGION
 *
 *   We're about to implement a park comprising two locations, so we'll 
 *   start by joining them together with a DistanceConnector, so that we can 
 *   see from one end of the park into the other. 
 */

parkRegion: SenseRegion
    regions = [outdoorRegion]
;


parkS: Room 'Park (Södra)'
    "Parken upptar ett stort område, pepprad med träd, buskar och buskar. 
    En övergiven brasa pyr nere vid den svällande floden. Parken fortsätter 
    norrut och vägen tillbaka till torget går österut. "

    east = squareNW
    north = parkN
    
    /*  
     *   The phrase to use to describe the location of objects left here when
     *   viewed from the other end of the park.
     */
    inRoomName(pov) { return 'i parkens södra ände'; }
    
    regions = [parkRegion]
;

+ Fixture 'brasa+n; glödande; eld+en'
    "Det pyr fortfarande fint och avger mycket rök. Men det kommer det inte att 
    göra det särskilt länge till utifall att floden svämmar över. "
    feelDesc = "Den känns het. "
;

/*  
 *   A DECORATION USED TO REPRESENT SMOKE
 *
 *   Smoke is only marginally tangible, but for our purposes it can be quite 
 *   adequately represented by a Decoration. 
 */
++ Decoration 'rök+en; böljande tjock+a'
    "Tjock rök väller upp från den pyrande elden. "
    
    /* We don't want the parser referring to 'a smoke' or even 'some smoke' */
    aName = (name)
    
    /*  The smoke should be clearly visible from a distance. */
    sightSize = large
    smellSize = large
    
    decorationActions = [Examine, SmellSomething]
    
    smellDesc = "Den frätande röklukten stiger upp från brasan nere vid floden."
    
    notImportantMsg = '{Jag} {kaninte} göra det med rök. '
;

/*  
 *   ODOR
 *
 *   We use the same description for the smell of the as for the smoke itself.
 *   The Odor object is used to represent the smell as opposed to the object
 *   emitting the smell, but in the case of smoke that's arguably a distinction
 *   scarcely worth making. Still, we'll use an Odor object here to provide
 *   another example of its use.
 */
+++ Odor 'lukt+en; syrlig+a'
    desc = location.smellDesc
    
    
    /* The smell should be quite apparent at a distance. */
    smellSize = large
    
;

//------------------------------------------------------------------------------


parkN: Room 'Park (Norra)' 'norra änden av parken'
    "Parken upptar ett stort område, kryddat med träd, snår och buskar, 
    avgränsat av den uppsvällda floden i väster. Parken fortsätter söderut. "
    
    south = parkS
    
    /*  
     *   The phrase to use to describe the location of objects left here when
     *   viewed from the other end of the park.
     */
    inRoomName(pov) { return 'i den norra änden av parken'; }
    
    regions = [parkRegion]
;

+ Fixture 'alm:en+träd+et; hög:t+a'
    "Almträdet är verkligen rätt högt. Dess lägsta grenar är en bit för höga 
    för dig att kunna nå utan hjälp. "
    sightSize = large
;


/*  
 *   PUTTING SOMETHING OUT OF REACH
 *
 *   We don't want the player character to be able to reach the trumpet without
 *   the ladder, so we can put it out of reach using the checkReach() method of
 *   the branch, which also restricts access to the contents of the branch.
 */
+ Fixture, Surface 'gren+en; lägsta' 
    "Den är ungefär halvvägs upp på trädet." 
    
    
    /*  
     *   The PC can only reach this branch if s/he's standing on the 
     *   ladder.
     */
    checkReach(obj)
    {
        /* 
         *   Note that the checkReach method only needs to display some text to
         *   prevent reaching the object, so we use the method to explain why
         *   the branch can't be reached if the actor isn't on the ladder.
         */
        if(!obj.isIn(ladder))
            "Grenen är för högt upp för att nå. ";
    }
    
    /* 
     *   We won't allow anything other than the trumpet to be put on the 
     *   branch.
     */
    notifyInsert(obj)
    {
        if(obj != trumpet)
        {
            gMessageParams(obj);
            "{Jag} {kaninte} sätta {ref obj} på grenen. ";
            exit;
        }        
    }
;

/*  
 *   The trumpet is the second instrument in the game. Once again we'll use 
 *   our custom Instrument class (defined below).
 */
++ trumpet: Instrument 'trumpet+en; mässing; objekt+et instrument+et' 
    "<<if moved>>Trots att den befinner sig i en alm ser den ut att vara i 
    helt gott skick. <<else>>Det är en konstig plats för en trumpet, någon 
    kanske har lämnat kvar den där som ett slags skämt, eller hade en 
    märklig lust att spela på sin trumpet halvvägs uppe i en alm.<<end>> "
    
  
    /*  
     *   The initial (until moved) description of the trumpet in a room 
     *   description when it's viewed from a remote location (the other end 
     *   of the park).
     */
    remoteInitSpecialDesc (actor)
    {
        "Solen glimmar från ett mässingsföremål någonstans uppe i ett träd i 
        norra änden av parken. ";
    }
    initSpecialDesc = "Av någon anledning hänger det en trumpet från en gren 
        halvvägs upp på almen."
    
    /*  The sound event that's triggered when the trumpet is played. */
    soundEvent = trumpetEvent
    
    /*  The text that's displayed when the trumpet is played. */
    playDesc = 'Du blåser ut en gripande version av nationalsången. ' 
             //'You blast out a stirring rendition of the National Anthem. '
;

+ basket: OpenableContainer 'li+ten+lla rottingkorg+en'
    "Det ser ut som den sortens korg som en fiskare skulle kunna använda."
    

    bulkCapacity = 2
    initSpecialDesc = "En liten rottingkorg ligger övergiven vid floden. "
    
    /*  
     *   Another way of specifying how the basket should be listed in a room 
     *   description when viewed from afar.
     */
    remoteInitSpecialDesc(pov)
    { 
        "Genom träden och buskarna kan man nätt och jämnt urskilja
        en korg som står vid floden längst bort i parken. ";
    }
    
    /*  
     *   We wan't to be able to smell the fish even when the basket is closed,
     *   on the basis that the smell of rotting fish would probably manage to
     *   seep through the weave of the basket. We can do that by setting its
     *   canSmellIn property to true. There's also a canSmellOut property, but
     *   we don't need it here since the player character will never be inside
     *   the basket.
     */
    canSmellIn = true
;


/* Something smelly in the basket */
++ fish: Thing 'rutt:en+na fisk+en;ruttnande; sill+en'
    "Det är svårt att säga vad det var -- kanske en sill (möjligen en röd). "
    cannotEatMsg = 'Den ser alldeles för långt gången ut för att vara ätbart. '
    tasteDesc = "<<cannotEatMsg>>"
    
    smellDesc = "<<if gPlayerChar.canSee(self)>>En hemsk rutten lukt kommer
     från fisken. <<else>>Du känner en hemsk lukt av något som ruttnar.
        <<end>> " 
;

/*  
 *   ODOR
 *
 *   We use an Odor object to represent the smell of the fish. This object can
 *   describe the smell of the fish in a number of ways, as illustrated below.
 *
 *   Once again, we could have saved ourselves a little bit of work here by
 *   using the Odor class defined in the sensory.t extension, which already
 *   implements the descWithSource/descWithoutSource distinction in its
 *   definition of the desc property.
 */

+++ Odor 'hemsk:t+a rutt:en+na lukt+en;ruttnande; stink+ande stank'
    "<<if gPlayerChar.canSee(fish)>><<descWithSource>> <<else>>
    <<descWithoutSource>> <<end>> "
    
    
    /* The response to SMELL STENCH when we can see the fish */
    descWithSource = "Det är den ej omisskännliga lukten av ruttnande fisk. "
    
    /* The response to SMELL STENCH when we can't see the fish */
    descWithoutSource = "Det är en verkligt vedervärdig lukt; något ruttnande -- en 
        fisk kanske."
    
    /* As horrible as the smell is, we probably can't smell it at a distance */
    smellSize = small
    
    
;

/*  The SoundEvent associaated with playing the trumpet. */

trumpetEvent: SoundEvent
;

//------------------------------------------------------------------------------
/*  
 *   MULTILOC
 *
 *   A MultiFaceted object is one that runs through several locations, such 
 *   as this river that runs along the west side of the park. Whereas the 
 *   MultiLoc statue in the square was one physical object in one location 
 *   accessible from all four corners of the square (because it lay on their 
 *   joint boundaries at the centre of the square, in the case of the river 
 *   we have two segments of the same object (the river) that are 
 *   nevertheless physically distinct.
 */

MultiLoc, Fixture 'flod+en; snabb:t+a rinnande; strand|vatt:en+net'
    "Floden som rinner längs parkens västra sida flyter mycket snabbare än 
    vanligt och ser exceptionellt hög ut; den kan svämma över när som helst. "
    locationList = [parkRegion]  
;

/*  
 *   MULTILOC DECORATION 
 */

xyz: MultiLoc, Decoration 'träd och buskar;;träd+en buskar+na snår+en; dem'
    "En mängd olika träd och buskar har smakfullt fördelats runt parken 
    och omsorgsfullt skötts under åren. Du kan bara hoppas att de inte skadas 
    av översvämningsvattnet om och när floden går över sina bräddar. "

    definiteForm = 'träden och buskarna'

    locationList = [parkRegion]
    
    /*  
     *   The response we get from the trees if a SoundEvent is triggered in
     *   their vicinity.
     */
    notifySoundEvent(event, source) 
    {

        "Det plötsliga ljudet får en flock fåglar att lyfta och flaxa bort från träden. ";
    }
    
;

//==============================================================================

/*  
 *   We've defined a couple of Musical Instruments, now we need to define a 
 *   custom Play action so they can be played or blown.
 */
DefineTAction(Play)
;

VerbRule(Play)
    ('spela' | ('blås' ('i'|'på'|))) singleDobj
    : VerbProduction
    action = Play
    verbRule = 'spela/spelar (vad)'
    missingQ = 'vad vill du spela'
;


/*  We need to ensure that there's handling for the PlayAction on Thing. */
modify Thing
    dobjFor(Play)
    {
        preCond = [touchObj]
        verify() { illogical('{Jag} {kaninte} spela {detta dobj}. '); }
    }
;


/*  
 *   Finally, we define our custom Instrument class, so that it knows how to 
 *   handle a Play command.
 */
class Instrument: Thing
    dobjFor(Play)
    {
        /* We need to hold a wind instrument in order to play it. */
        preCond = [objHeld]
        verify() {}
        action()
        {
            /* Display the custom playDesc property. */
            say(playDesc);
            
            /* trigger the SoundEvent associated with this instrument. */
            if(soundEvent)
                soundEvent.triggerEvent(self);
        }
    }
    
    /*  The SoundEvent associated with this instrument. */
    soundEvent = nil
    
    /*  The description of this instrument being played. */
    playDesc = nil     
;

/*  
 *   Yelling also makes a noise, so we'll associate a SoundEvent with that too.
 */

modify Yell
    execAction(cmd)
    {
        inherited(cmd);
        yellEvent.triggerEvent(gActor);
    }
;

yellEvent: SoundEvent;

