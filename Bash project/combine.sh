#!/bin/bash
    touch main.csv
    echo "Roll_Number,Name" > main.csv

    file_counter=0  
    for file in ./*.csv; do
        if [ "$file" != "./main.csv" ] ; then
            # echo -e "\n" >> $file
            echo "Processing $file"
            while IFS=, read -r line || [[ -n "$line" ]]; do
                lineTemp=$(echo $line | tr -d '\n')
                lineTemp=$(echo $line | tr -d '\r')
                roll_Number=$(echo $lineTemp | cut -d',' -f1)
                Name=$(echo $lineTemp | cut -d',' -f2)
                marks=$(echo $lineTemp | cut -d',' -f3)
                if [[ "$roll_Number" =~ ^[0-9].*$ ]]; then
                 if grep -i -q "^$roll_Number," main.csv; then
                    echo "Student $student is already present in main.csv"
                 else
                   echo $roll_Number,$Name>> main.csv
                 fi          
                fi
                
            done < "$file"
        
        fi
        done
        for file in ./*.csv; do
            if [ "$file" != "./main.csv" ]; then
             filename=$(basename $file)
            filename_without_extension="${filename%.*}"
            echo $filename_without_extension
           sed -i "1s/$/,$filename_without_extension/" main.csv

                echo "Processing $file"
                while IFS=, read -r line || [[ -n "$line" ]]; do
                lineTemp=$(echo $line | tr -d '\n')
                lineTemp=$(echo $line | tr -d '\r')
                

                roll_Number=$(echo $lineTemp | cut -d',' -f1)
                marks=$(echo $lineTemp | cut -d',' -f3)
                    if [[ "$roll_Number" =~ ^[0-9].*$ ]]; then
                    sed -i "s/\($roll_Number,.*$\)/\1,$marks/I" main.csv
                    fi
                done < "$file"



                # awk -F, '{if( $0 ~ "^[0-9]+$") {printf"%s,a\n",$0}}' main.csv
                while IFS=, read -r line || [[ -n "$line" ]]; do
                lineTemp=$(echo $line | tr -d '\n')
                lineTemp=$(echo $line | tr -d '\r')
                roll_Number=$(echo $lineTemp | cut -d',' -f1)
                Name=$(echo $lineTemp | cut -d',' -f2)
                marks=$(echo $lineTemp | cut -d',' -f3)
                if [[ "$roll_Number" =~ ^[0-9].*$ ]]; then
                if ! grep -i -q "^$roll_Number," $file ; then   
                sed -i "/^$roll_Number,/ s/$/,a/I" main.csv
                fi
                fi
                done < "main.csv"
            fi
        done
        # echo "hhi" >> main.csv
         