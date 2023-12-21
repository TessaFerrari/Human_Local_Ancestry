Run all 5 populations with snakemake on slurm using:

	$ conda activate snakemake
 	$ bash run_flare.sh

Run individual populations with snakemake on slurm using:

	$ conda activate snakemake
	$ nohup snakemake --slurm --default-resources slurm_account=jazlynmo_738 slurm_partition=qcb mem_mb=12000 runtime=1440 tasks=16 --config output=[${pop}] --jobs 1 --keep-going >> Log/${pop}_flare_log.txt 2>&1 &

Use flag '-np' to do dry-run and print rules to be executed
