#!/usr/bin/env bash
# 等当前正确性测试跑完，换用修正版重跑 RocksDB 部分（原版因非 PIC 对象+共享库链接失败）
cd "$(dirname "$0")"
while pgrep -f "correctness.sh" > /dev/null; do sleep 60; done
mv -f correctness.next.sh correctness.sh
# 清掉 rocksdb 的旧结果行与基线构建残留，让修正版重跑
grep -v "rocksdb" results/correctness.tsv > results/correctness.tsv.tmp && mv results/correctness.tsv.tmp results/correctness.tsv
git -C "$HOME/rvspoc-baseline/src/rocksdb" clean -qfdx 2>/dev/null
for d in src/rvspoc-S2605-rocksdb-pr*; do [ -d "$d" ] && git -C "$d" clean -qfdx 2>/dev/null; done
./correctness.sh > correctness2.log 2>&1
echo "ALL PHASES DONE" >> correctness2.log
