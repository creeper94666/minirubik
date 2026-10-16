# CA2026 From solver2 to an Optimized RV32I Cube Solver

## 錄製方式

以下為刪減約 30% 英文口說的精簡版，保留原分段時間作為示範配置；文字縮短後須靠實際程式追蹤與操作確認影片至少 15 分鐘。

時間配置：原始問題 2 分鐘、solver2 原理 4 分鐘、solver7 的 C 改善 6 分鐘、組語改善 3 分鐘、演算法改善 3 分鐘，再追加 solve 邊界回傳最佳化 3 分鐘，合計約 21 分鐘。檔名保留原名。

以下英文可作為口說草稿，中文只供錄影準備。畫面追蹤與操作算在每段時間內；請先排練，確認成片至少 15 分鐘。姓名與 AI disclosure 須依實際情況填寫。不要把既有 AI-executed 量測說成自己的獨立量測。

版本名稱務必區分：`solver2.c` 是初期搜尋實作；`solver7.c` 是 C 改善的比較終點；`solver7_optimization.s` 是組語最佳化版本；`solver7_search.c` 提供最後新增的搜尋剪枝與 inverse bound。最後的組語版本整合兩類改善。

全片英文、本人錄音且出鏡、有視覺輔助。YouTube 標題包含 CA2026，可見度為 Unlisted 或 Public，於 2026/10/18 23:59 GMT+8 前提交影片連結；已提交表單者重新提交含連結版本。

## Part 1 Original problem｜0:00–2:00

### 畫面

本人出鏡，顯示標題。再切到比較圖：完整 BFS → 大型 queue 與解答表；target 限制 → 128 KiB、RV32I、指令門檻。

### English script

Hello, my name is [your name]. I will explain how solver2 developed into an optimized RV32I cube solver, focusing on performance and shortest-solution correctness.

The original program builds a complete BFS table over 3,674,160 legal states. Queries are fast afterward, but preprocessing requires 18,405,414 bytes: about 14.7 million for the queue and 3.7 million for the move table. The target allows only 131,072 bytes.

Building the table also executes millions of state expansions. Ripes simulates these instructions, and its sparse memory representation increases host memory usage.

RV32I has no multiplication or division instructions. Repeated ranking, copying, and generic move execution therefore become important costs.

The solution is to store smaller abstract distance tables and perform the actual search on the target. This reduces storage while preserving optimality.

The key distinction is between preprocessing a complete answer database and storing partial information. The abstract tables support decisions during search rather than replacing the search.

### 畫面操作

圈出 queue 與 full-state table，然後切換成「abstract tables + target search」。不要花時間念完整 baseline 配置。若提 host/guest memory ratio，只顯示實際紀錄，不新增未量測數字。

## Part 2 How solver2 solves the problem｜2:00–6:00

### 2A State and lower bounds｜2:00–3:30

畫面：`state_t`、九種 move、兩張抽象表。solver2 保留 incorrect-cubie 下界，不能說它只用 hp/ho。

```c
typedef struct {
    uint8_t p[7], o[7];
} state_t;
```

### English script

Solver2 fixes one corner and stores seven corners. The p array records cubie identifiers from zero to six; o records orientations from zero to two.

The orientation sum is zero modulo three, so only six orientations are independent. The state count is seven factorial times three to the sixth power.

The nine moves are the three turn amounts for R, B, and D. Under the half-turn metric, each costs one step.

Solver2 stores 5,040 permutation distances and 729 orientation distances, totaling 5,769 bytes. Each abstraction ignores one requirement, so its exact distance is a lower bound on a complete solution.

It also counts incorrect corners. Since one move affects at most four corners, dividing that count by four and rounding up gives another lower bound.

The heuristic takes the maximum, never the sum: one move can improve several components.

### 2B Iterative search｜3:30–5:15

畫面：`solve()` 三層迴圈，旁邊畫 states/moves path。使用控制流程示意，不冒稱實際輸入 trace。

### English script

The search is non-recursive IDA-star. The outer loop increases the depth limit from the initial heuristic to eleven.

Within each limit, explicit arrays implement depth-first search. States stores each path state; moves records the last attempted move at each depth.

The inner loop constructs candidates and rejects them when the new depth plus the heuristic exceeds the limit.

On descent, the child's move cursor resets. On backtracking, the parent state and cursor remain available, so search continues with the next untried move.

Consecutive same-face moves are skipped because they combine or cancel.

Each iteration is finite. Admissible bounds and shortest-path-preserving pruning retain a shortest solution, so the first successful limit is optimal.

For example, a candidate at depth five with a lower bound of four cannot fit a limit of eight. Rejecting it cannot remove a valid eight-step solution.

