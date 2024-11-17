#!/bin/bash
c=$1


#storing the path of the repository in the path_repo file
#in current directory
#storing author name and email also in my path repo file
if [ "$c" == "git_init" ]; then
echo $2 > path_repo
echo "Enter the author name"
read author
echo "Enter the email"
read email
echo "$author <$email>" >> path_repo
if [ ! -d $2 ]; then
mkdir $2
else
echo "Repository already exists"
fi
fi




#this is used to commit the changes to the repository
if [ "$c" == "git_commit" ]; then
if [ $# -le 2 ]; then
echo "Invalid command usage use git_commit -m <message>"
else
if [ $2 == "-m" ]; then
#checking if the path_repo file exists or not that will imply that the git_init has been run
      if [ -f path_repo ]; then
            message="${@:3}"
            #storing the path of the repository in the repo_path variable
            repo_path=$(head -n 1 path_repo)
            #storing the author name in the author variable
            author=$(tail -n 1 path_repo)
            #checking if the .git_log file exists or not
            #This is for my first commit in the repository
            #for the first commit i will store all the csv file of my directory in the repository
            #and for subsequent commits i will store the patches of the files that have been modified
            if [ ! -f $repo_path/.git_log ]; then
                  #generating a random hash value for the commit id shuf is used to generate random number
                  hash_value=$(shuf -i 1000000000000000-9999999999999999 -n 1)
                  echo "commit $hash_value" >> "$repo_path/.git_log"
                  echo -e "Author: $author" >> "$repo_path/.git_log"
                  echo -e "Date: $(date)" >> "$repo_path/.git_log"
                  echo -e "\n$message\n" >> "$repo_path/.git_log"
                  #creating a directory with the commit id as the name in the remote repository
                  mkdir $repo_path/$hash_value
                  #for the first commit i will store all the csv files in the repository
                  cp *.csv $repo_path/$hash_value
            else
                  last_commit_id=$(tail -n 7 $repo_path/.git_log)
                  # echo $last_commit_id
                  #store the commit id of the last commit so that i can tell which files have been modified
                  last_hashvalue=${last_commit_id:7:17}
                  last_hashvalue=${last_hashvalue// /}
                  last_hashvalue=$(echo $last_hashvalue | tr -d '\n')
                  #doing the same thing and gnerating random number for each commit
                  hash_value=$(shuf -i 1000000000000000-9999999999999999 -n 1)
                  echo "commit $hash_value" >> "$repo_path/.git_log"
                  echo -e "Author: $author" >> "$repo_path/.git_log"
                  echo -e "Date: $(date)" >> "$repo_path/.git_log"
                  echo -e "\n$message\n" >> "$repo_path/.git_log"
                  mkdir $repo_path/$hash_value
                  # cp *.csv $repo_path/$hash_value
                 
                 #-----------------------------------------------------------------------------------------------
                  firstcommit=$(head -n 1 $repo_path/.git_log)
                  #getting the first commit id
                  firstcommitid=${firstcommit:7:17}
                  #iterating over all the csv files in the directory
                  for file in ./*.csv; do
                  filename=$(basename $file)
                  #this is to check wether new file is added or not
                  if [ ! -f $repo_path/$firstcommitid/$filename ]; then
                  #if the file is not present in the first commit then it is newly added
                  echo "$filename is being  newly added"
                  #i will create a file with the same name in the first commit directory 
                  #later on i will modify my checkkout to include this case also
                  touch $repo_path/$firstcommitid/$filename
                  fi

                  #now i am checking if the file is modified or not using diff command
                  # i am comparing the file in my current directory with the file in the first commit directory
                  diff_output=$(diff -q "$filename" "$repo_path/$firstcommitid/$filename")
                  #if the diff_output is not empty then the file is modified
                  if [ -n "$diff_output" ]; then
                  #     echo "$filename is being modified"
                  diff  $repo_path/$firstcommitid/$filename ./$filename > $repo_path/$hash_value/$filename.patch
                  #if yes then i will create a patch file for the file and store it in the current commit directory
                  fi
                  done

                  #this segment  of code is to check wether particular file is deleted or not
                  #The logic is i will iterate over all files in my main.csv directory
                  #and check if file is present in my working directory
                  #if not present and also if it wasnt present in my last commit then it is deleted
                  #and i will create a patch file for that deleted file in my commit directory
                  # i will patch it wwith an empty file and later on in my checkout i will delete that file because it was empty
                  for file in $repo_path/$firstcommitid/*.csv; do
                  #i will check if file from first commit exist in my directory or not
                        if [ ! -f $(basename $file) ]; then
                        #if yes than i will check if it present in my last commit id
                        #i am doing this because if i delete any file i dont want to show
                        #everytime after each commit that i eg quiz1.csv is being deleted or not
                        #as i am storing patch file corresponding to deleted file which is designed as to empty 
                        #the say quiz1 file in first commit when i will do checkout
                        #so i have checked wether its present in last commit or not if not then definitely its being deleted 
                        #only after this commit i.e its my latest commit
                        if [ ! -f $repo_path/$last_hashvalue/$(basename $file).patch ]; then
                        echo "file $(basename $file) is being deleted"
                        fi
                        filename=$(basename $file)
                        touch $(basename $filename)
                        diff  $repo_path/$firstcommitid/$filename ./$filename > $repo_path/$hash_value/$filename.patch
                        rm $filename
                        #this means during checkout i have to delete this file because it will be empty
                        #this is additional case if my deleted file have patch file in previous commit
                        #if yes then i will check diff of these files if they are different that means its the latest commit after which i have deleted file
                        #i am doing all these to not display quiz1.csv is being deleted everytime
                        if [ -f $repo_path/$last_hashvalue/$(basename $file).patch ]; then
                        diffout=$(diff -q $repo_path/$last_hashvalue/$(basename $file).patch $repo_path/$hash_value/$filename.patch)
                        if [ -n "$diffout" ]; then
                        echo "file $(basename $file) is being deleted"
                        fi
                        fi
                  fi
            done
#this segment of code is to display the files that are being modified
#i will iterate over all the files in the current commit directory
#and check if the file is present in the last commit directory
# if not present then it is being modified
# if present then i will check if the file is modified or not using diff command
# if modified then i will display the file
#Also if my current commiy=t directory is not empty than i can iterate through it using for so i am first checking wether its empty or not
   if [ ! -z "$(ls -A $repo_path/$hash_value)" ]; then
                   for file in $repo_path/$hash_value/*; do
                     filename=$(basename $file)
                     #if not present in the last commit directory then it is being modified
                        if [ ! -f  $repo_path/$last_hashvalue/$filename ]; then
                        filename_without_extension="${filename%.*}"
                  echo "$filename_without_extension is being modified"
                        else
                        #if present then check if the file is modified or not
                        diff_output=$(diff -q "$file"  "$repo_path/$last_hashvalue/$filename")
                  if [ -n "$diff_output" ]; then
                        filename_without_extension="${filename%.*}"
                  echo "$filename_without_extension is being modified"
                  fi
                        fi
                  done
       #now else when my commit directory is empty then i will check if my last commit directory is empty or not
                  else
                  if [ ! -z "$(ls -A $repo_path/$last_hashvalue)" ]; then
                  #if my last commit directory is not empty then i will iterate over all the files in the last commit directory
                  #and definitely all that files are being modified becaue they are not in latest commit
                  for file in $repo_path/$last_hashvalue/*; do
                  if [[ "$file" == *.patch   ]]; then
                  filename=$(basename $file)
                  filename_without_extension="${filename%.*}"
                  echo "$filename_without_extension is being modified"
                  fi
                  done
                  #because my current commit directory is empty so no file is being modified and all files are in the same state as last commit
                  echo "Your files are in the same state as your first commit"
                  else
                  echo "No files is being modified and files are in the same state as last commit"
                  fi
                  fi
            fi
      else 
            echo "Please run git_init first"
      fi
      else 
            echo "Invalid command please check use -m option not $2:xD"
      fi
fi
fi

#THE LOGIC::::::
#my logic is first i capture commit id using below code which you will understand by reading it 
#rmove all the csv files from the working directory
#Then i will copy all the files from first-commit  to the current commit directory
#After that i will patch the files whose patch file is stored in my current commit directory
#Now i encorporated the case of newly added files and deleted files
#CASE1 : Newly added files
#if there is newly added file than during commit coding i have set if i add any new file than i will create a empty  file with the same name in the first commit directory
#and take its diff with the current file and store it in the current commit directory
#so during checkout i will check if the file is empty or not if empty then i will check wether patch file is present on that commit or not if no that means  this file was added after that commit
#CASE2 : Deleted files
#If the file is deleted then i will create a patch file for that file in the current commit directory and patch it with an empty file
#so during checkout i will delete that file because it is empty
#CASE3 : Modified files

#I will copy all the files from the first commit directory to the current commit directory
#and then i will patch the files that have been modified
#now is the time for git_checkout
if [ "$c" == "git_checkout" ]; then
#checking if the path_repo file exists or not that will imply that the git_init has been run
if [ -f path_repo ]; then
#if the number of arguments is 1 then i will ask the user to enter the commit id
      if [ $# -eq 1 ]; then
            echo "Please enter the commit id or -m <message> to checkout the commit id"
      else
            repo_path=$(head -n 1 path_repo)
            if [ $# -eq 2 ]; then
                  #if the user has entered the commit id then i will store it in the commit_ids variable
                  #this i a string that contains all the commit ids that have the commit id tha` user has entered`
                  commit_ids=$(grep  -E "commit $2[0-9]+$" $repo_path/.git_log | cut -d" " -f2)
                  #if the length of the commit_ids is 16 then i will store it in the commit_id variable
                  if [ ${#commit_ids} -eq 16 ]; then
                  commit_id=$commit_ids
                  #if the length of the commit_ids is 0 then i will display that commit id not found
                  elif [ ${#commit_ids} -eq 0 ]; then
                  echo "Commit id not found"
                  #then i will ask the user to say yes or no to the commit ids that are matched using grep
                  else
                        for i in $commit_ids; do
                        echo "$i:Do you want to checkout this commit id? (y/n)"
                              read ans
                              if [ $ans == "y" ]; then
                              commit_id=$i
                              break
                              fi    
                        done
                  fi
            #if the number of arguments is 3 then 
            else
            message=$3
            #finding the commit id that has the message that the user has entered or part of it
            commit_ids=$(grep -E "^$3.*$" $repo_path/.git_log)
            #if the length of the commit_ids is equal to the length of the message then i will store it in the commit_id variable
            if [ ${#commit_ids} -eq ${#message} ]; then
            commit_id_message=$commit_ids
            #if the length of the commit_ids is 0 then i will display that commit id not found
            elif [ ${#commit_ids} -eq 0 ]; then
            echo "Commit id not found"
            #then i will ask the user to say yes or no to the commit ids that are matched using grep
            else
            for i in $commit_ids; do
            echo "$i:Do you want to checkout this commit id message? (y/n)"
                  read ans
                  if [ $ans == "y" ]; then
                  commit_id_message=$i
                  break
                  fi    
            done
            fi
            #finding the commit id that has the message that the user has entered or part of it
            #-B 4 is used to display the 4 lines before the commit id
            #this is because the commit id is 4 lines before the message
            #so i will store the commit id in the commit_id variable
            commit_id_string=$(grep -B 4 "^$commit_id_message$" $repo_path/.git_log)
            commit_id=${commit_id_string:7:17}
           
            fi
            #removing the spaces and endlinecharacters from the commit_id

            commit_id=${commit_id// /}
            commit_id=$(echo $commit_id | tr -d '\n')
            #if the length of the commit_id is 16 then i will checkout the commit id
            # that means i have found commit id and now i will proceed for further work
            if [ ${#commit_id} -eq 16 ]; then
            echo $commit_id is being checked out 
            rm -f *.csv
            #getting the first commit id then trimming it
            firstcommit=$(head -n 1 $repo_path/.git_log)
            firstcommitid=${firstcommit:7:17}
            firstcommitid=${firstcommitid// /}
            firstcommitid=$(echo $firstcommitid | tr -d '\n')
            #if the commit id is equal to the first commit id then i will copy all the files from the first commit directory to the current commit directory
            #AS i was storing all the csv files in the first commit directory and using it references for other commits
            if [ $commit_id == $firstcommitid ]; then
            cp $repo_path/$commit_id/*.csv ./
            for file in ./*.csv; do
            if [ ! -s $file ]; then
            rm $file
            fi
            done
            else
            #if the commit id is not equal to the first commit id then i will copy all the files from the first commit directory to the current commit directory
            #and then i will patch the files that have been modified
            #If the file is empty then i will check if the patch file is present in the current commit directory 
            #if not present that means this new files was added ahter that commit
            for file in $repo_path/$firstcommitid/*; do
            # echo $file
            if [ ! -s $file ]; then
            filename=$(basename $file)
            if [ -f $commit_id/$filename.patch ]; then
            cp $file ./
            fi
            else
            cp $file ./
            fi
            done
       # echo $repo_path/$commit_id
                  if [ ! -z "$(ls -A $repo_path/$commit_id)" ]; then
                  #this segment of code is to patch the files that have been modified
                  #all the patch files are stored in the current commit directory
                  for file in $repo_path/$commit_id/*; do

                  # echo $file

                  filename=$(basename $file)
                  # if [ ! -f $filename ]; then
                  # touch $filename
                  # fi
                  # echo $filename
                  filename_without_extension="${filename%.*}"
                  # echo $filename_without_extension
                  #patch the file with the patch file stored in the current commit directory
                  #it will modify the file and store it in the current directory
                  patch $filename_without_extension $file > /dev/null                  #if the file is empty then i will delete the file because it is the case of delete as i have stored empty patch file if any file is delted
                  if [ ! -s "$filename_without_extension" ]; then
                  rm $filename_without_extension
                  fi
                  done
                  fi
            fi
      fi
      fi
else
      echo "Please run git_init first"
fi
fi



