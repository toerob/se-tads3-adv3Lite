#charset "utf-8"

/* 
 *   Copyright (c) 2000, 2006 Michael J. Roberts.  All Rights Reserved. 
 *   Slightly adapted by Eric Eve for use with adv3Lite
 *   
 *   TADS 3 Library: Instructions for new players
 *   
 *   This module defines the INSTRUCTIONS command, which provides the
 *   player with an overview of how to play IF games in general.  These
 *   instructions are especially designed as an introduction to IF for
 *   inexperienced players.  The instructions given here are meant to be
 *   general enough to apply to most games that follow the common IF
 *   conventions. 
 *   
 *   This module defines the English version of the instructions.
 *   
 *   In most cases, each author should customize these general-purpose
 *   instructions at least a little for the specific game.  We provide a
 *   few hooks for some specific parameter-driven customizations that don't
 *   require modifying the original text in this file.  Authors should also
 *   feel free to make more extensive customizations as needed to address
 *   areas where the game diverges from the common conventions described
 *   here.
 *   
 *   One of the most important things you should do to customize these
 *   instructions for your game is to add a list of any special verbs or
 *   command phrasings that your game uses.  Of course, you might think
 *   you'll be spoiling part of the challenge for the player if you do
 *   this; you might worry that you'll give away a puzzle if you don't keep
 *   a certain verb secret.  Be warned, though, that many players - maybe
 *   even most - don't think "guess the verb" puzzles are good challenges;
 *   a lot of players feel that puzzles that hinge on finding the right
 *   verb or phrasing are simply bad design that make a game less
 *   enjoyable.  You should think carefully about exactly why you don't
 *   want to disclose a particular verb in the instructions.  If you want
 *   to withhold a verb because the entire puzzle is to figure out what
 *   command to use, then you have created a classic guess-the-verb puzzle,
 *   and most everyone in the IF community will feel this is simply a bad
 *   puzzle that you should omit from your game.  If you want to withhold a
 *   verb because it's too suggestive of a particular solution, then you
 *   should at least make sure that a more common verb - one that you are
 *   willing to disclose in the instructions, and one that will make as
 *   much sense to players as your secret verb - can achieve the same
 *   result.  You don't have to disclose every *accepted* verb or phrasing
 *   - as long as you disclose every *required* verb *and* phrasing, you
 *   will have a defense against accusations of using guess-the-verb
 *   puzzles.
 *   
 *   You might also want to mention the "cruelty" level of the game, so
 *   that players will know how frequently they should save the game.  It's
 *   helpful to point out whether or not it's possible for the player
 *   character to be killed; whether it's possible to get into situations
 *   where the game becomes "unwinnable"; and, if the game can become
 *   unwinnable, whether or not this will become immediately clear.  The
 *   kindest games never kill the PC and are always winnable, no matter
 *   what actions the player takes; it's never necessary to save these
 *   games except to suspend a session for later resumption.  The cruelest
 *   games kill the PC without warning (although if they offer an UNDO
 *   command from a "death" prompt, then even this doesn't constitute true
 *   cruelty), and can become unwinnable in ways that aren't readily and
 *   immediately apparent to the player, which means that the player could
 *   proceed for quite some time (and thus invest substantial effort) after
 *   the game is already effectively lost.  Note that unwinnable situations
 *   can often be very subtle, and might not even be intended by the
 *   author; for example, if the player needs a candle to perform an
 *   exorcism at some point, but the candle can also be used for
 *   illumination in dark areas, the player could make the game unwinnable
 *   simply by using up the candle early on while exploring some dark
 *   tunnels, and might not discover the problem until much further into
 *   the game.  
 */

#include "advlite.h"


/*
 *   The INSTRUCTIONS command.  Make this a "system" action, because it's
 *   a meta-action outside of the story.  System actions don't consume any
 *   game time.  
 */
