#charset "utf-8"

#include <tads.h>
#include "advlite.h"

/*
 *   EXERCISE 13 - CONTAINERS
 *
 *   A small 'game' implementing a kitchen as an illustration of adv3Lite
 *   containers.
 */

versionInfo: GameID
    IFID = '13cb0798-2be6-4082-87e1-aa077cb36bb7'
    name = 'Övning 13'
    byline = 'av Eric Eve (Översatt av Tomas Öberg)'
    htmlByline = 'av <a href="mailto:eric.eve@hmc.ox.ac.uk">Eric Eve</a>'
    version = '1'
    authorEmail = 'Eric Eve <eric.eve@hmc.ox.ac.uk>'
    desc = 'Ett exempelspel för att illustrera användningen av Containers
            i adv3Lite och för att ge en möjlig lösning till Övning 12 och 13 i 
            Learning TADS 3 with Adv3Lite. '
    htmlDesc = 'Ett exempelspel för att illustrera användningen av Containers
            i adv3Lite och för att ge en möjlig lösning till Övning 12 och 13 i 
            <i>Learning TADS 3 with AdvLite</i>. '
;

/*
 *   The "gameMain" object lets us set the initial player character and
 *   control the game's startup procedure.  Every game must define this
 *   object.  For convenience, we inherit from the library's GameMainDef
 *   class, which defines suitable defaults for most of this object's
 *   required methods and properties.  
 */
gameMain: GameMainDef
    /* the initial player character is 'me' */
    initialPlayerChar = me
    showIntro()
    {
        "Nu har ditt kök renoverats, och du vill titta runt lite. <.p> ";
    }
;


/* 
 *   ROOM
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
kitchen: Room 'Kitchen'
    "En stor del av utrymmet upptas av ett träbord mitt i köket. PÅ ena väggen finns ett skåp, en spis bredvid en annan, med en krok praktiskt placerad bredvid. En lång arbetsyta löper under skåpet, med ett hushållspappersrulle monterad på väggen precis ovanför. Den motsatta väggen är prydd med en munter affisch. Utgången är norrut, men du är inte intresserad av resten av huset just nu. "

    north() { "Det finns inget behov att vandra runt i huset i övrigt; det är köket du vill undersöka just nu. "; }
;

/* 
 *   The player character object. This doesn't have to be called me, but me is a
 *   convenient name. If you change it to something else, rememember to change
 *   gameMain.initialPlayerChar accordingly.
 */

+ me: Player'du'   
        
    /* 
     *   Give the player character a modest bulkCapacity so we can try out the
     *   BagOfHolding.
     */
    bulkCapacity = 20                                                           
;


//------------------------------------------------------------------------------

/*  
 *   DISTANT
 *
 *   We'll start with a simple Distant object. In practice the PC could 
 *   probably reach the light bulb by standing on the kitchen table, but 
 *   that's a complication beyond what we want to illustrate in this demo.
 */

+ bulb: Distant 'nak:en+na glöd|lampa+n'
    "En naken glödlampa hänger ned från taket. "
;

+ Distant 'tak+et'
    desc = bulb.desc
;

/*  
 *   DECORATION
 *
 *   The cheerful poster is mentioned in the room description. We implement it so the player can
 *   examine it without the need to interact with it in any other way.
 */

+ Decoration 'affisch+en; stor+a munt:er+ra solig+a landskap+et planch+en' 
    "Du har placerat den där för att den är munter. Den avbildar en soligt landskap. "    
;

//------------------------------------------------------------------------------
/*
 *   A SIMPLE SURFACE
 *
 *
 *   About the simplest kind of container object is a simple surface. We'll 
 *   make this one a Fixture too, since it obviously can't be moved.
 */

+ workTop: Surface, Fixture 'arbets|yta+n; lång+a övre; arbets|bänk+en' 
    cannotTakeMsg = 'Hantverkaren verkar ha arbetat färdigt med arbetsytan, i vilket fall är den så stadigt fixerad att man inte skulle kunna rubba den en nanometer.'
