/*
 * dynamic_allocator.c
 *
 *  Created on: Sep 21, 2023
 *      Author: HP
 */
#include <inc/assert.h>
#include <inc/string.h>
#include "../inc/dynamic_allocator.h"


//==================================================================================//
//============================== GIVEN FUNCTIONS ===================================//
//==================================================================================//

//=====================================================
// 1) GET BLOCK SIZE (including size of its meta data):
//=====================================================
__inline__ uint32 get_block_size(void* va)
{
	uint32 *curBlkMetaData = ((uint32 *)va - 1) ;
	return (*curBlkMetaData) & ~(0x1);
}

//===========================
// 2) GET BLOCK STATUS:
//===========================
__inline__ int8 is_free_block(void* va)
{
	uint32 *curBlkMetaData = ((uint32 *)va - 1) ;
	return (~(*curBlkMetaData) & 0x1) ;
}

//===========================
// 3) ALLOCATE BLOCK:
//===========================

void *alloc_block(uint32 size, int ALLOC_STRATEGY)
{
	void *va = NULL;
	switch (ALLOC_STRATEGY)
	{
	case DA_FF:
		va = alloc_block_FF(size);
		break;
	case DA_NF:
		va = alloc_block_NF(size);
		break;
	case DA_BF:
		va = alloc_block_BF(size);
		break;
	case DA_WF:
		va = alloc_block_WF(size);
		break;
	default:
		cprintf("Invalid allocation strategy\n");
		break;
	}
	return va;
}

//===========================
// 4) PRINT BLOCKS LIST:
//===========================

void print_blocks_list(struct MemBlock_LIST list)
{
	cprintf("=========================================\n");
	struct BlockElement* blk ;
	cprintf("\nDynAlloc Blocks List:\n");
	LIST_FOREACH(blk, &list)
	{
		cprintf("(size: %d, isFree: %d)\n", get_block_size(blk), is_free_block(blk)) ;
	}
	cprintf("=========================================\n");

}
//
////********************************************************************************//
////********************************************************************************//

//==================================================================================//
//============================ REQUIRED FUNCTIONS ==================================//
//==================================================================================//

bool is_initialized = 0;
//==================================
// [1] INITIALIZE DYNAMIC ALLOCATOR:
//==================================
void initialize_dynamic_allocator(uint32 daStart, uint32 initSizeOfAllocatedSpace)
{

		//==================================================================================
		//DON'T CHANGE THESE LINES==========================================================
		//==================================================================================
		{
			if (initSizeOfAllocatedSpace % 2 != 0) initSizeOfAllocatedSpace++; //ensure it's multiple of 2
			if (initSizeOfAllocatedSpace == 0)
				return ;
			is_initialized = 1;
		}
		//==================================================================================
		//==================================================================================

		//TODO: [PROJECT'24.MS1 - #04] [3] DYNAMIC ALLOCATOR - initialize_dynamic_allocator
		//COMMENT THE FOLLOWING LINE BEFORE START CODING
		// (uint32)LIST_INIT(deStart);
		//(uint32)LIST_INIT(head)=daStart;
	 //(uint32)LIST_SIZE(&freeBlocksList);
	 //  print_blocks_list(freeBlocksList) ;//	(uint32)LIST_FIRST(&freeBlocksList)=daStart;
	 //print_block_list(freeBlocksList);
		uint32* dbeg=(uint32*)daStart ;
		uint32* dend=(uint32*)(daStart+initSizeOfAllocatedSpace-sizeof(int));
		*dbeg=1;
		*dend=1;
		uint32* Header = (uint32*) (daStart + sizeof(int));
	    uint32* Footer = (uint32*) (daStart + initSizeOfAllocatedSpace -2*sizeof(int));
		*Header =initSizeOfAllocatedSpace - 2 * sizeof(int);
		*Footer =initSizeOfAllocatedSpace - 2 * sizeof(int) ;

		struct BlockElement *FreeBlock = (struct BlockElement * )( daStart + 2*sizeof(int));
		FreeBlock->prev_next_info.le_next=NULL;
		FreeBlock->prev_next_info.le_prev=NULL;
		LIST_INIT(&freeBlocksList) ;
		LIST_INSERT_HEAD(&freeBlocksList,FreeBlock);
	    //panic("initialize_dynamic_allocator is not implemented yet");
	//set_block_data((struct BlockElement *)( daStart + 2*sizeof(int)), 65,1);
	//print_blocks_list(freeBlocksList);

}
//==================================
// [2] SET BLOCK HEADER & FOOTER:
//==================================
void set_block_data(void* va, uint32 totalSize, bool isAllocated)
{

		//struct BlockElement *FreeBlock = (struct BlockElement * )( va );
		uint32 val= (uint32)totalSize ;
		if(isAllocated){
			val|=1;
		}

		if(totalSize%2!=0){
			val++	;
			}

		uint32* Header = (uint32*) (va -sizeof(int) );
		uint32* Footer = (uint32*) (va+totalSize-(2*sizeof(int)));
			*Header =(uint32)val ;
			*Footer =(uint32)val  ;

		//print_blocks_list(&freeBlocksList) ;


		//TODO: [PROJECT'24.MS1 - #05] [3] DYNAMIC ALLOCATOR - set_block_data
		//COMMENT THE FOLLOWING LINE BEFORE START CODING
		//panic("set_block_data is not implemented yet");
		//Your Code is Here...

}


