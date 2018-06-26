
subsampled_utt=0

batch_size=16

online_storage=false

config=
weights=
results=

data=""
tmpdir=
exp_dir=
compute_ter=true


echo "$0 $@"  # Print the command line for logging

[ -f path.sh ] && . ./path.sh;

. utils/parse_options.sh || exit 1;

if $online_storage ; then

      online_storage="--online_storage"
else
      online_storage=""
fi

if [ "$subsampled_utt" -gt "0" ]; then

      subsampled_utt="--subsampled_utt $subsampled_utt"
else
      subsampled_utt=""
fi

mkdir -p $results
mkdir -p $results/.backup
mv $results/* $results/.backup/


norm_vars=true

if [ -z "$tmpdir" ]; then
    #creating tmp directory (concrete tmp path is defined in path.sh)
    echo "Creating a new setup in temp"
    tmpdir=`mktemp -d`
else
    mkdir -p $tmpdir
fi

#feats="ark,s,cs:apply-cmvn --norm-vars=$norm_vars --utt2spk=ark:$data/utt2spk scp:$data/cmvn.scp scp:$data/feats.scp ark:- |"
if [ ! -f $tmpdir/f.ark ]; then
    echo ""
    echo copying test features ...
    echo ""
    feats="scp:$data/tdnn_3_bnf_feats.scp"
    copy-feats "${feats}" ark,scp:$tmpdir/f.ark,$tmpdir/test_local.scp
fi

labels=$(ls $data | grep labels)
cp $data/labels $exp_dir/labels.test

if [ -z "$labels" ]; then
    echo "no test labels found in: $exp_dir"
    echo "Creating pseudo labels"
    python ./utils/make_pseudo_labels.py --scp $tmpdir/test_local.scp --labels $tmpdir/labels.test --subsampling 3
fi

if $compute_ter; then
    compute_ter="--compute_ter"
    cp $exp_dir/labels.test $tmpdir/
    python ./utils/clean_length.py --scp_in  $tmpdir/test_local.scp --labels $tmpdir/labels.test --subsampling 3 --scp_out $tmpdir/test_local.scp $subsampled_utt_utt
else
    compute_ter=""
fi


echo python -m test --data_dir $tmpdir --results_dir $results --train_config $config --trained_weights $weights --batch_size $batch_size --temperature 1 $online_storage $compute_ter

python -m test --data_dir $tmpdir --results_dir $results --train_config $config --trained_weights $weights --batch_size $batch_size --temperature 1 $online_storage $compute_ter

