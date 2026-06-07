#charset "utf-8"
#include <tads.h>
#include "advlite.h"

/*
 *  Stugan - exempelspel för det svenska adv3Lite-biblioteket.
 *
 *  Grammatisk kongruens visas för:
 *    utrum   - en nyckel, en stol, en korg, en katt
 *    neutrum - ett bord, ett brev, ett fönster, ett äpple
 *    plural  - stövlarna, böckerna, blommorna
 *    ägande  - din näsa, dina händer (ownerNamed + owner)
*/

versionInfo: GameID
	IFID = 'af4b0905-a899-4ede-8c5b-b5012aa1e5bf'
	name = 'Stugan'
	byline = 'av Tomas Öberg'
	htmlByline = 'av <a href="mailto:tomaserikoberg@gmail.com">Tomas Öberg</a>'
	version = '1'
	authorEmail = 'Tomas Öberg tomaserikoberg@gmail.com'
	desc = 'Ett kort exempelspel för det svenska adv3Lite-biblioteket.'
	htmlDesc = 'Ett kort exempelspel för det svenska adv3Lite-biblioteket.'
;

gameMain: GameMainDef
	initialPlayerChar = me
	showIntro()
	{
		"<b>Stugan</b>\n\n
		Du vet inte hur länge du stått framför den gamla stugan. Du
		vet inte riktigt hur du kom hit. Men på köksbordet, som om det
		väntat på dig, ligger ett brev, adresserat till dig, i en
		handstil du inte känner igen.\n ";
	}
;

modify bodyParts
    initialLocationClass = nil
;

// -----------------------------------------------------------------------
// Testskript
// -----------------------------------------------------------------------

Test 'nyckel' [
'x brev', 'läs brevet', 'ta nyckeln',
'lås upp dörren med nyckeln', 'öppna dörren', 'n',
'hälsa på katt', 'tag allt', 'prata med katten'
];

Test 'grammatik' [
'x bordet', 'x fönstret', 'x stövlarna', 'x böckerna',
'x äpplet', 'x blommorna', 'ta på stövlarna', 'inv'
];

Test 'ägande' [
'x din näsa', 'x dina händer', 'x nyckeln', 'ta nyckeln', 'x din nyckel'
];


// -----------------------------------------------------------------------
// KÖKET - startrum
// -----------------------------------------------------------------------

koket: Room 'Köket'
	"Köket är litet och dammigt. Blommönstrade gardiner hänger skeva
	för ett litet fönster ovanför diskbänken. I mitten av rummet
	står ett gammalt bord. En dörr i norr leder ut mot trädgården;
	en öppen passage i väster leder till vardagsrummet. "
	north = tradgardsDorren
	out asExit(north)
	west = vardagsrummet
;

// Spelaren - andra person, stående
+ me: Actor 'du'
	person = 2
	posture = standing
;

// Kropp - visar ägande-grammatik: "din näsa", "dina händer"
++ nasa: Component 'näsa+n'
	"En alldeles vanlig näsa."
	ownerNamed = true
	owner = [me]
;

++ hander: Component 'händer+na[pl];;;dem'
	"Dina händer ser lite dammiga ut efter resan."
	plural = true
	ownerNamed = true
	owner = [me]
;

// Bordet - neutrum (ett bord)
+ matbord: Surface, Heavy 'bord+et'
	"Ett gammalt ekbord med en söndernött yta. Någon har ristat
	märken i träet - symboler du inte kan tolka. "
	isNeuter = true
;

// Brevet - neutrum (ett brev), fast, läsbart
++ brev: Thing 'brev+et'
	"Ett vikt brev med din adress skrivet i en handstil du inte
	känner igen."
	isFixed = true
	isNeuter = true
	isReadable = true
	readDesc =
	"\"Du vet varför du är här.\b
	Nyckeln till trädgårdsdörren ligger på bordet. Gå ut när
	du är redo.\" "
;

// Nyckeln - utrum (en nyckel), öppnar trädgårdsdörren
++ nyckel: Key 'nyckel+n'
	"En gammal järnnyckel med ett rött garnband runt ringen."
	actualLockList = [tradgardsDorren]
;
+++ garnband: Decoration, Component  'garn+band+et';

// Stolen - utrum (en stol), kan sitta på
+ stol: Chair, Heavy 'stol+en'
	"En gammal trästol med en välsliten sits och ryggstöd
	dekorerat med ett enkelt snideri. "
	canSitInMe = true
	cannotTakeMsg = 'Stolen är lite tung att bära omkring på.'
;

