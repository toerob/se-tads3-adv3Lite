#charset "utf-8"
#include "advlite.h"

/* ------------------------------------------------------------------------ */
/*
 *   Svensk kommando grammatik. Dessa regler definierar den övergripande
 *   meningssyntaxen och dess olika komponenter.
 *   
 *   Vi börjar analysera ett nytt kommando vid firstCommandPhrase (för det
 *   första kommandot på en rad) eller commandPhrase (för det andra och
 *   efterföljande kommandon på samma rad). Skillnaden mellan de två är att
 *   firstCommandPhrase accepterar aktörsorder (BOB, GÅ NORR eller SÄG TILL
 *   BOB ATT ÖPPNA DÖRREN), medan commandPhrase inte gör det.
 *   
 *   Andra språkmoduler behöver INTE duplicera den engelska grammatiken
 *   regel-för-regel. Du måste bara definiera reglerna markerade med
 *   [Required], eftersom dessa refereras från basbibliotekets parser. De
 *   [Required] grammatikobjekten måste existera och använda de givna
 *   basnamnen, men antalet regler för en given grammatik, taggnamnen och
 *   syntaxen definierad inom reglerna är alla upp till språkmodulen.
 *   
 *   Regler som INTE är markerade med [Required] är interna för den
 *   engelska grammatiken: de refereras bara från andra delar av den
 *   engelska grammatiken, så de är inte nödvändiga att existera i andra
 *   språk. En språkmodul är fri att använda sin egen helt annorlunda
 *   struktur för de interna reglerna, och bör göra det - strukturen bör
 *   baseras på den naturliga grammatiken i det implementerade språket, inte
 *   på hur de engelska reglerna här är strukturerade.
 *   
 *   Observera att basbiblioteket tillhandahåller ett antal
 *   XxxProduction-klasser för strukturella element som bör vara gemensamma
 *   för de flesta eller alla språk - NounPhraseProduction,
 *   PossessiveProduction, PronounProduction, etc. Som språkimplementerare
 *   är du INTE skyldig att implementera några grammatikregler baserade på
 *   någon av dessa klasser. Men du kommer förmodligen att vilja göra det
 *   ändå, eftersom dessa klasser är utformade för att göra ditt liv mycket
 *   enklare genom att göra det mesta av arbetet åt dig. Dessa klasser
 *   tillhandahåller kod som översätter informationen i syntaxträdet till
 *   motsvarande semantisk information i parsern. Om du inte skapar regler
 *   baserade på dessa klasser, måste du istället skriva din egen kod i
 *   reglerna som överför den nödvändiga informationen till parsern. XxxProduction
 *   klasserna är utformade för att vara abstrakta och språkoberoende, så om
 *   basbiblioteket gör sitt jobb korrekt, bör det vara enkelt att använda
 *   dessa klasser vid lämpliga punkter i grammatiken.
 */

/*
 *   firstCommandPhrase - den grundläggande grammatikregeln för det första
 *   kommandot på en kommandorad. [Required]
 */
grammar firstCommandPhrase(commandOnly): commandPhrase->cmd_
    : CommandProduction
;

grammar firstCommandPhrase(withActor):
    singleNounOnly->actor_ ',' commandPhrase->cmd_
    : CommandProduction
;

grammar firstCommandPhrase(askTellActorTo):
    ('fråga' | 'säga' | 'f' | 's') singleNounOnly->actor_
    'att' commandPhrase->cmd_
    : CommandProduction

    /* 
     *   Vi ger order till aktören i tredje person, eftersom vi gör det
     *   indirekt. Den faktiska imperativa predikatet här är SÄG ATT: detta
     *   adresserar parsern/berättaren, som vidarebefordrar kommandot till
     *   aktören på vår begäran.
     */
    actorPerson = 3
;

/*
 *   commandPhrase - den grundläggande grammatikregeln för det andra och
 *   efterföljande kommandot på en kommandorad. [Required]
 */
grammar commandPhrase(definiteConj):
    predicate->cmd_
    | predicate->cmd_ commandOnlyConjunction->conj_ *
    : CommandProduction
;

grammar commandPhrase(ambiguousConj):
    predicate->cmd_ commandOrNounConjunction->conj_
    commandPhrase->cmd2_
    : CommandProduction
;

/*
 *   Default command phrase - den grundläggande grammatikregeln för ett
 *   implicit kommando utan verb. I den engelska versionen är detta helt
 *   enkelt en substantivfras, som implicit betyder "undersök <substantivfras>".
 *   Andra språk kanske vill använda specifika substantivfrasformer för detta
 *   (t.ex. ett böjt språk kanske vill använda ackusativformen här).
 */
grammar defaultCommandPhrase(examine):
    defaultVerbPhrase->cmd_
    : CommandProduction
;

grammar defaultVerbPhrase(noun):
    singleDobj
    : VerbProduction
    action = Parser.DefaultAction
    verbPhrase = 'undersök/undersöker (vad)'
    missingQ = 'vad vill du undersöka'
;

grammar actorBadCommandPhrase(main):
    singleNounOnly->actor_ ',' miscWordList
    | ('fråga' | 'säga' | 'f' | 's') singleNounOnly->actor_ 'att' miscWordList
    : Production
;

grammar commandOnlyConjunction(sentenceEnding):
    '.'
    | '!'
    | '?'
    : Production

    /* 
     *   dessa avslutar meningen - vilket betyder att efter en av dessa kan
     *   du adressera en ny aktör
     */
    endOfSentence = true
;

grammar commandOnlyConjunction(nonSentenceEnding):
    'sedan'
    | 'och' 'sedan'
    | ',' 'sedan'
    | ',' 'och' 'sedan'
    | ';'
    : Production
;

grammar commandOrNounConjunction(main):
    ','
    | 'och'
    | ',' 'och'
    : Production
;

grammar nounConjunction(main):
    ','
    | 'och'
    | ',' 'och'
    : Production
;

grammar nounList(terminal): terminalNounPhrase->np_ : Production
;

grammar nounList(nonTerminal): completeNounPhrase->np_ : Production
;

grammar nounList(list): nounMultiList->lst_ : Production
;

grammar nounList(empty): [badness 500] : EmptyNounProduction
;

grammar nounMultiList(multi):
    nounMultiList->np1_ nounConjunction terminalNounPhrase->np2_
    : NounListProduction
;

grammar nounMultiList(nonterminal): nonTerminalNounMultiList->lst_
    : Production
;

grammar nonTerminalNounMultiList(pair):
    completeNounPhrase->np1_ nounConjunction completeNounPhrase->np2_
    : NounListProduction
;

grammar nonTerminalNounMultiList(multi):
    nonTerminalNounMultiList->np1_ nounConjunction completeNounPhrase->np2_
    : NounListProduction
;

grammar exceptList(main): exceptListBody->lst_ : ExceptListProduction
;

grammar exceptListBody(single): exceptNounPhrase->np_ : Production
;

grammar exceptListBody(list):
    exceptNounPhrase->np1_ nounConjunction exceptListBody->np2_
    : NounListProduction
;

grammar exceptNounPhrase(singleComplete): completeNounPhraseWithoutAll->np_
    : Production
;

grammar exceptNounPhrase(singlePossessive): possessiveNounPhrase->poss_
    : Production
;

/*
 *   singleNoun grammatikregeln är för predikatobjektsplatser som kräver en
 *   enda substantivfras (till skillnad från en lista med substantiv). Denna
 *   regel måste definieras av varje språk, eftersom basparsern använder den
 *   för att kontrollera implicit UNDERSÖK kommandon.
 *   
 *   [Required] 
 */

grammar singleNoun(normal): singleNounOnly->np_ : Production
;

grammar singleNoun(empty): [badness 500] : EmptyNounProduction
;

/*
 *   En användare kan försöka använda en substantivlista med mer än ett
 *   objekt (en "multi-lista") där ett enda substantiv krävs. Detta är ett
 *   semantiskt fel snarare än ett grammatiskt fel, så vi definierar en
 *   grammatikregel för det (trots den uppenbara konflikten med namnet
 *   singleNoun). Vi använder dock BadListProduction för detta matchobjekt -
 *   detta säkerställer att vi poängsätter det lägre än en version utan en
 *   lista, och att om vi når resolutionsstadiet, kommer vi att visa ett
 *   lämpligt felmeddelande.
 */
grammar singleNoun(multiple):
    [badness 100] nounMultiList->np_
    : BadListProduction
;


grammar singleNounOnly(main):
    terminalNounPhrase->np_
    | completeNounPhrase->np_
    : Production
;

grammar putPrepSingleNoun(main):
    putPrep->prep_ singleNoun->np_
    : Production
;

grammar putPrep(main):
    'i' | 'in' | 'i' 'till'
    | 'på' | 'uppå'
    | 'bakom'
    | 'under'
    : Production
;

grammar inSingleNoun(main):
     singleNoun->np_ | ('i' | 'in' | 'in' 'i' | 'in' 'till') singleNoun->np_
    : Production
;

grammar forSingleNoun(main):
   singleNoun->np_ | 'för' singleNoun->np_ : Production
;

grammar toSingleNoun(main):
   singleNoun->np_ | 'till' singleNoun->np_ : Production
;

grammar throughSingleNoun(main):
   singleNoun->np_ | ('genom' | 'via') singleNoun->np_
   : Production
;

grammar fromSingleNoun(main):
   singleNoun->np_ | 'från' singleNoun->np_ : Production
;

grammar onSingleNoun(main):
   singleNoun->np_ | ('på' | 'uppå') singleNoun->np_
    : Production
;

grammar withSingleNoun(main):
   singleNoun->np_ | 'med' singleNoun->np_ : Production
;

grammar atSingleNoun(main):
   singleNoun->np_ | 'vid' singleNoun->np_ : Production
;

grammar outOfSingleNoun(main):
   singleNoun->np_ | 'ut' 'ur' singleNoun->np_ : Production
;

grammar overSingleNoun(main):
    singleNoun->np_ | 'över' singleNoun->np_ : Production
;

grammar underSingleNoun(main):
    singleNoun->np_ | 'under' singleNoun->np_ : Production
;

grammar behindSingleNoun(main):
    singleNoun->np_ | 'bakom' singleNoun->np_ : Production
;

grammar aboutTopicPhrase(main):
   'om' topicPhrase->np_ | topicPhrase->np_ 
   : TopicNounProduction
;

grammar completeNounPhrase(main):
    completeNounPhraseWithAll->np_ | completeNounPhraseWithoutAll->np_
    : Production
;

grammar completeNounPhrase(miscPrep):
    [badness 100] completeNounPhrase->np1_
        ('med' | 'i' 'till' | 'genom' | 'via' | 'för' | 'till'
         | 'uppå' | 'vid' | 'under' | 'bakom')
        completeNounPhrase->np2_
    : Production
;

grammar completeNounPhraseWithoutAll(main):
    qualifiedNounPhrase->np_ | pronounPhrase->np_
    : Production
;

grammar pronounPhrase(it):  'den' : PronounProduction
    pronoun = It
;
grammar pronounPhrase(itNeuter): 'det' : PronounProduction
    pronoun = ItNeuter
;
grammar pronounPhrase(them): 'dem' : PronounProduction
    pronoun = Them
;
grammar pronounPhrase(him):  'honom' : PronounProduction
    pronoun = Him
;
grammar pronounPhrase(her):  'henne' : PronounProduction
    pronoun = Her
;

grammar pronounPhrase(itself): 'sig' : PronounProduction
    pronoun = Itself
;

grammar pronounPhrase(themselves):
    'sig' | 'sig själva' : PronounProduction
    pronoun = Themselves
;

grammar pronounPhrase(himself): 'sig själv' : PronounProduction
    pronoun = Himself
;

grammar pronounPhrase(herself): 'sig själv' : PronounProduction
    pronoun = Herself
;

grammar pronounPhrase(you):
    'du' | 'dig själv' | 'er själva' : PronounProduction
    pronoun = You
;
grammar pronounPhrase(me): 'mig' | 'mig själv' : PronounProduction
    pronoun = Me
;

grammar pronounPhrase(us): 'oss' | 'oss själva'
    : PronounProduction
    pronoun = Us
;


grammar completeNounPhraseWithAll(main):
    'alla' | 'allt'
    : Production

    determiner = All
;

grammar terminalNounPhrase(allBut):
    ('alla' | 'allt') ('utom' | 'förutom')
        exceptList->except_
    : Production

    determiner = All
;

grammar terminalNounPhrase(pluralExcept):
    (qualifiedPluralNounPhrase->np_ | detPluralNounPhrase->np_)
    ('utom' | 'förutom') exceptList->except_
    : Production
;

grammar terminalNounPhrase(anyBut):
    'någon' nounPhrase->np_
    ('utom' | 'förutom') exceptList->except_
    : Production

    determiner = Indefinite
;

grammar qualifiedNounPhrase(main):
    qualifiedSingularNounPhrase->np_
    | qualifiedPluralNounPhrase->np_
    : Production
;

// TODO: här är problemet, vid parsing avkrävs den/det en/ett framför substantivet,
// någon form av "indet" kanske kunna användas hellre:
//
// Skapar därför unqualifiedSingularNounPhrase som kan användas utan kvalificera ordet
// grammar unqualifiedSingularNounPhrase(definite):
//    indetSingularNounPhrase->np_
//    : Production
//
//    determiner = Definite
//;

grammar qualifiedSingularNounPhrase(definite):
    //('den' | 'det') indetSingularNounPhrase->np_
    // OBS: temporärt fulhack för att lösa problemet med att behöva ange substantivet i bestämd form
    // Detta behöver lösas bättre

    ('den' | 'det' |) indetSingularNounPhrase->np_
    : Production

    determiner = Definite
;

grammar qualifiedSingularNounPhrase(indefinite):
    ('en' | 'ett') indetSingularNounPhrase->np_
    : Production

    determiner = Indefinite
;

grammar qualifiedSingularNounPhrase(arbitrary):
    ('någon' | 'en' | 'ett') indetSingularNounPhrase->np_
    : Production

    determiner = Indefinite
;

grammar qualifiedSingularNounPhrase(possessive):
    possessiveAdjPhrase->poss_ indetSingularNounPhrase->np_
    | indetSingularNounPhrase->np_ 'av' possessiveNounPhrase->poss_
    : Production
;

grammar qualifiedSingularNounPhrase(anyPlural):
    ('någon' | 'en' | 'ett') 'av' explicitDetPluralNounPhrase->np_
    : Production

    determiner = Indefinite
;

grammar qualifiedSingularNounPhrase(theOneIn):
    ('den'|'det') 'som' ('är' | 'var') locationPrep->prep_ completeNounPhraseWithoutAll->cont_
    : LocationalProduction

    determiner = Definite
;

grammar qualifiedSingularNounPhrase(theOneContaining):
    ('den'|'det') 'som' contentsPrepOrVerb->prep_ completeNounPhraseWithoutAll->cont_
    : ContentsQualifierProduction

    determiner = Definite
;

grammar qualifiedSingularNounPhrase(anyOneIn):
    ('någon' | 'en' | 'ett') ('som' ('är' | 'var')) locationPrep->prep_
    completeNounPhraseWithoutAll->cont_
    : LocationalProduction

    determiner = Indefinite
;

grammar locationPrep(in):
    'i' | 'inuti' | 'inuti' 'av'
    : LocationPrepProduction

    locType = In
;

grammar locationPrep(on):
    'på' | 'uppå' | 'på' 'toppen' 'av'
    : LocationPrepProduction

    locType = On
;

grammar locationPrep(from):
    'från'
    : LocationPrepProduction

    locType = nil
;

grammar contentsPrep(main):
    'av' | 'innehållande'
    : Production
;

grammar contentsPrepOrVerb(main):
    'innehåller' | 'har' | contentsPrep
    : Production
;

grammar indetSingularNounPhrase(basic):
    nounPhraseWithContents->np_
    : Production
;

grammar indetSingularNounPhrase(locational):
    nounPhraseWithContents->np_
    ('som' ('är' | 'var')) locationPrep->prep_ completeNounPhraseWithoutAll->cont_
    : LocationalProduction
;

grammar nounPhraseWithContents(basic):
    nounPhrase->np_
    : Production
;

grammar nounPhraseWithContents(contents):
    nounPhraseWithContents->np_ contentsPrep->prep_ nounPhrase->cont_
    : ContentsQualifierProduction
;

grammar qualifiedPluralNounPhrase(determiner):
    'några' detPluralOnlyNounPhrase->np_
    : Production

    determiner = Indefinite
;

