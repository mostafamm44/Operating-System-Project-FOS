
obj/user/tst_chan_all_slave:     file format elf32-i386


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
  800031:	e8 2a 00 00 00       	call   800060 <libmain>
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
  80003e:	e8 92 12 00 00       	call   8012d5 <sys_getenvid>
  800043:	89 45 f4             	mov    %eax,-0xc(%ebp)

	//Sleep on the channel
	sys_utilities("__Sleep__", 0);
  800046:	83 ec 08             	sub    $0x8,%esp
  800049:	6a 00                	push   $0x0
  80004b:	68 80 1a 80 00       	push   $0x801a80
  800050:	e8 68 15 00 00       	call   8015bd <sys_utilities>
  800055:	83 c4 10             	add    $0x10,%esp

	//indicates wakenup
	inctst();
  800058:	e8 cf 13 00 00       	call   80142c <inctst>

	return;
  80005d:	90                   	nop
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:

volatile struct Env *myEnv = NULL;
volatile char *binaryname = "(PROGRAM NAME UNKNOWN)";
void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	83 ec 18             	sub    $0x18,%esp
	int envIndex = sys_getenvindex();
  800066:	e8 83 12 00 00       	call   8012ee <sys_getenvindex>
  80006b:	89 45 f4             	mov    %eax,-0xc(%ebp)

	myEnv = &(envs[envIndex]);
  80006e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800071:	89 d0                	mov    %edx,%eax
  800073:	c1 e0 02             	shl    $0x2,%eax
  800076:	01 d0                	add    %edx,%eax
  800078:	01 c0                	add    %eax,%eax
  80007a:	01 d0                	add    %edx,%eax
  80007c:	c1 e0 02             	shl    $0x2,%eax
  80007f:	01 d0                	add    %edx,%eax
  800081:	01 c0                	add    %eax,%eax
  800083:	01 d0                	add    %edx,%eax
  800085:	c1 e0 04             	shl    $0x4,%eax
  800088:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008d:	a3 04 30 80 00       	mov    %eax,0x803004

	//SET THE PROGRAM NAME
	if (myEnv->prog_name[0] != '\0')
  800092:	a1 04 30 80 00       	mov    0x803004,%eax
  800097:	8a 40 20             	mov    0x20(%eax),%al
  80009a:	84 c0                	test   %al,%al
  80009c:	74 0d                	je     8000ab <libmain+0x4b>
		binaryname = myEnv->prog_name;
  80009e:	a1 04 30 80 00       	mov    0x803004,%eax
  8000a3:	83 c0 20             	add    $0x20,%eax
  8000a6:	a3 00 30 80 00       	mov    %eax,0x803000

	// set env to point at our env structure in envs[].
	// env = envs;

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ab:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000af:	7e 0a                	jle    8000bb <libmain+0x5b>
		binaryname = argv[0];
  8000b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000b4:	8b 00                	mov    (%eax),%eax
  8000b6:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	_main(argc, argv);
  8000bb:	83 ec 08             	sub    $0x8,%esp
  8000be:	ff 75 0c             	pushl  0xc(%ebp)
  8000c1:	ff 75 08             	pushl  0x8(%ebp)
  8000c4:	e8 6f ff ff ff       	call   800038 <_main>
  8000c9:	83 c4 10             	add    $0x10,%esp



	//	sys_lock_cons();
	sys_lock_cons();
  8000cc:	e8 a1 0f 00 00       	call   801072 <sys_lock_cons>
	{
		cprintf("**************************************\n");
  8000d1:	83 ec 0c             	sub    $0xc,%esp
  8000d4:	68 a4 1a 80 00       	push   $0x801aa4
  8000d9:	e8 8d 01 00 00       	call   80026b <cprintf>
  8000de:	83 c4 10             	add    $0x10,%esp
		cprintf("Num of PAGE faults = %d, modif = %d\n", myEnv->pageFaultsCounter, myEnv->nModifiedPages);
  8000e1:	a1 04 30 80 00       	mov    0x803004,%eax
  8000e6:	8b 90 94 05 00 00    	mov    0x594(%eax),%edx
  8000ec:	a1 04 30 80 00       	mov    0x803004,%eax
  8000f1:	8b 80 84 05 00 00    	mov    0x584(%eax),%eax
  8000f7:	83 ec 04             	sub    $0x4,%esp
  8000fa:	52                   	push   %edx
  8000fb:	50                   	push   %eax
  8000fc:	68 cc 1a 80 00       	push   $0x801acc
  800101:	e8 65 01 00 00       	call   80026b <cprintf>
  800106:	83 c4 10             	add    $0x10,%esp
		cprintf("# PAGE IN (from disk) = %d, # PAGE OUT (on disk) = %d, # NEW PAGE ADDED (on disk) = %d\n", myEnv->nPageIn, myEnv->nPageOut,myEnv->nNewPageAdded);
  800109:	a1 04 30 80 00       	mov    0x803004,%eax
  80010e:	8b 88 a8 05 00 00    	mov    0x5a8(%eax),%ecx
  800114:	a1 04 30 80 00       	mov    0x803004,%eax
  800119:	8b 90 a4 05 00 00    	mov    0x5a4(%eax),%edx
  80011f:	a1 04 30 80 00       	mov    0x803004,%eax
  800124:	8b 80 a0 05 00 00    	mov    0x5a0(%eax),%eax
  80012a:	51                   	push   %ecx
  80012b:	52                   	push   %edx
  80012c:	50                   	push   %eax
  80012d:	68 f4 1a 80 00       	push   $0x801af4
  800132:	e8 34 01 00 00       	call   80026b <cprintf>
  800137:	83 c4 10             	add    $0x10,%esp
		//cprintf("Num of freeing scarce memory = %d, freeing full working set = %d\n", myEnv->freeingScarceMemCounter, myEnv->freeingFullWSCounter);
		cprintf("Num of clocks = %d\n", myEnv->nClocks);
  80013a:	a1 04 30 80 00       	mov    0x803004,%eax
  80013f:	8b 80 ac 05 00 00    	mov    0x5ac(%eax),%eax
  800145:	83 ec 08             	sub    $0x8,%esp
  800148:	50                   	push   %eax
  800149:	68 4c 1b 80 00       	push   $0x801b4c
  80014e:	e8 18 01 00 00       	call   80026b <cprintf>
  800153:	83 c4 10             	add    $0x10,%esp
		cprintf("**************************************\n");
  800156:	83 ec 0c             	sub    $0xc,%esp
  800159:	68 a4 1a 80 00       	push   $0x801aa4
  80015e:	e8 08 01 00 00       	call   80026b <cprintf>
  800163:	83 c4 10             	add    $0x10,%esp
	}
	sys_unlock_cons();
  800166:	e8 21 0f 00 00       	call   80108c <sys_unlock_cons>
//	sys_unlock_cons();

	// exit gracefully
	exit();
  80016b:	e8 19 00 00 00       	call   800189 <exit>
}
  800170:	90                   	nop
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <destroy>:

#include <inc/lib.h>

void
destroy(void)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	83 ec 08             	sub    $0x8,%esp
	sys_destroy_env(0);
  800179:	83 ec 0c             	sub    $0xc,%esp
  80017c:	6a 00                	push   $0x0
  80017e:	e8 37 11 00 00       	call   8012ba <sys_destroy_env>
  800183:	83 c4 10             	add    $0x10,%esp
}
  800186:	90                   	nop
  800187:	c9                   	leave  
  800188:	c3                   	ret    

00800189 <exit>:

void
exit(void)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	83 ec 08             	sub    $0x8,%esp
	sys_exit_env();
  80018f:	e8 8c 11 00 00       	call   801320 <sys_exit_env>
}
  800194:	90                   	nop
  800195:	c9                   	leave  
  800196:	c3                   	ret    

00800197 <putch>:
	int idx; // current buffer index
	int cnt; // total bytes printed so far
	char buf[256];
};

static void putch(int ch, struct printbuf *b) {
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	83 ec 08             	sub    $0x8,%esp
	b->buf[b->idx++] = ch;
  80019d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a0:	8b 00                	mov    (%eax),%eax
  8001a2:	8d 48 01             	lea    0x1(%eax),%ecx
  8001a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a8:	89 0a                	mov    %ecx,(%edx)
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	88 d1                	mov    %dl,%cl
  8001af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b2:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256 - 1) {
  8001b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b9:	8b 00                	mov    (%eax),%eax
  8001bb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c0:	75 2c                	jne    8001ee <putch+0x57>
		sys_cputs(b->buf, b->idx, printProgName);
  8001c2:	a0 08 30 80 00       	mov    0x803008,%al
  8001c7:	0f b6 c0             	movzbl %al,%eax
  8001ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cd:	8b 12                	mov    (%edx),%edx
  8001cf:	89 d1                	mov    %edx,%ecx
  8001d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d4:	83 c2 08             	add    $0x8,%edx
  8001d7:	83 ec 04             	sub    $0x4,%esp
  8001da:	50                   	push   %eax
  8001db:	51                   	push   %ecx
  8001dc:	52                   	push   %edx
  8001dd:	e8 4e 0e 00 00       	call   801030 <sys_cputs>
  8001e2:	83 c4 10             	add    $0x10,%esp
		b->idx = 0;
  8001e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8001ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f1:	8b 40 04             	mov    0x4(%eax),%eax
  8001f4:	8d 50 01             	lea    0x1(%eax),%edx
  8001f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001fa:	89 50 04             	mov    %edx,0x4(%eax)
}
  8001fd:	90                   	nop
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <vcprintf>:

int vcprintf(const char *fmt, va_list ap) {
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800209:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800210:	00 00 00 
	b.cnt = 0;
  800213:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80021a:	00 00 00 
	vprintfmt((void*) putch, &b, fmt, ap);
  80021d:	ff 75 0c             	pushl  0xc(%ebp)
  800220:	ff 75 08             	pushl  0x8(%ebp)
  800223:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800229:	50                   	push   %eax
  80022a:	68 97 01 80 00       	push   $0x800197
  80022f:	e8 11 02 00 00       	call   800445 <vprintfmt>
  800234:	83 c4 10             	add    $0x10,%esp
	sys_cputs(b.buf, b.idx, printProgName);
  800237:	a0 08 30 80 00       	mov    0x803008,%al
  80023c:	0f b6 c0             	movzbl %al,%eax
  80023f:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
  800245:	83 ec 04             	sub    $0x4,%esp
  800248:	50                   	push   %eax
  800249:	52                   	push   %edx
  80024a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800250:	83 c0 08             	add    $0x8,%eax
  800253:	50                   	push   %eax
  800254:	e8 d7 0d 00 00       	call   801030 <sys_cputs>
  800259:	83 c4 10             	add    $0x10,%esp

	printProgName = 0;
  80025c:	c6 05 08 30 80 00 00 	movb   $0x0,0x803008
	return b.cnt;
  800263:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800269:	c9                   	leave  
  80026a:	c3                   	ret    

0080026b <cprintf>:

//%@: to print the program name and ID before the message
//%~: to print the message directly
int cprintf(const char *fmt, ...) {
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;
	printProgName = 1 ;
  800271:	c6 05 08 30 80 00 01 	movb   $0x1,0x803008
	va_start(ap, fmt);
  800278:	8d 45 0c             	lea    0xc(%ebp),%eax
  80027b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	ff 75 f4             	pushl  -0xc(%ebp)
  800287:	50                   	push   %eax
  800288:	e8 73 ff ff ff       	call   800200 <vcprintf>
  80028d:	83 c4 10             	add    $0x10,%esp
  800290:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return cnt;
  800293:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <atomic_cprintf>:

//%@: to print the program name and ID before the message
//%~: to print the message directly
int atomic_cprintf(const char *fmt, ...)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	83 ec 18             	sub    $0x18,%esp
	int cnt;
	sys_lock_cons();
  80029e:	e8 cf 0d 00 00       	call   801072 <sys_lock_cons>
	{
		va_list ap;
		va_start(ap, fmt);
  8002a3:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
		cnt = vcprintf(fmt, ap);
  8002a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	ff 75 f4             	pushl  -0xc(%ebp)
  8002b2:	50                   	push   %eax
  8002b3:	e8 48 ff ff ff       	call   800200 <vcprintf>
  8002b8:	83 c4 10             	add    $0x10,%esp
  8002bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
		va_end(ap);
	}
	sys_unlock_cons();
  8002be:	e8 c9 0d 00 00       	call   80108c <sys_unlock_cons>
	return cnt;
  8002c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8002c6:	c9                   	leave  
  8002c7:	c3                   	ret    

008002c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	53                   	push   %ebx
  8002cc:	83 ec 14             	sub    $0x14,%esp
  8002cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8002d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002db:	8b 45 18             	mov    0x18(%ebp),%eax
  8002de:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e3:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002e6:	77 55                	ja     80033d <printnum+0x75>
  8002e8:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002eb:	72 05                	jb     8002f2 <printnum+0x2a>
  8002ed:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8002f0:	77 4b                	ja     80033d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f2:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8002f5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002f8:	8b 45 18             	mov    0x18(%ebp),%eax
  8002fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800300:	52                   	push   %edx
  800301:	50                   	push   %eax
  800302:	ff 75 f4             	pushl  -0xc(%ebp)
  800305:	ff 75 f0             	pushl  -0x10(%ebp)
  800308:	e8 0f 15 00 00       	call   80181c <__udivdi3>
  80030d:	83 c4 10             	add    $0x10,%esp
  800310:	83 ec 04             	sub    $0x4,%esp
  800313:	ff 75 20             	pushl  0x20(%ebp)
  800316:	53                   	push   %ebx
  800317:	ff 75 18             	pushl  0x18(%ebp)
  80031a:	52                   	push   %edx
  80031b:	50                   	push   %eax
  80031c:	ff 75 0c             	pushl  0xc(%ebp)
  80031f:	ff 75 08             	pushl  0x8(%ebp)
  800322:	e8 a1 ff ff ff       	call   8002c8 <printnum>
  800327:	83 c4 20             	add    $0x20,%esp
  80032a:	eb 1a                	jmp    800346 <printnum+0x7e>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032c:	83 ec 08             	sub    $0x8,%esp
  80032f:	ff 75 0c             	pushl  0xc(%ebp)
  800332:	ff 75 20             	pushl  0x20(%ebp)
  800335:	8b 45 08             	mov    0x8(%ebp),%eax
  800338:	ff d0                	call   *%eax
  80033a:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033d:	ff 4d 1c             	decl   0x1c(%ebp)
  800340:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800344:	7f e6                	jg     80032c <printnum+0x64>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800346:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800349:	bb 00 00 00 00       	mov    $0x0,%ebx
  80034e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800351:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800354:	53                   	push   %ebx
  800355:	51                   	push   %ecx
  800356:	52                   	push   %edx
  800357:	50                   	push   %eax
  800358:	e8 cf 15 00 00       	call   80192c <__umoddi3>
  80035d:	83 c4 10             	add    $0x10,%esp
  800360:	05 74 1d 80 00       	add    $0x801d74,%eax
  800365:	8a 00                	mov    (%eax),%al
  800367:	0f be c0             	movsbl %al,%eax
  80036a:	83 ec 08             	sub    $0x8,%esp
  80036d:	ff 75 0c             	pushl  0xc(%ebp)
  800370:	50                   	push   %eax
  800371:	8b 45 08             	mov    0x8(%ebp),%eax
  800374:	ff d0                	call   *%eax
  800376:	83 c4 10             	add    $0x10,%esp
}
  800379:	90                   	nop
  80037a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80037d:	c9                   	leave  
  80037e:	c3                   	ret    

0080037f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80037f:	55                   	push   %ebp
  800380:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800382:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800386:	7e 1c                	jle    8003a4 <getuint+0x25>
		return va_arg(*ap, unsigned long long);
  800388:	8b 45 08             	mov    0x8(%ebp),%eax
  80038b:	8b 00                	mov    (%eax),%eax
  80038d:	8d 50 08             	lea    0x8(%eax),%edx
  800390:	8b 45 08             	mov    0x8(%ebp),%eax
  800393:	89 10                	mov    %edx,(%eax)
  800395:	8b 45 08             	mov    0x8(%ebp),%eax
  800398:	8b 00                	mov    (%eax),%eax
  80039a:	83 e8 08             	sub    $0x8,%eax
  80039d:	8b 50 04             	mov    0x4(%eax),%edx
  8003a0:	8b 00                	mov    (%eax),%eax
  8003a2:	eb 40                	jmp    8003e4 <getuint+0x65>
	else if (lflag)
  8003a4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003a8:	74 1e                	je     8003c8 <getuint+0x49>
		return va_arg(*ap, unsigned long);
  8003aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ad:	8b 00                	mov    (%eax),%eax
  8003af:	8d 50 04             	lea    0x4(%eax),%edx
  8003b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b5:	89 10                	mov    %edx,(%eax)
  8003b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ba:	8b 00                	mov    (%eax),%eax
  8003bc:	83 e8 04             	sub    $0x4,%eax
  8003bf:	8b 00                	mov    (%eax),%eax
  8003c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c6:	eb 1c                	jmp    8003e4 <getuint+0x65>
	else
		return va_arg(*ap, unsigned int);
  8003c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cb:	8b 00                	mov    (%eax),%eax
  8003cd:	8d 50 04             	lea    0x4(%eax),%edx
  8003d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d3:	89 10                	mov    %edx,(%eax)
  8003d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d8:	8b 00                	mov    (%eax),%eax
  8003da:	83 e8 04             	sub    $0x4,%eax
  8003dd:	8b 00                	mov    (%eax),%eax
  8003df:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003e4:	5d                   	pop    %ebp
  8003e5:	c3                   	ret    

008003e6 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003e9:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003ed:	7e 1c                	jle    80040b <getint+0x25>
		return va_arg(*ap, long long);
  8003ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f2:	8b 00                	mov    (%eax),%eax
  8003f4:	8d 50 08             	lea    0x8(%eax),%edx
  8003f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fa:	89 10                	mov    %edx,(%eax)
  8003fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ff:	8b 00                	mov    (%eax),%eax
  800401:	83 e8 08             	sub    $0x8,%eax
  800404:	8b 50 04             	mov    0x4(%eax),%edx
  800407:	8b 00                	mov    (%eax),%eax
  800409:	eb 38                	jmp    800443 <getint+0x5d>
	else if (lflag)
  80040b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80040f:	74 1a                	je     80042b <getint+0x45>
		return va_arg(*ap, long);
  800411:	8b 45 08             	mov    0x8(%ebp),%eax
  800414:	8b 00                	mov    (%eax),%eax
  800416:	8d 50 04             	lea    0x4(%eax),%edx
  800419:	8b 45 08             	mov    0x8(%ebp),%eax
  80041c:	89 10                	mov    %edx,(%eax)
  80041e:	8b 45 08             	mov    0x8(%ebp),%eax
  800421:	8b 00                	mov    (%eax),%eax
  800423:	83 e8 04             	sub    $0x4,%eax
  800426:	8b 00                	mov    (%eax),%eax
  800428:	99                   	cltd   
  800429:	eb 18                	jmp    800443 <getint+0x5d>
	else
		return va_arg(*ap, int);
  80042b:	8b 45 08             	mov    0x8(%ebp),%eax
  80042e:	8b 00                	mov    (%eax),%eax
  800430:	8d 50 04             	lea    0x4(%eax),%edx
  800433:	8b 45 08             	mov    0x8(%ebp),%eax
  800436:	89 10                	mov    %edx,(%eax)
  800438:	8b 45 08             	mov    0x8(%ebp),%eax
  80043b:	8b 00                	mov    (%eax),%eax
  80043d:	83 e8 04             	sub    $0x4,%eax
  800440:	8b 00                	mov    (%eax),%eax
  800442:	99                   	cltd   
}
  800443:	5d                   	pop    %ebp
  800444:	c3                   	ret    

