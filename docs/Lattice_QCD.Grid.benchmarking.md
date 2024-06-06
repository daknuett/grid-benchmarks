---
authors: Nils Meyer, Daniel Knüttel
tags:
  - punch
---

# Grid Lattice QCD framework benchmarking

This guide covers download and compilation of the Grid Lattice QCD framework on various architectures. The focus here is on testing and benchmarking Grid.

Covered architectures:
* Fritz @ RRZE/FAU@NHR
* Alex @ RRZE/FAU@NHR
* QPACE4 @ UR (TBD)
* JUWELS Booster (TBD)

Remarks:
* Compilation details are based on best knowledge.
* Software stack/modules/environment of the target architectures can change over time.
* Grid follows a rolling release strategy. Actual Grid commit can fail to compile. In this case switch to another commit.
* Node allocation on Fritz @ RRZE/FAU@NHR can imply multiple switch hops (hops across multiple islands of 64 nodes each) and therefore performance can be sub-optimal?

## Download and preparation

Perform the following actions on a login node of the target machine with web access. This step is the same on all architectures. On Fritz and Alex use the dialog server.
```
$ git clone https://github.com/paboyle/Grid.git
$ cd Grid
$ ./bootstrap.sh
```
Patch the tests and benchmarks. This reduces runtimes without significantly affecting benchmark results.
```
$ sed -i 's/const int Ls=8;/const int Ls=16;/' tests/Test_dwf_mixedcg_prec.cc
$ sed -i 's/int ncall=1000;/int ncall=250;/' benchmarks/Benchmark_wilson.cc
$ sed -i 's/int ncall =1000;/int ncall=250;/' benchmarks/Benchmark_dwf.cc
```
## Compilation

Perform the following actions on a node suitable for compilation.
In this example the target folder hosting the binaries is `build` inside the `Grid` folder.
```
<load modules/environment>
$ mkdir build
$ cd build
$ ../configure CONFIGURATION
$ make -j 8
```
Details of necessary modules/environment and the `CONFIGURATION` are specific to
the target architecture.

### Fritz CPU Cluster @ RRZE/FAU@NHR

Modules/environment
```
$ module load openmpi/4.1.2-gcc11.2.0
```
`CONFIGURATION`
```
--enable-comms=mpi3 --enable-shm=shmget --enable-simd=SKL \
--enable-fermion-reps=no --enable-gparity=no \
 --without-lime --without-hdf5 CXX=mpicc
```

### Alex GPU Cluster @ RRZE/FAU@NHR
Modules/environment
```
$ module load gcc/11.2.0
$ module load openmpi/4.1.3-nvhpc22.5-cuda
```
`CONFIGURATION` (this works on Alex login nodes; if it does not work log out
and log in again)
```
--enable-setdevice --enable-simd=GPU --enable-accelerator=cuda \
--enable-unified=no --enable-alloc-align=4k --enable-accelerator-cshift=no \
--enable-shm=nvlink --enable-comms=mpi-auto --enable-gen-simd-width=64 \
--enable-fermion-reps=no --enable-gparity=no --without-lime --without-hdf5 \
MPICC=mpicc MPICXX=mpicxx CC=nvcc CXX=nvcc CXXFLAGS="-ccbin mpicxx -gencode \
arch=compute_80,code=sm_80 -std=c++14 --cudart shared --compiler-options -fPIC" \
LDFLAGS="--cudart shared --compiler-options -fopenmp" LIBS="-lrt"
```
Comment block in `Grid/Eigen/src/Core/arch/SSE/PacketMath.h` if compilation fails.

