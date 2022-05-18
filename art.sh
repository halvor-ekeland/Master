#!/bin/bash

#SBATCH --array=1-19%10                  # jobs 1 to 21, maximum 10 at the time
#SBATCH --nodes=1                        # We always use 1 node
#SBATCH --ntasks=10                      # The number of threads reserved
#SBATCH --mem=150G                       # The amount of memory reserved
#SBATCH --partition=hugemem              # For < 100GB use smallmem, for >100GB use hugemem
#SBATCH --time=12:00:00                  # Runs for maximum this time
#SBATCH --job-name=art                   # Sensible name for the job
#SBATCH --output=ART_%j_%a.log           # Logfile output here


### generell settings
table_dir=//mnt/SCRATCH/haek/art #directory for the list of genomes
data_dir=/mnt/SCRATCH/haek/genomes #directory with the genomes
read_length=150 
fold_coverage=1
mean_fragsize=200
std_fragsize=10
sequence_sys=HS25


#############################################
### Reading genome_id from genomes_table.txt
###
line=$(($SLURM_ARRAY_TASK_ID))
genome_names=$(awk -F"\t" '{print $1}' < $table_dir/genomes_table3.txt) #creates vector with genome names
genome_name=$(echo $genome_names | awk -vidx=$line '{print $idx}') #specifies names for file with reads

genome_paths=$(awk -F"\t" '{print $3}' < $table_dir/genomes_table3.txt) #creates vector with genome paths
genome_path=$(echo $genome_paths | awk -vidx=$line '{print $idx}') #specifies paths for genomse for read simulatin reads

seq_ref_file=$data_dir/$genome_path #just to use standard variable names
outfile_prefix=$genome_name #just to use standard variable names

echo "variables" #so that log-files will give indication of what variables were set as
echo $seq_ref_file
echo $outfile_prefix


# runnning Art
singularity exec /cvmfs/singularity.galaxyproject.org/a/r/art:3.19.15--1 art_illumina -sam -i $seq_ref_file -p -l $read_length -ss $sequence_sys -f $fold_coverage -m $mean_fragsize -s $std_fragsize -o $outfile_prefix
# singularity exec /cvmfs/singularity.galaxyproject.org/a/r/art:3.19.15--1 art_illumina -sam -i reference.fa -p -l 150 -ss HS25 -f 20 -m 200 -s 10 -o paired_dat

