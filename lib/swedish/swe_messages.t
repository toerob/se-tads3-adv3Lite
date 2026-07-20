#charset "utf-8"
#include "advlite.h"

modify Thing

    /*
    // TODO: detta måste vara en bugg i ursprungsbiblioteket
    cannotPourIntoMsg = BMsg(cannot pour into, '{I} {can\'t} pour {1}
        into {that dobj}. ', gDobj.fluidName)
    cannotPourOntoMsg = BMsg(cannot pour onto, '{I} {can\'t} pour {1}
        into {that dobj}. ', gDobj.fluidName)
    */

    /*
    // Borde hellre vara: 
    cannotPourIntoMsg = BMsg(cannot pour into, '{I} {can\'t} pour {1}
        into {that iobj}. ', gDobj.fluidName)
    cannotPourOntoMsg = BMsg(cannot pour onto, '{I} {can\'t} pour {1}
        into {that iobj}. ', gDobj.fluidName)
    */
    cannotPourIntoMsg = BMsg(cannot pour into, '{Jag} {kan} inte hälla {1} i {ref iobj}. ', gDobj.fluidName)
    cannotPourOntoMsg = BMsg(cannot pour onto, '{Jag} {kan} inte hälla {1} på {ref iobj}. ', gDobj.fluidName)


;

