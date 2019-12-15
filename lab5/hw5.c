#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <ctype.h>

#define DEMAND_SIZE 500
#define ADDRESS_LENGTH 8    // 8
/*
input:
cache cache_size block_size associativity replace_policy file 
1. cache size: KB
2. block size: B
3. 1, 2, 4, 8, f
4. cache, L[idx].priorityRU
5. file: gcc.din, spice.din 
*/
typedef struct{
    int valid;
    int tag;
    unsigned long *data;
    int dirty;
    int priority;
}Cache;

struct{
    char* file_name;
    unsigned long demand_fetch;
    unsigned long hit;
    unsigned long miss;     // miss rate = miss / demand_fetch
    //unsigned long vmiss;  
    //unsigned long nmiss;
    unsigned long read;
    unsigned long write;
    unsigned long from_memory;
    unsigned long to_memory;
}ANS;

void FIFO(int cache_size, int block_size,char *assoicate, FILE *fp){
    int i, j, k, pos, idx, tag, way, words, offset;
    int label;
    unsigned long max_idx = cache_size * 1024 / block_size;
    unsigned long tag_size;
    unsigned long demand, tmp;    // ffffffff = 2^32 - 1
    char str[DEMAND_SIZE];
    char *ptr;
    Cache **cache;
    //FILE *debug = fopen("index.txt","w");

    words = block_size / 4; // number of words
    isalpha(assoicate[0]) ? (way = 1) : (way = atoi(assoicate));
    max_idx /= way;
    cache = malloc(sizeof(Cache*) * way);
    for(i = 0; i < way; i++){   // init
        cache[i] = malloc(sizeof(Cache)* max_idx);
        for(j = 0; j < max_idx; j++){
            cache[i][j].valid = 0;
            cache[i][j].tag = 0;
            cache[i][j].data = malloc(sizeof(unsigned long) * words);
            cache[i][j].dirty = 0;
            isalpha(assoicate[0]) ? (cache[i][j].priority = j) : (cache[i][j].priority = i); // fully = idx
        }
    }
    offset = block_size;
    tag_size = 32 - log2(max_idx) - log2(offset);
    tag_size = pow(2, tag_size);    // 2 ^ tag_size
    /*
    printf("\ntag_size bit %lu\n", tag_size);
    printf("max_idx %lu\n", max_idx);
    printf("offset %d\n", offset);
    printf("way %d\n", way);
    printf("words %d\n\n", words);
    */
    while(fgets(str, DEMAND_SIZE, fp) != NULL){
        // demand fetch
        ptr = strtok(str, " ");
        label = atoi(ptr);
        ptr = strtok(NULL, "\n");
        if(ptr == NULL) // gcc has \n only
            break;

        demand = 0;
        for(i = 0; i < strlen(ptr); i++){
            if(isalpha(ptr[i])){
                tmp = ptr[i] - 'a' + 10;
            }else{
                tmp = ptr[i] - '0';
            }
            demand += tmp * pow(16, strlen(ptr) - i - 1);
        }

        if(label == 0){
            ANS.read++;
        }
        else if(label == 1){
            ANS.write++;
        }

        if(assoicate[0]!='f'){
            tmp = demand;
            demand /= offset;            // block address
            idx = demand % max_idx;      // idx
            tag = demand / max_idx;      // request tag
            demand = tmp;

            for(i = 0; i < way; i++){
                // init state
                if(cache[i][idx].valid == 0){ 
                    cache[i][idx].valid = 1;
                    cache[i][idx].tag = tag;

                    for(j = 0; j < words; j++){
                        cache[i][idx].data[j] = demand + (4*j);   // spatial locality
                    }

                    for(j = 0; j < way; j++){   // update
                        (cache[i][idx].priority == 0) ? (cache[i][idx].priority = way - 1) : (cache[i][idx].priority--);
                    }
                    
                    ANS.from_memory++;
                    ANS.miss++;
                    //ANS.nmiss++;
                    break;
                }
                else if(cache[i][idx].tag == tag){    // valid & hit
                    ANS.hit++;
                    break;
                }
            }
            if(i == way){   // valid & miss
                for(i = 0; i < way; i++){
                    if(cache[i][idx].priority == 0){
                        if(cache[i][idx].dirty == 1){
                            ANS.to_memory++;
                        }
                        cache[i][idx].tag = tag;
                        for(j = 0; j < words; j++){ // spatial locality
                            cache[i][idx].data[j] = demand + (4*j);
                        }
                        ANS.from_memory++;  // read data
                        (label == 1) ? (cache[i][idx].dirty = 1) : (cache[i][idx].dirty = 0);   // mark
                        cache[i][idx].priority = way - 1;   // priority update
                    }
                    else{
                        cache[i][idx].priority--;
                    }
                }
                //ANS.vmiss++;
                ANS.miss++;
            }
            else if(label == 1){
                cache[i][idx].dirty = 1;
            }
        }

        else{   // associate 'f'
            tag = demand/offset;

            for(idx = 0; idx < max_idx; idx++){
                if(cache[0][idx].valid == 0){
                    cache[0][idx].valid = 1;
                    cache[0][idx].tag = tag;
                    for(i = 0; i < words; i++){
                        cache[0][idx].data[i] = demand + (4*i);
                    }
                    for(i = 0; i < max_idx; i++){   // update
                        (i==idx) ? (cache[0][i].priority = max_idx - 1) : (cache[0][i].priority--);
                    }
                    ANS.from_memory++;
                    ANS.miss++;
                    break;
                }else if(cache[0][idx].tag == tag){
                    ANS.hit++;
                    break;
                    /*
                    for(i = 0; i < words && cache[0][idx].data[i] != demand; i++);
                    if(i != words){ // hit
                        ANS.hit++;
                        break;
                    }
                    */
                }
            }

            if(idx == max_idx){ // miss
                for(i = 0; i < max_idx; i++){
                    // update priority
                    if(cache[0][i].priority == 0){
                        cache[0][i].tag = tag;
                        if(cache[0][i].dirty == 1){
                            ANS.to_memory++;
                        }
                        (label == 1) ? (cache[0][i].dirty = 1) : (cache[0][i].dirty = 0);   // mark
                        for(j = 0; j < words; j++){
                            cache[0][i].data[j] = demand + (4*j);
                        }
                        cache[0][i].priority = max_idx - 1;
                    }
                    else{
                        cache[0][i].priority--;
                    }
                }
                ANS.from_memory++;
                ANS.miss++;
            }
            else if(label == 1){
                cache[0][idx].dirty = 1;
            }
        }   // 'f'
        ANS.demand_fetch++;
    }   // fgets
    
    for(i = 0; i < way; i++){   // check it's final state
        for(j = 0; j < max_idx; j++)
            if(cache[i][j].dirty == 1)
                ANS.to_memory++;
    }
    //fclose(debug);
    //printf("demand %lu\ntag %lu\nindex %lu\n\n",demand, tag, idx);
}

