#!/bin/bash

F=${0##*/}
if [ $# -lt 1 ] ; then
  echo "Insufficient arguments."
  echo "Usage: $F fritz|qpace4|booster"
  echo ""
  echo "fritz            Fritz CPU Cluster @ RRZE/FAU@NHR"
  echo "alex             Alex GPU Cluster @ RRZE/FAU@NHR"
  echo "qpace4           QPACE4 @ UR"
  echo "booster          JUWELS Booster @ JSC"
  echo "LumiG            Lumi-G @ CSC"
  exit 1
fi

echo "run_all.sh alive ..."

MULTI=1
CLUSTER=$1
case $CLUSTER in
  fritz)   MULTI=4 ; export OMP_NUM_THREADS=18 ;;
  qpace4)  MULTI=4 ; export OMP_NUM_THREADS=12 ;;
  booster) MULTI=1 ;;
  alex)    MULTI=1 ; export OMP_NUM_THREADS=16 ;;
  LumiG)   MULTI=8 ;;
  *)       echo "Must name a cluster" ; exit 1 ;;
esac

CC="--comms-concurrent"
CS="--comms-sequential"
CO="--comms-overlap"

echo "run_all.sh running ..."

BINARY="Benchmark_wilson"
OUT="${CLUSTER}.wilson_strong_scaling.dp.txt"
if [ ! -f "$OUT" ]; then
  ./wilson_strong_scaling.sh $BINARY $CC DP $MULTI $CLUSTER | tee    $OUT
  ./wilson_strong_scaling.sh $BINARY $CS DP $MULTI $CLUSTER | tee -a $OUT
  ./wilson_strong_scaling.sh $BINARY $CO DP $MULTI $CLUSTER | tee -a $OUT
fi
OUT="${CLUSTER}.wilson_weak_scaling.dp.txt"
if [ ! -f "$OUT" ]; then
  ./wilson_weak_scaling.sh   $BINARY $CC DP $MULTI $CLUSTER | tee    $OUT
  ./wilson_weak_scaling.sh   $BINARY $CS DP $MULTI $CLUSTER | tee -a $OUT
  ./wilson_weak_scaling.sh   $BINARY $CO DP $MULTI $CLUSTER | tee -a $OUT
fi
BINARY="Benchmark_dwf"
OUT="${CLUSTER}.dwf_strong_scaling.dp.txt"
if [ ! -f "$OUT" ]; then
  ./dwf_strong_scaling.sh $BINARY $CC DP $MULTI $CLUSTER | tee    $OUT
  ./dwf_strong_scaling.sh $BINARY $CS DP $MULTI $CLUSTER | tee -a $OUT
  ./dwf_strong_scaling.sh $BINARY $CO DP $MULTI $CLUSTER | tee -a $OUT
fi
OUT="${CLUSTER}.dwf_weak_scaling.dp.txt"
if [ ! -f "$OUT" ]; then
  ./dwf_weak_scaling.sh   $BINARY $CC DP $MULTI $CLUSTER | tee    $OUT
  ./dwf_weak_scaling.sh   $BINARY $CS DP $MULTI $CLUSTER | tee -a $OUT
  ./dwf_weak_scaling.sh   $BINARY $CO DP $MULTI $CLUSTER | tee -a $OUT
fi
BINARY="Benchmark_dwf_fp32"
OUT="${CLUSTER}.dwf_strong_scaling.sp.txt"
if [ ! -f "$OUT" ]; then
  ./dwf_strong_scaling.sh $BINARY $CC SP $MULTI $CLUSTER | tee    $OUT
  ./dwf_strong_scaling.sh $BINARY $CS SP $MULTI $CLUSTER | tee -a $OUT
  ./dwf_strong_scaling.sh $BINARY $CO SP $MULTI $CLUSTER | tee -a $OUT
fi
OUT="${CLUSTER}.dwf_weak_scaling.sp.txt"
if [ ! -f "$OUT" ]; then
  ./dwf_weak_scaling.sh   $BINARY $CC SP $MULTI $CLUSTER | tee    $OUT
  ./dwf_weak_scaling.sh   $BINARY $CS SP $MULTI $CLUSTER | tee -a $OUT
  ./dwf_weak_scaling.sh   $BINARY $CO SP $MULTI $CLUSTER | tee -a $OUT
fi
BINARY="Test_dwf_mixedcg_prec"
OUT="${CLUSTER}.cg_strong_scaling.mp.txt"
if [ ! -f "$OUT" ]; then
  ./cg_strong_scaling.sh $BINARY $CC MP $MULTI $CLUSTER | tee    $OUT
  ./cg_strong_scaling.sh $BINARY $CC MP $MULTI $CLUSTER | tee -a $OUT
  ./cg_strong_scaling.sh $BINARY $CC MP $MULTI $CLUSTER | tee -a $OUT
fi
OUT="${CLUSTER}.cg_weak_scaling.mp.txt"
if [ ! -f "$OUT" ]; then
  ./cg_weak_scaling.sh $BINARY $CC MP $MULTI $CLUSTER   | tee    $OUT
  ./cg_weak_scaling.sh $BINARY $CC MP $MULTI $CLUSTER   | tee -a $OUT
  ./cg_weak_scaling.sh $BINARY $CC MP $MULTI $CLUSTER   | tee -a $OUT
fi
