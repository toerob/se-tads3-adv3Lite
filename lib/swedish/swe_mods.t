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
    //actorAlreadyOnMsg = Msg(already on, '{Jag} {är} redan {i dobj}. ')
    //notImportantMsg = Msg(not important, '{Ref subj cobj} {är} inte viktig{t/a}. ') // TODO: lägg till viktig{t/a}
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

