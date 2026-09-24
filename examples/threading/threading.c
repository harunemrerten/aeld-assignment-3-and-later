#include "threading.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

// Optional: use these functions to add debug or error prints to your application
#define DEBUG_LOG(msg,...)
//#define DEBUG_LOG(msg,...) printf("threading: " msg "\n" , ##__VA_ARGS__)
#define ERROR_LOG(msg,...) printf("threading ERROR: " msg "\n" , ##__VA_ARGS__)

void* threadfunc(void* thread_param)
{

    // TODO: wait, obtain mutex, wait, release mutex as described by thread_data structure
    // hint: use a cast like the one below to obtain thread arguments from your parameter
    //struct thread_data* thread_func_args = (struct thread_data *) thread_param;
    struct thread_data *thread_func_args = (struct thread_data*) thread_param;

    // waiting for acquiring the key
    usleep(thread_func_args->wait_to_obtain_ms*1000);

    int state = pthread_mutex_lock(thread_func_args->mutex);

    if (state != 0) 
        return thread_func_args; // returning false 
    //  

    // waiting for realising the key
    usleep(thread_func_args->wait_to_release_ms * 1000);

    state = pthread_mutex_unlock(thread_func_args->mutex);

    if (state != 0)
        return thread_func_args;
    //

    thread_func_args->thread_complete_success = true;

    return thread_func_args;
}


bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex,int wait_to_obtain_ms, int wait_to_release_ms)
{
    /**
     * TODO: allocate memory for thread_data, setup mutex and wait arguments, pass thread_data to created thread
     * using threadfunc() as entry point.
     *
     * return true if successful.
     *
     * See implementation details in threading.h file comment block
     */

    //
    
    struct thread_data* thread_data = (struct thread_data*) malloc(sizeof(struct thread_data));

    if (thread_data == NULL)
        return false;
    //

    thread_data->thread                     = thread;
    thread_data->mutex                      = mutex;
    thread_data->wait_to_obtain_ms          = wait_to_obtain_ms;
    thread_data->wait_to_release_ms         = wait_to_release_ms;
    thread_data->thread_complete_success    = false;

    int state = pthread_create(thread_data->thread, NULL, threadfunc, (void*) thread_data);

    if (state != 0)
        free(thread_data);
    //
    
    return (state == 0);
}

