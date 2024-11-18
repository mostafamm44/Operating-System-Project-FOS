
obj/user/tst_chan_one_master:     file format elf32-i386


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
  800031:	e8 99 01 00 00       	call   8001cf <libmain>
1:      jmp 1b
  800036:	eb fe                	jmp    800036 <args_exist+0x5>

00800038 <_main>:
// Master program: create and run slaves, wait them to finish
#include <inc/lib.h>

void
_main(void)
{
  800038:	55                   	push   %ebp
  800039:	89 e5                	mov    %esp,%ebp
  80003b:	83 ec 38             	sub    $0x38,%esp
	int envID = sys_getenvid();
  80003e:	e8 f2 17 00 00       	call   801835 <sys_getenvid>
  800043:	89 45 e8             	mov    %eax,-0x18(%ebp)
	char slavesCnt[10];
	readline("Enter the number of Slave Programs: ", slavesCnt);
  800046:	83 ec 08             	sub    $0x8,%esp
  800049:	8d 45 da             	lea    -0x26(%ebp),%eax
  80004c:	50                   	push   %eax
  80004d:	68 00 1f 80 00       	push   $0x801f00
  800052:	e8 00 0c 00 00       	call   800c57 <readline>
  800057:	83 c4 10             	add    $0x10,%esp
	int numOfSlaves = strtol(slavesCnt, NULL, 10);
  80005a:	83 ec 04             	sub    $0x4,%esp
  80005d:	6a 0a                	push   $0xa
  80005f:	6a 00                	push   $0x0
  800061:	8d 45 da             	lea    -0x26(%ebp),%eax
  800064:	50                   	push   %eax
  800065:	e8 55 11 00 00       	call   8011bf <strtol>
  80006a:	83 c4 10             	add    $0x10,%esp
  80006d:	89 45 f4             	mov    %eax,-0xc(%ebp)

	//Create and run slave programs that should sleep
	int id;
	for (int i = 0; i < numOfSlaves; ++i)
  800070:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800077:	eb 68                	jmp    8000e1 <_main+0xa9>
	{
		id = sys_create_env("tstChanOneSlave", (myEnv->page_WS_max_size),(myEnv->SecondListSize), (myEnv->percentage_of_WS_pages_to_be_removed));
  800079:	a1 04 30 80 00       	mov    0x803004,%eax
  80007e:	8b 90 80 05 00 00    	mov    0x580(%eax),%edx
  800084:	a1 04 30 80 00       	mov    0x803004,%eax
  800089:	8b 80 78 05 00 00    	mov    0x578(%eax),%eax
  80008f:	89 c1                	mov    %eax,%ecx
  800091:	a1 04 30 80 00       	mov    0x803004,%eax
  800096:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  80009c:	52                   	push   %edx
  80009d:	51                   	push   %ecx
  80009e:	50                   	push   %eax
  80009f:	68 25 1f 80 00       	push   $0x801f25
  8000a4:	e8 37 17 00 00       	call   8017e0 <sys_create_env>
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if (id== E_ENV_CREATION_ERROR)
  8000af:	83 7d e4 ef          	cmpl   $0xffffffef,-0x1c(%ebp)
  8000b3:	75 1b                	jne    8000d0 <_main+0x98>
		{
			cprintf("\n%~insufficient number of processes in the system! only %d slave processes are created\n", i);
  8000b5:	83 ec 08             	sub    $0x8,%esp
  8000b8:	ff 75 f0             	pushl  -0x10(%ebp)
  8000bb:	68 38 1f 80 00       	push   $0x801f38
  8000c0:	e8 fe 04 00 00       	call   8005c3 <cprintf>
  8000c5:	83 c4 10             	add    $0x10,%esp
			numOfSlaves = i;
  8000c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
			break;
  8000ce:	eb 19                	jmp    8000e9 <_main+0xb1>
		}
		sys_run_env(id);
  8000d0:	83 ec 0c             	sub    $0xc,%esp
  8000d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000d6:	e8 23 17 00 00       	call   8017fe <sys_run_env>
  8000db:	83 c4 10             	add    $0x10,%esp
	readline("Enter the number of Slave Programs: ", slavesCnt);
	int numOfSlaves = strtol(slavesCnt, NULL, 10);

	//Create and run slave programs that should sleep
	int id;
	for (int i = 0; i < numOfSlaves; ++i)
  8000de:	ff 45 f0             	incl   -0x10(%ebp)
  8000e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000e4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  8000e7:	7c 90                	jl     800079 <_main+0x41>
		}
		sys_run_env(id);
	}

	//Wait until all slaves are blocked
	int numOfBlockedProcesses = 0;
  8000e9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
	sys_utilities("__GetChanQueueSize__", (uint32)(&numOfBlockedProcesses));
  8000f0:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  8000f3:	83 ec 08             	sub    $0x8,%esp
  8000f6:	50                   	push   %eax
  8000f7:	68 90 1f 80 00       	push   $0x801f90
  8000fc:	e8 1c 1a 00 00       	call   801b1d <sys_utilities>
  800101:	83 c4 10             	add    $0x10,%esp
	int cnt = 0;
  800104:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	while (numOfBlockedProcesses != numOfSlaves)
  80010b:	eb 4a                	jmp    800157 <_main+0x11f>
	{
		env_sleep(1000);
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	68 e8 03 00 00       	push   $0x3e8
  800115:	e8 79 1a 00 00       	call   801b93 <env_sleep>
  80011a:	83 c4 10             	add    $0x10,%esp
		cnt++ ;
  80011d:	ff 45 ec             	incl   -0x14(%ebp)
		if (cnt == numOfSlaves)
  800120:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800123:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  800126:	75 1b                	jne    800143 <_main+0x10b>
		{
			panic("%~test channels failed! unexpected number of blocked slaves. Expected = %d, Current = %d", numOfSlaves, numOfBlockedProcesses);
  800128:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80012b:	83 ec 0c             	sub    $0xc,%esp
  80012e:	50                   	push   %eax
  80012f:	ff 75 f4             	pushl  -0xc(%ebp)
  800132:	68 a8 1f 80 00       	push   $0x801fa8
  800137:	6a 25                	push   $0x25
  800139:	68 01 20 80 00       	push   $0x802001
  80013e:	e8 c3 01 00 00       	call   800306 <_panic>
		}
		sys_utilities("__GetChanQueueSize__", (uint32)(&numOfBlockedProcesses));
  800143:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  800146:	83 ec 08             	sub    $0x8,%esp
  800149:	50                   	push   %eax
  80014a:	68 90 1f 80 00       	push   $0x801f90
  80014f:	e8 c9 19 00 00       	call   801b1d <sys_utilities>
  800154:	83 c4 10             	add    $0x10,%esp

	//Wait until all slaves are blocked
	int numOfBlockedProcesses = 0;
	sys_utilities("__GetChanQueueSize__", (uint32)(&numOfBlockedProcesses));
	int cnt = 0;
	while (numOfBlockedProcesses != numOfSlaves)
  800157:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80015a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  80015d:	75 ae                	jne    80010d <_main+0xd5>
			panic("%~test channels failed! unexpected number of blocked slaves. Expected = %d, Current = %d", numOfSlaves, numOfBlockedProcesses);
		}
		sys_utilities("__GetChanQueueSize__", (uint32)(&numOfBlockedProcesses));
	}

	rsttst();
  80015f:	e8 c8 17 00 00       	call   80192c <rsttst>

	//Wakeup one
	sys_utilities("__WakeupOne__", 0);
  800164:	83 ec 08             	sub    $0x8,%esp
  800167:	6a 00                	push   $0x0
  800169:	68 1c 20 80 00       	push   $0x80201c
  80016e:	e8 aa 19 00 00       	call   801b1d <sys_utilities>
  800173:	83 c4 10             	add    $0x10,%esp

	//Wait until all slave finished
	cnt = 0;
  800176:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	while (gettst() != numOfSlaves)
  80017d:	eb 2f                	jmp    8001ae <_main+0x176>
	{
		env_sleep(5000);
  80017f:	83 ec 0c             	sub    $0xc,%esp
  800182:	68 88 13 00 00       	push   $0x1388
  800187:	e8 07 1a 00 00       	call   801b93 <env_sleep>
  80018c:	83 c4 10             	add    $0x10,%esp
		cnt++ ;
  80018f:	ff 45 ec             	incl   -0x14(%ebp)
		if (cnt == numOfSlaves)
  800192:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800195:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  800198:	75 14                	jne    8001ae <_main+0x176>
		{
			panic("%~test channels failed! not all slaves finished");
  80019a:	83 ec 04             	sub    $0x4,%esp
  80019d:	68 2c 20 80 00       	push   $0x80202c
  8001a2:	6a 37                	push   $0x37
  8001a4:	68 01 20 80 00       	push   $0x802001
  8001a9:	e8 58 01 00 00       	call   800306 <_panic>
	//Wakeup one
	sys_utilities("__WakeupOne__", 0);

	//Wait until all slave finished
	cnt = 0;
	while (gettst() != numOfSlaves)
  8001ae:	e8 f3 17 00 00       	call   8019a6 <gettst>
  8001b3:	89 c2                	mov    %eax,%edx
  8001b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001b8:	39 c2                	cmp    %eax,%edx
  8001ba:	75 c3                	jne    80017f <_main+0x147>
		{
			panic("%~test channels failed! not all slaves finished");
		}
	}

	cprintf("Congratulations!! Test of Channel (sleep & wakeup ONE) completed successfully!!\n\n\n");
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	68 5c 20 80 00       	push   $0x80205c
  8001c4:	e8 fa 03 00 00       	call   8005c3 <cprintf>
  8001c9:	83 c4 10             	add    $0x10,%esp

	return;
  8001cc:	90                   	nop
}
  8001cd:	c9                   	leave  
  8001ce:	c3                   	ret    

008001cf <libmain>:

volatile struct Env *myEnv = NULL;
volatile char *binaryname = "(PROGRAM NAME UNKNOWN)";
void
libmain(int argc, char **argv)
{
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	83 ec 18             	sub    $0x18,%esp
	int envIndex = sys_getenvindex();
  8001d5:	e8 74 16 00 00       	call   80184e <sys_getenvindex>
  8001da:	89 45 f4             	mov    %eax,-0xc(%ebp)

	myEnv = &(envs[envIndex]);
  8001dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8001e0:	89 d0                	mov    %edx,%eax
  8001e2:	c1 e0 02             	shl    $0x2,%eax
  8001e5:	01 d0                	add    %edx,%eax
  8001e7:	01 c0                	add    %eax,%eax
  8001e9:	01 d0                	add    %edx,%eax
  8001eb:	c1 e0 02             	shl    $0x2,%eax
  8001ee:	01 d0                	add    %edx,%eax
  8001f0:	01 c0                	add    %eax,%eax
  8001f2:	01 d0                	add    %edx,%eax
  8001f4:	c1 e0 04             	shl    $0x4,%eax
  8001f7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001fc:	a3 04 30 80 00       	mov    %eax,0x803004

	//SET THE PROGRAM NAME
	if (myEnv->prog_name[0] != '\0')
  800201:	a1 04 30 80 00       	mov    0x803004,%eax
  800206:	8a 40 20             	mov    0x20(%eax),%al
  800209:	84 c0                	test   %al,%al
  80020b:	74 0d                	je     80021a <libmain+0x4b>
		binaryname = myEnv->prog_name;
  80020d:	a1 04 30 80 00       	mov    0x803004,%eax
  800212:	83 c0 20             	add    $0x20,%eax
  800215:	a3 00 30 80 00       	mov    %eax,0x803000

	// set env to point at our env structure in envs[].
	// env = envs;

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80021a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80021e:	7e 0a                	jle    80022a <libmain+0x5b>
		binaryname = argv[0];
  800220:	8b 45 0c             	mov    0xc(%ebp),%eax
  800223:	8b 00                	mov    (%eax),%eax
  800225:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	_main(argc, argv);
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	ff 75 0c             	pushl  0xc(%ebp)
  800230:	ff 75 08             	pushl  0x8(%ebp)
  800233:	e8 00 fe ff ff       	call   800038 <_main>
  800238:	83 c4 10             	add    $0x10,%esp



	//	sys_lock_cons();
	sys_lock_cons();
  80023b:	e8 92 13 00 00       	call   8015d2 <sys_lock_cons>
	{
		cprintf("**************************************\n");
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	68 c8 20 80 00       	push   $0x8020c8
  800248:	e8 76 03 00 00       	call   8005c3 <cprintf>
  80024d:	83 c4 10             	add    $0x10,%esp
		cprintf("Num of PAGE faults = %d, modif = %d\n", myEnv->pageFaultsCounter, myEnv->nModifiedPages);
  800250:	a1 04 30 80 00       	mov    0x803004,%eax
  800255:	8b 90 94 05 00 00    	mov    0x594(%eax),%edx
  80025b:	a1 04 30 80 00       	mov    0x803004,%eax
  800260:	8b 80 84 05 00 00    	mov    0x584(%eax),%eax
  800266:	83 ec 04             	sub    $0x4,%esp
  800269:	52                   	push   %edx
  80026a:	50                   	push   %eax
  80026b:	68 f0 20 80 00       	push   $0x8020f0
  800270:	e8 4e 03 00 00       	call   8005c3 <cprintf>
  800275:	83 c4 10             	add    $0x10,%esp
		cprintf("# PAGE IN (from disk) = %d, # PAGE OUT (on disk) = %d, # NEW PAGE ADDED (on disk) = %d\n", myEnv->nPageIn, myEnv->nPageOut,myEnv->nNewPageAdded);
  800278:	a1 04 30 80 00       	mov    0x803004,%eax
  80027d:	8b 88 a8 05 00 00    	mov    0x5a8(%eax),%ecx
  800283:	a1 04 30 80 00       	mov    0x803004,%eax
  800288:	8b 90 a4 05 00 00    	mov    0x5a4(%eax),%edx
  80028e:	a1 04 30 80 00       	mov    0x803004,%eax
  800293:	8b 80 a0 05 00 00    	mov    0x5a0(%eax),%eax
  800299:	51                   	push   %ecx
  80029a:	52                   	push   %edx
  80029b:	50                   	push   %eax
  80029c:	68 18 21 80 00       	push   $0x802118
  8002a1:	e8 1d 03 00 00       	call   8005c3 <cprintf>
  8002a6:	83 c4 10             	add    $0x10,%esp
		//cprintf("Num of freeing scarce memory = %d, freeing full working set = %d\n", myEnv->freeingScarceMemCounter, myEnv->freeingFullWSCounter);
		cprintf("Num of clocks = %d\n", myEnv->nClocks);
  8002a9:	a1 04 30 80 00       	mov    0x803004,%eax
  8002ae:	8b 80 ac 05 00 00    	mov    0x5ac(%eax),%eax
  8002b4:	83 ec 08             	sub    $0x8,%esp
  8002b7:	50                   	push   %eax
  8002b8:	68 70 21 80 00       	push   $0x802170
  8002bd:	e8 01 03 00 00       	call   8005c3 <cprintf>
  8002c2:	83 c4 10             	add    $0x10,%esp
		cprintf("**************************************\n");
  8002c5:	83 ec 0c             	sub    $0xc,%esp
  8002c8:	68 c8 20 80 00       	push   $0x8020c8
  8002cd:	e8 f1 02 00 00       	call   8005c3 <cprintf>
  8002d2:	83 c4 10             	add    $0x10,%esp
	}
	sys_unlock_cons();
  8002d5:	e8 12 13 00 00       	call   8015ec <sys_unlock_cons>
//	sys_unlock_cons();

	// exit gracefully
	exit();
  8002da:	e8 19 00 00 00       	call   8002f8 <exit>
}
  8002df:	90                   	nop
  8002e0:	c9                   	leave  
  8002e1:	c3                   	ret    

008002e2 <destroy>:

#include <inc/lib.h>

void
destroy(void)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	83 ec 08             	sub    $0x8,%esp
	sys_destroy_env(0);
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	6a 00                	push   $0x0
  8002ed:	e8 28 15 00 00       	call   80181a <sys_destroy_env>
  8002f2:	83 c4 10             	add    $0x10,%esp
}
  8002f5:	90                   	nop
  8002f6:	c9                   	leave  
  8002f7:	c3                   	ret    

008002f8 <exit>:

void
exit(void)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 08             	sub    $0x8,%esp
	sys_exit_env();
  8002fe:	e8 7d 15 00 00       	call   801880 <sys_exit_env>
}
  800303:	90                   	nop
  800304:	c9                   	leave  
  800305:	c3                   	ret    

00800306 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes FOS to enter the FOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	va_start(ap, fmt);
  80030c:	8d 45 10             	lea    0x10(%ebp),%eax
  80030f:	83 c0 04             	add    $0x4,%eax
  800312:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// Print the panic message
	if (argv0)
  800315:	a1 24 30 80 00       	mov    0x803024,%eax
  80031a:	85 c0                	test   %eax,%eax
  80031c:	74 16                	je     800334 <_panic+0x2e>
		cprintf("%s: ", argv0);
  80031e:	a1 24 30 80 00       	mov    0x803024,%eax
  800323:	83 ec 08             	sub    $0x8,%esp
  800326:	50                   	push   %eax
  800327:	68 84 21 80 00       	push   $0x802184
  80032c:	e8 92 02 00 00       	call   8005c3 <cprintf>
  800331:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800334:	a1 00 30 80 00       	mov    0x803000,%eax
  800339:	ff 75 0c             	pushl  0xc(%ebp)
  80033c:	ff 75 08             	pushl  0x8(%ebp)
  80033f:	50                   	push   %eax
  800340:	68 89 21 80 00       	push   $0x802189
  800345:	e8 79 02 00 00       	call   8005c3 <cprintf>
  80034a:	83 c4 10             	add    $0x10,%esp
	vcprintf(fmt, ap);
  80034d:	8b 45 10             	mov    0x10(%ebp),%eax
  800350:	83 ec 08             	sub    $0x8,%esp
  800353:	ff 75 f4             	pushl  -0xc(%ebp)
  800356:	50                   	push   %eax
  800357:	e8 fc 01 00 00       	call   800558 <vcprintf>
  80035c:	83 c4 10             	add    $0x10,%esp
	vcprintf("\n", NULL);
  80035f:	83 ec 08             	sub    $0x8,%esp
  800362:	6a 00                	push   $0x0
  800364:	68 a5 21 80 00       	push   $0x8021a5
  800369:	e8 ea 01 00 00       	call   800558 <vcprintf>
  80036e:	83 c4 10             	add    $0x10,%esp
	// Cause a breakpoint exception
//	while (1);
//		asm volatile("int3");

	//2013: exit the panic env only
	exit() ;
  800371:	e8 82 ff ff ff       	call   8002f8 <exit>

	// should not return here
	while (1) ;
  800376:	eb fe                	jmp    800376 <_panic+0x70>

00800378 <CheckWSArrayWithoutLastIndex>:
}

