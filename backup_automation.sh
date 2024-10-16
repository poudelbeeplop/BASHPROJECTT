#!/bin/bash

# Function to display script usage/help information
function display_usage() {
    echo "Usage: $(basename "$0") -s <source_dir> -d <destination_dir> [-c] [-e <email>] [-h]"
    echo "Options:"
    echo "  -s <source_dir>: Specify the source directory to back up."
    echo "  -d <destination_dir>: Specify the destination directory for the backup."
    echo "  -c: Compress the backup using tar."
    echo "  -e <email>: Send an email notification on completion."
    echo "  -h: Display this help information."
}

# Check if no arguments are provided
if [[ $# -eq 0 || "$1" == "-h" ]]; then
    display_usage
    exit 0
fi

# Initialize variables
source_dir=""
destination_dir=""
compress=false
email=""

# Process command-line options and arguments
while getopts ":s:d:ce:h" opt; do
    case $opt in
        s) source_dir="$OPTARG" ;;
        d) destination_dir="$OPTARG" ;;
        c) compress=true ;;
        e) email="$OPTARG" ;;
        h) display_usage; exit 0 ;;
        \?) echo "Invalid option: -$OPTARG"; display_usage; exit 1 ;;
        :) echo "Option -$OPTARG requires an argument."; display_usage; exit 1 ;;
    esac
done

# Check if source directory exists
if [[ ! -d $source_dir ]]; then
    echo "Error: Source directory '$source_dir' does not exist."
    exit 1
fi

# Create the destination directory if it does not exist
mkdir -p "$destination_dir"

# Get the current timestamp for backup filename
timestamp=$(date +"%Y%m%d_%H%M%S")
backup_file="$destination_dir/backup_$timestamp"

# Perform the backup operation
if [[ $compress == true ]]; then
    tar -czf "$backup_file.tar.gz" -C "$source_dir" .
    echo "Backup created at: $backup_file.tar.gz"
else
    cp -r "$source_dir/"* "$backup_file/"
    echo "Backup created at: $backup_file"
fi

# Log the backup operation
log_file="$destination_dir/backup_log.txt"
echo "Backup created on $(date) from '$source_dir' to '$backup_file'" >> "$log_file"

# Send email notification if an email address was provided
if [[ -n $email ]]; then
    echo "Backup completed successfully." | mail -s "Backup Notification" "$email"
fi

echo "Backup operation completed successfully."

