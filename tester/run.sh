#!/bin/bash
if [ ! -d "obj" ]; then
  echo "Skapar upp en tom "obj"-katalog som är nödvändig för kompilering"
  mkdir obj
fi

echo
echo -e "\033[0;32mgrammar-tests\033[0m"
t3make -nobanner -f grammar-tests.t3m && rlwrap frob -k utf8 -i plain tester.t3
ECHO

echo -e "\033[0;32mpresent-tense-tests\033[0m"
t3make -nobanner -f present-tense.t3m && rlwrap frob -k utf8 -i plain tester.t3
ECHO

echo -e "\033[0;32mpast-tense-tests\033[0m"
t3make -nobanner -f past-tense.t3m && rlwrap frob -k utf8 -i plain tester.t3
ECHO

echo -e "\033[0;32mvocab-tests\033[0m"
t3make -nobanner -f vocab-tests.t3m && rlwrap frob -k utf8 -i plain tester.t3
ECHO

