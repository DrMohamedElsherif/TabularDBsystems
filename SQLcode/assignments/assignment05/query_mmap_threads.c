// HINT: 
// THE'query_mmap_threads.c file' IS EXECUTABLE ON ITS OWN BUT WILL NEED 'time' COMMAND TO OBTAIN THE RUNTIME VALUES AND 
// TAKES THREAD NUMBER (T) AS ARGUMENT.
// e.g usage (time ./query_mmap_t resources/lineitem.csv 128), where 128 is the T value.


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <pthread.h>
#include <limits.h>

#define DELIM '|'
#define N 5
#define FILTER_COL 1
#define MAX_THREADS 128

typedef struct {
    char *start;
    char *end;
    int local_min;
} ThreadArg;

void *thread_func(void *arg) {
    ThreadArg *targ = (ThreadArg *)arg;
    char *data = targ->start;
    char *end = targ->end;
    int min = INT_MAX;

    while (data < end) {
        int first_col = atoi(data);
        if (first_col >= 2000000) {
            data = strchr(data, '\n');
            if (!data || data >= end) break;
            data++;
            continue;
        }

        int column = 1;
        char *ptr = data;
        while (column < N && ptr < end) {
            ptr = strchr(ptr, DELIM);
            if (!ptr || ptr >= end) break;
            ptr++;
            column++;
        }

        if (ptr && ptr < end) {
            int current = atoi(ptr);
            if (current < min) min = current;
        }

        data = strchr(data, '\n');
        if (!data || data >= end) break;
        data++;
    }

    targ->local_min = min;
    return NULL;
}

int main(int argc, char **argv) {
    if (argc < 3) {
        fprintf(stderr, "Usage: %s <file.csv> <num_threads>\n", argv[0]);
        return 1;
    }

    int T = atoi(argv[2]);
    if (T < 1 || T > MAX_THREADS) {
        fprintf(stderr, "Thread count must be between 1 and %d\n", MAX_THREADS);
        return 1;
    }

    int file = open(argv[1], O_RDONLY);
    size_t size = lseek(file, 0, SEEK_END);
    char *data = mmap(NULL, size, PROT_READ, MAP_SHARED, file, 0);

    char *end = data + size;
    size_t chunk = size / T;

    pthread_t threads[T];
    ThreadArg args[T];

    char *start = data;
    for (int i = 0; i < T; i++) {
        args[i].start = start;

        if (i == T - 1) {
            args[i].end = end;
        } else {
            char *next = data + (i + 1) * chunk;
            while (next < end && *next != '\n') next++;
            args[i].end = next < end ? next + 1 : end;
            start = args[i].end;
        }

        pthread_create(&threads[i], NULL, thread_func, &args[i]);
    }

    int min = INT_MAX;
    for (int i = 0; i < T; i++) {
        pthread_join(threads[i], NULL);
        if (args[i].local_min < min) min = args[i].local_min;
    }

    printf("%d\n", min);
    munmap(data, size);
    close(file);
    return 0;
}