;

/*  
 *   RESTRICTED CONTAINER
 *
 *   We'll first define a Container - a pencil sharpener - into which only
 *   pencils can be put, and then only one at a time. We'll use its notifyInsert
 *   method to enforce these conditions.
 *
 *   This definition of the pencilSharpener is fairly minimal, but below we
 *   shall define a custom Pencil class which will make the sharpener work in a
 *   fairly basic fashion.
 */
 
++ pencilSharpener: Container 'li:ten+lla plast|penn|vässare+n; röd+a plastig+a; vässar|blad+et' 
    "Frånsett vässarbladet, är den helt gjort i röd plast. "
    
    notifyInsert(obj)
    {
        if(!obj.ofKind(Pencil))
        {
            "Endast pennor passar i pennvässaren. ";
            exit;
        }
        
        if(contents.length > 0)
        {
            "Vässaren kan vara ta en penna åt gången. ";
            exit;
        }
    }
        
    bulkCapacity = 1
    bulk = 2   
;

/*   
 *   HIDDEN UNDER
 *
 *   We can hide things under other things by listing the concealed items in the
 *   hiddenUnder property. example: a book under which a note has been
 *   concealed. Note that the note will stay behind when the book is taken.
 */

++ redBook: Thing 'stor+a röd+a matlagnings|bok+en; matlagning+en'
    "Det är en matlagningsbok. "
    
    /* 
     *   Giving the redfBood a readDesc is all that's needed to make it readable (i.e. to respond
     *   appropriately to a READ BOOK command.
     */
    readDesc = "Du bläddar genom några sidor, men inga av recepten intresserar dig just nu. "    
    
    hiddenUnder = [note]
    
    bulk = 3
;

/*  
 *   RESTRICTED SURFACE
 *
 *   An example of a Surface we can only put one thing on; here a peg on which
 *   we can hang (here just PUT) an apron, but nothing else.
 */


+ peg: Surface, Fixture 'häng|krok+en;;'
    notifyInsert(obj)
    {
        if(obj != apron)
        {
            "{Jag} {kaninte} hänga {ref dobj} på kroken. ";
            exit;
        }
    }
;

/*   WEARABLE */

++ apron: Wearable 'randig:a+t förkläde+t; blå (och) röd randiga'
    "Det är blå- och rödrandigt. "
    bulk = 4
;

 /*  
 *   REAR CONTAINER
 *
 *   RearContainers are used less often. The point to remember is that when 
 *   they're moved their contents doesn't move with them, so the bag and the 
 *   sack will remain put.
 *
 *   Normally we'd be able to open a large brown box, but to keep this 
 *   RearContainer simple we'll just display a message showing why we don't 
 *   want to open it just yet.
 */


+ brownBox: Heavy, RearContainer 'stor+a brun+a låd+an; fyr|kantig+a'
    "Den är ungefär två kvaderatfot stor. "
    initSpecialDesc = "En stor brun låda står placerad i ena hörnet. "
    cannotOpenMsg = 'Den är full av ditt porslin och dina bestick, 
        men du vill inte börja packa upp dem ännu.'
    lookInDesc = "<<cannotOpenMsg>>"
    
    cannotPutOnMsg = 'Du vill lägga något på lådan med tanke på risken 
                    att det skulle skada porslinet inuti. '
    bulk = 8
    
    /* 
     *   This isn't really an openable container, but it looks like one so 
     *   the player might try to put something in it. To cater for this we 
     *   add stub iobjFor(PutIn) handling that makes it logical to put 
     *   something in the brown box, but will fail on the attempt to open 
     *   the brown box that will be triggered by the objOpen precondition.
     */
    iobjFor(PutIn)
    {
        preCond = [objOpen]
        verify() {}
    }
    
    /* 
     *   In practice it would probably be simpler to list the items hidden
     *   behind the box in its hiddenBehind property, but here we're
     *   illustrating the use of a RearContainer, so we need to manually make it
     *   discover anything hidden behind it when we look behind it.
     */
    dobjFor(LookBehind)
    {
        action()
        {
            foreach(local cur in contents)
                cur.discover();
            inherited;
        }
    }
