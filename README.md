# High-Performance FPGA Implementations of Lightweight ASCON-128 and ASCON-128a with Enhanced Throughput-to-Area Efficiency

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Repository for the Article: "XX"

This repository contains the hardware implementation results and source code used in the article **High-Performance FPGA Implementations of Lightweight ASCON-128 and ASCON-128a with Enhanced Throughput-to-Area Efficiency**, published in **The 17th International Information Security and Cryptology Conference**. The article presents the performance of ASCON cryptographic algorithms on various FPGA platforms, including Spartan-6, Kintex-7, and Artix-7.

For more details, please refer to the article (will be added soon): [Link to the article](URL).

## Abstract

The ASCON algorithm was chosen for its efficiency and suitability for resource-constrained environments such as IoT devices. In this paper, we present a high-performance FPGA implementation of ASCON-128 and ASCON-128a, optimized for the throughput-to-area ratio. By utilizing a 6-round permutation in one cycle for ASCON-128 and a 4-round permutation in one cycle for ASCON-128a, we have effectively maximized throughput while ensuring efficient resource utilization. Our implementation shows significant improvements over existing designs, achieving 34.16\% better throughput-to-area efficiency on Artix-7 and 137.58\% better throughput-to-area efficiency on Kintex-7 FPGAs. When comparing our results on the Spartan-7 FPGA with Spartan-6, we observed a 98.63\% improvement in throughput-to-area efficiency. However, it is important to note that this improvement may also be influenced by the advanced capabilities of the Spartan-7 platform compared to the older Spartan-6, in addition to the design optimizations implemented in this work.

## Results and Comparison

Hardware Implementations of ASCON on Artix-7 FPGA

| **ASCON Architecture**       | **FPGA Platform** | **Area (LUT)** | **Area (FF)** | **Frequency (MHz)** | **Period (ns)** | **Throughput (Mbps)** | **Efficiency (Mbps/LUT)** |
|------------------------------|-------------------|----------------|---------------|---------------------|-----------------|-----------------------|---------------------------|
| \[Abdulgadir2019\]            | Artix-7           | 1808 LUT       | N/A           | 232 MHz              | 4.31 ns         | 39 Mbps                | 0.021                     |
| \[Khan2023\], (6-round)       | Artix-7           | 3728 LUT       | N/A           | 64.07 MHz            | 15.61 ns        | 792.56 Mbps            | 0.208                     |
| \[Raj2022\]                   | Artix-7           | 1330 LUT       | N/A           | 107 MHz              | 9.34 ns         | 457 Mbps               | 0.343                     |
| \[Mohajerani2020\]            | Artix-7           | 1723 LUT       | N/A           | 219 MHz              | 4.57 ns         | 987 Mbps               | 0.572                     |
| \[Khan2023\], (1-round)       | Artix-7           | 770 LUT        | N/A           | 260.75 MHz           | 3.84 ns         | 668.4 Mbps             | 0.868                     |
| \[Rezvani2019\]               | Artix-7           | 1898 LUT       | N/A           | 263 MHz              | 3.80 ns         | 1683.2 Mbps            | 0.887                     |
| This Work - ASCON-128         | Artix-7           | 2957 LUT       | 595 FF        | 55.25 MHz            | 18.1 ns         | 3535.91 Mbps           | 1.19                      |
| This Work - ASCON-128a        | Artix-7           | 2183 LUT       | 653 FF        | 83.33 MHz            | 12.0 ns         | 5333.3 Mbps            | 2.44                      |


Hardware Implementations of ASCON on Kintex-7 FPGA

