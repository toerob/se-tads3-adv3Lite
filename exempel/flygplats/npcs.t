#charset "utf-8"

#include <tads.h>
#include "advlite.h"


guard: Actor 'säkerhets|vakt+en; kraftig+a; man+nen' @securityGate
    "Han ser kraftig ut, men det är nog lika mycket fett som muskler. "

    actorSpecialDesc = "En säkerhetsvakt står brevid metalldetektorn, och blickar
        misstänksamt på dig. "

    checkAttackMsg = 'Med din träning skulle du förmodligen lätt kunna övermanna honom,
        även om han är beväpnad och du inte, men det skulle det troligen resultera i
        att all annan flygplatssäkerhetspersonal skulle komma efter dig, vilket är en
        komplikation du gärna skulle klara dig från just nu.'

    /*
    checkAttackMsg = 'With your training you could probably overpower him
        easily enough, although he\'s armed and you\'re not, but that would
        probably result all the other airport security staff coming after you,
        which is a complication you could do without right now. '
    */
;

+ AskTopic, StopEventList @tFlightDepartures
    [
        '<q>När går nästa plan härifrån?</q> frågar du.\b
        <q>Lyssna på högtalarna, Se&ntilde;or,</q> föreslår han, <q>eller
        titta på avgångstavlorna där inne.</q> Han nickar vagt mot norr. ',

        '<q>Avgår det något flyg snart?</q> frågar du.\b
        <q>Jag sa det redan, Se&ntilde;or: lyssna på högtalarna eller
        titta på tavlan,</q> svarar han med ett lätt uns av otålighet.'
    ]
;

+ TellTopic, StopEventList @cortez
    [
        '<q>En kriminell vid namn Pablo Cortez har nyss försökt ta över
        flyget till Buenos Aires,</q> säger du.\b
        <q>Jag är säker på att det ordnar sig, Se&ntilde;or,</q> försäkrar
        vakten dig likgiltigt. ',

        '<q>Pablo Cortez...</q> börjar du.\b
        Vakten avbryter dig med en handrörelse. <q>Allt är ordnat,
        Se&ntilde;or,</q> insisterar han. '
    ]
;

+ AskForTopic @IDcard
    "<q>Kan jag få tillbaka mitt ID-kort, tack?</q> frågar du.\b
    <q>Det var inte ditt ID-kort, Se&ntilde;or,</q> svarar vakten lugnt.
    <q>Jag känner Antonio Velaquez, och du är inte han.</q> "

    isActive = gRevealed('card-confiscated') && IDcard.location == counter
;

+ ShowTopic @IDcard
    topicResponse()
    {
        "Du visar upp ID-kortet för säkerhetsvakten i hopp om att det ska
        övertala honom att låta dig passera utan fler frågor, men istället
        rycker han det ur händerna på dig och stirrar på det med en djup rynka.\b
        <q>Det här är inte ditt, Se&ntilde;or,</q> konstaterar han.\b
        Med dessa ord lämnar han kortet till en kollega som genast bär iväg
        med det.<.reveal card-confiscated> ";

        IDcard.moveInto(counter);
    }

;

+ DefaultAnyTopic
    "Vakten rycker bara på axlarna och mumlar något som antingen kan vara <q>Inte
    min sak, Se&ntilde;or,</q> eller <q>Inte din sak, Se&ntilde;or.</q> "
;

//==============================================================================

cortez: Actor 'Pablo Cortez; stilig+a ond+a ondske|full+a ondsint:e+a latino+n;man+nen;honom'
    "Han är faktiskt ganska stilig, på ett latinoaktigt vis; om du mött honom
    i ett annat sammanhang kanske du inte förstått vilken ondskefull djävul han
    egentligen är. "

    actorSpecialDesc = "Pablo Cortez<<first time>>, El Diablos högra hand,
        <<only>> står vid huvudutgången och driver bort passagerarna från planet
        med mynningen av sin kulspruta. "

    checkAttackMsg = 'Du vet bättre än att försöka; han är känd för att vara
        ytterst dödlig med det vapnet. '

    cannotTakeFromActorMsg(obj)
    {
        return 'Cortez skulle skjuta ihjäl dig innan dina händer ens kom i
            närheten av det. ';
    }

    actorBeforeTravel(traveler, connector)
    {
        if(traveler == gPlayerChar && connector == cockpitDoor)
        {
            "Cortez ser misstänksamt åt ditt håll när du rör dig mot
            cockpitdörren. <q>Hej du, Pond!</q> ropar han. När du rusar mot
            dörren öppnar han eld med sin kulspruta och genomborrar din
            kropp med kulor. ";
            finishGameMsg(ftDeath, [finishOptionUndo]);
        }
        else if (traveler == gPlayerChar && connector == planeRear)
        {
            "Din improviserade förklädnad luras inte Cortez länge; det är bäst
            att lämna planet så snabbt som möjligt. ";
            exit;
        }

    }