void CheckWSArrayWithoutLastIndex(uint32 *expectedPages, int arraySize)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	83 ec 28             	sub    $0x28,%esp
	if (arraySize != myEnv->page_WS_max_size)
  80037e:	a1 04 30 80 00       	mov    0x803004,%eax
  800383:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
  800389:	8b 45 0c             	mov    0xc(%ebp),%eax
  80038c:	39 c2                	cmp    %eax,%edx
  80038e:	74 14                	je     8003a4 <CheckWSArrayWithoutLastIndex+0x2c>
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
  800390:	83 ec 04             	sub    $0x4,%esp
  800393:	68 a8 21 80 00       	push   $0x8021a8
  800398:	6a 26                	push   $0x26
  80039a:	68 f4 21 80 00       	push   $0x8021f4
  80039f:	e8 62 ff ff ff       	call   800306 <_panic>
	}
	int expectedNumOfEmptyLocs = 0;
  8003a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	for (int e = 0; e < arraySize; e++) {
  8003ab:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8003b2:	e9 c5 00 00 00       	jmp    80047c <CheckWSArrayWithoutLastIndex+0x104>
		if (expectedPages[e] == 0) {
  8003b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8003ba:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8003c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c4:	01 d0                	add    %edx,%eax
  8003c6:	8b 00                	mov    (%eax),%eax
  8003c8:	85 c0                	test   %eax,%eax
  8003ca:	75 08                	jne    8003d4 <CheckWSArrayWithoutLastIndex+0x5c>
			expectedNumOfEmptyLocs++;
  8003cc:	ff 45 f4             	incl   -0xc(%ebp)
			continue;
  8003cf:	e9 a5 00 00 00       	jmp    800479 <CheckWSArrayWithoutLastIndex+0x101>
		}
		int found = 0;
  8003d4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  8003db:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  8003e2:	eb 69                	jmp    80044d <CheckWSArrayWithoutLastIndex+0xd5>
			if (myEnv->__uptr_pws[w].empty == 0) {
  8003e4:	a1 04 30 80 00       	mov    0x803004,%eax
  8003e9:	8b 88 7c 05 00 00    	mov    0x57c(%eax),%ecx
  8003ef:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8003f2:	89 d0                	mov    %edx,%eax
  8003f4:	01 c0                	add    %eax,%eax
  8003f6:	01 d0                	add    %edx,%eax
  8003f8:	c1 e0 03             	shl    $0x3,%eax
  8003fb:	01 c8                	add    %ecx,%eax
  8003fd:	8a 40 04             	mov    0x4(%eax),%al
  800400:	84 c0                	test   %al,%al
  800402:	75 46                	jne    80044a <CheckWSArrayWithoutLastIndex+0xd2>
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  800404:	a1 04 30 80 00       	mov    0x803004,%eax
  800409:	8b 88 7c 05 00 00    	mov    0x57c(%eax),%ecx
  80040f:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800412:	89 d0                	mov    %edx,%eax
  800414:	01 c0                	add    %eax,%eax
  800416:	01 d0                	add    %edx,%eax
  800418:	c1 e0 03             	shl    $0x3,%eax
  80041b:	01 c8                	add    %ecx,%eax
  80041d:	8b 00                	mov    (%eax),%eax
  80041f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800422:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800425:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80042a:	89 c2                	mov    %eax,%edx
						== expectedPages[e]) {
  80042c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80042f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  800436:	8b 45 08             	mov    0x8(%ebp),%eax
  800439:	01 c8                	add    %ecx,%eax
  80043b:	8b 00                	mov    (%eax),%eax
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
			if (myEnv->__uptr_pws[w].empty == 0) {
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  80043d:	39 c2                	cmp    %eax,%edx
  80043f:	75 09                	jne    80044a <CheckWSArrayWithoutLastIndex+0xd2>
						== expectedPages[e]) {
					found = 1;
  800441:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
					break;
  800448:	eb 15                	jmp    80045f <CheckWSArrayWithoutLastIndex+0xe7>
		if (expectedPages[e] == 0) {
			expectedNumOfEmptyLocs++;
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  80044a:	ff 45 e8             	incl   -0x18(%ebp)
  80044d:	a1 04 30 80 00       	mov    0x803004,%eax
  800452:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
  800458:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80045b:	39 c2                	cmp    %eax,%edx
  80045d:	77 85                	ja     8003e4 <CheckWSArrayWithoutLastIndex+0x6c>
					found = 1;
					break;
				}
			}
		}
		if (!found)
  80045f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800463:	75 14                	jne    800479 <CheckWSArrayWithoutLastIndex+0x101>
			panic(
  800465:	83 ec 04             	sub    $0x4,%esp
  800468:	68 00 22 80 00       	push   $0x802200
  80046d:	6a 3a                	push   $0x3a
  80046f:	68 f4 21 80 00       	push   $0x8021f4
  800474:	e8 8d fe ff ff       	call   800306 <_panic>
	if (arraySize != myEnv->page_WS_max_size)
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
	}
	int expectedNumOfEmptyLocs = 0;
	for (int e = 0; e < arraySize; e++) {
  800479:	ff 45 f0             	incl   -0x10(%ebp)
  80047c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80047f:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800482:	0f 8c 2f ff ff ff    	jl     8003b7 <CheckWSArrayWithoutLastIndex+0x3f>
		}
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
  800488:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  80048f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800496:	eb 26                	jmp    8004be <CheckWSArrayWithoutLastIndex+0x146>
		if (myEnv->__uptr_pws[w].empty == 1) {
  800498:	a1 04 30 80 00       	mov    0x803004,%eax
  80049d:	8b 88 7c 05 00 00    	mov    0x57c(%eax),%ecx
  8004a3:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004a6:	89 d0                	mov    %edx,%eax
  8004a8:	01 c0                	add    %eax,%eax
  8004aa:	01 d0                	add    %edx,%eax
  8004ac:	c1 e0 03             	shl    $0x3,%eax
  8004af:	01 c8                	add    %ecx,%eax
  8004b1:	8a 40 04             	mov    0x4(%eax),%al
  8004b4:	3c 01                	cmp    $0x1,%al
  8004b6:	75 03                	jne    8004bb <CheckWSArrayWithoutLastIndex+0x143>
			actualNumOfEmptyLocs++;
  8004b8:	ff 45 e4             	incl   -0x1c(%ebp)
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  8004bb:	ff 45 e0             	incl   -0x20(%ebp)
  8004be:	a1 04 30 80 00       	mov    0x803004,%eax
  8004c3:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
  8004c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004cc:	39 c2                	cmp    %eax,%edx
  8004ce:	77 c8                	ja     800498 <CheckWSArrayWithoutLastIndex+0x120>
		if (myEnv->__uptr_pws[w].empty == 1) {
			actualNumOfEmptyLocs++;
		}
	}
	if (expectedNumOfEmptyLocs != actualNumOfEmptyLocs)
  8004d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004d3:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  8004d6:	74 14                	je     8004ec <CheckWSArrayWithoutLastIndex+0x174>
		panic(
  8004d8:	83 ec 04             	sub    $0x4,%esp
  8004db:	68 54 22 80 00       	push   $0x802254
  8004e0:	6a 44                	push   $0x44
  8004e2:	68 f4 21 80 00       	push   $0x8021f4
  8004e7:	e8 1a fe ff ff       	call   800306 <_panic>
				"PAGE WS entry checking failed... number of empty locations is not correct");
}
  8004ec:	90                   	nop
  8004ed:	c9                   	leave  
  8004ee:	c3                   	ret    

008004ef <putch>:
	int idx; // current buffer index
	int cnt; // total bytes printed so far
	char buf[256];
};

static void putch(int ch, struct printbuf *b) {
  8004ef:	55                   	push   %ebp
  8004f0:	89 e5                	mov    %esp,%ebp
  8004f2:	83 ec 08             	sub    $0x8,%esp
	b->buf[b->idx++] = ch;
  8004f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f8:	8b 00                	mov    (%eax),%eax
  8004fa:	8d 48 01             	lea    0x1(%eax),%ecx
  8004fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800500:	89 0a                	mov    %ecx,(%edx)
  800502:	8b 55 08             	mov    0x8(%ebp),%edx
  800505:	88 d1                	mov    %dl,%cl
  800507:	8b 55 0c             	mov    0xc(%ebp),%edx
  80050a:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256 - 1) {
  80050e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800511:	8b 00                	mov    (%eax),%eax
  800513:	3d ff 00 00 00       	cmp    $0xff,%eax
  800518:	75 2c                	jne    800546 <putch+0x57>
		sys_cputs(b->buf, b->idx, printProgName);
  80051a:	a0 08 30 80 00       	mov    0x803008,%al
  80051f:	0f b6 c0             	movzbl %al,%eax
  800522:	8b 55 0c             	mov    0xc(%ebp),%edx
  800525:	8b 12                	mov    (%edx),%edx
  800527:	89 d1                	mov    %edx,%ecx
  800529:	8b 55 0c             	mov    0xc(%ebp),%edx
  80052c:	83 c2 08             	add    $0x8,%edx
  80052f:	83 ec 04             	sub    $0x4,%esp
  800532:	50                   	push   %eax
  800533:	51                   	push   %ecx
  800534:	52                   	push   %edx
  800535:	e8 56 10 00 00       	call   801590 <sys_cputs>
  80053a:	83 c4 10             	add    $0x10,%esp
		b->idx = 0;
  80053d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800540:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800546:	8b 45 0c             	mov    0xc(%ebp),%eax
  800549:	8b 40 04             	mov    0x4(%eax),%eax
  80054c:	8d 50 01             	lea    0x1(%eax),%edx
  80054f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800552:	89 50 04             	mov    %edx,0x4(%eax)
}
  800555:	90                   	nop
  800556:	c9                   	leave  
  800557:	c3                   	ret    

00800558 <vcprintf>:

int vcprintf(const char *fmt, va_list ap) {
  800558:	55                   	push   %ebp
  800559:	89 e5                	mov    %esp,%ebp
  80055b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800561:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800568:	00 00 00 
	b.cnt = 0;
  80056b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800572:	00 00 00 
	vprintfmt((void*) putch, &b, fmt, ap);
  800575:	ff 75 0c             	pushl  0xc(%ebp)
  800578:	ff 75 08             	pushl  0x8(%ebp)
  80057b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800581:	50                   	push   %eax
  800582:	68 ef 04 80 00       	push   $0x8004ef
  800587:	e8 11 02 00 00       	call   80079d <vprintfmt>
  80058c:	83 c4 10             	add    $0x10,%esp
	sys_cputs(b.buf, b.idx, printProgName);
  80058f:	a0 08 30 80 00       	mov    0x803008,%al
  800594:	0f b6 c0             	movzbl %al,%eax
  800597:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
  80059d:	83 ec 04             	sub    $0x4,%esp
  8005a0:	50                   	push   %eax
  8005a1:	52                   	push   %edx
  8005a2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005a8:	83 c0 08             	add    $0x8,%eax
  8005ab:	50                   	push   %eax
  8005ac:	e8 df 0f 00 00       	call   801590 <sys_cputs>
  8005b1:	83 c4 10             	add    $0x10,%esp

	printProgName = 0;
  8005b4:	c6 05 08 30 80 00 00 	movb   $0x0,0x803008
	return b.cnt;
  8005bb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8005c1:	c9                   	leave  
  8005c2:	c3                   	ret    

008005c3 <cprintf>:

//%@: to print the program name and ID before the message
//%~: to print the message directly
int cprintf(const char *fmt, ...) {
  8005c3:	55                   	push   %ebp
  8005c4:	89 e5                	mov    %esp,%ebp
  8005c6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;
	printProgName = 1 ;
  8005c9:	c6 05 08 30 80 00 01 	movb   $0x1,0x803008
	va_start(ap, fmt);
  8005d0:	8d 45 0c             	lea    0xc(%ebp),%eax
  8005d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
  8005d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d9:	83 ec 08             	sub    $0x8,%esp
  8005dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8005df:	50                   	push   %eax
  8005e0:	e8 73 ff ff ff       	call   800558 <vcprintf>
  8005e5:	83 c4 10             	add    $0x10,%esp
  8005e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return cnt;
  8005eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8005ee:	c9                   	leave  
  8005ef:	c3                   	ret    

008005f0 <atomic_cprintf>:

//%@: to print the program name and ID before the message
//%~: to print the message directly
int atomic_cprintf(const char *fmt, ...)
{
  8005f0:	55                   	push   %ebp
  8005f1:	89 e5                	mov    %esp,%ebp
  8005f3:	83 ec 18             	sub    $0x18,%esp
	int cnt;
	sys_lock_cons();
  8005f6:	e8 d7 0f 00 00       	call   8015d2 <sys_lock_cons>
	{
		va_list ap;
		va_start(ap, fmt);
  8005fb:	8d 45 0c             	lea    0xc(%ebp),%eax
  8005fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
		cnt = vcprintf(fmt, ap);
  800601:	8b 45 08             	mov    0x8(%ebp),%eax
  800604:	83 ec 08             	sub    $0x8,%esp
  800607:	ff 75 f4             	pushl  -0xc(%ebp)
  80060a:	50                   	push   %eax
  80060b:	e8 48 ff ff ff       	call   800558 <vcprintf>
  800610:	83 c4 10             	add    $0x10,%esp
  800613:	89 45 f0             	mov    %eax,-0x10(%ebp)
		va_end(ap);
	}
	sys_unlock_cons();
  800616:	e8 d1 0f 00 00       	call   8015ec <sys_unlock_cons>
	return cnt;
  80061b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  80061e:	c9                   	leave  
  80061f:	c3                   	ret    

00800620 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800620:	55                   	push   %ebp
  800621:	89 e5                	mov    %esp,%ebp
  800623:	53                   	push   %ebx
  800624:	83 ec 14             	sub    $0x14,%esp
  800627:	8b 45 10             	mov    0x10(%ebp),%eax
  80062a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800633:	8b 45 18             	mov    0x18(%ebp),%eax
  800636:	ba 00 00 00 00       	mov    $0x0,%edx
  80063b:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80063e:	77 55                	ja     800695 <printnum+0x75>
  800640:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800643:	72 05                	jb     80064a <printnum+0x2a>
  800645:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800648:	77 4b                	ja     800695 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80064a:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80064d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800650:	8b 45 18             	mov    0x18(%ebp),%eax
  800653:	ba 00 00 00 00       	mov    $0x0,%edx
  800658:	52                   	push   %edx
  800659:	50                   	push   %eax
  80065a:	ff 75 f4             	pushl  -0xc(%ebp)
  80065d:	ff 75 f0             	pushl  -0x10(%ebp)
  800660:	e8 1f 16 00 00       	call   801c84 <__udivdi3>
  800665:	83 c4 10             	add    $0x10,%esp
  800668:	83 ec 04             	sub    $0x4,%esp
  80066b:	ff 75 20             	pushl  0x20(%ebp)
  80066e:	53                   	push   %ebx
  80066f:	ff 75 18             	pushl  0x18(%ebp)
  800672:	52                   	push   %edx
  800673:	50                   	push   %eax
  800674:	ff 75 0c             	pushl  0xc(%ebp)
  800677:	ff 75 08             	pushl  0x8(%ebp)
  80067a:	e8 a1 ff ff ff       	call   800620 <printnum>
  80067f:	83 c4 20             	add    $0x20,%esp
  800682:	eb 1a                	jmp    80069e <printnum+0x7e>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800684:	83 ec 08             	sub    $0x8,%esp
  800687:	ff 75 0c             	pushl  0xc(%ebp)
  80068a:	ff 75 20             	pushl  0x20(%ebp)
  80068d:	8b 45 08             	mov    0x8(%ebp),%eax
  800690:	ff d0                	call   *%eax
  800692:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800695:	ff 4d 1c             	decl   0x1c(%ebp)
  800698:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  80069c:	7f e6                	jg     800684 <printnum+0x64>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80069e:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8006a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006ac:	53                   	push   %ebx
  8006ad:	51                   	push   %ecx
  8006ae:	52                   	push   %edx
  8006af:	50                   	push   %eax
  8006b0:	e8 df 16 00 00       	call   801d94 <__umoddi3>
  8006b5:	83 c4 10             	add    $0x10,%esp
  8006b8:	05 b4 24 80 00       	add    $0x8024b4,%eax
  8006bd:	8a 00                	mov    (%eax),%al
  8006bf:	0f be c0             	movsbl %al,%eax
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	ff 75 0c             	pushl  0xc(%ebp)
  8006c8:	50                   	push   %eax
  8006c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cc:	ff d0                	call   *%eax
  8006ce:	83 c4 10             	add    $0x10,%esp
}
  8006d1:	90                   	nop
  8006d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006d5:	c9                   	leave  
  8006d6:	c3                   	ret    

008006d7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006da:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006de:	7e 1c                	jle    8006fc <getuint+0x25>
		return va_arg(*ap, unsigned long long);
  8006e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e3:	8b 00                	mov    (%eax),%eax
  8006e5:	8d 50 08             	lea    0x8(%eax),%edx
  8006e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006eb:	89 10                	mov    %edx,(%eax)
  8006ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f0:	8b 00                	mov    (%eax),%eax
  8006f2:	83 e8 08             	sub    $0x8,%eax
  8006f5:	8b 50 04             	mov    0x4(%eax),%edx
  8006f8:	8b 00                	mov    (%eax),%eax
  8006fa:	eb 40                	jmp    80073c <getuint+0x65>
	else if (lflag)
  8006fc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800700:	74 1e                	je     800720 <getuint+0x49>
		return va_arg(*ap, unsigned long);
  800702:	8b 45 08             	mov    0x8(%ebp),%eax
  800705:	8b 00                	mov    (%eax),%eax
  800707:	8d 50 04             	lea    0x4(%eax),%edx
  80070a:	8b 45 08             	mov    0x8(%ebp),%eax
  80070d:	89 10                	mov    %edx,(%eax)
  80070f:	8b 45 08             	mov    0x8(%ebp),%eax
  800712:	8b 00                	mov    (%eax),%eax
  800714:	83 e8 04             	sub    $0x4,%eax
  800717:	8b 00                	mov    (%eax),%eax
  800719:	ba 00 00 00 00       	mov    $0x0,%edx
  80071e:	eb 1c                	jmp    80073c <getuint+0x65>
	else
		return va_arg(*ap, unsigned int);
  800720:	8b 45 08             	mov    0x8(%ebp),%eax
  800723:	8b 00                	mov    (%eax),%eax
  800725:	8d 50 04             	lea    0x4(%eax),%edx
  800728:	8b 45 08             	mov    0x8(%ebp),%eax
  80072b:	89 10                	mov    %edx,(%eax)
  80072d:	8b 45 08             	mov    0x8(%ebp),%eax
  800730:	8b 00                	mov    (%eax),%eax
  800732:	83 e8 04             	sub    $0x4,%eax
  800735:	8b 00                	mov    (%eax),%eax
  800737:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80073c:	5d                   	pop    %ebp
  80073d:	c3                   	ret    

0080073e <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800741:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800745:	7e 1c                	jle    800763 <getint+0x25>
		return va_arg(*ap, long long);
  800747:	8b 45 08             	mov    0x8(%ebp),%eax
  80074a:	8b 00                	mov    (%eax),%eax
  80074c:	8d 50 08             	lea    0x8(%eax),%edx
  80074f:	8b 45 08             	mov    0x8(%ebp),%eax
  800752:	89 10                	mov    %edx,(%eax)
  800754:	8b 45 08             	mov    0x8(%ebp),%eax
  800757:	8b 00                	mov    (%eax),%eax
  800759:	83 e8 08             	sub    $0x8,%eax
  80075c:	8b 50 04             	mov    0x4(%eax),%edx
  80075f:	8b 00                	mov    (%eax),%eax
  800761:	eb 38                	jmp    80079b <getint+0x5d>
	else if (lflag)
  800763:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800767:	74 1a                	je     800783 <getint+0x45>
		return va_arg(*ap, long);
  800769:	8b 45 08             	mov    0x8(%ebp),%eax
  80076c:	8b 00                	mov    (%eax),%eax
  80076e:	8d 50 04             	lea    0x4(%eax),%edx
  800771:	8b 45 08             	mov    0x8(%ebp),%eax
  800774:	89 10                	mov    %edx,(%eax)
  800776:	8b 45 08             	mov    0x8(%ebp),%eax
  800779:	8b 00                	mov    (%eax),%eax
  80077b:	83 e8 04             	sub    $0x4,%eax
  80077e:	8b 00                	mov    (%eax),%eax
  800780:	99                   	cltd   
  800781:	eb 18                	jmp    80079b <getint+0x5d>
	else
		return va_arg(*ap, int);
  800783:	8b 45 08             	mov    0x8(%ebp),%eax
  800786:	8b 00                	mov    (%eax),%eax
  800788:	8d 50 04             	lea    0x4(%eax),%edx
  80078b:	8b 45 08             	mov    0x8(%ebp),%eax
  80078e:	89 10                	mov    %edx,(%eax)
  800790:	8b 45 08             	mov    0x8(%ebp),%eax
  800793:	8b 00                	mov    (%eax),%eax
  800795:	83 e8 04             	sub    $0x4,%eax
  800798:	8b 00                	mov    (%eax),%eax
  80079a:	99                   	cltd   
}
  80079b:	5d                   	pop    %ebp
  80079c:	c3                   	ret    

0080079d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	56                   	push   %esi
  8007a1:	53                   	push   %ebx
  8007a2:	83 ec 20             	sub    $0x20,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007a5:	eb 17                	jmp    8007be <vprintfmt+0x21>
			if (ch == '\0')
  8007a7:	85 db                	test   %ebx,%ebx
  8007a9:	0f 84 c1 03 00 00    	je     800b70 <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  8007af:	83 ec 08             	sub    $0x8,%esp
  8007b2:	ff 75 0c             	pushl  0xc(%ebp)
  8007b5:	53                   	push   %ebx
  8007b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b9:	ff d0                	call   *%eax
  8007bb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007be:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c1:	8d 50 01             	lea    0x1(%eax),%edx
  8007c4:	89 55 10             	mov    %edx,0x10(%ebp)
  8007c7:	8a 00                	mov    (%eax),%al
  8007c9:	0f b6 d8             	movzbl %al,%ebx
  8007cc:	83 fb 25             	cmp    $0x25,%ebx
  8007cf:	75 d6                	jne    8007a7 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8007d1:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8007d5:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8007dc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8007e3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8007ea:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f4:	8d 50 01             	lea    0x1(%eax),%edx
  8007f7:	89 55 10             	mov    %edx,0x10(%ebp)
  8007fa:	8a 00                	mov    (%eax),%al
  8007fc:	0f b6 d8             	movzbl %al,%ebx
  8007ff:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800802:	83 f8 5b             	cmp    $0x5b,%eax
  800805:	0f 87 3d 03 00 00    	ja     800b48 <vprintfmt+0x3ab>
  80080b:	8b 04 85 d8 24 80 00 	mov    0x8024d8(,%eax,4),%eax
  800812:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800814:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800818:	eb d7                	jmp    8007f1 <vprintfmt+0x54>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80081a:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80081e:	eb d1                	jmp    8007f1 <vprintfmt+0x54>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800820:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800827:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80082a:	89 d0                	mov    %edx,%eax
  80082c:	c1 e0 02             	shl    $0x2,%eax
  80082f:	01 d0                	add    %edx,%eax
  800831:	01 c0                	add    %eax,%eax
  800833:	01 d8                	add    %ebx,%eax
  800835:	83 e8 30             	sub    $0x30,%eax
  800838:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  80083b:	8b 45 10             	mov    0x10(%ebp),%eax
  80083e:	8a 00                	mov    (%eax),%al
  800840:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800843:	83 fb 2f             	cmp    $0x2f,%ebx
  800846:	7e 3e                	jle    800886 <vprintfmt+0xe9>
  800848:	83 fb 39             	cmp    $0x39,%ebx
  80084b:	7f 39                	jg     800886 <vprintfmt+0xe9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80084d:	ff 45 10             	incl   0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800850:	eb d5                	jmp    800827 <vprintfmt+0x8a>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800852:	8b 45 14             	mov    0x14(%ebp),%eax
  800855:	83 c0 04             	add    $0x4,%eax
  800858:	89 45 14             	mov    %eax,0x14(%ebp)
  80085b:	8b 45 14             	mov    0x14(%ebp),%eax
  80085e:	83 e8 04             	sub    $0x4,%eax
  800861:	8b 00                	mov    (%eax),%eax
  800863:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800866:	eb 1f                	jmp    800887 <vprintfmt+0xea>

		case '.':
			if (width < 0)
  800868:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80086c:	79 83                	jns    8007f1 <vprintfmt+0x54>
				width = 0;
  80086e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800875:	e9 77 ff ff ff       	jmp    8007f1 <vprintfmt+0x54>

		case '#':
			altflag = 1;
  80087a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800881:	e9 6b ff ff ff       	jmp    8007f1 <vprintfmt+0x54>
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto process_precision;
  800886:	90                   	nop
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800887:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80088b:	0f 89 60 ff ff ff    	jns    8007f1 <vprintfmt+0x54>
				width = precision, precision = -1;
  800891:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800894:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800897:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80089e:	e9 4e ff ff ff       	jmp    8007f1 <vprintfmt+0x54>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008a3:	ff 45 e8             	incl   -0x18(%ebp)
			goto reswitch;
  8008a6:	e9 46 ff ff ff       	jmp    8007f1 <vprintfmt+0x54>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ae:	83 c0 04             	add    $0x4,%eax
  8008b1:	89 45 14             	mov    %eax,0x14(%ebp)
  8008b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b7:	83 e8 04             	sub    $0x4,%eax
  8008ba:	8b 00                	mov    (%eax),%eax
  8008bc:	83 ec 08             	sub    $0x8,%esp
  8008bf:	ff 75 0c             	pushl  0xc(%ebp)
  8008c2:	50                   	push   %eax
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	ff d0                	call   *%eax
  8008c8:	83 c4 10             	add    $0x10,%esp
			break;
  8008cb:	e9 9b 02 00 00       	jmp    800b6b <vprintfmt+0x3ce>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d3:	83 c0 04             	add    $0x4,%eax
  8008d6:	89 45 14             	mov    %eax,0x14(%ebp)
  8008d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008dc:	83 e8 04             	sub    $0x4,%eax
  8008df:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8008e1:	85 db                	test   %ebx,%ebx
  8008e3:	79 02                	jns    8008e7 <vprintfmt+0x14a>
				err = -err;
  8008e5:	f7 db                	neg    %ebx
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8008e7:	83 fb 64             	cmp    $0x64,%ebx
  8008ea:	7f 0b                	jg     8008f7 <vprintfmt+0x15a>
  8008ec:	8b 34 9d 20 23 80 00 	mov    0x802320(,%ebx,4),%esi
  8008f3:	85 f6                	test   %esi,%esi
  8008f5:	75 19                	jne    800910 <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  8008f7:	53                   	push   %ebx
  8008f8:	68 c5 24 80 00       	push   $0x8024c5
  8008fd:	ff 75 0c             	pushl  0xc(%ebp)
  800900:	ff 75 08             	pushl  0x8(%ebp)
  800903:	e8 70 02 00 00       	call   800b78 <printfmt>
  800908:	83 c4 10             	add    $0x10,%esp
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80090b:	e9 5b 02 00 00       	jmp    800b6b <vprintfmt+0x3ce>
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800910:	56                   	push   %esi
  800911:	68 ce 24 80 00       	push   $0x8024ce
  800916:	ff 75 0c             	pushl  0xc(%ebp)
  800919:	ff 75 08             	pushl  0x8(%ebp)
  80091c:	e8 57 02 00 00       	call   800b78 <printfmt>
  800921:	83 c4 10             	add    $0x10,%esp
			break;
  800924:	e9 42 02 00 00       	jmp    800b6b <vprintfmt+0x3ce>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800929:	8b 45 14             	mov    0x14(%ebp),%eax
  80092c:	83 c0 04             	add    $0x4,%eax
  80092f:	89 45 14             	mov    %eax,0x14(%ebp)
  800932:	8b 45 14             	mov    0x14(%ebp),%eax
  800935:	83 e8 04             	sub    $0x4,%eax
  800938:	8b 30                	mov    (%eax),%esi
  80093a:	85 f6                	test   %esi,%esi
  80093c:	75 05                	jne    800943 <vprintfmt+0x1a6>
				p = "(null)";
  80093e:	be d1 24 80 00       	mov    $0x8024d1,%esi
			if (width > 0 && padc != '-')
  800943:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800947:	7e 6d                	jle    8009b6 <vprintfmt+0x219>
  800949:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80094d:	74 67                	je     8009b6 <vprintfmt+0x219>
				for (width -= strnlen(p, precision); width > 0; width--)
  80094f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800952:	83 ec 08             	sub    $0x8,%esp
  800955:	50                   	push   %eax
  800956:	56                   	push   %esi
  800957:	e8 26 05 00 00       	call   800e82 <strnlen>
  80095c:	83 c4 10             	add    $0x10,%esp
  80095f:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800962:	eb 16                	jmp    80097a <vprintfmt+0x1dd>
					putch(padc, putdat);
  800964:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800968:	83 ec 08             	sub    $0x8,%esp
  80096b:	ff 75 0c             	pushl  0xc(%ebp)
  80096e:	50                   	push   %eax
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	ff d0                	call   *%eax
  800974:	83 c4 10             	add    $0x10,%esp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800977:	ff 4d e4             	decl   -0x1c(%ebp)
  80097a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80097e:	7f e4                	jg     800964 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800980:	eb 34                	jmp    8009b6 <vprintfmt+0x219>
				if (altflag && (ch < ' ' || ch > '~'))
  800982:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800986:	74 1c                	je     8009a4 <vprintfmt+0x207>
  800988:	83 fb 1f             	cmp    $0x1f,%ebx
  80098b:	7e 05                	jle    800992 <vprintfmt+0x1f5>
  80098d:	83 fb 7e             	cmp    $0x7e,%ebx
  800990:	7e 12                	jle    8009a4 <vprintfmt+0x207>
					putch('?', putdat);
  800992:	83 ec 08             	sub    $0x8,%esp
  800995:	ff 75 0c             	pushl  0xc(%ebp)
  800998:	6a 3f                	push   $0x3f
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	ff d0                	call   *%eax
  80099f:	83 c4 10             	add    $0x10,%esp
  8009a2:	eb 0f                	jmp    8009b3 <vprintfmt+0x216>
				else
					putch(ch, putdat);
  8009a4:	83 ec 08             	sub    $0x8,%esp
  8009a7:	ff 75 0c             	pushl  0xc(%ebp)
  8009aa:	53                   	push   %ebx
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	ff d0                	call   *%eax
  8009b0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009b3:	ff 4d e4             	decl   -0x1c(%ebp)
  8009b6:	89 f0                	mov    %esi,%eax
  8009b8:	8d 70 01             	lea    0x1(%eax),%esi
  8009bb:	8a 00                	mov    (%eax),%al
  8009bd:	0f be d8             	movsbl %al,%ebx
  8009c0:	85 db                	test   %ebx,%ebx
  8009c2:	74 24                	je     8009e8 <vprintfmt+0x24b>
  8009c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009c8:	78 b8                	js     800982 <vprintfmt+0x1e5>
  8009ca:	ff 4d e0             	decl   -0x20(%ebp)
  8009cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009d1:	79 af                	jns    800982 <vprintfmt+0x1e5>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009d3:	eb 13                	jmp    8009e8 <vprintfmt+0x24b>
				putch(' ', putdat);
  8009d5:	83 ec 08             	sub    $0x8,%esp
  8009d8:	ff 75 0c             	pushl  0xc(%ebp)
  8009db:	6a 20                	push   $0x20
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e0:	ff d0                	call   *%eax
  8009e2:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009e5:	ff 4d e4             	decl   -0x1c(%ebp)
  8009e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009ec:	7f e7                	jg     8009d5 <vprintfmt+0x238>
				putch(' ', putdat);
			break;
  8009ee:	e9 78 01 00 00       	jmp    800b6b <vprintfmt+0x3ce>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009f3:	83 ec 08             	sub    $0x8,%esp
  8009f6:	ff 75 e8             	pushl  -0x18(%ebp)
  8009f9:	8d 45 14             	lea    0x14(%ebp),%eax
  8009fc:	50                   	push   %eax
  8009fd:	e8 3c fd ff ff       	call   80073e <getint>
  800a02:	83 c4 10             	add    $0x10,%esp
  800a05:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a08:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800a0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a11:	85 d2                	test   %edx,%edx
  800a13:	79 23                	jns    800a38 <vprintfmt+0x29b>
				putch('-', putdat);
  800a15:	83 ec 08             	sub    $0x8,%esp
  800a18:	ff 75 0c             	pushl  0xc(%ebp)
  800a1b:	6a 2d                	push   $0x2d
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	ff d0                	call   *%eax
  800a22:	83 c4 10             	add    $0x10,%esp
				num = -(long long) num;
  800a25:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a28:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a2b:	f7 d8                	neg    %eax
  800a2d:	83 d2 00             	adc    $0x0,%edx
  800a30:	f7 da                	neg    %edx
  800a32:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a35:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800a38:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a3f:	e9 bc 00 00 00       	jmp    800b00 <vprintfmt+0x363>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a44:	83 ec 08             	sub    $0x8,%esp
  800a47:	ff 75 e8             	pushl  -0x18(%ebp)
  800a4a:	8d 45 14             	lea    0x14(%ebp),%eax
  800a4d:	50                   	push   %eax
  800a4e:	e8 84 fc ff ff       	call   8006d7 <getuint>
  800a53:	83 c4 10             	add    $0x10,%esp
  800a56:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a59:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800a5c:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a63:	e9 98 00 00 00       	jmp    800b00 <vprintfmt+0x363>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800a68:	83 ec 08             	sub    $0x8,%esp
  800a6b:	ff 75 0c             	pushl  0xc(%ebp)
  800a6e:	6a 58                	push   $0x58
  800a70:	8b 45 08             	mov    0x8(%ebp),%eax
  800a73:	ff d0                	call   *%eax
  800a75:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800a78:	83 ec 08             	sub    $0x8,%esp
  800a7b:	ff 75 0c             	pushl  0xc(%ebp)
  800a7e:	6a 58                	push   $0x58
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	ff d0                	call   *%eax
  800a85:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800a88:	83 ec 08             	sub    $0x8,%esp
  800a8b:	ff 75 0c             	pushl  0xc(%ebp)
  800a8e:	6a 58                	push   $0x58
  800a90:	8b 45 08             	mov    0x8(%ebp),%eax
  800a93:	ff d0                	call   *%eax
  800a95:	83 c4 10             	add    $0x10,%esp
			break;
  800a98:	e9 ce 00 00 00       	jmp    800b6b <vprintfmt+0x3ce>

		// pointer
		case 'p':
			putch('0', putdat);
  800a9d:	83 ec 08             	sub    $0x8,%esp
  800aa0:	ff 75 0c             	pushl  0xc(%ebp)
  800aa3:	6a 30                	push   $0x30
  800aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa8:	ff d0                	call   *%eax
  800aaa:	83 c4 10             	add    $0x10,%esp
			putch('x', putdat);
  800aad:	83 ec 08             	sub    $0x8,%esp
  800ab0:	ff 75 0c             	pushl  0xc(%ebp)
  800ab3:	6a 78                	push   $0x78
  800ab5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab8:	ff d0                	call   *%eax
  800aba:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)
				(uint32) va_arg(ap, void *);
  800abd:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac0:	83 c0 04             	add    $0x4,%eax
  800ac3:	89 45 14             	mov    %eax,0x14(%ebp)
  800ac6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac9:	83 e8 04             	sub    $0x4,%eax
  800acc:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800ace:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ad1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uint32) va_arg(ap, void *);
			base = 16;
  800ad8:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800adf:	eb 1f                	jmp    800b00 <vprintfmt+0x363>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800ae1:	83 ec 08             	sub    $0x8,%esp
  800ae4:	ff 75 e8             	pushl  -0x18(%ebp)
  800ae7:	8d 45 14             	lea    0x14(%ebp),%eax
  800aea:	50                   	push   %eax
  800aeb:	e8 e7 fb ff ff       	call   8006d7 <getuint>
  800af0:	83 c4 10             	add    $0x10,%esp
  800af3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800af6:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800af9:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b00:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800b04:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b07:	83 ec 04             	sub    $0x4,%esp
  800b0a:	52                   	push   %edx
  800b0b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b0e:	50                   	push   %eax
  800b0f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b12:	ff 75 f0             	pushl  -0x10(%ebp)
  800b15:	ff 75 0c             	pushl  0xc(%ebp)
  800b18:	ff 75 08             	pushl  0x8(%ebp)
  800b1b:	e8 00 fb ff ff       	call   800620 <printnum>
  800b20:	83 c4 20             	add    $0x20,%esp
			break;
  800b23:	eb 46                	jmp    800b6b <vprintfmt+0x3ce>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b25:	83 ec 08             	sub    $0x8,%esp
  800b28:	ff 75 0c             	pushl  0xc(%ebp)
  800b2b:	53                   	push   %ebx
  800b2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2f:	ff d0                	call   *%eax
  800b31:	83 c4 10             	add    $0x10,%esp
			break;
  800b34:	eb 35                	jmp    800b6b <vprintfmt+0x3ce>

		/**********************************/
		/*2023*/
		// DON'T Print Program Name & UD
		case '~':
			printProgName = 0;
  800b36:	c6 05 08 30 80 00 00 	movb   $0x0,0x803008
			break;
  800b3d:	eb 2c                	jmp    800b6b <vprintfmt+0x3ce>
		// Print Program Name & UD
		case '@':
			printProgName = 1;
  800b3f:	c6 05 08 30 80 00 01 	movb   $0x1,0x803008
			break;
  800b46:	eb 23                	jmp    800b6b <vprintfmt+0x3ce>
		/**********************************/

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b48:	83 ec 08             	sub    $0x8,%esp
  800b4b:	ff 75 0c             	pushl  0xc(%ebp)
  800b4e:	6a 25                	push   $0x25
  800b50:	8b 45 08             	mov    0x8(%ebp),%eax
  800b53:	ff d0                	call   *%eax
  800b55:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b58:	ff 4d 10             	decl   0x10(%ebp)
  800b5b:	eb 03                	jmp    800b60 <vprintfmt+0x3c3>
  800b5d:	ff 4d 10             	decl   0x10(%ebp)
  800b60:	8b 45 10             	mov    0x10(%ebp),%eax
  800b63:	48                   	dec    %eax
  800b64:	8a 00                	mov    (%eax),%al
  800b66:	3c 25                	cmp    $0x25,%al
  800b68:	75 f3                	jne    800b5d <vprintfmt+0x3c0>
				/* do nothing */;
			break;
  800b6a:	90                   	nop
		}
	}
  800b6b:	e9 35 fc ff ff       	jmp    8007a5 <vprintfmt+0x8>
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
  800b70:	90                   	nop
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800b7e:	8d 45 10             	lea    0x10(%ebp),%eax
  800b81:	83 c0 04             	add    $0x4,%eax
  800b84:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b87:	8b 45 10             	mov    0x10(%ebp),%eax
  800b8a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b8d:	50                   	push   %eax
  800b8e:	ff 75 0c             	pushl  0xc(%ebp)
  800b91:	ff 75 08             	pushl  0x8(%ebp)
  800b94:	e8 04 fc ff ff       	call   80079d <vprintfmt>
  800b99:	83 c4 10             	add    $0x10,%esp
	va_end(ap);
}
  800b9c:	90                   	nop
  800b9d:	c9                   	leave  
  800b9e:	c3                   	ret    

00800b9f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba5:	8b 40 08             	mov    0x8(%eax),%eax
  800ba8:	8d 50 01             	lea    0x1(%eax),%edx
  800bab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bae:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800bb1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb4:	8b 10                	mov    (%eax),%edx
  800bb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb9:	8b 40 04             	mov    0x4(%eax),%eax
  800bbc:	39 c2                	cmp    %eax,%edx
  800bbe:	73 12                	jae    800bd2 <sprintputch+0x33>
		*b->buf++ = ch;
  800bc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc3:	8b 00                	mov    (%eax),%eax
  800bc5:	8d 48 01             	lea    0x1(%eax),%ecx
  800bc8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bcb:	89 0a                	mov    %ecx,(%edx)
  800bcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd0:	88 10                	mov    %dl,(%eax)
}
  800bd2:	90                   	nop
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	83 ec 18             	sub    $0x18,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bde:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800be1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be4:	8d 50 ff             	lea    -0x1(%eax),%edx
  800be7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bea:	01 d0                	add    %edx,%eax
  800bec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800bef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bf6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800bfa:	74 06                	je     800c02 <vsnprintf+0x2d>
  800bfc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c00:	7f 07                	jg     800c09 <vsnprintf+0x34>
		return -E_INVAL;
  800c02:	b8 03 00 00 00       	mov    $0x3,%eax
  800c07:	eb 20                	jmp    800c29 <vsnprintf+0x54>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c09:	ff 75 14             	pushl  0x14(%ebp)
  800c0c:	ff 75 10             	pushl  0x10(%ebp)
  800c0f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c12:	50                   	push   %eax
  800c13:	68 9f 0b 80 00       	push   $0x800b9f
  800c18:	e8 80 fb ff ff       	call   80079d <vprintfmt>
  800c1d:	83 c4 10             	add    $0x10,%esp

	// null terminate the buffer
	*b.buf = '\0';
  800c20:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c23:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c29:	c9                   	leave  
  800c2a:	c3                   	ret    

00800c2b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c31:	8d 45 10             	lea    0x10(%ebp),%eax
  800c34:	83 c0 04             	add    $0x4,%eax
  800c37:	89 45 f4             	mov    %eax,-0xc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800c3a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c3d:	ff 75 f4             	pushl  -0xc(%ebp)
  800c40:	50                   	push   %eax
  800c41:	ff 75 0c             	pushl  0xc(%ebp)
  800c44:	ff 75 08             	pushl  0x8(%ebp)
  800c47:	e8 89 ff ff ff       	call   800bd5 <vsnprintf>
  800c4c:	83 c4 10             	add    $0x10,%esp
  800c4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return rc;
  800c52:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800c55:	c9                   	leave  
  800c56:	c3                   	ret    

00800c57 <readline>:
#include <inc/lib.h>

//static char buf[BUFLEN];

