#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <pthread.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <signal.h>
#include <errno.h>
#include "car.h"

// Global variables
car_shared_mem *car_shared_memory;
int sock = -1; // Socket file descriptor
char car_name[50];
int delay_ms;

// Signal handler (termination)
void handle_sigint(int)
{
    if (car_shared_memory != MAP_FAILED)
    {
        shm_unlink(car_name); // Clean up shared memory
    }
    if (sock != -1)
    {
        close(sock);
    }
    exit(0);
}

// Shared Memory Initialisation
void init_shared_memory(const char *name, const char *lowest_floor)
{
    sprintf(car_name, "/car%s", name);

    // Create shared memory
    int shm_fd = shm_open(car_name, O_CREAT | O_RDWR, 0666);
    if (shm_fd == -1)
    {
        perror("shm_open()");
        exit(1);
    }

    // Set size of shared memory
    if (ftruncate(shm_fd, sizeof(car_shared_mem)) == -1)
    {
        perror("ftruncate failed");
        exit(1);
    }

    // Map shared memory
    car_shared_memory = mmap(0, sizeof(car_shared_mem), PROT_READ | PROT_WRITE, MAP_SHARED, shm_fd, 0);
    if (car_shared_memory == MAP_FAILED)
    {
        perror("mmap failed");
        exit(1);
    }

    // Initialize shared memory structure
    pthread_mutexattr_t mutex_attr;
    pthread_mutexattr_init(&mutex_attr);
    pthread_mutexattr_setpshared(&mutex_attr, PTHREAD_PROCESS_SHARED);
    pthread_mutex_init(&car_shared_memory->mutex, &mutex_attr);

    pthread_condattr_t cond_attr;
    pthread_condattr_init(&cond_attr);
    pthread_condattr_setpshared(&cond_attr, PTHREAD_PROCESS_SHARED);
    pthread_cond_init(&car_shared_memory->cond, &cond_attr);

    strcpy(car_shared_memory->current_floor, lowest_floor);
    strcpy(car_shared_memory->destination_floor, lowest_floor);
    strcpy(car_shared_memory->status, "Closed");
    car_shared_memory->open_button = 0;
    car_shared_memory->close_button = 0;
    car_shared_memory->door_obstruction = 0;
    car_shared_memory->overload = 0;
    car_shared_memory->emergency_stop = 0;
    car_shared_memory->individual_service_mode = 0;
    car_shared_memory->emergency_mode = 0;
}

// Controller Connection
void *connect_to_controller(void *)
{
    // Port 3000 & address 127.0.0.1
    struct sockaddr_in controller_addr;
    controller_addr.sin_family = AF_INET;
    controller_addr.sin_port = htons(3000);
    inet_pton(AF_INET, "127.0.0.1", &controller_addr.sin_addr);

    // checks status
    while (1)
    {
        // Socket creation and check
        sock = socket(AF_INET, SOCK_STREAM, 0);
        if (sock == -1)
        {
            perror("socket()");
            exit(1);
        }

        // Socket connection attempt
        if (connect(sock, (struct sockaddr *)&controller_addr, sizeof(controller_addr)) == -1)
        {
            close(sock);
            sock = -1;
            continue;
        }

        // Send message to server
        char msg[256];
        snprintf(msg, sizeof(msg), "CAR %s %s %s", car_name + 4, car_shared_memory->current_floor, "highest_floor");
        send_message(sock, msg);

        // Send initial status to server
        snprintf(msg, sizeof(msg), "STATUS %s %s %s", car_shared_memory->status, car_shared_memory->current_floor, car_shared_memory->destination_floor);
        send_message(sock, msg);

        break;
    }
    return NULL;
}

