#include "kheap.h"
#include <kern/disk/pagefile_manager.h>
#include <inc/memlayout.h>
#include <inc/dynamic_allocator.h>
#include "memory_manager.h"

//Initialize the dynamic allocator of kernel heap with the given start address, size & limit
//All pages in the given range should be allocated
//Remember: call the initialize_dynamic_allocator(..) to complete the initialization
//Return:
//	On success: 0
//	Otherwise (if no memory OR initial size exceed the given limit): PANIC

int initialize_kheap_dynamic_allocator(uint32 daStart, uint32 initSizeToAllocate, uint32 daLimit) {
	//TODO: [PROJECT'24.MS2 - #01] [1] KERNEL HEAP - initialize_kheap_dynamic_allocator
		// Write your code here, remove the panic and write your code
	//panic("initial size exceeds the given limit!");
    if (initSizeToAllocate > daLimit - daStart) {
        panic("initial size exceeds the given limit!");
    }

    kstart = daStart;
    kbrk = daStart + initSizeToAllocate;
    khardlimit = daLimit;
    //cprintf("zzzzzzzzzzzzzzzzzzzzzzzzzzz%x",daLimit);


    for (uint32 i = kstart; i < kbrk; i += PAGE_SIZE) {



        uint32 *ptr_page_table = NULL;
        struct FrameInfo *ptr_frame_info = get_frame_info(ptr_page_directory, i, &ptr_page_table);

        if (ptr_frame_info == NULL) {
            int allocResult = allocate_frame(&ptr_frame_info);
            if (allocResult != E_NO_MEM) {

                int mapResult = map_frame(ptr_page_directory, ptr_frame_info, i, PERM_WRITEABLE | PERM_PRESENT);
                if (mapResult == E_NO_MEM) {
                    panic("failed to map frame to virtual address");
                }
            }
        }
    }


    initialize_dynamic_allocator(daStart, initSizeToAllocate);

    return 0;
}

	/* numOfPages > 0: move the segment break of the kernel to increase the size of its heap by the given numOfPages,
	 * 				you should allocate pages and map them into the kernel virtual address space,
	 * 				and returns the address of the previous break (i.e. the beginning of newly mapped memory).
	 * numOfPages = 0: just return the current position of the segment break
	 *
	 * NOTES:
	 * 	1) Allocating additional pages for a kernel dynamic allocator will fail if the free frames are exhausted
	 * 		or the break exceed the limit of the dynamic allocator. If sbrk fails, return -1
	 */

	//MS2: COMMENT THIS LINE BEFORE START CODING==========
	//return (void*)-1 ;
	//====================================================

	//TODO: [PROJECT'24.MS2 - #02] [1] KERNEL HEAP - sbrk
	// Write your code here, remove the panic and write your code
	//panic("sbrk() is not implemented yet...!!");


	// cprintf("kbrk: %p, khardlimit: %p, numOfPages: %d\n", kbrk, khardlimit, numOfPages);




void* sbrk(int numOfPages) {

  //  cprintf("kbrk: %p, khardlimit: %p, numOfPages: %d\n", kbrk, khardlimit, numOfPages);


    if (numOfPages == 0) {
      //  cprintf("returning current break: %p\n", kbrk);
        return (void*)(kbrk);
    }


    if (numOfPages < 0) {

        return (void*)-1;
    }


    uint32 size = numOfPages * PAGE_SIZE;
   // cprintf(" size: %u bytes\n", size);


    unsigned int new_break = kbrk + size;
   // cprintf("calculated new_break: %p\n", (void*)new_break);


    if (new_break > khardlimit) {

        return (void*)-1;
    }
    uint32 *ptr_page_table = NULL;
      struct FrameInfo *ptr_frame_info = get_frame_info(ptr_page_directory, kbrk, &ptr_page_table);
      uint32 brk_tmp=kbrk;
    for(int i=0;i<numOfPages;i++){


               int allocResult = allocate_frame(&ptr_frame_info);
               if (allocResult != E_NO_MEM) {
                   int mapResult = map_frame(ptr_page_directory, ptr_frame_info, brk_tmp, PERM_WRITEABLE |PERM_PRESENT);
                   brk_tmp+=PAGE_SIZE;
                   if (mapResult == E_NO_MEM) {

                       panic("sssssssssssssssssssssssssssssssssssssssssss");

                   }









               }


         }
         unsigned int old_break = kbrk;
         kbrk = new_break;


       //  cprintf("updated kbrk: %p\n", (void*)kbrk);
         //cprintf("returning old break: %p\n", (void*)old_break);
         return (void*)old_break;
}

//TODO: [PROJECT'24.MS2 - BONUS#2] [1] KERNEL HEAP - Fast Page Allocator

