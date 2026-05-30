#charset "utf-8"
#include <tads.h>
#include "advlite.h"

#include "testunit.h"

versionInfo: GameID
  IFID = 'af4b0905-a899-4ede-8c5b-b5012aa1e5bf'
  name = 'Svensk översättning'
  byline = 'by Tomas Öberg'
  htmlByline = 'by <a href="mailto:yourmail@address.com">Tomas Öberg</a>'
  version = '1'
  authorEmail = 'Tomas Öberg yourmail@address.com'
  desc = 'En svensk översättning av adv3Lite'
  htmlDesc = 'En svensk översättning av adv3Lite'
;

gameMain: GameMainDef
  initialPlayerChar = spelare2aPerspektiv
  usePastTense = true
;

// Test arrangements
modify testRunner 
  verboseAboutSuccessfulTests = nil // Visa inte varje testutfall om det var OK
;

modify mainOutputStream
    hideOutput = true
    capturedOutputBuffer = nil // = static new StringBuffer()
    writeFromStream(txt) {
        if(capturedOutputBuffer == nil) {
          capturedOutputBuffer = new StringBuffer();
        }
        capturedOutputBuffer.append(txt);
        // Swallow the message
        if(!hideOutput) {
          inherited(txt);
        }
    }
;


modify String
    // Same as trim, both also trims whitespace vertically
    trimWS() { return findReplace(trimPatWS, ''); }
    trimPatWS = R'^<space>+|<vspace>|<newline>+|$'
;

// Shortcut to access the output without lengthy comparisons
#define o toString(mainOutputStream.capturedOutputBuffer)

// Rensa fångst-buffern varje gång samt sätt ett default gAction 
// (då det förutsätts vid bland annat gMessageParams)
beforeEachTest: BeforeEach 
    run() { 
        mainOutputStream.capturedOutputBuffer = new StringBuffer();
        gAction = Examine.createInstance();
    }
;

lab: Room 'testlabbet' "...";

spelare1aPerspektiv: Actor 'jag' @lab
  person = 1
  proper = true
  isHim = true
;

spelare2aPerspektiv: Actor 'du' @lab
  person = 2
  isProper = true
  isHim = true
;

spelare3ePerspektiv: Actor 'Bob;fyrkant;;honom' @lab
  person = 3
  isProper = true
  isHim = true
;

haretOBjNeutrumSingular: Thing 'hår+et'
  ownerNamed = true
  owner = [spelare1aPerspektiv, spelare2aPerspektiv, spelare3ePerspektiv]
;

nasanObjUtrumSingular: Thing 'näsa+n'
  ownerNamed = true
  isNeuter = nil
  //owner = [spelare1aPerspektiv, spelare2aPerspektiv, spelare3ePerspektiv]
  owner = [spelare2aPerspektiv]
;

ogonenObjNeutrumPlural: Thing 'ögon+en;;;dem' // dem sätter plural = true
  ownerNamed = true
  owner = [spelare1aPerspektiv, spelare2aPerspektiv, spelare3ePerspektiv]
;

bobsOgonObjNeutrumPlural: Thing 'ögon+en;;;dem'
  ownerNamed = true
  owner = [spelare3ePerspektiv]
;
    


/*

musketorer: Actor 'musketörer+na'
  pcReferralPerson = ThirdPerson
  isProper = nil
  isHim = true
  isPlural = true
;
*/
appletObjNeutrumSingular: Thing 'äpple+t;rö:tt+da;;det';
jordgubbeObjUtrumSingular: Thing 'jordgubbe+n;;en';
vindruvorObjNeutrumPlural: Thing 'vindruvor+na[pl];;;dem';

vinet: Thing 'vin+et';
lasken: Thing 'läsk+en';
dropparna: Thing 'droppar+na[pl];;;dem';

korgen: Container 'korg+en';
hyllan: Surface 'hylla+n'; 
karlet: Surface 'kärl+et'; 
garderoben: OpenableContainer 'garderob+en';

dorrenObjUtrumSingular: Thing 'dörr+en';
skapetObjNeutrumSingular: OpenableContainer 'skåp+et';
dorrarObjUterPlural: Thing 'dörrar+na;;;dem';

nyckel: Key 'nyckel+n';
//nyckelring: Keyring 'nyckel|ring+en';
svardet: Thing 'svärd+et';

hatten: Wearable 'hatt+en';
skarpet: Wearable 'skärp+et';
skorna: Wearable 'skor+na;;;dem';


bergsvaggen: Fixture 'bergs|vägg+en';
taket: Fixture 'tak+et';
stuprannorna: Fixture 'stuprännor+na;;;dem';

sandstranden: Floor 'sand|strand+en';
tragolvet: Floor 'trä|golv+et';
stenarna: Floor 'stenar+na;;;dem';

/*
bokenObjUtrumSingular: Thing 'bok+en';
papperetObjNeutrumSingular: Thing 'papper+et';
skyltarObjUtrumPlural: Thing 'skyltar+na;;;dem';


+snickargladje: Component 'snickargläde+n';

skapenObjNeuterPlural: Thing 'skåp+en;;;dem';

tandsticka: Thing 'tändsticka+n';
ljuset: Thing 'stearinljus+et';

prassel: SimpleNoise 'prassel/prasslet/prasslande+t' 'prassel' 
  theName = 'prasslet'
  
  //isProper = true
;


sopor: SimpleOdor 'sopa*sopor' 'sopor' isPlural = true isQualifiedName = true;

lukten: SimpleOdor 'lukt+en' 'lukt';

roret: Container 'rör+et' 'rör' ;

stegen: Thing 'stege+n' 'stege';
vaggen: DefaultWall 'vägg+en' 'väggen';

hobbit: Actor 'hobbit+en' 'hobbit' isHim = true isProper = nil;
baren: Room 'baren' 'baren'   theName = 'baren'
  east = valvgangPathPassage
  south = passageThroughPassage
;
apan: Actor 'apa+n' 'apa';

+ krogare: Actor 'krögare+n' 'krögare' isHim = true isProper = nil;
+ bankraden: Chair 'bänkrad+en' 'bänkrad';
++ sjorovare: Actor 'sjörrövare+n' 'sjörövare' 
  isHim = true 
  isProper = nil
  posture = sitting
;
++ viking: Actor 'viking+en' 'sjörövare' 
  isHim = true 
  isProper = nil
  posture = sitting
;

+ passageThroughPassage: ThroughPassage 'passage+n' 'passage' theName = 'passagen';
+ trappan: StairwayUp 'trappa+n' 'trappa' theName = 'trappan';
+ kallartrappan: StairwayDown 'trappa+n' 'trappa' theName = 'källartrappan';
fylke: OutdoorRoom 'Fylke' 'Fylke';
hallen: Room 'hallen' 'hallen'
  west = valvgangPathPassage
;

+ valvgangPathPassage: PathPassage 'valvgång+en' 'valvgång' theName = 'valvgången';
masten: OutdoorRoom 'masten' 'masten';
+pirat: Actor 'pirat+en' 'pirat';
+matros: Actor 'matros+en' 'matros';

kajen: OutdoorRoom 'kajen' 'kajen';

musikenObjUtrumSingular: Thing 'musik+en' 'musik';
matosetObjUtrumSingular: Thing 'matos+et' 'matos';

tingest: Thing 'tingest+en' 'tingest';
sak: Thing 'sak+en' 'sak';
*/

vagnen: Decoration 'vagn+en';
taltet: Decoration 'tält+et';
poolerna: Decoration 'pooler+na;;;dem';

/*
stolen: Platform: 'stol+en';
piano: Platform: 'piano+t';
soffor: Platform: 'soffor+na;;;dem';
*/











// Test Assertions
TestUnit 'openMsg - utrum singular' run {
  assertThat(Action.failCheckMsg)
    .isEqualTo('Du kunde inte göra det (men författaren till detta spel misslyckades med att specificera varför).');
};


// Test Assertions
TestUnit 'announceBestChoice - Examine neutrum DirectObject' run {
  [
      [appletObjNeutrumSingular, DirectObject, Examine] -> '(äpplet)'
    , [jordgubbeObjUtrumSingular, DirectObject, Take]   -> '(jordgubben)'
    //TODO: the rest

    //[appletObjNeutrumSingular, IndirectObject, Examine] -> '(äpplet)'
    //AccessoryObject
  ].forEachAssoc(function(params, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local obj = params[1];
    local role = params[2];
    local action = params[3];
    announceBestChoice(action, obj, role);
    //tadsSay('(<<obj.theName>>) VS: <<expected>>\n');
    assertThat(o.trimWS()).isEqualTo(expected);
  });
};