DefineSystemAction(Instructions)
    /*
     *   This property tells us how complete the verb list is.  By default,
     *   we'll assume that the instructions fail to disclose every required
     *   verb in the game, because the generic set we use here doesn't even
     *   try to anticipate the special verbs that most games include.  If
     *   you provide your own list of game-specific verbs, and your custom
     *   list (taken together with the generic list) discloses every verb
     *   required to complete the game, you should set this property to
     *   true; if you set this to true, the instructions will assure the
     *   player that they will not need to think of any verbs besides the
     *   ones listed in the instructions.  Authors are strongly encouraged
     *   to disclose a list of verbs that is sufficient by itself to
     *   complete the game, and to set this property to true once they've
     *   done so.  
     */
    allRequiredVerbsDisclosed = nil

    /* 
     *   A list of custom verbs.  Each game should set this to a list of
     *   single-quoted strings; each string gives an example of a verb to
     *   display in the list of sample verbs.  Something like this:
     *   
     *   customVerbs = ['brush my teeth', 'pick the lock'] 
     */
    customVerbs = []

    /* 
     *   Verbs relating specifically to character interaction.  This is in
     *   the same format as customVerbs, and has essentially the same
     *   purpose; however, we call these out separately to allow each game
     *   not only to supplement the default list we provide but to replace
     *   our default list.  This is desirable for conversation-related
     *   commands in particular because some games will not use the
     *   ASK/TELL conversation system at all and will thus want to remove
     *   any mention of the standard set of verbs.  
     */
    conversationVerbs =
    [
        'FRÅGA TROLLKARLEN OM TROLLSTAV',
        'FRÅGA TROLLKARLEN OM DRICKTRYCK',
        'FRÅGA TROLLKARLEN HUR MAN FLYGER',
        'BERÄTTA FÖR TROLLKARLEN OM DEN DAMMIGA STORA BOKEN',
        'PRATA OM VÄDRET',
        'SÄG ATT DU ÄR RÄDD',
        'VISA SKRIFTRULLE FÖR TROLLKARLEN',
        'GE TROLLSTAVEN TILL TROLLKARLEN',
        'JA (eller NEJ)'
    ]

    /* conversation verb abbreviations */
    conversationAbbr = "\n\tFRÅGA OM (ämne) kan förkortas till F (ämne)
                        \n\tBERÄTTA OM (ämne) kan skrivas som B (ämne)"

    /*
     *   Truncation length. If the game's parser allows words to be
     *   abbreviated to some minimum number of letters, this should
     *   indicate the minimum length.  The English parser uses a truncation
     *   length of 8 letters by default.
     *   
     *   Set this to nil if the game doesn't allow truncation at all.  
     */
    truncationLength = LMentionable.truncationLength

    /*
     *   This property should be set on a game-by-game basis to indicate
     *   the "cruelty level" of the game, which is a rough estimation of
     *   how likely it is that the player will encounter an unwinnable
     *   position in the game.
     *   
     *   Level 0 is "kind," which means that the player character can
     *   never be killed, and it's impossible to make the game unwinnable.
     *   When this setting is used, the instructions will reassure the
     *   player that saving is necessary only to suspend the session.
     *   
     *   Level 1 is "standard," which means that the player character can
     *   be killed, and/or that unwinnable positions are possible, but
     *   that there are no especially bad unwinnable situations.  When
     *   this setting is selected, we'll warn the player that they should
     *   save every so often.
     *   
     *   (An "especially bad" situation is one in which the game becomes
     *   unwinnable at some point, but this won't become apparent to the
     *   player until much later.  For example, suppose the first scene
     *   takes place in a location that can never be reached again after
     *   the first scene, and suppose that there's some object you can
     *   obtain in this scene.  This object will be required in the very
     *   last scene to win the game; if you don't have the object, you
     *   can't win.  This is an "especially bad" unwinnable situation: if
     *   you leave the first scene without getting the necessary object,
     *   the game is unwinnable from that point forward.  In order to win,
     *   you have to go back and play almost the whole game over again.
     *   Saved positions are almost useless in a case like this, since
     *   most of the saved positions will be after the fatal mistake; no
     *   matter how often you saved, you'll still have to go back and do
     *   everything over again from near the beginning.)
     *   
     *   Level 2 is "cruel," which means that the game can become
     *   unwinnable in especially bad ways, as described above.  If this
     *   level is selected, we'll warn the player more sternly to save
     *   frequently.
     *   
     *   We set this to 1 ("standard") by default, because even games that
     *   aren't intentionally designed to be cruel often have subtle
     *   situations where the game becomes unwinnable, because of things
     *   like the irreversible loss of an object, or an unrepeatable event
     *   sequence; it almost always takes extra design work to ensure that
     *   a game is always winnable.  
     */
    crueltyLevel = 1

    /*
     *   Conversation system description.  Several different conversation
     *   systems have come into relatively widespread use, so there isn't
     *   any single convention that's generic enough that we can assume it
     *   holds for all games.  In deference to this variability, we
     *   provide this hook to make it easy to replace the instructions
     *   pertaining to the conversation system.  If the game uses the
     *   standard ASK/TELL system, it can leave this list unchanged; if
     *   the game uses a different system, it can replace this with its
     *   own instructions.
     *   
     *   We'll include information on the TALK TO command if there are any
     *   in-conversation state objects in the game; if not, we'll assume
     *   there's no need for this command.
     *   
     *   We'll mention the TOPICS command if there are any SuggestedTopic
     *   instances in the game; if not, then the game will never have
     *   anything to suggest, so the TOPICS command isn't needed.
     *   
     *   We'll include information on special topics if there are any
     *   SpecialTopic objects defined.  
     */
    conversationInstructions()
    {
        /*
        "You can talk to other characters by asking or
        telling them about things in the story.  For example, you might
        ASK WIZARD ABOUT WAND or TELL GUARD ABOUT ALARM.  You should
        normally use the ASK ABOUT or TELL ABOUT phrasing; the story
        won&rsquo;t generally be able to understand other formats, so you don&rsquo;t
        have to worry about thinking up complicated questions like <q>ask
        guard how to open the window.</q>, unless the game explicitly offers
        such a question as a suggestion.
        In most cases, you&rsquo;ll get the best results by asking
        about specific objects or other characters you&rsquo;ve encountered
        in the story, rather than about abstract topics such as
        MEANING OF LIFE; however, if something in the story leads you
        to believe you <i>should</i> ask about some particular abstract
        topic, it can&rsquo;t hurt to try.

        \bIf you&rsquo;re asking or telling the same person about several
        topics in succession, you can save some typing by abbreviating
        ASK ABOUT to A, and TELL ABOUT to T.  For example, once you&rsquo;re
        talking to the wizard, you can abbreviate ASK WIZARD ABOUT AMULET
        to simply A AMULET.  This addresses the question to the same
        character as in the last ASK or TELL. 
        */

        "Du kan prata med andra karaktärer genom att fråga eller 
        berätta för dem om saker i berättelsen. Till exempel kan du
        FRÅGA TROLLKARLEN OM TROLLSTAV eller BERÄTTA FÖR VAKTEN OM 
        ALARM. Du bör normalt använda formuleringarna FRÅGA OM eller 
        BERÄTTA OM; berättelsen kommer i allmänhet inte att kunna 
        förstå andra format, så du behöver inte oroa dig för att 
        komma på komplicerade frågor som <q>fråga vakten hur man 
        öppnar fönstret.</q>, såvida inte spelet uttryckligen 
        erbjuder en sådan fråga som ett förslag. I de flesta fall 
        får du bäst resultat genom att fråga om specifika föremål 
        eller andra karaktärer du har stött på i berättelsen, snarare 
        än om abstrakta ämnen som MENINGEN MED LIVET; men om något i 
        berättelsen får dig att tro att du <i>borde</i> fråga om ett 
        visst abstrakt ämne, skadar det inte att försöka. 

        \bOm du frågar om eller berättar för samma person om flera 
        ämnen i följd kan du spara en del skrivarbete genom att 
        förkorta FRÅGA OM till A och BERÄTTA OM till T. Till exempel, 
        när du pratar med trollkarlen kan du förkorta FRÅGA TROLLKARLEN 
        OM AMULETTEN till helt enkelt F AMULETTEN. Detta riktar frågan 
        till samma karaktär som i den gjords i senaste FRÅGA eller BERÄTTA.";

        if(defined(ActorState) && firstObj(ActorState, ObjInstances) != nil)
            "\bFör att hälsa på en annan karaktär, skriv PRATA MED (Person). 
            Detta försöker få den andra karaktärens uppmärksamhet och sedan 
            starta en konversation. PRATA MED är alltid valfritt, eftersom 
            du även kan börja med FRÅGA eller BERÄTTA direkt om du föredrar 
            det. ";

        if(defined(SpecialTopic) && firstObj(SpecialTopic, ObjInstances) != nil)
            "\bBerättelsen kan ibland föreslå några speciella konversationskommandon, 
            som detta:

            \b(Du kan be om ursäkt, eller förklara utomjordingarna, eller fråga hur man flyger.)

            \bOm du vill kan du använda ett av förslagen genom att bara skriva in den speciella 
            fraseringen som visas. Du kan vanligtvis förkorta dessa till de första orden när de 
            är långa.

            \b\t&gt;BE OM URSÄKT
            \b\t&gt;FÖRKLARA UTOMJORDINGARNA
            \b\t&gt;FRÅGA HUR MAN FLYGER

            \bSpecialförslag som detta fungerar ofta bara just i det ögonblick de erbjuds, så du 
            behöver inte oroa dig för att memorera dem eller prova dem vid andra slumpmässiga 
            tillfällen i berättelsen.
            De är inte nya kommandon du behöver lära dig; de är bara ytterligare alternativ 
            tillgängliga vid specifika tillfällen, och berättelsen kommer alltid att meddela 
            dig när de är tillgängliga. När berättelsen erbjuder förslag som detta, kommer det 
            inte begränsa vad du kan göra; du kan fortfarande skriva vilket vanligt kommando som 
            helst istället för ett av förslagen. ";

        if(defined(ActorTopicEntry) && firstObj(ActorTopicEntry, ObjInstances) != nil)
            "\bOm du är osäker på vad du ska diskutera kan du skriva ÄMNEN när som helst 
            när du pratar med någon. Detta visar en lista över saker som din karaktär kan 
            vara intresserad av att diskutera med den andra personen. Kommandot ÄMNEN 
            listar vanligtvis inte allt som ni kan diskutera, så utforska gärna andra 
            ämnen även om de inte finns med i listan. ";

        "\bDu kan också interagera med andra karaktärer med hjälp av fysiska föremål. Till exempel 
        så kan du ge något till en annan karaktär, så som i: GE PENGAR TILL BUTIKSBITRÄDE, eller 
        visa ett föremål till någon, så som i VISA AVGUDABILD FÖR PROFESSORN. Du kan också slåss 
        mot andra karaktärer, som i ATTACKERA TROLL MED SVÄRD eller KASTA YXA PÅ DVÄRG.

        \bI vissa fall kan du be en karaktär att göra något för dig. Du gör detta genom att 
        skriva karaktärens namn, sedan ett kommatecken och sedan det kommando du vill att 
        karaktären ska utföra, med samma formulering som du skulle använda för ett kommando 
        till din egen karaktär. Till exempel:

        \b\t&gt;ROBOT, GÅ NORR

        \bBetänk dock på att det inte finns någon garanti för att andra karaktärer alltid 
        kommer att lyda dina order. De flesta karaktärer har sina egna tankar och kommer inte 
        automatiskt att göra vad du än ber om. ";

        /*
        "\bYou can also interact with other characters using physical
        objects.  For example, you might be able to give something to
        another character, as in GIVE MONEY TO CLERK, or show an object
        to someone, as in SHOW IDOL TO PROFESSOR.  You might also be
        able to fight other characters, as in ATTACK TROLL WITH
        SWORD or THROW AXE AT DWARF.

        \bIn some cases, you can tell a character to do
        something for you.  You do this by typing the character&rsquo;s name,
        then a comma, then the command you want the character to perform,
        using the same wording you&rsquo;d use for a command to your own
        character.  For example:

        \b\t&gt;ROBOT, GO NORTH

        \bKeep in mind, though, that there&rsquo;s no guarantee that other
        characters will always obey your orders.  Most characters have
        minds of their own and won&rsquo;t automatically do whatever you
        ask. ";*/
    }

    /* execute the command */
    execAction(cmd)
    {
        

        /* show the instructions */
        showInstructions();

       
    }

