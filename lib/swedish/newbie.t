#charset "utf-8"
#include "advlite.h"

/*
 *   ****************************************************************************
 *    newbie.t 
 *    This module forms part of the adv3Lite library 
 *    (c) 2012-13 Eric Eve
 */
#include "advlite.h"

/* 
 *   Many of the ideas in this file are based on Emily Short's 
 *   NewbieGrammar.h extension for Inform 6, itself based on observation of 
 *   some of the non-standard things newcomers to IF tend to type. The idea 
 *   is to get the parser to recognize these commands, at least to the 
 *   extent of giving the player who issues them some help towards typing 
 *   more useful commands rather than giving a standard (and probably 
 *   unhelpful) parser error message
 *
 *   We also provide some helpful brief IF playing instructions for newbies, 
 *   a sample transcript they can view to get the general idea, and a 
 *   mechanism to check whether someone is entering an excessive number of 
 *   invalid commands (so that we can then offer more help).
 */


helpMessage: object
    printMsg {
        "<<if defined(Instructions)>>Om du är ny på interaktiv fiktion kan du
        skriva <<aHref('INSTRUKTIONER', 'INSTRUKTIONER', 'Visa fullständiga
            instruktioner')>> vid prompten för en fullständig förklaring av hur du
        interagerar med programvaran och berättelsen; för<<else>>För<<end>> en kort
        introduktion till att spela den här typen av spel, skriv <<aHref('INTRO', 'INTRO',
            'Visa en kort introduktion')>>, eller <<aHref('SAMPLE', 'SAMPLE', 'Visa
                ett kort exempeltranskript')>> för att visa ett kort exempeltranskript.
        <<if gHintManager != nil>>Om du har problem med att komma vidare och
        behöver hjälp med att lösa ett pussel, skriv <<aHref('HINT', 'HINT', 'Visa
            ledtrådar')>>.<<end>> ";
        
        if(defined(extraHintManager))
           extraHintManager.explainExtraHints();
        
        if(versionInfo.propDefined(&showAbout, PropDefDirectly))
           "För mer information specifik för detta spel, skriv <<aHref('ABOUT',
               'ABOUT', 'Visa information om detta spel')>>. ";
    }
    
    briefIntro()
    {
        "Du spelar den här typen av spel genom att ange korta kommandon (försök att använda så
        få ord som möjligt). Exempel inkluderar:\b
        VÄSTER\n
        X NYCKLAR\n  
        TA BOK\n
        LÄS BOK\n
        SLÄPP BOK\n
        LÄGG BOK PÅ BORD\n
        ÖPPNA DÖRR\b
        För att röra dig runt använd kompassriktningar: NORR, ÖSTER, SÖDER etc. Dessa kan
        förkortas till N, Ö, S, V, NO, NV, SO, SV.
        Du kan också använda IN, UT, UPP och NER.\b 
        UNDERSÖK (= TITT PÅ) kan förkortas till X; X BOK, UNDERSÖK BOK och
        TITT PÅ BOK betyder alla samma sak.\b
        Kommandot INVENTERING (eller bara I) ger dig en lista över vad du bär.\n
        Använd TITT eller L för att upprepa beskrivningen av din nuvarande plats.\n
        IGEN eller G upprepar föregående kommando.\b
        För fullständiga instruktioner, använd kommandot <<aHref('INSTRUKTIONER', 'INSTRUKTIONER',
                                              'Visa fullständiga instruktioner')>>.\n
        För att se ett exempeltranskript, använd kommandot <<aHref('SAMPLE', 'SAMPLE', 'Visa
            exempeltranskript')>>. ";
    }

    showSample()
    {
        "Ett typiskt spel (inte just detta) kan börja så här:\b";
        inputManager.pauseForMore();
        "<b>>x mig</b>\n
        Du är en ganska stilig ung man.\b
        <b>>i</b>\n
        Du bär en ficklampa och en skattkarta.\b
        <b>>x karta</b>\n
        Så vitt du kan se, visar kartan att en skatt var gömd
        under jorden någonstans på Horatio Bumblespoons egendom.\b
        <b>>l</b>\n
        <b>Bumblespoons Bakgård</b>\n
        Efter år av försummelse har denna bakgård blivit helt
        övervuxen med ett virrvarr av ogräs och törnen. En stig leder norrut runt
        huset, och du kan precis urskilja en smal trappa
        som leder ner i mörkret.\b
        <b>>x ogräs</b>\n
        Ogräset är inte viktigt.\b
        <b>>ner</b>\n
        <b>I Mörkret</b>\n
        Det är kolsvart här inne.\b
        <b>>tänd ficklampa</b>\n
        <b>Fuktig Källare</b>\n
        Grön mögel täcker väggarna, och en hög med rostigt skräp fyller ett
        hörn. Den enda vägen ut verkar vara tillbaka uppför trappan.\b
        <b>>x skräp</b>\n
        Det är mest bitar av trasiga trädgårdsredskap, tillsammans med resterna
        av en metallbäddsram. Men under allt kan du precis urskilja vad som ser ut som en stor kista.\b
        <b>>x kista</b>\n
        Det är en stor träkista, förstärkt med stålband. Den är stängd.\b
        <b>>öppna kista</b>\n
        Du kan inte riktigt komma åt den med allt det där skräpet i vägen.\b
        <b>>flytta skräp</b>\n
        Du lyckas flytta en hel del av skräpet, vilket frigör din tillgång till
        träkistan under.\b
        <b>>öppna kista</b>\n
        (först försöker låsa upp träkistan)\n
        Träkistan verkar vara låst.\b
        <b>>lås upp kista</b>\n
        Vad vill du låsa upp den med?\b
        <b>>nyckel</b>\n
        Du ser ingen nyckel här.\b
        Vid denna punkt vet spelaren att han eller hon måste gå på jakt efter nyckeln,
        och förmodligen är det så här spelet skulle fortsätta.\b";
        inputManager.pauseForMore();
        "Och nu tillbaka till spelet du faktiskt spelar....\b";
        gPlayerChar.getOutermostRoom.lookAroundWithin();      
        
    }
;

/* Declare these two properties in case the hintsys module isn't present */
property extraHintsExist;
property explainExtraHints;

 /* 
  *   The playerHelper is an object that starts a daemon at start of play. 
  *   This daemon checks whether the player is making any progress at all, 
  *   and also watches the ratio of commands the parser rejects to the 
  *   number of turns. If this ratio becomes too high (as defined by the 
  *   errorThreshold property) we offer the player a HELP command. If it 
  *   becomes very low (as defined by the ceaseCheckingErrorLevel property) 
  *   we cease checking (i.e. stop the daemon) on the grounds that the 
  *   player doesn't appear to need the kind of help we want to offer. We 
  *   first perform a check after firstCheckAfter turns to see if the player 
  *   is making any progress, and then after each errorCheckInterval turns 
  *   to see if the player is having difficulty entering valid commands. 
  *
  *   The idea is to keep offering HELP to an inexperienced player who 
  *   clearly needs it, even if the player declined to read any help text at 
  *   the start of the game.
  */
playerHelper: InitObject
    
    /* 
     *   Set up the firstCheck() Fuse and note the player character's starting
     *   location.
     */
    execute()
    {
        new Fuse(self, &firstCheck, firstCheckAfter);       
        
        startLocation = gPlayerChar.location;
    }
    
    /* 
     *   The location the playerCharacter starts out in at the beginning of the
     *   game. It may be useful to know this in the firstCheckCriterion method.
     */
    startLocation = nil
    
    /*  
     *   The number of turns that must elapse before we test the
     *   firstCheckCriterion to see if the player appears to be stuck.
     */
    firstCheckAfter = 10
    
    /*   
     *   The message to display if the player seems to be stuck at the start of
     *   the game.
     */
    firstCheckMsg =  "<.p>Du verkar inte göra mycket framsteg. Om du
        känner att du kan behöva lite hjälp, ange
        kommandot <<aHref('HELP', 'HELP', 'Begär hjälp')>>. "
    
    /* 
     *   The number of turns between each check on whether the player is
     *   entering too many erroneous commands.
     */
    errorCheckInterval = 20
    
    /* 
     *   The proportion of rejected commands to turns (i.e. accepted 
     *   commands) that will trigger an offer of help. We express this 
     *   number as a percentage.
     */
    errorThreshold = 50
    
    /* 
     *   The proportion of rejected commands to turns, expressed as a
     *   percentage, below which we stop checking for errors. The default is 5
     *   (in other words if less than 5 per cent of the player's commands are
     *   being rejected, the player presumably knows what s/he's doing, so we
     *   don't need to keep checking)
     */
    ceaseCheckingErrorLevel = 5
    
    /* 
     *   The criterion to apply to see whether the player is making any progress
     *   at the start of the game. This method should return true if the player
     *   seems to be stuck. By default we simply return nil as there's no way of
     *   knowing how to measure 'stuckness' for games in general, so specific
     *   games will need to override this method. A game involved exploration
     *   might set the condition to gLocation == startLocation (meaning the
     *   player character hasn't moved) for example.
     */
    firstCheckCriterion()
    {
        return nil;
    }
    
    /*  
     *   Check whether the player appears to be making any progress at the start
     *   of the game. If not, display a message offering help and start the
     *   error checking daemon.
     */
    firstCheck()
    {
        /* 
         *   If the player is still in the starting location (and so hasn't 
         *   visited the endOfDriveway, which would trigger its doScript 
         *   method) after 5 turns, s/he may be a novice who's getting stuck, 
         *   so we'll offer help.
         */
        if(firstCheckCriterion())
        {
            /* Display a message offering help. */
            firstCheckMsg;
            /* 
             *   We've just offered help, so we'll wait another 
             *   errorCheckInterval turns before seeing whether to offer it 
             *   again.
             */
            new Fuse(self, &startErrorDaemon, errorCheckInterval);
        }
        else
            startErrorDaemon();
    }
    
    startErrorDaemon() { errorDaemonID = new Daemon(self, &errorCheck, 1); }
    
    /* Watch for a high percentage of errors in user input */
    errorCheck()
    {
        local errorPercent = (100 * errorCount)/libGlobal.totalTurns;
        
        if(errorPercent > errorThreshold)
        {
            "<.p>Vänligen skriv <<aHref('HELP', 'HELP', 'Begär hjälp')>> om du
            behöver hjälp med detta spel.<.p>";
            /* 
             *   We don't want to keep showing this message every turn, so 
             *   we'll turn the daemon off for twenty turns.
             */
            
            stopErrorDaemon();
            new Fuse(self, &startErrorDaemon, errorCheckInterval);
            
        }
        
        /* 
         *   If there are very few input errors, we're probably not needed 
         *   any more
         */
        if(errorPercent < ceaseCheckingErrorLevel)
            stopErrorDaemon();  
        
    }
    
    /* Stop the error check daemon from running */
    stopErrorDaemon()
    {
        if(errorDaemonID != nil)
            errorDaemonID.removeEvent();
        
        errorDaemonID = nil;
    }
       
    /* 
     *   The offerHelp() method asks whether the player has played this kind of
     *   game before and accepts a Y or N answer. if the answer is NO then it
     *   goes on to display a message suggesting sources of help.
     *
     *   This method can usefully be called at the end of the
     *   gameMain.showIntro() method, but it's up to game authors to incluse it
     *   there if they want it/
     */
    offerHelp()
    {
        "Har du spelat den här typen av spel förut? (<b>j</b> eller <b>n</b>) >";
        if(!yesOrNo())
        {
            "\b";
            helpMessage.printMsg();            
        }
        "\b";
    }
    
    /* 
     *   For internal use only: the ID of the currently running error check
     *   Daemon (if there is one)
     */
    errorDaemonID = nil
    
    /*   
     *   For internal use only: the number of badly formed commands the player
     *   has entered.
     */
    errorCount = 0
;

/* 
 *   This game may be played by novice players. We'll try to keep track of 
 *   how many not-understood commands they enter, in case it helps us decide 
 *   whether they need help. The playerHelper object will use this 
 *   information to decide whether to offer help. 
 */

modify NotUnderstoodError
    display()
    {
        inherited;
        playerHelper.errorCount++;
    }
;

modify UnknownWordError
    display()
    {
        inherited;
        playerHelper.errorCount++;
    }
;

modify EmptyNounError
    display()
    {
        inherited;
        playerHelper.errorCount++;
    }
;


//-------------------------------------------------------------------------------
/* 
 *   More newbie-helpful bits and pieces, based on work by Emily Short for I6
 *
 *   The idea is to trap the kind of invalid input a newcomer to IF might 
 *   type and respond with something a bit more helpful than a standard 
 *   parser error message. In some cases we'll execute the command the 
 *   player probably meant, and in others we'll just explain why the command 
 *   failed.
 */

/*  First, trap attempts to refer to body parts */

bodyParts: MultiLoc, Unthing 'kropp; (min) (din) (hans) (hennes) (denna) (vänster)
    (höger); huvud hand öra knytnäve finger tumme arm ben fot öga ansikte näsa mun
    tand tunga läpp knä armbåge; det dem' 
    
    notHereMsg = 'Generellt sett finns det inget behov av att referera till dina
        kroppsdelar individuellt i interaktiv fiktion. BÄR SKOR PÅ FÖTTER kommer
        inte nödvändigtvis att implementeras, till exempel; BÄR SKOR räcker. Och
        om du inte får någon antydan om motsatsen, kan du förmodligen inte ÖPPNA DÖRR
        MED FOT eller LÄGG SAFIRRINGEN I MIN MUN. '

    /* 
     *   By default we want this bodyParts object to be available everywhere (since the player may
     *   try to refer to the PC's bodyparts anywhere, but if your game defines its own body parts
     *   (or items that share vocab with body parts such as the hands of a clock or the legs of a
     *   chair) you may occasionally get unwanted results from having the bodyParts objects present
     *   too. In such a case you can banish the bodyParts object by setting its initialLocationClass
     *   to nil, or otherwise restrict where it turns up.
     */
    initialLocationClass = Room
  
;

/* Trap the use of vague words like 'someone' or 'something' or 'anyone' */
somethingPreParser: StringPreParser
    doParsing(str, which)
    {
        local ret = rexSearch(pat, str);
        if(ret != nil)
        {
            /* first check whether the word occurs in the dictionary */
            local lst = cmdDict.findWord(ret[3]);
            
            /* then see if it matches any objects in scope. */
            lst = lst.intersect(Q.scopeList(gPlayerChar));
            
            /* if not, display a helpful message */
            if(lst.length == 0)
            {
                "Det är vanligtvis bättre att inte använda vaga ord som
                <q><<ret[3]>></q> i dina kommandon, eftersom spelet inte kommer att
                kunna gissa vad du menar. Var mer specifik och referera till objekten
                i din närhet. ";
                playerHelper.errorCount++;
                return nil;
            }
        }
        return str;
    }
    pat = static new RexPattern('<NoCase>%<(någon|något|vem som helst|vad som helst)%>')

   isActive = (gPlayerChar.currentInterlocutor == nil)
;

/* 
 *   Trap commands like LOOK HERE or SEARCH THERE. We'll actually carry out 
 *   a LOOK command, but we'll also tell the player just to use LOOK in 
 *   future.
 */
DefineIAction(LookHere)
    execAction(cmd)
    {
        gActor.getOutermostRoom.lookAroundWithin();
        playerHelper.errorCount++;
        "<.p>[För framtida referens, du behöver inte referera till platser i spelet med ord som <q><<cmd.verbProd.placeName>></q>; ett enkelt TITT kommando räcker]<.p>";
    }
;
    
VerbRule(LookHere)
    ('t' | 'titta' | 'sök') ('här'->placeName|'där'->placeName)
    : VerbProduction
    action = LookHere
    verbPhrase = 'titta/tittar'
;

/* 
 *   Trap the words KINDLY and PLEASE in a player's command, and explain that
 *   they shouldn't be used, giving examples of the kind of commands to use
 *   instead. (But don't do this in conversation, where these words might be
 *   part of valid conversational exchange)
 */
pleasePreParser: StringPreParser
    doParsing(str, which)
    {
        if(rexMatch(pat, str) && gPlayerChar.currentInterlocutor == nil)
        {
            "Det är väldigt artigt av dig, men det finns verkligen inget behov av att använda ord
            som <q>snälla</q> och <q>vänligen</q>; du kommer att upptäcka att spelet
            förstår dig mycket bättre om du håller dig till enkla imperativ
            som GÅ NORR, eller X NYCKLAR eller LÄGG LÅDA PÅ BORD. <.p>";
            playerHelper.errorCount++;
            return nil;
        }
        return str;
    }
    pat = static new RexPattern('<NoCase>%<(snälla|vänligen)%>')
;

/* 
 *   Trap any command beginning with USE, telling the player to be more specific, unless the game
 *   code defines its own Use action.
 */
usePreParser: StringPreParser
    doParsing (str, which)
    {
        if(str.toLower.startsWith('använd ') && !(defined(Use) && Use.ofKind(Action)))        
        {
            "<.p>Jag känner inte igen kommandot ANVÄND, eftersom det är lite för
            vagt; var mer specifik om vad du vill göra.<.p>";
            playerHelper.errorCount++;
            return nil;
        }
        
        return str;
    }
;

/* 
 *   Trap commands like KEEP GOING NORTH or CONTINUE HEADING WEST. We'll 
 *   carry out the directional movement command obviously intended, but 
 *   advise the player on the standard form of such commands.
// */
KeepGoing: TravelAction
    execAction(cmd)
    {
        local action = Go.createInstance();
        cmd.dobj = cmd.verbProd.dirMatch.dir;
        
        action.execAction(cmd);
        "[I de flesta interaktiva fiktioner är det nödvändigt och enklare att
        formulera kommandon som detta som enkla riktningar: GÅ NORR, NORR (eller
        bara N), etc., snarare än FORTSÄTT GÅ NORR, GÅ TILLBAKA NORR,
        etc.]<.p>";
    }
;

VerbRule(KeepGoing)
    ('fortsätt' | 'fortsätt') ('gå'|'gå'|'springa'|'gå') singleDir
    | 'gå' ('tillbaka' | ) singleDir
    : VerbProduction
    action = KeepGoing
    verbPhrase = 'gå/går (vart)'
;

/* 
 *   Trap commands that start with a pronoun (e.g. I AM LOST or YOU ARE SILLY)
 *   and advise the player that they are likely to be unproductive, suggesting
 *   the format of commands that are more likely to work.
 *
 *   Note that we have to make exceptions that allow valid commands starting
 *   with I where I is an abbreviation for INVENTORY, such as I itself, I TALL
 *   and I WIDE. We also have to make exceptions when a conversation is in
 *   progress, since the command could be a valid SayTopic.
 */
pronounUsePreParser: StringPreParser
    doParsing(str, which)
    {
        if(rexMatch(pat3, str) || gPlayerChar.currentInterlocutor != nil)
            return str;
        
        if(rexMatch(pat, str) || rexMatch(pat2, str))
        {
            "Om spelet inte förstår dig, försök att ge dina kommandon i
            imperativ: t.ex., KASTA KNIVEN, men inte JAG VILL VERKLIGEN KASTA
            KNIVEN. Pratiga meningar som DU ÄR ETT VÄLDIGT DUMT SPEL kommer bara att bevisa sig själva sanna.\b
            Om du verkligen känner att spelet letar efter ett ord som inte är
            ett verb (som lösningen på en gåta, t.ex.) försök några variationer, som
            SÄG FLOOBLE.\b
            Om du behöver mer hjälp, försök kommandot <<aHref('HELP','HELP', 'Be om
                hjälp')>>.<.p>";
            playerHelper.errorCount++;
            return nil;
        }
        return str;
    }
    pat = static new RexPattern('<NoCase>^(du|han|hon|det|de|vi|dess|de är' 
                                + '|du är|han är|hon är)<Space|squote>')    
    
    pat2 = static new RexPattern('<NoCase>^(jag|jag är|jag<squote>m)<Space>+%w')
    
    pat3 = static new RexPattern('<NoCase>^jag<Space>+(bred|lång|hybrid|delad)')
;



/* 
 *   Trap commands like WHERE CAN I GET HELP. Print a suitable Help message, 
 *   and then explain the use of the HELP command.
 */
DefineSystemAction(WhereHelp)
    execAction(cmd)
    {
        "[Ett enkelt HJÄLP skulle räcka]<.p>";
        helpMessage.printMsg();
    }
;

VerbRule(WhereHelp)
    'var' ('kan' | 'gör' | 'gör' | 'ska') 
    ('jag' | 'vi' | 'någon' | 'vem som helst'| 'någon') 
    ('få' | 'hitta' | 'skaffa')
    ('hjälp' | 'assistans' | 'instruktioner')
    (literalDobj | )
    : VerbProduction
    action = WhereHelp
    verbPhrase = 'be om/be om hjälp'
    priority = 80
    
    /* 
     *   Don't match this grammar if the player char is in conversation, since
     *   in that case the player may be attempting a valid conversational
     *   command)
     */
    isActive = (gPlayerChar.currentInterlocutor == nil)
;

DefineSystemAction(Help)
    execAction(cmd)   {   helpMessage.printMsg();   }
;

/* Provide grammar to understand a fairly wide variety of requests for help */

VerbRule(Help)
    ('hjälp' | 'assistans' | 'assistans' ) |
    'hur' ('gör' | 'kan' | 'gör' | 'kommer' | 'ska' | 'kunde' | 'borde' | 'får'
           | 'måste') 
    ('jag' | 'mig' | 'han' | 'hon' | 'det' | 'vi' | 'du' | 'de' | 'person' | 'någon'
     | 'någon' | 'vem som helst' | 'någon' | 'vem som helst') literalDobj
    
    : VerbProduction
    action = Help
    verbPhrase = 'hjälp/hjälpa med programvaran'
    
    priority = 80
    
    /* 
     *   Don't match this grammar if the player char is in conversation, since
     *   in that case the player may be attempting a valid conversational
     *   command)
     */
    isActive = (gPlayerChar.currentInterlocutor == nil)
;

VerbRule(WhatNext)
    'vad' ('nästa' | 'nu') |
    'vad' ('ska' | 'kan' | 'gör' | 'gör' | 'är' | 'är') 
    ('jag' | 'någon' |'vem som helst' | 'någon') 
    (('menade' 'att')|) ('gör' | 'försök') ('nästa' | 'nu'|)
    : VerbProduction
    action = Help
    verbPhrase = 'hjälp/hjälpa med programvaran'
    
    priority = 80
    
    /* 
     *   Don't match this grammar if the player char is in conversation, since
     *   in that case the player may be attempting a valid conversational
     *   command)
     */
    isActive = (gPlayerChar.currentInterlocutor == nil)
;


/* 
 *   Provide a command to display a brief introduction to playing IF (as an 
 *   alternative to the full INSTRUCTIONS menu provided by the TADS 3 library)
 */
DefineSystemAction(Intro)
    execAction(cmd) { helpMessage.briefIntro(); }
;

VerbRule(Intro)
    ('visa'|'visa'|) ('kort'|) ('intro' | 'introduktion')
    : VerbProduction
    action = Intro
    verbPhrase = 'visa/visar kort introduktion'    
;

/* Provide a command to show the player a sample transcript */
DefineSystemAction(Sample)
    execAction(cmd) { helpMessage.showSample(); }
;

VerbRule(Sample)
    ('visa'|'visa'|) 'exempel' ('transkript' | )
    : VerbProduction
    action = Sample
    verbPhrase = 'visa/visar exempeltranskript'
;



/* 
 *   Make WHAT IS X behave like EXAMINE X, but then explain the standard 
 *   phrasing of an EXAMINE command. 
 */

VerbRule(WhatIsNoun)
    ('vad är' | 'vad' ('är'|'är')) multiDobj
    : VerbProduction
    action = Examine
    verbPhrase = 'undersök/undersöker (vad)'
    
    priority = 80
    
    /* 
     *   Don't match this grammar if the player char is in conversation, since
     *   in that case the player may be attempting a valid conversational
     *   command)
     */
    isActive = (gPlayerChar.currentInterlocutor == nil)
;

modify Examine
    execAction(cmd)
    {
        inherited(cmd);        
        if(cmd.verbProd.grammarTag == 'WhatIsNoun')
        {
            local obj = cmd.dobj;
            "[Du kan göra detta i framtiden genom att använda <<aHref('X '+ obj.name.toUpper,
                'X ' + obj.name.toUpper, 'Undersök ' + obj.theName)>>, vilket är
            snabbare och mer standard.]\b";
            playerHelper.errorCount++;
        }            
    }   
