---
authors: Nils Meyer, Daniel Knüttel
---

# Lattice QCD Benchmarks

This is a set of lattice QCD benchmarks carried out on a variety of
HPC clusters, including

- [QPACE 4](https://arxiv.org/pdf/2112.01852.pdf) (Fujitsu A64FX CPU cluster) at University of Regensburg (UR)
- [Fritz](https://hpc.fau.de/systems-services/documentation-instructions/clusters/fritz-cluster/) (Intel Ice Lake CPU cluster) at Regional Computer Center Erlangen (RRZE)
- [JUWELS Booster](https://apps.fz-juelich.de/jsc/hps/juwels/booster-overview.html) (NVIDIA A100 GPU cluster) at Jülich Supercomputing Centre (JSC)

- [Lumi-G](https://docs.lumi-supercomputer.eu/hardware/lumig/) (AMD MI250x GPU cluster) at  CSC data center in Kajaani, Finland

## Grid

The Grid lattice QCD framework comes with a series of tests and benchmarks.
Tests and benchmarks are configured by command line parameters. Configuration
includes, e.g.,
- global lattice volume
- partitioning of the global volume amongst processing elements
- computation and communication options

We define a processing element (PE) as follows:
- QPACE4: one Fujitsu A64FX CPU chip (one compute node hosts one CPU chip)
- Fritz: two Intel Ice Lake CPU chips (one compute node hosts two CPU chips, arranged as cache-coherent distributed shared memory system)
- JUWELS Booster: one NVIDIA A100 GPU chip (one compute node hosts four GPU chips interconnected by NVLink)

### Benchmark_wilson

Benchmark of the hopping term of the Wilson-Dirac operator applied to a
fermion field (Dslash). We show the performance of weak and strong MPI
scaling in single precision (SP) and double precision (DP).

Global lattice volumes:

| Number of PEs |         Weak scaling | Strong scaling      |
| ---:          | ---:                 | ---:                |
| 1             | 64 x 64 x 32 x 32    | -                   |
| 2             | 64 x 64 x 64 x 32    | -                   |
| 4             | 64 x 64 x 64 x 64    | -                   |
| 8             | 128 x 64 x 64 x 64   | 128 x 64 x 64 x 64  |
| 16            | 128 x 128 x 64 x 64  | 128 x 64 x 64 x 64  |
| 32            | 128 x 128 x 128 x 64 | 128 x 64 x 64 x 64  |

// Results:
//
// - [Benchmark_wilson on QPACE 4](docs/TA3/WP2/lqcd-benchmarks/Grid/Grid.Benchmark_wilson.QPACE4.pdf)
// - [Benchmark_wilson on Fritz](docs/TA3/WP2/lqcd-benchmarks/Grid/Grid.Benchmark_wilson.Fritz.pdf)
// - [Benchmark_wilson on JUWELS Booster](docs/TA3/WP2/lqcd-benchmarks/Grid/Grid.Benchmark_wilson.JUWELS-Booster.pdf)

### Benchmark_dwf

Benchmark of the performance-relevant part of the domain-wall Dirac operator
applied to a fermion field. We show the performance of weak and strong MPI
scaling in single precision (SP) and double precision (DP). The lattice
extension in the 5-direction is 16 for each benchmark.

Global lattice volumes:

| Number of PEs | Weak scaling           | Strong scaling      |
|--------------:|-----------------------:|--------------------:|
| 1             | 32 x 32 x 16 x 16 x 16 | -                   |
| 2             | 32 x 32 x 32 x 16 x 16 | -                   |
| 4             | 32 x 32 x 32 x 32 x 16 | -                   |
| 8             | 64 x 32 x 32 x 32 x 16 | 64 x 32 x 32 x 32 x 16  |
| 16            | 64 x 64 x 32 x 32 x 16 | 64 x 32 x 32 x 32 x 16  |
| 32            | 64 x 64 x 64 x 32 x 16 | 64 x 32 x 32 x 32 x 16  |

// Results:
//
// - [Benchmark_dwf on QPACE 4](docs/TA3/WP2/lqcd-benchmarks/Grid/Grid.Benchmark_dwf.QPACE4.pdf)
// - [Benchmark_dwf on Fritz](docs/TA3/WP2/lqcd-benchmarks/Grid/Grid.Benchmark_dwf.Fritz.pdf)
// - [Benchmark_dwf on JUWELS Booster](docs/TA3/WP2/lqcd-benchmarks/Grid/Grid.Benchmark_dwf.JUWELS-Booster.pdf)

### Test_dwf_mixedcg_prec

Solve time of FP32/FP64 mixed-precision conjugate gradient solver
for domain-wall fermions. We show the performance of weak and strong MPI
scaling. The lattice extension in the 5-direction is 16 for each benchmark.

Global lattice volumes:

| Number of PEs | Weak scaling           | Strong scaling      |
| ---:          | ---:                   | ---:                |
| 1             | 32 x 32 x 16 x 16 x 16 | -                   |
| 2             | 32 x 32 x 32 x 16 x 16 | -                   |
| 4             | 32 x 32 x 32 x 32 x 16 | -                   |
| 8             | 64 x 32 x 32 x 32 x 16 | 64 x 32 x 32 x 32 x 16  |
| 16            | 64 x 64 x 32 x 32 x 16 | 64 x 32 x 32 x 32 x 16  |
| 32            | 64 x 64 x 64 x 32 x 16 | 64 x 32 x 32 x 32 x 16  |

// Results:
//
// - [Test_dwf_mixedcg_prec on QPACE 4](docs/TA3/WP2/lqcd-benchmarks/Grid/Grid.Test_dwf_mixedcg_prec.QPACE4.pdf)
// - [Test_dwf_mixedcg_prec on Fritz](docs/TA3/WP2/lqcd-benchmarks/Grid/Grid.Test_dwf_mixedcg_prec.Fritz.pdf)
// - [Test_dwf_mixedcg_prec on JUWELS Booster](docs/TA3/WP2/lqcd-benchmarks/Grid/Grid.Test_dwf_mixedcg_prec.JUWELS-Booster.pdf)