#ifdef INSTRUCTIONS_MENU
    /*
     *   Show the instructions, using a menu-based table of contents.
     */
    showInstructions()
    {
        /* run the instructions menu */
        topInstructionsMenu.display();

        /* show an acknowledgment */
        "Klart. ";
    }
    
#else /* INSTRUCTIONS_MENU */

    /*
     *   Show the instructions as a standard text display.  Give the user
     *   the option of turning on a SCRIPT file to capture the text.  
     */
    showInstructions()
    {
        local startedScript;

        /* presume we won't start a new script file */
        startedScript = nil;
        
        /* show the introductory message */
        "Berättelsen kommer snart att visa en fullständig 
        uppsättning instruktioner, utformade speciellt för 
        personer som inte redan är bekanta med interaktiv 
        fiktion. Instruktionerna är långa";
        /*
         *   Check to see if we're already scripting.  If we aren't, offer
         *   to save the instructions to a file. 
         */
        if (scriptStatus.scriptFile == nil)
        {
            local str;
            
            /* 
             *   they're not already logging; ask if they'd like to start
             *   doing so 
             */
            ", så du kan vilja spara ner dem till en fil (så att du kan 
            skriva ut dem, till exempel). Vill du fortsätta?
            \n(<<aHref('ja', 'J')>> för att bekräfta, eller skriv 
            <<aHref('skript', 'SKRIPT')>> för att spara till en fil) &gt; ";

            /* ask for input */
            str = inputManager.getInputLine(nil);

            /* if they want to capture them to a file, set up scripting */
            if (rexMatch('<nocase><space>*s(k(r(i(pt?)?)?)?)?<space>*', str)
                == str.length())
            {
                /* try setting up a scripting file */
                ScriptOn.setUpScripting(nil);

                /* if that failed, don't proceed */
                if (scriptStatus.scriptFile == nil)
                    return;
                
                /* note that we've started a script file */
                startedScript = true;
            }
            else if (rexMatch('<nocase><space>*j.*', str) != str.length())
            {
                "Avbrutet. ";
                return;
            }
        }
        else
        {
            /* 
             *   they're already logging; just confirm that they want to
             *   see the instructions 
             */
            "; vill du fortsätta?
            \n(J för att bekräfta) &gt; ";

            /* stop if they don't want to proceed */
            if (!yesOrNo())
            {
                "Avbrutet. ";
                return;
            }
        }

        /* make sure we have something for the next "\b" to skip from */
        "\ ";

        /* show each chapter in turn */
        showCommandsChapter();
        showAbbrevChapter();
        showTravelChapter();
        showObjectsChapter();
        showConversationChapter();
        showTimeChapter();
        showSaveRestoreChapter();
        showSpecialCmdChapter();
        showUnknownWordsChapter();
        showAmbiguousCmdChapter();
        showAdvancedCmdChapter();
        showTipsChapter();

        /* if we started a script file, close it */
        if (startedScript)
            ScriptOff.turnOffScripting(nil);
    }

