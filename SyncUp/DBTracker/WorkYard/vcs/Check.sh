ProjectName=$(ls | grep ".csv")
INPUT=${ProjectName}
OLDIFS=$IFS
IFS=','
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read PipelineReleaseID ReleasepipelineName ReleaseDate ProjectName Summery ChangeRequest RowsUpdated SQLStatement TimeStamp
do
    echo "====================="
	echo "PipelineReleaseID   - ${PipelineReleaseID}"
	echo "ReleasepipelineName - ${ReleasepipelineName}"
	echo "ReleaseDate         - ${ReleaseDate}"
	echo "ProjectName         - ${ProjectName}"
	echo "Summery             - ${Summery}"
	echo "ChangeRequest       - ${ChangeRequest}"
	echo "RowsUpdated         - ${RowsUpdated}" 
	echo "SQLStatement        - ${SQLStatement}"
	echo "TimeStamp           - ${TimeStamp}"
    echo "====================="
done < $INPUT
IFS=$OLDIFS