// User-level Semaphore

#include "inc/lib.h"

struct semaphore create_semaphore(char *semaphoreName, uint32 value)
{
	//[PROJECT'24.MS3]
	//COMMENT THE FOLLOWING LINE BEFORE START CODING
	//panic("create_semaphore is not implemented yet");
	struct semaphore newsemaphore;
    newsemaphore.semdata = (struct __semdata*)smalloc(semaphoreName, sizeof(struct __semdata), 1);
 //   cprintf("hakooooona matatataaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\n");
	     newsemaphore.semdata->count = value;
	    // cprintf("hakooooona matatataaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\n");
	     newsemaphore.semdata->lock = 0;
	     //cprintf("hakooooona matatataaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\n");
	     sys_init_queue(&(newsemaphore.semdata->queue));



	   //  cprintf("hakooooona matatataaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\n");
	     strncpy(newsemaphore.semdata->name, semaphoreName, sizeof(newsemaphore.semdata->name) - 1);
	     newsemaphore.semdata->name[sizeof(newsemaphore.semdata->name) - 1] = '\0';
	    return newsemaphore;
}
struct semaphore get_semaphore(int32 ownerEnvID, char* semaphoreName)
{
	//[PROJECT'24.MS3]
	//COMMENT THE FOLLOWING LINE BEFORE START CODING
	//panic("get_semaphore is not implemented yet");

	  void* semaphorememory = sget(ownerEnvID, semaphoreName);

	    if (semaphorememory == NULL) {
	        // If the shared semaphore does not exist, return an empty wrapper
	        struct semaphore emptySemaphore;
	        emptySemaphore.semdata = NULL; // Indicate that no semaphore exists
	        return emptySemaphore;
	    }

	    // Create a wrapper semaphore object
	    struct semaphore sem;
	    sem.semdata = (struct __semdata*)semaphorememory;



	    return sem;

}

void wait_semaphore(struct semaphore sem)
{
	//[PROJECT'24.MS3]
	//COMMENT THE FOLLOWING LINE BEFORE START CODING
	//panic("wait_semaphore is not implemented yet");

	    // Acquire the lock
	//cprintf("my print %d\n ",sem.semdata->lock);
	 // while (xchg(&(sem.semdata->lock), 1) != 0);

	    sem.semdata->count--;
	    if (sem.semdata->count < 0){



	    	sys_push_queue(&(sem.semdata->queue),&(sem.semdata->lock));



	    } else {

	    	sem.semdata->lock = 0;
	    }

}

void signal_semaphore(struct semaphore sem)
{


	//[PROJECT'24.MS3]
	//COMMENT THE FOLLOWING LINE BEFORE START CODING
	  //while (xchg(&(sem.semdata->lock), 1) != 0);

	  sem.semdata->count++ ;
	  	if(sem.semdata->count<=0){



	  				sys_removegive_queue(&(sem.semdata->queue));



	  	}else{


	  	sem.semdata->lock=0 ;
	  	}
}

int semaphore_count(struct semaphore sem)
{
	return sem.semdata->count;
}
