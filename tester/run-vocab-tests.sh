#!/bin/bash
if [ ! -d "obj" ]; then
  echo "Skapar upp en tom "obj"-katalog som är nödvändig för kompilering"
  mkdir obj
fi

#t3make -f grammar-tests.t3m && rlwrap frob -k utf8 -i plain tester.t3
#t3make -f present-tense.t3m && rlwrap frob -k utf8 -i plain tester.t3
t3make -f vocab-tests.t3m && rlwrap frob -k utf8 -i plain tester.t3

