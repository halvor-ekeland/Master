#!/bin/bash

#SBATCH --nodes=1                        # We always use 1 node
#SBATCH --ntasks=10                      # The number of threads reserved
#SBATCH --mem=150G                       # The amount of memory reserved
#SBATCH --partition=hugemem              # For < 100GB use smallmem, for >100GB use hugemem
#SBATCH --time=12:00:00                  # Runs for maximum this time
#SBATCH --job-name=KBdatabase      # Sensible name for the job
#SBATCH --output=database_%j.log          # Logfile output here

### settings
DBNAME=/mnt/SCRATCH/haek/database_final
genomes_dir=/mnt/SCRATCH/haek/genomes


### downloads the NCBI taxonomy
singularity exec /cvmfs/singularity.galaxyproject.org/k/r/kraken2:2.1.2--pl5262h7d875b9_0 kraken2-build --download-taxonomy --db $DBNAME

### adds genomes found in the directory "genomes"
find $genomes_dir -name '*.fna' -print0 | xargs -0 -I{} -n1 singularity exec /cvmfs/singularity.galaxyproject.org/k/r/kraken2:2.1.2--pl5262h7d875b9_0 kraken2-build --add-to-library {} --db $DBNAME

### creates the database form the genomes added to the library above
singularity exec /cvmfs/singularity.galaxyproject.org/k/r/kraken2:2.1.2--pl5262h7d875b9_0 kraken2-build --build --db $DBNAME

### creating kmer-distribution for Bracken
KRAKEN_DB=$DBNAME
THREADS=10
KMER_LEN=35
READ_LEN=100

singularity exec /cvmfs/singularity.galaxyproject.org/b/r/bracken:2.6.1--py39h7cff6ad_2 bracken-build -d ${KRAKEN_DB} -t ${THREADS} -k ${KMER_LEN} -l ${READ_LEN}