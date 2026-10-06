### AI-executed results

All RSS values below are **bytes**, as reported by macOS `/usr/bin/time -l`. Repetition labels are 1-based here (0-based in the raw filenames). Rates are instructions per process wall-clock second.

| Model | Region bytes | Repeat | Peak RSS (bytes) | Retired instructions | Wall seconds | Instructions / second |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| RV32_ISS | 4,096 | 1 | 68,861,952 | 5,243,910 | 1.842321 | 2,846,360.72 |
| RV32_ISS | 4,096 | 2 | 71,237,632 | 5,243,910 | 0.569786 | 9,203,296.02 |
| RV32_ISS | 4,096 | 3 | 71,204,864 | 5,243,910 | 0.534342 | 9,813,771.72 |
| RV32_5S | 4,096 | 1 | 103,088,128 | 5,243,910 | 52.090758 | 100,668.72 |
| RV32_5S | 4,096 | 2 | 78,807,040 | 5,243,910 | 58.252897 | 90,019.73 |
| RV32_5S | 4,096 | 3 | 77,856,768 | 5,243,910 | 52.967196 | 99,002.97 |
| RV32_ISS | 4,194,304 | 1 | 295,632,896 | 5,242,887 | 1.427082 | 3,673,851.58 |
| RV32_ISS | 4,194,304 | 2 | 290,734,080 | 5,242,887 | 0.782734 | 6,698,174.54 |
| RV32_ISS | 4,194,304 | 3 | 303,333,376 | 5,242,887 | 0.704394 | 7,443,121.90 |
| RV32_5S | 4,194,304 | 1 | 228,327,424 | 5,242,887 | 51.869166 | 101,079.07 |
| RV32_5S | 4,194,304 | 2 | 244,580,352 | 5,242,887 | 48.243480 | 108,675.56 |
| RV32_5S | 4,194,304 | 3 | 227,966,976 | 5,242,887 | 50.049622 | 104,753.78 |

| Model | Region bytes | RSS median (bytes) | RSS min–max (bytes) | RSS sample SD (bytes) | RSS sample variance (bytes²) | Median instructions / second |
| --- | ---: | ---: | --- | ---: | ---: | ---: |
| RV32_ISS | 4,096 | 71,204,864 | 68,861,952–71,237,632 | 1,362,238.71 | 1,855,694,307,328.00 | 9,203,296.02 |
| RV32_ISS | 4,194,304 | 295,632,896 | 290,734,080–303,333,376 | 6,351,352.22 | 40,339,675,021,312.00 | 6,698,174.54 |
| RV32_5S | 4,096 | 78,807,040 | 77,856,768–103,088,128 | 14,300,907.77 | 204,515,963,131,221.34 | 99,002.97 |
| RV32_5S | 4,194,304 | 228,327,424 | 227,966,976–244,580,352 | 9,489,396.31 | 90,048,642,241,877.33 | 104,753.78 |

Sample variance uses denominator n−1. No outliers were removed.

| Model | Median RSS difference (bytes) | Host bytes / extra guest byte | Payload-only extrapolation for 18,405,414 guest bytes (host bytes) |
| --- | ---: | ---: | ---: |
| RV32_ISS | 224,428,032 | 53.560117 | 985,796,133 |
| RV32_5S | 149,520,384 | 35.683284 | 656,765,623 |

The last column is an approximate incremental host-memory projection, **not observed baseline peak RSS**. It excludes the fixed process/model cost, assumes scaling beyond the measured range, and inherits all peak-RSS limitations below.
