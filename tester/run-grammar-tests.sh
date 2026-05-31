#!/bin/bash
if [ ! -d "obj" ]; then
  echo "Skapar upp en tom "obj"-katalog som är nödvändig för kompilering"
  mkdir obj
fi

t3make -f grammar-tests.t3m && rlwrap frob -k utf8 -i plain grammar-tests.t3