void readline(const char *prompt, char* buf)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	83 ec 18             	sub    $0x18,%esp
	int i, c, echoing;

	if (prompt != NULL)
  800c5d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800c61:	74 13                	je     800c76 <readline+0x1f>
		cprintf("%s", prompt);
  800c63:	83 ec 08             	sub    $0x8,%esp
  800c66:	ff 75 08             	pushl  0x8(%ebp)
  800c69:	68 48 26 80 00       	push   $0x802648
  800c6e:	e8 50 f9 ff ff       	call   8005c3 <cprintf>
  800c73:	83 c4 10             	add    $0x10,%esp

	i = 0;
  800c76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	echoing = iscons(0);
  800c7d:	83 ec 0c             	sub    $0xc,%esp
  800c80:	6a 00                	push   $0x0
  800c82:	e8 f2 0f 00 00       	call   801c79 <iscons>
  800c87:	83 c4 10             	add    $0x10,%esp
  800c8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	while (1) {
		c = getchar();
  800c8d:	e8 d4 0f 00 00       	call   801c66 <getchar>
  800c92:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if (c < 0) {
  800c95:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800c99:	79 22                	jns    800cbd <readline+0x66>
			if (c != -E_EOF)
  800c9b:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
  800c9f:	0f 84 ad 00 00 00    	je     800d52 <readline+0xfb>
				cprintf("read error: %e\n", c);
  800ca5:	83 ec 08             	sub    $0x8,%esp
  800ca8:	ff 75 ec             	pushl  -0x14(%ebp)
  800cab:	68 4b 26 80 00       	push   $0x80264b
  800cb0:	e8 0e f9 ff ff       	call   8005c3 <cprintf>
  800cb5:	83 c4 10             	add    $0x10,%esp
			break;
  800cb8:	e9 95 00 00 00       	jmp    800d52 <readline+0xfb>
		} else if (c >= ' ' && i < BUFLEN-1) {
  800cbd:	83 7d ec 1f          	cmpl   $0x1f,-0x14(%ebp)
  800cc1:	7e 34                	jle    800cf7 <readline+0xa0>
  800cc3:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  800cca:	7f 2b                	jg     800cf7 <readline+0xa0>
			if (echoing)
  800ccc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800cd0:	74 0e                	je     800ce0 <readline+0x89>
				cputchar(c);
  800cd2:	83 ec 0c             	sub    $0xc,%esp
  800cd5:	ff 75 ec             	pushl  -0x14(%ebp)
  800cd8:	e8 6a 0f 00 00       	call   801c47 <cputchar>
  800cdd:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  800ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ce3:	8d 50 01             	lea    0x1(%eax),%edx
  800ce6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800ce9:	89 c2                	mov    %eax,%edx
  800ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cee:	01 d0                	add    %edx,%eax
  800cf0:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800cf3:	88 10                	mov    %dl,(%eax)
  800cf5:	eb 56                	jmp    800d4d <readline+0xf6>
		} else if (c == '\b' && i > 0) {
  800cf7:	83 7d ec 08          	cmpl   $0x8,-0x14(%ebp)
  800cfb:	75 1f                	jne    800d1c <readline+0xc5>
  800cfd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  800d01:	7e 19                	jle    800d1c <readline+0xc5>
			if (echoing)
  800d03:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800d07:	74 0e                	je     800d17 <readline+0xc0>
				cputchar(c);
  800d09:	83 ec 0c             	sub    $0xc,%esp
  800d0c:	ff 75 ec             	pushl  -0x14(%ebp)
  800d0f:	e8 33 0f 00 00       	call   801c47 <cputchar>
  800d14:	83 c4 10             	add    $0x10,%esp

			i--;
  800d17:	ff 4d f4             	decl   -0xc(%ebp)
  800d1a:	eb 31                	jmp    800d4d <readline+0xf6>
		} else if (c == '\n' || c == '\r') {
  800d1c:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
  800d20:	74 0a                	je     800d2c <readline+0xd5>
  800d22:	83 7d ec 0d          	cmpl   $0xd,-0x14(%ebp)
  800d26:	0f 85 61 ff ff ff    	jne    800c8d <readline+0x36>
			if (echoing)
  800d2c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800d30:	74 0e                	je     800d40 <readline+0xe9>
				cputchar(c);
  800d32:	83 ec 0c             	sub    $0xc,%esp
  800d35:	ff 75 ec             	pushl  -0x14(%ebp)
  800d38:	e8 0a 0f 00 00       	call   801c47 <cputchar>
  800d3d:	83 c4 10             	add    $0x10,%esp

			buf[i] = 0;
  800d40:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d46:	01 d0                	add    %edx,%eax
  800d48:	c6 00 00             	movb   $0x0,(%eax)
			break;
  800d4b:	eb 06                	jmp    800d53 <readline+0xfc>
		}
	}
  800d4d:	e9 3b ff ff ff       	jmp    800c8d <readline+0x36>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			break;
  800d52:	90                   	nop

			buf[i] = 0;
			break;
		}
	}
}
  800d53:	90                   	nop
  800d54:	c9                   	leave  
  800d55:	c3                   	ret    

00800d56 <atomic_readline>:

void atomic_readline(const char *prompt, char* buf)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	83 ec 18             	sub    $0x18,%esp
	sys_lock_cons();
  800d5c:	e8 71 08 00 00       	call   8015d2 <sys_lock_cons>
	{
		int i, c, echoing;

		if (prompt != NULL)
  800d61:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800d65:	74 13                	je     800d7a <atomic_readline+0x24>
			cprintf("%s", prompt);
  800d67:	83 ec 08             	sub    $0x8,%esp
  800d6a:	ff 75 08             	pushl  0x8(%ebp)
  800d6d:	68 48 26 80 00       	push   $0x802648
  800d72:	e8 4c f8 ff ff       	call   8005c3 <cprintf>
  800d77:	83 c4 10             	add    $0x10,%esp

		i = 0;
  800d7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
		echoing = iscons(0);
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	6a 00                	push   $0x0
  800d86:	e8 ee 0e 00 00       	call   801c79 <iscons>
  800d8b:	83 c4 10             	add    $0x10,%esp
  800d8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
		while (1) {
			c = getchar();
  800d91:	e8 d0 0e 00 00       	call   801c66 <getchar>
  800d96:	89 45 ec             	mov    %eax,-0x14(%ebp)
			if (c < 0) {
  800d99:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800d9d:	79 22                	jns    800dc1 <atomic_readline+0x6b>
				if (c != -E_EOF)
  800d9f:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
  800da3:	0f 84 ad 00 00 00    	je     800e56 <atomic_readline+0x100>
					cprintf("read error: %e\n", c);
  800da9:	83 ec 08             	sub    $0x8,%esp
  800dac:	ff 75 ec             	pushl  -0x14(%ebp)
  800daf:	68 4b 26 80 00       	push   $0x80264b
  800db4:	e8 0a f8 ff ff       	call   8005c3 <cprintf>
  800db9:	83 c4 10             	add    $0x10,%esp
				break;
  800dbc:	e9 95 00 00 00       	jmp    800e56 <atomic_readline+0x100>
			} else if (c >= ' ' && i < BUFLEN-1) {
  800dc1:	83 7d ec 1f          	cmpl   $0x1f,-0x14(%ebp)
  800dc5:	7e 34                	jle    800dfb <atomic_readline+0xa5>
  800dc7:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  800dce:	7f 2b                	jg     800dfb <atomic_readline+0xa5>
				if (echoing)
  800dd0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800dd4:	74 0e                	je     800de4 <atomic_readline+0x8e>
					cputchar(c);
  800dd6:	83 ec 0c             	sub    $0xc,%esp
  800dd9:	ff 75 ec             	pushl  -0x14(%ebp)
  800ddc:	e8 66 0e 00 00       	call   801c47 <cputchar>
  800de1:	83 c4 10             	add    $0x10,%esp
				buf[i++] = c;
  800de4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800de7:	8d 50 01             	lea    0x1(%eax),%edx
  800dea:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800ded:	89 c2                	mov    %eax,%edx
  800def:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df2:	01 d0                	add    %edx,%eax
  800df4:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800df7:	88 10                	mov    %dl,(%eax)
  800df9:	eb 56                	jmp    800e51 <atomic_readline+0xfb>
			} else if (c == '\b' && i > 0) {
  800dfb:	83 7d ec 08          	cmpl   $0x8,-0x14(%ebp)
  800dff:	75 1f                	jne    800e20 <atomic_readline+0xca>
  800e01:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  800e05:	7e 19                	jle    800e20 <atomic_readline+0xca>
				if (echoing)
  800e07:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800e0b:	74 0e                	je     800e1b <atomic_readline+0xc5>
					cputchar(c);
  800e0d:	83 ec 0c             	sub    $0xc,%esp
  800e10:	ff 75 ec             	pushl  -0x14(%ebp)
  800e13:	e8 2f 0e 00 00       	call   801c47 <cputchar>
  800e18:	83 c4 10             	add    $0x10,%esp
				i--;
  800e1b:	ff 4d f4             	decl   -0xc(%ebp)
  800e1e:	eb 31                	jmp    800e51 <atomic_readline+0xfb>
			} else if (c == '\n' || c == '\r') {
  800e20:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
  800e24:	74 0a                	je     800e30 <atomic_readline+0xda>
  800e26:	83 7d ec 0d          	cmpl   $0xd,-0x14(%ebp)
  800e2a:	0f 85 61 ff ff ff    	jne    800d91 <atomic_readline+0x3b>
				if (echoing)
  800e30:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800e34:	74 0e                	je     800e44 <atomic_readline+0xee>
					cputchar(c);
  800e36:	83 ec 0c             	sub    $0xc,%esp
  800e39:	ff 75 ec             	pushl  -0x14(%ebp)
  800e3c:	e8 06 0e 00 00       	call   801c47 <cputchar>
  800e41:	83 c4 10             	add    $0x10,%esp
				buf[i] = 0;
  800e44:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e4a:	01 d0                	add    %edx,%eax
  800e4c:	c6 00 00             	movb   $0x0,(%eax)
				break;
  800e4f:	eb 06                	jmp    800e57 <atomic_readline+0x101>
			}
		}
  800e51:	e9 3b ff ff ff       	jmp    800d91 <atomic_readline+0x3b>
		while (1) {
			c = getchar();
			if (c < 0) {
				if (c != -E_EOF)
					cprintf("read error: %e\n", c);
				break;
  800e56:	90                   	nop
				buf[i] = 0;
				break;
			}
		}
	}
	sys_unlock_cons();
  800e57:	e8 90 07 00 00       	call   8015ec <sys_unlock_cons>
}
  800e5c:	90                   	nop
  800e5d:	c9                   	leave  
  800e5e:	c3                   	ret    

00800e5f <strlen>:
#include <inc/string.h>
#include <inc/assert.h>

int
strlen(const char *s)
{
  800e5f:	55                   	push   %ebp
  800e60:	89 e5                	mov    %esp,%ebp
  800e62:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800e65:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800e6c:	eb 06                	jmp    800e74 <strlen+0x15>
		n++;
  800e6e:	ff 45 fc             	incl   -0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800e71:	ff 45 08             	incl   0x8(%ebp)
  800e74:	8b 45 08             	mov    0x8(%ebp),%eax
  800e77:	8a 00                	mov    (%eax),%al
  800e79:	84 c0                	test   %al,%al
  800e7b:	75 f1                	jne    800e6e <strlen+0xf>
		n++;
	return n;
  800e7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800e80:	c9                   	leave  
  800e81:	c3                   	ret    

00800e82 <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e88:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800e8f:	eb 09                	jmp    800e9a <strnlen+0x18>
		n++;
  800e91:	ff 45 fc             	incl   -0x4(%ebp)
int
strnlen(const char *s, uint32 size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e94:	ff 45 08             	incl   0x8(%ebp)
  800e97:	ff 4d 0c             	decl   0xc(%ebp)
  800e9a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e9e:	74 09                	je     800ea9 <strnlen+0x27>
  800ea0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea3:	8a 00                	mov    (%eax),%al
  800ea5:	84 c0                	test   %al,%al
  800ea7:	75 e8                	jne    800e91 <strnlen+0xf>
		n++;
	return n;
  800ea9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800eac:	c9                   	leave  
  800ead:	c3                   	ret    

00800eae <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800eb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb7:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800eba:	90                   	nop
  800ebb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebe:	8d 50 01             	lea    0x1(%eax),%edx
  800ec1:	89 55 08             	mov    %edx,0x8(%ebp)
  800ec4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ec7:	8d 4a 01             	lea    0x1(%edx),%ecx
  800eca:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800ecd:	8a 12                	mov    (%edx),%dl
  800ecf:	88 10                	mov    %dl,(%eax)
  800ed1:	8a 00                	mov    (%eax),%al
  800ed3:	84 c0                	test   %al,%al
  800ed5:	75 e4                	jne    800ebb <strcpy+0xd>
		/* do nothing */;
	return ret;
  800ed7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800eda:	c9                   	leave  
  800edb:	c3                   	ret    

00800edc <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 10             	sub    $0x10,%esp
	uint32 i;
	char *ret;

	ret = dst;
  800ee2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee5:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800ee8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800eef:	eb 1f                	jmp    800f10 <strncpy+0x34>
		*dst++ = *src;
  800ef1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef4:	8d 50 01             	lea    0x1(%eax),%edx
  800ef7:	89 55 08             	mov    %edx,0x8(%ebp)
  800efa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800efd:	8a 12                	mov    (%edx),%dl
  800eff:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800f01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f04:	8a 00                	mov    (%eax),%al
  800f06:	84 c0                	test   %al,%al
  800f08:	74 03                	je     800f0d <strncpy+0x31>
			src++;
  800f0a:	ff 45 0c             	incl   0xc(%ebp)
strncpy(char *dst, const char *src, uint32 size) {
	uint32 i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f0d:	ff 45 fc             	incl   -0x4(%ebp)
  800f10:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f13:	3b 45 10             	cmp    0x10(%ebp),%eax
  800f16:	72 d9                	jb     800ef1 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800f18:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800f1b:	c9                   	leave  
  800f1c:	c3                   	ret    

00800f1d <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  800f1d:	55                   	push   %ebp
  800f1e:	89 e5                	mov    %esp,%ebp
  800f20:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800f23:	8b 45 08             	mov    0x8(%ebp),%eax
  800f26:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800f29:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f2d:	74 30                	je     800f5f <strlcpy+0x42>
		while (--size > 0 && *src != '\0')
  800f2f:	eb 16                	jmp    800f47 <strlcpy+0x2a>
			*dst++ = *src++;
  800f31:	8b 45 08             	mov    0x8(%ebp),%eax
  800f34:	8d 50 01             	lea    0x1(%eax),%edx
  800f37:	89 55 08             	mov    %edx,0x8(%ebp)
  800f3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f3d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800f40:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800f43:	8a 12                	mov    (%edx),%dl
  800f45:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800f47:	ff 4d 10             	decl   0x10(%ebp)
  800f4a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f4e:	74 09                	je     800f59 <strlcpy+0x3c>
  800f50:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f53:	8a 00                	mov    (%eax),%al
  800f55:	84 c0                	test   %al,%al
  800f57:	75 d8                	jne    800f31 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800f59:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800f5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f62:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f65:	29 c2                	sub    %eax,%edx
  800f67:	89 d0                	mov    %edx,%eax
}
  800f69:	c9                   	leave  
  800f6a:	c3                   	ret    

00800f6b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800f6e:	eb 06                	jmp    800f76 <strcmp+0xb>
		p++, q++;
  800f70:	ff 45 08             	incl   0x8(%ebp)
  800f73:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800f76:	8b 45 08             	mov    0x8(%ebp),%eax
  800f79:	8a 00                	mov    (%eax),%al
  800f7b:	84 c0                	test   %al,%al
  800f7d:	74 0e                	je     800f8d <strcmp+0x22>
  800f7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f82:	8a 10                	mov    (%eax),%dl
  800f84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f87:	8a 00                	mov    (%eax),%al
  800f89:	38 c2                	cmp    %al,%dl
  800f8b:	74 e3                	je     800f70 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800f8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f90:	8a 00                	mov    (%eax),%al
  800f92:	0f b6 d0             	movzbl %al,%edx
  800f95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f98:	8a 00                	mov    (%eax),%al
  800f9a:	0f b6 c0             	movzbl %al,%eax
  800f9d:	29 c2                	sub    %eax,%edx
  800f9f:	89 d0                	mov    %edx,%eax
}
  800fa1:	5d                   	pop    %ebp
  800fa2:	c3                   	ret    

00800fa3 <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800fa6:	eb 09                	jmp    800fb1 <strncmp+0xe>
		n--, p++, q++;
  800fa8:	ff 4d 10             	decl   0x10(%ebp)
  800fab:	ff 45 08             	incl   0x8(%ebp)
  800fae:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint32 n)
{
	while (n > 0 && *p && *p == *q)
  800fb1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800fb5:	74 17                	je     800fce <strncmp+0x2b>
  800fb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fba:	8a 00                	mov    (%eax),%al
  800fbc:	84 c0                	test   %al,%al
  800fbe:	74 0e                	je     800fce <strncmp+0x2b>
  800fc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc3:	8a 10                	mov    (%eax),%dl
  800fc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc8:	8a 00                	mov    (%eax),%al
  800fca:	38 c2                	cmp    %al,%dl
  800fcc:	74 da                	je     800fa8 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800fce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800fd2:	75 07                	jne    800fdb <strncmp+0x38>
		return 0;
  800fd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd9:	eb 14                	jmp    800fef <strncmp+0x4c>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800fdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fde:	8a 00                	mov    (%eax),%al
  800fe0:	0f b6 d0             	movzbl %al,%edx
  800fe3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe6:	8a 00                	mov    (%eax),%al
  800fe8:	0f b6 c0             	movzbl %al,%eax
  800feb:	29 c2                	sub    %eax,%edx
  800fed:	89 d0                	mov    %edx,%eax
}
  800fef:	5d                   	pop    %ebp
  800ff0:	c3                   	ret    

00800ff1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ff1:	55                   	push   %ebp
  800ff2:	89 e5                	mov    %esp,%ebp
  800ff4:	83 ec 04             	sub    $0x4,%esp
  800ff7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ffa:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800ffd:	eb 12                	jmp    801011 <strchr+0x20>
		if (*s == c)
  800fff:	8b 45 08             	mov    0x8(%ebp),%eax
  801002:	8a 00                	mov    (%eax),%al
  801004:	3a 45 fc             	cmp    -0x4(%ebp),%al
  801007:	75 05                	jne    80100e <strchr+0x1d>
			return (char *) s;
  801009:	8b 45 08             	mov    0x8(%ebp),%eax
  80100c:	eb 11                	jmp    80101f <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80100e:	ff 45 08             	incl   0x8(%ebp)
  801011:	8b 45 08             	mov    0x8(%ebp),%eax
  801014:	8a 00                	mov    (%eax),%al
  801016:	84 c0                	test   %al,%al
  801018:	75 e5                	jne    800fff <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  80101a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80101f:	c9                   	leave  
  801020:	c3                   	ret    

00801021 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	83 ec 04             	sub    $0x4,%esp
  801027:	8b 45 0c             	mov    0xc(%ebp),%eax
  80102a:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  80102d:	eb 0d                	jmp    80103c <strfind+0x1b>
		if (*s == c)
  80102f:	8b 45 08             	mov    0x8(%ebp),%eax
  801032:	8a 00                	mov    (%eax),%al
  801034:	3a 45 fc             	cmp    -0x4(%ebp),%al
  801037:	74 0e                	je     801047 <strfind+0x26>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801039:	ff 45 08             	incl   0x8(%ebp)
  80103c:	8b 45 08             	mov    0x8(%ebp),%eax
  80103f:	8a 00                	mov    (%eax),%al
  801041:	84 c0                	test   %al,%al
  801043:	75 ea                	jne    80102f <strfind+0xe>
  801045:	eb 01                	jmp    801048 <strfind+0x27>
		if (*s == c)
			break;
  801047:	90                   	nop
	return (char *) s;
  801048:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80104b:	c9                   	leave  
  80104c:	c3                   	ret    

0080104d <memset>:


void *
memset(void *v, int c, uint32 n)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	83 ec 10             	sub    $0x10,%esp
	char *p;
	int m;

	p = v;
  801053:	8b 45 08             	mov    0x8(%ebp),%eax
  801056:	89 45 fc             	mov    %eax,-0x4(%ebp)
	m = n;
  801059:	8b 45 10             	mov    0x10(%ebp),%eax
  80105c:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (--m >= 0)
  80105f:	eb 0e                	jmp    80106f <memset+0x22>
		*p++ = c;
  801061:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801064:	8d 50 01             	lea    0x1(%eax),%edx
  801067:	89 55 fc             	mov    %edx,-0x4(%ebp)
  80106a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80106d:	88 10                	mov    %dl,(%eax)
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  80106f:	ff 4d f8             	decl   -0x8(%ebp)
  801072:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
  801076:	79 e9                	jns    801061 <memset+0x14>
		*p++ = c;

	return v;
  801078:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80107b:	c9                   	leave  
  80107c:	c3                   	ret    

0080107d <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  801083:	8b 45 0c             	mov    0xc(%ebp),%eax
  801086:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  801089:	8b 45 08             	mov    0x8(%ebp),%eax
  80108c:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
  80108f:	eb 16                	jmp    8010a7 <memcpy+0x2a>
		*d++ = *s++;
  801091:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801094:	8d 50 01             	lea    0x1(%eax),%edx
  801097:	89 55 f8             	mov    %edx,-0x8(%ebp)
  80109a:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80109d:	8d 4a 01             	lea    0x1(%edx),%ecx
  8010a0:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  8010a3:	8a 12                	mov    (%edx),%dl
  8010a5:	88 10                	mov    %dl,(%eax)
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  8010a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8010aa:	8d 50 ff             	lea    -0x1(%eax),%edx
  8010ad:	89 55 10             	mov    %edx,0x10(%ebp)
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	75 dd                	jne    801091 <memcpy+0x14>
		*d++ = *s++;

	return dst;
  8010b4:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8010b7:	c9                   	leave  
  8010b8:	c3                   	ret    

