#charset "utf-8"
#include "advlite.h"

// Ger name='himmel' definiteForm = 'himlen', samt 'himle' och 'himmelen'
modify defaultSky vocab = 'him:mel+len;;him:le+melen';

modify DefaultWall vocab = 'vägg+en;;väggar+na[pl]';

replace defaultCeiling:Ceiling 'tak+et';

replace defaultNorthWall: DefaultWall 'nordlig+a *; norra (n)' 
  name = 'nordlig vägg'
  definiteForm = 'nordliga väggen'
;

replace defaultEastWall: DefaultWall 'östra *; (ö) (o)'
  name = 'öster vägg'
  definiteForm = 'östra väggen'
;

replace defaultSouthWall: DefaultWall 'södra *; (s)'
  name = 'söder vägg'
  definiteForm = 'södra väggen'
;

replace defaultWestWall: DefaultWall 'västra *; (v)'
  name = 'väster vägg'
  definiteForm = 'västra väggen'
;
