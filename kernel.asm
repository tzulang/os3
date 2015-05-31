
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 c6 10 80       	mov    $0x8010c650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 f1 38 10 80       	mov    $0x801038f1,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 84 87 10 	movl   $0x80108784,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 a2 4f 00 00       	call   80104ff0 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 70 05 11 80 64 	movl   $0x80110564,0x80110570
80100055:	05 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 74 05 11 80 64 	movl   $0x80110564,0x80110574
8010005f:	05 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 94 c6 10 80 	movl   $0x8010c694,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 74 05 11 80    	mov    0x80110574,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 64 05 11 80 	movl   $0x80110564,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 74 05 11 80       	mov    0x80110574,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 74 05 11 80       	mov    %eax,0x80110574

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 64 05 11 80 	cmpl   $0x80110564,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801000bd:	e8 4f 4f 00 00       	call   80105011 <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 74 05 11 80       	mov    0x80110574,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->sector == sector){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	83 c8 01             	or     $0x1,%eax
801000f6:	89 c2                	mov    %eax,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100104:	e8 6a 4f 00 00       	call   80105073 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 23 4c 00 00       	call   80104d47 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 64 05 11 80 	cmpl   $0x80110564,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 70 05 11 80       	mov    0x80110570,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010017c:	e8 f2 4e 00 00       	call   80105073 <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 64 05 11 80 	cmpl   $0x80110564,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 8b 87 10 80 	movl   $0x8010878b,(%esp)
8010019f:	e8 3e 05 00 00       	call   801006e2 <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, sector);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 a3 27 00 00       	call   8010297b <iderw>
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 9c 87 10 80 	movl   $0x8010879c,(%esp)
801001f6:	e8 e7 04 00 00       	call   801006e2 <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	83 c8 04             	or     $0x4,%eax
80100203:	89 c2                	mov    %eax,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 66 27 00 00       	call   8010297b <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 a3 87 10 80 	movl   $0x801087a3,(%esp)
80100230:	e8 ad 04 00 00       	call   801006e2 <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010023c:	e8 d0 4d 00 00       	call   80105011 <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 74 05 11 80    	mov    0x80110574,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 64 05 11 80 	movl   $0x80110564,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 74 05 11 80       	mov    0x80110574,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 74 05 11 80       	mov    %eax,0x80110574

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	83 e0 fe             	and    $0xfffffffe,%eax
80100290:	89 c2                	mov    %eax,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 7e 4b 00 00       	call   80104e20 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002a9:	e8 c5 4d 00 00       	call   80105073 <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	83 ec 14             	sub    $0x14,%esp
801002b6:	8b 45 08             	mov    0x8(%ebp),%eax
801002b9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002bd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002c1:	89 c2                	mov    %eax,%edx
801002c3:	ec                   	in     (%dx),%al
801002c4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002c7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002cb:	c9                   	leave  
801002cc:	c3                   	ret    

801002cd <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002cd:	55                   	push   %ebp
801002ce:	89 e5                	mov    %esp,%ebp
801002d0:	83 ec 08             	sub    $0x8,%esp
801002d3:	8b 55 08             	mov    0x8(%ebp),%edx
801002d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801002d9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002dd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002e0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002e4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002e8:	ee                   	out    %al,(%dx)
}
801002e9:	c9                   	leave  
801002ea:	c3                   	ret    

801002eb <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002eb:	55                   	push   %ebp
801002ec:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002ee:	fa                   	cli    
}
801002ef:	5d                   	pop    %ebp
801002f0:	c3                   	ret    

801002f1 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	56                   	push   %esi
801002f5:	53                   	push   %ebx
801002f6:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
801002f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801002fd:	74 1c                	je     8010031b <printint+0x2a>
801002ff:	8b 45 08             	mov    0x8(%ebp),%eax
80100302:	c1 e8 1f             	shr    $0x1f,%eax
80100305:	0f b6 c0             	movzbl %al,%eax
80100308:	89 45 10             	mov    %eax,0x10(%ebp)
8010030b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010030f:	74 0a                	je     8010031b <printint+0x2a>
    x = -xx;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	f7 d8                	neg    %eax
80100316:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100319:	eb 06                	jmp    80100321 <printint+0x30>
  else
    x = xx;
8010031b:	8b 45 08             	mov    0x8(%ebp),%eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100321:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100328:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010032b:	8d 41 01             	lea    0x1(%ecx),%eax
8010032e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100337:	ba 00 00 00 00       	mov    $0x0,%edx
8010033c:	f7 f3                	div    %ebx
8010033e:	89 d0                	mov    %edx,%eax
80100340:	0f b6 80 08 90 10 80 	movzbl -0x7fef6ff8(%eax),%eax
80100347:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010034b:	8b 75 0c             	mov    0xc(%ebp),%esi
8010034e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100351:	ba 00 00 00 00       	mov    $0x0,%edx
80100356:	f7 f6                	div    %esi
80100358:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010035b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010035f:	75 c7                	jne    80100328 <printint+0x37>

  if(sign)
80100361:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100365:	74 10                	je     80100377 <printint+0x86>
    buf[i++] = '-';
80100367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010036a:	8d 50 01             	lea    0x1(%eax),%edx
8010036d:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100370:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100375:	eb 18                	jmp    8010038f <printint+0x9e>
80100377:	eb 16                	jmp    8010038f <printint+0x9e>
    consputc(buf[i]);
80100379:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010037c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010037f:	01 d0                	add    %edx,%eax
80100381:	0f b6 00             	movzbl (%eax),%eax
80100384:	0f be c0             	movsbl %al,%eax
80100387:	89 04 24             	mov    %eax,(%esp)
8010038a:	e8 69 05 00 00       	call   801008f8 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
8010038f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100393:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100397:	79 e0                	jns    80100379 <printint+0x88>
    consputc(buf[i]);
}
80100399:	83 c4 30             	add    $0x30,%esp
8010039c:	5b                   	pop    %ebx
8010039d:	5e                   	pop    %esi
8010039e:	5d                   	pop    %ebp
8010039f:	c3                   	ret    

801003a0 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a0:	55                   	push   %ebp
801003a1:	89 e5                	mov    %esp,%ebp
801003a3:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a6:	a1 f4 b5 10 80       	mov    0x8010b5f4,%eax
801003ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b2:	74 0c                	je     801003c0 <cprintf+0x20>
    acquire(&cons.lock);
801003b4:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
801003bb:	e8 51 4c 00 00       	call   80105011 <acquire>

  if (fmt == 0)
801003c0:	8b 45 08             	mov    0x8(%ebp),%eax
801003c3:	85 c0                	test   %eax,%eax
801003c5:	75 0c                	jne    801003d3 <cprintf+0x33>
    panic("null fmt");
801003c7:	c7 04 24 aa 87 10 80 	movl   $0x801087aa,(%esp)
801003ce:	e8 0f 03 00 00       	call   801006e2 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d3:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e0:	e9 21 01 00 00       	jmp    80100506 <cprintf+0x166>
    if(c != '%'){
801003e5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003e9:	74 10                	je     801003fb <cprintf+0x5b>
      consputc(c);
801003eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ee:	89 04 24             	mov    %eax,(%esp)
801003f1:	e8 02 05 00 00       	call   801008f8 <consputc>
      continue;
801003f6:	e9 07 01 00 00       	jmp    80100502 <cprintf+0x162>
    }
    c = fmt[++i] & 0xff;
801003fb:	8b 55 08             	mov    0x8(%ebp),%edx
801003fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100405:	01 d0                	add    %edx,%eax
80100407:	0f b6 00             	movzbl (%eax),%eax
8010040a:	0f be c0             	movsbl %al,%eax
8010040d:	25 ff 00 00 00       	and    $0xff,%eax
80100412:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100415:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100419:	75 05                	jne    80100420 <cprintf+0x80>
      break;
8010041b:	e9 06 01 00 00       	jmp    80100526 <cprintf+0x186>
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4f                	je     80100477 <cprintf+0xd7>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0xa0>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13c>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xaf>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x14a>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 57                	je     8010049c <cprintf+0xfc>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2d                	je     80100477 <cprintf+0xd7>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x14a>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8d 50 04             	lea    0x4(%eax),%edx
80100455:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100458:	8b 00                	mov    (%eax),%eax
8010045a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100461:	00 
80100462:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100469:	00 
8010046a:	89 04 24             	mov    %eax,(%esp)
8010046d:	e8 7f fe ff ff       	call   801002f1 <printint>
      break;
80100472:	e9 8b 00 00 00       	jmp    80100502 <cprintf+0x162>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100477:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047a:	8d 50 04             	lea    0x4(%eax),%edx
8010047d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100480:	8b 00                	mov    (%eax),%eax
80100482:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100489:	00 
8010048a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80100491:	00 
80100492:	89 04 24             	mov    %eax,(%esp)
80100495:	e8 57 fe ff ff       	call   801002f1 <printint>
      break;
8010049a:	eb 66                	jmp    80100502 <cprintf+0x162>
    case 's':
      if((s = (char*)*argp++) == 0)
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004aa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004ae:	75 09                	jne    801004b9 <cprintf+0x119>
        s = "(null)";
801004b0:	c7 45 ec b3 87 10 80 	movl   $0x801087b3,-0x14(%ebp)
      for(; *s; s++)
801004b7:	eb 17                	jmp    801004d0 <cprintf+0x130>
801004b9:	eb 15                	jmp    801004d0 <cprintf+0x130>
        consputc(*s);
801004bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004be:	0f b6 00             	movzbl (%eax),%eax
801004c1:	0f be c0             	movsbl %al,%eax
801004c4:	89 04 24             	mov    %eax,(%esp)
801004c7:	e8 2c 04 00 00       	call   801008f8 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004cc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 e1                	jne    801004bb <cprintf+0x11b>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x162>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 10 04 00 00       	call   801008f8 <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x162>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 02 04 00 00       	call   801008f8 <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 f7 03 00 00       	call   801008f8 <consputc>
      break;
80100501:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100506:	8b 55 08             	mov    0x8(%ebp),%edx
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	01 d0                	add    %edx,%eax
8010050e:	0f b6 00             	movzbl (%eax),%eax
80100511:	0f be c0             	movsbl %al,%eax
80100514:	25 ff 00 00 00       	and    $0xff,%eax
80100519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100520:	0f 85 bf fe ff ff    	jne    801003e5 <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
80100526:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052a:	74 0c                	je     80100538 <cprintf+0x198>
    release(&cons.lock);
8010052c:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100533:	e8 3b 4b 00 00       	call   80105073 <release>
}
80100538:	c9                   	leave  
80100539:	c3                   	ret    

8010053a <p>:


void
p(char *fmt, ...)
{
8010053a:	55                   	push   %ebp
8010053b:	89 e5                	mov    %esp,%ebp
8010053d:	83 ec 38             	sub    $0x38,%esp
  if (!Debug)
80100540:	a1 00 90 10 80       	mov    0x80109000,%eax
80100545:	85 c0                	test   %eax,%eax
80100547:	75 05                	jne    8010054e <p+0x14>
	  return;
80100549:	e9 92 01 00 00       	jmp    801006e0 <p+0x1a6>
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
8010054e:	a1 f4 b5 10 80       	mov    0x8010b5f4,%eax
80100553:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100556:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010055a:	74 0c                	je     80100568 <p+0x2e>
    acquire(&cons.lock);
8010055c:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100563:	e8 a9 4a 00 00       	call   80105011 <acquire>

  if (fmt == 0)
80100568:	8b 45 08             	mov    0x8(%ebp),%eax
8010056b:	85 c0                	test   %eax,%eax
8010056d:	75 0c                	jne    8010057b <p+0x41>
    panic("null fmt");
8010056f:	c7 04 24 aa 87 10 80 	movl   $0x801087aa,(%esp)
80100576:	e8 67 01 00 00       	call   801006e2 <panic>

  argp = (uint*)(void*)(&fmt + 1);
8010057b:	8d 45 0c             	lea    0xc(%ebp),%eax
8010057e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100581:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100588:	e9 21 01 00 00       	jmp    801006ae <p+0x174>
    if(c != '%'){
8010058d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100591:	74 10                	je     801005a3 <p+0x69>
      consputc(c);
80100593:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100596:	89 04 24             	mov    %eax,(%esp)
80100599:	e8 5a 03 00 00       	call   801008f8 <consputc>
      continue;
8010059e:	e9 07 01 00 00       	jmp    801006aa <p+0x170>
    }
    c = fmt[++i] & 0xff;
801005a3:	8b 55 08             	mov    0x8(%ebp),%edx
801005a6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005ad:	01 d0                	add    %edx,%eax
801005af:	0f b6 00             	movzbl (%eax),%eax
801005b2:	0f be c0             	movsbl %al,%eax
801005b5:	25 ff 00 00 00       	and    $0xff,%eax
801005ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
801005bd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801005c1:	75 05                	jne    801005c8 <p+0x8e>
      break;
801005c3:	e9 06 01 00 00       	jmp    801006ce <p+0x194>
    switch(c){
801005c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801005cb:	83 f8 70             	cmp    $0x70,%eax
801005ce:	74 4f                	je     8010061f <p+0xe5>
801005d0:	83 f8 70             	cmp    $0x70,%eax
801005d3:	7f 13                	jg     801005e8 <p+0xae>
801005d5:	83 f8 25             	cmp    $0x25,%eax
801005d8:	0f 84 a6 00 00 00    	je     80100684 <p+0x14a>
801005de:	83 f8 64             	cmp    $0x64,%eax
801005e1:	74 14                	je     801005f7 <p+0xbd>
801005e3:	e9 aa 00 00 00       	jmp    80100692 <p+0x158>
801005e8:	83 f8 73             	cmp    $0x73,%eax
801005eb:	74 57                	je     80100644 <p+0x10a>
801005ed:	83 f8 78             	cmp    $0x78,%eax
801005f0:	74 2d                	je     8010061f <p+0xe5>
801005f2:	e9 9b 00 00 00       	jmp    80100692 <p+0x158>
    case 'd':
      printint(*argp++, 10, 1);
801005f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801005fa:	8d 50 04             	lea    0x4(%eax),%edx
801005fd:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100600:	8b 00                	mov    (%eax),%eax
80100602:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100609:	00 
8010060a:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100611:	00 
80100612:	89 04 24             	mov    %eax,(%esp)
80100615:	e8 d7 fc ff ff       	call   801002f1 <printint>
      break;
8010061a:	e9 8b 00 00 00       	jmp    801006aa <p+0x170>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010061f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100622:	8d 50 04             	lea    0x4(%eax),%edx
80100625:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100628:	8b 00                	mov    (%eax),%eax
8010062a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100631:	00 
80100632:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80100639:	00 
8010063a:	89 04 24             	mov    %eax,(%esp)
8010063d:	e8 af fc ff ff       	call   801002f1 <printint>
      break;
80100642:	eb 66                	jmp    801006aa <p+0x170>
    case 's':
      if((s = (char*)*argp++) == 0)
80100644:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100647:	8d 50 04             	lea    0x4(%eax),%edx
8010064a:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010064d:	8b 00                	mov    (%eax),%eax
8010064f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100652:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100656:	75 09                	jne    80100661 <p+0x127>
        s = "(null)";
80100658:	c7 45 ec b3 87 10 80 	movl   $0x801087b3,-0x14(%ebp)
      for(; *s; s++)
8010065f:	eb 17                	jmp    80100678 <p+0x13e>
80100661:	eb 15                	jmp    80100678 <p+0x13e>
        consputc(*s);
80100663:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100666:	0f b6 00             	movzbl (%eax),%eax
80100669:	0f be c0             	movsbl %al,%eax
8010066c:	89 04 24             	mov    %eax,(%esp)
8010066f:	e8 84 02 00 00       	call   801008f8 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
80100674:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100678:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010067b:	0f b6 00             	movzbl (%eax),%eax
8010067e:	84 c0                	test   %al,%al
80100680:	75 e1                	jne    80100663 <p+0x129>
        consputc(*s);
      break;
80100682:	eb 26                	jmp    801006aa <p+0x170>
    case '%':
      consputc('%');
80100684:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
8010068b:	e8 68 02 00 00       	call   801008f8 <consputc>
      break;
80100690:	eb 18                	jmp    801006aa <p+0x170>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100692:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
80100699:	e8 5a 02 00 00       	call   801008f8 <consputc>
      consputc(c);
8010069e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801006a1:	89 04 24             	mov    %eax,(%esp)
801006a4:	e8 4f 02 00 00       	call   801008f8 <consputc>
      break;
801006a9:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801006aa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801006ae:	8b 55 08             	mov    0x8(%ebp),%edx
801006b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006b4:	01 d0                	add    %edx,%eax
801006b6:	0f b6 00             	movzbl (%eax),%eax
801006b9:	0f be c0             	movsbl %al,%eax
801006bc:	25 ff 00 00 00       	and    $0xff,%eax
801006c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801006c4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801006c8:	0f 85 bf fe ff ff    	jne    8010058d <p+0x53>
      consputc(c);
      break;
    }
  }

  if(locking)
801006ce:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801006d2:	74 0c                	je     801006e0 <p+0x1a6>
    release(&cons.lock);
801006d4:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
801006db:	e8 93 49 00 00       	call   80105073 <release>
}
801006e0:	c9                   	leave  
801006e1:	c3                   	ret    

801006e2 <panic>:

void
panic(char *s)
{
801006e2:	55                   	push   %ebp
801006e3:	89 e5                	mov    %esp,%ebp
801006e5:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
801006e8:	e8 fe fb ff ff       	call   801002eb <cli>
  cons.locking = 0;
801006ed:	c7 05 f4 b5 10 80 00 	movl   $0x0,0x8010b5f4
801006f4:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
801006f7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801006fd:	0f b6 00             	movzbl (%eax),%eax
80100700:	0f b6 c0             	movzbl %al,%eax
80100703:	89 44 24 04          	mov    %eax,0x4(%esp)
80100707:	c7 04 24 ba 87 10 80 	movl   $0x801087ba,(%esp)
8010070e:	e8 8d fc ff ff       	call   801003a0 <cprintf>
  cprintf(s);
80100713:	8b 45 08             	mov    0x8(%ebp),%eax
80100716:	89 04 24             	mov    %eax,(%esp)
80100719:	e8 82 fc ff ff       	call   801003a0 <cprintf>
  cprintf("\n");
8010071e:	c7 04 24 c9 87 10 80 	movl   $0x801087c9,(%esp)
80100725:	e8 76 fc ff ff       	call   801003a0 <cprintf>
  getcallerpcs(&s, pcs);
8010072a:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010072d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100731:	8d 45 08             	lea    0x8(%ebp),%eax
80100734:	89 04 24             	mov    %eax,(%esp)
80100737:	e8 86 49 00 00       	call   801050c2 <getcallerpcs>
  for(i=0; i<10; i++)
8010073c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100743:	eb 1b                	jmp    80100760 <panic+0x7e>
    cprintf(" %p", pcs[i]);
80100745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100748:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
8010074c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100750:	c7 04 24 cb 87 10 80 	movl   $0x801087cb,(%esp)
80100757:	e8 44 fc ff ff       	call   801003a0 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
8010075c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100760:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80100764:	7e df                	jle    80100745 <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
80100766:	c7 05 a0 b5 10 80 01 	movl   $0x1,0x8010b5a0
8010076d:	00 00 00 
  for(;;)
    ;
80100770:	eb fe                	jmp    80100770 <panic+0x8e>

80100772 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100772:	55                   	push   %ebp
80100773:	89 e5                	mov    %esp,%ebp
80100775:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100778:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
8010077f:	00 
80100780:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100787:	e8 41 fb ff ff       	call   801002cd <outb>
  pos = inb(CRTPORT+1) << 8;
8010078c:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100793:	e8 18 fb ff ff       	call   801002b0 <inb>
80100798:	0f b6 c0             	movzbl %al,%eax
8010079b:	c1 e0 08             	shl    $0x8,%eax
8010079e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801007a1:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
801007a8:	00 
801007a9:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801007b0:	e8 18 fb ff ff       	call   801002cd <outb>
  pos |= inb(CRTPORT+1);
801007b5:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801007bc:	e8 ef fa ff ff       	call   801002b0 <inb>
801007c1:	0f b6 c0             	movzbl %al,%eax
801007c4:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
801007c7:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
801007cb:	75 30                	jne    801007fd <cgaputc+0x8b>
    pos += 80 - pos%80;
801007cd:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801007d0:	ba 67 66 66 66       	mov    $0x66666667,%edx
801007d5:	89 c8                	mov    %ecx,%eax
801007d7:	f7 ea                	imul   %edx
801007d9:	c1 fa 05             	sar    $0x5,%edx
801007dc:	89 c8                	mov    %ecx,%eax
801007de:	c1 f8 1f             	sar    $0x1f,%eax
801007e1:	29 c2                	sub    %eax,%edx
801007e3:	89 d0                	mov    %edx,%eax
801007e5:	c1 e0 02             	shl    $0x2,%eax
801007e8:	01 d0                	add    %edx,%eax
801007ea:	c1 e0 04             	shl    $0x4,%eax
801007ed:	29 c1                	sub    %eax,%ecx
801007ef:	89 ca                	mov    %ecx,%edx
801007f1:	b8 50 00 00 00       	mov    $0x50,%eax
801007f6:	29 d0                	sub    %edx,%eax
801007f8:	01 45 f4             	add    %eax,-0xc(%ebp)
801007fb:	eb 35                	jmp    80100832 <cgaputc+0xc0>
  else if(c == BACKSPACE){
801007fd:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100804:	75 0c                	jne    80100812 <cgaputc+0xa0>
    if(pos > 0) --pos;
80100806:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010080a:	7e 26                	jle    80100832 <cgaputc+0xc0>
8010080c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100810:	eb 20                	jmp    80100832 <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100812:	8b 0d 04 90 10 80    	mov    0x80109004,%ecx
80100818:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010081b:	8d 50 01             	lea    0x1(%eax),%edx
8010081e:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100821:	01 c0                	add    %eax,%eax
80100823:	8d 14 01             	lea    (%ecx,%eax,1),%edx
80100826:	8b 45 08             	mov    0x8(%ebp),%eax
80100829:	0f b6 c0             	movzbl %al,%eax
8010082c:	80 cc 07             	or     $0x7,%ah
8010082f:	66 89 02             	mov    %ax,(%edx)
  
  if((pos/80) >= 24){  // Scroll up.
80100832:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100839:	7e 53                	jle    8010088e <cgaputc+0x11c>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
8010083b:	a1 04 90 10 80       	mov    0x80109004,%eax
80100840:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100846:	a1 04 90 10 80       	mov    0x80109004,%eax
8010084b:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
80100852:	00 
80100853:	89 54 24 04          	mov    %edx,0x4(%esp)
80100857:	89 04 24             	mov    %eax,(%esp)
8010085a:	e8 d5 4a 00 00       	call   80105334 <memmove>
    pos -= 80;
8010085f:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100863:	b8 80 07 00 00       	mov    $0x780,%eax
80100868:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010086b:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010086e:	a1 04 90 10 80       	mov    0x80109004,%eax
80100873:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100876:	01 c9                	add    %ecx,%ecx
80100878:	01 c8                	add    %ecx,%eax
8010087a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010087e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100885:	00 
80100886:	89 04 24             	mov    %eax,(%esp)
80100889:	e8 d7 49 00 00       	call   80105265 <memset>
  }
  
  outb(CRTPORT, 14);
8010088e:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100895:	00 
80100896:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010089d:	e8 2b fa ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos>>8);
801008a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008a5:	c1 f8 08             	sar    $0x8,%eax
801008a8:	0f b6 c0             	movzbl %al,%eax
801008ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801008af:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801008b6:	e8 12 fa ff ff       	call   801002cd <outb>
  outb(CRTPORT, 15);
801008bb:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
801008c2:	00 
801008c3:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801008ca:	e8 fe f9 ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos);
801008cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008d2:	0f b6 c0             	movzbl %al,%eax
801008d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801008d9:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801008e0:	e8 e8 f9 ff ff       	call   801002cd <outb>
  crt[pos] = ' ' | 0x0700;
801008e5:	a1 04 90 10 80       	mov    0x80109004,%eax
801008ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801008ed:	01 d2                	add    %edx,%edx
801008ef:	01 d0                	add    %edx,%eax
801008f1:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
801008f6:	c9                   	leave  
801008f7:	c3                   	ret    

801008f8 <consputc>:

void
consputc(int c)
{
801008f8:	55                   	push   %ebp
801008f9:	89 e5                	mov    %esp,%ebp
801008fb:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
801008fe:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
80100903:	85 c0                	test   %eax,%eax
80100905:	74 07                	je     8010090e <consputc+0x16>
    cli();
80100907:	e8 df f9 ff ff       	call   801002eb <cli>
    for(;;)
      ;
8010090c:	eb fe                	jmp    8010090c <consputc+0x14>
  }

  if(c == BACKSPACE){
8010090e:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100915:	75 26                	jne    8010093d <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100917:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010091e:	e8 16 63 00 00       	call   80106c39 <uartputc>
80100923:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010092a:	e8 0a 63 00 00       	call   80106c39 <uartputc>
8010092f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100936:	e8 fe 62 00 00       	call   80106c39 <uartputc>
8010093b:	eb 0b                	jmp    80100948 <consputc+0x50>
  } else
    uartputc(c);
8010093d:	8b 45 08             	mov    0x8(%ebp),%eax
80100940:	89 04 24             	mov    %eax,(%esp)
80100943:	e8 f1 62 00 00       	call   80106c39 <uartputc>
  cgaputc(c);
80100948:	8b 45 08             	mov    0x8(%ebp),%eax
8010094b:	89 04 24             	mov    %eax,(%esp)
8010094e:	e8 1f fe ff ff       	call   80100772 <cgaputc>
}
80100953:	c9                   	leave  
80100954:	c3                   	ret    

80100955 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
80100955:	55                   	push   %ebp
80100956:	89 e5                	mov    %esp,%ebp
80100958:	83 ec 28             	sub    $0x28,%esp
  int c;

  acquire(&input.lock);
8010095b:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100962:	e8 aa 46 00 00       	call   80105011 <acquire>
  while((c = getc()) >= 0){
80100967:	e9 37 01 00 00       	jmp    80100aa3 <consoleintr+0x14e>
    switch(c){
8010096c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010096f:	83 f8 10             	cmp    $0x10,%eax
80100972:	74 1e                	je     80100992 <consoleintr+0x3d>
80100974:	83 f8 10             	cmp    $0x10,%eax
80100977:	7f 0a                	jg     80100983 <consoleintr+0x2e>
80100979:	83 f8 08             	cmp    $0x8,%eax
8010097c:	74 64                	je     801009e2 <consoleintr+0x8d>
8010097e:	e9 91 00 00 00       	jmp    80100a14 <consoleintr+0xbf>
80100983:	83 f8 15             	cmp    $0x15,%eax
80100986:	74 2f                	je     801009b7 <consoleintr+0x62>
80100988:	83 f8 7f             	cmp    $0x7f,%eax
8010098b:	74 55                	je     801009e2 <consoleintr+0x8d>
8010098d:	e9 82 00 00 00       	jmp    80100a14 <consoleintr+0xbf>
    case C('P'):  // Process listing.
      procdump();
80100992:	e8 2c 45 00 00       	call   80104ec3 <procdump>
      break;
80100997:	e9 07 01 00 00       	jmp    80100aa3 <consoleintr+0x14e>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010099c:	a1 3c 08 11 80       	mov    0x8011083c,%eax
801009a1:	83 e8 01             	sub    $0x1,%eax
801009a4:	a3 3c 08 11 80       	mov    %eax,0x8011083c
        consputc(BACKSPACE);
801009a9:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
801009b0:	e8 43 ff ff ff       	call   801008f8 <consputc>
801009b5:	eb 01                	jmp    801009b8 <consoleintr+0x63>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801009b7:	90                   	nop
801009b8:	8b 15 3c 08 11 80    	mov    0x8011083c,%edx
801009be:	a1 38 08 11 80       	mov    0x80110838,%eax
801009c3:	39 c2                	cmp    %eax,%edx
801009c5:	74 16                	je     801009dd <consoleintr+0x88>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801009c7:	a1 3c 08 11 80       	mov    0x8011083c,%eax
801009cc:	83 e8 01             	sub    $0x1,%eax
801009cf:	83 e0 7f             	and    $0x7f,%eax
801009d2:	0f b6 80 b4 07 11 80 	movzbl -0x7feef84c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801009d9:	3c 0a                	cmp    $0xa,%al
801009db:	75 bf                	jne    8010099c <consoleintr+0x47>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
801009dd:	e9 c1 00 00 00       	jmp    80100aa3 <consoleintr+0x14e>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801009e2:	8b 15 3c 08 11 80    	mov    0x8011083c,%edx
801009e8:	a1 38 08 11 80       	mov    0x80110838,%eax
801009ed:	39 c2                	cmp    %eax,%edx
801009ef:	74 1e                	je     80100a0f <consoleintr+0xba>
        input.e--;
801009f1:	a1 3c 08 11 80       	mov    0x8011083c,%eax
801009f6:	83 e8 01             	sub    $0x1,%eax
801009f9:	a3 3c 08 11 80       	mov    %eax,0x8011083c
        consputc(BACKSPACE);
801009fe:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100a05:	e8 ee fe ff ff       	call   801008f8 <consputc>
      }
      break;
80100a0a:	e9 94 00 00 00       	jmp    80100aa3 <consoleintr+0x14e>
80100a0f:	e9 8f 00 00 00       	jmp    80100aa3 <consoleintr+0x14e>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100a14:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100a18:	0f 84 84 00 00 00    	je     80100aa2 <consoleintr+0x14d>
80100a1e:	8b 15 3c 08 11 80    	mov    0x8011083c,%edx
80100a24:	a1 34 08 11 80       	mov    0x80110834,%eax
80100a29:	29 c2                	sub    %eax,%edx
80100a2b:	89 d0                	mov    %edx,%eax
80100a2d:	83 f8 7f             	cmp    $0x7f,%eax
80100a30:	77 70                	ja     80100aa2 <consoleintr+0x14d>
        c = (c == '\r') ? '\n' : c;
80100a32:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
80100a36:	74 05                	je     80100a3d <consoleintr+0xe8>
80100a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a3b:	eb 05                	jmp    80100a42 <consoleintr+0xed>
80100a3d:	b8 0a 00 00 00       	mov    $0xa,%eax
80100a42:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100a45:	a1 3c 08 11 80       	mov    0x8011083c,%eax
80100a4a:	8d 50 01             	lea    0x1(%eax),%edx
80100a4d:	89 15 3c 08 11 80    	mov    %edx,0x8011083c
80100a53:	83 e0 7f             	and    $0x7f,%eax
80100a56:	89 c2                	mov    %eax,%edx
80100a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a5b:	88 82 b4 07 11 80    	mov    %al,-0x7feef84c(%edx)
        consputc(c);
80100a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a64:	89 04 24             	mov    %eax,(%esp)
80100a67:	e8 8c fe ff ff       	call   801008f8 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100a6c:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
80100a70:	74 18                	je     80100a8a <consoleintr+0x135>
80100a72:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
80100a76:	74 12                	je     80100a8a <consoleintr+0x135>
80100a78:	a1 3c 08 11 80       	mov    0x8011083c,%eax
80100a7d:	8b 15 34 08 11 80    	mov    0x80110834,%edx
80100a83:	83 ea 80             	sub    $0xffffff80,%edx
80100a86:	39 d0                	cmp    %edx,%eax
80100a88:	75 18                	jne    80100aa2 <consoleintr+0x14d>
          input.w = input.e;
80100a8a:	a1 3c 08 11 80       	mov    0x8011083c,%eax
80100a8f:	a3 38 08 11 80       	mov    %eax,0x80110838
          wakeup(&input.r);
80100a94:	c7 04 24 34 08 11 80 	movl   $0x80110834,(%esp)
80100a9b:	e8 80 43 00 00       	call   80104e20 <wakeup>
        }
      }
      break;
80100aa0:	eb 00                	jmp    80100aa2 <consoleintr+0x14d>
80100aa2:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
80100aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80100aa6:	ff d0                	call   *%eax
80100aa8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100aab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100aaf:	0f 89 b7 fe ff ff    	jns    8010096c <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
80100ab5:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100abc:	e8 b2 45 00 00       	call   80105073 <release>
}
80100ac1:	c9                   	leave  
80100ac2:	c3                   	ret    

80100ac3 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100ac3:	55                   	push   %ebp
80100ac4:	89 e5                	mov    %esp,%ebp
80100ac6:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100ac9:	8b 45 08             	mov    0x8(%ebp),%eax
80100acc:	89 04 24             	mov    %eax,(%esp)
80100acf:	e8 af 10 00 00       	call   80101b83 <iunlock>
  target = n;
80100ad4:	8b 45 10             	mov    0x10(%ebp),%eax
80100ad7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100ada:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100ae1:	e8 2b 45 00 00       	call   80105011 <acquire>
  while(n > 0){
80100ae6:	e9 aa 00 00 00       	jmp    80100b95 <consoleread+0xd2>
    while(input.r == input.w){
80100aeb:	eb 42                	jmp    80100b2f <consoleread+0x6c>
      if(proc->killed){
80100aed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100af3:	8b 40 24             	mov    0x24(%eax),%eax
80100af6:	85 c0                	test   %eax,%eax
80100af8:	74 21                	je     80100b1b <consoleread+0x58>
        release(&input.lock);
80100afa:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100b01:	e8 6d 45 00 00       	call   80105073 <release>
        ilock(ip);
80100b06:	8b 45 08             	mov    0x8(%ebp),%eax
80100b09:	89 04 24             	mov    %eax,(%esp)
80100b0c:	e8 24 0f 00 00       	call   80101a35 <ilock>
        return -1;
80100b11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b16:	e9 a5 00 00 00       	jmp    80100bc0 <consoleread+0xfd>
      }
      sleep(&input.r, &input.lock);
80100b1b:	c7 44 24 04 80 07 11 	movl   $0x80110780,0x4(%esp)
80100b22:	80 
80100b23:	c7 04 24 34 08 11 80 	movl   $0x80110834,(%esp)
80100b2a:	e8 18 42 00 00       	call   80104d47 <sleep>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100b2f:	8b 15 34 08 11 80    	mov    0x80110834,%edx
80100b35:	a1 38 08 11 80       	mov    0x80110838,%eax
80100b3a:	39 c2                	cmp    %eax,%edx
80100b3c:	74 af                	je     80100aed <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100b3e:	a1 34 08 11 80       	mov    0x80110834,%eax
80100b43:	8d 50 01             	lea    0x1(%eax),%edx
80100b46:	89 15 34 08 11 80    	mov    %edx,0x80110834
80100b4c:	83 e0 7f             	and    $0x7f,%eax
80100b4f:	0f b6 80 b4 07 11 80 	movzbl -0x7feef84c(%eax),%eax
80100b56:	0f be c0             	movsbl %al,%eax
80100b59:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100b5c:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100b60:	75 19                	jne    80100b7b <consoleread+0xb8>
      if(n < target){
80100b62:	8b 45 10             	mov    0x10(%ebp),%eax
80100b65:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100b68:	73 0f                	jae    80100b79 <consoleread+0xb6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100b6a:	a1 34 08 11 80       	mov    0x80110834,%eax
80100b6f:	83 e8 01             	sub    $0x1,%eax
80100b72:	a3 34 08 11 80       	mov    %eax,0x80110834
      }
      break;
80100b77:	eb 26                	jmp    80100b9f <consoleread+0xdc>
80100b79:	eb 24                	jmp    80100b9f <consoleread+0xdc>
    }
    *dst++ = c;
80100b7b:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b7e:	8d 50 01             	lea    0x1(%eax),%edx
80100b81:	89 55 0c             	mov    %edx,0xc(%ebp)
80100b84:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100b87:	88 10                	mov    %dl,(%eax)
    --n;
80100b89:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100b8d:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100b91:	75 02                	jne    80100b95 <consoleread+0xd2>
      break;
80100b93:	eb 0a                	jmp    80100b9f <consoleread+0xdc>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100b95:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100b99:	0f 8f 4c ff ff ff    	jg     80100aeb <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&input.lock);
80100b9f:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100ba6:	e8 c8 44 00 00       	call   80105073 <release>
  ilock(ip);
80100bab:	8b 45 08             	mov    0x8(%ebp),%eax
80100bae:	89 04 24             	mov    %eax,(%esp)
80100bb1:	e8 7f 0e 00 00       	call   80101a35 <ilock>

  return target - n;
80100bb6:	8b 45 10             	mov    0x10(%ebp),%eax
80100bb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100bbc:	29 c2                	sub    %eax,%edx
80100bbe:	89 d0                	mov    %edx,%eax
}
80100bc0:	c9                   	leave  
80100bc1:	c3                   	ret    

80100bc2 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100bc2:	55                   	push   %ebp
80100bc3:	89 e5                	mov    %esp,%ebp
80100bc5:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100bc8:	8b 45 08             	mov    0x8(%ebp),%eax
80100bcb:	89 04 24             	mov    %eax,(%esp)
80100bce:	e8 b0 0f 00 00       	call   80101b83 <iunlock>
  acquire(&cons.lock);
80100bd3:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100bda:	e8 32 44 00 00       	call   80105011 <acquire>
  for(i = 0; i < n; i++)
80100bdf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100be6:	eb 1d                	jmp    80100c05 <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100be8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100beb:	8b 45 0c             	mov    0xc(%ebp),%eax
80100bee:	01 d0                	add    %edx,%eax
80100bf0:	0f b6 00             	movzbl (%eax),%eax
80100bf3:	0f be c0             	movsbl %al,%eax
80100bf6:	0f b6 c0             	movzbl %al,%eax
80100bf9:	89 04 24             	mov    %eax,(%esp)
80100bfc:	e8 f7 fc ff ff       	call   801008f8 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100c01:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100c08:	3b 45 10             	cmp    0x10(%ebp),%eax
80100c0b:	7c db                	jl     80100be8 <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100c0d:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100c14:	e8 5a 44 00 00       	call   80105073 <release>
  ilock(ip);
80100c19:	8b 45 08             	mov    0x8(%ebp),%eax
80100c1c:	89 04 24             	mov    %eax,(%esp)
80100c1f:	e8 11 0e 00 00       	call   80101a35 <ilock>

  return n;
80100c24:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100c27:	c9                   	leave  
80100c28:	c3                   	ret    

80100c29 <consoleinit>:

void
consoleinit(void)
{
80100c29:	55                   	push   %ebp
80100c2a:	89 e5                	mov    %esp,%ebp
80100c2c:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100c2f:	c7 44 24 04 cf 87 10 	movl   $0x801087cf,0x4(%esp)
80100c36:	80 
80100c37:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100c3e:	e8 ad 43 00 00       	call   80104ff0 <initlock>
  initlock(&input.lock, "input");
80100c43:	c7 44 24 04 d7 87 10 	movl   $0x801087d7,0x4(%esp)
80100c4a:	80 
80100c4b:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100c52:	e8 99 43 00 00       	call   80104ff0 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100c57:	c7 05 ec 11 11 80 c2 	movl   $0x80100bc2,0x801111ec
80100c5e:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100c61:	c7 05 e8 11 11 80 c3 	movl   $0x80100ac3,0x801111e8
80100c68:	0a 10 80 
  cons.locking = 1;
80100c6b:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100c72:	00 00 00 

  picenable(IRQ_KBD);
80100c75:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100c7c:	e8 2b 33 00 00       	call   80103fac <picenable>
  ioapicenable(IRQ_KBD, 0);
80100c81:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100c88:	00 
80100c89:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100c90:	e8 a2 1e 00 00       	call   80102b37 <ioapicenable>
}
80100c95:	c9                   	leave  
80100c96:	c3                   	ret    

80100c97 <exec>:

extern void flushTLB();

int
exec(char *path, char **argv)
{
80100c97:	55                   	push   %ebp
80100c98:	89 e5                	mov    %esp,%ebp
80100c9a:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100ca0:	e8 45 29 00 00       	call   801035ea <begin_op>
  if((ip = namei(path)) == 0){
80100ca5:	8b 45 08             	mov    0x8(%ebp),%eax
80100ca8:	89 04 24             	mov    %eax,(%esp)
80100cab:	e8 30 19 00 00       	call   801025e0 <namei>
80100cb0:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100cb3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100cb7:	75 0f                	jne    80100cc8 <exec+0x31>
    end_op();
80100cb9:	e8 b0 29 00 00       	call   8010366e <end_op>
    return -1;
80100cbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100cc3:	e9 1a 04 00 00       	jmp    801010e2 <exec+0x44b>
  }
  ilock(ip);
80100cc8:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100ccb:	89 04 24             	mov    %eax,(%esp)
80100cce:	e8 62 0d 00 00       	call   80101a35 <ilock>
  pgdir = 0;
80100cd3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100cda:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100ce1:	00 
80100ce2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100ce9:	00 
80100cea:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100cf0:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cf4:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100cf7:	89 04 24             	mov    %eax,(%esp)
80100cfa:	e8 43 12 00 00       	call   80101f42 <readi>
80100cff:	83 f8 33             	cmp    $0x33,%eax
80100d02:	77 05                	ja     80100d09 <exec+0x72>
    goto bad;
80100d04:	e9 ad 03 00 00       	jmp    801010b6 <exec+0x41f>
  if(elf.magic != ELF_MAGIC)
80100d09:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100d0f:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100d14:	74 05                	je     80100d1b <exec+0x84>
    goto bad;
80100d16:	e9 9b 03 00 00       	jmp    801010b6 <exec+0x41f>

  if((pgdir = setupkvm()) == 0)
80100d1b:	e8 a6 70 00 00       	call   80107dc6 <setupkvm>
80100d20:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100d23:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100d27:	75 05                	jne    80100d2e <exec+0x97>
    goto bad;
80100d29:	e9 88 03 00 00       	jmp    801010b6 <exec+0x41f>

  // Load program into memory.
  sz = 0;
80100d2e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d35:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100d3c:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100d42:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d45:	e9 cb 00 00 00       	jmp    80100e15 <exec+0x17e>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100d4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d4d:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100d54:	00 
80100d55:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d59:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100d5f:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d63:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100d66:	89 04 24             	mov    %eax,(%esp)
80100d69:	e8 d4 11 00 00       	call   80101f42 <readi>
80100d6e:	83 f8 20             	cmp    $0x20,%eax
80100d71:	74 05                	je     80100d78 <exec+0xe1>
      goto bad;
80100d73:	e9 3e 03 00 00       	jmp    801010b6 <exec+0x41f>
    if(ph.type != ELF_PROG_LOAD)
80100d78:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100d7e:	83 f8 01             	cmp    $0x1,%eax
80100d81:	74 05                	je     80100d88 <exec+0xf1>
      continue;
80100d83:	e9 80 00 00 00       	jmp    80100e08 <exec+0x171>
    if(ph.memsz < ph.filesz)
80100d88:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100d8e:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100d94:	39 c2                	cmp    %eax,%edx
80100d96:	73 05                	jae    80100d9d <exec+0x106>
      goto bad;
80100d98:	e9 19 03 00 00       	jmp    801010b6 <exec+0x41f>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d9d:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100da3:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100da9:	01 d0                	add    %edx,%eax
80100dab:	89 44 24 08          	mov    %eax,0x8(%esp)
80100daf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100db2:	89 44 24 04          	mov    %eax,0x4(%esp)
80100db6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100db9:	89 04 24             	mov    %eax,(%esp)
80100dbc:	e8 c5 73 00 00       	call   80108186 <allocuvm>
80100dc1:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100dc4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100dc8:	75 05                	jne    80100dcf <exec+0x138>
      goto bad;
80100dca:	e9 e7 02 00 00       	jmp    801010b6 <exec+0x41f>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100dcf:	8b 8d f8 fe ff ff    	mov    -0x108(%ebp),%ecx
80100dd5:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100ddb:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100de1:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100de5:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100de9:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100dec:	89 54 24 08          	mov    %edx,0x8(%esp)
80100df0:	89 44 24 04          	mov    %eax,0x4(%esp)
80100df4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100df7:	89 04 24             	mov    %eax,(%esp)
80100dfa:	e8 9c 72 00 00       	call   8010809b <loaduvm>
80100dff:	85 c0                	test   %eax,%eax
80100e01:	79 05                	jns    80100e08 <exec+0x171>
      goto bad;
80100e03:	e9 ae 02 00 00       	jmp    801010b6 <exec+0x41f>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100e08:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100e0c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100e0f:	83 c0 20             	add    $0x20,%eax
80100e12:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100e15:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100e1c:	0f b7 c0             	movzwl %ax,%eax
80100e1f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100e22:	0f 8f 22 ff ff ff    	jg     80100d4a <exec+0xb3>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100e28:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100e2b:	89 04 24             	mov    %eax,(%esp)
80100e2e:	e8 86 0e 00 00       	call   80101cb9 <iunlockput>
  end_op();
80100e33:	e8 36 28 00 00       	call   8010366e <end_op>
  ip = 0;
80100e38:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100e3f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e42:	05 ff 0f 00 00       	add    $0xfff,%eax
80100e47:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e4c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100e4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e52:	05 00 20 00 00       	add    $0x2000,%eax
80100e57:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e5e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e62:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e65:	89 04 24             	mov    %eax,(%esp)
80100e68:	e8 19 73 00 00       	call   80108186 <allocuvm>
80100e6d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e70:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e74:	75 05                	jne    80100e7b <exec+0x1e4>
    goto bad;
80100e76:	e9 3b 02 00 00       	jmp    801010b6 <exec+0x41f>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100e7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e7e:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e83:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e87:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e8a:	89 04 24             	mov    %eax,(%esp)
80100e8d:	e8 24 75 00 00       	call   801083b6 <clearpteu>
  sp = sz;
80100e92:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e95:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e98:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e9f:	e9 9a 00 00 00       	jmp    80100f3e <exec+0x2a7>
    if(argc >= MAXARG)
80100ea4:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100ea8:	76 05                	jbe    80100eaf <exec+0x218>
      goto bad;
80100eaa:	e9 07 02 00 00       	jmp    801010b6 <exec+0x41f>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100eaf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eb2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100eb9:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ebc:	01 d0                	add    %edx,%eax
80100ebe:	8b 00                	mov    (%eax),%eax
80100ec0:	89 04 24             	mov    %eax,(%esp)
80100ec3:	e8 07 46 00 00       	call   801054cf <strlen>
80100ec8:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ecb:	29 c2                	sub    %eax,%edx
80100ecd:	89 d0                	mov    %edx,%eax
80100ecf:	83 e8 01             	sub    $0x1,%eax
80100ed2:	83 e0 fc             	and    $0xfffffffc,%eax
80100ed5:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100ed8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100edb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ee2:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ee5:	01 d0                	add    %edx,%eax
80100ee7:	8b 00                	mov    (%eax),%eax
80100ee9:	89 04 24             	mov    %eax,(%esp)
80100eec:	e8 de 45 00 00       	call   801054cf <strlen>
80100ef1:	83 c0 01             	add    $0x1,%eax
80100ef4:	89 c2                	mov    %eax,%edx
80100ef6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ef9:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100f00:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f03:	01 c8                	add    %ecx,%eax
80100f05:	8b 00                	mov    (%eax),%eax
80100f07:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100f0b:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f0f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f12:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f16:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f19:	89 04 24             	mov    %eax,(%esp)
80100f1c:	e8 5a 76 00 00       	call   8010857b <copyout>
80100f21:	85 c0                	test   %eax,%eax
80100f23:	79 05                	jns    80100f2a <exec+0x293>
      goto bad;
80100f25:	e9 8c 01 00 00       	jmp    801010b6 <exec+0x41f>
    ustack[3+argc] = sp;
80100f2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f2d:	8d 50 03             	lea    0x3(%eax),%edx
80100f30:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f33:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100f3a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100f3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f41:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f48:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f4b:	01 d0                	add    %edx,%eax
80100f4d:	8b 00                	mov    (%eax),%eax
80100f4f:	85 c0                	test   %eax,%eax
80100f51:	0f 85 4d ff ff ff    	jne    80100ea4 <exec+0x20d>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100f57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f5a:	83 c0 03             	add    $0x3,%eax
80100f5d:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100f64:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100f68:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100f6f:	ff ff ff 
  ustack[1] = argc;
80100f72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f75:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100f7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f7e:	83 c0 01             	add    $0x1,%eax
80100f81:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f88:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f8b:	29 d0                	sub    %edx,%eax
80100f8d:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100f93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f96:	83 c0 04             	add    $0x4,%eax
80100f99:	c1 e0 02             	shl    $0x2,%eax
80100f9c:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100fa2:	83 c0 04             	add    $0x4,%eax
80100fa5:	c1 e0 02             	shl    $0x2,%eax
80100fa8:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100fac:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100fb2:	89 44 24 08          	mov    %eax,0x8(%esp)
80100fb6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100fb9:	89 44 24 04          	mov    %eax,0x4(%esp)
80100fbd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100fc0:	89 04 24             	mov    %eax,(%esp)
80100fc3:	e8 b3 75 00 00       	call   8010857b <copyout>
80100fc8:	85 c0                	test   %eax,%eax
80100fca:	79 05                	jns    80100fd1 <exec+0x33a>
    goto bad;
80100fcc:	e9 e5 00 00 00       	jmp    801010b6 <exec+0x41f>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100fd1:	8b 45 08             	mov    0x8(%ebp),%eax
80100fd4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fda:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100fdd:	eb 17                	jmp    80100ff6 <exec+0x35f>
    if(*s == '/')
80100fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fe2:	0f b6 00             	movzbl (%eax),%eax
80100fe5:	3c 2f                	cmp    $0x2f,%al
80100fe7:	75 09                	jne    80100ff2 <exec+0x35b>
      last = s+1;
80100fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fec:	83 c0 01             	add    $0x1,%eax
80100fef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ff2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ff9:	0f b6 00             	movzbl (%eax),%eax
80100ffc:	84 c0                	test   %al,%al
80100ffe:	75 df                	jne    80100fdf <exec+0x348>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80101000:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101006:	8d 50 6c             	lea    0x6c(%eax),%edx
80101009:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80101010:	00 
80101011:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101014:	89 44 24 04          	mov    %eax,0x4(%esp)
80101018:	89 14 24             	mov    %edx,(%esp)
8010101b:	e8 65 44 00 00       	call   80105485 <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80101020:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101026:	8b 40 04             	mov    0x4(%eax),%eax
80101029:	89 45 cc             	mov    %eax,-0x34(%ebp)
  proc->pgdir = pgdir;
8010102c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101032:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80101035:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80101038:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010103e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101041:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80101043:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101049:	8b 40 18             	mov    0x18(%eax),%eax
8010104c:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80101052:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80101055:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010105b:	8b 40 18             	mov    0x18(%eax),%eax
8010105e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101061:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80101064:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010106a:	89 04 24             	mov    %eax,(%esp)
8010106d:	e8 4d 6e 00 00       	call   80107ebf <switchuvm>
  freevm(oldpgdir);
80101072:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101075:	89 04 24             	mov    %eax,(%esp)
80101078:	e8 9f 72 00 00       	call   8010831c <freevm>
   int j;
         for ( j = 0; j < 512; ++j) {
8010107d:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
80101084:	eb 1b                	jmp    801010a1 <exec+0x40a>
         cpu->kpgdir[j] = 0;
80101086:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010108c:	8b 40 04             	mov    0x4(%eax),%eax
8010108f:	8b 55 d0             	mov    -0x30(%ebp),%edx
80101092:	c1 e2 02             	shl    $0x2,%edx
80101095:	01 d0                	add    %edx,%eax
80101097:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  proc->tf->eip = elf.entry;  // main
  proc->tf->esp = sp;
  switchuvm(proc);
  freevm(oldpgdir);
   int j;
         for ( j = 0; j < 512; ++j) {
8010109d:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
801010a1:	81 7d d0 ff 01 00 00 	cmpl   $0x1ff,-0x30(%ebp)
801010a8:	7e dc                	jle    80101086 <exec+0x3ef>
         cpu->kpgdir[j] = 0;
     }

  flushTLB();
801010aa:	e8 85 76 00 00       	call   80108734 <flushTLB>

  return 0;
801010af:	b8 00 00 00 00       	mov    $0x0,%eax
801010b4:	eb 2c                	jmp    801010e2 <exec+0x44b>

 bad:
  if(pgdir)
801010b6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
801010ba:	74 0b                	je     801010c7 <exec+0x430>
    freevm(pgdir);
801010bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801010bf:	89 04 24             	mov    %eax,(%esp)
801010c2:	e8 55 72 00 00       	call   8010831c <freevm>
  if(ip){
801010c7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
801010cb:	74 10                	je     801010dd <exec+0x446>
    iunlockput(ip);
801010cd:	8b 45 d8             	mov    -0x28(%ebp),%eax
801010d0:	89 04 24             	mov    %eax,(%esp)
801010d3:	e8 e1 0b 00 00       	call   80101cb9 <iunlockput>
    end_op();
801010d8:	e8 91 25 00 00       	call   8010366e <end_op>
  }
  return -1;
801010dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010e2:	c9                   	leave  
801010e3:	c3                   	ret    

801010e4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801010e4:	55                   	push   %ebp
801010e5:	89 e5                	mov    %esp,%ebp
801010e7:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
801010ea:	c7 44 24 04 dd 87 10 	movl   $0x801087dd,0x4(%esp)
801010f1:	80 
801010f2:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
801010f9:	e8 f2 3e 00 00       	call   80104ff0 <initlock>
}
801010fe:	c9                   	leave  
801010ff:	c3                   	ret    

80101100 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101100:	55                   	push   %ebp
80101101:	89 e5                	mov    %esp,%ebp
80101103:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80101106:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
8010110d:	e8 ff 3e 00 00       	call   80105011 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101112:	c7 45 f4 74 08 11 80 	movl   $0x80110874,-0xc(%ebp)
80101119:	eb 29                	jmp    80101144 <filealloc+0x44>
    if(f->ref == 0){
8010111b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010111e:	8b 40 04             	mov    0x4(%eax),%eax
80101121:	85 c0                	test   %eax,%eax
80101123:	75 1b                	jne    80101140 <filealloc+0x40>
      f->ref = 1;
80101125:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101128:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010112f:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80101136:	e8 38 3f 00 00       	call   80105073 <release>
      return f;
8010113b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010113e:	eb 1e                	jmp    8010115e <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101140:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101144:	81 7d f4 d4 11 11 80 	cmpl   $0x801111d4,-0xc(%ebp)
8010114b:	72 ce                	jb     8010111b <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
8010114d:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80101154:	e8 1a 3f 00 00       	call   80105073 <release>
  return 0;
80101159:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010115e:	c9                   	leave  
8010115f:	c3                   	ret    

80101160 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101160:	55                   	push   %ebp
80101161:	89 e5                	mov    %esp,%ebp
80101163:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80101166:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
8010116d:	e8 9f 3e 00 00       	call   80105011 <acquire>
  if(f->ref < 1)
80101172:	8b 45 08             	mov    0x8(%ebp),%eax
80101175:	8b 40 04             	mov    0x4(%eax),%eax
80101178:	85 c0                	test   %eax,%eax
8010117a:	7f 0c                	jg     80101188 <filedup+0x28>
    panic("filedup");
8010117c:	c7 04 24 e4 87 10 80 	movl   $0x801087e4,(%esp)
80101183:	e8 5a f5 ff ff       	call   801006e2 <panic>
  f->ref++;
80101188:	8b 45 08             	mov    0x8(%ebp),%eax
8010118b:	8b 40 04             	mov    0x4(%eax),%eax
8010118e:	8d 50 01             	lea    0x1(%eax),%edx
80101191:	8b 45 08             	mov    0x8(%ebp),%eax
80101194:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101197:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
8010119e:	e8 d0 3e 00 00       	call   80105073 <release>
  return f;
801011a3:	8b 45 08             	mov    0x8(%ebp),%eax
}
801011a6:	c9                   	leave  
801011a7:	c3                   	ret    

801011a8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801011a8:	55                   	push   %ebp
801011a9:	89 e5                	mov    %esp,%ebp
801011ab:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
801011ae:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
801011b5:	e8 57 3e 00 00       	call   80105011 <acquire>
  if(f->ref < 1)
801011ba:	8b 45 08             	mov    0x8(%ebp),%eax
801011bd:	8b 40 04             	mov    0x4(%eax),%eax
801011c0:	85 c0                	test   %eax,%eax
801011c2:	7f 0c                	jg     801011d0 <fileclose+0x28>
    panic("fileclose");
801011c4:	c7 04 24 ec 87 10 80 	movl   $0x801087ec,(%esp)
801011cb:	e8 12 f5 ff ff       	call   801006e2 <panic>
  if(--f->ref > 0){
801011d0:	8b 45 08             	mov    0x8(%ebp),%eax
801011d3:	8b 40 04             	mov    0x4(%eax),%eax
801011d6:	8d 50 ff             	lea    -0x1(%eax),%edx
801011d9:	8b 45 08             	mov    0x8(%ebp),%eax
801011dc:	89 50 04             	mov    %edx,0x4(%eax)
801011df:	8b 45 08             	mov    0x8(%ebp),%eax
801011e2:	8b 40 04             	mov    0x4(%eax),%eax
801011e5:	85 c0                	test   %eax,%eax
801011e7:	7e 11                	jle    801011fa <fileclose+0x52>
    release(&ftable.lock);
801011e9:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
801011f0:	e8 7e 3e 00 00       	call   80105073 <release>
801011f5:	e9 82 00 00 00       	jmp    8010127c <fileclose+0xd4>
    return;
  }
  ff = *f;
801011fa:	8b 45 08             	mov    0x8(%ebp),%eax
801011fd:	8b 10                	mov    (%eax),%edx
801011ff:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101202:	8b 50 04             	mov    0x4(%eax),%edx
80101205:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101208:	8b 50 08             	mov    0x8(%eax),%edx
8010120b:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010120e:	8b 50 0c             	mov    0xc(%eax),%edx
80101211:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101214:	8b 50 10             	mov    0x10(%eax),%edx
80101217:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010121a:	8b 40 14             	mov    0x14(%eax),%eax
8010121d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101220:	8b 45 08             	mov    0x8(%ebp),%eax
80101223:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010122a:	8b 45 08             	mov    0x8(%ebp),%eax
8010122d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101233:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
8010123a:	e8 34 3e 00 00       	call   80105073 <release>
  
  if(ff.type == FD_PIPE)
8010123f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101242:	83 f8 01             	cmp    $0x1,%eax
80101245:	75 18                	jne    8010125f <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
80101247:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010124b:	0f be d0             	movsbl %al,%edx
8010124e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101251:	89 54 24 04          	mov    %edx,0x4(%esp)
80101255:	89 04 24             	mov    %eax,(%esp)
80101258:	e8 ff 2f 00 00       	call   8010425c <pipeclose>
8010125d:	eb 1d                	jmp    8010127c <fileclose+0xd4>
  else if(ff.type == FD_INODE){
8010125f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101262:	83 f8 02             	cmp    $0x2,%eax
80101265:	75 15                	jne    8010127c <fileclose+0xd4>
    begin_op();
80101267:	e8 7e 23 00 00       	call   801035ea <begin_op>
    iput(ff.ip);
8010126c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010126f:	89 04 24             	mov    %eax,(%esp)
80101272:	e8 71 09 00 00       	call   80101be8 <iput>
    end_op();
80101277:	e8 f2 23 00 00       	call   8010366e <end_op>
  }
}
8010127c:	c9                   	leave  
8010127d:	c3                   	ret    

8010127e <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010127e:	55                   	push   %ebp
8010127f:	89 e5                	mov    %esp,%ebp
80101281:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
80101284:	8b 45 08             	mov    0x8(%ebp),%eax
80101287:	8b 00                	mov    (%eax),%eax
80101289:	83 f8 02             	cmp    $0x2,%eax
8010128c:	75 38                	jne    801012c6 <filestat+0x48>
    ilock(f->ip);
8010128e:	8b 45 08             	mov    0x8(%ebp),%eax
80101291:	8b 40 10             	mov    0x10(%eax),%eax
80101294:	89 04 24             	mov    %eax,(%esp)
80101297:	e8 99 07 00 00       	call   80101a35 <ilock>
    stati(f->ip, st);
8010129c:	8b 45 08             	mov    0x8(%ebp),%eax
8010129f:	8b 40 10             	mov    0x10(%eax),%eax
801012a2:	8b 55 0c             	mov    0xc(%ebp),%edx
801012a5:	89 54 24 04          	mov    %edx,0x4(%esp)
801012a9:	89 04 24             	mov    %eax,(%esp)
801012ac:	e8 4c 0c 00 00       	call   80101efd <stati>
    iunlock(f->ip);
801012b1:	8b 45 08             	mov    0x8(%ebp),%eax
801012b4:	8b 40 10             	mov    0x10(%eax),%eax
801012b7:	89 04 24             	mov    %eax,(%esp)
801012ba:	e8 c4 08 00 00       	call   80101b83 <iunlock>
    return 0;
801012bf:	b8 00 00 00 00       	mov    $0x0,%eax
801012c4:	eb 05                	jmp    801012cb <filestat+0x4d>
  }
  return -1;
801012c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801012cb:	c9                   	leave  
801012cc:	c3                   	ret    

801012cd <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801012cd:	55                   	push   %ebp
801012ce:	89 e5                	mov    %esp,%ebp
801012d0:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801012d3:	8b 45 08             	mov    0x8(%ebp),%eax
801012d6:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801012da:	84 c0                	test   %al,%al
801012dc:	75 0a                	jne    801012e8 <fileread+0x1b>
    return -1;
801012de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012e3:	e9 9f 00 00 00       	jmp    80101387 <fileread+0xba>
  if(f->type == FD_PIPE)
801012e8:	8b 45 08             	mov    0x8(%ebp),%eax
801012eb:	8b 00                	mov    (%eax),%eax
801012ed:	83 f8 01             	cmp    $0x1,%eax
801012f0:	75 1e                	jne    80101310 <fileread+0x43>
    return piperead(f->pipe, addr, n);
801012f2:	8b 45 08             	mov    0x8(%ebp),%eax
801012f5:	8b 40 0c             	mov    0xc(%eax),%eax
801012f8:	8b 55 10             	mov    0x10(%ebp),%edx
801012fb:	89 54 24 08          	mov    %edx,0x8(%esp)
801012ff:	8b 55 0c             	mov    0xc(%ebp),%edx
80101302:	89 54 24 04          	mov    %edx,0x4(%esp)
80101306:	89 04 24             	mov    %eax,(%esp)
80101309:	e8 cf 30 00 00       	call   801043dd <piperead>
8010130e:	eb 77                	jmp    80101387 <fileread+0xba>
  if(f->type == FD_INODE){
80101310:	8b 45 08             	mov    0x8(%ebp),%eax
80101313:	8b 00                	mov    (%eax),%eax
80101315:	83 f8 02             	cmp    $0x2,%eax
80101318:	75 61                	jne    8010137b <fileread+0xae>
    ilock(f->ip);
8010131a:	8b 45 08             	mov    0x8(%ebp),%eax
8010131d:	8b 40 10             	mov    0x10(%eax),%eax
80101320:	89 04 24             	mov    %eax,(%esp)
80101323:	e8 0d 07 00 00       	call   80101a35 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101328:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010132b:	8b 45 08             	mov    0x8(%ebp),%eax
8010132e:	8b 50 14             	mov    0x14(%eax),%edx
80101331:	8b 45 08             	mov    0x8(%ebp),%eax
80101334:	8b 40 10             	mov    0x10(%eax),%eax
80101337:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010133b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010133f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101342:	89 54 24 04          	mov    %edx,0x4(%esp)
80101346:	89 04 24             	mov    %eax,(%esp)
80101349:	e8 f4 0b 00 00       	call   80101f42 <readi>
8010134e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101351:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101355:	7e 11                	jle    80101368 <fileread+0x9b>
      f->off += r;
80101357:	8b 45 08             	mov    0x8(%ebp),%eax
8010135a:	8b 50 14             	mov    0x14(%eax),%edx
8010135d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101360:	01 c2                	add    %eax,%edx
80101362:	8b 45 08             	mov    0x8(%ebp),%eax
80101365:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101368:	8b 45 08             	mov    0x8(%ebp),%eax
8010136b:	8b 40 10             	mov    0x10(%eax),%eax
8010136e:	89 04 24             	mov    %eax,(%esp)
80101371:	e8 0d 08 00 00       	call   80101b83 <iunlock>
    return r;
80101376:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101379:	eb 0c                	jmp    80101387 <fileread+0xba>
  }
  panic("fileread");
8010137b:	c7 04 24 f6 87 10 80 	movl   $0x801087f6,(%esp)
80101382:	e8 5b f3 ff ff       	call   801006e2 <panic>
}
80101387:	c9                   	leave  
80101388:	c3                   	ret    

80101389 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101389:	55                   	push   %ebp
8010138a:	89 e5                	mov    %esp,%ebp
8010138c:	53                   	push   %ebx
8010138d:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
80101390:	8b 45 08             	mov    0x8(%ebp),%eax
80101393:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101397:	84 c0                	test   %al,%al
80101399:	75 0a                	jne    801013a5 <filewrite+0x1c>
    return -1;
8010139b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013a0:	e9 20 01 00 00       	jmp    801014c5 <filewrite+0x13c>
  if(f->type == FD_PIPE)
801013a5:	8b 45 08             	mov    0x8(%ebp),%eax
801013a8:	8b 00                	mov    (%eax),%eax
801013aa:	83 f8 01             	cmp    $0x1,%eax
801013ad:	75 21                	jne    801013d0 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801013af:	8b 45 08             	mov    0x8(%ebp),%eax
801013b2:	8b 40 0c             	mov    0xc(%eax),%eax
801013b5:	8b 55 10             	mov    0x10(%ebp),%edx
801013b8:	89 54 24 08          	mov    %edx,0x8(%esp)
801013bc:	8b 55 0c             	mov    0xc(%ebp),%edx
801013bf:	89 54 24 04          	mov    %edx,0x4(%esp)
801013c3:	89 04 24             	mov    %eax,(%esp)
801013c6:	e8 23 2f 00 00       	call   801042ee <pipewrite>
801013cb:	e9 f5 00 00 00       	jmp    801014c5 <filewrite+0x13c>
  if(f->type == FD_INODE){
801013d0:	8b 45 08             	mov    0x8(%ebp),%eax
801013d3:	8b 00                	mov    (%eax),%eax
801013d5:	83 f8 02             	cmp    $0x2,%eax
801013d8:	0f 85 db 00 00 00    	jne    801014b9 <filewrite+0x130>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801013de:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801013e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801013ec:	e9 a8 00 00 00       	jmp    80101499 <filewrite+0x110>
      int n1 = n - i;
801013f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013f4:	8b 55 10             	mov    0x10(%ebp),%edx
801013f7:	29 c2                	sub    %eax,%edx
801013f9:	89 d0                	mov    %edx,%eax
801013fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801013fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101401:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101404:	7e 06                	jle    8010140c <filewrite+0x83>
        n1 = max;
80101406:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101409:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010140c:	e8 d9 21 00 00       	call   801035ea <begin_op>
      ilock(f->ip);
80101411:	8b 45 08             	mov    0x8(%ebp),%eax
80101414:	8b 40 10             	mov    0x10(%eax),%eax
80101417:	89 04 24             	mov    %eax,(%esp)
8010141a:	e8 16 06 00 00       	call   80101a35 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010141f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101422:	8b 45 08             	mov    0x8(%ebp),%eax
80101425:	8b 50 14             	mov    0x14(%eax),%edx
80101428:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010142b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010142e:	01 c3                	add    %eax,%ebx
80101430:	8b 45 08             	mov    0x8(%ebp),%eax
80101433:	8b 40 10             	mov    0x10(%eax),%eax
80101436:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010143a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010143e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101442:	89 04 24             	mov    %eax,(%esp)
80101445:	e8 5c 0c 00 00       	call   801020a6 <writei>
8010144a:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010144d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101451:	7e 11                	jle    80101464 <filewrite+0xdb>
        f->off += r;
80101453:	8b 45 08             	mov    0x8(%ebp),%eax
80101456:	8b 50 14             	mov    0x14(%eax),%edx
80101459:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010145c:	01 c2                	add    %eax,%edx
8010145e:	8b 45 08             	mov    0x8(%ebp),%eax
80101461:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101464:	8b 45 08             	mov    0x8(%ebp),%eax
80101467:	8b 40 10             	mov    0x10(%eax),%eax
8010146a:	89 04 24             	mov    %eax,(%esp)
8010146d:	e8 11 07 00 00       	call   80101b83 <iunlock>
      end_op();
80101472:	e8 f7 21 00 00       	call   8010366e <end_op>

      if(r < 0)
80101477:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010147b:	79 02                	jns    8010147f <filewrite+0xf6>
        break;
8010147d:	eb 26                	jmp    801014a5 <filewrite+0x11c>
      if(r != n1)
8010147f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101482:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101485:	74 0c                	je     80101493 <filewrite+0x10a>
        panic("short filewrite");
80101487:	c7 04 24 ff 87 10 80 	movl   $0x801087ff,(%esp)
8010148e:	e8 4f f2 ff ff       	call   801006e2 <panic>
      i += r;
80101493:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101496:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101499:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010149c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010149f:	0f 8c 4c ff ff ff    	jl     801013f1 <filewrite+0x68>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801014a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014a8:	3b 45 10             	cmp    0x10(%ebp),%eax
801014ab:	75 05                	jne    801014b2 <filewrite+0x129>
801014ad:	8b 45 10             	mov    0x10(%ebp),%eax
801014b0:	eb 05                	jmp    801014b7 <filewrite+0x12e>
801014b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801014b7:	eb 0c                	jmp    801014c5 <filewrite+0x13c>
  }
  panic("filewrite");
801014b9:	c7 04 24 0f 88 10 80 	movl   $0x8010880f,(%esp)
801014c0:	e8 1d f2 ff ff       	call   801006e2 <panic>
}
801014c5:	83 c4 24             	add    $0x24,%esp
801014c8:	5b                   	pop    %ebx
801014c9:	5d                   	pop    %ebp
801014ca:	c3                   	ret    

801014cb <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801014cb:	55                   	push   %ebp
801014cc:	89 e5                	mov    %esp,%ebp
801014ce:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801014d1:	8b 45 08             	mov    0x8(%ebp),%eax
801014d4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801014db:	00 
801014dc:	89 04 24             	mov    %eax,(%esp)
801014df:	e8 c2 ec ff ff       	call   801001a6 <bread>
801014e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801014e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014ea:	83 c0 18             	add    $0x18,%eax
801014ed:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801014f4:	00 
801014f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801014f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801014fc:	89 04 24             	mov    %eax,(%esp)
801014ff:	e8 30 3e 00 00       	call   80105334 <memmove>
  brelse(bp);
80101504:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101507:	89 04 24             	mov    %eax,(%esp)
8010150a:	e8 08 ed ff ff       	call   80100217 <brelse>
}
8010150f:	c9                   	leave  
80101510:	c3                   	ret    

80101511 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101511:	55                   	push   %ebp
80101512:	89 e5                	mov    %esp,%ebp
80101514:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101517:	8b 55 0c             	mov    0xc(%ebp),%edx
8010151a:	8b 45 08             	mov    0x8(%ebp),%eax
8010151d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101521:	89 04 24             	mov    %eax,(%esp)
80101524:	e8 7d ec ff ff       	call   801001a6 <bread>
80101529:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010152c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010152f:	83 c0 18             	add    $0x18,%eax
80101532:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80101539:	00 
8010153a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101541:	00 
80101542:	89 04 24             	mov    %eax,(%esp)
80101545:	e8 1b 3d 00 00       	call   80105265 <memset>
  log_write(bp);
8010154a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010154d:	89 04 24             	mov    %eax,(%esp)
80101550:	e8 a0 22 00 00       	call   801037f5 <log_write>
  brelse(bp);
80101555:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101558:	89 04 24             	mov    %eax,(%esp)
8010155b:	e8 b7 ec ff ff       	call   80100217 <brelse>
}
80101560:	c9                   	leave  
80101561:	c3                   	ret    

80101562 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101562:	55                   	push   %ebp
80101563:	89 e5                	mov    %esp,%ebp
80101565:	83 ec 38             	sub    $0x38,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
80101568:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
8010156f:	8b 45 08             	mov    0x8(%ebp),%eax
80101572:	8d 55 d8             	lea    -0x28(%ebp),%edx
80101575:	89 54 24 04          	mov    %edx,0x4(%esp)
80101579:	89 04 24             	mov    %eax,(%esp)
8010157c:	e8 4a ff ff ff       	call   801014cb <readsb>
  for(b = 0; b < sb.size; b += BPB){
80101581:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101588:	e9 07 01 00 00       	jmp    80101694 <balloc+0x132>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
8010158d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101590:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101596:	85 c0                	test   %eax,%eax
80101598:	0f 48 c2             	cmovs  %edx,%eax
8010159b:	c1 f8 0c             	sar    $0xc,%eax
8010159e:	8b 55 e0             	mov    -0x20(%ebp),%edx
801015a1:	c1 ea 03             	shr    $0x3,%edx
801015a4:	01 d0                	add    %edx,%eax
801015a6:	83 c0 03             	add    $0x3,%eax
801015a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801015ad:	8b 45 08             	mov    0x8(%ebp),%eax
801015b0:	89 04 24             	mov    %eax,(%esp)
801015b3:	e8 ee eb ff ff       	call   801001a6 <bread>
801015b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015bb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801015c2:	e9 9d 00 00 00       	jmp    80101664 <balloc+0x102>
      m = 1 << (bi % 8);
801015c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015ca:	99                   	cltd   
801015cb:	c1 ea 1d             	shr    $0x1d,%edx
801015ce:	01 d0                	add    %edx,%eax
801015d0:	83 e0 07             	and    $0x7,%eax
801015d3:	29 d0                	sub    %edx,%eax
801015d5:	ba 01 00 00 00       	mov    $0x1,%edx
801015da:	89 c1                	mov    %eax,%ecx
801015dc:	d3 e2                	shl    %cl,%edx
801015de:	89 d0                	mov    %edx,%eax
801015e0:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801015e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e6:	8d 50 07             	lea    0x7(%eax),%edx
801015e9:	85 c0                	test   %eax,%eax
801015eb:	0f 48 c2             	cmovs  %edx,%eax
801015ee:	c1 f8 03             	sar    $0x3,%eax
801015f1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015f4:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
801015f9:	0f b6 c0             	movzbl %al,%eax
801015fc:	23 45 e8             	and    -0x18(%ebp),%eax
801015ff:	85 c0                	test   %eax,%eax
80101601:	75 5d                	jne    80101660 <balloc+0xfe>
        bp->data[bi/8] |= m;  // Mark block in use.
80101603:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101606:	8d 50 07             	lea    0x7(%eax),%edx
80101609:	85 c0                	test   %eax,%eax
8010160b:	0f 48 c2             	cmovs  %edx,%eax
8010160e:	c1 f8 03             	sar    $0x3,%eax
80101611:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101614:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101619:	89 d1                	mov    %edx,%ecx
8010161b:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010161e:	09 ca                	or     %ecx,%edx
80101620:	89 d1                	mov    %edx,%ecx
80101622:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101625:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101629:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010162c:	89 04 24             	mov    %eax,(%esp)
8010162f:	e8 c1 21 00 00       	call   801037f5 <log_write>
        brelse(bp);
80101634:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101637:	89 04 24             	mov    %eax,(%esp)
8010163a:	e8 d8 eb ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
8010163f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101642:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101645:	01 c2                	add    %eax,%edx
80101647:	8b 45 08             	mov    0x8(%ebp),%eax
8010164a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010164e:	89 04 24             	mov    %eax,(%esp)
80101651:	e8 bb fe ff ff       	call   80101511 <bzero>
        return b + bi;
80101656:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101659:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010165c:	01 d0                	add    %edx,%eax
8010165e:	eb 4e                	jmp    801016ae <balloc+0x14c>

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101660:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101664:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010166b:	7f 15                	jg     80101682 <balloc+0x120>
8010166d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101670:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101673:	01 d0                	add    %edx,%eax
80101675:	89 c2                	mov    %eax,%edx
80101677:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010167a:	39 c2                	cmp    %eax,%edx
8010167c:	0f 82 45 ff ff ff    	jb     801015c7 <balloc+0x65>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101682:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101685:	89 04 24             	mov    %eax,(%esp)
80101688:	e8 8a eb ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
8010168d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101694:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101697:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010169a:	39 c2                	cmp    %eax,%edx
8010169c:	0f 82 eb fe ff ff    	jb     8010158d <balloc+0x2b>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801016a2:	c7 04 24 19 88 10 80 	movl   $0x80108819,(%esp)
801016a9:	e8 34 f0 ff ff       	call   801006e2 <panic>
}
801016ae:	c9                   	leave  
801016af:	c3                   	ret    

801016b0 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801016b0:	55                   	push   %ebp
801016b1:	89 e5                	mov    %esp,%ebp
801016b3:	83 ec 38             	sub    $0x38,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
801016b6:	8d 45 dc             	lea    -0x24(%ebp),%eax
801016b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801016bd:	8b 45 08             	mov    0x8(%ebp),%eax
801016c0:	89 04 24             	mov    %eax,(%esp)
801016c3:	e8 03 fe ff ff       	call   801014cb <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
801016c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801016cb:	c1 e8 0c             	shr    $0xc,%eax
801016ce:	89 c2                	mov    %eax,%edx
801016d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801016d3:	c1 e8 03             	shr    $0x3,%eax
801016d6:	01 d0                	add    %edx,%eax
801016d8:	8d 50 03             	lea    0x3(%eax),%edx
801016db:	8b 45 08             	mov    0x8(%ebp),%eax
801016de:	89 54 24 04          	mov    %edx,0x4(%esp)
801016e2:	89 04 24             	mov    %eax,(%esp)
801016e5:	e8 bc ea ff ff       	call   801001a6 <bread>
801016ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801016ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801016f0:	25 ff 0f 00 00       	and    $0xfff,%eax
801016f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801016f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016fb:	99                   	cltd   
801016fc:	c1 ea 1d             	shr    $0x1d,%edx
801016ff:	01 d0                	add    %edx,%eax
80101701:	83 e0 07             	and    $0x7,%eax
80101704:	29 d0                	sub    %edx,%eax
80101706:	ba 01 00 00 00       	mov    $0x1,%edx
8010170b:	89 c1                	mov    %eax,%ecx
8010170d:	d3 e2                	shl    %cl,%edx
8010170f:	89 d0                	mov    %edx,%eax
80101711:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101714:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101717:	8d 50 07             	lea    0x7(%eax),%edx
8010171a:	85 c0                	test   %eax,%eax
8010171c:	0f 48 c2             	cmovs  %edx,%eax
8010171f:	c1 f8 03             	sar    $0x3,%eax
80101722:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101725:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
8010172a:	0f b6 c0             	movzbl %al,%eax
8010172d:	23 45 ec             	and    -0x14(%ebp),%eax
80101730:	85 c0                	test   %eax,%eax
80101732:	75 0c                	jne    80101740 <bfree+0x90>
    panic("freeing free block");
80101734:	c7 04 24 2f 88 10 80 	movl   $0x8010882f,(%esp)
8010173b:	e8 a2 ef ff ff       	call   801006e2 <panic>
  bp->data[bi/8] &= ~m;
80101740:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101743:	8d 50 07             	lea    0x7(%eax),%edx
80101746:	85 c0                	test   %eax,%eax
80101748:	0f 48 c2             	cmovs  %edx,%eax
8010174b:	c1 f8 03             	sar    $0x3,%eax
8010174e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101751:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101756:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101759:	f7 d1                	not    %ecx
8010175b:	21 ca                	and    %ecx,%edx
8010175d:	89 d1                	mov    %edx,%ecx
8010175f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101762:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101766:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101769:	89 04 24             	mov    %eax,(%esp)
8010176c:	e8 84 20 00 00       	call   801037f5 <log_write>
  brelse(bp);
80101771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101774:	89 04 24             	mov    %eax,(%esp)
80101777:	e8 9b ea ff ff       	call   80100217 <brelse>
}
8010177c:	c9                   	leave  
8010177d:	c3                   	ret    

8010177e <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
8010177e:	55                   	push   %ebp
8010177f:	89 e5                	mov    %esp,%ebp
80101781:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
80101784:	c7 44 24 04 42 88 10 	movl   $0x80108842,0x4(%esp)
8010178b:	80 
8010178c:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101793:	e8 58 38 00 00       	call   80104ff0 <initlock>
}
80101798:	c9                   	leave  
80101799:	c3                   	ret    

8010179a <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
8010179a:	55                   	push   %ebp
8010179b:	89 e5                	mov    %esp,%ebp
8010179d:	83 ec 38             	sub    $0x38,%esp
801017a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801017a3:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
801017a7:	8b 45 08             	mov    0x8(%ebp),%eax
801017aa:	8d 55 dc             	lea    -0x24(%ebp),%edx
801017ad:	89 54 24 04          	mov    %edx,0x4(%esp)
801017b1:	89 04 24             	mov    %eax,(%esp)
801017b4:	e8 12 fd ff ff       	call   801014cb <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
801017b9:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801017c0:	e9 98 00 00 00       	jmp    8010185d <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
801017c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c8:	c1 e8 03             	shr    $0x3,%eax
801017cb:	83 c0 02             	add    $0x2,%eax
801017ce:	89 44 24 04          	mov    %eax,0x4(%esp)
801017d2:	8b 45 08             	mov    0x8(%ebp),%eax
801017d5:	89 04 24             	mov    %eax,(%esp)
801017d8:	e8 c9 e9 ff ff       	call   801001a6 <bread>
801017dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801017e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017e3:	8d 50 18             	lea    0x18(%eax),%edx
801017e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017e9:	83 e0 07             	and    $0x7,%eax
801017ec:	c1 e0 06             	shl    $0x6,%eax
801017ef:	01 d0                	add    %edx,%eax
801017f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801017f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017f7:	0f b7 00             	movzwl (%eax),%eax
801017fa:	66 85 c0             	test   %ax,%ax
801017fd:	75 4f                	jne    8010184e <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
801017ff:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101806:	00 
80101807:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010180e:	00 
8010180f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101812:	89 04 24             	mov    %eax,(%esp)
80101815:	e8 4b 3a 00 00       	call   80105265 <memset>
      dip->type = type;
8010181a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010181d:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
80101821:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101824:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101827:	89 04 24             	mov    %eax,(%esp)
8010182a:	e8 c6 1f 00 00       	call   801037f5 <log_write>
      brelse(bp);
8010182f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101832:	89 04 24             	mov    %eax,(%esp)
80101835:	e8 dd e9 ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
8010183a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183d:	89 44 24 04          	mov    %eax,0x4(%esp)
80101841:	8b 45 08             	mov    0x8(%ebp),%eax
80101844:	89 04 24             	mov    %eax,(%esp)
80101847:	e8 e5 00 00 00       	call   80101931 <iget>
8010184c:	eb 29                	jmp    80101877 <ialloc+0xdd>
    }
    brelse(bp);
8010184e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101851:	89 04 24             	mov    %eax,(%esp)
80101854:	e8 be e9 ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
80101859:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010185d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101860:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101863:	39 c2                	cmp    %eax,%edx
80101865:	0f 82 5a ff ff ff    	jb     801017c5 <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
8010186b:	c7 04 24 49 88 10 80 	movl   $0x80108849,(%esp)
80101872:	e8 6b ee ff ff       	call   801006e2 <panic>
}
80101877:	c9                   	leave  
80101878:	c3                   	ret    

80101879 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101879:	55                   	push   %ebp
8010187a:	89 e5                	mov    %esp,%ebp
8010187c:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
8010187f:	8b 45 08             	mov    0x8(%ebp),%eax
80101882:	8b 40 04             	mov    0x4(%eax),%eax
80101885:	c1 e8 03             	shr    $0x3,%eax
80101888:	8d 50 02             	lea    0x2(%eax),%edx
8010188b:	8b 45 08             	mov    0x8(%ebp),%eax
8010188e:	8b 00                	mov    (%eax),%eax
80101890:	89 54 24 04          	mov    %edx,0x4(%esp)
80101894:	89 04 24             	mov    %eax,(%esp)
80101897:	e8 0a e9 ff ff       	call   801001a6 <bread>
8010189c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010189f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a2:	8d 50 18             	lea    0x18(%eax),%edx
801018a5:	8b 45 08             	mov    0x8(%ebp),%eax
801018a8:	8b 40 04             	mov    0x4(%eax),%eax
801018ab:	83 e0 07             	and    $0x7,%eax
801018ae:	c1 e0 06             	shl    $0x6,%eax
801018b1:	01 d0                	add    %edx,%eax
801018b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801018b6:	8b 45 08             	mov    0x8(%ebp),%eax
801018b9:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801018bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018c0:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801018c3:	8b 45 08             	mov    0x8(%ebp),%eax
801018c6:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801018ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018cd:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801018d1:	8b 45 08             	mov    0x8(%ebp),%eax
801018d4:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801018d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018db:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801018df:	8b 45 08             	mov    0x8(%ebp),%eax
801018e2:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801018e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018e9:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801018ed:	8b 45 08             	mov    0x8(%ebp),%eax
801018f0:	8b 50 18             	mov    0x18(%eax),%edx
801018f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f6:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801018f9:	8b 45 08             	mov    0x8(%ebp),%eax
801018fc:	8d 50 1c             	lea    0x1c(%eax),%edx
801018ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101902:	83 c0 0c             	add    $0xc,%eax
80101905:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
8010190c:	00 
8010190d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101911:	89 04 24             	mov    %eax,(%esp)
80101914:	e8 1b 3a 00 00       	call   80105334 <memmove>
  log_write(bp);
80101919:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191c:	89 04 24             	mov    %eax,(%esp)
8010191f:	e8 d1 1e 00 00       	call   801037f5 <log_write>
  brelse(bp);
80101924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101927:	89 04 24             	mov    %eax,(%esp)
8010192a:	e8 e8 e8 ff ff       	call   80100217 <brelse>
}
8010192f:	c9                   	leave  
80101930:	c3                   	ret    

80101931 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101931:	55                   	push   %ebp
80101932:	89 e5                	mov    %esp,%ebp
80101934:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101937:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
8010193e:	e8 ce 36 00 00       	call   80105011 <acquire>

  // Is the inode already cached?
  empty = 0;
80101943:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010194a:	c7 45 f4 74 12 11 80 	movl   $0x80111274,-0xc(%ebp)
80101951:	eb 59                	jmp    801019ac <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101956:	8b 40 08             	mov    0x8(%eax),%eax
80101959:	85 c0                	test   %eax,%eax
8010195b:	7e 35                	jle    80101992 <iget+0x61>
8010195d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101960:	8b 00                	mov    (%eax),%eax
80101962:	3b 45 08             	cmp    0x8(%ebp),%eax
80101965:	75 2b                	jne    80101992 <iget+0x61>
80101967:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010196a:	8b 40 04             	mov    0x4(%eax),%eax
8010196d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101970:	75 20                	jne    80101992 <iget+0x61>
      ip->ref++;
80101972:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101975:	8b 40 08             	mov    0x8(%eax),%eax
80101978:	8d 50 01             	lea    0x1(%eax),%edx
8010197b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197e:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101981:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101988:	e8 e6 36 00 00       	call   80105073 <release>
      return ip;
8010198d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101990:	eb 6f                	jmp    80101a01 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101992:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101996:	75 10                	jne    801019a8 <iget+0x77>
80101998:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010199b:	8b 40 08             	mov    0x8(%eax),%eax
8010199e:	85 c0                	test   %eax,%eax
801019a0:	75 06                	jne    801019a8 <iget+0x77>
      empty = ip;
801019a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a5:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019a8:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801019ac:	81 7d f4 14 22 11 80 	cmpl   $0x80112214,-0xc(%ebp)
801019b3:	72 9e                	jb     80101953 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801019b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019b9:	75 0c                	jne    801019c7 <iget+0x96>
    panic("iget: no inodes");
801019bb:	c7 04 24 5b 88 10 80 	movl   $0x8010885b,(%esp)
801019c2:	e8 1b ed ff ff       	call   801006e2 <panic>

  ip = empty;
801019c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801019cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019d0:	8b 55 08             	mov    0x8(%ebp),%edx
801019d3:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801019d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019d8:	8b 55 0c             	mov    0xc(%ebp),%edx
801019db:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801019de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019e1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
801019e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019eb:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
801019f2:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801019f9:	e8 75 36 00 00       	call   80105073 <release>

  return ip;
801019fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a01:	c9                   	leave  
80101a02:	c3                   	ret    

80101a03 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a03:	55                   	push   %ebp
80101a04:	89 e5                	mov    %esp,%ebp
80101a06:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a09:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a10:	e8 fc 35 00 00       	call   80105011 <acquire>
  ip->ref++;
80101a15:	8b 45 08             	mov    0x8(%ebp),%eax
80101a18:	8b 40 08             	mov    0x8(%eax),%eax
80101a1b:	8d 50 01             	lea    0x1(%eax),%edx
80101a1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a21:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a24:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a2b:	e8 43 36 00 00       	call   80105073 <release>
  return ip;
80101a30:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a33:	c9                   	leave  
80101a34:	c3                   	ret    

80101a35 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a35:	55                   	push   %ebp
80101a36:	89 e5                	mov    %esp,%ebp
80101a38:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a3b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a3f:	74 0a                	je     80101a4b <ilock+0x16>
80101a41:	8b 45 08             	mov    0x8(%ebp),%eax
80101a44:	8b 40 08             	mov    0x8(%eax),%eax
80101a47:	85 c0                	test   %eax,%eax
80101a49:	7f 0c                	jg     80101a57 <ilock+0x22>
    panic("ilock");
80101a4b:	c7 04 24 6b 88 10 80 	movl   $0x8010886b,(%esp)
80101a52:	e8 8b ec ff ff       	call   801006e2 <panic>

  acquire(&icache.lock);
80101a57:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a5e:	e8 ae 35 00 00       	call   80105011 <acquire>
  while(ip->flags & I_BUSY)
80101a63:	eb 13                	jmp    80101a78 <ilock+0x43>
    sleep(ip, &icache.lock);
80101a65:	c7 44 24 04 40 12 11 	movl   $0x80111240,0x4(%esp)
80101a6c:	80 
80101a6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a70:	89 04 24             	mov    %eax,(%esp)
80101a73:	e8 cf 32 00 00       	call   80104d47 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101a78:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7b:	8b 40 0c             	mov    0xc(%eax),%eax
80101a7e:	83 e0 01             	and    $0x1,%eax
80101a81:	85 c0                	test   %eax,%eax
80101a83:	75 e0                	jne    80101a65 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101a85:	8b 45 08             	mov    0x8(%ebp),%eax
80101a88:	8b 40 0c             	mov    0xc(%eax),%eax
80101a8b:	83 c8 01             	or     $0x1,%eax
80101a8e:	89 c2                	mov    %eax,%edx
80101a90:	8b 45 08             	mov    0x8(%ebp),%eax
80101a93:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101a96:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a9d:	e8 d1 35 00 00       	call   80105073 <release>

  if(!(ip->flags & I_VALID)){
80101aa2:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa5:	8b 40 0c             	mov    0xc(%eax),%eax
80101aa8:	83 e0 02             	and    $0x2,%eax
80101aab:	85 c0                	test   %eax,%eax
80101aad:	0f 85 ce 00 00 00    	jne    80101b81 <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
80101ab3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab6:	8b 40 04             	mov    0x4(%eax),%eax
80101ab9:	c1 e8 03             	shr    $0x3,%eax
80101abc:	8d 50 02             	lea    0x2(%eax),%edx
80101abf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac2:	8b 00                	mov    (%eax),%eax
80101ac4:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ac8:	89 04 24             	mov    %eax,(%esp)
80101acb:	e8 d6 e6 ff ff       	call   801001a6 <bread>
80101ad0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ad6:	8d 50 18             	lea    0x18(%eax),%edx
80101ad9:	8b 45 08             	mov    0x8(%ebp),%eax
80101adc:	8b 40 04             	mov    0x4(%eax),%eax
80101adf:	83 e0 07             	and    $0x7,%eax
80101ae2:	c1 e0 06             	shl    $0x6,%eax
80101ae5:	01 d0                	add    %edx,%eax
80101ae7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101aea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aed:	0f b7 10             	movzwl (%eax),%edx
80101af0:	8b 45 08             	mov    0x8(%ebp),%eax
80101af3:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101af7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101afa:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101afe:	8b 45 08             	mov    0x8(%ebp),%eax
80101b01:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101b05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b08:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101b0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0f:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101b13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b16:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1d:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101b21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b24:	8b 50 08             	mov    0x8(%eax),%edx
80101b27:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2a:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b30:	8d 50 0c             	lea    0xc(%eax),%edx
80101b33:	8b 45 08             	mov    0x8(%ebp),%eax
80101b36:	83 c0 1c             	add    $0x1c,%eax
80101b39:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101b40:	00 
80101b41:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b45:	89 04 24             	mov    %eax,(%esp)
80101b48:	e8 e7 37 00 00       	call   80105334 <memmove>
    brelse(bp);
80101b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b50:	89 04 24             	mov    %eax,(%esp)
80101b53:	e8 bf e6 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
80101b58:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5b:	8b 40 0c             	mov    0xc(%eax),%eax
80101b5e:	83 c8 02             	or     $0x2,%eax
80101b61:	89 c2                	mov    %eax,%edx
80101b63:	8b 45 08             	mov    0x8(%ebp),%eax
80101b66:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101b69:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101b70:	66 85 c0             	test   %ax,%ax
80101b73:	75 0c                	jne    80101b81 <ilock+0x14c>
      panic("ilock: no type");
80101b75:	c7 04 24 71 88 10 80 	movl   $0x80108871,(%esp)
80101b7c:	e8 61 eb ff ff       	call   801006e2 <panic>
  }
}
80101b81:	c9                   	leave  
80101b82:	c3                   	ret    

80101b83 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b83:	55                   	push   %ebp
80101b84:	89 e5                	mov    %esp,%ebp
80101b86:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101b89:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b8d:	74 17                	je     80101ba6 <iunlock+0x23>
80101b8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b92:	8b 40 0c             	mov    0xc(%eax),%eax
80101b95:	83 e0 01             	and    $0x1,%eax
80101b98:	85 c0                	test   %eax,%eax
80101b9a:	74 0a                	je     80101ba6 <iunlock+0x23>
80101b9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9f:	8b 40 08             	mov    0x8(%eax),%eax
80101ba2:	85 c0                	test   %eax,%eax
80101ba4:	7f 0c                	jg     80101bb2 <iunlock+0x2f>
    panic("iunlock");
80101ba6:	c7 04 24 80 88 10 80 	movl   $0x80108880,(%esp)
80101bad:	e8 30 eb ff ff       	call   801006e2 <panic>

  acquire(&icache.lock);
80101bb2:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101bb9:	e8 53 34 00 00       	call   80105011 <acquire>
  ip->flags &= ~I_BUSY;
80101bbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc1:	8b 40 0c             	mov    0xc(%eax),%eax
80101bc4:	83 e0 fe             	and    $0xfffffffe,%eax
80101bc7:	89 c2                	mov    %eax,%edx
80101bc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcc:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101bcf:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd2:	89 04 24             	mov    %eax,(%esp)
80101bd5:	e8 46 32 00 00       	call   80104e20 <wakeup>
  release(&icache.lock);
80101bda:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101be1:	e8 8d 34 00 00       	call   80105073 <release>
}
80101be6:	c9                   	leave  
80101be7:	c3                   	ret    

80101be8 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101be8:	55                   	push   %ebp
80101be9:	89 e5                	mov    %esp,%ebp
80101beb:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101bee:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101bf5:	e8 17 34 00 00       	call   80105011 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101bfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfd:	8b 40 08             	mov    0x8(%eax),%eax
80101c00:	83 f8 01             	cmp    $0x1,%eax
80101c03:	0f 85 93 00 00 00    	jne    80101c9c <iput+0xb4>
80101c09:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0c:	8b 40 0c             	mov    0xc(%eax),%eax
80101c0f:	83 e0 02             	and    $0x2,%eax
80101c12:	85 c0                	test   %eax,%eax
80101c14:	0f 84 82 00 00 00    	je     80101c9c <iput+0xb4>
80101c1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101c21:	66 85 c0             	test   %ax,%ax
80101c24:	75 76                	jne    80101c9c <iput+0xb4>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101c26:	8b 45 08             	mov    0x8(%ebp),%eax
80101c29:	8b 40 0c             	mov    0xc(%eax),%eax
80101c2c:	83 e0 01             	and    $0x1,%eax
80101c2f:	85 c0                	test   %eax,%eax
80101c31:	74 0c                	je     80101c3f <iput+0x57>
      panic("iput busy");
80101c33:	c7 04 24 88 88 10 80 	movl   $0x80108888,(%esp)
80101c3a:	e8 a3 ea ff ff       	call   801006e2 <panic>
    ip->flags |= I_BUSY;
80101c3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c42:	8b 40 0c             	mov    0xc(%eax),%eax
80101c45:	83 c8 01             	or     $0x1,%eax
80101c48:	89 c2                	mov    %eax,%edx
80101c4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4d:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101c50:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101c57:	e8 17 34 00 00       	call   80105073 <release>
    itrunc(ip);
80101c5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5f:	89 04 24             	mov    %eax,(%esp)
80101c62:	e8 7d 01 00 00       	call   80101de4 <itrunc>
    ip->type = 0;
80101c67:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6a:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101c70:	8b 45 08             	mov    0x8(%ebp),%eax
80101c73:	89 04 24             	mov    %eax,(%esp)
80101c76:	e8 fe fb ff ff       	call   80101879 <iupdate>
    acquire(&icache.lock);
80101c7b:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101c82:	e8 8a 33 00 00       	call   80105011 <acquire>
    ip->flags = 0;
80101c87:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101c91:	8b 45 08             	mov    0x8(%ebp),%eax
80101c94:	89 04 24             	mov    %eax,(%esp)
80101c97:	e8 84 31 00 00       	call   80104e20 <wakeup>
  }
  ip->ref--;
80101c9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9f:	8b 40 08             	mov    0x8(%eax),%eax
80101ca2:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ca5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca8:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101cab:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101cb2:	e8 bc 33 00 00       	call   80105073 <release>
}
80101cb7:	c9                   	leave  
80101cb8:	c3                   	ret    

80101cb9 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101cb9:	55                   	push   %ebp
80101cba:	89 e5                	mov    %esp,%ebp
80101cbc:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101cbf:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc2:	89 04 24             	mov    %eax,(%esp)
80101cc5:	e8 b9 fe ff ff       	call   80101b83 <iunlock>
  iput(ip);
80101cca:	8b 45 08             	mov    0x8(%ebp),%eax
80101ccd:	89 04 24             	mov    %eax,(%esp)
80101cd0:	e8 13 ff ff ff       	call   80101be8 <iput>
}
80101cd5:	c9                   	leave  
80101cd6:	c3                   	ret    

80101cd7 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101cd7:	55                   	push   %ebp
80101cd8:	89 e5                	mov    %esp,%ebp
80101cda:	53                   	push   %ebx
80101cdb:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101cde:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101ce2:	77 3e                	ja     80101d22 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101ce4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce7:	8b 55 0c             	mov    0xc(%ebp),%edx
80101cea:	83 c2 04             	add    $0x4,%edx
80101ced:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101cf1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cf4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cf8:	75 20                	jne    80101d1a <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101cfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfd:	8b 00                	mov    (%eax),%eax
80101cff:	89 04 24             	mov    %eax,(%esp)
80101d02:	e8 5b f8 ff ff       	call   80101562 <balloc>
80101d07:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d10:	8d 4a 04             	lea    0x4(%edx),%ecx
80101d13:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d16:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d1d:	e9 bc 00 00 00       	jmp    80101dde <bmap+0x107>
  }
  bn -= NDIRECT;
80101d22:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d26:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d2a:	0f 87 a2 00 00 00    	ja     80101dd2 <bmap+0xfb>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d30:	8b 45 08             	mov    0x8(%ebp),%eax
80101d33:	8b 40 4c             	mov    0x4c(%eax),%eax
80101d36:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d39:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d3d:	75 19                	jne    80101d58 <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d42:	8b 00                	mov    (%eax),%eax
80101d44:	89 04 24             	mov    %eax,(%esp)
80101d47:	e8 16 f8 ff ff       	call   80101562 <balloc>
80101d4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d52:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d55:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101d58:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5b:	8b 00                	mov    (%eax),%eax
80101d5d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d60:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d64:	89 04 24             	mov    %eax,(%esp)
80101d67:	e8 3a e4 ff ff       	call   801001a6 <bread>
80101d6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d72:	83 c0 18             	add    $0x18,%eax
80101d75:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d78:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d7b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d82:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d85:	01 d0                	add    %edx,%eax
80101d87:	8b 00                	mov    (%eax),%eax
80101d89:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d8c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d90:	75 30                	jne    80101dc2 <bmap+0xeb>
      a[bn] = addr = balloc(ip->dev);
80101d92:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d95:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d9f:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101da2:	8b 45 08             	mov    0x8(%ebp),%eax
80101da5:	8b 00                	mov    (%eax),%eax
80101da7:	89 04 24             	mov    %eax,(%esp)
80101daa:	e8 b3 f7 ff ff       	call   80101562 <balloc>
80101daf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101db5:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101db7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dba:	89 04 24             	mov    %eax,(%esp)
80101dbd:	e8 33 1a 00 00       	call   801037f5 <log_write>
    }
    brelse(bp);
80101dc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dc5:	89 04 24             	mov    %eax,(%esp)
80101dc8:	e8 4a e4 ff ff       	call   80100217 <brelse>
    return addr;
80101dcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dd0:	eb 0c                	jmp    80101dde <bmap+0x107>
  }

  panic("bmap: out of range");
80101dd2:	c7 04 24 92 88 10 80 	movl   $0x80108892,(%esp)
80101dd9:	e8 04 e9 ff ff       	call   801006e2 <panic>
}
80101dde:	83 c4 24             	add    $0x24,%esp
80101de1:	5b                   	pop    %ebx
80101de2:	5d                   	pop    %ebp
80101de3:	c3                   	ret    

80101de4 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101de4:	55                   	push   %ebp
80101de5:	89 e5                	mov    %esp,%ebp
80101de7:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101dea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101df1:	eb 44                	jmp    80101e37 <itrunc+0x53>
    if(ip->addrs[i]){
80101df3:	8b 45 08             	mov    0x8(%ebp),%eax
80101df6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101df9:	83 c2 04             	add    $0x4,%edx
80101dfc:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e00:	85 c0                	test   %eax,%eax
80101e02:	74 2f                	je     80101e33 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101e04:	8b 45 08             	mov    0x8(%ebp),%eax
80101e07:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e0a:	83 c2 04             	add    $0x4,%edx
80101e0d:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101e11:	8b 45 08             	mov    0x8(%ebp),%eax
80101e14:	8b 00                	mov    (%eax),%eax
80101e16:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e1a:	89 04 24             	mov    %eax,(%esp)
80101e1d:	e8 8e f8 ff ff       	call   801016b0 <bfree>
      ip->addrs[i] = 0;
80101e22:	8b 45 08             	mov    0x8(%ebp),%eax
80101e25:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e28:	83 c2 04             	add    $0x4,%edx
80101e2b:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e32:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e33:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101e37:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e3b:	7e b6                	jle    80101df3 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101e3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e40:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e43:	85 c0                	test   %eax,%eax
80101e45:	0f 84 9b 00 00 00    	je     80101ee6 <itrunc+0x102>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4e:	8b 50 4c             	mov    0x4c(%eax),%edx
80101e51:	8b 45 08             	mov    0x8(%ebp),%eax
80101e54:	8b 00                	mov    (%eax),%eax
80101e56:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e5a:	89 04 24             	mov    %eax,(%esp)
80101e5d:	e8 44 e3 ff ff       	call   801001a6 <bread>
80101e62:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e65:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e68:	83 c0 18             	add    $0x18,%eax
80101e6b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e6e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e75:	eb 3b                	jmp    80101eb2 <itrunc+0xce>
      if(a[j])
80101e77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e7a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e81:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e84:	01 d0                	add    %edx,%eax
80101e86:	8b 00                	mov    (%eax),%eax
80101e88:	85 c0                	test   %eax,%eax
80101e8a:	74 22                	je     80101eae <itrunc+0xca>
        bfree(ip->dev, a[j]);
80101e8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e8f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e96:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e99:	01 d0                	add    %edx,%eax
80101e9b:	8b 10                	mov    (%eax),%edx
80101e9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea0:	8b 00                	mov    (%eax),%eax
80101ea2:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ea6:	89 04 24             	mov    %eax,(%esp)
80101ea9:	e8 02 f8 ff ff       	call   801016b0 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101eae:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101eb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101eb5:	83 f8 7f             	cmp    $0x7f,%eax
80101eb8:	76 bd                	jbe    80101e77 <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101eba:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ebd:	89 04 24             	mov    %eax,(%esp)
80101ec0:	e8 52 e3 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ec5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec8:	8b 50 4c             	mov    0x4c(%eax),%edx
80101ecb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ece:	8b 00                	mov    (%eax),%eax
80101ed0:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ed4:	89 04 24             	mov    %eax,(%esp)
80101ed7:	e8 d4 f7 ff ff       	call   801016b0 <bfree>
    ip->addrs[NDIRECT] = 0;
80101edc:	8b 45 08             	mov    0x8(%ebp),%eax
80101edf:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101ee6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee9:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101ef0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef3:	89 04 24             	mov    %eax,(%esp)
80101ef6:	e8 7e f9 ff ff       	call   80101879 <iupdate>
}
80101efb:	c9                   	leave  
80101efc:	c3                   	ret    

80101efd <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101efd:	55                   	push   %ebp
80101efe:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f00:	8b 45 08             	mov    0x8(%ebp),%eax
80101f03:	8b 00                	mov    (%eax),%eax
80101f05:	89 c2                	mov    %eax,%edx
80101f07:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f0a:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f10:	8b 50 04             	mov    0x4(%eax),%edx
80101f13:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f16:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f19:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1c:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101f20:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f23:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101f26:	8b 45 08             	mov    0x8(%ebp),%eax
80101f29:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101f2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f30:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101f34:	8b 45 08             	mov    0x8(%ebp),%eax
80101f37:	8b 50 18             	mov    0x18(%eax),%edx
80101f3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f3d:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f40:	5d                   	pop    %ebp
80101f41:	c3                   	ret    

80101f42 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f42:	55                   	push   %ebp
80101f43:	89 e5                	mov    %esp,%ebp
80101f45:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f48:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101f4f:	66 83 f8 03          	cmp    $0x3,%ax
80101f53:	75 60                	jne    80101fb5 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f55:	8b 45 08             	mov    0x8(%ebp),%eax
80101f58:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f5c:	66 85 c0             	test   %ax,%ax
80101f5f:	78 20                	js     80101f81 <readi+0x3f>
80101f61:	8b 45 08             	mov    0x8(%ebp),%eax
80101f64:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f68:	66 83 f8 09          	cmp    $0x9,%ax
80101f6c:	7f 13                	jg     80101f81 <readi+0x3f>
80101f6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f71:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f75:	98                   	cwtl   
80101f76:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
80101f7d:	85 c0                	test   %eax,%eax
80101f7f:	75 0a                	jne    80101f8b <readi+0x49>
      return -1;
80101f81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f86:	e9 19 01 00 00       	jmp    801020a4 <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101f8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f92:	98                   	cwtl   
80101f93:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
80101f9a:	8b 55 14             	mov    0x14(%ebp),%edx
80101f9d:	89 54 24 08          	mov    %edx,0x8(%esp)
80101fa1:	8b 55 0c             	mov    0xc(%ebp),%edx
80101fa4:	89 54 24 04          	mov    %edx,0x4(%esp)
80101fa8:	8b 55 08             	mov    0x8(%ebp),%edx
80101fab:	89 14 24             	mov    %edx,(%esp)
80101fae:	ff d0                	call   *%eax
80101fb0:	e9 ef 00 00 00       	jmp    801020a4 <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101fb5:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb8:	8b 40 18             	mov    0x18(%eax),%eax
80101fbb:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fbe:	72 0d                	jb     80101fcd <readi+0x8b>
80101fc0:	8b 45 14             	mov    0x14(%ebp),%eax
80101fc3:	8b 55 10             	mov    0x10(%ebp),%edx
80101fc6:	01 d0                	add    %edx,%eax
80101fc8:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fcb:	73 0a                	jae    80101fd7 <readi+0x95>
    return -1;
80101fcd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fd2:	e9 cd 00 00 00       	jmp    801020a4 <readi+0x162>
  if(off + n > ip->size)
80101fd7:	8b 45 14             	mov    0x14(%ebp),%eax
80101fda:	8b 55 10             	mov    0x10(%ebp),%edx
80101fdd:	01 c2                	add    %eax,%edx
80101fdf:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe2:	8b 40 18             	mov    0x18(%eax),%eax
80101fe5:	39 c2                	cmp    %eax,%edx
80101fe7:	76 0c                	jbe    80101ff5 <readi+0xb3>
    n = ip->size - off;
80101fe9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fec:	8b 40 18             	mov    0x18(%eax),%eax
80101fef:	2b 45 10             	sub    0x10(%ebp),%eax
80101ff2:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ff5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ffc:	e9 94 00 00 00       	jmp    80102095 <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102001:	8b 45 10             	mov    0x10(%ebp),%eax
80102004:	c1 e8 09             	shr    $0x9,%eax
80102007:	89 44 24 04          	mov    %eax,0x4(%esp)
8010200b:	8b 45 08             	mov    0x8(%ebp),%eax
8010200e:	89 04 24             	mov    %eax,(%esp)
80102011:	e8 c1 fc ff ff       	call   80101cd7 <bmap>
80102016:	8b 55 08             	mov    0x8(%ebp),%edx
80102019:	8b 12                	mov    (%edx),%edx
8010201b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010201f:	89 14 24             	mov    %edx,(%esp)
80102022:	e8 7f e1 ff ff       	call   801001a6 <bread>
80102027:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010202a:	8b 45 10             	mov    0x10(%ebp),%eax
8010202d:	25 ff 01 00 00       	and    $0x1ff,%eax
80102032:	89 c2                	mov    %eax,%edx
80102034:	b8 00 02 00 00       	mov    $0x200,%eax
80102039:	29 d0                	sub    %edx,%eax
8010203b:	89 c2                	mov    %eax,%edx
8010203d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102040:	8b 4d 14             	mov    0x14(%ebp),%ecx
80102043:	29 c1                	sub    %eax,%ecx
80102045:	89 c8                	mov    %ecx,%eax
80102047:	39 c2                	cmp    %eax,%edx
80102049:	0f 46 c2             	cmovbe %edx,%eax
8010204c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
8010204f:	8b 45 10             	mov    0x10(%ebp),%eax
80102052:	25 ff 01 00 00       	and    $0x1ff,%eax
80102057:	8d 50 10             	lea    0x10(%eax),%edx
8010205a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010205d:	01 d0                	add    %edx,%eax
8010205f:	8d 50 08             	lea    0x8(%eax),%edx
80102062:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102065:	89 44 24 08          	mov    %eax,0x8(%esp)
80102069:	89 54 24 04          	mov    %edx,0x4(%esp)
8010206d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102070:	89 04 24             	mov    %eax,(%esp)
80102073:	e8 bc 32 00 00       	call   80105334 <memmove>
    brelse(bp);
80102078:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010207b:	89 04 24             	mov    %eax,(%esp)
8010207e:	e8 94 e1 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102083:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102086:	01 45 f4             	add    %eax,-0xc(%ebp)
80102089:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010208c:	01 45 10             	add    %eax,0x10(%ebp)
8010208f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102092:	01 45 0c             	add    %eax,0xc(%ebp)
80102095:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102098:	3b 45 14             	cmp    0x14(%ebp),%eax
8010209b:	0f 82 60 ff ff ff    	jb     80102001 <readi+0xbf>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
801020a1:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020a4:	c9                   	leave  
801020a5:	c3                   	ret    

801020a6 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801020a6:	55                   	push   %ebp
801020a7:	89 e5                	mov    %esp,%ebp
801020a9:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020ac:	8b 45 08             	mov    0x8(%ebp),%eax
801020af:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801020b3:	66 83 f8 03          	cmp    $0x3,%ax
801020b7:	75 60                	jne    80102119 <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801020b9:	8b 45 08             	mov    0x8(%ebp),%eax
801020bc:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020c0:	66 85 c0             	test   %ax,%ax
801020c3:	78 20                	js     801020e5 <writei+0x3f>
801020c5:	8b 45 08             	mov    0x8(%ebp),%eax
801020c8:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020cc:	66 83 f8 09          	cmp    $0x9,%ax
801020d0:	7f 13                	jg     801020e5 <writei+0x3f>
801020d2:	8b 45 08             	mov    0x8(%ebp),%eax
801020d5:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020d9:	98                   	cwtl   
801020da:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
801020e1:	85 c0                	test   %eax,%eax
801020e3:	75 0a                	jne    801020ef <writei+0x49>
      return -1;
801020e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020ea:	e9 44 01 00 00       	jmp    80102233 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
801020ef:	8b 45 08             	mov    0x8(%ebp),%eax
801020f2:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020f6:	98                   	cwtl   
801020f7:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
801020fe:	8b 55 14             	mov    0x14(%ebp),%edx
80102101:	89 54 24 08          	mov    %edx,0x8(%esp)
80102105:	8b 55 0c             	mov    0xc(%ebp),%edx
80102108:	89 54 24 04          	mov    %edx,0x4(%esp)
8010210c:	8b 55 08             	mov    0x8(%ebp),%edx
8010210f:	89 14 24             	mov    %edx,(%esp)
80102112:	ff d0                	call   *%eax
80102114:	e9 1a 01 00 00       	jmp    80102233 <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
80102119:	8b 45 08             	mov    0x8(%ebp),%eax
8010211c:	8b 40 18             	mov    0x18(%eax),%eax
8010211f:	3b 45 10             	cmp    0x10(%ebp),%eax
80102122:	72 0d                	jb     80102131 <writei+0x8b>
80102124:	8b 45 14             	mov    0x14(%ebp),%eax
80102127:	8b 55 10             	mov    0x10(%ebp),%edx
8010212a:	01 d0                	add    %edx,%eax
8010212c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010212f:	73 0a                	jae    8010213b <writei+0x95>
    return -1;
80102131:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102136:	e9 f8 00 00 00       	jmp    80102233 <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
8010213b:	8b 45 14             	mov    0x14(%ebp),%eax
8010213e:	8b 55 10             	mov    0x10(%ebp),%edx
80102141:	01 d0                	add    %edx,%eax
80102143:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102148:	76 0a                	jbe    80102154 <writei+0xae>
    return -1;
8010214a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010214f:	e9 df 00 00 00       	jmp    80102233 <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102154:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010215b:	e9 9f 00 00 00       	jmp    801021ff <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102160:	8b 45 10             	mov    0x10(%ebp),%eax
80102163:	c1 e8 09             	shr    $0x9,%eax
80102166:	89 44 24 04          	mov    %eax,0x4(%esp)
8010216a:	8b 45 08             	mov    0x8(%ebp),%eax
8010216d:	89 04 24             	mov    %eax,(%esp)
80102170:	e8 62 fb ff ff       	call   80101cd7 <bmap>
80102175:	8b 55 08             	mov    0x8(%ebp),%edx
80102178:	8b 12                	mov    (%edx),%edx
8010217a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010217e:	89 14 24             	mov    %edx,(%esp)
80102181:	e8 20 e0 ff ff       	call   801001a6 <bread>
80102186:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102189:	8b 45 10             	mov    0x10(%ebp),%eax
8010218c:	25 ff 01 00 00       	and    $0x1ff,%eax
80102191:	89 c2                	mov    %eax,%edx
80102193:	b8 00 02 00 00       	mov    $0x200,%eax
80102198:	29 d0                	sub    %edx,%eax
8010219a:	89 c2                	mov    %eax,%edx
8010219c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010219f:	8b 4d 14             	mov    0x14(%ebp),%ecx
801021a2:	29 c1                	sub    %eax,%ecx
801021a4:	89 c8                	mov    %ecx,%eax
801021a6:	39 c2                	cmp    %eax,%edx
801021a8:	0f 46 c2             	cmovbe %edx,%eax
801021ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801021ae:	8b 45 10             	mov    0x10(%ebp),%eax
801021b1:	25 ff 01 00 00       	and    $0x1ff,%eax
801021b6:	8d 50 10             	lea    0x10(%eax),%edx
801021b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021bc:	01 d0                	add    %edx,%eax
801021be:	8d 50 08             	lea    0x8(%eax),%edx
801021c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021c4:	89 44 24 08          	mov    %eax,0x8(%esp)
801021c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801021cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801021cf:	89 14 24             	mov    %edx,(%esp)
801021d2:	e8 5d 31 00 00       	call   80105334 <memmove>
    log_write(bp);
801021d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021da:	89 04 24             	mov    %eax,(%esp)
801021dd:	e8 13 16 00 00       	call   801037f5 <log_write>
    brelse(bp);
801021e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021e5:	89 04 24             	mov    %eax,(%esp)
801021e8:	e8 2a e0 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801021ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021f0:	01 45 f4             	add    %eax,-0xc(%ebp)
801021f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021f6:	01 45 10             	add    %eax,0x10(%ebp)
801021f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021fc:	01 45 0c             	add    %eax,0xc(%ebp)
801021ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102202:	3b 45 14             	cmp    0x14(%ebp),%eax
80102205:	0f 82 55 ff ff ff    	jb     80102160 <writei+0xba>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010220b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010220f:	74 1f                	je     80102230 <writei+0x18a>
80102211:	8b 45 08             	mov    0x8(%ebp),%eax
80102214:	8b 40 18             	mov    0x18(%eax),%eax
80102217:	3b 45 10             	cmp    0x10(%ebp),%eax
8010221a:	73 14                	jae    80102230 <writei+0x18a>
    ip->size = off;
8010221c:	8b 45 08             	mov    0x8(%ebp),%eax
8010221f:	8b 55 10             	mov    0x10(%ebp),%edx
80102222:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102225:	8b 45 08             	mov    0x8(%ebp),%eax
80102228:	89 04 24             	mov    %eax,(%esp)
8010222b:	e8 49 f6 ff ff       	call   80101879 <iupdate>
  }
  return n;
80102230:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102233:	c9                   	leave  
80102234:	c3                   	ret    

80102235 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102235:	55                   	push   %ebp
80102236:	89 e5                	mov    %esp,%ebp
80102238:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
8010223b:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102242:	00 
80102243:	8b 45 0c             	mov    0xc(%ebp),%eax
80102246:	89 44 24 04          	mov    %eax,0x4(%esp)
8010224a:	8b 45 08             	mov    0x8(%ebp),%eax
8010224d:	89 04 24             	mov    %eax,(%esp)
80102250:	e8 82 31 00 00       	call   801053d7 <strncmp>
}
80102255:	c9                   	leave  
80102256:	c3                   	ret    

80102257 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102257:	55                   	push   %ebp
80102258:	89 e5                	mov    %esp,%ebp
8010225a:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010225d:	8b 45 08             	mov    0x8(%ebp),%eax
80102260:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102264:	66 83 f8 01          	cmp    $0x1,%ax
80102268:	74 0c                	je     80102276 <dirlookup+0x1f>
    panic("dirlookup not DIR");
8010226a:	c7 04 24 a5 88 10 80 	movl   $0x801088a5,(%esp)
80102271:	e8 6c e4 ff ff       	call   801006e2 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102276:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010227d:	e9 88 00 00 00       	jmp    8010230a <dirlookup+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102282:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102289:	00 
8010228a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010228d:	89 44 24 08          	mov    %eax,0x8(%esp)
80102291:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102294:	89 44 24 04          	mov    %eax,0x4(%esp)
80102298:	8b 45 08             	mov    0x8(%ebp),%eax
8010229b:	89 04 24             	mov    %eax,(%esp)
8010229e:	e8 9f fc ff ff       	call   80101f42 <readi>
801022a3:	83 f8 10             	cmp    $0x10,%eax
801022a6:	74 0c                	je     801022b4 <dirlookup+0x5d>
      panic("dirlink read");
801022a8:	c7 04 24 b7 88 10 80 	movl   $0x801088b7,(%esp)
801022af:	e8 2e e4 ff ff       	call   801006e2 <panic>
    if(de.inum == 0)
801022b4:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022b8:	66 85 c0             	test   %ax,%ax
801022bb:	75 02                	jne    801022bf <dirlookup+0x68>
      continue;
801022bd:	eb 47                	jmp    80102306 <dirlookup+0xaf>
    if(namecmp(name, de.name) == 0){
801022bf:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022c2:	83 c0 02             	add    $0x2,%eax
801022c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801022c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801022cc:	89 04 24             	mov    %eax,(%esp)
801022cf:	e8 61 ff ff ff       	call   80102235 <namecmp>
801022d4:	85 c0                	test   %eax,%eax
801022d6:	75 2e                	jne    80102306 <dirlookup+0xaf>
      // entry matches path element
      if(poff)
801022d8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801022dc:	74 08                	je     801022e6 <dirlookup+0x8f>
        *poff = off;
801022de:	8b 45 10             	mov    0x10(%ebp),%eax
801022e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022e4:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801022e6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022ea:	0f b7 c0             	movzwl %ax,%eax
801022ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801022f0:	8b 45 08             	mov    0x8(%ebp),%eax
801022f3:	8b 00                	mov    (%eax),%eax
801022f5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801022f8:	89 54 24 04          	mov    %edx,0x4(%esp)
801022fc:	89 04 24             	mov    %eax,(%esp)
801022ff:	e8 2d f6 ff ff       	call   80101931 <iget>
80102304:	eb 18                	jmp    8010231e <dirlookup+0xc7>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102306:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010230a:	8b 45 08             	mov    0x8(%ebp),%eax
8010230d:	8b 40 18             	mov    0x18(%eax),%eax
80102310:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102313:	0f 87 69 ff ff ff    	ja     80102282 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102319:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010231e:	c9                   	leave  
8010231f:	c3                   	ret    

80102320 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102320:	55                   	push   %ebp
80102321:	89 e5                	mov    %esp,%ebp
80102323:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102326:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010232d:	00 
8010232e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102331:	89 44 24 04          	mov    %eax,0x4(%esp)
80102335:	8b 45 08             	mov    0x8(%ebp),%eax
80102338:	89 04 24             	mov    %eax,(%esp)
8010233b:	e8 17 ff ff ff       	call   80102257 <dirlookup>
80102340:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102343:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102347:	74 15                	je     8010235e <dirlink+0x3e>
    iput(ip);
80102349:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010234c:	89 04 24             	mov    %eax,(%esp)
8010234f:	e8 94 f8 ff ff       	call   80101be8 <iput>
    return -1;
80102354:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102359:	e9 b7 00 00 00       	jmp    80102415 <dirlink+0xf5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010235e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102365:	eb 46                	jmp    801023ad <dirlink+0x8d>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010236a:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102371:	00 
80102372:	89 44 24 08          	mov    %eax,0x8(%esp)
80102376:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102379:	89 44 24 04          	mov    %eax,0x4(%esp)
8010237d:	8b 45 08             	mov    0x8(%ebp),%eax
80102380:	89 04 24             	mov    %eax,(%esp)
80102383:	e8 ba fb ff ff       	call   80101f42 <readi>
80102388:	83 f8 10             	cmp    $0x10,%eax
8010238b:	74 0c                	je     80102399 <dirlink+0x79>
      panic("dirlink read");
8010238d:	c7 04 24 b7 88 10 80 	movl   $0x801088b7,(%esp)
80102394:	e8 49 e3 ff ff       	call   801006e2 <panic>
    if(de.inum == 0)
80102399:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010239d:	66 85 c0             	test   %ax,%ax
801023a0:	75 02                	jne    801023a4 <dirlink+0x84>
      break;
801023a2:	eb 16                	jmp    801023ba <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801023a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023a7:	83 c0 10             	add    $0x10,%eax
801023aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801023b0:	8b 45 08             	mov    0x8(%ebp),%eax
801023b3:	8b 40 18             	mov    0x18(%eax),%eax
801023b6:	39 c2                	cmp    %eax,%edx
801023b8:	72 ad                	jb     80102367 <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
801023ba:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801023c1:	00 
801023c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801023c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801023c9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023cc:	83 c0 02             	add    $0x2,%eax
801023cf:	89 04 24             	mov    %eax,(%esp)
801023d2:	e8 56 30 00 00       	call   8010542d <strncpy>
  de.inum = inum;
801023d7:	8b 45 10             	mov    0x10(%ebp),%eax
801023da:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023e1:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801023e8:	00 
801023e9:	89 44 24 08          	mov    %eax,0x8(%esp)
801023ed:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801023f4:	8b 45 08             	mov    0x8(%ebp),%eax
801023f7:	89 04 24             	mov    %eax,(%esp)
801023fa:	e8 a7 fc ff ff       	call   801020a6 <writei>
801023ff:	83 f8 10             	cmp    $0x10,%eax
80102402:	74 0c                	je     80102410 <dirlink+0xf0>
    panic("dirlink");
80102404:	c7 04 24 c4 88 10 80 	movl   $0x801088c4,(%esp)
8010240b:	e8 d2 e2 ff ff       	call   801006e2 <panic>
  
  return 0;
80102410:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102415:	c9                   	leave  
80102416:	c3                   	ret    

80102417 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102417:	55                   	push   %ebp
80102418:	89 e5                	mov    %esp,%ebp
8010241a:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
8010241d:	eb 04                	jmp    80102423 <skipelem+0xc>
    path++;
8010241f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102423:	8b 45 08             	mov    0x8(%ebp),%eax
80102426:	0f b6 00             	movzbl (%eax),%eax
80102429:	3c 2f                	cmp    $0x2f,%al
8010242b:	74 f2                	je     8010241f <skipelem+0x8>
    path++;
  if(*path == 0)
8010242d:	8b 45 08             	mov    0x8(%ebp),%eax
80102430:	0f b6 00             	movzbl (%eax),%eax
80102433:	84 c0                	test   %al,%al
80102435:	75 0a                	jne    80102441 <skipelem+0x2a>
    return 0;
80102437:	b8 00 00 00 00       	mov    $0x0,%eax
8010243c:	e9 86 00 00 00       	jmp    801024c7 <skipelem+0xb0>
  s = path;
80102441:	8b 45 08             	mov    0x8(%ebp),%eax
80102444:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102447:	eb 04                	jmp    8010244d <skipelem+0x36>
    path++;
80102449:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
8010244d:	8b 45 08             	mov    0x8(%ebp),%eax
80102450:	0f b6 00             	movzbl (%eax),%eax
80102453:	3c 2f                	cmp    $0x2f,%al
80102455:	74 0a                	je     80102461 <skipelem+0x4a>
80102457:	8b 45 08             	mov    0x8(%ebp),%eax
8010245a:	0f b6 00             	movzbl (%eax),%eax
8010245d:	84 c0                	test   %al,%al
8010245f:	75 e8                	jne    80102449 <skipelem+0x32>
    path++;
  len = path - s;
80102461:	8b 55 08             	mov    0x8(%ebp),%edx
80102464:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102467:	29 c2                	sub    %eax,%edx
80102469:	89 d0                	mov    %edx,%eax
8010246b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010246e:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102472:	7e 1c                	jle    80102490 <skipelem+0x79>
    memmove(name, s, DIRSIZ);
80102474:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010247b:	00 
8010247c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010247f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102483:	8b 45 0c             	mov    0xc(%ebp),%eax
80102486:	89 04 24             	mov    %eax,(%esp)
80102489:	e8 a6 2e 00 00       	call   80105334 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010248e:	eb 2a                	jmp    801024ba <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102490:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102493:	89 44 24 08          	mov    %eax,0x8(%esp)
80102497:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010249a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010249e:	8b 45 0c             	mov    0xc(%ebp),%eax
801024a1:	89 04 24             	mov    %eax,(%esp)
801024a4:	e8 8b 2e 00 00       	call   80105334 <memmove>
    name[len] = 0;
801024a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801024ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801024af:	01 d0                	add    %edx,%eax
801024b1:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801024b4:	eb 04                	jmp    801024ba <skipelem+0xa3>
    path++;
801024b6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801024ba:	8b 45 08             	mov    0x8(%ebp),%eax
801024bd:	0f b6 00             	movzbl (%eax),%eax
801024c0:	3c 2f                	cmp    $0x2f,%al
801024c2:	74 f2                	je     801024b6 <skipelem+0x9f>
    path++;
  return path;
801024c4:	8b 45 08             	mov    0x8(%ebp),%eax
}
801024c7:	c9                   	leave  
801024c8:	c3                   	ret    

801024c9 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801024c9:	55                   	push   %ebp
801024ca:	89 e5                	mov    %esp,%ebp
801024cc:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
801024cf:	8b 45 08             	mov    0x8(%ebp),%eax
801024d2:	0f b6 00             	movzbl (%eax),%eax
801024d5:	3c 2f                	cmp    $0x2f,%al
801024d7:	75 1c                	jne    801024f5 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
801024d9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801024e0:	00 
801024e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801024e8:	e8 44 f4 ff ff       	call   80101931 <iget>
801024ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801024f0:	e9 af 00 00 00       	jmp    801025a4 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
801024f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801024fb:	8b 40 68             	mov    0x68(%eax),%eax
801024fe:	89 04 24             	mov    %eax,(%esp)
80102501:	e8 fd f4 ff ff       	call   80101a03 <idup>
80102506:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102509:	e9 96 00 00 00       	jmp    801025a4 <namex+0xdb>
    ilock(ip);
8010250e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102511:	89 04 24             	mov    %eax,(%esp)
80102514:	e8 1c f5 ff ff       	call   80101a35 <ilock>
    if(ip->type != T_DIR){
80102519:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010251c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102520:	66 83 f8 01          	cmp    $0x1,%ax
80102524:	74 15                	je     8010253b <namex+0x72>
      iunlockput(ip);
80102526:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102529:	89 04 24             	mov    %eax,(%esp)
8010252c:	e8 88 f7 ff ff       	call   80101cb9 <iunlockput>
      return 0;
80102531:	b8 00 00 00 00       	mov    $0x0,%eax
80102536:	e9 a3 00 00 00       	jmp    801025de <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
8010253b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010253f:	74 1d                	je     8010255e <namex+0x95>
80102541:	8b 45 08             	mov    0x8(%ebp),%eax
80102544:	0f b6 00             	movzbl (%eax),%eax
80102547:	84 c0                	test   %al,%al
80102549:	75 13                	jne    8010255e <namex+0x95>
      // Stop one level early.
      iunlock(ip);
8010254b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010254e:	89 04 24             	mov    %eax,(%esp)
80102551:	e8 2d f6 ff ff       	call   80101b83 <iunlock>
      return ip;
80102556:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102559:	e9 80 00 00 00       	jmp    801025de <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010255e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102565:	00 
80102566:	8b 45 10             	mov    0x10(%ebp),%eax
80102569:	89 44 24 04          	mov    %eax,0x4(%esp)
8010256d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102570:	89 04 24             	mov    %eax,(%esp)
80102573:	e8 df fc ff ff       	call   80102257 <dirlookup>
80102578:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010257b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010257f:	75 12                	jne    80102593 <namex+0xca>
      iunlockput(ip);
80102581:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102584:	89 04 24             	mov    %eax,(%esp)
80102587:	e8 2d f7 ff ff       	call   80101cb9 <iunlockput>
      return 0;
8010258c:	b8 00 00 00 00       	mov    $0x0,%eax
80102591:	eb 4b                	jmp    801025de <namex+0x115>
    }
    iunlockput(ip);
80102593:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102596:	89 04 24             	mov    %eax,(%esp)
80102599:	e8 1b f7 ff ff       	call   80101cb9 <iunlockput>
    ip = next;
8010259e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801025a4:	8b 45 10             	mov    0x10(%ebp),%eax
801025a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801025ab:	8b 45 08             	mov    0x8(%ebp),%eax
801025ae:	89 04 24             	mov    %eax,(%esp)
801025b1:	e8 61 fe ff ff       	call   80102417 <skipelem>
801025b6:	89 45 08             	mov    %eax,0x8(%ebp)
801025b9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025bd:	0f 85 4b ff ff ff    	jne    8010250e <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801025c3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025c7:	74 12                	je     801025db <namex+0x112>
    iput(ip);
801025c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025cc:	89 04 24             	mov    %eax,(%esp)
801025cf:	e8 14 f6 ff ff       	call   80101be8 <iput>
    return 0;
801025d4:	b8 00 00 00 00       	mov    $0x0,%eax
801025d9:	eb 03                	jmp    801025de <namex+0x115>
  }
  return ip;
801025db:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801025de:	c9                   	leave  
801025df:	c3                   	ret    

801025e0 <namei>:

struct inode*
namei(char *path)
{
801025e0:	55                   	push   %ebp
801025e1:	89 e5                	mov    %esp,%ebp
801025e3:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801025e6:	8d 45 ea             	lea    -0x16(%ebp),%eax
801025e9:	89 44 24 08          	mov    %eax,0x8(%esp)
801025ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801025f4:	00 
801025f5:	8b 45 08             	mov    0x8(%ebp),%eax
801025f8:	89 04 24             	mov    %eax,(%esp)
801025fb:	e8 c9 fe ff ff       	call   801024c9 <namex>
}
80102600:	c9                   	leave  
80102601:	c3                   	ret    

80102602 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102602:	55                   	push   %ebp
80102603:	89 e5                	mov    %esp,%ebp
80102605:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102608:	8b 45 0c             	mov    0xc(%ebp),%eax
8010260b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010260f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102616:	00 
80102617:	8b 45 08             	mov    0x8(%ebp),%eax
8010261a:	89 04 24             	mov    %eax,(%esp)
8010261d:	e8 a7 fe ff ff       	call   801024c9 <namex>
}
80102622:	c9                   	leave  
80102623:	c3                   	ret    

80102624 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102624:	55                   	push   %ebp
80102625:	89 e5                	mov    %esp,%ebp
80102627:	83 ec 14             	sub    $0x14,%esp
8010262a:	8b 45 08             	mov    0x8(%ebp),%eax
8010262d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102631:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102635:	89 c2                	mov    %eax,%edx
80102637:	ec                   	in     (%dx),%al
80102638:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010263b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010263f:	c9                   	leave  
80102640:	c3                   	ret    

80102641 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102641:	55                   	push   %ebp
80102642:	89 e5                	mov    %esp,%ebp
80102644:	57                   	push   %edi
80102645:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102646:	8b 55 08             	mov    0x8(%ebp),%edx
80102649:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010264c:	8b 45 10             	mov    0x10(%ebp),%eax
8010264f:	89 cb                	mov    %ecx,%ebx
80102651:	89 df                	mov    %ebx,%edi
80102653:	89 c1                	mov    %eax,%ecx
80102655:	fc                   	cld    
80102656:	f3 6d                	rep insl (%dx),%es:(%edi)
80102658:	89 c8                	mov    %ecx,%eax
8010265a:	89 fb                	mov    %edi,%ebx
8010265c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010265f:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102662:	5b                   	pop    %ebx
80102663:	5f                   	pop    %edi
80102664:	5d                   	pop    %ebp
80102665:	c3                   	ret    

80102666 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102666:	55                   	push   %ebp
80102667:	89 e5                	mov    %esp,%ebp
80102669:	83 ec 08             	sub    $0x8,%esp
8010266c:	8b 55 08             	mov    0x8(%ebp),%edx
8010266f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102672:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102676:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102679:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010267d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102681:	ee                   	out    %al,(%dx)
}
80102682:	c9                   	leave  
80102683:	c3                   	ret    

80102684 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102684:	55                   	push   %ebp
80102685:	89 e5                	mov    %esp,%ebp
80102687:	56                   	push   %esi
80102688:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102689:	8b 55 08             	mov    0x8(%ebp),%edx
8010268c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010268f:	8b 45 10             	mov    0x10(%ebp),%eax
80102692:	89 cb                	mov    %ecx,%ebx
80102694:	89 de                	mov    %ebx,%esi
80102696:	89 c1                	mov    %eax,%ecx
80102698:	fc                   	cld    
80102699:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010269b:	89 c8                	mov    %ecx,%eax
8010269d:	89 f3                	mov    %esi,%ebx
8010269f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801026a2:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801026a5:	5b                   	pop    %ebx
801026a6:	5e                   	pop    %esi
801026a7:	5d                   	pop    %ebp
801026a8:	c3                   	ret    

801026a9 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801026a9:	55                   	push   %ebp
801026aa:	89 e5                	mov    %esp,%ebp
801026ac:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801026af:	90                   	nop
801026b0:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026b7:	e8 68 ff ff ff       	call   80102624 <inb>
801026bc:	0f b6 c0             	movzbl %al,%eax
801026bf:	89 45 fc             	mov    %eax,-0x4(%ebp)
801026c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026c5:	25 c0 00 00 00       	and    $0xc0,%eax
801026ca:	83 f8 40             	cmp    $0x40,%eax
801026cd:	75 e1                	jne    801026b0 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801026cf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026d3:	74 11                	je     801026e6 <idewait+0x3d>
801026d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026d8:	83 e0 21             	and    $0x21,%eax
801026db:	85 c0                	test   %eax,%eax
801026dd:	74 07                	je     801026e6 <idewait+0x3d>
    return -1;
801026df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801026e4:	eb 05                	jmp    801026eb <idewait+0x42>
  return 0;
801026e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801026eb:	c9                   	leave  
801026ec:	c3                   	ret    

801026ed <ideinit>:

void
ideinit(void)
{
801026ed:	55                   	push   %ebp
801026ee:	89 e5                	mov    %esp,%ebp
801026f0:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
801026f3:	c7 44 24 04 cc 88 10 	movl   $0x801088cc,0x4(%esp)
801026fa:	80 
801026fb:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102702:	e8 e9 28 00 00       	call   80104ff0 <initlock>
  picenable(IRQ_IDE);
80102707:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010270e:	e8 99 18 00 00       	call   80103fac <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102713:	a1 c0 29 11 80       	mov    0x801129c0,%eax
80102718:	83 e8 01             	sub    $0x1,%eax
8010271b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010271f:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102726:	e8 0c 04 00 00       	call   80102b37 <ioapicenable>
  idewait(0);
8010272b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102732:	e8 72 ff ff ff       	call   801026a9 <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102737:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
8010273e:	00 
8010273f:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102746:	e8 1b ff ff ff       	call   80102666 <outb>
  for(i=0; i<1000; i++){
8010274b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102752:	eb 20                	jmp    80102774 <ideinit+0x87>
    if(inb(0x1f7) != 0){
80102754:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010275b:	e8 c4 fe ff ff       	call   80102624 <inb>
80102760:	84 c0                	test   %al,%al
80102762:	74 0c                	je     80102770 <ideinit+0x83>
      havedisk1 = 1;
80102764:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
8010276b:	00 00 00 
      break;
8010276e:	eb 0d                	jmp    8010277d <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102770:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102774:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
8010277b:	7e d7                	jle    80102754 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010277d:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102784:	00 
80102785:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010278c:	e8 d5 fe ff ff       	call   80102666 <outb>
}
80102791:	c9                   	leave  
80102792:	c3                   	ret    

80102793 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102793:	55                   	push   %ebp
80102794:	89 e5                	mov    %esp,%ebp
80102796:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102799:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010279d:	75 0c                	jne    801027ab <idestart+0x18>
    panic("idestart");
8010279f:	c7 04 24 d0 88 10 80 	movl   $0x801088d0,(%esp)
801027a6:	e8 37 df ff ff       	call   801006e2 <panic>

  idewait(0);
801027ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801027b2:	e8 f2 fe ff ff       	call   801026a9 <idewait>
  outb(0x3f6, 0);  // generate interrupt
801027b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801027be:	00 
801027bf:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
801027c6:	e8 9b fe ff ff       	call   80102666 <outb>
  outb(0x1f2, 1);  // number of sectors
801027cb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801027d2:	00 
801027d3:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
801027da:	e8 87 fe ff ff       	call   80102666 <outb>
  outb(0x1f3, b->sector & 0xff);
801027df:	8b 45 08             	mov    0x8(%ebp),%eax
801027e2:	8b 40 08             	mov    0x8(%eax),%eax
801027e5:	0f b6 c0             	movzbl %al,%eax
801027e8:	89 44 24 04          	mov    %eax,0x4(%esp)
801027ec:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
801027f3:	e8 6e fe ff ff       	call   80102666 <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
801027f8:	8b 45 08             	mov    0x8(%ebp),%eax
801027fb:	8b 40 08             	mov    0x8(%eax),%eax
801027fe:	c1 e8 08             	shr    $0x8,%eax
80102801:	0f b6 c0             	movzbl %al,%eax
80102804:	89 44 24 04          	mov    %eax,0x4(%esp)
80102808:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
8010280f:	e8 52 fe ff ff       	call   80102666 <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
80102814:	8b 45 08             	mov    0x8(%ebp),%eax
80102817:	8b 40 08             	mov    0x8(%eax),%eax
8010281a:	c1 e8 10             	shr    $0x10,%eax
8010281d:	0f b6 c0             	movzbl %al,%eax
80102820:	89 44 24 04          	mov    %eax,0x4(%esp)
80102824:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
8010282b:	e8 36 fe ff ff       	call   80102666 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102830:	8b 45 08             	mov    0x8(%ebp),%eax
80102833:	8b 40 04             	mov    0x4(%eax),%eax
80102836:	83 e0 01             	and    $0x1,%eax
80102839:	c1 e0 04             	shl    $0x4,%eax
8010283c:	89 c2                	mov    %eax,%edx
8010283e:	8b 45 08             	mov    0x8(%ebp),%eax
80102841:	8b 40 08             	mov    0x8(%eax),%eax
80102844:	c1 e8 18             	shr    $0x18,%eax
80102847:	83 e0 0f             	and    $0xf,%eax
8010284a:	09 d0                	or     %edx,%eax
8010284c:	83 c8 e0             	or     $0xffffffe0,%eax
8010284f:	0f b6 c0             	movzbl %al,%eax
80102852:	89 44 24 04          	mov    %eax,0x4(%esp)
80102856:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010285d:	e8 04 fe ff ff       	call   80102666 <outb>
  if(b->flags & B_DIRTY){
80102862:	8b 45 08             	mov    0x8(%ebp),%eax
80102865:	8b 00                	mov    (%eax),%eax
80102867:	83 e0 04             	and    $0x4,%eax
8010286a:	85 c0                	test   %eax,%eax
8010286c:	74 34                	je     801028a2 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
8010286e:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80102875:	00 
80102876:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010287d:	e8 e4 fd ff ff       	call   80102666 <outb>
    outsl(0x1f0, b->data, 512/4);
80102882:	8b 45 08             	mov    0x8(%ebp),%eax
80102885:	83 c0 18             	add    $0x18,%eax
80102888:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010288f:	00 
80102890:	89 44 24 04          	mov    %eax,0x4(%esp)
80102894:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010289b:	e8 e4 fd ff ff       	call   80102684 <outsl>
801028a0:	eb 14                	jmp    801028b6 <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
801028a2:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
801028a9:	00 
801028aa:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801028b1:	e8 b0 fd ff ff       	call   80102666 <outb>
  }
}
801028b6:	c9                   	leave  
801028b7:	c3                   	ret    

801028b8 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801028b8:	55                   	push   %ebp
801028b9:	89 e5                	mov    %esp,%ebp
801028bb:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801028be:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801028c5:	e8 47 27 00 00       	call   80105011 <acquire>
  if((b = idequeue) == 0){
801028ca:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801028cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028d6:	75 11                	jne    801028e9 <ideintr+0x31>
    release(&idelock);
801028d8:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801028df:	e8 8f 27 00 00       	call   80105073 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
801028e4:	e9 90 00 00 00       	jmp    80102979 <ideintr+0xc1>
  }
  idequeue = b->qnext;
801028e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ec:	8b 40 14             	mov    0x14(%eax),%eax
801028ef:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801028f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028f7:	8b 00                	mov    (%eax),%eax
801028f9:	83 e0 04             	and    $0x4,%eax
801028fc:	85 c0                	test   %eax,%eax
801028fe:	75 2e                	jne    8010292e <ideintr+0x76>
80102900:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102907:	e8 9d fd ff ff       	call   801026a9 <idewait>
8010290c:	85 c0                	test   %eax,%eax
8010290e:	78 1e                	js     8010292e <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102910:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102913:	83 c0 18             	add    $0x18,%eax
80102916:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010291d:	00 
8010291e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102922:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102929:	e8 13 fd ff ff       	call   80102641 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
8010292e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102931:	8b 00                	mov    (%eax),%eax
80102933:	83 c8 02             	or     $0x2,%eax
80102936:	89 c2                	mov    %eax,%edx
80102938:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010293b:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
8010293d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102940:	8b 00                	mov    (%eax),%eax
80102942:	83 e0 fb             	and    $0xfffffffb,%eax
80102945:	89 c2                	mov    %eax,%edx
80102947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010294a:	89 10                	mov    %edx,(%eax)
  wakeup(b);
8010294c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010294f:	89 04 24             	mov    %eax,(%esp)
80102952:	e8 c9 24 00 00       	call   80104e20 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102957:	a1 34 b6 10 80       	mov    0x8010b634,%eax
8010295c:	85 c0                	test   %eax,%eax
8010295e:	74 0d                	je     8010296d <ideintr+0xb5>
    idestart(idequeue);
80102960:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102965:	89 04 24             	mov    %eax,(%esp)
80102968:	e8 26 fe ff ff       	call   80102793 <idestart>

  release(&idelock);
8010296d:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102974:	e8 fa 26 00 00       	call   80105073 <release>
}
80102979:	c9                   	leave  
8010297a:	c3                   	ret    

8010297b <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010297b:	55                   	push   %ebp
8010297c:	89 e5                	mov    %esp,%ebp
8010297e:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102981:	8b 45 08             	mov    0x8(%ebp),%eax
80102984:	8b 00                	mov    (%eax),%eax
80102986:	83 e0 01             	and    $0x1,%eax
80102989:	85 c0                	test   %eax,%eax
8010298b:	75 0c                	jne    80102999 <iderw+0x1e>
    panic("iderw: buf not busy");
8010298d:	c7 04 24 d9 88 10 80 	movl   $0x801088d9,(%esp)
80102994:	e8 49 dd ff ff       	call   801006e2 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102999:	8b 45 08             	mov    0x8(%ebp),%eax
8010299c:	8b 00                	mov    (%eax),%eax
8010299e:	83 e0 06             	and    $0x6,%eax
801029a1:	83 f8 02             	cmp    $0x2,%eax
801029a4:	75 0c                	jne    801029b2 <iderw+0x37>
    panic("iderw: nothing to do");
801029a6:	c7 04 24 ed 88 10 80 	movl   $0x801088ed,(%esp)
801029ad:	e8 30 dd ff ff       	call   801006e2 <panic>
  if(b->dev != 0 && !havedisk1)
801029b2:	8b 45 08             	mov    0x8(%ebp),%eax
801029b5:	8b 40 04             	mov    0x4(%eax),%eax
801029b8:	85 c0                	test   %eax,%eax
801029ba:	74 15                	je     801029d1 <iderw+0x56>
801029bc:	a1 38 b6 10 80       	mov    0x8010b638,%eax
801029c1:	85 c0                	test   %eax,%eax
801029c3:	75 0c                	jne    801029d1 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
801029c5:	c7 04 24 02 89 10 80 	movl   $0x80108902,(%esp)
801029cc:	e8 11 dd ff ff       	call   801006e2 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801029d1:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801029d8:	e8 34 26 00 00       	call   80105011 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
801029dd:	8b 45 08             	mov    0x8(%ebp),%eax
801029e0:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801029e7:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
801029ee:	eb 0b                	jmp    801029fb <iderw+0x80>
801029f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029f3:	8b 00                	mov    (%eax),%eax
801029f5:	83 c0 14             	add    $0x14,%eax
801029f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029fe:	8b 00                	mov    (%eax),%eax
80102a00:	85 c0                	test   %eax,%eax
80102a02:	75 ec                	jne    801029f0 <iderw+0x75>
    ;
  *pp = b;
80102a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a07:	8b 55 08             	mov    0x8(%ebp),%edx
80102a0a:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102a0c:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102a11:	3b 45 08             	cmp    0x8(%ebp),%eax
80102a14:	75 0d                	jne    80102a23 <iderw+0xa8>
    idestart(b);
80102a16:	8b 45 08             	mov    0x8(%ebp),%eax
80102a19:	89 04 24             	mov    %eax,(%esp)
80102a1c:	e8 72 fd ff ff       	call   80102793 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a21:	eb 15                	jmp    80102a38 <iderw+0xbd>
80102a23:	eb 13                	jmp    80102a38 <iderw+0xbd>
    sleep(b, &idelock);
80102a25:	c7 44 24 04 00 b6 10 	movl   $0x8010b600,0x4(%esp)
80102a2c:	80 
80102a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80102a30:	89 04 24             	mov    %eax,(%esp)
80102a33:	e8 0f 23 00 00       	call   80104d47 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a38:	8b 45 08             	mov    0x8(%ebp),%eax
80102a3b:	8b 00                	mov    (%eax),%eax
80102a3d:	83 e0 06             	and    $0x6,%eax
80102a40:	83 f8 02             	cmp    $0x2,%eax
80102a43:	75 e0                	jne    80102a25 <iderw+0xaa>
    sleep(b, &idelock);
  }

  release(&idelock);
80102a45:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102a4c:	e8 22 26 00 00       	call   80105073 <release>
}
80102a51:	c9                   	leave  
80102a52:	c3                   	ret    

80102a53 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a53:	55                   	push   %ebp
80102a54:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a56:	a1 14 22 11 80       	mov    0x80112214,%eax
80102a5b:	8b 55 08             	mov    0x8(%ebp),%edx
80102a5e:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a60:	a1 14 22 11 80       	mov    0x80112214,%eax
80102a65:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a68:	5d                   	pop    %ebp
80102a69:	c3                   	ret    

80102a6a <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a6a:	55                   	push   %ebp
80102a6b:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a6d:	a1 14 22 11 80       	mov    0x80112214,%eax
80102a72:	8b 55 08             	mov    0x8(%ebp),%edx
80102a75:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a77:	a1 14 22 11 80       	mov    0x80112214,%eax
80102a7c:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a7f:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a82:	5d                   	pop    %ebp
80102a83:	c3                   	ret    

80102a84 <ioapicinit>:

void
ioapicinit(void)
{
80102a84:	55                   	push   %ebp
80102a85:	89 e5                	mov    %esp,%ebp
80102a87:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
80102a8a:	a1 44 23 11 80       	mov    0x80112344,%eax
80102a8f:	85 c0                	test   %eax,%eax
80102a91:	75 05                	jne    80102a98 <ioapicinit+0x14>
    return;
80102a93:	e9 9d 00 00 00       	jmp    80102b35 <ioapicinit+0xb1>

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a98:	c7 05 14 22 11 80 00 	movl   $0xfec00000,0x80112214
80102a9f:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102aa2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102aa9:	e8 a5 ff ff ff       	call   80102a53 <ioapicread>
80102aae:	c1 e8 10             	shr    $0x10,%eax
80102ab1:	25 ff 00 00 00       	and    $0xff,%eax
80102ab6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102ab9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102ac0:	e8 8e ff ff ff       	call   80102a53 <ioapicread>
80102ac5:	c1 e8 18             	shr    $0x18,%eax
80102ac8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102acb:	0f b6 05 40 23 11 80 	movzbl 0x80112340,%eax
80102ad2:	0f b6 c0             	movzbl %al,%eax
80102ad5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102ad8:	74 0c                	je     80102ae6 <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102ada:	c7 04 24 20 89 10 80 	movl   $0x80108920,(%esp)
80102ae1:	e8 ba d8 ff ff       	call   801003a0 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102ae6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102aed:	eb 3e                	jmp    80102b2d <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102af2:	83 c0 20             	add    $0x20,%eax
80102af5:	0d 00 00 01 00       	or     $0x10000,%eax
80102afa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102afd:	83 c2 08             	add    $0x8,%edx
80102b00:	01 d2                	add    %edx,%edx
80102b02:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b06:	89 14 24             	mov    %edx,(%esp)
80102b09:	e8 5c ff ff ff       	call   80102a6a <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b11:	83 c0 08             	add    $0x8,%eax
80102b14:	01 c0                	add    %eax,%eax
80102b16:	83 c0 01             	add    $0x1,%eax
80102b19:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102b20:	00 
80102b21:	89 04 24             	mov    %eax,(%esp)
80102b24:	e8 41 ff ff ff       	call   80102a6a <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b29:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b30:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b33:	7e ba                	jle    80102aef <ioapicinit+0x6b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102b35:	c9                   	leave  
80102b36:	c3                   	ret    

80102b37 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b37:	55                   	push   %ebp
80102b38:	89 e5                	mov    %esp,%ebp
80102b3a:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102b3d:	a1 44 23 11 80       	mov    0x80112344,%eax
80102b42:	85 c0                	test   %eax,%eax
80102b44:	75 02                	jne    80102b48 <ioapicenable+0x11>
    return;
80102b46:	eb 37                	jmp    80102b7f <ioapicenable+0x48>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b48:	8b 45 08             	mov    0x8(%ebp),%eax
80102b4b:	83 c0 20             	add    $0x20,%eax
80102b4e:	8b 55 08             	mov    0x8(%ebp),%edx
80102b51:	83 c2 08             	add    $0x8,%edx
80102b54:	01 d2                	add    %edx,%edx
80102b56:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b5a:	89 14 24             	mov    %edx,(%esp)
80102b5d:	e8 08 ff ff ff       	call   80102a6a <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b62:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b65:	c1 e0 18             	shl    $0x18,%eax
80102b68:	8b 55 08             	mov    0x8(%ebp),%edx
80102b6b:	83 c2 08             	add    $0x8,%edx
80102b6e:	01 d2                	add    %edx,%edx
80102b70:	83 c2 01             	add    $0x1,%edx
80102b73:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b77:	89 14 24             	mov    %edx,(%esp)
80102b7a:	e8 eb fe ff ff       	call   80102a6a <ioapicwrite>
}
80102b7f:	c9                   	leave  
80102b80:	c3                   	ret    

80102b81 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102b81:	55                   	push   %ebp
80102b82:	89 e5                	mov    %esp,%ebp
80102b84:	8b 45 08             	mov    0x8(%ebp),%eax
80102b87:	05 00 00 00 80       	add    $0x80000000,%eax
80102b8c:	5d                   	pop    %ebp
80102b8d:	c3                   	ret    

80102b8e <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b8e:	55                   	push   %ebp
80102b8f:	89 e5                	mov    %esp,%ebp
80102b91:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102b94:	c7 44 24 04 52 89 10 	movl   $0x80108952,0x4(%esp)
80102b9b:	80 
80102b9c:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102ba3:	e8 48 24 00 00       	call   80104ff0 <initlock>
  kmem.use_lock = 0;
80102ba8:	c7 05 54 22 11 80 00 	movl   $0x0,0x80112254
80102baf:	00 00 00 
  freerange(vstart, vend);
80102bb2:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bb5:	89 44 24 04          	mov    %eax,0x4(%esp)
80102bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80102bbc:	89 04 24             	mov    %eax,(%esp)
80102bbf:	e8 26 00 00 00       	call   80102bea <freerange>
}
80102bc4:	c9                   	leave  
80102bc5:	c3                   	ret    

80102bc6 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102bc6:	55                   	push   %ebp
80102bc7:	89 e5                	mov    %esp,%ebp
80102bc9:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102bcc:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bcf:	89 44 24 04          	mov    %eax,0x4(%esp)
80102bd3:	8b 45 08             	mov    0x8(%ebp),%eax
80102bd6:	89 04 24             	mov    %eax,(%esp)
80102bd9:	e8 0c 00 00 00       	call   80102bea <freerange>
  kmem.use_lock = 1;
80102bde:	c7 05 54 22 11 80 01 	movl   $0x1,0x80112254
80102be5:	00 00 00 
}
80102be8:	c9                   	leave  
80102be9:	c3                   	ret    

80102bea <freerange>:

void
freerange(void *vstart, void *vend)
{
80102bea:	55                   	push   %ebp
80102beb:	89 e5                	mov    %esp,%ebp
80102bed:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80102bf3:	05 ff 0f 00 00       	add    $0xfff,%eax
80102bf8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102bfd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c00:	eb 12                	jmp    80102c14 <freerange+0x2a>
    kfree(p);
80102c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c05:	89 04 24             	mov    %eax,(%esp)
80102c08:	e8 16 00 00 00       	call   80102c23 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c0d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c17:	05 00 10 00 00       	add    $0x1000,%eax
80102c1c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102c1f:	76 e1                	jbe    80102c02 <freerange+0x18>
    kfree(p);
}
80102c21:	c9                   	leave  
80102c22:	c3                   	ret    

80102c23 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102c23:	55                   	push   %ebp
80102c24:	89 e5                	mov    %esp,%ebp
80102c26:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102c29:	8b 45 08             	mov    0x8(%ebp),%eax
80102c2c:	25 ff 0f 00 00       	and    $0xfff,%eax
80102c31:	85 c0                	test   %eax,%eax
80102c33:	75 1b                	jne    80102c50 <kfree+0x2d>
80102c35:	81 7d 08 b8 51 11 80 	cmpl   $0x801151b8,0x8(%ebp)
80102c3c:	72 12                	jb     80102c50 <kfree+0x2d>
80102c3e:	8b 45 08             	mov    0x8(%ebp),%eax
80102c41:	89 04 24             	mov    %eax,(%esp)
80102c44:	e8 38 ff ff ff       	call   80102b81 <v2p>
80102c49:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c4e:	76 0c                	jbe    80102c5c <kfree+0x39>
    panic("kfree");
80102c50:	c7 04 24 57 89 10 80 	movl   $0x80108957,(%esp)
80102c57:	e8 86 da ff ff       	call   801006e2 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c5c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102c63:	00 
80102c64:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102c6b:	00 
80102c6c:	8b 45 08             	mov    0x8(%ebp),%eax
80102c6f:	89 04 24             	mov    %eax,(%esp)
80102c72:	e8 ee 25 00 00       	call   80105265 <memset>

  if(kmem.use_lock)
80102c77:	a1 54 22 11 80       	mov    0x80112254,%eax
80102c7c:	85 c0                	test   %eax,%eax
80102c7e:	74 0c                	je     80102c8c <kfree+0x69>
    acquire(&kmem.lock);
80102c80:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102c87:	e8 85 23 00 00       	call   80105011 <acquire>
  r = (struct run*)v;
80102c8c:	8b 45 08             	mov    0x8(%ebp),%eax
80102c8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c92:	8b 15 58 22 11 80    	mov    0x80112258,%edx
80102c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c9b:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ca0:	a3 58 22 11 80       	mov    %eax,0x80112258
  if(kmem.use_lock)
80102ca5:	a1 54 22 11 80       	mov    0x80112254,%eax
80102caa:	85 c0                	test   %eax,%eax
80102cac:	74 0c                	je     80102cba <kfree+0x97>
    release(&kmem.lock);
80102cae:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102cb5:	e8 b9 23 00 00       	call   80105073 <release>
}
80102cba:	c9                   	leave  
80102cbb:	c3                   	ret    

80102cbc <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102cbc:	55                   	push   %ebp
80102cbd:	89 e5                	mov    %esp,%ebp
80102cbf:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102cc2:	a1 54 22 11 80       	mov    0x80112254,%eax
80102cc7:	85 c0                	test   %eax,%eax
80102cc9:	74 0c                	je     80102cd7 <kalloc+0x1b>
    acquire(&kmem.lock);
80102ccb:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102cd2:	e8 3a 23 00 00       	call   80105011 <acquire>
  r = kmem.freelist;
80102cd7:	a1 58 22 11 80       	mov    0x80112258,%eax
80102cdc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102cdf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102ce3:	74 0a                	je     80102cef <kalloc+0x33>
    kmem.freelist = r->next;
80102ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ce8:	8b 00                	mov    (%eax),%eax
80102cea:	a3 58 22 11 80       	mov    %eax,0x80112258
  if(kmem.use_lock)
80102cef:	a1 54 22 11 80       	mov    0x80112254,%eax
80102cf4:	85 c0                	test   %eax,%eax
80102cf6:	74 0c                	je     80102d04 <kalloc+0x48>
    release(&kmem.lock);
80102cf8:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102cff:	e8 6f 23 00 00       	call   80105073 <release>
  return (char*)r;
80102d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102d07:	c9                   	leave  
80102d08:	c3                   	ret    

80102d09 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d09:	55                   	push   %ebp
80102d0a:	89 e5                	mov    %esp,%ebp
80102d0c:	83 ec 14             	sub    $0x14,%esp
80102d0f:	8b 45 08             	mov    0x8(%ebp),%eax
80102d12:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d16:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d1a:	89 c2                	mov    %eax,%edx
80102d1c:	ec                   	in     (%dx),%al
80102d1d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d20:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d24:	c9                   	leave  
80102d25:	c3                   	ret    

80102d26 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102d26:	55                   	push   %ebp
80102d27:	89 e5                	mov    %esp,%ebp
80102d29:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102d2c:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102d33:	e8 d1 ff ff ff       	call   80102d09 <inb>
80102d38:	0f b6 c0             	movzbl %al,%eax
80102d3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d41:	83 e0 01             	and    $0x1,%eax
80102d44:	85 c0                	test   %eax,%eax
80102d46:	75 0a                	jne    80102d52 <kbdgetc+0x2c>
    return -1;
80102d48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d4d:	e9 25 01 00 00       	jmp    80102e77 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102d52:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102d59:	e8 ab ff ff ff       	call   80102d09 <inb>
80102d5e:	0f b6 c0             	movzbl %al,%eax
80102d61:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d64:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d6b:	75 17                	jne    80102d84 <kbdgetc+0x5e>
    shift |= E0ESC;
80102d6d:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d72:	83 c8 40             	or     $0x40,%eax
80102d75:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102d7a:	b8 00 00 00 00       	mov    $0x0,%eax
80102d7f:	e9 f3 00 00 00       	jmp    80102e77 <kbdgetc+0x151>
  } else if(data & 0x80){
80102d84:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d87:	25 80 00 00 00       	and    $0x80,%eax
80102d8c:	85 c0                	test   %eax,%eax
80102d8e:	74 45                	je     80102dd5 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d90:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d95:	83 e0 40             	and    $0x40,%eax
80102d98:	85 c0                	test   %eax,%eax
80102d9a:	75 08                	jne    80102da4 <kbdgetc+0x7e>
80102d9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d9f:	83 e0 7f             	and    $0x7f,%eax
80102da2:	eb 03                	jmp    80102da7 <kbdgetc+0x81>
80102da4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102da7:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102daa:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dad:	05 20 90 10 80       	add    $0x80109020,%eax
80102db2:	0f b6 00             	movzbl (%eax),%eax
80102db5:	83 c8 40             	or     $0x40,%eax
80102db8:	0f b6 c0             	movzbl %al,%eax
80102dbb:	f7 d0                	not    %eax
80102dbd:	89 c2                	mov    %eax,%edx
80102dbf:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102dc4:	21 d0                	and    %edx,%eax
80102dc6:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102dcb:	b8 00 00 00 00       	mov    $0x0,%eax
80102dd0:	e9 a2 00 00 00       	jmp    80102e77 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102dd5:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102dda:	83 e0 40             	and    $0x40,%eax
80102ddd:	85 c0                	test   %eax,%eax
80102ddf:	74 14                	je     80102df5 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102de1:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102de8:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102ded:	83 e0 bf             	and    $0xffffffbf,%eax
80102df0:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102df5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102df8:	05 20 90 10 80       	add    $0x80109020,%eax
80102dfd:	0f b6 00             	movzbl (%eax),%eax
80102e00:	0f b6 d0             	movzbl %al,%edx
80102e03:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102e08:	09 d0                	or     %edx,%eax
80102e0a:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102e0f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e12:	05 20 91 10 80       	add    $0x80109120,%eax
80102e17:	0f b6 00             	movzbl (%eax),%eax
80102e1a:	0f b6 d0             	movzbl %al,%edx
80102e1d:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102e22:	31 d0                	xor    %edx,%eax
80102e24:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102e29:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102e2e:	83 e0 03             	and    $0x3,%eax
80102e31:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102e38:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e3b:	01 d0                	add    %edx,%eax
80102e3d:	0f b6 00             	movzbl (%eax),%eax
80102e40:	0f b6 c0             	movzbl %al,%eax
80102e43:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e46:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102e4b:	83 e0 08             	and    $0x8,%eax
80102e4e:	85 c0                	test   %eax,%eax
80102e50:	74 22                	je     80102e74 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102e52:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e56:	76 0c                	jbe    80102e64 <kbdgetc+0x13e>
80102e58:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e5c:	77 06                	ja     80102e64 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102e5e:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e62:	eb 10                	jmp    80102e74 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102e64:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e68:	76 0a                	jbe    80102e74 <kbdgetc+0x14e>
80102e6a:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e6e:	77 04                	ja     80102e74 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102e70:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e74:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e77:	c9                   	leave  
80102e78:	c3                   	ret    

80102e79 <kbdintr>:

void
kbdintr(void)
{
80102e79:	55                   	push   %ebp
80102e7a:	89 e5                	mov    %esp,%ebp
80102e7c:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102e7f:	c7 04 24 26 2d 10 80 	movl   $0x80102d26,(%esp)
80102e86:	e8 ca da ff ff       	call   80100955 <consoleintr>
}
80102e8b:	c9                   	leave  
80102e8c:	c3                   	ret    

80102e8d <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e8d:	55                   	push   %ebp
80102e8e:	89 e5                	mov    %esp,%ebp
80102e90:	83 ec 14             	sub    $0x14,%esp
80102e93:	8b 45 08             	mov    0x8(%ebp),%eax
80102e96:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e9a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e9e:	89 c2                	mov    %eax,%edx
80102ea0:	ec                   	in     (%dx),%al
80102ea1:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102ea4:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102ea8:	c9                   	leave  
80102ea9:	c3                   	ret    

80102eaa <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102eaa:	55                   	push   %ebp
80102eab:	89 e5                	mov    %esp,%ebp
80102ead:	83 ec 08             	sub    $0x8,%esp
80102eb0:	8b 55 08             	mov    0x8(%ebp),%edx
80102eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80102eb6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102eba:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ebd:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102ec1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102ec5:	ee                   	out    %al,(%dx)
}
80102ec6:	c9                   	leave  
80102ec7:	c3                   	ret    

80102ec8 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102ec8:	55                   	push   %ebp
80102ec9:	89 e5                	mov    %esp,%ebp
80102ecb:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102ece:	9c                   	pushf  
80102ecf:	58                   	pop    %eax
80102ed0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102ed3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102ed6:	c9                   	leave  
80102ed7:	c3                   	ret    

80102ed8 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102ed8:	55                   	push   %ebp
80102ed9:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102edb:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102ee0:	8b 55 08             	mov    0x8(%ebp),%edx
80102ee3:	c1 e2 02             	shl    $0x2,%edx
80102ee6:	01 c2                	add    %eax,%edx
80102ee8:	8b 45 0c             	mov    0xc(%ebp),%eax
80102eeb:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102eed:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102ef2:	83 c0 20             	add    $0x20,%eax
80102ef5:	8b 00                	mov    (%eax),%eax
}
80102ef7:	5d                   	pop    %ebp
80102ef8:	c3                   	ret    

80102ef9 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102ef9:	55                   	push   %ebp
80102efa:	89 e5                	mov    %esp,%ebp
80102efc:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102eff:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102f04:	85 c0                	test   %eax,%eax
80102f06:	75 05                	jne    80102f0d <lapicinit+0x14>
    return;
80102f08:	e9 43 01 00 00       	jmp    80103050 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102f0d:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102f14:	00 
80102f15:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102f1c:	e8 b7 ff ff ff       	call   80102ed8 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102f21:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102f28:	00 
80102f29:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102f30:	e8 a3 ff ff ff       	call   80102ed8 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102f35:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102f3c:	00 
80102f3d:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102f44:	e8 8f ff ff ff       	call   80102ed8 <lapicw>
  lapicw(TICR, 10000000); 
80102f49:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102f50:	00 
80102f51:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102f58:	e8 7b ff ff ff       	call   80102ed8 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f5d:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102f64:	00 
80102f65:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102f6c:	e8 67 ff ff ff       	call   80102ed8 <lapicw>
  lapicw(LINT1, MASKED);
80102f71:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102f78:	00 
80102f79:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102f80:	e8 53 ff ff ff       	call   80102ed8 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f85:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102f8a:	83 c0 30             	add    $0x30,%eax
80102f8d:	8b 00                	mov    (%eax),%eax
80102f8f:	c1 e8 10             	shr    $0x10,%eax
80102f92:	0f b6 c0             	movzbl %al,%eax
80102f95:	83 f8 03             	cmp    $0x3,%eax
80102f98:	76 14                	jbe    80102fae <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102f9a:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102fa1:	00 
80102fa2:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102fa9:	e8 2a ff ff ff       	call   80102ed8 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102fae:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102fb5:	00 
80102fb6:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102fbd:	e8 16 ff ff ff       	call   80102ed8 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102fc2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102fc9:	00 
80102fca:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102fd1:	e8 02 ff ff ff       	call   80102ed8 <lapicw>
  lapicw(ESR, 0);
80102fd6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102fdd:	00 
80102fde:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102fe5:	e8 ee fe ff ff       	call   80102ed8 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102fea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ff1:	00 
80102ff2:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102ff9:	e8 da fe ff ff       	call   80102ed8 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ffe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103005:	00 
80103006:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010300d:	e8 c6 fe ff ff       	call   80102ed8 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103012:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80103019:	00 
8010301a:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103021:	e8 b2 fe ff ff       	call   80102ed8 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80103026:	90                   	nop
80103027:	a1 5c 22 11 80       	mov    0x8011225c,%eax
8010302c:	05 00 03 00 00       	add    $0x300,%eax
80103031:	8b 00                	mov    (%eax),%eax
80103033:	25 00 10 00 00       	and    $0x1000,%eax
80103038:	85 c0                	test   %eax,%eax
8010303a:	75 eb                	jne    80103027 <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
8010303c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103043:	00 
80103044:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010304b:	e8 88 fe ff ff       	call   80102ed8 <lapicw>
}
80103050:	c9                   	leave  
80103051:	c3                   	ret    

80103052 <cpunum>:

int
cpunum(void)
{
80103052:	55                   	push   %ebp
80103053:	89 e5                	mov    %esp,%ebp
80103055:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80103058:	e8 6b fe ff ff       	call   80102ec8 <readeflags>
8010305d:	25 00 02 00 00       	and    $0x200,%eax
80103062:	85 c0                	test   %eax,%eax
80103064:	74 25                	je     8010308b <cpunum+0x39>
    static int n;
    if(n++ == 0)
80103066:	a1 40 b6 10 80       	mov    0x8010b640,%eax
8010306b:	8d 50 01             	lea    0x1(%eax),%edx
8010306e:	89 15 40 b6 10 80    	mov    %edx,0x8010b640
80103074:	85 c0                	test   %eax,%eax
80103076:	75 13                	jne    8010308b <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
80103078:	8b 45 04             	mov    0x4(%ebp),%eax
8010307b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010307f:	c7 04 24 60 89 10 80 	movl   $0x80108960,(%esp)
80103086:	e8 15 d3 ff ff       	call   801003a0 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
8010308b:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80103090:	85 c0                	test   %eax,%eax
80103092:	74 0f                	je     801030a3 <cpunum+0x51>
    return lapic[ID]>>24;
80103094:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80103099:	83 c0 20             	add    $0x20,%eax
8010309c:	8b 00                	mov    (%eax),%eax
8010309e:	c1 e8 18             	shr    $0x18,%eax
801030a1:	eb 05                	jmp    801030a8 <cpunum+0x56>
  return 0;
801030a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801030a8:	c9                   	leave  
801030a9:	c3                   	ret    

801030aa <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801030aa:	55                   	push   %ebp
801030ab:	89 e5                	mov    %esp,%ebp
801030ad:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
801030b0:	a1 5c 22 11 80       	mov    0x8011225c,%eax
801030b5:	85 c0                	test   %eax,%eax
801030b7:	74 14                	je     801030cd <lapiceoi+0x23>
    lapicw(EOI, 0);
801030b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801030c0:	00 
801030c1:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
801030c8:	e8 0b fe ff ff       	call   80102ed8 <lapicw>
}
801030cd:	c9                   	leave  
801030ce:	c3                   	ret    

801030cf <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801030cf:	55                   	push   %ebp
801030d0:	89 e5                	mov    %esp,%ebp
}
801030d2:	5d                   	pop    %ebp
801030d3:	c3                   	ret    

801030d4 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801030d4:	55                   	push   %ebp
801030d5:	89 e5                	mov    %esp,%ebp
801030d7:	83 ec 1c             	sub    $0x1c,%esp
801030da:	8b 45 08             	mov    0x8(%ebp),%eax
801030dd:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801030e0:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
801030e7:	00 
801030e8:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801030ef:	e8 b6 fd ff ff       	call   80102eaa <outb>
  outb(CMOS_PORT+1, 0x0A);
801030f4:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
801030fb:	00 
801030fc:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103103:	e8 a2 fd ff ff       	call   80102eaa <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103108:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010310f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103112:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103117:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010311a:	8d 50 02             	lea    0x2(%eax),%edx
8010311d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103120:	c1 e8 04             	shr    $0x4,%eax
80103123:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103126:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010312a:	c1 e0 18             	shl    $0x18,%eax
8010312d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103131:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103138:	e8 9b fd ff ff       	call   80102ed8 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010313d:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80103144:	00 
80103145:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010314c:	e8 87 fd ff ff       	call   80102ed8 <lapicw>
  microdelay(200);
80103151:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103158:	e8 72 ff ff ff       	call   801030cf <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
8010315d:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80103164:	00 
80103165:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010316c:	e8 67 fd ff ff       	call   80102ed8 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103171:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103178:	e8 52 ff ff ff       	call   801030cf <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010317d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103184:	eb 40                	jmp    801031c6 <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80103186:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010318a:	c1 e0 18             	shl    $0x18,%eax
8010318d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103191:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103198:	e8 3b fd ff ff       	call   80102ed8 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
8010319d:	8b 45 0c             	mov    0xc(%ebp),%eax
801031a0:	c1 e8 0c             	shr    $0xc,%eax
801031a3:	80 cc 06             	or     $0x6,%ah
801031a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801031aa:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801031b1:	e8 22 fd ff ff       	call   80102ed8 <lapicw>
    microdelay(200);
801031b6:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801031bd:	e8 0d ff ff ff       	call   801030cf <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801031c2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801031c6:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801031ca:	7e ba                	jle    80103186 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801031cc:	c9                   	leave  
801031cd:	c3                   	ret    

801031ce <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801031ce:	55                   	push   %ebp
801031cf:	89 e5                	mov    %esp,%ebp
801031d1:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
801031d4:	8b 45 08             	mov    0x8(%ebp),%eax
801031d7:	0f b6 c0             	movzbl %al,%eax
801031da:	89 44 24 04          	mov    %eax,0x4(%esp)
801031de:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801031e5:	e8 c0 fc ff ff       	call   80102eaa <outb>
  microdelay(200);
801031ea:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801031f1:	e8 d9 fe ff ff       	call   801030cf <microdelay>

  return inb(CMOS_RETURN);
801031f6:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801031fd:	e8 8b fc ff ff       	call   80102e8d <inb>
80103202:	0f b6 c0             	movzbl %al,%eax
}
80103205:	c9                   	leave  
80103206:	c3                   	ret    

80103207 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103207:	55                   	push   %ebp
80103208:	89 e5                	mov    %esp,%ebp
8010320a:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
8010320d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80103214:	e8 b5 ff ff ff       	call   801031ce <cmos_read>
80103219:	8b 55 08             	mov    0x8(%ebp),%edx
8010321c:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
8010321e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80103225:	e8 a4 ff ff ff       	call   801031ce <cmos_read>
8010322a:	8b 55 08             	mov    0x8(%ebp),%edx
8010322d:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103230:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80103237:	e8 92 ff ff ff       	call   801031ce <cmos_read>
8010323c:	8b 55 08             	mov    0x8(%ebp),%edx
8010323f:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103242:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
80103249:	e8 80 ff ff ff       	call   801031ce <cmos_read>
8010324e:	8b 55 08             	mov    0x8(%ebp),%edx
80103251:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103254:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010325b:	e8 6e ff ff ff       	call   801031ce <cmos_read>
80103260:	8b 55 08             	mov    0x8(%ebp),%edx
80103263:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103266:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
8010326d:	e8 5c ff ff ff       	call   801031ce <cmos_read>
80103272:	8b 55 08             	mov    0x8(%ebp),%edx
80103275:	89 42 14             	mov    %eax,0x14(%edx)
}
80103278:	c9                   	leave  
80103279:	c3                   	ret    

8010327a <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010327a:	55                   	push   %ebp
8010327b:	89 e5                	mov    %esp,%ebp
8010327d:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103280:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
80103287:	e8 42 ff ff ff       	call   801031ce <cmos_read>
8010328c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010328f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103292:	83 e0 04             	and    $0x4,%eax
80103295:	85 c0                	test   %eax,%eax
80103297:	0f 94 c0             	sete   %al
8010329a:	0f b6 c0             	movzbl %al,%eax
8010329d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801032a0:	8d 45 d8             	lea    -0x28(%ebp),%eax
801032a3:	89 04 24             	mov    %eax,(%esp)
801032a6:	e8 5c ff ff ff       	call   80103207 <fill_rtcdate>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801032ab:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801032b2:	e8 17 ff ff ff       	call   801031ce <cmos_read>
801032b7:	25 80 00 00 00       	and    $0x80,%eax
801032bc:	85 c0                	test   %eax,%eax
801032be:	74 02                	je     801032c2 <cmostime+0x48>
        continue;
801032c0:	eb 36                	jmp    801032f8 <cmostime+0x7e>
    fill_rtcdate(&t2);
801032c2:	8d 45 c0             	lea    -0x40(%ebp),%eax
801032c5:	89 04 24             	mov    %eax,(%esp)
801032c8:	e8 3a ff ff ff       	call   80103207 <fill_rtcdate>
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
801032cd:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
801032d4:	00 
801032d5:	8d 45 c0             	lea    -0x40(%ebp),%eax
801032d8:	89 44 24 04          	mov    %eax,0x4(%esp)
801032dc:	8d 45 d8             	lea    -0x28(%ebp),%eax
801032df:	89 04 24             	mov    %eax,(%esp)
801032e2:	e8 f5 1f 00 00       	call   801052dc <memcmp>
801032e7:	85 c0                	test   %eax,%eax
801032e9:	75 0d                	jne    801032f8 <cmostime+0x7e>
      break;
801032eb:	90                   	nop
  }

  // convert
  if (bcd) {
801032ec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801032f0:	0f 84 ac 00 00 00    	je     801033a2 <cmostime+0x128>
801032f6:	eb 02                	jmp    801032fa <cmostime+0x80>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801032f8:	eb a6                	jmp    801032a0 <cmostime+0x26>

  // convert
  if (bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801032fa:	8b 45 d8             	mov    -0x28(%ebp),%eax
801032fd:	c1 e8 04             	shr    $0x4,%eax
80103300:	89 c2                	mov    %eax,%edx
80103302:	89 d0                	mov    %edx,%eax
80103304:	c1 e0 02             	shl    $0x2,%eax
80103307:	01 d0                	add    %edx,%eax
80103309:	01 c0                	add    %eax,%eax
8010330b:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010330e:	83 e2 0f             	and    $0xf,%edx
80103311:	01 d0                	add    %edx,%eax
80103313:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103316:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103319:	c1 e8 04             	shr    $0x4,%eax
8010331c:	89 c2                	mov    %eax,%edx
8010331e:	89 d0                	mov    %edx,%eax
80103320:	c1 e0 02             	shl    $0x2,%eax
80103323:	01 d0                	add    %edx,%eax
80103325:	01 c0                	add    %eax,%eax
80103327:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010332a:	83 e2 0f             	and    $0xf,%edx
8010332d:	01 d0                	add    %edx,%eax
8010332f:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103332:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103335:	c1 e8 04             	shr    $0x4,%eax
80103338:	89 c2                	mov    %eax,%edx
8010333a:	89 d0                	mov    %edx,%eax
8010333c:	c1 e0 02             	shl    $0x2,%eax
8010333f:	01 d0                	add    %edx,%eax
80103341:	01 c0                	add    %eax,%eax
80103343:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103346:	83 e2 0f             	and    $0xf,%edx
80103349:	01 d0                	add    %edx,%eax
8010334b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010334e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103351:	c1 e8 04             	shr    $0x4,%eax
80103354:	89 c2                	mov    %eax,%edx
80103356:	89 d0                	mov    %edx,%eax
80103358:	c1 e0 02             	shl    $0x2,%eax
8010335b:	01 d0                	add    %edx,%eax
8010335d:	01 c0                	add    %eax,%eax
8010335f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103362:	83 e2 0f             	and    $0xf,%edx
80103365:	01 d0                	add    %edx,%eax
80103367:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010336a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010336d:	c1 e8 04             	shr    $0x4,%eax
80103370:	89 c2                	mov    %eax,%edx
80103372:	89 d0                	mov    %edx,%eax
80103374:	c1 e0 02             	shl    $0x2,%eax
80103377:	01 d0                	add    %edx,%eax
80103379:	01 c0                	add    %eax,%eax
8010337b:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010337e:	83 e2 0f             	and    $0xf,%edx
80103381:	01 d0                	add    %edx,%eax
80103383:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103386:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103389:	c1 e8 04             	shr    $0x4,%eax
8010338c:	89 c2                	mov    %eax,%edx
8010338e:	89 d0                	mov    %edx,%eax
80103390:	c1 e0 02             	shl    $0x2,%eax
80103393:	01 d0                	add    %edx,%eax
80103395:	01 c0                	add    %eax,%eax
80103397:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010339a:	83 e2 0f             	and    $0xf,%edx
8010339d:	01 d0                	add    %edx,%eax
8010339f:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801033a2:	8b 45 08             	mov    0x8(%ebp),%eax
801033a5:	8b 55 d8             	mov    -0x28(%ebp),%edx
801033a8:	89 10                	mov    %edx,(%eax)
801033aa:	8b 55 dc             	mov    -0x24(%ebp),%edx
801033ad:	89 50 04             	mov    %edx,0x4(%eax)
801033b0:	8b 55 e0             	mov    -0x20(%ebp),%edx
801033b3:	89 50 08             	mov    %edx,0x8(%eax)
801033b6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801033b9:	89 50 0c             	mov    %edx,0xc(%eax)
801033bc:	8b 55 e8             	mov    -0x18(%ebp),%edx
801033bf:	89 50 10             	mov    %edx,0x10(%eax)
801033c2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801033c5:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801033c8:	8b 45 08             	mov    0x8(%ebp),%eax
801033cb:	8b 40 14             	mov    0x14(%eax),%eax
801033ce:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801033d4:	8b 45 08             	mov    0x8(%ebp),%eax
801033d7:	89 50 14             	mov    %edx,0x14(%eax)
}
801033da:	c9                   	leave  
801033db:	c3                   	ret    

801033dc <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(void)
{
801033dc:	55                   	push   %ebp
801033dd:	89 e5                	mov    %esp,%ebp
801033df:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801033e2:	c7 44 24 04 8c 89 10 	movl   $0x8010898c,0x4(%esp)
801033e9:	80 
801033ea:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801033f1:	e8 fa 1b 00 00       	call   80104ff0 <initlock>
  readsb(ROOTDEV, &sb);
801033f6:	8d 45 e8             	lea    -0x18(%ebp),%eax
801033f9:	89 44 24 04          	mov    %eax,0x4(%esp)
801033fd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103404:	e8 c2 e0 ff ff       	call   801014cb <readsb>
  log.start = sb.size - sb.nlog;
80103409:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010340c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010340f:	29 c2                	sub    %eax,%edx
80103411:	89 d0                	mov    %edx,%eax
80103413:	a3 94 22 11 80       	mov    %eax,0x80112294
  log.size = sb.nlog;
80103418:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010341b:	a3 98 22 11 80       	mov    %eax,0x80112298
  log.dev = ROOTDEV;
80103420:	c7 05 a4 22 11 80 01 	movl   $0x1,0x801122a4
80103427:	00 00 00 
  recover_from_log();
8010342a:	e8 9a 01 00 00       	call   801035c9 <recover_from_log>
}
8010342f:	c9                   	leave  
80103430:	c3                   	ret    

80103431 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103431:	55                   	push   %ebp
80103432:	89 e5                	mov    %esp,%ebp
80103434:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103437:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010343e:	e9 8c 00 00 00       	jmp    801034cf <install_trans+0x9e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103443:	8b 15 94 22 11 80    	mov    0x80112294,%edx
80103449:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010344c:	01 d0                	add    %edx,%eax
8010344e:	83 c0 01             	add    $0x1,%eax
80103451:	89 c2                	mov    %eax,%edx
80103453:	a1 a4 22 11 80       	mov    0x801122a4,%eax
80103458:	89 54 24 04          	mov    %edx,0x4(%esp)
8010345c:	89 04 24             	mov    %eax,(%esp)
8010345f:	e8 42 cd ff ff       	call   801001a6 <bread>
80103464:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
80103467:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010346a:	83 c0 10             	add    $0x10,%eax
8010346d:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
80103474:	89 c2                	mov    %eax,%edx
80103476:	a1 a4 22 11 80       	mov    0x801122a4,%eax
8010347b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010347f:	89 04 24             	mov    %eax,(%esp)
80103482:	e8 1f cd ff ff       	call   801001a6 <bread>
80103487:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010348a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010348d:	8d 50 18             	lea    0x18(%eax),%edx
80103490:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103493:	83 c0 18             	add    $0x18,%eax
80103496:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010349d:	00 
8010349e:	89 54 24 04          	mov    %edx,0x4(%esp)
801034a2:	89 04 24             	mov    %eax,(%esp)
801034a5:	e8 8a 1e 00 00       	call   80105334 <memmove>
    bwrite(dbuf);  // write dst to disk
801034aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034ad:	89 04 24             	mov    %eax,(%esp)
801034b0:	e8 28 cd ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
801034b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b8:	89 04 24             	mov    %eax,(%esp)
801034bb:	e8 57 cd ff ff       	call   80100217 <brelse>
    brelse(dbuf);
801034c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034c3:	89 04 24             	mov    %eax,(%esp)
801034c6:	e8 4c cd ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801034cb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034cf:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801034d4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034d7:	0f 8f 66 ff ff ff    	jg     80103443 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801034dd:	c9                   	leave  
801034de:	c3                   	ret    

801034df <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801034df:	55                   	push   %ebp
801034e0:	89 e5                	mov    %esp,%ebp
801034e2:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801034e5:	a1 94 22 11 80       	mov    0x80112294,%eax
801034ea:	89 c2                	mov    %eax,%edx
801034ec:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801034f1:	89 54 24 04          	mov    %edx,0x4(%esp)
801034f5:	89 04 24             	mov    %eax,(%esp)
801034f8:	e8 a9 cc ff ff       	call   801001a6 <bread>
801034fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103500:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103503:	83 c0 18             	add    $0x18,%eax
80103506:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103509:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010350c:	8b 00                	mov    (%eax),%eax
8010350e:	a3 a8 22 11 80       	mov    %eax,0x801122a8
  for (i = 0; i < log.lh.n; i++) {
80103513:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010351a:	eb 1b                	jmp    80103537 <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
8010351c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010351f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103522:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103526:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103529:	83 c2 10             	add    $0x10,%edx
8010352c:	89 04 95 6c 22 11 80 	mov    %eax,-0x7feedd94(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103533:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103537:	a1 a8 22 11 80       	mov    0x801122a8,%eax
8010353c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010353f:	7f db                	jg     8010351c <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
80103541:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103544:	89 04 24             	mov    %eax,(%esp)
80103547:	e8 cb cc ff ff       	call   80100217 <brelse>
}
8010354c:	c9                   	leave  
8010354d:	c3                   	ret    

8010354e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010354e:	55                   	push   %ebp
8010354f:	89 e5                	mov    %esp,%ebp
80103551:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103554:	a1 94 22 11 80       	mov    0x80112294,%eax
80103559:	89 c2                	mov    %eax,%edx
8010355b:	a1 a4 22 11 80       	mov    0x801122a4,%eax
80103560:	89 54 24 04          	mov    %edx,0x4(%esp)
80103564:	89 04 24             	mov    %eax,(%esp)
80103567:	e8 3a cc ff ff       	call   801001a6 <bread>
8010356c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010356f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103572:	83 c0 18             	add    $0x18,%eax
80103575:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103578:	8b 15 a8 22 11 80    	mov    0x801122a8,%edx
8010357e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103581:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103583:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010358a:	eb 1b                	jmp    801035a7 <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
8010358c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010358f:	83 c0 10             	add    $0x10,%eax
80103592:	8b 0c 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%ecx
80103599:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010359c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010359f:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801035a3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801035a7:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801035ac:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035af:	7f db                	jg     8010358c <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
801035b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035b4:	89 04 24             	mov    %eax,(%esp)
801035b7:	e8 21 cc ff ff       	call   801001dd <bwrite>
  brelse(buf);
801035bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035bf:	89 04 24             	mov    %eax,(%esp)
801035c2:	e8 50 cc ff ff       	call   80100217 <brelse>
}
801035c7:	c9                   	leave  
801035c8:	c3                   	ret    

801035c9 <recover_from_log>:

static void
recover_from_log(void)
{
801035c9:	55                   	push   %ebp
801035ca:	89 e5                	mov    %esp,%ebp
801035cc:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801035cf:	e8 0b ff ff ff       	call   801034df <read_head>
  install_trans(); // if committed, copy from log to disk
801035d4:	e8 58 fe ff ff       	call   80103431 <install_trans>
  log.lh.n = 0;
801035d9:	c7 05 a8 22 11 80 00 	movl   $0x0,0x801122a8
801035e0:	00 00 00 
  write_head(); // clear the log
801035e3:	e8 66 ff ff ff       	call   8010354e <write_head>
}
801035e8:	c9                   	leave  
801035e9:	c3                   	ret    

801035ea <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801035ea:	55                   	push   %ebp
801035eb:	89 e5                	mov    %esp,%ebp
801035ed:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801035f0:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801035f7:	e8 15 1a 00 00       	call   80105011 <acquire>
  while(1){
    if(log.committing){
801035fc:	a1 a0 22 11 80       	mov    0x801122a0,%eax
80103601:	85 c0                	test   %eax,%eax
80103603:	74 16                	je     8010361b <begin_op+0x31>
      sleep(&log, &log.lock);
80103605:	c7 44 24 04 60 22 11 	movl   $0x80112260,0x4(%esp)
8010360c:	80 
8010360d:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103614:	e8 2e 17 00 00       	call   80104d47 <sleep>
80103619:	eb 4f                	jmp    8010366a <begin_op+0x80>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010361b:	8b 0d a8 22 11 80    	mov    0x801122a8,%ecx
80103621:	a1 9c 22 11 80       	mov    0x8011229c,%eax
80103626:	8d 50 01             	lea    0x1(%eax),%edx
80103629:	89 d0                	mov    %edx,%eax
8010362b:	c1 e0 02             	shl    $0x2,%eax
8010362e:	01 d0                	add    %edx,%eax
80103630:	01 c0                	add    %eax,%eax
80103632:	01 c8                	add    %ecx,%eax
80103634:	83 f8 1e             	cmp    $0x1e,%eax
80103637:	7e 16                	jle    8010364f <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103639:	c7 44 24 04 60 22 11 	movl   $0x80112260,0x4(%esp)
80103640:	80 
80103641:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103648:	e8 fa 16 00 00       	call   80104d47 <sleep>
8010364d:	eb 1b                	jmp    8010366a <begin_op+0x80>
    } else {
      log.outstanding += 1;
8010364f:	a1 9c 22 11 80       	mov    0x8011229c,%eax
80103654:	83 c0 01             	add    $0x1,%eax
80103657:	a3 9c 22 11 80       	mov    %eax,0x8011229c
      release(&log.lock);
8010365c:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103663:	e8 0b 1a 00 00       	call   80105073 <release>
      break;
80103668:	eb 02                	jmp    8010366c <begin_op+0x82>
    }
  }
8010366a:	eb 90                	jmp    801035fc <begin_op+0x12>
}
8010366c:	c9                   	leave  
8010366d:	c3                   	ret    

8010366e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
8010366e:	55                   	push   %ebp
8010366f:	89 e5                	mov    %esp,%ebp
80103671:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
80103674:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
8010367b:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103682:	e8 8a 19 00 00       	call   80105011 <acquire>
  log.outstanding -= 1;
80103687:	a1 9c 22 11 80       	mov    0x8011229c,%eax
8010368c:	83 e8 01             	sub    $0x1,%eax
8010368f:	a3 9c 22 11 80       	mov    %eax,0x8011229c
  if(log.committing)
80103694:	a1 a0 22 11 80       	mov    0x801122a0,%eax
80103699:	85 c0                	test   %eax,%eax
8010369b:	74 0c                	je     801036a9 <end_op+0x3b>
    panic("log.committing");
8010369d:	c7 04 24 90 89 10 80 	movl   $0x80108990,(%esp)
801036a4:	e8 39 d0 ff ff       	call   801006e2 <panic>
  if(log.outstanding == 0){
801036a9:	a1 9c 22 11 80       	mov    0x8011229c,%eax
801036ae:	85 c0                	test   %eax,%eax
801036b0:	75 13                	jne    801036c5 <end_op+0x57>
    do_commit = 1;
801036b2:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801036b9:	c7 05 a0 22 11 80 01 	movl   $0x1,0x801122a0
801036c0:	00 00 00 
801036c3:	eb 0c                	jmp    801036d1 <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801036c5:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801036cc:	e8 4f 17 00 00       	call   80104e20 <wakeup>
  }
  release(&log.lock);
801036d1:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801036d8:	e8 96 19 00 00       	call   80105073 <release>

  if(do_commit){
801036dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801036e1:	74 33                	je     80103716 <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801036e3:	e8 de 00 00 00       	call   801037c6 <commit>
    acquire(&log.lock);
801036e8:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801036ef:	e8 1d 19 00 00       	call   80105011 <acquire>
    log.committing = 0;
801036f4:	c7 05 a0 22 11 80 00 	movl   $0x0,0x801122a0
801036fb:	00 00 00 
    wakeup(&log);
801036fe:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103705:	e8 16 17 00 00       	call   80104e20 <wakeup>
    release(&log.lock);
8010370a:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103711:	e8 5d 19 00 00       	call   80105073 <release>
  }
}
80103716:	c9                   	leave  
80103717:	c3                   	ret    

80103718 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
80103718:	55                   	push   %ebp
80103719:	89 e5                	mov    %esp,%ebp
8010371b:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010371e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103725:	e9 8c 00 00 00       	jmp    801037b6 <write_log+0x9e>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010372a:	8b 15 94 22 11 80    	mov    0x80112294,%edx
80103730:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103733:	01 d0                	add    %edx,%eax
80103735:	83 c0 01             	add    $0x1,%eax
80103738:	89 c2                	mov    %eax,%edx
8010373a:	a1 a4 22 11 80       	mov    0x801122a4,%eax
8010373f:	89 54 24 04          	mov    %edx,0x4(%esp)
80103743:	89 04 24             	mov    %eax,(%esp)
80103746:	e8 5b ca ff ff       	call   801001a6 <bread>
8010374b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.sector[tail]); // cache block
8010374e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103751:	83 c0 10             	add    $0x10,%eax
80103754:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
8010375b:	89 c2                	mov    %eax,%edx
8010375d:	a1 a4 22 11 80       	mov    0x801122a4,%eax
80103762:	89 54 24 04          	mov    %edx,0x4(%esp)
80103766:	89 04 24             	mov    %eax,(%esp)
80103769:	e8 38 ca ff ff       	call   801001a6 <bread>
8010376e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103771:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103774:	8d 50 18             	lea    0x18(%eax),%edx
80103777:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010377a:	83 c0 18             	add    $0x18,%eax
8010377d:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103784:	00 
80103785:	89 54 24 04          	mov    %edx,0x4(%esp)
80103789:	89 04 24             	mov    %eax,(%esp)
8010378c:	e8 a3 1b 00 00       	call   80105334 <memmove>
    bwrite(to);  // write the log
80103791:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103794:	89 04 24             	mov    %eax,(%esp)
80103797:	e8 41 ca ff ff       	call   801001dd <bwrite>
    brelse(from); 
8010379c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010379f:	89 04 24             	mov    %eax,(%esp)
801037a2:	e8 70 ca ff ff       	call   80100217 <brelse>
    brelse(to);
801037a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037aa:	89 04 24             	mov    %eax,(%esp)
801037ad:	e8 65 ca ff ff       	call   80100217 <brelse>
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801037b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037b6:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801037bb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037be:	0f 8f 66 ff ff ff    	jg     8010372a <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
801037c4:	c9                   	leave  
801037c5:	c3                   	ret    

801037c6 <commit>:

static void
commit()
{
801037c6:	55                   	push   %ebp
801037c7:	89 e5                	mov    %esp,%ebp
801037c9:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801037cc:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801037d1:	85 c0                	test   %eax,%eax
801037d3:	7e 1e                	jle    801037f3 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801037d5:	e8 3e ff ff ff       	call   80103718 <write_log>
    write_head();    // Write header to disk -- the real commit
801037da:	e8 6f fd ff ff       	call   8010354e <write_head>
    install_trans(); // Now install writes to home locations
801037df:	e8 4d fc ff ff       	call   80103431 <install_trans>
    log.lh.n = 0; 
801037e4:	c7 05 a8 22 11 80 00 	movl   $0x0,0x801122a8
801037eb:	00 00 00 
    write_head();    // Erase the transaction from the log
801037ee:	e8 5b fd ff ff       	call   8010354e <write_head>
  }
}
801037f3:	c9                   	leave  
801037f4:	c3                   	ret    

801037f5 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801037f5:	55                   	push   %ebp
801037f6:	89 e5                	mov    %esp,%ebp
801037f8:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801037fb:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103800:	83 f8 1d             	cmp    $0x1d,%eax
80103803:	7f 12                	jg     80103817 <log_write+0x22>
80103805:	a1 a8 22 11 80       	mov    0x801122a8,%eax
8010380a:	8b 15 98 22 11 80    	mov    0x80112298,%edx
80103810:	83 ea 01             	sub    $0x1,%edx
80103813:	39 d0                	cmp    %edx,%eax
80103815:	7c 0c                	jl     80103823 <log_write+0x2e>
    panic("too big a transaction");
80103817:	c7 04 24 9f 89 10 80 	movl   $0x8010899f,(%esp)
8010381e:	e8 bf ce ff ff       	call   801006e2 <panic>
  if (log.outstanding < 1)
80103823:	a1 9c 22 11 80       	mov    0x8011229c,%eax
80103828:	85 c0                	test   %eax,%eax
8010382a:	7f 0c                	jg     80103838 <log_write+0x43>
    panic("log_write outside of trans");
8010382c:	c7 04 24 b5 89 10 80 	movl   $0x801089b5,(%esp)
80103833:	e8 aa ce ff ff       	call   801006e2 <panic>

  acquire(&log.lock);
80103838:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010383f:	e8 cd 17 00 00       	call   80105011 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103844:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010384b:	eb 1f                	jmp    8010386c <log_write+0x77>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
8010384d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103850:	83 c0 10             	add    $0x10,%eax
80103853:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
8010385a:	89 c2                	mov    %eax,%edx
8010385c:	8b 45 08             	mov    0x8(%ebp),%eax
8010385f:	8b 40 08             	mov    0x8(%eax),%eax
80103862:	39 c2                	cmp    %eax,%edx
80103864:	75 02                	jne    80103868 <log_write+0x73>
      break;
80103866:	eb 0e                	jmp    80103876 <log_write+0x81>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103868:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010386c:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103871:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103874:	7f d7                	jg     8010384d <log_write+0x58>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
      break;
  }
  log.lh.sector[i] = b->sector;
80103876:	8b 45 08             	mov    0x8(%ebp),%eax
80103879:	8b 40 08             	mov    0x8(%eax),%eax
8010387c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010387f:	83 c2 10             	add    $0x10,%edx
80103882:	89 04 95 6c 22 11 80 	mov    %eax,-0x7feedd94(,%edx,4)
  if (i == log.lh.n)
80103889:	a1 a8 22 11 80       	mov    0x801122a8,%eax
8010388e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103891:	75 0d                	jne    801038a0 <log_write+0xab>
    log.lh.n++;
80103893:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103898:	83 c0 01             	add    $0x1,%eax
8010389b:	a3 a8 22 11 80       	mov    %eax,0x801122a8
  b->flags |= B_DIRTY; // prevent eviction
801038a0:	8b 45 08             	mov    0x8(%ebp),%eax
801038a3:	8b 00                	mov    (%eax),%eax
801038a5:	83 c8 04             	or     $0x4,%eax
801038a8:	89 c2                	mov    %eax,%edx
801038aa:	8b 45 08             	mov    0x8(%ebp),%eax
801038ad:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801038af:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801038b6:	e8 b8 17 00 00       	call   80105073 <release>
}
801038bb:	c9                   	leave  
801038bc:	c3                   	ret    

801038bd <v2p>:
801038bd:	55                   	push   %ebp
801038be:	89 e5                	mov    %esp,%ebp
801038c0:	8b 45 08             	mov    0x8(%ebp),%eax
801038c3:	05 00 00 00 80       	add    $0x80000000,%eax
801038c8:	5d                   	pop    %ebp
801038c9:	c3                   	ret    

801038ca <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801038ca:	55                   	push   %ebp
801038cb:	89 e5                	mov    %esp,%ebp
801038cd:	8b 45 08             	mov    0x8(%ebp),%eax
801038d0:	05 00 00 00 80       	add    $0x80000000,%eax
801038d5:	5d                   	pop    %ebp
801038d6:	c3                   	ret    

801038d7 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801038d7:	55                   	push   %ebp
801038d8:	89 e5                	mov    %esp,%ebp
801038da:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801038dd:	8b 55 08             	mov    0x8(%ebp),%edx
801038e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801038e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
801038e6:	f0 87 02             	lock xchg %eax,(%edx)
801038e9:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801038ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801038ef:	c9                   	leave  
801038f0:	c3                   	ret    

801038f1 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801038f1:	55                   	push   %ebp
801038f2:	89 e5                	mov    %esp,%ebp
801038f4:	83 e4 f0             	and    $0xfffffff0,%esp
801038f7:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801038fa:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103901:	80 
80103902:	c7 04 24 b8 51 11 80 	movl   $0x801151b8,(%esp)
80103909:	e8 80 f2 ff ff       	call   80102b8e <kinit1>
  seginit();       // set up segments
8010390e:	e8 c7 3e 00 00       	call   801077da <seginit>
  kvmalloc(cpu);   // kernel page table
80103913:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103919:	89 04 24             	mov    %eax,(%esp)
8010391c:	e8 62 45 00 00       	call   80107e83 <kvmalloc>
  mpinit();        // collect info about this machine
80103921:	e8 56 04 00 00       	call   80103d7c <mpinit>
  lapicinit();
80103926:	e8 ce f5 ff ff       	call   80102ef9 <lapicinit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
8010392b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103931:	0f b6 00             	movzbl (%eax),%eax
80103934:	0f b6 c0             	movzbl %al,%eax
80103937:	89 44 24 04          	mov    %eax,0x4(%esp)
8010393b:	c7 04 24 d0 89 10 80 	movl   $0x801089d0,(%esp)
80103942:	e8 59 ca ff ff       	call   801003a0 <cprintf>
  picinit();       // interrupt controller
80103947:	e8 8e 06 00 00       	call   80103fda <picinit>
  ioapicinit();    // another interrupt controller
8010394c:	e8 33 f1 ff ff       	call   80102a84 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103951:	e8 d3 d2 ff ff       	call   80100c29 <consoleinit>
  uartinit();      // serial port
80103956:	e8 ce 31 00 00       	call   80106b29 <uartinit>
  pinit();         // process table
8010395b:	e8 84 0b 00 00       	call   801044e4 <pinit>
  tvinit();        // trap vectors
80103960:	e8 59 2d 00 00       	call   801066be <tvinit>
  binit();         // buffer cache
80103965:	e8 ca c6 ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010396a:	e8 75 d7 ff ff       	call   801010e4 <fileinit>
  iinit();         // inode cache
8010396f:	e8 0a de ff ff       	call   8010177e <iinit>
  ideinit();       // disk
80103974:	e8 74 ed ff ff       	call   801026ed <ideinit>
  if(!ismp)
80103979:	a1 44 23 11 80       	mov    0x80112344,%eax
8010397e:	85 c0                	test   %eax,%eax
80103980:	75 05                	jne    80103987 <main+0x96>
    timerinit();   // uniprocessor timer
80103982:	e8 82 2c 00 00       	call   80106609 <timerinit>
  startothers();   // start other processors
80103987:	e8 94 00 00 00       	call   80103a20 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
8010398c:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103993:	8e 
80103994:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
8010399b:	e8 26 f2 ff ff       	call   80102bc6 <kinit2>
  userinit();      // first user process
801039a0:	e8 5a 0c 00 00       	call   801045ff <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801039a5:	e8 2f 00 00 00       	call   801039d9 <mpmain>

801039aa <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801039aa:	55                   	push   %ebp
801039ab:	89 e5                	mov    %esp,%ebp
801039ad:	83 ec 18             	sub    $0x18,%esp
  switchkvm(&cpus[0]); 
801039b0:	c7 04 24 60 23 11 80 	movl   $0x80112360,(%esp)
801039b7:	e8 e5 44 00 00       	call   80107ea1 <switchkvm>
  seginit();
801039bc:	e8 19 3e 00 00       	call   801077da <seginit>
  kvmalloc(cpu);
801039c1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801039c7:	89 04 24             	mov    %eax,(%esp)
801039ca:	e8 b4 44 00 00       	call   80107e83 <kvmalloc>
  lapicinit();
801039cf:	e8 25 f5 ff ff       	call   80102ef9 <lapicinit>
  mpmain();
801039d4:	e8 00 00 00 00       	call   801039d9 <mpmain>

801039d9 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801039d9:	55                   	push   %ebp
801039da:	89 e5                	mov    %esp,%ebp
801039dc:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801039df:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801039e5:	0f b6 00             	movzbl (%eax),%eax
801039e8:	0f b6 c0             	movzbl %al,%eax
801039eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801039ef:	c7 04 24 e7 89 10 80 	movl   $0x801089e7,(%esp)
801039f6:	e8 a5 c9 ff ff       	call   801003a0 <cprintf>
  idtinit();       // load idt register
801039fb:	e8 32 2e 00 00       	call   80106832 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103a00:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103a06:	05 ac 00 00 00       	add    $0xac,%eax
80103a0b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103a12:	00 
80103a13:	89 04 24             	mov    %eax,(%esp)
80103a16:	e8 bc fe ff ff       	call   801038d7 <xchg>
  scheduler();     // start running processes
80103a1b:	e8 71 11 00 00       	call   80104b91 <scheduler>

80103a20 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103a20:	55                   	push   %ebp
80103a21:	89 e5                	mov    %esp,%ebp
80103a23:	53                   	push   %ebx
80103a24:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103a27:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
80103a2e:	e8 97 fe ff ff       	call   801038ca <p2v>
80103a33:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103a36:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103a3b:	89 44 24 08          	mov    %eax,0x8(%esp)
80103a3f:	c7 44 24 04 0c b5 10 	movl   $0x8010b50c,0x4(%esp)
80103a46:	80 
80103a47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a4a:	89 04 24             	mov    %eax,(%esp)
80103a4d:	e8 e2 18 00 00       	call   80105334 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103a52:	c7 45 f4 60 23 11 80 	movl   $0x80112360,-0xc(%ebp)
80103a59:	e9 85 00 00 00       	jmp    80103ae3 <startothers+0xc3>
    if(c == cpus+cpunum())  // We've started already.
80103a5e:	e8 ef f5 ff ff       	call   80103052 <cpunum>
80103a63:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80103a69:	05 60 23 11 80       	add    $0x80112360,%eax
80103a6e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a71:	75 02                	jne    80103a75 <startothers+0x55>
      continue;
80103a73:	eb 67                	jmp    80103adc <startothers+0xbc>

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103a75:	e8 42 f2 ff ff       	call   80102cbc <kalloc>
80103a7a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103a7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a80:	83 e8 04             	sub    $0x4,%eax
80103a83:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a86:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103a8c:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103a8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a91:	83 e8 08             	sub    $0x8,%eax
80103a94:	c7 00 aa 39 10 80    	movl   $0x801039aa,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103a9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a9d:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103aa0:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
80103aa7:	e8 11 fe ff ff       	call   801038bd <v2p>
80103aac:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ab1:	89 04 24             	mov    %eax,(%esp)
80103ab4:	e8 04 fe ff ff       	call   801038bd <v2p>
80103ab9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103abc:	0f b6 12             	movzbl (%edx),%edx
80103abf:	0f b6 d2             	movzbl %dl,%edx
80103ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ac6:	89 14 24             	mov    %edx,(%esp)
80103ac9:	e8 06 f6 ff ff       	call   801030d4 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103ace:	90                   	nop
80103acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad2:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103ad8:	85 c0                	test   %eax,%eax
80103ada:	74 f3                	je     80103acf <startothers+0xaf>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103adc:	81 45 f4 cc 00 00 00 	addl   $0xcc,-0xc(%ebp)
80103ae3:	a1 c0 29 11 80       	mov    0x801129c0,%eax
80103ae8:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80103aee:	05 60 23 11 80       	add    $0x80112360,%eax
80103af3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103af6:	0f 87 62 ff ff ff    	ja     80103a5e <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103afc:	83 c4 24             	add    $0x24,%esp
80103aff:	5b                   	pop    %ebx
80103b00:	5d                   	pop    %ebp
80103b01:	c3                   	ret    

80103b02 <p2v>:
80103b02:	55                   	push   %ebp
80103b03:	89 e5                	mov    %esp,%ebp
80103b05:	8b 45 08             	mov    0x8(%ebp),%eax
80103b08:	05 00 00 00 80       	add    $0x80000000,%eax
80103b0d:	5d                   	pop    %ebp
80103b0e:	c3                   	ret    

80103b0f <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103b0f:	55                   	push   %ebp
80103b10:	89 e5                	mov    %esp,%ebp
80103b12:	83 ec 14             	sub    $0x14,%esp
80103b15:	8b 45 08             	mov    0x8(%ebp),%eax
80103b18:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103b1c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103b20:	89 c2                	mov    %eax,%edx
80103b22:	ec                   	in     (%dx),%al
80103b23:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103b26:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103b2a:	c9                   	leave  
80103b2b:	c3                   	ret    

80103b2c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103b2c:	55                   	push   %ebp
80103b2d:	89 e5                	mov    %esp,%ebp
80103b2f:	83 ec 08             	sub    $0x8,%esp
80103b32:	8b 55 08             	mov    0x8(%ebp),%edx
80103b35:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b38:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103b3c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103b3f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103b43:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103b47:	ee                   	out    %al,(%dx)
}
80103b48:	c9                   	leave  
80103b49:	c3                   	ret    

80103b4a <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103b4a:	55                   	push   %ebp
80103b4b:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103b4d:	a1 44 b6 10 80       	mov    0x8010b644,%eax
80103b52:	89 c2                	mov    %eax,%edx
80103b54:	b8 60 23 11 80       	mov    $0x80112360,%eax
80103b59:	29 c2                	sub    %eax,%edx
80103b5b:	89 d0                	mov    %edx,%eax
80103b5d:	c1 f8 02             	sar    $0x2,%eax
80103b60:	69 c0 fb fa fa fa    	imul   $0xfafafafb,%eax,%eax
}
80103b66:	5d                   	pop    %ebp
80103b67:	c3                   	ret    

80103b68 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103b68:	55                   	push   %ebp
80103b69:	89 e5                	mov    %esp,%ebp
80103b6b:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103b6e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b75:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103b7c:	eb 15                	jmp    80103b93 <sum+0x2b>
    sum += addr[i];
80103b7e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b81:	8b 45 08             	mov    0x8(%ebp),%eax
80103b84:	01 d0                	add    %edx,%eax
80103b86:	0f b6 00             	movzbl (%eax),%eax
80103b89:	0f b6 c0             	movzbl %al,%eax
80103b8c:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103b8f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103b93:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b96:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b99:	7c e3                	jl     80103b7e <sum+0x16>
    sum += addr[i];
  return sum;
80103b9b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b9e:	c9                   	leave  
80103b9f:	c3                   	ret    

80103ba0 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103ba0:	55                   	push   %ebp
80103ba1:	89 e5                	mov    %esp,%ebp
80103ba3:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103ba6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ba9:	89 04 24             	mov    %eax,(%esp)
80103bac:	e8 51 ff ff ff       	call   80103b02 <p2v>
80103bb1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103bb4:	8b 55 0c             	mov    0xc(%ebp),%edx
80103bb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bba:	01 d0                	add    %edx,%eax
80103bbc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103bc5:	eb 3f                	jmp    80103c06 <mpsearch1+0x66>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103bc7:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103bce:	00 
80103bcf:	c7 44 24 04 f8 89 10 	movl   $0x801089f8,0x4(%esp)
80103bd6:	80 
80103bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bda:	89 04 24             	mov    %eax,(%esp)
80103bdd:	e8 fa 16 00 00       	call   801052dc <memcmp>
80103be2:	85 c0                	test   %eax,%eax
80103be4:	75 1c                	jne    80103c02 <mpsearch1+0x62>
80103be6:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103bed:	00 
80103bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf1:	89 04 24             	mov    %eax,(%esp)
80103bf4:	e8 6f ff ff ff       	call   80103b68 <sum>
80103bf9:	84 c0                	test   %al,%al
80103bfb:	75 05                	jne    80103c02 <mpsearch1+0x62>
      return (struct mp*)p;
80103bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c00:	eb 11                	jmp    80103c13 <mpsearch1+0x73>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103c02:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c09:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103c0c:	72 b9                	jb     80103bc7 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103c0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103c13:	c9                   	leave  
80103c14:	c3                   	ret    

80103c15 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103c15:	55                   	push   %ebp
80103c16:	89 e5                	mov    %esp,%ebp
80103c18:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103c1b:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c25:	83 c0 0f             	add    $0xf,%eax
80103c28:	0f b6 00             	movzbl (%eax),%eax
80103c2b:	0f b6 c0             	movzbl %al,%eax
80103c2e:	c1 e0 08             	shl    $0x8,%eax
80103c31:	89 c2                	mov    %eax,%edx
80103c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c36:	83 c0 0e             	add    $0xe,%eax
80103c39:	0f b6 00             	movzbl (%eax),%eax
80103c3c:	0f b6 c0             	movzbl %al,%eax
80103c3f:	09 d0                	or     %edx,%eax
80103c41:	c1 e0 04             	shl    $0x4,%eax
80103c44:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c47:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c4b:	74 21                	je     80103c6e <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103c4d:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103c54:	00 
80103c55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c58:	89 04 24             	mov    %eax,(%esp)
80103c5b:	e8 40 ff ff ff       	call   80103ba0 <mpsearch1>
80103c60:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c63:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c67:	74 50                	je     80103cb9 <mpsearch+0xa4>
      return mp;
80103c69:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c6c:	eb 5f                	jmp    80103ccd <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c71:	83 c0 14             	add    $0x14,%eax
80103c74:	0f b6 00             	movzbl (%eax),%eax
80103c77:	0f b6 c0             	movzbl %al,%eax
80103c7a:	c1 e0 08             	shl    $0x8,%eax
80103c7d:	89 c2                	mov    %eax,%edx
80103c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c82:	83 c0 13             	add    $0x13,%eax
80103c85:	0f b6 00             	movzbl (%eax),%eax
80103c88:	0f b6 c0             	movzbl %al,%eax
80103c8b:	09 d0                	or     %edx,%eax
80103c8d:	c1 e0 0a             	shl    $0xa,%eax
80103c90:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103c93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c96:	2d 00 04 00 00       	sub    $0x400,%eax
80103c9b:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103ca2:	00 
80103ca3:	89 04 24             	mov    %eax,(%esp)
80103ca6:	e8 f5 fe ff ff       	call   80103ba0 <mpsearch1>
80103cab:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103cae:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103cb2:	74 05                	je     80103cb9 <mpsearch+0xa4>
      return mp;
80103cb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cb7:	eb 14                	jmp    80103ccd <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103cb9:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103cc0:	00 
80103cc1:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103cc8:	e8 d3 fe ff ff       	call   80103ba0 <mpsearch1>
}
80103ccd:	c9                   	leave  
80103cce:	c3                   	ret    

80103ccf <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103ccf:	55                   	push   %ebp
80103cd0:	89 e5                	mov    %esp,%ebp
80103cd2:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103cd5:	e8 3b ff ff ff       	call   80103c15 <mpsearch>
80103cda:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cdd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ce1:	74 0a                	je     80103ced <mpconfig+0x1e>
80103ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce6:	8b 40 04             	mov    0x4(%eax),%eax
80103ce9:	85 c0                	test   %eax,%eax
80103ceb:	75 0a                	jne    80103cf7 <mpconfig+0x28>
    return 0;
80103ced:	b8 00 00 00 00       	mov    $0x0,%eax
80103cf2:	e9 83 00 00 00       	jmp    80103d7a <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cfa:	8b 40 04             	mov    0x4(%eax),%eax
80103cfd:	89 04 24             	mov    %eax,(%esp)
80103d00:	e8 fd fd ff ff       	call   80103b02 <p2v>
80103d05:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103d08:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103d0f:	00 
80103d10:	c7 44 24 04 fd 89 10 	movl   $0x801089fd,0x4(%esp)
80103d17:	80 
80103d18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d1b:	89 04 24             	mov    %eax,(%esp)
80103d1e:	e8 b9 15 00 00       	call   801052dc <memcmp>
80103d23:	85 c0                	test   %eax,%eax
80103d25:	74 07                	je     80103d2e <mpconfig+0x5f>
    return 0;
80103d27:	b8 00 00 00 00       	mov    $0x0,%eax
80103d2c:	eb 4c                	jmp    80103d7a <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103d2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d31:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103d35:	3c 01                	cmp    $0x1,%al
80103d37:	74 12                	je     80103d4b <mpconfig+0x7c>
80103d39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d3c:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103d40:	3c 04                	cmp    $0x4,%al
80103d42:	74 07                	je     80103d4b <mpconfig+0x7c>
    return 0;
80103d44:	b8 00 00 00 00       	mov    $0x0,%eax
80103d49:	eb 2f                	jmp    80103d7a <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103d4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d4e:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d52:	0f b7 c0             	movzwl %ax,%eax
80103d55:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d5c:	89 04 24             	mov    %eax,(%esp)
80103d5f:	e8 04 fe ff ff       	call   80103b68 <sum>
80103d64:	84 c0                	test   %al,%al
80103d66:	74 07                	je     80103d6f <mpconfig+0xa0>
    return 0;
80103d68:	b8 00 00 00 00       	mov    $0x0,%eax
80103d6d:	eb 0b                	jmp    80103d7a <mpconfig+0xab>
  *pmp = mp;
80103d6f:	8b 45 08             	mov    0x8(%ebp),%eax
80103d72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d75:	89 10                	mov    %edx,(%eax)
  return conf;
80103d77:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103d7a:	c9                   	leave  
80103d7b:	c3                   	ret    

80103d7c <mpinit>:

void
mpinit(void)
{
80103d7c:	55                   	push   %ebp
80103d7d:	89 e5                	mov    %esp,%ebp
80103d7f:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103d82:	c7 05 44 b6 10 80 60 	movl   $0x80112360,0x8010b644
80103d89:	23 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103d8c:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103d8f:	89 04 24             	mov    %eax,(%esp)
80103d92:	e8 38 ff ff ff       	call   80103ccf <mpconfig>
80103d97:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d9e:	75 05                	jne    80103da5 <mpinit+0x29>
    return;
80103da0:	e9 9c 01 00 00       	jmp    80103f41 <mpinit+0x1c5>
  ismp = 1;
80103da5:	c7 05 44 23 11 80 01 	movl   $0x1,0x80112344
80103dac:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103db2:	8b 40 24             	mov    0x24(%eax),%eax
80103db5:	a3 5c 22 11 80       	mov    %eax,0x8011225c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103dba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dbd:	83 c0 2c             	add    $0x2c,%eax
80103dc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103dc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dc6:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103dca:	0f b7 d0             	movzwl %ax,%edx
80103dcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dd0:	01 d0                	add    %edx,%eax
80103dd2:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103dd5:	e9 f4 00 00 00       	jmp    80103ece <mpinit+0x152>
    switch(*p){
80103dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ddd:	0f b6 00             	movzbl (%eax),%eax
80103de0:	0f b6 c0             	movzbl %al,%eax
80103de3:	83 f8 04             	cmp    $0x4,%eax
80103de6:	0f 87 bf 00 00 00    	ja     80103eab <mpinit+0x12f>
80103dec:	8b 04 85 40 8a 10 80 	mov    -0x7fef75c0(,%eax,4),%eax
80103df3:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103df5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103df8:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103dfb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103dfe:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e02:	0f b6 d0             	movzbl %al,%edx
80103e05:	a1 c0 29 11 80       	mov    0x801129c0,%eax
80103e0a:	39 c2                	cmp    %eax,%edx
80103e0c:	74 2d                	je     80103e3b <mpinit+0xbf>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103e0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e11:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e15:	0f b6 d0             	movzbl %al,%edx
80103e18:	a1 c0 29 11 80       	mov    0x801129c0,%eax
80103e1d:	89 54 24 08          	mov    %edx,0x8(%esp)
80103e21:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e25:	c7 04 24 02 8a 10 80 	movl   $0x80108a02,(%esp)
80103e2c:	e8 6f c5 ff ff       	call   801003a0 <cprintf>
        ismp = 0;
80103e31:	c7 05 44 23 11 80 00 	movl   $0x0,0x80112344
80103e38:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103e3b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e3e:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103e42:	0f b6 c0             	movzbl %al,%eax
80103e45:	83 e0 02             	and    $0x2,%eax
80103e48:	85 c0                	test   %eax,%eax
80103e4a:	74 15                	je     80103e61 <mpinit+0xe5>
        bcpu = &cpus[ncpu];
80103e4c:	a1 c0 29 11 80       	mov    0x801129c0,%eax
80103e51:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80103e57:	05 60 23 11 80       	add    $0x80112360,%eax
80103e5c:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103e61:	8b 15 c0 29 11 80    	mov    0x801129c0,%edx
80103e67:	a1 c0 29 11 80       	mov    0x801129c0,%eax
80103e6c:	69 d2 cc 00 00 00    	imul   $0xcc,%edx,%edx
80103e72:	81 c2 60 23 11 80    	add    $0x80112360,%edx
80103e78:	88 02                	mov    %al,(%edx)
      ncpu++;
80103e7a:	a1 c0 29 11 80       	mov    0x801129c0,%eax
80103e7f:	83 c0 01             	add    $0x1,%eax
80103e82:	a3 c0 29 11 80       	mov    %eax,0x801129c0
      p += sizeof(struct mpproc);
80103e87:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103e8b:	eb 41                	jmp    80103ece <mpinit+0x152>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e90:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103e93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103e96:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e9a:	a2 40 23 11 80       	mov    %al,0x80112340
      p += sizeof(struct mpioapic);
80103e9f:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103ea3:	eb 29                	jmp    80103ece <mpinit+0x152>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103ea5:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103ea9:	eb 23                	jmp    80103ece <mpinit+0x152>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eae:	0f b6 00             	movzbl (%eax),%eax
80103eb1:	0f b6 c0             	movzbl %al,%eax
80103eb4:	89 44 24 04          	mov    %eax,0x4(%esp)
80103eb8:	c7 04 24 20 8a 10 80 	movl   $0x80108a20,(%esp)
80103ebf:	e8 dc c4 ff ff       	call   801003a0 <cprintf>
      ismp = 0;
80103ec4:	c7 05 44 23 11 80 00 	movl   $0x0,0x80112344
80103ecb:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ed1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103ed4:	0f 82 00 ff ff ff    	jb     80103dda <mpinit+0x5e>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103eda:	a1 44 23 11 80       	mov    0x80112344,%eax
80103edf:	85 c0                	test   %eax,%eax
80103ee1:	75 1d                	jne    80103f00 <mpinit+0x184>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103ee3:	c7 05 c0 29 11 80 01 	movl   $0x1,0x801129c0
80103eea:	00 00 00 
    lapic = 0;
80103eed:	c7 05 5c 22 11 80 00 	movl   $0x0,0x8011225c
80103ef4:	00 00 00 
    ioapicid = 0;
80103ef7:	c6 05 40 23 11 80 00 	movb   $0x0,0x80112340
    return;
80103efe:	eb 41                	jmp    80103f41 <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103f00:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f03:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103f07:	84 c0                	test   %al,%al
80103f09:	74 36                	je     80103f41 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103f0b:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103f12:	00 
80103f13:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103f1a:	e8 0d fc ff ff       	call   80103b2c <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103f1f:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103f26:	e8 e4 fb ff ff       	call   80103b0f <inb>
80103f2b:	83 c8 01             	or     $0x1,%eax
80103f2e:	0f b6 c0             	movzbl %al,%eax
80103f31:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f35:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103f3c:	e8 eb fb ff ff       	call   80103b2c <outb>
  }
}
80103f41:	c9                   	leave  
80103f42:	c3                   	ret    

80103f43 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103f43:	55                   	push   %ebp
80103f44:	89 e5                	mov    %esp,%ebp
80103f46:	83 ec 08             	sub    $0x8,%esp
80103f49:	8b 55 08             	mov    0x8(%ebp),%edx
80103f4c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f4f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103f53:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103f56:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103f5a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103f5e:	ee                   	out    %al,(%dx)
}
80103f5f:	c9                   	leave  
80103f60:	c3                   	ret    

80103f61 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103f61:	55                   	push   %ebp
80103f62:	89 e5                	mov    %esp,%ebp
80103f64:	83 ec 0c             	sub    $0xc,%esp
80103f67:	8b 45 08             	mov    0x8(%ebp),%eax
80103f6a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103f6e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f72:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103f78:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f7c:	0f b6 c0             	movzbl %al,%eax
80103f7f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f83:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103f8a:	e8 b4 ff ff ff       	call   80103f43 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103f8f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f93:	66 c1 e8 08          	shr    $0x8,%ax
80103f97:	0f b6 c0             	movzbl %al,%eax
80103f9a:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f9e:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103fa5:	e8 99 ff ff ff       	call   80103f43 <outb>
}
80103faa:	c9                   	leave  
80103fab:	c3                   	ret    

80103fac <picenable>:

void
picenable(int irq)
{
80103fac:	55                   	push   %ebp
80103fad:	89 e5                	mov    %esp,%ebp
80103faf:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103fb2:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb5:	ba 01 00 00 00       	mov    $0x1,%edx
80103fba:	89 c1                	mov    %eax,%ecx
80103fbc:	d3 e2                	shl    %cl,%edx
80103fbe:	89 d0                	mov    %edx,%eax
80103fc0:	f7 d0                	not    %eax
80103fc2:	89 c2                	mov    %eax,%edx
80103fc4:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103fcb:	21 d0                	and    %edx,%eax
80103fcd:	0f b7 c0             	movzwl %ax,%eax
80103fd0:	89 04 24             	mov    %eax,(%esp)
80103fd3:	e8 89 ff ff ff       	call   80103f61 <picsetmask>
}
80103fd8:	c9                   	leave  
80103fd9:	c3                   	ret    

80103fda <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103fda:	55                   	push   %ebp
80103fdb:	89 e5                	mov    %esp,%ebp
80103fdd:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103fe0:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103fe7:	00 
80103fe8:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103fef:	e8 4f ff ff ff       	call   80103f43 <outb>
  outb(IO_PIC2+1, 0xFF);
80103ff4:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103ffb:	00 
80103ffc:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80104003:	e8 3b ff ff ff       	call   80103f43 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80104008:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
8010400f:	00 
80104010:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80104017:	e8 27 ff ff ff       	call   80103f43 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
8010401c:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80104023:	00 
80104024:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
8010402b:	e8 13 ff ff ff       	call   80103f43 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80104030:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80104037:	00 
80104038:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
8010403f:	e8 ff fe ff ff       	call   80103f43 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80104044:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010404b:	00 
8010404c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80104053:	e8 eb fe ff ff       	call   80103f43 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80104058:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
8010405f:	00 
80104060:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80104067:	e8 d7 fe ff ff       	call   80103f43 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
8010406c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80104073:	00 
80104074:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
8010407b:	e8 c3 fe ff ff       	call   80103f43 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80104080:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80104087:	00 
80104088:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
8010408f:	e8 af fe ff ff       	call   80103f43 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80104094:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010409b:	00 
8010409c:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
801040a3:	e8 9b fe ff ff       	call   80103f43 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
801040a8:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
801040af:	00 
801040b0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801040b7:	e8 87 fe ff ff       	call   80103f43 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
801040bc:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
801040c3:	00 
801040c4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801040cb:	e8 73 fe ff ff       	call   80103f43 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
801040d0:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
801040d7:	00 
801040d8:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
801040df:	e8 5f fe ff ff       	call   80103f43 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
801040e4:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
801040eb:	00 
801040ec:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
801040f3:	e8 4b fe ff ff       	call   80103f43 <outb>

  if(irqmask != 0xFFFF)
801040f8:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
801040ff:	66 83 f8 ff          	cmp    $0xffff,%ax
80104103:	74 12                	je     80104117 <picinit+0x13d>
    picsetmask(irqmask);
80104105:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
8010410c:	0f b7 c0             	movzwl %ax,%eax
8010410f:	89 04 24             	mov    %eax,(%esp)
80104112:	e8 4a fe ff ff       	call   80103f61 <picsetmask>
}
80104117:	c9                   	leave  
80104118:	c3                   	ret    

80104119 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104119:	55                   	push   %ebp
8010411a:	89 e5                	mov    %esp,%ebp
8010411c:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
8010411f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104126:	8b 45 0c             	mov    0xc(%ebp),%eax
80104129:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010412f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104132:	8b 10                	mov    (%eax),%edx
80104134:	8b 45 08             	mov    0x8(%ebp),%eax
80104137:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104139:	e8 c2 cf ff ff       	call   80101100 <filealloc>
8010413e:	8b 55 08             	mov    0x8(%ebp),%edx
80104141:	89 02                	mov    %eax,(%edx)
80104143:	8b 45 08             	mov    0x8(%ebp),%eax
80104146:	8b 00                	mov    (%eax),%eax
80104148:	85 c0                	test   %eax,%eax
8010414a:	0f 84 c8 00 00 00    	je     80104218 <pipealloc+0xff>
80104150:	e8 ab cf ff ff       	call   80101100 <filealloc>
80104155:	8b 55 0c             	mov    0xc(%ebp),%edx
80104158:	89 02                	mov    %eax,(%edx)
8010415a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010415d:	8b 00                	mov    (%eax),%eax
8010415f:	85 c0                	test   %eax,%eax
80104161:	0f 84 b1 00 00 00    	je     80104218 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104167:	e8 50 eb ff ff       	call   80102cbc <kalloc>
8010416c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010416f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104173:	75 05                	jne    8010417a <pipealloc+0x61>
    goto bad;
80104175:	e9 9e 00 00 00       	jmp    80104218 <pipealloc+0xff>
  p->readopen = 1;
8010417a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010417d:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104184:	00 00 00 
  p->writeopen = 1;
80104187:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010418a:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104191:	00 00 00 
  p->nwrite = 0;
80104194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104197:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010419e:	00 00 00 
  p->nread = 0;
801041a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a4:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801041ab:	00 00 00 
  initlock(&p->lock, "pipe");
801041ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b1:	c7 44 24 04 54 8a 10 	movl   $0x80108a54,0x4(%esp)
801041b8:	80 
801041b9:	89 04 24             	mov    %eax,(%esp)
801041bc:	e8 2f 0e 00 00       	call   80104ff0 <initlock>
  (*f0)->type = FD_PIPE;
801041c1:	8b 45 08             	mov    0x8(%ebp),%eax
801041c4:	8b 00                	mov    (%eax),%eax
801041c6:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801041cc:	8b 45 08             	mov    0x8(%ebp),%eax
801041cf:	8b 00                	mov    (%eax),%eax
801041d1:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801041d5:	8b 45 08             	mov    0x8(%ebp),%eax
801041d8:	8b 00                	mov    (%eax),%eax
801041da:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801041de:	8b 45 08             	mov    0x8(%ebp),%eax
801041e1:	8b 00                	mov    (%eax),%eax
801041e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041e6:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
801041e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801041ec:	8b 00                	mov    (%eax),%eax
801041ee:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801041f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801041f7:	8b 00                	mov    (%eax),%eax
801041f9:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801041fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80104200:	8b 00                	mov    (%eax),%eax
80104202:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104206:	8b 45 0c             	mov    0xc(%ebp),%eax
80104209:	8b 00                	mov    (%eax),%eax
8010420b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010420e:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104211:	b8 00 00 00 00       	mov    $0x0,%eax
80104216:	eb 42                	jmp    8010425a <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80104218:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010421c:	74 0b                	je     80104229 <pipealloc+0x110>
    kfree((char*)p);
8010421e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104221:	89 04 24             	mov    %eax,(%esp)
80104224:	e8 fa e9 ff ff       	call   80102c23 <kfree>
  if(*f0)
80104229:	8b 45 08             	mov    0x8(%ebp),%eax
8010422c:	8b 00                	mov    (%eax),%eax
8010422e:	85 c0                	test   %eax,%eax
80104230:	74 0d                	je     8010423f <pipealloc+0x126>
    fileclose(*f0);
80104232:	8b 45 08             	mov    0x8(%ebp),%eax
80104235:	8b 00                	mov    (%eax),%eax
80104237:	89 04 24             	mov    %eax,(%esp)
8010423a:	e8 69 cf ff ff       	call   801011a8 <fileclose>
  if(*f1)
8010423f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104242:	8b 00                	mov    (%eax),%eax
80104244:	85 c0                	test   %eax,%eax
80104246:	74 0d                	je     80104255 <pipealloc+0x13c>
    fileclose(*f1);
80104248:	8b 45 0c             	mov    0xc(%ebp),%eax
8010424b:	8b 00                	mov    (%eax),%eax
8010424d:	89 04 24             	mov    %eax,(%esp)
80104250:	e8 53 cf ff ff       	call   801011a8 <fileclose>
  return -1;
80104255:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010425a:	c9                   	leave  
8010425b:	c3                   	ret    

8010425c <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010425c:	55                   	push   %ebp
8010425d:	89 e5                	mov    %esp,%ebp
8010425f:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104262:	8b 45 08             	mov    0x8(%ebp),%eax
80104265:	89 04 24             	mov    %eax,(%esp)
80104268:	e8 a4 0d 00 00       	call   80105011 <acquire>
  if(writable){
8010426d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104271:	74 1f                	je     80104292 <pipeclose+0x36>
    p->writeopen = 0;
80104273:	8b 45 08             	mov    0x8(%ebp),%eax
80104276:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
8010427d:	00 00 00 
    wakeup(&p->nread);
80104280:	8b 45 08             	mov    0x8(%ebp),%eax
80104283:	05 34 02 00 00       	add    $0x234,%eax
80104288:	89 04 24             	mov    %eax,(%esp)
8010428b:	e8 90 0b 00 00       	call   80104e20 <wakeup>
80104290:	eb 1d                	jmp    801042af <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104292:	8b 45 08             	mov    0x8(%ebp),%eax
80104295:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010429c:	00 00 00 
    wakeup(&p->nwrite);
8010429f:	8b 45 08             	mov    0x8(%ebp),%eax
801042a2:	05 38 02 00 00       	add    $0x238,%eax
801042a7:	89 04 24             	mov    %eax,(%esp)
801042aa:	e8 71 0b 00 00       	call   80104e20 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
801042af:	8b 45 08             	mov    0x8(%ebp),%eax
801042b2:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801042b8:	85 c0                	test   %eax,%eax
801042ba:	75 25                	jne    801042e1 <pipeclose+0x85>
801042bc:	8b 45 08             	mov    0x8(%ebp),%eax
801042bf:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042c5:	85 c0                	test   %eax,%eax
801042c7:	75 18                	jne    801042e1 <pipeclose+0x85>
    release(&p->lock);
801042c9:	8b 45 08             	mov    0x8(%ebp),%eax
801042cc:	89 04 24             	mov    %eax,(%esp)
801042cf:	e8 9f 0d 00 00       	call   80105073 <release>
    kfree((char*)p);
801042d4:	8b 45 08             	mov    0x8(%ebp),%eax
801042d7:	89 04 24             	mov    %eax,(%esp)
801042da:	e8 44 e9 ff ff       	call   80102c23 <kfree>
801042df:	eb 0b                	jmp    801042ec <pipeclose+0x90>
  } else
    release(&p->lock);
801042e1:	8b 45 08             	mov    0x8(%ebp),%eax
801042e4:	89 04 24             	mov    %eax,(%esp)
801042e7:	e8 87 0d 00 00       	call   80105073 <release>
}
801042ec:	c9                   	leave  
801042ed:	c3                   	ret    

801042ee <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801042ee:	55                   	push   %ebp
801042ef:	89 e5                	mov    %esp,%ebp
801042f1:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
801042f4:	8b 45 08             	mov    0x8(%ebp),%eax
801042f7:	89 04 24             	mov    %eax,(%esp)
801042fa:	e8 12 0d 00 00       	call   80105011 <acquire>
  for(i = 0; i < n; i++){
801042ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104306:	e9 a6 00 00 00       	jmp    801043b1 <pipewrite+0xc3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010430b:	eb 57                	jmp    80104364 <pipewrite+0x76>
      if(p->readopen == 0 || proc->killed){
8010430d:	8b 45 08             	mov    0x8(%ebp),%eax
80104310:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104316:	85 c0                	test   %eax,%eax
80104318:	74 0d                	je     80104327 <pipewrite+0x39>
8010431a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104320:	8b 40 24             	mov    0x24(%eax),%eax
80104323:	85 c0                	test   %eax,%eax
80104325:	74 15                	je     8010433c <pipewrite+0x4e>
        release(&p->lock);
80104327:	8b 45 08             	mov    0x8(%ebp),%eax
8010432a:	89 04 24             	mov    %eax,(%esp)
8010432d:	e8 41 0d 00 00       	call   80105073 <release>
        return -1;
80104332:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104337:	e9 9f 00 00 00       	jmp    801043db <pipewrite+0xed>
      }
      wakeup(&p->nread);
8010433c:	8b 45 08             	mov    0x8(%ebp),%eax
8010433f:	05 34 02 00 00       	add    $0x234,%eax
80104344:	89 04 24             	mov    %eax,(%esp)
80104347:	e8 d4 0a 00 00       	call   80104e20 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010434c:	8b 45 08             	mov    0x8(%ebp),%eax
8010434f:	8b 55 08             	mov    0x8(%ebp),%edx
80104352:	81 c2 38 02 00 00    	add    $0x238,%edx
80104358:	89 44 24 04          	mov    %eax,0x4(%esp)
8010435c:	89 14 24             	mov    %edx,(%esp)
8010435f:	e8 e3 09 00 00       	call   80104d47 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104364:	8b 45 08             	mov    0x8(%ebp),%eax
80104367:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010436d:	8b 45 08             	mov    0x8(%ebp),%eax
80104370:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104376:	05 00 02 00 00       	add    $0x200,%eax
8010437b:	39 c2                	cmp    %eax,%edx
8010437d:	74 8e                	je     8010430d <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010437f:	8b 45 08             	mov    0x8(%ebp),%eax
80104382:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104388:	8d 48 01             	lea    0x1(%eax),%ecx
8010438b:	8b 55 08             	mov    0x8(%ebp),%edx
8010438e:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104394:	25 ff 01 00 00       	and    $0x1ff,%eax
80104399:	89 c1                	mov    %eax,%ecx
8010439b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010439e:	8b 45 0c             	mov    0xc(%ebp),%eax
801043a1:	01 d0                	add    %edx,%eax
801043a3:	0f b6 10             	movzbl (%eax),%edx
801043a6:	8b 45 08             	mov    0x8(%ebp),%eax
801043a9:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801043ad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801043b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b4:	3b 45 10             	cmp    0x10(%ebp),%eax
801043b7:	0f 8c 4e ff ff ff    	jl     8010430b <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801043bd:	8b 45 08             	mov    0x8(%ebp),%eax
801043c0:	05 34 02 00 00       	add    $0x234,%eax
801043c5:	89 04 24             	mov    %eax,(%esp)
801043c8:	e8 53 0a 00 00       	call   80104e20 <wakeup>
  release(&p->lock);
801043cd:	8b 45 08             	mov    0x8(%ebp),%eax
801043d0:	89 04 24             	mov    %eax,(%esp)
801043d3:	e8 9b 0c 00 00       	call   80105073 <release>
  return n;
801043d8:	8b 45 10             	mov    0x10(%ebp),%eax
}
801043db:	c9                   	leave  
801043dc:	c3                   	ret    

801043dd <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801043dd:	55                   	push   %ebp
801043de:	89 e5                	mov    %esp,%ebp
801043e0:	53                   	push   %ebx
801043e1:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
801043e4:	8b 45 08             	mov    0x8(%ebp),%eax
801043e7:	89 04 24             	mov    %eax,(%esp)
801043ea:	e8 22 0c 00 00       	call   80105011 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801043ef:	eb 3a                	jmp    8010442b <piperead+0x4e>
    if(proc->killed){
801043f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043f7:	8b 40 24             	mov    0x24(%eax),%eax
801043fa:	85 c0                	test   %eax,%eax
801043fc:	74 15                	je     80104413 <piperead+0x36>
      release(&p->lock);
801043fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104401:	89 04 24             	mov    %eax,(%esp)
80104404:	e8 6a 0c 00 00       	call   80105073 <release>
      return -1;
80104409:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010440e:	e9 b5 00 00 00       	jmp    801044c8 <piperead+0xeb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104413:	8b 45 08             	mov    0x8(%ebp),%eax
80104416:	8b 55 08             	mov    0x8(%ebp),%edx
80104419:	81 c2 34 02 00 00    	add    $0x234,%edx
8010441f:	89 44 24 04          	mov    %eax,0x4(%esp)
80104423:	89 14 24             	mov    %edx,(%esp)
80104426:	e8 1c 09 00 00       	call   80104d47 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010442b:	8b 45 08             	mov    0x8(%ebp),%eax
8010442e:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104434:	8b 45 08             	mov    0x8(%ebp),%eax
80104437:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010443d:	39 c2                	cmp    %eax,%edx
8010443f:	75 0d                	jne    8010444e <piperead+0x71>
80104441:	8b 45 08             	mov    0x8(%ebp),%eax
80104444:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010444a:	85 c0                	test   %eax,%eax
8010444c:	75 a3                	jne    801043f1 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010444e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104455:	eb 4b                	jmp    801044a2 <piperead+0xc5>
    if(p->nread == p->nwrite)
80104457:	8b 45 08             	mov    0x8(%ebp),%eax
8010445a:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104460:	8b 45 08             	mov    0x8(%ebp),%eax
80104463:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104469:	39 c2                	cmp    %eax,%edx
8010446b:	75 02                	jne    8010446f <piperead+0x92>
      break;
8010446d:	eb 3b                	jmp    801044aa <piperead+0xcd>
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010446f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104472:	8b 45 0c             	mov    0xc(%ebp),%eax
80104475:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104478:	8b 45 08             	mov    0x8(%ebp),%eax
8010447b:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104481:	8d 48 01             	lea    0x1(%eax),%ecx
80104484:	8b 55 08             	mov    0x8(%ebp),%edx
80104487:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
8010448d:	25 ff 01 00 00       	and    $0x1ff,%eax
80104492:	89 c2                	mov    %eax,%edx
80104494:	8b 45 08             	mov    0x8(%ebp),%eax
80104497:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
8010449c:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010449e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801044a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a5:	3b 45 10             	cmp    0x10(%ebp),%eax
801044a8:	7c ad                	jl     80104457 <piperead+0x7a>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801044aa:	8b 45 08             	mov    0x8(%ebp),%eax
801044ad:	05 38 02 00 00       	add    $0x238,%eax
801044b2:	89 04 24             	mov    %eax,(%esp)
801044b5:	e8 66 09 00 00       	call   80104e20 <wakeup>
  release(&p->lock);
801044ba:	8b 45 08             	mov    0x8(%ebp),%eax
801044bd:	89 04 24             	mov    %eax,(%esp)
801044c0:	e8 ae 0b 00 00       	call   80105073 <release>
  return i;
801044c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801044c8:	83 c4 24             	add    $0x24,%esp
801044cb:	5b                   	pop    %ebx
801044cc:	5d                   	pop    %ebp
801044cd:	c3                   	ret    

801044ce <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801044ce:	55                   	push   %ebp
801044cf:	89 e5                	mov    %esp,%ebp
801044d1:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801044d4:	9c                   	pushf  
801044d5:	58                   	pop    %eax
801044d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801044d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801044dc:	c9                   	leave  
801044dd:	c3                   	ret    

801044de <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801044de:	55                   	push   %ebp
801044df:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801044e1:	fb                   	sti    
}
801044e2:	5d                   	pop    %ebp
801044e3:	c3                   	ret    

801044e4 <pinit>:
extern   void flushTLB();
static void wakeup1(void *chan);

void
pinit(void)
{
801044e4:	55                   	push   %ebp
801044e5:	89 e5                	mov    %esp,%ebp
801044e7:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
801044ea:	c7 44 24 04 59 8a 10 	movl   $0x80108a59,0x4(%esp)
801044f1:	80 
801044f2:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
801044f9:	e8 f2 0a 00 00       	call   80104ff0 <initlock>
}
801044fe:	c9                   	leave  
801044ff:	c3                   	ret    

80104500 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104500:	55                   	push   %ebp
80104501:	89 e5                	mov    %esp,%ebp
80104503:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104506:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
8010450d:	e8 ff 0a 00 00       	call   80105011 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104512:	c7 45 f4 14 2a 11 80 	movl   $0x80112a14,-0xc(%ebp)
80104519:	eb 50                	jmp    8010456b <allocproc+0x6b>
    if(p->state == UNUSED)
8010451b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451e:	8b 40 0c             	mov    0xc(%eax),%eax
80104521:	85 c0                	test   %eax,%eax
80104523:	75 42                	jne    80104567 <allocproc+0x67>
      goto found;
80104525:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104526:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104529:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104530:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104535:	8d 50 01             	lea    0x1(%eax),%edx
80104538:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
8010453e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104541:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80104544:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
8010454b:	e8 23 0b 00 00       	call   80105073 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104550:	e8 67 e7 ff ff       	call   80102cbc <kalloc>
80104555:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104558:	89 42 08             	mov    %eax,0x8(%edx)
8010455b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455e:	8b 40 08             	mov    0x8(%eax),%eax
80104561:	85 c0                	test   %eax,%eax
80104563:	75 33                	jne    80104598 <allocproc+0x98>
80104565:	eb 20                	jmp    80104587 <allocproc+0x87>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104567:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010456b:	81 7d f4 14 49 11 80 	cmpl   $0x80114914,-0xc(%ebp)
80104572:	72 a7                	jb     8010451b <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104574:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
8010457b:	e8 f3 0a 00 00       	call   80105073 <release>
  return 0;
80104580:	b8 00 00 00 00       	mov    $0x0,%eax
80104585:	eb 76                	jmp    801045fd <allocproc+0xfd>
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
80104587:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010458a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104591:	b8 00 00 00 00       	mov    $0x0,%eax
80104596:	eb 65                	jmp    801045fd <allocproc+0xfd>
  }
  sp = p->kstack + KSTACKSIZE;
80104598:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459b:	8b 40 08             	mov    0x8(%eax),%eax
8010459e:	05 00 10 00 00       	add    $0x1000,%eax
801045a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801045a6:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801045aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045b0:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801045b3:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801045b7:	ba 79 66 10 80       	mov    $0x80106679,%edx
801045bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045bf:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801045c1:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801045c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045cb:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801045ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d1:	8b 40 1c             	mov    0x1c(%eax),%eax
801045d4:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801045db:	00 
801045dc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801045e3:	00 
801045e4:	89 04 24             	mov    %eax,(%esp)
801045e7:	e8 79 0c 00 00       	call   80105265 <memset>
  p->context->eip = (uint)forkret;
801045ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ef:	8b 40 1c             	mov    0x1c(%eax),%eax
801045f2:	ba 1b 4d 10 80       	mov    $0x80104d1b,%edx
801045f7:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801045fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801045fd:	c9                   	leave  
801045fe:	c3                   	ret    

801045ff <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801045ff:	55                   	push   %ebp
80104600:	89 e5                	mov    %esp,%ebp
80104602:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  memset(cpu->kpgdir,0, PGSIZE/2);
80104605:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010460b:	8b 40 04             	mov    0x4(%eax),%eax
8010460e:	c7 44 24 08 00 08 00 	movl   $0x800,0x8(%esp)
80104615:	00 
80104616:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010461d:	00 
8010461e:	89 04 24             	mov    %eax,(%esp)
80104621:	e8 3f 0c 00 00       	call   80105265 <memset>
  p = allocproc();
80104626:	e8 d5 fe ff ff       	call   80104500 <allocproc>
8010462b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
8010462e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104631:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm()) == 0)
80104636:	e8 8b 37 00 00       	call   80107dc6 <setupkvm>
8010463b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010463e:	89 42 04             	mov    %eax,0x4(%edx)
80104641:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104644:	8b 40 04             	mov    0x4(%eax),%eax
80104647:	85 c0                	test   %eax,%eax
80104649:	75 0c                	jne    80104657 <userinit+0x58>
    panic("userinit: out of memory?");
8010464b:	c7 04 24 60 8a 10 80 	movl   $0x80108a60,(%esp)
80104652:	e8 8b c0 ff ff       	call   801006e2 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104657:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010465c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465f:	8b 40 04             	mov    0x4(%eax),%eax
80104662:	89 54 24 08          	mov    %edx,0x8(%esp)
80104666:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
8010466d:	80 
8010466e:	89 04 24             	mov    %eax,(%esp)
80104671:	e8 9a 39 00 00       	call   80108010 <inituvm>
  p->sz = PGSIZE;
80104676:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104679:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010467f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104682:	8b 40 18             	mov    0x18(%eax),%eax
80104685:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
8010468c:	00 
8010468d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104694:	00 
80104695:	89 04 24             	mov    %eax,(%esp)
80104698:	e8 c8 0b 00 00       	call   80105265 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010469d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a0:	8b 40 18             	mov    0x18(%eax),%eax
801046a3:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801046a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ac:	8b 40 18             	mov    0x18(%eax),%eax
801046af:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
801046b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b8:	8b 40 18             	mov    0x18(%eax),%eax
801046bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046be:	8b 52 18             	mov    0x18(%edx),%edx
801046c1:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801046c5:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801046c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046cc:	8b 40 18             	mov    0x18(%eax),%eax
801046cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046d2:	8b 52 18             	mov    0x18(%edx),%edx
801046d5:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801046d9:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801046dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e0:	8b 40 18             	mov    0x18(%eax),%eax
801046e3:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801046ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ed:	8b 40 18             	mov    0x18(%eax),%eax
801046f0:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801046f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046fa:	8b 40 18             	mov    0x18(%eax),%eax
801046fd:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104704:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104707:	83 c0 6c             	add    $0x6c,%eax
8010470a:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104711:	00 
80104712:	c7 44 24 04 79 8a 10 	movl   $0x80108a79,0x4(%esp)
80104719:	80 
8010471a:	89 04 24             	mov    %eax,(%esp)
8010471d:	e8 63 0d 00 00       	call   80105485 <safestrcpy>
  p->cwd = namei("/");
80104722:	c7 04 24 82 8a 10 80 	movl   $0x80108a82,(%esp)
80104729:	e8 b2 de ff ff       	call   801025e0 <namei>
8010472e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104731:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
80104734:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104737:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
8010473e:	c9                   	leave  
8010473f:	c3                   	ret    

80104740 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104740:	55                   	push   %ebp
80104741:	89 e5                	mov    %esp,%ebp
80104743:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
80104746:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010474c:	8b 00                	mov    (%eax),%eax
8010474e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104751:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104755:	7e 34                	jle    8010478b <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104757:	8b 55 08             	mov    0x8(%ebp),%edx
8010475a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010475d:	01 c2                	add    %eax,%edx
8010475f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104765:	8b 40 04             	mov    0x4(%eax),%eax
80104768:	89 54 24 08          	mov    %edx,0x8(%esp)
8010476c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010476f:	89 54 24 04          	mov    %edx,0x4(%esp)
80104773:	89 04 24             	mov    %eax,(%esp)
80104776:	e8 0b 3a 00 00       	call   80108186 <allocuvm>
8010477b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010477e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104782:	75 41                	jne    801047c5 <growproc+0x85>
      return -1;
80104784:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104789:	eb 58                	jmp    801047e3 <growproc+0xa3>
  } else if(n < 0){
8010478b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010478f:	79 34                	jns    801047c5 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104791:	8b 55 08             	mov    0x8(%ebp),%edx
80104794:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104797:	01 c2                	add    %eax,%edx
80104799:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010479f:	8b 40 04             	mov    0x4(%eax),%eax
801047a2:	89 54 24 08          	mov    %edx,0x8(%esp)
801047a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047a9:	89 54 24 04          	mov    %edx,0x4(%esp)
801047ad:	89 04 24             	mov    %eax,(%esp)
801047b0:	e8 ab 3a 00 00       	call   80108260 <deallocuvm>
801047b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801047b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047bc:	75 07                	jne    801047c5 <growproc+0x85>
      return -1;
801047be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047c3:	eb 1e                	jmp    801047e3 <growproc+0xa3>
  }
  proc->sz = sz;
801047c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047ce:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
801047d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047d6:	89 04 24             	mov    %eax,(%esp)
801047d9:	e8 e1 36 00 00       	call   80107ebf <switchuvm>
  return 0;
801047de:	b8 00 00 00 00       	mov    $0x0,%eax
}
801047e3:	c9                   	leave  
801047e4:	c3                   	ret    

801047e5 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801047e5:	55                   	push   %ebp
801047e6:	89 e5                	mov    %esp,%ebp
801047e8:	57                   	push   %edi
801047e9:	56                   	push   %esi
801047ea:	53                   	push   %ebx
801047eb:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0){
801047ee:	e8 0d fd ff ff       	call   80104500 <allocproc>
801047f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
801047f6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801047fa:	75 0a                	jne    80104806 <fork+0x21>

	  return -1;
801047fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104801:	e9 52 01 00 00       	jmp    80104958 <fork+0x173>
  }
  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104806:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010480c:	8b 10                	mov    (%eax),%edx
8010480e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104814:	8b 40 04             	mov    0x4(%eax),%eax
80104817:	89 54 24 04          	mov    %edx,0x4(%esp)
8010481b:	89 04 24             	mov    %eax,(%esp)
8010481e:	e8 d9 3b 00 00       	call   801083fc <copyuvm>
80104823:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104826:	89 42 04             	mov    %eax,0x4(%edx)
80104829:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010482c:	8b 40 04             	mov    0x4(%eax),%eax
8010482f:	85 c0                	test   %eax,%eax
80104831:	75 2c                	jne    8010485f <fork+0x7a>
    kfree(np->kstack);
80104833:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104836:	8b 40 08             	mov    0x8(%eax),%eax
80104839:	89 04 24             	mov    %eax,(%esp)
8010483c:	e8 e2 e3 ff ff       	call   80102c23 <kfree>
    np->kstack = 0;
80104841:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104844:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
8010484b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010484e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)

    return -1;
80104855:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010485a:	e9 f9 00 00 00       	jmp    80104958 <fork+0x173>
  }
  np->sz = proc->sz;
8010485f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104865:	8b 10                	mov    (%eax),%edx
80104867:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010486a:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
8010486c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104873:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104876:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104879:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010487c:	8b 50 18             	mov    0x18(%eax),%edx
8010487f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104885:	8b 40 18             	mov    0x18(%eax),%eax
80104888:	89 c3                	mov    %eax,%ebx
8010488a:	b8 13 00 00 00       	mov    $0x13,%eax
8010488f:	89 d7                	mov    %edx,%edi
80104891:	89 de                	mov    %ebx,%esi
80104893:	89 c1                	mov    %eax,%ecx
80104895:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104897:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010489a:	8b 40 18             	mov    0x18(%eax),%eax
8010489d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801048a4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801048ab:	eb 3d                	jmp    801048ea <fork+0x105>
    if(proc->ofile[i])
801048ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048b3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801048b6:	83 c2 08             	add    $0x8,%edx
801048b9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801048bd:	85 c0                	test   %eax,%eax
801048bf:	74 25                	je     801048e6 <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
801048c1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048c7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801048ca:	83 c2 08             	add    $0x8,%edx
801048cd:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801048d1:	89 04 24             	mov    %eax,(%esp)
801048d4:	e8 87 c8 ff ff       	call   80101160 <filedup>
801048d9:	8b 55 e0             	mov    -0x20(%ebp),%edx
801048dc:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801048df:	83 c1 08             	add    $0x8,%ecx
801048e2:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801048e6:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801048ea:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801048ee:	7e bd                	jle    801048ad <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
801048f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048f6:	8b 40 68             	mov    0x68(%eax),%eax
801048f9:	89 04 24             	mov    %eax,(%esp)
801048fc:	e8 02 d1 ff ff       	call   80101a03 <idup>
80104901:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104904:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104907:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010490d:	8d 50 6c             	lea    0x6c(%eax),%edx
80104910:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104913:	83 c0 6c             	add    $0x6c,%eax
80104916:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010491d:	00 
8010491e:	89 54 24 04          	mov    %edx,0x4(%esp)
80104922:	89 04 24             	mov    %eax,(%esp)
80104925:	e8 5b 0b 00 00       	call   80105485 <safestrcpy>
 
  pid = np->pid;
8010492a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010492d:	8b 40 10             	mov    0x10(%eax),%eax
80104930:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104933:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
8010493a:	e8 d2 06 00 00       	call   80105011 <acquire>
  np->state = RUNNABLE;
8010493f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104942:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
80104949:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104950:	e8 1e 07 00 00       	call   80105073 <release>

  return pid;
80104955:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104958:	83 c4 2c             	add    $0x2c,%esp
8010495b:	5b                   	pop    %ebx
8010495c:	5e                   	pop    %esi
8010495d:	5f                   	pop    %edi
8010495e:	5d                   	pop    %ebp
8010495f:	c3                   	ret    

80104960 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104960:	55                   	push   %ebp
80104961:	89 e5                	mov    %esp,%ebp
80104963:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104966:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010496d:	a1 48 b6 10 80       	mov    0x8010b648,%eax
80104972:	39 c2                	cmp    %eax,%edx
80104974:	75 0c                	jne    80104982 <exit+0x22>
    panic("init exiting");
80104976:	c7 04 24 84 8a 10 80 	movl   $0x80108a84,(%esp)
8010497d:	e8 60 bd ff ff       	call   801006e2 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104982:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104989:	eb 44                	jmp    801049cf <exit+0x6f>
    if(proc->ofile[fd]){
8010498b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104991:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104994:	83 c2 08             	add    $0x8,%edx
80104997:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010499b:	85 c0                	test   %eax,%eax
8010499d:	74 2c                	je     801049cb <exit+0x6b>
      fileclose(proc->ofile[fd]);
8010499f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049a8:	83 c2 08             	add    $0x8,%edx
801049ab:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801049af:	89 04 24             	mov    %eax,(%esp)
801049b2:	e8 f1 c7 ff ff       	call   801011a8 <fileclose>
      proc->ofile[fd] = 0;
801049b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049c0:	83 c2 08             	add    $0x8,%edx
801049c3:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801049ca:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801049cb:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801049cf:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801049d3:	7e b6                	jle    8010498b <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
801049d5:	e8 10 ec ff ff       	call   801035ea <begin_op>
  iput(proc->cwd);
801049da:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049e0:	8b 40 68             	mov    0x68(%eax),%eax
801049e3:	89 04 24             	mov    %eax,(%esp)
801049e6:	e8 fd d1 ff ff       	call   80101be8 <iput>
  end_op();
801049eb:	e8 7e ec ff ff       	call   8010366e <end_op>
  proc->cwd = 0;
801049f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049f6:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801049fd:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104a04:	e8 08 06 00 00       	call   80105011 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104a09:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a0f:	8b 40 14             	mov    0x14(%eax),%eax
80104a12:	89 04 24             	mov    %eax,(%esp)
80104a15:	e8 c8 03 00 00       	call   80104de2 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a1a:	c7 45 f4 14 2a 11 80 	movl   $0x80112a14,-0xc(%ebp)
80104a21:	eb 38                	jmp    80104a5b <exit+0xfb>
    if(p->parent == proc){
80104a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a26:	8b 50 14             	mov    0x14(%eax),%edx
80104a29:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a2f:	39 c2                	cmp    %eax,%edx
80104a31:	75 24                	jne    80104a57 <exit+0xf7>
      p->parent = initproc;
80104a33:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
80104a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a3c:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a42:	8b 40 0c             	mov    0xc(%eax),%eax
80104a45:	83 f8 05             	cmp    $0x5,%eax
80104a48:	75 0d                	jne    80104a57 <exit+0xf7>
        wakeup1(initproc);
80104a4a:	a1 48 b6 10 80       	mov    0x8010b648,%eax
80104a4f:	89 04 24             	mov    %eax,(%esp)
80104a52:	e8 8b 03 00 00       	call   80104de2 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a57:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104a5b:	81 7d f4 14 49 11 80 	cmpl   $0x80114914,-0xc(%ebp)
80104a62:	72 bf                	jb     80104a23 <exit+0xc3>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104a64:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a6a:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104a71:	e8 c1 01 00 00       	call   80104c37 <sched>
  panic("zombie exit");
80104a76:	c7 04 24 91 8a 10 80 	movl   $0x80108a91,(%esp)
80104a7d:	e8 60 bc ff ff       	call   801006e2 <panic>

80104a82 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104a82:	55                   	push   %ebp
80104a83:	89 e5                	mov    %esp,%ebp
80104a85:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a88:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104a8f:	e8 7d 05 00 00       	call   80105011 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a94:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a9b:	c7 45 f4 14 2a 11 80 	movl   $0x80112a14,-0xc(%ebp)
80104aa2:	e9 9a 00 00 00       	jmp    80104b41 <wait+0xbf>
      if(p->parent != proc)
80104aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aaa:	8b 50 14             	mov    0x14(%eax),%edx
80104aad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ab3:	39 c2                	cmp    %eax,%edx
80104ab5:	74 05                	je     80104abc <wait+0x3a>
        continue;
80104ab7:	e9 81 00 00 00       	jmp    80104b3d <wait+0xbb>
      havekids = 1;
80104abc:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac6:	8b 40 0c             	mov    0xc(%eax),%eax
80104ac9:	83 f8 05             	cmp    $0x5,%eax
80104acc:	75 6f                	jne    80104b3d <wait+0xbb>
        // Found one.
        pid = p->pid;
80104ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad1:	8b 40 10             	mov    0x10(%eax),%eax
80104ad4:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ada:	8b 40 08             	mov    0x8(%eax),%eax
80104add:	89 04 24             	mov    %eax,(%esp)
80104ae0:	e8 3e e1 ff ff       	call   80102c23 <kfree>
        p->kstack = 0;
80104ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af2:	8b 40 04             	mov    0x4(%eax),%eax
80104af5:	89 04 24             	mov    %eax,(%esp)
80104af8:	e8 1f 38 00 00       	call   8010831c <freevm>
        p->state = UNUSED;
80104afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b00:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b0a:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b14:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b1e:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b25:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104b2c:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104b33:	e8 3b 05 00 00       	call   80105073 <release>
        return pid;
80104b38:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b3b:	eb 52                	jmp    80104b8f <wait+0x10d>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b3d:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104b41:	81 7d f4 14 49 11 80 	cmpl   $0x80114914,-0xc(%ebp)
80104b48:	0f 82 59 ff ff ff    	jb     80104aa7 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104b4e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b52:	74 0d                	je     80104b61 <wait+0xdf>
80104b54:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b5a:	8b 40 24             	mov    0x24(%eax),%eax
80104b5d:	85 c0                	test   %eax,%eax
80104b5f:	74 13                	je     80104b74 <wait+0xf2>
      release(&ptable.lock);
80104b61:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104b68:	e8 06 05 00 00       	call   80105073 <release>
      return -1;
80104b6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b72:	eb 1b                	jmp    80104b8f <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b74:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b7a:	c7 44 24 04 e0 29 11 	movl   $0x801129e0,0x4(%esp)
80104b81:	80 
80104b82:	89 04 24             	mov    %eax,(%esp)
80104b85:	e8 bd 01 00 00       	call   80104d47 <sleep>
  }
80104b8a:	e9 05 ff ff ff       	jmp    80104a94 <wait+0x12>
}
80104b8f:	c9                   	leave  
80104b90:	c3                   	ret    

80104b91 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104b91:	55                   	push   %ebp
80104b92:	89 e5                	mov    %esp,%ebp
80104b94:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104b97:	e8 42 f9 ff ff       	call   801044de <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104b9c:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104ba3:	e8 69 04 00 00       	call   80105011 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ba8:	c7 45 f4 14 2a 11 80 	movl   $0x80112a14,-0xc(%ebp)
80104baf:	eb 6c                	jmp    80104c1d <scheduler+0x8c>
      if(p->state != RUNNABLE)
80104bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb4:	8b 40 0c             	mov    0xc(%eax),%eax
80104bb7:	83 f8 03             	cmp    $0x3,%eax
80104bba:	74 02                	je     80104bbe <scheduler+0x2d>
        continue;
80104bbc:	eb 5b                	jmp    80104c19 <scheduler+0x88>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc1:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bca:	89 04 24             	mov    %eax,(%esp)
80104bcd:	e8 ed 32 00 00       	call   80107ebf <switchuvm>
      p->state = RUNNING;
80104bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd5:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      flushTLB();
80104bdc:	e8 53 3b 00 00       	call   80108734 <flushTLB>

      swtch(&cpu->scheduler, proc->context);
80104be1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104be7:	8b 40 1c             	mov    0x1c(%eax),%eax
80104bea:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104bf1:	83 c2 08             	add    $0x8,%edx
80104bf4:	89 44 24 04          	mov    %eax,0x4(%esp)
80104bf8:	89 14 24             	mov    %edx,(%esp)
80104bfb:	e8 f6 08 00 00       	call   801054f6 <swtch>
      switchkvm(cpu);
80104c00:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c06:	89 04 24             	mov    %eax,(%esp)
80104c09:	e8 93 32 00 00       	call   80107ea1 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104c0e:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104c15:	00 00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c19:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104c1d:	81 7d f4 14 49 11 80 	cmpl   $0x80114914,-0xc(%ebp)
80104c24:	72 8b                	jb     80104bb1 <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104c26:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104c2d:	e8 41 04 00 00       	call   80105073 <release>

  }
80104c32:	e9 60 ff ff ff       	jmp    80104b97 <scheduler+0x6>

80104c37 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104c37:	55                   	push   %ebp
80104c38:	89 e5                	mov    %esp,%ebp
80104c3a:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104c3d:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104c44:	e8 f2 04 00 00       	call   8010513b <holding>
80104c49:	85 c0                	test   %eax,%eax
80104c4b:	75 0c                	jne    80104c59 <sched+0x22>
    panic("sched ptable.lock");
80104c4d:	c7 04 24 9d 8a 10 80 	movl   $0x80108a9d,(%esp)
80104c54:	e8 89 ba ff ff       	call   801006e2 <panic>
  if(cpu->ncli != 1)
80104c59:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c5f:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104c65:	83 f8 01             	cmp    $0x1,%eax
80104c68:	74 0c                	je     80104c76 <sched+0x3f>
    panic("sched locks");
80104c6a:	c7 04 24 af 8a 10 80 	movl   $0x80108aaf,(%esp)
80104c71:	e8 6c ba ff ff       	call   801006e2 <panic>
  if(proc->state == RUNNING)
80104c76:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c7c:	8b 40 0c             	mov    0xc(%eax),%eax
80104c7f:	83 f8 04             	cmp    $0x4,%eax
80104c82:	75 0c                	jne    80104c90 <sched+0x59>
    panic("sched running");
80104c84:	c7 04 24 bb 8a 10 80 	movl   $0x80108abb,(%esp)
80104c8b:	e8 52 ba ff ff       	call   801006e2 <panic>
  if(readeflags()&FL_IF)
80104c90:	e8 39 f8 ff ff       	call   801044ce <readeflags>
80104c95:	25 00 02 00 00       	and    $0x200,%eax
80104c9a:	85 c0                	test   %eax,%eax
80104c9c:	74 0c                	je     80104caa <sched+0x73>
    panic("sched interruptible");
80104c9e:	c7 04 24 c9 8a 10 80 	movl   $0x80108ac9,(%esp)
80104ca5:	e8 38 ba ff ff       	call   801006e2 <panic>
  intena = cpu->intena;
80104caa:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cb0:	8b 80 b4 00 00 00    	mov    0xb4(%eax),%eax
80104cb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104cb9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cbf:	8b 40 08             	mov    0x8(%eax),%eax
80104cc2:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104cc9:	83 c2 1c             	add    $0x1c,%edx
80104ccc:	89 44 24 04          	mov    %eax,0x4(%esp)
80104cd0:	89 14 24             	mov    %edx,(%esp)
80104cd3:	e8 1e 08 00 00       	call   801054f6 <swtch>
  cpu->intena = intena;
80104cd8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cde:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ce1:	89 90 b4 00 00 00    	mov    %edx,0xb4(%eax)
}
80104ce7:	c9                   	leave  
80104ce8:	c3                   	ret    

80104ce9 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104ce9:	55                   	push   %ebp
80104cea:	89 e5                	mov    %esp,%ebp
80104cec:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104cef:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104cf6:	e8 16 03 00 00       	call   80105011 <acquire>
  proc->state = RUNNABLE;
80104cfb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d01:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104d08:	e8 2a ff ff ff       	call   80104c37 <sched>
  release(&ptable.lock);
80104d0d:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104d14:	e8 5a 03 00 00       	call   80105073 <release>
}
80104d19:	c9                   	leave  
80104d1a:	c3                   	ret    

80104d1b <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104d1b:	55                   	push   %ebp
80104d1c:	89 e5                	mov    %esp,%ebp
80104d1e:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104d21:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104d28:	e8 46 03 00 00       	call   80105073 <release>

  if (first) {
80104d2d:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104d32:	85 c0                	test   %eax,%eax
80104d34:	74 0f                	je     80104d45 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104d36:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104d3d:	00 00 00 
    initlog();
80104d40:	e8 97 e6 ff ff       	call   801033dc <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104d45:	c9                   	leave  
80104d46:	c3                   	ret    

80104d47 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104d47:	55                   	push   %ebp
80104d48:	89 e5                	mov    %esp,%ebp
80104d4a:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104d4d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d53:	85 c0                	test   %eax,%eax
80104d55:	75 0c                	jne    80104d63 <sleep+0x1c>
    panic("sleep");
80104d57:	c7 04 24 dd 8a 10 80 	movl   $0x80108add,(%esp)
80104d5e:	e8 7f b9 ff ff       	call   801006e2 <panic>

  if(lk == 0)
80104d63:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104d67:	75 0c                	jne    80104d75 <sleep+0x2e>
    panic("sleep without lk");
80104d69:	c7 04 24 e3 8a 10 80 	movl   $0x80108ae3,(%esp)
80104d70:	e8 6d b9 ff ff       	call   801006e2 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104d75:	81 7d 0c e0 29 11 80 	cmpl   $0x801129e0,0xc(%ebp)
80104d7c:	74 17                	je     80104d95 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104d7e:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104d85:	e8 87 02 00 00       	call   80105011 <acquire>
    release(lk);
80104d8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d8d:	89 04 24             	mov    %eax,(%esp)
80104d90:	e8 de 02 00 00       	call   80105073 <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104d95:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d9b:	8b 55 08             	mov    0x8(%ebp),%edx
80104d9e:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104da1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104da7:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104dae:	e8 84 fe ff ff       	call   80104c37 <sched>

  // Tidy up.
  proc->chan = 0;
80104db3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104db9:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104dc0:	81 7d 0c e0 29 11 80 	cmpl   $0x801129e0,0xc(%ebp)
80104dc7:	74 17                	je     80104de0 <sleep+0x99>
    release(&ptable.lock);
80104dc9:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104dd0:	e8 9e 02 00 00       	call   80105073 <release>
    acquire(lk);
80104dd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dd8:	89 04 24             	mov    %eax,(%esp)
80104ddb:	e8 31 02 00 00       	call   80105011 <acquire>
  }
}
80104de0:	c9                   	leave  
80104de1:	c3                   	ret    

80104de2 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104de2:	55                   	push   %ebp
80104de3:	89 e5                	mov    %esp,%ebp
80104de5:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104de8:	c7 45 fc 14 2a 11 80 	movl   $0x80112a14,-0x4(%ebp)
80104def:	eb 24                	jmp    80104e15 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104df1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104df4:	8b 40 0c             	mov    0xc(%eax),%eax
80104df7:	83 f8 02             	cmp    $0x2,%eax
80104dfa:	75 15                	jne    80104e11 <wakeup1+0x2f>
80104dfc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dff:	8b 40 20             	mov    0x20(%eax),%eax
80104e02:	3b 45 08             	cmp    0x8(%ebp),%eax
80104e05:	75 0a                	jne    80104e11 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104e07:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e0a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e11:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104e15:	81 7d fc 14 49 11 80 	cmpl   $0x80114914,-0x4(%ebp)
80104e1c:	72 d3                	jb     80104df1 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104e1e:	c9                   	leave  
80104e1f:	c3                   	ret    

80104e20 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104e20:	55                   	push   %ebp
80104e21:	89 e5                	mov    %esp,%ebp
80104e23:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104e26:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104e2d:	e8 df 01 00 00       	call   80105011 <acquire>
  wakeup1(chan);
80104e32:	8b 45 08             	mov    0x8(%ebp),%eax
80104e35:	89 04 24             	mov    %eax,(%esp)
80104e38:	e8 a5 ff ff ff       	call   80104de2 <wakeup1>
  release(&ptable.lock);
80104e3d:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104e44:	e8 2a 02 00 00       	call   80105073 <release>
}
80104e49:	c9                   	leave  
80104e4a:	c3                   	ret    

80104e4b <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104e4b:	55                   	push   %ebp
80104e4c:	89 e5                	mov    %esp,%ebp
80104e4e:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104e51:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104e58:	e8 b4 01 00 00       	call   80105011 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e5d:	c7 45 f4 14 2a 11 80 	movl   $0x80112a14,-0xc(%ebp)
80104e64:	eb 41                	jmp    80104ea7 <kill+0x5c>
    if(p->pid == pid){
80104e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e69:	8b 40 10             	mov    0x10(%eax),%eax
80104e6c:	3b 45 08             	cmp    0x8(%ebp),%eax
80104e6f:	75 32                	jne    80104ea3 <kill+0x58>
      p->killed = 1;
80104e71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e74:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e7e:	8b 40 0c             	mov    0xc(%eax),%eax
80104e81:	83 f8 02             	cmp    $0x2,%eax
80104e84:	75 0a                	jne    80104e90 <kill+0x45>
        p->state = RUNNABLE;
80104e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e89:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104e90:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104e97:	e8 d7 01 00 00       	call   80105073 <release>
      return 0;
80104e9c:	b8 00 00 00 00       	mov    $0x0,%eax
80104ea1:	eb 1e                	jmp    80104ec1 <kill+0x76>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ea3:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104ea7:	81 7d f4 14 49 11 80 	cmpl   $0x80114914,-0xc(%ebp)
80104eae:	72 b6                	jb     80104e66 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104eb0:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104eb7:	e8 b7 01 00 00       	call   80105073 <release>
  return -1;
80104ebc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ec1:	c9                   	leave  
80104ec2:	c3                   	ret    

80104ec3 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104ec3:	55                   	push   %ebp
80104ec4:	89 e5                	mov    %esp,%ebp
80104ec6:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ec9:	c7 45 f0 14 2a 11 80 	movl   $0x80112a14,-0x10(%ebp)
80104ed0:	e9 d6 00 00 00       	jmp    80104fab <procdump+0xe8>
    if(p->state == UNUSED)
80104ed5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ed8:	8b 40 0c             	mov    0xc(%eax),%eax
80104edb:	85 c0                	test   %eax,%eax
80104edd:	75 05                	jne    80104ee4 <procdump+0x21>
      continue;
80104edf:	e9 c3 00 00 00       	jmp    80104fa7 <procdump+0xe4>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104ee4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ee7:	8b 40 0c             	mov    0xc(%eax),%eax
80104eea:	83 f8 05             	cmp    $0x5,%eax
80104eed:	77 23                	ja     80104f12 <procdump+0x4f>
80104eef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ef2:	8b 40 0c             	mov    0xc(%eax),%eax
80104ef5:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104efc:	85 c0                	test   %eax,%eax
80104efe:	74 12                	je     80104f12 <procdump+0x4f>
      state = states[p->state];
80104f00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f03:	8b 40 0c             	mov    0xc(%eax),%eax
80104f06:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104f0d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104f10:	eb 07                	jmp    80104f19 <procdump+0x56>
    else
      state = "???";
80104f12:	c7 45 ec f4 8a 10 80 	movl   $0x80108af4,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104f19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f1c:	8d 50 6c             	lea    0x6c(%eax),%edx
80104f1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f22:	8b 40 10             	mov    0x10(%eax),%eax
80104f25:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104f29:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104f2c:	89 54 24 08          	mov    %edx,0x8(%esp)
80104f30:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f34:	c7 04 24 f8 8a 10 80 	movl   $0x80108af8,(%esp)
80104f3b:	e8 60 b4 ff ff       	call   801003a0 <cprintf>
    if(p->state == SLEEPING){
80104f40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f43:	8b 40 0c             	mov    0xc(%eax),%eax
80104f46:	83 f8 02             	cmp    $0x2,%eax
80104f49:	75 50                	jne    80104f9b <procdump+0xd8>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104f4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f4e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f51:	8b 40 0c             	mov    0xc(%eax),%eax
80104f54:	83 c0 08             	add    $0x8,%eax
80104f57:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104f5a:	89 54 24 04          	mov    %edx,0x4(%esp)
80104f5e:	89 04 24             	mov    %eax,(%esp)
80104f61:	e8 5c 01 00 00       	call   801050c2 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104f66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f6d:	eb 1b                	jmp    80104f8a <procdump+0xc7>
        cprintf(" %p", pc[i]);
80104f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f72:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f76:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f7a:	c7 04 24 01 8b 10 80 	movl   $0x80108b01,(%esp)
80104f81:	e8 1a b4 ff ff       	call   801003a0 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104f86:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f8a:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104f8e:	7f 0b                	jg     80104f9b <procdump+0xd8>
80104f90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f93:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f97:	85 c0                	test   %eax,%eax
80104f99:	75 d4                	jne    80104f6f <procdump+0xac>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104f9b:	c7 04 24 05 8b 10 80 	movl   $0x80108b05,(%esp)
80104fa2:	e8 f9 b3 ff ff       	call   801003a0 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fa7:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104fab:	81 7d f0 14 49 11 80 	cmpl   $0x80114914,-0x10(%ebp)
80104fb2:	0f 82 1d ff ff ff    	jb     80104ed5 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104fb8:	c9                   	leave  
80104fb9:	c3                   	ret    

80104fba <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104fba:	55                   	push   %ebp
80104fbb:	89 e5                	mov    %esp,%ebp
80104fbd:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104fc0:	9c                   	pushf  
80104fc1:	58                   	pop    %eax
80104fc2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104fc5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fc8:	c9                   	leave  
80104fc9:	c3                   	ret    

80104fca <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104fca:	55                   	push   %ebp
80104fcb:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104fcd:	fa                   	cli    
}
80104fce:	5d                   	pop    %ebp
80104fcf:	c3                   	ret    

80104fd0 <sti>:

static inline void
sti(void)
{
80104fd0:	55                   	push   %ebp
80104fd1:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104fd3:	fb                   	sti    
}
80104fd4:	5d                   	pop    %ebp
80104fd5:	c3                   	ret    

80104fd6 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104fd6:	55                   	push   %ebp
80104fd7:	89 e5                	mov    %esp,%ebp
80104fd9:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104fdc:	8b 55 08             	mov    0x8(%ebp),%edx
80104fdf:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fe2:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104fe5:	f0 87 02             	lock xchg %eax,(%edx)
80104fe8:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104feb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fee:	c9                   	leave  
80104fef:	c3                   	ret    

80104ff0 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104ff0:	55                   	push   %ebp
80104ff1:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104ff3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff6:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ff9:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104ffc:	8b 45 08             	mov    0x8(%ebp),%eax
80104fff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105005:	8b 45 08             	mov    0x8(%ebp),%eax
80105008:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010500f:	5d                   	pop    %ebp
80105010:	c3                   	ret    

80105011 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105011:	55                   	push   %ebp
80105012:	89 e5                	mov    %esp,%ebp
80105014:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105017:	e8 49 01 00 00       	call   80105165 <pushcli>
  if(holding(lk))
8010501c:	8b 45 08             	mov    0x8(%ebp),%eax
8010501f:	89 04 24             	mov    %eax,(%esp)
80105022:	e8 14 01 00 00       	call   8010513b <holding>
80105027:	85 c0                	test   %eax,%eax
80105029:	74 0c                	je     80105037 <acquire+0x26>
    panic("acquire");
8010502b:	c7 04 24 31 8b 10 80 	movl   $0x80108b31,(%esp)
80105032:	e8 ab b6 ff ff       	call   801006e2 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105037:	90                   	nop
80105038:	8b 45 08             	mov    0x8(%ebp),%eax
8010503b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105042:	00 
80105043:	89 04 24             	mov    %eax,(%esp)
80105046:	e8 8b ff ff ff       	call   80104fd6 <xchg>
8010504b:	85 c0                	test   %eax,%eax
8010504d:	75 e9                	jne    80105038 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
8010504f:	8b 45 08             	mov    0x8(%ebp),%eax
80105052:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105059:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
8010505c:	8b 45 08             	mov    0x8(%ebp),%eax
8010505f:	83 c0 0c             	add    $0xc,%eax
80105062:	89 44 24 04          	mov    %eax,0x4(%esp)
80105066:	8d 45 08             	lea    0x8(%ebp),%eax
80105069:	89 04 24             	mov    %eax,(%esp)
8010506c:	e8 51 00 00 00       	call   801050c2 <getcallerpcs>
}
80105071:	c9                   	leave  
80105072:	c3                   	ret    

80105073 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105073:	55                   	push   %ebp
80105074:	89 e5                	mov    %esp,%ebp
80105076:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105079:	8b 45 08             	mov    0x8(%ebp),%eax
8010507c:	89 04 24             	mov    %eax,(%esp)
8010507f:	e8 b7 00 00 00       	call   8010513b <holding>
80105084:	85 c0                	test   %eax,%eax
80105086:	75 0c                	jne    80105094 <release+0x21>
    panic("release");
80105088:	c7 04 24 39 8b 10 80 	movl   $0x80108b39,(%esp)
8010508f:	e8 4e b6 ff ff       	call   801006e2 <panic>

  lk->pcs[0] = 0;
80105094:	8b 45 08             	mov    0x8(%ebp),%eax
80105097:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010509e:	8b 45 08             	mov    0x8(%ebp),%eax
801050a1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
801050a8:	8b 45 08             	mov    0x8(%ebp),%eax
801050ab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801050b2:	00 
801050b3:	89 04 24             	mov    %eax,(%esp)
801050b6:	e8 1b ff ff ff       	call   80104fd6 <xchg>

  popcli();
801050bb:	e8 e9 00 00 00       	call   801051a9 <popcli>
}
801050c0:	c9                   	leave  
801050c1:	c3                   	ret    

801050c2 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801050c2:	55                   	push   %ebp
801050c3:	89 e5                	mov    %esp,%ebp
801050c5:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
801050c8:	8b 45 08             	mov    0x8(%ebp),%eax
801050cb:	83 e8 08             	sub    $0x8,%eax
801050ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801050d1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801050d8:	eb 38                	jmp    80105112 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801050da:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801050de:	74 38                	je     80105118 <getcallerpcs+0x56>
801050e0:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801050e7:	76 2f                	jbe    80105118 <getcallerpcs+0x56>
801050e9:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801050ed:	74 29                	je     80105118 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
801050ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050f2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801050f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801050fc:	01 c2                	add    %eax,%edx
801050fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105101:	8b 40 04             	mov    0x4(%eax),%eax
80105104:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105106:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105109:	8b 00                	mov    (%eax),%eax
8010510b:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010510e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105112:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105116:	7e c2                	jle    801050da <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105118:	eb 19                	jmp    80105133 <getcallerpcs+0x71>
    pcs[i] = 0;
8010511a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010511d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105124:	8b 45 0c             	mov    0xc(%ebp),%eax
80105127:	01 d0                	add    %edx,%eax
80105129:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010512f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105133:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105137:	7e e1                	jle    8010511a <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105139:	c9                   	leave  
8010513a:	c3                   	ret    

8010513b <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010513b:	55                   	push   %ebp
8010513c:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
8010513e:	8b 45 08             	mov    0x8(%ebp),%eax
80105141:	8b 00                	mov    (%eax),%eax
80105143:	85 c0                	test   %eax,%eax
80105145:	74 17                	je     8010515e <holding+0x23>
80105147:	8b 45 08             	mov    0x8(%ebp),%eax
8010514a:	8b 50 08             	mov    0x8(%eax),%edx
8010514d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105153:	39 c2                	cmp    %eax,%edx
80105155:	75 07                	jne    8010515e <holding+0x23>
80105157:	b8 01 00 00 00       	mov    $0x1,%eax
8010515c:	eb 05                	jmp    80105163 <holding+0x28>
8010515e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105163:	5d                   	pop    %ebp
80105164:	c3                   	ret    

80105165 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105165:	55                   	push   %ebp
80105166:	89 e5                	mov    %esp,%ebp
80105168:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
8010516b:	e8 4a fe ff ff       	call   80104fba <readeflags>
80105170:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105173:	e8 52 fe ff ff       	call   80104fca <cli>
  if(cpu->ncli++ == 0)
80105178:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010517f:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
80105185:	8d 48 01             	lea    0x1(%eax),%ecx
80105188:	89 8a b0 00 00 00    	mov    %ecx,0xb0(%edx)
8010518e:	85 c0                	test   %eax,%eax
80105190:	75 15                	jne    801051a7 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105192:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105198:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010519b:	81 e2 00 02 00 00    	and    $0x200,%edx
801051a1:	89 90 b4 00 00 00    	mov    %edx,0xb4(%eax)
}
801051a7:	c9                   	leave  
801051a8:	c3                   	ret    

801051a9 <popcli>:

void
popcli(void)
{
801051a9:	55                   	push   %ebp
801051aa:	89 e5                	mov    %esp,%ebp
801051ac:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
801051af:	e8 06 fe ff ff       	call   80104fba <readeflags>
801051b4:	25 00 02 00 00       	and    $0x200,%eax
801051b9:	85 c0                	test   %eax,%eax
801051bb:	74 0c                	je     801051c9 <popcli+0x20>
    panic("popcli - interruptible");
801051bd:	c7 04 24 41 8b 10 80 	movl   $0x80108b41,(%esp)
801051c4:	e8 19 b5 ff ff       	call   801006e2 <panic>
  if(--cpu->ncli < 0)
801051c9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051cf:	8b 90 b0 00 00 00    	mov    0xb0(%eax),%edx
801051d5:	83 ea 01             	sub    $0x1,%edx
801051d8:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
801051de:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801051e4:	85 c0                	test   %eax,%eax
801051e6:	79 0c                	jns    801051f4 <popcli+0x4b>
    panic("popcli");
801051e8:	c7 04 24 58 8b 10 80 	movl   $0x80108b58,(%esp)
801051ef:	e8 ee b4 ff ff       	call   801006e2 <panic>
  if(cpu->ncli == 0 && cpu->intena)
801051f4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051fa:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105200:	85 c0                	test   %eax,%eax
80105202:	75 15                	jne    80105219 <popcli+0x70>
80105204:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010520a:	8b 80 b4 00 00 00    	mov    0xb4(%eax),%eax
80105210:	85 c0                	test   %eax,%eax
80105212:	74 05                	je     80105219 <popcli+0x70>
    sti();
80105214:	e8 b7 fd ff ff       	call   80104fd0 <sti>
}
80105219:	c9                   	leave  
8010521a:	c3                   	ret    

8010521b <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
8010521b:	55                   	push   %ebp
8010521c:	89 e5                	mov    %esp,%ebp
8010521e:	57                   	push   %edi
8010521f:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105220:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105223:	8b 55 10             	mov    0x10(%ebp),%edx
80105226:	8b 45 0c             	mov    0xc(%ebp),%eax
80105229:	89 cb                	mov    %ecx,%ebx
8010522b:	89 df                	mov    %ebx,%edi
8010522d:	89 d1                	mov    %edx,%ecx
8010522f:	fc                   	cld    
80105230:	f3 aa                	rep stos %al,%es:(%edi)
80105232:	89 ca                	mov    %ecx,%edx
80105234:	89 fb                	mov    %edi,%ebx
80105236:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105239:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010523c:	5b                   	pop    %ebx
8010523d:	5f                   	pop    %edi
8010523e:	5d                   	pop    %ebp
8010523f:	c3                   	ret    

80105240 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105240:	55                   	push   %ebp
80105241:	89 e5                	mov    %esp,%ebp
80105243:	57                   	push   %edi
80105244:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105245:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105248:	8b 55 10             	mov    0x10(%ebp),%edx
8010524b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010524e:	89 cb                	mov    %ecx,%ebx
80105250:	89 df                	mov    %ebx,%edi
80105252:	89 d1                	mov    %edx,%ecx
80105254:	fc                   	cld    
80105255:	f3 ab                	rep stos %eax,%es:(%edi)
80105257:	89 ca                	mov    %ecx,%edx
80105259:	89 fb                	mov    %edi,%ebx
8010525b:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010525e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105261:	5b                   	pop    %ebx
80105262:	5f                   	pop    %edi
80105263:	5d                   	pop    %ebp
80105264:	c3                   	ret    

80105265 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105265:	55                   	push   %ebp
80105266:	89 e5                	mov    %esp,%ebp
80105268:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
8010526b:	8b 45 08             	mov    0x8(%ebp),%eax
8010526e:	83 e0 03             	and    $0x3,%eax
80105271:	85 c0                	test   %eax,%eax
80105273:	75 49                	jne    801052be <memset+0x59>
80105275:	8b 45 10             	mov    0x10(%ebp),%eax
80105278:	83 e0 03             	and    $0x3,%eax
8010527b:	85 c0                	test   %eax,%eax
8010527d:	75 3f                	jne    801052be <memset+0x59>
    c &= 0xFF;
8010527f:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105286:	8b 45 10             	mov    0x10(%ebp),%eax
80105289:	c1 e8 02             	shr    $0x2,%eax
8010528c:	89 c2                	mov    %eax,%edx
8010528e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105291:	c1 e0 18             	shl    $0x18,%eax
80105294:	89 c1                	mov    %eax,%ecx
80105296:	8b 45 0c             	mov    0xc(%ebp),%eax
80105299:	c1 e0 10             	shl    $0x10,%eax
8010529c:	09 c1                	or     %eax,%ecx
8010529e:	8b 45 0c             	mov    0xc(%ebp),%eax
801052a1:	c1 e0 08             	shl    $0x8,%eax
801052a4:	09 c8                	or     %ecx,%eax
801052a6:	0b 45 0c             	or     0xc(%ebp),%eax
801052a9:	89 54 24 08          	mov    %edx,0x8(%esp)
801052ad:	89 44 24 04          	mov    %eax,0x4(%esp)
801052b1:	8b 45 08             	mov    0x8(%ebp),%eax
801052b4:	89 04 24             	mov    %eax,(%esp)
801052b7:	e8 84 ff ff ff       	call   80105240 <stosl>
801052bc:	eb 19                	jmp    801052d7 <memset+0x72>
  } else
    stosb(dst, c, n);
801052be:	8b 45 10             	mov    0x10(%ebp),%eax
801052c1:	89 44 24 08          	mov    %eax,0x8(%esp)
801052c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801052c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801052cc:	8b 45 08             	mov    0x8(%ebp),%eax
801052cf:	89 04 24             	mov    %eax,(%esp)
801052d2:	e8 44 ff ff ff       	call   8010521b <stosb>
  return dst;
801052d7:	8b 45 08             	mov    0x8(%ebp),%eax
}
801052da:	c9                   	leave  
801052db:	c3                   	ret    

801052dc <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801052dc:	55                   	push   %ebp
801052dd:	89 e5                	mov    %esp,%ebp
801052df:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
801052e2:	8b 45 08             	mov    0x8(%ebp),%eax
801052e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801052e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801052eb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801052ee:	eb 30                	jmp    80105320 <memcmp+0x44>
    if(*s1 != *s2)
801052f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052f3:	0f b6 10             	movzbl (%eax),%edx
801052f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052f9:	0f b6 00             	movzbl (%eax),%eax
801052fc:	38 c2                	cmp    %al,%dl
801052fe:	74 18                	je     80105318 <memcmp+0x3c>
      return *s1 - *s2;
80105300:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105303:	0f b6 00             	movzbl (%eax),%eax
80105306:	0f b6 d0             	movzbl %al,%edx
80105309:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010530c:	0f b6 00             	movzbl (%eax),%eax
8010530f:	0f b6 c0             	movzbl %al,%eax
80105312:	29 c2                	sub    %eax,%edx
80105314:	89 d0                	mov    %edx,%eax
80105316:	eb 1a                	jmp    80105332 <memcmp+0x56>
    s1++, s2++;
80105318:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010531c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105320:	8b 45 10             	mov    0x10(%ebp),%eax
80105323:	8d 50 ff             	lea    -0x1(%eax),%edx
80105326:	89 55 10             	mov    %edx,0x10(%ebp)
80105329:	85 c0                	test   %eax,%eax
8010532b:	75 c3                	jne    801052f0 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010532d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105332:	c9                   	leave  
80105333:	c3                   	ret    

80105334 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105334:	55                   	push   %ebp
80105335:	89 e5                	mov    %esp,%ebp
80105337:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010533a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010533d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105340:	8b 45 08             	mov    0x8(%ebp),%eax
80105343:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105346:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105349:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010534c:	73 3d                	jae    8010538b <memmove+0x57>
8010534e:	8b 45 10             	mov    0x10(%ebp),%eax
80105351:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105354:	01 d0                	add    %edx,%eax
80105356:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105359:	76 30                	jbe    8010538b <memmove+0x57>
    s += n;
8010535b:	8b 45 10             	mov    0x10(%ebp),%eax
8010535e:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105361:	8b 45 10             	mov    0x10(%ebp),%eax
80105364:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105367:	eb 13                	jmp    8010537c <memmove+0x48>
      *--d = *--s;
80105369:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010536d:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105371:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105374:	0f b6 10             	movzbl (%eax),%edx
80105377:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010537a:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010537c:	8b 45 10             	mov    0x10(%ebp),%eax
8010537f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105382:	89 55 10             	mov    %edx,0x10(%ebp)
80105385:	85 c0                	test   %eax,%eax
80105387:	75 e0                	jne    80105369 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105389:	eb 26                	jmp    801053b1 <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010538b:	eb 17                	jmp    801053a4 <memmove+0x70>
      *d++ = *s++;
8010538d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105390:	8d 50 01             	lea    0x1(%eax),%edx
80105393:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105396:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105399:	8d 4a 01             	lea    0x1(%edx),%ecx
8010539c:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010539f:	0f b6 12             	movzbl (%edx),%edx
801053a2:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801053a4:	8b 45 10             	mov    0x10(%ebp),%eax
801053a7:	8d 50 ff             	lea    -0x1(%eax),%edx
801053aa:	89 55 10             	mov    %edx,0x10(%ebp)
801053ad:	85 c0                	test   %eax,%eax
801053af:	75 dc                	jne    8010538d <memmove+0x59>
      *d++ = *s++;

  return dst;
801053b1:	8b 45 08             	mov    0x8(%ebp),%eax
}
801053b4:	c9                   	leave  
801053b5:	c3                   	ret    

801053b6 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801053b6:	55                   	push   %ebp
801053b7:	89 e5                	mov    %esp,%ebp
801053b9:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
801053bc:	8b 45 10             	mov    0x10(%ebp),%eax
801053bf:	89 44 24 08          	mov    %eax,0x8(%esp)
801053c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801053c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801053ca:	8b 45 08             	mov    0x8(%ebp),%eax
801053cd:	89 04 24             	mov    %eax,(%esp)
801053d0:	e8 5f ff ff ff       	call   80105334 <memmove>
}
801053d5:	c9                   	leave  
801053d6:	c3                   	ret    

801053d7 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801053d7:	55                   	push   %ebp
801053d8:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801053da:	eb 0c                	jmp    801053e8 <strncmp+0x11>
    n--, p++, q++;
801053dc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801053e0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801053e4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801053e8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053ec:	74 1a                	je     80105408 <strncmp+0x31>
801053ee:	8b 45 08             	mov    0x8(%ebp),%eax
801053f1:	0f b6 00             	movzbl (%eax),%eax
801053f4:	84 c0                	test   %al,%al
801053f6:	74 10                	je     80105408 <strncmp+0x31>
801053f8:	8b 45 08             	mov    0x8(%ebp),%eax
801053fb:	0f b6 10             	movzbl (%eax),%edx
801053fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80105401:	0f b6 00             	movzbl (%eax),%eax
80105404:	38 c2                	cmp    %al,%dl
80105406:	74 d4                	je     801053dc <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105408:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010540c:	75 07                	jne    80105415 <strncmp+0x3e>
    return 0;
8010540e:	b8 00 00 00 00       	mov    $0x0,%eax
80105413:	eb 16                	jmp    8010542b <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105415:	8b 45 08             	mov    0x8(%ebp),%eax
80105418:	0f b6 00             	movzbl (%eax),%eax
8010541b:	0f b6 d0             	movzbl %al,%edx
8010541e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105421:	0f b6 00             	movzbl (%eax),%eax
80105424:	0f b6 c0             	movzbl %al,%eax
80105427:	29 c2                	sub    %eax,%edx
80105429:	89 d0                	mov    %edx,%eax
}
8010542b:	5d                   	pop    %ebp
8010542c:	c3                   	ret    

8010542d <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010542d:	55                   	push   %ebp
8010542e:	89 e5                	mov    %esp,%ebp
80105430:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105433:	8b 45 08             	mov    0x8(%ebp),%eax
80105436:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105439:	90                   	nop
8010543a:	8b 45 10             	mov    0x10(%ebp),%eax
8010543d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105440:	89 55 10             	mov    %edx,0x10(%ebp)
80105443:	85 c0                	test   %eax,%eax
80105445:	7e 1e                	jle    80105465 <strncpy+0x38>
80105447:	8b 45 08             	mov    0x8(%ebp),%eax
8010544a:	8d 50 01             	lea    0x1(%eax),%edx
8010544d:	89 55 08             	mov    %edx,0x8(%ebp)
80105450:	8b 55 0c             	mov    0xc(%ebp),%edx
80105453:	8d 4a 01             	lea    0x1(%edx),%ecx
80105456:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105459:	0f b6 12             	movzbl (%edx),%edx
8010545c:	88 10                	mov    %dl,(%eax)
8010545e:	0f b6 00             	movzbl (%eax),%eax
80105461:	84 c0                	test   %al,%al
80105463:	75 d5                	jne    8010543a <strncpy+0xd>
    ;
  while(n-- > 0)
80105465:	eb 0c                	jmp    80105473 <strncpy+0x46>
    *s++ = 0;
80105467:	8b 45 08             	mov    0x8(%ebp),%eax
8010546a:	8d 50 01             	lea    0x1(%eax),%edx
8010546d:	89 55 08             	mov    %edx,0x8(%ebp)
80105470:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105473:	8b 45 10             	mov    0x10(%ebp),%eax
80105476:	8d 50 ff             	lea    -0x1(%eax),%edx
80105479:	89 55 10             	mov    %edx,0x10(%ebp)
8010547c:	85 c0                	test   %eax,%eax
8010547e:	7f e7                	jg     80105467 <strncpy+0x3a>
    *s++ = 0;
  return os;
80105480:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105483:	c9                   	leave  
80105484:	c3                   	ret    

80105485 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105485:	55                   	push   %ebp
80105486:	89 e5                	mov    %esp,%ebp
80105488:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010548b:	8b 45 08             	mov    0x8(%ebp),%eax
8010548e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105491:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105495:	7f 05                	jg     8010549c <safestrcpy+0x17>
    return os;
80105497:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010549a:	eb 31                	jmp    801054cd <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
8010549c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801054a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054a4:	7e 1e                	jle    801054c4 <safestrcpy+0x3f>
801054a6:	8b 45 08             	mov    0x8(%ebp),%eax
801054a9:	8d 50 01             	lea    0x1(%eax),%edx
801054ac:	89 55 08             	mov    %edx,0x8(%ebp)
801054af:	8b 55 0c             	mov    0xc(%ebp),%edx
801054b2:	8d 4a 01             	lea    0x1(%edx),%ecx
801054b5:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801054b8:	0f b6 12             	movzbl (%edx),%edx
801054bb:	88 10                	mov    %dl,(%eax)
801054bd:	0f b6 00             	movzbl (%eax),%eax
801054c0:	84 c0                	test   %al,%al
801054c2:	75 d8                	jne    8010549c <safestrcpy+0x17>
    ;
  *s = 0;
801054c4:	8b 45 08             	mov    0x8(%ebp),%eax
801054c7:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801054ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054cd:	c9                   	leave  
801054ce:	c3                   	ret    

801054cf <strlen>:

int
strlen(const char *s)
{
801054cf:	55                   	push   %ebp
801054d0:	89 e5                	mov    %esp,%ebp
801054d2:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801054d5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801054dc:	eb 04                	jmp    801054e2 <strlen+0x13>
801054de:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801054e2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054e5:	8b 45 08             	mov    0x8(%ebp),%eax
801054e8:	01 d0                	add    %edx,%eax
801054ea:	0f b6 00             	movzbl (%eax),%eax
801054ed:	84 c0                	test   %al,%al
801054ef:	75 ed                	jne    801054de <strlen+0xf>
    ;
  return n;
801054f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054f4:	c9                   	leave  
801054f5:	c3                   	ret    

801054f6 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801054f6:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801054fa:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801054fe:	55                   	push   %ebp
  pushl %ebx
801054ff:	53                   	push   %ebx
  pushl %esi
80105500:	56                   	push   %esi
  pushl %edi
80105501:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105502:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105504:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105506:	5f                   	pop    %edi
  popl %esi
80105507:	5e                   	pop    %esi
  popl %ebx
80105508:	5b                   	pop    %ebx
  popl %ebp
80105509:	5d                   	pop    %ebp
  ret
8010550a:	c3                   	ret    

8010550b <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010550b:	55                   	push   %ebp
8010550c:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
8010550e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105514:	8b 00                	mov    (%eax),%eax
80105516:	3b 45 08             	cmp    0x8(%ebp),%eax
80105519:	76 12                	jbe    8010552d <fetchint+0x22>
8010551b:	8b 45 08             	mov    0x8(%ebp),%eax
8010551e:	8d 50 04             	lea    0x4(%eax),%edx
80105521:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105527:	8b 00                	mov    (%eax),%eax
80105529:	39 c2                	cmp    %eax,%edx
8010552b:	76 07                	jbe    80105534 <fetchint+0x29>
    return -1;
8010552d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105532:	eb 0f                	jmp    80105543 <fetchint+0x38>
  *ip = *(int*)(addr);
80105534:	8b 45 08             	mov    0x8(%ebp),%eax
80105537:	8b 10                	mov    (%eax),%edx
80105539:	8b 45 0c             	mov    0xc(%ebp),%eax
8010553c:	89 10                	mov    %edx,(%eax)
  return 0;
8010553e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105543:	5d                   	pop    %ebp
80105544:	c3                   	ret    

80105545 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105545:	55                   	push   %ebp
80105546:	89 e5                	mov    %esp,%ebp
80105548:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
8010554b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105551:	8b 00                	mov    (%eax),%eax
80105553:	3b 45 08             	cmp    0x8(%ebp),%eax
80105556:	77 07                	ja     8010555f <fetchstr+0x1a>
    return -1;
80105558:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010555d:	eb 46                	jmp    801055a5 <fetchstr+0x60>
  *pp = (char*)addr;
8010555f:	8b 55 08             	mov    0x8(%ebp),%edx
80105562:	8b 45 0c             	mov    0xc(%ebp),%eax
80105565:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105567:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010556d:	8b 00                	mov    (%eax),%eax
8010556f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105572:	8b 45 0c             	mov    0xc(%ebp),%eax
80105575:	8b 00                	mov    (%eax),%eax
80105577:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010557a:	eb 1c                	jmp    80105598 <fetchstr+0x53>
    if(*s == 0)
8010557c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010557f:	0f b6 00             	movzbl (%eax),%eax
80105582:	84 c0                	test   %al,%al
80105584:	75 0e                	jne    80105594 <fetchstr+0x4f>
      return s - *pp;
80105586:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105589:	8b 45 0c             	mov    0xc(%ebp),%eax
8010558c:	8b 00                	mov    (%eax),%eax
8010558e:	29 c2                	sub    %eax,%edx
80105590:	89 d0                	mov    %edx,%eax
80105592:	eb 11                	jmp    801055a5 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105594:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105598:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010559b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010559e:	72 dc                	jb     8010557c <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
801055a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055a5:	c9                   	leave  
801055a6:	c3                   	ret    

801055a7 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801055a7:	55                   	push   %ebp
801055a8:	89 e5                	mov    %esp,%ebp
801055aa:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801055ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055b3:	8b 40 18             	mov    0x18(%eax),%eax
801055b6:	8b 50 44             	mov    0x44(%eax),%edx
801055b9:	8b 45 08             	mov    0x8(%ebp),%eax
801055bc:	c1 e0 02             	shl    $0x2,%eax
801055bf:	01 d0                	add    %edx,%eax
801055c1:	8d 50 04             	lea    0x4(%eax),%edx
801055c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801055c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801055cb:	89 14 24             	mov    %edx,(%esp)
801055ce:	e8 38 ff ff ff       	call   8010550b <fetchint>
}
801055d3:	c9                   	leave  
801055d4:	c3                   	ret    

801055d5 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801055d5:	55                   	push   %ebp
801055d6:	89 e5                	mov    %esp,%ebp
801055d8:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
801055db:	8d 45 fc             	lea    -0x4(%ebp),%eax
801055de:	89 44 24 04          	mov    %eax,0x4(%esp)
801055e2:	8b 45 08             	mov    0x8(%ebp),%eax
801055e5:	89 04 24             	mov    %eax,(%esp)
801055e8:	e8 ba ff ff ff       	call   801055a7 <argint>
801055ed:	85 c0                	test   %eax,%eax
801055ef:	79 07                	jns    801055f8 <argptr+0x23>
    return -1;
801055f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055f6:	eb 3d                	jmp    80105635 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801055f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055fb:	89 c2                	mov    %eax,%edx
801055fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105603:	8b 00                	mov    (%eax),%eax
80105605:	39 c2                	cmp    %eax,%edx
80105607:	73 16                	jae    8010561f <argptr+0x4a>
80105609:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010560c:	89 c2                	mov    %eax,%edx
8010560e:	8b 45 10             	mov    0x10(%ebp),%eax
80105611:	01 c2                	add    %eax,%edx
80105613:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105619:	8b 00                	mov    (%eax),%eax
8010561b:	39 c2                	cmp    %eax,%edx
8010561d:	76 07                	jbe    80105626 <argptr+0x51>
    return -1;
8010561f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105624:	eb 0f                	jmp    80105635 <argptr+0x60>
  *pp = (char*)i;
80105626:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105629:	89 c2                	mov    %eax,%edx
8010562b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010562e:	89 10                	mov    %edx,(%eax)
  return 0;
80105630:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105635:	c9                   	leave  
80105636:	c3                   	ret    

80105637 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105637:	55                   	push   %ebp
80105638:	89 e5                	mov    %esp,%ebp
8010563a:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010563d:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105640:	89 44 24 04          	mov    %eax,0x4(%esp)
80105644:	8b 45 08             	mov    0x8(%ebp),%eax
80105647:	89 04 24             	mov    %eax,(%esp)
8010564a:	e8 58 ff ff ff       	call   801055a7 <argint>
8010564f:	85 c0                	test   %eax,%eax
80105651:	79 07                	jns    8010565a <argstr+0x23>
    return -1;
80105653:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105658:	eb 12                	jmp    8010566c <argstr+0x35>
  return fetchstr(addr, pp);
8010565a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010565d:	8b 55 0c             	mov    0xc(%ebp),%edx
80105660:	89 54 24 04          	mov    %edx,0x4(%esp)
80105664:	89 04 24             	mov    %eax,(%esp)
80105667:	e8 d9 fe ff ff       	call   80105545 <fetchstr>
}
8010566c:	c9                   	leave  
8010566d:	c3                   	ret    

8010566e <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
8010566e:	55                   	push   %ebp
8010566f:	89 e5                	mov    %esp,%ebp
80105671:	53                   	push   %ebx
80105672:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105675:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010567b:	8b 40 18             	mov    0x18(%eax),%eax
8010567e:	8b 40 1c             	mov    0x1c(%eax),%eax
80105681:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105684:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105688:	7e 30                	jle    801056ba <syscall+0x4c>
8010568a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010568d:	83 f8 15             	cmp    $0x15,%eax
80105690:	77 28                	ja     801056ba <syscall+0x4c>
80105692:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105695:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010569c:	85 c0                	test   %eax,%eax
8010569e:	74 1a                	je     801056ba <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
801056a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056a6:	8b 58 18             	mov    0x18(%eax),%ebx
801056a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ac:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801056b3:	ff d0                	call   *%eax
801056b5:	89 43 1c             	mov    %eax,0x1c(%ebx)
801056b8:	eb 3d                	jmp    801056f7 <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801056ba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056c0:	8d 48 6c             	lea    0x6c(%eax),%ecx
801056c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801056c9:	8b 40 10             	mov    0x10(%eax),%eax
801056cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801056cf:	89 54 24 0c          	mov    %edx,0xc(%esp)
801056d3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801056d7:	89 44 24 04          	mov    %eax,0x4(%esp)
801056db:	c7 04 24 5f 8b 10 80 	movl   $0x80108b5f,(%esp)
801056e2:	e8 b9 ac ff ff       	call   801003a0 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801056e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056ed:	8b 40 18             	mov    0x18(%eax),%eax
801056f0:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801056f7:	83 c4 24             	add    $0x24,%esp
801056fa:	5b                   	pop    %ebx
801056fb:	5d                   	pop    %ebp
801056fc:	c3                   	ret    

801056fd <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801056fd:	55                   	push   %ebp
801056fe:	89 e5                	mov    %esp,%ebp
80105700:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105703:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105706:	89 44 24 04          	mov    %eax,0x4(%esp)
8010570a:	8b 45 08             	mov    0x8(%ebp),%eax
8010570d:	89 04 24             	mov    %eax,(%esp)
80105710:	e8 92 fe ff ff       	call   801055a7 <argint>
80105715:	85 c0                	test   %eax,%eax
80105717:	79 07                	jns    80105720 <argfd+0x23>
    return -1;
80105719:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010571e:	eb 50                	jmp    80105770 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105720:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105723:	85 c0                	test   %eax,%eax
80105725:	78 21                	js     80105748 <argfd+0x4b>
80105727:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010572a:	83 f8 0f             	cmp    $0xf,%eax
8010572d:	7f 19                	jg     80105748 <argfd+0x4b>
8010572f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105735:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105738:	83 c2 08             	add    $0x8,%edx
8010573b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010573f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105742:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105746:	75 07                	jne    8010574f <argfd+0x52>
    return -1;
80105748:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010574d:	eb 21                	jmp    80105770 <argfd+0x73>
  if(pfd)
8010574f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105753:	74 08                	je     8010575d <argfd+0x60>
    *pfd = fd;
80105755:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105758:	8b 45 0c             	mov    0xc(%ebp),%eax
8010575b:	89 10                	mov    %edx,(%eax)
  if(pf)
8010575d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105761:	74 08                	je     8010576b <argfd+0x6e>
    *pf = f;
80105763:	8b 45 10             	mov    0x10(%ebp),%eax
80105766:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105769:	89 10                	mov    %edx,(%eax)
  return 0;
8010576b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105770:	c9                   	leave  
80105771:	c3                   	ret    

80105772 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105772:	55                   	push   %ebp
80105773:	89 e5                	mov    %esp,%ebp
80105775:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105778:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010577f:	eb 30                	jmp    801057b1 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105781:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105787:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010578a:	83 c2 08             	add    $0x8,%edx
8010578d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105791:	85 c0                	test   %eax,%eax
80105793:	75 18                	jne    801057ad <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105795:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010579b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010579e:	8d 4a 08             	lea    0x8(%edx),%ecx
801057a1:	8b 55 08             	mov    0x8(%ebp),%edx
801057a4:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801057a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057ab:	eb 0f                	jmp    801057bc <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801057ad:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057b1:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801057b5:	7e ca                	jle    80105781 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801057b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057bc:	c9                   	leave  
801057bd:	c3                   	ret    

801057be <sys_dup>:

int
sys_dup(void)
{
801057be:	55                   	push   %ebp
801057bf:	89 e5                	mov    %esp,%ebp
801057c1:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801057c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057c7:	89 44 24 08          	mov    %eax,0x8(%esp)
801057cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801057d2:	00 
801057d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801057da:	e8 1e ff ff ff       	call   801056fd <argfd>
801057df:	85 c0                	test   %eax,%eax
801057e1:	79 07                	jns    801057ea <sys_dup+0x2c>
    return -1;
801057e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057e8:	eb 29                	jmp    80105813 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801057ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057ed:	89 04 24             	mov    %eax,(%esp)
801057f0:	e8 7d ff ff ff       	call   80105772 <fdalloc>
801057f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057fc:	79 07                	jns    80105805 <sys_dup+0x47>
    return -1;
801057fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105803:	eb 0e                	jmp    80105813 <sys_dup+0x55>
  filedup(f);
80105805:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105808:	89 04 24             	mov    %eax,(%esp)
8010580b:	e8 50 b9 ff ff       	call   80101160 <filedup>
  return fd;
80105810:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105813:	c9                   	leave  
80105814:	c3                   	ret    

80105815 <sys_read>:

int
sys_read(void)
{
80105815:	55                   	push   %ebp
80105816:	89 e5                	mov    %esp,%ebp
80105818:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010581b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010581e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105822:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105829:	00 
8010582a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105831:	e8 c7 fe ff ff       	call   801056fd <argfd>
80105836:	85 c0                	test   %eax,%eax
80105838:	78 35                	js     8010586f <sys_read+0x5a>
8010583a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010583d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105841:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105848:	e8 5a fd ff ff       	call   801055a7 <argint>
8010584d:	85 c0                	test   %eax,%eax
8010584f:	78 1e                	js     8010586f <sys_read+0x5a>
80105851:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105854:	89 44 24 08          	mov    %eax,0x8(%esp)
80105858:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010585b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010585f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105866:	e8 6a fd ff ff       	call   801055d5 <argptr>
8010586b:	85 c0                	test   %eax,%eax
8010586d:	79 07                	jns    80105876 <sys_read+0x61>
    return -1;
8010586f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105874:	eb 19                	jmp    8010588f <sys_read+0x7a>
  return fileread(f, p, n);
80105876:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105879:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010587c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010587f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105883:	89 54 24 04          	mov    %edx,0x4(%esp)
80105887:	89 04 24             	mov    %eax,(%esp)
8010588a:	e8 3e ba ff ff       	call   801012cd <fileread>
}
8010588f:	c9                   	leave  
80105890:	c3                   	ret    

80105891 <sys_write>:

int
sys_write(void)
{
80105891:	55                   	push   %ebp
80105892:	89 e5                	mov    %esp,%ebp
80105894:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105897:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010589a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010589e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801058a5:	00 
801058a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801058ad:	e8 4b fe ff ff       	call   801056fd <argfd>
801058b2:	85 c0                	test   %eax,%eax
801058b4:	78 35                	js     801058eb <sys_write+0x5a>
801058b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801058bd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801058c4:	e8 de fc ff ff       	call   801055a7 <argint>
801058c9:	85 c0                	test   %eax,%eax
801058cb:	78 1e                	js     801058eb <sys_write+0x5a>
801058cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058d0:	89 44 24 08          	mov    %eax,0x8(%esp)
801058d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058d7:	89 44 24 04          	mov    %eax,0x4(%esp)
801058db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801058e2:	e8 ee fc ff ff       	call   801055d5 <argptr>
801058e7:	85 c0                	test   %eax,%eax
801058e9:	79 07                	jns    801058f2 <sys_write+0x61>
    return -1;
801058eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058f0:	eb 19                	jmp    8010590b <sys_write+0x7a>
  return filewrite(f, p, n);
801058f2:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801058f5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801058f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058fb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801058ff:	89 54 24 04          	mov    %edx,0x4(%esp)
80105903:	89 04 24             	mov    %eax,(%esp)
80105906:	e8 7e ba ff ff       	call   80101389 <filewrite>
}
8010590b:	c9                   	leave  
8010590c:	c3                   	ret    

8010590d <sys_close>:

int
sys_close(void)
{
8010590d:	55                   	push   %ebp
8010590e:	89 e5                	mov    %esp,%ebp
80105910:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105913:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105916:	89 44 24 08          	mov    %eax,0x8(%esp)
8010591a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010591d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105921:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105928:	e8 d0 fd ff ff       	call   801056fd <argfd>
8010592d:	85 c0                	test   %eax,%eax
8010592f:	79 07                	jns    80105938 <sys_close+0x2b>
    return -1;
80105931:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105936:	eb 24                	jmp    8010595c <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105938:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010593e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105941:	83 c2 08             	add    $0x8,%edx
80105944:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010594b:	00 
  fileclose(f);
8010594c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010594f:	89 04 24             	mov    %eax,(%esp)
80105952:	e8 51 b8 ff ff       	call   801011a8 <fileclose>
  return 0;
80105957:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010595c:	c9                   	leave  
8010595d:	c3                   	ret    

8010595e <sys_fstat>:

int
sys_fstat(void)
{
8010595e:	55                   	push   %ebp
8010595f:	89 e5                	mov    %esp,%ebp
80105961:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105964:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105967:	89 44 24 08          	mov    %eax,0x8(%esp)
8010596b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105972:	00 
80105973:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010597a:	e8 7e fd ff ff       	call   801056fd <argfd>
8010597f:	85 c0                	test   %eax,%eax
80105981:	78 1f                	js     801059a2 <sys_fstat+0x44>
80105983:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010598a:	00 
8010598b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010598e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105992:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105999:	e8 37 fc ff ff       	call   801055d5 <argptr>
8010599e:	85 c0                	test   %eax,%eax
801059a0:	79 07                	jns    801059a9 <sys_fstat+0x4b>
    return -1;
801059a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059a7:	eb 12                	jmp    801059bb <sys_fstat+0x5d>
  return filestat(f, st);
801059a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059af:	89 54 24 04          	mov    %edx,0x4(%esp)
801059b3:	89 04 24             	mov    %eax,(%esp)
801059b6:	e8 c3 b8 ff ff       	call   8010127e <filestat>
}
801059bb:	c9                   	leave  
801059bc:	c3                   	ret    

801059bd <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801059bd:	55                   	push   %ebp
801059be:	89 e5                	mov    %esp,%ebp
801059c0:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801059c3:	8d 45 d8             	lea    -0x28(%ebp),%eax
801059c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801059ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801059d1:	e8 61 fc ff ff       	call   80105637 <argstr>
801059d6:	85 c0                	test   %eax,%eax
801059d8:	78 17                	js     801059f1 <sys_link+0x34>
801059da:	8d 45 dc             	lea    -0x24(%ebp),%eax
801059dd:	89 44 24 04          	mov    %eax,0x4(%esp)
801059e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801059e8:	e8 4a fc ff ff       	call   80105637 <argstr>
801059ed:	85 c0                	test   %eax,%eax
801059ef:	79 0a                	jns    801059fb <sys_link+0x3e>
    return -1;
801059f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059f6:	e9 42 01 00 00       	jmp    80105b3d <sys_link+0x180>

  begin_op();
801059fb:	e8 ea db ff ff       	call   801035ea <begin_op>
  if((ip = namei(old)) == 0){
80105a00:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105a03:	89 04 24             	mov    %eax,(%esp)
80105a06:	e8 d5 cb ff ff       	call   801025e0 <namei>
80105a0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a0e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a12:	75 0f                	jne    80105a23 <sys_link+0x66>
    end_op();
80105a14:	e8 55 dc ff ff       	call   8010366e <end_op>
    return -1;
80105a19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a1e:	e9 1a 01 00 00       	jmp    80105b3d <sys_link+0x180>
  }

  ilock(ip);
80105a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a26:	89 04 24             	mov    %eax,(%esp)
80105a29:	e8 07 c0 ff ff       	call   80101a35 <ilock>
  if(ip->type == T_DIR){
80105a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a31:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105a35:	66 83 f8 01          	cmp    $0x1,%ax
80105a39:	75 1a                	jne    80105a55 <sys_link+0x98>
    iunlockput(ip);
80105a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a3e:	89 04 24             	mov    %eax,(%esp)
80105a41:	e8 73 c2 ff ff       	call   80101cb9 <iunlockput>
    end_op();
80105a46:	e8 23 dc ff ff       	call   8010366e <end_op>
    return -1;
80105a4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a50:	e9 e8 00 00 00       	jmp    80105b3d <sys_link+0x180>
  }

  ip->nlink++;
80105a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a58:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105a5c:	8d 50 01             	lea    0x1(%eax),%edx
80105a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a62:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a69:	89 04 24             	mov    %eax,(%esp)
80105a6c:	e8 08 be ff ff       	call   80101879 <iupdate>
  iunlock(ip);
80105a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a74:	89 04 24             	mov    %eax,(%esp)
80105a77:	e8 07 c1 ff ff       	call   80101b83 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105a7c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105a7f:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105a82:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a86:	89 04 24             	mov    %eax,(%esp)
80105a89:	e8 74 cb ff ff       	call   80102602 <nameiparent>
80105a8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a91:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a95:	75 02                	jne    80105a99 <sys_link+0xdc>
    goto bad;
80105a97:	eb 68                	jmp    80105b01 <sys_link+0x144>
  ilock(dp);
80105a99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a9c:	89 04 24             	mov    %eax,(%esp)
80105a9f:	e8 91 bf ff ff       	call   80101a35 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105aa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aa7:	8b 10                	mov    (%eax),%edx
80105aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aac:	8b 00                	mov    (%eax),%eax
80105aae:	39 c2                	cmp    %eax,%edx
80105ab0:	75 20                	jne    80105ad2 <sys_link+0x115>
80105ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab5:	8b 40 04             	mov    0x4(%eax),%eax
80105ab8:	89 44 24 08          	mov    %eax,0x8(%esp)
80105abc:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105abf:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ac3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ac6:	89 04 24             	mov    %eax,(%esp)
80105ac9:	e8 52 c8 ff ff       	call   80102320 <dirlink>
80105ace:	85 c0                	test   %eax,%eax
80105ad0:	79 0d                	jns    80105adf <sys_link+0x122>
    iunlockput(dp);
80105ad2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad5:	89 04 24             	mov    %eax,(%esp)
80105ad8:	e8 dc c1 ff ff       	call   80101cb9 <iunlockput>
    goto bad;
80105add:	eb 22                	jmp    80105b01 <sys_link+0x144>
  }
  iunlockput(dp);
80105adf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae2:	89 04 24             	mov    %eax,(%esp)
80105ae5:	e8 cf c1 ff ff       	call   80101cb9 <iunlockput>
  iput(ip);
80105aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aed:	89 04 24             	mov    %eax,(%esp)
80105af0:	e8 f3 c0 ff ff       	call   80101be8 <iput>

  end_op();
80105af5:	e8 74 db ff ff       	call   8010366e <end_op>

  return 0;
80105afa:	b8 00 00 00 00       	mov    $0x0,%eax
80105aff:	eb 3c                	jmp    80105b3d <sys_link+0x180>

bad:
  ilock(ip);
80105b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b04:	89 04 24             	mov    %eax,(%esp)
80105b07:	e8 29 bf ff ff       	call   80101a35 <ilock>
  ip->nlink--;
80105b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b0f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b13:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b19:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b20:	89 04 24             	mov    %eax,(%esp)
80105b23:	e8 51 bd ff ff       	call   80101879 <iupdate>
  iunlockput(ip);
80105b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b2b:	89 04 24             	mov    %eax,(%esp)
80105b2e:	e8 86 c1 ff ff       	call   80101cb9 <iunlockput>
  end_op();
80105b33:	e8 36 db ff ff       	call   8010366e <end_op>
  return -1;
80105b38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b3d:	c9                   	leave  
80105b3e:	c3                   	ret    

80105b3f <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105b3f:	55                   	push   %ebp
80105b40:	89 e5                	mov    %esp,%ebp
80105b42:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b45:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105b4c:	eb 4b                	jmp    80105b99 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b51:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105b58:	00 
80105b59:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b5d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b60:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b64:	8b 45 08             	mov    0x8(%ebp),%eax
80105b67:	89 04 24             	mov    %eax,(%esp)
80105b6a:	e8 d3 c3 ff ff       	call   80101f42 <readi>
80105b6f:	83 f8 10             	cmp    $0x10,%eax
80105b72:	74 0c                	je     80105b80 <isdirempty+0x41>
      panic("isdirempty: readi");
80105b74:	c7 04 24 7b 8b 10 80 	movl   $0x80108b7b,(%esp)
80105b7b:	e8 62 ab ff ff       	call   801006e2 <panic>
    if(de.inum != 0)
80105b80:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105b84:	66 85 c0             	test   %ax,%ax
80105b87:	74 07                	je     80105b90 <isdirempty+0x51>
      return 0;
80105b89:	b8 00 00 00 00       	mov    $0x0,%eax
80105b8e:	eb 1b                	jmp    80105bab <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b93:	83 c0 10             	add    $0x10,%eax
80105b96:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b99:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b9c:	8b 45 08             	mov    0x8(%ebp),%eax
80105b9f:	8b 40 18             	mov    0x18(%eax),%eax
80105ba2:	39 c2                	cmp    %eax,%edx
80105ba4:	72 a8                	jb     80105b4e <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105ba6:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105bab:	c9                   	leave  
80105bac:	c3                   	ret    

80105bad <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105bad:	55                   	push   %ebp
80105bae:	89 e5                	mov    %esp,%ebp
80105bb0:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105bb3:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105bb6:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105bc1:	e8 71 fa ff ff       	call   80105637 <argstr>
80105bc6:	85 c0                	test   %eax,%eax
80105bc8:	79 0a                	jns    80105bd4 <sys_unlink+0x27>
    return -1;
80105bca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bcf:	e9 af 01 00 00       	jmp    80105d83 <sys_unlink+0x1d6>

  begin_op();
80105bd4:	e8 11 da ff ff       	call   801035ea <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105bd9:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105bdc:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105bdf:	89 54 24 04          	mov    %edx,0x4(%esp)
80105be3:	89 04 24             	mov    %eax,(%esp)
80105be6:	e8 17 ca ff ff       	call   80102602 <nameiparent>
80105beb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bf2:	75 0f                	jne    80105c03 <sys_unlink+0x56>
    end_op();
80105bf4:	e8 75 da ff ff       	call   8010366e <end_op>
    return -1;
80105bf9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bfe:	e9 80 01 00 00       	jmp    80105d83 <sys_unlink+0x1d6>
  }

  ilock(dp);
80105c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c06:	89 04 24             	mov    %eax,(%esp)
80105c09:	e8 27 be ff ff       	call   80101a35 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105c0e:	c7 44 24 04 8d 8b 10 	movl   $0x80108b8d,0x4(%esp)
80105c15:	80 
80105c16:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c19:	89 04 24             	mov    %eax,(%esp)
80105c1c:	e8 14 c6 ff ff       	call   80102235 <namecmp>
80105c21:	85 c0                	test   %eax,%eax
80105c23:	0f 84 45 01 00 00    	je     80105d6e <sys_unlink+0x1c1>
80105c29:	c7 44 24 04 8f 8b 10 	movl   $0x80108b8f,0x4(%esp)
80105c30:	80 
80105c31:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c34:	89 04 24             	mov    %eax,(%esp)
80105c37:	e8 f9 c5 ff ff       	call   80102235 <namecmp>
80105c3c:	85 c0                	test   %eax,%eax
80105c3e:	0f 84 2a 01 00 00    	je     80105d6e <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105c44:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105c47:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c4b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c4e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c55:	89 04 24             	mov    %eax,(%esp)
80105c58:	e8 fa c5 ff ff       	call   80102257 <dirlookup>
80105c5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c60:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c64:	75 05                	jne    80105c6b <sys_unlink+0xbe>
    goto bad;
80105c66:	e9 03 01 00 00       	jmp    80105d6e <sys_unlink+0x1c1>
  ilock(ip);
80105c6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c6e:	89 04 24             	mov    %eax,(%esp)
80105c71:	e8 bf bd ff ff       	call   80101a35 <ilock>

  if(ip->nlink < 1)
80105c76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c79:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c7d:	66 85 c0             	test   %ax,%ax
80105c80:	7f 0c                	jg     80105c8e <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105c82:	c7 04 24 92 8b 10 80 	movl   $0x80108b92,(%esp)
80105c89:	e8 54 aa ff ff       	call   801006e2 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105c8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c91:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105c95:	66 83 f8 01          	cmp    $0x1,%ax
80105c99:	75 1f                	jne    80105cba <sys_unlink+0x10d>
80105c9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c9e:	89 04 24             	mov    %eax,(%esp)
80105ca1:	e8 99 fe ff ff       	call   80105b3f <isdirempty>
80105ca6:	85 c0                	test   %eax,%eax
80105ca8:	75 10                	jne    80105cba <sys_unlink+0x10d>
    iunlockput(ip);
80105caa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cad:	89 04 24             	mov    %eax,(%esp)
80105cb0:	e8 04 c0 ff ff       	call   80101cb9 <iunlockput>
    goto bad;
80105cb5:	e9 b4 00 00 00       	jmp    80105d6e <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80105cba:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105cc1:	00 
80105cc2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105cc9:	00 
80105cca:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ccd:	89 04 24             	mov    %eax,(%esp)
80105cd0:	e8 90 f5 ff ff       	call   80105265 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105cd5:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105cd8:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105cdf:	00 
80105ce0:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ce4:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ce7:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cee:	89 04 24             	mov    %eax,(%esp)
80105cf1:	e8 b0 c3 ff ff       	call   801020a6 <writei>
80105cf6:	83 f8 10             	cmp    $0x10,%eax
80105cf9:	74 0c                	je     80105d07 <sys_unlink+0x15a>
    panic("unlink: writei");
80105cfb:	c7 04 24 a4 8b 10 80 	movl   $0x80108ba4,(%esp)
80105d02:	e8 db a9 ff ff       	call   801006e2 <panic>
  if(ip->type == T_DIR){
80105d07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d0a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d0e:	66 83 f8 01          	cmp    $0x1,%ax
80105d12:	75 1c                	jne    80105d30 <sys_unlink+0x183>
    dp->nlink--;
80105d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d17:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d1b:	8d 50 ff             	lea    -0x1(%eax),%edx
80105d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d21:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d28:	89 04 24             	mov    %eax,(%esp)
80105d2b:	e8 49 bb ff ff       	call   80101879 <iupdate>
  }
  iunlockput(dp);
80105d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d33:	89 04 24             	mov    %eax,(%esp)
80105d36:	e8 7e bf ff ff       	call   80101cb9 <iunlockput>

  ip->nlink--;
80105d3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d3e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d42:	8d 50 ff             	lea    -0x1(%eax),%edx
80105d45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d48:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105d4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d4f:	89 04 24             	mov    %eax,(%esp)
80105d52:	e8 22 bb ff ff       	call   80101879 <iupdate>
  iunlockput(ip);
80105d57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d5a:	89 04 24             	mov    %eax,(%esp)
80105d5d:	e8 57 bf ff ff       	call   80101cb9 <iunlockput>

  end_op();
80105d62:	e8 07 d9 ff ff       	call   8010366e <end_op>

  return 0;
80105d67:	b8 00 00 00 00       	mov    $0x0,%eax
80105d6c:	eb 15                	jmp    80105d83 <sys_unlink+0x1d6>

bad:
  iunlockput(dp);
80105d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d71:	89 04 24             	mov    %eax,(%esp)
80105d74:	e8 40 bf ff ff       	call   80101cb9 <iunlockput>
  end_op();
80105d79:	e8 f0 d8 ff ff       	call   8010366e <end_op>
  return -1;
80105d7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d83:	c9                   	leave  
80105d84:	c3                   	ret    

80105d85 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105d85:	55                   	push   %ebp
80105d86:	89 e5                	mov    %esp,%ebp
80105d88:	83 ec 48             	sub    $0x48,%esp
80105d8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105d8e:	8b 55 10             	mov    0x10(%ebp),%edx
80105d91:	8b 45 14             	mov    0x14(%ebp),%eax
80105d94:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105d98:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105d9c:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105da0:	8d 45 de             	lea    -0x22(%ebp),%eax
80105da3:	89 44 24 04          	mov    %eax,0x4(%esp)
80105da7:	8b 45 08             	mov    0x8(%ebp),%eax
80105daa:	89 04 24             	mov    %eax,(%esp)
80105dad:	e8 50 c8 ff ff       	call   80102602 <nameiparent>
80105db2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105db5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105db9:	75 0a                	jne    80105dc5 <create+0x40>
    return 0;
80105dbb:	b8 00 00 00 00       	mov    $0x0,%eax
80105dc0:	e9 7e 01 00 00       	jmp    80105f43 <create+0x1be>
  ilock(dp);
80105dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dc8:	89 04 24             	mov    %eax,(%esp)
80105dcb:	e8 65 bc ff ff       	call   80101a35 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105dd0:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105dd3:	89 44 24 08          	mov    %eax,0x8(%esp)
80105dd7:	8d 45 de             	lea    -0x22(%ebp),%eax
80105dda:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de1:	89 04 24             	mov    %eax,(%esp)
80105de4:	e8 6e c4 ff ff       	call   80102257 <dirlookup>
80105de9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105dec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105df0:	74 47                	je     80105e39 <create+0xb4>
    iunlockput(dp);
80105df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df5:	89 04 24             	mov    %eax,(%esp)
80105df8:	e8 bc be ff ff       	call   80101cb9 <iunlockput>
    ilock(ip);
80105dfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e00:	89 04 24             	mov    %eax,(%esp)
80105e03:	e8 2d bc ff ff       	call   80101a35 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105e08:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105e0d:	75 15                	jne    80105e24 <create+0x9f>
80105e0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e12:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e16:	66 83 f8 02          	cmp    $0x2,%ax
80105e1a:	75 08                	jne    80105e24 <create+0x9f>
      return ip;
80105e1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e1f:	e9 1f 01 00 00       	jmp    80105f43 <create+0x1be>
    iunlockput(ip);
80105e24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e27:	89 04 24             	mov    %eax,(%esp)
80105e2a:	e8 8a be ff ff       	call   80101cb9 <iunlockput>
    return 0;
80105e2f:	b8 00 00 00 00       	mov    $0x0,%eax
80105e34:	e9 0a 01 00 00       	jmp    80105f43 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105e39:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e40:	8b 00                	mov    (%eax),%eax
80105e42:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e46:	89 04 24             	mov    %eax,(%esp)
80105e49:	e8 4c b9 ff ff       	call   8010179a <ialloc>
80105e4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e51:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e55:	75 0c                	jne    80105e63 <create+0xde>
    panic("create: ialloc");
80105e57:	c7 04 24 b3 8b 10 80 	movl   $0x80108bb3,(%esp)
80105e5e:	e8 7f a8 ff ff       	call   801006e2 <panic>

  ilock(ip);
80105e63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e66:	89 04 24             	mov    %eax,(%esp)
80105e69:	e8 c7 bb ff ff       	call   80101a35 <ilock>
  ip->major = major;
80105e6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e71:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105e75:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105e79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e7c:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105e80:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105e84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e87:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105e8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e90:	89 04 24             	mov    %eax,(%esp)
80105e93:	e8 e1 b9 ff ff       	call   80101879 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105e98:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105e9d:	75 6a                	jne    80105f09 <create+0x184>
    dp->nlink++;  // for ".."
80105e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ea2:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ea6:	8d 50 01             	lea    0x1(%eax),%edx
80105ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eac:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb3:	89 04 24             	mov    %eax,(%esp)
80105eb6:	e8 be b9 ff ff       	call   80101879 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105ebb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ebe:	8b 40 04             	mov    0x4(%eax),%eax
80105ec1:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ec5:	c7 44 24 04 8d 8b 10 	movl   $0x80108b8d,0x4(%esp)
80105ecc:	80 
80105ecd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ed0:	89 04 24             	mov    %eax,(%esp)
80105ed3:	e8 48 c4 ff ff       	call   80102320 <dirlink>
80105ed8:	85 c0                	test   %eax,%eax
80105eda:	78 21                	js     80105efd <create+0x178>
80105edc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105edf:	8b 40 04             	mov    0x4(%eax),%eax
80105ee2:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ee6:	c7 44 24 04 8f 8b 10 	movl   $0x80108b8f,0x4(%esp)
80105eed:	80 
80105eee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ef1:	89 04 24             	mov    %eax,(%esp)
80105ef4:	e8 27 c4 ff ff       	call   80102320 <dirlink>
80105ef9:	85 c0                	test   %eax,%eax
80105efb:	79 0c                	jns    80105f09 <create+0x184>
      panic("create dots");
80105efd:	c7 04 24 c2 8b 10 80 	movl   $0x80108bc2,(%esp)
80105f04:	e8 d9 a7 ff ff       	call   801006e2 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105f09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f0c:	8b 40 04             	mov    0x4(%eax),%eax
80105f0f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f13:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f16:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f1d:	89 04 24             	mov    %eax,(%esp)
80105f20:	e8 fb c3 ff ff       	call   80102320 <dirlink>
80105f25:	85 c0                	test   %eax,%eax
80105f27:	79 0c                	jns    80105f35 <create+0x1b0>
    panic("create: dirlink");
80105f29:	c7 04 24 ce 8b 10 80 	movl   $0x80108bce,(%esp)
80105f30:	e8 ad a7 ff ff       	call   801006e2 <panic>

  iunlockput(dp);
80105f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f38:	89 04 24             	mov    %eax,(%esp)
80105f3b:	e8 79 bd ff ff       	call   80101cb9 <iunlockput>

  return ip;
80105f40:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105f43:	c9                   	leave  
80105f44:	c3                   	ret    

80105f45 <sys_open>:

int
sys_open(void)
{
80105f45:	55                   	push   %ebp
80105f46:	89 e5                	mov    %esp,%ebp
80105f48:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105f4b:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f4e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f59:	e8 d9 f6 ff ff       	call   80105637 <argstr>
80105f5e:	85 c0                	test   %eax,%eax
80105f60:	78 17                	js     80105f79 <sys_open+0x34>
80105f62:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f65:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f69:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105f70:	e8 32 f6 ff ff       	call   801055a7 <argint>
80105f75:	85 c0                	test   %eax,%eax
80105f77:	79 0a                	jns    80105f83 <sys_open+0x3e>
    return -1;
80105f79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f7e:	e9 5c 01 00 00       	jmp    801060df <sys_open+0x19a>

  begin_op();
80105f83:	e8 62 d6 ff ff       	call   801035ea <begin_op>

  if(omode & O_CREATE){
80105f88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f8b:	25 00 02 00 00       	and    $0x200,%eax
80105f90:	85 c0                	test   %eax,%eax
80105f92:	74 3b                	je     80105fcf <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80105f94:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f97:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105f9e:	00 
80105f9f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105fa6:	00 
80105fa7:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105fae:	00 
80105faf:	89 04 24             	mov    %eax,(%esp)
80105fb2:	e8 ce fd ff ff       	call   80105d85 <create>
80105fb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105fba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fbe:	75 6b                	jne    8010602b <sys_open+0xe6>
      end_op();
80105fc0:	e8 a9 d6 ff ff       	call   8010366e <end_op>
      return -1;
80105fc5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fca:	e9 10 01 00 00       	jmp    801060df <sys_open+0x19a>
    }
  } else {
    if((ip = namei(path)) == 0){
80105fcf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fd2:	89 04 24             	mov    %eax,(%esp)
80105fd5:	e8 06 c6 ff ff       	call   801025e0 <namei>
80105fda:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fdd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fe1:	75 0f                	jne    80105ff2 <sys_open+0xad>
      end_op();
80105fe3:	e8 86 d6 ff ff       	call   8010366e <end_op>
      return -1;
80105fe8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fed:	e9 ed 00 00 00       	jmp    801060df <sys_open+0x19a>
    }
    ilock(ip);
80105ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ff5:	89 04 24             	mov    %eax,(%esp)
80105ff8:	e8 38 ba ff ff       	call   80101a35 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106000:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106004:	66 83 f8 01          	cmp    $0x1,%ax
80106008:	75 21                	jne    8010602b <sys_open+0xe6>
8010600a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010600d:	85 c0                	test   %eax,%eax
8010600f:	74 1a                	je     8010602b <sys_open+0xe6>
      iunlockput(ip);
80106011:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106014:	89 04 24             	mov    %eax,(%esp)
80106017:	e8 9d bc ff ff       	call   80101cb9 <iunlockput>
      end_op();
8010601c:	e8 4d d6 ff ff       	call   8010366e <end_op>
      return -1;
80106021:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106026:	e9 b4 00 00 00       	jmp    801060df <sys_open+0x19a>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010602b:	e8 d0 b0 ff ff       	call   80101100 <filealloc>
80106030:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106033:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106037:	74 14                	je     8010604d <sys_open+0x108>
80106039:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010603c:	89 04 24             	mov    %eax,(%esp)
8010603f:	e8 2e f7 ff ff       	call   80105772 <fdalloc>
80106044:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106047:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010604b:	79 28                	jns    80106075 <sys_open+0x130>
    if(f)
8010604d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106051:	74 0b                	je     8010605e <sys_open+0x119>
      fileclose(f);
80106053:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106056:	89 04 24             	mov    %eax,(%esp)
80106059:	e8 4a b1 ff ff       	call   801011a8 <fileclose>
    iunlockput(ip);
8010605e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106061:	89 04 24             	mov    %eax,(%esp)
80106064:	e8 50 bc ff ff       	call   80101cb9 <iunlockput>
    end_op();
80106069:	e8 00 d6 ff ff       	call   8010366e <end_op>
    return -1;
8010606e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106073:	eb 6a                	jmp    801060df <sys_open+0x19a>
  }
  iunlock(ip);
80106075:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106078:	89 04 24             	mov    %eax,(%esp)
8010607b:	e8 03 bb ff ff       	call   80101b83 <iunlock>
  end_op();
80106080:	e8 e9 d5 ff ff       	call   8010366e <end_op>

  f->type = FD_INODE;
80106085:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106088:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010608e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106094:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106097:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010609a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801060a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060a4:	83 e0 01             	and    $0x1,%eax
801060a7:	85 c0                	test   %eax,%eax
801060a9:	0f 94 c0             	sete   %al
801060ac:	89 c2                	mov    %eax,%edx
801060ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060b1:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801060b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060b7:	83 e0 01             	and    $0x1,%eax
801060ba:	85 c0                	test   %eax,%eax
801060bc:	75 0a                	jne    801060c8 <sys_open+0x183>
801060be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060c1:	83 e0 02             	and    $0x2,%eax
801060c4:	85 c0                	test   %eax,%eax
801060c6:	74 07                	je     801060cf <sys_open+0x18a>
801060c8:	b8 01 00 00 00       	mov    $0x1,%eax
801060cd:	eb 05                	jmp    801060d4 <sys_open+0x18f>
801060cf:	b8 00 00 00 00       	mov    $0x0,%eax
801060d4:	89 c2                	mov    %eax,%edx
801060d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d9:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801060dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801060df:	c9                   	leave  
801060e0:	c3                   	ret    

801060e1 <sys_mkdir>:

int
sys_mkdir(void)
{
801060e1:	55                   	push   %ebp
801060e2:	89 e5                	mov    %esp,%ebp
801060e4:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801060e7:	e8 fe d4 ff ff       	call   801035ea <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801060ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060ef:	89 44 24 04          	mov    %eax,0x4(%esp)
801060f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801060fa:	e8 38 f5 ff ff       	call   80105637 <argstr>
801060ff:	85 c0                	test   %eax,%eax
80106101:	78 2c                	js     8010612f <sys_mkdir+0x4e>
80106103:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106106:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
8010610d:	00 
8010610e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106115:	00 
80106116:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010611d:	00 
8010611e:	89 04 24             	mov    %eax,(%esp)
80106121:	e8 5f fc ff ff       	call   80105d85 <create>
80106126:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106129:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010612d:	75 0c                	jne    8010613b <sys_mkdir+0x5a>
    end_op();
8010612f:	e8 3a d5 ff ff       	call   8010366e <end_op>
    return -1;
80106134:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106139:	eb 15                	jmp    80106150 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
8010613b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010613e:	89 04 24             	mov    %eax,(%esp)
80106141:	e8 73 bb ff ff       	call   80101cb9 <iunlockput>
  end_op();
80106146:	e8 23 d5 ff ff       	call   8010366e <end_op>
  return 0;
8010614b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106150:	c9                   	leave  
80106151:	c3                   	ret    

80106152 <sys_mknod>:

int
sys_mknod(void)
{
80106152:	55                   	push   %ebp
80106153:	89 e5                	mov    %esp,%ebp
80106155:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106158:	e8 8d d4 ff ff       	call   801035ea <begin_op>
  if((len=argstr(0, &path)) < 0 ||
8010615d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106160:	89 44 24 04          	mov    %eax,0x4(%esp)
80106164:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010616b:	e8 c7 f4 ff ff       	call   80105637 <argstr>
80106170:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106173:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106177:	78 5e                	js     801061d7 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80106179:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010617c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106180:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106187:	e8 1b f4 ff ff       	call   801055a7 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
8010618c:	85 c0                	test   %eax,%eax
8010618e:	78 47                	js     801061d7 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106190:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106193:	89 44 24 04          	mov    %eax,0x4(%esp)
80106197:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010619e:	e8 04 f4 ff ff       	call   801055a7 <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801061a3:	85 c0                	test   %eax,%eax
801061a5:	78 30                	js     801061d7 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801061a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061aa:	0f bf c8             	movswl %ax,%ecx
801061ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061b0:	0f bf d0             	movswl %ax,%edx
801061b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801061b6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801061ba:	89 54 24 08          	mov    %edx,0x8(%esp)
801061be:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801061c5:	00 
801061c6:	89 04 24             	mov    %eax,(%esp)
801061c9:	e8 b7 fb ff ff       	call   80105d85 <create>
801061ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061d1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061d5:	75 0c                	jne    801061e3 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801061d7:	e8 92 d4 ff ff       	call   8010366e <end_op>
    return -1;
801061dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061e1:	eb 15                	jmp    801061f8 <sys_mknod+0xa6>
  }
  iunlockput(ip);
801061e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061e6:	89 04 24             	mov    %eax,(%esp)
801061e9:	e8 cb ba ff ff       	call   80101cb9 <iunlockput>
  end_op();
801061ee:	e8 7b d4 ff ff       	call   8010366e <end_op>
  return 0;
801061f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061f8:	c9                   	leave  
801061f9:	c3                   	ret    

801061fa <sys_chdir>:

int
sys_chdir(void)
{
801061fa:	55                   	push   %ebp
801061fb:	89 e5                	mov    %esp,%ebp
801061fd:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106200:	e8 e5 d3 ff ff       	call   801035ea <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106205:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106208:	89 44 24 04          	mov    %eax,0x4(%esp)
8010620c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106213:	e8 1f f4 ff ff       	call   80105637 <argstr>
80106218:	85 c0                	test   %eax,%eax
8010621a:	78 14                	js     80106230 <sys_chdir+0x36>
8010621c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010621f:	89 04 24             	mov    %eax,(%esp)
80106222:	e8 b9 c3 ff ff       	call   801025e0 <namei>
80106227:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010622a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010622e:	75 0c                	jne    8010623c <sys_chdir+0x42>
    end_op();
80106230:	e8 39 d4 ff ff       	call   8010366e <end_op>
    return -1;
80106235:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010623a:	eb 61                	jmp    8010629d <sys_chdir+0xa3>
  }
  ilock(ip);
8010623c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010623f:	89 04 24             	mov    %eax,(%esp)
80106242:	e8 ee b7 ff ff       	call   80101a35 <ilock>
  if(ip->type != T_DIR){
80106247:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010624a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010624e:	66 83 f8 01          	cmp    $0x1,%ax
80106252:	74 17                	je     8010626b <sys_chdir+0x71>
    iunlockput(ip);
80106254:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106257:	89 04 24             	mov    %eax,(%esp)
8010625a:	e8 5a ba ff ff       	call   80101cb9 <iunlockput>
    end_op();
8010625f:	e8 0a d4 ff ff       	call   8010366e <end_op>
    return -1;
80106264:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106269:	eb 32                	jmp    8010629d <sys_chdir+0xa3>
  }
  iunlock(ip);
8010626b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010626e:	89 04 24             	mov    %eax,(%esp)
80106271:	e8 0d b9 ff ff       	call   80101b83 <iunlock>
  iput(proc->cwd);
80106276:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010627c:	8b 40 68             	mov    0x68(%eax),%eax
8010627f:	89 04 24             	mov    %eax,(%esp)
80106282:	e8 61 b9 ff ff       	call   80101be8 <iput>
  end_op();
80106287:	e8 e2 d3 ff ff       	call   8010366e <end_op>
  proc->cwd = ip;
8010628c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106292:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106295:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106298:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010629d:	c9                   	leave  
8010629e:	c3                   	ret    

8010629f <sys_exec>:

int
sys_exec(void)
{
8010629f:	55                   	push   %ebp
801062a0:	89 e5                	mov    %esp,%ebp
801062a2:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801062a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801062af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062b6:	e8 7c f3 ff ff       	call   80105637 <argstr>
801062bb:	85 c0                	test   %eax,%eax
801062bd:	78 1a                	js     801062d9 <sys_exec+0x3a>
801062bf:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801062c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801062c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801062d0:	e8 d2 f2 ff ff       	call   801055a7 <argint>
801062d5:	85 c0                	test   %eax,%eax
801062d7:	79 0a                	jns    801062e3 <sys_exec+0x44>
    return -1;
801062d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062de:	e9 c8 00 00 00       	jmp    801063ab <sys_exec+0x10c>
  }
  memset(argv, 0, sizeof(argv));
801062e3:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801062ea:	00 
801062eb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801062f2:	00 
801062f3:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801062f9:	89 04 24             	mov    %eax,(%esp)
801062fc:	e8 64 ef ff ff       	call   80105265 <memset>
  for(i=0;; i++){
80106301:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010630b:	83 f8 1f             	cmp    $0x1f,%eax
8010630e:	76 0a                	jbe    8010631a <sys_exec+0x7b>
      return -1;
80106310:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106315:	e9 91 00 00 00       	jmp    801063ab <sys_exec+0x10c>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010631a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010631d:	c1 e0 02             	shl    $0x2,%eax
80106320:	89 c2                	mov    %eax,%edx
80106322:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106328:	01 c2                	add    %eax,%edx
8010632a:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106330:	89 44 24 04          	mov    %eax,0x4(%esp)
80106334:	89 14 24             	mov    %edx,(%esp)
80106337:	e8 cf f1 ff ff       	call   8010550b <fetchint>
8010633c:	85 c0                	test   %eax,%eax
8010633e:	79 07                	jns    80106347 <sys_exec+0xa8>
      return -1;
80106340:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106345:	eb 64                	jmp    801063ab <sys_exec+0x10c>
    if(uarg == 0){
80106347:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010634d:	85 c0                	test   %eax,%eax
8010634f:	75 26                	jne    80106377 <sys_exec+0xd8>
      argv[i] = 0;
80106351:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106354:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010635b:	00 00 00 00 
      break;
8010635f:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106360:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106363:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106369:	89 54 24 04          	mov    %edx,0x4(%esp)
8010636d:	89 04 24             	mov    %eax,(%esp)
80106370:	e8 22 a9 ff ff       	call   80100c97 <exec>
80106375:	eb 34                	jmp    801063ab <sys_exec+0x10c>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106377:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010637d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106380:	c1 e2 02             	shl    $0x2,%edx
80106383:	01 c2                	add    %eax,%edx
80106385:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010638b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010638f:	89 04 24             	mov    %eax,(%esp)
80106392:	e8 ae f1 ff ff       	call   80105545 <fetchstr>
80106397:	85 c0                	test   %eax,%eax
80106399:	79 07                	jns    801063a2 <sys_exec+0x103>
      return -1;
8010639b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063a0:	eb 09                	jmp    801063ab <sys_exec+0x10c>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801063a2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801063a6:	e9 5d ff ff ff       	jmp    80106308 <sys_exec+0x69>
  return exec(path, argv);
}
801063ab:	c9                   	leave  
801063ac:	c3                   	ret    

801063ad <sys_pipe>:

int
sys_pipe(void)
{
801063ad:	55                   	push   %ebp
801063ae:	89 e5                	mov    %esp,%ebp
801063b0:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801063b3:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801063ba:	00 
801063bb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063be:	89 44 24 04          	mov    %eax,0x4(%esp)
801063c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063c9:	e8 07 f2 ff ff       	call   801055d5 <argptr>
801063ce:	85 c0                	test   %eax,%eax
801063d0:	79 0a                	jns    801063dc <sys_pipe+0x2f>
    return -1;
801063d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063d7:	e9 9b 00 00 00       	jmp    80106477 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
801063dc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801063df:	89 44 24 04          	mov    %eax,0x4(%esp)
801063e3:	8d 45 e8             	lea    -0x18(%ebp),%eax
801063e6:	89 04 24             	mov    %eax,(%esp)
801063e9:	e8 2b dd ff ff       	call   80104119 <pipealloc>
801063ee:	85 c0                	test   %eax,%eax
801063f0:	79 07                	jns    801063f9 <sys_pipe+0x4c>
    return -1;
801063f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063f7:	eb 7e                	jmp    80106477 <sys_pipe+0xca>
  fd0 = -1;
801063f9:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106400:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106403:	89 04 24             	mov    %eax,(%esp)
80106406:	e8 67 f3 ff ff       	call   80105772 <fdalloc>
8010640b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010640e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106412:	78 14                	js     80106428 <sys_pipe+0x7b>
80106414:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106417:	89 04 24             	mov    %eax,(%esp)
8010641a:	e8 53 f3 ff ff       	call   80105772 <fdalloc>
8010641f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106422:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106426:	79 37                	jns    8010645f <sys_pipe+0xb2>
    if(fd0 >= 0)
80106428:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010642c:	78 14                	js     80106442 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
8010642e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106434:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106437:	83 c2 08             	add    $0x8,%edx
8010643a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106441:	00 
    fileclose(rf);
80106442:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106445:	89 04 24             	mov    %eax,(%esp)
80106448:	e8 5b ad ff ff       	call   801011a8 <fileclose>
    fileclose(wf);
8010644d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106450:	89 04 24             	mov    %eax,(%esp)
80106453:	e8 50 ad ff ff       	call   801011a8 <fileclose>
    return -1;
80106458:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010645d:	eb 18                	jmp    80106477 <sys_pipe+0xca>
  }
  fd[0] = fd0;
8010645f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106462:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106465:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106467:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010646a:	8d 50 04             	lea    0x4(%eax),%edx
8010646d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106470:	89 02                	mov    %eax,(%edx)
  return 0;
80106472:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106477:	c9                   	leave  
80106478:	c3                   	ret    

80106479 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106479:	55                   	push   %ebp
8010647a:	89 e5                	mov    %esp,%ebp
8010647c:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010647f:	e8 61 e3 ff ff       	call   801047e5 <fork>
}
80106484:	c9                   	leave  
80106485:	c3                   	ret    

80106486 <sys_exit>:

int
sys_exit(void)
{
80106486:	55                   	push   %ebp
80106487:	89 e5                	mov    %esp,%ebp
80106489:	83 ec 08             	sub    $0x8,%esp
  exit();
8010648c:	e8 cf e4 ff ff       	call   80104960 <exit>
  return 0;  // not reached
80106491:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106496:	c9                   	leave  
80106497:	c3                   	ret    

80106498 <sys_wait>:

int
sys_wait(void)
{
80106498:	55                   	push   %ebp
80106499:	89 e5                	mov    %esp,%ebp
8010649b:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010649e:	e8 df e5 ff ff       	call   80104a82 <wait>
}
801064a3:	c9                   	leave  
801064a4:	c3                   	ret    

801064a5 <sys_kill>:

int
sys_kill(void)
{
801064a5:	55                   	push   %ebp
801064a6:	89 e5                	mov    %esp,%ebp
801064a8:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
801064ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801064b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064b9:	e8 e9 f0 ff ff       	call   801055a7 <argint>
801064be:	85 c0                	test   %eax,%eax
801064c0:	79 07                	jns    801064c9 <sys_kill+0x24>
    return -1;
801064c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064c7:	eb 0b                	jmp    801064d4 <sys_kill+0x2f>
  return kill(pid);
801064c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064cc:	89 04 24             	mov    %eax,(%esp)
801064cf:	e8 77 e9 ff ff       	call   80104e4b <kill>
}
801064d4:	c9                   	leave  
801064d5:	c3                   	ret    

801064d6 <sys_getpid>:

int
sys_getpid(void)
{
801064d6:	55                   	push   %ebp
801064d7:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801064d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064df:	8b 40 10             	mov    0x10(%eax),%eax
}
801064e2:	5d                   	pop    %ebp
801064e3:	c3                   	ret    

801064e4 <sys_sbrk>:

int
sys_sbrk(void)
{
801064e4:	55                   	push   %ebp
801064e5:	89 e5                	mov    %esp,%ebp
801064e7:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801064ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801064f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064f8:	e8 aa f0 ff ff       	call   801055a7 <argint>
801064fd:	85 c0                	test   %eax,%eax
801064ff:	79 07                	jns    80106508 <sys_sbrk+0x24>
    return -1;
80106501:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106506:	eb 24                	jmp    8010652c <sys_sbrk+0x48>
  addr = proc->sz;
80106508:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010650e:	8b 00                	mov    (%eax),%eax
80106510:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106513:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106516:	89 04 24             	mov    %eax,(%esp)
80106519:	e8 22 e2 ff ff       	call   80104740 <growproc>
8010651e:	85 c0                	test   %eax,%eax
80106520:	79 07                	jns    80106529 <sys_sbrk+0x45>
    return -1;
80106522:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106527:	eb 03                	jmp    8010652c <sys_sbrk+0x48>
  return addr;
80106529:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010652c:	c9                   	leave  
8010652d:	c3                   	ret    

8010652e <sys_sleep>:

int
sys_sleep(void)
{
8010652e:	55                   	push   %ebp
8010652f:	89 e5                	mov    %esp,%ebp
80106531:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106534:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106537:	89 44 24 04          	mov    %eax,0x4(%esp)
8010653b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106542:	e8 60 f0 ff ff       	call   801055a7 <argint>
80106547:	85 c0                	test   %eax,%eax
80106549:	79 07                	jns    80106552 <sys_sleep+0x24>
    return -1;
8010654b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106550:	eb 6c                	jmp    801065be <sys_sleep+0x90>
  acquire(&tickslock);
80106552:	c7 04 24 20 49 11 80 	movl   $0x80114920,(%esp)
80106559:	e8 b3 ea ff ff       	call   80105011 <acquire>
  ticks0 = ticks;
8010655e:	a1 60 51 11 80       	mov    0x80115160,%eax
80106563:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106566:	eb 34                	jmp    8010659c <sys_sleep+0x6e>
    if(proc->killed){
80106568:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010656e:	8b 40 24             	mov    0x24(%eax),%eax
80106571:	85 c0                	test   %eax,%eax
80106573:	74 13                	je     80106588 <sys_sleep+0x5a>
      release(&tickslock);
80106575:	c7 04 24 20 49 11 80 	movl   $0x80114920,(%esp)
8010657c:	e8 f2 ea ff ff       	call   80105073 <release>
      return -1;
80106581:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106586:	eb 36                	jmp    801065be <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106588:	c7 44 24 04 20 49 11 	movl   $0x80114920,0x4(%esp)
8010658f:	80 
80106590:	c7 04 24 60 51 11 80 	movl   $0x80115160,(%esp)
80106597:	e8 ab e7 ff ff       	call   80104d47 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010659c:	a1 60 51 11 80       	mov    0x80115160,%eax
801065a1:	2b 45 f4             	sub    -0xc(%ebp),%eax
801065a4:	89 c2                	mov    %eax,%edx
801065a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065a9:	39 c2                	cmp    %eax,%edx
801065ab:	72 bb                	jb     80106568 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801065ad:	c7 04 24 20 49 11 80 	movl   $0x80114920,(%esp)
801065b4:	e8 ba ea ff ff       	call   80105073 <release>
  return 0;
801065b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065be:	c9                   	leave  
801065bf:	c3                   	ret    

801065c0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801065c0:	55                   	push   %ebp
801065c1:	89 e5                	mov    %esp,%ebp
801065c3:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
801065c6:	c7 04 24 20 49 11 80 	movl   $0x80114920,(%esp)
801065cd:	e8 3f ea ff ff       	call   80105011 <acquire>
  xticks = ticks;
801065d2:	a1 60 51 11 80       	mov    0x80115160,%eax
801065d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801065da:	c7 04 24 20 49 11 80 	movl   $0x80114920,(%esp)
801065e1:	e8 8d ea ff ff       	call   80105073 <release>
  return xticks;
801065e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801065e9:	c9                   	leave  
801065ea:	c3                   	ret    

801065eb <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801065eb:	55                   	push   %ebp
801065ec:	89 e5                	mov    %esp,%ebp
801065ee:	83 ec 08             	sub    $0x8,%esp
801065f1:	8b 55 08             	mov    0x8(%ebp),%edx
801065f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801065f7:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801065fb:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801065fe:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106602:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106606:	ee                   	out    %al,(%dx)
}
80106607:	c9                   	leave  
80106608:	c3                   	ret    

80106609 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106609:	55                   	push   %ebp
8010660a:	89 e5                	mov    %esp,%ebp
8010660c:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010660f:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
80106616:	00 
80106617:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
8010661e:	e8 c8 ff ff ff       	call   801065eb <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106623:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
8010662a:	00 
8010662b:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106632:	e8 b4 ff ff ff       	call   801065eb <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106637:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
8010663e:	00 
8010663f:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106646:	e8 a0 ff ff ff       	call   801065eb <outb>
  picenable(IRQ_TIMER);
8010664b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106652:	e8 55 d9 ff ff       	call   80103fac <picenable>
}
80106657:	c9                   	leave  
80106658:	c3                   	ret    

80106659 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106659:	1e                   	push   %ds
  pushl %es
8010665a:	06                   	push   %es
  pushl %fs
8010665b:	0f a0                	push   %fs
  pushl %gs
8010665d:	0f a8                	push   %gs
  pushal
8010665f:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106660:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106664:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106666:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106668:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
8010666c:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010666e:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106670:	54                   	push   %esp
  call trap
80106671:	e8 d8 01 00 00       	call   8010684e <trap>
  addl $4, %esp
80106676:	83 c4 04             	add    $0x4,%esp

80106679 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106679:	61                   	popa   
  popl %gs
8010667a:	0f a9                	pop    %gs
  popl %fs
8010667c:	0f a1                	pop    %fs
  popl %es
8010667e:	07                   	pop    %es
  popl %ds
8010667f:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106680:	83 c4 08             	add    $0x8,%esp
  iret
80106683:	cf                   	iret   

80106684 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106684:	55                   	push   %ebp
80106685:	89 e5                	mov    %esp,%ebp
80106687:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010668a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010668d:	83 e8 01             	sub    $0x1,%eax
80106690:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106694:	8b 45 08             	mov    0x8(%ebp),%eax
80106697:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010669b:	8b 45 08             	mov    0x8(%ebp),%eax
8010669e:	c1 e8 10             	shr    $0x10,%eax
801066a1:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801066a5:	8d 45 fa             	lea    -0x6(%ebp),%eax
801066a8:	0f 01 18             	lidtl  (%eax)
}
801066ab:	c9                   	leave  
801066ac:	c3                   	ret    

801066ad <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801066ad:	55                   	push   %ebp
801066ae:	89 e5                	mov    %esp,%ebp
801066b0:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801066b3:	0f 20 d0             	mov    %cr2,%eax
801066b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801066b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801066bc:	c9                   	leave  
801066bd:	c3                   	ret    

801066be <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801066be:	55                   	push   %ebp
801066bf:	89 e5                	mov    %esp,%ebp
801066c1:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
801066c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801066cb:	e9 c3 00 00 00       	jmp    80106793 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801066d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d3:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
801066da:	89 c2                	mov    %eax,%edx
801066dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066df:	66 89 14 c5 60 49 11 	mov    %dx,-0x7feeb6a0(,%eax,8)
801066e6:	80 
801066e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ea:	66 c7 04 c5 62 49 11 	movw   $0x8,-0x7feeb69e(,%eax,8)
801066f1:	80 08 00 
801066f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066f7:	0f b6 14 c5 64 49 11 	movzbl -0x7feeb69c(,%eax,8),%edx
801066fe:	80 
801066ff:	83 e2 e0             	and    $0xffffffe0,%edx
80106702:	88 14 c5 64 49 11 80 	mov    %dl,-0x7feeb69c(,%eax,8)
80106709:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010670c:	0f b6 14 c5 64 49 11 	movzbl -0x7feeb69c(,%eax,8),%edx
80106713:	80 
80106714:	83 e2 1f             	and    $0x1f,%edx
80106717:	88 14 c5 64 49 11 80 	mov    %dl,-0x7feeb69c(,%eax,8)
8010671e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106721:	0f b6 14 c5 65 49 11 	movzbl -0x7feeb69b(,%eax,8),%edx
80106728:	80 
80106729:	83 e2 f0             	and    $0xfffffff0,%edx
8010672c:	83 ca 0e             	or     $0xe,%edx
8010672f:	88 14 c5 65 49 11 80 	mov    %dl,-0x7feeb69b(,%eax,8)
80106736:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106739:	0f b6 14 c5 65 49 11 	movzbl -0x7feeb69b(,%eax,8),%edx
80106740:	80 
80106741:	83 e2 ef             	and    $0xffffffef,%edx
80106744:	88 14 c5 65 49 11 80 	mov    %dl,-0x7feeb69b(,%eax,8)
8010674b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010674e:	0f b6 14 c5 65 49 11 	movzbl -0x7feeb69b(,%eax,8),%edx
80106755:	80 
80106756:	83 e2 9f             	and    $0xffffff9f,%edx
80106759:	88 14 c5 65 49 11 80 	mov    %dl,-0x7feeb69b(,%eax,8)
80106760:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106763:	0f b6 14 c5 65 49 11 	movzbl -0x7feeb69b(,%eax,8),%edx
8010676a:	80 
8010676b:	83 ca 80             	or     $0xffffff80,%edx
8010676e:	88 14 c5 65 49 11 80 	mov    %dl,-0x7feeb69b(,%eax,8)
80106775:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106778:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
8010677f:	c1 e8 10             	shr    $0x10,%eax
80106782:	89 c2                	mov    %eax,%edx
80106784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106787:	66 89 14 c5 66 49 11 	mov    %dx,-0x7feeb69a(,%eax,8)
8010678e:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010678f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106793:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010679a:	0f 8e 30 ff ff ff    	jle    801066d0 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801067a0:	a1 98 b1 10 80       	mov    0x8010b198,%eax
801067a5:	66 a3 60 4b 11 80    	mov    %ax,0x80114b60
801067ab:	66 c7 05 62 4b 11 80 	movw   $0x8,0x80114b62
801067b2:	08 00 
801067b4:	0f b6 05 64 4b 11 80 	movzbl 0x80114b64,%eax
801067bb:	83 e0 e0             	and    $0xffffffe0,%eax
801067be:	a2 64 4b 11 80       	mov    %al,0x80114b64
801067c3:	0f b6 05 64 4b 11 80 	movzbl 0x80114b64,%eax
801067ca:	83 e0 1f             	and    $0x1f,%eax
801067cd:	a2 64 4b 11 80       	mov    %al,0x80114b64
801067d2:	0f b6 05 65 4b 11 80 	movzbl 0x80114b65,%eax
801067d9:	83 c8 0f             	or     $0xf,%eax
801067dc:	a2 65 4b 11 80       	mov    %al,0x80114b65
801067e1:	0f b6 05 65 4b 11 80 	movzbl 0x80114b65,%eax
801067e8:	83 e0 ef             	and    $0xffffffef,%eax
801067eb:	a2 65 4b 11 80       	mov    %al,0x80114b65
801067f0:	0f b6 05 65 4b 11 80 	movzbl 0x80114b65,%eax
801067f7:	83 c8 60             	or     $0x60,%eax
801067fa:	a2 65 4b 11 80       	mov    %al,0x80114b65
801067ff:	0f b6 05 65 4b 11 80 	movzbl 0x80114b65,%eax
80106806:	83 c8 80             	or     $0xffffff80,%eax
80106809:	a2 65 4b 11 80       	mov    %al,0x80114b65
8010680e:	a1 98 b1 10 80       	mov    0x8010b198,%eax
80106813:	c1 e8 10             	shr    $0x10,%eax
80106816:	66 a3 66 4b 11 80    	mov    %ax,0x80114b66
  
  initlock(&tickslock, "time");
8010681c:	c7 44 24 04 e0 8b 10 	movl   $0x80108be0,0x4(%esp)
80106823:	80 
80106824:	c7 04 24 20 49 11 80 	movl   $0x80114920,(%esp)
8010682b:	e8 c0 e7 ff ff       	call   80104ff0 <initlock>
}
80106830:	c9                   	leave  
80106831:	c3                   	ret    

80106832 <idtinit>:

void
idtinit(void)
{
80106832:	55                   	push   %ebp
80106833:	89 e5                	mov    %esp,%ebp
80106835:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106838:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
8010683f:	00 
80106840:	c7 04 24 60 49 11 80 	movl   $0x80114960,(%esp)
80106847:	e8 38 fe ff ff       	call   80106684 <lidt>
}
8010684c:	c9                   	leave  
8010684d:	c3                   	ret    

8010684e <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010684e:	55                   	push   %ebp
8010684f:	89 e5                	mov    %esp,%ebp
80106851:	57                   	push   %edi
80106852:	56                   	push   %esi
80106853:	53                   	push   %ebx
80106854:	83 ec 4c             	sub    $0x4c,%esp
  if(tf->trapno == T_SYSCALL){
80106857:	8b 45 08             	mov    0x8(%ebp),%eax
8010685a:	8b 40 30             	mov    0x30(%eax),%eax
8010685d:	83 f8 40             	cmp    $0x40,%eax
80106860:	75 3f                	jne    801068a1 <trap+0x53>
    if(proc->killed)
80106862:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106868:	8b 40 24             	mov    0x24(%eax),%eax
8010686b:	85 c0                	test   %eax,%eax
8010686d:	74 05                	je     80106874 <trap+0x26>
      exit();
8010686f:	e8 ec e0 ff ff       	call   80104960 <exit>
    proc->tf = tf;
80106874:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010687a:	8b 55 08             	mov    0x8(%ebp),%edx
8010687d:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106880:	e8 e9 ed ff ff       	call   8010566e <syscall>
    if(proc->killed)
80106885:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010688b:	8b 40 24             	mov    0x24(%eax),%eax
8010688e:	85 c0                	test   %eax,%eax
80106890:	74 0a                	je     8010689c <trap+0x4e>
      exit();
80106892:	e8 c9 e0 ff ff       	call   80104960 <exit>
    return;
80106897:	e9 4a 02 00 00       	jmp    80106ae6 <trap+0x298>
8010689c:	e9 45 02 00 00       	jmp    80106ae6 <trap+0x298>
  }
  uint va;

  switch(tf->trapno){
801068a1:	8b 45 08             	mov    0x8(%ebp),%eax
801068a4:	8b 40 30             	mov    0x30(%eax),%eax
801068a7:	83 e8 0e             	sub    $0xe,%eax
801068aa:	83 f8 31             	cmp    $0x31,%eax
801068ad:	0f 87 d9 00 00 00    	ja     8010698c <trap+0x13e>
801068b3:	8b 04 85 88 8c 10 80 	mov    -0x7fef7378(,%eax,4),%eax
801068ba:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801068bc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801068c2:	0f b6 00             	movzbl (%eax),%eax
801068c5:	84 c0                	test   %al,%al
801068c7:	75 31                	jne    801068fa <trap+0xac>
      acquire(&tickslock);
801068c9:	c7 04 24 20 49 11 80 	movl   $0x80114920,(%esp)
801068d0:	e8 3c e7 ff ff       	call   80105011 <acquire>
      ticks++;
801068d5:	a1 60 51 11 80       	mov    0x80115160,%eax
801068da:	83 c0 01             	add    $0x1,%eax
801068dd:	a3 60 51 11 80       	mov    %eax,0x80115160
      wakeup(&ticks);
801068e2:	c7 04 24 60 51 11 80 	movl   $0x80115160,(%esp)
801068e9:	e8 32 e5 ff ff       	call   80104e20 <wakeup>
      release(&tickslock);
801068ee:	c7 04 24 20 49 11 80 	movl   $0x80114920,(%esp)
801068f5:	e8 79 e7 ff ff       	call   80105073 <release>
    }
    lapiceoi();
801068fa:	e8 ab c7 ff ff       	call   801030aa <lapiceoi>
    break;
801068ff:	e9 5e 01 00 00       	jmp    80106a62 <trap+0x214>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106904:	e8 af bf ff ff       	call   801028b8 <ideintr>
    lapiceoi();
80106909:	e8 9c c7 ff ff       	call   801030aa <lapiceoi>
    break;
8010690e:	e9 4f 01 00 00       	jmp    80106a62 <trap+0x214>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106913:	e8 61 c5 ff ff       	call   80102e79 <kbdintr>
    lapiceoi();
80106918:	e8 8d c7 ff ff       	call   801030aa <lapiceoi>
    break;
8010691d:	e9 40 01 00 00       	jmp    80106a62 <trap+0x214>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106922:	e8 b4 03 00 00       	call   80106cdb <uartintr>
    lapiceoi();
80106927:	e8 7e c7 ff ff       	call   801030aa <lapiceoi>
    break;
8010692c:	e9 31 01 00 00       	jmp    80106a62 <trap+0x214>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106931:	8b 45 08             	mov    0x8(%ebp),%eax
80106934:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106937:	8b 45 08             	mov    0x8(%ebp),%eax
8010693a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010693e:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106941:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106947:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010694a:	0f b6 c0             	movzbl %al,%eax
8010694d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106951:	89 54 24 08          	mov    %edx,0x8(%esp)
80106955:	89 44 24 04          	mov    %eax,0x4(%esp)
80106959:	c7 04 24 e8 8b 10 80 	movl   $0x80108be8,(%esp)
80106960:	e8 3b 9a ff ff       	call   801003a0 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106965:	e8 40 c7 ff ff       	call   801030aa <lapiceoi>
    break;
8010696a:	e9 f3 00 00 00       	jmp    80106a62 <trap+0x214>
  case T_PGFLT:

	  va= (uint) rcr2();
8010696f:	e8 39 fd ff ff       	call   801066ad <rcr2>
80106974:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	  insertVa2TLB(va);
80106977:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010697a:	89 04 24             	mov    %eax,(%esp)
8010697d:	e8 a2 1c 00 00       	call   80108624 <insertVa2TLB>
	  lapiceoi();
80106982:	e8 23 c7 ff ff       	call   801030aa <lapiceoi>
  	  break;
80106987:	e9 d6 00 00 00       	jmp    80106a62 <trap+0x214>
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
8010698c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106992:	85 c0                	test   %eax,%eax
80106994:	74 11                	je     801069a7 <trap+0x159>
80106996:	8b 45 08             	mov    0x8(%ebp),%eax
80106999:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010699d:	0f b7 c0             	movzwl %ax,%eax
801069a0:	83 e0 03             	and    $0x3,%eax
801069a3:	85 c0                	test   %eax,%eax
801069a5:	75 46                	jne    801069ed <trap+0x19f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801069a7:	e8 01 fd ff ff       	call   801066ad <rcr2>
801069ac:	8b 55 08             	mov    0x8(%ebp),%edx
801069af:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
801069b2:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801069b9:	0f b6 12             	movzbl (%edx),%edx
  	  break;
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801069bc:	0f b6 ca             	movzbl %dl,%ecx
801069bf:	8b 55 08             	mov    0x8(%ebp),%edx
801069c2:	8b 52 30             	mov    0x30(%edx),%edx
801069c5:	89 44 24 10          	mov    %eax,0x10(%esp)
801069c9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
801069cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801069d1:	89 54 24 04          	mov    %edx,0x4(%esp)
801069d5:	c7 04 24 0c 8c 10 80 	movl   $0x80108c0c,(%esp)
801069dc:	e8 bf 99 ff ff       	call   801003a0 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
801069e1:	c7 04 24 3e 8c 10 80 	movl   $0x80108c3e,(%esp)
801069e8:	e8 f5 9c ff ff       	call   801006e2 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801069ed:	e8 bb fc ff ff       	call   801066ad <rcr2>
801069f2:	89 c2                	mov    %eax,%edx
801069f4:	8b 45 08             	mov    0x8(%ebp),%eax
801069f7:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801069fa:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a00:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a03:	0f b6 f0             	movzbl %al,%esi
80106a06:	8b 45 08             	mov    0x8(%ebp),%eax
80106a09:	8b 58 34             	mov    0x34(%eax),%ebx
80106a0c:	8b 45 08             	mov    0x8(%ebp),%eax
80106a0f:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106a12:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a18:	83 c0 6c             	add    $0x6c,%eax
80106a1b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106a1e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a24:	8b 40 10             	mov    0x10(%eax),%eax
80106a27:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106a2b:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106a2f:	89 74 24 14          	mov    %esi,0x14(%esp)
80106a33:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106a37:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106a3b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
80106a3e:	89 74 24 08          	mov    %esi,0x8(%esp)
80106a42:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a46:	c7 04 24 44 8c 10 80 	movl   $0x80108c44,(%esp)
80106a4d:	e8 4e 99 ff ff       	call   801003a0 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106a52:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a58:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106a5f:	eb 01                	jmp    80106a62 <trap+0x214>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106a61:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106a62:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a68:	85 c0                	test   %eax,%eax
80106a6a:	74 24                	je     80106a90 <trap+0x242>
80106a6c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a72:	8b 40 24             	mov    0x24(%eax),%eax
80106a75:	85 c0                	test   %eax,%eax
80106a77:	74 17                	je     80106a90 <trap+0x242>
80106a79:	8b 45 08             	mov    0x8(%ebp),%eax
80106a7c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a80:	0f b7 c0             	movzwl %ax,%eax
80106a83:	83 e0 03             	and    $0x3,%eax
80106a86:	83 f8 03             	cmp    $0x3,%eax
80106a89:	75 05                	jne    80106a90 <trap+0x242>
    exit();
80106a8b:	e8 d0 de ff ff       	call   80104960 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106a90:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a96:	85 c0                	test   %eax,%eax
80106a98:	74 1e                	je     80106ab8 <trap+0x26a>
80106a9a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106aa0:	8b 40 0c             	mov    0xc(%eax),%eax
80106aa3:	83 f8 04             	cmp    $0x4,%eax
80106aa6:	75 10                	jne    80106ab8 <trap+0x26a>
80106aa8:	8b 45 08             	mov    0x8(%ebp),%eax
80106aab:	8b 40 30             	mov    0x30(%eax),%eax
80106aae:	83 f8 20             	cmp    $0x20,%eax
80106ab1:	75 05                	jne    80106ab8 <trap+0x26a>
    yield();
80106ab3:	e8 31 e2 ff ff       	call   80104ce9 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106ab8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106abe:	85 c0                	test   %eax,%eax
80106ac0:	74 24                	je     80106ae6 <trap+0x298>
80106ac2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ac8:	8b 40 24             	mov    0x24(%eax),%eax
80106acb:	85 c0                	test   %eax,%eax
80106acd:	74 17                	je     80106ae6 <trap+0x298>
80106acf:	8b 45 08             	mov    0x8(%ebp),%eax
80106ad2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ad6:	0f b7 c0             	movzwl %ax,%eax
80106ad9:	83 e0 03             	and    $0x3,%eax
80106adc:	83 f8 03             	cmp    $0x3,%eax
80106adf:	75 05                	jne    80106ae6 <trap+0x298>
    exit();
80106ae1:	e8 7a de ff ff       	call   80104960 <exit>
}
80106ae6:	83 c4 4c             	add    $0x4c,%esp
80106ae9:	5b                   	pop    %ebx
80106aea:	5e                   	pop    %esi
80106aeb:	5f                   	pop    %edi
80106aec:	5d                   	pop    %ebp
80106aed:	c3                   	ret    

80106aee <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106aee:	55                   	push   %ebp
80106aef:	89 e5                	mov    %esp,%ebp
80106af1:	83 ec 14             	sub    $0x14,%esp
80106af4:	8b 45 08             	mov    0x8(%ebp),%eax
80106af7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106afb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106aff:	89 c2                	mov    %eax,%edx
80106b01:	ec                   	in     (%dx),%al
80106b02:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106b05:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106b09:	c9                   	leave  
80106b0a:	c3                   	ret    

80106b0b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106b0b:	55                   	push   %ebp
80106b0c:	89 e5                	mov    %esp,%ebp
80106b0e:	83 ec 08             	sub    $0x8,%esp
80106b11:	8b 55 08             	mov    0x8(%ebp),%edx
80106b14:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b17:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106b1b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106b1e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106b22:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106b26:	ee                   	out    %al,(%dx)
}
80106b27:	c9                   	leave  
80106b28:	c3                   	ret    

80106b29 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106b29:	55                   	push   %ebp
80106b2a:	89 e5                	mov    %esp,%ebp
80106b2c:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106b2f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106b36:	00 
80106b37:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106b3e:	e8 c8 ff ff ff       	call   80106b0b <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106b43:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106b4a:	00 
80106b4b:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106b52:	e8 b4 ff ff ff       	call   80106b0b <outb>
  outb(COM1+0, 115200/9600);
80106b57:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106b5e:	00 
80106b5f:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106b66:	e8 a0 ff ff ff       	call   80106b0b <outb>
  outb(COM1+1, 0);
80106b6b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106b72:	00 
80106b73:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106b7a:	e8 8c ff ff ff       	call   80106b0b <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106b7f:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106b86:	00 
80106b87:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106b8e:	e8 78 ff ff ff       	call   80106b0b <outb>
  outb(COM1+4, 0);
80106b93:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106b9a:	00 
80106b9b:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106ba2:	e8 64 ff ff ff       	call   80106b0b <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106ba7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106bae:	00 
80106baf:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106bb6:	e8 50 ff ff ff       	call   80106b0b <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106bbb:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106bc2:	e8 27 ff ff ff       	call   80106aee <inb>
80106bc7:	3c ff                	cmp    $0xff,%al
80106bc9:	75 02                	jne    80106bcd <uartinit+0xa4>
    return;
80106bcb:	eb 6a                	jmp    80106c37 <uartinit+0x10e>
  uart = 1;
80106bcd:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106bd4:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106bd7:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106bde:	e8 0b ff ff ff       	call   80106aee <inb>
  inb(COM1+0);
80106be3:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106bea:	e8 ff fe ff ff       	call   80106aee <inb>
  picenable(IRQ_COM1);
80106bef:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106bf6:	e8 b1 d3 ff ff       	call   80103fac <picenable>
  ioapicenable(IRQ_COM1, 0);
80106bfb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c02:	00 
80106c03:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106c0a:	e8 28 bf ff ff       	call   80102b37 <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106c0f:	c7 45 f4 50 8d 10 80 	movl   $0x80108d50,-0xc(%ebp)
80106c16:	eb 15                	jmp    80106c2d <uartinit+0x104>
    uartputc(*p);
80106c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c1b:	0f b6 00             	movzbl (%eax),%eax
80106c1e:	0f be c0             	movsbl %al,%eax
80106c21:	89 04 24             	mov    %eax,(%esp)
80106c24:	e8 10 00 00 00       	call   80106c39 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106c29:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c30:	0f b6 00             	movzbl (%eax),%eax
80106c33:	84 c0                	test   %al,%al
80106c35:	75 e1                	jne    80106c18 <uartinit+0xef>
    uartputc(*p);
}
80106c37:	c9                   	leave  
80106c38:	c3                   	ret    

80106c39 <uartputc>:

void
uartputc(int c)
{
80106c39:	55                   	push   %ebp
80106c3a:	89 e5                	mov    %esp,%ebp
80106c3c:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106c3f:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106c44:	85 c0                	test   %eax,%eax
80106c46:	75 02                	jne    80106c4a <uartputc+0x11>
    return;
80106c48:	eb 4b                	jmp    80106c95 <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106c51:	eb 10                	jmp    80106c63 <uartputc+0x2a>
    microdelay(10);
80106c53:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106c5a:	e8 70 c4 ff ff       	call   801030cf <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c5f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c63:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106c67:	7f 16                	jg     80106c7f <uartputc+0x46>
80106c69:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106c70:	e8 79 fe ff ff       	call   80106aee <inb>
80106c75:	0f b6 c0             	movzbl %al,%eax
80106c78:	83 e0 20             	and    $0x20,%eax
80106c7b:	85 c0                	test   %eax,%eax
80106c7d:	74 d4                	je     80106c53 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106c7f:	8b 45 08             	mov    0x8(%ebp),%eax
80106c82:	0f b6 c0             	movzbl %al,%eax
80106c85:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c89:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106c90:	e8 76 fe ff ff       	call   80106b0b <outb>
}
80106c95:	c9                   	leave  
80106c96:	c3                   	ret    

80106c97 <uartgetc>:

static int
uartgetc(void)
{
80106c97:	55                   	push   %ebp
80106c98:	89 e5                	mov    %esp,%ebp
80106c9a:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106c9d:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106ca2:	85 c0                	test   %eax,%eax
80106ca4:	75 07                	jne    80106cad <uartgetc+0x16>
    return -1;
80106ca6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cab:	eb 2c                	jmp    80106cd9 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106cad:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106cb4:	e8 35 fe ff ff       	call   80106aee <inb>
80106cb9:	0f b6 c0             	movzbl %al,%eax
80106cbc:	83 e0 01             	and    $0x1,%eax
80106cbf:	85 c0                	test   %eax,%eax
80106cc1:	75 07                	jne    80106cca <uartgetc+0x33>
    return -1;
80106cc3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cc8:	eb 0f                	jmp    80106cd9 <uartgetc+0x42>
  return inb(COM1+0);
80106cca:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106cd1:	e8 18 fe ff ff       	call   80106aee <inb>
80106cd6:	0f b6 c0             	movzbl %al,%eax
}
80106cd9:	c9                   	leave  
80106cda:	c3                   	ret    

80106cdb <uartintr>:

void
uartintr(void)
{
80106cdb:	55                   	push   %ebp
80106cdc:	89 e5                	mov    %esp,%ebp
80106cde:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106ce1:	c7 04 24 97 6c 10 80 	movl   $0x80106c97,(%esp)
80106ce8:	e8 68 9c ff ff       	call   80100955 <consoleintr>
}
80106ced:	c9                   	leave  
80106cee:	c3                   	ret    

80106cef <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106cef:	6a 00                	push   $0x0
  pushl $0
80106cf1:	6a 00                	push   $0x0
  jmp alltraps
80106cf3:	e9 61 f9 ff ff       	jmp    80106659 <alltraps>

80106cf8 <vector1>:
.globl vector1
vector1:
  pushl $0
80106cf8:	6a 00                	push   $0x0
  pushl $1
80106cfa:	6a 01                	push   $0x1
  jmp alltraps
80106cfc:	e9 58 f9 ff ff       	jmp    80106659 <alltraps>

80106d01 <vector2>:
.globl vector2
vector2:
  pushl $0
80106d01:	6a 00                	push   $0x0
  pushl $2
80106d03:	6a 02                	push   $0x2
  jmp alltraps
80106d05:	e9 4f f9 ff ff       	jmp    80106659 <alltraps>

80106d0a <vector3>:
.globl vector3
vector3:
  pushl $0
80106d0a:	6a 00                	push   $0x0
  pushl $3
80106d0c:	6a 03                	push   $0x3
  jmp alltraps
80106d0e:	e9 46 f9 ff ff       	jmp    80106659 <alltraps>

80106d13 <vector4>:
.globl vector4
vector4:
  pushl $0
80106d13:	6a 00                	push   $0x0
  pushl $4
80106d15:	6a 04                	push   $0x4
  jmp alltraps
80106d17:	e9 3d f9 ff ff       	jmp    80106659 <alltraps>

80106d1c <vector5>:
.globl vector5
vector5:
  pushl $0
80106d1c:	6a 00                	push   $0x0
  pushl $5
80106d1e:	6a 05                	push   $0x5
  jmp alltraps
80106d20:	e9 34 f9 ff ff       	jmp    80106659 <alltraps>

80106d25 <vector6>:
.globl vector6
vector6:
  pushl $0
80106d25:	6a 00                	push   $0x0
  pushl $6
80106d27:	6a 06                	push   $0x6
  jmp alltraps
80106d29:	e9 2b f9 ff ff       	jmp    80106659 <alltraps>

80106d2e <vector7>:
.globl vector7
vector7:
  pushl $0
80106d2e:	6a 00                	push   $0x0
  pushl $7
80106d30:	6a 07                	push   $0x7
  jmp alltraps
80106d32:	e9 22 f9 ff ff       	jmp    80106659 <alltraps>

80106d37 <vector8>:
.globl vector8
vector8:
  pushl $8
80106d37:	6a 08                	push   $0x8
  jmp alltraps
80106d39:	e9 1b f9 ff ff       	jmp    80106659 <alltraps>

80106d3e <vector9>:
.globl vector9
vector9:
  pushl $0
80106d3e:	6a 00                	push   $0x0
  pushl $9
80106d40:	6a 09                	push   $0x9
  jmp alltraps
80106d42:	e9 12 f9 ff ff       	jmp    80106659 <alltraps>

80106d47 <vector10>:
.globl vector10
vector10:
  pushl $10
80106d47:	6a 0a                	push   $0xa
  jmp alltraps
80106d49:	e9 0b f9 ff ff       	jmp    80106659 <alltraps>

80106d4e <vector11>:
.globl vector11
vector11:
  pushl $11
80106d4e:	6a 0b                	push   $0xb
  jmp alltraps
80106d50:	e9 04 f9 ff ff       	jmp    80106659 <alltraps>

80106d55 <vector12>:
.globl vector12
vector12:
  pushl $12
80106d55:	6a 0c                	push   $0xc
  jmp alltraps
80106d57:	e9 fd f8 ff ff       	jmp    80106659 <alltraps>

80106d5c <vector13>:
.globl vector13
vector13:
  pushl $13
80106d5c:	6a 0d                	push   $0xd
  jmp alltraps
80106d5e:	e9 f6 f8 ff ff       	jmp    80106659 <alltraps>

80106d63 <vector14>:
.globl vector14
vector14:
  pushl $14
80106d63:	6a 0e                	push   $0xe
  jmp alltraps
80106d65:	e9 ef f8 ff ff       	jmp    80106659 <alltraps>

80106d6a <vector15>:
.globl vector15
vector15:
  pushl $0
80106d6a:	6a 00                	push   $0x0
  pushl $15
80106d6c:	6a 0f                	push   $0xf
  jmp alltraps
80106d6e:	e9 e6 f8 ff ff       	jmp    80106659 <alltraps>

80106d73 <vector16>:
.globl vector16
vector16:
  pushl $0
80106d73:	6a 00                	push   $0x0
  pushl $16
80106d75:	6a 10                	push   $0x10
  jmp alltraps
80106d77:	e9 dd f8 ff ff       	jmp    80106659 <alltraps>

80106d7c <vector17>:
.globl vector17
vector17:
  pushl $17
80106d7c:	6a 11                	push   $0x11
  jmp alltraps
80106d7e:	e9 d6 f8 ff ff       	jmp    80106659 <alltraps>

80106d83 <vector18>:
.globl vector18
vector18:
  pushl $0
80106d83:	6a 00                	push   $0x0
  pushl $18
80106d85:	6a 12                	push   $0x12
  jmp alltraps
80106d87:	e9 cd f8 ff ff       	jmp    80106659 <alltraps>

80106d8c <vector19>:
.globl vector19
vector19:
  pushl $0
80106d8c:	6a 00                	push   $0x0
  pushl $19
80106d8e:	6a 13                	push   $0x13
  jmp alltraps
80106d90:	e9 c4 f8 ff ff       	jmp    80106659 <alltraps>

80106d95 <vector20>:
.globl vector20
vector20:
  pushl $0
80106d95:	6a 00                	push   $0x0
  pushl $20
80106d97:	6a 14                	push   $0x14
  jmp alltraps
80106d99:	e9 bb f8 ff ff       	jmp    80106659 <alltraps>

80106d9e <vector21>:
.globl vector21
vector21:
  pushl $0
80106d9e:	6a 00                	push   $0x0
  pushl $21
80106da0:	6a 15                	push   $0x15
  jmp alltraps
80106da2:	e9 b2 f8 ff ff       	jmp    80106659 <alltraps>

80106da7 <vector22>:
.globl vector22
vector22:
  pushl $0
80106da7:	6a 00                	push   $0x0
  pushl $22
80106da9:	6a 16                	push   $0x16
  jmp alltraps
80106dab:	e9 a9 f8 ff ff       	jmp    80106659 <alltraps>

80106db0 <vector23>:
.globl vector23
vector23:
  pushl $0
80106db0:	6a 00                	push   $0x0
  pushl $23
80106db2:	6a 17                	push   $0x17
  jmp alltraps
80106db4:	e9 a0 f8 ff ff       	jmp    80106659 <alltraps>

80106db9 <vector24>:
.globl vector24
vector24:
  pushl $0
80106db9:	6a 00                	push   $0x0
  pushl $24
80106dbb:	6a 18                	push   $0x18
  jmp alltraps
80106dbd:	e9 97 f8 ff ff       	jmp    80106659 <alltraps>

80106dc2 <vector25>:
.globl vector25
vector25:
  pushl $0
80106dc2:	6a 00                	push   $0x0
  pushl $25
80106dc4:	6a 19                	push   $0x19
  jmp alltraps
80106dc6:	e9 8e f8 ff ff       	jmp    80106659 <alltraps>

80106dcb <vector26>:
.globl vector26
vector26:
  pushl $0
80106dcb:	6a 00                	push   $0x0
  pushl $26
80106dcd:	6a 1a                	push   $0x1a
  jmp alltraps
80106dcf:	e9 85 f8 ff ff       	jmp    80106659 <alltraps>

80106dd4 <vector27>:
.globl vector27
vector27:
  pushl $0
80106dd4:	6a 00                	push   $0x0
  pushl $27
80106dd6:	6a 1b                	push   $0x1b
  jmp alltraps
80106dd8:	e9 7c f8 ff ff       	jmp    80106659 <alltraps>

80106ddd <vector28>:
.globl vector28
vector28:
  pushl $0
80106ddd:	6a 00                	push   $0x0
  pushl $28
80106ddf:	6a 1c                	push   $0x1c
  jmp alltraps
80106de1:	e9 73 f8 ff ff       	jmp    80106659 <alltraps>

80106de6 <vector29>:
.globl vector29
vector29:
  pushl $0
80106de6:	6a 00                	push   $0x0
  pushl $29
80106de8:	6a 1d                	push   $0x1d
  jmp alltraps
80106dea:	e9 6a f8 ff ff       	jmp    80106659 <alltraps>

80106def <vector30>:
.globl vector30
vector30:
  pushl $0
80106def:	6a 00                	push   $0x0
  pushl $30
80106df1:	6a 1e                	push   $0x1e
  jmp alltraps
80106df3:	e9 61 f8 ff ff       	jmp    80106659 <alltraps>

80106df8 <vector31>:
.globl vector31
vector31:
  pushl $0
80106df8:	6a 00                	push   $0x0
  pushl $31
80106dfa:	6a 1f                	push   $0x1f
  jmp alltraps
80106dfc:	e9 58 f8 ff ff       	jmp    80106659 <alltraps>

80106e01 <vector32>:
.globl vector32
vector32:
  pushl $0
80106e01:	6a 00                	push   $0x0
  pushl $32
80106e03:	6a 20                	push   $0x20
  jmp alltraps
80106e05:	e9 4f f8 ff ff       	jmp    80106659 <alltraps>

80106e0a <vector33>:
.globl vector33
vector33:
  pushl $0
80106e0a:	6a 00                	push   $0x0
  pushl $33
80106e0c:	6a 21                	push   $0x21
  jmp alltraps
80106e0e:	e9 46 f8 ff ff       	jmp    80106659 <alltraps>

80106e13 <vector34>:
.globl vector34
vector34:
  pushl $0
80106e13:	6a 00                	push   $0x0
  pushl $34
80106e15:	6a 22                	push   $0x22
  jmp alltraps
80106e17:	e9 3d f8 ff ff       	jmp    80106659 <alltraps>

80106e1c <vector35>:
.globl vector35
vector35:
  pushl $0
80106e1c:	6a 00                	push   $0x0
  pushl $35
80106e1e:	6a 23                	push   $0x23
  jmp alltraps
80106e20:	e9 34 f8 ff ff       	jmp    80106659 <alltraps>

80106e25 <vector36>:
.globl vector36
vector36:
  pushl $0
80106e25:	6a 00                	push   $0x0
  pushl $36
80106e27:	6a 24                	push   $0x24
  jmp alltraps
80106e29:	e9 2b f8 ff ff       	jmp    80106659 <alltraps>

80106e2e <vector37>:
.globl vector37
vector37:
  pushl $0
80106e2e:	6a 00                	push   $0x0
  pushl $37
80106e30:	6a 25                	push   $0x25
  jmp alltraps
80106e32:	e9 22 f8 ff ff       	jmp    80106659 <alltraps>

80106e37 <vector38>:
.globl vector38
vector38:
  pushl $0
80106e37:	6a 00                	push   $0x0
  pushl $38
80106e39:	6a 26                	push   $0x26
  jmp alltraps
80106e3b:	e9 19 f8 ff ff       	jmp    80106659 <alltraps>

80106e40 <vector39>:
.globl vector39
vector39:
  pushl $0
80106e40:	6a 00                	push   $0x0
  pushl $39
80106e42:	6a 27                	push   $0x27
  jmp alltraps
80106e44:	e9 10 f8 ff ff       	jmp    80106659 <alltraps>

80106e49 <vector40>:
.globl vector40
vector40:
  pushl $0
80106e49:	6a 00                	push   $0x0
  pushl $40
80106e4b:	6a 28                	push   $0x28
  jmp alltraps
80106e4d:	e9 07 f8 ff ff       	jmp    80106659 <alltraps>

80106e52 <vector41>:
.globl vector41
vector41:
  pushl $0
80106e52:	6a 00                	push   $0x0
  pushl $41
80106e54:	6a 29                	push   $0x29
  jmp alltraps
80106e56:	e9 fe f7 ff ff       	jmp    80106659 <alltraps>

80106e5b <vector42>:
.globl vector42
vector42:
  pushl $0
80106e5b:	6a 00                	push   $0x0
  pushl $42
80106e5d:	6a 2a                	push   $0x2a
  jmp alltraps
80106e5f:	e9 f5 f7 ff ff       	jmp    80106659 <alltraps>

80106e64 <vector43>:
.globl vector43
vector43:
  pushl $0
80106e64:	6a 00                	push   $0x0
  pushl $43
80106e66:	6a 2b                	push   $0x2b
  jmp alltraps
80106e68:	e9 ec f7 ff ff       	jmp    80106659 <alltraps>

80106e6d <vector44>:
.globl vector44
vector44:
  pushl $0
80106e6d:	6a 00                	push   $0x0
  pushl $44
80106e6f:	6a 2c                	push   $0x2c
  jmp alltraps
80106e71:	e9 e3 f7 ff ff       	jmp    80106659 <alltraps>

80106e76 <vector45>:
.globl vector45
vector45:
  pushl $0
80106e76:	6a 00                	push   $0x0
  pushl $45
80106e78:	6a 2d                	push   $0x2d
  jmp alltraps
80106e7a:	e9 da f7 ff ff       	jmp    80106659 <alltraps>

80106e7f <vector46>:
.globl vector46
vector46:
  pushl $0
80106e7f:	6a 00                	push   $0x0
  pushl $46
80106e81:	6a 2e                	push   $0x2e
  jmp alltraps
80106e83:	e9 d1 f7 ff ff       	jmp    80106659 <alltraps>

80106e88 <vector47>:
.globl vector47
vector47:
  pushl $0
80106e88:	6a 00                	push   $0x0
  pushl $47
80106e8a:	6a 2f                	push   $0x2f
  jmp alltraps
80106e8c:	e9 c8 f7 ff ff       	jmp    80106659 <alltraps>

80106e91 <vector48>:
.globl vector48
vector48:
  pushl $0
80106e91:	6a 00                	push   $0x0
  pushl $48
80106e93:	6a 30                	push   $0x30
  jmp alltraps
80106e95:	e9 bf f7 ff ff       	jmp    80106659 <alltraps>

80106e9a <vector49>:
.globl vector49
vector49:
  pushl $0
80106e9a:	6a 00                	push   $0x0
  pushl $49
80106e9c:	6a 31                	push   $0x31
  jmp alltraps
80106e9e:	e9 b6 f7 ff ff       	jmp    80106659 <alltraps>

80106ea3 <vector50>:
.globl vector50
vector50:
  pushl $0
80106ea3:	6a 00                	push   $0x0
  pushl $50
80106ea5:	6a 32                	push   $0x32
  jmp alltraps
80106ea7:	e9 ad f7 ff ff       	jmp    80106659 <alltraps>

80106eac <vector51>:
.globl vector51
vector51:
  pushl $0
80106eac:	6a 00                	push   $0x0
  pushl $51
80106eae:	6a 33                	push   $0x33
  jmp alltraps
80106eb0:	e9 a4 f7 ff ff       	jmp    80106659 <alltraps>

80106eb5 <vector52>:
.globl vector52
vector52:
  pushl $0
80106eb5:	6a 00                	push   $0x0
  pushl $52
80106eb7:	6a 34                	push   $0x34
  jmp alltraps
80106eb9:	e9 9b f7 ff ff       	jmp    80106659 <alltraps>

80106ebe <vector53>:
.globl vector53
vector53:
  pushl $0
80106ebe:	6a 00                	push   $0x0
  pushl $53
80106ec0:	6a 35                	push   $0x35
  jmp alltraps
80106ec2:	e9 92 f7 ff ff       	jmp    80106659 <alltraps>

80106ec7 <vector54>:
.globl vector54
vector54:
  pushl $0
80106ec7:	6a 00                	push   $0x0
  pushl $54
80106ec9:	6a 36                	push   $0x36
  jmp alltraps
80106ecb:	e9 89 f7 ff ff       	jmp    80106659 <alltraps>

80106ed0 <vector55>:
.globl vector55
vector55:
  pushl $0
80106ed0:	6a 00                	push   $0x0
  pushl $55
80106ed2:	6a 37                	push   $0x37
  jmp alltraps
80106ed4:	e9 80 f7 ff ff       	jmp    80106659 <alltraps>

80106ed9 <vector56>:
.globl vector56
vector56:
  pushl $0
80106ed9:	6a 00                	push   $0x0
  pushl $56
80106edb:	6a 38                	push   $0x38
  jmp alltraps
80106edd:	e9 77 f7 ff ff       	jmp    80106659 <alltraps>

80106ee2 <vector57>:
.globl vector57
vector57:
  pushl $0
80106ee2:	6a 00                	push   $0x0
  pushl $57
80106ee4:	6a 39                	push   $0x39
  jmp alltraps
80106ee6:	e9 6e f7 ff ff       	jmp    80106659 <alltraps>

80106eeb <vector58>:
.globl vector58
vector58:
  pushl $0
80106eeb:	6a 00                	push   $0x0
  pushl $58
80106eed:	6a 3a                	push   $0x3a
  jmp alltraps
80106eef:	e9 65 f7 ff ff       	jmp    80106659 <alltraps>

80106ef4 <vector59>:
.globl vector59
vector59:
  pushl $0
80106ef4:	6a 00                	push   $0x0
  pushl $59
80106ef6:	6a 3b                	push   $0x3b
  jmp alltraps
80106ef8:	e9 5c f7 ff ff       	jmp    80106659 <alltraps>

80106efd <vector60>:
.globl vector60
vector60:
  pushl $0
80106efd:	6a 00                	push   $0x0
  pushl $60
80106eff:	6a 3c                	push   $0x3c
  jmp alltraps
80106f01:	e9 53 f7 ff ff       	jmp    80106659 <alltraps>

80106f06 <vector61>:
.globl vector61
vector61:
  pushl $0
80106f06:	6a 00                	push   $0x0
  pushl $61
80106f08:	6a 3d                	push   $0x3d
  jmp alltraps
80106f0a:	e9 4a f7 ff ff       	jmp    80106659 <alltraps>

80106f0f <vector62>:
.globl vector62
vector62:
  pushl $0
80106f0f:	6a 00                	push   $0x0
  pushl $62
80106f11:	6a 3e                	push   $0x3e
  jmp alltraps
80106f13:	e9 41 f7 ff ff       	jmp    80106659 <alltraps>

80106f18 <vector63>:
.globl vector63
vector63:
  pushl $0
80106f18:	6a 00                	push   $0x0
  pushl $63
80106f1a:	6a 3f                	push   $0x3f
  jmp alltraps
80106f1c:	e9 38 f7 ff ff       	jmp    80106659 <alltraps>

80106f21 <vector64>:
.globl vector64
vector64:
  pushl $0
80106f21:	6a 00                	push   $0x0
  pushl $64
80106f23:	6a 40                	push   $0x40
  jmp alltraps
80106f25:	e9 2f f7 ff ff       	jmp    80106659 <alltraps>

80106f2a <vector65>:
.globl vector65
vector65:
  pushl $0
80106f2a:	6a 00                	push   $0x0
  pushl $65
80106f2c:	6a 41                	push   $0x41
  jmp alltraps
80106f2e:	e9 26 f7 ff ff       	jmp    80106659 <alltraps>

80106f33 <vector66>:
.globl vector66
vector66:
  pushl $0
80106f33:	6a 00                	push   $0x0
  pushl $66
80106f35:	6a 42                	push   $0x42
  jmp alltraps
80106f37:	e9 1d f7 ff ff       	jmp    80106659 <alltraps>

80106f3c <vector67>:
.globl vector67
vector67:
  pushl $0
80106f3c:	6a 00                	push   $0x0
  pushl $67
80106f3e:	6a 43                	push   $0x43
  jmp alltraps
80106f40:	e9 14 f7 ff ff       	jmp    80106659 <alltraps>

80106f45 <vector68>:
.globl vector68
vector68:
  pushl $0
80106f45:	6a 00                	push   $0x0
  pushl $68
80106f47:	6a 44                	push   $0x44
  jmp alltraps
80106f49:	e9 0b f7 ff ff       	jmp    80106659 <alltraps>

80106f4e <vector69>:
.globl vector69
vector69:
  pushl $0
80106f4e:	6a 00                	push   $0x0
  pushl $69
80106f50:	6a 45                	push   $0x45
  jmp alltraps
80106f52:	e9 02 f7 ff ff       	jmp    80106659 <alltraps>

80106f57 <vector70>:
.globl vector70
vector70:
  pushl $0
80106f57:	6a 00                	push   $0x0
  pushl $70
80106f59:	6a 46                	push   $0x46
  jmp alltraps
80106f5b:	e9 f9 f6 ff ff       	jmp    80106659 <alltraps>

80106f60 <vector71>:
.globl vector71
vector71:
  pushl $0
80106f60:	6a 00                	push   $0x0
  pushl $71
80106f62:	6a 47                	push   $0x47
  jmp alltraps
80106f64:	e9 f0 f6 ff ff       	jmp    80106659 <alltraps>

80106f69 <vector72>:
.globl vector72
vector72:
  pushl $0
80106f69:	6a 00                	push   $0x0
  pushl $72
80106f6b:	6a 48                	push   $0x48
  jmp alltraps
80106f6d:	e9 e7 f6 ff ff       	jmp    80106659 <alltraps>

80106f72 <vector73>:
.globl vector73
vector73:
  pushl $0
80106f72:	6a 00                	push   $0x0
  pushl $73
80106f74:	6a 49                	push   $0x49
  jmp alltraps
80106f76:	e9 de f6 ff ff       	jmp    80106659 <alltraps>

80106f7b <vector74>:
.globl vector74
vector74:
  pushl $0
80106f7b:	6a 00                	push   $0x0
  pushl $74
80106f7d:	6a 4a                	push   $0x4a
  jmp alltraps
80106f7f:	e9 d5 f6 ff ff       	jmp    80106659 <alltraps>

80106f84 <vector75>:
.globl vector75
vector75:
  pushl $0
80106f84:	6a 00                	push   $0x0
  pushl $75
80106f86:	6a 4b                	push   $0x4b
  jmp alltraps
80106f88:	e9 cc f6 ff ff       	jmp    80106659 <alltraps>

80106f8d <vector76>:
.globl vector76
vector76:
  pushl $0
80106f8d:	6a 00                	push   $0x0
  pushl $76
80106f8f:	6a 4c                	push   $0x4c
  jmp alltraps
80106f91:	e9 c3 f6 ff ff       	jmp    80106659 <alltraps>

80106f96 <vector77>:
.globl vector77
vector77:
  pushl $0
80106f96:	6a 00                	push   $0x0
  pushl $77
80106f98:	6a 4d                	push   $0x4d
  jmp alltraps
80106f9a:	e9 ba f6 ff ff       	jmp    80106659 <alltraps>

80106f9f <vector78>:
.globl vector78
vector78:
  pushl $0
80106f9f:	6a 00                	push   $0x0
  pushl $78
80106fa1:	6a 4e                	push   $0x4e
  jmp alltraps
80106fa3:	e9 b1 f6 ff ff       	jmp    80106659 <alltraps>

80106fa8 <vector79>:
.globl vector79
vector79:
  pushl $0
80106fa8:	6a 00                	push   $0x0
  pushl $79
80106faa:	6a 4f                	push   $0x4f
  jmp alltraps
80106fac:	e9 a8 f6 ff ff       	jmp    80106659 <alltraps>

80106fb1 <vector80>:
.globl vector80
vector80:
  pushl $0
80106fb1:	6a 00                	push   $0x0
  pushl $80
80106fb3:	6a 50                	push   $0x50
  jmp alltraps
80106fb5:	e9 9f f6 ff ff       	jmp    80106659 <alltraps>

80106fba <vector81>:
.globl vector81
vector81:
  pushl $0
80106fba:	6a 00                	push   $0x0
  pushl $81
80106fbc:	6a 51                	push   $0x51
  jmp alltraps
80106fbe:	e9 96 f6 ff ff       	jmp    80106659 <alltraps>

80106fc3 <vector82>:
.globl vector82
vector82:
  pushl $0
80106fc3:	6a 00                	push   $0x0
  pushl $82
80106fc5:	6a 52                	push   $0x52
  jmp alltraps
80106fc7:	e9 8d f6 ff ff       	jmp    80106659 <alltraps>

80106fcc <vector83>:
.globl vector83
vector83:
  pushl $0
80106fcc:	6a 00                	push   $0x0
  pushl $83
80106fce:	6a 53                	push   $0x53
  jmp alltraps
80106fd0:	e9 84 f6 ff ff       	jmp    80106659 <alltraps>

80106fd5 <vector84>:
.globl vector84
vector84:
  pushl $0
80106fd5:	6a 00                	push   $0x0
  pushl $84
80106fd7:	6a 54                	push   $0x54
  jmp alltraps
80106fd9:	e9 7b f6 ff ff       	jmp    80106659 <alltraps>

80106fde <vector85>:
.globl vector85
vector85:
  pushl $0
80106fde:	6a 00                	push   $0x0
  pushl $85
80106fe0:	6a 55                	push   $0x55
  jmp alltraps
80106fe2:	e9 72 f6 ff ff       	jmp    80106659 <alltraps>

80106fe7 <vector86>:
.globl vector86
vector86:
  pushl $0
80106fe7:	6a 00                	push   $0x0
  pushl $86
80106fe9:	6a 56                	push   $0x56
  jmp alltraps
80106feb:	e9 69 f6 ff ff       	jmp    80106659 <alltraps>

80106ff0 <vector87>:
.globl vector87
vector87:
  pushl $0
80106ff0:	6a 00                	push   $0x0
  pushl $87
80106ff2:	6a 57                	push   $0x57
  jmp alltraps
80106ff4:	e9 60 f6 ff ff       	jmp    80106659 <alltraps>

80106ff9 <vector88>:
.globl vector88
vector88:
  pushl $0
80106ff9:	6a 00                	push   $0x0
  pushl $88
80106ffb:	6a 58                	push   $0x58
  jmp alltraps
80106ffd:	e9 57 f6 ff ff       	jmp    80106659 <alltraps>

80107002 <vector89>:
.globl vector89
vector89:
  pushl $0
80107002:	6a 00                	push   $0x0
  pushl $89
80107004:	6a 59                	push   $0x59
  jmp alltraps
80107006:	e9 4e f6 ff ff       	jmp    80106659 <alltraps>

8010700b <vector90>:
.globl vector90
vector90:
  pushl $0
8010700b:	6a 00                	push   $0x0
  pushl $90
8010700d:	6a 5a                	push   $0x5a
  jmp alltraps
8010700f:	e9 45 f6 ff ff       	jmp    80106659 <alltraps>

80107014 <vector91>:
.globl vector91
vector91:
  pushl $0
80107014:	6a 00                	push   $0x0
  pushl $91
80107016:	6a 5b                	push   $0x5b
  jmp alltraps
80107018:	e9 3c f6 ff ff       	jmp    80106659 <alltraps>

8010701d <vector92>:
.globl vector92
vector92:
  pushl $0
8010701d:	6a 00                	push   $0x0
  pushl $92
8010701f:	6a 5c                	push   $0x5c
  jmp alltraps
80107021:	e9 33 f6 ff ff       	jmp    80106659 <alltraps>

80107026 <vector93>:
.globl vector93
vector93:
  pushl $0
80107026:	6a 00                	push   $0x0
  pushl $93
80107028:	6a 5d                	push   $0x5d
  jmp alltraps
8010702a:	e9 2a f6 ff ff       	jmp    80106659 <alltraps>

8010702f <vector94>:
.globl vector94
vector94:
  pushl $0
8010702f:	6a 00                	push   $0x0
  pushl $94
80107031:	6a 5e                	push   $0x5e
  jmp alltraps
80107033:	e9 21 f6 ff ff       	jmp    80106659 <alltraps>

80107038 <vector95>:
.globl vector95
vector95:
  pushl $0
80107038:	6a 00                	push   $0x0
  pushl $95
8010703a:	6a 5f                	push   $0x5f
  jmp alltraps
8010703c:	e9 18 f6 ff ff       	jmp    80106659 <alltraps>

80107041 <vector96>:
.globl vector96
vector96:
  pushl $0
80107041:	6a 00                	push   $0x0
  pushl $96
80107043:	6a 60                	push   $0x60
  jmp alltraps
80107045:	e9 0f f6 ff ff       	jmp    80106659 <alltraps>

8010704a <vector97>:
.globl vector97
vector97:
  pushl $0
8010704a:	6a 00                	push   $0x0
  pushl $97
8010704c:	6a 61                	push   $0x61
  jmp alltraps
8010704e:	e9 06 f6 ff ff       	jmp    80106659 <alltraps>

80107053 <vector98>:
.globl vector98
vector98:
  pushl $0
80107053:	6a 00                	push   $0x0
  pushl $98
80107055:	6a 62                	push   $0x62
  jmp alltraps
80107057:	e9 fd f5 ff ff       	jmp    80106659 <alltraps>

8010705c <vector99>:
.globl vector99
vector99:
  pushl $0
8010705c:	6a 00                	push   $0x0
  pushl $99
8010705e:	6a 63                	push   $0x63
  jmp alltraps
80107060:	e9 f4 f5 ff ff       	jmp    80106659 <alltraps>

80107065 <vector100>:
.globl vector100
vector100:
  pushl $0
80107065:	6a 00                	push   $0x0
  pushl $100
80107067:	6a 64                	push   $0x64
  jmp alltraps
80107069:	e9 eb f5 ff ff       	jmp    80106659 <alltraps>

8010706e <vector101>:
.globl vector101
vector101:
  pushl $0
8010706e:	6a 00                	push   $0x0
  pushl $101
80107070:	6a 65                	push   $0x65
  jmp alltraps
80107072:	e9 e2 f5 ff ff       	jmp    80106659 <alltraps>

80107077 <vector102>:
.globl vector102
vector102:
  pushl $0
80107077:	6a 00                	push   $0x0
  pushl $102
80107079:	6a 66                	push   $0x66
  jmp alltraps
8010707b:	e9 d9 f5 ff ff       	jmp    80106659 <alltraps>

80107080 <vector103>:
.globl vector103
vector103:
  pushl $0
80107080:	6a 00                	push   $0x0
  pushl $103
80107082:	6a 67                	push   $0x67
  jmp alltraps
80107084:	e9 d0 f5 ff ff       	jmp    80106659 <alltraps>

80107089 <vector104>:
.globl vector104
vector104:
  pushl $0
80107089:	6a 00                	push   $0x0
  pushl $104
8010708b:	6a 68                	push   $0x68
  jmp alltraps
8010708d:	e9 c7 f5 ff ff       	jmp    80106659 <alltraps>

80107092 <vector105>:
.globl vector105
vector105:
  pushl $0
80107092:	6a 00                	push   $0x0
  pushl $105
80107094:	6a 69                	push   $0x69
  jmp alltraps
80107096:	e9 be f5 ff ff       	jmp    80106659 <alltraps>

8010709b <vector106>:
.globl vector106
vector106:
  pushl $0
8010709b:	6a 00                	push   $0x0
  pushl $106
8010709d:	6a 6a                	push   $0x6a
  jmp alltraps
8010709f:	e9 b5 f5 ff ff       	jmp    80106659 <alltraps>

801070a4 <vector107>:
.globl vector107
vector107:
  pushl $0
801070a4:	6a 00                	push   $0x0
  pushl $107
801070a6:	6a 6b                	push   $0x6b
  jmp alltraps
801070a8:	e9 ac f5 ff ff       	jmp    80106659 <alltraps>

801070ad <vector108>:
.globl vector108
vector108:
  pushl $0
801070ad:	6a 00                	push   $0x0
  pushl $108
801070af:	6a 6c                	push   $0x6c
  jmp alltraps
801070b1:	e9 a3 f5 ff ff       	jmp    80106659 <alltraps>

801070b6 <vector109>:
.globl vector109
vector109:
  pushl $0
801070b6:	6a 00                	push   $0x0
  pushl $109
801070b8:	6a 6d                	push   $0x6d
  jmp alltraps
801070ba:	e9 9a f5 ff ff       	jmp    80106659 <alltraps>

801070bf <vector110>:
.globl vector110
vector110:
  pushl $0
801070bf:	6a 00                	push   $0x0
  pushl $110
801070c1:	6a 6e                	push   $0x6e
  jmp alltraps
801070c3:	e9 91 f5 ff ff       	jmp    80106659 <alltraps>

801070c8 <vector111>:
.globl vector111
vector111:
  pushl $0
801070c8:	6a 00                	push   $0x0
  pushl $111
801070ca:	6a 6f                	push   $0x6f
  jmp alltraps
801070cc:	e9 88 f5 ff ff       	jmp    80106659 <alltraps>

801070d1 <vector112>:
.globl vector112
vector112:
  pushl $0
801070d1:	6a 00                	push   $0x0
  pushl $112
801070d3:	6a 70                	push   $0x70
  jmp alltraps
801070d5:	e9 7f f5 ff ff       	jmp    80106659 <alltraps>

801070da <vector113>:
.globl vector113
vector113:
  pushl $0
801070da:	6a 00                	push   $0x0
  pushl $113
801070dc:	6a 71                	push   $0x71
  jmp alltraps
801070de:	e9 76 f5 ff ff       	jmp    80106659 <alltraps>

801070e3 <vector114>:
.globl vector114
vector114:
  pushl $0
801070e3:	6a 00                	push   $0x0
  pushl $114
801070e5:	6a 72                	push   $0x72
  jmp alltraps
801070e7:	e9 6d f5 ff ff       	jmp    80106659 <alltraps>

801070ec <vector115>:
.globl vector115
vector115:
  pushl $0
801070ec:	6a 00                	push   $0x0
  pushl $115
801070ee:	6a 73                	push   $0x73
  jmp alltraps
801070f0:	e9 64 f5 ff ff       	jmp    80106659 <alltraps>

801070f5 <vector116>:
.globl vector116
vector116:
  pushl $0
801070f5:	6a 00                	push   $0x0
  pushl $116
801070f7:	6a 74                	push   $0x74
  jmp alltraps
801070f9:	e9 5b f5 ff ff       	jmp    80106659 <alltraps>

801070fe <vector117>:
.globl vector117
vector117:
  pushl $0
801070fe:	6a 00                	push   $0x0
  pushl $117
80107100:	6a 75                	push   $0x75
  jmp alltraps
80107102:	e9 52 f5 ff ff       	jmp    80106659 <alltraps>

80107107 <vector118>:
.globl vector118
vector118:
  pushl $0
80107107:	6a 00                	push   $0x0
  pushl $118
80107109:	6a 76                	push   $0x76
  jmp alltraps
8010710b:	e9 49 f5 ff ff       	jmp    80106659 <alltraps>

80107110 <vector119>:
.globl vector119
vector119:
  pushl $0
80107110:	6a 00                	push   $0x0
  pushl $119
80107112:	6a 77                	push   $0x77
  jmp alltraps
80107114:	e9 40 f5 ff ff       	jmp    80106659 <alltraps>

80107119 <vector120>:
.globl vector120
vector120:
  pushl $0
80107119:	6a 00                	push   $0x0
  pushl $120
8010711b:	6a 78                	push   $0x78
  jmp alltraps
8010711d:	e9 37 f5 ff ff       	jmp    80106659 <alltraps>

80107122 <vector121>:
.globl vector121
vector121:
  pushl $0
80107122:	6a 00                	push   $0x0
  pushl $121
80107124:	6a 79                	push   $0x79
  jmp alltraps
80107126:	e9 2e f5 ff ff       	jmp    80106659 <alltraps>

8010712b <vector122>:
.globl vector122
vector122:
  pushl $0
8010712b:	6a 00                	push   $0x0
  pushl $122
8010712d:	6a 7a                	push   $0x7a
  jmp alltraps
8010712f:	e9 25 f5 ff ff       	jmp    80106659 <alltraps>

80107134 <vector123>:
.globl vector123
vector123:
  pushl $0
80107134:	6a 00                	push   $0x0
  pushl $123
80107136:	6a 7b                	push   $0x7b
  jmp alltraps
80107138:	e9 1c f5 ff ff       	jmp    80106659 <alltraps>

8010713d <vector124>:
.globl vector124
vector124:
  pushl $0
8010713d:	6a 00                	push   $0x0
  pushl $124
8010713f:	6a 7c                	push   $0x7c
  jmp alltraps
80107141:	e9 13 f5 ff ff       	jmp    80106659 <alltraps>

80107146 <vector125>:
.globl vector125
vector125:
  pushl $0
80107146:	6a 00                	push   $0x0
  pushl $125
80107148:	6a 7d                	push   $0x7d
  jmp alltraps
8010714a:	e9 0a f5 ff ff       	jmp    80106659 <alltraps>

8010714f <vector126>:
.globl vector126
vector126:
  pushl $0
8010714f:	6a 00                	push   $0x0
  pushl $126
80107151:	6a 7e                	push   $0x7e
  jmp alltraps
80107153:	e9 01 f5 ff ff       	jmp    80106659 <alltraps>

80107158 <vector127>:
.globl vector127
vector127:
  pushl $0
80107158:	6a 00                	push   $0x0
  pushl $127
8010715a:	6a 7f                	push   $0x7f
  jmp alltraps
8010715c:	e9 f8 f4 ff ff       	jmp    80106659 <alltraps>

80107161 <vector128>:
.globl vector128
vector128:
  pushl $0
80107161:	6a 00                	push   $0x0
  pushl $128
80107163:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107168:	e9 ec f4 ff ff       	jmp    80106659 <alltraps>

8010716d <vector129>:
.globl vector129
vector129:
  pushl $0
8010716d:	6a 00                	push   $0x0
  pushl $129
8010716f:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107174:	e9 e0 f4 ff ff       	jmp    80106659 <alltraps>

80107179 <vector130>:
.globl vector130
vector130:
  pushl $0
80107179:	6a 00                	push   $0x0
  pushl $130
8010717b:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107180:	e9 d4 f4 ff ff       	jmp    80106659 <alltraps>

80107185 <vector131>:
.globl vector131
vector131:
  pushl $0
80107185:	6a 00                	push   $0x0
  pushl $131
80107187:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010718c:	e9 c8 f4 ff ff       	jmp    80106659 <alltraps>

80107191 <vector132>:
.globl vector132
vector132:
  pushl $0
80107191:	6a 00                	push   $0x0
  pushl $132
80107193:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107198:	e9 bc f4 ff ff       	jmp    80106659 <alltraps>

8010719d <vector133>:
.globl vector133
vector133:
  pushl $0
8010719d:	6a 00                	push   $0x0
  pushl $133
8010719f:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801071a4:	e9 b0 f4 ff ff       	jmp    80106659 <alltraps>

801071a9 <vector134>:
.globl vector134
vector134:
  pushl $0
801071a9:	6a 00                	push   $0x0
  pushl $134
801071ab:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801071b0:	e9 a4 f4 ff ff       	jmp    80106659 <alltraps>

801071b5 <vector135>:
.globl vector135
vector135:
  pushl $0
801071b5:	6a 00                	push   $0x0
  pushl $135
801071b7:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801071bc:	e9 98 f4 ff ff       	jmp    80106659 <alltraps>

801071c1 <vector136>:
.globl vector136
vector136:
  pushl $0
801071c1:	6a 00                	push   $0x0
  pushl $136
801071c3:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801071c8:	e9 8c f4 ff ff       	jmp    80106659 <alltraps>

801071cd <vector137>:
.globl vector137
vector137:
  pushl $0
801071cd:	6a 00                	push   $0x0
  pushl $137
801071cf:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801071d4:	e9 80 f4 ff ff       	jmp    80106659 <alltraps>

801071d9 <vector138>:
.globl vector138
vector138:
  pushl $0
801071d9:	6a 00                	push   $0x0
  pushl $138
801071db:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801071e0:	e9 74 f4 ff ff       	jmp    80106659 <alltraps>

801071e5 <vector139>:
.globl vector139
vector139:
  pushl $0
801071e5:	6a 00                	push   $0x0
  pushl $139
801071e7:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801071ec:	e9 68 f4 ff ff       	jmp    80106659 <alltraps>

801071f1 <vector140>:
.globl vector140
vector140:
  pushl $0
801071f1:	6a 00                	push   $0x0
  pushl $140
801071f3:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801071f8:	e9 5c f4 ff ff       	jmp    80106659 <alltraps>

801071fd <vector141>:
.globl vector141
vector141:
  pushl $0
801071fd:	6a 00                	push   $0x0
  pushl $141
801071ff:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107204:	e9 50 f4 ff ff       	jmp    80106659 <alltraps>

80107209 <vector142>:
.globl vector142
vector142:
  pushl $0
80107209:	6a 00                	push   $0x0
  pushl $142
8010720b:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107210:	e9 44 f4 ff ff       	jmp    80106659 <alltraps>

80107215 <vector143>:
.globl vector143
vector143:
  pushl $0
80107215:	6a 00                	push   $0x0
  pushl $143
80107217:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010721c:	e9 38 f4 ff ff       	jmp    80106659 <alltraps>

80107221 <vector144>:
.globl vector144
vector144:
  pushl $0
80107221:	6a 00                	push   $0x0
  pushl $144
80107223:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107228:	e9 2c f4 ff ff       	jmp    80106659 <alltraps>

8010722d <vector145>:
.globl vector145
vector145:
  pushl $0
8010722d:	6a 00                	push   $0x0
  pushl $145
8010722f:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107234:	e9 20 f4 ff ff       	jmp    80106659 <alltraps>

80107239 <vector146>:
.globl vector146
vector146:
  pushl $0
80107239:	6a 00                	push   $0x0
  pushl $146
8010723b:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107240:	e9 14 f4 ff ff       	jmp    80106659 <alltraps>

80107245 <vector147>:
.globl vector147
vector147:
  pushl $0
80107245:	6a 00                	push   $0x0
  pushl $147
80107247:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010724c:	e9 08 f4 ff ff       	jmp    80106659 <alltraps>

80107251 <vector148>:
.globl vector148
vector148:
  pushl $0
80107251:	6a 00                	push   $0x0
  pushl $148
80107253:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107258:	e9 fc f3 ff ff       	jmp    80106659 <alltraps>

8010725d <vector149>:
.globl vector149
vector149:
  pushl $0
8010725d:	6a 00                	push   $0x0
  pushl $149
8010725f:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107264:	e9 f0 f3 ff ff       	jmp    80106659 <alltraps>

80107269 <vector150>:
.globl vector150
vector150:
  pushl $0
80107269:	6a 00                	push   $0x0
  pushl $150
8010726b:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107270:	e9 e4 f3 ff ff       	jmp    80106659 <alltraps>

80107275 <vector151>:
.globl vector151
vector151:
  pushl $0
80107275:	6a 00                	push   $0x0
  pushl $151
80107277:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010727c:	e9 d8 f3 ff ff       	jmp    80106659 <alltraps>

80107281 <vector152>:
.globl vector152
vector152:
  pushl $0
80107281:	6a 00                	push   $0x0
  pushl $152
80107283:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107288:	e9 cc f3 ff ff       	jmp    80106659 <alltraps>

8010728d <vector153>:
.globl vector153
vector153:
  pushl $0
8010728d:	6a 00                	push   $0x0
  pushl $153
8010728f:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107294:	e9 c0 f3 ff ff       	jmp    80106659 <alltraps>

80107299 <vector154>:
.globl vector154
vector154:
  pushl $0
80107299:	6a 00                	push   $0x0
  pushl $154
8010729b:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801072a0:	e9 b4 f3 ff ff       	jmp    80106659 <alltraps>

801072a5 <vector155>:
.globl vector155
vector155:
  pushl $0
801072a5:	6a 00                	push   $0x0
  pushl $155
801072a7:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801072ac:	e9 a8 f3 ff ff       	jmp    80106659 <alltraps>

801072b1 <vector156>:
.globl vector156
vector156:
  pushl $0
801072b1:	6a 00                	push   $0x0
  pushl $156
801072b3:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801072b8:	e9 9c f3 ff ff       	jmp    80106659 <alltraps>

801072bd <vector157>:
.globl vector157
vector157:
  pushl $0
801072bd:	6a 00                	push   $0x0
  pushl $157
801072bf:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801072c4:	e9 90 f3 ff ff       	jmp    80106659 <alltraps>

801072c9 <vector158>:
.globl vector158
vector158:
  pushl $0
801072c9:	6a 00                	push   $0x0
  pushl $158
801072cb:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801072d0:	e9 84 f3 ff ff       	jmp    80106659 <alltraps>

801072d5 <vector159>:
.globl vector159
vector159:
  pushl $0
801072d5:	6a 00                	push   $0x0
  pushl $159
801072d7:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801072dc:	e9 78 f3 ff ff       	jmp    80106659 <alltraps>

801072e1 <vector160>:
.globl vector160
vector160:
  pushl $0
801072e1:	6a 00                	push   $0x0
  pushl $160
801072e3:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801072e8:	e9 6c f3 ff ff       	jmp    80106659 <alltraps>

801072ed <vector161>:
.globl vector161
vector161:
  pushl $0
801072ed:	6a 00                	push   $0x0
  pushl $161
801072ef:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801072f4:	e9 60 f3 ff ff       	jmp    80106659 <alltraps>

801072f9 <vector162>:
.globl vector162
vector162:
  pushl $0
801072f9:	6a 00                	push   $0x0
  pushl $162
801072fb:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107300:	e9 54 f3 ff ff       	jmp    80106659 <alltraps>

80107305 <vector163>:
.globl vector163
vector163:
  pushl $0
80107305:	6a 00                	push   $0x0
  pushl $163
80107307:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010730c:	e9 48 f3 ff ff       	jmp    80106659 <alltraps>

80107311 <vector164>:
.globl vector164
vector164:
  pushl $0
80107311:	6a 00                	push   $0x0
  pushl $164
80107313:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107318:	e9 3c f3 ff ff       	jmp    80106659 <alltraps>

8010731d <vector165>:
.globl vector165
vector165:
  pushl $0
8010731d:	6a 00                	push   $0x0
  pushl $165
8010731f:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107324:	e9 30 f3 ff ff       	jmp    80106659 <alltraps>

80107329 <vector166>:
.globl vector166
vector166:
  pushl $0
80107329:	6a 00                	push   $0x0
  pushl $166
8010732b:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107330:	e9 24 f3 ff ff       	jmp    80106659 <alltraps>

80107335 <vector167>:
.globl vector167
vector167:
  pushl $0
80107335:	6a 00                	push   $0x0
  pushl $167
80107337:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010733c:	e9 18 f3 ff ff       	jmp    80106659 <alltraps>

80107341 <vector168>:
.globl vector168
vector168:
  pushl $0
80107341:	6a 00                	push   $0x0
  pushl $168
80107343:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107348:	e9 0c f3 ff ff       	jmp    80106659 <alltraps>

8010734d <vector169>:
.globl vector169
vector169:
  pushl $0
8010734d:	6a 00                	push   $0x0
  pushl $169
8010734f:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107354:	e9 00 f3 ff ff       	jmp    80106659 <alltraps>

80107359 <vector170>:
.globl vector170
vector170:
  pushl $0
80107359:	6a 00                	push   $0x0
  pushl $170
8010735b:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107360:	e9 f4 f2 ff ff       	jmp    80106659 <alltraps>

80107365 <vector171>:
.globl vector171
vector171:
  pushl $0
80107365:	6a 00                	push   $0x0
  pushl $171
80107367:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010736c:	e9 e8 f2 ff ff       	jmp    80106659 <alltraps>

80107371 <vector172>:
.globl vector172
vector172:
  pushl $0
80107371:	6a 00                	push   $0x0
  pushl $172
80107373:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107378:	e9 dc f2 ff ff       	jmp    80106659 <alltraps>

8010737d <vector173>:
.globl vector173
vector173:
  pushl $0
8010737d:	6a 00                	push   $0x0
  pushl $173
8010737f:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107384:	e9 d0 f2 ff ff       	jmp    80106659 <alltraps>

80107389 <vector174>:
.globl vector174
vector174:
  pushl $0
80107389:	6a 00                	push   $0x0
  pushl $174
8010738b:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107390:	e9 c4 f2 ff ff       	jmp    80106659 <alltraps>

80107395 <vector175>:
.globl vector175
vector175:
  pushl $0
80107395:	6a 00                	push   $0x0
  pushl $175
80107397:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010739c:	e9 b8 f2 ff ff       	jmp    80106659 <alltraps>

801073a1 <vector176>:
.globl vector176
vector176:
  pushl $0
801073a1:	6a 00                	push   $0x0
  pushl $176
801073a3:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801073a8:	e9 ac f2 ff ff       	jmp    80106659 <alltraps>

801073ad <vector177>:
.globl vector177
vector177:
  pushl $0
801073ad:	6a 00                	push   $0x0
  pushl $177
801073af:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801073b4:	e9 a0 f2 ff ff       	jmp    80106659 <alltraps>

801073b9 <vector178>:
.globl vector178
vector178:
  pushl $0
801073b9:	6a 00                	push   $0x0
  pushl $178
801073bb:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801073c0:	e9 94 f2 ff ff       	jmp    80106659 <alltraps>

801073c5 <vector179>:
.globl vector179
vector179:
  pushl $0
801073c5:	6a 00                	push   $0x0
  pushl $179
801073c7:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801073cc:	e9 88 f2 ff ff       	jmp    80106659 <alltraps>

801073d1 <vector180>:
.globl vector180
vector180:
  pushl $0
801073d1:	6a 00                	push   $0x0
  pushl $180
801073d3:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801073d8:	e9 7c f2 ff ff       	jmp    80106659 <alltraps>

801073dd <vector181>:
.globl vector181
vector181:
  pushl $0
801073dd:	6a 00                	push   $0x0
  pushl $181
801073df:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801073e4:	e9 70 f2 ff ff       	jmp    80106659 <alltraps>

801073e9 <vector182>:
.globl vector182
vector182:
  pushl $0
801073e9:	6a 00                	push   $0x0
  pushl $182
801073eb:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801073f0:	e9 64 f2 ff ff       	jmp    80106659 <alltraps>

801073f5 <vector183>:
.globl vector183
vector183:
  pushl $0
801073f5:	6a 00                	push   $0x0
  pushl $183
801073f7:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801073fc:	e9 58 f2 ff ff       	jmp    80106659 <alltraps>

80107401 <vector184>:
.globl vector184
vector184:
  pushl $0
80107401:	6a 00                	push   $0x0
  pushl $184
80107403:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107408:	e9 4c f2 ff ff       	jmp    80106659 <alltraps>

8010740d <vector185>:
.globl vector185
vector185:
  pushl $0
8010740d:	6a 00                	push   $0x0
  pushl $185
8010740f:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107414:	e9 40 f2 ff ff       	jmp    80106659 <alltraps>

80107419 <vector186>:
.globl vector186
vector186:
  pushl $0
80107419:	6a 00                	push   $0x0
  pushl $186
8010741b:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107420:	e9 34 f2 ff ff       	jmp    80106659 <alltraps>

80107425 <vector187>:
.globl vector187
vector187:
  pushl $0
80107425:	6a 00                	push   $0x0
  pushl $187
80107427:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010742c:	e9 28 f2 ff ff       	jmp    80106659 <alltraps>

80107431 <vector188>:
.globl vector188
vector188:
  pushl $0
80107431:	6a 00                	push   $0x0
  pushl $188
80107433:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107438:	e9 1c f2 ff ff       	jmp    80106659 <alltraps>

8010743d <vector189>:
.globl vector189
vector189:
  pushl $0
8010743d:	6a 00                	push   $0x0
  pushl $189
8010743f:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107444:	e9 10 f2 ff ff       	jmp    80106659 <alltraps>

80107449 <vector190>:
.globl vector190
vector190:
  pushl $0
80107449:	6a 00                	push   $0x0
  pushl $190
8010744b:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107450:	e9 04 f2 ff ff       	jmp    80106659 <alltraps>

80107455 <vector191>:
.globl vector191
vector191:
  pushl $0
80107455:	6a 00                	push   $0x0
  pushl $191
80107457:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010745c:	e9 f8 f1 ff ff       	jmp    80106659 <alltraps>

80107461 <vector192>:
.globl vector192
vector192:
  pushl $0
80107461:	6a 00                	push   $0x0
  pushl $192
80107463:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107468:	e9 ec f1 ff ff       	jmp    80106659 <alltraps>

8010746d <vector193>:
.globl vector193
vector193:
  pushl $0
8010746d:	6a 00                	push   $0x0
  pushl $193
8010746f:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107474:	e9 e0 f1 ff ff       	jmp    80106659 <alltraps>

80107479 <vector194>:
.globl vector194
vector194:
  pushl $0
80107479:	6a 00                	push   $0x0
  pushl $194
8010747b:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107480:	e9 d4 f1 ff ff       	jmp    80106659 <alltraps>

80107485 <vector195>:
.globl vector195
vector195:
  pushl $0
80107485:	6a 00                	push   $0x0
  pushl $195
80107487:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010748c:	e9 c8 f1 ff ff       	jmp    80106659 <alltraps>

80107491 <vector196>:
.globl vector196
vector196:
  pushl $0
80107491:	6a 00                	push   $0x0
  pushl $196
80107493:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107498:	e9 bc f1 ff ff       	jmp    80106659 <alltraps>

8010749d <vector197>:
.globl vector197
vector197:
  pushl $0
8010749d:	6a 00                	push   $0x0
  pushl $197
8010749f:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801074a4:	e9 b0 f1 ff ff       	jmp    80106659 <alltraps>

801074a9 <vector198>:
.globl vector198
vector198:
  pushl $0
801074a9:	6a 00                	push   $0x0
  pushl $198
801074ab:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801074b0:	e9 a4 f1 ff ff       	jmp    80106659 <alltraps>

801074b5 <vector199>:
.globl vector199
vector199:
  pushl $0
801074b5:	6a 00                	push   $0x0
  pushl $199
801074b7:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801074bc:	e9 98 f1 ff ff       	jmp    80106659 <alltraps>

801074c1 <vector200>:
.globl vector200
vector200:
  pushl $0
801074c1:	6a 00                	push   $0x0
  pushl $200
801074c3:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801074c8:	e9 8c f1 ff ff       	jmp    80106659 <alltraps>

801074cd <vector201>:
.globl vector201
vector201:
  pushl $0
801074cd:	6a 00                	push   $0x0
  pushl $201
801074cf:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801074d4:	e9 80 f1 ff ff       	jmp    80106659 <alltraps>

801074d9 <vector202>:
.globl vector202
vector202:
  pushl $0
801074d9:	6a 00                	push   $0x0
  pushl $202
801074db:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801074e0:	e9 74 f1 ff ff       	jmp    80106659 <alltraps>

801074e5 <vector203>:
.globl vector203
vector203:
  pushl $0
801074e5:	6a 00                	push   $0x0
  pushl $203
801074e7:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801074ec:	e9 68 f1 ff ff       	jmp    80106659 <alltraps>

801074f1 <vector204>:
.globl vector204
vector204:
  pushl $0
801074f1:	6a 00                	push   $0x0
  pushl $204
801074f3:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801074f8:	e9 5c f1 ff ff       	jmp    80106659 <alltraps>

801074fd <vector205>:
.globl vector205
vector205:
  pushl $0
801074fd:	6a 00                	push   $0x0
  pushl $205
801074ff:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107504:	e9 50 f1 ff ff       	jmp    80106659 <alltraps>

80107509 <vector206>:
.globl vector206
vector206:
  pushl $0
80107509:	6a 00                	push   $0x0
  pushl $206
8010750b:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107510:	e9 44 f1 ff ff       	jmp    80106659 <alltraps>

80107515 <vector207>:
.globl vector207
vector207:
  pushl $0
80107515:	6a 00                	push   $0x0
  pushl $207
80107517:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010751c:	e9 38 f1 ff ff       	jmp    80106659 <alltraps>

80107521 <vector208>:
.globl vector208
vector208:
  pushl $0
80107521:	6a 00                	push   $0x0
  pushl $208
80107523:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107528:	e9 2c f1 ff ff       	jmp    80106659 <alltraps>

8010752d <vector209>:
.globl vector209
vector209:
  pushl $0
8010752d:	6a 00                	push   $0x0
  pushl $209
8010752f:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107534:	e9 20 f1 ff ff       	jmp    80106659 <alltraps>

80107539 <vector210>:
.globl vector210
vector210:
  pushl $0
80107539:	6a 00                	push   $0x0
  pushl $210
8010753b:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107540:	e9 14 f1 ff ff       	jmp    80106659 <alltraps>

80107545 <vector211>:
.globl vector211
vector211:
  pushl $0
80107545:	6a 00                	push   $0x0
  pushl $211
80107547:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010754c:	e9 08 f1 ff ff       	jmp    80106659 <alltraps>

80107551 <vector212>:
.globl vector212
vector212:
  pushl $0
80107551:	6a 00                	push   $0x0
  pushl $212
80107553:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107558:	e9 fc f0 ff ff       	jmp    80106659 <alltraps>

8010755d <vector213>:
.globl vector213
vector213:
  pushl $0
8010755d:	6a 00                	push   $0x0
  pushl $213
8010755f:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107564:	e9 f0 f0 ff ff       	jmp    80106659 <alltraps>

80107569 <vector214>:
.globl vector214
vector214:
  pushl $0
80107569:	6a 00                	push   $0x0
  pushl $214
8010756b:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107570:	e9 e4 f0 ff ff       	jmp    80106659 <alltraps>

80107575 <vector215>:
.globl vector215
vector215:
  pushl $0
80107575:	6a 00                	push   $0x0
  pushl $215
80107577:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010757c:	e9 d8 f0 ff ff       	jmp    80106659 <alltraps>

80107581 <vector216>:
.globl vector216
vector216:
  pushl $0
80107581:	6a 00                	push   $0x0
  pushl $216
80107583:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107588:	e9 cc f0 ff ff       	jmp    80106659 <alltraps>

8010758d <vector217>:
.globl vector217
vector217:
  pushl $0
8010758d:	6a 00                	push   $0x0
  pushl $217
8010758f:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107594:	e9 c0 f0 ff ff       	jmp    80106659 <alltraps>

80107599 <vector218>:
.globl vector218
vector218:
  pushl $0
80107599:	6a 00                	push   $0x0
  pushl $218
8010759b:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801075a0:	e9 b4 f0 ff ff       	jmp    80106659 <alltraps>

801075a5 <vector219>:
.globl vector219
vector219:
  pushl $0
801075a5:	6a 00                	push   $0x0
  pushl $219
801075a7:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801075ac:	e9 a8 f0 ff ff       	jmp    80106659 <alltraps>

801075b1 <vector220>:
.globl vector220
vector220:
  pushl $0
801075b1:	6a 00                	push   $0x0
  pushl $220
801075b3:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801075b8:	e9 9c f0 ff ff       	jmp    80106659 <alltraps>

801075bd <vector221>:
.globl vector221
vector221:
  pushl $0
801075bd:	6a 00                	push   $0x0
  pushl $221
801075bf:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801075c4:	e9 90 f0 ff ff       	jmp    80106659 <alltraps>

801075c9 <vector222>:
.globl vector222
vector222:
  pushl $0
801075c9:	6a 00                	push   $0x0
  pushl $222
801075cb:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801075d0:	e9 84 f0 ff ff       	jmp    80106659 <alltraps>

801075d5 <vector223>:
.globl vector223
vector223:
  pushl $0
801075d5:	6a 00                	push   $0x0
  pushl $223
801075d7:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801075dc:	e9 78 f0 ff ff       	jmp    80106659 <alltraps>

801075e1 <vector224>:
.globl vector224
vector224:
  pushl $0
801075e1:	6a 00                	push   $0x0
  pushl $224
801075e3:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801075e8:	e9 6c f0 ff ff       	jmp    80106659 <alltraps>

801075ed <vector225>:
.globl vector225
vector225:
  pushl $0
801075ed:	6a 00                	push   $0x0
  pushl $225
801075ef:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801075f4:	e9 60 f0 ff ff       	jmp    80106659 <alltraps>

801075f9 <vector226>:
.globl vector226
vector226:
  pushl $0
801075f9:	6a 00                	push   $0x0
  pushl $226
801075fb:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107600:	e9 54 f0 ff ff       	jmp    80106659 <alltraps>

80107605 <vector227>:
.globl vector227
vector227:
  pushl $0
80107605:	6a 00                	push   $0x0
  pushl $227
80107607:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010760c:	e9 48 f0 ff ff       	jmp    80106659 <alltraps>

80107611 <vector228>:
.globl vector228
vector228:
  pushl $0
80107611:	6a 00                	push   $0x0
  pushl $228
80107613:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107618:	e9 3c f0 ff ff       	jmp    80106659 <alltraps>

8010761d <vector229>:
.globl vector229
vector229:
  pushl $0
8010761d:	6a 00                	push   $0x0
  pushl $229
8010761f:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107624:	e9 30 f0 ff ff       	jmp    80106659 <alltraps>

80107629 <vector230>:
.globl vector230
vector230:
  pushl $0
80107629:	6a 00                	push   $0x0
  pushl $230
8010762b:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107630:	e9 24 f0 ff ff       	jmp    80106659 <alltraps>

80107635 <vector231>:
.globl vector231
vector231:
  pushl $0
80107635:	6a 00                	push   $0x0
  pushl $231
80107637:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010763c:	e9 18 f0 ff ff       	jmp    80106659 <alltraps>

80107641 <vector232>:
.globl vector232
vector232:
  pushl $0
80107641:	6a 00                	push   $0x0
  pushl $232
80107643:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107648:	e9 0c f0 ff ff       	jmp    80106659 <alltraps>

8010764d <vector233>:
.globl vector233
vector233:
  pushl $0
8010764d:	6a 00                	push   $0x0
  pushl $233
8010764f:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107654:	e9 00 f0 ff ff       	jmp    80106659 <alltraps>

80107659 <vector234>:
.globl vector234
vector234:
  pushl $0
80107659:	6a 00                	push   $0x0
  pushl $234
8010765b:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107660:	e9 f4 ef ff ff       	jmp    80106659 <alltraps>

80107665 <vector235>:
.globl vector235
vector235:
  pushl $0
80107665:	6a 00                	push   $0x0
  pushl $235
80107667:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010766c:	e9 e8 ef ff ff       	jmp    80106659 <alltraps>

80107671 <vector236>:
.globl vector236
vector236:
  pushl $0
80107671:	6a 00                	push   $0x0
  pushl $236
80107673:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107678:	e9 dc ef ff ff       	jmp    80106659 <alltraps>

8010767d <vector237>:
.globl vector237
vector237:
  pushl $0
8010767d:	6a 00                	push   $0x0
  pushl $237
8010767f:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107684:	e9 d0 ef ff ff       	jmp    80106659 <alltraps>

80107689 <vector238>:
.globl vector238
vector238:
  pushl $0
80107689:	6a 00                	push   $0x0
  pushl $238
8010768b:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107690:	e9 c4 ef ff ff       	jmp    80106659 <alltraps>

80107695 <vector239>:
.globl vector239
vector239:
  pushl $0
80107695:	6a 00                	push   $0x0
  pushl $239
80107697:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010769c:	e9 b8 ef ff ff       	jmp    80106659 <alltraps>

801076a1 <vector240>:
.globl vector240
vector240:
  pushl $0
801076a1:	6a 00                	push   $0x0
  pushl $240
801076a3:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801076a8:	e9 ac ef ff ff       	jmp    80106659 <alltraps>

801076ad <vector241>:
.globl vector241
vector241:
  pushl $0
801076ad:	6a 00                	push   $0x0
  pushl $241
801076af:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801076b4:	e9 a0 ef ff ff       	jmp    80106659 <alltraps>

801076b9 <vector242>:
.globl vector242
vector242:
  pushl $0
801076b9:	6a 00                	push   $0x0
  pushl $242
801076bb:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801076c0:	e9 94 ef ff ff       	jmp    80106659 <alltraps>

801076c5 <vector243>:
.globl vector243
vector243:
  pushl $0
801076c5:	6a 00                	push   $0x0
  pushl $243
801076c7:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801076cc:	e9 88 ef ff ff       	jmp    80106659 <alltraps>

801076d1 <vector244>:
.globl vector244
vector244:
  pushl $0
801076d1:	6a 00                	push   $0x0
  pushl $244
801076d3:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801076d8:	e9 7c ef ff ff       	jmp    80106659 <alltraps>

801076dd <vector245>:
.globl vector245
vector245:
  pushl $0
801076dd:	6a 00                	push   $0x0
  pushl $245
801076df:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801076e4:	e9 70 ef ff ff       	jmp    80106659 <alltraps>

801076e9 <vector246>:
.globl vector246
vector246:
  pushl $0
801076e9:	6a 00                	push   $0x0
  pushl $246
801076eb:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801076f0:	e9 64 ef ff ff       	jmp    80106659 <alltraps>

801076f5 <vector247>:
.globl vector247
vector247:
  pushl $0
801076f5:	6a 00                	push   $0x0
  pushl $247
801076f7:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801076fc:	e9 58 ef ff ff       	jmp    80106659 <alltraps>

80107701 <vector248>:
.globl vector248
vector248:
  pushl $0
80107701:	6a 00                	push   $0x0
  pushl $248
80107703:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107708:	e9 4c ef ff ff       	jmp    80106659 <alltraps>

8010770d <vector249>:
.globl vector249
vector249:
  pushl $0
8010770d:	6a 00                	push   $0x0
  pushl $249
8010770f:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107714:	e9 40 ef ff ff       	jmp    80106659 <alltraps>

80107719 <vector250>:
.globl vector250
vector250:
  pushl $0
80107719:	6a 00                	push   $0x0
  pushl $250
8010771b:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107720:	e9 34 ef ff ff       	jmp    80106659 <alltraps>

80107725 <vector251>:
.globl vector251
vector251:
  pushl $0
80107725:	6a 00                	push   $0x0
  pushl $251
80107727:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010772c:	e9 28 ef ff ff       	jmp    80106659 <alltraps>

80107731 <vector252>:
.globl vector252
vector252:
  pushl $0
80107731:	6a 00                	push   $0x0
  pushl $252
80107733:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107738:	e9 1c ef ff ff       	jmp    80106659 <alltraps>

8010773d <vector253>:
.globl vector253
vector253:
  pushl $0
8010773d:	6a 00                	push   $0x0
  pushl $253
8010773f:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107744:	e9 10 ef ff ff       	jmp    80106659 <alltraps>

80107749 <vector254>:
.globl vector254
vector254:
  pushl $0
80107749:	6a 00                	push   $0x0
  pushl $254
8010774b:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107750:	e9 04 ef ff ff       	jmp    80106659 <alltraps>

80107755 <vector255>:
.globl vector255
vector255:
  pushl $0
80107755:	6a 00                	push   $0x0
  pushl $255
80107757:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010775c:	e9 f8 ee ff ff       	jmp    80106659 <alltraps>

80107761 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107761:	55                   	push   %ebp
80107762:	89 e5                	mov    %esp,%ebp
80107764:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107767:	8b 45 0c             	mov    0xc(%ebp),%eax
8010776a:	83 e8 01             	sub    $0x1,%eax
8010776d:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107771:	8b 45 08             	mov    0x8(%ebp),%eax
80107774:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107778:	8b 45 08             	mov    0x8(%ebp),%eax
8010777b:	c1 e8 10             	shr    $0x10,%eax
8010777e:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107782:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107785:	0f 01 10             	lgdtl  (%eax)
}
80107788:	c9                   	leave  
80107789:	c3                   	ret    

8010778a <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010778a:	55                   	push   %ebp
8010778b:	89 e5                	mov    %esp,%ebp
8010778d:	83 ec 04             	sub    $0x4,%esp
80107790:	8b 45 08             	mov    0x8(%ebp),%eax
80107793:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107797:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010779b:	0f 00 d8             	ltr    %ax
}
8010779e:	c9                   	leave  
8010779f:	c3                   	ret    

801077a0 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801077a0:	55                   	push   %ebp
801077a1:	89 e5                	mov    %esp,%ebp
801077a3:	83 ec 04             	sub    $0x4,%esp
801077a6:	8b 45 08             	mov    0x8(%ebp),%eax
801077a9:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801077ad:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801077b1:	8e e8                	mov    %eax,%gs
}
801077b3:	c9                   	leave  
801077b4:	c3                   	ret    

801077b5 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801077b5:	55                   	push   %ebp
801077b6:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801077b8:	8b 45 08             	mov    0x8(%ebp),%eax
801077bb:	0f 22 d8             	mov    %eax,%cr3
}
801077be:	5d                   	pop    %ebp
801077bf:	c3                   	ret    

801077c0 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801077c0:	55                   	push   %ebp
801077c1:	89 e5                	mov    %esp,%ebp
801077c3:	8b 45 08             	mov    0x8(%ebp),%eax
801077c6:	05 00 00 00 80       	add    $0x80000000,%eax
801077cb:	5d                   	pop    %ebp
801077cc:	c3                   	ret    

801077cd <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801077cd:	55                   	push   %ebp
801077ce:	89 e5                	mov    %esp,%ebp
801077d0:	8b 45 08             	mov    0x8(%ebp),%eax
801077d3:	05 00 00 00 80       	add    $0x80000000,%eax
801077d8:	5d                   	pop    %ebp
801077d9:	c3                   	ret    

801077da <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801077da:	55                   	push   %ebp
801077db:	89 e5                	mov    %esp,%ebp
801077dd:	53                   	push   %ebx
801077de:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];  
801077e1:	e8 6c b8 ff ff       	call   80103052 <cpunum>
801077e6:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
801077ec:	05 60 23 11 80       	add    $0x80112360,%eax
801077f1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801077f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f7:	66 c7 40 7c ff ff    	movw   $0xffff,0x7c(%eax)
801077fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107800:	66 c7 40 7e 00 00    	movw   $0x0,0x7e(%eax)
80107806:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107809:	c6 80 80 00 00 00 00 	movb   $0x0,0x80(%eax)
80107810:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107813:	0f b6 90 81 00 00 00 	movzbl 0x81(%eax),%edx
8010781a:	83 e2 f0             	and    $0xfffffff0,%edx
8010781d:	83 ca 0a             	or     $0xa,%edx
80107820:	88 90 81 00 00 00    	mov    %dl,0x81(%eax)
80107826:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107829:	0f b6 90 81 00 00 00 	movzbl 0x81(%eax),%edx
80107830:	83 ca 10             	or     $0x10,%edx
80107833:	88 90 81 00 00 00    	mov    %dl,0x81(%eax)
80107839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010783c:	0f b6 90 81 00 00 00 	movzbl 0x81(%eax),%edx
80107843:	83 e2 9f             	and    $0xffffff9f,%edx
80107846:	88 90 81 00 00 00    	mov    %dl,0x81(%eax)
8010784c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010784f:	0f b6 90 81 00 00 00 	movzbl 0x81(%eax),%edx
80107856:	83 ca 80             	or     $0xffffff80,%edx
80107859:	88 90 81 00 00 00    	mov    %dl,0x81(%eax)
8010785f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107862:	0f b6 90 82 00 00 00 	movzbl 0x82(%eax),%edx
80107869:	83 ca 0f             	or     $0xf,%edx
8010786c:	88 90 82 00 00 00    	mov    %dl,0x82(%eax)
80107872:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107875:	0f b6 90 82 00 00 00 	movzbl 0x82(%eax),%edx
8010787c:	83 e2 ef             	and    $0xffffffef,%edx
8010787f:	88 90 82 00 00 00    	mov    %dl,0x82(%eax)
80107885:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107888:	0f b6 90 82 00 00 00 	movzbl 0x82(%eax),%edx
8010788f:	83 e2 df             	and    $0xffffffdf,%edx
80107892:	88 90 82 00 00 00    	mov    %dl,0x82(%eax)
80107898:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789b:	0f b6 90 82 00 00 00 	movzbl 0x82(%eax),%edx
801078a2:	83 ca 40             	or     $0x40,%edx
801078a5:	88 90 82 00 00 00    	mov    %dl,0x82(%eax)
801078ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ae:	0f b6 90 82 00 00 00 	movzbl 0x82(%eax),%edx
801078b5:	83 ca 80             	or     $0xffffff80,%edx
801078b8:	88 90 82 00 00 00    	mov    %dl,0x82(%eax)
801078be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c1:	c6 80 83 00 00 00 00 	movb   $0x0,0x83(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801078c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078cb:	66 c7 80 84 00 00 00 	movw   $0xffff,0x84(%eax)
801078d2:	ff ff 
801078d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d7:	66 c7 80 86 00 00 00 	movw   $0x0,0x86(%eax)
801078de:	00 00 
801078e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e3:	c6 80 88 00 00 00 00 	movb   $0x0,0x88(%eax)
801078ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ed:	0f b6 90 89 00 00 00 	movzbl 0x89(%eax),%edx
801078f4:	83 e2 f0             	and    $0xfffffff0,%edx
801078f7:	83 ca 02             	or     $0x2,%edx
801078fa:	88 90 89 00 00 00    	mov    %dl,0x89(%eax)
80107900:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107903:	0f b6 90 89 00 00 00 	movzbl 0x89(%eax),%edx
8010790a:	83 ca 10             	or     $0x10,%edx
8010790d:	88 90 89 00 00 00    	mov    %dl,0x89(%eax)
80107913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107916:	0f b6 90 89 00 00 00 	movzbl 0x89(%eax),%edx
8010791d:	83 e2 9f             	and    $0xffffff9f,%edx
80107920:	88 90 89 00 00 00    	mov    %dl,0x89(%eax)
80107926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107929:	0f b6 90 89 00 00 00 	movzbl 0x89(%eax),%edx
80107930:	83 ca 80             	or     $0xffffff80,%edx
80107933:	88 90 89 00 00 00    	mov    %dl,0x89(%eax)
80107939:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010793c:	0f b6 90 8a 00 00 00 	movzbl 0x8a(%eax),%edx
80107943:	83 ca 0f             	or     $0xf,%edx
80107946:	88 90 8a 00 00 00    	mov    %dl,0x8a(%eax)
8010794c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010794f:	0f b6 90 8a 00 00 00 	movzbl 0x8a(%eax),%edx
80107956:	83 e2 ef             	and    $0xffffffef,%edx
80107959:	88 90 8a 00 00 00    	mov    %dl,0x8a(%eax)
8010795f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107962:	0f b6 90 8a 00 00 00 	movzbl 0x8a(%eax),%edx
80107969:	83 e2 df             	and    $0xffffffdf,%edx
8010796c:	88 90 8a 00 00 00    	mov    %dl,0x8a(%eax)
80107972:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107975:	0f b6 90 8a 00 00 00 	movzbl 0x8a(%eax),%edx
8010797c:	83 ca 40             	or     $0x40,%edx
8010797f:	88 90 8a 00 00 00    	mov    %dl,0x8a(%eax)
80107985:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107988:	0f b6 90 8a 00 00 00 	movzbl 0x8a(%eax),%edx
8010798f:	83 ca 80             	or     $0xffffff80,%edx
80107992:	88 90 8a 00 00 00    	mov    %dl,0x8a(%eax)
80107998:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010799b:	c6 80 8b 00 00 00 00 	movb   $0x0,0x8b(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801079a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a5:	66 c7 80 94 00 00 00 	movw   $0xffff,0x94(%eax)
801079ac:	ff ff 
801079ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b1:	66 c7 80 96 00 00 00 	movw   $0x0,0x96(%eax)
801079b8:	00 00 
801079ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079bd:	c6 80 98 00 00 00 00 	movb   $0x0,0x98(%eax)
801079c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c7:	0f b6 90 99 00 00 00 	movzbl 0x99(%eax),%edx
801079ce:	83 e2 f0             	and    $0xfffffff0,%edx
801079d1:	83 ca 0a             	or     $0xa,%edx
801079d4:	88 90 99 00 00 00    	mov    %dl,0x99(%eax)
801079da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079dd:	0f b6 90 99 00 00 00 	movzbl 0x99(%eax),%edx
801079e4:	83 ca 10             	or     $0x10,%edx
801079e7:	88 90 99 00 00 00    	mov    %dl,0x99(%eax)
801079ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f0:	0f b6 90 99 00 00 00 	movzbl 0x99(%eax),%edx
801079f7:	83 ca 60             	or     $0x60,%edx
801079fa:	88 90 99 00 00 00    	mov    %dl,0x99(%eax)
80107a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a03:	0f b6 90 99 00 00 00 	movzbl 0x99(%eax),%edx
80107a0a:	83 ca 80             	or     $0xffffff80,%edx
80107a0d:	88 90 99 00 00 00    	mov    %dl,0x99(%eax)
80107a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a16:	0f b6 90 9a 00 00 00 	movzbl 0x9a(%eax),%edx
80107a1d:	83 ca 0f             	or     $0xf,%edx
80107a20:	88 90 9a 00 00 00    	mov    %dl,0x9a(%eax)
80107a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a29:	0f b6 90 9a 00 00 00 	movzbl 0x9a(%eax),%edx
80107a30:	83 e2 ef             	and    $0xffffffef,%edx
80107a33:	88 90 9a 00 00 00    	mov    %dl,0x9a(%eax)
80107a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a3c:	0f b6 90 9a 00 00 00 	movzbl 0x9a(%eax),%edx
80107a43:	83 e2 df             	and    $0xffffffdf,%edx
80107a46:	88 90 9a 00 00 00    	mov    %dl,0x9a(%eax)
80107a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4f:	0f b6 90 9a 00 00 00 	movzbl 0x9a(%eax),%edx
80107a56:	83 ca 40             	or     $0x40,%edx
80107a59:	88 90 9a 00 00 00    	mov    %dl,0x9a(%eax)
80107a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a62:	0f b6 90 9a 00 00 00 	movzbl 0x9a(%eax),%edx
80107a69:	83 ca 80             	or     $0xffffff80,%edx
80107a6c:	88 90 9a 00 00 00    	mov    %dl,0x9a(%eax)
80107a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a75:	c6 80 9b 00 00 00 00 	movb   $0x0,0x9b(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7f:	66 c7 80 9c 00 00 00 	movw   $0xffff,0x9c(%eax)
80107a86:	ff ff 
80107a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8b:	66 c7 80 9e 00 00 00 	movw   $0x0,0x9e(%eax)
80107a92:	00 00 
80107a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a97:	c6 80 a0 00 00 00 00 	movb   $0x0,0xa0(%eax)
80107a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa1:	0f b6 90 a1 00 00 00 	movzbl 0xa1(%eax),%edx
80107aa8:	83 e2 f0             	and    $0xfffffff0,%edx
80107aab:	83 ca 02             	or     $0x2,%edx
80107aae:	88 90 a1 00 00 00    	mov    %dl,0xa1(%eax)
80107ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab7:	0f b6 90 a1 00 00 00 	movzbl 0xa1(%eax),%edx
80107abe:	83 ca 10             	or     $0x10,%edx
80107ac1:	88 90 a1 00 00 00    	mov    %dl,0xa1(%eax)
80107ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aca:	0f b6 90 a1 00 00 00 	movzbl 0xa1(%eax),%edx
80107ad1:	83 ca 60             	or     $0x60,%edx
80107ad4:	88 90 a1 00 00 00    	mov    %dl,0xa1(%eax)
80107ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107add:	0f b6 90 a1 00 00 00 	movzbl 0xa1(%eax),%edx
80107ae4:	83 ca 80             	or     $0xffffff80,%edx
80107ae7:	88 90 a1 00 00 00    	mov    %dl,0xa1(%eax)
80107aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af0:	0f b6 90 a2 00 00 00 	movzbl 0xa2(%eax),%edx
80107af7:	83 ca 0f             	or     $0xf,%edx
80107afa:	88 90 a2 00 00 00    	mov    %dl,0xa2(%eax)
80107b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b03:	0f b6 90 a2 00 00 00 	movzbl 0xa2(%eax),%edx
80107b0a:	83 e2 ef             	and    $0xffffffef,%edx
80107b0d:	88 90 a2 00 00 00    	mov    %dl,0xa2(%eax)
80107b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b16:	0f b6 90 a2 00 00 00 	movzbl 0xa2(%eax),%edx
80107b1d:	83 e2 df             	and    $0xffffffdf,%edx
80107b20:	88 90 a2 00 00 00    	mov    %dl,0xa2(%eax)
80107b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b29:	0f b6 90 a2 00 00 00 	movzbl 0xa2(%eax),%edx
80107b30:	83 ca 40             	or     $0x40,%edx
80107b33:	88 90 a2 00 00 00    	mov    %dl,0xa2(%eax)
80107b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3c:	0f b6 90 a2 00 00 00 	movzbl 0xa2(%eax),%edx
80107b43:	83 ca 80             	or     $0xffffff80,%edx
80107b46:	88 90 a2 00 00 00    	mov    %dl,0xa2(%eax)
80107b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4f:	c6 80 a3 00 00 00 00 	movb   $0x0,0xa3(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107b56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b59:	05 b8 00 00 00       	add    $0xb8,%eax
80107b5e:	89 c3                	mov    %eax,%ebx
80107b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b63:	05 b8 00 00 00       	add    $0xb8,%eax
80107b68:	c1 e8 10             	shr    $0x10,%eax
80107b6b:	89 c1                	mov    %eax,%ecx
80107b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b70:	05 b8 00 00 00       	add    $0xb8,%eax
80107b75:	c1 e8 18             	shr    $0x18,%eax
80107b78:	89 c2                	mov    %eax,%edx
80107b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7d:	66 c7 80 8c 00 00 00 	movw   $0x0,0x8c(%eax)
80107b84:	00 00 
80107b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b89:	66 89 98 8e 00 00 00 	mov    %bx,0x8e(%eax)
80107b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b93:	88 88 90 00 00 00    	mov    %cl,0x90(%eax)
80107b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9c:	0f b6 88 91 00 00 00 	movzbl 0x91(%eax),%ecx
80107ba3:	83 e1 f0             	and    $0xfffffff0,%ecx
80107ba6:	83 c9 02             	or     $0x2,%ecx
80107ba9:	88 88 91 00 00 00    	mov    %cl,0x91(%eax)
80107baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb2:	0f b6 88 91 00 00 00 	movzbl 0x91(%eax),%ecx
80107bb9:	83 c9 10             	or     $0x10,%ecx
80107bbc:	88 88 91 00 00 00    	mov    %cl,0x91(%eax)
80107bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc5:	0f b6 88 91 00 00 00 	movzbl 0x91(%eax),%ecx
80107bcc:	83 e1 9f             	and    $0xffffff9f,%ecx
80107bcf:	88 88 91 00 00 00    	mov    %cl,0x91(%eax)
80107bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd8:	0f b6 88 91 00 00 00 	movzbl 0x91(%eax),%ecx
80107bdf:	83 c9 80             	or     $0xffffff80,%ecx
80107be2:	88 88 91 00 00 00    	mov    %cl,0x91(%eax)
80107be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107beb:	0f b6 88 92 00 00 00 	movzbl 0x92(%eax),%ecx
80107bf2:	83 e1 f0             	and    $0xfffffff0,%ecx
80107bf5:	88 88 92 00 00 00    	mov    %cl,0x92(%eax)
80107bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfe:	0f b6 88 92 00 00 00 	movzbl 0x92(%eax),%ecx
80107c05:	83 e1 ef             	and    $0xffffffef,%ecx
80107c08:	88 88 92 00 00 00    	mov    %cl,0x92(%eax)
80107c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c11:	0f b6 88 92 00 00 00 	movzbl 0x92(%eax),%ecx
80107c18:	83 e1 df             	and    $0xffffffdf,%ecx
80107c1b:	88 88 92 00 00 00    	mov    %cl,0x92(%eax)
80107c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c24:	0f b6 88 92 00 00 00 	movzbl 0x92(%eax),%ecx
80107c2b:	83 c9 40             	or     $0x40,%ecx
80107c2e:	88 88 92 00 00 00    	mov    %cl,0x92(%eax)
80107c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c37:	0f b6 88 92 00 00 00 	movzbl 0x92(%eax),%ecx
80107c3e:	83 c9 80             	or     $0xffffff80,%ecx
80107c41:	88 88 92 00 00 00    	mov    %cl,0x92(%eax)
80107c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4a:	88 90 93 00 00 00    	mov    %dl,0x93(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c53:	83 c0 74             	add    $0x74,%eax
80107c56:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107c5d:	00 
80107c5e:	89 04 24             	mov    %eax,(%esp)
80107c61:	e8 fb fa ff ff       	call   80107761 <lgdt>
  loadgs(SEG_KCPU << 3);
80107c66:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107c6d:	e8 2e fb ff ff       	call   801077a0 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c75:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107c7b:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107c82:	00 00 00 00 
}
80107c86:	83 c4 24             	add    $0x24,%esp
80107c89:	5b                   	pop    %ebx
80107c8a:	5d                   	pop    %ebp
80107c8b:	c3                   	ret    

80107c8c <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107c8c:	55                   	push   %ebp
80107c8d:	89 e5                	mov    %esp,%ebp
80107c8f:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107c92:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c95:	c1 e8 16             	shr    $0x16,%eax
80107c98:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107c9f:	8b 45 08             	mov    0x8(%ebp),%eax
80107ca2:	01 d0                	add    %edx,%eax
80107ca4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107ca7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107caa:	8b 00                	mov    (%eax),%eax
80107cac:	83 e0 01             	and    $0x1,%eax
80107caf:	85 c0                	test   %eax,%eax
80107cb1:	74 17                	je     80107cca <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107cb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cb6:	8b 00                	mov    (%eax),%eax
80107cb8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107cbd:	89 04 24             	mov    %eax,(%esp)
80107cc0:	e8 08 fb ff ff       	call   801077cd <p2v>
80107cc5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107cc8:	eb 4b                	jmp    80107d15 <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107cca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107cce:	74 0e                	je     80107cde <walkpgdir+0x52>
80107cd0:	e8 e7 af ff ff       	call   80102cbc <kalloc>
80107cd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107cd8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107cdc:	75 07                	jne    80107ce5 <walkpgdir+0x59>
      return 0;
80107cde:	b8 00 00 00 00       	mov    $0x0,%eax
80107ce3:	eb 47                	jmp    80107d2c <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107ce5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107cec:	00 
80107ced:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107cf4:	00 
80107cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf8:	89 04 24             	mov    %eax,(%esp)
80107cfb:	e8 65 d5 ff ff       	call   80105265 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d03:	89 04 24             	mov    %eax,(%esp)
80107d06:	e8 b5 fa ff ff       	call   801077c0 <v2p>
80107d0b:	83 c8 07             	or     $0x7,%eax
80107d0e:	89 c2                	mov    %eax,%edx
80107d10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d13:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107d15:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d18:	c1 e8 0c             	shr    $0xc,%eax
80107d1b:	25 ff 03 00 00       	and    $0x3ff,%eax
80107d20:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2a:	01 d0                	add    %edx,%eax
}
80107d2c:	c9                   	leave  
80107d2d:	c3                   	ret    

80107d2e <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107d2e:	55                   	push   %ebp
80107d2f:	89 e5                	mov    %esp,%ebp
80107d31:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107d34:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d37:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107d3f:	8b 55 0c             	mov    0xc(%ebp),%edx
80107d42:	8b 45 10             	mov    0x10(%ebp),%eax
80107d45:	01 d0                	add    %edx,%eax
80107d47:	83 e8 01             	sub    $0x1,%eax
80107d4a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107d52:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107d59:	00 
80107d5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5d:	89 44 24 04          	mov    %eax,0x4(%esp)
80107d61:	8b 45 08             	mov    0x8(%ebp),%eax
80107d64:	89 04 24             	mov    %eax,(%esp)
80107d67:	e8 20 ff ff ff       	call   80107c8c <walkpgdir>
80107d6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107d6f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d73:	75 07                	jne    80107d7c <mappages+0x4e>
      return -1;
80107d75:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d7a:	eb 48                	jmp    80107dc4 <mappages+0x96>
    if(*pte & PTE_P)
80107d7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d7f:	8b 00                	mov    (%eax),%eax
80107d81:	83 e0 01             	and    $0x1,%eax
80107d84:	85 c0                	test   %eax,%eax
80107d86:	74 0c                	je     80107d94 <mappages+0x66>
      panic("remap");
80107d88:	c7 04 24 58 8d 10 80 	movl   $0x80108d58,(%esp)
80107d8f:	e8 4e 89 ff ff       	call   801006e2 <panic>
    *pte = pa | perm | PTE_P;
80107d94:	8b 45 18             	mov    0x18(%ebp),%eax
80107d97:	0b 45 14             	or     0x14(%ebp),%eax
80107d9a:	83 c8 01             	or     $0x1,%eax
80107d9d:	89 c2                	mov    %eax,%edx
80107d9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107da2:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107daa:	75 08                	jne    80107db4 <mappages+0x86>
      break;
80107dac:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107dad:	b8 00 00 00 00       	mov    $0x0,%eax
80107db2:	eb 10                	jmp    80107dc4 <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80107db4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107dbb:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107dc2:	eb 8e                	jmp    80107d52 <mappages+0x24>
  return 0;
}
80107dc4:	c9                   	leave  
80107dc5:	c3                   	ret    

80107dc6 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107dc6:	55                   	push   %ebp
80107dc7:	89 e5                	mov    %esp,%ebp
80107dc9:	53                   	push   %ebx
80107dca:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107dcd:	e8 ea ae ff ff       	call   80102cbc <kalloc>
80107dd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107dd5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107dd9:	75 0a                	jne    80107de5 <setupkvm+0x1f>
    return 0;
80107ddb:	b8 00 00 00 00       	mov    $0x0,%eax
80107de0:	e9 98 00 00 00       	jmp    80107e7d <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80107de5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107dec:	00 
80107ded:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107df4:	00 
80107df5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107df8:	89 04 24             	mov    %eax,(%esp)
80107dfb:	e8 65 d4 ff ff       	call   80105265 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107e00:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80107e07:	e8 c1 f9 ff ff       	call   801077cd <p2v>
80107e0c:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107e11:	76 0c                	jbe    80107e1f <setupkvm+0x59>
    panic("PHYSTOP too high");
80107e13:	c7 04 24 5e 8d 10 80 	movl   $0x80108d5e,(%esp)
80107e1a:	e8 c3 88 ff ff       	call   801006e2 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107e1f:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107e26:	eb 49                	jmp    80107e71 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e2b:	8b 48 0c             	mov    0xc(%eax),%ecx
80107e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e31:	8b 50 04             	mov    0x4(%eax),%edx
80107e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e37:	8b 58 08             	mov    0x8(%eax),%ebx
80107e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e3d:	8b 40 04             	mov    0x4(%eax),%eax
80107e40:	29 c3                	sub    %eax,%ebx
80107e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e45:	8b 00                	mov    (%eax),%eax
80107e47:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107e4b:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107e4f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107e53:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e5a:	89 04 24             	mov    %eax,(%esp)
80107e5d:	e8 cc fe ff ff       	call   80107d2e <mappages>
80107e62:	85 c0                	test   %eax,%eax
80107e64:	79 07                	jns    80107e6d <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107e66:	b8 00 00 00 00       	mov    $0x0,%eax
80107e6b:	eb 10                	jmp    80107e7d <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107e6d:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107e71:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80107e78:	72 ae                	jb     80107e28 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107e7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107e7d:	83 c4 34             	add    $0x34,%esp
80107e80:	5b                   	pop    %ebx
80107e81:	5d                   	pop    %ebp
80107e82:	c3                   	ret    

80107e83 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(struct cpu *c)
{
80107e83:	55                   	push   %ebp
80107e84:	89 e5                	mov    %esp,%ebp
80107e86:	83 ec 18             	sub    $0x18,%esp
  c->kpgdir = setupkvm();
80107e89:	e8 38 ff ff ff       	call   80107dc6 <setupkvm>
80107e8e:	8b 55 08             	mov    0x8(%ebp),%edx
80107e91:	89 42 04             	mov    %eax,0x4(%edx)
  switchkvm(c);
80107e94:	8b 45 08             	mov    0x8(%ebp),%eax
80107e97:	89 04 24             	mov    %eax,(%esp)
80107e9a:	e8 02 00 00 00       	call   80107ea1 <switchkvm>
}
80107e9f:	c9                   	leave  
80107ea0:	c3                   	ret    

80107ea1 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(struct cpu *c)
{
80107ea1:	55                   	push   %ebp
80107ea2:	89 e5                	mov    %esp,%ebp
80107ea4:	83 ec 04             	sub    $0x4,%esp

	lcr3(v2p(c->kpgdir));   // switch to the kernel page table
80107ea7:	8b 45 08             	mov    0x8(%ebp),%eax
80107eaa:	8b 40 04             	mov    0x4(%eax),%eax
80107ead:	89 04 24             	mov    %eax,(%esp)
80107eb0:	e8 0b f9 ff ff       	call   801077c0 <v2p>
80107eb5:	89 04 24             	mov    %eax,(%esp)
80107eb8:	e8 f8 f8 ff ff       	call   801077b5 <lcr3>
}
80107ebd:	c9                   	leave  
80107ebe:	c3                   	ret    

80107ebf <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107ebf:	55                   	push   %ebp
80107ec0:	89 e5                	mov    %esp,%ebp
80107ec2:	53                   	push   %ebx
80107ec3:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80107ec6:	e8 9a d2 ff ff       	call   80105165 <pushcli>

  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107ecb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107ed1:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107ed8:	83 c2 0c             	add    $0xc,%edx
80107edb:	89 d3                	mov    %edx,%ebx
80107edd:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107ee4:	83 c2 0c             	add    $0xc,%edx
80107ee7:	c1 ea 10             	shr    $0x10,%edx
80107eea:	89 d1                	mov    %edx,%ecx
80107eec:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107ef3:	83 c2 0c             	add    $0xc,%edx
80107ef6:	c1 ea 18             	shr    $0x18,%edx
80107ef9:	66 c7 80 a4 00 00 00 	movw   $0x67,0xa4(%eax)
80107f00:	67 00 
80107f02:	66 89 98 a6 00 00 00 	mov    %bx,0xa6(%eax)
80107f09:	88 88 a8 00 00 00    	mov    %cl,0xa8(%eax)
80107f0f:	0f b6 88 a9 00 00 00 	movzbl 0xa9(%eax),%ecx
80107f16:	83 e1 f0             	and    $0xfffffff0,%ecx
80107f19:	83 c9 09             	or     $0x9,%ecx
80107f1c:	88 88 a9 00 00 00    	mov    %cl,0xa9(%eax)
80107f22:	0f b6 88 a9 00 00 00 	movzbl 0xa9(%eax),%ecx
80107f29:	83 c9 10             	or     $0x10,%ecx
80107f2c:	88 88 a9 00 00 00    	mov    %cl,0xa9(%eax)
80107f32:	0f b6 88 a9 00 00 00 	movzbl 0xa9(%eax),%ecx
80107f39:	83 e1 9f             	and    $0xffffff9f,%ecx
80107f3c:	88 88 a9 00 00 00    	mov    %cl,0xa9(%eax)
80107f42:	0f b6 88 a9 00 00 00 	movzbl 0xa9(%eax),%ecx
80107f49:	83 c9 80             	or     $0xffffff80,%ecx
80107f4c:	88 88 a9 00 00 00    	mov    %cl,0xa9(%eax)
80107f52:	0f b6 88 aa 00 00 00 	movzbl 0xaa(%eax),%ecx
80107f59:	83 e1 f0             	and    $0xfffffff0,%ecx
80107f5c:	88 88 aa 00 00 00    	mov    %cl,0xaa(%eax)
80107f62:	0f b6 88 aa 00 00 00 	movzbl 0xaa(%eax),%ecx
80107f69:	83 e1 ef             	and    $0xffffffef,%ecx
80107f6c:	88 88 aa 00 00 00    	mov    %cl,0xaa(%eax)
80107f72:	0f b6 88 aa 00 00 00 	movzbl 0xaa(%eax),%ecx
80107f79:	83 e1 df             	and    $0xffffffdf,%ecx
80107f7c:	88 88 aa 00 00 00    	mov    %cl,0xaa(%eax)
80107f82:	0f b6 88 aa 00 00 00 	movzbl 0xaa(%eax),%ecx
80107f89:	83 c9 40             	or     $0x40,%ecx
80107f8c:	88 88 aa 00 00 00    	mov    %cl,0xaa(%eax)
80107f92:	0f b6 88 aa 00 00 00 	movzbl 0xaa(%eax),%ecx
80107f99:	83 e1 7f             	and    $0x7f,%ecx
80107f9c:	88 88 aa 00 00 00    	mov    %cl,0xaa(%eax)
80107fa2:	88 90 ab 00 00 00    	mov    %dl,0xab(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107fa8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107fae:	0f b6 90 a9 00 00 00 	movzbl 0xa9(%eax),%edx
80107fb5:	83 e2 ef             	and    $0xffffffef,%edx
80107fb8:	88 90 a9 00 00 00    	mov    %dl,0xa9(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107fbe:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107fc4:	66 c7 40 14 10 00    	movw   $0x10,0x14(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107fca:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107fd0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107fd7:	8b 52 08             	mov    0x8(%edx),%edx
80107fda:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107fe0:	89 50 10             	mov    %edx,0x10(%eax)
  ltr(SEG_TSS << 3);
80107fe3:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80107fea:	e8 9b f7 ff ff       	call   8010778a <ltr>
  if(p->pgdir == 0)
80107fef:	8b 45 08             	mov    0x8(%ebp),%eax
80107ff2:	8b 40 04             	mov    0x4(%eax),%eax
80107ff5:	85 c0                	test   %eax,%eax
80107ff7:	75 0c                	jne    80108005 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80107ff9:	c7 04 24 6f 8d 10 80 	movl   $0x80108d6f,(%esp)
80108000:	e8 dd 86 ff ff       	call   801006e2 <panic>
 //lcr3(v2p(cpu->kpgdir));  // switch to new address space


  popcli();
80108005:	e8 9f d1 ff ff       	call   801051a9 <popcli>
}
8010800a:	83 c4 14             	add    $0x14,%esp
8010800d:	5b                   	pop    %ebx
8010800e:	5d                   	pop    %ebp
8010800f:	c3                   	ret    

80108010 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108010:	55                   	push   %ebp
80108011:	89 e5                	mov    %esp,%ebp
80108013:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108016:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010801d:	76 0c                	jbe    8010802b <inituvm+0x1b>
    panic("inituvm: more than a page");
8010801f:	c7 04 24 83 8d 10 80 	movl   $0x80108d83,(%esp)
80108026:	e8 b7 86 ff ff       	call   801006e2 <panic>
  mem = kalloc();
8010802b:	e8 8c ac ff ff       	call   80102cbc <kalloc>
80108030:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108033:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010803a:	00 
8010803b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108042:	00 
80108043:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108046:	89 04 24             	mov    %eax,(%esp)
80108049:	e8 17 d2 ff ff       	call   80105265 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010804e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108051:	89 04 24             	mov    %eax,(%esp)
80108054:	e8 67 f7 ff ff       	call   801077c0 <v2p>
80108059:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108060:	00 
80108061:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108065:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010806c:	00 
8010806d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108074:	00 
80108075:	8b 45 08             	mov    0x8(%ebp),%eax
80108078:	89 04 24             	mov    %eax,(%esp)
8010807b:	e8 ae fc ff ff       	call   80107d2e <mappages>
  memmove(mem, init, sz);
80108080:	8b 45 10             	mov    0x10(%ebp),%eax
80108083:	89 44 24 08          	mov    %eax,0x8(%esp)
80108087:	8b 45 0c             	mov    0xc(%ebp),%eax
8010808a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010808e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108091:	89 04 24             	mov    %eax,(%esp)
80108094:	e8 9b d2 ff ff       	call   80105334 <memmove>
}
80108099:	c9                   	leave  
8010809a:	c3                   	ret    

8010809b <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010809b:	55                   	push   %ebp
8010809c:	89 e5                	mov    %esp,%ebp
8010809e:	53                   	push   %ebx
8010809f:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801080a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801080a5:	25 ff 0f 00 00       	and    $0xfff,%eax
801080aa:	85 c0                	test   %eax,%eax
801080ac:	74 0c                	je     801080ba <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
801080ae:	c7 04 24 a0 8d 10 80 	movl   $0x80108da0,(%esp)
801080b5:	e8 28 86 ff ff       	call   801006e2 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801080ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801080c1:	e9 a9 00 00 00       	jmp    8010816f <loaduvm+0xd4>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801080c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c9:	8b 55 0c             	mov    0xc(%ebp),%edx
801080cc:	01 d0                	add    %edx,%eax
801080ce:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801080d5:	00 
801080d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801080da:	8b 45 08             	mov    0x8(%ebp),%eax
801080dd:	89 04 24             	mov    %eax,(%esp)
801080e0:	e8 a7 fb ff ff       	call   80107c8c <walkpgdir>
801080e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
801080e8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801080ec:	75 0c                	jne    801080fa <loaduvm+0x5f>
      panic("loaduvm: address should exist");
801080ee:	c7 04 24 c3 8d 10 80 	movl   $0x80108dc3,(%esp)
801080f5:	e8 e8 85 ff ff       	call   801006e2 <panic>
    pa = PTE_ADDR(*pte);
801080fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080fd:	8b 00                	mov    (%eax),%eax
801080ff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108104:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108107:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010810a:	8b 55 18             	mov    0x18(%ebp),%edx
8010810d:	29 c2                	sub    %eax,%edx
8010810f:	89 d0                	mov    %edx,%eax
80108111:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108116:	77 0f                	ja     80108127 <loaduvm+0x8c>
      n = sz - i;
80108118:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010811b:	8b 55 18             	mov    0x18(%ebp),%edx
8010811e:	29 c2                	sub    %eax,%edx
80108120:	89 d0                	mov    %edx,%eax
80108122:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108125:	eb 07                	jmp    8010812e <loaduvm+0x93>
    else
      n = PGSIZE;
80108127:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
8010812e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108131:	8b 55 14             	mov    0x14(%ebp),%edx
80108134:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108137:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010813a:	89 04 24             	mov    %eax,(%esp)
8010813d:	e8 8b f6 ff ff       	call   801077cd <p2v>
80108142:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108145:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108149:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010814d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108151:	8b 45 10             	mov    0x10(%ebp),%eax
80108154:	89 04 24             	mov    %eax,(%esp)
80108157:	e8 e6 9d ff ff       	call   80101f42 <readi>
8010815c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010815f:	74 07                	je     80108168 <loaduvm+0xcd>
      return -1;
80108161:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108166:	eb 18                	jmp    80108180 <loaduvm+0xe5>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108168:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010816f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108172:	3b 45 18             	cmp    0x18(%ebp),%eax
80108175:	0f 82 4b ff ff ff    	jb     801080c6 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010817b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108180:	83 c4 24             	add    $0x24,%esp
80108183:	5b                   	pop    %ebx
80108184:	5d                   	pop    %ebp
80108185:	c3                   	ret    

80108186 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108186:	55                   	push   %ebp
80108187:	89 e5                	mov    %esp,%ebp
80108189:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010818c:	8b 45 10             	mov    0x10(%ebp),%eax
8010818f:	85 c0                	test   %eax,%eax
80108191:	79 0a                	jns    8010819d <allocuvm+0x17>
    return 0;
80108193:	b8 00 00 00 00       	mov    $0x0,%eax
80108198:	e9 c1 00 00 00       	jmp    8010825e <allocuvm+0xd8>
  if(newsz < oldsz)
8010819d:	8b 45 10             	mov    0x10(%ebp),%eax
801081a0:	3b 45 0c             	cmp    0xc(%ebp),%eax
801081a3:	73 08                	jae    801081ad <allocuvm+0x27>
    return oldsz;
801081a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801081a8:	e9 b1 00 00 00       	jmp    8010825e <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
801081ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801081b0:	05 ff 0f 00 00       	add    $0xfff,%eax
801081b5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801081bd:	e9 8d 00 00 00       	jmp    8010824f <allocuvm+0xc9>
    mem = kalloc();
801081c2:	e8 f5 aa ff ff       	call   80102cbc <kalloc>
801081c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801081ca:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801081ce:	75 2c                	jne    801081fc <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
801081d0:	c7 04 24 e1 8d 10 80 	movl   $0x80108de1,(%esp)
801081d7:	e8 c4 81 ff ff       	call   801003a0 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801081dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801081df:	89 44 24 08          	mov    %eax,0x8(%esp)
801081e3:	8b 45 10             	mov    0x10(%ebp),%eax
801081e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801081ea:	8b 45 08             	mov    0x8(%ebp),%eax
801081ed:	89 04 24             	mov    %eax,(%esp)
801081f0:	e8 6b 00 00 00       	call   80108260 <deallocuvm>
      return 0;
801081f5:	b8 00 00 00 00       	mov    $0x0,%eax
801081fa:	eb 62                	jmp    8010825e <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
801081fc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108203:	00 
80108204:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010820b:	00 
8010820c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010820f:	89 04 24             	mov    %eax,(%esp)
80108212:	e8 4e d0 ff ff       	call   80105265 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108217:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010821a:	89 04 24             	mov    %eax,(%esp)
8010821d:	e8 9e f5 ff ff       	call   801077c0 <v2p>
80108222:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108225:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010822c:	00 
8010822d:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108231:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108238:	00 
80108239:	89 54 24 04          	mov    %edx,0x4(%esp)
8010823d:	8b 45 08             	mov    0x8(%ebp),%eax
80108240:	89 04 24             	mov    %eax,(%esp)
80108243:	e8 e6 fa ff ff       	call   80107d2e <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108248:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010824f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108252:	3b 45 10             	cmp    0x10(%ebp),%eax
80108255:	0f 82 67 ff ff ff    	jb     801081c2 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
8010825b:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010825e:	c9                   	leave  
8010825f:	c3                   	ret    

80108260 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108260:	55                   	push   %ebp
80108261:	89 e5                	mov    %esp,%ebp
80108263:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108266:	8b 45 10             	mov    0x10(%ebp),%eax
80108269:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010826c:	72 08                	jb     80108276 <deallocuvm+0x16>
    return oldsz;
8010826e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108271:	e9 a4 00 00 00       	jmp    8010831a <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80108276:	8b 45 10             	mov    0x10(%ebp),%eax
80108279:	05 ff 0f 00 00       	add    $0xfff,%eax
8010827e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108283:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108286:	e9 80 00 00 00       	jmp    8010830b <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010828b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010828e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108295:	00 
80108296:	89 44 24 04          	mov    %eax,0x4(%esp)
8010829a:	8b 45 08             	mov    0x8(%ebp),%eax
8010829d:	89 04 24             	mov    %eax,(%esp)
801082a0:	e8 e7 f9 ff ff       	call   80107c8c <walkpgdir>
801082a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801082a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801082ac:	75 09                	jne    801082b7 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
801082ae:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801082b5:	eb 4d                	jmp    80108304 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
801082b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082ba:	8b 00                	mov    (%eax),%eax
801082bc:	83 e0 01             	and    $0x1,%eax
801082bf:	85 c0                	test   %eax,%eax
801082c1:	74 41                	je     80108304 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
801082c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082c6:	8b 00                	mov    (%eax),%eax
801082c8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801082d0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801082d4:	75 0c                	jne    801082e2 <deallocuvm+0x82>
        panic("kfree");
801082d6:	c7 04 24 f9 8d 10 80 	movl   $0x80108df9,(%esp)
801082dd:	e8 00 84 ff ff       	call   801006e2 <panic>
      char *v = p2v(pa);
801082e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082e5:	89 04 24             	mov    %eax,(%esp)
801082e8:	e8 e0 f4 ff ff       	call   801077cd <p2v>
801082ed:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801082f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082f3:	89 04 24             	mov    %eax,(%esp)
801082f6:	e8 28 a9 ff ff       	call   80102c23 <kfree>
      *pte = 0;
801082fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082fe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108304:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010830b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010830e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108311:	0f 82 74 ff ff ff    	jb     8010828b <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108317:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010831a:	c9                   	leave  
8010831b:	c3                   	ret    

8010831c <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010831c:	55                   	push   %ebp
8010831d:	89 e5                	mov    %esp,%ebp
8010831f:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108322:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108326:	75 0c                	jne    80108334 <freevm+0x18>
    panic("freevm: no pgdir");
80108328:	c7 04 24 ff 8d 10 80 	movl   $0x80108dff,(%esp)
8010832f:	e8 ae 83 ff ff       	call   801006e2 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108334:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010833b:	00 
8010833c:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108343:	80 
80108344:	8b 45 08             	mov    0x8(%ebp),%eax
80108347:	89 04 24             	mov    %eax,(%esp)
8010834a:	e8 11 ff ff ff       	call   80108260 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
8010834f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108356:	eb 48                	jmp    801083a0 <freevm+0x84>
    if(pgdir[i] & PTE_P){
80108358:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010835b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108362:	8b 45 08             	mov    0x8(%ebp),%eax
80108365:	01 d0                	add    %edx,%eax
80108367:	8b 00                	mov    (%eax),%eax
80108369:	83 e0 01             	and    $0x1,%eax
8010836c:	85 c0                	test   %eax,%eax
8010836e:	74 2c                	je     8010839c <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108370:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108373:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010837a:	8b 45 08             	mov    0x8(%ebp),%eax
8010837d:	01 d0                	add    %edx,%eax
8010837f:	8b 00                	mov    (%eax),%eax
80108381:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108386:	89 04 24             	mov    %eax,(%esp)
80108389:	e8 3f f4 ff ff       	call   801077cd <p2v>
8010838e:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108391:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108394:	89 04 24             	mov    %eax,(%esp)
80108397:	e8 87 a8 ff ff       	call   80102c23 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010839c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801083a0:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801083a7:	76 af                	jbe    80108358 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801083a9:	8b 45 08             	mov    0x8(%ebp),%eax
801083ac:	89 04 24             	mov    %eax,(%esp)
801083af:	e8 6f a8 ff ff       	call   80102c23 <kfree>
}
801083b4:	c9                   	leave  
801083b5:	c3                   	ret    

801083b6 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801083b6:	55                   	push   %ebp
801083b7:	89 e5                	mov    %esp,%ebp
801083b9:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801083bc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801083c3:	00 
801083c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801083c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801083cb:	8b 45 08             	mov    0x8(%ebp),%eax
801083ce:	89 04 24             	mov    %eax,(%esp)
801083d1:	e8 b6 f8 ff ff       	call   80107c8c <walkpgdir>
801083d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801083d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801083dd:	75 0c                	jne    801083eb <clearpteu+0x35>
    panic("clearpteu");
801083df:	c7 04 24 10 8e 10 80 	movl   $0x80108e10,(%esp)
801083e6:	e8 f7 82 ff ff       	call   801006e2 <panic>
  *pte &= ~PTE_U;
801083eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ee:	8b 00                	mov    (%eax),%eax
801083f0:	83 e0 fb             	and    $0xfffffffb,%eax
801083f3:	89 c2                	mov    %eax,%edx
801083f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f8:	89 10                	mov    %edx,(%eax)
}
801083fa:	c9                   	leave  
801083fb:	c3                   	ret    

801083fc <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801083fc:	55                   	push   %ebp
801083fd:	89 e5                	mov    %esp,%ebp
801083ff:	53                   	push   %ebx
80108400:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108403:	e8 be f9 ff ff       	call   80107dc6 <setupkvm>
80108408:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010840b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010840f:	75 0a                	jne    8010841b <copyuvm+0x1f>
    return 0;
80108411:	b8 00 00 00 00       	mov    $0x0,%eax
80108416:	e9 fd 00 00 00       	jmp    80108518 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
8010841b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108422:	e9 d0 00 00 00       	jmp    801084f7 <copyuvm+0xfb>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108427:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010842a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108431:	00 
80108432:	89 44 24 04          	mov    %eax,0x4(%esp)
80108436:	8b 45 08             	mov    0x8(%ebp),%eax
80108439:	89 04 24             	mov    %eax,(%esp)
8010843c:	e8 4b f8 ff ff       	call   80107c8c <walkpgdir>
80108441:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108444:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108448:	75 0c                	jne    80108456 <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
8010844a:	c7 04 24 1a 8e 10 80 	movl   $0x80108e1a,(%esp)
80108451:	e8 8c 82 ff ff       	call   801006e2 <panic>
    if(!(*pte & PTE_P))
80108456:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108459:	8b 00                	mov    (%eax),%eax
8010845b:	83 e0 01             	and    $0x1,%eax
8010845e:	85 c0                	test   %eax,%eax
80108460:	75 0c                	jne    8010846e <copyuvm+0x72>
      panic("copyuvm: page not present");
80108462:	c7 04 24 34 8e 10 80 	movl   $0x80108e34,(%esp)
80108469:	e8 74 82 ff ff       	call   801006e2 <panic>
    pa = PTE_ADDR(*pte);
8010846e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108471:	8b 00                	mov    (%eax),%eax
80108473:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108478:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010847b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010847e:	8b 00                	mov    (%eax),%eax
80108480:	25 ff 0f 00 00       	and    $0xfff,%eax
80108485:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108488:	e8 2f a8 ff ff       	call   80102cbc <kalloc>
8010848d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108490:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108494:	75 02                	jne    80108498 <copyuvm+0x9c>
      goto bad;
80108496:	eb 70                	jmp    80108508 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108498:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010849b:	89 04 24             	mov    %eax,(%esp)
8010849e:	e8 2a f3 ff ff       	call   801077cd <p2v>
801084a3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801084aa:	00 
801084ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801084af:	8b 45 e0             	mov    -0x20(%ebp),%eax
801084b2:	89 04 24             	mov    %eax,(%esp)
801084b5:	e8 7a ce ff ff       	call   80105334 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
801084ba:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801084bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801084c0:	89 04 24             	mov    %eax,(%esp)
801084c3:	e8 f8 f2 ff ff       	call   801077c0 <v2p>
801084c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084cb:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801084cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
801084d3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801084da:	00 
801084db:	89 54 24 04          	mov    %edx,0x4(%esp)
801084df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084e2:	89 04 24             	mov    %eax,(%esp)
801084e5:	e8 44 f8 ff ff       	call   80107d2e <mappages>
801084ea:	85 c0                	test   %eax,%eax
801084ec:	79 02                	jns    801084f0 <copyuvm+0xf4>
      goto bad;
801084ee:	eb 18                	jmp    80108508 <copyuvm+0x10c>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801084f0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801084f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084fa:	3b 45 0c             	cmp    0xc(%ebp),%eax
801084fd:	0f 82 24 ff ff ff    	jb     80108427 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108503:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108506:	eb 10                	jmp    80108518 <copyuvm+0x11c>

bad:
  freevm(d);
80108508:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010850b:	89 04 24             	mov    %eax,(%esp)
8010850e:	e8 09 fe ff ff       	call   8010831c <freevm>
  return 0;
80108513:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108518:	83 c4 44             	add    $0x44,%esp
8010851b:	5b                   	pop    %ebx
8010851c:	5d                   	pop    %ebp
8010851d:	c3                   	ret    

8010851e <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010851e:	55                   	push   %ebp
8010851f:	89 e5                	mov    %esp,%ebp
80108521:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108524:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010852b:	00 
8010852c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010852f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108533:	8b 45 08             	mov    0x8(%ebp),%eax
80108536:	89 04 24             	mov    %eax,(%esp)
80108539:	e8 4e f7 ff ff       	call   80107c8c <walkpgdir>
8010853e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108544:	8b 00                	mov    (%eax),%eax
80108546:	83 e0 01             	and    $0x1,%eax
80108549:	85 c0                	test   %eax,%eax
8010854b:	75 07                	jne    80108554 <uva2ka+0x36>
    return 0;
8010854d:	b8 00 00 00 00       	mov    $0x0,%eax
80108552:	eb 25                	jmp    80108579 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108557:	8b 00                	mov    (%eax),%eax
80108559:	83 e0 04             	and    $0x4,%eax
8010855c:	85 c0                	test   %eax,%eax
8010855e:	75 07                	jne    80108567 <uva2ka+0x49>
    return 0;
80108560:	b8 00 00 00 00       	mov    $0x0,%eax
80108565:	eb 12                	jmp    80108579 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108567:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010856a:	8b 00                	mov    (%eax),%eax
8010856c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108571:	89 04 24             	mov    %eax,(%esp)
80108574:	e8 54 f2 ff ff       	call   801077cd <p2v>
}
80108579:	c9                   	leave  
8010857a:	c3                   	ret    

8010857b <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010857b:	55                   	push   %ebp
8010857c:	89 e5                	mov    %esp,%ebp
8010857e:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108581:	8b 45 10             	mov    0x10(%ebp),%eax
80108584:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108587:	e9 87 00 00 00       	jmp    80108613 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
8010858c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010858f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108594:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108597:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010859a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010859e:	8b 45 08             	mov    0x8(%ebp),%eax
801085a1:	89 04 24             	mov    %eax,(%esp)
801085a4:	e8 75 ff ff ff       	call   8010851e <uva2ka>
801085a9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801085ac:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801085b0:	75 07                	jne    801085b9 <copyout+0x3e>
      return -1;
801085b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801085b7:	eb 69                	jmp    80108622 <copyout+0xa7>
    n = PGSIZE - (va - va0);
801085b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801085bc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801085bf:	29 c2                	sub    %eax,%edx
801085c1:	89 d0                	mov    %edx,%eax
801085c3:	05 00 10 00 00       	add    $0x1000,%eax
801085c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801085cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085ce:	3b 45 14             	cmp    0x14(%ebp),%eax
801085d1:	76 06                	jbe    801085d9 <copyout+0x5e>
      n = len;
801085d3:	8b 45 14             	mov    0x14(%ebp),%eax
801085d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801085d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085dc:	8b 55 0c             	mov    0xc(%ebp),%edx
801085df:	29 c2                	sub    %eax,%edx
801085e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801085e4:	01 c2                	add    %eax,%edx
801085e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085e9:	89 44 24 08          	mov    %eax,0x8(%esp)
801085ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801085f4:	89 14 24             	mov    %edx,(%esp)
801085f7:	e8 38 cd ff ff       	call   80105334 <memmove>
    len -= n;
801085fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085ff:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108602:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108605:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108608:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010860b:	05 00 10 00 00       	add    $0x1000,%eax
80108610:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108613:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108617:	0f 85 6f ff ff ff    	jne    8010858c <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010861d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108622:	c9                   	leave  
80108623:	c3                   	ret    

80108624 <insertVa2TLB>:
// Blank page.
//PAGEBREAK!
// Blank page.


int insertVa2TLB(uint va){
80108624:	55                   	push   %ebp
80108625:	89 e5                	mov    %esp,%ebp
80108627:	53                   	push   %ebx
80108628:	83 ec 24             	sub    $0x24,%esp


	if(va < KERNBASE){
8010862b:	8b 45 08             	mov    0x8(%ebp),%eax
8010862e:	85 c0                	test   %eax,%eax
80108630:	0f 88 f3 00 00 00    	js     80108729 <insertVa2TLB+0x105>

		cpu->TLBindex= 	(cpu->TLBindex+1) %TLB_SZ;
80108636:	65 8b 0d 00 00 00 00 	mov    %gs:0x0,%ecx
8010863d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108643:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
80108649:	8d 50 01             	lea    0x1(%eax),%edx
8010864c:	89 d0                	mov    %edx,%eax
8010864e:	c1 f8 1f             	sar    $0x1f,%eax
80108651:	c1 e8 1f             	shr    $0x1f,%eax
80108654:	01 c2                	add    %eax,%edx
80108656:	83 e2 01             	and    $0x1,%edx
80108659:	29 c2                	sub    %eax,%edx
8010865b:	89 d0                	mov    %edx,%eax
8010865d:	89 81 c8 00 00 00    	mov    %eax,0xc8(%ecx)
//	p(" cpu->TLBindex %p ********* %p \n", cpu->TLBindex,cpu->TLB[ cpu->TLBindex]);
	if (cpu->TLB[ cpu->TLBindex])
80108663:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108669:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108670:	8b 92 c8 00 00 00    	mov    0xc8(%edx),%edx
80108676:	83 c2 30             	add    $0x30,%edx
80108679:	8b 04 90             	mov    (%eax,%edx,4),%eax
8010867c:	85 c0                	test   %eax,%eax
8010867e:	74 1f                	je     8010869f <insertVa2TLB+0x7b>
		   *cpu->TLB[ cpu->TLBindex ]=0;
80108680:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108686:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010868d:	8b 92 c8 00 00 00    	mov    0xc8(%edx),%edx
80108693:	83 c2 30             	add    $0x30,%edx
80108696:	8b 04 90             	mov    (%eax,%edx,4),%eax
80108699:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  	pte_t *pte  = walkpgdir(proc->pgdir,(void*) va ,1);
8010869f:	8b 55 08             	mov    0x8(%ebp),%edx
801086a2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801086a8:	8b 40 04             	mov    0x4(%eax),%eax
801086ab:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
801086b2:	00 
801086b3:	89 54 24 04          	mov    %edx,0x4(%esp)
801086b7:	89 04 24             	mov    %eax,(%esp)
801086ba:	e8 cd f5 ff ff       	call   80107c8c <walkpgdir>
801086bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  	pde_t *kpde = &cpu->kpgdir[PDX(va)];
801086c2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801086c8:	8b 40 04             	mov    0x4(%eax),%eax
801086cb:	8b 55 08             	mov    0x8(%ebp),%edx
801086ce:	c1 ea 16             	shr    $0x16,%edx
801086d1:	c1 e2 02             	shl    $0x2,%edx
801086d4:	01 d0                	add    %edx,%eax
801086d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
     uint  flags = PTE_FLAGS(*pte);
801086d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086dc:	8b 00                	mov    (%eax),%eax
801086de:	25 ff 0f 00 00       	and    $0xfff,%eax
801086e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  	*kpde = v2p(pte) | flags;
801086e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e9:	89 04 24             	mov    %eax,(%esp)
801086ec:	e8 cf f0 ff ff       	call   801077c0 <v2p>
801086f1:	0b 45 ec             	or     -0x14(%ebp),%eax
801086f4:	89 c2                	mov    %eax,%edx
801086f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086f9:	89 10                	mov    %edx,(%eax)

	cpu->TLB[cpu->TLBindex]=&cpu->kpgdir[PDX(va)];
801086fb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108701:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108708:	8b 9a c8 00 00 00    	mov    0xc8(%edx),%ebx
8010870e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108715:	8b 52 04             	mov    0x4(%edx),%edx
80108718:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010871b:	c1 e9 16             	shr    $0x16,%ecx
8010871e:	c1 e1 02             	shl    $0x2,%ecx
80108721:	01 d1                	add    %edx,%ecx
80108723:	8d 53 30             	lea    0x30(%ebx),%edx
80108726:	89 0c 90             	mov    %ecx,(%eax,%edx,4)


	}
 	return 0;
80108729:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010872e:	83 c4 24             	add    $0x24,%esp
80108731:	5b                   	pop    %ebx
80108732:	5d                   	pop    %ebp
80108733:	c3                   	ret    

80108734 <flushTLB>:

void flushTLB(){
80108734:	55                   	push   %ebp
80108735:	89 e5                	mov    %esp,%ebp
80108737:	83 ec 10             	sub    $0x10,%esp


		cpu->TLBindex=0;
8010873a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108740:	c7 80 c8 00 00 00 00 	movl   $0x0,0xc8(%eax)
80108747:	00 00 00 
	 //  memset(cpu->kpgdir,0, PGSIZE/2);

	   int i;
	   for ( i=0; i<TLB_SZ; i++)
8010874a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80108751:	eb 29                	jmp    8010877c <flushTLB+0x48>
		   if (cpu->TLB[i])
80108753:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108759:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010875c:	83 c2 30             	add    $0x30,%edx
8010875f:	8b 04 90             	mov    (%eax,%edx,4),%eax
80108762:	85 c0                	test   %eax,%eax
80108764:	74 12                	je     80108778 <flushTLB+0x44>
			   	   *cpu->TLB[1]=0;
80108766:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010876c:	8b 80 c4 00 00 00    	mov    0xc4(%eax),%eax
80108772:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

		cpu->TLBindex=0;
	 //  memset(cpu->kpgdir,0, PGSIZE/2);

	   int i;
	   for ( i=0; i<TLB_SZ; i++)
80108778:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010877c:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80108780:	7e d1                	jle    80108753 <flushTLB+0x1f>
		   if (cpu->TLB[i])
			   	   *cpu->TLB[1]=0;

}
80108782:	c9                   	leave  
80108783:	c3                   	ret    
