#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <pthread.h>
#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>
#include "car.h"

// gets next floor given the current floor and direction of car
int get_next_floor(const char *current_floor, int direction)
{
    int floor = 0;
    // Basement
    if (current_floor[0] == 'B')
    {
        floor = -atoi(current_floor + 1);
    }
    // Normal floor
    else
    {
        floor = atoi(current_floor);
    }
    int next_floor = floor + direction;

    // Invalid floor number
    if (next_floor < -99 || next_floor > 999)
    {
        return 0;
    }
    return next_floor;
}

// sets floor based on either basement or level
void set_floor_name(char *floor_name, int floor)
{
    // Basement
    if (floor < 0)
    {
        snprintf(floor_name, 12, "B%d", abs(floor));
    }

    // B1
    else if (floor == 0)
    {
        snprintf(floor_name, 12, "B%d", 1);
    }

    // Normal
    if (floor > 0)
    {
        snprintf(floor_name, 12, "%d", floor);
    }
}

// Internal Main
int main(int argc, char *argv[])
{
    // check inputs
    if (argc != 3)
    {
        printf("Usage: ./call {source floor} {destination floor}\n");
        return 1;
    }

    // get input for argv
    char *car_name = argv[1];
    char *operation = argv[2];

    // set name
    char shm_name[32];
    snprintf(shm_name, sizeof(shm_name), "/car%s", car_name);

    // Trys to open or create shared memory for car called 'car_name'. If unsuccessful, exit
    int shm_fd = shm_open(shm_name, O_RDWR, 0666);
    if (shm_fd == -1)
    {
        printf("Unable to access car %s.\n", car_name);
        return EXIT_FAILURE;
    }

    // Trys to map the shared memory. If unsuccessful close and exit
    car_shared_mem *shared_mem = mmap(NULL, sizeof(car_shared_mem), PROT_READ | PROT_WRITE, MAP_SHARED, shm_fd, 0);
    if (shared_mem == MAP_FAILED)
    {
        printf("Unable to map shared memory for car %s.\n", car_name);
        close(shm_fd);
        return EXIT_FAILURE;
    }

    pthread_mutex_lock(&shared_mem->mutex);
    // Open Button
    if (strcmp(operation, "open") == 0)
    {
        shared_mem->open_button = 1;
        pthread_cond_broadcast(&shared_mem->cond);
    }

    // Close Button
    else if (strcmp(operation, "close") == 0)
    {
        shared_mem->close_button = 1;
        pthread_cond_broadcast(&shared_mem->cond);
    }

    // Stop Button
    else if (strcmp(operation, "stop") == 0)
    {
        shared_mem->emergency_stop = 1;
        pthread_cond_broadcast(&shared_mem->cond);
    }

    // Individual Service Button ON
    else if (strcmp(operation, "service_on") == 0)
    {
        shared_mem->individual_service_mode = 1;
        shared_mem->emergency_mode = 0;
        pthread_cond_broadcast(&shared_mem->cond);
    }

    // Individual Service Button OFF
    else if (strcmp(operation, "service_off") == 0)
    {
        shared_mem->individual_service_mode = 0;
        pthread_cond_broadcast(&shared_mem->cond);
    }

    // UP Button
    else if (strcmp(operation, "up") == 0)
    {
        // UP & Individual Service
        if (!shared_mem->individual_service_mode)
        {
            printf("Operation only allowed in service mode.\n");
        }

        // UP & Status is Between
        else if (strcmp(shared_mem->status, "Between") == 0)
        {
            printf("Operation not allowed while elevator is moving.\n");
        }

        // UP & Status is Closed
        else if (strcmp(shared_mem->status, "Closed") != 0)
        {
            printf("Operation not allowed while doors are open.\n");
        }

        // FIND NEW FLOOR
        else
        {
            int next_floor = get_next_floor(shared_mem->current_floor, 1);
            // Normal floors
            if (next_floor)
            {
                pthread_cond_broadcast(&shared_mem->cond);
                set_floor_name(shared_mem->destination_floor, next_floor);
            }

            // from B1 to 1
            else if (next_floor == 0)
            {
                pthread_cond_broadcast(&shared_mem->cond);
                set_floor_name(shared_mem->destination_floor, 1);
            }
        }
    }

    // DOWN Button
    else if (strcmp(operation, "down") == 0)
    {
        // DOWN & Individual Service
        if (!shared_mem->individual_service_mode)
        {
            printf("Operation only allowed in service mode.\n");
        }

        // DOWN & Status is Between
        else if (strcmp(shared_mem->status, "Between") == 0)
        {
            printf("Operation not allowed while elevator is moving.\n");
        }

        // DOWN & Status is Closed
        else if (strcmp(shared_mem->status, "Closed") != 0)
        {
            printf("Operation not allowed while doors are open.\n");
        }

        // FIND NEXT FLOOR
        else
        {
            int next_floor = get_next_floor(shared_mem->current_floor, -1);
            // Normal Floors
            if (next_floor)
            {
                pthread_cond_broadcast(&shared_mem->cond);
                set_floor_name(shared_mem->destination_floor, next_floor);
            }

            // from 1 to B1
            else if (next_floor == 0)
            {
                pthread_cond_broadcast(&shared_mem->cond);
                set_floor_name(shared_mem->destination_floor, -1);
            }
        }
    }

    // Invalid Operatons
    else
    {
        printf("Invalid operation.\n");
    }

    // Finish up(unmap and close car shared memory)
    pthread_mutex_unlock(&shared_mem->mutex);
    munmap(shared_mem, sizeof(car_shared_mem));
    close(shm_fd);
    return EXIT_SUCCESS;
}