#!/bin/sh

# if the count of arguments is not equal to 2 then terminate with the exec code of -1
if [ $# -eq 2 ]; then
	filesdir=$1
	searchstr=$2

	# if the first argumant is not a existin directory than terminate with the -1 exec code
	if [ -d "$filesdir" ]; then
	# numberoffiles "$filesdir"
		X=$(find "$filesdir" -type f | wc -l)
		Y=$(grep -r "$searchstr" "$filesdir" | wc -l)

		# we love c :D
		printf "The number of files are $X and the number of matching lines are $Y\n" 
	else
		exit 1
	fi
else
	exit 1
fi

# i was goint to use recursive function like in the c or cpp but i find the answer in the forums that can found the all files and subdirectories files
# numberoffiles() {
# 	# if i recursively look for the ls of the directories and take the number of it i will get the content
# 	# parameters are like in order: 
# 	# firstly name of the first directory or file
# 	# secondly total number of files 
# 	# thirdly wordcountuntil.
# 	local -n dirOrFile = $1
# 	local -n totalFileNum = {$2}
# 	local -n totalStrNum = {$3}
	
# 	if []

# }

# word_count_of_list() {

# }
