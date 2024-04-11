+++
title = '首届 RISC-V 软件移植及优化锦标赛冠军名单'
+++

本届（2023 年）锦标赛共产生 10 组冠军队伍，名单如下（排名不分先后）：

<table id="champion-list">
  <tr class="th">
    <th></th>
    <th></th>
  </tr>

  <tr class="fir">
    <td class="champion" rowspan="2">「你走线如丁似蛋」队</td>
    <td class="challenge"><a href="https://rvspoc.org/p2307/" target="_blank"><span>P2307</span>Zephyr 移植和演示</a></td>
  </tr>
  <tr class="tpr">
    <td class="pr"><a href="https://github.com/plctlab/rvspoc-p2307-zephyr/pull/1" target="_blank">plctlab/rvspoc-p2307-zephyr<span>#1</span></a></td>
  </tr>

  <tr class="fir">
    <td class="champion" rowspan="2">BigBrotherJu</td>
    <td class="challenge"><a href="https://rvspoc.org/p2308/" target="_blank"><span>P2308</span>Xv6 移植和演示</a></td>
  </tr>
  <tr class="tpr">
    <td class="pr"><a href="https://github.com/plctlab/rvspoc-p2308-xv6-riscv/pull/4" target="_blank">plctlab/rvspoc-p2308-xv6-riscv<span>#4</span></td>
  </tr>

  <tr class="fir">
    <td class="champion" rowspan="2">Xhackerustc</td>
    <td class="challenge"><a href="https://rvspoc.org/p2308/" target="_blank"><span>P2308</span>Xv6 移植和演示</a></td>
  </tr>
  <tr class="tpr">
    <td class="pr"><a href="https://github.com/plctlab/rvspoc-p2308-xv6-riscv/pull/2" target="_blank">plctlab/rvspoc-p2308-xv6-riscv<span>#2</span></td>
  </tr>

  <tr class="fir">
    <td class="champion" rowspan="2">xctan</td>
    <td class="challenge"><a href="https://rvspoc.org/s2302/" target="_blank"><span>S2302</span>二进制翻译及优化</a></td>
  </tr>
  <tr class="tpr">
    <td class="pr"><a href="https://github.com/plctlab/rvspoc-s2302-BT/pull/1" target="_blank">plctlab/rvspoc-s2302-BT<span>#1</span></td>
  </tr>

  <tr class="fir">
    <td class="champion" rowspan="2">nexplorer-3e</td>
    <td class="challenge"><a href="https://rvspoc.org/s2305/" target="_blank"><span>S2305</span>OpenGauss 数据库移植和优化</a></td>
  </tr>
  <tr class="tpr">
    <td class="pr"><a href="https://github.com/plctlab/rvspoc-s2305-openGauss-server/pull/2" target="_blank">plctlab/rvspoc-s2305-openGauss-server<span>#2</span></td>
  </tr>

  <tr class="fir">
    <td class="champion" rowspan="2">zhangfei0</td>
    <td class="challenge"><a href="https://rvspoc.org/s2305/" target="_blank"><span>S2305</span>OpenGauss 数据库移植和优化</a></td>
  </tr>
  <tr class="tpr">
    <td class="pr"><a href="https://github.com/plctlab/rvspoc-s2305-openGauss-server/pull/3" target="_blank">plctlab/rvspoc-s2305-openGauss-server<span>#3</span></td>
  </tr>

  <tr class="fir">
    <td class="champion" rowspan="2">liuyd-dev</td>
    <td class="challenge"><a href="https://rvspoc.org/s2306/" target="_blank"><span>S2306</span>Node.js 性能优化</a></td>
  </tr>
  <tr class="tpr">
    <td class="pr"><a href="https://github.com/plctlab/rvspoc-s2306-node/pull/1" target="_blank">plctlab/rvspoc-s2306-node<span>#1</span></td>
  </tr>

  <tr class="fir">
    <td class="champion" rowspan="2">「好吃的卷卷」队</td>
    <td class="challenge"><a href="https://rvspoc.org/s2309/" target="_blank"><span>S2309</span>OpenCV 在 Duo 上的速度优化</a></td>
  </tr>
  <tr class="tpr">
    <td class="pr"><a href="https://github.com/plctlab/rvspoc-s2309-opencv/pull/1" target="_blank">plctlab/rvspoc-s2309-opencv<span>#1</span></td>
  </tr>

  <tr class="fir">
    <td class="champion" rowspan="2">Xinyu302</td>
    <td class="challenge"><a href="https://rvspoc.org/s2310/" target="_blank"><span>S2310</span>ncnn 移植和优化</a></td>
  </tr>
  <tr class="tpr">
    <td class="pr"><a href="https://github.com/plctlab/rvspoc-s2310-ncnn/pull/2" target="_blank">plctlab/rvspoc-s2310-ncnn<span>#2</span></td>
  </tr>

  <tr class="fir">
    <td class="champion" rowspan="2">「操练TPU」队</td>
    <td class="challenge"><a href="https://rvspoc.org/s2311/" target="_blank"><span>S2311</span>Baby LLaMA 2 on Duo 速度优化（儿童讲故事场景）</a></td>
  </tr>
  <tr class="tpr">
    <td class="pr"><a href="https://github.com/plctlab/rvspoc-s2311-llama2/pull/4" target="_blank">plctlab/rvspoc-s2311-llama2<span>#2</span></td>
  </tr>
