#include <inc/memlayout.h>
#include "shared_memory_manager.h"

#include <inc/mmu.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>
#include <inc/queue.h>
#include <inc/environment_definitions.h>

#include <kern/proc/user_environment.h>
#include <kern/trap/syscall.h>
#include "kheap.h"
#include "memory_manager.h"

//==================================================================================//
//============================== GIVEN FUNCTIONS ===================================//
//==================================================================================//
//struct Share* get_share(int32 ownerID, char* name);
//
////===========================
// [1] INITIALIZE SHARES:
//===========================
//Initialize the list and the corresponding lock
void sharing_init()
{
#if USE_KHEAP
	LIST_INIT(&AllShares.shares_list) ;
	init_spinlock(&AllShares.shareslock, "shares lock");
#else
	panic("not handled when KERN HEAP is disabled");
#endif
}


//==============================
// [2] Get Size of Share Object:
//==============================
struct Share* get_share(int32 ownerID, char* name);

int getSizeOfSharedObject(int32 ownerID, char* shareName)
{
	//[PROJECT'24.MS2] DONE
	// This function should return the size of the given shared object
	// RETURN:
	//	a) If found, return size of shared object
	//	b) Else, return E_SHARED_MEM_NOT_EXISTS
	//cprintf("[48]shared obj\n");
	//
	struct Share* ptr_share = get_share((uint32)ownerID, shareName);
	if (ptr_share == NULL)
		return E_SHARED_MEM_NOT_EXISTS;
	else
		return ptr_share->size;

	return 0;
}

//===========================================================


//==================================================================================//
//============================ REQUIRED FUNCTIONS ==================================//
//==================================================================================//
//===========================
// [1] Create frames_storage:
//===========================
// Create the frames_storage and initialize it by 0
inline struct FrameInfo** create_frames_storage(int numOfFrames)
{
	 if (numOfFrames <= 0)
		        return NULL;
	uint32 size=numOfFrames*PAGE_SIZE;
		    struct FrameInfo** frames = (struct FrameInfo**)kmalloc(size);
		    if (frames == NULL)
		        return NULL;
		    for (int i = 0; i < numOfFrames; i++) {
		         frames[i] = 0;
		     }
		    return frames;

}

//=====================================
// [2] Alloc & Initialize Share Object:
//=====================================
//Allocates a new shared object and initialize its member
//It dynamically creates the "framesStorage"
//Return: allocatedObject (pointer to struct Share) passed by reference
struct Share* create_share(int32 ownerID, char* shareName, uint32 size, uint8 isWritable)
{

	struct Share* newshare = (struct Share*)kmalloc(sizeof(struct Share));
	    if (newshare == NULL)
	        return NULL;
	    for (int i = 0; i < sizeof(newshare->name) - 1 && shareName[i] != '\0'; i++) {
	        newshare->name[i] = shareName[i];
	    }
	    strcpy(newshare->name, shareName);
	    uint32 totalPages = ROUNDUP(size, PAGE_SIZE) / PAGE_SIZE;
	    newshare->size = size;
	    newshare->isWritable = isWritable;
	    const uint32 MASK_MSB = 0x7FFFFFFF;
	    newshare->ID = (uint32)newshare & MASK_MSB;
	    newshare->references = 1;
	    newshare->ownerID=ownerID;
	    newshare->framesStorage = (struct FrameInfo**)kmalloc(totalPages * sizeof(struct FrameInfo*));
	    if (newshare->framesStorage == NULL) {
	        cprintf("Failed to allocate framesStorage for newshare\n");
	        kfree(newshare);
	        return NULL;
	    }

	    return newshare;

}

//=============================
// [3] Search for Share Object:
//=============================
//Search for the given shared object in the "shares_list"
//Return:
//	a) if found: ptr to Share object
//	b) else: NULL
struct Share* get_share(int32 ownerID, char* name)
{
	//cprintf("get_share\n");
	//cprintf("[140]shared obj\n");
   acquire_spinlock(&AllShares.shareslock);

		 struct Share* current;
		    LIST_FOREACH(current, &AllShares.shares_list) {
		        if ( current->ownerID == ownerID && strcmp(current->name, name)==0 ) {
		        	release_spinlock(&AllShares.shareslock);
		        	//cprintf("here---name--%s->?-%s---id-->%d--->%d\n",name,current->name,ownerID,current->ownerID);
		           return current;
		        }
		    }
		  //  cprintf("release\n");
      	release_spinlock(&AllShares.shareslock);

		    return NULL;

}

