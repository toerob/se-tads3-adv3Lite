#!/bin/bash
if [ ! -d "obj" ]; then
  echo "Skapar upp en tom "obj"-katalog som är nödvändig för kompilering"
  mkdir obj
fi

# Option: suppress the MORE via the banner/screen height system


#t3make -f present-tense.t3m && rlwrap frob -k utf8 -i plain tester.t3
#printf '%0.s\n' {1..10000} | frob -c -p -k utf8 -i plain -e 8192 tester.t3 | grep 'TODO_VALUE'
t3make -f present-tense.t3m && yes "" | frob -k utf8 -i plain tester.t3
 