void LRU(int cache_size, int block_size,char *assoicate, FILE *fp){
    int i, j, k, pos, idx, tag, way, words, offset;
    int label;
    unsigned long max_idx = cache_size * 1024 / block_size;
    unsigned long tag_size;
    unsigned long demand, tmp;    // ffffffff = 2^32 - 1
    char str[DEMAND_SIZE];
    char *ptr;
    Cache **cache;
    //FILE *debug = fopen("index.txt","w");

    words = block_size / 4; // number of words
    isalpha(assoicate[0]) ? (way = 1) : (way = atoi(assoicate));
    max_idx /= way;
    cache = malloc(sizeof(Cache*) * way);
    for(i = 0; i < way; i++){   // init
        cache[i] = malloc(sizeof(Cache)* max_idx);
        for(j = 0; j < max_idx; j++){
            cache[i][j].valid = 0;
            cache[i][j].tag = 0;
            cache[i][j].data = malloc(sizeof(unsigned long) * words);
            cache[i][j].dirty = 0;
            isalpha(assoicate[0]) ? (cache[i][j].priority = j) : (cache[i][j].priority = i); // fully = idx
        }
    }
    offset = block_size;
    tag_size = 32 - log2(max_idx) - log2(offset);
    tag_size = pow(2, tag_size);    // 2 ^ tag_size
    
    while(fgets(str, DEMAND_SIZE, fp) != NULL){
        // demand fetch
        ptr = strtok(str, " ");
        label = atoi(ptr);
        ptr = strtok(NULL, "\n");
        if(ptr == NULL) // gcc has \n only
            break;

        demand = 0;
        for(i = 0; i < strlen(ptr); i++){
            if(isalpha(ptr[i])){
                tmp = ptr[i] - 'a' + 10;
            }else{
                tmp = ptr[i] - '0';
            }
            demand += tmp * pow(16, strlen(ptr) - i - 1);
        }

        if(label == 0){
            ANS.read++;
        }
        else if(label == 1){
            ANS.write++;
        }

        if(assoicate[0]!='f'){
            tmp = demand;
            demand /= offset;            // block address
            idx = demand % max_idx;      // idx
            tag = demand / max_idx;      // request tag
            demand = tmp;

            for(i = 0; i < way; i++){
                // init state
                if(cache[i][idx].valid == 0){ 
                    cache[i][idx].valid = 1;
                    cache[i][idx].tag = tag;

                    for(j = 0; j < words; j++){
                        cache[i][idx].data[j] = demand + (4*j);   // spatial locality
                    }
                    
                    ANS.from_memory++;
                    ANS.miss++;
                    //ANS.nmiss++;
                    break;
                }
                else if(cache[i][idx].tag == tag){    // valid & hit
                    ANS.hit++;
                    break;
                }
            }
            if(i == way){   // valid & miss
                for(i = 0; i < way; i++){
                    if(cache[i][idx].priority == 0){
                        tmp = i;
                        if(cache[i][idx].dirty == 1){
                            ANS.to_memory++;
                        }
                        cache[i][idx].tag = tag;
                        for(j = 0; j < words; j++){ // spatial locality
                            cache[i][idx].data[j] = demand + (4*j);
                        }
                        ANS.from_memory++;  // read data
                        (label == 1) ? (cache[i][idx].dirty = 1) : (cache[i][idx].dirty = 0);   // mark
                    }
                }
                i = tmp;
                //ANS.vmiss++;
                ANS.miss++;
            }
            else if(label == 1){
                cache[i][idx].dirty = 1;
            }
            // update
            tmp = cache[i][idx].priority;
            for(i = 0; i < way; i++){
                if(tmp == cache[i][idx].priority){
                    cache[i][idx].priority = way - 1;
                }
                else if(tmp < cache[i][idx].priority)
                    cache[i][idx].priority--;
            }
        }

        else{   // associate 'f'
            tag = demand/offset;

            for(idx = 0; idx < max_idx; idx++){
                if(cache[0][idx].valid == 0){   // init
                    cache[0][idx].valid = 1;
                    cache[0][idx].tag = tag;
                    for(i = 0; i < words; i++){
                        cache[0][idx].data[i] = demand + (4*i);
                    }
                    ANS.from_memory++;
                    ANS.miss++;
                    break;
                }else if(cache[0][idx].tag == tag){
                    ANS.hit++;
                    break;
                }
            }

            if(idx == max_idx){ // miss
                for(i = 0; i < max_idx; i++){
                    // update priority
                    if(cache[0][i].priority == 0){
                        idx = i;
                        cache[0][i].tag = tag;
                        if(cache[0][i].dirty == 1){
                            ANS.to_memory++;
                        }
                        (label == 1) ? (cache[0][i].dirty = 1) : (cache[0][i].dirty = 0);   // mark
                        for(j = 0; j < words; j++){
                            cache[0][i].data[j] = demand + (4*j);
                        }
                    }
                }
                ANS.from_memory++;
                ANS.miss++;
            }
            else if(label == 1){
                cache[0][idx].dirty = 1;
            }
            // update
            tmp = cache[0][idx].priority;
            for(i = 0; i < max_idx; i++){
                if(tmp == cache[0][i].priority){
                    cache[0][i].priority = max_idx - 1;
                }
                else if(tmp < cache[0][i].priority)
                    cache[0][i].priority--;
            }
        }   // 'f'
        ANS.demand_fetch++;
    }   // fgets
    
    for(i = 0; i < way; i++){   // check it's final state
        for(j = 0; j < max_idx; j++)
            if(cache[i][j].dirty == 1)
                ANS.to_memory++;
    }
    //fclose(debug);
    //printf("demand %lu\ntag %lu\nindex %lu\n\n",demand, tag, idx);
}

