/* MISRA-C RULES */
/*
Followed:
    Coverity Support for MISRA Coding Standards:
        Rules 2.1, 2.4, 4.1, 8.6, 9.1, 11.2,
        12.3, 12.4, 12.5, 14.1, 14.4, 14.5,
        6.2, 18.1, 19.1, 19.13, 20.4, 20.11
    MISRAC2012:
        Rule 2.7, 3.2
Broken:
    Coverity Support for MISRA Coding Standards
        Rule 14.10:
            Reason: That if an 'else' statement is included after most of the 'if..elseif' statements,
            there maybe unreachable code or unused code.
        Rule 20.9:
            Reason: 'snprintf' is used here as it will prevent buffer overflow.
        Rule 20.10:
            Reason: 'atoi' is used to convert numbers within 'strings' to integers so that
            they are able to be compared to see if they are either valid floors or valid inputs
            for buttons and sensors.
    MISRAC2012:
        Rule 21.17:
            Reason: 'strcpy'(string copy) is used once to change the door status of the car.
            'strcmp' is used multiple times to compare the door status.

*/
#include <stdlib.h>   /* Used for atoi (string conversion) */
#include <string.h>   /* Used for strcpy & strcmp (string conmpare and copy) */
#include <stdio.h>    /* Used for snprintf */
#include <fcntl.h>    /* Used for shm_open (shared memory) */
#include <sys/mman.h> /* Used for mmap, PROT_READ, PROT_WRITE, MAP_SHARED (shared memory) */
#include <pthread.h>  /* Used for pthread_mutex_t, pthread_cond_t (Threading) */
#include <stdint.h>   /* Used for 'unit8_t (Apart of car shared mem struct)*/
#include <unistd.h>   /* Used for write (Alternative to printf) */

/* Create shared memory car struct */
typedef struct
{
    pthread_mutex_t mutex;
    pthread_cond_t cond;
    char current_floor[4];
    char destination_floor[4];
    char status[8];
    uint8_t open_button;
    uint8_t close_button;
    uint8_t door_obstruction;
    uint8_t overload;
    uint8_t emergency_stop;
    uint8_t individual_service_mode;
    uint8_t emergency_mode;
} car_shared_mem;

/* Safety Main */
int main(int argc, char *argv[])
{
    /* Check Inputs */
    if (argc != 2)
    {
        write(1, "Usage: ./safety {car name}", 27);
        return 1;
    }

    /* Get Inputs */
    const char *car_name = argv[1];
    char shm_name[32];

    /* Initialise Shared Memory */
    (void)snprintf(shm_name, sizeof(shm_name), "/car%s", car_name);
    int shm_fd = shm_open(shm_name, O_RDWR, 0666);
    if (shm_fd == -1)
    {
        write(1, "Unable to access car Test.\n", 28);
        return 1;
    }
    car_shared_mem *shared_mem = mmap(NULL, sizeof(car_shared_mem), PROT_READ | PROT_WRITE, MAP_SHARED, shm_fd, 0);
    if (shared_mem == MAP_FAILED)
    {
        (void)close(shm_fd);
        write(1, "Unable to map shared memory.\n", 30);
        return 1;
    }

    while (1)
    {
        (void)pthread_mutex_lock(&shared_mem->mutex);
        (void)pthread_cond_wait(&shared_mem->cond, &shared_mem->mutex);

        /* DOOR OBSTRUCTION & CLOSING STATUS */
        if ((shared_mem->door_obstruction == 1) && (strcmp(shared_mem->status, "Closing") == 0))
        {
            (void)strcpy(shared_mem->status, "Opening");
            shared_mem->emergency_mode = 1;
        }

        /* Check Emergency Stop Button & Emergency Mode*/
        if ((shared_mem->emergency_stop == 1) && (shared_mem->emergency_mode == 0))
        {
            write(1, "The emergency stop button has been pressed!\n", 45);
            shared_mem->emergency_mode = 1;
        }

        /* Check Overload and Emergency Mode */
        if ((shared_mem->overload == 1) && (shared_mem->emergency_mode == 0))
        {
            shared_mem->emergency_mode = 1;
            write(1, "The overload sensor has been tripped!\n", 39);
        }

        /* Check Door Obstruction and Status inconsistencies */
        if ((shared_mem->door_obstruction == 1) && ((strcmp(shared_mem->status, "Open") == 0 || strcmp(shared_mem->status, "Between") == 0 || strcmp(shared_mem->status, "Closed") == 0)))
        {
            write(1, "Data consistency error!\n", 25);
            shared_mem->emergency_mode = 1;
        }

        /* Check emergency mode = 1 or 0 */
        if (shared_mem->emergency_mode > 1)
        {
            write(1, "Data consistency error!\n", 25);
            shared_mem->emergency_mode = 1;
        }

        /* Check for data inconsistenies */
        if (shared_mem->emergency_mode == 0)
        {
            /*Check Status Inconsistencies*/
            if ((strcmp(shared_mem->status, "Open")) || (strcmp(shared_mem->status, "Opening")) || (strcmp(shared_mem->status, "Between")) || (strcmp(shared_mem->status, "Closing")) || (strcmp(shared_mem->status, "Closed")))
            {
                write(1, "Data consistency error!\n", 25);
                shared_mem->emergency_mode = 1;
            }

            /* Check Open & Close Button Inconsistencies */
            else if ((shared_mem->open_button != 1) || (shared_mem->close_button != 1) || (shared_mem->open_button != 0) || (shared_mem->close_button != 0))
            {
                write(1, "Data consistency error!\n", 25);
                shared_mem->emergency_mode = 1;
            }

            /* Check Individual Service Mode & Emergency Mode Inconsistencies */
            else if ((shared_mem->individual_service_mode != 1) || (shared_mem->emergency_mode != 1) || (shared_mem->individual_service_mode != 0) || (shared_mem->emergency_mode != 0))
            {
                write(1, "Data consistency error!\n", 25);
                shared_mem->emergency_mode = 1;
            }

            /* Checks Door Obstruction & Overload Inconsistencies */
            else if ((shared_mem->door_obstruction != 1) || (shared_mem->overload != 1) || (shared_mem->door_obstruction != 0 || (shared_mem->overload != 0)))
            {
                write(1, "Data consistency error!\n", 25);
                shared_mem->emergency_mode = 1;
            }

            /* Checks Current & Destination Floor Inconsistencies */
            else if ((atoi(shared_mem->current_floor) != 1) || (atoi(shared_mem->current_floor) != 0) || (atoi(shared_mem->destination_floor) != 1) || (atoi(shared_mem->destination_floor) != 0))
            {
                write(1, "Data consistency error!\n", 25);
                shared_mem->emergency_mode = 1;
            }
        }
        (void)pthread_cond_broadcast(&shared_mem->cond);
        (void)pthread_mutex_unlock(&shared_mem->mutex);
    }
    (void)munmap(shared_mem, sizeof(car_shared_mem));
    (void)close(shm_fd);
    return 0;
}
