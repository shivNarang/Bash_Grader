BEGIN{
    FS=","
}
{
    if(NR == 1) printf("%s,total\n",$0)
    else{
       sum=0
       for(i=3; i<=NF; i++){
       sum+=$i
       }
    printf("%s,%s\n",$0,sum)


    }
}