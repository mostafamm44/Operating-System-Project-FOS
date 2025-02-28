#include <inc/lib.h>

//==================================================================================//
//============================ REQUIRED FUNCTIONS ==================================//
//==================================================================================//
//===========================OUR HELPER THINGS======================================//
#define NUM_PAGES ((USER_HEAP_MAX - USER_HEAP_START) / PAGE_SIZE)
#define BITMAP_SIZE (NUM_PAGES / 8)
uint8 bitmap[BITMAP_SIZE] = {0};
#define BITMAP_SET(idx) (bitmap[(idx) / 8] |= (1 << ((idx) % 8)))
#define BITMAP_CLEAR(idx) (bitmap[(idx) / 8] &= ~(1 << ((idx) % 8)))
#define BITMAP_IS_SET(idx) (bitmap[(idx) / 8] & (1 << ((idx) % 8)))
//===========================OUR HELPER THINGS======================================//
//=============================================
// [1] CHANGE THE BREAK LIMIT OF THE USER HEAP:
//=============================================
/*2023*/
//uint32 mark_pages[30000];
void* sbrk(int increment)
{
	//cprintf("calling sys_sbrk=========================>\n");

	return (void*) sys_sbrk(increment);
}
//OUR HELPER FUNCTION
void mark_pages_as_allocated(uint32 start_index, uint32 num_pages) {
    for (uint32 i = start_index; i < start_index + num_pages; i++) {
        BITMAP_SET(i);
    }
}
void mark_pages_as_free(uint32 start_index, uint32 num_pages) {
    for (uint32 i = start_index; i < start_index + num_pages; i++) {
        BITMAP_CLEAR(i);
    }
}

int find_free_pages(uint32 numpages, uint32* startindex) {
    uint32 count = 0;
    for (uint32 i = 0; i < NUM_PAGES; i++) {
        if (!BITMAP_IS_SET(i)) {
            if (count == 0) {
                *startindex = i;
            }
            count++;
            if (count == numpages) {
                return 1;
            }
        } else {
            count = 0;
        }
    }
    return 0;
}
//=================================
// [2] ALLOCATE SPACE IN USER HEAP:
//=================================

uint32 size_va[30000];
void* malloc(uint32 size)
{
	//==============================================================
	//DON'T CHANGE THIS CODE========================================
	if (size == 0) return NULL ;
	//==============================================================
	//TODO: [PROJECT'24.MS2 - #12] [3] USER HEAP [USER SIDE] - malloc()
	// Write your code here, remove the panic and write your code
	//panic("malloc() is not implemented yet...!!");
	//return NULL;
	//Use sys_isUHeapPlacementStrategyFIRSTFIT() and	sys_isUHeapPlacementStrategyBESTFIT()
	//to check the current strategy

	if (size<=DYN_ALLOC_MAX_BLOCK_SIZE){
		//cprintf("here Alloc block--%d\n",size);
		return (void*) alloc_block_FF(size);

	}
	else {


		   uint32 num_wanted_pages = ROUNDUP(size, PAGE_SIZE) / PAGE_SIZE;
		    uint32 start_index = 0;
		    uint32 count=0;
		    uint32 mark=myEnv->khardlimit+PAGE_SIZE;
		        for (uint32 i = 0; i <((USER_HEAP_MAX-myEnv->khardlimit-PAGE_SIZE)/PAGE_SIZE); i++) {

		            if ((sys_mark_page(mark+(i*PAGE_SIZE))&(1<<10))==0&&!BITMAP_IS_SET(i)) {
		        	//if (!BITMAP_IS_SET(i)){
		                if (count == 0) {
		                    start_index = i;
		                }
		                count++;
		                if (count == num_wanted_pages) {
		                    break;
		                }
		            } else {
		                count = 0;
		            }
		        }
		        if(count<num_wanted_pages)
		        	return NULL;
		    uint32 start_va = (myEnv->khardlimit + PAGE_SIZE) + start_index * PAGE_SIZE;
		  //  cprintf("[malloc] Allocating at virtual address: %x\n", start_va);
		    sys_allocate_user_mem(start_va, size);
		    mark_pages_as_allocated(start_index, num_wanted_pages);
		    size_va[start_index] = size;
		   // cprintf("[malloc] Allocation successful, returning address: %x\n", start_va);
		    return (void*)start_va;
}

}

//=================================
// [3] FREE SPACE FROM USER HEAP:
//=================================

void free(void* virtual_address)
{
	//TODO: [PROJECT'24.MS2 - #14] [3] USER HEAP [USER SIDE] - free()
	// Write your code here, remove the panic and write your code
	//panic("free() is not implemented yet...!!");
	//cprintf("virtual address%x\n",virtual_address);
	    if (virtual_address == NULL) {
	        return;
	    }
	    uint32 va = (uint32)virtual_address;
		   // cprintf("va%x\n",va);
		    if ((uint32)virtual_address < USER_HEAP_START ||(uint32) virtual_address >= USER_HEAP_MAX) {
		        panic("ssssss");
		        return;
		    }
		    if ((uint32)virtual_address >= USER_HEAP_START && (uint32)virtual_address < (myEnv->khardlimit)) {
		    	//cprintf("free_block[103]-->%x---hard-->%x\n",virtual_address,myEnv->khardlimit);
		        free_block((void*)virtual_address);
		        return;
		    }
	       virtual_address = ROUNDDOWN(virtual_address, PAGE_SIZE);
	       uint32 index_size = ((va - myEnv->khardlimit - PAGE_SIZE) / PAGE_SIZE);
	       uint32 num_pages_to_free = ROUNDUP(size_va[index_size], PAGE_SIZE) / PAGE_SIZE;

	       sys_free_user_mem(va, size_va[index_size]);
	       mark_pages_as_free(index_size, num_pages_to_free);
	    //   cprintf("[free] Freed memory at address: %x\n", va);

}