### 必做追蹤｜約 30–40 秒

指認 `moves[depth] + 1`、進入 child 時清零、回父層不清零。畫一個 `g=5, h=4, limit=8` 節點，說明拒絕原因。展示父層保存，因此不用逆轉 move。

### 2C Remaining limitations｜5:15–6:00

### English script

Solver2 removes the large full-state table, but still builds abstract distances at runtime through repeated edge relaxation until convergence.

During search, it repeatedly ranks permutations, passes structures by value, and implements longer turns through repeated quarter turns. It also depends on standard C facilities.

Solver7 addresses these remaining costs and target dependencies.

## Part 3 Improvements from solver2 to solver7｜6:00–12:00

此段只比較起點與最後保留的技術，不介紹 solver5 transition tables、零值編碼或順序列舉實驗。

### 3A Pointer-based state updates｜6:00–7:15

畫面：兩版 `apply_move` signatures 與資料搬移圖。

```c
/* solver2 */
static state_t apply_move(state_t state, uint8_t move);

/* solver7 */
static void apply_move(const state_t *src, state_t *dst,
                       uint8_t face, uint8_t turns);
```

### English script

Solver2 passes and returns fourteen-byte state structures by value. Earlier target builds generated repeated copies, including memcpy calls.

Solver7 passes separate source and destination pointers. The move function writes directly to the supplied destination, removing unnecessary transfers around the operation.

Some copies remain necessary, such as saving the initial state. Source and destination must stay distinct: overwriting the source could destroy data needed later.

This distinction matters when reading optimized assembly: a C structure assignment can generate memory traffic even when the source never explicitly calls a copying function.

### 追蹤

在 `apply_move` 指認一次 source read 與 destination write，說明 state 共 14 bytes。

### 3B Direct move compositions｜7:15–8:30

畫面：solver2 重複 quarter_turn；solver7 的 `move_source[3][3][7]` 與 `move_twist`。

### English script

Solver2 performs one, two, or three quarter turns, repeatedly traversing the state.

Solver7 stores composed mappings for all nine moves. Each move reads and writes the seven corners in one pass. The source and twist tables total 126 bytes.

Each destination receives its selected cubie and adjusted orientation. Since the orientation sum is at most four, one conditional subtraction replaces modulo-three division.

This C version still uses a seven-corner loop. Removing that loop is a separate assembly optimization.

### 追蹤

選 R2，展示它直接使用 half-turn mapping，不呼叫 quarter_turn 兩次。追蹤兩個 destination。

### 3C Host-generated direct distance tables｜8:30–10:30

畫面：solver2 `permutation_index` 的 nested loops → solver7 六維 lookup。標示 compact rank 與 direct-table index 差別。

```c
perm_dist[p[0]][p[1]][p[2]][p[3]][p[4]][p[5]]
orient_dist[o[0]][o[1]][o[2]][o[3]][o[4]][o[5]]
```

### English script

Solver7 replaces runtime table construction with host-generated read-only distances. This is permitted precomputation: the solution search still runs on the target.

Solver2 uses Lehmer ranking, counting smaller cubies to the right. Repeating those comparisons makes heuristic evaluation expensive.

Solver7 directly indexes the tables using six permutation values and six orientations. For a valid permutation, the seventh cubie is determined.

The permutation table occupies seven to the sixth power bytes, or 117,649. Only 5,040 tuples are legal permutations; the remaining slots are unused. The orientation table adds 729 bytes.

This trades storage for faster lookup while staying within budget. It eliminates ranking comparisons, but still requires address arithmetic. Horner indexing later reduces that assembly cost.

The larger table is acceptable because the removed full-state queue and answer table free the memory budget. Invalid permutation tuples are never queried after input validation.

### 追蹤｜約 40–50 秒

並排顯示 Lehmer 比較與六維 lookup；圈出「第七個值可推得」。標示 `117649+729=118378` 是兩張距離表本身，`118708` 才是基本 solver7 完整 static data，避免混用。

### 3D Remove weak work and support the target｜10:30–12:00

畫面：solver2 heuristic → solver7 `max(hp,ho)`；startup 與 ecall 小片段；基本 solver7 結果。

### English script

Solver7 removes the incorrect-cubie loop and keeps max of permutation and orientation distance. The bound becomes weaker for only twelve legal states. Cheaper evaluation can outweigh extra search, but measurement is necessary.

The program is freestanding: embedded input, custom startup, and Ripes environment calls replace standard-library dependencies. Startup initializes the stack and clears BSS.

Compiled solver7 uses 53,779,947 instructions for the required input and 118,708 bytes of static data. Memory fits, but instructions still exceed fifty million.

