#charset "utf-8"
#include "advlite.h"

// Ger name='himmel' definiteForm = 'himlen', samt 'himle' och 'himmelen'
modify defaultSky vocab = 'him:mel+len;;him:le+melen';

modify DefaultWall vocab = 'vägg+en;;väggar+na[pl]';

replace defaultCeiling:Ceiling 'tak+et';

replace defaultNorthWall: DefaultWall 'norr+a *; norra (n)' 
  name = 'nordlig vägg'
  theName = 'norra väggen'
;

replace defaultEastWall: DefaultWall 'öst:er+ra *; östra (ö) (o)'
  name = 'öster vägg'
  theName = 'östra väggen'
;

replace defaultSouthWall: DefaultWall 'söd:er+ra *; södra (s)'
  name = 'söder vägg'
  theName = 'södra väggen'
;

replace defaultWestWall: DefaultWall 'väst:er+ra *; västra (v)'
  name = 'väster vägg'
  theName = 'västra väggen'
;
