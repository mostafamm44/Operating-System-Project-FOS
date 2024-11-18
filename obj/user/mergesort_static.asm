
obj/user/mergesort_static:     file format elf32-i386


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
  800031:	e8 d5 06 00 00       	call   80070b <libmain>
1:      jmp 1b
  800036:	eb fe                	jmp    800036 <args_exist+0x5>

00800038 <_main>:
void Merge(int* A, int p, int q, int r);

uint32 CheckSorted(int *Elements, int NumOfElements);

void _main(void)
{
  800038:	55                   	push   %ebp
  800039:	89 e5                	mov    %esp,%ebp
  80003b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	char Line[255] ;
	char Chose ;
	int numOfRep = 0;
  800041:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	do
	{
		numOfRep++ ;
  800048:	ff 45 f0             	incl   -0x10(%ebp)
		//2012: lock the interrupt
		sys_lock_cons();
  80004b:	e8 b6 18 00 00       	call   801906 <sys_lock_cons>

		cprintf("\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 40 21 80 00       	push   $0x802140
  800058:	e8 a2 0a 00 00       	call   800aff <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
		cprintf("!!!!!!!!!!!!!!!!!!!!\n");
  800060:	83 ec 0c             	sub    $0xc,%esp
  800063:	68 42 21 80 00       	push   $0x802142
  800068:	e8 92 0a 00 00       	call   800aff <cprintf>
  80006d:	83 c4 10             	add    $0x10,%esp
		cprintf("!!!! MERGE SORT !!!!\n");
  800070:	83 ec 0c             	sub    $0xc,%esp
  800073:	68 58 21 80 00       	push   $0x802158
  800078:	e8 82 0a 00 00       	call   800aff <cprintf>
  80007d:	83 c4 10             	add    $0x10,%esp
		cprintf("!!!!!!!!!!!!!!!!!!!!\n");
  800080:	83 ec 0c             	sub    $0xc,%esp
  800083:	68 42 21 80 00       	push   $0x802142
  800088:	e8 72 0a 00 00       	call   800aff <cprintf>
  80008d:	83 c4 10             	add    $0x10,%esp
		cprintf("\n");
  800090:	83 ec 0c             	sub    $0xc,%esp
  800093:	68 40 21 80 00       	push   $0x802140
  800098:	e8 62 0a 00 00       	call   800aff <cprintf>
  80009d:	83 c4 10             	add    $0x10,%esp
		int NumOfElements = 800000;
  8000a0:	c7 45 ec 00 35 0c 00 	movl   $0xc3500,-0x14(%ebp)
		cprintf("Enter the number of elements: %d\n", NumOfElements) ;
  8000a7:	83 ec 08             	sub    $0x8,%esp
  8000aa:	ff 75 ec             	pushl  -0x14(%ebp)
  8000ad:	68 70 21 80 00       	push   $0x802170
  8000b2:	e8 48 0a 00 00       	call   800aff <cprintf>
  8000b7:	83 c4 10             	add    $0x10,%esp

		cprintf("Chose the initialization method:\n") ;
  8000ba:	83 ec 0c             	sub    $0xc,%esp
  8000bd:	68 94 21 80 00       	push   $0x802194
  8000c2:	e8 38 0a 00 00       	call   800aff <cprintf>
  8000c7:	83 c4 10             	add    $0x10,%esp
		cprintf("a) Ascending\n") ;
  8000ca:	83 ec 0c             	sub    $0xc,%esp
  8000cd:	68 b6 21 80 00       	push   $0x8021b6
  8000d2:	e8 28 0a 00 00       	call   800aff <cprintf>
  8000d7:	83 c4 10             	add    $0x10,%esp
		cprintf("b) Descending\n") ;
  8000da:	83 ec 0c             	sub    $0xc,%esp
  8000dd:	68 c4 21 80 00       	push   $0x8021c4
  8000e2:	e8 18 0a 00 00       	call   800aff <cprintf>
  8000e7:	83 c4 10             	add    $0x10,%esp
		cprintf("c) Semi random\n");
  8000ea:	83 ec 0c             	sub    $0xc,%esp
  8000ed:	68 d3 21 80 00       	push   $0x8021d3
  8000f2:	e8 08 0a 00 00       	call   800aff <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
		do
		{
			cprintf("Select: ") ;
  8000fa:	83 ec 0c             	sub    $0xc,%esp
  8000fd:	68 e3 21 80 00       	push   $0x8021e3
  800102:	e8 f8 09 00 00       	call   800aff <cprintf>
  800107:	83 c4 10             	add    $0x10,%esp
			Chose = 'c' ;
  80010a:	c6 45 f7 63          	movb   $0x63,-0x9(%ebp)
			cputchar(Chose);
  80010e:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  800112:	83 ec 0c             	sub    $0xc,%esp
  800115:	50                   	push   %eax
  800116:	e8 b4 05 00 00       	call   8006cf <cputchar>
  80011b:	83 c4 10             	add    $0x10,%esp
			cputchar('\n');
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	6a 0a                	push   $0xa
  800123:	e8 a7 05 00 00       	call   8006cf <cputchar>
  800128:	83 c4 10             	add    $0x10,%esp
		} while (Chose != 'a' && Chose != 'b' && Chose != 'c');
  80012b:	80 7d f7 61          	cmpb   $0x61,-0x9(%ebp)
  80012f:	74 0c                	je     80013d <_main+0x105>
  800131:	80 7d f7 62          	cmpb   $0x62,-0x9(%ebp)
  800135:	74 06                	je     80013d <_main+0x105>
  800137:	80 7d f7 63          	cmpb   $0x63,-0x9(%ebp)
  80013b:	75 bd                	jne    8000fa <_main+0xc2>

		//2012: lock the interrupt
		sys_unlock_cons();
  80013d:	e8 de 17 00 00       	call   801920 <sys_unlock_cons>

		//int *Elements = malloc(sizeof(int) * NumOfElements) ;
		int *Elements = __Elements;
  800142:	c7 45 e8 60 04 b1 00 	movl   $0xb10460,-0x18(%ebp)
		int  i ;
		switch (Chose)
  800149:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  80014d:	83 f8 62             	cmp    $0x62,%eax
  800150:	74 1d                	je     80016f <_main+0x137>
  800152:	83 f8 63             	cmp    $0x63,%eax
  800155:	74 2b                	je     800182 <_main+0x14a>
  800157:	83 f8 61             	cmp    $0x61,%eax
  80015a:	75 39                	jne    800195 <_main+0x15d>
		{
		case 'a':
			InitializeAscending(Elements, NumOfElements);
  80015c:	83 ec 08             	sub    $0x8,%esp
  80015f:	ff 75 ec             	pushl  -0x14(%ebp)
  800162:	ff 75 e8             	pushl  -0x18(%ebp)
  800165:	e8 e7 01 00 00       	call   800351 <InitializeAscending>
  80016a:	83 c4 10             	add    $0x10,%esp
			break ;
  80016d:	eb 37                	jmp    8001a6 <_main+0x16e>
		case 'b':
			InitializeIdentical(Elements, NumOfElements);
  80016f:	83 ec 08             	sub    $0x8,%esp
  800172:	ff 75 ec             	pushl  -0x14(%ebp)
  800175:	ff 75 e8             	pushl  -0x18(%ebp)
  800178:	e8 05 02 00 00       	call   800382 <InitializeIdentical>
  80017d:	83 c4 10             	add    $0x10,%esp
			break ;
  800180:	eb 24                	jmp    8001a6 <_main+0x16e>
		case 'c':
			InitializeSemiRandom(Elements, NumOfElements);
  800182:	83 ec 08             	sub    $0x8,%esp
  800185:	ff 75 ec             	pushl  -0x14(%ebp)
  800188:	ff 75 e8             	pushl  -0x18(%ebp)
  80018b:	e8 27 02 00 00       	call   8003b7 <InitializeSemiRandom>
  800190:	83 c4 10             	add    $0x10,%esp
			break ;
  800193:	eb 11                	jmp    8001a6 <_main+0x16e>
		default:
			InitializeSemiRandom(Elements, NumOfElements);
  800195:	83 ec 08             	sub    $0x8,%esp
  800198:	ff 75 ec             	pushl  -0x14(%ebp)
  80019b:	ff 75 e8             	pushl  -0x18(%ebp)
  80019e:	e8 14 02 00 00       	call   8003b7 <InitializeSemiRandom>
  8001a3:	83 c4 10             	add    $0x10,%esp
		}

		MSort(Elements, 1, NumOfElements);
  8001a6:	83 ec 04             	sub    $0x4,%esp
  8001a9:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ac:	6a 01                	push   $0x1
  8001ae:	ff 75 e8             	pushl  -0x18(%ebp)
  8001b1:	e8 e0 02 00 00       	call   800496 <MSort>
  8001b6:	83 c4 10             	add    $0x10,%esp

		sys_lock_cons();
  8001b9:	e8 48 17 00 00       	call   801906 <sys_lock_cons>
		cprintf("Sorting is Finished!!!!it'll be checked now....\n") ;
  8001be:	83 ec 0c             	sub    $0xc,%esp
  8001c1:	68 ec 21 80 00       	push   $0x8021ec
  8001c6:	e8 34 09 00 00       	call   800aff <cprintf>
  8001cb:	83 c4 10             	add    $0x10,%esp
		//PrintElements(Elements, NumOfElements);
		sys_unlock_cons();
  8001ce:	e8 4d 17 00 00       	call   801920 <sys_unlock_cons>

		uint32 Sorted = CheckSorted(Elements, NumOfElements);
  8001d3:	83 ec 08             	sub    $0x8,%esp
  8001d6:	ff 75 ec             	pushl  -0x14(%ebp)
  8001d9:	ff 75 e8             	pushl  -0x18(%ebp)
  8001dc:	e8 c6 00 00 00       	call   8002a7 <CheckSorted>
  8001e1:	83 c4 10             	add    $0x10,%esp
  8001e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		if(Sorted == 0) panic("The array is NOT sorted correctly") ;
  8001e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8001eb:	75 14                	jne    800201 <_main+0x1c9>
  8001ed:	83 ec 04             	sub    $0x4,%esp
  8001f0:	68 20 22 80 00       	push   $0x802220
  8001f5:	6a 51                	push   $0x51
  8001f7:	68 42 22 80 00       	push   $0x802242
  8001fc:	e8 41 06 00 00       	call   800842 <_panic>
		else
		{
			sys_lock_cons();
  800201:	e8 00 17 00 00       	call   801906 <sys_lock_cons>
			cprintf("===============================================\n") ;
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	68 5c 22 80 00       	push   $0x80225c
  80020e:	e8 ec 08 00 00       	call   800aff <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
			cprintf("Congratulations!! The array is sorted correctly\n") ;
  800216:	83 ec 0c             	sub    $0xc,%esp
  800219:	68 90 22 80 00       	push   $0x802290
  80021e:	e8 dc 08 00 00       	call   800aff <cprintf>
  800223:	83 c4 10             	add    $0x10,%esp
			cprintf("===============================================\n\n") ;
  800226:	83 ec 0c             	sub    $0xc,%esp
  800229:	68 c4 22 80 00       	push   $0x8022c4
  80022e:	e8 cc 08 00 00       	call   800aff <cprintf>
  800233:	83 c4 10             	add    $0x10,%esp
			sys_unlock_cons();
  800236:	e8 e5 16 00 00       	call   801920 <sys_unlock_cons>
		}

		//free(Elements) ;

		sys_lock_cons();
  80023b:	e8 c6 16 00 00       	call   801906 <sys_lock_cons>
		Chose = 0 ;
  800240:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)
		while (Chose != 'y' && Chose != 'n')
  800244:	eb 3e                	jmp    800284 <_main+0x24c>
		{
			cprintf("Do you want to repeat (y/n): ") ;
  800246:	83 ec 0c             	sub    $0xc,%esp
  800249:	68 f6 22 80 00       	push   $0x8022f6
  80024e:	e8 ac 08 00 00       	call   800aff <cprintf>
  800253:	83 c4 10             	add    $0x10,%esp
			Chose = 'n' ;
  800256:	c6 45 f7 6e          	movb   $0x6e,-0x9(%ebp)
			cputchar(Chose);
  80025a:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  80025e:	83 ec 0c             	sub    $0xc,%esp
  800261:	50                   	push   %eax
  800262:	e8 68 04 00 00       	call   8006cf <cputchar>
  800267:	83 c4 10             	add    $0x10,%esp
			cputchar('\n');
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	6a 0a                	push   $0xa
  80026f:	e8 5b 04 00 00       	call   8006cf <cputchar>
  800274:	83 c4 10             	add    $0x10,%esp
			cputchar('\n');
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	6a 0a                	push   $0xa
  80027c:	e8 4e 04 00 00       	call   8006cf <cputchar>
  800281:	83 c4 10             	add    $0x10,%esp

		//free(Elements) ;

		sys_lock_cons();
		Chose = 0 ;
		while (Chose != 'y' && Chose != 'n')
  800284:	80 7d f7 79          	cmpb   $0x79,-0x9(%ebp)
  800288:	74 06                	je     800290 <_main+0x258>
  80028a:	80 7d f7 6e          	cmpb   $0x6e,-0x9(%ebp)
  80028e:	75 b6                	jne    800246 <_main+0x20e>
			Chose = 'n' ;
			cputchar(Chose);
			cputchar('\n');
			cputchar('\n');
		}
		sys_unlock_cons();
  800290:	e8 8b 16 00 00       	call   801920 <sys_unlock_cons>

	} while (Chose == 'y');
  800295:	80 7d f7 79          	cmpb   $0x79,-0x9(%ebp)
  800299:	0f 84 a9 fd ff ff    	je     800048 <_main+0x10>

	//To indicate that it's completed successfully
	inctst();
  80029f:	e8 1c 1a 00 00       	call   801cc0 <inctst>

}
  8002a4:	90                   	nop
  8002a5:	c9                   	leave  
  8002a6:	c3                   	ret    

008002a7 <CheckSorted>:


