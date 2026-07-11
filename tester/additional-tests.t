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
  //usePastTense = true
;

// Test arrangements
modify testRunner 
  verboseAboutSuccessfulTests = nil // Visa inte varje testutfall om det är OK
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

#define o toString(mainOutputStream.capturedOutputBuffer)

modify String
    // Same as trim, both also trims whitespace vertically
    trimWS() { return findReplace(trimPatWS, ''); }
    trimPatWS = R'^<space>+|<vspace>|<newline>+|$'
    
    cleanUpDoubleSpaces() {
      return trimWS().findReplace('  ',' ',ReplaceAll);
    }
;

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

spelare2aPerspektiv: Actor 'du' @koket
  person = 2
  isProper = true
  isHim = true
;

+hatt: Wearable 'hatt+en;;kläd+er'
  wornBy = spelare2aPerspektiv 
;

+jacka: Wearable 'jacka+n;;kläd+er' 
  wornBy = spelare2aPerspektiv
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
    
musketorer: Actor 'musketörer+na;;;dem'
  proper = nil
  plural = true
  isHim = true
;

appletObjNeutrumSingular: Thing 'äpple+t;rö:tt+da;;det';
jordgubbeObjUtrumSingular: Thing 'jordgubbe+n;;en';
vindruvorObjNeutrumPlural: Thing 'vindruvor+na[pl];;;dem';


koket: Room 'Köket';
+kylen: Container 'kyl+en' isOpen = true;
//+vinet: Thing 'vin+et' vinet: Thing 'vin' massNoun = true;;
++vin: Thing 'vin' massNoun = true;
++lasken: Thing 'läsk+en';
++dropparna: Thing 'droppar+na[pl];;;dem';

+trasan: Thing 'trasa+n';

korgen: Container 'korg+en';
hyllan: Surface 'hylla+n'; 
garderoben: OpenableContainer 'garderob+en';

dorrenObjUtrumSingular: Thing 'dörr+en';
skapetObjNeutrumSingular: OpenableContainer 'skåp+et';
dorrarObjUterPlural: Thing 'dörrar+na;;;dem';

mjolkMassNoun: Thing 'mjölk' massNoun = true;

bobsHarObjNeutrumSingular: Thing 'hår+et'
  ownerNamed = true
  owner = [spelare3ePerspektiv]
;

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



+tingest: Thing 'tingest+en';
+skapet: Thing 'skåp+et';

// Objekt med +-notation — definiteForm sätts automatiskt av parsern
+stol: Thing 'stol+en';               // utrum singular
+bord: Thing 'bord+et' isNeuter = true;  // neutrum singular
+stolar: Thing 'stol+ar+na;;;dem' plural = true;  // plural

+husFallback: Thing 'hus+et' isNeuter = true;
+katternFallback: Thing 'katter' plural = true;
+bobProper: Thing 'bob' proper = true qualified = true;

+ljus: Thing 'ljus+et;;ljus[pl]' isLit = true;
+ljuskrona: Thing 'ljus+krona+n;;ljuskronor[pl]' isLit = true;

// Båda dessa fungerar men inte den sista, fixa
//+gatulyktor: Thing 'gatu+lyktor+na' plural = true isLit = true;
+gatulyktor: Thing 'gatu|lyktor+na[pl];;;dem' plural = true isLit = true;
//+gatulyktor: Thing 'gatu+lyktor+na*gatulyktor' plural = true isLit = true;

+virke: Thing 'virke+t*virke' massNoun = true isLit = true;
+olja: Thing 'olja+n*olja' massNoun = true isLit = true;


// TODO:
//objectLister.showSimpleList
//stringLister.showSimpleList


