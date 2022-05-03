#!/bin/bash

#SBATCH --array=1-16%10                  # jobs 1 to 21, maximum 10 at the time
#SBATCH --nodes=1                        # We always use 1 node
#SBATCH --ntasks=10                      # The number of threads reserved
#SBATCH --mem=150G                        # The amount of memory reserved
#SBATCH --partition=hugemem             # For < 100GB use smallmem, for >100GB use hugemem
#SBATCH --time=10:00:00                  # Runs for maximum this time
#SBATCH --job-name=diff_q_KB                   # Sensible name for the job
#SBATCH --output=diff_q_KB_%j_%a.log           # Logfile output here

##############
### Settings
###
threads=10

kraken_dbase=/mnt/SCRATCH/haek/database/master_database #using the custom database 

out_dir=/mnt/SCRATCH/haek/Results_KB/dif_q_KB_2 #defining a directory for the results

list_dir=/mnt/users/haek/Master/kracken_bracken #directory where the list of fastq-files are found 
fastq_dir=/mnt/SCRATCH/haek/mixes/1m_new #directory for the fastq-files
sample_list_R1=1m_new_R1.txt #list of R1 fastq-files
sample_list_R2=1m_new_R2.txt #list of R2 fastq-files

line=$(($SLURM_ARRAY_TASK_ID))
R1_samples=$(awk -F"\t" '{print $1}' < $list_dir/$sample_list_R1) #vector with paths for R1 reads
R1_sample=$(echo $R1_samples | awk -vidx=$line '{print $idx}') #specifies R1 path

R2_samples=$(awk -F"\t" '{print $1}' < $list_dir/$sample_list_R2) #vector with paths for R2 reads
R2_sample=$(echo $R2_samples | awk -vidx=$line '{print $idx}') #specifies R2 path

r1=$fastq_dir/$R1_sample #define r1 reads for kb
r2=$fastq_dir/$R2_sample #define r2 reads for kb

report_names="${R1_sample:0:-9}"

echo $r1
echo $r2
echo $report_names
echo $out_dir/"$report_names"_test_om_dette_funker

if [ ! -d $out_dir ]
then
  mkdir $out_dir
fi

qualities=$(seq 0 0.1 1)
for quality in $qualities #creares for-loop for different confidence for Kraken2 0 to 1 with steps of 0.1
do
  ####################
  ### settings kraken2

  krk2_report=$out_dir/"$report_names"_q"${quality}"_kraken2_report.txt #edit to get desired report name for Kraken2


  #####################
  ### Running kraken2
  ###
  singularity exec /cvmfs/singularity.galaxyproject.org/k/r/kraken2:2.1.2--pl5262h7d875b9_0 kraken2 \
  --threads $threads --use-names --db $kraken_dbase --report $krk2_report  --paired $r1 $r2 --confidence $quality > $out_dir/delete_me.txt

  ##############
  ### Settings
  ###
  brk_report=$out_dir/"$report_names"_q"${quality}"_bracken_report.txt #edit to get desired report name for Bracken
  target_rank=S
  echo $brk_report #to write in log-file what the report is named

  #####################
  ### Running bracken
  ###
  singularity exec /cvmfs/singularity.galaxyproject.org/b/r/bracken:2.6.1--py39h7cff6ad_2 bracken \
  -d $kraken_dbase -i $krk2_report -o $brk_report -l $target_rank -r 100 -t 1

#   #########################
#   ### Copying and cleaning
#   ###
#   #mv $brk_report $(basename $brk_report)
done

