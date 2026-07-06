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

// Test arrangements
gameMain: GameMainDef
  initialPlayerChar = spelare2aPerspektiv
;


// Proper named
adam: Actor 'Adam;;;honom';
eva: Actor 'Eva;;;henne';
sockerbagarna: Actor 'sockerbagarna[pl];;;dem' proper = true;

// Not proper named:
skaran: Actor 'skara+n' proper = nil;  // utrum 
sallskapet: Actor 'sällskap+et' proper = nil; // neutrum

croupiern: Actor 'croupier+n;;;honom' proper = nil;
flygvardinnan: Actor 'flyg|värdinna+n;;;henne' proper = nil;


soppburken: Container 'soppa+n på burk+en;;konservburk+en'
    definiteForm = 'soppan på burk'
;


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


/**
 * Returnerar en sträng med grammatiska delar av ett objekt:
 * adjektiv, substantiv och plural.
 */ 
function getGrammarInfoFromCmdDict(o) {
    local str = new StringBuffer();
    str.append('\n');
    cmdDict.forEachWord(function(obj, word, wordPart) {
        
        if(obj == o) {
            tadsSay('FOUND IT');
            local grammarFunction = 'unknown';
            if(wordPart == &noun) grammarFunction = 'substantiv';
            else if(wordPart == &plural) grammarFunction = 'plural';
            else if(wordPart == &adjective) grammarFunction = 'adjektiv';
            else if(wordPart == &literalAdjective) grammarFunction = 'literalAdjective';
            else if(wordPart == &adjApostS) grammarFunction = 'adjApostS';
            str.append('<<word>> (<<grammarFunction>>) \n');
        }
    });
    str.append('\b');
    return toString(str);
}

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

spelare2aPerspektiv: Actor 'du' @lab
  person = 2
  isProper = true
  isHim = true
;




// Test Assertions


// Differences in adv3 and adv3Lite
// adv3Lite only stores a dummy object within cmdDict. 
// For object resolving it only uses the objects in scope
// and ask each in turn if they are associated with a word,
// A guess this is done in 
// -- NounPhrase.matchVocab

// Mentionable.matchPhrases - holds the phrases to match tokens to
// Mentionable.matchName(tokens)

appletObjNeutrumSingular: Thing 'äpple+t;rött röd+a';
vindruvorna: Thing 'vindruvor+na[pl];;;dem';



function inspectVocabWords(obj, warnIfMissingName=true) {
  local name = obj.name ?? warnIfMissingName ? '"WARNING: unassigned"' : '';
  local defName = obj.definiteForm ?? warnIfMissingName ? '"WARNING: unassigned"' : '';
  tadsSay('Kontrollerar vocabWords för "<<name>>" (best. form: "<<defName>>"):\n');
  for(local vw in obj.vocabWords) {
    tadsSay('\t * <<vw.wordStr>> <<vw.posFlags>>\n'); 
  }
}



/**
  * Rensar bort alla dictionaryPlaceholder(s) i cmdDict
 */
function cleanUp(obj) {
  local a = new LookupTable();
  cmdDict.forEachWord(function(obj, word, wordPart) {
    if(obj == o) {
        a[word] = wordPart;
    }
  });
  a.forEachAssoc(function(word, wordPart) {
    //tadsSay('\nTar bort association mellan <<word>> (<<wordPart>>) och <<obj>>\n');
    cmdDict.removeWord(obj, word, wordPart);
  });
}

/**
 * Returnerar antalet grammatiska delar av ett objekt: DVS alla förekomster av olika adjektiv,
 * substantiv och plural som refererar till detta objekt i cmdDict
 */ 
function getGrammarPartsFromCmdDict(obj) {
  local count = 0;
  cmdDict.forEachWord(function(obj, word, wordPart) {
    if(obj == o) {
        count++;
    }
  });
  return count;
}


TestUnit 'initVocab() körs med: "David" (med men utan användning av +notation)' run {
    local david = new Actor();
    david.vocab = 'David';

    // Act
    david.initVocab();

    // Assert
    // inspectVocabWords(david);

    assertThat(david.name).isEqualTo('David');
    assertThat(david.theName).isEqualTo('David');
    //assertThat(david.definiteForm).isEqualTo('äpplet');

    assertThat(david.isNeuter).isEqualTo(nil);
    assertThat(david.plural).isEqualTo(nil);

    assertThat(david.proper).isEqualTo(true); 
    assertThat(david.qualified).isEqualTo(true); 

    assertThat(david.vocabWords).hasLength(1);
    assertThat(david.vocabWords[1])
      .extractingProps([&wordStr, &posFlags])
      .isEqualTo(['david', MatchNoun]);

    // Also assert that a dummy object exists in cmdDict for all nouns
    // only the dictionary properties &noun and  &nounApostS are used in adv3Lite. 
    // (see advlite.h)
    assertThat(cmdDict.findWord('david', &noun)[1]).isEqualTo(dictionaryPlaceholder);

    cleanUp(david); 
};

TestUnit 'initVocab() körs med: "äpple+t" (+notation)' run {
    local apple = new Thing();
    apple.vocab = 'äpple+t;stor+a röd+a;frukt+en';

    // Act
    apple.initVocab();

    // Assert
    // inspectVocabWords(apple);

    assertThat(apple.name).isEqualTo('äpple');
    assertThat(apple.definiteForm).isEqualTo('äpplet');
    assertThat(apple.isNeuter).isEqualTo(true);
    assertThat(apple.plural).isEqualTo(nil); // Default ´nil´

    assertThat(apple.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['äpple', MatchNoun]);
    assertThat(apple.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['äpplet', MatchNoun]);
    assertThat(apple.vocabWords[3]).extractingProps([&wordStr, &posFlags]).isEqualTo(['stor', MatchAdj]);
    assertThat(apple.vocabWords[4]).extractingProps([&wordStr, &posFlags]).isEqualTo(['stora', MatchAdj]);
    assertThat(apple.vocabWords[5]).extractingProps([&wordStr, &posFlags]).isEqualTo(['röd', MatchAdj]);
    assertThat(apple.vocabWords[6]).extractingProps([&wordStr, &posFlags]).isEqualTo(['röda', MatchAdj]);
    assertThat(apple.vocabWords[7]).extractingProps([&wordStr, &posFlags]).isEqualTo(['frukt', MatchNoun]);
    assertThat(apple.vocabWords[8]).extractingProps([&wordStr, &posFlags]).isEqualTo(['frukten', MatchNoun]);
    
    // Also assert that a dummy object exists in cmdDict for all nouns
    // only the dictionary properties &noun and  &nounApostS are used in adv3Lite. 
    // (see advlite.h)
    assertThat(cmdDict.findWord('äpple', &noun)[1]).isEqualTo(dictionaryPlaceholder);
    assertThat(cmdDict.findWord('äpplet', &noun)[1]).isEqualTo(dictionaryPlaceholder);
    assertThat(cmdDict.findWord('frukt', &noun)[1]).isEqualTo(dictionaryPlaceholder);
    assertThat(cmdDict.findWord('frukten', &noun)[1]).isEqualTo(dictionaryPlaceholder);

    cleanUp(apple); 
};

// TODO: fixa att plural=true sätts
TestUnit 'initVocab() körs med: "äpplen[pl]" (+notation)' run {
    local apple = new Thing();
    apple.vocab = 'äpplen+a[pl]'; 

    // Act
    apple.initVocab();

    // Assert
    // inspectVocabWords(apple);

    assertThat(apple.name).isEqualTo('äpplen');
    assertThat(apple.definiteForm).isEqualTo('äpplena');
    assertThat(apple.isNeuter).isEqualTo(nil); // Should just be the default ´nil´
    
    // TODO:  oklart om &plural ska härledas eller behöva sättas av användaren själv
    // Se rad: 1106 i english.t
    // assertThat(apple.plural).isEqualTo(true);

    assertThat(apple.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['äpplen', MatchPlural]);
    assertThat(apple.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['äpplena', MatchPlural]);

    cleanUp(apple); 
};


