printf "fold 1\n"
printf "with prediction model\t" 
perl GetScanTime.pl -k keyboard.txt -t test_0.txt -p predict_result0.txt -r rp01.txt
printf "no prediction   model\t" 
perl GetScanTime.pl -k keyboard.txt -t test_0.txt -r rp00.txt
printf "fold 2\n"
printf "with prediction model\t" 
perl GetScanTime.pl -k keyboard.txt -t test_1.txt -p predict_result1.txt -r rp11.txt
printf "no prediction   model\t" 
perl GetScanTime.pl -k keyboard.txt -t test_1.txt -r rp10.txt
printf "fold 3\n"
printf "with prediction model\t" 
perl GetScanTime.pl -k keyboard.txt -t test_2.txt -p predict_result2.txt -r rp21.txt
printf "no prediction   model\t" 
perl GetScanTime.pl -k keyboard.txt -t test_2.txt -r rp20.txt
printf "fold 4\n"
printf "with prediction model\t" 
perl GetScanTime.pl -k keyboard.txt -t test_3.txt -p predict_result3.txt -r rp31.txt
printf "no prediction   model\t" 
perl GetScanTime.pl -k keyboard.txt -t test_3.txt -r rp30.txt
printf "fold 5\n"
printf "with prediction model\t" 
perl GetScanTime.pl -k keyboard.txt -t test_4.txt -p predict_result4.txt -r rp41.txt
printf "no prediction   model\t" 
perl GetScanTime.pl -k keyboard.txt -t test_4.txt -r rp40.txt
printf "fold 6\n"
printf "with prediction model\t" 
perl GetScanTime.pl -k keyboard.txt -t test_5.txt -p predict_result5.txt -r rp51.txt
printf "no prediction   model\t" 
perl GetScanTime.pl -k keyboard.txt -t test_5.txt -r rp50.txt
printf "fold 7\n"
printf "with prediction model\t" 
perl GetScanTime.pl -k keyboard.txt -t test_6.txt -p predict_result6.txt -r rp61.txt
printf "no prediction   model\t" 
perl GetScanTime.pl -k keyboard.txt -t test_6.txt -r rp60.txt
printf "fold 8\n"
printf "with prediction model\t" 
perl GetScanTime.pl -k keyboard.txt -t test_7.txt -p predict_result7.txt -r rp71.txt
printf "no prediction   model\t" 
perl GetScanTime.pl -k keyboard.txt -t test_7.txt -r rp70.txt
printf "fold 9\n"
printf "with prediction model\t" 
perl GetScanTime.pl -k keyboard.txt -t test_8.txt -p predict_result8.txt -r rp81.txt
printf "no prediction   model\t" 
perl GetScanTime.pl -k keyboard.txt -t test_8.txt -r rp80.txt
printf "fold 10\n"
printf "with prediction model\t" 
perl GetScanTime.pl -k keyboard.txt -t test_9.txt -p predict_result9.txt -r rp91.txt
printf "no prediction   model\t" 
perl GetScanTime.pl -k keyboard.txt -t test_9.txt -r rp90.txt
