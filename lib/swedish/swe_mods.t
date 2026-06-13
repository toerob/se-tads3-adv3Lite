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


    sayActorArriving(fromLoc)
    {
        local traveler = self;
        gMessageParams(traveler);
        
        /* Attempt to get the director this actor arrived from. */
        local dir = getOutermostRoom.getDirectionTo(fromLoc);      
        
        /* If we find it, display a message saying we've arrived from that direction. */
        if(dir)
            "{Ref subj traveler} anländ{er/e} <<dir.arrivalName>>. ";
        
        /* Otherwise, just say the actor arrived in the player character's locatton. */
        else            
            "{Ref subj traveler} anländ{er/e} till området. ";
    }
;
