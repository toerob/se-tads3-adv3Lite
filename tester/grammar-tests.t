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

// Component-test: behöver ett förälderobjekt för att Component ska ha location
spelareKroppObj: Thing 'kropp+en' @lab;
+ spelareNasaComp: Component 'näsa+n'
  ownerNamed = true
  owner = [spelare2aPerspektiv]
;

// 2:a person plural
spelareHanderObj: Thing 'händer+na[pl];;;dem'
  ownerNamed = true
  owner = [spelare2aPerspektiv]
;

// NPC-aktörer för possEnding-tester
gostaActor: Actor 'Gösta;;;honom' @lab;      // konsonantslut → Göstas
jonasActor: Actor 'Jonas;;;honom' @lab;      // s-slut → Jonas (inget extra s)
penntecknareActor: Actor 'penntecknare+n;;;honom' @lab; // bestämd form → penntecknarens

// Objekt ägda av NPC (för theName- och possessify-tester)
gostasMossaObj: Thing 'mössa+n'
  ownerNamed = true
  owner = [gostaActor]
;
jonasMossaObj: Thing 'mössa+n'
  ownerNamed = true
  owner = [jonasActor]
;


musketorer: Actor 'musketörer+na;;;dem'
  proper = nil
  plural = true
  isHim = true
;

appletObjNeutrumSingular: Thing 'äpple+t;rö:tt+da;;det';
jordgubbeObjUtrumSingular: Thing 'jordgubbe+n;;en';
vindruvorObjNeutrumPlural: Thing 'vindruvor+na[pl];;;dem';


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

/*
Subjekt  Objekt  Reflexiva   Possessiva en  Ett   Flera
Jag      Mig     Mig         Min            Mitt  Mina
Du       Dig     Dig         Din            Ditt  Dina
Han      Honom   Sig         Hans           Hans  Hans
Hon      Henne   Sig         Hennes         Hennes Hennes
Den      Den     Sig         Dess           Dess  Dess
Det      Det     Sig         Dess           Dess  Dess
Vi       Oss     Oss         Vår            Vårt  Våra
De       Dem     Sig         Deras          Deras Deras
*/

/* ============================================================
 * Pronomen-testobjekt
 * ============================================================ */

katten: Thing 'katt+en'
    isHer = true
;

hunden: Thing 'hund+en'
    isHim = true
;

/* Aktörer för test av person 1/2 med neutrum */
robotNeutrum1aPerson: Actor 'jag'
    person = 1
    isNeuter = true
;

robotNeutrum2aPerson: Actor 'du'
    person = 2
    isNeuter = true
;

/* ============================================================
 * Pronomen-objekt: egenskaper
 * ============================================================ */

TestUnit 'pronomen/It' run {
    assertThat(It.name).isEqualTo('den');
    assertThat(It.objName).isEqualTo('den');
    assertThat(It.possAdj).isEqualTo('dess');
    assertThat(It.possNoun).isEqualTo('dess');
    assertThat(It.thatName).isEqualTo('den');
    assertThat(It.thatObjName).isEqualTo('den');
    assertThat(It.reflexive).isEqualTo(Itself);
};

TestUnit 'pronomen/ItNeuter' run {
    assertThat(ItNeuter.name).isEqualTo('det');
    assertThat(ItNeuter.objName).isEqualTo('det');
    assertThat(ItNeuter.possAdj).isEqualTo('dess');
    assertThat(ItNeuter.possNoun).isEqualTo('dess');
    assertThat(ItNeuter.thatName).isEqualTo('det');
    assertThat(ItNeuter.thatObjName).isEqualTo('det');
    assertThat(ItNeuter.reflexive).isEqualTo(Itself);
};

TestUnit 'pronomen/Him' run {
    assertThat(Him.name).isEqualTo('han');
    assertThat(Him.objName).isEqualTo('honom');
    assertThat(Him.possAdj).isEqualTo('hans');
    assertThat(Him.possNoun).isEqualTo('hans');
    assertThat(Him.reflexive).isEqualTo(Himself);
};

TestUnit 'pronomen/Her' run {
    assertThat(Her.name).isEqualTo('hon');
    assertThat(Her.objName).isEqualTo('henne');
    assertThat(Her.possAdj).isEqualTo('hennes');
    assertThat(Her.possNoun).isEqualTo('hennes');
    assertThat(Her.reflexive).isEqualTo(Herself);
};

TestUnit 'pronomen/Them' run {
    assertThat(Them.name).isEqualTo('de');
    assertThat(Them.objName).isEqualTo('dem');
    assertThat(Them.possAdj).isEqualTo('deras');
    assertThat(Them.possNoun).isEqualTo('deras');
    assertThat(Them.thatName).isEqualTo('de');
    assertThat(Them.thatObjName).isEqualTo('de');
    assertThat(Them.reflexive).isEqualTo(Themselves);
};

TestUnit 'pronomen/You' run {
    assertThat(You.name).isEqualTo('du');
    assertThat(You.objName).isEqualTo('dig');
    assertThat(You.possAdj).isEqualTo('din');
    assertThat(You.possNoun).isEqualTo('din');
    assertThat(You.possAdjT).isEqualTo('ditt');
    assertThat(You.reflexive).isEqualTo(Yourself);
};

TestUnit 'pronomen/Yall' run {
    assertThat(Yall.name).isEqualTo('dina');
    assertThat(Yall.objName).isEqualTo('dina');
    assertThat(Yall.possAdj).isEqualTo('dina');
    assertThat(Yall.possNoun).isEqualTo('dina');
    assertThat(Yall.reflexive).isEqualTo(Yourselves);
};

TestUnit 'pronomen/Me' run {
    assertThat(Me.name).isEqualTo('jag');
    assertThat(Me.objName).isEqualTo('mig');
    assertThat(Me.possAdj).isEqualTo('min');
    assertThat(Me.possNoun).isEqualTo('min');
    assertThat(Me.reflexive).isEqualTo(Myself);
};

TestUnit 'pronomen/MeAll' run {
    assertThat(MeAll.name).isEqualTo('mina');
    assertThat(MeAll.objName).isEqualTo('mina');
    assertThat(MeAll.possAdj).isEqualTo('mina');
    assertThat(MeAll.possNoun).isEqualTo('mina');
    assertThat(MeAll.reflexive).isEqualTo(Myself); /* buggfix: var Yourselves */
};

TestUnit 'pronomen/Us' run {
    assertThat(Us.name).isEqualTo('vi');
    assertThat(Us.objName).isEqualTo('oss');
    assertThat(Us.possAdj).isEqualTo('vår');
    assertThat(Us.possNoun).isEqualTo('vår');
    assertThat(Us.reflexive).isEqualTo(Ourselves);
};

TestUnit 'pronomen/UsAll' run {
    assertThat(UsAll.possAdj).isEqualTo('våra');
    assertThat(UsAll.possNoun).isEqualTo('våra');
    assertThat(UsAll.reflexive).isEqualTo(Ourselves);
};

TestUnit 'pronomen/reflexiver' run {
    assertThat(Myself.name).isEqualTo('mig');
    assertThat(Myself.objName).isEqualTo('mig');
    assertThat(Myself.pronoun).isEqualTo(Me);

    assertThat(Yourself.name).isEqualTo('dig');
    assertThat(Yourself.objName).isEqualTo('dig');
    assertThat(Yourself.pronoun).isEqualTo(You);

    assertThat(Itself.name).isEqualTo('sig');
    assertThat(Itself.objName).isEqualTo('sig');
    assertThat(Itself.pronoun).isEqualTo(It);

    assertThat(Herself.name).isEqualTo('sig');
    assertThat(Herself.objName).isEqualTo('sig');
    assertThat(Herself.pronoun).isEqualTo(Her);

    assertThat(Himself.name).isEqualTo('sig');
    assertThat(Himself.objName).isEqualTo('sig');
    assertThat(Himself.pronoun).isEqualTo(Him);

    assertThat(Ourselves.name).isEqualTo('oss');
    assertThat(Ourselves.objName).isEqualTo('oss');
    assertThat(Ourselves.pronoun).isEqualTo(Us);

    assertThat(Yourselves.name).isEqualTo('er');
    assertThat(Yourselves.objName).isEqualTo('er');
    assertThat(Yourselves.pronoun).isEqualTo(Yall);

    assertThat(Themselves.name).isEqualTo('sig');
    assertThat(Themselves.objName).isEqualTo('sig');
    assertThat(Themselves.pronoun).isEqualTo(Them);
};

