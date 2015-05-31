
_usertests:     file format elf32-i386


Disassembly of section .text:

00000000 <iputtest>:
int stdout = 1;

// does chdir() call iput(p->cwd) in a transaction?
void
iputtest(void)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "iput test\n");
       6:	a1 d8 62 00 00       	mov    0x62d8,%eax
       b:	c7 44 24 04 2e 44 00 	movl   $0x442e,0x4(%esp)
      12:	00 
      13:	89 04 24             	mov    %eax,(%esp)
      16:	e8 2e 40 00 00       	call   4049 <printf>

  if(mkdir("iputdir") < 0){
      1b:	c7 04 24 39 44 00 00 	movl   $0x4439,(%esp)
      22:	e8 0a 3f 00 00       	call   3f31 <mkdir>
      27:	85 c0                	test   %eax,%eax
      29:	79 1a                	jns    45 <iputtest+0x45>
    printf(stdout, "mkdir failed\n");
      2b:	a1 d8 62 00 00       	mov    0x62d8,%eax
      30:	c7 44 24 04 41 44 00 	movl   $0x4441,0x4(%esp)
      37:	00 
      38:	89 04 24             	mov    %eax,(%esp)
      3b:	e8 09 40 00 00       	call   4049 <printf>
    exit();
      40:	e8 84 3e 00 00       	call   3ec9 <exit>
  }
  if(chdir("iputdir") < 0){
      45:	c7 04 24 39 44 00 00 	movl   $0x4439,(%esp)
      4c:	e8 e8 3e 00 00       	call   3f39 <chdir>
      51:	85 c0                	test   %eax,%eax
      53:	79 1a                	jns    6f <iputtest+0x6f>
    printf(stdout, "chdir iputdir failed\n");
      55:	a1 d8 62 00 00       	mov    0x62d8,%eax
      5a:	c7 44 24 04 4f 44 00 	movl   $0x444f,0x4(%esp)
      61:	00 
      62:	89 04 24             	mov    %eax,(%esp)
      65:	e8 df 3f 00 00       	call   4049 <printf>
    exit();
      6a:	e8 5a 3e 00 00       	call   3ec9 <exit>
  }
  if(unlink("../iputdir") < 0){
      6f:	c7 04 24 65 44 00 00 	movl   $0x4465,(%esp)
      76:	e8 9e 3e 00 00       	call   3f19 <unlink>
      7b:	85 c0                	test   %eax,%eax
      7d:	79 1a                	jns    99 <iputtest+0x99>
    printf(stdout, "unlink ../iputdir failed\n");
      7f:	a1 d8 62 00 00       	mov    0x62d8,%eax
      84:	c7 44 24 04 70 44 00 	movl   $0x4470,0x4(%esp)
      8b:	00 
      8c:	89 04 24             	mov    %eax,(%esp)
      8f:	e8 b5 3f 00 00       	call   4049 <printf>
    exit();
      94:	e8 30 3e 00 00       	call   3ec9 <exit>
  }
  if(chdir("/") < 0){
      99:	c7 04 24 8a 44 00 00 	movl   $0x448a,(%esp)
      a0:	e8 94 3e 00 00       	call   3f39 <chdir>
      a5:	85 c0                	test   %eax,%eax
      a7:	79 1a                	jns    c3 <iputtest+0xc3>
    printf(stdout, "chdir / failed\n");
      a9:	a1 d8 62 00 00       	mov    0x62d8,%eax
      ae:	c7 44 24 04 8c 44 00 	movl   $0x448c,0x4(%esp)
      b5:	00 
      b6:	89 04 24             	mov    %eax,(%esp)
      b9:	e8 8b 3f 00 00       	call   4049 <printf>
    exit();
      be:	e8 06 3e 00 00       	call   3ec9 <exit>
  }
  printf(stdout, "iput test ok\n");
      c3:	a1 d8 62 00 00       	mov    0x62d8,%eax
      c8:	c7 44 24 04 9c 44 00 	movl   $0x449c,0x4(%esp)
      cf:	00 
      d0:	89 04 24             	mov    %eax,(%esp)
      d3:	e8 71 3f 00 00       	call   4049 <printf>
}
      d8:	c9                   	leave  
      d9:	c3                   	ret    

000000da <exitiputtest>:

// does exit() call iput(p->cwd) in a transaction?
void
exitiputtest(void)
{
      da:	55                   	push   %ebp
      db:	89 e5                	mov    %esp,%ebp
      dd:	83 ec 28             	sub    $0x28,%esp
  int pid;

  printf(stdout, "exitiput test\n");
      e0:	a1 d8 62 00 00       	mov    0x62d8,%eax
      e5:	c7 44 24 04 aa 44 00 	movl   $0x44aa,0x4(%esp)
      ec:	00 
      ed:	89 04 24             	mov    %eax,(%esp)
      f0:	e8 54 3f 00 00       	call   4049 <printf>

  pid = fork();
      f5:	e8 c7 3d 00 00       	call   3ec1 <fork>
      fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid < 0){
      fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     101:	79 1a                	jns    11d <exitiputtest+0x43>
    printf(stdout, "fork failed\n");
     103:	a1 d8 62 00 00       	mov    0x62d8,%eax
     108:	c7 44 24 04 b9 44 00 	movl   $0x44b9,0x4(%esp)
     10f:	00 
     110:	89 04 24             	mov    %eax,(%esp)
     113:	e8 31 3f 00 00       	call   4049 <printf>
    exit();
     118:	e8 ac 3d 00 00       	call   3ec9 <exit>
  }
  if(pid == 0){
     11d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     121:	0f 85 83 00 00 00    	jne    1aa <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
     127:	c7 04 24 39 44 00 00 	movl   $0x4439,(%esp)
     12e:	e8 fe 3d 00 00       	call   3f31 <mkdir>
     133:	85 c0                	test   %eax,%eax
     135:	79 1a                	jns    151 <exitiputtest+0x77>
      printf(stdout, "mkdir failed\n");
     137:	a1 d8 62 00 00       	mov    0x62d8,%eax
     13c:	c7 44 24 04 41 44 00 	movl   $0x4441,0x4(%esp)
     143:	00 
     144:	89 04 24             	mov    %eax,(%esp)
     147:	e8 fd 3e 00 00       	call   4049 <printf>
      exit();
     14c:	e8 78 3d 00 00       	call   3ec9 <exit>
    }
    if(chdir("iputdir") < 0){
     151:	c7 04 24 39 44 00 00 	movl   $0x4439,(%esp)
     158:	e8 dc 3d 00 00       	call   3f39 <chdir>
     15d:	85 c0                	test   %eax,%eax
     15f:	79 1a                	jns    17b <exitiputtest+0xa1>
      printf(stdout, "child chdir failed\n");
     161:	a1 d8 62 00 00       	mov    0x62d8,%eax
     166:	c7 44 24 04 c6 44 00 	movl   $0x44c6,0x4(%esp)
     16d:	00 
     16e:	89 04 24             	mov    %eax,(%esp)
     171:	e8 d3 3e 00 00       	call   4049 <printf>
      exit();
     176:	e8 4e 3d 00 00       	call   3ec9 <exit>
    }
    if(unlink("../iputdir") < 0){
     17b:	c7 04 24 65 44 00 00 	movl   $0x4465,(%esp)
     182:	e8 92 3d 00 00       	call   3f19 <unlink>
     187:	85 c0                	test   %eax,%eax
     189:	79 1a                	jns    1a5 <exitiputtest+0xcb>
      printf(stdout, "unlink ../iputdir failed\n");
     18b:	a1 d8 62 00 00       	mov    0x62d8,%eax
     190:	c7 44 24 04 70 44 00 	movl   $0x4470,0x4(%esp)
     197:	00 
     198:	89 04 24             	mov    %eax,(%esp)
     19b:	e8 a9 3e 00 00       	call   4049 <printf>
      exit();
     1a0:	e8 24 3d 00 00       	call   3ec9 <exit>
    }
    exit();
     1a5:	e8 1f 3d 00 00       	call   3ec9 <exit>
  }
  wait();
     1aa:	e8 22 3d 00 00       	call   3ed1 <wait>
  printf(stdout, "exitiput test ok\n");
     1af:	a1 d8 62 00 00       	mov    0x62d8,%eax
     1b4:	c7 44 24 04 da 44 00 	movl   $0x44da,0x4(%esp)
     1bb:	00 
     1bc:	89 04 24             	mov    %eax,(%esp)
     1bf:	e8 85 3e 00 00       	call   4049 <printf>
}
     1c4:	c9                   	leave  
     1c5:	c3                   	ret    

000001c6 <openiputtest>:
//      for(i = 0; i < 10000; i++)
//        yield();
//    }
void
openiputtest(void)
{
     1c6:	55                   	push   %ebp
     1c7:	89 e5                	mov    %esp,%ebp
     1c9:	83 ec 28             	sub    $0x28,%esp
  int pid;

  printf(stdout, "openiput test\n");
     1cc:	a1 d8 62 00 00       	mov    0x62d8,%eax
     1d1:	c7 44 24 04 ec 44 00 	movl   $0x44ec,0x4(%esp)
     1d8:	00 
     1d9:	89 04 24             	mov    %eax,(%esp)
     1dc:	e8 68 3e 00 00       	call   4049 <printf>
  if(mkdir("oidir") < 0){
     1e1:	c7 04 24 fb 44 00 00 	movl   $0x44fb,(%esp)
     1e8:	e8 44 3d 00 00       	call   3f31 <mkdir>
     1ed:	85 c0                	test   %eax,%eax
     1ef:	79 1a                	jns    20b <openiputtest+0x45>
    printf(stdout, "mkdir oidir failed\n");
     1f1:	a1 d8 62 00 00       	mov    0x62d8,%eax
     1f6:	c7 44 24 04 01 45 00 	movl   $0x4501,0x4(%esp)
     1fd:	00 
     1fe:	89 04 24             	mov    %eax,(%esp)
     201:	e8 43 3e 00 00       	call   4049 <printf>
    exit();
     206:	e8 be 3c 00 00       	call   3ec9 <exit>
  }
  pid = fork();
     20b:	e8 b1 3c 00 00       	call   3ec1 <fork>
     210:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid < 0){
     213:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     217:	79 1a                	jns    233 <openiputtest+0x6d>
    printf(stdout, "fork failed\n");
     219:	a1 d8 62 00 00       	mov    0x62d8,%eax
     21e:	c7 44 24 04 b9 44 00 	movl   $0x44b9,0x4(%esp)
     225:	00 
     226:	89 04 24             	mov    %eax,(%esp)
     229:	e8 1b 3e 00 00       	call   4049 <printf>
    exit();
     22e:	e8 96 3c 00 00       	call   3ec9 <exit>
  }
  if(pid == 0){
     233:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     237:	75 3c                	jne    275 <openiputtest+0xaf>
    int fd = open("oidir", O_RDWR);
     239:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     240:	00 
     241:	c7 04 24 fb 44 00 00 	movl   $0x44fb,(%esp)
     248:	e8 bc 3c 00 00       	call   3f09 <open>
     24d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(fd >= 0){
     250:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     254:	78 1a                	js     270 <openiputtest+0xaa>
      printf(stdout, "open directory for write succeeded\n");
     256:	a1 d8 62 00 00       	mov    0x62d8,%eax
     25b:	c7 44 24 04 18 45 00 	movl   $0x4518,0x4(%esp)
     262:	00 
     263:	89 04 24             	mov    %eax,(%esp)
     266:	e8 de 3d 00 00       	call   4049 <printf>
      exit();
     26b:	e8 59 3c 00 00       	call   3ec9 <exit>
    }
    exit();
     270:	e8 54 3c 00 00       	call   3ec9 <exit>
  }
  sleep(1);
     275:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     27c:	e8 d8 3c 00 00       	call   3f59 <sleep>
  if(unlink("oidir") != 0){
     281:	c7 04 24 fb 44 00 00 	movl   $0x44fb,(%esp)
     288:	e8 8c 3c 00 00       	call   3f19 <unlink>
     28d:	85 c0                	test   %eax,%eax
     28f:	74 1a                	je     2ab <openiputtest+0xe5>
    printf(stdout, "unlink failed\n");
     291:	a1 d8 62 00 00       	mov    0x62d8,%eax
     296:	c7 44 24 04 3c 45 00 	movl   $0x453c,0x4(%esp)
     29d:	00 
     29e:	89 04 24             	mov    %eax,(%esp)
     2a1:	e8 a3 3d 00 00       	call   4049 <printf>
    exit();
     2a6:	e8 1e 3c 00 00       	call   3ec9 <exit>
  }
  wait();
     2ab:	e8 21 3c 00 00       	call   3ed1 <wait>
  printf(stdout, "openiput test ok\n");
     2b0:	a1 d8 62 00 00       	mov    0x62d8,%eax
     2b5:	c7 44 24 04 4b 45 00 	movl   $0x454b,0x4(%esp)
     2bc:	00 
     2bd:	89 04 24             	mov    %eax,(%esp)
     2c0:	e8 84 3d 00 00       	call   4049 <printf>
}
     2c5:	c9                   	leave  
     2c6:	c3                   	ret    

000002c7 <opentest>:

// simple file system tests

void
opentest(void)
{
     2c7:	55                   	push   %ebp
     2c8:	89 e5                	mov    %esp,%ebp
     2ca:	83 ec 28             	sub    $0x28,%esp
  int fd;

  printf(stdout, "open test\n");
     2cd:	a1 d8 62 00 00       	mov    0x62d8,%eax
     2d2:	c7 44 24 04 5d 45 00 	movl   $0x455d,0x4(%esp)
     2d9:	00 
     2da:	89 04 24             	mov    %eax,(%esp)
     2dd:	e8 67 3d 00 00       	call   4049 <printf>
  fd = open("echo", 0);
     2e2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     2e9:	00 
     2ea:	c7 04 24 18 44 00 00 	movl   $0x4418,(%esp)
     2f1:	e8 13 3c 00 00       	call   3f09 <open>
     2f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
     2f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     2fd:	79 1a                	jns    319 <opentest+0x52>
    printf(stdout, "open echo failed!\n");
     2ff:	a1 d8 62 00 00       	mov    0x62d8,%eax
     304:	c7 44 24 04 68 45 00 	movl   $0x4568,0x4(%esp)
     30b:	00 
     30c:	89 04 24             	mov    %eax,(%esp)
     30f:	e8 35 3d 00 00       	call   4049 <printf>
    exit();
     314:	e8 b0 3b 00 00       	call   3ec9 <exit>
  }
  close(fd);
     319:	8b 45 f4             	mov    -0xc(%ebp),%eax
     31c:	89 04 24             	mov    %eax,(%esp)
     31f:	e8 cd 3b 00 00       	call   3ef1 <close>
  fd = open("doesnotexist", 0);
     324:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     32b:	00 
     32c:	c7 04 24 7b 45 00 00 	movl   $0x457b,(%esp)
     333:	e8 d1 3b 00 00       	call   3f09 <open>
     338:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
     33b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     33f:	78 1a                	js     35b <opentest+0x94>
    printf(stdout, "open doesnotexist succeeded!\n");
     341:	a1 d8 62 00 00       	mov    0x62d8,%eax
     346:	c7 44 24 04 88 45 00 	movl   $0x4588,0x4(%esp)
     34d:	00 
     34e:	89 04 24             	mov    %eax,(%esp)
     351:	e8 f3 3c 00 00       	call   4049 <printf>
    exit();
     356:	e8 6e 3b 00 00       	call   3ec9 <exit>
  }
  printf(stdout, "open test ok\n");
     35b:	a1 d8 62 00 00       	mov    0x62d8,%eax
     360:	c7 44 24 04 a6 45 00 	movl   $0x45a6,0x4(%esp)
     367:	00 
     368:	89 04 24             	mov    %eax,(%esp)
     36b:	e8 d9 3c 00 00       	call   4049 <printf>
}
     370:	c9                   	leave  
     371:	c3                   	ret    

00000372 <writetest>:

void
writetest(void)
{
     372:	55                   	push   %ebp
     373:	89 e5                	mov    %esp,%ebp
     375:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int i;

  printf(stdout, "small file test\n");
     378:	a1 d8 62 00 00       	mov    0x62d8,%eax
     37d:	c7 44 24 04 b4 45 00 	movl   $0x45b4,0x4(%esp)
     384:	00 
     385:	89 04 24             	mov    %eax,(%esp)
     388:	e8 bc 3c 00 00       	call   4049 <printf>
  fd = open("small", O_CREATE|O_RDWR);
     38d:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     394:	00 
     395:	c7 04 24 c5 45 00 00 	movl   $0x45c5,(%esp)
     39c:	e8 68 3b 00 00       	call   3f09 <open>
     3a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(fd >= 0){
     3a4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     3a8:	78 21                	js     3cb <writetest+0x59>
    printf(stdout, "creat small succeeded; ok\n");
     3aa:	a1 d8 62 00 00       	mov    0x62d8,%eax
     3af:	c7 44 24 04 cb 45 00 	movl   $0x45cb,0x4(%esp)
     3b6:	00 
     3b7:	89 04 24             	mov    %eax,(%esp)
     3ba:	e8 8a 3c 00 00       	call   4049 <printf>
  } else {
    printf(stdout, "error: creat small failed!\n");
    exit();
  }
  for(i = 0; i < 100; i++){
     3bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     3c6:	e9 a0 00 00 00       	jmp    46b <writetest+0xf9>
  printf(stdout, "small file test\n");
  fd = open("small", O_CREATE|O_RDWR);
  if(fd >= 0){
    printf(stdout, "creat small succeeded; ok\n");
  } else {
    printf(stdout, "error: creat small failed!\n");
     3cb:	a1 d8 62 00 00       	mov    0x62d8,%eax
     3d0:	c7 44 24 04 e6 45 00 	movl   $0x45e6,0x4(%esp)
     3d7:	00 
     3d8:	89 04 24             	mov    %eax,(%esp)
     3db:	e8 69 3c 00 00       	call   4049 <printf>
    exit();
     3e0:	e8 e4 3a 00 00       	call   3ec9 <exit>
  }
  for(i = 0; i < 100; i++){
    if(write(fd, "aaaaaaaaaa", 10) != 10){
     3e5:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     3ec:	00 
     3ed:	c7 44 24 04 02 46 00 	movl   $0x4602,0x4(%esp)
     3f4:	00 
     3f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
     3f8:	89 04 24             	mov    %eax,(%esp)
     3fb:	e8 e9 3a 00 00       	call   3ee9 <write>
     400:	83 f8 0a             	cmp    $0xa,%eax
     403:	74 21                	je     426 <writetest+0xb4>
      printf(stdout, "error: write aa %d new file failed\n", i);
     405:	a1 d8 62 00 00       	mov    0x62d8,%eax
     40a:	8b 55 f4             	mov    -0xc(%ebp),%edx
     40d:	89 54 24 08          	mov    %edx,0x8(%esp)
     411:	c7 44 24 04 10 46 00 	movl   $0x4610,0x4(%esp)
     418:	00 
     419:	89 04 24             	mov    %eax,(%esp)
     41c:	e8 28 3c 00 00       	call   4049 <printf>
      exit();
     421:	e8 a3 3a 00 00       	call   3ec9 <exit>
    }
    if(write(fd, "bbbbbbbbbb", 10) != 10){
     426:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     42d:	00 
     42e:	c7 44 24 04 34 46 00 	movl   $0x4634,0x4(%esp)
     435:	00 
     436:	8b 45 f0             	mov    -0x10(%ebp),%eax
     439:	89 04 24             	mov    %eax,(%esp)
     43c:	e8 a8 3a 00 00       	call   3ee9 <write>
     441:	83 f8 0a             	cmp    $0xa,%eax
     444:	74 21                	je     467 <writetest+0xf5>
      printf(stdout, "error: write bb %d new file failed\n", i);
     446:	a1 d8 62 00 00       	mov    0x62d8,%eax
     44b:	8b 55 f4             	mov    -0xc(%ebp),%edx
     44e:	89 54 24 08          	mov    %edx,0x8(%esp)
     452:	c7 44 24 04 40 46 00 	movl   $0x4640,0x4(%esp)
     459:	00 
     45a:	89 04 24             	mov    %eax,(%esp)
     45d:	e8 e7 3b 00 00       	call   4049 <printf>
      exit();
     462:	e8 62 3a 00 00       	call   3ec9 <exit>
    printf(stdout, "creat small succeeded; ok\n");
  } else {
    printf(stdout, "error: creat small failed!\n");
    exit();
  }
  for(i = 0; i < 100; i++){
     467:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     46b:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
     46f:	0f 8e 70 ff ff ff    	jle    3e5 <writetest+0x73>
    if(write(fd, "bbbbbbbbbb", 10) != 10){
      printf(stdout, "error: write bb %d new file failed\n", i);
      exit();
    }
  }
  printf(stdout, "writes ok\n");
     475:	a1 d8 62 00 00       	mov    0x62d8,%eax
     47a:	c7 44 24 04 64 46 00 	movl   $0x4664,0x4(%esp)
     481:	00 
     482:	89 04 24             	mov    %eax,(%esp)
     485:	e8 bf 3b 00 00       	call   4049 <printf>
  close(fd);
     48a:	8b 45 f0             	mov    -0x10(%ebp),%eax
     48d:	89 04 24             	mov    %eax,(%esp)
     490:	e8 5c 3a 00 00       	call   3ef1 <close>
  fd = open("small", O_RDONLY);
     495:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     49c:	00 
     49d:	c7 04 24 c5 45 00 00 	movl   $0x45c5,(%esp)
     4a4:	e8 60 3a 00 00       	call   3f09 <open>
     4a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(fd >= 0){
     4ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     4b0:	78 3e                	js     4f0 <writetest+0x17e>
    printf(stdout, "open small succeeded ok\n");
     4b2:	a1 d8 62 00 00       	mov    0x62d8,%eax
     4b7:	c7 44 24 04 6f 46 00 	movl   $0x466f,0x4(%esp)
     4be:	00 
     4bf:	89 04 24             	mov    %eax,(%esp)
     4c2:	e8 82 3b 00 00       	call   4049 <printf>
  } else {
    printf(stdout, "error: open small failed!\n");
    exit();
  }
  i = read(fd, buf, 2000);
     4c7:	c7 44 24 08 d0 07 00 	movl   $0x7d0,0x8(%esp)
     4ce:	00 
     4cf:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
     4d6:	00 
     4d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
     4da:	89 04 24             	mov    %eax,(%esp)
     4dd:	e8 ff 39 00 00       	call   3ee1 <read>
     4e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(i == 2000){
     4e5:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
     4ec:	75 4e                	jne    53c <writetest+0x1ca>
     4ee:	eb 1a                	jmp    50a <writetest+0x198>
  close(fd);
  fd = open("small", O_RDONLY);
  if(fd >= 0){
    printf(stdout, "open small succeeded ok\n");
  } else {
    printf(stdout, "error: open small failed!\n");
     4f0:	a1 d8 62 00 00       	mov    0x62d8,%eax
     4f5:	c7 44 24 04 88 46 00 	movl   $0x4688,0x4(%esp)
     4fc:	00 
     4fd:	89 04 24             	mov    %eax,(%esp)
     500:	e8 44 3b 00 00       	call   4049 <printf>
    exit();
     505:	e8 bf 39 00 00       	call   3ec9 <exit>
  }
  i = read(fd, buf, 2000);
  if(i == 2000){
    printf(stdout, "read succeeded ok\n");
     50a:	a1 d8 62 00 00       	mov    0x62d8,%eax
     50f:	c7 44 24 04 a3 46 00 	movl   $0x46a3,0x4(%esp)
     516:	00 
     517:	89 04 24             	mov    %eax,(%esp)
     51a:	e8 2a 3b 00 00       	call   4049 <printf>
  } else {
    printf(stdout, "read failed\n");
    exit();
  }
  close(fd);
     51f:	8b 45 f0             	mov    -0x10(%ebp),%eax
     522:	89 04 24             	mov    %eax,(%esp)
     525:	e8 c7 39 00 00       	call   3ef1 <close>

  if(unlink("small") < 0){
     52a:	c7 04 24 c5 45 00 00 	movl   $0x45c5,(%esp)
     531:	e8 e3 39 00 00       	call   3f19 <unlink>
     536:	85 c0                	test   %eax,%eax
     538:	79 36                	jns    570 <writetest+0x1fe>
     53a:	eb 1a                	jmp    556 <writetest+0x1e4>
  }
  i = read(fd, buf, 2000);
  if(i == 2000){
    printf(stdout, "read succeeded ok\n");
  } else {
    printf(stdout, "read failed\n");
     53c:	a1 d8 62 00 00       	mov    0x62d8,%eax
     541:	c7 44 24 04 b6 46 00 	movl   $0x46b6,0x4(%esp)
     548:	00 
     549:	89 04 24             	mov    %eax,(%esp)
     54c:	e8 f8 3a 00 00       	call   4049 <printf>
    exit();
     551:	e8 73 39 00 00       	call   3ec9 <exit>
  }
  close(fd);

  if(unlink("small") < 0){
    printf(stdout, "unlink small failed\n");
     556:	a1 d8 62 00 00       	mov    0x62d8,%eax
     55b:	c7 44 24 04 c3 46 00 	movl   $0x46c3,0x4(%esp)
     562:	00 
     563:	89 04 24             	mov    %eax,(%esp)
     566:	e8 de 3a 00 00       	call   4049 <printf>
    exit();
     56b:	e8 59 39 00 00       	call   3ec9 <exit>
  }
  printf(stdout, "small file test ok\n");
     570:	a1 d8 62 00 00       	mov    0x62d8,%eax
     575:	c7 44 24 04 d8 46 00 	movl   $0x46d8,0x4(%esp)
     57c:	00 
     57d:	89 04 24             	mov    %eax,(%esp)
     580:	e8 c4 3a 00 00       	call   4049 <printf>
}
     585:	c9                   	leave  
     586:	c3                   	ret    

00000587 <writetest1>:

void
writetest1(void)
{
     587:	55                   	push   %ebp
     588:	89 e5                	mov    %esp,%ebp
     58a:	83 ec 28             	sub    $0x28,%esp
  int i, fd, n;

  printf(stdout, "big files test\n");
     58d:	a1 d8 62 00 00       	mov    0x62d8,%eax
     592:	c7 44 24 04 ec 46 00 	movl   $0x46ec,0x4(%esp)
     599:	00 
     59a:	89 04 24             	mov    %eax,(%esp)
     59d:	e8 a7 3a 00 00       	call   4049 <printf>

  fd = open("big", O_CREATE|O_RDWR);
     5a2:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     5a9:	00 
     5aa:	c7 04 24 fc 46 00 00 	movl   $0x46fc,(%esp)
     5b1:	e8 53 39 00 00       	call   3f09 <open>
     5b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
     5b9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     5bd:	79 1a                	jns    5d9 <writetest1+0x52>
    printf(stdout, "error: creat big failed!\n");
     5bf:	a1 d8 62 00 00       	mov    0x62d8,%eax
     5c4:	c7 44 24 04 00 47 00 	movl   $0x4700,0x4(%esp)
     5cb:	00 
     5cc:	89 04 24             	mov    %eax,(%esp)
     5cf:	e8 75 3a 00 00       	call   4049 <printf>
    exit();
     5d4:	e8 f0 38 00 00       	call   3ec9 <exit>
  }

  for(i = 0; i < MAXFILE; i++){
     5d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     5e0:	eb 51                	jmp    633 <writetest1+0xac>
    ((int*)buf)[0] = i;
     5e2:	b8 c0 8a 00 00       	mov    $0x8ac0,%eax
     5e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
     5ea:	89 10                	mov    %edx,(%eax)
    if(write(fd, buf, 512) != 512){
     5ec:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
     5f3:	00 
     5f4:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
     5fb:	00 
     5fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
     5ff:	89 04 24             	mov    %eax,(%esp)
     602:	e8 e2 38 00 00       	call   3ee9 <write>
     607:	3d 00 02 00 00       	cmp    $0x200,%eax
     60c:	74 21                	je     62f <writetest1+0xa8>
      printf(stdout, "error: write big file failed\n", i);
     60e:	a1 d8 62 00 00       	mov    0x62d8,%eax
     613:	8b 55 f4             	mov    -0xc(%ebp),%edx
     616:	89 54 24 08          	mov    %edx,0x8(%esp)
     61a:	c7 44 24 04 1a 47 00 	movl   $0x471a,0x4(%esp)
     621:	00 
     622:	89 04 24             	mov    %eax,(%esp)
     625:	e8 1f 3a 00 00       	call   4049 <printf>
      exit();
     62a:	e8 9a 38 00 00       	call   3ec9 <exit>
  if(fd < 0){
    printf(stdout, "error: creat big failed!\n");
    exit();
  }

  for(i = 0; i < MAXFILE; i++){
     62f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     633:	8b 45 f4             	mov    -0xc(%ebp),%eax
     636:	3d 8b 00 00 00       	cmp    $0x8b,%eax
     63b:	76 a5                	jbe    5e2 <writetest1+0x5b>
      printf(stdout, "error: write big file failed\n", i);
      exit();
    }
  }

  close(fd);
     63d:	8b 45 ec             	mov    -0x14(%ebp),%eax
     640:	89 04 24             	mov    %eax,(%esp)
     643:	e8 a9 38 00 00       	call   3ef1 <close>

  fd = open("big", O_RDONLY);
     648:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     64f:	00 
     650:	c7 04 24 fc 46 00 00 	movl   $0x46fc,(%esp)
     657:	e8 ad 38 00 00       	call   3f09 <open>
     65c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
     65f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     663:	79 1a                	jns    67f <writetest1+0xf8>
    printf(stdout, "error: open big failed!\n");
     665:	a1 d8 62 00 00       	mov    0x62d8,%eax
     66a:	c7 44 24 04 38 47 00 	movl   $0x4738,0x4(%esp)
     671:	00 
     672:	89 04 24             	mov    %eax,(%esp)
     675:	e8 cf 39 00 00       	call   4049 <printf>
    exit();
     67a:	e8 4a 38 00 00       	call   3ec9 <exit>
  }

  n = 0;
     67f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(;;){
    i = read(fd, buf, 512);
     686:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
     68d:	00 
     68e:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
     695:	00 
     696:	8b 45 ec             	mov    -0x14(%ebp),%eax
     699:	89 04 24             	mov    %eax,(%esp)
     69c:	e8 40 38 00 00       	call   3ee1 <read>
     6a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(i == 0){
     6a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     6a8:	75 4c                	jne    6f6 <writetest1+0x16f>
      if(n == MAXFILE - 1){
     6aa:	81 7d f0 8b 00 00 00 	cmpl   $0x8b,-0x10(%ebp)
     6b1:	75 21                	jne    6d4 <writetest1+0x14d>
        printf(stdout, "read only %d blocks from big", n);
     6b3:	a1 d8 62 00 00       	mov    0x62d8,%eax
     6b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
     6bb:	89 54 24 08          	mov    %edx,0x8(%esp)
     6bf:	c7 44 24 04 51 47 00 	movl   $0x4751,0x4(%esp)
     6c6:	00 
     6c7:	89 04 24             	mov    %eax,(%esp)
     6ca:	e8 7a 39 00 00       	call   4049 <printf>
        exit();
     6cf:	e8 f5 37 00 00       	call   3ec9 <exit>
      }
      break;
     6d4:	90                   	nop
             n, ((int*)buf)[0]);
      exit();
    }
    n++;
  }
  close(fd);
     6d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
     6d8:	89 04 24             	mov    %eax,(%esp)
     6db:	e8 11 38 00 00       	call   3ef1 <close>
  if(unlink("big") < 0){
     6e0:	c7 04 24 fc 46 00 00 	movl   $0x46fc,(%esp)
     6e7:	e8 2d 38 00 00       	call   3f19 <unlink>
     6ec:	85 c0                	test   %eax,%eax
     6ee:	0f 89 87 00 00 00    	jns    77b <writetest1+0x1f4>
     6f4:	eb 6b                	jmp    761 <writetest1+0x1da>
      if(n == MAXFILE - 1){
        printf(stdout, "read only %d blocks from big", n);
        exit();
      }
      break;
    } else if(i != 512){
     6f6:	81 7d f4 00 02 00 00 	cmpl   $0x200,-0xc(%ebp)
     6fd:	74 21                	je     720 <writetest1+0x199>
      printf(stdout, "read failed %d\n", i);
     6ff:	a1 d8 62 00 00       	mov    0x62d8,%eax
     704:	8b 55 f4             	mov    -0xc(%ebp),%edx
     707:	89 54 24 08          	mov    %edx,0x8(%esp)
     70b:	c7 44 24 04 6e 47 00 	movl   $0x476e,0x4(%esp)
     712:	00 
     713:	89 04 24             	mov    %eax,(%esp)
     716:	e8 2e 39 00 00       	call   4049 <printf>
      exit();
     71b:	e8 a9 37 00 00       	call   3ec9 <exit>
    }
    if(((int*)buf)[0] != n){
     720:	b8 c0 8a 00 00       	mov    $0x8ac0,%eax
     725:	8b 00                	mov    (%eax),%eax
     727:	3b 45 f0             	cmp    -0x10(%ebp),%eax
     72a:	74 2c                	je     758 <writetest1+0x1d1>
      printf(stdout, "read content of block %d is %d\n",
             n, ((int*)buf)[0]);
     72c:	b8 c0 8a 00 00       	mov    $0x8ac0,%eax
    } else if(i != 512){
      printf(stdout, "read failed %d\n", i);
      exit();
    }
    if(((int*)buf)[0] != n){
      printf(stdout, "read content of block %d is %d\n",
     731:	8b 10                	mov    (%eax),%edx
     733:	a1 d8 62 00 00       	mov    0x62d8,%eax
     738:	89 54 24 0c          	mov    %edx,0xc(%esp)
     73c:	8b 55 f0             	mov    -0x10(%ebp),%edx
     73f:	89 54 24 08          	mov    %edx,0x8(%esp)
     743:	c7 44 24 04 80 47 00 	movl   $0x4780,0x4(%esp)
     74a:	00 
     74b:	89 04 24             	mov    %eax,(%esp)
     74e:	e8 f6 38 00 00       	call   4049 <printf>
             n, ((int*)buf)[0]);
      exit();
     753:	e8 71 37 00 00       	call   3ec9 <exit>
    }
    n++;
     758:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  }
     75c:	e9 25 ff ff ff       	jmp    686 <writetest1+0xff>
  close(fd);
  if(unlink("big") < 0){
    printf(stdout, "unlink big failed\n");
     761:	a1 d8 62 00 00       	mov    0x62d8,%eax
     766:	c7 44 24 04 a0 47 00 	movl   $0x47a0,0x4(%esp)
     76d:	00 
     76e:	89 04 24             	mov    %eax,(%esp)
     771:	e8 d3 38 00 00       	call   4049 <printf>
    exit();
     776:	e8 4e 37 00 00       	call   3ec9 <exit>
  }
  printf(stdout, "big files ok\n");
     77b:	a1 d8 62 00 00       	mov    0x62d8,%eax
     780:	c7 44 24 04 b3 47 00 	movl   $0x47b3,0x4(%esp)
     787:	00 
     788:	89 04 24             	mov    %eax,(%esp)
     78b:	e8 b9 38 00 00       	call   4049 <printf>
}
     790:	c9                   	leave  
     791:	c3                   	ret    

00000792 <createtest>:

void
createtest(void)
{
     792:	55                   	push   %ebp
     793:	89 e5                	mov    %esp,%ebp
     795:	83 ec 28             	sub    $0x28,%esp
  int i, fd;

  printf(stdout, "many creates, followed by unlink test\n");
     798:	a1 d8 62 00 00       	mov    0x62d8,%eax
     79d:	c7 44 24 04 c4 47 00 	movl   $0x47c4,0x4(%esp)
     7a4:	00 
     7a5:	89 04 24             	mov    %eax,(%esp)
     7a8:	e8 9c 38 00 00       	call   4049 <printf>

  name[0] = 'a';
     7ad:	c6 05 c0 aa 00 00 61 	movb   $0x61,0xaac0
  name[2] = '\0';
     7b4:	c6 05 c2 aa 00 00 00 	movb   $0x0,0xaac2
  for(i = 0; i < 52; i++){
     7bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     7c2:	eb 31                	jmp    7f5 <createtest+0x63>
    name[1] = '0' + i;
     7c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7c7:	83 c0 30             	add    $0x30,%eax
     7ca:	a2 c1 aa 00 00       	mov    %al,0xaac1
    fd = open(name, O_CREATE|O_RDWR);
     7cf:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     7d6:	00 
     7d7:	c7 04 24 c0 aa 00 00 	movl   $0xaac0,(%esp)
     7de:	e8 26 37 00 00       	call   3f09 <open>
     7e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    close(fd);
     7e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
     7e9:	89 04 24             	mov    %eax,(%esp)
     7ec:	e8 00 37 00 00       	call   3ef1 <close>

  printf(stdout, "many creates, followed by unlink test\n");

  name[0] = 'a';
  name[2] = '\0';
  for(i = 0; i < 52; i++){
     7f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     7f5:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
     7f9:	7e c9                	jle    7c4 <createtest+0x32>
    name[1] = '0' + i;
    fd = open(name, O_CREATE|O_RDWR);
    close(fd);
  }
  name[0] = 'a';
     7fb:	c6 05 c0 aa 00 00 61 	movb   $0x61,0xaac0
  name[2] = '\0';
     802:	c6 05 c2 aa 00 00 00 	movb   $0x0,0xaac2
  for(i = 0; i < 52; i++){
     809:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     810:	eb 1b                	jmp    82d <createtest+0x9b>
    name[1] = '0' + i;
     812:	8b 45 f4             	mov    -0xc(%ebp),%eax
     815:	83 c0 30             	add    $0x30,%eax
     818:	a2 c1 aa 00 00       	mov    %al,0xaac1
    unlink(name);
     81d:	c7 04 24 c0 aa 00 00 	movl   $0xaac0,(%esp)
     824:	e8 f0 36 00 00       	call   3f19 <unlink>
    fd = open(name, O_CREATE|O_RDWR);
    close(fd);
  }
  name[0] = 'a';
  name[2] = '\0';
  for(i = 0; i < 52; i++){
     829:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     82d:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
     831:	7e df                	jle    812 <createtest+0x80>
    name[1] = '0' + i;
    unlink(name);
  }
  printf(stdout, "many creates, followed by unlink; ok\n");
     833:	a1 d8 62 00 00       	mov    0x62d8,%eax
     838:	c7 44 24 04 ec 47 00 	movl   $0x47ec,0x4(%esp)
     83f:	00 
     840:	89 04 24             	mov    %eax,(%esp)
     843:	e8 01 38 00 00       	call   4049 <printf>
}
     848:	c9                   	leave  
     849:	c3                   	ret    

0000084a <dirtest>:

void dirtest(void)
{
     84a:	55                   	push   %ebp
     84b:	89 e5                	mov    %esp,%ebp
     84d:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "mkdir test\n");
     850:	a1 d8 62 00 00       	mov    0x62d8,%eax
     855:	c7 44 24 04 12 48 00 	movl   $0x4812,0x4(%esp)
     85c:	00 
     85d:	89 04 24             	mov    %eax,(%esp)
     860:	e8 e4 37 00 00       	call   4049 <printf>

  if(mkdir("dir0") < 0){
     865:	c7 04 24 1e 48 00 00 	movl   $0x481e,(%esp)
     86c:	e8 c0 36 00 00       	call   3f31 <mkdir>
     871:	85 c0                	test   %eax,%eax
     873:	79 1a                	jns    88f <dirtest+0x45>
    printf(stdout, "mkdir failed\n");
     875:	a1 d8 62 00 00       	mov    0x62d8,%eax
     87a:	c7 44 24 04 41 44 00 	movl   $0x4441,0x4(%esp)
     881:	00 
     882:	89 04 24             	mov    %eax,(%esp)
     885:	e8 bf 37 00 00       	call   4049 <printf>
    exit();
     88a:	e8 3a 36 00 00       	call   3ec9 <exit>
  }

  if(chdir("dir0") < 0){
     88f:	c7 04 24 1e 48 00 00 	movl   $0x481e,(%esp)
     896:	e8 9e 36 00 00       	call   3f39 <chdir>
     89b:	85 c0                	test   %eax,%eax
     89d:	79 1a                	jns    8b9 <dirtest+0x6f>
    printf(stdout, "chdir dir0 failed\n");
     89f:	a1 d8 62 00 00       	mov    0x62d8,%eax
     8a4:	c7 44 24 04 23 48 00 	movl   $0x4823,0x4(%esp)
     8ab:	00 
     8ac:	89 04 24             	mov    %eax,(%esp)
     8af:	e8 95 37 00 00       	call   4049 <printf>
    exit();
     8b4:	e8 10 36 00 00       	call   3ec9 <exit>
  }

  if(chdir("..") < 0){
     8b9:	c7 04 24 36 48 00 00 	movl   $0x4836,(%esp)
     8c0:	e8 74 36 00 00       	call   3f39 <chdir>
     8c5:	85 c0                	test   %eax,%eax
     8c7:	79 1a                	jns    8e3 <dirtest+0x99>
    printf(stdout, "chdir .. failed\n");
     8c9:	a1 d8 62 00 00       	mov    0x62d8,%eax
     8ce:	c7 44 24 04 39 48 00 	movl   $0x4839,0x4(%esp)
     8d5:	00 
     8d6:	89 04 24             	mov    %eax,(%esp)
     8d9:	e8 6b 37 00 00       	call   4049 <printf>
    exit();
     8de:	e8 e6 35 00 00       	call   3ec9 <exit>
  }

  if(unlink("dir0") < 0){
     8e3:	c7 04 24 1e 48 00 00 	movl   $0x481e,(%esp)
     8ea:	e8 2a 36 00 00       	call   3f19 <unlink>
     8ef:	85 c0                	test   %eax,%eax
     8f1:	79 1a                	jns    90d <dirtest+0xc3>
    printf(stdout, "unlink dir0 failed\n");
     8f3:	a1 d8 62 00 00       	mov    0x62d8,%eax
     8f8:	c7 44 24 04 4a 48 00 	movl   $0x484a,0x4(%esp)
     8ff:	00 
     900:	89 04 24             	mov    %eax,(%esp)
     903:	e8 41 37 00 00       	call   4049 <printf>
    exit();
     908:	e8 bc 35 00 00       	call   3ec9 <exit>
  }
  printf(stdout, "mkdir test ok\n");
     90d:	a1 d8 62 00 00       	mov    0x62d8,%eax
     912:	c7 44 24 04 5e 48 00 	movl   $0x485e,0x4(%esp)
     919:	00 
     91a:	89 04 24             	mov    %eax,(%esp)
     91d:	e8 27 37 00 00       	call   4049 <printf>
}
     922:	c9                   	leave  
     923:	c3                   	ret    

00000924 <exectest>:

void
exectest(void)
{
     924:	55                   	push   %ebp
     925:	89 e5                	mov    %esp,%ebp
     927:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "exec test\n");
     92a:	a1 d8 62 00 00       	mov    0x62d8,%eax
     92f:	c7 44 24 04 6d 48 00 	movl   $0x486d,0x4(%esp)
     936:	00 
     937:	89 04 24             	mov    %eax,(%esp)
     93a:	e8 0a 37 00 00       	call   4049 <printf>
  if(exec("echo", echoargv) < 0){
     93f:	c7 44 24 04 c4 62 00 	movl   $0x62c4,0x4(%esp)
     946:	00 
     947:	c7 04 24 18 44 00 00 	movl   $0x4418,(%esp)
     94e:	e8 ae 35 00 00       	call   3f01 <exec>
     953:	85 c0                	test   %eax,%eax
     955:	79 1a                	jns    971 <exectest+0x4d>
    printf(stdout, "exec echo failed\n");
     957:	a1 d8 62 00 00       	mov    0x62d8,%eax
     95c:	c7 44 24 04 78 48 00 	movl   $0x4878,0x4(%esp)
     963:	00 
     964:	89 04 24             	mov    %eax,(%esp)
     967:	e8 dd 36 00 00       	call   4049 <printf>
    exit();
     96c:	e8 58 35 00 00       	call   3ec9 <exit>
  }
}
     971:	c9                   	leave  
     972:	c3                   	ret    

00000973 <pipe1>:

// simple fork and pipe read/write

void
pipe1(void)
{
     973:	55                   	push   %ebp
     974:	89 e5                	mov    %esp,%ebp
     976:	83 ec 38             	sub    $0x38,%esp
  int fds[2], pid;
  int seq, i, n, cc, total;

  if(pipe(fds) != 0){
     979:	8d 45 d8             	lea    -0x28(%ebp),%eax
     97c:	89 04 24             	mov    %eax,(%esp)
     97f:	e8 55 35 00 00       	call   3ed9 <pipe>
     984:	85 c0                	test   %eax,%eax
     986:	74 19                	je     9a1 <pipe1+0x2e>
    printf(1, "pipe() failed\n");
     988:	c7 44 24 04 8a 48 00 	movl   $0x488a,0x4(%esp)
     98f:	00 
     990:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     997:	e8 ad 36 00 00       	call   4049 <printf>
    exit();
     99c:	e8 28 35 00 00       	call   3ec9 <exit>
  }
  pid = fork();
     9a1:	e8 1b 35 00 00       	call   3ec1 <fork>
     9a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  seq = 0;
     9a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if(pid == 0){
     9b0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     9b4:	0f 85 88 00 00 00    	jne    a42 <pipe1+0xcf>
    close(fds[0]);
     9ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
     9bd:	89 04 24             	mov    %eax,(%esp)
     9c0:	e8 2c 35 00 00       	call   3ef1 <close>
    for(n = 0; n < 5; n++){
     9c5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
     9cc:	eb 69                	jmp    a37 <pipe1+0xc4>
      for(i = 0; i < 1033; i++)
     9ce:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     9d5:	eb 18                	jmp    9ef <pipe1+0x7c>
        buf[i] = seq++;
     9d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9da:	8d 50 01             	lea    0x1(%eax),%edx
     9dd:	89 55 f4             	mov    %edx,-0xc(%ebp)
     9e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
     9e3:	81 c2 c0 8a 00 00    	add    $0x8ac0,%edx
     9e9:	88 02                	mov    %al,(%edx)
  pid = fork();
  seq = 0;
  if(pid == 0){
    close(fds[0]);
    for(n = 0; n < 5; n++){
      for(i = 0; i < 1033; i++)
     9eb:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
     9ef:	81 7d f0 08 04 00 00 	cmpl   $0x408,-0x10(%ebp)
     9f6:	7e df                	jle    9d7 <pipe1+0x64>
        buf[i] = seq++;
      if(write(fds[1], buf, 1033) != 1033){
     9f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
     9fb:	c7 44 24 08 09 04 00 	movl   $0x409,0x8(%esp)
     a02:	00 
     a03:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
     a0a:	00 
     a0b:	89 04 24             	mov    %eax,(%esp)
     a0e:	e8 d6 34 00 00       	call   3ee9 <write>
     a13:	3d 09 04 00 00       	cmp    $0x409,%eax
     a18:	74 19                	je     a33 <pipe1+0xc0>
        printf(1, "pipe1 oops 1\n");
     a1a:	c7 44 24 04 99 48 00 	movl   $0x4899,0x4(%esp)
     a21:	00 
     a22:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a29:	e8 1b 36 00 00       	call   4049 <printf>
        exit();
     a2e:	e8 96 34 00 00       	call   3ec9 <exit>
  }
  pid = fork();
  seq = 0;
  if(pid == 0){
    close(fds[0]);
    for(n = 0; n < 5; n++){
     a33:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
     a37:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
     a3b:	7e 91                	jle    9ce <pipe1+0x5b>
      if(write(fds[1], buf, 1033) != 1033){
        printf(1, "pipe1 oops 1\n");
        exit();
      }
    }
    exit();
     a3d:	e8 87 34 00 00       	call   3ec9 <exit>
  } else if(pid > 0){
     a42:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     a46:	0f 8e f9 00 00 00    	jle    b45 <pipe1+0x1d2>
    close(fds[1]);
     a4c:	8b 45 dc             	mov    -0x24(%ebp),%eax
     a4f:	89 04 24             	mov    %eax,(%esp)
     a52:	e8 9a 34 00 00       	call   3ef1 <close>
    total = 0;
     a57:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    cc = 1;
     a5e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
    while((n = read(fds[0], buf, cc)) > 0){
     a65:	eb 68                	jmp    acf <pipe1+0x15c>
      for(i = 0; i < n; i++){
     a67:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     a6e:	eb 3d                	jmp    aad <pipe1+0x13a>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
     a70:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a73:	05 c0 8a 00 00       	add    $0x8ac0,%eax
     a78:	0f b6 00             	movzbl (%eax),%eax
     a7b:	0f be c8             	movsbl %al,%ecx
     a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a81:	8d 50 01             	lea    0x1(%eax),%edx
     a84:	89 55 f4             	mov    %edx,-0xc(%ebp)
     a87:	31 c8                	xor    %ecx,%eax
     a89:	0f b6 c0             	movzbl %al,%eax
     a8c:	85 c0                	test   %eax,%eax
     a8e:	74 19                	je     aa9 <pipe1+0x136>
          printf(1, "pipe1 oops 2\n");
     a90:	c7 44 24 04 a7 48 00 	movl   $0x48a7,0x4(%esp)
     a97:	00 
     a98:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a9f:	e8 a5 35 00 00       	call   4049 <printf>
     aa4:	e9 b5 00 00 00       	jmp    b5e <pipe1+0x1eb>
  } else if(pid > 0){
    close(fds[1]);
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
      for(i = 0; i < n; i++){
     aa9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
     aad:	8b 45 f0             	mov    -0x10(%ebp),%eax
     ab0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
     ab3:	7c bb                	jl     a70 <pipe1+0xfd>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
          printf(1, "pipe1 oops 2\n");
          return;
        }
      }
      total += n;
     ab5:	8b 45 ec             	mov    -0x14(%ebp),%eax
     ab8:	01 45 e4             	add    %eax,-0x1c(%ebp)
      cc = cc * 2;
     abb:	d1 65 e8             	shll   -0x18(%ebp)
      if(cc > sizeof(buf))
     abe:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ac1:	3d 00 20 00 00       	cmp    $0x2000,%eax
     ac6:	76 07                	jbe    acf <pipe1+0x15c>
        cc = sizeof(buf);
     ac8:	c7 45 e8 00 20 00 00 	movl   $0x2000,-0x18(%ebp)
    exit();
  } else if(pid > 0){
    close(fds[1]);
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
     acf:	8b 45 d8             	mov    -0x28(%ebp),%eax
     ad2:	8b 55 e8             	mov    -0x18(%ebp),%edx
     ad5:	89 54 24 08          	mov    %edx,0x8(%esp)
     ad9:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
     ae0:	00 
     ae1:	89 04 24             	mov    %eax,(%esp)
     ae4:	e8 f8 33 00 00       	call   3ee1 <read>
     ae9:	89 45 ec             	mov    %eax,-0x14(%ebp)
     aec:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     af0:	0f 8f 71 ff ff ff    	jg     a67 <pipe1+0xf4>
      total += n;
      cc = cc * 2;
      if(cc > sizeof(buf))
        cc = sizeof(buf);
    }
    if(total != 5 * 1033){
     af6:	81 7d e4 2d 14 00 00 	cmpl   $0x142d,-0x1c(%ebp)
     afd:	74 20                	je     b1f <pipe1+0x1ac>
      printf(1, "pipe1 oops 3 total %d\n", total);
     aff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     b02:	89 44 24 08          	mov    %eax,0x8(%esp)
     b06:	c7 44 24 04 b5 48 00 	movl   $0x48b5,0x4(%esp)
     b0d:	00 
     b0e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b15:	e8 2f 35 00 00       	call   4049 <printf>
      exit();
     b1a:	e8 aa 33 00 00       	call   3ec9 <exit>
    }
    close(fds[0]);
     b1f:	8b 45 d8             	mov    -0x28(%ebp),%eax
     b22:	89 04 24             	mov    %eax,(%esp)
     b25:	e8 c7 33 00 00       	call   3ef1 <close>
    wait();
     b2a:	e8 a2 33 00 00       	call   3ed1 <wait>
  } else {
    printf(1, "fork() failed\n");
    exit();
  }
  printf(1, "pipe1 ok\n");
     b2f:	c7 44 24 04 db 48 00 	movl   $0x48db,0x4(%esp)
     b36:	00 
     b37:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b3e:	e8 06 35 00 00       	call   4049 <printf>
     b43:	eb 19                	jmp    b5e <pipe1+0x1eb>
      exit();
    }
    close(fds[0]);
    wait();
  } else {
    printf(1, "fork() failed\n");
     b45:	c7 44 24 04 cc 48 00 	movl   $0x48cc,0x4(%esp)
     b4c:	00 
     b4d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b54:	e8 f0 34 00 00       	call   4049 <printf>
    exit();
     b59:	e8 6b 33 00 00       	call   3ec9 <exit>
  }
  printf(1, "pipe1 ok\n");
}
     b5e:	c9                   	leave  
     b5f:	c3                   	ret    

00000b60 <preempt>:

// meant to be run w/ at most two CPUs
void
preempt(void)
{
     b60:	55                   	push   %ebp
     b61:	89 e5                	mov    %esp,%ebp
     b63:	83 ec 38             	sub    $0x38,%esp
  int pid1, pid2, pid3;
  int pfds[2];

  printf(1, "preempt: ");
     b66:	c7 44 24 04 e5 48 00 	movl   $0x48e5,0x4(%esp)
     b6d:	00 
     b6e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b75:	e8 cf 34 00 00       	call   4049 <printf>
  pid1 = fork();
     b7a:	e8 42 33 00 00       	call   3ec1 <fork>
     b7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid1 == 0)
     b82:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     b86:	75 02                	jne    b8a <preempt+0x2a>
    for(;;)
      ;
     b88:	eb fe                	jmp    b88 <preempt+0x28>

  pid2 = fork();
     b8a:	e8 32 33 00 00       	call   3ec1 <fork>
     b8f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pid2 == 0)
     b92:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     b96:	75 02                	jne    b9a <preempt+0x3a>
    for(;;)
      ;
     b98:	eb fe                	jmp    b98 <preempt+0x38>

  pipe(pfds);
     b9a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     b9d:	89 04 24             	mov    %eax,(%esp)
     ba0:	e8 34 33 00 00       	call   3ed9 <pipe>
  pid3 = fork();
     ba5:	e8 17 33 00 00       	call   3ec1 <fork>
     baa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(pid3 == 0){
     bad:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     bb1:	75 4c                	jne    bff <preempt+0x9f>
    close(pfds[0]);
     bb3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     bb6:	89 04 24             	mov    %eax,(%esp)
     bb9:	e8 33 33 00 00       	call   3ef1 <close>
    if(write(pfds[1], "x", 1) != 1)
     bbe:	8b 45 e8             	mov    -0x18(%ebp),%eax
     bc1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     bc8:	00 
     bc9:	c7 44 24 04 ef 48 00 	movl   $0x48ef,0x4(%esp)
     bd0:	00 
     bd1:	89 04 24             	mov    %eax,(%esp)
     bd4:	e8 10 33 00 00       	call   3ee9 <write>
     bd9:	83 f8 01             	cmp    $0x1,%eax
     bdc:	74 14                	je     bf2 <preempt+0x92>
      printf(1, "preempt write error");
     bde:	c7 44 24 04 f1 48 00 	movl   $0x48f1,0x4(%esp)
     be5:	00 
     be6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     bed:	e8 57 34 00 00       	call   4049 <printf>
    close(pfds[1]);
     bf2:	8b 45 e8             	mov    -0x18(%ebp),%eax
     bf5:	89 04 24             	mov    %eax,(%esp)
     bf8:	e8 f4 32 00 00       	call   3ef1 <close>
    for(;;)
      ;
     bfd:	eb fe                	jmp    bfd <preempt+0x9d>
  }

  close(pfds[1]);
     bff:	8b 45 e8             	mov    -0x18(%ebp),%eax
     c02:	89 04 24             	mov    %eax,(%esp)
     c05:	e8 e7 32 00 00       	call   3ef1 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
     c0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     c0d:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
     c14:	00 
     c15:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
     c1c:	00 
     c1d:	89 04 24             	mov    %eax,(%esp)
     c20:	e8 bc 32 00 00       	call   3ee1 <read>
     c25:	83 f8 01             	cmp    $0x1,%eax
     c28:	74 16                	je     c40 <preempt+0xe0>
    printf(1, "preempt read error");
     c2a:	c7 44 24 04 05 49 00 	movl   $0x4905,0x4(%esp)
     c31:	00 
     c32:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c39:	e8 0b 34 00 00       	call   4049 <printf>
     c3e:	eb 77                	jmp    cb7 <preempt+0x157>
    return;
  }
  close(pfds[0]);
     c40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     c43:	89 04 24             	mov    %eax,(%esp)
     c46:	e8 a6 32 00 00       	call   3ef1 <close>
  printf(1, "kill... ");
     c4b:	c7 44 24 04 18 49 00 	movl   $0x4918,0x4(%esp)
     c52:	00 
     c53:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c5a:	e8 ea 33 00 00       	call   4049 <printf>
  kill(pid1);
     c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     c62:	89 04 24             	mov    %eax,(%esp)
     c65:	e8 8f 32 00 00       	call   3ef9 <kill>
  kill(pid2);
     c6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c6d:	89 04 24             	mov    %eax,(%esp)
     c70:	e8 84 32 00 00       	call   3ef9 <kill>
  kill(pid3);
     c75:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c78:	89 04 24             	mov    %eax,(%esp)
     c7b:	e8 79 32 00 00       	call   3ef9 <kill>
  printf(1, "wait... ");
     c80:	c7 44 24 04 21 49 00 	movl   $0x4921,0x4(%esp)
     c87:	00 
     c88:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c8f:	e8 b5 33 00 00       	call   4049 <printf>
  wait();
     c94:	e8 38 32 00 00       	call   3ed1 <wait>
  wait();
     c99:	e8 33 32 00 00       	call   3ed1 <wait>
  wait();
     c9e:	e8 2e 32 00 00       	call   3ed1 <wait>
  printf(1, "preempt ok\n");
     ca3:	c7 44 24 04 2a 49 00 	movl   $0x492a,0x4(%esp)
     caa:	00 
     cab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     cb2:	e8 92 33 00 00       	call   4049 <printf>
}
     cb7:	c9                   	leave  
     cb8:	c3                   	ret    

00000cb9 <exitwait>:

// try to find any races between exit and wait
void
exitwait(void)
{
     cb9:	55                   	push   %ebp
     cba:	89 e5                	mov    %esp,%ebp
     cbc:	83 ec 28             	sub    $0x28,%esp
  int i, pid;

  for(i = 0; i < 100; i++){
     cbf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     cc6:	eb 53                	jmp    d1b <exitwait+0x62>
    pid = fork();
     cc8:	e8 f4 31 00 00       	call   3ec1 <fork>
     ccd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0){
     cd0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     cd4:	79 16                	jns    cec <exitwait+0x33>
      printf(1, "fork failed\n");
     cd6:	c7 44 24 04 b9 44 00 	movl   $0x44b9,0x4(%esp)
     cdd:	00 
     cde:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ce5:	e8 5f 33 00 00       	call   4049 <printf>
      return;
     cea:	eb 49                	jmp    d35 <exitwait+0x7c>
    }
    if(pid){
     cec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     cf0:	74 20                	je     d12 <exitwait+0x59>
      if(wait() != pid){
     cf2:	e8 da 31 00 00       	call   3ed1 <wait>
     cf7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
     cfa:	74 1b                	je     d17 <exitwait+0x5e>
        printf(1, "wait wrong pid\n");
     cfc:	c7 44 24 04 36 49 00 	movl   $0x4936,0x4(%esp)
     d03:	00 
     d04:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d0b:	e8 39 33 00 00       	call   4049 <printf>
        return;
     d10:	eb 23                	jmp    d35 <exitwait+0x7c>
      }
    } else {
      exit();
     d12:	e8 b2 31 00 00       	call   3ec9 <exit>
void
exitwait(void)
{
  int i, pid;

  for(i = 0; i < 100; i++){
     d17:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     d1b:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
     d1f:	7e a7                	jle    cc8 <exitwait+0xf>
      }
    } else {
      exit();
    }
  }
  printf(1, "exitwait ok\n");
     d21:	c7 44 24 04 46 49 00 	movl   $0x4946,0x4(%esp)
     d28:	00 
     d29:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d30:	e8 14 33 00 00       	call   4049 <printf>
}
     d35:	c9                   	leave  
     d36:	c3                   	ret    

00000d37 <mem>:

