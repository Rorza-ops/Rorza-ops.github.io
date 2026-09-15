#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <unistd.h>
#include <stdint.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <signal.h>
#include <errno.h>
#include <sys/select.h>
#include <ctype.h>
#include "car.h"

// Structure to store car information
typedef struct
{
    car_shared_mem shared_mem;
    int sockfd;
    char name[32];
} car_info;

// Function declarations
void handle_sigint();
void *car_handler(void *args);
void add_car(char *name, char *lowest_floor, char *highest_floor, int sockfd);
void remove_car(int sockfd);

// Global variables
int server_fd;
car_info cars[10];
int car_count = 0;
pthread_mutex_t car_list_mutex = PTHREAD_MUTEX_INITIALIZER;

// Main controller
int main()
{
    struct sockaddr_in server_addr, client_addr;
    socklen_t client_addr_len = sizeof(client_addr);

    // Socket creation and check
    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == -1)
    {
        perror("Failed to create socket");
        exit(EXIT_FAILURE);
    }

    // Socket Options
    int opt_enable = 1;
    setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt_enable, sizeof(opt_enable));

    // PORT 3000 & ADDRESS 127.0.0.1
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(3000);
    server_addr.sin_addr.s_addr = INADDR_ANY;

    // Bind socket to IP & PORT
    if (bind(server_fd, (struct sockaddr *)&server_addr, sizeof(server_addr)) == -1)
    {
        perror("Failed to bind socket");
        close(server_fd);
        exit(EXIT_FAILURE);
    }

    // Bind Socket Listening
    if (listen(server_fd, 10) == -1)
    {
        perror("Failed to listen on socket");
        close(server_fd);
        exit(EXIT_FAILURE);
    }

    // Termination controls
    signal(SIGINT, handle_sigint);

    while (1)
    {
        // Accept requests
        int *client_fd_ptr = malloc(sizeof(int));
        *client_fd_ptr = accept(server_fd, (struct sockaddr *)&client_addr, &client_addr_len);
        if (*client_fd_ptr == -1)
        {
            perror("Failed to accept connection");
            free(client_fd_ptr);
            continue;
        }

        // Create Client Thread
        pthread_t client_thread;
        if (pthread_create(&client_thread, NULL, car_handler, (void *)client_fd_ptr) != 0)
        {
            perror("Failed to create client handler thread");
            close(*client_fd_ptr);
            free(client_fd_ptr);
        }

        // detach thread
        else
        {
            pthread_detach(client_thread);
        }
    }

    return 0;
}

