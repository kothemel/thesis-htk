echo "Start embedded training"

count=0

rm -rf Embedded_HMMs_DeltaDelta/hmm1 Embedded_HMMs_DeltaDelta/hmm2 Embedded_HMMs_DeltaDelta/hmm3 Embedded_HMMs_DeltaDelta/hmm4 \
		Embedded_HMMs_DeltaDelta/hmm5 Embedded_HMMs_DeltaDelta/hmm6 Embedded_HMMs_DeltaDelta/hmm7 Embedded_HMMs_DeltaDelta/hmm8 \
		Embedded_HMMs_DeltaDelta/hmm9 Embedded_HMMs_DeltaDelta/hmm-2GMM Embedded_HMMs_DeltaDelta/hmm-4GMM Embedded_HMMs_DeltaDelta/hmm-8GMM \
		#Embedded_HMMs_DeltaDelta/hmm-16GMM Embedded_HMMs_DeltaDelta/hmm-32GMM
while [ $count -lt 9 ] 
do
    prvcnt=$count  
    let count++
    
    
    mkdir -p Embedded_HMMs_DeltaDelta/hmm$count
    ../bin/HERest -A -D -T 1 -C config -I labs39.mlf -S trainHMM39.scp -H Embedded_HMMs_DeltaDelta/hmm${prvcnt}/macros -H \
    Embedded_HMMs_DeltaDelta/hmm${prvcnt}/hmmdefs -M Embedded_HMMs_DeltaDelta/hmm$count  Embedded_HMMs_DeltaDelta/hmm0/monophones0
done

echo "Ooooooffff finished"

mkdir Embedded_HMMs_DeltaDelta/hmm-2GMM  Embedded_HMMs_DeltaDelta/hmm-4GMM  Embedded_HMMs_DeltaDelta/hmm-8GMM #\
	  ##Embedded_HMMs_DeltaDelta/hmm-16GMM Embedded_HMMs_DeltaDelta/hmm-32GMM

echo "split GMMs"
count=2

while [ $count -lt 16 ]
do
	mkdir Embedded_HMMs_DeltaDelta/hmm-${count}GMM/hmm1
	../bin/HHEd -H Embedded_HMMs_DeltaDelta/hmm9/hmmdefs -M Embedded_HMMs_DeltaDelta/hmm-${count}GMM/hmm1 \
	Embedded_HMMs_DeltaDelta/split${count}.hed Embedded_HMMs_DeltaDelta/tiedlist
	let "count = count*2"
done

echo "GMM splitting ended"


model=2

while [ $model -lt 16 ]
do

	count=1

	while [ $count -lt 9 ] 
	do
	    prvcnt=$count
	    let count++
	    
	    
	    mkdir -p Embedded_HMMs_DeltaDelta/hmm-${model}GMM/hmm$count
	    cp Embedded_HMMs_DeltaDelta/hmm9/macros Embedded_HMMs_DeltaDelta/hmm-${model}GMM/hmm1
		../bin/HERest -A -D -T 1 -C config -I labs39.mlf -S trainHMM39.scp -H Embedded_HMMs_DeltaDelta/hmm-${model}GMM/hmm${prvcnt}/macros\
		 -H Embedded_HMMs_DeltaDelta/hmm-${model}GMM/hmm${prvcnt}/hmmdefs -M Embedded_HMMs_DeltaDelta/hmm-${model}GMM/hmm$count  Embedded_HMMs_DeltaDelta/hmm0/monophones0
	done
	echo $nxtmodel
	let model=model*2
done

echo "Finished training"

echo "--------------------------------------------------------------------"

count=2

while [ $count -lt 16 ]
do
	echo "Start testing - Model with ${count} GMMs"

	../bin/HVite -A -D -T 1 -H Embedded_HMMs_DeltaDelta/hmm-${count}GMM/hmm9/macros -H Embedded_HMMs_DeltaDelta/hmm-${count}GMM/hmm9/hmmdefs \
	 -C config -S testALL39.scp -l '*' -i ../test_entire_s08/mfcc-delta-delta/recout-${count}GMM-DD.mlf \
	  -w ../auto/wdnet -p -380.0 -s 5.0 ../lexicon/smarthomes_lexicon Embedded_HMMs_DeltaDelta/tiedlist

	 ../bin/HResults -I ../test_entire_s08/mfcc-delta-delta/testref-all39.mlf Embedded_HMMs_DeltaDelta/tiedlist \
	 ../test_entire_s08/mfcc-delta-delta/recout-${count}GMM-DD.mlf
	let count=count*2 
done

echo "Finished testing"
echo "--------------------------------------------------------------------"
echo "Calculating FMR Error"
cd ../test_entire_s08/mfcc-delta-delta/
./morfFiles.sh
cd whole
python misclaf_whole.py