00800445 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	56                   	push   %esi
  800449:	53                   	push   %ebx
  80044a:	83 ec 20             	sub    $0x20,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80044d:	eb 17                	jmp    800466 <vprintfmt+0x21>
			if (ch == '\0')
  80044f:	85 db                	test   %ebx,%ebx
  800451:	0f 84 c1 03 00 00    	je     800818 <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	ff 75 0c             	pushl  0xc(%ebp)
  80045d:	53                   	push   %ebx
  80045e:	8b 45 08             	mov    0x8(%ebp),%eax
  800461:	ff d0                	call   *%eax
  800463:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800466:	8b 45 10             	mov    0x10(%ebp),%eax
  800469:	8d 50 01             	lea    0x1(%eax),%edx
  80046c:	89 55 10             	mov    %edx,0x10(%ebp)
  80046f:	8a 00                	mov    (%eax),%al
  800471:	0f b6 d8             	movzbl %al,%ebx
  800474:	83 fb 25             	cmp    $0x25,%ebx
  800477:	75 d6                	jne    80044f <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800479:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80047d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800484:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80048b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800492:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800499:	8b 45 10             	mov    0x10(%ebp),%eax
  80049c:	8d 50 01             	lea    0x1(%eax),%edx
  80049f:	89 55 10             	mov    %edx,0x10(%ebp)
  8004a2:	8a 00                	mov    (%eax),%al
  8004a4:	0f b6 d8             	movzbl %al,%ebx
  8004a7:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8004aa:	83 f8 5b             	cmp    $0x5b,%eax
  8004ad:	0f 87 3d 03 00 00    	ja     8007f0 <vprintfmt+0x3ab>
  8004b3:	8b 04 85 98 1d 80 00 	mov    0x801d98(,%eax,4),%eax
  8004ba:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8004bc:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8004c0:	eb d7                	jmp    800499 <vprintfmt+0x54>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c2:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8004c6:	eb d1                	jmp    800499 <vprintfmt+0x54>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8004cf:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004d2:	89 d0                	mov    %edx,%eax
  8004d4:	c1 e0 02             	shl    $0x2,%eax
  8004d7:	01 d0                	add    %edx,%eax
  8004d9:	01 c0                	add    %eax,%eax
  8004db:	01 d8                	add    %ebx,%eax
  8004dd:	83 e8 30             	sub    $0x30,%eax
  8004e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8004e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e6:	8a 00                	mov    (%eax),%al
  8004e8:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8004eb:	83 fb 2f             	cmp    $0x2f,%ebx
  8004ee:	7e 3e                	jle    80052e <vprintfmt+0xe9>
  8004f0:	83 fb 39             	cmp    $0x39,%ebx
  8004f3:	7f 39                	jg     80052e <vprintfmt+0xe9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f5:	ff 45 10             	incl   0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f8:	eb d5                	jmp    8004cf <vprintfmt+0x8a>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fd:	83 c0 04             	add    $0x4,%eax
  800500:	89 45 14             	mov    %eax,0x14(%ebp)
  800503:	8b 45 14             	mov    0x14(%ebp),%eax
  800506:	83 e8 04             	sub    $0x4,%eax
  800509:	8b 00                	mov    (%eax),%eax
  80050b:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80050e:	eb 1f                	jmp    80052f <vprintfmt+0xea>

		case '.':
			if (width < 0)
  800510:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800514:	79 83                	jns    800499 <vprintfmt+0x54>
				width = 0;
  800516:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  80051d:	e9 77 ff ff ff       	jmp    800499 <vprintfmt+0x54>

		case '#':
			altflag = 1;
  800522:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800529:	e9 6b ff ff ff       	jmp    800499 <vprintfmt+0x54>
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto process_precision;
  80052e:	90                   	nop
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80052f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800533:	0f 89 60 ff ff ff    	jns    800499 <vprintfmt+0x54>
				width = precision, precision = -1;
  800539:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80053c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80053f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800546:	e9 4e ff ff ff       	jmp    800499 <vprintfmt+0x54>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80054b:	ff 45 e8             	incl   -0x18(%ebp)
			goto reswitch;
  80054e:	e9 46 ff ff ff       	jmp    800499 <vprintfmt+0x54>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800553:	8b 45 14             	mov    0x14(%ebp),%eax
  800556:	83 c0 04             	add    $0x4,%eax
  800559:	89 45 14             	mov    %eax,0x14(%ebp)
  80055c:	8b 45 14             	mov    0x14(%ebp),%eax
  80055f:	83 e8 04             	sub    $0x4,%eax
  800562:	8b 00                	mov    (%eax),%eax
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	ff 75 0c             	pushl  0xc(%ebp)
  80056a:	50                   	push   %eax
  80056b:	8b 45 08             	mov    0x8(%ebp),%eax
  80056e:	ff d0                	call   *%eax
  800570:	83 c4 10             	add    $0x10,%esp
			break;
  800573:	e9 9b 02 00 00       	jmp    800813 <vprintfmt+0x3ce>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	83 c0 04             	add    $0x4,%eax
  80057e:	89 45 14             	mov    %eax,0x14(%ebp)
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	83 e8 04             	sub    $0x4,%eax
  800587:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800589:	85 db                	test   %ebx,%ebx
  80058b:	79 02                	jns    80058f <vprintfmt+0x14a>
				err = -err;
  80058d:	f7 db                	neg    %ebx
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  80058f:	83 fb 64             	cmp    $0x64,%ebx
  800592:	7f 0b                	jg     80059f <vprintfmt+0x15a>
  800594:	8b 34 9d e0 1b 80 00 	mov    0x801be0(,%ebx,4),%esi
  80059b:	85 f6                	test   %esi,%esi
  80059d:	75 19                	jne    8005b8 <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  80059f:	53                   	push   %ebx
  8005a0:	68 85 1d 80 00       	push   $0x801d85
  8005a5:	ff 75 0c             	pushl  0xc(%ebp)
  8005a8:	ff 75 08             	pushl  0x8(%ebp)
  8005ab:	e8 70 02 00 00       	call   800820 <printfmt>
  8005b0:	83 c4 10             	add    $0x10,%esp
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8005b3:	e9 5b 02 00 00       	jmp    800813 <vprintfmt+0x3ce>
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8005b8:	56                   	push   %esi
  8005b9:	68 8e 1d 80 00       	push   $0x801d8e
  8005be:	ff 75 0c             	pushl  0xc(%ebp)
  8005c1:	ff 75 08             	pushl  0x8(%ebp)
  8005c4:	e8 57 02 00 00       	call   800820 <printfmt>
  8005c9:	83 c4 10             	add    $0x10,%esp
			break;
  8005cc:	e9 42 02 00 00       	jmp    800813 <vprintfmt+0x3ce>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	83 c0 04             	add    $0x4,%eax
  8005d7:	89 45 14             	mov    %eax,0x14(%ebp)
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	83 e8 04             	sub    $0x4,%eax
  8005e0:	8b 30                	mov    (%eax),%esi
  8005e2:	85 f6                	test   %esi,%esi
  8005e4:	75 05                	jne    8005eb <vprintfmt+0x1a6>
				p = "(null)";
  8005e6:	be 91 1d 80 00       	mov    $0x801d91,%esi
			if (width > 0 && padc != '-')
  8005eb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ef:	7e 6d                	jle    80065e <vprintfmt+0x219>
  8005f1:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8005f5:	74 67                	je     80065e <vprintfmt+0x219>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005fa:	83 ec 08             	sub    $0x8,%esp
  8005fd:	50                   	push   %eax
  8005fe:	56                   	push   %esi
  8005ff:	e8 1e 03 00 00       	call   800922 <strnlen>
  800604:	83 c4 10             	add    $0x10,%esp
  800607:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80060a:	eb 16                	jmp    800622 <vprintfmt+0x1dd>
					putch(padc, putdat);
  80060c:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800610:	83 ec 08             	sub    $0x8,%esp
  800613:	ff 75 0c             	pushl  0xc(%ebp)
  800616:	50                   	push   %eax
  800617:	8b 45 08             	mov    0x8(%ebp),%eax
  80061a:	ff d0                	call   *%eax
  80061c:	83 c4 10             	add    $0x10,%esp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80061f:	ff 4d e4             	decl   -0x1c(%ebp)
  800622:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800626:	7f e4                	jg     80060c <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800628:	eb 34                	jmp    80065e <vprintfmt+0x219>
				if (altflag && (ch < ' ' || ch > '~'))
  80062a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062e:	74 1c                	je     80064c <vprintfmt+0x207>
  800630:	83 fb 1f             	cmp    $0x1f,%ebx
  800633:	7e 05                	jle    80063a <vprintfmt+0x1f5>
  800635:	83 fb 7e             	cmp    $0x7e,%ebx
  800638:	7e 12                	jle    80064c <vprintfmt+0x207>
					putch('?', putdat);
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	ff 75 0c             	pushl  0xc(%ebp)
  800640:	6a 3f                	push   $0x3f
  800642:	8b 45 08             	mov    0x8(%ebp),%eax
  800645:	ff d0                	call   *%eax
  800647:	83 c4 10             	add    $0x10,%esp
  80064a:	eb 0f                	jmp    80065b <vprintfmt+0x216>
				else
					putch(ch, putdat);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	ff 75 0c             	pushl  0xc(%ebp)
  800652:	53                   	push   %ebx
  800653:	8b 45 08             	mov    0x8(%ebp),%eax
  800656:	ff d0                	call   *%eax
  800658:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065b:	ff 4d e4             	decl   -0x1c(%ebp)
  80065e:	89 f0                	mov    %esi,%eax
  800660:	8d 70 01             	lea    0x1(%eax),%esi
  800663:	8a 00                	mov    (%eax),%al
  800665:	0f be d8             	movsbl %al,%ebx
  800668:	85 db                	test   %ebx,%ebx
  80066a:	74 24                	je     800690 <vprintfmt+0x24b>
  80066c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800670:	78 b8                	js     80062a <vprintfmt+0x1e5>
  800672:	ff 4d e0             	decl   -0x20(%ebp)
  800675:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800679:	79 af                	jns    80062a <vprintfmt+0x1e5>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80067b:	eb 13                	jmp    800690 <vprintfmt+0x24b>
				putch(' ', putdat);
  80067d:	83 ec 08             	sub    $0x8,%esp
  800680:	ff 75 0c             	pushl  0xc(%ebp)
  800683:	6a 20                	push   $0x20
  800685:	8b 45 08             	mov    0x8(%ebp),%eax
  800688:	ff d0                	call   *%eax
  80068a:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068d:	ff 4d e4             	decl   -0x1c(%ebp)
  800690:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800694:	7f e7                	jg     80067d <vprintfmt+0x238>
				putch(' ', putdat);
			break;
  800696:	e9 78 01 00 00       	jmp    800813 <vprintfmt+0x3ce>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	ff 75 e8             	pushl  -0x18(%ebp)
  8006a1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a4:	50                   	push   %eax
  8006a5:	e8 3c fd ff ff       	call   8003e6 <getint>
  8006aa:	83 c4 10             	add    $0x10,%esp
  8006ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006b0:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8006b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006b9:	85 d2                	test   %edx,%edx
  8006bb:	79 23                	jns    8006e0 <vprintfmt+0x29b>
				putch('-', putdat);
  8006bd:	83 ec 08             	sub    $0x8,%esp
  8006c0:	ff 75 0c             	pushl  0xc(%ebp)
  8006c3:	6a 2d                	push   $0x2d
  8006c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c8:	ff d0                	call   *%eax
  8006ca:	83 c4 10             	add    $0x10,%esp
				num = -(long long) num;
  8006cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006d3:	f7 d8                	neg    %eax
  8006d5:	83 d2 00             	adc    $0x0,%edx
  8006d8:	f7 da                	neg    %edx
  8006da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006dd:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8006e0:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006e7:	e9 bc 00 00 00       	jmp    8007a8 <vprintfmt+0x363>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ec:	83 ec 08             	sub    $0x8,%esp
  8006ef:	ff 75 e8             	pushl  -0x18(%ebp)
  8006f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f5:	50                   	push   %eax
  8006f6:	e8 84 fc ff ff       	call   80037f <getuint>
  8006fb:	83 c4 10             	add    $0x10,%esp
  8006fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800701:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800704:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80070b:	e9 98 00 00 00       	jmp    8007a8 <vprintfmt+0x363>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	ff 75 0c             	pushl  0xc(%ebp)
  800716:	6a 58                	push   $0x58
  800718:	8b 45 08             	mov    0x8(%ebp),%eax
  80071b:	ff d0                	call   *%eax
  80071d:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800720:	83 ec 08             	sub    $0x8,%esp
  800723:	ff 75 0c             	pushl  0xc(%ebp)
  800726:	6a 58                	push   $0x58
  800728:	8b 45 08             	mov    0x8(%ebp),%eax
  80072b:	ff d0                	call   *%eax
  80072d:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800730:	83 ec 08             	sub    $0x8,%esp
  800733:	ff 75 0c             	pushl  0xc(%ebp)
  800736:	6a 58                	push   $0x58
  800738:	8b 45 08             	mov    0x8(%ebp),%eax
  80073b:	ff d0                	call   *%eax
  80073d:	83 c4 10             	add    $0x10,%esp
			break;
  800740:	e9 ce 00 00 00       	jmp    800813 <vprintfmt+0x3ce>

		// pointer
		case 'p':
			putch('0', putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	ff 75 0c             	pushl  0xc(%ebp)
  80074b:	6a 30                	push   $0x30
  80074d:	8b 45 08             	mov    0x8(%ebp),%eax
  800750:	ff d0                	call   *%eax
  800752:	83 c4 10             	add    $0x10,%esp
			putch('x', putdat);
  800755:	83 ec 08             	sub    $0x8,%esp
  800758:	ff 75 0c             	pushl  0xc(%ebp)
  80075b:	6a 78                	push   $0x78
  80075d:	8b 45 08             	mov    0x8(%ebp),%eax
  800760:	ff d0                	call   *%eax
  800762:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)
				(uint32) va_arg(ap, void *);
  800765:	8b 45 14             	mov    0x14(%ebp),%eax
  800768:	83 c0 04             	add    $0x4,%eax
  80076b:	89 45 14             	mov    %eax,0x14(%ebp)
  80076e:	8b 45 14             	mov    0x14(%ebp),%eax
  800771:	83 e8 04             	sub    $0x4,%eax
  800774:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800776:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800779:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uint32) va_arg(ap, void *);
			base = 16;
  800780:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800787:	eb 1f                	jmp    8007a8 <vprintfmt+0x363>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800789:	83 ec 08             	sub    $0x8,%esp
  80078c:	ff 75 e8             	pushl  -0x18(%ebp)
  80078f:	8d 45 14             	lea    0x14(%ebp),%eax
  800792:	50                   	push   %eax
  800793:	e8 e7 fb ff ff       	call   80037f <getuint>
  800798:	83 c4 10             	add    $0x10,%esp
  80079b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80079e:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8007a1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a8:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8007ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007af:	83 ec 04             	sub    $0x4,%esp
  8007b2:	52                   	push   %edx
  8007b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007b6:	50                   	push   %eax
  8007b7:	ff 75 f4             	pushl  -0xc(%ebp)
  8007ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8007bd:	ff 75 0c             	pushl  0xc(%ebp)
  8007c0:	ff 75 08             	pushl  0x8(%ebp)
  8007c3:	e8 00 fb ff ff       	call   8002c8 <printnum>
  8007c8:	83 c4 20             	add    $0x20,%esp
			break;
  8007cb:	eb 46                	jmp    800813 <vprintfmt+0x3ce>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007cd:	83 ec 08             	sub    $0x8,%esp
  8007d0:	ff 75 0c             	pushl  0xc(%ebp)
  8007d3:	53                   	push   %ebx
  8007d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d7:	ff d0                	call   *%eax
  8007d9:	83 c4 10             	add    $0x10,%esp
			break;
  8007dc:	eb 35                	jmp    800813 <vprintfmt+0x3ce>

		/**********************************/
		/*2023*/
		// DON'T Print Program Name & UD
		case '~':
			printProgName = 0;
  8007de:	c6 05 08 30 80 00 00 	movb   $0x0,0x803008
			break;
  8007e5:	eb 2c                	jmp    800813 <vprintfmt+0x3ce>
		// Print Program Name & UD
		case '@':
			printProgName = 1;
  8007e7:	c6 05 08 30 80 00 01 	movb   $0x1,0x803008
			break;
  8007ee:	eb 23                	jmp    800813 <vprintfmt+0x3ce>
		/**********************************/

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007f0:	83 ec 08             	sub    $0x8,%esp
  8007f3:	ff 75 0c             	pushl  0xc(%ebp)
  8007f6:	6a 25                	push   $0x25
  8007f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fb:	ff d0                	call   *%eax
  8007fd:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800800:	ff 4d 10             	decl   0x10(%ebp)
  800803:	eb 03                	jmp    800808 <vprintfmt+0x3c3>
  800805:	ff 4d 10             	decl   0x10(%ebp)
  800808:	8b 45 10             	mov    0x10(%ebp),%eax
  80080b:	48                   	dec    %eax
  80080c:	8a 00                	mov    (%eax),%al
  80080e:	3c 25                	cmp    $0x25,%al
  800810:	75 f3                	jne    800805 <vprintfmt+0x3c0>
				/* do nothing */;
			break;
  800812:	90                   	nop
		}
	}
  800813:	e9 35 fc ff ff       	jmp    80044d <vprintfmt+0x8>
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
  800818:	90                   	nop
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800819:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80081c:	5b                   	pop    %ebx
  80081d:	5e                   	pop    %esi
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800826:	8d 45 10             	lea    0x10(%ebp),%eax
  800829:	83 c0 04             	add    $0x4,%eax
  80082c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80082f:	8b 45 10             	mov    0x10(%ebp),%eax
  800832:	ff 75 f4             	pushl  -0xc(%ebp)
  800835:	50                   	push   %eax
  800836:	ff 75 0c             	pushl  0xc(%ebp)
  800839:	ff 75 08             	pushl  0x8(%ebp)
  80083c:	e8 04 fc ff ff       	call   800445 <vprintfmt>
  800841:	83 c4 10             	add    $0x10,%esp
	va_end(ap);
}
  800844:	90                   	nop
  800845:	c9                   	leave  
  800846:	c3                   	ret    

