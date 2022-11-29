version 1.0

workflow remove_genotypes {
    input {
        File input_vcf
        Array[String] vcf_list=read_lines(input_vcf)
        }
    
    scatter(vcf in vcf_list) {
        String vcf_name = basename(vcf)
        call medianGQ_filter {
            input:
                vcf=vcf,
                vcf_name=vcf_name
        }
    }

    output {
        Array[File] medianGQ_file = medianGQ_filter.medianGQ_filter_output
    }
}


task medianGQ_filter {

    input {
        File vcf
        String vcf_name
    }

    runtime {
        cpu: 1
        memory: "2 GB"
        docker: "082963657711.dkr.ecr.eu-west-2.amazonaws.com/bcftools:1.13"
    }

    command {
        bcftools query -i 'menGQ > 30' -f '%CHROM\t%POS\t%REF\t%ALT\t%minGQ\n' ${vcf} > ${vcf_name}_medianGQ.tsv
        bcftools query -i 'menGQ > 30' -f '%CHROM\t%POS\t%REF\t%ALT\t%minGQ\n' ${vcf} 2> test_error.txt
    }

    output {
        File medianGQ_filter_output = "${vcf_name}_medianGQ.tsv"
    }

}