;

/* 
 *   Trap variants on WHAT AM I CARRYING that should be turned into an INVENTORY
 *   command.
 */

VerbRule(WhatAmICarrying)
    'vad' ('är'|'är') ('jag'|'vi'|'du') ('bär' | 'håller')
    | 'vad' 'har' ('jag'|'vi'|'du')
    | 'vad' 'har' ('jag'|'vi'|'du') 'fått'
    : VerbProduction
    action = Inventory
    verbPhrase = 'ta/tar inventering'
    priority = 80
    isActive = (gPlayerChar.currentInterlocutor == nil)
;

modify Inventory
    execAction(cmd)
    {
        inherited(cmd);        
        if(cmd.verbProd.grammarTag == 'WhatAmICarrying')
        {            
            "[Du kan göra detta i framtiden genom att använda <<aHref('INVENTERING',
                'INVENTERING', 'Ta inventering')>> eller bara
            <<aHref('I', 'I', 'Ta inventering')>>, vilket är
            snabbare och mer standard.]\b";
            playerHelper.errorCount++;
        }            
    } 
;


/* 
 *   Trap a variety of commands of the sort WHAT IS GAME ABOUT or WHATS THE 
 *   POINT and respond by showing the game's ABOUT text.
 */
VerbRule(WhatsThePoint)
    ('vad är' | 'vad' 'är') ('poängen'|) ('poängen' | 'idén' | 'målet' | 'syftet')
    (literalDobj | )
    : VerbProduction
    action = About
    verbPhrase = 'fråga/frågar om spelets poäng'
    
    priority = 80
    
    /* 
     *   Don't match this grammar if the player char is in conversation, since
     *   in that case the player may be attempting a valid conversational
     *   command)
     */
    isActive = (gPlayerChar.currentInterlocutor == nil)
