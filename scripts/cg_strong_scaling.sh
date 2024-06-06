#!/bin/bash

BINARY=$1
COMMS=$2
PRECISION=$3
MULTI=$4
CLUSTER=$5
GPU=0
if [ "$CLUSTER" = "alex" ] ; then
  GPU=1
fi
if [ "$CLUSTER" = "booster" ] ; then
  GPU=1
fi
if [ "$CLUSTER" = "LumiG" ] ; then
  GPU=1
fi
STATIC="--decomposition --shm 4096"
if [ $GPU -eq 0 ] ; then
  STATIC="$STATIC --dslash-asm"
else
  STATIC="$STATIC --accelerator-threads 8"
fi
if [ "$CLUSTER" = "LumiG" ] ; then
  STATIC="$STATIC --shm-mpi 1"
fi

# Main function running the binary, here
# $1 = Number of nodes
# $2 = Number of MPI processes
# $3 = Grid / volume
# $4 = MPI partitioning
RUN () {
  local M=$1
  local N=$2
  local GRID=$3
  local MPI=$4

  PREFIX=""
  case $CLUSTER in
    booster) M=$(( M / 4 ))
             if [ $M -eq 0 ] ; then M=1 ; fi
             PREFIX="srun -N $M -n $N"
             if [ $N -lt 4 ] ; then
               PREFIX="srun -N $M -n $N --gres=gpu:$N"
             fi
             M=$N
             ;;
    alex)    if [ $M -gt 8 ] ; then
               return
             fi
             M=$(( M / 8 ))
             if [ $M -eq 0 ] ; then M=1 ; fi
             PREFIX="srun -N $M -n $N"
             if [ $N -lt 8 ] ; then
               PREFIX="srun -N $M -n $N --gres=gpu:$N"
             fi
             M=$N
             ;;
    LumiG)
             #M=$(( M / 8 ))
             #if [ $M -eq 0 ] ; then M=1 ; fi

	     CPU_BIND="map_cpu:49,57,17,25,1,9,33,41"
	     PREFIX="srun -N $M -n $N --cpu-bind=${CPU_BIND} ./select_gpu"
	     ;;
    *)       PREFIX="srun -N $M -n $N" ;;
  esac

  #OUT=": mflop/s = xxxxxxx"
  OUT=`$PREFIX ./$BINARY $STATIC --grid $GRID --mpi $MPI $COMMS | grep "Total"`
  echo "$PRECISION  $GRID  $M  $MPI  $COMMS  $OUT"
}

M=32
N=$(( M * MULTI ))
GRID=64.32.32.32
MPILIST=$( python3 generate-mpilist.py $N $GRID )

for MPI in $MPILIST ; do
  RUN "$M" "$N" "$GRID" "$MPI"
done


M=16
N=$(( M * MULTI ))
GRID=64.32.32.32
MPILIST=$( python3 generate-mpilist.py $N $GRID )

for MPI in $MPILIST ; do
  RUN "$M" "$N" "$GRID" "$MPI"
done



M=8
N=$(( M * MULTI ))
GRID=64.32.32.32
MPILIST=$( python3 generate-mpilist.py $N $GRID )

for MPI in $MPILIST ; do
  RUN "$M" "$N" "$GRID" "$MPI"
done
