#charset "utf-8"

#include <tads.h>
#include "advlite.h"


/*   
 *   EXERCISE 23 - AN EVENTFUL WALK
 *
 *   This game is a demonstration of the various EventList classes in TADS.
 *
 *   It also demonstrates Scenes, Menus, Hints and Scoring (which, after all,
 *   have to be demonstrated in conjunction with something.
 *
 *   There are several methods of scoring in TADS 3. Here we'll demonstrate only
 *   the that which uses Achievement objects to keep track of the score, calling
 *   their awardPointsOnce method. This allows the game to calculate the maximum
 *   score automatically for us.
 */




versionInfo: GameID
    IFID = '4de6c2e8-342b-471b-aeb8-c6960e0c801b'
    name = 'Övning 23 - En händelserik Promenad'
    byline = 'av Eric Eve (Översatt av Tomas Öberg)'
    htmlByline = 'av <a href="mailto:eric.eve@hmc.ox.ac.uk">Eric Eve</a>'
    version = '1'
    authorEmail = 'Eric Eve <eric.eve@hmc.ox.ac.uk>'
    desc = 'En demonstration av adv3Lites Scener, EventList-klasser, menyer, ledtrådar
        och poäng. '
    htmlDesc = 'En demonstration av adv3Lites Scener, EventList-klasser, menyer, ledtrådar
        och poäng. '
    
    
    /* This method will be run in response to an ABOUT command. */
    showAbout()
    {
        /* Display our help menu (defined below). */
        helpMenu.display();
        "Klart. ";
    }
    
    /* This method is run in response to a CREDITS command. */
    showCredit()
    {
        "<i><<name>></i> <<htmlByline>>.\b
        adv3Lite library by Eric Eve.\b
        TADS 3 Language and Library by Michael J. Roberts.\b
         ";
    }
;

gameMain: GameMainDef
    /* Define the initial player character; this is compulsory */
    initialPlayerChar = me
    
    
    showIntro()
    {
        /* 
         *   Show the introductory text. On an HTML interpreter (like 
         *   HTML-TADS for Windows) the aHref() definition towards the end 
         *   will result in the player seeing a clickable link labelled 
         *   ABOUT which s/he can click on to execute the ABOUT command.
         */        
        "Det var meningen att bli en trevlig eftermiddagspromenad, 
        sedan återvända till bilen, ta den korta bilresa hem, och vara 
        hemma precis lagom till kaffedags.\b
        Förutom att du nu har svårigheter att <i>hitta</i> tillbaka till din 
        bil.\b
        (Nybörjare kan vilja skriva <<aHref('OM','OM', 
            'Visa om-menyn')>>)\b ";
    }
    
    /*  
     *   The setAboutBox() is method to set up an About Box that will be 
     *   displayed in response to selecting Help -> About from the HTML-TADS 
     *   Interpreter. The text to be displayed must appear between <ABOUTBOX>
     *   and </ABOUTBOX> tags. The following is a plain vanilla definition 
     *   that would do for any game, since it picks up all its information 
     *   from versionInfo.
     */    
    setAboutBox()
    {
        "<ABOUTBOX><CENTER>
        <<versionInfo.name>>\b
        <<versionInfo.byline>>\b
        Version <<versionInfo.version>>
        </CENTER></ABOUTBOX>";
    }
;


/* The starting location; this can be called anything you like */

startroom: Room, ShuffledEventList 'Djupt inne i skogen'    
    "Du befinner dig vid en korsning av tre stigar mitt i skogen: en leder 
    västerut, en leder nordostut och en leder sydost. "
    
    northeast = byStream
    southeast = clearing
    
    /*  
     *   STOP EVENT LIST      TRAVEL CONNECTOR TO NOWHERE
     *
     *   A StopEventList displays (or executes) each of its elements in turn
     *   till it reaches the last one, which it will then just repeat. If we
     *   make a TravelConnetor also an EventList and don't define a
     *   destinationfor it , then the items in the eventList will be used each
     *   time the PC attempts to traverses the connector without actually going
     *   anywhere. 
     *
     *   We could also have defined destination = startroom to simulate the
     *   player character wandering down the path and returning to his starting
     *   point.
     */    
    west: TravelConnector, StopEventList {
        destination = startroom // OBS: Det ovan beskrivna fungerar inte, "destination" 
                                // behövs, annars får man veta att man inte kan gå 
                                // åt det hållet.
        eventList = [        
        /*  
         *   We are not restricted to putting just strings in an EventList. 
         *   Various other things, including function pointers can go there 
         *   too. Calling new function {} returns a pointer to the new 
         *   function so defined, so we can use this syntax to define a 
         *   function containing any code we like to execute as an item in 
         *   the list.
         */
            new function {
                "Du går en lång bit längs stigen tills du finner din väg blockerad 
                av ett fallet träd. Eftersom du inte hittar någon väg runt det, 
                tvingas du vända och komma tillbaka, men inte innan du har tagit med
                dig  en liten gren som hade brutits av trädet. ";
                branch.moveInto(me);
                
                /* 
                *   Award some points (well, only one point as it turns out) for
                *   finding the branch.
                */
                achievement.awardPointsOnce();
            },
            'När du går tillbaka nerför baksidan, står trädet fortfarande där, 
            och du hittar ingenting mer användbart, så du tvingas återvända.', 

            'Ja -- det där fallna trädet blockerar fortfarande vägen.'
        ]
        
        /*  
         *   This is a custom property, which we could have called anything 
         *   we liked. Calling it achievement, however, usefully reflects its
         *   purpose. We could have created a set of separate Achievement 
         *   objects to keep score, but it's often quite convenient to make 
         *   them nested anonymous objects associated with the object that 
         *   awards the points, as here. 
         *
         *   The two items in the template are the number of points to award 
         *   and the description of the achievement that led to the awarding 
         *   of the points.
         */
        achievement: Achievement { +1 "hitta grenen" }
        
        
    }
    
    
    /*  
     *   SHUFFLED EVENT LIST
     *
     *   A ShuffledEventList (which this Room also is) is typically used to
     *   display a random series of messages. Each message is displayed once
     *   before any is used again, and no message will be seen twice in
     *   succession.
     *
     *   Making a Room also a ShuffledEventList and defining its eventLis
     *   property provides a randomly ordered list of atmospheric messages; this
     *   is one typical use of a ShuffledEventList.
     */
    eventList = 
    [
        'Någonstans borta i skogen hör du en kråkas rop. ',
        'Ett kaninpar hoppar över din stig och försvinner in i träden. ',
        'En räv rusar över din stig. ',
        'Du hör vingslag när en fågelflock lyfter. ',
        'Det hörs ett tillfälligt prasslande i undervegetationen borta bland träden.'
    ]
    /* 
     *   These messages would quickly become tiresome if one was displayed on
     *   every turn, so we start by showing them only 80% of the time, and then
     *   drop the frequency to 40% after every message has been displayed once.
     */
    eventPercent = 80
    eventReduceTo = 40
    eventReduceAfter = static eventList.length()
    