// TODO: move to past/present tense tests
TestUnit 'lookLister.show' run {
    //mainOutputStream.hideOutput = nil;  
    gActor = spelare2aPerspektiv;
    lookLister.show([ljuskrona, ljus, hatt, jacka, tingest, skapet], 0);
    assertThat(o.trimWS())
      .isEqualTo('Du kan se en jacka (buren), en tingest, ett skåp, en ljuskrona (som avger ljus), en hatt (buren) och ett ljus (som avger ljus) här.');
};

TestUnit 'inventoryLister.show' run {
    //mainOutputStream.hideOutput = nil;  
    gActor = spelare2aPerspektiv;
    inventoryLister.show([ljuskrona, ljus, hatt, jacka, tingest, skapet], 0);
    assertThat(o.trimWS())
      .isEqualTo('Du bär på en jacka (buren), en tingest, ett skåp, en ljuskrona (som avger ljus), en hatt (buren) och ett ljus (som avger ljus).');
};

/*
// TODO:
TestUnit 'inventoryTallLister.show' run {
    //mainOutputStream.hideOutput = nil;  
    gActor = spelare2aPerspektiv;
    inventoryTallLister.show([ljuskrona, ljus, hatt, jacka, tingest, skapet], 0);
    assertThat(o.trimWS())
      .contains('en jacka (buren) en tingest, ett skåp, en ljuskrona (som avger ljus), en hatt (buren) och ett ljus (som avger ljus).');
};*/


TestUnit 'wornLister.show' run {
    //mainOutputStream.hideOutput = nil;  
    gActor = spelare2aPerspektiv;
    wornLister.show([ljuskrona, ljus, hatt, jacka, tingest, skapet], 0);
    assertThat(o.trimWS())
      .isEqualTo('Du bär en jacka, en tingest, ett skåp, en ljuskrona (som avger ljus), en hatt och ett ljus (som avger ljus)');
};

// subLister - t ex: '(i vilket är en penna, en penna och ett papper)
TestUnit 'subLister.show' run {
    //mainOutputStream.hideOutput = nil;  
    gActor = spelare2aPerspektiv;
    subLister.show([vin, lasken, dropparna], 0);
    assertThat(o.trimWS())
      .isEqualTo('(i vilken är en läsk, några droppar och vin)');
};

TestUnit 'lookLister.show' run {
    //mainOutputStream.hideOutput = nil;  
    gActor = spelare2aPerspektiv;
    lookLister.show([vin, lasken, dropparna], 0);
    assertThat(o.trimWS())
      .isEqualTo('Du kan se en läsk, några droppar och vin här.');
};

/* 
// TODO:
TestUnit 'lookContentsLister.show' run {
    //mainOutputStream.hideOutput = nil;  
    gActor = spelare2aPerspektiv;
    lookContentsLister.show([vin, lasken, dropparna], 0);
    assertThat(o.trimWS())
      .isEqualTo('Du kan se en läsk, några droppar och vin här.');
};

TestUnit 'descContentsLister.show' run {
    //mainOutputStream.hideOutput = nil;  
    gActor = spelare2aPerspektiv;
    descContentsLister.show([vin, lasken, dropparna], 0);
    assertThat(o.trimWS())
      .isEqualTo('Du kan se en läsk, några droppar och vin här.');
};


TestUnit 'openingContentsLister.show' run {
    //mainOutputStream.hideOutput = nil;  
    gActor = spelare2aPerspektiv;
    openingContentsLister.show([vin, lasken, dropparna], 0);
    assertThat(o.trimWS())
      .isEqualTo('Du kan se en läsk, några droppar och vin här.');
};

TestUnit 'simpleAttachmentLister.show' run {
    //mainOutputStream.hideOutput = nil;  
    gActor = spelare2aPerspektiv;
    simpleAttachmentLister.show([vin, lasken, dropparna], 0);
    assertThat(o.trimWS())
      .isEqualTo('Du kan se en läsk, några droppar och vin här.');
};

TestUnit 'plugAttachableLister.show' run {
    //mainOutputStream.hideOutput = nil;  
    gActor = spelare2aPerspektiv;
    plugAttachableLister.show([vin, lasken, dropparna], 1);
    assertThat(o.trimWS())
      .isEqualTo('Du kan se en läsk, några droppar och vin här.');
};

*/

