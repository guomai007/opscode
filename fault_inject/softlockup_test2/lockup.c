#include <sched.h>
int main(int argc, char **argv)
{        
    struct sched_param p = { .sched_priority = 99 };
    sched_setscheduler(0, SCHED_FIFO, &p);
    for (;;)                
            ;
    return 0;
}
