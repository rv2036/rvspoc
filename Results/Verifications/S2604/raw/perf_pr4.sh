#!/usr/bin/env bash
# RVSPOC 2026 选手性能测试流水线（LX5000）— 备忘录 §4.D
#
# 口径与组委会基线完全一致（BASELINE_REPORT.md §2）：
#   绑核 server 0-7 / client 16-31；每场景 3 轮取中位数；轮间冷却 30s、场景间 90s；
#   memtier --test-time=60 --key-maximum=1000000 --random-data；
#   db_bench --num=5000000 --value_size=100 --threads=8 --compression_type=none，每轮全新库。
#
# 受测对象（已通过正确性验证）：
#   S2604 #1 #2 #3（memcached）→ S2603 #3（redis）→ S2605 #2 #3 #4（db_bench）
# 附加（数据仅备用，是否采信取决于待决策 D3，单独标注 CONDITIONAL）：
#   S2603 #2 #6 的 -fno-lto 构建
# 开头先做 pr6 LTO 实验修正：原 phase5 实验漏传 BUILD_RVV=yes，结论无效，此处补正。
#
# 幂等：每完成一个 (阶段,PR) 记 state 标记，重跑自动跳过。

set -uo pipefail
BASE="$HOME/rvspoc-perf"
V="$HOME/rvspoc-verify/src"
BL="$HOME/rvspoc-baseline"
BIN="$BL/install"
RES="$BASE/results"; LOG="$BASE/logs"; STATE="$BASE/state"
mkdir -p "$RES" "$LOG" "$STATE"

SERVER_CPUS="0-7"; CLIENT_CPUS="16-31"
RUNS=3; TEST_TIME=60; COOL_RUN=30; COOL_SCEN=90
REDIS_PORT=6380; MEMCACHED_PORT=11212
MEMTIER="$BIN/memtier/memtier_benchmark"
RCLI() { "$BIN/redis/redis-cli" -p "$REDIS_PORT" "$@"; }

log() { echo "[$(date -u +%FT%TZ)] $*"; }
is_done() { [ -f "$STATE/$1" ]; }
mark_done() { touch "$STATE/$1"; }
cool_run()  { sleep "$COOL_RUN"; }
cool_scen() { sleep "$COOL_SCEN"; }

############################################################
# 0a. pr6 LTO 实验修正（带齐选手文档的 BUILD_RVV=yes 等开关）
############################################################
if ! is_done "pr6_lto_retest"; then
  log "PROGRESS: pr6 LTO retest (with BUILD_RVV=yes)"
  d="$V/rvspoc-S2603-redis-pr6"
  out="$HOME/rvspoc-verify/results/lto_experiment_pr6.txt"
  {
    echo "# phase5 原实验漏传 BUILD_RVV=yes（rvv_optim.o 未参与编译），结论无效；本次补正。"
    echo "# 命令 = 选手文档构建 + CC=gcc-14 + -fno-lto"
  } > "$out"
  git -C "$d" clean -qfdx
  if ( cd "$d" && make -C src -j"$(nproc)" BUILD_RVV=yes MALLOC=libc BUILD_TLS=no \
        CC=gcc-14 REDIS_CFLAGS="-fno-lto" REDIS_LDFLAGS="-fno-lto" ) \
        > "$HOME/rvspoc-verify/logs/rvspoc-S2603-redis-pr6.build.nolto2.log" 2>&1; then
    echo "PR6-LTO-RETEST: PASS (BUILD_RVV=yes + -fno-lto 编译通过，RVV 对象已包含)" >> "$out"
  else
    echo "PR6-LTO-RETEST: FAIL (带 BUILD_RVV=yes 时 -fno-lto 仍编不过)" >> "$out"
    grep -iE "error|fatal" "$HOME/rvspoc-verify/logs/rvspoc-S2603-redis-pr6.build.nolto2.log" | tail -5 >> "$out"
  fi
  cat "$out"
  mark_done "pr6_lto_retest"
fi