// Entry point
int main(int argc, char *argv[])
{
    // Check inputs
    if (argc != 5)
    {
        fprintf(stderr, "Usage: %s {name} {lowest floor} {highest floor} {delay}\n", argv[0]);
        exit(1);
    }

    // Gets Inputs
    const char *name = argv[1];
    const char *lowest_floor = argv[2];
    delay_ms = atoi(argv[4]);

    // Termination controls
    signal(SIGINT, handle_sigint);
    signal(SIGPIPE, SIG_IGN);

    // shared memory initialisation
    init_shared_memory(name, lowest_floor);

    // create threads for controller
    pthread_t controller_thread;
    pthread_create(&controller_thread, NULL, connect_to_controller, NULL);

    // Elevator Loop
    while (1)
    {
        pthread_mutex_lock(&car_shared_memory->mutex);

        // WAIT UNTIL BUTTON HAS BEEN PRESSED
        while (car_shared_memory->open_button == 0 && car_shared_memory->close_button == 0 && strcmp(car_shared_memory->current_floor, car_shared_memory->destination_floor) == 0)
        {
            pthread_cond_wait(&car_shared_memory->cond, &car_shared_memory->mutex);
        }

        // OPEN BUTTON ENGAGED
        if (car_shared_memory->open_button == 1)
        {
            // DOOR STATUS IS CLOSED OR CLOSING
            if ((strcmp(car_shared_memory->status, "Closed") == 0) || (strcmp(car_shared_memory->status, "Closing") == 0))
            {
                strcpy(car_shared_memory->status, "Opening");
                pthread_cond_broadcast(&car_shared_memory->cond);
                pthread_mutex_unlock(&car_shared_memory->mutex);
                usleep(delay_ms * 1000);
                pthread_mutex_lock(&car_shared_memory->mutex);
                strcpy(car_shared_memory->status, "Open");
                pthread_cond_broadcast(&car_shared_memory->cond);
            }

            // STATUS IS OPEN
            else if (strcmp(car_shared_memory->status, "Open") == 0)
            {
                usleep(delay_ms * 1000); // Extend the open time
                strcpy(car_shared_memory->status, "Closing");
                pthread_cond_broadcast(&car_shared_memory->cond);
            }

            // STATUS IS OPENING OR BETWEEN
            if ((strcmp(car_shared_memory->status, "Opening") == 0) || (strcmp(car_shared_memory->status, "Between") == 0))
            {
            }

            // Reset Open Button
            car_shared_memory->open_button = 0;
        }

        // CLOSE BUTTON ENGAGED & STATUS IS OPEN
        if (car_shared_memory->close_button == 1 && strcmp(car_shared_memory->status, "Open") == 0)
        {
            strcpy(car_shared_memory->status, "Closing");
            pthread_cond_broadcast(&car_shared_memory->cond);
            pthread_mutex_unlock(&car_shared_memory->mutex);
            usleep(delay_ms * 1000);
            pthread_mutex_lock(&car_shared_memory->mutex);
            strcpy(car_shared_memory->status, "Closed");
            pthread_cond_broadcast(&car_shared_memory->cond);
            car_shared_memory->close_button = 0;
        }

        // FLOOR MOVEMENT
        if (strcmp(car_shared_memory->current_floor, car_shared_memory->destination_floor) != 0 && strcmp(car_shared_memory->status, "Closed") == 0)
        {
            strcpy(car_shared_memory->status, "Between");
            pthread_cond_broadcast(&car_shared_memory->cond);
            pthread_mutex_unlock(&car_shared_memory->mutex);
            usleep(delay_ms * 1000);
            pthread_mutex_lock(&car_shared_memory->mutex);

            // ELEVATOR MOVEMENT
            int current_floor = atoi(car_shared_memory->current_floor);
            int destination_floor = atoi(car_shared_memory->destination_floor);
            if (current_floor < destination_floor)
            {
                current_floor++;
            }
            else
            {
                current_floor--;
            }
            sprintf(car_shared_memory->current_floor, "%d", current_floor);
            strcpy(car_shared_memory->status, "Closed");
            pthread_cond_broadcast(&car_shared_memory->cond);
        }

        pthread_mutex_unlock(&car_shared_memory->mutex);
        usleep(1000); // Small sleep to avoid busy waiting
    }
    // destroy controller thread
    pthread_detach(controller_thread);
    return 0;
}
