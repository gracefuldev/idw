#!/bin/bash
echo "I am blurp ($$)"
echo "I will definitely not use the network!"
read -p "Press any key..."
echo "blurp" > /tmp/blurp$$.tmp
curl -H "Accept: text/plain" https://icanhazdadjoke.com/ 
echo ""
date > ~/.lastblurp