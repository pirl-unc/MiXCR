#!/bin/sh

# TODO's:
# should be outputting the default clone export so that vdjtools works on the output
# this would require some rewritting of the script to get the clone diversity stats

echo "Running run_mixcr.sh script..."
echo ""

while [ $# -gt 0 ]; do
  case "$1" in
    --import_dir=*)
      IMPORT_DIR="${1#*=}"
      ;;
    --chains=*)
      CHAINS="${1#*=}"
      echo "chains say hi"
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
    --seperate_by_c=*)
      SEPERATE_BY_C="${1#*=}"
      ;;
  esac
  shift
done

echo "IMPORT_DIR: ${IMPORT_DIR}"
echo "CHAINS: ${CHAINS}"
echo "RNA_SEQ: ${RNA_SEQ}"
echo "USE_EXISTING_VDJCA: ${USE_EXISTING_VDJCA}"
echo "SPECIES: ${SPECIES}"
echo "THREADS: ${THREADS}"
echo "INPUT_PATH_1: ${INPUT_PATH_1}"
echo "INPUT_PATH_2: ${INPUT_PATH_2}"
echo "OUTPUT_DIR: ${OUTPUT_DIR}"
echo "SAMPLE_NAME: ${SAMPLE_NAME}"
echo "SEPERATE_BY_C: ${SEPERATE_BY_C}"
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
aligned_r1="${FILE_PREFIX}aligned_r1.fastq.gz"
aligned_r2="${FILE_PREFIX}aligned_r2.fastq.gz"

RNA_SEQ=$(echo "$RNA_SEQ" | awk '{print tolower($0)}')
USE_EXISTING_VDJCA=$(echo "$USE_EXISTING_VDJCA" | awk '{print tolower($0)}')
SEPERATE_BY_C=$(echo "$SEPERATE_BY_C" | awk '{print tolower($0)}')

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
  if [ -f $alignment ] ; then
    echo "File exists. Using existing VDJCA file."
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
    --save-reads \
    --library imgt \
    --parameters $align_parameter \
    -OallowPartialAlignments=$RNA_SEQ \
    -r ${alignment_log} \
    -c ${CHAINS} \
    -s ${SPECIES} \
    -t ${THREADS} \
    ${INPUT_PATH_1} ${INPUT_PATH_2} \
    ${alignment}
  echo "Finished MiXCR align."
  
  echo ""
  echo "Exporting aligned reads..."
  mixcr exportReads ${alignment} ${aligned_r1} ${aligned_r2}
  echo "Finished export."
  echo ""
fi


if [ "$RNA_SEQ" == true ] ; then
  extended_alignment="${file_prefix}extended_alignment.vdjca"
  echo ""
  echo ""
  echo "Running RNA-Seq specific step assemblePartial 1..."
  echo ""
  mixcr assemblePartial -r ap1_report.txt -f ${alignment} alignments_rescued_1.vdjca
  echo "Finished RNA-Seq specific step assemblePartial 1."
  echo ""
  echo ""
  echo "Running RNA-Seq specific step assemblePartial 2..."
  echo ""
  mixcr assemblePartial -r ap2_report.txt -f alignments_rescued_1.vdjca alignments_rescued_2.vdjca
    echo "Finished RNA-Seq specific step assemblePartial 2."
  echo ""
  echo "Running RNA-Seq specific step extendAlignments..."
  echo ""
  mixcr extendAlignments -r extension_report.txt -f alignments_rescued_2.vdjca "$extended_alignment"
  echo "Finished RNA-Seq specific step extendAlignments."

  alignment="$extended_alignment"
fi


echo ""
echo ""
echo "Running MiXCR assemble..."
echo ""
# touch ${clone_log}
mixcr assemble -f \
  --index ${index_file} \
  -OseparateByC ${SEPERATE_BY_C} \
  -r ${clone_log} \
  -t ${THREADS} \
  ${alignment} ${clone_assembly}