//=================================
// [4] ALLOCATE SHARED VARIABLE:
//=================================
void* smalloc(char *sharedVarName, uint32 size, uint8 isWritable)
{
    //==============================================================
    // DON'T CHANGE THIS CODE
    //==============================================================
    if (size == 0) return NULL;


  //  cprintf("[smalloc] Request received: sharedVarName=%s, size=%u, isWritable=%u\n", sharedVarName, size, isWritable);
    uint32 blockalloc = USER_HEAP_START + DYN_ALLOC_MAX_SIZE + PAGE_SIZE;
    uint32 maxxsize = USER_HEAP_MAX - blockalloc - PAGE_SIZE;
    if (size > maxxsize) {
      //  cprintf("[smalloc] Error: Requested size exceeds maximum allocatable size (%u > %u)\n", size, maxxsize);
        return NULL;
    }
    uint32 num_wanted_pages = ROUNDUP(size, PAGE_SIZE) / PAGE_SIZE;
      //cprintf("[smalloc] Number of pages required: %u\n", num_wanted_pages);

      uint32 start_index = 0;
      if (!find_free_pages(num_wanted_pages, &start_index)) {
         // cprintf("[smalloc] No  block found\n");
          return NULL;
      }
      uint32 start_va = (myEnv->khardlimit + PAGE_SIZE) + start_index * PAGE_SIZE;
      int sharedObjectID = sys_createSharedObject(sharedVarName, size, isWritable, (void*)start_va);
      if (sharedObjectID < 0) {
          //cprintf("[smalloc] failed to create shared object, ID=%d\n", sharedObjectID);
          mark_pages_as_free(start_index, num_wanted_pages);
          return NULL;
      }
      mark_pages_as_allocated(start_index, num_wanted_pages);
      //cprintf("[smalloc] shared object created successfully, VA=%x\n", start_va);
      return (void*)start_va;
}


//========================================
// [5] SHARE ON ALLOCATED SHARED VARIABLE:
//========================================
void* sget(int32 ownerEnvID, char *sharedVarName)
{
	//TODO: [PROJECT'24.MS2 - #20] [4] SHARED MEMORY [USER SIDE] - sget()
		// Write your code here, remove the panic and write your code
		    uint32 size = sys_getSizeOfSharedObject(ownerEnvID, sharedVarName);
		    if (size == E_SHARED_MEM_NOT_EXISTS) {
		        return NULL;
		    }
		    uint32 num_wanted_pages = ROUNDUP(size, PAGE_SIZE) / PAGE_SIZE;
		    uint32 start_index = 0;
		    if (!find_free_pages(num_wanted_pages, &start_index)) {
		        return NULL;
		    }
		    uint32* returnaddress = (uint32*)((myEnv->khardlimit + PAGE_SIZE) + start_index * PAGE_SIZE);
		    int soda = sys_getSharedObject(ownerEnvID, sharedVarName, (void*)returnaddress);
		    if (soda < 0) {
		        return NULL;
		    }
		    mark_pages_as_allocated(start_index, num_wanted_pages);
		    return (void*)returnaddress;
}


//==================================================================================//
//============================== BONUS FUNCTIONS ===================================//
//==================================================================================//

//=================================
// FREE SHARED VARIABLE:
//=================================
//	This function frees the shared variable at the given virtual_address
//	To do this, we need to switch to the kernel, free the pages AND "EMPTY" PAGE TABLES
//	from main memory then switch back to the user again.
//
//	use sys_freeSharedObject(...); which switches to the kernel mode,
//	calls freeSharedObject(...) in "shared_memory_manager.c", then switch back to the user mode here
//	the freeSharedObject() function is empty, make sure to implement it.

void sfree(void* virtual_address)
{
	//TODO: [PROJECT'24.MS2 - BONUS#4] [4] SHARED MEMORY [USER SIDE] - sfree()
	// Write your code here, remove the panic and write your code
	panic("sfree() is not implemented yet...!!");
}


//=================================
// REALLOC USER SPACE:
//=================================
//	Attempts to resize the allocated space at "virtual_address" to "new_size" bytes,
//	possibly moving it in the heap.
//	If successful, returns the new virtual_address, in which case the old virtual_address must no longer be accessed.
//	On failure, returns a null pointer, and the old virtual_address remains valid.

//	A call with virtual_address = null is equivalent to malloc().
//	A call with new_size = zero is equivalent to free().

//  Hint: you may need to use the sys_move_user_mem(...)
//		which switches to the kernel mode, calls move_user_mem(...)
//		in "kern/mem/chunk_operations.c", then switch back to the user mode here
//	the move_user_mem() function is empty, make sure to implement it.
void *realloc(void *virtual_address, uint32 new_size)
{
	//[PROJECT]
	// Write your code here, remove the panic and write your code
	panic("realloc() is not implemented yet...!!");
	return NULL;

}


//==================================================================================//
//========================== MODIFICATION FUNCTIONS ================================//
//==================================================================================//

void expand(uint32 newSize)
{
	panic("Not Implemented");

}
void shrink(uint32 newSize)
{
	panic("Not Implemented");

}
void freeHeap(void* virtual_address)
{
	panic("Not Implemented");

}
