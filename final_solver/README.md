# 演講使用的程式與講稿

本資料夾只保留最新演講稿要指認與比較的程式，不放歷史量測目錄或 LED 示範版本。

| 檔案 | 演講用途 |
|---|---|
| solver2.c | 第 2 段：初期搜尋原理 |
| solver7.c | 第 3 段：C 改善後的基本版本 |
| solver7_search.c | 第 5 段：最新等價序列剪枝與 inverse orientation bound |
| solver7_optimization.s | 第 4、6 段：最新組語，含 acceptance-time goal return |
| solver7_optimization.elf | 在 Ripes 載入的最新執行檔 |
| solver7_tables.h | C 的距離表 |
| solver7_search_sequences.h | C 的序列剪枝表 |
| solver7_search_sequences.inc | 組語的序列剪枝表 |
| solver7.ld | 兩種 target build 使用的 linker script |
| build.sh | 建置最新組語或編譯最新 C |
| video_script.md | 約 21 分鐘演講稿 |

## 操作

在本資料夾執行：

```sh
sh build.sh
```

Ripes 載入 `solver7_optimization.elf`。此版本 renderer-off，量測使用 RV32_ISS、無 extensions；pipeline 指認可選 RV32_5S。

若要編譯最新 C 作為對照：

```sh
sh build.sh c
```

產生 `solver7_search.s` 與 `solver7_search.elf`。這是編譯器產物，不是最佳化組語，別拿它代替 `solver7_optimization.s`。

輸入在所使用 source 的 `cube_input`：改成合法的 14 字元字串，再重新 build。預設 `21345671111111`。

最新 C 與最新組語採用相同新增搜尋策略；但組語另外保留專用 move、Horner、early rejection 等改善。最後新增的邊界回傳只改在組語，沒有宣稱 C 與組語逐行相同。

## 量測來源

新組語在兩個困難輸入的 retired instructions 為 14,836,245／37,730,599。前一版為 15,092,396／38,398,165。新版通過 31 個 target regression cases、距離 0～11 的 12 個案例與 block tests；舊的 2,644-case exhaustive target sweep 不等於新版已重跑。

完整證據保留於原專案：

- measurements/solver7_solve_boundary/（最新）
- measurements/solver7_solve_control/（上一版）
- measurements/solver7_horner/
- measurements/solver7_pruning/
- measurements/solver7_search_assembly/
- measurements/solver7_submission_validation/

這些是 AI-assisted 修改與 AI-executed 開發量測，不能宣稱學生獨立執行。精簡包不複製量測資料；講稿引用仍可回原專案查核。

## 第六段 before 畫面

歷史版本曾使用以下 `.L8` loop，可在投影片顯示此短片段，不必帶整個舊版程式：

```asm
li a6,0
.L8:
    lbu a7,0(a5)
    bne a7,a6,.L7
    lbu a7,7(a5)
    addi a6,a6,1
    addi a5,a5,1
    bne a7,zero,.L7
    bne a6,s0,.L8
```

舊版 s0=7；上一版改為固定 offsets；最新版本直接移除 node goal scan，在 accepted child 到達 limit 時回傳。講稿中的完整證據都在原專案保留。
