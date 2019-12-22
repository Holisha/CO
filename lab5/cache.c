#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <ctype.h>
#include "cache.h"
#include "replace_policy.h"

void cache_init(int way, int max_idx){
    int i, j;

    cache = malloc(sizeof(Cache *) * way);
    for(i = 0; i < way; i++){
        cache[i] = malloc(sizeof(Cache) * max_idx);
        for(j = 0; j < max_idx; j++){
            cache[i][j].valid = 0;
            cache[i][j].tag = 0;
            cache[i][j].dirty = 0;
            cache[i][j].priority = i;
        }
    }
    // init request
    ANS.demand_fetch = 0;
    ANS.hit = 0;
    ANS.miss = 0;
    ANS.read = 0;
    ANS.write = 0;
    ANS.from_memory = 0;
    ANS.to_memory = 0;
}

void cache_demand(int label, unsigned long block_address, int max_idx, int way, int replace_policy){
    int i, j;
    unsigned long tag, idx;

    if(label == 0)
        ANS.read++;
    else if(label == 1)
        ANS.write++;

    idx = block_address % max_idx; // cache index
    tag = block_address / max_idx; // cache tag

    for(i = 0; i < way; i++){
        // non-valid state
        if(cache[i][idx].valid == 0){
            cache[i][idx].valid = 1;
            cache[i][idx].tag = tag;
            ANS.from_memory++;
            ANS.miss++;
            if(replace_policy == 0) FIFO(idx, way);
            break;
        }
        // valid & hit
        else if(cache[i][idx].tag == tag){
            ANS.hit++;
            break;
        }
    }
    // valid & miss
    if(i == way){
        // allocate block
        for(i = 0; i < way && cache[i][idx].priority > 0; i++);
        
        // Check dirty bit
        if(cache[i][idx].dirty == 1){
            ANS.to_memory++;
        }
        cache[i][idx].tag = tag;
        ANS.miss++;
        ANS.from_memory++;
        (label == 1) ? (cache[i][idx].dirty = 1) : (cache[i][idx].dirty = 0);   // mark
        if(replace_policy == 0) FIFO(idx, way);
    }
    if(label == 1) cache[i][idx].dirty = 1; // mark

    if(replace_policy == 1) LRU(idx, i, way);
    ANS.demand_fetch++;
}

void dirty_check(int way, int max_idx){
    int i, j;

    for(i = 0; i < way; i++){
        for(j = 0; j < max_idx; j++)
            if(cache[i][j].dirty == 1)
                ANS.to_memory++;
    }
}

void cache_free(int way, int max_idx){
    int i, j;

    for(i = 0; i < way; i++){
        for(j = 0; j < max_idx; j++){
            free(cache[i]);
        }
    }
}