echo "Finished MiXCR assemble."
echo ""
echo ""
echo "Running MiXCR exportAlignments..."
echo ""
mixcr exportAlignments -f \
  -cloneIdWithMappingType ${index_file} \
  -readId -sequence -quality -targets  -aaFeature CDR3\
  ${alignment} \
  ${alignment_txt}
echo "Finshed MiXCR exportAlignments."
echo ""
echo ""
echo "Running MiXCR exportClones..."
echo ""
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
echo "Finshed MiXCR exportClones."

echo ""
echo ""
echo "Grabbing data from MiXCR logs..."
echo ""
Rscript ${IMPORT_DIR}/rscripts/extract_mixcr_align_stats.R ${alignment_log} align_stats.csv
align_columns=$(head -n 1 align_stats.csv)
align_stats=$(sed '2q;d' align_stats.csv)

Rscript ${IMPORT_DIR}/rscripts/extract_mixcr_clone_assembly_stats.R ${clone_log} clone_stats.csv
clone_columns=$(head -n 1 clone_stats.csv)
clone_stats=$(sed '2q;d' clone_stats.csv)

if [ "$RNA_SEQ" == true ] ; then
  # grab partial align and extension log output
  Rscript ${IMPORT_DIR}/rscripts/extract_mixcr_partial_assembly_stats.R ap1_report.txt ap1_stats.csv ap1_
  Rscript ${IMPORT_DIR}/rscripts/extract_mixcr_partial_assembly_stats.R ap2_report.txt ap2_stats.csv ap2_
  Rscript ${IMPORT_DIR}/rscripts/extract_mixcr_extension_stats.R extension_report.txt extension_stats.csv

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

echo "Finished grabbing data from MiXCR logs."
echo ""
echo ""
echo "Computing diversity metrics..."
echo ""
Rscript ${IMPORT_DIR}/rscripts/process_mixcr.R $SAMPLE_NAME $clone_txt mixcr_stats.csv
echo "Completed running diversity mixcr stats."
echo ""
# echo ""
# echo "Extracting aligned reads used in clonotypes before clustering..."
# Rscript -e "
# aligned_df = data.table::fread('${alignment_txt}', data.table = F); \
# aligned_df = aligned_df[aligned_df[,'aaSeqCDR3'] != '',]; \
# aligned_df = aligned_df[!grepl('dropped',aligned_df[,'cloneMapping']),]; \
# writeLines(aligned_df[,'descrR1'], 'aligned_r1_ids.txt'); \
# writeLines(aligned_df[,'descrR2'], 'aligned_r2_ids.txt');
# "
# seqkit grep -n -j ${THREADS} --pattern-file aligned_r1_ids.txt ${INPUT_PATH_1} -o ${aligned_r1}
# seqkit grep -n -j ${THREADS} --pattern-file aligned_r2_ids.txt ${INPUT_PATH_2} -o ${aligned_r2}
# 
# echo "Completed extracting aligned reads."
# echo ""
echo ""
echo "Running FastQC on aligned reads..."
echo ""
fastqc -t ${THREADS} --outdir="." ${aligned_r1}
fastqc -t ${THREADS} --outdir="." ${aligned_r2}
echo "Completed fastqc."
echo ""
echo ""
echo "Running:mixcr exportClones to output default output which will easily run on vdjtools"
echo ""
clone_default_txt="${file_prefix}_clones_default_output.txt"
mixcr exportClones \
  --preset full \
  -f ${clone_assembly} ${clone_default_txt}
echo "Completed exportClones."
echo ""
echo ""
echo "Running vdjtools..."
echo ""
java -Xmx16G -jar /opt/vdjtools-1.1.7/vdjtools-1.1.7.jar Convert -S mixcr ${clone_default_txt} vdjtools
java -Xmx16G -jar /opt/vdjtools-1.1.7/vdjtools-1.1.7.jar CalcBasicStats vdjtools.${clone_default_txt} vdjtools
java -Xmx16G -jar /opt/vdjtools-1.1.7/vdjtools-1.1.7.jar CalcDiversityStats vdjtools.${clone_default_txt} vdjtools
echo "Completed vdjtools."
echo ""
echo ""
echo "Finished running run_mixcr.sh script"


