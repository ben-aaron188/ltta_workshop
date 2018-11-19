cd output_dir
rm -rf * 
cd ..
rm -rf overview.txt
touch overview.txt

rm -rf nohup.out

nohup python3 -u process.py
