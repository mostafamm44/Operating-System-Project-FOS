#include "kheap.h"
#include <kern/disk/pagefile_manager.h>
#include <inc/memlayout.h>
#include <inc/dynamic_allocator.h>
#include "memory_manager.h"
//#include <kern/conc/sleeplock.c>
//Initialize the dynamic allocator of kernel heap with the given start address, size & limit
//All pages in the given range should be allocated
//Remember: call the initialize_dynamic_allocator(..) to complete the initialization
//Return:
//	On success: 0
//	Otherwise (if no memory OR initial size exceed the given limit): PANIC
struct spinlock  klock;
struct spinlock  ff;
//struct sleeplock lk;
//struct sleeplock lk;
int initialize_kheap_dynamic_allocator(uint32 daStart, uint32 initSizeToAllocate, uint32 daLimit) {
	//TODO: [PROJECT'24.MS2 - #01] [1] KERNEL HEAP - initialize_kheap_dynamic_allocator
		// Write your code here, remove the panic and write your code
	//panic("initial size exceeds the given limit!");

   init_spinlock(&klock,"klock");
   init_spinlock(&ff,"ff");
   //init_sleeplock(&lk,"name");

    if (initSizeToAllocate > daLimit - daStart) {
        panic("initial size exceeds the given limit!");
    }
    acquire_spinlock(&klock);
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

                ptr_frame_info->vm=i;
                if (mapResult == E_NO_MEM) {
                    panic("failed to map frame to virtual address");
                }
            }
        }
    }



    initialize_dynamic_allocator(daStart, initSizeToAllocate);
    release_spinlock(&klock);
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

		//cprintf("sbrk kernel heap\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
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
    	//cprintf("new break greater than hard limit\n");

        return (void*)-1;
    }
    	       acquire_spinlock(&klock);
    uint32 *ptr_page_table = NULL;
      struct FrameInfo *ptr_frame_info = get_frame_info(ptr_page_directory, kbrk, &ptr_page_table);
      uint32 brk_tmp=kbrk;
    for(int i=0;i<numOfPages;i++){

               int allocResult = allocate_frame(&ptr_frame_info);

               if (allocResult != E_NO_MEM) {
                   int mapResult = map_frame(ptr_page_directory, ptr_frame_info, brk_tmp, PERM_WRITEABLE |PERM_PRESENT);
                   ptr_frame_info->vm=brk_tmp;
                   brk_tmp+=PAGE_SIZE;
                   if (mapResult == E_NO_MEM) {

                       panic("sssssssssssssssssssssssssssssssssssssssssss");

                   }









               }


         }
         unsigned int old_break = kbrk;
         kbrk = new_break;


       //  cprintf("updated kbrk: %p\n", (void*)kbrk);
                  release_spinlock(&klock);
         //cprintf("returning old break: %p\n", (void*)old_break);
         return (void*)old_break;
}