008010b9 <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  8010bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  8010c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c8:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (s < d && s + n > d) {
  8010cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8010ce:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  8010d1:	73 50                	jae    801123 <memmove+0x6a>
  8010d3:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8010d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8010d9:	01 d0                	add    %edx,%eax
  8010db:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  8010de:	76 43                	jbe    801123 <memmove+0x6a>
		s += n;
  8010e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8010e3:	01 45 fc             	add    %eax,-0x4(%ebp)
		d += n;
  8010e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8010e9:	01 45 f8             	add    %eax,-0x8(%ebp)
		while (n-- > 0)
  8010ec:	eb 10                	jmp    8010fe <memmove+0x45>
			*--d = *--s;
  8010ee:	ff 4d f8             	decl   -0x8(%ebp)
  8010f1:	ff 4d fc             	decl   -0x4(%ebp)
  8010f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8010f7:	8a 10                	mov    (%eax),%dl
  8010f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8010fc:	88 10                	mov    %dl,(%eax)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  8010fe:	8b 45 10             	mov    0x10(%ebp),%eax
  801101:	8d 50 ff             	lea    -0x1(%eax),%edx
  801104:	89 55 10             	mov    %edx,0x10(%ebp)
  801107:	85 c0                	test   %eax,%eax
  801109:	75 e3                	jne    8010ee <memmove+0x35>
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80110b:	eb 23                	jmp    801130 <memmove+0x77>
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  80110d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801110:	8d 50 01             	lea    0x1(%eax),%edx
  801113:	89 55 f8             	mov    %edx,-0x8(%ebp)
  801116:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801119:	8d 4a 01             	lea    0x1(%edx),%ecx
  80111c:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  80111f:	8a 12                	mov    (%edx),%dl
  801121:	88 10                	mov    %dl,(%eax)
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  801123:	8b 45 10             	mov    0x10(%ebp),%eax
  801126:	8d 50 ff             	lea    -0x1(%eax),%edx
  801129:	89 55 10             	mov    %edx,0x10(%ebp)
  80112c:	85 c0                	test   %eax,%eax
  80112e:	75 dd                	jne    80110d <memmove+0x54>
			*d++ = *s++;

	return dst;
  801130:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801133:	c9                   	leave  
  801134:	c3                   	ret    

00801135 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	83 ec 10             	sub    $0x10,%esp
	const uint8 *s1 = (const uint8 *) v1;
  80113b:	8b 45 08             	mov    0x8(%ebp),%eax
  80113e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8 *s2 = (const uint8 *) v2;
  801141:	8b 45 0c             	mov    0xc(%ebp),%eax
  801144:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  801147:	eb 2a                	jmp    801173 <memcmp+0x3e>
		if (*s1 != *s2)
  801149:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80114c:	8a 10                	mov    (%eax),%dl
  80114e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801151:	8a 00                	mov    (%eax),%al
  801153:	38 c2                	cmp    %al,%dl
  801155:	74 16                	je     80116d <memcmp+0x38>
			return (int) *s1 - (int) *s2;
  801157:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80115a:	8a 00                	mov    (%eax),%al
  80115c:	0f b6 d0             	movzbl %al,%edx
  80115f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801162:	8a 00                	mov    (%eax),%al
  801164:	0f b6 c0             	movzbl %al,%eax
  801167:	29 c2                	sub    %eax,%edx
  801169:	89 d0                	mov    %edx,%eax
  80116b:	eb 18                	jmp    801185 <memcmp+0x50>
		s1++, s2++;
  80116d:	ff 45 fc             	incl   -0x4(%ebp)
  801170:	ff 45 f8             	incl   -0x8(%ebp)
memcmp(const void *v1, const void *v2, uint32 n)
{
	const uint8 *s1 = (const uint8 *) v1;
	const uint8 *s2 = (const uint8 *) v2;

	while (n-- > 0) {
  801173:	8b 45 10             	mov    0x10(%ebp),%eax
  801176:	8d 50 ff             	lea    -0x1(%eax),%edx
  801179:	89 55 10             	mov    %edx,0x10(%ebp)
  80117c:	85 c0                	test   %eax,%eax
  80117e:	75 c9                	jne    801149 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801180:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801185:	c9                   	leave  
  801186:	c3                   	ret    

00801187 <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  80118d:	8b 55 08             	mov    0x8(%ebp),%edx
  801190:	8b 45 10             	mov    0x10(%ebp),%eax
  801193:	01 d0                	add    %edx,%eax
  801195:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801198:	eb 15                	jmp    8011af <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  80119a:	8b 45 08             	mov    0x8(%ebp),%eax
  80119d:	8a 00                	mov    (%eax),%al
  80119f:	0f b6 d0             	movzbl %al,%edx
  8011a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a5:	0f b6 c0             	movzbl %al,%eax
  8011a8:	39 c2                	cmp    %eax,%edx
  8011aa:	74 0d                	je     8011b9 <memfind+0x32>

void *
memfind(const void *s, int c, uint32 n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8011ac:	ff 45 08             	incl   0x8(%ebp)
  8011af:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  8011b5:	72 e3                	jb     80119a <memfind+0x13>
  8011b7:	eb 01                	jmp    8011ba <memfind+0x33>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
  8011b9:	90                   	nop
	return (void *) s;
  8011ba:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8011bd:	c9                   	leave  
  8011be:	c3                   	ret    

008011bf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8011bf:	55                   	push   %ebp
  8011c0:	89 e5                	mov    %esp,%ebp
  8011c2:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  8011c5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  8011cc:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8011d3:	eb 03                	jmp    8011d8 <strtol+0x19>
		s++;
  8011d5:	ff 45 08             	incl   0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8011d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011db:	8a 00                	mov    (%eax),%al
  8011dd:	3c 20                	cmp    $0x20,%al
  8011df:	74 f4                	je     8011d5 <strtol+0x16>
  8011e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e4:	8a 00                	mov    (%eax),%al
  8011e6:	3c 09                	cmp    $0x9,%al
  8011e8:	74 eb                	je     8011d5 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  8011ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ed:	8a 00                	mov    (%eax),%al
  8011ef:	3c 2b                	cmp    $0x2b,%al
  8011f1:	75 05                	jne    8011f8 <strtol+0x39>
		s++;
  8011f3:	ff 45 08             	incl   0x8(%ebp)
  8011f6:	eb 13                	jmp    80120b <strtol+0x4c>
	else if (*s == '-')
  8011f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fb:	8a 00                	mov    (%eax),%al
  8011fd:	3c 2d                	cmp    $0x2d,%al
  8011ff:	75 0a                	jne    80120b <strtol+0x4c>
		s++, neg = 1;
  801201:	ff 45 08             	incl   0x8(%ebp)
  801204:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80120b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80120f:	74 06                	je     801217 <strtol+0x58>
  801211:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801215:	75 20                	jne    801237 <strtol+0x78>
  801217:	8b 45 08             	mov    0x8(%ebp),%eax
  80121a:	8a 00                	mov    (%eax),%al
  80121c:	3c 30                	cmp    $0x30,%al
  80121e:	75 17                	jne    801237 <strtol+0x78>
  801220:	8b 45 08             	mov    0x8(%ebp),%eax
  801223:	40                   	inc    %eax
  801224:	8a 00                	mov    (%eax),%al
  801226:	3c 78                	cmp    $0x78,%al
  801228:	75 0d                	jne    801237 <strtol+0x78>
		s += 2, base = 16;
  80122a:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  80122e:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  801235:	eb 28                	jmp    80125f <strtol+0xa0>
	else if (base == 0 && s[0] == '0')
  801237:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80123b:	75 15                	jne    801252 <strtol+0x93>
  80123d:	8b 45 08             	mov    0x8(%ebp),%eax
  801240:	8a 00                	mov    (%eax),%al
  801242:	3c 30                	cmp    $0x30,%al
  801244:	75 0c                	jne    801252 <strtol+0x93>
		s++, base = 8;
  801246:	ff 45 08             	incl   0x8(%ebp)
  801249:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801250:	eb 0d                	jmp    80125f <strtol+0xa0>
	else if (base == 0)
  801252:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801256:	75 07                	jne    80125f <strtol+0xa0>
		base = 10;
  801258:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80125f:	8b 45 08             	mov    0x8(%ebp),%eax
  801262:	8a 00                	mov    (%eax),%al
  801264:	3c 2f                	cmp    $0x2f,%al
  801266:	7e 19                	jle    801281 <strtol+0xc2>
  801268:	8b 45 08             	mov    0x8(%ebp),%eax
  80126b:	8a 00                	mov    (%eax),%al
  80126d:	3c 39                	cmp    $0x39,%al
  80126f:	7f 10                	jg     801281 <strtol+0xc2>
			dig = *s - '0';
  801271:	8b 45 08             	mov    0x8(%ebp),%eax
  801274:	8a 00                	mov    (%eax),%al
  801276:	0f be c0             	movsbl %al,%eax
  801279:	83 e8 30             	sub    $0x30,%eax
  80127c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80127f:	eb 42                	jmp    8012c3 <strtol+0x104>
		else if (*s >= 'a' && *s <= 'z')
  801281:	8b 45 08             	mov    0x8(%ebp),%eax
  801284:	8a 00                	mov    (%eax),%al
  801286:	3c 60                	cmp    $0x60,%al
  801288:	7e 19                	jle    8012a3 <strtol+0xe4>
  80128a:	8b 45 08             	mov    0x8(%ebp),%eax
  80128d:	8a 00                	mov    (%eax),%al
  80128f:	3c 7a                	cmp    $0x7a,%al
  801291:	7f 10                	jg     8012a3 <strtol+0xe4>
			dig = *s - 'a' + 10;
  801293:	8b 45 08             	mov    0x8(%ebp),%eax
  801296:	8a 00                	mov    (%eax),%al
  801298:	0f be c0             	movsbl %al,%eax
  80129b:	83 e8 57             	sub    $0x57,%eax
  80129e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8012a1:	eb 20                	jmp    8012c3 <strtol+0x104>
		else if (*s >= 'A' && *s <= 'Z')
  8012a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a6:	8a 00                	mov    (%eax),%al
  8012a8:	3c 40                	cmp    $0x40,%al
  8012aa:	7e 39                	jle    8012e5 <strtol+0x126>
  8012ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8012af:	8a 00                	mov    (%eax),%al
  8012b1:	3c 5a                	cmp    $0x5a,%al
  8012b3:	7f 30                	jg     8012e5 <strtol+0x126>
			dig = *s - 'A' + 10;
  8012b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b8:	8a 00                	mov    (%eax),%al
  8012ba:	0f be c0             	movsbl %al,%eax
  8012bd:	83 e8 37             	sub    $0x37,%eax
  8012c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  8012c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c6:	3b 45 10             	cmp    0x10(%ebp),%eax
  8012c9:	7d 19                	jge    8012e4 <strtol+0x125>
			break;
		s++, val = (val * base) + dig;
  8012cb:	ff 45 08             	incl   0x8(%ebp)
  8012ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8012d1:	0f af 45 10          	imul   0x10(%ebp),%eax
  8012d5:	89 c2                	mov    %eax,%edx
  8012d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012da:	01 d0                	add    %edx,%eax
  8012dc:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  8012df:	e9 7b ff ff ff       	jmp    80125f <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
			break;
  8012e4:	90                   	nop
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8012e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8012e9:	74 08                	je     8012f3 <strtol+0x134>
		*endptr = (char *) s;
  8012eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f1:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8012f3:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8012f7:	74 07                	je     801300 <strtol+0x141>
  8012f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8012fc:	f7 d8                	neg    %eax
  8012fe:	eb 03                	jmp    801303 <strtol+0x144>
  801300:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801303:	c9                   	leave  
  801304:	c3                   	ret    

00801305 <ltostr>:

void
ltostr(long value, char *str)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	83 ec 20             	sub    $0x20,%esp
	int neg = 0;
  80130b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	int s = 0 ;
  801312:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// plus/minus sign
	if (value < 0)
  801319:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80131d:	79 13                	jns    801332 <ltostr+0x2d>
	{
		neg = 1;
  80131f:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
		str[0] = '-';
  801326:	8b 45 0c             	mov    0xc(%ebp),%eax
  801329:	c6 00 2d             	movb   $0x2d,(%eax)
		value = value * -1 ;
  80132c:	f7 5d 08             	negl   0x8(%ebp)
		s++ ;
  80132f:	ff 45 f8             	incl   -0x8(%ebp)
	}
	do
	{
		int mod = value % 10 ;
  801332:	8b 45 08             	mov    0x8(%ebp),%eax
  801335:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80133a:	99                   	cltd   
  80133b:	f7 f9                	idiv   %ecx
  80133d:	89 55 ec             	mov    %edx,-0x14(%ebp)
		str[s++] = mod + '0' ;
  801340:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801343:	8d 50 01             	lea    0x1(%eax),%edx
  801346:	89 55 f8             	mov    %edx,-0x8(%ebp)
  801349:	89 c2                	mov    %eax,%edx
  80134b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80134e:	01 d0                	add    %edx,%eax
  801350:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801353:	83 c2 30             	add    $0x30,%edx
  801356:	88 10                	mov    %dl,(%eax)
		value = value / 10 ;
  801358:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80135b:	b8 67 66 66 66       	mov    $0x66666667,%eax
  801360:	f7 e9                	imul   %ecx
  801362:	c1 fa 02             	sar    $0x2,%edx
  801365:	89 c8                	mov    %ecx,%eax
  801367:	c1 f8 1f             	sar    $0x1f,%eax
  80136a:	29 c2                	sub    %eax,%edx
  80136c:	89 d0                	mov    %edx,%eax
  80136e:	89 45 08             	mov    %eax,0x8(%ebp)
	/*2023 FIX el7 :)*/
	//} while (value % 10 != 0);
	} while (value != 0);
  801371:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801375:	75 bb                	jne    801332 <ltostr+0x2d>

	//reverse the string
	int start = 0 ;
  801377:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int end = s-1 ;
  80137e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801381:	48                   	dec    %eax
  801382:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (neg)
  801385:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  801389:	74 3d                	je     8013c8 <ltostr+0xc3>
		start = 1 ;
  80138b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	while(start<end)
  801392:	eb 34                	jmp    8013c8 <ltostr+0xc3>
	{
		char tmp = str[start] ;
  801394:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801397:	8b 45 0c             	mov    0xc(%ebp),%eax
  80139a:	01 d0                	add    %edx,%eax
  80139c:	8a 00                	mov    (%eax),%al
  80139e:	88 45 eb             	mov    %al,-0x15(%ebp)
		str[start] = str[end] ;
  8013a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a7:	01 c2                	add    %eax,%edx
  8013a9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8013ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013af:	01 c8                	add    %ecx,%eax
  8013b1:	8a 00                	mov    (%eax),%al
  8013b3:	88 02                	mov    %al,(%edx)
		str[end] = tmp;
  8013b5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013bb:	01 c2                	add    %eax,%edx
  8013bd:	8a 45 eb             	mov    -0x15(%ebp),%al
  8013c0:	88 02                	mov    %al,(%edx)
		start++ ;
  8013c2:	ff 45 f4             	incl   -0xc(%ebp)
		end-- ;
  8013c5:	ff 4d f0             	decl   -0x10(%ebp)
	//reverse the string
	int start = 0 ;
	int end = s-1 ;
	if (neg)
		start = 1 ;
	while(start<end)
  8013c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013cb:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8013ce:	7c c4                	jl     801394 <ltostr+0x8f>
		str[end] = tmp;
		start++ ;
		end-- ;
	}

	str[s] = 0 ;
  8013d0:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8013d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d6:	01 d0                	add    %edx,%eax
  8013d8:	c6 00 00             	movb   $0x0,(%eax)
	// we don't properly detect overflow!

}
  8013db:	90                   	nop
  8013dc:	c9                   	leave  
  8013dd:	c3                   	ret    

008013de <strcconcat>:

void
strcconcat(const char *str1, const char *str2, char *final)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	83 ec 10             	sub    $0x10,%esp
	int len1 = strlen(str1);
  8013e4:	ff 75 08             	pushl  0x8(%ebp)
  8013e7:	e8 73 fa ff ff       	call   800e5f <strlen>
  8013ec:	83 c4 04             	add    $0x4,%esp
  8013ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int len2 = strlen(str2);
  8013f2:	ff 75 0c             	pushl  0xc(%ebp)
  8013f5:	e8 65 fa ff ff       	call   800e5f <strlen>
  8013fa:	83 c4 04             	add    $0x4,%esp
  8013fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int s = 0 ;
  801400:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for (s=0 ; s < len1 ; s++)
  801407:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80140e:	eb 17                	jmp    801427 <strcconcat+0x49>
		final[s] = str1[s] ;
  801410:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801413:	8b 45 10             	mov    0x10(%ebp),%eax
  801416:	01 c2                	add    %eax,%edx
  801418:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  80141b:	8b 45 08             	mov    0x8(%ebp),%eax
  80141e:	01 c8                	add    %ecx,%eax
  801420:	8a 00                	mov    (%eax),%al
  801422:	88 02                	mov    %al,(%edx)
strcconcat(const char *str1, const char *str2, char *final)
{
	int len1 = strlen(str1);
	int len2 = strlen(str2);
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
  801424:	ff 45 fc             	incl   -0x4(%ebp)
  801427:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80142a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  80142d:	7c e1                	jl     801410 <strcconcat+0x32>
		final[s] = str1[s] ;

	int i = 0 ;
  80142f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
	for (i=0 ; i < len2 ; i++)
  801436:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  80143d:	eb 1f                	jmp    80145e <strcconcat+0x80>
		final[s++] = str2[i] ;
  80143f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801442:	8d 50 01             	lea    0x1(%eax),%edx
  801445:	89 55 fc             	mov    %edx,-0x4(%ebp)
  801448:	89 c2                	mov    %eax,%edx
  80144a:	8b 45 10             	mov    0x10(%ebp),%eax
  80144d:	01 c2                	add    %eax,%edx
  80144f:	8b 4d f8             	mov    -0x8(%ebp),%ecx
  801452:	8b 45 0c             	mov    0xc(%ebp),%eax
  801455:	01 c8                	add    %ecx,%eax
  801457:	8a 00                	mov    (%eax),%al
  801459:	88 02                	mov    %al,(%edx)
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
		final[s] = str1[s] ;

	int i = 0 ;
	for (i=0 ; i < len2 ; i++)
  80145b:	ff 45 f8             	incl   -0x8(%ebp)
  80145e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801461:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  801464:	7c d9                	jl     80143f <strcconcat+0x61>
		final[s++] = str2[i] ;

	final[s] = 0;
  801466:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801469:	8b 45 10             	mov    0x10(%ebp),%eax
  80146c:	01 d0                	add    %edx,%eax
  80146e:	c6 00 00             	movb   $0x0,(%eax)
}
  801471:	90                   	nop
  801472:	c9                   	leave  
  801473:	c3                   	ret    

00801474 <strsplit>:
int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  801477:	8b 45 14             	mov    0x14(%ebp),%eax
  80147a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	(argv)[*argc] = 0;
  801480:	8b 45 14             	mov    0x14(%ebp),%eax
  801483:	8b 00                	mov    (%eax),%eax
  801485:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80148c:	8b 45 10             	mov    0x10(%ebp),%eax
  80148f:	01 d0                	add    %edx,%eax
  801491:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  801497:	eb 0c                	jmp    8014a5 <strsplit+0x31>
			*string++ = 0;
  801499:	8b 45 08             	mov    0x8(%ebp),%eax
  80149c:	8d 50 01             	lea    0x1(%eax),%edx
  80149f:	89 55 08             	mov    %edx,0x8(%ebp)
  8014a2:	c6 00 00             	movb   $0x0,(%eax)
	*argc = 0;
	(argv)[*argc] = 0;
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  8014a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a8:	8a 00                	mov    (%eax),%al
  8014aa:	84 c0                	test   %al,%al
  8014ac:	74 18                	je     8014c6 <strsplit+0x52>
  8014ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b1:	8a 00                	mov    (%eax),%al
  8014b3:	0f be c0             	movsbl %al,%eax
  8014b6:	50                   	push   %eax
  8014b7:	ff 75 0c             	pushl  0xc(%ebp)
  8014ba:	e8 32 fb ff ff       	call   800ff1 <strchr>
  8014bf:	83 c4 08             	add    $0x8,%esp
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	75 d3                	jne    801499 <strsplit+0x25>
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
  8014c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c9:	8a 00                	mov    (%eax),%al
  8014cb:	84 c0                	test   %al,%al
  8014cd:	74 5a                	je     801529 <strsplit+0xb5>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1)
  8014cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d2:	8b 00                	mov    (%eax),%eax
  8014d4:	83 f8 0f             	cmp    $0xf,%eax
  8014d7:	75 07                	jne    8014e0 <strsplit+0x6c>
		{
			return 0;
  8014d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8014de:	eb 66                	jmp    801546 <strsplit+0xd2>
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  8014e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e3:	8b 00                	mov    (%eax),%eax
  8014e5:	8d 48 01             	lea    0x1(%eax),%ecx
  8014e8:	8b 55 14             	mov    0x14(%ebp),%edx
  8014eb:	89 0a                	mov    %ecx,(%edx)
  8014ed:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8014f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8014f7:	01 c2                	add    %eax,%edx
  8014f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fc:	89 02                	mov    %eax,(%edx)
		while (*string && !strchr(SPLIT_CHARS, *string))
  8014fe:	eb 03                	jmp    801503 <strsplit+0x8f>
			string++;
  801500:	ff 45 08             	incl   0x8(%ebp)
			return 0;
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
  801503:	8b 45 08             	mov    0x8(%ebp),%eax
  801506:	8a 00                	mov    (%eax),%al
  801508:	84 c0                	test   %al,%al
  80150a:	74 8b                	je     801497 <strsplit+0x23>
  80150c:	8b 45 08             	mov    0x8(%ebp),%eax
  80150f:	8a 00                	mov    (%eax),%al
  801511:	0f be c0             	movsbl %al,%eax
  801514:	50                   	push   %eax
  801515:	ff 75 0c             	pushl  0xc(%ebp)
  801518:	e8 d4 fa ff ff       	call   800ff1 <strchr>
  80151d:	83 c4 08             	add    $0x8,%esp
  801520:	85 c0                	test   %eax,%eax
  801522:	74 dc                	je     801500 <strsplit+0x8c>
			string++;
	}
  801524:	e9 6e ff ff ff       	jmp    801497 <strsplit+0x23>
		while (*string && strchr(SPLIT_CHARS, *string))
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
			break;
  801529:	90                   	nop
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
			string++;
	}
	(argv)[*argc] = 0;
  80152a:	8b 45 14             	mov    0x14(%ebp),%eax
  80152d:	8b 00                	mov    (%eax),%eax
  80152f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801536:	8b 45 10             	mov    0x10(%ebp),%eax
  801539:	01 d0                	add    %edx,%eax
  80153b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return 1 ;
  801541:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801546:	c9                   	leave  
  801547:	c3                   	ret    

00801548 <str2lower>:


char* str2lower(char *dst, const char *src)
{
  801548:	55                   	push   %ebp
  801549:	89 e5                	mov    %esp,%ebp
  80154b:	83 ec 08             	sub    $0x8,%esp
	//[PROJECT]
	panic("str2lower is not implemented yet!");
  80154e:	83 ec 04             	sub    $0x4,%esp
  801551:	68 5c 26 80 00       	push   $0x80265c
  801556:	68 3f 01 00 00       	push   $0x13f
  80155b:	68 7e 26 80 00       	push   $0x80267e
  801560:	e8 a1 ed ff ff       	call   800306 <_panic>

00801565 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline uint32
syscall(int num, uint32 a1, uint32 a2, uint32 a3, uint32 a4, uint32 a5)
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	57                   	push   %edi
  801569:	56                   	push   %esi
  80156a:	53                   	push   %ebx
  80156b:	83 ec 10             	sub    $0x10,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80156e:	8b 45 08             	mov    0x8(%ebp),%eax
  801571:	8b 55 0c             	mov    0xc(%ebp),%edx
  801574:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801577:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80157a:	8b 7d 18             	mov    0x18(%ebp),%edi
  80157d:	8b 75 1c             	mov    0x1c(%ebp),%esi
  801580:	cd 30                	int    $0x30
  801582:	89 45 f0             	mov    %eax,-0x10(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	return ret;
  801585:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	5b                   	pop    %ebx
  80158c:	5e                   	pop    %esi
  80158d:	5f                   	pop    %edi
  80158e:	5d                   	pop    %ebp
  80158f:	c3                   	ret    

00801590 <sys_cputs>:

void
sys_cputs(const char *s, uint32 len, uint8 printProgName)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	83 ec 04             	sub    $0x4,%esp
  801596:	8b 45 10             	mov    0x10(%ebp),%eax
  801599:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputs, (uint32) s, len, (uint32)printProgName, 0, 0);
  80159c:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  8015a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a3:	6a 00                	push   $0x0
  8015a5:	6a 00                	push   $0x0
  8015a7:	52                   	push   %edx
  8015a8:	ff 75 0c             	pushl  0xc(%ebp)
  8015ab:	50                   	push   %eax
  8015ac:	6a 00                	push   $0x0
  8015ae:	e8 b2 ff ff ff       	call   801565 <syscall>
  8015b3:	83 c4 18             	add    $0x18,%esp
}
  8015b6:	90                   	nop
  8015b7:	c9                   	leave  
  8015b8:	c3                   	ret    

008015b9 <sys_cgetc>:

int
sys_cgetc(void)
{
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
  8015bc:	6a 00                	push   $0x0
  8015be:	6a 00                	push   $0x0
  8015c0:	6a 00                	push   $0x0
  8015c2:	6a 00                	push   $0x0
  8015c4:	6a 00                	push   $0x0
  8015c6:	6a 02                	push   $0x2
  8015c8:	e8 98 ff ff ff       	call   801565 <syscall>
  8015cd:	83 c4 18             	add    $0x18,%esp
}
  8015d0:	c9                   	leave  
  8015d1:	c3                   	ret    

008015d2 <sys_lock_cons>:

void sys_lock_cons(void)
{
  8015d2:	55                   	push   %ebp
  8015d3:	89 e5                	mov    %esp,%ebp
	syscall(SYS_lock_cons, 0, 0, 0, 0, 0);
  8015d5:	6a 00                	push   $0x0
  8015d7:	6a 00                	push   $0x0
  8015d9:	6a 00                	push   $0x0
  8015db:	6a 00                	push   $0x0
  8015dd:	6a 00                	push   $0x0
  8015df:	6a 03                	push   $0x3
  8015e1:	e8 7f ff ff ff       	call   801565 <syscall>
  8015e6:	83 c4 18             	add    $0x18,%esp
}
  8015e9:	90                   	nop
  8015ea:	c9                   	leave  
  8015eb:	c3                   	ret    

008015ec <sys_unlock_cons>:
void sys_unlock_cons(void)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
	syscall(SYS_unlock_cons, 0, 0, 0, 0, 0);
  8015ef:	6a 00                	push   $0x0
  8015f1:	6a 00                	push   $0x0
  8015f3:	6a 00                	push   $0x0
  8015f5:	6a 00                	push   $0x0
  8015f7:	6a 00                	push   $0x0
  8015f9:	6a 04                	push   $0x4
  8015fb:	e8 65 ff ff ff       	call   801565 <syscall>
  801600:	83 c4 18             	add    $0x18,%esp
}
  801603:	90                   	nop
  801604:	c9                   	leave  
  801605:	c3                   	ret    