#endif /* INSTRUCTIONS_MENU */

    /* Entering Commands chapter */
    showCommandsChapter()
    {
        "\b<b>Skriva in Kommandon</b>\b
        Du har förmodligen redan märkt att du interagerar med berättelsen genom
        att skriva ett kommando när du ser <q>prompten</q>, som vanligtvis ser 
        ut så här:
        \b";

        ">";

        "\bMed tanke på detta kommer du förmodligen fram till en av två saker:
        <q>Toppen, jag kan skriva precis vad jag vill, på enkel engelska,
        och berättelsen kommer att göra precis vad jag vill,</q> eller 
        <q>Toppen, nu måste jag lista ut ännu ett otroligt komplext 
        kommandospråk för ett datorprogram; jag väljer att spela Minesweeper 
        istället.</q> Nja, ingen av dessa extremerna är riktigt sanna.

        \bI själva spelet behöver du bara en ganska liten uppsättning 
        kommandon, och kommandona är mestadels på vanlig engelska, så det är 
        inte så mycket du behöver lära dig eller komma ihåg.
        Även om kommandotolken kan verka skrämmande, låt den inte skrämma dig 
        &mdash; det finns bara några enkla saker du behöver känna till.

        \bFör det första behöver du nästan aldrig referera till något som 
        inte nämns direkt i berättelsen; det här är trots allt en berättelse, 
        inte en gissningslek där du måste tänka på allt som hör ihop med 
        något slumpmässigt föremål. Om du till exempel har på dig en jacka 
        kan du utgå från att jackan har fickor, knappar eller dragkedja 
        &mdash; men om berättelsen aldrig nämner dessa saker bör du inte 
        behöva oroa dig för dem.

        \bFör det andra behöver du inte tänka på alla tänkbara handlingar 
        du kan utföra. Poängen med spelet är inte att få dig att gissa 
        rätt slags verb. Istället behöver du bara använda ett relativt 
        litet antal enkla, vanliga handlingar. För att ge dig en 
        uppfattning om vad vi menar, kommer här ett urval av kommandon 
        du kan tänkas använda:";
        
        "\b


        \n\t SE DIG OMKRING 
        \n\t INVENTERING 
        \n\t GÅ NORR (eller ÖST, SYDVÄST, och så vidare, eller UPP, NER, IN, UT) 
        \n\t VÄNTA 
        \n\t TA LÅDA 
        \n\t SLÄPP SKIVAN 
        \n\t TITTA PÅ SKIVAN 
        \n\t LÄS BOKEN 
        \n\t ÖPPNA LÅDA 
        \n\t STÄNG LÅDA 
        \n\t TITTA I LÅDA 
        \n\t TITTA GENOM FÖNSTRET 
        \n\t LÄGG DISKETTEN I LÅDA 
        \n\t LÄGG LÅDAN PÅ BORDET 
        \n\t BÄR DEN KONISKA HATTEN 
        \n\t TA AV HATTEN 
        \n\t TÄND LYKTAN 
        \n\t TÄND TÄNDSTICKA 
        \n\t TÄND LJUSET MED TÄNDSTICKA 
        \n\t TRYCK PÅ KNAPPEN 
        \n\t DRA I SPAKEN 
        \n\t VRID KNAPP 
        \n\t VRID RATTEN TILL 11 
        \n\t ÄT KAKA 
        \n\t DRICK MJÖLK 
        \n\t KASTA PAJ PÅ CLOWNEN 
        \n\t ATTACKERA TROLLET MED SVÄRDET 
        \n\t LÅS UPP DÖRREN MED NYCKEL 
        \n\t LÅS DÖRREN MED NYCKEL 
        \n\t KLÄTTRA UPP FÖR STEGEN 
        \n\t KLIV IN I BILEN 
        \n\t SITT PÅ STOLEN 
        \n\t STÅ PÅ BORDET 
        \n\t STÅ I RABATTEN 
        \n\t LIGG PÅ SÄNGEN 
        \n\t SKRIV HEJ PÅ DATORN 
        \n\t SLÅ UPP BOB I TELEFONBOKEN";

        /* show the conversation-related verbs */
        foreach (local cur in conversationVerbs)
            "\n\t <<cur>>";

        /* show the custom verbs */
        foreach (local cur in customVerbs)
            "\n\t <<cur>>";

        /* 
         *   if the list is exhaustive, say so; otherwise, mention that
         *   there might be some other verbs to find 
         */
        if (allRequiredVerbsDisclosed)
            "\bDet är allt &mdash; varje verb och varje kommandofrasering 
            du behöver för att slutföra berättelsen visas ovan.

            Om du någonsin kör fast och känner att berättelsen förväntar 
            dig att du ska tänka på något helt oväntat, kom ihåg detta: 
            vad det än är du måste göra kan du göra det med ett eller flera 
            av kommandona som visas ovan. Oroa dig aldrig för att du måste 
            börja prova massor av slumpmässiga kommandon för att hitta den 
            magiska ordföljden, för allt du behöver visas tydligt ovan. ";
        else
            "\bDe flesta verben du behöver för att slutföra berättelsen 
            visas ovan; det kan finnas några ytterligare kommandon du behöver 
            då och då också, men de följer samma enkla format som kommandona 
            ovan. ";

        "\bNågra av dessa kommandon förtjänar lite mer förklaring. TITTA DIG 
        OMKRING (som du kan förkorta till TITTA, eller bara T) visar 
        beskrivningen av den aktuella platsen. Du kan använda detta om du 
        vill förfriska ditt minne om din karaktärs omgivningar. 
        INVENTERING (eller bara INV/I) visar en lista över allt din karaktär 
        bär på. VÄNTA (eller Z) gör bara att det går lite tid i berättelsen. ";
    }

    /* Abbreviations chapter */
    showAbbrevChapter()
    {

        "\b<b>Förkortningar</b>
        \bDu kommer förmodligen att använda några kommandon ganska ofta, 
        så för att spara skrivtid kan du förkorta några av de mest använda 
        kommandona:

        \b
        \n\t TITTA RUNT kan förkortas till TITTA, eller bara T
        \n\t INVENTERING kan helt enkelt skrivas som I
        \n\t GÅ NORRUT kan skrivas NORR, eller till och med bara N (likaså E, W, S, 
        NÖ/NO, SÖ/SO, NV, SV, U för UPP och N för NED/NER) 
        \n\t TITTA PÅ SKIVA kan anges som UNDERSÖK SKIVA eller helt enkelt X SKIVA 
        \n\t VÄNTA kan förkortas till Z
        <<conversationAbbr>>

        \b<b>Lite mer information om kommandon</b>
        \bNär du skriver in kommandon kan du använda versaler eller små 
        bokstäver i valfri blandning. Du kan använda ord som DEN och EN/ETT/DE 
        när de är lämpliga, men du kan utelämna dem också om du föredrar det. ";

        if (truncationLength != nil)
        {
            "Du kan förkorta vilket ord som helst till dess första <<
            spellNumber(truncationLength)>> bokstäver, men om du väljer att 
            inte förkorta, kommer berättelsen att uppmärksamma allt du 
            faktiskt skriver; det betyder till exempel att du kan förkorta 
            SUPERCALIFRAGILISTICEXPIALIDOCIOUS <<
            'SUPERCALIFRAGILISTICEXPIALIDOCIOUS'.substr(1, truncationLength)
            >> eller <<
            'SUPERCALIFRAGILISTICEXPIALIDOCIOUS'.substr(1, truncationLength+2)
            >>, men inte till <<
            'SUPERCALIFRAGILISTICEXPIALIDOCIOUS'.substr(1, truncationLength)
            >>SDF. ";
        }
    }

    /* Travel chapter */
    showTravelChapter()
    {
        "\b<b>Förflyttning</b>
        \bFör varje given tidpunkt i berättelsen befinner sig din karaktär 
        på en <q>plats.</q> Berättelsen beskriver platsen när din karaktär 
        först kommer in, och för varje gång du skriver TITTA.

        \bVarje plats har vanligtvis ett kort namn som visas precis före dess 
        fullständiga beskrivning; namnet är användbart när du ritar en karta,
        och det korta namnet kan hjälpa dig att komma ihåg när du letar dig 
        fram.

        \bVarje plats är ett separat rum, eller ett stort utomhusområde,
        eller liknande. (Ibland är ett enda fysiskt rum så stort att det
        omfattar flera platser i spelet, men det är ganska sällsynt.) Att gå 
        till en plats, är för det mesta, så specifikt som det går 
        när det avser förflyttning; när din karaktär väl är på en plats 
        kan karaktären vanligtvis se och nå allt inom platsen, så du behöver 
        inte fundera på var/hur din karaktär står i rummet. Ibland kanske
        du upptäcker att något är utom räckhåll, kanske för att det står 
        på en hög hylla eller på andra sidan av en vallgrav; i dessa fall är 
        det ibland bra att vara mer specifik om din karaktärs plats, till 
        exempel genom att stå på något (STÅ PÅ BORD, till exempel).

        \bAtt resa från en plats till en annan görs vanligtvis med hjälp av ett 
        riktningskommando: GÅ NORR, GÅ NORDÖST, GÅ UPP, och så vidare.
        (Du kan förkorta väderstrecket och vertikalriktningen till en bokstav 
        vardera &mdash; N, S, Ö, V, U, D &mdash; och diagonalriktningen till 
        två: NO/NÖ, NV, SÖ/SO, SV.) Berättelsen bör alltid berätta vilka 
        riktningar du kan gå när den beskriver en plats, så du borde aldrig 
        behöva prova alla de omnämnda riktningarna för att se om de leder 
        någonstans.

        \bI de flesta fall tar en tillbakagång (genom att vända den riktning 
        du tog från en plats till en annan) dig tillbaka till dit du började, 
        även om vissa passager kan ha svängar.

        \bFör det mesta, när berättelsen beskriver en dörr eller passage, 
        behöver du inte öppna dörren för att gå igenom passagen, eftersom 
        berättelsen gör detta åt dig. Först när berättelsen specifikt anger 
        att en dörr blockerar din väg kommer du vanligtvis behöva hantera 
        dörren uttryckligen.

        <<if defined(pcRouteFinder)>>\bEtt annat sätt att resa från plats till
        plats är att använda kommandot GÅ TILL NÅGONSTANS: till exempel GÅ TILL
        KÖKET eller GÅ TILL GEORGE, där KÖKET är ett rum du redan har besökt 
        eller GEORGE är någon (eller något) du redan har sett. Detta tar dig på
        första steget på vägen till köket, eller till rummet där du senast såg 
        George. För att fortsätta din resa efter det första steget kan du 
        använda kommandot FORTSÄTT, vilket kan förkortas till F. Du kan också 
        ange flera kommandon däremellan, t.ex. GÅ TILL KÖKET, SÖK SKRIVBORD, 
        TA ANTECKNINGSBOK, LÄS ANTECKNINGSBOK, FORTSÄTT.\b
        I vissa spel kan spelarkaraktären börja på en plats som redan är bekant
        för honom eller henne (t.ex. hans eller hennes hus eller hemstad), i 
        detta fall kan du möjligen navigera till vissa platser med hjälp av 
        GÅ TILL utan att tidigare ha utforskat den delen av kartan.
        <<end>> ";
    }

    /* Objects chapter */
    showObjectsChapter()
    {
        "\b<b>Manipulera föremål</b>
        \bDu kan hitta föremål i berättelsen som din karaktär kan bära eller på
         annat sätt manipulera. Om du vill bära något, skriv TA och föremålets 
         namn: TA BOK. Om du vill släppa något som din karaktär bär, SLÄPP det.

        \bDu behöver vanligtvis inte vara särskilt specifik om exakt hur din 
        karaktär ska bära eller hålla något, så du borde inte behöva oroa dig 
        för vilken hand som håller vilket föremål eller något liknande. Det kan
        ibland vara bra att lägga ett föremål inuti eller ovanpå ett annat, 
        till exempel LÄGG BOKEN I KASSEN eller LÄGG VASEN PÅ BORDET. Om din 
        karaktärs händer blir fulla kan det hjälpa att lägga några föremål som
        bärs i en behållare, ungefär som du i verkliga livet kan bära fler 
        saker om det är i en väska eller en låda.

        \bDu kan ofta få mycket extra information (och ibland viktiga 
        ledtrådar) genom att undersöka objekt, vilket du kan göra med kommandot
        SE/TITTA PÅ (eller motsvarande UNDERSÖK, vilket du kan förkorta till 
        helt enkelt X, som i X PAINTING). De flesta erfarna spelare får som 
        vana att undersöka allt på en ny plats direkt. ";

    }

    /* show the Conversation chapter */
    showConversationChapter()
    {
        "\b<b>Interagera med andra karaktärer</b>
        \bDin karaktär kan stöta på andra människor eller varelser i 
        berättelsen. Du kan ibland interagera med dessa karaktärer.\b";

        /* show the customizable conversation instructions */
        conversationInstructions;
    }

    /* Time chapter */
    showTimeChapter()
    {
        "\b<b>Tid</b>";

        "\bTiden går i berättelsen bara som svar på kommandon du skriver. Detta
        innebär att ingenting händer medan berättelsen väntar på att du ska 
        skriva något. Varje kommando tar ungefär lika lång tid i berättelsen. 
        Om du specifikt vill låta lite extra tid gå inom berättelsen, eftersom 
        du tror att något är på väg att hända, kan du skriva VÄNTA
        (eller bara Z). ";        
    }

    /* Saving, Restoring, and Undo chapter */
    showSaveRestoreChapter()
    {
        "\b<b>Spara och återställa</b>
        \bDu kan spara en ögonblicksbild av din nuvarande position i 
        berättelsen när som helst, så att du senare kan återställa 
        berättelsen till samma position. Ögonblicksbilden sparas i en
        fil på din dators hårddisk, och du kan spara så många olika 
        ögonblicksbilder som du vill (i den mån du har utrymme på din 
        hårddisk, i alla fall).\b";

        switch (crueltyLevel)
        {
        case 0:
            "I den här berättelsen kommer din karaktär aldrig att dödas, 
            och du kommer aldrig att hamna i en situation där det är omöjligt
            att slutföra berättelsen. Vad som än händer med din karaktär 
            kommer du alltid att kunna hitta ett sätt att slutföra 
            berättelsen. Så, till skillnad från i många andra textspel, behöver
            du inte oroa dig för att spara positioner för att skydda dig själv 
            mot att fastna i omöjliga situationer. Naturligtvis kan du 
            fortfarande spara så ofta du vill, för att pausa din session och
            återgå till den senare, eller för att spara positioner som du tror
            att du kanske vill återvända till. ";
            break;

        case 1:
        case 2:
            "Det kan vara möjligt att din karaktär dödas i berättelsen, eller 
            att du hamnar i en omöjlig situation där du inte kommer att kunna 
            slutföra berättelsen.

            Så du bör se till att spara din position
            <<crueltyLevel == 1 ? 'då och då' : 'ofta'>>
            så att du inte behöver gå tillbaka för långt om detta skulle 
            hända. ";

            if (crueltyLevel == 2)
                "(Du bör se till att behålla alla dina gamla sparade positioner
                också, eftersom du kanske inte alltid inser omedelbart när en 
                situation har blivit omöjlig. Du kan ibland upptäcka att du 
                behöver gå tillbaka längre än bara den sista positionen som du
                <i>trodde</i> var säker.)";
            break;
        }

        "\bFör att spara din position, skriv SPARA i kommandotolken.
        Berättelsen kommer att fråga dig efter namnet på en fil som ska 
        användas för att lagra ögonblicksbilden. Du måste ange ett filnamn som
        är lämpligt för ditt datorsystem, och disken behöver tillräckligt med 
        ledigt utrymme för att lagra filen. Du kommer få veta om det blir något 
        problem med att spara filen. Du bör använda ett filnamn som inte redan
        finns på din dator, eftersom den nya filen kommer att skriva över alla
        befintliga filer med samma namn.

        \bDu kan återställa en tidigare sparad position genom att skriva 
        ÅTERSTÄLL vid valfri prompt. Berättelsen kommer att fråga dig efter 
        namnet på filen som ska återställas. När datorn har läst filen kommer
        allt i berättelsen att vara exakt som det var när du sparade filen.

        \b<b>Ångra</b>
        \bÄven om du inte har sparat din position nyligen kan du vanligtvis 
        återställa dina senaste kommandon med ÅNGRA-kommandot.
        Varje gång du skriver [ÅNGRA], upphäver berättelsen effekten av 
        ett kommando, och återställer berättelsen som den var innan du 
        skrev det kommandot. ÅNGRA är begränsad till att återställa de senaste 
        kommandona, så detta är inte en ersättning för SPARA/ÅTERSTÄLL, men det 
        är väldigt praktiskt om du oväntat befinner dig i en farlig situation, 
        eller om du gör ett misstag som du vill återställa från. ";
    }

    /* Other Special Commands chapter */
    showSpecialCmdChapter()
    {
        "\b<b>Några andra specialkommandon</b>
        \bBerättelsen förstår några andra specialkommandon som du kan
        ha nytta av.

        \bIGEN (eller bara G): Upprepar det senaste kommandot. (Om din
        senaste inmatningsrad innehöll flera kommandon är det bara det
        sista enskilda kommandot på raden som upprepas.)
        \bINVENTERING (eller bara I): Visar vad din karaktär bär på.
        \bTITTA (eller bara T): Visar den fullständiga beskrivningen
        av din karaktärs nuvarande plats.";

        /* if the exit lister module is active, mention the EXITS command */
        if (gExitLister != nil)
            "\bUTGÅNGAR: Visar en lista över de tydliga utgångarna
            från den aktuella platsen.
            \bUTGÅNGAR PÅ/AV/STATUS/TITTA: Styr hur berättelsen visar
            listor över utgångar. UTGÅNGAR PÅ lägger till en lista
            över utgångar i statusraden och listar även utgångar i
            varje platsbeskrivning. UTGÅNGAR AV stänger av båda dessa
            listor. UTGÅNGAR STATUS slår bara på listan i statusraden,
            och UTGÅNGAR TITTA slår bara på listorna i
            platsbeskrivningarna.";

        "\bHOPPSAN (eller bara OJ): Rättar ett enda felstavat ord i ett
        kommando, utan att du behöver skriva om hela kommandot. Du kan
        bara använda HOPPSAN direkt efter att berättelsen har talat om
        för dig att den inte kände igen ett ord i ditt föregående
        kommando. Skriv HOPPSAN följt av det rättade ordet.
        \bAVSLUTA (eller bara Q): Avslutar berättelsen.
        \bBÖRJA OM: Startar om berättelsen från början.
        \bÅTERSTÄLL: Återställer en position som tidigare sparats med
        SPARA.
        \bSPARA: Sparar den aktuella positionen i en fil.
        \bSKRIPT: Börjar göra en avskrift av din spelsession, genom
        att spara all visad text till en fil, så att du kan läsa
        igenom den senare eller skriva ut den.
        \bSKRIPT AV: Avslutar en avskrift som du startade med SKRIPT.
        \bÅNGRA: Tar tillbaka det senaste kommandot."
        ;
    }
    
    /* Unknown Words chapter */
    showUnknownWordsChapter()
    {
        "\b<b>Okända ord</b>
        \bBerättelsen låtsas inte känna till varje ord i det svenska
        språket. Berättelsen kan till och med ibland använda ord i
        sina egna beskrivningar som den inte förstår i kommandon. Om
        du skriver ett kommando med ett ord som berättelsen inte
        känner till, kommer berättelsen att tala om för dig vilket ord
        den inte kände igen. Om berättelsen inte känner till ett ord
        för något den har beskrivit, och den inte känner till några
        synonymer för den saken, kan du förmodligen anta att föremålet
        bara finns där som en detalj i miljön, och inte är viktigt för
        berättelsen. ";
    }

    /* Ambiguous Commands chapter */
    showAmbiguousCmdChapter()
    {
        "\b<b>Tvetydiga kommandon</b>
        \bOm du skriver ett kommando som saknar viss viktig information,
        kommer berättelsen att göra sitt bästa för att lista ut vad du
        menar. När det är rimligt uppenbart av sammanhanget vad du
        menar, gör berättelsen ett antagande om den saknade
        informationen och fortsätter med kommandot. Berättelsen
        kommer att påpeka vad den antar i dessa fall, för att undvika
        förvirring från en missmatchning mellan berättelsens antaganden
        och dina. Till exempel:

        \b
        \n\t &gt;FÄST REPET
        \n\t (till kroken)
        \n\t Repet är nu fäst vid kroken. Änden av
        \n\t repet når nästan ner till golvet i gropen nedanför.

        \bOm kommandot är tillräckligt tvetydigt för att berättelsen
        inte säkert kan göra ett antagande, kommer du att bli
        tillfrågad om mer information. Du kan svara på dessa frågor
        genom att skriva den saknade informationen.

        \b
        \n\t &gt;LÅS UPP DÖRREN
        \n\t Vad vill du låsa upp den med?
        \b
        \n\t &gt;NYCKEL
        \n\t Vilken nyckel menar du, guldnyckeln eller silvernyckeln?
        \b
        \n\t &gt;GULD
        \n\t Upplåst.

        \bOm berättelsen ställer en av dessa frågor till dig, och du
        bestämmer dig för att du trots allt inte vill fortsätta med
        det ursprungliga kommandot, kan du bara skriva in ett helt
        nytt kommando istället för att svara på frågan.";
    }

    /* Advance Command Formats chapter */
    showAdvancedCmdChapter()
    {
        "\b<b>Avancerade kommandoformat</b>
        \bNär du väl känner dig bekväm med att skriva in kommandon
        kanske du är intresserad av att veta om några mer komplexa
        kommandoformat som berättelsen accepterar. Dessa avancerade
        kommandon är alla helt valfria, eftersom du alltid kan göra
        samma saker med de enklare formaten vi har talat om hittills,
        men erfarna spelare gillar ofta de avancerade formaten eftersom
        de kan spara lite skrivarbete.

        \b<b>Att använda flera föremål samtidigt</b>
        \bI de flesta kommandon kan du arbeta med flera föremål i ett
        och samma kommando. Använd ordet OCH, eller ett kommatecken,
        för att skilja ett föremål från ett annat:

        \b
        \n\t TA LÅDAN, DISKETTEN OCH REPET
        \n\t LÄGG DISKETT OCH REP I LÅDAN
        \n\t SLÄPP LÅDAN OCH REPET

        \bDu kan använda orden ALLA och ALLT för att syfta på allt som
        är tillämpligt för ditt kommando, och du kan använda UTOM eller
        FÖRUTOM (direkt efter ordet ALLA) för att utesluta specifika
        föremål:

        \b
        \n\t TA ALLT
        \n\t LÄGG ALLA UTOM DISKETT OCH REP I LÅDAN
        \n\t TA ALLT UR LÅDAN
        \n\t TA ALLT FRÅN HYLLAN

        \bALLA/ALLT syftar på allt som är rimligt för ditt kommando,
        förutom sådant som finns inuti andra föremål som också matchar
        ALLA/ALLT. Om du till exempel bär på en låda och ett rep, och
        lådan innehåller en diskett, kommer SLÄPP ALLT att släppa
        lådan och repet, medan disketten stannar kvar i lådan.

        \b<b><q>Den/Det</q> och <q>Dem</q></b>
        \bDu kan använda DEN, DET eller DEM för att syfta på det senaste
        föremålet eller de senaste föremålen som du använde i ett
        kommando:

        \b
        \n\t TA LÅDAN
        \n\t ÖPPNA DEN
        \n\t TA DISKETTEN OCH REPET
        \n\t LÄGG DEM I LÅDAN

        \b<b>Flera kommandon på en gång</b>
        \bDu kan skriva flera kommandon på en enda inmatningsrad genom
        att skilja kommandona åt med punkter eller ordet SEDAN, eller
        med ett kommatecken eller OCH. Till exempel:

        \b
        \n\t TA DISKETTEN OCH LÄGG DEN I LÅDAN
        \n\t TA LÅDAN. ÖPPNA DEN.
        \n\t LÅS UPP DÖRREN MED NYCKELN. ÖPPNA DEN, SEDAN GÅ NORR.

        \b Om berättelsen inte förstår ett av kommandona, kommer den
        att tala om för dig vad den inte kunde förstå, och ignorera
        allt efter det på raden.";
    }

    /* General Tips chapter */
    showTipsChapter()
    {
        "\b<b>Några tips</b>
        \bNu när du känner till de tekniska detaljerna för att skriva
        in kommandon, kanske du är intresserad av lite strategiska tips.
        Här är några tekniker som erfarna spelare av interaktiv fiktion
        använder när de närmar sig en berättelse.

        \bUNDERSÖK allt, särskilt när du kommer till en ny plats för
        första gången. Att titta på föremål avslöjar ofta detaljer som
        inte nämns i platsens övergripande beskrivning. Om en
        undersökning av ett föremål nämner detaljerade delar av
        föremålet, undersök dem också.

        \bRita en karta, om berättelsen har fler än ett fåtal platser.
        När du kommer till en ny plats för första gången, notera alla
        dess utgångar; detta gör det enkelt att med en snabb blick se
        om det finns utgångar du inte har utforskat än. Om du kör fast
        kan du gå igenom din karta efter outforskade områden, där du
        kanske hittar det du letar efter.

        \bOm berättelsen inte känner igen ett ord eller någon av dess
        synonymer, är föremålet du försöker manipulera förmodligen
        inte viktigt för berättelsen. Om du försöker manipulera något,
        och berättelsen svarar med något i stil med <q>det är inte
        viktigt,</q> kan du förmodligen bara ignorera föremålet; det
        finns troligen bara där som miljö, för att göra platsen mer
        detaljerad.

        \bOm du försöker åstadkomma något, och inget du gör verkar
        fungera, var uppmärksam på vad som går fel. Om allt du
        försöker möts av total avvisning (<q>inget händer</q> eller
        <q>det är inte något du kan öppna</q>), kan du helt enkelt
        vara på fel spår; ta ett steg tillbaka och tänk på andra sätt
        att angripa problemet på. Om svaret är något mer specifikt kan
        det vara en ledtråd. <q>Vakten säger <q>du kan inte öppna det
        här!</q>\ och rycker lådan ur dina händer</q> &mdash; det kan
        till exempel tyda på att du måste få vakten att lämna platsen,
        eller att du borde ta med dig lådan någon annanstans innan du
        öppnar den.

        \bOm du kör helt fast kan du prova att lägga det aktuella
        pusslet åt sidan och arbeta med ett annat problem ett tag. Du
        kanske till och med vill spara din position och ta en paus
        från spelet. Lösningen på problemet som har hindrat dina
        framsteg kan komma till dig i en plötslig insikt när du minst
        anar det, och sådana ögonblick av insikt kan vara otroligt
        givande. Vissa berättelser uppskattas bäst när de spelas under
        en period av dagar, veckor, eller till och med månader; om du
        njuter av berättelsen, varför skynda igenom den?

        \bSlutligen, om allt annat misslyckas, kan du försöka be om
        hjälp. Ett bra ställe att gå till för ledtrådar är Interactive
        Fiction Community Forum på
        <a href='https://intfiction.org'>https://intfiction.org</a>. ";

        "\n";
    }

    /* INSTRUCTIONS doesn't affect UNDO or AGAIN */
    isRepeatable = nil
    includeInUndo = nil