The program replays its returned moves before success. Replay confirms the path solves the cube; optimality additionally requires the search argument and reference-distance checks.

### 追蹤

指認 `_start` 的 stack/BSS setup 與 `output_char` 的 ecall。背景時間不足時不必逐條解釋 startup，保留時間展示結果。

## Part 4 Improving the assembly｜12:00–15:00

### 4A Specialized moves and Horner indexing｜12:00–13:30

畫面：一個專用 move body；Horner 公式及實際 `slli/sub/add`。

```text
index = index * radix + digit
x*7 = (x<<3)-x
x*3 = (x<<1)+x
```

### English script

Assembly optimization first reduces work per candidate.

Nine specialized move bodies use constant source offsets and orientation adjustments, removing generic table reads and loop control. The trade-off is larger code.

Horner indexing builds each table address one digit at a time. Multiplication by seven becomes shift-and-subtract; multiplication by three becomes shift-and-add. This is direct-table indexing, not Lehmer ranking.

The recorded Horner comparison saves twenty-four instructions per hot-path evaluation. Specialized moves reduce the required-input count to 40,549,573; Horner then reduces it to 34,934,509.

For the pipeline demonstration, I will identify the actual load address, destination register, ALU result, and store destination, rather than infer execution from C alone.

### 追蹤｜約 30–40 秒

指出一組 load/store 與一組 `slli/sub`。在五級 pipeline 畫面指認：load 的 memory result 寫回 register；ALU instruction 選 ALU result；store 改 memory、不寫 destination register。使用實際畫面數值，不只念抽象敘述。

### 4B Skip unnecessary work｜13:30–15:00

畫面：permutation lookup 後的 branch、parent/child slot 圖、累積結果。

### English script

The assembly checks permutation distance first. If it exceeds the remaining budget, orientation cannot rescue the candidate, so its calculation is skipped. The C heuristic evaluates both forward distances.

Candidates are written directly into the next depth's slot. Rejected children can be overwritten; accepted children need no additional copy. The parent remains intact.

Cleanup removes obsolete table setup, redundant spills and reloads, and unused counter updates, while preserving live registers.

These cumulative changes reduce the required input to 25,813,248 instructions. Another hard input still takes 70,613,418, so passing one case does not establish worst-case compliance.

### 追蹤

用游標指出 orientation block 被跳過的位置。畫 parent/child slot，說明可覆寫 child，但不可覆寫 parent 或 saved registers。不要把所有 register spills 說成可刪除。

## Part 5 Improving the search algorithm｜15:00–18:00

### 5A Equivalent sequences and cached masks｜15:00–16:15

畫面：等價序列與 `forbidden[depth]` bit mask。開啟 `solver7_search.c`。

```text
R R = R2
R R' = identity
B2 R2 B2 = R2 B2 R2
```

### English script

The next changes reduce candidate counts.

A generated table rejects suffixes of up to five moves with shorter or lexicographically earlier equivalents. A shorter replacement excludes the original from shortest paths. Equal-length replacements retain a canonical representative. Equivalent transformations work after any prefix.

A nine-bit forbidden mask is computed once per node and reused while trying moves, including after backtracking.

The mask is checked before apply_move and heuristic evaluation, avoiding their entire cost for forbidden moves. The table adds 7,371 bytes.

The same-face rule is included in the cached mask. This avoids repeating separate face checks and suffix-table calculations for every attempted move at the same node.

### 追蹤

指認 bit test 與進入 child 時計算 mask 的位置。強調「先剪枝，再生成 candidate」。

### 5B Inverse orientation bound｜16:15–17:15

畫面：inverse scatter 公式與 early-return 順序。

```text
inverse_orientation[p[i]] = (-o[i]) mod 3
h = max(hp, ho, hi)
```

### English script

A cube transformation and its inverse have equal solution distance: reverse a solution sequence and invert each move without changing its length.

The solver scatters negated orientations to positions selected by the permutation, then reuses the existing orientation distance table. No extra pattern database is needed.

This inverse projection can reveal a stronger lower bound. It is evaluated only after the forward bounds pass, trading extra work on survivors for fewer explored subtrees.

### 追蹤

示意 `p[i]=4, o[i]=1 → inverse_orientation[4]=2`。指出 forward rejection → inverse lookup → final rejection 的順序。

### 5C Final result and closing｜17:15–18:00

畫面：結果表，旁邊顯示本資料夾 ELF 的 Ripes console 解答。此精簡包不包含 LED build。

| Build | Required input | Other hard input |
|---|---:|---:|
| Original solver7 compiled C | 53,779,947 | 147,099,504 |
| Search compiled C | 31,343,837 | 79,635,246 |
| Earlier optimized assembly | 25,813,248 | 70,613,418 |
| Combined optimized assembly | 15,147,934 | 38,543,830 |

