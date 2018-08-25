
# Author: Sandy Lynn Ortiz - Stanford University Libraries - Born Digital Forensics Lab
# Created using GNU bash, version 4.3.48(1) in the BitCurator environment v1.8.16
# Purpose: Extract Metadata from a collection of files. 
# Execute a group of commands on each file, output 1 text file per command. Output processing logs.
# Algorithim:
#1) Look for duplicate files and create directory, create array, output .txt files, duplicates.log
#2) Process metadata for duplicate files and output txt files with integer incrementing extension
#3) Process other non-duplicate files and output text files and script.log
#4) Confirm processing completed, time to complete