;

+ DefaultAnyTopic
    "Du vill verkligen inte dra till dig hans uppmärksamhet. Om han känner
    igen dig dödar han dig. "

    isConversational = nil
;

+ gun: Thing 'gun; machine 93r beretta; pistol machine-pistol'
    "Det är en Beretta 93R, kapabel att avfyra mer än tusen skott per minut. "
;

+ cortezArrivalAgenda: AgendaItem
    initiallyActive = true
    isReady = (takeover.isHappening)

    invokeItem()
    {
        isDone = true;
        getActor.moveInto(planeFront);
        getActor.addToAgenda(cortezTalkingAgenda);
    }
;

+ cortezTalkingAgenda: AgendaItem
    isReady = (gPlayerChar.isIn(planeFront))

    invokeItem()
    {
        isDone = true;
        "<q>Skynda på! Lämna det här planet! El Diablo är inte en tålmodig man
        och han behöver det för viktiga affärer!</q> hör du Cortez säga till
        passagerarna. <q>Om planet inte är tömt när vår pilot anländer ska jag
        skjuta var och en av er som fortfarande är ombord! Nu, rör på er!</q> ";

        getActor.addToAgenda(cortezShootingAgenda.setDelay(2));
    }
;

+ cortezShootingAgenda: DelayedAgendaItem
    invokeItem()
    {
        isDone = true;
        if(gPlayerChar.isIn(planeFront))
        {
            "Cortez ser plötsligt åt ditt håll. En bråkdels sekund verkar han
            frusen av förvåning, men bara en bråkdels sekund.\b
            <q>Hallå där! Du!</q> ropar han. Ett ögonblick senare lyfter han sin
            kulspruta och avfyrar rakt in i din mage på noll hålls avstånd. ";
            finishGameMsg(ftDeath, [finishOptionUndo]);
        }
        else
            getActor.moveInto(nil);
    }
;


//==============================================================================

angela: Actor 'flight attendant; statuesque young; woman angela; henne'
    @planeFront
    "Hon är en statylik och ingalunda ful ung kvinna. "

    checkAttackMsg = 'Det skulle vara grymt och onödigt. '

    globalParamName = 'angela'

    makeProper
    {
        proper = true;
        name = 'Angela';
        return name;
    }

    suggestionKey = 'top'
;

+ TopicGroup 'top';

++ AskTopic @angela
    keyTopics = 'angela'

    name = 'herself'
;

++ QueryTopic 'when' 'this plane is going to leave; depart take off'
    "<q>När ska det här planet avgå?</q> frågar du.\b
    <q>Så fort piloten kommit ombord,</q> säger hon. <.reveal
    pilot-awaited> "

    askMatchObj = tFlightDepartures
;


++ AskTopic @tPilot
    "<q>Vad har hänt med piloten?</q> frågar du.\b
    <q>Det vet jag inte; vi väntar fortfarande på honom,</q> svarar hon. <q>Men
    oroa dig inte; jag är säker på att han dyker upp nu när som helst.</q> "

    autoName = true
    isActive = gRevealed('pilot-awaited')
;



+ QueryTopic 'what' 'her name is; your'
    "<q>Vad heter du?</q> frågar du.\b
    <q><<getActor.makeProper>>,</q> svarar hon. "

    isActive = !getActor.proper

    convKeys = 'angela'
;

