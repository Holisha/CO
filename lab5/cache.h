#ifndef _CACHE_H_
#define _CACHE_H_

typedef struct{
    int valid;
    int tag;
    int dirty;
    int priority;
}Cache;

typedef struct{
    char* file_name;
    unsigned long demand_fetch;
    unsigned long hit;
    unsigned long miss;     // miss rate = miss / demand_fetch
    unsigned long read;
    unsigned long write;
    unsigned long from_memory;
    unsigned long to_memory;
}request;

extern Cache **cache;

extern request ANS;

void cache_init(int way, int max_idx);

void cache_demand(int label, unsigned long block_address, int max_idx, int way, int replace_policy);

void dirty_check(int way, int max_idx);

#endif