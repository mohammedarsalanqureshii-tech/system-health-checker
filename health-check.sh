#!/bin/bash

# =========================
# variables
# =========================

# Store current date in variable

DATE=$(date '+%Y-%M-%D %H:%M:%S')

#Name of the file where report will be saved

REPORT_FILE="health-report.txt"

# =========================
# Functions
# =========================

# Print a nice header

print_header() {
    echo "========================="
    echo "SYSTEM-HEALTH-REPORT"
    echo "Genarated : $DATE "
    echo "========================="
}

# Check CPU usage

check_cpu() {
    echo ""
    echo "--- CPU USAGE ---"
# Run top once, find cpu line, grab usage number
cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
echo "CPU usage : $cpu%"

# Warn if cpu usage is above 80%

if [ $(echo "$cpu > 80" | bc) -eq 1 ]
then
    echo "Warning : CPU usage is high!"
else
    echo "CPU usage is normal"
fi

}

# Check RAM usage
check_ram() {
   echo ""
   echo "---RAM USAGE---"

# Get total RAM from row 2 column 2
total=$(free -m | awk 'NR==2{print $2}')

#Get used RAM from row2 column 3
used=$(free -m | awk 'NR==2{print $3}')

# Calculate percentage
percent=$(free -m | awk 'NR==2{printf "%d", $3/$2*100}')

echo "Total RAM: ${total}MB"
echo "Used RAM: ${used}MB"
echo "Usage: {$percent}%"

# Warn if above 80%

if [ $percent -gt 80 ]
then
    echo "WARNING: RAM usage is high"
else
    echo "RAM usage is normal"
fi

}

# Check disk space
check_disk() {

echo ""
echo "--- DISK USAGE ---"

# Get disk usage percentage and remove the % symbol

disk=$(df / | awk 'NR==2{print $5}' | tr -d '%')

#Get used and total space

used_space=$(df -h / | awk 'NR==2{print $3}')
total_space=$(df -h / | awk 'NR==2{print $2}')

    echo "Total Disk : $total_space"
    echo "Used Disk : $used_space"
    echo "Usage : ${disk}%"

# Warn if above 80

if [ $disk -gt 80 ]
then
    echo "WARNING: Disk usage is high!"
else
    echo "Disk usage is normal"
fi

}

#Check if important folder is exist

check_directories() {
    echo ""
    echo "---IMPORTANT DIRECTORIES---"

# Loop through each important folder

for dir in /etc /var /home /tmp
do
    if [ -d $dir ]
    then
        echo "$dir Exist"
    else
        echo "$dir id Missing"
    fi
done

}

# Print footer at the end

print_footer() {

    echo ""
    echo "========================="
    echo "     END OF THE REPORT     "
    echo "========================="

}

# =========================
# Main-Run everything
# =========================

# {} group all function together
# tee show output on screen and saves to file

{
    print_header
    check_cpu
    check_ram
    check_disk
    check_directories
    print_footer
} | tee $REPORT_FILE

echo ""
echo "Report saved to $REPORT_FILE"

