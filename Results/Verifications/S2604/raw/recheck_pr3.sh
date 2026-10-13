#!/usr/bin/env bash
# S2605 #3 边界带复核：readrandom +29.2% 落在 28~32% 带内，按 BASELINE_REPORT §4 重跑再定论。
# 协议与首轮完全一致，3 轮，每轮全新库。
set -uo pipefail
BIN="$HOME/rvspoc-verify/src/rvspoc-S2605-rocksdb-pr3/db_bench"
OUT="$HOME/rvspoc-perf/results/s2605-pr3-recheck"; mkdir -p "$OUT"
COMMON="--num=5000000 --value_size=100 --threads=8 --compression_type=none --statistics=0"
log(){ echo "[$(date -u +%FT%TZ)] $*"; }
for i in 1 2 3; do
  DB="$OUT/db-run$i"
  for b in fillrandom readrandom seekrandom; do
    log "recheck $b run $i/3"
    extra="--db=$DB"
    [ $b != fillrandom ] && extra="$extra --use_existing_db=1"
    [ $b = seekrandom ] && extra="$extra --seek_nexts=10"
    taskset -c 0-7,16-31 "$BIN" --benchmarks=$b $COMMON $extra > "$OUT/$b-run$i.txt" 2>&1
    sleep 30
  done
  rm -rf "$DB"; sleep 90
done
log "RECHECK DONE"