// Stövlarna - plural (stövlarna), bärbara
+ stovlar: Wearable 'stövlar+na[pl];;stövel:n+par+et;det dem'
	"Ett par grönbruna gummistövlar, perfekta för trädgården."
	plural = true
	name = 'par stövlar'
	definiteForm = 'stövelparet'
;


// Trädgårdsdörren - utrum, låst, länkad till sin motstycke
+ tradgardsDorren: Door 'trädgårds|dörr+en'
	"En kraftig trädörr med ett gammaldags järnhandtag. <<isLocked ? 'Den är låst.' : 'Den är olåst.'>>"
	otherSide = tradgardsDorrenInifran
	lockability = lockableWithKey
	isLocked = true
	//keyList = [nyckel]
;

// -----------------------------------------------------------------------
// VARDAGSRUMMET
// -----------------------------------------------------------------------

vardagsrummet: Room 'Vardagsrummet'
	"Vardagsrummet är mörkt och doftar av gammal ved och något annat
	som du inte kan sätta fingret på. En stor öppen spis
	dominerar västväggen; askan i eldstaden ser inte gammal ut.
	Längs ena sidan reser sig en fullpackad bokhylla. Ett fönster
	vetter mot trädgården. Köket ligger österut. "
	east = koket
	down = golvlucka
;

+matta: Surface  'matta+n';

+golvlucka: DSDoor  'golv|lucka+n' @vardagsrummet @kallaren
//	lookListed = true
;

// Soffan - utrum (en soffa), kan sitta och ligga i
+ soffa: Bed, Heavy 'soffa+n'
	"En djup soffa i mörkrött tyg. En grop i kudden antyder att
	någon suttit här nyligen."
	canSitInMe = true
	canLieInMe = true
	lookListed = true
;

// Bokhyllan - utrum (en bokhylla), fast, innehåller böcker
+ bokhylla: Fixture 'bok|hylla+n'
	"En hög bokhylla av mörknat trä. Hyllorna buktar under tyngden
	av böcker i alla storlekar och åldrar."
;

// Böckerna - plural (böckerna), fast
++ bocker: Fixture 'böcker+na[pl];;;dem'
	"Gamla böcker i skiftande storlekar och färger. Flera saknar
	ryggtitlar. En del verkar handskrivna, på ett språk du inte
	känner igen."
	plural = true
;

// Fönstret - neutrum (ett fönster), fast
+ fonster: Fixture 'fönst:er+ret'
	"Genom fönstret ser du trädgården, lysande i eftermiddagssolen.
	Äppelträdet skymtar bakom några buskar. "
	isNeuter = true
;

kallaren: Room  'Källaren' "..."
	up = golvlucka
;

// -----------------------------------------------------------------------
// TRÄDGÅRDEN
// -----------------------------------------------------------------------

tradgarden: Room 'Trädgården'
	"Trädgården är halvt övervuxen. Det som en gång kanske var
	välskötta rabatter har vuxit ihop till täta snår. Mitt i
	trädgården reser sig ett gammalt äppelträd med tyngda grenar.
	Stugans dörr är söderut. "
	south = tradgardsDorrenInifran
	in asExit(south)
;

// Dörren inifrån - motstycke till kökets dörr
+ tradgardsDorrenInifran: Door 'trädgårds|dörr+en'
	otherSide = tradgardsDorren
	lockability = lockableWithKey
	isLocked = true
;

// Äppelträdet - neutrum (ett äppelträd), fast, behållare för äpple
+ appeltrad: Fixture 'äppel|träd+et'
	"Ett gammalt och kraftigt äppelträd. Grenarna hänger tunga av
	mörkröda äpplen som ingen verkar ha plockat på länge. "
	contType = In
	isNeuter = true
;

// Äpplet - neutrum (ett äpple), mat, kan ätas
++ apple: Food 'äpple+t'
	"Ett mörkt rött äpple, alldeles moget."
	isNeuter = true
	tasteDesc = "Det smakar sött, med en besk eftersmak du inte
	riktigt kan identifiera."
;

// Blommorna - plural (blommorna), fast
+ blommor: Fixture 'blommor+na[pl];;;dem'
	"Vilda blommor i mörka, tunga färger som tränger upp genom
	ogräset. Inga bin."
	plural = true
;

// Korgen - utrum (en korg)
+ korg: Container 'korg+en'
	"En flätad korg av björkris, svart inuti av år och fukt. "
;

// Katten - utrum (en katt), NPC
+ katt: Actor 'katt+en'
	"En grå randig katt som solar sig på trappstenen med slutna ögon.
	Den rör sig inte men du är inte helt säker på att den sover för det. "
	proper = nil
	posture = lying
;

+kattleksak: Thing 'rått|leksak+en;;råtta+n katt|leksak+en'
	ownerNamed = true
	owner = [katt]
;