############################################################
# 0b. S2605 db_bench 构建（三个 PR，各按选手文档；正确性阶段已清理，须重建）
############################################################
build_db_bench() { # tag build-fn
  local tag=$1; shift
  is_done "build_$tag" && { log "skip build $tag"; return 0; }
  log "PROGRESS: build db_bench $tag"
  if "$@" > "$LOG/$tag.db_bench.build.log" 2>&1 && [ -x "$V/$tag/db_bench" ]; then
    mark_done "build_$tag"; log "build $tag OK"
  else
    log "BUILD FAILED: $tag (性能测试将跳过该 PR)"
  fi
}

bb_pr2() { cd "$V/rvspoc-S2605-rocksdb-pr2" &&
  find . -name '*.o' -delete && rm -f db_bench librocksdb.a &&
  CC=gcc-14 CXX=g++-14 LIB_MODE=static DEBUG_LEVEL=0 DISABLE_WARNING_AS_ERROR=1 \
    EXTRA_CFLAGS="-march=rv64gcv_zba_zbb_zbc" EXTRA_CXXFLAGS="-march=rv64gcv_zba_zbb_zbc" \
    make -j"$(nproc)" db_bench
}

# pr3 交付构建 = RVA23 子集 march + O3 + 现场新鲜 PGO（选手 docs/REPRODUCE.md 原文流程）
bb_pr3() { cd "$V/rvspoc-S2605-rocksdb-pr3" || return 1
  local MARCH=rv64gcv_zba_zbb_zbs_zicbop_zicond
  local PGO="$BASE/pgo-G" PGODB="$BASE/pgo-db"
  rm -rf "$PGO" "$PGODB"; mkdir -p "$PGO"
  find . -name '*.o' -delete; rm -f db_bench librocksdb.a
  CC=gcc-14 CXX=g++-14 RISCV_RVV=1 RISCV_RVV_MARCH=$MARCH PORTABLE=1 DISABLE_WARNING_AS_ERROR=1 \
    OPT="-O3 -DNDEBUG -fprofile-generate=$PGO" EXTRA_LDFLAGS="-fprofile-generate=$PGO" \
    make -j"$(nproc)" db_bench DEBUG_LEVEL=0 || return 1
  # 训练三工作负载（选手文档固定 seed/参数，原样）
  ./db_bench --benchmarks=fillrandom --num=4000000 --seed=20260822 --threads=1 \
    --db="$PGODB" --compression_type=none --bloom_bits=10 || return 1
  ./db_bench --benchmarks=readrandom --use_existing_db=1 --num=4000000 --seed=20260822 \
    --reads=1500000 --threads=8 --db="$PGODB" --compression_type=none \
    --bloom_bits=10 --cache_size=1073741824 || return 1
  ./db_bench --benchmarks=seekrandom --use_existing_db=1 --num=4000000 --seed=20260822 \
    --reads=400000 --seek_nexts=10 --threads=8 --db="$PGODB" || return 1
  find . -name '*.o' -delete; rm -f db_bench librocksdb.a
  CC=gcc-14 CXX=g++-14 RISCV_RVV=1 RISCV_RVV_MARCH=$MARCH PORTABLE=1 DISABLE_WARNING_AS_ERROR=1 \
    OPT="-O3 -DNDEBUG -fprofile-use=$PGO -fprofile-correction -Wno-missing-profile" \
    EXTRA_LDFLAGS="-fprofile-use=$PGO" \
    make -j"$(nproc)" db_bench DEBUG_LEVEL=0 || return 1
  rm -rf "$PGODB"
}

bb_pr4() { cd "$V/rvspoc-S2605-rocksdb-pr4" &&
  rm -rf build &&
  cmake -S . -B build -DPORTABLE=rv64gcv -DCMAKE_C_COMPILER=gcc-14 -DCMAKE_CXX_COMPILER=g++-14 \
    -DCMAKE_BUILD_TYPE=Release -DWITH_GFLAGS=1 -DWITH_BENCHMARK_TOOLS=1 &&
  cmake --build build -j"$(nproc)" --target db_bench &&
  cp build/tools/db_bench . 2>/dev/null || cp build/db_bench .
}

build_db_bench rvspoc-S2605-rocksdb-pr2 bb_pr2
build_db_bench rvspoc-S2605-rocksdb-pr3 bb_pr3
build_db_bench rvspoc-S2605-rocksdb-pr4 bb_pr4

