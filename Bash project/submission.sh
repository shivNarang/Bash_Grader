#!/bin/bash
# Storing command line arguments in variable c for easy access
c=$1

if [ $# -eq 0 ]; then
echo "Please provide the command"
fi





# If the command is "combine", run the combine.sh script
if [ "$c" == "combine" ]; then
#head which is used to ecratct header of main.csv file in code
# will create problem if i am running combine for first time i.e i dont
#have main.csv file so i will check if main.csv is present or not
       if [ -f main.csv ]; then
       #this is customisation to make this command efficient
       #i am checking the number of csv files in the directory
       #and number of fields in the header of main.csv file
       let num_csv_files=$(ls -l ./*.csv | wc -l)
       let nooffields=$(awk -F, '{if(NR==1) print NF}' main.csv)
       
       first_line=$(head -n 1 main.csv)
       # taking first line of main.csv file and checking if it contains total column or not
       #If the pattern is found, the exit status is 0 (success); otherwise, it's 1 (failure)
       #for grep -q option
       #This if-else statements to make sure when i upload any new file in my directory
       # and then i run combine if i have total column in my main.csv file then it will run
       # combine.sh and then total.awk which is used to calculate the total of all the columns so my total_column remains updated
              if echo $first_line | grep -q ",total"; then
              #if pattern is found then we will run combine.sh and then total.awk
              #to get the total of all the columns
              #this is to make sure that if there is no change in my directory
              #then i dont need to run combine.sh and total.awk again
              if [[ ! $nooffields-3 -eq $num_csv_files-1 ]]; then
              #-3 of name,roll_number,total and -1 of main.csv file
              ./combine.sh
              #storing output of total.awk in total.csv file
              #removing main.csv file
              #renaming total.csv to main.csv
              #total.awk will calculate the total of all the columns
              awk -f total.awk main.csv > total.csv
              rm main.csv
              mv total.csv main.csv
              else
              echo "No new file added in the directory and your main.csv is upto date with total column"
              fi
              else
              #this is to make sure that if there is no change in my directory
              #then i dont need to run combine.sh again
              if [[ ! $nooffields-2 -eq $num_csv_files-1 ]]; then
              #-2 of name,roll_number and -1 of main.csv file
              ./combine.sh
              else
              echo "No new file added in the directory and your main.csv is upto date"
              fi
              fi
       else
       ./combine.sh
       fi
fi










#upload command is used to upload the file in the directory
if [ "$c" == "upload" ]; then 
#checking if the number of arguments are 2 or not
if [ "$#" -eq 2 ]; then
#checking if the file exists or not
if [ -f $2 ]; then
#checking if the file is csv file or not
if [[ $2 == *.csv ]]; then
# checking if the file is already present in the directory or not
filename=$(basename -- "$2")
if [ !  -f $filename ]; then
#copying the file in the directory
cp $2 ./
echo "File uploaded successfully Enjoy!!"
else
#prompting the user if the file is already present in the directory
#and asking if he wants to replace the file or not
echo "File already exists in the directory"
echo "Do you want to replace the file(y/n):"
#reading the user input
read var 
if [ "$var" == "y" ]; then
cp $2 ./
echo "File uploaded successfully Enjoy!!"
else
echo "ok your wish!!"
fi
fi
else
echo "Kindly upload csv file only"
fi
else
echo "File does not exist:Kindly check the file name"
fi
else
echo "Please provide the file name"
fi
fi











#total command is used to calculate the total of all the columns
if [ "$c" == "total" ]; then
#checking if the main.csv file is present or not
if [ -f main.csv ]; then
#taking the first line of the main.csv file
first_line=$(head -n 1 main.csv)
#checking if the first line contains total column or not
#If the pattern is found, the exit status is 0 (success); otherwise, it's 1 (failure)
#for grep -q option
#so that i dont run total.awk again and again
#total.awk will calculate the total of all the columns
if ! echo $first_line | grep -q ",total"; then
awk -f total.awk main.csv > total.csv
#rename the main.csv file to main.csv.bak
mv total.csv main.csv
else
echo "Total column already present in the main.csv file"
fi
else
echo "main.csv does not exist in the directory!! Kindly run combine command first"
fi
fi









#update command is used to update the main.csv file
if [ "$c" == "update" ]; then
#checking if the main.csv file is present or not
if [ -f main.csv ]; then
#running the update.sh script
./update.sh
else
echo "main.csv does not exist in the directory!! Kindly run combine command first"
fi
fi







#command to clean the main.csv file
if [ "$c" == "clean" ]; then
rm -f main.csv
fi








#command to initialise the git repository
if [ "$c" == "git_init" ]; then
if [ "$#" -eq 2 ]; then
#giving $2 as the repository name to the git.sh script
bash ./git.sh git_init $2
else
echo "Please provide the repository name"
fi
fi




if [ "$c" == "git_commit" ]; then
bash ./git.sh git_commit $2 "${@:3}"
fi



if [ "$c" == "git_checkout" ]; then
bash ./git.sh git_checkout ${@:2}
fi

#TIME FOR SOME EXTRA COMMANDS
#run total command to calculate the total of all the columns before
if [ "$c" == "analysis" ]; then
if [ "$#" -eq 2 ]; then
python3 analysis.py $2
else
echo "Please provide the roll number"
fi
fi

if [ "$c" == "overallanalysis" ]; then
python3 overallanalysis.py
fi
#NOw i am adding some advanced git commands
#i have implemented the git_init,git_commit and git_checkout commands using staging area and gitstatus
#you will definetely find it interesting

if [  "$c" == "git__init" ]; then
bash ./advancedgit.sh git__init $2
fi

if [ "$c" == "git__add" ]; then
bash ./advancedgit.sh git__add $2
fi

if [ "$c" == "git__commit" ]; then
bash ./advancedgit.sh git__commit $2 "${@:3}"
fi

if [ "$c" == "git__checkout" ]; then
bash ./advancedgit.sh git__checkout ${@:2}
fi

if [ "$c" == "git__status" ]; then
bash ./advancedgit.sh git__status
fi

if [ "$c" == "git__log" ]; then
bash ./advancedgit.sh git__log
fi
if [ "$c" == "git__show" ]; then
bash ./advancedgit.sh git__show ${@:2}
fi