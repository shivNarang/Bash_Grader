#!/bin/bash
read -p "Enter student's name: " name
read -p "Enter student's roll number: " roll_number
for file in *.csv; do
if [ $file != "main.csv" ]; then
filename=$(basename $file)
filename_without_extension="${filename%.*}"
read -p "Do you want to change marks in $filename_without_extension? (y/n): " choice
if [ $choice == "y" ]; then
read -p "Enter the marks you want to change to: " marks
sed -i "s/$roll_number,$name,.*$/$roll_number,$name,$marks/" $file
# awk -v exam=$filename_without_extension  -F, '{if(NR==1){ 
# for(i=1;i<=NF;i++){
# if($i==exam)
# {field=i;break}
# }
# }
# print field
# }' main.csv
fi
fi
done