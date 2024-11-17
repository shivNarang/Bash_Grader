c=$1
#checking if the command is git__init
#i am creating staging area in my current directory only ad inside that i am creating a txt file tobecommitted.txt which shows 
#wich files are to be committed in next commit
if [ "$c" == "git__init" ]; then
echo $2 > path__repo
#taking the author name and email from the user
echo "Enter the author name"
read author
echo "Enter the email"
read email
echo "Author: $author <$email>" >> path__repo
mkdir stagingarea
touch stagingarea/tobecommitted.txt
mkdir $2
touch $2/.git_log
fi


#command to add the files to the staging area
if [ "$c" == "git__add" ]; then
    if [ -f path__repo ]; then
    #if argument2 is . then i will add all the files in the current directory to the staging area if that file is not already present
    #if the file is already present then i will check if the file is modified or not using diff command and if it is modified then i will add it to the staging area ALSO i will add the file to the tobecommitted.txt file
        if [ $2 == "." ]; then
            cp *.csv stagingarea
            for file in stagingarea/*.csv; do
            filename=$(basename $file)
            repo_path=$(head -n 1 path__repo)
            #this condition is if the git log file is empty or not
    #if it is not empty then i will check if the file is modified or not from previous commit and if it is modified then i will add it to the tobecommitted.txt file
                if [ -s "$repo_path/.git_log" ]; then
                last_commit_id=$(tail -n 7 $repo_path/.git_log)
                last_commit_id=$(echo $last_commit_id | cut -d " " -f2)
                diff_output=$(diff -q "$file" "$repo_path/$last_commit_id/$filename")
                if [ -n "$diff_output" ]; then
                
                if ! grep -i -q "^$filename" stagingarea/tobecommitted.txt; then
                echo "$filename" >> stagingarea/tobecommitted.txt
                fi
                fi
                #if it is empty that means it is my first commit then i will add all the files to the tobecommitted.txt file
                else 
                for file in ./*.csv; do
                filename=$(basename $file)

                if ! grep -i -q "^$filename" stagingarea/tobecommitted.txt; then
                echo "$filename" >> stagingarea/tobecommitted.txt
                fi
                done
            fi
            done
        #if the argument is not . then i will add the files that are mentioned in the arguments to the staging area
        else
        #i am using a while loop to iterate over all the arguments that are passed to the function
            let i=2
            while [ $i -le $# ]; do
            # if the file is already present in the staging area then i will check if the file is modified or not
            #if modified then i will add it to the staging area and to the tobecommitted.txt file
            #if not modified then i will display that the file is not modified
            if [ -f ./stagingarea/${!i} ]; then
            diff_output=$(diff -q ${!i} stagingarea/${!i})
            if [ -n "$diff_output" ]; then
            cp ${!i} ./stagingarea
            if ! grep -i -q "^${!i}" stagingarea/tobecommitted.txt; then
            echo ${!i} >> stagingarea/tobecommitted.txt
            fi
            else
            echo "This file is not modified from previous added version in staging area"
            fi
            #if the file is not present in the staging area then i will add it to the staging area and to the tobecommitted.txt file
            else
            cp ${!i} ./stagingarea
            echo ${!i} >> stagingarea/tobecommitted.txt
            fi
            i=$((i+1))
            done
            fi
    else
        echo "Please run git_init first"
    fi
fi

#git commit command to commit the files that are added to the staging area
if [ "$c" == "git__commit" ]; then
#error handling
    if [ -f path__repo ]; then
    #error handling

    if [ $2 == "-m" ]; then
    #extracting the path of the repository from the path__repo file
repo_path=$(head -n 1 path__repo)
#if the tobecommitted.txt file is not empty then i will commit the files that are added to the staging area
 if [ -s "./stagingarea/tobecommitted.txt" ]; then
 hash_value=$(shuf -i 1000000000000000-9999999999999999 -n 1)
 author=$(head -n 2 path__repo | tail -n 1)
 message="${@:3}"
    echo "commit $hash_value" >> "$repo_path/.git_log"
    echo -e "Author: $author" >> "$repo_path/.git_log"
    echo -e "Date: $(date)" >> "$repo_path/.git_log"
    echo -e "\n$message\n" >> "$repo_path/.git_log"
    #creating a directory with the commit id as the name in the remote repository
    mkdir $repo_path/$hash_value
    #this case is to handle deletion of files . I will check if any file is present in the staging area and not present in the current directory then i will remove that file from the staging area
    #because that file is deleted
            for file in stagingarea/*.csv; do
            filename=$(basename $file)
            if [ ! -f "$filename" ]; then
        rm $file
            fi
            done
  #coppuing the files from the staging area to the remote repository
    cp stagingarea/*.csv $repo_path/$hash_value
    echo "Files that are modified from last commit are"
    echo -e "\033[32m$(cat stagingarea/tobecommitted.txt)\033[0m"
 #resseting the tobecommitted.txt file
    rm stagingarea/tobecommitted.txt
    touch stagingarea/tobecommitted.txt
    else
    #if staging area/tocommitted.txt is empty then i will display that no changes are added to commit
    bash ./advancedgit.sh git__status
    echo "No changes added to commit"
    fi
# elif [ $2 == "-am"]
# for file in stagingarea/*.csv; do
# filename=$(basename $file)
# if [ ]



else
echo "Please chose valid option -m "
fi
else
    echo "Please run git_init first"
fi
fi

#git checkout command to checkout the commit id

if [ "$c" == "git__checkout" ]; then
#checking if the path_repo file exists or not that will imply that the git_init has been run
 if [ -f path__repo ]; then
 #if the number of arguments is 1 then i will ask the user to enter the commit id
      if [ $# -eq 1 ]; then
            echo "Please enter the commit id or -m <message> to checkout the commit id"
      else
            repo_path=$(head -n 1 path__repo)
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
            echo $commit_id
            cp $repo_path/$commit_id/*.csv ./
                  fi
            
      fi
 else
      echo "Please run git_init first"
  fi
fi

#git log command to display the log of the commits
if [ "$c" == "git__log" ]; then
if [ -f path__repo ]; then
repo_path=$(head -n 1 path__repo)
#displaying the log of the commits in color yellow using echo -e command and the color code
echo -e "\033[33m$(cat "$repo_path/.git_log")\033[0m"

else
echo "Please run git_init first"
fi
fi



#git status command to display the status of the files
if [ "$c" == "git__status" ]; then
if [ -f path__repo ]; then
repo_path=$(head -n 1 path__repo)
if [ -d stagingarea ]; then
#checking if the staging area is empty or not and if it is not empty then i will display the files that are to be committed in tobecommitted.txt file
if [ ! -z "$(ls -A stagingarea)" ]; then
echo "On branch master"

echo "Changes to be committed:"
echo "   (use git_restore  <file>... to unstage)"
echo -e "\033[32m$(cat stagingarea/tobecommitted.txt)\033[0m"


#this is to display the files that are modified from the staging area files as it is equivalent to compaing the files with the previous commit
echo "Changes not staged for commit:"
echo "   (use git _add <file>... to update what will be committed)"
for file in stagingarea/*.csv; do
filename=$(basename $file)
if [ -f "$filename" ]; then
diff_output=$(diff -q "$file" "$filename")
if [ -n "$diff_output" ]; then
echo -e "     \e[31mmodified: $filename\e[0m"
fi
fi
done
else 
echo -e "Staging area is empty\n"
fi
#this is to display the files that are untracked
#files that are present in the current directory but not in the staging area
echo Untracked files:
echo "     ( use git_add <file>... to include in what will be committed)"
for file in ./*.csv; do
filename=$(basename $file)
if [ ! -f stagingarea/$filename ]; then
echo -e "     \e[31m$filename\e[0m"
fi
done
fi
else
echo "Please run git_init first"
fi
fi



#git show is capturing commit id like gitchecout command and then displaying the file that is present in the commit id
if [ "$c" == "git__show" ]; then
if [ -f path__repo ]; then
    repo_path=$(head -n 1 path__repo)
    if [ $2 == ":" ]; then
        if [ -f stagingarea/$3 ]; then
        cat stagingarea/$3
        else
        echo "file $3 not found in staging area"
        fi
    else

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
            commit_id=${commit_id// /}
            commit_id=$(echo $commit_id | tr -d '\n')
            if [ -f $repo_path/$commit_id/$3 ]; then
            cat $repo_path/$commit_id/$3
            else 
            echo "file $3 not found"
            fi
        fi

    fi
else
    echo "Please run git_init first"
fi
fi