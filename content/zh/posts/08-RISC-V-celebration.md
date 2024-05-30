+++
title = '第一届 RISC-V 软件移植及优化锦标赛欢庆会暨第二届启动仪式圆满落幕'
date = 2024-05-29T09:30:00+08:00
slug = '08'
toc = false
summary = '5 月 26 日，第一届 RISC-V 软件移植及优化锦标赛欢庆会暨第二届启动仪式于上海外滩成功举办。现场氛围融洽热烈，线上参与者也踊跃互动，共同见证了这一精彩时刻。主办方上海苦芽科技有限公司代表，同时也是锦标赛主席和评委的李程先生在会议上致辞。他首先对第一届 RISC-V 软件移植及优化锦标赛进行了全面的总结：经过长达三个月的激烈角逐，本次锦标赛共吸引了 101 组队伍踊跃参与，收到了 20 个高质量的提交作品。最终，经过严格评审，诞生了 10 组冠军队伍。李程特别感谢算能对第一届锦标赛给予的大力支持。作为主办方之一的算能为本届锦标赛提供了实验平台，由于开发环境友好，此平台也成为选手们毕业设计的首选平台，此外冠军选手的奖金也由算能赞助。再次表示衷心的感谢，希望继续保持紧密合作。'
+++

5 月 26 日，第一届 RISC-V 软件移植及优化锦标赛欢庆会暨第二届启动仪式于上海外滩成功举办。现场氛围融洽热烈，线上参与者也踊跃互动，共同见证了这一精彩时刻。

![](/images/posts/08-all.webp)

<style>
img.fw-icon {
  width: 1em;
  height: 1em;
  display: inline-block !important;
  padding: 0 0.2em;
  top: 0.1em;
}
p.this-wide-top-margin {
  margin-top: 5em;
}
p.this-center {
  text-align: center;
}
p.this-bold {
  font-weight: bold;
}
</style>

<p class="this-wide-top-margin this-center this-bold"><img class="fw-icon" src="/images/posts/08-icon.webp"/>活动内容回顾<img class="fw-icon" src="/images/posts/08-icon.webp"/></p>

## 主办方致辞

![](/images/posts/08-1.webp)

主办方上海苦芽科技有限公司代表，同时也是锦标赛主席和评委的李程先生在会议上致辞。他首先对第一届 RISC-V 软件移植及优化锦标赛进行了全面的总结：经过长达三个月的激烈角逐，本次锦标赛共吸引了 101 组队伍踊跃参与，收到了 20 个高质量的提交作品。最终，经过严格评审，诞生了 10 组冠军队伍。

李程特别感谢算能对第一届锦标赛给予的大力支持。作为主办方之一的算能为本届锦标赛提供了实验平台，由于开发环境友好，此平台也成为选手们毕业设计的首选平台，此外冠军选手的奖金也由算能赞助。再次表示衷心的感谢，希望继续保持紧密合作。

随后，李程对即将举办的第二届锦标赛进行了详细的介绍。第二届赛事由上海苦芽科技有限公司主办，并荣幸地得到了 RISC-V 中国社区 (CNRV) 的鼎力协办。赛事的官方网站为 rvspoc.org。参赛者可通过该网站及“苦芽科技”公众号，获取更多关于赛事的详细信息、报名方式以及最新的赛程安排。

## 嘉宾分享：RuyiSDK 包管理器：介绍与展望

![](/images/posts/08-2.webp)

RuyiSDK 包管理器负责人带来了 RuyiSDK 核心组件——包管理器的全面介绍及其工作进展。他不仅剖析了 RuyiSDK 包管理器的核心功能和优势，还在现场演示了 RuyiSDK 的多项关键功能，展示了其在软件开发中的高效性和便捷性。不仅增强了大家对 RuyiSDK 包管理器的理解，也激发了开发者们对于未来应用的无限期待。

<p class="this-wide-top-margin this-center this-bold"><img class="fw-icon" src="/images/posts/08-icon.webp"/>冠军队伍线上分享<img class="fw-icon" src="/images/posts/08-icon.webp"/></p>

## Box64 for RV64 一周年回顾 --谭雄川

![](/images/posts/08-3.webp)

首届锦标赛冠军之一的谭雄川先生，带来了 Box64 for RV64 一周年的精彩回顾。他首先深入阐释了 Box64 的实质，这是一款功能强大的二进制翻译器，能够在 ARM/RISC-V/LoongArch Linux 设备上无缝运行 x86-64 Linux 程序，打破了平台间的限制。接着，谭先生详细解读了 Box64 的工作原理，让听众们对其技术内核有了更为清晰的认识。

