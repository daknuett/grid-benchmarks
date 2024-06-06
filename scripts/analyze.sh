#!/bin/bash

F=${0##*/}
if [ $# -lt 1 ] ; then
  echo "Insufficient arguments."
  echo "Usage: $F fritz|qpace4|booster|LumiG"
  echo ""
  echo "fritz            Fritz CPU Cluster @ RRZE/FAU@NHR"
  echo "alex             Alex GPU Cluster @ RRZE/FAU@NHR"
  echo "qpace4           QPACE4 @ UR"
  echo "booster          JUWELS Booster @ JSC"
  echo "LumiG            Lumi-G | CSC.fi"
  exit 1
fi

CLUSTER=$1
case $CLUSTER in
  fritz)   ;;
  qpace4)  ;;
  booster) ;;
  alex)    ;;
  LumiG)    ;;
  *)       echo "Must name a cluster" ; exit 1 ;;
esac

export LC_ALL=C

# Wilson and DWF: best Flop/s
IN="${CLUSTER}.wilson_strong_scaling.dp.txt"
OUT="${CLUSTER}.wilson_strong_scaling.dp.best.txt"
grep ^DP $IN | sort -r -g -k3,3 -k15,15 | awk '!a[$3]++' > $OUT
#OUT="${CLUSTER}.wilson_strong_scaling.sp.best.txt"
#grep ^SP $IN | sort -r -g -k3,3 -k15,15 | awk '!a[$3]++' > $OUT
IN="${CLUSTER}.wilson_weak_scaling.dp.txt"
OUT="${CLUSTER}.wilson_weak_scaling.dp.best.txt"
grep ^DP $IN | sort -r -g -k3,3 -k15,15 | awk '!a[$3]++' > $OUT

IN="${CLUSTER}.dwf_strong_scaling.dp.txt"
OUT="${CLUSTER}.dwf_strong_scaling.dp.best.txt"
grep ^DP $IN | sort -r -g -k3,3 -k15,15 | awk '!a[$3]++' > $OUT
IN="${CLUSTER}.dwf_strong_scaling.sp.txt"
OUT="${CLUSTER}.dwf_strong_scaling.sp.best.txt"
grep ^SP $IN | sort -r -g -k3,3 -k15,15 | awk '!a[$3]++' > $OUT

IN="${CLUSTER}.dwf_weak_scaling.dp.txt"
OUT="${CLUSTER}.dwf_weak_scaling.dp.best.txt"
grep ^DP $IN | sort -r -g -k3,3 -k15,15 | awk '!a[$3]++' > $OUT
IN="${CLUSTER}.dwf_weak_scaling.sp.txt"
OUT="${CLUSTER}.dwf_weak_scaling.sp.best.txt"
grep ^SP $IN | sort -r -g -k3,3 -k15,15 | awk '!a[$3]++' > $OUT

# CG: want lowest run time
IN="${CLUSTER}.cg_strong_scaling.mp.txt"
OUT="${CLUSTER}.cg_strong_scaling.mp.best.txt"
cat $IN | sort -g -k3,3 -k18,18  | awk '!a[$3]++' > $OUT
IN="${CLUSTER}.cg_weak_scaling.mp.txt"
OUT="${CLUSTER}.cg_weak_scaling.mp.best.txt"
cat $IN | sort -g -k3,3 -k18,18  | awk '!a[$3]++' > $OUT
