c=$1
flag=0
if [ "$c" == "combine" ]; then
first_line=$(head -n 1 main.csv)
if echo $first_line | grep -q ",total"; then
./combine.sh
awk -f total.awk main.csv > total.csv
rm main.csv
mv total.csv main.csv
else
./combine.sh
fi
       fi

if [ "$c" == "upload" ]; then 
cp $2 ./
fi
if [ "$c" == "total" ]; then
first_line=$(head -n 1 main.csv)
if ! echo $first_line | grep -q ",total"; then
awk -f total.awk main.csv > total.csv
rm main.csv
mv total.csv main.csv
fi
fi
if [ "$c" == "git_init" ]; then
if [[ $# -eq 1 ]]; then
echo "please enter the repo name"
else
echo $2 > path-repo
if [ ! -d $2 ]; then
mkdir $2
fi
fi

# rm main.csv
fi

if [ "$c" == "git_commit" ]; then
if [ -f path-repo ]; then
repo_path=$(head -n 1 path-repo)
last_commit_id=$(tail -n 1 $repo_path/.git_log)
hash_value=$(shuf -i 1000000000000000-9999999999999999 -n 1)
echo $hash_value\($3\) >> $repo_path/.git_log
mkdir $repo_path/$hash_value
cp *.csv $repo_path/$hash_value

echo $last_commit_id
last_hashvalue=${last_commit_id:0:16}
# echo $last_hashvalue
 for file in $(find . -type f -not -path "./remote_repository/*"); do
        remote_file="remote_repository/${file#./}"
        if [ -f "$remote_file" ]; then
            if ! diff -q "$file" "$remote_file" >/dev/null; then
                echo "$file"
            fi
        fi
    done
else 
echo "Please run git_init first"
fi
fi
if [ "$c" == "git_checkout" ]; then
val=$3
repo_path=$(head -n 1 path-repo)
commit_id=$(sed '/$val /p' $repo_path/.git_log)
hash_value=${commit_id:0:16}
echo $hash_value
cp $repo_path/$hash_value/*.csv ./
fi

if [ "$c" == "update" ]; then
./update.sh
fi




#!/bin/bash

# Generate a random 16-digit number


# echo $random_number