此外，他还详细回顾了一周年之中的开发过程。他与多位开发者在一年间不断地完善功能、修复漏洞，进行了多次的修改与提交，测试了多种类型的 Linux 和 Windows 程序，以确保 Box64 的稳定性和兼容性。在锦标赛中，他也凭借着这份坚持与努力，适配了比赛题目中的程序，最终成功完成了题目要求，荣获了首届锦标赛的冠军。

## Milk-V Duo 移植 zephyr 分享--hlleng

![](/images/posts/08-4.webp)

另一位冠军 hlleng 带来了关于 Milk-V Duo 移植 Zephyr 的精彩分享。hlleng 首先对团队“你走线如丁似蛋”成员进行介绍。随后为大家深入解读了 Zephyr。Zephyr 是一款开源实时操作系统 (RTOS)，专为资源受限设备设计，提供一个可扩展和模块化的框架，以支持从简单嵌入式系统到复杂物联网解决方案的各种硬件架构和应用。在 GitHub 上，Zephyr 的贡献者超 2000 人，Pull requests 超 5 万个，Star 数量接近 10K。

紧接着，hlleng 详细阐述了 Zephyr 在 Milk-V Duo 平台上的适配过程。在适配过程中，hlleng 和团队解决了众多技术环节，如配置 SOC、配置 board、编写驱动、性能优化等，确保 Zephyr 在 Milk-V Duo 平台上能够发挥出最佳性能。在上个月，团队基于 Zephyr 最新的设备模型 (HWMv2) 重构了代码，并已经提交给 Zephyr upstream。


## 锦标赛主席李程为冠军代表颁奖

![](/images/posts/08-5.webp)

未到场冠军选手的获奖证书，将安排邮寄。

<p class="this-wide-top-margin this-center this-bold"><img class="fw-icon" src="/images/posts/08-icon.webp"/>惊喜环节<img class="fw-icon" src="/images/posts/08-icon.webp"/></p>

## 甲辰计划主理人吴伟先生出席并透露甲辰计划的最新成果

![](/images/posts/08-6.webp)

本次活动非常荣幸地邀请到了甲辰计划主理人以及 PLCT 实验室的创始人吴伟先生亲临现场并带来宝贵的分享。吴伟先生透露了甲辰计划的最新成果——即将正式公开的 RISC-V 初学者文档百科全书工程。这项工程将为初学者提供一个全面而深入的 RISC-V 学习资源，旨在推动 RISC-V 技术的普及与发展。

苦芽科技社区的资深顾问章翔先生将牵头负责这一看似平凡但意义重大的大型协作项目。章翔先生的专业知识和丰富经验将为项目提供有力保障，同时也会吸引更多有志之士参与，共同为 RISC-V 技术的普及和发展贡献力量。期待这一工程能够为广大 RISC-V 初学者提供全面、系统、易懂的学习资料，助力他们在 RISC-V 领域取得更大的进步。

## 圆桌讨论：RISC-V 生态构建中遇到的挑战

![](/images/posts/08-7.webp)

线上分享环节圆满结束后，紧接着进行了一场热烈而有深度的圆桌讨论，聚焦在 RISC-V 生态构建过程中所面临的种种挑战。现场氛围十分活跃，与会者纷纷踊跃发言，分享自己的观点和见解。

在讨论中，涌现出一些创新的思路。有选手为第二届锦标赛提供思路：将企业在实际生产中遇到的问题作为比赛题目。这个提议将 RISC-V 技术的研发与实际应用相结合，不仅能够为企业解决实际问题，提供技术支持，同时也能够作为一种有效的宣传方式，提升 RISC-V 技术的知名度和影响力，还可以通过解决真实问题来节省研发经费。

对此方案有感兴趣的企业组织，可以深入了解合作方式：

<p class="this-center" style="color: rgb(125, 144, 169)">第二届 「RISC-V 软件移植及优化锦标赛」筹备工作正式启动，诚邀赞助</p>

欢迎联系第二届的主办方：

<p class="this-center" style="color: rgb(0, 82, 255)">rvspoc@kubuds.cn</p>

<p class="this-wide-top-margin this-center this-bold"><img class="fw-icon" src="/images/posts/08-icon.webp"/>特别感谢<img class="fw-icon" src="/images/posts/08-icon.webp"/></p>

<p class="this-center this-bold">感谢算能对 RISC-V 软件移植及优化锦标赛的大力支持！</p>

<p class="this-center this-bold">感谢上海苦芽科技有限公司 CEO 李威威先生亲临现场，并赞助了会场和茶歇。</p>
