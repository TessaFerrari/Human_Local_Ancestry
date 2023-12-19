# Load needed modules: $ module load bcftools/1.14 gcc/11.3.0 openblas/0.3.21 jdk/17.0.5

HG38REPO="/project/jazlynmo_738/DataRepository/Human/1000GenomeNYGC_hg38"
FLARE="/project/jazlynmo_738/software/flare.jar"
EXTENSIONS=["anc.vcf.gz", "log", "model", "global.anc.gz"]


configfile: "config.yaml"


def get_admixed_ancestor_samples(wildcards):
    return config["pops"][wildcards.anc]


rule all:
	input:
		expand("Out/{anc}_local_ancestry_chr{chr}.{ext}", anc=config["output"], chr=config["chroms"], ext=EXTENSIONS)


rule generate_ref_panel:
	input:
		get_admixed_ancestor_samples
	output:
		"refPanels/{anc}.ref.panel"
	shell:
		"awk '{{split(FILENAME, a, \"/\"); print $0 \"\\t\" a[9]}}' {input} | awk '{{ $2 = substr($2, 1, 3) }} 1' | tr -d $'\\r' > {output}"
		## Evaluates to: awk '{split(FILENAME, a, "/"); print $0 "\t" a[9]}' {input} | awk '{ $2 = substr($2, 1, 3) } 1' | tr -d $'\r' > {output}


rule generate_gt:
	input:
		HG38REPO + "/FileInformation/pops/{anc}_hg38.txt",
		HG38REPO + "/CCDG_14151_B01_GRM_WGS_2020-08-05_chr{chr}.filtered.shapeit2-duohmm-phased.nodupmarkers.snps.vcf.gz"
	output:
		"admixedSubsetVCFs/{anc}_hg38_chr{chr}.vcf.gz"
	shell:
		"""
		module load bcftools/1.14 gcc/11.3.0 openblas/0.3.21
		bcftools view -S {input} -Oz -o {output}
		"""			


rule run_flare:
	input:
		ref = HG38REPO + "/CCDG_14151_B01_GRM_WGS_2020-08-05_chr{chr}.filtered.shapeit2-duohmm-phased.nodupmarkers.snps.vcf.gz",
		rp = "refPanels/{anc}.ref.panel",
		gt = "admixedSubsetVCFs/{anc}_hg38_chr{chr}.vcf.gz",
		map = "GRCh38_Map/plink.chr{chr}.GRCh38.adjusted.map"
	output:
                "Out/{anc}_local_ancestry_chr{chr}.anc.vcf.gz",
                "Out/{anc}_local_ancestry_chr{chr}.log",
                "Out/{anc}_local_ancestry_chr{chr}.model",
                "Out/{anc}_local_ancestry_chr{chr}.global.anc.gz"
	run:
		shell("module load jdk/17.0.5; java -jar " + FLARE + " ref={input.ref} ref-panel={input.rp} gt={input.gt} map={input.map} out=Out/{wildcards.anc}_local_ancestry_chr{wildcards.chr}")
