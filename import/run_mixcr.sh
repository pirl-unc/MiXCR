#!/bin/sh

# TODO's:
# should be outputting the default clone export so that vdjtools works on the output
# this would require some rewritting of the script to get the clone diversity stats


while [ $# -gt 0 ]; do
  case "$1" in
    --chains=*)
      CHAINS="${1#*=}"
      ;;
    --rna_seq=*)
      RNA_SEQ="${1#*=}"
      ;;
    --use_existing_vdjca=*)
      USE_EXISTING_VDJCA="${1#*=}"
      ;;
    --species=*)
      SPECIES="${1#*=}"
      ;;
    --threads=*)
      THREADS="${1#*=}"
      ;;
    --r1_path=*)
      INPUT_PATH_1="${1#*=}"
      ;;
    --r2_path=*)
      INPUT_PATH_2="${1#*=}"
      ;;
    --output_dir=*)
      OUTPUT_DIR="${1#*=}"
      ;;
    --sample_name=*)
      SAMPLE_NAME="${1#*=}"
      ;;
  esac
  shift
done

echo "CHAINS: ${CHAINS}"
echo "RNA_SEQ: ${RNA_SEQ}"
echo "USE_EXISTING_VDJCA: ${USE_EXISTING_VDJCA}"
echo "SPECIES: ${SPECIES}"
echo "THREADS: ${THREADS}"
echo "INPUT_PATH_1: ${INPUT_PATH_1}"
echo "INPUT_PATH_2: ${INPUT_PATH_2}"
echo "OUTPUT_DIR: ${OUTPUT_DIR}"
echo "SAMPLE_NAME: ${SAMPLE_NAME}"
echo ""
FILE_PREFIX=${SAMPLE_NAME}_

cd ${OUTPUT_DIR}
alignment="${FILE_PREFIX}alignment.vdjca"
alignment_log="${FILE_PREFIX}alignment_log.txt"
alignment_txt="${FILE_PREFIX}alignment.txt"
clone_assembly="${FILE_PREFIX}clones.clns"
clone_log="${FILE_PREFIX}clone_log.txt"
clone_txt="${FILE_PREFIX}clones.txt"
index_file="${FILE_PREFIX}index_file"
extended_alignment="${FILE_PREFIX}extended_alignment.vdjca"
aligned_r1="${FILE_PREFIX}aligned_r1.fastq"
aligned_r2="${FILE_PREFIX}aligned_r2.fastq"
unaligned_r1="${FILE_PREFIX}unaligned_r1.fastq"
unaligned_r2="${FILE_PREFIX}unaligned_r2.fastq"


if [ "$RNA_SEQ" == true ] ; then
 echo "Running with RNA-Seq parameters."
 align_parameter="rna-seq"
else
 echo "Running with amplicon parameters."
 align_parameter="default"
fi

echo ""

run_align=true
if [ "$USE_EXISTING_VDJCA" == true ] ; then
echo "Checking if VDJCA file exists..."
  if [ ! -z $(ls $alignment) ] ; then
    echo "Using existing VDJCA file."
    run_align=false
  else
    echo "There was no existing VDJCA file. MiXCR align will need to be run. "
  fi
  echo ""
fi


if [ "$run_align" == true ] ; then
  echo ""
  echo ""
  echo "Running MiXCR align..."
  echo ""
  mixcr align -f \
    --write-all \
    --save-reads \
    --library imgt \
    --not-aligned-R1 ${unaligned_r1} \
    --not-aligned-R2 ${unaligned_r2} \
    --parameters $align_parameter \
    -OallowPartialAlignments=$RNA_SEQ \
    -r ${alignment_log} \
    -c ${CHAINS} \
    -s ${SPECIES} \
    -t ${THREADS} \
    ${INPUT_PATH_1} ${INPUT_PATH_2} \
    ${alignment}
fi

if [ "$RNA_SEQ" == true ] ; then
  # run two partial assemblies and an alignment extension
  echo "Running two partial assemblies and an alignment extension for RNA-Seq."
  echo ""
  extended_alignment="${file_prefix}extended_alignment.vdjca"
  mixcr assemblePartial -r ap1_report.txt -f ${alignment} alignments_rescued_1.vdjca
  mixcr assemblePartial -r ap2_report.txt -f alignments_rescued_1.vdjca alignments_rescued_2.vdjca
  mixcr extendAlignments -r extension_report.txt -f alignments_rescued_2.vdjca "$extended_alignment"

  alignment="$extended_alignment"