00800847 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  80084a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084d:	8b 40 08             	mov    0x8(%eax),%eax
  800850:	8d 50 01             	lea    0x1(%eax),%edx
  800853:	8b 45 0c             	mov    0xc(%ebp),%eax
  800856:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800859:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085c:	8b 10                	mov    (%eax),%edx
  80085e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800861:	8b 40 04             	mov    0x4(%eax),%eax
  800864:	39 c2                	cmp    %eax,%edx
  800866:	73 12                	jae    80087a <sprintputch+0x33>
		*b->buf++ = ch;
  800868:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086b:	8b 00                	mov    (%eax),%eax
  80086d:	8d 48 01             	lea    0x1(%eax),%ecx
  800870:	8b 55 0c             	mov    0xc(%ebp),%edx
  800873:	89 0a                	mov    %ecx,(%edx)
  800875:	8b 55 08             	mov    0x8(%ebp),%edx
  800878:	88 10                	mov    %dl,(%eax)
}
  80087a:	90                   	nop
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	83 ec 18             	sub    $0x18,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800883:	8b 45 08             	mov    0x8(%ebp),%eax
  800886:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800889:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088c:	8d 50 ff             	lea    -0x1(%eax),%edx
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	01 d0                	add    %edx,%eax
  800894:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800897:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80089e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8008a2:	74 06                	je     8008aa <vsnprintf+0x2d>
  8008a4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008a8:	7f 07                	jg     8008b1 <vsnprintf+0x34>
		return -E_INVAL;
  8008aa:	b8 03 00 00 00       	mov    $0x3,%eax
  8008af:	eb 20                	jmp    8008d1 <vsnprintf+0x54>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008b1:	ff 75 14             	pushl  0x14(%ebp)
  8008b4:	ff 75 10             	pushl  0x10(%ebp)
  8008b7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ba:	50                   	push   %eax
  8008bb:	68 47 08 80 00       	push   $0x800847
  8008c0:	e8 80 fb ff ff       	call   800445 <vprintfmt>
  8008c5:	83 c4 10             	add    $0x10,%esp

	// null terminate the buffer
	*b.buf = '\0';
  8008c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008cb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008d1:	c9                   	leave  
  8008d2:	c3                   	ret    

008008d3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008d9:	8d 45 10             	lea    0x10(%ebp),%eax
  8008dc:	83 c0 04             	add    $0x4,%eax
  8008df:	89 45 f4             	mov    %eax,-0xc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8008e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8008e8:	50                   	push   %eax
  8008e9:	ff 75 0c             	pushl  0xc(%ebp)
  8008ec:	ff 75 08             	pushl  0x8(%ebp)
  8008ef:	e8 89 ff ff ff       	call   80087d <vsnprintf>
  8008f4:	83 c4 10             	add    $0x10,%esp
  8008f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return rc;
  8008fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8008fd:	c9                   	leave  
  8008fe:	c3                   	ret    

008008ff <strlen>:
#include <inc/string.h>
#include <inc/assert.h>

int
strlen(const char *s)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800905:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80090c:	eb 06                	jmp    800914 <strlen+0x15>
		n++;
  80090e:	ff 45 fc             	incl   -0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800911:	ff 45 08             	incl   0x8(%ebp)
  800914:	8b 45 08             	mov    0x8(%ebp),%eax
  800917:	8a 00                	mov    (%eax),%al
  800919:	84 c0                	test   %al,%al
  80091b:	75 f1                	jne    80090e <strlen+0xf>
		n++;
	return n;
  80091d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800920:	c9                   	leave  
  800921:	c3                   	ret    

00800922 <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800928:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80092f:	eb 09                	jmp    80093a <strnlen+0x18>
		n++;
  800931:	ff 45 fc             	incl   -0x4(%ebp)
int
strnlen(const char *s, uint32 size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800934:	ff 45 08             	incl   0x8(%ebp)
  800937:	ff 4d 0c             	decl   0xc(%ebp)
  80093a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80093e:	74 09                	je     800949 <strnlen+0x27>
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	8a 00                	mov    (%eax),%al
  800945:	84 c0                	test   %al,%al
  800947:	75 e8                	jne    800931 <strnlen+0xf>
		n++;
	return n;
  800949:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80094c:	c9                   	leave  
  80094d:	c3                   	ret    

0080094e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  80095a:	90                   	nop
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	8d 50 01             	lea    0x1(%eax),%edx
  800961:	89 55 08             	mov    %edx,0x8(%ebp)
  800964:	8b 55 0c             	mov    0xc(%ebp),%edx
  800967:	8d 4a 01             	lea    0x1(%edx),%ecx
  80096a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  80096d:	8a 12                	mov    (%edx),%dl
  80096f:	88 10                	mov    %dl,(%eax)
  800971:	8a 00                	mov    (%eax),%al
  800973:	84 c0                	test   %al,%al
  800975:	75 e4                	jne    80095b <strcpy+0xd>
		/* do nothing */;
	return ret;
  800977:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80097a:	c9                   	leave  
  80097b:	c3                   	ret    

0080097c <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	83 ec 10             	sub    $0x10,%esp
	uint32 i;
	char *ret;

	ret = dst;
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800988:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80098f:	eb 1f                	jmp    8009b0 <strncpy+0x34>
		*dst++ = *src;
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	8d 50 01             	lea    0x1(%eax),%edx
  800997:	89 55 08             	mov    %edx,0x8(%ebp)
  80099a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099d:	8a 12                	mov    (%edx),%dl
  80099f:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8009a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a4:	8a 00                	mov    (%eax),%al
  8009a6:	84 c0                	test   %al,%al
  8009a8:	74 03                	je     8009ad <strncpy+0x31>
			src++;
  8009aa:	ff 45 0c             	incl   0xc(%ebp)
strncpy(char *dst, const char *src, uint32 size) {
	uint32 i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ad:	ff 45 fc             	incl   -0x4(%ebp)
  8009b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009b3:	3b 45 10             	cmp    0x10(%ebp),%eax
  8009b6:	72 d9                	jb     800991 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8009b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8009bb:	c9                   	leave  
  8009bc:	c3                   	ret    

008009bd <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  8009c9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009cd:	74 30                	je     8009ff <strlcpy+0x42>
		while (--size > 0 && *src != '\0')
  8009cf:	eb 16                	jmp    8009e7 <strlcpy+0x2a>
			*dst++ = *src++;
  8009d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d4:	8d 50 01             	lea    0x1(%eax),%edx
  8009d7:	89 55 08             	mov    %edx,0x8(%ebp)
  8009da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009dd:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009e0:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8009e3:	8a 12                	mov    (%edx),%dl
  8009e5:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009e7:	ff 4d 10             	decl   0x10(%ebp)
  8009ea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009ee:	74 09                	je     8009f9 <strlcpy+0x3c>
  8009f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f3:	8a 00                	mov    (%eax),%al
  8009f5:	84 c0                	test   %al,%al
  8009f7:	75 d8                	jne    8009d1 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800a02:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a05:	29 c2                	sub    %eax,%edx
  800a07:	89 d0                	mov    %edx,%eax
}
  800a09:	c9                   	leave  
  800a0a:	c3                   	ret    

00800a0b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800a0e:	eb 06                	jmp    800a16 <strcmp+0xb>
		p++, q++;
  800a10:	ff 45 08             	incl   0x8(%ebp)
  800a13:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a16:	8b 45 08             	mov    0x8(%ebp),%eax
  800a19:	8a 00                	mov    (%eax),%al
  800a1b:	84 c0                	test   %al,%al
  800a1d:	74 0e                	je     800a2d <strcmp+0x22>
  800a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a22:	8a 10                	mov    (%eax),%dl
  800a24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a27:	8a 00                	mov    (%eax),%al
  800a29:	38 c2                	cmp    %al,%dl
  800a2b:	74 e3                	je     800a10 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a30:	8a 00                	mov    (%eax),%al
  800a32:	0f b6 d0             	movzbl %al,%edx
  800a35:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a38:	8a 00                	mov    (%eax),%al
  800a3a:	0f b6 c0             	movzbl %al,%eax
  800a3d:	29 c2                	sub    %eax,%edx
  800a3f:	89 d0                	mov    %edx,%eax
}
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800a46:	eb 09                	jmp    800a51 <strncmp+0xe>
		n--, p++, q++;
  800a48:	ff 4d 10             	decl   0x10(%ebp)
  800a4b:	ff 45 08             	incl   0x8(%ebp)
  800a4e:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint32 n)
{
	while (n > 0 && *p && *p == *q)
  800a51:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a55:	74 17                	je     800a6e <strncmp+0x2b>
  800a57:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5a:	8a 00                	mov    (%eax),%al
  800a5c:	84 c0                	test   %al,%al
  800a5e:	74 0e                	je     800a6e <strncmp+0x2b>
  800a60:	8b 45 08             	mov    0x8(%ebp),%eax
  800a63:	8a 10                	mov    (%eax),%dl
  800a65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a68:	8a 00                	mov    (%eax),%al
  800a6a:	38 c2                	cmp    %al,%dl
  800a6c:	74 da                	je     800a48 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800a6e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a72:	75 07                	jne    800a7b <strncmp+0x38>
		return 0;
  800a74:	b8 00 00 00 00       	mov    $0x0,%eax
  800a79:	eb 14                	jmp    800a8f <strncmp+0x4c>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	8a 00                	mov    (%eax),%al
  800a80:	0f b6 d0             	movzbl %al,%edx
  800a83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a86:	8a 00                	mov    (%eax),%al
  800a88:	0f b6 c0             	movzbl %al,%eax
  800a8b:	29 c2                	sub    %eax,%edx
  800a8d:	89 d0                	mov    %edx,%eax
}
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    

00800a91 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	83 ec 04             	sub    $0x4,%esp
  800a97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9a:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a9d:	eb 12                	jmp    800ab1 <strchr+0x20>
		if (*s == c)
  800a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa2:	8a 00                	mov    (%eax),%al
  800aa4:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800aa7:	75 05                	jne    800aae <strchr+0x1d>
			return (char *) s;
  800aa9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aac:	eb 11                	jmp    800abf <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aae:	ff 45 08             	incl   0x8(%ebp)
  800ab1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab4:	8a 00                	mov    (%eax),%al
  800ab6:	84 c0                	test   %al,%al
  800ab8:	75 e5                	jne    800a9f <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800aba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800abf:	c9                   	leave  
  800ac0:	c3                   	ret    

00800ac1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	83 ec 04             	sub    $0x4,%esp
  800ac7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aca:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800acd:	eb 0d                	jmp    800adc <strfind+0x1b>
		if (*s == c)
  800acf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad2:	8a 00                	mov    (%eax),%al
  800ad4:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ad7:	74 0e                	je     800ae7 <strfind+0x26>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ad9:	ff 45 08             	incl   0x8(%ebp)
  800adc:	8b 45 08             	mov    0x8(%ebp),%eax
  800adf:	8a 00                	mov    (%eax),%al
  800ae1:	84 c0                	test   %al,%al
  800ae3:	75 ea                	jne    800acf <strfind+0xe>
  800ae5:	eb 01                	jmp    800ae8 <strfind+0x27>
		if (*s == c)
			break;
  800ae7:	90                   	nop
	return (char *) s;
  800ae8:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800aeb:	c9                   	leave  
  800aec:	c3                   	ret    

00800aed <memset>:


void *
memset(void *v, int c, uint32 n)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	83 ec 10             	sub    $0x10,%esp
	char *p;
	int m;

	p = v;
  800af3:	8b 45 08             	mov    0x8(%ebp),%eax
  800af6:	89 45 fc             	mov    %eax,-0x4(%ebp)
	m = n;
  800af9:	8b 45 10             	mov    0x10(%ebp),%eax
  800afc:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (--m >= 0)
  800aff:	eb 0e                	jmp    800b0f <memset+0x22>
		*p++ = c;
  800b01:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b04:	8d 50 01             	lea    0x1(%eax),%edx
  800b07:	89 55 fc             	mov    %edx,-0x4(%ebp)
  800b0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0d:	88 10                	mov    %dl,(%eax)
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800b0f:	ff 4d f8             	decl   -0x8(%ebp)
  800b12:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
  800b16:	79 e9                	jns    800b01 <memset+0x14>
		*p++ = c;

	return v;
  800b18:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b1b:	c9                   	leave  
  800b1c:	c3                   	ret    

00800b1d <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b26:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800b29:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2c:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
  800b2f:	eb 16                	jmp    800b47 <memcpy+0x2a>
		*d++ = *s++;
  800b31:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800b34:	8d 50 01             	lea    0x1(%eax),%edx
  800b37:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800b3a:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800b3d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800b40:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800b43:	8a 12                	mov    (%edx),%dl
  800b45:	88 10                	mov    %dl,(%eax)
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800b47:	8b 45 10             	mov    0x10(%ebp),%eax
  800b4a:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b4d:	89 55 10             	mov    %edx,0x10(%ebp)
  800b50:	85 c0                	test   %eax,%eax
  800b52:	75 dd                	jne    800b31 <memcpy+0x14>
		*d++ = *s++;

	return dst;
  800b54:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b57:	c9                   	leave  
  800b58:	c3                   	ret    