+ QueryTopic, StopEventList 'what' @tDoingTonight
    [
        '<q>Vad ska du göra i kväll?</q> frågar du.\b
        Hon höjer ett ögonbryn. <q>Jag har mina planer,</q> svarar hon
        vagt. ',

        '<q>Vad <i>ska</i> du göra i kväll?</q> insisterar du.\b
        <q>Jag tror inte det är din sak,</q> svarar hon med ett ganska
        kyligt leende. <q>Eller?</q> <.convnode not-your-business>',

        '<q>Om i kväll...</q> börjar du.\b
        Hon avbryter dig genom att pressa ihop läpparna och höja ögonbrynen
        på ett milt ogillande sätt, som om hon vill säga <q>Det ämnet är
        avslutat.</q> '
    ]

    convKeys = 'angela'
;

+ ConvNode 'not-your-business';

++ YesTopic
    "<q>Jo faktiskt,</q> svarar du djärvt.\b
    <q>I så fall får vi vara oense,</q> svarar hon, en aning stelt."
;

++ NoTopic
    "<q>Nej, det antar jag inte,</q> medger du.\b
    <q>Nej; nåväl, så var det med det,</q> konstaterar hon. "
;

+ QueryTopic 'when' 'this plane is going to leave; depart take off'
    "<q>När ska det här planet avgå?</q> frågar du.\b
    <q>Så fort piloten kommit ombord,</q> säger hon. <.reveal
    pilot-awaited> "

    askMatchObj = tFlightDepartures
;

+ DefaultAskForTopic
    "{Ref subj angela} lyssnar på din förfrågan och skakar på huvudet. <q>Förlåt, jag
    kan inte hjälpa dig med det,</q> säger hon. "
;

+ DefaultCommandTopic
    "<q><<if angela.proper>>Angela<<else>>Fröken<<end>>, skulle du kunna
    <<actionPhrase>>, tack?</q> ber du.\b
    Till svar höjer hon bara ett ögonbryn och ser på dig som om hon vill säga,
    <q>Vem tror du att du pratar med?</q> "
;


+ DefaultAnyTopic
    "{Ref subj angela} ler och rycker på axlarna. "
;

+ DefaultGiveShowTopic
    "Du erbjuder {ref angela} {ref dobj}, men hon skakar på huvudet och skjuter {honom
    dobj} ifrån sig och säger <q>Tyvärr kan jag inte ta emot {that dobj} av dig.</q> "
;

+ DefaultShowTopic
    "Du pekar mot {ref dobj}.\b
    <q>Mycket intressant, det är jag säker på,</q> konstaterar {ref subj angela}
    utan större entusiasm. "

    isActive = gDobj.isFixed
;

+ TopicGroup
    isActive = getActor.curState == angelaSeatedState
;

++ DefaultAskQueryTopic
    "<q>Den frågan är för svår för mig!</q> utbrister hon. "
;

+ angelaGreetingState: ActorState
    isInitState = true
    specialDesc = "{Ref subj angela} {är} precis innanför ingången och tar emot
        passagerare när de stiger ombord. "
    stateDesc = "Just nu bär hon på ett inövat professionellt leende. "

    beforeTravel(traveler, connector)
    {
        if(traveler == gPlayerChar)
        {
            switch(connector)
            {
            case cockpitDoor:
                "<q>Tyvärr kan du inte gå in där,</q> {ref subj angela}
                stoppar dig. <q>Endast flygbesättning är tillåten i cockpit.</q>
                ";

                exit;

            case planeRear:
                if(!ticketSeen)
                {
                    "<q>Tyvärr kan jag inte låta dig gå ombord förrän jag sett
                    din biljett,</q> {ref subj angela} insisterar. ";
                    exit;
                }
                break;
            case jetway:
                if(!ticketSeen)
                    getActor.addToAgenda(angelaTicketAgenda);
                break;
            default:
                break;
            }
        }
    }

    ticketSeen = nil
;

++ GiveShowTopic @ticket
    topicResponse()
    {
        "<q>Varsågod,</q> säger du och håller fram biljetten för {ref angela}
        att se.\b
        Hon blickar snabbt på biljetten i din hand och tar den tillfälligt
        för att kontrollera. <q>Det ser bra ut,</q> försäkrar hon dig när hon
        lämnar tillbaka den. <q>Var vänlig gå till bakre delen av planet och
        hitta din plats.</q> ";
        angelaGreetingState.ticketSeen = true;
        boardingAchievement.awardPointsOnce();
    }
;