/* ============================================================
 * pronoun() — returnerar rätt Pronoun-objekt per genus/person
 * ============================================================ */

TestUnit 'pronoun()/utrum singular' run {
    assertThat(dorrenObjUtrumSingular.pronoun()).isEqualTo(It);
};

TestUnit 'pronoun()/neutrum singular' run {
    assertThat(skapetObjNeutrumSingular.pronoun()).isEqualTo(ItNeuter);
};

TestUnit 'pronoun()/maskulinum' run {
    assertThat(hunden.pronoun()).isEqualTo(Him);
};

TestUnit 'pronoun()/femininum' run {
    assertThat(katten.pronoun()).isEqualTo(Her);
};

TestUnit 'pronoun()/plural' run {
    assertThat(vindruvorObjNeutrumPlural.pronoun()).isEqualTo(Them);
};

TestUnit 'pronoun()/1a person utrum' run {
    assertThat(spelare1aPerspektiv.pronoun()).isEqualTo(Me);
};

TestUnit 'pronoun()/1a person neutrum' run {
    assertThat(robotNeutrum1aPerson.pronoun()).isEqualTo(Me);
};

TestUnit 'pronoun()/2a person utrum' run {
    assertThat(spelare2aPerspektiv.pronoun()).isEqualTo(You);
};

TestUnit 'pronoun()/2a person neutrum' run {
    assertThat(robotNeutrum2aPerson.pronoun()).isEqualTo(You);
};

/* ============================================================
 * matchPronoun — korrekthet efter buggfix för ItNeuter
 * ============================================================ */

TestUnit 'matchPronoun/utrum matchar It' run {
    assertThat(dorrenObjUtrumSingular.matchPronoun(It)).isEqualTo(true);
};

TestUnit 'matchPronoun/utrum matchar inte ItNeuter' run {
    assertThat(dorrenObjUtrumSingular.matchPronoun(ItNeuter)).isEqualTo(nil);
};

TestUnit 'matchPronoun/neutrum matchar ItNeuter' run {
    assertThat(skapetObjNeutrumSingular.matchPronoun(ItNeuter)).isEqualTo(true);
};

TestUnit 'matchPronoun/neutrum matchar inte It' run {
    assertThat(skapetObjNeutrumSingular.matchPronoun(It)).isEqualTo(nil);
};

TestUnit 'matchPronoun/maskulinum matchar Him' run {
    assertThat(hunden.matchPronoun(Him)).isEqualTo(true);
};

TestUnit 'matchPronoun/maskulinum matchar inte It' run {
    assertThat(hunden.matchPronoun(It)).isEqualTo(nil);
};

TestUnit 'matchPronoun/femininum matchar Her' run {
    assertThat(katten.matchPronoun(Her)).isEqualTo(true);
};

TestUnit 'matchPronoun/femininum matchar inte It' run {
    assertThat(katten.matchPronoun(It)).isEqualTo(nil);
};

TestUnit 'matchPronoun/plural matchar Them' run {
    assertThat(vindruvorObjNeutrumPlural.matchPronoun(Them)).isEqualTo(true);
};

TestUnit 'matchPronoun/plural matchar inte It' run {
    assertThat(vindruvorObjNeutrumPlural.matchPronoun(It)).isEqualTo(nil);
};

/* ============================================================
 * heName / himName / herName / hersName
 * ============================================================ */

TestUnit 'objektnamn/utrum singular' run {
    assertThat(dorrenObjUtrumSingular.heName).isEqualTo('den');
    assertThat(dorrenObjUtrumSingular.himName).isEqualTo('den');
    assertThat(dorrenObjUtrumSingular.herName).isEqualTo('dess');
    assertThat(dorrenObjUtrumSingular.hersName).isEqualTo('dess');
};

TestUnit 'objektnamn/neutrum singular' run {
    assertThat(skapetObjNeutrumSingular.heName).isEqualTo('det');
    assertThat(skapetObjNeutrumSingular.himName).isEqualTo('det');
    assertThat(skapetObjNeutrumSingular.herName).isEqualTo('dess');
    assertThat(skapetObjNeutrumSingular.hersName).isEqualTo('dess');
};

TestUnit 'objektnamn/maskulinum' run {
    assertThat(hunden.heName).isEqualTo('han');
    assertThat(hunden.himName).isEqualTo('honom');
    assertThat(hunden.herName).isEqualTo('hans');
    assertThat(hunden.hersName).isEqualTo('hans');
};

TestUnit 'objektnamn/femininum' run {
    assertThat(katten.heName).isEqualTo('hon');
    assertThat(katten.himName).isEqualTo('henne');
    assertThat(katten.herName).isEqualTo('hennes');
    assertThat(katten.hersName).isEqualTo('hennes');
};

TestUnit 'objektnamn/plural' run {
    assertThat(vindruvorObjNeutrumPlural.heName).isEqualTo('de');
    assertThat(vindruvorObjNeutrumPlural.himName).isEqualTo('dem');
    assertThat(vindruvorObjNeutrumPlural.herName).isEqualTo('deras');
    assertThat(vindruvorObjNeutrumPlural.hersName).isEqualTo('deras');
};

/* herName för 1:a/2:a person returnerar alltid utrum-formen (pronoun().possAdj) —
 * känd begränsning; {poss actor obj} ger könskongruens istället */
TestUnit 'herName/1a person' run {
    assertThat(spelare1aPerspektiv.herName).isEqualTo('min');
};

TestUnit 'herName/2a person' run {
    assertThat(spelare2aPerspektiv.herName).isEqualTo('din');
};

/* ============================================================
 * thatName / thatObjName
 * ============================================================ */

TestUnit 'thatName/utrum' run {
    assertThat(dorrenObjUtrumSingular.thatName).isEqualTo('den');
    assertThat(dorrenObjUtrumSingular.thatObjName).isEqualTo('den');
};

TestUnit 'thatName/neutrum' run {
    assertThat(skapetObjNeutrumSingular.thatName).isEqualTo('det');
    assertThat(skapetObjNeutrumSingular.thatObjName).isEqualTo('det');
};

TestUnit 'thatName/plural' run {
    assertThat(vindruvorObjNeutrumPlural.thatName).isEqualTo('de');
    assertThat(vindruvorObjNeutrumPlural.thatObjName).isEqualTo('de');
};

/* ============================================================
 * reflexiveName / reflexiveObjName
 * ============================================================ */

TestUnit 'reflexiveName/utrum singular' run {
    assertThat(dorrenObjUtrumSingular.reflexiveName).isEqualTo('sig');
    assertThat(dorrenObjUtrumSingular.reflexiveObjName).isEqualTo('sig själv');
};

TestUnit 'reflexiveName/neutrum singular' run {
    assertThat(skapetObjNeutrumSingular.reflexiveName).isEqualTo('sig');
    assertThat(skapetObjNeutrumSingular.reflexiveObjName).isEqualTo('sig självt');
};

TestUnit 'reflexiveName/maskulinum' run {
    assertThat(hunden.reflexiveName).isEqualTo('sig');
    assertThat(hunden.reflexiveObjName).isEqualTo('sig själv');
};

TestUnit 'reflexiveName/femininum' run {
    assertThat(katten.reflexiveName).isEqualTo('sig');
    assertThat(katten.reflexiveObjName).isEqualTo('sig själv');
};

TestUnit 'reflexiveName/plural' run {
    assertThat(vindruvorObjNeutrumPlural.reflexiveName).isEqualTo('sig');
    assertThat(vindruvorObjNeutrumPlural.reflexiveObjName).isEqualTo('sig själva');
};

TestUnit 'reflexiveName/1a person' run {
    assertThat(spelare1aPerspektiv.reflexiveName).isEqualTo('mig');
    assertThat(spelare1aPerspektiv.reflexiveObjName).isEqualTo('mig själv');
};

TestUnit 'reflexiveName/2a person' run {
    assertThat(spelare2aPerspektiv.reflexiveName).isEqualTo('dig');
    assertThat(spelare2aPerspektiv.reflexiveObjName).isEqualTo('dig själv');
};