00800b59 <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b62:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800b65:	8b 45 08             	mov    0x8(%ebp),%eax
  800b68:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (s < d && s + n > d) {
  800b6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b6e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800b71:	73 50                	jae    800bc3 <memmove+0x6a>
  800b73:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800b76:	8b 45 10             	mov    0x10(%ebp),%eax
  800b79:	01 d0                	add    %edx,%eax
  800b7b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800b7e:	76 43                	jbe    800bc3 <memmove+0x6a>
		s += n;
  800b80:	8b 45 10             	mov    0x10(%ebp),%eax
  800b83:	01 45 fc             	add    %eax,-0x4(%ebp)
		d += n;
  800b86:	8b 45 10             	mov    0x10(%ebp),%eax
  800b89:	01 45 f8             	add    %eax,-0x8(%ebp)
		while (n-- > 0)
  800b8c:	eb 10                	jmp    800b9e <memmove+0x45>
			*--d = *--s;
  800b8e:	ff 4d f8             	decl   -0x8(%ebp)
  800b91:	ff 4d fc             	decl   -0x4(%ebp)
  800b94:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b97:	8a 10                	mov    (%eax),%dl
  800b99:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800b9c:	88 10                	mov    %dl,(%eax)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800b9e:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba1:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ba4:	89 55 10             	mov    %edx,0x10(%ebp)
  800ba7:	85 c0                	test   %eax,%eax
  800ba9:	75 e3                	jne    800b8e <memmove+0x35>
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bab:	eb 23                	jmp    800bd0 <memmove+0x77>
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800bad:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bb0:	8d 50 01             	lea    0x1(%eax),%edx
  800bb3:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800bb6:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800bb9:	8d 4a 01             	lea    0x1(%edx),%ecx
  800bbc:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800bbf:	8a 12                	mov    (%edx),%dl
  800bc1:	88 10                	mov    %dl,(%eax)
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800bc3:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc6:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bc9:	89 55 10             	mov    %edx,0x10(%ebp)
  800bcc:	85 c0                	test   %eax,%eax
  800bce:	75 dd                	jne    800bad <memmove+0x54>
			*d++ = *s++;

	return dst;
  800bd0:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bd3:	c9                   	leave  
  800bd4:	c3                   	ret    

00800bd5 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	83 ec 10             	sub    $0x10,%esp
	const uint8 *s1 = (const uint8 *) v1;
  800bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bde:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8 *s2 = (const uint8 *) v2;
  800be1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be4:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800be7:	eb 2a                	jmp    800c13 <memcmp+0x3e>
		if (*s1 != *s2)
  800be9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bec:	8a 10                	mov    (%eax),%dl
  800bee:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bf1:	8a 00                	mov    (%eax),%al
  800bf3:	38 c2                	cmp    %al,%dl
  800bf5:	74 16                	je     800c0d <memcmp+0x38>
			return (int) *s1 - (int) *s2;
  800bf7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bfa:	8a 00                	mov    (%eax),%al
  800bfc:	0f b6 d0             	movzbl %al,%edx
  800bff:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c02:	8a 00                	mov    (%eax),%al
  800c04:	0f b6 c0             	movzbl %al,%eax
  800c07:	29 c2                	sub    %eax,%edx
  800c09:	89 d0                	mov    %edx,%eax
  800c0b:	eb 18                	jmp    800c25 <memcmp+0x50>
		s1++, s2++;
  800c0d:	ff 45 fc             	incl   -0x4(%ebp)
  800c10:	ff 45 f8             	incl   -0x8(%ebp)
memcmp(const void *v1, const void *v2, uint32 n)
{
	const uint8 *s1 = (const uint8 *) v1;
	const uint8 *s2 = (const uint8 *) v2;

	while (n-- > 0) {
  800c13:	8b 45 10             	mov    0x10(%ebp),%eax
  800c16:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c19:	89 55 10             	mov    %edx,0x10(%ebp)
  800c1c:	85 c0                	test   %eax,%eax
  800c1e:	75 c9                	jne    800be9 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c20:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c25:	c9                   	leave  
  800c26:	c3                   	ret    

00800c27 <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c30:	8b 45 10             	mov    0x10(%ebp),%eax
  800c33:	01 d0                	add    %edx,%eax
  800c35:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c38:	eb 15                	jmp    800c4f <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3d:	8a 00                	mov    (%eax),%al
  800c3f:	0f b6 d0             	movzbl %al,%edx
  800c42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c45:	0f b6 c0             	movzbl %al,%eax
  800c48:	39 c2                	cmp    %eax,%edx
  800c4a:	74 0d                	je     800c59 <memfind+0x32>

void *
memfind(const void *s, int c, uint32 n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c4c:	ff 45 08             	incl   0x8(%ebp)
  800c4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c52:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800c55:	72 e3                	jb     800c3a <memfind+0x13>
  800c57:	eb 01                	jmp    800c5a <memfind+0x33>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
  800c59:	90                   	nop
	return (void *) s;
  800c5a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c5d:	c9                   	leave  
  800c5e:	c3                   	ret    

00800c5f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800c65:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800c6c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c73:	eb 03                	jmp    800c78 <strtol+0x19>
		s++;
  800c75:	ff 45 08             	incl   0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c78:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7b:	8a 00                	mov    (%eax),%al
  800c7d:	3c 20                	cmp    $0x20,%al
  800c7f:	74 f4                	je     800c75 <strtol+0x16>
  800c81:	8b 45 08             	mov    0x8(%ebp),%eax
  800c84:	8a 00                	mov    (%eax),%al
  800c86:	3c 09                	cmp    $0x9,%al
  800c88:	74 eb                	je     800c75 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8d:	8a 00                	mov    (%eax),%al
  800c8f:	3c 2b                	cmp    $0x2b,%al
  800c91:	75 05                	jne    800c98 <strtol+0x39>
		s++;
  800c93:	ff 45 08             	incl   0x8(%ebp)
  800c96:	eb 13                	jmp    800cab <strtol+0x4c>
	else if (*s == '-')
  800c98:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9b:	8a 00                	mov    (%eax),%al
  800c9d:	3c 2d                	cmp    $0x2d,%al
  800c9f:	75 0a                	jne    800cab <strtol+0x4c>
		s++, neg = 1;
  800ca1:	ff 45 08             	incl   0x8(%ebp)
  800ca4:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800caf:	74 06                	je     800cb7 <strtol+0x58>
  800cb1:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800cb5:	75 20                	jne    800cd7 <strtol+0x78>
  800cb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cba:	8a 00                	mov    (%eax),%al
  800cbc:	3c 30                	cmp    $0x30,%al
  800cbe:	75 17                	jne    800cd7 <strtol+0x78>
  800cc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc3:	40                   	inc    %eax
  800cc4:	8a 00                	mov    (%eax),%al
  800cc6:	3c 78                	cmp    $0x78,%al
  800cc8:	75 0d                	jne    800cd7 <strtol+0x78>
		s += 2, base = 16;
  800cca:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800cce:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800cd5:	eb 28                	jmp    800cff <strtol+0xa0>
	else if (base == 0 && s[0] == '0')
  800cd7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cdb:	75 15                	jne    800cf2 <strtol+0x93>
  800cdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce0:	8a 00                	mov    (%eax),%al
  800ce2:	3c 30                	cmp    $0x30,%al
  800ce4:	75 0c                	jne    800cf2 <strtol+0x93>
		s++, base = 8;
  800ce6:	ff 45 08             	incl   0x8(%ebp)
  800ce9:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800cf0:	eb 0d                	jmp    800cff <strtol+0xa0>
	else if (base == 0)
  800cf2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cf6:	75 07                	jne    800cff <strtol+0xa0>
		base = 10;
  800cf8:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cff:	8b 45 08             	mov    0x8(%ebp),%eax
  800d02:	8a 00                	mov    (%eax),%al
  800d04:	3c 2f                	cmp    $0x2f,%al
  800d06:	7e 19                	jle    800d21 <strtol+0xc2>
  800d08:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0b:	8a 00                	mov    (%eax),%al
  800d0d:	3c 39                	cmp    $0x39,%al
  800d0f:	7f 10                	jg     800d21 <strtol+0xc2>
			dig = *s - '0';
  800d11:	8b 45 08             	mov    0x8(%ebp),%eax
  800d14:	8a 00                	mov    (%eax),%al
  800d16:	0f be c0             	movsbl %al,%eax
  800d19:	83 e8 30             	sub    $0x30,%eax
  800d1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d1f:	eb 42                	jmp    800d63 <strtol+0x104>
		else if (*s >= 'a' && *s <= 'z')
  800d21:	8b 45 08             	mov    0x8(%ebp),%eax
  800d24:	8a 00                	mov    (%eax),%al
  800d26:	3c 60                	cmp    $0x60,%al
  800d28:	7e 19                	jle    800d43 <strtol+0xe4>
  800d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2d:	8a 00                	mov    (%eax),%al
  800d2f:	3c 7a                	cmp    $0x7a,%al
  800d31:	7f 10                	jg     800d43 <strtol+0xe4>
			dig = *s - 'a' + 10;
  800d33:	8b 45 08             	mov    0x8(%ebp),%eax
  800d36:	8a 00                	mov    (%eax),%al
  800d38:	0f be c0             	movsbl %al,%eax
  800d3b:	83 e8 57             	sub    $0x57,%eax
  800d3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d41:	eb 20                	jmp    800d63 <strtol+0x104>
		else if (*s >= 'A' && *s <= 'Z')
  800d43:	8b 45 08             	mov    0x8(%ebp),%eax
  800d46:	8a 00                	mov    (%eax),%al
  800d48:	3c 40                	cmp    $0x40,%al
  800d4a:	7e 39                	jle    800d85 <strtol+0x126>
  800d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4f:	8a 00                	mov    (%eax),%al
  800d51:	3c 5a                	cmp    $0x5a,%al
  800d53:	7f 30                	jg     800d85 <strtol+0x126>
			dig = *s - 'A' + 10;
  800d55:	8b 45 08             	mov    0x8(%ebp),%eax
  800d58:	8a 00                	mov    (%eax),%al
  800d5a:	0f be c0             	movsbl %al,%eax
  800d5d:	83 e8 37             	sub    $0x37,%eax
  800d60:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d66:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d69:	7d 19                	jge    800d84 <strtol+0x125>
			break;
		s++, val = (val * base) + dig;
  800d6b:	ff 45 08             	incl   0x8(%ebp)
  800d6e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d71:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d75:	89 c2                	mov    %eax,%edx
  800d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d7a:	01 d0                	add    %edx,%eax
  800d7c:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800d7f:	e9 7b ff ff ff       	jmp    800cff <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
			break;
  800d84:	90                   	nop
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d85:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d89:	74 08                	je     800d93 <strtol+0x134>
		*endptr = (char *) s;
  800d8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d91:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800d93:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800d97:	74 07                	je     800da0 <strtol+0x141>
  800d99:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d9c:	f7 d8                	neg    %eax
  800d9e:	eb 03                	jmp    800da3 <strtol+0x144>
  800da0:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800da3:	c9                   	leave  
  800da4:	c3                   	ret    

00800da5 <ltostr>:

void
ltostr(long value, char *str)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	83 ec 20             	sub    $0x20,%esp
	int neg = 0;
  800dab:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	int s = 0 ;
  800db2:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// plus/minus sign
	if (value < 0)
  800db9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800dbd:	79 13                	jns    800dd2 <ltostr+0x2d>
	{
		neg = 1;
  800dbf:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
		str[0] = '-';
  800dc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc9:	c6 00 2d             	movb   $0x2d,(%eax)
		value = value * -1 ;
  800dcc:	f7 5d 08             	negl   0x8(%ebp)
		s++ ;
  800dcf:	ff 45 f8             	incl   -0x8(%ebp)
	}
	do
	{
		int mod = value % 10 ;
  800dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800dda:	99                   	cltd   
  800ddb:	f7 f9                	idiv   %ecx
  800ddd:	89 55 ec             	mov    %edx,-0x14(%ebp)
		str[s++] = mod + '0' ;
  800de0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800de3:	8d 50 01             	lea    0x1(%eax),%edx
  800de6:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800de9:	89 c2                	mov    %eax,%edx
  800deb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dee:	01 d0                	add    %edx,%eax
  800df0:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800df3:	83 c2 30             	add    $0x30,%edx
  800df6:	88 10                	mov    %dl,(%eax)
		value = value / 10 ;
  800df8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dfb:	b8 67 66 66 66       	mov    $0x66666667,%eax
  800e00:	f7 e9                	imul   %ecx
  800e02:	c1 fa 02             	sar    $0x2,%edx
  800e05:	89 c8                	mov    %ecx,%eax
  800e07:	c1 f8 1f             	sar    $0x1f,%eax
  800e0a:	29 c2                	sub    %eax,%edx
  800e0c:	89 d0                	mov    %edx,%eax
  800e0e:	89 45 08             	mov    %eax,0x8(%ebp)
	/*2023 FIX el7 :)*/
	//} while (value % 10 != 0);
	} while (value != 0);
  800e11:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800e15:	75 bb                	jne    800dd2 <ltostr+0x2d>

	//reverse the string
	int start = 0 ;
  800e17:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int end = s-1 ;
  800e1e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e21:	48                   	dec    %eax
  800e22:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (neg)
  800e25:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e29:	74 3d                	je     800e68 <ltostr+0xc3>
		start = 1 ;
  800e2b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	while(start<end)
  800e32:	eb 34                	jmp    800e68 <ltostr+0xc3>
	{
		char tmp = str[start] ;
  800e34:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3a:	01 d0                	add    %edx,%eax
  800e3c:	8a 00                	mov    (%eax),%al
  800e3e:	88 45 eb             	mov    %al,-0x15(%ebp)
		str[start] = str[end] ;
  800e41:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e44:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e47:	01 c2                	add    %eax,%edx
  800e49:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800e4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e4f:	01 c8                	add    %ecx,%eax
  800e51:	8a 00                	mov    (%eax),%al
  800e53:	88 02                	mov    %al,(%edx)
		str[end] = tmp;
  800e55:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5b:	01 c2                	add    %eax,%edx
  800e5d:	8a 45 eb             	mov    -0x15(%ebp),%al
  800e60:	88 02                	mov    %al,(%edx)
		start++ ;
  800e62:	ff 45 f4             	incl   -0xc(%ebp)
		end-- ;
  800e65:	ff 4d f0             	decl   -0x10(%ebp)
	//reverse the string
	int start = 0 ;
	int end = s-1 ;
	if (neg)
		start = 1 ;
	while(start<end)
  800e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e6b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800e6e:	7c c4                	jl     800e34 <ltostr+0x8f>
		str[end] = tmp;
		start++ ;
		end-- ;
	}

	str[s] = 0 ;
  800e70:	8b 55 f8             	mov    -0x8(%ebp),%edx
  800e73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e76:	01 d0                	add    %edx,%eax
  800e78:	c6 00 00             	movb   $0x0,(%eax)
	// we don't properly detect overflow!

}
  800e7b:	90                   	nop
  800e7c:	c9                   	leave  
  800e7d:	c3                   	ret    

00800e7e <strcconcat>:

void
strcconcat(const char *str1, const char *str2, char *final)
{
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	83 ec 10             	sub    $0x10,%esp
	int len1 = strlen(str1);
  800e84:	ff 75 08             	pushl  0x8(%ebp)
  800e87:	e8 73 fa ff ff       	call   8008ff <strlen>
  800e8c:	83 c4 04             	add    $0x4,%esp
  800e8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int len2 = strlen(str2);
  800e92:	ff 75 0c             	pushl  0xc(%ebp)
  800e95:	e8 65 fa ff ff       	call   8008ff <strlen>
  800e9a:	83 c4 04             	add    $0x4,%esp
  800e9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int s = 0 ;
  800ea0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for (s=0 ; s < len1 ; s++)
  800ea7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800eae:	eb 17                	jmp    800ec7 <strcconcat+0x49>
		final[s] = str1[s] ;
  800eb0:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800eb3:	8b 45 10             	mov    0x10(%ebp),%eax
  800eb6:	01 c2                	add    %eax,%edx
  800eb8:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  800ebb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebe:	01 c8                	add    %ecx,%eax
  800ec0:	8a 00                	mov    (%eax),%al
  800ec2:	88 02                	mov    %al,(%edx)
strcconcat(const char *str1, const char *str2, char *final)
{
	int len1 = strlen(str1);
	int len2 = strlen(str2);
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
  800ec4:	ff 45 fc             	incl   -0x4(%ebp)
  800ec7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800eca:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  800ecd:	7c e1                	jl     800eb0 <strcconcat+0x32>
		final[s] = str1[s] ;

	int i = 0 ;
  800ecf:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
	for (i=0 ; i < len2 ; i++)
  800ed6:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  800edd:	eb 1f                	jmp    800efe <strcconcat+0x80>
		final[s++] = str2[i] ;
  800edf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ee2:	8d 50 01             	lea    0x1(%eax),%edx
  800ee5:	89 55 fc             	mov    %edx,-0x4(%ebp)
  800ee8:	89 c2                	mov    %eax,%edx
  800eea:	8b 45 10             	mov    0x10(%ebp),%eax
  800eed:	01 c2                	add    %eax,%edx
  800eef:	8b 4d f8             	mov    -0x8(%ebp),%ecx
  800ef2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef5:	01 c8                	add    %ecx,%eax
  800ef7:	8a 00                	mov    (%eax),%al
  800ef9:	88 02                	mov    %al,(%edx)
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
		final[s] = str1[s] ;

	int i = 0 ;
	for (i=0 ; i < len2 ; i++)
  800efb:	ff 45 f8             	incl   -0x8(%ebp)
  800efe:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f01:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800f04:	7c d9                	jl     800edf <strcconcat+0x61>
		final[s++] = str2[i] ;

	final[s] = 0;
  800f06:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800f09:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0c:	01 d0                	add    %edx,%eax
  800f0e:	c6 00 00             	movb   $0x0,(%eax)
}
  800f11:	90                   	nop
  800f12:	c9                   	leave  
  800f13:	c3                   	ret    

00800f14 <strsplit>:
int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  800f17:	8b 45 14             	mov    0x14(%ebp),%eax
  800f1a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	(argv)[*argc] = 0;
  800f20:	8b 45 14             	mov    0x14(%ebp),%eax
  800f23:	8b 00                	mov    (%eax),%eax
  800f25:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f2c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f2f:	01 d0                	add    %edx,%eax
  800f31:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800f37:	eb 0c                	jmp    800f45 <strsplit+0x31>
			*string++ = 0;
  800f39:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3c:	8d 50 01             	lea    0x1(%eax),%edx
  800f3f:	89 55 08             	mov    %edx,0x8(%ebp)
  800f42:	c6 00 00             	movb   $0x0,(%eax)
	*argc = 0;
	(argv)[*argc] = 0;
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800f45:	8b 45 08             	mov    0x8(%ebp),%eax
  800f48:	8a 00                	mov    (%eax),%al
  800f4a:	84 c0                	test   %al,%al
  800f4c:	74 18                	je     800f66 <strsplit+0x52>
  800f4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f51:	8a 00                	mov    (%eax),%al
  800f53:	0f be c0             	movsbl %al,%eax
  800f56:	50                   	push   %eax
  800f57:	ff 75 0c             	pushl  0xc(%ebp)
  800f5a:	e8 32 fb ff ff       	call   800a91 <strchr>
  800f5f:	83 c4 08             	add    $0x8,%esp
  800f62:	85 c0                	test   %eax,%eax
  800f64:	75 d3                	jne    800f39 <strsplit+0x25>
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
  800f66:	8b 45 08             	mov    0x8(%ebp),%eax
  800f69:	8a 00                	mov    (%eax),%al
  800f6b:	84 c0                	test   %al,%al
  800f6d:	74 5a                	je     800fc9 <strsplit+0xb5>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1)
  800f6f:	8b 45 14             	mov    0x14(%ebp),%eax
  800f72:	8b 00                	mov    (%eax),%eax
  800f74:	83 f8 0f             	cmp    $0xf,%eax
  800f77:	75 07                	jne    800f80 <strsplit+0x6c>
		{
			return 0;
  800f79:	b8 00 00 00 00       	mov    $0x0,%eax
  800f7e:	eb 66                	jmp    800fe6 <strsplit+0xd2>
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  800f80:	8b 45 14             	mov    0x14(%ebp),%eax
  800f83:	8b 00                	mov    (%eax),%eax
  800f85:	8d 48 01             	lea    0x1(%eax),%ecx
  800f88:	8b 55 14             	mov    0x14(%ebp),%edx
  800f8b:	89 0a                	mov    %ecx,(%edx)
  800f8d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f94:	8b 45 10             	mov    0x10(%ebp),%eax
  800f97:	01 c2                	add    %eax,%edx
  800f99:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9c:	89 02                	mov    %eax,(%edx)
		while (*string && !strchr(SPLIT_CHARS, *string))
  800f9e:	eb 03                	jmp    800fa3 <strsplit+0x8f>
			string++;
  800fa0:	ff 45 08             	incl   0x8(%ebp)
			return 0;
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
  800fa3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa6:	8a 00                	mov    (%eax),%al
  800fa8:	84 c0                	test   %al,%al
  800faa:	74 8b                	je     800f37 <strsplit+0x23>
  800fac:	8b 45 08             	mov    0x8(%ebp),%eax
  800faf:	8a 00                	mov    (%eax),%al
  800fb1:	0f be c0             	movsbl %al,%eax
  800fb4:	50                   	push   %eax
  800fb5:	ff 75 0c             	pushl  0xc(%ebp)
  800fb8:	e8 d4 fa ff ff       	call   800a91 <strchr>
  800fbd:	83 c4 08             	add    $0x8,%esp
  800fc0:	85 c0                	test   %eax,%eax
  800fc2:	74 dc                	je     800fa0 <strsplit+0x8c>
			string++;
	}
  800fc4:	e9 6e ff ff ff       	jmp    800f37 <strsplit+0x23>
		while (*string && strchr(SPLIT_CHARS, *string))
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
			break;
  800fc9:	90                   	nop
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
			string++;
	}
	(argv)[*argc] = 0;
  800fca:	8b 45 14             	mov    0x14(%ebp),%eax
  800fcd:	8b 00                	mov    (%eax),%eax
  800fcf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800fd6:	8b 45 10             	mov    0x10(%ebp),%eax
  800fd9:	01 d0                	add    %edx,%eax
  800fdb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return 1 ;
  800fe1:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800fe6:	c9                   	leave  
  800fe7:	c3                   	ret    

00800fe8 <str2lower>:


char* str2lower(char *dst, const char *src)
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	83 ec 08             	sub    $0x8,%esp
	//[PROJECT]
	panic("str2lower is not implemented yet!");
  800fee:	83 ec 04             	sub    $0x4,%esp
  800ff1:	68 08 1f 80 00       	push   $0x801f08
  800ff6:	68 3f 01 00 00       	push   $0x13f
  800ffb:	68 2a 1f 80 00       	push   $0x801f2a
  801000:	e8 2e 06 00 00       	call   801633 <_panic>

00801005 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline uint32
syscall(int num, uint32 a1, uint32 a2, uint32 a3, uint32 a4, uint32 a5)
{
  801005:	55                   	push   %ebp
  801006:	89 e5                	mov    %esp,%ebp
  801008:	57                   	push   %edi
  801009:	56                   	push   %esi
  80100a:	53                   	push   %ebx
  80100b:	83 ec 10             	sub    $0x10,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80100e:	8b 45 08             	mov    0x8(%ebp),%eax
  801011:	8b 55 0c             	mov    0xc(%ebp),%edx
  801014:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801017:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80101a:	8b 7d 18             	mov    0x18(%ebp),%edi
  80101d:	8b 75 1c             	mov    0x1c(%ebp),%esi
  801020:	cd 30                	int    $0x30
  801022:	89 45 f0             	mov    %eax,-0x10(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	return ret;
  801025:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  801028:	83 c4 10             	add    $0x10,%esp
  80102b:	5b                   	pop    %ebx
  80102c:	5e                   	pop    %esi
  80102d:	5f                   	pop    %edi
  80102e:	5d                   	pop    %ebp
  80102f:	c3                   	ret    

00801030 <sys_cputs>:

void
sys_cputs(const char *s, uint32 len, uint8 printProgName)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	83 ec 04             	sub    $0x4,%esp
  801036:	8b 45 10             	mov    0x10(%ebp),%eax
  801039:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputs, (uint32) s, len, (uint32)printProgName, 0, 0);
  80103c:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  801040:	8b 45 08             	mov    0x8(%ebp),%eax
  801043:	6a 00                	push   $0x0
  801045:	6a 00                	push   $0x0
  801047:	52                   	push   %edx
  801048:	ff 75 0c             	pushl  0xc(%ebp)
  80104b:	50                   	push   %eax
  80104c:	6a 00                	push   $0x0
  80104e:	e8 b2 ff ff ff       	call   801005 <syscall>
  801053:	83 c4 18             	add    $0x18,%esp
}
  801056:	90                   	nop
  801057:	c9                   	leave  
  801058:	c3                   	ret    

00801059 <sys_cgetc>:

int
sys_cgetc(void)
{
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
  80105c:	6a 00                	push   $0x0
  80105e:	6a 00                	push   $0x0
  801060:	6a 00                	push   $0x0
  801062:	6a 00                	push   $0x0
  801064:	6a 00                	push   $0x0
  801066:	6a 02                	push   $0x2
  801068:	e8 98 ff ff ff       	call   801005 <syscall>
  80106d:	83 c4 18             	add    $0x18,%esp
}
  801070:	c9                   	leave  
  801071:	c3                   	ret    

00801072 <sys_lock_cons>:

void sys_lock_cons(void)
{
  801072:	55                   	push   %ebp
  801073:	89 e5                	mov    %esp,%ebp
	syscall(SYS_lock_cons, 0, 0, 0, 0, 0);
  801075:	6a 00                	push   $0x0
  801077:	6a 00                	push   $0x0
  801079:	6a 00                	push   $0x0
  80107b:	6a 00                	push   $0x0
  80107d:	6a 00                	push   $0x0
  80107f:	6a 03                	push   $0x3
  801081:	e8 7f ff ff ff       	call   801005 <syscall>
  801086:	83 c4 18             	add    $0x18,%esp
}
  801089:	90                   	nop
  80108a:	c9                   	leave  
  80108b:	c3                   	ret    

0080108c <sys_unlock_cons>:
void sys_unlock_cons(void)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
	syscall(SYS_unlock_cons, 0, 0, 0, 0, 0);
  80108f:	6a 00                	push   $0x0
  801091:	6a 00                	push   $0x0
  801093:	6a 00                	push   $0x0
  801095:	6a 00                	push   $0x0
  801097:	6a 00                	push   $0x0
  801099:	6a 04                	push   $0x4
  80109b:	e8 65 ff ff ff       	call   801005 <syscall>
  8010a0:	83 c4 18             	add    $0x18,%esp
}
  8010a3:	90                   	nop
  8010a4:	c9                   	leave  
  8010a5:	c3                   	ret    

008010a6 <__sys_allocate_page>:

int __sys_allocate_page(void *va, int perm)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
  8010a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8010af:	6a 00                	push   $0x0
  8010b1:	6a 00                	push   $0x0
  8010b3:	6a 00                	push   $0x0
  8010b5:	52                   	push   %edx
  8010b6:	50                   	push   %eax
  8010b7:	6a 08                	push   $0x8
  8010b9:	e8 47 ff ff ff       	call   801005 <syscall>
  8010be:	83 c4 18             	add    $0x18,%esp
}
  8010c1:	c9                   	leave  
  8010c2:	c3                   	ret    

