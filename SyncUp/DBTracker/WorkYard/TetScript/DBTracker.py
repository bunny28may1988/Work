import os
import re
import shutil
import subprocess

def main():
    # Remove test-gen.csv if exists
    if os.path.isfile("test-gen.csv"):
        os.remove("test-gen.csv")

    # Remove SQL statement files if they exist
    sql_files = [f for f in os.listdir() if re.match(r'SQ.*', f)]
    for sql_file in sql_files:
        os.remove(sql_file)

    # Rename Agent log files
    agent_logs = [f for f in os.listdir() if re.match(r'.*Agent.*\.log', f)]
    for log in agent_logs:
        new_name = log.replace(' ', '')
        shutil.move(log, new_name)

    varfile = next((f for f in os.listdir() if re.match(r'.*Agent.*\.log', f)), None)
    if not varfile:
        exit(1)

    with open(varfile, 'r') as file:
        content = file.read()

    PipelineReleaseID_match = re.search(r'RELEASE_RELEASEID.*\[(.*?)\]', content)
    ReleasepipelineName_match = re.search(r'RELEASE_DEFINITIONNAME.*\[(.*?)\]', content)
    ReleaseDate_match = re.search(r'RELEASE_DEPLOYMENT_STARTTIME.*\[(.*?)\]', content)
    DBName_match = re.search(r'DEFINE _CONNECT_IDENTIFIER.*?/(.*?)/', content)

    if PipelineReleaseID_match and ReleasepipelineName_match and ReleaseDate_match and DBName_match:
        PipelineReleaseID = PipelineReleaseID_match.group(1)
        ReleasepipelineName = ReleasepipelineName_match.group(1)
        ReleaseDate = ReleaseDate_match.group(1).split()[0]
        DBName = DBName_match.group(1)
    else:
        print("Error: Required information not found in the log file.")
        exit(1)

    ProjectName = ReleasepipelineName
    Summery = "Some Static Content!!!"
    ChangeRequest = re.search(r'\bCRQ\b.* (\S+)', content)
    ChangeRequest = ChangeRequest.group(1) if ChangeRequest and len(ChangeRequest.group(1)) > 3 else "Not Specified"
    SchemaUser_match = re.search(r'DEFINE _USER.*?="(.*?)"', content)
    if SchemaUser_match:
        SchemaUser = SchemaUser_match.group(1)
    else:
        SchemaUser = "Not Specified"

    print(f"""
    #############################################
    PipelineReleaseID={PipelineReleaseID}
    ReleasepipelineName={ReleasepipelineName}
    ReleaseDate={ReleaseDate}
    ProjectName={ProjectName}
    Summery={Summery}
    ChangeRequest={ChangeRequest}
    RowsUpdated="Not Applicable"
    #############################################
    """)

    patterns = [
        r"SQL> DEF.*?SQL>",
        r"SQL> CREATE.*?SQL>",
        r"SQL> \EXEC.*?SQL>",
        r"SQL> exec.*?SQL>",
        r"SQL> GRANT.*?SQL>",
        r"SQL> update.*?commit",
        r"SQL> Insert.*?SQL>"
    ]

    fileName = next((f for f in os.listdir() if re.match(r'[0-9]_Dep.*\.log', f)), None)
    if not fileName:
        exit(1)

    for pattern in patterns:
        print(f"Running for Pattern {pattern}")
        match = re.search(r'>(.*?)\/', pattern)
        if match:
            file = match.group(1).strip()
            with open(fileName, 'r') as file_content:
                matches = re.findall(pattern, file_content.read(), re.DOTALL)
                with open(f"Time-{file}.txt", 'w') as time_file, open(f"SQ-{file}.txt", 'w') as sq_file:
                    for match in matches:
                        time_file.write(match.split()[0] + '\n')
                        sq_file.write(' '.join(match.split()[1:]) + '\n')
        else:
            print(f"No match found for pattern: {pattern}")

    for stat in [f for f in os.listdir() if re.match(r'SQ.*', f)]:
        if stat == "SQ-update.txt":
            process_stat_file(stat, fileName, PipelineReleaseID, ReleasepipelineName, ReleaseDate, ProjectName, Summery, ChangeRequest, "update")
        elif stat == "SQ-Insert.txt":
            process_stat_file(stat, fileName, PipelineReleaseID, ReleasepipelineName, ReleaseDate, ProjectName, Summery, ChangeRequest, "Insert")
        else:
            process_other_stat_files(stat, PipelineReleaseID, ReleasepipelineName, ReleaseDate, ProjectName, Summery, ChangeRequest)

    with open(f"{ProjectName}.csv", 'w') as csv_file:
        csv_file.write("PipelineReleaseID,ReleasePipelineName,ReleaseDate,ProjectName,Summary,ChangeTicket,RowsUpdated,SQLStatement,TimeStamp\n")
        for fin in [f for f in os.listdir() if re.match(r'DidIt.*', f)]:
            with open(fin, 'r') as fin_file:
                content = fin_file.read()
                columns = content.split(':::')
                csv_file.write(','.join(columns) + '\n')

    for stat in [f for f in os.listdir() if re.match(r'.*\.txt', f)]:
        os.remove(stat)

