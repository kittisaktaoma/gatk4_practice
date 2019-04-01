#!/bin/bash

RefFasta=$1
Sample=$2
F=$3
R=$4
Bam=$5


bwa index ${RefFasta}
header=$( samtools view -H $Bam | grep "@RG" | tr "\t" ",")
id=$( echo $header | cut -f 2 -d ",")
sm=$( echo $header | cut -f 3 -d ",")
pl=$( echo $header | cut -f 5 -d ",")
lb=$( echo $header | cut -f 4 -d ",")
pu=$( echo $header | cut -f 6 -d ",")
cn=$( echo $header | cut -f 7 -d ",")
dt=$( echo $header | cut -f 8 -d ",")

bwa mem \
   -M \
   -R $(echo "@RG\tID:$id\tSM:$sm\tPL:$pl\tLB:$lb\tPU:$pu\tCN:$cn")\
   ${RefFasta} \
   ${F} \
   ${R} \
   > ${Sample}.sam