//=========================================
// [3] ALLOCATE BLOCK BY FIRST FIT:
//=========================================

void *alloc_block_FF(uint32 size)
{
	//==================================================================================
	//DON'T CHANGE THESE LINES==========================================================
	//==================================================================================
	{
		if (size % 2 != 0) size++;	//ensure that the size is even (to use LSB as allocation flag)
		if (size < DYN_ALLOC_MIN_BLOCK_SIZE)
			size = DYN_ALLOC_MIN_BLOCK_SIZE ;
		if (!is_initialized)
		{
			uint32 required_size = size + 2*sizeof(int) /*header & footer*/ + 2*sizeof(int) /*da begin & end*/ ;
			uint32 da_start = (uint32)sbrk(ROUNDUP(required_size, PAGE_SIZE)/PAGE_SIZE);
			uint32 da_break = (uint32)sbrk(0);
			initialize_dynamic_allocator(da_start, da_break - da_start);
		}
	}
	//==================================================================================
	//==================================================================================

	//TODO: [PROJECT'24.MS1 - #06] [3] DYNAMIC ALLOCATOR - alloc_block_FF
	//COMMENT THE FOLLOWING LINE BEFORE START CODING
	//panic("alloc_block_FF is not implemented yet");
	//Your Code is Here...
	uint32 compsize =size+2*sizeof(int);
	struct BlockElement *moblock;
	struct BlockElement *newblock;

    LIST_FOREACH(moblock,&freeBlocksList){
    	uint32 sizeofblock=get_block_size(moblock);
    	if (size==0)return NULL;
    	if(compsize<=sizeofblock)
    	{


    		if (compsize==sizeofblock)
    		{

    			 	 	 	 set_block_data(moblock, compsize, 1);
    			                LIST_REMOVE(&freeBlocksList, moblock);

    			                return (void*)(moblock );

    		}


    			uint32 diff =sizeofblock-compsize;
    			//split
    			//struct BlockElement *
    			if (diff>=4*sizeof(int)){
				newblock = (struct BlockElement*)((char*)moblock + compsize);
    			uint32 compblock =get_block_size(moblock);
    			set_block_data(moblock,compsize,1);
    			set_block_data(newblock,diff,0);
    			LIST_INSERT_AFTER(&freeBlocksList,moblock,newblock);
    			 LIST_REMOVE(&freeBlocksList,moblock);

    			return (void*)(moblock);
    			}
    			else {
    				set_block_data(moblock,sizeofblock,1);
    				LIST_REMOVE(&freeBlocksList,moblock);
    				return(void*)(moblock);


    			}


    	{
    			//allocate

    			 set_block_data(moblock,sizeofblock,1);
    			 LIST_REMOVE(&freeBlocksList,moblock);

    			return (void*)(moblock);

    		}
    	}
    }








   void* kill = (struct BlockElement*)sbrk(compsize);
           if (kill == (void*)-1) {

               return NULL;  // sbrk failed
               }

           struct BlockElement* new_free_block = (struct BlockElement*)kill;
           set_block_data(new_free_block, compsize, 1);

           return (void*)(new_free_block) ;


}
//=========================================
// [4] ALLOCATE BLOCK BY BEST FIT:
//=========================================
void *alloc_block_BF(uint32 size)
{
	//TODO: [PROJECT'24.MS1 - BONUS] [3] DYNAMIC ALLOCATOR - alloc_block_BF
	//COMMENT THE FOLLOWING LINE BEFORE START CODING
	//panic("alloc_block_BF is not implemented yet");
	//Your Code is Here...

	    //==================================================================================
	    // DON'T CHANGE THESE LINES ========================================================
	    //==================================================================================
	    {
	        if (size % 2 != 0) size++;
	        if (size < DYN_ALLOC_MIN_BLOCK_SIZE)
	            size = DYN_ALLOC_MIN_BLOCK_SIZE;
	        if (!is_initialized) {
	            uint32 required_size = size + 2 * sizeof(int) + 2 * sizeof(int);
	            uint32 da_start = (uint32)sbrk(ROUNDUP(required_size, PAGE_SIZE) / PAGE_SIZE);
	            uint32 da_break = (uint32)sbrk(0);
	            initialize_dynamic_allocator(da_start, da_break - da_start);
	        }
	    }
	    //==================================================================================
	    //==================================================================================

	    uint32 compsize = size + 2 * sizeof(int);
	    struct BlockElement* best_fit_block = NULL;
	    struct BlockElement* current_block;
	    uint32 min_diff = 1e9;


	    LIST_FOREACH(current_block, &freeBlocksList) {
	        uint32 block_size = get_block_size(current_block);
	        if (block_size >= compsize) {
	            uint32 diff = block_size - compsize;
	            if (diff < min_diff) {
	                min_diff = diff;
	                best_fit_block = current_block;
	            }
	        }
	    }


	    if (best_fit_block == NULL) {
	        void* new_mem = (struct BlockElement*)sbrk(compsize);
	        if (new_mem == (void*)-1) {
	            return NULL;
	        }
	        struct BlockElement* new_block = (struct BlockElement*)new_mem;
	        set_block_data(new_block, compsize, 1);
	        return (void*)new_block;
	    }


	    if (min_diff == 0) {
	        set_block_data(best_fit_block, compsize, 1);
	        LIST_REMOVE(&freeBlocksList, best_fit_block);
	        return (void*)best_fit_block;
	    }


	    if (min_diff >= 4 * sizeof(int)) {
	        struct BlockElement* remaining_block = (struct BlockElement*)((char*)best_fit_block + compsize);
	        set_block_data(best_fit_block, compsize, 1);
	        set_block_data(remaining_block, min_diff, 0);
	        LIST_INSERT_AFTER(&freeBlocksList, best_fit_block, remaining_block);
	    } else {

	        set_block_data(best_fit_block, get_block_size(best_fit_block), 1);
	    }


	    LIST_REMOVE(&freeBlocksList, best_fit_block);
	    return (void*)best_fit_block;
	}