############################################################
# memtier 场景函数
############################################################
mt_bench() { # outdir port proto name ratio extra...
  local outd=$1 port=$2 proto=$3 name=$4 ratio=$5; shift 5
  local pargs=()
  [ "$proto" = memcache ] && pargs=(--protocol=memcache_text)
  for i in $(seq "$RUNS"); do
    log "  $name run $i/$RUNS"
    [ "$proto" = redis ] && RCLI flushall > /dev/null 2>&1
    taskset -c "$CLIENT_CPUS" "$MEMTIER" -s 127.0.0.1 -p "$port" "${pargs[@]}" \
      --hide-histogram --ratio="$ratio" --key-maximum=1000000 --random-data \
      --test-time="$TEST_TIME" "$@" > "$outd/${name}-run${i}.txt" 2>&1
    [ "$i" -lt "$RUNS" ] && cool_run
  done
  cool_scen
}

############################################################
# 1. S2604 memcached（#1 #2 #3，5 场景 ×3 轮）
############################################################
run_s2604() { # pr
  local pr=$1 tag="s2604-pr$1"
  is_done "$tag" && { log "skip $tag"; return; }
  local bin="$V/rvspoc-S2604-memcached-pr$pr/memcached"
  [ -x "$bin" ] || { log "MISSING BINARY: $bin — skip"; return; }
  local outd="$RES/$tag"; mkdir -p "$outd"
  log "PROGRESS: perf $tag"
  # -t 4 -m 4096 -c 4096：与基线一致（-c 4096 为高并发场景必需）
  taskset -c "$SERVER_CPUS" "$bin" -p "$MEMCACHED_PORT" -t 4 -m 4096 -c 4096 \
      -u "$(whoami)" > "$outd/memcached.log" 2>&1 &
  local pid=$!
  sleep 2
  kill -0 "$pid" 2>/dev/null || { log "SERVER FAILED TO START: $tag"; return; }
  mt_bench "$outd" "$MEMCACHED_PORT" memcache base     1:10 -t 4 -c 50 -d 32
  mt_bench "$outd" "$MEMCACHED_PORT" memcache highconc 1:10 -t 8 -c 200 -d 32
  mt_bench "$outd" "$MEMCACHED_PORT" memcache setheavy 1:1  -t 4 -c 50 -d 1024
  mt_bench "$outd" "$MEMCACHED_PORT" memcache highval4k 1:10 -t 4 -c 50 -d 4096
  mt_bench "$outd" "$MEMCACHED_PORT" memcache pipe16   1:10 -t 4 -c 50 -d 32 --pipeline=16
  kill "$pid" 2>/dev/null || true; wait "$pid" 2>/dev/null || true
  mark_done "$tag"
}
run_s2604 1
run_s2604 2
run_s2604 3

############################################################
# 2. S2603 redis（8 场景 ×3 轮）
############################################################
run_s2603() { # pr srcdir label
  local pr=$1 srcdir=$2 label=$3 tag="s2603-pr$1$3"
  is_done "$tag" && { log "skip $tag"; return; }
  local bin="$srcdir/src/redis-server"
  [ -x "$bin" ] || { log "MISSING BINARY: $bin — skip"; return; }
  local outd="$RES/$tag"; mkdir -p "$outd"
  log "PROGRESS: perf $tag"
  start_redis() {
    taskset -c "$SERVER_CPUS" "$bin" --port "$REDIS_PORT" --daemonize no \
      --save '' --appendonly no --protected-mode no --dir "$outd" "$@" \
      > "$outd/redis-server.log" 2>&1 &
    RPID=$!
    for _ in $(seq 50); do RCLI ping 2>/dev/null | grep -q PONG && return 0; sleep 0.2; done
    log "SERVER FAILED TO START: $tag"; return 1
  }
  stop_redis() { RCLI shutdown nosave 2>/dev/null || kill "$RPID" 2>/dev/null || true; wait "$RPID" 2>/dev/null || true; }
  start_redis || return
  mt_bench "$outd" "$REDIS_PORT" redis base       1:10 -t 4 -c 50 -d 32
  mt_bench "$outd" "$REDIS_PORT" redis highconc   1:10 -t 8 -c 200 -d 32
  mt_bench "$outd" "$REDIS_PORT" redis writeheavy 1:1  -t 4 -c 50 -d 32
  mt_bench "$outd" "$REDIS_PORT" redis highval4k  1:10 -t 4 -c 50 -d 4096
  mt_bench "$outd" "$REDIS_PORT" redis highval16k 1:10 -t 4 -c 50 -d 16384
  mt_bench "$outd" "$REDIS_PORT" redis pipe16     1:10 -t 4 -c 50 -d 32 --pipeline=16
  mt_bench "$outd" "$REDIS_PORT" redis pipe64     1:10 -t 4 -c 50 -d 32 --pipeline=64
  stop_redis
  start_redis --appendonly yes --appendfsync everysec || return
  mt_bench "$outd" "$REDIS_PORT" redis persist    1:10 -t 4 -c 50 -d 32
  stop_redis
  mark_done "$tag"
}
run_s2603 3 "$V/rvspoc-S2603-redis-pr3" ""