;


/* 
 *   The player character object. This doesn't have to be called me, but me is a
 *   convenient name. If you change it to something else, rememember to change
 *   gameMain.initialPlayerChar accordingly.
 */

+ me: Player 'du'
;


++ Wearable 'promenad|kläder+na; slitstark+a gam:mmal+la;; dem'
    "Mer hållbara än smarta, de är bara några gamla kläder du använder för att gå i. "
    dobjFor(Doff)
    {
        check()
        {
            /* We don't actually want to allow the removing of these clothes. */
            "Det är inte läge att klä av sig nu. ";
        }
    }
    wornBy = me
;

+ Decoration 'träd+en;; skog+en; dem det'
    "Det finns träd överallt runt omkring dig. "
    
;

/*  
 *   Several locations will mention paths running off in various directions. 
 *   To avoid repetitive typing, we define a custom Path class (immediately 
 *   following this object) so we can define Paths just by setting a couple 
 *   of properties.
 */
+ Path
    /*  
     *   dir1 and dir2 are custom properties defined on the custom Path 
     *   class, for which see immediately below.
     */
    dir1 = 'nordöst, sydöst'
    dir2 = 'väst'
;

/*  
 *   Path is a custom class we define to represent the various paths 
 *   mentioned in four of the locations in the game. It's basically a kind 
 *   of Decoration.
 */