008010c3 <__sys_map_frame>:

int __sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	56                   	push   %esi
  8010c7:	53                   	push   %ebx
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
  8010c8:	8b 75 18             	mov    0x18(%ebp),%esi
  8010cb:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d7:	56                   	push   %esi
  8010d8:	53                   	push   %ebx
  8010d9:	51                   	push   %ecx
  8010da:	52                   	push   %edx
  8010db:	50                   	push   %eax
  8010dc:	6a 09                	push   $0x9
  8010de:	e8 22 ff ff ff       	call   801005 <syscall>
  8010e3:	83 c4 18             	add    $0x18,%esp
}
  8010e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010e9:	5b                   	pop    %ebx
  8010ea:	5e                   	pop    %esi
  8010eb:	5d                   	pop    %ebp
  8010ec:	c3                   	ret    

008010ed <__sys_unmap_frame>:

int __sys_unmap_frame(int32 envid, void *va)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
  8010f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f6:	6a 00                	push   $0x0
  8010f8:	6a 00                	push   $0x0
  8010fa:	6a 00                	push   $0x0
  8010fc:	52                   	push   %edx
  8010fd:	50                   	push   %eax
  8010fe:	6a 0a                	push   $0xa
  801100:	e8 00 ff ff ff       	call   801005 <syscall>
  801105:	83 c4 18             	add    $0x18,%esp
}
  801108:	c9                   	leave  
  801109:	c3                   	ret    

0080110a <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  80110a:	55                   	push   %ebp
  80110b:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
  80110d:	6a 00                	push   $0x0
  80110f:	6a 00                	push   $0x0
  801111:	6a 00                	push   $0x0
  801113:	ff 75 0c             	pushl  0xc(%ebp)
  801116:	ff 75 08             	pushl  0x8(%ebp)
  801119:	6a 0b                	push   $0xb
  80111b:	e8 e5 fe ff ff       	call   801005 <syscall>
  801120:	83 c4 18             	add    $0x18,%esp
}
  801123:	c9                   	leave  
  801124:	c3                   	ret    

00801125 <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  801125:	55                   	push   %ebp
  801126:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
  801128:	6a 00                	push   $0x0
  80112a:	6a 00                	push   $0x0
  80112c:	6a 00                	push   $0x0
  80112e:	6a 00                	push   $0x0
  801130:	6a 00                	push   $0x0
  801132:	6a 0c                	push   $0xc
  801134:	e8 cc fe ff ff       	call   801005 <syscall>
  801139:	83 c4 18             	add    $0x18,%esp
}
  80113c:	c9                   	leave  
  80113d:	c3                   	ret    

0080113e <sys_calculate_modified_frames>:
uint32 sys_calculate_modified_frames()
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_modified_frames, 0, 0, 0, 0, 0);
  801141:	6a 00                	push   $0x0
  801143:	6a 00                	push   $0x0
  801145:	6a 00                	push   $0x0
  801147:	6a 00                	push   $0x0
  801149:	6a 00                	push   $0x0
  80114b:	6a 0d                	push   $0xd
  80114d:	e8 b3 fe ff ff       	call   801005 <syscall>
  801152:	83 c4 18             	add    $0x18,%esp
}
  801155:	c9                   	leave  
  801156:	c3                   	ret    

00801157 <sys_calculate_notmod_frames>:

uint32 sys_calculate_notmod_frames()
{
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_notmod_frames, 0, 0, 0, 0, 0);
  80115a:	6a 00                	push   $0x0
  80115c:	6a 00                	push   $0x0
  80115e:	6a 00                	push   $0x0
  801160:	6a 00                	push   $0x0
  801162:	6a 00                	push   $0x0
  801164:	6a 0e                	push   $0xe
  801166:	e8 9a fe ff ff       	call   801005 <syscall>
  80116b:	83 c4 18             	add    $0x18,%esp
}
  80116e:	c9                   	leave  
  80116f:	c3                   	ret    

00801170 <sys_pf_calculate_allocated_pages>:

int sys_pf_calculate_allocated_pages()
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_pf_calc_allocated_pages, 0,0,0,0,0);
  801173:	6a 00                	push   $0x0
  801175:	6a 00                	push   $0x0
  801177:	6a 00                	push   $0x0
  801179:	6a 00                	push   $0x0
  80117b:	6a 00                	push   $0x0
  80117d:	6a 0f                	push   $0xf
  80117f:	e8 81 fe ff ff       	call   801005 <syscall>
  801184:	83 c4 18             	add    $0x18,%esp
}
  801187:	c9                   	leave  
  801188:	c3                   	ret    

00801189 <sys_calculate_pages_tobe_removed_ready_exit>:

int sys_calculate_pages_tobe_removed_ready_exit(uint32 WS_or_MEMORY_flag)
{
  801189:	55                   	push   %ebp
  80118a:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calculate_pages_tobe_removed_ready_exit, WS_or_MEMORY_flag,0,0,0,0);
  80118c:	6a 00                	push   $0x0
  80118e:	6a 00                	push   $0x0
  801190:	6a 00                	push   $0x0
  801192:	6a 00                	push   $0x0
  801194:	ff 75 08             	pushl  0x8(%ebp)
  801197:	6a 10                	push   $0x10
  801199:	e8 67 fe ff ff       	call   801005 <syscall>
  80119e:	83 c4 18             	add    $0x18,%esp
}
  8011a1:	c9                   	leave  
  8011a2:	c3                   	ret    

008011a3 <sys_scarce_memory>:

void sys_scarce_memory()
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
	syscall(SYS_scarce_memory,0,0,0,0,0);
  8011a6:	6a 00                	push   $0x0
  8011a8:	6a 00                	push   $0x0
  8011aa:	6a 00                	push   $0x0
  8011ac:	6a 00                	push   $0x0
  8011ae:	6a 00                	push   $0x0
  8011b0:	6a 11                	push   $0x11
  8011b2:	e8 4e fe ff ff       	call   801005 <syscall>
  8011b7:	83 c4 18             	add    $0x18,%esp
}
  8011ba:	90                   	nop
  8011bb:	c9                   	leave  
  8011bc:	c3                   	ret    

008011bd <sys_cputc>:

void
sys_cputc(const char c)
{
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
  8011c0:	83 ec 04             	sub    $0x4,%esp
  8011c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c6:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputc, (uint32) c, 0, 0, 0, 0);
  8011c9:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  8011cd:	6a 00                	push   $0x0
  8011cf:	6a 00                	push   $0x0
  8011d1:	6a 00                	push   $0x0
  8011d3:	6a 00                	push   $0x0
  8011d5:	50                   	push   %eax
  8011d6:	6a 01                	push   $0x1
  8011d8:	e8 28 fe ff ff       	call   801005 <syscall>
  8011dd:	83 c4 18             	add    $0x18,%esp
}
  8011e0:	90                   	nop
  8011e1:	c9                   	leave  
  8011e2:	c3                   	ret    

008011e3 <sys_clear_ffl>:


//NEW'12: BONUS2 Testing
void
sys_clear_ffl()
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
	syscall(SYS_clearFFL,0, 0, 0, 0, 0);
  8011e6:	6a 00                	push   $0x0
  8011e8:	6a 00                	push   $0x0
  8011ea:	6a 00                	push   $0x0
  8011ec:	6a 00                	push   $0x0
  8011ee:	6a 00                	push   $0x0
  8011f0:	6a 14                	push   $0x14
  8011f2:	e8 0e fe ff ff       	call   801005 <syscall>
  8011f7:	83 c4 18             	add    $0x18,%esp
}
  8011fa:	90                   	nop
  8011fb:	c9                   	leave  
  8011fc:	c3                   	ret    

008011fd <sys_createSharedObject>:

int sys_createSharedObject(char* shareName, uint32 size, uint8 isWritable, void* virtual_address)
{
  8011fd:	55                   	push   %ebp
  8011fe:	89 e5                	mov    %esp,%ebp
  801200:	83 ec 04             	sub    $0x4,%esp
  801203:	8b 45 10             	mov    0x10(%ebp),%eax
  801206:	88 45 fc             	mov    %al,-0x4(%ebp)
	return syscall(SYS_create_shared_object,(uint32)shareName, (uint32)size, isWritable, (uint32)virtual_address,  0);
  801209:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80120c:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  801210:	8b 45 08             	mov    0x8(%ebp),%eax
  801213:	6a 00                	push   $0x0
  801215:	51                   	push   %ecx
  801216:	52                   	push   %edx
  801217:	ff 75 0c             	pushl  0xc(%ebp)
  80121a:	50                   	push   %eax
  80121b:	6a 15                	push   $0x15
  80121d:	e8 e3 fd ff ff       	call   801005 <syscall>
  801222:	83 c4 18             	add    $0x18,%esp
}
  801225:	c9                   	leave  
  801226:	c3                   	ret    

00801227 <sys_getSizeOfSharedObject>:

//2017:
int sys_getSizeOfSharedObject(int32 ownerID, char* shareName)
{
  801227:	55                   	push   %ebp
  801228:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_size_of_shared_object,(uint32) ownerID, (uint32)shareName, 0, 0, 0);
  80122a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122d:	8b 45 08             	mov    0x8(%ebp),%eax
  801230:	6a 00                	push   $0x0
  801232:	6a 00                	push   $0x0
  801234:	6a 00                	push   $0x0
  801236:	52                   	push   %edx
  801237:	50                   	push   %eax
  801238:	6a 16                	push   $0x16
  80123a:	e8 c6 fd ff ff       	call   801005 <syscall>
  80123f:	83 c4 18             	add    $0x18,%esp
}
  801242:	c9                   	leave  
  801243:	c3                   	ret    

00801244 <sys_getSharedObject>:
//==========

int sys_getSharedObject(int32 ownerID, char* shareName, void* virtual_address)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_shared_object,(uint32) ownerID, (uint32)shareName, (uint32)virtual_address, 0, 0);
  801247:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80124a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124d:	8b 45 08             	mov    0x8(%ebp),%eax
  801250:	6a 00                	push   $0x0
  801252:	6a 00                	push   $0x0
  801254:	51                   	push   %ecx
  801255:	52                   	push   %edx
  801256:	50                   	push   %eax
  801257:	6a 17                	push   $0x17
  801259:	e8 a7 fd ff ff       	call   801005 <syscall>
  80125e:	83 c4 18             	add    $0x18,%esp
}
  801261:	c9                   	leave  
  801262:	c3                   	ret    

00801263 <sys_freeSharedObject>:

int sys_freeSharedObject(int32 sharedObjectID, void *startVA)
{
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_free_shared_object,(uint32) sharedObjectID, (uint32) startVA, 0, 0, 0);
  801266:	8b 55 0c             	mov    0xc(%ebp),%edx
  801269:	8b 45 08             	mov    0x8(%ebp),%eax
  80126c:	6a 00                	push   $0x0
  80126e:	6a 00                	push   $0x0
  801270:	6a 00                	push   $0x0
  801272:	52                   	push   %edx
  801273:	50                   	push   %eax
  801274:	6a 18                	push   $0x18
  801276:	e8 8a fd ff ff       	call   801005 <syscall>
  80127b:	83 c4 18             	add    $0x18,%esp
}
  80127e:	c9                   	leave  
  80127f:	c3                   	ret    

00801280 <sys_create_env>:

int sys_create_env(char* programName, unsigned int page_WS_size,unsigned int LRU_second_list_size,unsigned int percent_WS_pages_to_remove)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_create_env,(uint32)programName, (uint32)page_WS_size,(uint32)LRU_second_list_size, (uint32)percent_WS_pages_to_remove, 0);
  801283:	8b 45 08             	mov    0x8(%ebp),%eax
  801286:	6a 00                	push   $0x0
  801288:	ff 75 14             	pushl  0x14(%ebp)
  80128b:	ff 75 10             	pushl  0x10(%ebp)
  80128e:	ff 75 0c             	pushl  0xc(%ebp)
  801291:	50                   	push   %eax
  801292:	6a 19                	push   $0x19
  801294:	e8 6c fd ff ff       	call   801005 <syscall>
  801299:	83 c4 18             	add    $0x18,%esp
}
  80129c:	c9                   	leave  
  80129d:	c3                   	ret    

0080129e <sys_run_env>:

void sys_run_env(int32 envId)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
	syscall(SYS_run_env, (int32)envId, 0, 0, 0, 0);
  8012a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a4:	6a 00                	push   $0x0
  8012a6:	6a 00                	push   $0x0
  8012a8:	6a 00                	push   $0x0
  8012aa:	6a 00                	push   $0x0
  8012ac:	50                   	push   %eax
  8012ad:	6a 1a                	push   $0x1a
  8012af:	e8 51 fd ff ff       	call   801005 <syscall>
  8012b4:	83 c4 18             	add    $0x18,%esp
}
  8012b7:	90                   	nop
  8012b8:	c9                   	leave  
  8012b9:	c3                   	ret    

008012ba <sys_destroy_env>:

int sys_destroy_env(int32  envid)
{
  8012ba:	55                   	push   %ebp
  8012bb:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_destroy_env, envid, 0, 0, 0, 0);
  8012bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c0:	6a 00                	push   $0x0
  8012c2:	6a 00                	push   $0x0
  8012c4:	6a 00                	push   $0x0
  8012c6:	6a 00                	push   $0x0
  8012c8:	50                   	push   %eax
  8012c9:	6a 1b                	push   $0x1b
  8012cb:	e8 35 fd ff ff       	call   801005 <syscall>
  8012d0:	83 c4 18             	add    $0x18,%esp
}
  8012d3:	c9                   	leave  
  8012d4:	c3                   	ret    

008012d5 <sys_getenvid>:

int32 sys_getenvid(void)
{
  8012d5:	55                   	push   %ebp
  8012d6:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
  8012d8:	6a 00                	push   $0x0
  8012da:	6a 00                	push   $0x0
  8012dc:	6a 00                	push   $0x0
  8012de:	6a 00                	push   $0x0
  8012e0:	6a 00                	push   $0x0
  8012e2:	6a 05                	push   $0x5
  8012e4:	e8 1c fd ff ff       	call   801005 <syscall>
  8012e9:	83 c4 18             	add    $0x18,%esp
}
  8012ec:	c9                   	leave  
  8012ed:	c3                   	ret    

008012ee <sys_getenvindex>:

//2017
int32 sys_getenvindex(void)
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvindex, 0, 0, 0, 0, 0);
  8012f1:	6a 00                	push   $0x0
  8012f3:	6a 00                	push   $0x0
  8012f5:	6a 00                	push   $0x0
  8012f7:	6a 00                	push   $0x0
  8012f9:	6a 00                	push   $0x0
  8012fb:	6a 06                	push   $0x6
  8012fd:	e8 03 fd ff ff       	call   801005 <syscall>
  801302:	83 c4 18             	add    $0x18,%esp
}
  801305:	c9                   	leave  
  801306:	c3                   	ret    

00801307 <sys_getparentenvid>:

int32 sys_getparentenvid(void)
{
  801307:	55                   	push   %ebp
  801308:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getparentenvid, 0, 0, 0, 0, 0);
  80130a:	6a 00                	push   $0x0
  80130c:	6a 00                	push   $0x0
  80130e:	6a 00                	push   $0x0
  801310:	6a 00                	push   $0x0
  801312:	6a 00                	push   $0x0
  801314:	6a 07                	push   $0x7
  801316:	e8 ea fc ff ff       	call   801005 <syscall>
  80131b:	83 c4 18             	add    $0x18,%esp
}
  80131e:	c9                   	leave  
  80131f:	c3                   	ret    

00801320 <sys_exit_env>:


void sys_exit_env(void)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
	syscall(SYS_exit_env, 0, 0, 0, 0, 0);
  801323:	6a 00                	push   $0x0
  801325:	6a 00                	push   $0x0
  801327:	6a 00                	push   $0x0
  801329:	6a 00                	push   $0x0
  80132b:	6a 00                	push   $0x0
  80132d:	6a 1c                	push   $0x1c
  80132f:	e8 d1 fc ff ff       	call   801005 <syscall>
  801334:	83 c4 18             	add    $0x18,%esp
}
  801337:	90                   	nop
  801338:	c9                   	leave  
  801339:	c3                   	ret    

0080133a <sys_get_virtual_time>:


struct uint64 sys_get_virtual_time()
{
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
  80133d:	83 ec 10             	sub    $0x10,%esp
	struct uint64 result;
	syscall(SYS_get_virtual_time, (uint32)&(result.low), (uint32)&(result.hi), 0, 0, 0);
  801340:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801343:	8d 50 04             	lea    0x4(%eax),%edx
  801346:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801349:	6a 00                	push   $0x0
  80134b:	6a 00                	push   $0x0
  80134d:	6a 00                	push   $0x0
  80134f:	52                   	push   %edx
  801350:	50                   	push   %eax
  801351:	6a 1d                	push   $0x1d
  801353:	e8 ad fc ff ff       	call   801005 <syscall>
  801358:	83 c4 18             	add    $0x18,%esp
	return result;
  80135b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80135e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801361:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801364:	89 01                	mov    %eax,(%ecx)
  801366:	89 51 04             	mov    %edx,0x4(%ecx)
}
  801369:	8b 45 08             	mov    0x8(%ebp),%eax
  80136c:	c9                   	leave  
  80136d:	c2 04 00             	ret    $0x4

00801370 <sys_move_user_mem>:

// 2014
void sys_move_user_mem(uint32 src_virtual_address, uint32 dst_virtual_address, uint32 size)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
	syscall(SYS_move_user_mem, src_virtual_address, dst_virtual_address, size, 0, 0);
  801373:	6a 00                	push   $0x0
  801375:	6a 00                	push   $0x0
  801377:	ff 75 10             	pushl  0x10(%ebp)
  80137a:	ff 75 0c             	pushl  0xc(%ebp)
  80137d:	ff 75 08             	pushl  0x8(%ebp)
  801380:	6a 13                	push   $0x13
  801382:	e8 7e fc ff ff       	call   801005 <syscall>
  801387:	83 c4 18             	add    $0x18,%esp
	return ;
  80138a:	90                   	nop
}
  80138b:	c9                   	leave  
  80138c:	c3                   	ret    

0080138d <sys_rcr2>:
uint32 sys_rcr2()
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_rcr2, 0, 0, 0, 0, 0);
  801390:	6a 00                	push   $0x0
  801392:	6a 00                	push   $0x0
  801394:	6a 00                	push   $0x0
  801396:	6a 00                	push   $0x0
  801398:	6a 00                	push   $0x0
  80139a:	6a 1e                	push   $0x1e
  80139c:	e8 64 fc ff ff       	call   801005 <syscall>
  8013a1:	83 c4 18             	add    $0x18,%esp
}
  8013a4:	c9                   	leave  
  8013a5:	c3                   	ret    

008013a6 <sys_bypassPageFault>:

void sys_bypassPageFault(uint8 instrLength)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	83 ec 04             	sub    $0x4,%esp
  8013ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8013af:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_bypassPageFault, instrLength, 0, 0, 0, 0);
  8013b2:	0f b6 45 fc          	movzbl -0x4(%ebp),%eax
  8013b6:	6a 00                	push   $0x0
  8013b8:	6a 00                	push   $0x0
  8013ba:	6a 00                	push   $0x0
  8013bc:	6a 00                	push   $0x0
  8013be:	50                   	push   %eax
  8013bf:	6a 1f                	push   $0x1f
  8013c1:	e8 3f fc ff ff       	call   801005 <syscall>
  8013c6:	83 c4 18             	add    $0x18,%esp
	return ;
  8013c9:	90                   	nop
}
  8013ca:	c9                   	leave  
  8013cb:	c3                   	ret    

008013cc <rsttst>:
void rsttst()
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
	syscall(SYS_rsttst, 0, 0, 0, 0, 0);
  8013cf:	6a 00                	push   $0x0
  8013d1:	6a 00                	push   $0x0
  8013d3:	6a 00                	push   $0x0
  8013d5:	6a 00                	push   $0x0
  8013d7:	6a 00                	push   $0x0
  8013d9:	6a 21                	push   $0x21
  8013db:	e8 25 fc ff ff       	call   801005 <syscall>
  8013e0:	83 c4 18             	add    $0x18,%esp
	return ;
  8013e3:	90                   	nop
}
  8013e4:	c9                   	leave  
  8013e5:	c3                   	ret    

008013e6 <tst>:
void tst(uint32 n, uint32 v1, uint32 v2, char c, int inv)
{
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	83 ec 04             	sub    $0x4,%esp
  8013ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ef:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_testNum, n, v1, v2, c, inv);
  8013f2:	8b 55 18             	mov    0x18(%ebp),%edx
  8013f5:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  8013f9:	52                   	push   %edx
  8013fa:	50                   	push   %eax
  8013fb:	ff 75 10             	pushl  0x10(%ebp)
  8013fe:	ff 75 0c             	pushl  0xc(%ebp)
  801401:	ff 75 08             	pushl  0x8(%ebp)
  801404:	6a 20                	push   $0x20
  801406:	e8 fa fb ff ff       	call   801005 <syscall>
  80140b:	83 c4 18             	add    $0x18,%esp
	return ;
  80140e:	90                   	nop
}
  80140f:	c9                   	leave  
  801410:	c3                   	ret    

00801411 <chktst>:
void chktst(uint32 n)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
	syscall(SYS_chktst, n, 0, 0, 0, 0);
  801414:	6a 00                	push   $0x0
  801416:	6a 00                	push   $0x0
  801418:	6a 00                	push   $0x0
  80141a:	6a 00                	push   $0x0
  80141c:	ff 75 08             	pushl  0x8(%ebp)
  80141f:	6a 22                	push   $0x22
  801421:	e8 df fb ff ff       	call   801005 <syscall>
  801426:	83 c4 18             	add    $0x18,%esp
	return ;
  801429:	90                   	nop
}
  80142a:	c9                   	leave  
  80142b:	c3                   	ret    

0080142c <inctst>:

void inctst()
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
	syscall(SYS_inctst, 0, 0, 0, 0, 0);
  80142f:	6a 00                	push   $0x0
  801431:	6a 00                	push   $0x0
  801433:	6a 00                	push   $0x0
  801435:	6a 00                	push   $0x0
  801437:	6a 00                	push   $0x0
  801439:	6a 23                	push   $0x23
  80143b:	e8 c5 fb ff ff       	call   801005 <syscall>
  801440:	83 c4 18             	add    $0x18,%esp
	return ;
  801443:	90                   	nop
}
  801444:	c9                   	leave  
  801445:	c3                   	ret    

00801446 <gettst>:
uint32 gettst()
{
  801446:	55                   	push   %ebp
  801447:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_gettst, 0, 0, 0, 0, 0);
  801449:	6a 00                	push   $0x0
  80144b:	6a 00                	push   $0x0
  80144d:	6a 00                	push   $0x0
  80144f:	6a 00                	push   $0x0
  801451:	6a 00                	push   $0x0
  801453:	6a 24                	push   $0x24
  801455:	e8 ab fb ff ff       	call   801005 <syscall>
  80145a:	83 c4 18             	add    $0x18,%esp
}
  80145d:	c9                   	leave  
  80145e:	c3                   	ret    

0080145f <sys_isUHeapPlacementStrategyFIRSTFIT>:


//2015
uint32 sys_isUHeapPlacementStrategyFIRSTFIT()
{
  80145f:	55                   	push   %ebp
  801460:	89 e5                	mov    %esp,%ebp
  801462:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  801465:	6a 00                	push   $0x0
  801467:	6a 00                	push   $0x0
  801469:	6a 00                	push   $0x0
  80146b:	6a 00                	push   $0x0
  80146d:	6a 00                	push   $0x0
  80146f:	6a 25                	push   $0x25
  801471:	e8 8f fb ff ff       	call   801005 <syscall>
  801476:	83 c4 18             	add    $0x18,%esp
  801479:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_FIRSTFIT)
  80147c:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
  801480:	75 07                	jne    801489 <sys_isUHeapPlacementStrategyFIRSTFIT+0x2a>
		return 1;
  801482:	b8 01 00 00 00       	mov    $0x1,%eax
  801487:	eb 05                	jmp    80148e <sys_isUHeapPlacementStrategyFIRSTFIT+0x2f>
	else
		return 0;
  801489:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80148e:	c9                   	leave  
  80148f:	c3                   	ret    

00801490 <sys_isUHeapPlacementStrategyBESTFIT>:
uint32 sys_isUHeapPlacementStrategyBESTFIT()
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  801496:	6a 00                	push   $0x0
  801498:	6a 00                	push   $0x0
  80149a:	6a 00                	push   $0x0
  80149c:	6a 00                	push   $0x0
  80149e:	6a 00                	push   $0x0
  8014a0:	6a 25                	push   $0x25
  8014a2:	e8 5e fb ff ff       	call   801005 <syscall>
  8014a7:	83 c4 18             	add    $0x18,%esp
  8014aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_BESTFIT)
  8014ad:	83 7d fc 02          	cmpl   $0x2,-0x4(%ebp)
  8014b1:	75 07                	jne    8014ba <sys_isUHeapPlacementStrategyBESTFIT+0x2a>
		return 1;
  8014b3:	b8 01 00 00 00       	mov    $0x1,%eax
  8014b8:	eb 05                	jmp    8014bf <sys_isUHeapPlacementStrategyBESTFIT+0x2f>
	else
		return 0;
  8014ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014bf:	c9                   	leave  
  8014c0:	c3                   	ret    

