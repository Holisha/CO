make

./cache.exe 8 32 1 FIFO gcc.din > a1
./cache.exe 8 32 2 LRU gcc.din > a2
./cache.exe 16 16 1 FIFO spice.din > a3
./cache.exe 256 128 f LRU spice.din > a4
./cache.exe 8 4 8 LRU spice.din >a5
./cache.exe 16 16 2 LRU spice.din > a6
./cache.exe 256 32 2 LRU spice.din > a7
./cache.exe 8 32 1 FIFO gcc.din > a8
./cache.exe 32 8 f FIFO gcc.din > a9
./cache.exe 32 8 f LRU gcc.din > a10
./cache.exe 32 8 4 FIFO gcc.din > a11
./cache.exe 32 8 4 LRU gcc.din > a12

vimdiff a1 ./test/t1
vimdiff a2 ./test/t2
vimdiff a3 ./test/t3
vimdiff a4 ./test/t4
vimdiff a5 ./test/t5
vimdiff a6 ./test/t6
vimdiff a7 ./test/t7
vimdiff a8 ./test/t8
vimdiff a9 ./test/t9
vimdiff a10 ./test/t10
vimdiff a11 ./test/t11
vimdiff a12 ./test/t12

rm a*