00801606 <__sys_allocate_page>:

int __sys_allocate_page(void *va, int perm)
{
  801606:	55                   	push   %ebp
  801607:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
  801609:	8b 55 0c             	mov    0xc(%ebp),%edx
  80160c:	8b 45 08             	mov    0x8(%ebp),%eax
  80160f:	6a 00                	push   $0x0
  801611:	6a 00                	push   $0x0
  801613:	6a 00                	push   $0x0
  801615:	52                   	push   %edx
  801616:	50                   	push   %eax
  801617:	6a 08                	push   $0x8
  801619:	e8 47 ff ff ff       	call   801565 <syscall>
  80161e:	83 c4 18             	add    $0x18,%esp
}
  801621:	c9                   	leave  
  801622:	c3                   	ret    

00801623 <__sys_map_frame>:

int __sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  801623:	55                   	push   %ebp
  801624:	89 e5                	mov    %esp,%ebp
  801626:	56                   	push   %esi
  801627:	53                   	push   %ebx
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
  801628:	8b 75 18             	mov    0x18(%ebp),%esi
  80162b:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80162e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801631:	8b 55 0c             	mov    0xc(%ebp),%edx
  801634:	8b 45 08             	mov    0x8(%ebp),%eax
  801637:	56                   	push   %esi
  801638:	53                   	push   %ebx
  801639:	51                   	push   %ecx
  80163a:	52                   	push   %edx
  80163b:	50                   	push   %eax
  80163c:	6a 09                	push   $0x9
  80163e:	e8 22 ff ff ff       	call   801565 <syscall>
  801643:	83 c4 18             	add    $0x18,%esp
}
  801646:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801649:	5b                   	pop    %ebx
  80164a:	5e                   	pop    %esi
  80164b:	5d                   	pop    %ebp
  80164c:	c3                   	ret    

0080164d <__sys_unmap_frame>:

int __sys_unmap_frame(int32 envid, void *va)
{
  80164d:	55                   	push   %ebp
  80164e:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
  801650:	8b 55 0c             	mov    0xc(%ebp),%edx
  801653:	8b 45 08             	mov    0x8(%ebp),%eax
  801656:	6a 00                	push   $0x0
  801658:	6a 00                	push   $0x0
  80165a:	6a 00                	push   $0x0
  80165c:	52                   	push   %edx
  80165d:	50                   	push   %eax
  80165e:	6a 0a                	push   $0xa
  801660:	e8 00 ff ff ff       	call   801565 <syscall>
  801665:	83 c4 18             	add    $0x18,%esp
}
  801668:	c9                   	leave  
  801669:	c3                   	ret    

0080166a <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
  80166d:	6a 00                	push   $0x0
  80166f:	6a 00                	push   $0x0
  801671:	6a 00                	push   $0x0
  801673:	ff 75 0c             	pushl  0xc(%ebp)
  801676:	ff 75 08             	pushl  0x8(%ebp)
  801679:	6a 0b                	push   $0xb
  80167b:	e8 e5 fe ff ff       	call   801565 <syscall>
  801680:	83 c4 18             	add    $0x18,%esp
}
  801683:	c9                   	leave  
  801684:	c3                   	ret    

00801685 <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
  801688:	6a 00                	push   $0x0
  80168a:	6a 00                	push   $0x0
  80168c:	6a 00                	push   $0x0
  80168e:	6a 00                	push   $0x0
  801690:	6a 00                	push   $0x0
  801692:	6a 0c                	push   $0xc
  801694:	e8 cc fe ff ff       	call   801565 <syscall>
  801699:	83 c4 18             	add    $0x18,%esp
}
  80169c:	c9                   	leave  
  80169d:	c3                   	ret    

0080169e <sys_calculate_modified_frames>:
uint32 sys_calculate_modified_frames()
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_modified_frames, 0, 0, 0, 0, 0);
  8016a1:	6a 00                	push   $0x0
  8016a3:	6a 00                	push   $0x0
  8016a5:	6a 00                	push   $0x0
  8016a7:	6a 00                	push   $0x0
  8016a9:	6a 00                	push   $0x0
  8016ab:	6a 0d                	push   $0xd
  8016ad:	e8 b3 fe ff ff       	call   801565 <syscall>
  8016b2:	83 c4 18             	add    $0x18,%esp
}
  8016b5:	c9                   	leave  
  8016b6:	c3                   	ret    

008016b7 <sys_calculate_notmod_frames>:

uint32 sys_calculate_notmod_frames()
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_notmod_frames, 0, 0, 0, 0, 0);
  8016ba:	6a 00                	push   $0x0
  8016bc:	6a 00                	push   $0x0
  8016be:	6a 00                	push   $0x0
  8016c0:	6a 00                	push   $0x0
  8016c2:	6a 00                	push   $0x0
  8016c4:	6a 0e                	push   $0xe
  8016c6:	e8 9a fe ff ff       	call   801565 <syscall>
  8016cb:	83 c4 18             	add    $0x18,%esp
}
  8016ce:	c9                   	leave  
  8016cf:	c3                   	ret    

008016d0 <sys_pf_calculate_allocated_pages>:

int sys_pf_calculate_allocated_pages()
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_pf_calc_allocated_pages, 0,0,0,0,0);
  8016d3:	6a 00                	push   $0x0
  8016d5:	6a 00                	push   $0x0
  8016d7:	6a 00                	push   $0x0
  8016d9:	6a 00                	push   $0x0
  8016db:	6a 00                	push   $0x0
  8016dd:	6a 0f                	push   $0xf
  8016df:	e8 81 fe ff ff       	call   801565 <syscall>
  8016e4:	83 c4 18             	add    $0x18,%esp
}
  8016e7:	c9                   	leave  
  8016e8:	c3                   	ret    

008016e9 <sys_calculate_pages_tobe_removed_ready_exit>:

int sys_calculate_pages_tobe_removed_ready_exit(uint32 WS_or_MEMORY_flag)
{
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calculate_pages_tobe_removed_ready_exit, WS_or_MEMORY_flag,0,0,0,0);
  8016ec:	6a 00                	push   $0x0
  8016ee:	6a 00                	push   $0x0
  8016f0:	6a 00                	push   $0x0
  8016f2:	6a 00                	push   $0x0
  8016f4:	ff 75 08             	pushl  0x8(%ebp)
  8016f7:	6a 10                	push   $0x10
  8016f9:	e8 67 fe ff ff       	call   801565 <syscall>
  8016fe:	83 c4 18             	add    $0x18,%esp
}
  801701:	c9                   	leave  
  801702:	c3                   	ret    

00801703 <sys_scarce_memory>:

void sys_scarce_memory()
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
	syscall(SYS_scarce_memory,0,0,0,0,0);
  801706:	6a 00                	push   $0x0
  801708:	6a 00                	push   $0x0
  80170a:	6a 00                	push   $0x0
  80170c:	6a 00                	push   $0x0
  80170e:	6a 00                	push   $0x0
  801710:	6a 11                	push   $0x11
  801712:	e8 4e fe ff ff       	call   801565 <syscall>
  801717:	83 c4 18             	add    $0x18,%esp
}
  80171a:	90                   	nop
  80171b:	c9                   	leave  
  80171c:	c3                   	ret    

0080171d <sys_cputc>:

void
sys_cputc(const char c)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	83 ec 04             	sub    $0x4,%esp
  801723:	8b 45 08             	mov    0x8(%ebp),%eax
  801726:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputc, (uint32) c, 0, 0, 0, 0);
  801729:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  80172d:	6a 00                	push   $0x0
  80172f:	6a 00                	push   $0x0
  801731:	6a 00                	push   $0x0
  801733:	6a 00                	push   $0x0
  801735:	50                   	push   %eax
  801736:	6a 01                	push   $0x1
  801738:	e8 28 fe ff ff       	call   801565 <syscall>
  80173d:	83 c4 18             	add    $0x18,%esp
}
  801740:	90                   	nop
  801741:	c9                   	leave  
  801742:	c3                   	ret    

00801743 <sys_clear_ffl>:


//NEW'12: BONUS2 Testing
void
sys_clear_ffl()
{
  801743:	55                   	push   %ebp
  801744:	89 e5                	mov    %esp,%ebp
	syscall(SYS_clearFFL,0, 0, 0, 0, 0);
  801746:	6a 00                	push   $0x0
  801748:	6a 00                	push   $0x0
  80174a:	6a 00                	push   $0x0
  80174c:	6a 00                	push   $0x0
  80174e:	6a 00                	push   $0x0
  801750:	6a 14                	push   $0x14
  801752:	e8 0e fe ff ff       	call   801565 <syscall>
  801757:	83 c4 18             	add    $0x18,%esp
}
  80175a:	90                   	nop
  80175b:	c9                   	leave  
  80175c:	c3                   	ret    

0080175d <sys_createSharedObject>:

int sys_createSharedObject(char* shareName, uint32 size, uint8 isWritable, void* virtual_address)
{
  80175d:	55                   	push   %ebp
  80175e:	89 e5                	mov    %esp,%ebp
  801760:	83 ec 04             	sub    $0x4,%esp
  801763:	8b 45 10             	mov    0x10(%ebp),%eax
  801766:	88 45 fc             	mov    %al,-0x4(%ebp)
	return syscall(SYS_create_shared_object,(uint32)shareName, (uint32)size, isWritable, (uint32)virtual_address,  0);
  801769:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80176c:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  801770:	8b 45 08             	mov    0x8(%ebp),%eax
  801773:	6a 00                	push   $0x0
  801775:	51                   	push   %ecx
  801776:	52                   	push   %edx
  801777:	ff 75 0c             	pushl  0xc(%ebp)
  80177a:	50                   	push   %eax
  80177b:	6a 15                	push   $0x15
  80177d:	e8 e3 fd ff ff       	call   801565 <syscall>
  801782:	83 c4 18             	add    $0x18,%esp
}
  801785:	c9                   	leave  
  801786:	c3                   	ret    

00801787 <sys_getSizeOfSharedObject>:

//2017:
int sys_getSizeOfSharedObject(int32 ownerID, char* shareName)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_size_of_shared_object,(uint32) ownerID, (uint32)shareName, 0, 0, 0);
  80178a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80178d:	8b 45 08             	mov    0x8(%ebp),%eax
  801790:	6a 00                	push   $0x0
  801792:	6a 00                	push   $0x0
  801794:	6a 00                	push   $0x0
  801796:	52                   	push   %edx
  801797:	50                   	push   %eax
  801798:	6a 16                	push   $0x16
  80179a:	e8 c6 fd ff ff       	call   801565 <syscall>
  80179f:	83 c4 18             	add    $0x18,%esp
}
  8017a2:	c9                   	leave  
  8017a3:	c3                   	ret    

008017a4 <sys_getSharedObject>:
//==========

int sys_getSharedObject(int32 ownerID, char* shareName, void* virtual_address)
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_shared_object,(uint32) ownerID, (uint32)shareName, (uint32)virtual_address, 0, 0);
  8017a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b0:	6a 00                	push   $0x0
  8017b2:	6a 00                	push   $0x0
  8017b4:	51                   	push   %ecx
  8017b5:	52                   	push   %edx
  8017b6:	50                   	push   %eax
  8017b7:	6a 17                	push   $0x17
  8017b9:	e8 a7 fd ff ff       	call   801565 <syscall>
  8017be:	83 c4 18             	add    $0x18,%esp
}
  8017c1:	c9                   	leave  
  8017c2:	c3                   	ret    

008017c3 <sys_freeSharedObject>:

int sys_freeSharedObject(int32 sharedObjectID, void *startVA)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_free_shared_object,(uint32) sharedObjectID, (uint32) startVA, 0, 0, 0);
  8017c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cc:	6a 00                	push   $0x0
  8017ce:	6a 00                	push   $0x0
  8017d0:	6a 00                	push   $0x0
  8017d2:	52                   	push   %edx
  8017d3:	50                   	push   %eax
  8017d4:	6a 18                	push   $0x18
  8017d6:	e8 8a fd ff ff       	call   801565 <syscall>
  8017db:	83 c4 18             	add    $0x18,%esp
}
  8017de:	c9                   	leave  
  8017df:	c3                   	ret    

008017e0 <sys_create_env>:

int sys_create_env(char* programName, unsigned int page_WS_size,unsigned int LRU_second_list_size,unsigned int percent_WS_pages_to_remove)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_create_env,(uint32)programName, (uint32)page_WS_size,(uint32)LRU_second_list_size, (uint32)percent_WS_pages_to_remove, 0);
  8017e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e6:	6a 00                	push   $0x0
  8017e8:	ff 75 14             	pushl  0x14(%ebp)
  8017eb:	ff 75 10             	pushl  0x10(%ebp)
  8017ee:	ff 75 0c             	pushl  0xc(%ebp)
  8017f1:	50                   	push   %eax
  8017f2:	6a 19                	push   $0x19
  8017f4:	e8 6c fd ff ff       	call   801565 <syscall>
  8017f9:	83 c4 18             	add    $0x18,%esp
}
  8017fc:	c9                   	leave  
  8017fd:	c3                   	ret    

008017fe <sys_run_env>:

void sys_run_env(int32 envId)
{
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
	syscall(SYS_run_env, (int32)envId, 0, 0, 0, 0);
  801801:	8b 45 08             	mov    0x8(%ebp),%eax
  801804:	6a 00                	push   $0x0
  801806:	6a 00                	push   $0x0
  801808:	6a 00                	push   $0x0
  80180a:	6a 00                	push   $0x0
  80180c:	50                   	push   %eax
  80180d:	6a 1a                	push   $0x1a
  80180f:	e8 51 fd ff ff       	call   801565 <syscall>
  801814:	83 c4 18             	add    $0x18,%esp
}
  801817:	90                   	nop
  801818:	c9                   	leave  
  801819:	c3                   	ret    

0080181a <sys_destroy_env>:

int sys_destroy_env(int32  envid)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_destroy_env, envid, 0, 0, 0, 0);
  80181d:	8b 45 08             	mov    0x8(%ebp),%eax
  801820:	6a 00                	push   $0x0
  801822:	6a 00                	push   $0x0
  801824:	6a 00                	push   $0x0
  801826:	6a 00                	push   $0x0
  801828:	50                   	push   %eax
  801829:	6a 1b                	push   $0x1b
  80182b:	e8 35 fd ff ff       	call   801565 <syscall>
  801830:	83 c4 18             	add    $0x18,%esp
}
  801833:	c9                   	leave  
  801834:	c3                   	ret    

00801835 <sys_getenvid>:

int32 sys_getenvid(void)
{
  801835:	55                   	push   %ebp
  801836:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
  801838:	6a 00                	push   $0x0
  80183a:	6a 00                	push   $0x0
  80183c:	6a 00                	push   $0x0
  80183e:	6a 00                	push   $0x0
  801840:	6a 00                	push   $0x0
  801842:	6a 05                	push   $0x5
  801844:	e8 1c fd ff ff       	call   801565 <syscall>
  801849:	83 c4 18             	add    $0x18,%esp
}
  80184c:	c9                   	leave  
  80184d:	c3                   	ret    

0080184e <sys_getenvindex>:

//2017
int32 sys_getenvindex(void)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvindex, 0, 0, 0, 0, 0);
  801851:	6a 00                	push   $0x0
  801853:	6a 00                	push   $0x0
  801855:	6a 00                	push   $0x0
  801857:	6a 00                	push   $0x0
  801859:	6a 00                	push   $0x0
  80185b:	6a 06                	push   $0x6
  80185d:	e8 03 fd ff ff       	call   801565 <syscall>
  801862:	83 c4 18             	add    $0x18,%esp
}
  801865:	c9                   	leave  
  801866:	c3                   	ret    

00801867 <sys_getparentenvid>:

int32 sys_getparentenvid(void)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getparentenvid, 0, 0, 0, 0, 0);
  80186a:	6a 00                	push   $0x0
  80186c:	6a 00                	push   $0x0
  80186e:	6a 00                	push   $0x0
  801870:	6a 00                	push   $0x0
  801872:	6a 00                	push   $0x0
  801874:	6a 07                	push   $0x7
  801876:	e8 ea fc ff ff       	call   801565 <syscall>
  80187b:	83 c4 18             	add    $0x18,%esp
}
  80187e:	c9                   	leave  
  80187f:	c3                   	ret    

00801880 <sys_exit_env>:


void sys_exit_env(void)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
	syscall(SYS_exit_env, 0, 0, 0, 0, 0);
  801883:	6a 00                	push   $0x0
  801885:	6a 00                	push   $0x0
  801887:	6a 00                	push   $0x0
  801889:	6a 00                	push   $0x0
  80188b:	6a 00                	push   $0x0
  80188d:	6a 1c                	push   $0x1c
  80188f:	e8 d1 fc ff ff       	call   801565 <syscall>
  801894:	83 c4 18             	add    $0x18,%esp
}
  801897:	90                   	nop
  801898:	c9                   	leave  
  801899:	c3                   	ret    

0080189a <sys_get_virtual_time>:


struct uint64 sys_get_virtual_time()
{
  80189a:	55                   	push   %ebp
  80189b:	89 e5                	mov    %esp,%ebp
  80189d:	83 ec 10             	sub    $0x10,%esp
	struct uint64 result;
	syscall(SYS_get_virtual_time, (uint32)&(result.low), (uint32)&(result.hi), 0, 0, 0);
  8018a0:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8018a3:	8d 50 04             	lea    0x4(%eax),%edx
  8018a6:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8018a9:	6a 00                	push   $0x0
  8018ab:	6a 00                	push   $0x0
  8018ad:	6a 00                	push   $0x0
  8018af:	52                   	push   %edx
  8018b0:	50                   	push   %eax
  8018b1:	6a 1d                	push   $0x1d
  8018b3:	e8 ad fc ff ff       	call   801565 <syscall>
  8018b8:	83 c4 18             	add    $0x18,%esp
	return result;
  8018bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018be:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8018c1:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8018c4:	89 01                	mov    %eax,(%ecx)
  8018c6:	89 51 04             	mov    %edx,0x4(%ecx)
}
  8018c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cc:	c9                   	leave  
  8018cd:	c2 04 00             	ret    $0x4

008018d0 <sys_move_user_mem>:

// 2014
void sys_move_user_mem(uint32 src_virtual_address, uint32 dst_virtual_address, uint32 size)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
	syscall(SYS_move_user_mem, src_virtual_address, dst_virtual_address, size, 0, 0);
  8018d3:	6a 00                	push   $0x0
  8018d5:	6a 00                	push   $0x0
  8018d7:	ff 75 10             	pushl  0x10(%ebp)
  8018da:	ff 75 0c             	pushl  0xc(%ebp)
  8018dd:	ff 75 08             	pushl  0x8(%ebp)
  8018e0:	6a 13                	push   $0x13
  8018e2:	e8 7e fc ff ff       	call   801565 <syscall>
  8018e7:	83 c4 18             	add    $0x18,%esp
	return ;
  8018ea:	90                   	nop
}
  8018eb:	c9                   	leave  
  8018ec:	c3                   	ret    

008018ed <sys_rcr2>:
uint32 sys_rcr2()
{
  8018ed:	55                   	push   %ebp
  8018ee:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_rcr2, 0, 0, 0, 0, 0);
  8018f0:	6a 00                	push   $0x0
  8018f2:	6a 00                	push   $0x0
  8018f4:	6a 00                	push   $0x0
  8018f6:	6a 00                	push   $0x0
  8018f8:	6a 00                	push   $0x0
  8018fa:	6a 1e                	push   $0x1e
  8018fc:	e8 64 fc ff ff       	call   801565 <syscall>
  801901:	83 c4 18             	add    $0x18,%esp
}
  801904:	c9                   	leave  
  801905:	c3                   	ret    

00801906 <sys_bypassPageFault>:

void sys_bypassPageFault(uint8 instrLength)
{
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
  801909:	83 ec 04             	sub    $0x4,%esp
  80190c:	8b 45 08             	mov    0x8(%ebp),%eax
  80190f:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_bypassPageFault, instrLength, 0, 0, 0, 0);
  801912:	0f b6 45 fc          	movzbl -0x4(%ebp),%eax
  801916:	6a 00                	push   $0x0
  801918:	6a 00                	push   $0x0
  80191a:	6a 00                	push   $0x0
  80191c:	6a 00                	push   $0x0
  80191e:	50                   	push   %eax
  80191f:	6a 1f                	push   $0x1f
  801921:	e8 3f fc ff ff       	call   801565 <syscall>
  801926:	83 c4 18             	add    $0x18,%esp
	return ;
  801929:	90                   	nop
}
  80192a:	c9                   	leave  
  80192b:	c3                   	ret    

0080192c <rsttst>:
void rsttst()
{
  80192c:	55                   	push   %ebp
  80192d:	89 e5                	mov    %esp,%ebp
	syscall(SYS_rsttst, 0, 0, 0, 0, 0);
  80192f:	6a 00                	push   $0x0
  801931:	6a 00                	push   $0x0
  801933:	6a 00                	push   $0x0
  801935:	6a 00                	push   $0x0
  801937:	6a 00                	push   $0x0
  801939:	6a 21                	push   $0x21
  80193b:	e8 25 fc ff ff       	call   801565 <syscall>
  801940:	83 c4 18             	add    $0x18,%esp
	return ;
  801943:	90                   	nop
}
  801944:	c9                   	leave  
  801945:	c3                   	ret    

00801946 <tst>:
void tst(uint32 n, uint32 v1, uint32 v2, char c, int inv)
{
  801946:	55                   	push   %ebp
  801947:	89 e5                	mov    %esp,%ebp
  801949:	83 ec 04             	sub    $0x4,%esp
  80194c:	8b 45 14             	mov    0x14(%ebp),%eax
  80194f:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_testNum, n, v1, v2, c, inv);
  801952:	8b 55 18             	mov    0x18(%ebp),%edx
  801955:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  801959:	52                   	push   %edx
  80195a:	50                   	push   %eax
  80195b:	ff 75 10             	pushl  0x10(%ebp)
  80195e:	ff 75 0c             	pushl  0xc(%ebp)
  801961:	ff 75 08             	pushl  0x8(%ebp)
  801964:	6a 20                	push   $0x20
  801966:	e8 fa fb ff ff       	call   801565 <syscall>
  80196b:	83 c4 18             	add    $0x18,%esp
	return ;
  80196e:	90                   	nop
}
  80196f:	c9                   	leave  
  801970:	c3                   	ret    

00801971 <chktst>:
void chktst(uint32 n)
{
  801971:	55                   	push   %ebp
  801972:	89 e5                	mov    %esp,%ebp
	syscall(SYS_chktst, n, 0, 0, 0, 0);
  801974:	6a 00                	push   $0x0
  801976:	6a 00                	push   $0x0
  801978:	6a 00                	push   $0x0
  80197a:	6a 00                	push   $0x0
  80197c:	ff 75 08             	pushl  0x8(%ebp)
  80197f:	6a 22                	push   $0x22
  801981:	e8 df fb ff ff       	call   801565 <syscall>
  801986:	83 c4 18             	add    $0x18,%esp
	return ;
  801989:	90                   	nop
}
  80198a:	c9                   	leave  
  80198b:	c3                   	ret    

0080198c <inctst>:

void inctst()
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
	syscall(SYS_inctst, 0, 0, 0, 0, 0);
  80198f:	6a 00                	push   $0x0
  801991:	6a 00                	push   $0x0
  801993:	6a 00                	push   $0x0
  801995:	6a 00                	push   $0x0
  801997:	6a 00                	push   $0x0
  801999:	6a 23                	push   $0x23
  80199b:	e8 c5 fb ff ff       	call   801565 <syscall>
  8019a0:	83 c4 18             	add    $0x18,%esp
	return ;
  8019a3:	90                   	nop
}
  8019a4:	c9                   	leave  
  8019a5:	c3                   	ret    

008019a6 <gettst>:
uint32 gettst()
{
  8019a6:	55                   	push   %ebp
  8019a7:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_gettst, 0, 0, 0, 0, 0);
  8019a9:	6a 00                	push   $0x0
  8019ab:	6a 00                	push   $0x0
  8019ad:	6a 00                	push   $0x0
  8019af:	6a 00                	push   $0x0
  8019b1:	6a 00                	push   $0x0
  8019b3:	6a 24                	push   $0x24
  8019b5:	e8 ab fb ff ff       	call   801565 <syscall>
  8019ba:	83 c4 18             	add    $0x18,%esp
}
  8019bd:	c9                   	leave  
  8019be:	c3                   	ret    

008019bf <sys_isUHeapPlacementStrategyFIRSTFIT>:


//2015
uint32 sys_isUHeapPlacementStrategyFIRSTFIT()
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  8019c5:	6a 00                	push   $0x0
  8019c7:	6a 00                	push   $0x0
  8019c9:	6a 00                	push   $0x0
  8019cb:	6a 00                	push   $0x0
  8019cd:	6a 00                	push   $0x0
  8019cf:	6a 25                	push   $0x25
  8019d1:	e8 8f fb ff ff       	call   801565 <syscall>
  8019d6:	83 c4 18             	add    $0x18,%esp
  8019d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_FIRSTFIT)
  8019dc:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
  8019e0:	75 07                	jne    8019e9 <sys_isUHeapPlacementStrategyFIRSTFIT+0x2a>
		return 1;
  8019e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8019e7:	eb 05                	jmp    8019ee <sys_isUHeapPlacementStrategyFIRSTFIT+0x2f>
	else
		return 0;
  8019e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019ee:	c9                   	leave  
  8019ef:	c3                   	ret    

008019f0 <sys_isUHeapPlacementStrategyBESTFIT>:
uint32 sys_isUHeapPlacementStrategyBESTFIT()
{
  8019f0:	55                   	push   %ebp
  8019f1:	89 e5                	mov    %esp,%ebp
  8019f3:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  8019f6:	6a 00                	push   $0x0
  8019f8:	6a 00                	push   $0x0
  8019fa:	6a 00                	push   $0x0
  8019fc:	6a 00                	push   $0x0
  8019fe:	6a 00                	push   $0x0
  801a00:	6a 25                	push   $0x25
  801a02:	e8 5e fb ff ff       	call   801565 <syscall>
  801a07:	83 c4 18             	add    $0x18,%esp
  801a0a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_BESTFIT)
  801a0d:	83 7d fc 02          	cmpl   $0x2,-0x4(%ebp)
  801a11:	75 07                	jne    801a1a <sys_isUHeapPlacementStrategyBESTFIT+0x2a>
		return 1;
  801a13:	b8 01 00 00 00       	mov    $0x1,%eax
  801a18:	eb 05                	jmp    801a1f <sys_isUHeapPlacementStrategyBESTFIT+0x2f>
	else
		return 0;
  801a1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a1f:	c9                   	leave  
  801a20:	c3                   	ret    

00801a21 <sys_isUHeapPlacementStrategyNEXTFIT>:
uint32 sys_isUHeapPlacementStrategyNEXTFIT()
{
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  801a27:	6a 00                	push   $0x0
  801a29:	6a 00                	push   $0x0
  801a2b:	6a 00                	push   $0x0
  801a2d:	6a 00                	push   $0x0
  801a2f:	6a 00                	push   $0x0
  801a31:	6a 25                	push   $0x25
  801a33:	e8 2d fb ff ff       	call   801565 <syscall>
  801a38:	83 c4 18             	add    $0x18,%esp
  801a3b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_NEXTFIT)
  801a3e:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
  801a42:	75 07                	jne    801a4b <sys_isUHeapPlacementStrategyNEXTFIT+0x2a>
		return 1;
  801a44:	b8 01 00 00 00       	mov    $0x1,%eax
  801a49:	eb 05                	jmp    801a50 <sys_isUHeapPlacementStrategyNEXTFIT+0x2f>
	else
		return 0;
  801a4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a50:	c9                   	leave  
  801a51:	c3                   	ret    

00801a52 <sys_isUHeapPlacementStrategyWORSTFIT>:
uint32 sys_isUHeapPlacementStrategyWORSTFIT()
{
  801a52:	55                   	push   %ebp
  801a53:	89 e5                	mov    %esp,%ebp
  801a55:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  801a58:	6a 00                	push   $0x0
  801a5a:	6a 00                	push   $0x0
  801a5c:	6a 00                	push   $0x0
  801a5e:	6a 00                	push   $0x0
  801a60:	6a 00                	push   $0x0
  801a62:	6a 25                	push   $0x25
  801a64:	e8 fc fa ff ff       	call   801565 <syscall>
  801a69:	83 c4 18             	add    $0x18,%esp
  801a6c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_WORSTFIT)
  801a6f:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
  801a73:	75 07                	jne    801a7c <sys_isUHeapPlacementStrategyWORSTFIT+0x2a>
		return 1;
  801a75:	b8 01 00 00 00       	mov    $0x1,%eax
  801a7a:	eb 05                	jmp    801a81 <sys_isUHeapPlacementStrategyWORSTFIT+0x2f>
	else
		return 0;
  801a7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a81:	c9                   	leave  
  801a82:	c3                   	ret    

00801a83 <sys_set_uheap_strategy>:

void sys_set_uheap_strategy(uint32 heapStrategy)
{
  801a83:	55                   	push   %ebp
  801a84:	89 e5                	mov    %esp,%ebp
	syscall(SYS_set_heap_strategy, heapStrategy, 0, 0, 0, 0);
  801a86:	6a 00                	push   $0x0
  801a88:	6a 00                	push   $0x0
  801a8a:	6a 00                	push   $0x0
  801a8c:	6a 00                	push   $0x0
  801a8e:	ff 75 08             	pushl  0x8(%ebp)
  801a91:	6a 26                	push   $0x26
  801a93:	e8 cd fa ff ff       	call   801565 <syscall>
  801a98:	83 c4 18             	add    $0x18,%esp
	return ;
  801a9b:	90                   	nop
}
  801a9c:	c9                   	leave  
  801a9d:	c3                   	ret    

00801a9e <sys_check_LRU_lists>:

//2020
int sys_check_LRU_lists(uint32* active_list_content, uint32* second_list_content, int actual_active_list_size, int actual_second_list_size)
{
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	53                   	push   %ebx
	return syscall(SYS_check_LRU_lists, (uint32)active_list_content, (uint32)second_list_content, (uint32)actual_active_list_size, (uint32)actual_second_list_size, 0);
  801aa2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801aa5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801aa8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aab:	8b 45 08             	mov    0x8(%ebp),%eax
  801aae:	6a 00                	push   $0x0
  801ab0:	53                   	push   %ebx
  801ab1:	51                   	push   %ecx
  801ab2:	52                   	push   %edx
  801ab3:	50                   	push   %eax
  801ab4:	6a 27                	push   $0x27
  801ab6:	e8 aa fa ff ff       	call   801565 <syscall>
  801abb:	83 c4 18             	add    $0x18,%esp
}
  801abe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac1:	c9                   	leave  
  801ac2:	c3                   	ret    

00801ac3 <sys_check_LRU_lists_free>:

int sys_check_LRU_lists_free(uint32* list_content, int list_size)
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_LRU_lists_free, (uint32)list_content, (uint32)list_size , 0, 0, 0);
  801ac6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  801acc:	6a 00                	push   $0x0
  801ace:	6a 00                	push   $0x0
  801ad0:	6a 00                	push   $0x0
  801ad2:	52                   	push   %edx
  801ad3:	50                   	push   %eax
  801ad4:	6a 28                	push   $0x28
  801ad6:	e8 8a fa ff ff       	call   801565 <syscall>
  801adb:	83 c4 18             	add    $0x18,%esp
}
  801ade:	c9                   	leave  
  801adf:	c3                   	ret    

00801ae0 <sys_check_WS_list>:

int sys_check_WS_list(uint32* WS_list_content, int actual_WS_list_size, uint32 last_WS_element_content, bool chk_in_order)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_WS_list, (uint32)WS_list_content, (uint32)actual_WS_list_size , last_WS_element_content, (uint32)chk_in_order, 0);
  801ae3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801ae6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  801aec:	6a 00                	push   $0x0
  801aee:	51                   	push   %ecx
  801aef:	ff 75 10             	pushl  0x10(%ebp)
  801af2:	52                   	push   %edx
  801af3:	50                   	push   %eax
  801af4:	6a 29                	push   $0x29
  801af6:	e8 6a fa ff ff       	call   801565 <syscall>
  801afb:	83 c4 18             	add    $0x18,%esp
}
  801afe:	c9                   	leave  
  801aff:	c3                   	ret    

00801b00 <sys_allocate_chunk>:
void sys_allocate_chunk(uint32 virtual_address, uint32 size, uint32 perms)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
	syscall(SYS_allocate_chunk_in_mem, virtual_address, size, perms, 0, 0);
  801b03:	6a 00                	push   $0x0
  801b05:	6a 00                	push   $0x0
  801b07:	ff 75 10             	pushl  0x10(%ebp)
  801b0a:	ff 75 0c             	pushl  0xc(%ebp)
  801b0d:	ff 75 08             	pushl  0x8(%ebp)
  801b10:	6a 12                	push   $0x12
  801b12:	e8 4e fa ff ff       	call   801565 <syscall>
  801b17:	83 c4 18             	add    $0x18,%esp
	return ;
  801b1a:	90                   	nop
}
  801b1b:	c9                   	leave  
  801b1c:	c3                   	ret    

00801b1d <sys_utilities>:
void sys_utilities(char* utilityName, int value)
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
	syscall(SYS_utilities, (uint32)utilityName, value, 0, 0, 0);
  801b20:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b23:	8b 45 08             	mov    0x8(%ebp),%eax
  801b26:	6a 00                	push   $0x0
  801b28:	6a 00                	push   $0x0
  801b2a:	6a 00                	push   $0x0
  801b2c:	52                   	push   %edx
  801b2d:	50                   	push   %eax
  801b2e:	6a 2a                	push   $0x2a
  801b30:	e8 30 fa ff ff       	call   801565 <syscall>
  801b35:	83 c4 18             	add    $0x18,%esp
	return;
  801b38:	90                   	nop
}
  801b39:	c9                   	leave  
  801b3a:	c3                   	ret    

00801b3b <sys_sbrk>:


//TODO: [PROJECT'24.MS1 - #02] [2] SYSTEM CALLS - Implement these system calls
void* sys_sbrk(int increment)
{
  801b3b:	55                   	push   %ebp
  801b3c:	89 e5                	mov    %esp,%ebp
	syscall( SYS_sbrk ,increment,0,0,0,0)  ;
  801b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b41:	6a 00                	push   $0x0
  801b43:	6a 00                	push   $0x0
  801b45:	6a 00                	push   $0x0
  801b47:	6a 00                	push   $0x0
  801b49:	50                   	push   %eax
  801b4a:	6a 2b                	push   $0x2b
  801b4c:	e8 14 fa ff ff       	call   801565 <syscall>
  801b51:	83 c4 18             	add    $0x18,%esp

	return (void*)-1 ;
  801b54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

}
  801b59:	c9                   	leave  
  801b5a:	c3                   	ret    

00801b5b <sys_free_user_mem>:
void sys_free_user_mem(uint32 virtual_address, uint32 size)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
	syscall(SYS_free_user_mem,virtual_address,size,0,0,0);
  801b5e:	6a 00                	push   $0x0
  801b60:	6a 00                	push   $0x0
  801b62:	6a 00                	push   $0x0
  801b64:	ff 75 0c             	pushl  0xc(%ebp)
  801b67:	ff 75 08             	pushl  0x8(%ebp)
  801b6a:	6a 2c                	push   $0x2c
  801b6c:	e8 f4 f9 ff ff       	call   801565 <syscall>
  801b71:	83 c4 18             	add    $0x18,%esp
	return;
  801b74:	90                   	nop
}
  801b75:	c9                   	leave  
  801b76:	c3                   	ret    

