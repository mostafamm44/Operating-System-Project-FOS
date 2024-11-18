
obj/user/tst_chan_one_slave:     file format elf32-i386


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
  800031:	e8 6d 00 00 00       	call   8000a3 <libmain>
1:      jmp 1b
  800036:	eb fe                	jmp    800036 <args_exist+0x5>

00800038 <_main>:
// Slave program: sleep, increment test after wakeup
#include <inc/lib.h>

void
_main(void)
{
  800038:	55                   	push   %ebp
  800039:	89 e5                	mov    %esp,%ebp
  80003b:	83 ec 18             	sub    $0x18,%esp
	int envID = sys_getenvid();
  80003e:	e8 d5 12 00 00       	call   801318 <sys_getenvid>
  800043:	89 45 f4             	mov    %eax,-0xc(%ebp)

	//Sleep on the channel
	sys_utilities("__Sleep__", 0);
  800046:	83 ec 08             	sub    $0x8,%esp
  800049:	6a 00                	push   $0x0
  80004b:	68 80 1b 80 00       	push   $0x801b80
  800050:	e8 ab 15 00 00       	call   801600 <sys_utilities>
  800055:	83 c4 10             	add    $0x10,%esp

	//wait for a while
	env_sleep(RAND(1000, 5000));
  800058:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80005b:	83 ec 0c             	sub    $0xc,%esp
  80005e:	50                   	push   %eax
  80005f:	e8 19 13 00 00       	call   80137d <sys_get_virtual_time>
  800064:	83 c4 0c             	add    $0xc,%esp
  800067:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80006a:	b9 a0 0f 00 00       	mov    $0xfa0,%ecx
  80006f:	ba 00 00 00 00       	mov    $0x0,%edx
  800074:	f7 f1                	div    %ecx
  800076:	89 d0                	mov    %edx,%eax
  800078:	05 e8 03 00 00       	add    $0x3e8,%eax
  80007d:	83 ec 0c             	sub    $0xc,%esp
  800080:	50                   	push   %eax
  800081:	e8 f0 15 00 00       	call   801676 <env_sleep>
  800086:	83 c4 10             	add    $0x10,%esp

	//wakeup another one
	sys_utilities("__WakeupOne__", 0);
  800089:	83 ec 08             	sub    $0x8,%esp
  80008c:	6a 00                	push   $0x0
  80008e:	68 8a 1b 80 00       	push   $0x801b8a
  800093:	e8 68 15 00 00       	call   801600 <sys_utilities>
  800098:	83 c4 10             	add    $0x10,%esp

	//indicates wakenup
	inctst();
  80009b:	e8 cf 13 00 00       	call   80146f <inctst>

	return;
  8000a0:	90                   	nop
}
  8000a1:	c9                   	leave  
  8000a2:	c3                   	ret    

008000a3 <libmain>:

volatile struct Env *myEnv = NULL;
volatile char *binaryname = "(PROGRAM NAME UNKNOWN)";
void
libmain(int argc, char **argv)
{
  8000a3:	55                   	push   %ebp
  8000a4:	89 e5                	mov    %esp,%ebp
  8000a6:	83 ec 18             	sub    $0x18,%esp
	int envIndex = sys_getenvindex();
  8000a9:	e8 83 12 00 00       	call   801331 <sys_getenvindex>
  8000ae:	89 45 f4             	mov    %eax,-0xc(%ebp)

	myEnv = &(envs[envIndex]);
  8000b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8000b4:	89 d0                	mov    %edx,%eax
  8000b6:	c1 e0 02             	shl    $0x2,%eax
  8000b9:	01 d0                	add    %edx,%eax
  8000bb:	01 c0                	add    %eax,%eax
  8000bd:	01 d0                	add    %edx,%eax
  8000bf:	c1 e0 02             	shl    $0x2,%eax
  8000c2:	01 d0                	add    %edx,%eax
  8000c4:	01 c0                	add    %eax,%eax
  8000c6:	01 d0                	add    %edx,%eax
  8000c8:	c1 e0 04             	shl    $0x4,%eax
  8000cb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d0:	a3 04 30 80 00       	mov    %eax,0x803004

	//SET THE PROGRAM NAME
	if (myEnv->prog_name[0] != '\0')
  8000d5:	a1 04 30 80 00       	mov    0x803004,%eax
  8000da:	8a 40 20             	mov    0x20(%eax),%al
  8000dd:	84 c0                	test   %al,%al
  8000df:	74 0d                	je     8000ee <libmain+0x4b>
		binaryname = myEnv->prog_name;
  8000e1:	a1 04 30 80 00       	mov    0x803004,%eax
  8000e6:	83 c0 20             	add    $0x20,%eax
  8000e9:	a3 00 30 80 00       	mov    %eax,0x803000

	// set env to point at our env structure in envs[].
	// env = envs;

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ee:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000f2:	7e 0a                	jle    8000fe <libmain+0x5b>
		binaryname = argv[0];
  8000f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000f7:	8b 00                	mov    (%eax),%eax
  8000f9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	_main(argc, argv);
  8000fe:	83 ec 08             	sub    $0x8,%esp
  800101:	ff 75 0c             	pushl  0xc(%ebp)
  800104:	ff 75 08             	pushl  0x8(%ebp)
  800107:	e8 2c ff ff ff       	call   800038 <_main>
  80010c:	83 c4 10             	add    $0x10,%esp



	//	sys_lock_cons();
	sys_lock_cons();
  80010f:	e8 a1 0f 00 00       	call   8010b5 <sys_lock_cons>
	{
		cprintf("**************************************\n");
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 b0 1b 80 00       	push   $0x801bb0
  80011c:	e8 8d 01 00 00       	call   8002ae <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
		cprintf("Num of PAGE faults = %d, modif = %d\n", myEnv->pageFaultsCounter, myEnv->nModifiedPages);
  800124:	a1 04 30 80 00       	mov    0x803004,%eax
  800129:	8b 90 94 05 00 00    	mov    0x594(%eax),%edx
  80012f:	a1 04 30 80 00       	mov    0x803004,%eax
  800134:	8b 80 84 05 00 00    	mov    0x584(%eax),%eax
  80013a:	83 ec 04             	sub    $0x4,%esp
  80013d:	52                   	push   %edx
  80013e:	50                   	push   %eax
  80013f:	68 d8 1b 80 00       	push   $0x801bd8
  800144:	e8 65 01 00 00       	call   8002ae <cprintf>
  800149:	83 c4 10             	add    $0x10,%esp
		cprintf("# PAGE IN (from disk) = %d, # PAGE OUT (on disk) = %d, # NEW PAGE ADDED (on disk) = %d\n", myEnv->nPageIn, myEnv->nPageOut,myEnv->nNewPageAdded);
  80014c:	a1 04 30 80 00       	mov    0x803004,%eax
  800151:	8b 88 a8 05 00 00    	mov    0x5a8(%eax),%ecx
  800157:	a1 04 30 80 00       	mov    0x803004,%eax
  80015c:	8b 90 a4 05 00 00    	mov    0x5a4(%eax),%edx
  800162:	a1 04 30 80 00       	mov    0x803004,%eax
  800167:	8b 80 a0 05 00 00    	mov    0x5a0(%eax),%eax
  80016d:	51                   	push   %ecx
  80016e:	52                   	push   %edx
  80016f:	50                   	push   %eax
  800170:	68 00 1c 80 00       	push   $0x801c00
  800175:	e8 34 01 00 00       	call   8002ae <cprintf>
  80017a:	83 c4 10             	add    $0x10,%esp
		//cprintf("Num of freeing scarce memory = %d, freeing full working set = %d\n", myEnv->freeingScarceMemCounter, myEnv->freeingFullWSCounter);
		cprintf("Num of clocks = %d\n", myEnv->nClocks);
  80017d:	a1 04 30 80 00       	mov    0x803004,%eax
  800182:	8b 80 ac 05 00 00    	mov    0x5ac(%eax),%eax
  800188:	83 ec 08             	sub    $0x8,%esp
  80018b:	50                   	push   %eax
  80018c:	68 58 1c 80 00       	push   $0x801c58
  800191:	e8 18 01 00 00       	call   8002ae <cprintf>
  800196:	83 c4 10             	add    $0x10,%esp
		cprintf("**************************************\n");
  800199:	83 ec 0c             	sub    $0xc,%esp
  80019c:	68 b0 1b 80 00       	push   $0x801bb0
  8001a1:	e8 08 01 00 00       	call   8002ae <cprintf>
  8001a6:	83 c4 10             	add    $0x10,%esp
	}
	sys_unlock_cons();
  8001a9:	e8 21 0f 00 00       	call   8010cf <sys_unlock_cons>
//	sys_unlock_cons();

	// exit gracefully
	exit();
  8001ae:	e8 19 00 00 00       	call   8001cc <exit>
}
  8001b3:	90                   	nop
  8001b4:	c9                   	leave  
  8001b5:	c3                   	ret    

008001b6 <destroy>:

#include <inc/lib.h>

void
destroy(void)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	83 ec 08             	sub    $0x8,%esp
	sys_destroy_env(0);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	6a 00                	push   $0x0
  8001c1:	e8 37 11 00 00       	call   8012fd <sys_destroy_env>
  8001c6:	83 c4 10             	add    $0x10,%esp
}
  8001c9:	90                   	nop
  8001ca:	c9                   	leave  
  8001cb:	c3                   	ret    

008001cc <exit>:

void
exit(void)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	83 ec 08             	sub    $0x8,%esp
	sys_exit_env();
  8001d2:	e8 8c 11 00 00       	call   801363 <sys_exit_env>
}
  8001d7:	90                   	nop
  8001d8:	c9                   	leave  
  8001d9:	c3                   	ret    

008001da <putch>:
	int idx; // current buffer index
	int cnt; // total bytes printed so far
	char buf[256];
};

static void putch(int ch, struct printbuf *b) {
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	83 ec 08             	sub    $0x8,%esp
	b->buf[b->idx++] = ch;
  8001e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e3:	8b 00                	mov    (%eax),%eax
  8001e5:	8d 48 01             	lea    0x1(%eax),%ecx
  8001e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001eb:	89 0a                	mov    %ecx,(%edx)
  8001ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f0:	88 d1                	mov    %dl,%cl
  8001f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f5:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256 - 1) {
  8001f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001fc:	8b 00                	mov    (%eax),%eax
  8001fe:	3d ff 00 00 00       	cmp    $0xff,%eax
  800203:	75 2c                	jne    800231 <putch+0x57>
		sys_cputs(b->buf, b->idx, printProgName);
  800205:	a0 08 30 80 00       	mov    0x803008,%al
  80020a:	0f b6 c0             	movzbl %al,%eax
  80020d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800210:	8b 12                	mov    (%edx),%edx
  800212:	89 d1                	mov    %edx,%ecx
  800214:	8b 55 0c             	mov    0xc(%ebp),%edx
  800217:	83 c2 08             	add    $0x8,%edx
  80021a:	83 ec 04             	sub    $0x4,%esp
  80021d:	50                   	push   %eax
  80021e:	51                   	push   %ecx
  80021f:	52                   	push   %edx
  800220:	e8 4e 0e 00 00       	call   801073 <sys_cputs>
  800225:	83 c4 10             	add    $0x10,%esp
		b->idx = 0;
  800228:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800231:	8b 45 0c             	mov    0xc(%ebp),%eax
  800234:	8b 40 04             	mov    0x4(%eax),%eax
  800237:	8d 50 01             	lea    0x1(%eax),%edx
  80023a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80023d:	89 50 04             	mov    %edx,0x4(%eax)
}
  800240:	90                   	nop
  800241:	c9                   	leave  
  800242:	c3                   	ret    

00800243 <vcprintf>:

