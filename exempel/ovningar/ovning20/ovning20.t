#charset "utf-8"

#include <tads.h>
#include "advlite.h"


/*   
 *   LIGHTHOUSE is a adv3Lite demo designed to illustrate implementing NPCs in 
 *   adv3Lite. It's loosely inspired by the Bop character used as an example in
 *   Mike Roberts's "Creating Dynamic Actors" article in the Technical 
 *   Manual.
 *
 *   There's a couple of endings you can reach, but you can't really win. As 
 *   with all these demos the point isn't playing the game but learning from 
 *   the sourc code (although as ever it's worth trying to play it to see 
 *   what the code does).
 */



versionInfo: GameID
    IFID = '058e959b-0b9d-41e7-be20-cf89edbfe97c'
    name = 'Exercise 20 - Fyren'
    byline = 'av Eric Eve (Översatt av Tomas Öberg)'
    htmlByline = 'av <a href="mailto:eric.eve@hmc.ox.ac.uk">Eric Eve</a>'
    version = '1'
    authorEmail = 'Eric Eve <eric.eve@hmc.ox.ac.uk>'
    desc = 'Ett kort spel för att demonstrera programmering av NPCer i adv3Lite'
    htmlDesc = 'Ett kort spel för att demonstrera programmering av NPCer i adv3Lite'
;

