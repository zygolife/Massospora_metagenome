#!/usr/bin/bash
#SBATCH -N 1 -n 32 --mem 32gb --out bwa.log

module load bwa
hostname
CPUS=$SLURM_CPUS_ON_NODE
if [ -z $CPUS ]; then
 CPUS=1
fi
TEMP=/scratch/Mass.canu2_6FC.loredac.bam
FINAL=Mass.canu2_6FC.loredac.bam
GENOME=canu2_6FC.loredac.contigs.vecscreen.fasta
if [ ! -f $GENOME.bwt ]; then
	bwa index -a bwtsw $GENOME
fi
time bwa mem -t $CPUS $GENOME Massospora_2019-06_R1.fq.gz Massospora_2019-06_R2.fq.gz | samtools view -O bam -@ 4 -o $TEMP -
samtools sort -@ $CPU -n -o $FINAL $TEMP
unlink $TEMP
