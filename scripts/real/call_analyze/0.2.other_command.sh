sed -n '/^0/p' res._e0.5_m1000.txt | sort -k3

# stats
ls *merged*format | xargs wc -l
ls *bench*vcf | xargs wc -l

#train model in hpc
for file in `ls *_* | grep "[0-9]$"`; do bsub -q qtest -o %J.$file.out bash ../4.1.train_model.sh $file; done

# predict
for file in `ls *model`; do . 4.1.predict.sh $file; done


