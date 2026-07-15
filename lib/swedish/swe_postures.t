#charset "utf-8"
#include "advlite.h"

// TODO: detect posture extension mod automatically
// [POSTURES EXTENSION MODS]
modify Posture active = nil;

modify standing active = 'står';
modify sitting active = 'sitter';
modify lying active = 'ligger';

modify Thing
    postureDesc = '{är}' // Default postureDesc

    // NOTE: this override is only here because we need to change from pos.participle to pos.active
    tryMakingPosture(pos) {
        if(posture == pos) {
            //DMsg(posture already adopted, '{I} {am} already {1}. ', pos.participle);
            DMsg(posture already adopted, '{Jag} {1} redan. ', pos.active);
        } else if(pos.canAdoptIn(location)) {
            posture = pos;
            //DMsg(okay adopt posture, 'Okay, {i} {am} {now} {1}. ', pos.participle); 
            DMsg(okay adopt posture, 'Okej, {jag} {1} nu. ', pos.active);
        } else {
            local dobj = location;
            gMessageParams(dobj);
            local prop = contType == In ? &cannotInMsgProp : &cannotOnMsgProp;
            prop = pos.(prop);
            say(self.(prop));
        }
    }
;

modify Actor
    // I svenskan använder vi aktiv form istället för participform,
    // behåller participle för andra fall, där de kan tänkas behövas.
    postureDesc = posture.active 
;

/*
// TODO: testa av, bör inte behöva ändras så här:
modify Thing
    nestedLoc(actor) {
        return //BMsg(actor nested location posture name,  
                        bmsg(' (<<actor.posture.participle>>
                             <<actor.location.objInPrep>> 
                             <<actor.location.theName>>)');
    }
;
*/