int vcprintf(const char *fmt, va_list ap) {
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80024c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800253:	00 00 00 
	b.cnt = 0;
  800256:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80025d:	00 00 00 
	vprintfmt((void*) putch, &b, fmt, ap);
  800260:	ff 75 0c             	pushl  0xc(%ebp)
  800263:	ff 75 08             	pushl  0x8(%ebp)
  800266:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80026c:	50                   	push   %eax
  80026d:	68 da 01 80 00       	push   $0x8001da
  800272:	e8 11 02 00 00       	call   800488 <vprintfmt>
  800277:	83 c4 10             	add    $0x10,%esp
	sys_cputs(b.buf, b.idx, printProgName);
  80027a:	a0 08 30 80 00       	mov    0x803008,%al
  80027f:	0f b6 c0             	movzbl %al,%eax
  800282:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
  800288:	83 ec 04             	sub    $0x4,%esp
  80028b:	50                   	push   %eax
  80028c:	52                   	push   %edx
  80028d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800293:	83 c0 08             	add    $0x8,%eax
  800296:	50                   	push   %eax
  800297:	e8 d7 0d 00 00       	call   801073 <sys_cputs>
  80029c:	83 c4 10             	add    $0x10,%esp

	printProgName = 0;
  80029f:	c6 05 08 30 80 00 00 	movb   $0x0,0x803008
	return b.cnt;
  8002a6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8002ac:	c9                   	leave  
  8002ad:	c3                   	ret    

008002ae <cprintf>:

//%@: to print the program name and ID before the message
//%~: to print the message directly
int cprintf(const char *fmt, ...) {
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;
	printProgName = 1 ;
  8002b4:	c6 05 08 30 80 00 01 	movb   $0x1,0x803008
	va_start(ap, fmt);
  8002bb:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002be:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
  8002c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c4:	83 ec 08             	sub    $0x8,%esp
  8002c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8002ca:	50                   	push   %eax
  8002cb:	e8 73 ff ff ff       	call   800243 <vcprintf>
  8002d0:	83 c4 10             	add    $0x10,%esp
  8002d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return cnt;
  8002d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8002d9:	c9                   	leave  
  8002da:	c3                   	ret    

008002db <atomic_cprintf>:

//%@: to print the program name and ID before the message
//%~: to print the message directly
int atomic_cprintf(const char *fmt, ...)
{
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
  8002de:	83 ec 18             	sub    $0x18,%esp
	int cnt;
	sys_lock_cons();
  8002e1:	e8 cf 0d 00 00       	call   8010b5 <sys_lock_cons>
	{
		va_list ap;
		va_start(ap, fmt);
  8002e6:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
		cnt = vcprintf(fmt, ap);
  8002ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ef:	83 ec 08             	sub    $0x8,%esp
  8002f2:	ff 75 f4             	pushl  -0xc(%ebp)
  8002f5:	50                   	push   %eax
  8002f6:	e8 48 ff ff ff       	call   800243 <vcprintf>
  8002fb:	83 c4 10             	add    $0x10,%esp
  8002fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
		va_end(ap);
	}
	sys_unlock_cons();
  800301:	e8 c9 0d 00 00       	call   8010cf <sys_unlock_cons>
	return cnt;
  800306:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800309:	c9                   	leave  
  80030a:	c3                   	ret    

0080030b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	53                   	push   %ebx
  80030f:	83 ec 14             	sub    $0x14,%esp
  800312:	8b 45 10             	mov    0x10(%ebp),%eax
  800315:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800318:	8b 45 14             	mov    0x14(%ebp),%eax
  80031b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80031e:	8b 45 18             	mov    0x18(%ebp),%eax
  800321:	ba 00 00 00 00       	mov    $0x0,%edx
  800326:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800329:	77 55                	ja     800380 <printnum+0x75>
  80032b:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80032e:	72 05                	jb     800335 <printnum+0x2a>
  800330:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800333:	77 4b                	ja     800380 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800335:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800338:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80033b:	8b 45 18             	mov    0x18(%ebp),%eax
  80033e:	ba 00 00 00 00       	mov    $0x0,%edx
  800343:	52                   	push   %edx
  800344:	50                   	push   %eax
  800345:	ff 75 f4             	pushl  -0xc(%ebp)
  800348:	ff 75 f0             	pushl  -0x10(%ebp)
  80034b:	e8 c4 15 00 00       	call   801914 <__udivdi3>
  800350:	83 c4 10             	add    $0x10,%esp
  800353:	83 ec 04             	sub    $0x4,%esp
  800356:	ff 75 20             	pushl  0x20(%ebp)
  800359:	53                   	push   %ebx
  80035a:	ff 75 18             	pushl  0x18(%ebp)
  80035d:	52                   	push   %edx
  80035e:	50                   	push   %eax
  80035f:	ff 75 0c             	pushl  0xc(%ebp)
  800362:	ff 75 08             	pushl  0x8(%ebp)
  800365:	e8 a1 ff ff ff       	call   80030b <printnum>
  80036a:	83 c4 20             	add    $0x20,%esp
  80036d:	eb 1a                	jmp    800389 <printnum+0x7e>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80036f:	83 ec 08             	sub    $0x8,%esp
  800372:	ff 75 0c             	pushl  0xc(%ebp)
  800375:	ff 75 20             	pushl  0x20(%ebp)
  800378:	8b 45 08             	mov    0x8(%ebp),%eax
  80037b:	ff d0                	call   *%eax
  80037d:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800380:	ff 4d 1c             	decl   0x1c(%ebp)
  800383:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800387:	7f e6                	jg     80036f <printnum+0x64>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800389:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80038c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800391:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800394:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800397:	53                   	push   %ebx
  800398:	51                   	push   %ecx
  800399:	52                   	push   %edx
  80039a:	50                   	push   %eax
  80039b:	e8 84 16 00 00       	call   801a24 <__umoddi3>
  8003a0:	83 c4 10             	add    $0x10,%esp
  8003a3:	05 94 1e 80 00       	add    $0x801e94,%eax
  8003a8:	8a 00                	mov    (%eax),%al
  8003aa:	0f be c0             	movsbl %al,%eax
  8003ad:	83 ec 08             	sub    $0x8,%esp
  8003b0:	ff 75 0c             	pushl  0xc(%ebp)
  8003b3:	50                   	push   %eax
  8003b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b7:	ff d0                	call   *%eax
  8003b9:	83 c4 10             	add    $0x10,%esp
}
  8003bc:	90                   	nop
  8003bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003c0:	c9                   	leave  
  8003c1:	c3                   	ret    

008003c2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003c2:	55                   	push   %ebp
  8003c3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003c5:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003c9:	7e 1c                	jle    8003e7 <getuint+0x25>
		return va_arg(*ap, unsigned long long);
  8003cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ce:	8b 00                	mov    (%eax),%eax
  8003d0:	8d 50 08             	lea    0x8(%eax),%edx
  8003d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d6:	89 10                	mov    %edx,(%eax)
  8003d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003db:	8b 00                	mov    (%eax),%eax
  8003dd:	83 e8 08             	sub    $0x8,%eax
  8003e0:	8b 50 04             	mov    0x4(%eax),%edx
  8003e3:	8b 00                	mov    (%eax),%eax
  8003e5:	eb 40                	jmp    800427 <getuint+0x65>
	else if (lflag)
  8003e7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003eb:	74 1e                	je     80040b <getuint+0x49>
		return va_arg(*ap, unsigned long);
  8003ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f0:	8b 00                	mov    (%eax),%eax
  8003f2:	8d 50 04             	lea    0x4(%eax),%edx
  8003f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f8:	89 10                	mov    %edx,(%eax)
  8003fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fd:	8b 00                	mov    (%eax),%eax
  8003ff:	83 e8 04             	sub    $0x4,%eax
  800402:	8b 00                	mov    (%eax),%eax
  800404:	ba 00 00 00 00       	mov    $0x0,%edx
  800409:	eb 1c                	jmp    800427 <getuint+0x65>
	else
		return va_arg(*ap, unsigned int);
  80040b:	8b 45 08             	mov    0x8(%ebp),%eax
  80040e:	8b 00                	mov    (%eax),%eax
  800410:	8d 50 04             	lea    0x4(%eax),%edx
  800413:	8b 45 08             	mov    0x8(%ebp),%eax
  800416:	89 10                	mov    %edx,(%eax)
  800418:	8b 45 08             	mov    0x8(%ebp),%eax
  80041b:	8b 00                	mov    (%eax),%eax
  80041d:	83 e8 04             	sub    $0x4,%eax
  800420:	8b 00                	mov    (%eax),%eax
  800422:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800427:	5d                   	pop    %ebp
  800428:	c3                   	ret    

00800429 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80042c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800430:	7e 1c                	jle    80044e <getint+0x25>
		return va_arg(*ap, long long);
  800432:	8b 45 08             	mov    0x8(%ebp),%eax
  800435:	8b 00                	mov    (%eax),%eax
  800437:	8d 50 08             	lea    0x8(%eax),%edx
  80043a:	8b 45 08             	mov    0x8(%ebp),%eax
  80043d:	89 10                	mov    %edx,(%eax)
  80043f:	8b 45 08             	mov    0x8(%ebp),%eax
  800442:	8b 00                	mov    (%eax),%eax
  800444:	83 e8 08             	sub    $0x8,%eax
  800447:	8b 50 04             	mov    0x4(%eax),%edx
  80044a:	8b 00                	mov    (%eax),%eax
  80044c:	eb 38                	jmp    800486 <getint+0x5d>
	else if (lflag)
  80044e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800452:	74 1a                	je     80046e <getint+0x45>
		return va_arg(*ap, long);
  800454:	8b 45 08             	mov    0x8(%ebp),%eax
  800457:	8b 00                	mov    (%eax),%eax
  800459:	8d 50 04             	lea    0x4(%eax),%edx
  80045c:	8b 45 08             	mov    0x8(%ebp),%eax
  80045f:	89 10                	mov    %edx,(%eax)
  800461:	8b 45 08             	mov    0x8(%ebp),%eax
  800464:	8b 00                	mov    (%eax),%eax
  800466:	83 e8 04             	sub    $0x4,%eax
  800469:	8b 00                	mov    (%eax),%eax
  80046b:	99                   	cltd   
  80046c:	eb 18                	jmp    800486 <getint+0x5d>
	else
		return va_arg(*ap, int);
  80046e:	8b 45 08             	mov    0x8(%ebp),%eax
  800471:	8b 00                	mov    (%eax),%eax
  800473:	8d 50 04             	lea    0x4(%eax),%edx
  800476:	8b 45 08             	mov    0x8(%ebp),%eax
  800479:	89 10                	mov    %edx,(%eax)
  80047b:	8b 45 08             	mov    0x8(%ebp),%eax
  80047e:	8b 00                	mov    (%eax),%eax
  800480:	83 e8 04             	sub    $0x4,%eax
  800483:	8b 00                	mov    (%eax),%eax
  800485:	99                   	cltd   
}
  800486:	5d                   	pop    %ebp
  800487:	c3                   	ret    

00800488 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800488:	55                   	push   %ebp
  800489:	89 e5                	mov    %esp,%ebp
  80048b:	56                   	push   %esi
  80048c:	53                   	push   %ebx
  80048d:	83 ec 20             	sub    $0x20,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800490:	eb 17                	jmp    8004a9 <vprintfmt+0x21>
			if (ch == '\0')
  800492:	85 db                	test   %ebx,%ebx
  800494:	0f 84 c1 03 00 00    	je     80085b <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  80049a:	83 ec 08             	sub    $0x8,%esp
  80049d:	ff 75 0c             	pushl  0xc(%ebp)
  8004a0:	53                   	push   %ebx
  8004a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a4:	ff d0                	call   *%eax
  8004a6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8004ac:	8d 50 01             	lea    0x1(%eax),%edx
  8004af:	89 55 10             	mov    %edx,0x10(%ebp)
  8004b2:	8a 00                	mov    (%eax),%al
  8004b4:	0f b6 d8             	movzbl %al,%ebx
  8004b7:	83 fb 25             	cmp    $0x25,%ebx
  8004ba:	75 d6                	jne    800492 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8004bc:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8004c0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8004c7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8004ce:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8004d5:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8004df:	8d 50 01             	lea    0x1(%eax),%edx
  8004e2:	89 55 10             	mov    %edx,0x10(%ebp)
  8004e5:	8a 00                	mov    (%eax),%al
  8004e7:	0f b6 d8             	movzbl %al,%ebx
  8004ea:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8004ed:	83 f8 5b             	cmp    $0x5b,%eax
  8004f0:	0f 87 3d 03 00 00    	ja     800833 <vprintfmt+0x3ab>
  8004f6:	8b 04 85 b8 1e 80 00 	mov    0x801eb8(,%eax,4),%eax
  8004fd:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8004ff:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800503:	eb d7                	jmp    8004dc <vprintfmt+0x54>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800505:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800509:	eb d1                	jmp    8004dc <vprintfmt+0x54>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80050b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800512:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800515:	89 d0                	mov    %edx,%eax
  800517:	c1 e0 02             	shl    $0x2,%eax
  80051a:	01 d0                	add    %edx,%eax
  80051c:	01 c0                	add    %eax,%eax
  80051e:	01 d8                	add    %ebx,%eax
  800520:	83 e8 30             	sub    $0x30,%eax
  800523:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800526:	8b 45 10             	mov    0x10(%ebp),%eax
  800529:	8a 00                	mov    (%eax),%al
  80052b:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  80052e:	83 fb 2f             	cmp    $0x2f,%ebx
  800531:	7e 3e                	jle    800571 <vprintfmt+0xe9>
  800533:	83 fb 39             	cmp    $0x39,%ebx
  800536:	7f 39                	jg     800571 <vprintfmt+0xe9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800538:	ff 45 10             	incl   0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80053b:	eb d5                	jmp    800512 <vprintfmt+0x8a>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80053d:	8b 45 14             	mov    0x14(%ebp),%eax
  800540:	83 c0 04             	add    $0x4,%eax
  800543:	89 45 14             	mov    %eax,0x14(%ebp)
  800546:	8b 45 14             	mov    0x14(%ebp),%eax
  800549:	83 e8 04             	sub    $0x4,%eax
  80054c:	8b 00                	mov    (%eax),%eax
  80054e:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800551:	eb 1f                	jmp    800572 <vprintfmt+0xea>

		case '.':
			if (width < 0)
  800553:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800557:	79 83                	jns    8004dc <vprintfmt+0x54>
				width = 0;
  800559:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800560:	e9 77 ff ff ff       	jmp    8004dc <vprintfmt+0x54>

		case '#':
			altflag = 1;
  800565:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80056c:	e9 6b ff ff ff       	jmp    8004dc <vprintfmt+0x54>
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto process_precision;
  800571:	90                   	nop
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800572:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800576:	0f 89 60 ff ff ff    	jns    8004dc <vprintfmt+0x54>
				width = precision, precision = -1;
  80057c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80057f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800582:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800589:	e9 4e ff ff ff       	jmp    8004dc <vprintfmt+0x54>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80058e:	ff 45 e8             	incl   -0x18(%ebp)
			goto reswitch;
  800591:	e9 46 ff ff ff       	jmp    8004dc <vprintfmt+0x54>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	83 c0 04             	add    $0x4,%eax
  80059c:	89 45 14             	mov    %eax,0x14(%ebp)
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	83 e8 04             	sub    $0x4,%eax
  8005a5:	8b 00                	mov    (%eax),%eax
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	ff 75 0c             	pushl  0xc(%ebp)
  8005ad:	50                   	push   %eax
  8005ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b1:	ff d0                	call   *%eax
  8005b3:	83 c4 10             	add    $0x10,%esp
			break;
  8005b6:	e9 9b 02 00 00       	jmp    800856 <vprintfmt+0x3ce>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	83 c0 04             	add    $0x4,%eax
  8005c1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	83 e8 04             	sub    $0x4,%eax
  8005ca:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8005cc:	85 db                	test   %ebx,%ebx
  8005ce:	79 02                	jns    8005d2 <vprintfmt+0x14a>
				err = -err;
  8005d0:	f7 db                	neg    %ebx
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8005d2:	83 fb 64             	cmp    $0x64,%ebx
  8005d5:	7f 0b                	jg     8005e2 <vprintfmt+0x15a>
  8005d7:	8b 34 9d 00 1d 80 00 	mov    0x801d00(,%ebx,4),%esi
  8005de:	85 f6                	test   %esi,%esi
  8005e0:	75 19                	jne    8005fb <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  8005e2:	53                   	push   %ebx
  8005e3:	68 a5 1e 80 00       	push   $0x801ea5
  8005e8:	ff 75 0c             	pushl  0xc(%ebp)
  8005eb:	ff 75 08             	pushl  0x8(%ebp)
  8005ee:	e8 70 02 00 00       	call   800863 <printfmt>
  8005f3:	83 c4 10             	add    $0x10,%esp
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8005f6:	e9 5b 02 00 00       	jmp    800856 <vprintfmt+0x3ce>
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8005fb:	56                   	push   %esi
  8005fc:	68 ae 1e 80 00       	push   $0x801eae
  800601:	ff 75 0c             	pushl  0xc(%ebp)
  800604:	ff 75 08             	pushl  0x8(%ebp)
  800607:	e8 57 02 00 00       	call   800863 <printfmt>
  80060c:	83 c4 10             	add    $0x10,%esp
			break;
  80060f:	e9 42 02 00 00       	jmp    800856 <vprintfmt+0x3ce>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	83 c0 04             	add    $0x4,%eax
  80061a:	89 45 14             	mov    %eax,0x14(%ebp)
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	83 e8 04             	sub    $0x4,%eax
  800623:	8b 30                	mov    (%eax),%esi
  800625:	85 f6                	test   %esi,%esi
  800627:	75 05                	jne    80062e <vprintfmt+0x1a6>
				p = "(null)";
  800629:	be b1 1e 80 00       	mov    $0x801eb1,%esi
			if (width > 0 && padc != '-')
  80062e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800632:	7e 6d                	jle    8006a1 <vprintfmt+0x219>
  800634:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800638:	74 67                	je     8006a1 <vprintfmt+0x219>
				for (width -= strnlen(p, precision); width > 0; width--)
  80063a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80063d:	83 ec 08             	sub    $0x8,%esp
  800640:	50                   	push   %eax
  800641:	56                   	push   %esi
  800642:	e8 1e 03 00 00       	call   800965 <strnlen>
  800647:	83 c4 10             	add    $0x10,%esp
  80064a:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80064d:	eb 16                	jmp    800665 <vprintfmt+0x1dd>
					putch(padc, putdat);
  80064f:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800653:	83 ec 08             	sub    $0x8,%esp
  800656:	ff 75 0c             	pushl  0xc(%ebp)
  800659:	50                   	push   %eax
  80065a:	8b 45 08             	mov    0x8(%ebp),%eax
  80065d:	ff d0                	call   *%eax
  80065f:	83 c4 10             	add    $0x10,%esp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800662:	ff 4d e4             	decl   -0x1c(%ebp)
  800665:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800669:	7f e4                	jg     80064f <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80066b:	eb 34                	jmp    8006a1 <vprintfmt+0x219>
				if (altflag && (ch < ' ' || ch > '~'))
  80066d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800671:	74 1c                	je     80068f <vprintfmt+0x207>
  800673:	83 fb 1f             	cmp    $0x1f,%ebx
  800676:	7e 05                	jle    80067d <vprintfmt+0x1f5>
  800678:	83 fb 7e             	cmp    $0x7e,%ebx
  80067b:	7e 12                	jle    80068f <vprintfmt+0x207>
					putch('?', putdat);
  80067d:	83 ec 08             	sub    $0x8,%esp
  800680:	ff 75 0c             	pushl  0xc(%ebp)
  800683:	6a 3f                	push   $0x3f
  800685:	8b 45 08             	mov    0x8(%ebp),%eax
  800688:	ff d0                	call   *%eax
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	eb 0f                	jmp    80069e <vprintfmt+0x216>
				else
					putch(ch, putdat);
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	ff 75 0c             	pushl  0xc(%ebp)
  800695:	53                   	push   %ebx
  800696:	8b 45 08             	mov    0x8(%ebp),%eax
  800699:	ff d0                	call   *%eax
  80069b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069e:	ff 4d e4             	decl   -0x1c(%ebp)
  8006a1:	89 f0                	mov    %esi,%eax
  8006a3:	8d 70 01             	lea    0x1(%eax),%esi
  8006a6:	8a 00                	mov    (%eax),%al
  8006a8:	0f be d8             	movsbl %al,%ebx
  8006ab:	85 db                	test   %ebx,%ebx
  8006ad:	74 24                	je     8006d3 <vprintfmt+0x24b>
  8006af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006b3:	78 b8                	js     80066d <vprintfmt+0x1e5>
  8006b5:	ff 4d e0             	decl   -0x20(%ebp)
  8006b8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006bc:	79 af                	jns    80066d <vprintfmt+0x1e5>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006be:	eb 13                	jmp    8006d3 <vprintfmt+0x24b>
				putch(' ', putdat);
  8006c0:	83 ec 08             	sub    $0x8,%esp
  8006c3:	ff 75 0c             	pushl  0xc(%ebp)
  8006c6:	6a 20                	push   $0x20
  8006c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cb:	ff d0                	call   *%eax
  8006cd:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006d0:	ff 4d e4             	decl   -0x1c(%ebp)
  8006d3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006d7:	7f e7                	jg     8006c0 <vprintfmt+0x238>
				putch(' ', putdat);
			break;
  8006d9:	e9 78 01 00 00       	jmp    800856 <vprintfmt+0x3ce>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006de:	83 ec 08             	sub    $0x8,%esp
  8006e1:	ff 75 e8             	pushl  -0x18(%ebp)
  8006e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e7:	50                   	push   %eax
  8006e8:	e8 3c fd ff ff       	call   800429 <getint>
  8006ed:	83 c4 10             	add    $0x10,%esp
  8006f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006f3:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8006f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006fc:	85 d2                	test   %edx,%edx
  8006fe:	79 23                	jns    800723 <vprintfmt+0x29b>
				putch('-', putdat);
  800700:	83 ec 08             	sub    $0x8,%esp
  800703:	ff 75 0c             	pushl  0xc(%ebp)
  800706:	6a 2d                	push   $0x2d
  800708:	8b 45 08             	mov    0x8(%ebp),%eax
  80070b:	ff d0                	call   *%eax
  80070d:	83 c4 10             	add    $0x10,%esp
				num = -(long long) num;
  800710:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800713:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800716:	f7 d8                	neg    %eax
  800718:	83 d2 00             	adc    $0x0,%edx
  80071b:	f7 da                	neg    %edx
  80071d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800720:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800723:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80072a:	e9 bc 00 00 00       	jmp    8007eb <vprintfmt+0x363>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80072f:	83 ec 08             	sub    $0x8,%esp
  800732:	ff 75 e8             	pushl  -0x18(%ebp)
  800735:	8d 45 14             	lea    0x14(%ebp),%eax
  800738:	50                   	push   %eax
  800739:	e8 84 fc ff ff       	call   8003c2 <getuint>
  80073e:	83 c4 10             	add    $0x10,%esp
  800741:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800744:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800747:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80074e:	e9 98 00 00 00       	jmp    8007eb <vprintfmt+0x363>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800753:	83 ec 08             	sub    $0x8,%esp
  800756:	ff 75 0c             	pushl  0xc(%ebp)
  800759:	6a 58                	push   $0x58
  80075b:	8b 45 08             	mov    0x8(%ebp),%eax
  80075e:	ff d0                	call   *%eax
  800760:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	ff 75 0c             	pushl  0xc(%ebp)
  800769:	6a 58                	push   $0x58
  80076b:	8b 45 08             	mov    0x8(%ebp),%eax
  80076e:	ff d0                	call   *%eax
  800770:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800773:	83 ec 08             	sub    $0x8,%esp
  800776:	ff 75 0c             	pushl  0xc(%ebp)
  800779:	6a 58                	push   $0x58
  80077b:	8b 45 08             	mov    0x8(%ebp),%eax
  80077e:	ff d0                	call   *%eax
  800780:	83 c4 10             	add    $0x10,%esp
			break;
  800783:	e9 ce 00 00 00       	jmp    800856 <vprintfmt+0x3ce>

		// pointer
		case 'p':
			putch('0', putdat);
  800788:	83 ec 08             	sub    $0x8,%esp
  80078b:	ff 75 0c             	pushl  0xc(%ebp)
  80078e:	6a 30                	push   $0x30
  800790:	8b 45 08             	mov    0x8(%ebp),%eax
  800793:	ff d0                	call   *%eax
  800795:	83 c4 10             	add    $0x10,%esp
			putch('x', putdat);
  800798:	83 ec 08             	sub    $0x8,%esp
  80079b:	ff 75 0c             	pushl  0xc(%ebp)
  80079e:	6a 78                	push   $0x78
  8007a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a3:	ff d0                	call   *%eax
  8007a5:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)
				(uint32) va_arg(ap, void *);
  8007a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ab:	83 c0 04             	add    $0x4,%eax
  8007ae:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b4:	83 e8 04             	sub    $0x4,%eax
  8007b7:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uint32) va_arg(ap, void *);
			base = 16;
  8007c3:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  8007ca:	eb 1f                	jmp    8007eb <vprintfmt+0x363>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	ff 75 e8             	pushl  -0x18(%ebp)
  8007d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d5:	50                   	push   %eax
  8007d6:	e8 e7 fb ff ff       	call   8003c2 <getuint>
  8007db:	83 c4 10             	add    $0x10,%esp
  8007de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007e1:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8007e4:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007eb:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8007ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f2:	83 ec 04             	sub    $0x4,%esp
  8007f5:	52                   	push   %edx
  8007f6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007f9:	50                   	push   %eax
  8007fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8007fd:	ff 75 f0             	pushl  -0x10(%ebp)
  800800:	ff 75 0c             	pushl  0xc(%ebp)
  800803:	ff 75 08             	pushl  0x8(%ebp)
  800806:	e8 00 fb ff ff       	call   80030b <printnum>
  80080b:	83 c4 20             	add    $0x20,%esp
			break;
  80080e:	eb 46                	jmp    800856 <vprintfmt+0x3ce>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800810:	83 ec 08             	sub    $0x8,%esp
  800813:	ff 75 0c             	pushl  0xc(%ebp)
  800816:	53                   	push   %ebx
  800817:	8b 45 08             	mov    0x8(%ebp),%eax
  80081a:	ff d0                	call   *%eax
  80081c:	83 c4 10             	add    $0x10,%esp
			break;
  80081f:	eb 35                	jmp    800856 <vprintfmt+0x3ce>

		/**********************************/
		/*2023*/
		// DON'T Print Program Name & UD
		case '~':
			printProgName = 0;
  800821:	c6 05 08 30 80 00 00 	movb   $0x0,0x803008
			break;
  800828:	eb 2c                	jmp    800856 <vprintfmt+0x3ce>
		// Print Program Name & UD
		case '@':
			printProgName = 1;
  80082a:	c6 05 08 30 80 00 01 	movb   $0x1,0x803008
			break;
  800831:	eb 23                	jmp    800856 <vprintfmt+0x3ce>
		/**********************************/

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800833:	83 ec 08             	sub    $0x8,%esp
  800836:	ff 75 0c             	pushl  0xc(%ebp)
  800839:	6a 25                	push   $0x25
  80083b:	8b 45 08             	mov    0x8(%ebp),%eax
  80083e:	ff d0                	call   *%eax
  800840:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800843:	ff 4d 10             	decl   0x10(%ebp)
  800846:	eb 03                	jmp    80084b <vprintfmt+0x3c3>
  800848:	ff 4d 10             	decl   0x10(%ebp)
  80084b:	8b 45 10             	mov    0x10(%ebp),%eax
  80084e:	48                   	dec    %eax
  80084f:	8a 00                	mov    (%eax),%al
  800851:	3c 25                	cmp    $0x25,%al
  800853:	75 f3                	jne    800848 <vprintfmt+0x3c0>
				/* do nothing */;
			break;
  800855:	90                   	nop
		}
	}
  800856:	e9 35 fc ff ff       	jmp    800490 <vprintfmt+0x8>
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
  80085b:	90                   	nop
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80085c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80085f:	5b                   	pop    %ebx
  800860:	5e                   	pop    %esi
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800869:	8d 45 10             	lea    0x10(%ebp),%eax
  80086c:	83 c0 04             	add    $0x4,%eax
  80086f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800872:	8b 45 10             	mov    0x10(%ebp),%eax
  800875:	ff 75 f4             	pushl  -0xc(%ebp)
  800878:	50                   	push   %eax
  800879:	ff 75 0c             	pushl  0xc(%ebp)
  80087c:	ff 75 08             	pushl  0x8(%ebp)
  80087f:	e8 04 fc ff ff       	call   800488 <vprintfmt>
  800884:	83 c4 10             	add    $0x10,%esp
	va_end(ap);
}
  800887:	90                   	nop
  800888:	c9                   	leave  
  800889:	c3                   	ret    

