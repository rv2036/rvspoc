+++
title = 'RISC-V 软件移植及优化锦标赛结果出炉，进入一周公示期'
date = 2024-04-03T15:30:00+08:00
slug = '05'
toc = false
summary = '经过了 3 个月的比赛和 1 个月的选手结果验证，RISC-V 全球锦标赛圆满落下帷幕。本次比赛共有 12 道赛题，其中有 4 道赛题没有收到任何提交，其余 8 道赛题分别收到了一组或多组提交，去除同一选手重复提交后共计 18 个提交。评委会通过选手的各项得分综合评比，选出了 10 名冠军。比赛的最终结果将在比赛官网进行公示，公示期一周，从 2024/4/3 开始至 2024/4/10 结束。'
+++

经过了 3 个月的比赛和 1 个月的选手结果验证，RISC-V 全球锦标赛圆满落下帷幕。本次比赛共有 12 道赛题，其中有 4 道赛题没有收到任何提交，其余 8 道赛题分别收到了一组或多组提交，去除同一选手重复提交后共计 18 个提交。评委会通过选手的各项得分综合评比，选出了 10 名冠军。比赛的最终结果将在比赛官网进行公示，公示期一周，从 2024/4/3 开始至 2024/4/10 结束。

## 本次比赛中没有收到任何提交的题目

* P2301 OpenHarmony 在 SG2042 上的移植和演示
* P2303 ROCm 平台移植并兼容 AMD GPU
* P2304 国产 GPU 平台移植和演示
* S2312 流式 ASR 在 SG2002 上的移植优化

## 本次比赛中收到过选手提交的题目

### S2302 二进制翻译及优化