TestUnit 'lookInLister.show' run {
    //mainOutputStream.hideOutput = nil;  
    gActor = spelare2aPerspektiv;
    lookInLister.show([vin, lasken, dropparna], 0);
    assertThat(o.trimWS())
      .isEqualTo('Du ser en läsk, några droppar och vin.');
};


/*
// TODO: fix space issues
TestUnit 'remoteRoomContentsLister.show' run {
    //mainOutputStream.hideOutput = nil;  
    gActor = spelare2aPerspektiv;
    remoteRoomContentsLister.show([vin, lasken, dropparna], 'I kylen');
    assertThat(o.trimWS())
      .startsWith('I kylen ser du en läsk, några droppar och vin');
};


TestUnit 'remoteSubContentsLister.show' run {
    //mainOutputStream.hideOutput = nil;  
    gActor = spelare2aPerspektiv;
    // TODO: använd inRoomName korrekt
    local x = koket.inRoomName(spelare2aPerspektiv);
    remoteSubContentsLister.show([vin, lasken, dropparna], 'I kylen');
    assertThat(o.trimWS())
      .startsWith('I kylen är en läsk, några droppar och vin');
};*/

/*
TestUnit 'Tänt ljus neutrum' run {
  assertThat(ljus.nameLit).isEqualTo('tänt ljus');
  assertThat(ljus.aNameLit()).isEqualTo('ett tänt ljus');
  assertThat(ljus.theNameLit).isEqualTo('det tända ljuset');
  assertThat(ljus.pluralNameLit).isEqualTo('tända ljus'); 

  ljus.isLit = nil;
  assertThat(ljus.nameLit).isEqualTo('otänt ljus');
  assertThat(ljus.aNameLit()).isEqualTo('ett otänt ljus');
  assertThat(ljus.theNameLit).isEqualTo('det otända ljuset');
  assertThat(ljus.pluralNameLit).isEqualTo('otända ljus'); 
  olja.isLit = true;

};
*/