0080088a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  80088d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800890:	8b 40 08             	mov    0x8(%eax),%eax
  800893:	8d 50 01             	lea    0x1(%eax),%edx
  800896:	8b 45 0c             	mov    0xc(%ebp),%eax
  800899:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  80089c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089f:	8b 10                	mov    (%eax),%edx
  8008a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a4:	8b 40 04             	mov    0x4(%eax),%eax
  8008a7:	39 c2                	cmp    %eax,%edx
  8008a9:	73 12                	jae    8008bd <sprintputch+0x33>
		*b->buf++ = ch;
  8008ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ae:	8b 00                	mov    (%eax),%eax
  8008b0:	8d 48 01             	lea    0x1(%eax),%ecx
  8008b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b6:	89 0a                	mov    %ecx,(%edx)
  8008b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8008bb:	88 10                	mov    %dl,(%eax)
}
  8008bd:	90                   	nop
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	83 ec 18             	sub    $0x18,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cf:	8d 50 ff             	lea    -0x1(%eax),%edx
  8008d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d5:	01 d0                	add    %edx,%eax
  8008d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008e1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8008e5:	74 06                	je     8008ed <vsnprintf+0x2d>
  8008e7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008eb:	7f 07                	jg     8008f4 <vsnprintf+0x34>
		return -E_INVAL;
  8008ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8008f2:	eb 20                	jmp    800914 <vsnprintf+0x54>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f4:	ff 75 14             	pushl  0x14(%ebp)
  8008f7:	ff 75 10             	pushl  0x10(%ebp)
  8008fa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008fd:	50                   	push   %eax
  8008fe:	68 8a 08 80 00       	push   $0x80088a
  800903:	e8 80 fb ff ff       	call   800488 <vprintfmt>
  800908:	83 c4 10             	add    $0x10,%esp

	// null terminate the buffer
	*b.buf = '\0';
  80090b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80090e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800911:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800914:	c9                   	leave  
  800915:	c3                   	ret    

00800916 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80091c:	8d 45 10             	lea    0x10(%ebp),%eax
  80091f:	83 c0 04             	add    $0x4,%eax
  800922:	89 45 f4             	mov    %eax,-0xc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800925:	8b 45 10             	mov    0x10(%ebp),%eax
  800928:	ff 75 f4             	pushl  -0xc(%ebp)
  80092b:	50                   	push   %eax
  80092c:	ff 75 0c             	pushl  0xc(%ebp)
  80092f:	ff 75 08             	pushl  0x8(%ebp)
  800932:	e8 89 ff ff ff       	call   8008c0 <vsnprintf>
  800937:	83 c4 10             	add    $0x10,%esp
  80093a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return rc;
  80093d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800940:	c9                   	leave  
  800941:	c3                   	ret    

00800942 <strlen>:
#include <inc/string.h>
#include <inc/assert.h>

int
strlen(const char *s)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800948:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80094f:	eb 06                	jmp    800957 <strlen+0x15>
		n++;
  800951:	ff 45 fc             	incl   -0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800954:	ff 45 08             	incl   0x8(%ebp)
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8a 00                	mov    (%eax),%al
  80095c:	84 c0                	test   %al,%al
  80095e:	75 f1                	jne    800951 <strlen+0xf>
		n++;
	return n;
  800960:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800963:	c9                   	leave  
  800964:	c3                   	ret    

00800965 <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80096b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800972:	eb 09                	jmp    80097d <strnlen+0x18>
		n++;
  800974:	ff 45 fc             	incl   -0x4(%ebp)
int
strnlen(const char *s, uint32 size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800977:	ff 45 08             	incl   0x8(%ebp)
  80097a:	ff 4d 0c             	decl   0xc(%ebp)
  80097d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800981:	74 09                	je     80098c <strnlen+0x27>
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
  800986:	8a 00                	mov    (%eax),%al
  800988:	84 c0                	test   %al,%al
  80098a:	75 e8                	jne    800974 <strnlen+0xf>
		n++;
	return n;
  80098c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80098f:	c9                   	leave  
  800990:	c3                   	ret    

00800991 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  80099d:	90                   	nop
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	8d 50 01             	lea    0x1(%eax),%edx
  8009a4:	89 55 08             	mov    %edx,0x8(%ebp)
  8009a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009aa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009ad:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8009b0:	8a 12                	mov    (%edx),%dl
  8009b2:	88 10                	mov    %dl,(%eax)
  8009b4:	8a 00                	mov    (%eax),%al
  8009b6:	84 c0                	test   %al,%al
  8009b8:	75 e4                	jne    80099e <strcpy+0xd>
		/* do nothing */;
	return ret;
  8009ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009bd:	c9                   	leave  
  8009be:	c3                   	ret    

008009bf <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	83 ec 10             	sub    $0x10,%esp
	uint32 i;
	char *ret;

	ret = dst;
  8009c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c8:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8009cb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8009d2:	eb 1f                	jmp    8009f3 <strncpy+0x34>
		*dst++ = *src;
  8009d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d7:	8d 50 01             	lea    0x1(%eax),%edx
  8009da:	89 55 08             	mov    %edx,0x8(%ebp)
  8009dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e0:	8a 12                	mov    (%edx),%dl
  8009e2:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8009e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e7:	8a 00                	mov    (%eax),%al
  8009e9:	84 c0                	test   %al,%al
  8009eb:	74 03                	je     8009f0 <strncpy+0x31>
			src++;
  8009ed:	ff 45 0c             	incl   0xc(%ebp)
strncpy(char *dst, const char *src, uint32 size) {
	uint32 i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f0:	ff 45 fc             	incl   -0x4(%ebp)
  8009f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009f6:	3b 45 10             	cmp    0x10(%ebp),%eax
  8009f9:	72 d9                	jb     8009d4 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8009fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8009fe:	c9                   	leave  
  8009ff:	c3                   	ret    

00800a00 <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800a0c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a10:	74 30                	je     800a42 <strlcpy+0x42>
		while (--size > 0 && *src != '\0')
  800a12:	eb 16                	jmp    800a2a <strlcpy+0x2a>
			*dst++ = *src++;
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	8d 50 01             	lea    0x1(%eax),%edx
  800a1a:	89 55 08             	mov    %edx,0x8(%ebp)
  800a1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a20:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a23:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800a26:	8a 12                	mov    (%edx),%dl
  800a28:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a2a:	ff 4d 10             	decl   0x10(%ebp)
  800a2d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a31:	74 09                	je     800a3c <strlcpy+0x3c>
  800a33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a36:	8a 00                	mov    (%eax),%al
  800a38:	84 c0                	test   %al,%al
  800a3a:	75 d8                	jne    800a14 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a42:	8b 55 08             	mov    0x8(%ebp),%edx
  800a45:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a48:	29 c2                	sub    %eax,%edx
  800a4a:	89 d0                	mov    %edx,%eax
}
  800a4c:	c9                   	leave  
  800a4d:	c3                   	ret    

00800a4e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800a51:	eb 06                	jmp    800a59 <strcmp+0xb>
		p++, q++;
  800a53:	ff 45 08             	incl   0x8(%ebp)
  800a56:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a59:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5c:	8a 00                	mov    (%eax),%al
  800a5e:	84 c0                	test   %al,%al
  800a60:	74 0e                	je     800a70 <strcmp+0x22>
  800a62:	8b 45 08             	mov    0x8(%ebp),%eax
  800a65:	8a 10                	mov    (%eax),%dl
  800a67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6a:	8a 00                	mov    (%eax),%al
  800a6c:	38 c2                	cmp    %al,%dl
  800a6e:	74 e3                	je     800a53 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a70:	8b 45 08             	mov    0x8(%ebp),%eax
  800a73:	8a 00                	mov    (%eax),%al
  800a75:	0f b6 d0             	movzbl %al,%edx
  800a78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7b:	8a 00                	mov    (%eax),%al
  800a7d:	0f b6 c0             	movzbl %al,%eax
  800a80:	29 c2                	sub    %eax,%edx
  800a82:	89 d0                	mov    %edx,%eax
}
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800a89:	eb 09                	jmp    800a94 <strncmp+0xe>
		n--, p++, q++;
  800a8b:	ff 4d 10             	decl   0x10(%ebp)
  800a8e:	ff 45 08             	incl   0x8(%ebp)
  800a91:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint32 n)
{
	while (n > 0 && *p && *p == *q)
  800a94:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a98:	74 17                	je     800ab1 <strncmp+0x2b>
  800a9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9d:	8a 00                	mov    (%eax),%al
  800a9f:	84 c0                	test   %al,%al
  800aa1:	74 0e                	je     800ab1 <strncmp+0x2b>
  800aa3:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa6:	8a 10                	mov    (%eax),%dl
  800aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aab:	8a 00                	mov    (%eax),%al
  800aad:	38 c2                	cmp    %al,%dl
  800aaf:	74 da                	je     800a8b <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800ab1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ab5:	75 07                	jne    800abe <strncmp+0x38>
		return 0;
  800ab7:	b8 00 00 00 00       	mov    $0x0,%eax
  800abc:	eb 14                	jmp    800ad2 <strncmp+0x4c>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800abe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac1:	8a 00                	mov    (%eax),%al
  800ac3:	0f b6 d0             	movzbl %al,%edx
  800ac6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac9:	8a 00                	mov    (%eax),%al
  800acb:	0f b6 c0             	movzbl %al,%eax
  800ace:	29 c2                	sub    %eax,%edx
  800ad0:	89 d0                	mov    %edx,%eax
}
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	83 ec 04             	sub    $0x4,%esp
  800ada:	8b 45 0c             	mov    0xc(%ebp),%eax
  800add:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800ae0:	eb 12                	jmp    800af4 <strchr+0x20>
		if (*s == c)
  800ae2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae5:	8a 00                	mov    (%eax),%al
  800ae7:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800aea:	75 05                	jne    800af1 <strchr+0x1d>
			return (char *) s;
  800aec:	8b 45 08             	mov    0x8(%ebp),%eax
  800aef:	eb 11                	jmp    800b02 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800af1:	ff 45 08             	incl   0x8(%ebp)
  800af4:	8b 45 08             	mov    0x8(%ebp),%eax
  800af7:	8a 00                	mov    (%eax),%al
  800af9:	84 c0                	test   %al,%al
  800afb:	75 e5                	jne    800ae2 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800afd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b02:	c9                   	leave  
  800b03:	c3                   	ret    

00800b04 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	83 ec 04             	sub    $0x4,%esp
  800b0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0d:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b10:	eb 0d                	jmp    800b1f <strfind+0x1b>
		if (*s == c)
  800b12:	8b 45 08             	mov    0x8(%ebp),%eax
  800b15:	8a 00                	mov    (%eax),%al
  800b17:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b1a:	74 0e                	je     800b2a <strfind+0x26>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b1c:	ff 45 08             	incl   0x8(%ebp)
  800b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b22:	8a 00                	mov    (%eax),%al
  800b24:	84 c0                	test   %al,%al
  800b26:	75 ea                	jne    800b12 <strfind+0xe>
  800b28:	eb 01                	jmp    800b2b <strfind+0x27>
		if (*s == c)
			break;
  800b2a:	90                   	nop
	return (char *) s;
  800b2b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b2e:	c9                   	leave  
  800b2f:	c3                   	ret    

00800b30 <memset>:


void *
memset(void *v, int c, uint32 n)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	83 ec 10             	sub    $0x10,%esp
	char *p;
	int m;

	p = v;
  800b36:	8b 45 08             	mov    0x8(%ebp),%eax
  800b39:	89 45 fc             	mov    %eax,-0x4(%ebp)
	m = n;
  800b3c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b3f:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (--m >= 0)
  800b42:	eb 0e                	jmp    800b52 <memset+0x22>
		*p++ = c;
  800b44:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b47:	8d 50 01             	lea    0x1(%eax),%edx
  800b4a:	89 55 fc             	mov    %edx,-0x4(%ebp)
  800b4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b50:	88 10                	mov    %dl,(%eax)
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800b52:	ff 4d f8             	decl   -0x8(%ebp)
  800b55:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
  800b59:	79 e9                	jns    800b44 <memset+0x14>
		*p++ = c;

	return v;
  800b5b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b5e:	c9                   	leave  
  800b5f:	c3                   	ret    

00800b60 <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b66:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b69:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800b6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6f:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
  800b72:	eb 16                	jmp    800b8a <memcpy+0x2a>
		*d++ = *s++;
  800b74:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800b77:	8d 50 01             	lea    0x1(%eax),%edx
  800b7a:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800b7d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800b80:	8d 4a 01             	lea    0x1(%edx),%ecx
  800b83:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800b86:	8a 12                	mov    (%edx),%dl
  800b88:	88 10                	mov    %dl,(%eax)
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800b8a:	8b 45 10             	mov    0x10(%ebp),%eax
  800b8d:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b90:	89 55 10             	mov    %edx,0x10(%ebp)
  800b93:	85 c0                	test   %eax,%eax
  800b95:	75 dd                	jne    800b74 <memcpy+0x14>
		*d++ = *s++;

	return dst;
  800b97:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b9a:	c9                   	leave  
  800b9b:	c3                   	ret    