;

/*  
 *   STRETCHY CONTAINER
 *
 *   We make the sack start out hidden by setting its isHidden property to true;
 *   calling discover() makes it unhidden. We make the bulk of the sack depend on
 *   the bulk of the items it contains by defining its bulk to be a minimum
 *   value (3) - the bulk of the sack when empty - plus the total bulk of the
 *   items it contains.
 */


++ sack: Container 'gam:mal+la brun+a säck+en'
    bulk = (3 + getBulkWithin)
    isHidden = true    
;

/*   
 *   BAG OF HOLDING
 *
 *   To try out the BagOfHolding, take it early on, then take as many other
 *   objects as you can. BagOfHolding is a mix-in class so we need to list it
 *   before any Thing-derived classes in the bag's class list.
 */

++ bag: BagOfHolding, Container 'gam:mal+la beige+a väska+n;;bag+en' 
    
    /* 
     *   Making the bulk smaller than the bulk capacity may seem 
     *   unrealistically Tardis-like, but if we don't do that the 
     *   BagOfHolding can't do its job, since the whole purpose of it is to 
     *   carry more bulk than the PC can hold in his/her hands.
     */
    bulk = 4
    bulkCapacity = 100
    
    isHidden = true
;

/* 
 *   MULTIPLE-TYPE CONTAINER
 *
 *   A cooker is something you can typically put things on top of and 
 *   inside, so it's a good candidate for illustrating Multiple Containment. 
 *   While we're at it, we'll give it a rear as well with something 
 *   hidden behind.
 */


+ oven: Fixture 'spis+en;;ugn+en' 
    "Den är inte helt an mot väggen. "
    
    /* 
     *   The remapOn property defines the sub-object we actually put things on
     *   when we notionally put them on the oven.
     */
    remapOn: SubComponent {}    
    
    /* 
     *   The remapIn property defines the sub-object we actually put things in
     *   when we notionally put them in the oven.
     */
    remapIn: SubComponent { isOpenable = true bulkCapacity = 10}
    
    /* 
     *   The remapBehind property defines the sub-object we actually put things
     *   behind when we notionally put them behind the oven.
     */

    // TODO: this is what causes not finding anything within the hiddenBehind array
    // remapBehind: SubComponent { bulkCapacity = 1 }   
    
    /* 
     *   The leaflet will be moved to the remapBehind SubComponent when we look
     *   behind the oven.
     */
    hiddenBehind = [leaflet]
;

/*  
 *   CONTAINER DOOR
 *
 *   A ContainerDoor is normally only used on a Multiple Container, as here.
 */

++ ContainerDoor 'ugns|dörr+en; (ugnens) (spisens)'
;

++ cake: Food 'choklad+tårta+n; stor+a rund+a utsökta+a delikat+a brun+a' 
    "Den är stor, rund och brun. "
    /* 
     *   Note the special syntax for locating something initially in a 
     *   remapIn object of a multiply-containing object. 
     */
    subLocation = &remapIn // or you could just write sLoc(In)
    
    dobjFor(Eat)
    {
        action()
        {
            "Du tar en tugga och den är utsökt, så du tar en hel bit; sedan en 
            till, och en till och en till och en till tills hela kakan är borta 
            och din midja hotar att bukta ut över acceptabla gränser.";
            
            inherited;
        }
    }
    
    tasteDesc = "Den smakar utsökt chokladig. "
    bulk = 3
;

++ saucepan: Container 'kastrull+en; rostfri:a+tt stål+et; panna+n' 
    "Den är gjord av rostfritt stål. "
    
    sLoc(On)
    bulkCapacity = 3
    bulk = 4
    allowPourIntoMe = true
