#!/bin/sh

if [ $# -ne 2 ]; then
    exit 1
fi

# path and content are taken from args
writefile=$1
writestr=$2

### this is changed it seems that we can not use touch directly because it can not create directory if there is not exist in the path
writepath=$(dirname "$writefile") # Dosyanın klasör yolunu ayıklar
mkdir -p "$writepath"
# we will create file if not exist
# touch $writefile


# > this thing overrides the content
echo "$writestr" > "$writefile"

# if we could not touch the file then exit with error
# we do not use touch so if echo does not work then we get the exit code
if [ $? -ne 0 ]; then
    echo "error happened :D"
    exit 1
fi