uint32 CheckSorted(int *Elements, int NumOfElements)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	83 ec 10             	sub    $0x10,%esp
	uint32 Sorted = 1 ;
  8002ad:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
	int i ;
	for (i = 0 ; i < NumOfElements - 1; i++)
  8002b4:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  8002bb:	eb 33                	jmp    8002f0 <CheckSorted+0x49>
	{
		if (Elements[i] > Elements[i+1])
  8002bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8002c0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8002c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ca:	01 d0                	add    %edx,%eax
  8002cc:	8b 10                	mov    (%eax),%edx
  8002ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8002d1:	40                   	inc    %eax
  8002d2:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8002d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002dc:	01 c8                	add    %ecx,%eax
  8002de:	8b 00                	mov    (%eax),%eax
  8002e0:	39 c2                	cmp    %eax,%edx
  8002e2:	7e 09                	jle    8002ed <CheckSorted+0x46>
		{
			Sorted = 0 ;
  8002e4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
			break;
  8002eb:	eb 0c                	jmp    8002f9 <CheckSorted+0x52>

uint32 CheckSorted(int *Elements, int NumOfElements)
{
	uint32 Sorted = 1 ;
	int i ;
	for (i = 0 ; i < NumOfElements - 1; i++)
  8002ed:	ff 45 f8             	incl   -0x8(%ebp)
  8002f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f3:	48                   	dec    %eax
  8002f4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  8002f7:	7f c4                	jg     8002bd <CheckSorted+0x16>
		{
			Sorted = 0 ;
			break;
		}
	}
	return Sorted ;
  8002f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8002fc:	c9                   	leave  
  8002fd:	c3                   	ret    

008002fe <Swap>:

///Private Functions


void Swap(int *Elements, int First, int Second)
{
  8002fe:	55                   	push   %ebp
  8002ff:	89 e5                	mov    %esp,%ebp
  800301:	83 ec 10             	sub    $0x10,%esp
	int Tmp = Elements[First] ;
  800304:	8b 45 0c             	mov    0xc(%ebp),%eax
  800307:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	01 d0                	add    %edx,%eax
  800313:	8b 00                	mov    (%eax),%eax
  800315:	89 45 fc             	mov    %eax,-0x4(%ebp)
	Elements[First] = Elements[Second] ;
  800318:	8b 45 0c             	mov    0xc(%ebp),%eax
  80031b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800322:	8b 45 08             	mov    0x8(%ebp),%eax
  800325:	01 c2                	add    %eax,%edx
  800327:	8b 45 10             	mov    0x10(%ebp),%eax
  80032a:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  800331:	8b 45 08             	mov    0x8(%ebp),%eax
  800334:	01 c8                	add    %ecx,%eax
  800336:	8b 00                	mov    (%eax),%eax
  800338:	89 02                	mov    %eax,(%edx)
	Elements[Second] = Tmp ;
  80033a:	8b 45 10             	mov    0x10(%ebp),%eax
  80033d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800344:	8b 45 08             	mov    0x8(%ebp),%eax
  800347:	01 c2                	add    %eax,%edx
  800349:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80034c:	89 02                	mov    %eax,(%edx)
}
  80034e:	90                   	nop
  80034f:	c9                   	leave  
  800350:	c3                   	ret    

00800351 <InitializeAscending>:

void InitializeAscending(int *Elements, int NumOfElements)
{
  800351:	55                   	push   %ebp
  800352:	89 e5                	mov    %esp,%ebp
  800354:	83 ec 10             	sub    $0x10,%esp
	int i ;
	for (i = 0 ; i < NumOfElements ; i++)
  800357:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80035e:	eb 17                	jmp    800377 <InitializeAscending+0x26>
	{
		(Elements)[i] = i ;
  800360:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800363:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80036a:	8b 45 08             	mov    0x8(%ebp),%eax
  80036d:	01 c2                	add    %eax,%edx
  80036f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800372:	89 02                	mov    %eax,(%edx)
}

void InitializeAscending(int *Elements, int NumOfElements)
{
	int i ;
	for (i = 0 ; i < NumOfElements ; i++)
  800374:	ff 45 fc             	incl   -0x4(%ebp)
  800377:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80037a:	3b 45 0c             	cmp    0xc(%ebp),%eax
  80037d:	7c e1                	jl     800360 <InitializeAscending+0xf>
	{
		(Elements)[i] = i ;
	}

}
  80037f:	90                   	nop
  800380:	c9                   	leave  
  800381:	c3                   	ret    

00800382 <InitializeIdentical>:

void InitializeIdentical(int *Elements, int NumOfElements)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	83 ec 10             	sub    $0x10,%esp
	int i ;
	for (i = 0 ; i < NumOfElements ; i++)
  800388:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80038f:	eb 1b                	jmp    8003ac <InitializeIdentical+0x2a>
	{
		Elements[i] = NumOfElements - i - 1 ;
  800391:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800394:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80039b:	8b 45 08             	mov    0x8(%ebp),%eax
  80039e:	01 c2                	add    %eax,%edx
  8003a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003a3:	2b 45 fc             	sub    -0x4(%ebp),%eax
  8003a6:	48                   	dec    %eax
  8003a7:	89 02                	mov    %eax,(%edx)
}

void InitializeIdentical(int *Elements, int NumOfElements)
{
	int i ;
	for (i = 0 ; i < NumOfElements ; i++)
  8003a9:	ff 45 fc             	incl   -0x4(%ebp)
  8003ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8003af:	3b 45 0c             	cmp    0xc(%ebp),%eax
  8003b2:	7c dd                	jl     800391 <InitializeIdentical+0xf>
	{
		Elements[i] = NumOfElements - i - 1 ;
	}

}
  8003b4:	90                   	nop
  8003b5:	c9                   	leave  
  8003b6:	c3                   	ret    

008003b7 <InitializeSemiRandom>:

void InitializeSemiRandom(int *Elements, int NumOfElements)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	83 ec 10             	sub    $0x10,%esp
	int i ;
	int Repetition = NumOfElements / 3 ;
  8003bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003c0:	b8 56 55 55 55       	mov    $0x55555556,%eax
  8003c5:	f7 e9                	imul   %ecx
  8003c7:	c1 f9 1f             	sar    $0x1f,%ecx
  8003ca:	89 d0                	mov    %edx,%eax
  8003cc:	29 c8                	sub    %ecx,%eax
  8003ce:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (Repetition == 0)
  8003d1:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
  8003d5:	75 07                	jne    8003de <InitializeSemiRandom+0x27>
			Repetition = 3;
  8003d7:	c7 45 f8 03 00 00 00 	movl   $0x3,-0x8(%ebp)
	for (i = 0 ; i < NumOfElements ; i++)
  8003de:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8003e5:	eb 1e                	jmp    800405 <InitializeSemiRandom+0x4e>
	{
		Elements[i] = i % Repetition ;
  8003e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8003ea:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8003f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f4:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
  8003f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8003fa:	99                   	cltd   
  8003fb:	f7 7d f8             	idivl  -0x8(%ebp)
  8003fe:	89 d0                	mov    %edx,%eax
  800400:	89 01                	mov    %eax,(%ecx)
{
	int i ;
	int Repetition = NumOfElements / 3 ;
	if (Repetition == 0)
			Repetition = 3;
	for (i = 0 ; i < NumOfElements ; i++)
  800402:	ff 45 fc             	incl   -0x4(%ebp)
  800405:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800408:	3b 45 0c             	cmp    0xc(%ebp),%eax
  80040b:	7c da                	jl     8003e7 <InitializeSemiRandom+0x30>
	{
		Elements[i] = i % Repetition ;
		//	cprintf("i=%d\n",i);
	}

}
  80040d:	90                   	nop
  80040e:	c9                   	leave  
  80040f:	c3                   	ret    

00800410 <PrintElements>:

void PrintElements(int *Elements, int NumOfElements)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	83 ec 18             	sub    $0x18,%esp
	int i ;
	int NumsPerLine = 20 ;
  800416:	c7 45 f0 14 00 00 00 	movl   $0x14,-0x10(%ebp)
	for (i = 0 ; i < NumOfElements-1 ; i++)
  80041d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  800424:	eb 42                	jmp    800468 <PrintElements+0x58>
	{
		if (i%NumsPerLine == 0)
  800426:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800429:	99                   	cltd   
  80042a:	f7 7d f0             	idivl  -0x10(%ebp)
  80042d:	89 d0                	mov    %edx,%eax
  80042f:	85 c0                	test   %eax,%eax
  800431:	75 10                	jne    800443 <PrintElements+0x33>
			cprintf("\n");
  800433:	83 ec 0c             	sub    $0xc,%esp
  800436:	68 40 21 80 00       	push   $0x802140
  80043b:	e8 bf 06 00 00       	call   800aff <cprintf>
  800440:	83 c4 10             	add    $0x10,%esp
		cprintf("%d, ",Elements[i]);
  800443:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800446:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80044d:	8b 45 08             	mov    0x8(%ebp),%eax
  800450:	01 d0                	add    %edx,%eax
  800452:	8b 00                	mov    (%eax),%eax
  800454:	83 ec 08             	sub    $0x8,%esp
  800457:	50                   	push   %eax
  800458:	68 14 23 80 00       	push   $0x802314
  80045d:	e8 9d 06 00 00       	call   800aff <cprintf>
  800462:	83 c4 10             	add    $0x10,%esp

void PrintElements(int *Elements, int NumOfElements)
{
	int i ;
	int NumsPerLine = 20 ;
	for (i = 0 ; i < NumOfElements-1 ; i++)
  800465:	ff 45 f4             	incl   -0xc(%ebp)
  800468:	8b 45 0c             	mov    0xc(%ebp),%eax
  80046b:	48                   	dec    %eax
  80046c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  80046f:	7f b5                	jg     800426 <PrintElements+0x16>
	{
		if (i%NumsPerLine == 0)
			cprintf("\n");
		cprintf("%d, ",Elements[i]);
	}
	cprintf("%d\n",Elements[i]);
  800471:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800474:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80047b:	8b 45 08             	mov    0x8(%ebp),%eax
  80047e:	01 d0                	add    %edx,%eax
  800480:	8b 00                	mov    (%eax),%eax
  800482:	83 ec 08             	sub    $0x8,%esp
  800485:	50                   	push   %eax
  800486:	68 19 23 80 00       	push   $0x802319
  80048b:	e8 6f 06 00 00       	call   800aff <cprintf>
  800490:	83 c4 10             	add    $0x10,%esp

}
  800493:	90                   	nop
  800494:	c9                   	leave  
  800495:	c3                   	ret    

00800496 <MSort>:


void MSort(int* A, int p, int r)
{
  800496:	55                   	push   %ebp
  800497:	89 e5                	mov    %esp,%ebp
  800499:	83 ec 18             	sub    $0x18,%esp
	if (p >= r)
  80049c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80049f:	3b 45 10             	cmp    0x10(%ebp),%eax
  8004a2:	7d 54                	jge    8004f8 <MSort+0x62>
	{
		return;
	}

	int q = (p + r) / 2;
  8004a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8004aa:	01 d0                	add    %edx,%eax
  8004ac:	89 c2                	mov    %eax,%edx
  8004ae:	c1 ea 1f             	shr    $0x1f,%edx
  8004b1:	01 d0                	add    %edx,%eax
  8004b3:	d1 f8                	sar    %eax
  8004b5:	89 45 f4             	mov    %eax,-0xc(%ebp)

	MSort(A, p, q);
  8004b8:	83 ec 04             	sub    $0x4,%esp
  8004bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8004be:	ff 75 0c             	pushl  0xc(%ebp)
  8004c1:	ff 75 08             	pushl  0x8(%ebp)
  8004c4:	e8 cd ff ff ff       	call   800496 <MSort>
  8004c9:	83 c4 10             	add    $0x10,%esp

	MSort(A, q + 1, r);
  8004cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004cf:	40                   	inc    %eax
  8004d0:	83 ec 04             	sub    $0x4,%esp
  8004d3:	ff 75 10             	pushl  0x10(%ebp)
  8004d6:	50                   	push   %eax
  8004d7:	ff 75 08             	pushl  0x8(%ebp)
  8004da:	e8 b7 ff ff ff       	call   800496 <MSort>
  8004df:	83 c4 10             	add    $0x10,%esp

	Merge(A, p, q, r);
  8004e2:	ff 75 10             	pushl  0x10(%ebp)
  8004e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8004e8:	ff 75 0c             	pushl  0xc(%ebp)
  8004eb:	ff 75 08             	pushl  0x8(%ebp)
  8004ee:	e8 08 00 00 00       	call   8004fb <Merge>
  8004f3:	83 c4 10             	add    $0x10,%esp
  8004f6:	eb 01                	jmp    8004f9 <MSort+0x63>

void MSort(int* A, int p, int r)
{
	if (p >= r)
	{
		return;
  8004f8:	90                   	nop

	MSort(A, q + 1, r);

	Merge(A, p, q, r);

}
  8004f9:	c9                   	leave  
  8004fa:	c3                   	ret    

008004fb <Merge>:

void Merge(int* A, int p, int q, int r)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	83 ec 30             	sub    $0x30,%esp
	int leftCapacity = q - p + 1;
  800501:	8b 45 10             	mov    0x10(%ebp),%eax
  800504:	2b 45 0c             	sub    0xc(%ebp),%eax
  800507:	40                   	inc    %eax
  800508:	89 45 e8             	mov    %eax,-0x18(%ebp)

	int rightCapacity = r - q;
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	2b 45 10             	sub    0x10(%ebp),%eax
  800511:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	int leftIndex = 0;
  800514:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)

	int rightIndex = 0;
  80051b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	//int* Left = malloc(sizeof(int) * leftCapacity);
	int* Left = __Left ;
  800522:	c7 45 e0 40 30 80 00 	movl   $0x803040,-0x20(%ebp)
	int* Right = __Right;
  800529:	c7 45 dc 60 d8 e1 00 	movl   $0xe1d860,-0x24(%ebp)

	//	int Left[5000] ;
	//	int Right[5000] ;

	int i, j, k;
	for (i = 0; i < leftCapacity; i++)
  800530:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  800537:	eb 2f                	jmp    800568 <Merge+0x6d>
	{
		Left[i] = A[p + i - 1];
  800539:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80053c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800543:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800546:	01 c2                	add    %eax,%edx
  800548:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80054b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80054e:	01 c8                	add    %ecx,%eax
  800550:	05 ff ff ff 3f       	add    $0x3fffffff,%eax
  800555:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80055c:	8b 45 08             	mov    0x8(%ebp),%eax
  80055f:	01 c8                	add    %ecx,%eax
  800561:	8b 00                	mov    (%eax),%eax
  800563:	89 02                	mov    %eax,(%edx)

	//	int Left[5000] ;
	//	int Right[5000] ;

	int i, j, k;
	for (i = 0; i < leftCapacity; i++)
  800565:	ff 45 f4             	incl   -0xc(%ebp)
  800568:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80056b:	3b 45 e8             	cmp    -0x18(%ebp),%eax
  80056e:	7c c9                	jl     800539 <Merge+0x3e>
	{
		Left[i] = A[p + i - 1];
	}
	for (j = 0; j < rightCapacity; j++)
  800570:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800577:	eb 2a                	jmp    8005a3 <Merge+0xa8>
	{
		Right[j] = A[q + j];
  800579:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80057c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800583:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800586:	01 c2                	add    %eax,%edx
  800588:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80058b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80058e:	01 c8                	add    %ecx,%eax
  800590:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  800597:	8b 45 08             	mov    0x8(%ebp),%eax
  80059a:	01 c8                	add    %ecx,%eax
  80059c:	8b 00                	mov    (%eax),%eax
  80059e:	89 02                	mov    %eax,(%edx)
	int i, j, k;
	for (i = 0; i < leftCapacity; i++)
	{
		Left[i] = A[p + i - 1];
	}
	for (j = 0; j < rightCapacity; j++)
  8005a0:	ff 45 f0             	incl   -0x10(%ebp)
  8005a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005a6:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  8005a9:	7c ce                	jl     800579 <Merge+0x7e>
	{
		Right[j] = A[q + j];
	}

	for ( k = p; k <= r; k++)
  8005ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8005b1:	e9 0a 01 00 00       	jmp    8006c0 <Merge+0x1c5>
	{
		if (leftIndex < leftCapacity && rightIndex < rightCapacity)
  8005b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8005b9:	3b 45 e8             	cmp    -0x18(%ebp),%eax
  8005bc:	0f 8d 95 00 00 00    	jge    800657 <Merge+0x15c>
  8005c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8005c5:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  8005c8:	0f 8d 89 00 00 00    	jge    800657 <Merge+0x15c>
		{
			if (Left[leftIndex] < Right[rightIndex] )
  8005ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8005d1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8005d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005db:	01 d0                	add    %edx,%eax
  8005dd:	8b 10                	mov    (%eax),%edx
  8005df:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8005e2:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8005e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005ec:	01 c8                	add    %ecx,%eax
  8005ee:	8b 00                	mov    (%eax),%eax
  8005f0:	39 c2                	cmp    %eax,%edx
  8005f2:	7d 33                	jge    800627 <Merge+0x12c>
			{
				A[k - 1] = Left[leftIndex++];
  8005f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8005f7:	05 ff ff ff 3f       	add    $0x3fffffff,%eax
  8005fc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800603:	8b 45 08             	mov    0x8(%ebp),%eax
  800606:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
  800609:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80060c:	8d 50 01             	lea    0x1(%eax),%edx
  80060f:	89 55 fc             	mov    %edx,-0x4(%ebp)
  800612:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800619:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80061c:	01 d0                	add    %edx,%eax
  80061e:	8b 00                	mov    (%eax),%eax
  800620:	89 01                	mov    %eax,(%ecx)

	for ( k = p; k <= r; k++)
	{
		if (leftIndex < leftCapacity && rightIndex < rightCapacity)
		{
			if (Left[leftIndex] < Right[rightIndex] )
  800622:	e9 96 00 00 00       	jmp    8006bd <Merge+0x1c2>
			{
				A[k - 1] = Left[leftIndex++];
			}
			else
			{
				A[k - 1] = Right[rightIndex++];
  800627:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80062a:	05 ff ff ff 3f       	add    $0x3fffffff,%eax
  80062f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800636:	8b 45 08             	mov    0x8(%ebp),%eax
  800639:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
  80063c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80063f:	8d 50 01             	lea    0x1(%eax),%edx
  800642:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800645:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80064c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80064f:	01 d0                	add    %edx,%eax
  800651:	8b 00                	mov    (%eax),%eax
  800653:	89 01                	mov    %eax,(%ecx)

	for ( k = p; k <= r; k++)
	{
		if (leftIndex < leftCapacity && rightIndex < rightCapacity)
		{
			if (Left[leftIndex] < Right[rightIndex] )
  800655:	eb 66                	jmp    8006bd <Merge+0x1c2>
			else
			{
				A[k - 1] = Right[rightIndex++];
			}
		}
		else if (leftIndex < leftCapacity)
  800657:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80065a:	3b 45 e8             	cmp    -0x18(%ebp),%eax
  80065d:	7d 30                	jge    80068f <Merge+0x194>
		{
			A[k - 1] = Left[leftIndex++];
  80065f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800662:	05 ff ff ff 3f       	add    $0x3fffffff,%eax
  800667:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80066e:	8b 45 08             	mov    0x8(%ebp),%eax
  800671:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
  800674:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800677:	8d 50 01             	lea    0x1(%eax),%edx
  80067a:	89 55 fc             	mov    %edx,-0x4(%ebp)
  80067d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800684:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800687:	01 d0                	add    %edx,%eax
  800689:	8b 00                	mov    (%eax),%eax
  80068b:	89 01                	mov    %eax,(%ecx)
  80068d:	eb 2e                	jmp    8006bd <Merge+0x1c2>
		}
		else
		{
			A[k - 1] = Right[rightIndex++];
  80068f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800692:	05 ff ff ff 3f       	add    $0x3fffffff,%eax
  800697:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80069e:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a1:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
  8006a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8006a7:	8d 50 01             	lea    0x1(%eax),%edx
  8006aa:	89 55 f8             	mov    %edx,-0x8(%ebp)
  8006ad:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8006b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006b7:	01 d0                	add    %edx,%eax
  8006b9:	8b 00                	mov    (%eax),%eax
  8006bb:	89 01                	mov    %eax,(%ecx)
	for (j = 0; j < rightCapacity; j++)
	{
		Right[j] = A[q + j];
	}

	for ( k = p; k <= r; k++)
  8006bd:	ff 45 ec             	incl   -0x14(%ebp)
  8006c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c3:	3b 45 14             	cmp    0x14(%ebp),%eax
  8006c6:	0f 8e ea fe ff ff    	jle    8005b6 <Merge+0xbb>
		{
			A[k - 1] = Right[rightIndex++];
		}
	}

}
  8006cc:	90                   	nop
  8006cd:	c9                   	leave  
  8006ce:	c3                   	ret    

008006cf <cputchar>:
#include <inc/lib.h>


void
cputchar(int ch)
{
  8006cf:	55                   	push   %ebp
  8006d0:	89 e5                	mov    %esp,%ebp
  8006d2:	83 ec 18             	sub    $0x18,%esp
	char c = ch;
  8006d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	//sys_cputs(&c, 1);

	sys_cputc(c);
  8006db:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  8006df:	83 ec 0c             	sub    $0xc,%esp
  8006e2:	50                   	push   %eax
  8006e3:	e8 69 13 00 00       	call   801a51 <sys_cputc>
  8006e8:	83 c4 10             	add    $0x10,%esp
}
  8006eb:	90                   	nop
  8006ec:	c9                   	leave  
  8006ed:	c3                   	ret    

008006ee <getchar>:


int
getchar(void)
{
  8006ee:	55                   	push   %ebp
  8006ef:	89 e5                	mov    %esp,%ebp
  8006f1:	83 ec 18             	sub    $0x18,%esp
	int c =sys_cgetc();
  8006f4:	e8 f4 11 00 00       	call   8018ed <sys_cgetc>
  8006f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
	return c;
  8006fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8006ff:	c9                   	leave  
  800700:	c3                   	ret    

00800701 <iscons>:

int iscons(int fdnum)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
  800704:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800709:	5d                   	pop    %ebp
  80070a:	c3                   	ret    

0080070b <libmain>:

volatile struct Env *myEnv = NULL;
volatile char *binaryname = "(PROGRAM NAME UNKNOWN)";
void
libmain(int argc, char **argv)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	83 ec 18             	sub    $0x18,%esp
	int envIndex = sys_getenvindex();
  800711:	e8 6c 14 00 00       	call   801b82 <sys_getenvindex>
  800716:	89 45 f4             	mov    %eax,-0xc(%ebp)

	myEnv = &(envs[envIndex]);
  800719:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80071c:	89 d0                	mov    %edx,%eax
  80071e:	c1 e0 02             	shl    $0x2,%eax
  800721:	01 d0                	add    %edx,%eax
  800723:	01 c0                	add    %eax,%eax
  800725:	01 d0                	add    %edx,%eax
  800727:	c1 e0 02             	shl    $0x2,%eax
  80072a:	01 d0                	add    %edx,%eax
  80072c:	01 c0                	add    %eax,%eax
  80072e:	01 d0                	add    %edx,%eax
  800730:	c1 e0 04             	shl    $0x4,%eax
  800733:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800738:	a3 20 30 80 00       	mov    %eax,0x803020

	//SET THE PROGRAM NAME
	if (myEnv->prog_name[0] != '\0')
  80073d:	a1 20 30 80 00       	mov    0x803020,%eax
  800742:	8a 40 20             	mov    0x20(%eax),%al
  800745:	84 c0                	test   %al,%al
  800747:	74 0d                	je     800756 <libmain+0x4b>
		binaryname = myEnv->prog_name;
  800749:	a1 20 30 80 00       	mov    0x803020,%eax
  80074e:	83 c0 20             	add    $0x20,%eax
  800751:	a3 00 30 80 00       	mov    %eax,0x803000

	// set env to point at our env structure in envs[].
	// env = envs;

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800756:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80075a:	7e 0a                	jle    800766 <libmain+0x5b>
		binaryname = argv[0];
  80075c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80075f:	8b 00                	mov    (%eax),%eax
  800761:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	_main(argc, argv);
  800766:	83 ec 08             	sub    $0x8,%esp
  800769:	ff 75 0c             	pushl  0xc(%ebp)
  80076c:	ff 75 08             	pushl  0x8(%ebp)
  80076f:	e8 c4 f8 ff ff       	call   800038 <_main>
  800774:	83 c4 10             	add    $0x10,%esp



	//	sys_lock_cons();
	sys_lock_cons();
  800777:	e8 8a 11 00 00       	call   801906 <sys_lock_cons>
	{
		cprintf("**************************************\n");
  80077c:	83 ec 0c             	sub    $0xc,%esp
  80077f:	68 38 23 80 00       	push   $0x802338
  800784:	e8 76 03 00 00       	call   800aff <cprintf>
  800789:	83 c4 10             	add    $0x10,%esp
		cprintf("Num of PAGE faults = %d, modif = %d\n", myEnv->pageFaultsCounter, myEnv->nModifiedPages);
  80078c:	a1 20 30 80 00       	mov    0x803020,%eax
  800791:	8b 90 94 05 00 00    	mov    0x594(%eax),%edx
  800797:	a1 20 30 80 00       	mov    0x803020,%eax
  80079c:	8b 80 84 05 00 00    	mov    0x584(%eax),%eax
  8007a2:	83 ec 04             	sub    $0x4,%esp
  8007a5:	52                   	push   %edx
  8007a6:	50                   	push   %eax
  8007a7:	68 60 23 80 00       	push   $0x802360
  8007ac:	e8 4e 03 00 00       	call   800aff <cprintf>
  8007b1:	83 c4 10             	add    $0x10,%esp
		cprintf("# PAGE IN (from disk) = %d, # PAGE OUT (on disk) = %d, # NEW PAGE ADDED (on disk) = %d\n", myEnv->nPageIn, myEnv->nPageOut,myEnv->nNewPageAdded);
  8007b4:	a1 20 30 80 00       	mov    0x803020,%eax
  8007b9:	8b 88 a8 05 00 00    	mov    0x5a8(%eax),%ecx
  8007bf:	a1 20 30 80 00       	mov    0x803020,%eax
  8007c4:	8b 90 a4 05 00 00    	mov    0x5a4(%eax),%edx
  8007ca:	a1 20 30 80 00       	mov    0x803020,%eax
  8007cf:	8b 80 a0 05 00 00    	mov    0x5a0(%eax),%eax
  8007d5:	51                   	push   %ecx
  8007d6:	52                   	push   %edx
  8007d7:	50                   	push   %eax
  8007d8:	68 88 23 80 00       	push   $0x802388
  8007dd:	e8 1d 03 00 00       	call   800aff <cprintf>
  8007e2:	83 c4 10             	add    $0x10,%esp
		//cprintf("Num of freeing scarce memory = %d, freeing full working set = %d\n", myEnv->freeingScarceMemCounter, myEnv->freeingFullWSCounter);
		cprintf("Num of clocks = %d\n", myEnv->nClocks);
  8007e5:	a1 20 30 80 00       	mov    0x803020,%eax
  8007ea:	8b 80 ac 05 00 00    	mov    0x5ac(%eax),%eax
  8007f0:	83 ec 08             	sub    $0x8,%esp
  8007f3:	50                   	push   %eax
  8007f4:	68 e0 23 80 00       	push   $0x8023e0
  8007f9:	e8 01 03 00 00       	call   800aff <cprintf>
  8007fe:	83 c4 10             	add    $0x10,%esp
		cprintf("**************************************\n");
  800801:	83 ec 0c             	sub    $0xc,%esp
  800804:	68 38 23 80 00       	push   $0x802338
  800809:	e8 f1 02 00 00       	call   800aff <cprintf>
  80080e:	83 c4 10             	add    $0x10,%esp
	}
	sys_unlock_cons();
  800811:	e8 0a 11 00 00       	call   801920 <sys_unlock_cons>
//	sys_unlock_cons();

	// exit gracefully
	exit();
  800816:	e8 19 00 00 00       	call   800834 <exit>
}
  80081b:	90                   	nop
  80081c:	c9                   	leave  
  80081d:	c3                   	ret    

0080081e <destroy>:

#include <inc/lib.h>

void
destroy(void)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	83 ec 08             	sub    $0x8,%esp
	sys_destroy_env(0);
  800824:	83 ec 0c             	sub    $0xc,%esp
  800827:	6a 00                	push   $0x0
  800829:	e8 20 13 00 00       	call   801b4e <sys_destroy_env>
  80082e:	83 c4 10             	add    $0x10,%esp
}
  800831:	90                   	nop
  800832:	c9                   	leave  
  800833:	c3                   	ret    

00800834 <exit>:

void
exit(void)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	83 ec 08             	sub    $0x8,%esp
	sys_exit_env();
  80083a:	e8 75 13 00 00       	call   801bb4 <sys_exit_env>
}
  80083f:	90                   	nop
  800840:	c9                   	leave  
  800841:	c3                   	ret    

00800842 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes FOS to enter the FOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	va_start(ap, fmt);
  800848:	8d 45 10             	lea    0x10(%ebp),%eax
  80084b:	83 c0 04             	add    $0x4,%eax
  80084e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// Print the panic message
	if (argv0)
  800851:	a1 64 ac 12 01       	mov    0x112ac64,%eax
  800856:	85 c0                	test   %eax,%eax
  800858:	74 16                	je     800870 <_panic+0x2e>
		cprintf("%s: ", argv0);
  80085a:	a1 64 ac 12 01       	mov    0x112ac64,%eax
  80085f:	83 ec 08             	sub    $0x8,%esp
  800862:	50                   	push   %eax
  800863:	68 f4 23 80 00       	push   $0x8023f4
  800868:	e8 92 02 00 00       	call   800aff <cprintf>
  80086d:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800870:	a1 00 30 80 00       	mov    0x803000,%eax
  800875:	ff 75 0c             	pushl  0xc(%ebp)
  800878:	ff 75 08             	pushl  0x8(%ebp)
  80087b:	50                   	push   %eax
  80087c:	68 f9 23 80 00       	push   $0x8023f9
  800881:	e8 79 02 00 00       	call   800aff <cprintf>
  800886:	83 c4 10             	add    $0x10,%esp
	vcprintf(fmt, ap);
  800889:	8b 45 10             	mov    0x10(%ebp),%eax
  80088c:	83 ec 08             	sub    $0x8,%esp
  80088f:	ff 75 f4             	pushl  -0xc(%ebp)
  800892:	50                   	push   %eax
  800893:	e8 fc 01 00 00       	call   800a94 <vcprintf>
  800898:	83 c4 10             	add    $0x10,%esp
	vcprintf("\n", NULL);
  80089b:	83 ec 08             	sub    $0x8,%esp
  80089e:	6a 00                	push   $0x0
  8008a0:	68 15 24 80 00       	push   $0x802415
  8008a5:	e8 ea 01 00 00       	call   800a94 <vcprintf>
  8008aa:	83 c4 10             	add    $0x10,%esp
	// Cause a breakpoint exception
//	while (1);
//		asm volatile("int3");

	//2013: exit the panic env only
	exit() ;
  8008ad:	e8 82 ff ff ff       	call   800834 <exit>

	// should not return here
	while (1) ;
  8008b2:	eb fe                	jmp    8008b2 <_panic+0x70>

008008b4 <CheckWSArrayWithoutLastIndex>:
}

void CheckWSArrayWithoutLastIndex(uint32 *expectedPages, int arraySize)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	83 ec 28             	sub    $0x28,%esp
	if (arraySize != myEnv->page_WS_max_size)
  8008ba:	a1 20 30 80 00       	mov    0x803020,%eax
  8008bf:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
  8008c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c8:	39 c2                	cmp    %eax,%edx
  8008ca:	74 14                	je     8008e0 <CheckWSArrayWithoutLastIndex+0x2c>
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
  8008cc:	83 ec 04             	sub    $0x4,%esp
  8008cf:	68 18 24 80 00       	push   $0x802418
  8008d4:	6a 26                	push   $0x26
  8008d6:	68 64 24 80 00       	push   $0x802464
  8008db:	e8 62 ff ff ff       	call   800842 <_panic>
	}
	int expectedNumOfEmptyLocs = 0;
  8008e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	for (int e = 0; e < arraySize; e++) {
  8008e7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8008ee:	e9 c5 00 00 00       	jmp    8009b8 <CheckWSArrayWithoutLastIndex+0x104>
		if (expectedPages[e] == 0) {
  8008f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008f6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	01 d0                	add    %edx,%eax
  800902:	8b 00                	mov    (%eax),%eax
  800904:	85 c0                	test   %eax,%eax
  800906:	75 08                	jne    800910 <CheckWSArrayWithoutLastIndex+0x5c>
			expectedNumOfEmptyLocs++;
  800908:	ff 45 f4             	incl   -0xc(%ebp)
			continue;
  80090b:	e9 a5 00 00 00       	jmp    8009b5 <CheckWSArrayWithoutLastIndex+0x101>
		}
		int found = 0;
  800910:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  800917:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  80091e:	eb 69                	jmp    800989 <CheckWSArrayWithoutLastIndex+0xd5>
			if (myEnv->__uptr_pws[w].empty == 0) {
  800920:	a1 20 30 80 00       	mov    0x803020,%eax
  800925:	8b 88 7c 05 00 00    	mov    0x57c(%eax),%ecx
  80092b:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80092e:	89 d0                	mov    %edx,%eax
  800930:	01 c0                	add    %eax,%eax
  800932:	01 d0                	add    %edx,%eax
  800934:	c1 e0 03             	shl    $0x3,%eax
  800937:	01 c8                	add    %ecx,%eax
  800939:	8a 40 04             	mov    0x4(%eax),%al
  80093c:	84 c0                	test   %al,%al
  80093e:	75 46                	jne    800986 <CheckWSArrayWithoutLastIndex+0xd2>
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  800940:	a1 20 30 80 00       	mov    0x803020,%eax
  800945:	8b 88 7c 05 00 00    	mov    0x57c(%eax),%ecx
  80094b:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80094e:	89 d0                	mov    %edx,%eax
  800950:	01 c0                	add    %eax,%eax
  800952:	01 d0                	add    %edx,%eax
  800954:	c1 e0 03             	shl    $0x3,%eax
  800957:	01 c8                	add    %ecx,%eax
  800959:	8b 00                	mov    (%eax),%eax
  80095b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80095e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800961:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800966:	89 c2                	mov    %eax,%edx
						== expectedPages[e]) {
  800968:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80096b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	01 c8                	add    %ecx,%eax
  800977:	8b 00                	mov    (%eax),%eax
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
			if (myEnv->__uptr_pws[w].empty == 0) {
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  800979:	39 c2                	cmp    %eax,%edx
  80097b:	75 09                	jne    800986 <CheckWSArrayWithoutLastIndex+0xd2>
						== expectedPages[e]) {
					found = 1;
  80097d:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
					break;
  800984:	eb 15                	jmp    80099b <CheckWSArrayWithoutLastIndex+0xe7>
		if (expectedPages[e] == 0) {
			expectedNumOfEmptyLocs++;
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  800986:	ff 45 e8             	incl   -0x18(%ebp)
  800989:	a1 20 30 80 00       	mov    0x803020,%eax
  80098e:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
  800994:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800997:	39 c2                	cmp    %eax,%edx
  800999:	77 85                	ja     800920 <CheckWSArrayWithoutLastIndex+0x6c>
					found = 1;
					break;
				}
			}
		}
		if (!found)
  80099b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80099f:	75 14                	jne    8009b5 <CheckWSArrayWithoutLastIndex+0x101>
			panic(
  8009a1:	83 ec 04             	sub    $0x4,%esp
  8009a4:	68 70 24 80 00       	push   $0x802470
  8009a9:	6a 3a                	push   $0x3a
  8009ab:	68 64 24 80 00       	push   $0x802464
  8009b0:	e8 8d fe ff ff       	call   800842 <_panic>
	if (arraySize != myEnv->page_WS_max_size)
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
	}
	int expectedNumOfEmptyLocs = 0;
	for (int e = 0; e < arraySize; e++) {
  8009b5:	ff 45 f0             	incl   -0x10(%ebp)
  8009b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009bb:	3b 45 0c             	cmp    0xc(%ebp),%eax
  8009be:	0f 8c 2f ff ff ff    	jl     8008f3 <CheckWSArrayWithoutLastIndex+0x3f>
		}
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
  8009c4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  8009cb:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8009d2:	eb 26                	jmp    8009fa <CheckWSArrayWithoutLastIndex+0x146>
		if (myEnv->__uptr_pws[w].empty == 1) {
  8009d4:	a1 20 30 80 00       	mov    0x803020,%eax
  8009d9:	8b 88 7c 05 00 00    	mov    0x57c(%eax),%ecx
  8009df:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8009e2:	89 d0                	mov    %edx,%eax
  8009e4:	01 c0                	add    %eax,%eax
  8009e6:	01 d0                	add    %edx,%eax
  8009e8:	c1 e0 03             	shl    $0x3,%eax
  8009eb:	01 c8                	add    %ecx,%eax
  8009ed:	8a 40 04             	mov    0x4(%eax),%al
  8009f0:	3c 01                	cmp    $0x1,%al
  8009f2:	75 03                	jne    8009f7 <CheckWSArrayWithoutLastIndex+0x143>
			actualNumOfEmptyLocs++;
  8009f4:	ff 45 e4             	incl   -0x1c(%ebp)
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  8009f7:	ff 45 e0             	incl   -0x20(%ebp)
  8009fa:	a1 20 30 80 00       	mov    0x803020,%eax
  8009ff:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
  800a05:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a08:	39 c2                	cmp    %eax,%edx
  800a0a:	77 c8                	ja     8009d4 <CheckWSArrayWithoutLastIndex+0x120>
		if (myEnv->__uptr_pws[w].empty == 1) {
			actualNumOfEmptyLocs++;
		}
	}
	if (expectedNumOfEmptyLocs != actualNumOfEmptyLocs)
  800a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a0f:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  800a12:	74 14                	je     800a28 <CheckWSArrayWithoutLastIndex+0x174>
		panic(
  800a14:	83 ec 04             	sub    $0x4,%esp
  800a17:	68 c4 24 80 00       	push   $0x8024c4
  800a1c:	6a 44                	push   $0x44
  800a1e:	68 64 24 80 00       	push   $0x802464
  800a23:	e8 1a fe ff ff       	call   800842 <_panic>
				"PAGE WS entry checking failed... number of empty locations is not correct");
}
  800a28:	90                   	nop
  800a29:	c9                   	leave  
  800a2a:	c3                   	ret    

00800a2b <putch>:
	int idx; // current buffer index
	int cnt; // total bytes printed so far
	char buf[256];
};

static void putch(int ch, struct printbuf *b) {
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	83 ec 08             	sub    $0x8,%esp
	b->buf[b->idx++] = ch;
  800a31:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a34:	8b 00                	mov    (%eax),%eax
  800a36:	8d 48 01             	lea    0x1(%eax),%ecx
  800a39:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3c:	89 0a                	mov    %ecx,(%edx)
  800a3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a41:	88 d1                	mov    %dl,%cl
  800a43:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a46:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256 - 1) {
  800a4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4d:	8b 00                	mov    (%eax),%eax
  800a4f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a54:	75 2c                	jne    800a82 <putch+0x57>
		sys_cputs(b->buf, b->idx, printProgName);
  800a56:	a0 40 04 b1 00       	mov    0xb10440,%al
  800a5b:	0f b6 c0             	movzbl %al,%eax
  800a5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a61:	8b 12                	mov    (%edx),%edx
  800a63:	89 d1                	mov    %edx,%ecx
  800a65:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a68:	83 c2 08             	add    $0x8,%edx
  800a6b:	83 ec 04             	sub    $0x4,%esp
  800a6e:	50                   	push   %eax
  800a6f:	51                   	push   %ecx
  800a70:	52                   	push   %edx
  800a71:	e8 4e 0e 00 00       	call   8018c4 <sys_cputs>
  800a76:	83 c4 10             	add    $0x10,%esp
		b->idx = 0;
  800a79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800a82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a85:	8b 40 04             	mov    0x4(%eax),%eax
  800a88:	8d 50 01             	lea    0x1(%eax),%edx
  800a8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8e:	89 50 04             	mov    %edx,0x4(%eax)
}
  800a91:	90                   	nop
  800a92:	c9                   	leave  
  800a93:	c3                   	ret    

00800a94 <vcprintf>:

int vcprintf(const char *fmt, va_list ap) {
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800a9d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800aa4:	00 00 00 
	b.cnt = 0;
  800aa7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800aae:	00 00 00 
	vprintfmt((void*) putch, &b, fmt, ap);
  800ab1:	ff 75 0c             	pushl  0xc(%ebp)
  800ab4:	ff 75 08             	pushl  0x8(%ebp)
  800ab7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800abd:	50                   	push   %eax
  800abe:	68 2b 0a 80 00       	push   $0x800a2b
  800ac3:	e8 11 02 00 00       	call   800cd9 <vprintfmt>
  800ac8:	83 c4 10             	add    $0x10,%esp
	sys_cputs(b.buf, b.idx, printProgName);
  800acb:	a0 40 04 b1 00       	mov    0xb10440,%al
  800ad0:	0f b6 c0             	movzbl %al,%eax
  800ad3:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
  800ad9:	83 ec 04             	sub    $0x4,%esp
  800adc:	50                   	push   %eax
  800add:	52                   	push   %edx
  800ade:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800ae4:	83 c0 08             	add    $0x8,%eax
  800ae7:	50                   	push   %eax
  800ae8:	e8 d7 0d 00 00       	call   8018c4 <sys_cputs>
  800aed:	83 c4 10             	add    $0x10,%esp

	printProgName = 0;
  800af0:	c6 05 40 04 b1 00 00 	movb   $0x0,0xb10440
	return b.cnt;
  800af7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800afd:	c9                   	leave  
  800afe:	c3                   	ret    

00800aff <cprintf>:

//%@: to print the program name and ID before the message
//%~: to print the message directly
int cprintf(const char *fmt, ...) {
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;
	printProgName = 1 ;
  800b05:	c6 05 40 04 b1 00 01 	movb   $0x1,0xb10440
	va_start(ap, fmt);
  800b0c:	8d 45 0c             	lea    0xc(%ebp),%eax
  800b0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
  800b12:	8b 45 08             	mov    0x8(%ebp),%eax
  800b15:	83 ec 08             	sub    $0x8,%esp
  800b18:	ff 75 f4             	pushl  -0xc(%ebp)
  800b1b:	50                   	push   %eax
  800b1c:	e8 73 ff ff ff       	call   800a94 <vcprintf>
  800b21:	83 c4 10             	add    $0x10,%esp
  800b24:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return cnt;
  800b27:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800b2a:	c9                   	leave  
  800b2b:	c3                   	ret    

00800b2c <atomic_cprintf>:

//%@: to print the program name and ID before the message
//%~: to print the message directly
int atomic_cprintf(const char *fmt, ...)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	83 ec 18             	sub    $0x18,%esp
	int cnt;
	sys_lock_cons();
  800b32:	e8 cf 0d 00 00       	call   801906 <sys_lock_cons>
	{
		va_list ap;
		va_start(ap, fmt);
  800b37:	8d 45 0c             	lea    0xc(%ebp),%eax
  800b3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
		cnt = vcprintf(fmt, ap);
  800b3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b40:	83 ec 08             	sub    $0x8,%esp
  800b43:	ff 75 f4             	pushl  -0xc(%ebp)
  800b46:	50                   	push   %eax
  800b47:	e8 48 ff ff ff       	call   800a94 <vcprintf>
  800b4c:	83 c4 10             	add    $0x10,%esp
  800b4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
		va_end(ap);
	}
	sys_unlock_cons();
  800b52:	e8 c9 0d 00 00       	call   801920 <sys_unlock_cons>
	return cnt;
  800b57:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800b5a:	c9                   	leave  
  800b5b:	c3                   	ret    

00800b5c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	53                   	push   %ebx
  800b60:	83 ec 14             	sub    $0x14,%esp
  800b63:	8b 45 10             	mov    0x10(%ebp),%eax
  800b66:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b69:	8b 45 14             	mov    0x14(%ebp),%eax
  800b6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b6f:	8b 45 18             	mov    0x18(%ebp),%eax
  800b72:	ba 00 00 00 00       	mov    $0x0,%edx
  800b77:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800b7a:	77 55                	ja     800bd1 <printnum+0x75>
  800b7c:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800b7f:	72 05                	jb     800b86 <printnum+0x2a>
  800b81:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800b84:	77 4b                	ja     800bd1 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b86:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800b89:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800b8c:	8b 45 18             	mov    0x18(%ebp),%eax
  800b8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b94:	52                   	push   %edx
  800b95:	50                   	push   %eax
  800b96:	ff 75 f4             	pushl  -0xc(%ebp)
  800b99:	ff 75 f0             	pushl  -0x10(%ebp)
  800b9c:	e8 27 13 00 00       	call   801ec8 <__udivdi3>
  800ba1:	83 c4 10             	add    $0x10,%esp
  800ba4:	83 ec 04             	sub    $0x4,%esp
  800ba7:	ff 75 20             	pushl  0x20(%ebp)
  800baa:	53                   	push   %ebx
  800bab:	ff 75 18             	pushl  0x18(%ebp)
  800bae:	52                   	push   %edx
  800baf:	50                   	push   %eax
  800bb0:	ff 75 0c             	pushl  0xc(%ebp)
  800bb3:	ff 75 08             	pushl  0x8(%ebp)
  800bb6:	e8 a1 ff ff ff       	call   800b5c <printnum>
  800bbb:	83 c4 20             	add    $0x20,%esp
  800bbe:	eb 1a                	jmp    800bda <printnum+0x7e>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800bc0:	83 ec 08             	sub    $0x8,%esp
  800bc3:	ff 75 0c             	pushl  0xc(%ebp)
  800bc6:	ff 75 20             	pushl  0x20(%ebp)
  800bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcc:	ff d0                	call   *%eax
  800bce:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800bd1:	ff 4d 1c             	decl   0x1c(%ebp)
  800bd4:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800bd8:	7f e6                	jg     800bc0 <printnum+0x64>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800bda:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800bdd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800be5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800be8:	53                   	push   %ebx
  800be9:	51                   	push   %ecx
  800bea:	52                   	push   %edx
  800beb:	50                   	push   %eax
  800bec:	e8 e7 13 00 00       	call   801fd8 <__umoddi3>
  800bf1:	83 c4 10             	add    $0x10,%esp
  800bf4:	05 34 27 80 00       	add    $0x802734,%eax
  800bf9:	8a 00                	mov    (%eax),%al
  800bfb:	0f be c0             	movsbl %al,%eax
  800bfe:	83 ec 08             	sub    $0x8,%esp
  800c01:	ff 75 0c             	pushl  0xc(%ebp)
  800c04:	50                   	push   %eax
  800c05:	8b 45 08             	mov    0x8(%ebp),%eax
  800c08:	ff d0                	call   *%eax
  800c0a:	83 c4 10             	add    $0x10,%esp
}
  800c0d:	90                   	nop
  800c0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c11:	c9                   	leave  
  800c12:	c3                   	ret    

00800c13 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800c16:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800c1a:	7e 1c                	jle    800c38 <getuint+0x25>
		return va_arg(*ap, unsigned long long);
  800c1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1f:	8b 00                	mov    (%eax),%eax
  800c21:	8d 50 08             	lea    0x8(%eax),%edx
  800c24:	8b 45 08             	mov    0x8(%ebp),%eax
  800c27:	89 10                	mov    %edx,(%eax)
  800c29:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2c:	8b 00                	mov    (%eax),%eax
  800c2e:	83 e8 08             	sub    $0x8,%eax
  800c31:	8b 50 04             	mov    0x4(%eax),%edx
  800c34:	8b 00                	mov    (%eax),%eax
  800c36:	eb 40                	jmp    800c78 <getuint+0x65>
	else if (lflag)
  800c38:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c3c:	74 1e                	je     800c5c <getuint+0x49>
		return va_arg(*ap, unsigned long);
  800c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c41:	8b 00                	mov    (%eax),%eax
  800c43:	8d 50 04             	lea    0x4(%eax),%edx
  800c46:	8b 45 08             	mov    0x8(%ebp),%eax
  800c49:	89 10                	mov    %edx,(%eax)
  800c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4e:	8b 00                	mov    (%eax),%eax
  800c50:	83 e8 04             	sub    $0x4,%eax
  800c53:	8b 00                	mov    (%eax),%eax
  800c55:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5a:	eb 1c                	jmp    800c78 <getuint+0x65>
	else
		return va_arg(*ap, unsigned int);
  800c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5f:	8b 00                	mov    (%eax),%eax
  800c61:	8d 50 04             	lea    0x4(%eax),%edx
  800c64:	8b 45 08             	mov    0x8(%ebp),%eax
  800c67:	89 10                	mov    %edx,(%eax)
  800c69:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6c:	8b 00                	mov    (%eax),%eax
  800c6e:	83 e8 04             	sub    $0x4,%eax
  800c71:	8b 00                	mov    (%eax),%eax
  800c73:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800c7d:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800c81:	7e 1c                	jle    800c9f <getint+0x25>
		return va_arg(*ap, long long);
  800c83:	8b 45 08             	mov    0x8(%ebp),%eax
  800c86:	8b 00                	mov    (%eax),%eax
  800c88:	8d 50 08             	lea    0x8(%eax),%edx
  800c8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8e:	89 10                	mov    %edx,(%eax)
  800c90:	8b 45 08             	mov    0x8(%ebp),%eax
  800c93:	8b 00                	mov    (%eax),%eax
  800c95:	83 e8 08             	sub    $0x8,%eax
  800c98:	8b 50 04             	mov    0x4(%eax),%edx
  800c9b:	8b 00                	mov    (%eax),%eax
  800c9d:	eb 38                	jmp    800cd7 <getint+0x5d>
	else if (lflag)
  800c9f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ca3:	74 1a                	je     800cbf <getint+0x45>
		return va_arg(*ap, long);
  800ca5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca8:	8b 00                	mov    (%eax),%eax
  800caa:	8d 50 04             	lea    0x4(%eax),%edx
  800cad:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb0:	89 10                	mov    %edx,(%eax)
  800cb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb5:	8b 00                	mov    (%eax),%eax
  800cb7:	83 e8 04             	sub    $0x4,%eax
  800cba:	8b 00                	mov    (%eax),%eax
  800cbc:	99                   	cltd   
  800cbd:	eb 18                	jmp    800cd7 <getint+0x5d>
	else
		return va_arg(*ap, int);
  800cbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc2:	8b 00                	mov    (%eax),%eax
  800cc4:	8d 50 04             	lea    0x4(%eax),%edx
  800cc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cca:	89 10                	mov    %edx,(%eax)
  800ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccf:	8b 00                	mov    (%eax),%eax
  800cd1:	83 e8 04             	sub    $0x4,%eax
  800cd4:	8b 00                	mov    (%eax),%eax
  800cd6:	99                   	cltd   
}
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
  800cde:	83 ec 20             	sub    $0x20,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800ce1:	eb 17                	jmp    800cfa <vprintfmt+0x21>
			if (ch == '\0')
  800ce3:	85 db                	test   %ebx,%ebx
  800ce5:	0f 84 c1 03 00 00    	je     8010ac <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  800ceb:	83 ec 08             	sub    $0x8,%esp
  800cee:	ff 75 0c             	pushl  0xc(%ebp)
  800cf1:	53                   	push   %ebx
  800cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf5:	ff d0                	call   *%eax
  800cf7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800cfa:	8b 45 10             	mov    0x10(%ebp),%eax
  800cfd:	8d 50 01             	lea    0x1(%eax),%edx
  800d00:	89 55 10             	mov    %edx,0x10(%ebp)
  800d03:	8a 00                	mov    (%eax),%al
  800d05:	0f b6 d8             	movzbl %al,%ebx
  800d08:	83 fb 25             	cmp    $0x25,%ebx
  800d0b:	75 d6                	jne    800ce3 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800d0d:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800d11:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800d18:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800d1f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800d26:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d2d:	8b 45 10             	mov    0x10(%ebp),%eax
  800d30:	8d 50 01             	lea    0x1(%eax),%edx
  800d33:	89 55 10             	mov    %edx,0x10(%ebp)
  800d36:	8a 00                	mov    (%eax),%al
  800d38:	0f b6 d8             	movzbl %al,%ebx
  800d3b:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800d3e:	83 f8 5b             	cmp    $0x5b,%eax
  800d41:	0f 87 3d 03 00 00    	ja     801084 <vprintfmt+0x3ab>
  800d47:	8b 04 85 58 27 80 00 	mov    0x802758(,%eax,4),%eax
  800d4e:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800d50:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800d54:	eb d7                	jmp    800d2d <vprintfmt+0x54>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800d56:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800d5a:	eb d1                	jmp    800d2d <vprintfmt+0x54>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800d5c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800d63:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800d66:	89 d0                	mov    %edx,%eax
  800d68:	c1 e0 02             	shl    $0x2,%eax
  800d6b:	01 d0                	add    %edx,%eax
  800d6d:	01 c0                	add    %eax,%eax
  800d6f:	01 d8                	add    %ebx,%eax
  800d71:	83 e8 30             	sub    $0x30,%eax
  800d74:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800d77:	8b 45 10             	mov    0x10(%ebp),%eax
  800d7a:	8a 00                	mov    (%eax),%al
  800d7c:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800d7f:	83 fb 2f             	cmp    $0x2f,%ebx
  800d82:	7e 3e                	jle    800dc2 <vprintfmt+0xe9>
  800d84:	83 fb 39             	cmp    $0x39,%ebx
  800d87:	7f 39                	jg     800dc2 <vprintfmt+0xe9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800d89:	ff 45 10             	incl   0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800d8c:	eb d5                	jmp    800d63 <vprintfmt+0x8a>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800d8e:	8b 45 14             	mov    0x14(%ebp),%eax
  800d91:	83 c0 04             	add    $0x4,%eax
  800d94:	89 45 14             	mov    %eax,0x14(%ebp)
  800d97:	8b 45 14             	mov    0x14(%ebp),%eax
  800d9a:	83 e8 04             	sub    $0x4,%eax
  800d9d:	8b 00                	mov    (%eax),%eax
  800d9f:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800da2:	eb 1f                	jmp    800dc3 <vprintfmt+0xea>

		case '.':
			if (width < 0)
  800da4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800da8:	79 83                	jns    800d2d <vprintfmt+0x54>
				width = 0;
  800daa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800db1:	e9 77 ff ff ff       	jmp    800d2d <vprintfmt+0x54>

		case '#':
			altflag = 1;
  800db6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800dbd:	e9 6b ff ff ff       	jmp    800d2d <vprintfmt+0x54>
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto process_precision;
  800dc2:	90                   	nop
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800dc3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800dc7:	0f 89 60 ff ff ff    	jns    800d2d <vprintfmt+0x54>
				width = precision, precision = -1;
  800dcd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800dd0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800dd3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800dda:	e9 4e ff ff ff       	jmp    800d2d <vprintfmt+0x54>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800ddf:	ff 45 e8             	incl   -0x18(%ebp)
			goto reswitch;
  800de2:	e9 46 ff ff ff       	jmp    800d2d <vprintfmt+0x54>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800de7:	8b 45 14             	mov    0x14(%ebp),%eax
  800dea:	83 c0 04             	add    $0x4,%eax
  800ded:	89 45 14             	mov    %eax,0x14(%ebp)
  800df0:	8b 45 14             	mov    0x14(%ebp),%eax
  800df3:	83 e8 04             	sub    $0x4,%eax
  800df6:	8b 00                	mov    (%eax),%eax
  800df8:	83 ec 08             	sub    $0x8,%esp
  800dfb:	ff 75 0c             	pushl  0xc(%ebp)
  800dfe:	50                   	push   %eax
  800dff:	8b 45 08             	mov    0x8(%ebp),%eax
  800e02:	ff d0                	call   *%eax
  800e04:	83 c4 10             	add    $0x10,%esp
			break;
  800e07:	e9 9b 02 00 00       	jmp    8010a7 <vprintfmt+0x3ce>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800e0c:	8b 45 14             	mov    0x14(%ebp),%eax
  800e0f:	83 c0 04             	add    $0x4,%eax
  800e12:	89 45 14             	mov    %eax,0x14(%ebp)
  800e15:	8b 45 14             	mov    0x14(%ebp),%eax
  800e18:	83 e8 04             	sub    $0x4,%eax
  800e1b:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800e1d:	85 db                	test   %ebx,%ebx
  800e1f:	79 02                	jns    800e23 <vprintfmt+0x14a>
				err = -err;
  800e21:	f7 db                	neg    %ebx
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800e23:	83 fb 64             	cmp    $0x64,%ebx
  800e26:	7f 0b                	jg     800e33 <vprintfmt+0x15a>
  800e28:	8b 34 9d a0 25 80 00 	mov    0x8025a0(,%ebx,4),%esi
  800e2f:	85 f6                	test   %esi,%esi
  800e31:	75 19                	jne    800e4c <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  800e33:	53                   	push   %ebx
  800e34:	68 45 27 80 00       	push   $0x802745
  800e39:	ff 75 0c             	pushl  0xc(%ebp)
  800e3c:	ff 75 08             	pushl  0x8(%ebp)
  800e3f:	e8 70 02 00 00       	call   8010b4 <printfmt>
  800e44:	83 c4 10             	add    $0x10,%esp
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800e47:	e9 5b 02 00 00       	jmp    8010a7 <vprintfmt+0x3ce>
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800e4c:	56                   	push   %esi
  800e4d:	68 4e 27 80 00       	push   $0x80274e
  800e52:	ff 75 0c             	pushl  0xc(%ebp)
  800e55:	ff 75 08             	pushl  0x8(%ebp)
  800e58:	e8 57 02 00 00       	call   8010b4 <printfmt>
  800e5d:	83 c4 10             	add    $0x10,%esp
			break;
  800e60:	e9 42 02 00 00       	jmp    8010a7 <vprintfmt+0x3ce>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800e65:	8b 45 14             	mov    0x14(%ebp),%eax
  800e68:	83 c0 04             	add    $0x4,%eax
  800e6b:	89 45 14             	mov    %eax,0x14(%ebp)
  800e6e:	8b 45 14             	mov    0x14(%ebp),%eax
  800e71:	83 e8 04             	sub    $0x4,%eax
  800e74:	8b 30                	mov    (%eax),%esi
  800e76:	85 f6                	test   %esi,%esi
  800e78:	75 05                	jne    800e7f <vprintfmt+0x1a6>
				p = "(null)";
  800e7a:	be 51 27 80 00       	mov    $0x802751,%esi
			if (width > 0 && padc != '-')
  800e7f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e83:	7e 6d                	jle    800ef2 <vprintfmt+0x219>
  800e85:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800e89:	74 67                	je     800ef2 <vprintfmt+0x219>
				for (width -= strnlen(p, precision); width > 0; width--)
  800e8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e8e:	83 ec 08             	sub    $0x8,%esp
  800e91:	50                   	push   %eax
  800e92:	56                   	push   %esi
  800e93:	e8 1e 03 00 00       	call   8011b6 <strnlen>
  800e98:	83 c4 10             	add    $0x10,%esp
  800e9b:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800e9e:	eb 16                	jmp    800eb6 <vprintfmt+0x1dd>
					putch(padc, putdat);
  800ea0:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800ea4:	83 ec 08             	sub    $0x8,%esp
  800ea7:	ff 75 0c             	pushl  0xc(%ebp)
  800eaa:	50                   	push   %eax
  800eab:	8b 45 08             	mov    0x8(%ebp),%eax
  800eae:	ff d0                	call   *%eax
  800eb0:	83 c4 10             	add    $0x10,%esp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800eb3:	ff 4d e4             	decl   -0x1c(%ebp)
  800eb6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800eba:	7f e4                	jg     800ea0 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ebc:	eb 34                	jmp    800ef2 <vprintfmt+0x219>
				if (altflag && (ch < ' ' || ch > '~'))
  800ebe:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ec2:	74 1c                	je     800ee0 <vprintfmt+0x207>
  800ec4:	83 fb 1f             	cmp    $0x1f,%ebx
  800ec7:	7e 05                	jle    800ece <vprintfmt+0x1f5>
  800ec9:	83 fb 7e             	cmp    $0x7e,%ebx
  800ecc:	7e 12                	jle    800ee0 <vprintfmt+0x207>
					putch('?', putdat);
  800ece:	83 ec 08             	sub    $0x8,%esp
  800ed1:	ff 75 0c             	pushl  0xc(%ebp)
  800ed4:	6a 3f                	push   $0x3f
  800ed6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed9:	ff d0                	call   *%eax
  800edb:	83 c4 10             	add    $0x10,%esp
  800ede:	eb 0f                	jmp    800eef <vprintfmt+0x216>
				else
					putch(ch, putdat);
  800ee0:	83 ec 08             	sub    $0x8,%esp
  800ee3:	ff 75 0c             	pushl  0xc(%ebp)
  800ee6:	53                   	push   %ebx
  800ee7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eea:	ff d0                	call   *%eax
  800eec:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800eef:	ff 4d e4             	decl   -0x1c(%ebp)
  800ef2:	89 f0                	mov    %esi,%eax
  800ef4:	8d 70 01             	lea    0x1(%eax),%esi
  800ef7:	8a 00                	mov    (%eax),%al
  800ef9:	0f be d8             	movsbl %al,%ebx
  800efc:	85 db                	test   %ebx,%ebx
  800efe:	74 24                	je     800f24 <vprintfmt+0x24b>
  800f00:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f04:	78 b8                	js     800ebe <vprintfmt+0x1e5>
  800f06:	ff 4d e0             	decl   -0x20(%ebp)
  800f09:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f0d:	79 af                	jns    800ebe <vprintfmt+0x1e5>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800f0f:	eb 13                	jmp    800f24 <vprintfmt+0x24b>
				putch(' ', putdat);
  800f11:	83 ec 08             	sub    $0x8,%esp
  800f14:	ff 75 0c             	pushl  0xc(%ebp)
  800f17:	6a 20                	push   $0x20
  800f19:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1c:	ff d0                	call   *%eax
  800f1e:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800f21:	ff 4d e4             	decl   -0x1c(%ebp)
  800f24:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f28:	7f e7                	jg     800f11 <vprintfmt+0x238>
				putch(' ', putdat);
			break;
  800f2a:	e9 78 01 00 00       	jmp    8010a7 <vprintfmt+0x3ce>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800f2f:	83 ec 08             	sub    $0x8,%esp
  800f32:	ff 75 e8             	pushl  -0x18(%ebp)
  800f35:	8d 45 14             	lea    0x14(%ebp),%eax
  800f38:	50                   	push   %eax
  800f39:	e8 3c fd ff ff       	call   800c7a <getint>
  800f3e:	83 c4 10             	add    $0x10,%esp
  800f41:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800f44:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800f47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f4d:	85 d2                	test   %edx,%edx
  800f4f:	79 23                	jns    800f74 <vprintfmt+0x29b>
				putch('-', putdat);
  800f51:	83 ec 08             	sub    $0x8,%esp
  800f54:	ff 75 0c             	pushl  0xc(%ebp)
  800f57:	6a 2d                	push   $0x2d
  800f59:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5c:	ff d0                	call   *%eax
  800f5e:	83 c4 10             	add    $0x10,%esp
				num = -(long long) num;
  800f61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f64:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f67:	f7 d8                	neg    %eax
  800f69:	83 d2 00             	adc    $0x0,%edx
  800f6c:	f7 da                	neg    %edx
  800f6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800f71:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800f74:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800f7b:	e9 bc 00 00 00       	jmp    80103c <vprintfmt+0x363>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f80:	83 ec 08             	sub    $0x8,%esp
  800f83:	ff 75 e8             	pushl  -0x18(%ebp)
  800f86:	8d 45 14             	lea    0x14(%ebp),%eax
  800f89:	50                   	push   %eax
  800f8a:	e8 84 fc ff ff       	call   800c13 <getuint>
  800f8f:	83 c4 10             	add    $0x10,%esp
  800f92:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800f95:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800f98:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800f9f:	e9 98 00 00 00       	jmp    80103c <vprintfmt+0x363>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800fa4:	83 ec 08             	sub    $0x8,%esp
  800fa7:	ff 75 0c             	pushl  0xc(%ebp)
  800faa:	6a 58                	push   $0x58
  800fac:	8b 45 08             	mov    0x8(%ebp),%eax
  800faf:	ff d0                	call   *%eax
  800fb1:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800fb4:	83 ec 08             	sub    $0x8,%esp
  800fb7:	ff 75 0c             	pushl  0xc(%ebp)
  800fba:	6a 58                	push   $0x58
  800fbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbf:	ff d0                	call   *%eax
  800fc1:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800fc4:	83 ec 08             	sub    $0x8,%esp
  800fc7:	ff 75 0c             	pushl  0xc(%ebp)
  800fca:	6a 58                	push   $0x58
  800fcc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fcf:	ff d0                	call   *%eax
  800fd1:	83 c4 10             	add    $0x10,%esp
			break;
  800fd4:	e9 ce 00 00 00       	jmp    8010a7 <vprintfmt+0x3ce>

		// pointer
		case 'p':
			putch('0', putdat);
  800fd9:	83 ec 08             	sub    $0x8,%esp
  800fdc:	ff 75 0c             	pushl  0xc(%ebp)
  800fdf:	6a 30                	push   $0x30
  800fe1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe4:	ff d0                	call   *%eax
  800fe6:	83 c4 10             	add    $0x10,%esp
			putch('x', putdat);
  800fe9:	83 ec 08             	sub    $0x8,%esp
  800fec:	ff 75 0c             	pushl  0xc(%ebp)
  800fef:	6a 78                	push   $0x78
  800ff1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff4:	ff d0                	call   *%eax
  800ff6:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)
				(uint32) va_arg(ap, void *);
  800ff9:	8b 45 14             	mov    0x14(%ebp),%eax
  800ffc:	83 c0 04             	add    $0x4,%eax
  800fff:	89 45 14             	mov    %eax,0x14(%ebp)
  801002:	8b 45 14             	mov    0x14(%ebp),%eax
  801005:	83 e8 04             	sub    $0x4,%eax
  801008:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80100a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80100d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uint32) va_arg(ap, void *);
			base = 16;
  801014:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  80101b:	eb 1f                	jmp    80103c <vprintfmt+0x363>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80101d:	83 ec 08             	sub    $0x8,%esp
  801020:	ff 75 e8             	pushl  -0x18(%ebp)
  801023:	8d 45 14             	lea    0x14(%ebp),%eax
  801026:	50                   	push   %eax
  801027:	e8 e7 fb ff ff       	call   800c13 <getuint>
  80102c:	83 c4 10             	add    $0x10,%esp
  80102f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801032:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  801035:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  80103c:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  801040:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801043:	83 ec 04             	sub    $0x4,%esp
  801046:	52                   	push   %edx
  801047:	ff 75 e4             	pushl  -0x1c(%ebp)
  80104a:	50                   	push   %eax
  80104b:	ff 75 f4             	pushl  -0xc(%ebp)
  80104e:	ff 75 f0             	pushl  -0x10(%ebp)
  801051:	ff 75 0c             	pushl  0xc(%ebp)
  801054:	ff 75 08             	pushl  0x8(%ebp)
  801057:	e8 00 fb ff ff       	call   800b5c <printnum>
  80105c:	83 c4 20             	add    $0x20,%esp
			break;
  80105f:	eb 46                	jmp    8010a7 <vprintfmt+0x3ce>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801061:	83 ec 08             	sub    $0x8,%esp
  801064:	ff 75 0c             	pushl  0xc(%ebp)
  801067:	53                   	push   %ebx
  801068:	8b 45 08             	mov    0x8(%ebp),%eax
  80106b:	ff d0                	call   *%eax
  80106d:	83 c4 10             	add    $0x10,%esp
			break;
  801070:	eb 35                	jmp    8010a7 <vprintfmt+0x3ce>

		/**********************************/
		/*2023*/
		// DON'T Print Program Name & UD
		case '~':
			printProgName = 0;
  801072:	c6 05 40 04 b1 00 00 	movb   $0x0,0xb10440
			break;
  801079:	eb 2c                	jmp    8010a7 <vprintfmt+0x3ce>
		// Print Program Name & UD
		case '@':
			printProgName = 1;
  80107b:	c6 05 40 04 b1 00 01 	movb   $0x1,0xb10440
			break;
  801082:	eb 23                	jmp    8010a7 <vprintfmt+0x3ce>
		/**********************************/

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801084:	83 ec 08             	sub    $0x8,%esp
  801087:	ff 75 0c             	pushl  0xc(%ebp)
  80108a:	6a 25                	push   $0x25
  80108c:	8b 45 08             	mov    0x8(%ebp),%eax
  80108f:	ff d0                	call   *%eax
  801091:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  801094:	ff 4d 10             	decl   0x10(%ebp)
  801097:	eb 03                	jmp    80109c <vprintfmt+0x3c3>
  801099:	ff 4d 10             	decl   0x10(%ebp)
  80109c:	8b 45 10             	mov    0x10(%ebp),%eax
  80109f:	48                   	dec    %eax
  8010a0:	8a 00                	mov    (%eax),%al
  8010a2:	3c 25                	cmp    $0x25,%al
  8010a4:	75 f3                	jne    801099 <vprintfmt+0x3c0>
				/* do nothing */;
			break;
  8010a6:	90                   	nop
		}
	}
  8010a7:	e9 35 fc ff ff       	jmp    800ce1 <vprintfmt+0x8>
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
  8010ac:	90                   	nop
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8010ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b0:	5b                   	pop    %ebx
  8010b1:	5e                   	pop    %esi
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8010ba:	8d 45 10             	lea    0x10(%ebp),%eax
  8010bd:	83 c0 04             	add    $0x4,%eax
  8010c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8010c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8010c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8010c9:	50                   	push   %eax
  8010ca:	ff 75 0c             	pushl  0xc(%ebp)
  8010cd:	ff 75 08             	pushl  0x8(%ebp)
  8010d0:	e8 04 fc ff ff       	call   800cd9 <vprintfmt>
  8010d5:	83 c4 10             	add    $0x10,%esp
	va_end(ap);
}
  8010d8:	90                   	nop
  8010d9:	c9                   	leave  
  8010da:	c3                   	ret    

008010db <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  8010de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010e1:	8b 40 08             	mov    0x8(%eax),%eax
  8010e4:	8d 50 01             	lea    0x1(%eax),%edx
  8010e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010ea:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  8010ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010f0:	8b 10                	mov    (%eax),%edx
  8010f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010f5:	8b 40 04             	mov    0x4(%eax),%eax
  8010f8:	39 c2                	cmp    %eax,%edx
  8010fa:	73 12                	jae    80110e <sprintputch+0x33>
		*b->buf++ = ch;
  8010fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010ff:	8b 00                	mov    (%eax),%eax
  801101:	8d 48 01             	lea    0x1(%eax),%ecx
  801104:	8b 55 0c             	mov    0xc(%ebp),%edx
  801107:	89 0a                	mov    %ecx,(%edx)
  801109:	8b 55 08             	mov    0x8(%ebp),%edx
  80110c:	88 10                	mov    %dl,(%eax)
}
  80110e:	90                   	nop
  80110f:	5d                   	pop    %ebp
  801110:	c3                   	ret    

00801111 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
  801114:	83 ec 18             	sub    $0x18,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  801117:	8b 45 08             	mov    0x8(%ebp),%eax
  80111a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80111d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801120:	8d 50 ff             	lea    -0x1(%eax),%edx
  801123:	8b 45 08             	mov    0x8(%ebp),%eax
  801126:	01 d0                	add    %edx,%eax
  801128:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80112b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801132:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801136:	74 06                	je     80113e <vsnprintf+0x2d>
  801138:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80113c:	7f 07                	jg     801145 <vsnprintf+0x34>
		return -E_INVAL;
  80113e:	b8 03 00 00 00       	mov    $0x3,%eax
  801143:	eb 20                	jmp    801165 <vsnprintf+0x54>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801145:	ff 75 14             	pushl  0x14(%ebp)
  801148:	ff 75 10             	pushl  0x10(%ebp)
  80114b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80114e:	50                   	push   %eax
  80114f:	68 db 10 80 00       	push   $0x8010db
  801154:	e8 80 fb ff ff       	call   800cd9 <vprintfmt>
  801159:	83 c4 10             	add    $0x10,%esp

	// null terminate the buffer
	*b.buf = '\0';
  80115c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80115f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801162:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801165:	c9                   	leave  
  801166:	c3                   	ret    

00801167 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80116d:	8d 45 10             	lea    0x10(%ebp),%eax
  801170:	83 c0 04             	add    $0x4,%eax
  801173:	89 45 f4             	mov    %eax,-0xc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  801176:	8b 45 10             	mov    0x10(%ebp),%eax
  801179:	ff 75 f4             	pushl  -0xc(%ebp)
  80117c:	50                   	push   %eax
  80117d:	ff 75 0c             	pushl  0xc(%ebp)
  801180:	ff 75 08             	pushl  0x8(%ebp)
  801183:	e8 89 ff ff ff       	call   801111 <vsnprintf>
  801188:	83 c4 10             	add    $0x10,%esp
  80118b:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return rc;
  80118e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  801191:	c9                   	leave  
  801192:	c3                   	ret    

00801193 <strlen>:
#include <inc/string.h>
#include <inc/assert.h>

int
strlen(const char *s)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  801199:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8011a0:	eb 06                	jmp    8011a8 <strlen+0x15>
		n++;
  8011a2:	ff 45 fc             	incl   -0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8011a5:	ff 45 08             	incl   0x8(%ebp)
  8011a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ab:	8a 00                	mov    (%eax),%al
  8011ad:	84 c0                	test   %al,%al
  8011af:	75 f1                	jne    8011a2 <strlen+0xf>
		n++;
	return n;
  8011b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8011b4:	c9                   	leave  
  8011b5:	c3                   	ret    

008011b6 <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011bc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8011c3:	eb 09                	jmp    8011ce <strnlen+0x18>
		n++;
  8011c5:	ff 45 fc             	incl   -0x4(%ebp)
int
strnlen(const char *s, uint32 size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011c8:	ff 45 08             	incl   0x8(%ebp)
  8011cb:	ff 4d 0c             	decl   0xc(%ebp)
  8011ce:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011d2:	74 09                	je     8011dd <strnlen+0x27>
  8011d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d7:	8a 00                	mov    (%eax),%al
  8011d9:	84 c0                	test   %al,%al
  8011db:	75 e8                	jne    8011c5 <strnlen+0xf>
		n++;
	return n;
  8011dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8011e0:	c9                   	leave  
  8011e1:	c3                   	ret    

008011e2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  8011e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011eb:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  8011ee:	90                   	nop
  8011ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f2:	8d 50 01             	lea    0x1(%eax),%edx
  8011f5:	89 55 08             	mov    %edx,0x8(%ebp)
  8011f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011fb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011fe:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  801201:	8a 12                	mov    (%edx),%dl
  801203:	88 10                	mov    %dl,(%eax)
  801205:	8a 00                	mov    (%eax),%al
  801207:	84 c0                	test   %al,%al
  801209:	75 e4                	jne    8011ef <strcpy+0xd>
		/* do nothing */;
	return ret;
  80120b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80120e:	c9                   	leave  
  80120f:	c3                   	ret    

00801210 <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	83 ec 10             	sub    $0x10,%esp
	uint32 i;
	char *ret;

	ret = dst;
  801216:	8b 45 08             	mov    0x8(%ebp),%eax
  801219:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  80121c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  801223:	eb 1f                	jmp    801244 <strncpy+0x34>
		*dst++ = *src;
  801225:	8b 45 08             	mov    0x8(%ebp),%eax
  801228:	8d 50 01             	lea    0x1(%eax),%edx
  80122b:	89 55 08             	mov    %edx,0x8(%ebp)
  80122e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801231:	8a 12                	mov    (%edx),%dl
  801233:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  801235:	8b 45 0c             	mov    0xc(%ebp),%eax
  801238:	8a 00                	mov    (%eax),%al
  80123a:	84 c0                	test   %al,%al
  80123c:	74 03                	je     801241 <strncpy+0x31>
			src++;
  80123e:	ff 45 0c             	incl   0xc(%ebp)
strncpy(char *dst, const char *src, uint32 size) {
	uint32 i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801241:	ff 45 fc             	incl   -0x4(%ebp)
  801244:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801247:	3b 45 10             	cmp    0x10(%ebp),%eax
  80124a:	72 d9                	jb     801225 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  80124c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80124f:	c9                   	leave  
  801250:	c3                   	ret    

00801251 <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  801257:	8b 45 08             	mov    0x8(%ebp),%eax
  80125a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  80125d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801261:	74 30                	je     801293 <strlcpy+0x42>
		while (--size > 0 && *src != '\0')
  801263:	eb 16                	jmp    80127b <strlcpy+0x2a>
			*dst++ = *src++;
  801265:	8b 45 08             	mov    0x8(%ebp),%eax
  801268:	8d 50 01             	lea    0x1(%eax),%edx
  80126b:	89 55 08             	mov    %edx,0x8(%ebp)
  80126e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801271:	8d 4a 01             	lea    0x1(%edx),%ecx
  801274:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  801277:	8a 12                	mov    (%edx),%dl
  801279:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80127b:	ff 4d 10             	decl   0x10(%ebp)
  80127e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801282:	74 09                	je     80128d <strlcpy+0x3c>
  801284:	8b 45 0c             	mov    0xc(%ebp),%eax
  801287:	8a 00                	mov    (%eax),%al
  801289:	84 c0                	test   %al,%al
  80128b:	75 d8                	jne    801265 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  80128d:	8b 45 08             	mov    0x8(%ebp),%eax
  801290:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801293:	8b 55 08             	mov    0x8(%ebp),%edx
  801296:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801299:	29 c2                	sub    %eax,%edx
  80129b:	89 d0                	mov    %edx,%eax
}
  80129d:	c9                   	leave  
  80129e:	c3                   	ret    

0080129f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  8012a2:	eb 06                	jmp    8012aa <strcmp+0xb>
		p++, q++;
  8012a4:	ff 45 08             	incl   0x8(%ebp)
  8012a7:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8012aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ad:	8a 00                	mov    (%eax),%al
  8012af:	84 c0                	test   %al,%al
  8012b1:	74 0e                	je     8012c1 <strcmp+0x22>
  8012b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b6:	8a 10                	mov    (%eax),%dl
  8012b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012bb:	8a 00                	mov    (%eax),%al
  8012bd:	38 c2                	cmp    %al,%dl
  8012bf:	74 e3                	je     8012a4 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8012c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c4:	8a 00                	mov    (%eax),%al
  8012c6:	0f b6 d0             	movzbl %al,%edx
  8012c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012cc:	8a 00                	mov    (%eax),%al
  8012ce:	0f b6 c0             	movzbl %al,%eax
  8012d1:	29 c2                	sub    %eax,%edx
  8012d3:	89 d0                	mov    %edx,%eax
}
  8012d5:	5d                   	pop    %ebp
  8012d6:	c3                   	ret    

008012d7 <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  8012d7:	55                   	push   %ebp
  8012d8:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  8012da:	eb 09                	jmp    8012e5 <strncmp+0xe>
		n--, p++, q++;
  8012dc:	ff 4d 10             	decl   0x10(%ebp)
  8012df:	ff 45 08             	incl   0x8(%ebp)
  8012e2:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint32 n)
{
	while (n > 0 && *p && *p == *q)
  8012e5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012e9:	74 17                	je     801302 <strncmp+0x2b>
  8012eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ee:	8a 00                	mov    (%eax),%al
  8012f0:	84 c0                	test   %al,%al
  8012f2:	74 0e                	je     801302 <strncmp+0x2b>
  8012f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f7:	8a 10                	mov    (%eax),%dl
  8012f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012fc:	8a 00                	mov    (%eax),%al
  8012fe:	38 c2                	cmp    %al,%dl
  801300:	74 da                	je     8012dc <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  801302:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801306:	75 07                	jne    80130f <strncmp+0x38>
		return 0;
  801308:	b8 00 00 00 00       	mov    $0x0,%eax
  80130d:	eb 14                	jmp    801323 <strncmp+0x4c>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80130f:	8b 45 08             	mov    0x8(%ebp),%eax
  801312:	8a 00                	mov    (%eax),%al
  801314:	0f b6 d0             	movzbl %al,%edx
  801317:	8b 45 0c             	mov    0xc(%ebp),%eax
  80131a:	8a 00                	mov    (%eax),%al
  80131c:	0f b6 c0             	movzbl %al,%eax
  80131f:	29 c2                	sub    %eax,%edx
  801321:	89 d0                	mov    %edx,%eax
}
  801323:	5d                   	pop    %ebp
  801324:	c3                   	ret    

00801325 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
  801328:	83 ec 04             	sub    $0x4,%esp
  80132b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80132e:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  801331:	eb 12                	jmp    801345 <strchr+0x20>
		if (*s == c)
  801333:	8b 45 08             	mov    0x8(%ebp),%eax
  801336:	8a 00                	mov    (%eax),%al
  801338:	3a 45 fc             	cmp    -0x4(%ebp),%al
  80133b:	75 05                	jne    801342 <strchr+0x1d>
			return (char *) s;
  80133d:	8b 45 08             	mov    0x8(%ebp),%eax
  801340:	eb 11                	jmp    801353 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801342:	ff 45 08             	incl   0x8(%ebp)
  801345:	8b 45 08             	mov    0x8(%ebp),%eax
  801348:	8a 00                	mov    (%eax),%al
  80134a:	84 c0                	test   %al,%al
  80134c:	75 e5                	jne    801333 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  80134e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801353:	c9                   	leave  
  801354:	c3                   	ret    

00801355 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801355:	55                   	push   %ebp
  801356:	89 e5                	mov    %esp,%ebp
  801358:	83 ec 04             	sub    $0x4,%esp
  80135b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80135e:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  801361:	eb 0d                	jmp    801370 <strfind+0x1b>
		if (*s == c)
  801363:	8b 45 08             	mov    0x8(%ebp),%eax
  801366:	8a 00                	mov    (%eax),%al
  801368:	3a 45 fc             	cmp    -0x4(%ebp),%al
  80136b:	74 0e                	je     80137b <strfind+0x26>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80136d:	ff 45 08             	incl   0x8(%ebp)
  801370:	8b 45 08             	mov    0x8(%ebp),%eax
  801373:	8a 00                	mov    (%eax),%al
  801375:	84 c0                	test   %al,%al
  801377:	75 ea                	jne    801363 <strfind+0xe>
  801379:	eb 01                	jmp    80137c <strfind+0x27>
		if (*s == c)
			break;
  80137b:	90                   	nop
	return (char *) s;
  80137c:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80137f:	c9                   	leave  
  801380:	c3                   	ret    

00801381 <memset>:


void *
memset(void *v, int c, uint32 n)
{
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	83 ec 10             	sub    $0x10,%esp
	char *p;
	int m;

	p = v;
  801387:	8b 45 08             	mov    0x8(%ebp),%eax
  80138a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	m = n;
  80138d:	8b 45 10             	mov    0x10(%ebp),%eax
  801390:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (--m >= 0)
  801393:	eb 0e                	jmp    8013a3 <memset+0x22>
		*p++ = c;
  801395:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801398:	8d 50 01             	lea    0x1(%eax),%edx
  80139b:	89 55 fc             	mov    %edx,-0x4(%ebp)
  80139e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013a1:	88 10                	mov    %dl,(%eax)
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  8013a3:	ff 4d f8             	decl   -0x8(%ebp)
  8013a6:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
  8013aa:	79 e9                	jns    801395 <memset+0x14>
		*p++ = c;

	return v;
  8013ac:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8013af:	c9                   	leave  
  8013b0:	c3                   	ret    

008013b1 <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  8013b1:	55                   	push   %ebp
  8013b2:	89 e5                	mov    %esp,%ebp
  8013b4:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  8013b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  8013bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c0:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
  8013c3:	eb 16                	jmp    8013db <memcpy+0x2a>
		*d++ = *s++;
  8013c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8013c8:	8d 50 01             	lea    0x1(%eax),%edx
  8013cb:	89 55 f8             	mov    %edx,-0x8(%ebp)
  8013ce:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8013d1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8013d4:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  8013d7:	8a 12                	mov    (%edx),%dl
  8013d9:	88 10                	mov    %dl,(%eax)
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  8013db:	8b 45 10             	mov    0x10(%ebp),%eax
  8013de:	8d 50 ff             	lea    -0x1(%eax),%edx
  8013e1:	89 55 10             	mov    %edx,0x10(%ebp)
  8013e4:	85 c0                	test   %eax,%eax
  8013e6:	75 dd                	jne    8013c5 <memcpy+0x14>
		*d++ = *s++;

	return dst;
  8013e8:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8013eb:	c9                   	leave  
  8013ec:	c3                   	ret    

008013ed <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  8013f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  8013f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fc:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (s < d && s + n > d) {
  8013ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801402:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  801405:	73 50                	jae    801457 <memmove+0x6a>
  801407:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80140a:	8b 45 10             	mov    0x10(%ebp),%eax
  80140d:	01 d0                	add    %edx,%eax
  80140f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  801412:	76 43                	jbe    801457 <memmove+0x6a>
		s += n;
  801414:	8b 45 10             	mov    0x10(%ebp),%eax
  801417:	01 45 fc             	add    %eax,-0x4(%ebp)
		d += n;
  80141a:	8b 45 10             	mov    0x10(%ebp),%eax
  80141d:	01 45 f8             	add    %eax,-0x8(%ebp)
		while (n-- > 0)
  801420:	eb 10                	jmp    801432 <memmove+0x45>
			*--d = *--s;
  801422:	ff 4d f8             	decl   -0x8(%ebp)
  801425:	ff 4d fc             	decl   -0x4(%ebp)
  801428:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80142b:	8a 10                	mov    (%eax),%dl
  80142d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801430:	88 10                	mov    %dl,(%eax)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  801432:	8b 45 10             	mov    0x10(%ebp),%eax
  801435:	8d 50 ff             	lea    -0x1(%eax),%edx
  801438:	89 55 10             	mov    %edx,0x10(%ebp)
  80143b:	85 c0                	test   %eax,%eax
  80143d:	75 e3                	jne    801422 <memmove+0x35>
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80143f:	eb 23                	jmp    801464 <memmove+0x77>
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  801441:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801444:	8d 50 01             	lea    0x1(%eax),%edx
  801447:	89 55 f8             	mov    %edx,-0x8(%ebp)
  80144a:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80144d:	8d 4a 01             	lea    0x1(%edx),%ecx
  801450:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  801453:	8a 12                	mov    (%edx),%dl
  801455:	88 10                	mov    %dl,(%eax)
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  801457:	8b 45 10             	mov    0x10(%ebp),%eax
  80145a:	8d 50 ff             	lea    -0x1(%eax),%edx
  80145d:	89 55 10             	mov    %edx,0x10(%ebp)
  801460:	85 c0                	test   %eax,%eax
  801462:	75 dd                	jne    801441 <memmove+0x54>
			*d++ = *s++;

	return dst;
  801464:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801467:	c9                   	leave  
  801468:	c3                   	ret    

00801469 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  801469:	55                   	push   %ebp
  80146a:	89 e5                	mov    %esp,%ebp
  80146c:	83 ec 10             	sub    $0x10,%esp
	const uint8 *s1 = (const uint8 *) v1;
  80146f:	8b 45 08             	mov    0x8(%ebp),%eax
  801472:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8 *s2 = (const uint8 *) v2;
  801475:	8b 45 0c             	mov    0xc(%ebp),%eax
  801478:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  80147b:	eb 2a                	jmp    8014a7 <memcmp+0x3e>
		if (*s1 != *s2)
  80147d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801480:	8a 10                	mov    (%eax),%dl
  801482:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801485:	8a 00                	mov    (%eax),%al
  801487:	38 c2                	cmp    %al,%dl
  801489:	74 16                	je     8014a1 <memcmp+0x38>
			return (int) *s1 - (int) *s2;
  80148b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80148e:	8a 00                	mov    (%eax),%al
  801490:	0f b6 d0             	movzbl %al,%edx
  801493:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801496:	8a 00                	mov    (%eax),%al
  801498:	0f b6 c0             	movzbl %al,%eax
  80149b:	29 c2                	sub    %eax,%edx
  80149d:	89 d0                	mov    %edx,%eax
  80149f:	eb 18                	jmp    8014b9 <memcmp+0x50>
		s1++, s2++;
  8014a1:	ff 45 fc             	incl   -0x4(%ebp)
  8014a4:	ff 45 f8             	incl   -0x8(%ebp)
memcmp(const void *v1, const void *v2, uint32 n)
{
	const uint8 *s1 = (const uint8 *) v1;
	const uint8 *s2 = (const uint8 *) v2;

	while (n-- > 0) {
  8014a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8014aa:	8d 50 ff             	lea    -0x1(%eax),%edx
  8014ad:	89 55 10             	mov    %edx,0x10(%ebp)
  8014b0:	85 c0                	test   %eax,%eax
  8014b2:	75 c9                	jne    80147d <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8014b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014b9:	c9                   	leave  
  8014ba:	c3                   	ret    

008014bb <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  8014c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8014c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8014c7:	01 d0                	add    %edx,%eax
  8014c9:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  8014cc:	eb 15                	jmp    8014e3 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  8014ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d1:	8a 00                	mov    (%eax),%al
  8014d3:	0f b6 d0             	movzbl %al,%edx
  8014d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d9:	0f b6 c0             	movzbl %al,%eax
  8014dc:	39 c2                	cmp    %eax,%edx
  8014de:	74 0d                	je     8014ed <memfind+0x32>

void *
memfind(const void *s, int c, uint32 n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8014e0:	ff 45 08             	incl   0x8(%ebp)
  8014e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  8014e9:	72 e3                	jb     8014ce <memfind+0x13>
  8014eb:	eb 01                	jmp    8014ee <memfind+0x33>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
  8014ed:	90                   	nop
	return (void *) s;
  8014ee:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8014f1:	c9                   	leave  
  8014f2:	c3                   	ret    

008014f3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
  8014f6:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  8014f9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  801500:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801507:	eb 03                	jmp    80150c <strtol+0x19>
		s++;
  801509:	ff 45 08             	incl   0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80150c:	8b 45 08             	mov    0x8(%ebp),%eax
  80150f:	8a 00                	mov    (%eax),%al
  801511:	3c 20                	cmp    $0x20,%al
  801513:	74 f4                	je     801509 <strtol+0x16>
  801515:	8b 45 08             	mov    0x8(%ebp),%eax
  801518:	8a 00                	mov    (%eax),%al
  80151a:	3c 09                	cmp    $0x9,%al
  80151c:	74 eb                	je     801509 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  80151e:	8b 45 08             	mov    0x8(%ebp),%eax
  801521:	8a 00                	mov    (%eax),%al
  801523:	3c 2b                	cmp    $0x2b,%al
  801525:	75 05                	jne    80152c <strtol+0x39>
		s++;
  801527:	ff 45 08             	incl   0x8(%ebp)
  80152a:	eb 13                	jmp    80153f <strtol+0x4c>
	else if (*s == '-')
  80152c:	8b 45 08             	mov    0x8(%ebp),%eax
  80152f:	8a 00                	mov    (%eax),%al
  801531:	3c 2d                	cmp    $0x2d,%al
  801533:	75 0a                	jne    80153f <strtol+0x4c>
		s++, neg = 1;
  801535:	ff 45 08             	incl   0x8(%ebp)
  801538:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80153f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801543:	74 06                	je     80154b <strtol+0x58>
  801545:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801549:	75 20                	jne    80156b <strtol+0x78>
  80154b:	8b 45 08             	mov    0x8(%ebp),%eax
  80154e:	8a 00                	mov    (%eax),%al
  801550:	3c 30                	cmp    $0x30,%al
  801552:	75 17                	jne    80156b <strtol+0x78>
  801554:	8b 45 08             	mov    0x8(%ebp),%eax
  801557:	40                   	inc    %eax
  801558:	8a 00                	mov    (%eax),%al
  80155a:	3c 78                	cmp    $0x78,%al
  80155c:	75 0d                	jne    80156b <strtol+0x78>
		s += 2, base = 16;
  80155e:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  801562:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  801569:	eb 28                	jmp    801593 <strtol+0xa0>
	else if (base == 0 && s[0] == '0')
  80156b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80156f:	75 15                	jne    801586 <strtol+0x93>
  801571:	8b 45 08             	mov    0x8(%ebp),%eax
  801574:	8a 00                	mov    (%eax),%al
  801576:	3c 30                	cmp    $0x30,%al
  801578:	75 0c                	jne    801586 <strtol+0x93>
		s++, base = 8;
  80157a:	ff 45 08             	incl   0x8(%ebp)
  80157d:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801584:	eb 0d                	jmp    801593 <strtol+0xa0>
	else if (base == 0)
  801586:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80158a:	75 07                	jne    801593 <strtol+0xa0>
		base = 10;
  80158c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801593:	8b 45 08             	mov    0x8(%ebp),%eax
  801596:	8a 00                	mov    (%eax),%al
  801598:	3c 2f                	cmp    $0x2f,%al
  80159a:	7e 19                	jle    8015b5 <strtol+0xc2>
  80159c:	8b 45 08             	mov    0x8(%ebp),%eax
  80159f:	8a 00                	mov    (%eax),%al
  8015a1:	3c 39                	cmp    $0x39,%al
  8015a3:	7f 10                	jg     8015b5 <strtol+0xc2>
			dig = *s - '0';
  8015a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a8:	8a 00                	mov    (%eax),%al
  8015aa:	0f be c0             	movsbl %al,%eax
  8015ad:	83 e8 30             	sub    $0x30,%eax
  8015b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8015b3:	eb 42                	jmp    8015f7 <strtol+0x104>
		else if (*s >= 'a' && *s <= 'z')
  8015b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b8:	8a 00                	mov    (%eax),%al
  8015ba:	3c 60                	cmp    $0x60,%al
  8015bc:	7e 19                	jle    8015d7 <strtol+0xe4>
  8015be:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c1:	8a 00                	mov    (%eax),%al
  8015c3:	3c 7a                	cmp    $0x7a,%al
  8015c5:	7f 10                	jg     8015d7 <strtol+0xe4>
			dig = *s - 'a' + 10;
  8015c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ca:	8a 00                	mov    (%eax),%al
  8015cc:	0f be c0             	movsbl %al,%eax
  8015cf:	83 e8 57             	sub    $0x57,%eax
  8015d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8015d5:	eb 20                	jmp    8015f7 <strtol+0x104>
		else if (*s >= 'A' && *s <= 'Z')
  8015d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015da:	8a 00                	mov    (%eax),%al
  8015dc:	3c 40                	cmp    $0x40,%al
  8015de:	7e 39                	jle    801619 <strtol+0x126>
  8015e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e3:	8a 00                	mov    (%eax),%al
  8015e5:	3c 5a                	cmp    $0x5a,%al
  8015e7:	7f 30                	jg     801619 <strtol+0x126>
			dig = *s - 'A' + 10;
  8015e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ec:	8a 00                	mov    (%eax),%al
  8015ee:	0f be c0             	movsbl %al,%eax
  8015f1:	83 e8 37             	sub    $0x37,%eax
  8015f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  8015f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015fa:	3b 45 10             	cmp    0x10(%ebp),%eax
  8015fd:	7d 19                	jge    801618 <strtol+0x125>
			break;
		s++, val = (val * base) + dig;
  8015ff:	ff 45 08             	incl   0x8(%ebp)
  801602:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801605:	0f af 45 10          	imul   0x10(%ebp),%eax
  801609:	89 c2                	mov    %eax,%edx
  80160b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80160e:	01 d0                	add    %edx,%eax
  801610:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  801613:	e9 7b ff ff ff       	jmp    801593 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
			break;
  801618:	90                   	nop
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801619:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80161d:	74 08                	je     801627 <strtol+0x134>
		*endptr = (char *) s;
  80161f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801622:	8b 55 08             	mov    0x8(%ebp),%edx
  801625:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801627:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  80162b:	74 07                	je     801634 <strtol+0x141>
  80162d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801630:	f7 d8                	neg    %eax
  801632:	eb 03                	jmp    801637 <strtol+0x144>
  801634:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801637:	c9                   	leave  
  801638:	c3                   	ret    

00801639 <ltostr>:

void
ltostr(long value, char *str)
{
  801639:	55                   	push   %ebp
  80163a:	89 e5                	mov    %esp,%ebp
  80163c:	83 ec 20             	sub    $0x20,%esp
	int neg = 0;
  80163f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	int s = 0 ;
  801646:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// plus/minus sign
	if (value < 0)
  80164d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801651:	79 13                	jns    801666 <ltostr+0x2d>
	{
		neg = 1;
  801653:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
		str[0] = '-';
  80165a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80165d:	c6 00 2d             	movb   $0x2d,(%eax)
		value = value * -1 ;
  801660:	f7 5d 08             	negl   0x8(%ebp)
		s++ ;
  801663:	ff 45 f8             	incl   -0x8(%ebp)
	}
	do
	{
		int mod = value % 10 ;
  801666:	8b 45 08             	mov    0x8(%ebp),%eax
  801669:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80166e:	99                   	cltd   
  80166f:	f7 f9                	idiv   %ecx
  801671:	89 55 ec             	mov    %edx,-0x14(%ebp)
		str[s++] = mod + '0' ;
  801674:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801677:	8d 50 01             	lea    0x1(%eax),%edx
  80167a:	89 55 f8             	mov    %edx,-0x8(%ebp)
  80167d:	89 c2                	mov    %eax,%edx
  80167f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801682:	01 d0                	add    %edx,%eax
  801684:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801687:	83 c2 30             	add    $0x30,%edx
  80168a:	88 10                	mov    %dl,(%eax)
		value = value / 10 ;
  80168c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80168f:	b8 67 66 66 66       	mov    $0x66666667,%eax
  801694:	f7 e9                	imul   %ecx
  801696:	c1 fa 02             	sar    $0x2,%edx
  801699:	89 c8                	mov    %ecx,%eax
  80169b:	c1 f8 1f             	sar    $0x1f,%eax
  80169e:	29 c2                	sub    %eax,%edx
  8016a0:	89 d0                	mov    %edx,%eax
  8016a2:	89 45 08             	mov    %eax,0x8(%ebp)
	/*2023 FIX el7 :)*/
	//} while (value % 10 != 0);
	} while (value != 0);
  8016a5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8016a9:	75 bb                	jne    801666 <ltostr+0x2d>

	//reverse the string
	int start = 0 ;
  8016ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int end = s-1 ;
  8016b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8016b5:	48                   	dec    %eax
  8016b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (neg)
  8016b9:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8016bd:	74 3d                	je     8016fc <ltostr+0xc3>
		start = 1 ;
  8016bf:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	while(start<end)
  8016c6:	eb 34                	jmp    8016fc <ltostr+0xc3>
	{
		char tmp = str[start] ;
  8016c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016ce:	01 d0                	add    %edx,%eax
  8016d0:	8a 00                	mov    (%eax),%al
  8016d2:	88 45 eb             	mov    %al,-0x15(%ebp)
		str[start] = str[end] ;
  8016d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016db:	01 c2                	add    %eax,%edx
  8016dd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8016e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e3:	01 c8                	add    %ecx,%eax
  8016e5:	8a 00                	mov    (%eax),%al
  8016e7:	88 02                	mov    %al,(%edx)
		str[end] = tmp;
  8016e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016ef:	01 c2                	add    %eax,%edx
  8016f1:	8a 45 eb             	mov    -0x15(%ebp),%al
  8016f4:	88 02                	mov    %al,(%edx)
		start++ ;
  8016f6:	ff 45 f4             	incl   -0xc(%ebp)
		end-- ;
  8016f9:	ff 4d f0             	decl   -0x10(%ebp)
	//reverse the string
	int start = 0 ;
	int end = s-1 ;
	if (neg)
		start = 1 ;
	while(start<end)
  8016fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ff:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  801702:	7c c4                	jl     8016c8 <ltostr+0x8f>
		str[end] = tmp;
		start++ ;
		end-- ;
	}

	str[s] = 0 ;
  801704:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801707:	8b 45 0c             	mov    0xc(%ebp),%eax
  80170a:	01 d0                	add    %edx,%eax
  80170c:	c6 00 00             	movb   $0x0,(%eax)
	// we don't properly detect overflow!

}
  80170f:	90                   	nop
  801710:	c9                   	leave  
  801711:	c3                   	ret    

00801712 <strcconcat>:

void
strcconcat(const char *str1, const char *str2, char *final)
{
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
  801715:	83 ec 10             	sub    $0x10,%esp
	int len1 = strlen(str1);
  801718:	ff 75 08             	pushl  0x8(%ebp)
  80171b:	e8 73 fa ff ff       	call   801193 <strlen>
  801720:	83 c4 04             	add    $0x4,%esp
  801723:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int len2 = strlen(str2);
  801726:	ff 75 0c             	pushl  0xc(%ebp)
  801729:	e8 65 fa ff ff       	call   801193 <strlen>
  80172e:	83 c4 04             	add    $0x4,%esp
  801731:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int s = 0 ;
  801734:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for (s=0 ; s < len1 ; s++)
  80173b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  801742:	eb 17                	jmp    80175b <strcconcat+0x49>
		final[s] = str1[s] ;
  801744:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801747:	8b 45 10             	mov    0x10(%ebp),%eax
  80174a:	01 c2                	add    %eax,%edx
  80174c:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  80174f:	8b 45 08             	mov    0x8(%ebp),%eax
  801752:	01 c8                	add    %ecx,%eax
  801754:	8a 00                	mov    (%eax),%al
  801756:	88 02                	mov    %al,(%edx)
strcconcat(const char *str1, const char *str2, char *final)
{
	int len1 = strlen(str1);
	int len2 = strlen(str2);
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
  801758:	ff 45 fc             	incl   -0x4(%ebp)
  80175b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80175e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  801761:	7c e1                	jl     801744 <strcconcat+0x32>
		final[s] = str1[s] ;

	int i = 0 ;
  801763:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
	for (i=0 ; i < len2 ; i++)
  80176a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  801771:	eb 1f                	jmp    801792 <strcconcat+0x80>
		final[s++] = str2[i] ;
  801773:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801776:	8d 50 01             	lea    0x1(%eax),%edx
  801779:	89 55 fc             	mov    %edx,-0x4(%ebp)
  80177c:	89 c2                	mov    %eax,%edx
  80177e:	8b 45 10             	mov    0x10(%ebp),%eax
  801781:	01 c2                	add    %eax,%edx
  801783:	8b 4d f8             	mov    -0x8(%ebp),%ecx
  801786:	8b 45 0c             	mov    0xc(%ebp),%eax
  801789:	01 c8                	add    %ecx,%eax
  80178b:	8a 00                	mov    (%eax),%al
  80178d:	88 02                	mov    %al,(%edx)
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
		final[s] = str1[s] ;

	int i = 0 ;
	for (i=0 ; i < len2 ; i++)
  80178f:	ff 45 f8             	incl   -0x8(%ebp)
  801792:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801795:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  801798:	7c d9                	jl     801773 <strcconcat+0x61>
		final[s++] = str2[i] ;

	final[s] = 0;
  80179a:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80179d:	8b 45 10             	mov    0x10(%ebp),%eax
  8017a0:	01 d0                	add    %edx,%eax
  8017a2:	c6 00 00             	movb   $0x0,(%eax)
}
  8017a5:	90                   	nop
  8017a6:	c9                   	leave  
  8017a7:	c3                   	ret    

008017a8 <strsplit>:
int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  8017a8:	55                   	push   %ebp
  8017a9:	89 e5                	mov    %esp,%ebp
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  8017ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ae:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	(argv)[*argc] = 0;
  8017b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8017b7:	8b 00                	mov    (%eax),%eax
  8017b9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8017c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8017c3:	01 d0                	add    %edx,%eax
  8017c5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  8017cb:	eb 0c                	jmp    8017d9 <strsplit+0x31>
			*string++ = 0;
  8017cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d0:	8d 50 01             	lea    0x1(%eax),%edx
  8017d3:	89 55 08             	mov    %edx,0x8(%ebp)
  8017d6:	c6 00 00             	movb   $0x0,(%eax)
	*argc = 0;
	(argv)[*argc] = 0;
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  8017d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dc:	8a 00                	mov    (%eax),%al
  8017de:	84 c0                	test   %al,%al
  8017e0:	74 18                	je     8017fa <strsplit+0x52>
  8017e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e5:	8a 00                	mov    (%eax),%al
  8017e7:	0f be c0             	movsbl %al,%eax
  8017ea:	50                   	push   %eax
  8017eb:	ff 75 0c             	pushl  0xc(%ebp)
  8017ee:	e8 32 fb ff ff       	call   801325 <strchr>
  8017f3:	83 c4 08             	add    $0x8,%esp
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	75 d3                	jne    8017cd <strsplit+0x25>
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
  8017fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fd:	8a 00                	mov    (%eax),%al
  8017ff:	84 c0                	test   %al,%al
  801801:	74 5a                	je     80185d <strsplit+0xb5>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1)
  801803:	8b 45 14             	mov    0x14(%ebp),%eax
  801806:	8b 00                	mov    (%eax),%eax
  801808:	83 f8 0f             	cmp    $0xf,%eax
  80180b:	75 07                	jne    801814 <strsplit+0x6c>
		{
			return 0;
  80180d:	b8 00 00 00 00       	mov    $0x0,%eax
  801812:	eb 66                	jmp    80187a <strsplit+0xd2>
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  801814:	8b 45 14             	mov    0x14(%ebp),%eax
  801817:	8b 00                	mov    (%eax),%eax
  801819:	8d 48 01             	lea    0x1(%eax),%ecx
  80181c:	8b 55 14             	mov    0x14(%ebp),%edx
  80181f:	89 0a                	mov    %ecx,(%edx)
  801821:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801828:	8b 45 10             	mov    0x10(%ebp),%eax
  80182b:	01 c2                	add    %eax,%edx
  80182d:	8b 45 08             	mov    0x8(%ebp),%eax
  801830:	89 02                	mov    %eax,(%edx)
		while (*string && !strchr(SPLIT_CHARS, *string))
  801832:	eb 03                	jmp    801837 <strsplit+0x8f>
			string++;
  801834:	ff 45 08             	incl   0x8(%ebp)
			return 0;
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
  801837:	8b 45 08             	mov    0x8(%ebp),%eax
  80183a:	8a 00                	mov    (%eax),%al
  80183c:	84 c0                	test   %al,%al
  80183e:	74 8b                	je     8017cb <strsplit+0x23>
  801840:	8b 45 08             	mov    0x8(%ebp),%eax
  801843:	8a 00                	mov    (%eax),%al
  801845:	0f be c0             	movsbl %al,%eax
  801848:	50                   	push   %eax
  801849:	ff 75 0c             	pushl  0xc(%ebp)
  80184c:	e8 d4 fa ff ff       	call   801325 <strchr>
  801851:	83 c4 08             	add    $0x8,%esp
  801854:	85 c0                	test   %eax,%eax
  801856:	74 dc                	je     801834 <strsplit+0x8c>
			string++;
	}
  801858:	e9 6e ff ff ff       	jmp    8017cb <strsplit+0x23>
		while (*string && strchr(SPLIT_CHARS, *string))
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
			break;
  80185d:	90                   	nop
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
			string++;
	}
	(argv)[*argc] = 0;
  80185e:	8b 45 14             	mov    0x14(%ebp),%eax
  801861:	8b 00                	mov    (%eax),%eax
  801863:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80186a:	8b 45 10             	mov    0x10(%ebp),%eax
  80186d:	01 d0                	add    %edx,%eax
  80186f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return 1 ;
  801875:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80187a:	c9                   	leave  
  80187b:	c3                   	ret    

0080187c <str2lower>:


char* str2lower(char *dst, const char *src)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	83 ec 08             	sub    $0x8,%esp
	//[PROJECT]
	panic("str2lower is not implemented yet!");
  801882:	83 ec 04             	sub    $0x4,%esp
  801885:	68 c8 28 80 00       	push   $0x8028c8
  80188a:	68 3f 01 00 00       	push   $0x13f
  80188f:	68 ea 28 80 00       	push   $0x8028ea
  801894:	e8 a9 ef ff ff       	call   800842 <_panic>

00801899 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline uint32
syscall(int num, uint32 a1, uint32 a2, uint32 a3, uint32 a4, uint32 a5)
{
  801899:	55                   	push   %ebp
  80189a:	89 e5                	mov    %esp,%ebp
  80189c:	57                   	push   %edi
  80189d:	56                   	push   %esi
  80189e:	53                   	push   %ebx
  80189f:	83 ec 10             	sub    $0x10,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8018a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018ab:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8018ae:	8b 7d 18             	mov    0x18(%ebp),%edi
  8018b1:	8b 75 1c             	mov    0x1c(%ebp),%esi
  8018b4:	cd 30                	int    $0x30
  8018b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	return ret;
  8018b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8018bc:	83 c4 10             	add    $0x10,%esp
  8018bf:	5b                   	pop    %ebx
  8018c0:	5e                   	pop    %esi
  8018c1:	5f                   	pop    %edi
  8018c2:	5d                   	pop    %ebp
  8018c3:	c3                   	ret    

008018c4 <sys_cputs>:

void
sys_cputs(const char *s, uint32 len, uint8 printProgName)
{
  8018c4:	55                   	push   %ebp
  8018c5:	89 e5                	mov    %esp,%ebp
  8018c7:	83 ec 04             	sub    $0x4,%esp
  8018ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8018cd:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputs, (uint32) s, len, (uint32)printProgName, 0, 0);
  8018d0:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  8018d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d7:	6a 00                	push   $0x0
  8018d9:	6a 00                	push   $0x0
  8018db:	52                   	push   %edx
  8018dc:	ff 75 0c             	pushl  0xc(%ebp)
  8018df:	50                   	push   %eax
  8018e0:	6a 00                	push   $0x0
  8018e2:	e8 b2 ff ff ff       	call   801899 <syscall>
  8018e7:	83 c4 18             	add    $0x18,%esp
}
  8018ea:	90                   	nop
  8018eb:	c9                   	leave  
  8018ec:	c3                   	ret    

008018ed <sys_cgetc>:

int
sys_cgetc(void)
{
  8018ed:	55                   	push   %ebp
  8018ee:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
  8018f0:	6a 00                	push   $0x0
  8018f2:	6a 00                	push   $0x0
  8018f4:	6a 00                	push   $0x0
  8018f6:	6a 00                	push   $0x0
  8018f8:	6a 00                	push   $0x0
  8018fa:	6a 02                	push   $0x2
  8018fc:	e8 98 ff ff ff       	call   801899 <syscall>
  801901:	83 c4 18             	add    $0x18,%esp
}
  801904:	c9                   	leave  
  801905:	c3                   	ret    

00801906 <sys_lock_cons>:

void sys_lock_cons(void)
{
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
	syscall(SYS_lock_cons, 0, 0, 0, 0, 0);
  801909:	6a 00                	push   $0x0
  80190b:	6a 00                	push   $0x0
  80190d:	6a 00                	push   $0x0
  80190f:	6a 00                	push   $0x0
  801911:	6a 00                	push   $0x0
  801913:	6a 03                	push   $0x3
  801915:	e8 7f ff ff ff       	call   801899 <syscall>
  80191a:	83 c4 18             	add    $0x18,%esp
}
  80191d:	90                   	nop
  80191e:	c9                   	leave  
  80191f:	c3                   	ret    

00801920 <sys_unlock_cons>:
void sys_unlock_cons(void)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
	syscall(SYS_unlock_cons, 0, 0, 0, 0, 0);
  801923:	6a 00                	push   $0x0
  801925:	6a 00                	push   $0x0
  801927:	6a 00                	push   $0x0
  801929:	6a 00                	push   $0x0
  80192b:	6a 00                	push   $0x0
  80192d:	6a 04                	push   $0x4
  80192f:	e8 65 ff ff ff       	call   801899 <syscall>
  801934:	83 c4 18             	add    $0x18,%esp
}
  801937:	90                   	nop
  801938:	c9                   	leave  
  801939:	c3                   	ret    

0080193a <__sys_allocate_page>:

int __sys_allocate_page(void *va, int perm)
{
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
  80193d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801940:	8b 45 08             	mov    0x8(%ebp),%eax
  801943:	6a 00                	push   $0x0
  801945:	6a 00                	push   $0x0
  801947:	6a 00                	push   $0x0
  801949:	52                   	push   %edx
  80194a:	50                   	push   %eax
  80194b:	6a 08                	push   $0x8
  80194d:	e8 47 ff ff ff       	call   801899 <syscall>
  801952:	83 c4 18             	add    $0x18,%esp
}
  801955:	c9                   	leave  
  801956:	c3                   	ret    

00801957 <__sys_map_frame>:

int __sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  801957:	55                   	push   %ebp
  801958:	89 e5                	mov    %esp,%ebp
  80195a:	56                   	push   %esi
  80195b:	53                   	push   %ebx
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
  80195c:	8b 75 18             	mov    0x18(%ebp),%esi
  80195f:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801962:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801965:	8b 55 0c             	mov    0xc(%ebp),%edx
  801968:	8b 45 08             	mov    0x8(%ebp),%eax
  80196b:	56                   	push   %esi
  80196c:	53                   	push   %ebx
  80196d:	51                   	push   %ecx
  80196e:	52                   	push   %edx
  80196f:	50                   	push   %eax
  801970:	6a 09                	push   $0x9
  801972:	e8 22 ff ff ff       	call   801899 <syscall>
  801977:	83 c4 18             	add    $0x18,%esp
}
  80197a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80197d:	5b                   	pop    %ebx
  80197e:	5e                   	pop    %esi
  80197f:	5d                   	pop    %ebp
  801980:	c3                   	ret    

00801981 <__sys_unmap_frame>:

int __sys_unmap_frame(int32 envid, void *va)
{
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
  801984:	8b 55 0c             	mov    0xc(%ebp),%edx
  801987:	8b 45 08             	mov    0x8(%ebp),%eax
  80198a:	6a 00                	push   $0x0
  80198c:	6a 00                	push   $0x0
  80198e:	6a 00                	push   $0x0
  801990:	52                   	push   %edx
  801991:	50                   	push   %eax
  801992:	6a 0a                	push   $0xa
  801994:	e8 00 ff ff ff       	call   801899 <syscall>
  801999:	83 c4 18             	add    $0x18,%esp
}
  80199c:	c9                   	leave  
  80199d:	c3                   	ret    

0080199e <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
  8019a1:	6a 00                	push   $0x0
  8019a3:	6a 00                	push   $0x0
  8019a5:	6a 00                	push   $0x0
  8019a7:	ff 75 0c             	pushl  0xc(%ebp)
  8019aa:	ff 75 08             	pushl  0x8(%ebp)
  8019ad:	6a 0b                	push   $0xb
  8019af:	e8 e5 fe ff ff       	call   801899 <syscall>
  8019b4:	83 c4 18             	add    $0x18,%esp
}
  8019b7:	c9                   	leave  
  8019b8:	c3                   	ret    

008019b9 <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
  8019bc:	6a 00                	push   $0x0
  8019be:	6a 00                	push   $0x0
  8019c0:	6a 00                	push   $0x0
  8019c2:	6a 00                	push   $0x0
  8019c4:	6a 00                	push   $0x0
  8019c6:	6a 0c                	push   $0xc
  8019c8:	e8 cc fe ff ff       	call   801899 <syscall>
  8019cd:	83 c4 18             	add    $0x18,%esp
}
  8019d0:	c9                   	leave  
  8019d1:	c3                   	ret    

008019d2 <sys_calculate_modified_frames>:
uint32 sys_calculate_modified_frames()
{
  8019d2:	55                   	push   %ebp
  8019d3:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_modified_frames, 0, 0, 0, 0, 0);
  8019d5:	6a 00                	push   $0x0
  8019d7:	6a 00                	push   $0x0
  8019d9:	6a 00                	push   $0x0
  8019db:	6a 00                	push   $0x0
  8019dd:	6a 00                	push   $0x0
  8019df:	6a 0d                	push   $0xd
  8019e1:	e8 b3 fe ff ff       	call   801899 <syscall>
  8019e6:	83 c4 18             	add    $0x18,%esp
}
  8019e9:	c9                   	leave  
  8019ea:	c3                   	ret    

008019eb <sys_calculate_notmod_frames>:

uint32 sys_calculate_notmod_frames()
{
  8019eb:	55                   	push   %ebp
  8019ec:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_notmod_frames, 0, 0, 0, 0, 0);
  8019ee:	6a 00                	push   $0x0
  8019f0:	6a 00                	push   $0x0
  8019f2:	6a 00                	push   $0x0
  8019f4:	6a 00                	push   $0x0
  8019f6:	6a 00                	push   $0x0
  8019f8:	6a 0e                	push   $0xe
  8019fa:	e8 9a fe ff ff       	call   801899 <syscall>
  8019ff:	83 c4 18             	add    $0x18,%esp
}
  801a02:	c9                   	leave  
  801a03:	c3                   	ret    