;

/*  
 *   MULTIPLEX CONTAINER WITH LID
 *
 *   Rather more complicated than a simple saucepan is a pot which is open or
 *   closed by removing or replacing its lid. In order to allow the lid to 
 *   be put ON it while other things can be put IN it, we need to make it a 
 *   Mutliplex Container.
 */

++ pot: Thing 'stor+a orange casserole|gryta+n' 
    "Det är en står orange gryta med ett svart handtag. "
    remapOn: SubComponent 
    {
        notifyInsert(obj)
        {
            if(obj != potLid)
            {
                "Det enda du kan lägga på grytan är dess lock. ";
                exit;
            }
        }
    }
    
    remapIn: SubComponent    
    {
        isOpenable = true
        isOpen = (!potLid.isIn(lexicalParent.remapOn))
        bulkCapacity = 5
        
        
        dobjFor(Open) 
        {
            verify()
            {
                if(isOpen)
                    illogicalNow('Den är redan öppen, ');
            }
            
            action()
            {                
                doInstead(Take, potLid);                
            }
        }
        
        dobjFor(LookIn) { preCond = [objOpen] }
    }
    
    bulk = 6     
    allowPourIntoMe = true
    subLocation = &remapOn
;


/* THE LID */

+++ potLid: Thing 'lock+et' 
    bulk = 3
    subLocation = &remapOn
    dobjFor(Take)
    {
        action()
        {
            if(isIn(pot.remapOn))
                "Du tar av locket från grytan. ";
            inherited;
        }
    }
;

/*  
 *   COMPONENT
 *
 *   Since the pot is already a ComplexContainer, its easy to add a Component
 *   like a handle. You couldn't do this directly on an OpenableContainer.
 */

+++ Component 'svart+a handtag+et' 
;


/*
 *   A MULTIPLEX CONTAINER YOU CAN STAND ON
 *
 *   A table could just be a straightforward Surface, but since it's 
 *   reasonable to put things under a table as well as on top of it, we can 
 *   also make it a Multiplex Container to allow this. A further complication 
 *   is that people might be able to sit, stand, or lie on a large kitchen 
 *   table: this example shows one way of allowing that
 *
 *   Note that we also make the table inherit from Heavy, since it's too 
 *   heavy to pick up or move around.
 */

+ table: Heavy 'bord+et; trä+iga stor+a;träbord+et'
    "Det är ett stort bord av trä. "
    remapOn: SubComponent, Platform { }
    remapUnder: SubComponent {}
;

/* 
 *   OPENABLE CONTAINER
 *
 *   The red box is a straightforward OpenableContainer 
 */

++ redBox: OpenableContainer 'stor+a röd+a låda+n'
    sLoc(Under) // equivalent to subLocation = &remapUnder
    bulk = 10
    bulkCapacity = 10
;

/*  We'll see how this can opener is used below. */

+++ canOpener: Thing 'konservöppnare+n;; konservburks|öppnare+n plåtburks|öppnare+n'
    iobjFor(OpenWith)
    {
        verify() {}
    }
;

/*  
 *   Some pencils for the sharpener; we'll define the Pencil class below.
 *
 *   Note that objects can inherit vocab from their superclass. The '+' in the
 *   vocab of these Pencils is a placeholder for the 'pencil' that they all
 *   inherit from the Pencil class.
 */

+++ Pencil 'röd+a *';
+++ Pencil 'blå+a *';
+++ Pencil 'grön+a *';
+++ Pencil 'svart+a *';
+++ Pencil 'gul+a *';



/* 
 *   LOCKABLE CONTAINER
 *
 *   The cabinet is also a straightforward LockableContainer, but it's also 
 *   fixed in place. Note that we don't need a key to unlock a 
 *   LockableContainer (which makes the class almost pointless in practice.
 */
 

