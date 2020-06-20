#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <ctype.h>
#include "replace_policy.h"
#include "cache.h"


void FIFO(int idx, int way, int hit){
    int i;

    if(hit) return;
    
    for(i = 0; i < way; i++)
        cache[i][idx].priority == 0 ? cache[i][idx].priority = way - 1 : cache[i][idx].priority--;
}

void LRU(int idx,int cur_way, int way){
    int i, tmp = cache[cur_way][idx].priority;

    for(i = 0; i < way; i++){
        if(tmp == cache[i][idx].priority){
            cache[i][idx].priority = way - 1;
        }
        else if(tmp < cache[i][idx].priority){
            cache[i][idx].priority--;
        }
    }
}