//TODO: [PROJECT'24.MS2 - BONUS#2] [1] KERNEL HEAP - Fast Page Allocator
//LIST_INSERT_HEAD(&freeBlocksList,FreeBlock);
//bool bb=1;
void* kmalloc(unsigned int size)
{
	//TODO: [PROJECT'24.MS2 - #03] [1] KERNEL HEAP - kmalloc
	// Write your code here, remove the panic and write your code
//_into_prompt("kmalloc() is not implemented yet...!!");

	//use "isKHeapPlacementStrategyFIRSTFIT() ..." functions to check the current strategy
	//cprintf("acquire the  lock\n");
struct FrameInfo *ptr_frameinfo;
uint32 pageadd=0;
  if (size<=2048){

	  	 // if(bb){cprintf(" again block\n");bb=0;}
	acquire_spinlock(&ff);
			void* re=alloc_block_FF(size);
	 // cprintf("release for block\n");
	  release_spinlock(&ff);
	  //cprintf("here block \n");
	return(void*)re;
 }
  else{
	 // bb=1;
	  //cprintf("entering paging\n");

	uint32 num_wanted_pages =ROUNDUP(size,4*1024)/(4*1024);
	 // cprintf("iam here mothere%d ",num_wanted_pages);
	  uint32 *ptr_pagetable = NULL;
int count=0;
uint32*page_table;
acquire_spinlock(&klock);
//cprintf("here y3m %x\n",khardlimit+(4*1024));
	  for (uint32 i = khardlimit+(4*1024); i <=( KERNEL_HEAP_MAX-(4*1024)); i += PAGE_SIZE) {
		get_page_table(ptr_page_directory,i,&page_table);
		uint32 presbit=page_table[PTX(i)]&1;
		if (presbit==0){

		  count++;
		  if(pageadd==0)
			pageadd=i;
			if (count==num_wanted_pages)break;
		}

		  else{
			 struct  FrameInfo *frame;
			 frame= get_frame_info(ptr_page_directory,i,&page_table);
			  i+=(frame->size*PAGE_SIZE)-PAGE_SIZE;


			  count =0;
		  pageadd=0;
		//cprintf("herefor %d/n",pageadd);
		  }


	  }
      if (count<num_wanted_pages){
    	  cprintf("release for null\n");
    	  release_spinlock(&klock);

    	  return NULL;}
      //cprintf("First here %d/n", pageadd =((num_wanted_pages-1)*PAGE_SIZE));

    //  cprintf("numof pageee%d/n", num_wanted_pages);

uint32 pagetemp=pageadd;
     for(int i=0;i<num_wanted_pages;i++){
    	// acquire_spinlock(&klock);

          int allocResult = allocate_frame(&ptr_frameinfo);



          if (allocResult != E_NO_MEM) {

              int mapResult = map_frame(ptr_page_directory, ptr_frameinfo, pagetemp,PERM_PRESENT|PERM_WRITEABLE);
              //get_page_table(ptr_page_directory,pagetemp,&page_table);
              		//uint32 presbit=page_table[PTX(pagetemp)]&1;
          //    release_spinlock(&klock);

              //cprintf("iam here\n%d",presbit);
              ptr_frameinfo->size=num_wanted_pages;
              	  ptr_frameinfo->vm=pagetemp;
              	  pagetemp+=PAGE_SIZE;
              if (mapResult == E_NO_MEM) {
                 panic("failed to map frame to virtual address");
              }
          }
          	  	  	  	  	  	  	  	}

 //cprintf("last%x/n",pageadd);
    // cprintf("release the lock\n");
     release_spinlock(&klock);
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
	//cprintf("vm--%x---kstart--%x--hard--%x\n",virtual_address,kstart,khardlimit);
	//cprintf("kfree==============\n");
//	acquire_spinlock(&klock);
if((uint32)virtual_address<KERNEL_HEAP_MAX&&(uint32)virtual_address>=(khardlimit+(4*1024))){
	uint32* page_table;
	//uint32 xx=pf_calculate_free_frames();
	//cprintf("freee%d\n",xx);
	uint32 num_of_free_pages=get_frame_info(ptr_page_directory,(uint32)virtual_address,&page_table)->size;
	//get_page_table(ptr_page_directory,(uint32)virtual_address,&page_table);
//	cprintf("hereee%d",num_of_free_pages,"\n");
	for(uint32 i=0;i<num_of_free_pages;i++){

	unmap_frame(ptr_page_directory,(uint32) virtual_address);
	virtual_address+=PAGE_SIZE;
	}

}
else if((uint32)virtual_address>=(uint32)kstart&&(uint32)virtual_address<(uint32)khardlimit){
	//cprintf("hereee before block\n");
	free_block(virtual_address);
	//cprintf("hereee block freeeeeee doneeee\n");
}

else panic("painccc");
//release_spinlock(&klock);

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
if(page_table[PTX(virtual_address)]&0x1)

	return (page_table[PTX(virtual_address)]& 0xFFFFF000)+( virtual_address & 0x00000FFF);
else return 0;
}

unsigned int kheap_virtual_address(unsigned int physical_address)
{
	//TODO: [PROJECT'24.MS2 - #06] [1] KERNEL HEAP - kheap_virtual_address
	// Write your code here, remove the panic and write your code
	//panic("kheap_virtual_address() is not implemented yet...!!");

	//return the virtual address corresponding to given physical_address
	//refer to the project presentation and documentation for details

	//EFFICIENT IMPLEMENTATION ~O(1) IS REQUIRED ==================

	struct FrameInfo *ptr_frame;
	ptr_frame=to_frame_info(physical_address);
	if (ptr_frame->references>0)
	return ptr_frame->vm+(physical_address&0x00000fff);
	else return 0;
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
//	panic("krealloc() is not implemented yet...!!");
//	void *krealloc(void *virtual_address, uint32 new_size)
//	{
		//TODO: [PROJECT'24.MS2 - BONUS#1] [1] KERNEL HEAP - krealloc
		// Write your code here, remove the panic and write your code
		int isdblock = 0;
			if (virtual_address >= (void*) KERNEL_HEAP_START && virtual_address < (void*)khardlimit ) {
				isdblock = 1;
			}

			if (new_size == 0) {
				kfree(virtual_address);
				return NULL;
			}
			if (virtual_address == NULL) {
				return kmalloc(new_size);
			}
			uint32 pagePtr = khardlimit + PAGE_SIZE;
		    uint32* ptr_page_table = NULL;
			int ret = get_page_table(ptr_page_directory, pagePtr, &ptr_page_table);
			if(ret != TABLE_IN_MEMORY) return NULL;
			struct FrameInfo *ptr_frame_info;

			ptr_frame_info = get_frame_info(ptr_page_directory, (uint32)virtual_address, &ptr_page_table);

			uint32 prev_pages = ptr_frame_info->size;
			//num of pages
			int newnofp = ROUNDUP(new_size, PAGE_SIZE)/PAGE_SIZE;

			int numdifference = newnofp - prev_pages;

			uint32 prev_lastpage = (uint32)virtual_address + ((prev_pages-1) * PAGE_SIZE);

			if (isdblock && new_size <= DYN_ALLOC_MAX_BLOCK_SIZE)
			{
					free_block(virtual_address);
					return alloc_block_FF(new_size);

			}

			if (isdblock && new_size > DYN_ALLOC_MAX_BLOCK_SIZE)
			{
					free_block(virtual_address);
					return kmalloc(new_size);
			}


			if (!isdblock && new_size <= DYN_ALLOC_MAX_BLOCK_SIZE)
			{
					kfree(virtual_address);
					return alloc_block_FF(new_size);

			}

			if (numdifference >= 0)
			{
			    uint32 currentpage = prev_pages;
				for (int i=0; i < numdifference-1; i++)
				{
					currentpage += PAGE_SIZE;
					ptr_frame_info = get_frame_info(ptr_page_directory, currentpage, &ptr_page_table);
					if (currentpage >= khardlimit || ptr_frame_info != 0)
					{
					kfree(virtual_address);
					return kmalloc(new_size);
					}
				}

				currentpage = prev_pages;

				for (int i=1; i < numdifference; i++)
				{
					currentpage = prev_pages + (i*PAGE_SIZE);
					ptr_frame_info = get_frame_info(ptr_page_directory, currentpage, &ptr_page_table);


					int fret = allocate_frame(&ptr_frame_info);
					if(fret == 0)
					{
						int mret = map_frame(ptr_page_directory, ptr_frame_info, pagePtr, PERM_WRITEABLE);

						if(mret != 0)
						{
							panic("no maaping");
						}

							ptr_frame_info->vm = pagePtr;

					}
				}
			}

			else
			{

					uint32 currentpage = prev_pages;

					for (int i = 0; i < (-numdifference); i++) {
						ptr_frame_info = get_frame_info(ptr_page_directory, currentpage, &ptr_page_table);
						unmap_frame(ptr_page_directory, currentpage);
						currentpage = currentpage - PAGE_SIZE;

					}

				}

				ptr_frame_info = get_frame_info(ptr_page_directory, (uint32)virtual_address, &ptr_page_table);
				ptr_frame_info->size = newnofp;

				return virtual_address;
		//panic("krealloc() is not implemented yet...!!");
	//}
}
