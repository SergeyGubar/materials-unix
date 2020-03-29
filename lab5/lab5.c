#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <time.h>

char *concat(const char *s1, const char *s2)
{
    char *result = malloc(strlen(s1) + strlen(s2) + 1);
    strcpy(result, s1);
    strcat(result, s2);
    return result;
}

void log_message(char *str, int pid, int signal, char* signal_str)
{
    FILE *file;
    const char *home = getenv("HOME");
    // TODO: Uncomment to log in HOME
    // char *path = concat(home, "/log/lab1.txt");

    time_t rawtime;
    struct tm *info;
    char buffer[80];

    time( &rawtime );

    info = localtime( &rawtime );

    strftime(buffer,80,"%a, %d %b %Y %X %z", info);

    char* timestamp = (char*)malloc(20 * sizeof(char));
    sprintf(timestamp, "%d",(int)time(NULL));

    char *path = "/Users/gubarsergey/Documents/projects/university/materials-unix/lab5/lab5.txt";
    file = fopen(path, "a+");

    char* message = (char*)malloc(100 * sizeof(char));
    sprintf(message, "%s; %s; %d; %d; %s; %s\n", buffer, timestamp, pid, signal, signal_str, str);
    fprintf(file, "%s", message);
    fclose(file);

    char* logger_formatted_message = (char*)malloc(100 * sizeof(char));
    sprintf(logger_formatted_message, "\"%s\"", message);
    system(concat("logger ", logger_formatted_message));
}

void ping_child_process(int pid)
{
    kill(pid, SIGUSR1);
    printf("Pinged child process\n");
}

void kill_child_process(int pid)
{
    kill(pid, SIGTERM);
}

void ping_back(int pid)
{
    kill(pid, SIGCHLD);
}

void parent_ping_back_handler() {
    log_message("Nothing - child pinged back signal", getpid(), 18, "SIGCHLD");
}

void child_usr1_handler() {
    log_message("Nothing - ping signal", getpid(), 16, "SIGUSR1");
}

void child_usr2_handler() {
    log_message("Health check", getpid(), 17, "SIGUSR2");
}

void child_term_handler() {
    log_message("Child termination", getpid(), 15, "SIGTERM");
    exit(1);
}

void child_ping_back_handler() {
    log_message("Child pinging back", getpid(), 18, "SIGCHLD");
    ping_back(getppid());
}


int main()
{
    const int PING_CHOICE = 10;
    const int KILL_CHOICE = 11;
    const int PING_BACK_CHOICE = 12;
    const int EXIT_CHOICE = 13;
    
    int pid = fork();

    if (pid == 0) {
        signal(SIGUSR1, child_usr1_handler);
        signal(SIGUSR2, child_usr2_handler);
        signal(SIGTERM, child_term_handler);
        signal(SIGCHLD, child_ping_back_handler);
        while (1) {

        }
    } else {
        signal(SIGCHLD, parent_ping_back_handler);

        int pid2 = fork();
        if (pid2 == 0) {
            while(1) {
                kill(pid, SIGUSR2);
                sleep(3);
            }
        } else {
            while (1)
            {
                printf("Enter the action:\n");
                char text_choice[100];
                int choice;

                scanf("%s", text_choice);
                if (strcmp(text_choice, "ping") == 0)
                {
                    choice = PING_CHOICE;
                }
                if (strcmp(text_choice, "kill") == 0)
                {
                    choice = KILL_CHOICE;
                }
                if (strcmp(text_choice, "back") == 0)
                {
                    choice = PING_BACK_CHOICE;
                }
                if (strcmp(text_choice, "quit") == 0)
                {
                    choice = EXIT_CHOICE;
                }
                int exit;
                switch (choice)
                {
                case PING_CHOICE:
                    ping_child_process(pid);
                    break;
                case KILL_CHOICE:
                    kill_child_process(pid);
                    break;
                case PING_BACK_CHOICE:
                    ping_back(pid);
                    break;
                case EXIT_CHOICE:
                    exit = 1;
                    break;
                default:
                    printf("Try again\n");
                    break;
                }
                if (exit == 1)
                {
                    break;
                }
            }
        }
        
    }

    
    return 0;
}