grammar qualifiedPluralNounPhrase(anyNum):
    ('några' | ) numberPhrase->quant_ indetPluralNounPhrase->np_
    | ('några' | ) numberPhrase->quant_ 'av' explicitDetPluralNounPhrase->np_
    : QuantifierProduction

    determiner = Indefinite
;

grammar qualifiedPluralNounPhrase(allNum):
    'alla' numberPhrase->quant_ indetPluralNounPhrase->np_
    | 'alla' numberPhrase->quant_ 'av' explicitDetPluralNounPhrase->np_
    : QuantifierProduction

    /* 
     *   även om ordet är ALLA, gör numret detta definitivt:
     *   ALLA SJU innebär att det finns EXAKT sju saker vi pratar om
     */
    determiner = Definite
;

grammar qualifiedPluralNounPhrase(both):
    'båda' detPluralNounPhrase->np_
    | 'båda' 'av' explicitDetPluralNounPhrase->np_
    : QuantifierProduction

    /* 
     *   BÅDA är effektivt ekvivalent med DE TVÅ - det innebär att det
     *   finns ENDAST två objekt vi kan prata om
     */
    determiner = Definite
    numval = 2
;

grammar qualifiedPluralNounPhrase(definiteNum):
    'de' numberPhrase->quant_ indetPluralNounPhrase->np_
    : QuantifierProduction

    determiner = Definite
;

grammar qualifiedPluralNounPhrase(all):
    'alla' detPluralNounPhrase->np_
    | 'alla' 'av' explicitDetPluralNounPhrase->np_
    : Production

    determiner = All
;

grammar qualifiedPluralNounPhrase(theOnesIn):
    ('de' 'som' ('är' | 'var') | 'allt' 'som' ('är' | 'var'))
    locationPrep->prep_ completeNounPhraseWithoutAll->cont_
    : LocationalProduction

    determiner = All
;

grammar qualifiedPluralNounPhrase(theOnesContaining):
    ('de' 'som' | 'allt' 'som') contentsPrepOrVerb->prep_ completeNounPhraseWithoutAll->cont_
    : ContentsQualifierProduction

    determiner = All
;

grammar detPluralNounPhrase(main):
    indetPluralNounPhrase->np_ | explicitDetPluralNounPhrase->np_
    : Production
;

grammar detPluralOnlyNounPhrase(main):
    implicitDetPluralOnlyNounPhrase->np_
    | explicitDetPluralOnlyNounPhrase->np_
    : Production
;

grammar implicitDetPluralOnlyNounPhrase(main):
    indetPluralOnlyNounPhrase->np_
    : Production
;

grammar explicitDetPluralNounPhrase(definite):
    'de' indetPluralNounPhrase->np_
    : Production

    determiner = Definite
;

grammar explicitDetPluralNounPhrase(definiteNumber):
    'de' numberPhrase->quant_ indetPluralNounPhrase->np_
    : QuantifierProduction

    determiner = Definite
;

grammar explicitDetPluralNounPhrase(possessive):
    possessiveAdjPhrase->poss_ indetPluralNounPhrase->np_
    | indetPluralNounPhrase->np_ 'av' possessiveNounPhrase->poss_
    : Production
;

grammar explicitDetPluralNounPhrase(possessiveNumber):
    possessiveAdjPhrase->poss_ numberPhrase->quant_ indetPluralNounPhrase->np_
    | 'de' numberPhrase->quant_ indetPluralNounPhrase->np_ 'av' possessiveNounPhrase->poss_
    : QuantifierProduction

    /* 
     *   possessiven gör detta definitivt: BOBS FEM BÖCKER innebär att
     *   Bob har EXAKT fem böcker
     */
    determiner = Definite
;

grammar explicitDetPluralNounPhrase(possessiveNumber2):
    numberPhrase->quant_ indetPluralNounPhrase->np_ 'av' possessiveNounPhrase->poss_
    : QuantifierProduction

    /* FEM BÖCKER AV BOB är obestämd */
    determiner = Indefinite
;

grammar explicitDetPluralOnlyNounPhrase(definite):
    'de' indetPluralOnlyNounPhrase->np_
    : Production

    determiner = Definite
;

grammar explicitDetPluralOnlyNounPhrase(definiteNumber):
    'de' numberPhrase->quant_ indetPluralNounPhrase->np_
    : QuantifierProduction

    determiner = Definite
;

grammar explicitDetPluralOnlyNounPhrase(possessive):
    possessiveAdjPhrase->poss_ indetPluralOnlyNounPhrase->np_
    | indetPluralOnlyNounPhrase->np_ 'av' possessiveNounPhrase->poss_
    : Production
;

grammar explicitDetPluralOnlyNounPhrase(possessiveNumber):
    possessiveAdjPhrase->poss_ numberPhrase->quant_ indetPluralNounPhrase->np_
    | 'de' numberPhrase->quant_ indetPluralNounPhrase->np_ 'av' possessiveNounPhrase->poss_
    : QuantifierProduction

    /* possessiven gör detta definitivt */
    determiner = Definite
;

grammar explicitDetPluralOnlyNounPhrase(possessiveNumber2):
    numberPhrase->quant_ indetPluralNounPhrase->np_ 'av' possessiveNounPhrase->poss_
    : QuantifierProduction

    /* FEM BÖCKER AV BOB är obestämd */
    determiner = Indefinite
;

grammar indetPluralNounPhrase(basic):
    pluralPhraseWithContents->np_
    : Production
;

grammar indetPluralNounPhrase(locational):
    pluralPhraseWithContents->np_ ('som' ('är' | 'var')) locationPrep->prep_ completeNounPhraseWithoutAll->cont_
    : LocationalProduction
;

grammar pluralPhraseWithContents(basic):
    pluralPhrase->np_
    : Production
;

grammar pluralPhraseWithContents(contents):
    pluralPhraseWithContents->np_ contentsPrep->prep_ nounPhrase->cont_
    : ContentsQualifierProduction
;

grammar indetPluralOnlyNounPhrase(basic):
    pluralPhrase->np_
    : Production
;

grammar indetPluralOnlyNounPhrase(locational):
    pluralPhrase->np_ ('som' ('är' | 'var')) locationPrep->prep_ completeNounPhraseWithoutAll->cont_
    : LocationalProduction
;

grammar nounPhrase(main): compoundNounPhrase->np_
    : CoreNounPhraseProduction
;

grammar pluralPhrase(main): compoundPluralPhrase->np_
    : CoreNounPhraseProduction
;

grammar compoundNounPhrase(simple): simpleNounPhrase->np_
    : Production
;

grammar compoundNounPhrase(of):
    simpleNounPhrase->np1_ compoundNounPrep->prep_ compoundNounArticle compoundNounPhrase->np2_
    : Production
;

grammar compoundNounPrep(main):
    'av'->prep_ | 'till'->prep_ | 'för'->prep_ | 'från'->prep_ | 'med'->prep_
    : Production
;

grammar compoundNounArticle(main):
    ('den' | 'det' | 'en' | 'ett')
    : Production
;

grammar compoundPluralPhrase(simple): simplePluralPhrase->np_
    : Production
;

grammar compoundPluralPhrase(of):
    simplePluralPhrase->np1_ compoundNounPrep->prep_ compoundNounArticle->article_ compoundNounPhrase->np2_
    : Production
;

grammar simpleNounPhrase(noun): nounWord->noun_ : Production
;

grammar simpleNounPhrase(list): nounWord->noun_ simpleNounPhrase->np_
    : Production
;

grammar simpleNounPhrase(literal): literalNounPhrase->noun_
    : Production
;

grammar simpleNounPhrase(literalAndList):
    literalNounPhrase->noun_ simpleNounPhrase->np_
    : Production
;

grammar simpleNounPhrase(adjAndOne): noun->noun_ 'en'
    : Production
;

grammar simpleNounPhrase(adjAndOnes): noun->noun_ 'några'
    : Production
;

grammar simpleNounPhrase(misc):
    [badness 200] miscWordList->lst_ : Production
;

grammar simpleNounPhrase(empty): [badness 600] : EmptyNounProduction
;

grammar literalNounPhrase(number):
    numberPhrase->num_ | poundNumberPhrase->num_
    : Production
;

grammar literalNounPhrase(string): quotedStringPhrase->str_
    : Production
;

grammar nounWord(noun): noun->noun_ : Production
;

grammar nounWord(nounApostS): nounApostS->noun_ tokApostropheS->apost_
    : Production
    grammarInfoForBuild()
    {
        /* kombinera substantivet och apostrof-S till en enda token */
        local gi = grammarInfo();
        return [gi[1], noun_ + apost_];
    }
;

grammar nounWord(nounAbbr): noun->noun_ tokAbbrPeriod->period_
    : Production
;

grammar possessiveAdjPhrase(its): 'dess' : PossessiveProduction
    pronoun = It
;
grammar possessiveAdjPhrase(his): 'hans' : PossessiveProduction
    pronoun = Him
;
grammar possessiveAdjPhrase(her): 'hennes' : PossessiveProduction
    pronoun = Her
;
grammar possessiveAdjPhrase(their): 'deras' : PossessiveProduction
    pronoun = Them
;
/*
 *   1:a och 2:a persons possessiver samlas i en regel per person trots att
 *   Swedish har tre former (din/ditt/dina, min/mitt/mina).  Anledningen är
 *   att splittning i separata regler (din→You, ditt→YouNeuter, dina→Yall)
 *   inte ger någon fördel för entydighetsupplösning.
 *
 *   matchVocabPoss i parsern försöker matcha possessiva pronomen mot
 *   föregående substantivfraser i samma kommando via pronoun.matchObj().
 *   Men matchPronoun() hanterar bara tredje persons pronomen (Him/Her/It/
 *   ItNeuter/Them) — det finns inget fall för You, YouNeuter eller Yall.
 *   Därför misslyckas steget alltid för 1:a/2:a person, och parsern faller
 *   tillbaka till pronoun.resolve() som alltid returnerar spelarkaraktären.
 *   Vilken böjningsform spelaren skriver (din/ditt/dina) spelar alltså
 *   ingen roll för hur ägaren löses upp.
 *
 *   Tredje persons possessiver (hans/hennes/dess/deras) är däremot redan
 *   separata regler, eftersom matchPronoun() faktiskt hanterar dem och
 *   entydighetsupplösning mot föregående fraser fungerar korrekt där.
 */
grammar possessiveAdjPhrase(your): ('din'|'ditt'|'dina') : PossessiveProduction
    pronoun = You
;
grammar possessiveAdjPhrase(my): ('min'|'mitt'|'mina') : PossessiveProduction
    pronoun = Me
;
grammar possessiveAdjPhrase(yAll): 'dina' : PossessiveProduction
    pronoun = Yall
;

grammar possessiveAdjPhrase(npApostropheS):
    nounPhrase->np_ tokApostropheS : PossessiveProduction
;

grammar possessiveAdjPhrase(definiteNpApostropheS):
    ('den'|'det') nounPhrase->np_ tokApostropheS : PossessiveProduction

    determine = Definite
;

grammar possessiveAdjPhrase(indefiniteNpApostropheS):
    ('en' | 'ett') nounPhrase->np_ tokApostropheS : PossessiveProduction

    determiner = Indefinite
;

grammar possessiveNounPhrase(its): 'dess': PossessiveProduction
    pronoun = It
;
grammar possessiveNounPhrase(his): 'hans': PossessiveProduction
    pronoun = Him
;
grammar possessiveNounPhrase(hers): 'hennes': PossessiveProduction
    pronoun = Her
;
grammar possessiveNounPhrase(theirs): 'deras': PossessiveProduction
    pronoun = Them
;
grammar possessiveNounPhrase(yours): 'ditt' : PossessiveProduction
    pronoun = You
;
grammar possessiveNounPhrase(mine): 'mitt' : PossessiveProduction
    pronoun = Me
;

grammar possessiveNounPhrase(npApostropheS):
    (nounPhrase->np_ | pluralPhrase->np_) tokApostropheS
    : PossessiveProduction
;

grammar simplePluralPhrase(plural): simpleNounPhrase->noun_ : Production
;

grammar simplePluralPhrase(adjAndOnes): noun->noun_ 'några'
    : Production
;

grammar simplePluralPhrase(empty): [badness 600] : EmptyNounProduction
;

grammar simplePluralPhrase(misc):
    [badness 300] miscWordList->lst_ : Production
;

grammar topicPhrase(main): singleNoun->np_ : TopicNounProduction
;

grammar topicPhrase(misc): miscWordList->np_ : TopicNounProduction
;

grammar quotedStringPhrase(main): tokString->str_ : Production
   getStringText() { return stripQuotesFrom(str_); }
;

/*
 *   Service rutin: ta bort citattecken från en *möjligen* citerad sträng.
 *   Om strängen börjar med ett citattecken tar vi bort det öppna citattecknet.
 *   Om det börjar med ett citattecken och slutar med ett motsvarande stängt
 *   citattecken tar vi bort det också.
 */
stripQuotesFrom(str)
{
    local hasOpen;
    local hasClose;

    /* förutsätt att vi inte hittar öppna eller stängda citattecken */
    hasOpen = hasClose = nil;

    /*
     *   Kontrollera citattecken. Vi accepterar vanliga ASCII "raka"
     *   enkla eller dubbla citattecken, samt Latin-1 krulliga enkla eller
     *   dubbla citattecken. De krulliga citattecknen måste användas i sin
     *   normala
     */
    if (str.startsWith('\'') || str.startsWith('"'))
    {
        /* enkelt eller dubbelt citattecken - kontrollera om det finns ett matchande stängt citattecken */
        hasOpen = true;
        hasClose = (str.length() > 2 && str.endsWith(str.substr(1, 1)));
    }
    else if (str.startsWith('`'))
    {
        /* enkelt inåtlutat citattecken - kontrollera om det finns något av de två typerna av stängt citattecken */
        hasOpen = true;
        hasClose = (str.length() > 2
                    && (str.endsWith('`') || str.endsWith('\'')));
    }
    else if (str.startsWith('\u201C'))
    {
        /* det är ett krulligt dubbelt citattecken */
        hasOpen = true;
        hasClose = str.endsWith('\u201D');
    }
    else if (str.startsWith('\u2018'))
    {
        /* det är ett krulligt enkelt citattecken */
        hasOpen = true;
        hasClose = str.endsWith('\u2019');
    }

    /* trimma bort citattecknen */
    if (hasOpen)
    {
        if (hasClose)
            str = str.substr(2, str.length() - 2);
        else
            str = str.substr(2);
    }

    /* returnera den modifierade texten */
    return str;
}


grammar literalPhrase(string): quotedStringPhrase->str_ : LiteralNounProduction
;

grammar literalPhrase(miscList): miscWordList->misc_ : LiteralNounProduction
;

grammar literalPhrase(empty): [badness 400]: EmptyNounProduction
;

grammar miscWordList(wordOrNumber):
    tokWord->txt_ | tokInt->txt_ | tokApostropheS->txt_
    | tokPoundInt->txt_ | tokString->txt_ | tokAbbrPeriod->txt_
    : MiscWordListProduction
;

grammar miscWordList(list):
    (tokWord->txt_ | tokInt->txt_ | tokApostropheS->txt_ | tokAbbrPeriod->txt_
     | tokPoundInt->txt_ | tokString->txt_) miscWordList->lst_
    : MiscWordListProduction
;

/*
 *   Den översta nivån av disambiguering grammatik. Parsern använder detta för att analysera
 *   inmatning som kan vara ett svar på en disambiguering prompt ("Vilken menade du...?").
 *   
 *   Vi accepterar hela substantivfraser och olika fragment av substantivfraser som
 *   svar på dessa frågor. Vi accepterar fragment eftersom (a) användare
 *   är vana vid att kunna svara med ett ord eller två från många andra IF-spel, och (b) allt vi behöver är något som
 *   skiljer ett objekt från ett annat.
 *   
 *   Detta bör använda DisambigProduction som basklass för matchträdet.
 *   
 *   [Required] 
 */
grammar mainDisambigPhrase(main):
    disambigPhrase->dp_
    | disambigPhrase->dp_ '.'
    : DisambigProduction
;

grammar disambigPhrase(all):
    'alla' | 'allt' | 'alla' 'av' 'dem' : Production

    determiner = All
;

grammar disambigPhrase(both): 'båda' | 'båda' 'av' 'dem'
    : QuantifierProduction

    /* BÅDA är definitivt eftersom det innebär att det finns EXAKT två matchningar */
    determiner = Definite
    numval = 2
;

grammar disambigPhrase(any): 'någon' | 'någon' 'av' 'dem' : Production
    determiner = Indefinite
;

grammar disambigPhrase(list): disambigList->lst_ : Production
;

grammar disambigPhrase(ordinalList):
    disambigOrdinalList->lst_ 'några'
    | 'de' disambigOrdinalList->lst_ 'några'
    : Production

    determiner = Definite