;


VerbRule(WhatThisGame)
    ('vad är' | 'vad' ('är'|'är')) ('spelet' | 'berättelsen' | 'programmet' | 'spelen' | ('interaktiv' 'fiktion')) 
        ('för' | 'om' | )
    : VerbProduction
    action = About
    verbPhrase = 'fråga/frågar vad spelet handlar om'
    
    priority = 80
    
    /* 
     *   Don't match this grammar if the player char is in conversation, since
     *   in that case the player may be attempting a valid conversational
     *   command)
     */
    isActive = (gPlayerChar.currentInterlocutor == nil)
;


/* 
 *   Trap a variety of vague travel commands like GO SOMEWHERE or WALK 
 *   AROUND or TURN RIGHT and explain how movement commands should be 
 *   phrased. Then display a list of available exits from the current 
 *   location.
 */
DefineIAction(GoSomewhere)
    execAction(cmd)
    {
        "Om du vill gå någonstans, använd en av kompassriktningarna (NORR,
        ÖSTER, SÖDER, VÄSTER, NO, NV, SO, SV etc). ";
        
        playerHelper.errorCount++;
        
        if(defined(exitLister) &&
           exitLister.cannotGoShowExits(gActor, gActor.getOutermostRoom));        
    }
    actionTime = 0
