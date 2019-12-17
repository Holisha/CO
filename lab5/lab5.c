#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <ctype.h>
#include "cache.h"
#include "replace_policy.h"

request ANS;
Cache **cache;

int main(int argc, char** argv){
    int i;
    int cache_size, block_size, way, max_idx, label, replace;
    unsigned long demand;
    FILE *trace;

    if(argc != 6){
        printf("Error Input value\n");
        return 0;
    }
    // init
    cache_size = atoi(argv[1]);
    block_size = atoi(argv[2]);
    if(isdigit(argv[3][0])){
        way = atoi(argv[3]);
        max_idx = cache_size * 1024 / (block_size * way);
    }
    else{   // fully
        way = cache_size * 1024 / block_size;
        max_idx = 1;
    }
    if(strcmp("FIFO", argv[4]) == 0)
        replace = 0;
    else if(strcmp("LRU", argv[4]) == 0)
        replace = 1;
    trace = fopen(argv[5], "r");
    ANS.file_name = strdup(argv[5]);

    cache_init(way, max_idx);

    while(fscanf(trace, "%d %x", &label, &demand) != EOF){
        demand /= block_size;   // block address
        cache_demand(label, demand, max_idx, way, replace);
    }

    dirty_check(way, max_idx);
    
    printf("Input file = %s\n", ANS.file_name);
    printf("Demand fetch = %lu\n", ANS.demand_fetch);
    printf("Cache hit = %lu\n",ANS.hit);
    printf("Cache miss = %lu\n",ANS.miss);
    printf("Miss rate = %.4f\n",(double) ANS.miss /(double) ANS.demand_fetch);
    printf("Read data = %lu\n",ANS.read);
    printf("Write data = %lu\n",ANS.write);
    printf("Bytes from memory = %lu\n",ANS.from_memory * block_size);
    printf("Bytes to memory = %lu\n", ANS.to_memory * block_size);

    //printf("%d %d %d %d %d\n", cache_size, block_size, max_idx, way, replace);
    fclose(trace);
    return 0;
}