// Test Assertions
TestUnit 'Thing.darkDesc' run {
  [
      appletObjNeutrumSingular -> 'Det var kolsvart; du kunde inte se något alls'
    , jordgubbeObjUtrumSingular   -> 'Det var kolsvart; du kunde inte se något alls'
  ].forEachAssoc(function(obj, expected) {
    gDobj = obj;
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    obj.darkDesc();
    assertThat(o.trimWS()).startsWith(expected);
  });
}
;

// Test Assertions
TestUnit 'notImportantMsg' run {
  [ 
      appletObjNeutrumSingular    ->'Äpplet var inte viktigt.'
    , jordgubbeObjUtrumSingular   ->'Jordgubben var inte viktig.'
    , vindruvorObjNeutrumPlural   ->'Vindruvorna var inte viktiga.'

  ].forEachAssoc(function(obj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    gCommand = new Command(spelare1aPerspektiv, Examine, obj);
    gAction.curObj = obj; // Sätter "cobj" i notImportantMsg
    say(obj.notImportantMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'tooDarkToSeeMsg' run {
  [ 
      appletObjNeutrumSingular    ->'Det var för mörkt för att se något.'
    , jordgubbeObjUtrumSingular   ->'Det var för mörkt för att se något.'
    , vindruvorObjNeutrumPlural   ->'Det var för mörkt för att se något.'

  ].forEachAssoc(function(obj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    gCommand = new Command(Examine, obj);
    //gAction.curObj = obj;     
    say(obj.tooDarkToSeeMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotSmellMsg' run {
  [ 
      appletObjNeutrumSingular    ->'Du kunde inte lukta på äpplet.'
    , jordgubbeObjUtrumSingular   ->'Du kunde inte lukta på jordgubben.'
    , vindruvorObjNeutrumPlural   ->'Du kunde inte lukta på vindruvorna.'

  ].forEachAssoc(function(obj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    gCommand = new Command(Examine, obj);
    //gAction.curObj = obj;     
    say(obj.cannotSmellMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};


TestUnit 'smellNothingMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kände ingen ovanlig lukt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kände ingen ovanlig lukt.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kände ingen ovanlig lukt.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    // new Command(actor, action, dobjs...) - create from
    gCommand = new Command(actor, Examine, obj);    
    say(obj.smellNothingMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};


TestUnit 'hearNothingMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag hörde inget ovanligt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du hörde inget ovanligt.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob hörde inget ovanligt.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    // new Command(actor, action, dobjs...) - create from
    gCommand = new Command(actor, Examine, obj);    
    say(obj.hearNothingMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};










//TODO: Thing.messages


TestUnit 'cannotTasteMsg' run {
  [ 
      appletObjNeutrumSingular    -> 'Äpplet var inte lämpligt att smaka på.'
    , jordgubbeObjUtrumSingular   -> 'Jordgubben var inte lämplig att smaka på.'
    , vindruvorObjNeutrumPlural   -> 'Vindruvorna var inte lämpliga att smaka på.'

  ].forEachAssoc(function(obj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    gCommand = new Command(Examine, obj);    
    say(obj.cannotTasteMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotFeelMsg' run {
  [ 
      appletObjNeutrumSingular    ->'Det var knappast en bra idé att försöka känna på äpplet.'
    , jordgubbeObjUtrumSingular   ->'Det var knappast en bra idé att försöka känna på jordgubben.'
    , vindruvorObjNeutrumPlural   ->'Det var knappast en bra idé att försöka känna på vindruvorna.'

  ].forEachAssoc(function(obj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    gCommand = new Command(Examine, obj);    
    say(obj.cannotFeelMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};


TestUnit 'cannotTakeMsg' run {
  [ 
      appletObjNeutrumSingular    ->'Äpplet satt fast på plats.'
    , jordgubbeObjUtrumSingular   ->'Jordgubben satt fast på plats.'
    , vindruvorObjNeutrumPlural   ->'Vindruvorna satt fast på plats.'
  ].forEachAssoc(function(obj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    gCommand = new Command(Examine, obj);    
    say(obj.cannotTakeMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'alreadyHeldMsg' run {
  [ 
    // TODO: ok mening?
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag höll i äpplet redan'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du höll i jordgubben redan'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob höll i vindruvorna redan'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.alreadyHeldMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotTakeMyContainerMsg' 
  run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte ta äpplet medan jag befann mig på det.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte ta jordgubben medan du befann dig på den.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte ta vindruvorna medan Bob befann sig på dem.'
    
    // TODO: Fixa så att det blir: 
    // Bob kunde inte ta vindruvorna medan han befann sig på dem.
    // se över ifPronoun/heName

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotTakeMyContainerMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  }); 
};

TestUnit 'cannotTakeSelfMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde knappast ta mig själv.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde knappast ta dig själv.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde knappast ta sig själv.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotTakeSelfMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotDropMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte släppa äpplet.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte släppa jordgubben.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte släppa vindruvorna'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotDropMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'notHoldingMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag höll inte i äpplet.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du höll inte i jordgubben.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob höll inte i vindruvorna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.notHoldingMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    


// TODO: Viktig lärdom: nominalOwner kommer bli den första owner om owner var en lista med flera objekt
// se över det.

TestUnit 'partOfYouMsg' run {
  [ 
      [spelare1aPerspektiv, haretOBjNeutrumSingular]    -> 'Mitt hår var en del av mig.'    
    , [spelare2aPerspektiv, nasanObjUtrumSingular]      -> 'Din näsa var en del av dig.' 
    
    // TODO: expanderas ej: 
    // [{Ref subj dobj} var en del av Bob.  ]
    // TODO: blir: Deras ögon var en del av Bob. 
    // , [spelare3ePerspektiv, bobsOgonObjNeutrumPlural]     -> 'Bobs ögon var en del av Bob'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2]; 
    gCommand = new Command(actor, Examine, obj);    
    gAction.curDobj = obj; // Sätter "cobj" 
    
    say(obj.partOfYouMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotReadMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Det fanns inget att läsa på äpplet.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Det fanns inget att läsa på jordgubben.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Det fanns inget att läsa på vindruvorna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotReadMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

// cannotFollowMsg = BMsg(cannot follow, '{The subj dobj} {isn\'t} going anywhere. ')
//                    Msg(cannot follow, '{Ref subj dobj} {går} ingenstans. '),

TestUnit 'cannotFollowMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet gick ingenstans.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben gick ingenstans.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna gick ingenstans.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotFollowMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    


    
// cannotFollowSelfMsg = BMsg(cannot follow self, '{I} {can\'t} follow {myself}. ')
 //                      Msg(cannot follow self, '{Jag} {kan} inte följa {mig} själv. '),
TestUnit 'cannotFollowSelfMsg' run {
  [ 
    // TODO: fixa mig själv när obj=subj rent allmänt
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte följa mig själv' 
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte följa dig själv'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte följa sig själv'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotFollowSelfMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotAttackMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Bäst att undvika meningslöst våld'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Bäst att undvika meningslöst våld'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bäst att undvika meningslöst våld'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotAttackMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};

// futileToAttackMsg = BMsg(futile attack, 'Attacking {1} prove{s/d} futile. ',  gActionListStr)
//                     Msg(futile attack, 'Att attackera {1} {visar} sig vara meningslöst. '),

TestUnit 'futileToAttackMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Att attackera äpplet visade sig vara meningslöst.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Att attackera jordgubben visade sig vara meningslöst.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Att attackera vindruvorna visade sig vara meningslöst.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Attack, obj);    
    gCommand.action.reportList = [obj];
    say(obj.futileToAttackMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

//Msg(cannot attack with self, '{Jag} {kan} inte attackera något med {mig} själv. '),    
TestUnit 'cannotAttackWithSelfMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte attackera något med mig själv.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte attackera något med dig själv.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte attackera något med sig själv.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotAttackWithSelfMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  }); 
};   

// TODO: 'det' eller 'detta' eller 'det här'
//Msg(cannot attack with, '{Jag} {kan} inte attackera någonting alls med {detta iobj}. '),
TestUnit 'cannotAttackWithMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte attackera någonting alls med detta.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte attackera någonting alls med denna.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte attackera någonting alls med dessa.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotAttackWithMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

// TODO: fixa mening:
// Msg(cannot break, '{Ref subj dobj} {är} inte något {jag} {kan} ta sönder. '),
TestUnit 'cannotBreakMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet var inte något jag kunde ta sönder.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben var inte något du kunde ta sönder.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna var inte något Bob kunde ta sönder.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotBreakMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

// Msg(dont break, '{Jag} {ser} ingen mening med att ta sönder {detta dobj}. '),
TestUnit 'shouldNotBreakMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag såg ingen mening med att ta sönder detta'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du såg ingen mening med att ta sönder denna'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob såg ingen mening med att ta sönder dessa'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.shouldNotBreakMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

// Msg(cannot throw, '{Jag} {kan} inte kasta {ref dobj} någonstans. '),
TestUnit 'cannotThrowMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte kasta äpplet någonstans.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte kasta jordgubben någonstans.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte kasta vindruvorna någonstans.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotThrowMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

// Msg(cannot open, '{Ref subj dobj} {är} inte något {jag} {kan} öppna. '),
TestUnit 'cannotOpenMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet var inte något jag kunde öppna'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben var inte något du kunde öppna'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna var inte något Bob kunde öppna'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotOpenMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

// Msg(already open, '{Ref subj dobj} {är} redan öpp{en/et/na}. '),
TestUnit 'alreadyOpenMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet var redan öppet.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben var redan öppen.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna var redan öppna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.alreadyOpenMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'lockedMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet var låst.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben var låst.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna var låsta.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.lockedMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotCloseMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet var inte något som kunde stängas.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben var inte något som kunde stängas.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna var inte något som kunde stängas.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotCloseMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'alreadyClosedMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet var inte öppet.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben var inte öppen.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna var inte öppna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.alreadyClosedMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotTurnMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet kunde inte vridas.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben kunde inte vridas.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna kunde inte vridas'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotTurnMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

//turnNoEffectMsg = BMsg(turn useless, 'Turning {1} {dummy} achieve{s/d} nothing. ', gActionListStr)
//                   Msg(turn useless, 'Att vrida på {1} {dummy} {gör} ingen nytta. '),
TestUnit 'turnNoEffectMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Att vrida på äpplet gjorde ingen nytta.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Att vrida på jordgubben gjorde ingen nytta.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Att vrida på vindruvorna gjorde ingen nytta.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    gCommand.action.reportList = [obj];
    say(obj.turnNoEffectMsg);    
    local result = o.trimWS().findReplace('  ', ' ', ReplaceAll);
    assertThat(result).startsWith(expected);
  });
};    

//Msg(cannot turn with, '{Jag} {kan} inte vrida någonting med {detta iobj}. '),
TestUnit 'cannotTurnWithMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte vrida någonting med detta'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte vrida någonting med denna'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte vrida någonting med dessa'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotTurnWithMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

// Msg(turn self, '{Jag} {kan} inte vrida någonting med {sig} själv. '),
TestUnit 'cannotTurnWithSelfMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte vrida någonting med mig själv.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte vrida någonting med dig själv.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte vrida någonting med sig själv.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotTurnWithSelfMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotCutMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte skära äpplet.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte skära jordgubben.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte skära vindruvorna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotCutMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotCutWithMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte skära något med detta.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte skära något med denna.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte skära något med dessa.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotCutWithMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotCutWithSelfMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte skära något med mig själv.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte skära något med dig själv.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte skära något med sig själv.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotCutWithSelfMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'lookInMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag såg inget intressant i äpplet.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du såg inget intressant i jordgubben.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob såg inget intressant i vindruvorna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.lookInMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotLookUnderMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte titta under detta.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte titta under denna.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte titta under dessa.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotLookUnderMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

//Msg(look under, '{Jag} hitta{r|de} inget av intresse under {ref dobj}. '),
TestUnit 'lookUnderMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag hittade inget av intresse under äpplet.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du hittade inget av intresse under jordgubben.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob hittade inget av intresse under vindruvorna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.lookUnderMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    


//Msg(cannot look behind, '{Jag} {kan} inte titta bakom {detta dobj}. '),
TestUnit 'cannotLookBehindMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte titta bakom detta.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte titta bakom denna.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte titta bakom dessa.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotLookBehindMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

//lookBehindMsg = BMsg(look behind, '{I} {find} nothing of interest behind {the dobj}. ')
//                 Msg(look behind, '{Jag} hitta{r|de} inget intressant bakom {ref dobj}. '),
TestUnit 'lookBehindMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag hittade inget intressant bakom äpplet.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du hittade inget intressant bakom jordgubben.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob hittade inget intressant bakom vindruvorna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.lookBehindMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};



//Msg(cannot look through, '{Jag} {kan} inte titta genom {detta dobj}. '),
TestUnit 'cannotLookThroughMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte titta genom detta.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte titta genom denna.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte titta genom dessa.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotLookThroughMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

//Msg(look through, '{Jag} {ser} inget genom {ref dobj}. '),
TestUnit 'lookThroughMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag såg inget genom äpplet.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du såg inget genom jordgubben.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob såg inget genom vindruvorna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.lookThroughMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotGoThroughMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte gå genom detta.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte gå genom denna.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte gå genom dessa.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotGoThroughMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

// TODO: BUG i adv3lite, msg pekar på samma id: 'cannot go through', borde vara 'cannot go along'
TestUnit 'cannotGoAlongMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte gå genom detta.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte gå genom denna.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte gå genom dessa.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotGoAlongMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotPushMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Det fanns ingen mening med att försöka trycka på detta.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Det fanns ingen mening med att försöka trycka på denna.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Det fanns ingen mening med att försöka trycka på dessa.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotPushMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'pushNoEffectMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Att trycka på äpplet hade ingen effekt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Att trycka på jordgubben hade ingen effekt.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Att trycka på vindruvorna hade ingen effekt.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    gCommand.action.reportList = [obj];
    say(obj.pushNoEffectMsg);    

    local str = o.trimWS().findReplace('  ', ' ', ReplaceAll);
    assertThat(str).startsWith(expected);
  });
};    

//cannotPullMsg = BMsg(cannot pull, 'There{\'s} no point trying to pull {that dobj}. ')
TestUnit 'cannotPullMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Det fanns ingen mening med att försöka dra detta.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Det fanns ingen mening med att försöka dra denna.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Det fanns ingen mening med att försöka dra dessa.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotPullMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'pullNoEffectMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Att dra äpplet hade ingen effekt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Att dra jordgubben hade ingen effekt.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Att dra vindruvorna hade ingen effekt.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    gCommand.action.reportList = [obj];
    say(obj.pullNoEffectMsg);    
    local str = o.trimWS().findReplace('  ', ' ', ReplaceAll);
    assertThat(str).startsWith(expected);
  });
};    

//alreadyInMsg = BMsg(already in, '{The subj dobj} {is} already {1}. ', gVerifyIobj.objInName)
//                Msg(already in, '{Ref subj dobj} {är} redan {i iobj}. ')
TestUnit 'alreadyInMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet var redan i korgen.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben var redan i korgen.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna var redan i korgen.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();  
    //mainOutputStream.hideOutput = nil;  
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj, korgen);
    gIobj = korgen;
    //gCommand.iobjs = [korgen];
    //gCommand.action.reportList = [obj, korgen];
    say(obj.alreadyInMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

// circularlyInMsg = BMsg(circularly in, '{I} {can\'t} put {the dobj} {1}
//     while {the subj iobj} {is} {in dobj}. ', gVerifyIobj.objInName)
TestUnit 'circularlyInMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte lägga äpplet i korgen medan korgen var på äpplet.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte lägga jordgubben i korgen medan korgen var på jordgubben.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte lägga vindruvorna i korgen medan korgen var på vindruvorna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    //mainOutputStream.hideOutput = nil;
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj, korgen);    
    gIobj = korgen;

    say(obj.circularlyInMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

//cannotPutInSelfMsg = BMsg(cannot put in self, '{I} {can\'t} put {the dobj} {1} {itself dobj}. ', gIobj.objInPrep)
//Msg(cannot put in self, '{Jag} {kan} inte lägga {ref dobj} {1} {själv dobj}. '),
TestUnit 'cannotPutInSelfMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte lägga äpplet på sig självt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte lägga jordgubben på sig själv.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte lägga vindruvorna på sig själva.'
  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    //mainOutputStream.hideOutput = nil;
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, PutIn, obj, obj);    

    gIobj = obj;

    say(obj.cannotPutInSelfMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
}
;    

TestUnit 'cannotPutOnMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte lägga något på hyllan.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte lägga något på hyllan.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte lägga något på hyllan.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj, hyllan);    
    say(obj.cannotPutOnMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotPutInMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte lägga något i korgen.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte lägga något i korgen.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte lägga något i korgen.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj, korgen);    
    say(obj.cannotPutInMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotPutUnderMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte lägga något under korgen'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte lägga något under korgen'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte lägga något under korgen'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj, korgen);    
    say(obj.cannotPutUnderMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotPutBehindMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte lägga något bakom garderoben'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte lägga något bakom garderoben'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte lägga något bakom garderoben'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj, garderoben);    
    say(obj.cannotPutBehindMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'notLockableMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet var inte låsbart.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben var inte låsbar.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna var inte låsbara.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.notLockableMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'keyNotNeededMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag behöver inte en nyckel för att låsa och låsa upp äpplet'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du behöver inte en nyckel för att låsa och låsa upp jordgubben'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob behöver inte en nyckel för att låsa och låsa upp vindruvorna'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.keyNotNeededMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'indirectLockableMsg' run {
  [ 
    // TODO: testa om versal behövs i början
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'äpplet verkar använda någon annan typ av låsmekanism.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'jordgubben verkar använda någon annan typ av låsmekanism.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'vindruvorna verkar använda någon annan typ av låsmekanism.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.indirectLockableMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'notLockedMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet var inte låst.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben var inte låst.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna var inte låsta.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.notLockedMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotUnlockWithMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte låsa upp något med detta.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte låsa upp något med denna.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte låsa upp något med dessa.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];

    gCommand = new Command(actor, Unlock, obj, garderoben);    
    say(obj.cannotUnlockWithMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotUnlockWithSelfMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte låsa upp något med sig självt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte låsa upp något med sig själv.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte låsa upp något med sig själva.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gIobj = obj;
    gDobj = obj;
    gCommand = new Command(actor, UnlockWith, obj, obj);    
    say(obj.cannotUnlockWithSelfMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  }); 
};

TestUnit 'alreadyLockedMsg' run {
  [ 
      [spelare1aPerspektiv, skapetObjNeutrumSingular]    ->'Skåpet var redan låst.'
    , [spelare2aPerspektiv, dorrenObjUtrumSingular]      ->'Dörren var redan låst.'
    , [spelare3ePerspektiv, dorrarObjUterPlural]         ->'Dörrarna var redan låsta.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.alreadyLockedMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotLockWithMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte låsa något med detta.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte låsa något med denna.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte låsa något med dessa.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotLockWithMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotLockWithSelfMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte låsa något med sig självt'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte låsa något med sig själv'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte låsa något med sig själva'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotLockWithSelfMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

//withKeyMsg = BMsg(with key, '<.assume>with {1}<./assume>\n', useKey_.theName)
TestUnit 'withKeyMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'(med äpplet)'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'(med jordgubben)'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'(med vindruvorna)'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    //local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    obj.useKey_ = obj;
    say(obj.withKeyMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

//keyDoesntWorkMsg = BMsg(key doesnt work, 'Unfortunately {1} {dummy} {doesn\'t work[ed]} on {the dobj}. ', useKey_.theName)

TestUnit 'keyDoesntWorkMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Tyvärr fungerar inte äpplet på garderoben.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Tyvärr fungerar inte jordgubben på garderoben.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Tyvärr fungerar inte vindruvorna på garderoben.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, UnlockWith, garderoben);
    garderoben.useKey_ = obj;
    say(garderoben.keyDoesntWorkMsg);
    local result = o.trimWS().findReplace('  ', ' ', ReplaceAll);
    assertThat(result).startsWith(expected);
  });
};    

//notSwitchableMsg = BMsg(not switchable, '{The subj dobj} {can\'t} be switched on and off. ')
TestUnit 'notSwitchableMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet kunde inte slås på och av.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben kunde inte slås på och av.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna kunde inte slås på och av.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.notSwitchableMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

//alreadyOnMsg = BMsg(already switched on, '{The subj dobj} {is} already switched on. ')
TestUnit 'alreadyOnMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet var redan påslaget.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben var redan påslagen.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna var redan påslagna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.alreadyOnMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'alreadyOffMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet var inte påslaget.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben var inte påslagen.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna var inte påslagna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.alreadyOffMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotFlipMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte använda äpplet.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte använda jordgubben.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte använda vindruvorna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotFlipMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotBurnMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte bränna äpplet.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte bränna jordgubben.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte bränna vindruvorna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotBurnMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

// cannotBurnWithMsg = BMsg(cannot burn with, '{I} {can\'t} burn {the dobj} with {that iobj}. ')
TestUnit 'cannotBurnWithMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte bränna äpplet med detta.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte bränna jordgubben med denna.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte bränna vindruvorna med dessa.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    //mainOutputStream.hideOutput = nil;
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj, obj);
    say(obj.cannotBurnWithMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotWearMsg' run {
  [ 
      [spelare1aPerspektiv, skarpet]  ->'Skärpet gick inte att bära.'
    , [spelare2aPerspektiv, hatten]   ->'Hatten gick inte att bära.'
    , [spelare3ePerspektiv, skorna]   ->'Skorna gick inte att bära.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotWearMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'alreadyWornMsg' run {
  [ 
      [spelare1aPerspektiv, skarpet]  ->'Jag hade redan på mig skärpet.'
    , [spelare2aPerspektiv, hatten]   ->'Du hade redan på dig hatten'
    , [spelare3ePerspektiv, skorna]   ->'Bob hade redan på sig skorna'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.alreadyWornMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'notWornMsg' run {
  [ 
      [spelare1aPerspektiv, skarpet]  ->'Jag hade inte på mig skärpet.'
    , [spelare2aPerspektiv, hatten]   ->'Du hade inte på dig hatten'
    , [spelare3ePerspektiv, skorna]   ->'Bob hade inte på sig skorna'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.notWornMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

// cannotClimbMsg = BMsg(cannot climb,'{The subj dobj} {is} not something {i} {can} climb. ')
TestUnit 'cannotClimbMsg' run {
  [ 
      [spelare1aPerspektiv, bergsvaggen]    ->'Bergsväggen var inte något som jag kunde klättra på.'
    , [spelare2aPerspektiv, taket]          ->'Taket var inte något som du kunde klättra på.'
    , [spelare3ePerspektiv, stuprannorna]   ->'Stuprännorna var inte något som Bob kunde klättra på.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotClimbMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotClimbDownMsg' run {
  [ 
      [spelare1aPerspektiv, bergsvaggen]    ->'Bergsväggen var inte något som jag kunde klättra ner för.'
    , [spelare2aPerspektiv, taket]          ->'Taket var inte något som du kunde klättra ner för.'
    , [spelare3ePerspektiv, stuprannorna]   ->'Stuprännorna var inte något som Bob kunde klättra ner för.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotClimbDownMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotBoardMsg' run {
  [ 
      [spelare1aPerspektiv, tragolvet]    ->'Trägolvet var inte något jag kunde gå på.'
    , [spelare2aPerspektiv, sandstranden]   ->'Sandstranden var inte något du kunde gå på.'
    , [spelare3ePerspektiv, stenarna]   ->'Stenarna var inte något Bob kunde gå på.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotBoardMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotBoardSelfMsg' run {
  [ 
      spelare1aPerspektiv     ->'Jag kunde knappast borda mig själv.'
    , spelare2aPerspektiv    ->'Du kunde knappast borda dig själv.'
    , spelare3ePerspektiv    ->'Bob kunde knappast borda sig själv.'

  ].forEachAssoc(function(actor, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    gCommand = new Command(actor, Examine, actor);    
    say(actor.cannotBoardSelfMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

// actorAlreadyOnMsg = BMsg(already on, '{I}{\'m} already {in dobj}. ')

TestUnit 'actorAlreadyOnMsg' run {
  [ 
      [spelare1aPerspektiv, tragolvet]      ->'Jag var redan på trägolvet.'
    , [spelare2aPerspektiv, sandstranden]   ->'Du var redan på sandstranden.'
    , [spelare3ePerspektiv, stenarna]       ->'Bob var redan på stenarna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.actorAlreadyOnMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotGetOnCarriedMsg' run {
  [ 
      [spelare1aPerspektiv, tragolvet, appletObjNeutrumSingular]
            ->'Jag kunde inte gå på trägolvet medan jag bär det.'
    , [spelare2aPerspektiv, sandstranden, jordgubbeObjUtrumSingular]
           ->'Du kunde inte gå på sandstranden medan du bär den.'
    , [spelare3ePerspektiv, stenarna, vindruvorObjNeutrumPlural]
           ->'Bob kunde inte gå på stenarna medan Bob bär dem.'

  ].forEachAssoc(function(actorAndObjAndIobj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObjAndIobj[1];
    local obj = actorAndObjAndIobj[2];
    local iobj = actorAndObjAndIobj[2];
    gCommand = new Command(actor, Travel, obj, iobj);    
    say(obj.cannotGetOnCarriedMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotStandOnMsg' run {
  [ 
      [spelare1aPerspektiv, tragolvet]      ->'Trägolvet var inte något jag kunde stå på.'
    , [spelare2aPerspektiv, sandstranden]   ->'Sandstranden var inte något du kunde stå på.'
    , [spelare3ePerspektiv, stenarna]       ->'Stenarna var inte något Bob kunde stå på.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotStandOnMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotSitOnMsg' run {
  [ 
      [spelare1aPerspektiv, tragolvet]      ->'Trägolvet var inte något jag kunde sitta på.'
    , [spelare2aPerspektiv, sandstranden]   ->'Sandstranden var inte något du kunde sitta på.'
    , [spelare3ePerspektiv, stenarna]       ->'Stenarna var inte något Bob kunde sitta på.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotSitOnMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotLieOnMsg' run {
  [ 
      [spelare1aPerspektiv, tragolvet]      ->'Trägolvet var inte något jag kunde ligga på.'
    , [spelare2aPerspektiv, sandstranden]   ->'Sandstranden var inte något du kunde ligga på.'
    , [spelare3ePerspektiv, stenarna]       ->'Stenarna var inte något Bob kunde ligga på.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotLieOnMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotEnterMsg' run {
  [ 
      [spelare1aPerspektiv, vagnen]     ->'Vagnen var inte något jag kunde gå in i.'
    , [spelare2aPerspektiv, taltet]     ->'Tältet var inte något du kunde gå in i.'
    , [spelare3ePerspektiv, poolerna]   ->'Poolerna var inte något Bob kunde gå in i.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotEnterMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

//actorAlreadyInMsg = BMsg(actor already in, '{I}{\'m} already {in dobj}. ')
TestUnit 'actorAlreadyInMsg' run {
  [ 
      [spelare1aPerspektiv, tragolvet]      ->'Jag var redan på trägolvet.'
    , [spelare2aPerspektiv, sandstranden]   ->'Du var redan på sandstranden.'
    , [spelare3ePerspektiv, stenarna]       ->'Bob var redan på stenarna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.actorAlreadyInMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

// TODO: Nästa
// TODO: bör kanske hellre vara normalform än objektform på sista?
// TODO: På Bob bör det vara 'han' i nästa läge. OBS! Så Även på andra tester...
// cannotGetInCarriedMsg = BMsg(cannot enter carried, '{I} {can\'t} get in {the dobj} while {i}{\'m} carrying {him dobj}. ')
// Msg(cannot enter carried, '{Jag} {kan} inte gå in i {ref dobj} medan {han} bär {honom dobj}. '),
TestUnit 'cannotGetInCarriedMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte gå in i äpplet medan jag bär på det.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte gå in i jordgubben medan du bär på den.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte gå in i vindruvorna medan Bob bär på dem.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Enter, obj, obj);    
    say(obj.cannotGetInCarriedMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'okayGetOutOfMsg' run {
  [ 
      [spelare1aPerspektiv, vagnen]     ->'Okej, jag gick ut ur vagnen.'
    , [spelare2aPerspektiv, taltet]     ->'Okej, du gick ut ur tältet.'
    , [spelare3ePerspektiv, poolerna]   ->'Okej, Bob gick ut ur poolerna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.okayGetOutOfMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'actorNotInMsg' run {
  [ 
      [spelare1aPerspektiv, vagnen]     ->'Jag var inte i vagnen.'
    , [spelare2aPerspektiv, taltet]     ->'Du var inte i tältet.'
    , [spelare3ePerspektiv, poolerna]   ->'Bob var inte i poolerna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.actorNotInMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'actorNotOnMsg' run {
  [ 
      [spelare1aPerspektiv, vagnen]     ->'Jag var inte på vagnen.'
    , [spelare2aPerspektiv, taltet]     ->'Du var inte på tältet.'
    , [spelare3ePerspektiv, poolerna]   ->'Bob var inte på poolerna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.actorNotOnMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    


// cannotRemoveMsg = BMsg(cannot remove, '{The subj dobj} {cannot} be removed.')

TestUnit 'cannotRemoveMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet kunde inte tas bort.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben kunde inte tas bort.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna kunde inte tas bort.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Remove, obj);    
    say(obj.cannotRemoveMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};

// TODO: snygga till. se hur adv3 löste "pronomen/objekt"
// cannotMoveMsg = BMsg(cannot move, '{The subj dobj} {won\'t} budge. ')  
//                  Msg(cannot move, '{Ref subj dobj} {rör} {pronomen/objekt dobj} inte. ') 

TestUnit 'cannotMoveMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet rörde sig inte.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben rörde sig inte.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna rörde sig inte.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();  
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Move, obj);
    say(obj.cannotMoveMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};


// TODO: fixa sen
// moveNoEffectMsg = BMsg(move no effect, 'Moving {1} {dummy} {has} no effect. ', gActionListStr)

/*
TestUnit 'moveNoEffectMsg' run {
  //tadsSay('TODO: fixa');
  [ 
      appletObjNeutrumSingular    ->'Det ger ingenting att flytta på2 äpplet.'
    , jordgubbeObjUtrumSingular   ->'Det ger ingenting att flytta på jordgubben.'
    , vindruvorObjNeutrumPlural   ->'Det ger ingenting att flytta på vindruvorna.'

  ].forEachAssoc(function(obj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    gCommand = new Command(actor, Move, obj);
    gCommand.action.reportList = [obj];
    say(obj.moveNoEffectMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    
*/
// {Jag} {kan} inte flytta {ref dobj} med {ref iobj}. 
TestUnit 'cannotMoveWithMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular, korgen]    ->'Jag kunde inte flytta äpplet med korgen.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular, svardet]   ->'Du kunde inte flytta jordgubben med svärdet.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural, skorna]   ->'Bob kunde inte flytta vindruvorna med skorna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    //mainOutputStream.hideOutput = nil;

    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    local iobj = actorAndObj[3];
    gCommand = new Command(actor, MoveWith, obj, iobj);    
    say(obj.cannotMoveWithMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
}
;    

TestUnit 'cannotMoveWithSelfMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet kunde inte användas för att flytta sig självt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben kunde inte användas för att flytta sig själv.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna kunde inte användas för att flytta sig själva.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotMoveWithSelfMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
}
 
;    

TestUnit 'cannotMoveToMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular, sandstranden]    ->'Äpplet kunde inte flyttas till sandstranden'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular, tragolvet]   ->'Jordgubben kunde inte flyttas till trägolvet'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural, stenarna]   ->'Vindruvorna kunde inte flyttas till stenarna'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    local iobj = actorAndObj[3];
    gCommand = new Command(actor, Examine, obj, iobj);    
    say(obj.cannotMoveToMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotMoveToSelfMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet kunde inte flyttas till sig självt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben kunde inte flyttas till sig själv'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna kunde inte flyttas till sig själva'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotMoveToSelfMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'alreadyMovedToMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular, sandstranden]    ->'Äpplet hade redan flyttats till sandstranden.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular, tragolvet]   ->'Jordgubben hade redan flyttats till trägolvet.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural, stenarna]   ->'Vindruvorna hade redan flyttats till stenarna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    local iobj = actorAndObj[3];
    gCommand = new Command(actor, Examine, obj, iobj);    
    say(obj.alreadyMovedToMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};
    
TestUnit 'cantMoveAwayFromSelfMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte flytta bort äpplet från sig självt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte flytta bort jordgubben från sig själv.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte flytta bort vindruvorna från sig själva.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cantMoveAwayFromSelfMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  }); 
}

;

// notMovedToMsg = BMsg(not by obj, '{The subj dobj} {is}n\'t by {the iobj}. ')
TestUnit 'notMovedToMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular, sandstranden]    ->'Äpplet var inte vid sandstranden.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular, tragolvet]   ->'Jordgubben var inte vid trägolvet.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural, stenarna]   ->'Vindruvorna var inte vid stenarna.'
  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    //mainOutputStream.hideOutput = nil;  

    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    local iobj = actorAndObj[3];
    gCommand = new Command(actor, MoveAwayFrom, obj, iobj);    
    say(obj.notMovedToMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotLightMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet var inte något jag kunde tända.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben var inte något du kunde tända.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna var inte något Bob kunde tända.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotLightMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    


TestUnit 'alreadyLitMsg' run {
  [ 
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet var redan tänt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben var redan tänd.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna var redan tända.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.alreadyLitMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'notLitMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet var inte tänt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben var inte tänd.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna var inte tända.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.notLitMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotExtinguishMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet kunde inte släckas.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben kunde inte släckas.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna kunde inte släckas.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotExtinguishMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotEatMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet var uppenbarligen oätligt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben var uppenbarligen oätlig.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna var uppenbarligen oätliga.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotEatMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotDrinkMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte dricka äpplet.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte dricka jordgubben.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte dricka vindruvorna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotDrinkMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotCleanMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet var inte något jag kunde rengöra.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben var inte något du kunde rengöra.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna var inte något Bob kunde rengöra.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotCleanMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'alreadyCleanMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet var redan tillräckligt ren.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben var redan tillräckligt ren.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna var redan tillräckligt ren.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.alreadyCleanMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'noNeedToCleanMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet behöver inte rengöras.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben behöver inte rengöras.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna behöver inte rengöras.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.noNeedToCleanMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};
    
TestUnit 'dontNeedCleaningObjMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag behöver inte rengöra äpplet.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du behöver inte rengöra jordgubben.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob behöver inte rengöra vindruvorna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.dontNeedCleaningObjMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  }); 
};
// TODO: add third object
// BMsg(cannot clean with, '{I} {can\'t} clean {the dobj} with {the iobj}. ')
// Msg(cannot clean with, '{Jag} {kan} inte rengöra {ref dobj} med {ref iobj}. ')
TestUnit 'cannotCleanWithMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular, korgen]    ->'Jag kunde inte rengöra äpplet med korgen'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular, svardet]   ->'Du kunde inte rengöra jordgubben med svärdet'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural, skorna]   ->'Bob kunde inte rengöra vindruvorna med skorna'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    local iobj = actorAndObj[3];
    gCommand = new Command(actor, Examine, obj, iobj);    
    say(obj.cannotCleanWithMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotDigMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte gräva där.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte gräva där.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte gräva där.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotDigMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotDigWithMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte gräva något med detta.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte gräva något med denna.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte gräva något med dessa.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotDigWithMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotDigWithSelfMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte gräva äpplet med mig självt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte gräva jordgubben med dig själv.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte gräva vindruvorna med sig själva.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotDigWithSelfMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'notInMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet var inte'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben var inte'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna var inte'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.notInMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotThrowAtMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte kasta något på'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte kasta något på'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte kasta något på'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotThrowAtMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotThrowAtSelfMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet kunde inte kastas på mig självt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben kunde inte kastas på dig själv.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna kunde inte kastas på Bob själva.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotThrowAtSelfMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotThrowToMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet kunde inte fånga något.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben kunde inte fånga något.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna kunde inte fånga något.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotThrowToMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotThrowToSelfMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet kunde inte fånga mig självt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben kunde inte fånga dig själv.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna kunde inte fånga Bob själva.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotThrowToSelfMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'throwFallsShortMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet landar långt ifrån'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben landar långt ifrån'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna landar långt ifrån'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.throwFallsShortMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotTurnToMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte vrida detta till något.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte vrida denna till något.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte vrida dessa till något.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotTurnToMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

// TODO: mocka gActionListStr
// okaySetMsg = BMsg(okay set to, '{I} {set} {1} to {2}. ', gActionListStr, curSetting)
/*
TestUnit 'okaySetMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag ställde in äpplet till'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du ställde in jordgubben till'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob ställde in vindruvorna till'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);

    assertThat(obj.okaySetMsg.trimWS()).startsWith(expected);
  });
};
*/

TestUnit 'cannotSetToMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte ställa in detta till något.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte ställa in denna till något.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte ställa in dessa till något.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotSetToMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'alreadyThereMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag var redan där.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du var redan där.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob var redan där.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.alreadyThereMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'alreadyPresentMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet var redan här.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben var redan här.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna var redan här.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.alreadyPresentMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotAttachMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte fästa äpplet till något.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte fästa jordgubben till något.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte fästa vindruvorna till något.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotAttachMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotAttachToMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte fästa något till'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte fästa något till'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte fästa något till'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();    
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);    
    say(obj.cannotAttachToMsg);    
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotAttachToSelfMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte fästa'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte fästa'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte fästa'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotAttachToSelfMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotDetachMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Det fanns inget från vilket äpplet kunde lossas.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Det fanns inget från vilket jordgubben kunde lossas.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Det fanns inget från vilket vindruvorna kunde lossas.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotDetachMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

/*
  cannotDetachFromMsg = BMsg(cannot detach from, 'There{dummy} {is}n\'t
      anything that could be detached from {the iobj}. ')
    
  cannotDetachFromSelfMsg = BMsg(cannot detach from self, '{The subj dobj}
      {can\'t} be detached from {itself dobj}. ')

  Msg(cannot detach this, '{Ref subj dobj} {kan} inte lossas från {1}. '),
  Msg(cannot detach from this , 'The {subj dobj} {kan} inte lossas från {ref iobj}. '),
*/
TestUnit 'cannotDetachFromMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Det fanns inget som kunde lossas från äpplet'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Det fanns inget som kunde lossas från jordgubben'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Det fanns inget som kunde lossas från vindruvorna'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    local iobj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj, iobj);
    say(obj.cannotDetachFromMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotDetachFromSelfMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet kunde inte lossas från mig självt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben kunde inte lossas från dig själv.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna kunde inte lossas från Bob själva.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotDetachFromSelfMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotFastenMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet var inte något jag kunde fästa.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben var inte något du kunde fästa.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna var inte något Bob kunde fästa.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotFastenMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'alreadyFastenedMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet var redan fäst.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben var redan fäst.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna var redan fäst.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.alreadyFastenedMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotFastenToMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte fästa något till detta.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte fästa något till denna.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte fästa något till dessa.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotFastenToMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotFastenToSelfMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'{Ref subj iobj}'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'{Ref subj iobj}'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'{Ref subj iobj}'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotFastenToSelfMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotUnfastenMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet kunde inte lossas.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben kunde inte lossas.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna kunde inte lossas.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotUnfastenMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotUnfastenFromMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte lossa något från detta.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte lossa något från denna.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte lossa något från dessa.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotUnfastenFromMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'hearNothingMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag hörde inget ovanligt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du hörde inget ovanligt.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob hörde inget ovanligt.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.hearNothingMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'notFastenedMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet var inte fäst.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben var inte fäst.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna var inte fäst.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.notFastenedMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotPlugMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet kunde inte kopplas in i något.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben kunde inte kopplas in i något.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna kunde inte kopplas in i något.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotPlugMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotPlugIntoSelfMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte koppla in äpplet i mig självt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte koppla in jordgubben i dig själv.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte koppla in vindruvorna i sig själva.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotPlugIntoSelfMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotPlugIntoMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte koppla in något i'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte koppla in något i'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte koppla in något i'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotPlugIntoMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotUnplugMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet kunde inte kopplas ur.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben kunde inte kopplas ur.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna kunde inte kopplas ur.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotUnplugMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotUnplugFromSelfMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte koppla ur äpplet från mig självt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte koppla ur jordgubben från dig själv.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte koppla ur vindruvorna från sig själva.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotUnplugFromSelfMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotUnplugFromMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte koppla ur något från'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte koppla ur något från'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte koppla ur något från'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotUnplugFromMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotKissMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde verkligen inte kyssa detta.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde verkligen inte kyssa denna.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde verkligen inte kyssa dessa.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotKissMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotJumpOffMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag var inte på äpplet.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du var inte på jordgubben.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob var inte på vindruvorna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotJumpOffMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotJumpOverMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Det var meningslöst att hoppa över äpplet.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Det var meningslöst att hoppa över jordgubben.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Det var meningslöst att hoppa över vindruvorna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotJumpOverMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

// TODO: laga
// BMsg(cannot jump over self, '{I} {can} hardly jump over {myself}. '  )
// BMsg(cannot jump over self, '{Jag} {kan} knappast hoppa över {sigsjälv}. '),
TestUnit 'cannotJumpOverSelfMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde knappast hoppa över mig själv'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde knappast hoppa över dig själv'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde knappast hoppa över sig själv'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    //local iobj = actorAndObj[2];
    gCommand = new Command(actor, JumpOver, actor);

    assertThat(obj.cannotJumpOverSelfMsg.trimWS()).startsWith(expected);
  });
}
;

TestUnit 'cannotSetMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet var inte något jag kunde ställa in.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben var inte något du kunde ställa in.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna var inte något Bob kunde ställa in.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotSetMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotTypeOnMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte skriva något på äpplet.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte skriva något på jordgubben.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte skriva något på vindruvorna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotTypeOnMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotEnterOnMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte ange något på äpplet.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte ange något på jordgubben.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte ange något på vindruvorna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotEnterOnMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};    

TestUnit 'cannotWriteOnMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte skriva något på äpplet.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte skriva något på jordgubben.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte skriva något på vindruvorna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotWriteOnMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotConsultMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Äpplet var inte en informationskälla.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Jordgubben var inte en informationskälla.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Vindruvorna var inte en informationskälla.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotConsultMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotPourMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte hälla äpplet någonstans.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte hälla jordgubben någonstans.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte hälla vindruvorna någonstans.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotPourMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotPourOntoSelfMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte hälla äpplet på sig självt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte hälla jordgubben på sig själv.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte hälla vindruvorna på sig själva.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotPourOntoSelfMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

// TODO: 
//cannotPourIntoSelfMsg = BMsg(cannot pour in self, '{I} {can\'t} pour {the dobj} into {itself dobj}. ')
// Msg(cannot pour in self, '{Jag} {kan} inte hälla {ref dobj} i {sigsjälv}. '),
TestUnit 'cannotPourIntoSelfMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte hälla äpplet i sig självt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte hälla jordgubben i sig själv.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte hälla vindruvorna i sig själva.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotPourIntoSelfMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

//     cannotPourIntoMsg = BMsg(cannot pour into, '{I} {can\'t} pour {1} into {that dobj}. ', gDobj.fluidName)
//                          Msg(cannot pour into, '{Jag} {kan} inte hälla {1} i {ref iobj}. '),
TestUnit 'cannotPourIntoMsg'
run {
  [
      [spelare1aPerspektiv, vinet, korgen]    ->'Jag kunde inte hälla vinet i korgen'
    , [spelare2aPerspektiv, lasken, karlet]   ->'Du kunde inte hälla läsken i kärlet'
    , [spelare3ePerspektiv, dropparna, skorna]   ->'Bob kunde inte hälla dropparna i skorna'
  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    local iobj = actorAndObj[3];
    gCommand = new Command(actor, PourInto, obj, iobj);
    gDobj = obj;
    say(obj.cannotPourIntoMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotPourOntoMsg'
run {
  [
      [spelare1aPerspektiv, vinet, korgen]    ->'Jag kunde inte hälla vinet på korgen'
    , [spelare2aPerspektiv, lasken, karlet]   ->'Du kunde inte hälla läsken på kärlet'
    , [spelare3ePerspektiv, dropparna, skorna]   ->'Bob kunde inte hälla dropparna på skorna'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    local iobj = actorAndObj[3];
    gCommand = new Command(actor, PourOnto, obj, iobj);
    gDobj = obj;
    say(obj.cannotPourOntoMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'shouldNotPourIntoMsg'
run {
  [
      [spelare1aPerspektiv, vinet, korgen]    ->'Det var nog bäst att inte hälla vinet i korgen'
    , [spelare2aPerspektiv, lasken, karlet]   ->'Det var nog bäst att inte hälla läsken i kärlet'
    , [spelare3ePerspektiv, dropparna, skorna]   ->'Det var nog bäst att inte hälla dropparna i skorna'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    local iobj = actorAndObj[3];
    gCommand = new Command(actor, PourInto, obj, iobj);
    gDobj = obj;

    assertThat(obj.shouldNotPourIntoMsg.trimWS()).startsWith(expected);
  });
}
;

TestUnit 'shouldNotPourOntoMsg' run {
  [
      [spelare1aPerspektiv, vinet, korgen]    ->'Det var nog bäst att inte hälla vinet på korgen'
    , [spelare2aPerspektiv, lasken, karlet]   ->'Det var nog bäst att inte hälla läsken på kärlet'
    , [spelare3ePerspektiv, dropparna, skorna]   ->'Det var nog bäst att inte hälla dropparna på skorna'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    local iobj = actorAndObj[3];
    gCommand = new Command(actor, PourInto, obj, iobj);
    gDobj = obj;

    assertThat(obj.shouldNotPourOntoMsg.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotScrewMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte skruva äpplet.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte skruva jordgubben.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte skruva vindruvorna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotScrewMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotScrewWithMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte skruva något med detta.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte skruva något med denna.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte skruva något med dessa.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotScrewWithMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotScrewWithSelfMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte skruva'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte skruva'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte skruva'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotScrewWithSelfMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotUnscrewMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte skruva loss äpplet.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte skruva loss jordgubben.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte skruva loss vindruvorna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotUnscrewMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotUnscrewWithMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte skruva loss något med detta.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte skruva loss något med denna.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte skruva loss något med dessa.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotUnscrewWithMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotUnscrewWithSelfMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte skruva loss'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte skruva loss'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte skruva loss'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.cannotUnscrewWithSelfMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'hearNothingMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag hörde inget ovanligt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du hörde inget ovanligt.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob hörde inget ovanligt.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    say(obj.hearNothingMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

// TODO: laga
// cannotPushViaSelfMsg = BMsg(cannot push via self, '{I} {can\'t} {1} {the dobj} {2} {itself dobj}. ', gVerbWord, viaMode.prep)
//Msg(cannot push via self, '{Jag} {kan} inte {1} {ref dobj} {2} {sigsjälv dobj}. '),
TestUnit 'cannotPushViaSelfMsg' run {
  [
      [spelare1aPerspektiv, korgen]   ->'Jag kunde inte trycka korgen genom sig själv'
    , [spelare2aPerspektiv, karlet]   ->'Du kunde inte trycka kärlet genom sig självt'
    , [spelare3ePerspektiv, skorna]   ->'Bob kunde inte trycka skorna genom sig själva'
  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    //mainOutputStream.hideOutput = nil;
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gDobj = obj;
    gCommand = new Command(actor, Push, obj, obj);
    gCommand.verbProd = Push.verbRule;
    gCommand.verbProd.tokenList = [ ['trycka'] ];
    obj.viaMode = Through;    

    say(obj.cannotPushViaSelfMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotPushThroughMsg' run {
   [
      [spelare1aPerspektiv, korgen, karlet]   ->'Jag kunde inte trycka korgen genom kärlet'
    , [spelare2aPerspektiv, karlet, skorna]   ->'Du kunde inte trycka kärlet genom skorna'
    , [spelare3ePerspektiv, skorna, korgen]   ->'Bob kunde inte trycka skorna genom korgen'
  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    //mainOutputStream.hideOutput = nil;
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    local iobj = actorAndObj[3];
    gDobj = obj;
    gCommand = new Command(actor, Push, obj, iobj);
    gCommand.verbProd = Push.verbRule;
    gCommand.verbProd.tokenList = [ ['trycka'] ];
    obj.viaMode = Through;    

    say(obj.cannotPushThroughMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};
// okayPushIntoMsg = BMsg(okay push into, '{I} <<if matchPullOnly>> pull{s/ed} <<else>> push{es/ed}<<end>> {the dobj} into {the iobj}. ')
//Msg(okay push into, '{Jag}<<if matchPullOnly>> dr{ar|og} <<else>> tryck{er|te}<<end>> in {ref dobj} i {ref iobj}.'),
TestUnit 'okayPushIntoMsg' run {
  [
      [spelare1aPerspektiv, korgen, karlet]   ->'Jag tryckte in korgen i kärlet.'
    , [spelare2aPerspektiv, karlet, skorna]   ->'Du tryckte in kärlet i skorna.'
    , [spelare3ePerspektiv, skorna, korgen]   ->'Bob tryckte in skorna i korgen.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    //mainOutputStream.hideOutput = nil;
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    local iobj = actorAndObj[3];
    gDobj = obj;
    gCommand = new Command(actor, Push, obj, iobj);
    gCommand.verbProd = Push.verbRule;
    gCommand.verbProd.tokenList = [ ['trycka'] ];
    obj.viaMode = Into;    

    say(obj.okayPushIntoMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

//cannotPushIntoMsg = BMsg(cannot push into, '{I} {can\'t} {1} anything into {the iobj}. ', gVerbWord)
// Msg(cannot push into, '{Jag} {kan} inte {1} in något i {ref iobj}. '),
TestUnit 'cannotPushIntoMsg' run {
  [
      [spelare1aPerspektiv, korgen]   ->'Jag kunde inte trycka in något i korgen.'
    , [spelare2aPerspektiv, karlet]   ->'Du kunde inte trycka in något i kärlet.'
    , [spelare3ePerspektiv, skorna]   ->'Bob kunde inte trycka in något i skorna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    //mainOutputStream.hideOutput = nil;
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    local iobj = obj;
    gIobj = iobj;

    gCommand = new Command(actor, Push, obj, iobj);
    gCommand.verbProd = Push.verbRule;
    gCommand.verbProd.tokenList = [ ['trycka'] ];
    obj.viaMode = Into;    
    //tadsSay('gVerbWord: <<gVerbWord>>**\n');
    
    say(obj.cannotPushIntoMsg);
    assertThat(o.trimWS()).startsWith(expected);
  });
};

//okayPushOutOfMsg = BMsg(okay push out of, '{I} <<if matchPullOnly>> pull{s/ed} <<else>> push{es/ed}<<end>> {the dobj} {outof iobj}. ')
// Msg(okay push out of, '{Jag}<<if matchPullOnly>> dr{ar|og} <<else>> tryck{er|te}<<end>> {ref dobj} {utur iobj}. '),
TestUnit 'okayPushOutOfMsg' run {
  [
      [spelare1aPerspektiv, korgen, karlet]   ->'Jag tryckte ut korgen ur kärlet.'
    , [spelare2aPerspektiv, karlet, skorna]   ->'Du tryckte ut kärlet ur skorna.'
    , [spelare3ePerspektiv, skorna, korgen]   ->'Bob tryckte ut skorna ur korgen.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    mainOutputStream.hideOutput = nil;
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    local iobj = actorAndObj[3];
    iobj.contType = nil;

    gDobj = obj;
    gCommand = new Command(actor, Push, obj, iobj);
    gCommand.verbProd = Push.verbRule;
    assertThat(obj.okayPushOutOfMsg.trimWS()).startsWith(expected);
  });
};

// cannotPushUpMsg = BMsg(cannot push up, '{I} {can\'t} {1} anything up {the iobj}. ', gVerbWord)
    
TestUnit 'cannotPushUpMsg' run {
  [
      [spelare1aPerspektiv, karlet]    ->'Jag kunde inte trycka upp något i kärlet.'
    , [spelare2aPerspektiv, hyllan]   ->'Du kunde inte trycka upp något i hyllan.'
    , [spelare3ePerspektiv, stuprannorna]   ->'Bob kunde inte trycka upp något i stuprännorna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    //mainOutputStream.hideOutput = nil;
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    local iobj = obj;
    gIobj = iobj;

    gCommand = new Command(actor, Push, obj, iobj);
    gCommand.verbProd = Push.verbRule;
    gCommand.verbProd.tokenList = [ ['trycka'] ];
    obj.viaMode = Into;    
    //tadsSay('gVerbWord: <<gVerbWord>>**\n');

    assertThat(obj.cannotPushUpMsg.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotPushDownMsg' run {
   [
      [spelare1aPerspektiv, karlet]    ->'Jag kunde inte trycka ner något i kärlet.'
    , [spelare2aPerspektiv, hyllan]   ->'Du kunde inte trycka ner något i hyllan.'
    , [spelare3ePerspektiv, stuprannorna]   ->'Bob kunde inte trycka ner något i stuprännorna.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    //mainOutputStream.hideOutput = nil;
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    local iobj = obj;
    gIobj = iobj;

    gCommand = new Command(actor, Push, obj, iobj);
    gCommand.verbProd = Push.verbRule;
    gCommand.verbProd.tokenList = [ ['trycka'] ];
    obj.viaMode = Into;    
    //tadsSay('gVerbWord: <<gVerbWord>>**\n');

    assertThat(obj.cannotPushDownMsg.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotTalkToMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Det fanns ingen mening med att försöka prata med den'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Det fanns ingen mening med att försöka prata med den'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Det fanns ingen mening med att försöka prata med den'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    assertThat(obj.cannotTalkToMsg.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotTalkToSelfMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Att prata med mig själv var meningslöst.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Att prata med dig själv var meningslöst.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Att prata med Bob själv var meningslöst.' // TODO: sig själv

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    mainOutputStream.hideOutput = nil;
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    assertThat(obj.cannotTalkToSelfMsg.trimWS()).startsWith(expected);
  });
}
;

// Msg(already has, '{Ref subj iobj} hade redan {ref dobj}. '),
TestUnit 'alreadyHasMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag hade redan äpplet'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du hade redan jordgubben'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob hade redan vindruvorna'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local iobj = actorAndObj[2];
    gCommand = new Command(actor, GiveTo, iobj, actor);
    assertThat(iobj.alreadyHasMsg.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotGiveToMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte ge något till detta.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte ge något till denna.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte ge något till dessa.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    assertThat(obj.cannotGiveToMsg.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotGiveToSelfMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte ge något till mig självt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte ge något till dig själv.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte ge något till sig själva.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);

    assertThat(obj.cannotGiveToSelfMsg.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotShowToMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte visa något för detta.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte visa något för denna.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte visa något för dessa.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    
    assertThat(obj.cannotShowToMsg.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotShowToSelfMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte visa något för mig självt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte visa något för dig själv.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte visa något för sig själva.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);

    assertThat(obj.cannotShowToSelfMsg.trimWS()).startsWith(expected);
  });
};

TestUnit 'notTalkingToAnyoneMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag pratar inte med någon.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du pratar inte med någon.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob pratar inte med någon.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    assertThat(obj.notTalkingToAnyoneMsg.trimWS()).startsWith(expected);
  });
};

TestUnit 'hearNothingMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag hörde inget ovanligt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du hörde inget ovanligt.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob hörde inget ovanligt.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);

    assertThat(obj.hearNothingMsg.trimWS()).startsWith(expected);
  });
};

// cantSpecialActionMsg = BMsg(cant do special, '{I} {can\'t} {1} {the dobj}. ', gAction.specialPhrase )
TestUnit 'cantSpecialActionMsg'
run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte dekorera äpplet'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte dekorera jordgubben'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte dekorera vindruvorna'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    gAction.specialPhrase = 'dekorera';

    assertThat(obj.cantSpecialActionMsg.trimWS()).startsWith(expected);
  });
}
;

TestUnit 'cannotPurloinSelfMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte stjäla mig själv.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte stjäla dig själv.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte stjäla sig själv.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);

    assertThat(obj.cannotPurloinSelfMsg.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotPurloinRoomMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte stjäla ett rum.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte stjäla ett rum.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte stjäla ett rum.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);
    assertThat(obj.cannotPurloinRoomMsg.trimWS()).startsWith(expected);
  });
};

TestUnit 'hearNothingMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag hörde inget ovanligt.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du hörde inget ovanligt.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob hörde inget ovanligt.'
  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);

    assertThat(obj.hearNothingMsg.trimWS()).startsWith(expected);
  });
};

TestUnit 'cannotGoNearThereMsg' run {
  [
      [spelare1aPerspektiv, appletObjNeutrumSingular]    ->'Jag kunde inte gå dit just nu.'
    , [spelare2aPerspektiv, jordgubbeObjUtrumSingular]   ->'Du kunde inte gå dit just nu.'
    , [spelare3ePerspektiv, vindruvorObjNeutrumPlural]   ->'Bob kunde inte gå dit just nu.'

  ].forEachAssoc(function(actorAndObj, expected) {
    mainOutputStream.capturedOutputBuffer = new StringBuffer();
    local actor = actorAndObj[1];
    local obj = actorAndObj[2];
    gCommand = new Command(actor, Examine, obj);

    assertThat(obj.cannotGoNearThereMsg.trimWS()).startsWith(expected);
  });
};

