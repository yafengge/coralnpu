
bazel-out/k8-fastbuild-ST-dd8dc713f32d/bin/examples/coralnpu_v2_hello_world_add_floats.elf:     file format elf32-littleriscv
# 目标：32 位小端 RISC-V ELF，可在 CoreMini AXI 仿真器上运行。


Disassembly of section .text:

00000000 <_start>:
# 入口：设置栈/全局指针，清零通用寄存器，然后清 BSS、调用构造函数、设定 mtvec，再跳 main。
  0:	00018117          	auipc	sp,0x18                          # 基于当前 PC 推导栈基址高位  #S: AUIPC (Add Upper Immediate to PC) 取 PC 相对高 20 位并加到 PC，用于形成栈基址；sp=栈指针
  4:	00010113          	mv	sp,sp                               # 保持 sp（配合上条形成绝对栈地址）  #S: MV (addi rd,rs,0) 拷贝寄存器，保持 sp
  8:	00010197          	auipc	gp,0x10                          # 取 gp 基址  #S: AUIPC 取 PC 相对高位，gp=全局指针指向小数据区
  c:	7f818193          	addi	gp,gp,2040 # 10800 <__global_pointer$> # 调整 gp 指向小数据区  #S: ADDI (Add Immediate) 寄存器加有符号立即数，形成绝对 gp
  10:	00000213          	li	tp,0                               # 清零 tp  #S: LI (Load Immediate pseudo) 装立即数到寄存器
  14:	00000313          	li	t1,0                               # 清零 t1
  18:	00000393          	li	t2,0                               # 清零 t2
  1c:	00000413          	li	s0,0                               # 清零 s0
  20:	00000493          	li	s1,0                               # 清零 s1
  24:	00000593          	li	a1,0                               # 清零 a1
  28:	00000613          	li	a2,0                               # 清零 a2
  2c:	00000693          	li	a3,0                               # 清零 a3
  30:	00000713          	li	a4,0                               # 清零 a4
  34:	00000793          	li	a5,0                               # 清零 a5
  38:	00000813          	li	a6,0                               # 清零 a6
  3c:	00000893          	li	a7,0                               # 清零 a7
  40:	00000913          	li	s2,0                               # 清零 s2
  44:	00000993          	li	s3,0                               # 清零 s3
  48:	00000a13          	li	s4,0                               # 清零 s4
  4c:	00000a93          	li	s5,0                               # 清零 s5
  50:	00000b13          	li	s6,0                               # 清零 s6
  54:	00000b93          	li	s7,0                               # 清零 s7
  58:	00000c13          	li	s8,0                               # 清零 s8
  5c:	00000c93          	li	s9,0                               # 清零 s9
  60:	00000d13          	li	s10,0                              # 清零 s10
  64:	00000d93          	li	s11,0                              # 清零 s11
  68:	00000e13          	li	t3,0                               # 清零 t3
  6c:	00000e93          	li	t4,0                               # 清零 t4
  70:	00000f13          	li	t5,0                               # 清零 t5
  74:	00000f93          	li	t6,0                               # 清零 t6
  78:	87018513          	addi	a0,gp,-1936 # 10070 <__bss_end>   # a0=BSS（全局变量地址段） 起点  #S: ADDI (Add Immediate) 以 gp 为基址计算 BSS 起始
  7c:	87018593          	addi	a1,gp,-1936 # 10070 <__bss_end>   # a1=BSS 终点（此例长度 0）
  80:	0c0000ef          	jal	ra,140 <crt_section_clear>         # 调用清零 BSS  #S: JAL (Jump and Link) 保存返回地址到 rd 然后跳转
  84:	1b000413          	li	s0,432                              # s0=init_array 起始  #S: LI 载入 init_array 起点（后续连续 li 不再重复）
  88:	1b000493          	li	s1,432                              # s1=init_array 结束
  8c:	00947a63          	bgeu	s0,s1,a0 <init_array_loop_end>    # 若无构造函数直接跳过  #S: BGEU (Branch if Greater or Equal Unsigned) 无符号比较分支

00000090 <init_array_loop>:
# 遍历 .init_array，逐个调用全局/静态对象的构造函数（此示例为空列表）。
  90:	00042283          	lw	t0,0(s0)                            # 取函数指针  #S: LW (Load Word) 从 rs1+imm 地址取 32 位写入 rd
  94:	000280e7          	jalr	t0                                # 调用构造函数  #S: JALR (Jump and Link Register) 寄存器间接跳转并保存返回地址，目标低位清零
  98:	00440413          	addi	s0,s0,4                           # 指向下一个条目  #S: ADDI (Add Immediate) 指针前移
  9c:	fe946ae3          	bltu	s0,s1,90 <init_array_loop>        # 还未到末尾则继续  #S: BLTU (Branch if Less Than Unsigned) 无符号比较分支