+ cabinet: LockableContainer, Fixture 'köks|skåp+et;; kabinett+en'
    cannotTakeMsg = 'Köksskåpet är ordentligt fäst i väggen. '
    
    /* If we want a LockableContainer to start out locked, we have to say so. */
    isLocked = true
;

/*  TRANSPARENT OPENABLE CONTAINER */

++ glassJar: OpenableContainer 'glas|burk+en'
    /*  
     *   By declaring isTransparent = true, we make it possible to see what's
     *   inside even when it's closed.
     */

    isTransparent = true
    
    /* 
     *   The following property prevents our putting anything but fairly small 
     *   objects into the jar, even though it has quite a large bulkCapacity.
     */    
    maxSingleBulk = 3
    bulkCapacity = 10
    allowPourIntoMe = true
;

/*  
 *   CLASS DEFINITION
 *
 *   Note that since we can define the SugarCube class here without upsetting
 *   the object containment hierarchy. Since every sugar cube will have the same
 *   name, the sugar cubes will automatically be treated as equivalent.
 */

class SugarCube: Food 'sockerbit+en'    
    tasteDesc = "Den smakar precis så sött som du förväntade dig. "
;

/*  
 *   These ten SugarCubes will be in the glassJar, not the SugarCube class! Note
 *   that when we first examine the glass jar the sugar cubes will be listed as
 *   'ten sugar cubes' not 'a sugar cube, a sugar cube, ... and a sugar cube'.
 *   Adv3Lite automatically groups items like this if their names are identical.
 */
 

+++ SugarCube;
+++ SugarCube;
+++ SugarCube;
+++ SugarCube;
+++ SugarCube;
+++ SugarCube;
+++ SugarCube;
+++ SugarCube;
+++ SugarCube;
+++ SugarCube;

/*  
 *   A CUSTOMISED CONTAINER
 *
 *   The soup can is a more complicated example of a container; it starts off
 *   closed and can only be opened in a special way, using the can opener. 
 *   This requires some custom coding.
 */

//TODO: can of soup;;tin
+ soupCan: Container 'soppa+n på burk+en;;konservburk+en'
    definiteForm = 'soppan på burk'
    isOpen = nil    
    
    dobjFor(OpenWith)
    {
        preCond = [objHeld]
        verify() 
        {
            if(isOpen)
                illogicalNow('Burken är redan öppen. ');
        }
        check()
        {
            if(gIobj != canOpener)
                "{Jag} {kaninte} öppna burken med {ref iobj}. ";
        }
        action()
        {            
            makeOpen(true);
            "{Jag} öppna{r/de} burken med {ref iobj}. ";
            
            /* 
             *   If opening us is not being performed as an implicit action,
             *   list the contents that are revealed as a result of our being
             *   opened.
             */
            if(!gAction.isImplicit)
            {              
                unmention(contents);
                listSubcontentsOf(self, openingContentsLister);
            }  
                       
        }
    }
    cannotOpenMsg = 'Du kommer behöva ha något att öppna den med. '
    bulk = 3
    bulkCapacity = 2
    allowPourIntoMe = true
;

/*  
 *   A SIMPLE LIQUID
 *
 *   The soup in the can is also an odd kind of object, since it can't 
 *   simply be picked up, although it should be possible to transfer it from 
 *   one container to another. 
 */