;

VerbRule(GoSomewhere)
    (('gå' | 'promenera' |  'fortsätt' | 'spring') ( | ('till' 'den') )
    ('vänster' | 'höger' | 'framåt' | 'framåt' | 'framåt' | 'framåt' |
     'runt' | 'någonstans' | (('rakt'| ) 'fram'))) | ('sväng'
         ('vänster'|'höger'))
    : VerbProduction
    action = GoSomewhere
    verbPhrase = 'gå/går någonstans'
;

modify VagueTravel
    execAction(cmd)  {  delegated GoSomewhere(cmd);  }
;

/*  
 *   Trap commands like WHERE AM I or WHERE ARE WE or WHAT IS HERE. Perform 
 *   a LOOK command but explain that LOOK is the phrasing to use.
 */
DefineIAction(WhereAmI)
    execAction(cmd)
    {
        gActor.getOutermostRoom.lookAroundWithin();
        "<.p>[I framtiden, använd bara kommandot <<aHref('LOOK','LOOK', 'Titta runt')>>
        ]<.p>";
    }
     
;

VerbRule(WhereAmI)
    'var' ('är' | 'är' | 'är') ('jag' | 'vi')
    : VerbProduction
    action = WhereAmI
    verbPhrase = 'titta/tittar'
    
    priority = 80
    isActive = (gPlayerChar.currentInterlocutor == nil)