++ QueryTopic 'if|whether' @tEnjoyWork
    "<q>Trivs du med ditt jobb?</q> frågar du.\b
    <q>Självklart,</q> svarar hon med ett inövat leende. "

    convKeys = 'angela'
;

+ TopicGroup +5
    isActive = angela.curState == angelaGreetingState &&
    !angelaGreetingState.ticketSeen
;

++ DefaultAskQueryTopic
    "<q>Jag måste verkligen se din biljett,</q> insisterar hon <<one
      of>>artigt<<or>>en gång till<<stopping>>. "
;

++ DefaultSayTellTalkTopic
    "{Ref subj angela} lyssnar <<one of>>artigt<<or>>lite otåligt
    <<stopping>> på vad du har att säga och svarar sedan, <q>Får jag se
    din biljett?</q> "
;

+ TopicGroup +5
    isActive = angela.curState == angelaGreetingState &&
    angelaGreetingState.ticketSeen
;

++ DefaultAskQueryTopic
    "<q>Om du har fler frågor kan du kanske ställa dem när vi är i luften,</q>
    <<one of>>föreslår<<or>>upprepar<<stopping>> hon. <q><<one
      of>>Det vore bäst om du gick <<or>> Var vänlig gå<<stopping>> till
    bakre delen av planet och <<one of>>tog<<or>>tar<<stopping>> din plats
    nu.</q> "
;

++ DefaultSayTellTalkTopic
    "{Ref subj angela} räcker upp handen för att stoppa dig. <q>Kan jag be dig
    gå till bakre delen av planet och ta din plats nu?</q> <<one
    of>>ber<<or>>upprepar<<or>>insisterar<<stopping>> hon. "
;



+ angelaAssistingState: ActorState
    specialDesc = "{Ref subj angela} {är} i mitten av passagerarbryggan och 
                   försöker lugna passagerarna som just tvingats lämna planet. "

    stateDesc = "Just nu ser hon ganska pressad ut. "
;

++ HelloTopic, StopEventList
    [
        '<q>Ursäkta, kan jag få ett ord?</q> säger du.\b
        {Ref subj angela} vänder sig mot dig med ett inövat leende, och
        förbereder sig mentalt för ytterligare en storm av klagomål. <q>Ja;
        hur kan jag hjälpa dig?</q> svarar hon. ',

        '<q>Kan jag få ett ord till?</q> frågar du.\b
        <q>Ja?</q> svarar hon och vänder sig mot dig med lätt försiktighet. '
    ]

    changeToState = angelaTalkingState
;




+ angelaTalkingState: ActorState
    specialDesc = "{Ref subj angela} {är} vänd mot dig och väntar på att du
        ska tala. "
;

++ QueryTopic 'if|whether' @tEnjoyWork
   "<q>Trivs du med ditt jobb -- i stunder som dessa?</q> frågar du.\b
   <q>I stunder som dessa...</q> låter hon meningen hänga oavslutad med en
   talande grimas. "

    convKeys = 'angela'
;

++ ByeTopic
    "<q>Nåväl, hej då så länge,</q> säger du.\b
    <q>Hejdå,</q> svarar hon med en snabb nick, innan hon vänder sig mot ännu
    en påträngande fördriven passagerare som vill ha hennes uppmärksamhet. "

    changeToState = angelaAssistingState
;

++ LeaveByeTopic
    "{Ref subj angela} ser ett ögonblick förbryllad över ditt något abruptat
    uppbrott, men vänder sig snabbt tillbaka till de andra passagerarna som
    ropar på hennes uppmärksamhet. "

    changeToState = angelaAssistingState
;

++ AskTellTopic, StopEventList @cortez
    [
        '<q>Vet du vem den där mannen som viftar med ett vapen vid framsidan
        av planet är?</q> frågar du och sänker rösten. <q>Det är Pablo Cortez,
        El Diablos högra hand!</q>\b
        Hennes leende blir ganska kallt när hon svarar, <q>Vad angår det
        dig?</q> <.inform cortez> <.convnodet what-to-you>',

        '<q>Du måste vara <i>mycket</i> försiktig runt Cortez,</q> varnar
        du henne.\b
        <q>Det ska jag vara,</q> försäkrar hon dig. '

    ]
    autoName = true
    convKeys = 'top'
    suggestAs = TellTopic