+++ soup: Food 'lite tomat|soppa+n; röd+a orange tjock+a'
    "Den ser rätt tjock ut, och färgen är någonstans mellan röd och orange. "
   
    dobjFor(Take)
    {
        verify() { illogical('Det är vätska; du kan inte ta upp det. '); }
    }
    
    dobjFor(PutIn)
    {
        preCond = [touchObj]
        check()
        {
            /* 
             *   allowPourIntoMe is a library property we define as true on
             *   those few containers above we're prepared to allow the soup to
             *   be poured into.
             */
            if(!gIobj.allowPourIntoMe)
                "Det skulle bli alltför mycket kladd att hälla i soppan där. ";
        }
    }
        
    dobjFor(PutOn)
    {
        preCond = [touchObj]
        check()
        {
            "Du vill inte kladda ner. ";
        }
    }
    dobjFor(PutUnder) asDobjFor(PutOn)
    dobjFor(PutBehind) asDobjFor(PutOn)
    dobjFor(PourOnto) asDobjFor(PutOn)
    
    isPourable = true
    
    dobjFor(PourInto) 
    {
        action() { doInstead(PutIn, self, gIobj); }
    }    
    
    bulk = 2
    dobjFor(Drink) asDobjFor(Eat)
    dobjFor(Eat)
    {
        preCond = [touchObj]
        action()
        {
            "Det smakar okej, men den skulle vara godare om den var varm. ";
            inherited;
        }
    }
    tasteDesc = "Det smakar tomat. "
;


/*   
 *   DISPENSER AND DISPENSABLES
 *
 *   In adv3, a Dispenser is a container for a special type of item. By default its
 *   contents can be taken but not returned. A roll of kitchen towels provides a
 *   good example of this; you can take a towel from the roll, but you can't but
 *   it back.
 *
 *   The adv3Lite library doesn't define Dispenser and Dispensable classes; here
 *   we instead implement the equivalent by making the roll a Container you
 *   can't put things in and which doesn't list its contents.
 *
 *
 *   We'll make the roll an Immovable; it's not obvious that you couldn't tale
 *   the whole roll, but in this case we won't allow it.
 */
 
//rulle med pappershanddukar
//hushållspapper; (handduksrulle); hållare
+ roll: Immovable, Container 'hushålls|pappers|rulle+n;; hållare'
    "Det är en<<contents.length == 0 ? ' tom rulle' : ' rulle av pappershanddukar'>>,
    fastmonterad på väggen. "
    
    cannotTakeMsg = 'Du kan inte ta loss rullen från hållaren; 
                    hantverkaren måste ha felmonterat den.'
    
    canPutInMe = nil
    
    contentsListed = nil
;

  /* 
   *   Once again we can define the class between the container and its 
   *   contents -- we don't have to define it here, but doing so does no harm.
   */

class PaperTowel: Thing 'papper:et^s+handduk+en; vanlig:a+t papp:er+ret vit+a fyrkant+iga (hushålls)'     
    "Det är en vanlig, vit, fyrkantig pappershandduk. "    
    bulk = 1
;

++ PaperTowel;
++ PaperTowel;
++ PaperTowel;
++ PaperTowel;
++ PaperTowel;
++ PaperTowel;
++ PaperTowel;
++ PaperTowel;
++ PaperTowel;
++ PaperTowel;


/* 
 *   A Fixture to represent the wall the clock starts out hanging on, and can be
 *   returned to.
 */
+ wall: Fixture, Surface 'vägg+en; (norra) (n)'
    notifyInsert(obj)
    {
        if(obj != clock)
        {
            "Du kan inte sätta det på väggen";
            exit;
        }
    }
;

/*  
 *   RESTRICTED REAR CONTAINER
 *
 *   This clock has a label attached to the rear. The label will move with the
 *   clock. We define a notifyInsert method to ensure that the label is the only
 *   thing that can go behind the clock.
 */

