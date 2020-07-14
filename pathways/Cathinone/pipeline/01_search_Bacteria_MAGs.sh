#!/usr/bin/bash
#SBATCH -p short -N 1 -n 8 --mem 16gb --out logs/01_hmmsearch_Bacteria.log

module load hmmer/3
module unload perl
module load parallel
# bacteria MAGs

CPUS=$SLURM_CPUS_ON_NODE
if [ -z $CPUS ]; then
 CPUS=1
fi
CPU=$CPUS

CUTOFF=1e-3
INPUT=../../processed/EukRep_autometa_Bacteria/MAGs/
OUT=results
mkdir -p $OUT
for HMM in $(ls steps/*.hmm)
do
   step=$(basename $HMM .hmm)

  parallel -j $CPU hmmsearch -E $CUTOFF --domtbl $OUT/$step.{/.}.domtbl $HMM {} \> $OUT/$step.{/.}.hmmsearch ::: $(ls $INPUT/*.faa)
  parallel -j $CPU esl-sfetch --index {} ::: $(ls $INPUT/*.faa)
  parallel -j $CPU grep -v "^#" $OUT/$step.{/.}.domtbl \| esl-sfetch -f {} - \> $OUT/$step.{/.}.hits.faa ::: $(ls $INPUT/*.faa)
  for n in $(ls $OUT/*.faa)
  do
	name=$(basename $n .hits.faa)
	perl -i -p -e "s/>/>$name|/" $n
  done
done