00800b9c <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800ba8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bab:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (s < d && s + n > d) {
  800bae:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bb1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800bb4:	73 50                	jae    800c06 <memmove+0x6a>
  800bb6:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800bb9:	8b 45 10             	mov    0x10(%ebp),%eax
  800bbc:	01 d0                	add    %edx,%eax
  800bbe:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800bc1:	76 43                	jbe    800c06 <memmove+0x6a>
		s += n;
  800bc3:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc6:	01 45 fc             	add    %eax,-0x4(%ebp)
		d += n;
  800bc9:	8b 45 10             	mov    0x10(%ebp),%eax
  800bcc:	01 45 f8             	add    %eax,-0x8(%ebp)
		while (n-- > 0)
  800bcf:	eb 10                	jmp    800be1 <memmove+0x45>
			*--d = *--s;
  800bd1:	ff 4d f8             	decl   -0x8(%ebp)
  800bd4:	ff 4d fc             	decl   -0x4(%ebp)
  800bd7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bda:	8a 10                	mov    (%eax),%dl
  800bdc:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bdf:	88 10                	mov    %dl,(%eax)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800be1:	8b 45 10             	mov    0x10(%ebp),%eax
  800be4:	8d 50 ff             	lea    -0x1(%eax),%edx
  800be7:	89 55 10             	mov    %edx,0x10(%ebp)
  800bea:	85 c0                	test   %eax,%eax
  800bec:	75 e3                	jne    800bd1 <memmove+0x35>
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bee:	eb 23                	jmp    800c13 <memmove+0x77>
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800bf0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bf3:	8d 50 01             	lea    0x1(%eax),%edx
  800bf6:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800bf9:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800bfc:	8d 4a 01             	lea    0x1(%edx),%ecx
  800bff:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800c02:	8a 12                	mov    (%edx),%dl
  800c04:	88 10                	mov    %dl,(%eax)
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800c06:	8b 45 10             	mov    0x10(%ebp),%eax
  800c09:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c0c:	89 55 10             	mov    %edx,0x10(%ebp)
  800c0f:	85 c0                	test   %eax,%eax
  800c11:	75 dd                	jne    800bf0 <memmove+0x54>
			*d++ = *s++;

	return dst;
  800c13:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c16:	c9                   	leave  
  800c17:	c3                   	ret    

00800c18 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	83 ec 10             	sub    $0x10,%esp
	const uint8 *s1 = (const uint8 *) v1;
  800c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c21:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8 *s2 = (const uint8 *) v2;
  800c24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c27:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800c2a:	eb 2a                	jmp    800c56 <memcmp+0x3e>
		if (*s1 != *s2)
  800c2c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c2f:	8a 10                	mov    (%eax),%dl
  800c31:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c34:	8a 00                	mov    (%eax),%al
  800c36:	38 c2                	cmp    %al,%dl
  800c38:	74 16                	je     800c50 <memcmp+0x38>
			return (int) *s1 - (int) *s2;
  800c3a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c3d:	8a 00                	mov    (%eax),%al
  800c3f:	0f b6 d0             	movzbl %al,%edx
  800c42:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c45:	8a 00                	mov    (%eax),%al
  800c47:	0f b6 c0             	movzbl %al,%eax
  800c4a:	29 c2                	sub    %eax,%edx
  800c4c:	89 d0                	mov    %edx,%eax
  800c4e:	eb 18                	jmp    800c68 <memcmp+0x50>
		s1++, s2++;
  800c50:	ff 45 fc             	incl   -0x4(%ebp)
  800c53:	ff 45 f8             	incl   -0x8(%ebp)
memcmp(const void *v1, const void *v2, uint32 n)
{
	const uint8 *s1 = (const uint8 *) v1;
	const uint8 *s2 = (const uint8 *) v2;

	while (n-- > 0) {
  800c56:	8b 45 10             	mov    0x10(%ebp),%eax
  800c59:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c5c:	89 55 10             	mov    %edx,0x10(%ebp)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	75 c9                	jne    800c2c <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c68:	c9                   	leave  
  800c69:	c3                   	ret    

00800c6a <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c70:	8b 55 08             	mov    0x8(%ebp),%edx
  800c73:	8b 45 10             	mov    0x10(%ebp),%eax
  800c76:	01 d0                	add    %edx,%eax
  800c78:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c7b:	eb 15                	jmp    800c92 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c80:	8a 00                	mov    (%eax),%al
  800c82:	0f b6 d0             	movzbl %al,%edx
  800c85:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c88:	0f b6 c0             	movzbl %al,%eax
  800c8b:	39 c2                	cmp    %eax,%edx
  800c8d:	74 0d                	je     800c9c <memfind+0x32>

void *
memfind(const void *s, int c, uint32 n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c8f:	ff 45 08             	incl   0x8(%ebp)
  800c92:	8b 45 08             	mov    0x8(%ebp),%eax
  800c95:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800c98:	72 e3                	jb     800c7d <memfind+0x13>
  800c9a:	eb 01                	jmp    800c9d <memfind+0x33>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
  800c9c:	90                   	nop
	return (void *) s;
  800c9d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ca0:	c9                   	leave  
  800ca1:	c3                   	ret    

00800ca2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800ca8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800caf:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb6:	eb 03                	jmp    800cbb <strtol+0x19>
		s++;
  800cb8:	ff 45 08             	incl   0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbe:	8a 00                	mov    (%eax),%al
  800cc0:	3c 20                	cmp    $0x20,%al
  800cc2:	74 f4                	je     800cb8 <strtol+0x16>
  800cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc7:	8a 00                	mov    (%eax),%al
  800cc9:	3c 09                	cmp    $0x9,%al
  800ccb:	74 eb                	je     800cb8 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ccd:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd0:	8a 00                	mov    (%eax),%al
  800cd2:	3c 2b                	cmp    $0x2b,%al
  800cd4:	75 05                	jne    800cdb <strtol+0x39>
		s++;
  800cd6:	ff 45 08             	incl   0x8(%ebp)
  800cd9:	eb 13                	jmp    800cee <strtol+0x4c>
	else if (*s == '-')
  800cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cde:	8a 00                	mov    (%eax),%al
  800ce0:	3c 2d                	cmp    $0x2d,%al
  800ce2:	75 0a                	jne    800cee <strtol+0x4c>
		s++, neg = 1;
  800ce4:	ff 45 08             	incl   0x8(%ebp)
  800ce7:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cf2:	74 06                	je     800cfa <strtol+0x58>
  800cf4:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800cf8:	75 20                	jne    800d1a <strtol+0x78>
  800cfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfd:	8a 00                	mov    (%eax),%al
  800cff:	3c 30                	cmp    $0x30,%al
  800d01:	75 17                	jne    800d1a <strtol+0x78>
  800d03:	8b 45 08             	mov    0x8(%ebp),%eax
  800d06:	40                   	inc    %eax
  800d07:	8a 00                	mov    (%eax),%al
  800d09:	3c 78                	cmp    $0x78,%al
  800d0b:	75 0d                	jne    800d1a <strtol+0x78>
		s += 2, base = 16;
  800d0d:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800d11:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800d18:	eb 28                	jmp    800d42 <strtol+0xa0>
	else if (base == 0 && s[0] == '0')
  800d1a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d1e:	75 15                	jne    800d35 <strtol+0x93>
  800d20:	8b 45 08             	mov    0x8(%ebp),%eax
  800d23:	8a 00                	mov    (%eax),%al
  800d25:	3c 30                	cmp    $0x30,%al
  800d27:	75 0c                	jne    800d35 <strtol+0x93>
		s++, base = 8;
  800d29:	ff 45 08             	incl   0x8(%ebp)
  800d2c:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d33:	eb 0d                	jmp    800d42 <strtol+0xa0>
	else if (base == 0)
  800d35:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d39:	75 07                	jne    800d42 <strtol+0xa0>
		base = 10;
  800d3b:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d42:	8b 45 08             	mov    0x8(%ebp),%eax
  800d45:	8a 00                	mov    (%eax),%al
  800d47:	3c 2f                	cmp    $0x2f,%al
  800d49:	7e 19                	jle    800d64 <strtol+0xc2>
  800d4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4e:	8a 00                	mov    (%eax),%al
  800d50:	3c 39                	cmp    $0x39,%al
  800d52:	7f 10                	jg     800d64 <strtol+0xc2>
			dig = *s - '0';
  800d54:	8b 45 08             	mov    0x8(%ebp),%eax
  800d57:	8a 00                	mov    (%eax),%al
  800d59:	0f be c0             	movsbl %al,%eax
  800d5c:	83 e8 30             	sub    $0x30,%eax
  800d5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d62:	eb 42                	jmp    800da6 <strtol+0x104>
		else if (*s >= 'a' && *s <= 'z')
  800d64:	8b 45 08             	mov    0x8(%ebp),%eax
  800d67:	8a 00                	mov    (%eax),%al
  800d69:	3c 60                	cmp    $0x60,%al
  800d6b:	7e 19                	jle    800d86 <strtol+0xe4>
  800d6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d70:	8a 00                	mov    (%eax),%al
  800d72:	3c 7a                	cmp    $0x7a,%al
  800d74:	7f 10                	jg     800d86 <strtol+0xe4>
			dig = *s - 'a' + 10;
  800d76:	8b 45 08             	mov    0x8(%ebp),%eax
  800d79:	8a 00                	mov    (%eax),%al
  800d7b:	0f be c0             	movsbl %al,%eax
  800d7e:	83 e8 57             	sub    $0x57,%eax
  800d81:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d84:	eb 20                	jmp    800da6 <strtol+0x104>
		else if (*s >= 'A' && *s <= 'Z')
  800d86:	8b 45 08             	mov    0x8(%ebp),%eax
  800d89:	8a 00                	mov    (%eax),%al
  800d8b:	3c 40                	cmp    $0x40,%al
  800d8d:	7e 39                	jle    800dc8 <strtol+0x126>
  800d8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d92:	8a 00                	mov    (%eax),%al
  800d94:	3c 5a                	cmp    $0x5a,%al
  800d96:	7f 30                	jg     800dc8 <strtol+0x126>
			dig = *s - 'A' + 10;
  800d98:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9b:	8a 00                	mov    (%eax),%al
  800d9d:	0f be c0             	movsbl %al,%eax
  800da0:	83 e8 37             	sub    $0x37,%eax
  800da3:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800da9:	3b 45 10             	cmp    0x10(%ebp),%eax
  800dac:	7d 19                	jge    800dc7 <strtol+0x125>
			break;
		s++, val = (val * base) + dig;
  800dae:	ff 45 08             	incl   0x8(%ebp)
  800db1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800db4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800db8:	89 c2                	mov    %eax,%edx
  800dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dbd:	01 d0                	add    %edx,%eax
  800dbf:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800dc2:	e9 7b ff ff ff       	jmp    800d42 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
			break;
  800dc7:	90                   	nop
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800dc8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dcc:	74 08                	je     800dd6 <strtol+0x134>
		*endptr = (char *) s;
  800dce:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd4:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800dd6:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800dda:	74 07                	je     800de3 <strtol+0x141>
  800ddc:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ddf:	f7 d8                	neg    %eax
  800de1:	eb 03                	jmp    800de6 <strtol+0x144>
  800de3:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800de6:	c9                   	leave  
  800de7:	c3                   	ret    

00800de8 <ltostr>:

void
ltostr(long value, char *str)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	83 ec 20             	sub    $0x20,%esp
	int neg = 0;
  800dee:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	int s = 0 ;
  800df5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// plus/minus sign
	if (value < 0)
  800dfc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800e00:	79 13                	jns    800e15 <ltostr+0x2d>
	{
		neg = 1;
  800e02:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
		str[0] = '-';
  800e09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e0c:	c6 00 2d             	movb   $0x2d,(%eax)
		value = value * -1 ;
  800e0f:	f7 5d 08             	negl   0x8(%ebp)
		s++ ;
  800e12:	ff 45 f8             	incl   -0x8(%ebp)
	}
	do
	{
		int mod = value % 10 ;
  800e15:	8b 45 08             	mov    0x8(%ebp),%eax
  800e18:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800e1d:	99                   	cltd   
  800e1e:	f7 f9                	idiv   %ecx
  800e20:	89 55 ec             	mov    %edx,-0x14(%ebp)
		str[s++] = mod + '0' ;
  800e23:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e26:	8d 50 01             	lea    0x1(%eax),%edx
  800e29:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800e2c:	89 c2                	mov    %eax,%edx
  800e2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e31:	01 d0                	add    %edx,%eax
  800e33:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800e36:	83 c2 30             	add    $0x30,%edx
  800e39:	88 10                	mov    %dl,(%eax)
		value = value / 10 ;
  800e3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3e:	b8 67 66 66 66       	mov    $0x66666667,%eax
  800e43:	f7 e9                	imul   %ecx
  800e45:	c1 fa 02             	sar    $0x2,%edx
  800e48:	89 c8                	mov    %ecx,%eax
  800e4a:	c1 f8 1f             	sar    $0x1f,%eax
  800e4d:	29 c2                	sub    %eax,%edx
  800e4f:	89 d0                	mov    %edx,%eax
  800e51:	89 45 08             	mov    %eax,0x8(%ebp)
	/*2023 FIX el7 :)*/
	//} while (value % 10 != 0);
	} while (value != 0);
  800e54:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800e58:	75 bb                	jne    800e15 <ltostr+0x2d>

	//reverse the string
	int start = 0 ;
  800e5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int end = s-1 ;
  800e61:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e64:	48                   	dec    %eax
  800e65:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (neg)
  800e68:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e6c:	74 3d                	je     800eab <ltostr+0xc3>
		start = 1 ;
  800e6e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	while(start<end)
  800e75:	eb 34                	jmp    800eab <ltostr+0xc3>
	{
		char tmp = str[start] ;
  800e77:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7d:	01 d0                	add    %edx,%eax
  800e7f:	8a 00                	mov    (%eax),%al
  800e81:	88 45 eb             	mov    %al,-0x15(%ebp)
		str[start] = str[end] ;
  800e84:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8a:	01 c2                	add    %eax,%edx
  800e8c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e92:	01 c8                	add    %ecx,%eax
  800e94:	8a 00                	mov    (%eax),%al
  800e96:	88 02                	mov    %al,(%edx)
		str[end] = tmp;
  800e98:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9e:	01 c2                	add    %eax,%edx
  800ea0:	8a 45 eb             	mov    -0x15(%ebp),%al
  800ea3:	88 02                	mov    %al,(%edx)
		start++ ;
  800ea5:	ff 45 f4             	incl   -0xc(%ebp)
		end-- ;
  800ea8:	ff 4d f0             	decl   -0x10(%ebp)
	//reverse the string
	int start = 0 ;
	int end = s-1 ;
	if (neg)
		start = 1 ;
	while(start<end)
  800eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eae:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800eb1:	7c c4                	jl     800e77 <ltostr+0x8f>
		str[end] = tmp;
		start++ ;
		end-- ;
	}

	str[s] = 0 ;
  800eb3:	8b 55 f8             	mov    -0x8(%ebp),%edx
  800eb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eb9:	01 d0                	add    %edx,%eax
  800ebb:	c6 00 00             	movb   $0x0,(%eax)
	// we don't properly detect overflow!

}
  800ebe:	90                   	nop
  800ebf:	c9                   	leave  
  800ec0:	c3                   	ret    

00800ec1 <strcconcat>:

void
strcconcat(const char *str1, const char *str2, char *final)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	83 ec 10             	sub    $0x10,%esp
	int len1 = strlen(str1);
  800ec7:	ff 75 08             	pushl  0x8(%ebp)
  800eca:	e8 73 fa ff ff       	call   800942 <strlen>
  800ecf:	83 c4 04             	add    $0x4,%esp
  800ed2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int len2 = strlen(str2);
  800ed5:	ff 75 0c             	pushl  0xc(%ebp)
  800ed8:	e8 65 fa ff ff       	call   800942 <strlen>
  800edd:	83 c4 04             	add    $0x4,%esp
  800ee0:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int s = 0 ;
  800ee3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for (s=0 ; s < len1 ; s++)
  800eea:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800ef1:	eb 17                	jmp    800f0a <strcconcat+0x49>
		final[s] = str1[s] ;
  800ef3:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800ef6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ef9:	01 c2                	add    %eax,%edx
  800efb:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  800efe:	8b 45 08             	mov    0x8(%ebp),%eax
  800f01:	01 c8                	add    %ecx,%eax
  800f03:	8a 00                	mov    (%eax),%al
  800f05:	88 02                	mov    %al,(%edx)
strcconcat(const char *str1, const char *str2, char *final)
{
	int len1 = strlen(str1);
	int len2 = strlen(str2);
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
  800f07:	ff 45 fc             	incl   -0x4(%ebp)
  800f0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f0d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  800f10:	7c e1                	jl     800ef3 <strcconcat+0x32>
		final[s] = str1[s] ;

	int i = 0 ;
  800f12:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
	for (i=0 ; i < len2 ; i++)
  800f19:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  800f20:	eb 1f                	jmp    800f41 <strcconcat+0x80>
		final[s++] = str2[i] ;
  800f22:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f25:	8d 50 01             	lea    0x1(%eax),%edx
  800f28:	89 55 fc             	mov    %edx,-0x4(%ebp)
  800f2b:	89 c2                	mov    %eax,%edx
  800f2d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f30:	01 c2                	add    %eax,%edx
  800f32:	8b 4d f8             	mov    -0x8(%ebp),%ecx
  800f35:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f38:	01 c8                	add    %ecx,%eax
  800f3a:	8a 00                	mov    (%eax),%al
  800f3c:	88 02                	mov    %al,(%edx)
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
		final[s] = str1[s] ;

	int i = 0 ;
	for (i=0 ; i < len2 ; i++)
  800f3e:	ff 45 f8             	incl   -0x8(%ebp)
  800f41:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f44:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800f47:	7c d9                	jl     800f22 <strcconcat+0x61>
		final[s++] = str2[i] ;

	final[s] = 0;
  800f49:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800f4c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f4f:	01 d0                	add    %edx,%eax
  800f51:	c6 00 00             	movb   $0x0,(%eax)
}
  800f54:	90                   	nop
  800f55:	c9                   	leave  
  800f56:	c3                   	ret    

00800f57 <strsplit>:
int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  800f5a:	8b 45 14             	mov    0x14(%ebp),%eax
  800f5d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	(argv)[*argc] = 0;
  800f63:	8b 45 14             	mov    0x14(%ebp),%eax
  800f66:	8b 00                	mov    (%eax),%eax
  800f68:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f6f:	8b 45 10             	mov    0x10(%ebp),%eax
  800f72:	01 d0                	add    %edx,%eax
  800f74:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800f7a:	eb 0c                	jmp    800f88 <strsplit+0x31>
			*string++ = 0;
  800f7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7f:	8d 50 01             	lea    0x1(%eax),%edx
  800f82:	89 55 08             	mov    %edx,0x8(%ebp)
  800f85:	c6 00 00             	movb   $0x0,(%eax)
	*argc = 0;
	(argv)[*argc] = 0;
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800f88:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8b:	8a 00                	mov    (%eax),%al
  800f8d:	84 c0                	test   %al,%al
  800f8f:	74 18                	je     800fa9 <strsplit+0x52>
  800f91:	8b 45 08             	mov    0x8(%ebp),%eax
  800f94:	8a 00                	mov    (%eax),%al
  800f96:	0f be c0             	movsbl %al,%eax
  800f99:	50                   	push   %eax
  800f9a:	ff 75 0c             	pushl  0xc(%ebp)
  800f9d:	e8 32 fb ff ff       	call   800ad4 <strchr>
  800fa2:	83 c4 08             	add    $0x8,%esp
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	75 d3                	jne    800f7c <strsplit+0x25>
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
  800fa9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fac:	8a 00                	mov    (%eax),%al
  800fae:	84 c0                	test   %al,%al
  800fb0:	74 5a                	je     80100c <strsplit+0xb5>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1)
  800fb2:	8b 45 14             	mov    0x14(%ebp),%eax
  800fb5:	8b 00                	mov    (%eax),%eax
  800fb7:	83 f8 0f             	cmp    $0xf,%eax
  800fba:	75 07                	jne    800fc3 <strsplit+0x6c>
		{
			return 0;
  800fbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc1:	eb 66                	jmp    801029 <strsplit+0xd2>
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  800fc3:	8b 45 14             	mov    0x14(%ebp),%eax
  800fc6:	8b 00                	mov    (%eax),%eax
  800fc8:	8d 48 01             	lea    0x1(%eax),%ecx
  800fcb:	8b 55 14             	mov    0x14(%ebp),%edx
  800fce:	89 0a                	mov    %ecx,(%edx)
  800fd0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800fd7:	8b 45 10             	mov    0x10(%ebp),%eax
  800fda:	01 c2                	add    %eax,%edx
  800fdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdf:	89 02                	mov    %eax,(%edx)
		while (*string && !strchr(SPLIT_CHARS, *string))
  800fe1:	eb 03                	jmp    800fe6 <strsplit+0x8f>
			string++;
  800fe3:	ff 45 08             	incl   0x8(%ebp)
			return 0;
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
  800fe6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe9:	8a 00                	mov    (%eax),%al
  800feb:	84 c0                	test   %al,%al
  800fed:	74 8b                	je     800f7a <strsplit+0x23>
  800fef:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff2:	8a 00                	mov    (%eax),%al
  800ff4:	0f be c0             	movsbl %al,%eax
  800ff7:	50                   	push   %eax
  800ff8:	ff 75 0c             	pushl  0xc(%ebp)
  800ffb:	e8 d4 fa ff ff       	call   800ad4 <strchr>
  801000:	83 c4 08             	add    $0x8,%esp
  801003:	85 c0                	test   %eax,%eax
  801005:	74 dc                	je     800fe3 <strsplit+0x8c>
			string++;
	}
  801007:	e9 6e ff ff ff       	jmp    800f7a <strsplit+0x23>
		while (*string && strchr(SPLIT_CHARS, *string))
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
			break;
  80100c:	90                   	nop
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
			string++;
	}
	(argv)[*argc] = 0;
  80100d:	8b 45 14             	mov    0x14(%ebp),%eax
  801010:	8b 00                	mov    (%eax),%eax
  801012:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801019:	8b 45 10             	mov    0x10(%ebp),%eax
  80101c:	01 d0                	add    %edx,%eax
  80101e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return 1 ;
  801024:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801029:	c9                   	leave  
  80102a:	c3                   	ret    

0080102b <str2lower>:


char* str2lower(char *dst, const char *src)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	83 ec 08             	sub    $0x8,%esp
	//[PROJECT]
	panic("str2lower is not implemented yet!");
  801031:	83 ec 04             	sub    $0x4,%esp
  801034:	68 28 20 80 00       	push   $0x802028
  801039:	68 3f 01 00 00       	push   $0x13f
  80103e:	68 4a 20 80 00       	push   $0x80204a
  801043:	e8 e2 06 00 00       	call   80172a <_panic>

00801048 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline uint32
syscall(int num, uint32 a1, uint32 a2, uint32 a3, uint32 a4, uint32 a5)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
  80104b:	57                   	push   %edi
  80104c:	56                   	push   %esi
  80104d:	53                   	push   %ebx
  80104e:	83 ec 10             	sub    $0x10,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801051:	8b 45 08             	mov    0x8(%ebp),%eax
  801054:	8b 55 0c             	mov    0xc(%ebp),%edx
  801057:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80105a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80105d:	8b 7d 18             	mov    0x18(%ebp),%edi
  801060:	8b 75 1c             	mov    0x1c(%ebp),%esi
  801063:	cd 30                	int    $0x30
  801065:	89 45 f0             	mov    %eax,-0x10(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	return ret;
  801068:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  80106b:	83 c4 10             	add    $0x10,%esp
  80106e:	5b                   	pop    %ebx
  80106f:	5e                   	pop    %esi
  801070:	5f                   	pop    %edi
  801071:	5d                   	pop    %ebp
  801072:	c3                   	ret    

00801073 <sys_cputs>:

void
sys_cputs(const char *s, uint32 len, uint8 printProgName)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	83 ec 04             	sub    $0x4,%esp
  801079:	8b 45 10             	mov    0x10(%ebp),%eax
  80107c:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputs, (uint32) s, len, (uint32)printProgName, 0, 0);
  80107f:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  801083:	8b 45 08             	mov    0x8(%ebp),%eax
  801086:	6a 00                	push   $0x0
  801088:	6a 00                	push   $0x0
  80108a:	52                   	push   %edx
  80108b:	ff 75 0c             	pushl  0xc(%ebp)
  80108e:	50                   	push   %eax
  80108f:	6a 00                	push   $0x0
  801091:	e8 b2 ff ff ff       	call   801048 <syscall>
  801096:	83 c4 18             	add    $0x18,%esp
}
  801099:	90                   	nop
  80109a:	c9                   	leave  
  80109b:	c3                   	ret    