TestUnit 'initVocab() körs med onödigt och grammatiskt felaktigt "en äpple+t" (+notation)' run {
    local apple = new Thing();

    // Här kan man felaktigt skriva över grammatiskt kön med 'en'
    // Det har samma funktion som att sätta isNeuter = nil direkt.
    // Härledning kommer inte göras i detta fall.
    // Dock kommer orden att skapas upp enligt plusnotation

    apple.vocab = 'en äpple+t';  

    // Act
    apple.initVocab();

    // Assert
    //inspectVocabWords(apple);

    assertThat(apple.isNeuter).isEqualTo(nil); // Inte härlett, satt av användaren

    assertThat(apple.name).isEqualTo('äpple');
    assertThat(apple.definiteForm).isEqualTo('äpplet');
    assertThat(apple.plural).isEqualTo(nil); // Default ´nil´

    assertThat(apple.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['äpple', MatchNoun]);
    assertThat(apple.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['äpplet', MatchNoun]);

    cleanUp(apple); 
};


TestUnit 'initVocab() körs med "äpple+t" plus isNeuter=nil (+notation)' run {
    local apple = new Thing();

    // Här kan man felaktigt skriva över grammatiskt kön med 'en'
    // Det har samma funktion som att sätta isNeuter = nil direkt.
    // Härledning kommer inte göras i detta fall.
    // Dock kommer orden att skapas upp enligt plusnotation

    apple.vocab = 'äpple+t';  
    apple.isNeuter = nil; 
    // Fel egentligen, men ska åskådliggöra att vi kan överrida grammatiskt genus

    // Act
    apple.initVocab();

    // Assert
    //inspectVocabWords(apple);

    assertThat(apple.isNeuter).isEqualTo(nil); // Inte härlett, satt av användaren

    assertThat(apple.name).isEqualTo('äpple');
    assertThat(apple.definiteForm).isEqualTo('äpplet');
    assertThat(apple.plural).isEqualTo(nil); // Default ´nil´

    assertThat(apple.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['äpple', MatchNoun]);
    assertThat(apple.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['äpplet', MatchNoun]);

    cleanUp(apple); 
};


TestUnit 'en croupier' run {
    assertThat(croupiern.name).isEqualTo('croupier');
    assertThat(croupiern.aName).isEqualTo('en croupier');
    assertThat(croupiern.theName).isEqualTo('croupiern');
    assertThat(croupiern.definiteForm).isEqualTo('croupiern');
    assertThat(croupiern.isHim).isTrue();
    assertThat(croupiern.isHer).isNil();
    assertThat(croupiern.isIt).isNil();

    assertThat(croupiern.qualified).isNil();
    assertThat(croupiern.proper).isNil();

    assertThat(croupiern.vocabWords).hasLength(2);
    assertThat(croupiern.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['croupier', MatchNoun]);
    assertThat(croupiern.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['croupiern', MatchNoun]);
};

TestUnit 'en flygvärdinnna' run {
    assertThat(flygvardinnan.name).isEqualTo('flygvärdinna');
    assertThat(flygvardinnan.aName).isEqualTo('en flygvärdinna');
    assertThat(flygvardinnan.theName).isEqualTo('flygvärdinnan');
    assertThat(flygvardinnan.definiteForm).isEqualTo('flygvärdinnan');
    assertThat(flygvardinnan.isHer).isTrue();
    assertThat(flygvardinnan.isHim).isNil();
    assertThat(flygvardinnan.isIt).isNil();

    assertThat(flygvardinnan.qualified).isNil();
    assertThat(flygvardinnan.proper).isNil();

    assertThat(flygvardinnan.vocabWords).hasLength(4);
    assertThat(flygvardinnan.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['flygvärdinna', MatchNoun]);
    assertThat(flygvardinnan.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['flygvärdinnan', MatchNoun]);
    assertThat(flygvardinnan.vocabWords[3]).extractingProps([&wordStr, &posFlags]).isEqualTo(['värdinna', MatchNoun]);
    assertThat(flygvardinnan.vocabWords[4]).extractingProps([&wordStr, &posFlags]).isEqualTo(['värdinnan', MatchNoun]);
};


TestUnit 'Eva' run {
    assertThat(eva.name).isEqualTo('Eva');
    assertThat(eva.aName).isEqualTo('Eva');
    assertThat(eva.theName).isEqualTo('Eva');
    // TODO: bör även detta sättas automatiskt, eller är det bara onödigt, (definiteForm används mest internt)
    //assertThat(eva.definiteForm).isEqualTo('Eva'); 
    assertThat(eva.isHer).isTrue();
    assertThat(eva.isHim).isNil();
    assertThat(eva.isIt).isNil();
    assertThat(adam.plural).isNil();

    assertThat(eva.qualified).isTrue();
    assertThat(eva.proper).isTrue();

    assertThat(eva.vocabWords).hasLength(1);
    assertThat(eva.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['eva', MatchNoun]);
};

TestUnit 'Adam' run {
    assertThat(adam.name).isEqualTo('Adam');
    assertThat(adam.aName).isEqualTo('Adam');
    assertThat(adam.theName).isEqualTo('Adam');
    
    // TODO: bör även detta sättas automatiskt, eller är det bara onödigt, (definiteForm används mest internt)
    //assertThat(adam.definiteForm).isEqualTo('Adam'); 
    assertThat(adam.isHim).isTrue();
    assertThat(adam.isHer).isNil();
    assertThat(adam.isIt).isNil();
    assertThat(adam.plural).isNil();

    assertThat(adam.qualified).isTrue();
    assertThat(adam.proper).isTrue();

    assertThat(adam.vocabWords).hasLength(1);
    assertThat(adam.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['adam', MatchNoun]);
};


TestUnit 'Sällskapet' run {
    assertThat(sallskapet.name).isEqualTo('sällskap');
    assertThat(sallskapet.aName).isEqualTo('ett sällskap');
    assertThat(sallskapet.theName).isEqualTo('sällskapet');
    
    assertThat(sallskapet.isHim).isNil();
    assertThat(sallskapet.isHer).isNil();
    
    assertThat(sallskapet.isIt).isTrue();
    assertThat(sallskapet.plural).isNil();

    assertThat(sallskapet.qualified).isNil();
    assertThat(sallskapet.proper).isNil();
    assertThat(sallskapet.vocabWords).hasLength(2);
    assertThat(sallskapet.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['sällskap', MatchNoun]);
    assertThat(sallskapet.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['sällskapet', MatchNoun]);
};

TestUnit 'Skaran' run {
    assertThat(skaran.name).isEqualTo('skara');
    assertThat(skaran.aName).isEqualTo('en skara');
    assertThat(skaran.theName).isEqualTo('skaran');
    
    assertThat(skaran.isHim).isNil();
    assertThat(skaran.isHer).isNil();
    assertThat(skaran.isIt).isTrue();
    assertThat(skaran.plural).isNil();

    assertThat(skaran.qualified).isNil();
    assertThat(skaran.proper).isNil();

    assertThat(skaran.vocabWords).hasLength(2);
    assertThat(skaran.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['skara', MatchNoun]);
    assertThat(skaran.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['skaran', MatchNoun]);
};


TestUnit 'Sockerbagarna' run {
    assertThat(sockerbagarna.name).isEqualTo('sockerbagarna');
    assertThat(sockerbagarna.aName).isEqualTo('sockerbagarna');
    assertThat(sockerbagarna.theName).isEqualTo('sockerbagarna');
    
    assertThat(sockerbagarna.isHim).isNil();
    assertThat(sockerbagarna.isHer).isNil();
    assertThat(sockerbagarna.isIt).isTrue();
    assertThat(sockerbagarna.plural).isTrue();

    assertThat(sockerbagarna.qualified).isTrue();
    assertThat(sockerbagarna.proper).isTrue();
    assertThat(sockerbagarna.vocabWords).hasLength(1);
    assertThat(sockerbagarna.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['sockerbagarna', MatchPlural]);
};