/* ============================================================
 * pronounMap — korrekthet efter buggfix för kollisioner
 * ============================================================ */

TestUnit 'pronounMap/du pekar på You' run {
    assertThat(LMentionable.pronounMap['du']).isEqualTo(You);
};

TestUnit 'pronounMap/jag pekar på Me' run {
    assertThat(LMentionable.pronounMap['jag']).isEqualTo(Me);
};

TestUnit 'pronounMap/vi pekar på Us (inte UsAll)' run {
    assertThat(LMentionable.pronounMap['vi']).isEqualTo(Us);
};

TestUnit 'pronounMap/den pekar på It' run {
    assertThat(LMentionable.pronounMap['den']).isEqualTo(It);
};

TestUnit 'pronounMap/det pekar på ItNeuter' run {
    assertThat(LMentionable.pronounMap['det']).isEqualTo(ItNeuter);
};

/* ============================================================
 * possAdjT och possAdjPl på pronomenobjekt
 * ============================================================ */

TestUnit 'possAdjT/You' run {
    assertThat(You.possAdjT).isEqualTo('ditt');
};

TestUnit 'possAdjT/Me' run {
    assertThat(Me.possAdjT).isEqualTo('mitt');
};

TestUnit 'possAdjT/Us' run {
    assertThat(Us.possAdjT).isEqualTo('vårt');
};

TestUnit 'possAdjT/Yall' run {
    assertThat(Yall.possAdjT).isEqualTo('ert');
};

TestUnit 'possAdjPl/You' run {
    assertThat(You.possAdjPl).isEqualTo('dina');
};

TestUnit 'possAdjPl/Me' run {
    assertThat(Me.possAdjPl).isEqualTo('mina');
};

TestUnit 'possAdjPl/Us' run {
    assertThat(Us.possAdjPl).isEqualTo('våra');
};

TestUnit 'possAdjPl/Yall' run {
    assertThat(Yall.possAdjPl).isEqualTo('era');
};

/* 3:e person: possAdjPl == possAdj (invarianta) */
TestUnit 'possAdjPl/3:e person invarianta' run {
    assertThat(It.possAdjPl).isEqualTo('dess');
    assertThat(ItNeuter.possAdjPl).isEqualTo('dess');
    assertThat(Him.possAdjPl).isEqualTo('hans');
    assertThat(Her.possAdjPl).isEqualTo('hennes');
    assertThat(Them.possAdjPl).isEqualTo('deras');
};

/* ============================================================
 * possessify — väljer rätt form utifrån ägt objekts genus/antal
 * ============================================================ */

TestUnit 'possessify/2a person utrum' run {
    assertThat(spelare2aPerspektiv.possessify(Definite, dorrenObjUtrumSingular, 'dörr'))
        .isEqualTo('din dörr');
};

TestUnit 'possessify/2a person neutrum' run {
    assertThat(spelare2aPerspektiv.possessify(Definite, skapetObjNeutrumSingular, 'skåp'))
        .isEqualTo('ditt skåp');
};

TestUnit 'possessify/2a person plural' run {
    assertThat(spelare2aPerspektiv.possessify(Definite, vindruvorObjNeutrumPlural, 'vindruvor'))
        .isEqualTo('dina vindruvor');
};

TestUnit 'possessify/1a person utrum' run {
    assertThat(spelare1aPerspektiv.possessify(Definite, dorrenObjUtrumSingular, 'dörr'))
        .isEqualTo('min dörr');
};

TestUnit 'possessify/1a person neutrum' run {
    assertThat(spelare1aPerspektiv.possessify(Definite, skapetObjNeutrumSingular, 'skåp'))
        .isEqualTo('mitt skåp');
};

TestUnit 'possessify/1a person plural' run {
    assertThat(spelare1aPerspektiv.possessify(Definite, vindruvorObjNeutrumPlural, 'vindruvor'))
        .isEqualTo('mina vindruvor');
};

/* ============================================================
 * {poss ägare ägt} — form baserat på ägt objekts genus/antal
 *
 * {poss} väljer possAdj/possAdjT/possAdjPl från ägaren baserat på
 * ägt.isNeuter och ägt.plural. Testas här via actor.possAdj/T/Pl
 * som är exakt de egenskaper {poss} hämtar via cmdInfo.
 * ============================================================ */

TestUnit 'poss/2a person — utrum ägt' run {
    assertThat(spelare2aPerspektiv.possAdj).isEqualTo('din');
};

TestUnit 'poss/2a person — neutrum ägt' run {
    assertThat(spelare2aPerspektiv.possAdjT).isEqualTo('ditt');
};

TestUnit 'poss/2a person — plural ägt' run {
    assertThat(spelare2aPerspektiv.possAdjPl).isEqualTo('dina');
};

TestUnit 'poss/1a person — utrum ägt' run {
    assertThat(spelare1aPerspektiv.possAdj).isEqualTo('min');
};

TestUnit 'poss/1a person — neutrum ägt' run {
    assertThat(spelare1aPerspektiv.possAdjT).isEqualTo('mitt');
};

TestUnit 'poss/1a person — plural ägt' run {
    assertThat(spelare1aPerspektiv.possAdjPl).isEqualTo('mina');
};

/* ============================================================
 * {poss} stränginterpolation — verifierar hela expansionspipelinen
 * ============================================================ */

TestUnit 'poss/stränginterpolation — 1a och 2a person' run {
  [
      [spelare1aPerspektiv, dorrenObjUtrumSingular,    'min']
    , [spelare1aPerspektiv, skapetObjNeutrumSingular,  'mitt']
    , [spelare1aPerspektiv, vindruvorObjNeutrumPlural, 'mina']
    , [spelare2aPerspektiv, dorrenObjUtrumSingular,    'din']
    , [spelare2aPerspektiv, skapetObjNeutrumSingular,  'ditt']
    , [spelare2aPerspektiv, vindruvorObjNeutrumPlural, 'dina']
  ].forEach(function(row) {
    assertThat(bmsg('{poss 1 2}', row[1], row[2])).isEqualTo(row[3]);
  });
};

TestUnit 'poss/stränginterpolation — 3:e person (invariant)' run {
  [
      [Him,  dorrenObjUtrumSingular,    'hans']
    , [Her,  skapetObjNeutrumSingular,  'hennes']
    , [It,   dorrenObjUtrumSingular,    'dess']
    , [Them, vindruvorObjNeutrumPlural, 'deras']
  ].forEach(function(row) {
    assertThat(bmsg('{poss 1 2}', row[1], row[2])).isEqualTo(row[3]);
  });
};

/* ============================================================
 * aNameFrom — obestämd artikel baserat på genus/antal/massNoun
 * ============================================================ */

TestUnit 'aNameFrom/utrum singular' run {
    assertThat(dorrenObjUtrumSingular.aName).isEqualTo('en dörr');
};

TestUnit 'aNameFrom/neutrum singular' run {
    assertThat(skapetObjNeutrumSingular.aName).isEqualTo('ett skåp');
};

TestUnit 'aNameFrom/plural' run {
    assertThat(vindruvorObjNeutrumPlural.aName).isEqualTo('några vindruvor');
};

TestUnit 'aNameFrom/egennamn (qualified → ingen artikel)' run {
    assertThat(spelare3ePerspektiv.aName).isEqualTo('Bob');
};

TestUnit 'aNameFrom/massNoun (ingen artikel)' run {
    assertThat(mjolkMassNoun.aName).isEqualTo('mjölk');
};

/* ============================================================
 * theNameFrom — bestämd form / possessiv / egennamn
 * ============================================================ */

TestUnit 'theNameFrom/utrum singular' run {
    assertThat(dorrenObjUtrumSingular.theName).isEqualTo('dörren');
};

TestUnit 'theNameFrom/neutrum singular' run {
    assertThat(skapetObjNeutrumSingular.theName).isEqualTo('skåpet');
};

TestUnit 'theNameFrom/plural' run {
    assertThat(vindruvorObjNeutrumPlural.theName).isEqualTo('vindruvorna');
};

TestUnit 'theNameFrom/egennamn (qualified → bare name)' run {
    assertThat(spelare3ePerspektiv.theName).isEqualTo('Bob');
};