0080109c <sys_cgetc>:

int
sys_cgetc(void)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
  80109f:	6a 00                	push   $0x0
  8010a1:	6a 00                	push   $0x0
  8010a3:	6a 00                	push   $0x0
  8010a5:	6a 00                	push   $0x0
  8010a7:	6a 00                	push   $0x0
  8010a9:	6a 02                	push   $0x2
  8010ab:	e8 98 ff ff ff       	call   801048 <syscall>
  8010b0:	83 c4 18             	add    $0x18,%esp
}
  8010b3:	c9                   	leave  
  8010b4:	c3                   	ret    

008010b5 <sys_lock_cons>:

void sys_lock_cons(void)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
	syscall(SYS_lock_cons, 0, 0, 0, 0, 0);
  8010b8:	6a 00                	push   $0x0
  8010ba:	6a 00                	push   $0x0
  8010bc:	6a 00                	push   $0x0
  8010be:	6a 00                	push   $0x0
  8010c0:	6a 00                	push   $0x0
  8010c2:	6a 03                	push   $0x3
  8010c4:	e8 7f ff ff ff       	call   801048 <syscall>
  8010c9:	83 c4 18             	add    $0x18,%esp
}
  8010cc:	90                   	nop
  8010cd:	c9                   	leave  
  8010ce:	c3                   	ret    

008010cf <sys_unlock_cons>:
void sys_unlock_cons(void)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
	syscall(SYS_unlock_cons, 0, 0, 0, 0, 0);
  8010d2:	6a 00                	push   $0x0
  8010d4:	6a 00                	push   $0x0
  8010d6:	6a 00                	push   $0x0
  8010d8:	6a 00                	push   $0x0
  8010da:	6a 00                	push   $0x0
  8010dc:	6a 04                	push   $0x4
  8010de:	e8 65 ff ff ff       	call   801048 <syscall>
  8010e3:	83 c4 18             	add    $0x18,%esp
}
  8010e6:	90                   	nop
  8010e7:	c9                   	leave  
  8010e8:	c3                   	ret    

008010e9 <__sys_allocate_page>:

int __sys_allocate_page(void *va, int perm)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
  8010ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f2:	6a 00                	push   $0x0
  8010f4:	6a 00                	push   $0x0
  8010f6:	6a 00                	push   $0x0
  8010f8:	52                   	push   %edx
  8010f9:	50                   	push   %eax
  8010fa:	6a 08                	push   $0x8
  8010fc:	e8 47 ff ff ff       	call   801048 <syscall>
  801101:	83 c4 18             	add    $0x18,%esp
}
  801104:	c9                   	leave  
  801105:	c3                   	ret    

00801106 <__sys_map_frame>:

int __sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  801106:	55                   	push   %ebp
  801107:	89 e5                	mov    %esp,%ebp
  801109:	56                   	push   %esi
  80110a:	53                   	push   %ebx
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
  80110b:	8b 75 18             	mov    0x18(%ebp),%esi
  80110e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801111:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801114:	8b 55 0c             	mov    0xc(%ebp),%edx
  801117:	8b 45 08             	mov    0x8(%ebp),%eax
  80111a:	56                   	push   %esi
  80111b:	53                   	push   %ebx
  80111c:	51                   	push   %ecx
  80111d:	52                   	push   %edx
  80111e:	50                   	push   %eax
  80111f:	6a 09                	push   $0x9
  801121:	e8 22 ff ff ff       	call   801048 <syscall>
  801126:	83 c4 18             	add    $0x18,%esp
}
  801129:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80112c:	5b                   	pop    %ebx
  80112d:	5e                   	pop    %esi
  80112e:	5d                   	pop    %ebp
  80112f:	c3                   	ret    

00801130 <__sys_unmap_frame>:

int __sys_unmap_frame(int32 envid, void *va)
{
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
  801133:	8b 55 0c             	mov    0xc(%ebp),%edx
  801136:	8b 45 08             	mov    0x8(%ebp),%eax
  801139:	6a 00                	push   $0x0
  80113b:	6a 00                	push   $0x0
  80113d:	6a 00                	push   $0x0
  80113f:	52                   	push   %edx
  801140:	50                   	push   %eax
  801141:	6a 0a                	push   $0xa
  801143:	e8 00 ff ff ff       	call   801048 <syscall>
  801148:	83 c4 18             	add    $0x18,%esp
}
  80114b:	c9                   	leave  
  80114c:	c3                   	ret    

0080114d <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
  801150:	6a 00                	push   $0x0
  801152:	6a 00                	push   $0x0
  801154:	6a 00                	push   $0x0
  801156:	ff 75 0c             	pushl  0xc(%ebp)
  801159:	ff 75 08             	pushl  0x8(%ebp)
  80115c:	6a 0b                	push   $0xb
  80115e:	e8 e5 fe ff ff       	call   801048 <syscall>
  801163:	83 c4 18             	add    $0x18,%esp
}
  801166:	c9                   	leave  
  801167:	c3                   	ret    

00801168 <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
  80116b:	6a 00                	push   $0x0
  80116d:	6a 00                	push   $0x0
  80116f:	6a 00                	push   $0x0
  801171:	6a 00                	push   $0x0
  801173:	6a 00                	push   $0x0
  801175:	6a 0c                	push   $0xc
  801177:	e8 cc fe ff ff       	call   801048 <syscall>
  80117c:	83 c4 18             	add    $0x18,%esp
}
  80117f:	c9                   	leave  
  801180:	c3                   	ret    

00801181 <sys_calculate_modified_frames>:
uint32 sys_calculate_modified_frames()
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_modified_frames, 0, 0, 0, 0, 0);
  801184:	6a 00                	push   $0x0
  801186:	6a 00                	push   $0x0
  801188:	6a 00                	push   $0x0
  80118a:	6a 00                	push   $0x0
  80118c:	6a 00                	push   $0x0
  80118e:	6a 0d                	push   $0xd
  801190:	e8 b3 fe ff ff       	call   801048 <syscall>
  801195:	83 c4 18             	add    $0x18,%esp
}
  801198:	c9                   	leave  
  801199:	c3                   	ret    

0080119a <sys_calculate_notmod_frames>:

uint32 sys_calculate_notmod_frames()
{
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_notmod_frames, 0, 0, 0, 0, 0);
  80119d:	6a 00                	push   $0x0
  80119f:	6a 00                	push   $0x0
  8011a1:	6a 00                	push   $0x0
  8011a3:	6a 00                	push   $0x0
  8011a5:	6a 00                	push   $0x0
  8011a7:	6a 0e                	push   $0xe
  8011a9:	e8 9a fe ff ff       	call   801048 <syscall>
  8011ae:	83 c4 18             	add    $0x18,%esp
}
  8011b1:	c9                   	leave  
  8011b2:	c3                   	ret    

008011b3 <sys_pf_calculate_allocated_pages>:

int sys_pf_calculate_allocated_pages()
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_pf_calc_allocated_pages, 0,0,0,0,0);
  8011b6:	6a 00                	push   $0x0
  8011b8:	6a 00                	push   $0x0
  8011ba:	6a 00                	push   $0x0
  8011bc:	6a 00                	push   $0x0
  8011be:	6a 00                	push   $0x0
  8011c0:	6a 0f                	push   $0xf
  8011c2:	e8 81 fe ff ff       	call   801048 <syscall>
  8011c7:	83 c4 18             	add    $0x18,%esp
}
  8011ca:	c9                   	leave  
  8011cb:	c3                   	ret    

008011cc <sys_calculate_pages_tobe_removed_ready_exit>:

int sys_calculate_pages_tobe_removed_ready_exit(uint32 WS_or_MEMORY_flag)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calculate_pages_tobe_removed_ready_exit, WS_or_MEMORY_flag,0,0,0,0);
  8011cf:	6a 00                	push   $0x0
  8011d1:	6a 00                	push   $0x0
  8011d3:	6a 00                	push   $0x0
  8011d5:	6a 00                	push   $0x0
  8011d7:	ff 75 08             	pushl  0x8(%ebp)
  8011da:	6a 10                	push   $0x10
  8011dc:	e8 67 fe ff ff       	call   801048 <syscall>
  8011e1:	83 c4 18             	add    $0x18,%esp
}
  8011e4:	c9                   	leave  
  8011e5:	c3                   	ret    

008011e6 <sys_scarce_memory>:

void sys_scarce_memory()
{
  8011e6:	55                   	push   %ebp
  8011e7:	89 e5                	mov    %esp,%ebp
	syscall(SYS_scarce_memory,0,0,0,0,0);
  8011e9:	6a 00                	push   $0x0
  8011eb:	6a 00                	push   $0x0
  8011ed:	6a 00                	push   $0x0
  8011ef:	6a 00                	push   $0x0
  8011f1:	6a 00                	push   $0x0
  8011f3:	6a 11                	push   $0x11
  8011f5:	e8 4e fe ff ff       	call   801048 <syscall>
  8011fa:	83 c4 18             	add    $0x18,%esp
}
  8011fd:	90                   	nop
  8011fe:	c9                   	leave  
  8011ff:	c3                   	ret    

00801200 <sys_cputc>:

void
sys_cputc(const char c)
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	83 ec 04             	sub    $0x4,%esp
  801206:	8b 45 08             	mov    0x8(%ebp),%eax
  801209:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputc, (uint32) c, 0, 0, 0, 0);
  80120c:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  801210:	6a 00                	push   $0x0
  801212:	6a 00                	push   $0x0
  801214:	6a 00                	push   $0x0
  801216:	6a 00                	push   $0x0
  801218:	50                   	push   %eax
  801219:	6a 01                	push   $0x1
  80121b:	e8 28 fe ff ff       	call   801048 <syscall>
  801220:	83 c4 18             	add    $0x18,%esp
}
  801223:	90                   	nop
  801224:	c9                   	leave  
  801225:	c3                   	ret    

00801226 <sys_clear_ffl>:


//NEW'12: BONUS2 Testing
void
sys_clear_ffl()
{
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
	syscall(SYS_clearFFL,0, 0, 0, 0, 0);
  801229:	6a 00                	push   $0x0
  80122b:	6a 00                	push   $0x0
  80122d:	6a 00                	push   $0x0
  80122f:	6a 00                	push   $0x0
  801231:	6a 00                	push   $0x0
  801233:	6a 14                	push   $0x14
  801235:	e8 0e fe ff ff       	call   801048 <syscall>
  80123a:	83 c4 18             	add    $0x18,%esp
}
  80123d:	90                   	nop
  80123e:	c9                   	leave  
  80123f:	c3                   	ret    

00801240 <sys_createSharedObject>:

int sys_createSharedObject(char* shareName, uint32 size, uint8 isWritable, void* virtual_address)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	83 ec 04             	sub    $0x4,%esp
  801246:	8b 45 10             	mov    0x10(%ebp),%eax
  801249:	88 45 fc             	mov    %al,-0x4(%ebp)
	return syscall(SYS_create_shared_object,(uint32)shareName, (uint32)size, isWritable, (uint32)virtual_address,  0);
  80124c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80124f:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  801253:	8b 45 08             	mov    0x8(%ebp),%eax
  801256:	6a 00                	push   $0x0
  801258:	51                   	push   %ecx
  801259:	52                   	push   %edx
  80125a:	ff 75 0c             	pushl  0xc(%ebp)
  80125d:	50                   	push   %eax
  80125e:	6a 15                	push   $0x15
  801260:	e8 e3 fd ff ff       	call   801048 <syscall>
  801265:	83 c4 18             	add    $0x18,%esp
}
  801268:	c9                   	leave  
  801269:	c3                   	ret    

0080126a <sys_getSizeOfSharedObject>:

//2017:
int sys_getSizeOfSharedObject(int32 ownerID, char* shareName)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_size_of_shared_object,(uint32) ownerID, (uint32)shareName, 0, 0, 0);
  80126d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801270:	8b 45 08             	mov    0x8(%ebp),%eax
  801273:	6a 00                	push   $0x0
  801275:	6a 00                	push   $0x0
  801277:	6a 00                	push   $0x0
  801279:	52                   	push   %edx
  80127a:	50                   	push   %eax
  80127b:	6a 16                	push   $0x16
  80127d:	e8 c6 fd ff ff       	call   801048 <syscall>
  801282:	83 c4 18             	add    $0x18,%esp
}
  801285:	c9                   	leave  
  801286:	c3                   	ret    