;

grammar disambigPhrase(locational):
    locationPrep->prep_ completeNounPhraseWithoutAll->cont_
    : LocationalProduction

    determiner = Definite
;

grammar disambigOrdinalList(tail):
    disambigOrdinalItem->np1_ ('och' | ',') disambigOrdinalItem->np2_
    : NounListProduction
;

grammar disambigOrdinalList(head):
    disambigOrdinalItem->np1_ ('och' | ',') disambigOrdinalList->np2_
    : NounListProduction
;

dictionary property ordinalWord;
grammar disambigOrdinalItem(main):
    ordinalWord->ord_
    : OrdinalProduction

    determiner = Definite

    /* slå upp värdet av ordningsordet */
    ordval() { return cmdDict.findWord(ord_, &ordinalWord)[1].ordinalVal; }
;

grammar disambigList(single): disambigListItem->np1_ :
    NounListProduction
;

grammar disambigList(list):
    disambigListItem->np1_ commandOrNounConjunction disambigList->np2_
    : NounListProduction
;

grammar disambigListItem(ordinal):
    ordinalWord->ord_
    | ordinalWord->ord_ 'en'
    | 'de' ordinalWord->ord_
    | 'de' ordinalWord->ord_ 'en'
    : OrdinalProduction

    determiner = Definite

    /* slå upp värdet av ordningsordet */
    ordval() { return cmdDict.findWord(ord_, &ordinalWord)[1].ordinalVal; }
;

grammar disambigListItem(noun):
    completeNounPhraseWithoutAll->np_
    | terminalNounPhrase->np_
    : Production
;

grammar disambigListItem(plural):
    pluralPhrase->np_
    : Production

    determiner = Definite
;

grammar disambigListItem(possessive):
    possessiveNounPhrase->poss_
    : Production
;



/*
 *   Ordningsord. Vi definierar en begränsad uppsättning av dessa, eftersom vi bara använder
 *   dem i några få speciella sammanhang där det skulle vara orimligt att behöva
 *   ens så många som definieras här.
 */
#define defOrdinal(str, val) object ordinalWord=#@str ordinalVal=val

defOrdinal(former, 1);
defOrdinal(first, 1);
defOrdinal(second, 2);
defOrdinal(third, 3);
defOrdinal(fourth, 4);
defOrdinal(fifth, 5);
defOrdinal(sixth, 6);
defOrdinal(seventh, 7);
defOrdinal(eighth, 8);
defOrdinal(ninth, 9);
defOrdinal(tenth, 10);
defOrdinal(eleventh, 11);
defOrdinal(twelfth, 12);
defOrdinal(thirteenth, 13);
defOrdinal(fourteenth, 14);
defOrdinal(fifteenth, 15);
defOrdinal(sixteenth, 16);
defOrdinal(seventeenth, 17);
defOrdinal(eighteenth, 18);
defOrdinal(nineteenth, 19);
defOrdinal(twentieth, 20);
defOrdinal(1st, 1);
defOrdinal(2nd, 2);
defOrdinal(3rd, 3);
defOrdinal(4th, 4);
defOrdinal(5th, 5);
defOrdinal(6th, 6);
defOrdinal(7th, 7);
defOrdinal(8th, 8);
defOrdinal(9th, 9);
defOrdinal(10th, 10);
defOrdinal(11th, 11);
defOrdinal(12th, 12);
defOrdinal(13th, 13);
defOrdinal(14th, 14);
defOrdinal(15th, 15);
defOrdinal(16th, 16);
defOrdinal(17th, 17);
defOrdinal(18th, 18);
defOrdinal(19th, 19);
defOrdinal(20th, 20);

/*
 *   det speciella 'sista' ordningsordet - värdet -1 är speciellt för att indikera det
 *   sista objektet i en lista
 */
defOrdinal(last, -1);
defOrdinal(latter, -1);


grammar numberObjPhrase(main): numberPhrase->num_ : NumberNounProduction
;

grammar numberPhrase(digits): tokInt->num_ : NumberNounProduction
    numval = (toInteger(num_))
;

grammar numberPhrase(spelled): spelledNumber->num_ : NumberNounProduction
    numval = (num_.numval)
;

grammar poundNumberPhrase(main): tokPoundInt->num_ : NumberNounProduction
;

/*
 *   Numeriska bokstavliga. Vi definierar en uppsättning specialobjekt för nummer:
 *   varje objekt definierar ett nummer och ett värde för numret.
 */
dictionary property digitWord, teenWord, tensWord;
#define defDigit(num, val) object digitWord=#@num numval=val
#define defTeen(num, val)  object teenWord=#@num numval=val
#define defTens(num, val)  object tensWord=#@num numval=val

defDigit(one, 1);
defDigit(two, 2);
defDigit(three, 3);
defDigit(four, 4);
defDigit(five, 5);
defDigit(six, 6);
defDigit(seven, 7);
defDigit(eight, 8);
defDigit(nine, 9);
defTeen(ten, 10);
defTeen(eleven, 11);
defTeen(twelve, 12);
defTeen(thirteen, 13);
defTeen(fourteen, 14);
defTeen(fifteen, 15);
defTeen(sixteen, 16);
defTeen(seventeen, 17);
defTeen(eighteen, 18);
defTeen(nineteen, 19);
defTens(twenty, 20);
defTens(thirty, 30);
defTens(forty, 40);
defTens(fifty, 50);
defTens(sixty, 60);
defTens(seventy, 70);
defTens(eighty, 80);
defTens(ninety, 90);

grammar spelledSmallNumber(digit): digitWord->num_ : Production
    numval()
    {
        /* slå upp enhetsordet i ordboken */
        return cmdDict.findWord(num_, &digitWord)[1].numval;
    }
;

grammar spelledSmallNumber(teen): teenWord->num_ : Production
    numval()
    {
        /* slå upp enhetsordet i ordboken */
        return cmdDict.findWord(num_, &teenWord)[1].numval;
    }
;

grammar spelledSmallNumber(tens): tensWord->num_ : Production
    numval()
    {
        /* slå upp enhetsordet i ordboken */
        return cmdDict.findWord(num_, &tensWord)[1].numval;
    }
;

grammar spelledSmallNumber(tensAndUnits):
    tensWord->tens_ '-'->sep_ digitWord->units_
    | tensWord->tens_ digitWord->units_
    : Production
    
    //    numval = (tens_.numval + units_.numval)
    numval()
    {
        return cmdDict.findWord(tens_, &tensWord)[1].numval +
            cmdDict.findWord(units_, &digitWord)[1].numval;
    }
;

grammar spelledSmallNumber(zero): 'noll' : Production
    numval = 0
;

grammar spelledHundred(small): spelledSmallNumber->num_ : Production
    numval = (num_.numval)
;

grammar spelledHundred(hundreds): spelledSmallNumber->hun_ 'hundra'
    : Production

    numval = (hun_.numval*100)
;

grammar spelledHundred(hundredsPlus):
    spelledSmallNumber->hun_ 'hundra' spelledSmallNumber->num_
    | spelledSmallNumber->hun_ 'hundra' 'och'->and_ spelledSmallNumber->num_
    : Production

    numval = (hun_.numval*100 + num_.numval)
;

grammar spelledHundred(aHundred): 'ett' 'hundra' : Production
;

grammar spelledHundred(aHundredPlus):
    'ett' 'hundra' 'och' spelledSmallNumber->num_
    : Production

    numval = (100 + num_.numval)
;

grammar spelledThousand(thousands): spelledHundred->thou_ 'tusen'
    : Production

    numval = (thou_.numval*1000)
;

grammar spelledThousand(thousandsPlus):
    spelledHundred->thou_ 'tusen' spelledHundred->num_
    : Production

    numval = (thou_.numval*1000 + num_.numval)
;

grammar spelledThousand(thousandsAndSmall):
    spelledHundred->thou_ 'tusen' 'och' spelledSmallNumber->num_
    : Production

    numval = (thou_.numval*1000 + num_.numval)
;

grammar spelledThousand(aThousand): 'ett' 'tusen' : Production
    numval = 1000
;

grammar spelledThousand(aThousandAndSmall):
    'ett' 'tusen' 'och' spelledSmallNumber->num_
    : Production

    numval = (1000 + num_.numval)
;

grammar spelledMillion(millions): spelledHundred->mil_ 'miljon': Production
    numval = (mil_.numval*1000000)
;

grammar spelledMillion(millionsPlus):
    spelledHundred->mil_ 'miljon'
    (spelledThousand->nxt_ | spelledHundred->nxt_)
    : Production

    numval = (mil_.numval*1000000 + nxt_.numval)
;

grammar spelledMillion(aMillion): 'en' 'miljon' : Production
    numval = 1000000
;

grammar spelledMillion(aMillionAndSmall):
    'en' 'miljon' 'och' spelledSmallNumber->num_
    : Production

    numval = (1000000 + num_.numval)
;

grammar spelledMillion(millionsAndSmall):
    spelledHundred->mil_ 'miljon' 'och' spelledSmallNumber->num_
    : Production

    numval = (mil_.numval*1000000 + num_.numval)
;

grammar spelledNumber(main):
    spelledHundred->num_
    | spelledThousand->num_
    | spelledMillion->num_
    : Production

    numval = (num_.numval)
;

/*
 *   Den huvudsakliga grammatiken för ett OOPS-kommando. Detta är separat från den huvudsakliga
 *   kommandogrammatiken, eftersom OOPS-kommandon är något speciella (i
 *   synnerhet kan de inte blandas med andra kommandon på en inmatningsrad).
 *   
 *   Grammatiken för ett OOPS-kommando måste inkludera en eller flera
 *   OopsProduction-objekt. Var och en av dessa måste ha en '->toks_'-egenskap
 *   som ger sub-produktionen med den bokstavliga tokenlistan för
 *   korrigeringen.
 *   
 *   [Required] 
 */
grammar oopsCommand(main):
    oopsPhrase->oops_ | oopsPhrase->oops_ '.' : Production
;

grammar oopsPhrase(main):
    'oops' miscWordList->toks_
    | 'oops' ',' miscWordList->toks_
    | 'o' miscWordList->toks_
    | 'o' ',' miscWordList->toks_
    : OopsProduction
;

/* ------------------------------------------------------------------------ */
/*
 *   Riktning grammatikregler.
 */
class DirectionName : object;

#define DefineLangDir(root, dirNames, backPre, depName) \
grammar directionName(root): dirNames: Production \
   dir = root##Dir \
; \
\
   root##Direction: DirectionName \
   name = #@root \
   backToPrefix = backPre\
   departureName = depName 

DefineLangDir(north, 'norr' | 'n', 'tillbaka till', 'till norr');
DefineLangDir(south, 'söder' | 's', 'tillbaka till', 'till söder');
DefineLangDir(east, 'öster' | 'ö', 'tillbaka till', 'till öster');
DefineLangDir(west, 'väster' | 'v', 'tillbaka till', 'till väster');
DefineLangDir(northeast, 'nordost' | 'no'| 'nö', 'tillbaka till', 'till nordost');
DefineLangDir(northwest, 'nordväst' | 'nv', 'tillbaka till', 'till nordväst');
DefineLangDir(southeast, 'sydost' | 'so'| 'sö', 'tillbaka till', 'till sydost');
DefineLangDir(southwest, 'sydväst' | 'sv', 'tillbaka till', 'till sydväst');
DefineLangDir(up, 'upp' | 'u', 'tillbaka', 'uppåt');
DefineLangDir(down, 'ner' | 'n', 'tillbaka', 'neråt');
DefineLangDir(in, 'in', 'tillbaka', 'inåt');
DefineLangDir(out, 'ut', 'tillbaka', 'utåt');
DefineLangDir(port, 'babord' | 'b', 'tillbaka till', 'till babord');
DefineLangDir(starboard, 'styrbord' | 'sb', 'tillbaka till', 'till styrbord');
DefineLangDir(aft, 'akterut', 'tillbaka', 'akterut');
DefineLangDir(fore, 'förut' | 'f' | 'framåt' ,  'tillbaka', 'förut');
//

/* ------------------------------------------------------------------------ */
/*
 *   Ja eller Nej fras. Detta är ett svar på en enkel Ja/Nej fråga.
 *   
 *   [Required] 
 */
grammar yesOrNoPhrase(yes): 'ja' : YesOrNoProduction
    answer = true
;
grammar yesOrNoPhrase(no): 'nej' : YesOrNoProduction
    answer = nil
;


/* ------------------------------------------------------------------------ */
/*
 *   Verb grammatik (predikat) regler för svenska.
 *   
 *   Svenskans predikatsyntax är mycket positionsbaserad. Det vill säga, rollen för
 *   varje ord i ett predikat bestäms till stor del av dess position i
 *   frasen. Det finns flera vanliga mönster för predikatets ordföljd, men det specifika mönstret som gäller för ett givet verb är
 *   i huvudsak idiomatiskt för det verbet, särskilt med avseende på
 *   komplementord (som "upp" i "plocka upp"). Vår metod för att
 *   definiera predikatgrammatiken är därför att definiera en separat,
 *   anpassad syntaxregel för varje verb. Detta gör det enkelt att lägga till regler för
 *   de udda små idiomen i svenska verb.
 *   
 *   För verb som tar indirekta objekt, introduceras det indirekta objektet vanligtvis
 *   av en preposition (t.ex. LÄGG NYCKELN I LÅSET). Eftersom vi
 *   anser att prepositionen i ett sådant fall är en del av verbets
 *   grammatiska struktur, skriver vi in den direkt i grammatikregeln som en
 *   bokstavlig. Detta innebär att vi inte skulle kunna analysera inmatning som
 *   saknar hela den indirekta objektfrasen (t.ex. LÄGG NYCKELN). Vi vill inte
 *   bara avvisa dessa utan förklaring, så vi måste definiera separata
 *   grammatikregler för de förkortade verben. Några av dessa fall är giltiga
 *   kommandon i sig: LÅS UPP DÖRREN och LÅS UPP DÖRREN MED NYCKELN är båda
 *   grammatiskt giltiga. Men LÄGG NYCKELN är det inte, så vi måste markera detta som
 *   saknar sitt indirekta objekt. Vi gör detta genom att ställa in egenskapen
 *   missingRole för dessa regler till rollen (vanligtvis IndirectObject) för frasen som saknas.
 *   
 *   Varje VerbRule har flera egenskaper och metoder som den kan eller måste
 *   definiera:
 *   
 *   action [Required] - Den associerade Action som utförs när detta
 *   verb analyseras. Basbiblioteket kräver denna egenskap.
 *   
 *   verbPhrase - Meddelandebyggande mallen för verbet. Biblioteket
 *   använder detta för att konstruera meddelanden för att beskriva den associerade åtgärden.
 *   Formatet är 'verb/verbing (dobj) (iobj) (accessory)'. Varje objekt
 *   roll i parentes består av en valfri preposition och ordet
 *   'vad' eller 'vem'. Till exempel, 'fråga/frågar (vem) (om vad)'.
 *   Utanför parenteserna kan du också inkludera verbkomplementord
 *   före det första objektet eller efter det sista, men aldrig mellan objekten:
 *   till exempel, 'plocka/plockar upp (vad)'.
 *   
 *   missingQ - mallen för att ställa frågor om saknade objekt. Detta
 *   består av en fråga per objekt, separerade med semikolon, i
 *   ordningen dobj, iobj, accessory. Du behöver bara så många frågor som verbet
 *   har objektplatser (dvs. du behöver bara en iobj-fråga om verbet
 *   tar ett indirekt objekt). Frågan är helt enkelt av formen
 *   "vad vill du <verb>", men du kan också inkludera orden "det"
 *   och "den" för att hänvisa till "det andra" objektet i verbet. "Det" kommer
 *   att ersättas med det/honom/henne/dem som är lämpligt, och "den" med
 *   den/dem. Använd det-dobj, det-iobj, det-acc för att specificera vilket annat objekt
 *   du pratar om (vilket aldrig är nödvändigt för två-objekt verb,
 *   eftersom det bara finns ett annat objekt). Sätt hela 'det' frasen,
 *   inklusive prepositioner, i parentes för att göra det valfritt; det kommer
 *   att utelämnas om objektet inte är en del av kommandoinmatningen. Detta är bara
 *   nödvändigt för objekt som visas tidigare i verbregeln, eftersom det
 *   löses från vänster till höger.
 *   
 *   missingRole - objektrollen (DirectObject, etc) som uttryckligen
 *   saknas från denna grammatiksyntax. Detta är för regler som du definierar
 *   specifikt för att känna igen delvis inmatning, som "LÄGG <dobj>". Parsern
 *   kommer att fråga efter det saknade objektet när den löser en sådan regel.
 *   
 *   answerMissing(cmd, np) - basbiblioteket kallar detta när spelaren
 *   svarar på parserns fråga om det saknade substantivfrasen.
 *   'cmd' är kommandot, och 'np' är substantivfrasen som analyserades från
 *   användarens svar på frågan. Detta kallas från basbiblioteket men
 *   är inte obligatoriskt, eftersom det är rent rådgivande. Poängen med denna
 *   rutin är att låta verbet ändra kommandot enligt svaret.
 *   Till exempel, på svenska har vi ett generiskt Lägg <dobj> verb som frågar
 *   var man ska lägga dobj. Om användaren säger "i lådan", kan vi ändra
 *   åtgärden till Lägg I; om användaren säger "på bordet", kan vi ändra
 *   åtgärden till Lägg På.
 *   
 *   dobjReply, iobjReply, accReply - substantivfrasproduktionen att använda för
 *   att analysera ett svar på frågan om det saknade objektet för den
 *   motsvarande rollen. Spelare svarar ibland på en fråga som "Vad vill du
 *   lägga det i?" genom att börja svaret med samma preposition i
 *   frågan: "i lådan". För att stödja detta kan du specificera en substantivfrasproduktion
 *   som börjar med den lämpliga prepositionen (inSingleNoun, onSingleNoun, etc).
 *   
 *   (Observera att basbiblioteket inte ställer några krav på exakt
 *   hur verbreglerna definieras. I synnerhet behöver du inte
 *   definiera en regel per verb, som vi gör på svenska. Den svenska
 *   modulens en-verb/en-regel tillvägagångssätt kanske inte passar bra när
 *   man implementerar ett mycket böjt språk, eftersom sådana språk vanligtvis är
 *   mycket mer flexibla när det gäller ordföljd, vilket skapar ett brett spektrum av möjliga
 *   fraseringar för varje verb. Det kan vara enklare för ett sådant språk att definiera
 *   en uppsättning universella verbgrammatikregler som täcker de vanliga strukturerna
 *   för alla verb, och sedan definiera de individuella verben som enkla
 *   ordförrådsord som passar in i denna universella frasstruktur.)
 */