//===================================================
// [5] FREE BLOCK WITH COALESCING:
//===================================================
void free_block(void *va)
{
	struct BlockElement *mos;


	//TODO: [PROJECT'24.MS1 - #07] [3] DYNAMIC ALLOCATOR - free_block
	//COMMENT THE FOLLOWING LINE BEFORE START CODING
	//panic("free_block is not implemented yet");
	//Your Code is Here...
	struct BlockElement* block;
	if (va!=NULL){
	uint32 size =get_block_size(va);
	set_block_data(va,size,0);//set free block
	struct BlockElement* va_block=(struct BlockElement*)va;
	struct BlockElement* prev;
	uint32 newsize;
	//cprintf("here before each\n");
	LIST_FOREACH(block,&freeBlocksList){
		if (va_block<block){
			set_block_data(va_block,size,0);
			LIST_INSERT_BEFORE(&freeBlocksList,block,va_block);
			long diff_next = (char*)(va_block->prev_next_info.le_next) - (char*)((char*)va_block+size);
			long diff_prev = (char*)((char*)va_block->prev_next_info.le_prev+get_block_size(va_block->prev_next_info.le_prev)) - (char*)(va_block);
			//cprintf("here\n");
			if (diff_next<(4*sizeof(int))&&(diff_prev<(4*sizeof(int)))){
				//both merge
				struct BlockElement *mos;



				newsize=get_block_size(va_block->prev_next_info.le_next);
				newsize+=get_block_size(va_block->prev_next_info.le_prev);
				newsize+=size;

				set_block_data(va_block->prev_next_info.le_prev,newsize,0);

				LIST_REMOVE(&freeBlocksList,block);
				LIST_REMOVE(&freeBlocksList,va_block);
				//cprintf("both");


				return;

			}
			else if (diff_next<(4*sizeof(int))){
				//just next merge
				newsize=get_block_size(va_block->prev_next_info.le_next);
				newsize+=size;
				set_block_data(va_block,newsize,0);
				//LIST_INSERT_BEFORE(&freeBlocksList,va_block->prev_next_info.le_next,va_block);
				LIST_REMOVE(&freeBlocksList,block);
				//cprintf("just next/n");
				return;

			}
			else if(diff_prev<(4*sizeof(int))){
				//just prev
				prev=va_block->prev_next_info.le_prev;

				newsize=get_block_size(va_block->prev_next_info.le_prev);
				newsize+=size;
			//	cprintf("the new size %d-----size%d\n",newsize ,size);
				//cprintf("herrrrrrrrrrrrrrrr---------------------->%x\n",alloc_block_FF(get_block_size(prev)));
				//cprintf("the size before edit%d\n",get_block_size(prev));
				set_block_data(prev,newsize,0);
				//cprintf("the size AFTERedit%d\n",get_block_size(prev));

				LIST_REMOVE(&freeBlocksList,va_block);
				//cprintf("size AFTER REmove %d",LIST_SIZE(&freeBlocksList));
				//cprintf("justprev\n");

				return;
			}
			else {

				return;

			}
		}
	}

	set_block_data(va_block,size,0);
	//cprintf("size before insert\n %d",LIST_SIZE(&freeBlocksList));
	LIST_INSERT_TAIL(&freeBlocksList,va_block);
	//cprintf((void*)(va_block-va_block->prev_next_info.le_prev));
	prev=va_block->prev_next_info.le_prev;
	//cprintf("size AFTER insert\n %d",LIST_SIZE(&freeBlocksList));
	//cprintf("Address of va_block: %ld\n", (void*)get_block_size(prev));
//	cprintf("Address of prev: %p\n", (void*)prev);
//	cprintf("Address of prev+size: %p\n", (void*)((char*)prev+get_block_size(prev)));
	long diff = (char*)(va_block) - (char*)((char*)prev+get_block_size(prev));
	//cprintf("sub of va_block: %ld\n", (diff));
	if (diff<4*sizeof(int)){
		//cprintf("anan heene\n");
		//prev=va_block->prev_next_info.le_prev;
		newsize=get_block_size(prev);
		newsize+=size;
		LIST_REMOVE(&freeBlocksList,va_block);
		//cprintf("size AFTER REmove \n%d",LIST_SIZE(&freeBlocksList));
		set_block_data(prev,newsize,0);
		//LIST_INSERT_TAIL(&freeBlocksList,prev);
		//cprintf("size AFTER insert\n %d",LIST_SIZE(&freeBlocksList));

	}
}}
//=========================================
// [6] REALLOCATE BLOCK BY FIRST FIT:
//=========================================
void *realloc_block_FF(void* va, uint32 new_size)
{
	//TODO: [PROJECT'24.MS1 - #08] [3] DYNAMIC ALLOCATOR - realloc_block_FF
	//COMMENT THE FOLLOWING LINE BEFORE START CODING
	//panic("realloc_block_FF is not implemented yet");
	//Your Code is Here...
	// cprintf("(size: %d, isFree: %d)\n", next, va) ;
	    if (va == NULL) {
	    	//cprintf("(size: %d, NULxxxxxxxLLLL: %d)\n", next, va) ;
	        return (new_size == 0) ? NULL : alloc_block_FF(new_size);
	        //cprintf("(size: %d, SUIIIIIIIIL: %d)\n", next, va) ;
	        //	return NULL ;
	    }


	    if (new_size == 0) {
	        free_block(va);
	        return NULL;
	    }



	    struct BlockElement* block = (struct BlockElement*)va;
	    uint32 curr = get_block_size(block) - 2 * sizeof(int);
	    if (new_size==curr)return va;
	    struct BlockElement* next = (struct BlockElement*)((void*)block + get_block_size(block));
	    //decrase the size-----done
	    if (new_size <= curr) {
	        uint32 remainsize = curr - new_size ;


	        if (remainsize >= 4 * sizeof(int)) {
	            struct BlockElement* new_free_block = (struct BlockElement*)((char*)block+new_size+2*sizeof(int));
	            set_block_data(new_free_block, remainsize, 0);
	            set_block_data(block, new_size + 2 * sizeof(int), 1);

	          //  print_blocks_list(freeBlocksList);
	            free_block(new_free_block);
	           // print_blocks_list(freeBlocksList);





	        }

	       else if (is_free_block(next)){
	        	 struct BlockElement* new_free_block = (struct BlockElement*)((char*)block+new_size+2*sizeof(int));
	        	set_block_data(new_free_block,remainsize,0);
	        	free_block(new_free_block);
	        	set_block_data(block,new_size+2*sizeof(int),1);

	        }

	        else{
	        	 set_block_data(block, curr + 2 * sizeof(int), 1);
	        	        return (void*)block;

	        }
	        return (void*)block;
	    }

	    else if(new_size > curr)
	    {






	    if (is_free_block(next) && (get_block_size(next) + curr >= new_size)) {

	        uint32 newsizeeeee = get_block_size(next) + curr;
	        uint32 remaining_size = newsizeeeee - new_size;

	        if (remaining_size >= 4 * sizeof(int)) {

	            struct BlockElement* new_free_block = (struct BlockElement*)((void*)block + new_size + 2 * sizeof(int));
	            set_block_data(new_free_block, remaining_size, 0);
	            free_block(new_free_block);

	        }

	        LIST_REMOVE(&freeBlocksList, next);
	        set_block_data(block, new_size + 2 * sizeof(int), 1);
	        return (void*)block;
	    }
	    }


	    void* new_block = alloc_block_FF(new_size);
	    if (new_block != NULL) {

	        free_block(va);
	        return new_block;
	    }


	    return (void*)block;
}

/*********************************************************************************************/
/*********************************************************************************************/
/*********************************************************************************************/
//=========================================
// [7] ALLOCATE BLOCK BY WORST FIT:
//=========================================
void *alloc_block_WF(uint32 size)
{
	panic("alloc_block_WF is not implemented yet");
	return NULL;
}

//=========================================
// [8] ALLOCATE BLOCK BY NEXT FIT:
//=========================================
void *alloc_block_NF(uint32 size)
{
	panic("alloc_block_NF is not implemented yet");
	return NULL;
}
