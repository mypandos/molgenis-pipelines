#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=4

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage
#string picardVersion
#string RVersion
#string reads2FqGz
#string collectMultipleMetricsDir
#string collectMultipleMetricsPrefix
#string onekgGenomeFasta
#string markDuplicatesBam
#string markDuplicatesBai
#string toolDir


echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

#echo  ${collectMultipleMetricsPrefix} 

getFile ${markDuplicatesBam}
getFile ${markDuplicatesBai}
getFile ${onekgGenomeFasta}


#load modules
${stage} picard/${picardVersion}
${checkStage}


#main ceate dir and run programmes

mkdir -p ${collectMultipleMetricsDir}

insertSizeMetrics=""
if [ ${#reads2FqGz} -ne 0 ]; then
	insertSizeMetrics="PROGRAM=CollectInsertSizeMetrics"
fi

#Run Picard CollectAlignmentSummaryMetrics, CollectInsertSizeMetrics, QualityScoreDistribution and MeanQualityByCycle
if java -jar -Xmx4g -XX:ParallelGCThreads=8 ${toolDir}picard/${picardVersion}//CollectMultipleMetrics.jar \
 I=${markDuplicatesBam} \
 O=${collectMultipleMetricsPrefix} \
 R=${onekgGenomeFasta} \
 PROGRAM=CollectAlignmentSummaryMetrics \
 PROGRAM=QualityScoreDistribution \
 PROGRAM=MeanQualityByCycle \
 $insertSizeMetrics \
 TMP_DIR=${collectMultipleMetricsDir}

#VALIDATION_STRINGENCY=LENIENT \

then
 echo "returncode: $?"; 

 putFile  ${collectMultipleMetricsPrefix}.alignment_summary_metrics 
 putFile ${collectMultipleMetricsPrefix}.quality_by_cycle_metrics 
 putFile ${collectMultipleMetricsPrefix}.quality_by_cycle.pdf 
 putFile ${collectMultipleMetricsPrefix}.quality_distribution_metrics 
 putFile ${collectMultipleMetricsPrefix}.quality_distribution.pdf
 echo "md5sums"
md5sum ${collectMultipleMetricsPrefix}.quality_distribution_metrics
md5sum ${collectMultipleMetricsPrefix}.alignment_summary_metrics
md5sum ${collectMultipleMetricsPrefix}.quality_by_cycle_metrics
md5sum ${collectMultipleMetricsPrefix}.quality_by_cycle.pdf
md5sum ${collectMultipleMetricsPrefix}.quality_distribution.pdf
 if [ ${#reads2FqGz} -ne 0 ]; then
	putFile ${collectMultipleMetricsPrefix}.insert_size_histogram.pdf
	putFile ${collectMultipleMetricsPrefix}.insert_size_metrics
    md5sum ${collectMultipleMetricsPrefix}.insert_size_histogram.pdf
    md5sum ${collectMultipleMetricsPrefix}.insert_size_metrics
 fi

 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