int main(int argc, char** argv){
    int i;
    int cache_size, block_size, idx;
    FILE *fp;

    if(argc != 6){
        printf("Error Input value\n");
        return 0;
    }
    // init
    cache_size = atoi(argv[1]);
    block_size = atoi(argv[2]);
    fp = fopen(argv[5], "r");
    ANS.file_name = strdup(argv[5]);
    ANS.demand_fetch = 0;
    ANS.hit = 0;
    //ANS.vmiss = 0;
    //ANS.nmiss = 0;
    ANS.miss = 0;
    ANS.read = 0;
    ANS.write = 0;
    ANS.from_memory = 0;
    ANS.to_memory = 0;

    //printf("Input file = %s\n", ANS.file_name);

    if(strcmp(argv[4], "FIFO") == 0){
        FIFO(cache_size, block_size, argv[3], fp); // cache and block size, associativity, fp
    }
    if(strcmp(argv[4], "LRU") == 0){
        LRU(cache_size, block_size, argv[3], fp); // cache and block size, associativity, fp
    }
    
    printf("Input file = %s\n", ANS.file_name);
    printf("Demand fetch = %lu\n", ANS.demand_fetch);
    printf("Cache hit = %lu\n",ANS.hit);
    printf("Cache miss = %lu\n",ANS.miss);
    //ANS.miss = ANS.vmiss + ANS.nmiss;
    //printf("Cache vmiss = %lu\nCache nmiss = %lu\n", ANS.vmiss, ANS.nmiss);
    printf("Miss rate = %.4f\n",(double) ANS.miss /(double) ANS.demand_fetch);
    printf("Read data = %lu\n",ANS.read);
    printf("Write data = %lu\n",ANS.write);
    printf("Bytes from memory = %lu\n",ANS.from_memory * block_size);
    printf("Bytes to memory = %lu\n", ANS.to_memory * block_size);

    fclose(fp);
    return 0;
}