00801b77 <sys_allocate_user_mem>:

void sys_allocate_user_mem(uint32 virtual_address, uint32 size)
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
	syscall(SYS_allocate_user_mem,virtual_address,size,0,0,0);
  801b7a:	6a 00                	push   $0x0
  801b7c:	6a 00                	push   $0x0
  801b7e:	6a 00                	push   $0x0
  801b80:	ff 75 0c             	pushl  0xc(%ebp)
  801b83:	ff 75 08             	pushl  0x8(%ebp)
  801b86:	6a 2d                	push   $0x2d
  801b88:	e8 d8 f9 ff ff       	call   801565 <syscall>
  801b8d:	83 c4 18             	add    $0x18,%esp
	return;
  801b90:	90                   	nop
}
  801b91:	c9                   	leave  
  801b92:	c3                   	ret    

00801b93 <env_sleep>:
#include <inc/lib.h>
#include <inc/timerreg.h>

void
env_sleep(uint32 approxMilliSeconds)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	83 ec 28             	sub    $0x28,%esp
//	cprintf("%s go to sleep...\n", myEnv->prog_name);
	uint32 time_in_cycles=approxMilliSeconds*CYCLES_PER_MILLISEC;
  801b99:	8b 55 08             	mov    0x8(%ebp),%edx
  801b9c:	89 d0                	mov    %edx,%eax
  801b9e:	c1 e0 02             	shl    $0x2,%eax
  801ba1:	01 d0                	add    %edx,%eax
  801ba3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801baa:	01 d0                	add    %edx,%eax
  801bac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801bb3:	01 d0                	add    %edx,%eax
  801bb5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801bbc:	01 d0                	add    %edx,%eax
  801bbe:	c1 e0 04             	shl    $0x4,%eax
  801bc1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	uint32 cycles_counter =0;
  801bc4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	struct uint64 baseTime = sys_get_virtual_time() ;
  801bcb:	8d 45 e8             	lea    -0x18(%ebp),%eax
  801bce:	83 ec 0c             	sub    $0xc,%esp
  801bd1:	50                   	push   %eax
  801bd2:	e8 c3 fc ff ff       	call   80189a <sys_get_virtual_time>
  801bd7:	83 c4 0c             	add    $0xc,%esp
	while(cycles_counter<time_in_cycles)
  801bda:	eb 41                	jmp    801c1d <env_sleep+0x8a>
	{
		struct uint64 currentTime = sys_get_virtual_time() ;
  801bdc:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801bdf:	83 ec 0c             	sub    $0xc,%esp
  801be2:	50                   	push   %eax
  801be3:	e8 b2 fc ff ff       	call   80189a <sys_get_virtual_time>
  801be8:	83 c4 0c             	add    $0xc,%esp

		// update the cycles_count
		#define M32 0xffffffff
		// subtract basetime from current time
		struct uint64 res;
		res.low = (currentTime.low - baseTime.low) & M32;
  801beb:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801bee:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801bf1:	29 c2                	sub    %eax,%edx
  801bf3:	89 d0                	mov    %edx,%eax
  801bf5:	89 45 d8             	mov    %eax,-0x28(%ebp)
		res.hi = (currentTime.hi - baseTime.hi - (res.low > currentTime.low)) & M32;
  801bf8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801bfb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801bfe:	89 d1                	mov    %edx,%ecx
  801c00:	29 c1                	sub    %eax,%ecx
  801c02:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801c05:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c08:	39 c2                	cmp    %eax,%edx
  801c0a:	0f 97 c0             	seta   %al
  801c0d:	0f b6 c0             	movzbl %al,%eax
  801c10:	29 c1                	sub    %eax,%ecx
  801c12:	89 c8                	mov    %ecx,%eax
  801c14:	89 45 dc             	mov    %eax,-0x24(%ebp)

		//update cycles_count with result
		cycles_counter = res.low;
  801c17:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801c1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
//	cprintf("%s go to sleep...\n", myEnv->prog_name);
	uint32 time_in_cycles=approxMilliSeconds*CYCLES_PER_MILLISEC;
	uint32 cycles_counter =0;

	struct uint64 baseTime = sys_get_virtual_time() ;
	while(cycles_counter<time_in_cycles)
  801c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c20:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  801c23:	72 b7                	jb     801bdc <env_sleep+0x49>
//				,cycles_counter
//				);
	}
	//cprintf("%s [%d] wake up now!\n", myEnv->prog_name, myEnv->env_id);

}
  801c25:	90                   	nop
  801c26:	c9                   	leave  
  801c27:	c3                   	ret    

00801c28 <busy_wait>:

//2017
uint32 busy_wait(uint32 loopMax)
{
  801c28:	55                   	push   %ebp
  801c29:	89 e5                	mov    %esp,%ebp
  801c2b:	83 ec 10             	sub    $0x10,%esp
	uint32 i = 0 ;
  801c2e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	while (i < loopMax) i++;
  801c35:	eb 03                	jmp    801c3a <busy_wait+0x12>
  801c37:	ff 45 fc             	incl   -0x4(%ebp)
  801c3a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801c3d:	3b 45 08             	cmp    0x8(%ebp),%eax
  801c40:	72 f5                	jb     801c37 <busy_wait+0xf>
	return i;
  801c42:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  801c45:	c9                   	leave  
  801c46:	c3                   	ret    

00801c47 <cputchar>:
#include <inc/lib.h>


void
cputchar(int ch)
{
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	83 ec 18             	sub    $0x18,%esp
	char c = ch;
  801c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c50:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	//sys_cputs(&c, 1);

	sys_cputc(c);
  801c53:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  801c57:	83 ec 0c             	sub    $0xc,%esp
  801c5a:	50                   	push   %eax
  801c5b:	e8 bd fa ff ff       	call   80171d <sys_cputc>
  801c60:	83 c4 10             	add    $0x10,%esp
}
  801c63:	90                   	nop
  801c64:	c9                   	leave  
  801c65:	c3                   	ret    

00801c66 <getchar>:


int
getchar(void)
{
  801c66:	55                   	push   %ebp
  801c67:	89 e5                	mov    %esp,%ebp
  801c69:	83 ec 18             	sub    $0x18,%esp
	int c =sys_cgetc();
  801c6c:	e8 48 f9 ff ff       	call   8015b9 <sys_cgetc>
  801c71:	89 45 f4             	mov    %eax,-0xc(%ebp)
	return c;
  801c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801c77:	c9                   	leave  
  801c78:	c3                   	ret    

00801c79 <iscons>:

int iscons(int fdnum)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
  801c7c:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801c81:	5d                   	pop    %ebp
  801c82:	c3                   	ret    
  801c83:	90                   	nop

00801c84 <__udivdi3>:
  801c84:	55                   	push   %ebp
  801c85:	57                   	push   %edi
  801c86:	56                   	push   %esi
  801c87:	53                   	push   %ebx
  801c88:	83 ec 1c             	sub    $0x1c,%esp
  801c8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c97:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c9b:	89 ca                	mov    %ecx,%edx
  801c9d:	89 f8                	mov    %edi,%eax
  801c9f:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ca3:	85 f6                	test   %esi,%esi
  801ca5:	75 2d                	jne    801cd4 <__udivdi3+0x50>
  801ca7:	39 cf                	cmp    %ecx,%edi
  801ca9:	77 65                	ja     801d10 <__udivdi3+0x8c>
  801cab:	89 fd                	mov    %edi,%ebp
  801cad:	85 ff                	test   %edi,%edi
  801caf:	75 0b                	jne    801cbc <__udivdi3+0x38>
  801cb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cb6:	31 d2                	xor    %edx,%edx
  801cb8:	f7 f7                	div    %edi
  801cba:	89 c5                	mov    %eax,%ebp
  801cbc:	31 d2                	xor    %edx,%edx
  801cbe:	89 c8                	mov    %ecx,%eax
  801cc0:	f7 f5                	div    %ebp
  801cc2:	89 c1                	mov    %eax,%ecx
  801cc4:	89 d8                	mov    %ebx,%eax
  801cc6:	f7 f5                	div    %ebp
  801cc8:	89 cf                	mov    %ecx,%edi
  801cca:	89 fa                	mov    %edi,%edx
  801ccc:	83 c4 1c             	add    $0x1c,%esp
  801ccf:	5b                   	pop    %ebx
  801cd0:	5e                   	pop    %esi
  801cd1:	5f                   	pop    %edi
  801cd2:	5d                   	pop    %ebp
  801cd3:	c3                   	ret    
  801cd4:	39 ce                	cmp    %ecx,%esi
  801cd6:	77 28                	ja     801d00 <__udivdi3+0x7c>
  801cd8:	0f bd fe             	bsr    %esi,%edi
  801cdb:	83 f7 1f             	xor    $0x1f,%edi
  801cde:	75 40                	jne    801d20 <__udivdi3+0x9c>
  801ce0:	39 ce                	cmp    %ecx,%esi
  801ce2:	72 0a                	jb     801cee <__udivdi3+0x6a>
  801ce4:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ce8:	0f 87 9e 00 00 00    	ja     801d8c <__udivdi3+0x108>
  801cee:	b8 01 00 00 00       	mov    $0x1,%eax
  801cf3:	89 fa                	mov    %edi,%edx
  801cf5:	83 c4 1c             	add    $0x1c,%esp
  801cf8:	5b                   	pop    %ebx
  801cf9:	5e                   	pop    %esi
  801cfa:	5f                   	pop    %edi
  801cfb:	5d                   	pop    %ebp
  801cfc:	c3                   	ret    
  801cfd:	8d 76 00             	lea    0x0(%esi),%esi
  801d00:	31 ff                	xor    %edi,%edi
  801d02:	31 c0                	xor    %eax,%eax
  801d04:	89 fa                	mov    %edi,%edx
  801d06:	83 c4 1c             	add    $0x1c,%esp
  801d09:	5b                   	pop    %ebx
  801d0a:	5e                   	pop    %esi
  801d0b:	5f                   	pop    %edi
  801d0c:	5d                   	pop    %ebp
  801d0d:	c3                   	ret    
  801d0e:	66 90                	xchg   %ax,%ax
  801d10:	89 d8                	mov    %ebx,%eax
  801d12:	f7 f7                	div    %edi
  801d14:	31 ff                	xor    %edi,%edi
  801d16:	89 fa                	mov    %edi,%edx
  801d18:	83 c4 1c             	add    $0x1c,%esp
  801d1b:	5b                   	pop    %ebx
  801d1c:	5e                   	pop    %esi
  801d1d:	5f                   	pop    %edi
  801d1e:	5d                   	pop    %ebp
  801d1f:	c3                   	ret    
  801d20:	bd 20 00 00 00       	mov    $0x20,%ebp
  801d25:	89 eb                	mov    %ebp,%ebx
  801d27:	29 fb                	sub    %edi,%ebx
  801d29:	89 f9                	mov    %edi,%ecx
  801d2b:	d3 e6                	shl    %cl,%esi
  801d2d:	89 c5                	mov    %eax,%ebp
  801d2f:	88 d9                	mov    %bl,%cl
  801d31:	d3 ed                	shr    %cl,%ebp
  801d33:	89 e9                	mov    %ebp,%ecx
  801d35:	09 f1                	or     %esi,%ecx
  801d37:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d3b:	89 f9                	mov    %edi,%ecx
  801d3d:	d3 e0                	shl    %cl,%eax
  801d3f:	89 c5                	mov    %eax,%ebp
  801d41:	89 d6                	mov    %edx,%esi
  801d43:	88 d9                	mov    %bl,%cl
  801d45:	d3 ee                	shr    %cl,%esi
  801d47:	89 f9                	mov    %edi,%ecx
  801d49:	d3 e2                	shl    %cl,%edx
  801d4b:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d4f:	88 d9                	mov    %bl,%cl
  801d51:	d3 e8                	shr    %cl,%eax
  801d53:	09 c2                	or     %eax,%edx
  801d55:	89 d0                	mov    %edx,%eax
  801d57:	89 f2                	mov    %esi,%edx
  801d59:	f7 74 24 0c          	divl   0xc(%esp)
  801d5d:	89 d6                	mov    %edx,%esi
  801d5f:	89 c3                	mov    %eax,%ebx
  801d61:	f7 e5                	mul    %ebp
  801d63:	39 d6                	cmp    %edx,%esi
  801d65:	72 19                	jb     801d80 <__udivdi3+0xfc>
  801d67:	74 0b                	je     801d74 <__udivdi3+0xf0>
  801d69:	89 d8                	mov    %ebx,%eax
  801d6b:	31 ff                	xor    %edi,%edi
  801d6d:	e9 58 ff ff ff       	jmp    801cca <__udivdi3+0x46>
  801d72:	66 90                	xchg   %ax,%ax
  801d74:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d78:	89 f9                	mov    %edi,%ecx
  801d7a:	d3 e2                	shl    %cl,%edx
  801d7c:	39 c2                	cmp    %eax,%edx
  801d7e:	73 e9                	jae    801d69 <__udivdi3+0xe5>
  801d80:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d83:	31 ff                	xor    %edi,%edi
  801d85:	e9 40 ff ff ff       	jmp    801cca <__udivdi3+0x46>
  801d8a:	66 90                	xchg   %ax,%ax
  801d8c:	31 c0                	xor    %eax,%eax
  801d8e:	e9 37 ff ff ff       	jmp    801cca <__udivdi3+0x46>
  801d93:	90                   	nop

00801d94 <__umoddi3>:
  801d94:	55                   	push   %ebp
  801d95:	57                   	push   %edi
  801d96:	56                   	push   %esi
  801d97:	53                   	push   %ebx
  801d98:	83 ec 1c             	sub    $0x1c,%esp
  801d9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801da3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801da7:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801dab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801daf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801db3:	89 f3                	mov    %esi,%ebx
  801db5:	89 fa                	mov    %edi,%edx
  801db7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801dbb:	89 34 24             	mov    %esi,(%esp)
  801dbe:	85 c0                	test   %eax,%eax
  801dc0:	75 1a                	jne    801ddc <__umoddi3+0x48>
  801dc2:	39 f7                	cmp    %esi,%edi
  801dc4:	0f 86 a2 00 00 00    	jbe    801e6c <__umoddi3+0xd8>
  801dca:	89 c8                	mov    %ecx,%eax
  801dcc:	89 f2                	mov    %esi,%edx
  801dce:	f7 f7                	div    %edi
  801dd0:	89 d0                	mov    %edx,%eax
  801dd2:	31 d2                	xor    %edx,%edx
  801dd4:	83 c4 1c             	add    $0x1c,%esp
  801dd7:	5b                   	pop    %ebx
  801dd8:	5e                   	pop    %esi
  801dd9:	5f                   	pop    %edi
  801dda:	5d                   	pop    %ebp
  801ddb:	c3                   	ret    
  801ddc:	39 f0                	cmp    %esi,%eax
  801dde:	0f 87 ac 00 00 00    	ja     801e90 <__umoddi3+0xfc>
  801de4:	0f bd e8             	bsr    %eax,%ebp
  801de7:	83 f5 1f             	xor    $0x1f,%ebp
  801dea:	0f 84 ac 00 00 00    	je     801e9c <__umoddi3+0x108>
  801df0:	bf 20 00 00 00       	mov    $0x20,%edi
  801df5:	29 ef                	sub    %ebp,%edi
  801df7:	89 fe                	mov    %edi,%esi
  801df9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801dfd:	89 e9                	mov    %ebp,%ecx
  801dff:	d3 e0                	shl    %cl,%eax
  801e01:	89 d7                	mov    %edx,%edi
  801e03:	89 f1                	mov    %esi,%ecx
  801e05:	d3 ef                	shr    %cl,%edi
  801e07:	09 c7                	or     %eax,%edi
  801e09:	89 e9                	mov    %ebp,%ecx
  801e0b:	d3 e2                	shl    %cl,%edx
  801e0d:	89 14 24             	mov    %edx,(%esp)
  801e10:	89 d8                	mov    %ebx,%eax
  801e12:	d3 e0                	shl    %cl,%eax
  801e14:	89 c2                	mov    %eax,%edx
  801e16:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e1a:	d3 e0                	shl    %cl,%eax
  801e1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e20:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e24:	89 f1                	mov    %esi,%ecx
  801e26:	d3 e8                	shr    %cl,%eax
  801e28:	09 d0                	or     %edx,%eax
  801e2a:	d3 eb                	shr    %cl,%ebx
  801e2c:	89 da                	mov    %ebx,%edx
  801e2e:	f7 f7                	div    %edi
  801e30:	89 d3                	mov    %edx,%ebx
  801e32:	f7 24 24             	mull   (%esp)
  801e35:	89 c6                	mov    %eax,%esi
  801e37:	89 d1                	mov    %edx,%ecx
  801e39:	39 d3                	cmp    %edx,%ebx
  801e3b:	0f 82 87 00 00 00    	jb     801ec8 <__umoddi3+0x134>
  801e41:	0f 84 91 00 00 00    	je     801ed8 <__umoddi3+0x144>
  801e47:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e4b:	29 f2                	sub    %esi,%edx
  801e4d:	19 cb                	sbb    %ecx,%ebx
  801e4f:	89 d8                	mov    %ebx,%eax
  801e51:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801e55:	d3 e0                	shl    %cl,%eax
  801e57:	89 e9                	mov    %ebp,%ecx
  801e59:	d3 ea                	shr    %cl,%edx
  801e5b:	09 d0                	or     %edx,%eax
  801e5d:	89 e9                	mov    %ebp,%ecx
  801e5f:	d3 eb                	shr    %cl,%ebx
  801e61:	89 da                	mov    %ebx,%edx
  801e63:	83 c4 1c             	add    $0x1c,%esp
  801e66:	5b                   	pop    %ebx
  801e67:	5e                   	pop    %esi
  801e68:	5f                   	pop    %edi
  801e69:	5d                   	pop    %ebp
  801e6a:	c3                   	ret    
  801e6b:	90                   	nop
  801e6c:	89 fd                	mov    %edi,%ebp
  801e6e:	85 ff                	test   %edi,%edi
  801e70:	75 0b                	jne    801e7d <__umoddi3+0xe9>
  801e72:	b8 01 00 00 00       	mov    $0x1,%eax
  801e77:	31 d2                	xor    %edx,%edx
  801e79:	f7 f7                	div    %edi
  801e7b:	89 c5                	mov    %eax,%ebp
  801e7d:	89 f0                	mov    %esi,%eax
  801e7f:	31 d2                	xor    %edx,%edx
  801e81:	f7 f5                	div    %ebp
  801e83:	89 c8                	mov    %ecx,%eax
  801e85:	f7 f5                	div    %ebp
  801e87:	89 d0                	mov    %edx,%eax
  801e89:	e9 44 ff ff ff       	jmp    801dd2 <__umoddi3+0x3e>
  801e8e:	66 90                	xchg   %ax,%ax
  801e90:	89 c8                	mov    %ecx,%eax
  801e92:	89 f2                	mov    %esi,%edx
  801e94:	83 c4 1c             	add    $0x1c,%esp
  801e97:	5b                   	pop    %ebx
  801e98:	5e                   	pop    %esi
  801e99:	5f                   	pop    %edi
  801e9a:	5d                   	pop    %ebp
  801e9b:	c3                   	ret    
  801e9c:	3b 04 24             	cmp    (%esp),%eax
  801e9f:	72 06                	jb     801ea7 <__umoddi3+0x113>
  801ea1:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801ea5:	77 0f                	ja     801eb6 <__umoddi3+0x122>
  801ea7:	89 f2                	mov    %esi,%edx
  801ea9:	29 f9                	sub    %edi,%ecx
  801eab:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801eaf:	89 14 24             	mov    %edx,(%esp)
  801eb2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801eb6:	8b 44 24 04          	mov    0x4(%esp),%eax
  801eba:	8b 14 24             	mov    (%esp),%edx
  801ebd:	83 c4 1c             	add    $0x1c,%esp
  801ec0:	5b                   	pop    %ebx
  801ec1:	5e                   	pop    %esi
  801ec2:	5f                   	pop    %edi
  801ec3:	5d                   	pop    %ebp
  801ec4:	c3                   	ret    
  801ec5:	8d 76 00             	lea    0x0(%esi),%esi
  801ec8:	2b 04 24             	sub    (%esp),%eax
  801ecb:	19 fa                	sbb    %edi,%edx
  801ecd:	89 d1                	mov    %edx,%ecx
  801ecf:	89 c6                	mov    %eax,%esi
  801ed1:	e9 71 ff ff ff       	jmp    801e47 <__umoddi3+0xb3>
  801ed6:	66 90                	xchg   %ax,%ax
  801ed8:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801edc:	72 ea                	jb     801ec8 <__umoddi3+0x134>
  801ede:	89 d9                	mov    %ebx,%ecx
  801ee0:	e9 62 ff ff ff       	jmp    801e47 <__umoddi3+0xb3>
