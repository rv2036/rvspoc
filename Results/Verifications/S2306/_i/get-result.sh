#!/usr/bin/env bash
#

compareR="$1"

CATEGORIES=( assert async_hooks blob buffers child_process
	cluster crypto dgram diagnostics_channel dns domain error es esm events
	fs http http2 https mime misc module napi net os path perf_hooks
	permission policy process querystring readline streams string_decoder
	test_runner timers tls url util v8 validators vm webstreams worker zlib )

mkdir -p results.dir  results.21.dir

for c in "${CATEGORIES[@]}"; do
	cat ./cX/$c/results.csv | Rscript "$compareR" >./results.dir/$c.txt || true
	cat ./cY/$c/results.csv | Rscript "$compareR" >./results.21.dir/$c.txt || true
done