00801a04 <sys_pf_calculate_allocated_pages>:

int sys_pf_calculate_allocated_pages()
{
  801a04:	55                   	push   %ebp
  801a05:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_pf_calc_allocated_pages, 0,0,0,0,0);
  801a07:	6a 00                	push   $0x0
  801a09:	6a 00                	push   $0x0
  801a0b:	6a 00                	push   $0x0
  801a0d:	6a 00                	push   $0x0
  801a0f:	6a 00                	push   $0x0
  801a11:	6a 0f                	push   $0xf
  801a13:	e8 81 fe ff ff       	call   801899 <syscall>
  801a18:	83 c4 18             	add    $0x18,%esp
}
  801a1b:	c9                   	leave  
  801a1c:	c3                   	ret    

00801a1d <sys_calculate_pages_tobe_removed_ready_exit>:

int sys_calculate_pages_tobe_removed_ready_exit(uint32 WS_or_MEMORY_flag)
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calculate_pages_tobe_removed_ready_exit, WS_or_MEMORY_flag,0,0,0,0);
  801a20:	6a 00                	push   $0x0
  801a22:	6a 00                	push   $0x0
  801a24:	6a 00                	push   $0x0
  801a26:	6a 00                	push   $0x0
  801a28:	ff 75 08             	pushl  0x8(%ebp)
  801a2b:	6a 10                	push   $0x10
  801a2d:	e8 67 fe ff ff       	call   801899 <syscall>
  801a32:	83 c4 18             	add    $0x18,%esp
}
  801a35:	c9                   	leave  
  801a36:	c3                   	ret    