TestUnit 'theNameFrom/ownerNamed utrum' run {
    assertThat(nasanObjUtrumSingular.theName).isEqualTo('din näsa');
};

TestUnit 'theNameFrom/ownerNamed neutrum' run {
    assertThat(bobsHarObjNeutrumSingular.theName).isEqualTo('hans hår');
};

TestUnit 'theNameFrom/ownerNamed plural' run {
    assertThat(bobsOgonObjNeutrumPlural.theName).isEqualTo('hans ögon');
};

TestUnit 'theNameFrom/ownerNamed Component utrum' run {
    assertThat(spelareNasaComp.theName).isEqualTo('din näsa');
};

TestUnit 'theNameFrom/ownerNamed 2:a person plural' run {
    assertThat(spelareHanderObj.theName).isEqualTo('dina händer');
};

/* ============================================================
 * possEnding — namnbaserade NPC-ägare
 * ============================================================ */

TestUnit 'possEnding/konsonantslut (Gösta → Göstas)' run {
    assertThat(gostaActor.possEnding).isEqualTo('s');
    assertThat(gostaActor.possAdj).isEqualTo('Göstas');
};

TestUnit 'possEnding/s-slut (Jonas → Jonas, inget extra s)' run {
    assertThat(jonasActor.possEnding).isEqualTo('');
    assertThat(jonasActor.possAdj).isEqualTo('Jonas');
};

TestUnit 'possEnding/bestämd form (penntecknaren → penntecknarens)' run {
    assertThat(penntecknareActor.theName).isEqualTo('penntecknaren');
    assertThat(penntecknareActor.possEnding).isEqualTo('s');
    assertThat(penntecknareActor.possAdj).isEqualTo('penntecknarens');
};

/* ============================================================
 * theNameFrom/ownerNamed — NPC-ägda objekt använder pronomenform
 * ============================================================ */

// Båda ger 'hans mössa' — theNameFrom använder ägarens pronomen, inte namnformen
TestUnit 'theNameFrom/ownerNamed NPC konsonantslut (hans mössa — Gösta)' run {
    assertThat(gostasMossaObj.theName).isEqualTo('hans mössa');
};

TestUnit 'theNameFrom/ownerNamed NPC s-slut (hans mössa — Jonas)' run {
    assertThat(jonasMossaObj.theName).isEqualTo('hans mössa');
};

/* ============================================================
 * possessify — NPC-ägare med namnbaserad possessivform
 * ============================================================ */

TestUnit 'possessify/NPC konsonantslut utrum (Göstas dörr)' run {
    assertThat(gostaActor.possessify(Definite, dorrenObjUtrumSingular, 'dörr'))
        .isEqualTo('Göstas dörr');
};

TestUnit 'possessify/NPC konsonantslut neutrum (Göstas skåp)' run {
    assertThat(gostaActor.possessify(Definite, skapetObjNeutrumSingular, 'skåp'))
        .isEqualTo('Göstas skåp');
};

TestUnit 'possessify/NPC konsonantslut plural (Göstas vindruvor)' run {
    assertThat(gostaActor.possessify(Definite, vindruvorObjNeutrumPlural, 'vindruvor'))
        .isEqualTo('Göstas vindruvor');
};

TestUnit 'possessify/NPC s-slut utrum (Jonas dörr)' run {
    assertThat(jonasActor.possessify(Definite, dorrenObjUtrumSingular, 'dörr'))
        .isEqualTo('Jonas dörr');
};

TestUnit 'possessify/NPC bestämd form (penntecknarens dörr)' run {
    assertThat(penntecknareActor.possessify(Definite, dorrenObjUtrumSingular, 'dörr'))
        .isEqualTo('penntecknarens dörr');
};

/* ============================================================
 * aName — ownerNamed påverkar INTE aName (returnerar obestämd form)
 * ============================================================ */

TestUnit 'aName/ownerNamed utrum (en näsa)' run {
    assertThat(nasanObjUtrumSingular.aName).isEqualTo('en näsa');
};

TestUnit 'aName/ownerNamed neutrum (ett hår)' run {
    assertThat(bobsHarObjNeutrumSingular.aName).isEqualTo('ett hår');
};

TestUnit 'aName/ownerNamed plural (några ögon)' run {
    assertThat(bobsOgonObjNeutrumPlural.aName).isEqualTo('några ögon');
};

TestUnit 'aName/ownerNamed 2:a person plural (några händer)' run {
    assertThat(spelareHanderObj.aName).isEqualTo('några händer');
};

/* ============================================================
 * langAdjust — omskrivning rot{mönster} → {conjadj rot mönster}
 * ============================================================ */

TestUnit 'langAdjust/grundfall' run {
    assertThat(langAdjust('är öppen{t/a}')).isEqualTo('är {conjadj öppen t/a}');
    assertThat(langAdjust('redan tän{d/t/da}')).isEqualTo('redan {conjadj tän d/t/da}');
    assertThat(langAdjust('vara öpp{en/et/na}')).isEqualTo('vara {conjadj öpp en/et/na}');
};

TestUnit 'langAdjust/verbmönster' run {
    assertThat(langAdjust('öppn{ar/ade/at}')).isEqualTo('{conj öppn ar/ade/at}');
    assertThat(langAdjust('tryck{er/te/t}')).isEqualTo('{conj tryck er/te/t}');
    assertThat(langAdjust('lev{er/de/t}')).isEqualTo('{conj lev er/de/t}');
    assertThat(langAdjust('bo{r/dde/tt}')).isEqualTo('{conj bo r/dde/tt}');
    // Befintliga tvåformsmönster ska inte påverkas av verbregexen
    assertThat(langAdjust('tryck{er/te}')).isEqualTo('tryck{er/te}');
};

TestUnit 'conjugateSwedish/grupp1 — öppn{ar/ade/at}' run {
    local saved = Narrator.tense;
    Narrator.tense = Present;     assertThat(bmsg('öppn{ar/ade/at}')).isEqualTo('öppnar');
    Narrator.tense = Past;        assertThat(bmsg('öppn{ar/ade/at}')).isEqualTo('öppnade');
    Narrator.tense = Perfect;     assertThat(bmsg('öppn{ar/ade/at}')).isEqualTo('har öppnat');
    Narrator.tense = PastPerfect; assertThat(bmsg('öppn{ar/ade/at}')).isEqualTo('hade öppnat');
    Narrator.tense = Future;      assertThat(bmsg('öppn{ar/ade/at}')).isEqualTo('ska öppna');
    Narrator.tense = FuturePerfect; assertThat(bmsg('öppn{ar/ade/at}')).isEqualTo('ska ha öppnat');
    Narrator.tense = saved;
};

TestUnit 'conjugateSwedish/grupp2a — tryck{er/te/t}' run {
    local saved = Narrator.tense;
    Narrator.tense = Present;     assertThat(bmsg('tryck{er/te/t}')).isEqualTo('trycker');
    Narrator.tense = Past;        assertThat(bmsg('tryck{er/te/t}')).isEqualTo('tryckte');
    Narrator.tense = Perfect;     assertThat(bmsg('tryck{er/te/t}')).isEqualTo('har tryckt');
    Narrator.tense = Future;      assertThat(bmsg('tryck{er/te/t}')).isEqualTo('ska trycka');
    Narrator.tense = saved;
};

TestUnit 'conjugateSwedish/grupp2b — lev{er/de/t}' run {
    local saved = Narrator.tense;
    Narrator.tense = Present;     assertThat(bmsg('lev{er/de/t}')).isEqualTo('lever');
    Narrator.tense = Past;        assertThat(bmsg('lev{er/de/t}')).isEqualTo('levde');
    Narrator.tense = Perfect;     assertThat(bmsg('lev{er/de/t}')).isEqualTo('har levt');
    Narrator.tense = Future;      assertThat(bmsg('lev{er/de/t}')).isEqualTo('ska leva');
    Narrator.tense = saved;
};