;

+ ConvNode 'what-to-you';

++ TellTopic @gPlayerChar
    "<q>Jag heter Pond, Sherlock Pond,</q> berättar du för henne. <q>Jag är en
    brittisk hemlig agent på spåren av dessa skurkar!</q>\b
    <q>Verkligen!</q> svarar hon med dåligt dold skepticism. <.inform agent>"

    name = 'yourself'
;

++ SayTopic 'Cortez is dangerous'
    "<q>Pablo Cortez är en <i>mycket</i> farlig man,</q> varnar du henne. <q>Han har
    dödat fler män än jag haft varma middagar!</q><.inform cortez-dangerous>\b
    <q>Vem som helst som viftar med ett vapen ombord på ett passagerarplan kan
    betraktas som farlig,</q> påpekar hon pragmatiskt. "
;

++ SayTopic 'she should call security; you'
    "<q>Du borde tillkalla flygplatssäkerheten för att hantera honom!</q> uppmanar
    du henne.\b
    <q>Flygplatssäkerheten -- i Narcosia?</q> frågar hon otroget. <q>På något
    sätt tror jag inte det hjälper situationen precis!</q> "
;

++ DefaultAnyTopic, StopEventList
    [
        '<q>Nej, men vad angår det dig vem den här mannen är?</q> avbryter
        hon dig. <.convstay> ',

        'Hon skakar på huvudet. <q>Nåväl, svara inte på min fråga då,</q>
        muttrar hon. '
    ]
;

++ NodeEndCheck
    canEndConversation(reason)
    {
        if(reason == endConvBye)
        {
            "<q><q>Hejdå</q> är inte ett svar,</q> klagar {ref subj angela}.
            <q>Varför bryr du dig så mycket om den här mannen Cortez?</q> ";

            return blockEndConv;
        }

        if(reason == endConvLeave)
        {
            "Det verkar inte vara ett bra tillfälle att avbryta samtalet. ";
            return nil;
        }

        return true;
    }
;

+ TopicGroup +5
    isActive = angela.curState == angelaTalkingState
;

++  DefaultAskQueryTopic, ShuffledEventList
    [
        '{Ref subj angela} muttrar något ohörbart och ser sig omkring, som
        om hon ger en tydlig antydan om att hon har andra att ta hand om
        förutom dig. ',

        '<q>Kanske vi kan diskutera det en annan gång,</q> föreslår hon med en
        meningsfull blick mot de andra passagerarna som ivrar att fånga hennes
        uppmärksamhet. ',

        '<q>Hm, ja,</q> säger hon i en ton som snarast antyder att hon har
        mer brådskande saker på hjärnan. ',

        '<q>Jag tänker kanske...</q> börjar hon, men avbryts när en av de andra
        passagerarna klappar henne på armen i ett försök att fånga hennes
        uppmärksamhet. '
    ]
;

++ DefaultSayTellTalkTopic
    "{Ref subj angela} lyssnar på vad du har att säga utan kommentar, men med
    minen av en som har annat på hjärnan. "
;



+ angelaSeatedState: ActorState
    specialDesc = "{Ref subj angela} {är} sittande nära framsidan av planet. "
    stateDesc = "Just nu ser hon dock orolig och rädd ut. "
;

++ QueryTopic 'if|whether' @tEnjoyWork
   "<q>Trivs du med ditt jobb nu?</q> frågar du.\b
   <q>Jag kommer vara glad när just det här flyget är över,</q> svarar hon
   tyst. "

    convKeys = 'angela'
;

++ QueryTopic, StopEventList 'what' @tDoingTonight
    [
        '<q>Vad har du för planer för i kväll nu?</q> frågar du.\b
        <q>Jag är inte säker,</q> svarar hon lite nervöst. <q>Jag tror
        att jag hellre väntar tills det här planet har landat och säkert 
        nått mål och -- ja, du förstår.</q> Hon indikerar de nya passagerarna 
        med en snabb ögonrörelse. <q>Jag tror att jag hellre väntar tills 
        allt det här är över innan jag gör fler planer.</q> ',

        '<q>Om senare i kväll...</q> börjar du.\b
        <q>Vi diskuterar det när vi har anlänt på andra sidan,</q> insisterar
        hon. '
    ]

    convKeys = 'angela'
