#!/usr/bin/bash
#SBATCH -p short -N 1 -n 8 --mem 8gb  --out prodigal.log

module unload perl
module load parallel
module load prodigal
CPU=8
# run twice to do training then running
parallel -j $CPU prodigal -i {} -a {.}.faa -d {.}.fna -o {.}.gff -t {.}.train -f gff ::: $(ls *.fasta)
parallel -j $CPU prodigal -i {} -a {.}.faa -d {.}.fna -o {.}.gff -t {.}.train -f gff ::: $(ls *.fasta)
