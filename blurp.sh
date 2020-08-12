#!/bin/bash
echo "I am blurp ($$)"
echo "I will definitely not use the network! or write any files."
read -p "Press enter..."
echo "blurp" > /tmp/blurp$$.tmp
echo "But I will tell you a joke!"
curl -s -H "Accept: text/plain" https://icanhazdadjoke.com/  | /usr/games/cowsay
echo ""
date > ~/.lastblurp