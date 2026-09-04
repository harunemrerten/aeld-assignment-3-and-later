#include <stdio.h>
#include <syslog.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>

int main(int argc, char *argv[]) {
    
    openlog(argv[0], LOG_PID, LOG_USER);
    // if the argument count is not the same as 3(because +1 with name) like in the firt hw we did exit with 1 
    if(argc != 3) {
        // we log the error
        syslog(LOG_ERR, "Two argument is needed one for file name and one for string to write on file");
        closelog();

        return 1; //exit(-1); // or return -1
    }

    // arguments
    char* writefile = argv[1];
    char* writestr = argv[2];
    
    /*
    I did not see the new requirements section in which we do not need to create directories if there is the first part

    // i will strip the file name from the directories
    char filename[50];
    

    unsigned char dircount = 0;// for understanding how much of the directory in given string
    char* ptrofstr = writefile;// counter for the character we are going to search for all

    for(size_t i = 0; i < strlen(writefile); i++) {
        
        if((*ptrofstr) == '/')
            ++dircount;
        //

        ++ptrofstr;
    }

    // we got the number of directory now we get the filename from arg string
    unsigned char cmpcount = 0;
    ptrofstr = writefile; // from start
    for(size_t i = 0; i < strlen(writefile); i++) {
        
        if((*ptrofstr) == '/')
            ++cmpcount;
        //

        if(dircount == cmpcount) {

            strcpy(filename, ptrofstr);
            break;

        }

        ++ptrofstr;

    }
    */

    // we log on syslog as debug
    syslog(LOG_DEBUG, "Writing %s to %s", writestr, writefile);

    // we open the file with file discropter and open syscall
    int fileD = open(writefile, O_WRONLY | O_CREAT | O_TRUNC, 0644);

    if(fileD == -1) {
        // we log the error and return 1
        syslog(LOG_ERR, "Error while opening file with the error: %s", strerror(errno));
        closelog();
        
        return 1;
        //
    }

    ssize_t byteW = write(fileD, writestr, strlen(writestr));

    if(byteW == -1) {
        // log the error
        syslog(LOG_ERR, "Error while writing to the file with the error: %s", strerror(errno));
        closelog();

        return 1;
    }

    // closing the oppened source
    close(fileD);
    closelog();

    return 0;

}