000000a0 <init_array_loop_end>:
# 设置异常向量 mtvec，给 _ret 写入哨兵，跳转执行 main，返回后把 main 的返回值写回 _ret。
  a0:	00000297          	auipc	t0,0x0                             # t0 = 当前 PC 基址  #S: AUIPC (Add Upper Immediate to PC) 取 PC 相对高 20 位，为异常向量做基址
  a4:	09028293          	addi	t0,t0,144 # 130 <coralnpu_exception_handler> # t0=异常入口  #S: ADDI 形成异常处理函数绝对地址
  a8:	30529073          	csrw	mtvec,t0                           # 设置 mtvec  #S: CSRW (CSR Write) 写特权寄存器 mtvec=陷阱入口基址
  ac:	00010297          	auipc	t0,0x10                            # 取 _ret 基址高位  #S: AUIPC 取返回值存放地址高位
  b0:	fb428293          	addi	t0,t0,-76 # 10060 <_ret>            # t0 指向 _ret
  b4:	0badd537          	lui	a0,0xbadd                           # a0 高 20 位 = 0xbadd  #S: LUI (Load Upper Immediate) 装载高 20 位
  b8:	00d50513          	addi	a0,a0,13 # badd00d <__stack_end__+0xbac500d> # a0=0xbadd00d 哨兵
  bc:	00a2a023          	sw	a0,0(t0)                            # _ret 写入哨兵  #S: SW (Store Word) 写 32 位到内存
  c0:	00000513          	li	a0,0                                 # main 参数 a0=0  #S: LI 装载 main 参数
  c4:	00000593          	li	a1,0                                 # main 参数 a1=0
  c8:	00000097          	auipc	ra,0x0                            # 取 main 基址  #S: AUIPC 取 main 相对地址
  cc:	02c08093          	addi	ra,ra,44 # f4 <main>                 # ra=main 绝对地址
  d0:	000080e7          	jalr	ra                                 # 跳转执行 main  #S: JALR (Jump and Link Register) 间接跳转并写返回地址
  d4:	00010297          	auipc	t0,0x10                            # main 返回后再次取 _ret 基址
  d8:	f8c28293          	addi	t0,t0,-116 # 10060 <_ret>
  dc:	00a2a023          	sw	a0,0(t0)                            # 保存 main 返回值
  e0:	00050663          	beqz	a0,ec <success>                     # 返回 0 则跳 success  #S: BEQZ (Branch if Equal to Zero pseudo) 条件分支

000000e4 <failure>:
# main 返回非 0：走 failure 分支，触发 ebreak 便于调试，然后进入死循环。
  e4:	00100073          	ebreak                                   # 触发断点  #S: EBREAK (Environment Break) 调试断点陷入
  e8:	0080006f          	j	f0 <loop>                             # 跳到死循环  #S: J (Jump pseudo jal x0,label) 无条件跳转

000000ec <success>:
# main 返回 0：发出自定义 0x80000073 指令，通常作为退出/停机信号。
  ec:	08000073          	0x8000073                                # 自定义退出/停机指令  #S: Custom instruction (平台定义) 作为退出/停机信号

000000f0 <loop>:
# 无论成功或失败最终都停在死循环，等待仿真器或调试器处理。
  f0:	0000006f          	j	f0 <loop>                             # 永久自旋  #S: J (Jump pseudo jal x0,label) 无条件跳转

000000f4 <main>:
float input1[8] __attribute__((section(".data")));
float input2[8] __attribute__((section(".data")));
float output[8] __attribute__((section(".data")));