TestUnit 'Vindruvorna' run {
  
    assertThat(vindruvorna.name).isEqualTo('vindruvor');
    assertThat(vindruvorna.aName).isEqualTo('några vindruvor');
    assertThat(vindruvorna.theName).isEqualTo('vindruvorna');
    
    assertThat(vindruvorna.isHim).isNil();
    assertThat(vindruvorna.isHer).isNil();
    assertThat(vindruvorna.isIt).isTrue();
    assertThat(vindruvorna.plural).isTrue();

    assertThat(vindruvorna.qualified).isNil();
    assertThat(vindruvorna.proper).isNil();
    assertThat(vindruvorna.vocabWords).hasLength(2);
    assertThat(vindruvorna.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['vindruvor', MatchPlural]);
    assertThat(vindruvorna.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['vindruvorna', MatchPlural]);
};


// ============================================================
// Tester för createCompoundWordVariations / initVocabWord
// ============================================================


// --- A: Enkel ändelse och genus-härledning ---

TestUnit 'dörr+en (utrum konsonant → bestämdform -en)' run {
    local obj = new Thing();
    obj.vocab = 'dörr+en';
    obj.initVocab();
    assertThat(obj.name).isEqualTo('dörr');
    assertThat(obj.definiteForm).isEqualTo('dörren');
    assertThat(obj.isNeuter).isEqualTo(nil);
    assertThat(obj.vocabWords).hasLength(2);
    assertThat(obj.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['dörr', MatchNoun]);
    assertThat(obj.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['dörren', MatchNoun]);
    cleanUp(obj);
};

TestUnit 'träd+et (neutrum konsonant → bestämdform -et)' run {
    local obj = new Thing();
    obj.vocab = 'träd+et';
    obj.initVocab();
    assertThat(obj.name).isEqualTo('träd');
    assertThat(obj.definiteForm).isEqualTo('trädet');
    assertThat(obj.isNeuter).isEqualTo(true);
    assertThat(obj.vocabWords).hasLength(2);
    assertThat(obj.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['träd', MatchNoun]);
    assertThat(obj.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['trädet', MatchNoun]);
    cleanUp(obj);
};

TestUnit 'fura+n (utrum vokal → bestämdform -n)' run {
    local obj = new Thing();
    obj.vocab = 'fura+n';
    obj.initVocab();
    assertThat(obj.name).isEqualTo('fura');
    assertThat(obj.definiteForm).isEqualTo('furan');
    assertThat(obj.isNeuter).isEqualTo(nil);
    assertThat(obj.vocabWords).hasLength(2);
    assertThat(obj.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['fura', MatchNoun]);
    assertThat(obj.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['furan', MatchNoun]);
    cleanUp(obj);
};

TestUnit 'dator+n (utrum -or-stam → bestämdform -n, inte -en)' run {
    local obj = new Thing();
    obj.vocab = 'dator+n';
    obj.initVocab();
    assertThat(obj.name).isEqualTo('dator');
    assertThat(obj.definiteForm).isEqualTo('datorn');
    assertThat(obj.isNeuter).isEqualTo(nil);
    assertThat(obj.vocabWords).hasLength(2);
    assertThat(obj.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['dator', MatchNoun]);
    assertThat(obj.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['datorn', MatchNoun]);
    cleanUp(obj);
};

TestUnit 'teater+n (utrum -er-stam → bestämdform -n, inte -en)' run {
    local obj = new Thing();
    obj.vocab = 'teater+n';
    obj.initVocab();
    assertThat(obj.name).isEqualTo('teater');
    assertThat(obj.definiteForm).isEqualTo('teatern');
    assertThat(obj.isNeuter).isEqualTo(nil);
    assertThat(obj.vocabWords).hasLength(2);
    assertThat(obj.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['teater', MatchNoun]);
    assertThat(obj.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['teatern', MatchNoun]);
    cleanUp(obj);
};


// --- B: Kolon — alternativ obestämd form (altEnding) ---
//
// ':suffix' på den sista ordkomponenten (steget innan globaländelsen) lagras
// som altEnding och används för obestämd form i stället för den nakna stammen.
//
//   fönst:er+ret  → word='fönst', altEnding='er', ending='ret'
//                    obestämd: fönst+er  = fönster
//                    bestämd:  fönst+ret = fönstret
//
// Fungerar i sammansatta ord på godtycklig position:
//   tak+fönst:er+ret → tak/taket, takfönster/takfönstret, fönster/fönstret

TestUnit 'fönst:er+ret (altEnding ger alternativ obestämd form)' run {
    local obj = new Thing();
    obj.vocab = 'fönst:er+ret';
    obj.initVocab();
    assertThat(obj.name).isEqualTo('fönster');
    assertThat(obj.definiteForm).isEqualTo('fönstret');
    assertThat(obj.isNeuter).isEqualTo(true);
    assertThat(obj.vocabWords).hasLength(2);
    assertThat(obj.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['fönster', MatchNoun]);
    assertThat(obj.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['fönstret', MatchNoun]);
    cleanUp(obj);
};

TestUnit 'tak+fönst:er+ret (altEnding i sammansatt ord)' run {
    local obj = new Thing();
    obj.vocab = 'tak+fönst:er+ret';
    obj.initVocab();
    assertThat(obj.name).isEqualTo('takfönster');
    assertThat(obj.definiteForm).isEqualTo('takfönstret');
    assertThat(obj.isNeuter).isEqualTo(true);
    // start=1: tak/taket, takfönster/takfönstret
    // start=2: fönster/fönstret
    assertThat(obj.vocabWords).hasLength(6);
    assertThat(obj.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['tak', MatchNoun]);
    assertThat(obj.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['taket', MatchNoun]);
    assertThat(obj.vocabWords[3]).extractingProps([&wordStr, &posFlags]).isEqualTo(['takfönster', MatchNoun]);
    assertThat(obj.vocabWords[4]).extractingProps([&wordStr, &posFlags]).isEqualTo(['takfönstret', MatchNoun]);
    assertThat(obj.vocabWords[5]).extractingProps([&wordStr, &posFlags]).isEqualTo(['fönster', MatchNoun]);
    assertThat(obj.vocabWords[6]).extractingProps([&wordStr, &posFlags]).isEqualTo(['fönstret', MatchNoun]);
    cleanUp(obj);
};

// OBS: 'äpp:el+et+kaka+n' fungerar INTE — 'et' tolkas som en separat ordkomponent
// och genererar nonsens som äppet/äppeten/äppetkaka. Morfologin för äpple/äpplet
// i sammansatt ord (äppelkaka vs äpplekaka) kräver ett av dessa kompromissalternativ:
//
//   äpple:t+kaka+n  → äpple/äpplet standalone, äpplekaka/äpplekakan compound
//   äppel+kaka+n    → äppel/äppeln standalone (fel genus), äppelkaka/äppelkakan compound
//   äppel|kaka+n    → bara äppelkaka/äppelkakan, inget standalone för äppel


// --- C: Sammansatta ord utan foge-s (3 delar) ---

TestUnit 'cykel+korg+en (2-ledat sammansatt, båda komponenter genereras)' run {
    local obj = new Thing();
    obj.vocab = 'cykel+korg+en';
    obj.initVocab();
    assertThat(obj.name).isEqualTo('cykelkorg');
    assertThat(obj.definiteForm).isEqualTo('cykelkorgen');
    assertThat(obj.isNeuter).isEqualTo(nil);
    // cykel, cykeln, korg, korgen, cykelkorg, cykelkorgen
    assertThat(obj.vocabWords).hasLength(6);
    assertThat(obj.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['cykel', MatchNoun]);
    assertThat(obj.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['cykeln', MatchNoun]);
    assertThat(obj.vocabWords[3]).extractingProps([&wordStr, &posFlags]).isEqualTo(['cykelkorg', MatchNoun]);
    assertThat(obj.vocabWords[4]).extractingProps([&wordStr, &posFlags]).isEqualTo(['cykelkorgen', MatchNoun]);
    assertThat(obj.vocabWords[5]).extractingProps([&wordStr, &posFlags]).isEqualTo(['korg', MatchNoun]);
    assertThat(obj.vocabWords[6]).extractingProps([&wordStr, &posFlags]).isEqualTo(['korgen', MatchNoun]);
    cleanUp(obj);
};