00801287 <sys_getSharedObject>:
//==========

int sys_getSharedObject(int32 ownerID, char* shareName, void* virtual_address)
{
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_shared_object,(uint32) ownerID, (uint32)shareName, (uint32)virtual_address, 0, 0);
  80128a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80128d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801290:	8b 45 08             	mov    0x8(%ebp),%eax
  801293:	6a 00                	push   $0x0
  801295:	6a 00                	push   $0x0
  801297:	51                   	push   %ecx
  801298:	52                   	push   %edx
  801299:	50                   	push   %eax
  80129a:	6a 17                	push   $0x17
  80129c:	e8 a7 fd ff ff       	call   801048 <syscall>
  8012a1:	83 c4 18             	add    $0x18,%esp
}
  8012a4:	c9                   	leave  
  8012a5:	c3                   	ret    

008012a6 <sys_freeSharedObject>:

int sys_freeSharedObject(int32 sharedObjectID, void *startVA)
{
  8012a6:	55                   	push   %ebp
  8012a7:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_free_shared_object,(uint32) sharedObjectID, (uint32) startVA, 0, 0, 0);
  8012a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8012af:	6a 00                	push   $0x0
  8012b1:	6a 00                	push   $0x0
  8012b3:	6a 00                	push   $0x0
  8012b5:	52                   	push   %edx
  8012b6:	50                   	push   %eax
  8012b7:	6a 18                	push   $0x18
  8012b9:	e8 8a fd ff ff       	call   801048 <syscall>
  8012be:	83 c4 18             	add    $0x18,%esp
}
  8012c1:	c9                   	leave  
  8012c2:	c3                   	ret    

008012c3 <sys_create_env>:

int sys_create_env(char* programName, unsigned int page_WS_size,unsigned int LRU_second_list_size,unsigned int percent_WS_pages_to_remove)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_create_env,(uint32)programName, (uint32)page_WS_size,(uint32)LRU_second_list_size, (uint32)percent_WS_pages_to_remove, 0);
  8012c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c9:	6a 00                	push   $0x0
  8012cb:	ff 75 14             	pushl  0x14(%ebp)
  8012ce:	ff 75 10             	pushl  0x10(%ebp)
  8012d1:	ff 75 0c             	pushl  0xc(%ebp)
  8012d4:	50                   	push   %eax
  8012d5:	6a 19                	push   $0x19
  8012d7:	e8 6c fd ff ff       	call   801048 <syscall>
  8012dc:	83 c4 18             	add    $0x18,%esp
}
  8012df:	c9                   	leave  
  8012e0:	c3                   	ret    

008012e1 <sys_run_env>:

void sys_run_env(int32 envId)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
	syscall(SYS_run_env, (int32)envId, 0, 0, 0, 0);
  8012e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e7:	6a 00                	push   $0x0
  8012e9:	6a 00                	push   $0x0
  8012eb:	6a 00                	push   $0x0
  8012ed:	6a 00                	push   $0x0
  8012ef:	50                   	push   %eax
  8012f0:	6a 1a                	push   $0x1a
  8012f2:	e8 51 fd ff ff       	call   801048 <syscall>
  8012f7:	83 c4 18             	add    $0x18,%esp
}
  8012fa:	90                   	nop
  8012fb:	c9                   	leave  
  8012fc:	c3                   	ret    

008012fd <sys_destroy_env>:

int sys_destroy_env(int32  envid)
{
  8012fd:	55                   	push   %ebp
  8012fe:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_destroy_env, envid, 0, 0, 0, 0);
  801300:	8b 45 08             	mov    0x8(%ebp),%eax
  801303:	6a 00                	push   $0x0
  801305:	6a 00                	push   $0x0
  801307:	6a 00                	push   $0x0
  801309:	6a 00                	push   $0x0
  80130b:	50                   	push   %eax
  80130c:	6a 1b                	push   $0x1b
  80130e:	e8 35 fd ff ff       	call   801048 <syscall>
  801313:	83 c4 18             	add    $0x18,%esp
}
  801316:	c9                   	leave  
  801317:	c3                   	ret    

00801318 <sys_getenvid>:

int32 sys_getenvid(void)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
  80131b:	6a 00                	push   $0x0
  80131d:	6a 00                	push   $0x0
  80131f:	6a 00                	push   $0x0
  801321:	6a 00                	push   $0x0
  801323:	6a 00                	push   $0x0
  801325:	6a 05                	push   $0x5
  801327:	e8 1c fd ff ff       	call   801048 <syscall>
  80132c:	83 c4 18             	add    $0x18,%esp
}
  80132f:	c9                   	leave  
  801330:	c3                   	ret    

00801331 <sys_getenvindex>:

//2017
int32 sys_getenvindex(void)
{
  801331:	55                   	push   %ebp
  801332:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvindex, 0, 0, 0, 0, 0);
  801334:	6a 00                	push   $0x0
  801336:	6a 00                	push   $0x0
  801338:	6a 00                	push   $0x0
  80133a:	6a 00                	push   $0x0
  80133c:	6a 00                	push   $0x0
  80133e:	6a 06                	push   $0x6
  801340:	e8 03 fd ff ff       	call   801048 <syscall>
  801345:	83 c4 18             	add    $0x18,%esp
}
  801348:	c9                   	leave  
  801349:	c3                   	ret    

0080134a <sys_getparentenvid>:

int32 sys_getparentenvid(void)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getparentenvid, 0, 0, 0, 0, 0);
  80134d:	6a 00                	push   $0x0
  80134f:	6a 00                	push   $0x0
  801351:	6a 00                	push   $0x0
  801353:	6a 00                	push   $0x0
  801355:	6a 00                	push   $0x0
  801357:	6a 07                	push   $0x7
  801359:	e8 ea fc ff ff       	call   801048 <syscall>
  80135e:	83 c4 18             	add    $0x18,%esp
}
  801361:	c9                   	leave  
  801362:	c3                   	ret    

00801363 <sys_exit_env>:


void sys_exit_env(void)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
	syscall(SYS_exit_env, 0, 0, 0, 0, 0);
  801366:	6a 00                	push   $0x0
  801368:	6a 00                	push   $0x0
  80136a:	6a 00                	push   $0x0
  80136c:	6a 00                	push   $0x0
  80136e:	6a 00                	push   $0x0
  801370:	6a 1c                	push   $0x1c
  801372:	e8 d1 fc ff ff       	call   801048 <syscall>
  801377:	83 c4 18             	add    $0x18,%esp
}
  80137a:	90                   	nop
  80137b:	c9                   	leave  
  80137c:	c3                   	ret    

0080137d <sys_get_virtual_time>:


struct uint64 sys_get_virtual_time()
{
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	83 ec 10             	sub    $0x10,%esp
	struct uint64 result;
	syscall(SYS_get_virtual_time, (uint32)&(result.low), (uint32)&(result.hi), 0, 0, 0);
  801383:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801386:	8d 50 04             	lea    0x4(%eax),%edx
  801389:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80138c:	6a 00                	push   $0x0
  80138e:	6a 00                	push   $0x0
  801390:	6a 00                	push   $0x0
  801392:	52                   	push   %edx
  801393:	50                   	push   %eax
  801394:	6a 1d                	push   $0x1d
  801396:	e8 ad fc ff ff       	call   801048 <syscall>
  80139b:	83 c4 18             	add    $0x18,%esp
	return result;
  80139e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8013a4:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8013a7:	89 01                	mov    %eax,(%ecx)
  8013a9:	89 51 04             	mov    %edx,0x4(%ecx)
}
  8013ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8013af:	c9                   	leave  
  8013b0:	c2 04 00             	ret    $0x4

008013b3 <sys_move_user_mem>:

// 2014
void sys_move_user_mem(uint32 src_virtual_address, uint32 dst_virtual_address, uint32 size)
{
  8013b3:	55                   	push   %ebp
  8013b4:	89 e5                	mov    %esp,%ebp
	syscall(SYS_move_user_mem, src_virtual_address, dst_virtual_address, size, 0, 0);
  8013b6:	6a 00                	push   $0x0
  8013b8:	6a 00                	push   $0x0
  8013ba:	ff 75 10             	pushl  0x10(%ebp)
  8013bd:	ff 75 0c             	pushl  0xc(%ebp)
  8013c0:	ff 75 08             	pushl  0x8(%ebp)
  8013c3:	6a 13                	push   $0x13
  8013c5:	e8 7e fc ff ff       	call   801048 <syscall>
  8013ca:	83 c4 18             	add    $0x18,%esp
	return ;
  8013cd:	90                   	nop
}
  8013ce:	c9                   	leave  
  8013cf:	c3                   	ret    

008013d0 <sys_rcr2>:
uint32 sys_rcr2()
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_rcr2, 0, 0, 0, 0, 0);
  8013d3:	6a 00                	push   $0x0
  8013d5:	6a 00                	push   $0x0
  8013d7:	6a 00                	push   $0x0
  8013d9:	6a 00                	push   $0x0
  8013db:	6a 00                	push   $0x0
  8013dd:	6a 1e                	push   $0x1e
  8013df:	e8 64 fc ff ff       	call   801048 <syscall>
  8013e4:	83 c4 18             	add    $0x18,%esp
}
  8013e7:	c9                   	leave  
  8013e8:	c3                   	ret    

008013e9 <sys_bypassPageFault>:

void sys_bypassPageFault(uint8 instrLength)
{
  8013e9:	55                   	push   %ebp
  8013ea:	89 e5                	mov    %esp,%ebp
  8013ec:	83 ec 04             	sub    $0x4,%esp
  8013ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f2:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_bypassPageFault, instrLength, 0, 0, 0, 0);
  8013f5:	0f b6 45 fc          	movzbl -0x4(%ebp),%eax
  8013f9:	6a 00                	push   $0x0
  8013fb:	6a 00                	push   $0x0
  8013fd:	6a 00                	push   $0x0
  8013ff:	6a 00                	push   $0x0
  801401:	50                   	push   %eax
  801402:	6a 1f                	push   $0x1f
  801404:	e8 3f fc ff ff       	call   801048 <syscall>
  801409:	83 c4 18             	add    $0x18,%esp
	return ;
  80140c:	90                   	nop
}
  80140d:	c9                   	leave  
  80140e:	c3                   	ret    

0080140f <rsttst>:
void rsttst()
{
  80140f:	55                   	push   %ebp
  801410:	89 e5                	mov    %esp,%ebp
	syscall(SYS_rsttst, 0, 0, 0, 0, 0);
  801412:	6a 00                	push   $0x0
  801414:	6a 00                	push   $0x0
  801416:	6a 00                	push   $0x0
  801418:	6a 00                	push   $0x0
  80141a:	6a 00                	push   $0x0
  80141c:	6a 21                	push   $0x21
  80141e:	e8 25 fc ff ff       	call   801048 <syscall>
  801423:	83 c4 18             	add    $0x18,%esp
	return ;
  801426:	90                   	nop
}
  801427:	c9                   	leave  
  801428:	c3                   	ret    

00801429 <tst>:
void tst(uint32 n, uint32 v1, uint32 v2, char c, int inv)
{
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	83 ec 04             	sub    $0x4,%esp
  80142f:	8b 45 14             	mov    0x14(%ebp),%eax
  801432:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_testNum, n, v1, v2, c, inv);
  801435:	8b 55 18             	mov    0x18(%ebp),%edx
  801438:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  80143c:	52                   	push   %edx
  80143d:	50                   	push   %eax
  80143e:	ff 75 10             	pushl  0x10(%ebp)
  801441:	ff 75 0c             	pushl  0xc(%ebp)
  801444:	ff 75 08             	pushl  0x8(%ebp)
  801447:	6a 20                	push   $0x20
  801449:	e8 fa fb ff ff       	call   801048 <syscall>
  80144e:	83 c4 18             	add    $0x18,%esp
	return ;
  801451:	90                   	nop
}
  801452:	c9                   	leave  
  801453:	c3                   	ret    

00801454 <chktst>:
void chktst(uint32 n)
{
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
	syscall(SYS_chktst, n, 0, 0, 0, 0);
  801457:	6a 00                	push   $0x0
  801459:	6a 00                	push   $0x0
  80145b:	6a 00                	push   $0x0
  80145d:	6a 00                	push   $0x0
  80145f:	ff 75 08             	pushl  0x8(%ebp)
  801462:	6a 22                	push   $0x22
  801464:	e8 df fb ff ff       	call   801048 <syscall>
  801469:	83 c4 18             	add    $0x18,%esp
	return ;
  80146c:	90                   	nop
}
  80146d:	c9                   	leave  
  80146e:	c3                   	ret    

0080146f <inctst>:

void inctst()
{
  80146f:	55                   	push   %ebp
  801470:	89 e5                	mov    %esp,%ebp
	syscall(SYS_inctst, 0, 0, 0, 0, 0);
  801472:	6a 00                	push   $0x0
  801474:	6a 00                	push   $0x0
  801476:	6a 00                	push   $0x0
  801478:	6a 00                	push   $0x0
  80147a:	6a 00                	push   $0x0
  80147c:	6a 23                	push   $0x23
  80147e:	e8 c5 fb ff ff       	call   801048 <syscall>
  801483:	83 c4 18             	add    $0x18,%esp
	return ;
  801486:	90                   	nop
}
  801487:	c9                   	leave  
  801488:	c3                   	ret    

00801489 <gettst>:
uint32 gettst()
{
  801489:	55                   	push   %ebp
  80148a:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_gettst, 0, 0, 0, 0, 0);
  80148c:	6a 00                	push   $0x0
  80148e:	6a 00                	push   $0x0
  801490:	6a 00                	push   $0x0
  801492:	6a 00                	push   $0x0
  801494:	6a 00                	push   $0x0
  801496:	6a 24                	push   $0x24
  801498:	e8 ab fb ff ff       	call   801048 <syscall>
  80149d:	83 c4 18             	add    $0x18,%esp
}
  8014a0:	c9                   	leave  
  8014a1:	c3                   	ret    

008014a2 <sys_isUHeapPlacementStrategyFIRSTFIT>:


//2015
uint32 sys_isUHeapPlacementStrategyFIRSTFIT()
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  8014a8:	6a 00                	push   $0x0
  8014aa:	6a 00                	push   $0x0
  8014ac:	6a 00                	push   $0x0
  8014ae:	6a 00                	push   $0x0
  8014b0:	6a 00                	push   $0x0
  8014b2:	6a 25                	push   $0x25
  8014b4:	e8 8f fb ff ff       	call   801048 <syscall>
  8014b9:	83 c4 18             	add    $0x18,%esp
  8014bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_FIRSTFIT)
  8014bf:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
  8014c3:	75 07                	jne    8014cc <sys_isUHeapPlacementStrategyFIRSTFIT+0x2a>
		return 1;
  8014c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8014ca:	eb 05                	jmp    8014d1 <sys_isUHeapPlacementStrategyFIRSTFIT+0x2f>
	else
		return 0;
  8014cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d1:	c9                   	leave  
  8014d2:	c3                   	ret    

008014d3 <sys_isUHeapPlacementStrategyBESTFIT>:
uint32 sys_isUHeapPlacementStrategyBESTFIT()
{
  8014d3:	55                   	push   %ebp
  8014d4:	89 e5                	mov    %esp,%ebp
  8014d6:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  8014d9:	6a 00                	push   $0x0
  8014db:	6a 00                	push   $0x0
  8014dd:	6a 00                	push   $0x0
  8014df:	6a 00                	push   $0x0
  8014e1:	6a 00                	push   $0x0
  8014e3:	6a 25                	push   $0x25
  8014e5:	e8 5e fb ff ff       	call   801048 <syscall>
  8014ea:	83 c4 18             	add    $0x18,%esp
  8014ed:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_BESTFIT)
  8014f0:	83 7d fc 02          	cmpl   $0x2,-0x4(%ebp)
  8014f4:	75 07                	jne    8014fd <sys_isUHeapPlacementStrategyBESTFIT+0x2a>
		return 1;
  8014f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014fb:	eb 05                	jmp    801502 <sys_isUHeapPlacementStrategyBESTFIT+0x2f>
	else
		return 0;
  8014fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801502:	c9                   	leave  
  801503:	c3                   	ret    

00801504 <sys_isUHeapPlacementStrategyNEXTFIT>:
uint32 sys_isUHeapPlacementStrategyNEXTFIT()
{
  801504:	55                   	push   %ebp
  801505:	89 e5                	mov    %esp,%ebp
  801507:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  80150a:	6a 00                	push   $0x0
  80150c:	6a 00                	push   $0x0
  80150e:	6a 00                	push   $0x0
  801510:	6a 00                	push   $0x0
  801512:	6a 00                	push   $0x0
  801514:	6a 25                	push   $0x25
  801516:	e8 2d fb ff ff       	call   801048 <syscall>
  80151b:	83 c4 18             	add    $0x18,%esp
  80151e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_NEXTFIT)
  801521:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
  801525:	75 07                	jne    80152e <sys_isUHeapPlacementStrategyNEXTFIT+0x2a>
		return 1;
  801527:	b8 01 00 00 00       	mov    $0x1,%eax
  80152c:	eb 05                	jmp    801533 <sys_isUHeapPlacementStrategyNEXTFIT+0x2f>
	else
		return 0;
  80152e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801533:	c9                   	leave  
  801534:	c3                   	ret    

00801535 <sys_isUHeapPlacementStrategyWORSTFIT>:
uint32 sys_isUHeapPlacementStrategyWORSTFIT()
{
  801535:	55                   	push   %ebp
  801536:	89 e5                	mov    %esp,%ebp
  801538:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  80153b:	6a 00                	push   $0x0
  80153d:	6a 00                	push   $0x0
  80153f:	6a 00                	push   $0x0
  801541:	6a 00                	push   $0x0
  801543:	6a 00                	push   $0x0
  801545:	6a 25                	push   $0x25
  801547:	e8 fc fa ff ff       	call   801048 <syscall>
  80154c:	83 c4 18             	add    $0x18,%esp
  80154f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_WORSTFIT)
  801552:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
  801556:	75 07                	jne    80155f <sys_isUHeapPlacementStrategyWORSTFIT+0x2a>
		return 1;
  801558:	b8 01 00 00 00       	mov    $0x1,%eax
  80155d:	eb 05                	jmp    801564 <sys_isUHeapPlacementStrategyWORSTFIT+0x2f>
	else
		return 0;
  80155f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801564:	c9                   	leave  
  801565:	c3                   	ret    

