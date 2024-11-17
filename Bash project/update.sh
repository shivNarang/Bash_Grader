#!/bin/bash
#this file is used to update the marks of the student
#taking the name of the student as input
read -p "Enter student's name: " name
#taking the roll number of the student as input
read -p "Enter student's roll number: " roll_number
#checking if the student is present in the file or not
#-i is used to ignore the case
#if yes then taking the new marks as input
if grep -q -i "^$roll_number,$name," main.csv; then
#uppercasing the roll number so that 23b1075 and 23B1075 are treated same
roll_number="${roll_number^^}"
#this is used to check if the total field is present in the main.csv file
#so that i can update the total field of the student if present!
first_line=$(head -n 1 main.csv)
#checking if the first line contains total column or not
if echo $first_line | grep -q ",total"; then
istotalpresent="true"
else
istotalpresent="false"
fi
#iterating over all the csv files in the directory
for file in *.csv; do
#checking if the file is not main.csv file
if [ $file != "main.csv" ]; then
#basename is used to get the name of the file
#${filename%.*} is used to remove the extension of the file
filename=$(basename $file)
filename_without_extension="${filename%.*}"
#taking input from the user if he wants to change the marks
#in the particuolar exam or not
read -p "Do you want to change marks in $filename_without_extension? (Y/N): " choice
choice="${choice^^}"
#checking if the user wants to change the marks or not
if [ $choice == "Y" ]; then

read -p "Enter the marks you want to change to: " marks
#changing the marks in the file using awk
#-v is used to pass the variable to the awk 
#i am sending the roll number and marks to the awk
#this awk is to change the marks of the student in the particular file
#and not in the main.csv file
#-F, is used to set the field separator as ,
#i am checking if the first field of the file is equal to the roll number
#if yes then i am changing the marks of the student
#and then printing the whole line
awk -v roll=$roll_number -v marks=$marks -F, '{
if($1==roll){
$3=marks
}
for(i=1; i<NF; i++){
printf("%s,", $i)}
printf("%s", $NF)
printf("\n")
}' $file > t.csv
mv t.csv $file

#calculating no of fields in the main.csv file in header
# so that i can change marks of that student in the main.csv file
#using awk and then storing the output in fieldval
fieldval=$(awk -v exam=$filename_without_extension  -F, '{if(NR==1){
for(i=1;i<=NF;i++){
if($i==exam)
print i
}
}
}' main.csv)


# echo $istotalpresent
#sending the marks, roll number, fieldval and istotalpresent to the awk
# #if total is present then i will subtract the previous marks of the student
#from the total and then add the new marks to the total
#if not present then i will just change the marks of the student
awk -v marks=$marks -v roll=$roll_number -v field=$fieldval -v istotalpresent=$istotalpresent -F, '{
    # print (is totalpresent)
if($1==roll){
   
    if(istotalpresent=="true") $NF=$NF-$field+marks
$field=marks
}
#
for(i=1; i<NF; i++){
    printf("%s,", $i)}
    printf("%s", $NF)
    printf("\n")
}' main.csv > temp.csv
mv temp.csv main.csv
# echo $fieldval
echo "Marks changed in $filename_without_extension"

elif [ $choice == "N" ]; then
echo "Marks not changed in $filename_without_extension"
else
echo "Invalid choice"

fi

fi
done
else
echo "Student not found in the main.csv file"
fi