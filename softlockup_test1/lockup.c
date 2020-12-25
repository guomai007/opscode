#include <linux/module.h>
static int lockup_init(void)
{
    for (;;)
            ;

    return 0;
}

static void lockup_exit(void)
{
}

module_init(lockup_init);
module_exit(lockup_exit);
