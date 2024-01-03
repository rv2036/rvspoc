# S2311: Baby LLaMA 2 on Duo 速度优化（儿童讲故事场景）

## 赛题演示文档

[S2311.PDF](./S2311.PDF)

## 赛题演示回放地址

TBA

## 赛题演示中一些材料

- scp2duo 函数
  ```bash
  scp2duo() {
      local DUO_IP="${DUO_IP:-192.168.88.104}"
      local D NEXT_IS_D=0
      local -a S
      for arg {
          case $arg in
              -d)
                  NEXT_IS_D=1
                  ;;
              *)
                  if [[ $NEXT_IS_D == 1 ]]; then
                      D="$arg"
                      NEXT_IS_D=0
                  else
                      S+=("$arg")
                  fi
                  ;;
          esac
      }
      : ${D:="~/"}
      set -- scp -O "${S[@]}" root@${DUO_IP}:"$D"
      echo ">>>" "$@" >&2
      "$@"
  }
  ```
- resizefs.sh 脚本：[resizefs.sh](./resizefs.sh)
  > 视频演示中遇到的
  > ```
  > open: No such file or directory while opening /dev/sdd2
  > ```
  > 这个问题，怀疑是在 fdisk 操作完成之后，在短暂的时间内实际没有同步到磁盘导致的。
  > 目前在原有脚本的基础上，增加了其间的 sync 操作，来尽量避免这个问题。
- milkvtech/milkv-duo 基础上新增的 Docker Image
  - [Dockerfile](./Dockerfile)
  - [.zshrc](./dot-zshrc)

## 回放视频最后为何把 Stories15M.bin 文件删除的原因

运行操作时，使用了 `run` 函数而非 `./run` 二进制，这个函数是我环境下的用来快速编译 c/cpp 并运行的函数，导致出现此次失误。
