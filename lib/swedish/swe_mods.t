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
