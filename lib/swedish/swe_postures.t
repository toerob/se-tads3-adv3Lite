#charset "utf-8"
#include "advlite.h"

// TODO: detect posture extension mod automatically
// [POSTURES EXTENSION MODS]
modify Posture active = nil;

modify standing active = 'står';
modify sitting active = 'sitter';
modify lying active = 'ligger';
modify Thing postureDesc = '{är}';

modify Actor
    // I svenskan använder vi aktiv form istället för participform,
    // behåller participle för andra fall, där de kan tänkas behövas.
    postureDesc = posture.active 
    actorSpecialDesc() {
        if(isPlayerChar) {
            return;
        }
        local descName = proper ? theName : aName;

        if(location == getOutermostRoom)
            "\^<<descName>> <<postureDesc>> {här|där}. ";
        else
            "\^<<descName>> <<postureDesc>> <<location.objInName>>. ";
    }
;