int main() {
# 主循环：逐元素加载 input1[i] 与 input2[i]，执行单精度浮点加法并写回 output[i]，共 8 个元素。
  for (int i = 0; i < 8; i++) {
  f4:	00010797          	auipc	a5,0x10                            # a5 基址 -> input1  #S: AUIPC (Add Upper Immediate to PC) 取 PC 相对高位作为数据区基址
  f8:	f0c78793           	addi	a5,a5,-244 # 10000 <input1>        # a5 指向 input1[0]  #S: ADDI (Add Immediate) 形成 input1 起始地址
  fc:	82018693           	addi	a3,gp,-2016 # 10020 <input2>        # a3 指向 input2[0]
100:	84018713           	addi	a4,gp,-1984 # 10040 <output>        # a4 指向 output[0]
104:	00068613           	mv	a2,a3                                 # a2 保存 input2 起始，用作终止比较  #S: MV (addi rd,rs,0) 复制寄存器
    output[i] = input1[i]  +  input2[i];
108:	0007a787           	flw	fa5,0(a5)                            # 载入 input1[i]  #S: FLW (Floating Load Word) 从内存取 32 位到浮点寄存器
10c:	0006a707           	flw	fa4,0(a3)                            # 载入 input2[i]
110:	00e7f7d3           	fadd.s	fa5,fa5,fa4                      # 单精度相加  #S: FADD.S (Floating Add Single) 单精度浮点加法
114:	00f72027           	fsw	fa5,0(a4)                            # 写回 output[i]  #S: FSW (Floating Store Word) 将浮点寄存器写回内存
  for (int i = 0; i < 8; i++) {
118:	00478793           	addi	a5,a5,4                             # input1 指针前移  #S: ADDI 指针递增
11c:	00468693           	addi	a3,a3,4                             # input2 指针前移
120:	00470713           	addi	a4,a4,4                             # output 指针前移
124:	fec792e3           	bne	a5,a2,108 <main+0x14>                # 循环 8 次后退出  #S: BNE (Branch if Not Equal) 条件分支
  }
  return 0;
}
 128:	00000513          	li	a0,0                                 # 返回 0
 12c:	00008067            	ret                                     # 返回到 _start 调度  #S: RET (jalr x0,ra,0 pseudo) 返回到 ra
00000130 <coralnpu_exception_handler>:
# 弱符号的异常处理：触发 ebreak 并自旋，方便在调试环境捕获。
 134:	0000006f           	j	134 <coralnpu_exception_handler+0x4>  # 自旋等待调试  #S: J (Jump pseudo jal x0,label) 无条件跳转
// See the License for the specific language governing permissions and
// limitations under the License.

extern "C" {
void __attribute__((weak)) coralnpu_exception_handler() {
  asm volatile("ebreak");
 130:	00100073           	ebreak                                   # 触发断点  #S: EBREAK (Environment Break) 调试断点陷入
  while (1) {}
 134:	0000006f           	j	134 <coralnpu_exception_handler+0x4>  # 自旋等待调试  #S: J (Jump pseudo jal x0,label) 无条件跳转
	...

Disassembly of section .crt:

00000140 <crt_section_clear>:
# 运行时辅助：检查地址合法与字对齐，逐字写 0 清空 [start, end) 段，异常则 ebreak。
  0000016c <crt_section_copy>:
   16c:	02b57c63             	bgeu	a0,a1,1a4 <crt_section_copy+0x38> # start>=end 直接返回/报错  #S: BGEU (Branch if Greater or Equal Unsigned) 起止合法性检查

    // Check that start, end and src are word aligned.
    or   t0, a0, a1
   170:	00b562b3            	or	t0,a0,a1                             # 对齐检查 part1  #S: OR 合并地址低位判断对齐
    or   t0, t0, a2
   174:	00c2e2b3            	or	t0,t0,a2                             # 对齐检查 part2（含 src）
    andi t0, t0, 0x3
   178:	0032f293            	andi	t0,t0,3                            # 低 2 位非 0 表示未对齐  #S: ANDI (AND Immediate) 提取低位检查对齐
    bnez t0, .L_copy_error
   17c:	02029863            	bnez	t0,1ac <crt_section_copy+0x40>     # 未对齐直接报错  #S: BNEZ (Branch if Not Equal Zero pseudo) 非零跳错误
    //        +-------------+
    //        |             |
    //      start          end
    //
    // TODO: disallow all overlap since it indicates API misuse?
    sub  t0, a0, a2           // (start - src) mod 2**32
   180:	40c502b3            	sub	t0,a0,a2                           # 差值 (start - src)  #S: SUB (Subtract) 寄存器减法
    sub  t1, a1, a0           // end - start
  184:	40a58333            	sub	t1,a1,a0                           # 区间长度  #S: SUB (Subtract) 计算区间长度
    bltu t0, t1, .L_copy_error
   188:	0262e263            	bltu	t0,t1,1ac <crt_section_copy+0x40> # 重叠方向错误则报错  #S: BLTU (Branch if Less Than Unsigned) 检查区间重叠

  .L_copy_loop:
    // Copy data from src into section word-by-word.
    // TODO: unroll
    lw   t0, 0(a2)
   18c:	00062283            	lw	t0,0(a2)                           # 读源字  #S: LW (Load Word) 从内存读 32 位到 rd
    addi a2, a2, 4
    190:	00460613            	addi	a2,a2,4                           # 源指针前移  #S: ADDI (Add Immediate) 指针按字宽递增
    sw   t0, 0(a0)
   194:	00552023            	sw	t0,0(a0)                           # 写目标字  #S: SW (Store Word) 将寄存器写回内存
    addi a0, a0, 4
    198:	00450513            	addi	a0,a0,4                           # 目的指针前移
    bltu a0, a1, .L_copy_loop
   19c:	feb568e3            	bltu	a0,a1,18c <crt_section_copy+0x20> # 未到 end 继续复制  #S: BLTU (Branch if Less Than Unsigned) 循环控制
    ret
    1a0:	00008067            	ret                                   #S: RET (Return pseudo, jalr x0, ra, 0) 从子程序返回
    1a4:	00b51463            	bne	a0,a1,1ac <crt_section_copy+0x40> # start!=end 说明参数非法  #S: BNE (Branch if Not Equal) 长度不为 0 则报错
   1a8:	00008067            	ret
  .L_copy_error:
    ebreak
   1ac:	00100073            	ebreak                                   # 复制参数错误  #S: EBREAK (Environment Break) 参数错误陷入
