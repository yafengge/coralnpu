# CoralNPU RVV MAC 阵列概览

本页补充 RVV 乘加阵列的规格、通道含义与内部结构示意，便于对照源码与仿真。

## 通道与总体规格
- 通道数量：`NUM_MUL = 2`（在 `hdl/verilog/rvv/inc/rvv_backend_define.svh` 定义）。每条通道独立取指/出队/提交，可并发执行向量 MUL/MAC uop。
- 数据宽度：`VLEN = 128` bit，LMUL 最多 8；前端据指令配置有效并行度。
- 阵列形态（单通道）：128b 输入被拆成 16 个 8b 子元素，经 4 × 4 × 4 的 mul8 网格（64 个 8 位乘法单元）并行生成 16b 乘积，后续按 EEW=8/16/32 做宽化/累加/舍入/饱和，写回 VRF。
- 每拍总乘法单元数：单通道 64 个 mul8，双通道并行等效 128 个 mul8。
- 控制与提交：`rvv_backend_mulmac` 负责从保留站出队、驱动两条通道、与 ROB 握手并处理 trap flush。

## 关键文件映射
- 通道参数与 VLEN：`hdl/verilog/rvv/inc/rvv_backend_define.svh`
- 双通道包装与握手：`hdl/verilog/rvv/design/rvv_backend_mulmac.sv`
- 单通道乘法阵列（4×4×4 mul8）：`hdl/verilog/rvv/design/rvv_backend_mul_unit.sv`
- 单通道乘加/饱和/舍入（同样 4×4×4 mul8）：`hdl/verilog/rvv/design/rvv_backend_mac_unit.sv`
- 后端顶层汇总（RS/ROB/VRF 连接）：`hdl/verilog/rvv/design/rvv_backend.sv`
- 前端 LMUL/VLEN 配置：`hdl/verilog/rvv/design/RvvFrontEnd.sv`
- 软件示例（int8×int8→int16→int32 累加 matmul）：`tests/cocotb/rvv/ml_ops/rvv_matmul.cc`

## ASCII / 矢量示意
单通道内部（乘法网格 + 宽化/累加）：
```
128b vs2 ----┐          128b vs1 ----┐
             v                      v
         [ 4 × 4 × 4 mul8 网格，共 64 个 8b×8b→16b ]
                           |
                     64×16b 乘积
                           v
                宽化 / 累加 / 舍入 / 饱和
                           v
                      写回 VRF
```

双通道并行（每拍 2×64 mul8）：
```
RS -> MAC lane0 (64×mul8) -> ROB
RS -> MAC lane1 (64×mul8) -> ROB
```

按 SEW 展开的“网格”形态（每条通道拆成 16B，再以 4×4×4 方式映射到 mul8 单元）：
```
vs2 bytes: [b15 b14 b13 b12] [b11 b10 b9 b8] [b7 b6 b5 b4] [b3 b2 b1 b0]
vs1 bytes: [a15 a14 a13 a12] [a11 a10 a9 a8] [a7 a6 a5 a4] [a3 a2 a1 a0]

  z=0           z=1           z=2           z=3         (每个 z 是 4×4 片)
┌────────┐   ┌────────┐   ┌────────┐   ┌────────┐
│mul8×16 │   │mul8×16 │   │mul8×16 │   │mul8×16 │   ← 共 64 个 mul8
└────────┘   └────────┘   └────────┘   └────────┘
     \           \            \           \
      └── 64×16b 乘积 ──> 宽化/累加/舍入 ──> VRF
```

## 运行/观测建议
- 仿真：使用 Verilator SystemC 顶层加载 ELF，结合 `--trace`/`--instr_trace` 观测 MAC 通道握手与产出。
- cocotb：运行 `rvv_matmul` 用例可在波形中看到两条通道的并行乘加；配合 VRF 写回信号验证结果。

## 波形抓取步骤（Verilator SystemC）
1) 编译仿真顶层（如已完成可跳过）：
```bash
bazel build //tests/verilator_sim:core_mini_axi_sim
```
2) 运行并打开波形：
```bash
# 生成 VCD 与指令追踪（输出在 bazel-bin/tests/verilator_sim）
bazel-bin/tests/verilator_sim/core_mini_axi_sim \
  --binary bazel-out/k8-fastbuild/bin/examples/coralnpu_v2_hello_world_add_floats.elf \
  --trace --instr_trace

# 用 gtkwave 观测（假定已安装）
gtkwave bazel-bin/tests/verilator_sim/core_mini_axi_sim.vcd &
```
3) 建议添加的信号组：
```
top.u_core_mini_axi.u_rvv_core.u_backend.u_mulmac.
  rs2mac_uop_valid[1:0]
  mac2rs_uop_ready[1:0]
  mac_stg0_vld_en[1:0]
  mac_stg0_data_en[1:0]
  mac2rob_uop_valid[1:0]
  ex2rob_data[*].rob_entry (或 wr_mul2rob)
```
4) 若关注单个通道内部产出，可展开 `u_mac0` / `u_mac1`，查看 `mac8_out_d1`、`mac_rslt_*` 与 `rs2mac_uop_valid_d1` 对齐关系。

## 备注
当前仓库未提供单独的 PDF/图片规格书，本页与源码是最新的事实标准；若需要图形化示意，可在此基础上补充。
