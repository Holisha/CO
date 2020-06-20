# CO lab 5

## 記憶體位置

| tag | index | offset |
| --- | ----- | ------ |
| block addr. / block num    | block addr. % block num      | block size       |
| 用來比較的內容    | 存放位置      | 餘留存幾個 word 的空間 <br>(spatial locality)</br>       |
>**以上都沒有固定大小，視情況而定**
>注意 cache size 跟 block size 的單位，通常會是不同的
>電腦用的是IEC制，與SI制的單位不同(K = 1024)

## 測資

- 使用 test.sh 來測試以下12組測資

![](https://i.imgur.com/B83mOSs.png)

![](https://i.imgur.com/z6LJBwf.png)

![](https://i.imgur.com/bxKU7Va.png)

![](https://i.imgur.com/jTekUS1.png)


## cache.h

- Cache: 不需真的抓資料近來，故沒有 data
    - valid
    - tag
    - dirty
    - priority(**為方便，初值不一定為0**)
>優化: use bit
>資料存取: data

- request: 作業需求
    - file_name
    - demand_fetch
    - hit
    - miss
    - read
    - write
    - from memory
    - to memory

- cache_init: 動態分配快取大小
- cache_demand: 處理進來的記憶體位置，已經先除以 offset 了
- dirty_check: **全部跑完**後要檢查是否有寫過

## replace_policy.h

- FIFO: First In First Out
- LRU: Least Recent Used
    - 更新比當前位置還要大的 priority 即可

## lab5.c

- 起初用 fgets 讀取， gcc.din 裡面有多一行，所以沒寫好會炸掉
- 因為換成 call func，所以執行時間較最初版本的久一點