// --- D: Pipe-notation (| blockerar delkomponent som eget ord) ---

TestUnit 'cykel|slang+en (| hindrar cykel/cykeln som egna ord)' run {
    local obj = new Thing();
    obj.vocab = 'cykel|slang+en';
    obj.initVocab();
    assertThat(obj.name).isEqualTo('cykelslang');
    assertThat(obj.definiteForm).isEqualTo('cykelslangen');
    assertThat(obj.isNeuter).isEqualTo(nil);
    // slang, slangen, cykelslang, cykelslangen — INTE cykel/cykeln
    assertThat(obj.vocabWords).hasLength(4);
    assertThat(obj.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['cykelslang', MatchNoun]);
    assertThat(obj.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['cykelslangen', MatchNoun]);
    assertThat(obj.vocabWords[3]).extractingProps([&wordStr, &posFlags]).isEqualTo(['slang', MatchNoun]);
    assertThat(obj.vocabWords[4]).extractingProps([&wordStr, &posFlags]).isEqualTo(['slangen', MatchNoun]);
    cleanUp(obj);
};


// --- E: Foge-s (^s) ---

TestUnit 'tranbär^s+juice+n (foge-s fogar samman sammansättningen)' run {
    local obj = new Thing();
    obj.vocab = 'tranbär^s+juice+n';
    obj.initVocab();
    assertThat(obj.name).isEqualTo('tranbärsjuice');
    assertThat(obj.definiteForm).isEqualTo('tranbärsjuicen');
    assertThat(obj.isNeuter).isEqualTo(nil);
    // tranbär, tranbären, juice, juicen, tranbärsjuice, tranbärsjuicen
    assertThat(obj.vocabWords).hasLength(6);
    assertThat(obj.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['tranbär', MatchNoun]);
    assertThat(obj.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['tranbären', MatchNoun]);
    assertThat(obj.vocabWords[3]).extractingProps([&wordStr, &posFlags]).isEqualTo(['tranbärsjuice', MatchNoun]);
    assertThat(obj.vocabWords[4]).extractingProps([&wordStr, &posFlags]).isEqualTo(['tranbärsjuicen', MatchNoun]);
    assertThat(obj.vocabWords[5]).extractingProps([&wordStr, &posFlags]).isEqualTo(['juice', MatchNoun]);
    assertThat(obj.vocabWords[6]).extractingProps([&wordStr, &posFlags]).isEqualTo(['juicen', MatchNoun]);
    cleanUp(obj);
};


// --- F: Kolon i sammansatt ord — genusmodifiering av delkomponent ---

TestUnit 'ansvar:et^s+känsla+n (kolon sätter delkomponents genus explicit)' run {
    local obj = new Thing();
    obj.vocab = 'ansvar:et^s+känsla+n';
    obj.initVocab();
    assertThat(obj.name).isEqualTo('ansvarskänsla');
    assertThat(obj.definiteForm).isEqualTo('ansvarskänslan');
    assertThat(obj.isNeuter).isEqualTo(nil);
    // ansvar, ansvaret, känsla, känslan, ansvarskänsla, ansvarskänslan
    assertThat(obj.vocabWords).hasLength(6);
    assertThat(obj.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['ansvar', MatchNoun]);
    assertThat(obj.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['ansvaret', MatchNoun]);
    assertThat(obj.vocabWords[3]).extractingProps([&wordStr, &posFlags]).isEqualTo(['ansvarskänsla', MatchNoun]);
    assertThat(obj.vocabWords[4]).extractingProps([&wordStr, &posFlags]).isEqualTo(['ansvarskänslan', MatchNoun]);
    assertThat(obj.vocabWords[5]).extractingProps([&wordStr, &posFlags]).isEqualTo(['känsla', MatchNoun]);
    assertThat(obj.vocabWords[6]).extractingProps([&wordStr, &posFlags]).isEqualTo(['känslan', MatchNoun]);
    cleanUp(obj);
};


// --- G: Trippeltecken kortas ned (shortenRepeatingCharacters) ---

TestUnit 'boll+lek+en (trippel-l i sammansättning kortas till dubbel-l)' run {
    local obj = new Thing();
    obj.vocab = 'boll+lek+en';
    obj.initVocab();
    // 'boll'+'lek' = 'bolllek' → kortas till 'bollek'
    assertThat(obj.name).isEqualTo('bollek');
    assertThat(obj.definiteForm).isEqualTo('bolleken');
    assertThat(obj.isNeuter).isEqualTo(nil);
    // boll, bollen, lek, leken, bollek, bolleken
    assertThat(obj.vocabWords).hasLength(6);
    assertThat(obj.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['boll', MatchNoun]);
    assertThat(obj.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['bollen', MatchNoun]);
    assertThat(obj.vocabWords[3]).extractingProps([&wordStr, &posFlags]).isEqualTo(['bollek', MatchNoun]);
    assertThat(obj.vocabWords[4]).extractingProps([&wordStr, &posFlags]).isEqualTo(['bolleken', MatchNoun]);
    assertThat(obj.vocabWords[5]).extractingProps([&wordStr, &posFlags]).isEqualTo(['lek', MatchNoun]);
    assertThat(obj.vocabWords[6]).extractingProps([&wordStr, &posFlags]).isEqualTo(['leken', MatchNoun]);
    cleanUp(obj);
};


// --- H: Adjektiv i sektion 1 (ingår i name och theName) ---
//
// När ett adjektiv med +notation förekommer FÖRE substantivet i sektion 1
// inkluderas det automatiskt i name och theName.
// Sektion 2 används för sökord som inte ska synas i name.

TestUnit 'blå+a stol+en (adj i sektion 1, utrum singular)' run {
    local obj = new Thing();
    obj.vocab = 'blå+a stol+en';
    obj.initVocab();

    assertThat(obj.name).isEqualTo('blå stol');
    assertThat(obj.definiteForm).isEqualTo('stolen');
    assertThat(obj.shortNameAdjDef).isEqualTo('blåa');
    assertThat(obj.isNeuter).isNil();
    // theName = artikel + adj.def.form + noun.def.form
    assertThat(obj.theName).isEqualTo('den blåa stolen');
    assertThat(obj.aName).isEqualTo('en blå stol');

    // blå, blåa (adj), stol, stolen (subst) — 4 sökord
    assertThat(obj.vocabWords).hasLength(4);
    assertThat(obj.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['blå', MatchAdj]);
    assertThat(obj.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['blåa', MatchAdj]);
    assertThat(obj.vocabWords[3]).extractingProps([&wordStr, &posFlags]).isEqualTo(['stol', MatchNoun]);
    assertThat(obj.vocabWords[4]).extractingProps([&wordStr, &posFlags]).isEqualTo(['stolen', MatchNoun]);

    cleanUp(obj);
};

TestUnit 'blå+a bord+et (adj i sektion 1, neutrum singular)' run {
    local obj = new Thing();
    obj.vocab = 'blå+a bord+et';
    obj.initVocab();

    assertThat(obj.name).isEqualTo('blå bord');
    assertThat(obj.definiteForm).isEqualTo('bordet');
    assertThat(obj.shortNameAdjDef).isEqualTo('blåa');
    assertThat(obj.isNeuter).isEqualTo(true);
    // neutrum → artikel 'det'
    assertThat(obj.theName).isEqualTo('det blåa bordet');
    assertThat(obj.aName).isEqualTo('ett blå bord');

    // blå, blåa (adj), bord, bordet (subst) — 4 sökord
    assertThat(obj.vocabWords).hasLength(4);
    assertThat(obj.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['blå', MatchAdj]);
    assertThat(obj.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['blåa', MatchAdj]);
    assertThat(obj.vocabWords[3]).extractingProps([&wordStr, &posFlags]).isEqualTo(['bord', MatchNoun]);
    assertThat(obj.vocabWords[4]).extractingProps([&wordStr, &posFlags]).isEqualTo(['bordet', MatchNoun]);

    cleanUp(obj);
};