00801a37 <sys_scarce_memory>:

void sys_scarce_memory()
{
  801a37:	55                   	push   %ebp
  801a38:	89 e5                	mov    %esp,%ebp
	syscall(SYS_scarce_memory,0,0,0,0,0);
  801a3a:	6a 00                	push   $0x0
  801a3c:	6a 00                	push   $0x0
  801a3e:	6a 00                	push   $0x0
  801a40:	6a 00                	push   $0x0
  801a42:	6a 00                	push   $0x0
  801a44:	6a 11                	push   $0x11
  801a46:	e8 4e fe ff ff       	call   801899 <syscall>
  801a4b:	83 c4 18             	add    $0x18,%esp
}
  801a4e:	90                   	nop
  801a4f:	c9                   	leave  
  801a50:	c3                   	ret    

00801a51 <sys_cputc>:

void
sys_cputc(const char c)
{
  801a51:	55                   	push   %ebp
  801a52:	89 e5                	mov    %esp,%ebp
  801a54:	83 ec 04             	sub    $0x4,%esp
  801a57:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5a:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputc, (uint32) c, 0, 0, 0, 0);
  801a5d:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  801a61:	6a 00                	push   $0x0
  801a63:	6a 00                	push   $0x0
  801a65:	6a 00                	push   $0x0
  801a67:	6a 00                	push   $0x0
  801a69:	50                   	push   %eax
  801a6a:	6a 01                	push   $0x1
  801a6c:	e8 28 fe ff ff       	call   801899 <syscall>
  801a71:	83 c4 18             	add    $0x18,%esp
}
  801a74:	90                   	nop
  801a75:	c9                   	leave  
  801a76:	c3                   	ret    

