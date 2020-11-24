#!/bin/bash

set -u

WDIR=./export_appraise
TSKILL=$PWD/wmt-trueskill


# ALREARY DONE
#function setup {
#	svn clone https://github.com/keisks/wmt-trueskill
#	sudo easy_install trueskill
#	pip install --user trueskill
#}



# Conversion + anonymisisation
function conversion {
	INPUT=$1
	OUTPUT=$2

	2>&1 echo "Converting $INPUT -> $OUTPUT"
	cat $INPUT.xml | \
		sed -e 's/NAME_EVAL1/evaluator1/g' -e 's/NAME_EVAL2/evaluator2/g' \
		> $OUTPUT.xml
	python $TSKILL/data/xml2csv.py $OUTPUT.xml
}


function conversions {
	cd $WDIR

	conversion exported-task-enca-trfm_ft-orwell-2020-01-24 bdu.orwell.enca
	conversion exported-task-enca-trfm_ft-rowling-2020-01-24 bdu.rowling.enca
	conversion exported-task-enca-trfm_ft-salinger-2020-01-25 bdu.salinger.enca

	cd ..
}


#----------------------------------------------------------------------------
function rankings {
	for type in "ts"; do #"ew"; do
          for f in "bdu.orwell.enca.csv" "bdu.rowling.enca.csv" "bdu.salinger.enca.csv"; do
	    for num in $(seq 1 1000); do
	      SGE_TASK_ID=$num ranking $f $type
	    done
	  done
	done
}


function ranking {
	f=$1
	model=$2

	2>&1 echo "Ranking $f $model"

	PYTHONPATH="" # because i don't have it setup
	export PYTHONPATH=.:$PYTHONPATH:$TSKILL/src/trueskill
	dir=$WDIR/rank/$f/$SGE_TASK_ID
	[[ ! -d "$dir" ]] && mkdir -p "$dir"

	if [[ $model = "ts" ]]; then
	    cat $WDIR/$f | $TSKILL/src/infer_TS.py -n 2 -d 0 -s 2 $dir/
	elif [[ $model = "ew" ]]; then
	    cat $WDIR/$f | $TSKILL/src/infer_EW.py -p 1.0 -s 2 $dir/
	fi
}


#----------------------------------------------------------------------------
function cluster {
	F=$1

	2>&1 echo "Cluster $F"

	dir=$WDIR/clusters/
	[[ ! -d "$dir" ]] && mkdir -p "$dir"

	$TSKILL/eval/cluster.py -by-rank $WDIR/rank/$F/*/*.json > $dir/$F.rank.cluster
	$TSKILL/eval/cluster.py $WDIR/rank/$F/*/*.json > $dir/$F.mu.cluster
}


function clusters {
        for f in "bdu.orwell.enca.csv" "bdu.rowling.enca.csv" "bdu.salinger.enca.csv"; do
		cluster $f
	done
}



#----------------------------------------------------------------------------

#HT<MT are problematic cases, hence we remove them before running rankings and clusters
function filter_ht_less_mt {
	for f in "bdu.orwell.enca.csv" "bdu.rowling.enca.csv" "bdu.salinger.enca.csv"; do
		python3 filter_rankings_ht_less_mt__bdu.py $WDIR/$f > $WDIR/$f.no_ht_less_mt.csv 2> $WDIR/$f.no_ht_less_mt.err
	done
}


#same as rankings, just input files different
function rankings_filtered {
	for type in "ts"; do #"ew"; do
          for f in "bdu.orwell.enca.csv.no_ht_less_mt.csv" "bdu.rowling.enca.csv.no_ht_less_mt.csv" "bdu.salinger.enca.csv.no_ht_less_mt.csv"; do
	    for num in $(seq 1 1000); do
	      SGE_TASK_ID=$num ranking $f $type
	    done
	  done
	done
}

#same as clusters, just input files different
function clusters_filtered {
          for f in "bdu.orwell.enca.csv.no_ht_less_mt.csv" "bdu.rowling.enca.csv.no_ht_less_mt.csv" "bdu.salinger.enca.csv.no_ht_less_mt.csv"; do
		cluster $f
	done
}



#conversions
rankings
clusters

filter_ht_less_mt
rankings_filtered
clusters_filtered

