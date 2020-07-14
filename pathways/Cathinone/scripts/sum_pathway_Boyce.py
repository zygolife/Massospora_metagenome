#!/usr/bin/env python3
import csv, os, sys, re

pathway='pathway_steps.tsv'
topdir='results/Boyce2018'
evalue_cutoff = 1e-10

steps = {}
MAGhits = {}
with open(pathway,"r") as fh:
    rdr = csv.reader(fh,delimiter="\t")
    for row in rdr:
        hmm = re.sub(".hmm","",row[1])
        name = row[2]
        steps[hmm] = name

for file in os.listdir(topdir):
    if file.endswith(".domtbl"):
        nameparse = file.split(".")
        hmmname = nameparse[0]
        MAG     = nameparse[1]
        #print(hmmname,MAG)
        with open(os.path.join(topdir,file),"r") as tph:
            for line in tph:
                if line.startswith("#"):
                    continue
                hmmerline = line.split()
                evalue = float(hmmerline[6])
                if MAG in MAGhits:
                    if hmmname in MAGhits[MAG]:
                        MAGhits[MAG][hmmname].append(hmmerline[0])
                    else:
                        MAGhits[MAG][hmmname] = [hmmerline[0]]
                else:
                    MAGhits[MAG] = { hmmname: [hmmerline[0]] }

header = ["MAG"]
for step in steps:
    header.append(steps[step])

with open("MAG.Boyce2018.hits.tsv","w") as ofh:
    outcsv = csv.writer(ofh,delimiter="\t",quoting=csv.QUOTE_MINIMAL)
    outcsv.writerow(header)

    for mag in MAGhits:
        line = [mag]
        for hmm in steps:
            if hmm in MAGhits[mag]:
                line.append(len(MAGhits[mag][hmm]))
            else:
                line.append(0)
        outcsv.writerow(line)
