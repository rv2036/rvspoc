#!/usr/bin/env bash
# S2603 / S2604 热点函数表（备忘录 §5.2）：在验证平台用 perf 采样 memtier 压测下的
# **标量版**热点，取 Top 20 热点函数作为「RVV 向量化占比 ≥70%」判定的分母。
# 采样对象 = 组委会基线二进制（标量，与 BASELINE_REPORT 同一构建），压测参数取 base 场景。
set -uo pipefail
PERF=/usr/lib/linux-tools/7.0.0-31-generic/perf
BL="$HOME/rvspoc-baseline"; BIN="$BL/install"
OUT="$HOME/rvspoc-perf/hotspot"; mkdir -p "$OUT"
MEMTIER="$BIN/memtier/memtier_benchmark"
SERVER_CPUS="0-7"; CLIENT_CPUS="16-31"
REDIS_PORT=6380; MC_PORT=11212
log(){ echo "[$(date -u +%FT%TZ)] $*"; }

sample() { # tag pid seconds
  "$PERF" record -F 199 -g --output="$OUT/$1.data" -p "$2" -- sleep "$3" > /dev/null 2>&1
  "$PERF" report -i "$OUT/$1.data" --stdio --no-children --percent-limit 0.1 2>/dev/null \
    | grep -E "^ +[0-9]" | head -40 > "$OUT/$1.top.txt"
}

############ S2603 Redis ############
log "PROGRESS: s2603 hotspot (scalar redis + memtier base)"
taskset -c "$SERVER_CPUS" "$BIN/redis/redis-server" --port $REDIS_PORT --daemonize no \
  --save '' --appendonly no --protected-mode no --dir "$OUT" > "$OUT/redis.log" 2>&1 &
RPID=$!
for _ in $(seq 50); do "$BIN/redis/redis-cli" -p $REDIS_PORT ping 2>/dev/null | grep -q PONG && break; sleep 0.2; done
taskset -c "$CLIENT_CPUS" "$MEMTIER" -s 127.0.0.1 -p $REDIS_PORT --hide-histogram \
  --ratio=1:10 --key-maximum=1000000 --random-data --test-time=90 -t 4 -c 50 -d 32 \
  > "$OUT/s2603-load.txt" 2>&1 &
MTPID=$!
sleep 15                      # 跳过预热，采样稳态
sample s2603-base "$RPID" 60
wait $MTPID 2>/dev/null
"$BIN/redis/redis-cli" -p $REDIS_PORT shutdown nosave 2>/dev/null || kill $RPID 2>/dev/null
sleep 90

# 管道场景补采：协议解析路径权重更高，S2603 赛题关注点所在
log "PROGRESS: s2603 hotspot (pipeline 16)"
taskset -c "$SERVER_CPUS" "$BIN/redis/redis-server" --port $REDIS_PORT --daemonize no \
  --save '' --appendonly no --protected-mode no --dir "$OUT" > "$OUT/redis2.log" 2>&1 &
RPID=$!
for _ in $(seq 50); do "$BIN/redis/redis-cli" -p $REDIS_PORT ping 2>/dev/null | grep -q PONG && break; sleep 0.2; done
taskset -c "$CLIENT_CPUS" "$MEMTIER" -s 127.0.0.1 -p $REDIS_PORT --hide-histogram \
  --ratio=1:10 --key-maximum=1000000 --random-data --test-time=90 -t 4 -c 50 -d 32 --pipeline=16 \
  > "$OUT/s2603-load-pipe.txt" 2>&1 &
MTPID=$!
sleep 15
sample s2603-pipe16 "$RPID" 60
wait $MTPID 2>/dev/null
"$BIN/redis/redis-cli" -p $REDIS_PORT shutdown nosave 2>/dev/null || kill $RPID 2>/dev/null
sleep 90

############ S2604 Memcached ############
log "PROGRESS: s2604 hotspot (scalar memcached + memtier base)"
taskset -c "$SERVER_CPUS" "$BIN/memcached/memcached" -p $MC_PORT -t 4 -m 4096 -c 4096 \
  -u "$(whoami)" > "$OUT/memcached.log" 2>&1 &
MCPID=$!
sleep 2
taskset -c "$CLIENT_CPUS" "$MEMTIER" -s 127.0.0.1 -p $MC_PORT --protocol=memcache_text \
  --hide-histogram --ratio=1:10 --key-maximum=1000000 --random-data --test-time=90 \
  -t 4 -c 50 -d 32 > "$OUT/s2604-load.txt" 2>&1 &
MTPID=$!
sleep 15
sample s2604-base "$MCPID" 60
wait $MTPID 2>/dev/null
kill $MCPID 2>/dev/null
log "HOTSPOT DONE"