class Path: Decoration 'stig+en;;;den dem'
    /* 
     *   Provide a generic description which will be automatically 
     *   customised from the dir1 and dir2 properties.
     */
    "Stigar går härifrån till <<dir1>> och <<dir2>>. "
    
    /*   
     *   Define a custom notImportantMsg (used for all actions except EXAMINE
     *   and the two we define below), which will automatically be 
     *   customised with the text from the dir1 and dir2 properties.
     */
    notImportantMsg = ('Det enda du kan göra med stigarna är att gå på
         en av dem, antingen genom att gå ' + dir1 + ' eller ' + dir2 + '. ')
    
    
    /*   
     *   One might reasonably try to FOLLOW a path, so we provide custom 
     *   handling for this.
     */
    dobjFor(Follow)
    {
        verify() {}
        action()
        {
            /* 
             *   Turn FOLLOW PATH into a question asking which way the PC 
             *   should go.
             */
            "Vilken väg till du ta: <<dir1>> eller <<dir2>>? ";
        }
    }
       
    
    /*   
     *   To customize individual Path objects we just need to override the 
     *   custom (non library) dir1 and dir2 properties. Both properties 
     *   should be set to single-quoted strings: dir2 should describe the 
     *   final direction to be shown in any list, and dir1 should list all 
     *   the other directions. So if a location has paths running east, west 
     *   and south, you would set dir1 to 'east, west' and dir2 to 'south'. 
     *   If there paths running in only two directions, e.g. southeast and 
     *   southwest, just put one direction in each property, e.g. dir1 = 
     *   'southeast' and dir2 = 'southwest'.
     */
    dir1 = nil
    dir2 = nil
;

/*  
 *   TAKE PATH is equivalent to FOLLOW PATH, but only if the phrasing TAKE PATH
 *   is used; PICK UP PATH or GET PATH wouldn't mean the same thing.
 */
 // TODO: välj Path
Doer 'ta Path'
    execAction(c)
    {
        doInstead(Follow, gDobj);
    }
    strict = true
;

/*  
 *   The PC picks up this branch on going west from the starting location 
 *   for the first time. It's purpose is to act as a torch to explore inside 
 *   the dark cave, so we make it of kind Candle so it can be lit and will 
 *   continue to burn.
 */

branch: Thing 'smal+a gren+en;; kvist+en kvistar+na[pl] lövverk+et'
    "Grenen är ungefär en meter lång och slutar i en massa kvistar och lövverk. "
    
    /* It starts unlit */
    isLit = nil
        
    /* We can burn (i.e. set light to) it */
    isBurnable = true
    
    
    /* 
     *   If we just issue the command BURN BRANCH, then we'll have the game
     *   either ask the player what s/he wants to burn it with, or, if there's
     *   one best choice of indirect object in scope, have the parser select it
     *   automatically (so that BURN BRANCH in the presence of the fire will be
     *   treated as BURN BRANCH WITH FIRE)
     */
    dobjFor(Burn)
    {
        action() { askForIobj(BurnWith); }
    }
    
    /* Make LIGHT BRANCH behave the same as BURN BRANCH */
    dobjFor(Light) asDobjFor(Burn)
    
    dobjFor(BurnWith)
    {
        verify()
        {
            if(isLit)
                illogicalNow('Grenen är redan tänd. ');
            
        }
        
        action()
        {
            makeLit(true);
        }
    }
    
    
    
    makeLit(stat)
    {
        inherited(stat);
        /* When it's lit, award some points for lighting it. */
        if(stat)
            achievement.awardPointsOnce();
    }
    
    achievement: Achievement { +1 "sätta eld på grenen" }
;


//------------------------------------------------------------------------------

byStream: Room, RandomEventList 'Vid floden ' 'flodstranden'
    "En bred flod, svälld av det senaste kraftiga regnet, blockerar vägen norrut. 
    Tät snårväxt längs stranden skulle göra det svårt att följa flodens lopp 
    vare sig det gällde österut eller västerut, men det finns stigar som leder 
    både åt sydost och sydväst. "
    southwest = startroom
    southeast = byCave
    
    /*  
     *   EVENT LIST              TRAVEL CONNECTOR TO NOWHERE
     *
     *   An EventList executes every item in its list in turn, until it reaches
     *   the end, when it will do nothing. Since the last item in this EventList
     *   kills the Player Character (and so ends the game) we don't need
     *   anything to happen beyond the end of the list, so an EventList is just
     *   fine here.
     *
     *   Since this travel connector has no destination, all that will happen
     *   when we try to traverse it is that it will execute its noteTraversal
     *   method, which will in turn call travelDesc, which will in turn execute
     *   doScript, thus displaying each item in the event list in turn.
     */
    
    north: TravelConnector, EventList {
    [
        'Du kan inte gå den vägen; floden är i vägen. ',

        'Floden är fortfarande i vägen, och det ser alldeles för farligt ut att 
        simma över. ',
        
        /*  
         *   As before we can execute any code we like within an EventList 
         *   item by wrapping it in the new function syntax.
         */        
        new function {
            "Jaja, eftersom om du insisterar.\b
            Du vadar ner i floden. Den är djup. Du kan inte simma så bra. 
            Du drunknar.\b";

            /*  
             *   Kill the PC on the third attempt, but allow the player to 
             *   UNDO, so it's not too cruel. Also give the player the 
             *   option to see the full score (listing all the achievements 
             *   achieved to date).
             */
            finishGameMsg(ftDeath, [finishOptionUndo, finishOptionFullScore]);
        }
    ]
        
        /* 
         *   Since this connector isn't meant to lead anywhere, we don't want it
         *   listed as an exit.
         */
        isConnectorListed = nil
    }
    
    
    
    east = "Tät undervegetation hindrar dig från att gå direkt längs 
        flodstranden. " 
    
    /*  Use the same message for both east and west. */
    west asExit(east)
    
    /*  
     *   RANDOM EVENT LIST
     *
     *   A RandomEventList simply displays one of its items at random. The
     *   difference between this and a ShuffledEventList is that a
     *   RandomEventList may show the same item twice (or more) in a row. In a
     *   situation where this is acceptable, you can use it as an alternative to
     *   a ShuffledEventList, as here.
     */
    eventList =     
    [        
        'Det uppstår ett tillfälligt hinder i floden när något bryter 
        upp över ytan och sedan försvinner under den igen. ',
        'Någonstans hör du en grodas kväkande. ',
        'En fågelflock flyger ovanför. ',
        'Något plaskar i den sumpiga undervegetationen. ',
        'En vindpust krusar ytan på floden.'
        
        /*
        'There\'s a brief disturbance in the river as something breaks
        above the surface and then vanishes beneath it again. ',
        
        'Somewhere, you hear the croaking of a frog. ',
        'A flock of birds flies overhead. ',
        'Something splashes in the marshy undergrowth. ',
        'A gust of wind ripples across the surface of the river. '
        */
    ]
    
    eventPercent = 50
;


/*  
 *   SYNC EVENT LIST
 *
 *   A SyncEventList is an EventList that's kept in sync with another 
 *   EventList (pointed to in its masterObject property).
 *
 *   This game is mean enough to drown the PC on the third attempt to cross 
 *   the river whether it's by typing NORTH or SWIM RIVER, although we'll 
 *   display different messages for the two commands. Using a SyncEventList 
 *   here esnures we keep count of the total number of attempts to cross the 
 *   river, by whichever means. 
 */
+ Fixture, SyncEventList 'flod+en; bred+a vids|träckt+a svälld svällande+s; vatt:en+net'
    "Svullen av de senaste översvämningarna forsar floden snabbt förbi. "

    /*  
     *   We can fill things (well, the bucket) from the river, and pour 
     *   things (well, water) into it.
     */
    iobjFor(FillWith) { verify() {} }
    iobjFor(PourInto) { verify() {} }
    
    
    /*   
     *   In principle, the river is something that could be swum. Note that 
     *   Swim is not an action defined in the standard library; we define it 
     *   below.
     */
    dobjFor(Swim)
    {
        verify() {}
        action() { doScript(); }       
    }
    
    eventList = 
    [
        'Floden har svällt av det senaste regnet, strömmen ser exceptionellt 
        stark ut, och du är inte en så bra simmare. Så efter att du doppat en 
        tå i vattnet, kommer du på bättre tankar. ',

        'Du är nästan desperat nog att försöka, men inte riktigt. Vattnet är kallt,
        och strömmen ser stark ut. Du är inte säker på att du skulle klara dig till 
        andra sidan. ',

        new function {

        "Du överger all försiktighet, kastar dig i floden och ger dig ut 
        mot den motsatta stranden, men floden är än djupare och strömmen än 
        starkare än du trodde. Mindre än halvvägs över blir du medsvept. 
        Oförmögen att hålla huvudet ovanför vattnet, drunknar du.\b";
        
        finishGameMsg(ftDeath, [finishOptionUndo, finishOptionFullScore]);
    }        
    ]
    
    /* The EventList object we're keeping in sync with. */
    masterObject = byStream.north
;

/* Path is a custom class defined above. */
+ Path
    dir1 = 'sydöst'
    dir2 = 'sydväst'
;

+ Decoration 'viss undervegetation; tät+a tjock+a sumpig+a mark+en; vall+en flod|bank+en' 
    //"Thick undergrowth, made marshy by the swollen river, blocks the bank to
    // both east and west. "     
    "Tjock undervegetation, sumpig av den svällande floden, blockerar 
    stranden både österut och västerut. "
;


//------------------------------------------------------------------------------

byCave: Room 'Utanför en grotta' 'grottans ingång'
    "Stigar från både nordväst och sydväst slutar här strax utanför en grottas 
    mynning i öster. "
    northwest = byStream     
    southwest = clearing
    east = cave
    in asExit(east)
    
    /*  
     *   Award some points if the player character enters this room carrying 
     *   the bucket, which will happen if the PC takes the bucket out of the 
     *   cave. Since awardPointsOnce() only awards points once, it doesn't 
     *   matter how many times the PC subsequently enters the room carrying 
     *   the bucket; no more points will be awarded.
     */
    travelerEntering(traveler, origin)
    {
        if(bucket.isIn(traveler))
           achievement.awardPointsOnce();
    }
    achievement: Achievement { +2 "att få ut hinken ur grottan" }
;

+ Enterable -> cave 'grott|ingång+en; grottans av[prep]; grott|mynning+en grotta+n'
    "Grottans ingång <<cave.blocked ? 'har blockerats av ett nyligt stenras'
     : 'är inte så stor, men ser tillräckligt stor ut för att man ska kunna 
     gå in i den'>>. "
;

/*  
 *   HIDDEN ROCKFALL
 *
 *   This rockfall should only be present once the cave entrance has collapsed,
 *   so we make it start out hidden so it can be made present once it's needed.
 */
+ rockfall: Immovable 'sten|ras+et; sten av[prep]; stenar+na fall:ande+na hög+a' 
    "Stenraset har helt blockerat ingången till grottan. "

    specialDesc = "En hög med stenar blockerar ingången till grottan. "
    
    cannotTakeMsg = 'Du kommer aldrig kunna flytta den där massan för hand. '
    
    
    isHidden = true
;

/*   Path is a custom class defined above. */
+ Path
    dir1 = 'nordväst'
    dir2 = 'sydväst'
;


//------------------------------------------------------------------------------

cave: Room 'Grotta' 
    "Det ser ut som att den här grottan sträcker sig ganska långt,
    men den enda vägen ut är västerut. "
    /* The cave is dark */
    isLit = nil
    
    /*  
     *   darkName and darkDesc will be used instead of the ordinary 
     *   room name and description when the room is dark. The use of the 
     *   <.reveal> tag in the dark description enables the hints system to 
     *   track when the PC has visited this room in the dark.
     */
    darkName = 'Grotta (i mörkret)'
        
    darkDesc = "Det är för mörkt för att se något här inne, förutom att 
        vägen ut är västerut. <.reveal dark-cave>"
    
    /*   
     *   EVENT LIST        TRAVEL CONNECTOR
     *
     *   We can mix an EventList with a TravelConnector to provide a sequence 
     *   of different responses each time the PC goes this way. Since the PC 
     *   cannot in any case traverse this travel connector after the third 
     *   traversal blocks the entrance to the cave, a simple EventList will 
     *   do.
     */    
    west: TravelConnector, EventList {
    [
        /* 
         *   An EventList item can simply be nil, in which case it does 
         *   nothing.
         */
        nil,
        
        /*  The second time through we'll display a warning message. */
        'När du går ut ur grottan hör du ett oroväckande muller, och du känner 
        ett fint damm och småsten falla runt dig alldeles innan du kommer ut 
        i ljuset. ',
        
        /*  
         *   The third time through we'll cause a rockfall that blocks the 
         *   way back into the cave. We could do this with new function 
         *   again, but this time we'll illustrate an alternative. Another 
         *   kind of thing that can occur in an EventList is a method 
         *   pointer; when the EventList reaches &rockFall it will execute 
         *   self.rockFall().
         */
        &rockFall
    ]
        /*   This travel connector takes us outside the cave. */
        destination = byCave
        
        /*   A custom method invoked by the last item in the EventList above. */
        rockFall()
        {
            /* 
             *   Start by blocking the cave. Note that we have defined the 
             *   custom blocked property on the cave object, not the 
             *   TravelMessage, so we use lexicalParent to get the right 
             *   object's property (forgetting to do this can be a very 
             *   common source of bugs).
             */
            lexicalParent.blocked = true;            
            "När du går ut ur grottan börjar stenarna runt utgången att darra. 
            Du lyckas rusa ut precis i tid för att undvika stenraset som 
            blockerar grottan. ";

            /*   Make present the rocks blocking the cave from the outside. */
            rockfall.discover();
            
            /*   
             *   If the PC has left the bucket in the cave, the game is now 
             *   unwinnable, so we may as well end it straight away.
             */
            if(bucket.isIn(cave) && !bucket.isIn(me))
                finishGameMsg('SPELET ÄR NU OMÖJLIGT ATT KLARA', 
                              [finishOptionUndo, finishOptionFullScore]);
        }
        
        
    }
    
    out asExit(west)
    
    /*  A custom property we use to block the cave after the rockfall. */
    blocked = !rockfall.isHidden
    
    /*  
     *   Once the cave is blocked we can't get back into it. Since the cave 
     *   is the only TravelerConnector to itself, we can block it by using 
     *   its canTravelerPass method.
     */
    canTravelerPass(traveler) { return !blocked; }
    explainTravelBarrier(traveler) 
    {
        "Du kan inte gå tillbaka in i grottan; ett stenras har täckt ingången. ";
    }
    
    /*  
     *   Once the cave is blocked, we obviously can't get back in, so we 
     *   shouldn't list the way back in as a possible exit.
     */
    isConnectorApparent = (!blocked)
;    


+ bucket: Container 'hink+en; vanlig+a'
    "Det är bara en helt vanlig hink<< water.isIn(self) ? ', som är
        full med vatten' : ''>>. "
    
    /*  
     *   FillWith is a custom action defined below. The bucket is the only 
     *   object in the game that can be filled with anything, so we need to 
     *   define special action handling for it.
     */
    dobjFor(FillWith)
    {
        /*  
         *   In order to fill the bucket the actor must be holding the 
         *   bucket and the bucket must first be empty.
         */
        preCond = [objHeld]
        verify() 
        {
            /*  We can't fill a bucket that's already full. */
            if(water.isIn(self))
                illogicalNow('Hinken är redan full. ');
        }
        action()
        {
            "Du fyller hinken med {ref iobj}. ";
            
            /*  
             *   The water object is defined below. Moving it into the bucket
             *   effectively fills the bucket with water.
             */
            water.moveInto(self);
            
            /*   Award some points for filling the bucket. */
            achievement.awardPointsOnce();
        }
    }
    initSpecialDesc = "En hink har lämnats kvar på marken när grottans baksida. "
    bulkCapacity = 4
     
    
    achievement: Achievement { +2 "fylla hinken med vatten" }
;


//------------------------------------------------------------------------------

clearing: Room 'Glänta'
    "<<first time>>Du känner igen den här gläntan; du är ganska säker på att du 
    har varit här förut. <<only>>Om du inte misstar dig särskilt mycket ligger vägen 
    tillbaka till parkeringen rakt söderut<< smoke.isIn(self) ?  ' -- om du nu kan 
    nå den med all rök som väller upp från brasan' : ''>>. Andra stigar 
    leder mot nordost och nordväst. "
    
    
    northwest = startroom
    northeast = byCave
    
    south: TravelConnector
    {
        
        noteTraversal(traveler)
        {
            "Nu när röken från branden har lagt sig kan du enkelt nå den södra 
            utgången från gläntan. Efter det är det bara en kort promenad 
            tillbaka till din bil.\b";
            
            /*  
             *   Once the PC traverses this connector award the final points 
             *   end the game in victory.
             */
            achievement.awardPointsOnce();
            finishGameMsg(ftVictory, [finishOptionUndo, finishOptionFullScore]);
        }
        
        achievement: Achievement { +2 "hitta tillbaka till din bil" }
    }
    
;


/*   
 *   FIRE - we use a Fixture and add some customizations to make it work like a
 *   bonfire.
 *
 */
+ bonfire: Fixture 'brasa+n; stor+a; elds|lågor+na läger|eld+en'
    "Brasan <<if isLit>>flammar och sprider rökmoln<<else>>
    är pyr endast<<end>>. "
    
    feelDesc = "<<if isLit>>Brasan är alltför het för att röra vid. 
                <<else>>Den känns fortfarande rätt varm.<<end>> "
    
    /*  Special handling for pouring water onto the fire. */
    
    iobjFor(PourOnto)
    {
        verify()
        {
            /*  If the fire isn't lit, there's no point trying to put it out. */
            if(!isLit)
                illogicalNow('Du har redan släckt elden. ');
        }
        check() {}
        action()
        {
            /*  
             *   Pouring water into the fire makes it go out, and removes the
             *   smoke.
             */
            "Du häller {ref dobj} på elden, som slockar. ";
            smoke.moveInto(nil);
            
            /*   Award some points for extinguishing the fire. */
            achievement.awardPointsOnce();
            
            /* 
             *   Now that we've put the fire out, we shouldn't be able to refer
             *   to any flames.
             */
            removeVocabWord('lågor');
            removeVocabWord('lågorna');

            addVocab(';pyrande'); // TODO: testa av att lägga till ett ajektiv fungerar som tänkt
        }
    }
    
    /*   
     *   The player might try DOUSE FIRE or EXTINGUISH FIRE, so we provide 
     *   handling for that.
     */
    dobjFor(Extinguish)
    {
        /*  
         *   We save ourselves some typing by re-using the same verify() 
         *   method as for PourOnto, since exactly the same conditions apply.
         */
        verify() { verifyIobjPourOnto(); }
        check()
        {
            /*  We can only extinguish the fire if the water is to hand. */
            if(!gActor.canReach(water))
               "Du har inget till hands att göra det med. ";
        }
        
        /* 
         *   If we've got this fire, there is water to hand, and the fire 
         *   hasn't been put out yet, so we can now translate DOUSE FIRE 
         *   into POUR WATER ONTO FIRE.
         */
        action() { replaceAction(PourOnto, water, self); }
        
    }
    
    iobjFor(BurnWith) { preCond = [touchObj] }
    
    canBurnWithMe = true
    
    /*   The bonfire is lit when it is smoking. */
    isLit = (smoke.isIn(self))
   
   //'Elden är alldeles för het för att vidröra, än mindre för att bära med sig.' : 'Den är både för varm och för stor för att röra sig.'

    cannotTakeMsg = (isLit ? 'Elden är alldeles för het för att 
        vidröra, än mindre för att bära med sig. ' 
        : 'Den är både för varm och för stor för att flytta på. ')
    
    //'Du vill inte förse lågorna med mer bränsle! ': 'Riskera inte; det kanske tänds igen.'

    cannotPutOnMsg = (isLit ? 'Du vill inte förse lågorna med mer bränsle! 
        the flames! ' : 'Bäst att inte ta någon risk; den kanske antänds igen. ')
    
    achievement: Achievement { +2 "släcka elden" }
;

++ smoke: Decoration 'viss rök; heta hetta+nde bölja+nde; moln+en värme|rök+en' 
    "Röken väller upp från elden och nästan helt fyller den södra sidan av gläntan.  "
    aName = 'rök' 
    
    smellDesc = "Den luktar ganska syrligt. "
    
    /* We want to be able to smell the smoke as well as examine it. */
    decorationActions = [Examine, SmellSomething]
    
    notImportantMsg = 'Du kan inte göra så med rök. '
;

+++ smokeSmell: Odor, ExternalEventList 'lukt+en; frätande av[prep]; (rök+en)' 
    eventList =
    [
        'Röklukten från elden verkar överväldigande. ',
        'Den syrliga röklukten får dig att hosta. ',
        'Röken svider i dina ögon. ',
        'Röklukten är ganska obehaglig.'
    ]
    
    /*  
     *   An ExternalScriptList provides no mechanism of its own for changing 
     *   its state. Here we set its curScriptState to track the Odor's 
     *   displayCount (which is advanced every time the Odor is mentioned). 
     *   We have to make sure that curScriptState is never a number that's 
     *   larger than the length of the event list.
     */
    curScriptState = (displayCount > eventList.length ?
                                      eventList.length : displayCount)
    
    displayCount = 1

;

/*  Here we define a very basic NPC. */
+ man: Actor 'lång+a man+nen; mag:er+ra;;honom'     
    "Han är väldigt lång och ganska mager, som om han bara har tillbringat 
    de senaste femtio åren i ett kloster dedikerad med att fasta. "

    globalParamName = 'man'
;

/* This is the ActorState the man starts out in */
++ ActorState   
    isInitState = true
    specialDesc = "{Ref subj man} går raskt förbi. "
    
    /* 
     *   Any attempt to converse with the man while he's in this state will be
     *   met with this noResponse.
     */
    noResponse = "Han är för djupt försjunken i sina egna tankar för att bry sig om dina. "
    stateDesc = "Han ser ut att vara försjunken i sina tankar. "
    
    /* 
     *   The message to display when the man enters the location of the player
     *   character.
     */
    sayArriving(fromLoc)
    {
        "<<one of>>En lång man<<or>>Den långa mannen<<stopping>> dyker upp efter stigen. ";
    }
;

/*  
 *   CYCLIC EVENT LIST
 *
 *   A CyclicEventList is an EventList that goes round in a continuous cycle;
 *   after the last item in the list has been used, it loops back to the 
 *   first.
 *
 *   Here we combine a CyclicEventList with an AgendaItem to send our 
 *   NPC walking in a continuous circle round the map.
 */
++ walkingAgenda: AgendaItem, CyclicEventList
    [
        /* 
         *   The {: } syntax is just a short form of the new function syntax we
         *   can use when the function contains a single statement. The first
         *   item in the list is equivalent to:
         *
         *   new function { man.travelVia(startRoom); }
         *
         *   Note that when we use the short form {: } syntax we must not end
         *   the single statement in the function with a semicolon.
         *
         *   Note the use of the report method (a method of AgendaItem) in the
         *   third item in the list to make sure the message is only displayed
         *   when the player character can see the man.
         */        
        {: man.travelVia(startroom) },
        {: man.travelVia(byStream) },
        {: report('{Ref subj man} stannar upp för att ösa upp en näve vatten 
            från floden innan han fortsätter sin väg. ')} ,
        {: man.travelVia(byCave) },
        {: man.travelVia(clearing) }
    ]    
    
    initiallyActive = true
    invokeItem() { doScript(); }
;

/* 
 *   An alternative actor state the tall man goes into if the Player Character
 *   triggers a rock fall in the cave.
 */

++ manStandingState: ActorState
    specialDesc = "Den långe mannen står precis utanför grottan och stirrar på
        stenhögen med en blandning av bestörtning och ogillande. "

    stateDesc = "Han ser inte alls nöjd ut just nu. "
;

+++ DefaultAnyTopic, CyclicEventList
    [
        '<q>Det där var <i>min</i> grotta,</q> klagar han. <q>Det är dit jag brukar 
        gå för att meditera. Vad ska jag göra nu?</q> ',

        '<q>Jag kommer aldrig att kunna flytta alla de där stenarna,</q> suckar han. ',

        '<q>Det här är bara för mycket,</q> muttrar han och skakar på huvudet.'
    ]
;

/*  The custom Path class is defined above. */
+ Path
    dir1 = 'nordöst, nordväst'
    dir2 = 'söder'
;

/* 
 *   A State object applied to the bonfire to give it different adjectives by
 *   which it can be referred to according to whether it's lit or unlit.
 */
fireLitUnlitState: State
    appliesTo(obj) { return obj == bonfire; }
    stateProp = &isLit
    adjectives = [[nil, ['släckta', 'varma', 'glödande']], 
        [true, ['tända', 'heta', 'flammande']]]
    
;


/* 
 *   SCENES
 *
 *   This is admittedly a somewhat artificial example since everything this
 *   Scene does could be done in other ways, but it nevertheless illustrates the
 *   principle.
 */
bonfireLitScene: Scene
    /* This Scene is active from the start of the game */
    startsWhen = true
    
    /* 
     *   Every turn when the player character is in the clearing during the
     *   scene we'll drive the smokeSmell script; if the player isn't in the
     *   clearing we reset the counter for the script instead, so it always
     *   starts out at 1 when the player character returns to the clearing.
     */
    eachTurn()
    {
        if(gPlayerChar.isIn(clearing))
        {
            smokeSmell.doScript();
            smokeSmell.displayCount++;            
        }
        else
            smokeSmell.displayCount = 1;
    }
    
    /* This Scene ends when the bonfire has been put out. */
    endsWhen = !bonfire.isLit
;


/* 
 *   A second example of a Scene. Again, this could be done another way, but a
 *   Scene provides quite a convenient means of making things happen in response
 *   to some condition becoming true.
 */
manComplainingScene: Scene
    /* 
     *   The Scene starts when the rockfall happens, which is when the rockfall
     *   object becomes visible.
     */
    startsWhen = !rockfall.isHidden
    
    whenStarting()
    {
        man.removeFromAgenda(walkingAgenda);
        man.setState(manStandingState);
        man.moveInto(byCave);
        "I just det ögonblicket dyker den långe mannen upp längs stigen.";
    }
;


/* 
 *   What this Doer does could just as easily have been done using the
 *   canTravelerPass() and explainTravelBarrier() methods on the TravelConnector
 *   south from the clearing, but this illustrates another approach tied in with
 *   a Scene.
 */
Doer 'gå söder'
    execAction(c)
    {
        "Du kan inte nå den södra utgången på grund av röken och hettan från 
        elden.<.reveal smoke-block> ";
    }
    
    where = [clearing]
    during = [bonfireLitScene]
;




//==============================================================================
/*  The WATER object */

water: Immovable 'vatt:en+net;;vätska+n' 
    
    //aName = 'vatten'
    cannotTakeMsg = 'Vattnet rinner mellan dina fingrar. '
    
    /* Custom handling for pouring water onto something. */    
    dobjFor(PourOnto)
    {
        /*  
         *   To be able to pour water onto something we must be holding its 
         *   container.
         */
        preCond() { return [new ObjectPreCondition(location, objHeld)]; }
        verify() {}
        action()
        {
            moveInto(nil);
        }
    }
    
    /* 
     *   Treat PUT WATER ON SOMETHING as equivalent to POUR WATER ONTO 
     *   SOMETHING.
     */
    dobjFor(PutOn) 
    {
        preCond() { return [new ObjectPreCondition(location, objHeld)]; }
        verify() {}
        action()
        {
            doInstead(PourOnto, self, gIobj);
        }
    }
       
    
    
    /*  Custom handling for pouring water into something. */
    dobjFor(PourInto)
    {
        preCond() { return [new ObjectPreCondition(location, objHeld)]; }
        verify() {}
        action()
        {
            "Du häller vatten i {ref iobj. ";
            moveInto(nil);
        }
    }
       
    
    
    bulk = 4
;


//==============================================================================
/* CUSTOM ACTIONS AND GRAMMAR */
          
DefineTIAction(FillWith)    
;

VerbRule(FillWith)
    'fyll' singleDobj ('med') singleIobj
    : VerbProduction
    action = FillWith
    verbPhrase = 'fylla/fyller (vad) (med vad)'
    missingQ = 'vad vill du fylla; vad vill du fylla med'
;

/*  
 *   Provide this form to handle FILL SOMETHING. If the player types FILL BUCKET
 *   the parser will  prompt for an indirect object: "What do you want to fill
 *   it from?"
 */

VerbRule(FillWithWhat)
    [badness 500] 'fyll' singleDobj     
    : VerbProduction
    action = FillWith
    verbPhrase = 'fylla/fyller (vad) (med vad)'
    missingQ = 'vad vill du fylla; vad vill du fylla med'
    missingRole = IndirectObject
    dobjReply = singleNoun
    iobjReply = withSingleNoun
;

DefineTAction(Swim)
;    

VerbRule(Swim)
    'simma' ('över' | 'i' | ) singleDobj
    : VerbProduction
    action = Swim
    verbPhrase = 'simma/simmar i (vad)'
    missingQ = 'vad vill du simma i'
;

/*  Put appropriate action handling on Thing for our new actions. */
modify Thing
    dobjFor(FillWith)
    {
        preCond  = [touchObj]
        verify() { illogical('Du kan inte fylla {ref dobj} med någonting. ');
        }
    }
    iobjFor(FillWith)
    {
        preCond = [touchObj]
        verify() { illogical('Du kan inte fylla någonting med {detta iobj}. '); }
                
    }
    
    dobjFor(Swim)
    {
        preCond = [touchObj]
        verify()
        {
            illogical('{Detta dobj} {är} inte något jag kan simma i. ');
        }
    }
    
    /*  
     *   Also make it logical to pour onto anything, but rule it out in 
     *   check(), so the player can't waste the water in the bucket by 
     *   pouring it onto anything other than the fire.
     */
    iobjFor(PourOnto)
    {
        preCond = [touchObj]
        verify() {}
        check()
        {
            "Det är ingen större mening att hälla {ref dobj} på {detta iobj}. ";
        }
    }
    
;


//==============================================================================
/* 
 *   MENUS
 *
 *   We'll demonstrate menus in general by setting up a short menu of options
 *   that can be displayed in response to an ABOUT command. This will 
 *   include the instructions on playing IF in general defined in instruct.t
 *
 *
 *   We first modify the InstructionsAction (defined in the standard library 
 *   file instruct.t). Here we're modifying standard properties provided for 
 *   the purpose of allowing game authors to tweak the otherwise standard 
 *   instructions.
 */

modify Instructions
    /* 
     *   Our game is a bit on the cruel side, so change the cruelty lever to 
     *   2 so that this is reflected in the instructions.
     */
    crueltyLevel = 2
    
    /*  
     *   The instructions can say that they contain all the verbs a player 
     *   needs to complete the game.
     */
    allRequiredVerbsDisclosed = true
    
    /*   
     *   To make the above claim true we need to add an example of the FILL
     *   WITH grammar to the list of standard verbs.
     */
    customVerbs = ['FYLL HINK MED SAND']
;

/*  Make HELP equivalent to ABOUT. */
modify VerbRule(About)
    'om' | 'hjälp'
    :
;

/*  
 *   MENU ITEM
 *
 *   We can use MenuItem to define a top-level menu or a sub-menu. Here we're
 *   defining the top menu that's displayed in response to an ABOUT command 
 *   (see versionInfo.showAbout() defined near the start of this file.
 */     
helpMenu: MenuItem 'Hjälpmeny'
    /* 
     *   In addition to the two items defined below, we want this menu to 
     *   contain the instructions menu from instruct.t and out hint menu, 
     *   which we're about to define below.
     *
     *   Note that instruct.t doesn't automatically provide the instructions 
     *   as a menu. To make it do so, we must make sure that 
     *   INSTRUCTIONS_MENU is defined before instruct.t is compiled into the 
     *   build. We can do this in Workbench using the Build -> Settings menu 
     *   and adding INSTRUCTIONS_MENU via the Compiler -> Defines tab.
     *
     *   If you're not using Workbench you'll need to add -D 
     *   INSTRUCTIONS_MENU when compiling from the command line.
     *
     *   You might also need to force a recompile of instruct.t, either by 
     *   doing a Compile All, or by opening instruct.t and, say, adding and 
     *   deleting a space so that the compiler thinks it has changed.
     *
     */
    
    contents = [topInstructionsMenu, topHintMenu]    
;

/*  
 *   MENU LONG TOPIC ITEM
 *
 *   We use MenuLongTopicItem to display some text when the item is selected 
 *   from a menu.
 */
+ MenuLongTopicItem 'Om detta spel'
    menuContents = "<<versionInfo.name>> är en demonstation av EventList(or),
        menyer, ledtrådar och poängtagande i adv3Lite.\b
        I spelhänseende är detta vare sig långt eller krävande. Efter att raskt 
        ha tagit dig till ett vinnande slut första omgången kan det hända att du 
        vill spela om och utforska i ett lugnare tempo för att se hur de olika 
        EventList(orna) fungerar, samt testa alla ledtrådar. "    
;

+ MenuLongTopicItem 'Eftertexter'
    /* 
     *   When the Credits item is selected from the menu, just show the 
     *   credits information already defined on the versionInfo object.
     */
    menuContents = (versionInfo.showCredit)
;


//------------------------------------------------------------------------------
/*  
 *   HINTS
 *
 *   This demonstration is probably a bit over the top in providing 
 *   comprehensive hints for such simple puzzles, but the idea is to show the
 *   principles of the Hints system.
 *
 *   We begin by defining the root menu of our Hints System. This could 
 *   contain submenus if we wanted, but an adaptive hint system rarely has 
 *   enough hints active at once for this to be worthwhile.
 *
 *   This is the menu that will be displayed in response to a HINTS command.
 */


topHintMenu: TopHintMenu 'Ledtrådar'
;

/*  
 *   GOAL
 *
 *   Goals constitute the contents of the Hints system. They represent tasks 
 *   that the player is trying to perform and might want guidance on. Only 
 *   those Goals that are currently open (relevant for active tasks) are 
 *   displayed.
 *
 *   We start with a very general goal that the player might have right at 
 *   the start of the game.
 */


+ Goal 'Vad är det meningen att jag ska göra?'
    /* 
     *   The following hints will be displayed one at a time until the player
     *   reaches a list. As each hint is displayed, the previous ones remain
     *   visible.
     */
    [
        'Försök att utforska. ',
        'Du försöker hitta en väg tillbaka till din bil. ',
        'Se till att du har utforskat hela området.'
    ]
    
    /*  
     *   This goal is open at the start of the game. We use the OpenWhenTrue 
     *   condition to open it and simply define the condition as true.
     */
    openWhenTrue = true
    
    /*   
     *   We close this Goal once the player has visited the four main 
     *   locations on the map and encountered something that looks enough 
     *   like a recognizable difficulty to suggest a more specific goal to 
     *   pursue.
     */
    closeWhenTrue = byCave.seen && byStream.seen && clearing.seen &&
    (gRevealed('smoke-block') || gRevealed('dark-cave') )
;


+ caveGoal: Goal 'Hur får jag in ljus i grottan?'
    [
        'Har du sett något häromkring som ger ifrån sig ljus? ',
        'Kanske detta även ger ifrån sig värme. ',
        'Så som en eld. ',
        'Om du kunde tända något bärbart kanske du skulle kunna 
        ta med det till grottan. ',
        'Trä brinner. ',
        
        /* 
         *   Mostly we can just use single-quoted strings to display hints. 
         *   Occasionally, when we want displaying the hint to have some side
         *   effect, such as opening another goal, it's convenient to use a 
         *   hint object instead.
         */
        branchHint
    ]
    
    /* 
     *   The cave is not considered 'seen' until it has been seen in lit 
     *   conditions. The dark description of the cave reveals the dark-cave 
     *   tag so we can use it here to test whether it has been revealed; if 
     *   it is, it's time to open this goal.
     */
    openWhenRevealed = 'dark-cave'
    
    /*  
     *   Once the cave has been seen properly (with the aid of a light) this 
     *   goal has been achieved, its hints are no longer needed, so we close 
     *   it.
     */
    closeWhenSeen = cave
;

/*   
 *   HINT
 *
 *   There's no necessity to nest Hint objects inside Goals, but it can be 
 *   convenient to do so, since this allows us to define the Hint object 
 *   close to the Goal that refers to it without messing up the object 
 *   hierarchy of the menu; otherwise all the Hint objects would have to be 
 *   defined after the last Goal. 
 *
 *   This Hint displays "So you could try using a branch." and open the 
 *   branchGoal Goal.
 */
++ branchHint: Hint 'Du skulle kunna prova att använda en gren.'
    [branchGoal]
;

+ branchGoal: Goal 'Var hittar jag en gren?'
    [
        'Hur noga har du utforskat?',
        'Vad ligger västerut?',
        'Mer specifikt, vad ligger västerut från din startplats?'
    ]
    /*  
     *   We don't provide an openWhenXXXX, since this Goal is opened by the 
     *   display of the branchHint Hint. It's closed once the branch has 
     *   been moved, since at that point the player has found the branch and 
     *   doesn't need any more hints on how to do so. 
     */
    closeWhenTrue = branch.moved
;


+ Goal 'Hur tar jag mig söderut från gläntan med brasan? '
    [
        'Vad hindrar dig? ',        
        fireHint
    ]
    /* Once again use a reveal tag to open the Goal. */
    openWhenRevealed = 'smoke-block'
    
    /* 
     *   We can close the Goal once the fire's been put out; since putting 
     *   out the fire causes the achievement of the bonfire.achievement, we 
     *   can use that as the test here. Equally usable alternatives would 
     *   have included:
     *
     *   closeWhenTrue = !bonfire.isLit
     *
     *   OR
     *
     *   closeWhenTrue = smoke.isIn(nil)
     *
     */
    closeWhenAchieved = bonfire.achievement
;

++ fireHint: Hint 'Det kanske vore en god idé att släcka elden. '
    [fireGoal]
;

+ fireGoal: Goal 'Hur kan jag släcka elden?'
    [
        'Hur brukar du släcka en eld?',
        'Vad kan man lägga på en eld för att släcka den?',
        waterHint
    ]
    closeWhenAchieved = bonfire.achievement
;

++ waterHint: Hint 'Du kanske kan hämta lite vatten. '
    [waterGoal]
;
    
    
+ waterGoal: Goal 'Hur kan jag föra vatten från floden till elden? '
    [ 
        'Vad brukar du normalt sett transportera vatten i? ',
        bucketHint   
    ]
    closeWhenTrue = water.moved
;

++ bucketHint: Hint 'Du kanske kan hitta en hink någonstans. '
    [bucketGoal]
;

+ bucketGoal: Goal 'Vad kan jag hitta en hink? '
    [        
        'Hur noggrant har du utforkat? ',
        'Vad ligger österut? ',
        caveHint
    ]
    closeWhenSeen = bucket
;

    /* 
     *   Note that though this Hint opens caveGoal, that Goal can also be 
     *   opened by the PC entering the cave when it's dark.
     */
++ caveHint: Hint 'Försök att titta i grottan. '
    [caveGoal]
;

/*  
 *   Once the bonfire has been put out, there's nothing left to do except 
 *   leave the clearing by the south exit. For the sake of completeness we 
 *   include a Goal even for that.
 */

+ Goal 'Vad ska jag göra nu?'
    [
        'Vad är det du har försökt göra från första början?',
        'Meningen är att du ska försöka hitta tillbaka till din bil.',
        'Kommer du ihåg var du parkerade den?',
        'Du är ganska säker på att det var söder om gläntan med brasan.'
    ]
    openWhenAchieved = bonfire.achievement
    
    /* 
     *   We don't need a CloseWhenXXXX condition, since this Goal should 
     *   remain open until the end of the game.
     */
;
