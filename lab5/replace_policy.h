#ifndef _REPLACE_POLICY_H_
#define _REPLACE_POLICY_H_

void FIFO(int idx, int way, int hit);

void LRU(int idx, int cur_way, int way);

#endif