# @Variable: NODE_BENCHMARK_CATEGORIES
# @Value: Fixed items for v20.11.0
# @Description: The benchmark categories
NODE_BENCHMARK_CATEGORIES=( assert async_hooks blob buffers child_process
	cluster crypto dgram diagnostics_channel dns domain error es esm events
	fs http http2 https mime misc module napi net os path perf_hooks
	permission policy process querystring readline streams string_decoder
	test_runner timers tls url util v8 validators vm webstreams worker zlib )

# @Variable: NODE_BENCHMARK_TIMEOUT_<CATE-NAME>
# @Value: Fixed timeout according to the actual benchmark time tested with default.
# @Description: Give a generic timeout to almost all categories except those
#               with a long executing time.
#               The generic timeout value (20m) is based on the contents of file
#               ./misc/time.txt, the values in this file is calculated by script
#               ./misc/calc-time.sh, the original data is benchmarked within a
#               standard environment on Pionner Box with the default node binary
#               (v20.11.0).
#               Other specical timeout values used by some specified categories
#               is also based on the file ./misc/time.txt.
for CATE in "${NODE_BENCHMARK_CATEGORIES[@]}"; do
	eval "NODE_BENCHMARK_TIMEOUT_${CATE}=15m"
done
NODE_BENCHMARK_TIMEOUT_blob=900m
NODE_BENCHMARK_TIMEOUT_buffers=30m
NODE_BENCHMARK_TIMEOUT_crypto=60m
NODE_BENCHMARK_TIMEOUT_fs=30m
NODE_BENCHMARK_TIMEOUT_http=30m
NODE_BENCHMARK_TIMEOUT_process=60m
NODE_BENCHMARK_TIMEOUT_string_decoder=200m
NODE_BENCHMARK_TIMEOUT_test_runner=60m
NODE_BENCHMARK_TIMEOUT_url=60m
NODE_BENCHMARK_TIMEOUT_v8=60m

# @Variable: NODE_BENCHMARK_ENV_<CATE-NAME>
# @Value: Fixed environment variables that should be used when benchmarking
#         specified categories.
NODE_BENCHMARK_ENV_net="PORT=12345 NODEJS_BENCHMARK_ZERO_ALLOWED=1"