本题是一道竞速赛，由一组选手提交。本题目要求选手使用二进制翻译技术在 SG2042 上运行 X64 或者 ARM64 程序。最终由 [xctan](https://github.com/plctlab/rvspoc-s2302-BT/pull/1) 个人参赛 ，在 SG2042 上通过 Box64 成功运行了产出要求中的天之痕和反恐精英，拿下本赛题的冠军。

### S2305 OpenGauss 数据库移植和优化

本题共两组选手提交，分别是 [zhangfeiv0](https://github.com/plctlab/rvspoc-s2305-openGauss-server/pull/3) 和 [nexplorer-3e](https://github.com/plctlab/rvspoc-s2305-openGauss-server/pull/2)。两位选手都独立的将 openGauss 数据库移植到 SG2042 平台上，并在此基础上做出了一系列优化。在组委会的[验证复核结果](https://github.com/plctlab/rvspoc/blob/main/Results/Verifications/S2305/README.md)中， PR3 的性能测评数据上略优、稳定性方面更为出色，但是考虑到硬件系统环境验证（docker 环境、原生系统 Fedora），存在验证环境误差干扰的可能性。基于以上分析，评委会决定 PR2 和 PR3 的作者（zhangfeiv0 和 nexplorer-3e）为共同冠军。共同冠军是指本赛题的奖金总额增加一倍，每一位冠军领取到全额奖金（而不是均分）。

![](/images/posts/05-S2305-1.png)

### S2306 Node.js 性能优化

本赛题由一组选手提交。本题目要求在 Node.js 官方 RISC-V 版本的基础上，修复 bug 和 SG2042/Pioneer Box 硬件实施优化，尽可能高的提升相关 Benchmark 的分数。本题由 [liuyd-dev](https://github.com/plctlab/rvspoc-s2306-node/pull/1) 个人参赛 ，liuyd-dev backport 了一些高版本的特性支持到基线上，他最终将拿下本题的冠军。

### P2307 Zephyr 移植和演示

本赛题共两组选手提交，分别是[「你走线如丁似蛋队」](https://github.com/plctlab/rvspoc-p2307-zephyr/pull/1) 和 [「Jude小队」](https://github.com/plctlab/rvspoc-p2307-zephyr/pull/2)。本题要求将 Zephyr 移植到 Milk-V Duo 上，关于本题的选手提交结果验证结果见下图。两队参赛者都成功在 Milk-V Duo 上移植了 Zephyr。由于本题是一道移植类题目，因为「你走线如丁似蛋队」提交时间更早，且完成的功能模块更多。PR1 选手「你走线如丁似蛋队」在 Milk-V Duo 除了中断处理， UART 和 GPIO 外，还移植了 PWM 和 Mailbox，并添加了对应的测试程序。因此冠军宣布为 PR1 选手「你走线如丁似蛋队」。

![](/images/posts/05-P2307-1.png)

### P2308 Xv6 移植和演示

共赛题由三组选手提交，分别是 [IEEE 80211 Team](https://github.com/plctlab/rvspoc-p2308-xv6-riscv/pull/3) ，[Xhackerustc](https://github.com/plctlab/rvspoc-p2308-xv6-riscv/pull/2)和[BigBrotherJu](https://github.com/plctlab/rvspoc-p2308-xv6-riscv/pull/4)，分别对应 PR3， PR2 和 PR4，因为 IEEE 80211 Team 的 PR1 和 PR3 的内容代码完全一致，组委会将其进行了合并复核。本题的目的是在 Milk-V Duo 上移植 Xv6 系统，Xv6 是 MIT 开发的一个教学用的完整的类 Unix 操作系统。 Xhackerustc 和 BigBrotherJu 选手在提交时间上相近，且功能点相似。经过评委的分析确认，最终按照实质性完成判定分类思想，结合本题有多个评分点综合评定。经评委会研究决定本题 PR2 作者 (Xhackerustc) 和 PR4 作者 (BigBrotherJu) 作为本赛题共同冠军。共同冠军是指本赛题的奖金总额增加一倍，每一位冠军领取到全额奖金（而不是均分）。

![](/images/posts/05-P2308-1.png)

### S2309 OpenCV 在 Duo 上的速度优化

本题共两组选手提交，分别是[「好吃的卷卷队」](https://github.com/plctlab/rvspoc-s2309-opencv/pull/1)和[「银河护卫队」](https://github.com/plctlab/rvspoc-s2309-opencv/pull/2) 。本题旨在提升 OpenCV 在 Milk-V Duo 平台上的性能，并将 OpenCV 移植到 Milk-V Duo 上。在测试结果中，PR1 选手「好吃的卷卷队」的测试通过率 93.55%，测试的整体时间耗时 6 小时,此两项明显优于其他选手。因此 PR1 选手「好吃的卷卷队」为本项赛题的冠军。

![](/images/posts/05-S2309-1.png)

### S2310 ncnn 移植和优化

本题共两名选手提交，分别是 [MollySophia](https://github.com/plctlab/rvspoc-s2310-ncnn/pull/1) 和 [Xinyu302](https://github.com/plctlab/rvspoc-s2310-ncnn/pull/2)。本题目要求在上游已有的 RISC-V 支持下尽可能的提升 ncnn 自带测试集的分数。两位选手都对 ncnn 在 Milk-V Duo 上进行了 RVV 的优化以及其他模型上的优化。对比在 Milk-V Duo 上 ncnn 的原始跑分，都有比较大的提升。从[复测结果](https://github.com/plctlab/rvspoc/tree/main/Results/Verifications/S2310) 来看，PR2 选手 (Xinyu302) 在回归测试通过项和各项跑分上，均更胜一筹，因此冠军为 PR2 选手 (Xinyu302)。

### S2311 Baby LLaMA 2 on Duo 速度优化（儿童讲故事场景）

共[五组选手提交](https://github.com/plctlab/rvspoc-s2311-llama2/pulls)，本题目要求在 Milk-V Duo 上运行 Baby LLaMA 2，来达到一个儿童故事场景，目标是更快的每秒 Token 处理速度。其中 PR4 选手（[操练 TPU队](https://github.com/plctlab/rvspoc-s2311-llama2/pull/4) ) 在 int8 量化模型下达到了 24.302522 每秒 Token 数，远高于其他选手，因此 PR4 选手（操练 TPU队）为本项赛题的冠军。

![](/images/posts/05-S2311-1.png)

## 评委会与组委会

* [本届 RISC-V 软件移植与优化全球锦标赛评审委员会](/2023/committee/)
* [本届 RISC-V 软件移植与优化全球锦标赛组织委员会](/2023/organizers/)

## 结束语

感谢算能作为锦标赛的坚实后盾，对本次比赛提供的赞助和大力支持。
感谢所有参赛报名的选手，他们的热情参与和精彩表现给予了本次比赛活力和竞争力。
最后我们向本次比赛的冠军送以热烈的祝贺。

后续我们还将举办赛后直播活动和线下总结颁奖活动，敬请期待。