gameMain: GameMainDef
    /* Define the initial player character; this is compulsory */
    initialPlayerChar = me
    
    showIntro()
    {
        /*"You've only just moved into town, so you thought you'd pay the local
        store a visit to pick up some basic essentials. But you may be about to
        get more than you bargained for.\b";*/
        "Du har precis flyttat in till stan, så du tänkte att du skulle besöka 
        den lokala butiken för att köpa några basvaror. Men du kanske snart får
        mer än vad du hade räknat med.\b";
    }
    
    showGoodbye()
    {
        if(me.hasSeen(horrorChamber))
            "<.p>Tyvärr så var det allt gott folk! ";
        else
            "<.p>Du kanske ska försöka anstränga dig lite mer nästa gång! ";
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
 */
shop: Room 'Lanthandel'
    "Butiken har ungefär de där sakerna man kan förvänta sig i en lanthandel
    i en sömnig kuststad som denna. Den enda vägen ut är norrut."
    north = street
    out asExit(north)
    
    /* 
     *   followDesc is a custom property we are defining for use with an 
     *   accompanying NPC (see below). It's used to customize what's 
     *   displayed when the sally NPC accompanies the PC via a particular 
     *   connector.
     */
    followDesc = 'tillbaka in i affären'
;

/* 
 *   The player character object. This doesn't have to be called me, but me is a
 *   convenient name. If you change it to something else, rememember to change
 *   gameMain.initialPlayerChar accordingly.
 */

+ me: Player 'du'       
;

/*   
 *   Since this is a demo of NPCs, we'll keep the implementation of the map 
 *   and the physical objects in it as basic as possible, more or less to 
 *   the bare minimum needed to illustrate the various features of NPC 
 *   programming. For the same reason we'll only provide minimal commenting 
 *   for the map-building section of the code.
 *
 *   We don't need multiple rooms to illustrate conversation, but we do need 
 *   multiple rooms to illustrate an NPC who accompanies the PC on his 
 *   travels, so we'll still need several rooms in this map.
 */


+ Decoration 'kläd|ställning+en' 
    "Det är en ställning med massor av kläder på. "
;

+ cans: Decoration 'burkar+na; noggran:t+na stapla:de+t av[prep]; stapel+n burk+ar; dem' 
    "Burkarna är noggrant staplade. "    
;

street: Room 'Huvudgatan'
    "Det här ser ut att vara huvudgatan som löper genom staden. Här går den förbi 
    lanthandeln som är direkt söderut. Stadskärnan är västerut, medan gatan 
    lämnar staden österut. "
    
    south = shop
    in asExit(south)
    
    west: TravelConnector {         
        destination = street
        travelDesc = "Du vandrar runt i stadskärnan en stund, men hittar 
                    ingenting som fångar din uppmärksamhet, så du upptäcker så
                    småningom att dina fötter har tagit dig tillbaka dit du 
                    utgick från. "


    }
    
    east: TravelConnector {
        destination = road
        
        /* 
         *   followDesc is a custom property we're defining to customize the
         *   description of one actor following another through a
         *   TravelConnector. See below for how it's used in this demo game.
         */
        followDesc = 'längs gatan hela vägen ut ur stan, och sedan vidare 
            nerför vägen'
    }
;

road: Room 'Väg'
    "Vägen verkar ovanligt tyst, med väldigt lite trafik; just nu syns ingen
    till alls. Den går ganska rakt här, nästan raka vägen tillbaka in i staden 
    västerut, även om man kan se att den börjar böja sig en bit österut. Ett 
    öppet fält ligger söderut. "
    
    west = street
    east: TravelConnector { 
        destination = road
        travelDesc = "Du går en kort bit nerför vägen, vänder sedan om 
            och kommer tillbaka."
    }
    
    south: TravelConnector {
        destination = hillTop
        //followDesc = 'away from the road, across a field and up a shallow hill'
        followDesc = 'bort från vägen, över ett fält och uppför en låg kulle'
    }
;

+ Enterable 'Öppet fält' 
    "Det sluttar svagt uppåt mot öster. "
    destination = road.south
;

hillTop: Room 'Kulle'
    "Från toppen av kullen kan man tydligt se havet glittra en bit söderut. Det 
    ser ut som att man kan gå nerför kullen åt sydost, sydväst eller norrut. "
    
    southeast: TravelConnector {
        destination = cliff
        followDesc = 'nerför den bortre sidan av kullen och fortsätter en kort 
            bit mot kusten'
    }
    southwest: TravelConnector {
        destination = hillTop
        travelDesc = "Du går en kort bit ner mot sydväst, men kommer snart till
            en brant klippa med utsikt över havet. Eftersom du inte kan gå 
            längre i den riktningen vänder du om och kommer tillbaka."
    }
    north = road
    followDesc = 'tillbaka uppför kullen'
;

MultiLoc, Distant 'hav+et; blå+a våt:t+a vattnig:t+a lugn:t+a; havs|vatt:en+net'
    "Det ser lika blött och vattnigt ut som havet alltid gör, även om det 
    också ser någorlunda lugnt ut. "
    locationList = [cliff, cliffPath, hillTop]
;

cliff: Room 'Ensam klippa'
    "Stigen nerför sluttningen mot nordväst slutar på denna dystra klippsträcka, 
    med utsikt över havet flera dussin meter nedanför. En gammal fyr, strategiskt 
    placerad nära klippkanten, står omedelbart österut. I väster slingrar sig en 
    smal stig farofyllt längs klipptoppen. "

    northwest = hillTop
    
    east = lhDoor
    in asExit(east)
    west = narrowPath
;

+ lighthouse: Enterable 'fyr+en; skadad+e gam:mal+la'
    "Fyren står fortfarande kvar, men det ser ut som om den övre delen har 
    fått vissa skador."
    connector = lhDoor
;

/* 
 *   Using -> in the template is an alternative way of specifying the otherSide
 *   of a Door.
 */
++ lhDoor: Door ->lhDoorInside 'dörr+en;;fyrhusdörr+en' 
    followDesc = 'genom dörren in i fyren'
;

+ narrowPath: PathPassage 'smal+a stig+en' 
    "It snakes precariously along the cliff-top to the west. "
    destination = cliffPath
    followDesc = 'nerför den smala stigen'
;

cliffPath: Room 'Klippstig'
    "Stigen från nordväst når en återvändsgränd med utsikt över havet. "
    northwest = cliff    
;

lobby: Room 'Fyrlobbyn'
    "Detta verkar vara entréhallen till fyren. En spiraltrappa slingrar sig 
    upp till norr, och vägen ut är till väst, medan en andra utgång är till 
    öst. "
    west = lhDoorInside
    out asExit(west)
    north = lhStair
    up asExit(north)
    east = store
    
    followDesc = 'tillbaka in i lobbyn'
;

+ lhDoorInside: Door ->lhDoor 'dörr+en' 
    followDesc = 'tillbaka genom dörren'
;


+ lhStair: StairwayUp 'uppåtgående spiral|trappa+n;spiral|formad+e upp;; det dem'
    followDesc = 'upp för trappan'
    destination = midStair
; 


store: Room 'Förråd' 
    "Det här ser ut som om det en gång var ett förråd till fyren, men det har nästan
    plockats helt rent nu. Utgången tillbaka till lobbyn är västerut, men det finns 
    en annan utgång söderut. "
    west = lobby
    south = office
    out asExit(west)
    followDesc = 'in i förrådet'
;

office: Room 'Kontor'
    "Det slitna gamla träskrivbordet som står i hörnet antyder att detta en gång 
    i tiden var ett kontor av något slag, men det finns inte mycket annat här nu. 
    Den enda vägen ut är norrut. "
    north = store
    out asExit(north)
    followDesc = 'in på kontoret'
;

+ Surface, Heavy 'skriv|bord+et; slit:et+na gam:malt+la träskrivbord+et'
    "Det har definitivt sett bättre dagar. "
;

midStair: Room 'På trappan'
    "Ungefär halvvägs uppför fyren passerar spiraltrappan en ekdörr i öster. "
    down = midStairDown
    up = midStairUp
    east = oakDoor
;

+ midStairDown: StairwayDown 'nedåtgående spiral|trappa+n;spiral|formad+e ner;; det dem'    
    destination = lobby 
    followDesc = 'tillbaka ner för trappan'
;


+ midStairUp: StairwayUp 'uppåtgående spiral|trappa+n;spiral|formad+e upp;; det dem'
    destination = location    
    travelDesc =  "Du kommer bara en kort bit längre uppför trappan innan du 
        upptäcker att vägen har blockerats av fallande murverk, så du är tvungen 
        att vända och komma tillbaka. "   
;

+ oakDoor: Door ->horrorDoor 'ek|dörr+en;ek av[prep]'
    followDesc = 'genom dörren'
;

horrorChamber: Room 'Skräckkammaren'
    /* 
     *   Normally it would be a bad idea to include a description of the PC's
     *   first reaction to a location in the desc property (we should 
     *   normally use roomFirstDesc for this), but since this room 
     *   description will only ever be displayed once, when the PC first 
     *   enters this room, it doesn't matter here.
     */
    "Synen som möter dina ögon när du går in i detta rum förvånar, äcklar och 
    skrämmer dig på en och samma gång. Du blir bokstavligen stum av fasa. Du 
    visste inte vad du skulle förvänta dig, men aldrig i dina vildaste 
    mardrömmar föreställde du dig något liknande <i>detta</i>..."

    east = horrorDoor
    out asExit(east)
;

+ horrorDoor: Door ->oakDoor 'ek|dörr+en;ek av[prep]' 
;


//==============================================================================
/*   
 *   CLASS DEFINITION
 *
 *   Later in the game we'll be creating Can objects dynamically, so we need 
 *   to define a Can class.
 */

class Can: Thing 'burk+en; rund+a aluminium|plåt+en av[prep]; plåt+en'
    "Den är rund och gjord av plåt -- eller kanske aluminium. "
            
    /* 
     *   We want to keep track of the total number of Cans we've created, so 
     *   we do this in the construct() method. Note that we keep this count 
     *   on the Can class, not on individual Can objects.
     */
    construct()
    {
        inherited();
        Can.cansCreated ++;
    }
    cansCreated = 0
;


//==============================================================================
/*  
 *   THE MAIN NPC CODE STARTS HERE
 *
 *   There'll be two NPCs in this game. Bob, the shopkeeper, will be used to 
 *   demonstrate the standard method of implementing conversations in adv3Lite. 
 *   Sally, the other, will be used to illustrate an NPC who accompanies 
 *   the PC on his travel, as well as other features such as AgendaItems and 
 *   Conversation Nodes. 
 *
 *
 *   We'll start by modifying the standard library Actor class to provide 
 *   some tweaks we should find useful.
 */


modify Actor
    /* 
     *   We often don't know the name of NPCs when we first encounter them, 
     *   so that to begin with they have generic descriptions like 'a tall 
     *   man' or 'a blonde woman'. But once the PC knows an NPC's proper 
     *   name, that's the name that should be used. makeProper() is a custom 
     *   method we define to handle giving an NPC a proper name once we know 
     *   what it is.
     */
    
    makeProper()
    {
        /* 
         *   Calling addVocab in this way simultaneously changes the name of the
         *   Actor to properName, makes it proper (if every word in properName
         *   starts with a capital letter) and adds properName to this actor's
         *   vocabWords.
         */
        addVocab(properName);
        
        /*   
         *   Return the properName to the caller, so it can be used in 
         *   constructions like "<q>Hi, I'm <<properName>>,</q> the man 
         *   introduces himself.
         */
        return properName;
    }
    
    /* 
     *   properName is a custom property we define to contain the NPC's 
     *   proper name -- what he or she will be known by once the PC knows 
     *   his or her name.
     */
    properName = nil

    /*  
     *   The first time an actor's mentioned we expect him or her to be 
     *   described with the indefinite object ("A tall man is standing 
     *   here"); thereafter we'd expect to see the definite article ("The 
     *   tall man is standing here"). We therefore override theName (and add 
     *   a custom previouslyMentioned property) to produce this effect; the 
     *   first time theName is called it will return aName; thereafter it 
     *   will return the inherited version of theName.
     */
    
    timesMentioned = 0
    theName = (timesMentioned++ ? inherited : aName)
    
    /*  
     *   There aren't many portable objects in this game (unless the player 
     *   start collecting cans from Bob), but the standard library response 
     *   for throwing things at things is quite inappropriate when the 
     *   target is a person, (e.g. "The can hits Bob without any obvious 
     *   effect and falls to the floor") that we should in any case override 
     *   it.
     */
    
    iobjFor(ThrowAt)
    {
        check()
        {
            "Du är inte som ett barn som får ett utbrott; du vet bättre än att 
            börja kasta saker på folk. ";
        }
    }
    
;


//==============================================================================
/*  
 *   CODE FOR THE BOB NPC 
 *
 *   There's usually a lot of code and objects associated with an NPC, so 
 *   where an NPC is at all complex it's best to keep the NPC code separate 
 *   from the rest of the room and game code.
 *
 *   PERSON
 *
 *   There's not much to define on the Person object itself, since most of 
 *   Bob's behaviour will be implemented in his ActorStates and Topic 
 *   Entries. 
 */

bob: Actor 'lång+a man+nen;;människor+na[pl]; honom'  @shop
    "Han är en man med ett magert ansikte och en aning böjd rygg; man 
    skulle kunna uppskatta att han var närmare sextio än femtio. "
       
    /* Remember, this is a custom property. We just defined it above/ */
    properName = 'Bob'
      
    /* 
     *   It's useful to define a globalParamName on an NPC, so we can refer 
     *   to him or her in paramater substitution string (such as '{the 
     *   bob/he}'). This is particular useful when the name of the NPC might 
     *   change in the course of play (e.g. from 'the tall man' to 'Bob' if 
     *   and when we learn Bob's name), but we don't know in advance when 
     *   this will happen. 
     */
    globalParamName = 'bob'
    
    /*   Customize the responses for ATTACK/HIT/KICK/KILL BOB and KISS BOB */    
    cannotAttackMsg = 'Det verkar inte finnas någon uppmaning till våld. '
    kissResponseMsg = 'Ingen av er skulle tycka om det särskilt mycket. '
;    


/*  
 *   UNTHING
 *
 *   It's debatable whether the player who already knows that the tall man is
 *   called Bob should be able to refer to him as 'Bob' before the player 
 *   character has officially learned his name. In this example we're 
 *   assuming not, but you may well prefer to do things differently in your 
 *   own games, (in which case just include 'bob' or whatever in the NPC's 
 *   vocabWords property when you first define him or her.
 *
 *   But the problem then is what to do when the player does try to refer to 
 *   Bob before the PC has learned his name. If we haven't defined 'bob' in 
 *   bob's vocabWords the game will respond with "The word �bob� is not 
 *   necessary in this story. ", but that's simply untrue!
 *
 *   One way to get round this is with this little trick using an Unthing, 
 *   which we attach to Bob so it's always in scope when Bob is in scope. 
 *   Then if the player tries to refer to Bob before Bob has been named, 
 *   s/he'll get the response "You don't know anyone called Bob yet", which 
 *   is at least better than the default. Once Bob has named, the Unthing 
 *   will simply be ignored (since the parser always prefers any other 
 *   object to an Unthing if one is available).
 */


+ Unthing 'bob' 
    'Du känner inte någon som kallas Bob ännu. '
;

/*  
 *   INITIAL ACTOR STATE
 *
 *   bobStacking is the ActorState Bob is in when he's not 
 *   actually engaged in conversation, but can be. When the PC talks to Bob, 
 *   we'll switch Bob to the bobTalking.
 *
 *
 */

+ bobStacking: ActorState
    /* This is the state Bob starts out in. */
    isInitState = true
    
    /* 
     *   commonDesc is not a library property; it's a custom property we're 
     *   defining to avoid the need to duplicate text in the specialDesc and 
     *   stateDesc properties.
     */
    commonDesc = 'staplar flitigt burkar längst bak i butiken'
    
    /*   
     *   How Bob will be mentioned in a room description when he's in this 
     *   state.
     */
    specialDesc = "{Ref subj bob} <<commonDesc>>. "
    
    /*   
     *   The stateDesc will be added to the end of the description provided 
     *   by bob.desc when Bob is in this ActiveState and the player examines 
     *   Bob.
     */
    stateDesc = "Han <<commonDesc>>. "    
;


/*
 *   HELLO TOPIC
 *
 *   A HelloTopic is used to handle Bob's response to BOB, HI, or TALK TO BOB,
 *   when Bob is in this ActorState. Since we're not also defining an
 *   ImpHelloTopic it will also be used when the PC addresses any conversational
 *   command to Bob (e.g. ASK MAN ABOUT THE WEATHER) while he's in the
 *   ActorState, in which case the conversational exchange defined in the
 *   HelloTopic will occur before the specific topic asked about is handled (and
 *   Bob will then switch into the bobTalkingState, as defined on this
 *   HelloTopic).
 *
 *   Note that HelloTopics are normally located in the ActorState the actor's in
 *   just prior to the start of the conversation.
 *
 *   By combining HelloTopic with  StopEventList we can vary the response Bob
 *   gives each time he is addressed.
 */

++ HelloTopic, StopEventList
    [
        '<q>Hallå där!</q> säger du.\b
        <q>God morgon, herrn,</q> svarar han och vänder sig mot dig. ',

        '<q>Ursäkta mig,</q> säger du.\b
        <q>Ja?</q> svarar han och vänder sig mot dig. ',

        '<q>Hallå igen,</q> hälsar du honom.\b
        <q>God morgon ännu en gång, herrn,</q> svarar han och vänder sig mot dig.'
    ]
    
    /* 
     *   When this HelloTopic is invoked at the start of a conversation we'll
     *   switch Bob to the bobTalking state.
     */
    changeToState = bobTalking
;

/*   
 *   ACTOR STATE WHILE BOB IS IN CONVERSATION
 *
 *   To implement a conversation with Bob, we also define the the ActorState
 *   he's in when conversing with the player character
 */

+ bobTalking: ActorState
    /* 
     *   The specialDesc defines how Bob will be described in a room 
     *   description when he's in this ActorState. Note the use of {Ref subj
     *   bob} which will expand to either 'Bob' or 'The tall man', 
     *   depending on whether or not the PC has yet learned Bob's name.
     */
    specialDesc = "{Ref subj bob} står mitt emot dig, med ena handen 
        på höften och den andra hållandes en burk. "
;

/*
 *   BYE TOPIC
 *
 *   We use a ByeTopic to end a conversation just as we use a HelloTopic to
 *   begin with. Since we're also defining an ImpByeTopic, this ByeTopic will
 *   only be triggered in the player explicitly bids Bob goodbye (e.g. with a
 *   BYE command). Note that ByeTopics are normally located in the state the
 *   actor is in while talking.
 */    

++ ByeTopic
    "<q>Nåväl, adjöken då!</q> säger du.\b
    <q>Ha en bra dag, herrn,</q> svarar {ref subj bob} innan han återvänder till 
    sin stapel med burkar. "

    
    /* 
     *   Change Bob back to the bobStacking state when this ByeTopic is invoked.
     */
    changeToState = bobStacking
;

/*   
 *   IMP BYE TOPIC
 *
 *   An ImpByeTopic is just like a ByeTopic, except that it is triggered 
 *   when a conversation is terminated other than with an explicit GOODBYE. 
 *   This may happen if the Player Character simply walks away in the middle 
 *   of the conversation, or if s/he fails to address Bob for so many turns 
 *   (defined in the InConversationState's attentionSpan property) and Bob 
 *   gets bored waiting for the PC to speak. If we want to distinguish 
 *   between these two implicit Bye cases we can use LeaveByeTopic and 
 *   BoredByeTopic, but here we'll just use an ImpByeTopic to cover both 
 *   cases. 
 */

++ ImpByeTopic
    "{Ref subj bob} vänder sig bort och återupptar staplingen av burkar. "
    
    /* 
     *   Change Bob back to the bobStacking state when this ByeTopic is invoked.
     */
    changeToState = bobStacking
;

/*   
 *   ASK TOPIC, WITH SUGGESTION
 *
 *   An AskTopic is used to respond to a question such as ASK BOB ABOUT WHATEVER
 *   (which can be abbreviated to A WHATEVER one a conversation is underway).
 *   The AskTopic defined below will match the question ASK BOB ABOUT LIGHTHOUSE
 *   (because 'lighthouse' is defined in the vocabWords of the lighthouse
 *   object). But note that the PC must first know about the lighthouse before
 *   this topic becomes available.
 *
 *   By giving this AskTopic a name we include it in the topic inventory - the
 *   list of suggested topics for conversation displayed in response to a TOPICS
 *   command or to TALK ABOUT BOB. Note that the topic will only be suggested
 *   when the TopicEntry becomes available, i.e. when the PC knows about the
 *   lighthouse.
 */
++ AskTopic @lighthouse
    "<q>Så vad hände vid fyren?</q> vill du veta.\b
    <q>Tja,</q> börjar han, <q>det var så här -- för flera år sedan...</q> han 
    avbryter sig, som om han brottas med sig själv, sedan fräser han plötsligt, 
    <q>Låt bli att gå dit bara, det är allt du behöver veta!</q> "
    
    /* The name we use to describe this topic in a list of suggested topics. */
    name = 'fyren'
;

/*
 *   TELL TOPIC, SUGGESTED
 *
 *   TellTopic is the converse of AskTopic. It defines the response to a 
 *   command like TELL BOB ABOUT WHATEVER (in this case TELL BOB ABOUT 
 *   MYSELF or T MYSELF). We give it a name so that it 
 *   appears in a list of suggested topics (note we don't have to do this; 
 *   it's up to the game author whether a particular TopicEntry should be 
 *   suggested or not). 
 *
 *   By combining the TellTopic with ShuffledEventList we can vary the 
 *   response. This is often a good idea for creating more life-like NPCs.
 */
++ TellTopic, ShuffledEventList @me
    /* 
     *   When we define two lists for a ShuffledEventList, the items in the 
     *   first list are first shown in order.
     */
    [        
        '<q>Jag är ny här,</q> säger du.\b
        <q>Det förklarar nog varför vi inte har träffats förut,</q> anmärker han. '
    ]
    
    /*  
     *   After the items in the first list have been shown, the items in the 
     *   second list are displayed in shuffled-random order. We don't need to
     *   define both lists; if we only define one, it will be used as a 
     *   shuffled list.
     */    
    [
        '{Ref subj bob} lyssnar artigt medan du berättar en del av din 
        livshistoria.',

        '{Ref subj bob} gör sitt bästa för att låtsas att han tycker att 
        du är ett lika fascinerande samtalsämne som du verkar vara.',

        '<q>Vad intressant!</q> muttrar han.'
    ]
    
    /* The name for the list of suggested topics */
    name = 'dig själv'
;


/*  
 *   Another ASK TOPIC
 *
 *   This time we mix it in with a StopEventList, which will display each 
 *   item in turn and then keep displaying the last one.
 *
 *   The @bob means the bob object, of course, but while we're talking to bob
 *   this can be referred to as 'himself', so this topic will match ASK BOB 
 *   ABOUT HIMSELF.
 */
++ AskTopic, StopEventList @bob
    [
        /* 
         *   We can't include a double-quoted string in an EventList, but we 
         *   can include a function pointer, which is what wrapping a 
         *   double-quoted string in the {: } short-form anonymous function 
         *   notation actually does. This enables us to invoke 
         *   bob.makeProper() using the <<>> syntax; bob.makeProper() 
         *   returns 'Bob', so this is what it displays, but it also carries 
         *   out the corresponding changes on the bob object.
         *
         *   An alternative would have been to write:
         *
         *   '<q>By the way, I don\'t think I caught your name,</q> you 
         *   say.\b <q>I\'m '+ bob.makeProper() + ',</q> he tells you. '
         */        

        {: "<q>Du förresten, jag tror inte att jag uppfattade ditt namn,</q> säger du.\b
            <q>Jag heter <<bob.makeProper()>>,</q> berättar han. " },

        '<q>Har du jobbat här länge?</q> frågar du.\b
        <q>Bara de senaste fyrtio åren,</q> svarar han. ',

        'Du kan inte komma på något att fråga honom om sig själv just nu.'
    ]    
    name = 'honom själv'
    
    /* 
     *   Once the player has seen the first two responses, the response to 
     *   ASK BOB ABOUT HIMSELF ceases to be interesting, so there's no point 
     *   in suggesting it any longer. So we'll only suggest it twice (note 
     *   that the default value of timesToSuggest is 1).
     */
    timesToSuggest = 2
    
    /*
     *   Normally ASK BOB ABOUT WHATEVER would trigger the greeting protocols
     *   (the HelloTopic) when Bob is in his ConversationReadyState. But the
     *   final response suggests that no conversational exchange actually 
     *   takes place, so it would be inappropriate to display a greeting 
     *   only to have a message say that you can't think of anything to ask. 
     *   We can avoid this by marking this TopicEntry as non-conversational 
     *   once the final response is reached. Since we've already defined 
     *   timesToSuggest = 2 this is equivalent to marking it as 
     *   non-conversational once curiosity has been satisfied.
     */    
    isConversational = (!curiositySatisfied)    
;

/*  
 *   ASK TELL SHOW TOPIC
 *
 *   An AskTellShowTopic responds to ASK ABOUT, TELL ABOUT and SHOW 
 *   commands, so that this one will respond to ASK BOB ABOUT BLONDE, TELL 
 *   BOB ABOUT BLONDE, or SHOW BLONDE TO BOB.
 */
++ AskTellShowTopic, StopEventList @sally
    [

        {: "<q>Vem är den blonda kvinnan där borta?</q> frågar du.\b
            <q>Det är <<sally.makeProper()>>, herrn,</q> svarar han. "
        },

        '<q>Är {ref subj sally} en stamkund här?</q> frågar du.\b
        <q>O-ja, herrn, en av mina bästa,</q> svarar han. ',

        'Du har frågat tillräckligt om {ref sally} för studen; du 
        vill inte ge {ref bob} intrycket att du är fixerad av henne! '
    ]
    
    /* 
     *   We want this topic to be suggested as 'ask Bob about the blonde 
     *   woman' before we learn Sally's name and 'ask Bob about Sally' 
     *   thereafter.
     */
    name = (sally.theName)
    
    /*   
     *   The first question presupposes that Sally is present to be asked 
     *   about, so we make this TopicEntry active only when Sally is in the 
     *   shop.
     */    
    isActive = (sally.isIn(shop))
    timesToSuggest = 2
    isConversational = (!curiositySatisfied)
;


++ AskTopic, StopEventList @tTown
    [
        /* 
         *   Until the player sees this response, the player character 
         *   hasn't even heard of the troubles. The tag <.reveal troubles> 
         *   notes the fact that the topic of troubles has now been 
         *   mentioned. Note that 'troubles' is an arbitrary string here; we 
         *   could have used <.reveal xp1-q34r>, except it wouldn't have 
         *   been so meaningul. Had we for example wanted to distinguish Bob 
         *   mentioning the troubles from Sally mentioning the troubles, we 
         *   could use <.reveal bob-troubles> and <.reveal sally-troubles>.
         */        
        '<q>Vad tycker du om staden?</q> frågar du.\b
            <q>Åh, den är fantastisk. Helt fantastisk,</q> svarar han. Med sänkt röst 
            tillägger han, <q>nu när problemen är över.</q><.reveal troubles> ',

        'Han tillgodoser dig en med en hel del information om ställen att äta och shoppa på, 
        besöka och undvika längs hela vägkurvan. Du tar inte en tiondel av allt.'
    ]
    name = 'staden'
;


/*  
 *   ASK TELL TOPIC
 *
 *   Since this is an AskTellTopic it will be used as a response to both ASK 
 *   BOB ABOUT TROUBLES and TELL BOB ABOUT TROUBLES.
 */
++ AskTellTopic, StopEventList @tTroubles
    [
        /*  
         *   The first response to ASK ABOUT TROUBLES mentions the 
         *   lighthouse, so once the player has seen this response, the PC 
         *   knows about the lighthouse. We can mark this by using 
         *   <.known lighthouse>. 
         */        
        '<q>Du sa något om några problem,</q> anmärker du, <q>vad handlade 
            det om egentligen?</q>\b
        <q>Tja,</q> börjar han, <q>allt började uppe vid fyren...</q>
        han avbryter sig och skakar på huvudet, <q>Nej, du vill verkligen 
        inte veta, du vill verkligen inte -- tro mig!</q><.known lighthouse> ',

        '{Ref subj bob} vägrar ståndaktigt att berätta något mer om problemen.'
    ]
    
    /* 
     *   Here we test whether the tag 'troubles' has been revealed in order 
     *   to decide whether this TopicEntry is active.
     *
     *   tTroubles is a Topic, not a Thing (see below), so it starts out 
     *   known by default. As an alternative to using <.reveal troubles> and 
     *   testing for gRevealed('troubles') here we could have overridden 
     *   isKnown to nil on tTroubles and then used gSetKnown(tTroubles) to 
     *   make it known once Bob mentioned the troubles. 
     */
    isActive = gRevealed('troubles')
    name = 'problemen'
;


/*   
 *   TALK TOPIC
 *
 *   A TalkTopic responds to TALK ABOUT SO-AND-SO. In this case, TALK ABOUT THE
 *   WEATHER.
 *
 *   Note that tWeather is another Topic (defined below) not a Thing. Using a
 *   lower case initial t to distinguish Topics from Things in this way is just
 *   a convention I employ, not a requirement; but it's useful to adopt some
 *   such convetion.
 */
++ TalkTopic @tWeather
    "<q>Vilket fint väder vi har,</q> anmärker du.\b
    <q>Inte alls illa för årstiden, sir,</q> håller han med."
    name = 'vädret'
;

/*   
 *   ASK FOR TOPIC
 *
 *   We use an AskForTopic to handle commands like ASK BOB FOR SOMETHING. 
 *   Since Bob is desribed as stacking cans we'll allow the PC to ask for a 
 *   can; but since it's irrelevant to the plot, we shan't suggest it. 
 */
++ AskForTopic @cans
    topicResponse()
    {
        "<q>Kan jag få en en sån där burk, tack?</q> frågar du.\b
        <q>Javisst,</q> svarar han. Han vänder sig om, plockar upp en burk 
        och sedan vänder han sig tillbaka och räcker den till dig. 
        <q>Varsågod,</q> säger han. ";
        
        /*  Create a new Can object and then move it to the PC's inventory. */
        local obj = new Can;
        obj.moveInto(me);
    }
;

/*   
 *   ALTERNATIVE RESPONSE
 *
 *   We use another AskForTopic to provide an alternative response to a
 *   conversational command when a particular condition (defined in the isActive
 *   property) holds. By giving it a higher matchScore (the + property in the
 *   template) we make sure it's used in preference to the previous AskForTopic
 *   when its isActive property becomes true.
 *.
 *
 *   Here we use the second AskForTopic to put a limit on the number of cans the
 *   PC can ask for, since we don't want the game to generate an infinite number
 *   of dynamically-created cans. Ten cans should be more than enough, so we'll
 *   stop when 10 cans have been created.
 *
 *   The other (and possibly neater way) of providing an alternative response is
 *   to use an AltTopic, which will be illustrated below.
 */
++ AskForTopic +110 @cans
    "Du har mer än tillräckligt med burkar nu. "
    isConversational = nil
    isActive = Can.cansCreated >= 10
;


/*   
 *   ASK TELL GIVE SHOW TOPIC
 *
 *   An AskTellGiveShowTopic provides the same response to ASK BOB ABOUT X, 
 *   TELL BOB ABOUT X, SHOW X TO BOB and GIVE X TO BOB. Here we'll use it for
 *   asking about, telling about, showing or giving cans.
 *
 *   There's one complication, though; the PC can only give Bob a can if the 
 *   PC is holding a can, and since the Can objects given to the player are 
 *   created dynamically, we don't have an object name for any such can. We 
 *   can instead test for an object belonging to the Can class.
 *
 *   If it were allowed, we'd simply express the matchObj for this 
 *   TopicEntry as a list:
 */
++ AskTellGiveShowTopic [cans, Can]
    "<q>Vad är det i burkarna?</q> frågar du.\b
    <q>Bakade bönor,</q> svarar han rappt, <q>inte vilka bakade bönor som helst, dock
    -- bönorna i de där burkarna är miljövänliga, cancerfria ekologiska
    fiberrika bakade bönor -- de allra bästa!</q> "

;

/*  
 *   DEFAULT ASK TOPIC
 *
 *   The chances are the player will try to ASK Bob about topics for which we
 *   haven't replied a response. We can use a DefaultAskTopic to deal with 
 *   these commands. To avoid making the NPC look like a talking robot, it's 
 *   best to vary such responses, so we also make the DefaultAskTopic a 
 *   ShuffledEventList.
 */

++ DefaultAskTopic, ShuffledEventList
    [
        '{Ref subj bob} rynkar förbryllat på pannan, som om han inte förstod 
        din fråga. ',

        '<q>Ja, ja,</q> börjar han, och sedan babblar han fram ett så snabbt 
        svar att man inte hör ett ord av det. ',

        '<q>Som jag ser det...</q> börjar han; men sedan försvinner resten av 
        hans svar i ett hostattack.'
    ]
;

/*   
 *   DEFAULT TELL TOPIC 
 *
 *   We use DefaultTellTopic to cater for topics we haven't provided a 
 *   specific TELL ABOUT response to.
 */
++ DefaultTellTopic
    "{Ref subj bob} lyssnar artigt medan du pladdrar på. "
;

/*  
 *   We can use a CommandTopic to provide a response to particular 
 *   commands such as BOB, JUMP (as here).
 *
 *   CommandTopic doesn't make it particularly easy to match command 
 *   involving particular objects, such as BOB, TAKE THE RED BALL or BOB, 
 *   PUT THE RED BALL IN THE GREEN BOX; to match such commands you'd need to 
 *   override the matchTopic() method of the CommandTopic. Alternatively you 
 *   could just download and use the TCommand extension.
 */

++ CommandTopic @Jump
    "<q>Hoppa!</q> ropar du!\b
    {Ref subj bob} blir så förskräckt att han hoppar till. "
;

/*  
 *   DEFAULT COMMAND TOPIC
 *
 *   We use a DefaultCommandTopic to handle all orders given to the Bob for
 *   which we haven't provided a customised response. We can use the
 *   actionPhrase property to represent the command the player just issued.
 */
++ DefaultCommandTopic
    "<q>\^<<actionPhrase>>!</q> kommenderar du.\b    
    <q>Jag vill inte vara oförskämd, herrn, men jag anser inte att ni har någon 
    rätt att bossa runt med mig,</q> klagar han. "
;
     
++ DefaultAskForTopic
    "<q>Jag tror tyvärr inte att jag kan hjälpa till där, herrn,</q> svarar han. "

;


//==============================================================================
/*  
 *   CODE FOR THE SALLY NPC
 *
 *   Sally is a more complex NPC than Bob, in that she'll lead the PC to the
 *   lighthouse and then follow him around. We also use her to illustrate
 *   ConvNodes and AgendaItems.
 *
 *   To begin with a summary: Sally starts out in the shop looking for clothes,
 *   but can't be talked to while she's in that state. As soon as she hears Bob
 *   mention the troubles she goes outside the shop to wait for the PC. When the
 *   PC emerges from the shop she offers to take him to the lighthouse. If he
 *   refuses, the game ends then and there. If he accepts she leads him to the
 *   lighthouse. Once they arrive at the lighthouse she will follow the PC
 *   (there's no particular reason for this swap of leading character other than
 *   to demonstrate the two different ways in which an NPC can be made to
 *   accompany the PC). Once they start to explore the lighthouse together they
 *   come face to face with the origin of the troubles.
 *
 */



sally: Actor 'blond+a kvinna+n; li:ten+lla och söt+a; människor+na[pl]; henne' @shop
    "Hon är en liten blondin med ett fint runt ansikte. "
    
    properName = 'Sally'
    
    globalParamName = 'sally'
    
    cannotAttackMsg = 'Du är inte den sortens man som går runt och attackerar 
        försvarslösa kvinnor. '
    
    kissResponseMsg = ('Bäst att låta bli; ' + (gRevealed('married') ?
                             'du har redan berättat att du är gift. ' : 'du
                                 känner inte henne särskilt väl. '))
;

/*  
 *   We add an Unthing to Sally as we did for Bob, to handle attempts to 
 *   refer to Sally before the PC has learned her name.
 */
+ Unthing 'sally' 
    'You don\'t know anyone called Sally yet. '
;


/*  
 *   NO RERSPONSE STATE
 *
 *   A No Response State is an ActorState in which an NPC will not respond to
 *   any conversational commands. It can be used to represent an NPC who is
 *   preoccupied, stand-offish, unconscious, or even dead. Here we start Sally
 *   off in a No Response State since we don't want the PC to talk to her until
 *   they meet outside the shop. While he's in the shop the PC should
 *   concentrate on talking to Bob. We make an ordinary actor state behave as a
 *   No Response State simply by defining its noResponse property to display the
 *   reason the actor is refusing to respond.
 *
 *   If we mix in an EventList class with an ActorState, the EventList's
 *   doScript() method will be called every tutn the NPC is in the state, so
 *   that we can display a list of messages indicating that that NPC is actually
 *   doing something. Here we make the ActorState also a ShuffledEventList
 *   so that Sally looks a bit livelier than a tailor's dummy while she's
 *   shopping for clothes.
 */

+ sallyShopping: ActorState, ShuffledEventList
    /* This is the state Sally starts out in. */
    isInitState = true
    
    /* 
     *   This is how Sally will be listed in a room description when she's in
     *   this ActorState.
     */
    specialDesc = "{Ref subj sally} står vid klädstället och inspekterar noggrant
         allt som erbjuds. "
    
    /* 
     *   This will be appended to the description of Sally when she's in this
     *   ActorState.
     */
    stateDesc = "Hon står vid klädstället och inspekterar vad som erbjuds. "
    
    
    
    /*   
     *   The list of random messages to display while the actor is in this 
     *   state.
     */
    eventList = [
        '{Ref subj sally} tar en kappa från hyllan, håller den mot kroppen,
        sedan skakar hon på huvudet och lägger den tillbaka på hyllan. ',
        
        '{Ref subj sally} fortsätter att rota igenom hyllan. ',
        
        '{Ref subj sally} plockar upp en hatt och provar den. Hon drar ner den över ansiktet, 
        rynkar pannan och sätter sedan tillbaka den',
        
        {: "{Ref subj sally} tar en <<rand('kjol', 'blus', 'klänning',
                                           'jumper')>> från hyllan och muttrar
            något ogillande om fel nyans av <<rand('blå',
                'grön', 'gul', 'orange', 'rosa', 'lila')>>. "
        },
        
        '{Ref subj sally} kämpar med att få ner ett par byxor från hyllan, 
        sen bestämmer hon sig för att de är för långa, och så kämpar hon med 
        att sätta tillbaka dem igen. '
    ]
    
    /* 
     *   It would be intrusive to see these messages every turn, so we'll 
     *   start off displaying them on average on two turns out of three.
     */
    eventPercent = 67
    /*   
     *   Once the player has seen all these messages once, it's probably 
     *   best to make them less frequent before they start to seem obviously 
     *   repetitive and tiresome, so we'll reduce the frequency to one turn 
     *   in three once after displaying five messages.
     */
    eventReduceTo = 33
    eventReduceAfter = 5
    
    /*   
     *   When Sally leaves the shop the default message would be "Sally/The 
     *   blonde woman leaves to the north." We replace that here with 
     *   something more appopriate to the context.
     */
    sayDeparting(conn)
    {
        //"Then she turns away again and hurries out of the shop. ";
        "Sedan vänder hon sig om igen och skyndar ut ur butiken. ";
    }
    
    /*  
     *   If a noResponse method is defined, as here, it will be used as the
     *   response to all conversational commands directed at Sally while she's
     *   in this state.
     */
    noResponse =  "Du vet bättre än att avbryta en kvinna medan hon letar efter fynd 
        på klädstället. "
;


/*  
 *   ACTOR STATE
 *
 *   This ActorStatre is used while Sally is waiting outside the shop.
 */
+ sallyStreetState: ActorState
    specialDesc = "{Ref subj sally} står precis utanför butiken. "
;


/*  
 *   We put Sally into this state when she's leading (i.e. when she wants the
 *   player character to follow her.
 */
+ sallyLeadingState: ActorState
    specialDesc = "{Ref subj sally} är precis bredvid dig. "
    stateDesc = "Hon är precis bredvid dig. "
    
    activateState(actor, oldState)
    {
        /* 
         *   Most of the work of acting as an actor the PC can follow is
         *   actually done by a FollowAgendaItem, so here we add a suitable
         *   FollowAgendaItem to Sally's agendaList when she enters this state.
         */
        actor.addToAgenda(sallyLeadingAgenda);
    }
;

/* 
 *   FOLLOW AGENDA ITEM
 *
 *   A FollowAgendaItem is used when we want the player character to be able to
 *   follow another actor, in this case Sally.
 */
     
+ sallyLeadingAgenda: FollowAgendaItem
    /* 
     *   The list of TravelConnectors we want Sally to lead the player character
     *   through. When we get to the end of the list, the FollowAgendaItem is
     *   done with.
     */
    connectorList = [street.east, road.south, hillTop.southeast]
    
    /*   
     *   The noteArrival method is called after Sally has been followed to the
     *   final destination along her route. Here we use it to change Sally to a
     *   different ActorState, which would be a fairly common use of this
     *   method.
     */
    noteArrival() 
    {
        getActor.setState(sallyArriving);
    }
    
    /*  
     *   The arrivingDesc is shown each turn just after the player character has
     *   followed the actor. The default is to say "Sally is waiting for you to
     *   follow her to the [whichever direction]. Here we use the default except
     *   right at the end, when we've arrived at the cliff, when we display a
     *   custom message.
     */
    arrivingDesc() 
    { 
        if(me.isIn(cliff))
            "{Ref subj sally} stannar till utanför den gamla fyren och 
            vänder sig om och möter din blick. ";

        else
            inherited; 
    }
    
    /* 
     *   The sayDeparting(conn) message is used to describe the player character
     *   following the actor each time they move. Here we customize it to make
     *   use of the custom followDesc property defined on another of
     *   TravelConnectors above.
     */
    sayDeparting(conn)
    {
        "Du följer med Sally <<conn.followDesc>>. ";
    }
;

/*   
 *   ACTOR STATE
 *
 *   Sally will leave this ActorState almost as soon as she enters it. It's 
 *   purpose is to smooth the transition from Sally leading the PC to Sally 
 *   following the PC.
 */

+ sallyArriving: ActorState
    activateState(actor, oldState)    
    {      
        
        sally.actorSay('<q>Ja, då är vi här,</q> säger hon till dig, <q>Det är
            här allt började. Ska vi gå in?</q><.convnode lighthouse>');      
    }    

    specialDesc = "{Ref subj sally} står precis brevid fyrhusdörren. "
    
    /* As soon at the PlayerCharacter moves Sally will start following him. */
    beforeTravel(traveler, connector)
    {
        getActor.setState(sallyFollowingState);
    }
    
    
;

/*  
 *   ACCOMPANYING STATE
 *
 *   To make an actor follow the PC around we actually need to call the
 *   startFollowing method on the actor. But we often want the actor to be in
 *   particular ActorState while following, so here we define an ActorState for
 *   the purpose which calls Sally's startFollowing() method when it's
 *   activated. Once she enters this state, Sally will remain in it for the rest
 *   of the game.
 */

+ sallyFollowingState: ActorState
    specialDesc = "{Ref subj sally} är vid din sida. "
    
    /* 
     *   The arrivingTurn() method is called each time the NPC arrives in a 
     *   at a location while following the PC. Here we use it to make Sally 
     *   say or do something via an InitiateTopic keyed on the location just 
     *   arrived at; calling sally.initiateTopic(obj) will cause the 
     *   corresponding InitiateTopic @obj to be triggered.
     */
    arrivingTurn()
    {
        sally.initiateTopic(sally.location);
    }
    
    
    /* 
     *   Tell Sally to start following the player character around when she
     *   enters this ActorState.
     */
    activateState(actor, oldState)
    {
        actor.startFollowing();
    }
   
    
    beforeTravel(traveler, connector)
    {
        if(connector == road.west)
        {
            "<q>Jag väntar på dig här,</q> meddelar {ref subj sally}. ";
            sally.stopFollowing;
        }
    }
    
    afterTravel(traveler, connector)
    {
        if(traveler == me && connector == road)
            sally.startFollowing();
    }
    
    sayFollowing(oldLoc, conn)
    {
        /* In case conn is nil fall back to an empty travel description. */
        local travelMsg = conn ? ' ' + conn.followDesc : '';
        
        "{Ref subj sally} följer med dig<<travelMsg>>. ";
    }
;

/*  
 *   INITIATE TOPIC
 *
 *   An InitiateTopic is triggered by an explicit call to 
 *   actor.initiateTopic. It's use to make an NPC react to specific things 
 *   in the game. These InitiateTopics are all triggered from the 
 *   arrivingTurn() method of sallyFollowing to make Sally respond to 
 *   arriving in various locations. Note that we're also locating all these 
 *   InitiateTopics in the sallyFollowingState (the definition of the 
 *   SallyAccompanyingInTravelState forms no part of the object containment 
 *   hierarchy).
 */
++ InitiateTopic @lobby
    topicResponse()
    {
        "<q>Ja, här är det,</a> tillkännager {red subj sally}, <q>Vi tar och
        kollar oss omkring lite.</q>";        

        /*  
         *   This is the way to add a DelayedAgendaItem (for which see 
         *   below) to Sally's agenda list.
         *
         */
        sally.addToAgenda(sallyImpatientAgenda.setDelay(4));
        /* 
         *   We only want this InitiateTopic to fire on the first time Sally 
         *   enters the lobby. Setting isActive to nil here disables this 
         *   InitiateTopic for subsequent occasions.
         */
        isActive = nil;
    }
;

++ InitiateTopic @midStair
    "<q>Här är det,</q> {ref subj sally} tillkännager och pekar på ekdörren,
    <q>svaret på alla dina frågor finns på andra sidan. Gå in om du vågar!</q>"
;

++ InitiateTopic @horrorChamber
    topicResponse()
    {
        "Hon ger ifrån sig ett genomträngande skrik; men du är bara svagt 
        medveten om hennes närvaro; då din mage hotar att tömma sitt innehåll, 
        rummet berkar börja snurra runt dig, och sedan försvinner allt.\b";
        
        /*  
         *   We'll end the game at this point (it's only a demo, after all!).
         *   Note how we can use finishGameMsg to display a custom finishing
         *   message.
         */
        finishGameMsg('DU HAR SVIMMAT', [finishOptionUndo]);
    }
;

++ InitiateTopic @road
    "<q>Jag går inte tillbaka till stan förrän jag har visat dig vad 
    som finns i fyren,</q> varnar {ref subj sally} dig. "
;

++ InitiateTopic, StopEventList @store
    [
        '<q>De plockade bort allt efter problemen,</q> anmärker {ref subj sally}, 
        <q>det finns inget intressant kvar i den här delen av fyren nu. </q> ',

        '<q>Som jag sa, det finns ingenting intressant kvar  i den här delen av         
        fyren nu,</q> anmärker {ref subj sally}, <q>Vi kollar någon annanstans.</q> '
    ]
;


++ InitiateTopic, StopEventList @office
    [
        '<q>Det verkar inte finnas mycket här, eller hur?</q>
        förklarar {ref subj sally}. ',

        '{Ref subj sally} tittar sig omkring i rummet utan större intresse.'
    ]
;

++ InitiateTopic @cliffPath
    "<q>Tja, det var <i>stor</i> poäng med att komma hit, va!</q> 
    förklarar {ref subj sally}."
;


/*   
 *   TOPIC GROUP
 *
 *   We'll define a few conversational responses for Sally; these could all 
 *   go directly in the sally object, but we can also use a TopicGroup for 
 *   the purpose (and since there are so many other kinds of thing going 
 *   directly in the actor, using a TopicGroup can seem neater).
 */

+ TopicGroup
    /* 
     *   The TopicEntries in this TopicGroup will only be reachable when this
     *   isActive condition is true. As a matter of fact it will true 
     *   practically all the time the PC is in a position to talk to Sally in
     *   any case, so we're just illustrating the principle here. 
     *   In a real game you might want to use a more restrictive condition.
     */
    isActive = (sally.curState is in(sallyLeadingState, sallyFollowingState,
                                     sallyArriving))
;

++ AskTopic,  StopEventList @sally
    [
        '<q>Är du gift, Sally?</q> frågar du.\b

        <q>Jag var det,</q> säger hon, <q>men sedan dök problemen upp. Men hur
        är det med dig själv? Har du familj?</q><.convnode family> ',

        '<q>Hur orsakade problemen...?</q> du.\b
        <q>Ett avslut på mitt äktenskap?</q> frågar hon, <q>Tja, det är en 
        lång historia. Jag kanske berättar om det någon annan gång.</q> ',

        '<q>Finns det någon man i ditt liv nu?</q> frågar du.\b
        <q>Jag kan bara fortsätta hoppas,</q> ler hon blygt. ',

        '<q>Berätta mer om dig själv, Sally,</q> säger du.\b
        <q>En annan gång,</q> svarar hon. '
    ]
    name = 'henne själv'
    timesToSuggest = 3
;

/*
 *   ALTTOPIC
 *
 *   An AltTopic can be used to provide an alternative response to a
 *   conversational command. It responds to the same command as the TopicEntry
 *   it's located in (in this case ASK SALLY ABOUT HERSELF) but is used in
 *   preference to its parent TopicEntry when its own isActive property is true;
 *   in this case when the player character doesn't know Sally's name.
 */

+++ AltTopic
    "<q>Ursäkta, men jag tror inte vi har introducerats,</q> säger du, <q>Du 
    är...?</q>\b
    <q>Jag heter <<sally.makeProper()>>,</q> svarar hon dig, <q>Jag har bott
    här nästan hela mitt liv.</q>"

    isActive = !sally.proper
;

   /* 
    *   ASK TELL TOPIC
    *
    *   Note that as an alternative to using the @obj template syntax to 
    *   make a TopicEntry match the single object obj, we can provide a list 
    *   of objects that a TopicEntry can match. Here we make asking/telling 
    *   Sally about the lighthouse equivalent to asking/telling her about 
    *   the troubles (or about the oakDoor once the PC has seen it)
    */
++ AskTellTopic [lighthouse, tTroubles, oakDoor]
    "<q>Så vad var det för slags problem, och vad kommer vi att hitta 
    vid fyren? </q> frågar du.\b
    <q>Du får se när vi kommer dit,</q> försäkrar hon dig. "

    name = 'fyren'
;

/*   
 *   ALT TOPIC
 *
 *   We also provide a whole series of AltTopics to tailor the response to 
 *   ASK/TELL SALLY ABOUT LIGHTHOUSE/TROUBLES according to the current 
 *   situation.
 */
+++ AltTopic
    "<q>Vad var det som hände i fyren?</q> frågar du, 
    <q>var det där problemen började?</q>\b
    <q>Svaren finns alla i fyren,</q> säger hon till dig, 
    <q>om du vill ta reda på vad som hände måste du gå in.</q>"    
    isActive = me.hasSeen(lighthouse)
;

+++ AltTopic
    "<q>Så, vad hände här?</q> vill du veta, <q>Och vad var problemen?</q>\b
    <q>Fortsätt leta,</q> säger hon, <q>du får se tids nog!</q>"

    name = 'problemen'
    isActive = me.location is in (lobby, store, office)
;

+++ AltTopic
    "<q>Vad finns det på andra sidan dörren?</q> frågar du, 
    <q>är det där problemen började?</q>\b
    <q>Om du går igenom den kommer du att få se,</q> säger hon till dig. "
    name = 'problemen'
    isActive = me.isIn(midStair)
;

++ TellTopic, StopEventList @me
    [
        '<q>Jag är ny här,</q> säger du till henne.\n
        <q>Jag har förstått det,</q> anmärker hon. ',

        'Du fortsätter att berätta om dig själv för henne, men du upplever inte
        att hon verkligen lyssnar. ' 
    ]
;


++ DefaultCommandTopic
    "<q>Min man brukade även han försöka säga åt mig vad jag skulle göra hela tiden;</q> 
    påpekar hon, <q>Ärligt talat, så tycker inte jag att detta är något attraktivt hos en man.</q>"
;

/*   
 *   DEFAULT GIVE SHOW TOPIC
 *
 *   We can use a DefaultGiveShowTopic to provide a response to attempt to 
 *   Give or Show anything to Sally (for which we haven't provided any more 
 *   specific handling).
 */

++ DefaultGiveShowTopic
    "<q>Ja, {han subj dobj} {är} {en subj dobj},</q> observerar hon, <q>Mycket
    intressant, på riktigt!</q>"
;

/*   
 *   DEFAULT ANY TOPIC
 *
 *   A DefaultAnyTopic will match anything for which we haven't provided a 
 *   more specific response. Here, for example, it would match ASK SALLY 
 *   ABOUT HER MOTHER, or TELL SALLY ABOUT CHINESE COOKERY. A 
 *   DefaultAnyTopic is used as a last resort: any other kind of 
 *   DefaultXXXXTopic (e.g. DefaultAskTopic, DefaultTellTopic, 
 *   DefaultGiveShowTopic) will be used in preference to it (so our 
 *   DefaultGiveShowTopic will still work, but the DefaultAnyTopic would 
 *   have handled GIVE & SHOW if we hadn't defined a DefaultGiveShowTopic.
 *
 *   Here we use a DefaultAnyTopic in place of defining separate a 
 *   DefaultAskTopic and DefaultTellTopic (given that most other kinds have 
 *   already been covered). We could have done almost the same job in this 
 *   particular context with a DefaultAskTellTopic.
 */

++ DefaultAnyTopic
    "<q>Vi kan prata sen; kom så går vi till fyren nu,</q> svarar hon. ";
;

/*   
 *   ALT TOPIC
 *
 *   We can use AltTopics with DefaultTopics as well as other kinds of 
 *   TopicEntry. Normally one would use a ShuffledEventList to vary the 
 *   response to a DefaultTopic, but here we'll use a whole series of 
 *   AltTopics to vary the response according to the situation.
 */
+++ AltTopic
    "<q>Vi pratar om det någon annan gång,</q> föreslår hon, <q>Jag tror att vi 
    borde gå tillbaka till fyren innan det blir mörkt.</q> "
    isActive = me.hasSeen(lighthouse) && !me.canSee(lighthouse)
;

+++ AltTopic
    "<q>Så mycket prat!</q> klagar hon, <q>man skulle kunna tro att du är rädd
    för att gå in där!</q> säger hon och nickar mot fyren. "
    isActive = me.isIn(cliff)
;

+++ AltTopic, ShuffledEventList
    [
        '<q>Det här känns inte rom rätt tillfälle att prata om det,</q> svarar hon,
        <q>Jag trodde att du var ivrig på att få veta mer om problemen!</q> ',

        '<q>Senare,</q> uppmanar hon dig,<q>oavsett vad så kommer du att få en 
         helt förändrad bild på allt när du väl har sett källan till problemen.</q> ',

        '<q>Vi kan diskutera det någon annan gång,</q> säger hon,<q>vi 
        koncentrerar oss på det vi kom för nu!</q> '
    ]
    isActive = me.location is in (lobby, store, office, midStair)
;

//------------------------------------------------------------------------------
/*   
 *   CONVERSATION NODES
 *
 *   A Conversation Node, or ConvNode (as the class is actually called) 
 *   represents a particular point in a conversation at which a particular 
 *   set of responses becomes appropriate. For example, if an NPC asks a 
 *   question, it may be pertinent to reply YES or NO immediately after, 
 *   whereas interjecting YES or NO into the conversation at some later or 
 *   earlier point of the conversation would either be meaningless, or else 
 *   would have some quite different meaning. 
 *
 *
 *   There are basically two types of Conversation Node that one might 
 *   typically be implemented in adv3Lite, which one might for convenience 
 *   called 'open' and 'closed' (though this is nowhere defined in the 
 *   library's nomenclature). An 'open' node is one at which a particular 
 *   set of responses becomes appropriate (such as YES or NO or some more 
 *   detailed reply), but the player doesn't have to use one of them; the 
 *   player can take the opportunity to use one of these responses or ignore 
 *   it (though once ignored, the opportunity is lost, as it would be in a 
 *   real conversation).
 *
 *   A 'closed' node, on the other hand, is where the NPC demands an answer 
 *   and won't let the conversation move on until s/he receives one. This is 
 *   the more laborious kind of Conversation Node to implement, but it's the 
 *   one we'll illustrate first, as it demonstrates more of the features of 
 *   ConvNodes, and once we've implemented a 'closed' node the 'open' ones 
 *   will seem easy!
 *
 *   The ConvNode below is used for Sally to offer to show the PC to the 
 *   lighthouse; she'll demand that he says yes or no.
 */

+ ConvNode 'problemen'   
;


/*   
 *   NODE CONTINUATION TOPIC
 *
 *   A NodeContinuationTopic can be used to let the actor remind the player
 *   character she's waiting for an answer to her question while she's at this
 *   ConvNode. Here we mix it in with ShuffledEventList to vary the 'nag'
 *   messages displayed.
 */
++ NodeContinuationTopic, ShuffledEventList
    
    [
        '<q>Fyren,</q> {ref sally/hon} påminner dig, <q>Jag erbjöd mig att ta 
        med dig för att se den. Vill du att jag ska göra det?</q> ',

        '<q>Jag väntar fortfarande på att få höra om du vill att jag ska visa 
        dig fyren,</q> påminner {ref sally/hon} dig. ',

        '<q>Jag har varit vänlig nog att erbjuda mig att visa dig fyren, så 
        jag tycker att jag förtjänar ett svar,</q> anmärker {ref sally/hon}, 
        <q>Nå -- kommer du?</q> '
    ]
    /*  
     *   Sally would seem needlessly importunate if she nagged the PC for a
     *   response on every turn he didn't say something, so we'll use one of
     *   these messages on average only every other turn.
     */
    eventPercent = 50
; 

/* 
 *   NODE END CHECK
 *
 *   A NodeEndCheck object can be used to prevent the player character from
 *   ending the conversation while the actor is at this ConvNode.
 */
++ NodeEndCheck
    /*  
     *   Since Sally is insisting on an answer, we need to block the various 
     *   ways in which the player could simply end the conversation. Walking 
     *   away from her might be one way; saying goodbye would be another. We 
     *   use canEndConversation() to block both.
     */
    canEndConversation(actor, reason)
    {
        if(reason == endConvLeave)
            "<q>Gå inte härifrån när jag pratar med dig!</q> protesterar 
            {ref subj sally}, <q>Jag ställde en fråga: vill du att jag ska visa 
            dig fyren eller inte?</q> ";
        if(reason == endConvBye)
            "<q>Säg inte adjö när jag ställer en fråga!</q> stormar {the subj 
            sally}, <q>Kommer du följa med mig till fyren eller inte?</q> ";
        
        /*  
         *   blockEndConv is a special value which not only doesn't allow the
         *   conversation to be ended while we're in this ConvNode but also 
         *   tells the caller that we've displayed a message explaining why, 
         *   so that we don't also need to display one of the messages from 
         *   npcContinueList/
         */
        return blockEndConv;
    }   
;


/*  
 *   YES TOPIC
 *
 *   A YesTopic handles the response when the player types YES. Normally a 
 *   YesTopic will only be useful in a ConvNode (to handle a reply to a 
 *   question the NPC has just asked. Making it a SuggestedYesTopic also 
 *   means that 'say yes' will be one of the suggestions offered to the 
 *   player/
 */
++ YesTopic
    topicResponse()
    {
        /*  
         *   If the player replies YES, we want to leave this ConvNode. This
         *   will happen in any case unless we include a <.convstay> or
         *   <.convstayt> tag in the response, which we don't want to do here.
         */
        "<q>Ja, okej, för mig till fyren,</q> säger du.\b
        <q>Följ mig,</q> svarar hon och börjar gå österut. ";

        /*   
         *   If the player says YES, Sally will lead him to the lighthouse, 
         *   so we need to put her in the first of her GuidedTourStates.
         */
        sally.setState(sallyLeadingState);
    }
;

/*   
 *   NO TOPIC
 *
 *   A NoTopic is just like a YesTopic, except that it handles a response to 
 *   NO.
 */
++ NoTopic
    topicResponse()
    {
        /*
        "<q>No, I'm a bit busy right now,</q> you say.\b
        <q>Very well, suit yourself,</q> she shrugs, <q>It's your loss, not
        mine,</q>\b
        So saying, she turns away; and with her goes your only chance of
        learning about the lighthouse and the troubles.\b";
        */

        "<q>Nej, jag är lite upptagen just nu,</q> säger du.\b
        <q>Okej då, skyll dig själv då,</q> säger hon och rycker på axlarna. 
        <q>Din förlust, inte min,</q>\b
        Med det sagt vänder hon sig bort; och med henne försvinner din enda 
        chans att lära dig mer om fyren och problemen.\b";

        /* 
         *   If the PC refuses to follow Sally, then the plot (such as it 
         *   is) has been derailed, so we may as well end the game. We do so 
         *   with a suitable custom message.
         */        
        finishGameMsg('DU ÄR YNKLIGT SVAGMODIG', [finishOptionUndo]);
        
    }
;

/*  
 *   QUERY TOPIC
 *
 *   A QueryTopic is a special kind of TopicEntry that can be used to allow the
 *   player to ask things that normally wouldn't be possible in the standard
 *   ASK/TELL system. The QueryTopic we define immediately below will be
 *   suggested to the player as "as why she's offering", but the player could
 *   also trigger it with WHY ARE YOU OFFERING.
 *
 *   The first single-quoted string in the template is the qType, in this case
 *   'why', which enables the parser to match the QueryTopic to ASK WHY... or
 *   just WHY... The second string is the vocab property of the Topic object the
 *   library will create for us to act as this QueryTopic's matchObj.
 *
 *   Note that in this case we do use <.convstay> tag so the the conversation
 *   will remain at this ConvNode even after this TopicEntry has been triggered.
 */
++ QueryTopic, StopEventList 'why' 'she\'s offering; (she) (is) (you) (are)'   
    [

        '<q>Varför erbjuder du dig att visa mig?</q> frågar du.\b
        <q>Eftersom du är ny här; du behöver förstå vad som hände,</q> svarar hon. 
        <q>Nå, kommer du? Ja eller nej?</q> <.convstay>',

        '<q>Jag förstår fortfarande inte varför du är så angelägen om att visa mig 
        fyren,</q> säger du.\b
        <q>Som sagt, du behöver förstå vad som hände där. Nå, vill du att jag 
        ska visa dig?</q> <.convstay>'
    ]
;
    
/* 
 *   If the PC doesn't yet know who Sally is (he could have found out from 
 *   Bob), we'll let him ask her.
 */
++ AskTopic @sally
    "<q>Vem är du?</q> frågar du.\b
    <q>Jag hetrer <<sally.makeProper()>>,</q> svarar hon snabbt, 
    <q>och jag har varit här tillräckligt länge för att veta ett och annat. 
    Så, vill du att jag ska ta dig till fyren?</q> <.convstay>"

    isActive = (!sally.proper)
    name = 'herself'
;

/*   
 *   DEFAULT ANY TOPIC
 *
 *   This DefaultAnyTopic ensures that this ConvNode remains 'closed', since it
 *   will be triggered in response to any conversational command except for the
 *   four explicitly handled above. Without one or more DefaultTopics to trap
 *   other conversational commands, they would be handled by the next
 *   TopicDatabase (ActorState or Actor) in the hierarchy, and we'd slip
 *   straight out of the ConvNode. Note that to make this DefaultTopic 'close'
 *   the node we have to add a <.convstay> tag to the response so that we stay
 *   at this ConvNode each time this DefaultAnyTopic is triggered.
 *
 *   In a real game we'd probably want to make the DefaultAnyTopic a
 *   ShuffledEventList to vary the responses.
 */ 
++ DefaultAnyTopic
    "<q>Strunta i det där,</q> säger hon, <q>Jag frågade dig om du ville att 
    jag skulle visa dig fyren. Vill du det?</q> <.convstay>"
;


    
//------------------------------------------------------------------------------
/*   
 *   AN 'OPEN' CONVERSATION NODE
 *
 *   This is the conversation node that's triggered when Sally and the PC arrive
 *   outside the lighthouse. She asks the PC whether they should go inside, but
 *   that's an invitation to action rather than a demand for a verbal response,
 *   so though we should cater for a verbal response, we shouldn't demand one.
 *   So we can use the much simpler 'open' ConvNode coding structure here. This
 *   is marked by the absence of any catchall DefaultTopics.
 */
+ ConvNode 'fyren'     
;

++ YesTopic
    "<q>Ja, det är ju det som är anledningen av vi kom, eller hur?</q> svarar du.\b
    <q>Absolut,</q> håller hon med. <q>Fortsätt!</q> "
;

++ NoTopic
    "<q>Nej, det här känns inte bra,</q> svarar du.\b
    <q>Var inte så nördig!</q> protesterar hon. <q>Det är helt säkert! Bara fortsätt!"
;

++ AskTopic @lighthouse
    "<q>Vad kommer vi hitta där inne?</q> frågar du.\b
    <q>Varför inte gå in och se efter själva?</q> svarar hon, <q>Ska vi?</q> <.convstay>
    "
    name = 'fyren'
;

/* 
 *   There's no DefaultTopic at the end of this ConvNode structure. If the 
 *   player responds with anything other than YES, NO or ASK ABOUT 
 *   LIGHTHOUSE, we'll simply fall straight out of the ConvNode, since we'll 
 *   have left the point of the conversation at which any of these responses 
 *   made sense.
 */


//------------------------------------------------------------------------------
/*   
 *   A THREADED CONVERSATION NODE CHAIN
 *
 *   We can also use ConvNodes to created a threaded conversational chain. 
 *   This could be done with 'closed' nodes, but quickly becomes very 
 *   laborious (perhaps for the player as well as the author!). Here we just 
 *   illustrate a chain of very simple 'open' nodes. Note that the 
 *   conversation will only continue on to the next node in the chain if the 
 *   player gives the 'correct' answer on every turn (though we could have 
 *   programmed a branching chain had we wanted to). In this case this is a 
 *   reasonable model of how such a conversation might proceed.
 */

+ ConvNode 'familjen'   
;

++ YesTopic
    "<q>Ja, jag har precis flyttat hit med min fru och barn,</q> säger du.\b
    <q>Jag hoppas att kommer du trivas här!</q> svarar hon.<.reveal married> "
;

++ NoTopic
    /* 
     *   The tag <.convnode drink> at the end of this reply will take the 
     *   Conversation to the next ConvNode (called 'drink').
     */
    "<q>Nej, jag är ungkarl,</q> svarar du.\b
    <q>Jaså?</q> svarar hon, <q>Jag hade trott att en kille som du -- men, 
    vi kanske kan ta en drink någon gång, så kan du berätta allt för mig.</q>
    <.convnode drink> "
;

+ ConvNode 'drink'
;

/*  
 *   Likewise the <.convnode date> tag will take the conversation to the next
 *   ConvNode (called 'date')
 */
++ YesTopic
    "<q>Ja, det skulle jag vilja,</q> säger du.\b
    <q>Bra!</q> säger hon och ler, <q>Hur fungerar det ikväll? Jag känner till ett härligt
    litet ställe vi skulle kunna gå till, om du är ledig...</q> <.convnode date>"
;

++ NoTopic
   "<q>Nej, det är bäst att jag låter bli. Min flickvän skulle nog inte förstå,</q> 
   säger du till henne.\b
    <q>Jaha, men då så,</q> svarar hon."
;

+ ConvNode 'date'
;

++ YesTopic
    "<q>Ja, jag är ledig ikväll,</q> svarar du, <q>Vi ses för på ett glas då!</q>\b
    <q>Det är en dejt!</q> deklararerar hon med ett brett leende. "
;

/* 
 *   The <.convnodet other> tag takes the conversation to the ConvNode 'other'
 *   immediately below, but this time, since we're not just looking for a simple
 *   yes or no answer, we need to inform the player what responses are now
 *   possible. By using <.convnodet other> rather than <.convnode other> we're
 *   asking for a topic inventory (list of suggested topics) to be displayed on
 *   entering the new ConvNode.
 */
++ NoTopic
    "<q>Nej, jag är upptagen ikväll,</q> svarar du, <q>precis flyttat, så mycket 
    att ta itu med...</q>\b
    <q>Någon annan gång då, kanske,</q> föreslår hon. <.convnodet other>"    
;

+ ConvNode 'other'
;

/* 
 *   SAY TOPIC
 *
 *   A SayTopic is another kind of SpecialTopic that can be used to allow the
 *   player to SAY anything. It works much like a QueryTopic except that we
 *   don't define a qType for it.
 */
++ SayTopic 'föreslå imorgon' 
    "<q>Hur ser morgondagen ut?</q> föreslår du.\b
    <q>Det fungerar utmärkt -- det är dejt!</q> strålar hon. "
    
    /* 
     *   We want this SayTopic to be suggested as "suggest tomorrow" not "say
     *   suggect tomorrow", so we set includeSayInName to nil to remove "say"
     *   from this SayTopic's name
     */
    includeSayInName = nil
;

++ SayTopic 'svara vagt; (var) vag' 
    "<q>Ja, någon annan gång,</q> håller du med. "
    includeSayInName = nil
;



//==============================================================================
/*  
 *   AGENDA ITEMS
 *
 *   AgendaItems provide a mechanism to allow NPCs to pursue goal-directed 
 *   behaviour or responded to particular events. Each NPC has an agendaList 
 *   (which may, of course, be empty at any one time), and on each turn when 
 *   the NPC is not otherwise engaged his/her/its agendaList is searched for 
 *   an AgendaItem that's ready to be used. If one is found, it's 
 *   invokeItem() method is called. 
 *
 *   We want Sally to walk out of the shop and wait for the PC as soon as she
 *   hears Bob mention the lighthouse. An AgendaItem is ideal for this.
 */

+ AgendaItem
    /* 
     *   AgendaItems normally have to be added to an NPC's AgendaList 
     *   explicitly, but by setting this property to true we can have an 
     *   AgendaItem automatically added to the agendaList at the start of 
     *   the game, which is what we want here.
     */
    initiallyActive = true
    
    /*   
     *   An AgendaItem can fire once its isReady property is true. The PC 
     *   learns about the lighthouse when Bob first mentions it, so checking 
     *   for when the PC knows about the lighthouse should make this 
     *   AgendaItem fire at the right time.
     */
    isReady = (me.knowsAbout(lighthouse))
    
    /*   The code to execute once this AgendaItem is triggered. */
    invokeItem
    {
        /*  
         *   Note that text displayed in the invokeItem() of an AgendaItem 
         *   will only be displayed if the PC can see the NPC in question. 
         *   Normally this is what we want, since it allows us to describe 
         *   what an NPC is doing without worrying if the PC is there to see 
         *   it or not (if the PC isn't, the text won't be displayed), but 
         *   occasionally this can catch us out, not least if the 
         *   invokeItem() method moves the NPC in or out of the PC's scope 
         *   in the course of execution.
         *
         *   Here, though, it's straightforward, since the PC will always be 
         *   present to see Sally's reaction to the mention of the lighthouse.
         */
        "{Ref subj sally} {tar} en paus från hennes klädesjakt och slänger en nervös
        blick mot dig. ";
        
        /*  Make Sally leave the shop. */
        sally.travelVia(street);
        
        /*  Change Sally's ActorState to sallyStreetState */
        sally.setState(sallyStreetState);
        
        /*  Add a new AgendaItem to Sally's agendaList. */
        sally.addToAgenda(sallyStreetAgenda);
        
        /*  
         *   We're done with this AgendaItem, so it can be removed from 
         *   Sally's agendaList; we show this by setting isDone = true. If 
         *   we didn't this AgendaItem would keep on firing while its 
         *   isReady property evaluated to true. 
         *
         *   In come cases we might want an AgendaItem to be triggered over 
         *   several terms, in which case we wouldn't set isDone = true 
         *   until we were done with it; but this AgendaItem is a one-off, 
         *   so we set isDone = true first time through.
         */
        isDone = true;
    }
;

/*   
 *   CONV AGENDA ITEM
 *
 *   A ConvAgendaItem is used to allow the NPC to try to say something on 
 *   his or her own initiative. By default it becomes ready when (a) the NPC 
 *   is in a position to talk to the PC and (b) the PC hasn't conversed with 
 *   the NPC on that turn. When those two conditions are met the NPC can 
 *   inject her conversational gambit into the conversation. 
 *
 *   We want Sally to offer to lead the PC to the lighthouse as soon as he 
 *   emerges from the shop. A ConvAgenaItem will do this job for us, since 
 *   the Sally can't talk to the PC when he's inside the shop and she's 
 *   outside, but will be able to as soon as he comes out of the shop. 
 */

+ sallyStreetAgenda: ConvAgendaItem
    invokeItem()
    {           
        /* 
         *   Here we have Sally ask a question and then wait for a reply. The
         *   possible responses are defined in the 'troubles' ConvNode to which
         *   the conversation is moved by the <.convnodet troubles> tag. Note
         *   that there are restrictions on where such tags can be used, but
         *   they can be used in ConvAgendaItems as well as TopicEntries.
         */
        "{Ref subj sally} går fram till dig och säger, <q>Ursäkta mig,
        men jag kunde inte låta bli att höra dig fråga om problemen. Skulle
        du vilja att jag visade dig fyren?</q> <.convnodet troubles>";       
     
        /* This is a once-off AgendaItem, so note we're done with it. */
        isDone = true;
    }
;

/*
 *   DELAYED AGENDA ITEM
 *
 *   A DelayedAgendaItem is one that fires a predetermined number of turns 
 *   after its added to its actor's agendaList.
 *
 *   If the PC wanders around for too long after entering the lighthouse 
 *   without going to the room Sally wants him to visit, she'll become 
 *   impatient enough to give him a verbal nudge. Since this is a 
 *   conversational activity, it's appropriate to make this a ConvAgendaItem 
 *   as well. Note that we can just mix the two classes together to combine 
 *   their behaviour.
 */


+ sallyImpatientAgenda: DelayedAgendaItem, ConvAgendaItem
    invokeItem()
    {
        if(me.hasSeen(oakDoor))
            "<.p><q>Om du vill ha några <i>svar</i> så måste du gå igenom den där 
            ekdörren,</q> förklarar {ref subj sally} för dig. ";
        else
            "<.p><q>Du kommer inte hitta något där nere,</q> berättar {ref subj sally} 
            för dig, <q>vi måste försöka en våning upp.</q> ";
        
        isDone = true;
    }
;






//==============================================================================
/*   
 *   TOPIC
 *
 *   A Topic is used to represent a possible Topic of Conversation that's not
 *   otherwise represented as a physical object in the game world, either 
 *   because it's an abstraction (like 'weather' or 'troubles') or because 
 *   there's no physical object by that name corresponding to it in the game 
 *   (like the town).
 *
 *   Here we define just three Topics. A real game would probably define many
 *   more. Note that starting the name of a Topic object with a lower-case 
 *   t is not a requirement, it's simply a convention adopted here/
 *
 *   Note also that the only property we need to define on a Topic object is 
 *   its vocabWords (the single-quoted string in the Topic template). 
 */

tWeather: Topic 'väd:er+ret';
//tTown: Topic 'this town;;place';
tTown: Topic 'denna stad+en;;plats+en'; // TODO: testa av denna
tTroubles: Topic 'bekym:mer+ren;;;dem';

