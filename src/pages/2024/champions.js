import React from 'react';
import Layout from '@theme/Layout';
import './champions.css';

export default function Hello() {
  return (
    <Layout title="第二届 RISC-V 软件移植及优化锦标赛冠军名单">
      <div style={{
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          alignItems: 'center',
          fontSize: '20px',
          maxWidth: '800px',
          margin: 'auto',
          paddingTop: '60px',
          paddingLeft: '20px',
          paddingRight: '20px',
          paddingBottom: '60px',
        }}>
        <h1>
          第二届 RISC-V 软件移植及优化锦标赛冠军名单
        </h1>
        <p>
          本届（2024 年）锦标赛共产生 6 组冠军队伍，名单如下（排名不分先后）：         
        </p>
        <table id="champion-list">

          <tr class="fir">
            <td class="champion" rowspan="2">Kakaka 队</td>
            <td class="challenge"><a href="https://rvspoc.org/S2422/" target="_blank"><span>S2422</span>Llama3 在 K230 上的优化实现</a></td>
          </tr>
          <tr class="tpr">
            <td class="pr"><a href="https://github.com/rv2036/rvspoc-S2422-Llama3/pull/1" target="_blank">rv2036/rvspoc-S2422-Llama3<span>#1</span></a></td>
          </tr>

          <tr class="fir">
            <td class="champion" rowspan="2">时间原理队</td>
            <td class="challenge"><a href="https://rvspoc.org/S2424/" target="_blank"><span>S2424</span>TDengine 移植与优化</a></td>
          </tr>
          <tr class="tpr">
            <td class="pr"><a href="https://github.com/rv2036/rvspoc-S2424-TDengine/pull/1" target="_blank">rv2036/rvspoc-S2424-TDengine<span>#1</span></a></td>
          </tr>

          <tr class="fir">
            <td class="champion" rowspan="2">meOwall 队</td>
            <td class="challenge"><a href="https://rvspoc.org/P2425/" target="_blank"><span>P2425</span>RetroArch 移植与优化</a></td>
          </tr>
          <tr class="tpr">
            <td class="pr"><a href="https://github.com/rv2036/rvspoc-P2425-RetroArch/pull/3" target="_blank">rv2036/rvspoc-P2425-RetroArch<span>#3</span></a></td>
          </tr>

          <tr class="fir">
            <td class="champion" rowspan="2">kube-rv 队</td>
            <td class="challenge"><a href="https://rvspoc.org/P2426/" target="_blank"><span>P2426</span>KubeSphere 移植</a></td>
          </tr>
          <tr class="tpr">
            <td class="pr"><a href="https://github.com/rv2036/rvspoc-P2426-kubesphere/pull/1" target="_blank">rv2036/rvspoc-P2426-kubesphere<span>#1</span></a></td>
          </tr>

          <tr class="fir">
            <td class="champion" rowspan="2">Nests 队</td>
            <td class="challenge"><a href="https://rvspoc.org/S2427/" target="_blank"><span>S2427</span>TiDB 在 2042 的移植与优化</a></td>
          </tr>
          <tr class="tpr">
            <td class="pr"><a href="https://github.com/rv2036/rvspoc-S2427-tidb/pull/1" target="_blank">rv2036/rvspoc-S2427-tidb<span>#1</span></a></td>
          </tr>

          <tr class="fir">
            <td class="champion" rowspan="2">GuoMoe 队</td>
            <td class="challenge"><a href="https://rvspoc.org/S2428/" target="_blank"><span>S2428</span>K3s 的移植与优化</a></td>
          </tr>
          <tr class="tpr">
            <td class="pr"><a href="https://github.com/rv2036/rvspoc-S2428-k3s/pull/1" target="_blank">rv2036/rvspoc-S2428-k3s<span>#1</span></a></td>
          </tr>

        </table>
      </div>
    </Layout>
  );
}


