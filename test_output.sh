#!/usr/bin/bash

set -e

for f in samples/*; do
	for outfmt in md tex; do
		pandoc -L refnos.lua $f -o expected/$(basename ${f%%.*}).$outfmt
	done
done
discrepancies="$(git diff -- expected)"
echo $discrepancies
if [[ "$discrepancies" != "" ]]; then
	echo "Expected output doesn't match actual output!"
	echo $discrepandies
	exit 1
fi