TestUnit 'blå+a stol+en;bekväm+a (adj i sektion 1 + adj i sektion 2)' run {
    // Adj i s1 → ingår i name. Adj i s2 → bara sökord, ingår inte i name.
    local obj = new Thing();
    obj.vocab = 'blå+a stol+en;bekväm+a';
    obj.initVocab();

    assertThat(obj.name).isEqualTo('blå stol');
    assertThat(obj.definiteForm).isEqualTo('stolen');
    assertThat(obj.shortNameAdjDef).isEqualTo('blåa');
    assertThat(obj.isNeuter).isNil();
    assertThat(obj.theName).isEqualTo('den blåa stolen');
    assertThat(obj.aName).isEqualTo('en blå stol');

    // blå, blåa (adj s1), stol, stolen (subst s1), bekväm, bekväma (adj s2) — 6 sökord
    assertThat(obj.vocabWords).hasLength(6);
    assertThat(obj.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['blå', MatchAdj]);
    assertThat(obj.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['blåa', MatchAdj]);
    assertThat(obj.vocabWords[3]).extractingProps([&wordStr, &posFlags]).isEqualTo(['stol', MatchNoun]);
    assertThat(obj.vocabWords[4]).extractingProps([&wordStr, &posFlags]).isEqualTo(['stolen', MatchNoun]);
    assertThat(obj.vocabWords[5]).extractingProps([&wordStr, &posFlags]).isEqualTo(['bekväm', MatchAdj]);
    assertThat(obj.vocabWords[6]).extractingProps([&wordStr, &posFlags]).isEqualTo(['bekväma', MatchAdj]);

    cleanUp(obj);
};

TestUnit 'blå+a stor+a stol+en (flera adj i sektion 1)' run {
    local obj = new Thing();
    obj.vocab = 'blå+a stor+a stol+en';
    obj.initVocab();

    // Alla föregående adjektiv samlas och läggs före substantivets grundform
    assertThat(obj.name).isEqualTo('blå stor stol');
    assertThat(obj.definiteForm).isEqualTo('stolen');
    // Alla adj. definitiva former samlas med mellanslag
    assertThat(obj.shortNameAdjDef).isEqualTo('blåa stora');
    assertThat(obj.isNeuter).isNil();
    assertThat(obj.theName).isEqualTo('den blåa stora stolen');
    assertThat(obj.aName).isEqualTo('en blå stor stol');

    // blå, blåa, stor, stora (adj), stol, stolen (subst) — 6 sökord
    assertThat(obj.vocabWords).hasLength(6);
    assertThat(obj.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['blå', MatchAdj]);
    assertThat(obj.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['blåa', MatchAdj]);
    assertThat(obj.vocabWords[3]).extractingProps([&wordStr, &posFlags]).isEqualTo(['stor', MatchAdj]);
    assertThat(obj.vocabWords[4]).extractingProps([&wordStr, &posFlags]).isEqualTo(['stora', MatchAdj]);
    assertThat(obj.vocabWords[5]).extractingProps([&wordStr, &posFlags]).isEqualTo(['stol', MatchNoun]);
    assertThat(obj.vocabWords[6]).extractingProps([&wordStr, &posFlags]).isEqualTo(['stolen', MatchNoun]);

    cleanUp(obj);
};

TestUnit 'blå stol+en (adj utan +notation i sektion 1)' run {
    // Utan +notation på adjektivet saknas den definitiva adj-formen.
    // name byggs ändå, men theName får ingen adj-prefix.
    local obj = new Thing();
    obj.vocab = 'blå stol+en';
    obj.initVocab();

    assertThat(obj.name).isEqualTo('blå stol');
    assertThat(obj.definiteForm).isEqualTo('stolen');
    // Ingen definitiv adj-form → shortNameAdjDef är nil
    assertThat(obj.shortNameAdjDef).isNil();
    assertThat(obj.isNeuter).isNil();
    // theName faller tillbaka på definiteForm (precis som utan adj)
    assertThat(obj.theName).isEqualTo('stolen');
    assertThat(obj.aName).isEqualTo('en blå stol');

    // blå (adj, bara grundform), stol, stolen (subst) — 3 sökord
    assertThat(obj.vocabWords).hasLength(3);
    assertThat(obj.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['blå', MatchAdj]);
    assertThat(obj.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['stol', MatchNoun]);
    assertThat(obj.vocabWords[3]).extractingProps([&wordStr, &posFlags]).isEqualTo(['stolen', MatchNoun]);

    cleanUp(obj);
};

TestUnit 'explicit name åsidosätts inte av adj i sektion 1' run {
    // Om name är satt direkt på objektet ska initVocab inte skriva över det.
    local obj = new Thing();
    obj.vocab = 'blå+a stol+en';
    obj.name = 'min stol';
    obj.initVocab();

    assertThat(obj.name).isEqualTo('min stol');
    // shortNameAdjDef sätts ändå (för theName-beräkning om definiteForm finns)
    assertThat(obj.shortNameAdjDef).isEqualTo('blåa');
    assertThat(obj.definiteForm).isEqualTo('stolen');

    cleanUp(obj);
};


// --- H1: Adj i sektion 1 — plural, massNoun och sammansatt substantiv ---

TestUnit 'blå+a stolar+na[pl] (adj i sektion 1, plural)' run {
    // plural=true sätts via 'dem' i sektion 4; artikel i theName blir 'de'
    local obj = new Thing();
    obj.vocab = 'blå+a stolar+na[pl];;;dem';
    obj.initVocab();

    assertThat(obj.name).isEqualTo('blå stolar');
    assertThat(obj.definiteForm).isEqualTo('stolarna');
    assertThat(obj.shortNameAdjDef).isEqualTo('blåa');
    assertThat(obj.isNeuter).isNil();
    assertThat(obj.plural).isEqualTo(true);
    assertThat(obj.theName).isEqualTo('de blåa stolarna');
    assertThat(obj.aName).isEqualTo('några blå stolar');

    // blå, blåa (adj), stolar, stolarna (plural) — 4 sökord
    assertThat(obj.vocabWords).hasLength(4);
    assertThat(obj.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['blå', MatchAdj]);
    assertThat(obj.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['blåa', MatchAdj]);
    assertThat(obj.vocabWords[3]).extractingProps([&wordStr, &posFlags]).isEqualTo(['stolar', MatchPlural]);
    assertThat(obj.vocabWords[4]).extractingProps([&wordStr, &posFlags]).isEqualTo(['stolarna', MatchPlural]);

    cleanUp(obj);
};

TestUnit 'lite blå:tt+a mjöl+et (adj i sektion 1, massNoun neutrum)' run {
    // 'lite' → massNoun=true; massNoun → ingen artikel i theName ('blåa mjölet')
    // blå:tt+a → standardForm='blått' (neutrum indef.), definiteForm='blåa'
    // aName returnerar name utan artikel för massNoun
    local obj = new Thing();
    obj.vocab = 'lite blå:tt+a mjöl+et';
    obj.initVocab();

    assertThat(obj.name).isEqualTo('blått mjöl');
    assertThat(obj.definiteForm).isEqualTo('mjölet');
    assertThat(obj.shortNameAdjDef).isEqualTo('blåa');
    assertThat(obj.massNoun).isEqualTo(true);
    assertThat(obj.isNeuter).isEqualTo(true);
    assertThat(obj.theName).isEqualTo('blåa mjölet');
    assertThat(obj.aName).isEqualTo('blått mjöl');

    // blått, blåa (adj), mjöl, mjölet (subst) — 4 sökord
    assertThat(obj.vocabWords).hasLength(4);
    assertThat(obj.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['blått', MatchAdj]);
    assertThat(obj.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['blåa', MatchAdj]);
    assertThat(obj.vocabWords[3]).extractingProps([&wordStr, &posFlags]).isEqualTo(['mjöl', MatchNoun]);
    assertThat(obj.vocabWords[4]).extractingProps([&wordStr, &posFlags]).isEqualTo(['mjölet', MatchNoun]);

    cleanUp(obj);
};

