#!/usr/bin/bash
#SBATCH -p short -N 1 -n 8 --mem 16gb --out logs/01_hmmsearch_Bacteria.log

module load hmmer/3
module unload perl
module load parallel
module load muscle
module load fasttree
# bacteria MAGs

CPUS=$SLURM_CPUS_ON_NODE
if [ -z $CPUS ]; then
 CPUS=1
fi
CPU=$CPUS

CUTOFF=1e-3
INPUT=../../processed/EukRep_autometa_Bacteria/MAGs
parallel -j $CPU esl-sfetch --index {} ::: $(ls $INPUT/*.faa)

OUTTOP=results
for DIR in Boyce2018 Groves_S2_genes
do
    OUT=$OUTTOP/$DIR
    mkdir -p $OUT
    
    for HMM in $(ls steps/$DIR/*.hmm)
    do
	step=$(basename $HMM .hmm)	
	parallel -j $CPU hmmsearch -E $CUTOFF --domtbl $OUT/$step.{/.}.domtbl $HMM {} \> $OUT/$step.{/.}.hmmsearch ::: $(ls $INPUT/*.faa)
	#parallel -j $CPU grep -v "^#" $OUT/$step.{/.}.domtbl \| awk \'\{print \$1\}\' \| sort \| uniq \>  $step.{/.}.list :::  $(ls $INPUT/*.faa)
	parallel -j $CPU grep -v "^#" $OUT/$step.{/.}.domtbl \| awk \'\{print \$1\}\' \| sort \| uniq \| esl-sfetch -f {} - \> $OUT/$step.{/.}.hits.faa ::: $(lsx $INPUT/*.faa)
	find $OUT -size 0 | xargs rm -f
    done
    for n in $(ls $OUT/*.faa)
    do
	name=$(basename $n .hits.faa)
	perl -i -p -e "s/>/>$name|/; s/\*//;" $n
	dir=$(dirname $n)
	muscle < $n > $dir/$name.hits.fasaln
	FastTreeMP -wag -gamma < $dir/$name.hits.fasaln > $dir/$name.hits.FT.tre
    done
done