00801a77 <sys_clear_ffl>:


//NEW'12: BONUS2 Testing
void
sys_clear_ffl()
{
  801a77:	55                   	push   %ebp
  801a78:	89 e5                	mov    %esp,%ebp
	syscall(SYS_clearFFL,0, 0, 0, 0, 0);
  801a7a:	6a 00                	push   $0x0
  801a7c:	6a 00                	push   $0x0
  801a7e:	6a 00                	push   $0x0
  801a80:	6a 00                	push   $0x0
  801a82:	6a 00                	push   $0x0
  801a84:	6a 14                	push   $0x14
  801a86:	e8 0e fe ff ff       	call   801899 <syscall>
  801a8b:	83 c4 18             	add    $0x18,%esp
}
  801a8e:	90                   	nop
  801a8f:	c9                   	leave  
  801a90:	c3                   	ret    

00801a91 <sys_createSharedObject>:

int sys_createSharedObject(char* shareName, uint32 size, uint8 isWritable, void* virtual_address)
{
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	83 ec 04             	sub    $0x4,%esp
  801a97:	8b 45 10             	mov    0x10(%ebp),%eax
  801a9a:	88 45 fc             	mov    %al,-0x4(%ebp)
	return syscall(SYS_create_shared_object,(uint32)shareName, (uint32)size, isWritable, (uint32)virtual_address,  0);
  801a9d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801aa0:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  801aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa7:	6a 00                	push   $0x0
  801aa9:	51                   	push   %ecx
  801aaa:	52                   	push   %edx
  801aab:	ff 75 0c             	pushl  0xc(%ebp)
  801aae:	50                   	push   %eax
  801aaf:	6a 15                	push   $0x15
  801ab1:	e8 e3 fd ff ff       	call   801899 <syscall>
  801ab6:	83 c4 18             	add    $0x18,%esp
}
  801ab9:	c9                   	leave  
  801aba:	c3                   	ret    