/*
TestUnit 'Tänd ljuskrona utrum' run {
  assertThat(ljuskrona.nameLit).isEqualTo('tänd ljuskrona');
  assertThat(ljuskrona.aNameLit()).isEqualTo('en tänd ljuskrona');
  assertThat(ljuskrona.theNameLit).isEqualTo('den tända ljuskronan');
  assertThat(ljuskrona.pluralNameLit).isEqualTo('tända ljuskronor'); 

  ljuskrona.isLit = nil;
  assertThat(ljuskrona.nameLit).isEqualTo('otänd ljuskrona');
  assertThat(ljuskrona.aNameLit()).isEqualTo('en otänd ljuskrona');
  assertThat(ljuskrona.theNameLit).isEqualTo('den otända ljuskronan');
  assertThat(ljuskrona.pluralNameLit).isEqualTo('otända ljuskronor'); 
  ljuskrona.isLit = true;
};

TestUnit 'Tända gatulyktor plural' run {
  assertThat(gatulyktor.nameLit).isEqualTo('tända gatulyktor');
  assertThat(gatulyktor.aNameLit()).isEqualTo('tända gatulyktor');
  assertThat(gatulyktor.theNameLit).isEqualTo('de tända gatulyktorna');
  assertThat(gatulyktor.pluralNameLit).isEqualTo('tända gatulyktor'); 

  gatulyktor.isLit = nil;
  assertThat(gatulyktor.nameLit).isEqualTo('otända gatulyktor');
  assertThat(gatulyktor.aNameLit()).isEqualTo('otända gatulyktor');
  assertThat(gatulyktor.theNameLit).isEqualTo('de otända gatulyktorna');
  assertThat(gatulyktor.pluralNameLit).isEqualTo('otända gatulyktor'); 
  gatulyktor.isLit = true;

};


TestUnit 'Tänt virke/tänd olja (massnoun)' run {
  assertThat(virke.nameLit).isEqualTo('tänt virke');
  assertThat(virke.aNameLit()).isEqualTo('tänt virke');
  assertThat(virke.theNameLit).isEqualTo('det tända virket');
  assertThat(virke.pluralNameLit).isEqualTo('tänt virke'); 

  assertThat(olja.nameLit).isEqualTo('tänd olja');
  assertThat(olja.aNameLit()).isEqualTo('tänd olja');
  assertThat(olja.theNameLit).isEqualTo('den tända oljan');
  assertThat(olja.pluralNameLit).isEqualTo('tänd olja'); 

  olja.isLit = nil;

  assertThat(olja.nameLit).isEqualTo('otänd olja');
  assertThat(olja.aNameLit()).isEqualTo('otänd olja');
  assertThat(olja.theNameLit).isEqualTo('den otända oljan');
  assertThat(olja.pluralNameLit).isEqualTo('otänd olja'); 
  olja.isLit = true;

};

TestUnit 'spellIntOrdinalExt' run {
  [ 1 -> 'första', 2 -> 'andra', 3 -> 'tredje', 4 -> 'fjärde', 5 -> 'femte', 
    6 -> 'sjätte', 7 -> 'sjunde', 8 -> 'åttonde', 9 -> 'nionde', 10 -> 'tionde', 
    11 -> 'elfte', 12 -> 'tolfte', 13 -> 'trettonde', 14 -> 'fjortonde', 15 -> 'femtonde', 
    16 -> 'sextonde', 17 -> 'sjuttonde', 18 -> 'artonde', 19 -> 'nittonde', 
 
    20 -> 'tjugonde', 21 -> 'tjugoförsta',  22 -> 'tjugoandra',23 -> 'tjugotredje',24 -> 'tjugofjärde',
    25 -> 'tjugofemte', 26 -> 'tjugosjätte', 27 -> 'tjugosjunde', 28 -> 'tjugoåttonde', 29 -> 'tjugonionde',
    30 -> 'trettionde', 31 -> 'trettioförsta', 32 -> 'trettioandra',
    40 -> 'fyrtionde',
    50 -> 'femtionde',
    60 -> 'sextionde',
    70 -> 'sjuttionde',
    80 -> 'åttionde',
    90 -> 'nittionde',
    100 -> 'etthundrade', 
    1000 -> 'etttusende', 
    10000 -> 'tiotusende', 
    100000 -> 'etthundratusende', 
    1000000 -> 'enmiljonte',
    1111111 -> 'enmiljonetthundraelvatusenetthundraelfte' // Svenskan är galen på sammansättningar!
  ].forEachAssoc(function(n, expected) {
    local x = spellIntOrdinalExt(n, SpellIntTeenHundreds & SpellIntAndTens & SpellIntCommas);
    //tadsSay('<<x>>\n');
    assertThat(x).isEqualTo(expected);

  });
};


TestUnit 'LiteralTAction.getOtherMessageObjectPronoun' run {
  local a = LiteralTAction.createActionInstance();
  local x = a.getOtherMessageObjectPronoun(DirectObject);
  assertThat(x).isEqualTo('det');
};


TestUnit 'cmdTokenizer.buildOrigText' run {
  assertThat(cmdTokenizer.buildOrigText(cmdTokenizer.tokenize('tjugo -  ett'))).isEqualTo('tjugo-ett');
};

TestUnit 'splitWithDelimiterPattern' run {
    local result = splitWithDelimiterPattern('met|spö+et');
    assertThat(result[1]).isEqualTo(['met', '|']);
    assertThat(result[2]).isEqualTo(['spö', '+']);
    assertThat(result[3]).isEqualTo(['et', nil]);
};

TestUnit 'splitWithDelimiterPattern' run {
    local result = splitWithDelimiterPattern('ljus+krona+n');
    //tadsSay(result);
    assertThat(result[1]).isEqualTo(['ljus', '+']);
    assertThat(result[2]).isEqualTo(['krona', '+']);
    assertThat(result[3]).isEqualTo(['n', nil]);
};



TestUnit 'objectLister.makeSimpleList' run {
    local result = objectLister.makeSimpleList([ljuskrona, ljus, hatt, jacka, tingest, skapet]);
    //tadsSay(result);
    assertThat(result).isEqualTo('en ljuskrona (avger ljus), ett ljus, en hatt (påklädd), en jacka (påklädd), en tingest, och ett skåp');
};

TestUnit 'stringLister.makeSimpleList' run {
    local result = stringLister.makeSimpleList(['ljuskrona', 'ljus', 'hatt', 'jacka', 'tingest', 'skåpet']);
    //tadsSay(result);
    assertThat(result).isEqualTo('ljuskrona, ljus, hatt, jacka, tingest, och skåpet');
};


TestUnit 'plainLister.showListAll' run {
    local lst = [ljuskrona, ljus, hatt, jacka, tingest, skapet];
    local result = mainOutputStream.captureOutput({: 
      plainLister.showListAll(lst,0, 0)
    }); 
    assertThat(result).isEqualTo('en ljuskrona (avger ljus), ett ljus, en hatt (påklädd), en jacka (påklädd), en tingest, och ett skåp');
};
*/

