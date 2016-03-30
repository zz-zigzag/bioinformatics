
## 0: env

- some __local environment variable__ for this experiment


## 1: pre-processing
- `1.0.simplify_pindel_call_set` get pindel simple result from raw call set
- `1.1.simplify_svseq_call_set.sh` get svseq simple result from raw call set
- `1.2.format_vcf.sh` get sample's benchmark if have

## 2: verify variation
- `2.0.0.format_call_set.sh` format raw call set to `chr start_pos end_pos label` and get benchmark from insection of call set if need
- `2.0.1.compare_callset.sh` verify variation for each sample and output result to `res.$caller.txt`
- `2.0.2.calculate_stats.sh` output stats for callers and output result to `$stats_file$`
- `2.0.format_compare_calc.sh` do all above

## 3: collect feature
- `3.0.run_SVfeature.sh` collect feature
- `3.1.paste_label.sh` add label[0/1] to feature

## 4: train model
-  `4.0.downsample.sh` create [0:10:100 and 0:25:100 percent] subset
-  `4.1.train_model.sh` train svm model

## predict
- `5.0.predict.sh` use exist model to predict
- `5.1.train_predict` use different parameter to train and call `predict.sh`