;

+ TopicGroup +5
    isActive = angela.curState == angelaSeatedState
;

++ DefaultAskQueryTopic, ShuffledEventList
    [
        '{Ref subj angela} sänker rösten och vrider ögonen precis tillräckligt
        för att påminna dig om de andra personerna inom hörhåll. <q>Vi kanske
        borde diskutera det en annan gång,</q> föreslår hon. ',

        '<q>Jag tror inte att jag vill svara på det just nu,</q> svarar hon,
        med precis tillräcklig rörelse med huvudet för att visa hur lätt du
        kan avlyssnas av ligisterna i de andra passagerarsätena. ',

        '<q>Jag tänker...</q> börjar hon och avbryter sig sedan. <q>Jag tror
        att det kanske inte är det bästa tillfället att tala om det,</q>
        avslutar hon. ',

        '<q>Hm,</q> säger hon, <q>just det.</q> Det är uppenbarligen menat
        som ett icke-svar, kanske för att hon är orolig för vem annars som
        kan höra vad hon säger. '
    ]
;

++ DefaultSayTellTalkTopic
    "{Ref subj angela} lyssnar bara och ser svagt ogillande på din
    pratsamhet. "
;



+ angelaAssistingAgenda: AgendaItem
    initiallyActive = true
    isReady = (takeover.isHappening)

    invokeItem()
    {
        isDone = true;
        getActor.moveInto(jetway);
        getActor.setState(angelaAssistingState);
        getActor.addToAgenda(angelaReboardingAgenda);
    }
;

+ angelaReboardingAgenda: AgendaItem
    isReady = (takeover.hasHappened)

    invokeItem()
    {
        isDone = true;
        getActor.moveInto(planeFront);
        getActor.setState(angelaSeatedState);
        getActor.addToAgenda(angelaPilotAgenda);
    }

;

+ angelaPilotAgenda: ConvAgendaItem
    invokeItem()
    {
        isDone = true;
        "{Ref subj angela} ser skarpt upp mot dig och rynkar pannan. <q>Hallå där! Du är
        en av passagerarna, eller hur?</q> konstaterar hon. <q>Jag minns att jag
        tittade på din biljett! Du är definitivt inte vår pilot. Vad gör du
        i den uniformen?</q><.convnodet uniform> ";

    }
;

+ ConvNode 'uniform';

++ SayTopic 'alla brittiska agenter lär sig flyga'
    "<q>Jag sa ju det, jag är en brittisk agent, och alla brittiska agenter lär sig
    flyga -- det är en del av vår utbildning,</q> berättar du för henne.\b
    <q>Menar du att du verkligen tänker flyga det här flygplanet?</q> kräver hon
    att veta, förskräckt. <.convnodet intend-fly> "

    isActive = gInformed('agent')
;

++ SayTopic 'du har en pilotlicens; jag'
    "<q>Det är helt lugnt, jag har flygcertifikat,</q> försäkrar du henne.\b
    <q>Ja, men...</q> börjar hon. <q>Menar du verkligen att du tänker flyga
    det här planet?</q> <.convnodet intend-fly> "

    isActive = !gInformed('agent')
;

// TODO: testa av
++ SayTopic 'du är ersättningspiloten; du är jag är'
    "<q>Du sa att ni väntade på piloten, men det syns inget till honom, så
    jag hoppar in istället,</q> svarar du.\b
    <q>Du!</q> utbrister hon. <q>Menar du att <i>du</i> ska flyga det
    här planet?</q> <.convnodet intend-fly> "

    isActive = gRevealed('pilot-awaited')
;

++ SayTopic 'du har just hittat uniformen; jag'
    "<q>Jag hittade uniformen, ni behöver en pilot,</q> svarar du med ett leende
    och en axelryckning. <q>Dessutom kan jag faktiskt flyga -- jag har
    certifikat.</q>\b
    <q>Menar du att du tänker flyga det här planet?</q> kräver hon att veta
    klentroget. <.convnodet intend-fly> "
;