TestUnit 'conjugateSwedish/grupp3 — bo{r/dde/tt}' run {
    local saved = Narrator.tense;
    Narrator.tense = Present;     assertThat(bmsg('bo{r/dde/tt}')).isEqualTo('bor');
    Narrator.tense = Past;        assertThat(bmsg('bo{r/dde/tt}')).isEqualTo('bodde');
    Narrator.tense = Perfect;     assertThat(bmsg('bo{r/dde/tt}')).isEqualTo('har bott');
    Narrator.tense = Future;      assertThat(bmsg('bo{r/dde/tt}')).isEqualTo('ska bo');
    Narrator.tense = saved;
};

TestUnit 'langAdjust/kantfall — ord i position 1' run {
    // [^ {}]+ ska fånga hela roten inklusive första tecknet och svenska tecken
    assertThat(langAdjust('Tag{en/et/na}')).isEqualTo('{conjadj Tag en/et/na}');
    assertThat(langAdjust('Öpp{en/et/na}')).isEqualTo('{conjadj Öpp en/et/na}');
    assertThat(langAdjust('tung{t/a}')).isEqualTo('{conjadj tung t/a}');
    assertThat(langAdjust('tän{d/t/da}')).isEqualTo('{conjadj tän d/t/da}');
};

TestUnit 'langAdjust/nya mönster n/t/na och ad/at/ade' run {
    assertThat(langAdjust('skriv{n/t/na}')).isEqualTo('{conjadj skriv n/t/na}');
    assertThat(langAdjust('ladd{ad/at/ade}')).isEqualTo('{conjadj ladd ad/at/ade}');
};

/* ============================================================
 * Substitutionstoken — direkttester via bmsg
 * ============================================================ */

/* Pronomen: {han}, {honom} */
TestUnit 'pronomen/han — heName per genus' run {
    assertThat(bmsg('{han 1}', dorrenObjUtrumSingular)).isEqualTo('den');
    assertThat(bmsg('{han 1}', skapetObjNeutrumSingular)).isEqualTo('det');
    assertThat(bmsg('{han 1}', hunden)).isEqualTo('han');
    assertThat(bmsg('{han 1}', katten)).isEqualTo('hon');
    assertThat(bmsg('{han 1}', vindruvorObjNeutrumPlural)).isEqualTo('de');
};

TestUnit 'pronomen/honom — himName per genus' run {
    assertThat(bmsg('{honom 1}', dorrenObjUtrumSingular)).isEqualTo('den');
    assertThat(bmsg('{honom 1}', skapetObjNeutrumSingular)).isEqualTo('det');
    assertThat(bmsg('{honom 1}', hunden)).isEqualTo('honom');
    assertThat(bmsg('{honom 1}', katten)).isEqualTo('henne');
    assertThat(bmsg('{honom 1}', vindruvorObjNeutrumPlural)).isEqualTo('dem');
};

/* Pronomen: {hans}, {hennes}, {dess}, {deras} — alla mappar till herName */
TestUnit 'pronomen/hans dess deras hennes — herName' run {
    assertThat(bmsg('{hans 1}', hunden)).isEqualTo('hans');
    assertThat(bmsg('{hennes 1}', katten)).isEqualTo('hennes');
    assertThat(bmsg('{dess 1}', dorrenObjUtrumSingular)).isEqualTo('dess');
    assertThat(bmsg('{deras 1}', vindruvorObjNeutrumPlural)).isEqualTo('deras');
};

/* Pronomen: {sigsjälv} — emfatisk reflexiv form */
TestUnit 'pronomen/sigsjälv — reflexivt objekt per person' run {
    assertThat(bmsg('{sigsjälv 1}', dorrenObjUtrumSingular)).isEqualTo('sig själv');
    assertThat(bmsg('{sigsjälv 1}', skapetObjNeutrumSingular)).isEqualTo('sig självt');
    assertThat(bmsg('{sigsjälv 1}', vindruvorObjNeutrumPlural)).isEqualTo('sig själva');
    assertThat(bmsg('{sigsjälv 1}', spelare1aPerspektiv)).isEqualTo('mig själv');
    assertThat(bmsg('{sigsjälv 1}', spelare2aPerspektiv)).isEqualTo('dig själv');
};

/* {ref subj 1} och {ref 1} — bestämd form subjekt/objekt */
TestUnit 'ref/subj och obj form via arg' run {
    assertThat(bmsg('{ref subj 1}', dorrenObjUtrumSingular)).isEqualTo('dörren');
    assertThat(bmsg('{ref 1}', dorrenObjUtrumSingular)).isEqualTo('dörren');
    assertThat(bmsg('{ref subj 1}', skapetObjNeutrumSingular)).isEqualTo('skåpet');
    assertThat(bmsg('{ref 1}', vindruvorObjNeutrumPlural)).isEqualTo('vindruvorna');
};

/* {ett subj 1} / {en subj 1} — obestämd form */
TestUnit 'ett/en — obestämd form via arg' run {
    assertThat(bmsg('{ett subj 1}', dorrenObjUtrumSingular)).isEqualTo('en dörr');
    assertThat(bmsg('{ett subj 1}', skapetObjNeutrumSingular)).isEqualTo('ett skåp');
    assertThat(bmsg('{en subj 1}', dorrenObjUtrumSingular)).isEqualTo('en dörr');
    assertThat(bmsg('{ett subj 1}', vindruvorObjNeutrumPlural)).isEqualTo('några vindruvor');
};

/* Hjälpverb — presens och preteritum
 * {dummy} krävs för att hjälpverben konjugerar efter grammatiskt subjekt
 * (ctx.subj); utan det saknas ctx.subj och konjugeringen kraschar. */
TestUnit 'hjälpverb/är — presens och preteritum' run {
    local saved = Narrator.tense;
    gCommand = new Command(spelare2aPerspektiv, Examine, dorrenObjUtrumSingular);
    Narrator.tense = Present; assertThat(bmsg('{dummy}{är}.')).isEqualTo('är.');
    Narrator.tense = Past;    assertThat(bmsg('{dummy}{är}.')).isEqualTo('var.');
    Narrator.tense = saved;
};

/* {ärinte}, {varinte}, {harinte}, {kaninte} är enkelsporstokens (mellanslag i
 * tokennamn fungerar inte — paramTab-uppslagning tar bara första ordet). */
TestUnit 'hjälpverb/ärinte — presens, preteritum, perfekt' run {
    local saved = Narrator.tense;
    gCommand = new Command(spelare2aPerspektiv, Examine, dorrenObjUtrumSingular);
    Narrator.tense = Present; assertThat(bmsg('{dummy}{ärinte}.')).isEqualTo('är inte.');
    Narrator.tense = Past;    assertThat(bmsg('{dummy}{ärinte}.')).isEqualTo('var inte.');
    Narrator.tense = Perfect; assertThat(bmsg('{dummy}{ärinte}.')).isEqualTo('har inte varit.');
    Narrator.tense = saved;
};

TestUnit 'hjälpverb/kan — alla tempus' run {
    local saved = Narrator.tense;
    gCommand = new Command(spelare2aPerspektiv, Examine, dorrenObjUtrumSingular);
    Narrator.tense = Present;       assertThat(bmsg('{dummy}{kan} öppna.')).isEqualTo('kan öppna.');
    Narrator.tense = Past;          assertThat(bmsg('{dummy}{kan} öppna.')).isEqualTo('kunde öppna.');
    Narrator.tense = Perfect;       assertThat(bmsg('{dummy}{kan} öppna.')).isEqualTo('har kunnat öppna.');
    Narrator.tense = PastPerfect;   assertThat(bmsg('{dummy}{kan} öppna.')).isEqualTo('hade kunnat öppna.');
    Narrator.tense = Future;        assertThat(bmsg('{dummy}{kan} öppna.')).isEqualTo('kommer att kunna öppna.');
    Narrator.tense = FuturePerfect; assertThat(bmsg('{dummy}{kan} öppna.')).isEqualTo('kommer att ha kunnat öppna.');
    Narrator.tense = saved;
};