### JUWELS Booster @ JSC
Modules/environment
```
$ module load Stages/2020
$ module load GCC/10.3.0
$ module load CUDA/11.3
$ module load OpenMPI/4.1.1
$ module load mpi-settings/CUDA
$ module load MPFR/4.1.0
$ module load FFTW/3.3.8
# $ module load Python/3.8.5
# $ module load scikit/2021-Python-3.8.5
$ export OMP_NUM_THREADS=12
$ export OMPI_MCA_btl=^uct,openib
$ export UCX_TLS=gdr_copy,rc,rc_x,sm,cuda_copy,cuda_ipc
$ export UCX_RNDV_SCHEME=put_zcopy
$ export UCX_RNDV_THRESH=16384
$ export UCX_IB_GPU_DIRECT_RDMA=yes
$ export UCX_MEMTYPE_CACHE=n
```
`CONFIGURATION`
```
--enable-simd=GPU --enable-accelerator=cuda --enable-unified=no \
--enable-alloc-align=4k --enable-accelerator-cshift=no \
--enable-shm=nvlink --enable-comms=mpi-auto --enable-gen-simd-width=64 \
--enable-fermion-reps=no --enable-gparity=no \
--without-lime --without-hdf5 \
MPICC=mpicc MPICXX=mpicxx CC=nvcc CXX=nvcc \
CXXFLAGS="-ccbin g++ -gencode arch=compute_80,code=sm_80 -std=c++14 --cudart shared --compiler-options -fPIC" \
LDFLAGS="--cudart shared --compiler-options -fopenmp" \
LIBS="-lrt -lmpi"
```

### LUMI-G

--- 

**Update 08.05.2024**

`source.sh`:
```sh
#!/bin/bash
# module load craype-x86-trento fftw/3.3.9 DefApps/default \
#        libfabric/1.15.0.0 gcc/11.2.0 cmake/3.22.2 \
#        craype-network-ofi craype/2.7.15 libtool/2.4.6 \
#        perftools-base/22.05.0 cray-dsmml/0.2.2 rocm/5.1.0 \
#        xpmem/2.3.2-2.2_7.8__g93dd7ee.shasta cray-libsci/21.08.1.2 gmp/6.2.1 \
#        cray-pmi/6.1.2 PrgEnv-gnu/8.3.3 craype-accel-amd-gfx90a \
#        cray-pmi-lib/6.0.17 xalt/1.3.0 cray-mpich/8.1.16

#module load CrayEnv LUMI/23.09 partition/G  cray-fftw/3.3.10.1

module load CrayEnv LUMI/22.08 partition/G  cray-fftw/3.3.10.1 rocm/5.3.3
#
#cray-python/3.9.12.1

export PATH=~/Python-3.11.1/build/bin:$PATH
#export LD_LIBRARY_PATH=/opt/cray/pe/gcc/mpfr/3.1.4/lib:${LD_LIBRARY_PATH}
```

`config-command.sh`:
```sh
#!/bin/bash
../../configure \
    --enable-comms=mpi-auto --enable-unified=no \
    --enable-shm=nvlink --enable-accelerator=hip --disable-accelerator-cshift \
    --enable-gen-simd-width=64 --enable-simd=GPU --disable-fermion-reps --disable-gparity \
    --with-fftw=/users/knutteld/fftw-3.3.10/build \
    CXX=hipcc MPICXX=mpicxx \
    CXXFLAGS="-fPIC --offload-arch=gfx90a -I/opt/rocm/include/ -std=c++17 -I/opt/cray/pe/mpich/8.1.25/ofi/gnu/9.1/include" \
    LDFLAGS="-L/opt/cray/pe/mpich/8.1.25/ofi/gnu/9.1/lib -lmpi -L/opt/cray/pe/mpich/8.1.25/gtl/lib  -L/appl/lumi/SW/LUMI-22.08/G/EB/rocm/5.3.3/lib -lhipblas -lmpi_gtl_hsa -lamdhip64 -fopenmp"

#    --with-gmp=/sw/crusher/spack-envs/base/opt/cray-sles15-zen2/gcc-11.2.0/gmp-6.2.1-idotvdzakdbt5mdfbxiffbln672cifcz --with-mpfr=/opt/cray/pe/gcc/mpfr/3.1.4/ \



```



---
**Update 06.05.2024**

I try to use `systems/Lumi`.