;


/* ------------------------------------------------------------------------ */
/*
 *   define the INSTRUCTIONS command's grammar 
 */
VerbRule(instructions) 
    'instruktioner' 
    : VerbProduction
    action = Instructions
    verbPhrase = 'visa/visar instruktioner'
;


/* ------------------------------------------------------------------------ */
/*
 *   The instructions, rendered in menu form.  The menu format helps break
 *   up the instructions by dividing the instructions into chapters, and
 *   displaying a menu that lists the chapters.  This way, players can
 *   easily go directly to the chapters they're most interested in, but
 *   can also still read through the whole thing fairly easily.
 *   
 *   To avoid creating an unnecessary dependency on the menu subsystem for
 *   games that don't want the menu-style instructions, we'll only define
 *   the menu objects if the preprocessor symbol INSTRUCTIONS_MENU is
 *   defined.  So, if you want to use the menu-style instructions, just
 *   add -D INSTRUCTIONS_MENU to your project makefile.  
 */
#ifdef INSTRUCTIONS_MENU

/* a base class for the instruction chapter menus */
class InstructionsMenu: MenuLongTopicItem
    /* 
     *   present the instructions in "chapter" format, so that we can
     *   navigate from one chapter directly to the next 
     */
    isChapterMenu = true

    /* the InstructionsAction property that we invoke to show our chapter */
    chapterProp = nil

    /* don't use a heading, as we provide our own internal chapter titles */
    heading = ''

    /* show our chapter text */
    menuContents = (Instructions.(self.chapterProp)())