TestUnit 'hjälpverb/kaninte — alla tempus' run {
    local saved = Narrator.tense;
    gCommand = new Command(spelare2aPerspektiv, Examine, dorrenObjUtrumSingular);
    Narrator.tense = Present;       assertThat(bmsg('{dummy}{kaninte} öppna.')).isEqualTo('kan inte öppna.');
    Narrator.tense = Past;          assertThat(bmsg('{dummy}{kaninte} öppna.')).isEqualTo('kunde inte öppna.');
    Narrator.tense = Perfect;       assertThat(bmsg('{dummy}{kaninte} öppna.')).isEqualTo('har inte kunnat öppna.');
    Narrator.tense = PastPerfect;   assertThat(bmsg('{dummy}{kaninte} öppna.')).isEqualTo('hade inte kunnat öppna.');
    Narrator.tense = Future;        assertThat(bmsg('{dummy}{kaninte} öppna.')).isEqualTo('kommer inte att kunna öppna.');
    Narrator.tense = FuturePerfect; assertThat(bmsg('{dummy}{kaninte} öppna.')).isEqualTo('kommer inte att ha kunnat öppna.');
    Narrator.tense = saved;
};

TestUnit 'hjälpverb/måste — presens och preteritum' run {
    local saved = Narrator.tense;
    gCommand = new Command(spelare2aPerspektiv, Examine, dorrenObjUtrumSingular);
    Narrator.tense = Present; assertThat(bmsg('{dummy}{måste öppna}.')).isEqualTo('måste öppna.');
    Narrator.tense = Past;    assertThat(bmsg('{dummy}{måste öppna}.')).isEqualTo('var tvungen att öppna.');
    Narrator.tense = saved;
};

TestUnit 'hjälpverb/harinte — presens och preteritum' run {
    local saved = Narrator.tense;
    gCommand = new Command(spelare2aPerspektiv, Examine, dorrenObjUtrumSingular);
    Narrator.tense = Present; assertThat(bmsg('{dummy}{harinte}.')).isEqualTo('har inte.');
    Narrator.tense = Past;    assertThat(bmsg('{dummy}{harinte}.')).isEqualTo('hade inte.');
    Narrator.tense = saved;
};

/* Determiner — genus-kongruens */
/* {den}, {det} och {de} är synonyma determinativer — väljer den/det/de baserat på
 * dobj:s genus/numerus. {de} utan argument fungerar som determinativ; med argument
 * fungerar det som pronomenet {de obj}. */
TestUnit 'determinativ/den-det-de — alla utfall per genus' run {
    local tokens = ['{den}', '{det}', '{de}'];
    [   [dorrenObjUtrumSingular,   'den']
      , [skapetObjNeutrumSingular, 'det']
      , [vindruvorObjNeutrumPlural, 'de']
    ].forEach(function(row) {
        gCommand = new Command(spelare2aPerspektiv, Examine, row[1]);
        tokens.forEach(function(tok) {
            assertThat(bmsg(tok)).isEqualTo(row[2]);
        });
    });
};

/* {de obj} och {dem obj} — pronomenvarianter för samma token.
 * {de} utan argument: determinativ (se ovan). {de obj} med argument: subjektivt pronomen.
 * {dem obj}: objektiv form. Kongruerar med obj:s genus och numerus på samma sätt
 * som {han obj}/{honom obj}, men passar naturligare när referensen är plural. */
TestUnit 'pronomen/de-dem — subjektiv och objektiv pronomform' run {
    // Saker utan genus → den/den
    assertThat(bmsg('{de 1}',  dorrenObjUtrumSingular)).isEqualTo('den');
    assertThat(bmsg('{dem 1}', dorrenObjUtrumSingular)).isEqualTo('den');
    // Neutrum sak → det/det
    assertThat(bmsg('{de 1}',  skapetObjNeutrumSingular)).isEqualTo('det');
    assertThat(bmsg('{dem 1}', skapetObjNeutrumSingular)).isEqualTo('det');
    // Plural → de/dem — det typiska användningsfallet
    assertThat(bmsg('{de 1}',  vindruvorObjNeutrumPlural)).isEqualTo('de');
    assertThat(bmsg('{dem 1}', vindruvorObjNeutrumPlural)).isEqualTo('dem');
    // Maskulin person → han/honom
    assertThat(bmsg('{de 1}',  hunden)).isEqualTo('han');
    assertThat(bmsg('{dem 1}', hunden)).isEqualTo('honom');
    // Feminin person → hon/henne
    assertThat(bmsg('{de 1}',  katten)).isEqualTo('hon');
    assertThat(bmsg('{dem 1}', katten)).isEqualTo('henne');
};

TestUnit 'determinativ/denna — denna/detta/dessa per genus' run {
    gCommand = new Command(spelare2aPerspektiv, Examine, dorrenObjUtrumSingular);
    assertThat(bmsg('{denna}')).isEqualTo('denna');
    gCommand = new Command(spelare2aPerspektiv, Examine, skapetObjNeutrumSingular);
    assertThat(bmsg('{denna}')).isEqualTo('detta');
    gCommand = new Command(spelare2aPerspektiv, Examine, vindruvorObjNeutrumPlural);
    assertThat(bmsg('{denna}')).isEqualTo('dessa');
};

TestUnit 'determinativ/denhär — den här/det här/de här per genus' run {
    gCommand = new Command(spelare2aPerspektiv, Examine, dorrenObjUtrumSingular);
    assertThat(bmsg('{denhär}')).isEqualTo('den här');
    gCommand = new Command(spelare2aPerspektiv, Examine, skapetObjNeutrumSingular);
    assertThat(bmsg('{denhär}')).isEqualTo('det här');
    gCommand = new Command(spelare2aPerspektiv, Examine, vindruvorObjNeutrumPlural);
    assertThat(bmsg('{denhär}')).isEqualTo('de här');
};

/* Prepositioner */
TestUnit 'prepositioner/i inuti utur inprep' run {
    assertThat(bmsg('{i 1}', korgen)).isEqualTo('i korgen');
    assertThat(bmsg('{inuti 1}', korgen)).isEqualTo('in i korgen');
    assertThat(bmsg('{utur 1}', korgen)).isEqualTo('ut ur korgen');
    assertThat(bmsg('{platsprep 1}', korgen)).isEqualTo('i');
};

/* Platsadverb — tempusberoende */
TestUnit 'platsadverb/här och då' run {
    local saved = Narrator.tense;
    gCommand = new Command(spelare2aPerspektiv, Examine, dorrenObjUtrumSingular);
    Narrator.tense = Present;
    assertThat(bmsg('{här}')).isEqualTo('här');
    assertThat(bmsg('{då}')).isEqualTo('nu');
    assertThat(bmsg('{nu}')).isEqualTo('nu');
    Narrator.tense = Past;
    assertThat(bmsg('{här}')).isEqualTo('där');
    assertThat(bmsg('{då}')).isEqualTo('då');
    Narrator.tense = saved;
};

/* Listor och argument */
TestUnit 'listor/1 och 2 — argument' run {
    assertThat(bmsg('{1}', dorrenObjUtrumSingular)).isEqualTo('dörren');
    assertThat(bmsg('{1}, {2}', dorrenObjUtrumSingular, skapetObjNeutrumSingular))
        .isEqualTo('dörren, skåpet');
};

TestUnit 'listor/# N — stavat tal' run {
    assertThat(bmsg('{# 1}', 3)).isEqualTo('tre');
    assertThat(bmsg('{# 1}', 1)).isEqualTo('ett');  // neutrumform utan genuskontext
};

TestUnit 'listor/och N — och-lista' run {
    assertThat(bmsg('{och 1}', ['äpplet', 'dörren', 'skåpet']))
        .isEqualTo('äpplet, dörren och skåpet');
    assertThat(bmsg('{och 1}', ['äpplet', 'dörren']))
        .isEqualTo('äpplet och dörren');
};

TestUnit 'listor/eller N — eller-lista' run {
    assertThat(bmsg('{eller 1}', ['äpplet', 'dörren']))
        .isEqualTo('äpplet eller dörren');
};

/* Literals */
TestUnit 'literals/lb rb bar' run {
    assertThat(bmsg('{lb}test{rb}')).isEqualTo('{test}');
    assertThat(bmsg('a{bar}b')).isEqualTo('a|b');
};

/* Adjektivkongruens — saknade mönster a, n/t/na, ad/at/ade */
TestUnit 'adjektiv/{a} — oförändrat utrum/neutrum, +a plural' run {
    gCommand = new Command(spelare2aPerspektiv, Examine, dorrenObjUtrumSingular);
    assertThat(bmsg('låst{a}')).isEqualTo('låst');
    gCommand = new Command(spelare2aPerspektiv, Examine, skapetObjNeutrumSingular);
    assertThat(bmsg('låst{a}')).isEqualTo('låst');
    gCommand = new Command(spelare2aPerspektiv, Examine, vindruvorObjNeutrumPlural);
    assertThat(bmsg('låst{a}')).isEqualTo('låsta');
};