TestUnit 'vikt+a papper:et^s+flyg+plan+et (adj i sektion 1 + 3-komponents sammansatt subst)' run {
    // Komplex: adj med +notation + sammansatt substantiv med foge-s och altEnding.
    // 3 komponenter → n*(n+1) = 12 substantivord (6 fönster × 2 ord) + 2 adj = 14 totalt.
    //
    // Fönster (start=1): pappersflygplan/et, pappersflyg/et, papper/et
    // Fönster (start=2): flygplan/et, flyg/et
    // Fönster (start=3): plan/et
    local obj = new Thing();
    obj.vocab = 'vikt+a papper:et^s+flyg+plan+et';
    obj.initVocab();

    assertThat(obj.name).isEqualTo('vikt pappersflygplan');
    assertThat(obj.definiteForm).isEqualTo('pappersflygplanet');
    assertThat(obj.shortNameAdjDef).isEqualTo('vikta');
    assertThat(obj.isNeuter).isEqualTo(true);
    assertThat(obj.theName).isEqualTo('det vikta pappersflygplanet');
    assertThat(obj.aName).isEqualTo('ett vikt pappersflygplan');

    assertThat(obj.vocabWords).hasLength(14);
    // adj
    assertThat(obj.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['vikt', MatchAdj]);
    assertThat(obj.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['vikta', MatchAdj]);
    // start=1, kortaste fönstret först (len=1 → len=2 → len=3)
    assertThat(obj.vocabWords[3]).extractingProps([&wordStr, &posFlags]).isEqualTo(['papper', MatchNoun]);
    assertThat(obj.vocabWords[4]).extractingProps([&wordStr, &posFlags]).isEqualTo(['papperet', MatchNoun]);
    assertThat(obj.vocabWords[5]).extractingProps([&wordStr, &posFlags]).isEqualTo(['pappersflyg', MatchNoun]);
    assertThat(obj.vocabWords[6]).extractingProps([&wordStr, &posFlags]).isEqualTo(['pappersflyget', MatchNoun]);
    assertThat(obj.vocabWords[7]).extractingProps([&wordStr, &posFlags]).isEqualTo(['pappersflygplan', MatchNoun]);
    assertThat(obj.vocabWords[8]).extractingProps([&wordStr, &posFlags]).isEqualTo(['pappersflygplanet', MatchNoun]);
    // start=2
    assertThat(obj.vocabWords[9]).extractingProps([&wordStr, &posFlags]).isEqualTo(['flyg', MatchNoun]);
    assertThat(obj.vocabWords[10]).extractingProps([&wordStr, &posFlags]).isEqualTo(['flyget', MatchNoun]);
    assertThat(obj.vocabWords[11]).extractingProps([&wordStr, &posFlags]).isEqualTo(['flygplan', MatchNoun]);
    assertThat(obj.vocabWords[12]).extractingProps([&wordStr, &posFlags]).isEqualTo(['flygplanet', MatchNoun]);
    // start=3
    assertThat(obj.vocabWords[13]).extractingProps([&wordStr, &posFlags]).isEqualTo(['plan', MatchNoun]);
    assertThat(obj.vocabWords[14]).extractingProps([&wordStr, &posFlags]).isEqualTo(['planet', MatchNoun]);

    cleanUp(obj);
};


// --- H2: Adjektiv i sektion 2 ---

TestUnit 'boll+en;rund+a (adjektiv med +notation i sektion 2)' run {
    local obj = new Thing();
    obj.vocab = 'boll+en;rund+a';
    obj.initVocab();
    assertThat(obj.name).isEqualTo('boll');
    assertThat(obj.definiteForm).isEqualTo('bollen');
    assertThat(obj.isNeuter).isEqualTo(nil);
    // boll, bollen (subst), rund, runda (adj)
    assertThat(obj.vocabWords).hasLength(4);
    assertThat(obj.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['boll', MatchNoun]);
    assertThat(obj.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['bollen', MatchNoun]);
    assertThat(obj.vocabWords[3]).extractingProps([&wordStr, &posFlags]).isEqualTo(['rund', MatchAdj]);
    assertThat(obj.vocabWords[4]).extractingProps([&wordStr, &posFlags]).isEqualTo(['runda', MatchAdj]);
    cleanUp(obj);
};


// --- I: Plural i sektion 3 ---

TestUnit 'äpple+t;;äpplen+a[pl] (plural som extra sektion)' run {
    local obj = new Thing();
    obj.vocab = 'äpple+t;;äpplen+a[pl]';
    obj.initVocab();
    assertThat(obj.name).isEqualTo('äpple');
    assertThat(obj.definiteForm).isEqualTo('äpplet');
    assertThat(obj.isNeuter).isEqualTo(true);
    // äpple, äpplet (subst), äpplen, äpplena (plural)
    assertThat(obj.vocabWords).hasLength(4);
    assertThat(obj.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['äpple', MatchNoun]);
    assertThat(obj.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['äpplet', MatchNoun]);
    assertThat(obj.vocabWords[3]).extractingProps([&wordStr, &posFlags]).isEqualTo(['äpplen', MatchPlural]);
    assertThat(obj.vocabWords[4]).extractingProps([&wordStr, &posFlags]).isEqualTo(['äpplena', MatchPlural]);
    cleanUp(obj);
};


// --- J: Pronomen i sektion 4 ---

TestUnit 'nyckel+n;;;honom (pronomen sektion 4 sätter isHim)' run {
    local obj = new Actor();
    obj.vocab = 'nyckel+n;;;honom';
    obj.initVocab();
    assertThat(obj.isHim).isEqualTo(true);
    assertThat(obj.isHer).isNil();
    cleanUp(obj);
};

TestUnit 'nyckel+n;;;henne (pronomen sektion 4 sätter isHer)' run {
    local obj = new Actor();
    obj.vocab = 'nyckel+n;;;henne';
    obj.initVocab();
    assertThat(obj.isHer).isEqualTo(true);
    assertThat(obj.isHim).isNil();
    cleanUp(obj);
};


// --- K: 3-komponents sammansättning (4 delar) ---
//
// arm:en+band:et^s+ur+et → armbandsuret
//   arm:en   = armen  (utrum)
//   band:et^s = armbandet + foge-s mot nästa led
//   ur+et    = uret   (neutrum, globaländelse)
//
// Fönster (start=1): arm/armen, armband/armbandet, armbandsur/armbandsuret
// Fönster (start=2): band/bandet, bandsur/bandsuret
// Fönster (start=3): ur/uret

TestUnit 'arm:en+band:et^s+ur+et (3 komponenter, foge-s och genusmod)' run {
    local obj = new Thing();
    obj.vocab = 'arm:en+band:et^s+ur+et';
    obj.initVocab();
    assertThat(obj.name).isEqualTo('armbandsur');
    assertThat(obj.definiteForm).isEqualTo('armbandsuret');
    assertThat(obj.isNeuter).isEqualTo(true);
    assertThat(obj.vocabWords).hasLength(12);
    assertThat(obj.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['arm', MatchNoun]);
    assertThat(obj.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['armen', MatchNoun]);
    assertThat(obj.vocabWords[3]).extractingProps([&wordStr, &posFlags]).isEqualTo(['armband', MatchNoun]);
    assertThat(obj.vocabWords[4]).extractingProps([&wordStr, &posFlags]).isEqualTo(['armbandet', MatchNoun]);
    assertThat(obj.vocabWords[5]).extractingProps([&wordStr, &posFlags]).isEqualTo(['armbandsur', MatchNoun]);
    assertThat(obj.vocabWords[6]).extractingProps([&wordStr, &posFlags]).isEqualTo(['armbandsuret', MatchNoun]);
    assertThat(obj.vocabWords[7]).extractingProps([&wordStr, &posFlags]).isEqualTo(['band', MatchNoun]);
    assertThat(obj.vocabWords[8]).extractingProps([&wordStr, &posFlags]).isEqualTo(['bandet', MatchNoun]);
    assertThat(obj.vocabWords[9]).extractingProps([&wordStr, &posFlags]).isEqualTo(['bandsur', MatchNoun]);
    assertThat(obj.vocabWords[10]).extractingProps([&wordStr, &posFlags]).isEqualTo(['bandsuret', MatchNoun]);
    assertThat(obj.vocabWords[11]).extractingProps([&wordStr, &posFlags]).isEqualTo(['ur', MatchNoun]);
    assertThat(obj.vocabWords[12]).extractingProps([&wordStr, &posFlags]).isEqualTo(['uret', MatchNoun]);
    cleanUp(obj);
};