;

InstructionsMenu template 'title' ->chapterProp;

/*
 *   The main instructions menu.  This can be used as a top-level menu;
 *   just call the 'display()' method on this object to display the menu.
 *   This can also be used as a sub-menu of any other menu, simply by
 *   inserting this menu into a parent menu's 'contents' list.  
 */
topInstructionsMenu: MenuItem 'Hur spelar man Interaktiv Fiktion';

/* the chapter menus */
+ MenuLongTopicItem
    isChapterMenu = true
    title = 'Introduktion'
    heading = nil
    menuContents()
    {
        "\b<b>Introduktion</b>
        \bVälkommen! Om du aldrig har spelat Interaktiv Fiktion förut 
        är dessa instruktioner utformade för att hjälpa dig att komma 
        igång. Om du redan vet hur man spelar den här typen av spel 
        kan du förmodligen hoppa över de fullständiga instruktionerna, 
        men du kan vilja skriva OM i kommandotolken för en 
        sammanfattning av de speciella funktionerna i just den här 
        berättelsen.
        \bFör att göra instruktionerna enklare att navigera är de 
        uppdelade i kapitel. ";

        if (curKeyList != nil && curKeyList.length() > 0)
            "I slutet av varje kapitel, tryck bara på
            <b><<curKeyList[M_SEL][1].toUpper()>></b> för att gå vidare till nästa kapitel, eller <b><<curKeyList[M_PREV][1].toUpper()>></b>
            för att återgå till kapitellistan. ";
        else
            "För att bläddra igenom kapitlen, klicka på länkarna
            eller använd vänster-/högerpilarna. ";
    }
;

+ InstructionsMenu 'Skriva in Kommandon' ->(&showCommandsChapter);
+ InstructionsMenu 'Kommandoförkortningar' ->(&showAbbrevChapter);
+ InstructionsMenu 'Förflyttning' ->(&showTravelChapter);
+ InstructionsMenu 'Manipulera Ting' ->(&showObjectsChapter);
+ InstructionsMenu 'Interagera med Andra Karaktärer'
    ->(&showConversationChapter);
+ InstructionsMenu 'Tid' ->(&showTimeChapter);
+ InstructionsMenu 'Spara och Återställa' ->(&showSaveRestoreChapter);
+ InstructionsMenu 'Andra specialkommandon' ->(&showSpecialCmdChapter);
+ InstructionsMenu 'Okända ord' ->(&showUnknownWordsChapter);
+ InstructionsMenu 'Tvetydiga kommandon' ->(&showAmbiguousCmdChapter);
+ InstructionsMenu 'Avancerade kommandoformat' ->(&showAdvancedCmdChapter);
+ InstructionsMenu 'Några tips' ->(&showTipsChapter);

#endif /* INSTRUCTIONS_MENU */