00801abb <sys_getSizeOfSharedObject>:

//2017:
int sys_getSizeOfSharedObject(int32 ownerID, char* shareName)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_size_of_shared_object,(uint32) ownerID, (uint32)shareName, 0, 0, 0);
  801abe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac4:	6a 00                	push   $0x0
  801ac6:	6a 00                	push   $0x0
  801ac8:	6a 00                	push   $0x0
  801aca:	52                   	push   %edx
  801acb:	50                   	push   %eax
  801acc:	6a 16                	push   $0x16
  801ace:	e8 c6 fd ff ff       	call   801899 <syscall>
  801ad3:	83 c4 18             	add    $0x18,%esp
}
  801ad6:	c9                   	leave  
  801ad7:	c3                   	ret    

00801ad8 <sys_getSharedObject>:
//==========

int sys_getSharedObject(int32 ownerID, char* shareName, void* virtual_address)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_shared_object,(uint32) ownerID, (uint32)shareName, (uint32)virtual_address, 0, 0);
  801adb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801ade:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ae1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae4:	6a 00                	push   $0x0
  801ae6:	6a 00                	push   $0x0
  801ae8:	51                   	push   %ecx
  801ae9:	52                   	push   %edx
  801aea:	50                   	push   %eax
  801aeb:	6a 17                	push   $0x17
  801aed:	e8 a7 fd ff ff       	call   801899 <syscall>
  801af2:	83 c4 18             	add    $0x18,%esp
}
  801af5:	c9                   	leave  
  801af6:	c3                   	ret    

