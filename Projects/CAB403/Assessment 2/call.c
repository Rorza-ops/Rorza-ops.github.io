#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include "car.h"

// Sends a message to serve
int send_messages(int socket, const char *message)
{
    uint32_t message_len = strlen(message);
    uint32_t network_len = htonl(message_len);
    if (send(socket, &network_len, sizeof(network_len), 0) == -1)
    {
        return -1;
    }
    if (send(socket, message, message_len, 0) == -1)
    {
        return -1;
    }
    return 0;
}

// Receives message from
int read_message(int socket, char *buffer)
{
    uint32_t message_len;
    if (recv(socket, &message_len, sizeof(message_len), 0) <= 0)
    {
        return -1;
    }
    message_len = ntohl(message_len);
    if (recv(socket, buffer, message_len, 0) <= 0)
    {
        return -1;
    }
    buffer[message_len] = '\0';
    return message_len;
}

// Check if floor is valid
int is_valid_floor(const char *floor)
{
    if (floor[0] == 'B')
    {
        int basement_num = atoi(floor + 1);
        return basement_num >= 1 && basement_num <= 99;
    }
    else
    {
        int floor_num = atoi(floor);
        return floor_num >= 1 && floor_num <= 999;
    }
    return 0;
}

// Call Main
int main(int argc, char *argv[])
{
    // Checks inputs
    if (argc != 3)
    {
        printf("Usage: ./call {source floor} {destination floor}\n");
        return 1;
    }

    // Gets inputs
    char *source_floor = argv[1];
    char *destination_floor = argv[2];

    // Checks if either floor is valid
    if (!is_valid_floor(source_floor) || !is_valid_floor(destination_floor))
    {
        printf("Invalid floor(s) specified.\n");
        return 1;
    }

    // Check if current and destination are the same
    if (strcmp(source_floor, destination_floor) == 0)
    {
        printf("You are already on that floor!\n");
        return 1;
    }

    // Initialise Server Side
    int sock = 0;
    struct sockaddr_in serv_addr;
    char buffer[1024] = {0};

    // Check socket creation
    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    {
        printf("Socket creation error\n");
        return 1;
    }

    // Port 300 & Address 127.0.0.1
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(3000);
    serv_addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);

    // Checks socket connection to server
    if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0)
    {
        printf("Unable to connect to elevator system.\n");
        close(sock);
        return 1;
    }

    // Initialise message
    char message[1024];
    snprintf(message, 1024, "CALL %s %s", source_floor, destination_floor);

    // Checks if system is able to send messages
    if (send_messages(sock, message) < 0)
    {
        printf("Failed to send message.\n");
        close(sock);
        return 1;
    }

    // Checks if the system is able to connect
    if (read_message(sock, buffer) <= 0)
    {
        printf("Unable to connect to elevator system.\n");
        close(sock);
        return 1;
    }

    // Checks if buffer is a car
    if (strncmp(buffer, "CAR", 3) == 0)
    {
        char car_name[1024];
        sscanf(buffer, "CAR %s", car_name);
        printf("Car %s is arriving.\n", car_name);
    }

    // Checks if response is UNAVAIABLE
    else if (strcmp(buffer, "UNAVAILABLE") == 0)
    {
        printf("Sorry, no car is available to take this request.\n");
    }

    // Finish
    close(sock);
    return 0;
}
