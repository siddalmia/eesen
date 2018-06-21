#!/bin/bash

. ./cmd.sh ## You'll want to change cmd.sh to something that will work on your system.
           ## This relates to the queue.
. path.sh

am_nlayer=6
am_nproj=0
am_ninitproj=0
am_nfinalproj=0
am_ncell_dim=360
am_model=deepbilstm
am_window=3
am_norm=false

data_train=
data_dev=
aspire=false

. parse_options.sh

echo =====================================================================
echo "                Training AM with the Full Set                      "
echo =====================================================================


dir=exp/train_l${am_nlayer}_c${am_ncell_dim}_m${am_model}_w${am_window}_n${am_norm}_p${am_nproj}_ip${am_ninitproj}_fp${am_ninitproj}

mkdir -p $dir

# Train the network with CTC. Refer to the script for details about the arguments
steps/train_ctc_tf.sh --nlayer $am_nlayer --nhidden $am_ncell_dim  --batch_size 16 --learn_rate 0.02 --half_after 2 --model $am_model --window $am_window --ninitproj $am_ninitproj --nproj $am_nproj --nfinalproj $am_nfinalproj --norm $am_norm $data_train $data_dev $dir 