008014c1 <sys_isUHeapPlacementStrategyNEXTFIT>:
uint32 sys_isUHeapPlacementStrategyNEXTFIT()
{
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
  8014c4:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  8014c7:	6a 00                	push   $0x0
  8014c9:	6a 00                	push   $0x0
  8014cb:	6a 00                	push   $0x0
  8014cd:	6a 00                	push   $0x0
  8014cf:	6a 00                	push   $0x0
  8014d1:	6a 25                	push   $0x25
  8014d3:	e8 2d fb ff ff       	call   801005 <syscall>
  8014d8:	83 c4 18             	add    $0x18,%esp
  8014db:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_NEXTFIT)
  8014de:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
  8014e2:	75 07                	jne    8014eb <sys_isUHeapPlacementStrategyNEXTFIT+0x2a>
		return 1;
  8014e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8014e9:	eb 05                	jmp    8014f0 <sys_isUHeapPlacementStrategyNEXTFIT+0x2f>
	else
		return 0;
  8014eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f0:	c9                   	leave  
  8014f1:	c3                   	ret    

008014f2 <sys_isUHeapPlacementStrategyWORSTFIT>:
uint32 sys_isUHeapPlacementStrategyWORSTFIT()
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  8014f8:	6a 00                	push   $0x0
  8014fa:	6a 00                	push   $0x0
  8014fc:	6a 00                	push   $0x0
  8014fe:	6a 00                	push   $0x0
  801500:	6a 00                	push   $0x0
  801502:	6a 25                	push   $0x25
  801504:	e8 fc fa ff ff       	call   801005 <syscall>
  801509:	83 c4 18             	add    $0x18,%esp
  80150c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_WORSTFIT)
  80150f:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
  801513:	75 07                	jne    80151c <sys_isUHeapPlacementStrategyWORSTFIT+0x2a>
		return 1;
  801515:	b8 01 00 00 00       	mov    $0x1,%eax
  80151a:	eb 05                	jmp    801521 <sys_isUHeapPlacementStrategyWORSTFIT+0x2f>
	else
		return 0;
  80151c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801521:	c9                   	leave  
  801522:	c3                   	ret    

00801523 <sys_set_uheap_strategy>:

void sys_set_uheap_strategy(uint32 heapStrategy)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
	syscall(SYS_set_heap_strategy, heapStrategy, 0, 0, 0, 0);
  801526:	6a 00                	push   $0x0
  801528:	6a 00                	push   $0x0
  80152a:	6a 00                	push   $0x0
  80152c:	6a 00                	push   $0x0
  80152e:	ff 75 08             	pushl  0x8(%ebp)
  801531:	6a 26                	push   $0x26
  801533:	e8 cd fa ff ff       	call   801005 <syscall>
  801538:	83 c4 18             	add    $0x18,%esp
	return ;
  80153b:	90                   	nop
}
  80153c:	c9                   	leave  
  80153d:	c3                   	ret    

0080153e <sys_check_LRU_lists>:

//2020
int sys_check_LRU_lists(uint32* active_list_content, uint32* second_list_content, int actual_active_list_size, int actual_second_list_size)
{
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
  801541:	53                   	push   %ebx
	return syscall(SYS_check_LRU_lists, (uint32)active_list_content, (uint32)second_list_content, (uint32)actual_active_list_size, (uint32)actual_second_list_size, 0);
  801542:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801545:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801548:	8b 55 0c             	mov    0xc(%ebp),%edx
  80154b:	8b 45 08             	mov    0x8(%ebp),%eax
  80154e:	6a 00                	push   $0x0
  801550:	53                   	push   %ebx
  801551:	51                   	push   %ecx
  801552:	52                   	push   %edx
  801553:	50                   	push   %eax
  801554:	6a 27                	push   $0x27
  801556:	e8 aa fa ff ff       	call   801005 <syscall>
  80155b:	83 c4 18             	add    $0x18,%esp
}
  80155e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801561:	c9                   	leave  
  801562:	c3                   	ret    

00801563 <sys_check_LRU_lists_free>:

int sys_check_LRU_lists_free(uint32* list_content, int list_size)
{
  801563:	55                   	push   %ebp
  801564:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_LRU_lists_free, (uint32)list_content, (uint32)list_size , 0, 0, 0);
  801566:	8b 55 0c             	mov    0xc(%ebp),%edx
  801569:	8b 45 08             	mov    0x8(%ebp),%eax
  80156c:	6a 00                	push   $0x0
  80156e:	6a 00                	push   $0x0
  801570:	6a 00                	push   $0x0
  801572:	52                   	push   %edx
  801573:	50                   	push   %eax
  801574:	6a 28                	push   $0x28
  801576:	e8 8a fa ff ff       	call   801005 <syscall>
  80157b:	83 c4 18             	add    $0x18,%esp
}
  80157e:	c9                   	leave  
  80157f:	c3                   	ret    

00801580 <sys_check_WS_list>:

int sys_check_WS_list(uint32* WS_list_content, int actual_WS_list_size, uint32 last_WS_element_content, bool chk_in_order)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_WS_list, (uint32)WS_list_content, (uint32)actual_WS_list_size , last_WS_element_content, (uint32)chk_in_order, 0);
  801583:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801586:	8b 55 0c             	mov    0xc(%ebp),%edx
  801589:	8b 45 08             	mov    0x8(%ebp),%eax
  80158c:	6a 00                	push   $0x0
  80158e:	51                   	push   %ecx
  80158f:	ff 75 10             	pushl  0x10(%ebp)
  801592:	52                   	push   %edx
  801593:	50                   	push   %eax
  801594:	6a 29                	push   $0x29
  801596:	e8 6a fa ff ff       	call   801005 <syscall>
  80159b:	83 c4 18             	add    $0x18,%esp
}
  80159e:	c9                   	leave  
  80159f:	c3                   	ret    

008015a0 <sys_allocate_chunk>:
void sys_allocate_chunk(uint32 virtual_address, uint32 size, uint32 perms)
{
  8015a0:	55                   	push   %ebp
  8015a1:	89 e5                	mov    %esp,%ebp
	syscall(SYS_allocate_chunk_in_mem, virtual_address, size, perms, 0, 0);
  8015a3:	6a 00                	push   $0x0
  8015a5:	6a 00                	push   $0x0
  8015a7:	ff 75 10             	pushl  0x10(%ebp)
  8015aa:	ff 75 0c             	pushl  0xc(%ebp)
  8015ad:	ff 75 08             	pushl  0x8(%ebp)
  8015b0:	6a 12                	push   $0x12
  8015b2:	e8 4e fa ff ff       	call   801005 <syscall>
  8015b7:	83 c4 18             	add    $0x18,%esp
	return ;
  8015ba:	90                   	nop
}
  8015bb:	c9                   	leave  
  8015bc:	c3                   	ret    

008015bd <sys_utilities>:
void sys_utilities(char* utilityName, int value)
{
  8015bd:	55                   	push   %ebp
  8015be:	89 e5                	mov    %esp,%ebp
	syscall(SYS_utilities, (uint32)utilityName, value, 0, 0, 0);
  8015c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c6:	6a 00                	push   $0x0
  8015c8:	6a 00                	push   $0x0
  8015ca:	6a 00                	push   $0x0
  8015cc:	52                   	push   %edx
  8015cd:	50                   	push   %eax
  8015ce:	6a 2a                	push   $0x2a
  8015d0:	e8 30 fa ff ff       	call   801005 <syscall>
  8015d5:	83 c4 18             	add    $0x18,%esp
	return;
  8015d8:	90                   	nop
}
  8015d9:	c9                   	leave  
  8015da:	c3                   	ret    

008015db <sys_sbrk>:


//TODO: [PROJECT'24.MS1 - #02] [2] SYSTEM CALLS - Implement these system calls
void* sys_sbrk(int increment)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
	syscall( SYS_sbrk ,increment,0,0,0,0)  ;
  8015de:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e1:	6a 00                	push   $0x0
  8015e3:	6a 00                	push   $0x0
  8015e5:	6a 00                	push   $0x0
  8015e7:	6a 00                	push   $0x0
  8015e9:	50                   	push   %eax
  8015ea:	6a 2b                	push   $0x2b
  8015ec:	e8 14 fa ff ff       	call   801005 <syscall>
  8015f1:	83 c4 18             	add    $0x18,%esp

	return (void*)-1 ;
  8015f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

}
  8015f9:	c9                   	leave  
  8015fa:	c3                   	ret    

008015fb <sys_free_user_mem>:
void sys_free_user_mem(uint32 virtual_address, uint32 size)
{
  8015fb:	55                   	push   %ebp
  8015fc:	89 e5                	mov    %esp,%ebp
	syscall(SYS_free_user_mem,virtual_address,size,0,0,0);
  8015fe:	6a 00                	push   $0x0
  801600:	6a 00                	push   $0x0
  801602:	6a 00                	push   $0x0
  801604:	ff 75 0c             	pushl  0xc(%ebp)
  801607:	ff 75 08             	pushl  0x8(%ebp)
  80160a:	6a 2c                	push   $0x2c
  80160c:	e8 f4 f9 ff ff       	call   801005 <syscall>
  801611:	83 c4 18             	add    $0x18,%esp
	return;
  801614:	90                   	nop
}
  801615:	c9                   	leave  
  801616:	c3                   	ret    

00801617 <sys_allocate_user_mem>:

void sys_allocate_user_mem(uint32 virtual_address, uint32 size)
{
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
	syscall(SYS_allocate_user_mem,virtual_address,size,0,0,0);
  80161a:	6a 00                	push   $0x0
  80161c:	6a 00                	push   $0x0
  80161e:	6a 00                	push   $0x0
  801620:	ff 75 0c             	pushl  0xc(%ebp)
  801623:	ff 75 08             	pushl  0x8(%ebp)
  801626:	6a 2d                	push   $0x2d
  801628:	e8 d8 f9 ff ff       	call   801005 <syscall>
  80162d:	83 c4 18             	add    $0x18,%esp
	return;
  801630:	90                   	nop
}
  801631:	c9                   	leave  
  801632:	c3                   	ret    

00801633 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes FOS to enter the FOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	va_start(ap, fmt);
  801639:	8d 45 10             	lea    0x10(%ebp),%eax
  80163c:	83 c0 04             	add    $0x4,%eax
  80163f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// Print the panic message
	if (argv0)
  801642:	a1 24 30 80 00       	mov    0x803024,%eax
  801647:	85 c0                	test   %eax,%eax
  801649:	74 16                	je     801661 <_panic+0x2e>
		cprintf("%s: ", argv0);
  80164b:	a1 24 30 80 00       	mov    0x803024,%eax
  801650:	83 ec 08             	sub    $0x8,%esp
  801653:	50                   	push   %eax
  801654:	68 38 1f 80 00       	push   $0x801f38
  801659:	e8 0d ec ff ff       	call   80026b <cprintf>
  80165e:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  801661:	a1 00 30 80 00       	mov    0x803000,%eax
  801666:	ff 75 0c             	pushl  0xc(%ebp)
  801669:	ff 75 08             	pushl  0x8(%ebp)
  80166c:	50                   	push   %eax
  80166d:	68 3d 1f 80 00       	push   $0x801f3d
  801672:	e8 f4 eb ff ff       	call   80026b <cprintf>
  801677:	83 c4 10             	add    $0x10,%esp
	vcprintf(fmt, ap);
  80167a:	8b 45 10             	mov    0x10(%ebp),%eax
  80167d:	83 ec 08             	sub    $0x8,%esp
  801680:	ff 75 f4             	pushl  -0xc(%ebp)
  801683:	50                   	push   %eax
  801684:	e8 77 eb ff ff       	call   800200 <vcprintf>
  801689:	83 c4 10             	add    $0x10,%esp
	vcprintf("\n", NULL);
  80168c:	83 ec 08             	sub    $0x8,%esp
  80168f:	6a 00                	push   $0x0
  801691:	68 59 1f 80 00       	push   $0x801f59
  801696:	e8 65 eb ff ff       	call   800200 <vcprintf>
  80169b:	83 c4 10             	add    $0x10,%esp
	// Cause a breakpoint exception
//	while (1);
//		asm volatile("int3");

	//2013: exit the panic env only
	exit() ;
  80169e:	e8 e6 ea ff ff       	call   800189 <exit>

	// should not return here
	while (1) ;
  8016a3:	eb fe                	jmp    8016a3 <_panic+0x70>

008016a5 <CheckWSArrayWithoutLastIndex>:
}

void CheckWSArrayWithoutLastIndex(uint32 *expectedPages, int arraySize)
{
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	83 ec 28             	sub    $0x28,%esp
	if (arraySize != myEnv->page_WS_max_size)
  8016ab:	a1 04 30 80 00       	mov    0x803004,%eax
  8016b0:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
  8016b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b9:	39 c2                	cmp    %eax,%edx
  8016bb:	74 14                	je     8016d1 <CheckWSArrayWithoutLastIndex+0x2c>
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
  8016bd:	83 ec 04             	sub    $0x4,%esp
  8016c0:	68 5c 1f 80 00       	push   $0x801f5c
  8016c5:	6a 26                	push   $0x26
  8016c7:	68 a8 1f 80 00       	push   $0x801fa8
  8016cc:	e8 62 ff ff ff       	call   801633 <_panic>
	}
	int expectedNumOfEmptyLocs = 0;
  8016d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	for (int e = 0; e < arraySize; e++) {
  8016d8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8016df:	e9 c5 00 00 00       	jmp    8017a9 <CheckWSArrayWithoutLastIndex+0x104>
		if (expectedPages[e] == 0) {
  8016e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8016ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f1:	01 d0                	add    %edx,%eax
  8016f3:	8b 00                	mov    (%eax),%eax
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	75 08                	jne    801701 <CheckWSArrayWithoutLastIndex+0x5c>
			expectedNumOfEmptyLocs++;
  8016f9:	ff 45 f4             	incl   -0xc(%ebp)
			continue;
  8016fc:	e9 a5 00 00 00       	jmp    8017a6 <CheckWSArrayWithoutLastIndex+0x101>
		}
		int found = 0;
  801701:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  801708:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  80170f:	eb 69                	jmp    80177a <CheckWSArrayWithoutLastIndex+0xd5>
			if (myEnv->__uptr_pws[w].empty == 0) {
  801711:	a1 04 30 80 00       	mov    0x803004,%eax
  801716:	8b 88 7c 05 00 00    	mov    0x57c(%eax),%ecx
  80171c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80171f:	89 d0                	mov    %edx,%eax
  801721:	01 c0                	add    %eax,%eax
  801723:	01 d0                	add    %edx,%eax
  801725:	c1 e0 03             	shl    $0x3,%eax
  801728:	01 c8                	add    %ecx,%eax
  80172a:	8a 40 04             	mov    0x4(%eax),%al
  80172d:	84 c0                	test   %al,%al
  80172f:	75 46                	jne    801777 <CheckWSArrayWithoutLastIndex+0xd2>
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  801731:	a1 04 30 80 00       	mov    0x803004,%eax
  801736:	8b 88 7c 05 00 00    	mov    0x57c(%eax),%ecx
  80173c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80173f:	89 d0                	mov    %edx,%eax
  801741:	01 c0                	add    %eax,%eax
  801743:	01 d0                	add    %edx,%eax
  801745:	c1 e0 03             	shl    $0x3,%eax
  801748:	01 c8                	add    %ecx,%eax
  80174a:	8b 00                	mov    (%eax),%eax
  80174c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80174f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801752:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801757:	89 c2                	mov    %eax,%edx
						== expectedPages[e]) {
  801759:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175c:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801763:	8b 45 08             	mov    0x8(%ebp),%eax
  801766:	01 c8                	add    %ecx,%eax
  801768:	8b 00                	mov    (%eax),%eax
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
			if (myEnv->__uptr_pws[w].empty == 0) {
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  80176a:	39 c2                	cmp    %eax,%edx
  80176c:	75 09                	jne    801777 <CheckWSArrayWithoutLastIndex+0xd2>
						== expectedPages[e]) {
					found = 1;
  80176e:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
					break;
  801775:	eb 15                	jmp    80178c <CheckWSArrayWithoutLastIndex+0xe7>
		if (expectedPages[e] == 0) {
			expectedNumOfEmptyLocs++;
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  801777:	ff 45 e8             	incl   -0x18(%ebp)
  80177a:	a1 04 30 80 00       	mov    0x803004,%eax
  80177f:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
  801785:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801788:	39 c2                	cmp    %eax,%edx
  80178a:	77 85                	ja     801711 <CheckWSArrayWithoutLastIndex+0x6c>
					found = 1;
					break;
				}
			}
		}
		if (!found)
  80178c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801790:	75 14                	jne    8017a6 <CheckWSArrayWithoutLastIndex+0x101>
			panic(
  801792:	83 ec 04             	sub    $0x4,%esp
  801795:	68 b4 1f 80 00       	push   $0x801fb4
  80179a:	6a 3a                	push   $0x3a
  80179c:	68 a8 1f 80 00       	push   $0x801fa8
  8017a1:	e8 8d fe ff ff       	call   801633 <_panic>
	if (arraySize != myEnv->page_WS_max_size)
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
	}
	int expectedNumOfEmptyLocs = 0;
	for (int e = 0; e < arraySize; e++) {
  8017a6:	ff 45 f0             	incl   -0x10(%ebp)
  8017a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ac:	3b 45 0c             	cmp    0xc(%ebp),%eax
  8017af:	0f 8c 2f ff ff ff    	jl     8016e4 <CheckWSArrayWithoutLastIndex+0x3f>
		}
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
  8017b5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  8017bc:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8017c3:	eb 26                	jmp    8017eb <CheckWSArrayWithoutLastIndex+0x146>
		if (myEnv->__uptr_pws[w].empty == 1) {
  8017c5:	a1 04 30 80 00       	mov    0x803004,%eax
  8017ca:	8b 88 7c 05 00 00    	mov    0x57c(%eax),%ecx
  8017d0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8017d3:	89 d0                	mov    %edx,%eax
  8017d5:	01 c0                	add    %eax,%eax
  8017d7:	01 d0                	add    %edx,%eax
  8017d9:	c1 e0 03             	shl    $0x3,%eax
  8017dc:	01 c8                	add    %ecx,%eax
  8017de:	8a 40 04             	mov    0x4(%eax),%al
  8017e1:	3c 01                	cmp    $0x1,%al
  8017e3:	75 03                	jne    8017e8 <CheckWSArrayWithoutLastIndex+0x143>
			actualNumOfEmptyLocs++;
  8017e5:	ff 45 e4             	incl   -0x1c(%ebp)
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  8017e8:	ff 45 e0             	incl   -0x20(%ebp)
  8017eb:	a1 04 30 80 00       	mov    0x803004,%eax
  8017f0:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
  8017f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017f9:	39 c2                	cmp    %eax,%edx
  8017fb:	77 c8                	ja     8017c5 <CheckWSArrayWithoutLastIndex+0x120>
		if (myEnv->__uptr_pws[w].empty == 1) {
			actualNumOfEmptyLocs++;
		}
	}
	if (expectedNumOfEmptyLocs != actualNumOfEmptyLocs)
  8017fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801800:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  801803:	74 14                	je     801819 <CheckWSArrayWithoutLastIndex+0x174>
		panic(
  801805:	83 ec 04             	sub    $0x4,%esp
  801808:	68 08 20 80 00       	push   $0x802008
  80180d:	6a 44                	push   $0x44
  80180f:	68 a8 1f 80 00       	push   $0x801fa8
  801814:	e8 1a fe ff ff       	call   801633 <_panic>
				"PAGE WS entry checking failed... number of empty locations is not correct");
}
  801819:	90                   	nop
  80181a:	c9                   	leave  
  80181b:	c3                   	ret    