++ DefaultAnyTopic, ShuffledEventList
    [
        '<q>Nej, men svara på min fråga,</q> avbryter hon dig. <q>Vad gör du
        i den uniformen?</q> <.convstay> ',

        '<q>Det var inte det jag frågade,</q> klagar hon. <q>Berätta varför du
        bär den där uniformen!</q> <.convstay>',

        '<q>Varför bär du den där uniformen?</q> insisterar hon och avfärdar
        dina irrelevanta anmärkningar. <.convstay> ',

        '<q>Det säger mig fortfarande inte vad du gör med den
        uniformen,</q> klagar hon. <q>Varför bär du den?</q> <.convstay> '
    ]
;


++ NodeEndCheck
    canEndConversation(reason)
    {
        switch(reason)
        {
        case endConvBye:
            "<q>Nej, du slipper inte undan min fråga på det viset!</q> säger
            hon. <q>Berätta, varför bär du den där pilotuniformen?</q> ";
            return blockEndConv;
        case endConvLeave:
            "<q>Du går ingenstans förrän du berättar vad du gör i den
            uniformen!</q> insisterar {ref subj angela}. ";
            return blockEndConv;
        default:
            return nil;
        }
    }
;

++ NodeContinuationTopic
    "<q><<one of>>Jag ställde dig en fråga<<or>>Jag väntar fortfarande på ett
    svar<<cycling>>,</q> {ref subj angela} <<one of>> påminner
    dig<<or>> insisterar<<or>> upprepar<<cycling>>. <q>Varför bär du den
    uniformen?</q> "
;


+ ConvNode 'intend-fly'
   commonResponse = "\b<q>Nåväl,</q> suckar hon. <q>Jag antar att vi inte har
       så mycket val nu, eller hur? Bara du vet vad du gör...</q> "
;

++ YesTopic
    "<q>Ja, varför inte?</q> svarar du lätt. <q>Du kan inte vänta här hela
    dagen -- Pablo Cortez och hans glada gäng tål inte det, bland annat!</q>
    <<location.commonResponse>>"
;

++ QueryTopic 'why not'
    "<q>Varför inte?</q> frågar du. <q>Ni behöver en pilot och jag behöver ta
    mig härifrån. Dessutom skulle jag inte vilja vara i dina skor när det här
    gänget tappar tålamodet!</q> Du nickar mot gangstrarna och narkotikabaronerna
    som intar passagerarsätena längre bak i mittgången. <<location.commonResponse>>"
;

// TODO: Testa
++ QueryTopic 'huruvida|om hon har en bättre idé; du har'
    "<q>Har du någon bättre idé?</q> kontrar du. <q>Eran ordinarie pilot 
    syns inte till, och jag skulle inte vilja vara i dina skor när era nuvarande
    passagerare tappar tålamodet!</q> <<location.commonResponse>>"
;

++ DefaultAnyTopic
    "<q>Vänligen svara på min fråga,</q> insisterar hon. <q>Tänker du verkligen
    flyga det här planet?</q> <.convstay>"
;

++ NodeEndCheck
    canEndConversation(reason)
    {
        switch(reason)
        {
        case endConvBye:
            "<q>Det är inte ett svar!</q> klagar hon. <q>Berätta, tänker
            du flyga det här planet själv?</q> ";
            return blockEndConv;
        case endConvLeave:
            "<q>Gå inte förrän du berättat om du tänker flyga det här
            planet,</q> insisterar {ref subj angela}. <q>Nåväl, tänker
            du det?</q> ";
            return blockEndConv;
        default:
            return nil;
        }
    }
;

++ NodeContinuationTopic
    "<q>Jag skulle uppskatta om du svarade på min fråga,</q> insisterar {ref subj angela}.
    <q>Tänker du verkligen flyga det här flygplanet?</q> "
;


+ angelaTicketAgenda: ConvAgendaItem
    initiallyActive = true

    invokeItem()
    {
        isDone = true;
        "<q>Välkommen ombord,</q> hälsar {ref subj angela} dig med ett leende.
        <q>Får jag se din biljett, tack?</q> ";

//        /* The code shown commented out below can be deleted */
//        if(ticket.isDirectlyIn(me))
//        {
//            "She glances down at the ticket in your hand, and temporarily takes
//            it off you to check it. <q>That's fine, sir,</q> she assures you as
//            she returns it to you. <q>Please move to the rear of the plane to
//            find a seat.</q> ";
//            angelaGreetingState.ticketSeen = true;
//        }

    }
;