fi

echo ""
echo ""
echo "Running MiXCR assemble..."
echo ""
# touch ${clone_log}
mixcr assemble -f \
  --index ${index_file} \
  -r ${clone_log} \
  -t ${THREADS} \
  ${alignment} ${clone_assembly}

echo ""
echo ""
echo "Running MiXCR exportAlignments..."
echo ""
mixcr exportAlignments -f \
  -cloneIdWithMappingType ${index_file} \
  -readId -sequence -quality -targets  -aaFeature CDR3 \
  ${alignment} \
  ${alignment_txt}

echo ""
echo ""
echo "Running MiXCR exportClones..."
echo ""
# -c --chains is the new way to get the clone fractions
mixcr exportClones -f -chains \
  --filter-out-of-frames \
  --filter-stops \
  -cloneId \
  -count \
  -nFeature CDR3 -qFeature CDR3 -aaFeature CDR3 \
  -vHit -dHit -jHit \
  -vHitsWithScore -dHitsWithScore -jHitsWithScore \
  ${clone_assembly} \
  ${clone_txt}

echo ""
echo ""
echo "Grabbing data from MiXCR logs..."
echo ""
Rscript /import/rscripts/extract_mixcr_align_stats.R ${alignment_log} align_stats.csv
align_columns=$(head -n 1 align_stats.csv)
align_stats=$(sed '2q;d' align_stats.csv)

Rscript /import/rscripts/extract_mixcr_clone_assembly_stats.R ${clone_log} clone_stats.csv
clone_columns=$(head -n 1 clone_stats.csv)
clone_stats=$(sed '2q;d' clone_stats.csv)

if [ "$RNA_SEQ" == true ] ; then
  # grab partial align and extension log output
  Rscript /import/rscripts/extract_mixcr_partial_assembly_stats.R ap1_report.txt ap1_stats.csv ap1_
  Rscript /import/rscripts/extract_mixcr_partial_assembly_stats.R ap2_report.txt ap2_stats.csv ap2_
  Rscript /import/rscripts/extract_mixcr_extension_stats.R extension_report.txt extension_stats.csv
  
  align_columns=$(head -n 1 align_stats.csv)
  align_stats=$(sed '2q;d' align_stats.csv)

  ap1_columns=$(head -n 1 ap1_stats.csv)
  ap1_stats=$(sed '2q;d' ap1_stats.csv)

  ap2_columns=$(head -n 1 ap2_stats.csv)
  ap2_stats=$(sed '2q;d' ap2_stats.csv)

  extension_columns=$(head -n 1 extension_stats.csv)
  extension_stats=$(sed '2q;d' extension_stats.csv)

  mixcr_columns="Sample_ID,${clone_columns},${align_columns},${ap1_columns},${ap2_columns},${extension_columns}"
  mixcr_qc="${SAMPLE_NAME},${clone_stats},${align_stats},${ap1_stats},${ap2_stats},${extension_stats}"
  
else

  mixcr_columns="Sample_ID,${clone_columns},${align_columns}"
  mixcr_qc="${SAMPLE_NAME},${clone_stats},${align_stats}"
  
fi

echo "${mixcr_columns}" > mixcr_qc.csv
echo "${mixcr_qc}" >> mixcr_qc.csv

echo ""
echo "Computing diversity metrics..."
echo ""
Rscript /import/rscripts/process_mixcr.R $SAMPLE_NAME $clone_txt mixcr_stats.csv

echo ""
echo "Make fastq file with only the aligned reads..."
echo ""

# ow=t (overwrite) Overwrites files that already exist.
# include=f Set to 'true' to include the filtered names rather than excluding them.
# -Xmx2g \ removed

/import/bbmap/filterbyname.sh \
  ow=t \
  in=${INPUT_PATH_1} \
  in2=${INPUT_PATH_2} \
  out=${aligned_r1} \
  out2=${aligned_r2} \
  names=${unaligned_r1} \
  include=f

echo ""
echo ""
echo "Running FastQC on aligned reads..."
echo ""
fastqc -t ${THREADS} --outdir="." ${aligned_r1}
fastqc -t ${THREADS} --outdir="." ${aligned_r2}

chmod 666 *