0080181c <__udivdi3>:
  80181c:	55                   	push   %ebp
  80181d:	57                   	push   %edi
  80181e:	56                   	push   %esi
  80181f:	53                   	push   %ebx
  801820:	83 ec 1c             	sub    $0x1c,%esp
  801823:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801827:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  80182b:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80182f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801833:	89 ca                	mov    %ecx,%edx
  801835:	89 f8                	mov    %edi,%eax
  801837:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80183b:	85 f6                	test   %esi,%esi
  80183d:	75 2d                	jne    80186c <__udivdi3+0x50>
  80183f:	39 cf                	cmp    %ecx,%edi
  801841:	77 65                	ja     8018a8 <__udivdi3+0x8c>
  801843:	89 fd                	mov    %edi,%ebp
  801845:	85 ff                	test   %edi,%edi
  801847:	75 0b                	jne    801854 <__udivdi3+0x38>
  801849:	b8 01 00 00 00       	mov    $0x1,%eax
  80184e:	31 d2                	xor    %edx,%edx
  801850:	f7 f7                	div    %edi
  801852:	89 c5                	mov    %eax,%ebp
  801854:	31 d2                	xor    %edx,%edx
  801856:	89 c8                	mov    %ecx,%eax
  801858:	f7 f5                	div    %ebp
  80185a:	89 c1                	mov    %eax,%ecx
  80185c:	89 d8                	mov    %ebx,%eax
  80185e:	f7 f5                	div    %ebp
  801860:	89 cf                	mov    %ecx,%edi
  801862:	89 fa                	mov    %edi,%edx
  801864:	83 c4 1c             	add    $0x1c,%esp
  801867:	5b                   	pop    %ebx
  801868:	5e                   	pop    %esi
  801869:	5f                   	pop    %edi
  80186a:	5d                   	pop    %ebp
  80186b:	c3                   	ret    
  80186c:	39 ce                	cmp    %ecx,%esi
  80186e:	77 28                	ja     801898 <__udivdi3+0x7c>
  801870:	0f bd fe             	bsr    %esi,%edi
  801873:	83 f7 1f             	xor    $0x1f,%edi
  801876:	75 40                	jne    8018b8 <__udivdi3+0x9c>
  801878:	39 ce                	cmp    %ecx,%esi
  80187a:	72 0a                	jb     801886 <__udivdi3+0x6a>
  80187c:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801880:	0f 87 9e 00 00 00    	ja     801924 <__udivdi3+0x108>
  801886:	b8 01 00 00 00       	mov    $0x1,%eax
  80188b:	89 fa                	mov    %edi,%edx
  80188d:	83 c4 1c             	add    $0x1c,%esp
  801890:	5b                   	pop    %ebx
  801891:	5e                   	pop    %esi
  801892:	5f                   	pop    %edi
  801893:	5d                   	pop    %ebp
  801894:	c3                   	ret    
  801895:	8d 76 00             	lea    0x0(%esi),%esi
  801898:	31 ff                	xor    %edi,%edi
  80189a:	31 c0                	xor    %eax,%eax
  80189c:	89 fa                	mov    %edi,%edx
  80189e:	83 c4 1c             	add    $0x1c,%esp
  8018a1:	5b                   	pop    %ebx
  8018a2:	5e                   	pop    %esi
  8018a3:	5f                   	pop    %edi
  8018a4:	5d                   	pop    %ebp
  8018a5:	c3                   	ret    
  8018a6:	66 90                	xchg   %ax,%ax
  8018a8:	89 d8                	mov    %ebx,%eax
  8018aa:	f7 f7                	div    %edi
  8018ac:	31 ff                	xor    %edi,%edi
  8018ae:	89 fa                	mov    %edi,%edx
  8018b0:	83 c4 1c             	add    $0x1c,%esp
  8018b3:	5b                   	pop    %ebx
  8018b4:	5e                   	pop    %esi
  8018b5:	5f                   	pop    %edi
  8018b6:	5d                   	pop    %ebp
  8018b7:	c3                   	ret    
  8018b8:	bd 20 00 00 00       	mov    $0x20,%ebp
  8018bd:	89 eb                	mov    %ebp,%ebx
  8018bf:	29 fb                	sub    %edi,%ebx
  8018c1:	89 f9                	mov    %edi,%ecx
  8018c3:	d3 e6                	shl    %cl,%esi
  8018c5:	89 c5                	mov    %eax,%ebp
  8018c7:	88 d9                	mov    %bl,%cl
  8018c9:	d3 ed                	shr    %cl,%ebp
  8018cb:	89 e9                	mov    %ebp,%ecx
  8018cd:	09 f1                	or     %esi,%ecx
  8018cf:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8018d3:	89 f9                	mov    %edi,%ecx
  8018d5:	d3 e0                	shl    %cl,%eax
  8018d7:	89 c5                	mov    %eax,%ebp
  8018d9:	89 d6                	mov    %edx,%esi
  8018db:	88 d9                	mov    %bl,%cl
  8018dd:	d3 ee                	shr    %cl,%esi
  8018df:	89 f9                	mov    %edi,%ecx
  8018e1:	d3 e2                	shl    %cl,%edx
  8018e3:	8b 44 24 08          	mov    0x8(%esp),%eax
  8018e7:	88 d9                	mov    %bl,%cl
  8018e9:	d3 e8                	shr    %cl,%eax
  8018eb:	09 c2                	or     %eax,%edx
  8018ed:	89 d0                	mov    %edx,%eax
  8018ef:	89 f2                	mov    %esi,%edx
  8018f1:	f7 74 24 0c          	divl   0xc(%esp)
  8018f5:	89 d6                	mov    %edx,%esi
  8018f7:	89 c3                	mov    %eax,%ebx
  8018f9:	f7 e5                	mul    %ebp
  8018fb:	39 d6                	cmp    %edx,%esi
  8018fd:	72 19                	jb     801918 <__udivdi3+0xfc>
  8018ff:	74 0b                	je     80190c <__udivdi3+0xf0>
  801901:	89 d8                	mov    %ebx,%eax
  801903:	31 ff                	xor    %edi,%edi
  801905:	e9 58 ff ff ff       	jmp    801862 <__udivdi3+0x46>
  80190a:	66 90                	xchg   %ax,%ax
  80190c:	8b 54 24 08          	mov    0x8(%esp),%edx
  801910:	89 f9                	mov    %edi,%ecx
  801912:	d3 e2                	shl    %cl,%edx
  801914:	39 c2                	cmp    %eax,%edx
  801916:	73 e9                	jae    801901 <__udivdi3+0xe5>
  801918:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80191b:	31 ff                	xor    %edi,%edi
  80191d:	e9 40 ff ff ff       	jmp    801862 <__udivdi3+0x46>
  801922:	66 90                	xchg   %ax,%ax
  801924:	31 c0                	xor    %eax,%eax
  801926:	e9 37 ff ff ff       	jmp    801862 <__udivdi3+0x46>
  80192b:	90                   	nop

0080192c <__umoddi3>:
  80192c:	55                   	push   %ebp
  80192d:	57                   	push   %edi
  80192e:	56                   	push   %esi
  80192f:	53                   	push   %ebx
  801930:	83 ec 1c             	sub    $0x1c,%esp
  801933:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801937:	8b 74 24 34          	mov    0x34(%esp),%esi
  80193b:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80193f:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801943:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801947:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80194b:	89 f3                	mov    %esi,%ebx
  80194d:	89 fa                	mov    %edi,%edx
  80194f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801953:	89 34 24             	mov    %esi,(%esp)
  801956:	85 c0                	test   %eax,%eax
  801958:	75 1a                	jne    801974 <__umoddi3+0x48>
  80195a:	39 f7                	cmp    %esi,%edi
  80195c:	0f 86 a2 00 00 00    	jbe    801a04 <__umoddi3+0xd8>
  801962:	89 c8                	mov    %ecx,%eax
  801964:	89 f2                	mov    %esi,%edx
  801966:	f7 f7                	div    %edi
  801968:	89 d0                	mov    %edx,%eax
  80196a:	31 d2                	xor    %edx,%edx
  80196c:	83 c4 1c             	add    $0x1c,%esp
  80196f:	5b                   	pop    %ebx
  801970:	5e                   	pop    %esi
  801971:	5f                   	pop    %edi
  801972:	5d                   	pop    %ebp
  801973:	c3                   	ret    
  801974:	39 f0                	cmp    %esi,%eax
  801976:	0f 87 ac 00 00 00    	ja     801a28 <__umoddi3+0xfc>
  80197c:	0f bd e8             	bsr    %eax,%ebp
  80197f:	83 f5 1f             	xor    $0x1f,%ebp
  801982:	0f 84 ac 00 00 00    	je     801a34 <__umoddi3+0x108>
  801988:	bf 20 00 00 00       	mov    $0x20,%edi
  80198d:	29 ef                	sub    %ebp,%edi
  80198f:	89 fe                	mov    %edi,%esi
  801991:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801995:	89 e9                	mov    %ebp,%ecx
  801997:	d3 e0                	shl    %cl,%eax
  801999:	89 d7                	mov    %edx,%edi
  80199b:	89 f1                	mov    %esi,%ecx
  80199d:	d3 ef                	shr    %cl,%edi
  80199f:	09 c7                	or     %eax,%edi
  8019a1:	89 e9                	mov    %ebp,%ecx
  8019a3:	d3 e2                	shl    %cl,%edx
  8019a5:	89 14 24             	mov    %edx,(%esp)
  8019a8:	89 d8                	mov    %ebx,%eax
  8019aa:	d3 e0                	shl    %cl,%eax
  8019ac:	89 c2                	mov    %eax,%edx
  8019ae:	8b 44 24 08          	mov    0x8(%esp),%eax
  8019b2:	d3 e0                	shl    %cl,%eax
  8019b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8019bc:	89 f1                	mov    %esi,%ecx
  8019be:	d3 e8                	shr    %cl,%eax
  8019c0:	09 d0                	or     %edx,%eax
  8019c2:	d3 eb                	shr    %cl,%ebx
  8019c4:	89 da                	mov    %ebx,%edx
  8019c6:	f7 f7                	div    %edi
  8019c8:	89 d3                	mov    %edx,%ebx
  8019ca:	f7 24 24             	mull   (%esp)
  8019cd:	89 c6                	mov    %eax,%esi
  8019cf:	89 d1                	mov    %edx,%ecx
  8019d1:	39 d3                	cmp    %edx,%ebx
  8019d3:	0f 82 87 00 00 00    	jb     801a60 <__umoddi3+0x134>
  8019d9:	0f 84 91 00 00 00    	je     801a70 <__umoddi3+0x144>
  8019df:	8b 54 24 04          	mov    0x4(%esp),%edx
  8019e3:	29 f2                	sub    %esi,%edx
  8019e5:	19 cb                	sbb    %ecx,%ebx
  8019e7:	89 d8                	mov    %ebx,%eax
  8019e9:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  8019ed:	d3 e0                	shl    %cl,%eax
  8019ef:	89 e9                	mov    %ebp,%ecx
  8019f1:	d3 ea                	shr    %cl,%edx
  8019f3:	09 d0                	or     %edx,%eax
  8019f5:	89 e9                	mov    %ebp,%ecx
  8019f7:	d3 eb                	shr    %cl,%ebx
  8019f9:	89 da                	mov    %ebx,%edx
  8019fb:	83 c4 1c             	add    $0x1c,%esp
  8019fe:	5b                   	pop    %ebx
  8019ff:	5e                   	pop    %esi
  801a00:	5f                   	pop    %edi
  801a01:	5d                   	pop    %ebp
  801a02:	c3                   	ret    
  801a03:	90                   	nop
  801a04:	89 fd                	mov    %edi,%ebp
  801a06:	85 ff                	test   %edi,%edi
  801a08:	75 0b                	jne    801a15 <__umoddi3+0xe9>
  801a0a:	b8 01 00 00 00       	mov    $0x1,%eax
  801a0f:	31 d2                	xor    %edx,%edx
  801a11:	f7 f7                	div    %edi
  801a13:	89 c5                	mov    %eax,%ebp
  801a15:	89 f0                	mov    %esi,%eax
  801a17:	31 d2                	xor    %edx,%edx
  801a19:	f7 f5                	div    %ebp
  801a1b:	89 c8                	mov    %ecx,%eax
  801a1d:	f7 f5                	div    %ebp
  801a1f:	89 d0                	mov    %edx,%eax
  801a21:	e9 44 ff ff ff       	jmp    80196a <__umoddi3+0x3e>
  801a26:	66 90                	xchg   %ax,%ax
  801a28:	89 c8                	mov    %ecx,%eax
  801a2a:	89 f2                	mov    %esi,%edx
  801a2c:	83 c4 1c             	add    $0x1c,%esp
  801a2f:	5b                   	pop    %ebx
  801a30:	5e                   	pop    %esi
  801a31:	5f                   	pop    %edi
  801a32:	5d                   	pop    %ebp
  801a33:	c3                   	ret    
  801a34:	3b 04 24             	cmp    (%esp),%eax
  801a37:	72 06                	jb     801a3f <__umoddi3+0x113>
  801a39:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801a3d:	77 0f                	ja     801a4e <__umoddi3+0x122>
  801a3f:	89 f2                	mov    %esi,%edx
  801a41:	29 f9                	sub    %edi,%ecx
  801a43:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801a47:	89 14 24             	mov    %edx,(%esp)
  801a4a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a4e:	8b 44 24 04          	mov    0x4(%esp),%eax
  801a52:	8b 14 24             	mov    (%esp),%edx
  801a55:	83 c4 1c             	add    $0x1c,%esp
  801a58:	5b                   	pop    %ebx
  801a59:	5e                   	pop    %esi
  801a5a:	5f                   	pop    %edi
  801a5b:	5d                   	pop    %ebp
  801a5c:	c3                   	ret    
  801a5d:	8d 76 00             	lea    0x0(%esi),%esi
  801a60:	2b 04 24             	sub    (%esp),%eax
  801a63:	19 fa                	sbb    %edi,%edx
  801a65:	89 d1                	mov    %edx,%ecx
  801a67:	89 c6                	mov    %eax,%esi
  801a69:	e9 71 ff ff ff       	jmp    8019df <__umoddi3+0xb3>
  801a6e:	66 90                	xchg   %ax,%ax
  801a70:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801a74:	72 ea                	jb     801a60 <__umoddi3+0x134>
  801a76:	89 d9                	mov    %ebx,%ecx
  801a78:	e9 62 ff ff ff       	jmp    8019df <__umoddi3+0xb3>
