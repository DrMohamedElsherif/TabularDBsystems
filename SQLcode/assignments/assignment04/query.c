#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DELIM '|'
#define N 5  // Column to process (quantity)
#define FILTER_COL 1  // Column to filter on (orderkey)

int main(int argc, char **argv) {
    FILE *file = fopen(argv[1], "r");
    char *line = NULL;
    size_t linecap = 0;
    int min = INT_MAX;

    while (getline(&line, &linecap, file) > 0) {
        char *ptr = line;
        
        // Get first column value
        int first_col = atoi(ptr);
        if (first_col >= 2000000) continue;
        
        // Find Nth column
        for (int col = 1; col < N; col++) {
            ptr = strchr(ptr, DELIM);
            if (!ptr) break;
            ptr++;
        }
        if (!ptr) continue;
        
        int current = atoi(ptr);
        if (min == -1 || current < min) min = current;
    }
    
    printf("%d\n", min);
    free(line);
    fclose(file);
    return 0;
}