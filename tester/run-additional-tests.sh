#!/bin/bash
if [ ! -d "obj" ]; then
  echo "Skapar upp en tom "obj"-katalog som är nödvändig för kompilering"
  mkdir obj
fi

t3make -f additional-tests.t3m && rlwrap frob -k utf8 -i plain additional-tests.t3