++ clock: RearContainer 'klocka+n; rund+a vit+a' 
   "Den är rund och vit och visar att klockan är <<showTime()>>. "
        
    /* 
     *   When we move the clock we want the label that's behind it to move with
     *   it.
     */
    dropItemsBehind = nil
    
    dobjFor(LookBehind)
    {
        preCond = [objHeld]
    }

    notifyInsert(obj)
    {
        if(obj != blueLabel)
        {
            "Endast etiketten kan placeras på klockans baksida. ";
            exit;
        }
    }
    

    initSpecialDesc = "En klockan hänger på norra väggen. "
    useInitSpecialDesc = (isIn(wall))

    objInPrep = 'på baksidan av'
    
    bulk = 3
    
    /* 
     *   There's no need to worry too much about the showTime() method below;
     *   what it does it read the system time and then report it as the 
     *   time shown on the clock.
     */
    
    showTime()
    {
        local minute = getTime()[7];
        local hour = getTime()[6];
        
        /* 
         *   If the minute is more than 30, then we want to report the time 
         *   as so many minutes to the hour, otherwise we'll report it as so 
         *   many minutes past the hour.
         */
        local prep = minute > 30 ? 'i' : 'över';
        
        /*   
         *   If the minute it more than 30, subtract it from 60 to get the 
         *   number of minutes to the next hour.
         */
        minute = minute > 30 ? 60 - minute : minute;
        
        /*   
         *   If we're reporting so many minutes to the hour, we need to add 
         *   one to the hour ( 10:35 is 25 minutes to 11). 
         */
        hour = prep == 'i' ? hour + 1 : hour;
        
        /*   
         *   If the hour is more than 12, deduct 12 so it's on a 12 hour 
         *   rather than 24 hour clock.
         */
        hour = hour > 12 ? hour - 12 : hour;
        
        /*   Finally spell the time out in words, not numbers. */
        
        if(minute == 0)
            "kl. <<spellNumber(hour)>>";
        else
            "<<spellNumber(minute)>> minut<<minute > 1 ? 'er' :''>> <<prep>>
            <<spellNumber(hour)>>";
    }
;

/*  
 *   The label starts hidden, since we obviously can't see it while the 
 *   clock is hanging on the wall.
 */

+++ blueLabel: Thing 'blå+a etikett+en' 
    "Det står <q>Made in adv3Lite</q> på den. "   
    isHidden = clock.useInitSpecialDesc
;


   
/* 
 *   Make PUT SOMETHING ON CLOCK or ATTACH SOMETHING TO CLOCK behave like PUT
 *   SOMETHING BEHIND CLOCK by defining a DOER
 */
Doer 'sätt Thing på clock; fäst Thing på clock'
    execAction(c)
    {
        doInstead(PutBehind, gDobj, clock);
    }
;



//------------------------------------------------------------------------------

/* The note that's hidden under the cookery book. */

note: Thing 'gul+a papper:et^s+lapp^s+bit+en;anteckning+en'
    "Någon har klottrat en anteckning på den. "
    readDesc = "Det står: <q>Jag insåg just att det fanns ett litet 
        fel i min ursprungliga bedömnning i den här köksmonteringen. Inga 
        problem -- lägg bara till några nollor till den ursprungliga siffran.\b 
        Buck Grubber (hantverkare)</q>"
    bulk = 1
;

// TODO: cannot find leaflet by looking behind the oven

/* The leaflet that's hidden behind the oven */
leaflet: Thing 'broschyr+en;(spisens); spis|instruktion+en'
    "Det ser ut som instruktionsbladet till spisen. <<first time>> Det måste ha fallit ner bakoms spisen.<<only>>"
    
    readDesc = "Man kan inte urskilja instruktionerna. Det ser ut som att de har översatts från kinesiska med hjälp av en portugisisk-swahili-parlör av någon vars modersmål var sanskrit. "
    dobjFor(Read) { preCond = [objVisible, objHeld] }
    bulk = 1
;



/*
 *   Another example of a DOER: If the player tries to turn the sharpener when
 *   there's a pencil in it, turn the pencil instead.
 *
 *   The property matched in the template, the single-quoted string, is the cmd
 *   property. This defines the command this Doer will respond to when its when
 *   condition is true. We construct this string using the name of the command
 *   as it would be typed by the player ('turn') followed by the *programmatic*
 *   name of the item (or class) the command applies to ('pencilSharpener').
 */
Doer 'vrid pencilSharpener'
    execAction(c)
    {
        doInstead(Turn, pencilSharpener.contents[1]);
    }
    when = pencilSharpener.contents.length > 0
;