CustomMessages
    messages = [ 
        Msg(north, 'nord'),                     // Org: name = BMsg(north, 'north')
        Msg(arrive north, 'norrifrån'),         // Org: Msg(arrive north, 'from the north')
        Msg(depart north, 'till norr'),         // Org: Msg(depart north, 'to the north')
        Msg(east, 'öst'),
        Msg(arrive east, 'österifrån'),
        Msg(depart east, 'till öst'),
        Msg(west, 'väst'),
        Msg(arrive west, 'västerifrån'),
        Msg(depart west, 'till väst'),
        Msg(south, 'syd'),
        Msg(arrive south, 'söderifrån'),
        Msg(depart south, 'till norr'),
        Msg(northeast, 'nordöst'),
        Msg(arrive northeast, 'nordösterifrån'),
        Msg(depart northeast, 'till nordöst'),
        Msg(northwest, 'nordväst'),
        Msg(arrive northwest, 'nordvästerifrån'),
        Msg(depart northwest, 'till nordväst'),
        Msg(southeast, 'sydöst'),
        Msg(arrive southeast, 'sydösterifrån'),
        Msg(depart southeast, 'till sydöst'),
        Msg(southwest, 'sydväst'),
        Msg(arrive southwest, 'sydvästerifrån'),
        Msg(depart southwest, 'till sydväst'),
        Msg(down, 'ner'),
        Msg(arrive down, 'nerifrån'),
        Msg(depart down, 'ner'),
        Msg(up, 'upp'),
        Msg(arrive up, 'uppifrån'),
        Msg(depart up, 'upp'),
        Msg(in, 'in'),
        Msg(arrive in, 'inifrån'),
        Msg(depart in, 'in'),
        Msg(out, 'ut'),
        Msg(arrive out, 'utifrån'),
        Msg(depart out, 'ut'),
        Msg(port, 'babord'),
        Msg(arrive port, 'från babordsidan'),
        Msg(depart port, 'längs babordssidan'),
        Msg(starboard, 'styrbord'),
        Msg(arrive starboard, 'från styrbordssidan'),
        Msg(depart starboard, 'längs styrbordssidan'),
        Msg(forward, 'föröver'),
        Msg(arrive forward, 'föröverut'), // alt. 'från fören'
        Msg(depart forward, 'mot fören'),
        Msg(aft, 'akterut'),
        Msg(arrive aft, 'akterut'),
        Msg(depart aft, 'mot aktern'),
        Msg(dummy object inaccessible, 'Dummy-objektet failVerifyObj är inte ett giltigt objekt '),
        Msg(explain numbering, 'Uppräkning av ämnesförslag kan slås på och av med kommandot ENUM FÖRSLAG'),
        Msg(no suggestions present, 'Ämnesförslag är inte tillgängligt i detta spel'),
        Msg(misc list suffix, '{här}'),
        Msg(onset of darkness, '\n{Jag} {är} nedsänkt i mörker. '),
        Msg(remap error, '<b>FEL!</b> Den långa formen av remap är inte längre tillgänglig; använd en Doer istället. '),
        Msg(command not present, '<.parser>Det kommandot behövs inte i denna berättelse.<./parser> '),
        Msg(all not allowed, 'Tyvärr; ALLA är inte tillåtna med detta kommando. '),
        Msg(quit query, '<.p>Vill du verkligen avsluta? (j/n)?\n>'),
        Msg(undo okay, 'Ett drag ångrat: {1}'),
        Msg(undo failed, 'Ångra misslyckades. '),
        Msg(restart query, 'Vill du verkligen börja om från början (j/n)?\n>'),
        Msg(exit color onoff, 'Okej, färgning av oöppnade utgångar är nu {1}.<.p>'),
        Msg(exit color change, 'Okej, oöppnade utgångar i statusraden kommer nu att visas i {1}. '),
        Msg(no exit lister, 'Tyvärr, det kommandot är inte tillgängligt i detta spel, eftersom det inte f{i|a}nns någon utgångslista. '), 
        Msg(score not present, '<.parser>Denna berättelse använder inte poäng.<./parser> '), 
        Msg(hints not present, '<.parser>Tyvärr, denna berättelse har inga inbyggda ledtrådar.<./parser> '),
        Msg(no hints to disable, '<.parser>Detta spel har inga ledtrådar att stänga av.<./parser> '),
        Msg(no extra hints, 'Tyvärr, det f{i|a}nns inga extra ledtrådar i detta spel. '),
        Msg(extra hints on or off, 'Okej; extra ledtrådar är nu {1}. ' ),
        Msg(game now brief, 'Spelet är nu i KORT läge. <<first time>>Fullständiga rumsbeskrivningar kommer nu endast att visas vid första besöket i ett rum eller som svar på ett uttryckligt <<aHref('LOOK', 'LOOK', 'Titta runt')>> kommando.<<only>> '),
        Msg(game already brief, 'Spelet är redan i KORT läge. '),
        Msg(game already verbose, 'Spelet är redan i UTFÖRLIGT läge. '), 
        Msg(game now verbose, 'Spelet är nu i UTFÖRLIGT läge. <<first time>>Fullständiga rumsbeskrivningar kommer att visas varje gång ett rum besöks.<<only>> '),
        Msg(wait, 'Tiden {dummy} går. '),
        Msg(jump, '{Jag} hoppar på stället, fruktlöst. '),
        Msg(leap in the dark, 'Det kan vara klokare att inte ta ett språng i mörkret {här}.'),
        Msg(yell, '{Jag} skriker mycket högt. '),
        Msg(smell nothing intransitive, '{Jag} kän{ner|de} ingen ovanlig lukt.<.p>'),
        Msg(hear nothing listen, '{Jag} hör{|de} inget ovanligt.<.p>'),
        Msg(cant do special, '{Jag} {kaninte} {1} {ref dobj}. '),
        Msg(no sleeping, 'Detta {dummy} {är} ingen tid för att sova. '),
        Msg(already standing, '{Jag} står redan. '),
        Msg(vague travel, 'Vilken väg vill du gå? '), 
        Msg(nowhere back, '{Jag} har ingenstans att gå tillbaka till. '),
        Msg(no way back, 'Det f{i|a}nns ingen väg tillbaka. '),
        Msg(already back there, '{Jag} {är} redan där. '),
        Msg(going back dir, '(går {1})\n'),
        Msg(no journey, '{Jag} g{ick|år} ingenstans. '),
        Msg(off route, '{Jag} {är} inte längre på {min} rutt. Använd kommandot GÅ TILL för att ställa in en ny rutt. '),
        Msg(going dir, '(går {1})\n'),
        Msg(no interlocutor, '{Jag} pratar inte med någon. '),
        Msg(nothing to take, 'Det f{i|a}nns inget att ta från {1}. '),
        Msg(not on anything, '{Jag} {är} inte på något. '),
        Msg(not talking, '{Jag} pratar inte med någon. '),
        Msg(no one here, 'Det f{i|a}nns ingen här att prata med. '),
        Msg(think, '{Jag} {tänker}, därför {är} {jag}. '),
        Msg(scripting canceled, '<.parser>Avbruten.<./parser>'), 
        Msg(scripting failed exception, '<.parser>Misslyckades'),
        Msg(scripting failed, '<.parser>Misslyckades; ett fel uppstod vid öppning av skriptfilen.<./parser> '),
        Msg(script off ignored, '<.parser>Inget skript spelas in för närvarande.<./parser>'),
        Msg(script off okay, '<.parser>Skriptning avslutad.<./parser>'),
        Msg(recording canceled, '<.parser>Avbruten.<./parser> '), 
        Msg(recording failed exception, '<.parser>Misslyckades'), 
        Msg(recording failed, '<.parser>Misslyckades; ett fel uppstod vid öppning av kommandoinspelningsfilen.<./parser>'),
        Msg(record off ignored, '<.parser>Ingen kommandoinspelning görs för närvarande.<./parser> '),
        Msg(record off okay, '<.parser>Kommandoinspelning avslutad.<./parser> '),
        Msg(replay canceled, '<.parser>Avbruten.<./parser> '), 
        Msg(input script failed exception, '<.parser>Misslyckades'),
        Msg(input script failed, '<.parser>Misslyckades; skriptinmatningsfilen kunde inte öppnas.<./parser>'),
        Msg(save cancelled, '<.parser>Avbruten.<./parser> '), 
        Msg(save failed, '<.parser>Misslyckades; din dator kan ha ont om diskutrymme, eller så kanske du inte har nödvändiga behörigheter för att skriva denna fil.<./parser>'), 
        Msg(save okay, '<.parser>Sparad.<./parser> '),
        Msg(restore canceled, '<.parser>Avbruten.<./parser> '), 
        Msg(restore invalid file, '<.parser>Misslyckades: detta är inte en giltig sparad positionsfil.<./parser> '), 
        Msg(restore invalid match, '<.parser>Misslyckades: filen sparades inte av denna berättelse (eller sparades av en inkompatibel version av berättelsen).<./parser> '), 
        Msg(restore corrupted file, '<.parser>Misslyckades: denna sparade tillståndsfil verkar vara korrupt. Detta kan inträffa om filen ändrades av ett annat program, eller om filen kopierades mellan datorer i ett icke-binärt överföringsläge, eller om det fysiska mediet som lagrar filen skadades.<./parser> '), 
        Msg(restore failed, '<.parser>Misslyckades: positionen kunde inte återställas.<./parser>'), 
        Msg(restore okay, '<.parser>Återställd.<./parser> '),
        Msg(file prompt failed, '<.parser>Ett systemfel inträffade vid begäran om ett filnamn. Din dator kan ha ont om minne, eller kan ha ett konfigurationsproblem.<./parser> '),
        Msg(no repeat, 'Tyvärr, det f{i|a}nns ingen åtgärd att upprepa. '),
        Msg(cannot command system action, 'Endast spelaren kan utföra den typen av kommando. '),
        Msg(follow, '<.p>{ref follower} följ{er/de} efter {ref pc}. '),
        Msg(not interlocutor, '{I\'m} pratar inte med {1}. '),
        Msg(catch okay, '{Ref subj iobj} {fångar} {ref obj}. '),
        Msg(drop catch, '{Ref subj iobj} misslyckas med att fånga {ref obj}, så att {he obj} landar på marken istället. '),
        Msg(say head after actor, '{Jag} {går} {1} efter {2}. '),
        Msg(state follow, '{Ref follower} följ{er/de} efter {ref pc}. '),
        Msg(nothing to discuss on that topic, '{Jag} {har} inget att diskutera om det ämnet just nu. '), 
        Msg(waiting for follow, '{Ref subj myactor} väntar på {ref pc} {dummy} att följa {honom myactor} {1}. '),
        Msg(suggestion list intro, '{Jag} skulle kunna '),
        Msg(open suggestion list intro, 'Bland annat skulle {jag} kunna '),
        Msg(nothing in mind, '{Jag} {har} inget i åtanke att diskutera med {1} just nu. '),
        Msg(nothing specfic in mind, '{Jag} {har} vid det här laget inte bestämt {mig} för vad {jag} ska diskutera med {1}. '),
        Msg(or, ' eller '),
        Msg(cannot move while attached, '{Ref subj cobj} {kan} inte flyttas medan {he cobj} {är} fäst vid {ref other}. '), 
        Msg(okay plug in, '{Jag} kopplar in {1}. '),
        Msg(debugger not present, 'Debugger inte närvarande. '),
        Msg(fiat lux, '{Jag} {blir} plötsligt {1} lysande. '), // TODO: fixa
        Msg(no test scripts, 'Det f{i|a}nns inga testskript definierade i detta spel. '),
        Msg(test sequence not found, 'Testsekvensen hittades inte. '),
        Msg(debug test now holding, '{Jag} {håller} nu {1}.\n'),
        Msg(no shipboard directions, 'Skeppsriktningar {plural} {har} inte definierats. '),
        Msg(no compass directions, 'Kompassriktningar {plural} {har} inte definierats. '),
        Msg(explain exits on off, '<.p>Utgångslistning kan justeras med följande kommandon:\n UTGÅNGAR PÅ -- visa utgångar både i statusraden och i rumsbeskrivningar.\n UTGÅNGAR AV -- visa utgångar varken i statusraden eller i rumsbeskrivningar.\n UTGÅNGAR STATUS -- visa utgångar endast i statusraden.\n UTGÅNGAR TITT -- visa utgångar endast i rumsbeskrivningar.\n UTGÅNGAR FÄRG PÅ -- visa oöppnade utgångar i en annan färg.\n UTGÅNGAR FÄRG AV -- visa inte oöppnade utgångar i en annan färg.\n UTGÅNGAR FÄRG RÖD / BLÅ / GRÖN / GUL -- visa oöppnade utgångar i den angivna färgen. <.p>'), 
        Msg(no exits from here, 'Det f{i|a}nns inga utgångar härifrån. '),
        Msg(no exits, 'Utgångar: inga. '),
        Msg(no clear exits, 'Det är inte tydligt var {jag} {kan} gå härifrån. '),
        Msg(exits from here, '{Här}ifrån {kan} {jag} gå '),
        Msg(cmdhelp show options, 'Vad vill du göra?\b <<aHref('1','1')>>. Gå till en annan plats\n <<aHref('2','2')>>. Undersök dina omgivningar\n <<aHref('3','3')>>. Flytta något\n <<aHref('4','4')>>. Manipulera något\n'),
        Msg(cmdhelp talk to someone, '<<aHref('5','5')>>. Prata med någon\n'),
        Msg(cmdhelp where go, 'Vart vill du gå?\n De möjliga utgångarna är: '),
        Msg(cmdhelp no exit, 'Inga '),
        Msg(cmdhelp go to, 'Eller du skulle kunna: '),
        Msg(cmdhelp investigate, 'Här är några förslag (andra åtgärder kan också vara möjliga):\n'),
        Msg(cmdhelp relocate, 'Här är några förslag (det kan finnas flera andra möjligheter):\n'),
        Msg(cmdhelp manipulate, 'Några saker du kan prova inkluderar (det kan finnas många andra möjligheter):\b'),
        Msg(cmdhelp no one to talk to, 'Tyvärr, men det f{i|a}nns ingen här att prata med just nu.\b'),
        Msg(say dispensed, '{Jag} {tar} {1} från {2}. '),
        Msg(no such footnote, '<.parser>Berättelsen har aldrig hänvisat till någon sådan fotnot.<./parser> '),
        Msg(first footnote, 'Ett nummer i [hakparenteser] som det ovan hänvisar till en fotnot, som du kan läsa genom att skriva FOTNOT följt av numret: <<aHref('footnote 1', 'FOTNOT 1', 'Visa fotnot [1]')>>, till exempel. Fotnoter innehåller vanligtvis ytterligare bakgrundsinformation som kan vara intressant men inte är nödvändig för berättelsen. Om du föredrar att inte se fotnoter alls, kan du kontrollera deras utseende genom att skriva <<aHref('footnotes', 'FOTNOTER', 'Kontrollera fotnoters utseende')>>.'),
        Msg(acknowledge footnote status, '<.parser>Inställningen är nu {1}. <./parser>'),
        Msg(show footnotes off, 'AV, vilket döljer alla fotnotsreferenser. Skriv <<aHref('footnotes medium', 'FOTNOTER MEDIUM', 'Ställ in fotnoter till Medium')>> för att visa referenser till fotnoter förutom de du redan har sett, eller <<aHref('footnotes full', 'FOTNOTER FULL', 'Ställ in fotnoter till Full')>> för att visa alla fotnotsreferenser. '),
        Msg(show footnotes medium, 'MEDIUM, vilket visar referenser till olästa fotnoter, men döljer referenser till de du redan har läst. Skriv <<aHref('footnotes off', 'FOTNOTER AV', 'Stäng av fotnoter')>> för att dölja fotnotsreferenser helt, eller <<aHref( 'footnotes full', 'FOTNOTER FULL', 'Ställ in fotnoter till Full')>> för att visa varje referens, även till anteckningar du redan har läst. '),
        Msg(show footnotes full, 'FULL, vilket visar varje fotnotsreferens, även till anteckningar du redan har läst. Skriv <<aHref('footnotes medium', 'FOTNOTER MEDIUM', 'Ställ in fotnoter till Medium')>> för att visa endast referenser till anteckningar du ännu inte har läst, eller << aHref('footnotes off', 'FOTNOTER AV', 'Stäng av fotnoter')>> för att dölja fotnotsreferenser helt. '),
        //Msg(posture already adopted, '{Jag} {1} redan. '),
        //Msg(okay adopt posture, 'Okej, {jag} {1} nu. '), 
        Msg(okay get on posture, '{1} på {2}. '),
        Msg(cannot board self, '{Jag} {kan} knappast borda {mig} själv. '),
        Msg(cannot add to derived relation, 'FEL! Du kan inte explicit relatera objekt via en härledd relation (%1). '),
        Msg(cannot remove from derived relation, 'FEL! Du kan inte explicit ta bort en härledd relation (%) mellan objekt. '),
        Msg(no such relation, 'FEL, det f{i|a}nns ingen sådan relation som <q>{1}</q>. '),
        Msg(no relations defined, 'Inga relationer är definierade i detta spel. '),
        Msg(no such relation, 'Det f{i|a}nns ingen sådan relation i spelet som {1}. '),
        Msg(cant list derived relation, '<i>Eftersom {1} {är} en DerivedRelation, kan inga objekt den relaterar listas.</i> '),
        Msg(no relations defined, '<i>inga relationer definierade</i> '),
        Msg(onset of darkness, '\n{Jag} {är} nedsänkt i mörker. '),
        Msg(command prompt, '>'), 
        Msg(too heavy, '{Ref subj obj} {är} för tung{t/a} för att gå {1} {2}. '),
        Msg(cant bear more weight, '{Ref subj this} {kan} inte bära mer vikt. '),
        Msg(too heavy to carry, '{Ref subj dobj} {är} för tung{t/a} för {mig} att bära. '),
        Msg(cannot carry any more weight, '{Jag} {kan} inte bära så mycket mer vikt. '),
        Msg(too heavy to hide, '{Ref sub obj} {är} för tung{t/a} för att gömma {1} {2}. '),
        Msg(collective group empty, 'Det f{i|a}nns ingen {1} här. '),
        Msg(carrying collective group, '{Jag} {bär} {1}. '),
        Msg(collective group members, 'Det f{i|a}nns {1} här. '),
        Msg(say departing up stairs, '{Ref subj traveler} {går} upp {1}. '),
        Msg(say following up staircase, '{Ref subj follower} följ{er/de} {ref leader} upp {1}. '),
        Msg(say departing down stairs, '{Ref subj traveler} {går} ner {1}. '),
        Msg(say following down staircase, '{Ref subj follower} följ{er/de} {ref leader} ner {1}. '),
        Msg(click, 'Klick!'), 
        Msg(okay pulled, 'Gjort|{Jag} {drar} {1}'), 
        Msg(okay pushed, 'Gjort|{Jag} {trycker} {1}'), 
        Msg(hints disabled, '<.parser>Ledtrådar är nu inaktiverade.<./parser> '),
        Msg(sorry hints disabled, '<.parser>Tyvärr, men ledtrådar har inaktiverats för denna session, som du begärde. Om du har ändrat dig, måste du spara din nuvarande position, avsluta TADS-tolken och starta en ny tolksession.<./parser> '),
        Msg(currently no hints, '<.parser>Tyvärr, inga ledtrådar är för närvarande tillgängliga. Vänligen återkom senare.<./parser> '),
        Msg(hints done, '<.parser>Gjort.<./parser> '),
        Msg(showHintWarning, '<.notification>Varning: Vissa människor gillar inte inbyggda ledtrådar, eftersom frestelsen att be om hjälp för tidigt kan bli överväldigande när ledtrådar är så nära till hands. Om du är orolig för att din viljestyrka inte kommer att hålla, kan du inaktivera ledtrådar för resten av denna session genom att skriva <<aHref('hints off', 'LEDTRÅDAR AV')>>'),
        Msg(explain extra hints, 'Om du är ny på Interaktiv Fiktion och vill läsa några extra tips och råd som kommer att dyka upp här och där när du utforskar berättelsen, skriv <<cmdStr('PÅ')>>. Om du bestämmer dig för att du inte vill ha fler av dessa bonustips, skriv bara <<cmdStr('AV')>>. '),
        Msg(note with script, 'Kommentar inspelad. '),
        Msg(note without script warning, 'Kommentar INTE inspelad. '),
        Msg(note without script, 'Kommentar INTE inspelad. '),
        Msg(command prompt, '>'),
        Msg(note main restore, 'Spelet återställt.<.p>'),
        Msg(show finish msg, '\b*** {1} ***\b\b'),
        Msg(invalid finish option, '<q>{1}</q> var inte ett av alternativen.<.p>'),
        Msg(show version, '{1} version {2}'), 
        Msg(token error, 'Jag förstår inte skiljetecknet {1}'),
        Msg(empty command line, 'Jag ber om ursäkt?'),
        Msg(not understood, 'Jag förstår inte det kommandot.'), 
        Msg(unknown word, 'Jag kän{ner|de} inte till ordet ""{1}"".'),
        Msg(no oops now, 'Tyvärr, jag är inte säker på vad du rättar.'),
        Msg(unmatched actor, '{Jag} {ser} inte {1} här.'),
        Msg(unmatched noun, '{Jag} {ser} inte {2} här.'),
        Msg(undo tip, 'Om detta inte blev riktigt som det var avsett, är det bra att veta att du alltid kan återställa ett 
                        eller flera kommandon genom att skriva <<aHref('ångra', 'ÅNGRA', 'Ta tillbaka det senaste kommandot')>>.'),
        Msg(oops tip, 'Om detta var en oavsiktlig felstavning, så kan du rätta den genom att skriva OOPS
                        följd av det rättade ordet nu. Varje gång spelet pekar ut ett okänt ord, kan du rätta
                        det genom att använda OOPS som ditt nästa kommando.'),
        Msg(no antecedent, 'Jag är inte säker på vad du menar med ""{1}"".'),
        Msg(antecedent out of scope, '{Jag} {ser} inte längre det här.'),
        Msg(nothing suitable for all, 'Det f{i|a}nns inget lämpligt för ALLA att hänvisa till. '),
        Msg(not enough nouns, '{Jag} {ser|såg} inte så många {2} här.'), 
        Msg(none in owners, 'Jag förstår inte vem "{2}" syftar på.'),
        Msg(none in owner, '{Ref subj obj} verkar inte ha någon {2}.'),
        Msg(none in locations, '{Jag} {ser|såg} ingen {2} {3} någon {4}.'),
        Msg(none in location, '{Jag} {ser|såg} ingen {2} {3} {ref 4}.'),
        Msg(none with contents in list, '{Jag} {ser|såg} ingen {2} av {3}.'),
        Msg(none with contents, '{Jag} {ser|såg} ingen {2} av {3}.'),
        Msg(be more specific, 'Jag vet inte vilka du menar. Kan du vara mer specifik?'),
        Msg(ordinal out of range, 'Tyvärr, jag {ser} inte vad du hänvisar till.'),
        Msg(multi not allowed, 'Tyvärr; flera objekt är inte tillåtna med det kommandot.'), 
        Msg(container needs to be open, '{Ref subj obj} måste vara öpp{en/et/na} för det. '),
        Msg(object needs to be open, '{Ref subj obj} måste vara öpp{en/et/na} för det. '),
        Msg(obj needs to be closed, '{Ref subj obj} måste vara stängd för det. '),
        Msg(need to hold, '{Jag} måste hålla {ref obj} för att göra det. '),
        Msg(cannot do that while wearing, '{Jag} {kan} inte göra det medan {he actor} bär {ref obj). '),
        Msg(cannot do that while attached, '{Jag} {kan} inte göra det medan {ref subj obj} {är} fäst vid {ref att). '),
        Msg(no staging loc, '{Ref subj obj} {kan} inte nås. '),
        Msg(still in nested, '{Jag} {kan} inte göra det medan {he actor} {är} {i loc}.'),
        Msg(full score item points, '\n <<totalPoints>> poäng<<totalPoints == 1 ? '' : 's'>> för '),
        Msg(full score prefix, 'Din poäng består av:'),
        Msg(show score rank, 'Detta gör dig {1}. '), 
        Msg(remote contents prefix, '<.p>\^{1} {ser} {jag} '), 
        Msg(remote contents suffix, '. '), 
        Msg(remote subcontents prefix, '<.p>\^{1} {är} '),
        Msg(remote subcontents suffix, '. '),
        Msg(implicit go, '(först g{ick|år} till {1})\n'),
        Msg(corrected spelling, '(<i>{1}</i>)<br>'),
        Msg(dark desc, 'Det {är} kolsvart; {jag} {kan} inte se något alls. '),
        Msg(proxy room desc, '{Jag} {kan} inte se mycket av {ref dobj} härifrån. '),
        Msg(list immediate container, '{Jag} {befinner|befann} {mig} {i loc}. <.p>'),
        Msg(too big, '{Ref subj obj} {är} för stor{t/a} för att passa {1} {2}. '),
        Msg(no room, 'Det f{i|a}nns inte tillräckligt med utrymme {1} {2} för {ref obj}. '), 
        Msg(cannot command thing, 'Det f{i|a}nns ingen mening med att försöka ge order till {1}. '),
        Msg(nothing special, '{Jag} {ser} inget speciellt med {ref 1}. '), 
        Msg(taste nothing, '{Jag} smaka{r|de} inget oväntat.<.p>'),
        Msg(feel nothing, '{Jag} kän{ner|de} inget oväntat.<.p>'),
        Msg(report take, 'Tag{en/et/na}. | {Jag} {tar|tog} {1}. '),
        Msg(too big to carry, '{Ref subj dobj} {är} för stor{t/a} för {mig} att bära. '),
        Msg(cannot carry any more, '{Jag} {kan} inte bära mer än {jag} redan bär. '),
        Msg(report drop, 'Släppt. |{Jag} släpper {1}. '), 
        Msg(throw dir, '{Jag} kastar {ref obj} {1} och {he obj} landar på marken. '),
        Msg(okay open, 'Öppnad. |{Jag} {öppnar} {1}. '),
        Msg(report close, 'Gjort. |{Jag} {stänger} {1}. '),
        Msg(report put on, '{Jag} lägger {1} på {ref iobj}. '), 
        Msg(report put in, '{Jag} lägger {1} i {ref iobj}. '), 
        Msg(no room in, 'Det f{i|a}nns inte tillräckligt med utrymme för {ref dobj} i {ref iobj}. '), 
        Msg(report put under, '{Jag} lägger {1} under {ref iobj}. '),
        Msg(no room under, 'Det f{i|a}nns inte tillräckligt med utrymme för {ref dobj} under {ref iobj}. '), 
        Msg(report put behind, '{Jag} lägger {1} bakom {ref iobj}. '),
        Msg(no room behind, 'Det f{i|a}nns inte tillräckligt med utrymme för {ref dobj} bakom {ref iobj}. '), 
        Msg(report unlock, 'Upplåst{a}.|{Jag} {låser} upp {1}. '),
        Msg(report lock, 'Låst{a}.|{Jag} {låser} {1}. '),
        Msg(report turn on, 'Gjort.|{Jag} slår på {ref dobj}. '),
        Msg(report turn off, 'Gjort.|{Jag} slår av {ref dobj}. '),
        Msg(report switch, 'Okej, {jag} slår {1} {2}. '),
        Msg(okay wear, 'Okej, {jag} har nu på {sig} {1}. '),
        Msg(okay doff, 'Okej, {jag} har inte längre på {sig} {1}. '),
        Msg(throw, '{Ref subj obj} seglar genom luften och landar på marken. '),
        Msg(okay get on, '{Jag} g{ick|år} på {1}. '),
        Msg(okay get in, '{Jag} g{ick|år} in i {1}. '),
        Msg(okay move to, '{Jag} flyttar {1} {dummy} till {ref iobj}. '),
        Msg(okay lit,'Gjort.|{Jag} tänder {1}. '),
        Msg(extinguish, '{Jag} släcker {1}. '),
        Msg(eat, '{Jag} äter {1}. '),
        Msg(okay clean, 'Rengjord|{Jag} rengör {1}. '),
        Msg(throw at, '{Ref subj obj} träffar {ref iobj} och landar på marken. '),
        Msg(okay turn to, 'Okej, {jag} vrider {1} till {2}'),
        Msg(okay set to, '{Jag} ställ{er|de} in {1} till {2}. '), 
        Msg(route unknown, '{Jag} vet inte hur man kommer dit. '),
        Msg(destination unknown, '{Jag} vet inte hur man når {honom dobj}.' ),
        Msg(okay fasten, 'Gjort|{Jag} fäster {1}. '),
        Msg(report kiss, 'Att kyssa {1} {dummy} {visar} sig vara märkbart otillfredsställande. '), 
        Msg(jump off, '{Jag} hoppar av {1} och landar på marken'),
        Msg(before push travel dir, '{Jag} tryck{er|te} {ref dobj} {1}. '),
        Msg(describe move pushable, '{Ref subj obj} stannar. ' ),
        Msg(push travel traversal, '{Jag} <<if matchPullOnly>> drar {ref dobj} {1}. '),
        Msg(push travel somewhere, '{Jag} <<if matchPullOnly>> drar {ref dobj} {1}. '),
        Msg(purloin, '{Jag} plötsligt {hittar} {mig själv} hållande {1}. '),
        Msg(gonear, '{Jag} förflytta{s|des} i ett ögonblick...<.p>'),
        Msg(okay unlock with, '{Jag} {låser} upp {ref dobj} med {ref iobj}. '),
        Msg(okay lock with, '{Jag} {låser} {ref dobj} med {ref iobj}. '),
        Msg(npc opens door, '{Ref subj traveler} {öppnar} {ref obj}. '),
        Msg(door opens, '{Ref subj obj} {öppnas}. '),
        Msg(say departing through door, '{Ref subj traveler} {lämnar} genom {1}. '),
        Msg(say following through door, '{Ref subj follower} följ{er/de} {ref leader} genom {1}. '),
        Msg(no destination, 'Det {dummy} leder ingenstans. '),
        Msg(say departing vague, '<.p>{Ref subj traveler} {lämnar} området. '),
        Msg(say departing dir, '<.p>{Ref subj traveler} {går} {1}. '),
        Msg(say following vague, '<.p>{Ref subj follower} följ{er/de} {ref leader}. '),
        Msg(say following dir, '<.p>{Ref subj follower} följ{er/de} {ref leader} {1}. '),
        Msg(fail check, '{Jag} {kan} inte göra det (men författaren till detta spel misslyckades med att specificera varför).'),
        Msg(mention full score, 'För att se din kompletta lista över prestationer, använd kommandot <<aHref('full score', 'FULL POÄNG', 'visa full poäng')>>. '),
        Msg(extra hints off, 'av'),
        Msg(extra hints on, 'på'),
        Msg(extra hints command, 'EXTRA '),
        Msg(explain continue, 'För att fortsätta resan använd kommandot <<aHref('Continue','FORTSÄTT','Fortsätt')>> eller C. '),
        Msg(get scripting prompt, 'Vänligen välj ett namn för den nya skriptfilen'),
        Msg(cannot take actor, '{Ref subj dobj} {vill} inte låta {mig} {dummy} plocka upp {honom dobj}. '),
        Msg(no response, '{Ref subj cobj} {svarar} inte. '),
        Msg(refuse command, '{Jag} {har} bättre saker att göra. '),
        Msg(follow actor, '{Jag} följ{er/de} {1}. '),
        Msg(actor stays put, '{Jag} vänta{r/de} förgäves på att {1} ska gå någonstans. '),
        Msg(no hello response, '{Jag} {har} nu {1} uppmärksamhet. '),
        Msg(already talking, '{Jag} {pratar} redan med {1}. '),
        Msg(no goodbye response, 'Samtalet {dummy} fortsätter. '),
        Msg(cannot take from actor, '{Ref subj this} {vill} inte låta {mig} ta {ref obj} från {honom dobj}. '),
        Msg(should not kiss, 'Det verkar knappast vara en bra idé att kyssa {ref dobj}. '),
        Msg(kiss response, '{Ref subj dobj} {gillar} inte att bli kysst. '),
        Msg(cannot attack actor, 'Det verkar knappast vara en bra idé att attackera {ref dobj}. '),
        Msg(should not touch actor, '{Ref subj dobj} {gillar} inte att bli rörd. '),
        Msg(wait to see, '{Jag} väntar för att se var {he dobj} går. '),
        Msg(dont know where gone, '{Jag} vet inte var {ref subj dobj} har gått. '),
        Msg(cannot start from here, '{Jag}{\'m} inte där {jag} {kan} börja. '),
        Msg(cannot follow from here, '{Jag} {kan} inte följa {honom dobj} härifrån. '),
        Msg(say yes, 'säg ja'),
        Msg(say no, 'säg nej'),
        Msg(say yes or no, 'säg ja eller nej'),
        Msg(say prefix, 'säg '),
        Msg(ask query, 'fråga {honom interlocutor} '),
        Msg(ask about, 'fråga {honom interlocutor} om '),
        Msg(tell about, 'berätta {honom interlocutor} om '),
        Msg(talk about, 'prata om ') ,
        Msg(give, 'ge {honom interlocutor} '),
        Msg(show, 'visa {honom interlocutor} '),
        Msg(ask for, 'be {honom interlocutor} om '),
        Msg(tell to, 'berätta {honom interlocutor} att '),
        Msg(or list separator, '; eller '),
        Msg(okay attach, '{Jag} fäster {1} till {ref iobj}. ') ,
        Msg(already attached, '{Ref subj dobj} {är} redan fäst vid {1}. '),
        Msg(not attached, '{Ref subj dobj} {är} inte fäst vid något. '),
        Msg(okay detach, '{Jag} lossar {1}. '),
        Msg(okay detach from, '{Jag} lossar {1} från {ref iobj}. '),
        Msg(cannot detach from, 'Det f{i|a}nns ingenting som {kan} lösgöras från {ref iobj}.'),
        Msg(cannot detach this, '{Ref subj dobj} {kan} inte lossas från {1}. '),
        Msg(cannot detach from self, '{Ref subj dobj} {kaninte} tas loss från {sigsjälv dobj}. '),
        Msg(not attached to that, '{Ref subj dobj} {är} inte fäst vid det. '),
        Msg(nothing attached, 'Det f{i|a}nns inget fäst vid {ref iobj}. '),
        Msg(cannot be attached, '{Ref subj dobj} {kan} inte fästas vid {ref iobj}. '),
        Msg(cannot attach to more, '{Jag} {kan} inte fästa {ref dobj} vid något annat medan {he dobj} {är} fäst vid {1}. '),
        Msg(okay plug, '{Jag} kopplar in {1} i {ref iobj}. ') ,
        Msg(already plugged in, '{Ref subj dobj} {är} redan inkopplad i {1}. '),
        Msg(already plugged in vague, '{Ref subj dobj} {är} redan inkopplad. '),
        Msg(cannot plug in any more, '{Jag} {kan} inte koppla in mer i {ref iobj}. '),
        Msg(cannot be plugged in, '{Ref subj dobj} {kan} inte plugga in i {ref iobj}. '),
        Msg(okay unplug from, '{Jag} drar ur {1} från {ref iobj}. '),
        Msg(not plugged in, '{Ref subj dobj} {är} inte inkopplad i något. '),
        Msg(not plugged into that, '{Ref subj dobj} {är} inte inkopplad i {ref iobj}. '),
        Msg(being worn, ' (buren)'), //alt: ' (påklädd)'
        Msg(implicit action report start, '('),
        Msg(implicit action report separator, ' sedan '),
        Msg(implicit action report terminator, ' först)\n'),
        Msg(implicit action report failure, 'försöker '),
        Msg(exits, 'Utgångar:'),
        Msg(cant take from dispenser, '{Jag} {kan} inte ta {a dobj} från {ref iobj}. '),
        Msg(cannot dispense, '{Jag} {kan} inte ta mer från {ref dobj}. '),
        Msg(not that many left, 'Det f{i|a}nns inte så många kvar att ta. '),
        Msg(footnote ref, '<sup>[<<aHref('footnote ' + num, toString(num))>>]</sup>'),
        Msg(footnotes, 'FOTNOTER '),
        Msg(footnote off, 'AV'),
        Msg(footnote medium, 'MEDIUM'),
        Msg(footnote full, 'FULL'),
        Msg(say burned out, '{Ref subj obj} slocknar'),
        Msg(plunged into darkness, ', nedsänker {1} i mörker'),
        Msg(wont light, '\^{1} {dummy} vill inte tändas. '),
        Msg(stands, 'står'),
        Msg(standing, 'stående'),
        Msg(i stand, '{Jag} står'),
        Msg(sits, 'sitter'),
        Msg(sitting, 'sittande'),
        Msg(i sit, '{Jag} sitter'),
        Msg(lies, 'ligger'),
        Msg(lying, 'liggande'),
        Msg(i lie, '{Jag} ligger'),
        Msg(okay stand on, '{Jag} står på {1}. '),
        Msg(okay sit on, '{Jag} {sätter} {mig} på {1}. '),
        Msg(okay lie on, '{Jag} {lägger} {mig} på {1}. '),
        Msg(cannot stand in, '{Jag} {kan} inte stå i {ref dobj}. '),
        Msg(okay stand in, '{Jag} står i {1}. '),
        Msg(okay sit in, '{Jag} {sitter} i {1}. '),
        Msg(cannot sit in, '{Jag} {kan} inte sitta i {ref dobj}. '),
        Msg(okay lie in, '{Jag} ligger i {1}. '),
        Msg(cannot lie in, '{Jag} {kan} inte ligga i {ref dobj}. '),
        Msg(sky beyond reach, '{Ref subj cobj} {är} långt bortom {min} räckvidd. '),
        Msg(cannot do to sensory, '{Jag} {kan} inte göra det mot {a cobj}. '),
        Msg(only smell, '{Jag} {kan} inte göra det mot en lukt. '),
        Msg(only listen, '{Jag} {kan} inte göra det mot ett ljud. '),
        Msg(nothing on, '{Jag} hitta{r|de} inget av intresse på {ref dobj}. '),
        Msg(cannot take component, '{Jag} {kan} inte ta {detta cobj}, {he dobj} {är} en del av {1}. '),
        Msg(distant, '{Ref subj cobj} {är} för långt borta. '),
        Msg(unthing absent, '{Ref subj cobj} {är} inte här. '),
        Msg(too heavy, '{Ref subj cobj} {är} för tung{t/a} för att flytta. '),
        Msg(cannot take immovable, '{Jag} {kan} inte ta {ref cobj). '),
        Msg(traverse stairway up, 'upp {1}'),
        Msg(traverse stairway down, 'ner {1}'),
        Msg(cannot climb stairway down, '{Jag} {kan} inte klättra {ref dobj}, men {jag} {kan} gå ner {honom dobj}. '),
        Msg(traverse path passage, 'ner {1}'),
        Msg(cannot take container door, '{Jag} {kan} inte ta {ref cobj}; {he dobj} {är} en del av {1}. '),
        Msg(already pulled, '{Ref subj dobj} {är} redan i draget läge. '),
        Msg(already pushed, '{Ref subj dobj} {är} redan i tryckt läge. '),
        Msg(invalid setting, 'Det är inte en giltig inställning för {ref dobj}. '),
        Msg(okay set, '{Jag} ställer in {ref dobj} till {1}. '),
        Msg(already set, '{Ref subj dobj} {är} redan inställd på {1}. '),
        Msg(finish death, 'DU HAR DÖTT'),
        Msg(finish victory,'DU HAR VUNNIT'),
        Msg(finish failure, 'DU HAR MISSLYCKATS'),
        Msg(finish game over, 'SPELET ÄR SLUT'),
        Msg(first person pronoun, 'Jag'),
        Msg(command results prefix, '<.p0>'),
        Msg(command interuption prefix, '<.p>'),
        Msg(command results separator, '<.p>'),
        Msg(command results empty, 'Inget uppenbart {dummy}{händer}.<.p>'),
        Msg(command results suffix, ''),
        Msg(cannot see obj, '{Jag} {kan} inte se {1}. '),
        Msg(too far away to hear obj, '{Ref subj obj} {är} för långt borta för att höra. '),
        Msg(cannot hear, '{Jag} {kan} inte höra {1} genom {2}. '),
        Msg(too far away to smell obj, '{Ref subj obj} {är} för långt borta för att lukta. '),
        Msg(cannot smell through, '{Jag} {kan} inte lukta {1} genom {2}. '),
        Msg(in room name, 'i {1}'),
        Msg(too far away to see detail, '{Ref subj dobj} {är} för långt borta för att se några detaljer. '),
        Msg(too far away to hear, '{Ref subj dobj} {är} för långt borta för att höra tydligt. '),
        Msg(too far away to read, '{Ref subj dobj} {är} för långt borta för att läsa. '),
        Msg(too far away to smell, '{Ref subj dobj} {är} för långt borta för att lukta tydligt. '),
        Msg(command look around, 'titta runt'),
        Msg(command full score, 'full poäng'),
        Msg(dark name, 'I mörkret'),
        Msg(cannot reach, '{Jag} {kan} inte nå {ref target} genom {ref obj}. '),
        Msg(too far away, '{Ref subj obj} {är} för långt borta. '),
        Msg(cannot reach out, '{Jag} {kan} inte nå {ref target} från {ref loc}. '),
        Msg(not important, '{Ref subj cobj} {är} inte viktig{t/a}. '), 
        Msg(too dark to see, 'Det {är} för mörkt för att se något. '),
        Msg(cannot smell, '{Jag} {kan} inte lukta på {ref dobj}. '),
        Msg(smell nothing, '{Jag} {känner} ingen ovanlig lukt.<.p>'),
        Msg(hear nothing listen to, '{Jag} hör{|de} inget ovanligt.<.p>'),
        Msg(cannot taste, '{Ref subj dobj} {är} inte lämplig{t/a} att smaka på. '),
        Msg(cannot feel, 'Det {är} knappast en bra idé att försöka känna på {ref dobj}. '),
        Msg(cannot take, '{Ref subj dobj} {sitter} fast på plats. '),
        Msg(already holding, '{Jag} {håller} i {ref dobj} redan. '),
        Msg(already holding objects, '{Jag} {håller} redan i {1}.\n'),
        Msg(too big for me to hold, '{1} för {mig} att hålla i. '),
        Msg(hands too full to hold, 'Mina händer är för fulla för att hålla i {1}.\n '),
        Msg(cannot take my container, '{Jag} {kan} inte ta {ref dobj} medan {jag} {befinner} {mig} {1} {honom dobj}. '),
        Msg(cannot take self, '{Jag} {kan} knappast ta {mig} själv. '),
        Msg(reveal move under,'Flyttar {1} {dummy} avslöja{r/de} {2} tidigare dold under {3}. '),
        Msg(reveal move behind,'Flyttar {1} {dummy} avslöja{r/de} {2} tidigare dold bakom {3}. '),
        Msg(cannot drop, '{Jag} {kan} inte släppa {ref subj dobj}. '),
        Msg(not holding, '{Jag} {håller} inte i {ref dobj}. '),
        Msg(not holding any, '{Jag} {håller} inte i något av dem. '),
        Msg(part of me, '{Ref subj dobj} {är} en del av {mig}. '),
        Msg(cannot read, 'Det f{i|a}nns inget att läsa på {ref dobj}. '),
        Msg(cannot follow, '{Ref subj dobj} {går} ingenstans. '),
        Msg(cannot follow self, '{Jag} {kan} inte följa {mig} själv. '),
        Msg(cannot attack, 'Bäst att undvika meningslöst våld. '),
        Msg(futile attack, 'Att attackera {1} {visar} sig vara meningslöst. '),
        Msg(cannot attack with self, '{Jag} {kan} inte attackera något med {mig} själv. '),    
        Msg(cannot attack with, '{Jag} {kan} inte attackera någonting alls med {detta iobj}. '),
        Msg(cannot break, '{Ref subj dobj} {är} inte något {jag} {kan} ta sönder. '),
        Msg(dont break, '{Jag} {ser} ingen mening med att ta sönder {detta dobj}. '),
        Msg(cannot throw, '{Jag} {kan} inte kasta {ref dobj} någonstans. '),
        Msg(cannot open, '{Ref subj dobj} {är} inte något {jag} {kan} öppna. '),
        Msg(already open, '{Ref subj dobj} {är} redan öpp{en/et/na}. '),
        Msg(locked, '{Ref subj dobj} {är} låst{a}. '),
        Msg(not closeable, '{Ref subj dobj} {är} inte något som {kan} stängas. '),
        Msg(already closed,'{Ref subj dobj} {är} inte öpp{en/et/na}. '),
        Msg(cannot turn, '{Ref subj dobj} {kan} inte vridas. '),
        Msg(turn useless, 'Att vrida på {1} {dummy} {gör} ingen nytta. '),
        Msg(cannot turn with, '{Jag} {kan} inte vrida någonting med {detta iobj}. '),
        Msg(turn self, '{Jag} {kan} inte vrida någonting med {sig} själv. '),
        Msg(cannot cut, '{Jag} {kan} inte skära {ref dobj}. '),
        Msg(cannot cut with, '{Jag} {kan} inte skära något med {detta iobj}. '),
        Msg(cannot cut with self, '{Jag} {kan} inte skära något med {sig} själv. '),
        Msg(look in, '{Jag} {ser} inget intressant i {ref dobj}. '),
        Msg(cannot look under, '{Jag} {kan} inte titta under {detta dobj}. '),
        Msg(look under, '{Jag} hitta{r|de} inget av intresse under {ref dobj}. '),
        Msg(cannot look behind, '{Jag} {kan} inte titta bakom {detta dobj}. '),
        Msg(look behind, '{Jag} hitta{r|de} inget intressant bakom {ref subj dobj}. '),
        Msg(cannot look through, '{Jag} {kan} inte titta genom {detta dobj}. '),
        Msg(look through, '{Jag} {ser} inget genom {ref dobj}. '),
        Msg(cannot go through,'{Jag} {kan} inte gå genom {detta dobj}. '),
        Msg(cannot push, 'Det f{i|a}nns ingen mening med att försöka trycka på {detta dobj}. '),        
        Msg(push no effect, 'Att trycka på {1} {dummy} {har} ingen effekt. '),
        Msg(cannot pull, 'Det f{i|a}nns ingen mening med att försöka dra {detta dobj}. '),
        Msg(pull no effect, 'Att dra {1} {dummy} {har} ingen effekt. '),        
        Msg(already in, '{Ref subj dobj} {är} redan {1}. '),        
        Msg(circularly in, '{Jag} {kan} inte lägga {ref dobj} {1} medan {ref subj iobj} {är} {i dobj}. '),
        Msg(cannot put in self, '{Jag} {kan} inte lägga {ref dobj} {1} {sigsjälv dobj}. '),
        Msg(cannot put on,'{Jag} {kan} inte lägga något på {ref iobj}. ' ),
        Msg(cannot put in, '{Jag} {kan} inte lägga något i {ref iobj}. '),
        Msg(cannot put under, '{Jag} {kan} inte lägga något under {ref iobj}. ' ),
        Msg(cannot put behind, '{Jag} {kan} inte lägga något bakom {ref iobj}. '),
        Msg(not lockable, '{Ref subj dobj} {är} inte låsbar{t/a}. '),
        Msg(key not needed,'{Jag} behöver inte en nyckel för att låsa och låsa upp {ref dobj}. '),
        Msg(indirect lockable,'{ref dobj} verkar använda någon annan typ av låsmekanism. '),
        Msg(not locked, '{Ref subj dobj} {är} inte låst{a}. '),
        Msg(cannot unlock with, '{Jag} {kan} inte låsa upp något med {detta dobj}. ' ),
        Msg(cannot unlock with self, '{Jag} {kan} inte låsa upp något med {sigsjälv dobj}. ' ),
        Msg(already locked, '{Ref subj dobj} {är} redan låst{a}. '),
        Msg(cannot lock with, '{Jag} {kan} inte låsa något med {detta dobj}. ' ),
        Msg(cannot lock with self, '{Jag} {kan} inte låsa något med {sigsjälv dobj}. ' ),
        Msg(with key, '<.assume>med {1}<./assume>\n'),
        Msg(key doesnt work, 'Tyvärr fungerar inte {1} {dummy} på {ref dobj}. '),
        Msg(not switchable, '{Ref subj dobj} {kan} inte slås på och av. '),
        Msg(already switched on, '{Ref subj dobj} {är} redan påslag{en/et/na}. '),
        Msg(not switched on, '{Ref subj dobj} {är} inte påslag{en/et/na}. '),
        Msg(cannot flip, '{Jag} {kan} inte använda {ref dobj}. '),
        Msg(cannot burn, '{Jag} {kan} inte bränna {ref dobj}. '),
        Msg(cannot burn with, '{Jag} {kan} inte bränna {ref dobj} med {detta iobj}. '),
        Msg(cannot wear, '{Ref subj dobj} {går} inte att bära. '),
        Msg(already worn, '{Jag} {har} redan på {sig} {ref dobj}. '),
        Msg(not worn, '{Jag} {har} inte på {sig} {ref dobj}. '),
        Msg(cannot climb,'{Ref subj dobj} {är} inte något som {jag} {kan} klättra på. '),
        Msg(cannot climb down, '{Ref subj dobj} {är} inte något som {jag} {kan} klättra ner för. '),
        Msg(cannot board, '{Ref subj dobj} {är} inte något {jag} {kan} gå på. '),
        Msg(already on, '{Jag} {är} redan {i dobj}. '),
        Msg(cannot board carried, '{Jag} {kan} inte gå på {ref dobj} medan {jag} bär {honom dobj}. '),
        Msg(cannot stand on, '{Ref subj dobj} {är} inte något {jag} {kan} stå på. '),
        Msg(cannot sit on, '{Ref subj dobj} {är} inte något {jag} {kan} sitta på. '),
        Msg(cannot lie on, '{Ref subj dobj} {är} inte något {jag} {kan} ligga på. '),
        Msg(cannot enter, '{Ref subj dobj} {är} inte något {jag} {kan} gå in i. '),
        Msg(actor already in, '{Jag} {är} redan {i dobj}. '),
        Msg(cannot enter carried, '{Jag} {kan} inte gå in i {ref dobj} medan {jag} bär på {dem dobj}. '),
        Msg(okay get outof, 'Okej, {jag} {kliver} {utur dobj}. '),
        Msg(actor not in,'{Jag} {är} inte i {ref dobj}. '),
        Msg(actor not on,'{Jag} {är} inte på {ref dobj}. '),
        Msg(cannot remove, '{Ref subj dobj} {kan} inte tas bort. '),
        Msg(cannot move, '{Ref subj dobj} {rör} {obj dobj} inte. '),        
        Msg(move no effect, 'Det ger ingenting att flytta på {1}{dummy}. '),
        Msg(cannot move with, '{Jag} {kan} inte flytta {ref dobj} med {ref iobj}. '),    
        Msg(not by obj, '{Ref subj dobj} {är} inte vid {ref iobj}. '),
        Msg(cannot move with self, '{Ref subj dobj} {kan} inte användas för att flytta {sigsjälv dobj}. '),
        Msg(cannot move to, '{Ref subj dobj} {kan} inte flyttas till {ref iobj}. '),
        Msg(cannot move to self, '{Ref subj dobj} {kan} inte flyttas till {sigsjälv dobj}. '),
        Msg(already moved to, '{Ref subj dobj} {har} redan flyttats till {ref iobj}. '),
        Msg(cant move away from self, '{Jag} {kan} inte flytta bort {ref dobj} från {sigsjälv dobj}. '),
        Msg(cannot light, '{Ref subj dobj} {är} inte något {jag} {kan} tända. '),
        Msg(already lit, '{Ref subj dobj} {är} redan tän{d/t/da}. '),
        Msg(not lit, '{Ref subj dobj} {är} inte tän{d/t/da}. '),
        Msg(cannot extinguish, '{Ref dobj} {kan} inte släckas. '),
        Msg(cannot eat, '{Ref subj dobj} {är} uppenbarligen oätlig{t/a}. '),
        Msg(not potable, '{Jag} {kan} inte dricka {1}. '),
        Msg(cannot clean, '{Ref subj dobj} {är} inte något {jag} {kan} rengöra. '),
        Msg(already clean, '{Ref subj dobj} {är} redan tillräckligt ren. '),
        Msg(no clean, '{Ref subj dobj} behöver inte rengöras. '),
        Msg(dont need cleaning obj, '{Jag} behöver inte rengöra {ref dobj}. '),
        Msg(cannot clean with, '{Jag} {kan} inte rengöra {ref dobj} med {ref iobj}. '),
        Msg(cannot dig, '{Jag} {kan} inte gräva där. '),
        Msg(cannot dig with, '{Jag} {kan} inte gräva något med {detta iobj}. '),
        Msg(cannot dig with self, '{Jag} {kan} inte gräva {ref dobj} med {sig} själv{t/a}. '),
        Msg(not inside, '{Ref dobj} {är} inte {i iobj}. '),
        Msg(cannot take from self, '{Jag} {kan} inte ta {ref subj dobj} från {ref dobj}. '),
        Msg(cannot throw at, '{Jag} {kan} inte kasta något på {ref iobj}. '),
        Msg(cannot throw at self, '{Ref subj dobj} {kan} inte kastas på {sig} själv{t/a}. '),
        Msg(cannot throw to, '{Ref subj dobj} {kan} inte fånga något. '),
        Msg(cannot throw to self, '{Ref subj dobj} {kan} inte fånga {sig} själv{t/a}. '),
        Msg(throw falls short, '{Ref subj dobj} landar långt ifrån {ref iobj}. '),
        Msg(cannot turn to, '{Jag} {kan} inte vrida {detta dobj} till något. '),
        Msg(cannot set to, '{Jag} {kan} inte ställa in {detta dobj} till något. '),
        Msg(already there, '{Jag} {är} redan där. '),
        Msg(already present, '{Ref subj dobj} {är} redan här. '),
        Msg(cannot attach, '{Jag} {kan} inte fästa {ref dobj} till något. '),
        Msg(cannot attach to, '{Jag} {kan} inte fästa något till {ref iobj}. '),
        Msg(cannot attach to self, '{Jag} {kan} inte fästa {ref iobj} till {sig} själv{t/a}. '),
        Msg(cannot detach, 'Det f{i|a}nns inget från vilket {ref subj dobj} {kan} lossas. '),
        Msg(cannot detach from, 'Det f{i|a}nns inget som {kan} lossas från {ref iobj}. '),
        Msg(cannot detach from self, '{Ref subj dobj} {kan} inte lossas från {sig} själv{t/a}. '),
        Msg(cannot fasten, '{Ref subj dobj} {är} inte något {jag} {kan} fästa. '),
        Msg(already fastened, '{Ref subj dobj} {är} redan fäst. '),
        Msg(cannot fasten to, '{Jag} {kan} inte fästa något till {detta iobj}. '),
        Msg(cannot fasten to self, '{Ref subj iobj} {kan} inte fästas till {sig} själv{t/a}. '),
        Msg(cannot unfasten, '{Ref subj dobj} {kan} inte lossas. '),
        Msg(cannot unfasten from, '{Jag} {kan} inte lossa något från {detta iobj}. '),
        Msg(cannot unfasten from self, '{Jag} {kan} inte lossa {ref dobj} från {sig} själv{t/a}. '),
        Msg(not fastened, '{Ref subj dobj} {är} inte fäst. '),
        Msg(cannot plug, '{Ref subj dobj} {kan} inte kopplas in i något. '),
        Msg(cannot plug into self, '{Jag} {kan} inte koppla in {ref dobj} i {sig} själv{t/a}. '),
        Msg(cannot plug into, '{Jag} {kan} inte koppla in något i {ref iobj}. '),
        Msg(cannot unplug, '{Ref subj dobj} {kan} inte kopplas ur. '),
        Msg(cannot unplug from self, '{Jag} {kan} inte koppla ur {ref dobj} från {sig} själv{t/a}. '),
        Msg(cannot unplug from, '{Jag} {kan} inte koppla ur något från {ref iobj}. '),
        Msg(cannot kiss, '{Jag} {kan} verkligen inte kyssa {detta dobj}. '),
        Msg(cannot jump off, '{Jag} {är} inte på {ref dobj}. '),
        Msg(cannot jump over self, '{Jag} {kan} knappast hoppa över {sigsjälv dobj}. '),
        Msg(pointless to jump over, 'Det {är} meningslöst att hoppa över {ref dobj}. '),
        Msg(cannot set, '{Ref subj dobj} {är} inte något {jag} {kan} ställa in. '),
        Msg(cannot type on, '{Jag} {kan} inte skriva något på {ref dobj}. '),
        Msg(cannot enter on, '{Jag} {kan} inte ange något på {ref dobj}. '),
        Msg(cannot write on, '{Jag} {kan} inte skriva något på {ref dobj}. '),
        Msg(cannot consult, '{Ref subj dobj} {är} inte en informationskälla. '),
        Msg(cannot pour, '{Jag} {kan} inte hälla {1} någonstans. '),
        Msg(cannot pour on self, '{Jag} {kan} inte hälla {ref dobj} på {sigsjälv dobj}. '),
        Msg(cannot pour in self, '{Jag} {kan} inte hälla {ref dobj} i {sigsjälv dobj}. '),
        Msg(cannot pour into, '{Jag} {kan} inte hälla {1} i {ref iobj}. '),
        Msg(cannot pour onto, '{Jag} {kan} inte hälla {1} på {ref iobj}. '),
        Msg(should not pour into, 'Det {är} nog bäst att inte hälla {1} i {ref iobj}. '),
        Msg(should not pour onto, 'Det {är} nog bäst att inte hälla {1} på {ref iobj}. '),
        Msg(cannot screw, '{Jag} {kan} inte skruva {ref dobj}. '),
        Msg(cannot screw with, '{Jag} {kan} inte skruva något med {detta iobj}. '),
        Msg(cannot screw with self, '{Jag} {kan} inte skruva {ref iobj} med {sig} själv{t/a}. '),
        Msg(cannot unscrew, '{Jag} {kan} inte skruva loss {ref dobj}. '),
        Msg(cannot unscrew with, '{Jag} {kan} inte skruva loss något med {detta iobj}. '),
        Msg(cannot unscrew with self, '{Jag} {kan} inte skruva loss {ref iobj} med {sig} själv{t/a}. '),
        Msg(cannot push own container, '{Jag} {kan} inte trycka {ref dobj} medan {jag} {är} {1} {honom dobj}. '),
        Msg(cannot push via self, '{Jag} {kan} inte {1} {ref dobj} {2} {sigsjälv dobj}. '),
        Msg(cannot push travel, 'Det f{i|a}nns ingen mening med att försöka {1} {detta dobj} någonstans. '),
        Msg(cannot push through, '{Jag} {kan} inte {1} {ref dobj} genom {ref iobj}. '),
        Msg(cannot push into, '{Jag} {kan} inte {1} in något i {ref iobj}. '),
        Msg(cannot push up, '{Jag} {kan} inte {1} upp något i {ref dobj}. '),
        Msg(cannot push down, '{Jag} {kan} inte {1} ner något i {ref dobj}. '),
        Msg(cannot talk, 'Det f{i|a}nns ingen mening med att försöka prata med {ref cobj}. '),
        Msg(cannot talk to self, 'Att prata med {sig} själv {är} meningslöst. '),        
        Msg(already has, '{Ref subj iobj} {har} redan {ref dobj}. '), 
        Msg(cannot give to, '{Jag} {kan} inte ge något till {detta iobj}. '),
        Msg(cannot give to self, '{Jag} {kan} inte ge något till {sig} själv{t/a}. '),
        Msg(cannot show to, '{Jag} {kan} inte visa något för {detta iobj}. '),
        Msg(cannot show to self, '{Jag} {kan} inte visa något för {sig} själv{t/a}. '),
        Msg(not talking to anyone, '{Jag} pratar inte med någon. '),
        Msg(no longer talking to anyone, '{Jag} pratar inte längre med någon. '),
        Msg(cannot purloin self, '{Jag} {kan} inte stjäla {mig} själv. '),
        Msg(cannot purloin room, '{Jag} {kan} inte stjäla ett rum. '),
        Msg(cannot purloin container, '{Jag} {kan} inte stjäla en behållare. '),
        Msg(cannot go there, '{Jag} {kan} inte gå dit just nu. '),
        Msg(thoughts prefix, '{Jag} kommer ihåg '),
        Msg(fact intro, 'att'), // Användning: du kommer ihåg 'att' 
        Msg(no thoughts, '{Jag} har inga tankar om det specifika ämnet.'),
        Msg(told me that, ' berättade för {mig} '),
        Msg(knew fact already, ' (men det visste {jag} redan)'),
        Msg(consult prefix, '{Ref subj dobj} informera{r/de} {mig}'),
        Msg(no consult, '{Ref subj dobj} {har} ingenting användbart att tillföra i ämnet. '),
        Msg(no matched topic, '{Ref subj dobj} har inget att säga om det. '),
        Msg(cannot go, '{Jag} {kan} inte gå den vägen. ' ),
        Msg(cannot go in dark, 'Det {är} för mörkt för att se vart {jag} går. '),
        Msg(no thought comes to mind, '{Du} kommer inte på något. '),
        Msg(scripting okay web temp,  '<.parser>Transkriberingen kommer att sparas.
                                      Skriv <<aHref('skript av', 'SKRIPT AV','Stäng av skript')>>
                                     för att avbryta skriptet och ladda ner det sparade transkriptet.<./parser><.p> '),
        Msg(scripting okay,           '<.parser>Transkriberingen kommer att sparas i filen. Skriv <<aHref('skript av',
                                     'SKRIPT AV', 'Stäng av skript')>> för att avbryta transkriberingen.<./parser><.p> '),
        Msg(get recording prompt,    'Välj ett namn för den nya kommandologgfilen'),

        Msg(recording okay, '<.parser>Kommandon kommer nu att spelas in. Skriv
                            <<aHref('spela in av', 'SPELA IN AV', 'avsluta kommandoinspelning')>>
                            för att stoppa inspelningen av kommandon.<./parser><.p> '),
        Msg(get replay prompt, 'Välj kommandologgfil att spela upp'),
        Msg(get save prompt, 'Spara spel till fil'),
        Msg(get restore prompt, 'Återställ spel från fil'), 
        Msg(no need to refer, 'Det är inget du behöver hänvisa till.'),
        Msg(cannot go through closed door, '{Ref subj obj} {är} i vägen. '),
        Msg(traverse door, 'genom {1}'),
        Msg(traverse connector, '{1}'),
        Msg(north, 'norr'),
        Msg(depart north, 'till norr'),
        Msg(east, 'öster'),
        Msg(depart east, 'till öster'),
        Msg(south, 'söder'),
        Msg(depart south, 'till söder'),
        Msg(west, 'väster'),
        Msg(depart west, 'till väster'),
        Msg(northeast, 'nordost'),
        Msg(depart northeast, 'till nordost'),
        Msg(northwest, 'nordväst'),
        Msg(depart northwest, 'till nordväst'),
        Msg(southeast, 'sydost'),
        Msg(depart southeast, 'till sydost'),
        Msg(southwest, 'sydväst'),
        Msg(depart southwest, 'till sydväst'),
        Msg(down, 'ner'),
        Msg(depart down, 'ner'),
        Msg(up, 'upp'),
        Msg(depart up, 'upp'),
        Msg(in, 'in'),
        Msg(depart in, 'inuti'),
        Msg(out, 'ut'),
        Msg(depart out, 'ut'),
        Msg(port, 'babord'),
        Msg(depart port, 'till babord'),
        Msg(starboard, 'styrbord'),
        Msg(depart starboard, 'till styrbord'),
        Msg(forward, 'framåt'),
        Msg(depart forward, 'framåt'),
        Msg(aft, 'akterut'),
        Msg(depart aft, 'akterut'),
        Msg(no thought in mind, '{Jag} {har} inget att prata om just {nu|då}. '),
        Msg(enterable with door, '\^{1} {ser} {jag} {2} nåbar via {3}.'),         
        Msg(passage that way, '\^{1} {jag} {ser} {2}. '),
        Msg(ask connector options, '\^{1} {jag} {ser} {2}. '),
        Msg(room that way, '\^{1} {dummy}{ligger} {2}. '),
        Msg(could go that way, 'Det {dummy} {ser} ut som att {jag} möjligen kan ta mig den vägen. '),
        Msg(intro look dirdesc, '\^{1} {jag} {ser} '),
        Msg(nothing unexpected that way, '{Jag} {ser} inget oväntat åt det hållet. '),
        Msg(too dark to look that way, 'Det{dummy} {är} för mörkt för att kunna se något åt det hållet. '),
        Msg(doorway desc, 'En dörröppning är bara en vanlig dörröppning. '),
        Msg(passageway desc, 'En passage är bara en vanlig passage. '),
        Msg(pathway desc, 'En stig är bara en vanlig stig.'),
        Msg(archway desc, 'En valvport är bara en vanlig valvport.'),
        Msg(multi door, 'Mer än en dörröppning leder ut härifrån; du behöver säga åt vilket håll du vill gå.'),
        Msg(multi passage, 'Mer än en gång leder härifrån; du måste ange vilken väg du vill gå.'),
        Msg(multi path, 'Mer än en stig leder härifrån; du måste säga vilken väg du vill gå.'),
        Msg(multi arch, 'Mer än en valvgång leder ut härifrån; du måste säga åt vilket håll du vill gå.'),
        Msg(not in posture to travel,  '{Jag} behöv{er/de} vara {1} först. '),
        Msg(contradiction, '<.p>Det verkar finnas en viss motsägelse {här}.<.p>'),
        Msg(list and, ' och '),
        Msg(list tall prefix, '\n{Jag} {bär} på:\n '),
        Msg(list tall empty, '\n{Jag} {är} tomhänt. '),
        Msg(first score change, '<.p><.parser>Om du föredrar att inte få poängnotifikationer framöver, skriv NOTIFIERA AV.<./parser>'),
        Msg(cant see in from here, '{Jag} {kan} inte se in i {ref dobj} {här}ifrån.'),
        Msg(multi destination, 'Åt det hållet {plural}{ligger} {1}. '),
        Msg(no facts defined, 'Inga fakta har definierats i det här spelet.'),
        Msg(no such fact, '''Ingen fakta med namnet '<<literal>>' har definieras i spelet. '''),
        Msg(not out of subnested, '{Jag} behöv{er/de} vara {1} före {jag} {kan} ta {mig} {2}. '),
        Msg(not held, '{Jag} håller inte i {ref obj}. '),
        Msg(nothing more to discuss on that topic, '{Jag} {har} ingenting mer att diskutera i ämnet. '),
        Msg(non conv response, 'Det är bäst att jag håller mig fokuserad på konversationen.'),
        Msg(explain enumerating and hyperlinking, 'Uppräkning och/eller hyperlänkning av ämnesförslag kan 
                                                  slås på och av med kommandona ENUM SUGGS respektive HYPER SUGGS.'),
        Msg(no enumerations, 'Uppräknade förslag är inte tillgängliga just nu. '),
        Msg(enmeration out of range, 'För att välja ett uppräknat förslag, vänligen ange ett nummer mellan 1 och {1}.'),
        Msg(okay move from, '{Jag} flytta{r/de} bort {1} {dummy} från {ref iobj}. '),
        Msg(needs html terp, 'Denna feature kräver en HTML interpreter. '),
        Msg(inventory tall, 'Inventarielisting har nu satts till LÅNG'),
        Msg(no need to lookdir, '<.parser>Det {finns} ingen anledning att titta åt något specifikt håll {här}.<./parser>'),
        Msg(not a bird, '{Jag} {är} inte en fågel. '),
        Msg(consult about vague, 'Var mer specifik, t.ex. KONSULTERA SVART BOK OM MAGI eller LÄS OM MAGI I SVART BOK.'),
        Msg(doorway vocab, 'dörr|öppning+en;vanlig+a;dörr+en'),
        Msg(open doorway, 'Inget behov i det här fallet'),
        Msg(close doorway, 'Inget behov i det här fallet.'),
        Msg(door not important, 'There\'s no need to fiddle with such an ordinary door.'),
        Msg(passageway vocab, 'passageway;ordinary wide long short narrow straight;passage'),
        Msg(passage not important, 'There\'s no need to fiddle with such an ordinary passage. '),
        Msg(pathway vocab, 'pathway;ordinary narrow wide broad long short straight windy crooked;path'),
        Msg(path not important, 'There\'s no need to fiddle with such an ordinary path. '),
        Msg(archway vocab, 'archway;ordinary; large small big arch'),
        Msg(arch not important, 'There\'s no need to fiddle with such an ordinary archway. '),
        Msg(think about, 'tänka på '),
        Msg(too dark to read, 'Det är inte tillräckligt ljust {här} för att läsa {ref dobj}. '),
        Msg(look up, 'slå upp '),
        Msg(verbose consult prefix, 'konsultera ' + theName + ' om'),
        Msg(status line noexits, '<i>Inga</i>'),
        Msg(which do you mean, 'Vilken menar du'),
        Msg(cant climb from here, '{Jag} {kan} inte klättra upp för {ref dobj} {här}ifrån. '),
        Msg(cannot push climb here, '{Jag} {kan} inte gå upp för {ref iobj} {här}ifrån.'),
        Msg(cannot push climb down here, '{Jag} {kan} inte gå nerför {ref iobj} {här}ifrån.'),
        Msg(too far away to talk, '{Ref subj obj} {är} för långt borta för att prata med. '),
        Msg(cannot talk to obj, '{Jag} {kan} inte prata med {ref obj} just {nu}. '),
        Msg(cannot reach inside from, '{Jag} {kan} inte nå {1} från utsidan av {2}. '),
        Msg(cannot talk basicactor, '{Ref subj cobj} {verkar} inte intresserad. '),

        Msg(okay push into, '{Jag} <<if matchPullOnly>> drar {ref dobj} {1} {2}. '),
        Msg(okay push into, '{Jag} <<if matchPullOnly>>dr{ar|og} <<else>>tryck{er|te}<<end>> in {ref dobj} i {ref iobj}. '),
        Msg(okay push out of, '{Jag} <<if matchPullOnly>>dr{ar|og} <<else>>tryck{er|te}<<end>> ut {ref dobj} ur {ref iobj}. '),



        // TODO: these needs a unique ID each to work, but the lib resuses the same ID so it cannot be fixed right now
        Msg(tips on, 'Tips are now on. '),
        Msg(tips off, 'Tips are now off. '),
        Msg(disambig enum on, 'Enumeration of disambiguation choices is now on. '),
        Msg(disambig enum off, 'Enumeration of disambiguation choices is now off. '),
        Msg(brief goto, 'Goto mode is now brief (no room descriptions or stopping to CONTINUE)'),
        Msg(brief goto, 'Goto mode is now fast (no stopping to CONTINUE)'),
        Msg(brief goto, 'Goto mode is now normal (explicit CONTINUE needed for each step)'),

        // TODO: keep track of when this wrong-spelling gets corrected in the main lib
        Msg(cant climb doen from here,  '{Jag} {kan} inte klättra ner för {ref dobj} {här}ifrån. '),
        Msg(alreadt attached to iobj, '{The subj dobj} {is} already attachd to {1}. '),



        // Overriden in swe_mods / swe_messages
        //Msg(report left behind, 'När {1}{dummy} {flyttas} synlig{gör}s {2} tidigare dold bakom {3}. '),
        //Msg(report left behind, '<<if moveReport == ''>>När {1}{dummy} {flyttas} {lämnas} {2} kvar. <<else>>Även <<end>>{dummy}{2} {lämnas} kvar. '),
        //Msg(report left under, 'När {1}{dummy} {flyttas} synlig{gör}s {2} tidigare dold bakom {3}. '),

        // TODO: test
        //Msg(actor arriving from dir, '{Ref subj traveler} anländ{er/e} från <<dir.arrivalName>>. '),
        //Msg(actor arriving from dir, '{Ref subj traveler} anländ{er/e} från .  '),

        // Msg(actor arriving, '{Ref subj traveler} anländer till området. '),
        // Msg(actor in location, '\^<<theNameIs>> <<postureDesc>> <<location.objInName>>. ');        		

        // Msg(exit lister dest name, ' till <<obj.dest_.destName>>'),
        // Msg(reject spaction input, 'Jag <i>verkligen</i> vägrar att förstå {det} kommandot. ');
        
        // TODO: needs override beacuse of <<...>>:
        // Msg(acknowledge notify status, '<.parser>Poängnotifikationer är nu <<stat ? 'på' : 'av'>>.<./parser> '),
        // Msg(doubt fact, ' (though {i} now regard{s/ed} that as <<str(beliefVal)>>)'),
        // Msg(default pcsayquip, '<q><<gTopicText.substr(1,1).toUpper()>><<gTopicText.substr(2).toLower()>>,</q> {i} {say}. '),
        // Msg(toggle suggestion enum, 'Uppräkning av ämnesförslag är nu <b><<suggestedTopicLister.enumerateSuggestions ? 'påslaget' : 'avstängt'>></b>.<.p>'),
        // Msg(cant do that special, '{I} {can\'t} <<svPhrase>> {that dobj}. '),
        // Msg(input script okay, '<.parser>Läser kommandon från <q><< File.getRootName(fname).htmlify()>></q>...<./parser>\n '),
        // Msg(save failed on server, '<.parser>Misslyckades, på grund av ett problem med att komma åt lagringsservern: <<makeSentence(sse.errMsg)>><./parser>'),
        // Msg(restore failed on server,'<.parser>Misslyckades, på grund av ett problem med att komma åt lagringsservern: <<makeSentence(sse.errMsg)>><./parser>'), 
        // Msg(file prompt failed msg, '<.parser>Misslyckades: <<makeSentence(msg)>><./parser> '),
        // Msg(show notify status, '<.parser>Poängnotifikationer är för närvarande <<stat ? 'på' : 'av'>>.<./parser> '),
        // Msg(extra hints status, 'Extra ledtrådar är för närvarande <<onOrOff(extraHintsActive)>>. För att stänga av dem <<onOrOff(!extraHintsActive)>> använd kommandot <<aHref(cmdstr, cmdstr, 'Stäng av extra ledtrådar ' + onOrOff(!extraHintsActive))>>. '),
        // Msg(actor here, '\^<<theNameIs>> <<postureDesc>> {here}. ');
        // Msg(actor in location, '\^<<theNameIs>> <<location.objInName>>. '), 		
        // Msg(actor in location, '\^<<theNameIs>> <<postureDesc>> <<location.objInName>>. '), 
        // Msg(actor in remote location, '\^<<theNameIs>> <<getOutermostRoom.inRoomName(pov)>>. '),
        // Msg(actor nested location name, ' (<<actor.location.objInPrep>> <<actor.location.theName>>)'),
        // Msg(exits on off okay, 'Okej. Utgångslistning i statusraden är nu <<stat ? 'PÅ' : 'AV'>>, medan utgångslistning i rumsbeskrivningar är nu <<look ? 'PÅ' : 'AV'>>. '),        
        // Msg(current exit settings, 'Utgångar listas <<if(inStatusLine && inRoomDesc)>> både i statusraden och i rumsbeskrivningar. <<else if(inStatusLine && !inRoomDesc)>> endast i statusraden. <<else if(!inStatusLine && inRoomDesc)>> endast i rumsbeskrivningar. <<else if(!inStatusLine && !inRoomDesc)>> varken i statusraden eller i rumsbeskrivningar. <<end>>'),
        // Msg(time fuse interval error, 'Felaktigt intervall <<interval>> angivet till TimeFuse-konstruktorn. '),
        // Msg(extra hint cmd str, '<<aHref('EXTRA ' + stat, 'EXTRA ' + stat, 'Slår på extra ledtrådar ' + stat.toLower)>>'),
        // Msg(not in staging location, '{Jag} måste vara <<if stagingLoc.ofKind(Room)>> direkt <<end>> {i stagingloc} för att göra det. '),
        // Msg(basic score change, '''Din <<aHref('full score', 'poäng', 'Visa fullständig poäng')>> har just <<delta > 0 ? 'ökat' : 'minskat'>> med <<spellNumber(delta > 0 ? delta : -delta)>> poäng<<delta is in (1, -1) ? '' : 's'>>.'''),
        // Msg(show score, 'På {1} drag<<turns == 1 ? '' : 's'>> har du fått {2} av totalt {3} poäng<<maxPoints == 1 ? '' : 's'>>. '),
        // Msg(show score no max, 'På {1} drag<<turns == 1 ? '' : 's'>> har du fått {2} poäng<<points == 1 ? '' : 's'>>. '),
        // Msg(find hidden, '\^{1} {ref dobj} {jag} hitta{r|de} {2}<<if findHiddenDest == gActor>>, som {jag} tar<<end>>. '),
        // Msg(actor nested location posture name, ' (<<actor.posture.participle>> <<actor.location.objInPrep>> <<actor.location.theName>>)'),
        // Msg(illegal actor state, '<FONT COLOR=RED><b>VARNING!</b></FONT> I anropet till setState(stat) på Actor <<theName>>, var stat <<stat>> inte en ActorState som tillhörde <<theName>>.'),
        // Msg(set stance error, '<FONT color=red><b>VARNING</b></FONT>: i setStanceToward(<<actor>>, <<stance_>>) är inte <<actor>> en Actor och/eller <<stance_>> inte en Stance.'),
        // Msg(set mood error, '<FONT color=red><b>VARNING!</b></FONT>: i setMood(<<mood_>>), är <<mood_>> inte ett Mood.'),
        // Msg(duplicate fact name, 'FEL! Försökte skapa duplicerat fakta med namnet \'<<namn_>>\'.'),
        // Msg(short notify status, 'NOTIFY <<isOn ? 'PÅ' : 'AV'>>'),
        // Msg(bad agenda item, '<FONT COLOR=RED><b>VARNING!</b></FONT>: försök att lägga till något i agendan för <<getActor.theName>> som inte är en AgendaItem som tillhör denna Actor.'),



        // TODO: testa actorOutOfSubNested.checkPreCondition(obj, allowImplicit)
        //  ORG: DMsg(not out of subnested, '{I} need{s/ed} to be {1} before {i} {can} get {2}. ',loc.objOutOfName, obj.objOutOfName);
        // Msg(fiat lux, '{Jag} {blir} plötsligt {1} lysande. '), // TODO: fixa, (vad behöver fixas?)


        // TODO: svenska till denna svengelska tillsammans med det som står i grammar.t
        Msg(explain goto options,
            '<.p><.parser>För att aktivera snabb GÅ TILL utan FORTSÄTT, använd GÅ TILL LÄGE SNABB eller 
            GÅ TILL KORT (det senare undertrycker rumsbeskrivningarna för rummen längs vägen). 
            För att återuppta användningen av FORTSÄTT, använd GÅ TILL LÄGE FORTSÄTT. Alla lägesändringar
            träder i kraft vid nästa GÅ TILL-kommando.<./parser> '
            )

    ]
;


// TODO: These modifications will go away when the library is fixed

modify explicitExitLister
    showListItem(obj, options, pov, infoTab)
    {               
        htmlSay('<<aHref(obj.dir_.name, obj.dir_.name, 'Gå ' + obj.dir_.name, 0)>>');    
        if(showDestNames && obj.dest_ && (obj.dest_.visited || obj.dest_.familiar))
            DMsg(exit lister dest name, ' till <<obj.dest_.destName>>'); // eller 'mot'
        
    }   
;

modify Action
    acknowledgeNotifyStatus(stat) {
        DMsg(acknowledge notify status, '<.notification>Score notifications are now
        <<stat ? 'on' : 'off'>>.<./notification> ');
    }
;

modify FactHelper
    doubtFactMsg(beliefVal) {
        return BMsg(doubt fact, ' (though {i} now regard{s/ed} that as
            <<str(beliefVal)>>)');
    }
;

modify Actor
    pcDefaultSayQuip = //BMsg(default pcsayquip,  
        bmsg('<q><<gTopicText.substr(1,1).toUpper()>><<gTopicText.substr(2).toLower()>>,</q> {säger} {jag}. ')   

    postureDesc = 'är' // Detta överrids när posture-extensionen används
    
    actorSpecialDesc() {
        if(isPlayerChar) {
            return;
        }
        local descName = proper ? theName : aName;

        if(location == getOutermostRoom)
            dmsg('\^<<descName>> <<postureDesc>> {här|där}. ');
        else
            dmsg('\^<<descName>> <<postureDesc>> <<location.objInName>>. ');
    }

    sayActorArriving(fromLoc)
    {
        local traveler = self;
        gMessageParams(traveler);
        local dir = getOutermostRoom.getDirectionTo(fromLoc);              
        if(dir) {
            //DMsg(actor arriving from dir,
            dmsg('{Ref subj traveler} {anländer} från <<dir.arrivalName>>. ');
        } else {
            //DMsg(actor arriving, 
            dmsg('{Ref subj traveler} {anländer} till platsen. ');
        }
    }

    // TODO: testa av, borde fungera som den är utan override
    actorRemoteSpecialDesc(pov) 
    { 
        if(fDaemon == nil) {
            //dmsg('\^<<theNameIs>> <<if location != getOutermostRoom>><<location.remoteObjInName(pov)>> <<end>> <<getOutermostRoom.inRoomName(pov)>>. ');
            //"\^<<theNameIs>> <<location.remoteObjInName(pov)>> <<getOutermostRoom.inRoomName(pov)>>. ";
            //"\^<<theNameIs>> <<getOutermostRoom.inRoomName(pov)>>. ";
            if(location != getOutermostRoom) {
                dmsg('\^<<theNameIs>> <<location.remoteObjInName(pov)>> <<getOutermostRoom.inRoomName(pov)>>. ');
            } else {
                dmsg('\^<<theNameIs>> <<getOutermostRoom.inRoomName(pov)>>. ');
            }
        }
    }
    // TODO: samma med
    //statusName(actor)
    
;

modify EnumerateSuggestions
    execAction(cmd) {
        if(defined(suggestedTopicLister)) {
            suggestedTopicLister.enumerateSuggestions = !suggestedTopicLister.enumerateSuggestions;
            
            //DMsg(toggle suggestion enum, 
            dmsg('Uppräkning av ämnesförslag är nu <b><<suggestedTopicLister.enumerateSuggestions ? 'påslaget' : 'avstängt'>></b>.<.p>');
        }
    }
;


modify SpecialVerb
    showFailureMsg(svPhrase) {
        DMsg(cant do that special, '{Jag} {kaninte} <<svPhrase>> {det dobj}. ');
    }
;    

// TODO: too much overriding
modify Thing 
    revealOnMove()
    {
        local moveReport = '';
        local underLoc = location;
        local behindLoc = location;
        
        /* 
         *   If I don't want to leave items under me behind when I'm moved, and
         *   I am or have an underside, change the location to move items hidden
         *   under me to accordingly.
         */
        if(contType == Under && dropItemsUnder == nil)
            underLoc = self;
        else if(remapUnder != nil && dropItemsUnder == nil)
            underLoc = remapUnder;
        
         /* 
          *   If I don't want to leave items behind me behind when I'm moved,
          *   and I am or have a RearContainer, change the location to move
          *   items hidden under me to accordingly.
          */
        if(contType == Behind && dropItemsBehind == nil)
            behindLoc = self;
        else if(remapBehind != nil && dropItemsBehind == nil)
            behindLoc = remapBehind;
        
        
        /* 
         *   If anything is hidden under us, add a report saying that it's just
         *   been revealed moved and then move the previously hidden items to
         *   our location.
         */
        if(hiddenUnder.length > 0)
        {
            moveReport += bmsg(
                //report left under, 
                 'När {1}{dummy} {flyttas} synlig{gör}s {2} tidigare dold under {3}. ',
                 theName, makeListStr(hiddenUnder), himName);
                //BMsg(reveal move under,'Moving {1} {dummy} reveal{s/ed} {2}
                //    previously hidden under {3}. ',
                //     theName, makeListStr(hiddenUnder), himName);
                     
            moveHidden(&hiddenUnder, underLoc);
            
        }
        
        
        /* 
         *   If anything is hidden behind us, add a report saying that's just
         *   been revealed and then move the previously hidden items to our
         *   location.
         */
        if(hiddenBehind.length > 0)
        {
            moveReport += bmsg(//report left behind, 
                    'När {1}{dummy} {flyttas} synlig{gör}s {2} tidigare dold bakom {3}. ',
                     theName, makeListStr(hiddenBehind), himName);            
                //BMsg(reveal move behind,'Moving {1} {dummy} reveal{s/ed} {2}
                //    previously hidden behind {3}. ',
                //    theName, makeListStr(hiddenBehind), himName);
                        
            moveHidden(&hiddenBehind, behindLoc);            
        }
        
        /* 
         *   Construct a list of anything left behind from under or behind us
         *   when we're moved.
         */
        local lst = [];
        
        if(dropItemsUnder)
        {
            if(contType == Under)
                lst = contents;
            else if(remapUnder)
                lst = remapUnder.contents;                    
        }
               
        if(dropItemsBehind)
        {
            if(contType == Behind)
                lst += contents;
            else if(remapBehind)
                lst += remapBehind.contents;           
        }
        
        lst = lst.subset({o: !o.isFixed});
        
        if(lst.length > 0)
        {
            foreach(local cur in lst)
                cur.moveInto(location);                
         
            moveReport +=
                //BMsg(report left behind, '<<if moveReport == ''>>Moving {1}
                //    <<else>>It also <<end>> {dummy} {leaves} {2} behind. ',
                //     theName, makeListStr(lst));

                bmsg(//report left behind, 
                '<<if moveReport == ''>>När {1}{dummy} {flyttas} {lämnas} {2} kvar. <<else>>Även <<end>>{dummy}{2} {lämnas} kvar. ',
                    theName, makeListStr(lst));

        }
        
        
        /* 
         *   If anything has been reported as being revealed, report the
         *   discovery after reporting the action that caused it.
         */
        if(moveReport != '' )
            reportAfter(moveReport);
    }

    sayFindHidden(prop, prep)
    {
        // TODO: testa av meddelandet 
        dmsg('\^{1} {ref dobj} hitta{r|de} {jag} {2}<<if findHiddenDest == 
            gActor>>, som {jag} tar<<end>>. ', 
            prep.prep, makeListStr(self.(prop)));

    }
;

modify actorInStagingLocation
    checkPreCondition(obj, allowImplicit)
    {
        local loc = gActor.location;
        local stagingLoc = obj.stagingLocation;
        local action;
        
        /* If the actor's location is the staging location then we're done. */
        if(loc == stagingLoc)
            return true;
        
        if(stagingLoc == nil) {
            gMessageParams(obj);
            //DMsg(no staging loc, 
            dmsg('{Ref subj obj} {kaninte} nås. ');
            return nil;
        }
        
        if(allowImplicit) {
            local tried = nil;
            while(!stagingLoc.isOrIsIn(loc)) {
                action = loc.contType == In ? GetOutOf : GetOff;
                tried = tryImplicitAction(action, loc);
                if(gActor.location == loc)
                    break;
                
                loc = gActor.location;
            }
                                  
            if(stagingLoc == loc) return true;
            
            local path = [];
            local step = stagingLoc;
            
            while(step && step != loc) {
                path = [step] + path;
                step = step.stagingLocation;
            }
            
            foreach(step in path) {
                action = step.contType == In ? Enter : Board;
                tried = tryImplicitAction(action, step);                
                if(gActor.location != step)
                    break;
            }
            if(stagingLoc == gActor.location) return true;        
            if(tried) return nil;
        }
        gMessageParams(stagingLoc);
        //DMsg(not in staging location,
        dmsg('{Jag} måste vara <<if stagingLoc.ofKind(Room)>>direkt<<end>> {i stagingloc} för att göra det. ');

        return nil;          
    }    
;

modify scoreNotifier
    firstScoreChange(delta) {
        scoreChange(delta);
        //DMsg(first score change, 
        dmsg('<.p><.parser>Om du föredrar att inte få poängnotifikationer framöver, skriv NOTIFIERA AV.<./parser>');
    }

    basicScoreChange(delta) {
        cquoteOutputFilter.deactivate();
        //DMsg(basic score change,         
        dmsg('''Din <<aHref('full score', 'poäng', 
                        'Visa fullständig poäng')>> 
        har just <<delta > 0 ? 'ökat' : 'minskat'>> med 
        <<spellNumber(delta > 0 ? delta : -delta)>> 
        poäng<<delta is in (1, -1) ? '' : 's'>>.''');
        cquoteOutputFilter.activate();
    }
;

modify libScore
    showScoreMessage(points, maxPoints, turns) {
        //DMsg(show score,
        dmsg('På {1} drag<<turns == 1 ? '' : 's'>> har du fått 
            {2} av totalt {3} poäng<<maxPoints == 1 ? '' : 's'>>. ',
            turns, points, maxPoints);
    }
    showScoreNoMaxMessage(points, turns) {
        //DMsg(show score no max, 
        dmsg('På {1} drag<<turns == 1 ? '' : 's'>> har du fått 
            {2} poäng<<points == 1 ? '' : 's'>>. ',
             turns, points);        
    }
;
/*
// TODO: behöver kanske inte inte överridas på det här viset.
//       Testa av först

modify Room
    statusName(actor)
    {
        local nestedLoc = '';
        if(!actor.location.ofKind(Room))
            nestedLoc = 
        BMsg(actor nested location name,  ' (<<actor.location.objInPrep>> <<actor.location.theName>>)');        
        if(isIlluminated) {
            "<<roomTitle>><<nestedLoc>>";
        } else {
            "<<darkName>><<nestedLoc>>";            
        }
    }
;
*/

// TODO: testa av, bör inte behöva ändras, används bara i postures/swe_postures+extensionen:
// Msg(actor nested location posture name, ' (<<actor.posture.participle>> <<actor.location.objInPrep>> <<actor.location.theName>>)'),


// Msg(show notify status, '<.parser>Poängnotifikationer är för närvarande <<stat ? 'på' : 'av'>>.<./parser> '),
// Msg(extra hints status, 'Extra ledtrådar är för närvarande <<onOrOff(extraHintsActive)>>. För att stänga av dem <<onOrOff(!extraHintsActive)>> använd kommandot <<aHref(cmdstr, cmdstr, 'Stäng av extra ledtrådar ' + onOrOff(!extraHintsActive))>>. '),
// Msg(exits on off okay, 'Okej. Utgångslistning i statusraden är nu <<stat ? 'PÅ' : 'AV'>>, medan utgångslistning i rumsbeskrivningar är nu <<look ? 'PÅ' : 'AV'>>. '),        
// Msg(current exit settings, 'Utgångar listas <<if(inStatusLine && inRoomDesc)>> både i statusraden och i rumsbeskrivningar. <<else if(inStatusLine && !inRoomDesc)>> endast i statusraden. <<else if(!inStatusLine && inRoomDesc)>> endast i rumsbeskrivningar. <<else if(!inStatusLine && !inRoomDesc)>> varken i statusraden eller i rumsbeskrivningar. <<end>>'),
// Msg(time fuse interval error, 'Felaktigt intervall <<interval>> angivet till TimeFuse-konstruktorn. '),
// Msg(extra hint cmd str, '<<aHref('EXTRA ' + stat, 'EXTRA ' + stat, 'Slår på extra ledtrådar ' + stat.toLower)>>'),        
// Msg(illegal actor state, '<FONT COLOR=RED><b>VARNING!</b></FONT> I anropet till setState(stat) på Actor <<theName>>, var stat <<stat>> inte en ActorState som tillhörde <<theName>>.'),
// Msg(set stance error, '<FONT color=red><b>VARNING</b></FONT>: i setStanceToward(<<actor>>, <<stance_>>) är inte <<actor>> en Actor och/eller <<stance_>> inte en Stance.'),
// Msg(set mood error, '<FONT color=red><b>VARNING!</b></FONT>: i setMood(<<mood_>>), är <<mood_>> inte ett Mood.'),
// Msg(duplicate fact name, 'FEL! Försökte skapa duplicerat fakta med namnet \'<<namn_>>\'.'),
// Msg(short notify status, 'NOTIFY <<isOn ? 'PÅ' : 'AV'>>'),
// Msg(bad agenda item, '<FONT COLOR=RED><b>VARNING!</b></FONT>: försök att lägga till något i agendan för <<getActor.theName>> som inte är en AgendaItem som tillhör denna Actor.'),


