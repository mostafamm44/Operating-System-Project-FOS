
obj/user/tst_free_2:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	mov $0, %eax
  800020:	b8 00 00 00 00       	mov    $0x0,%eax
	cmpl $USTACKTOP, %esp
  800025:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  80002b:	75 04                	jne    800031 <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  80002d:	6a 00                	push   $0x0
	pushl $0
  80002f:	6a 00                	push   $0x0

00800031 <args_exist>:

args_exist:
	call libmain
  800031:	e8 1c 0f 00 00       	call   800f52 <libmain>
1:      jmp 1b
  800036:	eb fe                	jmp    800036 <args_exist+0x5>

00800038 <check_block>:
#define USER_TST_UTILITIES_H_
#include <inc/types.h>
#include <inc/stdio.h>

int check_block(void* va, void* expectedVA, uint32 expectedSize, uint8 expectedFlag)
{
  800038:	55                   	push   %ebp
  800039:	89 e5                	mov    %esp,%ebp
  80003b:	83 ec 28             	sub    $0x28,%esp
  80003e:	8b 45 14             	mov    0x14(%ebp),%eax
  800041:	88 45 e4             	mov    %al,-0x1c(%ebp)
	//Check returned va
	if(va != expectedVA)
  800044:	8b 45 08             	mov    0x8(%ebp),%eax
  800047:	3b 45 0c             	cmp    0xc(%ebp),%eax
  80004a:	74 1d                	je     800069 <check_block+0x31>
	{
		cprintf("wrong block address. Expected %x, Actual %x\n", expectedVA, va);
  80004c:	83 ec 04             	sub    $0x4,%esp
  80004f:	ff 75 08             	pushl  0x8(%ebp)
  800052:	ff 75 0c             	pushl  0xc(%ebp)
  800055:	68 20 3f 80 00       	push   $0x803f20
  80005a:	e8 e7 12 00 00       	call   801346 <cprintf>
  80005f:	83 c4 10             	add    $0x10,%esp
		return 0;
  800062:	b8 00 00 00 00       	mov    $0x0,%eax
  800067:	eb 55                	jmp    8000be <check_block+0x86>
	}
	//Check header & footer
	uint32 header = *((uint32*)va-1);
  800069:	8b 45 08             	mov    0x8(%ebp),%eax
  80006c:	8b 40 fc             	mov    -0x4(%eax),%eax
  80006f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32 footer = *((uint32*)(va + expectedSize - 8));
  800072:	8b 45 10             	mov    0x10(%ebp),%eax
  800075:	8d 50 f8             	lea    -0x8(%eax),%edx
  800078:	8b 45 08             	mov    0x8(%ebp),%eax
  80007b:	01 d0                	add    %edx,%eax
  80007d:	8b 00                	mov    (%eax),%eax
  80007f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	uint32 expectedData = expectedSize | expectedFlag ;
  800082:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
  800086:	0b 45 10             	or     0x10(%ebp),%eax
  800089:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(header != expectedData || footer != expectedData)
  80008c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80008f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800092:	75 08                	jne    80009c <check_block+0x64>
  800094:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800097:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  80009a:	74 1d                	je     8000b9 <check_block+0x81>
	{
		cprintf("wrong header/footer data. Expected %d, Actual H:%d F:%d\n", expectedData, header, footer);
  80009c:	ff 75 f0             	pushl  -0x10(%ebp)
  80009f:	ff 75 f4             	pushl  -0xc(%ebp)
  8000a2:	ff 75 ec             	pushl  -0x14(%ebp)
  8000a5:	68 50 3f 80 00       	push   $0x803f50
  8000aa:	e8 97 12 00 00       	call   801346 <cprintf>
  8000af:	83 c4 10             	add    $0x10,%esp
		return 0;
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	eb 05                	jmp    8000be <check_block+0x86>
	}
	return 1;
  8000b9:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <_main>:
short* startVAs[numOfAllocs*allocCntPerSize+1] ;
short* midVAs[numOfAllocs*allocCntPerSize+1] ;
short* endVAs[numOfAllocs*allocCntPerSize+1] ;

void _main(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
  8000c6:	81 ec dc 00 00 00    	sub    $0xdc,%esp
	 * WE COMPARE THE DIFF IN FREE FRAMES BY "AT LEAST" RULE
	 * INSTEAD OF "EQUAL" RULE SINCE IT'S POSSIBLE THAT SOME
	 * PAGES ARE ALLOCATED IN KERNEL DYNAMIC ALLOCATOR sbrk()
	 * (e.g. DURING THE DYNAMIC CREATION OF WS ELEMENT in FH).
	 *********************************************************/
	sys_set_uheap_strategy(UHP_PLACE_FIRSTFIT);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	6a 01                	push   $0x1
  8000d1:	e8 52 26 00 00       	call   802728 <sys_set_uheap_strategy>
  8000d6:	83 c4 10             	add    $0x10,%esp

	//cprintf("1\n");
	//Initial test to ensure it works on "PLACEMENT" not "REPLACEMENT"
#if USE_KHEAP
	{
		if (LIST_SIZE(&(myEnv->page_WS_list)) >= myEnv->page_WS_max_size)
  8000d9:	a1 20 60 80 00       	mov    0x806020,%eax
  8000de:	8b 90 94 00 00 00    	mov    0x94(%eax),%edx
  8000e4:	a1 20 60 80 00       	mov    0x806020,%eax
  8000e9:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  8000ef:	39 c2                	cmp    %eax,%edx
  8000f1:	72 14                	jb     800107 <_main+0x47>
			panic("Please increase the WS size");
  8000f3:	83 ec 04             	sub    $0x4,%esp
  8000f6:	68 89 3f 80 00       	push   $0x803f89
  8000fb:	6a 25                	push   $0x25
  8000fd:	68 a5 3f 80 00       	push   $0x803fa5
  800102:	e8 82 0f 00 00       	call   801089 <_panic>
	panic("make sure to enable the kernel heap: USE_KHEAP=1");
#endif

	/*=================================================*/

	int eval = 0;
  800107:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	bool is_correct = 1;
  80010e:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
	int targetAllocatedSpace = 3*Mega;
  800115:	c7 45 b8 00 00 30 00 	movl   $0x300000,-0x48(%ebp)

	void * va ;
	int idx = 0;
  80011c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	bool chk;
	int usedDiskPages = sys_pf_calculate_allocated_pages() ;
  800123:	e8 4d 22 00 00       	call   802375 <sys_pf_calculate_allocated_pages>
  800128:	89 45 b4             	mov    %eax,-0x4c(%ebp)
	int freeFrames = sys_calculate_free_frames() ;
  80012b:	e8 fa 21 00 00       	call   80232a <sys_calculate_free_frames>
  800130:	89 45 b0             	mov    %eax,-0x50(%ebp)
	uint32 actualSize, block_size, blockIndex;
	int8 block_status;
	void* expectedVA;
	uint32 expectedSize, curTotalSize,roundedTotalSize ;

	void* curVA = (void*) USER_HEAP_START + sizeof(int) /*BEG Block*/ ;
  800133:	c7 45 d0 04 00 00 80 	movl   $0x80000004,-0x30(%ebp)
	//====================================================================//
	/*INITIAL ALLOC Scenario 1: Try to allocate set of blocks with different sizes*/
	cprintf("PREREQUISITE#1: Try to allocate set of blocks with different sizes [all should fit]\n\n") ;
  80013a:	83 ec 0c             	sub    $0xc,%esp
  80013d:	68 b8 3f 80 00       	push   $0x803fb8
  800142:	e8 ff 11 00 00       	call   801346 <cprintf>
  800147:	83 c4 10             	add    $0x10,%esp
	{
		is_correct = 1;
  80014a:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		curTotalSize = sizeof(int);
  800151:	c7 45 d4 04 00 00 00 	movl   $0x4,-0x2c(%ebp)
		for (int i = 0; i < numOfAllocs; ++i)
  800158:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80015f:	e9 6f 01 00 00       	jmp    8002d3 <_main+0x213>
		{
			for (int j = 0; j < allocCntPerSize; ++j)
  800164:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80016b:	e9 53 01 00 00       	jmp    8002c3 <_main+0x203>
			{
				actualSize = allocSizes[i] - sizeOfMetaData;
  800170:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800173:	8b 04 85 00 60 80 00 	mov    0x806000(,%eax,4),%eax
  80017a:	83 e8 08             	sub    $0x8,%eax
  80017d:	89 45 ac             	mov    %eax,-0x54(%ebp)
				va = startVAs[idx] = malloc(actualSize);
  800180:	83 ec 0c             	sub    $0xc,%esp
  800183:	ff 75 ac             	pushl  -0x54(%ebp)
  800186:	e8 6b 1f 00 00       	call   8020f6 <malloc>
  80018b:	83 c4 10             	add    $0x10,%esp
  80018e:	89 c2                	mov    %eax,%edx
  800190:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800193:	89 14 85 60 60 80 00 	mov    %edx,0x806060(,%eax,4)
  80019a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80019d:	8b 04 85 60 60 80 00 	mov    0x806060(,%eax,4),%eax
  8001a4:	89 45 a8             	mov    %eax,-0x58(%ebp)
				midVAs[idx] = va + actualSize/2 ;
  8001a7:	8b 45 ac             	mov    -0x54(%ebp),%eax
  8001aa:	d1 e8                	shr    %eax
  8001ac:	89 c2                	mov    %eax,%edx
  8001ae:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8001b1:	01 c2                	add    %eax,%edx
  8001b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001b6:	89 14 85 60 8c 80 00 	mov    %edx,0x808c60(,%eax,4)
				endVAs[idx] = va + actualSize - sizeof(short);
  8001bd:	8b 45 ac             	mov    -0x54(%ebp),%eax
  8001c0:	8d 50 fe             	lea    -0x2(%eax),%edx
  8001c3:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8001c6:	01 c2                	add    %eax,%edx
  8001c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001cb:	89 14 85 60 76 80 00 	mov    %edx,0x807660(,%eax,4)
				//Check returned va
				expectedVA = (curVA + sizeOfMetaData/2);
  8001d2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8001d5:	83 c0 04             	add    $0x4,%eax
  8001d8:	89 45 a4             	mov    %eax,-0x5c(%ebp)
				expectedSize = allocSizes[i];
  8001db:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8001de:	8b 04 85 00 60 80 00 	mov    0x806000(,%eax,4),%eax
  8001e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
				curTotalSize += allocSizes[i] ;
  8001e8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8001eb:	8b 04 85 00 60 80 00 	mov    0x806000(,%eax,4),%eax
  8001f2:	01 45 d4             	add    %eax,-0x2c(%ebp)
				//============================================================
				//Check if the remaining area doesn't fit the DynAllocBlock,
				//so update the curVA & curTotalSize to skip this area
				roundedTotalSize = ROUNDUP(curTotalSize, PAGE_SIZE);
  8001f5:	c7 45 a0 00 10 00 00 	movl   $0x1000,-0x60(%ebp)
  8001fc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8001ff:	8b 45 a0             	mov    -0x60(%ebp),%eax
  800202:	01 d0                	add    %edx,%eax
  800204:	48                   	dec    %eax
  800205:	89 45 9c             	mov    %eax,-0x64(%ebp)
  800208:	8b 45 9c             	mov    -0x64(%ebp),%eax
  80020b:	ba 00 00 00 00       	mov    $0x0,%edx
  800210:	f7 75 a0             	divl   -0x60(%ebp)
  800213:	8b 45 9c             	mov    -0x64(%ebp),%eax
  800216:	29 d0                	sub    %edx,%eax
  800218:	89 45 98             	mov    %eax,-0x68(%ebp)
				int diff = (roundedTotalSize - curTotalSize) ;
  80021b:	8b 45 98             	mov    -0x68(%ebp),%eax
  80021e:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  800221:	89 45 94             	mov    %eax,-0x6c(%ebp)
				if (diff > 0 && diff < (DYN_ALLOC_MIN_BLOCK_SIZE + sizeOfMetaData))
  800224:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
  800228:	7e 48                	jle    800272 <_main+0x1b2>
  80022a:	83 7d 94 0f          	cmpl   $0xf,-0x6c(%ebp)
  80022e:	7f 42                	jg     800272 <_main+0x1b2>
				{
//					cprintf("%~\n FRAGMENTATION: curVA = %x diff = %d\n", curVA, diff);
//					cprintf("%~\n Allocated block @ %x with size = %d\n", va, get_block_size(va));

					curVA = ROUNDUP(curVA, PAGE_SIZE)- sizeof(int) /*next alloc will start at END Block (after sbrk)*/;
  800230:	c7 45 90 00 10 00 00 	movl   $0x1000,-0x70(%ebp)
  800237:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80023a:	8b 45 90             	mov    -0x70(%ebp),%eax
  80023d:	01 d0                	add    %edx,%eax
  80023f:	48                   	dec    %eax
  800240:	89 45 8c             	mov    %eax,-0x74(%ebp)
  800243:	8b 45 8c             	mov    -0x74(%ebp),%eax
  800246:	ba 00 00 00 00       	mov    $0x0,%edx
  80024b:	f7 75 90             	divl   -0x70(%ebp)
  80024e:	8b 45 8c             	mov    -0x74(%ebp),%eax
  800251:	29 d0                	sub    %edx,%eax
  800253:	83 e8 04             	sub    $0x4,%eax
  800256:	89 45 d0             	mov    %eax,-0x30(%ebp)
					curTotalSize = roundedTotalSize - sizeof(int) /*exclude END Block*/;
  800259:	8b 45 98             	mov    -0x68(%ebp),%eax
  80025c:	83 e8 04             	sub    $0x4,%eax
  80025f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
					expectedSize += diff - sizeof(int) /*exclude END Block*/;
  800262:	8b 55 94             	mov    -0x6c(%ebp),%edx
  800265:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800268:	01 d0                	add    %edx,%eax
  80026a:	83 e8 04             	sub    $0x4,%eax
  80026d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800270:	eb 0d                	jmp    80027f <_main+0x1bf>
				}
				else
				{
					curVA += allocSizes[i] ;
  800272:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800275:	8b 04 85 00 60 80 00 	mov    0x806000(,%eax,4),%eax
  80027c:	01 45 d0             	add    %eax,-0x30(%ebp)
				}
				//============================================================
				if (is_correct)
  80027f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800283:	74 38                	je     8002bd <_main+0x1fd>
				{
					if (check_block(va, expectedVA, expectedSize, 1) == 0)
  800285:	6a 01                	push   $0x1
  800287:	ff 75 d8             	pushl  -0x28(%ebp)
  80028a:	ff 75 a4             	pushl  -0x5c(%ebp)
  80028d:	ff 75 a8             	pushl  -0x58(%ebp)
  800290:	e8 a3 fd ff ff       	call   800038 <check_block>
  800295:	83 c4 10             	add    $0x10,%esp
  800298:	85 c0                	test   %eax,%eax
  80029a:	75 21                	jne    8002bd <_main+0x1fd>
					{
						if (is_correct)
  80029c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8002a0:	74 1b                	je     8002bd <_main+0x1fd>
						{
							is_correct = 0;
  8002a2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
							panic("alloc_block_xx #PRQ.%d: WRONG ALLOC\n", idx);
  8002a9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ac:	68 10 40 80 00       	push   $0x804010
  8002b1:	6a 68                	push   $0x68
  8002b3:	68 a5 3f 80 00       	push   $0x803fa5
  8002b8:	e8 cc 0d 00 00       	call   801089 <_panic>
						}
					}
				}
				idx++;
  8002bd:	ff 45 dc             	incl   -0x24(%ebp)
	{
		is_correct = 1;
		curTotalSize = sizeof(int);
		for (int i = 0; i < numOfAllocs; ++i)
		{
			for (int j = 0; j < allocCntPerSize; ++j)
  8002c0:	ff 45 c8             	incl   -0x38(%ebp)
  8002c3:	81 7d c8 c7 00 00 00 	cmpl   $0xc7,-0x38(%ebp)
  8002ca:	0f 8e a0 fe ff ff    	jle    800170 <_main+0xb0>
	/*INITIAL ALLOC Scenario 1: Try to allocate set of blocks with different sizes*/
	cprintf("PREREQUISITE#1: Try to allocate set of blocks with different sizes [all should fit]\n\n") ;
	{
		is_correct = 1;
		curTotalSize = sizeof(int);
		for (int i = 0; i < numOfAllocs; ++i)
  8002d0:	ff 45 cc             	incl   -0x34(%ebp)
  8002d3:	83 7d cc 06          	cmpl   $0x6,-0x34(%ebp)
  8002d7:	0f 8e 87 fe ff ff    	jle    800164 <_main+0xa4>
			//if (is_correct == 0)
			//break;
		}
	}
	/* Fill the remaining space at the end of the DA*/
	roundedTotalSize = ROUNDUP(curTotalSize, PAGE_SIZE);
  8002dd:	c7 45 88 00 10 00 00 	movl   $0x1000,-0x78(%ebp)
  8002e4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8002e7:	8b 45 88             	mov    -0x78(%ebp),%eax
  8002ea:	01 d0                	add    %edx,%eax
  8002ec:	48                   	dec    %eax
  8002ed:	89 45 84             	mov    %eax,-0x7c(%ebp)
  8002f0:	8b 45 84             	mov    -0x7c(%ebp),%eax
  8002f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f8:	f7 75 88             	divl   -0x78(%ebp)
  8002fb:	8b 45 84             	mov    -0x7c(%ebp),%eax
  8002fe:	29 d0                	sub    %edx,%eax
  800300:	89 45 98             	mov    %eax,-0x68(%ebp)
	uint32 remainSize = (roundedTotalSize - curTotalSize) - sizeof(int) /*END block*/;
  800303:	8b 45 98             	mov    -0x68(%ebp),%eax
  800306:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  800309:	83 e8 04             	sub    $0x4,%eax
  80030c:	89 45 80             	mov    %eax,-0x80(%ebp)
	if (remainSize >= (DYN_ALLOC_MIN_BLOCK_SIZE + sizeOfMetaData))
  80030f:	83 7d 80 0f          	cmpl   $0xf,-0x80(%ebp)
  800313:	76 7b                	jbe    800390 <_main+0x2d0>
	{
		cprintf("Filling the remaining size of %d\n\n", remainSize);
  800315:	83 ec 08             	sub    $0x8,%esp
  800318:	ff 75 80             	pushl  -0x80(%ebp)
  80031b:	68 38 40 80 00       	push   $0x804038
  800320:	e8 21 10 00 00       	call   801346 <cprintf>
  800325:	83 c4 10             	add    $0x10,%esp
		va = startVAs[idx] = alloc_block(remainSize - sizeOfMetaData, DA_FF);
  800328:	8b 45 80             	mov    -0x80(%ebp),%eax
  80032b:	83 e8 08             	sub    $0x8,%eax
  80032e:	83 ec 08             	sub    $0x8,%esp
  800331:	6a 01                	push   $0x1
  800333:	50                   	push   %eax
  800334:	e8 36 25 00 00       	call   80286f <alloc_block>
  800339:	83 c4 10             	add    $0x10,%esp
  80033c:	89 c2                	mov    %eax,%edx
  80033e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800341:	89 14 85 60 60 80 00 	mov    %edx,0x806060(,%eax,4)
  800348:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80034b:	8b 04 85 60 60 80 00 	mov    0x806060(,%eax,4),%eax
  800352:	89 45 a8             	mov    %eax,-0x58(%ebp)
		//Check returned va
		expectedVA = curVA + sizeOfMetaData/2;
  800355:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800358:	83 c0 04             	add    $0x4,%eax
  80035b:	89 45 a4             	mov    %eax,-0x5c(%ebp)
		if (check_block(va, expectedVA, remainSize, 1) == 0)
  80035e:	6a 01                	push   $0x1
  800360:	ff 75 80             	pushl  -0x80(%ebp)
  800363:	ff 75 a4             	pushl  -0x5c(%ebp)
  800366:	ff 75 a8             	pushl  -0x58(%ebp)
  800369:	e8 ca fc ff ff       	call   800038 <check_block>
  80036e:	83 c4 10             	add    $0x10,%esp
  800371:	85 c0                	test   %eax,%eax
  800373:	75 1b                	jne    800390 <_main+0x2d0>
		{
			is_correct = 0;
  800375:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
			panic("alloc_block_xx #PRQ.oo: WRONG ALLOC\n", idx);
  80037c:	ff 75 dc             	pushl  -0x24(%ebp)
  80037f:	68 5c 40 80 00       	push   $0x80405c
  800384:	6a 7f                	push   $0x7f
  800386:	68 a5 3f 80 00       	push   $0x803fa5
  80038b:	e8 f9 0c 00 00       	call   801089 <_panic>
		}
	}

	freeFrames = sys_calculate_free_frames() ;
  800390:	e8 95 1f 00 00       	call   80232a <sys_calculate_free_frames>
  800395:	89 45 b0             	mov    %eax,-0x50(%ebp)

	//====================================================================//
	/*Free set of blocks with different sizes (first block of each size)*/
	cprintf("1: Free set of blocks with different sizes (first block of each size)\n\n") ;
  800398:	83 ec 0c             	sub    $0xc,%esp
  80039b:	68 84 40 80 00       	push   $0x804084
  8003a0:	e8 a1 0f 00 00       	call   801346 <cprintf>
  8003a5:	83 c4 10             	add    $0x10,%esp
	{
		is_correct = 1;
  8003a8:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		for (int i = 0; i < numOfAllocs; ++i)
  8003af:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
  8003b6:	e9 98 00 00 00       	jmp    800453 <_main+0x393>
		{
			free(startVAs[i*allocCntPerSize]);
  8003bb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8003be:	89 d0                	mov    %edx,%eax
  8003c0:	c1 e0 02             	shl    $0x2,%eax
  8003c3:	01 d0                	add    %edx,%eax
  8003c5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8003cc:	01 d0                	add    %edx,%eax
  8003ce:	c1 e0 03             	shl    $0x3,%eax
  8003d1:	8b 04 85 60 60 80 00 	mov    0x806060(,%eax,4),%eax
  8003d8:	83 ec 0c             	sub    $0xc,%esp
  8003db:	50                   	push   %eax
  8003dc:	e8 3e 1d 00 00       	call   80211f <free>
  8003e1:	83 c4 10             	add    $0x10,%esp
			if (check_block(startVAs[i*allocCntPerSize], startVAs[i*allocCntPerSize], allocSizes[i], 0) == 0)
  8003e4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8003e7:	8b 0c 85 00 60 80 00 	mov    0x806000(,%eax,4),%ecx
  8003ee:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8003f1:	89 d0                	mov    %edx,%eax
  8003f3:	c1 e0 02             	shl    $0x2,%eax
  8003f6:	01 d0                	add    %edx,%eax
  8003f8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8003ff:	01 d0                	add    %edx,%eax
  800401:	c1 e0 03             	shl    $0x3,%eax
  800404:	8b 14 85 60 60 80 00 	mov    0x806060(,%eax,4),%edx
  80040b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80040e:	89 d8                	mov    %ebx,%eax
  800410:	c1 e0 02             	shl    $0x2,%eax
  800413:	01 d8                	add    %ebx,%eax
  800415:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
  80041c:	01 d8                	add    %ebx,%eax
  80041e:	c1 e0 03             	shl    $0x3,%eax
  800421:	8b 04 85 60 60 80 00 	mov    0x806060(,%eax,4),%eax
  800428:	6a 00                	push   $0x0
  80042a:	51                   	push   %ecx
  80042b:	52                   	push   %edx
  80042c:	50                   	push   %eax
  80042d:	e8 06 fc ff ff       	call   800038 <check_block>
  800432:	83 c4 10             	add    $0x10,%esp
  800435:	85 c0                	test   %eax,%eax
  800437:	75 17                	jne    800450 <_main+0x390>
			{
				is_correct = 0;
  800439:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				cprintf("test_free_2 #1.1: WRONG FREE!\n");
  800440:	83 ec 0c             	sub    $0xc,%esp
  800443:	68 cc 40 80 00       	push   $0x8040cc
  800448:	e8 f9 0e 00 00       	call   801346 <cprintf>
  80044d:	83 c4 10             	add    $0x10,%esp
	//====================================================================//
	/*Free set of blocks with different sizes (first block of each size)*/
	cprintf("1: Free set of blocks with different sizes (first block of each size)\n\n") ;
	{
		is_correct = 1;
		for (int i = 0; i < numOfAllocs; ++i)
  800450:	ff 45 c4             	incl   -0x3c(%ebp)
  800453:	83 7d c4 06          	cmpl   $0x6,-0x3c(%ebp)
  800457:	0f 8e 5e ff ff ff    	jle    8003bb <_main+0x2fb>
				cprintf("test_free_2 #1.1: WRONG FREE!\n");
			}
		}

		//Free block before last
		free(startVAs[numOfAllocs*allocCntPerSize - 1]);
  80045d:	a1 3c 76 80 00       	mov    0x80763c,%eax
  800462:	83 ec 0c             	sub    $0xc,%esp
  800465:	50                   	push   %eax
  800466:	e8 b4 1c 00 00       	call   80211f <free>
  80046b:	83 c4 10             	add    $0x10,%esp

		if (check_block(startVAs[numOfAllocs*allocCntPerSize - 1], startVAs[numOfAllocs*allocCntPerSize - 1], allocSizes[numOfAllocs-1], 0) == 0)
  80046e:	8b 0d 18 60 80 00    	mov    0x806018,%ecx
  800474:	8b 15 3c 76 80 00    	mov    0x80763c,%edx
  80047a:	a1 3c 76 80 00       	mov    0x80763c,%eax
  80047f:	6a 00                	push   $0x0
  800481:	51                   	push   %ecx
  800482:	52                   	push   %edx
  800483:	50                   	push   %eax
  800484:	e8 af fb ff ff       	call   800038 <check_block>
  800489:	83 c4 10             	add    $0x10,%esp
  80048c:	85 c0                	test   %eax,%eax
  80048e:	75 17                	jne    8004a7 <_main+0x3e7>
		{
			is_correct = 0;
  800490:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
			cprintf("test_free_2 #1.2: WRONG FREE!\n");
  800497:	83 ec 0c             	sub    $0xc,%esp
  80049a:	68 ec 40 80 00       	push   $0x8040ec
  80049f:	e8 a2 0e 00 00       	call   801346 <cprintf>
  8004a4:	83 c4 10             	add    $0x10,%esp
		}

		//Reallocate first block
		actualSize = allocSizes[0] - sizeOfMetaData;
  8004a7:	a1 00 60 80 00       	mov    0x806000,%eax
  8004ac:	83 e8 08             	sub    $0x8,%eax
  8004af:	89 45 ac             	mov    %eax,-0x54(%ebp)
		va = malloc(actualSize);
  8004b2:	83 ec 0c             	sub    $0xc,%esp
  8004b5:	ff 75 ac             	pushl  -0x54(%ebp)
  8004b8:	e8 39 1c 00 00       	call   8020f6 <malloc>
  8004bd:	83 c4 10             	add    $0x10,%esp
  8004c0:	89 45 a8             	mov    %eax,-0x58(%ebp)
		//Check returned va
		expectedVA = (void*)(USER_HEAP_START + sizeof(int) + sizeOfMetaData/2);
  8004c3:	c7 45 a4 08 00 00 80 	movl   $0x80000008,-0x5c(%ebp)
		if (check_block(va, expectedVA, allocSizes[0], 1) == 0)
  8004ca:	a1 00 60 80 00       	mov    0x806000,%eax
  8004cf:	6a 01                	push   $0x1
  8004d1:	50                   	push   %eax
  8004d2:	ff 75 a4             	pushl  -0x5c(%ebp)
  8004d5:	ff 75 a8             	pushl  -0x58(%ebp)
  8004d8:	e8 5b fb ff ff       	call   800038 <check_block>
  8004dd:	83 c4 10             	add    $0x10,%esp
  8004e0:	85 c0                	test   %eax,%eax
  8004e2:	75 17                	jne    8004fb <_main+0x43b>
		{
			is_correct = 0;
  8004e4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
			cprintf("test_free_2 #1.3: WRONG ALLOCATE AFTER FREE!\n");
  8004eb:	83 ec 0c             	sub    $0xc,%esp
  8004ee:	68 0c 41 80 00       	push   $0x80410c
  8004f3:	e8 4e 0e 00 00       	call   801346 <cprintf>
  8004f8:	83 c4 10             	add    $0x10,%esp
		}

		//Free 2nd block
		free(startVAs[1]);
  8004fb:	a1 64 60 80 00       	mov    0x806064,%eax
  800500:	83 ec 0c             	sub    $0xc,%esp
  800503:	50                   	push   %eax
  800504:	e8 16 1c 00 00       	call   80211f <free>
  800509:	83 c4 10             	add    $0x10,%esp
		if (check_block(startVAs[1],startVAs[1], allocSizes[0], 0) == 0)
  80050c:	8b 0d 00 60 80 00    	mov    0x806000,%ecx
  800512:	8b 15 64 60 80 00    	mov    0x806064,%edx
  800518:	a1 64 60 80 00       	mov    0x806064,%eax
  80051d:	6a 00                	push   $0x0
  80051f:	51                   	push   %ecx
  800520:	52                   	push   %edx
  800521:	50                   	push   %eax
  800522:	e8 11 fb ff ff       	call   800038 <check_block>
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	85 c0                	test   %eax,%eax
  80052c:	75 17                	jne    800545 <_main+0x485>
		{
			is_correct = 0;
  80052e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
			cprintf("test_free_2 #1.4: WRONG FREE!\n");
  800535:	83 ec 0c             	sub    $0xc,%esp
  800538:	68 3c 41 80 00       	push   $0x80413c
  80053d:	e8 04 0e 00 00       	call   801346 <cprintf>
  800542:	83 c4 10             	add    $0x10,%esp
		}

		if (is_correct)
  800545:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800549:	74 04                	je     80054f <_main+0x48f>
		{
			eval += 10;
  80054b:	83 45 e4 0a          	addl   $0xa,-0x1c(%ebp)
		}
	}

	//====================================================================//
	/*free Scenario 2: Merge with previous ONLY (AT the tail)*/
	cprintf("2: Free some allocated blocks [Merge with previous ONLY]\n\n") ;
  80054f:	83 ec 0c             	sub    $0xc,%esp
  800552:	68 5c 41 80 00       	push   $0x80415c
  800557:	e8 ea 0d 00 00       	call   801346 <cprintf>
  80055c:	83 c4 10             	add    $0x10,%esp
	{
		cprintf("	2.1: at the tail\n\n") ;
  80055f:	83 ec 0c             	sub    $0xc,%esp
  800562:	68 97 41 80 00       	push   $0x804197
  800567:	e8 da 0d 00 00       	call   801346 <cprintf>
  80056c:	83 c4 10             	add    $0x10,%esp
		is_correct = 1;
  80056f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		//Free last block (coalesce with previous)
		blockIndex = numOfAllocs*allocCntPerSize;
  800576:	c7 85 7c ff ff ff 78 	movl   $0x578,-0x84(%ebp)
  80057d:	05 00 00 
		free(startVAs[blockIndex]);
  800580:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  800586:	8b 04 85 60 60 80 00 	mov    0x806060(,%eax,4),%eax
  80058d:	83 ec 0c             	sub    $0xc,%esp
  800590:	50                   	push   %eax
  800591:	e8 89 1b 00 00       	call   80211f <free>
  800596:	83 c4 10             	add    $0x10,%esp
		expectedSize = allocSizes[numOfAllocs-1] + remainSize;
  800599:	8b 15 18 60 80 00    	mov    0x806018,%edx
  80059f:	8b 45 80             	mov    -0x80(%ebp),%eax
  8005a2:	01 d0                	add    %edx,%eax
  8005a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
		if (check_block(startVAs[blockIndex-1],startVAs[blockIndex-1], expectedSize, 0) == 0)
  8005a7:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  8005ad:	48                   	dec    %eax
  8005ae:	8b 14 85 60 60 80 00 	mov    0x806060(,%eax,4),%edx
  8005b5:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  8005bb:	48                   	dec    %eax
  8005bc:	8b 04 85 60 60 80 00 	mov    0x806060(,%eax,4),%eax
  8005c3:	6a 00                	push   $0x0
  8005c5:	ff 75 d8             	pushl  -0x28(%ebp)
  8005c8:	52                   	push   %edx
  8005c9:	50                   	push   %eax
  8005ca:	e8 69 fa ff ff       	call   800038 <check_block>
  8005cf:	83 c4 10             	add    $0x10,%esp
  8005d2:	85 c0                	test   %eax,%eax
  8005d4:	75 17                	jne    8005ed <_main+0x52d>
		{
			is_correct = 0;
  8005d6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
			cprintf("test_free_2 #2.1: WRONG FREE!\n");
  8005dd:	83 ec 0c             	sub    $0xc,%esp
  8005e0:	68 ac 41 80 00       	push   $0x8041ac
  8005e5:	e8 5c 0d 00 00       	call   801346 <cprintf>
  8005ea:	83 c4 10             	add    $0x10,%esp
		}

		//====================================================================//
		/*free Scenario 3: Merge with previous ONLY (between 2 blocks)*/
		cprintf("	2.2: between 2 blocks\n\n") ;
  8005ed:	83 ec 0c             	sub    $0xc,%esp
  8005f0:	68 cb 41 80 00       	push   $0x8041cb
  8005f5:	e8 4c 0d 00 00       	call   801346 <cprintf>
  8005fa:	83 c4 10             	add    $0x10,%esp
		blockIndex = 2*allocCntPerSize+1 ;
  8005fd:	c7 85 7c ff ff ff 91 	movl   $0x191,-0x84(%ebp)
  800604:	01 00 00 
		free(startVAs[blockIndex]);
  800607:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  80060d:	8b 04 85 60 60 80 00 	mov    0x806060(,%eax,4),%eax
  800614:	83 ec 0c             	sub    $0xc,%esp
  800617:	50                   	push   %eax
  800618:	e8 02 1b 00 00       	call   80211f <free>
  80061d:	83 c4 10             	add    $0x10,%esp
		expectedSize = allocSizes[2]+allocSizes[2];
  800620:	8b 15 08 60 80 00    	mov    0x806008,%edx
  800626:	a1 08 60 80 00       	mov    0x806008,%eax
  80062b:	01 d0                	add    %edx,%eax
  80062d:	89 45 d8             	mov    %eax,-0x28(%ebp)
		if (check_block(startVAs[blockIndex-1],startVAs[blockIndex-1], expectedSize, 0) == 0)
  800630:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  800636:	48                   	dec    %eax
  800637:	8b 14 85 60 60 80 00 	mov    0x806060(,%eax,4),%edx
  80063e:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  800644:	48                   	dec    %eax
  800645:	8b 04 85 60 60 80 00 	mov    0x806060(,%eax,4),%eax
  80064c:	6a 00                	push   $0x0
  80064e:	ff 75 d8             	pushl  -0x28(%ebp)
  800651:	52                   	push   %edx
  800652:	50                   	push   %eax
  800653:	e8 e0 f9 ff ff       	call   800038 <check_block>
  800658:	83 c4 10             	add    $0x10,%esp
  80065b:	85 c0                	test   %eax,%eax
  80065d:	75 17                	jne    800676 <_main+0x5b6>
		{
			is_correct = 0;
  80065f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
			cprintf("test_free_2 #2.2: WRONG FREE!\n");
  800666:	83 ec 0c             	sub    $0xc,%esp
  800669:	68 e4 41 80 00       	push   $0x8041e4
  80066e:	e8 d3 0c 00 00       	call   801346 <cprintf>
  800673:	83 c4 10             	add    $0x10,%esp
		}
		if (is_correct)
  800676:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80067a:	74 04                	je     800680 <_main+0x5c0>
		{
			eval += 10;
  80067c:	83 45 e4 0a          	addl   $0xa,-0x1c(%ebp)
	}


	//====================================================================//
	/*free Scenario 4: Merge with next ONLY (AT the head)*/
	cprintf("3: Free some allocated blocks [Merge with next ONLY]\n\n") ;
  800680:	83 ec 0c             	sub    $0xc,%esp
  800683:	68 04 42 80 00       	push   $0x804204
  800688:	e8 b9 0c 00 00       	call   801346 <cprintf>
  80068d:	83 c4 10             	add    $0x10,%esp
	{
		cprintf("	3.1: at the head\n\n") ;
  800690:	83 ec 0c             	sub    $0xc,%esp
  800693:	68 3b 42 80 00       	push   $0x80423b
  800698:	e8 a9 0c 00 00       	call   801346 <cprintf>
  80069d:	83 c4 10             	add    $0x10,%esp
		is_correct = 1;
  8006a0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		blockIndex = 0 ;
  8006a7:	c7 85 7c ff ff ff 00 	movl   $0x0,-0x84(%ebp)
  8006ae:	00 00 00 
		free(startVAs[blockIndex]);
  8006b1:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  8006b7:	8b 04 85 60 60 80 00 	mov    0x806060(,%eax,4),%eax
  8006be:	83 ec 0c             	sub    $0xc,%esp
  8006c1:	50                   	push   %eax
  8006c2:	e8 58 1a 00 00       	call   80211f <free>
  8006c7:	83 c4 10             	add    $0x10,%esp
		expectedSize = allocSizes[0]+allocSizes[0];
  8006ca:	8b 15 00 60 80 00    	mov    0x806000,%edx
  8006d0:	a1 00 60 80 00       	mov    0x806000,%eax
  8006d5:	01 d0                	add    %edx,%eax
  8006d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
		if (check_block(startVAs[blockIndex],startVAs[blockIndex], expectedSize, 0) == 0)
  8006da:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  8006e0:	8b 14 85 60 60 80 00 	mov    0x806060(,%eax,4),%edx
  8006e7:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  8006ed:	8b 04 85 60 60 80 00 	mov    0x806060(,%eax,4),%eax
  8006f4:	6a 00                	push   $0x0
  8006f6:	ff 75 d8             	pushl  -0x28(%ebp)
  8006f9:	52                   	push   %edx
  8006fa:	50                   	push   %eax
  8006fb:	e8 38 f9 ff ff       	call   800038 <check_block>
  800700:	83 c4 10             	add    $0x10,%esp
  800703:	85 c0                	test   %eax,%eax
  800705:	75 17                	jne    80071e <_main+0x65e>
		{
			is_correct = 0;
  800707:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
			cprintf("test_free_2 #3.1: WRONG FREE!\n");
  80070e:	83 ec 0c             	sub    $0xc,%esp
  800711:	68 50 42 80 00       	push   $0x804250
  800716:	e8 2b 0c 00 00       	call   801346 <cprintf>
  80071b:	83 c4 10             	add    $0x10,%esp
		}

		//====================================================================//
		/*free Scenario 5: Merge with next ONLY (between 2 blocks)*/
		cprintf("	3.2: between 2 blocks\n\n") ;
  80071e:	83 ec 0c             	sub    $0xc,%esp
  800721:	68 6f 42 80 00       	push   $0x80426f
  800726:	e8 1b 0c 00 00       	call   801346 <cprintf>
  80072b:	83 c4 10             	add    $0x10,%esp
		blockIndex = 1*allocCntPerSize - 1 ;
  80072e:	c7 85 7c ff ff ff c7 	movl   $0xc7,-0x84(%ebp)
  800735:	00 00 00 
		free(startVAs[blockIndex]);
  800738:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  80073e:	8b 04 85 60 60 80 00 	mov    0x806060(,%eax,4),%eax
  800745:	83 ec 0c             	sub    $0xc,%esp
  800748:	50                   	push   %eax
  800749:	e8 d1 19 00 00       	call   80211f <free>
  80074e:	83 c4 10             	add    $0x10,%esp
		block_size = get_block_size(startVAs[blockIndex]) ;
  800751:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  800757:	8b 04 85 60 60 80 00 	mov    0x806060(,%eax,4),%eax
  80075e:	83 ec 0c             	sub    $0xc,%esp
  800761:	50                   	push   %eax
  800762:	e8 d1 20 00 00       	call   802838 <get_block_size>
  800767:	83 c4 10             	add    $0x10,%esp
  80076a:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
		expectedSize = allocSizes[0]+allocSizes[1];
  800770:	8b 15 00 60 80 00    	mov    0x806000,%edx
  800776:	a1 04 60 80 00       	mov    0x806004,%eax
  80077b:	01 d0                	add    %edx,%eax
  80077d:	89 45 d8             	mov    %eax,-0x28(%ebp)
		if (check_block(startVAs[blockIndex],startVAs[blockIndex], expectedSize, 0) == 0)
  800780:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  800786:	8b 14 85 60 60 80 00 	mov    0x806060(,%eax,4),%edx
  80078d:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  800793:	8b 04 85 60 60 80 00 	mov    0x806060(,%eax,4),%eax
  80079a:	6a 00                	push   $0x0
  80079c:	ff 75 d8             	pushl  -0x28(%ebp)
  80079f:	52                   	push   %edx
  8007a0:	50                   	push   %eax
  8007a1:	e8 92 f8 ff ff       	call   800038 <check_block>
  8007a6:	83 c4 10             	add    $0x10,%esp
  8007a9:	85 c0                	test   %eax,%eax
  8007ab:	75 17                	jne    8007c4 <_main+0x704>
		{
			is_correct = 0;
  8007ad:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
			cprintf("test_free_2 #3.2: WRONG FREE!\n");
  8007b4:	83 ec 0c             	sub    $0xc,%esp
  8007b7:	68 88 42 80 00       	push   $0x804288
  8007bc:	e8 85 0b 00 00       	call   801346 <cprintf>
  8007c1:	83 c4 10             	add    $0x10,%esp
		}

		if (is_correct)
  8007c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007c8:	74 04                	je     8007ce <_main+0x70e>
		{
			eval += 10;
  8007ca:	83 45 e4 0a          	addl   $0xa,-0x1c(%ebp)
		}
	}
	//====================================================================//
	/*free Scenario 6: Merge with prev & next */
	cprintf("4: Free some allocated blocks [Merge with previous & next]\n\n") ;
  8007ce:	83 ec 0c             	sub    $0xc,%esp
  8007d1:	68 a8 42 80 00       	push   $0x8042a8
  8007d6:	e8 6b 0b 00 00       	call   801346 <cprintf>
  8007db:	83 c4 10             	add    $0x10,%esp
	{
		is_correct = 1;
  8007de:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		blockIndex = 4*allocCntPerSize - 2 ;
  8007e5:	c7 85 7c ff ff ff 1e 	movl   $0x31e,-0x84(%ebp)
  8007ec:	03 00 00 
		free(startVAs[blockIndex]);
  8007ef:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  8007f5:	8b 04 85 60 60 80 00 	mov    0x806060(,%eax,4),%eax
  8007fc:	83 ec 0c             	sub    $0xc,%esp
  8007ff:	50                   	push   %eax
  800800:	e8 1a 19 00 00       	call   80211f <free>
  800805:	83 c4 10             	add    $0x10,%esp

		blockIndex = 4*allocCntPerSize - 1 ;
  800808:	c7 85 7c ff ff ff 1f 	movl   $0x31f,-0x84(%ebp)
  80080f:	03 00 00 
		free(startVAs[blockIndex]);
  800812:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  800818:	8b 04 85 60 60 80 00 	mov    0x806060(,%eax,4),%eax
  80081f:	83 ec 0c             	sub    $0xc,%esp
  800822:	50                   	push   %eax
  800823:	e8 f7 18 00 00       	call   80211f <free>
  800828:	83 c4 10             	add    $0x10,%esp
		block_size = get_block_size(startVAs[blockIndex-1]) ;
  80082b:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  800831:	48                   	dec    %eax
  800832:	8b 04 85 60 60 80 00 	mov    0x806060(,%eax,4),%eax
  800839:	83 ec 0c             	sub    $0xc,%esp
  80083c:	50                   	push   %eax
  80083d:	e8 f6 1f 00 00       	call   802838 <get_block_size>
  800842:	83 c4 10             	add    $0x10,%esp
  800845:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
		expectedSize = allocSizes[3]+allocSizes[3]+allocSizes[4];
  80084b:	8b 15 0c 60 80 00    	mov    0x80600c,%edx
  800851:	a1 0c 60 80 00       	mov    0x80600c,%eax
  800856:	01 c2                	add    %eax,%edx
  800858:	a1 10 60 80 00       	mov    0x806010,%eax
  80085d:	01 d0                	add    %edx,%eax
  80085f:	89 45 d8             	mov    %eax,-0x28(%ebp)
		if (check_block(startVAs[blockIndex-1],startVAs[blockIndex-1], expectedSize, 0) == 0)
  800862:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  800868:	48                   	dec    %eax
  800869:	8b 14 85 60 60 80 00 	mov    0x806060(,%eax,4),%edx
  800870:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  800876:	48                   	dec    %eax
  800877:	8b 04 85 60 60 80 00 	mov    0x806060(,%eax,4),%eax
  80087e:	6a 00                	push   $0x0
  800880:	ff 75 d8             	pushl  -0x28(%ebp)
  800883:	52                   	push   %edx
  800884:	50                   	push   %eax
  800885:	e8 ae f7 ff ff       	call   800038 <check_block>
  80088a:	83 c4 10             	add    $0x10,%esp
  80088d:	85 c0                	test   %eax,%eax
  80088f:	75 17                	jne    8008a8 <_main+0x7e8>
		{
			is_correct = 0;
  800891:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
			cprintf("test_free_2 #4: WRONG FREE!\n");
  800898:	83 ec 0c             	sub    $0xc,%esp
  80089b:	68 e5 42 80 00       	push   $0x8042e5
  8008a0:	e8 a1 0a 00 00       	call   801346 <cprintf>
  8008a5:	83 c4 10             	add    $0x10,%esp
		}
		if (is_correct)
  8008a8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008ac:	74 04                	je     8008b2 <_main+0x7f2>
		{
			eval += 20;
  8008ae:	83 45 e4 14          	addl   $0x14,-0x1c(%ebp)
		}
	}

	//====================================================================//
	/*Allocate After Free Scenarios */
	cprintf("5: Allocate After Free [should be placed in coalesced blocks]\n\n") ;
  8008b2:	83 ec 0c             	sub    $0xc,%esp
  8008b5:	68 04 43 80 00       	push   $0x804304
  8008ba:	e8 87 0a 00 00       	call   801346 <cprintf>
  8008bf:	83 c4 10             	add    $0x10,%esp
	{
		cprintf("	5.1: in block coalesces with NEXT\n\n") ;
  8008c2:	83 ec 0c             	sub    $0xc,%esp
  8008c5:	68 44 43 80 00       	push   $0x804344
  8008ca:	e8 77 0a 00 00       	call   801346 <cprintf>
  8008cf:	83 c4 10             	add    $0x10,%esp
		is_correct = 1;
  8008d2:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		cprintf("	5.1.1: a. at head\n\n") ;
  8008d9:	83 ec 0c             	sub    $0xc,%esp
  8008dc:	68 69 43 80 00       	push   $0x804369
  8008e1:	e8 60 0a 00 00       	call   801346 <cprintf>
  8008e6:	83 c4 10             	add    $0x10,%esp
		{
			actualSize = 4*sizeof(int);
  8008e9:	c7 45 ac 10 00 00 00 	movl   $0x10,-0x54(%ebp)
			expectedSize = ROUNDUP(actualSize + sizeOfMetaData, 2);
  8008f0:	c7 85 74 ff ff ff 02 	movl   $0x2,-0x8c(%ebp)
  8008f7:	00 00 00 
  8008fa:	8b 55 ac             	mov    -0x54(%ebp),%edx
  8008fd:	8b 85 74 ff ff ff    	mov    -0x8c(%ebp),%eax
  800903:	01 d0                	add    %edx,%eax
  800905:	83 c0 07             	add    $0x7,%eax
  800908:	89 85 70 ff ff ff    	mov    %eax,-0x90(%ebp)
  80090e:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
  800914:	ba 00 00 00 00       	mov    $0x0,%edx
  800919:	f7 b5 74 ff ff ff    	divl   -0x8c(%ebp)
  80091f:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
  800925:	29 d0                	sub    %edx,%eax
  800927:	89 45 d8             	mov    %eax,-0x28(%ebp)
			va = malloc(actualSize);
  80092a:	83 ec 0c             	sub    $0xc,%esp
  80092d:	ff 75 ac             	pushl  -0x54(%ebp)
  800930:	e8 c1 17 00 00       	call   8020f6 <malloc>
  800935:	83 c4 10             	add    $0x10,%esp
  800938:	89 45 a8             	mov    %eax,-0x58(%ebp)
			//Check returned va
			expectedVA = (void*)(USER_HEAP_START + sizeOfMetaData);
  80093b:	c7 45 a4 08 00 00 80 	movl   $0x80000008,-0x5c(%ebp)
			if (check_block(va, expectedVA, expectedSize, 1) == 0)
  800942:	6a 01                	push   $0x1
  800944:	ff 75 d8             	pushl  -0x28(%ebp)
  800947:	ff 75 a4             	pushl  -0x5c(%ebp)
  80094a:	ff 75 a8             	pushl  -0x58(%ebp)
  80094d:	e8 e6 f6 ff ff       	call   800038 <check_block>
  800952:	83 c4 10             	add    $0x10,%esp
  800955:	85 c0                	test   %eax,%eax
  800957:	75 17                	jne    800970 <_main+0x8b0>
			{
				is_correct = 0;
  800959:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				cprintf("test_free_2 #5.1.1: WRONG ALLOCATE AFTER FREE!\n");
  800960:	83 ec 0c             	sub    $0xc,%esp
  800963:	68 80 43 80 00       	push   $0x804380
  800968:	e8 d9 09 00 00       	call   801346 <cprintf>
  80096d:	83 c4 10             	add    $0x10,%esp
			}
		}
		cprintf("	5.1.2: b. after the prev alloc in 5.1.1\n\n") ;
  800970:	83 ec 0c             	sub    $0xc,%esp
  800973:	68 b0 43 80 00       	push   $0x8043b0
  800978:	e8 c9 09 00 00       	call   801346 <cprintf>
  80097d:	83 c4 10             	add    $0x10,%esp
		{
			actualSize = 2*sizeof(int) ;
  800980:	c7 45 ac 08 00 00 00 	movl   $0x8,-0x54(%ebp)
			va = malloc(actualSize);
  800987:	83 ec 0c             	sub    $0xc,%esp
  80098a:	ff 75 ac             	pushl  -0x54(%ebp)
  80098d:	e8 64 17 00 00       	call   8020f6 <malloc>
  800992:	83 c4 10             	add    $0x10,%esp
  800995:	89 45 a8             	mov    %eax,-0x58(%ebp)
			expectedSize = ROUNDUP(actualSize + sizeOfMetaData, 2);
  800998:	c7 85 6c ff ff ff 02 	movl   $0x2,-0x94(%ebp)
  80099f:	00 00 00 
  8009a2:	8b 55 ac             	mov    -0x54(%ebp),%edx
  8009a5:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
  8009ab:	01 d0                	add    %edx,%eax
  8009ad:	83 c0 07             	add    $0x7,%eax
  8009b0:	89 85 68 ff ff ff    	mov    %eax,-0x98(%ebp)
  8009b6:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
  8009bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c1:	f7 b5 6c ff ff ff    	divl   -0x94(%ebp)
  8009c7:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
  8009cd:	29 d0                	sub    %edx,%eax
  8009cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
			//Check returned va
			expectedVA = (void*)(USER_HEAP_START + sizeOfMetaData + 4*sizeof(int) + sizeOfMetaData);
  8009d2:	c7 45 a4 20 00 00 80 	movl   $0x80000020,-0x5c(%ebp)
			if (check_block(va, expectedVA, expectedSize, 1) == 0)
  8009d9:	6a 01                	push   $0x1
  8009db:	ff 75 d8             	pushl  -0x28(%ebp)
  8009de:	ff 75 a4             	pushl  -0x5c(%ebp)
  8009e1:	ff 75 a8             	pushl  -0x58(%ebp)
  8009e4:	e8 4f f6 ff ff       	call   800038 <check_block>
  8009e9:	83 c4 10             	add    $0x10,%esp
  8009ec:	85 c0                	test   %eax,%eax
  8009ee:	75 17                	jne    800a07 <_main+0x947>
			{
				is_correct = 0;
  8009f0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				cprintf("test_free_2 #5.1.2: WRONG ALLOCATE AFTER FREE!\n");
  8009f7:	83 ec 0c             	sub    $0xc,%esp
  8009fa:	68 dc 43 80 00       	push   $0x8043dc
  8009ff:	e8 42 09 00 00       	call   801346 <cprintf>
  800a04:	83 c4 10             	add    $0x10,%esp
			}
		}
		cprintf("	5.1.3: c. between two blocks [INTERNAL FRAGMENTATION CASE]\n\n") ;
  800a07:	83 ec 0c             	sub    $0xc,%esp
  800a0a:	68 0c 44 80 00       	push   $0x80440c
  800a0f:	e8 32 09 00 00       	call   801346 <cprintf>
  800a14:	83 c4 10             	add    $0x10,%esp
		{
			actualSize = 5*sizeof(int); //20B
  800a17:	c7 45 ac 14 00 00 00 	movl   $0x14,-0x54(%ebp)
			expectedSize = allocSizes[0] + allocSizes[1]; //20B + 16B [Internal Fragmentation of 8 Bytes]
  800a1e:	8b 15 00 60 80 00    	mov    0x806000,%edx
  800a24:	a1 04 60 80 00       	mov    0x806004,%eax
  800a29:	01 d0                	add    %edx,%eax
  800a2b:	89 45 d8             	mov    %eax,-0x28(%ebp)
			va = malloc(actualSize);
  800a2e:	83 ec 0c             	sub    $0xc,%esp
  800a31:	ff 75 ac             	pushl  -0x54(%ebp)
  800a34:	e8 bd 16 00 00       	call   8020f6 <malloc>
  800a39:	83 c4 10             	add    $0x10,%esp
  800a3c:	89 45 a8             	mov    %eax,-0x58(%ebp)
			//Check returned va
			expectedVA = startVAs[1*allocCntPerSize - 1];
  800a3f:	a1 7c 63 80 00       	mov    0x80637c,%eax
  800a44:	89 45 a4             	mov    %eax,-0x5c(%ebp)
			if (check_block(va, expectedVA, expectedSize, 1) == 0)
  800a47:	6a 01                	push   $0x1
  800a49:	ff 75 d8             	pushl  -0x28(%ebp)
  800a4c:	ff 75 a4             	pushl  -0x5c(%ebp)
  800a4f:	ff 75 a8             	pushl  -0x58(%ebp)
  800a52:	e8 e1 f5 ff ff       	call   800038 <check_block>
  800a57:	83 c4 10             	add    $0x10,%esp
  800a5a:	85 c0                	test   %eax,%eax
  800a5c:	75 17                	jne    800a75 <_main+0x9b5>
			{
				is_correct = 0;
  800a5e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				cprintf("test_free_2 #5.1.3: WRONG ALLOCATE AFTER FREE!\n");
  800a65:	83 ec 0c             	sub    $0xc,%esp
  800a68:	68 4c 44 80 00       	push   $0x80444c
  800a6d:	e8 d4 08 00 00       	call   801346 <cprintf>
  800a72:	83 c4 10             	add    $0x10,%esp
			}
		}
		if (is_correct)
  800a75:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a79:	74 04                	je     800a7f <_main+0x9bf>
		{
			eval += 10;
  800a7b:	83 45 e4 0a          	addl   $0xa,-0x1c(%ebp)
		}

		cprintf("	5.2: in block coalesces with PREV & NEXT\n\n") ;
  800a7f:	83 ec 0c             	sub    $0xc,%esp
  800a82:	68 7c 44 80 00       	push   $0x80447c
  800a87:	e8 ba 08 00 00       	call   801346 <cprintf>
  800a8c:	83 c4 10             	add    $0x10,%esp
		is_correct = 1;
  800a8f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		actualSize = 3*kilo/2;
  800a96:	c7 45 ac 00 06 00 00 	movl   $0x600,-0x54(%ebp)
		expectedSize = ROUNDUP(actualSize + sizeOfMetaData, 2);
  800a9d:	c7 85 64 ff ff ff 02 	movl   $0x2,-0x9c(%ebp)
  800aa4:	00 00 00 
  800aa7:	8b 55 ac             	mov    -0x54(%ebp),%edx
  800aaa:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  800ab0:	01 d0                	add    %edx,%eax
  800ab2:	83 c0 07             	add    $0x7,%eax
  800ab5:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  800abb:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  800ac1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac6:	f7 b5 64 ff ff ff    	divl   -0x9c(%ebp)
  800acc:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  800ad2:	29 d0                	sub    %edx,%eax
  800ad4:	89 45 d8             	mov    %eax,-0x28(%ebp)
		va = malloc(actualSize);
  800ad7:	83 ec 0c             	sub    $0xc,%esp
  800ada:	ff 75 ac             	pushl  -0x54(%ebp)
  800add:	e8 14 16 00 00       	call   8020f6 <malloc>
  800ae2:	83 c4 10             	add    $0x10,%esp
  800ae5:	89 45 a8             	mov    %eax,-0x58(%ebp)
		//Check returned va
		expectedVA = startVAs[4*allocCntPerSize - 2];
  800ae8:	a1 d8 6c 80 00       	mov    0x806cd8,%eax
  800aed:	89 45 a4             	mov    %eax,-0x5c(%ebp)
		if (check_block(va, expectedVA, expectedSize, 1) == 0)
  800af0:	6a 01                	push   $0x1
  800af2:	ff 75 d8             	pushl  -0x28(%ebp)
  800af5:	ff 75 a4             	pushl  -0x5c(%ebp)
  800af8:	ff 75 a8             	pushl  -0x58(%ebp)
  800afb:	e8 38 f5 ff ff       	call   800038 <check_block>
  800b00:	83 c4 10             	add    $0x10,%esp
  800b03:	85 c0                	test   %eax,%eax
  800b05:	75 17                	jne    800b1e <_main+0xa5e>
		{
			is_correct = 0;
  800b07:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
			cprintf("test_free_2 #5.2: WRONG ALLOCATE AFTER FREE!\n");
  800b0e:	83 ec 0c             	sub    $0xc,%esp
  800b11:	68 a8 44 80 00       	push   $0x8044a8
  800b16:	e8 2b 08 00 00       	call   801346 <cprintf>
  800b1b:	83 c4 10             	add    $0x10,%esp
		}
		if (is_correct)
  800b1e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b22:	74 04                	je     800b28 <_main+0xa68>
		{
			eval += 10;
  800b24:	83 45 e4 0a          	addl   $0xa,-0x1c(%ebp)
		}

		cprintf("	5.3: in block coalesces with PREV\n\n") ;
  800b28:	83 ec 0c             	sub    $0xc,%esp
  800b2b:	68 d8 44 80 00       	push   $0x8044d8
  800b30:	e8 11 08 00 00       	call   801346 <cprintf>
  800b35:	83 c4 10             	add    $0x10,%esp
		cprintf("	5.3.1: a. between two blocks\n\n") ;
  800b38:	83 ec 0c             	sub    $0xc,%esp
  800b3b:	68 00 45 80 00       	push   $0x804500
  800b40:	e8 01 08 00 00       	call   801346 <cprintf>
  800b45:	83 c4 10             	add    $0x10,%esp
		{
			is_correct = 1;
  800b48:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			actualSize = 30*sizeof(char) ;
  800b4f:	c7 45 ac 1e 00 00 00 	movl   $0x1e,-0x54(%ebp)
			expectedSize = ROUNDUP(actualSize + sizeOfMetaData, 2);
  800b56:	c7 85 5c ff ff ff 02 	movl   $0x2,-0xa4(%ebp)
  800b5d:	00 00 00 
  800b60:	8b 55 ac             	mov    -0x54(%ebp),%edx
  800b63:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  800b69:	01 d0                	add    %edx,%eax
  800b6b:	83 c0 07             	add    $0x7,%eax
  800b6e:	89 85 58 ff ff ff    	mov    %eax,-0xa8(%ebp)
  800b74:	8b 85 58 ff ff ff    	mov    -0xa8(%ebp),%eax
  800b7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7f:	f7 b5 5c ff ff ff    	divl   -0xa4(%ebp)
  800b85:	8b 85 58 ff ff ff    	mov    -0xa8(%ebp),%eax
  800b8b:	29 d0                	sub    %edx,%eax
  800b8d:	89 45 d8             	mov    %eax,-0x28(%ebp)
			va = malloc(actualSize);
  800b90:	83 ec 0c             	sub    $0xc,%esp
  800b93:	ff 75 ac             	pushl  -0x54(%ebp)
  800b96:	e8 5b 15 00 00       	call   8020f6 <malloc>
  800b9b:	83 c4 10             	add    $0x10,%esp
  800b9e:	89 45 a8             	mov    %eax,-0x58(%ebp)
			//Check returned va
			expectedVA = startVAs[2*allocCntPerSize];
  800ba1:	a1 a0 66 80 00       	mov    0x8066a0,%eax
  800ba6:	89 45 a4             	mov    %eax,-0x5c(%ebp)
			if (check_block(va, expectedVA, expectedSize, 1) == 0)
  800ba9:	6a 01                	push   $0x1
  800bab:	ff 75 d8             	pushl  -0x28(%ebp)
  800bae:	ff 75 a4             	pushl  -0x5c(%ebp)
  800bb1:	ff 75 a8             	pushl  -0x58(%ebp)
  800bb4:	e8 7f f4 ff ff       	call   800038 <check_block>
  800bb9:	83 c4 10             	add    $0x10,%esp
  800bbc:	85 c0                	test   %eax,%eax
  800bbe:	75 17                	jne    800bd7 <_main+0xb17>
			{
				is_correct = 0;
  800bc0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				cprintf("test_free_2 #5.3.1: WRONG ALLOCATE AFTER FREE!\n");
  800bc7:	83 ec 0c             	sub    $0xc,%esp
  800bca:	68 20 45 80 00       	push   $0x804520
  800bcf:	e8 72 07 00 00       	call   801346 <cprintf>
  800bd4:	83 c4 10             	add    $0x10,%esp
			}
		}
		actualSize = 3*kilo/2 - sizeOfMetaData ;
  800bd7:	c7 45 ac f8 05 00 00 	movl   $0x5f8,-0x54(%ebp)
		expectedSize = ROUNDUP(actualSize + sizeOfMetaData, 2);
  800bde:	c7 85 54 ff ff ff 02 	movl   $0x2,-0xac(%ebp)
  800be5:	00 00 00 
  800be8:	8b 55 ac             	mov    -0x54(%ebp),%edx
  800beb:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800bf1:	01 d0                	add    %edx,%eax
  800bf3:	83 c0 07             	add    $0x7,%eax
  800bf6:	89 85 50 ff ff ff    	mov    %eax,-0xb0(%ebp)
  800bfc:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800c02:	ba 00 00 00 00       	mov    $0x0,%edx
  800c07:	f7 b5 54 ff ff ff    	divl   -0xac(%ebp)
  800c0d:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800c13:	29 d0                	sub    %edx,%eax
  800c15:	89 45 d8             	mov    %eax,-0x28(%ebp)

		//dummy allocation to consume the 1st 1.5 KB free block
		{
			va = malloc(actualSize);
  800c18:	83 ec 0c             	sub    $0xc,%esp
  800c1b:	ff 75 ac             	pushl  -0x54(%ebp)
  800c1e:	e8 d3 14 00 00       	call   8020f6 <malloc>
  800c23:	83 c4 10             	add    $0x10,%esp
  800c26:	89 45 a8             	mov    %eax,-0x58(%ebp)
		}
		//dummy allocation to consume the 1st 2 KB free block
		{
			va = malloc(actualSize);
  800c29:	83 ec 0c             	sub    $0xc,%esp
  800c2c:	ff 75 ac             	pushl  -0x54(%ebp)
  800c2f:	e8 c2 14 00 00       	call   8020f6 <malloc>
  800c34:	83 c4 10             	add    $0x10,%esp
  800c37:	89 45 a8             	mov    %eax,-0x58(%ebp)
		}

		cprintf("	5.3.2: b. at tail\n\n") ;
  800c3a:	83 ec 0c             	sub    $0xc,%esp
  800c3d:	68 50 45 80 00       	push   $0x804550
  800c42:	e8 ff 06 00 00       	call   801346 <cprintf>
  800c47:	83 c4 10             	add    $0x10,%esp
		{
			actualSize = 3*kilo/2 ;
  800c4a:	c7 45 ac 00 06 00 00 	movl   $0x600,-0x54(%ebp)
			expectedSize = ROUNDUP(actualSize + sizeOfMetaData, 2);
  800c51:	c7 85 4c ff ff ff 02 	movl   $0x2,-0xb4(%ebp)
  800c58:	00 00 00 
  800c5b:	8b 55 ac             	mov    -0x54(%ebp),%edx
  800c5e:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800c64:	01 d0                	add    %edx,%eax
  800c66:	83 c0 07             	add    $0x7,%eax
  800c69:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
  800c6f:	8b 85 48 ff ff ff    	mov    -0xb8(%ebp),%eax
  800c75:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7a:	f7 b5 4c ff ff ff    	divl   -0xb4(%ebp)
  800c80:	8b 85 48 ff ff ff    	mov    -0xb8(%ebp),%eax
  800c86:	29 d0                	sub    %edx,%eax
  800c88:	89 45 d8             	mov    %eax,-0x28(%ebp)

			print_blocks_list(freeBlocksList);
  800c8b:	83 ec 10             	sub    $0x10,%esp
  800c8e:	89 e0                	mov    %esp,%eax
  800c90:	89 c2                	mov    %eax,%edx
  800c92:	bb 44 60 80 00       	mov    $0x806044,%ebx
  800c97:	b8 04 00 00 00       	mov    $0x4,%eax
  800c9c:	89 d7                	mov    %edx,%edi
  800c9e:	89 de                	mov    %ebx,%esi
  800ca0:	89 c1                	mov    %eax,%ecx
  800ca2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ca4:	e8 55 1c 00 00       	call   8028fe <print_blocks_list>
  800ca9:	83 c4 10             	add    $0x10,%esp

			va = malloc(actualSize);
  800cac:	83 ec 0c             	sub    $0xc,%esp
  800caf:	ff 75 ac             	pushl  -0x54(%ebp)
  800cb2:	e8 3f 14 00 00       	call   8020f6 <malloc>
  800cb7:	83 c4 10             	add    $0x10,%esp
  800cba:	89 45 a8             	mov    %eax,-0x58(%ebp)

			//Check returned va
			expectedVA = startVAs[numOfAllocs*allocCntPerSize-1];
  800cbd:	a1 3c 76 80 00       	mov    0x80763c,%eax
  800cc2:	89 45 a4             	mov    %eax,-0x5c(%ebp)
			if (check_block(va, expectedVA, expectedSize, 1) == 0)
  800cc5:	6a 01                	push   $0x1
  800cc7:	ff 75 d8             	pushl  -0x28(%ebp)
  800cca:	ff 75 a4             	pushl  -0x5c(%ebp)
  800ccd:	ff 75 a8             	pushl  -0x58(%ebp)
  800cd0:	e8 63 f3 ff ff       	call   800038 <check_block>
  800cd5:	83 c4 10             	add    $0x10,%esp
  800cd8:	85 c0                	test   %eax,%eax
  800cda:	75 17                	jne    800cf3 <_main+0xc33>
			{
				is_correct = 0;
  800cdc:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				cprintf("test_free_2 #5.3.2: WRONG ALLOCATE AFTER FREE!\n");
  800ce3:	83 ec 0c             	sub    $0xc,%esp
  800ce6:	68 68 45 80 00       	push   $0x804568
  800ceb:	e8 56 06 00 00       	call   801346 <cprintf>
  800cf0:	83 c4 10             	add    $0x10,%esp
			}
		}

		cprintf("	5.3.3: c. after the prev allocated block in 5.3.2\n\n") ;
  800cf3:	83 ec 0c             	sub    $0xc,%esp
  800cf6:	68 98 45 80 00       	push   $0x804598
  800cfb:	e8 46 06 00 00       	call   801346 <cprintf>
  800d00:	83 c4 10             	add    $0x10,%esp
		{
			actualSize = 3*kilo/2 ;
  800d03:	c7 45 ac 00 06 00 00 	movl   $0x600,-0x54(%ebp)
			expectedSize = ROUNDUP(actualSize + sizeOfMetaData, 2);
  800d0a:	c7 85 44 ff ff ff 02 	movl   $0x2,-0xbc(%ebp)
  800d11:	00 00 00 
  800d14:	8b 55 ac             	mov    -0x54(%ebp),%edx
  800d17:	8b 85 44 ff ff ff    	mov    -0xbc(%ebp),%eax
  800d1d:	01 d0                	add    %edx,%eax
  800d1f:	83 c0 07             	add    $0x7,%eax
  800d22:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  800d28:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800d2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d33:	f7 b5 44 ff ff ff    	divl   -0xbc(%ebp)
  800d39:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800d3f:	29 d0                	sub    %edx,%eax
  800d41:	89 45 d8             	mov    %eax,-0x28(%ebp)

			va = malloc(actualSize);
  800d44:	83 ec 0c             	sub    $0xc,%esp
  800d47:	ff 75 ac             	pushl  -0x54(%ebp)
  800d4a:	e8 a7 13 00 00       	call   8020f6 <malloc>
  800d4f:	83 c4 10             	add    $0x10,%esp
  800d52:	89 45 a8             	mov    %eax,-0x58(%ebp)

			//Check returned va
			expectedVA = (void*)startVAs[numOfAllocs*allocCntPerSize-1] + 3*kilo/2 + sizeOfMetaData;
  800d55:	a1 3c 76 80 00       	mov    0x80763c,%eax
  800d5a:	05 08 06 00 00       	add    $0x608,%eax
  800d5f:	89 45 a4             	mov    %eax,-0x5c(%ebp)
			if (check_block(va, expectedVA, expectedSize, 1) == 0)
  800d62:	6a 01                	push   $0x1
  800d64:	ff 75 d8             	pushl  -0x28(%ebp)
  800d67:	ff 75 a4             	pushl  -0x5c(%ebp)
  800d6a:	ff 75 a8             	pushl  -0x58(%ebp)
  800d6d:	e8 c6 f2 ff ff       	call   800038 <check_block>
  800d72:	83 c4 10             	add    $0x10,%esp
  800d75:	85 c0                	test   %eax,%eax
  800d77:	75 17                	jne    800d90 <_main+0xcd0>
			{
				is_correct = 0;
  800d79:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				cprintf("test_free_2 #5.3.3: WRONG ALLOCATE AFTER FREE!\n");
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	68 d0 45 80 00       	push   $0x8045d0
  800d88:	e8 b9 05 00 00       	call   801346 <cprintf>
  800d8d:	83 c4 10             	add    $0x10,%esp
			}
		}
		if (is_correct)
  800d90:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d94:	74 04                	je     800d9a <_main+0xcda>
		{
			eval += 10;
  800d96:	83 45 e4 0a          	addl   $0xa,-0x1c(%ebp)
		}
	}

	//====================================================================//
	/*Check memory allocation*/
	cprintf("6: Check memory allocation [should not be changed due to free]\n\n") ;
  800d9a:	83 ec 0c             	sub    $0xc,%esp
  800d9d:	68 00 46 80 00       	push   $0x804600
  800da2:	e8 9f 05 00 00       	call   801346 <cprintf>
  800da7:	83 c4 10             	add    $0x10,%esp
	{
		is_correct = 1;
  800daa:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		if ((freeFrames - sys_calculate_free_frames()) != 0)
  800db1:	e8 74 15 00 00       	call   80232a <sys_calculate_free_frames>
  800db6:	89 c2                	mov    %eax,%edx
  800db8:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800dbb:	39 c2                	cmp    %eax,%edx
  800dbd:	74 17                	je     800dd6 <_main+0xd16>
		{
			cprintf("test_free_2 #6: number of allocated pages in MEMORY is changed due to free() while it's not supposed to!\n");
  800dbf:	83 ec 0c             	sub    $0xc,%esp
  800dc2:	68 44 46 80 00       	push   $0x804644
  800dc7:	e8 7a 05 00 00       	call   801346 <cprintf>
  800dcc:	83 c4 10             	add    $0x10,%esp
			is_correct = 0;
  800dcf:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		}
		if (is_correct)
  800dd6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800dda:	74 04                	je     800de0 <_main+0xd20>
		{
			eval += 10;
  800ddc:	83 45 e4 0a          	addl   $0xa,-0x1c(%ebp)
		}
	}

	uint32 expectedAllocatedSize = curTotalSize;
  800de0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800de3:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%ebp)
//	for (int i = 0; i < numOfAllocs; ++i)
//	{
//		expectedAllocatedSize += allocCntPerSize * allocSizes[i] ;
//	}
	expectedAllocatedSize = ROUNDUP(expectedAllocatedSize, PAGE_SIZE);
  800de9:	c7 85 38 ff ff ff 00 	movl   $0x1000,-0xc8(%ebp)
  800df0:	10 00 00 
  800df3:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
  800df9:	8b 85 38 ff ff ff    	mov    -0xc8(%ebp),%eax
  800dff:	01 d0                	add    %edx,%eax
  800e01:	48                   	dec    %eax
  800e02:	89 85 34 ff ff ff    	mov    %eax,-0xcc(%ebp)
  800e08:	8b 85 34 ff ff ff    	mov    -0xcc(%ebp),%eax
  800e0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e13:	f7 b5 38 ff ff ff    	divl   -0xc8(%ebp)
  800e19:	8b 85 34 ff ff ff    	mov    -0xcc(%ebp),%eax
  800e1f:	29 d0                	sub    %edx,%eax
  800e21:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%ebp)
	uint32 expectedAllocNumOfPages = expectedAllocatedSize / PAGE_SIZE; 				/*# pages*/
  800e27:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800e2d:	c1 e8 0c             	shr    $0xc,%eax
  800e30:	89 85 30 ff ff ff    	mov    %eax,-0xd0(%ebp)
	uint32 expectedAllocNumOfTables = ROUNDUP(expectedAllocatedSize, PTSIZE) / PTSIZE; 	/*# tables*/
  800e36:	c7 85 2c ff ff ff 00 	movl   $0x400000,-0xd4(%ebp)
  800e3d:	00 40 00 
  800e40:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
  800e46:	8b 85 2c ff ff ff    	mov    -0xd4(%ebp),%eax
  800e4c:	01 d0                	add    %edx,%eax
  800e4e:	48                   	dec    %eax
  800e4f:	89 85 28 ff ff ff    	mov    %eax,-0xd8(%ebp)
  800e55:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
  800e5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e60:	f7 b5 2c ff ff ff    	divl   -0xd4(%ebp)
  800e66:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
  800e6c:	29 d0                	sub    %edx,%eax
  800e6e:	c1 e8 16             	shr    $0x16,%eax
  800e71:	89 85 24 ff ff ff    	mov    %eax,-0xdc(%ebp)

	//====================================================================//
	/*Check WS elements*/
	cprintf("7: Check WS Elements [should not be changed due to free]\n\n") ;
  800e77:	83 ec 0c             	sub    $0xc,%esp
  800e7a:	68 b0 46 80 00       	push   $0x8046b0
  800e7f:	e8 c2 04 00 00       	call   801346 <cprintf>
  800e84:	83 c4 10             	add    $0x10,%esp
	{
		is_correct = 1;
  800e87:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		uint32* expectedVAs = malloc(expectedAllocNumOfPages*sizeof(int));
  800e8e:	8b 85 30 ff ff ff    	mov    -0xd0(%ebp),%eax
  800e94:	c1 e0 02             	shl    $0x2,%eax
  800e97:	83 ec 0c             	sub    $0xc,%esp
  800e9a:	50                   	push   %eax
  800e9b:	e8 56 12 00 00       	call   8020f6 <malloc>
  800ea0:	83 c4 10             	add    $0x10,%esp
  800ea3:	89 85 20 ff ff ff    	mov    %eax,-0xe0(%ebp)
		int i = 0;
  800ea9:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
		for (uint32 va = USER_HEAP_START; va < USER_HEAP_START + expectedAllocatedSize; va+=PAGE_SIZE)
  800eb0:	c7 45 bc 00 00 00 80 	movl   $0x80000000,-0x44(%ebp)
  800eb7:	eb 24                	jmp    800edd <_main+0xe1d>
		{
			expectedVAs[i++] = va;
  800eb9:	8b 45 c0             	mov    -0x40(%ebp),%eax
  800ebc:	8d 50 01             	lea    0x1(%eax),%edx
  800ebf:	89 55 c0             	mov    %edx,-0x40(%ebp)
  800ec2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800ec9:	8b 85 20 ff ff ff    	mov    -0xe0(%ebp),%eax
  800ecf:	01 c2                	add    %eax,%edx
  800ed1:	8b 45 bc             	mov    -0x44(%ebp),%eax
  800ed4:	89 02                	mov    %eax,(%edx)
	cprintf("7: Check WS Elements [should not be changed due to free]\n\n") ;
	{
		is_correct = 1;
		uint32* expectedVAs = malloc(expectedAllocNumOfPages*sizeof(int));
		int i = 0;
		for (uint32 va = USER_HEAP_START; va < USER_HEAP_START + expectedAllocatedSize; va+=PAGE_SIZE)
  800ed6:	81 45 bc 00 10 00 00 	addl   $0x1000,-0x44(%ebp)
  800edd:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800ee3:	05 00 00 00 80       	add    $0x80000000,%eax
  800ee8:	3b 45 bc             	cmp    -0x44(%ebp),%eax
  800eeb:	77 cc                	ja     800eb9 <_main+0xdf9>
		{
			expectedVAs[i++] = va;
		}
		chk = sys_check_WS_list(expectedVAs, expectedAllocNumOfPages, 0, 2);
  800eed:	8b 85 30 ff ff ff    	mov    -0xd0(%ebp),%eax
  800ef3:	6a 02                	push   $0x2
  800ef5:	6a 00                	push   $0x0
  800ef7:	50                   	push   %eax
  800ef8:	ff b5 20 ff ff ff    	pushl  -0xe0(%ebp)
  800efe:	e8 82 18 00 00       	call   802785 <sys_check_WS_list>
  800f03:	83 c4 10             	add    $0x10,%esp
  800f06:	89 85 1c ff ff ff    	mov    %eax,-0xe4(%ebp)
		if (chk != 1)
  800f0c:	83 bd 1c ff ff ff 01 	cmpl   $0x1,-0xe4(%ebp)
  800f13:	74 17                	je     800f2c <_main+0xe6c>
		{
			cprintf("test_free_2 #7: page is either not added to WS or removed from it\n");
  800f15:	83 ec 0c             	sub    $0xc,%esp
  800f18:	68 ec 46 80 00       	push   $0x8046ec
  800f1d:	e8 24 04 00 00       	call   801346 <cprintf>
  800f22:	83 c4 10             	add    $0x10,%esp
			is_correct = 0;
  800f25:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		}
		if (is_correct)
  800f2c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f30:	74 04                	je     800f36 <_main+0xe76>
		{
			eval += 10;
  800f32:	83 45 e4 0a          	addl   $0xa,-0x1c(%ebp)
		}
	}

	cprintf("%~test free() with FIRST FIT completed [DYNAMIC ALLOCATOR]. Evaluation = %d%\n", eval);
  800f36:	83 ec 08             	sub    $0x8,%esp
  800f39:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f3c:	68 30 47 80 00       	push   $0x804730
  800f41:	e8 00 04 00 00       	call   801346 <cprintf>
  800f46:	83 c4 10             	add    $0x10,%esp

	return;
  800f49:	90                   	nop
}
  800f4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f4d:	5b                   	pop    %ebx
  800f4e:	5e                   	pop    %esi
  800f4f:	5f                   	pop    %edi
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    

00800f52 <libmain>:

volatile struct Env *myEnv = NULL;
volatile char *binaryname = "(PROGRAM NAME UNKNOWN)";
void
libmain(int argc, char **argv)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	83 ec 18             	sub    $0x18,%esp
	int envIndex = sys_getenvindex();
  800f58:	e8 96 15 00 00       	call   8024f3 <sys_getenvindex>
  800f5d:	89 45 f4             	mov    %eax,-0xc(%ebp)

	myEnv = &(envs[envIndex]);
  800f60:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f63:	89 d0                	mov    %edx,%eax
  800f65:	c1 e0 02             	shl    $0x2,%eax
  800f68:	01 d0                	add    %edx,%eax
  800f6a:	01 c0                	add    %eax,%eax
  800f6c:	01 d0                	add    %edx,%eax
  800f6e:	c1 e0 02             	shl    $0x2,%eax
  800f71:	01 d0                	add    %edx,%eax
  800f73:	01 c0                	add    %eax,%eax
  800f75:	01 d0                	add    %edx,%eax
  800f77:	c1 e0 04             	shl    $0x4,%eax
  800f7a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f7f:	a3 20 60 80 00       	mov    %eax,0x806020

	//SET THE PROGRAM NAME
	if (myEnv->prog_name[0] != '\0')
  800f84:	a1 20 60 80 00       	mov    0x806020,%eax
  800f89:	8a 40 20             	mov    0x20(%eax),%al
  800f8c:	84 c0                	test   %al,%al
  800f8e:	74 0d                	je     800f9d <libmain+0x4b>
		binaryname = myEnv->prog_name;
  800f90:	a1 20 60 80 00       	mov    0x806020,%eax
  800f95:	83 c0 20             	add    $0x20,%eax
  800f98:	a3 1c 60 80 00       	mov    %eax,0x80601c

	// set env to point at our env structure in envs[].
	// env = envs;

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800f9d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800fa1:	7e 0a                	jle    800fad <libmain+0x5b>
		binaryname = argv[0];
  800fa3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa6:	8b 00                	mov    (%eax),%eax
  800fa8:	a3 1c 60 80 00       	mov    %eax,0x80601c

	// call user main routine
	_main(argc, argv);
  800fad:	83 ec 08             	sub    $0x8,%esp
  800fb0:	ff 75 0c             	pushl  0xc(%ebp)
  800fb3:	ff 75 08             	pushl  0x8(%ebp)
  800fb6:	e8 05 f1 ff ff       	call   8000c0 <_main>
  800fbb:	83 c4 10             	add    $0x10,%esp



	//	sys_lock_cons();
	sys_lock_cons();
  800fbe:	e8 b4 12 00 00       	call   802277 <sys_lock_cons>
	{
		cprintf("**************************************\n");
  800fc3:	83 ec 0c             	sub    $0xc,%esp
  800fc6:	68 98 47 80 00       	push   $0x804798
  800fcb:	e8 76 03 00 00       	call   801346 <cprintf>
  800fd0:	83 c4 10             	add    $0x10,%esp
		cprintf("Num of PAGE faults = %d, modif = %d\n", myEnv->pageFaultsCounter, myEnv->nModifiedPages);
  800fd3:	a1 20 60 80 00       	mov    0x806020,%eax
  800fd8:	8b 90 94 05 00 00    	mov    0x594(%eax),%edx
  800fde:	a1 20 60 80 00       	mov    0x806020,%eax
  800fe3:	8b 80 84 05 00 00    	mov    0x584(%eax),%eax
  800fe9:	83 ec 04             	sub    $0x4,%esp
  800fec:	52                   	push   %edx
  800fed:	50                   	push   %eax
  800fee:	68 c0 47 80 00       	push   $0x8047c0
  800ff3:	e8 4e 03 00 00       	call   801346 <cprintf>
  800ff8:	83 c4 10             	add    $0x10,%esp
		cprintf("# PAGE IN (from disk) = %d, # PAGE OUT (on disk) = %d, # NEW PAGE ADDED (on disk) = %d\n", myEnv->nPageIn, myEnv->nPageOut,myEnv->nNewPageAdded);
  800ffb:	a1 20 60 80 00       	mov    0x806020,%eax
  801000:	8b 88 a8 05 00 00    	mov    0x5a8(%eax),%ecx
  801006:	a1 20 60 80 00       	mov    0x806020,%eax
  80100b:	8b 90 a4 05 00 00    	mov    0x5a4(%eax),%edx
  801011:	a1 20 60 80 00       	mov    0x806020,%eax
  801016:	8b 80 a0 05 00 00    	mov    0x5a0(%eax),%eax
  80101c:	51                   	push   %ecx
  80101d:	52                   	push   %edx
  80101e:	50                   	push   %eax
  80101f:	68 e8 47 80 00       	push   $0x8047e8
  801024:	e8 1d 03 00 00       	call   801346 <cprintf>
  801029:	83 c4 10             	add    $0x10,%esp
		//cprintf("Num of freeing scarce memory = %d, freeing full working set = %d\n", myEnv->freeingScarceMemCounter, myEnv->freeingFullWSCounter);
		cprintf("Num of clocks = %d\n", myEnv->nClocks);
  80102c:	a1 20 60 80 00       	mov    0x806020,%eax
  801031:	8b 80 ac 05 00 00    	mov    0x5ac(%eax),%eax
  801037:	83 ec 08             	sub    $0x8,%esp
  80103a:	50                   	push   %eax
  80103b:	68 40 48 80 00       	push   $0x804840
  801040:	e8 01 03 00 00       	call   801346 <cprintf>
  801045:	83 c4 10             	add    $0x10,%esp
		cprintf("**************************************\n");
  801048:	83 ec 0c             	sub    $0xc,%esp
  80104b:	68 98 47 80 00       	push   $0x804798
  801050:	e8 f1 02 00 00       	call   801346 <cprintf>
  801055:	83 c4 10             	add    $0x10,%esp
	}
	sys_unlock_cons();
  801058:	e8 34 12 00 00       	call   802291 <sys_unlock_cons>
//	sys_unlock_cons();

	// exit gracefully
	exit();
  80105d:	e8 19 00 00 00       	call   80107b <exit>
}
  801062:	90                   	nop
  801063:	c9                   	leave  
  801064:	c3                   	ret    

00801065 <destroy>:

#include <inc/lib.h>

void
destroy(void)
{
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
  801068:	83 ec 08             	sub    $0x8,%esp
	sys_destroy_env(0);
  80106b:	83 ec 0c             	sub    $0xc,%esp
  80106e:	6a 00                	push   $0x0
  801070:	e8 4a 14 00 00       	call   8024bf <sys_destroy_env>
  801075:	83 c4 10             	add    $0x10,%esp
}
  801078:	90                   	nop
  801079:	c9                   	leave  
  80107a:	c3                   	ret    

0080107b <exit>:

void
exit(void)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
  80107e:	83 ec 08             	sub    $0x8,%esp
	sys_exit_env();
  801081:	e8 9f 14 00 00       	call   802525 <sys_exit_env>
}
  801086:	90                   	nop
  801087:	c9                   	leave  
  801088:	c3                   	ret    

00801089 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes FOS to enter the FOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	va_start(ap, fmt);
  80108f:	8d 45 10             	lea    0x10(%ebp),%eax
  801092:	83 c0 04             	add    $0x4,%eax
  801095:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// Print the panic message
	if (argv0)
  801098:	a1 4c a2 80 00       	mov    0x80a24c,%eax
  80109d:	85 c0                	test   %eax,%eax
  80109f:	74 16                	je     8010b7 <_panic+0x2e>
		cprintf("%s: ", argv0);
  8010a1:	a1 4c a2 80 00       	mov    0x80a24c,%eax
  8010a6:	83 ec 08             	sub    $0x8,%esp
  8010a9:	50                   	push   %eax
  8010aa:	68 54 48 80 00       	push   $0x804854
  8010af:	e8 92 02 00 00       	call   801346 <cprintf>
  8010b4:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8010b7:	a1 1c 60 80 00       	mov    0x80601c,%eax
  8010bc:	ff 75 0c             	pushl  0xc(%ebp)
  8010bf:	ff 75 08             	pushl  0x8(%ebp)
  8010c2:	50                   	push   %eax
  8010c3:	68 59 48 80 00       	push   $0x804859
  8010c8:	e8 79 02 00 00       	call   801346 <cprintf>
  8010cd:	83 c4 10             	add    $0x10,%esp
	vcprintf(fmt, ap);
  8010d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8010d3:	83 ec 08             	sub    $0x8,%esp
  8010d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8010d9:	50                   	push   %eax
  8010da:	e8 fc 01 00 00       	call   8012db <vcprintf>
  8010df:	83 c4 10             	add    $0x10,%esp
	vcprintf("\n", NULL);
  8010e2:	83 ec 08             	sub    $0x8,%esp
  8010e5:	6a 00                	push   $0x0
  8010e7:	68 75 48 80 00       	push   $0x804875
  8010ec:	e8 ea 01 00 00       	call   8012db <vcprintf>
  8010f1:	83 c4 10             	add    $0x10,%esp
	// Cause a breakpoint exception
//	while (1);
//		asm volatile("int3");

	//2013: exit the panic env only
	exit() ;
  8010f4:	e8 82 ff ff ff       	call   80107b <exit>

	// should not return here
	while (1) ;
  8010f9:	eb fe                	jmp    8010f9 <_panic+0x70>

008010fb <CheckWSArrayWithoutLastIndex>:
}

void CheckWSArrayWithoutLastIndex(uint32 *expectedPages, int arraySize)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	83 ec 28             	sub    $0x28,%esp
	if (arraySize != myEnv->page_WS_max_size)
  801101:	a1 20 60 80 00       	mov    0x806020,%eax
  801106:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
  80110c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80110f:	39 c2                	cmp    %eax,%edx
  801111:	74 14                	je     801127 <CheckWSArrayWithoutLastIndex+0x2c>
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
  801113:	83 ec 04             	sub    $0x4,%esp
  801116:	68 78 48 80 00       	push   $0x804878
  80111b:	6a 26                	push   $0x26
  80111d:	68 c4 48 80 00       	push   $0x8048c4
  801122:	e8 62 ff ff ff       	call   801089 <_panic>
	}
	int expectedNumOfEmptyLocs = 0;
  801127:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	for (int e = 0; e < arraySize; e++) {
  80112e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801135:	e9 c5 00 00 00       	jmp    8011ff <CheckWSArrayWithoutLastIndex+0x104>
		if (expectedPages[e] == 0) {
  80113a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80113d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801144:	8b 45 08             	mov    0x8(%ebp),%eax
  801147:	01 d0                	add    %edx,%eax
  801149:	8b 00                	mov    (%eax),%eax
  80114b:	85 c0                	test   %eax,%eax
  80114d:	75 08                	jne    801157 <CheckWSArrayWithoutLastIndex+0x5c>
			expectedNumOfEmptyLocs++;
  80114f:	ff 45 f4             	incl   -0xc(%ebp)
			continue;
  801152:	e9 a5 00 00 00       	jmp    8011fc <CheckWSArrayWithoutLastIndex+0x101>
		}
		int found = 0;
  801157:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  80115e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  801165:	eb 69                	jmp    8011d0 <CheckWSArrayWithoutLastIndex+0xd5>
			if (myEnv->__uptr_pws[w].empty == 0) {
  801167:	a1 20 60 80 00       	mov    0x806020,%eax
  80116c:	8b 88 7c 05 00 00    	mov    0x57c(%eax),%ecx
  801172:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801175:	89 d0                	mov    %edx,%eax
  801177:	01 c0                	add    %eax,%eax
  801179:	01 d0                	add    %edx,%eax
  80117b:	c1 e0 03             	shl    $0x3,%eax
  80117e:	01 c8                	add    %ecx,%eax
  801180:	8a 40 04             	mov    0x4(%eax),%al
  801183:	84 c0                	test   %al,%al
  801185:	75 46                	jne    8011cd <CheckWSArrayWithoutLastIndex+0xd2>
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  801187:	a1 20 60 80 00       	mov    0x806020,%eax
  80118c:	8b 88 7c 05 00 00    	mov    0x57c(%eax),%ecx
  801192:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801195:	89 d0                	mov    %edx,%eax
  801197:	01 c0                	add    %eax,%eax
  801199:	01 d0                	add    %edx,%eax
  80119b:	c1 e0 03             	shl    $0x3,%eax
  80119e:	01 c8                	add    %ecx,%eax
  8011a0:	8b 00                	mov    (%eax),%eax
  8011a2:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8011a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011ad:	89 c2                	mov    %eax,%edx
						== expectedPages[e]) {
  8011af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b2:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8011b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011bc:	01 c8                	add    %ecx,%eax
  8011be:	8b 00                	mov    (%eax),%eax
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
			if (myEnv->__uptr_pws[w].empty == 0) {
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  8011c0:	39 c2                	cmp    %eax,%edx
  8011c2:	75 09                	jne    8011cd <CheckWSArrayWithoutLastIndex+0xd2>
						== expectedPages[e]) {
					found = 1;
  8011c4:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
					break;
  8011cb:	eb 15                	jmp    8011e2 <CheckWSArrayWithoutLastIndex+0xe7>
		if (expectedPages[e] == 0) {
			expectedNumOfEmptyLocs++;
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  8011cd:	ff 45 e8             	incl   -0x18(%ebp)
  8011d0:	a1 20 60 80 00       	mov    0x806020,%eax
  8011d5:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
  8011db:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8011de:	39 c2                	cmp    %eax,%edx
  8011e0:	77 85                	ja     801167 <CheckWSArrayWithoutLastIndex+0x6c>
					found = 1;
					break;
				}
			}
		}
		if (!found)
  8011e2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8011e6:	75 14                	jne    8011fc <CheckWSArrayWithoutLastIndex+0x101>
			panic(
  8011e8:	83 ec 04             	sub    $0x4,%esp
  8011eb:	68 d0 48 80 00       	push   $0x8048d0
  8011f0:	6a 3a                	push   $0x3a
  8011f2:	68 c4 48 80 00       	push   $0x8048c4
  8011f7:	e8 8d fe ff ff       	call   801089 <_panic>
	if (arraySize != myEnv->page_WS_max_size)
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
	}
	int expectedNumOfEmptyLocs = 0;
	for (int e = 0; e < arraySize; e++) {
  8011fc:	ff 45 f0             	incl   -0x10(%ebp)
  8011ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801202:	3b 45 0c             	cmp    0xc(%ebp),%eax
  801205:	0f 8c 2f ff ff ff    	jl     80113a <CheckWSArrayWithoutLastIndex+0x3f>
		}
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
  80120b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  801212:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801219:	eb 26                	jmp    801241 <CheckWSArrayWithoutLastIndex+0x146>
		if (myEnv->__uptr_pws[w].empty == 1) {
  80121b:	a1 20 60 80 00       	mov    0x806020,%eax
  801220:	8b 88 7c 05 00 00    	mov    0x57c(%eax),%ecx
  801226:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801229:	89 d0                	mov    %edx,%eax
  80122b:	01 c0                	add    %eax,%eax
  80122d:	01 d0                	add    %edx,%eax
  80122f:	c1 e0 03             	shl    $0x3,%eax
  801232:	01 c8                	add    %ecx,%eax
  801234:	8a 40 04             	mov    0x4(%eax),%al
  801237:	3c 01                	cmp    $0x1,%al
  801239:	75 03                	jne    80123e <CheckWSArrayWithoutLastIndex+0x143>
			actualNumOfEmptyLocs++;
  80123b:	ff 45 e4             	incl   -0x1c(%ebp)
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  80123e:	ff 45 e0             	incl   -0x20(%ebp)
  801241:	a1 20 60 80 00       	mov    0x806020,%eax
  801246:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
  80124c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80124f:	39 c2                	cmp    %eax,%edx
  801251:	77 c8                	ja     80121b <CheckWSArrayWithoutLastIndex+0x120>
		if (myEnv->__uptr_pws[w].empty == 1) {
			actualNumOfEmptyLocs++;
		}
	}
	if (expectedNumOfEmptyLocs != actualNumOfEmptyLocs)
  801253:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801256:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  801259:	74 14                	je     80126f <CheckWSArrayWithoutLastIndex+0x174>
		panic(
  80125b:	83 ec 04             	sub    $0x4,%esp
  80125e:	68 24 49 80 00       	push   $0x804924
  801263:	6a 44                	push   $0x44
  801265:	68 c4 48 80 00       	push   $0x8048c4
  80126a:	e8 1a fe ff ff       	call   801089 <_panic>
				"PAGE WS entry checking failed... number of empty locations is not correct");
}
  80126f:	90                   	nop
  801270:	c9                   	leave  
  801271:	c3                   	ret    

00801272 <putch>:
	int idx; // current buffer index
	int cnt; // total bytes printed so far
	char buf[256];
};

static void putch(int ch, struct printbuf *b) {
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	83 ec 08             	sub    $0x8,%esp
	b->buf[b->idx++] = ch;
  801278:	8b 45 0c             	mov    0xc(%ebp),%eax
  80127b:	8b 00                	mov    (%eax),%eax
  80127d:	8d 48 01             	lea    0x1(%eax),%ecx
  801280:	8b 55 0c             	mov    0xc(%ebp),%edx
  801283:	89 0a                	mov    %ecx,(%edx)
  801285:	8b 55 08             	mov    0x8(%ebp),%edx
  801288:	88 d1                	mov    %dl,%cl
  80128a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80128d:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256 - 1) {
  801291:	8b 45 0c             	mov    0xc(%ebp),%eax
  801294:	8b 00                	mov    (%eax),%eax
  801296:	3d ff 00 00 00       	cmp    $0xff,%eax
  80129b:	75 2c                	jne    8012c9 <putch+0x57>
		sys_cputs(b->buf, b->idx, printProgName);
  80129d:	a0 40 60 80 00       	mov    0x806040,%al
  8012a2:	0f b6 c0             	movzbl %al,%eax
  8012a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a8:	8b 12                	mov    (%edx),%edx
  8012aa:	89 d1                	mov    %edx,%ecx
  8012ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012af:	83 c2 08             	add    $0x8,%edx
  8012b2:	83 ec 04             	sub    $0x4,%esp
  8012b5:	50                   	push   %eax
  8012b6:	51                   	push   %ecx
  8012b7:	52                   	push   %edx
  8012b8:	e8 78 0f 00 00       	call   802235 <sys_cputs>
  8012bd:	83 c4 10             	add    $0x10,%esp
		b->idx = 0;
  8012c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8012c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012cc:	8b 40 04             	mov    0x4(%eax),%eax
  8012cf:	8d 50 01             	lea    0x1(%eax),%edx
  8012d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012d5:	89 50 04             	mov    %edx,0x4(%eax)
}
  8012d8:	90                   	nop
  8012d9:	c9                   	leave  
  8012da:	c3                   	ret    

008012db <vcprintf>:

int vcprintf(const char *fmt, va_list ap) {
  8012db:	55                   	push   %ebp
  8012dc:	89 e5                	mov    %esp,%ebp
  8012de:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8012e4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8012eb:	00 00 00 
	b.cnt = 0;
  8012ee:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8012f5:	00 00 00 
	vprintfmt((void*) putch, &b, fmt, ap);
  8012f8:	ff 75 0c             	pushl  0xc(%ebp)
  8012fb:	ff 75 08             	pushl  0x8(%ebp)
  8012fe:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801304:	50                   	push   %eax
  801305:	68 72 12 80 00       	push   $0x801272
  80130a:	e8 11 02 00 00       	call   801520 <vprintfmt>
  80130f:	83 c4 10             	add    $0x10,%esp
	sys_cputs(b.buf, b.idx, printProgName);
  801312:	a0 40 60 80 00       	mov    0x806040,%al
  801317:	0f b6 c0             	movzbl %al,%eax
  80131a:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
  801320:	83 ec 04             	sub    $0x4,%esp
  801323:	50                   	push   %eax
  801324:	52                   	push   %edx
  801325:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80132b:	83 c0 08             	add    $0x8,%eax
  80132e:	50                   	push   %eax
  80132f:	e8 01 0f 00 00       	call   802235 <sys_cputs>
  801334:	83 c4 10             	add    $0x10,%esp

	printProgName = 0;
  801337:	c6 05 40 60 80 00 00 	movb   $0x0,0x806040
	return b.cnt;
  80133e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801344:	c9                   	leave  
  801345:	c3                   	ret    

00801346 <cprintf>:

//%@: to print the program name and ID before the message
//%~: to print the message directly
int cprintf(const char *fmt, ...) {
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;
	printProgName = 1 ;
  80134c:	c6 05 40 60 80 00 01 	movb   $0x1,0x806040
	va_start(ap, fmt);
  801353:	8d 45 0c             	lea    0xc(%ebp),%eax
  801356:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
  801359:	8b 45 08             	mov    0x8(%ebp),%eax
  80135c:	83 ec 08             	sub    $0x8,%esp
  80135f:	ff 75 f4             	pushl  -0xc(%ebp)
  801362:	50                   	push   %eax
  801363:	e8 73 ff ff ff       	call   8012db <vcprintf>
  801368:	83 c4 10             	add    $0x10,%esp
  80136b:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return cnt;
  80136e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  801371:	c9                   	leave  
  801372:	c3                   	ret    

00801373 <atomic_cprintf>:

//%@: to print the program name and ID before the message
//%~: to print the message directly
int atomic_cprintf(const char *fmt, ...)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	83 ec 18             	sub    $0x18,%esp
	int cnt;
	sys_lock_cons();
  801379:	e8 f9 0e 00 00       	call   802277 <sys_lock_cons>
	{
		va_list ap;
		va_start(ap, fmt);
  80137e:	8d 45 0c             	lea    0xc(%ebp),%eax
  801381:	89 45 f4             	mov    %eax,-0xc(%ebp)
		cnt = vcprintf(fmt, ap);
  801384:	8b 45 08             	mov    0x8(%ebp),%eax
  801387:	83 ec 08             	sub    $0x8,%esp
  80138a:	ff 75 f4             	pushl  -0xc(%ebp)
  80138d:	50                   	push   %eax
  80138e:	e8 48 ff ff ff       	call   8012db <vcprintf>
  801393:	83 c4 10             	add    $0x10,%esp
  801396:	89 45 f0             	mov    %eax,-0x10(%ebp)
		va_end(ap);
	}
	sys_unlock_cons();
  801399:	e8 f3 0e 00 00       	call   802291 <sys_unlock_cons>
	return cnt;
  80139e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8013a1:	c9                   	leave  
  8013a2:	c3                   	ret    

008013a3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	53                   	push   %ebx
  8013a7:	83 ec 14             	sub    $0x14,%esp
  8013aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8013ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8013b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8013b6:	8b 45 18             	mov    0x18(%ebp),%eax
  8013b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013be:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8013c1:	77 55                	ja     801418 <printnum+0x75>
  8013c3:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8013c6:	72 05                	jb     8013cd <printnum+0x2a>
  8013c8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8013cb:	77 4b                	ja     801418 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8013cd:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8013d0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8013d3:	8b 45 18             	mov    0x18(%ebp),%eax
  8013d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013db:	52                   	push   %edx
  8013dc:	50                   	push   %eax
  8013dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8013e0:	ff 75 f0             	pushl  -0x10(%ebp)
  8013e3:	e8 c4 28 00 00       	call   803cac <__udivdi3>
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	83 ec 04             	sub    $0x4,%esp
  8013ee:	ff 75 20             	pushl  0x20(%ebp)
  8013f1:	53                   	push   %ebx
  8013f2:	ff 75 18             	pushl  0x18(%ebp)
  8013f5:	52                   	push   %edx
  8013f6:	50                   	push   %eax
  8013f7:	ff 75 0c             	pushl  0xc(%ebp)
  8013fa:	ff 75 08             	pushl  0x8(%ebp)
  8013fd:	e8 a1 ff ff ff       	call   8013a3 <printnum>
  801402:	83 c4 20             	add    $0x20,%esp
  801405:	eb 1a                	jmp    801421 <printnum+0x7e>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801407:	83 ec 08             	sub    $0x8,%esp
  80140a:	ff 75 0c             	pushl  0xc(%ebp)
  80140d:	ff 75 20             	pushl  0x20(%ebp)
  801410:	8b 45 08             	mov    0x8(%ebp),%eax
  801413:	ff d0                	call   *%eax
  801415:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801418:	ff 4d 1c             	decl   0x1c(%ebp)
  80141b:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  80141f:	7f e6                	jg     801407 <printnum+0x64>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801421:	8b 4d 18             	mov    0x18(%ebp),%ecx
  801424:	bb 00 00 00 00       	mov    $0x0,%ebx
  801429:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80142f:	53                   	push   %ebx
  801430:	51                   	push   %ecx
  801431:	52                   	push   %edx
  801432:	50                   	push   %eax
  801433:	e8 84 29 00 00       	call   803dbc <__umoddi3>
  801438:	83 c4 10             	add    $0x10,%esp
  80143b:	05 94 4b 80 00       	add    $0x804b94,%eax
  801440:	8a 00                	mov    (%eax),%al
  801442:	0f be c0             	movsbl %al,%eax
  801445:	83 ec 08             	sub    $0x8,%esp
  801448:	ff 75 0c             	pushl  0xc(%ebp)
  80144b:	50                   	push   %eax
  80144c:	8b 45 08             	mov    0x8(%ebp),%eax
  80144f:	ff d0                	call   *%eax
  801451:	83 c4 10             	add    $0x10,%esp
}
  801454:	90                   	nop
  801455:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801458:	c9                   	leave  
  801459:	c3                   	ret    

0080145a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80145d:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801461:	7e 1c                	jle    80147f <getuint+0x25>
		return va_arg(*ap, unsigned long long);
  801463:	8b 45 08             	mov    0x8(%ebp),%eax
  801466:	8b 00                	mov    (%eax),%eax
  801468:	8d 50 08             	lea    0x8(%eax),%edx
  80146b:	8b 45 08             	mov    0x8(%ebp),%eax
  80146e:	89 10                	mov    %edx,(%eax)
  801470:	8b 45 08             	mov    0x8(%ebp),%eax
  801473:	8b 00                	mov    (%eax),%eax
  801475:	83 e8 08             	sub    $0x8,%eax
  801478:	8b 50 04             	mov    0x4(%eax),%edx
  80147b:	8b 00                	mov    (%eax),%eax
  80147d:	eb 40                	jmp    8014bf <getuint+0x65>
	else if (lflag)
  80147f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801483:	74 1e                	je     8014a3 <getuint+0x49>
		return va_arg(*ap, unsigned long);
  801485:	8b 45 08             	mov    0x8(%ebp),%eax
  801488:	8b 00                	mov    (%eax),%eax
  80148a:	8d 50 04             	lea    0x4(%eax),%edx
  80148d:	8b 45 08             	mov    0x8(%ebp),%eax
  801490:	89 10                	mov    %edx,(%eax)
  801492:	8b 45 08             	mov    0x8(%ebp),%eax
  801495:	8b 00                	mov    (%eax),%eax
  801497:	83 e8 04             	sub    $0x4,%eax
  80149a:	8b 00                	mov    (%eax),%eax
  80149c:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a1:	eb 1c                	jmp    8014bf <getuint+0x65>
	else
		return va_arg(*ap, unsigned int);
  8014a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a6:	8b 00                	mov    (%eax),%eax
  8014a8:	8d 50 04             	lea    0x4(%eax),%edx
  8014ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ae:	89 10                	mov    %edx,(%eax)
  8014b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b3:	8b 00                	mov    (%eax),%eax
  8014b5:	83 e8 04             	sub    $0x4,%eax
  8014b8:	8b 00                	mov    (%eax),%eax
  8014ba:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8014bf:	5d                   	pop    %ebp
  8014c0:	c3                   	ret    

008014c1 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8014c4:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8014c8:	7e 1c                	jle    8014e6 <getint+0x25>
		return va_arg(*ap, long long);
  8014ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8014cd:	8b 00                	mov    (%eax),%eax
  8014cf:	8d 50 08             	lea    0x8(%eax),%edx
  8014d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d5:	89 10                	mov    %edx,(%eax)
  8014d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014da:	8b 00                	mov    (%eax),%eax
  8014dc:	83 e8 08             	sub    $0x8,%eax
  8014df:	8b 50 04             	mov    0x4(%eax),%edx
  8014e2:	8b 00                	mov    (%eax),%eax
  8014e4:	eb 38                	jmp    80151e <getint+0x5d>
	else if (lflag)
  8014e6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8014ea:	74 1a                	je     801506 <getint+0x45>
		return va_arg(*ap, long);
  8014ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ef:	8b 00                	mov    (%eax),%eax
  8014f1:	8d 50 04             	lea    0x4(%eax),%edx
  8014f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f7:	89 10                	mov    %edx,(%eax)
  8014f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fc:	8b 00                	mov    (%eax),%eax
  8014fe:	83 e8 04             	sub    $0x4,%eax
  801501:	8b 00                	mov    (%eax),%eax
  801503:	99                   	cltd   
  801504:	eb 18                	jmp    80151e <getint+0x5d>
	else
		return va_arg(*ap, int);
  801506:	8b 45 08             	mov    0x8(%ebp),%eax
  801509:	8b 00                	mov    (%eax),%eax
  80150b:	8d 50 04             	lea    0x4(%eax),%edx
  80150e:	8b 45 08             	mov    0x8(%ebp),%eax
  801511:	89 10                	mov    %edx,(%eax)
  801513:	8b 45 08             	mov    0x8(%ebp),%eax
  801516:	8b 00                	mov    (%eax),%eax
  801518:	83 e8 04             	sub    $0x4,%eax
  80151b:	8b 00                	mov    (%eax),%eax
  80151d:	99                   	cltd   
}
  80151e:	5d                   	pop    %ebp
  80151f:	c3                   	ret    

00801520 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
  801523:	56                   	push   %esi
  801524:	53                   	push   %ebx
  801525:	83 ec 20             	sub    $0x20,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801528:	eb 17                	jmp    801541 <vprintfmt+0x21>
			if (ch == '\0')
  80152a:	85 db                	test   %ebx,%ebx
  80152c:	0f 84 c1 03 00 00    	je     8018f3 <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  801532:	83 ec 08             	sub    $0x8,%esp
  801535:	ff 75 0c             	pushl  0xc(%ebp)
  801538:	53                   	push   %ebx
  801539:	8b 45 08             	mov    0x8(%ebp),%eax
  80153c:	ff d0                	call   *%eax
  80153e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801541:	8b 45 10             	mov    0x10(%ebp),%eax
  801544:	8d 50 01             	lea    0x1(%eax),%edx
  801547:	89 55 10             	mov    %edx,0x10(%ebp)
  80154a:	8a 00                	mov    (%eax),%al
  80154c:	0f b6 d8             	movzbl %al,%ebx
  80154f:	83 fb 25             	cmp    $0x25,%ebx
  801552:	75 d6                	jne    80152a <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  801554:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  801558:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  80155f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801566:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80156d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801574:	8b 45 10             	mov    0x10(%ebp),%eax
  801577:	8d 50 01             	lea    0x1(%eax),%edx
  80157a:	89 55 10             	mov    %edx,0x10(%ebp)
  80157d:	8a 00                	mov    (%eax),%al
  80157f:	0f b6 d8             	movzbl %al,%ebx
  801582:	8d 43 dd             	lea    -0x23(%ebx),%eax
  801585:	83 f8 5b             	cmp    $0x5b,%eax
  801588:	0f 87 3d 03 00 00    	ja     8018cb <vprintfmt+0x3ab>
  80158e:	8b 04 85 b8 4b 80 00 	mov    0x804bb8(,%eax,4),%eax
  801595:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  801597:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80159b:	eb d7                	jmp    801574 <vprintfmt+0x54>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80159d:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8015a1:	eb d1                	jmp    801574 <vprintfmt+0x54>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8015a3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8015aa:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8015ad:	89 d0                	mov    %edx,%eax
  8015af:	c1 e0 02             	shl    $0x2,%eax
  8015b2:	01 d0                	add    %edx,%eax
  8015b4:	01 c0                	add    %eax,%eax
  8015b6:	01 d8                	add    %ebx,%eax
  8015b8:	83 e8 30             	sub    $0x30,%eax
  8015bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8015be:	8b 45 10             	mov    0x10(%ebp),%eax
  8015c1:	8a 00                	mov    (%eax),%al
  8015c3:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8015c6:	83 fb 2f             	cmp    $0x2f,%ebx
  8015c9:	7e 3e                	jle    801609 <vprintfmt+0xe9>
  8015cb:	83 fb 39             	cmp    $0x39,%ebx
  8015ce:	7f 39                	jg     801609 <vprintfmt+0xe9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8015d0:	ff 45 10             	incl   0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8015d3:	eb d5                	jmp    8015aa <vprintfmt+0x8a>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8015d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d8:	83 c0 04             	add    $0x4,%eax
  8015db:	89 45 14             	mov    %eax,0x14(%ebp)
  8015de:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e1:	83 e8 04             	sub    $0x4,%eax
  8015e4:	8b 00                	mov    (%eax),%eax
  8015e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8015e9:	eb 1f                	jmp    80160a <vprintfmt+0xea>

		case '.':
			if (width < 0)
  8015eb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8015ef:	79 83                	jns    801574 <vprintfmt+0x54>
				width = 0;
  8015f1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8015f8:	e9 77 ff ff ff       	jmp    801574 <vprintfmt+0x54>

		case '#':
			altflag = 1;
  8015fd:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  801604:	e9 6b ff ff ff       	jmp    801574 <vprintfmt+0x54>
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto process_precision;
  801609:	90                   	nop
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80160a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80160e:	0f 89 60 ff ff ff    	jns    801574 <vprintfmt+0x54>
				width = precision, precision = -1;
  801614:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801617:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80161a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  801621:	e9 4e ff ff ff       	jmp    801574 <vprintfmt+0x54>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801626:	ff 45 e8             	incl   -0x18(%ebp)
			goto reswitch;
  801629:	e9 46 ff ff ff       	jmp    801574 <vprintfmt+0x54>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80162e:	8b 45 14             	mov    0x14(%ebp),%eax
  801631:	83 c0 04             	add    $0x4,%eax
  801634:	89 45 14             	mov    %eax,0x14(%ebp)
  801637:	8b 45 14             	mov    0x14(%ebp),%eax
  80163a:	83 e8 04             	sub    $0x4,%eax
  80163d:	8b 00                	mov    (%eax),%eax
  80163f:	83 ec 08             	sub    $0x8,%esp
  801642:	ff 75 0c             	pushl  0xc(%ebp)
  801645:	50                   	push   %eax
  801646:	8b 45 08             	mov    0x8(%ebp),%eax
  801649:	ff d0                	call   *%eax
  80164b:	83 c4 10             	add    $0x10,%esp
			break;
  80164e:	e9 9b 02 00 00       	jmp    8018ee <vprintfmt+0x3ce>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801653:	8b 45 14             	mov    0x14(%ebp),%eax
  801656:	83 c0 04             	add    $0x4,%eax
  801659:	89 45 14             	mov    %eax,0x14(%ebp)
  80165c:	8b 45 14             	mov    0x14(%ebp),%eax
  80165f:	83 e8 04             	sub    $0x4,%eax
  801662:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  801664:	85 db                	test   %ebx,%ebx
  801666:	79 02                	jns    80166a <vprintfmt+0x14a>
				err = -err;
  801668:	f7 db                	neg    %ebx
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  80166a:	83 fb 64             	cmp    $0x64,%ebx
  80166d:	7f 0b                	jg     80167a <vprintfmt+0x15a>
  80166f:	8b 34 9d 00 4a 80 00 	mov    0x804a00(,%ebx,4),%esi
  801676:	85 f6                	test   %esi,%esi
  801678:	75 19                	jne    801693 <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  80167a:	53                   	push   %ebx
  80167b:	68 a5 4b 80 00       	push   $0x804ba5
  801680:	ff 75 0c             	pushl  0xc(%ebp)
  801683:	ff 75 08             	pushl  0x8(%ebp)
  801686:	e8 70 02 00 00       	call   8018fb <printfmt>
  80168b:	83 c4 10             	add    $0x10,%esp
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80168e:	e9 5b 02 00 00       	jmp    8018ee <vprintfmt+0x3ce>
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  801693:	56                   	push   %esi
  801694:	68 ae 4b 80 00       	push   $0x804bae
  801699:	ff 75 0c             	pushl  0xc(%ebp)
  80169c:	ff 75 08             	pushl  0x8(%ebp)
  80169f:	e8 57 02 00 00       	call   8018fb <printfmt>
  8016a4:	83 c4 10             	add    $0x10,%esp
			break;
  8016a7:	e9 42 02 00 00       	jmp    8018ee <vprintfmt+0x3ce>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8016ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8016af:	83 c0 04             	add    $0x4,%eax
  8016b2:	89 45 14             	mov    %eax,0x14(%ebp)
  8016b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8016b8:	83 e8 04             	sub    $0x4,%eax
  8016bb:	8b 30                	mov    (%eax),%esi
  8016bd:	85 f6                	test   %esi,%esi
  8016bf:	75 05                	jne    8016c6 <vprintfmt+0x1a6>
				p = "(null)";
  8016c1:	be b1 4b 80 00       	mov    $0x804bb1,%esi
			if (width > 0 && padc != '-')
  8016c6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8016ca:	7e 6d                	jle    801739 <vprintfmt+0x219>
  8016cc:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8016d0:	74 67                	je     801739 <vprintfmt+0x219>
				for (width -= strnlen(p, precision); width > 0; width--)
  8016d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016d5:	83 ec 08             	sub    $0x8,%esp
  8016d8:	50                   	push   %eax
  8016d9:	56                   	push   %esi
  8016da:	e8 1e 03 00 00       	call   8019fd <strnlen>
  8016df:	83 c4 10             	add    $0x10,%esp
  8016e2:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8016e5:	eb 16                	jmp    8016fd <vprintfmt+0x1dd>
					putch(padc, putdat);
  8016e7:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8016eb:	83 ec 08             	sub    $0x8,%esp
  8016ee:	ff 75 0c             	pushl  0xc(%ebp)
  8016f1:	50                   	push   %eax
  8016f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f5:	ff d0                	call   *%eax
  8016f7:	83 c4 10             	add    $0x10,%esp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8016fa:	ff 4d e4             	decl   -0x1c(%ebp)
  8016fd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801701:	7f e4                	jg     8016e7 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801703:	eb 34                	jmp    801739 <vprintfmt+0x219>
				if (altflag && (ch < ' ' || ch > '~'))
  801705:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801709:	74 1c                	je     801727 <vprintfmt+0x207>
  80170b:	83 fb 1f             	cmp    $0x1f,%ebx
  80170e:	7e 05                	jle    801715 <vprintfmt+0x1f5>
  801710:	83 fb 7e             	cmp    $0x7e,%ebx
  801713:	7e 12                	jle    801727 <vprintfmt+0x207>
					putch('?', putdat);
  801715:	83 ec 08             	sub    $0x8,%esp
  801718:	ff 75 0c             	pushl  0xc(%ebp)
  80171b:	6a 3f                	push   $0x3f
  80171d:	8b 45 08             	mov    0x8(%ebp),%eax
  801720:	ff d0                	call   *%eax
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	eb 0f                	jmp    801736 <vprintfmt+0x216>
				else
					putch(ch, putdat);
  801727:	83 ec 08             	sub    $0x8,%esp
  80172a:	ff 75 0c             	pushl  0xc(%ebp)
  80172d:	53                   	push   %ebx
  80172e:	8b 45 08             	mov    0x8(%ebp),%eax
  801731:	ff d0                	call   *%eax
  801733:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801736:	ff 4d e4             	decl   -0x1c(%ebp)
  801739:	89 f0                	mov    %esi,%eax
  80173b:	8d 70 01             	lea    0x1(%eax),%esi
  80173e:	8a 00                	mov    (%eax),%al
  801740:	0f be d8             	movsbl %al,%ebx
  801743:	85 db                	test   %ebx,%ebx
  801745:	74 24                	je     80176b <vprintfmt+0x24b>
  801747:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80174b:	78 b8                	js     801705 <vprintfmt+0x1e5>
  80174d:	ff 4d e0             	decl   -0x20(%ebp)
  801750:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801754:	79 af                	jns    801705 <vprintfmt+0x1e5>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801756:	eb 13                	jmp    80176b <vprintfmt+0x24b>
				putch(' ', putdat);
  801758:	83 ec 08             	sub    $0x8,%esp
  80175b:	ff 75 0c             	pushl  0xc(%ebp)
  80175e:	6a 20                	push   $0x20
  801760:	8b 45 08             	mov    0x8(%ebp),%eax
  801763:	ff d0                	call   *%eax
  801765:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801768:	ff 4d e4             	decl   -0x1c(%ebp)
  80176b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80176f:	7f e7                	jg     801758 <vprintfmt+0x238>
				putch(' ', putdat);
			break;
  801771:	e9 78 01 00 00       	jmp    8018ee <vprintfmt+0x3ce>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801776:	83 ec 08             	sub    $0x8,%esp
  801779:	ff 75 e8             	pushl  -0x18(%ebp)
  80177c:	8d 45 14             	lea    0x14(%ebp),%eax
  80177f:	50                   	push   %eax
  801780:	e8 3c fd ff ff       	call   8014c1 <getint>
  801785:	83 c4 10             	add    $0x10,%esp
  801788:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80178b:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  80178e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801791:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801794:	85 d2                	test   %edx,%edx
  801796:	79 23                	jns    8017bb <vprintfmt+0x29b>
				putch('-', putdat);
  801798:	83 ec 08             	sub    $0x8,%esp
  80179b:	ff 75 0c             	pushl  0xc(%ebp)
  80179e:	6a 2d                	push   $0x2d
  8017a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a3:	ff d0                	call   *%eax
  8017a5:	83 c4 10             	add    $0x10,%esp
				num = -(long long) num;
  8017a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ae:	f7 d8                	neg    %eax
  8017b0:	83 d2 00             	adc    $0x0,%edx
  8017b3:	f7 da                	neg    %edx
  8017b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8017b8:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8017bb:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8017c2:	e9 bc 00 00 00       	jmp    801883 <vprintfmt+0x363>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8017c7:	83 ec 08             	sub    $0x8,%esp
  8017ca:	ff 75 e8             	pushl  -0x18(%ebp)
  8017cd:	8d 45 14             	lea    0x14(%ebp),%eax
  8017d0:	50                   	push   %eax
  8017d1:	e8 84 fc ff ff       	call   80145a <getuint>
  8017d6:	83 c4 10             	add    $0x10,%esp
  8017d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8017dc:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8017df:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8017e6:	e9 98 00 00 00       	jmp    801883 <vprintfmt+0x363>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8017eb:	83 ec 08             	sub    $0x8,%esp
  8017ee:	ff 75 0c             	pushl  0xc(%ebp)
  8017f1:	6a 58                	push   $0x58
  8017f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f6:	ff d0                	call   *%eax
  8017f8:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  8017fb:	83 ec 08             	sub    $0x8,%esp
  8017fe:	ff 75 0c             	pushl  0xc(%ebp)
  801801:	6a 58                	push   $0x58
  801803:	8b 45 08             	mov    0x8(%ebp),%eax
  801806:	ff d0                	call   *%eax
  801808:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  80180b:	83 ec 08             	sub    $0x8,%esp
  80180e:	ff 75 0c             	pushl  0xc(%ebp)
  801811:	6a 58                	push   $0x58
  801813:	8b 45 08             	mov    0x8(%ebp),%eax
  801816:	ff d0                	call   *%eax
  801818:	83 c4 10             	add    $0x10,%esp
			break;
  80181b:	e9 ce 00 00 00       	jmp    8018ee <vprintfmt+0x3ce>

		// pointer
		case 'p':
			putch('0', putdat);
  801820:	83 ec 08             	sub    $0x8,%esp
  801823:	ff 75 0c             	pushl  0xc(%ebp)
  801826:	6a 30                	push   $0x30
  801828:	8b 45 08             	mov    0x8(%ebp),%eax
  80182b:	ff d0                	call   *%eax
  80182d:	83 c4 10             	add    $0x10,%esp
			putch('x', putdat);
  801830:	83 ec 08             	sub    $0x8,%esp
  801833:	ff 75 0c             	pushl  0xc(%ebp)
  801836:	6a 78                	push   $0x78
  801838:	8b 45 08             	mov    0x8(%ebp),%eax
  80183b:	ff d0                	call   *%eax
  80183d:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)
				(uint32) va_arg(ap, void *);
  801840:	8b 45 14             	mov    0x14(%ebp),%eax
  801843:	83 c0 04             	add    $0x4,%eax
  801846:	89 45 14             	mov    %eax,0x14(%ebp)
  801849:	8b 45 14             	mov    0x14(%ebp),%eax
  80184c:	83 e8 04             	sub    $0x4,%eax
  80184f:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801851:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801854:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uint32) va_arg(ap, void *);
			base = 16;
  80185b:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  801862:	eb 1f                	jmp    801883 <vprintfmt+0x363>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801864:	83 ec 08             	sub    $0x8,%esp
  801867:	ff 75 e8             	pushl  -0x18(%ebp)
  80186a:	8d 45 14             	lea    0x14(%ebp),%eax
  80186d:	50                   	push   %eax
  80186e:	e8 e7 fb ff ff       	call   80145a <getuint>
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801879:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  80187c:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  801883:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  801887:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80188a:	83 ec 04             	sub    $0x4,%esp
  80188d:	52                   	push   %edx
  80188e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801891:	50                   	push   %eax
  801892:	ff 75 f4             	pushl  -0xc(%ebp)
  801895:	ff 75 f0             	pushl  -0x10(%ebp)
  801898:	ff 75 0c             	pushl  0xc(%ebp)
  80189b:	ff 75 08             	pushl  0x8(%ebp)
  80189e:	e8 00 fb ff ff       	call   8013a3 <printnum>
  8018a3:	83 c4 20             	add    $0x20,%esp
			break;
  8018a6:	eb 46                	jmp    8018ee <vprintfmt+0x3ce>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8018a8:	83 ec 08             	sub    $0x8,%esp
  8018ab:	ff 75 0c             	pushl  0xc(%ebp)
  8018ae:	53                   	push   %ebx
  8018af:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b2:	ff d0                	call   *%eax
  8018b4:	83 c4 10             	add    $0x10,%esp
			break;
  8018b7:	eb 35                	jmp    8018ee <vprintfmt+0x3ce>

		/**********************************/
		/*2023*/
		// DON'T Print Program Name & UD
		case '~':
			printProgName = 0;
  8018b9:	c6 05 40 60 80 00 00 	movb   $0x0,0x806040
			break;
  8018c0:	eb 2c                	jmp    8018ee <vprintfmt+0x3ce>
		// Print Program Name & UD
		case '@':
			printProgName = 1;
  8018c2:	c6 05 40 60 80 00 01 	movb   $0x1,0x806040
			break;
  8018c9:	eb 23                	jmp    8018ee <vprintfmt+0x3ce>
		/**********************************/

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8018cb:	83 ec 08             	sub    $0x8,%esp
  8018ce:	ff 75 0c             	pushl  0xc(%ebp)
  8018d1:	6a 25                	push   $0x25
  8018d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d6:	ff d0                	call   *%eax
  8018d8:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  8018db:	ff 4d 10             	decl   0x10(%ebp)
  8018de:	eb 03                	jmp    8018e3 <vprintfmt+0x3c3>
  8018e0:	ff 4d 10             	decl   0x10(%ebp)
  8018e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8018e6:	48                   	dec    %eax
  8018e7:	8a 00                	mov    (%eax),%al
  8018e9:	3c 25                	cmp    $0x25,%al
  8018eb:	75 f3                	jne    8018e0 <vprintfmt+0x3c0>
				/* do nothing */;
			break;
  8018ed:	90                   	nop
		}
	}
  8018ee:	e9 35 fc ff ff       	jmp    801528 <vprintfmt+0x8>
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
  8018f3:	90                   	nop
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8018f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f7:	5b                   	pop    %ebx
  8018f8:	5e                   	pop    %esi
  8018f9:	5d                   	pop    %ebp
  8018fa:	c3                   	ret    

008018fb <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8018fb:	55                   	push   %ebp
  8018fc:	89 e5                	mov    %esp,%ebp
  8018fe:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801901:	8d 45 10             	lea    0x10(%ebp),%eax
  801904:	83 c0 04             	add    $0x4,%eax
  801907:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80190a:	8b 45 10             	mov    0x10(%ebp),%eax
  80190d:	ff 75 f4             	pushl  -0xc(%ebp)
  801910:	50                   	push   %eax
  801911:	ff 75 0c             	pushl  0xc(%ebp)
  801914:	ff 75 08             	pushl  0x8(%ebp)
  801917:	e8 04 fc ff ff       	call   801520 <vprintfmt>
  80191c:	83 c4 10             	add    $0x10,%esp
	va_end(ap);
}
  80191f:	90                   	nop
  801920:	c9                   	leave  
  801921:	c3                   	ret    

00801922 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801922:	55                   	push   %ebp
  801923:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  801925:	8b 45 0c             	mov    0xc(%ebp),%eax
  801928:	8b 40 08             	mov    0x8(%eax),%eax
  80192b:	8d 50 01             	lea    0x1(%eax),%edx
  80192e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801931:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  801934:	8b 45 0c             	mov    0xc(%ebp),%eax
  801937:	8b 10                	mov    (%eax),%edx
  801939:	8b 45 0c             	mov    0xc(%ebp),%eax
  80193c:	8b 40 04             	mov    0x4(%eax),%eax
  80193f:	39 c2                	cmp    %eax,%edx
  801941:	73 12                	jae    801955 <sprintputch+0x33>
		*b->buf++ = ch;
  801943:	8b 45 0c             	mov    0xc(%ebp),%eax
  801946:	8b 00                	mov    (%eax),%eax
  801948:	8d 48 01             	lea    0x1(%eax),%ecx
  80194b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80194e:	89 0a                	mov    %ecx,(%edx)
  801950:	8b 55 08             	mov    0x8(%ebp),%edx
  801953:	88 10                	mov    %dl,(%eax)
}
  801955:	90                   	nop
  801956:	5d                   	pop    %ebp
  801957:	c3                   	ret    

00801958 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801958:	55                   	push   %ebp
  801959:	89 e5                	mov    %esp,%ebp
  80195b:	83 ec 18             	sub    $0x18,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  80195e:	8b 45 08             	mov    0x8(%ebp),%eax
  801961:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801964:	8b 45 0c             	mov    0xc(%ebp),%eax
  801967:	8d 50 ff             	lea    -0x1(%eax),%edx
  80196a:	8b 45 08             	mov    0x8(%ebp),%eax
  80196d:	01 d0                	add    %edx,%eax
  80196f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801972:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801979:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80197d:	74 06                	je     801985 <vsnprintf+0x2d>
  80197f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801983:	7f 07                	jg     80198c <vsnprintf+0x34>
		return -E_INVAL;
  801985:	b8 03 00 00 00       	mov    $0x3,%eax
  80198a:	eb 20                	jmp    8019ac <vsnprintf+0x54>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80198c:	ff 75 14             	pushl  0x14(%ebp)
  80198f:	ff 75 10             	pushl  0x10(%ebp)
  801992:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801995:	50                   	push   %eax
  801996:	68 22 19 80 00       	push   $0x801922
  80199b:	e8 80 fb ff ff       	call   801520 <vprintfmt>
  8019a0:	83 c4 10             	add    $0x10,%esp

	// null terminate the buffer
	*b.buf = '\0';
  8019a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8019a6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8019a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8019ac:	c9                   	leave  
  8019ad:	c3                   	ret    

008019ae <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8019ae:	55                   	push   %ebp
  8019af:	89 e5                	mov    %esp,%ebp
  8019b1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8019b4:	8d 45 10             	lea    0x10(%ebp),%eax
  8019b7:	83 c0 04             	add    $0x4,%eax
  8019ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8019bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8019c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c3:	50                   	push   %eax
  8019c4:	ff 75 0c             	pushl  0xc(%ebp)
  8019c7:	ff 75 08             	pushl  0x8(%ebp)
  8019ca:	e8 89 ff ff ff       	call   801958 <vsnprintf>
  8019cf:	83 c4 10             	add    $0x10,%esp
  8019d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return rc;
  8019d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8019d8:	c9                   	leave  
  8019d9:	c3                   	ret    

008019da <strlen>:
#include <inc/string.h>
#include <inc/assert.h>

int
strlen(const char *s)
{
  8019da:	55                   	push   %ebp
  8019db:	89 e5                	mov    %esp,%ebp
  8019dd:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  8019e0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8019e7:	eb 06                	jmp    8019ef <strlen+0x15>
		n++;
  8019e9:	ff 45 fc             	incl   -0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8019ec:	ff 45 08             	incl   0x8(%ebp)
  8019ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f2:	8a 00                	mov    (%eax),%al
  8019f4:	84 c0                	test   %al,%al
  8019f6:	75 f1                	jne    8019e9 <strlen+0xf>
		n++;
	return n;
  8019f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8019fb:	c9                   	leave  
  8019fc:	c3                   	ret    

008019fd <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  8019fd:	55                   	push   %ebp
  8019fe:	89 e5                	mov    %esp,%ebp
  801a00:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a03:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  801a0a:	eb 09                	jmp    801a15 <strnlen+0x18>
		n++;
  801a0c:	ff 45 fc             	incl   -0x4(%ebp)
int
strnlen(const char *s, uint32 size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a0f:	ff 45 08             	incl   0x8(%ebp)
  801a12:	ff 4d 0c             	decl   0xc(%ebp)
  801a15:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a19:	74 09                	je     801a24 <strnlen+0x27>
  801a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1e:	8a 00                	mov    (%eax),%al
  801a20:	84 c0                	test   %al,%al
  801a22:	75 e8                	jne    801a0c <strnlen+0xf>
		n++;
	return n;
  801a24:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  801a27:	c9                   	leave  
  801a28:	c3                   	ret    

00801a29 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801a29:	55                   	push   %ebp
  801a2a:	89 e5                	mov    %esp,%ebp
  801a2c:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  801a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a32:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  801a35:	90                   	nop
  801a36:	8b 45 08             	mov    0x8(%ebp),%eax
  801a39:	8d 50 01             	lea    0x1(%eax),%edx
  801a3c:	89 55 08             	mov    %edx,0x8(%ebp)
  801a3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a42:	8d 4a 01             	lea    0x1(%edx),%ecx
  801a45:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  801a48:	8a 12                	mov    (%edx),%dl
  801a4a:	88 10                	mov    %dl,(%eax)
  801a4c:	8a 00                	mov    (%eax),%al
  801a4e:	84 c0                	test   %al,%al
  801a50:	75 e4                	jne    801a36 <strcpy+0xd>
		/* do nothing */;
	return ret;
  801a52:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  801a55:	c9                   	leave  
  801a56:	c3                   	ret    

00801a57 <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  801a57:	55                   	push   %ebp
  801a58:	89 e5                	mov    %esp,%ebp
  801a5a:	83 ec 10             	sub    $0x10,%esp
	uint32 i;
	char *ret;

	ret = dst;
  801a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a60:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  801a63:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  801a6a:	eb 1f                	jmp    801a8b <strncpy+0x34>
		*dst++ = *src;
  801a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6f:	8d 50 01             	lea    0x1(%eax),%edx
  801a72:	89 55 08             	mov    %edx,0x8(%ebp)
  801a75:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a78:	8a 12                	mov    (%edx),%dl
  801a7a:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  801a7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7f:	8a 00                	mov    (%eax),%al
  801a81:	84 c0                	test   %al,%al
  801a83:	74 03                	je     801a88 <strncpy+0x31>
			src++;
  801a85:	ff 45 0c             	incl   0xc(%ebp)
strncpy(char *dst, const char *src, uint32 size) {
	uint32 i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a88:	ff 45 fc             	incl   -0x4(%ebp)
  801a8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801a8e:	3b 45 10             	cmp    0x10(%ebp),%eax
  801a91:	72 d9                	jb     801a6c <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  801a93:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801a96:	c9                   	leave  
  801a97:	c3                   	ret    

00801a98 <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  801a98:	55                   	push   %ebp
  801a99:	89 e5                	mov    %esp,%ebp
  801a9b:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  801a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa1:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  801aa4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801aa8:	74 30                	je     801ada <strlcpy+0x42>
		while (--size > 0 && *src != '\0')
  801aaa:	eb 16                	jmp    801ac2 <strlcpy+0x2a>
			*dst++ = *src++;
  801aac:	8b 45 08             	mov    0x8(%ebp),%eax
  801aaf:	8d 50 01             	lea    0x1(%eax),%edx
  801ab2:	89 55 08             	mov    %edx,0x8(%ebp)
  801ab5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ab8:	8d 4a 01             	lea    0x1(%edx),%ecx
  801abb:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  801abe:	8a 12                	mov    (%edx),%dl
  801ac0:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801ac2:	ff 4d 10             	decl   0x10(%ebp)
  801ac5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ac9:	74 09                	je     801ad4 <strlcpy+0x3c>
  801acb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ace:	8a 00                	mov    (%eax),%al
  801ad0:	84 c0                	test   %al,%al
  801ad2:	75 d8                	jne    801aac <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  801ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801ada:	8b 55 08             	mov    0x8(%ebp),%edx
  801add:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801ae0:	29 c2                	sub    %eax,%edx
  801ae2:	89 d0                	mov    %edx,%eax
}
  801ae4:	c9                   	leave  
  801ae5:	c3                   	ret    

00801ae6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  801ae9:	eb 06                	jmp    801af1 <strcmp+0xb>
		p++, q++;
  801aeb:	ff 45 08             	incl   0x8(%ebp)
  801aee:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801af1:	8b 45 08             	mov    0x8(%ebp),%eax
  801af4:	8a 00                	mov    (%eax),%al
  801af6:	84 c0                	test   %al,%al
  801af8:	74 0e                	je     801b08 <strcmp+0x22>
  801afa:	8b 45 08             	mov    0x8(%ebp),%eax
  801afd:	8a 10                	mov    (%eax),%dl
  801aff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b02:	8a 00                	mov    (%eax),%al
  801b04:	38 c2                	cmp    %al,%dl
  801b06:	74 e3                	je     801aeb <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801b08:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0b:	8a 00                	mov    (%eax),%al
  801b0d:	0f b6 d0             	movzbl %al,%edx
  801b10:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b13:	8a 00                	mov    (%eax),%al
  801b15:	0f b6 c0             	movzbl %al,%eax
  801b18:	29 c2                	sub    %eax,%edx
  801b1a:	89 d0                	mov    %edx,%eax
}
  801b1c:	5d                   	pop    %ebp
  801b1d:	c3                   	ret    

00801b1e <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  801b1e:	55                   	push   %ebp
  801b1f:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  801b21:	eb 09                	jmp    801b2c <strncmp+0xe>
		n--, p++, q++;
  801b23:	ff 4d 10             	decl   0x10(%ebp)
  801b26:	ff 45 08             	incl   0x8(%ebp)
  801b29:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint32 n)
{
	while (n > 0 && *p && *p == *q)
  801b2c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b30:	74 17                	je     801b49 <strncmp+0x2b>
  801b32:	8b 45 08             	mov    0x8(%ebp),%eax
  801b35:	8a 00                	mov    (%eax),%al
  801b37:	84 c0                	test   %al,%al
  801b39:	74 0e                	je     801b49 <strncmp+0x2b>
  801b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3e:	8a 10                	mov    (%eax),%dl
  801b40:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b43:	8a 00                	mov    (%eax),%al
  801b45:	38 c2                	cmp    %al,%dl
  801b47:	74 da                	je     801b23 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  801b49:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b4d:	75 07                	jne    801b56 <strncmp+0x38>
		return 0;
  801b4f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b54:	eb 14                	jmp    801b6a <strncmp+0x4c>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801b56:	8b 45 08             	mov    0x8(%ebp),%eax
  801b59:	8a 00                	mov    (%eax),%al
  801b5b:	0f b6 d0             	movzbl %al,%edx
  801b5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b61:	8a 00                	mov    (%eax),%al
  801b63:	0f b6 c0             	movzbl %al,%eax
  801b66:	29 c2                	sub    %eax,%edx
  801b68:	89 d0                	mov    %edx,%eax
}
  801b6a:	5d                   	pop    %ebp
  801b6b:	c3                   	ret    

00801b6c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801b6c:	55                   	push   %ebp
  801b6d:	89 e5                	mov    %esp,%ebp
  801b6f:	83 ec 04             	sub    $0x4,%esp
  801b72:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b75:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  801b78:	eb 12                	jmp    801b8c <strchr+0x20>
		if (*s == c)
  801b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7d:	8a 00                	mov    (%eax),%al
  801b7f:	3a 45 fc             	cmp    -0x4(%ebp),%al
  801b82:	75 05                	jne    801b89 <strchr+0x1d>
			return (char *) s;
  801b84:	8b 45 08             	mov    0x8(%ebp),%eax
  801b87:	eb 11                	jmp    801b9a <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b89:	ff 45 08             	incl   0x8(%ebp)
  801b8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8f:	8a 00                	mov    (%eax),%al
  801b91:	84 c0                	test   %al,%al
  801b93:	75 e5                	jne    801b7a <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  801b95:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b9a:	c9                   	leave  
  801b9b:	c3                   	ret    

00801b9c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	83 ec 04             	sub    $0x4,%esp
  801ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba5:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  801ba8:	eb 0d                	jmp    801bb7 <strfind+0x1b>
		if (*s == c)
  801baa:	8b 45 08             	mov    0x8(%ebp),%eax
  801bad:	8a 00                	mov    (%eax),%al
  801baf:	3a 45 fc             	cmp    -0x4(%ebp),%al
  801bb2:	74 0e                	je     801bc2 <strfind+0x26>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801bb4:	ff 45 08             	incl   0x8(%ebp)
  801bb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bba:	8a 00                	mov    (%eax),%al
  801bbc:	84 c0                	test   %al,%al
  801bbe:	75 ea                	jne    801baa <strfind+0xe>
  801bc0:	eb 01                	jmp    801bc3 <strfind+0x27>
		if (*s == c)
			break;
  801bc2:	90                   	nop
	return (char *) s;
  801bc3:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801bc6:	c9                   	leave  
  801bc7:	c3                   	ret    

00801bc8 <memset>:


void *
memset(void *v, int c, uint32 n)
{
  801bc8:	55                   	push   %ebp
  801bc9:	89 e5                	mov    %esp,%ebp
  801bcb:	83 ec 10             	sub    $0x10,%esp
	char *p;
	int m;

	p = v;
  801bce:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd1:	89 45 fc             	mov    %eax,-0x4(%ebp)
	m = n;
  801bd4:	8b 45 10             	mov    0x10(%ebp),%eax
  801bd7:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (--m >= 0)
  801bda:	eb 0e                	jmp    801bea <memset+0x22>
		*p++ = c;
  801bdc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801bdf:	8d 50 01             	lea    0x1(%eax),%edx
  801be2:	89 55 fc             	mov    %edx,-0x4(%ebp)
  801be5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801be8:	88 10                	mov    %dl,(%eax)
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  801bea:	ff 4d f8             	decl   -0x8(%ebp)
  801bed:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
  801bf1:	79 e9                	jns    801bdc <memset+0x14>
		*p++ = c;

	return v;
  801bf3:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801bf6:	c9                   	leave  
  801bf7:	c3                   	ret    

00801bf8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  801bfe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c01:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  801c04:	8b 45 08             	mov    0x8(%ebp),%eax
  801c07:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
  801c0a:	eb 16                	jmp    801c22 <memcpy+0x2a>
		*d++ = *s++;
  801c0c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801c0f:	8d 50 01             	lea    0x1(%eax),%edx
  801c12:	89 55 f8             	mov    %edx,-0x8(%ebp)
  801c15:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801c18:	8d 4a 01             	lea    0x1(%edx),%ecx
  801c1b:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  801c1e:	8a 12                	mov    (%edx),%dl
  801c20:	88 10                	mov    %dl,(%eax)
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  801c22:	8b 45 10             	mov    0x10(%ebp),%eax
  801c25:	8d 50 ff             	lea    -0x1(%eax),%edx
  801c28:	89 55 10             	mov    %edx,0x10(%ebp)
  801c2b:	85 c0                	test   %eax,%eax
  801c2d:	75 dd                	jne    801c0c <memcpy+0x14>
		*d++ = *s++;

	return dst;
  801c2f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801c32:	c9                   	leave  
  801c33:	c3                   	ret    

00801c34 <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  801c3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c3d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  801c40:	8b 45 08             	mov    0x8(%ebp),%eax
  801c43:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (s < d && s + n > d) {
  801c46:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801c49:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  801c4c:	73 50                	jae    801c9e <memmove+0x6a>
  801c4e:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801c51:	8b 45 10             	mov    0x10(%ebp),%eax
  801c54:	01 d0                	add    %edx,%eax
  801c56:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  801c59:	76 43                	jbe    801c9e <memmove+0x6a>
		s += n;
  801c5b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c5e:	01 45 fc             	add    %eax,-0x4(%ebp)
		d += n;
  801c61:	8b 45 10             	mov    0x10(%ebp),%eax
  801c64:	01 45 f8             	add    %eax,-0x8(%ebp)
		while (n-- > 0)
  801c67:	eb 10                	jmp    801c79 <memmove+0x45>
			*--d = *--s;
  801c69:	ff 4d f8             	decl   -0x8(%ebp)
  801c6c:	ff 4d fc             	decl   -0x4(%ebp)
  801c6f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801c72:	8a 10                	mov    (%eax),%dl
  801c74:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801c77:	88 10                	mov    %dl,(%eax)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  801c79:	8b 45 10             	mov    0x10(%ebp),%eax
  801c7c:	8d 50 ff             	lea    -0x1(%eax),%edx
  801c7f:	89 55 10             	mov    %edx,0x10(%ebp)
  801c82:	85 c0                	test   %eax,%eax
  801c84:	75 e3                	jne    801c69 <memmove+0x35>
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801c86:	eb 23                	jmp    801cab <memmove+0x77>
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  801c88:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801c8b:	8d 50 01             	lea    0x1(%eax),%edx
  801c8e:	89 55 f8             	mov    %edx,-0x8(%ebp)
  801c91:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801c94:	8d 4a 01             	lea    0x1(%edx),%ecx
  801c97:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  801c9a:	8a 12                	mov    (%edx),%dl
  801c9c:	88 10                	mov    %dl,(%eax)
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  801c9e:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca1:	8d 50 ff             	lea    -0x1(%eax),%edx
  801ca4:	89 55 10             	mov    %edx,0x10(%ebp)
  801ca7:	85 c0                	test   %eax,%eax
  801ca9:	75 dd                	jne    801c88 <memmove+0x54>
			*d++ = *s++;

	return dst;
  801cab:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801cae:	c9                   	leave  
  801caf:	c3                   	ret    

00801cb0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	83 ec 10             	sub    $0x10,%esp
	const uint8 *s1 = (const uint8 *) v1;
  801cb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb9:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8 *s2 = (const uint8 *) v2;
  801cbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cbf:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  801cc2:	eb 2a                	jmp    801cee <memcmp+0x3e>
		if (*s1 != *s2)
  801cc4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801cc7:	8a 10                	mov    (%eax),%dl
  801cc9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801ccc:	8a 00                	mov    (%eax),%al
  801cce:	38 c2                	cmp    %al,%dl
  801cd0:	74 16                	je     801ce8 <memcmp+0x38>
			return (int) *s1 - (int) *s2;
  801cd2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801cd5:	8a 00                	mov    (%eax),%al
  801cd7:	0f b6 d0             	movzbl %al,%edx
  801cda:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801cdd:	8a 00                	mov    (%eax),%al
  801cdf:	0f b6 c0             	movzbl %al,%eax
  801ce2:	29 c2                	sub    %eax,%edx
  801ce4:	89 d0                	mov    %edx,%eax
  801ce6:	eb 18                	jmp    801d00 <memcmp+0x50>
		s1++, s2++;
  801ce8:	ff 45 fc             	incl   -0x4(%ebp)
  801ceb:	ff 45 f8             	incl   -0x8(%ebp)
memcmp(const void *v1, const void *v2, uint32 n)
{
	const uint8 *s1 = (const uint8 *) v1;
	const uint8 *s2 = (const uint8 *) v2;

	while (n-- > 0) {
  801cee:	8b 45 10             	mov    0x10(%ebp),%eax
  801cf1:	8d 50 ff             	lea    -0x1(%eax),%edx
  801cf4:	89 55 10             	mov    %edx,0x10(%ebp)
  801cf7:	85 c0                	test   %eax,%eax
  801cf9:	75 c9                	jne    801cc4 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801cfb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d00:	c9                   	leave  
  801d01:	c3                   	ret    

00801d02 <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  801d02:	55                   	push   %ebp
  801d03:	89 e5                	mov    %esp,%ebp
  801d05:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  801d08:	8b 55 08             	mov    0x8(%ebp),%edx
  801d0b:	8b 45 10             	mov    0x10(%ebp),%eax
  801d0e:	01 d0                	add    %edx,%eax
  801d10:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801d13:	eb 15                	jmp    801d2a <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  801d15:	8b 45 08             	mov    0x8(%ebp),%eax
  801d18:	8a 00                	mov    (%eax),%al
  801d1a:	0f b6 d0             	movzbl %al,%edx
  801d1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d20:	0f b6 c0             	movzbl %al,%eax
  801d23:	39 c2                	cmp    %eax,%edx
  801d25:	74 0d                	je     801d34 <memfind+0x32>

void *
memfind(const void *s, int c, uint32 n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d27:	ff 45 08             	incl   0x8(%ebp)
  801d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  801d30:	72 e3                	jb     801d15 <memfind+0x13>
  801d32:	eb 01                	jmp    801d35 <memfind+0x33>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
  801d34:	90                   	nop
	return (void *) s;
  801d35:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801d38:	c9                   	leave  
  801d39:	c3                   	ret    

00801d3a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801d3a:	55                   	push   %ebp
  801d3b:	89 e5                	mov    %esp,%ebp
  801d3d:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  801d40:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  801d47:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801d4e:	eb 03                	jmp    801d53 <strtol+0x19>
		s++;
  801d50:	ff 45 08             	incl   0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801d53:	8b 45 08             	mov    0x8(%ebp),%eax
  801d56:	8a 00                	mov    (%eax),%al
  801d58:	3c 20                	cmp    $0x20,%al
  801d5a:	74 f4                	je     801d50 <strtol+0x16>
  801d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5f:	8a 00                	mov    (%eax),%al
  801d61:	3c 09                	cmp    $0x9,%al
  801d63:	74 eb                	je     801d50 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  801d65:	8b 45 08             	mov    0x8(%ebp),%eax
  801d68:	8a 00                	mov    (%eax),%al
  801d6a:	3c 2b                	cmp    $0x2b,%al
  801d6c:	75 05                	jne    801d73 <strtol+0x39>
		s++;
  801d6e:	ff 45 08             	incl   0x8(%ebp)
  801d71:	eb 13                	jmp    801d86 <strtol+0x4c>
	else if (*s == '-')
  801d73:	8b 45 08             	mov    0x8(%ebp),%eax
  801d76:	8a 00                	mov    (%eax),%al
  801d78:	3c 2d                	cmp    $0x2d,%al
  801d7a:	75 0a                	jne    801d86 <strtol+0x4c>
		s++, neg = 1;
  801d7c:	ff 45 08             	incl   0x8(%ebp)
  801d7f:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801d86:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d8a:	74 06                	je     801d92 <strtol+0x58>
  801d8c:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801d90:	75 20                	jne    801db2 <strtol+0x78>
  801d92:	8b 45 08             	mov    0x8(%ebp),%eax
  801d95:	8a 00                	mov    (%eax),%al
  801d97:	3c 30                	cmp    $0x30,%al
  801d99:	75 17                	jne    801db2 <strtol+0x78>
  801d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9e:	40                   	inc    %eax
  801d9f:	8a 00                	mov    (%eax),%al
  801da1:	3c 78                	cmp    $0x78,%al
  801da3:	75 0d                	jne    801db2 <strtol+0x78>
		s += 2, base = 16;
  801da5:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  801da9:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  801db0:	eb 28                	jmp    801dda <strtol+0xa0>
	else if (base == 0 && s[0] == '0')
  801db2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801db6:	75 15                	jne    801dcd <strtol+0x93>
  801db8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbb:	8a 00                	mov    (%eax),%al
  801dbd:	3c 30                	cmp    $0x30,%al
  801dbf:	75 0c                	jne    801dcd <strtol+0x93>
		s++, base = 8;
  801dc1:	ff 45 08             	incl   0x8(%ebp)
  801dc4:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801dcb:	eb 0d                	jmp    801dda <strtol+0xa0>
	else if (base == 0)
  801dcd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dd1:	75 07                	jne    801dda <strtol+0xa0>
		base = 10;
  801dd3:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801dda:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddd:	8a 00                	mov    (%eax),%al
  801ddf:	3c 2f                	cmp    $0x2f,%al
  801de1:	7e 19                	jle    801dfc <strtol+0xc2>
  801de3:	8b 45 08             	mov    0x8(%ebp),%eax
  801de6:	8a 00                	mov    (%eax),%al
  801de8:	3c 39                	cmp    $0x39,%al
  801dea:	7f 10                	jg     801dfc <strtol+0xc2>
			dig = *s - '0';
  801dec:	8b 45 08             	mov    0x8(%ebp),%eax
  801def:	8a 00                	mov    (%eax),%al
  801df1:	0f be c0             	movsbl %al,%eax
  801df4:	83 e8 30             	sub    $0x30,%eax
  801df7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801dfa:	eb 42                	jmp    801e3e <strtol+0x104>
		else if (*s >= 'a' && *s <= 'z')
  801dfc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dff:	8a 00                	mov    (%eax),%al
  801e01:	3c 60                	cmp    $0x60,%al
  801e03:	7e 19                	jle    801e1e <strtol+0xe4>
  801e05:	8b 45 08             	mov    0x8(%ebp),%eax
  801e08:	8a 00                	mov    (%eax),%al
  801e0a:	3c 7a                	cmp    $0x7a,%al
  801e0c:	7f 10                	jg     801e1e <strtol+0xe4>
			dig = *s - 'a' + 10;
  801e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e11:	8a 00                	mov    (%eax),%al
  801e13:	0f be c0             	movsbl %al,%eax
  801e16:	83 e8 57             	sub    $0x57,%eax
  801e19:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801e1c:	eb 20                	jmp    801e3e <strtol+0x104>
		else if (*s >= 'A' && *s <= 'Z')
  801e1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e21:	8a 00                	mov    (%eax),%al
  801e23:	3c 40                	cmp    $0x40,%al
  801e25:	7e 39                	jle    801e60 <strtol+0x126>
  801e27:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2a:	8a 00                	mov    (%eax),%al
  801e2c:	3c 5a                	cmp    $0x5a,%al
  801e2e:	7f 30                	jg     801e60 <strtol+0x126>
			dig = *s - 'A' + 10;
  801e30:	8b 45 08             	mov    0x8(%ebp),%eax
  801e33:	8a 00                	mov    (%eax),%al
  801e35:	0f be c0             	movsbl %al,%eax
  801e38:	83 e8 37             	sub    $0x37,%eax
  801e3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e41:	3b 45 10             	cmp    0x10(%ebp),%eax
  801e44:	7d 19                	jge    801e5f <strtol+0x125>
			break;
		s++, val = (val * base) + dig;
  801e46:	ff 45 08             	incl   0x8(%ebp)
  801e49:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801e4c:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e50:	89 c2                	mov    %eax,%edx
  801e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e55:	01 d0                	add    %edx,%eax
  801e57:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  801e5a:	e9 7b ff ff ff       	jmp    801dda <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
			break;
  801e5f:	90                   	nop
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801e60:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e64:	74 08                	je     801e6e <strtol+0x134>
		*endptr = (char *) s;
  801e66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e69:	8b 55 08             	mov    0x8(%ebp),%edx
  801e6c:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801e6e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  801e72:	74 07                	je     801e7b <strtol+0x141>
  801e74:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801e77:	f7 d8                	neg    %eax
  801e79:	eb 03                	jmp    801e7e <strtol+0x144>
  801e7b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801e7e:	c9                   	leave  
  801e7f:	c3                   	ret    

00801e80 <ltostr>:

void
ltostr(long value, char *str)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	83 ec 20             	sub    $0x20,%esp
	int neg = 0;
  801e86:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	int s = 0 ;
  801e8d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// plus/minus sign
	if (value < 0)
  801e94:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801e98:	79 13                	jns    801ead <ltostr+0x2d>
	{
		neg = 1;
  801e9a:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
		str[0] = '-';
  801ea1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea4:	c6 00 2d             	movb   $0x2d,(%eax)
		value = value * -1 ;
  801ea7:	f7 5d 08             	negl   0x8(%ebp)
		s++ ;
  801eaa:	ff 45 f8             	incl   -0x8(%ebp)
	}
	do
	{
		int mod = value % 10 ;
  801ead:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801eb5:	99                   	cltd   
  801eb6:	f7 f9                	idiv   %ecx
  801eb8:	89 55 ec             	mov    %edx,-0x14(%ebp)
		str[s++] = mod + '0' ;
  801ebb:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801ebe:	8d 50 01             	lea    0x1(%eax),%edx
  801ec1:	89 55 f8             	mov    %edx,-0x8(%ebp)
  801ec4:	89 c2                	mov    %eax,%edx
  801ec6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec9:	01 d0                	add    %edx,%eax
  801ecb:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801ece:	83 c2 30             	add    $0x30,%edx
  801ed1:	88 10                	mov    %dl,(%eax)
		value = value / 10 ;
  801ed3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ed6:	b8 67 66 66 66       	mov    $0x66666667,%eax
  801edb:	f7 e9                	imul   %ecx
  801edd:	c1 fa 02             	sar    $0x2,%edx
  801ee0:	89 c8                	mov    %ecx,%eax
  801ee2:	c1 f8 1f             	sar    $0x1f,%eax
  801ee5:	29 c2                	sub    %eax,%edx
  801ee7:	89 d0                	mov    %edx,%eax
  801ee9:	89 45 08             	mov    %eax,0x8(%ebp)
	/*2023 FIX el7 :)*/
	//} while (value % 10 != 0);
	} while (value != 0);
  801eec:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801ef0:	75 bb                	jne    801ead <ltostr+0x2d>

	//reverse the string
	int start = 0 ;
  801ef2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int end = s-1 ;
  801ef9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801efc:	48                   	dec    %eax
  801efd:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (neg)
  801f00:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  801f04:	74 3d                	je     801f43 <ltostr+0xc3>
		start = 1 ;
  801f06:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	while(start<end)
  801f0d:	eb 34                	jmp    801f43 <ltostr+0xc3>
	{
		char tmp = str[start] ;
  801f0f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f12:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f15:	01 d0                	add    %edx,%eax
  801f17:	8a 00                	mov    (%eax),%al
  801f19:	88 45 eb             	mov    %al,-0x15(%ebp)
		str[start] = str[end] ;
  801f1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f22:	01 c2                	add    %eax,%edx
  801f24:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801f27:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f2a:	01 c8                	add    %ecx,%eax
  801f2c:	8a 00                	mov    (%eax),%al
  801f2e:	88 02                	mov    %al,(%edx)
		str[end] = tmp;
  801f30:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f33:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f36:	01 c2                	add    %eax,%edx
  801f38:	8a 45 eb             	mov    -0x15(%ebp),%al
  801f3b:	88 02                	mov    %al,(%edx)
		start++ ;
  801f3d:	ff 45 f4             	incl   -0xc(%ebp)
		end-- ;
  801f40:	ff 4d f0             	decl   -0x10(%ebp)
	//reverse the string
	int start = 0 ;
	int end = s-1 ;
	if (neg)
		start = 1 ;
	while(start<end)
  801f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f46:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  801f49:	7c c4                	jl     801f0f <ltostr+0x8f>
		str[end] = tmp;
		start++ ;
		end-- ;
	}

	str[s] = 0 ;
  801f4b:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801f4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f51:	01 d0                	add    %edx,%eax
  801f53:	c6 00 00             	movb   $0x0,(%eax)
	// we don't properly detect overflow!

}
  801f56:	90                   	nop
  801f57:	c9                   	leave  
  801f58:	c3                   	ret    

00801f59 <strcconcat>:

void
strcconcat(const char *str1, const char *str2, char *final)
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
  801f5c:	83 ec 10             	sub    $0x10,%esp
	int len1 = strlen(str1);
  801f5f:	ff 75 08             	pushl  0x8(%ebp)
  801f62:	e8 73 fa ff ff       	call   8019da <strlen>
  801f67:	83 c4 04             	add    $0x4,%esp
  801f6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int len2 = strlen(str2);
  801f6d:	ff 75 0c             	pushl  0xc(%ebp)
  801f70:	e8 65 fa ff ff       	call   8019da <strlen>
  801f75:	83 c4 04             	add    $0x4,%esp
  801f78:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int s = 0 ;
  801f7b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for (s=0 ; s < len1 ; s++)
  801f82:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  801f89:	eb 17                	jmp    801fa2 <strcconcat+0x49>
		final[s] = str1[s] ;
  801f8b:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801f8e:	8b 45 10             	mov    0x10(%ebp),%eax
  801f91:	01 c2                	add    %eax,%edx
  801f93:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  801f96:	8b 45 08             	mov    0x8(%ebp),%eax
  801f99:	01 c8                	add    %ecx,%eax
  801f9b:	8a 00                	mov    (%eax),%al
  801f9d:	88 02                	mov    %al,(%edx)
strcconcat(const char *str1, const char *str2, char *final)
{
	int len1 = strlen(str1);
	int len2 = strlen(str2);
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
  801f9f:	ff 45 fc             	incl   -0x4(%ebp)
  801fa2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801fa5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  801fa8:	7c e1                	jl     801f8b <strcconcat+0x32>
		final[s] = str1[s] ;

	int i = 0 ;
  801faa:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
	for (i=0 ; i < len2 ; i++)
  801fb1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  801fb8:	eb 1f                	jmp    801fd9 <strcconcat+0x80>
		final[s++] = str2[i] ;
  801fba:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801fbd:	8d 50 01             	lea    0x1(%eax),%edx
  801fc0:	89 55 fc             	mov    %edx,-0x4(%ebp)
  801fc3:	89 c2                	mov    %eax,%edx
  801fc5:	8b 45 10             	mov    0x10(%ebp),%eax
  801fc8:	01 c2                	add    %eax,%edx
  801fca:	8b 4d f8             	mov    -0x8(%ebp),%ecx
  801fcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd0:	01 c8                	add    %ecx,%eax
  801fd2:	8a 00                	mov    (%eax),%al
  801fd4:	88 02                	mov    %al,(%edx)
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
		final[s] = str1[s] ;

	int i = 0 ;
	for (i=0 ; i < len2 ; i++)
  801fd6:	ff 45 f8             	incl   -0x8(%ebp)
  801fd9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801fdc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  801fdf:	7c d9                	jl     801fba <strcconcat+0x61>
		final[s++] = str2[i] ;

	final[s] = 0;
  801fe1:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801fe4:	8b 45 10             	mov    0x10(%ebp),%eax
  801fe7:	01 d0                	add    %edx,%eax
  801fe9:	c6 00 00             	movb   $0x0,(%eax)
}
  801fec:	90                   	nop
  801fed:	c9                   	leave  
  801fee:	c3                   	ret    

00801fef <strsplit>:
int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  801fef:	55                   	push   %ebp
  801ff0:	89 e5                	mov    %esp,%ebp
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  801ff2:	8b 45 14             	mov    0x14(%ebp),%eax
  801ff5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	(argv)[*argc] = 0;
  801ffb:	8b 45 14             	mov    0x14(%ebp),%eax
  801ffe:	8b 00                	mov    (%eax),%eax
  802000:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  802007:	8b 45 10             	mov    0x10(%ebp),%eax
  80200a:	01 d0                	add    %edx,%eax
  80200c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  802012:	eb 0c                	jmp    802020 <strsplit+0x31>
			*string++ = 0;
  802014:	8b 45 08             	mov    0x8(%ebp),%eax
  802017:	8d 50 01             	lea    0x1(%eax),%edx
  80201a:	89 55 08             	mov    %edx,0x8(%ebp)
  80201d:	c6 00 00             	movb   $0x0,(%eax)
	*argc = 0;
	(argv)[*argc] = 0;
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  802020:	8b 45 08             	mov    0x8(%ebp),%eax
  802023:	8a 00                	mov    (%eax),%al
  802025:	84 c0                	test   %al,%al
  802027:	74 18                	je     802041 <strsplit+0x52>
  802029:	8b 45 08             	mov    0x8(%ebp),%eax
  80202c:	8a 00                	mov    (%eax),%al
  80202e:	0f be c0             	movsbl %al,%eax
  802031:	50                   	push   %eax
  802032:	ff 75 0c             	pushl  0xc(%ebp)
  802035:	e8 32 fb ff ff       	call   801b6c <strchr>
  80203a:	83 c4 08             	add    $0x8,%esp
  80203d:	85 c0                	test   %eax,%eax
  80203f:	75 d3                	jne    802014 <strsplit+0x25>
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
  802041:	8b 45 08             	mov    0x8(%ebp),%eax
  802044:	8a 00                	mov    (%eax),%al
  802046:	84 c0                	test   %al,%al
  802048:	74 5a                	je     8020a4 <strsplit+0xb5>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1)
  80204a:	8b 45 14             	mov    0x14(%ebp),%eax
  80204d:	8b 00                	mov    (%eax),%eax
  80204f:	83 f8 0f             	cmp    $0xf,%eax
  802052:	75 07                	jne    80205b <strsplit+0x6c>
		{
			return 0;
  802054:	b8 00 00 00 00       	mov    $0x0,%eax
  802059:	eb 66                	jmp    8020c1 <strsplit+0xd2>
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  80205b:	8b 45 14             	mov    0x14(%ebp),%eax
  80205e:	8b 00                	mov    (%eax),%eax
  802060:	8d 48 01             	lea    0x1(%eax),%ecx
  802063:	8b 55 14             	mov    0x14(%ebp),%edx
  802066:	89 0a                	mov    %ecx,(%edx)
  802068:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80206f:	8b 45 10             	mov    0x10(%ebp),%eax
  802072:	01 c2                	add    %eax,%edx
  802074:	8b 45 08             	mov    0x8(%ebp),%eax
  802077:	89 02                	mov    %eax,(%edx)
		while (*string && !strchr(SPLIT_CHARS, *string))
  802079:	eb 03                	jmp    80207e <strsplit+0x8f>
			string++;
  80207b:	ff 45 08             	incl   0x8(%ebp)
			return 0;
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
  80207e:	8b 45 08             	mov    0x8(%ebp),%eax
  802081:	8a 00                	mov    (%eax),%al
  802083:	84 c0                	test   %al,%al
  802085:	74 8b                	je     802012 <strsplit+0x23>
  802087:	8b 45 08             	mov    0x8(%ebp),%eax
  80208a:	8a 00                	mov    (%eax),%al
  80208c:	0f be c0             	movsbl %al,%eax
  80208f:	50                   	push   %eax
  802090:	ff 75 0c             	pushl  0xc(%ebp)
  802093:	e8 d4 fa ff ff       	call   801b6c <strchr>
  802098:	83 c4 08             	add    $0x8,%esp
  80209b:	85 c0                	test   %eax,%eax
  80209d:	74 dc                	je     80207b <strsplit+0x8c>
			string++;
	}
  80209f:	e9 6e ff ff ff       	jmp    802012 <strsplit+0x23>
		while (*string && strchr(SPLIT_CHARS, *string))
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
			break;
  8020a4:	90                   	nop
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
			string++;
	}
	(argv)[*argc] = 0;
  8020a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8020a8:	8b 00                	mov    (%eax),%eax
  8020aa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8020b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8020b4:	01 d0                	add    %edx,%eax
  8020b6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return 1 ;
  8020bc:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8020c1:	c9                   	leave  
  8020c2:	c3                   	ret    

008020c3 <str2lower>:


char* str2lower(char *dst, const char *src)
{
  8020c3:	55                   	push   %ebp
  8020c4:	89 e5                	mov    %esp,%ebp
  8020c6:	83 ec 08             	sub    $0x8,%esp
	//[PROJECT]
	panic("str2lower is not implemented yet!");
  8020c9:	83 ec 04             	sub    $0x4,%esp
  8020cc:	68 28 4d 80 00       	push   $0x804d28
  8020d1:	68 3f 01 00 00       	push   $0x13f
  8020d6:	68 4a 4d 80 00       	push   $0x804d4a
  8020db:	e8 a9 ef ff ff       	call   801089 <_panic>

008020e0 <sbrk>:
//=============================================
// [1] CHANGE THE BREAK LIMIT OF THE USER HEAP:
//=============================================
/*2023*/
void* sbrk(int increment)
{
  8020e0:	55                   	push   %ebp
  8020e1:	89 e5                	mov    %esp,%ebp
  8020e3:	83 ec 08             	sub    $0x8,%esp
	return (void*) sys_sbrk(increment);
  8020e6:	83 ec 0c             	sub    $0xc,%esp
  8020e9:	ff 75 08             	pushl  0x8(%ebp)
  8020ec:	e8 ef 06 00 00       	call   8027e0 <sys_sbrk>
  8020f1:	83 c4 10             	add    $0x10,%esp
}
  8020f4:	c9                   	leave  
  8020f5:	c3                   	ret    

008020f6 <malloc>:

//=================================
// [2] ALLOCATE SPACE IN USER HEAP:
//=================================
void* malloc(uint32 size)
{
  8020f6:	55                   	push   %ebp
  8020f7:	89 e5                	mov    %esp,%ebp
  8020f9:	83 ec 08             	sub    $0x8,%esp
	//==============================================================
	//DON'T CHANGE THIS CODE========================================
	if (size == 0) return NULL ;
  8020fc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  802100:	75 07                	jne    802109 <malloc+0x13>
  802102:	b8 00 00 00 00       	mov    $0x0,%eax
  802107:	eb 14                	jmp    80211d <malloc+0x27>
	//==============================================================
	//TODO: [PROJECT'24.MS2 - #12] [3] USER HEAP [USER SIDE] - malloc()
	// Write your code here, remove the panic and write your code
	panic("malloc() is not implemented yet...!!");
  802109:	83 ec 04             	sub    $0x4,%esp
  80210c:	68 58 4d 80 00       	push   $0x804d58
  802111:	6a 1b                	push   $0x1b
  802113:	68 7d 4d 80 00       	push   $0x804d7d
  802118:	e8 6c ef ff ff       	call   801089 <_panic>
	return NULL;
	//Use sys_isUHeapPlacementStrategyFIRSTFIT() and	sys_isUHeapPlacementStrategyBESTFIT()
	//to check the current strategy

}
  80211d:	c9                   	leave  
  80211e:	c3                   	ret    

0080211f <free>:

//=================================
// [3] FREE SPACE FROM USER HEAP:
//=================================
void free(void* virtual_address)
{
  80211f:	55                   	push   %ebp
  802120:	89 e5                	mov    %esp,%ebp
  802122:	83 ec 08             	sub    $0x8,%esp
	//TODO: [PROJECT'24.MS2 - #14] [3] USER HEAP [USER SIDE] - free()
	// Write your code here, remove the panic and write your code
	panic("free() is not implemented yet...!!");
  802125:	83 ec 04             	sub    $0x4,%esp
  802128:	68 8c 4d 80 00       	push   $0x804d8c
  80212d:	6a 29                	push   $0x29
  80212f:	68 7d 4d 80 00       	push   $0x804d7d
  802134:	e8 50 ef ff ff       	call   801089 <_panic>

00802139 <smalloc>:

//=================================
// [4] ALLOCATE SHARED VARIABLE:
//=================================
void* smalloc(char *sharedVarName, uint32 size, uint8 isWritable)
{
  802139:	55                   	push   %ebp
  80213a:	89 e5                	mov    %esp,%ebp
  80213c:	83 ec 18             	sub    $0x18,%esp
  80213f:	8b 45 10             	mov    0x10(%ebp),%eax
  802142:	88 45 f4             	mov    %al,-0xc(%ebp)
	//==============================================================
	//DON'T CHANGE THIS CODE========================================
	if (size == 0) return NULL ;
  802145:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802149:	75 07                	jne    802152 <smalloc+0x19>
  80214b:	b8 00 00 00 00       	mov    $0x0,%eax
  802150:	eb 14                	jmp    802166 <smalloc+0x2d>
	//==============================================================
	//TODO: [PROJECT'24.MS2 - #18] [4] SHARED MEMORY [USER SIDE] - smalloc()
	// Write your code here, remove the panic and write your code
	panic("smalloc() is not implemented yet...!!");
  802152:	83 ec 04             	sub    $0x4,%esp
  802155:	68 b0 4d 80 00       	push   $0x804db0
  80215a:	6a 38                	push   $0x38
  80215c:	68 7d 4d 80 00       	push   $0x804d7d
  802161:	e8 23 ef ff ff       	call   801089 <_panic>
	return NULL;
}
  802166:	c9                   	leave  
  802167:	c3                   	ret    

00802168 <sget>:

//========================================
// [5] SHARE ON ALLOCATED SHARED VARIABLE:
//========================================
void* sget(int32 ownerEnvID, char *sharedVarName)
{
  802168:	55                   	push   %ebp
  802169:	89 e5                	mov    %esp,%ebp
  80216b:	83 ec 08             	sub    $0x8,%esp
	//TODO: [PROJECT'24.MS2 - #20] [4] SHARED MEMORY [USER SIDE] - sget()
	// Write your code here, remove the panic and write your code
	panic("sget() is not implemented yet...!!");
  80216e:	83 ec 04             	sub    $0x4,%esp
  802171:	68 d8 4d 80 00       	push   $0x804dd8
  802176:	6a 43                	push   $0x43
  802178:	68 7d 4d 80 00       	push   $0x804d7d
  80217d:	e8 07 ef ff ff       	call   801089 <_panic>

00802182 <sfree>:
//	use sys_freeSharedObject(...); which switches to the kernel mode,
//	calls freeSharedObject(...) in "shared_memory_manager.c", then switch back to the user mode here
//	the freeSharedObject() function is empty, make sure to implement it.

void sfree(void* virtual_address)
{
  802182:	55                   	push   %ebp
  802183:	89 e5                	mov    %esp,%ebp
  802185:	83 ec 08             	sub    $0x8,%esp
	//TODO: [PROJECT'24.MS2 - BONUS#4] [4] SHARED MEMORY [USER SIDE] - sfree()
	// Write your code here, remove the panic and write your code
	panic("sfree() is not implemented yet...!!");
  802188:	83 ec 04             	sub    $0x4,%esp
  80218b:	68 fc 4d 80 00       	push   $0x804dfc
  802190:	6a 5b                	push   $0x5b
  802192:	68 7d 4d 80 00       	push   $0x804d7d
  802197:	e8 ed ee ff ff       	call   801089 <_panic>

0080219c <realloc>:
//  Hint: you may need to use the sys_move_user_mem(...)
//		which switches to the kernel mode, calls move_user_mem(...)
//		in "kern/mem/chunk_operations.c", then switch back to the user mode here
//	the move_user_mem() function is empty, make sure to implement it.
void *realloc(void *virtual_address, uint32 new_size)
{
  80219c:	55                   	push   %ebp
  80219d:	89 e5                	mov    %esp,%ebp
  80219f:	83 ec 08             	sub    $0x8,%esp
	//[PROJECT]
	// Write your code here, remove the panic and write your code
	panic("realloc() is not implemented yet...!!");
  8021a2:	83 ec 04             	sub    $0x4,%esp
  8021a5:	68 20 4e 80 00       	push   $0x804e20
  8021aa:	6a 72                	push   $0x72
  8021ac:	68 7d 4d 80 00       	push   $0x804d7d
  8021b1:	e8 d3 ee ff ff       	call   801089 <_panic>

008021b6 <expand>:
//==================================================================================//
//========================== MODIFICATION FUNCTIONS ================================//
//==================================================================================//

void expand(uint32 newSize)
{
  8021b6:	55                   	push   %ebp
  8021b7:	89 e5                	mov    %esp,%ebp
  8021b9:	83 ec 08             	sub    $0x8,%esp
	panic("Not Implemented");
  8021bc:	83 ec 04             	sub    $0x4,%esp
  8021bf:	68 46 4e 80 00       	push   $0x804e46
  8021c4:	6a 7e                	push   $0x7e
  8021c6:	68 7d 4d 80 00       	push   $0x804d7d
  8021cb:	e8 b9 ee ff ff       	call   801089 <_panic>

008021d0 <shrink>:

}
void shrink(uint32 newSize)
{
  8021d0:	55                   	push   %ebp
  8021d1:	89 e5                	mov    %esp,%ebp
  8021d3:	83 ec 08             	sub    $0x8,%esp
	panic("Not Implemented");
  8021d6:	83 ec 04             	sub    $0x4,%esp
  8021d9:	68 46 4e 80 00       	push   $0x804e46
  8021de:	68 83 00 00 00       	push   $0x83
  8021e3:	68 7d 4d 80 00       	push   $0x804d7d
  8021e8:	e8 9c ee ff ff       	call   801089 <_panic>

008021ed <freeHeap>:

}
void freeHeap(void* virtual_address)
{
  8021ed:	55                   	push   %ebp
  8021ee:	89 e5                	mov    %esp,%ebp
  8021f0:	83 ec 08             	sub    $0x8,%esp
	panic("Not Implemented");
  8021f3:	83 ec 04             	sub    $0x4,%esp
  8021f6:	68 46 4e 80 00       	push   $0x804e46
  8021fb:	68 88 00 00 00       	push   $0x88
  802200:	68 7d 4d 80 00       	push   $0x804d7d
  802205:	e8 7f ee ff ff       	call   801089 <_panic>

0080220a <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline uint32
syscall(int num, uint32 a1, uint32 a2, uint32 a3, uint32 a4, uint32 a5)
{
  80220a:	55                   	push   %ebp
  80220b:	89 e5                	mov    %esp,%ebp
  80220d:	57                   	push   %edi
  80220e:	56                   	push   %esi
  80220f:	53                   	push   %ebx
  802210:	83 ec 10             	sub    $0x10,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802213:	8b 45 08             	mov    0x8(%ebp),%eax
  802216:	8b 55 0c             	mov    0xc(%ebp),%edx
  802219:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80221c:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80221f:	8b 7d 18             	mov    0x18(%ebp),%edi
  802222:	8b 75 1c             	mov    0x1c(%ebp),%esi
  802225:	cd 30                	int    $0x30
  802227:	89 45 f0             	mov    %eax,-0x10(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	return ret;
  80222a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  80222d:	83 c4 10             	add    $0x10,%esp
  802230:	5b                   	pop    %ebx
  802231:	5e                   	pop    %esi
  802232:	5f                   	pop    %edi
  802233:	5d                   	pop    %ebp
  802234:	c3                   	ret    

00802235 <sys_cputs>:

void
sys_cputs(const char *s, uint32 len, uint8 printProgName)
{
  802235:	55                   	push   %ebp
  802236:	89 e5                	mov    %esp,%ebp
  802238:	83 ec 04             	sub    $0x4,%esp
  80223b:	8b 45 10             	mov    0x10(%ebp),%eax
  80223e:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputs, (uint32) s, len, (uint32)printProgName, 0, 0);
  802241:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  802245:	8b 45 08             	mov    0x8(%ebp),%eax
  802248:	6a 00                	push   $0x0
  80224a:	6a 00                	push   $0x0
  80224c:	52                   	push   %edx
  80224d:	ff 75 0c             	pushl  0xc(%ebp)
  802250:	50                   	push   %eax
  802251:	6a 00                	push   $0x0
  802253:	e8 b2 ff ff ff       	call   80220a <syscall>
  802258:	83 c4 18             	add    $0x18,%esp
}
  80225b:	90                   	nop
  80225c:	c9                   	leave  
  80225d:	c3                   	ret    

0080225e <sys_cgetc>:

int
sys_cgetc(void)
{
  80225e:	55                   	push   %ebp
  80225f:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
  802261:	6a 00                	push   $0x0
  802263:	6a 00                	push   $0x0
  802265:	6a 00                	push   $0x0
  802267:	6a 00                	push   $0x0
  802269:	6a 00                	push   $0x0
  80226b:	6a 02                	push   $0x2
  80226d:	e8 98 ff ff ff       	call   80220a <syscall>
  802272:	83 c4 18             	add    $0x18,%esp
}
  802275:	c9                   	leave  
  802276:	c3                   	ret    

00802277 <sys_lock_cons>:

void sys_lock_cons(void)
{
  802277:	55                   	push   %ebp
  802278:	89 e5                	mov    %esp,%ebp
	syscall(SYS_lock_cons, 0, 0, 0, 0, 0);
  80227a:	6a 00                	push   $0x0
  80227c:	6a 00                	push   $0x0
  80227e:	6a 00                	push   $0x0
  802280:	6a 00                	push   $0x0
  802282:	6a 00                	push   $0x0
  802284:	6a 03                	push   $0x3
  802286:	e8 7f ff ff ff       	call   80220a <syscall>
  80228b:	83 c4 18             	add    $0x18,%esp
}
  80228e:	90                   	nop
  80228f:	c9                   	leave  
  802290:	c3                   	ret    

00802291 <sys_unlock_cons>:
void sys_unlock_cons(void)
{
  802291:	55                   	push   %ebp
  802292:	89 e5                	mov    %esp,%ebp
	syscall(SYS_unlock_cons, 0, 0, 0, 0, 0);
  802294:	6a 00                	push   $0x0
  802296:	6a 00                	push   $0x0
  802298:	6a 00                	push   $0x0
  80229a:	6a 00                	push   $0x0
  80229c:	6a 00                	push   $0x0
  80229e:	6a 04                	push   $0x4
  8022a0:	e8 65 ff ff ff       	call   80220a <syscall>
  8022a5:	83 c4 18             	add    $0x18,%esp
}
  8022a8:	90                   	nop
  8022a9:	c9                   	leave  
  8022aa:	c3                   	ret    

008022ab <__sys_allocate_page>:

int __sys_allocate_page(void *va, int perm)
{
  8022ab:	55                   	push   %ebp
  8022ac:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
  8022ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b4:	6a 00                	push   $0x0
  8022b6:	6a 00                	push   $0x0
  8022b8:	6a 00                	push   $0x0
  8022ba:	52                   	push   %edx
  8022bb:	50                   	push   %eax
  8022bc:	6a 08                	push   $0x8
  8022be:	e8 47 ff ff ff       	call   80220a <syscall>
  8022c3:	83 c4 18             	add    $0x18,%esp
}
  8022c6:	c9                   	leave  
  8022c7:	c3                   	ret    

008022c8 <__sys_map_frame>:

int __sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  8022c8:	55                   	push   %ebp
  8022c9:	89 e5                	mov    %esp,%ebp
  8022cb:	56                   	push   %esi
  8022cc:	53                   	push   %ebx
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
  8022cd:	8b 75 18             	mov    0x18(%ebp),%esi
  8022d0:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8022d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8022d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8022dc:	56                   	push   %esi
  8022dd:	53                   	push   %ebx
  8022de:	51                   	push   %ecx
  8022df:	52                   	push   %edx
  8022e0:	50                   	push   %eax
  8022e1:	6a 09                	push   $0x9
  8022e3:	e8 22 ff ff ff       	call   80220a <syscall>
  8022e8:	83 c4 18             	add    $0x18,%esp
}
  8022eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022ee:	5b                   	pop    %ebx
  8022ef:	5e                   	pop    %esi
  8022f0:	5d                   	pop    %ebp
  8022f1:	c3                   	ret    

008022f2 <__sys_unmap_frame>:

int __sys_unmap_frame(int32 envid, void *va)
{
  8022f2:	55                   	push   %ebp
  8022f3:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
  8022f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022fb:	6a 00                	push   $0x0
  8022fd:	6a 00                	push   $0x0
  8022ff:	6a 00                	push   $0x0
  802301:	52                   	push   %edx
  802302:	50                   	push   %eax
  802303:	6a 0a                	push   $0xa
  802305:	e8 00 ff ff ff       	call   80220a <syscall>
  80230a:	83 c4 18             	add    $0x18,%esp
}
  80230d:	c9                   	leave  
  80230e:	c3                   	ret    

0080230f <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  80230f:	55                   	push   %ebp
  802310:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
  802312:	6a 00                	push   $0x0
  802314:	6a 00                	push   $0x0
  802316:	6a 00                	push   $0x0
  802318:	ff 75 0c             	pushl  0xc(%ebp)
  80231b:	ff 75 08             	pushl  0x8(%ebp)
  80231e:	6a 0b                	push   $0xb
  802320:	e8 e5 fe ff ff       	call   80220a <syscall>
  802325:	83 c4 18             	add    $0x18,%esp
}
  802328:	c9                   	leave  
  802329:	c3                   	ret    

0080232a <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  80232a:	55                   	push   %ebp
  80232b:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
  80232d:	6a 00                	push   $0x0
  80232f:	6a 00                	push   $0x0
  802331:	6a 00                	push   $0x0
  802333:	6a 00                	push   $0x0
  802335:	6a 00                	push   $0x0
  802337:	6a 0c                	push   $0xc
  802339:	e8 cc fe ff ff       	call   80220a <syscall>
  80233e:	83 c4 18             	add    $0x18,%esp
}
  802341:	c9                   	leave  
  802342:	c3                   	ret    

00802343 <sys_calculate_modified_frames>:
uint32 sys_calculate_modified_frames()
{
  802343:	55                   	push   %ebp
  802344:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_modified_frames, 0, 0, 0, 0, 0);
  802346:	6a 00                	push   $0x0
  802348:	6a 00                	push   $0x0
  80234a:	6a 00                	push   $0x0
  80234c:	6a 00                	push   $0x0
  80234e:	6a 00                	push   $0x0
  802350:	6a 0d                	push   $0xd
  802352:	e8 b3 fe ff ff       	call   80220a <syscall>
  802357:	83 c4 18             	add    $0x18,%esp
}
  80235a:	c9                   	leave  
  80235b:	c3                   	ret    

0080235c <sys_calculate_notmod_frames>:

uint32 sys_calculate_notmod_frames()
{
  80235c:	55                   	push   %ebp
  80235d:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_notmod_frames, 0, 0, 0, 0, 0);
  80235f:	6a 00                	push   $0x0
  802361:	6a 00                	push   $0x0
  802363:	6a 00                	push   $0x0
  802365:	6a 00                	push   $0x0
  802367:	6a 00                	push   $0x0
  802369:	6a 0e                	push   $0xe
  80236b:	e8 9a fe ff ff       	call   80220a <syscall>
  802370:	83 c4 18             	add    $0x18,%esp
}
  802373:	c9                   	leave  
  802374:	c3                   	ret    

00802375 <sys_pf_calculate_allocated_pages>:

int sys_pf_calculate_allocated_pages()
{
  802375:	55                   	push   %ebp
  802376:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_pf_calc_allocated_pages, 0,0,0,0,0);
  802378:	6a 00                	push   $0x0
  80237a:	6a 00                	push   $0x0
  80237c:	6a 00                	push   $0x0
  80237e:	6a 00                	push   $0x0
  802380:	6a 00                	push   $0x0
  802382:	6a 0f                	push   $0xf
  802384:	e8 81 fe ff ff       	call   80220a <syscall>
  802389:	83 c4 18             	add    $0x18,%esp
}
  80238c:	c9                   	leave  
  80238d:	c3                   	ret    

0080238e <sys_calculate_pages_tobe_removed_ready_exit>:

int sys_calculate_pages_tobe_removed_ready_exit(uint32 WS_or_MEMORY_flag)
{
  80238e:	55                   	push   %ebp
  80238f:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calculate_pages_tobe_removed_ready_exit, WS_or_MEMORY_flag,0,0,0,0);
  802391:	6a 00                	push   $0x0
  802393:	6a 00                	push   $0x0
  802395:	6a 00                	push   $0x0
  802397:	6a 00                	push   $0x0
  802399:	ff 75 08             	pushl  0x8(%ebp)
  80239c:	6a 10                	push   $0x10
  80239e:	e8 67 fe ff ff       	call   80220a <syscall>
  8023a3:	83 c4 18             	add    $0x18,%esp
}
  8023a6:	c9                   	leave  
  8023a7:	c3                   	ret    

008023a8 <sys_scarce_memory>:

void sys_scarce_memory()
{
  8023a8:	55                   	push   %ebp
  8023a9:	89 e5                	mov    %esp,%ebp
	syscall(SYS_scarce_memory,0,0,0,0,0);
  8023ab:	6a 00                	push   $0x0
  8023ad:	6a 00                	push   $0x0
  8023af:	6a 00                	push   $0x0
  8023b1:	6a 00                	push   $0x0
  8023b3:	6a 00                	push   $0x0
  8023b5:	6a 11                	push   $0x11
  8023b7:	e8 4e fe ff ff       	call   80220a <syscall>
  8023bc:	83 c4 18             	add    $0x18,%esp
}
  8023bf:	90                   	nop
  8023c0:	c9                   	leave  
  8023c1:	c3                   	ret    

008023c2 <sys_cputc>:

void
sys_cputc(const char c)
{
  8023c2:	55                   	push   %ebp
  8023c3:	89 e5                	mov    %esp,%ebp
  8023c5:	83 ec 04             	sub    $0x4,%esp
  8023c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8023cb:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputc, (uint32) c, 0, 0, 0, 0);
  8023ce:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  8023d2:	6a 00                	push   $0x0
  8023d4:	6a 00                	push   $0x0
  8023d6:	6a 00                	push   $0x0
  8023d8:	6a 00                	push   $0x0
  8023da:	50                   	push   %eax
  8023db:	6a 01                	push   $0x1
  8023dd:	e8 28 fe ff ff       	call   80220a <syscall>
  8023e2:	83 c4 18             	add    $0x18,%esp
}
  8023e5:	90                   	nop
  8023e6:	c9                   	leave  
  8023e7:	c3                   	ret    

008023e8 <sys_clear_ffl>:


//NEW'12: BONUS2 Testing
void
sys_clear_ffl()
{
  8023e8:	55                   	push   %ebp
  8023e9:	89 e5                	mov    %esp,%ebp
	syscall(SYS_clearFFL,0, 0, 0, 0, 0);
  8023eb:	6a 00                	push   $0x0
  8023ed:	6a 00                	push   $0x0
  8023ef:	6a 00                	push   $0x0
  8023f1:	6a 00                	push   $0x0
  8023f3:	6a 00                	push   $0x0
  8023f5:	6a 14                	push   $0x14
  8023f7:	e8 0e fe ff ff       	call   80220a <syscall>
  8023fc:	83 c4 18             	add    $0x18,%esp
}
  8023ff:	90                   	nop
  802400:	c9                   	leave  
  802401:	c3                   	ret    

00802402 <sys_createSharedObject>:

int sys_createSharedObject(char* shareName, uint32 size, uint8 isWritable, void* virtual_address)
{
  802402:	55                   	push   %ebp
  802403:	89 e5                	mov    %esp,%ebp
  802405:	83 ec 04             	sub    $0x4,%esp
  802408:	8b 45 10             	mov    0x10(%ebp),%eax
  80240b:	88 45 fc             	mov    %al,-0x4(%ebp)
	return syscall(SYS_create_shared_object,(uint32)shareName, (uint32)size, isWritable, (uint32)virtual_address,  0);
  80240e:	8b 4d 14             	mov    0x14(%ebp),%ecx
  802411:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  802415:	8b 45 08             	mov    0x8(%ebp),%eax
  802418:	6a 00                	push   $0x0
  80241a:	51                   	push   %ecx
  80241b:	52                   	push   %edx
  80241c:	ff 75 0c             	pushl  0xc(%ebp)
  80241f:	50                   	push   %eax
  802420:	6a 15                	push   $0x15
  802422:	e8 e3 fd ff ff       	call   80220a <syscall>
  802427:	83 c4 18             	add    $0x18,%esp
}
  80242a:	c9                   	leave  
  80242b:	c3                   	ret    

0080242c <sys_getSizeOfSharedObject>:

//2017:
int sys_getSizeOfSharedObject(int32 ownerID, char* shareName)
{
  80242c:	55                   	push   %ebp
  80242d:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_size_of_shared_object,(uint32) ownerID, (uint32)shareName, 0, 0, 0);
  80242f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802432:	8b 45 08             	mov    0x8(%ebp),%eax
  802435:	6a 00                	push   $0x0
  802437:	6a 00                	push   $0x0
  802439:	6a 00                	push   $0x0
  80243b:	52                   	push   %edx
  80243c:	50                   	push   %eax
  80243d:	6a 16                	push   $0x16
  80243f:	e8 c6 fd ff ff       	call   80220a <syscall>
  802444:	83 c4 18             	add    $0x18,%esp
}
  802447:	c9                   	leave  
  802448:	c3                   	ret    

00802449 <sys_getSharedObject>:
//==========

int sys_getSharedObject(int32 ownerID, char* shareName, void* virtual_address)
{
  802449:	55                   	push   %ebp
  80244a:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_shared_object,(uint32) ownerID, (uint32)shareName, (uint32)virtual_address, 0, 0);
  80244c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80244f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802452:	8b 45 08             	mov    0x8(%ebp),%eax
  802455:	6a 00                	push   $0x0
  802457:	6a 00                	push   $0x0
  802459:	51                   	push   %ecx
  80245a:	52                   	push   %edx
  80245b:	50                   	push   %eax
  80245c:	6a 17                	push   $0x17
  80245e:	e8 a7 fd ff ff       	call   80220a <syscall>
  802463:	83 c4 18             	add    $0x18,%esp
}
  802466:	c9                   	leave  
  802467:	c3                   	ret    

00802468 <sys_freeSharedObject>:

int sys_freeSharedObject(int32 sharedObjectID, void *startVA)
{
  802468:	55                   	push   %ebp
  802469:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_free_shared_object,(uint32) sharedObjectID, (uint32) startVA, 0, 0, 0);
  80246b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80246e:	8b 45 08             	mov    0x8(%ebp),%eax
  802471:	6a 00                	push   $0x0
  802473:	6a 00                	push   $0x0
  802475:	6a 00                	push   $0x0
  802477:	52                   	push   %edx
  802478:	50                   	push   %eax
  802479:	6a 18                	push   $0x18
  80247b:	e8 8a fd ff ff       	call   80220a <syscall>
  802480:	83 c4 18             	add    $0x18,%esp
}
  802483:	c9                   	leave  
  802484:	c3                   	ret    

00802485 <sys_create_env>:

int sys_create_env(char* programName, unsigned int page_WS_size,unsigned int LRU_second_list_size,unsigned int percent_WS_pages_to_remove)
{
  802485:	55                   	push   %ebp
  802486:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_create_env,(uint32)programName, (uint32)page_WS_size,(uint32)LRU_second_list_size, (uint32)percent_WS_pages_to_remove, 0);
  802488:	8b 45 08             	mov    0x8(%ebp),%eax
  80248b:	6a 00                	push   $0x0
  80248d:	ff 75 14             	pushl  0x14(%ebp)
  802490:	ff 75 10             	pushl  0x10(%ebp)
  802493:	ff 75 0c             	pushl  0xc(%ebp)
  802496:	50                   	push   %eax
  802497:	6a 19                	push   $0x19
  802499:	e8 6c fd ff ff       	call   80220a <syscall>
  80249e:	83 c4 18             	add    $0x18,%esp
}
  8024a1:	c9                   	leave  
  8024a2:	c3                   	ret    

008024a3 <sys_run_env>:

void sys_run_env(int32 envId)
{
  8024a3:	55                   	push   %ebp
  8024a4:	89 e5                	mov    %esp,%ebp
	syscall(SYS_run_env, (int32)envId, 0, 0, 0, 0);
  8024a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8024a9:	6a 00                	push   $0x0
  8024ab:	6a 00                	push   $0x0
  8024ad:	6a 00                	push   $0x0
  8024af:	6a 00                	push   $0x0
  8024b1:	50                   	push   %eax
  8024b2:	6a 1a                	push   $0x1a
  8024b4:	e8 51 fd ff ff       	call   80220a <syscall>
  8024b9:	83 c4 18             	add    $0x18,%esp
}
  8024bc:	90                   	nop
  8024bd:	c9                   	leave  
  8024be:	c3                   	ret    

008024bf <sys_destroy_env>:

int sys_destroy_env(int32  envid)
{
  8024bf:	55                   	push   %ebp
  8024c0:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_destroy_env, envid, 0, 0, 0, 0);
  8024c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8024c5:	6a 00                	push   $0x0
  8024c7:	6a 00                	push   $0x0
  8024c9:	6a 00                	push   $0x0
  8024cb:	6a 00                	push   $0x0
  8024cd:	50                   	push   %eax
  8024ce:	6a 1b                	push   $0x1b
  8024d0:	e8 35 fd ff ff       	call   80220a <syscall>
  8024d5:	83 c4 18             	add    $0x18,%esp
}
  8024d8:	c9                   	leave  
  8024d9:	c3                   	ret    

008024da <sys_getenvid>:

int32 sys_getenvid(void)
{
  8024da:	55                   	push   %ebp
  8024db:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
  8024dd:	6a 00                	push   $0x0
  8024df:	6a 00                	push   $0x0
  8024e1:	6a 00                	push   $0x0
  8024e3:	6a 00                	push   $0x0
  8024e5:	6a 00                	push   $0x0
  8024e7:	6a 05                	push   $0x5
  8024e9:	e8 1c fd ff ff       	call   80220a <syscall>
  8024ee:	83 c4 18             	add    $0x18,%esp
}
  8024f1:	c9                   	leave  
  8024f2:	c3                   	ret    

008024f3 <sys_getenvindex>:

//2017
int32 sys_getenvindex(void)
{
  8024f3:	55                   	push   %ebp
  8024f4:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvindex, 0, 0, 0, 0, 0);
  8024f6:	6a 00                	push   $0x0
  8024f8:	6a 00                	push   $0x0
  8024fa:	6a 00                	push   $0x0
  8024fc:	6a 00                	push   $0x0
  8024fe:	6a 00                	push   $0x0
  802500:	6a 06                	push   $0x6
  802502:	e8 03 fd ff ff       	call   80220a <syscall>
  802507:	83 c4 18             	add    $0x18,%esp
}
  80250a:	c9                   	leave  
  80250b:	c3                   	ret    

0080250c <sys_getparentenvid>:

int32 sys_getparentenvid(void)
{
  80250c:	55                   	push   %ebp
  80250d:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getparentenvid, 0, 0, 0, 0, 0);
  80250f:	6a 00                	push   $0x0
  802511:	6a 00                	push   $0x0
  802513:	6a 00                	push   $0x0
  802515:	6a 00                	push   $0x0
  802517:	6a 00                	push   $0x0
  802519:	6a 07                	push   $0x7
  80251b:	e8 ea fc ff ff       	call   80220a <syscall>
  802520:	83 c4 18             	add    $0x18,%esp
}
  802523:	c9                   	leave  
  802524:	c3                   	ret    

00802525 <sys_exit_env>:


void sys_exit_env(void)
{
  802525:	55                   	push   %ebp
  802526:	89 e5                	mov    %esp,%ebp
	syscall(SYS_exit_env, 0, 0, 0, 0, 0);
  802528:	6a 00                	push   $0x0
  80252a:	6a 00                	push   $0x0
  80252c:	6a 00                	push   $0x0
  80252e:	6a 00                	push   $0x0
  802530:	6a 00                	push   $0x0
  802532:	6a 1c                	push   $0x1c
  802534:	e8 d1 fc ff ff       	call   80220a <syscall>
  802539:	83 c4 18             	add    $0x18,%esp
}
  80253c:	90                   	nop
  80253d:	c9                   	leave  
  80253e:	c3                   	ret    

0080253f <sys_get_virtual_time>:


struct uint64 sys_get_virtual_time()
{
  80253f:	55                   	push   %ebp
  802540:	89 e5                	mov    %esp,%ebp
  802542:	83 ec 10             	sub    $0x10,%esp
	struct uint64 result;
	syscall(SYS_get_virtual_time, (uint32)&(result.low), (uint32)&(result.hi), 0, 0, 0);
  802545:	8d 45 f8             	lea    -0x8(%ebp),%eax
  802548:	8d 50 04             	lea    0x4(%eax),%edx
  80254b:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80254e:	6a 00                	push   $0x0
  802550:	6a 00                	push   $0x0
  802552:	6a 00                	push   $0x0
  802554:	52                   	push   %edx
  802555:	50                   	push   %eax
  802556:	6a 1d                	push   $0x1d
  802558:	e8 ad fc ff ff       	call   80220a <syscall>
  80255d:	83 c4 18             	add    $0x18,%esp
	return result;
  802560:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802563:	8b 45 f8             	mov    -0x8(%ebp),%eax
  802566:	8b 55 fc             	mov    -0x4(%ebp),%edx
  802569:	89 01                	mov    %eax,(%ecx)
  80256b:	89 51 04             	mov    %edx,0x4(%ecx)
}
  80256e:	8b 45 08             	mov    0x8(%ebp),%eax
  802571:	c9                   	leave  
  802572:	c2 04 00             	ret    $0x4

00802575 <sys_move_user_mem>:

// 2014
void sys_move_user_mem(uint32 src_virtual_address, uint32 dst_virtual_address, uint32 size)
{
  802575:	55                   	push   %ebp
  802576:	89 e5                	mov    %esp,%ebp
	syscall(SYS_move_user_mem, src_virtual_address, dst_virtual_address, size, 0, 0);
  802578:	6a 00                	push   $0x0
  80257a:	6a 00                	push   $0x0
  80257c:	ff 75 10             	pushl  0x10(%ebp)
  80257f:	ff 75 0c             	pushl  0xc(%ebp)
  802582:	ff 75 08             	pushl  0x8(%ebp)
  802585:	6a 13                	push   $0x13
  802587:	e8 7e fc ff ff       	call   80220a <syscall>
  80258c:	83 c4 18             	add    $0x18,%esp
	return ;
  80258f:	90                   	nop
}
  802590:	c9                   	leave  
  802591:	c3                   	ret    

00802592 <sys_rcr2>:
uint32 sys_rcr2()
{
  802592:	55                   	push   %ebp
  802593:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_rcr2, 0, 0, 0, 0, 0);
  802595:	6a 00                	push   $0x0
  802597:	6a 00                	push   $0x0
  802599:	6a 00                	push   $0x0
  80259b:	6a 00                	push   $0x0
  80259d:	6a 00                	push   $0x0
  80259f:	6a 1e                	push   $0x1e
  8025a1:	e8 64 fc ff ff       	call   80220a <syscall>
  8025a6:	83 c4 18             	add    $0x18,%esp
}
  8025a9:	c9                   	leave  
  8025aa:	c3                   	ret    

008025ab <sys_bypassPageFault>:

void sys_bypassPageFault(uint8 instrLength)
{
  8025ab:	55                   	push   %ebp
  8025ac:	89 e5                	mov    %esp,%ebp
  8025ae:	83 ec 04             	sub    $0x4,%esp
  8025b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8025b4:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_bypassPageFault, instrLength, 0, 0, 0, 0);
  8025b7:	0f b6 45 fc          	movzbl -0x4(%ebp),%eax
  8025bb:	6a 00                	push   $0x0
  8025bd:	6a 00                	push   $0x0
  8025bf:	6a 00                	push   $0x0
  8025c1:	6a 00                	push   $0x0
  8025c3:	50                   	push   %eax
  8025c4:	6a 1f                	push   $0x1f
  8025c6:	e8 3f fc ff ff       	call   80220a <syscall>
  8025cb:	83 c4 18             	add    $0x18,%esp
	return ;
  8025ce:	90                   	nop
}
  8025cf:	c9                   	leave  
  8025d0:	c3                   	ret    

008025d1 <rsttst>:
void rsttst()
{
  8025d1:	55                   	push   %ebp
  8025d2:	89 e5                	mov    %esp,%ebp
	syscall(SYS_rsttst, 0, 0, 0, 0, 0);
  8025d4:	6a 00                	push   $0x0
  8025d6:	6a 00                	push   $0x0
  8025d8:	6a 00                	push   $0x0
  8025da:	6a 00                	push   $0x0
  8025dc:	6a 00                	push   $0x0
  8025de:	6a 21                	push   $0x21
  8025e0:	e8 25 fc ff ff       	call   80220a <syscall>
  8025e5:	83 c4 18             	add    $0x18,%esp
	return ;
  8025e8:	90                   	nop
}
  8025e9:	c9                   	leave  
  8025ea:	c3                   	ret    

008025eb <tst>:
void tst(uint32 n, uint32 v1, uint32 v2, char c, int inv)
{
  8025eb:	55                   	push   %ebp
  8025ec:	89 e5                	mov    %esp,%ebp
  8025ee:	83 ec 04             	sub    $0x4,%esp
  8025f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8025f4:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_testNum, n, v1, v2, c, inv);
  8025f7:	8b 55 18             	mov    0x18(%ebp),%edx
  8025fa:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  8025fe:	52                   	push   %edx
  8025ff:	50                   	push   %eax
  802600:	ff 75 10             	pushl  0x10(%ebp)
  802603:	ff 75 0c             	pushl  0xc(%ebp)
  802606:	ff 75 08             	pushl  0x8(%ebp)
  802609:	6a 20                	push   $0x20
  80260b:	e8 fa fb ff ff       	call   80220a <syscall>
  802610:	83 c4 18             	add    $0x18,%esp
	return ;
  802613:	90                   	nop
}
  802614:	c9                   	leave  
  802615:	c3                   	ret    

00802616 <chktst>:
void chktst(uint32 n)
{
  802616:	55                   	push   %ebp
  802617:	89 e5                	mov    %esp,%ebp
	syscall(SYS_chktst, n, 0, 0, 0, 0);
  802619:	6a 00                	push   $0x0
  80261b:	6a 00                	push   $0x0
  80261d:	6a 00                	push   $0x0
  80261f:	6a 00                	push   $0x0
  802621:	ff 75 08             	pushl  0x8(%ebp)
  802624:	6a 22                	push   $0x22
  802626:	e8 df fb ff ff       	call   80220a <syscall>
  80262b:	83 c4 18             	add    $0x18,%esp
	return ;
  80262e:	90                   	nop
}
  80262f:	c9                   	leave  
  802630:	c3                   	ret    

00802631 <inctst>:

void inctst()
{
  802631:	55                   	push   %ebp
  802632:	89 e5                	mov    %esp,%ebp
	syscall(SYS_inctst, 0, 0, 0, 0, 0);
  802634:	6a 00                	push   $0x0
  802636:	6a 00                	push   $0x0
  802638:	6a 00                	push   $0x0
  80263a:	6a 00                	push   $0x0
  80263c:	6a 00                	push   $0x0
  80263e:	6a 23                	push   $0x23
  802640:	e8 c5 fb ff ff       	call   80220a <syscall>
  802645:	83 c4 18             	add    $0x18,%esp
	return ;
  802648:	90                   	nop
}
  802649:	c9                   	leave  
  80264a:	c3                   	ret    

0080264b <gettst>:
uint32 gettst()
{
  80264b:	55                   	push   %ebp
  80264c:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_gettst, 0, 0, 0, 0, 0);
  80264e:	6a 00                	push   $0x0
  802650:	6a 00                	push   $0x0
  802652:	6a 00                	push   $0x0
  802654:	6a 00                	push   $0x0
  802656:	6a 00                	push   $0x0
  802658:	6a 24                	push   $0x24
  80265a:	e8 ab fb ff ff       	call   80220a <syscall>
  80265f:	83 c4 18             	add    $0x18,%esp
}
  802662:	c9                   	leave  
  802663:	c3                   	ret    

00802664 <sys_isUHeapPlacementStrategyFIRSTFIT>:


//2015
uint32 sys_isUHeapPlacementStrategyFIRSTFIT()
{
  802664:	55                   	push   %ebp
  802665:	89 e5                	mov    %esp,%ebp
  802667:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  80266a:	6a 00                	push   $0x0
  80266c:	6a 00                	push   $0x0
  80266e:	6a 00                	push   $0x0
  802670:	6a 00                	push   $0x0
  802672:	6a 00                	push   $0x0
  802674:	6a 25                	push   $0x25
  802676:	e8 8f fb ff ff       	call   80220a <syscall>
  80267b:	83 c4 18             	add    $0x18,%esp
  80267e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_FIRSTFIT)
  802681:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
  802685:	75 07                	jne    80268e <sys_isUHeapPlacementStrategyFIRSTFIT+0x2a>
		return 1;
  802687:	b8 01 00 00 00       	mov    $0x1,%eax
  80268c:	eb 05                	jmp    802693 <sys_isUHeapPlacementStrategyFIRSTFIT+0x2f>
	else
		return 0;
  80268e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802693:	c9                   	leave  
  802694:	c3                   	ret    

00802695 <sys_isUHeapPlacementStrategyBESTFIT>:
uint32 sys_isUHeapPlacementStrategyBESTFIT()
{
  802695:	55                   	push   %ebp
  802696:	89 e5                	mov    %esp,%ebp
  802698:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  80269b:	6a 00                	push   $0x0
  80269d:	6a 00                	push   $0x0
  80269f:	6a 00                	push   $0x0
  8026a1:	6a 00                	push   $0x0
  8026a3:	6a 00                	push   $0x0
  8026a5:	6a 25                	push   $0x25
  8026a7:	e8 5e fb ff ff       	call   80220a <syscall>
  8026ac:	83 c4 18             	add    $0x18,%esp
  8026af:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_BESTFIT)
  8026b2:	83 7d fc 02          	cmpl   $0x2,-0x4(%ebp)
  8026b6:	75 07                	jne    8026bf <sys_isUHeapPlacementStrategyBESTFIT+0x2a>
		return 1;
  8026b8:	b8 01 00 00 00       	mov    $0x1,%eax
  8026bd:	eb 05                	jmp    8026c4 <sys_isUHeapPlacementStrategyBESTFIT+0x2f>
	else
		return 0;
  8026bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8026c4:	c9                   	leave  
  8026c5:	c3                   	ret    

008026c6 <sys_isUHeapPlacementStrategyNEXTFIT>:
uint32 sys_isUHeapPlacementStrategyNEXTFIT()
{
  8026c6:	55                   	push   %ebp
  8026c7:	89 e5                	mov    %esp,%ebp
  8026c9:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  8026cc:	6a 00                	push   $0x0
  8026ce:	6a 00                	push   $0x0
  8026d0:	6a 00                	push   $0x0
  8026d2:	6a 00                	push   $0x0
  8026d4:	6a 00                	push   $0x0
  8026d6:	6a 25                	push   $0x25
  8026d8:	e8 2d fb ff ff       	call   80220a <syscall>
  8026dd:	83 c4 18             	add    $0x18,%esp
  8026e0:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_NEXTFIT)
  8026e3:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
  8026e7:	75 07                	jne    8026f0 <sys_isUHeapPlacementStrategyNEXTFIT+0x2a>
		return 1;
  8026e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8026ee:	eb 05                	jmp    8026f5 <sys_isUHeapPlacementStrategyNEXTFIT+0x2f>
	else
		return 0;
  8026f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8026f5:	c9                   	leave  
  8026f6:	c3                   	ret    

008026f7 <sys_isUHeapPlacementStrategyWORSTFIT>:
uint32 sys_isUHeapPlacementStrategyWORSTFIT()
{
  8026f7:	55                   	push   %ebp
  8026f8:	89 e5                	mov    %esp,%ebp
  8026fa:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  8026fd:	6a 00                	push   $0x0
  8026ff:	6a 00                	push   $0x0
  802701:	6a 00                	push   $0x0
  802703:	6a 00                	push   $0x0
  802705:	6a 00                	push   $0x0
  802707:	6a 25                	push   $0x25
  802709:	e8 fc fa ff ff       	call   80220a <syscall>
  80270e:	83 c4 18             	add    $0x18,%esp
  802711:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_WORSTFIT)
  802714:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
  802718:	75 07                	jne    802721 <sys_isUHeapPlacementStrategyWORSTFIT+0x2a>
		return 1;
  80271a:	b8 01 00 00 00       	mov    $0x1,%eax
  80271f:	eb 05                	jmp    802726 <sys_isUHeapPlacementStrategyWORSTFIT+0x2f>
	else
		return 0;
  802721:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802726:	c9                   	leave  
  802727:	c3                   	ret    

00802728 <sys_set_uheap_strategy>:

void sys_set_uheap_strategy(uint32 heapStrategy)
{
  802728:	55                   	push   %ebp
  802729:	89 e5                	mov    %esp,%ebp
	syscall(SYS_set_heap_strategy, heapStrategy, 0, 0, 0, 0);
  80272b:	6a 00                	push   $0x0
  80272d:	6a 00                	push   $0x0
  80272f:	6a 00                	push   $0x0
  802731:	6a 00                	push   $0x0
  802733:	ff 75 08             	pushl  0x8(%ebp)
  802736:	6a 26                	push   $0x26
  802738:	e8 cd fa ff ff       	call   80220a <syscall>
  80273d:	83 c4 18             	add    $0x18,%esp
	return ;
  802740:	90                   	nop
}
  802741:	c9                   	leave  
  802742:	c3                   	ret    

00802743 <sys_check_LRU_lists>:

//2020
int sys_check_LRU_lists(uint32* active_list_content, uint32* second_list_content, int actual_active_list_size, int actual_second_list_size)
{
  802743:	55                   	push   %ebp
  802744:	89 e5                	mov    %esp,%ebp
  802746:	53                   	push   %ebx
	return syscall(SYS_check_LRU_lists, (uint32)active_list_content, (uint32)second_list_content, (uint32)actual_active_list_size, (uint32)actual_second_list_size, 0);
  802747:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80274a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80274d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802750:	8b 45 08             	mov    0x8(%ebp),%eax
  802753:	6a 00                	push   $0x0
  802755:	53                   	push   %ebx
  802756:	51                   	push   %ecx
  802757:	52                   	push   %edx
  802758:	50                   	push   %eax
  802759:	6a 27                	push   $0x27
  80275b:	e8 aa fa ff ff       	call   80220a <syscall>
  802760:	83 c4 18             	add    $0x18,%esp
}
  802763:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802766:	c9                   	leave  
  802767:	c3                   	ret    

00802768 <sys_check_LRU_lists_free>:

int sys_check_LRU_lists_free(uint32* list_content, int list_size)
{
  802768:	55                   	push   %ebp
  802769:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_LRU_lists_free, (uint32)list_content, (uint32)list_size , 0, 0, 0);
  80276b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80276e:	8b 45 08             	mov    0x8(%ebp),%eax
  802771:	6a 00                	push   $0x0
  802773:	6a 00                	push   $0x0
  802775:	6a 00                	push   $0x0
  802777:	52                   	push   %edx
  802778:	50                   	push   %eax
  802779:	6a 28                	push   $0x28
  80277b:	e8 8a fa ff ff       	call   80220a <syscall>
  802780:	83 c4 18             	add    $0x18,%esp
}
  802783:	c9                   	leave  
  802784:	c3                   	ret    

00802785 <sys_check_WS_list>:

int sys_check_WS_list(uint32* WS_list_content, int actual_WS_list_size, uint32 last_WS_element_content, bool chk_in_order)
{
  802785:	55                   	push   %ebp
  802786:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_WS_list, (uint32)WS_list_content, (uint32)actual_WS_list_size , last_WS_element_content, (uint32)chk_in_order, 0);
  802788:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80278b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80278e:	8b 45 08             	mov    0x8(%ebp),%eax
  802791:	6a 00                	push   $0x0
  802793:	51                   	push   %ecx
  802794:	ff 75 10             	pushl  0x10(%ebp)
  802797:	52                   	push   %edx
  802798:	50                   	push   %eax
  802799:	6a 29                	push   $0x29
  80279b:	e8 6a fa ff ff       	call   80220a <syscall>
  8027a0:	83 c4 18             	add    $0x18,%esp
}
  8027a3:	c9                   	leave  
  8027a4:	c3                   	ret    

008027a5 <sys_allocate_chunk>:
void sys_allocate_chunk(uint32 virtual_address, uint32 size, uint32 perms)
{
  8027a5:	55                   	push   %ebp
  8027a6:	89 e5                	mov    %esp,%ebp
	syscall(SYS_allocate_chunk_in_mem, virtual_address, size, perms, 0, 0);
  8027a8:	6a 00                	push   $0x0
  8027aa:	6a 00                	push   $0x0
  8027ac:	ff 75 10             	pushl  0x10(%ebp)
  8027af:	ff 75 0c             	pushl  0xc(%ebp)
  8027b2:	ff 75 08             	pushl  0x8(%ebp)
  8027b5:	6a 12                	push   $0x12
  8027b7:	e8 4e fa ff ff       	call   80220a <syscall>
  8027bc:	83 c4 18             	add    $0x18,%esp
	return ;
  8027bf:	90                   	nop
}
  8027c0:	c9                   	leave  
  8027c1:	c3                   	ret    

008027c2 <sys_utilities>:
void sys_utilities(char* utilityName, int value)
{
  8027c2:	55                   	push   %ebp
  8027c3:	89 e5                	mov    %esp,%ebp
	syscall(SYS_utilities, (uint32)utilityName, value, 0, 0, 0);
  8027c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8027c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8027cb:	6a 00                	push   $0x0
  8027cd:	6a 00                	push   $0x0
  8027cf:	6a 00                	push   $0x0
  8027d1:	52                   	push   %edx
  8027d2:	50                   	push   %eax
  8027d3:	6a 2a                	push   $0x2a
  8027d5:	e8 30 fa ff ff       	call   80220a <syscall>
  8027da:	83 c4 18             	add    $0x18,%esp
	return;
  8027dd:	90                   	nop
}
  8027de:	c9                   	leave  
  8027df:	c3                   	ret    

008027e0 <sys_sbrk>:


//TODO: [PROJECT'24.MS1 - #02] [2] SYSTEM CALLS - Implement these system calls
void* sys_sbrk(int increment)
{
  8027e0:	55                   	push   %ebp
  8027e1:	89 e5                	mov    %esp,%ebp
	syscall( SYS_sbrk ,increment,0,0,0,0)  ;
  8027e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8027e6:	6a 00                	push   $0x0
  8027e8:	6a 00                	push   $0x0
  8027ea:	6a 00                	push   $0x0
  8027ec:	6a 00                	push   $0x0
  8027ee:	50                   	push   %eax
  8027ef:	6a 2b                	push   $0x2b
  8027f1:	e8 14 fa ff ff       	call   80220a <syscall>
  8027f6:	83 c4 18             	add    $0x18,%esp

	return (void*)-1 ;
  8027f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

}
  8027fe:	c9                   	leave  
  8027ff:	c3                   	ret    

00802800 <sys_free_user_mem>:
void sys_free_user_mem(uint32 virtual_address, uint32 size)
{
  802800:	55                   	push   %ebp
  802801:	89 e5                	mov    %esp,%ebp
	syscall(SYS_free_user_mem,virtual_address,size,0,0,0);
  802803:	6a 00                	push   $0x0
  802805:	6a 00                	push   $0x0
  802807:	6a 00                	push   $0x0
  802809:	ff 75 0c             	pushl  0xc(%ebp)
  80280c:	ff 75 08             	pushl  0x8(%ebp)
  80280f:	6a 2c                	push   $0x2c
  802811:	e8 f4 f9 ff ff       	call   80220a <syscall>
  802816:	83 c4 18             	add    $0x18,%esp
	return;
  802819:	90                   	nop
}
  80281a:	c9                   	leave  
  80281b:	c3                   	ret    

0080281c <sys_allocate_user_mem>:

void sys_allocate_user_mem(uint32 virtual_address, uint32 size)
{
  80281c:	55                   	push   %ebp
  80281d:	89 e5                	mov    %esp,%ebp
	syscall(SYS_allocate_user_mem,virtual_address,size,0,0,0);
  80281f:	6a 00                	push   $0x0
  802821:	6a 00                	push   $0x0
  802823:	6a 00                	push   $0x0
  802825:	ff 75 0c             	pushl  0xc(%ebp)
  802828:	ff 75 08             	pushl  0x8(%ebp)
  80282b:	6a 2d                	push   $0x2d
  80282d:	e8 d8 f9 ff ff       	call   80220a <syscall>
  802832:	83 c4 18             	add    $0x18,%esp
	return;
  802835:	90                   	nop
}
  802836:	c9                   	leave  
  802837:	c3                   	ret    

00802838 <get_block_size>:

//=====================================================
// 1) GET BLOCK SIZE (including size of its meta data):
//=====================================================
__inline__ uint32 get_block_size(void* va)
{
  802838:	55                   	push   %ebp
  802839:	89 e5                	mov    %esp,%ebp
  80283b:	83 ec 10             	sub    $0x10,%esp
	uint32 *curBlkMetaData = ((uint32 *)va - 1) ;
  80283e:	8b 45 08             	mov    0x8(%ebp),%eax
  802841:	83 e8 04             	sub    $0x4,%eax
  802844:	89 45 fc             	mov    %eax,-0x4(%ebp)
	return (*curBlkMetaData) & ~(0x1);
  802847:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80284a:	8b 00                	mov    (%eax),%eax
  80284c:	83 e0 fe             	and    $0xfffffffe,%eax
}
  80284f:	c9                   	leave  
  802850:	c3                   	ret    

00802851 <is_free_block>:

//===========================
// 2) GET BLOCK STATUS:
//===========================
__inline__ int8 is_free_block(void* va)
{
  802851:	55                   	push   %ebp
  802852:	89 e5                	mov    %esp,%ebp
  802854:	83 ec 10             	sub    $0x10,%esp
	uint32 *curBlkMetaData = ((uint32 *)va - 1) ;
  802857:	8b 45 08             	mov    0x8(%ebp),%eax
  80285a:	83 e8 04             	sub    $0x4,%eax
  80285d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	return (~(*curBlkMetaData) & 0x1) ;
  802860:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802863:	8b 00                	mov    (%eax),%eax
  802865:	83 e0 01             	and    $0x1,%eax
  802868:	85 c0                	test   %eax,%eax
  80286a:	0f 94 c0             	sete   %al
}
  80286d:	c9                   	leave  
  80286e:	c3                   	ret    

0080286f <alloc_block>:
//===========================
// 3) ALLOCATE BLOCK:
//===========================

void *alloc_block(uint32 size, int ALLOC_STRATEGY)
{
  80286f:	55                   	push   %ebp
  802870:	89 e5                	mov    %esp,%ebp
  802872:	83 ec 18             	sub    $0x18,%esp
	void *va = NULL;
  802875:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	switch (ALLOC_STRATEGY)
  80287c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80287f:	83 f8 02             	cmp    $0x2,%eax
  802882:	74 2b                	je     8028af <alloc_block+0x40>
  802884:	83 f8 02             	cmp    $0x2,%eax
  802887:	7f 07                	jg     802890 <alloc_block+0x21>
  802889:	83 f8 01             	cmp    $0x1,%eax
  80288c:	74 0e                	je     80289c <alloc_block+0x2d>
  80288e:	eb 58                	jmp    8028e8 <alloc_block+0x79>
  802890:	83 f8 03             	cmp    $0x3,%eax
  802893:	74 2d                	je     8028c2 <alloc_block+0x53>
  802895:	83 f8 04             	cmp    $0x4,%eax
  802898:	74 3b                	je     8028d5 <alloc_block+0x66>
  80289a:	eb 4c                	jmp    8028e8 <alloc_block+0x79>
	{
	case DA_FF:
		va = alloc_block_FF(size);
  80289c:	83 ec 0c             	sub    $0xc,%esp
  80289f:	ff 75 08             	pushl  0x8(%ebp)
  8028a2:	e8 5f 02 00 00       	call   802b06 <alloc_block_FF>
  8028a7:	83 c4 10             	add    $0x10,%esp
  8028aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
		break;
  8028ad:	eb 4a                	jmp    8028f9 <alloc_block+0x8a>
	case DA_NF:
		va = alloc_block_NF(size);
  8028af:	83 ec 0c             	sub    $0xc,%esp
  8028b2:	ff 75 08             	pushl  0x8(%ebp)
  8028b5:	e8 d3 13 00 00       	call   803c8d <alloc_block_NF>
  8028ba:	83 c4 10             	add    $0x10,%esp
  8028bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
		break;
  8028c0:	eb 37                	jmp    8028f9 <alloc_block+0x8a>
	case DA_BF:
		va = alloc_block_BF(size);
  8028c2:	83 ec 0c             	sub    $0xc,%esp
  8028c5:	ff 75 08             	pushl  0x8(%ebp)
  8028c8:	e8 f2 07 00 00       	call   8030bf <alloc_block_BF>
  8028cd:	83 c4 10             	add    $0x10,%esp
  8028d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
		break;
  8028d3:	eb 24                	jmp    8028f9 <alloc_block+0x8a>
	case DA_WF:
		va = alloc_block_WF(size);
  8028d5:	83 ec 0c             	sub    $0xc,%esp
  8028d8:	ff 75 08             	pushl  0x8(%ebp)
  8028db:	e8 90 13 00 00       	call   803c70 <alloc_block_WF>
  8028e0:	83 c4 10             	add    $0x10,%esp
  8028e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
		break;
  8028e6:	eb 11                	jmp    8028f9 <alloc_block+0x8a>
	default:
		cprintf("Invalid allocation strategy\n");
  8028e8:	83 ec 0c             	sub    $0xc,%esp
  8028eb:	68 58 4e 80 00       	push   $0x804e58
  8028f0:	e8 51 ea ff ff       	call   801346 <cprintf>
  8028f5:	83 c4 10             	add    $0x10,%esp
		break;
  8028f8:	90                   	nop
	}
	return va;
  8028f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8028fc:	c9                   	leave  
  8028fd:	c3                   	ret    

008028fe <print_blocks_list>:
//===========================
// 4) PRINT BLOCKS LIST:
//===========================

void print_blocks_list(struct MemBlock_LIST list)
{
  8028fe:	55                   	push   %ebp
  8028ff:	89 e5                	mov    %esp,%ebp
  802901:	53                   	push   %ebx
  802902:	83 ec 14             	sub    $0x14,%esp
	cprintf("=========================================\n");
  802905:	83 ec 0c             	sub    $0xc,%esp
  802908:	68 78 4e 80 00       	push   $0x804e78
  80290d:	e8 34 ea ff ff       	call   801346 <cprintf>
  802912:	83 c4 10             	add    $0x10,%esp
	struct BlockElement* blk ;
	cprintf("\nDynAlloc Blocks List:\n");
  802915:	83 ec 0c             	sub    $0xc,%esp
  802918:	68 a3 4e 80 00       	push   $0x804ea3
  80291d:	e8 24 ea ff ff       	call   801346 <cprintf>
  802922:	83 c4 10             	add    $0x10,%esp
	LIST_FOREACH(blk, &list)
  802925:	8b 45 08             	mov    0x8(%ebp),%eax
  802928:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80292b:	eb 37                	jmp    802964 <print_blocks_list+0x66>
	{
		cprintf("(size: %d, isFree: %d)\n", get_block_size(blk), is_free_block(blk)) ;
  80292d:	83 ec 0c             	sub    $0xc,%esp
  802930:	ff 75 f4             	pushl  -0xc(%ebp)
  802933:	e8 19 ff ff ff       	call   802851 <is_free_block>
  802938:	83 c4 10             	add    $0x10,%esp
  80293b:	0f be d8             	movsbl %al,%ebx
  80293e:	83 ec 0c             	sub    $0xc,%esp
  802941:	ff 75 f4             	pushl  -0xc(%ebp)
  802944:	e8 ef fe ff ff       	call   802838 <get_block_size>
  802949:	83 c4 10             	add    $0x10,%esp
  80294c:	83 ec 04             	sub    $0x4,%esp
  80294f:	53                   	push   %ebx
  802950:	50                   	push   %eax
  802951:	68 bb 4e 80 00       	push   $0x804ebb
  802956:	e8 eb e9 ff ff       	call   801346 <cprintf>
  80295b:	83 c4 10             	add    $0x10,%esp
void print_blocks_list(struct MemBlock_LIST list)
{
	cprintf("=========================================\n");
	struct BlockElement* blk ;
	cprintf("\nDynAlloc Blocks List:\n");
	LIST_FOREACH(blk, &list)
  80295e:	8b 45 10             	mov    0x10(%ebp),%eax
  802961:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802964:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802968:	74 07                	je     802971 <print_blocks_list+0x73>
  80296a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80296d:	8b 00                	mov    (%eax),%eax
  80296f:	eb 05                	jmp    802976 <print_blocks_list+0x78>
  802971:	b8 00 00 00 00       	mov    $0x0,%eax
  802976:	89 45 10             	mov    %eax,0x10(%ebp)
  802979:	8b 45 10             	mov    0x10(%ebp),%eax
  80297c:	85 c0                	test   %eax,%eax
  80297e:	75 ad                	jne    80292d <print_blocks_list+0x2f>
  802980:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802984:	75 a7                	jne    80292d <print_blocks_list+0x2f>
	{
		cprintf("(size: %d, isFree: %d)\n", get_block_size(blk), is_free_block(blk)) ;
	}
	cprintf("=========================================\n");
  802986:	83 ec 0c             	sub    $0xc,%esp
  802989:	68 78 4e 80 00       	push   $0x804e78
  80298e:	e8 b3 e9 ff ff       	call   801346 <cprintf>
  802993:	83 c4 10             	add    $0x10,%esp

}
  802996:	90                   	nop
  802997:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80299a:	c9                   	leave  
  80299b:	c3                   	ret    

0080299c <initialize_dynamic_allocator>:
//==================================
// [1] INITIALIZE DYNAMIC ALLOCATOR:
//==================================
uint32 *dend;
void initialize_dynamic_allocator(uint32 daStart, uint32 initSizeOfAllocatedSpace)
{
  80299c:	55                   	push   %ebp
  80299d:	89 e5                	mov    %esp,%ebp
  80299f:	83 ec 18             	sub    $0x18,%esp

		//==================================================================================
		//DON'T CHANGE THESE LINES==========================================================
		//==================================================================================
		{
			if (initSizeOfAllocatedSpace % 2 != 0) initSizeOfAllocatedSpace++; //ensure it's multiple of 2
  8029a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029a5:	83 e0 01             	and    $0x1,%eax
  8029a8:	85 c0                	test   %eax,%eax
  8029aa:	74 03                	je     8029af <initialize_dynamic_allocator+0x13>
  8029ac:	ff 45 0c             	incl   0xc(%ebp)
			if (initSizeOfAllocatedSpace == 0)
  8029af:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8029b3:	0f 84 fd 00 00 00    	je     802ab6 <initialize_dynamic_allocator+0x11a>
				return ;
			is_initialized = 1;
  8029b9:	c7 05 24 60 80 00 01 	movl   $0x1,0x806024
  8029c0:	00 00 00 
		// (uint32)LIST_INIT(deStart);
		//(uint32)LIST_INIT(head)=daStart;
	 //(uint32)LIST_SIZE(&freeBlocksList);
	 //  print_blocks_list(freeBlocksList) ;//	(uint32)LIST_FIRST(&freeBlocksList)=daStart;
	 //print_block_list(freeBlocksList);
		uint32* dbeg=(uint32*)daStart ;
  8029c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8029c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
		 dend=(uint32*)(daStart+initSizeOfAllocatedSpace-sizeof(int));
  8029c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8029cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029cf:	01 d0                	add    %edx,%eax
  8029d1:	83 e8 04             	sub    $0x4,%eax
  8029d4:	a3 50 a2 80 00       	mov    %eax,0x80a250
		*dbeg=1;
  8029d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029dc:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
		*dend=1;
  8029e2:	a1 50 a2 80 00       	mov    0x80a250,%eax
  8029e7:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
		uint32* Header = (uint32*) (daStart + sizeof(int));
  8029ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8029f0:	83 c0 04             	add    $0x4,%eax
  8029f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	    uint32* Footer = (uint32*) (daStart + initSizeOfAllocatedSpace -2*sizeof(int));
  8029f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8029f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029fc:	01 d0                	add    %edx,%eax
  8029fe:	83 e8 08             	sub    $0x8,%eax
  802a01:	89 45 ec             	mov    %eax,-0x14(%ebp)
		*Header =initSizeOfAllocatedSpace - 2 * sizeof(int);
  802a04:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a07:	8d 50 f8             	lea    -0x8(%eax),%edx
  802a0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a0d:	89 10                	mov    %edx,(%eax)
		*Footer =initSizeOfAllocatedSpace - 2 * sizeof(int) ;
  802a0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a12:	8d 50 f8             	lea    -0x8(%eax),%edx
  802a15:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802a18:	89 10                	mov    %edx,(%eax)

		struct BlockElement *FreeBlock = (struct BlockElement * )( daStart + 2*sizeof(int));
  802a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  802a1d:	83 c0 08             	add    $0x8,%eax
  802a20:	89 45 e8             	mov    %eax,-0x18(%ebp)
		FreeBlock->prev_next_info.le_next=NULL;
  802a23:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802a26:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		FreeBlock->prev_next_info.le_prev=NULL;
  802a2c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802a2f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		LIST_INIT(&freeBlocksList) ;
  802a36:	c7 05 44 60 80 00 00 	movl   $0x0,0x806044
  802a3d:	00 00 00 
  802a40:	c7 05 48 60 80 00 00 	movl   $0x0,0x806048
  802a47:	00 00 00 
  802a4a:	c7 05 50 60 80 00 00 	movl   $0x0,0x806050
  802a51:	00 00 00 
		LIST_INSERT_HEAD(&freeBlocksList,FreeBlock);
  802a54:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  802a58:	75 14                	jne    802a6e <initialize_dynamic_allocator+0xd2>
  802a5a:	83 ec 04             	sub    $0x4,%esp
  802a5d:	68 d4 4e 80 00       	push   $0x804ed4
  802a62:	6a 7e                	push   $0x7e
  802a64:	68 f7 4e 80 00       	push   $0x804ef7
  802a69:	e8 1b e6 ff ff       	call   801089 <_panic>
  802a6e:	8b 15 44 60 80 00    	mov    0x806044,%edx
  802a74:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802a77:	89 10                	mov    %edx,(%eax)
  802a79:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802a7c:	8b 00                	mov    (%eax),%eax
  802a7e:	85 c0                	test   %eax,%eax
  802a80:	74 0d                	je     802a8f <initialize_dynamic_allocator+0xf3>
  802a82:	a1 44 60 80 00       	mov    0x806044,%eax
  802a87:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802a8a:	89 50 04             	mov    %edx,0x4(%eax)
  802a8d:	eb 08                	jmp    802a97 <initialize_dynamic_allocator+0xfb>
  802a8f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802a92:	a3 48 60 80 00       	mov    %eax,0x806048
  802a97:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802a9a:	a3 44 60 80 00       	mov    %eax,0x806044
  802a9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802aa2:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802aa9:	a1 50 60 80 00       	mov    0x806050,%eax
  802aae:	40                   	inc    %eax
  802aaf:	a3 50 60 80 00       	mov    %eax,0x806050
  802ab4:	eb 01                	jmp    802ab7 <initialize_dynamic_allocator+0x11b>
		//DON'T CHANGE THESE LINES==========================================================
		//==================================================================================
		{
			if (initSizeOfAllocatedSpace % 2 != 0) initSizeOfAllocatedSpace++; //ensure it's multiple of 2
			if (initSizeOfAllocatedSpace == 0)
				return ;
  802ab6:	90                   	nop
		LIST_INSERT_HEAD(&freeBlocksList,FreeBlock);
	    //panic("initialize_dynamic_allocator is not implemented yet");
	//set_block_data((struct BlockElement *)( daStart + 2*sizeof(int)), 65,1);
	//print_blocks_list(freeBlocksList);

}
  802ab7:	c9                   	leave  
  802ab8:	c3                   	ret    

00802ab9 <set_block_data>:
//==================================
// [2] SET BLOCK HEADER & FOOTER:
//==================================
void set_block_data(void* va, uint32 totalSize, bool isAllocated)
{
  802ab9:	55                   	push   %ebp
  802aba:	89 e5                	mov    %esp,%ebp
  802abc:	83 ec 10             	sub    $0x10,%esp

		//struct BlockElement *FreeBlock = (struct BlockElement * )( va );
		uint32 val= (uint32)totalSize ;
  802abf:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ac2:	89 45 fc             	mov    %eax,-0x4(%ebp)
		if(isAllocated){
  802ac5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802ac9:	74 04                	je     802acf <set_block_data+0x16>
			val|=1;
  802acb:	83 4d fc 01          	orl    $0x1,-0x4(%ebp)
		}

		if(totalSize%2!=0){
  802acf:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ad2:	83 e0 01             	and    $0x1,%eax
  802ad5:	85 c0                	test   %eax,%eax
  802ad7:	74 03                	je     802adc <set_block_data+0x23>
			val++	;
  802ad9:	ff 45 fc             	incl   -0x4(%ebp)
			}

		uint32* Header = (uint32*) (va -sizeof(int) );
  802adc:	8b 45 08             	mov    0x8(%ebp),%eax
  802adf:	83 e8 04             	sub    $0x4,%eax
  802ae2:	89 45 f8             	mov    %eax,-0x8(%ebp)
		uint32* Footer = (uint32*) (va+totalSize-(2*sizeof(int)));
  802ae5:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ae8:	8d 50 f8             	lea    -0x8(%eax),%edx
  802aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  802aee:	01 d0                	add    %edx,%eax
  802af0:	89 45 f4             	mov    %eax,-0xc(%ebp)
			*Header =(uint32)val ;
  802af3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  802af6:	8b 55 fc             	mov    -0x4(%ebp),%edx
  802af9:	89 10                	mov    %edx,(%eax)
			*Footer =(uint32)val  ;
  802afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802afe:	8b 55 fc             	mov    -0x4(%ebp),%edx
  802b01:	89 10                	mov    %edx,(%eax)
		//TODO: [PROJECT'24.MS1 - #05] [3] DYNAMIC ALLOCATOR - set_block_data
		//COMMENT THE FOLLOWING LINE BEFORE START CODING
		//panic("set_block_data is not implemented yet");
		//Your Code is Here...

}
  802b03:	90                   	nop
  802b04:	c9                   	leave  
  802b05:	c3                   	ret    

00802b06 <alloc_block_FF>:
//=========================================
// [3] ALLOCATE BLOCK BY FIRST FIT:
//=========================================

void *alloc_block_FF(uint32 size)
{
  802b06:	55                   	push   %ebp
  802b07:	89 e5                	mov    %esp,%ebp
  802b09:	83 ec 68             	sub    $0x68,%esp
	//==================================================================================
	//DON'T CHANGE THESE LINES==========================================================
	//==================================================================================
	{
		if (size % 2 != 0) size++;	//ensure that the size is even (to use LSB as allocation flag)
  802b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  802b0f:	83 e0 01             	and    $0x1,%eax
  802b12:	85 c0                	test   %eax,%eax
  802b14:	74 03                	je     802b19 <alloc_block_FF+0x13>
  802b16:	ff 45 08             	incl   0x8(%ebp)
		if (size < DYN_ALLOC_MIN_BLOCK_SIZE)
  802b19:	83 7d 08 07          	cmpl   $0x7,0x8(%ebp)
  802b1d:	77 07                	ja     802b26 <alloc_block_FF+0x20>
			size = DYN_ALLOC_MIN_BLOCK_SIZE ;
  802b1f:	c7 45 08 08 00 00 00 	movl   $0x8,0x8(%ebp)
		if (!is_initialized)
  802b26:	a1 24 60 80 00       	mov    0x806024,%eax
  802b2b:	85 c0                	test   %eax,%eax
  802b2d:	75 63                	jne    802b92 <alloc_block_FF+0x8c>
		{
			uint32 required_size = size + 2*sizeof(int) /*header & footer*/ + 2*sizeof(int) /*da begin & end*/ ;
  802b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  802b32:	83 c0 10             	add    $0x10,%eax
  802b35:	89 45 f0             	mov    %eax,-0x10(%ebp)
			uint32 da_start = (uint32)sbrk(ROUNDUP(required_size, PAGE_SIZE)/PAGE_SIZE);
  802b38:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%ebp)
  802b3f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802b42:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802b45:	01 d0                	add    %edx,%eax
  802b47:	48                   	dec    %eax
  802b48:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802b4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802b4e:	ba 00 00 00 00       	mov    $0x0,%edx
  802b53:	f7 75 ec             	divl   -0x14(%ebp)
  802b56:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802b59:	29 d0                	sub    %edx,%eax
  802b5b:	c1 e8 0c             	shr    $0xc,%eax
  802b5e:	83 ec 0c             	sub    $0xc,%esp
  802b61:	50                   	push   %eax
  802b62:	e8 79 f5 ff ff       	call   8020e0 <sbrk>
  802b67:	83 c4 10             	add    $0x10,%esp
  802b6a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			uint32 da_break = (uint32)sbrk(0);
  802b6d:	83 ec 0c             	sub    $0xc,%esp
  802b70:	6a 00                	push   $0x0
  802b72:	e8 69 f5 ff ff       	call   8020e0 <sbrk>
  802b77:	83 c4 10             	add    $0x10,%esp
  802b7a:	89 45 e0             	mov    %eax,-0x20(%ebp)
			initialize_dynamic_allocator(da_start, da_break - da_start);
  802b7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802b80:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  802b83:	83 ec 08             	sub    $0x8,%esp
  802b86:	50                   	push   %eax
  802b87:	ff 75 e4             	pushl  -0x1c(%ebp)
  802b8a:	e8 0d fe ff ff       	call   80299c <initialize_dynamic_allocator>
  802b8f:	83 c4 10             	add    $0x10,%esp

	//TODO: [PROJECT'24.MS1 - #06] [3] DYNAMIC ALLOCATOR - alloc_block_FF
	//COMMENT THE FOLLOWING LINE BEFORE START CODING
	//panic("alloc_block_FF is not implemented yet");
	//Your Code is Here...
	uint32 compsize =size+2*sizeof(int);
  802b92:	8b 45 08             	mov    0x8(%ebp),%eax
  802b95:	83 c0 08             	add    $0x8,%eax
  802b98:	89 45 dc             	mov    %eax,-0x24(%ebp)
	struct BlockElement *moblock;
	struct BlockElement *newblock;

    LIST_FOREACH(moblock,&freeBlocksList){
  802b9b:	a1 44 60 80 00       	mov    0x806044,%eax
  802ba0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802ba3:	e9 c8 02 00 00       	jmp    802e70 <alloc_block_FF+0x36a>
    	uint32 sizeofblock=get_block_size(moblock);
  802ba8:	83 ec 0c             	sub    $0xc,%esp
  802bab:	ff 75 f4             	pushl  -0xc(%ebp)
  802bae:	e8 85 fc ff ff       	call   802838 <get_block_size>
  802bb3:	83 c4 10             	add    $0x10,%esp
  802bb6:	89 45 a8             	mov    %eax,-0x58(%ebp)
    	if (size==0)return NULL;
  802bb9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  802bbd:	75 0a                	jne    802bc9 <alloc_block_FF+0xc3>
  802bbf:	b8 00 00 00 00       	mov    $0x0,%eax
  802bc4:	e9 f4 04 00 00       	jmp    8030bd <alloc_block_FF+0x5b7>
    	if(compsize<=sizeofblock)
  802bc9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  802bcc:	3b 45 a8             	cmp    -0x58(%ebp),%eax
  802bcf:	0f 87 93 02 00 00    	ja     802e68 <alloc_block_FF+0x362>
    	{


    		if (compsize==sizeofblock)
  802bd5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  802bd8:	3b 45 a8             	cmp    -0x58(%ebp),%eax
  802bdb:	0f 85 9d 00 00 00    	jne    802c7e <alloc_block_FF+0x178>
    		{

    			 	 	 	 set_block_data(moblock, compsize, 1);
  802be1:	83 ec 04             	sub    $0x4,%esp
  802be4:	6a 01                	push   $0x1
  802be6:	ff 75 dc             	pushl  -0x24(%ebp)
  802be9:	ff 75 f4             	pushl  -0xc(%ebp)
  802bec:	e8 c8 fe ff ff       	call   802ab9 <set_block_data>
  802bf1:	83 c4 10             	add    $0x10,%esp
    			                LIST_REMOVE(&freeBlocksList, moblock);
  802bf4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802bf8:	75 17                	jne    802c11 <alloc_block_FF+0x10b>
  802bfa:	83 ec 04             	sub    $0x4,%esp
  802bfd:	68 0f 4f 80 00       	push   $0x804f0f
  802c02:	68 cf 00 00 00       	push   $0xcf
  802c07:	68 f7 4e 80 00       	push   $0x804ef7
  802c0c:	e8 78 e4 ff ff       	call   801089 <_panic>
  802c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c14:	8b 00                	mov    (%eax),%eax
  802c16:	85 c0                	test   %eax,%eax
  802c18:	74 10                	je     802c2a <alloc_block_FF+0x124>
  802c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c1d:	8b 00                	mov    (%eax),%eax
  802c1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802c22:	8b 52 04             	mov    0x4(%edx),%edx
  802c25:	89 50 04             	mov    %edx,0x4(%eax)
  802c28:	eb 0b                	jmp    802c35 <alloc_block_FF+0x12f>
  802c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c2d:	8b 40 04             	mov    0x4(%eax),%eax
  802c30:	a3 48 60 80 00       	mov    %eax,0x806048
  802c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c38:	8b 40 04             	mov    0x4(%eax),%eax
  802c3b:	85 c0                	test   %eax,%eax
  802c3d:	74 0f                	je     802c4e <alloc_block_FF+0x148>
  802c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c42:	8b 40 04             	mov    0x4(%eax),%eax
  802c45:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802c48:	8b 12                	mov    (%edx),%edx
  802c4a:	89 10                	mov    %edx,(%eax)
  802c4c:	eb 0a                	jmp    802c58 <alloc_block_FF+0x152>
  802c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c51:	8b 00                	mov    (%eax),%eax
  802c53:	a3 44 60 80 00       	mov    %eax,0x806044
  802c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c5b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  802c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c64:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802c6b:	a1 50 60 80 00       	mov    0x806050,%eax
  802c70:	48                   	dec    %eax
  802c71:	a3 50 60 80 00       	mov    %eax,0x806050

    			                return (void*)(moblock );
  802c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c79:	e9 3f 04 00 00       	jmp    8030bd <alloc_block_FF+0x5b7>

    		}


    			uint32 diff =sizeofblock-compsize;
  802c7e:	8b 45 a8             	mov    -0x58(%ebp),%eax
  802c81:	2b 45 dc             	sub    -0x24(%ebp),%eax
  802c84:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    			//split
    			//struct BlockElement *
    			if (diff>=4*sizeof(int)){
  802c87:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
  802c8b:	0f 86 3a 01 00 00    	jbe    802dcb <alloc_block_FF+0x2c5>
				newblock = (struct BlockElement*)((char*)moblock + compsize);
  802c91:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802c94:	8b 45 dc             	mov    -0x24(%ebp),%eax
  802c97:	01 d0                	add    %edx,%eax
  802c99:	89 45 a0             	mov    %eax,-0x60(%ebp)
    			uint32 compblock =get_block_size(moblock);
  802c9c:	83 ec 0c             	sub    $0xc,%esp
  802c9f:	ff 75 f4             	pushl  -0xc(%ebp)
  802ca2:	e8 91 fb ff ff       	call   802838 <get_block_size>
  802ca7:	83 c4 10             	add    $0x10,%esp
  802caa:	89 45 9c             	mov    %eax,-0x64(%ebp)
    			set_block_data(moblock,compsize,1);
  802cad:	83 ec 04             	sub    $0x4,%esp
  802cb0:	6a 01                	push   $0x1
  802cb2:	ff 75 dc             	pushl  -0x24(%ebp)
  802cb5:	ff 75 f4             	pushl  -0xc(%ebp)
  802cb8:	e8 fc fd ff ff       	call   802ab9 <set_block_data>
  802cbd:	83 c4 10             	add    $0x10,%esp
    			set_block_data(newblock,diff,0);
  802cc0:	83 ec 04             	sub    $0x4,%esp
  802cc3:	6a 00                	push   $0x0
  802cc5:	ff 75 a4             	pushl  -0x5c(%ebp)
  802cc8:	ff 75 a0             	pushl  -0x60(%ebp)
  802ccb:	e8 e9 fd ff ff       	call   802ab9 <set_block_data>
  802cd0:	83 c4 10             	add    $0x10,%esp
    			LIST_INSERT_AFTER(&freeBlocksList,moblock,newblock);
  802cd3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802cd7:	74 06                	je     802cdf <alloc_block_FF+0x1d9>
  802cd9:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
  802cdd:	75 17                	jne    802cf6 <alloc_block_FF+0x1f0>
  802cdf:	83 ec 04             	sub    $0x4,%esp
  802ce2:	68 30 4f 80 00       	push   $0x804f30
  802ce7:	68 de 00 00 00       	push   $0xde
  802cec:	68 f7 4e 80 00       	push   $0x804ef7
  802cf1:	e8 93 e3 ff ff       	call   801089 <_panic>
  802cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cf9:	8b 10                	mov    (%eax),%edx
  802cfb:	8b 45 a0             	mov    -0x60(%ebp),%eax
  802cfe:	89 10                	mov    %edx,(%eax)
  802d00:	8b 45 a0             	mov    -0x60(%ebp),%eax
  802d03:	8b 00                	mov    (%eax),%eax
  802d05:	85 c0                	test   %eax,%eax
  802d07:	74 0b                	je     802d14 <alloc_block_FF+0x20e>
  802d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d0c:	8b 00                	mov    (%eax),%eax
  802d0e:	8b 55 a0             	mov    -0x60(%ebp),%edx
  802d11:	89 50 04             	mov    %edx,0x4(%eax)
  802d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d17:	8b 55 a0             	mov    -0x60(%ebp),%edx
  802d1a:	89 10                	mov    %edx,(%eax)
  802d1c:	8b 45 a0             	mov    -0x60(%ebp),%eax
  802d1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802d22:	89 50 04             	mov    %edx,0x4(%eax)
  802d25:	8b 45 a0             	mov    -0x60(%ebp),%eax
  802d28:	8b 00                	mov    (%eax),%eax
  802d2a:	85 c0                	test   %eax,%eax
  802d2c:	75 08                	jne    802d36 <alloc_block_FF+0x230>
  802d2e:	8b 45 a0             	mov    -0x60(%ebp),%eax
  802d31:	a3 48 60 80 00       	mov    %eax,0x806048
  802d36:	a1 50 60 80 00       	mov    0x806050,%eax
  802d3b:	40                   	inc    %eax
  802d3c:	a3 50 60 80 00       	mov    %eax,0x806050
    			 LIST_REMOVE(&freeBlocksList,moblock);
  802d41:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802d45:	75 17                	jne    802d5e <alloc_block_FF+0x258>
  802d47:	83 ec 04             	sub    $0x4,%esp
  802d4a:	68 0f 4f 80 00       	push   $0x804f0f
  802d4f:	68 df 00 00 00       	push   $0xdf
  802d54:	68 f7 4e 80 00       	push   $0x804ef7
  802d59:	e8 2b e3 ff ff       	call   801089 <_panic>
  802d5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d61:	8b 00                	mov    (%eax),%eax
  802d63:	85 c0                	test   %eax,%eax
  802d65:	74 10                	je     802d77 <alloc_block_FF+0x271>
  802d67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d6a:	8b 00                	mov    (%eax),%eax
  802d6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802d6f:	8b 52 04             	mov    0x4(%edx),%edx
  802d72:	89 50 04             	mov    %edx,0x4(%eax)
  802d75:	eb 0b                	jmp    802d82 <alloc_block_FF+0x27c>
  802d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d7a:	8b 40 04             	mov    0x4(%eax),%eax
  802d7d:	a3 48 60 80 00       	mov    %eax,0x806048
  802d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d85:	8b 40 04             	mov    0x4(%eax),%eax
  802d88:	85 c0                	test   %eax,%eax
  802d8a:	74 0f                	je     802d9b <alloc_block_FF+0x295>
  802d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d8f:	8b 40 04             	mov    0x4(%eax),%eax
  802d92:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802d95:	8b 12                	mov    (%edx),%edx
  802d97:	89 10                	mov    %edx,(%eax)
  802d99:	eb 0a                	jmp    802da5 <alloc_block_FF+0x29f>
  802d9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d9e:	8b 00                	mov    (%eax),%eax
  802da0:	a3 44 60 80 00       	mov    %eax,0x806044
  802da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802da8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  802dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802db1:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802db8:	a1 50 60 80 00       	mov    0x806050,%eax
  802dbd:	48                   	dec    %eax
  802dbe:	a3 50 60 80 00       	mov    %eax,0x806050

    			return (void*)(moblock);
  802dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802dc6:	e9 f2 02 00 00       	jmp    8030bd <alloc_block_FF+0x5b7>
    			}
    			else {
    				set_block_data(moblock,sizeofblock,1);
  802dcb:	83 ec 04             	sub    $0x4,%esp
  802dce:	6a 01                	push   $0x1
  802dd0:	ff 75 a8             	pushl  -0x58(%ebp)
  802dd3:	ff 75 f4             	pushl  -0xc(%ebp)
  802dd6:	e8 de fc ff ff       	call   802ab9 <set_block_data>
  802ddb:	83 c4 10             	add    $0x10,%esp
    				LIST_REMOVE(&freeBlocksList,moblock);
  802dde:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802de2:	75 17                	jne    802dfb <alloc_block_FF+0x2f5>
  802de4:	83 ec 04             	sub    $0x4,%esp
  802de7:	68 0f 4f 80 00       	push   $0x804f0f
  802dec:	68 e5 00 00 00       	push   $0xe5
  802df1:	68 f7 4e 80 00       	push   $0x804ef7
  802df6:	e8 8e e2 ff ff       	call   801089 <_panic>
  802dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802dfe:	8b 00                	mov    (%eax),%eax
  802e00:	85 c0                	test   %eax,%eax
  802e02:	74 10                	je     802e14 <alloc_block_FF+0x30e>
  802e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e07:	8b 00                	mov    (%eax),%eax
  802e09:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802e0c:	8b 52 04             	mov    0x4(%edx),%edx
  802e0f:	89 50 04             	mov    %edx,0x4(%eax)
  802e12:	eb 0b                	jmp    802e1f <alloc_block_FF+0x319>
  802e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e17:	8b 40 04             	mov    0x4(%eax),%eax
  802e1a:	a3 48 60 80 00       	mov    %eax,0x806048
  802e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e22:	8b 40 04             	mov    0x4(%eax),%eax
  802e25:	85 c0                	test   %eax,%eax
  802e27:	74 0f                	je     802e38 <alloc_block_FF+0x332>
  802e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e2c:	8b 40 04             	mov    0x4(%eax),%eax
  802e2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802e32:	8b 12                	mov    (%edx),%edx
  802e34:	89 10                	mov    %edx,(%eax)
  802e36:	eb 0a                	jmp    802e42 <alloc_block_FF+0x33c>
  802e38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e3b:	8b 00                	mov    (%eax),%eax
  802e3d:	a3 44 60 80 00       	mov    %eax,0x806044
  802e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e45:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  802e4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e4e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802e55:	a1 50 60 80 00       	mov    0x806050,%eax
  802e5a:	48                   	dec    %eax
  802e5b:	a3 50 60 80 00       	mov    %eax,0x806050
    				return(void*)(moblock);
  802e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e63:	e9 55 02 00 00       	jmp    8030bd <alloc_block_FF+0x5b7>
	//Your Code is Here...
	uint32 compsize =size+2*sizeof(int);
	struct BlockElement *moblock;
	struct BlockElement *newblock;

    LIST_FOREACH(moblock,&freeBlocksList){
  802e68:	a1 4c 60 80 00       	mov    0x80604c,%eax
  802e6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802e70:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802e74:	74 07                	je     802e7d <alloc_block_FF+0x377>
  802e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e79:	8b 00                	mov    (%eax),%eax
  802e7b:	eb 05                	jmp    802e82 <alloc_block_FF+0x37c>
  802e7d:	b8 00 00 00 00       	mov    $0x0,%eax
  802e82:	a3 4c 60 80 00       	mov    %eax,0x80604c
  802e87:	a1 4c 60 80 00       	mov    0x80604c,%eax
  802e8c:	85 c0                	test   %eax,%eax
  802e8e:	0f 85 14 fd ff ff    	jne    802ba8 <alloc_block_FF+0xa2>
  802e94:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802e98:	0f 85 0a fd ff ff    	jne    802ba8 <alloc_block_FF+0xa2>





    uint32 num=ROUNDUP(size,4*1024)/(4*1024);
  802e9e:	c7 45 d8 00 10 00 00 	movl   $0x1000,-0x28(%ebp)
  802ea5:	8b 55 08             	mov    0x8(%ebp),%edx
  802ea8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802eab:	01 d0                	add    %edx,%eax
  802ead:	48                   	dec    %eax
  802eae:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  802eb1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  802eb4:	ba 00 00 00 00       	mov    $0x0,%edx
  802eb9:	f7 75 d8             	divl   -0x28(%ebp)
  802ebc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  802ebf:	29 d0                	sub    %edx,%eax
  802ec1:	c1 e8 0c             	shr    $0xc,%eax
  802ec4:	89 45 d0             	mov    %eax,-0x30(%ebp)
   void* brk = (struct BlockElement*)sbrk(num);
  802ec7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  802eca:	83 ec 0c             	sub    $0xc,%esp
  802ecd:	50                   	push   %eax
  802ece:	e8 0d f2 ff ff       	call   8020e0 <sbrk>
  802ed3:	83 c4 10             	add    $0x10,%esp
  802ed6:	89 45 cc             	mov    %eax,-0x34(%ebp)
           if (brk == (void*)-1) {
  802ed9:	83 7d cc ff          	cmpl   $0xffffffff,-0x34(%ebp)
  802edd:	75 0a                	jne    802ee9 <alloc_block_FF+0x3e3>

               return NULL;  // sbrk failed
  802edf:	b8 00 00 00 00       	mov    $0x0,%eax
  802ee4:	e9 d4 01 00 00       	jmp    8030bd <alloc_block_FF+0x5b7>
               }

          // cprintf("here %d----%d\n",num,size);

           struct BlockElement* new_free_block = (struct BlockElement*)(brk);
  802ee9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802eec:	89 45 c8             	mov    %eax,-0x38(%ebp)
           set_block_data(new_free_block, (num*4*1024), 0);
  802eef:	8b 45 d0             	mov    -0x30(%ebp),%eax
  802ef2:	c1 e0 0c             	shl    $0xc,%eax
  802ef5:	83 ec 04             	sub    $0x4,%esp
  802ef8:	6a 00                	push   $0x0
  802efa:	50                   	push   %eax
  802efb:	ff 75 c8             	pushl  -0x38(%ebp)
  802efe:	e8 b6 fb ff ff       	call   802ab9 <set_block_data>
  802f03:	83 c4 10             	add    $0x10,%esp

           LIST_INSERT_TAIL(&freeBlocksList,new_free_block);
  802f06:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  802f0a:	75 17                	jne    802f23 <alloc_block_FF+0x41d>
  802f0c:	83 ec 04             	sub    $0x4,%esp
  802f0f:	68 64 4f 80 00       	push   $0x804f64
  802f14:	68 0a 01 00 00       	push   $0x10a
  802f19:	68 f7 4e 80 00       	push   $0x804ef7
  802f1e:	e8 66 e1 ff ff       	call   801089 <_panic>
  802f23:	8b 15 48 60 80 00    	mov    0x806048,%edx
  802f29:	8b 45 c8             	mov    -0x38(%ebp),%eax
  802f2c:	89 50 04             	mov    %edx,0x4(%eax)
  802f2f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  802f32:	8b 40 04             	mov    0x4(%eax),%eax
  802f35:	85 c0                	test   %eax,%eax
  802f37:	74 0c                	je     802f45 <alloc_block_FF+0x43f>
  802f39:	a1 48 60 80 00       	mov    0x806048,%eax
  802f3e:	8b 55 c8             	mov    -0x38(%ebp),%edx
  802f41:	89 10                	mov    %edx,(%eax)
  802f43:	eb 08                	jmp    802f4d <alloc_block_FF+0x447>
  802f45:	8b 45 c8             	mov    -0x38(%ebp),%eax
  802f48:	a3 44 60 80 00       	mov    %eax,0x806044
  802f4d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  802f50:	a3 48 60 80 00       	mov    %eax,0x806048
  802f55:	8b 45 c8             	mov    -0x38(%ebp),%eax
  802f58:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  802f5e:	a1 50 60 80 00       	mov    0x806050,%eax
  802f63:	40                   	inc    %eax
  802f64:	a3 50 60 80 00       	mov    %eax,0x806050
           struct BlockElement*prev;
           //long diff_next = (char*)(va_block->prev_next_info.le_next) - (char*)((char*)va_block+size);
           prev=new_free_block->prev_next_info.le_prev;
  802f69:	8b 45 c8             	mov    -0x38(%ebp),%eax
  802f6c:	8b 40 04             	mov    0x4(%eax),%eax
  802f6f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
          // print_blocks_list(freeBlocksList);
         if(prev!=NULL&&is_free_block(prev)==1){
  802f72:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  802f76:	0f 84 04 01 00 00    	je     803080 <alloc_block_FF+0x57a>
  802f7c:	83 ec 0c             	sub    $0xc,%esp
  802f7f:	ff 75 c4             	pushl  -0x3c(%ebp)
  802f82:	e8 ca f8 ff ff       	call   802851 <is_free_block>
  802f87:	83 c4 10             	add    $0x10,%esp
  802f8a:	3c 01                	cmp    $0x1,%al
  802f8c:	0f 85 ee 00 00 00    	jne    803080 <alloc_block_FF+0x57a>
          // print_blocks_list(freeBlocksList);
        	uint32 size_prev= get_block_size(prev);
  802f92:	83 ec 0c             	sub    $0xc,%esp
  802f95:	ff 75 c4             	pushl  -0x3c(%ebp)
  802f98:	e8 9b f8 ff ff       	call   802838 <get_block_size>
  802f9d:	83 c4 10             	add    $0x10,%esp
  802fa0:	89 45 c0             	mov    %eax,-0x40(%ebp)
        	char* prev_end = (char*)prev + size_prev;
  802fa3:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  802fa6:	8b 45 c0             	mov    -0x40(%ebp),%eax
  802fa9:	01 d0                	add    %edx,%eax
  802fab:	89 45 bc             	mov    %eax,-0x44(%ebp)
           long diff = ((char*)(new_free_block)-prev_end);
  802fae:	8b 55 c8             	mov    -0x38(%ebp),%edx
  802fb1:	8b 45 bc             	mov    -0x44(%ebp),%eax
  802fb4:	29 c2                	sub    %eax,%edx
  802fb6:	89 d0                	mov    %edx,%eax
  802fb8:	89 45 b8             	mov    %eax,-0x48(%ebp)
          // cprintf("prev--%x - prev+size ---%x ---diff%d/n",diff);
         if(diff<4*sizeof(int)&&diff>=0){
  802fbb:	8b 45 b8             	mov    -0x48(%ebp),%eax
  802fbe:	83 f8 0f             	cmp    $0xf,%eax
  802fc1:	0f 87 b9 00 00 00    	ja     803080 <alloc_block_FF+0x57a>
  802fc7:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  802fcb:	0f 88 af 00 00 00    	js     803080 <alloc_block_FF+0x57a>
        	 	 //	 cprintf("merginggggggg\n");
        	uint32 size_new=get_block_size(new_free_block);
  802fd1:	83 ec 0c             	sub    $0xc,%esp
  802fd4:	ff 75 c8             	pushl  -0x38(%ebp)
  802fd7:	e8 5c f8 ff ff       	call   802838 <get_block_size>
  802fdc:	83 c4 10             	add    $0x10,%esp
  802fdf:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        	size_prev+=(num*4*1024);
  802fe2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  802fe5:	c1 e0 0c             	shl    $0xc,%eax
  802fe8:	01 45 c0             	add    %eax,-0x40(%ebp)
        	   set_block_data(prev,size_prev,0);
  802feb:	83 ec 04             	sub    $0x4,%esp
  802fee:	6a 00                	push   $0x0
  802ff0:	ff 75 c0             	pushl  -0x40(%ebp)
  802ff3:	ff 75 c4             	pushl  -0x3c(%ebp)
  802ff6:	e8 be fa ff ff       	call   802ab9 <set_block_data>
  802ffb:	83 c4 10             	add    $0x10,%esp
        	   LIST_REMOVE(&freeBlocksList,new_free_block);
  802ffe:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  803002:	75 17                	jne    80301b <alloc_block_FF+0x515>
  803004:	83 ec 04             	sub    $0x4,%esp
  803007:	68 0f 4f 80 00       	push   $0x804f0f
  80300c:	68 1a 01 00 00       	push   $0x11a
  803011:	68 f7 4e 80 00       	push   $0x804ef7
  803016:	e8 6e e0 ff ff       	call   801089 <_panic>
  80301b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80301e:	8b 00                	mov    (%eax),%eax
  803020:	85 c0                	test   %eax,%eax
  803022:	74 10                	je     803034 <alloc_block_FF+0x52e>
  803024:	8b 45 c8             	mov    -0x38(%ebp),%eax
  803027:	8b 00                	mov    (%eax),%eax
  803029:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80302c:	8b 52 04             	mov    0x4(%edx),%edx
  80302f:	89 50 04             	mov    %edx,0x4(%eax)
  803032:	eb 0b                	jmp    80303f <alloc_block_FF+0x539>
  803034:	8b 45 c8             	mov    -0x38(%ebp),%eax
  803037:	8b 40 04             	mov    0x4(%eax),%eax
  80303a:	a3 48 60 80 00       	mov    %eax,0x806048
  80303f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  803042:	8b 40 04             	mov    0x4(%eax),%eax
  803045:	85 c0                	test   %eax,%eax
  803047:	74 0f                	je     803058 <alloc_block_FF+0x552>
  803049:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80304c:	8b 40 04             	mov    0x4(%eax),%eax
  80304f:	8b 55 c8             	mov    -0x38(%ebp),%edx
  803052:	8b 12                	mov    (%edx),%edx
  803054:	89 10                	mov    %edx,(%eax)
  803056:	eb 0a                	jmp    803062 <alloc_block_FF+0x55c>
  803058:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80305b:	8b 00                	mov    (%eax),%eax
  80305d:	a3 44 60 80 00       	mov    %eax,0x806044
  803062:	8b 45 c8             	mov    -0x38(%ebp),%eax
  803065:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  80306b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80306e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  803075:	a1 50 60 80 00       	mov    0x806050,%eax
  80307a:	48                   	dec    %eax
  80307b:	a3 50 60 80 00       	mov    %eax,0x806050
        	   //set_block_data(new_free_block,0,1);
        	   	   //print_blocks_list(freeBlocksList);
           }}

         struct BlockElement*oldend=(struct BlockElement*)((char*)(sbrk(0)-sizeof(int)));
  803080:	83 ec 0c             	sub    $0xc,%esp
  803083:	6a 00                	push   $0x0
  803085:	e8 56 f0 ff ff       	call   8020e0 <sbrk>
  80308a:	83 c4 10             	add    $0x10,%esp
  80308d:	83 e8 04             	sub    $0x4,%eax
  803090:	89 45 b0             	mov    %eax,-0x50(%ebp)
           	   uint32*new_end=sbrk(0)-sizeof(int);
  803093:	83 ec 0c             	sub    $0xc,%esp
  803096:	6a 00                	push   $0x0
  803098:	e8 43 f0 ff ff       	call   8020e0 <sbrk>
  80309d:	83 c4 10             	add    $0x10,%esp
  8030a0:	83 e8 04             	sub    $0x4,%eax
  8030a3:	89 45 ac             	mov    %eax,-0x54(%ebp)
           	     *new_end =0x1;
  8030a6:	8b 45 ac             	mov    -0x54(%ebp),%eax
  8030a9:	c7 00 01 00 00 00    	movl   $0x1,(%eax)





           return alloc_block_FF(size);
  8030af:	83 ec 0c             	sub    $0xc,%esp
  8030b2:	ff 75 08             	pushl  0x8(%ebp)
  8030b5:	e8 4c fa ff ff       	call   802b06 <alloc_block_FF>
  8030ba:	83 c4 10             	add    $0x10,%esp


}
  8030bd:	c9                   	leave  
  8030be:	c3                   	ret    

008030bf <alloc_block_BF>:
//=========================================
// [4] ALLOCATE BLOCK BY BEST FIT:
//=========================================
void *alloc_block_BF(uint32 size)
{
  8030bf:	55                   	push   %ebp
  8030c0:	89 e5                	mov    %esp,%ebp
  8030c2:	83 ec 48             	sub    $0x48,%esp

	    //==================================================================================
	    // DON'T CHANGE THESE LINES ========================================================
	    //==================================================================================
	    {
	        if (size % 2 != 0) size++;
  8030c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8030c8:	83 e0 01             	and    $0x1,%eax
  8030cb:	85 c0                	test   %eax,%eax
  8030cd:	74 03                	je     8030d2 <alloc_block_BF+0x13>
  8030cf:	ff 45 08             	incl   0x8(%ebp)
	        if (size < DYN_ALLOC_MIN_BLOCK_SIZE)
  8030d2:	83 7d 08 07          	cmpl   $0x7,0x8(%ebp)
  8030d6:	77 07                	ja     8030df <alloc_block_BF+0x20>
	            size = DYN_ALLOC_MIN_BLOCK_SIZE;
  8030d8:	c7 45 08 08 00 00 00 	movl   $0x8,0x8(%ebp)
	        if (!is_initialized) {
  8030df:	a1 24 60 80 00       	mov    0x806024,%eax
  8030e4:	85 c0                	test   %eax,%eax
  8030e6:	75 63                	jne    80314b <alloc_block_BF+0x8c>
	            uint32 required_size = size + 2 * sizeof(int) + 2 * sizeof(int);
  8030e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8030eb:	83 c0 10             	add    $0x10,%eax
  8030ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
	            uint32 da_start = (uint32)sbrk(ROUNDUP(required_size, PAGE_SIZE) / PAGE_SIZE);
  8030f1:	c7 45 e4 00 10 00 00 	movl   $0x1000,-0x1c(%ebp)
  8030f8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8030fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8030fe:	01 d0                	add    %edx,%eax
  803100:	48                   	dec    %eax
  803101:	89 45 e0             	mov    %eax,-0x20(%ebp)
  803104:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803107:	ba 00 00 00 00       	mov    $0x0,%edx
  80310c:	f7 75 e4             	divl   -0x1c(%ebp)
  80310f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803112:	29 d0                	sub    %edx,%eax
  803114:	c1 e8 0c             	shr    $0xc,%eax
  803117:	83 ec 0c             	sub    $0xc,%esp
  80311a:	50                   	push   %eax
  80311b:	e8 c0 ef ff ff       	call   8020e0 <sbrk>
  803120:	83 c4 10             	add    $0x10,%esp
  803123:	89 45 dc             	mov    %eax,-0x24(%ebp)
	            uint32 da_break = (uint32)sbrk(0);
  803126:	83 ec 0c             	sub    $0xc,%esp
  803129:	6a 00                	push   $0x0
  80312b:	e8 b0 ef ff ff       	call   8020e0 <sbrk>
  803130:	83 c4 10             	add    $0x10,%esp
  803133:	89 45 d8             	mov    %eax,-0x28(%ebp)
	            initialize_dynamic_allocator(da_start, da_break - da_start);
  803136:	8b 45 d8             	mov    -0x28(%ebp),%eax
  803139:	2b 45 dc             	sub    -0x24(%ebp),%eax
  80313c:	83 ec 08             	sub    $0x8,%esp
  80313f:	50                   	push   %eax
  803140:	ff 75 dc             	pushl  -0x24(%ebp)
  803143:	e8 54 f8 ff ff       	call   80299c <initialize_dynamic_allocator>
  803148:	83 c4 10             	add    $0x10,%esp
	        }
	    }
	    //==================================================================================
	    //==================================================================================

	    uint32 compsize = size + 2 * sizeof(int);
  80314b:	8b 45 08             	mov    0x8(%ebp),%eax
  80314e:	83 c0 08             	add    $0x8,%eax
  803151:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	    struct BlockElement* best_fit_block = NULL;
  803154:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	    struct BlockElement* current_block;
	    uint32 min_diff = 1e9;
  80315b:	c7 45 ec 00 ca 9a 3b 	movl   $0x3b9aca00,-0x14(%ebp)


	    LIST_FOREACH(current_block, &freeBlocksList) {
  803162:	a1 44 60 80 00       	mov    0x806044,%eax
  803167:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80316a:	eb 3e                	jmp    8031aa <alloc_block_BF+0xeb>
	        uint32 block_size = get_block_size(current_block);
  80316c:	83 ec 0c             	sub    $0xc,%esp
  80316f:	ff 75 f0             	pushl  -0x10(%ebp)
  803172:	e8 c1 f6 ff ff       	call   802838 <get_block_size>
  803177:	83 c4 10             	add    $0x10,%esp
  80317a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	        if (block_size >= compsize) {
  80317d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  803180:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  803183:	72 1d                	jb     8031a2 <alloc_block_BF+0xe3>
	            uint32 diff = block_size - compsize;
  803185:	8b 45 d0             	mov    -0x30(%ebp),%eax
  803188:	2b 45 d4             	sub    -0x2c(%ebp),%eax
  80318b:	89 45 cc             	mov    %eax,-0x34(%ebp)
	            if (diff < min_diff) {
  80318e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  803191:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  803194:	73 0c                	jae    8031a2 <alloc_block_BF+0xe3>
	                min_diff = diff;
  803196:	8b 45 cc             	mov    -0x34(%ebp),%eax
  803199:	89 45 ec             	mov    %eax,-0x14(%ebp)
	                best_fit_block = current_block;
  80319c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80319f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    struct BlockElement* best_fit_block = NULL;
	    struct BlockElement* current_block;
	    uint32 min_diff = 1e9;


	    LIST_FOREACH(current_block, &freeBlocksList) {
  8031a2:	a1 4c 60 80 00       	mov    0x80604c,%eax
  8031a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8031aa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8031ae:	74 07                	je     8031b7 <alloc_block_BF+0xf8>
  8031b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8031b3:	8b 00                	mov    (%eax),%eax
  8031b5:	eb 05                	jmp    8031bc <alloc_block_BF+0xfd>
  8031b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8031bc:	a3 4c 60 80 00       	mov    %eax,0x80604c
  8031c1:	a1 4c 60 80 00       	mov    0x80604c,%eax
  8031c6:	85 c0                	test   %eax,%eax
  8031c8:	75 a2                	jne    80316c <alloc_block_BF+0xad>
  8031ca:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8031ce:	75 9c                	jne    80316c <alloc_block_BF+0xad>
	            }
	        }
	    }


	    if (best_fit_block == NULL) {
  8031d0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8031d4:	75 43                	jne    803219 <alloc_block_BF+0x15a>
	        void* new_mem = (struct BlockElement*)sbrk(compsize);
  8031d6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8031d9:	83 ec 0c             	sub    $0xc,%esp
  8031dc:	50                   	push   %eax
  8031dd:	e8 fe ee ff ff       	call   8020e0 <sbrk>
  8031e2:	83 c4 10             	add    $0x10,%esp
  8031e5:	89 45 c8             	mov    %eax,-0x38(%ebp)
	        if (new_mem == (void*)-1) {
  8031e8:	83 7d c8 ff          	cmpl   $0xffffffff,-0x38(%ebp)
  8031ec:	75 0a                	jne    8031f8 <alloc_block_BF+0x139>
	            return NULL;
  8031ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8031f3:	e9 17 02 00 00       	jmp    80340f <alloc_block_BF+0x350>
	        }
	        struct BlockElement* new_block = (struct BlockElement*)new_mem;
  8031f8:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8031fb:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	        set_block_data(new_block, compsize, 1);
  8031fe:	83 ec 04             	sub    $0x4,%esp
  803201:	6a 01                	push   $0x1
  803203:	ff 75 d4             	pushl  -0x2c(%ebp)
  803206:	ff 75 c4             	pushl  -0x3c(%ebp)
  803209:	e8 ab f8 ff ff       	call   802ab9 <set_block_data>
  80320e:	83 c4 10             	add    $0x10,%esp
	        return (void*)new_block;
  803211:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  803214:	e9 f6 01 00 00       	jmp    80340f <alloc_block_BF+0x350>
	    }


	    if (min_diff == 0) {
  803219:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80321d:	0f 85 9d 00 00 00    	jne    8032c0 <alloc_block_BF+0x201>
	        set_block_data(best_fit_block, compsize, 1);
  803223:	83 ec 04             	sub    $0x4,%esp
  803226:	6a 01                	push   $0x1
  803228:	ff 75 d4             	pushl  -0x2c(%ebp)
  80322b:	ff 75 f4             	pushl  -0xc(%ebp)
  80322e:	e8 86 f8 ff ff       	call   802ab9 <set_block_data>
  803233:	83 c4 10             	add    $0x10,%esp
	        LIST_REMOVE(&freeBlocksList, best_fit_block);
  803236:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80323a:	75 17                	jne    803253 <alloc_block_BF+0x194>
  80323c:	83 ec 04             	sub    $0x4,%esp
  80323f:	68 0f 4f 80 00       	push   $0x804f0f
  803244:	68 65 01 00 00       	push   $0x165
  803249:	68 f7 4e 80 00       	push   $0x804ef7
  80324e:	e8 36 de ff ff       	call   801089 <_panic>
  803253:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803256:	8b 00                	mov    (%eax),%eax
  803258:	85 c0                	test   %eax,%eax
  80325a:	74 10                	je     80326c <alloc_block_BF+0x1ad>
  80325c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80325f:	8b 00                	mov    (%eax),%eax
  803261:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803264:	8b 52 04             	mov    0x4(%edx),%edx
  803267:	89 50 04             	mov    %edx,0x4(%eax)
  80326a:	eb 0b                	jmp    803277 <alloc_block_BF+0x1b8>
  80326c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80326f:	8b 40 04             	mov    0x4(%eax),%eax
  803272:	a3 48 60 80 00       	mov    %eax,0x806048
  803277:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80327a:	8b 40 04             	mov    0x4(%eax),%eax
  80327d:	85 c0                	test   %eax,%eax
  80327f:	74 0f                	je     803290 <alloc_block_BF+0x1d1>
  803281:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803284:	8b 40 04             	mov    0x4(%eax),%eax
  803287:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80328a:	8b 12                	mov    (%edx),%edx
  80328c:	89 10                	mov    %edx,(%eax)
  80328e:	eb 0a                	jmp    80329a <alloc_block_BF+0x1db>
  803290:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803293:	8b 00                	mov    (%eax),%eax
  803295:	a3 44 60 80 00       	mov    %eax,0x806044
  80329a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80329d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  8032a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8032a6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  8032ad:	a1 50 60 80 00       	mov    0x806050,%eax
  8032b2:	48                   	dec    %eax
  8032b3:	a3 50 60 80 00       	mov    %eax,0x806050
	        return (void*)best_fit_block;
  8032b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8032bb:	e9 4f 01 00 00       	jmp    80340f <alloc_block_BF+0x350>
	    }


	    if (min_diff >= 4 * sizeof(int)) {
  8032c0:	83 7d ec 0f          	cmpl   $0xf,-0x14(%ebp)
  8032c4:	0f 86 a1 00 00 00    	jbe    80336b <alloc_block_BF+0x2ac>
	        struct BlockElement* remaining_block = (struct BlockElement*)((char*)best_fit_block + compsize);
  8032ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8032cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8032d0:	01 d0                	add    %edx,%eax
  8032d2:	89 45 c0             	mov    %eax,-0x40(%ebp)
	        set_block_data(best_fit_block, compsize, 1);
  8032d5:	83 ec 04             	sub    $0x4,%esp
  8032d8:	6a 01                	push   $0x1
  8032da:	ff 75 d4             	pushl  -0x2c(%ebp)
  8032dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8032e0:	e8 d4 f7 ff ff       	call   802ab9 <set_block_data>
  8032e5:	83 c4 10             	add    $0x10,%esp
	        set_block_data(remaining_block, min_diff, 0);
  8032e8:	83 ec 04             	sub    $0x4,%esp
  8032eb:	6a 00                	push   $0x0
  8032ed:	ff 75 ec             	pushl  -0x14(%ebp)
  8032f0:	ff 75 c0             	pushl  -0x40(%ebp)
  8032f3:	e8 c1 f7 ff ff       	call   802ab9 <set_block_data>
  8032f8:	83 c4 10             	add    $0x10,%esp
	        LIST_INSERT_AFTER(&freeBlocksList, best_fit_block, remaining_block);
  8032fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8032ff:	74 06                	je     803307 <alloc_block_BF+0x248>
  803301:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  803305:	75 17                	jne    80331e <alloc_block_BF+0x25f>
  803307:	83 ec 04             	sub    $0x4,%esp
  80330a:	68 30 4f 80 00       	push   $0x804f30
  80330f:	68 6e 01 00 00       	push   $0x16e
  803314:	68 f7 4e 80 00       	push   $0x804ef7
  803319:	e8 6b dd ff ff       	call   801089 <_panic>
  80331e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803321:	8b 10                	mov    (%eax),%edx
  803323:	8b 45 c0             	mov    -0x40(%ebp),%eax
  803326:	89 10                	mov    %edx,(%eax)
  803328:	8b 45 c0             	mov    -0x40(%ebp),%eax
  80332b:	8b 00                	mov    (%eax),%eax
  80332d:	85 c0                	test   %eax,%eax
  80332f:	74 0b                	je     80333c <alloc_block_BF+0x27d>
  803331:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803334:	8b 00                	mov    (%eax),%eax
  803336:	8b 55 c0             	mov    -0x40(%ebp),%edx
  803339:	89 50 04             	mov    %edx,0x4(%eax)
  80333c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80333f:	8b 55 c0             	mov    -0x40(%ebp),%edx
  803342:	89 10                	mov    %edx,(%eax)
  803344:	8b 45 c0             	mov    -0x40(%ebp),%eax
  803347:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80334a:	89 50 04             	mov    %edx,0x4(%eax)
  80334d:	8b 45 c0             	mov    -0x40(%ebp),%eax
  803350:	8b 00                	mov    (%eax),%eax
  803352:	85 c0                	test   %eax,%eax
  803354:	75 08                	jne    80335e <alloc_block_BF+0x29f>
  803356:	8b 45 c0             	mov    -0x40(%ebp),%eax
  803359:	a3 48 60 80 00       	mov    %eax,0x806048
  80335e:	a1 50 60 80 00       	mov    0x806050,%eax
  803363:	40                   	inc    %eax
  803364:	a3 50 60 80 00       	mov    %eax,0x806050
  803369:	eb 1f                	jmp    80338a <alloc_block_BF+0x2cb>
	    } else {

	        set_block_data(best_fit_block, get_block_size(best_fit_block), 1);
  80336b:	83 ec 0c             	sub    $0xc,%esp
  80336e:	ff 75 f4             	pushl  -0xc(%ebp)
  803371:	e8 c2 f4 ff ff       	call   802838 <get_block_size>
  803376:	83 c4 10             	add    $0x10,%esp
  803379:	83 ec 04             	sub    $0x4,%esp
  80337c:	6a 01                	push   $0x1
  80337e:	50                   	push   %eax
  80337f:	ff 75 f4             	pushl  -0xc(%ebp)
  803382:	e8 32 f7 ff ff       	call   802ab9 <set_block_data>
  803387:	83 c4 10             	add    $0x10,%esp
	    }


	    LIST_REMOVE(&freeBlocksList, best_fit_block);
  80338a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80338e:	75 17                	jne    8033a7 <alloc_block_BF+0x2e8>
  803390:	83 ec 04             	sub    $0x4,%esp
  803393:	68 0f 4f 80 00       	push   $0x804f0f
  803398:	68 75 01 00 00       	push   $0x175
  80339d:	68 f7 4e 80 00       	push   $0x804ef7
  8033a2:	e8 e2 dc ff ff       	call   801089 <_panic>
  8033a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8033aa:	8b 00                	mov    (%eax),%eax
  8033ac:	85 c0                	test   %eax,%eax
  8033ae:	74 10                	je     8033c0 <alloc_block_BF+0x301>
  8033b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8033b3:	8b 00                	mov    (%eax),%eax
  8033b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8033b8:	8b 52 04             	mov    0x4(%edx),%edx
  8033bb:	89 50 04             	mov    %edx,0x4(%eax)
  8033be:	eb 0b                	jmp    8033cb <alloc_block_BF+0x30c>
  8033c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8033c3:	8b 40 04             	mov    0x4(%eax),%eax
  8033c6:	a3 48 60 80 00       	mov    %eax,0x806048
  8033cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8033ce:	8b 40 04             	mov    0x4(%eax),%eax
  8033d1:	85 c0                	test   %eax,%eax
  8033d3:	74 0f                	je     8033e4 <alloc_block_BF+0x325>
  8033d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8033d8:	8b 40 04             	mov    0x4(%eax),%eax
  8033db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8033de:	8b 12                	mov    (%edx),%edx
  8033e0:	89 10                	mov    %edx,(%eax)
  8033e2:	eb 0a                	jmp    8033ee <alloc_block_BF+0x32f>
  8033e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8033e7:	8b 00                	mov    (%eax),%eax
  8033e9:	a3 44 60 80 00       	mov    %eax,0x806044
  8033ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8033f1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  8033f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8033fa:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  803401:	a1 50 60 80 00       	mov    0x806050,%eax
  803406:	48                   	dec    %eax
  803407:	a3 50 60 80 00       	mov    %eax,0x806050
	    return (void*)best_fit_block;
  80340c:	8b 45 f4             	mov    -0xc(%ebp),%eax
	}
  80340f:	c9                   	leave  
  803410:	c3                   	ret    

00803411 <free_block>:

//===================================================
// [5] FREE BLOCK WITH COALESCING:
//===================================================
void free_block(void *va)
{
  803411:	55                   	push   %ebp
  803412:	89 e5                	mov    %esp,%ebp
  803414:	53                   	push   %ebx
  803415:	83 ec 24             	sub    $0x24,%esp
	//TODO: [PROJECT'24.MS1 - #07] [3] DYNAMIC ALLOCATOR - free_block
	//COMMENT THE FOLLOWING LINE BEFORE START CODING
	//panic("free_block is not implemented yet");
	//Your Code is Here...
	struct BlockElement* block;
	if (va!=NULL){
  803418:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80341c:	0f 84 73 05 00 00    	je     803995 <free_block+0x584>
	uint32 size =get_block_size(va);
  803422:	ff 75 08             	pushl  0x8(%ebp)
  803425:	e8 0e f4 ff ff       	call   802838 <get_block_size>
  80342a:	83 c4 04             	add    $0x4,%esp
  80342d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	set_block_data(va,size,0);//set free block
  803430:	6a 00                	push   $0x0
  803432:	ff 75 f0             	pushl  -0x10(%ebp)
  803435:	ff 75 08             	pushl  0x8(%ebp)
  803438:	e8 7c f6 ff ff       	call   802ab9 <set_block_data>
  80343d:	83 c4 0c             	add    $0xc,%esp
	struct BlockElement* va_block=(struct BlockElement*)va;
  803440:	8b 45 08             	mov    0x8(%ebp),%eax
  803443:	89 45 ec             	mov    %eax,-0x14(%ebp)
	struct BlockElement* prev;
	uint32 newsize;
	//cprintf("here before each\n");
	LIST_FOREACH(block,&freeBlocksList){
  803446:	a1 44 60 80 00       	mov    0x806044,%eax
  80344b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80344e:	e9 bb 03 00 00       	jmp    80380e <free_block+0x3fd>
		if (va_block<block){
  803453:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803456:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  803459:	0f 83 a7 03 00 00    	jae    803806 <free_block+0x3f5>
			set_block_data(va_block,size,0);
  80345f:	6a 00                	push   $0x0
  803461:	ff 75 f0             	pushl  -0x10(%ebp)
  803464:	ff 75 ec             	pushl  -0x14(%ebp)
  803467:	e8 4d f6 ff ff       	call   802ab9 <set_block_data>
  80346c:	83 c4 0c             	add    $0xc,%esp
			LIST_INSERT_BEFORE(&freeBlocksList,block,va_block);
  80346f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  803473:	74 06                	je     80347b <free_block+0x6a>
  803475:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  803479:	75 17                	jne    803492 <free_block+0x81>
  80347b:	83 ec 04             	sub    $0x4,%esp
  80347e:	68 88 4f 80 00       	push   $0x804f88
  803483:	68 92 01 00 00       	push   $0x192
  803488:	68 f7 4e 80 00       	push   $0x804ef7
  80348d:	e8 f7 db ff ff       	call   801089 <_panic>
  803492:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803495:	8b 50 04             	mov    0x4(%eax),%edx
  803498:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80349b:	89 50 04             	mov    %edx,0x4(%eax)
  80349e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8034a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8034a4:	89 10                	mov    %edx,(%eax)
  8034a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8034a9:	8b 40 04             	mov    0x4(%eax),%eax
  8034ac:	85 c0                	test   %eax,%eax
  8034ae:	74 0d                	je     8034bd <free_block+0xac>
  8034b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8034b3:	8b 40 04             	mov    0x4(%eax),%eax
  8034b6:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8034b9:	89 10                	mov    %edx,(%eax)
  8034bb:	eb 08                	jmp    8034c5 <free_block+0xb4>
  8034bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8034c0:	a3 44 60 80 00       	mov    %eax,0x806044
  8034c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8034c8:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8034cb:	89 50 04             	mov    %edx,0x4(%eax)
  8034ce:	a1 50 60 80 00       	mov    0x806050,%eax
  8034d3:	40                   	inc    %eax
  8034d4:	a3 50 60 80 00       	mov    %eax,0x806050
			long diff_next = (char*)(va_block->prev_next_info.le_next) - (char*)((char*)va_block+size);
  8034d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8034dc:	8b 00                	mov    (%eax),%eax
  8034de:	89 c1                	mov    %eax,%ecx
  8034e0:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8034e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8034e6:	01 d0                	add    %edx,%eax
  8034e8:	29 c1                	sub    %eax,%ecx
  8034ea:	89 c8                	mov    %ecx,%eax
  8034ec:	89 45 dc             	mov    %eax,-0x24(%ebp)
			long diff_prev = (char*)((char*)va_block->prev_next_info.le_prev+get_block_size(va_block->prev_next_info.le_prev)) - (char*)(va_block);
  8034ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8034f2:	8b 58 04             	mov    0x4(%eax),%ebx
  8034f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8034f8:	8b 40 04             	mov    0x4(%eax),%eax
  8034fb:	83 ec 0c             	sub    $0xc,%esp
  8034fe:	50                   	push   %eax
  8034ff:	e8 34 f3 ff ff       	call   802838 <get_block_size>
  803504:	83 c4 10             	add    $0x10,%esp
  803507:	01 d8                	add    %ebx,%eax
  803509:	89 c2                	mov    %eax,%edx
  80350b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80350e:	29 c2                	sub    %eax,%edx
  803510:	89 d0                	mov    %edx,%eax
  803512:	89 45 d8             	mov    %eax,-0x28(%ebp)
			//cprintf("here\n");
			if (diff_next<(4*sizeof(int))&&(diff_prev<(4*sizeof(int)))){
  803515:	8b 45 dc             	mov    -0x24(%ebp),%eax
  803518:	83 f8 0f             	cmp    $0xf,%eax
  80351b:	0f 87 5b 01 00 00    	ja     80367c <free_block+0x26b>
  803521:	8b 45 d8             	mov    -0x28(%ebp),%eax
  803524:	83 f8 0f             	cmp    $0xf,%eax
  803527:	0f 87 4f 01 00 00    	ja     80367c <free_block+0x26b>
				//both merge
				struct BlockElement *mos;



				newsize=get_block_size(va_block->prev_next_info.le_next);
  80352d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803530:	8b 00                	mov    (%eax),%eax
  803532:	83 ec 0c             	sub    $0xc,%esp
  803535:	50                   	push   %eax
  803536:	e8 fd f2 ff ff       	call   802838 <get_block_size>
  80353b:	83 c4 10             	add    $0x10,%esp
  80353e:	89 45 e0             	mov    %eax,-0x20(%ebp)
				newsize+=get_block_size(va_block->prev_next_info.le_prev);
  803541:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803544:	8b 40 04             	mov    0x4(%eax),%eax
  803547:	83 ec 0c             	sub    $0xc,%esp
  80354a:	50                   	push   %eax
  80354b:	e8 e8 f2 ff ff       	call   802838 <get_block_size>
  803550:	83 c4 10             	add    $0x10,%esp
  803553:	01 45 e0             	add    %eax,-0x20(%ebp)
				newsize+=size;
  803556:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803559:	01 45 e0             	add    %eax,-0x20(%ebp)

				set_block_data(va_block->prev_next_info.le_prev,newsize,0);
  80355c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80355f:	8b 40 04             	mov    0x4(%eax),%eax
  803562:	83 ec 04             	sub    $0x4,%esp
  803565:	6a 00                	push   $0x0
  803567:	ff 75 e0             	pushl  -0x20(%ebp)
  80356a:	50                   	push   %eax
  80356b:	e8 49 f5 ff ff       	call   802ab9 <set_block_data>
  803570:	83 c4 10             	add    $0x10,%esp

				LIST_REMOVE(&freeBlocksList,block);
  803573:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  803577:	75 17                	jne    803590 <free_block+0x17f>
  803579:	83 ec 04             	sub    $0x4,%esp
  80357c:	68 0f 4f 80 00       	push   $0x804f0f
  803581:	68 a2 01 00 00       	push   $0x1a2
  803586:	68 f7 4e 80 00       	push   $0x804ef7
  80358b:	e8 f9 da ff ff       	call   801089 <_panic>
  803590:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803593:	8b 00                	mov    (%eax),%eax
  803595:	85 c0                	test   %eax,%eax
  803597:	74 10                	je     8035a9 <free_block+0x198>
  803599:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80359c:	8b 00                	mov    (%eax),%eax
  80359e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8035a1:	8b 52 04             	mov    0x4(%edx),%edx
  8035a4:	89 50 04             	mov    %edx,0x4(%eax)
  8035a7:	eb 0b                	jmp    8035b4 <free_block+0x1a3>
  8035a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035ac:	8b 40 04             	mov    0x4(%eax),%eax
  8035af:	a3 48 60 80 00       	mov    %eax,0x806048
  8035b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035b7:	8b 40 04             	mov    0x4(%eax),%eax
  8035ba:	85 c0                	test   %eax,%eax
  8035bc:	74 0f                	je     8035cd <free_block+0x1bc>
  8035be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035c1:	8b 40 04             	mov    0x4(%eax),%eax
  8035c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8035c7:	8b 12                	mov    (%edx),%edx
  8035c9:	89 10                	mov    %edx,(%eax)
  8035cb:	eb 0a                	jmp    8035d7 <free_block+0x1c6>
  8035cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035d0:	8b 00                	mov    (%eax),%eax
  8035d2:	a3 44 60 80 00       	mov    %eax,0x806044
  8035d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035da:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  8035e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035e3:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  8035ea:	a1 50 60 80 00       	mov    0x806050,%eax
  8035ef:	48                   	dec    %eax
  8035f0:	a3 50 60 80 00       	mov    %eax,0x806050
				LIST_REMOVE(&freeBlocksList,va_block);
  8035f5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8035f9:	75 17                	jne    803612 <free_block+0x201>
  8035fb:	83 ec 04             	sub    $0x4,%esp
  8035fe:	68 0f 4f 80 00       	push   $0x804f0f
  803603:	68 a3 01 00 00       	push   $0x1a3
  803608:	68 f7 4e 80 00       	push   $0x804ef7
  80360d:	e8 77 da ff ff       	call   801089 <_panic>
  803612:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803615:	8b 00                	mov    (%eax),%eax
  803617:	85 c0                	test   %eax,%eax
  803619:	74 10                	je     80362b <free_block+0x21a>
  80361b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80361e:	8b 00                	mov    (%eax),%eax
  803620:	8b 55 ec             	mov    -0x14(%ebp),%edx
  803623:	8b 52 04             	mov    0x4(%edx),%edx
  803626:	89 50 04             	mov    %edx,0x4(%eax)
  803629:	eb 0b                	jmp    803636 <free_block+0x225>
  80362b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80362e:	8b 40 04             	mov    0x4(%eax),%eax
  803631:	a3 48 60 80 00       	mov    %eax,0x806048
  803636:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803639:	8b 40 04             	mov    0x4(%eax),%eax
  80363c:	85 c0                	test   %eax,%eax
  80363e:	74 0f                	je     80364f <free_block+0x23e>
  803640:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803643:	8b 40 04             	mov    0x4(%eax),%eax
  803646:	8b 55 ec             	mov    -0x14(%ebp),%edx
  803649:	8b 12                	mov    (%edx),%edx
  80364b:	89 10                	mov    %edx,(%eax)
  80364d:	eb 0a                	jmp    803659 <free_block+0x248>
  80364f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803652:	8b 00                	mov    (%eax),%eax
  803654:	a3 44 60 80 00       	mov    %eax,0x806044
  803659:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80365c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  803662:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803665:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  80366c:	a1 50 60 80 00       	mov    0x806050,%eax
  803671:	48                   	dec    %eax
  803672:	a3 50 60 80 00       	mov    %eax,0x806050
				//cprintf("both");


				return;
  803677:	e9 19 03 00 00       	jmp    803995 <free_block+0x584>

			}
			else if (diff_next<(4*sizeof(int))){
  80367c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80367f:	83 f8 0f             	cmp    $0xf,%eax
  803682:	0f 87 b4 00 00 00    	ja     80373c <free_block+0x32b>
				//just next merge
				newsize=get_block_size(va_block->prev_next_info.le_next);
  803688:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80368b:	8b 00                	mov    (%eax),%eax
  80368d:	83 ec 0c             	sub    $0xc,%esp
  803690:	50                   	push   %eax
  803691:	e8 a2 f1 ff ff       	call   802838 <get_block_size>
  803696:	83 c4 10             	add    $0x10,%esp
  803699:	89 45 e0             	mov    %eax,-0x20(%ebp)
				newsize+=size;
  80369c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80369f:	01 45 e0             	add    %eax,-0x20(%ebp)
				set_block_data(va_block,newsize,0);
  8036a2:	83 ec 04             	sub    $0x4,%esp
  8036a5:	6a 00                	push   $0x0
  8036a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8036aa:	ff 75 ec             	pushl  -0x14(%ebp)
  8036ad:	e8 07 f4 ff ff       	call   802ab9 <set_block_data>
  8036b2:	83 c4 10             	add    $0x10,%esp
				//LIST_INSERT_BEFORE(&freeBlocksList,va_block->prev_next_info.le_next,va_block);
				LIST_REMOVE(&freeBlocksList,block);
  8036b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8036b9:	75 17                	jne    8036d2 <free_block+0x2c1>
  8036bb:	83 ec 04             	sub    $0x4,%esp
  8036be:	68 0f 4f 80 00       	push   $0x804f0f
  8036c3:	68 b0 01 00 00       	push   $0x1b0
  8036c8:	68 f7 4e 80 00       	push   $0x804ef7
  8036cd:	e8 b7 d9 ff ff       	call   801089 <_panic>
  8036d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8036d5:	8b 00                	mov    (%eax),%eax
  8036d7:	85 c0                	test   %eax,%eax
  8036d9:	74 10                	je     8036eb <free_block+0x2da>
  8036db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8036de:	8b 00                	mov    (%eax),%eax
  8036e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8036e3:	8b 52 04             	mov    0x4(%edx),%edx
  8036e6:	89 50 04             	mov    %edx,0x4(%eax)
  8036e9:	eb 0b                	jmp    8036f6 <free_block+0x2e5>
  8036eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8036ee:	8b 40 04             	mov    0x4(%eax),%eax
  8036f1:	a3 48 60 80 00       	mov    %eax,0x806048
  8036f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8036f9:	8b 40 04             	mov    0x4(%eax),%eax
  8036fc:	85 c0                	test   %eax,%eax
  8036fe:	74 0f                	je     80370f <free_block+0x2fe>
  803700:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803703:	8b 40 04             	mov    0x4(%eax),%eax
  803706:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803709:	8b 12                	mov    (%edx),%edx
  80370b:	89 10                	mov    %edx,(%eax)
  80370d:	eb 0a                	jmp    803719 <free_block+0x308>
  80370f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803712:	8b 00                	mov    (%eax),%eax
  803714:	a3 44 60 80 00       	mov    %eax,0x806044
  803719:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80371c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  803722:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803725:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  80372c:	a1 50 60 80 00       	mov    0x806050,%eax
  803731:	48                   	dec    %eax
  803732:	a3 50 60 80 00       	mov    %eax,0x806050
				//cprintf("just next/n");
				return;
  803737:	e9 59 02 00 00       	jmp    803995 <free_block+0x584>

			}
			else if(diff_prev<(4*sizeof(int))){
  80373c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80373f:	83 f8 0f             	cmp    $0xf,%eax
  803742:	0f 87 4c 02 00 00    	ja     803994 <free_block+0x583>
				//just prev
				prev=va_block->prev_next_info.le_prev;
  803748:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80374b:	8b 40 04             	mov    0x4(%eax),%eax
  80374e:	89 45 e8             	mov    %eax,-0x18(%ebp)

				newsize=get_block_size(va_block->prev_next_info.le_prev);
  803751:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803754:	8b 40 04             	mov    0x4(%eax),%eax
  803757:	83 ec 0c             	sub    $0xc,%esp
  80375a:	50                   	push   %eax
  80375b:	e8 d8 f0 ff ff       	call   802838 <get_block_size>
  803760:	83 c4 10             	add    $0x10,%esp
  803763:	89 45 e0             	mov    %eax,-0x20(%ebp)
				newsize+=size;
  803766:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803769:	01 45 e0             	add    %eax,-0x20(%ebp)
			//	cprintf("the new size %d-----size%d\n",newsize ,size);
				//cprintf("herrrrrrrrrrrrrrrr---------------------->%x\n",alloc_block_FF(get_block_size(prev)));
				//cprintf("the size before edit%d\n",get_block_size(prev));
				set_block_data(prev,newsize,0);
  80376c:	83 ec 04             	sub    $0x4,%esp
  80376f:	6a 00                	push   $0x0
  803771:	ff 75 e0             	pushl  -0x20(%ebp)
  803774:	ff 75 e8             	pushl  -0x18(%ebp)
  803777:	e8 3d f3 ff ff       	call   802ab9 <set_block_data>
  80377c:	83 c4 10             	add    $0x10,%esp
				//cprintf("the size AFTERedit%d\n",get_block_size(prev));

				LIST_REMOVE(&freeBlocksList,va_block);
  80377f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  803783:	75 17                	jne    80379c <free_block+0x38b>
  803785:	83 ec 04             	sub    $0x4,%esp
  803788:	68 0f 4f 80 00       	push   $0x804f0f
  80378d:	68 c1 01 00 00       	push   $0x1c1
  803792:	68 f7 4e 80 00       	push   $0x804ef7
  803797:	e8 ed d8 ff ff       	call   801089 <_panic>
  80379c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80379f:	8b 00                	mov    (%eax),%eax
  8037a1:	85 c0                	test   %eax,%eax
  8037a3:	74 10                	je     8037b5 <free_block+0x3a4>
  8037a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8037a8:	8b 00                	mov    (%eax),%eax
  8037aa:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8037ad:	8b 52 04             	mov    0x4(%edx),%edx
  8037b0:	89 50 04             	mov    %edx,0x4(%eax)
  8037b3:	eb 0b                	jmp    8037c0 <free_block+0x3af>
  8037b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8037b8:	8b 40 04             	mov    0x4(%eax),%eax
  8037bb:	a3 48 60 80 00       	mov    %eax,0x806048
  8037c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8037c3:	8b 40 04             	mov    0x4(%eax),%eax
  8037c6:	85 c0                	test   %eax,%eax
  8037c8:	74 0f                	je     8037d9 <free_block+0x3c8>
  8037ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8037cd:	8b 40 04             	mov    0x4(%eax),%eax
  8037d0:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8037d3:	8b 12                	mov    (%edx),%edx
  8037d5:	89 10                	mov    %edx,(%eax)
  8037d7:	eb 0a                	jmp    8037e3 <free_block+0x3d2>
  8037d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8037dc:	8b 00                	mov    (%eax),%eax
  8037de:	a3 44 60 80 00       	mov    %eax,0x806044
  8037e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8037e6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  8037ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8037ef:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  8037f6:	a1 50 60 80 00       	mov    0x806050,%eax
  8037fb:	48                   	dec    %eax
  8037fc:	a3 50 60 80 00       	mov    %eax,0x806050
				//cprintf("size AFTER REmove %d",LIST_SIZE(&freeBlocksList));
				//cprintf("justprev\n");

				return;
  803801:	e9 8f 01 00 00       	jmp    803995 <free_block+0x584>
	set_block_data(va,size,0);//set free block
	struct BlockElement* va_block=(struct BlockElement*)va;
	struct BlockElement* prev;
	uint32 newsize;
	//cprintf("here before each\n");
	LIST_FOREACH(block,&freeBlocksList){
  803806:	a1 4c 60 80 00       	mov    0x80604c,%eax
  80380b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80380e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  803812:	74 07                	je     80381b <free_block+0x40a>
  803814:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803817:	8b 00                	mov    (%eax),%eax
  803819:	eb 05                	jmp    803820 <free_block+0x40f>
  80381b:	b8 00 00 00 00       	mov    $0x0,%eax
  803820:	a3 4c 60 80 00       	mov    %eax,0x80604c
  803825:	a1 4c 60 80 00       	mov    0x80604c,%eax
  80382a:	85 c0                	test   %eax,%eax
  80382c:	0f 85 21 fc ff ff    	jne    803453 <free_block+0x42>
  803832:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  803836:	0f 85 17 fc ff ff    	jne    803453 <free_block+0x42>

			}
		}
	}

	set_block_data(va_block,size,0);
  80383c:	83 ec 04             	sub    $0x4,%esp
  80383f:	6a 00                	push   $0x0
  803841:	ff 75 f0             	pushl  -0x10(%ebp)
  803844:	ff 75 ec             	pushl  -0x14(%ebp)
  803847:	e8 6d f2 ff ff       	call   802ab9 <set_block_data>
  80384c:	83 c4 10             	add    $0x10,%esp
	//cprintf("size before insert\n %d",LIST_SIZE(&freeBlocksList));
	LIST_INSERT_TAIL(&freeBlocksList,va_block);
  80384f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  803853:	75 17                	jne    80386c <free_block+0x45b>
  803855:	83 ec 04             	sub    $0x4,%esp
  803858:	68 64 4f 80 00       	push   $0x804f64
  80385d:	68 d1 01 00 00       	push   $0x1d1
  803862:	68 f7 4e 80 00       	push   $0x804ef7
  803867:	e8 1d d8 ff ff       	call   801089 <_panic>
  80386c:	8b 15 48 60 80 00    	mov    0x806048,%edx
  803872:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803875:	89 50 04             	mov    %edx,0x4(%eax)
  803878:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80387b:	8b 40 04             	mov    0x4(%eax),%eax
  80387e:	85 c0                	test   %eax,%eax
  803880:	74 0c                	je     80388e <free_block+0x47d>
  803882:	a1 48 60 80 00       	mov    0x806048,%eax
  803887:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80388a:	89 10                	mov    %edx,(%eax)
  80388c:	eb 08                	jmp    803896 <free_block+0x485>
  80388e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803891:	a3 44 60 80 00       	mov    %eax,0x806044
  803896:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803899:	a3 48 60 80 00       	mov    %eax,0x806048
  80389e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8038a1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  8038a7:	a1 50 60 80 00       	mov    0x806050,%eax
  8038ac:	40                   	inc    %eax
  8038ad:	a3 50 60 80 00       	mov    %eax,0x806050
	//cprintf((void*)(va_block-va_block->prev_next_info.le_prev));
	prev=va_block->prev_next_info.le_prev;
  8038b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8038b5:	8b 40 04             	mov    0x4(%eax),%eax
  8038b8:	89 45 e8             	mov    %eax,-0x18(%ebp)
	//cprintf("size AFTER insert\n %d",LIST_SIZE(&freeBlocksList));
	//cprintf("Address of va_block: %ld\n", (void*)get_block_size(prev));
//	cprintf("Address of prev: %p\n", (void*)prev);
//	cprintf("Address of prev+size: %p\n", (void*)((char*)prev+get_block_size(prev)));
	long diff = (char*)(va_block) - (char*)((char*)prev+get_block_size(prev));
  8038bb:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  8038be:	83 ec 0c             	sub    $0xc,%esp
  8038c1:	ff 75 e8             	pushl  -0x18(%ebp)
  8038c4:	e8 6f ef ff ff       	call   802838 <get_block_size>
  8038c9:	83 c4 10             	add    $0x10,%esp
  8038cc:	89 c2                	mov    %eax,%edx
  8038ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8038d1:	01 d0                	add    %edx,%eax
  8038d3:	29 c3                	sub    %eax,%ebx
  8038d5:	89 d8                	mov    %ebx,%eax
  8038d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	//cprintf("sub of va_block: %ld\n", (diff));
	if (diff<4*sizeof(int)){
  8038da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8038dd:	83 f8 0f             	cmp    $0xf,%eax
  8038e0:	0f 87 af 00 00 00    	ja     803995 <free_block+0x584>
		//cprintf("anan heene\n");
		//prev=va_block->prev_next_info.le_prev;
		newsize=get_block_size(prev);
  8038e6:	83 ec 0c             	sub    $0xc,%esp
  8038e9:	ff 75 e8             	pushl  -0x18(%ebp)
  8038ec:	e8 47 ef ff ff       	call   802838 <get_block_size>
  8038f1:	83 c4 10             	add    $0x10,%esp
  8038f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
		newsize+=size;
  8038f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8038fa:	01 45 e0             	add    %eax,-0x20(%ebp)
		LIST_REMOVE(&freeBlocksList,va_block);
  8038fd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  803901:	75 17                	jne    80391a <free_block+0x509>
  803903:	83 ec 04             	sub    $0x4,%esp
  803906:	68 0f 4f 80 00       	push   $0x804f0f
  80390b:	68 df 01 00 00       	push   $0x1df
  803910:	68 f7 4e 80 00       	push   $0x804ef7
  803915:	e8 6f d7 ff ff       	call   801089 <_panic>
  80391a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80391d:	8b 00                	mov    (%eax),%eax
  80391f:	85 c0                	test   %eax,%eax
  803921:	74 10                	je     803933 <free_block+0x522>
  803923:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803926:	8b 00                	mov    (%eax),%eax
  803928:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80392b:	8b 52 04             	mov    0x4(%edx),%edx
  80392e:	89 50 04             	mov    %edx,0x4(%eax)
  803931:	eb 0b                	jmp    80393e <free_block+0x52d>
  803933:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803936:	8b 40 04             	mov    0x4(%eax),%eax
  803939:	a3 48 60 80 00       	mov    %eax,0x806048
  80393e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803941:	8b 40 04             	mov    0x4(%eax),%eax
  803944:	85 c0                	test   %eax,%eax
  803946:	74 0f                	je     803957 <free_block+0x546>
  803948:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80394b:	8b 40 04             	mov    0x4(%eax),%eax
  80394e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  803951:	8b 12                	mov    (%edx),%edx
  803953:	89 10                	mov    %edx,(%eax)
  803955:	eb 0a                	jmp    803961 <free_block+0x550>
  803957:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80395a:	8b 00                	mov    (%eax),%eax
  80395c:	a3 44 60 80 00       	mov    %eax,0x806044
  803961:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803964:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  80396a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80396d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  803974:	a1 50 60 80 00       	mov    0x806050,%eax
  803979:	48                   	dec    %eax
  80397a:	a3 50 60 80 00       	mov    %eax,0x806050
		//cprintf("size AFTER REmove \n%d",LIST_SIZE(&freeBlocksList));
		set_block_data(prev,newsize,0);
  80397f:	83 ec 04             	sub    $0x4,%esp
  803982:	6a 00                	push   $0x0
  803984:	ff 75 e0             	pushl  -0x20(%ebp)
  803987:	ff 75 e8             	pushl  -0x18(%ebp)
  80398a:	e8 2a f1 ff ff       	call   802ab9 <set_block_data>
  80398f:	83 c4 10             	add    $0x10,%esp
  803992:	eb 01                	jmp    803995 <free_block+0x584>

				return;
			}
			else {

				return;
  803994:	90                   	nop
		set_block_data(prev,newsize,0);
		//LIST_INSERT_TAIL(&freeBlocksList,prev);
		//cprintf("size AFTER insert\n %d",LIST_SIZE(&freeBlocksList));

	}
}}
  803995:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803998:	c9                   	leave  
  803999:	c3                   	ret    

0080399a <realloc_block_FF>:
//=========================================
// [6] REALLOCATE BLOCK BY FIRST FIT:
//=========================================
void *realloc_block_FF(void* va, uint32 new_size)
{
  80399a:	55                   	push   %ebp
  80399b:	89 e5                	mov    %esp,%ebp
  80399d:	83 ec 38             	sub    $0x38,%esp
	//TODO: [PROJECT'24.MS1 - #08] [3] DYNAMIC ALLOCATOR - realloc_block_FF
	//COMMENT THE FOLLOWING LINE BEFORE START CODING
	//panic("realloc_block_FF is not implemented yet");
	//Your Code is Here...
	// cprintf("(size: %d, isFree: %d)\n", next, va) ;
	    if (va == NULL) {
  8039a0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8039a4:	75 23                	jne    8039c9 <realloc_block_FF+0x2f>
	    	//cprintf("(size: %d, NULxxxxxxxLLLL: %d)\n", next, va) ;
	        return (new_size == 0) ? NULL : alloc_block_FF(new_size);
  8039a6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8039aa:	74 13                	je     8039bf <realloc_block_FF+0x25>
  8039ac:	83 ec 0c             	sub    $0xc,%esp
  8039af:	ff 75 0c             	pushl  0xc(%ebp)
  8039b2:	e8 4f f1 ff ff       	call   802b06 <alloc_block_FF>
  8039b7:	83 c4 10             	add    $0x10,%esp
  8039ba:	e9 af 02 00 00       	jmp    803c6e <realloc_block_FF+0x2d4>
  8039bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8039c4:	e9 a5 02 00 00       	jmp    803c6e <realloc_block_FF+0x2d4>
	        //cprintf("(size: %d, SUIIIIIIIIL: %d)\n", next, va) ;
	        //	return NULL ;
	    }


	    if (new_size == 0) {
  8039c9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8039cd:	75 18                	jne    8039e7 <realloc_block_FF+0x4d>
	        free_block(va);
  8039cf:	83 ec 0c             	sub    $0xc,%esp
  8039d2:	ff 75 08             	pushl  0x8(%ebp)
  8039d5:	e8 37 fa ff ff       	call   803411 <free_block>
  8039da:	83 c4 10             	add    $0x10,%esp
	        return NULL;
  8039dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8039e2:	e9 87 02 00 00       	jmp    803c6e <realloc_block_FF+0x2d4>
	    }



	    struct BlockElement* block = (struct BlockElement*)va;
  8039e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8039ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    uint32 curr = get_block_size(block) - 2 * sizeof(int);
  8039ed:	83 ec 0c             	sub    $0xc,%esp
  8039f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8039f3:	e8 40 ee ff ff       	call   802838 <get_block_size>
  8039f8:	83 c4 10             	add    $0x10,%esp
  8039fb:	83 e8 08             	sub    $0x8,%eax
  8039fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
	    if (new_size==curr)return va;
  803a01:	8b 45 0c             	mov    0xc(%ebp),%eax
  803a04:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  803a07:	75 08                	jne    803a11 <realloc_block_FF+0x77>
  803a09:	8b 45 08             	mov    0x8(%ebp),%eax
  803a0c:	e9 5d 02 00 00       	jmp    803c6e <realloc_block_FF+0x2d4>
	    struct BlockElement* next = (struct BlockElement*)((void*)block + get_block_size(block));
  803a11:	83 ec 0c             	sub    $0xc,%esp
  803a14:	ff 75 f4             	pushl  -0xc(%ebp)
  803a17:	e8 1c ee ff ff       	call   802838 <get_block_size>
  803a1c:	83 c4 10             	add    $0x10,%esp
  803a1f:	89 c2                	mov    %eax,%edx
  803a21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803a24:	01 d0                	add    %edx,%eax
  803a26:	89 45 ec             	mov    %eax,-0x14(%ebp)
	    //decrase the size-----done
	    if (new_size <= curr) {
  803a29:	8b 45 0c             	mov    0xc(%ebp),%eax
  803a2c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  803a2f:	0f 87 d8 00 00 00    	ja     803b0d <realloc_block_FF+0x173>
	        uint32 remainsize = curr - new_size ;
  803a35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803a38:	2b 45 0c             	sub    0xc(%ebp),%eax
  803a3b:	89 45 e8             	mov    %eax,-0x18(%ebp)


	        if (remainsize >= 4 * sizeof(int)) {
  803a3e:	83 7d e8 0f          	cmpl   $0xf,-0x18(%ebp)
  803a42:	76 48                	jbe    803a8c <realloc_block_FF+0xf2>
	            struct BlockElement* new_free_block = (struct BlockElement*)((char*)block+new_size+2*sizeof(int));
  803a44:	8b 45 0c             	mov    0xc(%ebp),%eax
  803a47:	8d 50 08             	lea    0x8(%eax),%edx
  803a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803a4d:	01 d0                	add    %edx,%eax
  803a4f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	            set_block_data(new_free_block, remainsize, 0);
  803a52:	83 ec 04             	sub    $0x4,%esp
  803a55:	6a 00                	push   $0x0
  803a57:	ff 75 e8             	pushl  -0x18(%ebp)
  803a5a:	ff 75 e0             	pushl  -0x20(%ebp)
  803a5d:	e8 57 f0 ff ff       	call   802ab9 <set_block_data>
  803a62:	83 c4 10             	add    $0x10,%esp
	            set_block_data(block, new_size + 2 * sizeof(int), 1);
  803a65:	8b 45 0c             	mov    0xc(%ebp),%eax
  803a68:	83 c0 08             	add    $0x8,%eax
  803a6b:	83 ec 04             	sub    $0x4,%esp
  803a6e:	6a 01                	push   $0x1
  803a70:	50                   	push   %eax
  803a71:	ff 75 f4             	pushl  -0xc(%ebp)
  803a74:	e8 40 f0 ff ff       	call   802ab9 <set_block_data>
  803a79:	83 c4 10             	add    $0x10,%esp

	          //  print_blocks_list(freeBlocksList);
	            free_block(new_free_block);
  803a7c:	83 ec 0c             	sub    $0xc,%esp
  803a7f:	ff 75 e0             	pushl  -0x20(%ebp)
  803a82:	e8 8a f9 ff ff       	call   803411 <free_block>
  803a87:	83 c4 10             	add    $0x10,%esp
  803a8a:	eb 79                	jmp    803b05 <realloc_block_FF+0x16b>



	        }

	       else if (is_free_block(next)){
  803a8c:	83 ec 0c             	sub    $0xc,%esp
  803a8f:	ff 75 ec             	pushl  -0x14(%ebp)
  803a92:	e8 ba ed ff ff       	call   802851 <is_free_block>
  803a97:	83 c4 10             	add    $0x10,%esp
  803a9a:	84 c0                	test   %al,%al
  803a9c:	74 48                	je     803ae6 <realloc_block_FF+0x14c>
	        	 struct BlockElement* new_free_block = (struct BlockElement*)((char*)block+new_size+2*sizeof(int));
  803a9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  803aa1:	8d 50 08             	lea    0x8(%eax),%edx
  803aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803aa7:	01 d0                	add    %edx,%eax
  803aa9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	        	set_block_data(new_free_block,remainsize,0);
  803aac:	83 ec 04             	sub    $0x4,%esp
  803aaf:	6a 00                	push   $0x0
  803ab1:	ff 75 e8             	pushl  -0x18(%ebp)
  803ab4:	ff 75 e4             	pushl  -0x1c(%ebp)
  803ab7:	e8 fd ef ff ff       	call   802ab9 <set_block_data>
  803abc:	83 c4 10             	add    $0x10,%esp
	        	free_block(new_free_block);
  803abf:	83 ec 0c             	sub    $0xc,%esp
  803ac2:	ff 75 e4             	pushl  -0x1c(%ebp)
  803ac5:	e8 47 f9 ff ff       	call   803411 <free_block>
  803aca:	83 c4 10             	add    $0x10,%esp
	        	set_block_data(block,new_size+2*sizeof(int),1);
  803acd:	8b 45 0c             	mov    0xc(%ebp),%eax
  803ad0:	83 c0 08             	add    $0x8,%eax
  803ad3:	83 ec 04             	sub    $0x4,%esp
  803ad6:	6a 01                	push   $0x1
  803ad8:	50                   	push   %eax
  803ad9:	ff 75 f4             	pushl  -0xc(%ebp)
  803adc:	e8 d8 ef ff ff       	call   802ab9 <set_block_data>
  803ae1:	83 c4 10             	add    $0x10,%esp
  803ae4:	eb 1f                	jmp    803b05 <realloc_block_FF+0x16b>

	        }

	        else{
	        	 set_block_data(block, curr + 2 * sizeof(int), 1);
  803ae6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803ae9:	83 c0 08             	add    $0x8,%eax
  803aec:	83 ec 04             	sub    $0x4,%esp
  803aef:	6a 01                	push   $0x1
  803af1:	50                   	push   %eax
  803af2:	ff 75 f4             	pushl  -0xc(%ebp)
  803af5:	e8 bf ef ff ff       	call   802ab9 <set_block_data>
  803afa:	83 c4 10             	add    $0x10,%esp
	        	        return (void*)block;
  803afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803b00:	e9 69 01 00 00       	jmp    803c6e <realloc_block_FF+0x2d4>

	        }
	        return (void*)block;
  803b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803b08:	e9 61 01 00 00       	jmp    803c6e <realloc_block_FF+0x2d4>
	    }

	    else if(new_size > curr)
  803b0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  803b10:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  803b13:	0f 86 28 01 00 00    	jbe    803c41 <realloc_block_FF+0x2a7>





	    if (is_free_block(next) && (get_block_size(next) + curr >= new_size)) {
  803b19:	83 ec 0c             	sub    $0xc,%esp
  803b1c:	ff 75 ec             	pushl  -0x14(%ebp)
  803b1f:	e8 2d ed ff ff       	call   802851 <is_free_block>
  803b24:	83 c4 10             	add    $0x10,%esp
  803b27:	84 c0                	test   %al,%al
  803b29:	0f 84 12 01 00 00    	je     803c41 <realloc_block_FF+0x2a7>
  803b2f:	83 ec 0c             	sub    $0xc,%esp
  803b32:	ff 75 ec             	pushl  -0x14(%ebp)
  803b35:	e8 fe ec ff ff       	call   802838 <get_block_size>
  803b3a:	83 c4 10             	add    $0x10,%esp
  803b3d:	89 c2                	mov    %eax,%edx
  803b3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803b42:	01 d0                	add    %edx,%eax
  803b44:	3b 45 0c             	cmp    0xc(%ebp),%eax
  803b47:	0f 82 f4 00 00 00    	jb     803c41 <realloc_block_FF+0x2a7>

	        uint32 newsizeeeee = get_block_size(next) + curr;
  803b4d:	83 ec 0c             	sub    $0xc,%esp
  803b50:	ff 75 ec             	pushl  -0x14(%ebp)
  803b53:	e8 e0 ec ff ff       	call   802838 <get_block_size>
  803b58:	83 c4 10             	add    $0x10,%esp
  803b5b:	89 c2                	mov    %eax,%edx
  803b5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803b60:	01 d0                	add    %edx,%eax
  803b62:	89 45 dc             	mov    %eax,-0x24(%ebp)
	        uint32 remaining_size = newsizeeeee - new_size;
  803b65:	8b 45 dc             	mov    -0x24(%ebp),%eax
  803b68:	2b 45 0c             	sub    0xc(%ebp),%eax
  803b6b:	89 45 d8             	mov    %eax,-0x28(%ebp)

	        if (remaining_size >= 4 * sizeof(int)) {
  803b6e:	83 7d d8 0f          	cmpl   $0xf,-0x28(%ebp)
  803b72:	76 2f                	jbe    803ba3 <realloc_block_FF+0x209>

	            struct BlockElement* new_free_block = (struct BlockElement*)((void*)block + new_size + 2 * sizeof(int));
  803b74:	8b 45 0c             	mov    0xc(%ebp),%eax
  803b77:	8d 50 08             	lea    0x8(%eax),%edx
  803b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803b7d:	01 d0                	add    %edx,%eax
  803b7f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	            set_block_data(new_free_block, remaining_size, 0);
  803b82:	83 ec 04             	sub    $0x4,%esp
  803b85:	6a 00                	push   $0x0
  803b87:	ff 75 d8             	pushl  -0x28(%ebp)
  803b8a:	ff 75 d4             	pushl  -0x2c(%ebp)
  803b8d:	e8 27 ef ff ff       	call   802ab9 <set_block_data>
  803b92:	83 c4 10             	add    $0x10,%esp
	            free_block(new_free_block);
  803b95:	83 ec 0c             	sub    $0xc,%esp
  803b98:	ff 75 d4             	pushl  -0x2c(%ebp)
  803b9b:	e8 71 f8 ff ff       	call   803411 <free_block>
  803ba0:	83 c4 10             	add    $0x10,%esp

	        }

	        LIST_REMOVE(&freeBlocksList, next);
  803ba3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  803ba7:	75 17                	jne    803bc0 <realloc_block_FF+0x226>
  803ba9:	83 ec 04             	sub    $0x4,%esp
  803bac:	68 0f 4f 80 00       	push   $0x804f0f
  803bb1:	68 3d 02 00 00       	push   $0x23d
  803bb6:	68 f7 4e 80 00       	push   $0x804ef7
  803bbb:	e8 c9 d4 ff ff       	call   801089 <_panic>
  803bc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803bc3:	8b 00                	mov    (%eax),%eax
  803bc5:	85 c0                	test   %eax,%eax
  803bc7:	74 10                	je     803bd9 <realloc_block_FF+0x23f>
  803bc9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803bcc:	8b 00                	mov    (%eax),%eax
  803bce:	8b 55 ec             	mov    -0x14(%ebp),%edx
  803bd1:	8b 52 04             	mov    0x4(%edx),%edx
  803bd4:	89 50 04             	mov    %edx,0x4(%eax)
  803bd7:	eb 0b                	jmp    803be4 <realloc_block_FF+0x24a>
  803bd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803bdc:	8b 40 04             	mov    0x4(%eax),%eax
  803bdf:	a3 48 60 80 00       	mov    %eax,0x806048
  803be4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803be7:	8b 40 04             	mov    0x4(%eax),%eax
  803bea:	85 c0                	test   %eax,%eax
  803bec:	74 0f                	je     803bfd <realloc_block_FF+0x263>
  803bee:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803bf1:	8b 40 04             	mov    0x4(%eax),%eax
  803bf4:	8b 55 ec             	mov    -0x14(%ebp),%edx
  803bf7:	8b 12                	mov    (%edx),%edx
  803bf9:	89 10                	mov    %edx,(%eax)
  803bfb:	eb 0a                	jmp    803c07 <realloc_block_FF+0x26d>
  803bfd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803c00:	8b 00                	mov    (%eax),%eax
  803c02:	a3 44 60 80 00       	mov    %eax,0x806044
  803c07:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803c0a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  803c10:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803c13:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  803c1a:	a1 50 60 80 00       	mov    0x806050,%eax
  803c1f:	48                   	dec    %eax
  803c20:	a3 50 60 80 00       	mov    %eax,0x806050
	        set_block_data(block, new_size + 2 * sizeof(int), 1);
  803c25:	8b 45 0c             	mov    0xc(%ebp),%eax
  803c28:	83 c0 08             	add    $0x8,%eax
  803c2b:	83 ec 04             	sub    $0x4,%esp
  803c2e:	6a 01                	push   $0x1
  803c30:	50                   	push   %eax
  803c31:	ff 75 f4             	pushl  -0xc(%ebp)
  803c34:	e8 80 ee ff ff       	call   802ab9 <set_block_data>
  803c39:	83 c4 10             	add    $0x10,%esp
	        return (void*)block;
  803c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803c3f:	eb 2d                	jmp    803c6e <realloc_block_FF+0x2d4>
	    }
	    }


	    void* new_block = alloc_block_FF(new_size);
  803c41:	83 ec 0c             	sub    $0xc,%esp
  803c44:	ff 75 0c             	pushl  0xc(%ebp)
  803c47:	e8 ba ee ff ff       	call   802b06 <alloc_block_FF>
  803c4c:	83 c4 10             	add    $0x10,%esp
  803c4f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	    if (new_block != NULL) {
  803c52:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  803c56:	74 13                	je     803c6b <realloc_block_FF+0x2d1>

	        free_block(va);
  803c58:	83 ec 0c             	sub    $0xc,%esp
  803c5b:	ff 75 08             	pushl  0x8(%ebp)
  803c5e:	e8 ae f7 ff ff       	call   803411 <free_block>
  803c63:	83 c4 10             	add    $0x10,%esp
	        return new_block;
  803c66:	8b 45 d0             	mov    -0x30(%ebp),%eax
  803c69:	eb 03                	jmp    803c6e <realloc_block_FF+0x2d4>
	    }


	    return (void*)block;
  803c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  803c6e:	c9                   	leave  
  803c6f:	c3                   	ret    

00803c70 <alloc_block_WF>:
/*********************************************************************************************/
//=========================================
// [7] ALLOCATE BLOCK BY WORST FIT:
//=========================================
void *alloc_block_WF(uint32 size)
{
  803c70:	55                   	push   %ebp
  803c71:	89 e5                	mov    %esp,%ebp
  803c73:	83 ec 08             	sub    $0x8,%esp
	panic("alloc_block_WF is not implemented yet");
  803c76:	83 ec 04             	sub    $0x4,%esp
  803c79:	68 c0 4f 80 00       	push   $0x804fc0
  803c7e:	68 57 02 00 00       	push   $0x257
  803c83:	68 f7 4e 80 00       	push   $0x804ef7
  803c88:	e8 fc d3 ff ff       	call   801089 <_panic>

00803c8d <alloc_block_NF>:

//=========================================
// [8] ALLOCATE BLOCK BY NEXT FIT:
//=========================================
void *alloc_block_NF(uint32 size)
{
  803c8d:	55                   	push   %ebp
  803c8e:	89 e5                	mov    %esp,%ebp
  803c90:	83 ec 08             	sub    $0x8,%esp
	panic("alloc_block_NF is not implemented yet");
  803c93:	83 ec 04             	sub    $0x4,%esp
  803c96:	68 e8 4f 80 00       	push   $0x804fe8
  803c9b:	68 60 02 00 00       	push   $0x260
  803ca0:	68 f7 4e 80 00       	push   $0x804ef7
  803ca5:	e8 df d3 ff ff       	call   801089 <_panic>
  803caa:	66 90                	xchg   %ax,%ax

00803cac <__udivdi3>:
  803cac:	55                   	push   %ebp
  803cad:	57                   	push   %edi
  803cae:	56                   	push   %esi
  803caf:	53                   	push   %ebx
  803cb0:	83 ec 1c             	sub    $0x1c,%esp
  803cb3:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  803cb7:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803cbb:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803cbf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803cc3:	89 ca                	mov    %ecx,%edx
  803cc5:	89 f8                	mov    %edi,%eax
  803cc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  803ccb:	85 f6                	test   %esi,%esi
  803ccd:	75 2d                	jne    803cfc <__udivdi3+0x50>
  803ccf:	39 cf                	cmp    %ecx,%edi
  803cd1:	77 65                	ja     803d38 <__udivdi3+0x8c>
  803cd3:	89 fd                	mov    %edi,%ebp
  803cd5:	85 ff                	test   %edi,%edi
  803cd7:	75 0b                	jne    803ce4 <__udivdi3+0x38>
  803cd9:	b8 01 00 00 00       	mov    $0x1,%eax
  803cde:	31 d2                	xor    %edx,%edx
  803ce0:	f7 f7                	div    %edi
  803ce2:	89 c5                	mov    %eax,%ebp
  803ce4:	31 d2                	xor    %edx,%edx
  803ce6:	89 c8                	mov    %ecx,%eax
  803ce8:	f7 f5                	div    %ebp
  803cea:	89 c1                	mov    %eax,%ecx
  803cec:	89 d8                	mov    %ebx,%eax
  803cee:	f7 f5                	div    %ebp
  803cf0:	89 cf                	mov    %ecx,%edi
  803cf2:	89 fa                	mov    %edi,%edx
  803cf4:	83 c4 1c             	add    $0x1c,%esp
  803cf7:	5b                   	pop    %ebx
  803cf8:	5e                   	pop    %esi
  803cf9:	5f                   	pop    %edi
  803cfa:	5d                   	pop    %ebp
  803cfb:	c3                   	ret    
  803cfc:	39 ce                	cmp    %ecx,%esi
  803cfe:	77 28                	ja     803d28 <__udivdi3+0x7c>
  803d00:	0f bd fe             	bsr    %esi,%edi
  803d03:	83 f7 1f             	xor    $0x1f,%edi
  803d06:	75 40                	jne    803d48 <__udivdi3+0x9c>
  803d08:	39 ce                	cmp    %ecx,%esi
  803d0a:	72 0a                	jb     803d16 <__udivdi3+0x6a>
  803d0c:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803d10:	0f 87 9e 00 00 00    	ja     803db4 <__udivdi3+0x108>
  803d16:	b8 01 00 00 00       	mov    $0x1,%eax
  803d1b:	89 fa                	mov    %edi,%edx
  803d1d:	83 c4 1c             	add    $0x1c,%esp
  803d20:	5b                   	pop    %ebx
  803d21:	5e                   	pop    %esi
  803d22:	5f                   	pop    %edi
  803d23:	5d                   	pop    %ebp
  803d24:	c3                   	ret    
  803d25:	8d 76 00             	lea    0x0(%esi),%esi
  803d28:	31 ff                	xor    %edi,%edi
  803d2a:	31 c0                	xor    %eax,%eax
  803d2c:	89 fa                	mov    %edi,%edx
  803d2e:	83 c4 1c             	add    $0x1c,%esp
  803d31:	5b                   	pop    %ebx
  803d32:	5e                   	pop    %esi
  803d33:	5f                   	pop    %edi
  803d34:	5d                   	pop    %ebp
  803d35:	c3                   	ret    
  803d36:	66 90                	xchg   %ax,%ax
  803d38:	89 d8                	mov    %ebx,%eax
  803d3a:	f7 f7                	div    %edi
  803d3c:	31 ff                	xor    %edi,%edi
  803d3e:	89 fa                	mov    %edi,%edx
  803d40:	83 c4 1c             	add    $0x1c,%esp
  803d43:	5b                   	pop    %ebx
  803d44:	5e                   	pop    %esi
  803d45:	5f                   	pop    %edi
  803d46:	5d                   	pop    %ebp
  803d47:	c3                   	ret    
  803d48:	bd 20 00 00 00       	mov    $0x20,%ebp
  803d4d:	89 eb                	mov    %ebp,%ebx
  803d4f:	29 fb                	sub    %edi,%ebx
  803d51:	89 f9                	mov    %edi,%ecx
  803d53:	d3 e6                	shl    %cl,%esi
  803d55:	89 c5                	mov    %eax,%ebp
  803d57:	88 d9                	mov    %bl,%cl
  803d59:	d3 ed                	shr    %cl,%ebp
  803d5b:	89 e9                	mov    %ebp,%ecx
  803d5d:	09 f1                	or     %esi,%ecx
  803d5f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  803d63:	89 f9                	mov    %edi,%ecx
  803d65:	d3 e0                	shl    %cl,%eax
  803d67:	89 c5                	mov    %eax,%ebp
  803d69:	89 d6                	mov    %edx,%esi
  803d6b:	88 d9                	mov    %bl,%cl
  803d6d:	d3 ee                	shr    %cl,%esi
  803d6f:	89 f9                	mov    %edi,%ecx
  803d71:	d3 e2                	shl    %cl,%edx
  803d73:	8b 44 24 08          	mov    0x8(%esp),%eax
  803d77:	88 d9                	mov    %bl,%cl
  803d79:	d3 e8                	shr    %cl,%eax
  803d7b:	09 c2                	or     %eax,%edx
  803d7d:	89 d0                	mov    %edx,%eax
  803d7f:	89 f2                	mov    %esi,%edx
  803d81:	f7 74 24 0c          	divl   0xc(%esp)
  803d85:	89 d6                	mov    %edx,%esi
  803d87:	89 c3                	mov    %eax,%ebx
  803d89:	f7 e5                	mul    %ebp
  803d8b:	39 d6                	cmp    %edx,%esi
  803d8d:	72 19                	jb     803da8 <__udivdi3+0xfc>
  803d8f:	74 0b                	je     803d9c <__udivdi3+0xf0>
  803d91:	89 d8                	mov    %ebx,%eax
  803d93:	31 ff                	xor    %edi,%edi
  803d95:	e9 58 ff ff ff       	jmp    803cf2 <__udivdi3+0x46>
  803d9a:	66 90                	xchg   %ax,%ax
  803d9c:	8b 54 24 08          	mov    0x8(%esp),%edx
  803da0:	89 f9                	mov    %edi,%ecx
  803da2:	d3 e2                	shl    %cl,%edx
  803da4:	39 c2                	cmp    %eax,%edx
  803da6:	73 e9                	jae    803d91 <__udivdi3+0xe5>
  803da8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  803dab:	31 ff                	xor    %edi,%edi
  803dad:	e9 40 ff ff ff       	jmp    803cf2 <__udivdi3+0x46>
  803db2:	66 90                	xchg   %ax,%ax
  803db4:	31 c0                	xor    %eax,%eax
  803db6:	e9 37 ff ff ff       	jmp    803cf2 <__udivdi3+0x46>
  803dbb:	90                   	nop

00803dbc <__umoddi3>:
  803dbc:	55                   	push   %ebp
  803dbd:	57                   	push   %edi
  803dbe:	56                   	push   %esi
  803dbf:	53                   	push   %ebx
  803dc0:	83 ec 1c             	sub    $0x1c,%esp
  803dc3:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  803dc7:	8b 74 24 34          	mov    0x34(%esp),%esi
  803dcb:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803dcf:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  803dd3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803dd7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803ddb:	89 f3                	mov    %esi,%ebx
  803ddd:	89 fa                	mov    %edi,%edx
  803ddf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  803de3:	89 34 24             	mov    %esi,(%esp)
  803de6:	85 c0                	test   %eax,%eax
  803de8:	75 1a                	jne    803e04 <__umoddi3+0x48>
  803dea:	39 f7                	cmp    %esi,%edi
  803dec:	0f 86 a2 00 00 00    	jbe    803e94 <__umoddi3+0xd8>
  803df2:	89 c8                	mov    %ecx,%eax
  803df4:	89 f2                	mov    %esi,%edx
  803df6:	f7 f7                	div    %edi
  803df8:	89 d0                	mov    %edx,%eax
  803dfa:	31 d2                	xor    %edx,%edx
  803dfc:	83 c4 1c             	add    $0x1c,%esp
  803dff:	5b                   	pop    %ebx
  803e00:	5e                   	pop    %esi
  803e01:	5f                   	pop    %edi
  803e02:	5d                   	pop    %ebp
  803e03:	c3                   	ret    
  803e04:	39 f0                	cmp    %esi,%eax
  803e06:	0f 87 ac 00 00 00    	ja     803eb8 <__umoddi3+0xfc>
  803e0c:	0f bd e8             	bsr    %eax,%ebp
  803e0f:	83 f5 1f             	xor    $0x1f,%ebp
  803e12:	0f 84 ac 00 00 00    	je     803ec4 <__umoddi3+0x108>
  803e18:	bf 20 00 00 00       	mov    $0x20,%edi
  803e1d:	29 ef                	sub    %ebp,%edi
  803e1f:	89 fe                	mov    %edi,%esi
  803e21:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803e25:	89 e9                	mov    %ebp,%ecx
  803e27:	d3 e0                	shl    %cl,%eax
  803e29:	89 d7                	mov    %edx,%edi
  803e2b:	89 f1                	mov    %esi,%ecx
  803e2d:	d3 ef                	shr    %cl,%edi
  803e2f:	09 c7                	or     %eax,%edi
  803e31:	89 e9                	mov    %ebp,%ecx
  803e33:	d3 e2                	shl    %cl,%edx
  803e35:	89 14 24             	mov    %edx,(%esp)
  803e38:	89 d8                	mov    %ebx,%eax
  803e3a:	d3 e0                	shl    %cl,%eax
  803e3c:	89 c2                	mov    %eax,%edx
  803e3e:	8b 44 24 08          	mov    0x8(%esp),%eax
  803e42:	d3 e0                	shl    %cl,%eax
  803e44:	89 44 24 04          	mov    %eax,0x4(%esp)
  803e48:	8b 44 24 08          	mov    0x8(%esp),%eax
  803e4c:	89 f1                	mov    %esi,%ecx
  803e4e:	d3 e8                	shr    %cl,%eax
  803e50:	09 d0                	or     %edx,%eax
  803e52:	d3 eb                	shr    %cl,%ebx
  803e54:	89 da                	mov    %ebx,%edx
  803e56:	f7 f7                	div    %edi
  803e58:	89 d3                	mov    %edx,%ebx
  803e5a:	f7 24 24             	mull   (%esp)
  803e5d:	89 c6                	mov    %eax,%esi
  803e5f:	89 d1                	mov    %edx,%ecx
  803e61:	39 d3                	cmp    %edx,%ebx
  803e63:	0f 82 87 00 00 00    	jb     803ef0 <__umoddi3+0x134>
  803e69:	0f 84 91 00 00 00    	je     803f00 <__umoddi3+0x144>
  803e6f:	8b 54 24 04          	mov    0x4(%esp),%edx
  803e73:	29 f2                	sub    %esi,%edx
  803e75:	19 cb                	sbb    %ecx,%ebx
  803e77:	89 d8                	mov    %ebx,%eax
  803e79:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  803e7d:	d3 e0                	shl    %cl,%eax
  803e7f:	89 e9                	mov    %ebp,%ecx
  803e81:	d3 ea                	shr    %cl,%edx
  803e83:	09 d0                	or     %edx,%eax
  803e85:	89 e9                	mov    %ebp,%ecx
  803e87:	d3 eb                	shr    %cl,%ebx
  803e89:	89 da                	mov    %ebx,%edx
  803e8b:	83 c4 1c             	add    $0x1c,%esp
  803e8e:	5b                   	pop    %ebx
  803e8f:	5e                   	pop    %esi
  803e90:	5f                   	pop    %edi
  803e91:	5d                   	pop    %ebp
  803e92:	c3                   	ret    
  803e93:	90                   	nop
  803e94:	89 fd                	mov    %edi,%ebp
  803e96:	85 ff                	test   %edi,%edi
  803e98:	75 0b                	jne    803ea5 <__umoddi3+0xe9>
  803e9a:	b8 01 00 00 00       	mov    $0x1,%eax
  803e9f:	31 d2                	xor    %edx,%edx
  803ea1:	f7 f7                	div    %edi
  803ea3:	89 c5                	mov    %eax,%ebp
  803ea5:	89 f0                	mov    %esi,%eax
  803ea7:	31 d2                	xor    %edx,%edx
  803ea9:	f7 f5                	div    %ebp
  803eab:	89 c8                	mov    %ecx,%eax
  803ead:	f7 f5                	div    %ebp
  803eaf:	89 d0                	mov    %edx,%eax
  803eb1:	e9 44 ff ff ff       	jmp    803dfa <__umoddi3+0x3e>
  803eb6:	66 90                	xchg   %ax,%ax
  803eb8:	89 c8                	mov    %ecx,%eax
  803eba:	89 f2                	mov    %esi,%edx
  803ebc:	83 c4 1c             	add    $0x1c,%esp
  803ebf:	5b                   	pop    %ebx
  803ec0:	5e                   	pop    %esi
  803ec1:	5f                   	pop    %edi
  803ec2:	5d                   	pop    %ebp
  803ec3:	c3                   	ret    
  803ec4:	3b 04 24             	cmp    (%esp),%eax
  803ec7:	72 06                	jb     803ecf <__umoddi3+0x113>
  803ec9:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  803ecd:	77 0f                	ja     803ede <__umoddi3+0x122>
  803ecf:	89 f2                	mov    %esi,%edx
  803ed1:	29 f9                	sub    %edi,%ecx
  803ed3:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  803ed7:	89 14 24             	mov    %edx,(%esp)
  803eda:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  803ede:	8b 44 24 04          	mov    0x4(%esp),%eax
  803ee2:	8b 14 24             	mov    (%esp),%edx
  803ee5:	83 c4 1c             	add    $0x1c,%esp
  803ee8:	5b                   	pop    %ebx
  803ee9:	5e                   	pop    %esi
  803eea:	5f                   	pop    %edi
  803eeb:	5d                   	pop    %ebp
  803eec:	c3                   	ret    
  803eed:	8d 76 00             	lea    0x0(%esi),%esi
  803ef0:	2b 04 24             	sub    (%esp),%eax
  803ef3:	19 fa                	sbb    %edi,%edx
  803ef5:	89 d1                	mov    %edx,%ecx
  803ef7:	89 c6                	mov    %eax,%esi
  803ef9:	e9 71 ff ff ff       	jmp    803e6f <__umoddi3+0xb3>
  803efe:	66 90                	xchg   %ax,%ax
  803f00:	39 44 24 04          	cmp    %eax,0x4(%esp)
  803f04:	72 ea                	jb     803ef0 <__umoddi3+0x134>
  803f06:	89 d9                	mov    %ebx,%ecx
  803f08:	e9 62 ff ff ff       	jmp    803e6f <__umoddi3+0xb3>
