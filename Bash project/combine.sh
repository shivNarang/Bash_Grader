#!/bin/bash
#this file is used to combine all the csv files into one main.csv file
#adding header to main.csv file
echo "Roll_Number,Name" > main.csv
#iterating over all the csv files
#this is variable to keep track of the number of fields in the main.csv file
let i=2
#iterating over all files present in my directory
for file in ./*.csv; do
    #checking if the file is not main.csv file
    if [ "$file" != "./main.csv" ]; then
        #basename is used to get the name of the file
        #${filename%.*} is used to remove the extension of the file
        # i am doing this to get the name of the file without extension
        # so that i can add it to the header of the main.csv file
        filename=$(basename $file)
        filename_without_extension="${filename%.*}"
        # using sed to substitute the first line of the main.csv file $(end of the line) with the ,filename_without_extension
        sed -i "1s/$/,$filename_without_extension/" main.csv
        #incrementing the number of fields in the main.csv file
        i=$((i+1))
        #i am doing this so if i encounter any new student in the new file
        #i can add the new field to the main.csv file
        
        let x=i
        str=""
        while [ $x -gt 3 ]; do
            str="$str,""a"
            x=$((x-1))
        done 
       
        # doing this i will get a string str which have a in it number of field-2 times so that if
        # i encounter any new student in csv file which is not in my main.csv file then i will
        #add that student to the main.csv file using $roll_Number,$name$str,$marks
        #because student was absent before that much times
        #-----------------------------------------------------------------------------------------------


        #reading the file line by line also -n line is used to read the last line of the file if it does not end with a new line
        while IFS=, read -r line || [[ -n "$line" ]]; do
        #-r is used to prevent backslashes from being interpreted as escape characters
            lineTemp=$(echo $line | tr -d '\n')
            lineTemp=$(echo $line | tr -d '\r')
            #trimming the line and storing it in lineTemp

            name=$(echo $lineTemp | cut -d',' -f2)
            roll_Number=$(echo $lineTemp | cut -d',' -f1)
            marks=$(echo $lineTemp | cut -d',' -f3)
            #getting the roll number marks and name from the line 
            roll_Number="${roll_Number^^}" 
            #upper casing the roll number so that 23b1075 and 23B1075 are treated same
            #^^ is used for this catgpt se pucha tha
            #matching the regex for valid rollnumber of form N
            
            if [[ ! "$line" == "Roll_Number,Name,Marks" ]]; then
             #doing this to make sure that i am not adding the header of the csv file to the main.csv file
             #matching the rollnumber entry in main.csv file
            
             #if the roll number is present in the main.csv file then i will update the marks of the student
            if grep -q "$roll_Number" main.csv; then
                sed -i "s/\($roll_Number,.*$\)/\1,$marks/" main.csv
            else
            #if not present then i will add new field in the below format where i will add a's before it
                echo $roll_Number,$name$str,$marks >> main.csv
                fi
            fi
            
        done < "$file"

#Atlast i will check all the entries of main.csv if a partricular student was in main.csv file but not in corresponding file like quiz1 so i will add a at that 
#field of main.csv 
# using -v i can send bash variable to awk i send i which is number of fields it is check nooffields with that i will add a to them
  awk -v field="$i" -F, '{if( NF != field ) {printf"%s,a\n",$0} else print $0}' main.csv > temp.csv
                    mv temp.csv main.csv
            fi
done
         