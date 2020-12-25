#include <linux/module.h>
#include <linux/irqflags.h>

static int lockup_init(void)
{
    local_irq_disable();
    for (;;)
            ;
    return 0;

}

static void lockup_exit(void)
{
}
module_init(lockup_init);
module_exit(lockup_exit);
