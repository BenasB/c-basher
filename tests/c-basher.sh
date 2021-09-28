#!/bin/bash
# c-basher by Benas Budrys 2021

die () {
    echo -e $'\n'"$@"
    exit 1
}

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

project_root=$(dirname $(dirname $(realpath $0 )))
output_dir="bin"
tests_dir="tests"
output_file="output"
cases_file="cases.txt"
ignore_file="ignore.txt"

task="gcc $project_root/$1 -o $project_root/$output_dir/$output_file"

echo "Project root: $project_root"

[ "$#" -ge 1 ] || die "Error: please specify the source file name (relative to project root)"

if ! [ -f "$1" ]; then
    die "Error: source file '$1' does not exist."
fi

# Get optional arguments
OPTIND=2 # Skip the first argument (since its not optional)
while getopts ":c:t:" opt; do
    case $opt in
        c) cases_file="$OPTARG"
        ;;
        t) task="$OPTARG"
        ;;
        \?) die "Invalid option -$OPTARG"
        ;;
    esac

    case $OPTARG in
        -*) die "Option $opt needs a valid argument"
        ;;
    esac
done

if ! [ -f "$project_root/$tests_dir/$cases_file" ]; then
    die "Error: case file '$cases_file' does not exist in '$tests_dir/' directory."
fi

ignore=1
if ! [ -f "$project_root/$tests_dir/$ignore_file" ]; then
    echo -e "Warning: ignore file '$ignore_file' is missing, proceeding without it.\n"
    ignore=0
fi

if ! [ -d "$project_root/$output_dir" ]; then
    echo -e "Warning: $output_dir/ folder is missing in project root, creating it\n"
else
    echo -e "Cleaning: $output_dir/\n"
    rm -rf $project_root/$output_dir
fi

mkdir $project_root/$output_dir

echo "Compiling"
$task
if [ "$?" -ne 0 ]; then 
    die "Error: compilation failed, tests will not run"
else
    echo -e "Done Compiling"
fi

if ! [ -f "$project_root/$output_dir/$output_file" ]; then
    die "Error: $output_file was not found in $output_dir/. Maybe compilation did not generate it?"
fi

echo -e "\nExecuting\n"

test_count=0
passed_count=0
failed_count=0

while read test_name || [ -n "$test_name" ]; do
    [ -z "$test_name" ] && continue

    # Get test input
    read input_data
    while read new_line || [ -n "$new_line" ]; do
        [ -z "$new_line" ] && break
        input_data="${input_data} ${new_line}"
    done
 
    # Get expected outcome
    read expected_data
    while read new_line || [ -n "$new_line" ]; do
        [ -z "$new_line" ] && break
        expected_data="${expected_data} ${new_line}"
    done

    # Run compiled binary
    received_data=$(echo "$input_data" | $project_root/$output_dir/$output_file)

    if [ $ignore = 1 ] ; then
        while read ignore_line || [ -n "$ignore_line" ]; do
            received_data=${received_data/$ignore_line/}
        done < $project_root/$tests_dir/$ignore_file
    fi

    # Remove newlines
    received_data=$(echo $received_data | sed ':a;N;$!ba;s/\n\n/ /g')

    ((test_count++))
    if [ "$expected_data" = "$received_data" ]; then 
        echo -e "$test_count. $test_name: ${GREEN}PASSED${NC}"
        ((passed_count++))
    else
        echo -e "$test_count. $test_name: ${RED}FAILED${NC}"
        ((failed_count++))
        echo -e "Expected:\n$expected_data"
        echo -e "Recieved:\n$received_data"
    fi

done < $project_root/$tests_dir/$cases_file

echo -e "\nTotal tests: $test_count\nPassed: ${GREEN}$passed_count${NC}\nFailed: ${RED}$failed_count${NC}"

if [ "$failed_count" -ne 0 ] ; then
    die "Some tests ${RED}failed${NC}"
else
    echo -e "\nAll tests ${GREEN}passed${NC}"
fi