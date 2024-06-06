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
STATIC="--decomposition --shm 4096 -Ls 16"
if [ $GPU -eq 0 ] ; then
  STATIC="$STATIC --dslash-asm"
else
  STATIC="$STATIC --accelerator-threads 8"
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
    *)       PREFIX="srun -N $M -n $N" ;;
  esac

  #OUT=": mflop/s = xxxxxxx"
  OUT=`$PREFIX ./$BINARY $STATIC --grid $GRID --mpi $MPI $COMMS | grep ": mflop/s ="`
  echo "$PRECISION  $GRID  $M  $MPI  $COMMS  $OUT"
}

M=32
N=$(( M * MULTI ))
GRID=64.64.64.32
MPILIST=$( python3 generate-mpilist.py $N $GRID )
#MPILIST="16.8.1.1  16.4.2.1  16.2.2.2  8.4.4.1  8.4.2.2  4.4.4.2"

for MPI in $MPILIST ; do
  RUN "$M" "$N" "$GRID" "$MPI"
done

M=16
N=$(( M * MULTI ))
GRID=64.64.32.32
MPILIST=$( python3 generate-mpilist.py $N $GRID )
#MPILIST="16.4.1.1  8.8.1.1  8.4.2.1  8.2.2.2  4.4.4.1  4.4.2.2"

for MPI in $MPILIST ; do
  RUN "$M" "$N" "$GRID" "$MPI"
done

M=8
N=$(( M * MULTI ))
GRID=64.32.32.32
MPILIST=$( python3 generate-mpilist.py $N $GRID )
#MPILIST="16.2.1.1  8.4.1.1  8.2.2.1  4.4.2.1  4.2.2.2"

for MPI in $MPILIST ; do
  RUN "$M" "$N" "$GRID" "$MPI"
done

M=4
N=$(( M * MULTI ))
GRID=32.32.32.32
MPILIST=$( python3 generate-mpilist.py $N $GRID )
#MPILIST="8.2.1.1  4.4.1.1  4.2.2.1  2.2.2.2"

for MPI in $MPILIST ; do
  RUN "$M" "$N" "$GRID" "$MPI"
done

M=2
N=$(( M * MULTI ))
GRID=32.32.32.16
MPILIST=$( python3 generate-mpilist.py $N $GRID )
#MPILIST="8.1.1.1  4.2.1.1  2.2.2.1"

for MPI in $MPILIST ; do
  RUN "$M" "$N" "$GRID" "$MPI"
done

M=1
N=$(( M * MULTI ))
GRID=32.32.16.16
MPILIST=$( python3 generate-mpilist.py $N $GRID )
#MPILIST="4.1.1.1  2.2.1.1"

for MPI in $MPILIST ; do
  RUN "$M" "$N" "$GRID" "$MPI"
done