| **ASCON Architecture**       | **FPGA Platform** | **Area (LUT)** | **Area (FF)** | **Frequency (MHz)** | **Period (ns)** | **Throughput (Mbps)** | **Efficiency (Mbps/LUT)** |
|------------------------------|-------------------|----------------|---------------|---------------------|-----------------|-----------------------|---------------------------|
| \[Aneesh\], Encryption        | Kintex-7          | 944 LUT        | 734           | 181 MHz              | 5.52 ns         | N/A Mbps               | N/A                       |
| \[Aneesh\], Decryption        | Kintex-7          | 1058 LUT       | 735           | 181 MHz              | 5.52 ns         | N/A Mbps               | N/A                       |
| \[Mandal2022\], ASCON-128     | Kintex-7          | 1055 LUT       | 328           | 303 MHz              | 3.30 ns         | N/A Mbps               | N/A                       |
| \[Mandal2022\], ASCON-128a    | Kintex-7          | 1107 LUT       | 328           | 212 MHz              | 3.20 ns         | N/A Mbps               | N/A                       |
| \[Khan2023\], (6-round)       | Kintex-7          | 3728 LUT       | N/A           | 100.36 MHz           | 9.96 ns         | 1354.49 Mbps           | 0.356                     |
| \[Khan2023\], (1-round)       | Kintex-7          | 702 LUT        | N/A           | 268.24 MHz           | 3.73 ns         | 646.46 Mbps            | 0.846                     |
| This Work - ASCON-128         | Kintex-7          | 2958 LUT       | 595 FF        | 92.59 MHz            | 10.8 ns         | 5925.92 Mbps           | 2.01                      |
| This Work - ASCON-128a        | Kintex-7          | 3051 LUT       | 653 FF        | 158.73 MHz           | 6.3 ns          | 10158 Mbps             | 3.32                      |


Hardware Implementations of ASCON on Spartan FPGAs

| **ASCON Architecture**       | **FPGA Platform** | **Area (LUT)** | **Area (FF)** | **Frequency (MHz)** | **Period (ns)** | **Throughput (Mbps)** | **Efficiency (Mbps/LUT)** |
|------------------------------|-------------------|----------------|---------------|---------------------|-----------------|-----------------------|---------------------------|
| \[Diehl2019\]                | Spartan-6         | 1640 LUT       | N/A           | 146.1 MHz            | 6.84 ns         | 114 Mbps               | 0.070                     |
| \[yalla2017\]                | Spartan-6         | 680 LUT        | N/A           | 216 MHz              | 4.63 ns         | 60.1 Mbps              | 0.088                     |
| \[Diehl2018\]                | Spartan-6         | 2048 LUT       | N/A           | N/A MHz              | N/A ns          | 255.4 Mbps             | 0.1247                    |
| \[Khan2021\] (3-p)           | Spartan-6         | 3630 LUT       | N/A           | 126.1 MHz            | 7.93 ns         | 448.25 Mbps            | 0.133                     |
| \[Khan2021\] (2-p)           | Spartan-6         | 2720 LUT       | N/A           | 147.2 MHz            | 6.79 ns         | 392.61 Mbps            | 0.144                     |
| \[Khan2021\] (1-p)           | Spartan-6         | 2060 LUT       | N/A           | 206.2 MHz            | 4.85 ns         | 315.2 Mbps             | 0.153                     |
| \[Ayyappa\]                  | Spartan-6         | 1985 LUT       | N/A           | 96.89 MHz            | 10.32 ns        | 406.66 Mbps            | 0.235                     |
| \[Rezvani2019\]              | Spartan-6         | 1913 LUT       | N/A           | 174.4 MHz            | 5.73 ns         | 1116.4 Mbps            | 0.584                     |
| This Work - ASCON-128        | Spartan-7         | 2957 LUT       | 595 FF        | 53.76 MHz            | 18.6 ns         | 3440.86 Mbps           | 1.16                      |
| This Work - ASCON-128a       | Spartan-7         | 2178 LUT       | 653 FF        | 83.33 MHz            | 12.0 ns         | 5333.33 Mbps           | 2.45                      |



## Conclusion
 
In this research, we have proposed a design focused on achieving high performance with an optimized throughput-to-area ratio. We implemented a 6-round permutation for \texttt{ASCON-128} and a 4-round permutation for \texttt{ASCON-128a} to maximize throughput. While our results indicate significant improvements, with 34.16\% better efficiency on the Artix-7 FPGA and 137.58\% better efficiency on the Kintex-7, it's important to note that the 98.63\% better efficiency observed on the Spartan-7 FPGA compared to Spartan-6 results may be partially attributed to the advancements in FPGA technology rather than our design optimizations. The newer Spartan-7 platform offers enhanced performance capabilities, which likely contribute to these improved results.