`export SPACK_USER_PREFIX=/project/project_465000822/spack`
`module load spack/23.03-2`
`module load openssl-1.1.1l-gcc-7.5.0-v4rhtc4`

`sourceme.sh` should be:
```sh
export PATH=$PATH:$SPACK_ROOT/bin
source $SPACK_ROOT/share/spack/setup-env.sh
module load CrayEnv LUMI/22.12 partition/G  cray-fftw/3.3.10.1 rocm
spack load c-lime
spack load gmp
spack load mpfr
```



---

Modules/environment: none

`CONFIGURATION`
```
--enable-comms=mpi-auto --enable-unified=no --enable-shm=nvlink \
--enable-accelerator=hip --enable-gen-simd-width=64 --enable-simd=GPU \
--enable-fermion-reps=no --enable-gparity=no --without-lime --without-hdf5 \
CXX=hipcc MPICXX=mpicxx CXXFLAGS="-fPIC --amdgpu-target=gfx90a -I/opt/rocm/include/ \
-std=c++14 -I/opt/cray/pe/mpich/8.1.17/ofi/gnu/9.1/include" \
LDFLAGS="-L/opt/cray/pe/mpich/8.1.17/ofi/gnu/9.1/lib -lmpi \
-L/opt/cray/pe/mpich/8.1.17/gtl/lib -lmpi_gtl_hsa -lamdhip64 -fopenmp"
```

**UPDATE**

```
--enable-comms=mpi-auto --enable-unified=no --enable-shm=nvlink \
--enable-accelerator=hip --enable-gen-simd-width=64 --enable-simd=GPU \
--enable-fermion-reps=no --enable-gparity=no --without-lime --without-hdf5 \
CXX=hipcc MPICXX=mpicxx CXXFLAGS="-fPIC --amdgpu-target=gfx90a -I/opt/rocm/include/ \
-std=c++17 -I/opt/cray/pe/mpich/8.1.23/ofi/gnu/9.1/include" \
LDFLAGS="-L/opt/cray/pe/mpich/8.1.23/ofi/gnu/9.1/lib -lmpi \
-L/opt/cray/pe/mpich/8.1.23/gtl/lib -lmpi_gtl_hsa -lamdhip64 -fopenmp"
```


### QPACE 4 @ UR
Modules/environment

TBD


### SMUC-NG-P2 @ LRZ

```
module load intel-mpi/2021.11.0
module load intel/2024.0.0

```

Compile MPFR with this config:

```
CC=icpx ./configure --prefix=/dss/dsshome1/0D/di82teh/site
```

For GRID:

```
TOOLS=$HOME/tools
../../configure \
	--enable-simd=GPU \
	--enable-gen-simd-width=64 \
	--enable-comms=mpi-auto \
	--enable-accelerator-cshift \
	--disable-gparity \
	--disable-fermion-reps \
	--enable-shm=nvlink \
	--enable-accelerator=sycl \
	--enable-unified=no \
	MPICXX=mpicxx \
	CXX=icpx \
	LDFLAGS="-fiopenmp -fsycl -fsycl-device-code-split=per_kernel -fsycl-device-lib=all -lze_loader -L$TOOLS/lib64/ -L$HOME/site/lib" \
	CXXFLAGS="-fiopenmp -fsycl-unnamed-lambda -fsycl -I$INSTALL/include -Wno-tautological-compare -I$HOME/ -I$TOOLS/include -I $HOME/site/include"


```

## Benchmarking

Switch back to the `Grid` folder and create a new folder `my-benchmarks`. Copy relevant
tests and benchmarks into the `my-benchmarks` folder.
```
$ cd ..
$ mkdir my-benchmarks
$ cd my-benchmarks
$ cp ../build/benchmarks/Benchmark_wilson .
$ cp ../build/benchmarks/Benchmark_dwf .
$ cp ../build/benchmarks/Benchmark_dwf_fp32 .
$ cp ../build/tests/Test_dwf_mixedcg_prec .
```
Use secure copy `scp` to copy benchmark scripts to the `my-benchmarks` folder, untar
if necessary.