;

VerbRule(WhatsHere)
    'vad' 'är' 'här'
    | 'vad' 'är' 'här'
    : VerbProduction
    action = WhereAmI
    verbPhrase = 'fråga/frågar vad som är här'
    
    priority = 80
    isActive = (gPlayerChar.currentInterlocutor == nil)
;  

/* 
 *   Provide a response to WHO AM I. We provide a brief explanation and then 
 *   perform an EXAMINE ME command to add any game-specific player character 
 *   description. 
 */
DefineIAction(WhoAmI)
    execAction(cmd)
    {
        "[Du är huvudpersonen i spelet. Naturligtvis kan spelutvecklaren
        ha gett dig en beskrivning. Du kan se denna beskrivning i framtiden genom att skriva <<aHref('X ME','X ME','Undersök mig')>>], vilket är
        snabbare och mer standard.]\b";
        replaceAction(Examine, gPlayerChar);
        playerHelper.errorCount++;
    }
;

VerbRule(WhoAmI)
    ('vem'| 'vad') ('är'|'är') ('jag'|'mig')
    : VerbProduction
    action = WhoAmI
    verbPhrase = 'fråga/frågar vem jag är'
    
    priority = 80
    isActive = (gPlayerChar.currentInterlocutor == nil)
;


/* 
 *   Trap commands like WHERE CAN I GO. Perform an EXITS command to list the 
 *   exits, but then tell the player to use the wording EXITS in future.
 */
