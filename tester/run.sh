#!/bin/bash
if [ ! -d "obj" ]; then
  echo "Skapar upp en tom "obj"-katalog som är nödvändig för kompilering"
  mkdir obj
fi

echo
echo -e "\033[0;32mgrammar-tests\033[0m"
bash run-grammar-tests.sh
echo

echo
echo -e "\033[0;32mpresent-tense-tests\033[0m"
bash run-present-tense-tests.sh
echo

echo
echo -e "\033[0;32mpast-tense-tests\033[0m"
bash run-past-tense-tests.sh
echo

echo
echo -e "\033[0;32mvocab-tests\033[0m"
bash run-vocab-tests.sh
echo

echo
echo -e "\033[0;32madditional-tests\033[0m"
bash run-additional-tests.sh
echo