</table>

<style>
#champion-list {
  text-align: center;
  border: none !important;
}
#champion-list a {
  color: var(--fg) !important;
  text-decoration: none;
  position: relative;
}
#champion-list a:hover {
  text-decoration: underline;
}
#champion-list tr {
  position: relative;
}
#champion-list tr:not(.tpr):not(.th):after {
  content: ' ';
  display: block;
  position: absolute;
  left: 0;
  height: 1px;
  width: 100%;
  z-index: -2;
  background-image: linear-gradient(90deg,#FFFFFF 0%,#8EC5FC 10%,#E0C3FC 50%,#8EC5FC 90%,#FFFFFF 100%);
  opacity: .6;
}
#champion-list th, #champion-list td {
  border: none !important;
  line-height: 1.5em;
}
#champion-list th {
  font-weight: normal !important;
  font-size: 80%;
  line-height: 3em;
}
#champion-list tr:nth-child(even), #champion-list tr:nth-child(odd) {
  background-color: transparent !important;
}
#champion-list .challenge, #champion-list .pr {
  font-size: 80%;
  word-break: break-all;
  text-align: left;
}
#champion-list .challenge span, #champion-list .pr span {
  font-family: monospace;
  font-size: 80%;
  display: inline-block;
  padding: 0.1em 0.5em;
  margin-right: 0.5em;
  background-color: var(--bg-less);
  border-radius: 0.5em;
  position: relative;
  bottom: 0.1em;
}
#champion-list .challenge {
  padding-top: 1em;
}
#champion-list .pr {
  padding-bottom: 2em;
}
#champion-list .challenge:before, #champion-list .pr:before {
  content: '赛题：';
  font-size: 90%;
  margin-right: 0.5em;
  padding-left: 3em;
  opacity: 0.8;
}
#champion-list .pr:before {
  content: '提交：';
}
#champion-list .pr span {
  padding: 0.05em 0.2em;
  margin-left: 0.1em;
  font-size: 90%;
  border-radius: 0.2em;
  bottom: unset;
  text-decoration: inherit;
}
#champion-list .champion {
  padding: 1em 1em 2.5em 1em !important;
  font-size: 90%;
  font-weight: bold;
  letter-spacing: 1px;
  position: relative;
  color: white;
  word-break: none;
  white-space: pre;
}
#champion-list .champion:before {
  content: ' ';
  position: absolute;
  z-index: -1;
  top: 0;
  left: 0;
  width: 100%;
  height: calc(100% - 1.5em);
  background-color: #fff;
  background-image: linear-gradient(90deg, #8EC5FC 0%, #BDC8F8 100%);
}
@media all and (max-width: 800px) {
  #champion-list tr {
    display: flex;
    flex-direction: column;
  }
  #champion-list tr.fir td.champion {
    padding-bottom: 1em !important;
  }
  #champion-list tr.fir td.champion:before {
    height: 100%;
  }
  #champion-list tr.fir td.challenge {
    padding-top: 0.8em;
    border-left: 1px dotted #8EC5FC80 !important;
    border-right: 1px dotted #8EC5FC80 !important;
  }
  #champion-list tr.tpr {
    margin-bottom: 1em;
  }
  #champion-list tr.tpr td {
    padding-bottom: 0.8em;
    border-left: 1px dotted #8EC5FC80 !important;
    border-right: 1px dotted #8EC5FC80 !important;
    border-bottom: 1px dotted #8EC5FC80 !important;
  }
  #champion-list tr.fir td.challenge, #champion-list tr.tpr td {
    display: flex;
    /*background-color: #e0c3fc30;*/
  }
  #champion-list tr td {
    padding-left: 1em !important;
    padding-right: 1em !important;
  }
  #champion-list .challenge:before, #champion-list .pr:before {
    white-space: pre;
    padding-left: 1em;
  }
}
</style>