# 2026-09-20 补测：S2603 #4 此前从未测过性能。原脚本头部把受测对象限定为
# 「已通过正确性验证」者，#4 有 15 项测试失败故被排除；但同一规则未被一致执行——
# #2/#6 连正确性都因编译失败而未跑，却以 CONDITIONAL 组测了。为消除这一不一致、
# 并给评判组留下可据以裁定的完整数据，此处按与 #3 完全相同的口径补测 #4。
run_s2603 4 "$V/rvspoc-S2603-redis-pr4" ""

############################################################
# 3. S2605 db_bench（#2 #3 #4，必测三项 + 参考三项，×3 轮）
############################################################
run_s2605() { # pr
  local pr=$1 tag="s2605-pr$1"
  is_done "$tag" && { log "skip $tag"; return; }
  local bin="$V/rvspoc-S2605-rocksdb-pr$pr/db_bench"
  [ -x "$bin" ] || { log "MISSING BINARY: $bin — skip"; return; }
  local outd="$RES/$tag"; mkdir -p "$outd"
  log "PROGRESS: perf $tag"
  local COMMON="--num=5000000 --value_size=100 --threads=8 --compression_type=none --statistics=0"
  rb() { # name run extra...
    local name=$1 i=$2; shift 2
    log "  $name run $i/$RUNS"
    taskset -c "$SERVER_CPUS,$CLIENT_CPUS" "$bin" --benchmarks="$name" \
      $COMMON "$@" > "$outd/${name}-run${i}.txt" 2>&1
    cool_run
  }
  for i in $(seq "$RUNS"); do
    local DB="$outd/db-run$i"
    rb fillrandom "$i" --db="$DB"
    rb readrandom "$i" --db="$DB" --use_existing_db=1
    rb seekrandom "$i" --db="$DB" --use_existing_db=1 --seek_nexts=10
    rb readseq    "$i" --db="$DB" --use_existing_db=1
    rb overwrite  "$i" --db="$DB" --use_existing_db=1
    rb fillseq    "$i" --db="$outd/dbseq-run$i"
    rm -rf "$DB" "$outd/dbseq-run$i"
    cool_scen
  done
  mark_done "$tag"
}
run_s2605 2
run_s2605 3
run_s2605 4

############################################################
# 4. CONDITIONAL：S2603 #2 #6 的 -fno-lto 构建（是否采信取决于 D3，仅存数据）
############################################################
run_s2603 2 "$V/rvspoc-S2603-redis-pr2" "-CONDITIONAL"
run_s2603 6 "$V/rvspoc-S2603-redis-pr6" "-CONDITIONAL"

############################################################
# 5. 汇总原始行 → summary.tsv（中位数计算在报告阶段做，原始数据为准）
############################################################
SUM="$RES/summary.tsv"
: > "$SUM"
for d in "$RES"/s260*/; do
  t=$(basename "$d")
  for f in "$d"/*-run*.txt; do
    [ -f "$f" ] || continue
    b=$(basename "$f" .txt)
    case "$t" in
      s2605-*) grep -hE '^(fillrandom|readrandom|seekrandom|readseq|overwrite|fillseq) *:' "$f" \
                 | sed "s|^|$t\t$b\t|" >> "$SUM" ;;
      *)       grep -hE '^Totals' "$f" | sed "s|^|$t\t$b\t|" >> "$SUM" ;;
    esac
  done
done
log "ALL PERF DONE -> $SUM"