/* {n/t/na}: rot+n/t/na — för ord som sann/sant/sanna (ej skriven, som är {en/et/na}) */
TestUnit 'adjektiv/{n/t/na} — sann/sant/sanna' run {
    gCommand = new Command(spelare2aPerspektiv, Examine, dorrenObjUtrumSingular);
    assertThat(bmsg('san{n/t/na}')).isEqualTo('sann');
    gCommand = new Command(spelare2aPerspektiv, Examine, skapetObjNeutrumSingular);
    assertThat(bmsg('san{n/t/na}')).isEqualTo('sant');
    gCommand = new Command(spelare2aPerspektiv, Examine, vindruvorObjNeutrumPlural);
    assertThat(bmsg('san{n/t/na}')).isEqualTo('sanna');
};

TestUnit 'adjektiv/{ad/at/ade} — laddad/laddat/laddade' run {
    gCommand = new Command(spelare2aPerspektiv, Examine, dorrenObjUtrumSingular);
    assertThat(bmsg('ladd{ad/at/ade}')).isEqualTo('laddad');
    gCommand = new Command(spelare2aPerspektiv, Examine, skapetObjNeutrumSingular);
    assertThat(bmsg('ladd{ad/at/ade}')).isEqualTo('laddat');
    gCommand = new Command(spelare2aPerspektiv, Examine, vindruvorObjNeutrumPlural);
    assertThat(bmsg('ladd{ad/at/ade}')).isEqualTo('laddade');
};

/* {sigsjälv dobj} — emfatisk reflexiv i meddelandemallar */
TestUnit 'reflexiv/{sigsjälv} — utrum, neutrum, plural' run {
    gCommand = new Command(spelare2aPerspektiv, Examine, dorrenObjUtrumSingular);
    assertThat(bmsg('{sigsjälv dobj}')).isEqualTo('sig själv');
    gCommand = new Command(spelare2aPerspektiv, Examine, skapetObjNeutrumSingular);
    assertThat(bmsg('{sigsjälv dobj}')).isEqualTo('sig självt');
    gCommand = new Command(spelare2aPerspektiv, Examine, vindruvorObjNeutrumPlural);
    assertThat(bmsg('{sigsjälv dobj}')).isEqualTo('sig själva');
};

/* ============================================================
 * aNameFromPoss — obestämd artikel för possessivt formaterad sträng.
 * Anropas efter possessify() som redan format strängen, t.ex.
 * 'dörr av Bob' → 'en dörr av Bob'.
 * För plural/massNoun: 'vindruvor av Bob' → 'några av vindruvor av Bob'.
 * ============================================================ */

TestUnit 'aNameFromPoss/singular utrum' run {
    assertThat(dorrenObjUtrumSingular.aNameFromPoss('dörr av Bob'))
        .isEqualTo('en dörr av Bob');
};

TestUnit 'aNameFromPoss/singular neutrum' run {
    assertThat(skapetObjNeutrumSingular.aNameFromPoss('skåp av Bob'))
        .isEqualTo('ett skåp av Bob');
};

TestUnit 'aNameFromPoss/plural' run {
    // plural → 'några av' prefixeras till den possessiva strängen
    assertThat(vindruvorObjNeutrumPlural.aNameFromPoss('vindruvor av Bob'))
        .isEqualTo('några av vindruvor av Bob');
};

/* ============================================================
 * distinguishedName — returnerar namn med rätt artikel och
 * eventuella distinguisher-kvalificerare.
 * Utan distinguishers: bara basnamn + artikel.
 * ============================================================ */

TestUnit 'distinguishedName/singular utrum' run {
    local used = new Vector(10);
    assertThat(dorrenObjUtrumSingular.distinguishedName(Indefinite, used)).isEqualTo('en dörr');
    assertThat(dorrenObjUtrumSingular.distinguishedName(Definite, used)).isEqualTo('dörren');
    assertThat(dorrenObjUtrumSingular.distinguishedName(Unqualified, used)).isEqualTo('dörr');
};

TestUnit 'distinguishedName/singular neutrum' run {
    local used = new Vector(10);
    assertThat(skapetObjNeutrumSingular.distinguishedName(Indefinite, used)).isEqualTo('ett skåp');
    assertThat(skapetObjNeutrumSingular.distinguishedName(Definite, used)).isEqualTo('skåpet');
    assertThat(skapetObjNeutrumSingular.distinguishedName(Unqualified, used)).isEqualTo('skåp');
};

TestUnit 'distinguishedName/plural' run {
    local used = new Vector(10);
    assertThat(vindruvorObjNeutrumPlural.distinguishedName(Indefinite, used)).isEqualTo('några vindruvor');
    assertThat(vindruvorObjNeutrumPlural.distinguishedName(Definite, used)).isEqualTo('vindruvorna');
    assertThat(vindruvorObjNeutrumPlural.distinguishedName(Unqualified, used)).isEqualTo('vindruvor');
};

/* ============================================================
 * pluralWordFrom — slår upp pluralform för ett enstaka ord.
 * Ordning: irregularPlurals → -man→-män → tom sträng → skelett.
 *
 * GRÖNA: ord kvar i irregularPlurals (umlaut, rotvokalfall, latinska
 *        specialformer, oförändrad plural, dubbla former) + menPluralPat.
 * RÖDA:  regelbundna ord borttagna ur irregularPlurals; skelettet
 *        returnerar dem oförändrat tills -or/-ar/-er/lånord-regler
 *        implementeras.
 * ============================================================ */

/* --- GRÖNA: umlautpluraler --- */

TestUnit 'pluralWordFrom/umlaut' run {
    [   ['fot', 'fötter'], ['gås', 'gäss'],    ['lus', 'löss']
      , ['mus', 'möss'],   ['tand', 'tänder'], ['tång', 'tänger']
    ].forEach(function(row) {
        assertThat(LMentionable.pluralWordFrom(row[1])).isEqualTo(row[2]);
    });
};

/* --- GRÖNA: inbyggt -man → -män mönster --- */

TestUnit 'pluralWordFrom/man→männ' run {
    assertThat(LMentionable.pluralWordFrom('man')).isEqualTo('män');
    assertThat(LMentionable.pluralWordFrom('brandman')).isEqualTo('brandmän');
};

/* --- GRÖNA: rotvokalfall (vokal faller bort: virvl-, axl-) --- */

TestUnit 'pluralWordFrom/rotvokalfall' run {
    assertThat(LMentionable.pluralWordFrom('virvel')).isEqualTo('virvlar');
    assertThat(LMentionable.pluralWordFrom('axel')).isEqualTo('axlar');
};

/* --- GRÖNA: latinska specialformer som avviker från svenska regler --- */

TestUnit 'pluralWordFrom/latinska specialformer' run {
    assertThat(LMentionable.pluralWordFrom('schema')).isEqualTo('scheman');
    assertThat(LMentionable.pluralWordFrom('kriterium')).isEqualTo('kriterier');
    assertThat(LMentionable.pluralWordFrom('symposium')).isEqualTo('symposier');
    assertThat(LMentionable.pluralWordFrom('memorandum')).isEqualTo('memorandum');
};

/* --- GRÖNA: oförändrad plural (grupp 5) --- */

TestUnit 'pluralWordFrom/oförändrad' run {
    [   'ägg', 'blad', 'byxor', 'data', 'fel', 'fenomen', 'får'
      , 'glasögon', 'högkvarter', 'index', 'kläder', 'lager', 'liv'
      , 'medel', 'möbler', 'själv', 'shorts', 'slut', 'tillägg'
    ].forEach(function(w) {
        assertThat(LMentionable.pluralWordFrom(w)).isEqualTo(w);
    });
};

/* --- GRÖNA: dubbla former — returnerar föredragen (första) form --- */

