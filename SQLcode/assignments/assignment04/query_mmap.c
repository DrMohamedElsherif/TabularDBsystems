#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

#define DELIM '|'
#define N 5
#define FILTER_COL 1

int main(int argc, char **argv) {
    int file = open(argv[1], O_RDONLY);
    size_t size = lseek(file, 0, SEEK_END);
    char *data = mmap(NULL, size, PROT_READ, MAP_SHARED, file, 0);

    
    char *end = data + size;
    int min = INT_MAX;

    while (data < end) {
        // Get first column value
        int first_col = atoi(data);
        if (first_col >= 2000000) {
            data = strchr(data, '\n') + 1;
            continue;
        }

        // Find Nth column
        int column = 1;
        char *ptr = data;
        while (column < N && ptr < end) {
            ptr = strchr(ptr, DELIM);
            if (!ptr) break;
            ptr++;
            column++;
        }

        if (ptr && ptr < end) {
            int current = atoi(ptr);
            if (min == -1 || current < min) min = current;
        }

        data = strchr(data, '\n') + 1;
    }

    printf("%d\n", min);
    munmap(data, size);
    close(file);
    return 0;
}