DefineIAction(WhereGo)
    execAction(cmd)
    {
        nestedAction(Exits);
        "<.p>[I framtiden, använd bara kommandot UTGÅNGAR]<.p>";
    }
;

VerbRule(WhereGo)
    'var' ('kan' | 'gör' | 'gör' | 'ska') ('jag' | 'vi' | 'någon'| 'vem som helst') 
    'gå'
    : VerbProduction
    action = WhereGo
    verbPhrase = 'visa/visar utgångar'
    
    priority = 80
    isActive = (gPlayerChar.currentInterlocutor == nil)
;



/*  
 *   The StringPreparser and the TopicAction which follows are designed to 
 *   deal with command like LOOK FOR X, FIND Y or SEARCH FOR Z. The 
 *   complication is that in the standard library these are all forms of 
 *   LOOK UP X, which prompt the response "What do you want to look that up 
 *   in?". This is likely to confuse new players.
 *
 *   The StringPreparser checks to see if there's a Consultable in the 
 *   current location. If so, then we use the standard library handling, on 
 *   the assumption that the player is trying to looking something up in it. 
 *   If not we change the command to SEEK X in order to invoke the new 
 *   SeekAction defined below.
 */

seekPreParser: StringPreParser
    doParsing(str, which) 
    {        
        local doReplacement = true;
        
        if(defined(Consultable) && firstObj(Consultable))
        {
            doReplacement = nil; 
        }
        
        if(doReplacement && rexMatch(pat, str))  
           str = rexReplace(pat, str, 'sök', ReplaceOnce); 
        
        return str;
    }
    pat = static new RexPattern('^<NoCase>%<(hitta|leta efter|sök efter|jaga efter)%>')