00801566 <sys_set_uheap_strategy>:

void sys_set_uheap_strategy(uint32 heapStrategy)
{
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
	syscall(SYS_set_heap_strategy, heapStrategy, 0, 0, 0, 0);
  801569:	6a 00                	push   $0x0
  80156b:	6a 00                	push   $0x0
  80156d:	6a 00                	push   $0x0
  80156f:	6a 00                	push   $0x0
  801571:	ff 75 08             	pushl  0x8(%ebp)
  801574:	6a 26                	push   $0x26
  801576:	e8 cd fa ff ff       	call   801048 <syscall>
  80157b:	83 c4 18             	add    $0x18,%esp
	return ;
  80157e:	90                   	nop
}
  80157f:	c9                   	leave  
  801580:	c3                   	ret    

00801581 <sys_check_LRU_lists>:

//2020
int sys_check_LRU_lists(uint32* active_list_content, uint32* second_list_content, int actual_active_list_size, int actual_second_list_size)
{
  801581:	55                   	push   %ebp
  801582:	89 e5                	mov    %esp,%ebp
  801584:	53                   	push   %ebx
	return syscall(SYS_check_LRU_lists, (uint32)active_list_content, (uint32)second_list_content, (uint32)actual_active_list_size, (uint32)actual_second_list_size, 0);
  801585:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801588:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80158b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80158e:	8b 45 08             	mov    0x8(%ebp),%eax
  801591:	6a 00                	push   $0x0
  801593:	53                   	push   %ebx
  801594:	51                   	push   %ecx
  801595:	52                   	push   %edx
  801596:	50                   	push   %eax
  801597:	6a 27                	push   $0x27
  801599:	e8 aa fa ff ff       	call   801048 <syscall>
  80159e:	83 c4 18             	add    $0x18,%esp
}
  8015a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a4:	c9                   	leave  
  8015a5:	c3                   	ret    

008015a6 <sys_check_LRU_lists_free>:

int sys_check_LRU_lists_free(uint32* list_content, int list_size)
{
  8015a6:	55                   	push   %ebp
  8015a7:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_LRU_lists_free, (uint32)list_content, (uint32)list_size , 0, 0, 0);
  8015a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8015af:	6a 00                	push   $0x0
  8015b1:	6a 00                	push   $0x0
  8015b3:	6a 00                	push   $0x0
  8015b5:	52                   	push   %edx
  8015b6:	50                   	push   %eax
  8015b7:	6a 28                	push   $0x28
  8015b9:	e8 8a fa ff ff       	call   801048 <syscall>
  8015be:	83 c4 18             	add    $0x18,%esp
}
  8015c1:	c9                   	leave  
  8015c2:	c3                   	ret    

008015c3 <sys_check_WS_list>:

int sys_check_WS_list(uint32* WS_list_content, int actual_WS_list_size, uint32 last_WS_element_content, bool chk_in_order)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_WS_list, (uint32)WS_list_content, (uint32)actual_WS_list_size , last_WS_element_content, (uint32)chk_in_order, 0);
  8015c6:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cf:	6a 00                	push   $0x0
  8015d1:	51                   	push   %ecx
  8015d2:	ff 75 10             	pushl  0x10(%ebp)
  8015d5:	52                   	push   %edx
  8015d6:	50                   	push   %eax
  8015d7:	6a 29                	push   $0x29
  8015d9:	e8 6a fa ff ff       	call   801048 <syscall>
  8015de:	83 c4 18             	add    $0x18,%esp
}
  8015e1:	c9                   	leave  
  8015e2:	c3                   	ret    

008015e3 <sys_allocate_chunk>:
void sys_allocate_chunk(uint32 virtual_address, uint32 size, uint32 perms)
{
  8015e3:	55                   	push   %ebp
  8015e4:	89 e5                	mov    %esp,%ebp
	syscall(SYS_allocate_chunk_in_mem, virtual_address, size, perms, 0, 0);
  8015e6:	6a 00                	push   $0x0
  8015e8:	6a 00                	push   $0x0
  8015ea:	ff 75 10             	pushl  0x10(%ebp)
  8015ed:	ff 75 0c             	pushl  0xc(%ebp)
  8015f0:	ff 75 08             	pushl  0x8(%ebp)
  8015f3:	6a 12                	push   $0x12
  8015f5:	e8 4e fa ff ff       	call   801048 <syscall>
  8015fa:	83 c4 18             	add    $0x18,%esp
	return ;
  8015fd:	90                   	nop
}
  8015fe:	c9                   	leave  
  8015ff:	c3                   	ret    

00801600 <sys_utilities>:
void sys_utilities(char* utilityName, int value)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
	syscall(SYS_utilities, (uint32)utilityName, value, 0, 0, 0);
  801603:	8b 55 0c             	mov    0xc(%ebp),%edx
  801606:	8b 45 08             	mov    0x8(%ebp),%eax
  801609:	6a 00                	push   $0x0
  80160b:	6a 00                	push   $0x0
  80160d:	6a 00                	push   $0x0
  80160f:	52                   	push   %edx
  801610:	50                   	push   %eax
  801611:	6a 2a                	push   $0x2a
  801613:	e8 30 fa ff ff       	call   801048 <syscall>
  801618:	83 c4 18             	add    $0x18,%esp
	return;
  80161b:	90                   	nop
}
  80161c:	c9                   	leave  
  80161d:	c3                   	ret    

0080161e <sys_sbrk>:


//TODO: [PROJECT'24.MS1 - #02] [2] SYSTEM CALLS - Implement these system calls
void* sys_sbrk(int increment)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
	syscall( SYS_sbrk ,increment,0,0,0,0)  ;
  801621:	8b 45 08             	mov    0x8(%ebp),%eax
  801624:	6a 00                	push   $0x0
  801626:	6a 00                	push   $0x0
  801628:	6a 00                	push   $0x0
  80162a:	6a 00                	push   $0x0
  80162c:	50                   	push   %eax
  80162d:	6a 2b                	push   $0x2b
  80162f:	e8 14 fa ff ff       	call   801048 <syscall>
  801634:	83 c4 18             	add    $0x18,%esp

	return (void*)-1 ;
  801637:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

}
  80163c:	c9                   	leave  
  80163d:	c3                   	ret    

0080163e <sys_free_user_mem>:
void sys_free_user_mem(uint32 virtual_address, uint32 size)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
	syscall(SYS_free_user_mem,virtual_address,size,0,0,0);
  801641:	6a 00                	push   $0x0
  801643:	6a 00                	push   $0x0
  801645:	6a 00                	push   $0x0
  801647:	ff 75 0c             	pushl  0xc(%ebp)
  80164a:	ff 75 08             	pushl  0x8(%ebp)
  80164d:	6a 2c                	push   $0x2c
  80164f:	e8 f4 f9 ff ff       	call   801048 <syscall>
  801654:	83 c4 18             	add    $0x18,%esp
	return;
  801657:	90                   	nop
}
  801658:	c9                   	leave  
  801659:	c3                   	ret    

0080165a <sys_allocate_user_mem>:

void sys_allocate_user_mem(uint32 virtual_address, uint32 size)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
	syscall(SYS_allocate_user_mem,virtual_address,size,0,0,0);
  80165d:	6a 00                	push   $0x0
  80165f:	6a 00                	push   $0x0
  801661:	6a 00                	push   $0x0
  801663:	ff 75 0c             	pushl  0xc(%ebp)
  801666:	ff 75 08             	pushl  0x8(%ebp)
  801669:	6a 2d                	push   $0x2d
  80166b:	e8 d8 f9 ff ff       	call   801048 <syscall>
  801670:	83 c4 18             	add    $0x18,%esp
	return;
  801673:	90                   	nop
}
  801674:	c9                   	leave  
  801675:	c3                   	ret    

00801676 <env_sleep>:
#include <inc/lib.h>
#include <inc/timerreg.h>

void
env_sleep(uint32 approxMilliSeconds)
{
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	83 ec 28             	sub    $0x28,%esp
//	cprintf("%s go to sleep...\n", myEnv->prog_name);
	uint32 time_in_cycles=approxMilliSeconds*CYCLES_PER_MILLISEC;
  80167c:	8b 55 08             	mov    0x8(%ebp),%edx
  80167f:	89 d0                	mov    %edx,%eax
  801681:	c1 e0 02             	shl    $0x2,%eax
  801684:	01 d0                	add    %edx,%eax
  801686:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80168d:	01 d0                	add    %edx,%eax
  80168f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801696:	01 d0                	add    %edx,%eax
  801698:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80169f:	01 d0                	add    %edx,%eax
  8016a1:	c1 e0 04             	shl    $0x4,%eax
  8016a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
	uint32 cycles_counter =0;
  8016a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	struct uint64 baseTime = sys_get_virtual_time() ;
  8016ae:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8016b1:	83 ec 0c             	sub    $0xc,%esp
  8016b4:	50                   	push   %eax
  8016b5:	e8 c3 fc ff ff       	call   80137d <sys_get_virtual_time>
  8016ba:	83 c4 0c             	add    $0xc,%esp
	while(cycles_counter<time_in_cycles)
  8016bd:	eb 41                	jmp    801700 <env_sleep+0x8a>
	{
		struct uint64 currentTime = sys_get_virtual_time() ;
  8016bf:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8016c2:	83 ec 0c             	sub    $0xc,%esp
  8016c5:	50                   	push   %eax
  8016c6:	e8 b2 fc ff ff       	call   80137d <sys_get_virtual_time>
  8016cb:	83 c4 0c             	add    $0xc,%esp

		// update the cycles_count
		#define M32 0xffffffff
		// subtract basetime from current time
		struct uint64 res;
		res.low = (currentTime.low - baseTime.low) & M32;
  8016ce:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8016d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8016d4:	29 c2                	sub    %eax,%edx
  8016d6:	89 d0                	mov    %edx,%eax
  8016d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
		res.hi = (currentTime.hi - baseTime.hi - (res.low > currentTime.low)) & M32;
  8016db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016de:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016e1:	89 d1                	mov    %edx,%ecx
  8016e3:	29 c1                	sub    %eax,%ecx
  8016e5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8016e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016eb:	39 c2                	cmp    %eax,%edx
  8016ed:	0f 97 c0             	seta   %al
  8016f0:	0f b6 c0             	movzbl %al,%eax
  8016f3:	29 c1                	sub    %eax,%ecx
  8016f5:	89 c8                	mov    %ecx,%eax
  8016f7:	89 45 dc             	mov    %eax,-0x24(%ebp)

		//update cycles_count with result
		cycles_counter = res.low;
  8016fa:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8016fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
//	cprintf("%s go to sleep...\n", myEnv->prog_name);
	uint32 time_in_cycles=approxMilliSeconds*CYCLES_PER_MILLISEC;
	uint32 cycles_counter =0;

	struct uint64 baseTime = sys_get_virtual_time() ;
	while(cycles_counter<time_in_cycles)
  801700:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801703:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  801706:	72 b7                	jb     8016bf <env_sleep+0x49>
//				,cycles_counter
//				);
	}
	//cprintf("%s [%d] wake up now!\n", myEnv->prog_name, myEnv->env_id);

}
  801708:	90                   	nop
  801709:	c9                   	leave  
  80170a:	c3                   	ret    

0080170b <busy_wait>:

//2017
uint32 busy_wait(uint32 loopMax)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	83 ec 10             	sub    $0x10,%esp
	uint32 i = 0 ;
  801711:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	while (i < loopMax) i++;
  801718:	eb 03                	jmp    80171d <busy_wait+0x12>
  80171a:	ff 45 fc             	incl   -0x4(%ebp)
  80171d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801720:	3b 45 08             	cmp    0x8(%ebp),%eax
  801723:	72 f5                	jb     80171a <busy_wait+0xf>
	return i;
  801725:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  801728:	c9                   	leave  
  801729:	c3                   	ret    

0080172a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes FOS to enter the FOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  80172a:	55                   	push   %ebp
  80172b:	89 e5                	mov    %esp,%ebp
  80172d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	va_start(ap, fmt);
  801730:	8d 45 10             	lea    0x10(%ebp),%eax
  801733:	83 c0 04             	add    $0x4,%eax
  801736:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// Print the panic message
	if (argv0)
  801739:	a1 24 30 80 00       	mov    0x803024,%eax
  80173e:	85 c0                	test   %eax,%eax
  801740:	74 16                	je     801758 <_panic+0x2e>
		cprintf("%s: ", argv0);
  801742:	a1 24 30 80 00       	mov    0x803024,%eax
  801747:	83 ec 08             	sub    $0x8,%esp
  80174a:	50                   	push   %eax
  80174b:	68 58 20 80 00       	push   $0x802058
  801750:	e8 59 eb ff ff       	call   8002ae <cprintf>
  801755:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  801758:	a1 00 30 80 00       	mov    0x803000,%eax
  80175d:	ff 75 0c             	pushl  0xc(%ebp)
  801760:	ff 75 08             	pushl  0x8(%ebp)
  801763:	50                   	push   %eax
  801764:	68 5d 20 80 00       	push   $0x80205d
  801769:	e8 40 eb ff ff       	call   8002ae <cprintf>
  80176e:	83 c4 10             	add    $0x10,%esp
	vcprintf(fmt, ap);
  801771:	8b 45 10             	mov    0x10(%ebp),%eax
  801774:	83 ec 08             	sub    $0x8,%esp
  801777:	ff 75 f4             	pushl  -0xc(%ebp)
  80177a:	50                   	push   %eax
  80177b:	e8 c3 ea ff ff       	call   800243 <vcprintf>
  801780:	83 c4 10             	add    $0x10,%esp
	vcprintf("\n", NULL);
  801783:	83 ec 08             	sub    $0x8,%esp
  801786:	6a 00                	push   $0x0
  801788:	68 79 20 80 00       	push   $0x802079
  80178d:	e8 b1 ea ff ff       	call   800243 <vcprintf>
  801792:	83 c4 10             	add    $0x10,%esp
	// Cause a breakpoint exception
//	while (1);
//		asm volatile("int3");

	//2013: exit the panic env only
	exit() ;
  801795:	e8 32 ea ff ff       	call   8001cc <exit>

	// should not return here
	while (1) ;
  80179a:	eb fe                	jmp    80179a <_panic+0x70>

0080179c <CheckWSArrayWithoutLastIndex>:
}

void CheckWSArrayWithoutLastIndex(uint32 *expectedPages, int arraySize)
{
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
  80179f:	83 ec 28             	sub    $0x28,%esp
	if (arraySize != myEnv->page_WS_max_size)
  8017a2:	a1 04 30 80 00       	mov    0x803004,%eax
  8017a7:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
  8017ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b0:	39 c2                	cmp    %eax,%edx
  8017b2:	74 14                	je     8017c8 <CheckWSArrayWithoutLastIndex+0x2c>
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
  8017b4:	83 ec 04             	sub    $0x4,%esp
  8017b7:	68 7c 20 80 00       	push   $0x80207c
  8017bc:	6a 26                	push   $0x26
  8017be:	68 c8 20 80 00       	push   $0x8020c8
  8017c3:	e8 62 ff ff ff       	call   80172a <_panic>
	}
	int expectedNumOfEmptyLocs = 0;
  8017c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	for (int e = 0; e < arraySize; e++) {
  8017cf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8017d6:	e9 c5 00 00 00       	jmp    8018a0 <CheckWSArrayWithoutLastIndex+0x104>
		if (expectedPages[e] == 0) {
  8017db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017de:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8017e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e8:	01 d0                	add    %edx,%eax
  8017ea:	8b 00                	mov    (%eax),%eax
  8017ec:	85 c0                	test   %eax,%eax
  8017ee:	75 08                	jne    8017f8 <CheckWSArrayWithoutLastIndex+0x5c>
			expectedNumOfEmptyLocs++;
  8017f0:	ff 45 f4             	incl   -0xc(%ebp)
			continue;
  8017f3:	e9 a5 00 00 00       	jmp    80189d <CheckWSArrayWithoutLastIndex+0x101>
		}
		int found = 0;
  8017f8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  8017ff:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  801806:	eb 69                	jmp    801871 <CheckWSArrayWithoutLastIndex+0xd5>
			if (myEnv->__uptr_pws[w].empty == 0) {
  801808:	a1 04 30 80 00       	mov    0x803004,%eax
  80180d:	8b 88 7c 05 00 00    	mov    0x57c(%eax),%ecx
  801813:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801816:	89 d0                	mov    %edx,%eax
  801818:	01 c0                	add    %eax,%eax
  80181a:	01 d0                	add    %edx,%eax
  80181c:	c1 e0 03             	shl    $0x3,%eax
  80181f:	01 c8                	add    %ecx,%eax
  801821:	8a 40 04             	mov    0x4(%eax),%al
  801824:	84 c0                	test   %al,%al
  801826:	75 46                	jne    80186e <CheckWSArrayWithoutLastIndex+0xd2>
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  801828:	a1 04 30 80 00       	mov    0x803004,%eax
  80182d:	8b 88 7c 05 00 00    	mov    0x57c(%eax),%ecx
  801833:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801836:	89 d0                	mov    %edx,%eax
  801838:	01 c0                	add    %eax,%eax
  80183a:	01 d0                	add    %edx,%eax
  80183c:	c1 e0 03             	shl    $0x3,%eax
  80183f:	01 c8                	add    %ecx,%eax
  801841:	8b 00                	mov    (%eax),%eax
  801843:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801846:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801849:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80184e:	89 c2                	mov    %eax,%edx
						== expectedPages[e]) {
  801850:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801853:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80185a:	8b 45 08             	mov    0x8(%ebp),%eax
  80185d:	01 c8                	add    %ecx,%eax
  80185f:	8b 00                	mov    (%eax),%eax
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
			if (myEnv->__uptr_pws[w].empty == 0) {
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  801861:	39 c2                	cmp    %eax,%edx
  801863:	75 09                	jne    80186e <CheckWSArrayWithoutLastIndex+0xd2>
						== expectedPages[e]) {
					found = 1;
  801865:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
					break;
  80186c:	eb 15                	jmp    801883 <CheckWSArrayWithoutLastIndex+0xe7>
		if (expectedPages[e] == 0) {
			expectedNumOfEmptyLocs++;
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  80186e:	ff 45 e8             	incl   -0x18(%ebp)
  801871:	a1 04 30 80 00       	mov    0x803004,%eax
  801876:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
  80187c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80187f:	39 c2                	cmp    %eax,%edx
  801881:	77 85                	ja     801808 <CheckWSArrayWithoutLastIndex+0x6c>
					found = 1;
					break;
				}
			}
		}
		if (!found)
  801883:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801887:	75 14                	jne    80189d <CheckWSArrayWithoutLastIndex+0x101>
			panic(
  801889:	83 ec 04             	sub    $0x4,%esp
  80188c:	68 d4 20 80 00       	push   $0x8020d4
  801891:	6a 3a                	push   $0x3a
  801893:	68 c8 20 80 00       	push   $0x8020c8
  801898:	e8 8d fe ff ff       	call   80172a <_panic>
	if (arraySize != myEnv->page_WS_max_size)
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
	}
	int expectedNumOfEmptyLocs = 0;
	for (int e = 0; e < arraySize; e++) {
  80189d:	ff 45 f0             	incl   -0x10(%ebp)
  8018a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a3:	3b 45 0c             	cmp    0xc(%ebp),%eax
  8018a6:	0f 8c 2f ff ff ff    	jl     8017db <CheckWSArrayWithoutLastIndex+0x3f>
		}
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
  8018ac:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  8018b3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8018ba:	eb 26                	jmp    8018e2 <CheckWSArrayWithoutLastIndex+0x146>
		if (myEnv->__uptr_pws[w].empty == 1) {
  8018bc:	a1 04 30 80 00       	mov    0x803004,%eax
  8018c1:	8b 88 7c 05 00 00    	mov    0x57c(%eax),%ecx
  8018c7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8018ca:	89 d0                	mov    %edx,%eax
  8018cc:	01 c0                	add    %eax,%eax
  8018ce:	01 d0                	add    %edx,%eax
  8018d0:	c1 e0 03             	shl    $0x3,%eax
  8018d3:	01 c8                	add    %ecx,%eax
  8018d5:	8a 40 04             	mov    0x4(%eax),%al
  8018d8:	3c 01                	cmp    $0x1,%al
  8018da:	75 03                	jne    8018df <CheckWSArrayWithoutLastIndex+0x143>
			actualNumOfEmptyLocs++;
  8018dc:	ff 45 e4             	incl   -0x1c(%ebp)
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  8018df:	ff 45 e0             	incl   -0x20(%ebp)
  8018e2:	a1 04 30 80 00       	mov    0x803004,%eax
  8018e7:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
  8018ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018f0:	39 c2                	cmp    %eax,%edx
  8018f2:	77 c8                	ja     8018bc <CheckWSArrayWithoutLastIndex+0x120>
		if (myEnv->__uptr_pws[w].empty == 1) {
			actualNumOfEmptyLocs++;
		}
	}
	if (expectedNumOfEmptyLocs != actualNumOfEmptyLocs)
  8018f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f7:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  8018fa:	74 14                	je     801910 <CheckWSArrayWithoutLastIndex+0x174>
		panic(
  8018fc:	83 ec 04             	sub    $0x4,%esp
  8018ff:	68 28 21 80 00       	push   $0x802128
  801904:	6a 44                	push   $0x44
  801906:	68 c8 20 80 00       	push   $0x8020c8
  80190b:	e8 1a fe ff ff       	call   80172a <_panic>
				"PAGE WS entry checking failed... number of empty locations is not correct");
}
  801910:	90                   	nop
  801911:	c9                   	leave  
  801912:	c3                   	ret    
  801913:	90                   	nop