Inputs：`21345671111111`、`54721631111111`。數字為 retired instructions；RV32_ISS、無 extensions、無 renderer，包含 startup/search/replay/output/exit。

### English script

The combined assembly uses 15,147,934 instructions for the required input and 126,079 bytes of static data.

Recorded validation includes exhaustive host optimality and replay for the C search, plus all 2,644 distance-eleven inputs for the pinned assembly ELF. The target maximum is 38,543,830 instructions.

These results do not imply all-state target or GUI validation.

[Disclose actual AI assistance and personally reproduced work.]

Finally, I will show an additional optimization of the assembly search controller.

## Part 6 Customized assembly solve control｜18:00–21:00

### 6A Remove the repeated goal scan｜18:00–19:00

畫面：從舊版 `.L8` 檢查，切到新版 `.L69` acceptance block；使用 README 的歷史說明比較。先前 fixed-offset 展開已被本次改進取代。

### English script

The final optimization removes the repeated goal scan from the search controller.

Every accepted candidate satisfies depth plus each forward bound no greater than the limit. At the boundary, depth equals the limit, so both abstract distances must be zero. With valid cube states and exact tables, this means the cube is solved.

The search starts at an admissible lower bound and increases limits one by one. A shorter solution would have been found earlier. The public wrapper separately handles an already-solved input.

### 6B Return during candidate acceptance｜19:00–20:00

```asm
.L69:
    add a5,s3,a5
    sw t0,0(a5)
    beq s10,s2,.Lsolve_found
# Interior child setup follows.
```

### English script

The assembly saves the selected move, compares the new depth with the limit, and returns through the existing solution-copy path when they match.

Interior children continue searching. Boundary children skip child-mask setup. Removing the node scan also removes unnecessary state-address arithmetic and the old depth-limit check.

This preserves move order and bounds. It relies on exact abstract tables and the current threshold schedule; an arbitrary heuristic returning zero would not be enough.

### 示範

指認 s10=new depth、s2=limit、t0=move。用 depth=limit 與 depth<limit 兩種情況追蹤分支，再展示 public wrapper 與最後 replay。

### 6C Measurement and scope｜20:00–21:00

| Input | Previous solve | Boundary return |
|---|---:|---:|
| `21345671111111` | 15,092,396 | 14,836,245 |
| `54721631111111` | 38,398,165 | 37,730,599 |

### English script

Paired RV32_ISS measurements show another reduction of about 1.7 percent. The required input now uses 14,836,245 instructions; the other hard input uses 37,730,599. Text shrinks by 144 bytes, while static data stays unchanged.

The acceptance test, existing block tests, thirty-one target regression cases, and twelve samples covering exact distances zero through eleven all pass. Paths replay correctly.

The full 2,644-case target sweep has not been repeated for this binary. These are AI-assisted development results and require accurate disclosure.

The improvement comes from removing duplicate work using a proven search invariant. Thank you for watching.

## 準備素材

1. 一張原始 BFS／target 限制比較圖。
2. solver2 搜尋樹與三層迴圈截圖。
3. solver2／solver7 `apply_move` 與 heuristic 並排畫面。
4. 專用 move 與 Horner 的短組語片段。
5. parent/child slot、九位 forbidden mask、inverse scatter 三張圖。
6. Ripes solved、one-move、distance-11 的結果畫面；修改 embedded input 後重新建置。
7. 一小段使用本資料夾 ELF 的 pipeline trace。

錄影時全程保留 webcam 小窗即可。長程搜尋先準備結果與錄影，避免等待耗盡段落時間。英文草稿與示範合計的實際時長須自行排練確認；結尾 disclosure 應具體而真實，不能直接念方括號提示。

## 程式檔案與量測來源

- [solver2.c](solver2.c)
- [solver7.c](solver7.c)與[基本 solver7 紀錄](README.md#量測來源)
- [solver7_search.c](solver7_search.c)與[search 紀錄](README.md#量測來源)
- [solver7_optimization.s](solver7_optimization.s)
- [Horner measurements](README.md#量測來源)
- [Early rejection and direct writes](README.md#量測來源)
- [Combined assembly measurements](README.md#量測來源)
- [Current target validation](README.md#量測來源)
- `Ca.txt.docx`：既有歷程参考，未放入此精簡程式資料夾。

原五段於 2026-10-15 依既有程式與紀錄整理；新增第六段引用本次新執行的 solve-control 前後量測。未建立過去的提交或修訂紀錄。

2026-10-17 更新：第六段已改為 acceptance-time goal detection，取代先前 fixed-offset goal scan。