;

/*  
 *   SeekAction is designed to handle of commands FIND X, LOOK FOR Y or 
 *   SEARCH FOR Z, when they don't seem to be intended as attempts to look 
 *   something up in a Consultable. We make it a TopicAction so that it will 
 *   match whatever the player types, and so not give away any premature 
 *   spoilery information by the nature of the parser's response.
 *
 *   The appropriate response then depends on the player character's state of
 *   knowledge. In the most general case the player is simply given 
 *   instructions on how to go about looking for things. This hardly seems 
 *   appropriate, however if the object requested is in plain sight, in 
 *   which case we point this out to the player. As a courtesy to the 
 *   player, we also remind him or her of where an object was last seen, if 
 *   it has been seen.
 *
 *   One or two complications need to be dealt with. If the player finds 
 *   something like FIND SMELL or FIND NOISE then we should describe it as 
 *   having been smelt or heard elsewhere, not seen. We also want to make 
 *   sure that the command never matches an Unthing in preference to a 
 *   Thing, and that if an Unthing is matched it is not described as being 
 *   present.
 */    

DefineTopicAction(Seek)
    execAction(cmd)
    {
        local obj = getBestMatch(cmd);
        gMessageParams(obj);
        if(obj && obj.ofKind(Unthing))
        {
            say(obj.notImportantMsg);
            return;
        }
           
        if(obj == gPlayerChar)
        {
            "Om du har lyckats tappa bort din spelkaraktär, måste saker och ting vara
            desperata! Men oroa dig inte, {I}{\'m} precis {här}. ";
            return;
        }
        
        if(obj && obj.ofKind(Thing) && gActor.hasSeen(obj))
        {
            local loc = obj.location;
            if(loc == nil)
            {
                if(obj.isIn(gActor.getOutermostRoom))
                    loc = gActor.getOutermostRoom;
                else if(obj.ofKind(MultiLoc) && obj.locationList.length > 0)
                    loc = obj.locationList[1];
            }
            
            
            if(obj.isIn(gActor))
                "{I} {bär} {him obj}. ";
            else if(gActor.canSee(obj) && loc != nil)
            {
                "{The subj obj} {är} ";
                if(loc == gActor.getOutermostRoom)
                    "precis {här}. ";
                else 
                    "<<obj.isIn(gActor.getOutermostRoom) ? '' : 'nära, '>>
                    <<locDesc(obj, loc)>>. ";
            }
            else
                "{I} {|hade} senast <<senseDesc(obj)>> {the obj}
                <<locDesc(obj, obj.lastSeenAt)>>. ";
        }
        else
            "Om du vill hitta något du inte kan se, måste du leta
            efter det. Om du tror att det kan vara på din nuvarande plats, försök
            undersöka saker, söka saker, öppna saker som kan öppnas, eller
            titta i, under och bakom saker. Om det du letar efter
            kan vara någon annanstans, kan du behöva gå någon annanstans för att hitta det. ";
           
    }
    
    /* 
     *   gTopic.getBestMatch() may not give the best results for our 
     *   purposes. The following code is designed to prefer Things to 
     *   Unthings, and then to prioritize what the player char can see over 
     *   what s/he has seen, and both over what s/he only knows about. If 
     *   none of these find a match, we then revert to gTopic.getBestMatch.
     */
    
    getBestMatch(cmd)
    {
        local lst = valToList(cmd.dobj.topicList);
        
        /* 
         *   First see if our topic list includes anything the actor can see
         *   that's not an Unthing.
         */
        local obj = lst.valWhich({x: x.ofKind(Thing) && gActor.canSee(x) 
                                 && !x.ofKind(Unthing)});
        if(obj != nil)
            return obj;
        
        /* 
         *   Next see if there's anything in our topic list that the actor has
         *   previously seen.
         */
        obj = lst.valWhich({x: gActor.hasSeen(x) && !x.ofKind(Unthing)});
        if(obj != nil)
            return obj;
        
        /* 
         *   Next see if there's anything in our topic list that the actor
         *   knows about.
         */
        obj = lst.valWhich({x: x.ofKind(Thing) && gActor.knowsAbout(x)});        
        
        if(obj != nil)
            return obj;
        
        /* 
         *   Finally, if all else fails, just return the ResolvedTopic's idea of
         *   a best match.
         */   
        return cmd.dobj.getBestMatch();
        
    }
    
    locDesc(obj, loc)
    {
        if(obj.ofKind(Noise) || obj.ofKind(Odor))
            "kommer från <<loc.theName>>";       
        else
            "<<loc.objInName>>";
    }
    
    senseDesc(obj)
    {
        if(obj.ofKind(Noise))
            return 'hörde';
        if(obj.ofKind(Odor))
            return 'kände lukten av';
        return '{såg|sett}';           
    }
 
;

VerbRule(Seek)
    ('sök' | ('jaga' 'efter')) topicDobj
    : VerbProduction
    action = Seek
    verbPhrase = 'sök/söker (vad)'
    missingQ = 'vad vill du söka'
    dobjReply = topicPhrase
;