00801914 <__udivdi3>:
  801914:	55                   	push   %ebp
  801915:	57                   	push   %edi
  801916:	56                   	push   %esi
  801917:	53                   	push   %ebx
  801918:	83 ec 1c             	sub    $0x1c,%esp
  80191b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80191f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801923:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801927:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80192b:	89 ca                	mov    %ecx,%edx
  80192d:	89 f8                	mov    %edi,%eax
  80192f:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801933:	85 f6                	test   %esi,%esi
  801935:	75 2d                	jne    801964 <__udivdi3+0x50>
  801937:	39 cf                	cmp    %ecx,%edi
  801939:	77 65                	ja     8019a0 <__udivdi3+0x8c>
  80193b:	89 fd                	mov    %edi,%ebp
  80193d:	85 ff                	test   %edi,%edi
  80193f:	75 0b                	jne    80194c <__udivdi3+0x38>
  801941:	b8 01 00 00 00       	mov    $0x1,%eax
  801946:	31 d2                	xor    %edx,%edx
  801948:	f7 f7                	div    %edi
  80194a:	89 c5                	mov    %eax,%ebp
  80194c:	31 d2                	xor    %edx,%edx
  80194e:	89 c8                	mov    %ecx,%eax
  801950:	f7 f5                	div    %ebp
  801952:	89 c1                	mov    %eax,%ecx
  801954:	89 d8                	mov    %ebx,%eax
  801956:	f7 f5                	div    %ebp
  801958:	89 cf                	mov    %ecx,%edi
  80195a:	89 fa                	mov    %edi,%edx
  80195c:	83 c4 1c             	add    $0x1c,%esp
  80195f:	5b                   	pop    %ebx
  801960:	5e                   	pop    %esi
  801961:	5f                   	pop    %edi
  801962:	5d                   	pop    %ebp
  801963:	c3                   	ret    
  801964:	39 ce                	cmp    %ecx,%esi
  801966:	77 28                	ja     801990 <__udivdi3+0x7c>
  801968:	0f bd fe             	bsr    %esi,%edi
  80196b:	83 f7 1f             	xor    $0x1f,%edi
  80196e:	75 40                	jne    8019b0 <__udivdi3+0x9c>
  801970:	39 ce                	cmp    %ecx,%esi
  801972:	72 0a                	jb     80197e <__udivdi3+0x6a>
  801974:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801978:	0f 87 9e 00 00 00    	ja     801a1c <__udivdi3+0x108>
  80197e:	b8 01 00 00 00       	mov    $0x1,%eax
  801983:	89 fa                	mov    %edi,%edx
  801985:	83 c4 1c             	add    $0x1c,%esp
  801988:	5b                   	pop    %ebx
  801989:	5e                   	pop    %esi
  80198a:	5f                   	pop    %edi
  80198b:	5d                   	pop    %ebp
  80198c:	c3                   	ret    
  80198d:	8d 76 00             	lea    0x0(%esi),%esi
  801990:	31 ff                	xor    %edi,%edi
  801992:	31 c0                	xor    %eax,%eax
  801994:	89 fa                	mov    %edi,%edx
  801996:	83 c4 1c             	add    $0x1c,%esp
  801999:	5b                   	pop    %ebx
  80199a:	5e                   	pop    %esi
  80199b:	5f                   	pop    %edi
  80199c:	5d                   	pop    %ebp
  80199d:	c3                   	ret    
  80199e:	66 90                	xchg   %ax,%ax
  8019a0:	89 d8                	mov    %ebx,%eax
  8019a2:	f7 f7                	div    %edi
  8019a4:	31 ff                	xor    %edi,%edi
  8019a6:	89 fa                	mov    %edi,%edx
  8019a8:	83 c4 1c             	add    $0x1c,%esp
  8019ab:	5b                   	pop    %ebx
  8019ac:	5e                   	pop    %esi
  8019ad:	5f                   	pop    %edi
  8019ae:	5d                   	pop    %ebp
  8019af:	c3                   	ret    
  8019b0:	bd 20 00 00 00       	mov    $0x20,%ebp
  8019b5:	89 eb                	mov    %ebp,%ebx
  8019b7:	29 fb                	sub    %edi,%ebx
  8019b9:	89 f9                	mov    %edi,%ecx
  8019bb:	d3 e6                	shl    %cl,%esi
  8019bd:	89 c5                	mov    %eax,%ebp
  8019bf:	88 d9                	mov    %bl,%cl
  8019c1:	d3 ed                	shr    %cl,%ebp
  8019c3:	89 e9                	mov    %ebp,%ecx
  8019c5:	09 f1                	or     %esi,%ecx
  8019c7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8019cb:	89 f9                	mov    %edi,%ecx
  8019cd:	d3 e0                	shl    %cl,%eax
  8019cf:	89 c5                	mov    %eax,%ebp
  8019d1:	89 d6                	mov    %edx,%esi
  8019d3:	88 d9                	mov    %bl,%cl
  8019d5:	d3 ee                	shr    %cl,%esi
  8019d7:	89 f9                	mov    %edi,%ecx
  8019d9:	d3 e2                	shl    %cl,%edx
  8019db:	8b 44 24 08          	mov    0x8(%esp),%eax
  8019df:	88 d9                	mov    %bl,%cl
  8019e1:	d3 e8                	shr    %cl,%eax
  8019e3:	09 c2                	or     %eax,%edx
  8019e5:	89 d0                	mov    %edx,%eax
  8019e7:	89 f2                	mov    %esi,%edx
  8019e9:	f7 74 24 0c          	divl   0xc(%esp)
  8019ed:	89 d6                	mov    %edx,%esi
  8019ef:	89 c3                	mov    %eax,%ebx
  8019f1:	f7 e5                	mul    %ebp
  8019f3:	39 d6                	cmp    %edx,%esi
  8019f5:	72 19                	jb     801a10 <__udivdi3+0xfc>
  8019f7:	74 0b                	je     801a04 <__udivdi3+0xf0>
  8019f9:	89 d8                	mov    %ebx,%eax
  8019fb:	31 ff                	xor    %edi,%edi
  8019fd:	e9 58 ff ff ff       	jmp    80195a <__udivdi3+0x46>
  801a02:	66 90                	xchg   %ax,%ax
  801a04:	8b 54 24 08          	mov    0x8(%esp),%edx
  801a08:	89 f9                	mov    %edi,%ecx
  801a0a:	d3 e2                	shl    %cl,%edx
  801a0c:	39 c2                	cmp    %eax,%edx
  801a0e:	73 e9                	jae    8019f9 <__udivdi3+0xe5>
  801a10:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801a13:	31 ff                	xor    %edi,%edi
  801a15:	e9 40 ff ff ff       	jmp    80195a <__udivdi3+0x46>
  801a1a:	66 90                	xchg   %ax,%ax
  801a1c:	31 c0                	xor    %eax,%eax
  801a1e:	e9 37 ff ff ff       	jmp    80195a <__udivdi3+0x46>
  801a23:	90                   	nop

00801a24 <__umoddi3>:
  801a24:	55                   	push   %ebp
  801a25:	57                   	push   %edi
  801a26:	56                   	push   %esi
  801a27:	53                   	push   %ebx
  801a28:	83 ec 1c             	sub    $0x1c,%esp
  801a2b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801a2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801a33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801a37:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801a3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a3f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a43:	89 f3                	mov    %esi,%ebx
  801a45:	89 fa                	mov    %edi,%edx
  801a47:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a4b:	89 34 24             	mov    %esi,(%esp)
  801a4e:	85 c0                	test   %eax,%eax
  801a50:	75 1a                	jne    801a6c <__umoddi3+0x48>
  801a52:	39 f7                	cmp    %esi,%edi
  801a54:	0f 86 a2 00 00 00    	jbe    801afc <__umoddi3+0xd8>
  801a5a:	89 c8                	mov    %ecx,%eax
  801a5c:	89 f2                	mov    %esi,%edx
  801a5e:	f7 f7                	div    %edi
  801a60:	89 d0                	mov    %edx,%eax
  801a62:	31 d2                	xor    %edx,%edx
  801a64:	83 c4 1c             	add    $0x1c,%esp
  801a67:	5b                   	pop    %ebx
  801a68:	5e                   	pop    %esi
  801a69:	5f                   	pop    %edi
  801a6a:	5d                   	pop    %ebp
  801a6b:	c3                   	ret    
  801a6c:	39 f0                	cmp    %esi,%eax
  801a6e:	0f 87 ac 00 00 00    	ja     801b20 <__umoddi3+0xfc>
  801a74:	0f bd e8             	bsr    %eax,%ebp
  801a77:	83 f5 1f             	xor    $0x1f,%ebp
  801a7a:	0f 84 ac 00 00 00    	je     801b2c <__umoddi3+0x108>
  801a80:	bf 20 00 00 00       	mov    $0x20,%edi
  801a85:	29 ef                	sub    %ebp,%edi
  801a87:	89 fe                	mov    %edi,%esi
  801a89:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a8d:	89 e9                	mov    %ebp,%ecx
  801a8f:	d3 e0                	shl    %cl,%eax
  801a91:	89 d7                	mov    %edx,%edi
  801a93:	89 f1                	mov    %esi,%ecx
  801a95:	d3 ef                	shr    %cl,%edi
  801a97:	09 c7                	or     %eax,%edi
  801a99:	89 e9                	mov    %ebp,%ecx
  801a9b:	d3 e2                	shl    %cl,%edx
  801a9d:	89 14 24             	mov    %edx,(%esp)
  801aa0:	89 d8                	mov    %ebx,%eax
  801aa2:	d3 e0                	shl    %cl,%eax
  801aa4:	89 c2                	mov    %eax,%edx
  801aa6:	8b 44 24 08          	mov    0x8(%esp),%eax
  801aaa:	d3 e0                	shl    %cl,%eax
  801aac:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab0:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ab4:	89 f1                	mov    %esi,%ecx
  801ab6:	d3 e8                	shr    %cl,%eax
  801ab8:	09 d0                	or     %edx,%eax
  801aba:	d3 eb                	shr    %cl,%ebx
  801abc:	89 da                	mov    %ebx,%edx
  801abe:	f7 f7                	div    %edi
  801ac0:	89 d3                	mov    %edx,%ebx
  801ac2:	f7 24 24             	mull   (%esp)
  801ac5:	89 c6                	mov    %eax,%esi
  801ac7:	89 d1                	mov    %edx,%ecx
  801ac9:	39 d3                	cmp    %edx,%ebx
  801acb:	0f 82 87 00 00 00    	jb     801b58 <__umoddi3+0x134>
  801ad1:	0f 84 91 00 00 00    	je     801b68 <__umoddi3+0x144>
  801ad7:	8b 54 24 04          	mov    0x4(%esp),%edx
  801adb:	29 f2                	sub    %esi,%edx
  801add:	19 cb                	sbb    %ecx,%ebx
  801adf:	89 d8                	mov    %ebx,%eax
  801ae1:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801ae5:	d3 e0                	shl    %cl,%eax
  801ae7:	89 e9                	mov    %ebp,%ecx
  801ae9:	d3 ea                	shr    %cl,%edx
  801aeb:	09 d0                	or     %edx,%eax
  801aed:	89 e9                	mov    %ebp,%ecx
  801aef:	d3 eb                	shr    %cl,%ebx
  801af1:	89 da                	mov    %ebx,%edx
  801af3:	83 c4 1c             	add    $0x1c,%esp
  801af6:	5b                   	pop    %ebx
  801af7:	5e                   	pop    %esi
  801af8:	5f                   	pop    %edi
  801af9:	5d                   	pop    %ebp
  801afa:	c3                   	ret    
  801afb:	90                   	nop
  801afc:	89 fd                	mov    %edi,%ebp
  801afe:	85 ff                	test   %edi,%edi
  801b00:	75 0b                	jne    801b0d <__umoddi3+0xe9>
  801b02:	b8 01 00 00 00       	mov    $0x1,%eax
  801b07:	31 d2                	xor    %edx,%edx
  801b09:	f7 f7                	div    %edi
  801b0b:	89 c5                	mov    %eax,%ebp
  801b0d:	89 f0                	mov    %esi,%eax
  801b0f:	31 d2                	xor    %edx,%edx
  801b11:	f7 f5                	div    %ebp
  801b13:	89 c8                	mov    %ecx,%eax
  801b15:	f7 f5                	div    %ebp
  801b17:	89 d0                	mov    %edx,%eax
  801b19:	e9 44 ff ff ff       	jmp    801a62 <__umoddi3+0x3e>
  801b1e:	66 90                	xchg   %ax,%ax
  801b20:	89 c8                	mov    %ecx,%eax
  801b22:	89 f2                	mov    %esi,%edx
  801b24:	83 c4 1c             	add    $0x1c,%esp
  801b27:	5b                   	pop    %ebx
  801b28:	5e                   	pop    %esi
  801b29:	5f                   	pop    %edi
  801b2a:	5d                   	pop    %ebp
  801b2b:	c3                   	ret    
  801b2c:	3b 04 24             	cmp    (%esp),%eax
  801b2f:	72 06                	jb     801b37 <__umoddi3+0x113>
  801b31:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801b35:	77 0f                	ja     801b46 <__umoddi3+0x122>
  801b37:	89 f2                	mov    %esi,%edx
  801b39:	29 f9                	sub    %edi,%ecx
  801b3b:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801b3f:	89 14 24             	mov    %edx,(%esp)
  801b42:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b46:	8b 44 24 04          	mov    0x4(%esp),%eax
  801b4a:	8b 14 24             	mov    (%esp),%edx
  801b4d:	83 c4 1c             	add    $0x1c,%esp
  801b50:	5b                   	pop    %ebx
  801b51:	5e                   	pop    %esi
  801b52:	5f                   	pop    %edi
  801b53:	5d                   	pop    %ebp
  801b54:	c3                   	ret    
  801b55:	8d 76 00             	lea    0x0(%esi),%esi
  801b58:	2b 04 24             	sub    (%esp),%eax
  801b5b:	19 fa                	sbb    %edi,%edx
  801b5d:	89 d1                	mov    %edx,%ecx
  801b5f:	89 c6                	mov    %eax,%esi
  801b61:	e9 71 ff ff ff       	jmp    801ad7 <__umoddi3+0xb3>
  801b66:	66 90                	xchg   %ax,%ax
  801b68:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801b6c:	72 ea                	jb     801b58 <__umoddi3+0x134>
  801b6e:	89 d9                	mov    %ebx,%ecx
  801b70:	e9 62 ff ff ff       	jmp    801ad7 <__umoddi3+0xb3>
