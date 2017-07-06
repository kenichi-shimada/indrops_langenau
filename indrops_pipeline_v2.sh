python path/to/indrops_install/indrops/indrops.py /path/to/indrops_install/indrops/test/indrops_v3.yaml build_index     \
        --genome-fasta-gz /data/langenau/Danio_rerio.GRCz10.dna_sm.toplevel.fa.gz     \
        --ensembl-gtf-gz /data/langenau/Danio_rerio.GRCz10.85.gtf.gz

# RSEM can not recognize transcript ENSDART00000000992|GTSF1!
# Gene Names with spaces in the GFT file were a problem with RSEM. So had to change (1 of many) to _1_of_many in GTF, gzip it and recreate index
python path/to/indrops_install/indrops/indrops.py /path/to/indrops_install/indrops/test/indrops_v3.yaml build_index     \
        --genome-fasta-gz /data/langenau/Danio_rerio.GRCz10.dna_sm.toplevel.fa.gz     \
        --ensembl-gtf-gz /data/langenau/Danio_rerio.GRCz10.85.gtf.quoted_genenames.gz


# Round 2 of index building. Noticed that indrops.py was throwing out a lot of biotypes that were of interest to us. So changed that, reran indexing; reran counting
# STEP 0 - ONE TIME ONLY
python path/to/indrops_install/indrops/indrops.py /path/to/indrops_install/indrops/test/indrops_v3.yaml build_index     \
        --genome-fasta-gz /data/langenau/Danio_rerio.GRCz10.dna_sm.toplevel.fa.gz     \
        --ensembl-gtf-gz /data/langenau/Danio_rerio.GRCz10.85.gtf.quoted_genenames.gz

# STEP 1
for library in {"WT_1","WT_2","PRKDC_1","PRKDC_2"}
do
        for worker_index in {0..39}
        do
		python path/to/indrops_install/indrops/indrops.py /path/to/indrops_install/indrops/test/indrops_v2.yaml filter --libraries ${library} --total-workers 40 --worker-index ${worker_index}
	done
done

# STEP 2
python path/to/indrops_install/indrops/indrops.py /path/to/indrops_install/indrops/test/indrops_v2.yaml identify_abundant_barcodes
grep -c "\-" ./*/abundant_barcodes.pickle


# STEP 3
for library in {"WT_1","WT_2","PRKDC_1","PRKDC_2"}
do
        for worker_index in {0..39}
        do
		python path/to/indrops_install/indrops/indrops.py /path/to/indrops_install/indrops/test/indrops_v2.yaml sort --libraries ${library} --total-workers 40 --worker-index ${worker_index}
	done
done


# Had to use samtools/1.3.1 for samtools sort to work without changing code in indrops.py. Changed setting in /path/to/indrops_install/indrops/test/indrops_v2.yaml
# So I had to install samtools 1.3.1 in my home directory, change setting again in the yaml file to /path/to/indrops_install/samtools-1.3.1/ and rerun
# STEP 4
for library in {"WT_1","WT_2","PRKDC_1","PRKDC_2"}
do
	for worker_index in {0..39}
	do
		python path/to/indrops_install/indrops/indrops.py /path/to/indrops_install/indrops/test/indrops_v2.yaml quantify --min-reads 10000 --min-counts 1 --analysis-prefix v2_prefix --libraries ${library} --total-workers 40 --worker-index ${worker_index}
	done
done
# STEP 5
for library in {"WT_1","WT_2","PRKDC_1","PRKDC_2"}
do
	python path/to/indrops_install/indrops/indrops.py /path/to/indrops_install/indrops/test/indrops_v2.yaml quantify --analysis-prefix v2_prefix  --total-workers 1 --libraries ${library}
done