/*
TestUnit 'specialDescLister.showListAll' run {
    //ljuskrona.specialDesc = {: "sdfadf" };
    gActor = spelare2aPerspektiv;

    local infoTab = new LookupTable();
    infoTab[ljuskrona] = new SenseInfo(ljuskrona, opaque, nil, 0);
    
    //local result = mainOutputStream.captureOutput({: 
      specialDescLister.showListItem(ljuskrona, nil, gActor, infoTab);
    //}); 
    //assertThat(result).isEqualTo('en ljuskrona (avger ljus), ett ljus, en hatt (påklädd), en jacka (påklädd), en tingest, och ett skåp');
};
*/

TestUnit 'Thing.listContents (using openingContentsLister)' run {
    mainOutputStream.hideOutput = nil;  
    local result = mainOutputStream.captureOutput({: 
      // anropar listSubcontentsOf med openingContentsLister indirekt
      kylen.actionDobjOpen()
    }); 
    assertThat(result).startsWith('När kylen öppnas upptäcker du vin, några droppar och en läsk.');
};

TestUnit 'Action.implicitAnnouncement(true)' run {
  [ 
     [Eat, jordgubbeObjUtrumSingular]
        -> ['äter jordgubben', 'försöker äta jordgubben']

    ,[PourInto, lasken] -> ['häller läsken', 'försöker hälla läsken']
    ,[PourInto, lasken] -> ['häller läsken', 'försöker hälla läsken']
    ,[Clean, lasken] -> ['rengör läsken', 'försöker rengöra läsken']

    ,[CleanWith, lasken, trasan] 
      -> ['rengör läsken med trasan', 'försöker rengöra läsken med trasan']


  ].forEachAssoc(function(actionAndObj, expectedTexts) {
    mainOutputStream.hideOutput = nil;  
    gAction = actionAndObj[1].createInstance();
    gAction.isImplicit = true;

    if(actionAndObj.length >= 2) {
      gAction.curDobj = actionAndObj[2];
    }
    if(actionAndObj.length == 3) {
      gAction.curIobj = actionAndObj[3];
    }

    assertThat(gAction.implicitAnnouncement(true))
      .isEqualTo(expectedTexts[1]);
    assertThat(gAction.implicitAnnouncement(nil))
      .isEqualTo(expectedTexts[2]);
  });
}
//only = true
;
