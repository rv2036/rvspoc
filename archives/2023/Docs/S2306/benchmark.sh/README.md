# 一点说明

主要做了在进行 benchmark 之前必要的一些准备工作，以及相关修复工作，
详细见 [run.sh](./run.sh) 内几个 prepare_* 函数的说明。

## 识别的环境变量

- `NODE_BENCHMARK_BIN`
- `NODE_BENCHMARK_OUTDIR`
- `NODE_BENCHMARK_SRCDIR`
- `NODE_BENCHMARK_CATEGORIES_FILTER`
- `NODE_BENCHMARK_CATEGORIES_EXCLUDE`

详见 [var.sh](./var.sh) 文件。

## 最快速的开始方式

直接在有编译好二进制的 nodejs 源码目录下运行：

```bash
/path/to/this/path/run.sh
```

## 也可以指定一些变量后运行

```bash
env NODE_BENCHMARK_BIN=/path/to/bin/node NODE_BENCHMARK_OUTDIR=/path/to/node-benchmark/out/dir /path/to/this/path/run.sh
```

等等。

此脚本只是一个参考，不够完善。