void
mem(void)
{
     d37:	55                   	push   %ebp
     d38:	89 e5                	mov    %esp,%ebp
     d3a:	83 ec 28             	sub    $0x28,%esp
  void *m1, *m2;
  int pid, ppid;

  printf(1, "mem test\n");
     d3d:	c7 44 24 04 53 49 00 	movl   $0x4953,0x4(%esp)
     d44:	00 
     d45:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d4c:	e8 f8 32 00 00       	call   4049 <printf>
  ppid = getpid();
     d51:	e8 f3 31 00 00       	call   3f49 <getpid>
     d56:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if((pid = fork()) == 0){
     d59:	e8 63 31 00 00       	call   3ec1 <fork>
     d5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
     d61:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     d65:	0f 85 aa 00 00 00    	jne    e15 <mem+0xde>
    m1 = 0;
     d6b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while((m2 = malloc(10001)) != 0){
     d72:	eb 0e                	jmp    d82 <mem+0x4b>
      *(char**)m2 = m1;
     d74:	8b 45 e8             	mov    -0x18(%ebp),%eax
     d77:	8b 55 f4             	mov    -0xc(%ebp),%edx
     d7a:	89 10                	mov    %edx,(%eax)
      m1 = m2;
     d7c:	8b 45 e8             	mov    -0x18(%ebp),%eax
     d7f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  printf(1, "mem test\n");
  ppid = getpid();
  if((pid = fork()) == 0){
    m1 = 0;
    while((m2 = malloc(10001)) != 0){
     d82:	c7 04 24 11 27 00 00 	movl   $0x2711,(%esp)
     d89:	e8 a7 35 00 00       	call   4335 <malloc>
     d8e:	89 45 e8             	mov    %eax,-0x18(%ebp)
     d91:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     d95:	75 dd                	jne    d74 <mem+0x3d>
      *(char**)m2 = m1;
      m1 = m2;
    }
    while(m1){
     d97:	eb 19                	jmp    db2 <mem+0x7b>
      m2 = *(char**)m1;
     d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
     d9c:	8b 00                	mov    (%eax),%eax
     d9e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      free(m1);
     da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     da4:	89 04 24             	mov    %eax,(%esp)
     da7:	e8 50 34 00 00       	call   41fc <free>
      m1 = m2;
     dac:	8b 45 e8             	mov    -0x18(%ebp),%eax
     daf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    m1 = 0;
    while((m2 = malloc(10001)) != 0){
      *(char**)m2 = m1;
      m1 = m2;
    }
    while(m1){
     db2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     db6:	75 e1                	jne    d99 <mem+0x62>
      m2 = *(char**)m1;
      free(m1);
      m1 = m2;
    }
    m1 = malloc(1024*20);
     db8:	c7 04 24 00 50 00 00 	movl   $0x5000,(%esp)
     dbf:	e8 71 35 00 00       	call   4335 <malloc>
     dc4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(m1 == 0){
     dc7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     dcb:	75 24                	jne    df1 <mem+0xba>
      printf(1, "couldn't allocate mem?!!\n");
     dcd:	c7 44 24 04 5d 49 00 	movl   $0x495d,0x4(%esp)
     dd4:	00 
     dd5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ddc:	e8 68 32 00 00       	call   4049 <printf>
      kill(ppid);
     de1:	8b 45 f0             	mov    -0x10(%ebp),%eax
     de4:	89 04 24             	mov    %eax,(%esp)
     de7:	e8 0d 31 00 00       	call   3ef9 <kill>
      exit();
     dec:	e8 d8 30 00 00       	call   3ec9 <exit>
    }
    free(m1);
     df1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     df4:	89 04 24             	mov    %eax,(%esp)
     df7:	e8 00 34 00 00       	call   41fc <free>
    printf(1, "mem ok\n");
     dfc:	c7 44 24 04 77 49 00 	movl   $0x4977,0x4(%esp)
     e03:	00 
     e04:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e0b:	e8 39 32 00 00       	call   4049 <printf>
    exit();
     e10:	e8 b4 30 00 00       	call   3ec9 <exit>
  } else {
    wait();
     e15:	e8 b7 30 00 00       	call   3ed1 <wait>
  }
}
     e1a:	c9                   	leave  
     e1b:	c3                   	ret    

00000e1c <sharedfd>:

// two processes write to the same file descriptor
// is the offset shared? does inode locking work?
void
sharedfd(void)
{
     e1c:	55                   	push   %ebp
     e1d:	89 e5                	mov    %esp,%ebp
     e1f:	83 ec 48             	sub    $0x48,%esp
  int fd, pid, i, n, nc, np;
  char buf[10];

  printf(1, "sharedfd test\n");
     e22:	c7 44 24 04 7f 49 00 	movl   $0x497f,0x4(%esp)
     e29:	00 
     e2a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e31:	e8 13 32 00 00       	call   4049 <printf>

  unlink("sharedfd");
     e36:	c7 04 24 8e 49 00 00 	movl   $0x498e,(%esp)
     e3d:	e8 d7 30 00 00       	call   3f19 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
     e42:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     e49:	00 
     e4a:	c7 04 24 8e 49 00 00 	movl   $0x498e,(%esp)
     e51:	e8 b3 30 00 00       	call   3f09 <open>
     e56:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(fd < 0){
     e59:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     e5d:	79 19                	jns    e78 <sharedfd+0x5c>
    printf(1, "fstests: cannot open sharedfd for writing");
     e5f:	c7 44 24 04 98 49 00 	movl   $0x4998,0x4(%esp)
     e66:	00 
     e67:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e6e:	e8 d6 31 00 00       	call   4049 <printf>
    return;
     e73:	e9 a0 01 00 00       	jmp    1018 <sharedfd+0x1fc>
  }
  pid = fork();
     e78:	e8 44 30 00 00       	call   3ec1 <fork>
     e7d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  memset(buf, pid==0?'c':'p', sizeof(buf));
     e80:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
     e84:	75 07                	jne    e8d <sharedfd+0x71>
     e86:	b8 63 00 00 00       	mov    $0x63,%eax
     e8b:	eb 05                	jmp    e92 <sharedfd+0x76>
     e8d:	b8 70 00 00 00       	mov    $0x70,%eax
     e92:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     e99:	00 
     e9a:	89 44 24 04          	mov    %eax,0x4(%esp)
     e9e:	8d 45 d6             	lea    -0x2a(%ebp),%eax
     ea1:	89 04 24             	mov    %eax,(%esp)
     ea4:	e8 73 2e 00 00       	call   3d1c <memset>
  for(i = 0; i < 1000; i++){
     ea9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     eb0:	eb 39                	jmp    eeb <sharedfd+0xcf>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
     eb2:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     eb9:	00 
     eba:	8d 45 d6             	lea    -0x2a(%ebp),%eax
     ebd:	89 44 24 04          	mov    %eax,0x4(%esp)
     ec1:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ec4:	89 04 24             	mov    %eax,(%esp)
     ec7:	e8 1d 30 00 00       	call   3ee9 <write>
     ecc:	83 f8 0a             	cmp    $0xa,%eax
     ecf:	74 16                	je     ee7 <sharedfd+0xcb>
      printf(1, "fstests: write sharedfd failed\n");
     ed1:	c7 44 24 04 c4 49 00 	movl   $0x49c4,0x4(%esp)
     ed8:	00 
     ed9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ee0:	e8 64 31 00 00       	call   4049 <printf>
      break;
     ee5:	eb 0d                	jmp    ef4 <sharedfd+0xd8>
    printf(1, "fstests: cannot open sharedfd for writing");
    return;
  }
  pid = fork();
  memset(buf, pid==0?'c':'p', sizeof(buf));
  for(i = 0; i < 1000; i++){
     ee7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     eeb:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
     ef2:	7e be                	jle    eb2 <sharedfd+0x96>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
      printf(1, "fstests: write sharedfd failed\n");
      break;
    }
  }
  if(pid == 0)
     ef4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
     ef8:	75 05                	jne    eff <sharedfd+0xe3>
    exit();
     efa:	e8 ca 2f 00 00       	call   3ec9 <exit>
  else
    wait();
     eff:	e8 cd 2f 00 00       	call   3ed1 <wait>
  close(fd);
     f04:	8b 45 e8             	mov    -0x18(%ebp),%eax
     f07:	89 04 24             	mov    %eax,(%esp)
     f0a:	e8 e2 2f 00 00       	call   3ef1 <close>
  fd = open("sharedfd", 0);
     f0f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     f16:	00 
     f17:	c7 04 24 8e 49 00 00 	movl   $0x498e,(%esp)
     f1e:	e8 e6 2f 00 00       	call   3f09 <open>
     f23:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(fd < 0){
     f26:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     f2a:	79 19                	jns    f45 <sharedfd+0x129>
    printf(1, "fstests: cannot open sharedfd for reading\n");
     f2c:	c7 44 24 04 e4 49 00 	movl   $0x49e4,0x4(%esp)
     f33:	00 
     f34:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     f3b:	e8 09 31 00 00       	call   4049 <printf>
    return;
     f40:	e9 d3 00 00 00       	jmp    1018 <sharedfd+0x1fc>
  }
  nc = np = 0;
     f45:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
     f4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
     f4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while((n = read(fd, buf, sizeof(buf))) > 0){
     f52:	eb 3b                	jmp    f8f <sharedfd+0x173>
    for(i = 0; i < sizeof(buf); i++){
     f54:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     f5b:	eb 2a                	jmp    f87 <sharedfd+0x16b>
      if(buf[i] == 'c')
     f5d:	8d 55 d6             	lea    -0x2a(%ebp),%edx
     f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f63:	01 d0                	add    %edx,%eax
     f65:	0f b6 00             	movzbl (%eax),%eax
     f68:	3c 63                	cmp    $0x63,%al
     f6a:	75 04                	jne    f70 <sharedfd+0x154>
        nc++;
     f6c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
      if(buf[i] == 'p')
     f70:	8d 55 d6             	lea    -0x2a(%ebp),%edx
     f73:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f76:	01 d0                	add    %edx,%eax
     f78:	0f b6 00             	movzbl (%eax),%eax
     f7b:	3c 70                	cmp    $0x70,%al
     f7d:	75 04                	jne    f83 <sharedfd+0x167>
        np++;
     f7f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
    printf(1, "fstests: cannot open sharedfd for reading\n");
    return;
  }
  nc = np = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i = 0; i < sizeof(buf); i++){
     f83:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f8a:	83 f8 09             	cmp    $0x9,%eax
     f8d:	76 ce                	jbe    f5d <sharedfd+0x141>
  if(fd < 0){
    printf(1, "fstests: cannot open sharedfd for reading\n");
    return;
  }
  nc = np = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
     f8f:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     f96:	00 
     f97:	8d 45 d6             	lea    -0x2a(%ebp),%eax
     f9a:	89 44 24 04          	mov    %eax,0x4(%esp)
     f9e:	8b 45 e8             	mov    -0x18(%ebp),%eax
     fa1:	89 04 24             	mov    %eax,(%esp)
     fa4:	e8 38 2f 00 00       	call   3ee1 <read>
     fa9:	89 45 e0             	mov    %eax,-0x20(%ebp)
     fac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     fb0:	7f a2                	jg     f54 <sharedfd+0x138>
        nc++;
      if(buf[i] == 'p')
        np++;
    }
  }
  close(fd);
     fb2:	8b 45 e8             	mov    -0x18(%ebp),%eax
     fb5:	89 04 24             	mov    %eax,(%esp)
     fb8:	e8 34 2f 00 00       	call   3ef1 <close>
  unlink("sharedfd");
     fbd:	c7 04 24 8e 49 00 00 	movl   $0x498e,(%esp)
     fc4:	e8 50 2f 00 00       	call   3f19 <unlink>
  if(nc == 10000 && np == 10000){
     fc9:	81 7d f0 10 27 00 00 	cmpl   $0x2710,-0x10(%ebp)
     fd0:	75 1f                	jne    ff1 <sharedfd+0x1d5>
     fd2:	81 7d ec 10 27 00 00 	cmpl   $0x2710,-0x14(%ebp)
     fd9:	75 16                	jne    ff1 <sharedfd+0x1d5>
    printf(1, "sharedfd ok\n");
     fdb:	c7 44 24 04 0f 4a 00 	movl   $0x4a0f,0x4(%esp)
     fe2:	00 
     fe3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     fea:	e8 5a 30 00 00       	call   4049 <printf>
     fef:	eb 27                	jmp    1018 <sharedfd+0x1fc>
  } else {
    printf(1, "sharedfd oops %d %d\n", nc, np);
     ff1:	8b 45 ec             	mov    -0x14(%ebp),%eax
     ff4:	89 44 24 0c          	mov    %eax,0xc(%esp)
     ff8:	8b 45 f0             	mov    -0x10(%ebp),%eax
     ffb:	89 44 24 08          	mov    %eax,0x8(%esp)
     fff:	c7 44 24 04 1c 4a 00 	movl   $0x4a1c,0x4(%esp)
    1006:	00 
    1007:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    100e:	e8 36 30 00 00       	call   4049 <printf>
    exit();
    1013:	e8 b1 2e 00 00       	call   3ec9 <exit>
  }
}
    1018:	c9                   	leave  
    1019:	c3                   	ret    

0000101a <fourfiles>:

// four processes write different files at the same
// time, to test block allocation.
void
fourfiles(void)
{
    101a:	55                   	push   %ebp
    101b:	89 e5                	mov    %esp,%ebp
    101d:	83 ec 48             	sub    $0x48,%esp
  int fd, pid, i, j, n, total, pi;
  char *names[] = { "f0", "f1", "f2", "f3" };
    1020:	c7 45 c8 31 4a 00 00 	movl   $0x4a31,-0x38(%ebp)
    1027:	c7 45 cc 34 4a 00 00 	movl   $0x4a34,-0x34(%ebp)
    102e:	c7 45 d0 37 4a 00 00 	movl   $0x4a37,-0x30(%ebp)
    1035:	c7 45 d4 3a 4a 00 00 	movl   $0x4a3a,-0x2c(%ebp)
  char *fname;

  printf(1, "fourfiles test\n");
    103c:	c7 44 24 04 3d 4a 00 	movl   $0x4a3d,0x4(%esp)
    1043:	00 
    1044:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    104b:	e8 f9 2f 00 00       	call   4049 <printf>

  for(pi = 0; pi < 4; pi++){
    1050:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    1057:	e9 fc 00 00 00       	jmp    1158 <fourfiles+0x13e>
    fname = names[pi];
    105c:	8b 45 e8             	mov    -0x18(%ebp),%eax
    105f:	8b 44 85 c8          	mov    -0x38(%ebp,%eax,4),%eax
    1063:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    unlink(fname);
    1066:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1069:	89 04 24             	mov    %eax,(%esp)
    106c:	e8 a8 2e 00 00       	call   3f19 <unlink>

    pid = fork();
    1071:	e8 4b 2e 00 00       	call   3ec1 <fork>
    1076:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if(pid < 0){
    1079:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
    107d:	79 19                	jns    1098 <fourfiles+0x7e>
      printf(1, "fork failed\n");
    107f:	c7 44 24 04 b9 44 00 	movl   $0x44b9,0x4(%esp)
    1086:	00 
    1087:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    108e:	e8 b6 2f 00 00       	call   4049 <printf>
      exit();
    1093:	e8 31 2e 00 00       	call   3ec9 <exit>
    }

    if(pid == 0){
    1098:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
    109c:	0f 85 b2 00 00 00    	jne    1154 <fourfiles+0x13a>
      fd = open(fname, O_CREATE | O_RDWR);
    10a2:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    10a9:	00 
    10aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    10ad:	89 04 24             	mov    %eax,(%esp)
    10b0:	e8 54 2e 00 00       	call   3f09 <open>
    10b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
      if(fd < 0){
    10b8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
    10bc:	79 19                	jns    10d7 <fourfiles+0xbd>
        printf(1, "create failed\n");
    10be:	c7 44 24 04 4d 4a 00 	movl   $0x4a4d,0x4(%esp)
    10c5:	00 
    10c6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    10cd:	e8 77 2f 00 00       	call   4049 <printf>
        exit();
    10d2:	e8 f2 2d 00 00       	call   3ec9 <exit>
      }
      
      memset(buf, '0'+pi, 512);
    10d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
    10da:	83 c0 30             	add    $0x30,%eax
    10dd:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
    10e4:	00 
    10e5:	89 44 24 04          	mov    %eax,0x4(%esp)
    10e9:	c7 04 24 c0 8a 00 00 	movl   $0x8ac0,(%esp)
    10f0:	e8 27 2c 00 00       	call   3d1c <memset>
      for(i = 0; i < 12; i++){
    10f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    10fc:	eb 4b                	jmp    1149 <fourfiles+0x12f>
        if((n = write(fd, buf, 500)) != 500){
    10fe:	c7 44 24 08 f4 01 00 	movl   $0x1f4,0x8(%esp)
    1105:	00 
    1106:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
    110d:	00 
    110e:	8b 45 dc             	mov    -0x24(%ebp),%eax
    1111:	89 04 24             	mov    %eax,(%esp)
    1114:	e8 d0 2d 00 00       	call   3ee9 <write>
    1119:	89 45 d8             	mov    %eax,-0x28(%ebp)
    111c:	81 7d d8 f4 01 00 00 	cmpl   $0x1f4,-0x28(%ebp)
    1123:	74 20                	je     1145 <fourfiles+0x12b>
          printf(1, "write failed %d\n", n);
    1125:	8b 45 d8             	mov    -0x28(%ebp),%eax
    1128:	89 44 24 08          	mov    %eax,0x8(%esp)
    112c:	c7 44 24 04 5c 4a 00 	movl   $0x4a5c,0x4(%esp)
    1133:	00 
    1134:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    113b:	e8 09 2f 00 00       	call   4049 <printf>
          exit();
    1140:	e8 84 2d 00 00       	call   3ec9 <exit>
        printf(1, "create failed\n");
        exit();
      }
      
      memset(buf, '0'+pi, 512);
      for(i = 0; i < 12; i++){
    1145:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1149:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
    114d:	7e af                	jle    10fe <fourfiles+0xe4>
        if((n = write(fd, buf, 500)) != 500){
          printf(1, "write failed %d\n", n);
          exit();
        }
      }
      exit();
    114f:	e8 75 2d 00 00       	call   3ec9 <exit>
  char *names[] = { "f0", "f1", "f2", "f3" };
  char *fname;

  printf(1, "fourfiles test\n");

  for(pi = 0; pi < 4; pi++){
    1154:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
    1158:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
    115c:	0f 8e fa fe ff ff    	jle    105c <fourfiles+0x42>
      }
      exit();
    }
  }

  for(pi = 0; pi < 4; pi++){
    1162:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    1169:	eb 09                	jmp    1174 <fourfiles+0x15a>
    wait();
    116b:	e8 61 2d 00 00       	call   3ed1 <wait>
      }
      exit();
    }
  }

  for(pi = 0; pi < 4; pi++){
    1170:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
    1174:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
    1178:	7e f1                	jle    116b <fourfiles+0x151>
    wait();
  }

  for(i = 0; i < 2; i++){
    117a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1181:	e9 dc 00 00 00       	jmp    1262 <fourfiles+0x248>
    fname = names[i];
    1186:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1189:	8b 44 85 c8          	mov    -0x38(%ebp,%eax,4),%eax
    118d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    fd = open(fname, 0);
    1190:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1197:	00 
    1198:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    119b:	89 04 24             	mov    %eax,(%esp)
    119e:	e8 66 2d 00 00       	call   3f09 <open>
    11a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
    total = 0;
    11a6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    while((n = read(fd, buf, sizeof(buf))) > 0){
    11ad:	eb 4c                	jmp    11fb <fourfiles+0x1e1>
      for(j = 0; j < n; j++){
    11af:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    11b6:	eb 35                	jmp    11ed <fourfiles+0x1d3>
        if(buf[j] != '0'+i){
    11b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
    11bb:	05 c0 8a 00 00       	add    $0x8ac0,%eax
    11c0:	0f b6 00             	movzbl (%eax),%eax
    11c3:	0f be c0             	movsbl %al,%eax
    11c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
    11c9:	83 c2 30             	add    $0x30,%edx
    11cc:	39 d0                	cmp    %edx,%eax
    11ce:	74 19                	je     11e9 <fourfiles+0x1cf>
          printf(1, "wrong char\n");
    11d0:	c7 44 24 04 6d 4a 00 	movl   $0x4a6d,0x4(%esp)
    11d7:	00 
    11d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    11df:	e8 65 2e 00 00       	call   4049 <printf>
          exit();
    11e4:	e8 e0 2c 00 00       	call   3ec9 <exit>
  for(i = 0; i < 2; i++){
    fname = names[i];
    fd = open(fname, 0);
    total = 0;
    while((n = read(fd, buf, sizeof(buf))) > 0){
      for(j = 0; j < n; j++){
    11e9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    11ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
    11f0:	3b 45 d8             	cmp    -0x28(%ebp),%eax
    11f3:	7c c3                	jl     11b8 <fourfiles+0x19e>
        if(buf[j] != '0'+i){
          printf(1, "wrong char\n");
          exit();
        }
      }
      total += n;
    11f5:	8b 45 d8             	mov    -0x28(%ebp),%eax
    11f8:	01 45 ec             	add    %eax,-0x14(%ebp)

  for(i = 0; i < 2; i++){
    fname = names[i];
    fd = open(fname, 0);
    total = 0;
    while((n = read(fd, buf, sizeof(buf))) > 0){
    11fb:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    1202:	00 
    1203:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
    120a:	00 
    120b:	8b 45 dc             	mov    -0x24(%ebp),%eax
    120e:	89 04 24             	mov    %eax,(%esp)
    1211:	e8 cb 2c 00 00       	call   3ee1 <read>
    1216:	89 45 d8             	mov    %eax,-0x28(%ebp)
    1219:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
    121d:	7f 90                	jg     11af <fourfiles+0x195>
          exit();
        }
      }
      total += n;
    }
    close(fd);
    121f:	8b 45 dc             	mov    -0x24(%ebp),%eax
    1222:	89 04 24             	mov    %eax,(%esp)
    1225:	e8 c7 2c 00 00       	call   3ef1 <close>
    if(total != 12*500){
    122a:	81 7d ec 70 17 00 00 	cmpl   $0x1770,-0x14(%ebp)
    1231:	74 20                	je     1253 <fourfiles+0x239>
      printf(1, "wrong length %d\n", total);
    1233:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1236:	89 44 24 08          	mov    %eax,0x8(%esp)
    123a:	c7 44 24 04 79 4a 00 	movl   $0x4a79,0x4(%esp)
    1241:	00 
    1242:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1249:	e8 fb 2d 00 00       	call   4049 <printf>
      exit();
    124e:	e8 76 2c 00 00       	call   3ec9 <exit>
    }
    unlink(fname);
    1253:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1256:	89 04 24             	mov    %eax,(%esp)
    1259:	e8 bb 2c 00 00       	call   3f19 <unlink>

  for(pi = 0; pi < 4; pi++){
    wait();
  }

  for(i = 0; i < 2; i++){
    125e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1262:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
    1266:	0f 8e 1a ff ff ff    	jle    1186 <fourfiles+0x16c>
      exit();
    }
    unlink(fname);
  }

  printf(1, "fourfiles ok\n");
    126c:	c7 44 24 04 8a 4a 00 	movl   $0x4a8a,0x4(%esp)
    1273:	00 
    1274:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    127b:	e8 c9 2d 00 00       	call   4049 <printf>
}
    1280:	c9                   	leave  
    1281:	c3                   	ret    

00001282 <createdelete>:

// four processes create and delete different files in same directory
void
createdelete(void)
{
    1282:	55                   	push   %ebp
    1283:	89 e5                	mov    %esp,%ebp
    1285:	83 ec 48             	sub    $0x48,%esp
  enum { N = 20 };
  int pid, i, fd, pi;
  char name[32];

  printf(1, "createdelete test\n");
    1288:	c7 44 24 04 98 4a 00 	movl   $0x4a98,0x4(%esp)
    128f:	00 
    1290:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1297:	e8 ad 2d 00 00       	call   4049 <printf>

  for(pi = 0; pi < 4; pi++){
    129c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    12a3:	e9 f4 00 00 00       	jmp    139c <createdelete+0x11a>
    pid = fork();
    12a8:	e8 14 2c 00 00       	call   3ec1 <fork>
    12ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(pid < 0){
    12b0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    12b4:	79 19                	jns    12cf <createdelete+0x4d>
      printf(1, "fork failed\n");
    12b6:	c7 44 24 04 b9 44 00 	movl   $0x44b9,0x4(%esp)
    12bd:	00 
    12be:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    12c5:	e8 7f 2d 00 00       	call   4049 <printf>
      exit();
    12ca:	e8 fa 2b 00 00       	call   3ec9 <exit>
    }

    if(pid == 0){
    12cf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    12d3:	0f 85 bf 00 00 00    	jne    1398 <createdelete+0x116>
      name[0] = 'p' + pi;
    12d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    12dc:	83 c0 70             	add    $0x70,%eax
    12df:	88 45 c8             	mov    %al,-0x38(%ebp)
      name[2] = '\0';
    12e2:	c6 45 ca 00          	movb   $0x0,-0x36(%ebp)
      for(i = 0; i < N; i++){
    12e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    12ed:	e9 97 00 00 00       	jmp    1389 <createdelete+0x107>
        name[1] = '0' + i;
    12f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12f5:	83 c0 30             	add    $0x30,%eax
    12f8:	88 45 c9             	mov    %al,-0x37(%ebp)
        fd = open(name, O_CREATE | O_RDWR);
    12fb:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1302:	00 
    1303:	8d 45 c8             	lea    -0x38(%ebp),%eax
    1306:	89 04 24             	mov    %eax,(%esp)
    1309:	e8 fb 2b 00 00       	call   3f09 <open>
    130e:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if(fd < 0){
    1311:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    1315:	79 19                	jns    1330 <createdelete+0xae>
          printf(1, "create failed\n");
    1317:	c7 44 24 04 4d 4a 00 	movl   $0x4a4d,0x4(%esp)
    131e:	00 
    131f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1326:	e8 1e 2d 00 00       	call   4049 <printf>
          exit();
    132b:	e8 99 2b 00 00       	call   3ec9 <exit>
        }
        close(fd);
    1330:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1333:	89 04 24             	mov    %eax,(%esp)
    1336:	e8 b6 2b 00 00       	call   3ef1 <close>
        if(i > 0 && (i % 2 ) == 0){
    133b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    133f:	7e 44                	jle    1385 <createdelete+0x103>
    1341:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1344:	83 e0 01             	and    $0x1,%eax
    1347:	85 c0                	test   %eax,%eax
    1349:	75 3a                	jne    1385 <createdelete+0x103>
          name[1] = '0' + (i / 2);
    134b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    134e:	89 c2                	mov    %eax,%edx
    1350:	c1 ea 1f             	shr    $0x1f,%edx
    1353:	01 d0                	add    %edx,%eax
    1355:	d1 f8                	sar    %eax
    1357:	83 c0 30             	add    $0x30,%eax
    135a:	88 45 c9             	mov    %al,-0x37(%ebp)
          if(unlink(name) < 0){
    135d:	8d 45 c8             	lea    -0x38(%ebp),%eax
    1360:	89 04 24             	mov    %eax,(%esp)
    1363:	e8 b1 2b 00 00       	call   3f19 <unlink>
    1368:	85 c0                	test   %eax,%eax
    136a:	79 19                	jns    1385 <createdelete+0x103>
            printf(1, "unlink failed\n");
    136c:	c7 44 24 04 3c 45 00 	movl   $0x453c,0x4(%esp)
    1373:	00 
    1374:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    137b:	e8 c9 2c 00 00       	call   4049 <printf>
            exit();
    1380:	e8 44 2b 00 00       	call   3ec9 <exit>
    }

    if(pid == 0){
      name[0] = 'p' + pi;
      name[2] = '\0';
      for(i = 0; i < N; i++){
    1385:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1389:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    138d:	0f 8e 5f ff ff ff    	jle    12f2 <createdelete+0x70>
            printf(1, "unlink failed\n");
            exit();
          }
        }
      }
      exit();
    1393:	e8 31 2b 00 00       	call   3ec9 <exit>
  int pid, i, fd, pi;
  char name[32];

  printf(1, "createdelete test\n");

  for(pi = 0; pi < 4; pi++){
    1398:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    139c:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
    13a0:	0f 8e 02 ff ff ff    	jle    12a8 <createdelete+0x26>
      }
      exit();
    }
  }

  for(pi = 0; pi < 4; pi++){
    13a6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    13ad:	eb 09                	jmp    13b8 <createdelete+0x136>
    wait();
    13af:	e8 1d 2b 00 00       	call   3ed1 <wait>
      }
      exit();
    }
  }

  for(pi = 0; pi < 4; pi++){
    13b4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    13b8:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
    13bc:	7e f1                	jle    13af <createdelete+0x12d>
    wait();
  }

  name[0] = name[1] = name[2] = 0;
    13be:	c6 45 ca 00          	movb   $0x0,-0x36(%ebp)
    13c2:	0f b6 45 ca          	movzbl -0x36(%ebp),%eax
    13c6:	88 45 c9             	mov    %al,-0x37(%ebp)
    13c9:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
    13cd:	88 45 c8             	mov    %al,-0x38(%ebp)
  for(i = 0; i < N; i++){
    13d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    13d7:	e9 bb 00 00 00       	jmp    1497 <createdelete+0x215>
    for(pi = 0; pi < 4; pi++){
    13dc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    13e3:	e9 a1 00 00 00       	jmp    1489 <createdelete+0x207>
      name[0] = 'p' + pi;
    13e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13eb:	83 c0 70             	add    $0x70,%eax
    13ee:	88 45 c8             	mov    %al,-0x38(%ebp)
      name[1] = '0' + i;
    13f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13f4:	83 c0 30             	add    $0x30,%eax
    13f7:	88 45 c9             	mov    %al,-0x37(%ebp)
      fd = open(name, 0);
    13fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1401:	00 
    1402:	8d 45 c8             	lea    -0x38(%ebp),%eax
    1405:	89 04 24             	mov    %eax,(%esp)
    1408:	e8 fc 2a 00 00       	call   3f09 <open>
    140d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((i == 0 || i >= N/2) && fd < 0){
    1410:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1414:	74 06                	je     141c <createdelete+0x19a>
    1416:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
    141a:	7e 26                	jle    1442 <createdelete+0x1c0>
    141c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    1420:	79 20                	jns    1442 <createdelete+0x1c0>
        printf(1, "oops createdelete %s didn't exist\n", name);
    1422:	8d 45 c8             	lea    -0x38(%ebp),%eax
    1425:	89 44 24 08          	mov    %eax,0x8(%esp)
    1429:	c7 44 24 04 ac 4a 00 	movl   $0x4aac,0x4(%esp)
    1430:	00 
    1431:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1438:	e8 0c 2c 00 00       	call   4049 <printf>
        exit();
    143d:	e8 87 2a 00 00       	call   3ec9 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1442:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1446:	7e 2c                	jle    1474 <createdelete+0x1f2>
    1448:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
    144c:	7f 26                	jg     1474 <createdelete+0x1f2>
    144e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    1452:	78 20                	js     1474 <createdelete+0x1f2>
        printf(1, "oops createdelete %s did exist\n", name);
    1454:	8d 45 c8             	lea    -0x38(%ebp),%eax
    1457:	89 44 24 08          	mov    %eax,0x8(%esp)
    145b:	c7 44 24 04 d0 4a 00 	movl   $0x4ad0,0x4(%esp)
    1462:	00 
    1463:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    146a:	e8 da 2b 00 00       	call   4049 <printf>
        exit();
    146f:	e8 55 2a 00 00       	call   3ec9 <exit>
      }
      if(fd >= 0)
    1474:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    1478:	78 0b                	js     1485 <createdelete+0x203>
        close(fd);
    147a:	8b 45 e8             	mov    -0x18(%ebp),%eax
    147d:	89 04 24             	mov    %eax,(%esp)
    1480:	e8 6c 2a 00 00       	call   3ef1 <close>
    wait();
  }

  name[0] = name[1] = name[2] = 0;
  for(i = 0; i < N; i++){
    for(pi = 0; pi < 4; pi++){
    1485:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    1489:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
    148d:	0f 8e 55 ff ff ff    	jle    13e8 <createdelete+0x166>
  for(pi = 0; pi < 4; pi++){
    wait();
  }

  name[0] = name[1] = name[2] = 0;
  for(i = 0; i < N; i++){
    1493:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1497:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    149b:	0f 8e 3b ff ff ff    	jle    13dc <createdelete+0x15a>
      if(fd >= 0)
        close(fd);
    }
  }

  for(i = 0; i < N; i++){
    14a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    14a8:	eb 34                	jmp    14de <createdelete+0x25c>
    for(pi = 0; pi < 4; pi++){
    14aa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    14b1:	eb 21                	jmp    14d4 <createdelete+0x252>
      name[0] = 'p' + i;
    14b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14b6:	83 c0 70             	add    $0x70,%eax
    14b9:	88 45 c8             	mov    %al,-0x38(%ebp)
      name[1] = '0' + i;
    14bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14bf:	83 c0 30             	add    $0x30,%eax
    14c2:	88 45 c9             	mov    %al,-0x37(%ebp)
      unlink(name);
    14c5:	8d 45 c8             	lea    -0x38(%ebp),%eax
    14c8:	89 04 24             	mov    %eax,(%esp)
    14cb:	e8 49 2a 00 00       	call   3f19 <unlink>
        close(fd);
    }
  }

  for(i = 0; i < N; i++){
    for(pi = 0; pi < 4; pi++){
    14d0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    14d4:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
    14d8:	7e d9                	jle    14b3 <createdelete+0x231>
      if(fd >= 0)
        close(fd);
    }
  }

  for(i = 0; i < N; i++){
    14da:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    14de:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    14e2:	7e c6                	jle    14aa <createdelete+0x228>
      name[1] = '0' + i;
      unlink(name);
    }
  }

  printf(1, "createdelete ok\n");
    14e4:	c7 44 24 04 f0 4a 00 	movl   $0x4af0,0x4(%esp)
    14eb:	00 
    14ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    14f3:	e8 51 2b 00 00       	call   4049 <printf>
}
    14f8:	c9                   	leave  
    14f9:	c3                   	ret    

000014fa <unlinkread>:

// can I unlink a file and still read it?
void
unlinkread(void)
{
    14fa:	55                   	push   %ebp
    14fb:	89 e5                	mov    %esp,%ebp
    14fd:	83 ec 28             	sub    $0x28,%esp
  int fd, fd1;

  printf(1, "unlinkread test\n");
    1500:	c7 44 24 04 01 4b 00 	movl   $0x4b01,0x4(%esp)
    1507:	00 
    1508:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    150f:	e8 35 2b 00 00       	call   4049 <printf>
  fd = open("unlinkread", O_CREATE | O_RDWR);
    1514:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    151b:	00 
    151c:	c7 04 24 12 4b 00 00 	movl   $0x4b12,(%esp)
    1523:	e8 e1 29 00 00       	call   3f09 <open>
    1528:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    152b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    152f:	79 19                	jns    154a <unlinkread+0x50>
    printf(1, "create unlinkread failed\n");
    1531:	c7 44 24 04 1d 4b 00 	movl   $0x4b1d,0x4(%esp)
    1538:	00 
    1539:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1540:	e8 04 2b 00 00       	call   4049 <printf>
    exit();
    1545:	e8 7f 29 00 00       	call   3ec9 <exit>
  }
  write(fd, "hello", 5);
    154a:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
    1551:	00 
    1552:	c7 44 24 04 37 4b 00 	movl   $0x4b37,0x4(%esp)
    1559:	00 
    155a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    155d:	89 04 24             	mov    %eax,(%esp)
    1560:	e8 84 29 00 00       	call   3ee9 <write>
  close(fd);
    1565:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1568:	89 04 24             	mov    %eax,(%esp)
    156b:	e8 81 29 00 00       	call   3ef1 <close>

  fd = open("unlinkread", O_RDWR);
    1570:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    1577:	00 
    1578:	c7 04 24 12 4b 00 00 	movl   $0x4b12,(%esp)
    157f:	e8 85 29 00 00       	call   3f09 <open>
    1584:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    1587:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    158b:	79 19                	jns    15a6 <unlinkread+0xac>
    printf(1, "open unlinkread failed\n");
    158d:	c7 44 24 04 3d 4b 00 	movl   $0x4b3d,0x4(%esp)
    1594:	00 
    1595:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    159c:	e8 a8 2a 00 00       	call   4049 <printf>
    exit();
    15a1:	e8 23 29 00 00       	call   3ec9 <exit>
  }
  if(unlink("unlinkread") != 0){
    15a6:	c7 04 24 12 4b 00 00 	movl   $0x4b12,(%esp)
    15ad:	e8 67 29 00 00       	call   3f19 <unlink>
    15b2:	85 c0                	test   %eax,%eax
    15b4:	74 19                	je     15cf <unlinkread+0xd5>
    printf(1, "unlink unlinkread failed\n");
    15b6:	c7 44 24 04 55 4b 00 	movl   $0x4b55,0x4(%esp)
    15bd:	00 
    15be:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    15c5:	e8 7f 2a 00 00       	call   4049 <printf>
    exit();
    15ca:	e8 fa 28 00 00       	call   3ec9 <exit>
  }

  fd1 = open("unlinkread", O_CREATE | O_RDWR);
    15cf:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    15d6:	00 
    15d7:	c7 04 24 12 4b 00 00 	movl   $0x4b12,(%esp)
    15de:	e8 26 29 00 00       	call   3f09 <open>
    15e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  write(fd1, "yyy", 3);
    15e6:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
    15ed:	00 
    15ee:	c7 44 24 04 6f 4b 00 	movl   $0x4b6f,0x4(%esp)
    15f5:	00 
    15f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15f9:	89 04 24             	mov    %eax,(%esp)
    15fc:	e8 e8 28 00 00       	call   3ee9 <write>
  close(fd1);
    1601:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1604:	89 04 24             	mov    %eax,(%esp)
    1607:	e8 e5 28 00 00       	call   3ef1 <close>

  if(read(fd, buf, sizeof(buf)) != 5){
    160c:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    1613:	00 
    1614:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
    161b:	00 
    161c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    161f:	89 04 24             	mov    %eax,(%esp)
    1622:	e8 ba 28 00 00       	call   3ee1 <read>
    1627:	83 f8 05             	cmp    $0x5,%eax
    162a:	74 19                	je     1645 <unlinkread+0x14b>
    printf(1, "unlinkread read failed");
    162c:	c7 44 24 04 73 4b 00 	movl   $0x4b73,0x4(%esp)
    1633:	00 
    1634:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    163b:	e8 09 2a 00 00       	call   4049 <printf>
    exit();
    1640:	e8 84 28 00 00       	call   3ec9 <exit>
  }
  if(buf[0] != 'h'){
    1645:	0f b6 05 c0 8a 00 00 	movzbl 0x8ac0,%eax
    164c:	3c 68                	cmp    $0x68,%al
    164e:	74 19                	je     1669 <unlinkread+0x16f>
    printf(1, "unlinkread wrong data\n");
    1650:	c7 44 24 04 8a 4b 00 	movl   $0x4b8a,0x4(%esp)
    1657:	00 
    1658:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    165f:	e8 e5 29 00 00       	call   4049 <printf>
    exit();
    1664:	e8 60 28 00 00       	call   3ec9 <exit>
  }
  if(write(fd, buf, 10) != 10){
    1669:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    1670:	00 
    1671:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
    1678:	00 
    1679:	8b 45 f4             	mov    -0xc(%ebp),%eax
    167c:	89 04 24             	mov    %eax,(%esp)
    167f:	e8 65 28 00 00       	call   3ee9 <write>
    1684:	83 f8 0a             	cmp    $0xa,%eax
    1687:	74 19                	je     16a2 <unlinkread+0x1a8>
    printf(1, "unlinkread write failed\n");
    1689:	c7 44 24 04 a1 4b 00 	movl   $0x4ba1,0x4(%esp)
    1690:	00 
    1691:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1698:	e8 ac 29 00 00       	call   4049 <printf>
    exit();
    169d:	e8 27 28 00 00       	call   3ec9 <exit>
  }
  close(fd);
    16a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16a5:	89 04 24             	mov    %eax,(%esp)
    16a8:	e8 44 28 00 00       	call   3ef1 <close>
  unlink("unlinkread");
    16ad:	c7 04 24 12 4b 00 00 	movl   $0x4b12,(%esp)
    16b4:	e8 60 28 00 00       	call   3f19 <unlink>
  printf(1, "unlinkread ok\n");
    16b9:	c7 44 24 04 ba 4b 00 	movl   $0x4bba,0x4(%esp)
    16c0:	00 
    16c1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    16c8:	e8 7c 29 00 00       	call   4049 <printf>
}
    16cd:	c9                   	leave  
    16ce:	c3                   	ret    

000016cf <linktest>:

void
linktest(void)
{
    16cf:	55                   	push   %ebp
    16d0:	89 e5                	mov    %esp,%ebp
    16d2:	83 ec 28             	sub    $0x28,%esp
  int fd;

  printf(1, "linktest\n");
    16d5:	c7 44 24 04 c9 4b 00 	movl   $0x4bc9,0x4(%esp)
    16dc:	00 
    16dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    16e4:	e8 60 29 00 00       	call   4049 <printf>

  unlink("lf1");
    16e9:	c7 04 24 d3 4b 00 00 	movl   $0x4bd3,(%esp)
    16f0:	e8 24 28 00 00       	call   3f19 <unlink>
  unlink("lf2");
    16f5:	c7 04 24 d7 4b 00 00 	movl   $0x4bd7,(%esp)
    16fc:	e8 18 28 00 00       	call   3f19 <unlink>

  fd = open("lf1", O_CREATE|O_RDWR);
    1701:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1708:	00 
    1709:	c7 04 24 d3 4b 00 00 	movl   $0x4bd3,(%esp)
    1710:	e8 f4 27 00 00       	call   3f09 <open>
    1715:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    1718:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    171c:	79 19                	jns    1737 <linktest+0x68>
    printf(1, "create lf1 failed\n");
    171e:	c7 44 24 04 db 4b 00 	movl   $0x4bdb,0x4(%esp)
    1725:	00 
    1726:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    172d:	e8 17 29 00 00       	call   4049 <printf>
    exit();
    1732:	e8 92 27 00 00       	call   3ec9 <exit>
  }
  if(write(fd, "hello", 5) != 5){
    1737:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
    173e:	00 
    173f:	c7 44 24 04 37 4b 00 	movl   $0x4b37,0x4(%esp)
    1746:	00 
    1747:	8b 45 f4             	mov    -0xc(%ebp),%eax
    174a:	89 04 24             	mov    %eax,(%esp)
    174d:	e8 97 27 00 00       	call   3ee9 <write>
    1752:	83 f8 05             	cmp    $0x5,%eax
    1755:	74 19                	je     1770 <linktest+0xa1>
    printf(1, "write lf1 failed\n");
    1757:	c7 44 24 04 ee 4b 00 	movl   $0x4bee,0x4(%esp)
    175e:	00 
    175f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1766:	e8 de 28 00 00       	call   4049 <printf>
    exit();
    176b:	e8 59 27 00 00       	call   3ec9 <exit>
  }
  close(fd);
    1770:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1773:	89 04 24             	mov    %eax,(%esp)
    1776:	e8 76 27 00 00       	call   3ef1 <close>

  if(link("lf1", "lf2") < 0){
    177b:	c7 44 24 04 d7 4b 00 	movl   $0x4bd7,0x4(%esp)
    1782:	00 
    1783:	c7 04 24 d3 4b 00 00 	movl   $0x4bd3,(%esp)
    178a:	e8 9a 27 00 00       	call   3f29 <link>
    178f:	85 c0                	test   %eax,%eax
    1791:	79 19                	jns    17ac <linktest+0xdd>
    printf(1, "link lf1 lf2 failed\n");
    1793:	c7 44 24 04 00 4c 00 	movl   $0x4c00,0x4(%esp)
    179a:	00 
    179b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    17a2:	e8 a2 28 00 00       	call   4049 <printf>
    exit();
    17a7:	e8 1d 27 00 00       	call   3ec9 <exit>
  }
  unlink("lf1");
    17ac:	c7 04 24 d3 4b 00 00 	movl   $0x4bd3,(%esp)
    17b3:	e8 61 27 00 00       	call   3f19 <unlink>

  if(open("lf1", 0) >= 0){
    17b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    17bf:	00 
    17c0:	c7 04 24 d3 4b 00 00 	movl   $0x4bd3,(%esp)
    17c7:	e8 3d 27 00 00       	call   3f09 <open>
    17cc:	85 c0                	test   %eax,%eax
    17ce:	78 19                	js     17e9 <linktest+0x11a>
    printf(1, "unlinked lf1 but it is still there!\n");
    17d0:	c7 44 24 04 18 4c 00 	movl   $0x4c18,0x4(%esp)
    17d7:	00 
    17d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    17df:	e8 65 28 00 00       	call   4049 <printf>
    exit();
    17e4:	e8 e0 26 00 00       	call   3ec9 <exit>
  }

  fd = open("lf2", 0);
    17e9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    17f0:	00 
    17f1:	c7 04 24 d7 4b 00 00 	movl   $0x4bd7,(%esp)
    17f8:	e8 0c 27 00 00       	call   3f09 <open>
    17fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    1800:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1804:	79 19                	jns    181f <linktest+0x150>
    printf(1, "open lf2 failed\n");
    1806:	c7 44 24 04 3d 4c 00 	movl   $0x4c3d,0x4(%esp)
    180d:	00 
    180e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1815:	e8 2f 28 00 00       	call   4049 <printf>
    exit();
    181a:	e8 aa 26 00 00       	call   3ec9 <exit>
  }
  if(read(fd, buf, sizeof(buf)) != 5){
    181f:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    1826:	00 
    1827:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
    182e:	00 
    182f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1832:	89 04 24             	mov    %eax,(%esp)
    1835:	e8 a7 26 00 00       	call   3ee1 <read>
    183a:	83 f8 05             	cmp    $0x5,%eax
    183d:	74 19                	je     1858 <linktest+0x189>
    printf(1, "read lf2 failed\n");
    183f:	c7 44 24 04 4e 4c 00 	movl   $0x4c4e,0x4(%esp)
    1846:	00 
    1847:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    184e:	e8 f6 27 00 00       	call   4049 <printf>
    exit();
    1853:	e8 71 26 00 00       	call   3ec9 <exit>
  }
  close(fd);
    1858:	8b 45 f4             	mov    -0xc(%ebp),%eax
    185b:	89 04 24             	mov    %eax,(%esp)
    185e:	e8 8e 26 00 00       	call   3ef1 <close>

  if(link("lf2", "lf2") >= 0){
    1863:	c7 44 24 04 d7 4b 00 	movl   $0x4bd7,0x4(%esp)
    186a:	00 
    186b:	c7 04 24 d7 4b 00 00 	movl   $0x4bd7,(%esp)
    1872:	e8 b2 26 00 00       	call   3f29 <link>
    1877:	85 c0                	test   %eax,%eax
    1879:	78 19                	js     1894 <linktest+0x1c5>
    printf(1, "link lf2 lf2 succeeded! oops\n");
    187b:	c7 44 24 04 5f 4c 00 	movl   $0x4c5f,0x4(%esp)
    1882:	00 
    1883:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    188a:	e8 ba 27 00 00       	call   4049 <printf>
    exit();
    188f:	e8 35 26 00 00       	call   3ec9 <exit>
  }

  unlink("lf2");
    1894:	c7 04 24 d7 4b 00 00 	movl   $0x4bd7,(%esp)
    189b:	e8 79 26 00 00       	call   3f19 <unlink>
  if(link("lf2", "lf1") >= 0){
    18a0:	c7 44 24 04 d3 4b 00 	movl   $0x4bd3,0x4(%esp)
    18a7:	00 
    18a8:	c7 04 24 d7 4b 00 00 	movl   $0x4bd7,(%esp)
    18af:	e8 75 26 00 00       	call   3f29 <link>
    18b4:	85 c0                	test   %eax,%eax
    18b6:	78 19                	js     18d1 <linktest+0x202>
    printf(1, "link non-existant succeeded! oops\n");
    18b8:	c7 44 24 04 80 4c 00 	movl   $0x4c80,0x4(%esp)
    18bf:	00 
    18c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    18c7:	e8 7d 27 00 00       	call   4049 <printf>
    exit();
    18cc:	e8 f8 25 00 00       	call   3ec9 <exit>
  }

  if(link(".", "lf1") >= 0){
    18d1:	c7 44 24 04 d3 4b 00 	movl   $0x4bd3,0x4(%esp)
    18d8:	00 
    18d9:	c7 04 24 a3 4c 00 00 	movl   $0x4ca3,(%esp)
    18e0:	e8 44 26 00 00       	call   3f29 <link>
    18e5:	85 c0                	test   %eax,%eax
    18e7:	78 19                	js     1902 <linktest+0x233>
    printf(1, "link . lf1 succeeded! oops\n");
    18e9:	c7 44 24 04 a5 4c 00 	movl   $0x4ca5,0x4(%esp)
    18f0:	00 
    18f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    18f8:	e8 4c 27 00 00       	call   4049 <printf>
    exit();
    18fd:	e8 c7 25 00 00       	call   3ec9 <exit>
  }

  printf(1, "linktest ok\n");
    1902:	c7 44 24 04 c1 4c 00 	movl   $0x4cc1,0x4(%esp)
    1909:	00 
    190a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1911:	e8 33 27 00 00       	call   4049 <printf>
}
    1916:	c9                   	leave  
    1917:	c3                   	ret    

00001918 <concreate>:

// test concurrent create/link/unlink of the same file
void
concreate(void)
{
    1918:	55                   	push   %ebp
    1919:	89 e5                	mov    %esp,%ebp
    191b:	83 ec 68             	sub    $0x68,%esp
  struct {
    ushort inum;
    char name[14];
  } de;

  printf(1, "concreate test\n");
    191e:	c7 44 24 04 ce 4c 00 	movl   $0x4cce,0x4(%esp)
    1925:	00 
    1926:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    192d:	e8 17 27 00 00       	call   4049 <printf>
  file[0] = 'C';
    1932:	c6 45 e5 43          	movb   $0x43,-0x1b(%ebp)
  file[2] = '\0';
    1936:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
  for(i = 0; i < 40; i++){
    193a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1941:	e9 f7 00 00 00       	jmp    1a3d <concreate+0x125>
    file[1] = '0' + i;
    1946:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1949:	83 c0 30             	add    $0x30,%eax
    194c:	88 45 e6             	mov    %al,-0x1a(%ebp)
    unlink(file);
    194f:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1952:	89 04 24             	mov    %eax,(%esp)
    1955:	e8 bf 25 00 00       	call   3f19 <unlink>
    pid = fork();
    195a:	e8 62 25 00 00       	call   3ec1 <fork>
    195f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(pid && (i % 3) == 1){
    1962:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1966:	74 3a                	je     19a2 <concreate+0x8a>
    1968:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    196b:	ba 56 55 55 55       	mov    $0x55555556,%edx
    1970:	89 c8                	mov    %ecx,%eax
    1972:	f7 ea                	imul   %edx
    1974:	89 c8                	mov    %ecx,%eax
    1976:	c1 f8 1f             	sar    $0x1f,%eax
    1979:	29 c2                	sub    %eax,%edx
    197b:	89 d0                	mov    %edx,%eax
    197d:	01 c0                	add    %eax,%eax
    197f:	01 d0                	add    %edx,%eax
    1981:	29 c1                	sub    %eax,%ecx
    1983:	89 ca                	mov    %ecx,%edx
    1985:	83 fa 01             	cmp    $0x1,%edx
    1988:	75 18                	jne    19a2 <concreate+0x8a>
      link("C0", file);
    198a:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    198d:	89 44 24 04          	mov    %eax,0x4(%esp)
    1991:	c7 04 24 de 4c 00 00 	movl   $0x4cde,(%esp)
    1998:	e8 8c 25 00 00       	call   3f29 <link>
    199d:	e9 87 00 00 00       	jmp    1a29 <concreate+0x111>
    } else if(pid == 0 && (i % 5) == 1){
    19a2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    19a6:	75 3a                	jne    19e2 <concreate+0xca>
    19a8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    19ab:	ba 67 66 66 66       	mov    $0x66666667,%edx
    19b0:	89 c8                	mov    %ecx,%eax
    19b2:	f7 ea                	imul   %edx
    19b4:	d1 fa                	sar    %edx
    19b6:	89 c8                	mov    %ecx,%eax
    19b8:	c1 f8 1f             	sar    $0x1f,%eax
    19bb:	29 c2                	sub    %eax,%edx
    19bd:	89 d0                	mov    %edx,%eax
    19bf:	c1 e0 02             	shl    $0x2,%eax
    19c2:	01 d0                	add    %edx,%eax
    19c4:	29 c1                	sub    %eax,%ecx
    19c6:	89 ca                	mov    %ecx,%edx
    19c8:	83 fa 01             	cmp    $0x1,%edx
    19cb:	75 15                	jne    19e2 <concreate+0xca>
      link("C0", file);
    19cd:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    19d0:	89 44 24 04          	mov    %eax,0x4(%esp)
    19d4:	c7 04 24 de 4c 00 00 	movl   $0x4cde,(%esp)
    19db:	e8 49 25 00 00       	call   3f29 <link>
    19e0:	eb 47                	jmp    1a29 <concreate+0x111>
    } else {
      fd = open(file, O_CREATE | O_RDWR);
    19e2:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    19e9:	00 
    19ea:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    19ed:	89 04 24             	mov    %eax,(%esp)
    19f0:	e8 14 25 00 00       	call   3f09 <open>
    19f5:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(fd < 0){
    19f8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    19fc:	79 20                	jns    1a1e <concreate+0x106>
        printf(1, "concreate create %s failed\n", file);
    19fe:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1a01:	89 44 24 08          	mov    %eax,0x8(%esp)
    1a05:	c7 44 24 04 e1 4c 00 	movl   $0x4ce1,0x4(%esp)
    1a0c:	00 
    1a0d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1a14:	e8 30 26 00 00       	call   4049 <printf>
        exit();
    1a19:	e8 ab 24 00 00       	call   3ec9 <exit>
      }
      close(fd);
    1a1e:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1a21:	89 04 24             	mov    %eax,(%esp)
    1a24:	e8 c8 24 00 00       	call   3ef1 <close>
    }
    if(pid == 0)
    1a29:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1a2d:	75 05                	jne    1a34 <concreate+0x11c>
      exit();
    1a2f:	e8 95 24 00 00       	call   3ec9 <exit>
    else
      wait();
    1a34:	e8 98 24 00 00       	call   3ed1 <wait>
  } de;

  printf(1, "concreate test\n");
  file[0] = 'C';
  file[2] = '\0';
  for(i = 0; i < 40; i++){
    1a39:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1a3d:	83 7d f4 27          	cmpl   $0x27,-0xc(%ebp)
    1a41:	0f 8e ff fe ff ff    	jle    1946 <concreate+0x2e>
      exit();
    else
      wait();
  }

  memset(fa, 0, sizeof(fa));
    1a47:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
    1a4e:	00 
    1a4f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1a56:	00 
    1a57:	8d 45 bd             	lea    -0x43(%ebp),%eax
    1a5a:	89 04 24             	mov    %eax,(%esp)
    1a5d:	e8 ba 22 00 00       	call   3d1c <memset>
  fd = open(".", 0);
    1a62:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1a69:	00 
    1a6a:	c7 04 24 a3 4c 00 00 	movl   $0x4ca3,(%esp)
    1a71:	e8 93 24 00 00       	call   3f09 <open>
    1a76:	89 45 e8             	mov    %eax,-0x18(%ebp)
  n = 0;
    1a79:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  while(read(fd, &de, sizeof(de)) > 0){
    1a80:	e9 a1 00 00 00       	jmp    1b26 <concreate+0x20e>
    if(de.inum == 0)
    1a85:	0f b7 45 ac          	movzwl -0x54(%ebp),%eax
    1a89:	66 85 c0             	test   %ax,%ax
    1a8c:	75 05                	jne    1a93 <concreate+0x17b>
      continue;
    1a8e:	e9 93 00 00 00       	jmp    1b26 <concreate+0x20e>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    1a93:	0f b6 45 ae          	movzbl -0x52(%ebp),%eax
    1a97:	3c 43                	cmp    $0x43,%al
    1a99:	0f 85 87 00 00 00    	jne    1b26 <concreate+0x20e>
    1a9f:	0f b6 45 b0          	movzbl -0x50(%ebp),%eax
    1aa3:	84 c0                	test   %al,%al
    1aa5:	75 7f                	jne    1b26 <concreate+0x20e>
      i = de.name[1] - '0';
    1aa7:	0f b6 45 af          	movzbl -0x51(%ebp),%eax
    1aab:	0f be c0             	movsbl %al,%eax
    1aae:	83 e8 30             	sub    $0x30,%eax
    1ab1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if(i < 0 || i >= sizeof(fa)){
    1ab4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1ab8:	78 08                	js     1ac2 <concreate+0x1aa>
    1aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1abd:	83 f8 27             	cmp    $0x27,%eax
    1ac0:	76 23                	jbe    1ae5 <concreate+0x1cd>
        printf(1, "concreate weird file %s\n", de.name);
    1ac2:	8d 45 ac             	lea    -0x54(%ebp),%eax
    1ac5:	83 c0 02             	add    $0x2,%eax
    1ac8:	89 44 24 08          	mov    %eax,0x8(%esp)
    1acc:	c7 44 24 04 fd 4c 00 	movl   $0x4cfd,0x4(%esp)
    1ad3:	00 
    1ad4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1adb:	e8 69 25 00 00       	call   4049 <printf>
        exit();
    1ae0:	e8 e4 23 00 00       	call   3ec9 <exit>
      }
      if(fa[i]){
    1ae5:	8d 55 bd             	lea    -0x43(%ebp),%edx
    1ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1aeb:	01 d0                	add    %edx,%eax
    1aed:	0f b6 00             	movzbl (%eax),%eax
    1af0:	84 c0                	test   %al,%al
    1af2:	74 23                	je     1b17 <concreate+0x1ff>
        printf(1, "concreate duplicate file %s\n", de.name);
    1af4:	8d 45 ac             	lea    -0x54(%ebp),%eax
    1af7:	83 c0 02             	add    $0x2,%eax
    1afa:	89 44 24 08          	mov    %eax,0x8(%esp)
    1afe:	c7 44 24 04 16 4d 00 	movl   $0x4d16,0x4(%esp)
    1b05:	00 
    1b06:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1b0d:	e8 37 25 00 00       	call   4049 <printf>
        exit();
    1b12:	e8 b2 23 00 00       	call   3ec9 <exit>
      }
      fa[i] = 1;
    1b17:	8d 55 bd             	lea    -0x43(%ebp),%edx
    1b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1b1d:	01 d0                	add    %edx,%eax
    1b1f:	c6 00 01             	movb   $0x1,(%eax)
      n++;
    1b22:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  }

  memset(fa, 0, sizeof(fa));
  fd = open(".", 0);
  n = 0;
  while(read(fd, &de, sizeof(de)) > 0){
    1b26:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    1b2d:	00 
    1b2e:	8d 45 ac             	lea    -0x54(%ebp),%eax
    1b31:	89 44 24 04          	mov    %eax,0x4(%esp)
    1b35:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1b38:	89 04 24             	mov    %eax,(%esp)
    1b3b:	e8 a1 23 00 00       	call   3ee1 <read>
    1b40:	85 c0                	test   %eax,%eax
    1b42:	0f 8f 3d ff ff ff    	jg     1a85 <concreate+0x16d>
      }
      fa[i] = 1;
      n++;
    }
  }
  close(fd);
    1b48:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1b4b:	89 04 24             	mov    %eax,(%esp)
    1b4e:	e8 9e 23 00 00       	call   3ef1 <close>

  if(n != 40){
    1b53:	83 7d f0 28          	cmpl   $0x28,-0x10(%ebp)
    1b57:	74 19                	je     1b72 <concreate+0x25a>
    printf(1, "concreate not enough files in directory listing\n");
    1b59:	c7 44 24 04 34 4d 00 	movl   $0x4d34,0x4(%esp)
    1b60:	00 
    1b61:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1b68:	e8 dc 24 00 00       	call   4049 <printf>
    exit();
    1b6d:	e8 57 23 00 00       	call   3ec9 <exit>
  }

  for(i = 0; i < 40; i++){
    1b72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1b79:	e9 2d 01 00 00       	jmp    1cab <concreate+0x393>
    file[1] = '0' + i;
    1b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1b81:	83 c0 30             	add    $0x30,%eax
    1b84:	88 45 e6             	mov    %al,-0x1a(%ebp)
    pid = fork();
    1b87:	e8 35 23 00 00       	call   3ec1 <fork>
    1b8c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(pid < 0){
    1b8f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1b93:	79 19                	jns    1bae <concreate+0x296>
      printf(1, "fork failed\n");
    1b95:	c7 44 24 04 b9 44 00 	movl   $0x44b9,0x4(%esp)
    1b9c:	00 
    1b9d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1ba4:	e8 a0 24 00 00       	call   4049 <printf>
      exit();
    1ba9:	e8 1b 23 00 00       	call   3ec9 <exit>
    }
    if(((i % 3) == 0 && pid == 0) ||
    1bae:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1bb1:	ba 56 55 55 55       	mov    $0x55555556,%edx
    1bb6:	89 c8                	mov    %ecx,%eax
    1bb8:	f7 ea                	imul   %edx
    1bba:	89 c8                	mov    %ecx,%eax
    1bbc:	c1 f8 1f             	sar    $0x1f,%eax
    1bbf:	29 c2                	sub    %eax,%edx
    1bc1:	89 d0                	mov    %edx,%eax
    1bc3:	01 c0                	add    %eax,%eax
    1bc5:	01 d0                	add    %edx,%eax
    1bc7:	29 c1                	sub    %eax,%ecx
    1bc9:	89 ca                	mov    %ecx,%edx
    1bcb:	85 d2                	test   %edx,%edx
    1bcd:	75 06                	jne    1bd5 <concreate+0x2bd>
    1bcf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1bd3:	74 28                	je     1bfd <concreate+0x2e5>
       ((i % 3) == 1 && pid != 0)){
    1bd5:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1bd8:	ba 56 55 55 55       	mov    $0x55555556,%edx
    1bdd:	89 c8                	mov    %ecx,%eax
    1bdf:	f7 ea                	imul   %edx
    1be1:	89 c8                	mov    %ecx,%eax
    1be3:	c1 f8 1f             	sar    $0x1f,%eax
    1be6:	29 c2                	sub    %eax,%edx
    1be8:	89 d0                	mov    %edx,%eax
    1bea:	01 c0                	add    %eax,%eax
    1bec:	01 d0                	add    %edx,%eax
    1bee:	29 c1                	sub    %eax,%ecx
    1bf0:	89 ca                	mov    %ecx,%edx
    pid = fork();
    if(pid < 0){
      printf(1, "fork failed\n");
      exit();
    }
    if(((i % 3) == 0 && pid == 0) ||
    1bf2:	83 fa 01             	cmp    $0x1,%edx
    1bf5:	75 74                	jne    1c6b <concreate+0x353>
       ((i % 3) == 1 && pid != 0)){
    1bf7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1bfb:	74 6e                	je     1c6b <concreate+0x353>
      close(open(file, 0));
    1bfd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1c04:	00 
    1c05:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1c08:	89 04 24             	mov    %eax,(%esp)
    1c0b:	e8 f9 22 00 00       	call   3f09 <open>
    1c10:	89 04 24             	mov    %eax,(%esp)
    1c13:	e8 d9 22 00 00       	call   3ef1 <close>
      close(open(file, 0));
    1c18:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1c1f:	00 
    1c20:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1c23:	89 04 24             	mov    %eax,(%esp)
    1c26:	e8 de 22 00 00       	call   3f09 <open>
    1c2b:	89 04 24             	mov    %eax,(%esp)
    1c2e:	e8 be 22 00 00       	call   3ef1 <close>
      close(open(file, 0));
    1c33:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1c3a:	00 
    1c3b:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1c3e:	89 04 24             	mov    %eax,(%esp)
    1c41:	e8 c3 22 00 00       	call   3f09 <open>
    1c46:	89 04 24             	mov    %eax,(%esp)
    1c49:	e8 a3 22 00 00       	call   3ef1 <close>
      close(open(file, 0));
    1c4e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1c55:	00 
    1c56:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1c59:	89 04 24             	mov    %eax,(%esp)
    1c5c:	e8 a8 22 00 00       	call   3f09 <open>
    1c61:	89 04 24             	mov    %eax,(%esp)
    1c64:	e8 88 22 00 00       	call   3ef1 <close>
    1c69:	eb 2c                	jmp    1c97 <concreate+0x37f>
    } else {
      unlink(file);
    1c6b:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1c6e:	89 04 24             	mov    %eax,(%esp)
    1c71:	e8 a3 22 00 00       	call   3f19 <unlink>
      unlink(file);
    1c76:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1c79:	89 04 24             	mov    %eax,(%esp)
    1c7c:	e8 98 22 00 00       	call   3f19 <unlink>
      unlink(file);
    1c81:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1c84:	89 04 24             	mov    %eax,(%esp)
    1c87:	e8 8d 22 00 00       	call   3f19 <unlink>
      unlink(file);
    1c8c:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1c8f:	89 04 24             	mov    %eax,(%esp)
    1c92:	e8 82 22 00 00       	call   3f19 <unlink>
    }
    if(pid == 0)
    1c97:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1c9b:	75 05                	jne    1ca2 <concreate+0x38a>
      exit();
    1c9d:	e8 27 22 00 00       	call   3ec9 <exit>
    else
      wait();
    1ca2:	e8 2a 22 00 00       	call   3ed1 <wait>
  if(n != 40){
    printf(1, "concreate not enough files in directory listing\n");
    exit();
  }

  for(i = 0; i < 40; i++){
    1ca7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1cab:	83 7d f4 27          	cmpl   $0x27,-0xc(%ebp)
    1caf:	0f 8e c9 fe ff ff    	jle    1b7e <concreate+0x266>
      exit();
    else
      wait();
  }

  printf(1, "concreate ok\n");
    1cb5:	c7 44 24 04 65 4d 00 	movl   $0x4d65,0x4(%esp)
    1cbc:	00 
    1cbd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1cc4:	e8 80 23 00 00       	call   4049 <printf>
}
    1cc9:	c9                   	leave  
    1cca:	c3                   	ret    

00001ccb <linkunlink>:

// another concurrent link/unlink/create test,
// to look for deadlocks.
void
linkunlink()
{
    1ccb:	55                   	push   %ebp
    1ccc:	89 e5                	mov    %esp,%ebp
    1cce:	83 ec 28             	sub    $0x28,%esp
  int pid, i;

  printf(1, "linkunlink test\n");
    1cd1:	c7 44 24 04 73 4d 00 	movl   $0x4d73,0x4(%esp)
    1cd8:	00 
    1cd9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1ce0:	e8 64 23 00 00       	call   4049 <printf>

  unlink("x");
    1ce5:	c7 04 24 ef 48 00 00 	movl   $0x48ef,(%esp)
    1cec:	e8 28 22 00 00       	call   3f19 <unlink>
  pid = fork();
    1cf1:	e8 cb 21 00 00       	call   3ec1 <fork>
    1cf6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(pid < 0){
    1cf9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1cfd:	79 19                	jns    1d18 <linkunlink+0x4d>
    printf(1, "fork failed\n");
    1cff:	c7 44 24 04 b9 44 00 	movl   $0x44b9,0x4(%esp)
    1d06:	00 
    1d07:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1d0e:	e8 36 23 00 00       	call   4049 <printf>
    exit();
    1d13:	e8 b1 21 00 00       	call   3ec9 <exit>
  }

  unsigned int x = (pid ? 1 : 97);
    1d18:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1d1c:	74 07                	je     1d25 <linkunlink+0x5a>
    1d1e:	b8 01 00 00 00       	mov    $0x1,%eax
    1d23:	eb 05                	jmp    1d2a <linkunlink+0x5f>
    1d25:	b8 61 00 00 00       	mov    $0x61,%eax
    1d2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; i < 100; i++){
    1d2d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1d34:	e9 8e 00 00 00       	jmp    1dc7 <linkunlink+0xfc>
    x = x * 1103515245 + 12345;
    1d39:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1d3c:	69 c0 6d 4e c6 41    	imul   $0x41c64e6d,%eax,%eax
    1d42:	05 39 30 00 00       	add    $0x3039,%eax
    1d47:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((x % 3) == 0){
    1d4a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
    1d4d:	ba ab aa aa aa       	mov    $0xaaaaaaab,%edx
    1d52:	89 c8                	mov    %ecx,%eax
    1d54:	f7 e2                	mul    %edx
    1d56:	d1 ea                	shr    %edx
    1d58:	89 d0                	mov    %edx,%eax
    1d5a:	01 c0                	add    %eax,%eax
    1d5c:	01 d0                	add    %edx,%eax
    1d5e:	29 c1                	sub    %eax,%ecx
    1d60:	89 ca                	mov    %ecx,%edx
    1d62:	85 d2                	test   %edx,%edx
    1d64:	75 1e                	jne    1d84 <linkunlink+0xb9>
      close(open("x", O_RDWR | O_CREATE));
    1d66:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1d6d:	00 
    1d6e:	c7 04 24 ef 48 00 00 	movl   $0x48ef,(%esp)
    1d75:	e8 8f 21 00 00       	call   3f09 <open>
    1d7a:	89 04 24             	mov    %eax,(%esp)
    1d7d:	e8 6f 21 00 00       	call   3ef1 <close>
    1d82:	eb 3f                	jmp    1dc3 <linkunlink+0xf8>
    } else if((x % 3) == 1){
    1d84:	8b 4d f0             	mov    -0x10(%ebp),%ecx
    1d87:	ba ab aa aa aa       	mov    $0xaaaaaaab,%edx
    1d8c:	89 c8                	mov    %ecx,%eax
    1d8e:	f7 e2                	mul    %edx
    1d90:	d1 ea                	shr    %edx
    1d92:	89 d0                	mov    %edx,%eax
    1d94:	01 c0                	add    %eax,%eax
    1d96:	01 d0                	add    %edx,%eax
    1d98:	29 c1                	sub    %eax,%ecx
    1d9a:	89 ca                	mov    %ecx,%edx
    1d9c:	83 fa 01             	cmp    $0x1,%edx
    1d9f:	75 16                	jne    1db7 <linkunlink+0xec>
      link("cat", "x");
    1da1:	c7 44 24 04 ef 48 00 	movl   $0x48ef,0x4(%esp)
    1da8:	00 
    1da9:	c7 04 24 84 4d 00 00 	movl   $0x4d84,(%esp)
    1db0:	e8 74 21 00 00       	call   3f29 <link>
    1db5:	eb 0c                	jmp    1dc3 <linkunlink+0xf8>
    } else {
      unlink("x");
    1db7:	c7 04 24 ef 48 00 00 	movl   $0x48ef,(%esp)
    1dbe:	e8 56 21 00 00       	call   3f19 <unlink>
    printf(1, "fork failed\n");
    exit();
  }

  unsigned int x = (pid ? 1 : 97);
  for(i = 0; i < 100; i++){
    1dc3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1dc7:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
    1dcb:	0f 8e 68 ff ff ff    	jle    1d39 <linkunlink+0x6e>
    } else {
      unlink("x");
    }
  }

  if(pid)
    1dd1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1dd5:	74 07                	je     1dde <linkunlink+0x113>
    wait();
    1dd7:	e8 f5 20 00 00       	call   3ed1 <wait>
    1ddc:	eb 05                	jmp    1de3 <linkunlink+0x118>
  else 
    exit();
    1dde:	e8 e6 20 00 00       	call   3ec9 <exit>

  printf(1, "linkunlink ok\n");
    1de3:	c7 44 24 04 88 4d 00 	movl   $0x4d88,0x4(%esp)
    1dea:	00 
    1deb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1df2:	e8 52 22 00 00       	call   4049 <printf>
}
    1df7:	c9                   	leave  
    1df8:	c3                   	ret    

00001df9 <bigdir>:

// directory that uses indirect blocks
void
bigdir(void)
{
    1df9:	55                   	push   %ebp
    1dfa:	89 e5                	mov    %esp,%ebp
    1dfc:	83 ec 38             	sub    $0x38,%esp
  int i, fd;
  char name[10];

  printf(1, "bigdir test\n");
    1dff:	c7 44 24 04 97 4d 00 	movl   $0x4d97,0x4(%esp)
    1e06:	00 
    1e07:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1e0e:	e8 36 22 00 00       	call   4049 <printf>
  unlink("bd");
    1e13:	c7 04 24 a4 4d 00 00 	movl   $0x4da4,(%esp)
    1e1a:	e8 fa 20 00 00       	call   3f19 <unlink>

  fd = open("bd", O_CREATE);
    1e1f:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    1e26:	00 
    1e27:	c7 04 24 a4 4d 00 00 	movl   $0x4da4,(%esp)
    1e2e:	e8 d6 20 00 00       	call   3f09 <open>
    1e33:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(fd < 0){
    1e36:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1e3a:	79 19                	jns    1e55 <bigdir+0x5c>
    printf(1, "bigdir create failed\n");
    1e3c:	c7 44 24 04 a7 4d 00 	movl   $0x4da7,0x4(%esp)
    1e43:	00 
    1e44:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1e4b:	e8 f9 21 00 00       	call   4049 <printf>
    exit();
    1e50:	e8 74 20 00 00       	call   3ec9 <exit>
  }
  close(fd);
    1e55:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1e58:	89 04 24             	mov    %eax,(%esp)
    1e5b:	e8 91 20 00 00       	call   3ef1 <close>

  for(i = 0; i < 500; i++){
    1e60:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1e67:	eb 64                	jmp    1ecd <bigdir+0xd4>
    name[0] = 'x';
    1e69:	c6 45 e6 78          	movb   $0x78,-0x1a(%ebp)
    name[1] = '0' + (i / 64);
    1e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1e70:	8d 50 3f             	lea    0x3f(%eax),%edx
    1e73:	85 c0                	test   %eax,%eax
    1e75:	0f 48 c2             	cmovs  %edx,%eax
    1e78:	c1 f8 06             	sar    $0x6,%eax
    1e7b:	83 c0 30             	add    $0x30,%eax
    1e7e:	88 45 e7             	mov    %al,-0x19(%ebp)
    name[2] = '0' + (i % 64);
    1e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1e84:	99                   	cltd   
    1e85:	c1 ea 1a             	shr    $0x1a,%edx
    1e88:	01 d0                	add    %edx,%eax
    1e8a:	83 e0 3f             	and    $0x3f,%eax
    1e8d:	29 d0                	sub    %edx,%eax
    1e8f:	83 c0 30             	add    $0x30,%eax
    1e92:	88 45 e8             	mov    %al,-0x18(%ebp)
    name[3] = '\0';
    1e95:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
    if(link("bd", name) != 0){
    1e99:	8d 45 e6             	lea    -0x1a(%ebp),%eax
    1e9c:	89 44 24 04          	mov    %eax,0x4(%esp)
    1ea0:	c7 04 24 a4 4d 00 00 	movl   $0x4da4,(%esp)
    1ea7:	e8 7d 20 00 00       	call   3f29 <link>
    1eac:	85 c0                	test   %eax,%eax
    1eae:	74 19                	je     1ec9 <bigdir+0xd0>
      printf(1, "bigdir link failed\n");
    1eb0:	c7 44 24 04 bd 4d 00 	movl   $0x4dbd,0x4(%esp)
    1eb7:	00 
    1eb8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1ebf:	e8 85 21 00 00       	call   4049 <printf>
      exit();
    1ec4:	e8 00 20 00 00       	call   3ec9 <exit>
    printf(1, "bigdir create failed\n");
    exit();
  }
  close(fd);

  for(i = 0; i < 500; i++){
    1ec9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1ecd:	81 7d f4 f3 01 00 00 	cmpl   $0x1f3,-0xc(%ebp)
    1ed4:	7e 93                	jle    1e69 <bigdir+0x70>
      printf(1, "bigdir link failed\n");
      exit();
    }
  }

  unlink("bd");
    1ed6:	c7 04 24 a4 4d 00 00 	movl   $0x4da4,(%esp)
    1edd:	e8 37 20 00 00       	call   3f19 <unlink>
  for(i = 0; i < 500; i++){
    1ee2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1ee9:	eb 5c                	jmp    1f47 <bigdir+0x14e>
    name[0] = 'x';
    1eeb:	c6 45 e6 78          	movb   $0x78,-0x1a(%ebp)
    name[1] = '0' + (i / 64);
    1eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1ef2:	8d 50 3f             	lea    0x3f(%eax),%edx
    1ef5:	85 c0                	test   %eax,%eax
    1ef7:	0f 48 c2             	cmovs  %edx,%eax
    1efa:	c1 f8 06             	sar    $0x6,%eax
    1efd:	83 c0 30             	add    $0x30,%eax
    1f00:	88 45 e7             	mov    %al,-0x19(%ebp)
    name[2] = '0' + (i % 64);
    1f03:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1f06:	99                   	cltd   
    1f07:	c1 ea 1a             	shr    $0x1a,%edx
    1f0a:	01 d0                	add    %edx,%eax
    1f0c:	83 e0 3f             	and    $0x3f,%eax
    1f0f:	29 d0                	sub    %edx,%eax
    1f11:	83 c0 30             	add    $0x30,%eax
    1f14:	88 45 e8             	mov    %al,-0x18(%ebp)
    name[3] = '\0';
    1f17:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
    if(unlink(name) != 0){
    1f1b:	8d 45 e6             	lea    -0x1a(%ebp),%eax
    1f1e:	89 04 24             	mov    %eax,(%esp)
    1f21:	e8 f3 1f 00 00       	call   3f19 <unlink>
    1f26:	85 c0                	test   %eax,%eax
    1f28:	74 19                	je     1f43 <bigdir+0x14a>
      printf(1, "bigdir unlink failed");
    1f2a:	c7 44 24 04 d1 4d 00 	movl   $0x4dd1,0x4(%esp)
    1f31:	00 
    1f32:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f39:	e8 0b 21 00 00       	call   4049 <printf>
      exit();
    1f3e:	e8 86 1f 00 00       	call   3ec9 <exit>
      exit();
    }
  }

  unlink("bd");
  for(i = 0; i < 500; i++){
    1f43:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1f47:	81 7d f4 f3 01 00 00 	cmpl   $0x1f3,-0xc(%ebp)
    1f4e:	7e 9b                	jle    1eeb <bigdir+0xf2>
      printf(1, "bigdir unlink failed");
      exit();
    }
  }

  printf(1, "bigdir ok\n");
    1f50:	c7 44 24 04 e6 4d 00 	movl   $0x4de6,0x4(%esp)
    1f57:	00 
    1f58:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f5f:	e8 e5 20 00 00       	call   4049 <printf>
}
    1f64:	c9                   	leave  
    1f65:	c3                   	ret    

00001f66 <subdir>:

void
subdir(void)
{
    1f66:	55                   	push   %ebp
    1f67:	89 e5                	mov    %esp,%ebp
    1f69:	83 ec 28             	sub    $0x28,%esp
  int fd, cc;

  printf(1, "subdir test\n");
    1f6c:	c7 44 24 04 f1 4d 00 	movl   $0x4df1,0x4(%esp)
    1f73:	00 
    1f74:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f7b:	e8 c9 20 00 00       	call   4049 <printf>

  unlink("ff");
    1f80:	c7 04 24 fe 4d 00 00 	movl   $0x4dfe,(%esp)
    1f87:	e8 8d 1f 00 00       	call   3f19 <unlink>
  if(mkdir("dd") != 0){
    1f8c:	c7 04 24 01 4e 00 00 	movl   $0x4e01,(%esp)
    1f93:	e8 99 1f 00 00       	call   3f31 <mkdir>
    1f98:	85 c0                	test   %eax,%eax
    1f9a:	74 19                	je     1fb5 <subdir+0x4f>
    printf(1, "subdir mkdir dd failed\n");
    1f9c:	c7 44 24 04 04 4e 00 	movl   $0x4e04,0x4(%esp)
    1fa3:	00 
    1fa4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1fab:	e8 99 20 00 00       	call   4049 <printf>
    exit();
    1fb0:	e8 14 1f 00 00       	call   3ec9 <exit>
  }

  fd = open("dd/ff", O_CREATE | O_RDWR);
    1fb5:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1fbc:	00 
    1fbd:	c7 04 24 1c 4e 00 00 	movl   $0x4e1c,(%esp)
    1fc4:	e8 40 1f 00 00       	call   3f09 <open>
    1fc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    1fcc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1fd0:	79 19                	jns    1feb <subdir+0x85>
    printf(1, "create dd/ff failed\n");
    1fd2:	c7 44 24 04 22 4e 00 	movl   $0x4e22,0x4(%esp)
    1fd9:	00 
    1fda:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1fe1:	e8 63 20 00 00       	call   4049 <printf>
    exit();
    1fe6:	e8 de 1e 00 00       	call   3ec9 <exit>
  }
  write(fd, "ff", 2);
    1feb:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
    1ff2:	00 
    1ff3:	c7 44 24 04 fe 4d 00 	movl   $0x4dfe,0x4(%esp)
    1ffa:	00 
    1ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1ffe:	89 04 24             	mov    %eax,(%esp)
    2001:	e8 e3 1e 00 00       	call   3ee9 <write>
  close(fd);
    2006:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2009:	89 04 24             	mov    %eax,(%esp)
    200c:	e8 e0 1e 00 00       	call   3ef1 <close>
  
  if(unlink("dd") >= 0){
    2011:	c7 04 24 01 4e 00 00 	movl   $0x4e01,(%esp)
    2018:	e8 fc 1e 00 00       	call   3f19 <unlink>
    201d:	85 c0                	test   %eax,%eax
    201f:	78 19                	js     203a <subdir+0xd4>
    printf(1, "unlink dd (non-empty dir) succeeded!\n");
    2021:	c7 44 24 04 38 4e 00 	movl   $0x4e38,0x4(%esp)
    2028:	00 
    2029:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2030:	e8 14 20 00 00       	call   4049 <printf>
    exit();
    2035:	e8 8f 1e 00 00       	call   3ec9 <exit>
  }

  if(mkdir("/dd/dd") != 0){
    203a:	c7 04 24 5e 4e 00 00 	movl   $0x4e5e,(%esp)
    2041:	e8 eb 1e 00 00       	call   3f31 <mkdir>
    2046:	85 c0                	test   %eax,%eax
    2048:	74 19                	je     2063 <subdir+0xfd>
    printf(1, "subdir mkdir dd/dd failed\n");
    204a:	c7 44 24 04 65 4e 00 	movl   $0x4e65,0x4(%esp)
    2051:	00 
    2052:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2059:	e8 eb 1f 00 00       	call   4049 <printf>
    exit();
    205e:	e8 66 1e 00 00       	call   3ec9 <exit>
  }

  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    2063:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    206a:	00 
    206b:	c7 04 24 80 4e 00 00 	movl   $0x4e80,(%esp)
    2072:	e8 92 1e 00 00       	call   3f09 <open>
    2077:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    207a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    207e:	79 19                	jns    2099 <subdir+0x133>
    printf(1, "create dd/dd/ff failed\n");
    2080:	c7 44 24 04 89 4e 00 	movl   $0x4e89,0x4(%esp)
    2087:	00 
    2088:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    208f:	e8 b5 1f 00 00       	call   4049 <printf>
    exit();
    2094:	e8 30 1e 00 00       	call   3ec9 <exit>
  }
  write(fd, "FF", 2);
    2099:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
    20a0:	00 
    20a1:	c7 44 24 04 a1 4e 00 	movl   $0x4ea1,0x4(%esp)
    20a8:	00 
    20a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    20ac:	89 04 24             	mov    %eax,(%esp)
    20af:	e8 35 1e 00 00       	call   3ee9 <write>
  close(fd);
    20b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    20b7:	89 04 24             	mov    %eax,(%esp)
    20ba:	e8 32 1e 00 00       	call   3ef1 <close>

  fd = open("dd/dd/../ff", 0);
    20bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    20c6:	00 
    20c7:	c7 04 24 a4 4e 00 00 	movl   $0x4ea4,(%esp)
    20ce:	e8 36 1e 00 00       	call   3f09 <open>
    20d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    20d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    20da:	79 19                	jns    20f5 <subdir+0x18f>
    printf(1, "open dd/dd/../ff failed\n");
    20dc:	c7 44 24 04 b0 4e 00 	movl   $0x4eb0,0x4(%esp)
    20e3:	00 
    20e4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    20eb:	e8 59 1f 00 00       	call   4049 <printf>
    exit();
    20f0:	e8 d4 1d 00 00       	call   3ec9 <exit>
  }
  cc = read(fd, buf, sizeof(buf));
    20f5:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    20fc:	00 
    20fd:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
    2104:	00 
    2105:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2108:	89 04 24             	mov    %eax,(%esp)
    210b:	e8 d1 1d 00 00       	call   3ee1 <read>
    2110:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(cc != 2 || buf[0] != 'f'){
    2113:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
    2117:	75 0b                	jne    2124 <subdir+0x1be>
    2119:	0f b6 05 c0 8a 00 00 	movzbl 0x8ac0,%eax
    2120:	3c 66                	cmp    $0x66,%al
    2122:	74 19                	je     213d <subdir+0x1d7>
    printf(1, "dd/dd/../ff wrong content\n");
    2124:	c7 44 24 04 c9 4e 00 	movl   $0x4ec9,0x4(%esp)
    212b:	00 
    212c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2133:	e8 11 1f 00 00       	call   4049 <printf>
    exit();
    2138:	e8 8c 1d 00 00       	call   3ec9 <exit>
  }
  close(fd);
    213d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2140:	89 04 24             	mov    %eax,(%esp)
    2143:	e8 a9 1d 00 00       	call   3ef1 <close>

  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    2148:	c7 44 24 04 e4 4e 00 	movl   $0x4ee4,0x4(%esp)
    214f:	00 
    2150:	c7 04 24 80 4e 00 00 	movl   $0x4e80,(%esp)
    2157:	e8 cd 1d 00 00       	call   3f29 <link>
    215c:	85 c0                	test   %eax,%eax
    215e:	74 19                	je     2179 <subdir+0x213>
    printf(1, "link dd/dd/ff dd/dd/ffff failed\n");
    2160:	c7 44 24 04 f0 4e 00 	movl   $0x4ef0,0x4(%esp)
    2167:	00 
    2168:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    216f:	e8 d5 1e 00 00       	call   4049 <printf>
    exit();
    2174:	e8 50 1d 00 00       	call   3ec9 <exit>
  }

  if(unlink("dd/dd/ff") != 0){
    2179:	c7 04 24 80 4e 00 00 	movl   $0x4e80,(%esp)
    2180:	e8 94 1d 00 00       	call   3f19 <unlink>
    2185:	85 c0                	test   %eax,%eax
    2187:	74 19                	je     21a2 <subdir+0x23c>
    printf(1, "unlink dd/dd/ff failed\n");
    2189:	c7 44 24 04 11 4f 00 	movl   $0x4f11,0x4(%esp)
    2190:	00 
    2191:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2198:	e8 ac 1e 00 00       	call   4049 <printf>
    exit();
    219d:	e8 27 1d 00 00       	call   3ec9 <exit>
  }
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    21a2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    21a9:	00 
    21aa:	c7 04 24 80 4e 00 00 	movl   $0x4e80,(%esp)
    21b1:	e8 53 1d 00 00       	call   3f09 <open>
    21b6:	85 c0                	test   %eax,%eax
    21b8:	78 19                	js     21d3 <subdir+0x26d>
    printf(1, "open (unlinked) dd/dd/ff succeeded\n");
    21ba:	c7 44 24 04 2c 4f 00 	movl   $0x4f2c,0x4(%esp)
    21c1:	00 
    21c2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21c9:	e8 7b 1e 00 00       	call   4049 <printf>
    exit();
    21ce:	e8 f6 1c 00 00       	call   3ec9 <exit>
  }

  if(chdir("dd") != 0){
    21d3:	c7 04 24 01 4e 00 00 	movl   $0x4e01,(%esp)
    21da:	e8 5a 1d 00 00       	call   3f39 <chdir>
    21df:	85 c0                	test   %eax,%eax
    21e1:	74 19                	je     21fc <subdir+0x296>
    printf(1, "chdir dd failed\n");
    21e3:	c7 44 24 04 50 4f 00 	movl   $0x4f50,0x4(%esp)
    21ea:	00 
    21eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21f2:	e8 52 1e 00 00       	call   4049 <printf>
    exit();
    21f7:	e8 cd 1c 00 00       	call   3ec9 <exit>
  }
  if(chdir("dd/../../dd") != 0){
    21fc:	c7 04 24 61 4f 00 00 	movl   $0x4f61,(%esp)
    2203:	e8 31 1d 00 00       	call   3f39 <chdir>
    2208:	85 c0                	test   %eax,%eax
    220a:	74 19                	je     2225 <subdir+0x2bf>
    printf(1, "chdir dd/../../dd failed\n");
    220c:	c7 44 24 04 6d 4f 00 	movl   $0x4f6d,0x4(%esp)
    2213:	00 
    2214:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    221b:	e8 29 1e 00 00       	call   4049 <printf>
    exit();
    2220:	e8 a4 1c 00 00       	call   3ec9 <exit>
  }
  if(chdir("dd/../../../dd") != 0){
    2225:	c7 04 24 87 4f 00 00 	movl   $0x4f87,(%esp)
    222c:	e8 08 1d 00 00       	call   3f39 <chdir>
    2231:	85 c0                	test   %eax,%eax
    2233:	74 19                	je     224e <subdir+0x2e8>
    printf(1, "chdir dd/../../dd failed\n");
    2235:	c7 44 24 04 6d 4f 00 	movl   $0x4f6d,0x4(%esp)
    223c:	00 
    223d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2244:	e8 00 1e 00 00       	call   4049 <printf>
    exit();
    2249:	e8 7b 1c 00 00       	call   3ec9 <exit>
  }
  if(chdir("./..") != 0){
    224e:	c7 04 24 96 4f 00 00 	movl   $0x4f96,(%esp)
    2255:	e8 df 1c 00 00       	call   3f39 <chdir>
    225a:	85 c0                	test   %eax,%eax
    225c:	74 19                	je     2277 <subdir+0x311>
    printf(1, "chdir ./.. failed\n");
    225e:	c7 44 24 04 9b 4f 00 	movl   $0x4f9b,0x4(%esp)
    2265:	00 
    2266:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    226d:	e8 d7 1d 00 00       	call   4049 <printf>
    exit();
    2272:	e8 52 1c 00 00       	call   3ec9 <exit>
  }

  fd = open("dd/dd/ffff", 0);
    2277:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    227e:	00 
    227f:	c7 04 24 e4 4e 00 00 	movl   $0x4ee4,(%esp)
    2286:	e8 7e 1c 00 00       	call   3f09 <open>
    228b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    228e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2292:	79 19                	jns    22ad <subdir+0x347>
    printf(1, "open dd/dd/ffff failed\n");
    2294:	c7 44 24 04 ae 4f 00 	movl   $0x4fae,0x4(%esp)
    229b:	00 
    229c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    22a3:	e8 a1 1d 00 00       	call   4049 <printf>
    exit();
    22a8:	e8 1c 1c 00 00       	call   3ec9 <exit>
  }
  if(read(fd, buf, sizeof(buf)) != 2){
    22ad:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    22b4:	00 
    22b5:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
    22bc:	00 
    22bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    22c0:	89 04 24             	mov    %eax,(%esp)
    22c3:	e8 19 1c 00 00       	call   3ee1 <read>
    22c8:	83 f8 02             	cmp    $0x2,%eax
    22cb:	74 19                	je     22e6 <subdir+0x380>
    printf(1, "read dd/dd/ffff wrong len\n");
    22cd:	c7 44 24 04 c6 4f 00 	movl   $0x4fc6,0x4(%esp)
    22d4:	00 
    22d5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    22dc:	e8 68 1d 00 00       	call   4049 <printf>
    exit();
    22e1:	e8 e3 1b 00 00       	call   3ec9 <exit>
  }
  close(fd);
    22e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    22e9:	89 04 24             	mov    %eax,(%esp)
    22ec:	e8 00 1c 00 00       	call   3ef1 <close>

  if(open("dd/dd/ff", O_RDONLY) >= 0){
    22f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    22f8:	00 
    22f9:	c7 04 24 80 4e 00 00 	movl   $0x4e80,(%esp)
    2300:	e8 04 1c 00 00       	call   3f09 <open>
    2305:	85 c0                	test   %eax,%eax
    2307:	78 19                	js     2322 <subdir+0x3bc>
    printf(1, "open (unlinked) dd/dd/ff succeeded!\n");
    2309:	c7 44 24 04 e4 4f 00 	movl   $0x4fe4,0x4(%esp)
    2310:	00 
    2311:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2318:	e8 2c 1d 00 00       	call   4049 <printf>
    exit();
    231d:	e8 a7 1b 00 00       	call   3ec9 <exit>
  }

  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    2322:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    2329:	00 
    232a:	c7 04 24 09 50 00 00 	movl   $0x5009,(%esp)
    2331:	e8 d3 1b 00 00       	call   3f09 <open>
    2336:	85 c0                	test   %eax,%eax
    2338:	78 19                	js     2353 <subdir+0x3ed>
    printf(1, "create dd/ff/ff succeeded!\n");
    233a:	c7 44 24 04 12 50 00 	movl   $0x5012,0x4(%esp)
    2341:	00 
    2342:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2349:	e8 fb 1c 00 00       	call   4049 <printf>
    exit();
    234e:	e8 76 1b 00 00       	call   3ec9 <exit>
  }
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    2353:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    235a:	00 
    235b:	c7 04 24 2e 50 00 00 	movl   $0x502e,(%esp)
    2362:	e8 a2 1b 00 00       	call   3f09 <open>
    2367:	85 c0                	test   %eax,%eax
    2369:	78 19                	js     2384 <subdir+0x41e>
    printf(1, "create dd/xx/ff succeeded!\n");
    236b:	c7 44 24 04 37 50 00 	movl   $0x5037,0x4(%esp)
    2372:	00 
    2373:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    237a:	e8 ca 1c 00 00       	call   4049 <printf>
    exit();
    237f:	e8 45 1b 00 00       	call   3ec9 <exit>
  }
  if(open("dd", O_CREATE) >= 0){
    2384:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    238b:	00 
    238c:	c7 04 24 01 4e 00 00 	movl   $0x4e01,(%esp)
    2393:	e8 71 1b 00 00       	call   3f09 <open>
    2398:	85 c0                	test   %eax,%eax
    239a:	78 19                	js     23b5 <subdir+0x44f>
    printf(1, "create dd succeeded!\n");
    239c:	c7 44 24 04 53 50 00 	movl   $0x5053,0x4(%esp)
    23a3:	00 
    23a4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    23ab:	e8 99 1c 00 00       	call   4049 <printf>
    exit();
    23b0:	e8 14 1b 00 00       	call   3ec9 <exit>
  }
  if(open("dd", O_RDWR) >= 0){
    23b5:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    23bc:	00 
    23bd:	c7 04 24 01 4e 00 00 	movl   $0x4e01,(%esp)
    23c4:	e8 40 1b 00 00       	call   3f09 <open>
    23c9:	85 c0                	test   %eax,%eax
    23cb:	78 19                	js     23e6 <subdir+0x480>
    printf(1, "open dd rdwr succeeded!\n");
    23cd:	c7 44 24 04 69 50 00 	movl   $0x5069,0x4(%esp)
    23d4:	00 
    23d5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    23dc:	e8 68 1c 00 00       	call   4049 <printf>
    exit();
    23e1:	e8 e3 1a 00 00       	call   3ec9 <exit>
  }
  if(open("dd", O_WRONLY) >= 0){
    23e6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
    23ed:	00 
    23ee:	c7 04 24 01 4e 00 00 	movl   $0x4e01,(%esp)
    23f5:	e8 0f 1b 00 00       	call   3f09 <open>
    23fa:	85 c0                	test   %eax,%eax
    23fc:	78 19                	js     2417 <subdir+0x4b1>
    printf(1, "open dd wronly succeeded!\n");
    23fe:	c7 44 24 04 82 50 00 	movl   $0x5082,0x4(%esp)
    2405:	00 
    2406:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    240d:	e8 37 1c 00 00       	call   4049 <printf>
    exit();
    2412:	e8 b2 1a 00 00       	call   3ec9 <exit>
  }
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    2417:	c7 44 24 04 9d 50 00 	movl   $0x509d,0x4(%esp)
    241e:	00 
    241f:	c7 04 24 09 50 00 00 	movl   $0x5009,(%esp)
    2426:	e8 fe 1a 00 00       	call   3f29 <link>
    242b:	85 c0                	test   %eax,%eax
    242d:	75 19                	jne    2448 <subdir+0x4e2>
    printf(1, "link dd/ff/ff dd/dd/xx succeeded!\n");
    242f:	c7 44 24 04 a8 50 00 	movl   $0x50a8,0x4(%esp)
    2436:	00 
    2437:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    243e:	e8 06 1c 00 00       	call   4049 <printf>
    exit();
    2443:	e8 81 1a 00 00       	call   3ec9 <exit>
  }
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    2448:	c7 44 24 04 9d 50 00 	movl   $0x509d,0x4(%esp)
    244f:	00 
    2450:	c7 04 24 2e 50 00 00 	movl   $0x502e,(%esp)
    2457:	e8 cd 1a 00 00       	call   3f29 <link>
    245c:	85 c0                	test   %eax,%eax
    245e:	75 19                	jne    2479 <subdir+0x513>
    printf(1, "link dd/xx/ff dd/dd/xx succeeded!\n");
    2460:	c7 44 24 04 cc 50 00 	movl   $0x50cc,0x4(%esp)
    2467:	00 
    2468:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    246f:	e8 d5 1b 00 00       	call   4049 <printf>
    exit();
    2474:	e8 50 1a 00 00       	call   3ec9 <exit>
  }
  if(link("dd/ff", "dd/dd/ffff") == 0){
    2479:	c7 44 24 04 e4 4e 00 	movl   $0x4ee4,0x4(%esp)
    2480:	00 
    2481:	c7 04 24 1c 4e 00 00 	movl   $0x4e1c,(%esp)
    2488:	e8 9c 1a 00 00       	call   3f29 <link>
    248d:	85 c0                	test   %eax,%eax
    248f:	75 19                	jne    24aa <subdir+0x544>
    printf(1, "link dd/ff dd/dd/ffff succeeded!\n");
    2491:	c7 44 24 04 f0 50 00 	movl   $0x50f0,0x4(%esp)
    2498:	00 
    2499:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    24a0:	e8 a4 1b 00 00       	call   4049 <printf>
    exit();
    24a5:	e8 1f 1a 00 00       	call   3ec9 <exit>
  }
  if(mkdir("dd/ff/ff") == 0){
    24aa:	c7 04 24 09 50 00 00 	movl   $0x5009,(%esp)
    24b1:	e8 7b 1a 00 00       	call   3f31 <mkdir>
    24b6:	85 c0                	test   %eax,%eax
    24b8:	75 19                	jne    24d3 <subdir+0x56d>
    printf(1, "mkdir dd/ff/ff succeeded!\n");
    24ba:	c7 44 24 04 12 51 00 	movl   $0x5112,0x4(%esp)
    24c1:	00 
    24c2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    24c9:	e8 7b 1b 00 00       	call   4049 <printf>
    exit();
    24ce:	e8 f6 19 00 00       	call   3ec9 <exit>
  }
  if(mkdir("dd/xx/ff") == 0){
    24d3:	c7 04 24 2e 50 00 00 	movl   $0x502e,(%esp)
    24da:	e8 52 1a 00 00       	call   3f31 <mkdir>
    24df:	85 c0                	test   %eax,%eax
    24e1:	75 19                	jne    24fc <subdir+0x596>
    printf(1, "mkdir dd/xx/ff succeeded!\n");
    24e3:	c7 44 24 04 2d 51 00 	movl   $0x512d,0x4(%esp)
    24ea:	00 
    24eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    24f2:	e8 52 1b 00 00       	call   4049 <printf>
    exit();
    24f7:	e8 cd 19 00 00       	call   3ec9 <exit>
  }
  if(mkdir("dd/dd/ffff") == 0){
    24fc:	c7 04 24 e4 4e 00 00 	movl   $0x4ee4,(%esp)
    2503:	e8 29 1a 00 00       	call   3f31 <mkdir>
    2508:	85 c0                	test   %eax,%eax
    250a:	75 19                	jne    2525 <subdir+0x5bf>
    printf(1, "mkdir dd/dd/ffff succeeded!\n");
    250c:	c7 44 24 04 48 51 00 	movl   $0x5148,0x4(%esp)
    2513:	00 
    2514:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    251b:	e8 29 1b 00 00       	call   4049 <printf>
    exit();
    2520:	e8 a4 19 00 00       	call   3ec9 <exit>
  }
  if(unlink("dd/xx/ff") == 0){
    2525:	c7 04 24 2e 50 00 00 	movl   $0x502e,(%esp)
    252c:	e8 e8 19 00 00       	call   3f19 <unlink>
    2531:	85 c0                	test   %eax,%eax
    2533:	75 19                	jne    254e <subdir+0x5e8>
    printf(1, "unlink dd/xx/ff succeeded!\n");
    2535:	c7 44 24 04 65 51 00 	movl   $0x5165,0x4(%esp)
    253c:	00 
    253d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2544:	e8 00 1b 00 00       	call   4049 <printf>
    exit();
    2549:	e8 7b 19 00 00       	call   3ec9 <exit>
  }
  if(unlink("dd/ff/ff") == 0){
    254e:	c7 04 24 09 50 00 00 	movl   $0x5009,(%esp)
    2555:	e8 bf 19 00 00       	call   3f19 <unlink>
    255a:	85 c0                	test   %eax,%eax
    255c:	75 19                	jne    2577 <subdir+0x611>
    printf(1, "unlink dd/ff/ff succeeded!\n");
    255e:	c7 44 24 04 81 51 00 	movl   $0x5181,0x4(%esp)
    2565:	00 
    2566:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    256d:	e8 d7 1a 00 00       	call   4049 <printf>
    exit();
    2572:	e8 52 19 00 00       	call   3ec9 <exit>
  }
  if(chdir("dd/ff") == 0){
    2577:	c7 04 24 1c 4e 00 00 	movl   $0x4e1c,(%esp)
    257e:	e8 b6 19 00 00       	call   3f39 <chdir>
    2583:	85 c0                	test   %eax,%eax
    2585:	75 19                	jne    25a0 <subdir+0x63a>
    printf(1, "chdir dd/ff succeeded!\n");
    2587:	c7 44 24 04 9d 51 00 	movl   $0x519d,0x4(%esp)
    258e:	00 
    258f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2596:	e8 ae 1a 00 00       	call   4049 <printf>
    exit();
    259b:	e8 29 19 00 00       	call   3ec9 <exit>
  }
  if(chdir("dd/xx") == 0){
    25a0:	c7 04 24 b5 51 00 00 	movl   $0x51b5,(%esp)
    25a7:	e8 8d 19 00 00       	call   3f39 <chdir>
    25ac:	85 c0                	test   %eax,%eax
    25ae:	75 19                	jne    25c9 <subdir+0x663>
    printf(1, "chdir dd/xx succeeded!\n");
    25b0:	c7 44 24 04 bb 51 00 	movl   $0x51bb,0x4(%esp)
    25b7:	00 
    25b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    25bf:	e8 85 1a 00 00       	call   4049 <printf>
    exit();
    25c4:	e8 00 19 00 00       	call   3ec9 <exit>
  }

  if(unlink("dd/dd/ffff") != 0){
    25c9:	c7 04 24 e4 4e 00 00 	movl   $0x4ee4,(%esp)
    25d0:	e8 44 19 00 00       	call   3f19 <unlink>
    25d5:	85 c0                	test   %eax,%eax
    25d7:	74 19                	je     25f2 <subdir+0x68c>
    printf(1, "unlink dd/dd/ff failed\n");
    25d9:	c7 44 24 04 11 4f 00 	movl   $0x4f11,0x4(%esp)
    25e0:	00 
    25e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    25e8:	e8 5c 1a 00 00       	call   4049 <printf>
    exit();
    25ed:	e8 d7 18 00 00       	call   3ec9 <exit>
  }
  if(unlink("dd/ff") != 0){
    25f2:	c7 04 24 1c 4e 00 00 	movl   $0x4e1c,(%esp)
    25f9:	e8 1b 19 00 00       	call   3f19 <unlink>
    25fe:	85 c0                	test   %eax,%eax
    2600:	74 19                	je     261b <subdir+0x6b5>
    printf(1, "unlink dd/ff failed\n");
    2602:	c7 44 24 04 d3 51 00 	movl   $0x51d3,0x4(%esp)
    2609:	00 
    260a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2611:	e8 33 1a 00 00       	call   4049 <printf>
    exit();
    2616:	e8 ae 18 00 00       	call   3ec9 <exit>
  }
  if(unlink("dd") == 0){
    261b:	c7 04 24 01 4e 00 00 	movl   $0x4e01,(%esp)
    2622:	e8 f2 18 00 00       	call   3f19 <unlink>
    2627:	85 c0                	test   %eax,%eax
    2629:	75 19                	jne    2644 <subdir+0x6de>
    printf(1, "unlink non-empty dd succeeded!\n");
    262b:	c7 44 24 04 e8 51 00 	movl   $0x51e8,0x4(%esp)
    2632:	00 
    2633:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    263a:	e8 0a 1a 00 00       	call   4049 <printf>
    exit();
    263f:	e8 85 18 00 00       	call   3ec9 <exit>
  }
  if(unlink("dd/dd") < 0){
    2644:	c7 04 24 08 52 00 00 	movl   $0x5208,(%esp)
    264b:	e8 c9 18 00 00       	call   3f19 <unlink>
    2650:	85 c0                	test   %eax,%eax
    2652:	79 19                	jns    266d <subdir+0x707>
    printf(1, "unlink dd/dd failed\n");
    2654:	c7 44 24 04 0e 52 00 	movl   $0x520e,0x4(%esp)
    265b:	00 
    265c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2663:	e8 e1 19 00 00       	call   4049 <printf>
    exit();
    2668:	e8 5c 18 00 00       	call   3ec9 <exit>
  }
  if(unlink("dd") < 0){
    266d:	c7 04 24 01 4e 00 00 	movl   $0x4e01,(%esp)
    2674:	e8 a0 18 00 00       	call   3f19 <unlink>
    2679:	85 c0                	test   %eax,%eax
    267b:	79 19                	jns    2696 <subdir+0x730>
    printf(1, "unlink dd failed\n");
    267d:	c7 44 24 04 23 52 00 	movl   $0x5223,0x4(%esp)
    2684:	00 
    2685:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    268c:	e8 b8 19 00 00       	call   4049 <printf>
    exit();
    2691:	e8 33 18 00 00       	call   3ec9 <exit>
  }

  printf(1, "subdir ok\n");
    2696:	c7 44 24 04 35 52 00 	movl   $0x5235,0x4(%esp)
    269d:	00 
    269e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    26a5:	e8 9f 19 00 00       	call   4049 <printf>
}
    26aa:	c9                   	leave  
    26ab:	c3                   	ret    

000026ac <bigwrite>:

// test writes that are larger than the log.
void
bigwrite(void)
{
    26ac:	55                   	push   %ebp
    26ad:	89 e5                	mov    %esp,%ebp
    26af:	83 ec 28             	sub    $0x28,%esp
  int fd, sz;

  printf(1, "bigwrite test\n");
    26b2:	c7 44 24 04 40 52 00 	movl   $0x5240,0x4(%esp)
    26b9:	00 
    26ba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    26c1:	e8 83 19 00 00       	call   4049 <printf>

  unlink("bigwrite");
    26c6:	c7 04 24 4f 52 00 00 	movl   $0x524f,(%esp)
    26cd:	e8 47 18 00 00       	call   3f19 <unlink>
  for(sz = 499; sz < 12*512; sz += 471){
    26d2:	c7 45 f4 f3 01 00 00 	movl   $0x1f3,-0xc(%ebp)
    26d9:	e9 b3 00 00 00       	jmp    2791 <bigwrite+0xe5>
    fd = open("bigwrite", O_CREATE | O_RDWR);
    26de:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    26e5:	00 
    26e6:	c7 04 24 4f 52 00 00 	movl   $0x524f,(%esp)
    26ed:	e8 17 18 00 00       	call   3f09 <open>
    26f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(fd < 0){
    26f5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    26f9:	79 19                	jns    2714 <bigwrite+0x68>
      printf(1, "cannot create bigwrite\n");
    26fb:	c7 44 24 04 58 52 00 	movl   $0x5258,0x4(%esp)
    2702:	00 
    2703:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    270a:	e8 3a 19 00 00       	call   4049 <printf>
      exit();
    270f:	e8 b5 17 00 00       	call   3ec9 <exit>
    }
    int i;
    for(i = 0; i < 2; i++){
    2714:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    271b:	eb 50                	jmp    276d <bigwrite+0xc1>
      int cc = write(fd, buf, sz);
    271d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2720:	89 44 24 08          	mov    %eax,0x8(%esp)
    2724:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
    272b:	00 
    272c:	8b 45 ec             	mov    -0x14(%ebp),%eax
    272f:	89 04 24             	mov    %eax,(%esp)
    2732:	e8 b2 17 00 00       	call   3ee9 <write>
    2737:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(cc != sz){
    273a:	8b 45 e8             	mov    -0x18(%ebp),%eax
    273d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    2740:	74 27                	je     2769 <bigwrite+0xbd>
        printf(1, "write(%d) ret %d\n", sz, cc);
    2742:	8b 45 e8             	mov    -0x18(%ebp),%eax
    2745:	89 44 24 0c          	mov    %eax,0xc(%esp)
    2749:	8b 45 f4             	mov    -0xc(%ebp),%eax
    274c:	89 44 24 08          	mov    %eax,0x8(%esp)
    2750:	c7 44 24 04 70 52 00 	movl   $0x5270,0x4(%esp)
    2757:	00 
    2758:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    275f:	e8 e5 18 00 00       	call   4049 <printf>
        exit();
    2764:	e8 60 17 00 00       	call   3ec9 <exit>
    if(fd < 0){
      printf(1, "cannot create bigwrite\n");
      exit();
    }
    int i;
    for(i = 0; i < 2; i++){
    2769:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    276d:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
    2771:	7e aa                	jle    271d <bigwrite+0x71>
      if(cc != sz){
        printf(1, "write(%d) ret %d\n", sz, cc);
        exit();
      }
    }
    close(fd);
    2773:	8b 45 ec             	mov    -0x14(%ebp),%eax
    2776:	89 04 24             	mov    %eax,(%esp)
    2779:	e8 73 17 00 00       	call   3ef1 <close>
    unlink("bigwrite");
    277e:	c7 04 24 4f 52 00 00 	movl   $0x524f,(%esp)
    2785:	e8 8f 17 00 00       	call   3f19 <unlink>
  int fd, sz;

  printf(1, "bigwrite test\n");

  unlink("bigwrite");
  for(sz = 499; sz < 12*512; sz += 471){
    278a:	81 45 f4 d7 01 00 00 	addl   $0x1d7,-0xc(%ebp)
    2791:	81 7d f4 ff 17 00 00 	cmpl   $0x17ff,-0xc(%ebp)
    2798:	0f 8e 40 ff ff ff    	jle    26de <bigwrite+0x32>
    }
    close(fd);
    unlink("bigwrite");
  }

  printf(1, "bigwrite ok\n");
    279e:	c7 44 24 04 82 52 00 	movl   $0x5282,0x4(%esp)
    27a5:	00 
    27a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    27ad:	e8 97 18 00 00       	call   4049 <printf>
}
    27b2:	c9                   	leave  
    27b3:	c3                   	ret    

000027b4 <bigfile>:

void
bigfile(void)
{
    27b4:	55                   	push   %ebp
    27b5:	89 e5                	mov    %esp,%ebp
    27b7:	83 ec 28             	sub    $0x28,%esp
  int fd, i, total, cc;

  printf(1, "bigfile test\n");
    27ba:	c7 44 24 04 8f 52 00 	movl   $0x528f,0x4(%esp)
    27c1:	00 
    27c2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    27c9:	e8 7b 18 00 00       	call   4049 <printf>

  unlink("bigfile");
    27ce:	c7 04 24 9d 52 00 00 	movl   $0x529d,(%esp)
    27d5:	e8 3f 17 00 00       	call   3f19 <unlink>
  fd = open("bigfile", O_CREATE | O_RDWR);
    27da:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    27e1:	00 
    27e2:	c7 04 24 9d 52 00 00 	movl   $0x529d,(%esp)
    27e9:	e8 1b 17 00 00       	call   3f09 <open>
    27ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    27f1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    27f5:	79 19                	jns    2810 <bigfile+0x5c>
    printf(1, "cannot create bigfile");
    27f7:	c7 44 24 04 a5 52 00 	movl   $0x52a5,0x4(%esp)
    27fe:	00 
    27ff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2806:	e8 3e 18 00 00       	call   4049 <printf>
    exit();
    280b:	e8 b9 16 00 00       	call   3ec9 <exit>
  }
  for(i = 0; i < 20; i++){
    2810:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    2817:	eb 5a                	jmp    2873 <bigfile+0xbf>
    memset(buf, i, 600);
    2819:	c7 44 24 08 58 02 00 	movl   $0x258,0x8(%esp)
    2820:	00 
    2821:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2824:	89 44 24 04          	mov    %eax,0x4(%esp)
    2828:	c7 04 24 c0 8a 00 00 	movl   $0x8ac0,(%esp)
    282f:	e8 e8 14 00 00       	call   3d1c <memset>
    if(write(fd, buf, 600) != 600){
    2834:	c7 44 24 08 58 02 00 	movl   $0x258,0x8(%esp)
    283b:	00 
    283c:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
    2843:	00 
    2844:	8b 45 ec             	mov    -0x14(%ebp),%eax
    2847:	89 04 24             	mov    %eax,(%esp)
    284a:	e8 9a 16 00 00       	call   3ee9 <write>
    284f:	3d 58 02 00 00       	cmp    $0x258,%eax
    2854:	74 19                	je     286f <bigfile+0xbb>
      printf(1, "write bigfile failed\n");
    2856:	c7 44 24 04 bb 52 00 	movl   $0x52bb,0x4(%esp)
    285d:	00 
    285e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2865:	e8 df 17 00 00       	call   4049 <printf>
      exit();
    286a:	e8 5a 16 00 00       	call   3ec9 <exit>
  fd = open("bigfile", O_CREATE | O_RDWR);
  if(fd < 0){
    printf(1, "cannot create bigfile");
    exit();
  }
  for(i = 0; i < 20; i++){
    286f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    2873:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    2877:	7e a0                	jle    2819 <bigfile+0x65>
    if(write(fd, buf, 600) != 600){
      printf(1, "write bigfile failed\n");
      exit();
    }
  }
  close(fd);
    2879:	8b 45 ec             	mov    -0x14(%ebp),%eax
    287c:	89 04 24             	mov    %eax,(%esp)
    287f:	e8 6d 16 00 00       	call   3ef1 <close>

  fd = open("bigfile", 0);
    2884:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    288b:	00 
    288c:	c7 04 24 9d 52 00 00 	movl   $0x529d,(%esp)
    2893:	e8 71 16 00 00       	call   3f09 <open>
    2898:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    289b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    289f:	79 19                	jns    28ba <bigfile+0x106>
    printf(1, "cannot open bigfile\n");
    28a1:	c7 44 24 04 d1 52 00 	movl   $0x52d1,0x4(%esp)
    28a8:	00 
    28a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    28b0:	e8 94 17 00 00       	call   4049 <printf>
    exit();
    28b5:	e8 0f 16 00 00       	call   3ec9 <exit>
  }
  total = 0;
    28ba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(i = 0; ; i++){
    28c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    cc = read(fd, buf, 300);
    28c8:	c7 44 24 08 2c 01 00 	movl   $0x12c,0x8(%esp)
    28cf:	00 
    28d0:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
    28d7:	00 
    28d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
    28db:	89 04 24             	mov    %eax,(%esp)
    28de:	e8 fe 15 00 00       	call   3ee1 <read>
    28e3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(cc < 0){
    28e6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    28ea:	79 19                	jns    2905 <bigfile+0x151>
      printf(1, "read bigfile failed\n");
    28ec:	c7 44 24 04 e6 52 00 	movl   $0x52e6,0x4(%esp)
    28f3:	00 
    28f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    28fb:	e8 49 17 00 00       	call   4049 <printf>
      exit();
    2900:	e8 c4 15 00 00       	call   3ec9 <exit>
    }
    if(cc == 0)
    2905:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    2909:	75 1b                	jne    2926 <bigfile+0x172>
      break;
    290b:	90                   	nop
      printf(1, "read bigfile wrong data\n");
      exit();
    }
    total += cc;
  }
  close(fd);
    290c:	8b 45 ec             	mov    -0x14(%ebp),%eax
    290f:	89 04 24             	mov    %eax,(%esp)
    2912:	e8 da 15 00 00       	call   3ef1 <close>
  if(total != 20*600){
    2917:	81 7d f0 e0 2e 00 00 	cmpl   $0x2ee0,-0x10(%ebp)
    291e:	0f 84 99 00 00 00    	je     29bd <bigfile+0x209>
    2924:	eb 7e                	jmp    29a4 <bigfile+0x1f0>
      printf(1, "read bigfile failed\n");
      exit();
    }
    if(cc == 0)
      break;
    if(cc != 300){
    2926:	81 7d e8 2c 01 00 00 	cmpl   $0x12c,-0x18(%ebp)
    292d:	74 19                	je     2948 <bigfile+0x194>
      printf(1, "short read bigfile\n");
    292f:	c7 44 24 04 fb 52 00 	movl   $0x52fb,0x4(%esp)
    2936:	00 
    2937:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    293e:	e8 06 17 00 00       	call   4049 <printf>
      exit();
    2943:	e8 81 15 00 00       	call   3ec9 <exit>
    }
    if(buf[0] != i/2 || buf[299] != i/2){
    2948:	0f b6 05 c0 8a 00 00 	movzbl 0x8ac0,%eax
    294f:	0f be d0             	movsbl %al,%edx
    2952:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2955:	89 c1                	mov    %eax,%ecx
    2957:	c1 e9 1f             	shr    $0x1f,%ecx
    295a:	01 c8                	add    %ecx,%eax
    295c:	d1 f8                	sar    %eax
    295e:	39 c2                	cmp    %eax,%edx
    2960:	75 1a                	jne    297c <bigfile+0x1c8>
    2962:	0f b6 05 eb 8b 00 00 	movzbl 0x8beb,%eax
    2969:	0f be d0             	movsbl %al,%edx
    296c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    296f:	89 c1                	mov    %eax,%ecx
    2971:	c1 e9 1f             	shr    $0x1f,%ecx
    2974:	01 c8                	add    %ecx,%eax
    2976:	d1 f8                	sar    %eax
    2978:	39 c2                	cmp    %eax,%edx
    297a:	74 19                	je     2995 <bigfile+0x1e1>
      printf(1, "read bigfile wrong data\n");
    297c:	c7 44 24 04 0f 53 00 	movl   $0x530f,0x4(%esp)
    2983:	00 
    2984:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    298b:	e8 b9 16 00 00       	call   4049 <printf>
      exit();
    2990:	e8 34 15 00 00       	call   3ec9 <exit>
    }
    total += cc;
    2995:	8b 45 e8             	mov    -0x18(%ebp),%eax
    2998:	01 45 f0             	add    %eax,-0x10(%ebp)
  if(fd < 0){
    printf(1, "cannot open bigfile\n");
    exit();
  }
  total = 0;
  for(i = 0; ; i++){
    299b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(buf[0] != i/2 || buf[299] != i/2){
      printf(1, "read bigfile wrong data\n");
      exit();
    }
    total += cc;
  }
    299f:	e9 24 ff ff ff       	jmp    28c8 <bigfile+0x114>
  close(fd);
  if(total != 20*600){
    printf(1, "read bigfile wrong total\n");
    29a4:	c7 44 24 04 28 53 00 	movl   $0x5328,0x4(%esp)
    29ab:	00 
    29ac:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    29b3:	e8 91 16 00 00       	call   4049 <printf>
    exit();
    29b8:	e8 0c 15 00 00       	call   3ec9 <exit>
  }
  unlink("bigfile");
    29bd:	c7 04 24 9d 52 00 00 	movl   $0x529d,(%esp)
    29c4:	e8 50 15 00 00       	call   3f19 <unlink>

  printf(1, "bigfile test ok\n");
    29c9:	c7 44 24 04 42 53 00 	movl   $0x5342,0x4(%esp)
    29d0:	00 
    29d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    29d8:	e8 6c 16 00 00       	call   4049 <printf>
}
    29dd:	c9                   	leave  
    29de:	c3                   	ret    

000029df <fourteen>:

void
fourteen(void)
{
    29df:	55                   	push   %ebp
    29e0:	89 e5                	mov    %esp,%ebp
    29e2:	83 ec 28             	sub    $0x28,%esp
  int fd;

  // DIRSIZ is 14.
  printf(1, "fourteen test\n");
    29e5:	c7 44 24 04 53 53 00 	movl   $0x5353,0x4(%esp)
    29ec:	00 
    29ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    29f4:	e8 50 16 00 00       	call   4049 <printf>

  if(mkdir("12345678901234") != 0){
    29f9:	c7 04 24 62 53 00 00 	movl   $0x5362,(%esp)
    2a00:	e8 2c 15 00 00       	call   3f31 <mkdir>
    2a05:	85 c0                	test   %eax,%eax
    2a07:	74 19                	je     2a22 <fourteen+0x43>
    printf(1, "mkdir 12345678901234 failed\n");
    2a09:	c7 44 24 04 71 53 00 	movl   $0x5371,0x4(%esp)
    2a10:	00 
    2a11:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a18:	e8 2c 16 00 00       	call   4049 <printf>
    exit();
    2a1d:	e8 a7 14 00 00       	call   3ec9 <exit>
  }
  if(mkdir("12345678901234/123456789012345") != 0){
    2a22:	c7 04 24 90 53 00 00 	movl   $0x5390,(%esp)
    2a29:	e8 03 15 00 00       	call   3f31 <mkdir>
    2a2e:	85 c0                	test   %eax,%eax
    2a30:	74 19                	je     2a4b <fourteen+0x6c>
    printf(1, "mkdir 12345678901234/123456789012345 failed\n");
    2a32:	c7 44 24 04 b0 53 00 	movl   $0x53b0,0x4(%esp)
    2a39:	00 
    2a3a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a41:	e8 03 16 00 00       	call   4049 <printf>
    exit();
    2a46:	e8 7e 14 00 00       	call   3ec9 <exit>
  }
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    2a4b:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2a52:	00 
    2a53:	c7 04 24 e0 53 00 00 	movl   $0x53e0,(%esp)
    2a5a:	e8 aa 14 00 00       	call   3f09 <open>
    2a5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2a62:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2a66:	79 19                	jns    2a81 <fourteen+0xa2>
    printf(1, "create 123456789012345/123456789012345/123456789012345 failed\n");
    2a68:	c7 44 24 04 10 54 00 	movl   $0x5410,0x4(%esp)
    2a6f:	00 
    2a70:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a77:	e8 cd 15 00 00       	call   4049 <printf>
    exit();
    2a7c:	e8 48 14 00 00       	call   3ec9 <exit>
  }
  close(fd);
    2a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2a84:	89 04 24             	mov    %eax,(%esp)
    2a87:	e8 65 14 00 00       	call   3ef1 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2a8c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2a93:	00 
    2a94:	c7 04 24 50 54 00 00 	movl   $0x5450,(%esp)
    2a9b:	e8 69 14 00 00       	call   3f09 <open>
    2aa0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2aa3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2aa7:	79 19                	jns    2ac2 <fourteen+0xe3>
    printf(1, "open 12345678901234/12345678901234/12345678901234 failed\n");
    2aa9:	c7 44 24 04 80 54 00 	movl   $0x5480,0x4(%esp)
    2ab0:	00 
    2ab1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2ab8:	e8 8c 15 00 00       	call   4049 <printf>
    exit();
    2abd:	e8 07 14 00 00       	call   3ec9 <exit>
  }
  close(fd);
    2ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2ac5:	89 04 24             	mov    %eax,(%esp)
    2ac8:	e8 24 14 00 00       	call   3ef1 <close>

  if(mkdir("12345678901234/12345678901234") == 0){
    2acd:	c7 04 24 ba 54 00 00 	movl   $0x54ba,(%esp)
    2ad4:	e8 58 14 00 00       	call   3f31 <mkdir>
    2ad9:	85 c0                	test   %eax,%eax
    2adb:	75 19                	jne    2af6 <fourteen+0x117>
    printf(1, "mkdir 12345678901234/12345678901234 succeeded!\n");
    2add:	c7 44 24 04 d8 54 00 	movl   $0x54d8,0x4(%esp)
    2ae4:	00 
    2ae5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2aec:	e8 58 15 00 00       	call   4049 <printf>
    exit();
    2af1:	e8 d3 13 00 00       	call   3ec9 <exit>
  }
  if(mkdir("123456789012345/12345678901234") == 0){
    2af6:	c7 04 24 08 55 00 00 	movl   $0x5508,(%esp)
    2afd:	e8 2f 14 00 00       	call   3f31 <mkdir>
    2b02:	85 c0                	test   %eax,%eax
    2b04:	75 19                	jne    2b1f <fourteen+0x140>
    printf(1, "mkdir 12345678901234/123456789012345 succeeded!\n");
    2b06:	c7 44 24 04 28 55 00 	movl   $0x5528,0x4(%esp)
    2b0d:	00 
    2b0e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b15:	e8 2f 15 00 00       	call   4049 <printf>
    exit();
    2b1a:	e8 aa 13 00 00       	call   3ec9 <exit>
  }

  printf(1, "fourteen ok\n");
    2b1f:	c7 44 24 04 59 55 00 	movl   $0x5559,0x4(%esp)
    2b26:	00 
    2b27:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b2e:	e8 16 15 00 00       	call   4049 <printf>
}
    2b33:	c9                   	leave  
    2b34:	c3                   	ret    

00002b35 <rmdot>:

void
rmdot(void)
{
    2b35:	55                   	push   %ebp
    2b36:	89 e5                	mov    %esp,%ebp
    2b38:	83 ec 18             	sub    $0x18,%esp
  printf(1, "rmdot test\n");
    2b3b:	c7 44 24 04 66 55 00 	movl   $0x5566,0x4(%esp)
    2b42:	00 
    2b43:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b4a:	e8 fa 14 00 00       	call   4049 <printf>
  if(mkdir("dots") != 0){
    2b4f:	c7 04 24 72 55 00 00 	movl   $0x5572,(%esp)
    2b56:	e8 d6 13 00 00       	call   3f31 <mkdir>
    2b5b:	85 c0                	test   %eax,%eax
    2b5d:	74 19                	je     2b78 <rmdot+0x43>
    printf(1, "mkdir dots failed\n");
    2b5f:	c7 44 24 04 77 55 00 	movl   $0x5577,0x4(%esp)
    2b66:	00 
    2b67:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b6e:	e8 d6 14 00 00       	call   4049 <printf>
    exit();
    2b73:	e8 51 13 00 00       	call   3ec9 <exit>
  }
  if(chdir("dots") != 0){
    2b78:	c7 04 24 72 55 00 00 	movl   $0x5572,(%esp)
    2b7f:	e8 b5 13 00 00       	call   3f39 <chdir>
    2b84:	85 c0                	test   %eax,%eax
    2b86:	74 19                	je     2ba1 <rmdot+0x6c>
    printf(1, "chdir dots failed\n");
    2b88:	c7 44 24 04 8a 55 00 	movl   $0x558a,0x4(%esp)
    2b8f:	00 
    2b90:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b97:	e8 ad 14 00 00       	call   4049 <printf>
    exit();
    2b9c:	e8 28 13 00 00       	call   3ec9 <exit>
  }
  if(unlink(".") == 0){
    2ba1:	c7 04 24 a3 4c 00 00 	movl   $0x4ca3,(%esp)
    2ba8:	e8 6c 13 00 00       	call   3f19 <unlink>
    2bad:	85 c0                	test   %eax,%eax
    2baf:	75 19                	jne    2bca <rmdot+0x95>
    printf(1, "rm . worked!\n");
    2bb1:	c7 44 24 04 9d 55 00 	movl   $0x559d,0x4(%esp)
    2bb8:	00 
    2bb9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2bc0:	e8 84 14 00 00       	call   4049 <printf>
    exit();
    2bc5:	e8 ff 12 00 00       	call   3ec9 <exit>
  }
  if(unlink("..") == 0){
    2bca:	c7 04 24 36 48 00 00 	movl   $0x4836,(%esp)
    2bd1:	e8 43 13 00 00       	call   3f19 <unlink>
    2bd6:	85 c0                	test   %eax,%eax
    2bd8:	75 19                	jne    2bf3 <rmdot+0xbe>
    printf(1, "rm .. worked!\n");
    2bda:	c7 44 24 04 ab 55 00 	movl   $0x55ab,0x4(%esp)
    2be1:	00 
    2be2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2be9:	e8 5b 14 00 00       	call   4049 <printf>
    exit();
    2bee:	e8 d6 12 00 00       	call   3ec9 <exit>
  }
  if(chdir("/") != 0){
    2bf3:	c7 04 24 8a 44 00 00 	movl   $0x448a,(%esp)
    2bfa:	e8 3a 13 00 00       	call   3f39 <chdir>
    2bff:	85 c0                	test   %eax,%eax
    2c01:	74 19                	je     2c1c <rmdot+0xe7>
    printf(1, "chdir / failed\n");
    2c03:	c7 44 24 04 8c 44 00 	movl   $0x448c,0x4(%esp)
    2c0a:	00 
    2c0b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c12:	e8 32 14 00 00       	call   4049 <printf>
    exit();
    2c17:	e8 ad 12 00 00       	call   3ec9 <exit>
  }
  if(unlink("dots/.") == 0){
    2c1c:	c7 04 24 ba 55 00 00 	movl   $0x55ba,(%esp)
    2c23:	e8 f1 12 00 00       	call   3f19 <unlink>
    2c28:	85 c0                	test   %eax,%eax
    2c2a:	75 19                	jne    2c45 <rmdot+0x110>
    printf(1, "unlink dots/. worked!\n");
    2c2c:	c7 44 24 04 c1 55 00 	movl   $0x55c1,0x4(%esp)
    2c33:	00 
    2c34:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c3b:	e8 09 14 00 00       	call   4049 <printf>
    exit();
    2c40:	e8 84 12 00 00       	call   3ec9 <exit>
  }
  if(unlink("dots/..") == 0){
    2c45:	c7 04 24 d8 55 00 00 	movl   $0x55d8,(%esp)
    2c4c:	e8 c8 12 00 00       	call   3f19 <unlink>
    2c51:	85 c0                	test   %eax,%eax
    2c53:	75 19                	jne    2c6e <rmdot+0x139>
    printf(1, "unlink dots/.. worked!\n");
    2c55:	c7 44 24 04 e0 55 00 	movl   $0x55e0,0x4(%esp)
    2c5c:	00 
    2c5d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c64:	e8 e0 13 00 00       	call   4049 <printf>
    exit();
    2c69:	e8 5b 12 00 00       	call   3ec9 <exit>
  }
  if(unlink("dots") != 0){
    2c6e:	c7 04 24 72 55 00 00 	movl   $0x5572,(%esp)
    2c75:	e8 9f 12 00 00       	call   3f19 <unlink>
    2c7a:	85 c0                	test   %eax,%eax
    2c7c:	74 19                	je     2c97 <rmdot+0x162>
    printf(1, "unlink dots failed!\n");
    2c7e:	c7 44 24 04 f8 55 00 	movl   $0x55f8,0x4(%esp)
    2c85:	00 
    2c86:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c8d:	e8 b7 13 00 00       	call   4049 <printf>
    exit();
    2c92:	e8 32 12 00 00       	call   3ec9 <exit>
  }
  printf(1, "rmdot ok\n");
    2c97:	c7 44 24 04 0d 56 00 	movl   $0x560d,0x4(%esp)
    2c9e:	00 
    2c9f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2ca6:	e8 9e 13 00 00       	call   4049 <printf>
}
    2cab:	c9                   	leave  
    2cac:	c3                   	ret    

00002cad <dirfile>:

void
dirfile(void)
{
    2cad:	55                   	push   %ebp
    2cae:	89 e5                	mov    %esp,%ebp
    2cb0:	83 ec 28             	sub    $0x28,%esp
  int fd;

  printf(1, "dir vs file\n");
    2cb3:	c7 44 24 04 17 56 00 	movl   $0x5617,0x4(%esp)
    2cba:	00 
    2cbb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2cc2:	e8 82 13 00 00       	call   4049 <printf>

  fd = open("dirfile", O_CREATE);
    2cc7:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2cce:	00 
    2ccf:	c7 04 24 24 56 00 00 	movl   $0x5624,(%esp)
    2cd6:	e8 2e 12 00 00       	call   3f09 <open>
    2cdb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2cde:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2ce2:	79 19                	jns    2cfd <dirfile+0x50>
    printf(1, "create dirfile failed\n");
    2ce4:	c7 44 24 04 2c 56 00 	movl   $0x562c,0x4(%esp)
    2ceb:	00 
    2cec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2cf3:	e8 51 13 00 00       	call   4049 <printf>
    exit();
    2cf8:	e8 cc 11 00 00       	call   3ec9 <exit>
  }
  close(fd);
    2cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2d00:	89 04 24             	mov    %eax,(%esp)
    2d03:	e8 e9 11 00 00       	call   3ef1 <close>
  if(chdir("dirfile") == 0){
    2d08:	c7 04 24 24 56 00 00 	movl   $0x5624,(%esp)
    2d0f:	e8 25 12 00 00       	call   3f39 <chdir>
    2d14:	85 c0                	test   %eax,%eax
    2d16:	75 19                	jne    2d31 <dirfile+0x84>
    printf(1, "chdir dirfile succeeded!\n");
    2d18:	c7 44 24 04 43 56 00 	movl   $0x5643,0x4(%esp)
    2d1f:	00 
    2d20:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d27:	e8 1d 13 00 00       	call   4049 <printf>
    exit();
    2d2c:	e8 98 11 00 00       	call   3ec9 <exit>
  }
  fd = open("dirfile/xx", 0);
    2d31:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2d38:	00 
    2d39:	c7 04 24 5d 56 00 00 	movl   $0x565d,(%esp)
    2d40:	e8 c4 11 00 00       	call   3f09 <open>
    2d45:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
    2d48:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2d4c:	78 19                	js     2d67 <dirfile+0xba>
    printf(1, "create dirfile/xx succeeded!\n");
    2d4e:	c7 44 24 04 68 56 00 	movl   $0x5668,0x4(%esp)
    2d55:	00 
    2d56:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d5d:	e8 e7 12 00 00       	call   4049 <printf>
    exit();
    2d62:	e8 62 11 00 00       	call   3ec9 <exit>
  }
  fd = open("dirfile/xx", O_CREATE);
    2d67:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2d6e:	00 
    2d6f:	c7 04 24 5d 56 00 00 	movl   $0x565d,(%esp)
    2d76:	e8 8e 11 00 00       	call   3f09 <open>
    2d7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
    2d7e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2d82:	78 19                	js     2d9d <dirfile+0xf0>
    printf(1, "create dirfile/xx succeeded!\n");
    2d84:	c7 44 24 04 68 56 00 	movl   $0x5668,0x4(%esp)
    2d8b:	00 
    2d8c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d93:	e8 b1 12 00 00       	call   4049 <printf>
    exit();
    2d98:	e8 2c 11 00 00       	call   3ec9 <exit>
  }
  if(mkdir("dirfile/xx") == 0){
    2d9d:	c7 04 24 5d 56 00 00 	movl   $0x565d,(%esp)
    2da4:	e8 88 11 00 00       	call   3f31 <mkdir>
    2da9:	85 c0                	test   %eax,%eax
    2dab:	75 19                	jne    2dc6 <dirfile+0x119>
    printf(1, "mkdir dirfile/xx succeeded!\n");
    2dad:	c7 44 24 04 86 56 00 	movl   $0x5686,0x4(%esp)
    2db4:	00 
    2db5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2dbc:	e8 88 12 00 00       	call   4049 <printf>
    exit();
    2dc1:	e8 03 11 00 00       	call   3ec9 <exit>
  }
  if(unlink("dirfile/xx") == 0){
    2dc6:	c7 04 24 5d 56 00 00 	movl   $0x565d,(%esp)
    2dcd:	e8 47 11 00 00       	call   3f19 <unlink>
    2dd2:	85 c0                	test   %eax,%eax
    2dd4:	75 19                	jne    2def <dirfile+0x142>
    printf(1, "unlink dirfile/xx succeeded!\n");
    2dd6:	c7 44 24 04 a3 56 00 	movl   $0x56a3,0x4(%esp)
    2ddd:	00 
    2dde:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2de5:	e8 5f 12 00 00       	call   4049 <printf>
    exit();
    2dea:	e8 da 10 00 00       	call   3ec9 <exit>
  }
  if(link("README", "dirfile/xx") == 0){
    2def:	c7 44 24 04 5d 56 00 	movl   $0x565d,0x4(%esp)
    2df6:	00 
    2df7:	c7 04 24 c1 56 00 00 	movl   $0x56c1,(%esp)
    2dfe:	e8 26 11 00 00       	call   3f29 <link>
    2e03:	85 c0                	test   %eax,%eax
    2e05:	75 19                	jne    2e20 <dirfile+0x173>
    printf(1, "link to dirfile/xx succeeded!\n");
    2e07:	c7 44 24 04 c8 56 00 	movl   $0x56c8,0x4(%esp)
    2e0e:	00 
    2e0f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e16:	e8 2e 12 00 00       	call   4049 <printf>
    exit();
    2e1b:	e8 a9 10 00 00       	call   3ec9 <exit>
  }
  if(unlink("dirfile") != 0){
    2e20:	c7 04 24 24 56 00 00 	movl   $0x5624,(%esp)
    2e27:	e8 ed 10 00 00       	call   3f19 <unlink>
    2e2c:	85 c0                	test   %eax,%eax
    2e2e:	74 19                	je     2e49 <dirfile+0x19c>
    printf(1, "unlink dirfile failed!\n");
    2e30:	c7 44 24 04 e7 56 00 	movl   $0x56e7,0x4(%esp)
    2e37:	00 
    2e38:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e3f:	e8 05 12 00 00       	call   4049 <printf>
    exit();
    2e44:	e8 80 10 00 00       	call   3ec9 <exit>
  }

  fd = open(".", O_RDWR);
    2e49:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    2e50:	00 
    2e51:	c7 04 24 a3 4c 00 00 	movl   $0x4ca3,(%esp)
    2e58:	e8 ac 10 00 00       	call   3f09 <open>
    2e5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
    2e60:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2e64:	78 19                	js     2e7f <dirfile+0x1d2>
    printf(1, "open . for writing succeeded!\n");
    2e66:	c7 44 24 04 00 57 00 	movl   $0x5700,0x4(%esp)
    2e6d:	00 
    2e6e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e75:	e8 cf 11 00 00       	call   4049 <printf>
    exit();
    2e7a:	e8 4a 10 00 00       	call   3ec9 <exit>
  }
  fd = open(".", 0);
    2e7f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2e86:	00 
    2e87:	c7 04 24 a3 4c 00 00 	movl   $0x4ca3,(%esp)
    2e8e:	e8 76 10 00 00       	call   3f09 <open>
    2e93:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(write(fd, "x", 1) > 0){
    2e96:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    2e9d:	00 
    2e9e:	c7 44 24 04 ef 48 00 	movl   $0x48ef,0x4(%esp)
    2ea5:	00 
    2ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2ea9:	89 04 24             	mov    %eax,(%esp)
    2eac:	e8 38 10 00 00       	call   3ee9 <write>
    2eb1:	85 c0                	test   %eax,%eax
    2eb3:	7e 19                	jle    2ece <dirfile+0x221>
    printf(1, "write . succeeded!\n");
    2eb5:	c7 44 24 04 1f 57 00 	movl   $0x571f,0x4(%esp)
    2ebc:	00 
    2ebd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2ec4:	e8 80 11 00 00       	call   4049 <printf>
    exit();
    2ec9:	e8 fb 0f 00 00       	call   3ec9 <exit>
  }
  close(fd);
    2ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2ed1:	89 04 24             	mov    %eax,(%esp)
    2ed4:	e8 18 10 00 00       	call   3ef1 <close>

  printf(1, "dir vs file OK\n");
    2ed9:	c7 44 24 04 33 57 00 	movl   $0x5733,0x4(%esp)
    2ee0:	00 
    2ee1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2ee8:	e8 5c 11 00 00       	call   4049 <printf>
}
    2eed:	c9                   	leave  
    2eee:	c3                   	ret    

00002eef <iref>:

// test that iput() is called at the end of _namei()
void
iref(void)
{
    2eef:	55                   	push   %ebp
    2ef0:	89 e5                	mov    %esp,%ebp
    2ef2:	83 ec 28             	sub    $0x28,%esp
  int i, fd;

  printf(1, "empty file name\n");
    2ef5:	c7 44 24 04 43 57 00 	movl   $0x5743,0x4(%esp)
    2efc:	00 
    2efd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2f04:	e8 40 11 00 00       	call   4049 <printf>

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
    2f09:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    2f10:	e9 d2 00 00 00       	jmp    2fe7 <iref+0xf8>
    if(mkdir("irefd") != 0){
    2f15:	c7 04 24 54 57 00 00 	movl   $0x5754,(%esp)
    2f1c:	e8 10 10 00 00       	call   3f31 <mkdir>
    2f21:	85 c0                	test   %eax,%eax
    2f23:	74 19                	je     2f3e <iref+0x4f>
      printf(1, "mkdir irefd failed\n");
    2f25:	c7 44 24 04 5a 57 00 	movl   $0x575a,0x4(%esp)
    2f2c:	00 
    2f2d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2f34:	e8 10 11 00 00       	call   4049 <printf>
      exit();
    2f39:	e8 8b 0f 00 00       	call   3ec9 <exit>
    }
    if(chdir("irefd") != 0){
    2f3e:	c7 04 24 54 57 00 00 	movl   $0x5754,(%esp)
    2f45:	e8 ef 0f 00 00       	call   3f39 <chdir>
    2f4a:	85 c0                	test   %eax,%eax
    2f4c:	74 19                	je     2f67 <iref+0x78>
      printf(1, "chdir irefd failed\n");
    2f4e:	c7 44 24 04 6e 57 00 	movl   $0x576e,0x4(%esp)
    2f55:	00 
    2f56:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2f5d:	e8 e7 10 00 00       	call   4049 <printf>
      exit();
    2f62:	e8 62 0f 00 00       	call   3ec9 <exit>
    }

    mkdir("");
    2f67:	c7 04 24 82 57 00 00 	movl   $0x5782,(%esp)
    2f6e:	e8 be 0f 00 00       	call   3f31 <mkdir>
    link("README", "");
    2f73:	c7 44 24 04 82 57 00 	movl   $0x5782,0x4(%esp)
    2f7a:	00 
    2f7b:	c7 04 24 c1 56 00 00 	movl   $0x56c1,(%esp)
    2f82:	e8 a2 0f 00 00       	call   3f29 <link>
    fd = open("", O_CREATE);
    2f87:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2f8e:	00 
    2f8f:	c7 04 24 82 57 00 00 	movl   $0x5782,(%esp)
    2f96:	e8 6e 0f 00 00       	call   3f09 <open>
    2f9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(fd >= 0)
    2f9e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    2fa2:	78 0b                	js     2faf <iref+0xc0>
      close(fd);
    2fa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
    2fa7:	89 04 24             	mov    %eax,(%esp)
    2faa:	e8 42 0f 00 00       	call   3ef1 <close>
    fd = open("xx", O_CREATE);
    2faf:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2fb6:	00 
    2fb7:	c7 04 24 83 57 00 00 	movl   $0x5783,(%esp)
    2fbe:	e8 46 0f 00 00       	call   3f09 <open>
    2fc3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(fd >= 0)
    2fc6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    2fca:	78 0b                	js     2fd7 <iref+0xe8>
      close(fd);
    2fcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
    2fcf:	89 04 24             	mov    %eax,(%esp)
    2fd2:	e8 1a 0f 00 00       	call   3ef1 <close>
    unlink("xx");
    2fd7:	c7 04 24 83 57 00 00 	movl   $0x5783,(%esp)
    2fde:	e8 36 0f 00 00       	call   3f19 <unlink>
  int i, fd;

  printf(1, "empty file name\n");

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
    2fe3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    2fe7:	83 7d f4 32          	cmpl   $0x32,-0xc(%ebp)
    2feb:	0f 8e 24 ff ff ff    	jle    2f15 <iref+0x26>
    if(fd >= 0)
      close(fd);
    unlink("xx");
  }

  chdir("/");
    2ff1:	c7 04 24 8a 44 00 00 	movl   $0x448a,(%esp)
    2ff8:	e8 3c 0f 00 00       	call   3f39 <chdir>
  printf(1, "empty file name OK\n");
    2ffd:	c7 44 24 04 86 57 00 	movl   $0x5786,0x4(%esp)
    3004:	00 
    3005:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    300c:	e8 38 10 00 00       	call   4049 <printf>
}
    3011:	c9                   	leave  
    3012:	c3                   	ret    

00003013 <forktest>:
// test that fork fails gracefully
// the forktest binary also does this, but it runs out of proc entries first.
// inside the bigger usertests binary, we run out of memory first.
void
forktest(void)
{
    3013:	55                   	push   %ebp
    3014:	89 e5                	mov    %esp,%ebp
    3016:	83 ec 28             	sub    $0x28,%esp
  int n, pid;

  printf(1, "fork test\n");
    3019:	c7 44 24 04 9a 57 00 	movl   $0x579a,0x4(%esp)
    3020:	00 
    3021:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3028:	e8 1c 10 00 00       	call   4049 <printf>

  for(n=0; n<1000; n++){
    302d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    3034:	eb 1f                	jmp    3055 <forktest+0x42>
    pid = fork();
    3036:	e8 86 0e 00 00       	call   3ec1 <fork>
    303b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0)
    303e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3042:	79 02                	jns    3046 <forktest+0x33>
      break;
    3044:	eb 18                	jmp    305e <forktest+0x4b>
    if(pid == 0)
    3046:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    304a:	75 05                	jne    3051 <forktest+0x3e>
      exit();
    304c:	e8 78 0e 00 00       	call   3ec9 <exit>
{
  int n, pid;

  printf(1, "fork test\n");

  for(n=0; n<1000; n++){
    3051:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    3055:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
    305c:	7e d8                	jle    3036 <forktest+0x23>
      break;
    if(pid == 0)
      exit();
  }
  
  if(n == 1000){
    305e:	81 7d f4 e8 03 00 00 	cmpl   $0x3e8,-0xc(%ebp)
    3065:	75 19                	jne    3080 <forktest+0x6d>
    printf(1, "fork claimed to work 1000 times!\n");
    3067:	c7 44 24 04 a8 57 00 	movl   $0x57a8,0x4(%esp)
    306e:	00 
    306f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3076:	e8 ce 0f 00 00       	call   4049 <printf>
    exit();
    307b:	e8 49 0e 00 00       	call   3ec9 <exit>
  }
  
  for(; n > 0; n--){
    3080:	eb 26                	jmp    30a8 <forktest+0x95>
    if(wait() < 0){
    3082:	e8 4a 0e 00 00       	call   3ed1 <wait>
    3087:	85 c0                	test   %eax,%eax
    3089:	79 19                	jns    30a4 <forktest+0x91>
      printf(1, "wait stopped early\n");
    308b:	c7 44 24 04 ca 57 00 	movl   $0x57ca,0x4(%esp)
    3092:	00 
    3093:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    309a:	e8 aa 0f 00 00       	call   4049 <printf>
      exit();
    309f:	e8 25 0e 00 00       	call   3ec9 <exit>
  if(n == 1000){
    printf(1, "fork claimed to work 1000 times!\n");
    exit();
  }
  
  for(; n > 0; n--){
    30a4:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    30a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    30ac:	7f d4                	jg     3082 <forktest+0x6f>
      printf(1, "wait stopped early\n");
      exit();
    }
  }
  
  if(wait() != -1){
    30ae:	e8 1e 0e 00 00       	call   3ed1 <wait>
    30b3:	83 f8 ff             	cmp    $0xffffffff,%eax
    30b6:	74 19                	je     30d1 <forktest+0xbe>
    printf(1, "wait got too many\n");
    30b8:	c7 44 24 04 de 57 00 	movl   $0x57de,0x4(%esp)
    30bf:	00 
    30c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    30c7:	e8 7d 0f 00 00       	call   4049 <printf>
    exit();
    30cc:	e8 f8 0d 00 00       	call   3ec9 <exit>
  }
  
  printf(1, "fork test OK\n");
    30d1:	c7 44 24 04 f1 57 00 	movl   $0x57f1,0x4(%esp)
    30d8:	00 
    30d9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    30e0:	e8 64 0f 00 00       	call   4049 <printf>
}
    30e5:	c9                   	leave  
    30e6:	c3                   	ret    

000030e7 <sbrktest>:

void
sbrktest(void)
{
    30e7:	55                   	push   %ebp
    30e8:	89 e5                	mov    %esp,%ebp
    30ea:	53                   	push   %ebx
    30eb:	81 ec 84 00 00 00    	sub    $0x84,%esp
  int fds[2], pid, pids[10], ppid;
  char *a, *b, *c, *lastaddr, *oldbrk, *p, scratch;
  uint amt;

  printf(stdout, "sbrk test\n");
    30f1:	a1 d8 62 00 00       	mov    0x62d8,%eax
    30f6:	c7 44 24 04 ff 57 00 	movl   $0x57ff,0x4(%esp)
    30fd:	00 
    30fe:	89 04 24             	mov    %eax,(%esp)
    3101:	e8 43 0f 00 00       	call   4049 <printf>
  oldbrk = sbrk(0);
    3106:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    310d:	e8 3f 0e 00 00       	call   3f51 <sbrk>
    3112:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // can one sbrk() less than a page?
  a = sbrk(0);
    3115:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    311c:	e8 30 0e 00 00       	call   3f51 <sbrk>
    3121:	89 45 f4             	mov    %eax,-0xc(%ebp)
  int i;
  for(i = 0; i < 5000; i++){ 
    3124:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    312b:	eb 59                	jmp    3186 <sbrktest+0x9f>
    b = sbrk(1);
    312d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3134:	e8 18 0e 00 00       	call   3f51 <sbrk>
    3139:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(b != a){
    313c:	8b 45 e8             	mov    -0x18(%ebp),%eax
    313f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    3142:	74 2f                	je     3173 <sbrktest+0x8c>
      printf(stdout, "sbrk test failed %d %x %x\n", i, a, b);
    3144:	a1 d8 62 00 00       	mov    0x62d8,%eax
    3149:	8b 55 e8             	mov    -0x18(%ebp),%edx
    314c:	89 54 24 10          	mov    %edx,0x10(%esp)
    3150:	8b 55 f4             	mov    -0xc(%ebp),%edx
    3153:	89 54 24 0c          	mov    %edx,0xc(%esp)
    3157:	8b 55 f0             	mov    -0x10(%ebp),%edx
    315a:	89 54 24 08          	mov    %edx,0x8(%esp)
    315e:	c7 44 24 04 0a 58 00 	movl   $0x580a,0x4(%esp)
    3165:	00 
    3166:	89 04 24             	mov    %eax,(%esp)
    3169:	e8 db 0e 00 00       	call   4049 <printf>
      exit();
    316e:	e8 56 0d 00 00       	call   3ec9 <exit>
    }
    *b = 1;
    3173:	8b 45 e8             	mov    -0x18(%ebp),%eax
    3176:	c6 00 01             	movb   $0x1,(%eax)
    a = b + 1;
    3179:	8b 45 e8             	mov    -0x18(%ebp),%eax
    317c:	83 c0 01             	add    $0x1,%eax
    317f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  oldbrk = sbrk(0);

  // can one sbrk() less than a page?
  a = sbrk(0);
  int i;
  for(i = 0; i < 5000; i++){ 
    3182:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    3186:	81 7d f0 87 13 00 00 	cmpl   $0x1387,-0x10(%ebp)
    318d:	7e 9e                	jle    312d <sbrktest+0x46>
      exit();
    }
    *b = 1;
    a = b + 1;
  }
  pid = fork();
    318f:	e8 2d 0d 00 00       	call   3ec1 <fork>
    3194:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(pid < 0){
    3197:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    319b:	79 1a                	jns    31b7 <sbrktest+0xd0>
    printf(stdout, "sbrk test fork failed\n");
    319d:	a1 d8 62 00 00       	mov    0x62d8,%eax
    31a2:	c7 44 24 04 25 58 00 	movl   $0x5825,0x4(%esp)
    31a9:	00 
    31aa:	89 04 24             	mov    %eax,(%esp)
    31ad:	e8 97 0e 00 00       	call   4049 <printf>
    exit();
    31b2:	e8 12 0d 00 00       	call   3ec9 <exit>
  }
  c = sbrk(1);
    31b7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    31be:	e8 8e 0d 00 00       	call   3f51 <sbrk>
    31c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  c = sbrk(1);
    31c6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    31cd:	e8 7f 0d 00 00       	call   3f51 <sbrk>
    31d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a + 1){
    31d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    31d8:	83 c0 01             	add    $0x1,%eax
    31db:	3b 45 e0             	cmp    -0x20(%ebp),%eax
    31de:	74 1a                	je     31fa <sbrktest+0x113>
    printf(stdout, "sbrk test failed post-fork\n");
    31e0:	a1 d8 62 00 00       	mov    0x62d8,%eax
    31e5:	c7 44 24 04 3c 58 00 	movl   $0x583c,0x4(%esp)
    31ec:	00 
    31ed:	89 04 24             	mov    %eax,(%esp)
    31f0:	e8 54 0e 00 00       	call   4049 <printf>
    exit();
    31f5:	e8 cf 0c 00 00       	call   3ec9 <exit>
  }
  if(pid == 0)
    31fa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    31fe:	75 05                	jne    3205 <sbrktest+0x11e>
    exit();
    3200:	e8 c4 0c 00 00       	call   3ec9 <exit>
  wait();
    3205:	e8 c7 0c 00 00       	call   3ed1 <wait>

  // can one grow address space to something big?
#define BIG (100*1024*1024)
  a = sbrk(0);
    320a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3211:	e8 3b 0d 00 00       	call   3f51 <sbrk>
    3216:	89 45 f4             	mov    %eax,-0xc(%ebp)
  amt = (BIG) - (uint)a;
    3219:	8b 45 f4             	mov    -0xc(%ebp),%eax
    321c:	ba 00 00 40 06       	mov    $0x6400000,%edx
    3221:	29 c2                	sub    %eax,%edx
    3223:	89 d0                	mov    %edx,%eax
    3225:	89 45 dc             	mov    %eax,-0x24(%ebp)
  p = sbrk(amt);
    3228:	8b 45 dc             	mov    -0x24(%ebp),%eax
    322b:	89 04 24             	mov    %eax,(%esp)
    322e:	e8 1e 0d 00 00       	call   3f51 <sbrk>
    3233:	89 45 d8             	mov    %eax,-0x28(%ebp)
  if (p != a) { 
    3236:	8b 45 d8             	mov    -0x28(%ebp),%eax
    3239:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    323c:	74 1a                	je     3258 <sbrktest+0x171>
    printf(stdout, "sbrk test failed to grow big address space; enough phys mem?\n");
    323e:	a1 d8 62 00 00       	mov    0x62d8,%eax
    3243:	c7 44 24 04 58 58 00 	movl   $0x5858,0x4(%esp)
    324a:	00 
    324b:	89 04 24             	mov    %eax,(%esp)
    324e:	e8 f6 0d 00 00       	call   4049 <printf>
    exit();
    3253:	e8 71 0c 00 00       	call   3ec9 <exit>
  }
  lastaddr = (char*) (BIG-1);
    3258:	c7 45 d4 ff ff 3f 06 	movl   $0x63fffff,-0x2c(%ebp)
  *lastaddr = 99;
    325f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    3262:	c6 00 63             	movb   $0x63,(%eax)

  // can one de-allocate?
  a = sbrk(0);
    3265:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    326c:	e8 e0 0c 00 00       	call   3f51 <sbrk>
    3271:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c = sbrk(-4096);
    3274:	c7 04 24 00 f0 ff ff 	movl   $0xfffff000,(%esp)
    327b:	e8 d1 0c 00 00       	call   3f51 <sbrk>
    3280:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c == (char*)0xffffffff){
    3283:	83 7d e0 ff          	cmpl   $0xffffffff,-0x20(%ebp)
    3287:	75 21                	jne    32aa <sbrktest+0x1c3>
    printf(stdout, "sbrk could not deallocate %d\n",c);
    3289:	a1 d8 62 00 00       	mov    0x62d8,%eax
    328e:	8b 55 e0             	mov    -0x20(%ebp),%edx
    3291:	89 54 24 08          	mov    %edx,0x8(%esp)
    3295:	c7 44 24 04 96 58 00 	movl   $0x5896,0x4(%esp)
    329c:	00 
    329d:	89 04 24             	mov    %eax,(%esp)
    32a0:	e8 a4 0d 00 00       	call   4049 <printf>
    exit();
    32a5:	e8 1f 0c 00 00       	call   3ec9 <exit>
  }
  c = sbrk(0);
    32aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    32b1:	e8 9b 0c 00 00       	call   3f51 <sbrk>
    32b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a - 4096){
    32b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    32bc:	2d 00 10 00 00       	sub    $0x1000,%eax
    32c1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
    32c4:	74 28                	je     32ee <sbrktest+0x207>
    printf(stdout, "sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    32c6:	a1 d8 62 00 00       	mov    0x62d8,%eax
    32cb:	8b 55 e0             	mov    -0x20(%ebp),%edx
    32ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
    32d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
    32d5:	89 54 24 08          	mov    %edx,0x8(%esp)
    32d9:	c7 44 24 04 b4 58 00 	movl   $0x58b4,0x4(%esp)
    32e0:	00 
    32e1:	89 04 24             	mov    %eax,(%esp)
    32e4:	e8 60 0d 00 00       	call   4049 <printf>
    exit();
    32e9:	e8 db 0b 00 00       	call   3ec9 <exit>
  }

  // can one re-allocate that page?
  a = sbrk(0);
    32ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    32f5:	e8 57 0c 00 00       	call   3f51 <sbrk>
    32fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c = sbrk(4096);
    32fd:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
    3304:	e8 48 0c 00 00       	call   3f51 <sbrk>
    3309:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a || sbrk(0) != a + 4096){
    330c:	8b 45 e0             	mov    -0x20(%ebp),%eax
    330f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    3312:	75 19                	jne    332d <sbrktest+0x246>
    3314:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    331b:	e8 31 0c 00 00       	call   3f51 <sbrk>
    3320:	8b 55 f4             	mov    -0xc(%ebp),%edx
    3323:	81 c2 00 10 00 00    	add    $0x1000,%edx
    3329:	39 d0                	cmp    %edx,%eax
    332b:	74 28                	je     3355 <sbrktest+0x26e>
    printf(stdout, "sbrk re-allocation failed, a %x c %x\n", a, c);
    332d:	a1 d8 62 00 00       	mov    0x62d8,%eax
    3332:	8b 55 e0             	mov    -0x20(%ebp),%edx
    3335:	89 54 24 0c          	mov    %edx,0xc(%esp)
    3339:	8b 55 f4             	mov    -0xc(%ebp),%edx
    333c:	89 54 24 08          	mov    %edx,0x8(%esp)
    3340:	c7 44 24 04 ec 58 00 	movl   $0x58ec,0x4(%esp)
    3347:	00 
    3348:	89 04 24             	mov    %eax,(%esp)
    334b:	e8 f9 0c 00 00       	call   4049 <printf>
    exit();
    3350:	e8 74 0b 00 00       	call   3ec9 <exit>
  }
  if(*lastaddr == 99){
    3355:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    3358:	0f b6 00             	movzbl (%eax),%eax
    335b:	3c 63                	cmp    $0x63,%al
    335d:	75 27                	jne    3386 <sbrktest+0x29f>
    // should be zero
    printf(stdout, "sbrk de-allocation didn't really deallocate %p\n",*lastaddr);
    335f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    3362:	0f b6 00             	movzbl (%eax),%eax
    3365:	0f be d0             	movsbl %al,%edx
    3368:	a1 d8 62 00 00       	mov    0x62d8,%eax
    336d:	89 54 24 08          	mov    %edx,0x8(%esp)
    3371:	c7 44 24 04 14 59 00 	movl   $0x5914,0x4(%esp)
    3378:	00 
    3379:	89 04 24             	mov    %eax,(%esp)
    337c:	e8 c8 0c 00 00       	call   4049 <printf>
    exit();
    3381:	e8 43 0b 00 00       	call   3ec9 <exit>
  }

  a = sbrk(0);
    3386:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    338d:	e8 bf 0b 00 00       	call   3f51 <sbrk>
    3392:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c = sbrk(-(sbrk(0) - oldbrk));
    3395:	8b 5d ec             	mov    -0x14(%ebp),%ebx
    3398:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    339f:	e8 ad 0b 00 00       	call   3f51 <sbrk>
    33a4:	29 c3                	sub    %eax,%ebx
    33a6:	89 d8                	mov    %ebx,%eax
    33a8:	89 04 24             	mov    %eax,(%esp)
    33ab:	e8 a1 0b 00 00       	call   3f51 <sbrk>
    33b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a){
    33b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
    33b6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    33b9:	74 28                	je     33e3 <sbrktest+0x2fc>
    printf(stdout, "sbrk downsize failed, a %x c %x\n", a, c);
    33bb:	a1 d8 62 00 00       	mov    0x62d8,%eax
    33c0:	8b 55 e0             	mov    -0x20(%ebp),%edx
    33c3:	89 54 24 0c          	mov    %edx,0xc(%esp)
    33c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
    33ca:	89 54 24 08          	mov    %edx,0x8(%esp)
    33ce:	c7 44 24 04 44 59 00 	movl   $0x5944,0x4(%esp)
    33d5:	00 
    33d6:	89 04 24             	mov    %eax,(%esp)
    33d9:	e8 6b 0c 00 00       	call   4049 <printf>
    exit();
    33de:	e8 e6 0a 00 00       	call   3ec9 <exit>
  }
  
  // can we read the kernel's memory?
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    33e3:	c7 45 f4 00 00 00 80 	movl   $0x80000000,-0xc(%ebp)
    33ea:	eb 7b                	jmp    3467 <sbrktest+0x380>
    ppid = getpid();
    33ec:	e8 58 0b 00 00       	call   3f49 <getpid>
    33f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
    pid = fork();
    33f4:	e8 c8 0a 00 00       	call   3ec1 <fork>
    33f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(pid < 0){
    33fc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    3400:	79 1a                	jns    341c <sbrktest+0x335>
      printf(stdout, "fork failed\n");
    3402:	a1 d8 62 00 00       	mov    0x62d8,%eax
    3407:	c7 44 24 04 b9 44 00 	movl   $0x44b9,0x4(%esp)
    340e:	00 
    340f:	89 04 24             	mov    %eax,(%esp)
    3412:	e8 32 0c 00 00       	call   4049 <printf>
      exit();
    3417:	e8 ad 0a 00 00       	call   3ec9 <exit>
    }
    if(pid == 0){
    341c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    3420:	75 39                	jne    345b <sbrktest+0x374>
      printf(stdout, "oops could read %x = %x\n", a, *a);
    3422:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3425:	0f b6 00             	movzbl (%eax),%eax
    3428:	0f be d0             	movsbl %al,%edx
    342b:	a1 d8 62 00 00       	mov    0x62d8,%eax
    3430:	89 54 24 0c          	mov    %edx,0xc(%esp)
    3434:	8b 55 f4             	mov    -0xc(%ebp),%edx
    3437:	89 54 24 08          	mov    %edx,0x8(%esp)
    343b:	c7 44 24 04 65 59 00 	movl   $0x5965,0x4(%esp)
    3442:	00 
    3443:	89 04 24             	mov    %eax,(%esp)
    3446:	e8 fe 0b 00 00       	call   4049 <printf>
      kill(ppid);
    344b:	8b 45 d0             	mov    -0x30(%ebp),%eax
    344e:	89 04 24             	mov    %eax,(%esp)
    3451:	e8 a3 0a 00 00       	call   3ef9 <kill>
      exit();
    3456:	e8 6e 0a 00 00       	call   3ec9 <exit>
    }
    wait();
    345b:	e8 71 0a 00 00       	call   3ed1 <wait>
    printf(stdout, "sbrk downsize failed, a %x c %x\n", a, c);
    exit();
  }
  
  // can we read the kernel's memory?
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    3460:	81 45 f4 50 c3 00 00 	addl   $0xc350,-0xc(%ebp)
    3467:	81 7d f4 7f 84 1e 80 	cmpl   $0x801e847f,-0xc(%ebp)
    346e:	0f 86 78 ff ff ff    	jbe    33ec <sbrktest+0x305>
    wait();
  }

  // if we run the system out of memory, does it clean up the last
  // failed allocation?
  if(pipe(fds) != 0){
    3474:	8d 45 c8             	lea    -0x38(%ebp),%eax
    3477:	89 04 24             	mov    %eax,(%esp)
    347a:	e8 5a 0a 00 00       	call   3ed9 <pipe>
    347f:	85 c0                	test   %eax,%eax
    3481:	74 19                	je     349c <sbrktest+0x3b5>
    printf(1, "pipe() failed\n");
    3483:	c7 44 24 04 8a 48 00 	movl   $0x488a,0x4(%esp)
    348a:	00 
    348b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3492:	e8 b2 0b 00 00       	call   4049 <printf>
    exit();
    3497:	e8 2d 0a 00 00       	call   3ec9 <exit>
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    349c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    34a3:	e9 87 00 00 00       	jmp    352f <sbrktest+0x448>
    if((pids[i] = fork()) == 0){
    34a8:	e8 14 0a 00 00       	call   3ec1 <fork>
    34ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
    34b0:	89 44 95 a0          	mov    %eax,-0x60(%ebp,%edx,4)
    34b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
    34b7:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    34bb:	85 c0                	test   %eax,%eax
    34bd:	75 46                	jne    3505 <sbrktest+0x41e>
      // allocate a lot of memory
      sbrk(BIG - (uint)sbrk(0));
    34bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    34c6:	e8 86 0a 00 00       	call   3f51 <sbrk>
    34cb:	ba 00 00 40 06       	mov    $0x6400000,%edx
    34d0:	29 c2                	sub    %eax,%edx
    34d2:	89 d0                	mov    %edx,%eax
    34d4:	89 04 24             	mov    %eax,(%esp)
    34d7:	e8 75 0a 00 00       	call   3f51 <sbrk>
      write(fds[1], "x", 1);
    34dc:	8b 45 cc             	mov    -0x34(%ebp),%eax
    34df:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    34e6:	00 
    34e7:	c7 44 24 04 ef 48 00 	movl   $0x48ef,0x4(%esp)
    34ee:	00 
    34ef:	89 04 24             	mov    %eax,(%esp)
    34f2:	e8 f2 09 00 00       	call   3ee9 <write>
      // sit around until killed
      for(;;) sleep(1000);
    34f7:	c7 04 24 e8 03 00 00 	movl   $0x3e8,(%esp)
    34fe:	e8 56 0a 00 00       	call   3f59 <sleep>
    3503:	eb f2                	jmp    34f7 <sbrktest+0x410>
    }
    if(pids[i] != -1)
    3505:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3508:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    350c:	83 f8 ff             	cmp    $0xffffffff,%eax
    350f:	74 1a                	je     352b <sbrktest+0x444>
      read(fds[0], &scratch, 1);
    3511:	8b 45 c8             	mov    -0x38(%ebp),%eax
    3514:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    351b:	00 
    351c:	8d 55 9f             	lea    -0x61(%ebp),%edx
    351f:	89 54 24 04          	mov    %edx,0x4(%esp)
    3523:	89 04 24             	mov    %eax,(%esp)
    3526:	e8 b6 09 00 00       	call   3ee1 <read>
  // failed allocation?
  if(pipe(fds) != 0){
    printf(1, "pipe() failed\n");
    exit();
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    352b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    352f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3532:	83 f8 09             	cmp    $0x9,%eax
    3535:	0f 86 6d ff ff ff    	jbe    34a8 <sbrktest+0x3c1>
    if(pids[i] != -1)
      read(fds[0], &scratch, 1);
  }
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
    353b:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
    3542:	e8 0a 0a 00 00       	call   3f51 <sbrk>
    3547:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    354a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    3551:	eb 26                	jmp    3579 <sbrktest+0x492>
    if(pids[i] == -1)
    3553:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3556:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    355a:	83 f8 ff             	cmp    $0xffffffff,%eax
    355d:	75 02                	jne    3561 <sbrktest+0x47a>
      continue;
    355f:	eb 14                	jmp    3575 <sbrktest+0x48e>
    kill(pids[i]);
    3561:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3564:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    3568:	89 04 24             	mov    %eax,(%esp)
    356b:	e8 89 09 00 00       	call   3ef9 <kill>
    wait();
    3570:	e8 5c 09 00 00       	call   3ed1 <wait>
      read(fds[0], &scratch, 1);
  }
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3575:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    3579:	8b 45 f0             	mov    -0x10(%ebp),%eax
    357c:	83 f8 09             	cmp    $0x9,%eax
    357f:	76 d2                	jbe    3553 <sbrktest+0x46c>
    if(pids[i] == -1)
      continue;
    kill(pids[i]);
    wait();
  }
  if(c == (char*)0xffffffff){
    3581:	83 7d e0 ff          	cmpl   $0xffffffff,-0x20(%ebp)
    3585:	75 1a                	jne    35a1 <sbrktest+0x4ba>
    printf(stdout, "failed sbrk leaked memory\n");
    3587:	a1 d8 62 00 00       	mov    0x62d8,%eax
    358c:	c7 44 24 04 7e 59 00 	movl   $0x597e,0x4(%esp)
    3593:	00 
    3594:	89 04 24             	mov    %eax,(%esp)
    3597:	e8 ad 0a 00 00       	call   4049 <printf>
    exit();
    359c:	e8 28 09 00 00       	call   3ec9 <exit>
  }

  if(sbrk(0) > oldbrk)
    35a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    35a8:	e8 a4 09 00 00       	call   3f51 <sbrk>
    35ad:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    35b0:	76 1b                	jbe    35cd <sbrktest+0x4e6>
    sbrk(-(sbrk(0) - oldbrk));
    35b2:	8b 5d ec             	mov    -0x14(%ebp),%ebx
    35b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    35bc:	e8 90 09 00 00       	call   3f51 <sbrk>
    35c1:	29 c3                	sub    %eax,%ebx
    35c3:	89 d8                	mov    %ebx,%eax
    35c5:	89 04 24             	mov    %eax,(%esp)
    35c8:	e8 84 09 00 00       	call   3f51 <sbrk>

  printf(stdout, "sbrk test OK\n");
    35cd:	a1 d8 62 00 00       	mov    0x62d8,%eax
    35d2:	c7 44 24 04 99 59 00 	movl   $0x5999,0x4(%esp)
    35d9:	00 
    35da:	89 04 24             	mov    %eax,(%esp)
    35dd:	e8 67 0a 00 00       	call   4049 <printf>
}
    35e2:	81 c4 84 00 00 00    	add    $0x84,%esp
    35e8:	5b                   	pop    %ebx
    35e9:	5d                   	pop    %ebp
    35ea:	c3                   	ret    

