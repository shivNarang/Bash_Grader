#awk file to do total
BEGIN{
    FS=","
}
{
    #adding total in a header
    if(NR == 1) printf("%s,total\n",$0)
    else{
       sum=0
       #storing sum in variable sum
       for(i=3; i<=NF; i++){
       sum+=$i
       }
       #printing the line and appending sum in it
    printf("%s,%s\n",$0,sum)


    }
}