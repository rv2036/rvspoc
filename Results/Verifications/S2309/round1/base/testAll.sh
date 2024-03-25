#!/bin/ash

export LD_LIBRARY_PATH='/root/lib/:$LD_LIBRARY_PATH'

#每个模块对应的测试suite列表
input="inputAll.csv"

timeout=15

#测试结果列表
output="outputAll.csv"

touch $output
d=`date`
echo "$d" >> $output

while IFS=, read -r f1 f2 f3; do
        env WARNTIME=$timeout WARNSIG=1 KILLTIME=1.000001 ./timelimit ./bin/$f1  --gtest_filter="$f2.$f3"
        ret=$?
        echo "$f1,$f2,$f3,$ret" >> $output
done < "$input"

d=`date`

echo "$d" >> $output