000035eb <validateint>:

void
validateint(int *p)
{
    35eb:	55                   	push   %ebp
    35ec:	89 e5                	mov    %esp,%ebp
    35ee:	53                   	push   %ebx
    35ef:	83 ec 10             	sub    $0x10,%esp
  int res;
  asm("mov %%esp, %%ebx\n\t"
    35f2:	b8 0d 00 00 00       	mov    $0xd,%eax
    35f7:	8b 55 08             	mov    0x8(%ebp),%edx
    35fa:	89 d1                	mov    %edx,%ecx
    35fc:	89 e3                	mov    %esp,%ebx
    35fe:	89 cc                	mov    %ecx,%esp
    3600:	cd 40                	int    $0x40
    3602:	89 dc                	mov    %ebx,%esp
    3604:	89 45 f8             	mov    %eax,-0x8(%ebp)
      "int %2\n\t"
      "mov %%ebx, %%esp" :
      "=a" (res) :
      "a" (SYS_sleep), "n" (T_SYSCALL), "c" (p) :
      "ebx");
}
    3607:	83 c4 10             	add    $0x10,%esp
    360a:	5b                   	pop    %ebx
    360b:	5d                   	pop    %ebp
    360c:	c3                   	ret    

0000360d <validatetest>:

void
validatetest(void)
{
    360d:	55                   	push   %ebp
    360e:	89 e5                	mov    %esp,%ebp
    3610:	83 ec 28             	sub    $0x28,%esp
  int hi, pid;
  uint p;

  printf(stdout, "validate test\n");
    3613:	a1 d8 62 00 00       	mov    0x62d8,%eax
    3618:	c7 44 24 04 a7 59 00 	movl   $0x59a7,0x4(%esp)
    361f:	00 
    3620:	89 04 24             	mov    %eax,(%esp)
    3623:	e8 21 0a 00 00       	call   4049 <printf>
  hi = 1100*1024;
    3628:	c7 45 f0 00 30 11 00 	movl   $0x113000,-0x10(%ebp)

  for(p = 0; p <= (uint)hi; p += 4096){
    362f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    3636:	eb 7f                	jmp    36b7 <validatetest+0xaa>
    if((pid = fork()) == 0){
    3638:	e8 84 08 00 00       	call   3ec1 <fork>
    363d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    3640:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    3644:	75 10                	jne    3656 <validatetest+0x49>
      // try to crash the kernel by passing in a badly placed integer
      validateint((int*)p);
    3646:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3649:	89 04 24             	mov    %eax,(%esp)
    364c:	e8 9a ff ff ff       	call   35eb <validateint>
      exit();
    3651:	e8 73 08 00 00       	call   3ec9 <exit>
    }
    sleep(0);
    3656:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    365d:	e8 f7 08 00 00       	call   3f59 <sleep>
    sleep(0);
    3662:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3669:	e8 eb 08 00 00       	call   3f59 <sleep>
    kill(pid);
    366e:	8b 45 ec             	mov    -0x14(%ebp),%eax
    3671:	89 04 24             	mov    %eax,(%esp)
    3674:	e8 80 08 00 00       	call   3ef9 <kill>
    wait();
    3679:	e8 53 08 00 00       	call   3ed1 <wait>

    // try to crash the kernel by passing in a bad string pointer
    if(link("nosuchfile", (char*)p) != -1){
    367e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3681:	89 44 24 04          	mov    %eax,0x4(%esp)
    3685:	c7 04 24 b6 59 00 00 	movl   $0x59b6,(%esp)
    368c:	e8 98 08 00 00       	call   3f29 <link>
    3691:	83 f8 ff             	cmp    $0xffffffff,%eax
    3694:	74 1a                	je     36b0 <validatetest+0xa3>
      printf(stdout, "link should not succeed\n");
    3696:	a1 d8 62 00 00       	mov    0x62d8,%eax
    369b:	c7 44 24 04 c1 59 00 	movl   $0x59c1,0x4(%esp)
    36a2:	00 
    36a3:	89 04 24             	mov    %eax,(%esp)
    36a6:	e8 9e 09 00 00       	call   4049 <printf>
      exit();
    36ab:	e8 19 08 00 00       	call   3ec9 <exit>
  uint p;

  printf(stdout, "validate test\n");
  hi = 1100*1024;

  for(p = 0; p <= (uint)hi; p += 4096){
    36b0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    36b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
    36ba:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    36bd:	0f 83 75 ff ff ff    	jae    3638 <validatetest+0x2b>
      printf(stdout, "link should not succeed\n");
      exit();
    }
  }

  printf(stdout, "validate ok\n");
    36c3:	a1 d8 62 00 00       	mov    0x62d8,%eax
    36c8:	c7 44 24 04 da 59 00 	movl   $0x59da,0x4(%esp)
    36cf:	00 
    36d0:	89 04 24             	mov    %eax,(%esp)
    36d3:	e8 71 09 00 00       	call   4049 <printf>
}
    36d8:	c9                   	leave  
    36d9:	c3                   	ret    

000036da <bsstest>:

// does unintialized data start out zero?
char uninit[10000];
void
bsstest(void)
{
    36da:	55                   	push   %ebp
    36db:	89 e5                	mov    %esp,%ebp
    36dd:	83 ec 28             	sub    $0x28,%esp
  int i;

  printf(stdout, "bss test\n");
    36e0:	a1 d8 62 00 00       	mov    0x62d8,%eax
    36e5:	c7 44 24 04 e7 59 00 	movl   $0x59e7,0x4(%esp)
    36ec:	00 
    36ed:	89 04 24             	mov    %eax,(%esp)
    36f0:	e8 54 09 00 00       	call   4049 <printf>
  for(i = 0; i < sizeof(uninit); i++){
    36f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    36fc:	eb 2d                	jmp    372b <bsstest+0x51>
    if(uninit[i] != '\0'){
    36fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3701:	05 a0 63 00 00       	add    $0x63a0,%eax
    3706:	0f b6 00             	movzbl (%eax),%eax
    3709:	84 c0                	test   %al,%al
    370b:	74 1a                	je     3727 <bsstest+0x4d>
      printf(stdout, "bss test failed\n");
    370d:	a1 d8 62 00 00       	mov    0x62d8,%eax
    3712:	c7 44 24 04 f1 59 00 	movl   $0x59f1,0x4(%esp)
    3719:	00 
    371a:	89 04 24             	mov    %eax,(%esp)
    371d:	e8 27 09 00 00       	call   4049 <printf>
      exit();
    3722:	e8 a2 07 00 00       	call   3ec9 <exit>
bsstest(void)
{
  int i;

  printf(stdout, "bss test\n");
  for(i = 0; i < sizeof(uninit); i++){
    3727:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    372b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    372e:	3d 0f 27 00 00       	cmp    $0x270f,%eax
    3733:	76 c9                	jbe    36fe <bsstest+0x24>
    if(uninit[i] != '\0'){
      printf(stdout, "bss test failed\n");
      exit();
    }
  }
  printf(stdout, "bss test ok\n");
    3735:	a1 d8 62 00 00       	mov    0x62d8,%eax
    373a:	c7 44 24 04 02 5a 00 	movl   $0x5a02,0x4(%esp)
    3741:	00 
    3742:	89 04 24             	mov    %eax,(%esp)
    3745:	e8 ff 08 00 00       	call   4049 <printf>
}
    374a:	c9                   	leave  
    374b:	c3                   	ret    

0000374c <bigargtest>:
// does exec return an error if the arguments
// are larger than a page? or does it write
// below the stack and wreck the instructions/data?
void
bigargtest(void)
{
    374c:	55                   	push   %ebp
    374d:	89 e5                	mov    %esp,%ebp
    374f:	83 ec 28             	sub    $0x28,%esp
  int pid, fd;

  unlink("bigarg-ok");
    3752:	c7 04 24 0f 5a 00 00 	movl   $0x5a0f,(%esp)
    3759:	e8 bb 07 00 00       	call   3f19 <unlink>
  pid = fork();
    375e:	e8 5e 07 00 00       	call   3ec1 <fork>
    3763:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pid == 0){
    3766:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    376a:	0f 85 90 00 00 00    	jne    3800 <bigargtest+0xb4>
    static char *args[MAXARG];
    int i;
    for(i = 0; i < MAXARG-1; i++)
    3770:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    3777:	eb 12                	jmp    378b <bigargtest+0x3f>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    3779:	8b 45 f4             	mov    -0xc(%ebp),%eax
    377c:	c7 04 85 00 63 00 00 	movl   $0x5a1c,0x6300(,%eax,4)
    3783:	1c 5a 00 00 
  unlink("bigarg-ok");
  pid = fork();
  if(pid == 0){
    static char *args[MAXARG];
    int i;
    for(i = 0; i < MAXARG-1; i++)
    3787:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    378b:	83 7d f4 1e          	cmpl   $0x1e,-0xc(%ebp)
    378f:	7e e8                	jle    3779 <bigargtest+0x2d>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    args[MAXARG-1] = 0;
    3791:	c7 05 7c 63 00 00 00 	movl   $0x0,0x637c
    3798:	00 00 00 
    printf(stdout, "bigarg test\n");
    379b:	a1 d8 62 00 00       	mov    0x62d8,%eax
    37a0:	c7 44 24 04 f9 5a 00 	movl   $0x5af9,0x4(%esp)
    37a7:	00 
    37a8:	89 04 24             	mov    %eax,(%esp)
    37ab:	e8 99 08 00 00       	call   4049 <printf>
    exec("echo", args);
    37b0:	c7 44 24 04 00 63 00 	movl   $0x6300,0x4(%esp)
    37b7:	00 
    37b8:	c7 04 24 18 44 00 00 	movl   $0x4418,(%esp)
    37bf:	e8 3d 07 00 00       	call   3f01 <exec>
    printf(stdout, "bigarg test ok\n");
    37c4:	a1 d8 62 00 00       	mov    0x62d8,%eax
    37c9:	c7 44 24 04 06 5b 00 	movl   $0x5b06,0x4(%esp)
    37d0:	00 
    37d1:	89 04 24             	mov    %eax,(%esp)
    37d4:	e8 70 08 00 00       	call   4049 <printf>
    fd = open("bigarg-ok", O_CREATE);
    37d9:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    37e0:	00 
    37e1:	c7 04 24 0f 5a 00 00 	movl   $0x5a0f,(%esp)
    37e8:	e8 1c 07 00 00       	call   3f09 <open>
    37ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
    close(fd);
    37f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
    37f3:	89 04 24             	mov    %eax,(%esp)
    37f6:	e8 f6 06 00 00       	call   3ef1 <close>
    exit();
    37fb:	e8 c9 06 00 00       	call   3ec9 <exit>
  } else if(pid < 0){
    3800:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3804:	79 1a                	jns    3820 <bigargtest+0xd4>
    printf(stdout, "bigargtest: fork failed\n");
    3806:	a1 d8 62 00 00       	mov    0x62d8,%eax
    380b:	c7 44 24 04 16 5b 00 	movl   $0x5b16,0x4(%esp)
    3812:	00 
    3813:	89 04 24             	mov    %eax,(%esp)
    3816:	e8 2e 08 00 00       	call   4049 <printf>
    exit();
    381b:	e8 a9 06 00 00       	call   3ec9 <exit>
  }
  wait();
    3820:	e8 ac 06 00 00       	call   3ed1 <wait>
  fd = open("bigarg-ok", 0);
    3825:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    382c:	00 
    382d:	c7 04 24 0f 5a 00 00 	movl   $0x5a0f,(%esp)
    3834:	e8 d0 06 00 00       	call   3f09 <open>
    3839:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    383c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    3840:	79 1a                	jns    385c <bigargtest+0x110>
    printf(stdout, "bigarg test failed!\n");
    3842:	a1 d8 62 00 00       	mov    0x62d8,%eax
    3847:	c7 44 24 04 2f 5b 00 	movl   $0x5b2f,0x4(%esp)
    384e:	00 
    384f:	89 04 24             	mov    %eax,(%esp)
    3852:	e8 f2 07 00 00       	call   4049 <printf>
    exit();
    3857:	e8 6d 06 00 00       	call   3ec9 <exit>
  }
  close(fd);
    385c:	8b 45 ec             	mov    -0x14(%ebp),%eax
    385f:	89 04 24             	mov    %eax,(%esp)
    3862:	e8 8a 06 00 00       	call   3ef1 <close>
  unlink("bigarg-ok");
    3867:	c7 04 24 0f 5a 00 00 	movl   $0x5a0f,(%esp)
    386e:	e8 a6 06 00 00       	call   3f19 <unlink>
}
    3873:	c9                   	leave  
    3874:	c3                   	ret    

00003875 <fsfull>:

// what happens when the file system runs out of blocks?
// answer: balloc panics, so this test is not useful.
void
fsfull()
{
    3875:	55                   	push   %ebp
    3876:	89 e5                	mov    %esp,%ebp
    3878:	53                   	push   %ebx
    3879:	83 ec 74             	sub    $0x74,%esp
  int nfiles;
  int fsblocks = 0;
    387c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  printf(1, "fsfull test\n");
    3883:	c7 44 24 04 44 5b 00 	movl   $0x5b44,0x4(%esp)
    388a:	00 
    388b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3892:	e8 b2 07 00 00       	call   4049 <printf>

  for(nfiles = 0; ; nfiles++){
    3897:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    char name[64];
    name[0] = 'f';
    389e:	c6 45 a4 66          	movb   $0x66,-0x5c(%ebp)
    name[1] = '0' + nfiles / 1000;
    38a2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    38a5:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    38aa:	89 c8                	mov    %ecx,%eax
    38ac:	f7 ea                	imul   %edx
    38ae:	c1 fa 06             	sar    $0x6,%edx
    38b1:	89 c8                	mov    %ecx,%eax
    38b3:	c1 f8 1f             	sar    $0x1f,%eax
    38b6:	29 c2                	sub    %eax,%edx
    38b8:	89 d0                	mov    %edx,%eax
    38ba:	83 c0 30             	add    $0x30,%eax
    38bd:	88 45 a5             	mov    %al,-0x5b(%ebp)
    name[2] = '0' + (nfiles % 1000) / 100;
    38c0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    38c3:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    38c8:	89 d8                	mov    %ebx,%eax
    38ca:	f7 ea                	imul   %edx
    38cc:	c1 fa 06             	sar    $0x6,%edx
    38cf:	89 d8                	mov    %ebx,%eax
    38d1:	c1 f8 1f             	sar    $0x1f,%eax
    38d4:	89 d1                	mov    %edx,%ecx
    38d6:	29 c1                	sub    %eax,%ecx
    38d8:	69 c1 e8 03 00 00    	imul   $0x3e8,%ecx,%eax
    38de:	29 c3                	sub    %eax,%ebx
    38e0:	89 d9                	mov    %ebx,%ecx
    38e2:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    38e7:	89 c8                	mov    %ecx,%eax
    38e9:	f7 ea                	imul   %edx
    38eb:	c1 fa 05             	sar    $0x5,%edx
    38ee:	89 c8                	mov    %ecx,%eax
    38f0:	c1 f8 1f             	sar    $0x1f,%eax
    38f3:	29 c2                	sub    %eax,%edx
    38f5:	89 d0                	mov    %edx,%eax
    38f7:	83 c0 30             	add    $0x30,%eax
    38fa:	88 45 a6             	mov    %al,-0x5a(%ebp)
    name[3] = '0' + (nfiles % 100) / 10;
    38fd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    3900:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    3905:	89 d8                	mov    %ebx,%eax
    3907:	f7 ea                	imul   %edx
    3909:	c1 fa 05             	sar    $0x5,%edx
    390c:	89 d8                	mov    %ebx,%eax
    390e:	c1 f8 1f             	sar    $0x1f,%eax
    3911:	89 d1                	mov    %edx,%ecx
    3913:	29 c1                	sub    %eax,%ecx
    3915:	6b c1 64             	imul   $0x64,%ecx,%eax
    3918:	29 c3                	sub    %eax,%ebx
    391a:	89 d9                	mov    %ebx,%ecx
    391c:	ba 67 66 66 66       	mov    $0x66666667,%edx
    3921:	89 c8                	mov    %ecx,%eax
    3923:	f7 ea                	imul   %edx
    3925:	c1 fa 02             	sar    $0x2,%edx
    3928:	89 c8                	mov    %ecx,%eax
    392a:	c1 f8 1f             	sar    $0x1f,%eax
    392d:	29 c2                	sub    %eax,%edx
    392f:	89 d0                	mov    %edx,%eax
    3931:	83 c0 30             	add    $0x30,%eax
    3934:	88 45 a7             	mov    %al,-0x59(%ebp)
    name[4] = '0' + (nfiles % 10);
    3937:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    393a:	ba 67 66 66 66       	mov    $0x66666667,%edx
    393f:	89 c8                	mov    %ecx,%eax
    3941:	f7 ea                	imul   %edx
    3943:	c1 fa 02             	sar    $0x2,%edx
    3946:	89 c8                	mov    %ecx,%eax
    3948:	c1 f8 1f             	sar    $0x1f,%eax
    394b:	29 c2                	sub    %eax,%edx
    394d:	89 d0                	mov    %edx,%eax
    394f:	c1 e0 02             	shl    $0x2,%eax
    3952:	01 d0                	add    %edx,%eax
    3954:	01 c0                	add    %eax,%eax
    3956:	29 c1                	sub    %eax,%ecx
    3958:	89 ca                	mov    %ecx,%edx
    395a:	89 d0                	mov    %edx,%eax
    395c:	83 c0 30             	add    $0x30,%eax
    395f:	88 45 a8             	mov    %al,-0x58(%ebp)
    name[5] = '\0';
    3962:	c6 45 a9 00          	movb   $0x0,-0x57(%ebp)
    printf(1, "writing %s\n", name);
    3966:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    3969:	89 44 24 08          	mov    %eax,0x8(%esp)
    396d:	c7 44 24 04 51 5b 00 	movl   $0x5b51,0x4(%esp)
    3974:	00 
    3975:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    397c:	e8 c8 06 00 00       	call   4049 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    3981:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    3988:	00 
    3989:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    398c:	89 04 24             	mov    %eax,(%esp)
    398f:	e8 75 05 00 00       	call   3f09 <open>
    3994:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(fd < 0){
    3997:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    399b:	79 1d                	jns    39ba <fsfull+0x145>
      printf(1, "open %s failed\n", name);
    399d:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    39a0:	89 44 24 08          	mov    %eax,0x8(%esp)
    39a4:	c7 44 24 04 5d 5b 00 	movl   $0x5b5d,0x4(%esp)
    39ab:	00 
    39ac:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    39b3:	e8 91 06 00 00       	call   4049 <printf>
      break;
    39b8:	eb 74                	jmp    3a2e <fsfull+0x1b9>
    }
    int total = 0;
    39ba:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    while(1){
      int cc = write(fd, buf, 512);
    39c1:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
    39c8:	00 
    39c9:	c7 44 24 04 c0 8a 00 	movl   $0x8ac0,0x4(%esp)
    39d0:	00 
    39d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
    39d4:	89 04 24             	mov    %eax,(%esp)
    39d7:	e8 0d 05 00 00       	call   3ee9 <write>
    39dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(cc < 512)
    39df:	81 7d e4 ff 01 00 00 	cmpl   $0x1ff,-0x1c(%ebp)
    39e6:	7f 2f                	jg     3a17 <fsfull+0x1a2>
        break;
    39e8:	90                   	nop
      total += cc;
      fsblocks++;
    }
    printf(1, "wrote %d bytes\n", total);
    39e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
    39ec:	89 44 24 08          	mov    %eax,0x8(%esp)
    39f0:	c7 44 24 04 6d 5b 00 	movl   $0x5b6d,0x4(%esp)
    39f7:	00 
    39f8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    39ff:	e8 45 06 00 00       	call   4049 <printf>
    close(fd);
    3a04:	8b 45 e8             	mov    -0x18(%ebp),%eax
    3a07:	89 04 24             	mov    %eax,(%esp)
    3a0a:	e8 e2 04 00 00       	call   3ef1 <close>
    if(total == 0)
    3a0f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    3a13:	75 10                	jne    3a25 <fsfull+0x1b0>
    3a15:	eb 0c                	jmp    3a23 <fsfull+0x1ae>
    int total = 0;
    while(1){
      int cc = write(fd, buf, 512);
      if(cc < 512)
        break;
      total += cc;
    3a17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    3a1a:	01 45 ec             	add    %eax,-0x14(%ebp)
      fsblocks++;
    3a1d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    }
    3a21:	eb 9e                	jmp    39c1 <fsfull+0x14c>
    printf(1, "wrote %d bytes\n", total);
    close(fd);
    if(total == 0)
      break;
    3a23:	eb 09                	jmp    3a2e <fsfull+0x1b9>
  int nfiles;
  int fsblocks = 0;

  printf(1, "fsfull test\n");

  for(nfiles = 0; ; nfiles++){
    3a25:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    printf(1, "wrote %d bytes\n", total);
    close(fd);
    if(total == 0)
      break;
  }
    3a29:	e9 70 fe ff ff       	jmp    389e <fsfull+0x29>

  while(nfiles >= 0){
    3a2e:	e9 d7 00 00 00       	jmp    3b0a <fsfull+0x295>
    char name[64];
    name[0] = 'f';
    3a33:	c6 45 a4 66          	movb   $0x66,-0x5c(%ebp)
    name[1] = '0' + nfiles / 1000;
    3a37:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    3a3a:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    3a3f:	89 c8                	mov    %ecx,%eax
    3a41:	f7 ea                	imul   %edx
    3a43:	c1 fa 06             	sar    $0x6,%edx
    3a46:	89 c8                	mov    %ecx,%eax
    3a48:	c1 f8 1f             	sar    $0x1f,%eax
    3a4b:	29 c2                	sub    %eax,%edx
    3a4d:	89 d0                	mov    %edx,%eax
    3a4f:	83 c0 30             	add    $0x30,%eax
    3a52:	88 45 a5             	mov    %al,-0x5b(%ebp)
    name[2] = '0' + (nfiles % 1000) / 100;
    3a55:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    3a58:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    3a5d:	89 d8                	mov    %ebx,%eax
    3a5f:	f7 ea                	imul   %edx
    3a61:	c1 fa 06             	sar    $0x6,%edx
    3a64:	89 d8                	mov    %ebx,%eax
    3a66:	c1 f8 1f             	sar    $0x1f,%eax
    3a69:	89 d1                	mov    %edx,%ecx
    3a6b:	29 c1                	sub    %eax,%ecx
    3a6d:	69 c1 e8 03 00 00    	imul   $0x3e8,%ecx,%eax
    3a73:	29 c3                	sub    %eax,%ebx
    3a75:	89 d9                	mov    %ebx,%ecx
    3a77:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    3a7c:	89 c8                	mov    %ecx,%eax
    3a7e:	f7 ea                	imul   %edx
    3a80:	c1 fa 05             	sar    $0x5,%edx
    3a83:	89 c8                	mov    %ecx,%eax
    3a85:	c1 f8 1f             	sar    $0x1f,%eax
    3a88:	29 c2                	sub    %eax,%edx
    3a8a:	89 d0                	mov    %edx,%eax
    3a8c:	83 c0 30             	add    $0x30,%eax
    3a8f:	88 45 a6             	mov    %al,-0x5a(%ebp)
    name[3] = '0' + (nfiles % 100) / 10;
    3a92:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    3a95:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    3a9a:	89 d8                	mov    %ebx,%eax
    3a9c:	f7 ea                	imul   %edx
    3a9e:	c1 fa 05             	sar    $0x5,%edx
    3aa1:	89 d8                	mov    %ebx,%eax
    3aa3:	c1 f8 1f             	sar    $0x1f,%eax
    3aa6:	89 d1                	mov    %edx,%ecx
    3aa8:	29 c1                	sub    %eax,%ecx
    3aaa:	6b c1 64             	imul   $0x64,%ecx,%eax
    3aad:	29 c3                	sub    %eax,%ebx
    3aaf:	89 d9                	mov    %ebx,%ecx
    3ab1:	ba 67 66 66 66       	mov    $0x66666667,%edx
    3ab6:	89 c8                	mov    %ecx,%eax
    3ab8:	f7 ea                	imul   %edx
    3aba:	c1 fa 02             	sar    $0x2,%edx
    3abd:	89 c8                	mov    %ecx,%eax
    3abf:	c1 f8 1f             	sar    $0x1f,%eax
    3ac2:	29 c2                	sub    %eax,%edx
    3ac4:	89 d0                	mov    %edx,%eax
    3ac6:	83 c0 30             	add    $0x30,%eax
    3ac9:	88 45 a7             	mov    %al,-0x59(%ebp)
    name[4] = '0' + (nfiles % 10);
    3acc:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    3acf:	ba 67 66 66 66       	mov    $0x66666667,%edx
    3ad4:	89 c8                	mov    %ecx,%eax
    3ad6:	f7 ea                	imul   %edx
    3ad8:	c1 fa 02             	sar    $0x2,%edx
    3adb:	89 c8                	mov    %ecx,%eax
    3add:	c1 f8 1f             	sar    $0x1f,%eax
    3ae0:	29 c2                	sub    %eax,%edx
    3ae2:	89 d0                	mov    %edx,%eax
    3ae4:	c1 e0 02             	shl    $0x2,%eax
    3ae7:	01 d0                	add    %edx,%eax
    3ae9:	01 c0                	add    %eax,%eax
    3aeb:	29 c1                	sub    %eax,%ecx
    3aed:	89 ca                	mov    %ecx,%edx
    3aef:	89 d0                	mov    %edx,%eax
    3af1:	83 c0 30             	add    $0x30,%eax
    3af4:	88 45 a8             	mov    %al,-0x58(%ebp)
    name[5] = '\0';
    3af7:	c6 45 a9 00          	movb   $0x0,-0x57(%ebp)
    unlink(name);
    3afb:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    3afe:	89 04 24             	mov    %eax,(%esp)
    3b01:	e8 13 04 00 00       	call   3f19 <unlink>
    nfiles--;
    3b06:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    close(fd);
    if(total == 0)
      break;
  }

  while(nfiles >= 0){
    3b0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    3b0e:	0f 89 1f ff ff ff    	jns    3a33 <fsfull+0x1be>
    name[5] = '\0';
    unlink(name);
    nfiles--;
  }

  printf(1, "fsfull test finished\n");
    3b14:	c7 44 24 04 7d 5b 00 	movl   $0x5b7d,0x4(%esp)
    3b1b:	00 
    3b1c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3b23:	e8 21 05 00 00       	call   4049 <printf>
}
    3b28:	83 c4 74             	add    $0x74,%esp
    3b2b:	5b                   	pop    %ebx
    3b2c:	5d                   	pop    %ebp
    3b2d:	c3                   	ret    

00003b2e <rand>:

unsigned long randstate = 1;
unsigned int
rand()
{
    3b2e:	55                   	push   %ebp
    3b2f:	89 e5                	mov    %esp,%ebp
  randstate = randstate * 1664525 + 1013904223;
    3b31:	a1 dc 62 00 00       	mov    0x62dc,%eax
    3b36:	69 c0 0d 66 19 00    	imul   $0x19660d,%eax,%eax
    3b3c:	05 5f f3 6e 3c       	add    $0x3c6ef35f,%eax
    3b41:	a3 dc 62 00 00       	mov    %eax,0x62dc
  return randstate;
    3b46:	a1 dc 62 00 00       	mov    0x62dc,%eax
}
    3b4b:	5d                   	pop    %ebp
    3b4c:	c3                   	ret    

00003b4d <main>:

int
main(int argc, char *argv[])
{
    3b4d:	55                   	push   %ebp
    3b4e:	89 e5                	mov    %esp,%ebp
    3b50:	83 e4 f0             	and    $0xfffffff0,%esp
    3b53:	83 ec 10             	sub    $0x10,%esp
  printf(1, "usertests starting\n");
    3b56:	c7 44 24 04 93 5b 00 	movl   $0x5b93,0x4(%esp)
    3b5d:	00 
    3b5e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3b65:	e8 df 04 00 00       	call   4049 <printf>

  if(open("usertests.ran", 0) >= 0){
    3b6a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    3b71:	00 
    3b72:	c7 04 24 a7 5b 00 00 	movl   $0x5ba7,(%esp)
    3b79:	e8 8b 03 00 00       	call   3f09 <open>
    3b7e:	85 c0                	test   %eax,%eax
    3b80:	78 19                	js     3b9b <main+0x4e>
    printf(1, "already ran user tests -- rebuild fs.img\n");
    3b82:	c7 44 24 04 b8 5b 00 	movl   $0x5bb8,0x4(%esp)
    3b89:	00 
    3b8a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3b91:	e8 b3 04 00 00       	call   4049 <printf>
    exit();
    3b96:	e8 2e 03 00 00       	call   3ec9 <exit>
  }
  close(open("usertests.ran", O_CREATE));
    3b9b:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    3ba2:	00 
    3ba3:	c7 04 24 a7 5b 00 00 	movl   $0x5ba7,(%esp)
    3baa:	e8 5a 03 00 00       	call   3f09 <open>
    3baf:	89 04 24             	mov    %eax,(%esp)
    3bb2:	e8 3a 03 00 00       	call   3ef1 <close>

  createdelete();
    3bb7:	e8 c6 d6 ff ff       	call   1282 <createdelete>
  linkunlink();
    3bbc:	e8 0a e1 ff ff       	call   1ccb <linkunlink>
  concreate();
    3bc1:	e8 52 dd ff ff       	call   1918 <concreate>
  fourfiles();
    3bc6:	e8 4f d4 ff ff       	call   101a <fourfiles>
  sharedfd();
    3bcb:	e8 4c d2 ff ff       	call   e1c <sharedfd>

  bigargtest();
    3bd0:	e8 77 fb ff ff       	call   374c <bigargtest>
  bigwrite();
    3bd5:	e8 d2 ea ff ff       	call   26ac <bigwrite>
  bigargtest();
    3bda:	e8 6d fb ff ff       	call   374c <bigargtest>
  bsstest();
    3bdf:	e8 f6 fa ff ff       	call   36da <bsstest>
  sbrktest();
    3be4:	e8 fe f4 ff ff       	call   30e7 <sbrktest>
  validatetest();
    3be9:	e8 1f fa ff ff       	call   360d <validatetest>

  opentest();
    3bee:	e8 d4 c6 ff ff       	call   2c7 <opentest>
  writetest();
    3bf3:	e8 7a c7 ff ff       	call   372 <writetest>
  writetest1();
    3bf8:	e8 8a c9 ff ff       	call   587 <writetest1>
  createtest();
    3bfd:	e8 90 cb ff ff       	call   792 <createtest>

  openiputtest();
    3c02:	e8 bf c5 ff ff       	call   1c6 <openiputtest>
  exitiputtest();
    3c07:	e8 ce c4 ff ff       	call   da <exitiputtest>
  iputtest();
    3c0c:	e8 ef c3 ff ff       	call   0 <iputtest>

  mem();
    3c11:	e8 21 d1 ff ff       	call   d37 <mem>
  pipe1();
    3c16:	e8 58 cd ff ff       	call   973 <pipe1>
  preempt();
    3c1b:	e8 40 cf ff ff       	call   b60 <preempt>
  exitwait();
    3c20:	e8 94 d0 ff ff       	call   cb9 <exitwait>

  rmdot();
    3c25:	e8 0b ef ff ff       	call   2b35 <rmdot>
  fourteen();
    3c2a:	e8 b0 ed ff ff       	call   29df <fourteen>
  bigfile();
    3c2f:	e8 80 eb ff ff       	call   27b4 <bigfile>
  subdir();
    3c34:	e8 2d e3 ff ff       	call   1f66 <subdir>
  linktest();
    3c39:	e8 91 da ff ff       	call   16cf <linktest>
  unlinkread();
    3c3e:	e8 b7 d8 ff ff       	call   14fa <unlinkread>
  dirfile();
    3c43:	e8 65 f0 ff ff       	call   2cad <dirfile>
  iref();
    3c48:	e8 a2 f2 ff ff       	call   2eef <iref>
  forktest();
    3c4d:	e8 c1 f3 ff ff       	call   3013 <forktest>
  bigdir(); // slow
    3c52:	e8 a2 e1 ff ff       	call   1df9 <bigdir>
  exectest();
    3c57:	e8 c8 cc ff ff       	call   924 <exectest>

  exit();
    3c5c:	e8 68 02 00 00       	call   3ec9 <exit>

00003c61 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    3c61:	55                   	push   %ebp
    3c62:	89 e5                	mov    %esp,%ebp
    3c64:	57                   	push   %edi
    3c65:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    3c66:	8b 4d 08             	mov    0x8(%ebp),%ecx
    3c69:	8b 55 10             	mov    0x10(%ebp),%edx
    3c6c:	8b 45 0c             	mov    0xc(%ebp),%eax
    3c6f:	89 cb                	mov    %ecx,%ebx
    3c71:	89 df                	mov    %ebx,%edi
    3c73:	89 d1                	mov    %edx,%ecx
    3c75:	fc                   	cld    
    3c76:	f3 aa                	rep stos %al,%es:(%edi)
    3c78:	89 ca                	mov    %ecx,%edx
    3c7a:	89 fb                	mov    %edi,%ebx
    3c7c:	89 5d 08             	mov    %ebx,0x8(%ebp)
    3c7f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    3c82:	5b                   	pop    %ebx
    3c83:	5f                   	pop    %edi
    3c84:	5d                   	pop    %ebp
    3c85:	c3                   	ret    

00003c86 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    3c86:	55                   	push   %ebp
    3c87:	89 e5                	mov    %esp,%ebp
    3c89:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    3c8c:	8b 45 08             	mov    0x8(%ebp),%eax
    3c8f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    3c92:	90                   	nop
    3c93:	8b 45 08             	mov    0x8(%ebp),%eax
    3c96:	8d 50 01             	lea    0x1(%eax),%edx
    3c99:	89 55 08             	mov    %edx,0x8(%ebp)
    3c9c:	8b 55 0c             	mov    0xc(%ebp),%edx
    3c9f:	8d 4a 01             	lea    0x1(%edx),%ecx
    3ca2:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    3ca5:	0f b6 12             	movzbl (%edx),%edx
    3ca8:	88 10                	mov    %dl,(%eax)
    3caa:	0f b6 00             	movzbl (%eax),%eax
    3cad:	84 c0                	test   %al,%al
    3caf:	75 e2                	jne    3c93 <strcpy+0xd>
    ;
  return os;
    3cb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    3cb4:	c9                   	leave  
    3cb5:	c3                   	ret    

00003cb6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    3cb6:	55                   	push   %ebp
    3cb7:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    3cb9:	eb 08                	jmp    3cc3 <strcmp+0xd>
    p++, q++;
    3cbb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    3cbf:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    3cc3:	8b 45 08             	mov    0x8(%ebp),%eax
    3cc6:	0f b6 00             	movzbl (%eax),%eax
    3cc9:	84 c0                	test   %al,%al
    3ccb:	74 10                	je     3cdd <strcmp+0x27>
    3ccd:	8b 45 08             	mov    0x8(%ebp),%eax
    3cd0:	0f b6 10             	movzbl (%eax),%edx
    3cd3:	8b 45 0c             	mov    0xc(%ebp),%eax
    3cd6:	0f b6 00             	movzbl (%eax),%eax
    3cd9:	38 c2                	cmp    %al,%dl
    3cdb:	74 de                	je     3cbb <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    3cdd:	8b 45 08             	mov    0x8(%ebp),%eax
    3ce0:	0f b6 00             	movzbl (%eax),%eax
    3ce3:	0f b6 d0             	movzbl %al,%edx
    3ce6:	8b 45 0c             	mov    0xc(%ebp),%eax
    3ce9:	0f b6 00             	movzbl (%eax),%eax
    3cec:	0f b6 c0             	movzbl %al,%eax
    3cef:	29 c2                	sub    %eax,%edx
    3cf1:	89 d0                	mov    %edx,%eax
}
    3cf3:	5d                   	pop    %ebp
    3cf4:	c3                   	ret    

00003cf5 <strlen>:

uint
strlen(char *s)
{
    3cf5:	55                   	push   %ebp
    3cf6:	89 e5                	mov    %esp,%ebp
    3cf8:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    3cfb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    3d02:	eb 04                	jmp    3d08 <strlen+0x13>
    3d04:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    3d08:	8b 55 fc             	mov    -0x4(%ebp),%edx
    3d0b:	8b 45 08             	mov    0x8(%ebp),%eax
    3d0e:	01 d0                	add    %edx,%eax
    3d10:	0f b6 00             	movzbl (%eax),%eax
    3d13:	84 c0                	test   %al,%al
    3d15:	75 ed                	jne    3d04 <strlen+0xf>
    ;
  return n;
    3d17:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    3d1a:	c9                   	leave  
    3d1b:	c3                   	ret    

00003d1c <memset>:

void*
memset(void *dst, int c, uint n)
{
    3d1c:	55                   	push   %ebp
    3d1d:	89 e5                	mov    %esp,%ebp
    3d1f:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
    3d22:	8b 45 10             	mov    0x10(%ebp),%eax
    3d25:	89 44 24 08          	mov    %eax,0x8(%esp)
    3d29:	8b 45 0c             	mov    0xc(%ebp),%eax
    3d2c:	89 44 24 04          	mov    %eax,0x4(%esp)
    3d30:	8b 45 08             	mov    0x8(%ebp),%eax
    3d33:	89 04 24             	mov    %eax,(%esp)
    3d36:	e8 26 ff ff ff       	call   3c61 <stosb>
  return dst;
    3d3b:	8b 45 08             	mov    0x8(%ebp),%eax
}
    3d3e:	c9                   	leave  
    3d3f:	c3                   	ret    

00003d40 <strchr>:

char*
strchr(const char *s, char c)
{
    3d40:	55                   	push   %ebp
    3d41:	89 e5                	mov    %esp,%ebp
    3d43:	83 ec 04             	sub    $0x4,%esp
    3d46:	8b 45 0c             	mov    0xc(%ebp),%eax
    3d49:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    3d4c:	eb 14                	jmp    3d62 <strchr+0x22>
    if(*s == c)
    3d4e:	8b 45 08             	mov    0x8(%ebp),%eax
    3d51:	0f b6 00             	movzbl (%eax),%eax
    3d54:	3a 45 fc             	cmp    -0x4(%ebp),%al
    3d57:	75 05                	jne    3d5e <strchr+0x1e>
      return (char*)s;
    3d59:	8b 45 08             	mov    0x8(%ebp),%eax
    3d5c:	eb 13                	jmp    3d71 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    3d5e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    3d62:	8b 45 08             	mov    0x8(%ebp),%eax
    3d65:	0f b6 00             	movzbl (%eax),%eax
    3d68:	84 c0                	test   %al,%al
    3d6a:	75 e2                	jne    3d4e <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    3d6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
    3d71:	c9                   	leave  
    3d72:	c3                   	ret    

00003d73 <gets>:

char*
gets(char *buf, int max)
{
    3d73:	55                   	push   %ebp
    3d74:	89 e5                	mov    %esp,%ebp
    3d76:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    3d79:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    3d80:	eb 4c                	jmp    3dce <gets+0x5b>
    cc = read(0, &c, 1);
    3d82:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    3d89:	00 
    3d8a:	8d 45 ef             	lea    -0x11(%ebp),%eax
    3d8d:	89 44 24 04          	mov    %eax,0x4(%esp)
    3d91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3d98:	e8 44 01 00 00       	call   3ee1 <read>
    3d9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    3da0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3da4:	7f 02                	jg     3da8 <gets+0x35>
      break;
    3da6:	eb 31                	jmp    3dd9 <gets+0x66>
    buf[i++] = c;
    3da8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3dab:	8d 50 01             	lea    0x1(%eax),%edx
    3dae:	89 55 f4             	mov    %edx,-0xc(%ebp)
    3db1:	89 c2                	mov    %eax,%edx
    3db3:	8b 45 08             	mov    0x8(%ebp),%eax
    3db6:	01 c2                	add    %eax,%edx
    3db8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    3dbc:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    3dbe:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    3dc2:	3c 0a                	cmp    $0xa,%al
    3dc4:	74 13                	je     3dd9 <gets+0x66>
    3dc6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    3dca:	3c 0d                	cmp    $0xd,%al
    3dcc:	74 0b                	je     3dd9 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    3dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3dd1:	83 c0 01             	add    $0x1,%eax
    3dd4:	3b 45 0c             	cmp    0xc(%ebp),%eax
    3dd7:	7c a9                	jl     3d82 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    3dd9:	8b 55 f4             	mov    -0xc(%ebp),%edx
    3ddc:	8b 45 08             	mov    0x8(%ebp),%eax
    3ddf:	01 d0                	add    %edx,%eax
    3de1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    3de4:	8b 45 08             	mov    0x8(%ebp),%eax
}
    3de7:	c9                   	leave  
    3de8:	c3                   	ret    

00003de9 <stat>:

int
stat(char *n, struct stat *st)
{
    3de9:	55                   	push   %ebp
    3dea:	89 e5                	mov    %esp,%ebp
    3dec:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    3def:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    3df6:	00 
    3df7:	8b 45 08             	mov    0x8(%ebp),%eax
    3dfa:	89 04 24             	mov    %eax,(%esp)
    3dfd:	e8 07 01 00 00       	call   3f09 <open>
    3e02:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    3e05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    3e09:	79 07                	jns    3e12 <stat+0x29>
    return -1;
    3e0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    3e10:	eb 23                	jmp    3e35 <stat+0x4c>
  r = fstat(fd, st);
    3e12:	8b 45 0c             	mov    0xc(%ebp),%eax
    3e15:	89 44 24 04          	mov    %eax,0x4(%esp)
    3e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3e1c:	89 04 24             	mov    %eax,(%esp)
    3e1f:	e8 fd 00 00 00       	call   3f21 <fstat>
    3e24:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    3e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3e2a:	89 04 24             	mov    %eax,(%esp)
    3e2d:	e8 bf 00 00 00       	call   3ef1 <close>
  return r;
    3e32:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    3e35:	c9                   	leave  
    3e36:	c3                   	ret    

00003e37 <atoi>:

int
atoi(const char *s)
{
    3e37:	55                   	push   %ebp
    3e38:	89 e5                	mov    %esp,%ebp
    3e3a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    3e3d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    3e44:	eb 25                	jmp    3e6b <atoi+0x34>
    n = n*10 + *s++ - '0';
    3e46:	8b 55 fc             	mov    -0x4(%ebp),%edx
    3e49:	89 d0                	mov    %edx,%eax
    3e4b:	c1 e0 02             	shl    $0x2,%eax
    3e4e:	01 d0                	add    %edx,%eax
    3e50:	01 c0                	add    %eax,%eax
    3e52:	89 c1                	mov    %eax,%ecx
    3e54:	8b 45 08             	mov    0x8(%ebp),%eax
    3e57:	8d 50 01             	lea    0x1(%eax),%edx
    3e5a:	89 55 08             	mov    %edx,0x8(%ebp)
    3e5d:	0f b6 00             	movzbl (%eax),%eax
    3e60:	0f be c0             	movsbl %al,%eax
    3e63:	01 c8                	add    %ecx,%eax
    3e65:	83 e8 30             	sub    $0x30,%eax
    3e68:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    3e6b:	8b 45 08             	mov    0x8(%ebp),%eax
    3e6e:	0f b6 00             	movzbl (%eax),%eax
    3e71:	3c 2f                	cmp    $0x2f,%al
    3e73:	7e 0a                	jle    3e7f <atoi+0x48>
    3e75:	8b 45 08             	mov    0x8(%ebp),%eax
    3e78:	0f b6 00             	movzbl (%eax),%eax
    3e7b:	3c 39                	cmp    $0x39,%al
    3e7d:	7e c7                	jle    3e46 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    3e7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    3e82:	c9                   	leave  
    3e83:	c3                   	ret    

00003e84 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    3e84:	55                   	push   %ebp
    3e85:	89 e5                	mov    %esp,%ebp
    3e87:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    3e8a:	8b 45 08             	mov    0x8(%ebp),%eax
    3e8d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    3e90:	8b 45 0c             	mov    0xc(%ebp),%eax
    3e93:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    3e96:	eb 17                	jmp    3eaf <memmove+0x2b>
    *dst++ = *src++;
    3e98:	8b 45 fc             	mov    -0x4(%ebp),%eax
    3e9b:	8d 50 01             	lea    0x1(%eax),%edx
    3e9e:	89 55 fc             	mov    %edx,-0x4(%ebp)
    3ea1:	8b 55 f8             	mov    -0x8(%ebp),%edx
    3ea4:	8d 4a 01             	lea    0x1(%edx),%ecx
    3ea7:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    3eaa:	0f b6 12             	movzbl (%edx),%edx
    3ead:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    3eaf:	8b 45 10             	mov    0x10(%ebp),%eax
    3eb2:	8d 50 ff             	lea    -0x1(%eax),%edx
    3eb5:	89 55 10             	mov    %edx,0x10(%ebp)
    3eb8:	85 c0                	test   %eax,%eax
    3eba:	7f dc                	jg     3e98 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    3ebc:	8b 45 08             	mov    0x8(%ebp),%eax
}
    3ebf:	c9                   	leave  
    3ec0:	c3                   	ret    

00003ec1 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    3ec1:	b8 01 00 00 00       	mov    $0x1,%eax
    3ec6:	cd 40                	int    $0x40
    3ec8:	c3                   	ret    

00003ec9 <exit>:
SYSCALL(exit)
    3ec9:	b8 02 00 00 00       	mov    $0x2,%eax
    3ece:	cd 40                	int    $0x40
    3ed0:	c3                   	ret    

00003ed1 <wait>:
SYSCALL(wait)
    3ed1:	b8 03 00 00 00       	mov    $0x3,%eax
    3ed6:	cd 40                	int    $0x40
    3ed8:	c3                   	ret    

00003ed9 <pipe>:
SYSCALL(pipe)
    3ed9:	b8 04 00 00 00       	mov    $0x4,%eax
    3ede:	cd 40                	int    $0x40
    3ee0:	c3                   	ret    

00003ee1 <read>:
SYSCALL(read)
    3ee1:	b8 05 00 00 00       	mov    $0x5,%eax
    3ee6:	cd 40                	int    $0x40
    3ee8:	c3                   	ret    

00003ee9 <write>:
SYSCALL(write)
    3ee9:	b8 10 00 00 00       	mov    $0x10,%eax
    3eee:	cd 40                	int    $0x40
    3ef0:	c3                   	ret    

00003ef1 <close>:
SYSCALL(close)
    3ef1:	b8 15 00 00 00       	mov    $0x15,%eax
    3ef6:	cd 40                	int    $0x40
    3ef8:	c3                   	ret    

00003ef9 <kill>:
SYSCALL(kill)
    3ef9:	b8 06 00 00 00       	mov    $0x6,%eax
    3efe:	cd 40                	int    $0x40
    3f00:	c3                   	ret    

00003f01 <exec>:
SYSCALL(exec)
    3f01:	b8 07 00 00 00       	mov    $0x7,%eax
    3f06:	cd 40                	int    $0x40
    3f08:	c3                   	ret    

00003f09 <open>:
SYSCALL(open)
    3f09:	b8 0f 00 00 00       	mov    $0xf,%eax
    3f0e:	cd 40                	int    $0x40
    3f10:	c3                   	ret    

00003f11 <mknod>:
SYSCALL(mknod)
    3f11:	b8 11 00 00 00       	mov    $0x11,%eax
    3f16:	cd 40                	int    $0x40
    3f18:	c3                   	ret    

00003f19 <unlink>:
SYSCALL(unlink)
    3f19:	b8 12 00 00 00       	mov    $0x12,%eax
    3f1e:	cd 40                	int    $0x40
    3f20:	c3                   	ret    

00003f21 <fstat>:
SYSCALL(fstat)
    3f21:	b8 08 00 00 00       	mov    $0x8,%eax
    3f26:	cd 40                	int    $0x40
    3f28:	c3                   	ret    

00003f29 <link>:
SYSCALL(link)
    3f29:	b8 13 00 00 00       	mov    $0x13,%eax
    3f2e:	cd 40                	int    $0x40
    3f30:	c3                   	ret    

00003f31 <mkdir>:
SYSCALL(mkdir)
    3f31:	b8 14 00 00 00       	mov    $0x14,%eax
    3f36:	cd 40                	int    $0x40
    3f38:	c3                   	ret    

00003f39 <chdir>:
SYSCALL(chdir)
    3f39:	b8 09 00 00 00       	mov    $0x9,%eax
    3f3e:	cd 40                	int    $0x40
    3f40:	c3                   	ret    

00003f41 <dup>:
SYSCALL(dup)
    3f41:	b8 0a 00 00 00       	mov    $0xa,%eax
    3f46:	cd 40                	int    $0x40
    3f48:	c3                   	ret    

00003f49 <getpid>:
SYSCALL(getpid)
    3f49:	b8 0b 00 00 00       	mov    $0xb,%eax
    3f4e:	cd 40                	int    $0x40
    3f50:	c3                   	ret    

00003f51 <sbrk>:
SYSCALL(sbrk)
    3f51:	b8 0c 00 00 00       	mov    $0xc,%eax
    3f56:	cd 40                	int    $0x40
    3f58:	c3                   	ret    

00003f59 <sleep>:
SYSCALL(sleep)
    3f59:	b8 0d 00 00 00       	mov    $0xd,%eax
    3f5e:	cd 40                	int    $0x40
    3f60:	c3                   	ret    

00003f61 <uptime>:
SYSCALL(uptime)
    3f61:	b8 0e 00 00 00       	mov    $0xe,%eax
    3f66:	cd 40                	int    $0x40
    3f68:	c3                   	ret    

00003f69 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    3f69:	55                   	push   %ebp
    3f6a:	89 e5                	mov    %esp,%ebp
    3f6c:	83 ec 18             	sub    $0x18,%esp
    3f6f:	8b 45 0c             	mov    0xc(%ebp),%eax
    3f72:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    3f75:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    3f7c:	00 
    3f7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
    3f80:	89 44 24 04          	mov    %eax,0x4(%esp)
    3f84:	8b 45 08             	mov    0x8(%ebp),%eax
    3f87:	89 04 24             	mov    %eax,(%esp)
    3f8a:	e8 5a ff ff ff       	call   3ee9 <write>
}
    3f8f:	c9                   	leave  
    3f90:	c3                   	ret    

00003f91 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    3f91:	55                   	push   %ebp
    3f92:	89 e5                	mov    %esp,%ebp
    3f94:	56                   	push   %esi
    3f95:	53                   	push   %ebx
    3f96:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    3f99:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    3fa0:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    3fa4:	74 17                	je     3fbd <printint+0x2c>
    3fa6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    3faa:	79 11                	jns    3fbd <printint+0x2c>
    neg = 1;
    3fac:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    3fb3:	8b 45 0c             	mov    0xc(%ebp),%eax
    3fb6:	f7 d8                	neg    %eax
    3fb8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    3fbb:	eb 06                	jmp    3fc3 <printint+0x32>
  } else {
    x = xx;
    3fbd:	8b 45 0c             	mov    0xc(%ebp),%eax
    3fc0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    3fc3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    3fca:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    3fcd:	8d 41 01             	lea    0x1(%ecx),%eax
    3fd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    3fd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
    3fd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
    3fd9:	ba 00 00 00 00       	mov    $0x0,%edx
    3fde:	f7 f3                	div    %ebx
    3fe0:	89 d0                	mov    %edx,%eax
    3fe2:	0f b6 80 e0 62 00 00 	movzbl 0x62e0(%eax),%eax
    3fe9:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    3fed:	8b 75 10             	mov    0x10(%ebp),%esi
    3ff0:	8b 45 ec             	mov    -0x14(%ebp),%eax
    3ff3:	ba 00 00 00 00       	mov    $0x0,%edx
    3ff8:	f7 f6                	div    %esi
    3ffa:	89 45 ec             	mov    %eax,-0x14(%ebp)
    3ffd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    4001:	75 c7                	jne    3fca <printint+0x39>
  if(neg)
    4003:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    4007:	74 10                	je     4019 <printint+0x88>
    buf[i++] = '-';
    4009:	8b 45 f4             	mov    -0xc(%ebp),%eax
    400c:	8d 50 01             	lea    0x1(%eax),%edx
    400f:	89 55 f4             	mov    %edx,-0xc(%ebp)
    4012:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    4017:	eb 1f                	jmp    4038 <printint+0xa7>
    4019:	eb 1d                	jmp    4038 <printint+0xa7>
    putc(fd, buf[i]);
    401b:	8d 55 dc             	lea    -0x24(%ebp),%edx
    401e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4021:	01 d0                	add    %edx,%eax
    4023:	0f b6 00             	movzbl (%eax),%eax
    4026:	0f be c0             	movsbl %al,%eax
    4029:	89 44 24 04          	mov    %eax,0x4(%esp)
    402d:	8b 45 08             	mov    0x8(%ebp),%eax
    4030:	89 04 24             	mov    %eax,(%esp)
    4033:	e8 31 ff ff ff       	call   3f69 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    4038:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    403c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    4040:	79 d9                	jns    401b <printint+0x8a>
    putc(fd, buf[i]);
}
    4042:	83 c4 30             	add    $0x30,%esp
    4045:	5b                   	pop    %ebx
    4046:	5e                   	pop    %esi
    4047:	5d                   	pop    %ebp
    4048:	c3                   	ret    

00004049 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    4049:	55                   	push   %ebp
    404a:	89 e5                	mov    %esp,%ebp
    404c:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    404f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    4056:	8d 45 0c             	lea    0xc(%ebp),%eax
    4059:	83 c0 04             	add    $0x4,%eax
    405c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    405f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    4066:	e9 7c 01 00 00       	jmp    41e7 <printf+0x19e>
    c = fmt[i] & 0xff;
    406b:	8b 55 0c             	mov    0xc(%ebp),%edx
    406e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4071:	01 d0                	add    %edx,%eax
    4073:	0f b6 00             	movzbl (%eax),%eax
    4076:	0f be c0             	movsbl %al,%eax
    4079:	25 ff 00 00 00       	and    $0xff,%eax
    407e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    4081:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    4085:	75 2c                	jne    40b3 <printf+0x6a>
      if(c == '%'){
    4087:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    408b:	75 0c                	jne    4099 <printf+0x50>
        state = '%';
    408d:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    4094:	e9 4a 01 00 00       	jmp    41e3 <printf+0x19a>
      } else {
        putc(fd, c);
    4099:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    409c:	0f be c0             	movsbl %al,%eax
    409f:	89 44 24 04          	mov    %eax,0x4(%esp)
    40a3:	8b 45 08             	mov    0x8(%ebp),%eax
    40a6:	89 04 24             	mov    %eax,(%esp)
    40a9:	e8 bb fe ff ff       	call   3f69 <putc>
    40ae:	e9 30 01 00 00       	jmp    41e3 <printf+0x19a>
      }
    } else if(state == '%'){
    40b3:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    40b7:	0f 85 26 01 00 00    	jne    41e3 <printf+0x19a>
      if(c == 'd'){
    40bd:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    40c1:	75 2d                	jne    40f0 <printf+0xa7>
        printint(fd, *ap, 10, 1);
    40c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
    40c6:	8b 00                	mov    (%eax),%eax
    40c8:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    40cf:	00 
    40d0:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    40d7:	00 
    40d8:	89 44 24 04          	mov    %eax,0x4(%esp)
    40dc:	8b 45 08             	mov    0x8(%ebp),%eax
    40df:	89 04 24             	mov    %eax,(%esp)
    40e2:	e8 aa fe ff ff       	call   3f91 <printint>
        ap++;
    40e7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    40eb:	e9 ec 00 00 00       	jmp    41dc <printf+0x193>
      } else if(c == 'x' || c == 'p'){
    40f0:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    40f4:	74 06                	je     40fc <printf+0xb3>
    40f6:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    40fa:	75 2d                	jne    4129 <printf+0xe0>
        printint(fd, *ap, 16, 0);
    40fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
    40ff:	8b 00                	mov    (%eax),%eax
    4101:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    4108:	00 
    4109:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    4110:	00 
    4111:	89 44 24 04          	mov    %eax,0x4(%esp)
    4115:	8b 45 08             	mov    0x8(%ebp),%eax
    4118:	89 04 24             	mov    %eax,(%esp)
    411b:	e8 71 fe ff ff       	call   3f91 <printint>
        ap++;
    4120:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    4124:	e9 b3 00 00 00       	jmp    41dc <printf+0x193>
      } else if(c == 's'){
    4129:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    412d:	75 45                	jne    4174 <printf+0x12b>
        s = (char*)*ap;
    412f:	8b 45 e8             	mov    -0x18(%ebp),%eax
    4132:	8b 00                	mov    (%eax),%eax
    4134:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    4137:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    413b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    413f:	75 09                	jne    414a <printf+0x101>
          s = "(null)";
    4141:	c7 45 f4 e2 5b 00 00 	movl   $0x5be2,-0xc(%ebp)
        while(*s != 0){
    4148:	eb 1e                	jmp    4168 <printf+0x11f>
    414a:	eb 1c                	jmp    4168 <printf+0x11f>
          putc(fd, *s);
    414c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    414f:	0f b6 00             	movzbl (%eax),%eax
    4152:	0f be c0             	movsbl %al,%eax
    4155:	89 44 24 04          	mov    %eax,0x4(%esp)
    4159:	8b 45 08             	mov    0x8(%ebp),%eax
    415c:	89 04 24             	mov    %eax,(%esp)
    415f:	e8 05 fe ff ff       	call   3f69 <putc>
          s++;
    4164:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    4168:	8b 45 f4             	mov    -0xc(%ebp),%eax
    416b:	0f b6 00             	movzbl (%eax),%eax
    416e:	84 c0                	test   %al,%al
    4170:	75 da                	jne    414c <printf+0x103>
    4172:	eb 68                	jmp    41dc <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    4174:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    4178:	75 1d                	jne    4197 <printf+0x14e>
        putc(fd, *ap);
    417a:	8b 45 e8             	mov    -0x18(%ebp),%eax
    417d:	8b 00                	mov    (%eax),%eax
    417f:	0f be c0             	movsbl %al,%eax
    4182:	89 44 24 04          	mov    %eax,0x4(%esp)
    4186:	8b 45 08             	mov    0x8(%ebp),%eax
    4189:	89 04 24             	mov    %eax,(%esp)
    418c:	e8 d8 fd ff ff       	call   3f69 <putc>
        ap++;
    4191:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    4195:	eb 45                	jmp    41dc <printf+0x193>
      } else if(c == '%'){
    4197:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    419b:	75 17                	jne    41b4 <printf+0x16b>
        putc(fd, c);
    419d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    41a0:	0f be c0             	movsbl %al,%eax
    41a3:	89 44 24 04          	mov    %eax,0x4(%esp)
    41a7:	8b 45 08             	mov    0x8(%ebp),%eax
    41aa:	89 04 24             	mov    %eax,(%esp)
    41ad:	e8 b7 fd ff ff       	call   3f69 <putc>
    41b2:	eb 28                	jmp    41dc <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    41b4:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    41bb:	00 
    41bc:	8b 45 08             	mov    0x8(%ebp),%eax
    41bf:	89 04 24             	mov    %eax,(%esp)
    41c2:	e8 a2 fd ff ff       	call   3f69 <putc>
        putc(fd, c);
    41c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    41ca:	0f be c0             	movsbl %al,%eax
    41cd:	89 44 24 04          	mov    %eax,0x4(%esp)
    41d1:	8b 45 08             	mov    0x8(%ebp),%eax
    41d4:	89 04 24             	mov    %eax,(%esp)
    41d7:	e8 8d fd ff ff       	call   3f69 <putc>
      }
      state = 0;
    41dc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    41e3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    41e7:	8b 55 0c             	mov    0xc(%ebp),%edx
    41ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
    41ed:	01 d0                	add    %edx,%eax
    41ef:	0f b6 00             	movzbl (%eax),%eax
    41f2:	84 c0                	test   %al,%al
    41f4:	0f 85 71 fe ff ff    	jne    406b <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    41fa:	c9                   	leave  
    41fb:	c3                   	ret    

000041fc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    41fc:	55                   	push   %ebp
    41fd:	89 e5                	mov    %esp,%ebp
    41ff:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    4202:	8b 45 08             	mov    0x8(%ebp),%eax
    4205:	83 e8 08             	sub    $0x8,%eax
    4208:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    420b:	a1 88 63 00 00       	mov    0x6388,%eax
    4210:	89 45 fc             	mov    %eax,-0x4(%ebp)
    4213:	eb 24                	jmp    4239 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    4215:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4218:	8b 00                	mov    (%eax),%eax
    421a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    421d:	77 12                	ja     4231 <free+0x35>
    421f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4222:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    4225:	77 24                	ja     424b <free+0x4f>
    4227:	8b 45 fc             	mov    -0x4(%ebp),%eax
    422a:	8b 00                	mov    (%eax),%eax
    422c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    422f:	77 1a                	ja     424b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    4231:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4234:	8b 00                	mov    (%eax),%eax
    4236:	89 45 fc             	mov    %eax,-0x4(%ebp)
    4239:	8b 45 f8             	mov    -0x8(%ebp),%eax
    423c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    423f:	76 d4                	jbe    4215 <free+0x19>
    4241:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4244:	8b 00                	mov    (%eax),%eax
    4246:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    4249:	76 ca                	jbe    4215 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    424b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    424e:	8b 40 04             	mov    0x4(%eax),%eax
    4251:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    4258:	8b 45 f8             	mov    -0x8(%ebp),%eax
    425b:	01 c2                	add    %eax,%edx
    425d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4260:	8b 00                	mov    (%eax),%eax
    4262:	39 c2                	cmp    %eax,%edx
    4264:	75 24                	jne    428a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    4266:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4269:	8b 50 04             	mov    0x4(%eax),%edx
    426c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    426f:	8b 00                	mov    (%eax),%eax
    4271:	8b 40 04             	mov    0x4(%eax),%eax
    4274:	01 c2                	add    %eax,%edx
    4276:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4279:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    427c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    427f:	8b 00                	mov    (%eax),%eax
    4281:	8b 10                	mov    (%eax),%edx
    4283:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4286:	89 10                	mov    %edx,(%eax)
    4288:	eb 0a                	jmp    4294 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    428a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    428d:	8b 10                	mov    (%eax),%edx
    428f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4292:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    4294:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4297:	8b 40 04             	mov    0x4(%eax),%eax
    429a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    42a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
    42a4:	01 d0                	add    %edx,%eax
    42a6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    42a9:	75 20                	jne    42cb <free+0xcf>
    p->s.size += bp->s.size;
    42ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
    42ae:	8b 50 04             	mov    0x4(%eax),%edx
    42b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
    42b4:	8b 40 04             	mov    0x4(%eax),%eax
    42b7:	01 c2                	add    %eax,%edx
    42b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    42bc:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    42bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
    42c2:	8b 10                	mov    (%eax),%edx
    42c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    42c7:	89 10                	mov    %edx,(%eax)
    42c9:	eb 08                	jmp    42d3 <free+0xd7>
  } else
    p->s.ptr = bp;
    42cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
    42ce:	8b 55 f8             	mov    -0x8(%ebp),%edx
    42d1:	89 10                	mov    %edx,(%eax)
  freep = p;
    42d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
    42d6:	a3 88 63 00 00       	mov    %eax,0x6388
}
    42db:	c9                   	leave  
    42dc:	c3                   	ret    

000042dd <morecore>:

static Header*
morecore(uint nu)
{
    42dd:	55                   	push   %ebp
    42de:	89 e5                	mov    %esp,%ebp
    42e0:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    42e3:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    42ea:	77 07                	ja     42f3 <morecore+0x16>
    nu = 4096;
    42ec:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    42f3:	8b 45 08             	mov    0x8(%ebp),%eax
    42f6:	c1 e0 03             	shl    $0x3,%eax
    42f9:	89 04 24             	mov    %eax,(%esp)
    42fc:	e8 50 fc ff ff       	call   3f51 <sbrk>
    4301:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    4304:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    4308:	75 07                	jne    4311 <morecore+0x34>
    return 0;
    430a:	b8 00 00 00 00       	mov    $0x0,%eax
    430f:	eb 22                	jmp    4333 <morecore+0x56>
  hp = (Header*)p;
    4311:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4314:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    4317:	8b 45 f0             	mov    -0x10(%ebp),%eax
    431a:	8b 55 08             	mov    0x8(%ebp),%edx
    431d:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    4320:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4323:	83 c0 08             	add    $0x8,%eax
    4326:	89 04 24             	mov    %eax,(%esp)
    4329:	e8 ce fe ff ff       	call   41fc <free>
  return freep;
    432e:	a1 88 63 00 00       	mov    0x6388,%eax
}
    4333:	c9                   	leave  
    4334:	c3                   	ret    

00004335 <malloc>:

void*
malloc(uint nbytes)
{
    4335:	55                   	push   %ebp
    4336:	89 e5                	mov    %esp,%ebp
    4338:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    433b:	8b 45 08             	mov    0x8(%ebp),%eax
    433e:	83 c0 07             	add    $0x7,%eax
    4341:	c1 e8 03             	shr    $0x3,%eax
    4344:	83 c0 01             	add    $0x1,%eax
    4347:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    434a:	a1 88 63 00 00       	mov    0x6388,%eax
    434f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    4352:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    4356:	75 23                	jne    437b <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    4358:	c7 45 f0 80 63 00 00 	movl   $0x6380,-0x10(%ebp)
    435f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4362:	a3 88 63 00 00       	mov    %eax,0x6388
    4367:	a1 88 63 00 00       	mov    0x6388,%eax
    436c:	a3 80 63 00 00       	mov    %eax,0x6380
    base.s.size = 0;
    4371:	c7 05 84 63 00 00 00 	movl   $0x0,0x6384
    4378:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    437b:	8b 45 f0             	mov    -0x10(%ebp),%eax
    437e:	8b 00                	mov    (%eax),%eax
    4380:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    4383:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4386:	8b 40 04             	mov    0x4(%eax),%eax
    4389:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    438c:	72 4d                	jb     43db <malloc+0xa6>
      if(p->s.size == nunits)
    438e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4391:	8b 40 04             	mov    0x4(%eax),%eax
    4394:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    4397:	75 0c                	jne    43a5 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    4399:	8b 45 f4             	mov    -0xc(%ebp),%eax
    439c:	8b 10                	mov    (%eax),%edx
    439e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    43a1:	89 10                	mov    %edx,(%eax)
    43a3:	eb 26                	jmp    43cb <malloc+0x96>
      else {
        p->s.size -= nunits;
    43a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    43a8:	8b 40 04             	mov    0x4(%eax),%eax
    43ab:	2b 45 ec             	sub    -0x14(%ebp),%eax
    43ae:	89 c2                	mov    %eax,%edx
    43b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    43b3:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    43b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    43b9:	8b 40 04             	mov    0x4(%eax),%eax
    43bc:	c1 e0 03             	shl    $0x3,%eax
    43bf:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    43c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    43c5:	8b 55 ec             	mov    -0x14(%ebp),%edx
    43c8:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    43cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
    43ce:	a3 88 63 00 00       	mov    %eax,0x6388
      return (void*)(p + 1);
    43d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    43d6:	83 c0 08             	add    $0x8,%eax
    43d9:	eb 38                	jmp    4413 <malloc+0xde>
    }
    if(p == freep)
    43db:	a1 88 63 00 00       	mov    0x6388,%eax
    43e0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    43e3:	75 1b                	jne    4400 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    43e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
    43e8:	89 04 24             	mov    %eax,(%esp)
    43eb:	e8 ed fe ff ff       	call   42dd <morecore>
    43f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    43f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    43f7:	75 07                	jne    4400 <malloc+0xcb>
        return 0;
    43f9:	b8 00 00 00 00       	mov    $0x0,%eax
    43fe:	eb 13                	jmp    4413 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    4400:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4403:	89 45 f0             	mov    %eax,-0x10(%ebp)
    4406:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4409:	8b 00                	mov    (%eax),%eax
    440b:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    440e:	e9 70 ff ff ff       	jmp    4383 <malloc+0x4e>
}
    4413:	c9                   	leave  
    4414:	c3                   	ret    