VerbRule(Take)
    ('ta' | 'tag' | 'plocka') ('upp'|) multiDobj
    : VerbProduction
    action = Take
    verbPhrase = 'ta/tar (vad)'
    missingQ = 'vad vill du ta'
;

VerbRule(TakeFrom)
    ('ta' | 'få') multiDobj ('från' | 'ut' 'ur' | 'av') singleIobj
    |   ('ta' 'bort' multiDobj 'från' singleIobj)
    : VerbProduction
    action = TakeFrom
    verbPhrase = 'ta/tar (vad) (från vad)'
    missingQ = 'vad vill du ta;vad vill du ta det från'
    iobjReply = fromSingleNoun
;

VerbRule(Remove)
    'ta' 'bort' multiDobj
    : VerbProduction
    action = Remove
    verbPhrase = 'ta bort/tar bort (vad)'
    missingQ = 'vad vill du ta bort'
;

VerbRule(Drop)
    ('släpp' | 'lägg' | 'sätt') ('ner'|) multiDobj
    : VerbProduction
    action = Drop
    verbPhrase = 'släpp/släpper (vad)'
    missingQ = 'vad vill du släppa'
;

VerbRule(SetDownWhat)
    'sätt' 'ner'
    : VerbProduction
    action = Drop
    verbPhrase = 'släpp/släpper (vad)'
    missingQ = 'vad vill du släppa'
    missingRole = DirectObject    
;
    

VerbRule(Examine)
    ('undersök' | 'inspektera' | 'x' |'titta' 'på' | 't' 'på') multiDobj
    : VerbProduction
    action = Examine
    verbPhrase = 'undersök/undersöker (vad)'
    missingQ = 'vad vill du undersöka'
;

VerbRule(LookX)
    ('titta'|'t') multiDobj
    : VerbProduction
    action = Examine
    verbPhrase = 'undersök/undersöker (vad)'
    missingQ = 'vad vill du titta på'
    
    /* 
     *   Vi ger detta en lägre prioritet för att säkerställa att TITT PÅ FOO analyseras som
     *   (TITT PÅ) FOO snarare än TITT (PÅ FOO).
     */
    priority = 40
;

VerbRule(LookAtWhat)
    ('titta' | 't') 'på'
    : VerbProduction
    action = Examine
    verbPhrase = 'titta/tittar (på vad)'
    missingQ = 'vad vill du titta på'
    missingRole = DirectObject
;

VerbRule(Read)
    'läs' singleDobj
    : VerbProduction
    action = Read
    verbPhrase = 'läs/läser (vad)'
    missingQ = 'vad vill du läsa'
;

VerbRule(LookIn)
    ('titta' | 't') ('i' | 'inuti') multiDobj
    : VerbProduction
    action = LookIn
    verbPhrase = 'titta/tittar (i vad)'
    missingQ = 'vad vill du titta i'   
    priority = 60
;

VerbRule(LookInWhat)
    ('titta' | 't') ('i' | 'inuti') 
    : VerbProduction
    action = LookIn
    verbPhrase = 'titta/tittar (i vad)'
    missingQ = 'vad vill du titta i'   
    priority = 60
    missingRole = DirectObject
;

VerbRule(Search)
    'sök' multiDobj
    : VerbProduction
    action = Search
    verbPhrase = 'sök/söker (vad)'
    missingQ = 'vad vill du söka'
;

VerbRule(LookThrough)
    ('titta' | 't' | 'kika') ('genom' | 'via') multiDobj
    : VerbProduction
    action = LookThrough
    verbPhrase = 'titta/tittar (genom vad)'
    missingQ = 'vad vill du titta genom'
;

VerbRule(LookThroughWhat)
    ('titta' | 't' | 'kika') ('genom' | 'via') 
    : VerbProduction
    action = LookThrough
    verbPhrase = 'titta/tittar (genom vad)'
    missingQ = 'vad vill du titta genom'
    missingRole = DirectObject
;

VerbRule(LookUnder)
    ('sök' | 'titta' | 't') 'under' multiDobj
    : VerbProduction
    action = LookUnder
    verbPhrase = 'titta/tittar (under vad)'
    missingQ = 'vad vill du titta under'   
;

VerbRule(LookUnderWhat)
    ('sök' | 'titta' | 't') 'under' 
    : VerbProduction
    action = LookUnder
    verbPhrase = 'titta/tittar (under vad)'
    missingQ = 'vad vill du titta under'   
    missingRole = DirectObject
;


VerbRule(LookBehind)
    ('sök' | 'titta' | 't') 'bakom' multiDobj
    : VerbProduction
    action = LookBehind
    verbPhrase = 'titta/tittar (bakom vad)'
    missingQ = 'vad vill du titta bakom'
;

VerbRule(LookBehindWhat)
    ('sök' | 'titta' | 't') 'bakom'
    : VerbProduction
    action = LookBehind
    verbPhrase = 'titta/tittar (bakom vad)'
    missingQ = 'vad vill du titta bakom'
    missingRole = DirectObject
;

/* 
 *   Grammatiken för att titta i en viss riktning. Icke-engelska spel kan ändra detta genom
 *   att tillhandahålla modify VerbRule(LookDir).
 */
VerbRule(LookDir)
    ('titta' | 't') ('till' |) ('den'|'det'|) singleDir    
    : VerbProduction
    action = LookDir
    verbPhrase = 'titta/tittar (vart)' 
    priority = 40
;

 VerbRule(LookDir2)
    ('titta' | 't') ('till' |) ('den'|'det'|) singleDir ('och' | 'sen' | 'och' 'sen')
    directionName->dirMatch2   
    : VerbProduction
    action = LookDir2
    verbPhrase = 'titta/tittar (vart)'
    priority = 40
;


VerbRule(Feel)
    'känn'  multiDobj
    : VerbProduction
    action = Feel
    verbPhrase = 'känn/känner (vad)'
    missingQ = 'vad vill du känna'
;

VerbRule(Touch)
    'rör' multiDobj
    : VerbProduction
    action = Touch
    verbPhrase = 'rör/rör (vad)'
    missingQ = 'vad vill du röra'
;

VerbRule(Taste)
    'smaka' multiDobj
    : VerbProduction
    action = Taste
    verbPhrase = 'smaka/smakar (vad)'
    missingQ = 'vad vill du smaka'
;

VerbRule(SmellSomething)
    ('lukta' | 'sniffa') multiDobj
    : VerbProduction
    action = SmellSomething
    verbPhrase = 'lukta/luktar (vad)'
    missingQ = 'vad vill du lukta'
;

VerbRule(Smell)
    'lukta' | 'sniffa'
    : VerbProduction
    action = Smell
    verbPhrase = 'lukta/luktar'
;

VerbRule(ListenTo)
    ('hör' | 'lyssna' 'på' ) multiDobj
    : VerbProduction
    action = ListenTo
    verbPhrase = 'lyssna/lyssnar (på vad)'
    missingQ = 'vad vill du lyssna på'
;

VerbRule(Listen)
    'lyssna' | 'hör'
    : VerbProduction
    action = Listen
    verbPhrase = 'lyssna/lyssnar'
;


VerbRule(PutIn)
    ('lägg' | 'placera' | 'sätt' | 'stoppa') multiDobj
        ('i' | 'in' | 'i' 'till' | 'inuti' | 'inuti' 'av') singleIobj
    : VerbProduction
    action = PutIn
    verbPhrase = 'lägg/lägger (vad) (i vad)'
    missingQ = 'vad vill du lägga (i det);vad vill du lägga det i'
    iobjReply = inSingleNoun
;

VerbRule(PutOn)
    (('lägg' | 'placera' | 'släpp' | 'sätt') multiDobj ('på' | 'uppå') singleIobj)
    | 'lägg' multiDobj 'ner' 'på' singleIobj
    : VerbProduction
    action = PutOn
    verbPhrase = 'lägg/lägger (vad) (på vad)'
    missingQ = 'vad vill du lägga (på det);vad vill du lägga det på'
    iobjReply = onSingleNoun
;

VerbRule(PutUnder)
    ('lägg' | 'placera' | 'sätt') multiDobj 'under' singleIobj
    : VerbProduction
    action = PutUnder
    verbPhrase = 'lägg/lägger (vad) (under vad)'
    missingQ = 'vad vill du lägga (under det);'
             + 'vad vill du lägga det under'
;

VerbRule(PutBehind)
    ('lägg' | 'placera' | 'sätt') multiDobj 'bakom' singleIobj
    : VerbProduction
    action = PutBehind
    verbPhrase = 'lägg/lägger (vad) (bakom vad)'
    missingQ = 'vad vill du lägga (bakom det);'
    + 'vad vill du lägga det bakom'
;

VerbRule(PutWhere)
    [badness 500] ('lägg' | 'placera') multiDobj
    : VerbProduction
    action = PutIn
    verbPhrase = 'lägg/lägger (vad) (i vad)'
    missingQ = 'vad vill du lägga;var vill du lägga det'

    missingRole = IndirectObject
    iobjReply = putPrepSingleNoun

    /* 
     *   när spelaren tillhandahåller vårt saknade indirekta objekt genom att svara
     *   på frågan "var vill du lägga det", ändrar vi
     *   åtgärden enligt prepositionen i det indirekta objektet svaret
     */
    answerMissing(cmd, np)
    {
        /* detta gäller endast det indirekta objektet */
        if (np.role == IndirectObject && np.prod.prep_ != nil)
        {
            /* få prepositionerna de använde */
            local preps = np.prod.prep_.getText();

            /* 
             *   leta efter en mall med samma prepositioner bland de
             *   olika Lägg grammatikreglerna
             */
            foreach (local action in [PutIn, PutOn, PutBehind, PutUnder])
            {
                if (action.grammarTemplates
                    .indexWhich({ t: t.find(preps) }) != nil)
                {
                    /* hittade det - använd denna åtgärd */
                    cmd.action = action;
                    return;
                }
            }
        }
    }

    priority = 25
;

VerbRule(Wear)
    ('bär' | 'klä' 'på' | 'ta' 'på' | 'sätt' 'på') ('mig'|'dig'|) multiDobj
    | 'sätt'  multiDobj 'på'
    : VerbProduction
    action = Wear
    verbPhrase = 'bär/bär (vad)'
    missingQ = 'vad vill du bära'
;

VerbRule(Doff)
    ('klä'|'ta') 'av' ('mig'|'dig'|) multiDobj
    | 'ta' ('av'|'bort') multiDobj 
    : VerbProduction
    action = Doff
    verbPhrase = 'ta av/tar av (vad)'
    missingQ = 'vad vill du ta av'
;

VerbRule(TakeOff)
    'ta' 'av'
    : VerbProduction
    action = TakeOff
    verbPhrase = 'ta/tar av'
    priority = 40
;

VerbRule(Kiss)
    'kyss' singleDobj
    : VerbProduction
    action = Kiss
    verbPhrase = 'kyss/kyssar (vem)'
    missingQ = 'vem vill du kyssa'
    dobjReply = singleNoun
;

VerbRule(Query)
    ('f' | 'fråga') ('vad' ->qtype | 'vem' ->qtype | 'var' -> qtype | 'varför'
                   ->qtype | 'när' -> qtype| 'hur' -> qtype | 'huruvida' ->
                    qtype | 'ifall' -> qtype) topicDobj
    : VerbProduction
    action = Query
    verbPhrase = 'fråga/frågar (vad)'
    missingQ = 'vad vill du fråga'
    priority = 60
    dobjReply = topicPhrase
;

VerbRule(Query2)
    ('vad' ->qtype | 'vem' ->qtype | 'var' -> qtype | 'varför'
                   ->qtype | 'när' -> qtype| 'hur' -> qtype) topicDobj
    : VerbProduction
    action = Query
    verbPhrase = 'fråga/frågar (vad)'
    missingQ = 'vad vill du fråga'
    priority = 60
    dobjReply = topicPhrase
;

VerbRule(QueryAbout)
    ('f' | 'fråga') singleDobj ('vad' ->qtype | 'vem' ->qtype 
                               | 'var' -> qtype | 'varför' ->qtype 
                               | 'när' -> qtype | 'hur' -> qtype 
                               
                               // OBS: vi vill inte ha 'om' här, eftersom 
                               // AskTopic då blir överskuggad av QueryAbout
                                // whether
                               | 'huruvida' -> qtype 
                               // if 
                               | 'ifall' -> qtype)  
                               topicIobj
    : VerbProduction
    action = QueryAbout
    verbPhrase = 'fråga/frågar (vad)'
    missingQ = 'vad vill du fråga'
    priority = 60
    dobjReply = singleNoun
    iobjReply = topicPhrase
;

VerbRule(QueryVague)
    ('f' | 'fråga'|) ('vad' ->qtype | 'vem' ->qtype | 'var' -> qtype | 'varför'
                   ->qtype | 'när' -> qtype| 'hur' -> qtype | 'huruvida' ->
                    qtype | 'ifall' -> qtype) 
    : VerbProduction
    action = QueryVague
    verbPhrase = 'fråga/frågar (vad)'
    missingQ = 'vad vill du fråga'
    dobjReply = topicPhrase
    priority = 60
;

VerbRule(AuxQuery)
    ('f' | 'fråga'|) ('gör' | 'gör' | 'gjorde' | 'är' | 'har' |'kan' |
     'kunde' | 'skulle' | 'borde' | 'var' ) topicDobj
    :VerbProduction
    action = Query
    missingQ = 'vad vill du fråga'
    dobjReply = topicPhrase
    priority = 60
    qtype = 'ifall'
;

/* 
 *   För frågor, omvandla en apostrof-s form till den underliggande qtype plus är så
 *   att grammatiken definierad omedelbart ovan kan matchas.
 */