### Fritz CPU Cluster @ RRZE/FAU@NHR

Use interactive login onto 32 nodes, 4 tasks per node.
```
$ module purge
$ salloc --nodes=32 --ntasks-per-node=4 --partition=multinode --time=04:00:00
```
Perform a functionality check on 32 nodes in parallel
```
$ module load openmpi/4.1.2-gcc11.2.0
$ export OMP_NUM_THREADS=18
$ srun -N 32 -n 128 ./Benchmark_wilson --mpi 16.8.1.1 --shm 4096 --grid 64.64.64.64 --comms-overlap --dslash-asm
```
Run benchmark scripts interactively on Fritz node
```
$ module load openmpi/4.1.2-gcc11.2.0
$ export OMP_NUM_THREADS=18
./run_all.sh fritz
```
or submit a batch job on Fritz login node
```
$ sbatch fritz.run_all.job
```

### Alex GPU Cluster @ RRZE/FAU@NHR

Use interactive login
```
$ module purge
$ salloc --partition a100 --gres=gpu:a100:8 --cpus-per-task=16 --time 04:00:00
```
then test
```
$ module load gcc/11.2.0
$ module load openmpi/4.1.3-nvhpc22.5-cuda
$ export OMP_NUM_THREADS=16
$ srun -N 1 -n 8 ./Benchmark_wilson --mpi 4.2.1.1 --shm 4096 --grid 64.64.64.64 --comms-overlap --accelerator-threads 8
```
Run benchmark scripts interactively on Alex compute node
```
$ module load gcc/11.2.0
$ module load openmpi/4.1.3-nvhpc22.5-cuda
$ export OMP_NUM_THREADS=16
$ ./run_all.sh alex
```
or submit a batch job on Alex login node
```
$ sbatch alex.run_all.job
```

### JUWELS Booster @ JSC

TBD

### LUMI-G

- **note**: my project is: `project_465000822`
Use interactive login
```
$ salloc --nodes=4 --ntasks-per-node=8 --gpus-per-task 1 --account=project_465000381 --partition=dev-g --time=04:00:00
```
then test
```
$ module load PrgEnv-cray
$ module load craype-accel-amd-gfx90a
$ module load rocm
$ srun -N 4 -n 32 --gpus-per-task 1 ./Benchmark_wilson --mpi 8.4.1.1 --shm 4096 --grid 64.64.64.64 --comms-overlap --accelerator-threads 8 --shm-mpi 1
```

This is the test sbatch script I now use:

```sh

#!/bin/bash

#SBATCH --nodes=4
#SBATCH --ntasks-per-node=8
#SBATCH --gpus-per-node=8
#SBATCH --account=project_465000822 
#SBATCH --partition=standard-g
#SBATCH --time=01:00:00
#SBATCH -J Benchmark_wilson

source ../source.sh

cat << EOF > select_gpu
#!/bin/bash

export ROCR_VISIBLE_DEVICES=\$SLURM_LOCALID
exec \$*
EOF

chmod +x ./select_gpu

CPU_BIND="map_cpu:49,57,17,25,1,9,33,41"

export MPICH_GPU_SUPPORT_ENABLED=1

#srun -N 4 -n 32 --gpus-per-task 1 --cpu-bind=${CPU_BIND} ./select_gpu ./Benchmark_wilson --mpi 8.4.1.1 --shm 4096 --grid 64.64.64.64 --comms-overlap --accelerator-threads 8 --shm-mpi 1
srun --cpu-bind=${CPU_BIND} ./select_gpu ./Benchmark_wilson --mpi 8.4.1.1 --shm 4096 --grid 64.64.64.64 --comms-overlap --accelerator-threads 8 --shm-mpi 1
rm -rf ./select_gpu

```
## Analysis

In the `my-benchmarks` folder run
```
$ ./analyze.sh <fritz|alex|qpace4|booster>
```
This will pick the best performance of each benchmark/setting and store
the results in the files `<cluster>.<benchmark>.<precision>.best.txt` for 
further usage, e.g., to make performance plots.