// --- L: 5-komponents sammansättning ---
//
// djur+park:en+gång:en+vakt:en+bås+et → djurparkgångvaktbåset
//
// WordParts:
//   djur     → word=djur,  ending=et  (härleds: neutrum, konsonant → et)
//   park:en  → word=park,  ending=en  (utrum)
//   gång:en  → word=gång,  ending=en  (utrum)
//   vakt:en  → word=vakt,  ending=en  (utrum)
//   bås      → word=bås,   ending=et  (global, neutrum)
//
// n*(n+1) fönster för n=5 → 15 fönster × 2 ord = 30 ord totalt.
//
// start=1 (10 ord): djur, djuret, djurpark, djurparken, djurparkgång,
//                   djurparkgången, djurparkgångvakt, djurparkgångvakten,
//                   djurparkgångvaktbås, djurparkgångvaktbåset
// start=2 (8 ord):  park, parken, parkgång, parkgången,
//                   parkgångvakt, parkgångvakten, parkgångvaktbås, parkgångvaktbåset
// start=3 (6 ord):  gång, gången, gångvakt, gångvakten, gångvaktbås, gångvaktbåset
// start=4 (4 ord):  vakt, vakten, vaktbås, vaktbåset
// start=5 (2 ord):  bås, båset

TestUnit 'djur+park:en+gång:en+vakt:en+bås+et (5 komponenter)' run {
    local obj = new Thing();
    obj.vocab = 'djur+park:en+gång:en+vakt:en+bås+et';
    obj.initVocab();
    assertThat(obj.name).isEqualTo('djurparkgångvaktbås');
    assertThat(obj.definiteForm).isEqualTo('djurparkgångvaktbåset');
    assertThat(obj.isNeuter).isEqualTo(true);
    assertThat(obj.vocabWords).hasLength(30);
    // start=1
    assertThat(obj.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['djur', MatchNoun]);
    assertThat(obj.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['djuret', MatchNoun]);
    assertThat(obj.vocabWords[3]).extractingProps([&wordStr, &posFlags]).isEqualTo(['djurpark', MatchNoun]);
    assertThat(obj.vocabWords[4]).extractingProps([&wordStr, &posFlags]).isEqualTo(['djurparken', MatchNoun]);
    assertThat(obj.vocabWords[5]).extractingProps([&wordStr, &posFlags]).isEqualTo(['djurparkgång', MatchNoun]);
    assertThat(obj.vocabWords[6]).extractingProps([&wordStr, &posFlags]).isEqualTo(['djurparkgången', MatchNoun]);
    assertThat(obj.vocabWords[7]).extractingProps([&wordStr, &posFlags]).isEqualTo(['djurparkgångvakt', MatchNoun]);
    assertThat(obj.vocabWords[8]).extractingProps([&wordStr, &posFlags]).isEqualTo(['djurparkgångvakten', MatchNoun]);
    assertThat(obj.vocabWords[9]).extractingProps([&wordStr, &posFlags]).isEqualTo(['djurparkgångvaktbås', MatchNoun]);
    assertThat(obj.vocabWords[10]).extractingProps([&wordStr, &posFlags]).isEqualTo(['djurparkgångvaktbåset', MatchNoun]);
    // start=2
    assertThat(obj.vocabWords[11]).extractingProps([&wordStr, &posFlags]).isEqualTo(['park', MatchNoun]);
    assertThat(obj.vocabWords[12]).extractingProps([&wordStr, &posFlags]).isEqualTo(['parken', MatchNoun]);
    assertThat(obj.vocabWords[13]).extractingProps([&wordStr, &posFlags]).isEqualTo(['parkgång', MatchNoun]);
    assertThat(obj.vocabWords[14]).extractingProps([&wordStr, &posFlags]).isEqualTo(['parkgången', MatchNoun]);
    assertThat(obj.vocabWords[15]).extractingProps([&wordStr, &posFlags]).isEqualTo(['parkgångvakt', MatchNoun]);
    assertThat(obj.vocabWords[16]).extractingProps([&wordStr, &posFlags]).isEqualTo(['parkgångvakten', MatchNoun]);
    assertThat(obj.vocabWords[17]).extractingProps([&wordStr, &posFlags]).isEqualTo(['parkgångvaktbås', MatchNoun]);
    assertThat(obj.vocabWords[18]).extractingProps([&wordStr, &posFlags]).isEqualTo(['parkgångvaktbåset', MatchNoun]);
    // start=3
    assertThat(obj.vocabWords[19]).extractingProps([&wordStr, &posFlags]).isEqualTo(['gång', MatchNoun]);
    assertThat(obj.vocabWords[20]).extractingProps([&wordStr, &posFlags]).isEqualTo(['gången', MatchNoun]);
    assertThat(obj.vocabWords[21]).extractingProps([&wordStr, &posFlags]).isEqualTo(['gångvakt', MatchNoun]);
    assertThat(obj.vocabWords[22]).extractingProps([&wordStr, &posFlags]).isEqualTo(['gångvakten', MatchNoun]);
    assertThat(obj.vocabWords[23]).extractingProps([&wordStr, &posFlags]).isEqualTo(['gångvaktbås', MatchNoun]);
    assertThat(obj.vocabWords[24]).extractingProps([&wordStr, &posFlags]).isEqualTo(['gångvaktbåset', MatchNoun]);
    // start=4
    assertThat(obj.vocabWords[25]).extractingProps([&wordStr, &posFlags]).isEqualTo(['vakt', MatchNoun]);
    assertThat(obj.vocabWords[26]).extractingProps([&wordStr, &posFlags]).isEqualTo(['vakten', MatchNoun]);
    assertThat(obj.vocabWords[27]).extractingProps([&wordStr, &posFlags]).isEqualTo(['vaktbås', MatchNoun]);
    assertThat(obj.vocabWords[28]).extractingProps([&wordStr, &posFlags]).isEqualTo(['vaktbåset', MatchNoun]);
    // start=5
    assertThat(obj.vocabWords[29]).extractingProps([&wordStr, &posFlags]).isEqualTo(['bås', MatchNoun]);
    assertThat(obj.vocabWords[30]).extractingProps([&wordStr, &posFlags]).isEqualTo(['båset', MatchNoun]);
    cleanUp(obj);
};


class Frukt: Thing 'frukt+en;mog:en+na;frukter+na[pl]';
kiwi: Frukt 'kiwi+n';
rodFrukt: Frukt 'röd+a *';
mango: Frukt 'mango+n;-';
ananas: Frukt 'ananas+en;;-';


// Arv utan * — subklassen definierar eget substantivnamn. Adjektiv och plural
// ärvs automatiskt, men superklassens substantiv ärvs inte (kiwi heter inte "frukt").
TestUnit 'kiwi (ärvd vocab utan *)' run {
    //inspectVocabWords(kiwi);

    assertThat(kiwi.name).isEqualTo('kiwi');
    assertThat(kiwi.definiteForm).isEqualTo('kiwin');
    assertThat(kiwi.isNeuter).isEqualTo(nil);
    assertThat(kiwi.vocabWords).hasLength(6);

    assertThat(kiwi.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['kiwi', MatchNoun]);
    assertThat(kiwi.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['kiwin', MatchNoun]);
    assertThat(kiwi.vocabWords[3]).extractingProps([&wordStr, &posFlags]).isEqualTo(['mogen', MatchAdj]);
    assertThat(kiwi.vocabWords[4]).extractingProps([&wordStr, &posFlags]).isEqualTo(['mogna', MatchAdj]);
    assertThat(kiwi.vocabWords[5]).extractingProps([&wordStr, &posFlags]).isEqualTo(['frukter', MatchPlural]);
    assertThat(kiwi.vocabWords[6]).extractingProps([&wordStr, &posFlags]).isEqualTo(['frukterna', MatchPlural]);
};

