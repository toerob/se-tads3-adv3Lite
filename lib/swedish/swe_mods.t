#charset "utf-8"
#include "advlite.h"

// [POSTURES EXTENSION MODS]

modify Posture
    active = nil
;

// TODO: ok som det är nu?
modify standing
    //participle = BMsg(standing, 'stående') // TODO: ersätt med swe_messages istället
    active = BMsg(stands, 'står') 
;
modify sitting
    //participle = BMsg(sitting, 'sittande') // TODO: ersätt med swe_messages istället
    active = BMsg(sits, 'sitter') 
;
modify lying
    //participle = BMsg(lying, 'liggande') // TODO: ersätt med swe_messages istället
    active = BMsg(lies, 'ligger') 
;


modify Thing
    postureDesc = '{är}'
    //notImportantMsg = Msg(not important, '{Ref subj cobj} {är} inte viktig{t/a}. '),
    actorAlreadyOnMsg = Msg(already on, '{Jag} {är} redan {i dobj}. ')
    
    notImportantMsg = Msg(not important, '{Ref subj cobj} {är} inte viktig{t/a}. ') // TODO: lägg till viktig{t/a}

    //moveNoEffectMsg = Msg(move no effect, 'Att flytta på {1} {dummy} {har} ingen effekt. ')
    //cannotEnterMsg = BMsg(cannot enter, '{The subj dobj} {is} not something {i} {can} enter. ')
    //actorAlreadyInMsg = BMsg(actor already in, '{Jag} {är} redan {i dobj}. ')
     
    //cannotGetInCarriedMsg = BMsg(cannot enter carried, '{I} {can\'t} get in {the dobj} while {i}{\'m} carrying {him dobj}. ')
    //cannotBoardMsg = BMsg(cannot board, '{The subj dobj} {is} not something {i} {can} get on. ')
    //cannotBoardSelfMsg = BMsg(cannot board self, '{I} {can} hardly get on {myself}. ')         
    //cannotGetOnCarriedMsg = BMsg(cannot board carried, '{I} {can\'t} get on {the dobj} while {i}{\'m} carrying {him dobj}. ')
;



modify Actor
    postureDesc = posture.participle // I svenskan använder vi aktiv form istället för participform
    actorSpecialDesc()
    {
        if(isPlayerChar)
            return;

        local descName = proper ? theName : aName;

        if(location == getOutermostRoom)
            "\^<<descName>> <<postureDesc>> {här|där}. ";
        else
            "\^<<descName>> <<postureDesc>> <<location.objInName>>. ";
    }
;



// We need to modify this because the original uses openTextFile with 'us-ascii' hardcoded
modify Test
    run()
    {
        "====================================\n";
        "Test: \"<<testName>>\"\n";

        if(restartBeforeTest) {
            local hld = allNewTests.savedState();
            if(allNewTests.restoregame(&restartSaveFile) == nil) {
                allNewTests.isTesting = nil;    // failed so quit the test
                return;
            }
            allNewTests.restoreState(hld);
        }

        /* we save the entire game at this point by default to restore it */
        if(restoreStartStateAfterTest)
            allNewTests.savegame(&revertSaveFile); // save the current state

        /* 
         *   If a location is specified, first move the actor into that
         *   location.
         */
        if (location && gPlayerChar.location != location)
        {
            gPlayerChar.moveInto(location);	
            
            /* If we want to report the move, show the new room description */
            if(reportMove)
                gPlayerChar.getOutermostRoom.lookAroundWithin();
        }
        
        /*   Move any required objects into the actor's inventory */
        getHolding();

        /* Export a file to use */
        local txt;
        local temp = new TemporaryFile();
        local f = File.openTextFile(temp, FileAccessWrite, 'utf-8'); // NOTE: why we need to modify this class

        local testVec = new Vector(testList);

        /*   Preparse and execute each command in the list */
        local linecnt = 0;
        testVec.forEach(new function(x)  {
            local c = x.trim();
            f.writeFile('><<c>>\n');
            ++linecnt;
        });
        f.closeFile();
        allNewTests.isTesting = true;
        setScriptFile(temp,ScriptFileNonstop);
        do
        {
            /* Display score notifications if the score module is included. */
            if(defined(scoreNotifier) && scoreNotifier.checkNotification())
                ;
            
            /* run any PromptDaemons if the events module is included */
            if(defined(eventManager) && eventManager.executePrompt())
                ;
        
            try
            {
                /* Output a paragraph break */
                "<.p>";
                
                /* Read a new command from the keyboard. */
                "<.inputline>";
                DMsg(command prompt, '>');
                txt = inputManager.getInputLine();
                "<./inputline>\n";   
                
                if(clearAssertBufferBeforeCmd && !txt.startsWith('assert'))
                    allNewTests.lastMsg = '';
                
                
                /* Pass the command through all our StringPreParsers */
                txt = StringPreParser.runAll(txt, Parser.rmcType());
                
                /* 
                 *   If the txt is now nil, a StringPreParser has fully dealt with
                 *   the command, so go back and prompt for another one.
                 */        
                if(txt == nil)
                    continue;
                
                /* Parse and execute the command. */
                Parser.parse(txt);
            }
            catch(TerminateCommandException tce)
            {
                
            }
            
            /* Update the status line. */
            statusLine.showStatusLine();
 
        } while (--linecnt > 0 && allNewTests.isTesting);

        if(restoreStartStateAfterTest) {

            local hld = allNewTests.savedState();
            allNewTests.restoregame(&revertSaveFile); // restore the saved state
            allNewTests.restoreState(hld);
        }
        // this means an error happened so this script needs to go away
        if(!allNewTests.isTesting)
            setScriptFile(nil);
        temp.deleteFile();        
    }
;