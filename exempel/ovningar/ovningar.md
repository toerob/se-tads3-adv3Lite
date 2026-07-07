# Övningar & exempel

Learning TADS 3 With Adv3Lite innehåller ett antal övningar. 
Förslag på lösningar till några av dessa övningar ges
här. Dessa kan antingen användas tillsammans med övningarna eller
helt enkelt studeras separat som exempel på kod som illustrerar olika delar
av adv3Lite-biblioteket.

## Länkar till .t-källfilerna

De exempelspel som tillhandahålls är följande:

[Övning 11](ovning11/ovning11.t) är främst en illustration av Rooms,
TravelConnectors och TravelBarriers. Den innehåller också ett exempel på
ett fordon och ett res-skjutbart föremål.

[Övning 13](ovning13/ovning13.t) är främst en illustration av olika
sorters Container. Den illustrerar också vissa aspekter av händelsehantering
och av att definiera nya handlingar under arbetet med att implementera
saker med de olika sorternas behållare.

[Övning 15 - Bombröjning](ovning15/ovning15.t) är främst en
illustration av Fuses och Daemons. Den illustrerar också hur ett spel
startas och avslutas, samt användningen av InitObjects, CollectiveGroups,
Consultables och mer händelsehantering.

[Övning 17 - Ljuskällor](ovning17/ovning17.t) är främst en
demonstration av olika sorters ljuskällor. Observera att även om den visar
hur man skapar en bränsledriven ljuskälla från grunden, kan det i praktiken
vara enklare att använda tillägget [fueled light
source](../../extensions/docs/fueled.htm). Detta exempel illustrerar också
hur man modifierar VerbRules (grammatiken som gäller för olika handlingar)
och hur man definierar ett AMUSING-alternativ.

[Övning 18 - Bedsitterland](ovning18/ovning18.t) är främst en
illustration av nästlade rum (såsom Platforms och Booths), inklusive hur
man begränsar möjligheten att nå in i och ut ur dem.

[Övning 19 - Lås och prylar](ovning19/ovning19.t) är främst en
illustration av Lockable-föremål, nycklar, samt olika typer av prylar och
reglage såsom rattar, spakar, strömbrytare och skjutreglage. Den
innehåller också ytterligare ett exempel på hur man implementerar ett
AMUSING-alternativ.

[Övning 20 - Fyren](ovning20/ovning20.t) är främst en illustration av
hur man implementerar NPC:er (icke-spelarkaraktärer), inklusive
konversation och användningen av ActorStates och AgendaItems.

[Övning 21 - Förnuft och känsla](ovning21/ovning21.t) är främst en
illustration av SenseRegions och de sinnesförbindelser de tillhandahåller.
Den illustrerar också användningen av MultiLocs, Noises och Odors, samt en
enkel NPC och ytterligare ett res-skjutbart föremål. Den visar hur man
skapar en SoundEvent-klass från grunden, men i praktiken kan detta göras
enklare genom att använda tillägget [Sensory](../../extensions/docs/fueled.htm).

[Övning 22 - Fästen](ovning22/ovning22.t) är främst en illustration av
olika sorters Attachable-klasser, om än i sammanhanget av vad som
förmodligen är det mest komplexa spelet av alla exemplen här.

[Övning 23 - En händelserik promenad](ovning23/ovning23.t) är främst en
illustration av EventLists, menyer, ledtrådar och poängsättning, även om
den också innehåller ett par exempel på enkla scener.
:::