//=========================
// [4] Create Share Object:
//=========================
int createSharedObject(int32 ownerID, char* shareName, uint32 size, uint8 isWritable, void* virtual_address) {
    uint32 *ptr_pagetable = NULL;
   // cprintf("[createSharedObject] Request received: ownerID=%d, shareName=%s, size=%u, isWritable=%u, virtual_address=%p\n",


    if (get_share(ownerID, shareName) != NULL) {
        //cprintf("[createsharedobject] error: shared object with name '%s' already exists\n", shareName);
        return E_SHARED_MEM_EXISTS;
    }

    struct Share* newshare = create_share(ownerID, shareName, size, isWritable);
    if (newshare == NULL) {

        return E_NO_SHARE;
    }

    uint32 ssize = newshare->size;
    struct Env* myEnv = get_cpu_proc();
    uint32 totalPages = ROUNDUP(ssize, PAGE_SIZE) / PAGE_SIZE;

       // cprintf("abdel8afor elbor3y\n");

    uint32 va = (uint32)virtual_address;
    for (uint32 i = 0; i < totalPages; i++) {
        struct FrameInfo* frameInfo = NULL;
        int ret = allocate_frame(&frameInfo);
        if (ret != 0 || frameInfo == NULL) {
           // cprintf("[createsharedObject] Frame allocation failed at page %d\n", i);
            return E_NO_MEM;
        }

        int perm = PERM_PRESENT | PERM_USER| PERM_WRITEABLE;;

        if (isWritable) {
            perm |= PERM_WRITEABLE;
           // cprintf("VALIDATE WRITE AND READ%x\n",perm & PERM_WRITEABLE);
        }
       // cprintf("VALIDATE WRITE AND READ%x\n",perm & PERM_WRITEABLE);

       // cprintf("[createsharedobject] page %u permissions: %x\n", i, perm);

        int mapResult = map_frame(myEnv->env_page_directory, frameInfo, va, perm);
        newshare->framesStorage[i] = frameInfo;
        if (mapResult == E_NO_MEM) {
           // cprintf("[createSharedObject] Error: Failed to map frame to virtual address %p\n", va);
            return E_NO_MEM;
        }
       // cprintf("[createsharedObject] frame %u mapped to VA %p\n", i, va);

        va += PAGE_SIZE;
    }
    //acquire_spinlock(&AllShares.shareslock);
    LIST_INSERT_HEAD(&AllShares.shares_list, newshare);
   // release_spinlock(&AllShares.shareslock);
   // cprintf("[createsharedObject] shared object created: ID=%x\n", newshare->ID);
    return (uint32)newshare->ID;
}


//======================
// [5] Get Share Object:
//======================
int getSharedObject(int32 ownerID, char* shareName, void* virtual_address)
{
	  struct Share* sharedobj = get_share(ownerID, shareName);
	    if (sharedobj != NULL)
	    {
	    struct Env* myEnv = get_cpu_proc();
	    uint32 num = ROUNDUP(sharedobj->size, PAGE_SIZE) / PAGE_SIZE;
	    uint32 va = (uint32)virtual_address;
	    for (uint32 i = 0; i < num; i++)
	    {
	        struct FrameInfo* frameInfo = sharedobj->framesStorage[i];
	            int perm = PERM_PRESENT | PERM_USER;
               if(sharedobj->isWritable==1)
	            perm|= PERM_WRITEABLE;
	            int result = map_frame(myEnv->env_page_directory, frameInfo, va, perm);
	            if (result != 0)
	            {
	                return E_SHARED_MEM_NOT_EXISTS;
	            }
	        va += PAGE_SIZE;
	    }
	    sharedobj->references++;
	    return (uint32)sharedobj->ID;
	    }else{

	    	 return E_SHARED_MEM_NOT_EXISTS;
	    }


	    cprintf("ana get shared object\n");
}

//==================================================================================//
//============================== BONUS FUNCTIONS ===================================//
//==================================================================================//

//==========================
// [B1] Delete Share Object:
//==========================
//delete the given shared object from the "shares_list"
//it should free its framesStorage and the share object itself
void free_share(struct Share *ptrShare)
{
	//TODO: [PROJECT'24.MS2 - BONUS#4] [4] SHARED MEMORY [KERNEL SIDE] - free_share()
	//COMMENT THE FOLLOWING LINE BEFORE START CODING
	panic("free_share is not implemented yet");
	//Your Code is Here...

}
//========================
// [B2] Free Share Object:
//========================
int freeSharedObject(int32 sharedObjectID, void *startVA)
{
	panic("freeSharedObject is not implemented yet");
}