//==============================================================================
/* The PENCIL class */

class Pencil: Thing 'penna+n'
    "Den är <<if isSharpened>> rätt vass<<else>> ganska trubbig<<end>>. "
    dobjFor(Turn)
    {
        verify() 
        {
            /* 
             *   It's most useful to turn a pencil when it's in the 
             *   sharpener, so we'll boost the logical rank of such a pencil.
             */
            
            if(isIn(pencilSharpener))
                logicalRank(120);
        }
        action()
        {
            if(isIn(pencilSharpener))
            {
                "Du vrider <<theName>> några gånger och vässar till den fint. ";
                isSharpened = true;
            }
            else
                "Du snurrar runt med <<theName>>, men det hjälper inte så mycket. ";
        }
    }
    
    
    isSharpened = nil
    
    /* 
     *   Assigning a ListOrder to the Pencil class will ensure that Pencils 
     *   are listed together in a sensible way in room descriptions, 
     *   inventory listings and the like.
     */
    
    listOrder = 11  
;

/* 
 *   STATE object for the Pencil class so that pencils can be described as
 *   'sharp' or 'blunt'
 */

sharpenedState: State
    /* 
     *   This State will relate to any object that defines the isSharpened
     *   property (i.e. all Pencils), and the isSharpened property will
     *   determine which additional adjectives apply.
     */
    stateProp = &isSharpened
    
    /*   
     *   The additional adjective 'blunt' will apply to Pencils whose
     *   isSharpened property is nil, while the adjectives 'sharp' and
     *   'sharpened' will apply to Pencils whose isSharpened property is true.
     */
    adjectives = [[nil, ['trubbig', 'trubbiga']], [true, ['vass', 'vässad']]]
;


//==============================================================================
/*  
 *   CUSTOM ACTIONS AND GRAMMAR
 *
 *   Define the custom OpenWith action plus default action handlers for it. 
 */


DefineTIAction(OpenWith)
;

VerbRule(OpenWith)
    'öppna' multiDobj 'med' singleIobj
    : VerbProduction
    action = OpenWith
    verbPhrase = 'öppna/öppnar (vad) (med vad)'
    missingQ = 'vad vill du öppna;vad vill du öppna med'
;

modify Thing
    dobjFor(OpenWith)
    {
        preCond = [touchObj]
        
        /* For a multiplex container, remap OpenWith to the remapIn object */             
        remap = remapIn
        
        verify()
        {
            if(isOpenable)
                illogical('{Jag} {behöver} inte {ref iobj} för att öppna {denna dobj}. ');
            else
                illogical(&cannotOpenMsg);
        }
    }
    
    iobjFor(OpenWith)
    {
        preCond = [objHeld]
        verify()
        {
            illogical(cannotOpenWithMsg);
        }
    }
    cannotOpenWithMsg = '{Jag} {kaninte} öppna någonting med {detta iobj}. '
    
    /* 
     *   By default the library doesn't allow anything to be the indirect object
     *   of a PourOnto command -- the library simply responds with "You can't
     *   pour anything onto that" -- but it's obviously possible to pour stuff
     *   onto anything (even if we're going to stop the soup being poured for
     *   other reasons) so we'll override the library default.
     */    
    allowPourOntoMe = true
        
;


/* 
 *   With both the clock and the apron a player might try HANG CLOCK ON WALL 
 *   or HANG APRON ON PEG, so it would be good to allow this grammar. The 
 *   best way to do this is to make HANG ON a synonym for PUT ON. There are 
 *   two ways to do this: modify the existing VerbRule or create a new one. 
 *   Here we'll demonstrate the second method.
 */


VerbRule(HangOn)
    'häng' multiDobj 'på' singleIobj
    : VerbProduction
    action = PutOn // this makes it a synonym for PUT ON
    verbPhrase = 'hänga/hänger (vad) (på vad)'
    missingQ = 'vad vill du hänga;vad vill du hänga på'
;