def process_stat_file(stat, fileName, PipelineReleaseID, ReleasepipelineName, ReleaseDate, ProjectName, Summery, ChangeRequest, keyword):
    with open(stat, 'r') as stat_file:
        stat_content = stat_file.read()
    with open(fileName, 'r') as file_content:
        file_content = file_content.read()

    matches = re.findall(rf'SQL> {keyword}.*', stat_content, re.IGNORECASE)
    var = len(matches)
    rows_updated = re.findall(r'^[0-9]', stat_content, re.MULTILINE)
    timestamps = re.findall(rf'SQL> {keyword}.*', file_content, re.IGNORECASE)

    for i in range(var):
        file_read = matches[i]
        RowsUpdated = rows_updated[i]
        TimeStamp = timestamps[i].split()[0]
        final_stat = f"{PipelineReleaseID},{ReleasepipelineName},{ReleaseDate},{ProjectName},{Summery},{ChangeRequest},{RowsUpdated},{file_read},{TimeStamp}"
        with open(f"{i+1}-Final-{stat}", 'w') as final_file:
            final_file.write(final_stat)
        subprocess.run(["ex", "+%j", "+%p", "-scq!", f"{i+1}-Final-{stat}"], stdout=subprocess.PIPE)
        with open(f"{i+1}-Finally-{stat}", 'w') as final_file:
            final_file.write(final_stat.replace('\n', ''))
        with open(f"DidIt-{i+1}-{stat}", 'w') as didit_file:
            didit_file.write(final_stat.replace(',', ':::'))

def process_other_stat_files(stat, PipelineReleaseID, ReleasepipelineName, ReleaseDate, ProjectName, Summery, ChangeRequest):
    with open(stat, 'r') as stat_file:
        file_read = stat_file.read().replace('\n', '')
    a = stat.split('-')[1]
    tme = f"Time-{a}"
    with open(tme, 'r') as time_file:
        TimeStamp = time_file.read().strip()
    final_stat = f"{PipelineReleaseID},{ReleasepipelineName},{ReleaseDate},{ProjectName},{Summery},{ChangeRequest},Not Applicable,{file_read},{TimeStamp}"
    with open(f"Final-{stat}", 'w') as final_file:
        final_file.write(final_stat)
    subprocess.run(["ex", "+%j", "+%p", "-scq!", f"Final-{stat}"], stdout=subprocess.PIPE)
    with open(f"Finally-{stat}", 'w') as final_file:
        final_file.write(final_stat.replace('\n', ''))
    with open(f"DidIt-{stat}", 'w') as didit_file:
        didit_file.write(final_stat.replace(',', ':::'))

if __name__ == "__main__":
    main()