set -e
set -u

groupname=$1
MYINSTALLATIONDIR=$( cd -P "$( dirname "$0" )" && pwd )

##source config file (zinc-finger.gcc.rug.nl.cfg, leucine-zipper.gcc.rug.nl OR gattaca.cfg)
myhost=$(hostname)
. ${MYINSTALLATIONDIR}/${groupname}.cfg
. ${MYINSTALLATIONDIR}/${myhost}.cfg
. ${MYINSTALLATIONDIR}/sharedConfig.cfg

ALLFINISHED=()
ls ${LOGDIR}/*.pipeline.finished > ${LOGDIR}/AllProjects.pipeline.finished.csv
while read line 
do
	ALLFINISHED+=("${line} ")
done<${LOGDIR}/AllProjects.pipeline.finished.csv


for i in ${ALLFINISHED[@]}
do
	filename=$(basename $i)
	projectName="${filename%%.*}"
	for i in $(ls ${PROJECTSDIR}/${projectName}/*/rawdata/ngs/*); do if [ -L $i ];then readlink $i > ${LOGDIR}/${projectName}/${projectName}.rawdatalink ; fi;done

	while read line ; do dirname $line > ${LOGDIR}/${projectName}/${projectName}.rawdatalinkDirName; done<${LOGDIR}/${projectName}/${projectName}.rawdatalink

		rawDataName=$(while read line ; do basename $line ; done<${LOGDIR}/${projectName}/${projectName}.rawdatalinkDirName)

		echo "moving ${projectName} files to ${LOGDIR}/${projectName}/ and removing tmp finished files"
		if [[ -f ${LOGDIR}/${projectName}/${projectName}.pipeline.logger  && -f ${LOGDIR}/${projectName}/${projectName}.pipeline.started && -f ${LOGDIR}/${projectName}/${projectName}.rawdatalink && -f ${LOGDIR}/${projectName}/${projectName}.rawdatalinkDirName ]]
		then 
			touch ${LOGDIR}/${projectName}/${rawDataName}
			mv ${LOGDIR}/${projectName}.pipeline.finished ${LOGDIR}/${projectName}/

		else
			echo "there is/are missing some files:${projectName}.pipeline.logger or  ${projectName}.pipeline.started or ${projectName}/${projectName}.rawdatalink or ${projectName}.rawdatalinkDirName"
			echo "there is/are missing some files:${projectName}.pipeline.logger or  ${projectName}.pipeline.started or ${projectName}/${projectName}.rawdatalink or ${projectName}.rawdatalinkDirName" >> ${LOGDIR}/${projectName}/${projectName}.pipeline.logger
		fi
	if [ ! -f ${LOGDIR}/${projectName}/${projectName}.pipeline.finished.mailed ]
	then
		printf "The results can be found: ${PROJECTSDIR}/${projectName} \n\nCheers from the GCC :)"| mail -s "NGS_DNA pipeline is finished for project ${projectName} on `date +%d/%m/%Y` `date +%H:%M`" ${ONTVANGER}
		touch ${LOGDIR}/${projectName}/${projectName}.pipeline.finished.mailed

	fi

done