00801af7 <sys_freeSharedObject>:

int sys_freeSharedObject(int32 sharedObjectID, void *startVA)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_free_shared_object,(uint32) sharedObjectID, (uint32) startVA, 0, 0, 0);
  801afa:	8b 55 0c             	mov    0xc(%ebp),%edx
  801afd:	8b 45 08             	mov    0x8(%ebp),%eax
  801b00:	6a 00                	push   $0x0
  801b02:	6a 00                	push   $0x0
  801b04:	6a 00                	push   $0x0
  801b06:	52                   	push   %edx
  801b07:	50                   	push   %eax
  801b08:	6a 18                	push   $0x18
  801b0a:	e8 8a fd ff ff       	call   801899 <syscall>
  801b0f:	83 c4 18             	add    $0x18,%esp
}
  801b12:	c9                   	leave  
  801b13:	c3                   	ret    

00801b14 <sys_create_env>:

int sys_create_env(char* programName, unsigned int page_WS_size,unsigned int LRU_second_list_size,unsigned int percent_WS_pages_to_remove)
{
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_create_env,(uint32)programName, (uint32)page_WS_size,(uint32)LRU_second_list_size, (uint32)percent_WS_pages_to_remove, 0);
  801b17:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1a:	6a 00                	push   $0x0
  801b1c:	ff 75 14             	pushl  0x14(%ebp)
  801b1f:	ff 75 10             	pushl  0x10(%ebp)
  801b22:	ff 75 0c             	pushl  0xc(%ebp)
  801b25:	50                   	push   %eax
  801b26:	6a 19                	push   $0x19
  801b28:	e8 6c fd ff ff       	call   801899 <syscall>
  801b2d:	83 c4 18             	add    $0x18,%esp
}
  801b30:	c9                   	leave  
  801b31:	c3                   	ret    

00801b32 <sys_run_env>:

void sys_run_env(int32 envId)
{
  801b32:	55                   	push   %ebp
  801b33:	89 e5                	mov    %esp,%ebp
	syscall(SYS_run_env, (int32)envId, 0, 0, 0, 0);
  801b35:	8b 45 08             	mov    0x8(%ebp),%eax
  801b38:	6a 00                	push   $0x0
  801b3a:	6a 00                	push   $0x0
  801b3c:	6a 00                	push   $0x0
  801b3e:	6a 00                	push   $0x0
  801b40:	50                   	push   %eax
  801b41:	6a 1a                	push   $0x1a
  801b43:	e8 51 fd ff ff       	call   801899 <syscall>
  801b48:	83 c4 18             	add    $0x18,%esp
}
  801b4b:	90                   	nop
  801b4c:	c9                   	leave  
  801b4d:	c3                   	ret    

00801b4e <sys_destroy_env>:

int sys_destroy_env(int32  envid)
{
  801b4e:	55                   	push   %ebp
  801b4f:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_destroy_env, envid, 0, 0, 0, 0);
  801b51:	8b 45 08             	mov    0x8(%ebp),%eax
  801b54:	6a 00                	push   $0x0
  801b56:	6a 00                	push   $0x0
  801b58:	6a 00                	push   $0x0
  801b5a:	6a 00                	push   $0x0
  801b5c:	50                   	push   %eax
  801b5d:	6a 1b                	push   $0x1b
  801b5f:	e8 35 fd ff ff       	call   801899 <syscall>
  801b64:	83 c4 18             	add    $0x18,%esp
}
  801b67:	c9                   	leave  
  801b68:	c3                   	ret    

00801b69 <sys_getenvid>:

int32 sys_getenvid(void)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
  801b6c:	6a 00                	push   $0x0
  801b6e:	6a 00                	push   $0x0
  801b70:	6a 00                	push   $0x0
  801b72:	6a 00                	push   $0x0
  801b74:	6a 00                	push   $0x0
  801b76:	6a 05                	push   $0x5
  801b78:	e8 1c fd ff ff       	call   801899 <syscall>
  801b7d:	83 c4 18             	add    $0x18,%esp
}
  801b80:	c9                   	leave  
  801b81:	c3                   	ret    

00801b82 <sys_getenvindex>:

//2017
int32 sys_getenvindex(void)
{
  801b82:	55                   	push   %ebp
  801b83:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvindex, 0, 0, 0, 0, 0);
  801b85:	6a 00                	push   $0x0
  801b87:	6a 00                	push   $0x0
  801b89:	6a 00                	push   $0x0
  801b8b:	6a 00                	push   $0x0
  801b8d:	6a 00                	push   $0x0
  801b8f:	6a 06                	push   $0x6
  801b91:	e8 03 fd ff ff       	call   801899 <syscall>
  801b96:	83 c4 18             	add    $0x18,%esp
}
  801b99:	c9                   	leave  
  801b9a:	c3                   	ret    

00801b9b <sys_getparentenvid>:

int32 sys_getparentenvid(void)
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getparentenvid, 0, 0, 0, 0, 0);
  801b9e:	6a 00                	push   $0x0
  801ba0:	6a 00                	push   $0x0
  801ba2:	6a 00                	push   $0x0
  801ba4:	6a 00                	push   $0x0
  801ba6:	6a 00                	push   $0x0
  801ba8:	6a 07                	push   $0x7
  801baa:	e8 ea fc ff ff       	call   801899 <syscall>
  801baf:	83 c4 18             	add    $0x18,%esp
}
  801bb2:	c9                   	leave  
  801bb3:	c3                   	ret    

00801bb4 <sys_exit_env>:


void sys_exit_env(void)
{
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
	syscall(SYS_exit_env, 0, 0, 0, 0, 0);
  801bb7:	6a 00                	push   $0x0
  801bb9:	6a 00                	push   $0x0
  801bbb:	6a 00                	push   $0x0
  801bbd:	6a 00                	push   $0x0
  801bbf:	6a 00                	push   $0x0
  801bc1:	6a 1c                	push   $0x1c
  801bc3:	e8 d1 fc ff ff       	call   801899 <syscall>
  801bc8:	83 c4 18             	add    $0x18,%esp
}
  801bcb:	90                   	nop
  801bcc:	c9                   	leave  
  801bcd:	c3                   	ret    

00801bce <sys_get_virtual_time>:


struct uint64 sys_get_virtual_time()
{
  801bce:	55                   	push   %ebp
  801bcf:	89 e5                	mov    %esp,%ebp
  801bd1:	83 ec 10             	sub    $0x10,%esp
	struct uint64 result;
	syscall(SYS_get_virtual_time, (uint32)&(result.low), (uint32)&(result.hi), 0, 0, 0);
  801bd4:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801bd7:	8d 50 04             	lea    0x4(%eax),%edx
  801bda:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801bdd:	6a 00                	push   $0x0
  801bdf:	6a 00                	push   $0x0
  801be1:	6a 00                	push   $0x0
  801be3:	52                   	push   %edx
  801be4:	50                   	push   %eax
  801be5:	6a 1d                	push   $0x1d
  801be7:	e8 ad fc ff ff       	call   801899 <syscall>
  801bec:	83 c4 18             	add    $0x18,%esp
	return result;
  801bef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801bf5:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801bf8:	89 01                	mov    %eax,(%ecx)
  801bfa:	89 51 04             	mov    %edx,0x4(%ecx)
}
  801bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  801c00:	c9                   	leave  
  801c01:	c2 04 00             	ret    $0x4

00801c04 <sys_move_user_mem>:

// 2014
void sys_move_user_mem(uint32 src_virtual_address, uint32 dst_virtual_address, uint32 size)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
	syscall(SYS_move_user_mem, src_virtual_address, dst_virtual_address, size, 0, 0);
  801c07:	6a 00                	push   $0x0
  801c09:	6a 00                	push   $0x0
  801c0b:	ff 75 10             	pushl  0x10(%ebp)
  801c0e:	ff 75 0c             	pushl  0xc(%ebp)
  801c11:	ff 75 08             	pushl  0x8(%ebp)
  801c14:	6a 13                	push   $0x13
  801c16:	e8 7e fc ff ff       	call   801899 <syscall>
  801c1b:	83 c4 18             	add    $0x18,%esp
	return ;
  801c1e:	90                   	nop
}
  801c1f:	c9                   	leave  
  801c20:	c3                   	ret    

00801c21 <sys_rcr2>:
uint32 sys_rcr2()
{
  801c21:	55                   	push   %ebp
  801c22:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_rcr2, 0, 0, 0, 0, 0);
  801c24:	6a 00                	push   $0x0
  801c26:	6a 00                	push   $0x0
  801c28:	6a 00                	push   $0x0
  801c2a:	6a 00                	push   $0x0
  801c2c:	6a 00                	push   $0x0
  801c2e:	6a 1e                	push   $0x1e
  801c30:	e8 64 fc ff ff       	call   801899 <syscall>
  801c35:	83 c4 18             	add    $0x18,%esp
}
  801c38:	c9                   	leave  
  801c39:	c3                   	ret    

00801c3a <sys_bypassPageFault>:

void sys_bypassPageFault(uint8 instrLength)
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	83 ec 04             	sub    $0x4,%esp
  801c40:	8b 45 08             	mov    0x8(%ebp),%eax
  801c43:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_bypassPageFault, instrLength, 0, 0, 0, 0);
  801c46:	0f b6 45 fc          	movzbl -0x4(%ebp),%eax
  801c4a:	6a 00                	push   $0x0
  801c4c:	6a 00                	push   $0x0
  801c4e:	6a 00                	push   $0x0
  801c50:	6a 00                	push   $0x0
  801c52:	50                   	push   %eax
  801c53:	6a 1f                	push   $0x1f
  801c55:	e8 3f fc ff ff       	call   801899 <syscall>
  801c5a:	83 c4 18             	add    $0x18,%esp
	return ;
  801c5d:	90                   	nop
}
  801c5e:	c9                   	leave  
  801c5f:	c3                   	ret    

00801c60 <rsttst>:
void rsttst()
{
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
	syscall(SYS_rsttst, 0, 0, 0, 0, 0);
  801c63:	6a 00                	push   $0x0
  801c65:	6a 00                	push   $0x0
  801c67:	6a 00                	push   $0x0
  801c69:	6a 00                	push   $0x0
  801c6b:	6a 00                	push   $0x0
  801c6d:	6a 21                	push   $0x21
  801c6f:	e8 25 fc ff ff       	call   801899 <syscall>
  801c74:	83 c4 18             	add    $0x18,%esp
	return ;
  801c77:	90                   	nop
}
  801c78:	c9                   	leave  
  801c79:	c3                   	ret    

00801c7a <tst>:
void tst(uint32 n, uint32 v1, uint32 v2, char c, int inv)
{
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	83 ec 04             	sub    $0x4,%esp
  801c80:	8b 45 14             	mov    0x14(%ebp),%eax
  801c83:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_testNum, n, v1, v2, c, inv);
  801c86:	8b 55 18             	mov    0x18(%ebp),%edx
  801c89:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  801c8d:	52                   	push   %edx
  801c8e:	50                   	push   %eax
  801c8f:	ff 75 10             	pushl  0x10(%ebp)
  801c92:	ff 75 0c             	pushl  0xc(%ebp)
  801c95:	ff 75 08             	pushl  0x8(%ebp)
  801c98:	6a 20                	push   $0x20
  801c9a:	e8 fa fb ff ff       	call   801899 <syscall>
  801c9f:	83 c4 18             	add    $0x18,%esp
	return ;
  801ca2:	90                   	nop
}
  801ca3:	c9                   	leave  
  801ca4:	c3                   	ret    

00801ca5 <chktst>:
void chktst(uint32 n)
{
  801ca5:	55                   	push   %ebp
  801ca6:	89 e5                	mov    %esp,%ebp
	syscall(SYS_chktst, n, 0, 0, 0, 0);
  801ca8:	6a 00                	push   $0x0
  801caa:	6a 00                	push   $0x0
  801cac:	6a 00                	push   $0x0
  801cae:	6a 00                	push   $0x0
  801cb0:	ff 75 08             	pushl  0x8(%ebp)
  801cb3:	6a 22                	push   $0x22
  801cb5:	e8 df fb ff ff       	call   801899 <syscall>
  801cba:	83 c4 18             	add    $0x18,%esp
	return ;
  801cbd:	90                   	nop
}
  801cbe:	c9                   	leave  
  801cbf:	c3                   	ret    

00801cc0 <inctst>:

void inctst()
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
	syscall(SYS_inctst, 0, 0, 0, 0, 0);
  801cc3:	6a 00                	push   $0x0
  801cc5:	6a 00                	push   $0x0
  801cc7:	6a 00                	push   $0x0
  801cc9:	6a 00                	push   $0x0
  801ccb:	6a 00                	push   $0x0
  801ccd:	6a 23                	push   $0x23
  801ccf:	e8 c5 fb ff ff       	call   801899 <syscall>
  801cd4:	83 c4 18             	add    $0x18,%esp
	return ;
  801cd7:	90                   	nop
}
  801cd8:	c9                   	leave  
  801cd9:	c3                   	ret    

00801cda <gettst>:
uint32 gettst()
{
  801cda:	55                   	push   %ebp
  801cdb:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_gettst, 0, 0, 0, 0, 0);
  801cdd:	6a 00                	push   $0x0
  801cdf:	6a 00                	push   $0x0
  801ce1:	6a 00                	push   $0x0
  801ce3:	6a 00                	push   $0x0
  801ce5:	6a 00                	push   $0x0
  801ce7:	6a 24                	push   $0x24
  801ce9:	e8 ab fb ff ff       	call   801899 <syscall>
  801cee:	83 c4 18             	add    $0x18,%esp
}
  801cf1:	c9                   	leave  
  801cf2:	c3                   	ret    

00801cf3 <sys_isUHeapPlacementStrategyFIRSTFIT>:


//2015
uint32 sys_isUHeapPlacementStrategyFIRSTFIT()
{
  801cf3:	55                   	push   %ebp
  801cf4:	89 e5                	mov    %esp,%ebp
  801cf6:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  801cf9:	6a 00                	push   $0x0
  801cfb:	6a 00                	push   $0x0
  801cfd:	6a 00                	push   $0x0
  801cff:	6a 00                	push   $0x0
  801d01:	6a 00                	push   $0x0
  801d03:	6a 25                	push   $0x25
  801d05:	e8 8f fb ff ff       	call   801899 <syscall>
  801d0a:	83 c4 18             	add    $0x18,%esp
  801d0d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_FIRSTFIT)
  801d10:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
  801d14:	75 07                	jne    801d1d <sys_isUHeapPlacementStrategyFIRSTFIT+0x2a>
		return 1;
  801d16:	b8 01 00 00 00       	mov    $0x1,%eax
  801d1b:	eb 05                	jmp    801d22 <sys_isUHeapPlacementStrategyFIRSTFIT+0x2f>
	else
		return 0;
  801d1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d22:	c9                   	leave  
  801d23:	c3                   	ret    

00801d24 <sys_isUHeapPlacementStrategyBESTFIT>:
uint32 sys_isUHeapPlacementStrategyBESTFIT()
{
  801d24:	55                   	push   %ebp
  801d25:	89 e5                	mov    %esp,%ebp
  801d27:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  801d2a:	6a 00                	push   $0x0
  801d2c:	6a 00                	push   $0x0
  801d2e:	6a 00                	push   $0x0
  801d30:	6a 00                	push   $0x0
  801d32:	6a 00                	push   $0x0
  801d34:	6a 25                	push   $0x25
  801d36:	e8 5e fb ff ff       	call   801899 <syscall>
  801d3b:	83 c4 18             	add    $0x18,%esp
  801d3e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_BESTFIT)
  801d41:	83 7d fc 02          	cmpl   $0x2,-0x4(%ebp)
  801d45:	75 07                	jne    801d4e <sys_isUHeapPlacementStrategyBESTFIT+0x2a>
		return 1;
  801d47:	b8 01 00 00 00       	mov    $0x1,%eax
  801d4c:	eb 05                	jmp    801d53 <sys_isUHeapPlacementStrategyBESTFIT+0x2f>
	else
		return 0;
  801d4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d53:	c9                   	leave  
  801d54:	c3                   	ret    

00801d55 <sys_isUHeapPlacementStrategyNEXTFIT>:
uint32 sys_isUHeapPlacementStrategyNEXTFIT()
{
  801d55:	55                   	push   %ebp
  801d56:	89 e5                	mov    %esp,%ebp
  801d58:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  801d5b:	6a 00                	push   $0x0
  801d5d:	6a 00                	push   $0x0
  801d5f:	6a 00                	push   $0x0
  801d61:	6a 00                	push   $0x0
  801d63:	6a 00                	push   $0x0
  801d65:	6a 25                	push   $0x25
  801d67:	e8 2d fb ff ff       	call   801899 <syscall>
  801d6c:	83 c4 18             	add    $0x18,%esp
  801d6f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_NEXTFIT)
  801d72:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
  801d76:	75 07                	jne    801d7f <sys_isUHeapPlacementStrategyNEXTFIT+0x2a>
		return 1;
  801d78:	b8 01 00 00 00       	mov    $0x1,%eax
  801d7d:	eb 05                	jmp    801d84 <sys_isUHeapPlacementStrategyNEXTFIT+0x2f>
	else
		return 0;
  801d7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d84:	c9                   	leave  
  801d85:	c3                   	ret    

00801d86 <sys_isUHeapPlacementStrategyWORSTFIT>:
uint32 sys_isUHeapPlacementStrategyWORSTFIT()
{
  801d86:	55                   	push   %ebp
  801d87:	89 e5                	mov    %esp,%ebp
  801d89:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  801d8c:	6a 00                	push   $0x0
  801d8e:	6a 00                	push   $0x0
  801d90:	6a 00                	push   $0x0
  801d92:	6a 00                	push   $0x0
  801d94:	6a 00                	push   $0x0
  801d96:	6a 25                	push   $0x25
  801d98:	e8 fc fa ff ff       	call   801899 <syscall>
  801d9d:	83 c4 18             	add    $0x18,%esp
  801da0:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_WORSTFIT)
  801da3:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
  801da7:	75 07                	jne    801db0 <sys_isUHeapPlacementStrategyWORSTFIT+0x2a>
		return 1;
  801da9:	b8 01 00 00 00       	mov    $0x1,%eax
  801dae:	eb 05                	jmp    801db5 <sys_isUHeapPlacementStrategyWORSTFIT+0x2f>
	else
		return 0;
  801db0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801db5:	c9                   	leave  
  801db6:	c3                   	ret    

00801db7 <sys_set_uheap_strategy>:

void sys_set_uheap_strategy(uint32 heapStrategy)
{
  801db7:	55                   	push   %ebp
  801db8:	89 e5                	mov    %esp,%ebp
	syscall(SYS_set_heap_strategy, heapStrategy, 0, 0, 0, 0);
  801dba:	6a 00                	push   $0x0
  801dbc:	6a 00                	push   $0x0
  801dbe:	6a 00                	push   $0x0
  801dc0:	6a 00                	push   $0x0
  801dc2:	ff 75 08             	pushl  0x8(%ebp)
  801dc5:	6a 26                	push   $0x26
  801dc7:	e8 cd fa ff ff       	call   801899 <syscall>
  801dcc:	83 c4 18             	add    $0x18,%esp
	return ;
  801dcf:	90                   	nop
}
  801dd0:	c9                   	leave  
  801dd1:	c3                   	ret    

00801dd2 <sys_check_LRU_lists>:

//2020
int sys_check_LRU_lists(uint32* active_list_content, uint32* second_list_content, int actual_active_list_size, int actual_second_list_size)
{
  801dd2:	55                   	push   %ebp
  801dd3:	89 e5                	mov    %esp,%ebp
  801dd5:	53                   	push   %ebx
	return syscall(SYS_check_LRU_lists, (uint32)active_list_content, (uint32)second_list_content, (uint32)actual_active_list_size, (uint32)actual_second_list_size, 0);
  801dd6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801dd9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801ddc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  801de2:	6a 00                	push   $0x0
  801de4:	53                   	push   %ebx
  801de5:	51                   	push   %ecx
  801de6:	52                   	push   %edx
  801de7:	50                   	push   %eax
  801de8:	6a 27                	push   $0x27
  801dea:	e8 aa fa ff ff       	call   801899 <syscall>
  801def:	83 c4 18             	add    $0x18,%esp
}
  801df2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801df5:	c9                   	leave  
  801df6:	c3                   	ret    

00801df7 <sys_check_LRU_lists_free>:

int sys_check_LRU_lists_free(uint32* list_content, int list_size)
{
  801df7:	55                   	push   %ebp
  801df8:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_LRU_lists_free, (uint32)list_content, (uint32)list_size , 0, 0, 0);
  801dfa:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dfd:	8b 45 08             	mov    0x8(%ebp),%eax
  801e00:	6a 00                	push   $0x0
  801e02:	6a 00                	push   $0x0
  801e04:	6a 00                	push   $0x0
  801e06:	52                   	push   %edx
  801e07:	50                   	push   %eax
  801e08:	6a 28                	push   $0x28
  801e0a:	e8 8a fa ff ff       	call   801899 <syscall>
  801e0f:	83 c4 18             	add    $0x18,%esp
}
  801e12:	c9                   	leave  
  801e13:	c3                   	ret    

00801e14 <sys_check_WS_list>:

int sys_check_WS_list(uint32* WS_list_content, int actual_WS_list_size, uint32 last_WS_element_content, bool chk_in_order)
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_WS_list, (uint32)WS_list_content, (uint32)actual_WS_list_size , last_WS_element_content, (uint32)chk_in_order, 0);
  801e17:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801e1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e20:	6a 00                	push   $0x0
  801e22:	51                   	push   %ecx
  801e23:	ff 75 10             	pushl  0x10(%ebp)
  801e26:	52                   	push   %edx
  801e27:	50                   	push   %eax
  801e28:	6a 29                	push   $0x29
  801e2a:	e8 6a fa ff ff       	call   801899 <syscall>
  801e2f:	83 c4 18             	add    $0x18,%esp
}
  801e32:	c9                   	leave  
  801e33:	c3                   	ret    

00801e34 <sys_allocate_chunk>:
void sys_allocate_chunk(uint32 virtual_address, uint32 size, uint32 perms)
{
  801e34:	55                   	push   %ebp
  801e35:	89 e5                	mov    %esp,%ebp
	syscall(SYS_allocate_chunk_in_mem, virtual_address, size, perms, 0, 0);
  801e37:	6a 00                	push   $0x0
  801e39:	6a 00                	push   $0x0
  801e3b:	ff 75 10             	pushl  0x10(%ebp)
  801e3e:	ff 75 0c             	pushl  0xc(%ebp)
  801e41:	ff 75 08             	pushl  0x8(%ebp)
  801e44:	6a 12                	push   $0x12
  801e46:	e8 4e fa ff ff       	call   801899 <syscall>
  801e4b:	83 c4 18             	add    $0x18,%esp
	return ;
  801e4e:	90                   	nop
}
  801e4f:	c9                   	leave  
  801e50:	c3                   	ret    

00801e51 <sys_utilities>:
void sys_utilities(char* utilityName, int value)
{
  801e51:	55                   	push   %ebp
  801e52:	89 e5                	mov    %esp,%ebp
	syscall(SYS_utilities, (uint32)utilityName, value, 0, 0, 0);
  801e54:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e57:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5a:	6a 00                	push   $0x0
  801e5c:	6a 00                	push   $0x0
  801e5e:	6a 00                	push   $0x0
  801e60:	52                   	push   %edx
  801e61:	50                   	push   %eax
  801e62:	6a 2a                	push   $0x2a
  801e64:	e8 30 fa ff ff       	call   801899 <syscall>
  801e69:	83 c4 18             	add    $0x18,%esp
	return;
  801e6c:	90                   	nop
}
  801e6d:	c9                   	leave  
  801e6e:	c3                   	ret    

00801e6f <sys_sbrk>:


//TODO: [PROJECT'24.MS1 - #02] [2] SYSTEM CALLS - Implement these system calls
void* sys_sbrk(int increment)
{
  801e6f:	55                   	push   %ebp
  801e70:	89 e5                	mov    %esp,%ebp
	syscall( SYS_sbrk ,increment,0,0,0,0)  ;
  801e72:	8b 45 08             	mov    0x8(%ebp),%eax
  801e75:	6a 00                	push   $0x0
  801e77:	6a 00                	push   $0x0
  801e79:	6a 00                	push   $0x0
  801e7b:	6a 00                	push   $0x0
  801e7d:	50                   	push   %eax
  801e7e:	6a 2b                	push   $0x2b
  801e80:	e8 14 fa ff ff       	call   801899 <syscall>
  801e85:	83 c4 18             	add    $0x18,%esp

	return (void*)-1 ;
  801e88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

}
  801e8d:	c9                   	leave  
  801e8e:	c3                   	ret    

00801e8f <sys_free_user_mem>:
void sys_free_user_mem(uint32 virtual_address, uint32 size)
{
  801e8f:	55                   	push   %ebp
  801e90:	89 e5                	mov    %esp,%ebp
	syscall(SYS_free_user_mem,virtual_address,size,0,0,0);
  801e92:	6a 00                	push   $0x0
  801e94:	6a 00                	push   $0x0
  801e96:	6a 00                	push   $0x0
  801e98:	ff 75 0c             	pushl  0xc(%ebp)
  801e9b:	ff 75 08             	pushl  0x8(%ebp)
  801e9e:	6a 2c                	push   $0x2c
  801ea0:	e8 f4 f9 ff ff       	call   801899 <syscall>
  801ea5:	83 c4 18             	add    $0x18,%esp
	return;
  801ea8:	90                   	nop
}
  801ea9:	c9                   	leave  
  801eaa:	c3                   	ret    

00801eab <sys_allocate_user_mem>:

void sys_allocate_user_mem(uint32 virtual_address, uint32 size)
{
  801eab:	55                   	push   %ebp
  801eac:	89 e5                	mov    %esp,%ebp
	syscall(SYS_allocate_user_mem,virtual_address,size,0,0,0);
  801eae:	6a 00                	push   $0x0
  801eb0:	6a 00                	push   $0x0
  801eb2:	6a 00                	push   $0x0
  801eb4:	ff 75 0c             	pushl  0xc(%ebp)
  801eb7:	ff 75 08             	pushl  0x8(%ebp)
  801eba:	6a 2d                	push   $0x2d
  801ebc:	e8 d8 f9 ff ff       	call   801899 <syscall>
  801ec1:	83 c4 18             	add    $0x18,%esp
	return;
  801ec4:	90                   	nop
}
  801ec5:	c9                   	leave  
  801ec6:	c3                   	ret    
  801ec7:	90                   	nop

00801ec8 <__udivdi3>:
  801ec8:	55                   	push   %ebp
  801ec9:	57                   	push   %edi
  801eca:	56                   	push   %esi
  801ecb:	53                   	push   %ebx
  801ecc:	83 ec 1c             	sub    $0x1c,%esp
  801ecf:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801ed3:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ed7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801edb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801edf:	89 ca                	mov    %ecx,%edx
  801ee1:	89 f8                	mov    %edi,%eax
  801ee3:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ee7:	85 f6                	test   %esi,%esi
  801ee9:	75 2d                	jne    801f18 <__udivdi3+0x50>
  801eeb:	39 cf                	cmp    %ecx,%edi
  801eed:	77 65                	ja     801f54 <__udivdi3+0x8c>
  801eef:	89 fd                	mov    %edi,%ebp
  801ef1:	85 ff                	test   %edi,%edi
  801ef3:	75 0b                	jne    801f00 <__udivdi3+0x38>
  801ef5:	b8 01 00 00 00       	mov    $0x1,%eax
  801efa:	31 d2                	xor    %edx,%edx
  801efc:	f7 f7                	div    %edi
  801efe:	89 c5                	mov    %eax,%ebp
  801f00:	31 d2                	xor    %edx,%edx
  801f02:	89 c8                	mov    %ecx,%eax
  801f04:	f7 f5                	div    %ebp
  801f06:	89 c1                	mov    %eax,%ecx
  801f08:	89 d8                	mov    %ebx,%eax
  801f0a:	f7 f5                	div    %ebp
  801f0c:	89 cf                	mov    %ecx,%edi
  801f0e:	89 fa                	mov    %edi,%edx
  801f10:	83 c4 1c             	add    $0x1c,%esp
  801f13:	5b                   	pop    %ebx
  801f14:	5e                   	pop    %esi
  801f15:	5f                   	pop    %edi
  801f16:	5d                   	pop    %ebp
  801f17:	c3                   	ret    
  801f18:	39 ce                	cmp    %ecx,%esi
  801f1a:	77 28                	ja     801f44 <__udivdi3+0x7c>
  801f1c:	0f bd fe             	bsr    %esi,%edi
  801f1f:	83 f7 1f             	xor    $0x1f,%edi
  801f22:	75 40                	jne    801f64 <__udivdi3+0x9c>
  801f24:	39 ce                	cmp    %ecx,%esi
  801f26:	72 0a                	jb     801f32 <__udivdi3+0x6a>
  801f28:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801f2c:	0f 87 9e 00 00 00    	ja     801fd0 <__udivdi3+0x108>
  801f32:	b8 01 00 00 00       	mov    $0x1,%eax
  801f37:	89 fa                	mov    %edi,%edx
  801f39:	83 c4 1c             	add    $0x1c,%esp
  801f3c:	5b                   	pop    %ebx
  801f3d:	5e                   	pop    %esi
  801f3e:	5f                   	pop    %edi
  801f3f:	5d                   	pop    %ebp
  801f40:	c3                   	ret    
  801f41:	8d 76 00             	lea    0x0(%esi),%esi
  801f44:	31 ff                	xor    %edi,%edi
  801f46:	31 c0                	xor    %eax,%eax
  801f48:	89 fa                	mov    %edi,%edx
  801f4a:	83 c4 1c             	add    $0x1c,%esp
  801f4d:	5b                   	pop    %ebx
  801f4e:	5e                   	pop    %esi
  801f4f:	5f                   	pop    %edi
  801f50:	5d                   	pop    %ebp
  801f51:	c3                   	ret    
  801f52:	66 90                	xchg   %ax,%ax
  801f54:	89 d8                	mov    %ebx,%eax
  801f56:	f7 f7                	div    %edi
  801f58:	31 ff                	xor    %edi,%edi
  801f5a:	89 fa                	mov    %edi,%edx
  801f5c:	83 c4 1c             	add    $0x1c,%esp
  801f5f:	5b                   	pop    %ebx
  801f60:	5e                   	pop    %esi
  801f61:	5f                   	pop    %edi
  801f62:	5d                   	pop    %ebp
  801f63:	c3                   	ret    
  801f64:	bd 20 00 00 00       	mov    $0x20,%ebp
  801f69:	89 eb                	mov    %ebp,%ebx
  801f6b:	29 fb                	sub    %edi,%ebx
  801f6d:	89 f9                	mov    %edi,%ecx
  801f6f:	d3 e6                	shl    %cl,%esi
  801f71:	89 c5                	mov    %eax,%ebp
  801f73:	88 d9                	mov    %bl,%cl
  801f75:	d3 ed                	shr    %cl,%ebp
  801f77:	89 e9                	mov    %ebp,%ecx
  801f79:	09 f1                	or     %esi,%ecx
  801f7b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801f7f:	89 f9                	mov    %edi,%ecx
  801f81:	d3 e0                	shl    %cl,%eax
  801f83:	89 c5                	mov    %eax,%ebp
  801f85:	89 d6                	mov    %edx,%esi
  801f87:	88 d9                	mov    %bl,%cl
  801f89:	d3 ee                	shr    %cl,%esi
  801f8b:	89 f9                	mov    %edi,%ecx
  801f8d:	d3 e2                	shl    %cl,%edx
  801f8f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f93:	88 d9                	mov    %bl,%cl
  801f95:	d3 e8                	shr    %cl,%eax
  801f97:	09 c2                	or     %eax,%edx
  801f99:	89 d0                	mov    %edx,%eax
  801f9b:	89 f2                	mov    %esi,%edx
  801f9d:	f7 74 24 0c          	divl   0xc(%esp)
  801fa1:	89 d6                	mov    %edx,%esi
  801fa3:	89 c3                	mov    %eax,%ebx
  801fa5:	f7 e5                	mul    %ebp
  801fa7:	39 d6                	cmp    %edx,%esi
  801fa9:	72 19                	jb     801fc4 <__udivdi3+0xfc>
  801fab:	74 0b                	je     801fb8 <__udivdi3+0xf0>
  801fad:	89 d8                	mov    %ebx,%eax
  801faf:	31 ff                	xor    %edi,%edi
  801fb1:	e9 58 ff ff ff       	jmp    801f0e <__udivdi3+0x46>
  801fb6:	66 90                	xchg   %ax,%ax
  801fb8:	8b 54 24 08          	mov    0x8(%esp),%edx
  801fbc:	89 f9                	mov    %edi,%ecx
  801fbe:	d3 e2                	shl    %cl,%edx
  801fc0:	39 c2                	cmp    %eax,%edx
  801fc2:	73 e9                	jae    801fad <__udivdi3+0xe5>
  801fc4:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801fc7:	31 ff                	xor    %edi,%edi
  801fc9:	e9 40 ff ff ff       	jmp    801f0e <__udivdi3+0x46>
  801fce:	66 90                	xchg   %ax,%ax
  801fd0:	31 c0                	xor    %eax,%eax
  801fd2:	e9 37 ff ff ff       	jmp    801f0e <__udivdi3+0x46>
  801fd7:	90                   	nop

00801fd8 <__umoddi3>:
  801fd8:	55                   	push   %ebp
  801fd9:	57                   	push   %edi
  801fda:	56                   	push   %esi
  801fdb:	53                   	push   %ebx
  801fdc:	83 ec 1c             	sub    $0x1c,%esp
  801fdf:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801fe3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fe7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801feb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801fef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ff3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ff7:	89 f3                	mov    %esi,%ebx
  801ff9:	89 fa                	mov    %edi,%edx
  801ffb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801fff:	89 34 24             	mov    %esi,(%esp)
  802002:	85 c0                	test   %eax,%eax
  802004:	75 1a                	jne    802020 <__umoddi3+0x48>
  802006:	39 f7                	cmp    %esi,%edi
  802008:	0f 86 a2 00 00 00    	jbe    8020b0 <__umoddi3+0xd8>
  80200e:	89 c8                	mov    %ecx,%eax
  802010:	89 f2                	mov    %esi,%edx
  802012:	f7 f7                	div    %edi
  802014:	89 d0                	mov    %edx,%eax
  802016:	31 d2                	xor    %edx,%edx
  802018:	83 c4 1c             	add    $0x1c,%esp
  80201b:	5b                   	pop    %ebx
  80201c:	5e                   	pop    %esi
  80201d:	5f                   	pop    %edi
  80201e:	5d                   	pop    %ebp
  80201f:	c3                   	ret    
  802020:	39 f0                	cmp    %esi,%eax
  802022:	0f 87 ac 00 00 00    	ja     8020d4 <__umoddi3+0xfc>
  802028:	0f bd e8             	bsr    %eax,%ebp
  80202b:	83 f5 1f             	xor    $0x1f,%ebp
  80202e:	0f 84 ac 00 00 00    	je     8020e0 <__umoddi3+0x108>
  802034:	bf 20 00 00 00       	mov    $0x20,%edi
  802039:	29 ef                	sub    %ebp,%edi
  80203b:	89 fe                	mov    %edi,%esi
  80203d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802041:	89 e9                	mov    %ebp,%ecx
  802043:	d3 e0                	shl    %cl,%eax
  802045:	89 d7                	mov    %edx,%edi
  802047:	89 f1                	mov    %esi,%ecx
  802049:	d3 ef                	shr    %cl,%edi
  80204b:	09 c7                	or     %eax,%edi
  80204d:	89 e9                	mov    %ebp,%ecx
  80204f:	d3 e2                	shl    %cl,%edx
  802051:	89 14 24             	mov    %edx,(%esp)
  802054:	89 d8                	mov    %ebx,%eax
  802056:	d3 e0                	shl    %cl,%eax
  802058:	89 c2                	mov    %eax,%edx
  80205a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80205e:	d3 e0                	shl    %cl,%eax
  802060:	89 44 24 04          	mov    %eax,0x4(%esp)
  802064:	8b 44 24 08          	mov    0x8(%esp),%eax
  802068:	89 f1                	mov    %esi,%ecx
  80206a:	d3 e8                	shr    %cl,%eax
  80206c:	09 d0                	or     %edx,%eax
  80206e:	d3 eb                	shr    %cl,%ebx
  802070:	89 da                	mov    %ebx,%edx
  802072:	f7 f7                	div    %edi
  802074:	89 d3                	mov    %edx,%ebx
  802076:	f7 24 24             	mull   (%esp)
  802079:	89 c6                	mov    %eax,%esi
  80207b:	89 d1                	mov    %edx,%ecx
  80207d:	39 d3                	cmp    %edx,%ebx
  80207f:	0f 82 87 00 00 00    	jb     80210c <__umoddi3+0x134>
  802085:	0f 84 91 00 00 00    	je     80211c <__umoddi3+0x144>
  80208b:	8b 54 24 04          	mov    0x4(%esp),%edx
  80208f:	29 f2                	sub    %esi,%edx
  802091:	19 cb                	sbb    %ecx,%ebx
  802093:	89 d8                	mov    %ebx,%eax
  802095:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  802099:	d3 e0                	shl    %cl,%eax
  80209b:	89 e9                	mov    %ebp,%ecx
  80209d:	d3 ea                	shr    %cl,%edx
  80209f:	09 d0                	or     %edx,%eax
  8020a1:	89 e9                	mov    %ebp,%ecx
  8020a3:	d3 eb                	shr    %cl,%ebx
  8020a5:	89 da                	mov    %ebx,%edx
  8020a7:	83 c4 1c             	add    $0x1c,%esp
  8020aa:	5b                   	pop    %ebx
  8020ab:	5e                   	pop    %esi
  8020ac:	5f                   	pop    %edi
  8020ad:	5d                   	pop    %ebp
  8020ae:	c3                   	ret    
  8020af:	90                   	nop
  8020b0:	89 fd                	mov    %edi,%ebp
  8020b2:	85 ff                	test   %edi,%edi
  8020b4:	75 0b                	jne    8020c1 <__umoddi3+0xe9>
  8020b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020bb:	31 d2                	xor    %edx,%edx
  8020bd:	f7 f7                	div    %edi
  8020bf:	89 c5                	mov    %eax,%ebp
  8020c1:	89 f0                	mov    %esi,%eax
  8020c3:	31 d2                	xor    %edx,%edx
  8020c5:	f7 f5                	div    %ebp
  8020c7:	89 c8                	mov    %ecx,%eax
  8020c9:	f7 f5                	div    %ebp
  8020cb:	89 d0                	mov    %edx,%eax
  8020cd:	e9 44 ff ff ff       	jmp    802016 <__umoddi3+0x3e>
  8020d2:	66 90                	xchg   %ax,%ax
  8020d4:	89 c8                	mov    %ecx,%eax
  8020d6:	89 f2                	mov    %esi,%edx
  8020d8:	83 c4 1c             	add    $0x1c,%esp
  8020db:	5b                   	pop    %ebx
  8020dc:	5e                   	pop    %esi
  8020dd:	5f                   	pop    %edi
  8020de:	5d                   	pop    %ebp
  8020df:	c3                   	ret    
  8020e0:	3b 04 24             	cmp    (%esp),%eax
  8020e3:	72 06                	jb     8020eb <__umoddi3+0x113>
  8020e5:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  8020e9:	77 0f                	ja     8020fa <__umoddi3+0x122>
  8020eb:	89 f2                	mov    %esi,%edx
  8020ed:	29 f9                	sub    %edi,%ecx
  8020ef:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  8020f3:	89 14 24             	mov    %edx,(%esp)
  8020f6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8020fa:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020fe:	8b 14 24             	mov    (%esp),%edx
  802101:	83 c4 1c             	add    $0x1c,%esp
  802104:	5b                   	pop    %ebx
  802105:	5e                   	pop    %esi
  802106:	5f                   	pop    %edi
  802107:	5d                   	pop    %ebp
  802108:	c3                   	ret    
  802109:	8d 76 00             	lea    0x0(%esi),%esi
  80210c:	2b 04 24             	sub    (%esp),%eax
  80210f:	19 fa                	sbb    %edi,%edx
  802111:	89 d1                	mov    %edx,%ecx
  802113:	89 c6                	mov    %eax,%esi
  802115:	e9 71 ff ff ff       	jmp    80208b <__umoddi3+0xb3>
  80211a:	66 90                	xchg   %ax,%ax
  80211c:	39 44 24 04          	cmp    %eax,0x4(%esp)
  802120:	72 ea                	jb     80210c <__umoddi3+0x134>
  802122:	89 d9                	mov    %ebx,%ecx
  802124:	e9 62 ff ff ff       	jmp    80208b <__umoddi3+0xb3>
