a=$(awk -F ':::' '{print $8}' DidIt-SQ-CREATE.txt | wc -c)
echo "Total Number of characters are ${a}"
if [ $a -gt 36760 ]
  then
    echo "WordCount is Greater than Limit"
   else
     echo "Every thing in Limit"
fi


#DidIt-SQ-CREATE.txt
#DidIt-SQ-DEF.txt