queryPreParser: StringPreParser
    doParsing(str, which)
    {
        local s = str.toLower();
        
        /* Först, kontrollera att detta ser ut som en fråga */
        if(s.startsWith('f ') || s.startsWith('fråga ') || s.substr(1, 3) is in
           ('vem', 'vad', 'var', 'varför', 'hur'))
        {
            str = s.findReplace(['vad\'s','vem\'s', 'var\'s', 'varför\'s',
                'när\'s', 'hur\'s'], ['vad är', 'vem är', 'var är', 'varför
                    är', 'när är', 'hur är'], ReplaceOnce);        
                       
        
        }

    
        return str;
    }
;

VerbRule(AskFor)
    ('f' | 'fråga') singleDobj 'för' topicIobj
    | ('f' | 'fråga') 'för' topicIobj 'från' singleDobj
    : VerbProduction
    action = AskFor
    verbPhrase = 'fråga/frågar (vem) (för vad)'
    missingQ = 'vem vill du fråga;vad vill du fråga det för'
    dobjReply = singleNoun
    iobjReply = forSingleNoun
;

VerbRule(AskWhomFor)
    ('f' | 'fråga') 'för' topicIobj
    : VerbProduction
    action = AskFor
    verbPhrase = 'fråga/frågar (vem) (för vad)'
    missingQ = 'vem vill du fråga;vad vill du fråga det för'
    iobjReply = topicPhrase
    priority = 25
;

VerbRule(AskForImplicit)
    ('f' | 'fråga')  'för' topicIobj
    : VerbProduction
    action = AskForImplicit
    verbPhrase = 'fråga/frågar (vem) (för vad)'
    missingQ = 'vem vill du fråga;vad vill du fråga det för'
    iobjReply = topicPhrase
    priority = 60
;



VerbRule(AskAbout)
    ('f' | 'fråga') singleDobj 'om' topicIobj
    : VerbProduction
    action = AskAbout
    verbPhrase = 'fråga/frågar (vem) (om vad)'
    missingQ = 'vem vill du fråga;vad vill du fråga {det} om'
    dobjReply = singleNoun
    iobjReply = aboutTopicPhrase
;


VerbRule(AskAboutImplicit)
    ('f' | ('fråga' | 'säga' 'mig') ('om')) topicIobj
    : VerbProduction
    action = AskAboutImplicit
    verbPhrase = 'fråga/frågar (vem) (om vad)'
    missingQ = 'vem vill du fråga;vad vill du fråga {det} om'
    iobjReply = aboutTopicPhrase
    priority = 45
;

VerbRule(AskAboutWhat)
    [badness 500] 'fråga' singleDobj
    : VerbProduction
    action = AskAbout
    verbPhrase = 'fråga/frågar (vem) (om vad)'
    missingQ = 'vem vill du fråga;vad vill du fråga {det} om'

    missingRole = IndirectObject
    iobjReply = aboutTopicPhrase

    priority = 25
;


VerbRule(TellAbout)
    ('berätta'|'säg') singleDobj 'om' topicIobj
    : VerbProduction
    action = TellAbout
    verbPhrase = 'säga/säger (vem) (om vad)'
    missingQ = 'vem vill du säga;vad vill du säga {det} om'
    dobjReply = singleNoun
    iobjReply = aboutTopicPhrase
;

VerbRule(TellAboutImplicit)
     ('berätta'|'säg') 'om' topicIobj
    : VerbProduction
    action = TellAboutImplicit
    verbPhrase = 'säga/säger (vem) (om vad)'
    missingQ = 'vem vill du säga;vad vill du säga {det} om'
    iobjReply = aboutTopicPhrase
;

VerbRule(TellAboutWhat)
    [badness 500] 'säga' singleDobj
    : VerbProduction
    action = TellAbout
    verbPhrase = 'säga/säger (vem) (om vad)'
    missingQ = 'vem vill du säga;vad vill du säga {det} om'

    missingRole = IndirectObject
    dobjReply = singleNoun
    iobjReply = aboutTopicPhrase

    priority = 25    
;

VerbRule(TellTo)
    'säga' singleDobj 'att' literalIobj
    : VerbProduction
    action = TellTo
    verbPhrase = 'säga/säger (vem) (att vad)'
    missingQ = 'vem vill du säga;vad vill du säga {det} att göra'
    iobjReply = literalPhrase
;

VerbRule(TalkAbout)
    'prata' 'med' singleDobj 'om' topicIobj
    : VerbProduction
    action = TalkAbout
    verbPhrase = 'prata/pratar (med vem) (om vad)'
    missingQ = 'med vem vill du prata;vad vill du prata med {det} om'
    dobjReply = toSingleNoun
    iobjReply = aboutTopicPhrase
;

VerbRule(TalkAboutImplicit)
    'prata' 'om' topicIobj
    : VerbProduction
    action = TalkAboutImplicit
    verbPhrase = 'prata/pratar (om vad)'
    missingQ = 'vad vill du prata om'
    iobjReply = aboutTopicPhrase
;

VerbRule(AskVague)
    [badness 500] 'fråga' singleDobj topicIobj
    : VerbProduction
    action = AskAbout
    verbPhrase = 'fråga/frågar (vem)'
    missingQ = 'vem vill du fråga;vad vill du fråga {det} om'
    dobjReply = singleNoun
    iobjReply = topicPhrase
;

VerbRule(TellVague)
    ('säga'|'s') singleDobj topicIobj
    : VerbProduction
    action = TellAbout
    verbPhrase = 'säga/säger (vem)'
    missingQ = 'vem vill du säga;vad vill du säga {det} om'
    priority = 40
    dobjReply = singleNoun
    iobjReply = topicPhrase    
;

VerbRule(TalkTo)
    ('hälsa' ('på'|) | 'säga' 'hej' 'till' | 'prata' 'med') singleDobj
    : VerbProduction
    action = TalkTo
    verbPhrase = 'prata/pratar (med vem)'
    missingQ = 'med vem vill du prata'
    dobjReply = singleNoun
;

VerbRule(Topics)
    'ämnen'
    : VerbProduction
    action = Topics
    verbPhrase = 'visa/visar ämnen'
;

VerbRule(Hello)
    ('säga' | ) ('hej' | 'hallå' | 'hej')
    : VerbProduction
    action = Hello
    verbPhrase = 'säga/säger hej'
     /* Ge detta prioritet över SÄGA ÄMNE */
    priority = 60
;

VerbRule(Goodbye)
    ('säga' | ()) ('hejdå' | 'adjö' | 'farväl' | 'hej då')
    : VerbProduction
    action = Goodbye
    verbPhrase = 'säga/säger hejdå'
;

VerbRule(Yes)
    'ja' | ('säga' 'ja') | 'acceptera'
    : VerbProduction
    action = SayYes
    verbPhrase = 'säga/säger ja'
    /* Ge detta prioritet över SÄGA ÄMNE */
    priority = 60
;

VerbRule(No)
    'nej' | 'negativ' | ('säg'|'tacka') 'nej' 
    : VerbProduction
    action = SayNo
    verbPhrase = 'säga/säger nej'
    /* Ge detta prioritet över SÄGA ÄMNE */
    priority = 60
;

VerbRule(Yell)
    'skrik' | 'vråla' | 'ropa' | 'gorma'
    : VerbProduction
    action = Yell
    verbPhrase = 'skrika/skriker'
;

VerbRule(GiveTo)
    ('ge' | 'erbjud') multiDobj 'till' singleIobj
    : VerbProduction
    action = GiveTo
    verbPhrase = 'ge/ger (vad) (till vem)'
    missingQ = 'vad vill du ge (till det);vem vill du ge det till'
    iobjReply = toSingleNoun
;

VerbRule(GiveToType2)
    ('ge' | 'erbjud') singleIobj multiDobj
    : VerbProduction
    action = GiveTo
    verbPhrase = 'ge/ger (vad) (till vem)'
    missingQ = 'vad vill du ge (till det);vem vill du ge det till'
    iobjReply = toSingleNoun

    /* detta är en icke-prepositionell frasering */
    isPrepositionalPhrasing = nil
;

VerbRule(GiveToImplicit)
    ('ge' | 'erbjuda') multiDobj
    : VerbProduction
    action = GiveToImplicit
    verbPhrase = 'ge/ger (vad) (till vem)'
    missingQ = 'vad vill du ge (till det);vem vill du ge det till'

    priority = 25
;

VerbRule(ShowTo)
    'visa' multiDobj 'till' singleIobj
    : VerbProduction
    action = ShowTo
    verbPhrase = 'visa/visar (vad) (till vem)'
    missingQ = 'vad vill du visa (till det);vem vill du visa det till'
    iobjReply = toSingleNoun
;

VerbRule(ShowToType2)
    'visa' singleIobj multiDobj
    : VerbProduction
    action = ShowTo
    verbPhrase = 'visa/visar (vad) (till vem)'
    missingQ = 'vad vill du visa (till det);vem vill du visa det till'
    iobjReply = toSingleNoun

    /* detta är en icke-prepositionell frasering */
    isPrepositionalPhrasing = nil
;

VerbRule(ShowToImplicit)
    'visa' multiDobj
    : VerbProduction
    action = ShowToImplicit
    verbPhrase = 'visa/visar (vad) (till vem)'
    missingQ = 'vad vill du visa (till det);vem vill du visa det till'

    priority = 25
;


VerbRule(Say)
    'säga' ('att' |) topicDobj
    : VerbProduction
    action = SayAction
    verbPhrase = 'säga/säger (vad)'
    missingQ = 'vad vill du säga'
    dobjReply = topicPhrase
;

VerbRule(SayTo)
    'säga' ('att' |) topicIobj 'till' singleDobj
    : VerbProduction
    action = SayTo
    verbPhrase = 'säga/säger (vad) (till vem)'
    missingQ = 'vad vill du säga det till; vad vill du säga'
    dobjReply = topicPhrase
    iobjReply = toSingleNoun
;

VerbRule(TellThat)
    'säga' singleDobj 'att' topicIobj
    : VerbProduction
    action = SayTo
    verbPhrase = 'säga/säger (vad) (till vem)'
    missingQ = 'vad vill du säga det till; vad vill du säga'
    dobjReply = singleNoun
    iobjReply = topicPhrase
;
    
VerbRule(Think)
    'tänk' | 'fundera' | 'grubbla'
    : VerbProduction
    action = Think
    verbPhrase = 'tänk/tänker'
;

VerbRule(ThinkAbout)
    ('tänk' | 'fundera' | 'grubbla') 'om' topicDobj
    : VerbProduction
    action = ThinkAbout
    verbPhrase = 'tänk/tänker (om vad)'
    missingQ = 'vad vill du tänka om'
    dobjReply = aboutTopicPhrase
;
    

VerbRule(Throw)
    [badness 500] ('kasta' | 'slänga') multiDobj
    : VerbProduction
    action = Throw
    verbPhrase = 'kasta/kastar (vad)'
    missingQ = 'vad vill du kasta'
;

VerbRule(ThrownDown)
    ('kasta' | 'slänga') 'ner'
    : VerbProduction
    action = Drop
    verbPhrase = 'släpp/släpper (vad)'
    missingQ = 'vad vill du kasta ner'
    missingRole = DirectObject
;


VerbRule(ThrowAt)
    ('kasta' | 'slänga') multiDobj 'på' singleIobj
    : VerbProduction
    action = ThrowAt
    verbPhrase = 'kasta/kastar (vad) (på vad)'
    missingQ = 'vad vill du kasta (på det);vad vill du kasta det på'
    iobjReply = atSingleNoun
;

VerbRule(ThrowTo)
    ('kasta' | 'slänga') multiDobj 'till' singleIobj
    : VerbProduction
    action = ThrowTo
    verbPhrase = 'kasta/kastar (vad) (till vem)'
    missingQ = 'vad vill du kasta (till det);vem vill du kasta till det'
    iobjReply = toSingleNoun
;

VerbRule(ThrowToType2)
    'kasta' singleIobj multiDobj
    : VerbProduction
    action = ThrowTo
    verbPhrase = 'kasta/kastar (vad) (till vem)'
    missingQ = 'vad vill du kasta (till det);vem vill du kasta det till'
    iobjReply = toSingleNoun

    /* detta är en icke-prepositionell frasering */
    isPrepositionalPhrasing = nil
;

VerbRule(ThrowDir)
    ('kasta' | 'slänga') multiDobj ('till' ('den'|'det' | ) | ) singleDir
    : VerbProduction
    action = ThrowDir

    verbPhrase = 'kasta/kastar (vad)'
    missingQ = 'vad vill du kasta'
    dobjReply = directionName
;

/* en specialregel för KASTA NER <dobj> */
VerbRule(ThrowDirDown)
    ('kasta' | 'slänga') ('ner' | 'n') multiDobj |
    ('kasta' | 'slänga') multiDobj ('ner' | 'n')
    : VerbProduction
    action = Drop
    verbPhrase = ('kasta/kastar (vad) ner')
    missingQ = 'vad vill du kasta ner'
    
    priority = 100
;

VerbRule(Follow)
    'följ' singleDobj
    : VerbProduction
    action = Follow
    verbPhrase = 'följ/följer (vem)'
    missingQ = 'vem vill du följa'
    dobjReply = singleNoun
;

VerbRule(Attack)
    ('attackera' | 'döda' | 'slå' | 'sparka' | 'slåss') singleDobj
    : VerbProduction
    action = Attack
    verbPhrase = 'attackera/attackerar (vem)'
    missingQ = 'vem vill du attackera'
    dobjReply = singleNoun
;

VerbRule(AttackWith)
    ('attackera' | 'döda' | 'slå' | 'slåss')
        singleDobj 'med' singleIobj
    : VerbProduction
    action = AttackWith
    verbPhrase = 'attackera/attackerar (vem) (med vad)'
    missingQ = 'vem vill du attackera;vad vill du attackera det med'
    dobjReply = singleNoun
    iobjReply = withSingleNoun
;

VerbRule(Inventory)
    'i' | 'inv' | 'inventering' 
    //| 'ta' 'inventering'
    : VerbProduction
    action = Inventory
    verbPhrase = 'ta/tar inventering'
;

VerbRule(InventoryTall)
    ('i' | 'inv' | 'inventering') 'lång'
    : VerbProduction
    action = InventoryTall
    verbPhrase = 'ta/gör inventering lång'
;

VerbRule(InventoryWide)
    ('i' | 'inv' | 'inventering') 'bred'
    : VerbProduction
    action = InventoryWide
    verbPhrase = 'gör/gör inventering bred'
;   


VerbRule(InventoryHybrid)
    ('i' | 'inv' | 'inventering') ('hybrid' | 'delad')
    : VerbProduction
    action = InventoryHybrid
    verbPhrase = 'gör/gör inventering hybrid'
;   


VerbRule(Wait)
    'z' | 'vänta'
    : VerbProduction
    action = Wait
    verbPhrase = 'vänta/väntar'
;

VerbRule(Look)
    ('titta' | 'titta' | 't' | 'l') ('runt'|)
    : VerbProduction
    action = Look
    verbPhrase = 'titta/tittar runt'    
;

VerbRule(Quit)
    'avsluta' | 'av' | 'a' | 'sluta' | 'q'
    : VerbProduction
    action = Quit
    verbPhrase = 'sluta/slutar'
;

VerbRule(Again)
    'igen' | 'g'
    : VerbProduction
    action = Again
    verbPhrase = 'upprepa/upprepar det senaste kommandot'
;

VerbRule(Score)
    'poäng' | 'status'
    : VerbProduction
    action = Score
    verbPhrase = 'visa/visar poäng'
;

VerbRule(FullScore)
    'full' 'poäng' | 'fullpoäng' | 'full'
    : VerbProduction
    action = FullScore
    verbPhrase = 'visa/visar full poäng'
;

VerbRule(Notify)
    'notifiera'
    : VerbProduction
    action = Notify
    verbPhrase = 'visa/visar notifieringsstatus'
;

VerbRule(NotifyOn)
    'notifiera' 'på'
    : VerbProduction
    action = NotifyOn
    verbPhrase = 'slå/slår på poängnotifiering'
;

VerbRule(NotifyOff)
    'notifiera' 'av'
    : VerbProduction
    action = NotifyOff
    verbPhrase = 'slå/slår av poängnotifiering'
;

VerbRule(Save)
    'spara'
    : VerbProduction
    action = Save
    verbPhrase = 'spara/sparar'
;

VerbRule(SaveString)
    'spara' quotedStringPhrase->fname_
    : VerbProduction
    action = Save
    verbPhrase = 'spara/sparar'
;

VerbRule(Restore)
    'återställ'
    : VerbProduction
    action = Restore
    verbPhrase = 'återställ/återställer'
;

VerbRule(RestoreString)
    'återställ' quotedStringPhrase->fname_
    : VerbProduction
    action = Restore
    verbPhrase = 'återställ/återställer'
;


VerbRule(Restart)
    'starta' 'om'
    : VerbProduction
    action = Restart
    verbPhrase = 'starta/startar om'
;

VerbRule(Undo)
    'ångra'
    : VerbProduction
    action = Undo
    verbPhrase = 'ångra/ångrar'
;

VerbRule(Version)
    'version'
    : VerbProduction
    action = Version
    verbPhrase = 'visa/visar version'
;

VerbRule(Credits)
    'krediter'
    : VerbProduction
    action = Credits
    verbPhrase = 'visa/visar krediter'
;

VerbRule(About)
    'om'
    : VerbProduction
    action = About
    verbPhrase = 'visa/visar information om berättelsen'
;

VerbRule(ScriptOn)
    'skript' | 'skript' 'på'
    : VerbProduction
    action = ScriptOn
    verbPhrase = 'starta/startar skriptning'
;

VerbRule(ScriptString)
    'skript' quotedStringPhrase->fname_
    : VerbProduction
    action = ScriptOn
    verbPhrase = 'starta/startar skriptning'
;

VerbRule(ScriptOff)
    'skript' 'av' | 'avskript'
    : VerbProduction
    action = ScriptOff 
    verbPhrase = 'sluta/slutar skriptning'
;

VerbRule(Record)
    'spela in' | 'spela in' 'på'
    : VerbProduction
    action = Record
    verbPhrase = 'starta/startar kommandoinspelning'
;

VerbRule(RecordString)
    'spela in' quotedStringPhrase->fname_
    : VerbProduction
    action = Record
    verbPhrase = 'starta/startar kommandoinspelning'
;

VerbRule(RecordEvents)
    'spela in' 'händelser' | 'spela in' 'händelser' 'på'
    : VerbProduction
    action = RecordEvents
    verbPhrase = 'starta/startar händelseinspelning'
;

VerbRule(RecordEventsString)
    'spela in' 'händelser' quotedStringPhrase->fname_
    : VerbProduction
    action = RecordEvents
    verbPhrase = 'starta/startar kommandoinspelning'
;

VerbRule(RecordOff)
    'spela in' 'av'
    : VerbProduction
    action = RecordOff
    verbPhrase = 'sluta/slutar kommandoinspelning'
;

VerbRule(ReplayString)
    'spela upp' ('tyst'->quiet_ | 'nonstop'->nonstop_ | )
        (quotedStringPhrase->fname_ | )
    : VerbProduction
    action = Replay
    verbPhrase = 'spela upp/spelar upp kommandoinspelning'

    /* ställ in lämpliga alternativflaggor */
    scriptOptionFlags = ((quiet_ != nil ? ScriptFileQuiet : 0)
                         | (nonstop_ != nil ? ScriptFileNonstop : 0))
;
VerbRule(ReplayQuiet)
    'sp' (quotedStringPhrase->fname_ | )
    : VerbProduction
    action = Replay

    scriptOptionFlags = ScriptFileQuiet
;

VerbRule(ToggleDiaambigEnum)
    ('växla' |) ('disambig' | 'disambiguering') ('enum' | 'enumeration')
    : VerbProduction
    action = ToggleDisambigEnumeration
    verbPhrase = 'växla/växlar enumeration av disambiguering alternativ'
;

// TODO: Försvenska till denna svengelskaöversättning 
VerbRule(GoToMode)
    ('gå till' | 'gå' 'till') (|'läge') ('kort' -> brief_| 'snabb' -> fast_|
        'utförlig'->normal_|'normal'-> normal_| 'långsam'-> normal_ | 'fortsätt' -> normal_)
    : VerbProduction
    action = GoToMode
    verbPhrase = 'växla/växlar gå till läge'    
;

VerbRule(GoTo)
    ('gå' 'till' | 'gå' 'till' | 'gå till')
    singleDobj
    : VerbProduction
    action = GoTo
    verbPhrase = 'gå/går till (vad)'
    missingQ = 'vart vill du gå'
    dobjReply = toSingleNoun
    priority = 60
;

VerbRule(Continue)
    'fortsätt' | 'f'
    : VerbProduction
    action = Continue
    verbPhrase = 'fortsätt/fortsätter resan'
;


VerbRule(VagueTravel) 
    'gå' | 'springa' | 'löp' 
    : VerbProduction
    action = VagueTravel
    verbPhrase = 'gå/går'

    priority = 25
;

VerbRule(Travel)
    (('gå' | 'springa' | 'löp')  singleDir) | singleDir
    : VerbProduction
    action = Travel
    verbPhrase = 'gå/går {vart)'  
;

/*
 *   Skapa en TravelVia VerbRule endast så att vi kan tillhandahålla en verbPhrase.
 *   (Parsern letar efter underklasser av varje specifik Action-klass för att hitta
 *   dess verbfras, eftersom de språksspecifika Action-definitionerna
 *   alltid finns i språkmodulens 'grammar' underklasser. Vi behöver inte
 *   en faktisk grammatikregel, eftersom detta inte är ett inmatningsbart verb, så vi
 *   behöver bara skapa en vanlig underklass för att verbfrasen ska hittas.)
 */
VerbRule(TravelVia)
    'tv#' singleDobj
    : VerbProduction
    action = TravelVia
    verbPhrase = 'använd/använder (vad)'
    missingQ = 'vilken vill du använda'
    dobjReply = singleNoun
;

VerbRule(In)
    'gå in'
    : VerbProduction
    action = GoIn
    verbPhrase = 'gå/går in'
;

VerbRule(Out)
    'gå ut' | 'lämna'
    : VerbProduction
    action = GoOut
    verbPhrase = 'gå/går ut'
;

VerbRule(GoThrough)
    ('gå' | 'gå' ) ('genom' | 'via')
        singleDobj
    : VerbProduction
    action = GoThrough
    verbPhrase = 'gå/går (genom vad)'
    missingQ = 'vad vill du gå genom'
    dobjReply = throughSingleNoun
;

VerbRule(GoAlong)
    ('gå' | 'gå' ) ('längs')
        singleDobj
    : VerbProduction
    action = GoAlong
    verbPhrase = 'gå/går (längs vad)'
    missingQ = 'vad vill du gå längs'
    dobjReply = singleNoun
;


VerbRule(GoBack)
    'tillbaka' | 'gå' 'tillbaka' | 'återvänd'
    : VerbProduction
    action = GoBack
    verbPhrase = 'gå/går tillbaka'
;

VerbRule(Dig)
    ([badness 500] 'gräv' | 'gräv' 'i') singleDobj
    : VerbProduction
    action = Dig
    verbPhrase = 'gräva/gräver (i vad)'
    missingQ = 'vad vill du gräva i'
    dobjReply = inSingleNoun
;

VerbRule(DigWith)
    ('gräv' | 'gräv' 'i') singleDobj 'med' singleIobj
    : VerbProduction
    action = DigWith
    verbPhrase = 'gräva/gräver (i vad) (med vad)'
    missingQ = 'vad vill du gräva i;vad vill du gräva med'
    dobjReply = inSingleNoun
    iobjReply = withSingleNoun
;

VerbRule(Jump)
    'hoppa'
    : VerbProduction
    action = Jump
    verbPhrase = 'hoppa/hoppar'
;

VerbRule(JumpOffIntransitive)
    'hoppa' 'av'
    : VerbProduction
    action = JumpOffIntransitive
    verbPhrase = 'hoppa/hoppar av'
;

VerbRule(JumpOff)
    'hoppa' 'av' singleDobj
    : VerbProduction
    action = JumpOff
    verbPhrase = 'hoppa/hoppar (av vad)'
    missingQ = 'vad vill du hoppa av'
    dobjReply = singleNoun
;

VerbRule(JumpOver)
    ([badness 500]'hoppa' | 'hoppa' 'över') singleDobj
    : VerbProduction
    action = JumpOver
    verbPhrase = 'hoppa/hoppar (över vad)'
    missingQ = 'vad vill du hoppa över'
    dobjReply = overSingleNoun
;

VerbRule(Push)
    ('tryck' | 'pressa') multiDobj
    : VerbProduction
    action = Push
    verbPhrase = 'tryck/trycker (vad)'
    missingQ = 'vad vill du trycka'
;

VerbRule(Pull)
    'dra' multiDobj
    : VerbProduction
    action = Pull
    verbPhrase = 'dra/drar (vad)'
    missingQ = 'vad vill du dra'
;

VerbRule(Move)
    'flytta' multiDobj
    : VerbProduction
    action = Move
    verbPhrase = 'flytta/flyttar (vad)'
    missingQ = 'vad vill du flytta'
;

VerbRule(MoveTo)
    ('tryck' | 'flytta') multiDobj ((('över' |) 'till' )| 'under') singleIobj
    : VerbProduction
    action = MoveTo
    verbPhrase = 'flytta/flyttar (vad) (till vad)'
    missingQ = 'vad vill du flytta;vart vill du flytta det'
    iobjReply = toSingleNoun
;

VerbRule(MoveAwayFrom)
    ('tryck' | 'flytta' | 'dra') multiDobj (('bort'|) 'från') singleIobj
    : VerbProduction
    action = MoveAwayFrom
    verbPhrase = 'flytta/flyttar (vad) (till vad)'
    missingQ = 'vad vill du flytta;vart vill du flytta det'
    iobjReply = fromSingleNoun
;


VerbRule(MoveWith)
    'flytta' singleDobj 'med' singleIobj
    : VerbProduction
    action = MoveWith
    verbPhrase = 'flytta/flyttar (vad) (med vad)'
    missingQ = 'vad vill du flytta;vad vill du flytta det med'
    dobjReply = singleNoun
    iobjReply = withSingleNoun
;

VerbRule(Turn)
    ('vrid' | 'vrid' | 'rotera') multiDobj
    : VerbProduction
    action = Turn
    verbPhrase = 'vrid/vrider (vad)'
    missingQ = 'vad vill du vrida'
;

VerbRule(TurnWith)
    ('vrid' | 'vrid' | 'rotera') singleDobj 'med' singleIobj
    : VerbProduction
    action = TurnWith
    verbPhrase = 'vrid/vrider (vad) (med vad)'
    missingQ = 'vad vill du vrida;vad vill du vrida det med'
    dobjReply = singleNoun
    iobjReply = withSingleNoun
;

VerbRule(TurnTo)
    ('vrid' | 'vrid' | 'rotera') singleDobj
        'till' literalIobj
    : VerbProduction
    action = TurnTo
    verbPhrase = 'vrid/vrider (vad) (till vad)'
    missingQ = 'vad vill du vrida;vad vill du vrida det till'
    dobjReply = singleNoun
;

VerbRule(Set)
    [badness 500] 'sätt' multiDobj
    : VerbProduction
    action = Set
    verbPhrase = 'sätt/sätter (vad)'
    missingQ = 'vad vill du sätta'
;

VerbRule(SetTo)
    'sätt' singleDobj 'till' literalIobj
    : VerbProduction
    action = SetTo
    verbPhrase = 'sätt/sätter (vad) (till vad)'
    missingQ = 'vad vill du sätta;vad vill du sätta det till'
    dobjReply = singleNoun
    
;

VerbRule(TypeOn)
    'skriv' 'på' singleDobj
    : VerbProduction
    action = TypeOnVague
    verbPhrase = 'skriv/skriv (på vad)'
    missingQ = 'vad vill du skriva på'
    dobjReply = onSingleNoun
;

VerbRule(TypeLiteralOn)
    'skriv' literalDobj 'på' singleIobj
    : VerbProduction
    action = TypeOn
    verbPhrase = 'skriv/skriv (vad) (på vad)'
    missingQ = 'vad vill du skriva;vad vill du skriva det på'
    iobjReply = onSingleNoun
;

VerbRule(TypeLiteralOnWhat)
    [badness 500] 'skriv' literalDobj
    : VerbProduction
    action = Type
    verbPhrase = 'skriv/skriv (vad) (på vad)'
    missingQ = 'vad vill du skriva;vad vill du skriva det på'
;

VerbRule(TypeVague)
    'skriv'
    : VerbProduction
    action = TypeVague
    verbPhrase = 'skriv/skriv'
    missingQ = 'vad vill du skriva;vad vill du skriva det på'
    priority = 20
;

VerbRule(EnterOn)
    'ange' literalDobj
        ('på' | 'i' | 'i' 'till' | 'in' | 'med') singleIobj
    : VerbProduction
    action = EnterOn
    verbPhrase = 'ange/anger (vad) (på vad)'
    missingQ = 'vad vill du ange;vad vill du ange det på'
    dobjReply = singleNoun
;


VerbRule(WriteOn)
    'skriv' literalDobj ('på' | 'i') singleIobj
    : VerbProduction
    action = WriteOn
    verbPhrase = 'skriv/skriv (vad) (på vad)'
    missingQ = 'vad vill du skriva;vad vill du skriva det på'
    dobjReply = onSingleNoun
;

VerbRule(Write)
    'skriv' literalDobj
    : VerbProduction
    action = Write
    verbPhrase = 'skriv/skriv (vad) (på vad)'
    missingQ = 'vad vill du skriva;vad vill du skriva det på'
    priority = 25
;

VerbRule(WriteVague)
    'skriv'
    : VerbProduction
    action = WriteVague
    verbPhrase = 'skriv/skriv (vad)'
    missingQ = 'vad vill du skriva'
    priority = 30
;


VerbRule(ConsultAbout)
    'konsultera' singleDobj ('på' | 'om') topicIobj
    | 'sök' singleDobj 'för' topicIobj
    : VerbProduction
    action = ConsultAbout
    verbPhrase = 'konsultera/konsulterar (vad) (om vad)'
    missingQ = 'vad vill du konsultera;vad vill du konsultera det om'
    dobjReply = singleNoun
    iobjReply = aboutTopicPhrase
;

VerbRule(LookUp)
    (('titta' | 't') ('upp' | 'för') | 'hitta'  | 'sök' 'för' | 'läs' 'om')
    topicIobj ('i' | 'på') singleDobj
    | ('titta' | 't') topicIobj 'upp' ('i' | 'på') singleDobj
    : VerbProduction
    action = ConsultAbout
    verbPhrase = 'titta/tittar upp (vad) (i vad)'
    missingQ = 'vad vill du titta upp i;vad vill du titta upp'
    dobjReply = topicPhrase
    iobjReply = inSingleNoun
    
    /* 
     *   This VerbRule effectively reverses the grammtical roles of its action's direct and indirect
     *   objects.
     */
    rolesReversed = true
;

VerbRule(ConsultWhatAbout)
    (('titta' | 't') ('upp' | 'för')
     | 'hitta'
     | 'sök' 'för'
     | 'läs' 'om')
    topicIobj
    | ('titta' | 't') topicIobj 'upp'
    : VerbProduction
    action = ConsultWhatAbout
    verbPhrase = 'titta/tittar upp (vad) (i vad)'
    missingQ = 'vad vill du titta upp i;vad vill du titta upp'
    priority = 25
    iobjReply = topicPhrase
    dobjReply = inSingleNoun
;

VerbRule(ConsultAboutVague)
    ('konsultera' | 'läs') 'om'
    : VerbProduction
    action = ConsultAboutVague
    verbPhrase = 'konsultera/konsulterar om'    
;

VerbRule(Switch)
    [badness 500] 'växla' multiDobj
    : VerbProduction
    action = SwitchVague
    verbPhrase = 'växla/växlar (vad)'
    missingQ = 'vad vill du växla'
;

VerbRule(Flip)
    [badness 500] 'vänd' multiDobj
    : VerbProduction
    action = Flip
    verbPhrase = 'vänd/vänder (vad)'
    missingQ = 'vad vill du vända'
;

VerbRule(SwitchOn)
    ('aktivera' | ('slå' | 'växla' | 'vänd') 'på') multiDobj
    | ('slå' | 'växla' | 'vänd') multiDobj 'på'
    : VerbProduction
    action = SwitchOn
    verbPhrase = 'slå/slår på (vad)'
    missingQ = 'vad vill du slå på'
    priority = 60
;

VerbRule(SwitchOff)
    ('deaktivera' | ('slå' | 'växla' | 'vänd') 'av') multiDobj
    | ('slå' | 'växla' | 'vänd') multiDobj 'av'
    : VerbProduction
    action = SwitchOff
    verbPhrase = 'slå/slår av (vad)'
    missingQ = 'vad vill du slå av'
    priority = 60
;

VerbRule(Light)
    'tänd' multiDobj
    : VerbProduction
    action = Light
    verbPhrase = 'tänd/tänder (vad)'
    missingQ = 'vad vill du tända'
;

VerbRule(Strike)
    'slå' multiDobj
    : VerbProduction
    action = Strike
    verbPhrase = 'slå/slår (vad)'
    missingQ = 'vad vill du slå'
;

VerbRule(Burn)
    ('bränn' | 'tänd' | 'sätt' 'eld' 'på') multiDobj
    : VerbProduction
    action = Burn
    verbPhrase = 'bränn/bränner (vad)'
    missingQ = 'vad vill du bränna'
;

VerbRule(SetFireToWhat)
    'sätt' 'eld' 'på'
    : VerbProduction
    action = Burn
    verbPhrase = 'bränn/bränner (vad)'
    missingQ = 'vad vill du sätta eld på'
    missingRole = DirectObject
;

VerbRule(BurnWith)
    ('tänd' | 'bränn' | 'tänd' | 'sätt' 'eld' 'på') singleDobj
        ('med' | 'från') singleIobj
    : VerbProduction
    action = BurnWith
    verbPhrase = 'bränn/bränner (vad) (med vad)'
    missingQ = 'vad vill du bränna;vad vill du bränna det med'
    dobjReply = singleNoun
    iobjReply = withSingleNoun
;

VerbRule(Extinguish)
    ('släck' | 'släck' | 'släck' 'ut' | 'blås' 'ut') multiDobj
    | ('blås' | 'släck') multiDobj 'ut'
    : VerbProduction
    action = Extinguish
    verbPhrase = 'släck/släcker (vad)'
    missingQ = 'vad vill du släcka'
;

VerbRule(Break)
    ('bryt' | 'förstöra' | 'förstöra' | 'förstöra' | 'krossa') multiDobj
    : VerbProduction
    action = Break
    verbPhrase = 'bryt/bryter (vad)'
    missingQ = 'vad vill du bryta'
;

VerbRule(Cut)
    [badness 500] 'skär' singleDobj
    : VerbProduction
    action = Cut
    verbPhrase = 'skär/skär (vad) (med vad)'
    missingQ = 'vad vill du skära'
    dobjReply = singleNoun
;

VerbRule(CutWith)
    'skär' singleDobj 'med' singleIobj
    : VerbProduction
    action = CutWith
    verbPhrase = 'skär/skär (vad) (med vad)'
    missingQ = 'vad vill du skära;vad vill du skära det med'
    dobjReply = singleNoun
    iobjReply = withSingleNoun
;

VerbRule(Eat)
    ('ät' | 'konsumera') multiDobj
    : VerbProduction
    action = Eat
    verbPhrase = 'ät/äter (vad)'
    missingQ = 'vad vill du äta'
;

VerbRule(Drink)
    ('drick' | 'dricka' | 'dricka') multiDobj
    : VerbProduction
    action = Drink
    verbPhrase = 'drick/dricker (vad)'
    missingQ = 'vad vill du dricka'
;

VerbRule(Pour)
    'häll' multiDobj
    : VerbProduction
    action = Pour
    verbPhrase = 'häll/häller (vad)'
    missingQ = 'vad vill du hälla'
;

VerbRule(PourInto)
    'häll' multiDobj ('i' | 'in' | 'i' 'till') singleIobj
    : VerbProduction
    action = PourInto
    verbPhrase = 'häll/häller (vad) (i vad)'
    missingQ = 'vad vill du hälla;vad vill du hälla det i'
    iobjReply = inSingleNoun
;

VerbRule(PourOnto)
    'häll' multiDobj ('på' | 'uppå') singleIobj
    : VerbProduction
    action = PourOnto
    verbPhrase = 'häll/häller (vad) (på vad)'
    missingQ = 'vad vill du hälla;vad vill du hälla det på'
    iobjReply = onSingleNoun
;

VerbRule(Climb)
    'klättra' singleDobj
    : VerbProduction
    action = Climb
    verbPhrase = 'klättra/klättrar (vad)'
    missingQ = 'vad vill du klättra'
    dobjReply = singleNoun
;

VerbRule(ClimbUp)
    ('klättra' | 'gå' | 'gå') 'upp' singleDobj
    : VerbProduction
    action = ClimbUp
    verbPhrase = 'klättra/klättrar (upp vad)'
    missingQ = 'vad vill du klättra upp'
    dobjReply = singleNoun
;

VerbRule(ClimbUpWhat)
    'klättra' 'upp'
    : VerbProduction
    action = ClimbUp
    verbPhrase = 'klättra/klättrar (upp vad)'
    missingQ = 'vad vill du klättra upp'
    dobjReply = singleNoun
    missingRole = DirectObject
;

VerbRule(ClimbDown)
    ('klättra' | 'gå' | 'gå') 'ner' singleDobj
    : VerbProduction
    action = ClimbDown
    verbPhrase = 'klättra/klättrar (ner vad)'
    missingQ = 'vad vill du klättra ner'
    dobjReply = singleNoun
;

VerbRule(ClimbDownWhat)
    ('klättra' | 'gå' | 'gå') 'ner'
    : VerbProduction
    action = ClimbDown
    verbPhrase = 'klättra/klättrar (ner vad)'
    missingQ = 'vad vill du klättra ner'
    dobjReply = singleNoun
    missingRole = DirectObject
;

VerbRule(Clean)
    'rengör' multiDobj
    : VerbProduction
    action = Clean
    verbPhrase = 'rengör/rengör (vad)'
    missingQ = 'vad vill du rengöra'
;

VerbRule(CleanWith)
    'rengör' singleDobj 'med' singleIobj
    : VerbProduction
    action = CleanWith
    verbPhrase = 'rengör/rengör (vad) (med vad)'
    missingQ = 'vad vill du rengöra (med det);'
              + 'vad vill du rengöra det med'
    iobjReply = withSingleNoun
;

VerbRule(AttachTo)
    ('fäst' | 'anslut') multiDobj ('på' | 'till') singleIobj
    : VerbProduction
    action = AttachTo
    iobjReply = toSingleNoun
    verbPhrase = 'fäst/fäster (vad) (till vad)'
    missingQ = 'vad vill du fästa (till det);'
               + 'vad vill du fästa det till'
;

VerbRule(Attach)
    ('fäst' | 'anslut') multiDobj
    : VerbProduction
    action = Attach
    verbPhrase = 'fäst/fäster (vad)'
    missingQ = 'vad vill du fästa'
    
    priority = 40
;

VerbRule(DetachFrom)
    ('lossa' | 'koppla bort') multiDobj 'från' singleIobj
    : VerbProduction
    action = DetachFrom
    verbPhrase = 'lossa/lossar (vad) (från vad)'
    missingQ = 'vad vill du lossa (från det);'
              + 'vad vill du lossa det från'
    iobjReply = fromSingleNoun
;

VerbRule(Detach)
    ('lossa' | 'koppla bort') multiDobj
    : VerbProduction
    action = Detach
    verbPhrase = 'lossa/lossar (vad)'
    missingQ = 'vad vill du lossa'
;

VerbRule(Open)
    'öppna' multiDobj
    : VerbProduction
    action = Open
    verbPhrase = 'öppna/öppnar (vad)'
    missingQ = 'vad vill du öppna'
;

VerbRule(Close)
    ('stäng' | 'stäng') multiDobj
    : VerbProduction
    action = Close
    verbPhrase = 'stäng/stänger (vad)'
    missingQ = 'vad vill du stänga'
;

VerbRule(Lock)
    'lås' multiDobj
    : VerbProduction
    action = Lock
    verbPhrase = 'lås/låser (vad)'
    missingQ = 'vad vill du låsa'
;

VerbRule(Unlock)
    'lås' 'upp' multiDobj
    : VerbProduction
    action = Unlock
    verbPhrase = 'lås upp/låser upp (vad)'
    missingQ = 'vad vill du låsa upp'
;

VerbRule(LockWith)
    'lås' singleDobj 'med' singleIobj
    : VerbProduction
    action = LockWith
    verbPhrase = 'lås/låser (vad) (med vad)'
    missingQ = 'vad vill du låsa;vad vill du låsa det med'
    dobjReply = singleNoun
    iobjReply = withSingleNoun
;

VerbRule(UnlockWith)
    'lås' 'upp' singleDobj 'med' singleIobj
    : VerbProduction
    action = UnlockWith
    verbPhrase = 'lås upp/låser upp (vad) (med vad)'
    missingQ = 'vad vill du låsa upp;vad vill du låsa upp {det} med'
    dobjReply = singleNoun
    iobjReply = withSingleNoun
;

VerbRule(SitOn)
    'sitt' ('på' | 'ner' 'på' )
        singleDobj
    : VerbProduction
    action = SitOn
    verbPhrase = 'sitt/sitter (på vad)'
    missingQ = 'vad vill du sitta på'
    dobjReply = onSingleNoun
;

VerbRule(SitIn)
    'sitt' ('i' | 'ner' 'i')
        singleDobj
    : VerbProduction
    action = SitIn
    verbPhrase = 'sitt/sitter (på vad)'
    missingQ = 'vad vill du sitta på'
    dobjReply = inSingleNoun
;

VerbRule(Sit)
    'sitt' ( | 'ner') : VerbProduction
    action = Sit
    verbPhrase = 'sitt/sitter ner'
;

VerbRule(LieOn)
    'ligg' ('på' | 'ner' 'på' )
        singleDobj
    : VerbProduction
    action = LieOn
    verbPhrase = 'ligg/ligger (på vad)'
    missingQ = 'vad vill du ligga på'
    dobjReply = onSingleNoun
;

VerbRule(LieIn)
    'ligg' ('i' | 'ner' 'i')
        singleDobj
    : VerbProduction
    action = LieIn
    verbPhrase = 'ligg/ligger (på vad)'
    missingQ = 'vad vill du ligga på'
    dobjReply = inSingleNoun
;


VerbRule(Lie)
    'ligg' 'ner' : VerbProduction
    action = Lie
    verbPhrase = 'ligg/ligger ner'
;

VerbRule(StandOn)
    'stå' ('på' | 'uppå' | 'på' 'till' ) singleDobj
    : VerbProduction
    action = StandOn
    verbPhrase = 'stå/står (på vad)'
    missingQ = 'vad vill du stå på'
    dobjReply = onSingleNoun
;

VerbRule(StandIn)
    'stå' ('i' | 'in' | 'i' 'till')  singleDobj
    : VerbProduction
    action = StandIn
    verbPhrase = 'stå/står (på vad)'
    missingQ = 'vad vill du stå på'
    dobjReply = inSingleNoun
;

VerbRule(Stand)
    'stå' | 'stå' 'upp' | 'res' 'upp'
    : VerbProduction
    action = Stand
    verbPhrase = 'stå/står upp'
;

VerbRule(GetOutOf)
    ('ut' 'ur' | 'gå' 'ut' 'ur' | 'klättra' 'ut' 'ur' | 'lämna' | 'gå ut')
    singleDobj
    : VerbProduction
    action = GetOutOf
    verbPhrase = 'gå/går (ut ur vad)'
    missingQ = 'vad vill du gå ut ur'
    dobjReply = outOfSingleNoun
;

VerbRule(GetOutOfWhat)
    ('gå' | 'klättra') 'ut' 'ur'     
    : VerbProduction
    action = GetOutOf
    verbPhrase = 'gå/går (ut ur vad)'
    missingQ = 'vad vill du gå ut ur'
    dobjReply = outOfSingleNoun
    missingRole = DirectObject
;


VerbRule(GetOff)
    'gå' ('av' | 'av' 'av' | 'ner' 'från') singleDobj
    : VerbProduction
    action = GetOff
    verbPhrase = 'gå/går (av vad)'
    missingQ = 'vad vill du gå av'
    dobjReply = singleNoun
;

VerbRule(GetOut)
    'gå' 'ut'
    | 'gå' 'av'
    | 'gå' 'ner' ('från' |)   
    | 'gå av'
    | 'klättra' 'ut'
    : VerbProduction
    action = GetOut
    verbPhrase = 'gå/går ut'
    priority = 60
;

VerbRule(Board)
    ('ombord'
     | ('gå' ('på' | 'uppå' | 'på' 'till'))
     | ('klättra' ('på' | 'uppå' | 'på' 'till')))
    singleDobj
    : VerbProduction
    action = Board
    verbPhrase = 'gå/går (på vad)'
    missingQ = 'vad vill du gå på'
    dobjReply = onSingleNoun
;

VerbRule(BoardWhat)
    ('gå' | 'klättra') ('på' | 'uppå' | 'på' 'till')
    : VerbProduction
    action = Board
    verbPhrase = 'gå/går (på vad)'
    missingQ = 'vad vill du gå på'    
    dobjReply = onSingleNoun
    missingRole = DirectObject
;


VerbRule(Enter)
    'gå in' singleDobj  |
    ('gå' | 'gå' | 'gå' | 'klättra') ( 'i' | 'i' 'till' | 'in' | 'inuti')
    singleDobj
    : VerbProduction
    action = Enter
    verbPhrase = 'gå/går (vad)'
    missingQ = 'vad vill du gå'
    dobjReply = singleNoun
;

VerbRule(GetInWhat)
    'gå in' |  (('gå' | 'klättra') ( 'i' | 'i' 'till' | 'in' | 'inuti'))
    : VerbProduction
    action = Enter
    verbPhrase = 'gå/går (vad)'
    missingQ = 'vad vill du gå'
    dobjReply = singleNoun
    missingRole = DirectObject
;

VerbRule(Sleep)
    'sov'
    : VerbProduction
    action = Sleep
    verbPhrase = 'sov/sover'
;

VerbRule(Fasten)
    ('fäst' | [badness 500] 'spänna' | 'spänna' 'upp') multiDobj
    : VerbProduction
    action = Fasten
    verbPhrase = 'fäst/fäster (vad)'
    missingQ = 'vad vill du fästa'
;

VerbRule(FastenTo)
    ('fäst' | 'spänna') multiDobj 'till' singleIobj
    : VerbProduction
    action = FastenTo
    verbPhrase = 'fäst/fäster (vad) (till vad)'
    missingQ = 'vad vill du fästa (till det);'
               + 'vad vill du fästa {det} till'
    iobjReply = toSingleNoun
;

VerbRule(Unfasten)
    ('lossa' | 'spänna upp') multiDobj
    : VerbProduction
    action = Unfasten
    verbPhrase = 'lossa/lossar (vad)'
    missingQ = 'vad vill du lossa'
;

VerbRule(UnfastenFrom)
    ('lossa' | 'spänna upp') multiDobj 'från' singleIobj
    : VerbProduction
    action = UnfastenFrom
    verbPhrase = 'lossa/lossar (vad) (från vad)'
    missingQ = 'vad vill du lossa;'
               + 'vad vill du lossa {det} från'
    iobjReply = fromSingleNoun
;

VerbRule(PlugInto)
    'plugga' multiDobj ('i' | 'in' | 'i' 'till') singleIobj
    : VerbProduction
    action = PlugInto
    verbPhrase = 'plugga/pluggar (vad) (i vad)'
    missingQ = 'vad vill du plugga (i det);'
             + 'vad vill du plugga {det} i'
    iobjReply = inSingleNoun
;

VerbRule(PlugIntoWhat)
    [badness 500] 'plugga' multiDobj
    : VerbProduction
    action = PlugInto
    verbPhrase = 'plugga/pluggar (vad) (i vad)'
    missingQ = 'vad vill du plugga (i det);'
              + 'vad vill du plugga {det} i'

    missingRole = IndirectObject
    iobjReply = inSingleNoun
;

VerbRule(PlugIn)
    'plugga' multiDobj 'i'
    | 'plugga' 'i' multiDobj
    : VerbProduction
    action = PlugIn
    verbPhrase = 'plugga/pluggar (vad) i'
    missingQ = 'vad vill du plugga i'
;

VerbRule(UnplugFrom)
    'koppla' 'ur' multiDobj 'från' singleIobj
    : VerbProduction
    action = UnplugFrom
    verbPhrase = 'koppla ur/kopplar ur (vad) (från vad)'
    missingQ = 'vad vill du koppla ur;vad vill du koppla ur {det} från'
    iobjReply = fromSingleNoun
;

VerbRule(Unplug)
    'koppla' 'ur' multiDobj
    : VerbProduction
    action = Unplug
    verbPhrase = 'koppla ur/kopplar ur (vad)'
    missingQ = 'vad vill du koppla ur'
;

VerbRule(Screw)
    'skruva' multiDobj
    : VerbProduction
    action = Screw
    verbPhrase = 'skruva/skruvar (vad)'
    missingQ = 'vad vill du skruva'
;

VerbRule(ScrewWith)
    'skruva' multiDobj 'med' singleIobj
    : VerbProduction
    action = ScrewWith
    verbPhrase = 'skruva/skruvar (vad) (med vad)'
    missingQ = 'vad vill du skruva;'
               + 'vad vill du skruva {det} med'
    iobjReply = withSingleNoun
;

VerbRule(Unscrew)
    'skruva' 'loss' multiDobj
    : VerbProduction
    action = Unscrew
    verbPhrase = 'skruva loss/skruvar loss (vad)'
    missingQ = 'vad vill du skruva loss'
;

VerbRule(UnscrewWith)
    'skruva' 'loss' multiDobj 'med' singleIobj
    : VerbProduction
    action = UnscrewWith
    verbPhrase = 'skruva loss/skruvar loss (vad) (med vad)'
    missingQ = 'vad vill du skruva loss;'
               + 'vad vill du skruva loss {det} med'
    iobjReply = withSingleNoun
;

VerbRule(PushTravelDir)
    ('tryck' | 'dra' | 'dra' | 'flytta') singleDobj singleDir
    : VerbProduction
    action = PushTravelDir
    dobjReply = singleNoun
    iobjReply = directionName
;

VerbRule(PushTravelThrough)
    ('tryck' | 'dra' | 'dra' | 'flytta') singleDobj
    ('genom' | 'via') singleIobj
    : VerbProduction
    action = PushTravelThrough
    verbPhrase = 'tryck/trycker (vad) (genom vad)'
    missingQ = 'vad vill du trycka;vad vill du trycka {det} genom'
    dobjReply = singleNoun
    iobjReply = throughSingleNoun
;

VerbRule(PushTravelEnter)
    ('tryck' | 'dra' | 'dra' | 'flytta') singleDobj
    ('i' | 'in' | 'i' 'till') singleIobj
    : VerbProduction
    action = PushTravelEnter
    verbPhrase = 'tryck/trycker (vad) (i vad)'
    missingQ = 'vad vill du trycka;vad vill du trycka {det} i'
    dobjReply = singleNoun
    iobjReply = inSingleNoun
;

VerbRule(PushTravelGetOutOf)
    ('tryck' | 'dra' | 'dra' | 'flytta') singleDobj
    'ut' ('ur' | ) singleIobj
    : VerbProduction
    action = PushTravelGetOutOf
    verbPhrase = 'tryck/trycker (vad) (ut ur vad)'
    missingQ = 'vad vill du trycka;vad vill du trycka {det} ut ur'
    dobjReply = singleNoun
    iobjReply = outOfSingleNoun
;


VerbRule(PushTravelClimbUp)
    ('tryck' | 'dra' | 'dra' | 'flytta') singleDobj
    'upp' singleIobj
    : VerbProduction
    action = PushTravelClimbUp
    verbPhrase = 'tryck/trycker (vad) (upp vad)'
    missingQ = 'vad vill du trycka;vad vill du trycka {det} upp'
    dobjReply = singleNoun
;

VerbRule(PushTravelClimbDown)
    ('tryck' | 'dra' | 'dra' | 'flytta') singleDobj
    'ner' singleIobj
    : VerbProduction
    action = PushTravelClimbDown
    verbPhrase = 'tryck/trycker (vad) (ner vad)'
    missingQ = 'vad vill du trycka;vad vill du trycka {det} ner'
    dobjReply = singleNoun
;

VerbRule(Exits)
    'utgångar'
    : VerbProduction
    action = Exits
    verbPhrase = 'utgångar/visar utgångar'
;

VerbRule(ExitsMode)
    'utgångar' ('på'->on_ | 'alla'->on_
             | 'av'->off_ | 'inga'->off_
             | ('status' ('rad' | ) | 'statusrad') 'titta'->on_
             | 'titta'->on_ ('status' ('rad' | ) | 'statusrad')
             | 'status'->stat_ ('rad' | ) | 'statusrad'->stat_
             | 'titta'->look_)
    : VerbProduction
    action = ExitsMode
    verbPhrase = 'slå/slår av utgångsvisning'
;

VerbRule(ExitsColour)
    ('utgångar'|'utgång') ('färg'|'färg') ('på' ->on_| 'av' ->on_ | 
                                         'blå' ->colour_ | 'röd' -> colour_ |
                                         'grön' -> colour_ | 'gul' ->
                                         colour_)
    : VerbProduction
    action = ExitsColour
    verbPhrase = 'slå/slår av ofärgade utgångar'
;


VerbRule(HintsOff)
    'ledtrådar' 'av'
    : VerbProduction
    action = HintsOff
    verbPhrase = 'inaktivera/inaktiverar ledtrådar'
;

VerbRule(Hints)
    'ledtråd' | 'ledtrådar'
    : VerbProduction
    action = Hints
    verbPhrase = 'visa/visar ledtrådar'
;

/* Kommando för att aktivera eller inaktivera extra ledtrådar */
VerbRule(ExtraHints)
    ('extra' | 'extra'| 'bonus') ('ledtråd' | 'ledtrådar' |'tips' |'tips'| ) 
    ('på'->onOff | 'av'->onOff | )
    : VerbProduction
    action = ExtraHints
    verbPhrase = ('slå/slår extra ledtrådar ' + onOff)
;

VerbRule(TipsOn)
    ('tips' |'tips'| ) 'på'    
    : VerbProduction
    action = TipsOn
    verbPhrase = ('slå/slår tips på')
;

VerbRule(TipsOff)
    ('tips' |'tips'| ) 'av'    
    : VerbProduction
    action = TipsOff
    verbPhrase = ('slå/slår tips av')
;

VerbRule(Brief)
    'kort' | 'kortfattad'
    : VerbProduction
    action = Brief
    verbPhrase = 'sätt/sätter kort läge'
;

VerbRule(Verbose)
    'utförlig' | 'ordrik'
    : VerbProduction
    action = Verbose
    verbPhrase = 'sätt/sätter utförligt läge'   
;

    
VerbRule(HyperlinkSuggestions)
    ('hyper' | 'hyperlänk') ('ämne'|'förslag')
    : VerbProduction
    action = HyperlinkSuggestions
    verbPhrase = 'växla/växlar hyperlänkning av ämnesförslag'  
;
    
VerbRule(EnumerateSuggestions)
    ('enum' | 'enumerera') ('ämne'|'förslag')
    : VerbProduction
    action = EnumerateSuggestions
    verbPhrase = 'växla/växlar enumeration av ämnesförslag'  
;

VerbRule(SpecialAction)
    'sp#akt' singleDobj
    :VerbProduction
    action = SpecialAction
    verbPhrase = 'gör/gör {det} till (vad)'
    missingQ = 'vad vill du göra {det} till'    
    dobjReply = singleNoun
;

VerbRule(SpecialActionMulti)
    'sp#akter' multiDobj
    :VerbProduction
    action = SpecialAction
    verbPhrase = 'gör/gör {det} till (vad)'
    missingQ = 'vad vill du göra {det} till'    
;


specialActionPreparser: StringPreParser
    doParsing(str, which)
    {
        if(str.find('sp#akt'))
        {
            //DMsg(reject spaction input, 'Jag <i>verkligen</i> vägrar att förstå {det} kommandot. ');
            dmsg('Jag <i>verkligen</i> vägrar att förstå {det} kommandot. ');
            return nil;                
        }
        return str;
    }
;


#ifdef __DEBUG

VerbRule(Purloin)
    ('stjäla' | 'pn') singleDobj
    : VerbProduction
    action = Purloin
    verbPhrase = 'stjäla/stjäl (vad)'
    missingQ = 'vad vill du stjäla'
    dobjReply = singleNoun
;

VerbRule(GoNear)
    ('gå nära' |'gå' 'nära'| 'gn') singleDobj
    : VerbProduction
    action = GoNear
    verbPhrase = 'gå nära/går nära (vad)'
    missingQ = 'vad vill du gå nära'
    dobjReply = singleNoun
;


VerbRule(FiatLux)
    'fiat' 'lux' | 'låt' 'det' 'bli' 'ljus'
    : VerbProduction
    action = FiatLux
    verbPhrase = 'justera/justerar ljus'
;

VerbRule(Evaluate)
    'eval' literalDobj
    : VerbProduction
    action = Evaluate
    verbPhrase = 'eval/eval (vad)'
    missingQ = 'Vilket uttryck vill du evaluera'
;

/* 
 *   Om de inte redan finns, sätt in citattecken runt argumentet för ett utvärdera
 *   kommando.
 */

evalPreParser: StringPreParser
    doParsing(str, which)
    {
        if(str.toLower.startsWith('eval ') && !str.endsWith('"'))
        {
            str = str.splice(6, 0, '"') + '"';
        }
        return str;
    }
; 

#endif


/* ------------------------------------------------------------------------ */
/*
 *   Ytterligare svenska grammatik egenskaper.
 *   
 *   För varje Action, ställer vi in egenskapen grammarTemplates med en lista
 *   över alla möjliga kommandoinmatningssyntaxmallar som kan användas
 *   för att generera åtgärden från ett användarkommando. Dessa är av formen
 *   "lägg (dobj) i (iobj)", som vi enkelt kan använda för att generera meddelanden
 *   eller jämföra med inmatningsfraser. Detta är ibland användbart för att bestämma
 *   den specifika fraseringen som spelaren använde i inmatningen, när en given åtgärd
 *   har flera möjliga fraseringar.
 *   
 *   För varje VerbProduction (som i allmänhet är samma som en VerbRule
 *   definition), ställer vi in egenskapen grammarAlts till en lista över grammatik
 *   regler för verbet. Detta är användbart för att hitta den specifika regeln vi
 *   matchade för en given inmatad inmatning.
 *   
 *   Dessa listor, och proceduren för att bygga dem, är i sig
 *   specifika för det svenska biblioteket. Andra språk kanske inte definierar
 *   sina verbgrammatiker med samma strukturer, så de antaganden vi
 *   gör om grammatikträden kanske inte håller i alla språk. Dessa
 *   listor används endast inom det svenska biblioteket, eftersom det
 *   generiska biblioteket inte kan räkna med att de är tillgängliga i andra
 *   översättningar.
 */
property grammarTemplates, grammarAlts, verbRule;


/* ------------------------------------------------------------------------ */
/*
 *   Initiera DoerParser-tabellen. Detta fyller den givna
 *   DoerParserTable med DoerParser-objekt som beskriver syntaxen
 *   tillgänglig för användning i Doer 'cmd' strängar.
 *   
 *   Varje DoerParser-objekt tillhandahåller helt enkelt ett reguljärt uttryck för
 *   att analysera en åtgärdsfrasering. Det reguljära uttrycket definierar den
 *   språksspecifika mallen för åtgärdsfraseringen, med förbehållet
 *   att varje substantivfras ersätts med ett objekt eller klassnamn, eller en
 *   lista med objekt eller klassnamn separerade med '|' tecken.
 *   
 *   Till exempel, för ett Ge Till kommando på svenska, kan vi definiera en
 *   DoerParser för var och en av följande reguljära uttryck:
 *   
 *.     'ge (<alphanum|_|vbar>+) till (<alphanum|_|vbar>+)'
 *.     'ge (<alphanum|_|vbar>+) (<alphanum|_|vbar>+)'
 *   
 *   Efter att du har skapat en DoerParser, anropar du helt enkelt ptab.addParser() för att lägga till den
 *   nya parsern till tabellen.
 *   
 *   Observera att, oavsett språk, MÅSTE du använda en verbsyntax som
 *   börjar med ett verbord, på grund av hur parserns uppslagstabell är
 *   byggd. De flesta språk börjar naturligtvis en imperativ med ett verb
 *   ändå, så detta är vanligtvis vad du skulle göra även utan detta
 *   krav. För ett språk som använder en annan ordföljd för
 *   imperativer, måste du dock använda en onaturlig syntax för
 *   DoerParser-syntaxen, och därmed för Doer 'cmd' strängsyntaxen. Denna
 *   onaturliga syntax är rent intern för biblioteket och spel, så
 *   spelare kommer inte att se den.
 *   
 *   Det är upp till språkmodulen att bestämma hur man ska komma fram till listan
 *   över verbfraser, och hur man bygger de reguljära uttrycksmönstren för verb.
 *   Det svenska biblioteket bygger listan direkt från
 *   spelarkommandogrammatiken - specifikt syntaxtokenlistorna definierade
 *   för VerbRule-produktionerna.
 *   
 *   Denna svenska implementering tar också tillfället i akt att bygga
 *   grammatikmallar för varje Action. Detta är rent för vår egen användning i
 *   det svenska biblioteket, så andra språk behöver inte replikera den
 *   funktionaliteten. Vi gör detta här eftersom vi bygger dessa från samma
 *   information som vi använder för att bygga DoerParsers.
 *   
 *   [Required] 
 */
initDoerParsers(ptab)
{
    /* ställ in ärvda tomma mallistor i basklasserna */
    VerbProduction.grammarAlts = [];
    Action.grammarTemplates = [];
    Action.verbRule = nil;

    /* gå igenom varje predikatregelalternativ */
    foreach (local alt in predicate.getGrammarInfo())
    {
        /* få matchobjektet och åtgärden */
        local mo = alt.gramMatchObj;
        local action = mo.action;
          
        
        /* spara alternativinformationen med matchobjektet */
        mo.grammarAlts += alt;
        
        /* bygg det till en strängmall och en Doer parser */
        local t = [], pt = [], ptRoles = [];
        foreach (local tok in alt.gramTokens)
        {
            switch (tok.gramTokenType)
            {
            case GramTokTypeProd:
                /* kontrollera mål egenskapen */
                if (tok.gramTargetProp == &dirMatch)
                {
                    /* det är en riktning */
                    t += '(riktning)';
//                    pt += '<alphanum>+';
                   pt += '(<alphanum|_|vbar|dot|star>+)';
                }
                else
                {
                    /* 
                     *   För allt annat, anta att vi har en substantivfras.
                     *   Se om detta matchar en substantivfras roll.
                     */
                    local r = NounRole.all.valWhich(
                        { r: r.matchProp == tok.gramTargetProp });
                    
                    /* om det matchar, ange i mallen som '(roll)' */
                    if (r != nil)
                    {
                        t += '(' + r.name + ')';
                        pt += '(<alphanum|_|vbar|dot|star>+)';
                        ptRoles += r;
                    }
                }
                break;
                
            case GramTokTypeLiteral:
                /* bokstavlig - ange i mallen direkt som den är */
                t += tok.gramTokenInfo;
                pt += tok.gramTokenInfo;
                break;
            }
        }

        /* 
         *   kombinera malltokenen till en sträng och lägg till
         *   strängen till åtgärdens mallista
         */
        action.grammarTemplates += t.join(' ');
        
        /* 
         *   Om åtgärden inte redan känner till en associerad verbregel
         *   notera att denna tillhör den.
         */
        
        if(action.verbRule == nil)
        {
            action.verbRule = mo;
        }
        
        
        /* lägg till en DoerParser för verbmallen till parser tabellen */
        ptab.addParser(new DoerParser(action, pt[1], pt.join(' '), ptRoles));
    }
}

/* ------------------------------------------------------------------------ */
/*
 *   Svenska specifika VerbProduction tillägg 
 */
modify VerbProduction
    /*
     *   Få grammatikproduktionen för den givna substantivfrasrollen, för
     *   att svara på frågor om saknade substantiv ("Vad vill du öppna?").
     *   Som standard kommer vi att titta på tre ställen:
     *   
     *   1. Om vi har "reply" egenskapen som motsvarar rollen
     *   (dobjReply, iobjReply, etc), returnerar vi grammatikregeln
     *   som anges där.
     *   
     *   2. Vi försöker hitta rollens match egenskap i vår grammatikregel
     *   lista. Om vi hittar den, returnerar vi produktionen för den första
     *   vi hittar.
     *   
     *   3. Om allt detta misslyckas, returnerar vi en lämplig standard för rollen
     *   (nounList för ett direkt objekt, eller singleNoun för något annat).
     *   
     *   [Required] 
     */
    missingRoleProd(role)
    {
        /* kontrollera om det finns en anpassad inställning för rollen */
        if (self.(role.missingReplyProp) != nil)
            return self.(role.missingReplyProp);

        /* leta efter rollen i våra grammatiksyntaxmallar */
        foreach (local alt in grammarAlts)
        {
            /* leta efter en matchning för denna roll, med en sub-produktion */
            local t = (alt.valWhich(
                { t: t.gramTargetProp == role.matchProp
                     && t.gramTokenType == GramTokTypeProd  }));

            /* om vi hittade den, returnera sub-produktionsobjektet */
            if (t != nil)
                return t.gramTokenInfo;
        }

        /* hittade fortfarande inte - returnera en lämplig standard för rollen */
        return (role == DirectObject ? nounList : singleNoun);
    }
;

modify Action
    /* VerbRule (Production) associerad med denna åtgärd. */
    verbRule = nil
;


// TODO: temporärt verb för att kolla upp vocabwords
DefineTAction(SweHelper);
VerbRule(SweHelper)
    'swe' singleDobj
    : VerbProduction
    action = SweHelper
    verbPhrase = 'swe'
;

modify Thing
    dobjFor(SweHelper) {
        verify() {}
        check() {}        
        action() {
            local words = vocabWords.mapAll({x: x.wordStr}).join(', ');
            tadsSay('Synonymer: <<words>>\n');
        }
    }
;
//'eval blomma.vocabWords.mapAll({x: x.wordStr}).join(', ')'