# @Variable: NODE_BENCHMARK_BIN
# @Value:
#       NODE_BENCHMARK_BIN env
#       ./out/Release/node
# @Description: the node binary path used for benchmark
: "${NODE_BENCHMARK_BIN:=./out/Release/node}"
NODE_BENCHMARK_BIN="$(realpath "$NODE_BENCHMARK_BIN")"

# @Variable: NODE_BENCHMARK_SRCDIR
# @Value:
#       NODE_BENCHMARK_SRCDIR env
#       $1 argument
#       $(pwd)
# @Description: the node src dir path where the benchmark folder lives
: "${NODE_BENCHMARK_SRCDIR:=${1:-$(pwd)}}"
NODE_BENCHMARK_SRCDIR="$(realpath "$NODE_BENCHMARK_SRCDIR")"

# @Variable: NODE_BENCHMARK_OUTDIR
# @Value:
#       NODE_BENCHMARK_OUTDIR env
#       ./node-benchmark-`date '+%Y-%m-%d_%H-%M'`
# @Description: the parent dir of benchmark results
: "${NODE_BENCHMARK_OUTDIR:=./node-benchmark-$(date '+%Y-%m-%d_%H-%M')}"
NODE_BENCHMARK_OUTDIR="$(realpath "$NODE_BENCHMARK_OUTDIR")"

# @Variable: NODE_BENCHMARK_CATEGORIES_FILTER
# @Value: NODE_BENCHMARK_CATEGORIES_FILTER env
# @Description: separate with space

# @Variable: NODE_BENCHMARK_CATEGORIES_EXCLUDE
# @Value: NODE_BENCHMARK_CATEGORIES_EXCLUDE env
# @Description: separate with space