// Arv med * — subklassen har inget eget substantivnamn utan lånar superklassens.
// * expanderas till superklassens substantiv; egna adjektiv läggs till i sektion 1.
TestUnit 'rodFrukt (arv med *)' run {
    //inspectVocabWords(rodFrukt);

    assertThat(rodFrukt.vocabWords).hasLength(8);

    assertThat(rodFrukt.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['röd', MatchAdj]);
    assertThat(rodFrukt.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['röda', MatchAdj]);
    assertThat(rodFrukt.vocabWords[3]).extractingProps([&wordStr, &posFlags]).isEqualTo(['frukt', MatchNoun]);
    assertThat(rodFrukt.vocabWords[4]).extractingProps([&wordStr, &posFlags]).isEqualTo(['frukten', MatchNoun]);
    assertThat(rodFrukt.vocabWords[5]).extractingProps([&wordStr, &posFlags]).isEqualTo(['mogen', MatchAdj]);
    assertThat(rodFrukt.vocabWords[6]).extractingProps([&wordStr, &posFlags]).isEqualTo(['mogna', MatchAdj]);
    assertThat(rodFrukt.vocabWords[7]).extractingProps([&wordStr, &posFlags]).isEqualTo(['frukter', MatchPlural]);
    assertThat(rodFrukt.vocabWords[8]).extractingProps([&wordStr, &posFlags]).isEqualTo(['frukterna', MatchPlural]);
};

// - i sektion 2 blockerar arv av adjektiv
TestUnit 'mango (blockerat adjektivarv med -)' run {
    //inspectVocabWords(mango);

    assertThat(mango.vocabWords).hasLength(4);

    assertThat(mango.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['mango', MatchNoun]);
    assertThat(mango.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['mangon', MatchNoun]);
    assertThat(mango.vocabWords[3]).extractingProps([&wordStr, &posFlags]).isEqualTo(['frukter', MatchPlural]);
    assertThat(mango.vocabWords[4]).extractingProps([&wordStr, &posFlags]).isEqualTo(['frukterna', MatchPlural]);
};

// - i sektion 3 blockerar arv av plural
TestUnit 'ananas (blockerat pluralarv med -)' run {
    //inspectVocabWords(ananas);

    assertThat(ananas.vocabWords).hasLength(4);

    assertThat(ananas.vocabWords[1]).extractingProps([&wordStr, &posFlags]).isEqualTo(['ananas', MatchNoun]);
    assertThat(ananas.vocabWords[2]).extractingProps([&wordStr, &posFlags]).isEqualTo(['ananasen', MatchNoun]);
    assertThat(ananas.vocabWords[3]).extractingProps([&wordStr, &posFlags]).isEqualTo(['mogen', MatchAdj]);
    assertThat(ananas.vocabWords[4]).extractingProps([&wordStr, &posFlags]).isEqualTo(['mogna', MatchAdj]);
};



// Substantiv följt av en oföränderlig prepositionsfras ('på burk') som ska
// ingå i det visade namnet, inte bara användas för att särskilja objekt.
// definiteForm sätts direkt av författaren eftersom den automatiska
// vokabuläranalysen inte kan härleda en bestämd form för denna typ av fras.
TestUnit 'Soppa på burk' run {
    //inspectVocabWords(soppburken);

    assertThat(soppburken.name).isEqualTo('soppa på burk');
    assertThat(soppburken.definiteForm).isEqualTo('soppan på burk');
    // Ingen shortNameAdjDef ska genereras eftersom definiteForm sattes direkt
    assertThat(soppburken.shortNameAdjDef).isNil();
    // isNeuter härleds från första ordet i definiteForm ('soppan'), inte
    // hela frasen ('burk') - utrum
    assertThat(soppburken.isNeuter).isNil();
    // theName ska returnera den bestämda formen ordagrant, utan artikel
    assertThat(soppburken.theName).isEqualTo('soppan på burk');
    assertThat(soppburken.aName).isEqualTo('en soppa på burk');
};

// 'för' är medvetet uteslutet ur prepList (se kommentar vid prepList i
// swedish.t). Legitima "for"-fall (syfte/mottagare) fungerar ändå genom att
// annotera ordet uttryckligen med [prep] i det enskilda objektets
// vocab-sträng, utan att påverka andra objekt.
instruktion: Thing 'instruktion+en för[prep] användning+en';

TestUnit 'instruktion för[prep] användning (legitim "for"-betydelse)' run {
    assertThat(instruktion.name).isEqualTo('instruktion');
    assertThat(instruktion.definiteForm).isEqualTo('instruktionen');
    // 'användning+en' hamnar efter prepositionen, ingår inte i name
    assertThat(instruktion.shortNameAdjDef).isNil();
    assertThat(instruktion.theName).isEqualTo('instruktionen');
    assertThat(instruktion.aName).isEqualTo('en instruktion');
};

// Utan 'för' i prepList tolkas 'för' bara som ytterligare ett ord före
// substantivet (som 'blå' i 'blå stol+en'), så hela frasen bevaras i name.
// 'för' saknar egen +notation och bidrar därför inte till shortNameAdjDef -
// samma kända begränsning som gäller för alla adjektiv utan +notation i
// sektion 1 (jämför testet 'blå stol+en (adj utan +notation i sektion 1)').
tradigInstruktion: Thing 'för tråkig+a instruktion+en';

TestUnit 'för tråkiga instruktionen (kollision med förstärkningsordet "för")' run {
    assertThat(tradigInstruktion.name).isEqualTo('för tråkig instruktion');
    assertThat(tradigInstruktion.definiteForm).isEqualTo('instruktionen');
    assertThat(tradigInstruktion.shortNameAdjDef).isEqualTo('tråkiga');
    assertThat(tradigInstruktion.isNeuter).isNil();
    // 'för' saknar +notation och faller därför bort ur den bestämda frasen,
    // precis som ett oannoterat adjektiv skulle göra
    assertThat(tradigInstruktion.theName).isEqualTo('den tråkiga instruktionen');
    assertThat(tradigInstruktion.aName).isEqualTo('en för tråkig instruktion');
};

// 'av' länkar här till en SPECIFIK referent ('kungen', bestämd form), inte en
// generisk kategori/material. Till skillnad från t.ex. 'papperslappsbit' går
// detta inte att göra om till ett sammansatt ord: 'kungastaty' skulle bara
// betyda "en staty föreställande en kung i allmänhet" - den bestämda
// referensen till DEN HÄR specifika kungen (som 'kungen' bär på) går
// förlorad. 'av' hamnar dessutom i prepList, så 'staty+n' blir substantivet
// och 'av kung+en' faller bort som en ren särskiljande kvalificerare (jämför
// 'nyckel till dörren') om vi inte sätter name/definiteForm direkt.
staty: Thing 'staty+n av kung+en'
    name = 'staty av kungen'
    definiteForm = 'statyn av kungen'
;

TestUnit 'staty av kungen (referens till något specifikt, ej sammansättning)' run {
    assertThat(staty.name).isEqualTo('staty av kungen');
    assertThat(staty.definiteForm).isEqualTo('statyn av kungen');
    // Ingen shortNameAdjDef ska genereras eftersom definiteForm sattes direkt
    assertThat(staty.shortNameAdjDef).isNil();
    assertThat(staty.isNeuter).isNil();
    // theName ska returnera den bestämda formen ordagrant, med 'av kungen' kvar
    assertThat(staty.theName).isEqualTo('statyn av kungen');
    assertThat(staty.aName).isEqualTo('en staty av kungen');
};