TestUnit 'pluralWordFrom/dubbla former' run {
    assertThat(LMentionable.pluralWordFrom('fisk')).isEqualTo('fisk');
    assertThat(LMentionable.pluralWordFrom('hjort')).isEqualTo('hjort');
    assertThat(LMentionable.pluralWordFrom('öring')).isEqualTo('öring');
    assertThat(LMentionable.pluralWordFrom('torsk')).isEqualTo('torsk');
};

TestUnit 'pluralWordFrom/tom sträng' run {
    assertThat(LMentionable.pluralWordFrom('')).isEqualTo('');
};

/* --- RÖDA: grupp 1, -a → -or --- */

TestUnit 'pluralWordFrom/grupp-1-or' run {
    [   ['älva', 'älvor'],    ['halva', 'halvor'],      ['limpa', 'limpor']
      , ['skärva', 'skärvor'], ['hylla', 'hyllor'],     ['bokhylla', 'bokhyllor']
      , ['kärna', 'kärnor'],  ['avkomma', 'avkommor']
    ].forEach(function(row) {
        assertThat(LMentionable.pluralWordFrom(row[1])).isEqualTo(row[2]);
    });
};

/* --- RÖDA: grupp 2, → -ar --- */

TestUnit 'pluralWordFrom/grupp-2-ar' run {
    [   ['svamp', 'svampar'],     ['bläckfisk', 'bläckfiskar'], ['sax', 'saxar']
      , ['kaktus', 'kaktusar'],   ['galge', 'galgar'],          ['tärning', 'tärningar']
      , ['korsväg', 'korsvägar'], ['barack', 'baracker'],       ['sammanfattning', 'sammanfattningar']
      , ['avhandling', 'avhandlingar'], ['betoning', 'betoningar']
      , ['dörr', 'dörrar'],       ['hund', 'hundar']
    ].forEach(function(row) {
        assertThat(LMentionable.pluralWordFrom(row[1])).isEqualTo(row[2]);
    });
};

/* --- RÖDA: grupp 3, → -er --- */

TestUnit 'pluralWordFrom/grupp-3-er' run {
    [   ['analys', 'analyser'],     ['kris', 'kriser'],         ['diagnos', 'diagnoser']
      , ['hypotes', 'hypoteser'],   ['neuros', 'neuroser'],     ['parentes', 'parenteser']
      , ['stimulans', 'stimulanser'], ['bas', 'baser'],         ['larv', 'larver']
      , ['alg', 'alger'],           ['ryggrad', 'ryggrader'],   ['bacill', 'baciller']
      , ['matris', 'matriser'],     ['läroplan', 'läroplaner'], ['bakterie', 'bakterier']
      , ['radie', 'radier'],        ['serie', 'serier'],        ['art', 'arter']
      , ['kerub', 'keruber'],       ['seraf', 'serafer'],       ['virtuos', 'virtuoser']
      , ['sopran', 'sopraner'],     ['bilaga', 'bilagor'],      ['pincett', 'pincetter']
    ].forEach(function(row) {
        assertThat(LMentionable.pluralWordFrom(row[1])).isEqualTo(row[2]);
    });
};

/* --- GRÖNA: härledda regler --- */

/* -are → oförändrad (agentnomet) */
TestUnit 'pluralWordFrom/are-oförändrad' run {
    [   ['läkare', 'läkare'], ['spelare', 'spelare'], ['hackare', 'hackare']
      , ['jägare', 'jägare'], ['säljare', 'säljare']
    ].forEach(function(row) {
        assertThat(LMentionable.pluralWordFrom(row[1])).isEqualTo(row[2]);
    });
};

/* -ion → +er */
TestUnit 'pluralWordFrom/ion' run {
    [   ['nation', 'nationer'], ['station', 'stationer'], ['tradition', 'traditioner']
      , ['religion', 'religioner'], ['version', 'versioner']
    ].forEach(function(row) {
        assertThat(LMentionable.pluralWordFrom(row[1])).isEqualTo(row[2]);
    });
};

/* -het/-tet → +er */
TestUnit 'pluralWordFrom/het-tet' run {
    [   ['frihet', 'friheter'], ['säkerhet', 'säkerheter'], ['trygghet', 'tryggheter']
      , ['kvalitet', 'kvaliteter'], ['aktivitet', 'aktiviteter'], ['prioritet', 'prioriteter']
    ].forEach(function(row) {
        assertThat(LMentionable.pluralWordFrom(row[1])).isEqualTo(row[2]);
    });
};

/* -ism → +er */
TestUnit 'pluralWordFrom/ism' run {
    [   ['socialism', 'socialismer'], ['turism', 'turismer'], ['cynism', 'cynismer']
    ].forEach(function(row) {
        assertThat(LMentionable.pluralWordFrom(row[1])).isEqualTo(row[2]);
    });
};

/* -el → drop -el, +lar (och att irregularPlurals slår igenom för undantag) */
TestUnit 'pluralWordFrom/el-lar' run {
    [   ['spegel', 'speglar'], ['pixel', 'pixlar']
      , ['cykel', 'cyklar'],   ['fågel', 'fåglar'],  ['kamel', 'kameler']
    ].forEach(function(row) {
        assertThat(LMentionable.pluralWordFrom(row[1])).isEqualTo(row[2]);
    });
    /* undantag via irregularPlurals */
    assertThat(LMentionable.pluralWordFrom('regel')).isEqualTo('regler');
    assertThat(LMentionable.pluralWordFrom('muskel')).isEqualTo('muskler');
};

/* --- RÖDA: lånord, → -on/-or/-er/-s beroende på ursprung --- */

TestUnit 'pluralWordFrom/lånord' run {
    [   ['foto', 'foton'],         ['piano', 'pianon'],    ['tempo', 'tempon']
      , ['libretto', 'libretton'], ['motto', 'motton'],    ['video', 'videor']
      , ['memo', 'memos'],         ['studio', 'studios'],  ['automat', 'automater']
    ].forEach(function(row) {
        assertThat(LMentionable.pluralWordFrom(row[1])).isEqualTo(row[2]);
    });
};

/* ============================================================
 * pluralNameFrom — pluraliserar en namnfras (kan innehålla prep-fras).
 * Delar upp 'X av Y' → pluraliserar X, behåller ' av Y'.
 * ============================================================ */

TestUnit 'pluralNameFrom/umlaut' run {
    assertThat(LMentionable.pluralNameFrom('fot')).isEqualTo('fötter');
    assertThat(LMentionable.pluralNameFrom('man')).isEqualTo('män');
};

TestUnit 'pluralNameFrom/prep-fras' run {
    // Delar upp vid preposition; pluraliserar bara vänstra sidan
    assertThat(LMentionable.pluralNameFrom('fot av lera')).isEqualTo('fötter av lera');
};

/* ============================================================
 * locify — lägger till platsbeskrivning: '<obj> <prep> <container>'.
 * Prep beror på locType: In→'i', On→'på', Under→'under' etc.
 * ============================================================ */

TestUnit 'locify/i behållare' run {
    libGlobal.curActor = spelare2aPerspektiv;
    appletObjNeutrumSingular.moveInto(korgen);
    // apple.locType = In (Container), korgen.theName = 'korgen'
    assertThat(korgen.locify(appletObjNeutrumSingular, 'äpplet')).isEqualTo('äpplet i korgen');
    appletObjNeutrumSingular.moveInto(nil);
};

TestUnit 'locify/på yta' run {
    libGlobal.curActor = spelare2aPerspektiv;
    appletObjNeutrumSingular.moveInto(hyllan);
    // apple.locType = On (Surface), hyllan.theName = 'hyllan'
    assertThat(hyllan.locify(appletObjNeutrumSingular, 'äpplet')).isEqualTo('äpplet på hyllan');
    appletObjNeutrumSingular.moveInto(nil);
};

/* ============================================================
 * contify — lägger till innehållsbeskrivning: '<container> med <innehåll>'.
 * self är innehållet, str är containerns namn under konstruktion.
 * ============================================================ */

TestUnit 'contify' run {
    // appletObjNeutrumSingular.name = 'äpple' (basform utan ändelse)
    assertThat(appletObjNeutrumSingular.contify(korgen, 'korgen')).isEqualTo('korgen med äpple');
    // vindruvorObjNeutrumPlural.name = 'vindruvor'
    assertThat(vindruvorObjNeutrumPlural.contify(korgen, 'korgen')).isEqualTo('korgen med vindruvor');
};