// communication with car
void *car_handler(void *args)
{
    // initialise
    int client_fd = *(int *)args;
    free(args);
    char buffer[256];
    char car_name[32] = "";

    // Message control
    uint32_t len;
    ssize_t bytes_read = read(client_fd, &len, sizeof(len));
    if (bytes_read <= 0)
    {
        perror("Failed to read message length");
        close(client_fd);
        pthread_exit(NULL);
    }

    // Read message from car
    len = ntohl(len);
    bytes_read = read(client_fd, buffer, len);
    if (bytes_read <= 0)
    {
        perror("Failed to read message");
        close(client_fd);
        pthread_exit(NULL);
    }
    buffer[bytes_read] = '\0';

    // Car Creation
    char lowest_floor[4], highest_floor[4];
    if (strstr(buffer, "CAR") != NULL)
    {
        // Invalid format message
        if (sscanf(buffer, "CAR %31s %3s %3s", car_name, lowest_floor, highest_floor) != 3)
        {
            fprintf(stderr, "Invalid registration message: %s\n", buffer);
            close(client_fd);
            pthread_exit(NULL);
        }

        // Checks for Duplicate
        pthread_mutex_lock(&car_list_mutex);
        for (int i = 0; i < car_count; ++i)
        {
            // SAME NAMES
            if (strcmp(cars[i].name, car_name) == 0)
            {
                fprintf(stderr, "Car with name %s is already registered\n", car_name);
                pthread_mutex_unlock(&car_list_mutex);
                close(client_fd);
                pthread_exit(NULL);
            }
        }

        // ADDS CAR
        if (car_count < 10)
        {
            add_car(car_name, lowest_floor, highest_floor, client_fd);
            char response[64];
            snprintf(response, sizeof(response), "%s", car_name);
            write(client_fd, response, strlen(response));
        }

        // MAX CAR
        else
        {
            fprintf(stderr, "Maximum number of cars reached, cannot add %s\n", car_name);
            pthread_mutex_unlock(&car_list_mutex);
            close(client_fd);
            pthread_exit(NULL);
        }
        pthread_mutex_unlock(&car_list_mutex);
    }

    // Invalid message
    else
    {
        fprintf(stderr, "Invalid message: %s\n", buffer);
        close(client_fd);
        pthread_exit(NULL);
    }

    // Communication loop
    while (1)
    {
        // initialise timeout parameters
        struct timeval timeout;
        timeout.tv_sec = 60; // Increase to 60 seconds for testing
        timeout.tv_usec = 0;
        setsockopt(client_fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
        bytes_read = read(client_fd, buffer, sizeof(buffer) - 1);

        // Read data
        if (bytes_read < 0)
        {
            // Handle timeout
            if (errno == EAGAIN || errno == EWOULDBLOCK)
            {
                continue;
            }

            // Errors
            else
            {
                perror("Read failed");
                break;
            }
        }

        // car connection closed
        else if (bytes_read == 0)
        {
            break;
        }

        // Receives message
        buffer[bytes_read] = '\0';
        if (strlen(buffer) == 0)
        {
            continue;
        }

        // Access existing cars to find particular car
        pthread_mutex_lock(&car_list_mutex);
        car_info *car = NULL;
        for (int i = 0; i < car_count; ++i)
        {
            if (cars[i].sockfd == client_fd)
            {
                car = &cars[i];
                break;
            }
        }

        // car not found
        if (car == NULL)
        {
            pthread_mutex_unlock(&car_list_mutex);
            break;
        }

        // CALL Message Received and formatted
        if (strncasecmp(buffer, "CALL", 4) == 0)
        {
            char start_floor[4] = "", destination_floor[4] = "";
            int args_read = sscanf(buffer, "CALL %3s %3s", start_floor, destination_floor);

            // formats response from car
            if (args_read >= 1)
            {
                char response[64];
                snprintf(response, sizeof(response), "RECV: FLOOR %s\n", start_floor);
                write(client_fd, response, strlen(response));
            }

            // unable to format
            else
            {
                char response[64];
                snprintf(response, sizeof(response), "UNAVAILABLE\n");
                write(client_fd, response, strlen(response));
            }
        }

        // STATUS Message Received and formatted
        else if (strncasecmp(buffer, "STATUS", 6) == 0)
        {
            char status_type[16], floor_1[4], floor_2[4];

            // Format response from car
            if (sscanf(buffer, "STATUS %15s %3s %3s", status_type, floor_1, floor_2) == 3)
            {
                char response[64];
                snprintf(response, sizeof(response), "RECV: FLOOR %s\n", floor_1);
                write(client_fd, response, strlen(response));
            }

            // unable to format
            else
            {
                char response[64];
                snprintf(response, sizeof(response), "UNAVAILABLE\n");
                write(client_fd, response, strlen(response));
            }
        }

        // uable to format
        else
        {
            char response[64];
            snprintf(response, sizeof(response), "UNAVAILABLE\n");
            write(client_fd, response, strlen(response));
        }

        pthread_mutex_unlock(&car_list_mutex);
    }

    // Remove cars, close sockets and destroy threads
    pthread_mutex_lock(&car_list_mutex);
    remove_car(client_fd);
    pthread_mutex_unlock(&car_list_mutex);
    close(client_fd);
    pthread_exit(NULL);
}

// Adds car to system
void add_car(char *name, char *lowest_floor, char *highest_floor, int sockfd)
{
    // Check car limit
    if (car_count >= 10)
    {
        fprintf(stderr, "Maximum number of cars reached, cannot add %s\n", name);
        return;
    }

    // create and initialise new car
    pthread_mutex_init(&cars[car_count].shared_mem.mutex, NULL);
    pthread_cond_init(&cars[car_count].shared_mem.cond, NULL);
    strncpy(cars[car_count].shared_mem.current_floor, lowest_floor, sizeof(cars[car_count].shared_mem.current_floor) - 1);
    cars[car_count].shared_mem.current_floor[sizeof(cars[car_count].shared_mem.current_floor) - 1] = '\0';
    strncpy(cars[car_count].shared_mem.destination_floor, highest_floor, sizeof(cars[car_count].shared_mem.destination_floor) - 1);
    cars[car_count].shared_mem.destination_floor[sizeof(cars[car_count].shared_mem.destination_floor) - 1] = '\0';
    cars[car_count].sockfd = sockfd;
    strncpy(cars[car_count].name, name, sizeof(cars[car_count].name) - 1);
    cars[car_count].name[sizeof(cars[car_count].name) - 1] = '\0';
    strncpy(cars[car_count].shared_mem.status, "Closed", sizeof(cars[car_count].shared_mem.status) - 1);
    cars[car_count].shared_mem.status[sizeof(cars[car_count].shared_mem.status) - 1] = '\0';
    cars[car_count].shared_mem.open_button = 0;
    cars[car_count].shared_mem.close_button = 0;
    cars[car_count].shared_mem.door_obstruction = 0;
    cars[car_count].shared_mem.overload = 0;
    cars[car_count].shared_mem.emergency_stop = 0;
    cars[car_count].shared_mem.individual_service_mode = 0;
    cars[car_count].shared_mem.emergency_mode = 0;
    car_count++;
}

// Removes car from system
void remove_car(int sockfd)
{
    // Checks every car
    for (int i = 0; i < car_count; i++)
    {
        // SAME CAR
        if (cars[i].sockfd == sockfd)
        {
            pthread_mutex_destroy(&cars[i].shared_mem.mutex);
            pthread_cond_destroy(&cars[i].shared_mem.cond);
            for (int j = i; j < car_count - 1; j++)
            {
                cars[j] = cars[j + 1];
            }
            car_count--;
            return;
        }
    }
}

// Signal handler (termination)
void handle_sigint()
{
    close(server_fd);
    for (int i = 0; i < car_count; i++)
    {
        close(cars[i].sockfd);
        pthread_mutex_destroy(&cars[i].shared_mem.mutex);
        pthread_cond_destroy(&cars[i].shared_mem.cond);
    }
    exit(EXIT_SUCCESS);
}