void* kmalloc(unsigned int size)
{
	//TODO: [PROJECT'24.MS2 - #03] [1] KERNEL HEAP - kmalloc
	// Write your code here, remove the panic and write your code
//_into_prompt("kmalloc() is not implemented yet...!!");

	//use "isKHeapPlacementStrategyFIRSTFIT() ..." functions to check the current strategy
uint32 pageadd=0;
  if (size<=2048){



	 // cprintf("here block \n");
	return(void*) alloc_block_FF(size);
 }
  else{


	uint32 num_wanted_pages =ROUNDUP(size,4*1024)/(4*1024);
	 // cprintf("iam here mothere%d ",num_wanted_pages);
	  uint32 *ptr_pagetable = NULL;
int count=0;
struct FrameInfo *ptr_frameinfo;
uint32*page_table;
//cprintf("here y3m %x\n",khardlimit+(4*1024));
	  for (uint32 i = khardlimit+(4*1024); i <= KERNEL_HEAP_MAX-(4*1024); i += PAGE_SIZE) {
		get_page_table(ptr_page_directory,i,&page_table);
		uint32 presbit=page_table[PTX(i)]&1;
		if (presbit==0){

		  count++;
		  if(pageadd==0)
			pageadd=i;
			if (count==num_wanted_pages)break;
		}

		  else{ count =0;
		  pageadd=0;
		//cprintf("herefor %d/n",pageadd);
		  }


	  }
      if (count<num_wanted_pages)return NULL;
      //cprintf("First here %d/n", pageadd =((num_wanted_pages-1)*PAGE_SIZE));

    //  cprintf("numof pageee%d/n", num_wanted_pages);

uint32 pagetemp=pageadd;
     for(int i=0;i<num_wanted_pages;i++){
          int allocResult = allocate_frame(&ptr_frameinfo);




          if (allocResult != E_NO_MEM) {

              int mapResult = map_frame(ptr_page_directory, ptr_frameinfo, pagetemp,PERM_PRESENT|PERM_WRITEABLE);
              //get_page_table(ptr_page_directory,pagetemp,&page_table);
              		//uint32 presbit=page_table[PTX(pagetemp)]&1;
              	  	  	  //cprintf("iam here\n%d",presbit);
              ptr_frameinfo->size=num_wanted_pages;
              	  pagetemp+=PAGE_SIZE;
              if (mapResult == E_NO_MEM) {
                 panic("failed to map frame to virtual address");
              }
          }
          	  	  	  	  	  	  	  	}

 //cprintf("last%x/n",pageadd);

  return (void*)pageadd;
  }



}



void kfree(void* virtual_address)
{
	//TODO: [PROJECT'24.MS2 - #04] [1] KERNEL HEAP - kfree
	// Write your code here, remove the panic and write your code
	//panic("kfree() is not implemented yet...!!");

	//you need to get the size of the given allocation using its address
	//refer to the project presentation and documentation for details
	//cprintf("vm--%x---kstart--%x--hard--%x\n",virtual_address,kbrk,khardlimit);
if((uint32)virtual_address<KERNEL_HEAP_MAX&&(uint32)virtual_address>=(khardlimit+(4*1024))){
	uint32* page_table;
	uint32 xx=pf_calculate_free_frames();
	//cprintf("freee%d\n",xx);
	uint32 num_of_free_pages=get_frame_info(ptr_page_directory,(uint32)virtual_address,&page_table)->size;
	//get_page_table(ptr_page_directory,(uint32)virtual_address,&page_table);
//	cprintf("hereee%d",num_of_free_pages,"\n");
	for(uint32 i=0;i<num_of_free_pages;i++){

	unmap_frame(ptr_page_directory,(uint32) virtual_address);
	virtual_address+=PAGE_SIZE;
	}

}
else if((uint32)virtual_address>=(uint32)kstart&&(uint32)virtual_address<(uint32)kbrk){
	//cprintf("hereee before block\n");
	free_block(virtual_address);
	//cprintf("hereee block freeeeeee doneeee\n");
}

else panic("painccc");
}

unsigned int kheap_physical_address(unsigned int virtual_address)
{
	//TODO: [PROJECT'24.MS2 - #05] [1] KERNEL HEAP - kheap_physical_address
	// Write your code here, remove the panic and write your code

	//panic("kheap_physical_address() is not implemented yet...!!");

	//return the physical address corresponding to given virtual_address
	//refer to the project presentation and documentation for details

	//EFFICIENT IMPLEMENTATION ~O(1) IS REQUIRED ==================
	uint32 *page_table;
	get_page_table(ptr_page_directory,virtual_address,&page_table);


	return page_table[PTX(virtual_address)]+( virtual_address & 0xFFF);
}

unsigned int kheap_virtual_address(unsigned int physical_address)
{
	//TODO: [PROJECT'24.MS2 - #06] [1] KERNEL HEAP - kheap_virtual_address
	// Write your code here, remove the panic and write your code
	panic("kheap_virtual_address() is not implemented yet...!!");

	//return the virtual address corresponding to given physical_address
	//refer to the project presentation and documentation for details

	//EFFICIENT IMPLEMENTATION ~O(1) IS REQUIRED ==================
}
//=================================================================================//
//============================== BONUS FUNCTION ===================================//
//=================================================================================//
// krealloc():

//	Attempts to resize the allocated space at "virtual_address" to "new_size" bytes,
//	possibly moving it in the heap.
//	If successful, returns the new virtual_address, if moved to another loc: the old virtual_address must no longer be accessed.
//	On failure, returns a null pointer, and the old virtual_address remains valid.

//	A call with virtual_address = null is equivalent to kmalloc().
//	A call with new_size = zero is equivalent to kfree().

void *krealloc(void *virtual_address, uint32 new_size)
{
	//TODO: [PROJECT'24.MS2 - BONUS#1] [1] KERNEL HEAP - krealloc
	// Write your code here, remove the panic and write your code
	return NULL;
	panic("krealloc() is not implemented yet...!!");
}
