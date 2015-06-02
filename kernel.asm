
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
8010002d:	b8 17 37 10 80       	mov    $0x80103717,%eax
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
8010003a:	c7 44 24 04 a4 86 10 	movl   $0x801086a4,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 a2 4d 00 00       	call   80104df0 <initlock>

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
801000bd:	e8 4f 4d 00 00       	call   80104e11 <acquire>

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
80100104:	e8 6a 4d 00 00       	call   80104e73 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 23 4a 00 00       	call   80104b47 <sleep>
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
8010017c:	e8 f2 4c 00 00       	call   80104e73 <release>
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
80100198:	c7 04 24 ab 86 10 80 	movl   $0x801086ab,(%esp)
8010019f:	e8 96 03 00 00       	call   8010053a <panic>
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
801001d3:	e8 c9 25 00 00       	call   801027a1 <iderw>
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
801001ef:	c7 04 24 bc 86 10 80 	movl   $0x801086bc,(%esp)
801001f6:	e8 3f 03 00 00       	call   8010053a <panic>
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
80100210:	e8 8c 25 00 00       	call   801027a1 <iderw>
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
80100229:	c7 04 24 c3 86 10 80 	movl   $0x801086c3,(%esp)
80100230:	e8 05 03 00 00       	call   8010053a <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010023c:	e8 d0 4b 00 00       	call   80104e11 <acquire>

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
8010029d:	e8 7e 49 00 00       	call   80104c20 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002a9:	e8 c5 4b 00 00       	call   80104e73 <release>
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
80100340:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
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
8010038a:	e8 c1 03 00 00       	call   80100750 <consputc>
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
801003bb:	e8 51 4a 00 00       	call   80104e11 <acquire>

  if (fmt == 0)
801003c0:	8b 45 08             	mov    0x8(%ebp),%eax
801003c3:	85 c0                	test   %eax,%eax
801003c5:	75 0c                	jne    801003d3 <cprintf+0x33>
    panic("null fmt");
801003c7:	c7 04 24 ca 86 10 80 	movl   $0x801086ca,(%esp)
801003ce:	e8 67 01 00 00       	call   8010053a <panic>

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
801003f1:	e8 5a 03 00 00       	call   80100750 <consputc>
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
801004b0:	c7 45 ec d3 86 10 80 	movl   $0x801086d3,-0x14(%ebp)
      for(; *s; s++)
801004b7:	eb 17                	jmp    801004d0 <cprintf+0x130>
801004b9:	eb 15                	jmp    801004d0 <cprintf+0x130>
        consputc(*s);
801004bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004be:	0f b6 00             	movzbl (%eax),%eax
801004c1:	0f be c0             	movsbl %al,%eax
801004c4:	89 04 24             	mov    %eax,(%esp)
801004c7:	e8 84 02 00 00       	call   80100750 <consputc>
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
801004e3:	e8 68 02 00 00       	call   80100750 <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x162>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 5a 02 00 00       	call   80100750 <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 4f 02 00 00       	call   80100750 <consputc>
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
80100533:	e8 3b 49 00 00       	call   80104e73 <release>
}
80100538:	c9                   	leave  
80100539:	c3                   	ret    

8010053a <panic>:

void
panic(char *s)
{
8010053a:	55                   	push   %ebp
8010053b:	89 e5                	mov    %esp,%ebp
8010053d:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
80100540:	e8 a6 fd ff ff       	call   801002eb <cli>
  cons.locking = 0;
80100545:	c7 05 f4 b5 10 80 00 	movl   $0x0,0x8010b5f4
8010054c:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010054f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100555:	0f b6 00             	movzbl (%eax),%eax
80100558:	0f b6 c0             	movzbl %al,%eax
8010055b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010055f:	c7 04 24 da 86 10 80 	movl   $0x801086da,(%esp)
80100566:	e8 35 fe ff ff       	call   801003a0 <cprintf>
  cprintf(s);
8010056b:	8b 45 08             	mov    0x8(%ebp),%eax
8010056e:	89 04 24             	mov    %eax,(%esp)
80100571:	e8 2a fe ff ff       	call   801003a0 <cprintf>
  cprintf("\n");
80100576:	c7 04 24 e9 86 10 80 	movl   $0x801086e9,(%esp)
8010057d:	e8 1e fe ff ff       	call   801003a0 <cprintf>
  getcallerpcs(&s, pcs);
80100582:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100585:	89 44 24 04          	mov    %eax,0x4(%esp)
80100589:	8d 45 08             	lea    0x8(%ebp),%eax
8010058c:	89 04 24             	mov    %eax,(%esp)
8010058f:	e8 2e 49 00 00       	call   80104ec2 <getcallerpcs>
  for(i=0; i<10; i++)
80100594:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059b:	eb 1b                	jmp    801005b8 <panic+0x7e>
    cprintf(" %p", pcs[i]);
8010059d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a0:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801005a8:	c7 04 24 eb 86 10 80 	movl   $0x801086eb,(%esp)
801005af:	e8 ec fd ff ff       	call   801003a0 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005b8:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bc:	7e df                	jle    8010059d <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005be:	c7 05 a0 b5 10 80 01 	movl   $0x1,0x8010b5a0
801005c5:	00 00 00 
  for(;;)
    ;
801005c8:	eb fe                	jmp    801005c8 <panic+0x8e>

801005ca <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005ca:	55                   	push   %ebp
801005cb:	89 e5                	mov    %esp,%ebp
801005cd:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005d0:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005d7:	00 
801005d8:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005df:	e8 e9 fc ff ff       	call   801002cd <outb>
  pos = inb(CRTPORT+1) << 8;
801005e4:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005eb:	e8 c0 fc ff ff       	call   801002b0 <inb>
801005f0:	0f b6 c0             	movzbl %al,%eax
801005f3:	c1 e0 08             	shl    $0x8,%eax
801005f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801005f9:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100600:	00 
80100601:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100608:	e8 c0 fc ff ff       	call   801002cd <outb>
  pos |= inb(CRTPORT+1);
8010060d:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100614:	e8 97 fc ff ff       	call   801002b0 <inb>
80100619:	0f b6 c0             	movzbl %al,%eax
8010061c:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010061f:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100623:	75 30                	jne    80100655 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100625:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100628:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010062d:	89 c8                	mov    %ecx,%eax
8010062f:	f7 ea                	imul   %edx
80100631:	c1 fa 05             	sar    $0x5,%edx
80100634:	89 c8                	mov    %ecx,%eax
80100636:	c1 f8 1f             	sar    $0x1f,%eax
80100639:	29 c2                	sub    %eax,%edx
8010063b:	89 d0                	mov    %edx,%eax
8010063d:	c1 e0 02             	shl    $0x2,%eax
80100640:	01 d0                	add    %edx,%eax
80100642:	c1 e0 04             	shl    $0x4,%eax
80100645:	29 c1                	sub    %eax,%ecx
80100647:	89 ca                	mov    %ecx,%edx
80100649:	b8 50 00 00 00       	mov    $0x50,%eax
8010064e:	29 d0                	sub    %edx,%eax
80100650:	01 45 f4             	add    %eax,-0xc(%ebp)
80100653:	eb 35                	jmp    8010068a <cgaputc+0xc0>
  else if(c == BACKSPACE){
80100655:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065c:	75 0c                	jne    8010066a <cgaputc+0xa0>
    if(pos > 0) --pos;
8010065e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100662:	7e 26                	jle    8010068a <cgaputc+0xc0>
80100664:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100668:	eb 20                	jmp    8010068a <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010066a:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
80100670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100673:	8d 50 01             	lea    0x1(%eax),%edx
80100676:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100679:	01 c0                	add    %eax,%eax
8010067b:	8d 14 01             	lea    (%ecx,%eax,1),%edx
8010067e:	8b 45 08             	mov    0x8(%ebp),%eax
80100681:	0f b6 c0             	movzbl %al,%eax
80100684:	80 cc 07             	or     $0x7,%ah
80100687:	66 89 02             	mov    %ax,(%edx)
  
  if((pos/80) >= 24){  // Scroll up.
8010068a:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100691:	7e 53                	jle    801006e6 <cgaputc+0x11c>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100693:	a1 00 90 10 80       	mov    0x80109000,%eax
80100698:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
8010069e:	a1 00 90 10 80       	mov    0x80109000,%eax
801006a3:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006aa:	00 
801006ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801006af:	89 04 24             	mov    %eax,(%esp)
801006b2:	e8 7d 4a 00 00       	call   80105134 <memmove>
    pos -= 80;
801006b7:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006bb:	b8 80 07 00 00       	mov    $0x780,%eax
801006c0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006c3:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006c6:	a1 00 90 10 80       	mov    0x80109000,%eax
801006cb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006ce:	01 c9                	add    %ecx,%ecx
801006d0:	01 c8                	add    %ecx,%eax
801006d2:	89 54 24 08          	mov    %edx,0x8(%esp)
801006d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006dd:	00 
801006de:	89 04 24             	mov    %eax,(%esp)
801006e1:	e8 7f 49 00 00       	call   80105065 <memset>
  }
  
  outb(CRTPORT, 14);
801006e6:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801006ed:	00 
801006ee:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801006f5:	e8 d3 fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos>>8);
801006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006fd:	c1 f8 08             	sar    $0x8,%eax
80100700:	0f b6 c0             	movzbl %al,%eax
80100703:	89 44 24 04          	mov    %eax,0x4(%esp)
80100707:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010070e:	e8 ba fb ff ff       	call   801002cd <outb>
  outb(CRTPORT, 15);
80100713:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010071a:	00 
8010071b:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100722:	e8 a6 fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos);
80100727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010072a:	0f b6 c0             	movzbl %al,%eax
8010072d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100731:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100738:	e8 90 fb ff ff       	call   801002cd <outb>
  crt[pos] = ' ' | 0x0700;
8010073d:	a1 00 90 10 80       	mov    0x80109000,%eax
80100742:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100745:	01 d2                	add    %edx,%edx
80100747:	01 d0                	add    %edx,%eax
80100749:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010074e:	c9                   	leave  
8010074f:	c3                   	ret    

80100750 <consputc>:

void
consputc(int c)
{
80100750:	55                   	push   %ebp
80100751:	89 e5                	mov    %esp,%ebp
80100753:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100756:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
8010075b:	85 c0                	test   %eax,%eax
8010075d:	74 07                	je     80100766 <consputc+0x16>
    cli();
8010075f:	e8 87 fb ff ff       	call   801002eb <cli>
    for(;;)
      ;
80100764:	eb fe                	jmp    80100764 <consputc+0x14>
  }

  if(c == BACKSPACE){
80100766:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010076d:	75 26                	jne    80100795 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010076f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100776:	e8 c8 62 00 00       	call   80106a43 <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 bc 62 00 00       	call   80106a43 <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 b0 62 00 00       	call   80106a43 <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 a3 62 00 00       	call   80106a43 <uartputc>
  cgaputc(c);
801007a0:	8b 45 08             	mov    0x8(%ebp),%eax
801007a3:	89 04 24             	mov    %eax,(%esp)
801007a6:	e8 1f fe ff ff       	call   801005ca <cgaputc>
}
801007ab:	c9                   	leave  
801007ac:	c3                   	ret    

801007ad <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007ad:	55                   	push   %ebp
801007ae:	89 e5                	mov    %esp,%ebp
801007b0:	83 ec 28             	sub    $0x28,%esp
  int c;

  acquire(&input.lock);
801007b3:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
801007ba:	e8 52 46 00 00       	call   80104e11 <acquire>
  while((c = getc()) >= 0){
801007bf:	e9 37 01 00 00       	jmp    801008fb <consoleintr+0x14e>
    switch(c){
801007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007c7:	83 f8 10             	cmp    $0x10,%eax
801007ca:	74 1e                	je     801007ea <consoleintr+0x3d>
801007cc:	83 f8 10             	cmp    $0x10,%eax
801007cf:	7f 0a                	jg     801007db <consoleintr+0x2e>
801007d1:	83 f8 08             	cmp    $0x8,%eax
801007d4:	74 64                	je     8010083a <consoleintr+0x8d>
801007d6:	e9 91 00 00 00       	jmp    8010086c <consoleintr+0xbf>
801007db:	83 f8 15             	cmp    $0x15,%eax
801007de:	74 2f                	je     8010080f <consoleintr+0x62>
801007e0:	83 f8 7f             	cmp    $0x7f,%eax
801007e3:	74 55                	je     8010083a <consoleintr+0x8d>
801007e5:	e9 82 00 00 00       	jmp    8010086c <consoleintr+0xbf>
    case C('P'):  // Process listing.
      procdump();
801007ea:	e8 d4 44 00 00       	call   80104cc3 <procdump>
      break;
801007ef:	e9 07 01 00 00       	jmp    801008fb <consoleintr+0x14e>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801007f4:	a1 3c 08 11 80       	mov    0x8011083c,%eax
801007f9:	83 e8 01             	sub    $0x1,%eax
801007fc:	a3 3c 08 11 80       	mov    %eax,0x8011083c
        consputc(BACKSPACE);
80100801:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100808:	e8 43 ff ff ff       	call   80100750 <consputc>
8010080d:	eb 01                	jmp    80100810 <consoleintr+0x63>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010080f:	90                   	nop
80100810:	8b 15 3c 08 11 80    	mov    0x8011083c,%edx
80100816:	a1 38 08 11 80       	mov    0x80110838,%eax
8010081b:	39 c2                	cmp    %eax,%edx
8010081d:	74 16                	je     80100835 <consoleintr+0x88>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010081f:	a1 3c 08 11 80       	mov    0x8011083c,%eax
80100824:	83 e8 01             	sub    $0x1,%eax
80100827:	83 e0 7f             	and    $0x7f,%eax
8010082a:	0f b6 80 b4 07 11 80 	movzbl -0x7feef84c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100831:	3c 0a                	cmp    $0xa,%al
80100833:	75 bf                	jne    801007f4 <consoleintr+0x47>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100835:	e9 c1 00 00 00       	jmp    801008fb <consoleintr+0x14e>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010083a:	8b 15 3c 08 11 80    	mov    0x8011083c,%edx
80100840:	a1 38 08 11 80       	mov    0x80110838,%eax
80100845:	39 c2                	cmp    %eax,%edx
80100847:	74 1e                	je     80100867 <consoleintr+0xba>
        input.e--;
80100849:	a1 3c 08 11 80       	mov    0x8011083c,%eax
8010084e:	83 e8 01             	sub    $0x1,%eax
80100851:	a3 3c 08 11 80       	mov    %eax,0x8011083c
        consputc(BACKSPACE);
80100856:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010085d:	e8 ee fe ff ff       	call   80100750 <consputc>
      }
      break;
80100862:	e9 94 00 00 00       	jmp    801008fb <consoleintr+0x14e>
80100867:	e9 8f 00 00 00       	jmp    801008fb <consoleintr+0x14e>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010086c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100870:	0f 84 84 00 00 00    	je     801008fa <consoleintr+0x14d>
80100876:	8b 15 3c 08 11 80    	mov    0x8011083c,%edx
8010087c:	a1 34 08 11 80       	mov    0x80110834,%eax
80100881:	29 c2                	sub    %eax,%edx
80100883:	89 d0                	mov    %edx,%eax
80100885:	83 f8 7f             	cmp    $0x7f,%eax
80100888:	77 70                	ja     801008fa <consoleintr+0x14d>
        c = (c == '\r') ? '\n' : c;
8010088a:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
8010088e:	74 05                	je     80100895 <consoleintr+0xe8>
80100890:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100893:	eb 05                	jmp    8010089a <consoleintr+0xed>
80100895:	b8 0a 00 00 00       	mov    $0xa,%eax
8010089a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
8010089d:	a1 3c 08 11 80       	mov    0x8011083c,%eax
801008a2:	8d 50 01             	lea    0x1(%eax),%edx
801008a5:	89 15 3c 08 11 80    	mov    %edx,0x8011083c
801008ab:	83 e0 7f             	and    $0x7f,%eax
801008ae:	89 c2                	mov    %eax,%edx
801008b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008b3:	88 82 b4 07 11 80    	mov    %al,-0x7feef84c(%edx)
        consputc(c);
801008b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008bc:	89 04 24             	mov    %eax,(%esp)
801008bf:	e8 8c fe ff ff       	call   80100750 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008c4:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801008c8:	74 18                	je     801008e2 <consoleintr+0x135>
801008ca:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801008ce:	74 12                	je     801008e2 <consoleintr+0x135>
801008d0:	a1 3c 08 11 80       	mov    0x8011083c,%eax
801008d5:	8b 15 34 08 11 80    	mov    0x80110834,%edx
801008db:	83 ea 80             	sub    $0xffffff80,%edx
801008de:	39 d0                	cmp    %edx,%eax
801008e0:	75 18                	jne    801008fa <consoleintr+0x14d>
          input.w = input.e;
801008e2:	a1 3c 08 11 80       	mov    0x8011083c,%eax
801008e7:	a3 38 08 11 80       	mov    %eax,0x80110838
          wakeup(&input.r);
801008ec:	c7 04 24 34 08 11 80 	movl   $0x80110834,(%esp)
801008f3:	e8 28 43 00 00       	call   80104c20 <wakeup>
        }
      }
      break;
801008f8:	eb 00                	jmp    801008fa <consoleintr+0x14d>
801008fa:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
801008fb:	8b 45 08             	mov    0x8(%ebp),%eax
801008fe:	ff d0                	call   *%eax
80100900:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100903:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100907:	0f 89 b7 fe ff ff    	jns    801007c4 <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
8010090d:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100914:	e8 5a 45 00 00       	call   80104e73 <release>
}
80100919:	c9                   	leave  
8010091a:	c3                   	ret    

8010091b <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010091b:	55                   	push   %ebp
8010091c:	89 e5                	mov    %esp,%ebp
8010091e:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100921:	8b 45 08             	mov    0x8(%ebp),%eax
80100924:	89 04 24             	mov    %eax,(%esp)
80100927:	e8 7d 10 00 00       	call   801019a9 <iunlock>
  target = n;
8010092c:	8b 45 10             	mov    0x10(%ebp),%eax
8010092f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100932:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100939:	e8 d3 44 00 00       	call   80104e11 <acquire>
  while(n > 0){
8010093e:	e9 aa 00 00 00       	jmp    801009ed <consoleread+0xd2>
    while(input.r == input.w){
80100943:	eb 42                	jmp    80100987 <consoleread+0x6c>
      if(proc->killed){
80100945:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010094b:	8b 40 24             	mov    0x24(%eax),%eax
8010094e:	85 c0                	test   %eax,%eax
80100950:	74 21                	je     80100973 <consoleread+0x58>
        release(&input.lock);
80100952:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100959:	e8 15 45 00 00       	call   80104e73 <release>
        ilock(ip);
8010095e:	8b 45 08             	mov    0x8(%ebp),%eax
80100961:	89 04 24             	mov    %eax,(%esp)
80100964:	e8 f2 0e 00 00       	call   8010185b <ilock>
        return -1;
80100969:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010096e:	e9 a5 00 00 00       	jmp    80100a18 <consoleread+0xfd>
      }
      sleep(&input.r, &input.lock);
80100973:	c7 44 24 04 80 07 11 	movl   $0x80110780,0x4(%esp)
8010097a:	80 
8010097b:	c7 04 24 34 08 11 80 	movl   $0x80110834,(%esp)
80100982:	e8 c0 41 00 00       	call   80104b47 <sleep>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100987:	8b 15 34 08 11 80    	mov    0x80110834,%edx
8010098d:	a1 38 08 11 80       	mov    0x80110838,%eax
80100992:	39 c2                	cmp    %eax,%edx
80100994:	74 af                	je     80100945 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100996:	a1 34 08 11 80       	mov    0x80110834,%eax
8010099b:	8d 50 01             	lea    0x1(%eax),%edx
8010099e:	89 15 34 08 11 80    	mov    %edx,0x80110834
801009a4:	83 e0 7f             	and    $0x7f,%eax
801009a7:	0f b6 80 b4 07 11 80 	movzbl -0x7feef84c(%eax),%eax
801009ae:	0f be c0             	movsbl %al,%eax
801009b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
801009b4:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009b8:	75 19                	jne    801009d3 <consoleread+0xb8>
      if(n < target){
801009ba:	8b 45 10             	mov    0x10(%ebp),%eax
801009bd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009c0:	73 0f                	jae    801009d1 <consoleread+0xb6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801009c2:	a1 34 08 11 80       	mov    0x80110834,%eax
801009c7:	83 e8 01             	sub    $0x1,%eax
801009ca:	a3 34 08 11 80       	mov    %eax,0x80110834
      }
      break;
801009cf:	eb 26                	jmp    801009f7 <consoleread+0xdc>
801009d1:	eb 24                	jmp    801009f7 <consoleread+0xdc>
    }
    *dst++ = c;
801009d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801009d6:	8d 50 01             	lea    0x1(%eax),%edx
801009d9:	89 55 0c             	mov    %edx,0xc(%ebp)
801009dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801009df:	88 10                	mov    %dl,(%eax)
    --n;
801009e1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
801009e5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801009e9:	75 02                	jne    801009ed <consoleread+0xd2>
      break;
801009eb:	eb 0a                	jmp    801009f7 <consoleread+0xdc>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
801009ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801009f1:	0f 8f 4c ff ff ff    	jg     80100943 <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&input.lock);
801009f7:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
801009fe:	e8 70 44 00 00       	call   80104e73 <release>
  ilock(ip);
80100a03:	8b 45 08             	mov    0x8(%ebp),%eax
80100a06:	89 04 24             	mov    %eax,(%esp)
80100a09:	e8 4d 0e 00 00       	call   8010185b <ilock>

  return target - n;
80100a0e:	8b 45 10             	mov    0x10(%ebp),%eax
80100a11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a14:	29 c2                	sub    %eax,%edx
80100a16:	89 d0                	mov    %edx,%eax
}
80100a18:	c9                   	leave  
80100a19:	c3                   	ret    

80100a1a <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a1a:	55                   	push   %ebp
80100a1b:	89 e5                	mov    %esp,%ebp
80100a1d:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100a20:	8b 45 08             	mov    0x8(%ebp),%eax
80100a23:	89 04 24             	mov    %eax,(%esp)
80100a26:	e8 7e 0f 00 00       	call   801019a9 <iunlock>
  acquire(&cons.lock);
80100a2b:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a32:	e8 da 43 00 00       	call   80104e11 <acquire>
  for(i = 0; i < n; i++)
80100a37:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a3e:	eb 1d                	jmp    80100a5d <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100a40:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a43:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a46:	01 d0                	add    %edx,%eax
80100a48:	0f b6 00             	movzbl (%eax),%eax
80100a4b:	0f be c0             	movsbl %al,%eax
80100a4e:	0f b6 c0             	movzbl %al,%eax
80100a51:	89 04 24             	mov    %eax,(%esp)
80100a54:	e8 f7 fc ff ff       	call   80100750 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100a59:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a60:	3b 45 10             	cmp    0x10(%ebp),%eax
80100a63:	7c db                	jl     80100a40 <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100a65:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a6c:	e8 02 44 00 00       	call   80104e73 <release>
  ilock(ip);
80100a71:	8b 45 08             	mov    0x8(%ebp),%eax
80100a74:	89 04 24             	mov    %eax,(%esp)
80100a77:	e8 df 0d 00 00       	call   8010185b <ilock>

  return n;
80100a7c:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100a7f:	c9                   	leave  
80100a80:	c3                   	ret    

80100a81 <consoleinit>:

void
consoleinit(void)
{
80100a81:	55                   	push   %ebp
80100a82:	89 e5                	mov    %esp,%ebp
80100a84:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100a87:	c7 44 24 04 ef 86 10 	movl   $0x801086ef,0x4(%esp)
80100a8e:	80 
80100a8f:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a96:	e8 55 43 00 00       	call   80104df0 <initlock>
  initlock(&input.lock, "input");
80100a9b:	c7 44 24 04 f7 86 10 	movl   $0x801086f7,0x4(%esp)
80100aa2:	80 
80100aa3:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100aaa:	e8 41 43 00 00       	call   80104df0 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100aaf:	c7 05 ec 11 11 80 1a 	movl   $0x80100a1a,0x801111ec
80100ab6:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ab9:	c7 05 e8 11 11 80 1b 	movl   $0x8010091b,0x801111e8
80100ac0:	09 10 80 
  cons.locking = 1;
80100ac3:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100aca:	00 00 00 

  picenable(IRQ_KBD);
80100acd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ad4:	e8 f9 32 00 00       	call   80103dd2 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100ad9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100ae0:	00 
80100ae1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ae8:	e8 70 1e 00 00       	call   8010295d <ioapicenable>
}
80100aed:	c9                   	leave  
80100aee:	c3                   	ret    

80100aef <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100aef:	55                   	push   %ebp
80100af0:	89 e5                	mov    %esp,%ebp
80100af2:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100af8:	e8 13 29 00 00       	call   80103410 <begin_op>
  if((ip = namei(path)) == 0){
80100afd:	8b 45 08             	mov    0x8(%ebp),%eax
80100b00:	89 04 24             	mov    %eax,(%esp)
80100b03:	e8 fe 18 00 00       	call   80102406 <namei>
80100b08:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b0b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b0f:	75 0f                	jne    80100b20 <exec+0x31>
    end_op();
80100b11:	e8 7e 29 00 00       	call   80103494 <end_op>
    return -1;
80100b16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b1b:	e9 e8 03 00 00       	jmp    80100f08 <exec+0x419>
  }
  ilock(ip);
80100b20:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b23:	89 04 24             	mov    %eax,(%esp)
80100b26:	e8 30 0d 00 00       	call   8010185b <ilock>
  pgdir = 0;
80100b2b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b32:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b39:	00 
80100b3a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b41:	00 
80100b42:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b48:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b4c:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b4f:	89 04 24             	mov    %eax,(%esp)
80100b52:	e8 11 12 00 00       	call   80101d68 <readi>
80100b57:	83 f8 33             	cmp    $0x33,%eax
80100b5a:	77 05                	ja     80100b61 <exec+0x72>
    goto bad;
80100b5c:	e9 7b 03 00 00       	jmp    80100edc <exec+0x3ed>
  if(elf.magic != ELF_MAGIC)
80100b61:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100b67:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b6c:	74 05                	je     80100b73 <exec+0x84>
    goto bad;
80100b6e:	e9 69 03 00 00       	jmp    80100edc <exec+0x3ed>

  if((pgdir = setupkvm()) == 0)
80100b73:	e8 58 70 00 00       	call   80107bd0 <setupkvm>
80100b78:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b7b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b7f:	75 05                	jne    80100b86 <exec+0x97>
    goto bad;
80100b81:	e9 56 03 00 00       	jmp    80100edc <exec+0x3ed>

  // Load program into memory.
  sz = 0;
80100b86:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b8d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100b94:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100b9a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100b9d:	e9 cb 00 00 00       	jmp    80100c6d <exec+0x17e>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100ba2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100ba5:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100bac:	00 
80100bad:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bb1:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bb7:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bbb:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bbe:	89 04 24             	mov    %eax,(%esp)
80100bc1:	e8 a2 11 00 00       	call   80101d68 <readi>
80100bc6:	83 f8 20             	cmp    $0x20,%eax
80100bc9:	74 05                	je     80100bd0 <exec+0xe1>
      goto bad;
80100bcb:	e9 0c 03 00 00       	jmp    80100edc <exec+0x3ed>
    if(ph.type != ELF_PROG_LOAD)
80100bd0:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100bd6:	83 f8 01             	cmp    $0x1,%eax
80100bd9:	74 05                	je     80100be0 <exec+0xf1>
      continue;
80100bdb:	e9 80 00 00 00       	jmp    80100c60 <exec+0x171>
    if(ph.memsz < ph.filesz)
80100be0:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100be6:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100bec:	39 c2                	cmp    %eax,%edx
80100bee:	73 05                	jae    80100bf5 <exec+0x106>
      goto bad;
80100bf0:	e9 e7 02 00 00       	jmp    80100edc <exec+0x3ed>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100bf5:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100bfb:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c01:	01 d0                	add    %edx,%eax
80100c03:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c07:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c0e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c11:	89 04 24             	mov    %eax,(%esp)
80100c14:	e8 81 73 00 00       	call   80107f9a <allocuvm>
80100c19:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c1c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c20:	75 05                	jne    80100c27 <exec+0x138>
      goto bad;
80100c22:	e9 b5 02 00 00       	jmp    80100edc <exec+0x3ed>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c27:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100c2d:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c33:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c39:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c3d:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c41:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c44:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c48:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c4c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c4f:	89 04 24             	mov    %eax,(%esp)
80100c52:	e8 58 72 00 00       	call   80107eaf <loaduvm>
80100c57:	85 c0                	test   %eax,%eax
80100c59:	79 05                	jns    80100c60 <exec+0x171>
      goto bad;
80100c5b:	e9 7c 02 00 00       	jmp    80100edc <exec+0x3ed>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c60:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c64:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c67:	83 c0 20             	add    $0x20,%eax
80100c6a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c6d:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100c74:	0f b7 c0             	movzwl %ax,%eax
80100c77:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100c7a:	0f 8f 22 ff ff ff    	jg     80100ba2 <exec+0xb3>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100c80:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c83:	89 04 24             	mov    %eax,(%esp)
80100c86:	e8 54 0e 00 00       	call   80101adf <iunlockput>
  end_op();
80100c8b:	e8 04 28 00 00       	call   80103494 <end_op>
  ip = 0;
80100c90:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100c97:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c9a:	05 ff 0f 00 00       	add    $0xfff,%eax
80100c9f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100ca4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100ca7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100caa:	05 00 20 00 00       	add    $0x2000,%eax
80100caf:	89 44 24 08          	mov    %eax,0x8(%esp)
80100cb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cb6:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cba:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cbd:	89 04 24             	mov    %eax,(%esp)
80100cc0:	e8 d5 72 00 00       	call   80107f9a <allocuvm>
80100cc5:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100ccc:	75 05                	jne    80100cd3 <exec+0x1e4>
    goto bad;
80100cce:	e9 09 02 00 00       	jmp    80100edc <exec+0x3ed>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100cd3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd6:	2d 00 20 00 00       	sub    $0x2000,%eax
80100cdb:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cdf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ce2:	89 04 24             	mov    %eax,(%esp)
80100ce5:	e8 e0 74 00 00       	call   801081ca <clearpteu>
  sp = sz;
80100cea:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ced:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100cf0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100cf7:	e9 9a 00 00 00       	jmp    80100d96 <exec+0x2a7>
    if(argc >= MAXARG)
80100cfc:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d00:	76 05                	jbe    80100d07 <exec+0x218>
      goto bad;
80100d02:	e9 d5 01 00 00       	jmp    80100edc <exec+0x3ed>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d0a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d11:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d14:	01 d0                	add    %edx,%eax
80100d16:	8b 00                	mov    (%eax),%eax
80100d18:	89 04 24             	mov    %eax,(%esp)
80100d1b:	e8 af 45 00 00       	call   801052cf <strlen>
80100d20:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100d23:	29 c2                	sub    %eax,%edx
80100d25:	89 d0                	mov    %edx,%eax
80100d27:	83 e8 01             	sub    $0x1,%eax
80100d2a:	83 e0 fc             	and    $0xfffffffc,%eax
80100d2d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d33:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d3d:	01 d0                	add    %edx,%eax
80100d3f:	8b 00                	mov    (%eax),%eax
80100d41:	89 04 24             	mov    %eax,(%esp)
80100d44:	e8 86 45 00 00       	call   801052cf <strlen>
80100d49:	83 c0 01             	add    $0x1,%eax
80100d4c:	89 c2                	mov    %eax,%edx
80100d4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d51:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100d58:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d5b:	01 c8                	add    %ecx,%eax
80100d5d:	8b 00                	mov    (%eax),%eax
80100d5f:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d63:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d67:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d6a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d6e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d71:	89 04 24             	mov    %eax,(%esp)
80100d74:	e8 16 76 00 00       	call   8010838f <copyout>
80100d79:	85 c0                	test   %eax,%eax
80100d7b:	79 05                	jns    80100d82 <exec+0x293>
      goto bad;
80100d7d:	e9 5a 01 00 00       	jmp    80100edc <exec+0x3ed>
    ustack[3+argc] = sp;
80100d82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d85:	8d 50 03             	lea    0x3(%eax),%edx
80100d88:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d8b:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d92:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100d96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d99:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100da0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100da3:	01 d0                	add    %edx,%eax
80100da5:	8b 00                	mov    (%eax),%eax
80100da7:	85 c0                	test   %eax,%eax
80100da9:	0f 85 4d ff ff ff    	jne    80100cfc <exec+0x20d>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100daf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db2:	83 c0 03             	add    $0x3,%eax
80100db5:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100dbc:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100dc0:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100dc7:	ff ff ff 
  ustack[1] = argc;
80100dca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dcd:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100dd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd6:	83 c0 01             	add    $0x1,%eax
80100dd9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100de0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100de3:	29 d0                	sub    %edx,%eax
80100de5:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100deb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dee:	83 c0 04             	add    $0x4,%eax
80100df1:	c1 e0 02             	shl    $0x2,%eax
80100df4:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100df7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dfa:	83 c0 04             	add    $0x4,%eax
80100dfd:	c1 e0 02             	shl    $0x2,%eax
80100e00:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100e04:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e0a:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e0e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e11:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e15:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e18:	89 04 24             	mov    %eax,(%esp)
80100e1b:	e8 6f 75 00 00       	call   8010838f <copyout>
80100e20:	85 c0                	test   %eax,%eax
80100e22:	79 05                	jns    80100e29 <exec+0x33a>
    goto bad;
80100e24:	e9 b3 00 00 00       	jmp    80100edc <exec+0x3ed>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e29:	8b 45 08             	mov    0x8(%ebp),%eax
80100e2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e32:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e35:	eb 17                	jmp    80100e4e <exec+0x35f>
    if(*s == '/')
80100e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e3a:	0f b6 00             	movzbl (%eax),%eax
80100e3d:	3c 2f                	cmp    $0x2f,%al
80100e3f:	75 09                	jne    80100e4a <exec+0x35b>
      last = s+1;
80100e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e44:	83 c0 01             	add    $0x1,%eax
80100e47:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e4a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e51:	0f b6 00             	movzbl (%eax),%eax
80100e54:	84 c0                	test   %al,%al
80100e56:	75 df                	jne    80100e37 <exec+0x348>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e58:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e5e:	8d 50 6c             	lea    0x6c(%eax),%edx
80100e61:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100e68:	00 
80100e69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100e6c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e70:	89 14 24             	mov    %edx,(%esp)
80100e73:	e8 0d 44 00 00       	call   80105285 <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e78:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e7e:	8b 40 04             	mov    0x4(%eax),%eax
80100e81:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100e84:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e8a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100e8d:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100e90:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e96:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100e99:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100e9b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea1:	8b 40 18             	mov    0x18(%eax),%eax
80100ea4:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100eaa:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100ead:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eb3:	8b 40 18             	mov    0x18(%eax),%eax
80100eb6:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100eb9:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100ebc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec2:	89 04 24             	mov    %eax,(%esp)
80100ec5:	e8 04 6e 00 00       	call   80107cce <switchuvm>
  freevm(oldpgdir);
80100eca:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ecd:	89 04 24             	mov    %eax,(%esp)
80100ed0:	e8 5b 72 00 00       	call   80108130 <freevm>
  return 0;
80100ed5:	b8 00 00 00 00       	mov    $0x0,%eax
80100eda:	eb 2c                	jmp    80100f08 <exec+0x419>

 bad:
  if(pgdir)
80100edc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100ee0:	74 0b                	je     80100eed <exec+0x3fe>
    freevm(pgdir);
80100ee2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ee5:	89 04 24             	mov    %eax,(%esp)
80100ee8:	e8 43 72 00 00       	call   80108130 <freevm>
  if(ip){
80100eed:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100ef1:	74 10                	je     80100f03 <exec+0x414>
    iunlockput(ip);
80100ef3:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100ef6:	89 04 24             	mov    %eax,(%esp)
80100ef9:	e8 e1 0b 00 00       	call   80101adf <iunlockput>
    end_op();
80100efe:	e8 91 25 00 00       	call   80103494 <end_op>
  }
  return -1;
80100f03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f08:	c9                   	leave  
80100f09:	c3                   	ret    

80100f0a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f0a:	55                   	push   %ebp
80100f0b:	89 e5                	mov    %esp,%ebp
80100f0d:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f10:	c7 44 24 04 fd 86 10 	movl   $0x801086fd,0x4(%esp)
80100f17:	80 
80100f18:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f1f:	e8 cc 3e 00 00       	call   80104df0 <initlock>
}
80100f24:	c9                   	leave  
80100f25:	c3                   	ret    

80100f26 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f26:	55                   	push   %ebp
80100f27:	89 e5                	mov    %esp,%ebp
80100f29:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f2c:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f33:	e8 d9 3e 00 00       	call   80104e11 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f38:	c7 45 f4 74 08 11 80 	movl   $0x80110874,-0xc(%ebp)
80100f3f:	eb 29                	jmp    80100f6a <filealloc+0x44>
    if(f->ref == 0){
80100f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f44:	8b 40 04             	mov    0x4(%eax),%eax
80100f47:	85 c0                	test   %eax,%eax
80100f49:	75 1b                	jne    80100f66 <filealloc+0x40>
      f->ref = 1;
80100f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f4e:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f55:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f5c:	e8 12 3f 00 00       	call   80104e73 <release>
      return f;
80100f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f64:	eb 1e                	jmp    80100f84 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f66:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f6a:	81 7d f4 d4 11 11 80 	cmpl   $0x801111d4,-0xc(%ebp)
80100f71:	72 ce                	jb     80100f41 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f73:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f7a:	e8 f4 3e 00 00       	call   80104e73 <release>
  return 0;
80100f7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100f84:	c9                   	leave  
80100f85:	c3                   	ret    

80100f86 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100f86:	55                   	push   %ebp
80100f87:	89 e5                	mov    %esp,%ebp
80100f89:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100f8c:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f93:	e8 79 3e 00 00       	call   80104e11 <acquire>
  if(f->ref < 1)
80100f98:	8b 45 08             	mov    0x8(%ebp),%eax
80100f9b:	8b 40 04             	mov    0x4(%eax),%eax
80100f9e:	85 c0                	test   %eax,%eax
80100fa0:	7f 0c                	jg     80100fae <filedup+0x28>
    panic("filedup");
80100fa2:	c7 04 24 04 87 10 80 	movl   $0x80108704,(%esp)
80100fa9:	e8 8c f5 ff ff       	call   8010053a <panic>
  f->ref++;
80100fae:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb1:	8b 40 04             	mov    0x4(%eax),%eax
80100fb4:	8d 50 01             	lea    0x1(%eax),%edx
80100fb7:	8b 45 08             	mov    0x8(%ebp),%eax
80100fba:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fbd:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100fc4:	e8 aa 3e 00 00       	call   80104e73 <release>
  return f;
80100fc9:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100fcc:	c9                   	leave  
80100fcd:	c3                   	ret    

80100fce <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100fce:	55                   	push   %ebp
80100fcf:	89 e5                	mov    %esp,%ebp
80100fd1:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80100fd4:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100fdb:	e8 31 3e 00 00       	call   80104e11 <acquire>
  if(f->ref < 1)
80100fe0:	8b 45 08             	mov    0x8(%ebp),%eax
80100fe3:	8b 40 04             	mov    0x4(%eax),%eax
80100fe6:	85 c0                	test   %eax,%eax
80100fe8:	7f 0c                	jg     80100ff6 <fileclose+0x28>
    panic("fileclose");
80100fea:	c7 04 24 0c 87 10 80 	movl   $0x8010870c,(%esp)
80100ff1:	e8 44 f5 ff ff       	call   8010053a <panic>
  if(--f->ref > 0){
80100ff6:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff9:	8b 40 04             	mov    0x4(%eax),%eax
80100ffc:	8d 50 ff             	lea    -0x1(%eax),%edx
80100fff:	8b 45 08             	mov    0x8(%ebp),%eax
80101002:	89 50 04             	mov    %edx,0x4(%eax)
80101005:	8b 45 08             	mov    0x8(%ebp),%eax
80101008:	8b 40 04             	mov    0x4(%eax),%eax
8010100b:	85 c0                	test   %eax,%eax
8010100d:	7e 11                	jle    80101020 <fileclose+0x52>
    release(&ftable.lock);
8010100f:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80101016:	e8 58 3e 00 00       	call   80104e73 <release>
8010101b:	e9 82 00 00 00       	jmp    801010a2 <fileclose+0xd4>
    return;
  }
  ff = *f;
80101020:	8b 45 08             	mov    0x8(%ebp),%eax
80101023:	8b 10                	mov    (%eax),%edx
80101025:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101028:	8b 50 04             	mov    0x4(%eax),%edx
8010102b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010102e:	8b 50 08             	mov    0x8(%eax),%edx
80101031:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101034:	8b 50 0c             	mov    0xc(%eax),%edx
80101037:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010103a:	8b 50 10             	mov    0x10(%eax),%edx
8010103d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101040:	8b 40 14             	mov    0x14(%eax),%eax
80101043:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101046:	8b 45 08             	mov    0x8(%ebp),%eax
80101049:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101050:	8b 45 08             	mov    0x8(%ebp),%eax
80101053:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101059:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80101060:	e8 0e 3e 00 00       	call   80104e73 <release>
  
  if(ff.type == FD_PIPE)
80101065:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101068:	83 f8 01             	cmp    $0x1,%eax
8010106b:	75 18                	jne    80101085 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
8010106d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101071:	0f be d0             	movsbl %al,%edx
80101074:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101077:	89 54 24 04          	mov    %edx,0x4(%esp)
8010107b:	89 04 24             	mov    %eax,(%esp)
8010107e:	e8 ff 2f 00 00       	call   80104082 <pipeclose>
80101083:	eb 1d                	jmp    801010a2 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
80101085:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101088:	83 f8 02             	cmp    $0x2,%eax
8010108b:	75 15                	jne    801010a2 <fileclose+0xd4>
    begin_op();
8010108d:	e8 7e 23 00 00       	call   80103410 <begin_op>
    iput(ff.ip);
80101092:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101095:	89 04 24             	mov    %eax,(%esp)
80101098:	e8 71 09 00 00       	call   80101a0e <iput>
    end_op();
8010109d:	e8 f2 23 00 00       	call   80103494 <end_op>
  }
}
801010a2:	c9                   	leave  
801010a3:	c3                   	ret    

801010a4 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010a4:	55                   	push   %ebp
801010a5:	89 e5                	mov    %esp,%ebp
801010a7:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801010aa:	8b 45 08             	mov    0x8(%ebp),%eax
801010ad:	8b 00                	mov    (%eax),%eax
801010af:	83 f8 02             	cmp    $0x2,%eax
801010b2:	75 38                	jne    801010ec <filestat+0x48>
    ilock(f->ip);
801010b4:	8b 45 08             	mov    0x8(%ebp),%eax
801010b7:	8b 40 10             	mov    0x10(%eax),%eax
801010ba:	89 04 24             	mov    %eax,(%esp)
801010bd:	e8 99 07 00 00       	call   8010185b <ilock>
    stati(f->ip, st);
801010c2:	8b 45 08             	mov    0x8(%ebp),%eax
801010c5:	8b 40 10             	mov    0x10(%eax),%eax
801010c8:	8b 55 0c             	mov    0xc(%ebp),%edx
801010cb:	89 54 24 04          	mov    %edx,0x4(%esp)
801010cf:	89 04 24             	mov    %eax,(%esp)
801010d2:	e8 4c 0c 00 00       	call   80101d23 <stati>
    iunlock(f->ip);
801010d7:	8b 45 08             	mov    0x8(%ebp),%eax
801010da:	8b 40 10             	mov    0x10(%eax),%eax
801010dd:	89 04 24             	mov    %eax,(%esp)
801010e0:	e8 c4 08 00 00       	call   801019a9 <iunlock>
    return 0;
801010e5:	b8 00 00 00 00       	mov    $0x0,%eax
801010ea:	eb 05                	jmp    801010f1 <filestat+0x4d>
  }
  return -1;
801010ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010f1:	c9                   	leave  
801010f2:	c3                   	ret    

801010f3 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801010f3:	55                   	push   %ebp
801010f4:	89 e5                	mov    %esp,%ebp
801010f6:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801010f9:	8b 45 08             	mov    0x8(%ebp),%eax
801010fc:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101100:	84 c0                	test   %al,%al
80101102:	75 0a                	jne    8010110e <fileread+0x1b>
    return -1;
80101104:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101109:	e9 9f 00 00 00       	jmp    801011ad <fileread+0xba>
  if(f->type == FD_PIPE)
8010110e:	8b 45 08             	mov    0x8(%ebp),%eax
80101111:	8b 00                	mov    (%eax),%eax
80101113:	83 f8 01             	cmp    $0x1,%eax
80101116:	75 1e                	jne    80101136 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101118:	8b 45 08             	mov    0x8(%ebp),%eax
8010111b:	8b 40 0c             	mov    0xc(%eax),%eax
8010111e:	8b 55 10             	mov    0x10(%ebp),%edx
80101121:	89 54 24 08          	mov    %edx,0x8(%esp)
80101125:	8b 55 0c             	mov    0xc(%ebp),%edx
80101128:	89 54 24 04          	mov    %edx,0x4(%esp)
8010112c:	89 04 24             	mov    %eax,(%esp)
8010112f:	e8 cf 30 00 00       	call   80104203 <piperead>
80101134:	eb 77                	jmp    801011ad <fileread+0xba>
  if(f->type == FD_INODE){
80101136:	8b 45 08             	mov    0x8(%ebp),%eax
80101139:	8b 00                	mov    (%eax),%eax
8010113b:	83 f8 02             	cmp    $0x2,%eax
8010113e:	75 61                	jne    801011a1 <fileread+0xae>
    ilock(f->ip);
80101140:	8b 45 08             	mov    0x8(%ebp),%eax
80101143:	8b 40 10             	mov    0x10(%eax),%eax
80101146:	89 04 24             	mov    %eax,(%esp)
80101149:	e8 0d 07 00 00       	call   8010185b <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010114e:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101151:	8b 45 08             	mov    0x8(%ebp),%eax
80101154:	8b 50 14             	mov    0x14(%eax),%edx
80101157:	8b 45 08             	mov    0x8(%ebp),%eax
8010115a:	8b 40 10             	mov    0x10(%eax),%eax
8010115d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101161:	89 54 24 08          	mov    %edx,0x8(%esp)
80101165:	8b 55 0c             	mov    0xc(%ebp),%edx
80101168:	89 54 24 04          	mov    %edx,0x4(%esp)
8010116c:	89 04 24             	mov    %eax,(%esp)
8010116f:	e8 f4 0b 00 00       	call   80101d68 <readi>
80101174:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101177:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010117b:	7e 11                	jle    8010118e <fileread+0x9b>
      f->off += r;
8010117d:	8b 45 08             	mov    0x8(%ebp),%eax
80101180:	8b 50 14             	mov    0x14(%eax),%edx
80101183:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101186:	01 c2                	add    %eax,%edx
80101188:	8b 45 08             	mov    0x8(%ebp),%eax
8010118b:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010118e:	8b 45 08             	mov    0x8(%ebp),%eax
80101191:	8b 40 10             	mov    0x10(%eax),%eax
80101194:	89 04 24             	mov    %eax,(%esp)
80101197:	e8 0d 08 00 00       	call   801019a9 <iunlock>
    return r;
8010119c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010119f:	eb 0c                	jmp    801011ad <fileread+0xba>
  }
  panic("fileread");
801011a1:	c7 04 24 16 87 10 80 	movl   $0x80108716,(%esp)
801011a8:	e8 8d f3 ff ff       	call   8010053a <panic>
}
801011ad:	c9                   	leave  
801011ae:	c3                   	ret    

801011af <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011af:	55                   	push   %ebp
801011b0:	89 e5                	mov    %esp,%ebp
801011b2:	53                   	push   %ebx
801011b3:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011b6:	8b 45 08             	mov    0x8(%ebp),%eax
801011b9:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801011bd:	84 c0                	test   %al,%al
801011bf:	75 0a                	jne    801011cb <filewrite+0x1c>
    return -1;
801011c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011c6:	e9 20 01 00 00       	jmp    801012eb <filewrite+0x13c>
  if(f->type == FD_PIPE)
801011cb:	8b 45 08             	mov    0x8(%ebp),%eax
801011ce:	8b 00                	mov    (%eax),%eax
801011d0:	83 f8 01             	cmp    $0x1,%eax
801011d3:	75 21                	jne    801011f6 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801011d5:	8b 45 08             	mov    0x8(%ebp),%eax
801011d8:	8b 40 0c             	mov    0xc(%eax),%eax
801011db:	8b 55 10             	mov    0x10(%ebp),%edx
801011de:	89 54 24 08          	mov    %edx,0x8(%esp)
801011e2:	8b 55 0c             	mov    0xc(%ebp),%edx
801011e5:	89 54 24 04          	mov    %edx,0x4(%esp)
801011e9:	89 04 24             	mov    %eax,(%esp)
801011ec:	e8 23 2f 00 00       	call   80104114 <pipewrite>
801011f1:	e9 f5 00 00 00       	jmp    801012eb <filewrite+0x13c>
  if(f->type == FD_INODE){
801011f6:	8b 45 08             	mov    0x8(%ebp),%eax
801011f9:	8b 00                	mov    (%eax),%eax
801011fb:	83 f8 02             	cmp    $0x2,%eax
801011fe:	0f 85 db 00 00 00    	jne    801012df <filewrite+0x130>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101204:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
8010120b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101212:	e9 a8 00 00 00       	jmp    801012bf <filewrite+0x110>
      int n1 = n - i;
80101217:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010121a:	8b 55 10             	mov    0x10(%ebp),%edx
8010121d:	29 c2                	sub    %eax,%edx
8010121f:	89 d0                	mov    %edx,%eax
80101221:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101224:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101227:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010122a:	7e 06                	jle    80101232 <filewrite+0x83>
        n1 = max;
8010122c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010122f:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101232:	e8 d9 21 00 00       	call   80103410 <begin_op>
      ilock(f->ip);
80101237:	8b 45 08             	mov    0x8(%ebp),%eax
8010123a:	8b 40 10             	mov    0x10(%eax),%eax
8010123d:	89 04 24             	mov    %eax,(%esp)
80101240:	e8 16 06 00 00       	call   8010185b <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101245:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101248:	8b 45 08             	mov    0x8(%ebp),%eax
8010124b:	8b 50 14             	mov    0x14(%eax),%edx
8010124e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101251:	8b 45 0c             	mov    0xc(%ebp),%eax
80101254:	01 c3                	add    %eax,%ebx
80101256:	8b 45 08             	mov    0x8(%ebp),%eax
80101259:	8b 40 10             	mov    0x10(%eax),%eax
8010125c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101260:	89 54 24 08          	mov    %edx,0x8(%esp)
80101264:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101268:	89 04 24             	mov    %eax,(%esp)
8010126b:	e8 5c 0c 00 00       	call   80101ecc <writei>
80101270:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101273:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101277:	7e 11                	jle    8010128a <filewrite+0xdb>
        f->off += r;
80101279:	8b 45 08             	mov    0x8(%ebp),%eax
8010127c:	8b 50 14             	mov    0x14(%eax),%edx
8010127f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101282:	01 c2                	add    %eax,%edx
80101284:	8b 45 08             	mov    0x8(%ebp),%eax
80101287:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010128a:	8b 45 08             	mov    0x8(%ebp),%eax
8010128d:	8b 40 10             	mov    0x10(%eax),%eax
80101290:	89 04 24             	mov    %eax,(%esp)
80101293:	e8 11 07 00 00       	call   801019a9 <iunlock>
      end_op();
80101298:	e8 f7 21 00 00       	call   80103494 <end_op>

      if(r < 0)
8010129d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012a1:	79 02                	jns    801012a5 <filewrite+0xf6>
        break;
801012a3:	eb 26                	jmp    801012cb <filewrite+0x11c>
      if(r != n1)
801012a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012a8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012ab:	74 0c                	je     801012b9 <filewrite+0x10a>
        panic("short filewrite");
801012ad:	c7 04 24 1f 87 10 80 	movl   $0x8010871f,(%esp)
801012b4:	e8 81 f2 ff ff       	call   8010053a <panic>
      i += r;
801012b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012bc:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012c2:	3b 45 10             	cmp    0x10(%ebp),%eax
801012c5:	0f 8c 4c ff ff ff    	jl     80101217 <filewrite+0x68>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801012cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012ce:	3b 45 10             	cmp    0x10(%ebp),%eax
801012d1:	75 05                	jne    801012d8 <filewrite+0x129>
801012d3:	8b 45 10             	mov    0x10(%ebp),%eax
801012d6:	eb 05                	jmp    801012dd <filewrite+0x12e>
801012d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012dd:	eb 0c                	jmp    801012eb <filewrite+0x13c>
  }
  panic("filewrite");
801012df:	c7 04 24 2f 87 10 80 	movl   $0x8010872f,(%esp)
801012e6:	e8 4f f2 ff ff       	call   8010053a <panic>
}
801012eb:	83 c4 24             	add    $0x24,%esp
801012ee:	5b                   	pop    %ebx
801012ef:	5d                   	pop    %ebp
801012f0:	c3                   	ret    

801012f1 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801012f1:	55                   	push   %ebp
801012f2:	89 e5                	mov    %esp,%ebp
801012f4:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801012f7:	8b 45 08             	mov    0x8(%ebp),%eax
801012fa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101301:	00 
80101302:	89 04 24             	mov    %eax,(%esp)
80101305:	e8 9c ee ff ff       	call   801001a6 <bread>
8010130a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010130d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101310:	83 c0 18             	add    $0x18,%eax
80101313:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010131a:	00 
8010131b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010131f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101322:	89 04 24             	mov    %eax,(%esp)
80101325:	e8 0a 3e 00 00       	call   80105134 <memmove>
  brelse(bp);
8010132a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010132d:	89 04 24             	mov    %eax,(%esp)
80101330:	e8 e2 ee ff ff       	call   80100217 <brelse>
}
80101335:	c9                   	leave  
80101336:	c3                   	ret    

80101337 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101337:	55                   	push   %ebp
80101338:	89 e5                	mov    %esp,%ebp
8010133a:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
8010133d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101340:	8b 45 08             	mov    0x8(%ebp),%eax
80101343:	89 54 24 04          	mov    %edx,0x4(%esp)
80101347:	89 04 24             	mov    %eax,(%esp)
8010134a:	e8 57 ee ff ff       	call   801001a6 <bread>
8010134f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101355:	83 c0 18             	add    $0x18,%eax
80101358:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010135f:	00 
80101360:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101367:	00 
80101368:	89 04 24             	mov    %eax,(%esp)
8010136b:	e8 f5 3c 00 00       	call   80105065 <memset>
  log_write(bp);
80101370:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101373:	89 04 24             	mov    %eax,(%esp)
80101376:	e8 a0 22 00 00       	call   8010361b <log_write>
  brelse(bp);
8010137b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010137e:	89 04 24             	mov    %eax,(%esp)
80101381:	e8 91 ee ff ff       	call   80100217 <brelse>
}
80101386:	c9                   	leave  
80101387:	c3                   	ret    

80101388 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101388:	55                   	push   %ebp
80101389:	89 e5                	mov    %esp,%ebp
8010138b:	83 ec 38             	sub    $0x38,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
8010138e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
80101395:	8b 45 08             	mov    0x8(%ebp),%eax
80101398:	8d 55 d8             	lea    -0x28(%ebp),%edx
8010139b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010139f:	89 04 24             	mov    %eax,(%esp)
801013a2:	e8 4a ff ff ff       	call   801012f1 <readsb>
  for(b = 0; b < sb.size; b += BPB){
801013a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013ae:	e9 07 01 00 00       	jmp    801014ba <balloc+0x132>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
801013b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013b6:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801013bc:	85 c0                	test   %eax,%eax
801013be:	0f 48 c2             	cmovs  %edx,%eax
801013c1:	c1 f8 0c             	sar    $0xc,%eax
801013c4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801013c7:	c1 ea 03             	shr    $0x3,%edx
801013ca:	01 d0                	add    %edx,%eax
801013cc:	83 c0 03             	add    $0x3,%eax
801013cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801013d3:	8b 45 08             	mov    0x8(%ebp),%eax
801013d6:	89 04 24             	mov    %eax,(%esp)
801013d9:	e8 c8 ed ff ff       	call   801001a6 <bread>
801013de:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013e1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801013e8:	e9 9d 00 00 00       	jmp    8010148a <balloc+0x102>
      m = 1 << (bi % 8);
801013ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013f0:	99                   	cltd   
801013f1:	c1 ea 1d             	shr    $0x1d,%edx
801013f4:	01 d0                	add    %edx,%eax
801013f6:	83 e0 07             	and    $0x7,%eax
801013f9:	29 d0                	sub    %edx,%eax
801013fb:	ba 01 00 00 00       	mov    $0x1,%edx
80101400:	89 c1                	mov    %eax,%ecx
80101402:	d3 e2                	shl    %cl,%edx
80101404:	89 d0                	mov    %edx,%eax
80101406:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101409:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010140c:	8d 50 07             	lea    0x7(%eax),%edx
8010140f:	85 c0                	test   %eax,%eax
80101411:	0f 48 c2             	cmovs  %edx,%eax
80101414:	c1 f8 03             	sar    $0x3,%eax
80101417:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010141a:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
8010141f:	0f b6 c0             	movzbl %al,%eax
80101422:	23 45 e8             	and    -0x18(%ebp),%eax
80101425:	85 c0                	test   %eax,%eax
80101427:	75 5d                	jne    80101486 <balloc+0xfe>
        bp->data[bi/8] |= m;  // Mark block in use.
80101429:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010142c:	8d 50 07             	lea    0x7(%eax),%edx
8010142f:	85 c0                	test   %eax,%eax
80101431:	0f 48 c2             	cmovs  %edx,%eax
80101434:	c1 f8 03             	sar    $0x3,%eax
80101437:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010143a:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010143f:	89 d1                	mov    %edx,%ecx
80101441:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101444:	09 ca                	or     %ecx,%edx
80101446:	89 d1                	mov    %edx,%ecx
80101448:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010144b:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
8010144f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101452:	89 04 24             	mov    %eax,(%esp)
80101455:	e8 c1 21 00 00       	call   8010361b <log_write>
        brelse(bp);
8010145a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010145d:	89 04 24             	mov    %eax,(%esp)
80101460:	e8 b2 ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101465:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101468:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010146b:	01 c2                	add    %eax,%edx
8010146d:	8b 45 08             	mov    0x8(%ebp),%eax
80101470:	89 54 24 04          	mov    %edx,0x4(%esp)
80101474:	89 04 24             	mov    %eax,(%esp)
80101477:	e8 bb fe ff ff       	call   80101337 <bzero>
        return b + bi;
8010147c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010147f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101482:	01 d0                	add    %edx,%eax
80101484:	eb 4e                	jmp    801014d4 <balloc+0x14c>

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101486:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010148a:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101491:	7f 15                	jg     801014a8 <balloc+0x120>
80101493:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101496:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101499:	01 d0                	add    %edx,%eax
8010149b:	89 c2                	mov    %eax,%edx
8010149d:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014a0:	39 c2                	cmp    %eax,%edx
801014a2:	0f 82 45 ff ff ff    	jb     801013ed <balloc+0x65>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014ab:	89 04 24             	mov    %eax,(%esp)
801014ae:	e8 64 ed ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
801014b3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014bd:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014c0:	39 c2                	cmp    %eax,%edx
801014c2:	0f 82 eb fe ff ff    	jb     801013b3 <balloc+0x2b>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014c8:	c7 04 24 39 87 10 80 	movl   $0x80108739,(%esp)
801014cf:	e8 66 f0 ff ff       	call   8010053a <panic>
}
801014d4:	c9                   	leave  
801014d5:	c3                   	ret    

801014d6 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801014d6:	55                   	push   %ebp
801014d7:	89 e5                	mov    %esp,%ebp
801014d9:	83 ec 38             	sub    $0x38,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
801014dc:	8d 45 dc             	lea    -0x24(%ebp),%eax
801014df:	89 44 24 04          	mov    %eax,0x4(%esp)
801014e3:	8b 45 08             	mov    0x8(%ebp),%eax
801014e6:	89 04 24             	mov    %eax,(%esp)
801014e9:	e8 03 fe ff ff       	call   801012f1 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
801014ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801014f1:	c1 e8 0c             	shr    $0xc,%eax
801014f4:	89 c2                	mov    %eax,%edx
801014f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801014f9:	c1 e8 03             	shr    $0x3,%eax
801014fc:	01 d0                	add    %edx,%eax
801014fe:	8d 50 03             	lea    0x3(%eax),%edx
80101501:	8b 45 08             	mov    0x8(%ebp),%eax
80101504:	89 54 24 04          	mov    %edx,0x4(%esp)
80101508:	89 04 24             	mov    %eax,(%esp)
8010150b:	e8 96 ec ff ff       	call   801001a6 <bread>
80101510:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101513:	8b 45 0c             	mov    0xc(%ebp),%eax
80101516:	25 ff 0f 00 00       	and    $0xfff,%eax
8010151b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010151e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101521:	99                   	cltd   
80101522:	c1 ea 1d             	shr    $0x1d,%edx
80101525:	01 d0                	add    %edx,%eax
80101527:	83 e0 07             	and    $0x7,%eax
8010152a:	29 d0                	sub    %edx,%eax
8010152c:	ba 01 00 00 00       	mov    $0x1,%edx
80101531:	89 c1                	mov    %eax,%ecx
80101533:	d3 e2                	shl    %cl,%edx
80101535:	89 d0                	mov    %edx,%eax
80101537:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010153a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153d:	8d 50 07             	lea    0x7(%eax),%edx
80101540:	85 c0                	test   %eax,%eax
80101542:	0f 48 c2             	cmovs  %edx,%eax
80101545:	c1 f8 03             	sar    $0x3,%eax
80101548:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010154b:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101550:	0f b6 c0             	movzbl %al,%eax
80101553:	23 45 ec             	and    -0x14(%ebp),%eax
80101556:	85 c0                	test   %eax,%eax
80101558:	75 0c                	jne    80101566 <bfree+0x90>
    panic("freeing free block");
8010155a:	c7 04 24 4f 87 10 80 	movl   $0x8010874f,(%esp)
80101561:	e8 d4 ef ff ff       	call   8010053a <panic>
  bp->data[bi/8] &= ~m;
80101566:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101569:	8d 50 07             	lea    0x7(%eax),%edx
8010156c:	85 c0                	test   %eax,%eax
8010156e:	0f 48 c2             	cmovs  %edx,%eax
80101571:	c1 f8 03             	sar    $0x3,%eax
80101574:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101577:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010157c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010157f:	f7 d1                	not    %ecx
80101581:	21 ca                	and    %ecx,%edx
80101583:	89 d1                	mov    %edx,%ecx
80101585:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101588:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
8010158c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010158f:	89 04 24             	mov    %eax,(%esp)
80101592:	e8 84 20 00 00       	call   8010361b <log_write>
  brelse(bp);
80101597:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010159a:	89 04 24             	mov    %eax,(%esp)
8010159d:	e8 75 ec ff ff       	call   80100217 <brelse>
}
801015a2:	c9                   	leave  
801015a3:	c3                   	ret    

801015a4 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
801015a4:	55                   	push   %ebp
801015a5:	89 e5                	mov    %esp,%ebp
801015a7:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
801015aa:	c7 44 24 04 62 87 10 	movl   $0x80108762,0x4(%esp)
801015b1:	80 
801015b2:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801015b9:	e8 32 38 00 00       	call   80104df0 <initlock>
}
801015be:	c9                   	leave  
801015bf:	c3                   	ret    

801015c0 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801015c0:	55                   	push   %ebp
801015c1:	89 e5                	mov    %esp,%ebp
801015c3:	83 ec 38             	sub    $0x38,%esp
801015c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801015c9:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
801015cd:	8b 45 08             	mov    0x8(%ebp),%eax
801015d0:	8d 55 dc             	lea    -0x24(%ebp),%edx
801015d3:	89 54 24 04          	mov    %edx,0x4(%esp)
801015d7:	89 04 24             	mov    %eax,(%esp)
801015da:	e8 12 fd ff ff       	call   801012f1 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
801015df:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801015e6:	e9 98 00 00 00       	jmp    80101683 <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
801015eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015ee:	c1 e8 03             	shr    $0x3,%eax
801015f1:	83 c0 02             	add    $0x2,%eax
801015f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801015f8:	8b 45 08             	mov    0x8(%ebp),%eax
801015fb:	89 04 24             	mov    %eax,(%esp)
801015fe:	e8 a3 eb ff ff       	call   801001a6 <bread>
80101603:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101606:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101609:	8d 50 18             	lea    0x18(%eax),%edx
8010160c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010160f:	83 e0 07             	and    $0x7,%eax
80101612:	c1 e0 06             	shl    $0x6,%eax
80101615:	01 d0                	add    %edx,%eax
80101617:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010161a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010161d:	0f b7 00             	movzwl (%eax),%eax
80101620:	66 85 c0             	test   %ax,%ax
80101623:	75 4f                	jne    80101674 <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
80101625:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
8010162c:	00 
8010162d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101634:	00 
80101635:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101638:	89 04 24             	mov    %eax,(%esp)
8010163b:	e8 25 3a 00 00       	call   80105065 <memset>
      dip->type = type;
80101640:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101643:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
80101647:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010164a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010164d:	89 04 24             	mov    %eax,(%esp)
80101650:	e8 c6 1f 00 00       	call   8010361b <log_write>
      brelse(bp);
80101655:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101658:	89 04 24             	mov    %eax,(%esp)
8010165b:	e8 b7 eb ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
80101660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101663:	89 44 24 04          	mov    %eax,0x4(%esp)
80101667:	8b 45 08             	mov    0x8(%ebp),%eax
8010166a:	89 04 24             	mov    %eax,(%esp)
8010166d:	e8 e5 00 00 00       	call   80101757 <iget>
80101672:	eb 29                	jmp    8010169d <ialloc+0xdd>
    }
    brelse(bp);
80101674:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101677:	89 04 24             	mov    %eax,(%esp)
8010167a:	e8 98 eb ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
8010167f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101683:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101686:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101689:	39 c2                	cmp    %eax,%edx
8010168b:	0f 82 5a ff ff ff    	jb     801015eb <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101691:	c7 04 24 69 87 10 80 	movl   $0x80108769,(%esp)
80101698:	e8 9d ee ff ff       	call   8010053a <panic>
}
8010169d:	c9                   	leave  
8010169e:	c3                   	ret    

8010169f <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
8010169f:	55                   	push   %ebp
801016a0:	89 e5                	mov    %esp,%ebp
801016a2:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
801016a5:	8b 45 08             	mov    0x8(%ebp),%eax
801016a8:	8b 40 04             	mov    0x4(%eax),%eax
801016ab:	c1 e8 03             	shr    $0x3,%eax
801016ae:	8d 50 02             	lea    0x2(%eax),%edx
801016b1:	8b 45 08             	mov    0x8(%ebp),%eax
801016b4:	8b 00                	mov    (%eax),%eax
801016b6:	89 54 24 04          	mov    %edx,0x4(%esp)
801016ba:	89 04 24             	mov    %eax,(%esp)
801016bd:	e8 e4 ea ff ff       	call   801001a6 <bread>
801016c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801016c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016c8:	8d 50 18             	lea    0x18(%eax),%edx
801016cb:	8b 45 08             	mov    0x8(%ebp),%eax
801016ce:	8b 40 04             	mov    0x4(%eax),%eax
801016d1:	83 e0 07             	and    $0x7,%eax
801016d4:	c1 e0 06             	shl    $0x6,%eax
801016d7:	01 d0                	add    %edx,%eax
801016d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801016dc:	8b 45 08             	mov    0x8(%ebp),%eax
801016df:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801016e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016e6:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801016e9:	8b 45 08             	mov    0x8(%ebp),%eax
801016ec:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801016f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f3:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801016f7:	8b 45 08             	mov    0x8(%ebp),%eax
801016fa:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801016fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101701:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101705:	8b 45 08             	mov    0x8(%ebp),%eax
80101708:	0f b7 50 16          	movzwl 0x16(%eax),%edx
8010170c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010170f:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101713:	8b 45 08             	mov    0x8(%ebp),%eax
80101716:	8b 50 18             	mov    0x18(%eax),%edx
80101719:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010171c:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010171f:	8b 45 08             	mov    0x8(%ebp),%eax
80101722:	8d 50 1c             	lea    0x1c(%eax),%edx
80101725:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101728:	83 c0 0c             	add    $0xc,%eax
8010172b:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101732:	00 
80101733:	89 54 24 04          	mov    %edx,0x4(%esp)
80101737:	89 04 24             	mov    %eax,(%esp)
8010173a:	e8 f5 39 00 00       	call   80105134 <memmove>
  log_write(bp);
8010173f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101742:	89 04 24             	mov    %eax,(%esp)
80101745:	e8 d1 1e 00 00       	call   8010361b <log_write>
  brelse(bp);
8010174a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010174d:	89 04 24             	mov    %eax,(%esp)
80101750:	e8 c2 ea ff ff       	call   80100217 <brelse>
}
80101755:	c9                   	leave  
80101756:	c3                   	ret    

80101757 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101757:	55                   	push   %ebp
80101758:	89 e5                	mov    %esp,%ebp
8010175a:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
8010175d:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101764:	e8 a8 36 00 00       	call   80104e11 <acquire>

  // Is the inode already cached?
  empty = 0;
80101769:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101770:	c7 45 f4 74 12 11 80 	movl   $0x80111274,-0xc(%ebp)
80101777:	eb 59                	jmp    801017d2 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101779:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010177c:	8b 40 08             	mov    0x8(%eax),%eax
8010177f:	85 c0                	test   %eax,%eax
80101781:	7e 35                	jle    801017b8 <iget+0x61>
80101783:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101786:	8b 00                	mov    (%eax),%eax
80101788:	3b 45 08             	cmp    0x8(%ebp),%eax
8010178b:	75 2b                	jne    801017b8 <iget+0x61>
8010178d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101790:	8b 40 04             	mov    0x4(%eax),%eax
80101793:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101796:	75 20                	jne    801017b8 <iget+0x61>
      ip->ref++;
80101798:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010179b:	8b 40 08             	mov    0x8(%eax),%eax
8010179e:	8d 50 01             	lea    0x1(%eax),%edx
801017a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a4:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801017a7:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801017ae:	e8 c0 36 00 00       	call   80104e73 <release>
      return ip;
801017b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017b6:	eb 6f                	jmp    80101827 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801017b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017bc:	75 10                	jne    801017ce <iget+0x77>
801017be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c1:	8b 40 08             	mov    0x8(%eax),%eax
801017c4:	85 c0                	test   %eax,%eax
801017c6:	75 06                	jne    801017ce <iget+0x77>
      empty = ip;
801017c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017cb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017ce:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801017d2:	81 7d f4 14 22 11 80 	cmpl   $0x80112214,-0xc(%ebp)
801017d9:	72 9e                	jb     80101779 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801017db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017df:	75 0c                	jne    801017ed <iget+0x96>
    panic("iget: no inodes");
801017e1:	c7 04 24 7b 87 10 80 	movl   $0x8010877b,(%esp)
801017e8:	e8 4d ed ff ff       	call   8010053a <panic>

  ip = empty;
801017ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801017f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f6:	8b 55 08             	mov    0x8(%ebp),%edx
801017f9:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801017fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017fe:	8b 55 0c             	mov    0xc(%ebp),%edx
80101801:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101804:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101807:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
8010180e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101811:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101818:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
8010181f:	e8 4f 36 00 00       	call   80104e73 <release>

  return ip;
80101824:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101827:	c9                   	leave  
80101828:	c3                   	ret    

80101829 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101829:	55                   	push   %ebp
8010182a:	89 e5                	mov    %esp,%ebp
8010182c:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
8010182f:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101836:	e8 d6 35 00 00       	call   80104e11 <acquire>
  ip->ref++;
8010183b:	8b 45 08             	mov    0x8(%ebp),%eax
8010183e:	8b 40 08             	mov    0x8(%eax),%eax
80101841:	8d 50 01             	lea    0x1(%eax),%edx
80101844:	8b 45 08             	mov    0x8(%ebp),%eax
80101847:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
8010184a:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101851:	e8 1d 36 00 00       	call   80104e73 <release>
  return ip;
80101856:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101859:	c9                   	leave  
8010185a:	c3                   	ret    

8010185b <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
8010185b:	55                   	push   %ebp
8010185c:	89 e5                	mov    %esp,%ebp
8010185e:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101861:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101865:	74 0a                	je     80101871 <ilock+0x16>
80101867:	8b 45 08             	mov    0x8(%ebp),%eax
8010186a:	8b 40 08             	mov    0x8(%eax),%eax
8010186d:	85 c0                	test   %eax,%eax
8010186f:	7f 0c                	jg     8010187d <ilock+0x22>
    panic("ilock");
80101871:	c7 04 24 8b 87 10 80 	movl   $0x8010878b,(%esp)
80101878:	e8 bd ec ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
8010187d:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101884:	e8 88 35 00 00       	call   80104e11 <acquire>
  while(ip->flags & I_BUSY)
80101889:	eb 13                	jmp    8010189e <ilock+0x43>
    sleep(ip, &icache.lock);
8010188b:	c7 44 24 04 40 12 11 	movl   $0x80111240,0x4(%esp)
80101892:	80 
80101893:	8b 45 08             	mov    0x8(%ebp),%eax
80101896:	89 04 24             	mov    %eax,(%esp)
80101899:	e8 a9 32 00 00       	call   80104b47 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
8010189e:	8b 45 08             	mov    0x8(%ebp),%eax
801018a1:	8b 40 0c             	mov    0xc(%eax),%eax
801018a4:	83 e0 01             	and    $0x1,%eax
801018a7:	85 c0                	test   %eax,%eax
801018a9:	75 e0                	jne    8010188b <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801018ab:	8b 45 08             	mov    0x8(%ebp),%eax
801018ae:	8b 40 0c             	mov    0xc(%eax),%eax
801018b1:	83 c8 01             	or     $0x1,%eax
801018b4:	89 c2                	mov    %eax,%edx
801018b6:	8b 45 08             	mov    0x8(%ebp),%eax
801018b9:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801018bc:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801018c3:	e8 ab 35 00 00       	call   80104e73 <release>

  if(!(ip->flags & I_VALID)){
801018c8:	8b 45 08             	mov    0x8(%ebp),%eax
801018cb:	8b 40 0c             	mov    0xc(%eax),%eax
801018ce:	83 e0 02             	and    $0x2,%eax
801018d1:	85 c0                	test   %eax,%eax
801018d3:	0f 85 ce 00 00 00    	jne    801019a7 <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
801018d9:	8b 45 08             	mov    0x8(%ebp),%eax
801018dc:	8b 40 04             	mov    0x4(%eax),%eax
801018df:	c1 e8 03             	shr    $0x3,%eax
801018e2:	8d 50 02             	lea    0x2(%eax),%edx
801018e5:	8b 45 08             	mov    0x8(%ebp),%eax
801018e8:	8b 00                	mov    (%eax),%eax
801018ea:	89 54 24 04          	mov    %edx,0x4(%esp)
801018ee:	89 04 24             	mov    %eax,(%esp)
801018f1:	e8 b0 e8 ff ff       	call   801001a6 <bread>
801018f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801018f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018fc:	8d 50 18             	lea    0x18(%eax),%edx
801018ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101902:	8b 40 04             	mov    0x4(%eax),%eax
80101905:	83 e0 07             	and    $0x7,%eax
80101908:	c1 e0 06             	shl    $0x6,%eax
8010190b:	01 d0                	add    %edx,%eax
8010190d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101910:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101913:	0f b7 10             	movzwl (%eax),%edx
80101916:	8b 45 08             	mov    0x8(%ebp),%eax
80101919:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
8010191d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101920:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101924:	8b 45 08             	mov    0x8(%ebp),%eax
80101927:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
8010192b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010192e:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101932:	8b 45 08             	mov    0x8(%ebp),%eax
80101935:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101939:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010193c:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101940:	8b 45 08             	mov    0x8(%ebp),%eax
80101943:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101947:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010194a:	8b 50 08             	mov    0x8(%eax),%edx
8010194d:	8b 45 08             	mov    0x8(%ebp),%eax
80101950:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101953:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101956:	8d 50 0c             	lea    0xc(%eax),%edx
80101959:	8b 45 08             	mov    0x8(%ebp),%eax
8010195c:	83 c0 1c             	add    $0x1c,%eax
8010195f:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101966:	00 
80101967:	89 54 24 04          	mov    %edx,0x4(%esp)
8010196b:	89 04 24             	mov    %eax,(%esp)
8010196e:	e8 c1 37 00 00       	call   80105134 <memmove>
    brelse(bp);
80101973:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101976:	89 04 24             	mov    %eax,(%esp)
80101979:	e8 99 e8 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
8010197e:	8b 45 08             	mov    0x8(%ebp),%eax
80101981:	8b 40 0c             	mov    0xc(%eax),%eax
80101984:	83 c8 02             	or     $0x2,%eax
80101987:	89 c2                	mov    %eax,%edx
80101989:	8b 45 08             	mov    0x8(%ebp),%eax
8010198c:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
8010198f:	8b 45 08             	mov    0x8(%ebp),%eax
80101992:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101996:	66 85 c0             	test   %ax,%ax
80101999:	75 0c                	jne    801019a7 <ilock+0x14c>
      panic("ilock: no type");
8010199b:	c7 04 24 91 87 10 80 	movl   $0x80108791,(%esp)
801019a2:	e8 93 eb ff ff       	call   8010053a <panic>
  }
}
801019a7:	c9                   	leave  
801019a8:	c3                   	ret    

801019a9 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
801019a9:	55                   	push   %ebp
801019aa:	89 e5                	mov    %esp,%ebp
801019ac:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
801019af:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019b3:	74 17                	je     801019cc <iunlock+0x23>
801019b5:	8b 45 08             	mov    0x8(%ebp),%eax
801019b8:	8b 40 0c             	mov    0xc(%eax),%eax
801019bb:	83 e0 01             	and    $0x1,%eax
801019be:	85 c0                	test   %eax,%eax
801019c0:	74 0a                	je     801019cc <iunlock+0x23>
801019c2:	8b 45 08             	mov    0x8(%ebp),%eax
801019c5:	8b 40 08             	mov    0x8(%eax),%eax
801019c8:	85 c0                	test   %eax,%eax
801019ca:	7f 0c                	jg     801019d8 <iunlock+0x2f>
    panic("iunlock");
801019cc:	c7 04 24 a0 87 10 80 	movl   $0x801087a0,(%esp)
801019d3:	e8 62 eb ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
801019d8:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801019df:	e8 2d 34 00 00       	call   80104e11 <acquire>
  ip->flags &= ~I_BUSY;
801019e4:	8b 45 08             	mov    0x8(%ebp),%eax
801019e7:	8b 40 0c             	mov    0xc(%eax),%eax
801019ea:	83 e0 fe             	and    $0xfffffffe,%eax
801019ed:	89 c2                	mov    %eax,%edx
801019ef:	8b 45 08             	mov    0x8(%ebp),%eax
801019f2:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
801019f5:	8b 45 08             	mov    0x8(%ebp),%eax
801019f8:	89 04 24             	mov    %eax,(%esp)
801019fb:	e8 20 32 00 00       	call   80104c20 <wakeup>
  release(&icache.lock);
80101a00:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a07:	e8 67 34 00 00       	call   80104e73 <release>
}
80101a0c:	c9                   	leave  
80101a0d:	c3                   	ret    

80101a0e <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101a0e:	55                   	push   %ebp
80101a0f:	89 e5                	mov    %esp,%ebp
80101a11:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a14:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a1b:	e8 f1 33 00 00       	call   80104e11 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101a20:	8b 45 08             	mov    0x8(%ebp),%eax
80101a23:	8b 40 08             	mov    0x8(%eax),%eax
80101a26:	83 f8 01             	cmp    $0x1,%eax
80101a29:	0f 85 93 00 00 00    	jne    80101ac2 <iput+0xb4>
80101a2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a32:	8b 40 0c             	mov    0xc(%eax),%eax
80101a35:	83 e0 02             	and    $0x2,%eax
80101a38:	85 c0                	test   %eax,%eax
80101a3a:	0f 84 82 00 00 00    	je     80101ac2 <iput+0xb4>
80101a40:	8b 45 08             	mov    0x8(%ebp),%eax
80101a43:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101a47:	66 85 c0             	test   %ax,%ax
80101a4a:	75 76                	jne    80101ac2 <iput+0xb4>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101a4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4f:	8b 40 0c             	mov    0xc(%eax),%eax
80101a52:	83 e0 01             	and    $0x1,%eax
80101a55:	85 c0                	test   %eax,%eax
80101a57:	74 0c                	je     80101a65 <iput+0x57>
      panic("iput busy");
80101a59:	c7 04 24 a8 87 10 80 	movl   $0x801087a8,(%esp)
80101a60:	e8 d5 ea ff ff       	call   8010053a <panic>
    ip->flags |= I_BUSY;
80101a65:	8b 45 08             	mov    0x8(%ebp),%eax
80101a68:	8b 40 0c             	mov    0xc(%eax),%eax
80101a6b:	83 c8 01             	or     $0x1,%eax
80101a6e:	89 c2                	mov    %eax,%edx
80101a70:	8b 45 08             	mov    0x8(%ebp),%eax
80101a73:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101a76:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a7d:	e8 f1 33 00 00       	call   80104e73 <release>
    itrunc(ip);
80101a82:	8b 45 08             	mov    0x8(%ebp),%eax
80101a85:	89 04 24             	mov    %eax,(%esp)
80101a88:	e8 7d 01 00 00       	call   80101c0a <itrunc>
    ip->type = 0;
80101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a90:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101a96:	8b 45 08             	mov    0x8(%ebp),%eax
80101a99:	89 04 24             	mov    %eax,(%esp)
80101a9c:	e8 fe fb ff ff       	call   8010169f <iupdate>
    acquire(&icache.lock);
80101aa1:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101aa8:	e8 64 33 00 00       	call   80104e11 <acquire>
    ip->flags = 0;
80101aad:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ab7:	8b 45 08             	mov    0x8(%ebp),%eax
80101aba:	89 04 24             	mov    %eax,(%esp)
80101abd:	e8 5e 31 00 00       	call   80104c20 <wakeup>
  }
  ip->ref--;
80101ac2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac5:	8b 40 08             	mov    0x8(%eax),%eax
80101ac8:	8d 50 ff             	lea    -0x1(%eax),%edx
80101acb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ace:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ad1:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101ad8:	e8 96 33 00 00       	call   80104e73 <release>
}
80101add:	c9                   	leave  
80101ade:	c3                   	ret    

80101adf <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101adf:	55                   	push   %ebp
80101ae0:	89 e5                	mov    %esp,%ebp
80101ae2:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101ae5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae8:	89 04 24             	mov    %eax,(%esp)
80101aeb:	e8 b9 fe ff ff       	call   801019a9 <iunlock>
  iput(ip);
80101af0:	8b 45 08             	mov    0x8(%ebp),%eax
80101af3:	89 04 24             	mov    %eax,(%esp)
80101af6:	e8 13 ff ff ff       	call   80101a0e <iput>
}
80101afb:	c9                   	leave  
80101afc:	c3                   	ret    

80101afd <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101afd:	55                   	push   %ebp
80101afe:	89 e5                	mov    %esp,%ebp
80101b00:	53                   	push   %ebx
80101b01:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b04:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b08:	77 3e                	ja     80101b48 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b10:	83 c2 04             	add    $0x4,%edx
80101b13:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b17:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b1a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b1e:	75 20                	jne    80101b40 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b20:	8b 45 08             	mov    0x8(%ebp),%eax
80101b23:	8b 00                	mov    (%eax),%eax
80101b25:	89 04 24             	mov    %eax,(%esp)
80101b28:	e8 5b f8 ff ff       	call   80101388 <balloc>
80101b2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b30:	8b 45 08             	mov    0x8(%ebp),%eax
80101b33:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b36:	8d 4a 04             	lea    0x4(%edx),%ecx
80101b39:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b3c:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b43:	e9 bc 00 00 00       	jmp    80101c04 <bmap+0x107>
  }
  bn -= NDIRECT;
80101b48:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101b4c:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101b50:	0f 87 a2 00 00 00    	ja     80101bf8 <bmap+0xfb>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101b56:	8b 45 08             	mov    0x8(%ebp),%eax
80101b59:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b5f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b63:	75 19                	jne    80101b7e <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101b65:	8b 45 08             	mov    0x8(%ebp),%eax
80101b68:	8b 00                	mov    (%eax),%eax
80101b6a:	89 04 24             	mov    %eax,(%esp)
80101b6d:	e8 16 f8 ff ff       	call   80101388 <balloc>
80101b72:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b75:	8b 45 08             	mov    0x8(%ebp),%eax
80101b78:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b7b:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101b7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b81:	8b 00                	mov    (%eax),%eax
80101b83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b86:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b8a:	89 04 24             	mov    %eax,(%esp)
80101b8d:	e8 14 e6 ff ff       	call   801001a6 <bread>
80101b92:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b98:	83 c0 18             	add    $0x18,%eax
80101b9b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101b9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ba1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ba8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bab:	01 d0                	add    %edx,%eax
80101bad:	8b 00                	mov    (%eax),%eax
80101baf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bb2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101bb6:	75 30                	jne    80101be8 <bmap+0xeb>
      a[bn] = addr = balloc(ip->dev);
80101bb8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bbb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101bc2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bc5:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101bc8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcb:	8b 00                	mov    (%eax),%eax
80101bcd:	89 04 24             	mov    %eax,(%esp)
80101bd0:	e8 b3 f7 ff ff       	call   80101388 <balloc>
80101bd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bdb:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101bdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101be0:	89 04 24             	mov    %eax,(%esp)
80101be3:	e8 33 1a 00 00       	call   8010361b <log_write>
    }
    brelse(bp);
80101be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101beb:	89 04 24             	mov    %eax,(%esp)
80101bee:	e8 24 e6 ff ff       	call   80100217 <brelse>
    return addr;
80101bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bf6:	eb 0c                	jmp    80101c04 <bmap+0x107>
  }

  panic("bmap: out of range");
80101bf8:	c7 04 24 b2 87 10 80 	movl   $0x801087b2,(%esp)
80101bff:	e8 36 e9 ff ff       	call   8010053a <panic>
}
80101c04:	83 c4 24             	add    $0x24,%esp
80101c07:	5b                   	pop    %ebx
80101c08:	5d                   	pop    %ebp
80101c09:	c3                   	ret    

80101c0a <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c0a:	55                   	push   %ebp
80101c0b:	89 e5                	mov    %esp,%ebp
80101c0d:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c17:	eb 44                	jmp    80101c5d <itrunc+0x53>
    if(ip->addrs[i]){
80101c19:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c1f:	83 c2 04             	add    $0x4,%edx
80101c22:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c26:	85 c0                	test   %eax,%eax
80101c28:	74 2f                	je     80101c59 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101c2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c30:	83 c2 04             	add    $0x4,%edx
80101c33:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101c37:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3a:	8b 00                	mov    (%eax),%eax
80101c3c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c40:	89 04 24             	mov    %eax,(%esp)
80101c43:	e8 8e f8 ff ff       	call   801014d6 <bfree>
      ip->addrs[i] = 0;
80101c48:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c4e:	83 c2 04             	add    $0x4,%edx
80101c51:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101c58:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c59:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101c5d:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101c61:	7e b6                	jle    80101c19 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101c63:	8b 45 08             	mov    0x8(%ebp),%eax
80101c66:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c69:	85 c0                	test   %eax,%eax
80101c6b:	0f 84 9b 00 00 00    	je     80101d0c <itrunc+0x102>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101c71:	8b 45 08             	mov    0x8(%ebp),%eax
80101c74:	8b 50 4c             	mov    0x4c(%eax),%edx
80101c77:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7a:	8b 00                	mov    (%eax),%eax
80101c7c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c80:	89 04 24             	mov    %eax,(%esp)
80101c83:	e8 1e e5 ff ff       	call   801001a6 <bread>
80101c88:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101c8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c8e:	83 c0 18             	add    $0x18,%eax
80101c91:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101c94:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101c9b:	eb 3b                	jmp    80101cd8 <itrunc+0xce>
      if(a[j])
80101c9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ca0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ca7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101caa:	01 d0                	add    %edx,%eax
80101cac:	8b 00                	mov    (%eax),%eax
80101cae:	85 c0                	test   %eax,%eax
80101cb0:	74 22                	je     80101cd4 <itrunc+0xca>
        bfree(ip->dev, a[j]);
80101cb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cb5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cbc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101cbf:	01 d0                	add    %edx,%eax
80101cc1:	8b 10                	mov    (%eax),%edx
80101cc3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc6:	8b 00                	mov    (%eax),%eax
80101cc8:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ccc:	89 04 24             	mov    %eax,(%esp)
80101ccf:	e8 02 f8 ff ff       	call   801014d6 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101cd4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cdb:	83 f8 7f             	cmp    $0x7f,%eax
80101cde:	76 bd                	jbe    80101c9d <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101ce0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ce3:	89 04 24             	mov    %eax,(%esp)
80101ce6:	e8 2c e5 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ceb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cee:	8b 50 4c             	mov    0x4c(%eax),%edx
80101cf1:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf4:	8b 00                	mov    (%eax),%eax
80101cf6:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cfa:	89 04 24             	mov    %eax,(%esp)
80101cfd:	e8 d4 f7 ff ff       	call   801014d6 <bfree>
    ip->addrs[NDIRECT] = 0;
80101d02:	8b 45 08             	mov    0x8(%ebp),%eax
80101d05:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101d0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0f:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101d16:	8b 45 08             	mov    0x8(%ebp),%eax
80101d19:	89 04 24             	mov    %eax,(%esp)
80101d1c:	e8 7e f9 ff ff       	call   8010169f <iupdate>
}
80101d21:	c9                   	leave  
80101d22:	c3                   	ret    

80101d23 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101d23:	55                   	push   %ebp
80101d24:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101d26:	8b 45 08             	mov    0x8(%ebp),%eax
80101d29:	8b 00                	mov    (%eax),%eax
80101d2b:	89 c2                	mov    %eax,%edx
80101d2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d30:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101d33:	8b 45 08             	mov    0x8(%ebp),%eax
80101d36:	8b 50 04             	mov    0x4(%eax),%edx
80101d39:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d3c:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101d3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d42:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101d46:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d49:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101d4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4f:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101d53:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d56:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101d5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5d:	8b 50 18             	mov    0x18(%eax),%edx
80101d60:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d63:	89 50 10             	mov    %edx,0x10(%eax)
}
80101d66:	5d                   	pop    %ebp
80101d67:	c3                   	ret    

80101d68 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101d68:	55                   	push   %ebp
80101d69:	89 e5                	mov    %esp,%ebp
80101d6b:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101d6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d71:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101d75:	66 83 f8 03          	cmp    $0x3,%ax
80101d79:	75 60                	jne    80101ddb <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101d7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d82:	66 85 c0             	test   %ax,%ax
80101d85:	78 20                	js     80101da7 <readi+0x3f>
80101d87:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d8e:	66 83 f8 09          	cmp    $0x9,%ax
80101d92:	7f 13                	jg     80101da7 <readi+0x3f>
80101d94:	8b 45 08             	mov    0x8(%ebp),%eax
80101d97:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d9b:	98                   	cwtl   
80101d9c:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
80101da3:	85 c0                	test   %eax,%eax
80101da5:	75 0a                	jne    80101db1 <readi+0x49>
      return -1;
80101da7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101dac:	e9 19 01 00 00       	jmp    80101eca <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101db1:	8b 45 08             	mov    0x8(%ebp),%eax
80101db4:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101db8:	98                   	cwtl   
80101db9:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
80101dc0:	8b 55 14             	mov    0x14(%ebp),%edx
80101dc3:	89 54 24 08          	mov    %edx,0x8(%esp)
80101dc7:	8b 55 0c             	mov    0xc(%ebp),%edx
80101dca:	89 54 24 04          	mov    %edx,0x4(%esp)
80101dce:	8b 55 08             	mov    0x8(%ebp),%edx
80101dd1:	89 14 24             	mov    %edx,(%esp)
80101dd4:	ff d0                	call   *%eax
80101dd6:	e9 ef 00 00 00       	jmp    80101eca <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101ddb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dde:	8b 40 18             	mov    0x18(%eax),%eax
80101de1:	3b 45 10             	cmp    0x10(%ebp),%eax
80101de4:	72 0d                	jb     80101df3 <readi+0x8b>
80101de6:	8b 45 14             	mov    0x14(%ebp),%eax
80101de9:	8b 55 10             	mov    0x10(%ebp),%edx
80101dec:	01 d0                	add    %edx,%eax
80101dee:	3b 45 10             	cmp    0x10(%ebp),%eax
80101df1:	73 0a                	jae    80101dfd <readi+0x95>
    return -1;
80101df3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101df8:	e9 cd 00 00 00       	jmp    80101eca <readi+0x162>
  if(off + n > ip->size)
80101dfd:	8b 45 14             	mov    0x14(%ebp),%eax
80101e00:	8b 55 10             	mov    0x10(%ebp),%edx
80101e03:	01 c2                	add    %eax,%edx
80101e05:	8b 45 08             	mov    0x8(%ebp),%eax
80101e08:	8b 40 18             	mov    0x18(%eax),%eax
80101e0b:	39 c2                	cmp    %eax,%edx
80101e0d:	76 0c                	jbe    80101e1b <readi+0xb3>
    n = ip->size - off;
80101e0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e12:	8b 40 18             	mov    0x18(%eax),%eax
80101e15:	2b 45 10             	sub    0x10(%ebp),%eax
80101e18:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e1b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e22:	e9 94 00 00 00       	jmp    80101ebb <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e27:	8b 45 10             	mov    0x10(%ebp),%eax
80101e2a:	c1 e8 09             	shr    $0x9,%eax
80101e2d:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e31:	8b 45 08             	mov    0x8(%ebp),%eax
80101e34:	89 04 24             	mov    %eax,(%esp)
80101e37:	e8 c1 fc ff ff       	call   80101afd <bmap>
80101e3c:	8b 55 08             	mov    0x8(%ebp),%edx
80101e3f:	8b 12                	mov    (%edx),%edx
80101e41:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e45:	89 14 24             	mov    %edx,(%esp)
80101e48:	e8 59 e3 ff ff       	call   801001a6 <bread>
80101e4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101e50:	8b 45 10             	mov    0x10(%ebp),%eax
80101e53:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e58:	89 c2                	mov    %eax,%edx
80101e5a:	b8 00 02 00 00       	mov    $0x200,%eax
80101e5f:	29 d0                	sub    %edx,%eax
80101e61:	89 c2                	mov    %eax,%edx
80101e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e66:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101e69:	29 c1                	sub    %eax,%ecx
80101e6b:	89 c8                	mov    %ecx,%eax
80101e6d:	39 c2                	cmp    %eax,%edx
80101e6f:	0f 46 c2             	cmovbe %edx,%eax
80101e72:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101e75:	8b 45 10             	mov    0x10(%ebp),%eax
80101e78:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e7d:	8d 50 10             	lea    0x10(%eax),%edx
80101e80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e83:	01 d0                	add    %edx,%eax
80101e85:	8d 50 08             	lea    0x8(%eax),%edx
80101e88:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e8b:	89 44 24 08          	mov    %eax,0x8(%esp)
80101e8f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e93:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e96:	89 04 24             	mov    %eax,(%esp)
80101e99:	e8 96 32 00 00       	call   80105134 <memmove>
    brelse(bp);
80101e9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ea1:	89 04 24             	mov    %eax,(%esp)
80101ea4:	e8 6e e3 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ea9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eac:	01 45 f4             	add    %eax,-0xc(%ebp)
80101eaf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eb2:	01 45 10             	add    %eax,0x10(%ebp)
80101eb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eb8:	01 45 0c             	add    %eax,0xc(%ebp)
80101ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ebe:	3b 45 14             	cmp    0x14(%ebp),%eax
80101ec1:	0f 82 60 ff ff ff    	jb     80101e27 <readi+0xbf>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101ec7:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101eca:	c9                   	leave  
80101ecb:	c3                   	ret    

80101ecc <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101ecc:	55                   	push   %ebp
80101ecd:	89 e5                	mov    %esp,%ebp
80101ecf:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed5:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ed9:	66 83 f8 03          	cmp    $0x3,%ax
80101edd:	75 60                	jne    80101f3f <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101edf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee2:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ee6:	66 85 c0             	test   %ax,%ax
80101ee9:	78 20                	js     80101f0b <writei+0x3f>
80101eeb:	8b 45 08             	mov    0x8(%ebp),%eax
80101eee:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ef2:	66 83 f8 09          	cmp    $0x9,%ax
80101ef6:	7f 13                	jg     80101f0b <writei+0x3f>
80101ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80101efb:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101eff:	98                   	cwtl   
80101f00:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
80101f07:	85 c0                	test   %eax,%eax
80101f09:	75 0a                	jne    80101f15 <writei+0x49>
      return -1;
80101f0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f10:	e9 44 01 00 00       	jmp    80102059 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80101f15:	8b 45 08             	mov    0x8(%ebp),%eax
80101f18:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f1c:	98                   	cwtl   
80101f1d:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
80101f24:	8b 55 14             	mov    0x14(%ebp),%edx
80101f27:	89 54 24 08          	mov    %edx,0x8(%esp)
80101f2b:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f2e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f32:	8b 55 08             	mov    0x8(%ebp),%edx
80101f35:	89 14 24             	mov    %edx,(%esp)
80101f38:	ff d0                	call   *%eax
80101f3a:	e9 1a 01 00 00       	jmp    80102059 <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
80101f3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f42:	8b 40 18             	mov    0x18(%eax),%eax
80101f45:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f48:	72 0d                	jb     80101f57 <writei+0x8b>
80101f4a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f4d:	8b 55 10             	mov    0x10(%ebp),%edx
80101f50:	01 d0                	add    %edx,%eax
80101f52:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f55:	73 0a                	jae    80101f61 <writei+0x95>
    return -1;
80101f57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f5c:	e9 f8 00 00 00       	jmp    80102059 <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
80101f61:	8b 45 14             	mov    0x14(%ebp),%eax
80101f64:	8b 55 10             	mov    0x10(%ebp),%edx
80101f67:	01 d0                	add    %edx,%eax
80101f69:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101f6e:	76 0a                	jbe    80101f7a <writei+0xae>
    return -1;
80101f70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f75:	e9 df 00 00 00       	jmp    80102059 <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101f7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f81:	e9 9f 00 00 00       	jmp    80102025 <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f86:	8b 45 10             	mov    0x10(%ebp),%eax
80101f89:	c1 e8 09             	shr    $0x9,%eax
80101f8c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f90:	8b 45 08             	mov    0x8(%ebp),%eax
80101f93:	89 04 24             	mov    %eax,(%esp)
80101f96:	e8 62 fb ff ff       	call   80101afd <bmap>
80101f9b:	8b 55 08             	mov    0x8(%ebp),%edx
80101f9e:	8b 12                	mov    (%edx),%edx
80101fa0:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fa4:	89 14 24             	mov    %edx,(%esp)
80101fa7:	e8 fa e1 ff ff       	call   801001a6 <bread>
80101fac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101faf:	8b 45 10             	mov    0x10(%ebp),%eax
80101fb2:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fb7:	89 c2                	mov    %eax,%edx
80101fb9:	b8 00 02 00 00       	mov    $0x200,%eax
80101fbe:	29 d0                	sub    %edx,%eax
80101fc0:	89 c2                	mov    %eax,%edx
80101fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fc5:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101fc8:	29 c1                	sub    %eax,%ecx
80101fca:	89 c8                	mov    %ecx,%eax
80101fcc:	39 c2                	cmp    %eax,%edx
80101fce:	0f 46 c2             	cmovbe %edx,%eax
80101fd1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80101fd4:	8b 45 10             	mov    0x10(%ebp),%eax
80101fd7:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fdc:	8d 50 10             	lea    0x10(%eax),%edx
80101fdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fe2:	01 d0                	add    %edx,%eax
80101fe4:	8d 50 08             	lea    0x8(%eax),%edx
80101fe7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fea:	89 44 24 08          	mov    %eax,0x8(%esp)
80101fee:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ff1:	89 44 24 04          	mov    %eax,0x4(%esp)
80101ff5:	89 14 24             	mov    %edx,(%esp)
80101ff8:	e8 37 31 00 00       	call   80105134 <memmove>
    log_write(bp);
80101ffd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102000:	89 04 24             	mov    %eax,(%esp)
80102003:	e8 13 16 00 00       	call   8010361b <log_write>
    brelse(bp);
80102008:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010200b:	89 04 24             	mov    %eax,(%esp)
8010200e:	e8 04 e2 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102013:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102016:	01 45 f4             	add    %eax,-0xc(%ebp)
80102019:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010201c:	01 45 10             	add    %eax,0x10(%ebp)
8010201f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102022:	01 45 0c             	add    %eax,0xc(%ebp)
80102025:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102028:	3b 45 14             	cmp    0x14(%ebp),%eax
8010202b:	0f 82 55 ff ff ff    	jb     80101f86 <writei+0xba>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102031:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102035:	74 1f                	je     80102056 <writei+0x18a>
80102037:	8b 45 08             	mov    0x8(%ebp),%eax
8010203a:	8b 40 18             	mov    0x18(%eax),%eax
8010203d:	3b 45 10             	cmp    0x10(%ebp),%eax
80102040:	73 14                	jae    80102056 <writei+0x18a>
    ip->size = off;
80102042:	8b 45 08             	mov    0x8(%ebp),%eax
80102045:	8b 55 10             	mov    0x10(%ebp),%edx
80102048:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010204b:	8b 45 08             	mov    0x8(%ebp),%eax
8010204e:	89 04 24             	mov    %eax,(%esp)
80102051:	e8 49 f6 ff ff       	call   8010169f <iupdate>
  }
  return n;
80102056:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102059:	c9                   	leave  
8010205a:	c3                   	ret    

8010205b <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010205b:	55                   	push   %ebp
8010205c:	89 e5                	mov    %esp,%ebp
8010205e:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80102061:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102068:	00 
80102069:	8b 45 0c             	mov    0xc(%ebp),%eax
8010206c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102070:	8b 45 08             	mov    0x8(%ebp),%eax
80102073:	89 04 24             	mov    %eax,(%esp)
80102076:	e8 5c 31 00 00       	call   801051d7 <strncmp>
}
8010207b:	c9                   	leave  
8010207c:	c3                   	ret    

8010207d <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010207d:	55                   	push   %ebp
8010207e:	89 e5                	mov    %esp,%ebp
80102080:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102083:	8b 45 08             	mov    0x8(%ebp),%eax
80102086:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010208a:	66 83 f8 01          	cmp    $0x1,%ax
8010208e:	74 0c                	je     8010209c <dirlookup+0x1f>
    panic("dirlookup not DIR");
80102090:	c7 04 24 c5 87 10 80 	movl   $0x801087c5,(%esp)
80102097:	e8 9e e4 ff ff       	call   8010053a <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010209c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020a3:	e9 88 00 00 00       	jmp    80102130 <dirlookup+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801020a8:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801020af:	00 
801020b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020b3:	89 44 24 08          	mov    %eax,0x8(%esp)
801020b7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801020be:	8b 45 08             	mov    0x8(%ebp),%eax
801020c1:	89 04 24             	mov    %eax,(%esp)
801020c4:	e8 9f fc ff ff       	call   80101d68 <readi>
801020c9:	83 f8 10             	cmp    $0x10,%eax
801020cc:	74 0c                	je     801020da <dirlookup+0x5d>
      panic("dirlink read");
801020ce:	c7 04 24 d7 87 10 80 	movl   $0x801087d7,(%esp)
801020d5:	e8 60 e4 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
801020da:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801020de:	66 85 c0             	test   %ax,%ax
801020e1:	75 02                	jne    801020e5 <dirlookup+0x68>
      continue;
801020e3:	eb 47                	jmp    8010212c <dirlookup+0xaf>
    if(namecmp(name, de.name) == 0){
801020e5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020e8:	83 c0 02             	add    $0x2,%eax
801020eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801020ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801020f2:	89 04 24             	mov    %eax,(%esp)
801020f5:	e8 61 ff ff ff       	call   8010205b <namecmp>
801020fa:	85 c0                	test   %eax,%eax
801020fc:	75 2e                	jne    8010212c <dirlookup+0xaf>
      // entry matches path element
      if(poff)
801020fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102102:	74 08                	je     8010210c <dirlookup+0x8f>
        *poff = off;
80102104:	8b 45 10             	mov    0x10(%ebp),%eax
80102107:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010210a:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010210c:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102110:	0f b7 c0             	movzwl %ax,%eax
80102113:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102116:	8b 45 08             	mov    0x8(%ebp),%eax
80102119:	8b 00                	mov    (%eax),%eax
8010211b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010211e:	89 54 24 04          	mov    %edx,0x4(%esp)
80102122:	89 04 24             	mov    %eax,(%esp)
80102125:	e8 2d f6 ff ff       	call   80101757 <iget>
8010212a:	eb 18                	jmp    80102144 <dirlookup+0xc7>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010212c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102130:	8b 45 08             	mov    0x8(%ebp),%eax
80102133:	8b 40 18             	mov    0x18(%eax),%eax
80102136:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102139:	0f 87 69 ff ff ff    	ja     801020a8 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010213f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102144:	c9                   	leave  
80102145:	c3                   	ret    

80102146 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102146:	55                   	push   %ebp
80102147:	89 e5                	mov    %esp,%ebp
80102149:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010214c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102153:	00 
80102154:	8b 45 0c             	mov    0xc(%ebp),%eax
80102157:	89 44 24 04          	mov    %eax,0x4(%esp)
8010215b:	8b 45 08             	mov    0x8(%ebp),%eax
8010215e:	89 04 24             	mov    %eax,(%esp)
80102161:	e8 17 ff ff ff       	call   8010207d <dirlookup>
80102166:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102169:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010216d:	74 15                	je     80102184 <dirlink+0x3e>
    iput(ip);
8010216f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102172:	89 04 24             	mov    %eax,(%esp)
80102175:	e8 94 f8 ff ff       	call   80101a0e <iput>
    return -1;
8010217a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010217f:	e9 b7 00 00 00       	jmp    8010223b <dirlink+0xf5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102184:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010218b:	eb 46                	jmp    801021d3 <dirlink+0x8d>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010218d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102190:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102197:	00 
80102198:	89 44 24 08          	mov    %eax,0x8(%esp)
8010219c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010219f:	89 44 24 04          	mov    %eax,0x4(%esp)
801021a3:	8b 45 08             	mov    0x8(%ebp),%eax
801021a6:	89 04 24             	mov    %eax,(%esp)
801021a9:	e8 ba fb ff ff       	call   80101d68 <readi>
801021ae:	83 f8 10             	cmp    $0x10,%eax
801021b1:	74 0c                	je     801021bf <dirlink+0x79>
      panic("dirlink read");
801021b3:	c7 04 24 d7 87 10 80 	movl   $0x801087d7,(%esp)
801021ba:	e8 7b e3 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
801021bf:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021c3:	66 85 c0             	test   %ax,%ax
801021c6:	75 02                	jne    801021ca <dirlink+0x84>
      break;
801021c8:	eb 16                	jmp    801021e0 <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801021ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021cd:	83 c0 10             	add    $0x10,%eax
801021d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801021d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021d6:	8b 45 08             	mov    0x8(%ebp),%eax
801021d9:	8b 40 18             	mov    0x18(%eax),%eax
801021dc:	39 c2                	cmp    %eax,%edx
801021de:	72 ad                	jb     8010218d <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
801021e0:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801021e7:	00 
801021e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801021eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801021ef:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021f2:	83 c0 02             	add    $0x2,%eax
801021f5:	89 04 24             	mov    %eax,(%esp)
801021f8:	e8 30 30 00 00       	call   8010522d <strncpy>
  de.inum = inum;
801021fd:	8b 45 10             	mov    0x10(%ebp),%eax
80102200:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102204:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102207:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010220e:	00 
8010220f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102213:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102216:	89 44 24 04          	mov    %eax,0x4(%esp)
8010221a:	8b 45 08             	mov    0x8(%ebp),%eax
8010221d:	89 04 24             	mov    %eax,(%esp)
80102220:	e8 a7 fc ff ff       	call   80101ecc <writei>
80102225:	83 f8 10             	cmp    $0x10,%eax
80102228:	74 0c                	je     80102236 <dirlink+0xf0>
    panic("dirlink");
8010222a:	c7 04 24 e4 87 10 80 	movl   $0x801087e4,(%esp)
80102231:	e8 04 e3 ff ff       	call   8010053a <panic>
  
  return 0;
80102236:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010223b:	c9                   	leave  
8010223c:	c3                   	ret    

8010223d <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010223d:	55                   	push   %ebp
8010223e:	89 e5                	mov    %esp,%ebp
80102240:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102243:	eb 04                	jmp    80102249 <skipelem+0xc>
    path++;
80102245:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102249:	8b 45 08             	mov    0x8(%ebp),%eax
8010224c:	0f b6 00             	movzbl (%eax),%eax
8010224f:	3c 2f                	cmp    $0x2f,%al
80102251:	74 f2                	je     80102245 <skipelem+0x8>
    path++;
  if(*path == 0)
80102253:	8b 45 08             	mov    0x8(%ebp),%eax
80102256:	0f b6 00             	movzbl (%eax),%eax
80102259:	84 c0                	test   %al,%al
8010225b:	75 0a                	jne    80102267 <skipelem+0x2a>
    return 0;
8010225d:	b8 00 00 00 00       	mov    $0x0,%eax
80102262:	e9 86 00 00 00       	jmp    801022ed <skipelem+0xb0>
  s = path;
80102267:	8b 45 08             	mov    0x8(%ebp),%eax
8010226a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010226d:	eb 04                	jmp    80102273 <skipelem+0x36>
    path++;
8010226f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102273:	8b 45 08             	mov    0x8(%ebp),%eax
80102276:	0f b6 00             	movzbl (%eax),%eax
80102279:	3c 2f                	cmp    $0x2f,%al
8010227b:	74 0a                	je     80102287 <skipelem+0x4a>
8010227d:	8b 45 08             	mov    0x8(%ebp),%eax
80102280:	0f b6 00             	movzbl (%eax),%eax
80102283:	84 c0                	test   %al,%al
80102285:	75 e8                	jne    8010226f <skipelem+0x32>
    path++;
  len = path - s;
80102287:	8b 55 08             	mov    0x8(%ebp),%edx
8010228a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010228d:	29 c2                	sub    %eax,%edx
8010228f:	89 d0                	mov    %edx,%eax
80102291:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102294:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102298:	7e 1c                	jle    801022b6 <skipelem+0x79>
    memmove(name, s, DIRSIZ);
8010229a:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801022a1:	00 
801022a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801022a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801022ac:	89 04 24             	mov    %eax,(%esp)
801022af:	e8 80 2e 00 00       	call   80105134 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022b4:	eb 2a                	jmp    801022e0 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801022b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022b9:	89 44 24 08          	mov    %eax,0x8(%esp)
801022bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801022c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801022c7:	89 04 24             	mov    %eax,(%esp)
801022ca:	e8 65 2e 00 00       	call   80105134 <memmove>
    name[len] = 0;
801022cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801022d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801022d5:	01 d0                	add    %edx,%eax
801022d7:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801022da:	eb 04                	jmp    801022e0 <skipelem+0xa3>
    path++;
801022dc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022e0:	8b 45 08             	mov    0x8(%ebp),%eax
801022e3:	0f b6 00             	movzbl (%eax),%eax
801022e6:	3c 2f                	cmp    $0x2f,%al
801022e8:	74 f2                	je     801022dc <skipelem+0x9f>
    path++;
  return path;
801022ea:	8b 45 08             	mov    0x8(%ebp),%eax
}
801022ed:	c9                   	leave  
801022ee:	c3                   	ret    

801022ef <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801022ef:	55                   	push   %ebp
801022f0:	89 e5                	mov    %esp,%ebp
801022f2:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
801022f5:	8b 45 08             	mov    0x8(%ebp),%eax
801022f8:	0f b6 00             	movzbl (%eax),%eax
801022fb:	3c 2f                	cmp    $0x2f,%al
801022fd:	75 1c                	jne    8010231b <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
801022ff:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102306:	00 
80102307:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010230e:	e8 44 f4 ff ff       	call   80101757 <iget>
80102313:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102316:	e9 af 00 00 00       	jmp    801023ca <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
8010231b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102321:	8b 40 68             	mov    0x68(%eax),%eax
80102324:	89 04 24             	mov    %eax,(%esp)
80102327:	e8 fd f4 ff ff       	call   80101829 <idup>
8010232c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010232f:	e9 96 00 00 00       	jmp    801023ca <namex+0xdb>
    ilock(ip);
80102334:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102337:	89 04 24             	mov    %eax,(%esp)
8010233a:	e8 1c f5 ff ff       	call   8010185b <ilock>
    if(ip->type != T_DIR){
8010233f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102342:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102346:	66 83 f8 01          	cmp    $0x1,%ax
8010234a:	74 15                	je     80102361 <namex+0x72>
      iunlockput(ip);
8010234c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010234f:	89 04 24             	mov    %eax,(%esp)
80102352:	e8 88 f7 ff ff       	call   80101adf <iunlockput>
      return 0;
80102357:	b8 00 00 00 00       	mov    $0x0,%eax
8010235c:	e9 a3 00 00 00       	jmp    80102404 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
80102361:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102365:	74 1d                	je     80102384 <namex+0x95>
80102367:	8b 45 08             	mov    0x8(%ebp),%eax
8010236a:	0f b6 00             	movzbl (%eax),%eax
8010236d:	84 c0                	test   %al,%al
8010236f:	75 13                	jne    80102384 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
80102371:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102374:	89 04 24             	mov    %eax,(%esp)
80102377:	e8 2d f6 ff ff       	call   801019a9 <iunlock>
      return ip;
8010237c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010237f:	e9 80 00 00 00       	jmp    80102404 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102384:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010238b:	00 
8010238c:	8b 45 10             	mov    0x10(%ebp),%eax
8010238f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102396:	89 04 24             	mov    %eax,(%esp)
80102399:	e8 df fc ff ff       	call   8010207d <dirlookup>
8010239e:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023a5:	75 12                	jne    801023b9 <namex+0xca>
      iunlockput(ip);
801023a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023aa:	89 04 24             	mov    %eax,(%esp)
801023ad:	e8 2d f7 ff ff       	call   80101adf <iunlockput>
      return 0;
801023b2:	b8 00 00 00 00       	mov    $0x0,%eax
801023b7:	eb 4b                	jmp    80102404 <namex+0x115>
    }
    iunlockput(ip);
801023b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023bc:	89 04 24             	mov    %eax,(%esp)
801023bf:	e8 1b f7 ff ff       	call   80101adf <iunlockput>
    ip = next;
801023c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801023ca:	8b 45 10             	mov    0x10(%ebp),%eax
801023cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801023d1:	8b 45 08             	mov    0x8(%ebp),%eax
801023d4:	89 04 24             	mov    %eax,(%esp)
801023d7:	e8 61 fe ff ff       	call   8010223d <skipelem>
801023dc:	89 45 08             	mov    %eax,0x8(%ebp)
801023df:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801023e3:	0f 85 4b ff ff ff    	jne    80102334 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801023e9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801023ed:	74 12                	je     80102401 <namex+0x112>
    iput(ip);
801023ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f2:	89 04 24             	mov    %eax,(%esp)
801023f5:	e8 14 f6 ff ff       	call   80101a0e <iput>
    return 0;
801023fa:	b8 00 00 00 00       	mov    $0x0,%eax
801023ff:	eb 03                	jmp    80102404 <namex+0x115>
  }
  return ip;
80102401:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102404:	c9                   	leave  
80102405:	c3                   	ret    

80102406 <namei>:

struct inode*
namei(char *path)
{
80102406:	55                   	push   %ebp
80102407:	89 e5                	mov    %esp,%ebp
80102409:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010240c:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010240f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102413:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010241a:	00 
8010241b:	8b 45 08             	mov    0x8(%ebp),%eax
8010241e:	89 04 24             	mov    %eax,(%esp)
80102421:	e8 c9 fe ff ff       	call   801022ef <namex>
}
80102426:	c9                   	leave  
80102427:	c3                   	ret    

80102428 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102428:	55                   	push   %ebp
80102429:	89 e5                	mov    %esp,%ebp
8010242b:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
8010242e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102431:	89 44 24 08          	mov    %eax,0x8(%esp)
80102435:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010243c:	00 
8010243d:	8b 45 08             	mov    0x8(%ebp),%eax
80102440:	89 04 24             	mov    %eax,(%esp)
80102443:	e8 a7 fe ff ff       	call   801022ef <namex>
}
80102448:	c9                   	leave  
80102449:	c3                   	ret    

8010244a <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010244a:	55                   	push   %ebp
8010244b:	89 e5                	mov    %esp,%ebp
8010244d:	83 ec 14             	sub    $0x14,%esp
80102450:	8b 45 08             	mov    0x8(%ebp),%eax
80102453:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102457:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010245b:	89 c2                	mov    %eax,%edx
8010245d:	ec                   	in     (%dx),%al
8010245e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102461:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102465:	c9                   	leave  
80102466:	c3                   	ret    

80102467 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102467:	55                   	push   %ebp
80102468:	89 e5                	mov    %esp,%ebp
8010246a:	57                   	push   %edi
8010246b:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010246c:	8b 55 08             	mov    0x8(%ebp),%edx
8010246f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102472:	8b 45 10             	mov    0x10(%ebp),%eax
80102475:	89 cb                	mov    %ecx,%ebx
80102477:	89 df                	mov    %ebx,%edi
80102479:	89 c1                	mov    %eax,%ecx
8010247b:	fc                   	cld    
8010247c:	f3 6d                	rep insl (%dx),%es:(%edi)
8010247e:	89 c8                	mov    %ecx,%eax
80102480:	89 fb                	mov    %edi,%ebx
80102482:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102485:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102488:	5b                   	pop    %ebx
80102489:	5f                   	pop    %edi
8010248a:	5d                   	pop    %ebp
8010248b:	c3                   	ret    

8010248c <outb>:

static inline void
outb(ushort port, uchar data)
{
8010248c:	55                   	push   %ebp
8010248d:	89 e5                	mov    %esp,%ebp
8010248f:	83 ec 08             	sub    $0x8,%esp
80102492:	8b 55 08             	mov    0x8(%ebp),%edx
80102495:	8b 45 0c             	mov    0xc(%ebp),%eax
80102498:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010249c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010249f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801024a3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801024a7:	ee                   	out    %al,(%dx)
}
801024a8:	c9                   	leave  
801024a9:	c3                   	ret    

801024aa <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801024aa:	55                   	push   %ebp
801024ab:	89 e5                	mov    %esp,%ebp
801024ad:	56                   	push   %esi
801024ae:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801024af:	8b 55 08             	mov    0x8(%ebp),%edx
801024b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024b5:	8b 45 10             	mov    0x10(%ebp),%eax
801024b8:	89 cb                	mov    %ecx,%ebx
801024ba:	89 de                	mov    %ebx,%esi
801024bc:	89 c1                	mov    %eax,%ecx
801024be:	fc                   	cld    
801024bf:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801024c1:	89 c8                	mov    %ecx,%eax
801024c3:	89 f3                	mov    %esi,%ebx
801024c5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024c8:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801024cb:	5b                   	pop    %ebx
801024cc:	5e                   	pop    %esi
801024cd:	5d                   	pop    %ebp
801024ce:	c3                   	ret    

801024cf <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801024cf:	55                   	push   %ebp
801024d0:	89 e5                	mov    %esp,%ebp
801024d2:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801024d5:	90                   	nop
801024d6:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801024dd:	e8 68 ff ff ff       	call   8010244a <inb>
801024e2:	0f b6 c0             	movzbl %al,%eax
801024e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
801024e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801024eb:	25 c0 00 00 00       	and    $0xc0,%eax
801024f0:	83 f8 40             	cmp    $0x40,%eax
801024f3:	75 e1                	jne    801024d6 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801024f5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024f9:	74 11                	je     8010250c <idewait+0x3d>
801024fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801024fe:	83 e0 21             	and    $0x21,%eax
80102501:	85 c0                	test   %eax,%eax
80102503:	74 07                	je     8010250c <idewait+0x3d>
    return -1;
80102505:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010250a:	eb 05                	jmp    80102511 <idewait+0x42>
  return 0;
8010250c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102511:	c9                   	leave  
80102512:	c3                   	ret    

80102513 <ideinit>:

void
ideinit(void)
{
80102513:	55                   	push   %ebp
80102514:	89 e5                	mov    %esp,%ebp
80102516:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102519:	c7 44 24 04 ec 87 10 	movl   $0x801087ec,0x4(%esp)
80102520:	80 
80102521:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102528:	e8 c3 28 00 00       	call   80104df0 <initlock>
  picenable(IRQ_IDE);
8010252d:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102534:	e8 99 18 00 00       	call   80103dd2 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102539:	a1 c0 29 11 80       	mov    0x801129c0,%eax
8010253e:	83 e8 01             	sub    $0x1,%eax
80102541:	89 44 24 04          	mov    %eax,0x4(%esp)
80102545:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010254c:	e8 0c 04 00 00       	call   8010295d <ioapicenable>
  idewait(0);
80102551:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102558:	e8 72 ff ff ff       	call   801024cf <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010255d:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102564:	00 
80102565:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010256c:	e8 1b ff ff ff       	call   8010248c <outb>
  for(i=0; i<1000; i++){
80102571:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102578:	eb 20                	jmp    8010259a <ideinit+0x87>
    if(inb(0x1f7) != 0){
8010257a:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102581:	e8 c4 fe ff ff       	call   8010244a <inb>
80102586:	84 c0                	test   %al,%al
80102588:	74 0c                	je     80102596 <ideinit+0x83>
      havedisk1 = 1;
8010258a:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
80102591:	00 00 00 
      break;
80102594:	eb 0d                	jmp    801025a3 <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102596:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010259a:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801025a1:	7e d7                	jle    8010257a <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801025a3:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801025aa:	00 
801025ab:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025b2:	e8 d5 fe ff ff       	call   8010248c <outb>
}
801025b7:	c9                   	leave  
801025b8:	c3                   	ret    

801025b9 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801025b9:	55                   	push   %ebp
801025ba:	89 e5                	mov    %esp,%ebp
801025bc:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801025bf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025c3:	75 0c                	jne    801025d1 <idestart+0x18>
    panic("idestart");
801025c5:	c7 04 24 f0 87 10 80 	movl   $0x801087f0,(%esp)
801025cc:	e8 69 df ff ff       	call   8010053a <panic>

  idewait(0);
801025d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801025d8:	e8 f2 fe ff ff       	call   801024cf <idewait>
  outb(0x3f6, 0);  // generate interrupt
801025dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801025e4:	00 
801025e5:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
801025ec:	e8 9b fe ff ff       	call   8010248c <outb>
  outb(0x1f2, 1);  // number of sectors
801025f1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801025f8:	00 
801025f9:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102600:	e8 87 fe ff ff       	call   8010248c <outb>
  outb(0x1f3, b->sector & 0xff);
80102605:	8b 45 08             	mov    0x8(%ebp),%eax
80102608:	8b 40 08             	mov    0x8(%eax),%eax
8010260b:	0f b6 c0             	movzbl %al,%eax
8010260e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102612:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102619:	e8 6e fe ff ff       	call   8010248c <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
8010261e:	8b 45 08             	mov    0x8(%ebp),%eax
80102621:	8b 40 08             	mov    0x8(%eax),%eax
80102624:	c1 e8 08             	shr    $0x8,%eax
80102627:	0f b6 c0             	movzbl %al,%eax
8010262a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010262e:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102635:	e8 52 fe ff ff       	call   8010248c <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
8010263a:	8b 45 08             	mov    0x8(%ebp),%eax
8010263d:	8b 40 08             	mov    0x8(%eax),%eax
80102640:	c1 e8 10             	shr    $0x10,%eax
80102643:	0f b6 c0             	movzbl %al,%eax
80102646:	89 44 24 04          	mov    %eax,0x4(%esp)
8010264a:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102651:	e8 36 fe ff ff       	call   8010248c <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102656:	8b 45 08             	mov    0x8(%ebp),%eax
80102659:	8b 40 04             	mov    0x4(%eax),%eax
8010265c:	83 e0 01             	and    $0x1,%eax
8010265f:	c1 e0 04             	shl    $0x4,%eax
80102662:	89 c2                	mov    %eax,%edx
80102664:	8b 45 08             	mov    0x8(%ebp),%eax
80102667:	8b 40 08             	mov    0x8(%eax),%eax
8010266a:	c1 e8 18             	shr    $0x18,%eax
8010266d:	83 e0 0f             	and    $0xf,%eax
80102670:	09 d0                	or     %edx,%eax
80102672:	83 c8 e0             	or     $0xffffffe0,%eax
80102675:	0f b6 c0             	movzbl %al,%eax
80102678:	89 44 24 04          	mov    %eax,0x4(%esp)
8010267c:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102683:	e8 04 fe ff ff       	call   8010248c <outb>
  if(b->flags & B_DIRTY){
80102688:	8b 45 08             	mov    0x8(%ebp),%eax
8010268b:	8b 00                	mov    (%eax),%eax
8010268d:	83 e0 04             	and    $0x4,%eax
80102690:	85 c0                	test   %eax,%eax
80102692:	74 34                	je     801026c8 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
80102694:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
8010269b:	00 
8010269c:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026a3:	e8 e4 fd ff ff       	call   8010248c <outb>
    outsl(0x1f0, b->data, 512/4);
801026a8:	8b 45 08             	mov    0x8(%ebp),%eax
801026ab:	83 c0 18             	add    $0x18,%eax
801026ae:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801026b5:	00 
801026b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801026ba:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801026c1:	e8 e4 fd ff ff       	call   801024aa <outsl>
801026c6:	eb 14                	jmp    801026dc <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
801026c8:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
801026cf:	00 
801026d0:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026d7:	e8 b0 fd ff ff       	call   8010248c <outb>
  }
}
801026dc:	c9                   	leave  
801026dd:	c3                   	ret    

801026de <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801026de:	55                   	push   %ebp
801026df:	89 e5                	mov    %esp,%ebp
801026e1:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801026e4:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801026eb:	e8 21 27 00 00       	call   80104e11 <acquire>
  if((b = idequeue) == 0){
801026f0:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801026f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801026f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801026fc:	75 11                	jne    8010270f <ideintr+0x31>
    release(&idelock);
801026fe:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102705:	e8 69 27 00 00       	call   80104e73 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
8010270a:	e9 90 00 00 00       	jmp    8010279f <ideintr+0xc1>
  }
  idequeue = b->qnext;
8010270f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102712:	8b 40 14             	mov    0x14(%eax),%eax
80102715:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010271a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010271d:	8b 00                	mov    (%eax),%eax
8010271f:	83 e0 04             	and    $0x4,%eax
80102722:	85 c0                	test   %eax,%eax
80102724:	75 2e                	jne    80102754 <ideintr+0x76>
80102726:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010272d:	e8 9d fd ff ff       	call   801024cf <idewait>
80102732:	85 c0                	test   %eax,%eax
80102734:	78 1e                	js     80102754 <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102736:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102739:	83 c0 18             	add    $0x18,%eax
8010273c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102743:	00 
80102744:	89 44 24 04          	mov    %eax,0x4(%esp)
80102748:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010274f:	e8 13 fd ff ff       	call   80102467 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102757:	8b 00                	mov    (%eax),%eax
80102759:	83 c8 02             	or     $0x2,%eax
8010275c:	89 c2                	mov    %eax,%edx
8010275e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102761:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102763:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102766:	8b 00                	mov    (%eax),%eax
80102768:	83 e0 fb             	and    $0xfffffffb,%eax
8010276b:	89 c2                	mov    %eax,%edx
8010276d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102770:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102775:	89 04 24             	mov    %eax,(%esp)
80102778:	e8 a3 24 00 00       	call   80104c20 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010277d:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102782:	85 c0                	test   %eax,%eax
80102784:	74 0d                	je     80102793 <ideintr+0xb5>
    idestart(idequeue);
80102786:	a1 34 b6 10 80       	mov    0x8010b634,%eax
8010278b:	89 04 24             	mov    %eax,(%esp)
8010278e:	e8 26 fe ff ff       	call   801025b9 <idestart>

  release(&idelock);
80102793:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
8010279a:	e8 d4 26 00 00       	call   80104e73 <release>
}
8010279f:	c9                   	leave  
801027a0:	c3                   	ret    

801027a1 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801027a1:	55                   	push   %ebp
801027a2:	89 e5                	mov    %esp,%ebp
801027a4:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801027a7:	8b 45 08             	mov    0x8(%ebp),%eax
801027aa:	8b 00                	mov    (%eax),%eax
801027ac:	83 e0 01             	and    $0x1,%eax
801027af:	85 c0                	test   %eax,%eax
801027b1:	75 0c                	jne    801027bf <iderw+0x1e>
    panic("iderw: buf not busy");
801027b3:	c7 04 24 f9 87 10 80 	movl   $0x801087f9,(%esp)
801027ba:	e8 7b dd ff ff       	call   8010053a <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801027bf:	8b 45 08             	mov    0x8(%ebp),%eax
801027c2:	8b 00                	mov    (%eax),%eax
801027c4:	83 e0 06             	and    $0x6,%eax
801027c7:	83 f8 02             	cmp    $0x2,%eax
801027ca:	75 0c                	jne    801027d8 <iderw+0x37>
    panic("iderw: nothing to do");
801027cc:	c7 04 24 0d 88 10 80 	movl   $0x8010880d,(%esp)
801027d3:	e8 62 dd ff ff       	call   8010053a <panic>
  if(b->dev != 0 && !havedisk1)
801027d8:	8b 45 08             	mov    0x8(%ebp),%eax
801027db:	8b 40 04             	mov    0x4(%eax),%eax
801027de:	85 c0                	test   %eax,%eax
801027e0:	74 15                	je     801027f7 <iderw+0x56>
801027e2:	a1 38 b6 10 80       	mov    0x8010b638,%eax
801027e7:	85 c0                	test   %eax,%eax
801027e9:	75 0c                	jne    801027f7 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
801027eb:	c7 04 24 22 88 10 80 	movl   $0x80108822,(%esp)
801027f2:	e8 43 dd ff ff       	call   8010053a <panic>

  acquire(&idelock);  //DOC:acquire-lock
801027f7:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801027fe:	e8 0e 26 00 00       	call   80104e11 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102803:	8b 45 08             	mov    0x8(%ebp),%eax
80102806:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010280d:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
80102814:	eb 0b                	jmp    80102821 <iderw+0x80>
80102816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102819:	8b 00                	mov    (%eax),%eax
8010281b:	83 c0 14             	add    $0x14,%eax
8010281e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102821:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102824:	8b 00                	mov    (%eax),%eax
80102826:	85 c0                	test   %eax,%eax
80102828:	75 ec                	jne    80102816 <iderw+0x75>
    ;
  *pp = b;
8010282a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282d:	8b 55 08             	mov    0x8(%ebp),%edx
80102830:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102832:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102837:	3b 45 08             	cmp    0x8(%ebp),%eax
8010283a:	75 0d                	jne    80102849 <iderw+0xa8>
    idestart(b);
8010283c:	8b 45 08             	mov    0x8(%ebp),%eax
8010283f:	89 04 24             	mov    %eax,(%esp)
80102842:	e8 72 fd ff ff       	call   801025b9 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102847:	eb 15                	jmp    8010285e <iderw+0xbd>
80102849:	eb 13                	jmp    8010285e <iderw+0xbd>
    sleep(b, &idelock);
8010284b:	c7 44 24 04 00 b6 10 	movl   $0x8010b600,0x4(%esp)
80102852:	80 
80102853:	8b 45 08             	mov    0x8(%ebp),%eax
80102856:	89 04 24             	mov    %eax,(%esp)
80102859:	e8 e9 22 00 00       	call   80104b47 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010285e:	8b 45 08             	mov    0x8(%ebp),%eax
80102861:	8b 00                	mov    (%eax),%eax
80102863:	83 e0 06             	and    $0x6,%eax
80102866:	83 f8 02             	cmp    $0x2,%eax
80102869:	75 e0                	jne    8010284b <iderw+0xaa>
    sleep(b, &idelock);
  }

  release(&idelock);
8010286b:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102872:	e8 fc 25 00 00       	call   80104e73 <release>
}
80102877:	c9                   	leave  
80102878:	c3                   	ret    

80102879 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102879:	55                   	push   %ebp
8010287a:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010287c:	a1 14 22 11 80       	mov    0x80112214,%eax
80102881:	8b 55 08             	mov    0x8(%ebp),%edx
80102884:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102886:	a1 14 22 11 80       	mov    0x80112214,%eax
8010288b:	8b 40 10             	mov    0x10(%eax),%eax
}
8010288e:	5d                   	pop    %ebp
8010288f:	c3                   	ret    

80102890 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102890:	55                   	push   %ebp
80102891:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102893:	a1 14 22 11 80       	mov    0x80112214,%eax
80102898:	8b 55 08             	mov    0x8(%ebp),%edx
8010289b:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010289d:	a1 14 22 11 80       	mov    0x80112214,%eax
801028a2:	8b 55 0c             	mov    0xc(%ebp),%edx
801028a5:	89 50 10             	mov    %edx,0x10(%eax)
}
801028a8:	5d                   	pop    %ebp
801028a9:	c3                   	ret    

801028aa <ioapicinit>:

void
ioapicinit(void)
{
801028aa:	55                   	push   %ebp
801028ab:	89 e5                	mov    %esp,%ebp
801028ad:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
801028b0:	a1 44 23 11 80       	mov    0x80112344,%eax
801028b5:	85 c0                	test   %eax,%eax
801028b7:	75 05                	jne    801028be <ioapicinit+0x14>
    return;
801028b9:	e9 9d 00 00 00       	jmp    8010295b <ioapicinit+0xb1>

  ioapic = (volatile struct ioapic*)IOAPIC;
801028be:	c7 05 14 22 11 80 00 	movl   $0xfec00000,0x80112214
801028c5:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801028c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801028cf:	e8 a5 ff ff ff       	call   80102879 <ioapicread>
801028d4:	c1 e8 10             	shr    $0x10,%eax
801028d7:	25 ff 00 00 00       	and    $0xff,%eax
801028dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801028df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801028e6:	e8 8e ff ff ff       	call   80102879 <ioapicread>
801028eb:	c1 e8 18             	shr    $0x18,%eax
801028ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801028f1:	0f b6 05 40 23 11 80 	movzbl 0x80112340,%eax
801028f8:	0f b6 c0             	movzbl %al,%eax
801028fb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801028fe:	74 0c                	je     8010290c <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102900:	c7 04 24 40 88 10 80 	movl   $0x80108840,(%esp)
80102907:	e8 94 da ff ff       	call   801003a0 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010290c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102913:	eb 3e                	jmp    80102953 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102915:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102918:	83 c0 20             	add    $0x20,%eax
8010291b:	0d 00 00 01 00       	or     $0x10000,%eax
80102920:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102923:	83 c2 08             	add    $0x8,%edx
80102926:	01 d2                	add    %edx,%edx
80102928:	89 44 24 04          	mov    %eax,0x4(%esp)
8010292c:	89 14 24             	mov    %edx,(%esp)
8010292f:	e8 5c ff ff ff       	call   80102890 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102934:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102937:	83 c0 08             	add    $0x8,%eax
8010293a:	01 c0                	add    %eax,%eax
8010293c:	83 c0 01             	add    $0x1,%eax
8010293f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102946:	00 
80102947:	89 04 24             	mov    %eax,(%esp)
8010294a:	e8 41 ff ff ff       	call   80102890 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010294f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102956:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102959:	7e ba                	jle    80102915 <ioapicinit+0x6b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010295b:	c9                   	leave  
8010295c:	c3                   	ret    

8010295d <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010295d:	55                   	push   %ebp
8010295e:	89 e5                	mov    %esp,%ebp
80102960:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102963:	a1 44 23 11 80       	mov    0x80112344,%eax
80102968:	85 c0                	test   %eax,%eax
8010296a:	75 02                	jne    8010296e <ioapicenable+0x11>
    return;
8010296c:	eb 37                	jmp    801029a5 <ioapicenable+0x48>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010296e:	8b 45 08             	mov    0x8(%ebp),%eax
80102971:	83 c0 20             	add    $0x20,%eax
80102974:	8b 55 08             	mov    0x8(%ebp),%edx
80102977:	83 c2 08             	add    $0x8,%edx
8010297a:	01 d2                	add    %edx,%edx
8010297c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102980:	89 14 24             	mov    %edx,(%esp)
80102983:	e8 08 ff ff ff       	call   80102890 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102988:	8b 45 0c             	mov    0xc(%ebp),%eax
8010298b:	c1 e0 18             	shl    $0x18,%eax
8010298e:	8b 55 08             	mov    0x8(%ebp),%edx
80102991:	83 c2 08             	add    $0x8,%edx
80102994:	01 d2                	add    %edx,%edx
80102996:	83 c2 01             	add    $0x1,%edx
80102999:	89 44 24 04          	mov    %eax,0x4(%esp)
8010299d:	89 14 24             	mov    %edx,(%esp)
801029a0:	e8 eb fe ff ff       	call   80102890 <ioapicwrite>
}
801029a5:	c9                   	leave  
801029a6:	c3                   	ret    

801029a7 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801029a7:	55                   	push   %ebp
801029a8:	89 e5                	mov    %esp,%ebp
801029aa:	8b 45 08             	mov    0x8(%ebp),%eax
801029ad:	05 00 00 00 80       	add    $0x80000000,%eax
801029b2:	5d                   	pop    %ebp
801029b3:	c3                   	ret    

801029b4 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801029b4:	55                   	push   %ebp
801029b5:	89 e5                	mov    %esp,%ebp
801029b7:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
801029ba:	c7 44 24 04 72 88 10 	movl   $0x80108872,0x4(%esp)
801029c1:	80 
801029c2:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
801029c9:	e8 22 24 00 00       	call   80104df0 <initlock>
  kmem.use_lock = 0;
801029ce:	c7 05 54 22 11 80 00 	movl   $0x0,0x80112254
801029d5:	00 00 00 
  freerange(vstart, vend);
801029d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801029db:	89 44 24 04          	mov    %eax,0x4(%esp)
801029df:	8b 45 08             	mov    0x8(%ebp),%eax
801029e2:	89 04 24             	mov    %eax,(%esp)
801029e5:	e8 26 00 00 00       	call   80102a10 <freerange>
}
801029ea:	c9                   	leave  
801029eb:	c3                   	ret    

801029ec <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801029ec:	55                   	push   %ebp
801029ed:	89 e5                	mov    %esp,%ebp
801029ef:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
801029f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801029f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801029f9:	8b 45 08             	mov    0x8(%ebp),%eax
801029fc:	89 04 24             	mov    %eax,(%esp)
801029ff:	e8 0c 00 00 00       	call   80102a10 <freerange>
  kmem.use_lock = 1;
80102a04:	c7 05 54 22 11 80 01 	movl   $0x1,0x80112254
80102a0b:	00 00 00 
}
80102a0e:	c9                   	leave  
80102a0f:	c3                   	ret    

80102a10 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102a10:	55                   	push   %ebp
80102a11:	89 e5                	mov    %esp,%ebp
80102a13:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102a16:	8b 45 08             	mov    0x8(%ebp),%eax
80102a19:	05 ff 0f 00 00       	add    $0xfff,%eax
80102a1e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102a23:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a26:	eb 12                	jmp    80102a3a <freerange+0x2a>
    kfree(p);
80102a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a2b:	89 04 24             	mov    %eax,(%esp)
80102a2e:	e8 16 00 00 00       	call   80102a49 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a33:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a3d:	05 00 10 00 00       	add    $0x1000,%eax
80102a42:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102a45:	76 e1                	jbe    80102a28 <freerange+0x18>
    kfree(p);
}
80102a47:	c9                   	leave  
80102a48:	c3                   	ret    

80102a49 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102a49:	55                   	push   %ebp
80102a4a:	89 e5                	mov    %esp,%ebp
80102a4c:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102a4f:	8b 45 08             	mov    0x8(%ebp),%eax
80102a52:	25 ff 0f 00 00       	and    $0xfff,%eax
80102a57:	85 c0                	test   %eax,%eax
80102a59:	75 1b                	jne    80102a76 <kfree+0x2d>
80102a5b:	81 7d 08 b8 51 11 80 	cmpl   $0x801151b8,0x8(%ebp)
80102a62:	72 12                	jb     80102a76 <kfree+0x2d>
80102a64:	8b 45 08             	mov    0x8(%ebp),%eax
80102a67:	89 04 24             	mov    %eax,(%esp)
80102a6a:	e8 38 ff ff ff       	call   801029a7 <v2p>
80102a6f:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102a74:	76 0c                	jbe    80102a82 <kfree+0x39>
    panic("kfree");
80102a76:	c7 04 24 77 88 10 80 	movl   $0x80108877,(%esp)
80102a7d:	e8 b8 da ff ff       	call   8010053a <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102a82:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102a89:	00 
80102a8a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102a91:	00 
80102a92:	8b 45 08             	mov    0x8(%ebp),%eax
80102a95:	89 04 24             	mov    %eax,(%esp)
80102a98:	e8 c8 25 00 00       	call   80105065 <memset>

  if(kmem.use_lock)
80102a9d:	a1 54 22 11 80       	mov    0x80112254,%eax
80102aa2:	85 c0                	test   %eax,%eax
80102aa4:	74 0c                	je     80102ab2 <kfree+0x69>
    acquire(&kmem.lock);
80102aa6:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102aad:	e8 5f 23 00 00       	call   80104e11 <acquire>
  r = (struct run*)v;
80102ab2:	8b 45 08             	mov    0x8(%ebp),%eax
80102ab5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102ab8:	8b 15 58 22 11 80    	mov    0x80112258,%edx
80102abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac1:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac6:	a3 58 22 11 80       	mov    %eax,0x80112258
  if(kmem.use_lock)
80102acb:	a1 54 22 11 80       	mov    0x80112254,%eax
80102ad0:	85 c0                	test   %eax,%eax
80102ad2:	74 0c                	je     80102ae0 <kfree+0x97>
    release(&kmem.lock);
80102ad4:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102adb:	e8 93 23 00 00       	call   80104e73 <release>
}
80102ae0:	c9                   	leave  
80102ae1:	c3                   	ret    

80102ae2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102ae2:	55                   	push   %ebp
80102ae3:	89 e5                	mov    %esp,%ebp
80102ae5:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102ae8:	a1 54 22 11 80       	mov    0x80112254,%eax
80102aed:	85 c0                	test   %eax,%eax
80102aef:	74 0c                	je     80102afd <kalloc+0x1b>
    acquire(&kmem.lock);
80102af1:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102af8:	e8 14 23 00 00       	call   80104e11 <acquire>
  r = kmem.freelist;
80102afd:	a1 58 22 11 80       	mov    0x80112258,%eax
80102b02:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102b05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b09:	74 0a                	je     80102b15 <kalloc+0x33>
    kmem.freelist = r->next;
80102b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b0e:	8b 00                	mov    (%eax),%eax
80102b10:	a3 58 22 11 80       	mov    %eax,0x80112258
  if(kmem.use_lock)
80102b15:	a1 54 22 11 80       	mov    0x80112254,%eax
80102b1a:	85 c0                	test   %eax,%eax
80102b1c:	74 0c                	je     80102b2a <kalloc+0x48>
    release(&kmem.lock);
80102b1e:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102b25:	e8 49 23 00 00       	call   80104e73 <release>
  return (char*)r;
80102b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102b2d:	c9                   	leave  
80102b2e:	c3                   	ret    

80102b2f <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102b2f:	55                   	push   %ebp
80102b30:	89 e5                	mov    %esp,%ebp
80102b32:	83 ec 14             	sub    $0x14,%esp
80102b35:	8b 45 08             	mov    0x8(%ebp),%eax
80102b38:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b3c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102b40:	89 c2                	mov    %eax,%edx
80102b42:	ec                   	in     (%dx),%al
80102b43:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102b46:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102b4a:	c9                   	leave  
80102b4b:	c3                   	ret    

80102b4c <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102b4c:	55                   	push   %ebp
80102b4d:	89 e5                	mov    %esp,%ebp
80102b4f:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102b52:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102b59:	e8 d1 ff ff ff       	call   80102b2f <inb>
80102b5e:	0f b6 c0             	movzbl %al,%eax
80102b61:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b67:	83 e0 01             	and    $0x1,%eax
80102b6a:	85 c0                	test   %eax,%eax
80102b6c:	75 0a                	jne    80102b78 <kbdgetc+0x2c>
    return -1;
80102b6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102b73:	e9 25 01 00 00       	jmp    80102c9d <kbdgetc+0x151>
  data = inb(KBDATAP);
80102b78:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102b7f:	e8 ab ff ff ff       	call   80102b2f <inb>
80102b84:	0f b6 c0             	movzbl %al,%eax
80102b87:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102b8a:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102b91:	75 17                	jne    80102baa <kbdgetc+0x5e>
    shift |= E0ESC;
80102b93:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102b98:	83 c8 40             	or     $0x40,%eax
80102b9b:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102ba0:	b8 00 00 00 00       	mov    $0x0,%eax
80102ba5:	e9 f3 00 00 00       	jmp    80102c9d <kbdgetc+0x151>
  } else if(data & 0x80){
80102baa:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bad:	25 80 00 00 00       	and    $0x80,%eax
80102bb2:	85 c0                	test   %eax,%eax
80102bb4:	74 45                	je     80102bfb <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102bb6:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102bbb:	83 e0 40             	and    $0x40,%eax
80102bbe:	85 c0                	test   %eax,%eax
80102bc0:	75 08                	jne    80102bca <kbdgetc+0x7e>
80102bc2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bc5:	83 e0 7f             	and    $0x7f,%eax
80102bc8:	eb 03                	jmp    80102bcd <kbdgetc+0x81>
80102bca:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bcd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102bd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bd3:	05 20 90 10 80       	add    $0x80109020,%eax
80102bd8:	0f b6 00             	movzbl (%eax),%eax
80102bdb:	83 c8 40             	or     $0x40,%eax
80102bde:	0f b6 c0             	movzbl %al,%eax
80102be1:	f7 d0                	not    %eax
80102be3:	89 c2                	mov    %eax,%edx
80102be5:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102bea:	21 d0                	and    %edx,%eax
80102bec:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102bf1:	b8 00 00 00 00       	mov    $0x0,%eax
80102bf6:	e9 a2 00 00 00       	jmp    80102c9d <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102bfb:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c00:	83 e0 40             	and    $0x40,%eax
80102c03:	85 c0                	test   %eax,%eax
80102c05:	74 14                	je     80102c1b <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102c07:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102c0e:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c13:	83 e0 bf             	and    $0xffffffbf,%eax
80102c16:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102c1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c1e:	05 20 90 10 80       	add    $0x80109020,%eax
80102c23:	0f b6 00             	movzbl (%eax),%eax
80102c26:	0f b6 d0             	movzbl %al,%edx
80102c29:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c2e:	09 d0                	or     %edx,%eax
80102c30:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102c35:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c38:	05 20 91 10 80       	add    $0x80109120,%eax
80102c3d:	0f b6 00             	movzbl (%eax),%eax
80102c40:	0f b6 d0             	movzbl %al,%edx
80102c43:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c48:	31 d0                	xor    %edx,%eax
80102c4a:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102c4f:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c54:	83 e0 03             	and    $0x3,%eax
80102c57:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102c5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c61:	01 d0                	add    %edx,%eax
80102c63:	0f b6 00             	movzbl (%eax),%eax
80102c66:	0f b6 c0             	movzbl %al,%eax
80102c69:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102c6c:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c71:	83 e0 08             	and    $0x8,%eax
80102c74:	85 c0                	test   %eax,%eax
80102c76:	74 22                	je     80102c9a <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102c78:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102c7c:	76 0c                	jbe    80102c8a <kbdgetc+0x13e>
80102c7e:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102c82:	77 06                	ja     80102c8a <kbdgetc+0x13e>
      c += 'A' - 'a';
80102c84:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102c88:	eb 10                	jmp    80102c9a <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102c8a:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102c8e:	76 0a                	jbe    80102c9a <kbdgetc+0x14e>
80102c90:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102c94:	77 04                	ja     80102c9a <kbdgetc+0x14e>
      c += 'a' - 'A';
80102c96:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102c9a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102c9d:	c9                   	leave  
80102c9e:	c3                   	ret    

80102c9f <kbdintr>:

void
kbdintr(void)
{
80102c9f:	55                   	push   %ebp
80102ca0:	89 e5                	mov    %esp,%ebp
80102ca2:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102ca5:	c7 04 24 4c 2b 10 80 	movl   $0x80102b4c,(%esp)
80102cac:	e8 fc da ff ff       	call   801007ad <consoleintr>
}
80102cb1:	c9                   	leave  
80102cb2:	c3                   	ret    

80102cb3 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102cb3:	55                   	push   %ebp
80102cb4:	89 e5                	mov    %esp,%ebp
80102cb6:	83 ec 14             	sub    $0x14,%esp
80102cb9:	8b 45 08             	mov    0x8(%ebp),%eax
80102cbc:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cc0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cc4:	89 c2                	mov    %eax,%edx
80102cc6:	ec                   	in     (%dx),%al
80102cc7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cca:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cce:	c9                   	leave  
80102ccf:	c3                   	ret    

80102cd0 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102cd0:	55                   	push   %ebp
80102cd1:	89 e5                	mov    %esp,%ebp
80102cd3:	83 ec 08             	sub    $0x8,%esp
80102cd6:	8b 55 08             	mov    0x8(%ebp),%edx
80102cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cdc:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102ce0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ce3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102ce7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102ceb:	ee                   	out    %al,(%dx)
}
80102cec:	c9                   	leave  
80102ced:	c3                   	ret    

80102cee <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102cee:	55                   	push   %ebp
80102cef:	89 e5                	mov    %esp,%ebp
80102cf1:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102cf4:	9c                   	pushf  
80102cf5:	58                   	pop    %eax
80102cf6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102cf9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102cfc:	c9                   	leave  
80102cfd:	c3                   	ret    

80102cfe <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102cfe:	55                   	push   %ebp
80102cff:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102d01:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102d06:	8b 55 08             	mov    0x8(%ebp),%edx
80102d09:	c1 e2 02             	shl    $0x2,%edx
80102d0c:	01 c2                	add    %eax,%edx
80102d0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d11:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102d13:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102d18:	83 c0 20             	add    $0x20,%eax
80102d1b:	8b 00                	mov    (%eax),%eax
}
80102d1d:	5d                   	pop    %ebp
80102d1e:	c3                   	ret    

80102d1f <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102d1f:	55                   	push   %ebp
80102d20:	89 e5                	mov    %esp,%ebp
80102d22:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102d25:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102d2a:	85 c0                	test   %eax,%eax
80102d2c:	75 05                	jne    80102d33 <lapicinit+0x14>
    return;
80102d2e:	e9 43 01 00 00       	jmp    80102e76 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102d33:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102d3a:	00 
80102d3b:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102d42:	e8 b7 ff ff ff       	call   80102cfe <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102d47:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102d4e:	00 
80102d4f:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102d56:	e8 a3 ff ff ff       	call   80102cfe <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102d5b:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102d62:	00 
80102d63:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102d6a:	e8 8f ff ff ff       	call   80102cfe <lapicw>
  lapicw(TICR, 10000000); 
80102d6f:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102d76:	00 
80102d77:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102d7e:	e8 7b ff ff ff       	call   80102cfe <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102d83:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102d8a:	00 
80102d8b:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102d92:	e8 67 ff ff ff       	call   80102cfe <lapicw>
  lapicw(LINT1, MASKED);
80102d97:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102d9e:	00 
80102d9f:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102da6:	e8 53 ff ff ff       	call   80102cfe <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102dab:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102db0:	83 c0 30             	add    $0x30,%eax
80102db3:	8b 00                	mov    (%eax),%eax
80102db5:	c1 e8 10             	shr    $0x10,%eax
80102db8:	0f b6 c0             	movzbl %al,%eax
80102dbb:	83 f8 03             	cmp    $0x3,%eax
80102dbe:	76 14                	jbe    80102dd4 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102dc0:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102dc7:	00 
80102dc8:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102dcf:	e8 2a ff ff ff       	call   80102cfe <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102dd4:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102ddb:	00 
80102ddc:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102de3:	e8 16 ff ff ff       	call   80102cfe <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102de8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102def:	00 
80102df0:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102df7:	e8 02 ff ff ff       	call   80102cfe <lapicw>
  lapicw(ESR, 0);
80102dfc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e03:	00 
80102e04:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e0b:	e8 ee fe ff ff       	call   80102cfe <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102e10:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e17:	00 
80102e18:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102e1f:	e8 da fe ff ff       	call   80102cfe <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102e24:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e2b:	00 
80102e2c:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102e33:	e8 c6 fe ff ff       	call   80102cfe <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102e38:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102e3f:	00 
80102e40:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102e47:	e8 b2 fe ff ff       	call   80102cfe <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102e4c:	90                   	nop
80102e4d:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102e52:	05 00 03 00 00       	add    $0x300,%eax
80102e57:	8b 00                	mov    (%eax),%eax
80102e59:	25 00 10 00 00       	and    $0x1000,%eax
80102e5e:	85 c0                	test   %eax,%eax
80102e60:	75 eb                	jne    80102e4d <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102e62:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e69:	00 
80102e6a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102e71:	e8 88 fe ff ff       	call   80102cfe <lapicw>
}
80102e76:	c9                   	leave  
80102e77:	c3                   	ret    

80102e78 <cpunum>:

int
cpunum(void)
{
80102e78:	55                   	push   %ebp
80102e79:	89 e5                	mov    %esp,%ebp
80102e7b:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102e7e:	e8 6b fe ff ff       	call   80102cee <readeflags>
80102e83:	25 00 02 00 00       	and    $0x200,%eax
80102e88:	85 c0                	test   %eax,%eax
80102e8a:	74 25                	je     80102eb1 <cpunum+0x39>
    static int n;
    if(n++ == 0)
80102e8c:	a1 40 b6 10 80       	mov    0x8010b640,%eax
80102e91:	8d 50 01             	lea    0x1(%eax),%edx
80102e94:	89 15 40 b6 10 80    	mov    %edx,0x8010b640
80102e9a:	85 c0                	test   %eax,%eax
80102e9c:	75 13                	jne    80102eb1 <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
80102e9e:	8b 45 04             	mov    0x4(%ebp),%eax
80102ea1:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ea5:	c7 04 24 80 88 10 80 	movl   $0x80108880,(%esp)
80102eac:	e8 ef d4 ff ff       	call   801003a0 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102eb1:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102eb6:	85 c0                	test   %eax,%eax
80102eb8:	74 0f                	je     80102ec9 <cpunum+0x51>
    return lapic[ID]>>24;
80102eba:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102ebf:	83 c0 20             	add    $0x20,%eax
80102ec2:	8b 00                	mov    (%eax),%eax
80102ec4:	c1 e8 18             	shr    $0x18,%eax
80102ec7:	eb 05                	jmp    80102ece <cpunum+0x56>
  return 0;
80102ec9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102ece:	c9                   	leave  
80102ecf:	c3                   	ret    

80102ed0 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102ed0:	55                   	push   %ebp
80102ed1:	89 e5                	mov    %esp,%ebp
80102ed3:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102ed6:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102edb:	85 c0                	test   %eax,%eax
80102edd:	74 14                	je     80102ef3 <lapiceoi+0x23>
    lapicw(EOI, 0);
80102edf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ee6:	00 
80102ee7:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102eee:	e8 0b fe ff ff       	call   80102cfe <lapicw>
}
80102ef3:	c9                   	leave  
80102ef4:	c3                   	ret    

80102ef5 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102ef5:	55                   	push   %ebp
80102ef6:	89 e5                	mov    %esp,%ebp
}
80102ef8:	5d                   	pop    %ebp
80102ef9:	c3                   	ret    

80102efa <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102efa:	55                   	push   %ebp
80102efb:	89 e5                	mov    %esp,%ebp
80102efd:	83 ec 1c             	sub    $0x1c,%esp
80102f00:	8b 45 08             	mov    0x8(%ebp),%eax
80102f03:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102f06:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102f0d:	00 
80102f0e:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102f15:	e8 b6 fd ff ff       	call   80102cd0 <outb>
  outb(CMOS_PORT+1, 0x0A);
80102f1a:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102f21:	00 
80102f22:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102f29:	e8 a2 fd ff ff       	call   80102cd0 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102f2e:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102f35:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f38:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102f3d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f40:	8d 50 02             	lea    0x2(%eax),%edx
80102f43:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f46:	c1 e8 04             	shr    $0x4,%eax
80102f49:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102f4c:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102f50:	c1 e0 18             	shl    $0x18,%eax
80102f53:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f57:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102f5e:	e8 9b fd ff ff       	call   80102cfe <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102f63:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80102f6a:	00 
80102f6b:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f72:	e8 87 fd ff ff       	call   80102cfe <lapicw>
  microdelay(200);
80102f77:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102f7e:	e8 72 ff ff ff       	call   80102ef5 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80102f83:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80102f8a:	00 
80102f8b:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f92:	e8 67 fd ff ff       	call   80102cfe <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102f97:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102f9e:	e8 52 ff ff ff       	call   80102ef5 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102fa3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102faa:	eb 40                	jmp    80102fec <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80102fac:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102fb0:	c1 e0 18             	shl    $0x18,%eax
80102fb3:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fb7:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102fbe:	e8 3b fd ff ff       	call   80102cfe <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fc6:	c1 e8 0c             	shr    $0xc,%eax
80102fc9:	80 cc 06             	or     $0x6,%ah
80102fcc:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fd0:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fd7:	e8 22 fd ff ff       	call   80102cfe <lapicw>
    microdelay(200);
80102fdc:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102fe3:	e8 0d ff ff ff       	call   80102ef5 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102fe8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102fec:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102ff0:	7e ba                	jle    80102fac <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80102ff2:	c9                   	leave  
80102ff3:	c3                   	ret    

80102ff4 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102ff4:	55                   	push   %ebp
80102ff5:	89 e5                	mov    %esp,%ebp
80102ff7:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
80102ffa:	8b 45 08             	mov    0x8(%ebp),%eax
80102ffd:	0f b6 c0             	movzbl %al,%eax
80103000:	89 44 24 04          	mov    %eax,0x4(%esp)
80103004:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
8010300b:	e8 c0 fc ff ff       	call   80102cd0 <outb>
  microdelay(200);
80103010:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103017:	e8 d9 fe ff ff       	call   80102ef5 <microdelay>

  return inb(CMOS_RETURN);
8010301c:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103023:	e8 8b fc ff ff       	call   80102cb3 <inb>
80103028:	0f b6 c0             	movzbl %al,%eax
}
8010302b:	c9                   	leave  
8010302c:	c3                   	ret    

8010302d <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010302d:	55                   	push   %ebp
8010302e:	89 e5                	mov    %esp,%ebp
80103030:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
80103033:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010303a:	e8 b5 ff ff ff       	call   80102ff4 <cmos_read>
8010303f:	8b 55 08             	mov    0x8(%ebp),%edx
80103042:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103044:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010304b:	e8 a4 ff ff ff       	call   80102ff4 <cmos_read>
80103050:	8b 55 08             	mov    0x8(%ebp),%edx
80103053:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103056:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010305d:	e8 92 ff ff ff       	call   80102ff4 <cmos_read>
80103062:	8b 55 08             	mov    0x8(%ebp),%edx
80103065:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103068:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
8010306f:	e8 80 ff ff ff       	call   80102ff4 <cmos_read>
80103074:	8b 55 08             	mov    0x8(%ebp),%edx
80103077:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
8010307a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80103081:	e8 6e ff ff ff       	call   80102ff4 <cmos_read>
80103086:	8b 55 08             	mov    0x8(%ebp),%edx
80103089:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
8010308c:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
80103093:	e8 5c ff ff ff       	call   80102ff4 <cmos_read>
80103098:	8b 55 08             	mov    0x8(%ebp),%edx
8010309b:	89 42 14             	mov    %eax,0x14(%edx)
}
8010309e:	c9                   	leave  
8010309f:	c3                   	ret    

801030a0 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801030a0:	55                   	push   %ebp
801030a1:	89 e5                	mov    %esp,%ebp
801030a3:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801030a6:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
801030ad:	e8 42 ff ff ff       	call   80102ff4 <cmos_read>
801030b2:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801030b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030b8:	83 e0 04             	and    $0x4,%eax
801030bb:	85 c0                	test   %eax,%eax
801030bd:	0f 94 c0             	sete   %al
801030c0:	0f b6 c0             	movzbl %al,%eax
801030c3:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801030c6:	8d 45 d8             	lea    -0x28(%ebp),%eax
801030c9:	89 04 24             	mov    %eax,(%esp)
801030cc:	e8 5c ff ff ff       	call   8010302d <fill_rtcdate>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801030d1:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801030d8:	e8 17 ff ff ff       	call   80102ff4 <cmos_read>
801030dd:	25 80 00 00 00       	and    $0x80,%eax
801030e2:	85 c0                	test   %eax,%eax
801030e4:	74 02                	je     801030e8 <cmostime+0x48>
        continue;
801030e6:	eb 36                	jmp    8010311e <cmostime+0x7e>
    fill_rtcdate(&t2);
801030e8:	8d 45 c0             	lea    -0x40(%ebp),%eax
801030eb:	89 04 24             	mov    %eax,(%esp)
801030ee:	e8 3a ff ff ff       	call   8010302d <fill_rtcdate>
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
801030f3:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
801030fa:	00 
801030fb:	8d 45 c0             	lea    -0x40(%ebp),%eax
801030fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80103102:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103105:	89 04 24             	mov    %eax,(%esp)
80103108:	e8 cf 1f 00 00       	call   801050dc <memcmp>
8010310d:	85 c0                	test   %eax,%eax
8010310f:	75 0d                	jne    8010311e <cmostime+0x7e>
      break;
80103111:	90                   	nop
  }

  // convert
  if (bcd) {
80103112:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103116:	0f 84 ac 00 00 00    	je     801031c8 <cmostime+0x128>
8010311c:	eb 02                	jmp    80103120 <cmostime+0x80>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
8010311e:	eb a6                	jmp    801030c6 <cmostime+0x26>

  // convert
  if (bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103120:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103123:	c1 e8 04             	shr    $0x4,%eax
80103126:	89 c2                	mov    %eax,%edx
80103128:	89 d0                	mov    %edx,%eax
8010312a:	c1 e0 02             	shl    $0x2,%eax
8010312d:	01 d0                	add    %edx,%eax
8010312f:	01 c0                	add    %eax,%eax
80103131:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103134:	83 e2 0f             	and    $0xf,%edx
80103137:	01 d0                	add    %edx,%eax
80103139:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
8010313c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010313f:	c1 e8 04             	shr    $0x4,%eax
80103142:	89 c2                	mov    %eax,%edx
80103144:	89 d0                	mov    %edx,%eax
80103146:	c1 e0 02             	shl    $0x2,%eax
80103149:	01 d0                	add    %edx,%eax
8010314b:	01 c0                	add    %eax,%eax
8010314d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103150:	83 e2 0f             	and    $0xf,%edx
80103153:	01 d0                	add    %edx,%eax
80103155:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103158:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010315b:	c1 e8 04             	shr    $0x4,%eax
8010315e:	89 c2                	mov    %eax,%edx
80103160:	89 d0                	mov    %edx,%eax
80103162:	c1 e0 02             	shl    $0x2,%eax
80103165:	01 d0                	add    %edx,%eax
80103167:	01 c0                	add    %eax,%eax
80103169:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010316c:	83 e2 0f             	and    $0xf,%edx
8010316f:	01 d0                	add    %edx,%eax
80103171:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103174:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103177:	c1 e8 04             	shr    $0x4,%eax
8010317a:	89 c2                	mov    %eax,%edx
8010317c:	89 d0                	mov    %edx,%eax
8010317e:	c1 e0 02             	shl    $0x2,%eax
80103181:	01 d0                	add    %edx,%eax
80103183:	01 c0                	add    %eax,%eax
80103185:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103188:	83 e2 0f             	and    $0xf,%edx
8010318b:	01 d0                	add    %edx,%eax
8010318d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103190:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103193:	c1 e8 04             	shr    $0x4,%eax
80103196:	89 c2                	mov    %eax,%edx
80103198:	89 d0                	mov    %edx,%eax
8010319a:	c1 e0 02             	shl    $0x2,%eax
8010319d:	01 d0                	add    %edx,%eax
8010319f:	01 c0                	add    %eax,%eax
801031a1:	8b 55 e8             	mov    -0x18(%ebp),%edx
801031a4:	83 e2 0f             	and    $0xf,%edx
801031a7:	01 d0                	add    %edx,%eax
801031a9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801031ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031af:	c1 e8 04             	shr    $0x4,%eax
801031b2:	89 c2                	mov    %eax,%edx
801031b4:	89 d0                	mov    %edx,%eax
801031b6:	c1 e0 02             	shl    $0x2,%eax
801031b9:	01 d0                	add    %edx,%eax
801031bb:	01 c0                	add    %eax,%eax
801031bd:	8b 55 ec             	mov    -0x14(%ebp),%edx
801031c0:	83 e2 0f             	and    $0xf,%edx
801031c3:	01 d0                	add    %edx,%eax
801031c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801031c8:	8b 45 08             	mov    0x8(%ebp),%eax
801031cb:	8b 55 d8             	mov    -0x28(%ebp),%edx
801031ce:	89 10                	mov    %edx,(%eax)
801031d0:	8b 55 dc             	mov    -0x24(%ebp),%edx
801031d3:	89 50 04             	mov    %edx,0x4(%eax)
801031d6:	8b 55 e0             	mov    -0x20(%ebp),%edx
801031d9:	89 50 08             	mov    %edx,0x8(%eax)
801031dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801031df:	89 50 0c             	mov    %edx,0xc(%eax)
801031e2:	8b 55 e8             	mov    -0x18(%ebp),%edx
801031e5:	89 50 10             	mov    %edx,0x10(%eax)
801031e8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801031eb:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801031ee:	8b 45 08             	mov    0x8(%ebp),%eax
801031f1:	8b 40 14             	mov    0x14(%eax),%eax
801031f4:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801031fa:	8b 45 08             	mov    0x8(%ebp),%eax
801031fd:	89 50 14             	mov    %edx,0x14(%eax)
}
80103200:	c9                   	leave  
80103201:	c3                   	ret    

80103202 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(void)
{
80103202:	55                   	push   %ebp
80103203:	89 e5                	mov    %esp,%ebp
80103205:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103208:	c7 44 24 04 ac 88 10 	movl   $0x801088ac,0x4(%esp)
8010320f:	80 
80103210:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103217:	e8 d4 1b 00 00       	call   80104df0 <initlock>
  readsb(ROOTDEV, &sb);
8010321c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010321f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103223:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010322a:	e8 c2 e0 ff ff       	call   801012f1 <readsb>
  log.start = sb.size - sb.nlog;
8010322f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103232:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103235:	29 c2                	sub    %eax,%edx
80103237:	89 d0                	mov    %edx,%eax
80103239:	a3 94 22 11 80       	mov    %eax,0x80112294
  log.size = sb.nlog;
8010323e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103241:	a3 98 22 11 80       	mov    %eax,0x80112298
  log.dev = ROOTDEV;
80103246:	c7 05 a4 22 11 80 01 	movl   $0x1,0x801122a4
8010324d:	00 00 00 
  recover_from_log();
80103250:	e8 9a 01 00 00       	call   801033ef <recover_from_log>
}
80103255:	c9                   	leave  
80103256:	c3                   	ret    

80103257 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103257:	55                   	push   %ebp
80103258:	89 e5                	mov    %esp,%ebp
8010325a:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010325d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103264:	e9 8c 00 00 00       	jmp    801032f5 <install_trans+0x9e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103269:	8b 15 94 22 11 80    	mov    0x80112294,%edx
8010326f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103272:	01 d0                	add    %edx,%eax
80103274:	83 c0 01             	add    $0x1,%eax
80103277:	89 c2                	mov    %eax,%edx
80103279:	a1 a4 22 11 80       	mov    0x801122a4,%eax
8010327e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103282:	89 04 24             	mov    %eax,(%esp)
80103285:	e8 1c cf ff ff       	call   801001a6 <bread>
8010328a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
8010328d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103290:	83 c0 10             	add    $0x10,%eax
80103293:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
8010329a:	89 c2                	mov    %eax,%edx
8010329c:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801032a1:	89 54 24 04          	mov    %edx,0x4(%esp)
801032a5:	89 04 24             	mov    %eax,(%esp)
801032a8:	e8 f9 ce ff ff       	call   801001a6 <bread>
801032ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801032b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801032b3:	8d 50 18             	lea    0x18(%eax),%edx
801032b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032b9:	83 c0 18             	add    $0x18,%eax
801032bc:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801032c3:	00 
801032c4:	89 54 24 04          	mov    %edx,0x4(%esp)
801032c8:	89 04 24             	mov    %eax,(%esp)
801032cb:	e8 64 1e 00 00       	call   80105134 <memmove>
    bwrite(dbuf);  // write dst to disk
801032d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032d3:	89 04 24             	mov    %eax,(%esp)
801032d6:	e8 02 cf ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
801032db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801032de:	89 04 24             	mov    %eax,(%esp)
801032e1:	e8 31 cf ff ff       	call   80100217 <brelse>
    brelse(dbuf);
801032e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032e9:	89 04 24             	mov    %eax,(%esp)
801032ec:	e8 26 cf ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801032f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032f5:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801032fa:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801032fd:	0f 8f 66 ff ff ff    	jg     80103269 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103303:	c9                   	leave  
80103304:	c3                   	ret    

80103305 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103305:	55                   	push   %ebp
80103306:	89 e5                	mov    %esp,%ebp
80103308:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010330b:	a1 94 22 11 80       	mov    0x80112294,%eax
80103310:	89 c2                	mov    %eax,%edx
80103312:	a1 a4 22 11 80       	mov    0x801122a4,%eax
80103317:	89 54 24 04          	mov    %edx,0x4(%esp)
8010331b:	89 04 24             	mov    %eax,(%esp)
8010331e:	e8 83 ce ff ff       	call   801001a6 <bread>
80103323:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103326:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103329:	83 c0 18             	add    $0x18,%eax
8010332c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010332f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103332:	8b 00                	mov    (%eax),%eax
80103334:	a3 a8 22 11 80       	mov    %eax,0x801122a8
  for (i = 0; i < log.lh.n; i++) {
80103339:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103340:	eb 1b                	jmp    8010335d <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
80103342:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103345:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103348:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010334c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010334f:	83 c2 10             	add    $0x10,%edx
80103352:	89 04 95 6c 22 11 80 	mov    %eax,-0x7feedd94(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103359:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010335d:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103362:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103365:	7f db                	jg     80103342 <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
80103367:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010336a:	89 04 24             	mov    %eax,(%esp)
8010336d:	e8 a5 ce ff ff       	call   80100217 <brelse>
}
80103372:	c9                   	leave  
80103373:	c3                   	ret    

80103374 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103374:	55                   	push   %ebp
80103375:	89 e5                	mov    %esp,%ebp
80103377:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010337a:	a1 94 22 11 80       	mov    0x80112294,%eax
8010337f:	89 c2                	mov    %eax,%edx
80103381:	a1 a4 22 11 80       	mov    0x801122a4,%eax
80103386:	89 54 24 04          	mov    %edx,0x4(%esp)
8010338a:	89 04 24             	mov    %eax,(%esp)
8010338d:	e8 14 ce ff ff       	call   801001a6 <bread>
80103392:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103395:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103398:	83 c0 18             	add    $0x18,%eax
8010339b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010339e:	8b 15 a8 22 11 80    	mov    0x801122a8,%edx
801033a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033a7:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801033a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033b0:	eb 1b                	jmp    801033cd <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
801033b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033b5:	83 c0 10             	add    $0x10,%eax
801033b8:	8b 0c 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%ecx
801033bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033c5:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801033c9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033cd:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801033d2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033d5:	7f db                	jg     801033b2 <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
801033d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033da:	89 04 24             	mov    %eax,(%esp)
801033dd:	e8 fb cd ff ff       	call   801001dd <bwrite>
  brelse(buf);
801033e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033e5:	89 04 24             	mov    %eax,(%esp)
801033e8:	e8 2a ce ff ff       	call   80100217 <brelse>
}
801033ed:	c9                   	leave  
801033ee:	c3                   	ret    

801033ef <recover_from_log>:

static void
recover_from_log(void)
{
801033ef:	55                   	push   %ebp
801033f0:	89 e5                	mov    %esp,%ebp
801033f2:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801033f5:	e8 0b ff ff ff       	call   80103305 <read_head>
  install_trans(); // if committed, copy from log to disk
801033fa:	e8 58 fe ff ff       	call   80103257 <install_trans>
  log.lh.n = 0;
801033ff:	c7 05 a8 22 11 80 00 	movl   $0x0,0x801122a8
80103406:	00 00 00 
  write_head(); // clear the log
80103409:	e8 66 ff ff ff       	call   80103374 <write_head>
}
8010340e:	c9                   	leave  
8010340f:	c3                   	ret    

80103410 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103410:	55                   	push   %ebp
80103411:	89 e5                	mov    %esp,%ebp
80103413:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103416:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010341d:	e8 ef 19 00 00       	call   80104e11 <acquire>
  while(1){
    if(log.committing){
80103422:	a1 a0 22 11 80       	mov    0x801122a0,%eax
80103427:	85 c0                	test   %eax,%eax
80103429:	74 16                	je     80103441 <begin_op+0x31>
      sleep(&log, &log.lock);
8010342b:	c7 44 24 04 60 22 11 	movl   $0x80112260,0x4(%esp)
80103432:	80 
80103433:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010343a:	e8 08 17 00 00       	call   80104b47 <sleep>
8010343f:	eb 4f                	jmp    80103490 <begin_op+0x80>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103441:	8b 0d a8 22 11 80    	mov    0x801122a8,%ecx
80103447:	a1 9c 22 11 80       	mov    0x8011229c,%eax
8010344c:	8d 50 01             	lea    0x1(%eax),%edx
8010344f:	89 d0                	mov    %edx,%eax
80103451:	c1 e0 02             	shl    $0x2,%eax
80103454:	01 d0                	add    %edx,%eax
80103456:	01 c0                	add    %eax,%eax
80103458:	01 c8                	add    %ecx,%eax
8010345a:	83 f8 1e             	cmp    $0x1e,%eax
8010345d:	7e 16                	jle    80103475 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010345f:	c7 44 24 04 60 22 11 	movl   $0x80112260,0x4(%esp)
80103466:	80 
80103467:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010346e:	e8 d4 16 00 00       	call   80104b47 <sleep>
80103473:	eb 1b                	jmp    80103490 <begin_op+0x80>
    } else {
      log.outstanding += 1;
80103475:	a1 9c 22 11 80       	mov    0x8011229c,%eax
8010347a:	83 c0 01             	add    $0x1,%eax
8010347d:	a3 9c 22 11 80       	mov    %eax,0x8011229c
      release(&log.lock);
80103482:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103489:	e8 e5 19 00 00       	call   80104e73 <release>
      break;
8010348e:	eb 02                	jmp    80103492 <begin_op+0x82>
    }
  }
80103490:	eb 90                	jmp    80103422 <begin_op+0x12>
}
80103492:	c9                   	leave  
80103493:	c3                   	ret    

80103494 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103494:	55                   	push   %ebp
80103495:	89 e5                	mov    %esp,%ebp
80103497:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
8010349a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801034a1:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801034a8:	e8 64 19 00 00       	call   80104e11 <acquire>
  log.outstanding -= 1;
801034ad:	a1 9c 22 11 80       	mov    0x8011229c,%eax
801034b2:	83 e8 01             	sub    $0x1,%eax
801034b5:	a3 9c 22 11 80       	mov    %eax,0x8011229c
  if(log.committing)
801034ba:	a1 a0 22 11 80       	mov    0x801122a0,%eax
801034bf:	85 c0                	test   %eax,%eax
801034c1:	74 0c                	je     801034cf <end_op+0x3b>
    panic("log.committing");
801034c3:	c7 04 24 b0 88 10 80 	movl   $0x801088b0,(%esp)
801034ca:	e8 6b d0 ff ff       	call   8010053a <panic>
  if(log.outstanding == 0){
801034cf:	a1 9c 22 11 80       	mov    0x8011229c,%eax
801034d4:	85 c0                	test   %eax,%eax
801034d6:	75 13                	jne    801034eb <end_op+0x57>
    do_commit = 1;
801034d8:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801034df:	c7 05 a0 22 11 80 01 	movl   $0x1,0x801122a0
801034e6:	00 00 00 
801034e9:	eb 0c                	jmp    801034f7 <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801034eb:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801034f2:	e8 29 17 00 00       	call   80104c20 <wakeup>
  }
  release(&log.lock);
801034f7:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801034fe:	e8 70 19 00 00       	call   80104e73 <release>

  if(do_commit){
80103503:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103507:	74 33                	je     8010353c <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103509:	e8 de 00 00 00       	call   801035ec <commit>
    acquire(&log.lock);
8010350e:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103515:	e8 f7 18 00 00       	call   80104e11 <acquire>
    log.committing = 0;
8010351a:	c7 05 a0 22 11 80 00 	movl   $0x0,0x801122a0
80103521:	00 00 00 
    wakeup(&log);
80103524:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010352b:	e8 f0 16 00 00       	call   80104c20 <wakeup>
    release(&log.lock);
80103530:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103537:	e8 37 19 00 00       	call   80104e73 <release>
  }
}
8010353c:	c9                   	leave  
8010353d:	c3                   	ret    

8010353e <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
8010353e:	55                   	push   %ebp
8010353f:	89 e5                	mov    %esp,%ebp
80103541:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103544:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010354b:	e9 8c 00 00 00       	jmp    801035dc <write_log+0x9e>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103550:	8b 15 94 22 11 80    	mov    0x80112294,%edx
80103556:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103559:	01 d0                	add    %edx,%eax
8010355b:	83 c0 01             	add    $0x1,%eax
8010355e:	89 c2                	mov    %eax,%edx
80103560:	a1 a4 22 11 80       	mov    0x801122a4,%eax
80103565:	89 54 24 04          	mov    %edx,0x4(%esp)
80103569:	89 04 24             	mov    %eax,(%esp)
8010356c:	e8 35 cc ff ff       	call   801001a6 <bread>
80103571:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.sector[tail]); // cache block
80103574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103577:	83 c0 10             	add    $0x10,%eax
8010357a:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
80103581:	89 c2                	mov    %eax,%edx
80103583:	a1 a4 22 11 80       	mov    0x801122a4,%eax
80103588:	89 54 24 04          	mov    %edx,0x4(%esp)
8010358c:	89 04 24             	mov    %eax,(%esp)
8010358f:	e8 12 cc ff ff       	call   801001a6 <bread>
80103594:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103597:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010359a:	8d 50 18             	lea    0x18(%eax),%edx
8010359d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035a0:	83 c0 18             	add    $0x18,%eax
801035a3:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801035aa:	00 
801035ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801035af:	89 04 24             	mov    %eax,(%esp)
801035b2:	e8 7d 1b 00 00       	call   80105134 <memmove>
    bwrite(to);  // write the log
801035b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035ba:	89 04 24             	mov    %eax,(%esp)
801035bd:	e8 1b cc ff ff       	call   801001dd <bwrite>
    brelse(from); 
801035c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035c5:	89 04 24             	mov    %eax,(%esp)
801035c8:	e8 4a cc ff ff       	call   80100217 <brelse>
    brelse(to);
801035cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035d0:	89 04 24             	mov    %eax,(%esp)
801035d3:	e8 3f cc ff ff       	call   80100217 <brelse>
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801035d8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801035dc:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801035e1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035e4:	0f 8f 66 ff ff ff    	jg     80103550 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
801035ea:	c9                   	leave  
801035eb:	c3                   	ret    

801035ec <commit>:

static void
commit()
{
801035ec:	55                   	push   %ebp
801035ed:	89 e5                	mov    %esp,%ebp
801035ef:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801035f2:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801035f7:	85 c0                	test   %eax,%eax
801035f9:	7e 1e                	jle    80103619 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801035fb:	e8 3e ff ff ff       	call   8010353e <write_log>
    write_head();    // Write header to disk -- the real commit
80103600:	e8 6f fd ff ff       	call   80103374 <write_head>
    install_trans(); // Now install writes to home locations
80103605:	e8 4d fc ff ff       	call   80103257 <install_trans>
    log.lh.n = 0; 
8010360a:	c7 05 a8 22 11 80 00 	movl   $0x0,0x801122a8
80103611:	00 00 00 
    write_head();    // Erase the transaction from the log
80103614:	e8 5b fd ff ff       	call   80103374 <write_head>
  }
}
80103619:	c9                   	leave  
8010361a:	c3                   	ret    

8010361b <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010361b:	55                   	push   %ebp
8010361c:	89 e5                	mov    %esp,%ebp
8010361e:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103621:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103626:	83 f8 1d             	cmp    $0x1d,%eax
80103629:	7f 12                	jg     8010363d <log_write+0x22>
8010362b:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103630:	8b 15 98 22 11 80    	mov    0x80112298,%edx
80103636:	83 ea 01             	sub    $0x1,%edx
80103639:	39 d0                	cmp    %edx,%eax
8010363b:	7c 0c                	jl     80103649 <log_write+0x2e>
    panic("too big a transaction");
8010363d:	c7 04 24 bf 88 10 80 	movl   $0x801088bf,(%esp)
80103644:	e8 f1 ce ff ff       	call   8010053a <panic>
  if (log.outstanding < 1)
80103649:	a1 9c 22 11 80       	mov    0x8011229c,%eax
8010364e:	85 c0                	test   %eax,%eax
80103650:	7f 0c                	jg     8010365e <log_write+0x43>
    panic("log_write outside of trans");
80103652:	c7 04 24 d5 88 10 80 	movl   $0x801088d5,(%esp)
80103659:	e8 dc ce ff ff       	call   8010053a <panic>

  acquire(&log.lock);
8010365e:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103665:	e8 a7 17 00 00       	call   80104e11 <acquire>
  for (i = 0; i < log.lh.n; i++) {
8010366a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103671:	eb 1f                	jmp    80103692 <log_write+0x77>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
80103673:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103676:	83 c0 10             	add    $0x10,%eax
80103679:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
80103680:	89 c2                	mov    %eax,%edx
80103682:	8b 45 08             	mov    0x8(%ebp),%eax
80103685:	8b 40 08             	mov    0x8(%eax),%eax
80103688:	39 c2                	cmp    %eax,%edx
8010368a:	75 02                	jne    8010368e <log_write+0x73>
      break;
8010368c:	eb 0e                	jmp    8010369c <log_write+0x81>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
8010368e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103692:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103697:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010369a:	7f d7                	jg     80103673 <log_write+0x58>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
      break;
  }
  log.lh.sector[i] = b->sector;
8010369c:	8b 45 08             	mov    0x8(%ebp),%eax
8010369f:	8b 40 08             	mov    0x8(%eax),%eax
801036a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801036a5:	83 c2 10             	add    $0x10,%edx
801036a8:	89 04 95 6c 22 11 80 	mov    %eax,-0x7feedd94(,%edx,4)
  if (i == log.lh.n)
801036af:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801036b4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036b7:	75 0d                	jne    801036c6 <log_write+0xab>
    log.lh.n++;
801036b9:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801036be:	83 c0 01             	add    $0x1,%eax
801036c1:	a3 a8 22 11 80       	mov    %eax,0x801122a8
  b->flags |= B_DIRTY; // prevent eviction
801036c6:	8b 45 08             	mov    0x8(%ebp),%eax
801036c9:	8b 00                	mov    (%eax),%eax
801036cb:	83 c8 04             	or     $0x4,%eax
801036ce:	89 c2                	mov    %eax,%edx
801036d0:	8b 45 08             	mov    0x8(%ebp),%eax
801036d3:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801036d5:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801036dc:	e8 92 17 00 00       	call   80104e73 <release>
}
801036e1:	c9                   	leave  
801036e2:	c3                   	ret    

801036e3 <v2p>:
801036e3:	55                   	push   %ebp
801036e4:	89 e5                	mov    %esp,%ebp
801036e6:	8b 45 08             	mov    0x8(%ebp),%eax
801036e9:	05 00 00 00 80       	add    $0x80000000,%eax
801036ee:	5d                   	pop    %ebp
801036ef:	c3                   	ret    

801036f0 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801036f0:	55                   	push   %ebp
801036f1:	89 e5                	mov    %esp,%ebp
801036f3:	8b 45 08             	mov    0x8(%ebp),%eax
801036f6:	05 00 00 00 80       	add    $0x80000000,%eax
801036fb:	5d                   	pop    %ebp
801036fc:	c3                   	ret    

801036fd <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801036fd:	55                   	push   %ebp
801036fe:	89 e5                	mov    %esp,%ebp
80103700:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103703:	8b 55 08             	mov    0x8(%ebp),%edx
80103706:	8b 45 0c             	mov    0xc(%ebp),%eax
80103709:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010370c:	f0 87 02             	lock xchg %eax,(%edx)
8010370f:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103712:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103715:	c9                   	leave  
80103716:	c3                   	ret    

80103717 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103717:	55                   	push   %ebp
80103718:	89 e5                	mov    %esp,%ebp
8010371a:	83 e4 f0             	and    $0xfffffff0,%esp
8010371d:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103720:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103727:	80 
80103728:	c7 04 24 b8 51 11 80 	movl   $0x801151b8,(%esp)
8010372f:	e8 80 f2 ff ff       	call   801029b4 <kinit1>
  seginit();       // set up segments
80103734:	e8 ab 3e 00 00       	call   801075e4 <seginit>
  kvmalloc(cpu);   // kernel page table
80103739:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010373f:	89 04 24             	mov    %eax,(%esp)
80103742:	e8 46 45 00 00       	call   80107c8d <kvmalloc>
  mpinit();        // collect info about this machine
80103747:	e8 56 04 00 00       	call   80103ba2 <mpinit>
  lapicinit();
8010374c:	e8 ce f5 ff ff       	call   80102d1f <lapicinit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103751:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103757:	0f b6 00             	movzbl (%eax),%eax
8010375a:	0f b6 c0             	movzbl %al,%eax
8010375d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103761:	c7 04 24 f0 88 10 80 	movl   $0x801088f0,(%esp)
80103768:	e8 33 cc ff ff       	call   801003a0 <cprintf>
  picinit();       // interrupt controller
8010376d:	e8 8e 06 00 00       	call   80103e00 <picinit>
  ioapicinit();    // another interrupt controller
80103772:	e8 33 f1 ff ff       	call   801028aa <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103777:	e8 05 d3 ff ff       	call   80100a81 <consoleinit>
  uartinit();      // serial port
8010377c:	e8 b2 31 00 00       	call   80106933 <uartinit>
  pinit();         // process table
80103781:	e8 84 0b 00 00       	call   8010430a <pinit>
  tvinit();        // trap vectors
80103786:	e8 33 2d 00 00       	call   801064be <tvinit>
  binit();         // buffer cache
8010378b:	e8 a4 c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103790:	e8 75 d7 ff ff       	call   80100f0a <fileinit>
  iinit();         // inode cache
80103795:	e8 0a de ff ff       	call   801015a4 <iinit>
  ideinit();       // disk
8010379a:	e8 74 ed ff ff       	call   80102513 <ideinit>
  if(!ismp)
8010379f:	a1 44 23 11 80       	mov    0x80112344,%eax
801037a4:	85 c0                	test   %eax,%eax
801037a6:	75 05                	jne    801037ad <main+0x96>
    timerinit();   // uniprocessor timer
801037a8:	e8 5c 2c 00 00       	call   80106409 <timerinit>
  startothers();   // start other processors
801037ad:	e8 94 00 00 00       	call   80103846 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801037b2:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801037b9:	8e 
801037ba:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801037c1:	e8 26 f2 ff ff       	call   801029ec <kinit2>
  userinit();      // first user process
801037c6:	e8 5a 0c 00 00       	call   80104425 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801037cb:	e8 2f 00 00 00       	call   801037ff <mpmain>

801037d0 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801037d0:	55                   	push   %ebp
801037d1:	89 e5                	mov    %esp,%ebp
801037d3:	83 ec 18             	sub    $0x18,%esp
  switchkvm(&cpus[0]); 
801037d6:	c7 04 24 60 23 11 80 	movl   $0x80112360,(%esp)
801037dd:	e8 c9 44 00 00       	call   80107cab <switchkvm>
  seginit();
801037e2:	e8 fd 3d 00 00       	call   801075e4 <seginit>
  kvmalloc(cpu);
801037e7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801037ed:	89 04 24             	mov    %eax,(%esp)
801037f0:	e8 98 44 00 00       	call   80107c8d <kvmalloc>
  lapicinit();
801037f5:	e8 25 f5 ff ff       	call   80102d1f <lapicinit>
  mpmain();
801037fa:	e8 00 00 00 00       	call   801037ff <mpmain>

801037ff <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801037ff:	55                   	push   %ebp
80103800:	89 e5                	mov    %esp,%ebp
80103802:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103805:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010380b:	0f b6 00             	movzbl (%eax),%eax
8010380e:	0f b6 c0             	movzbl %al,%eax
80103811:	89 44 24 04          	mov    %eax,0x4(%esp)
80103815:	c7 04 24 07 89 10 80 	movl   $0x80108907,(%esp)
8010381c:	e8 7f cb ff ff       	call   801003a0 <cprintf>
  idtinit();       // load idt register
80103821:	e8 0c 2e 00 00       	call   80106632 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103826:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010382c:	05 ac 00 00 00       	add    $0xac,%eax
80103831:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103838:	00 
80103839:	89 04 24             	mov    %eax,(%esp)
8010383c:	e8 bc fe ff ff       	call   801036fd <xchg>
  scheduler();     // start running processes
80103841:	e8 50 11 00 00       	call   80104996 <scheduler>

80103846 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103846:	55                   	push   %ebp
80103847:	89 e5                	mov    %esp,%ebp
80103849:	53                   	push   %ebx
8010384a:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
8010384d:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
80103854:	e8 97 fe ff ff       	call   801036f0 <p2v>
80103859:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010385c:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103861:	89 44 24 08          	mov    %eax,0x8(%esp)
80103865:	c7 44 24 04 0c b5 10 	movl   $0x8010b50c,0x4(%esp)
8010386c:	80 
8010386d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103870:	89 04 24             	mov    %eax,(%esp)
80103873:	e8 bc 18 00 00       	call   80105134 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103878:	c7 45 f4 60 23 11 80 	movl   $0x80112360,-0xc(%ebp)
8010387f:	e9 85 00 00 00       	jmp    80103909 <startothers+0xc3>
    if(c == cpus+cpunum())  // We've started already.
80103884:	e8 ef f5 ff ff       	call   80102e78 <cpunum>
80103889:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
8010388f:	05 60 23 11 80       	add    $0x80112360,%eax
80103894:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103897:	75 02                	jne    8010389b <startothers+0x55>
      continue;
80103899:	eb 67                	jmp    80103902 <startothers+0xbc>

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010389b:	e8 42 f2 ff ff       	call   80102ae2 <kalloc>
801038a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801038a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038a6:	83 e8 04             	sub    $0x4,%eax
801038a9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801038ac:	81 c2 00 10 00 00    	add    $0x1000,%edx
801038b2:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801038b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038b7:	83 e8 08             	sub    $0x8,%eax
801038ba:	c7 00 d0 37 10 80    	movl   $0x801037d0,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
801038c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038c3:	8d 58 f4             	lea    -0xc(%eax),%ebx
801038c6:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
801038cd:	e8 11 fe ff ff       	call   801036e3 <v2p>
801038d2:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
801038d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038d7:	89 04 24             	mov    %eax,(%esp)
801038da:	e8 04 fe ff ff       	call   801036e3 <v2p>
801038df:	8b 55 f4             	mov    -0xc(%ebp),%edx
801038e2:	0f b6 12             	movzbl (%edx),%edx
801038e5:	0f b6 d2             	movzbl %dl,%edx
801038e8:	89 44 24 04          	mov    %eax,0x4(%esp)
801038ec:	89 14 24             	mov    %edx,(%esp)
801038ef:	e8 06 f6 ff ff       	call   80102efa <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801038f4:	90                   	nop
801038f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038f8:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801038fe:	85 c0                	test   %eax,%eax
80103900:	74 f3                	je     801038f5 <startothers+0xaf>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103902:	81 45 f4 cc 00 00 00 	addl   $0xcc,-0xc(%ebp)
80103909:	a1 c0 29 11 80       	mov    0x801129c0,%eax
8010390e:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80103914:	05 60 23 11 80       	add    $0x80112360,%eax
80103919:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010391c:	0f 87 62 ff ff ff    	ja     80103884 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103922:	83 c4 24             	add    $0x24,%esp
80103925:	5b                   	pop    %ebx
80103926:	5d                   	pop    %ebp
80103927:	c3                   	ret    

80103928 <p2v>:
80103928:	55                   	push   %ebp
80103929:	89 e5                	mov    %esp,%ebp
8010392b:	8b 45 08             	mov    0x8(%ebp),%eax
8010392e:	05 00 00 00 80       	add    $0x80000000,%eax
80103933:	5d                   	pop    %ebp
80103934:	c3                   	ret    

80103935 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103935:	55                   	push   %ebp
80103936:	89 e5                	mov    %esp,%ebp
80103938:	83 ec 14             	sub    $0x14,%esp
8010393b:	8b 45 08             	mov    0x8(%ebp),%eax
8010393e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103942:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103946:	89 c2                	mov    %eax,%edx
80103948:	ec                   	in     (%dx),%al
80103949:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010394c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103950:	c9                   	leave  
80103951:	c3                   	ret    

80103952 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103952:	55                   	push   %ebp
80103953:	89 e5                	mov    %esp,%ebp
80103955:	83 ec 08             	sub    $0x8,%esp
80103958:	8b 55 08             	mov    0x8(%ebp),%edx
8010395b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010395e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103962:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103965:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103969:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010396d:	ee                   	out    %al,(%dx)
}
8010396e:	c9                   	leave  
8010396f:	c3                   	ret    

80103970 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103970:	55                   	push   %ebp
80103971:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103973:	a1 44 b6 10 80       	mov    0x8010b644,%eax
80103978:	89 c2                	mov    %eax,%edx
8010397a:	b8 60 23 11 80       	mov    $0x80112360,%eax
8010397f:	29 c2                	sub    %eax,%edx
80103981:	89 d0                	mov    %edx,%eax
80103983:	c1 f8 02             	sar    $0x2,%eax
80103986:	69 c0 fb fa fa fa    	imul   $0xfafafafb,%eax,%eax
}
8010398c:	5d                   	pop    %ebp
8010398d:	c3                   	ret    

8010398e <sum>:

static uchar
sum(uchar *addr, int len)
{
8010398e:	55                   	push   %ebp
8010398f:	89 e5                	mov    %esp,%ebp
80103991:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103994:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
8010399b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801039a2:	eb 15                	jmp    801039b9 <sum+0x2b>
    sum += addr[i];
801039a4:	8b 55 fc             	mov    -0x4(%ebp),%edx
801039a7:	8b 45 08             	mov    0x8(%ebp),%eax
801039aa:	01 d0                	add    %edx,%eax
801039ac:	0f b6 00             	movzbl (%eax),%eax
801039af:	0f b6 c0             	movzbl %al,%eax
801039b2:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
801039b5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801039b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801039bc:	3b 45 0c             	cmp    0xc(%ebp),%eax
801039bf:	7c e3                	jl     801039a4 <sum+0x16>
    sum += addr[i];
  return sum;
801039c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801039c4:	c9                   	leave  
801039c5:	c3                   	ret    

801039c6 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
801039c6:	55                   	push   %ebp
801039c7:	89 e5                	mov    %esp,%ebp
801039c9:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
801039cc:	8b 45 08             	mov    0x8(%ebp),%eax
801039cf:	89 04 24             	mov    %eax,(%esp)
801039d2:	e8 51 ff ff ff       	call   80103928 <p2v>
801039d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
801039da:	8b 55 0c             	mov    0xc(%ebp),%edx
801039dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039e0:	01 d0                	add    %edx,%eax
801039e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
801039e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801039eb:	eb 3f                	jmp    80103a2c <mpsearch1+0x66>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801039ed:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801039f4:	00 
801039f5:	c7 44 24 04 18 89 10 	movl   $0x80108918,0x4(%esp)
801039fc:	80 
801039fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a00:	89 04 24             	mov    %eax,(%esp)
80103a03:	e8 d4 16 00 00       	call   801050dc <memcmp>
80103a08:	85 c0                	test   %eax,%eax
80103a0a:	75 1c                	jne    80103a28 <mpsearch1+0x62>
80103a0c:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a13:	00 
80103a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a17:	89 04 24             	mov    %eax,(%esp)
80103a1a:	e8 6f ff ff ff       	call   8010398e <sum>
80103a1f:	84 c0                	test   %al,%al
80103a21:	75 05                	jne    80103a28 <mpsearch1+0x62>
      return (struct mp*)p;
80103a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a26:	eb 11                	jmp    80103a39 <mpsearch1+0x73>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a28:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a2f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a32:	72 b9                	jb     801039ed <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a34:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a39:	c9                   	leave  
80103a3a:	c3                   	ret    

80103a3b <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a3b:	55                   	push   %ebp
80103a3c:	89 e5                	mov    %esp,%ebp
80103a3e:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103a41:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a4b:	83 c0 0f             	add    $0xf,%eax
80103a4e:	0f b6 00             	movzbl (%eax),%eax
80103a51:	0f b6 c0             	movzbl %al,%eax
80103a54:	c1 e0 08             	shl    $0x8,%eax
80103a57:	89 c2                	mov    %eax,%edx
80103a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a5c:	83 c0 0e             	add    $0xe,%eax
80103a5f:	0f b6 00             	movzbl (%eax),%eax
80103a62:	0f b6 c0             	movzbl %al,%eax
80103a65:	09 d0                	or     %edx,%eax
80103a67:	c1 e0 04             	shl    $0x4,%eax
80103a6a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103a6d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a71:	74 21                	je     80103a94 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103a73:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103a7a:	00 
80103a7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a7e:	89 04 24             	mov    %eax,(%esp)
80103a81:	e8 40 ff ff ff       	call   801039c6 <mpsearch1>
80103a86:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103a89:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103a8d:	74 50                	je     80103adf <mpsearch+0xa4>
      return mp;
80103a8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a92:	eb 5f                	jmp    80103af3 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a97:	83 c0 14             	add    $0x14,%eax
80103a9a:	0f b6 00             	movzbl (%eax),%eax
80103a9d:	0f b6 c0             	movzbl %al,%eax
80103aa0:	c1 e0 08             	shl    $0x8,%eax
80103aa3:	89 c2                	mov    %eax,%edx
80103aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa8:	83 c0 13             	add    $0x13,%eax
80103aab:	0f b6 00             	movzbl (%eax),%eax
80103aae:	0f b6 c0             	movzbl %al,%eax
80103ab1:	09 d0                	or     %edx,%eax
80103ab3:	c1 e0 0a             	shl    $0xa,%eax
80103ab6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103abc:	2d 00 04 00 00       	sub    $0x400,%eax
80103ac1:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103ac8:	00 
80103ac9:	89 04 24             	mov    %eax,(%esp)
80103acc:	e8 f5 fe ff ff       	call   801039c6 <mpsearch1>
80103ad1:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ad4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ad8:	74 05                	je     80103adf <mpsearch+0xa4>
      return mp;
80103ada:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103add:	eb 14                	jmp    80103af3 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103adf:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103ae6:	00 
80103ae7:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103aee:	e8 d3 fe ff ff       	call   801039c6 <mpsearch1>
}
80103af3:	c9                   	leave  
80103af4:	c3                   	ret    

80103af5 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103af5:	55                   	push   %ebp
80103af6:	89 e5                	mov    %esp,%ebp
80103af8:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103afb:	e8 3b ff ff ff       	call   80103a3b <mpsearch>
80103b00:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b03:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b07:	74 0a                	je     80103b13 <mpconfig+0x1e>
80103b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b0c:	8b 40 04             	mov    0x4(%eax),%eax
80103b0f:	85 c0                	test   %eax,%eax
80103b11:	75 0a                	jne    80103b1d <mpconfig+0x28>
    return 0;
80103b13:	b8 00 00 00 00       	mov    $0x0,%eax
80103b18:	e9 83 00 00 00       	jmp    80103ba0 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b20:	8b 40 04             	mov    0x4(%eax),%eax
80103b23:	89 04 24             	mov    %eax,(%esp)
80103b26:	e8 fd fd ff ff       	call   80103928 <p2v>
80103b2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b2e:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b35:	00 
80103b36:	c7 44 24 04 1d 89 10 	movl   $0x8010891d,0x4(%esp)
80103b3d:	80 
80103b3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b41:	89 04 24             	mov    %eax,(%esp)
80103b44:	e8 93 15 00 00       	call   801050dc <memcmp>
80103b49:	85 c0                	test   %eax,%eax
80103b4b:	74 07                	je     80103b54 <mpconfig+0x5f>
    return 0;
80103b4d:	b8 00 00 00 00       	mov    $0x0,%eax
80103b52:	eb 4c                	jmp    80103ba0 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103b54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b57:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b5b:	3c 01                	cmp    $0x1,%al
80103b5d:	74 12                	je     80103b71 <mpconfig+0x7c>
80103b5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b62:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b66:	3c 04                	cmp    $0x4,%al
80103b68:	74 07                	je     80103b71 <mpconfig+0x7c>
    return 0;
80103b6a:	b8 00 00 00 00       	mov    $0x0,%eax
80103b6f:	eb 2f                	jmp    80103ba0 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103b71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b74:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103b78:	0f b7 c0             	movzwl %ax,%eax
80103b7b:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b82:	89 04 24             	mov    %eax,(%esp)
80103b85:	e8 04 fe ff ff       	call   8010398e <sum>
80103b8a:	84 c0                	test   %al,%al
80103b8c:	74 07                	je     80103b95 <mpconfig+0xa0>
    return 0;
80103b8e:	b8 00 00 00 00       	mov    $0x0,%eax
80103b93:	eb 0b                	jmp    80103ba0 <mpconfig+0xab>
  *pmp = mp;
80103b95:	8b 45 08             	mov    0x8(%ebp),%eax
80103b98:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b9b:	89 10                	mov    %edx,(%eax)
  return conf;
80103b9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103ba0:	c9                   	leave  
80103ba1:	c3                   	ret    

80103ba2 <mpinit>:

void
mpinit(void)
{
80103ba2:	55                   	push   %ebp
80103ba3:	89 e5                	mov    %esp,%ebp
80103ba5:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103ba8:	c7 05 44 b6 10 80 60 	movl   $0x80112360,0x8010b644
80103baf:	23 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103bb2:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103bb5:	89 04 24             	mov    %eax,(%esp)
80103bb8:	e8 38 ff ff ff       	call   80103af5 <mpconfig>
80103bbd:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103bc0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bc4:	75 05                	jne    80103bcb <mpinit+0x29>
    return;
80103bc6:	e9 9c 01 00 00       	jmp    80103d67 <mpinit+0x1c5>
  ismp = 1;
80103bcb:	c7 05 44 23 11 80 01 	movl   $0x1,0x80112344
80103bd2:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103bd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bd8:	8b 40 24             	mov    0x24(%eax),%eax
80103bdb:	a3 5c 22 11 80       	mov    %eax,0x8011225c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103be0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103be3:	83 c0 2c             	add    $0x2c,%eax
80103be6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103be9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bec:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103bf0:	0f b7 d0             	movzwl %ax,%edx
80103bf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bf6:	01 d0                	add    %edx,%eax
80103bf8:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103bfb:	e9 f4 00 00 00       	jmp    80103cf4 <mpinit+0x152>
    switch(*p){
80103c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c03:	0f b6 00             	movzbl (%eax),%eax
80103c06:	0f b6 c0             	movzbl %al,%eax
80103c09:	83 f8 04             	cmp    $0x4,%eax
80103c0c:	0f 87 bf 00 00 00    	ja     80103cd1 <mpinit+0x12f>
80103c12:	8b 04 85 60 89 10 80 	mov    -0x7fef76a0(,%eax,4),%eax
80103c19:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c1e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103c21:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c24:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c28:	0f b6 d0             	movzbl %al,%edx
80103c2b:	a1 c0 29 11 80       	mov    0x801129c0,%eax
80103c30:	39 c2                	cmp    %eax,%edx
80103c32:	74 2d                	je     80103c61 <mpinit+0xbf>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103c34:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c37:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c3b:	0f b6 d0             	movzbl %al,%edx
80103c3e:	a1 c0 29 11 80       	mov    0x801129c0,%eax
80103c43:	89 54 24 08          	mov    %edx,0x8(%esp)
80103c47:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c4b:	c7 04 24 22 89 10 80 	movl   $0x80108922,(%esp)
80103c52:	e8 49 c7 ff ff       	call   801003a0 <cprintf>
        ismp = 0;
80103c57:	c7 05 44 23 11 80 00 	movl   $0x0,0x80112344
80103c5e:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103c61:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c64:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103c68:	0f b6 c0             	movzbl %al,%eax
80103c6b:	83 e0 02             	and    $0x2,%eax
80103c6e:	85 c0                	test   %eax,%eax
80103c70:	74 15                	je     80103c87 <mpinit+0xe5>
        bcpu = &cpus[ncpu];
80103c72:	a1 c0 29 11 80       	mov    0x801129c0,%eax
80103c77:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80103c7d:	05 60 23 11 80       	add    $0x80112360,%eax
80103c82:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103c87:	8b 15 c0 29 11 80    	mov    0x801129c0,%edx
80103c8d:	a1 c0 29 11 80       	mov    0x801129c0,%eax
80103c92:	69 d2 cc 00 00 00    	imul   $0xcc,%edx,%edx
80103c98:	81 c2 60 23 11 80    	add    $0x80112360,%edx
80103c9e:	88 02                	mov    %al,(%edx)
      ncpu++;
80103ca0:	a1 c0 29 11 80       	mov    0x801129c0,%eax
80103ca5:	83 c0 01             	add    $0x1,%eax
80103ca8:	a3 c0 29 11 80       	mov    %eax,0x801129c0
      p += sizeof(struct mpproc);
80103cad:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103cb1:	eb 41                	jmp    80103cf4 <mpinit+0x152>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103cb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103cbc:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cc0:	a2 40 23 11 80       	mov    %al,0x80112340
      p += sizeof(struct mpioapic);
80103cc5:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cc9:	eb 29                	jmp    80103cf4 <mpinit+0x152>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103ccb:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103ccf:	eb 23                	jmp    80103cf4 <mpinit+0x152>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd4:	0f b6 00             	movzbl (%eax),%eax
80103cd7:	0f b6 c0             	movzbl %al,%eax
80103cda:	89 44 24 04          	mov    %eax,0x4(%esp)
80103cde:	c7 04 24 40 89 10 80 	movl   $0x80108940,(%esp)
80103ce5:	e8 b6 c6 ff ff       	call   801003a0 <cprintf>
      ismp = 0;
80103cea:	c7 05 44 23 11 80 00 	movl   $0x0,0x80112344
80103cf1:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103cfa:	0f 82 00 ff ff ff    	jb     80103c00 <mpinit+0x5e>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103d00:	a1 44 23 11 80       	mov    0x80112344,%eax
80103d05:	85 c0                	test   %eax,%eax
80103d07:	75 1d                	jne    80103d26 <mpinit+0x184>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103d09:	c7 05 c0 29 11 80 01 	movl   $0x1,0x801129c0
80103d10:	00 00 00 
    lapic = 0;
80103d13:	c7 05 5c 22 11 80 00 	movl   $0x0,0x8011225c
80103d1a:	00 00 00 
    ioapicid = 0;
80103d1d:	c6 05 40 23 11 80 00 	movb   $0x0,0x80112340
    return;
80103d24:	eb 41                	jmp    80103d67 <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103d26:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d29:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d2d:	84 c0                	test   %al,%al
80103d2f:	74 36                	je     80103d67 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d31:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103d38:	00 
80103d39:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103d40:	e8 0d fc ff ff       	call   80103952 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d45:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d4c:	e8 e4 fb ff ff       	call   80103935 <inb>
80103d51:	83 c8 01             	or     $0x1,%eax
80103d54:	0f b6 c0             	movzbl %al,%eax
80103d57:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d5b:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d62:	e8 eb fb ff ff       	call   80103952 <outb>
  }
}
80103d67:	c9                   	leave  
80103d68:	c3                   	ret    

80103d69 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d69:	55                   	push   %ebp
80103d6a:	89 e5                	mov    %esp,%ebp
80103d6c:	83 ec 08             	sub    $0x8,%esp
80103d6f:	8b 55 08             	mov    0x8(%ebp),%edx
80103d72:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d75:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103d79:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d7c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103d80:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103d84:	ee                   	out    %al,(%dx)
}
80103d85:	c9                   	leave  
80103d86:	c3                   	ret    

80103d87 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103d87:	55                   	push   %ebp
80103d88:	89 e5                	mov    %esp,%ebp
80103d8a:	83 ec 0c             	sub    $0xc,%esp
80103d8d:	8b 45 08             	mov    0x8(%ebp),%eax
80103d90:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103d94:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103d98:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103d9e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103da2:	0f b6 c0             	movzbl %al,%eax
80103da5:	89 44 24 04          	mov    %eax,0x4(%esp)
80103da9:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103db0:	e8 b4 ff ff ff       	call   80103d69 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103db5:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103db9:	66 c1 e8 08          	shr    $0x8,%ax
80103dbd:	0f b6 c0             	movzbl %al,%eax
80103dc0:	89 44 24 04          	mov    %eax,0x4(%esp)
80103dc4:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103dcb:	e8 99 ff ff ff       	call   80103d69 <outb>
}
80103dd0:	c9                   	leave  
80103dd1:	c3                   	ret    

80103dd2 <picenable>:

void
picenable(int irq)
{
80103dd2:	55                   	push   %ebp
80103dd3:	89 e5                	mov    %esp,%ebp
80103dd5:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103dd8:	8b 45 08             	mov    0x8(%ebp),%eax
80103ddb:	ba 01 00 00 00       	mov    $0x1,%edx
80103de0:	89 c1                	mov    %eax,%ecx
80103de2:	d3 e2                	shl    %cl,%edx
80103de4:	89 d0                	mov    %edx,%eax
80103de6:	f7 d0                	not    %eax
80103de8:	89 c2                	mov    %eax,%edx
80103dea:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103df1:	21 d0                	and    %edx,%eax
80103df3:	0f b7 c0             	movzwl %ax,%eax
80103df6:	89 04 24             	mov    %eax,(%esp)
80103df9:	e8 89 ff ff ff       	call   80103d87 <picsetmask>
}
80103dfe:	c9                   	leave  
80103dff:	c3                   	ret    

80103e00 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103e00:	55                   	push   %ebp
80103e01:	89 e5                	mov    %esp,%ebp
80103e03:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e06:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e0d:	00 
80103e0e:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e15:	e8 4f ff ff ff       	call   80103d69 <outb>
  outb(IO_PIC2+1, 0xFF);
80103e1a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e21:	00 
80103e22:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e29:	e8 3b ff ff ff       	call   80103d69 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103e2e:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e35:	00 
80103e36:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103e3d:	e8 27 ff ff ff       	call   80103d69 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103e42:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103e49:	00 
80103e4a:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e51:	e8 13 ff ff ff       	call   80103d69 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103e56:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103e5d:	00 
80103e5e:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e65:	e8 ff fe ff ff       	call   80103d69 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103e6a:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103e71:	00 
80103e72:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e79:	e8 eb fe ff ff       	call   80103d69 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103e7e:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e85:	00 
80103e86:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103e8d:	e8 d7 fe ff ff       	call   80103d69 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103e92:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103e99:	00 
80103e9a:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ea1:	e8 c3 fe ff ff       	call   80103d69 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103ea6:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103ead:	00 
80103eae:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103eb5:	e8 af fe ff ff       	call   80103d69 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103eba:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103ec1:	00 
80103ec2:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ec9:	e8 9b fe ff ff       	call   80103d69 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103ece:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103ed5:	00 
80103ed6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103edd:	e8 87 fe ff ff       	call   80103d69 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103ee2:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103ee9:	00 
80103eea:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ef1:	e8 73 fe ff ff       	call   80103d69 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103ef6:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103efd:	00 
80103efe:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f05:	e8 5f fe ff ff       	call   80103d69 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103f0a:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f11:	00 
80103f12:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f19:	e8 4b fe ff ff       	call   80103d69 <outb>

  if(irqmask != 0xFFFF)
80103f1e:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f25:	66 83 f8 ff          	cmp    $0xffff,%ax
80103f29:	74 12                	je     80103f3d <picinit+0x13d>
    picsetmask(irqmask);
80103f2b:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f32:	0f b7 c0             	movzwl %ax,%eax
80103f35:	89 04 24             	mov    %eax,(%esp)
80103f38:	e8 4a fe ff ff       	call   80103d87 <picsetmask>
}
80103f3d:	c9                   	leave  
80103f3e:	c3                   	ret    

80103f3f <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103f3f:	55                   	push   %ebp
80103f40:	89 e5                	mov    %esp,%ebp
80103f42:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103f45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103f4c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f4f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103f55:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f58:	8b 10                	mov    (%eax),%edx
80103f5a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f5d:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103f5f:	e8 c2 cf ff ff       	call   80100f26 <filealloc>
80103f64:	8b 55 08             	mov    0x8(%ebp),%edx
80103f67:	89 02                	mov    %eax,(%edx)
80103f69:	8b 45 08             	mov    0x8(%ebp),%eax
80103f6c:	8b 00                	mov    (%eax),%eax
80103f6e:	85 c0                	test   %eax,%eax
80103f70:	0f 84 c8 00 00 00    	je     8010403e <pipealloc+0xff>
80103f76:	e8 ab cf ff ff       	call   80100f26 <filealloc>
80103f7b:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f7e:	89 02                	mov    %eax,(%edx)
80103f80:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f83:	8b 00                	mov    (%eax),%eax
80103f85:	85 c0                	test   %eax,%eax
80103f87:	0f 84 b1 00 00 00    	je     8010403e <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103f8d:	e8 50 eb ff ff       	call   80102ae2 <kalloc>
80103f92:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f95:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f99:	75 05                	jne    80103fa0 <pipealloc+0x61>
    goto bad;
80103f9b:	e9 9e 00 00 00       	jmp    8010403e <pipealloc+0xff>
  p->readopen = 1;
80103fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fa3:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103faa:	00 00 00 
  p->writeopen = 1;
80103fad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fb0:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103fb7:	00 00 00 
  p->nwrite = 0;
80103fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fbd:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103fc4:	00 00 00 
  p->nread = 0;
80103fc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fca:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103fd1:	00 00 00 
  initlock(&p->lock, "pipe");
80103fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fd7:	c7 44 24 04 74 89 10 	movl   $0x80108974,0x4(%esp)
80103fde:	80 
80103fdf:	89 04 24             	mov    %eax,(%esp)
80103fe2:	e8 09 0e 00 00       	call   80104df0 <initlock>
  (*f0)->type = FD_PIPE;
80103fe7:	8b 45 08             	mov    0x8(%ebp),%eax
80103fea:	8b 00                	mov    (%eax),%eax
80103fec:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103ff2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff5:	8b 00                	mov    (%eax),%eax
80103ff7:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103ffb:	8b 45 08             	mov    0x8(%ebp),%eax
80103ffe:	8b 00                	mov    (%eax),%eax
80104000:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104004:	8b 45 08             	mov    0x8(%ebp),%eax
80104007:	8b 00                	mov    (%eax),%eax
80104009:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010400c:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010400f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104012:	8b 00                	mov    (%eax),%eax
80104014:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010401a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010401d:	8b 00                	mov    (%eax),%eax
8010401f:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104023:	8b 45 0c             	mov    0xc(%ebp),%eax
80104026:	8b 00                	mov    (%eax),%eax
80104028:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010402c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010402f:	8b 00                	mov    (%eax),%eax
80104031:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104034:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104037:	b8 00 00 00 00       	mov    $0x0,%eax
8010403c:	eb 42                	jmp    80104080 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
8010403e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104042:	74 0b                	je     8010404f <pipealloc+0x110>
    kfree((char*)p);
80104044:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104047:	89 04 24             	mov    %eax,(%esp)
8010404a:	e8 fa e9 ff ff       	call   80102a49 <kfree>
  if(*f0)
8010404f:	8b 45 08             	mov    0x8(%ebp),%eax
80104052:	8b 00                	mov    (%eax),%eax
80104054:	85 c0                	test   %eax,%eax
80104056:	74 0d                	je     80104065 <pipealloc+0x126>
    fileclose(*f0);
80104058:	8b 45 08             	mov    0x8(%ebp),%eax
8010405b:	8b 00                	mov    (%eax),%eax
8010405d:	89 04 24             	mov    %eax,(%esp)
80104060:	e8 69 cf ff ff       	call   80100fce <fileclose>
  if(*f1)
80104065:	8b 45 0c             	mov    0xc(%ebp),%eax
80104068:	8b 00                	mov    (%eax),%eax
8010406a:	85 c0                	test   %eax,%eax
8010406c:	74 0d                	je     8010407b <pipealloc+0x13c>
    fileclose(*f1);
8010406e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104071:	8b 00                	mov    (%eax),%eax
80104073:	89 04 24             	mov    %eax,(%esp)
80104076:	e8 53 cf ff ff       	call   80100fce <fileclose>
  return -1;
8010407b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104080:	c9                   	leave  
80104081:	c3                   	ret    

80104082 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104082:	55                   	push   %ebp
80104083:	89 e5                	mov    %esp,%ebp
80104085:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104088:	8b 45 08             	mov    0x8(%ebp),%eax
8010408b:	89 04 24             	mov    %eax,(%esp)
8010408e:	e8 7e 0d 00 00       	call   80104e11 <acquire>
  if(writable){
80104093:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104097:	74 1f                	je     801040b8 <pipeclose+0x36>
    p->writeopen = 0;
80104099:	8b 45 08             	mov    0x8(%ebp),%eax
8010409c:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801040a3:	00 00 00 
    wakeup(&p->nread);
801040a6:	8b 45 08             	mov    0x8(%ebp),%eax
801040a9:	05 34 02 00 00       	add    $0x234,%eax
801040ae:	89 04 24             	mov    %eax,(%esp)
801040b1:	e8 6a 0b 00 00       	call   80104c20 <wakeup>
801040b6:	eb 1d                	jmp    801040d5 <pipeclose+0x53>
  } else {
    p->readopen = 0;
801040b8:	8b 45 08             	mov    0x8(%ebp),%eax
801040bb:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801040c2:	00 00 00 
    wakeup(&p->nwrite);
801040c5:	8b 45 08             	mov    0x8(%ebp),%eax
801040c8:	05 38 02 00 00       	add    $0x238,%eax
801040cd:	89 04 24             	mov    %eax,(%esp)
801040d0:	e8 4b 0b 00 00       	call   80104c20 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
801040d5:	8b 45 08             	mov    0x8(%ebp),%eax
801040d8:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801040de:	85 c0                	test   %eax,%eax
801040e0:	75 25                	jne    80104107 <pipeclose+0x85>
801040e2:	8b 45 08             	mov    0x8(%ebp),%eax
801040e5:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801040eb:	85 c0                	test   %eax,%eax
801040ed:	75 18                	jne    80104107 <pipeclose+0x85>
    release(&p->lock);
801040ef:	8b 45 08             	mov    0x8(%ebp),%eax
801040f2:	89 04 24             	mov    %eax,(%esp)
801040f5:	e8 79 0d 00 00       	call   80104e73 <release>
    kfree((char*)p);
801040fa:	8b 45 08             	mov    0x8(%ebp),%eax
801040fd:	89 04 24             	mov    %eax,(%esp)
80104100:	e8 44 e9 ff ff       	call   80102a49 <kfree>
80104105:	eb 0b                	jmp    80104112 <pipeclose+0x90>
  } else
    release(&p->lock);
80104107:	8b 45 08             	mov    0x8(%ebp),%eax
8010410a:	89 04 24             	mov    %eax,(%esp)
8010410d:	e8 61 0d 00 00       	call   80104e73 <release>
}
80104112:	c9                   	leave  
80104113:	c3                   	ret    

80104114 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104114:	55                   	push   %ebp
80104115:	89 e5                	mov    %esp,%ebp
80104117:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
8010411a:	8b 45 08             	mov    0x8(%ebp),%eax
8010411d:	89 04 24             	mov    %eax,(%esp)
80104120:	e8 ec 0c 00 00       	call   80104e11 <acquire>
  for(i = 0; i < n; i++){
80104125:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010412c:	e9 a6 00 00 00       	jmp    801041d7 <pipewrite+0xc3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104131:	eb 57                	jmp    8010418a <pipewrite+0x76>
      if(p->readopen == 0 || proc->killed){
80104133:	8b 45 08             	mov    0x8(%ebp),%eax
80104136:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010413c:	85 c0                	test   %eax,%eax
8010413e:	74 0d                	je     8010414d <pipewrite+0x39>
80104140:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104146:	8b 40 24             	mov    0x24(%eax),%eax
80104149:	85 c0                	test   %eax,%eax
8010414b:	74 15                	je     80104162 <pipewrite+0x4e>
        release(&p->lock);
8010414d:	8b 45 08             	mov    0x8(%ebp),%eax
80104150:	89 04 24             	mov    %eax,(%esp)
80104153:	e8 1b 0d 00 00       	call   80104e73 <release>
        return -1;
80104158:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010415d:	e9 9f 00 00 00       	jmp    80104201 <pipewrite+0xed>
      }
      wakeup(&p->nread);
80104162:	8b 45 08             	mov    0x8(%ebp),%eax
80104165:	05 34 02 00 00       	add    $0x234,%eax
8010416a:	89 04 24             	mov    %eax,(%esp)
8010416d:	e8 ae 0a 00 00       	call   80104c20 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104172:	8b 45 08             	mov    0x8(%ebp),%eax
80104175:	8b 55 08             	mov    0x8(%ebp),%edx
80104178:	81 c2 38 02 00 00    	add    $0x238,%edx
8010417e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104182:	89 14 24             	mov    %edx,(%esp)
80104185:	e8 bd 09 00 00       	call   80104b47 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010418a:	8b 45 08             	mov    0x8(%ebp),%eax
8010418d:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104193:	8b 45 08             	mov    0x8(%ebp),%eax
80104196:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010419c:	05 00 02 00 00       	add    $0x200,%eax
801041a1:	39 c2                	cmp    %eax,%edx
801041a3:	74 8e                	je     80104133 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801041a5:	8b 45 08             	mov    0x8(%ebp),%eax
801041a8:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041ae:	8d 48 01             	lea    0x1(%eax),%ecx
801041b1:	8b 55 08             	mov    0x8(%ebp),%edx
801041b4:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801041ba:	25 ff 01 00 00       	and    $0x1ff,%eax
801041bf:	89 c1                	mov    %eax,%ecx
801041c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801041c7:	01 d0                	add    %edx,%eax
801041c9:	0f b6 10             	movzbl (%eax),%edx
801041cc:	8b 45 08             	mov    0x8(%ebp),%eax
801041cf:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801041d3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801041d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041da:	3b 45 10             	cmp    0x10(%ebp),%eax
801041dd:	0f 8c 4e ff ff ff    	jl     80104131 <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801041e3:	8b 45 08             	mov    0x8(%ebp),%eax
801041e6:	05 34 02 00 00       	add    $0x234,%eax
801041eb:	89 04 24             	mov    %eax,(%esp)
801041ee:	e8 2d 0a 00 00       	call   80104c20 <wakeup>
  release(&p->lock);
801041f3:	8b 45 08             	mov    0x8(%ebp),%eax
801041f6:	89 04 24             	mov    %eax,(%esp)
801041f9:	e8 75 0c 00 00       	call   80104e73 <release>
  return n;
801041fe:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104201:	c9                   	leave  
80104202:	c3                   	ret    

80104203 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104203:	55                   	push   %ebp
80104204:	89 e5                	mov    %esp,%ebp
80104206:	53                   	push   %ebx
80104207:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
8010420a:	8b 45 08             	mov    0x8(%ebp),%eax
8010420d:	89 04 24             	mov    %eax,(%esp)
80104210:	e8 fc 0b 00 00       	call   80104e11 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104215:	eb 3a                	jmp    80104251 <piperead+0x4e>
    if(proc->killed){
80104217:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010421d:	8b 40 24             	mov    0x24(%eax),%eax
80104220:	85 c0                	test   %eax,%eax
80104222:	74 15                	je     80104239 <piperead+0x36>
      release(&p->lock);
80104224:	8b 45 08             	mov    0x8(%ebp),%eax
80104227:	89 04 24             	mov    %eax,(%esp)
8010422a:	e8 44 0c 00 00       	call   80104e73 <release>
      return -1;
8010422f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104234:	e9 b5 00 00 00       	jmp    801042ee <piperead+0xeb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104239:	8b 45 08             	mov    0x8(%ebp),%eax
8010423c:	8b 55 08             	mov    0x8(%ebp),%edx
8010423f:	81 c2 34 02 00 00    	add    $0x234,%edx
80104245:	89 44 24 04          	mov    %eax,0x4(%esp)
80104249:	89 14 24             	mov    %edx,(%esp)
8010424c:	e8 f6 08 00 00       	call   80104b47 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104251:	8b 45 08             	mov    0x8(%ebp),%eax
80104254:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010425a:	8b 45 08             	mov    0x8(%ebp),%eax
8010425d:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104263:	39 c2                	cmp    %eax,%edx
80104265:	75 0d                	jne    80104274 <piperead+0x71>
80104267:	8b 45 08             	mov    0x8(%ebp),%eax
8010426a:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104270:	85 c0                	test   %eax,%eax
80104272:	75 a3                	jne    80104217 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104274:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010427b:	eb 4b                	jmp    801042c8 <piperead+0xc5>
    if(p->nread == p->nwrite)
8010427d:	8b 45 08             	mov    0x8(%ebp),%eax
80104280:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104286:	8b 45 08             	mov    0x8(%ebp),%eax
80104289:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010428f:	39 c2                	cmp    %eax,%edx
80104291:	75 02                	jne    80104295 <piperead+0x92>
      break;
80104293:	eb 3b                	jmp    801042d0 <piperead+0xcd>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104295:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104298:	8b 45 0c             	mov    0xc(%ebp),%eax
8010429b:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010429e:	8b 45 08             	mov    0x8(%ebp),%eax
801042a1:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042a7:	8d 48 01             	lea    0x1(%eax),%ecx
801042aa:	8b 55 08             	mov    0x8(%ebp),%edx
801042ad:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801042b3:	25 ff 01 00 00       	and    $0x1ff,%eax
801042b8:	89 c2                	mov    %eax,%edx
801042ba:	8b 45 08             	mov    0x8(%ebp),%eax
801042bd:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
801042c2:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042c4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042cb:	3b 45 10             	cmp    0x10(%ebp),%eax
801042ce:	7c ad                	jl     8010427d <piperead+0x7a>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801042d0:	8b 45 08             	mov    0x8(%ebp),%eax
801042d3:	05 38 02 00 00       	add    $0x238,%eax
801042d8:	89 04 24             	mov    %eax,(%esp)
801042db:	e8 40 09 00 00       	call   80104c20 <wakeup>
  release(&p->lock);
801042e0:	8b 45 08             	mov    0x8(%ebp),%eax
801042e3:	89 04 24             	mov    %eax,(%esp)
801042e6:	e8 88 0b 00 00       	call   80104e73 <release>
  return i;
801042eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801042ee:	83 c4 24             	add    $0x24,%esp
801042f1:	5b                   	pop    %ebx
801042f2:	5d                   	pop    %ebp
801042f3:	c3                   	ret    

801042f4 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801042f4:	55                   	push   %ebp
801042f5:	89 e5                	mov    %esp,%ebp
801042f7:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801042fa:	9c                   	pushf  
801042fb:	58                   	pop    %eax
801042fc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801042ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104302:	c9                   	leave  
80104303:	c3                   	ret    

80104304 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104304:	55                   	push   %ebp
80104305:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104307:	fb                   	sti    
}
80104308:	5d                   	pop    %ebp
80104309:	c3                   	ret    

8010430a <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010430a:	55                   	push   %ebp
8010430b:	89 e5                	mov    %esp,%ebp
8010430d:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104310:	c7 44 24 04 79 89 10 	movl   $0x80108979,0x4(%esp)
80104317:	80 
80104318:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
8010431f:	e8 cc 0a 00 00       	call   80104df0 <initlock>
}
80104324:	c9                   	leave  
80104325:	c3                   	ret    

80104326 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104326:	55                   	push   %ebp
80104327:	89 e5                	mov    %esp,%ebp
80104329:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010432c:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104333:	e8 d9 0a 00 00       	call   80104e11 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104338:	c7 45 f4 14 2a 11 80 	movl   $0x80112a14,-0xc(%ebp)
8010433f:	eb 50                	jmp    80104391 <allocproc+0x6b>
    if(p->state == UNUSED)
80104341:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104344:	8b 40 0c             	mov    0xc(%eax),%eax
80104347:	85 c0                	test   %eax,%eax
80104349:	75 42                	jne    8010438d <allocproc+0x67>
      goto found;
8010434b:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010434c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434f:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104356:	a1 04 b0 10 80       	mov    0x8010b004,%eax
8010435b:	8d 50 01             	lea    0x1(%eax),%edx
8010435e:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
80104364:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104367:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
8010436a:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104371:	e8 fd 0a 00 00       	call   80104e73 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104376:	e8 67 e7 ff ff       	call   80102ae2 <kalloc>
8010437b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010437e:	89 42 08             	mov    %eax,0x8(%edx)
80104381:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104384:	8b 40 08             	mov    0x8(%eax),%eax
80104387:	85 c0                	test   %eax,%eax
80104389:	75 33                	jne    801043be <allocproc+0x98>
8010438b:	eb 20                	jmp    801043ad <allocproc+0x87>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010438d:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104391:	81 7d f4 14 49 11 80 	cmpl   $0x80114914,-0xc(%ebp)
80104398:	72 a7                	jb     80104341 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
8010439a:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
801043a1:	e8 cd 0a 00 00       	call   80104e73 <release>
  return 0;
801043a6:	b8 00 00 00 00       	mov    $0x0,%eax
801043ab:	eb 76                	jmp    80104423 <allocproc+0xfd>
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
801043ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801043b7:	b8 00 00 00 00       	mov    $0x0,%eax
801043bc:	eb 65                	jmp    80104423 <allocproc+0xfd>
  }
  sp = p->kstack + KSTACKSIZE;
801043be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c1:	8b 40 08             	mov    0x8(%eax),%eax
801043c4:	05 00 10 00 00       	add    $0x1000,%eax
801043c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801043cc:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801043d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043d6:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801043d9:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801043dd:	ba 79 64 10 80       	mov    $0x80106479,%edx
801043e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043e5:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801043e7:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801043eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ee:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043f1:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801043f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f7:	8b 40 1c             	mov    0x1c(%eax),%eax
801043fa:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104401:	00 
80104402:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104409:	00 
8010440a:	89 04 24             	mov    %eax,(%esp)
8010440d:	e8 53 0c 00 00       	call   80105065 <memset>
  p->context->eip = (uint)forkret;
80104412:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104415:	8b 40 1c             	mov    0x1c(%eax),%eax
80104418:	ba 1b 4b 10 80       	mov    $0x80104b1b,%edx
8010441d:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104420:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104423:	c9                   	leave  
80104424:	c3                   	ret    

80104425 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104425:	55                   	push   %ebp
80104426:	89 e5                	mov    %esp,%ebp
80104428:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
8010442b:	e8 f6 fe ff ff       	call   80104326 <allocproc>
80104430:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104433:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104436:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm()) == 0)
8010443b:	e8 90 37 00 00       	call   80107bd0 <setupkvm>
80104440:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104443:	89 42 04             	mov    %eax,0x4(%edx)
80104446:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104449:	8b 40 04             	mov    0x4(%eax),%eax
8010444c:	85 c0                	test   %eax,%eax
8010444e:	75 0c                	jne    8010445c <userinit+0x37>
    panic("userinit: out of memory?");
80104450:	c7 04 24 80 89 10 80 	movl   $0x80108980,(%esp)
80104457:	e8 de c0 ff ff       	call   8010053a <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010445c:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104464:	8b 40 04             	mov    0x4(%eax),%eax
80104467:	89 54 24 08          	mov    %edx,0x8(%esp)
8010446b:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
80104472:	80 
80104473:	89 04 24             	mov    %eax,(%esp)
80104476:	e8 a9 39 00 00       	call   80107e24 <inituvm>
  p->sz = PGSIZE;
8010447b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447e:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104484:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104487:	8b 40 18             	mov    0x18(%eax),%eax
8010448a:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104491:	00 
80104492:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104499:	00 
8010449a:	89 04 24             	mov    %eax,(%esp)
8010449d:	e8 c3 0b 00 00       	call   80105065 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801044a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a5:	8b 40 18             	mov    0x18(%eax),%eax
801044a8:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801044ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b1:	8b 40 18             	mov    0x18(%eax),%eax
801044b4:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
801044ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044bd:	8b 40 18             	mov    0x18(%eax),%eax
801044c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044c3:	8b 52 18             	mov    0x18(%edx),%edx
801044c6:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801044ca:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801044ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d1:	8b 40 18             	mov    0x18(%eax),%eax
801044d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044d7:	8b 52 18             	mov    0x18(%edx),%edx
801044da:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801044de:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801044e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e5:	8b 40 18             	mov    0x18(%eax),%eax
801044e8:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801044ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f2:	8b 40 18             	mov    0x18(%eax),%eax
801044f5:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801044fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ff:	8b 40 18             	mov    0x18(%eax),%eax
80104502:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450c:	83 c0 6c             	add    $0x6c,%eax
8010450f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104516:	00 
80104517:	c7 44 24 04 99 89 10 	movl   $0x80108999,0x4(%esp)
8010451e:	80 
8010451f:	89 04 24             	mov    %eax,(%esp)
80104522:	e8 5e 0d 00 00       	call   80105285 <safestrcpy>
  p->cwd = namei("/");
80104527:	c7 04 24 a2 89 10 80 	movl   $0x801089a2,(%esp)
8010452e:	e8 d3 de ff ff       	call   80102406 <namei>
80104533:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104536:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
80104539:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104543:	c9                   	leave  
80104544:	c3                   	ret    

80104545 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104545:	55                   	push   %ebp
80104546:	89 e5                	mov    %esp,%ebp
80104548:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
8010454b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104551:	8b 00                	mov    (%eax),%eax
80104553:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104556:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010455a:	7e 34                	jle    80104590 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
8010455c:	8b 55 08             	mov    0x8(%ebp),%edx
8010455f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104562:	01 c2                	add    %eax,%edx
80104564:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010456a:	8b 40 04             	mov    0x4(%eax),%eax
8010456d:	89 54 24 08          	mov    %edx,0x8(%esp)
80104571:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104574:	89 54 24 04          	mov    %edx,0x4(%esp)
80104578:	89 04 24             	mov    %eax,(%esp)
8010457b:	e8 1a 3a 00 00       	call   80107f9a <allocuvm>
80104580:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104583:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104587:	75 41                	jne    801045ca <growproc+0x85>
      return -1;
80104589:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010458e:	eb 58                	jmp    801045e8 <growproc+0xa3>
  } else if(n < 0){
80104590:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104594:	79 34                	jns    801045ca <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104596:	8b 55 08             	mov    0x8(%ebp),%edx
80104599:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459c:	01 c2                	add    %eax,%edx
8010459e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045a4:	8b 40 04             	mov    0x4(%eax),%eax
801045a7:	89 54 24 08          	mov    %edx,0x8(%esp)
801045ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045ae:	89 54 24 04          	mov    %edx,0x4(%esp)
801045b2:	89 04 24             	mov    %eax,(%esp)
801045b5:	e8 ba 3a 00 00       	call   80108074 <deallocuvm>
801045ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045c1:	75 07                	jne    801045ca <growproc+0x85>
      return -1;
801045c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045c8:	eb 1e                	jmp    801045e8 <growproc+0xa3>
  }
  proc->sz = sz;
801045ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045d3:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
801045d5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045db:	89 04 24             	mov    %eax,(%esp)
801045de:	e8 eb 36 00 00       	call   80107cce <switchuvm>
  return 0;
801045e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801045e8:	c9                   	leave  
801045e9:	c3                   	ret    

801045ea <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801045ea:	55                   	push   %ebp
801045eb:	89 e5                	mov    %esp,%ebp
801045ed:	57                   	push   %edi
801045ee:	56                   	push   %esi
801045ef:	53                   	push   %ebx
801045f0:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
801045f3:	e8 2e fd ff ff       	call   80104326 <allocproc>
801045f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
801045fb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801045ff:	75 0a                	jne    8010460b <fork+0x21>
    return -1;
80104601:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104606:	e9 52 01 00 00       	jmp    8010475d <fork+0x173>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010460b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104611:	8b 10                	mov    (%eax),%edx
80104613:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104619:	8b 40 04             	mov    0x4(%eax),%eax
8010461c:	89 54 24 04          	mov    %edx,0x4(%esp)
80104620:	89 04 24             	mov    %eax,(%esp)
80104623:	e8 e8 3b 00 00       	call   80108210 <copyuvm>
80104628:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010462b:	89 42 04             	mov    %eax,0x4(%edx)
8010462e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104631:	8b 40 04             	mov    0x4(%eax),%eax
80104634:	85 c0                	test   %eax,%eax
80104636:	75 2c                	jne    80104664 <fork+0x7a>
    kfree(np->kstack);
80104638:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010463b:	8b 40 08             	mov    0x8(%eax),%eax
8010463e:	89 04 24             	mov    %eax,(%esp)
80104641:	e8 03 e4 ff ff       	call   80102a49 <kfree>
    np->kstack = 0;
80104646:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104649:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104650:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104653:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010465a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010465f:	e9 f9 00 00 00       	jmp    8010475d <fork+0x173>
  }
  np->sz = proc->sz;
80104664:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010466a:	8b 10                	mov    (%eax),%edx
8010466c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010466f:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104671:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104678:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010467b:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
8010467e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104681:	8b 50 18             	mov    0x18(%eax),%edx
80104684:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010468a:	8b 40 18             	mov    0x18(%eax),%eax
8010468d:	89 c3                	mov    %eax,%ebx
8010468f:	b8 13 00 00 00       	mov    $0x13,%eax
80104694:	89 d7                	mov    %edx,%edi
80104696:	89 de                	mov    %ebx,%esi
80104698:	89 c1                	mov    %eax,%ecx
8010469a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010469c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010469f:	8b 40 18             	mov    0x18(%eax),%eax
801046a2:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801046a9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801046b0:	eb 3d                	jmp    801046ef <fork+0x105>
    if(proc->ofile[i])
801046b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046bb:	83 c2 08             	add    $0x8,%edx
801046be:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046c2:	85 c0                	test   %eax,%eax
801046c4:	74 25                	je     801046eb <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
801046c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046cf:	83 c2 08             	add    $0x8,%edx
801046d2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046d6:	89 04 24             	mov    %eax,(%esp)
801046d9:	e8 a8 c8 ff ff       	call   80100f86 <filedup>
801046de:	8b 55 e0             	mov    -0x20(%ebp),%edx
801046e1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801046e4:	83 c1 08             	add    $0x8,%ecx
801046e7:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801046eb:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801046ef:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801046f3:	7e bd                	jle    801046b2 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
801046f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046fb:	8b 40 68             	mov    0x68(%eax),%eax
801046fe:	89 04 24             	mov    %eax,(%esp)
80104701:	e8 23 d1 ff ff       	call   80101829 <idup>
80104706:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104709:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
8010470c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104712:	8d 50 6c             	lea    0x6c(%eax),%edx
80104715:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104718:	83 c0 6c             	add    $0x6c,%eax
8010471b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104722:	00 
80104723:	89 54 24 04          	mov    %edx,0x4(%esp)
80104727:	89 04 24             	mov    %eax,(%esp)
8010472a:	e8 56 0b 00 00       	call   80105285 <safestrcpy>
 
  pid = np->pid;
8010472f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104732:	8b 40 10             	mov    0x10(%eax),%eax
80104735:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104738:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
8010473f:	e8 cd 06 00 00       	call   80104e11 <acquire>
  np->state = RUNNABLE;
80104744:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104747:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
8010474e:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104755:	e8 19 07 00 00       	call   80104e73 <release>
  
  return pid;
8010475a:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
8010475d:	83 c4 2c             	add    $0x2c,%esp
80104760:	5b                   	pop    %ebx
80104761:	5e                   	pop    %esi
80104762:	5f                   	pop    %edi
80104763:	5d                   	pop    %ebp
80104764:	c3                   	ret    

80104765 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104765:	55                   	push   %ebp
80104766:	89 e5                	mov    %esp,%ebp
80104768:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
8010476b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104772:	a1 48 b6 10 80       	mov    0x8010b648,%eax
80104777:	39 c2                	cmp    %eax,%edx
80104779:	75 0c                	jne    80104787 <exit+0x22>
    panic("init exiting");
8010477b:	c7 04 24 a4 89 10 80 	movl   $0x801089a4,(%esp)
80104782:	e8 b3 bd ff ff       	call   8010053a <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104787:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010478e:	eb 44                	jmp    801047d4 <exit+0x6f>
    if(proc->ofile[fd]){
80104790:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104796:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104799:	83 c2 08             	add    $0x8,%edx
8010479c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047a0:	85 c0                	test   %eax,%eax
801047a2:	74 2c                	je     801047d0 <exit+0x6b>
      fileclose(proc->ofile[fd]);
801047a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047aa:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047ad:	83 c2 08             	add    $0x8,%edx
801047b0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047b4:	89 04 24             	mov    %eax,(%esp)
801047b7:	e8 12 c8 ff ff       	call   80100fce <fileclose>
      proc->ofile[fd] = 0;
801047bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047c2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047c5:	83 c2 08             	add    $0x8,%edx
801047c8:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801047cf:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801047d0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801047d4:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801047d8:	7e b6                	jle    80104790 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
801047da:	e8 31 ec ff ff       	call   80103410 <begin_op>
  iput(proc->cwd);
801047df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047e5:	8b 40 68             	mov    0x68(%eax),%eax
801047e8:	89 04 24             	mov    %eax,(%esp)
801047eb:	e8 1e d2 ff ff       	call   80101a0e <iput>
  end_op();
801047f0:	e8 9f ec ff ff       	call   80103494 <end_op>
  proc->cwd = 0;
801047f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047fb:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104802:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104809:	e8 03 06 00 00       	call   80104e11 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
8010480e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104814:	8b 40 14             	mov    0x14(%eax),%eax
80104817:	89 04 24             	mov    %eax,(%esp)
8010481a:	e8 c3 03 00 00       	call   80104be2 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010481f:	c7 45 f4 14 2a 11 80 	movl   $0x80112a14,-0xc(%ebp)
80104826:	eb 38                	jmp    80104860 <exit+0xfb>
    if(p->parent == proc){
80104828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010482b:	8b 50 14             	mov    0x14(%eax),%edx
8010482e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104834:	39 c2                	cmp    %eax,%edx
80104836:	75 24                	jne    8010485c <exit+0xf7>
      p->parent = initproc;
80104838:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
8010483e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104841:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104844:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104847:	8b 40 0c             	mov    0xc(%eax),%eax
8010484a:	83 f8 05             	cmp    $0x5,%eax
8010484d:	75 0d                	jne    8010485c <exit+0xf7>
        wakeup1(initproc);
8010484f:	a1 48 b6 10 80       	mov    0x8010b648,%eax
80104854:	89 04 24             	mov    %eax,(%esp)
80104857:	e8 86 03 00 00       	call   80104be2 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010485c:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104860:	81 7d f4 14 49 11 80 	cmpl   $0x80114914,-0xc(%ebp)
80104867:	72 bf                	jb     80104828 <exit+0xc3>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104869:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010486f:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104876:	e8 bc 01 00 00       	call   80104a37 <sched>
  panic("zombie exit");
8010487b:	c7 04 24 b1 89 10 80 	movl   $0x801089b1,(%esp)
80104882:	e8 b3 bc ff ff       	call   8010053a <panic>

80104887 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104887:	55                   	push   %ebp
80104888:	89 e5                	mov    %esp,%ebp
8010488a:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
8010488d:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104894:	e8 78 05 00 00       	call   80104e11 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104899:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048a0:	c7 45 f4 14 2a 11 80 	movl   $0x80112a14,-0xc(%ebp)
801048a7:	e9 9a 00 00 00       	jmp    80104946 <wait+0xbf>
      if(p->parent != proc)
801048ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048af:	8b 50 14             	mov    0x14(%eax),%edx
801048b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048b8:	39 c2                	cmp    %eax,%edx
801048ba:	74 05                	je     801048c1 <wait+0x3a>
        continue;
801048bc:	e9 81 00 00 00       	jmp    80104942 <wait+0xbb>
      havekids = 1;
801048c1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801048c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048cb:	8b 40 0c             	mov    0xc(%eax),%eax
801048ce:	83 f8 05             	cmp    $0x5,%eax
801048d1:	75 6f                	jne    80104942 <wait+0xbb>
        // Found one.
        pid = p->pid;
801048d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d6:	8b 40 10             	mov    0x10(%eax),%eax
801048d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801048dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048df:	8b 40 08             	mov    0x8(%eax),%eax
801048e2:	89 04 24             	mov    %eax,(%esp)
801048e5:	e8 5f e1 ff ff       	call   80102a49 <kfree>
        p->kstack = 0;
801048ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ed:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801048f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f7:	8b 40 04             	mov    0x4(%eax),%eax
801048fa:	89 04 24             	mov    %eax,(%esp)
801048fd:	e8 2e 38 00 00       	call   80108130 <freevm>
        p->state = UNUSED;
80104902:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104905:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
8010490c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010490f:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104916:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104919:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104920:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104923:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104927:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010492a:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104931:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104938:	e8 36 05 00 00       	call   80104e73 <release>
        return pid;
8010493d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104940:	eb 52                	jmp    80104994 <wait+0x10d>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104942:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104946:	81 7d f4 14 49 11 80 	cmpl   $0x80114914,-0xc(%ebp)
8010494d:	0f 82 59 ff ff ff    	jb     801048ac <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104953:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104957:	74 0d                	je     80104966 <wait+0xdf>
80104959:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010495f:	8b 40 24             	mov    0x24(%eax),%eax
80104962:	85 c0                	test   %eax,%eax
80104964:	74 13                	je     80104979 <wait+0xf2>
      release(&ptable.lock);
80104966:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
8010496d:	e8 01 05 00 00       	call   80104e73 <release>
      return -1;
80104972:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104977:	eb 1b                	jmp    80104994 <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104979:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010497f:	c7 44 24 04 e0 29 11 	movl   $0x801129e0,0x4(%esp)
80104986:	80 
80104987:	89 04 24             	mov    %eax,(%esp)
8010498a:	e8 b8 01 00 00       	call   80104b47 <sleep>
  }
8010498f:	e9 05 ff ff ff       	jmp    80104899 <wait+0x12>
}
80104994:	c9                   	leave  
80104995:	c3                   	ret    

80104996 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104996:	55                   	push   %ebp
80104997:	89 e5                	mov    %esp,%ebp
80104999:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
8010499c:	e8 63 f9 ff ff       	call   80104304 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801049a1:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
801049a8:	e8 64 04 00 00       	call   80104e11 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049ad:	c7 45 f4 14 2a 11 80 	movl   $0x80112a14,-0xc(%ebp)
801049b4:	eb 67                	jmp    80104a1d <scheduler+0x87>
      if(p->state != RUNNABLE)
801049b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b9:	8b 40 0c             	mov    0xc(%eax),%eax
801049bc:	83 f8 03             	cmp    $0x3,%eax
801049bf:	74 02                	je     801049c3 <scheduler+0x2d>
        continue;
801049c1:	eb 56                	jmp    80104a19 <scheduler+0x83>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
801049c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c6:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
801049cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049cf:	89 04 24             	mov    %eax,(%esp)
801049d2:	e8 f7 32 00 00       	call   80107cce <switchuvm>
      p->state = RUNNING;
801049d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049da:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
801049e1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049e7:	8b 40 1c             	mov    0x1c(%eax),%eax
801049ea:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801049f1:	83 c2 08             	add    $0x8,%edx
801049f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801049f8:	89 14 24             	mov    %edx,(%esp)
801049fb:	e8 f6 08 00 00       	call   801052f6 <swtch>
      switchkvm(cpu);
80104a00:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104a06:	89 04 24             	mov    %eax,(%esp)
80104a09:	e8 9d 32 00 00       	call   80107cab <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104a0e:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104a15:	00 00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a19:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104a1d:	81 7d f4 14 49 11 80 	cmpl   $0x80114914,-0xc(%ebp)
80104a24:	72 90                	jb     801049b6 <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104a26:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104a2d:	e8 41 04 00 00       	call   80104e73 <release>

  }
80104a32:	e9 65 ff ff ff       	jmp    8010499c <scheduler+0x6>

80104a37 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104a37:	55                   	push   %ebp
80104a38:	89 e5                	mov    %esp,%ebp
80104a3a:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104a3d:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104a44:	e8 f2 04 00 00       	call   80104f3b <holding>
80104a49:	85 c0                	test   %eax,%eax
80104a4b:	75 0c                	jne    80104a59 <sched+0x22>
    panic("sched ptable.lock");
80104a4d:	c7 04 24 bd 89 10 80 	movl   $0x801089bd,(%esp)
80104a54:	e8 e1 ba ff ff       	call   8010053a <panic>
  if(cpu->ncli != 1)
80104a59:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104a5f:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104a65:	83 f8 01             	cmp    $0x1,%eax
80104a68:	74 0c                	je     80104a76 <sched+0x3f>
    panic("sched locks");
80104a6a:	c7 04 24 cf 89 10 80 	movl   $0x801089cf,(%esp)
80104a71:	e8 c4 ba ff ff       	call   8010053a <panic>
  if(proc->state == RUNNING)
80104a76:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a7c:	8b 40 0c             	mov    0xc(%eax),%eax
80104a7f:	83 f8 04             	cmp    $0x4,%eax
80104a82:	75 0c                	jne    80104a90 <sched+0x59>
    panic("sched running");
80104a84:	c7 04 24 db 89 10 80 	movl   $0x801089db,(%esp)
80104a8b:	e8 aa ba ff ff       	call   8010053a <panic>
  if(readeflags()&FL_IF)
80104a90:	e8 5f f8 ff ff       	call   801042f4 <readeflags>
80104a95:	25 00 02 00 00       	and    $0x200,%eax
80104a9a:	85 c0                	test   %eax,%eax
80104a9c:	74 0c                	je     80104aaa <sched+0x73>
    panic("sched interruptible");
80104a9e:	c7 04 24 e9 89 10 80 	movl   $0x801089e9,(%esp)
80104aa5:	e8 90 ba ff ff       	call   8010053a <panic>
  intena = cpu->intena;
80104aaa:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ab0:	8b 80 b4 00 00 00    	mov    0xb4(%eax),%eax
80104ab6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104ab9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104abf:	8b 40 08             	mov    0x8(%eax),%eax
80104ac2:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104ac9:	83 c2 1c             	add    $0x1c,%edx
80104acc:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ad0:	89 14 24             	mov    %edx,(%esp)
80104ad3:	e8 1e 08 00 00       	call   801052f6 <swtch>
  cpu->intena = intena;
80104ad8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ade:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ae1:	89 90 b4 00 00 00    	mov    %edx,0xb4(%eax)
}
80104ae7:	c9                   	leave  
80104ae8:	c3                   	ret    

80104ae9 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104ae9:	55                   	push   %ebp
80104aea:	89 e5                	mov    %esp,%ebp
80104aec:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104aef:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104af6:	e8 16 03 00 00       	call   80104e11 <acquire>
  proc->state = RUNNABLE;
80104afb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b01:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104b08:	e8 2a ff ff ff       	call   80104a37 <sched>
  release(&ptable.lock);
80104b0d:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104b14:	e8 5a 03 00 00       	call   80104e73 <release>
}
80104b19:	c9                   	leave  
80104b1a:	c3                   	ret    

80104b1b <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104b1b:	55                   	push   %ebp
80104b1c:	89 e5                	mov    %esp,%ebp
80104b1e:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104b21:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104b28:	e8 46 03 00 00       	call   80104e73 <release>

  if (first) {
80104b2d:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104b32:	85 c0                	test   %eax,%eax
80104b34:	74 0f                	je     80104b45 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104b36:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104b3d:	00 00 00 
    initlog();
80104b40:	e8 bd e6 ff ff       	call   80103202 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104b45:	c9                   	leave  
80104b46:	c3                   	ret    

80104b47 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104b47:	55                   	push   %ebp
80104b48:	89 e5                	mov    %esp,%ebp
80104b4a:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104b4d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b53:	85 c0                	test   %eax,%eax
80104b55:	75 0c                	jne    80104b63 <sleep+0x1c>
    panic("sleep");
80104b57:	c7 04 24 fd 89 10 80 	movl   $0x801089fd,(%esp)
80104b5e:	e8 d7 b9 ff ff       	call   8010053a <panic>

  if(lk == 0)
80104b63:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104b67:	75 0c                	jne    80104b75 <sleep+0x2e>
    panic("sleep without lk");
80104b69:	c7 04 24 03 8a 10 80 	movl   $0x80108a03,(%esp)
80104b70:	e8 c5 b9 ff ff       	call   8010053a <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104b75:	81 7d 0c e0 29 11 80 	cmpl   $0x801129e0,0xc(%ebp)
80104b7c:	74 17                	je     80104b95 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104b7e:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104b85:	e8 87 02 00 00       	call   80104e11 <acquire>
    release(lk);
80104b8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b8d:	89 04 24             	mov    %eax,(%esp)
80104b90:	e8 de 02 00 00       	call   80104e73 <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104b95:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b9b:	8b 55 08             	mov    0x8(%ebp),%edx
80104b9e:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104ba1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ba7:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104bae:	e8 84 fe ff ff       	call   80104a37 <sched>

  // Tidy up.
  proc->chan = 0;
80104bb3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bb9:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104bc0:	81 7d 0c e0 29 11 80 	cmpl   $0x801129e0,0xc(%ebp)
80104bc7:	74 17                	je     80104be0 <sleep+0x99>
    release(&ptable.lock);
80104bc9:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104bd0:	e8 9e 02 00 00       	call   80104e73 <release>
    acquire(lk);
80104bd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bd8:	89 04 24             	mov    %eax,(%esp)
80104bdb:	e8 31 02 00 00       	call   80104e11 <acquire>
  }
}
80104be0:	c9                   	leave  
80104be1:	c3                   	ret    

80104be2 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104be2:	55                   	push   %ebp
80104be3:	89 e5                	mov    %esp,%ebp
80104be5:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104be8:	c7 45 fc 14 2a 11 80 	movl   $0x80112a14,-0x4(%ebp)
80104bef:	eb 24                	jmp    80104c15 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104bf1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bf4:	8b 40 0c             	mov    0xc(%eax),%eax
80104bf7:	83 f8 02             	cmp    $0x2,%eax
80104bfa:	75 15                	jne    80104c11 <wakeup1+0x2f>
80104bfc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bff:	8b 40 20             	mov    0x20(%eax),%eax
80104c02:	3b 45 08             	cmp    0x8(%ebp),%eax
80104c05:	75 0a                	jne    80104c11 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104c07:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c0a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c11:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104c15:	81 7d fc 14 49 11 80 	cmpl   $0x80114914,-0x4(%ebp)
80104c1c:	72 d3                	jb     80104bf1 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104c1e:	c9                   	leave  
80104c1f:	c3                   	ret    

80104c20 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104c20:	55                   	push   %ebp
80104c21:	89 e5                	mov    %esp,%ebp
80104c23:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104c26:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104c2d:	e8 df 01 00 00       	call   80104e11 <acquire>
  wakeup1(chan);
80104c32:	8b 45 08             	mov    0x8(%ebp),%eax
80104c35:	89 04 24             	mov    %eax,(%esp)
80104c38:	e8 a5 ff ff ff       	call   80104be2 <wakeup1>
  release(&ptable.lock);
80104c3d:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104c44:	e8 2a 02 00 00       	call   80104e73 <release>
}
80104c49:	c9                   	leave  
80104c4a:	c3                   	ret    

80104c4b <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104c4b:	55                   	push   %ebp
80104c4c:	89 e5                	mov    %esp,%ebp
80104c4e:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104c51:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104c58:	e8 b4 01 00 00       	call   80104e11 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c5d:	c7 45 f4 14 2a 11 80 	movl   $0x80112a14,-0xc(%ebp)
80104c64:	eb 41                	jmp    80104ca7 <kill+0x5c>
    if(p->pid == pid){
80104c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c69:	8b 40 10             	mov    0x10(%eax),%eax
80104c6c:	3b 45 08             	cmp    0x8(%ebp),%eax
80104c6f:	75 32                	jne    80104ca3 <kill+0x58>
      p->killed = 1;
80104c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c74:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c7e:	8b 40 0c             	mov    0xc(%eax),%eax
80104c81:	83 f8 02             	cmp    $0x2,%eax
80104c84:	75 0a                	jne    80104c90 <kill+0x45>
        p->state = RUNNABLE;
80104c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c89:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104c90:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104c97:	e8 d7 01 00 00       	call   80104e73 <release>
      return 0;
80104c9c:	b8 00 00 00 00       	mov    $0x0,%eax
80104ca1:	eb 1e                	jmp    80104cc1 <kill+0x76>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ca3:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104ca7:	81 7d f4 14 49 11 80 	cmpl   $0x80114914,-0xc(%ebp)
80104cae:	72 b6                	jb     80104c66 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104cb0:	c7 04 24 e0 29 11 80 	movl   $0x801129e0,(%esp)
80104cb7:	e8 b7 01 00 00       	call   80104e73 <release>
  return -1;
80104cbc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104cc1:	c9                   	leave  
80104cc2:	c3                   	ret    

80104cc3 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104cc3:	55                   	push   %ebp
80104cc4:	89 e5                	mov    %esp,%ebp
80104cc6:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cc9:	c7 45 f0 14 2a 11 80 	movl   $0x80112a14,-0x10(%ebp)
80104cd0:	e9 d6 00 00 00       	jmp    80104dab <procdump+0xe8>
    if(p->state == UNUSED)
80104cd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cd8:	8b 40 0c             	mov    0xc(%eax),%eax
80104cdb:	85 c0                	test   %eax,%eax
80104cdd:	75 05                	jne    80104ce4 <procdump+0x21>
      continue;
80104cdf:	e9 c3 00 00 00       	jmp    80104da7 <procdump+0xe4>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104ce4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ce7:	8b 40 0c             	mov    0xc(%eax),%eax
80104cea:	83 f8 05             	cmp    $0x5,%eax
80104ced:	77 23                	ja     80104d12 <procdump+0x4f>
80104cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cf2:	8b 40 0c             	mov    0xc(%eax),%eax
80104cf5:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104cfc:	85 c0                	test   %eax,%eax
80104cfe:	74 12                	je     80104d12 <procdump+0x4f>
      state = states[p->state];
80104d00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d03:	8b 40 0c             	mov    0xc(%eax),%eax
80104d06:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104d0d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104d10:	eb 07                	jmp    80104d19 <procdump+0x56>
    else
      state = "???";
80104d12:	c7 45 ec 14 8a 10 80 	movl   $0x80108a14,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104d19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d1c:	8d 50 6c             	lea    0x6c(%eax),%edx
80104d1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d22:	8b 40 10             	mov    0x10(%eax),%eax
80104d25:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104d29:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104d2c:	89 54 24 08          	mov    %edx,0x8(%esp)
80104d30:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d34:	c7 04 24 18 8a 10 80 	movl   $0x80108a18,(%esp)
80104d3b:	e8 60 b6 ff ff       	call   801003a0 <cprintf>
    if(p->state == SLEEPING){
80104d40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d43:	8b 40 0c             	mov    0xc(%eax),%eax
80104d46:	83 f8 02             	cmp    $0x2,%eax
80104d49:	75 50                	jne    80104d9b <procdump+0xd8>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104d4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d4e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d51:	8b 40 0c             	mov    0xc(%eax),%eax
80104d54:	83 c0 08             	add    $0x8,%eax
80104d57:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104d5a:	89 54 24 04          	mov    %edx,0x4(%esp)
80104d5e:	89 04 24             	mov    %eax,(%esp)
80104d61:	e8 5c 01 00 00       	call   80104ec2 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104d66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104d6d:	eb 1b                	jmp    80104d8a <procdump+0xc7>
        cprintf(" %p", pc[i]);
80104d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d72:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104d76:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d7a:	c7 04 24 21 8a 10 80 	movl   $0x80108a21,(%esp)
80104d81:	e8 1a b6 ff ff       	call   801003a0 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104d86:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104d8a:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104d8e:	7f 0b                	jg     80104d9b <procdump+0xd8>
80104d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d93:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104d97:	85 c0                	test   %eax,%eax
80104d99:	75 d4                	jne    80104d6f <procdump+0xac>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104d9b:	c7 04 24 25 8a 10 80 	movl   $0x80108a25,(%esp)
80104da2:	e8 f9 b5 ff ff       	call   801003a0 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104da7:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104dab:	81 7d f0 14 49 11 80 	cmpl   $0x80114914,-0x10(%ebp)
80104db2:	0f 82 1d ff ff ff    	jb     80104cd5 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104db8:	c9                   	leave  
80104db9:	c3                   	ret    

80104dba <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104dba:	55                   	push   %ebp
80104dbb:	89 e5                	mov    %esp,%ebp
80104dbd:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104dc0:	9c                   	pushf  
80104dc1:	58                   	pop    %eax
80104dc2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104dc5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104dc8:	c9                   	leave  
80104dc9:	c3                   	ret    

80104dca <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104dca:	55                   	push   %ebp
80104dcb:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104dcd:	fa                   	cli    
}
80104dce:	5d                   	pop    %ebp
80104dcf:	c3                   	ret    

80104dd0 <sti>:

static inline void
sti(void)
{
80104dd0:	55                   	push   %ebp
80104dd1:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104dd3:	fb                   	sti    
}
80104dd4:	5d                   	pop    %ebp
80104dd5:	c3                   	ret    

80104dd6 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104dd6:	55                   	push   %ebp
80104dd7:	89 e5                	mov    %esp,%ebp
80104dd9:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104ddc:	8b 55 08             	mov    0x8(%ebp),%edx
80104ddf:	8b 45 0c             	mov    0xc(%ebp),%eax
80104de2:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104de5:	f0 87 02             	lock xchg %eax,(%edx)
80104de8:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104deb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104dee:	c9                   	leave  
80104def:	c3                   	ret    

80104df0 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104df0:	55                   	push   %ebp
80104df1:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104df3:	8b 45 08             	mov    0x8(%ebp),%eax
80104df6:	8b 55 0c             	mov    0xc(%ebp),%edx
80104df9:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104dfc:	8b 45 08             	mov    0x8(%ebp),%eax
80104dff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104e05:	8b 45 08             	mov    0x8(%ebp),%eax
80104e08:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104e0f:	5d                   	pop    %ebp
80104e10:	c3                   	ret    

80104e11 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104e11:	55                   	push   %ebp
80104e12:	89 e5                	mov    %esp,%ebp
80104e14:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104e17:	e8 49 01 00 00       	call   80104f65 <pushcli>
  if(holding(lk))
80104e1c:	8b 45 08             	mov    0x8(%ebp),%eax
80104e1f:	89 04 24             	mov    %eax,(%esp)
80104e22:	e8 14 01 00 00       	call   80104f3b <holding>
80104e27:	85 c0                	test   %eax,%eax
80104e29:	74 0c                	je     80104e37 <acquire+0x26>
    panic("acquire");
80104e2b:	c7 04 24 51 8a 10 80 	movl   $0x80108a51,(%esp)
80104e32:	e8 03 b7 ff ff       	call   8010053a <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80104e37:	90                   	nop
80104e38:	8b 45 08             	mov    0x8(%ebp),%eax
80104e3b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104e42:	00 
80104e43:	89 04 24             	mov    %eax,(%esp)
80104e46:	e8 8b ff ff ff       	call   80104dd6 <xchg>
80104e4b:	85 c0                	test   %eax,%eax
80104e4d:	75 e9                	jne    80104e38 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80104e4f:	8b 45 08             	mov    0x8(%ebp),%eax
80104e52:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104e59:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80104e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80104e5f:	83 c0 0c             	add    $0xc,%eax
80104e62:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e66:	8d 45 08             	lea    0x8(%ebp),%eax
80104e69:	89 04 24             	mov    %eax,(%esp)
80104e6c:	e8 51 00 00 00       	call   80104ec2 <getcallerpcs>
}
80104e71:	c9                   	leave  
80104e72:	c3                   	ret    

80104e73 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104e73:	55                   	push   %ebp
80104e74:	89 e5                	mov    %esp,%ebp
80104e76:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80104e79:	8b 45 08             	mov    0x8(%ebp),%eax
80104e7c:	89 04 24             	mov    %eax,(%esp)
80104e7f:	e8 b7 00 00 00       	call   80104f3b <holding>
80104e84:	85 c0                	test   %eax,%eax
80104e86:	75 0c                	jne    80104e94 <release+0x21>
    panic("release");
80104e88:	c7 04 24 59 8a 10 80 	movl   $0x80108a59,(%esp)
80104e8f:	e8 a6 b6 ff ff       	call   8010053a <panic>

  lk->pcs[0] = 0;
80104e94:	8b 45 08             	mov    0x8(%ebp),%eax
80104e97:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104e9e:	8b 45 08             	mov    0x8(%ebp),%eax
80104ea1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80104ea8:	8b 45 08             	mov    0x8(%ebp),%eax
80104eab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104eb2:	00 
80104eb3:	89 04 24             	mov    %eax,(%esp)
80104eb6:	e8 1b ff ff ff       	call   80104dd6 <xchg>

  popcli();
80104ebb:	e8 e9 00 00 00       	call   80104fa9 <popcli>
}
80104ec0:	c9                   	leave  
80104ec1:	c3                   	ret    

80104ec2 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104ec2:	55                   	push   %ebp
80104ec3:	89 e5                	mov    %esp,%ebp
80104ec5:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80104ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80104ecb:	83 e8 08             	sub    $0x8,%eax
80104ece:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104ed1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104ed8:	eb 38                	jmp    80104f12 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104eda:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104ede:	74 38                	je     80104f18 <getcallerpcs+0x56>
80104ee0:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104ee7:	76 2f                	jbe    80104f18 <getcallerpcs+0x56>
80104ee9:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104eed:	74 29                	je     80104f18 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104eef:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ef2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104ef9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104efc:	01 c2                	add    %eax,%edx
80104efe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f01:	8b 40 04             	mov    0x4(%eax),%eax
80104f04:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104f06:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f09:	8b 00                	mov    (%eax),%eax
80104f0b:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104f0e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104f12:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104f16:	7e c2                	jle    80104eda <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104f18:	eb 19                	jmp    80104f33 <getcallerpcs+0x71>
    pcs[i] = 0;
80104f1a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f1d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104f24:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f27:	01 d0                	add    %edx,%eax
80104f29:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104f2f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104f33:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104f37:	7e e1                	jle    80104f1a <getcallerpcs+0x58>
    pcs[i] = 0;
}
80104f39:	c9                   	leave  
80104f3a:	c3                   	ret    

80104f3b <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104f3b:	55                   	push   %ebp
80104f3c:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80104f3e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f41:	8b 00                	mov    (%eax),%eax
80104f43:	85 c0                	test   %eax,%eax
80104f45:	74 17                	je     80104f5e <holding+0x23>
80104f47:	8b 45 08             	mov    0x8(%ebp),%eax
80104f4a:	8b 50 08             	mov    0x8(%eax),%edx
80104f4d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f53:	39 c2                	cmp    %eax,%edx
80104f55:	75 07                	jne    80104f5e <holding+0x23>
80104f57:	b8 01 00 00 00       	mov    $0x1,%eax
80104f5c:	eb 05                	jmp    80104f63 <holding+0x28>
80104f5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f63:	5d                   	pop    %ebp
80104f64:	c3                   	ret    

80104f65 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104f65:	55                   	push   %ebp
80104f66:	89 e5                	mov    %esp,%ebp
80104f68:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80104f6b:	e8 4a fe ff ff       	call   80104dba <readeflags>
80104f70:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80104f73:	e8 52 fe ff ff       	call   80104dca <cli>
  if(cpu->ncli++ == 0)
80104f78:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104f7f:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
80104f85:	8d 48 01             	lea    0x1(%eax),%ecx
80104f88:	89 8a b0 00 00 00    	mov    %ecx,0xb0(%edx)
80104f8e:	85 c0                	test   %eax,%eax
80104f90:	75 15                	jne    80104fa7 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80104f92:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f98:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f9b:	81 e2 00 02 00 00    	and    $0x200,%edx
80104fa1:	89 90 b4 00 00 00    	mov    %edx,0xb4(%eax)
}
80104fa7:	c9                   	leave  
80104fa8:	c3                   	ret    

80104fa9 <popcli>:

void
popcli(void)
{
80104fa9:	55                   	push   %ebp
80104faa:	89 e5                	mov    %esp,%ebp
80104fac:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80104faf:	e8 06 fe ff ff       	call   80104dba <readeflags>
80104fb4:	25 00 02 00 00       	and    $0x200,%eax
80104fb9:	85 c0                	test   %eax,%eax
80104fbb:	74 0c                	je     80104fc9 <popcli+0x20>
    panic("popcli - interruptible");
80104fbd:	c7 04 24 61 8a 10 80 	movl   $0x80108a61,(%esp)
80104fc4:	e8 71 b5 ff ff       	call   8010053a <panic>
  if(--cpu->ncli < 0)
80104fc9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104fcf:	8b 90 b0 00 00 00    	mov    0xb0(%eax),%edx
80104fd5:	83 ea 01             	sub    $0x1,%edx
80104fd8:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
80104fde:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104fe4:	85 c0                	test   %eax,%eax
80104fe6:	79 0c                	jns    80104ff4 <popcli+0x4b>
    panic("popcli");
80104fe8:	c7 04 24 78 8a 10 80 	movl   $0x80108a78,(%esp)
80104fef:	e8 46 b5 ff ff       	call   8010053a <panic>
  if(cpu->ncli == 0 && cpu->intena)
80104ff4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ffa:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105000:	85 c0                	test   %eax,%eax
80105002:	75 15                	jne    80105019 <popcli+0x70>
80105004:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010500a:	8b 80 b4 00 00 00    	mov    0xb4(%eax),%eax
80105010:	85 c0                	test   %eax,%eax
80105012:	74 05                	je     80105019 <popcli+0x70>
    sti();
80105014:	e8 b7 fd ff ff       	call   80104dd0 <sti>
}
80105019:	c9                   	leave  
8010501a:	c3                   	ret    

8010501b <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
8010501b:	55                   	push   %ebp
8010501c:	89 e5                	mov    %esp,%ebp
8010501e:	57                   	push   %edi
8010501f:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105020:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105023:	8b 55 10             	mov    0x10(%ebp),%edx
80105026:	8b 45 0c             	mov    0xc(%ebp),%eax
80105029:	89 cb                	mov    %ecx,%ebx
8010502b:	89 df                	mov    %ebx,%edi
8010502d:	89 d1                	mov    %edx,%ecx
8010502f:	fc                   	cld    
80105030:	f3 aa                	rep stos %al,%es:(%edi)
80105032:	89 ca                	mov    %ecx,%edx
80105034:	89 fb                	mov    %edi,%ebx
80105036:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105039:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010503c:	5b                   	pop    %ebx
8010503d:	5f                   	pop    %edi
8010503e:	5d                   	pop    %ebp
8010503f:	c3                   	ret    

80105040 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105040:	55                   	push   %ebp
80105041:	89 e5                	mov    %esp,%ebp
80105043:	57                   	push   %edi
80105044:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105045:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105048:	8b 55 10             	mov    0x10(%ebp),%edx
8010504b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010504e:	89 cb                	mov    %ecx,%ebx
80105050:	89 df                	mov    %ebx,%edi
80105052:	89 d1                	mov    %edx,%ecx
80105054:	fc                   	cld    
80105055:	f3 ab                	rep stos %eax,%es:(%edi)
80105057:	89 ca                	mov    %ecx,%edx
80105059:	89 fb                	mov    %edi,%ebx
8010505b:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010505e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105061:	5b                   	pop    %ebx
80105062:	5f                   	pop    %edi
80105063:	5d                   	pop    %ebp
80105064:	c3                   	ret    

80105065 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105065:	55                   	push   %ebp
80105066:	89 e5                	mov    %esp,%ebp
80105068:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
8010506b:	8b 45 08             	mov    0x8(%ebp),%eax
8010506e:	83 e0 03             	and    $0x3,%eax
80105071:	85 c0                	test   %eax,%eax
80105073:	75 49                	jne    801050be <memset+0x59>
80105075:	8b 45 10             	mov    0x10(%ebp),%eax
80105078:	83 e0 03             	and    $0x3,%eax
8010507b:	85 c0                	test   %eax,%eax
8010507d:	75 3f                	jne    801050be <memset+0x59>
    c &= 0xFF;
8010507f:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105086:	8b 45 10             	mov    0x10(%ebp),%eax
80105089:	c1 e8 02             	shr    $0x2,%eax
8010508c:	89 c2                	mov    %eax,%edx
8010508e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105091:	c1 e0 18             	shl    $0x18,%eax
80105094:	89 c1                	mov    %eax,%ecx
80105096:	8b 45 0c             	mov    0xc(%ebp),%eax
80105099:	c1 e0 10             	shl    $0x10,%eax
8010509c:	09 c1                	or     %eax,%ecx
8010509e:	8b 45 0c             	mov    0xc(%ebp),%eax
801050a1:	c1 e0 08             	shl    $0x8,%eax
801050a4:	09 c8                	or     %ecx,%eax
801050a6:	0b 45 0c             	or     0xc(%ebp),%eax
801050a9:	89 54 24 08          	mov    %edx,0x8(%esp)
801050ad:	89 44 24 04          	mov    %eax,0x4(%esp)
801050b1:	8b 45 08             	mov    0x8(%ebp),%eax
801050b4:	89 04 24             	mov    %eax,(%esp)
801050b7:	e8 84 ff ff ff       	call   80105040 <stosl>
801050bc:	eb 19                	jmp    801050d7 <memset+0x72>
  } else
    stosb(dst, c, n);
801050be:	8b 45 10             	mov    0x10(%ebp),%eax
801050c1:	89 44 24 08          	mov    %eax,0x8(%esp)
801050c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801050c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801050cc:	8b 45 08             	mov    0x8(%ebp),%eax
801050cf:	89 04 24             	mov    %eax,(%esp)
801050d2:	e8 44 ff ff ff       	call   8010501b <stosb>
  return dst;
801050d7:	8b 45 08             	mov    0x8(%ebp),%eax
}
801050da:	c9                   	leave  
801050db:	c3                   	ret    

801050dc <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801050dc:	55                   	push   %ebp
801050dd:	89 e5                	mov    %esp,%ebp
801050df:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
801050e2:	8b 45 08             	mov    0x8(%ebp),%eax
801050e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801050e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801050eb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801050ee:	eb 30                	jmp    80105120 <memcmp+0x44>
    if(*s1 != *s2)
801050f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050f3:	0f b6 10             	movzbl (%eax),%edx
801050f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050f9:	0f b6 00             	movzbl (%eax),%eax
801050fc:	38 c2                	cmp    %al,%dl
801050fe:	74 18                	je     80105118 <memcmp+0x3c>
      return *s1 - *s2;
80105100:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105103:	0f b6 00             	movzbl (%eax),%eax
80105106:	0f b6 d0             	movzbl %al,%edx
80105109:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010510c:	0f b6 00             	movzbl (%eax),%eax
8010510f:	0f b6 c0             	movzbl %al,%eax
80105112:	29 c2                	sub    %eax,%edx
80105114:	89 d0                	mov    %edx,%eax
80105116:	eb 1a                	jmp    80105132 <memcmp+0x56>
    s1++, s2++;
80105118:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010511c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105120:	8b 45 10             	mov    0x10(%ebp),%eax
80105123:	8d 50 ff             	lea    -0x1(%eax),%edx
80105126:	89 55 10             	mov    %edx,0x10(%ebp)
80105129:	85 c0                	test   %eax,%eax
8010512b:	75 c3                	jne    801050f0 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010512d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105132:	c9                   	leave  
80105133:	c3                   	ret    

80105134 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105134:	55                   	push   %ebp
80105135:	89 e5                	mov    %esp,%ebp
80105137:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010513a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010513d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105140:	8b 45 08             	mov    0x8(%ebp),%eax
80105143:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105146:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105149:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010514c:	73 3d                	jae    8010518b <memmove+0x57>
8010514e:	8b 45 10             	mov    0x10(%ebp),%eax
80105151:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105154:	01 d0                	add    %edx,%eax
80105156:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105159:	76 30                	jbe    8010518b <memmove+0x57>
    s += n;
8010515b:	8b 45 10             	mov    0x10(%ebp),%eax
8010515e:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105161:	8b 45 10             	mov    0x10(%ebp),%eax
80105164:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105167:	eb 13                	jmp    8010517c <memmove+0x48>
      *--d = *--s;
80105169:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010516d:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105171:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105174:	0f b6 10             	movzbl (%eax),%edx
80105177:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010517a:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010517c:	8b 45 10             	mov    0x10(%ebp),%eax
8010517f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105182:	89 55 10             	mov    %edx,0x10(%ebp)
80105185:	85 c0                	test   %eax,%eax
80105187:	75 e0                	jne    80105169 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105189:	eb 26                	jmp    801051b1 <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010518b:	eb 17                	jmp    801051a4 <memmove+0x70>
      *d++ = *s++;
8010518d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105190:	8d 50 01             	lea    0x1(%eax),%edx
80105193:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105196:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105199:	8d 4a 01             	lea    0x1(%edx),%ecx
8010519c:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010519f:	0f b6 12             	movzbl (%edx),%edx
801051a2:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801051a4:	8b 45 10             	mov    0x10(%ebp),%eax
801051a7:	8d 50 ff             	lea    -0x1(%eax),%edx
801051aa:	89 55 10             	mov    %edx,0x10(%ebp)
801051ad:	85 c0                	test   %eax,%eax
801051af:	75 dc                	jne    8010518d <memmove+0x59>
      *d++ = *s++;

  return dst;
801051b1:	8b 45 08             	mov    0x8(%ebp),%eax
}
801051b4:	c9                   	leave  
801051b5:	c3                   	ret    

801051b6 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801051b6:	55                   	push   %ebp
801051b7:	89 e5                	mov    %esp,%ebp
801051b9:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
801051bc:	8b 45 10             	mov    0x10(%ebp),%eax
801051bf:	89 44 24 08          	mov    %eax,0x8(%esp)
801051c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801051c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801051ca:	8b 45 08             	mov    0x8(%ebp),%eax
801051cd:	89 04 24             	mov    %eax,(%esp)
801051d0:	e8 5f ff ff ff       	call   80105134 <memmove>
}
801051d5:	c9                   	leave  
801051d6:	c3                   	ret    

801051d7 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801051d7:	55                   	push   %ebp
801051d8:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801051da:	eb 0c                	jmp    801051e8 <strncmp+0x11>
    n--, p++, q++;
801051dc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801051e0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801051e4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801051e8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051ec:	74 1a                	je     80105208 <strncmp+0x31>
801051ee:	8b 45 08             	mov    0x8(%ebp),%eax
801051f1:	0f b6 00             	movzbl (%eax),%eax
801051f4:	84 c0                	test   %al,%al
801051f6:	74 10                	je     80105208 <strncmp+0x31>
801051f8:	8b 45 08             	mov    0x8(%ebp),%eax
801051fb:	0f b6 10             	movzbl (%eax),%edx
801051fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80105201:	0f b6 00             	movzbl (%eax),%eax
80105204:	38 c2                	cmp    %al,%dl
80105206:	74 d4                	je     801051dc <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105208:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010520c:	75 07                	jne    80105215 <strncmp+0x3e>
    return 0;
8010520e:	b8 00 00 00 00       	mov    $0x0,%eax
80105213:	eb 16                	jmp    8010522b <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105215:	8b 45 08             	mov    0x8(%ebp),%eax
80105218:	0f b6 00             	movzbl (%eax),%eax
8010521b:	0f b6 d0             	movzbl %al,%edx
8010521e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105221:	0f b6 00             	movzbl (%eax),%eax
80105224:	0f b6 c0             	movzbl %al,%eax
80105227:	29 c2                	sub    %eax,%edx
80105229:	89 d0                	mov    %edx,%eax
}
8010522b:	5d                   	pop    %ebp
8010522c:	c3                   	ret    

8010522d <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010522d:	55                   	push   %ebp
8010522e:	89 e5                	mov    %esp,%ebp
80105230:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105233:	8b 45 08             	mov    0x8(%ebp),%eax
80105236:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105239:	90                   	nop
8010523a:	8b 45 10             	mov    0x10(%ebp),%eax
8010523d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105240:	89 55 10             	mov    %edx,0x10(%ebp)
80105243:	85 c0                	test   %eax,%eax
80105245:	7e 1e                	jle    80105265 <strncpy+0x38>
80105247:	8b 45 08             	mov    0x8(%ebp),%eax
8010524a:	8d 50 01             	lea    0x1(%eax),%edx
8010524d:	89 55 08             	mov    %edx,0x8(%ebp)
80105250:	8b 55 0c             	mov    0xc(%ebp),%edx
80105253:	8d 4a 01             	lea    0x1(%edx),%ecx
80105256:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105259:	0f b6 12             	movzbl (%edx),%edx
8010525c:	88 10                	mov    %dl,(%eax)
8010525e:	0f b6 00             	movzbl (%eax),%eax
80105261:	84 c0                	test   %al,%al
80105263:	75 d5                	jne    8010523a <strncpy+0xd>
    ;
  while(n-- > 0)
80105265:	eb 0c                	jmp    80105273 <strncpy+0x46>
    *s++ = 0;
80105267:	8b 45 08             	mov    0x8(%ebp),%eax
8010526a:	8d 50 01             	lea    0x1(%eax),%edx
8010526d:	89 55 08             	mov    %edx,0x8(%ebp)
80105270:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105273:	8b 45 10             	mov    0x10(%ebp),%eax
80105276:	8d 50 ff             	lea    -0x1(%eax),%edx
80105279:	89 55 10             	mov    %edx,0x10(%ebp)
8010527c:	85 c0                	test   %eax,%eax
8010527e:	7f e7                	jg     80105267 <strncpy+0x3a>
    *s++ = 0;
  return os;
80105280:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105283:	c9                   	leave  
80105284:	c3                   	ret    

80105285 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105285:	55                   	push   %ebp
80105286:	89 e5                	mov    %esp,%ebp
80105288:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010528b:	8b 45 08             	mov    0x8(%ebp),%eax
8010528e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105291:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105295:	7f 05                	jg     8010529c <safestrcpy+0x17>
    return os;
80105297:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010529a:	eb 31                	jmp    801052cd <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
8010529c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801052a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052a4:	7e 1e                	jle    801052c4 <safestrcpy+0x3f>
801052a6:	8b 45 08             	mov    0x8(%ebp),%eax
801052a9:	8d 50 01             	lea    0x1(%eax),%edx
801052ac:	89 55 08             	mov    %edx,0x8(%ebp)
801052af:	8b 55 0c             	mov    0xc(%ebp),%edx
801052b2:	8d 4a 01             	lea    0x1(%edx),%ecx
801052b5:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801052b8:	0f b6 12             	movzbl (%edx),%edx
801052bb:	88 10                	mov    %dl,(%eax)
801052bd:	0f b6 00             	movzbl (%eax),%eax
801052c0:	84 c0                	test   %al,%al
801052c2:	75 d8                	jne    8010529c <safestrcpy+0x17>
    ;
  *s = 0;
801052c4:	8b 45 08             	mov    0x8(%ebp),%eax
801052c7:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801052ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052cd:	c9                   	leave  
801052ce:	c3                   	ret    

801052cf <strlen>:

int
strlen(const char *s)
{
801052cf:	55                   	push   %ebp
801052d0:	89 e5                	mov    %esp,%ebp
801052d2:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801052d5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801052dc:	eb 04                	jmp    801052e2 <strlen+0x13>
801052de:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801052e2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801052e5:	8b 45 08             	mov    0x8(%ebp),%eax
801052e8:	01 d0                	add    %edx,%eax
801052ea:	0f b6 00             	movzbl (%eax),%eax
801052ed:	84 c0                	test   %al,%al
801052ef:	75 ed                	jne    801052de <strlen+0xf>
    ;
  return n;
801052f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052f4:	c9                   	leave  
801052f5:	c3                   	ret    

801052f6 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801052f6:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801052fa:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801052fe:	55                   	push   %ebp
  pushl %ebx
801052ff:	53                   	push   %ebx
  pushl %esi
80105300:	56                   	push   %esi
  pushl %edi
80105301:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105302:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105304:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105306:	5f                   	pop    %edi
  popl %esi
80105307:	5e                   	pop    %esi
  popl %ebx
80105308:	5b                   	pop    %ebx
  popl %ebp
80105309:	5d                   	pop    %ebp
  ret
8010530a:	c3                   	ret    

8010530b <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010530b:	55                   	push   %ebp
8010530c:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
8010530e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105314:	8b 00                	mov    (%eax),%eax
80105316:	3b 45 08             	cmp    0x8(%ebp),%eax
80105319:	76 12                	jbe    8010532d <fetchint+0x22>
8010531b:	8b 45 08             	mov    0x8(%ebp),%eax
8010531e:	8d 50 04             	lea    0x4(%eax),%edx
80105321:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105327:	8b 00                	mov    (%eax),%eax
80105329:	39 c2                	cmp    %eax,%edx
8010532b:	76 07                	jbe    80105334 <fetchint+0x29>
    return -1;
8010532d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105332:	eb 0f                	jmp    80105343 <fetchint+0x38>
  *ip = *(int*)(addr);
80105334:	8b 45 08             	mov    0x8(%ebp),%eax
80105337:	8b 10                	mov    (%eax),%edx
80105339:	8b 45 0c             	mov    0xc(%ebp),%eax
8010533c:	89 10                	mov    %edx,(%eax)
  return 0;
8010533e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105343:	5d                   	pop    %ebp
80105344:	c3                   	ret    

80105345 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105345:	55                   	push   %ebp
80105346:	89 e5                	mov    %esp,%ebp
80105348:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
8010534b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105351:	8b 00                	mov    (%eax),%eax
80105353:	3b 45 08             	cmp    0x8(%ebp),%eax
80105356:	77 07                	ja     8010535f <fetchstr+0x1a>
    return -1;
80105358:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010535d:	eb 46                	jmp    801053a5 <fetchstr+0x60>
  *pp = (char*)addr;
8010535f:	8b 55 08             	mov    0x8(%ebp),%edx
80105362:	8b 45 0c             	mov    0xc(%ebp),%eax
80105365:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105367:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010536d:	8b 00                	mov    (%eax),%eax
8010536f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105372:	8b 45 0c             	mov    0xc(%ebp),%eax
80105375:	8b 00                	mov    (%eax),%eax
80105377:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010537a:	eb 1c                	jmp    80105398 <fetchstr+0x53>
    if(*s == 0)
8010537c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010537f:	0f b6 00             	movzbl (%eax),%eax
80105382:	84 c0                	test   %al,%al
80105384:	75 0e                	jne    80105394 <fetchstr+0x4f>
      return s - *pp;
80105386:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105389:	8b 45 0c             	mov    0xc(%ebp),%eax
8010538c:	8b 00                	mov    (%eax),%eax
8010538e:	29 c2                	sub    %eax,%edx
80105390:	89 d0                	mov    %edx,%eax
80105392:	eb 11                	jmp    801053a5 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105394:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105398:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010539b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010539e:	72 dc                	jb     8010537c <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
801053a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801053a5:	c9                   	leave  
801053a6:	c3                   	ret    

801053a7 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801053a7:	55                   	push   %ebp
801053a8:	89 e5                	mov    %esp,%ebp
801053aa:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801053ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053b3:	8b 40 18             	mov    0x18(%eax),%eax
801053b6:	8b 50 44             	mov    0x44(%eax),%edx
801053b9:	8b 45 08             	mov    0x8(%ebp),%eax
801053bc:	c1 e0 02             	shl    $0x2,%eax
801053bf:	01 d0                	add    %edx,%eax
801053c1:	8d 50 04             	lea    0x4(%eax),%edx
801053c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801053c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801053cb:	89 14 24             	mov    %edx,(%esp)
801053ce:	e8 38 ff ff ff       	call   8010530b <fetchint>
}
801053d3:	c9                   	leave  
801053d4:	c3                   	ret    

801053d5 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801053d5:	55                   	push   %ebp
801053d6:	89 e5                	mov    %esp,%ebp
801053d8:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
801053db:	8d 45 fc             	lea    -0x4(%ebp),%eax
801053de:	89 44 24 04          	mov    %eax,0x4(%esp)
801053e2:	8b 45 08             	mov    0x8(%ebp),%eax
801053e5:	89 04 24             	mov    %eax,(%esp)
801053e8:	e8 ba ff ff ff       	call   801053a7 <argint>
801053ed:	85 c0                	test   %eax,%eax
801053ef:	79 07                	jns    801053f8 <argptr+0x23>
    return -1;
801053f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053f6:	eb 3d                	jmp    80105435 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801053f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053fb:	89 c2                	mov    %eax,%edx
801053fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105403:	8b 00                	mov    (%eax),%eax
80105405:	39 c2                	cmp    %eax,%edx
80105407:	73 16                	jae    8010541f <argptr+0x4a>
80105409:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010540c:	89 c2                	mov    %eax,%edx
8010540e:	8b 45 10             	mov    0x10(%ebp),%eax
80105411:	01 c2                	add    %eax,%edx
80105413:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105419:	8b 00                	mov    (%eax),%eax
8010541b:	39 c2                	cmp    %eax,%edx
8010541d:	76 07                	jbe    80105426 <argptr+0x51>
    return -1;
8010541f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105424:	eb 0f                	jmp    80105435 <argptr+0x60>
  *pp = (char*)i;
80105426:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105429:	89 c2                	mov    %eax,%edx
8010542b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010542e:	89 10                	mov    %edx,(%eax)
  return 0;
80105430:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105435:	c9                   	leave  
80105436:	c3                   	ret    

80105437 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105437:	55                   	push   %ebp
80105438:	89 e5                	mov    %esp,%ebp
8010543a:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010543d:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105440:	89 44 24 04          	mov    %eax,0x4(%esp)
80105444:	8b 45 08             	mov    0x8(%ebp),%eax
80105447:	89 04 24             	mov    %eax,(%esp)
8010544a:	e8 58 ff ff ff       	call   801053a7 <argint>
8010544f:	85 c0                	test   %eax,%eax
80105451:	79 07                	jns    8010545a <argstr+0x23>
    return -1;
80105453:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105458:	eb 12                	jmp    8010546c <argstr+0x35>
  return fetchstr(addr, pp);
8010545a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010545d:	8b 55 0c             	mov    0xc(%ebp),%edx
80105460:	89 54 24 04          	mov    %edx,0x4(%esp)
80105464:	89 04 24             	mov    %eax,(%esp)
80105467:	e8 d9 fe ff ff       	call   80105345 <fetchstr>
}
8010546c:	c9                   	leave  
8010546d:	c3                   	ret    

8010546e <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
8010546e:	55                   	push   %ebp
8010546f:	89 e5                	mov    %esp,%ebp
80105471:	53                   	push   %ebx
80105472:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105475:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010547b:	8b 40 18             	mov    0x18(%eax),%eax
8010547e:	8b 40 1c             	mov    0x1c(%eax),%eax
80105481:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105484:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105488:	7e 30                	jle    801054ba <syscall+0x4c>
8010548a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010548d:	83 f8 15             	cmp    $0x15,%eax
80105490:	77 28                	ja     801054ba <syscall+0x4c>
80105492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105495:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010549c:	85 c0                	test   %eax,%eax
8010549e:	74 1a                	je     801054ba <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
801054a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054a6:	8b 58 18             	mov    0x18(%eax),%ebx
801054a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054ac:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801054b3:	ff d0                	call   *%eax
801054b5:	89 43 1c             	mov    %eax,0x1c(%ebx)
801054b8:	eb 3d                	jmp    801054f7 <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801054ba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054c0:	8d 48 6c             	lea    0x6c(%eax),%ecx
801054c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801054c9:	8b 40 10             	mov    0x10(%eax),%eax
801054cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054cf:	89 54 24 0c          	mov    %edx,0xc(%esp)
801054d3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801054d7:	89 44 24 04          	mov    %eax,0x4(%esp)
801054db:	c7 04 24 7f 8a 10 80 	movl   $0x80108a7f,(%esp)
801054e2:	e8 b9 ae ff ff       	call   801003a0 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801054e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054ed:	8b 40 18             	mov    0x18(%eax),%eax
801054f0:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801054f7:	83 c4 24             	add    $0x24,%esp
801054fa:	5b                   	pop    %ebx
801054fb:	5d                   	pop    %ebp
801054fc:	c3                   	ret    

801054fd <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801054fd:	55                   	push   %ebp
801054fe:	89 e5                	mov    %esp,%ebp
80105500:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105503:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105506:	89 44 24 04          	mov    %eax,0x4(%esp)
8010550a:	8b 45 08             	mov    0x8(%ebp),%eax
8010550d:	89 04 24             	mov    %eax,(%esp)
80105510:	e8 92 fe ff ff       	call   801053a7 <argint>
80105515:	85 c0                	test   %eax,%eax
80105517:	79 07                	jns    80105520 <argfd+0x23>
    return -1;
80105519:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010551e:	eb 50                	jmp    80105570 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105520:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105523:	85 c0                	test   %eax,%eax
80105525:	78 21                	js     80105548 <argfd+0x4b>
80105527:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010552a:	83 f8 0f             	cmp    $0xf,%eax
8010552d:	7f 19                	jg     80105548 <argfd+0x4b>
8010552f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105535:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105538:	83 c2 08             	add    $0x8,%edx
8010553b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010553f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105542:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105546:	75 07                	jne    8010554f <argfd+0x52>
    return -1;
80105548:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010554d:	eb 21                	jmp    80105570 <argfd+0x73>
  if(pfd)
8010554f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105553:	74 08                	je     8010555d <argfd+0x60>
    *pfd = fd;
80105555:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105558:	8b 45 0c             	mov    0xc(%ebp),%eax
8010555b:	89 10                	mov    %edx,(%eax)
  if(pf)
8010555d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105561:	74 08                	je     8010556b <argfd+0x6e>
    *pf = f;
80105563:	8b 45 10             	mov    0x10(%ebp),%eax
80105566:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105569:	89 10                	mov    %edx,(%eax)
  return 0;
8010556b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105570:	c9                   	leave  
80105571:	c3                   	ret    

80105572 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105572:	55                   	push   %ebp
80105573:	89 e5                	mov    %esp,%ebp
80105575:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105578:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010557f:	eb 30                	jmp    801055b1 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105581:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105587:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010558a:	83 c2 08             	add    $0x8,%edx
8010558d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105591:	85 c0                	test   %eax,%eax
80105593:	75 18                	jne    801055ad <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105595:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010559b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010559e:	8d 4a 08             	lea    0x8(%edx),%ecx
801055a1:	8b 55 08             	mov    0x8(%ebp),%edx
801055a4:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801055a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055ab:	eb 0f                	jmp    801055bc <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801055ad:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801055b1:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801055b5:	7e ca                	jle    80105581 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801055b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055bc:	c9                   	leave  
801055bd:	c3                   	ret    

801055be <sys_dup>:

int
sys_dup(void)
{
801055be:	55                   	push   %ebp
801055bf:	89 e5                	mov    %esp,%ebp
801055c1:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801055c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801055c7:	89 44 24 08          	mov    %eax,0x8(%esp)
801055cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801055d2:	00 
801055d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801055da:	e8 1e ff ff ff       	call   801054fd <argfd>
801055df:	85 c0                	test   %eax,%eax
801055e1:	79 07                	jns    801055ea <sys_dup+0x2c>
    return -1;
801055e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055e8:	eb 29                	jmp    80105613 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801055ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055ed:	89 04 24             	mov    %eax,(%esp)
801055f0:	e8 7d ff ff ff       	call   80105572 <fdalloc>
801055f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801055fc:	79 07                	jns    80105605 <sys_dup+0x47>
    return -1;
801055fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105603:	eb 0e                	jmp    80105613 <sys_dup+0x55>
  filedup(f);
80105605:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105608:	89 04 24             	mov    %eax,(%esp)
8010560b:	e8 76 b9 ff ff       	call   80100f86 <filedup>
  return fd;
80105610:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105613:	c9                   	leave  
80105614:	c3                   	ret    

80105615 <sys_read>:

int
sys_read(void)
{
80105615:	55                   	push   %ebp
80105616:	89 e5                	mov    %esp,%ebp
80105618:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010561b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010561e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105622:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105629:	00 
8010562a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105631:	e8 c7 fe ff ff       	call   801054fd <argfd>
80105636:	85 c0                	test   %eax,%eax
80105638:	78 35                	js     8010566f <sys_read+0x5a>
8010563a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010563d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105641:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105648:	e8 5a fd ff ff       	call   801053a7 <argint>
8010564d:	85 c0                	test   %eax,%eax
8010564f:	78 1e                	js     8010566f <sys_read+0x5a>
80105651:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105654:	89 44 24 08          	mov    %eax,0x8(%esp)
80105658:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010565b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010565f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105666:	e8 6a fd ff ff       	call   801053d5 <argptr>
8010566b:	85 c0                	test   %eax,%eax
8010566d:	79 07                	jns    80105676 <sys_read+0x61>
    return -1;
8010566f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105674:	eb 19                	jmp    8010568f <sys_read+0x7a>
  return fileread(f, p, n);
80105676:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105679:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010567c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010567f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105683:	89 54 24 04          	mov    %edx,0x4(%esp)
80105687:	89 04 24             	mov    %eax,(%esp)
8010568a:	e8 64 ba ff ff       	call   801010f3 <fileread>
}
8010568f:	c9                   	leave  
80105690:	c3                   	ret    

80105691 <sys_write>:

int
sys_write(void)
{
80105691:	55                   	push   %ebp
80105692:	89 e5                	mov    %esp,%ebp
80105694:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105697:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010569a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010569e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801056a5:	00 
801056a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801056ad:	e8 4b fe ff ff       	call   801054fd <argfd>
801056b2:	85 c0                	test   %eax,%eax
801056b4:	78 35                	js     801056eb <sys_write+0x5a>
801056b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801056bd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801056c4:	e8 de fc ff ff       	call   801053a7 <argint>
801056c9:	85 c0                	test   %eax,%eax
801056cb:	78 1e                	js     801056eb <sys_write+0x5a>
801056cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056d0:	89 44 24 08          	mov    %eax,0x8(%esp)
801056d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801056d7:	89 44 24 04          	mov    %eax,0x4(%esp)
801056db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801056e2:	e8 ee fc ff ff       	call   801053d5 <argptr>
801056e7:	85 c0                	test   %eax,%eax
801056e9:	79 07                	jns    801056f2 <sys_write+0x61>
    return -1;
801056eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056f0:	eb 19                	jmp    8010570b <sys_write+0x7a>
  return filewrite(f, p, n);
801056f2:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801056f5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801056f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056fb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801056ff:	89 54 24 04          	mov    %edx,0x4(%esp)
80105703:	89 04 24             	mov    %eax,(%esp)
80105706:	e8 a4 ba ff ff       	call   801011af <filewrite>
}
8010570b:	c9                   	leave  
8010570c:	c3                   	ret    

8010570d <sys_close>:

int
sys_close(void)
{
8010570d:	55                   	push   %ebp
8010570e:	89 e5                	mov    %esp,%ebp
80105710:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105713:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105716:	89 44 24 08          	mov    %eax,0x8(%esp)
8010571a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010571d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105721:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105728:	e8 d0 fd ff ff       	call   801054fd <argfd>
8010572d:	85 c0                	test   %eax,%eax
8010572f:	79 07                	jns    80105738 <sys_close+0x2b>
    return -1;
80105731:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105736:	eb 24                	jmp    8010575c <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105738:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010573e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105741:	83 c2 08             	add    $0x8,%edx
80105744:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010574b:	00 
  fileclose(f);
8010574c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010574f:	89 04 24             	mov    %eax,(%esp)
80105752:	e8 77 b8 ff ff       	call   80100fce <fileclose>
  return 0;
80105757:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010575c:	c9                   	leave  
8010575d:	c3                   	ret    

8010575e <sys_fstat>:

int
sys_fstat(void)
{
8010575e:	55                   	push   %ebp
8010575f:	89 e5                	mov    %esp,%ebp
80105761:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105764:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105767:	89 44 24 08          	mov    %eax,0x8(%esp)
8010576b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105772:	00 
80105773:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010577a:	e8 7e fd ff ff       	call   801054fd <argfd>
8010577f:	85 c0                	test   %eax,%eax
80105781:	78 1f                	js     801057a2 <sys_fstat+0x44>
80105783:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010578a:	00 
8010578b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010578e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105792:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105799:	e8 37 fc ff ff       	call   801053d5 <argptr>
8010579e:	85 c0                	test   %eax,%eax
801057a0:	79 07                	jns    801057a9 <sys_fstat+0x4b>
    return -1;
801057a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057a7:	eb 12                	jmp    801057bb <sys_fstat+0x5d>
  return filestat(f, st);
801057a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801057ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057af:	89 54 24 04          	mov    %edx,0x4(%esp)
801057b3:	89 04 24             	mov    %eax,(%esp)
801057b6:	e8 e9 b8 ff ff       	call   801010a4 <filestat>
}
801057bb:	c9                   	leave  
801057bc:	c3                   	ret    

801057bd <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801057bd:	55                   	push   %ebp
801057be:	89 e5                	mov    %esp,%ebp
801057c0:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801057c3:	8d 45 d8             	lea    -0x28(%ebp),%eax
801057c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801057ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801057d1:	e8 61 fc ff ff       	call   80105437 <argstr>
801057d6:	85 c0                	test   %eax,%eax
801057d8:	78 17                	js     801057f1 <sys_link+0x34>
801057da:	8d 45 dc             	lea    -0x24(%ebp),%eax
801057dd:	89 44 24 04          	mov    %eax,0x4(%esp)
801057e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801057e8:	e8 4a fc ff ff       	call   80105437 <argstr>
801057ed:	85 c0                	test   %eax,%eax
801057ef:	79 0a                	jns    801057fb <sys_link+0x3e>
    return -1;
801057f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057f6:	e9 42 01 00 00       	jmp    8010593d <sys_link+0x180>

  begin_op();
801057fb:	e8 10 dc ff ff       	call   80103410 <begin_op>
  if((ip = namei(old)) == 0){
80105800:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105803:	89 04 24             	mov    %eax,(%esp)
80105806:	e8 fb cb ff ff       	call   80102406 <namei>
8010580b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010580e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105812:	75 0f                	jne    80105823 <sys_link+0x66>
    end_op();
80105814:	e8 7b dc ff ff       	call   80103494 <end_op>
    return -1;
80105819:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010581e:	e9 1a 01 00 00       	jmp    8010593d <sys_link+0x180>
  }

  ilock(ip);
80105823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105826:	89 04 24             	mov    %eax,(%esp)
80105829:	e8 2d c0 ff ff       	call   8010185b <ilock>
  if(ip->type == T_DIR){
8010582e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105831:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105835:	66 83 f8 01          	cmp    $0x1,%ax
80105839:	75 1a                	jne    80105855 <sys_link+0x98>
    iunlockput(ip);
8010583b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010583e:	89 04 24             	mov    %eax,(%esp)
80105841:	e8 99 c2 ff ff       	call   80101adf <iunlockput>
    end_op();
80105846:	e8 49 dc ff ff       	call   80103494 <end_op>
    return -1;
8010584b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105850:	e9 e8 00 00 00       	jmp    8010593d <sys_link+0x180>
  }

  ip->nlink++;
80105855:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105858:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010585c:	8d 50 01             	lea    0x1(%eax),%edx
8010585f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105862:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105866:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105869:	89 04 24             	mov    %eax,(%esp)
8010586c:	e8 2e be ff ff       	call   8010169f <iupdate>
  iunlock(ip);
80105871:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105874:	89 04 24             	mov    %eax,(%esp)
80105877:	e8 2d c1 ff ff       	call   801019a9 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
8010587c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010587f:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105882:	89 54 24 04          	mov    %edx,0x4(%esp)
80105886:	89 04 24             	mov    %eax,(%esp)
80105889:	e8 9a cb ff ff       	call   80102428 <nameiparent>
8010588e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105891:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105895:	75 02                	jne    80105899 <sys_link+0xdc>
    goto bad;
80105897:	eb 68                	jmp    80105901 <sys_link+0x144>
  ilock(dp);
80105899:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010589c:	89 04 24             	mov    %eax,(%esp)
8010589f:	e8 b7 bf ff ff       	call   8010185b <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801058a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a7:	8b 10                	mov    (%eax),%edx
801058a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058ac:	8b 00                	mov    (%eax),%eax
801058ae:	39 c2                	cmp    %eax,%edx
801058b0:	75 20                	jne    801058d2 <sys_link+0x115>
801058b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058b5:	8b 40 04             	mov    0x4(%eax),%eax
801058b8:	89 44 24 08          	mov    %eax,0x8(%esp)
801058bc:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801058bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801058c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058c6:	89 04 24             	mov    %eax,(%esp)
801058c9:	e8 78 c8 ff ff       	call   80102146 <dirlink>
801058ce:	85 c0                	test   %eax,%eax
801058d0:	79 0d                	jns    801058df <sys_link+0x122>
    iunlockput(dp);
801058d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058d5:	89 04 24             	mov    %eax,(%esp)
801058d8:	e8 02 c2 ff ff       	call   80101adf <iunlockput>
    goto bad;
801058dd:	eb 22                	jmp    80105901 <sys_link+0x144>
  }
  iunlockput(dp);
801058df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058e2:	89 04 24             	mov    %eax,(%esp)
801058e5:	e8 f5 c1 ff ff       	call   80101adf <iunlockput>
  iput(ip);
801058ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058ed:	89 04 24             	mov    %eax,(%esp)
801058f0:	e8 19 c1 ff ff       	call   80101a0e <iput>

  end_op();
801058f5:	e8 9a db ff ff       	call   80103494 <end_op>

  return 0;
801058fa:	b8 00 00 00 00       	mov    $0x0,%eax
801058ff:	eb 3c                	jmp    8010593d <sys_link+0x180>

bad:
  ilock(ip);
80105901:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105904:	89 04 24             	mov    %eax,(%esp)
80105907:	e8 4f bf ff ff       	call   8010185b <ilock>
  ip->nlink--;
8010590c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010590f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105913:	8d 50 ff             	lea    -0x1(%eax),%edx
80105916:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105919:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010591d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105920:	89 04 24             	mov    %eax,(%esp)
80105923:	e8 77 bd ff ff       	call   8010169f <iupdate>
  iunlockput(ip);
80105928:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010592b:	89 04 24             	mov    %eax,(%esp)
8010592e:	e8 ac c1 ff ff       	call   80101adf <iunlockput>
  end_op();
80105933:	e8 5c db ff ff       	call   80103494 <end_op>
  return -1;
80105938:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010593d:	c9                   	leave  
8010593e:	c3                   	ret    

8010593f <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010593f:	55                   	push   %ebp
80105940:	89 e5                	mov    %esp,%ebp
80105942:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105945:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010594c:	eb 4b                	jmp    80105999 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010594e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105951:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105958:	00 
80105959:	89 44 24 08          	mov    %eax,0x8(%esp)
8010595d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105960:	89 44 24 04          	mov    %eax,0x4(%esp)
80105964:	8b 45 08             	mov    0x8(%ebp),%eax
80105967:	89 04 24             	mov    %eax,(%esp)
8010596a:	e8 f9 c3 ff ff       	call   80101d68 <readi>
8010596f:	83 f8 10             	cmp    $0x10,%eax
80105972:	74 0c                	je     80105980 <isdirempty+0x41>
      panic("isdirempty: readi");
80105974:	c7 04 24 9b 8a 10 80 	movl   $0x80108a9b,(%esp)
8010597b:	e8 ba ab ff ff       	call   8010053a <panic>
    if(de.inum != 0)
80105980:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105984:	66 85 c0             	test   %ax,%ax
80105987:	74 07                	je     80105990 <isdirempty+0x51>
      return 0;
80105989:	b8 00 00 00 00       	mov    $0x0,%eax
8010598e:	eb 1b                	jmp    801059ab <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105993:	83 c0 10             	add    $0x10,%eax
80105996:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105999:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010599c:	8b 45 08             	mov    0x8(%ebp),%eax
8010599f:	8b 40 18             	mov    0x18(%eax),%eax
801059a2:	39 c2                	cmp    %eax,%edx
801059a4:	72 a8                	jb     8010594e <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
801059a6:	b8 01 00 00 00       	mov    $0x1,%eax
}
801059ab:	c9                   	leave  
801059ac:	c3                   	ret    

801059ad <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801059ad:	55                   	push   %ebp
801059ae:	89 e5                	mov    %esp,%ebp
801059b0:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801059b3:	8d 45 cc             	lea    -0x34(%ebp),%eax
801059b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801059ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801059c1:	e8 71 fa ff ff       	call   80105437 <argstr>
801059c6:	85 c0                	test   %eax,%eax
801059c8:	79 0a                	jns    801059d4 <sys_unlink+0x27>
    return -1;
801059ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059cf:	e9 af 01 00 00       	jmp    80105b83 <sys_unlink+0x1d6>

  begin_op();
801059d4:	e8 37 da ff ff       	call   80103410 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801059d9:	8b 45 cc             	mov    -0x34(%ebp),%eax
801059dc:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801059df:	89 54 24 04          	mov    %edx,0x4(%esp)
801059e3:	89 04 24             	mov    %eax,(%esp)
801059e6:	e8 3d ca ff ff       	call   80102428 <nameiparent>
801059eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059ee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059f2:	75 0f                	jne    80105a03 <sys_unlink+0x56>
    end_op();
801059f4:	e8 9b da ff ff       	call   80103494 <end_op>
    return -1;
801059f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059fe:	e9 80 01 00 00       	jmp    80105b83 <sys_unlink+0x1d6>
  }

  ilock(dp);
80105a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a06:	89 04 24             	mov    %eax,(%esp)
80105a09:	e8 4d be ff ff       	call   8010185b <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105a0e:	c7 44 24 04 ad 8a 10 	movl   $0x80108aad,0x4(%esp)
80105a15:	80 
80105a16:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105a19:	89 04 24             	mov    %eax,(%esp)
80105a1c:	e8 3a c6 ff ff       	call   8010205b <namecmp>
80105a21:	85 c0                	test   %eax,%eax
80105a23:	0f 84 45 01 00 00    	je     80105b6e <sys_unlink+0x1c1>
80105a29:	c7 44 24 04 af 8a 10 	movl   $0x80108aaf,0x4(%esp)
80105a30:	80 
80105a31:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105a34:	89 04 24             	mov    %eax,(%esp)
80105a37:	e8 1f c6 ff ff       	call   8010205b <namecmp>
80105a3c:	85 c0                	test   %eax,%eax
80105a3e:	0f 84 2a 01 00 00    	je     80105b6e <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105a44:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105a47:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a4b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105a4e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a55:	89 04 24             	mov    %eax,(%esp)
80105a58:	e8 20 c6 ff ff       	call   8010207d <dirlookup>
80105a5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a60:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a64:	75 05                	jne    80105a6b <sys_unlink+0xbe>
    goto bad;
80105a66:	e9 03 01 00 00       	jmp    80105b6e <sys_unlink+0x1c1>
  ilock(ip);
80105a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a6e:	89 04 24             	mov    %eax,(%esp)
80105a71:	e8 e5 bd ff ff       	call   8010185b <ilock>

  if(ip->nlink < 1)
80105a76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a79:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105a7d:	66 85 c0             	test   %ax,%ax
80105a80:	7f 0c                	jg     80105a8e <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105a82:	c7 04 24 b2 8a 10 80 	movl   $0x80108ab2,(%esp)
80105a89:	e8 ac aa ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105a8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a91:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105a95:	66 83 f8 01          	cmp    $0x1,%ax
80105a99:	75 1f                	jne    80105aba <sys_unlink+0x10d>
80105a9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a9e:	89 04 24             	mov    %eax,(%esp)
80105aa1:	e8 99 fe ff ff       	call   8010593f <isdirempty>
80105aa6:	85 c0                	test   %eax,%eax
80105aa8:	75 10                	jne    80105aba <sys_unlink+0x10d>
    iunlockput(ip);
80105aaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aad:	89 04 24             	mov    %eax,(%esp)
80105ab0:	e8 2a c0 ff ff       	call   80101adf <iunlockput>
    goto bad;
80105ab5:	e9 b4 00 00 00       	jmp    80105b6e <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80105aba:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105ac1:	00 
80105ac2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105ac9:	00 
80105aca:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105acd:	89 04 24             	mov    %eax,(%esp)
80105ad0:	e8 90 f5 ff ff       	call   80105065 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ad5:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105ad8:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105adf:	00 
80105ae0:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ae4:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ae7:	89 44 24 04          	mov    %eax,0x4(%esp)
80105aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aee:	89 04 24             	mov    %eax,(%esp)
80105af1:	e8 d6 c3 ff ff       	call   80101ecc <writei>
80105af6:	83 f8 10             	cmp    $0x10,%eax
80105af9:	74 0c                	je     80105b07 <sys_unlink+0x15a>
    panic("unlink: writei");
80105afb:	c7 04 24 c4 8a 10 80 	movl   $0x80108ac4,(%esp)
80105b02:	e8 33 aa ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR){
80105b07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b0a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105b0e:	66 83 f8 01          	cmp    $0x1,%ax
80105b12:	75 1c                	jne    80105b30 <sys_unlink+0x183>
    dp->nlink--;
80105b14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b17:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b1b:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b21:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b28:	89 04 24             	mov    %eax,(%esp)
80105b2b:	e8 6f bb ff ff       	call   8010169f <iupdate>
  }
  iunlockput(dp);
80105b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b33:	89 04 24             	mov    %eax,(%esp)
80105b36:	e8 a4 bf ff ff       	call   80101adf <iunlockput>

  ip->nlink--;
80105b3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b3e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b42:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b48:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105b4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b4f:	89 04 24             	mov    %eax,(%esp)
80105b52:	e8 48 bb ff ff       	call   8010169f <iupdate>
  iunlockput(ip);
80105b57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b5a:	89 04 24             	mov    %eax,(%esp)
80105b5d:	e8 7d bf ff ff       	call   80101adf <iunlockput>

  end_op();
80105b62:	e8 2d d9 ff ff       	call   80103494 <end_op>

  return 0;
80105b67:	b8 00 00 00 00       	mov    $0x0,%eax
80105b6c:	eb 15                	jmp    80105b83 <sys_unlink+0x1d6>

bad:
  iunlockput(dp);
80105b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b71:	89 04 24             	mov    %eax,(%esp)
80105b74:	e8 66 bf ff ff       	call   80101adf <iunlockput>
  end_op();
80105b79:	e8 16 d9 ff ff       	call   80103494 <end_op>
  return -1;
80105b7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b83:	c9                   	leave  
80105b84:	c3                   	ret    

80105b85 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105b85:	55                   	push   %ebp
80105b86:	89 e5                	mov    %esp,%ebp
80105b88:	83 ec 48             	sub    $0x48,%esp
80105b8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105b8e:	8b 55 10             	mov    0x10(%ebp),%edx
80105b91:	8b 45 14             	mov    0x14(%ebp),%eax
80105b94:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105b98:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105b9c:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105ba0:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ba3:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ba7:	8b 45 08             	mov    0x8(%ebp),%eax
80105baa:	89 04 24             	mov    %eax,(%esp)
80105bad:	e8 76 c8 ff ff       	call   80102428 <nameiparent>
80105bb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bb5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bb9:	75 0a                	jne    80105bc5 <create+0x40>
    return 0;
80105bbb:	b8 00 00 00 00       	mov    $0x0,%eax
80105bc0:	e9 7e 01 00 00       	jmp    80105d43 <create+0x1be>
  ilock(dp);
80105bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc8:	89 04 24             	mov    %eax,(%esp)
80105bcb:	e8 8b bc ff ff       	call   8010185b <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105bd0:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105bd3:	89 44 24 08          	mov    %eax,0x8(%esp)
80105bd7:	8d 45 de             	lea    -0x22(%ebp),%eax
80105bda:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be1:	89 04 24             	mov    %eax,(%esp)
80105be4:	e8 94 c4 ff ff       	call   8010207d <dirlookup>
80105be9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bf0:	74 47                	je     80105c39 <create+0xb4>
    iunlockput(dp);
80105bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf5:	89 04 24             	mov    %eax,(%esp)
80105bf8:	e8 e2 be ff ff       	call   80101adf <iunlockput>
    ilock(ip);
80105bfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c00:	89 04 24             	mov    %eax,(%esp)
80105c03:	e8 53 bc ff ff       	call   8010185b <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105c08:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105c0d:	75 15                	jne    80105c24 <create+0x9f>
80105c0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c12:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105c16:	66 83 f8 02          	cmp    $0x2,%ax
80105c1a:	75 08                	jne    80105c24 <create+0x9f>
      return ip;
80105c1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c1f:	e9 1f 01 00 00       	jmp    80105d43 <create+0x1be>
    iunlockput(ip);
80105c24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c27:	89 04 24             	mov    %eax,(%esp)
80105c2a:	e8 b0 be ff ff       	call   80101adf <iunlockput>
    return 0;
80105c2f:	b8 00 00 00 00       	mov    $0x0,%eax
80105c34:	e9 0a 01 00 00       	jmp    80105d43 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105c39:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c40:	8b 00                	mov    (%eax),%eax
80105c42:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c46:	89 04 24             	mov    %eax,(%esp)
80105c49:	e8 72 b9 ff ff       	call   801015c0 <ialloc>
80105c4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c51:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c55:	75 0c                	jne    80105c63 <create+0xde>
    panic("create: ialloc");
80105c57:	c7 04 24 d3 8a 10 80 	movl   $0x80108ad3,(%esp)
80105c5e:	e8 d7 a8 ff ff       	call   8010053a <panic>

  ilock(ip);
80105c63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c66:	89 04 24             	mov    %eax,(%esp)
80105c69:	e8 ed bb ff ff       	call   8010185b <ilock>
  ip->major = major;
80105c6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c71:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105c75:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105c79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c7c:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105c80:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105c84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c87:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105c8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c90:	89 04 24             	mov    %eax,(%esp)
80105c93:	e8 07 ba ff ff       	call   8010169f <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105c98:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105c9d:	75 6a                	jne    80105d09 <create+0x184>
    dp->nlink++;  // for ".."
80105c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ca2:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ca6:	8d 50 01             	lea    0x1(%eax),%edx
80105ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cac:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cb3:	89 04 24             	mov    %eax,(%esp)
80105cb6:	e8 e4 b9 ff ff       	call   8010169f <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105cbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cbe:	8b 40 04             	mov    0x4(%eax),%eax
80105cc1:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cc5:	c7 44 24 04 ad 8a 10 	movl   $0x80108aad,0x4(%esp)
80105ccc:	80 
80105ccd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cd0:	89 04 24             	mov    %eax,(%esp)
80105cd3:	e8 6e c4 ff ff       	call   80102146 <dirlink>
80105cd8:	85 c0                	test   %eax,%eax
80105cda:	78 21                	js     80105cfd <create+0x178>
80105cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cdf:	8b 40 04             	mov    0x4(%eax),%eax
80105ce2:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ce6:	c7 44 24 04 af 8a 10 	movl   $0x80108aaf,0x4(%esp)
80105ced:	80 
80105cee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cf1:	89 04 24             	mov    %eax,(%esp)
80105cf4:	e8 4d c4 ff ff       	call   80102146 <dirlink>
80105cf9:	85 c0                	test   %eax,%eax
80105cfb:	79 0c                	jns    80105d09 <create+0x184>
      panic("create dots");
80105cfd:	c7 04 24 e2 8a 10 80 	movl   $0x80108ae2,(%esp)
80105d04:	e8 31 a8 ff ff       	call   8010053a <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105d09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d0c:	8b 40 04             	mov    0x4(%eax),%eax
80105d0f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d13:	8d 45 de             	lea    -0x22(%ebp),%eax
80105d16:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d1d:	89 04 24             	mov    %eax,(%esp)
80105d20:	e8 21 c4 ff ff       	call   80102146 <dirlink>
80105d25:	85 c0                	test   %eax,%eax
80105d27:	79 0c                	jns    80105d35 <create+0x1b0>
    panic("create: dirlink");
80105d29:	c7 04 24 ee 8a 10 80 	movl   $0x80108aee,(%esp)
80105d30:	e8 05 a8 ff ff       	call   8010053a <panic>

  iunlockput(dp);
80105d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d38:	89 04 24             	mov    %eax,(%esp)
80105d3b:	e8 9f bd ff ff       	call   80101adf <iunlockput>

  return ip;
80105d40:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105d43:	c9                   	leave  
80105d44:	c3                   	ret    

80105d45 <sys_open>:

int
sys_open(void)
{
80105d45:	55                   	push   %ebp
80105d46:	89 e5                	mov    %esp,%ebp
80105d48:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105d4b:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105d4e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d59:	e8 d9 f6 ff ff       	call   80105437 <argstr>
80105d5e:	85 c0                	test   %eax,%eax
80105d60:	78 17                	js     80105d79 <sys_open+0x34>
80105d62:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d65:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d69:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105d70:	e8 32 f6 ff ff       	call   801053a7 <argint>
80105d75:	85 c0                	test   %eax,%eax
80105d77:	79 0a                	jns    80105d83 <sys_open+0x3e>
    return -1;
80105d79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d7e:	e9 5c 01 00 00       	jmp    80105edf <sys_open+0x19a>

  begin_op();
80105d83:	e8 88 d6 ff ff       	call   80103410 <begin_op>

  if(omode & O_CREATE){
80105d88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d8b:	25 00 02 00 00       	and    $0x200,%eax
80105d90:	85 c0                	test   %eax,%eax
80105d92:	74 3b                	je     80105dcf <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80105d94:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d97:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105d9e:	00 
80105d9f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105da6:	00 
80105da7:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105dae:	00 
80105daf:	89 04 24             	mov    %eax,(%esp)
80105db2:	e8 ce fd ff ff       	call   80105b85 <create>
80105db7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105dba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105dbe:	75 6b                	jne    80105e2b <sys_open+0xe6>
      end_op();
80105dc0:	e8 cf d6 ff ff       	call   80103494 <end_op>
      return -1;
80105dc5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dca:	e9 10 01 00 00       	jmp    80105edf <sys_open+0x19a>
    }
  } else {
    if((ip = namei(path)) == 0){
80105dcf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105dd2:	89 04 24             	mov    %eax,(%esp)
80105dd5:	e8 2c c6 ff ff       	call   80102406 <namei>
80105dda:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ddd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105de1:	75 0f                	jne    80105df2 <sys_open+0xad>
      end_op();
80105de3:	e8 ac d6 ff ff       	call   80103494 <end_op>
      return -1;
80105de8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ded:	e9 ed 00 00 00       	jmp    80105edf <sys_open+0x19a>
    }
    ilock(ip);
80105df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df5:	89 04 24             	mov    %eax,(%esp)
80105df8:	e8 5e ba ff ff       	call   8010185b <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e00:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e04:	66 83 f8 01          	cmp    $0x1,%ax
80105e08:	75 21                	jne    80105e2b <sys_open+0xe6>
80105e0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e0d:	85 c0                	test   %eax,%eax
80105e0f:	74 1a                	je     80105e2b <sys_open+0xe6>
      iunlockput(ip);
80105e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e14:	89 04 24             	mov    %eax,(%esp)
80105e17:	e8 c3 bc ff ff       	call   80101adf <iunlockput>
      end_op();
80105e1c:	e8 73 d6 ff ff       	call   80103494 <end_op>
      return -1;
80105e21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e26:	e9 b4 00 00 00       	jmp    80105edf <sys_open+0x19a>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105e2b:	e8 f6 b0 ff ff       	call   80100f26 <filealloc>
80105e30:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e33:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e37:	74 14                	je     80105e4d <sys_open+0x108>
80105e39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e3c:	89 04 24             	mov    %eax,(%esp)
80105e3f:	e8 2e f7 ff ff       	call   80105572 <fdalloc>
80105e44:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105e47:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105e4b:	79 28                	jns    80105e75 <sys_open+0x130>
    if(f)
80105e4d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e51:	74 0b                	je     80105e5e <sys_open+0x119>
      fileclose(f);
80105e53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e56:	89 04 24             	mov    %eax,(%esp)
80105e59:	e8 70 b1 ff ff       	call   80100fce <fileclose>
    iunlockput(ip);
80105e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e61:	89 04 24             	mov    %eax,(%esp)
80105e64:	e8 76 bc ff ff       	call   80101adf <iunlockput>
    end_op();
80105e69:	e8 26 d6 ff ff       	call   80103494 <end_op>
    return -1;
80105e6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e73:	eb 6a                	jmp    80105edf <sys_open+0x19a>
  }
  iunlock(ip);
80105e75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e78:	89 04 24             	mov    %eax,(%esp)
80105e7b:	e8 29 bb ff ff       	call   801019a9 <iunlock>
  end_op();
80105e80:	e8 0f d6 ff ff       	call   80103494 <end_op>

  f->type = FD_INODE;
80105e85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e88:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105e8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e91:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e94:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105e97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e9a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105ea1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ea4:	83 e0 01             	and    $0x1,%eax
80105ea7:	85 c0                	test   %eax,%eax
80105ea9:	0f 94 c0             	sete   %al
80105eac:	89 c2                	mov    %eax,%edx
80105eae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb1:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105eb4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105eb7:	83 e0 01             	and    $0x1,%eax
80105eba:	85 c0                	test   %eax,%eax
80105ebc:	75 0a                	jne    80105ec8 <sys_open+0x183>
80105ebe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ec1:	83 e0 02             	and    $0x2,%eax
80105ec4:	85 c0                	test   %eax,%eax
80105ec6:	74 07                	je     80105ecf <sys_open+0x18a>
80105ec8:	b8 01 00 00 00       	mov    $0x1,%eax
80105ecd:	eb 05                	jmp    80105ed4 <sys_open+0x18f>
80105ecf:	b8 00 00 00 00       	mov    $0x0,%eax
80105ed4:	89 c2                	mov    %eax,%edx
80105ed6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ed9:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105edc:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105edf:	c9                   	leave  
80105ee0:	c3                   	ret    

80105ee1 <sys_mkdir>:

int
sys_mkdir(void)
{
80105ee1:	55                   	push   %ebp
80105ee2:	89 e5                	mov    %esp,%ebp
80105ee4:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105ee7:	e8 24 d5 ff ff       	call   80103410 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105eec:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105eef:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ef3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105efa:	e8 38 f5 ff ff       	call   80105437 <argstr>
80105eff:	85 c0                	test   %eax,%eax
80105f01:	78 2c                	js     80105f2f <sys_mkdir+0x4e>
80105f03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f06:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105f0d:	00 
80105f0e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105f15:	00 
80105f16:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105f1d:	00 
80105f1e:	89 04 24             	mov    %eax,(%esp)
80105f21:	e8 5f fc ff ff       	call   80105b85 <create>
80105f26:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f29:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f2d:	75 0c                	jne    80105f3b <sys_mkdir+0x5a>
    end_op();
80105f2f:	e8 60 d5 ff ff       	call   80103494 <end_op>
    return -1;
80105f34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f39:	eb 15                	jmp    80105f50 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80105f3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f3e:	89 04 24             	mov    %eax,(%esp)
80105f41:	e8 99 bb ff ff       	call   80101adf <iunlockput>
  end_op();
80105f46:	e8 49 d5 ff ff       	call   80103494 <end_op>
  return 0;
80105f4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f50:	c9                   	leave  
80105f51:	c3                   	ret    

80105f52 <sys_mknod>:

int
sys_mknod(void)
{
80105f52:	55                   	push   %ebp
80105f53:	89 e5                	mov    %esp,%ebp
80105f55:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80105f58:	e8 b3 d4 ff ff       	call   80103410 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80105f5d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f60:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f64:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f6b:	e8 c7 f4 ff ff       	call   80105437 <argstr>
80105f70:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f73:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f77:	78 5e                	js     80105fd7 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80105f79:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f7c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f80:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105f87:	e8 1b f4 ff ff       	call   801053a7 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80105f8c:	85 c0                	test   %eax,%eax
80105f8e:	78 47                	js     80105fd7 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105f90:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f93:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f97:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105f9e:	e8 04 f4 ff ff       	call   801053a7 <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80105fa3:	85 c0                	test   %eax,%eax
80105fa5:	78 30                	js     80105fd7 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80105fa7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105faa:	0f bf c8             	movswl %ax,%ecx
80105fad:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fb0:	0f bf d0             	movswl %ax,%edx
80105fb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105fb6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80105fba:	89 54 24 08          	mov    %edx,0x8(%esp)
80105fbe:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80105fc5:	00 
80105fc6:	89 04 24             	mov    %eax,(%esp)
80105fc9:	e8 b7 fb ff ff       	call   80105b85 <create>
80105fce:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fd1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fd5:	75 0c                	jne    80105fe3 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80105fd7:	e8 b8 d4 ff ff       	call   80103494 <end_op>
    return -1;
80105fdc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fe1:	eb 15                	jmp    80105ff8 <sys_mknod+0xa6>
  }
  iunlockput(ip);
80105fe3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fe6:	89 04 24             	mov    %eax,(%esp)
80105fe9:	e8 f1 ba ff ff       	call   80101adf <iunlockput>
  end_op();
80105fee:	e8 a1 d4 ff ff       	call   80103494 <end_op>
  return 0;
80105ff3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ff8:	c9                   	leave  
80105ff9:	c3                   	ret    

80105ffa <sys_chdir>:

int
sys_chdir(void)
{
80105ffa:	55                   	push   %ebp
80105ffb:	89 e5                	mov    %esp,%ebp
80105ffd:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106000:	e8 0b d4 ff ff       	call   80103410 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106005:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106008:	89 44 24 04          	mov    %eax,0x4(%esp)
8010600c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106013:	e8 1f f4 ff ff       	call   80105437 <argstr>
80106018:	85 c0                	test   %eax,%eax
8010601a:	78 14                	js     80106030 <sys_chdir+0x36>
8010601c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010601f:	89 04 24             	mov    %eax,(%esp)
80106022:	e8 df c3 ff ff       	call   80102406 <namei>
80106027:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010602a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010602e:	75 0c                	jne    8010603c <sys_chdir+0x42>
    end_op();
80106030:	e8 5f d4 ff ff       	call   80103494 <end_op>
    return -1;
80106035:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010603a:	eb 61                	jmp    8010609d <sys_chdir+0xa3>
  }
  ilock(ip);
8010603c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010603f:	89 04 24             	mov    %eax,(%esp)
80106042:	e8 14 b8 ff ff       	call   8010185b <ilock>
  if(ip->type != T_DIR){
80106047:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010604a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010604e:	66 83 f8 01          	cmp    $0x1,%ax
80106052:	74 17                	je     8010606b <sys_chdir+0x71>
    iunlockput(ip);
80106054:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106057:	89 04 24             	mov    %eax,(%esp)
8010605a:	e8 80 ba ff ff       	call   80101adf <iunlockput>
    end_op();
8010605f:	e8 30 d4 ff ff       	call   80103494 <end_op>
    return -1;
80106064:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106069:	eb 32                	jmp    8010609d <sys_chdir+0xa3>
  }
  iunlock(ip);
8010606b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010606e:	89 04 24             	mov    %eax,(%esp)
80106071:	e8 33 b9 ff ff       	call   801019a9 <iunlock>
  iput(proc->cwd);
80106076:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010607c:	8b 40 68             	mov    0x68(%eax),%eax
8010607f:	89 04 24             	mov    %eax,(%esp)
80106082:	e8 87 b9 ff ff       	call   80101a0e <iput>
  end_op();
80106087:	e8 08 d4 ff ff       	call   80103494 <end_op>
  proc->cwd = ip;
8010608c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106092:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106095:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106098:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010609d:	c9                   	leave  
8010609e:	c3                   	ret    

8010609f <sys_exec>:

int
sys_exec(void)
{
8010609f:	55                   	push   %ebp
801060a0:	89 e5                	mov    %esp,%ebp
801060a2:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801060a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801060af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801060b6:	e8 7c f3 ff ff       	call   80105437 <argstr>
801060bb:	85 c0                	test   %eax,%eax
801060bd:	78 1a                	js     801060d9 <sys_exec+0x3a>
801060bf:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801060c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801060c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801060d0:	e8 d2 f2 ff ff       	call   801053a7 <argint>
801060d5:	85 c0                	test   %eax,%eax
801060d7:	79 0a                	jns    801060e3 <sys_exec+0x44>
    return -1;
801060d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060de:	e9 c8 00 00 00       	jmp    801061ab <sys_exec+0x10c>
  }
  memset(argv, 0, sizeof(argv));
801060e3:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801060ea:	00 
801060eb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801060f2:	00 
801060f3:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801060f9:	89 04 24             	mov    %eax,(%esp)
801060fc:	e8 64 ef ff ff       	call   80105065 <memset>
  for(i=0;; i++){
80106101:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106108:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010610b:	83 f8 1f             	cmp    $0x1f,%eax
8010610e:	76 0a                	jbe    8010611a <sys_exec+0x7b>
      return -1;
80106110:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106115:	e9 91 00 00 00       	jmp    801061ab <sys_exec+0x10c>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010611a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010611d:	c1 e0 02             	shl    $0x2,%eax
80106120:	89 c2                	mov    %eax,%edx
80106122:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106128:	01 c2                	add    %eax,%edx
8010612a:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106130:	89 44 24 04          	mov    %eax,0x4(%esp)
80106134:	89 14 24             	mov    %edx,(%esp)
80106137:	e8 cf f1 ff ff       	call   8010530b <fetchint>
8010613c:	85 c0                	test   %eax,%eax
8010613e:	79 07                	jns    80106147 <sys_exec+0xa8>
      return -1;
80106140:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106145:	eb 64                	jmp    801061ab <sys_exec+0x10c>
    if(uarg == 0){
80106147:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010614d:	85 c0                	test   %eax,%eax
8010614f:	75 26                	jne    80106177 <sys_exec+0xd8>
      argv[i] = 0;
80106151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106154:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010615b:	00 00 00 00 
      break;
8010615f:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106160:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106163:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106169:	89 54 24 04          	mov    %edx,0x4(%esp)
8010616d:	89 04 24             	mov    %eax,(%esp)
80106170:	e8 7a a9 ff ff       	call   80100aef <exec>
80106175:	eb 34                	jmp    801061ab <sys_exec+0x10c>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106177:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010617d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106180:	c1 e2 02             	shl    $0x2,%edx
80106183:	01 c2                	add    %eax,%edx
80106185:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010618b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010618f:	89 04 24             	mov    %eax,(%esp)
80106192:	e8 ae f1 ff ff       	call   80105345 <fetchstr>
80106197:	85 c0                	test   %eax,%eax
80106199:	79 07                	jns    801061a2 <sys_exec+0x103>
      return -1;
8010619b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061a0:	eb 09                	jmp    801061ab <sys_exec+0x10c>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801061a2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801061a6:	e9 5d ff ff ff       	jmp    80106108 <sys_exec+0x69>
  return exec(path, argv);
}
801061ab:	c9                   	leave  
801061ac:	c3                   	ret    

801061ad <sys_pipe>:

int
sys_pipe(void)
{
801061ad:	55                   	push   %ebp
801061ae:	89 e5                	mov    %esp,%ebp
801061b0:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801061b3:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801061ba:	00 
801061bb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801061be:	89 44 24 04          	mov    %eax,0x4(%esp)
801061c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801061c9:	e8 07 f2 ff ff       	call   801053d5 <argptr>
801061ce:	85 c0                	test   %eax,%eax
801061d0:	79 0a                	jns    801061dc <sys_pipe+0x2f>
    return -1;
801061d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061d7:	e9 9b 00 00 00       	jmp    80106277 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
801061dc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801061df:	89 44 24 04          	mov    %eax,0x4(%esp)
801061e3:	8d 45 e8             	lea    -0x18(%ebp),%eax
801061e6:	89 04 24             	mov    %eax,(%esp)
801061e9:	e8 51 dd ff ff       	call   80103f3f <pipealloc>
801061ee:	85 c0                	test   %eax,%eax
801061f0:	79 07                	jns    801061f9 <sys_pipe+0x4c>
    return -1;
801061f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061f7:	eb 7e                	jmp    80106277 <sys_pipe+0xca>
  fd0 = -1;
801061f9:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106200:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106203:	89 04 24             	mov    %eax,(%esp)
80106206:	e8 67 f3 ff ff       	call   80105572 <fdalloc>
8010620b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010620e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106212:	78 14                	js     80106228 <sys_pipe+0x7b>
80106214:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106217:	89 04 24             	mov    %eax,(%esp)
8010621a:	e8 53 f3 ff ff       	call   80105572 <fdalloc>
8010621f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106222:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106226:	79 37                	jns    8010625f <sys_pipe+0xb2>
    if(fd0 >= 0)
80106228:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010622c:	78 14                	js     80106242 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
8010622e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106234:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106237:	83 c2 08             	add    $0x8,%edx
8010623a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106241:	00 
    fileclose(rf);
80106242:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106245:	89 04 24             	mov    %eax,(%esp)
80106248:	e8 81 ad ff ff       	call   80100fce <fileclose>
    fileclose(wf);
8010624d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106250:	89 04 24             	mov    %eax,(%esp)
80106253:	e8 76 ad ff ff       	call   80100fce <fileclose>
    return -1;
80106258:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010625d:	eb 18                	jmp    80106277 <sys_pipe+0xca>
  }
  fd[0] = fd0;
8010625f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106262:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106265:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106267:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010626a:	8d 50 04             	lea    0x4(%eax),%edx
8010626d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106270:	89 02                	mov    %eax,(%edx)
  return 0;
80106272:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106277:	c9                   	leave  
80106278:	c3                   	ret    

80106279 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106279:	55                   	push   %ebp
8010627a:	89 e5                	mov    %esp,%ebp
8010627c:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010627f:	e8 66 e3 ff ff       	call   801045ea <fork>
}
80106284:	c9                   	leave  
80106285:	c3                   	ret    

80106286 <sys_exit>:

int
sys_exit(void)
{
80106286:	55                   	push   %ebp
80106287:	89 e5                	mov    %esp,%ebp
80106289:	83 ec 08             	sub    $0x8,%esp
  exit();
8010628c:	e8 d4 e4 ff ff       	call   80104765 <exit>
  return 0;  // not reached
80106291:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106296:	c9                   	leave  
80106297:	c3                   	ret    

80106298 <sys_wait>:

int
sys_wait(void)
{
80106298:	55                   	push   %ebp
80106299:	89 e5                	mov    %esp,%ebp
8010629b:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010629e:	e8 e4 e5 ff ff       	call   80104887 <wait>
}
801062a3:	c9                   	leave  
801062a4:	c3                   	ret    

801062a5 <sys_kill>:

int
sys_kill(void)
{
801062a5:	55                   	push   %ebp
801062a6:	89 e5                	mov    %esp,%ebp
801062a8:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
801062ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
801062ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801062b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062b9:	e8 e9 f0 ff ff       	call   801053a7 <argint>
801062be:	85 c0                	test   %eax,%eax
801062c0:	79 07                	jns    801062c9 <sys_kill+0x24>
    return -1;
801062c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062c7:	eb 0b                	jmp    801062d4 <sys_kill+0x2f>
  return kill(pid);
801062c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062cc:	89 04 24             	mov    %eax,(%esp)
801062cf:	e8 77 e9 ff ff       	call   80104c4b <kill>
}
801062d4:	c9                   	leave  
801062d5:	c3                   	ret    

801062d6 <sys_getpid>:

int
sys_getpid(void)
{
801062d6:	55                   	push   %ebp
801062d7:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801062d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062df:	8b 40 10             	mov    0x10(%eax),%eax
}
801062e2:	5d                   	pop    %ebp
801062e3:	c3                   	ret    

801062e4 <sys_sbrk>:

int
sys_sbrk(void)
{
801062e4:	55                   	push   %ebp
801062e5:	89 e5                	mov    %esp,%ebp
801062e7:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

 
  if(argint(0, &n) < 0)
801062ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801062f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062f8:	e8 aa f0 ff ff       	call   801053a7 <argint>
801062fd:	85 c0                	test   %eax,%eax
801062ff:	79 07                	jns    80106308 <sys_sbrk+0x24>
    return -1;
80106301:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106306:	eb 24                	jmp    8010632c <sys_sbrk+0x48>
  addr = proc->sz;
80106308:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010630e:	8b 00                	mov    (%eax),%eax
80106310:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106313:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106316:	89 04 24             	mov    %eax,(%esp)
80106319:	e8 27 e2 ff ff       	call   80104545 <growproc>
8010631e:	85 c0                	test   %eax,%eax
80106320:	79 07                	jns    80106329 <sys_sbrk+0x45>
    return -1;
80106322:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106327:	eb 03                	jmp    8010632c <sys_sbrk+0x48>
  return addr;
80106329:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010632c:	c9                   	leave  
8010632d:	c3                   	ret    

8010632e <sys_sleep>:

int
sys_sleep(void)
{
8010632e:	55                   	push   %ebp
8010632f:	89 e5                	mov    %esp,%ebp
80106331:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106334:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106337:	89 44 24 04          	mov    %eax,0x4(%esp)
8010633b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106342:	e8 60 f0 ff ff       	call   801053a7 <argint>
80106347:	85 c0                	test   %eax,%eax
80106349:	79 07                	jns    80106352 <sys_sleep+0x24>
    return -1;
8010634b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106350:	eb 6c                	jmp    801063be <sys_sleep+0x90>
  acquire(&tickslock);
80106352:	c7 04 24 20 49 11 80 	movl   $0x80114920,(%esp)
80106359:	e8 b3 ea ff ff       	call   80104e11 <acquire>
  ticks0 = ticks;
8010635e:	a1 60 51 11 80       	mov    0x80115160,%eax
80106363:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106366:	eb 34                	jmp    8010639c <sys_sleep+0x6e>
    if(proc->killed){
80106368:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010636e:	8b 40 24             	mov    0x24(%eax),%eax
80106371:	85 c0                	test   %eax,%eax
80106373:	74 13                	je     80106388 <sys_sleep+0x5a>
      release(&tickslock);  
80106375:	c7 04 24 20 49 11 80 	movl   $0x80114920,(%esp)
8010637c:	e8 f2 ea ff ff       	call   80104e73 <release>
      return -1;
80106381:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106386:	eb 36                	jmp    801063be <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106388:	c7 44 24 04 20 49 11 	movl   $0x80114920,0x4(%esp)
8010638f:	80 
80106390:	c7 04 24 60 51 11 80 	movl   $0x80115160,(%esp)
80106397:	e8 ab e7 ff ff       	call   80104b47 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010639c:	a1 60 51 11 80       	mov    0x80115160,%eax
801063a1:	2b 45 f4             	sub    -0xc(%ebp),%eax
801063a4:	89 c2                	mov    %eax,%edx
801063a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063a9:	39 c2                	cmp    %eax,%edx
801063ab:	72 bb                	jb     80106368 <sys_sleep+0x3a>
      release(&tickslock);  
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801063ad:	c7 04 24 20 49 11 80 	movl   $0x80114920,(%esp)
801063b4:	e8 ba ea ff ff       	call   80104e73 <release>
  return 0;
801063b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063be:	c9                   	leave  
801063bf:	c3                   	ret    

801063c0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801063c0:	55                   	push   %ebp
801063c1:	89 e5                	mov    %esp,%ebp
801063c3:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
801063c6:	c7 04 24 20 49 11 80 	movl   $0x80114920,(%esp)
801063cd:	e8 3f ea ff ff       	call   80104e11 <acquire>
  xticks = ticks;
801063d2:	a1 60 51 11 80       	mov    0x80115160,%eax
801063d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801063da:	c7 04 24 20 49 11 80 	movl   $0x80114920,(%esp)
801063e1:	e8 8d ea ff ff       	call   80104e73 <release>
  return xticks;
801063e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801063e9:	c9                   	leave  
801063ea:	c3                   	ret    

801063eb <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801063eb:	55                   	push   %ebp
801063ec:	89 e5                	mov    %esp,%ebp
801063ee:	83 ec 08             	sub    $0x8,%esp
801063f1:	8b 55 08             	mov    0x8(%ebp),%edx
801063f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801063f7:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801063fb:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801063fe:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106402:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106406:	ee                   	out    %al,(%dx)
}
80106407:	c9                   	leave  
80106408:	c3                   	ret    

80106409 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106409:	55                   	push   %ebp
8010640a:	89 e5                	mov    %esp,%ebp
8010640c:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010640f:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
80106416:	00 
80106417:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
8010641e:	e8 c8 ff ff ff       	call   801063eb <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106423:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
8010642a:	00 
8010642b:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106432:	e8 b4 ff ff ff       	call   801063eb <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106437:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
8010643e:	00 
8010643f:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106446:	e8 a0 ff ff ff       	call   801063eb <outb>
  picenable(IRQ_TIMER);
8010644b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106452:	e8 7b d9 ff ff       	call   80103dd2 <picenable>
}
80106457:	c9                   	leave  
80106458:	c3                   	ret    

80106459 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106459:	1e                   	push   %ds
  pushl %es
8010645a:	06                   	push   %es
  pushl %fs
8010645b:	0f a0                	push   %fs
  pushl %gs
8010645d:	0f a8                	push   %gs
  pushal
8010645f:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106460:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106464:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106466:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106468:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
8010646c:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010646e:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106470:	54                   	push   %esp
  call trap
80106471:	e8 d8 01 00 00       	call   8010664e <trap>
  addl $4, %esp
80106476:	83 c4 04             	add    $0x4,%esp

80106479 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106479:	61                   	popa   
  popl %gs
8010647a:	0f a9                	pop    %gs
  popl %fs
8010647c:	0f a1                	pop    %fs
  popl %es
8010647e:	07                   	pop    %es
  popl %ds
8010647f:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106480:	83 c4 08             	add    $0x8,%esp
  iret
80106483:	cf                   	iret   

80106484 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106484:	55                   	push   %ebp
80106485:	89 e5                	mov    %esp,%ebp
80106487:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010648a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010648d:	83 e8 01             	sub    $0x1,%eax
80106490:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106494:	8b 45 08             	mov    0x8(%ebp),%eax
80106497:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010649b:	8b 45 08             	mov    0x8(%ebp),%eax
8010649e:	c1 e8 10             	shr    $0x10,%eax
801064a1:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801064a5:	8d 45 fa             	lea    -0x6(%ebp),%eax
801064a8:	0f 01 18             	lidtl  (%eax)
}
801064ab:	c9                   	leave  
801064ac:	c3                   	ret    

801064ad <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801064ad:	55                   	push   %ebp
801064ae:	89 e5                	mov    %esp,%ebp
801064b0:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801064b3:	0f 20 d0             	mov    %cr2,%eax
801064b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801064b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801064bc:	c9                   	leave  
801064bd:	c3                   	ret    

801064be <tvinit>:
extern void pageFault(uint *va);


void
tvinit(void)
{
801064be:	55                   	push   %ebp
801064bf:	89 e5                	mov    %esp,%ebp
801064c1:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
801064c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801064cb:	e9 c3 00 00 00       	jmp    80106593 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801064d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d3:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
801064da:	89 c2                	mov    %eax,%edx
801064dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064df:	66 89 14 c5 60 49 11 	mov    %dx,-0x7feeb6a0(,%eax,8)
801064e6:	80 
801064e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064ea:	66 c7 04 c5 62 49 11 	movw   $0x8,-0x7feeb69e(,%eax,8)
801064f1:	80 08 00 
801064f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064f7:	0f b6 14 c5 64 49 11 	movzbl -0x7feeb69c(,%eax,8),%edx
801064fe:	80 
801064ff:	83 e2 e0             	and    $0xffffffe0,%edx
80106502:	88 14 c5 64 49 11 80 	mov    %dl,-0x7feeb69c(,%eax,8)
80106509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010650c:	0f b6 14 c5 64 49 11 	movzbl -0x7feeb69c(,%eax,8),%edx
80106513:	80 
80106514:	83 e2 1f             	and    $0x1f,%edx
80106517:	88 14 c5 64 49 11 80 	mov    %dl,-0x7feeb69c(,%eax,8)
8010651e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106521:	0f b6 14 c5 65 49 11 	movzbl -0x7feeb69b(,%eax,8),%edx
80106528:	80 
80106529:	83 e2 f0             	and    $0xfffffff0,%edx
8010652c:	83 ca 0e             	or     $0xe,%edx
8010652f:	88 14 c5 65 49 11 80 	mov    %dl,-0x7feeb69b(,%eax,8)
80106536:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106539:	0f b6 14 c5 65 49 11 	movzbl -0x7feeb69b(,%eax,8),%edx
80106540:	80 
80106541:	83 e2 ef             	and    $0xffffffef,%edx
80106544:	88 14 c5 65 49 11 80 	mov    %dl,-0x7feeb69b(,%eax,8)
8010654b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010654e:	0f b6 14 c5 65 49 11 	movzbl -0x7feeb69b(,%eax,8),%edx
80106555:	80 
80106556:	83 e2 9f             	and    $0xffffff9f,%edx
80106559:	88 14 c5 65 49 11 80 	mov    %dl,-0x7feeb69b(,%eax,8)
80106560:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106563:	0f b6 14 c5 65 49 11 	movzbl -0x7feeb69b(,%eax,8),%edx
8010656a:	80 
8010656b:	83 ca 80             	or     $0xffffff80,%edx
8010656e:	88 14 c5 65 49 11 80 	mov    %dl,-0x7feeb69b(,%eax,8)
80106575:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106578:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
8010657f:	c1 e8 10             	shr    $0x10,%eax
80106582:	89 c2                	mov    %eax,%edx
80106584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106587:	66 89 14 c5 66 49 11 	mov    %dx,-0x7feeb69a(,%eax,8)
8010658e:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010658f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106593:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010659a:	0f 8e 30 ff ff ff    	jle    801064d0 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801065a0:	a1 98 b1 10 80       	mov    0x8010b198,%eax
801065a5:	66 a3 60 4b 11 80    	mov    %ax,0x80114b60
801065ab:	66 c7 05 62 4b 11 80 	movw   $0x8,0x80114b62
801065b2:	08 00 
801065b4:	0f b6 05 64 4b 11 80 	movzbl 0x80114b64,%eax
801065bb:	83 e0 e0             	and    $0xffffffe0,%eax
801065be:	a2 64 4b 11 80       	mov    %al,0x80114b64
801065c3:	0f b6 05 64 4b 11 80 	movzbl 0x80114b64,%eax
801065ca:	83 e0 1f             	and    $0x1f,%eax
801065cd:	a2 64 4b 11 80       	mov    %al,0x80114b64
801065d2:	0f b6 05 65 4b 11 80 	movzbl 0x80114b65,%eax
801065d9:	83 c8 0f             	or     $0xf,%eax
801065dc:	a2 65 4b 11 80       	mov    %al,0x80114b65
801065e1:	0f b6 05 65 4b 11 80 	movzbl 0x80114b65,%eax
801065e8:	83 e0 ef             	and    $0xffffffef,%eax
801065eb:	a2 65 4b 11 80       	mov    %al,0x80114b65
801065f0:	0f b6 05 65 4b 11 80 	movzbl 0x80114b65,%eax
801065f7:	83 c8 60             	or     $0x60,%eax
801065fa:	a2 65 4b 11 80       	mov    %al,0x80114b65
801065ff:	0f b6 05 65 4b 11 80 	movzbl 0x80114b65,%eax
80106606:	83 c8 80             	or     $0xffffff80,%eax
80106609:	a2 65 4b 11 80       	mov    %al,0x80114b65
8010660e:	a1 98 b1 10 80       	mov    0x8010b198,%eax
80106613:	c1 e8 10             	shr    $0x10,%eax
80106616:	66 a3 66 4b 11 80    	mov    %ax,0x80114b66
  
  initlock(&tickslock, "time");
8010661c:	c7 44 24 04 00 8b 10 	movl   $0x80108b00,0x4(%esp)
80106623:	80 
80106624:	c7 04 24 20 49 11 80 	movl   $0x80114920,(%esp)
8010662b:	e8 c0 e7 ff ff       	call   80104df0 <initlock>
}
80106630:	c9                   	leave  
80106631:	c3                   	ret    

80106632 <idtinit>:

void
idtinit(void)
{
80106632:	55                   	push   %ebp
80106633:	89 e5                	mov    %esp,%ebp
80106635:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106638:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
8010663f:	00 
80106640:	c7 04 24 60 49 11 80 	movl   $0x80114960,(%esp)
80106647:	e8 38 fe ff ff       	call   80106484 <lidt>
}
8010664c:	c9                   	leave  
8010664d:	c3                   	ret    

8010664e <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010664e:	55                   	push   %ebp
8010664f:	89 e5                	mov    %esp,%ebp
80106651:	57                   	push   %edi
80106652:	56                   	push   %esi
80106653:	53                   	push   %ebx
80106654:	83 ec 4c             	sub    $0x4c,%esp
  if(tf->trapno == T_SYSCALL){
80106657:	8b 45 08             	mov    0x8(%ebp),%eax
8010665a:	8b 40 30             	mov    0x30(%eax),%eax
8010665d:	83 f8 40             	cmp    $0x40,%eax
80106660:	75 3f                	jne    801066a1 <trap+0x53>
    if(proc->killed)
80106662:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106668:	8b 40 24             	mov    0x24(%eax),%eax
8010666b:	85 c0                	test   %eax,%eax
8010666d:	74 05                	je     80106674 <trap+0x26>
      exit();
8010666f:	e8 f1 e0 ff ff       	call   80104765 <exit>
    proc->tf = tf;
80106674:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010667a:	8b 55 08             	mov    0x8(%ebp),%edx
8010667d:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106680:	e8 e9 ed ff ff       	call   8010546e <syscall>
    if(proc->killed)
80106685:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010668b:	8b 40 24             	mov    0x24(%eax),%eax
8010668e:	85 c0                	test   %eax,%eax
80106690:	74 0a                	je     8010669c <trap+0x4e>
      exit();
80106692:	e8 ce e0 ff ff       	call   80104765 <exit>
    return;
80106697:	e9 54 02 00 00       	jmp    801068f0 <trap+0x2a2>
8010669c:	e9 4f 02 00 00       	jmp    801068f0 <trap+0x2a2>
  }
  
 uint *va;
 // char *mem;
 //  uint a;
  switch(tf->trapno){
801066a1:	8b 45 08             	mov    0x8(%ebp),%eax
801066a4:	8b 40 30             	mov    0x30(%eax),%eax
801066a7:	83 e8 0e             	sub    $0xe,%eax
801066aa:	83 f8 31             	cmp    $0x31,%eax
801066ad:	0f 87 e3 00 00 00    	ja     80106796 <trap+0x148>
801066b3:	8b 04 85 a8 8b 10 80 	mov    -0x7fef7458(,%eax,4),%eax
801066ba:	ff e0                	jmp    *%eax
 
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801066bc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801066c2:	0f b6 00             	movzbl (%eax),%eax
801066c5:	84 c0                	test   %al,%al
801066c7:	75 31                	jne    801066fa <trap+0xac>
      acquire(&tickslock);
801066c9:	c7 04 24 20 49 11 80 	movl   $0x80114920,(%esp)
801066d0:	e8 3c e7 ff ff       	call   80104e11 <acquire>
      ticks++;
801066d5:	a1 60 51 11 80       	mov    0x80115160,%eax
801066da:	83 c0 01             	add    $0x1,%eax
801066dd:	a3 60 51 11 80       	mov    %eax,0x80115160
      wakeup(&ticks);
801066e2:	c7 04 24 60 51 11 80 	movl   $0x80115160,(%esp)
801066e9:	e8 32 e5 ff ff       	call   80104c20 <wakeup>
      release(&tickslock);
801066ee:	c7 04 24 20 49 11 80 	movl   $0x80114920,(%esp)
801066f5:	e8 79 e7 ff ff       	call   80104e73 <release>
    }
    lapiceoi();
801066fa:	e8 d1 c7 ff ff       	call   80102ed0 <lapiceoi>
    break;
801066ff:	e9 68 01 00 00       	jmp    8010686c <trap+0x21e>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106704:	e8 d5 bf ff ff       	call   801026de <ideintr>
    lapiceoi();
80106709:	e8 c2 c7 ff ff       	call   80102ed0 <lapiceoi>
    break;
8010670e:	e9 59 01 00 00       	jmp    8010686c <trap+0x21e>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106713:	e8 87 c5 ff ff       	call   80102c9f <kbdintr>
    lapiceoi();
80106718:	e8 b3 c7 ff ff       	call   80102ed0 <lapiceoi>
    break;
8010671d:	e9 4a 01 00 00       	jmp    8010686c <trap+0x21e>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106722:	e8 be 03 00 00       	call   80106ae5 <uartintr>
    lapiceoi();
80106727:	e8 a4 c7 ff ff       	call   80102ed0 <lapiceoi>
    break;
8010672c:	e9 3b 01 00 00       	jmp    8010686c <trap+0x21e>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106731:	8b 45 08             	mov    0x8(%ebp),%eax
80106734:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106737:	8b 45 08             	mov    0x8(%ebp),%eax
8010673a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010673e:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106741:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106747:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010674a:	0f b6 c0             	movzbl %al,%eax
8010674d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106751:	89 54 24 08          	mov    %edx,0x8(%esp)
80106755:	89 44 24 04          	mov    %eax,0x4(%esp)
80106759:	c7 04 24 08 8b 10 80 	movl   $0x80108b08,(%esp)
80106760:	e8 3b 9c ff ff       	call   801003a0 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106765:	e8 66 c7 ff ff       	call   80102ed0 <lapiceoi>
    break;
8010676a:	e9 fd 00 00 00       	jmp    8010686c <trap+0x21e>
  

  case T_PGFLT:


       va =(uint*) rcr2();
8010676f:	e8 39 fd ff ff       	call   801064ad <rcr2>
80106774:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      
      if ((uint) va <= proc->sz){
80106777:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010677a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106780:	8b 00                	mov    (%eax),%eax
80106782:	39 c2                	cmp    %eax,%edx
80106784:	77 10                	ja     80106796 <trap+0x148>
        pageFault(va);
80106786:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106789:	89 04 24             	mov    %eax,(%esp)
8010678c:	e8 a7 1c 00 00       	call   80108438 <pageFault>
        break;
80106791:	e9 d6 00 00 00       	jmp    8010686c <trap+0x21e>
      // mappages(proc->pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
      
 
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106796:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010679c:	85 c0                	test   %eax,%eax
8010679e:	74 11                	je     801067b1 <trap+0x163>
801067a0:	8b 45 08             	mov    0x8(%ebp),%eax
801067a3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801067a7:	0f b7 c0             	movzwl %ax,%eax
801067aa:	83 e0 03             	and    $0x3,%eax
801067ad:	85 c0                	test   %eax,%eax
801067af:	75 46                	jne    801067f7 <trap+0x1a9>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801067b1:	e8 f7 fc ff ff       	call   801064ad <rcr2>
801067b6:	8b 55 08             	mov    0x8(%ebp),%edx
801067b9:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
801067bc:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801067c3:	0f b6 12             	movzbl (%edx),%edx
 
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801067c6:	0f b6 ca             	movzbl %dl,%ecx
801067c9:	8b 55 08             	mov    0x8(%ebp),%edx
801067cc:	8b 52 30             	mov    0x30(%edx),%edx
801067cf:	89 44 24 10          	mov    %eax,0x10(%esp)
801067d3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
801067d7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801067db:	89 54 24 04          	mov    %edx,0x4(%esp)
801067df:	c7 04 24 2c 8b 10 80 	movl   $0x80108b2c,(%esp)
801067e6:	e8 b5 9b ff ff       	call   801003a0 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
801067eb:	c7 04 24 5e 8b 10 80 	movl   $0x80108b5e,(%esp)
801067f2:	e8 43 9d ff ff       	call   8010053a <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801067f7:	e8 b1 fc ff ff       	call   801064ad <rcr2>
801067fc:	89 c2                	mov    %eax,%edx
801067fe:	8b 45 08             	mov    0x8(%ebp),%eax
80106801:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106804:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010680a:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010680d:	0f b6 f0             	movzbl %al,%esi
80106810:	8b 45 08             	mov    0x8(%ebp),%eax
80106813:	8b 58 34             	mov    0x34(%eax),%ebx
80106816:	8b 45 08             	mov    0x8(%ebp),%eax
80106819:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010681c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106822:	83 c0 6c             	add    $0x6c,%eax
80106825:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106828:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010682e:	8b 40 10             	mov    0x10(%eax),%eax
80106831:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106835:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106839:	89 74 24 14          	mov    %esi,0x14(%esp)
8010683d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106841:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106845:	8b 75 d4             	mov    -0x2c(%ebp),%esi
80106848:	89 74 24 08          	mov    %esi,0x8(%esp)
8010684c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106850:	c7 04 24 64 8b 10 80 	movl   $0x80108b64,(%esp)
80106857:	e8 44 9b ff ff       	call   801003a0 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
8010685c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106862:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106869:	eb 01                	jmp    8010686c <trap+0x21e>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
8010686b:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010686c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106872:	85 c0                	test   %eax,%eax
80106874:	74 24                	je     8010689a <trap+0x24c>
80106876:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010687c:	8b 40 24             	mov    0x24(%eax),%eax
8010687f:	85 c0                	test   %eax,%eax
80106881:	74 17                	je     8010689a <trap+0x24c>
80106883:	8b 45 08             	mov    0x8(%ebp),%eax
80106886:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010688a:	0f b7 c0             	movzwl %ax,%eax
8010688d:	83 e0 03             	and    $0x3,%eax
80106890:	83 f8 03             	cmp    $0x3,%eax
80106893:	75 05                	jne    8010689a <trap+0x24c>
    exit();
80106895:	e8 cb de ff ff       	call   80104765 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
8010689a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068a0:	85 c0                	test   %eax,%eax
801068a2:	74 1e                	je     801068c2 <trap+0x274>
801068a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068aa:	8b 40 0c             	mov    0xc(%eax),%eax
801068ad:	83 f8 04             	cmp    $0x4,%eax
801068b0:	75 10                	jne    801068c2 <trap+0x274>
801068b2:	8b 45 08             	mov    0x8(%ebp),%eax
801068b5:	8b 40 30             	mov    0x30(%eax),%eax
801068b8:	83 f8 20             	cmp    $0x20,%eax
801068bb:	75 05                	jne    801068c2 <trap+0x274>
    yield();
801068bd:	e8 27 e2 ff ff       	call   80104ae9 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801068c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068c8:	85 c0                	test   %eax,%eax
801068ca:	74 24                	je     801068f0 <trap+0x2a2>
801068cc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068d2:	8b 40 24             	mov    0x24(%eax),%eax
801068d5:	85 c0                	test   %eax,%eax
801068d7:	74 17                	je     801068f0 <trap+0x2a2>
801068d9:	8b 45 08             	mov    0x8(%ebp),%eax
801068dc:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801068e0:	0f b7 c0             	movzwl %ax,%eax
801068e3:	83 e0 03             	and    $0x3,%eax
801068e6:	83 f8 03             	cmp    $0x3,%eax
801068e9:	75 05                	jne    801068f0 <trap+0x2a2>
    exit();
801068eb:	e8 75 de ff ff       	call   80104765 <exit>
}
801068f0:	83 c4 4c             	add    $0x4c,%esp
801068f3:	5b                   	pop    %ebx
801068f4:	5e                   	pop    %esi
801068f5:	5f                   	pop    %edi
801068f6:	5d                   	pop    %ebp
801068f7:	c3                   	ret    

801068f8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801068f8:	55                   	push   %ebp
801068f9:	89 e5                	mov    %esp,%ebp
801068fb:	83 ec 14             	sub    $0x14,%esp
801068fe:	8b 45 08             	mov    0x8(%ebp),%eax
80106901:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106905:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106909:	89 c2                	mov    %eax,%edx
8010690b:	ec                   	in     (%dx),%al
8010690c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010690f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106913:	c9                   	leave  
80106914:	c3                   	ret    

80106915 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106915:	55                   	push   %ebp
80106916:	89 e5                	mov    %esp,%ebp
80106918:	83 ec 08             	sub    $0x8,%esp
8010691b:	8b 55 08             	mov    0x8(%ebp),%edx
8010691e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106921:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106925:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106928:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010692c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106930:	ee                   	out    %al,(%dx)
}
80106931:	c9                   	leave  
80106932:	c3                   	ret    

80106933 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106933:	55                   	push   %ebp
80106934:	89 e5                	mov    %esp,%ebp
80106936:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106939:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106940:	00 
80106941:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106948:	e8 c8 ff ff ff       	call   80106915 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010694d:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106954:	00 
80106955:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
8010695c:	e8 b4 ff ff ff       	call   80106915 <outb>
  outb(COM1+0, 115200/9600);
80106961:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106968:	00 
80106969:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106970:	e8 a0 ff ff ff       	call   80106915 <outb>
  outb(COM1+1, 0);
80106975:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010697c:	00 
8010697d:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106984:	e8 8c ff ff ff       	call   80106915 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106989:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106990:	00 
80106991:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106998:	e8 78 ff ff ff       	call   80106915 <outb>
  outb(COM1+4, 0);
8010699d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801069a4:	00 
801069a5:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
801069ac:	e8 64 ff ff ff       	call   80106915 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801069b1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801069b8:	00 
801069b9:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
801069c0:	e8 50 ff ff ff       	call   80106915 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801069c5:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801069cc:	e8 27 ff ff ff       	call   801068f8 <inb>
801069d1:	3c ff                	cmp    $0xff,%al
801069d3:	75 02                	jne    801069d7 <uartinit+0xa4>
    return;
801069d5:	eb 6a                	jmp    80106a41 <uartinit+0x10e>
  uart = 1;
801069d7:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
801069de:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801069e1:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801069e8:	e8 0b ff ff ff       	call   801068f8 <inb>
  inb(COM1+0);
801069ed:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801069f4:	e8 ff fe ff ff       	call   801068f8 <inb>
  picenable(IRQ_COM1);
801069f9:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106a00:	e8 cd d3 ff ff       	call   80103dd2 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106a05:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106a0c:	00 
80106a0d:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106a14:	e8 44 bf ff ff       	call   8010295d <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106a19:	c7 45 f4 70 8c 10 80 	movl   $0x80108c70,-0xc(%ebp)
80106a20:	eb 15                	jmp    80106a37 <uartinit+0x104>
    uartputc(*p);
80106a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a25:	0f b6 00             	movzbl (%eax),%eax
80106a28:	0f be c0             	movsbl %al,%eax
80106a2b:	89 04 24             	mov    %eax,(%esp)
80106a2e:	e8 10 00 00 00       	call   80106a43 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106a33:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a3a:	0f b6 00             	movzbl (%eax),%eax
80106a3d:	84 c0                	test   %al,%al
80106a3f:	75 e1                	jne    80106a22 <uartinit+0xef>
    uartputc(*p);
}
80106a41:	c9                   	leave  
80106a42:	c3                   	ret    

80106a43 <uartputc>:

void
uartputc(int c)
{
80106a43:	55                   	push   %ebp
80106a44:	89 e5                	mov    %esp,%ebp
80106a46:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106a49:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106a4e:	85 c0                	test   %eax,%eax
80106a50:	75 02                	jne    80106a54 <uartputc+0x11>
    return;
80106a52:	eb 4b                	jmp    80106a9f <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106a54:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106a5b:	eb 10                	jmp    80106a6d <uartputc+0x2a>
    microdelay(10);
80106a5d:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106a64:	e8 8c c4 ff ff       	call   80102ef5 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106a69:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a6d:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106a71:	7f 16                	jg     80106a89 <uartputc+0x46>
80106a73:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106a7a:	e8 79 fe ff ff       	call   801068f8 <inb>
80106a7f:	0f b6 c0             	movzbl %al,%eax
80106a82:	83 e0 20             	and    $0x20,%eax
80106a85:	85 c0                	test   %eax,%eax
80106a87:	74 d4                	je     80106a5d <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106a89:	8b 45 08             	mov    0x8(%ebp),%eax
80106a8c:	0f b6 c0             	movzbl %al,%eax
80106a8f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a93:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106a9a:	e8 76 fe ff ff       	call   80106915 <outb>
}
80106a9f:	c9                   	leave  
80106aa0:	c3                   	ret    

80106aa1 <uartgetc>:

static int
uartgetc(void)
{
80106aa1:	55                   	push   %ebp
80106aa2:	89 e5                	mov    %esp,%ebp
80106aa4:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106aa7:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106aac:	85 c0                	test   %eax,%eax
80106aae:	75 07                	jne    80106ab7 <uartgetc+0x16>
    return -1;
80106ab0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ab5:	eb 2c                	jmp    80106ae3 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106ab7:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106abe:	e8 35 fe ff ff       	call   801068f8 <inb>
80106ac3:	0f b6 c0             	movzbl %al,%eax
80106ac6:	83 e0 01             	and    $0x1,%eax
80106ac9:	85 c0                	test   %eax,%eax
80106acb:	75 07                	jne    80106ad4 <uartgetc+0x33>
    return -1;
80106acd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ad2:	eb 0f                	jmp    80106ae3 <uartgetc+0x42>
  return inb(COM1+0);
80106ad4:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106adb:	e8 18 fe ff ff       	call   801068f8 <inb>
80106ae0:	0f b6 c0             	movzbl %al,%eax
}
80106ae3:	c9                   	leave  
80106ae4:	c3                   	ret    

80106ae5 <uartintr>:

void
uartintr(void)
{
80106ae5:	55                   	push   %ebp
80106ae6:	89 e5                	mov    %esp,%ebp
80106ae8:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106aeb:	c7 04 24 a1 6a 10 80 	movl   $0x80106aa1,(%esp)
80106af2:	e8 b6 9c ff ff       	call   801007ad <consoleintr>
}
80106af7:	c9                   	leave  
80106af8:	c3                   	ret    

80106af9 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106af9:	6a 00                	push   $0x0
  pushl $0
80106afb:	6a 00                	push   $0x0
  jmp alltraps
80106afd:	e9 57 f9 ff ff       	jmp    80106459 <alltraps>

80106b02 <vector1>:
.globl vector1
vector1:
  pushl $0
80106b02:	6a 00                	push   $0x0
  pushl $1
80106b04:	6a 01                	push   $0x1
  jmp alltraps
80106b06:	e9 4e f9 ff ff       	jmp    80106459 <alltraps>

80106b0b <vector2>:
.globl vector2
vector2:
  pushl $0
80106b0b:	6a 00                	push   $0x0
  pushl $2
80106b0d:	6a 02                	push   $0x2
  jmp alltraps
80106b0f:	e9 45 f9 ff ff       	jmp    80106459 <alltraps>

80106b14 <vector3>:
.globl vector3
vector3:
  pushl $0
80106b14:	6a 00                	push   $0x0
  pushl $3
80106b16:	6a 03                	push   $0x3
  jmp alltraps
80106b18:	e9 3c f9 ff ff       	jmp    80106459 <alltraps>

80106b1d <vector4>:
.globl vector4
vector4:
  pushl $0
80106b1d:	6a 00                	push   $0x0
  pushl $4
80106b1f:	6a 04                	push   $0x4
  jmp alltraps
80106b21:	e9 33 f9 ff ff       	jmp    80106459 <alltraps>

80106b26 <vector5>:
.globl vector5
vector5:
  pushl $0
80106b26:	6a 00                	push   $0x0
  pushl $5
80106b28:	6a 05                	push   $0x5
  jmp alltraps
80106b2a:	e9 2a f9 ff ff       	jmp    80106459 <alltraps>

80106b2f <vector6>:
.globl vector6
vector6:
  pushl $0
80106b2f:	6a 00                	push   $0x0
  pushl $6
80106b31:	6a 06                	push   $0x6
  jmp alltraps
80106b33:	e9 21 f9 ff ff       	jmp    80106459 <alltraps>

80106b38 <vector7>:
.globl vector7
vector7:
  pushl $0
80106b38:	6a 00                	push   $0x0
  pushl $7
80106b3a:	6a 07                	push   $0x7
  jmp alltraps
80106b3c:	e9 18 f9 ff ff       	jmp    80106459 <alltraps>

80106b41 <vector8>:
.globl vector8
vector8:
  pushl $8
80106b41:	6a 08                	push   $0x8
  jmp alltraps
80106b43:	e9 11 f9 ff ff       	jmp    80106459 <alltraps>

80106b48 <vector9>:
.globl vector9
vector9:
  pushl $0
80106b48:	6a 00                	push   $0x0
  pushl $9
80106b4a:	6a 09                	push   $0x9
  jmp alltraps
80106b4c:	e9 08 f9 ff ff       	jmp    80106459 <alltraps>

80106b51 <vector10>:
.globl vector10
vector10:
  pushl $10
80106b51:	6a 0a                	push   $0xa
  jmp alltraps
80106b53:	e9 01 f9 ff ff       	jmp    80106459 <alltraps>

80106b58 <vector11>:
.globl vector11
vector11:
  pushl $11
80106b58:	6a 0b                	push   $0xb
  jmp alltraps
80106b5a:	e9 fa f8 ff ff       	jmp    80106459 <alltraps>

80106b5f <vector12>:
.globl vector12
vector12:
  pushl $12
80106b5f:	6a 0c                	push   $0xc
  jmp alltraps
80106b61:	e9 f3 f8 ff ff       	jmp    80106459 <alltraps>

80106b66 <vector13>:
.globl vector13
vector13:
  pushl $13
80106b66:	6a 0d                	push   $0xd
  jmp alltraps
80106b68:	e9 ec f8 ff ff       	jmp    80106459 <alltraps>

80106b6d <vector14>:
.globl vector14
vector14:
  pushl $14
80106b6d:	6a 0e                	push   $0xe
  jmp alltraps
80106b6f:	e9 e5 f8 ff ff       	jmp    80106459 <alltraps>

80106b74 <vector15>:
.globl vector15
vector15:
  pushl $0
80106b74:	6a 00                	push   $0x0
  pushl $15
80106b76:	6a 0f                	push   $0xf
  jmp alltraps
80106b78:	e9 dc f8 ff ff       	jmp    80106459 <alltraps>

80106b7d <vector16>:
.globl vector16
vector16:
  pushl $0
80106b7d:	6a 00                	push   $0x0
  pushl $16
80106b7f:	6a 10                	push   $0x10
  jmp alltraps
80106b81:	e9 d3 f8 ff ff       	jmp    80106459 <alltraps>

80106b86 <vector17>:
.globl vector17
vector17:
  pushl $17
80106b86:	6a 11                	push   $0x11
  jmp alltraps
80106b88:	e9 cc f8 ff ff       	jmp    80106459 <alltraps>

80106b8d <vector18>:
.globl vector18
vector18:
  pushl $0
80106b8d:	6a 00                	push   $0x0
  pushl $18
80106b8f:	6a 12                	push   $0x12
  jmp alltraps
80106b91:	e9 c3 f8 ff ff       	jmp    80106459 <alltraps>

80106b96 <vector19>:
.globl vector19
vector19:
  pushl $0
80106b96:	6a 00                	push   $0x0
  pushl $19
80106b98:	6a 13                	push   $0x13
  jmp alltraps
80106b9a:	e9 ba f8 ff ff       	jmp    80106459 <alltraps>

80106b9f <vector20>:
.globl vector20
vector20:
  pushl $0
80106b9f:	6a 00                	push   $0x0
  pushl $20
80106ba1:	6a 14                	push   $0x14
  jmp alltraps
80106ba3:	e9 b1 f8 ff ff       	jmp    80106459 <alltraps>

80106ba8 <vector21>:
.globl vector21
vector21:
  pushl $0
80106ba8:	6a 00                	push   $0x0
  pushl $21
80106baa:	6a 15                	push   $0x15
  jmp alltraps
80106bac:	e9 a8 f8 ff ff       	jmp    80106459 <alltraps>

80106bb1 <vector22>:
.globl vector22
vector22:
  pushl $0
80106bb1:	6a 00                	push   $0x0
  pushl $22
80106bb3:	6a 16                	push   $0x16
  jmp alltraps
80106bb5:	e9 9f f8 ff ff       	jmp    80106459 <alltraps>

80106bba <vector23>:
.globl vector23
vector23:
  pushl $0
80106bba:	6a 00                	push   $0x0
  pushl $23
80106bbc:	6a 17                	push   $0x17
  jmp alltraps
80106bbe:	e9 96 f8 ff ff       	jmp    80106459 <alltraps>

80106bc3 <vector24>:
.globl vector24
vector24:
  pushl $0
80106bc3:	6a 00                	push   $0x0
  pushl $24
80106bc5:	6a 18                	push   $0x18
  jmp alltraps
80106bc7:	e9 8d f8 ff ff       	jmp    80106459 <alltraps>

80106bcc <vector25>:
.globl vector25
vector25:
  pushl $0
80106bcc:	6a 00                	push   $0x0
  pushl $25
80106bce:	6a 19                	push   $0x19
  jmp alltraps
80106bd0:	e9 84 f8 ff ff       	jmp    80106459 <alltraps>

80106bd5 <vector26>:
.globl vector26
vector26:
  pushl $0
80106bd5:	6a 00                	push   $0x0
  pushl $26
80106bd7:	6a 1a                	push   $0x1a
  jmp alltraps
80106bd9:	e9 7b f8 ff ff       	jmp    80106459 <alltraps>

80106bde <vector27>:
.globl vector27
vector27:
  pushl $0
80106bde:	6a 00                	push   $0x0
  pushl $27
80106be0:	6a 1b                	push   $0x1b
  jmp alltraps
80106be2:	e9 72 f8 ff ff       	jmp    80106459 <alltraps>

80106be7 <vector28>:
.globl vector28
vector28:
  pushl $0
80106be7:	6a 00                	push   $0x0
  pushl $28
80106be9:	6a 1c                	push   $0x1c
  jmp alltraps
80106beb:	e9 69 f8 ff ff       	jmp    80106459 <alltraps>

80106bf0 <vector29>:
.globl vector29
vector29:
  pushl $0
80106bf0:	6a 00                	push   $0x0
  pushl $29
80106bf2:	6a 1d                	push   $0x1d
  jmp alltraps
80106bf4:	e9 60 f8 ff ff       	jmp    80106459 <alltraps>

80106bf9 <vector30>:
.globl vector30
vector30:
  pushl $0
80106bf9:	6a 00                	push   $0x0
  pushl $30
80106bfb:	6a 1e                	push   $0x1e
  jmp alltraps
80106bfd:	e9 57 f8 ff ff       	jmp    80106459 <alltraps>

80106c02 <vector31>:
.globl vector31
vector31:
  pushl $0
80106c02:	6a 00                	push   $0x0
  pushl $31
80106c04:	6a 1f                	push   $0x1f
  jmp alltraps
80106c06:	e9 4e f8 ff ff       	jmp    80106459 <alltraps>

80106c0b <vector32>:
.globl vector32
vector32:
  pushl $0
80106c0b:	6a 00                	push   $0x0
  pushl $32
80106c0d:	6a 20                	push   $0x20
  jmp alltraps
80106c0f:	e9 45 f8 ff ff       	jmp    80106459 <alltraps>

80106c14 <vector33>:
.globl vector33
vector33:
  pushl $0
80106c14:	6a 00                	push   $0x0
  pushl $33
80106c16:	6a 21                	push   $0x21
  jmp alltraps
80106c18:	e9 3c f8 ff ff       	jmp    80106459 <alltraps>

80106c1d <vector34>:
.globl vector34
vector34:
  pushl $0
80106c1d:	6a 00                	push   $0x0
  pushl $34
80106c1f:	6a 22                	push   $0x22
  jmp alltraps
80106c21:	e9 33 f8 ff ff       	jmp    80106459 <alltraps>

80106c26 <vector35>:
.globl vector35
vector35:
  pushl $0
80106c26:	6a 00                	push   $0x0
  pushl $35
80106c28:	6a 23                	push   $0x23
  jmp alltraps
80106c2a:	e9 2a f8 ff ff       	jmp    80106459 <alltraps>

80106c2f <vector36>:
.globl vector36
vector36:
  pushl $0
80106c2f:	6a 00                	push   $0x0
  pushl $36
80106c31:	6a 24                	push   $0x24
  jmp alltraps
80106c33:	e9 21 f8 ff ff       	jmp    80106459 <alltraps>

80106c38 <vector37>:
.globl vector37
vector37:
  pushl $0
80106c38:	6a 00                	push   $0x0
  pushl $37
80106c3a:	6a 25                	push   $0x25
  jmp alltraps
80106c3c:	e9 18 f8 ff ff       	jmp    80106459 <alltraps>

80106c41 <vector38>:
.globl vector38
vector38:
  pushl $0
80106c41:	6a 00                	push   $0x0
  pushl $38
80106c43:	6a 26                	push   $0x26
  jmp alltraps
80106c45:	e9 0f f8 ff ff       	jmp    80106459 <alltraps>

80106c4a <vector39>:
.globl vector39
vector39:
  pushl $0
80106c4a:	6a 00                	push   $0x0
  pushl $39
80106c4c:	6a 27                	push   $0x27
  jmp alltraps
80106c4e:	e9 06 f8 ff ff       	jmp    80106459 <alltraps>

80106c53 <vector40>:
.globl vector40
vector40:
  pushl $0
80106c53:	6a 00                	push   $0x0
  pushl $40
80106c55:	6a 28                	push   $0x28
  jmp alltraps
80106c57:	e9 fd f7 ff ff       	jmp    80106459 <alltraps>

80106c5c <vector41>:
.globl vector41
vector41:
  pushl $0
80106c5c:	6a 00                	push   $0x0
  pushl $41
80106c5e:	6a 29                	push   $0x29
  jmp alltraps
80106c60:	e9 f4 f7 ff ff       	jmp    80106459 <alltraps>

80106c65 <vector42>:
.globl vector42
vector42:
  pushl $0
80106c65:	6a 00                	push   $0x0
  pushl $42
80106c67:	6a 2a                	push   $0x2a
  jmp alltraps
80106c69:	e9 eb f7 ff ff       	jmp    80106459 <alltraps>

80106c6e <vector43>:
.globl vector43
vector43:
  pushl $0
80106c6e:	6a 00                	push   $0x0
  pushl $43
80106c70:	6a 2b                	push   $0x2b
  jmp alltraps
80106c72:	e9 e2 f7 ff ff       	jmp    80106459 <alltraps>

80106c77 <vector44>:
.globl vector44
vector44:
  pushl $0
80106c77:	6a 00                	push   $0x0
  pushl $44
80106c79:	6a 2c                	push   $0x2c
  jmp alltraps
80106c7b:	e9 d9 f7 ff ff       	jmp    80106459 <alltraps>

80106c80 <vector45>:
.globl vector45
vector45:
  pushl $0
80106c80:	6a 00                	push   $0x0
  pushl $45
80106c82:	6a 2d                	push   $0x2d
  jmp alltraps
80106c84:	e9 d0 f7 ff ff       	jmp    80106459 <alltraps>

80106c89 <vector46>:
.globl vector46
vector46:
  pushl $0
80106c89:	6a 00                	push   $0x0
  pushl $46
80106c8b:	6a 2e                	push   $0x2e
  jmp alltraps
80106c8d:	e9 c7 f7 ff ff       	jmp    80106459 <alltraps>

80106c92 <vector47>:
.globl vector47
vector47:
  pushl $0
80106c92:	6a 00                	push   $0x0
  pushl $47
80106c94:	6a 2f                	push   $0x2f
  jmp alltraps
80106c96:	e9 be f7 ff ff       	jmp    80106459 <alltraps>

80106c9b <vector48>:
.globl vector48
vector48:
  pushl $0
80106c9b:	6a 00                	push   $0x0
  pushl $48
80106c9d:	6a 30                	push   $0x30
  jmp alltraps
80106c9f:	e9 b5 f7 ff ff       	jmp    80106459 <alltraps>

80106ca4 <vector49>:
.globl vector49
vector49:
  pushl $0
80106ca4:	6a 00                	push   $0x0
  pushl $49
80106ca6:	6a 31                	push   $0x31
  jmp alltraps
80106ca8:	e9 ac f7 ff ff       	jmp    80106459 <alltraps>

80106cad <vector50>:
.globl vector50
vector50:
  pushl $0
80106cad:	6a 00                	push   $0x0
  pushl $50
80106caf:	6a 32                	push   $0x32
  jmp alltraps
80106cb1:	e9 a3 f7 ff ff       	jmp    80106459 <alltraps>

80106cb6 <vector51>:
.globl vector51
vector51:
  pushl $0
80106cb6:	6a 00                	push   $0x0
  pushl $51
80106cb8:	6a 33                	push   $0x33
  jmp alltraps
80106cba:	e9 9a f7 ff ff       	jmp    80106459 <alltraps>

80106cbf <vector52>:
.globl vector52
vector52:
  pushl $0
80106cbf:	6a 00                	push   $0x0
  pushl $52
80106cc1:	6a 34                	push   $0x34
  jmp alltraps
80106cc3:	e9 91 f7 ff ff       	jmp    80106459 <alltraps>

80106cc8 <vector53>:
.globl vector53
vector53:
  pushl $0
80106cc8:	6a 00                	push   $0x0
  pushl $53
80106cca:	6a 35                	push   $0x35
  jmp alltraps
80106ccc:	e9 88 f7 ff ff       	jmp    80106459 <alltraps>

80106cd1 <vector54>:
.globl vector54
vector54:
  pushl $0
80106cd1:	6a 00                	push   $0x0
  pushl $54
80106cd3:	6a 36                	push   $0x36
  jmp alltraps
80106cd5:	e9 7f f7 ff ff       	jmp    80106459 <alltraps>

80106cda <vector55>:
.globl vector55
vector55:
  pushl $0
80106cda:	6a 00                	push   $0x0
  pushl $55
80106cdc:	6a 37                	push   $0x37
  jmp alltraps
80106cde:	e9 76 f7 ff ff       	jmp    80106459 <alltraps>

80106ce3 <vector56>:
.globl vector56
vector56:
  pushl $0
80106ce3:	6a 00                	push   $0x0
  pushl $56
80106ce5:	6a 38                	push   $0x38
  jmp alltraps
80106ce7:	e9 6d f7 ff ff       	jmp    80106459 <alltraps>

80106cec <vector57>:
.globl vector57
vector57:
  pushl $0
80106cec:	6a 00                	push   $0x0
  pushl $57
80106cee:	6a 39                	push   $0x39
  jmp alltraps
80106cf0:	e9 64 f7 ff ff       	jmp    80106459 <alltraps>

80106cf5 <vector58>:
.globl vector58
vector58:
  pushl $0
80106cf5:	6a 00                	push   $0x0
  pushl $58
80106cf7:	6a 3a                	push   $0x3a
  jmp alltraps
80106cf9:	e9 5b f7 ff ff       	jmp    80106459 <alltraps>

80106cfe <vector59>:
.globl vector59
vector59:
  pushl $0
80106cfe:	6a 00                	push   $0x0
  pushl $59
80106d00:	6a 3b                	push   $0x3b
  jmp alltraps
80106d02:	e9 52 f7 ff ff       	jmp    80106459 <alltraps>

80106d07 <vector60>:
.globl vector60
vector60:
  pushl $0
80106d07:	6a 00                	push   $0x0
  pushl $60
80106d09:	6a 3c                	push   $0x3c
  jmp alltraps
80106d0b:	e9 49 f7 ff ff       	jmp    80106459 <alltraps>

80106d10 <vector61>:
.globl vector61
vector61:
  pushl $0
80106d10:	6a 00                	push   $0x0
  pushl $61
80106d12:	6a 3d                	push   $0x3d
  jmp alltraps
80106d14:	e9 40 f7 ff ff       	jmp    80106459 <alltraps>

80106d19 <vector62>:
.globl vector62
vector62:
  pushl $0
80106d19:	6a 00                	push   $0x0
  pushl $62
80106d1b:	6a 3e                	push   $0x3e
  jmp alltraps
80106d1d:	e9 37 f7 ff ff       	jmp    80106459 <alltraps>

80106d22 <vector63>:
.globl vector63
vector63:
  pushl $0
80106d22:	6a 00                	push   $0x0
  pushl $63
80106d24:	6a 3f                	push   $0x3f
  jmp alltraps
80106d26:	e9 2e f7 ff ff       	jmp    80106459 <alltraps>

80106d2b <vector64>:
.globl vector64
vector64:
  pushl $0
80106d2b:	6a 00                	push   $0x0
  pushl $64
80106d2d:	6a 40                	push   $0x40
  jmp alltraps
80106d2f:	e9 25 f7 ff ff       	jmp    80106459 <alltraps>

80106d34 <vector65>:
.globl vector65
vector65:
  pushl $0
80106d34:	6a 00                	push   $0x0
  pushl $65
80106d36:	6a 41                	push   $0x41
  jmp alltraps
80106d38:	e9 1c f7 ff ff       	jmp    80106459 <alltraps>

80106d3d <vector66>:
.globl vector66
vector66:
  pushl $0
80106d3d:	6a 00                	push   $0x0
  pushl $66
80106d3f:	6a 42                	push   $0x42
  jmp alltraps
80106d41:	e9 13 f7 ff ff       	jmp    80106459 <alltraps>

80106d46 <vector67>:
.globl vector67
vector67:
  pushl $0
80106d46:	6a 00                	push   $0x0
  pushl $67
80106d48:	6a 43                	push   $0x43
  jmp alltraps
80106d4a:	e9 0a f7 ff ff       	jmp    80106459 <alltraps>

80106d4f <vector68>:
.globl vector68
vector68:
  pushl $0
80106d4f:	6a 00                	push   $0x0
  pushl $68
80106d51:	6a 44                	push   $0x44
  jmp alltraps
80106d53:	e9 01 f7 ff ff       	jmp    80106459 <alltraps>

80106d58 <vector69>:
.globl vector69
vector69:
  pushl $0
80106d58:	6a 00                	push   $0x0
  pushl $69
80106d5a:	6a 45                	push   $0x45
  jmp alltraps
80106d5c:	e9 f8 f6 ff ff       	jmp    80106459 <alltraps>

80106d61 <vector70>:
.globl vector70
vector70:
  pushl $0
80106d61:	6a 00                	push   $0x0
  pushl $70
80106d63:	6a 46                	push   $0x46
  jmp alltraps
80106d65:	e9 ef f6 ff ff       	jmp    80106459 <alltraps>

80106d6a <vector71>:
.globl vector71
vector71:
  pushl $0
80106d6a:	6a 00                	push   $0x0
  pushl $71
80106d6c:	6a 47                	push   $0x47
  jmp alltraps
80106d6e:	e9 e6 f6 ff ff       	jmp    80106459 <alltraps>

80106d73 <vector72>:
.globl vector72
vector72:
  pushl $0
80106d73:	6a 00                	push   $0x0
  pushl $72
80106d75:	6a 48                	push   $0x48
  jmp alltraps
80106d77:	e9 dd f6 ff ff       	jmp    80106459 <alltraps>

80106d7c <vector73>:
.globl vector73
vector73:
  pushl $0
80106d7c:	6a 00                	push   $0x0
  pushl $73
80106d7e:	6a 49                	push   $0x49
  jmp alltraps
80106d80:	e9 d4 f6 ff ff       	jmp    80106459 <alltraps>

80106d85 <vector74>:
.globl vector74
vector74:
  pushl $0
80106d85:	6a 00                	push   $0x0
  pushl $74
80106d87:	6a 4a                	push   $0x4a
  jmp alltraps
80106d89:	e9 cb f6 ff ff       	jmp    80106459 <alltraps>

80106d8e <vector75>:
.globl vector75
vector75:
  pushl $0
80106d8e:	6a 00                	push   $0x0
  pushl $75
80106d90:	6a 4b                	push   $0x4b
  jmp alltraps
80106d92:	e9 c2 f6 ff ff       	jmp    80106459 <alltraps>

80106d97 <vector76>:
.globl vector76
vector76:
  pushl $0
80106d97:	6a 00                	push   $0x0
  pushl $76
80106d99:	6a 4c                	push   $0x4c
  jmp alltraps
80106d9b:	e9 b9 f6 ff ff       	jmp    80106459 <alltraps>

80106da0 <vector77>:
.globl vector77
vector77:
  pushl $0
80106da0:	6a 00                	push   $0x0
  pushl $77
80106da2:	6a 4d                	push   $0x4d
  jmp alltraps
80106da4:	e9 b0 f6 ff ff       	jmp    80106459 <alltraps>

80106da9 <vector78>:
.globl vector78
vector78:
  pushl $0
80106da9:	6a 00                	push   $0x0
  pushl $78
80106dab:	6a 4e                	push   $0x4e
  jmp alltraps
80106dad:	e9 a7 f6 ff ff       	jmp    80106459 <alltraps>

80106db2 <vector79>:
.globl vector79
vector79:
  pushl $0
80106db2:	6a 00                	push   $0x0
  pushl $79
80106db4:	6a 4f                	push   $0x4f
  jmp alltraps
80106db6:	e9 9e f6 ff ff       	jmp    80106459 <alltraps>

80106dbb <vector80>:
.globl vector80
vector80:
  pushl $0
80106dbb:	6a 00                	push   $0x0
  pushl $80
80106dbd:	6a 50                	push   $0x50
  jmp alltraps
80106dbf:	e9 95 f6 ff ff       	jmp    80106459 <alltraps>

80106dc4 <vector81>:
.globl vector81
vector81:
  pushl $0
80106dc4:	6a 00                	push   $0x0
  pushl $81
80106dc6:	6a 51                	push   $0x51
  jmp alltraps
80106dc8:	e9 8c f6 ff ff       	jmp    80106459 <alltraps>

80106dcd <vector82>:
.globl vector82
vector82:
  pushl $0
80106dcd:	6a 00                	push   $0x0
  pushl $82
80106dcf:	6a 52                	push   $0x52
  jmp alltraps
80106dd1:	e9 83 f6 ff ff       	jmp    80106459 <alltraps>

80106dd6 <vector83>:
.globl vector83
vector83:
  pushl $0
80106dd6:	6a 00                	push   $0x0
  pushl $83
80106dd8:	6a 53                	push   $0x53
  jmp alltraps
80106dda:	e9 7a f6 ff ff       	jmp    80106459 <alltraps>

80106ddf <vector84>:
.globl vector84
vector84:
  pushl $0
80106ddf:	6a 00                	push   $0x0
  pushl $84
80106de1:	6a 54                	push   $0x54
  jmp alltraps
80106de3:	e9 71 f6 ff ff       	jmp    80106459 <alltraps>

80106de8 <vector85>:
.globl vector85
vector85:
  pushl $0
80106de8:	6a 00                	push   $0x0
  pushl $85
80106dea:	6a 55                	push   $0x55
  jmp alltraps
80106dec:	e9 68 f6 ff ff       	jmp    80106459 <alltraps>

80106df1 <vector86>:
.globl vector86
vector86:
  pushl $0
80106df1:	6a 00                	push   $0x0
  pushl $86
80106df3:	6a 56                	push   $0x56
  jmp alltraps
80106df5:	e9 5f f6 ff ff       	jmp    80106459 <alltraps>

80106dfa <vector87>:
.globl vector87
vector87:
  pushl $0
80106dfa:	6a 00                	push   $0x0
  pushl $87
80106dfc:	6a 57                	push   $0x57
  jmp alltraps
80106dfe:	e9 56 f6 ff ff       	jmp    80106459 <alltraps>

80106e03 <vector88>:
.globl vector88
vector88:
  pushl $0
80106e03:	6a 00                	push   $0x0
  pushl $88
80106e05:	6a 58                	push   $0x58
  jmp alltraps
80106e07:	e9 4d f6 ff ff       	jmp    80106459 <alltraps>

80106e0c <vector89>:
.globl vector89
vector89:
  pushl $0
80106e0c:	6a 00                	push   $0x0
  pushl $89
80106e0e:	6a 59                	push   $0x59
  jmp alltraps
80106e10:	e9 44 f6 ff ff       	jmp    80106459 <alltraps>

80106e15 <vector90>:
.globl vector90
vector90:
  pushl $0
80106e15:	6a 00                	push   $0x0
  pushl $90
80106e17:	6a 5a                	push   $0x5a
  jmp alltraps
80106e19:	e9 3b f6 ff ff       	jmp    80106459 <alltraps>

80106e1e <vector91>:
.globl vector91
vector91:
  pushl $0
80106e1e:	6a 00                	push   $0x0
  pushl $91
80106e20:	6a 5b                	push   $0x5b
  jmp alltraps
80106e22:	e9 32 f6 ff ff       	jmp    80106459 <alltraps>

80106e27 <vector92>:
.globl vector92
vector92:
  pushl $0
80106e27:	6a 00                	push   $0x0
  pushl $92
80106e29:	6a 5c                	push   $0x5c
  jmp alltraps
80106e2b:	e9 29 f6 ff ff       	jmp    80106459 <alltraps>

80106e30 <vector93>:
.globl vector93
vector93:
  pushl $0
80106e30:	6a 00                	push   $0x0
  pushl $93
80106e32:	6a 5d                	push   $0x5d
  jmp alltraps
80106e34:	e9 20 f6 ff ff       	jmp    80106459 <alltraps>

80106e39 <vector94>:
.globl vector94
vector94:
  pushl $0
80106e39:	6a 00                	push   $0x0
  pushl $94
80106e3b:	6a 5e                	push   $0x5e
  jmp alltraps
80106e3d:	e9 17 f6 ff ff       	jmp    80106459 <alltraps>

80106e42 <vector95>:
.globl vector95
vector95:
  pushl $0
80106e42:	6a 00                	push   $0x0
  pushl $95
80106e44:	6a 5f                	push   $0x5f
  jmp alltraps
80106e46:	e9 0e f6 ff ff       	jmp    80106459 <alltraps>

80106e4b <vector96>:
.globl vector96
vector96:
  pushl $0
80106e4b:	6a 00                	push   $0x0
  pushl $96
80106e4d:	6a 60                	push   $0x60
  jmp alltraps
80106e4f:	e9 05 f6 ff ff       	jmp    80106459 <alltraps>

80106e54 <vector97>:
.globl vector97
vector97:
  pushl $0
80106e54:	6a 00                	push   $0x0
  pushl $97
80106e56:	6a 61                	push   $0x61
  jmp alltraps
80106e58:	e9 fc f5 ff ff       	jmp    80106459 <alltraps>

80106e5d <vector98>:
.globl vector98
vector98:
  pushl $0
80106e5d:	6a 00                	push   $0x0
  pushl $98
80106e5f:	6a 62                	push   $0x62
  jmp alltraps
80106e61:	e9 f3 f5 ff ff       	jmp    80106459 <alltraps>

80106e66 <vector99>:
.globl vector99
vector99:
  pushl $0
80106e66:	6a 00                	push   $0x0
  pushl $99
80106e68:	6a 63                	push   $0x63
  jmp alltraps
80106e6a:	e9 ea f5 ff ff       	jmp    80106459 <alltraps>

80106e6f <vector100>:
.globl vector100
vector100:
  pushl $0
80106e6f:	6a 00                	push   $0x0
  pushl $100
80106e71:	6a 64                	push   $0x64
  jmp alltraps
80106e73:	e9 e1 f5 ff ff       	jmp    80106459 <alltraps>

80106e78 <vector101>:
.globl vector101
vector101:
  pushl $0
80106e78:	6a 00                	push   $0x0
  pushl $101
80106e7a:	6a 65                	push   $0x65
  jmp alltraps
80106e7c:	e9 d8 f5 ff ff       	jmp    80106459 <alltraps>

80106e81 <vector102>:
.globl vector102
vector102:
  pushl $0
80106e81:	6a 00                	push   $0x0
  pushl $102
80106e83:	6a 66                	push   $0x66
  jmp alltraps
80106e85:	e9 cf f5 ff ff       	jmp    80106459 <alltraps>

80106e8a <vector103>:
.globl vector103
vector103:
  pushl $0
80106e8a:	6a 00                	push   $0x0
  pushl $103
80106e8c:	6a 67                	push   $0x67
  jmp alltraps
80106e8e:	e9 c6 f5 ff ff       	jmp    80106459 <alltraps>

80106e93 <vector104>:
.globl vector104
vector104:
  pushl $0
80106e93:	6a 00                	push   $0x0
  pushl $104
80106e95:	6a 68                	push   $0x68
  jmp alltraps
80106e97:	e9 bd f5 ff ff       	jmp    80106459 <alltraps>

80106e9c <vector105>:
.globl vector105
vector105:
  pushl $0
80106e9c:	6a 00                	push   $0x0
  pushl $105
80106e9e:	6a 69                	push   $0x69
  jmp alltraps
80106ea0:	e9 b4 f5 ff ff       	jmp    80106459 <alltraps>

80106ea5 <vector106>:
.globl vector106
vector106:
  pushl $0
80106ea5:	6a 00                	push   $0x0
  pushl $106
80106ea7:	6a 6a                	push   $0x6a
  jmp alltraps
80106ea9:	e9 ab f5 ff ff       	jmp    80106459 <alltraps>

80106eae <vector107>:
.globl vector107
vector107:
  pushl $0
80106eae:	6a 00                	push   $0x0
  pushl $107
80106eb0:	6a 6b                	push   $0x6b
  jmp alltraps
80106eb2:	e9 a2 f5 ff ff       	jmp    80106459 <alltraps>

80106eb7 <vector108>:
.globl vector108
vector108:
  pushl $0
80106eb7:	6a 00                	push   $0x0
  pushl $108
80106eb9:	6a 6c                	push   $0x6c
  jmp alltraps
80106ebb:	e9 99 f5 ff ff       	jmp    80106459 <alltraps>

80106ec0 <vector109>:
.globl vector109
vector109:
  pushl $0
80106ec0:	6a 00                	push   $0x0
  pushl $109
80106ec2:	6a 6d                	push   $0x6d
  jmp alltraps
80106ec4:	e9 90 f5 ff ff       	jmp    80106459 <alltraps>

80106ec9 <vector110>:
.globl vector110
vector110:
  pushl $0
80106ec9:	6a 00                	push   $0x0
  pushl $110
80106ecb:	6a 6e                	push   $0x6e
  jmp alltraps
80106ecd:	e9 87 f5 ff ff       	jmp    80106459 <alltraps>

80106ed2 <vector111>:
.globl vector111
vector111:
  pushl $0
80106ed2:	6a 00                	push   $0x0
  pushl $111
80106ed4:	6a 6f                	push   $0x6f
  jmp alltraps
80106ed6:	e9 7e f5 ff ff       	jmp    80106459 <alltraps>

80106edb <vector112>:
.globl vector112
vector112:
  pushl $0
80106edb:	6a 00                	push   $0x0
  pushl $112
80106edd:	6a 70                	push   $0x70
  jmp alltraps
80106edf:	e9 75 f5 ff ff       	jmp    80106459 <alltraps>

80106ee4 <vector113>:
.globl vector113
vector113:
  pushl $0
80106ee4:	6a 00                	push   $0x0
  pushl $113
80106ee6:	6a 71                	push   $0x71
  jmp alltraps
80106ee8:	e9 6c f5 ff ff       	jmp    80106459 <alltraps>

80106eed <vector114>:
.globl vector114
vector114:
  pushl $0
80106eed:	6a 00                	push   $0x0
  pushl $114
80106eef:	6a 72                	push   $0x72
  jmp alltraps
80106ef1:	e9 63 f5 ff ff       	jmp    80106459 <alltraps>

80106ef6 <vector115>:
.globl vector115
vector115:
  pushl $0
80106ef6:	6a 00                	push   $0x0
  pushl $115
80106ef8:	6a 73                	push   $0x73
  jmp alltraps
80106efa:	e9 5a f5 ff ff       	jmp    80106459 <alltraps>

80106eff <vector116>:
.globl vector116
vector116:
  pushl $0
80106eff:	6a 00                	push   $0x0
  pushl $116
80106f01:	6a 74                	push   $0x74
  jmp alltraps
80106f03:	e9 51 f5 ff ff       	jmp    80106459 <alltraps>

80106f08 <vector117>:
.globl vector117
vector117:
  pushl $0
80106f08:	6a 00                	push   $0x0
  pushl $117
80106f0a:	6a 75                	push   $0x75
  jmp alltraps
80106f0c:	e9 48 f5 ff ff       	jmp    80106459 <alltraps>

80106f11 <vector118>:
.globl vector118
vector118:
  pushl $0
80106f11:	6a 00                	push   $0x0
  pushl $118
80106f13:	6a 76                	push   $0x76
  jmp alltraps
80106f15:	e9 3f f5 ff ff       	jmp    80106459 <alltraps>

80106f1a <vector119>:
.globl vector119
vector119:
  pushl $0
80106f1a:	6a 00                	push   $0x0
  pushl $119
80106f1c:	6a 77                	push   $0x77
  jmp alltraps
80106f1e:	e9 36 f5 ff ff       	jmp    80106459 <alltraps>

80106f23 <vector120>:
.globl vector120
vector120:
  pushl $0
80106f23:	6a 00                	push   $0x0
  pushl $120
80106f25:	6a 78                	push   $0x78
  jmp alltraps
80106f27:	e9 2d f5 ff ff       	jmp    80106459 <alltraps>

80106f2c <vector121>:
.globl vector121
vector121:
  pushl $0
80106f2c:	6a 00                	push   $0x0
  pushl $121
80106f2e:	6a 79                	push   $0x79
  jmp alltraps
80106f30:	e9 24 f5 ff ff       	jmp    80106459 <alltraps>

80106f35 <vector122>:
.globl vector122
vector122:
  pushl $0
80106f35:	6a 00                	push   $0x0
  pushl $122
80106f37:	6a 7a                	push   $0x7a
  jmp alltraps
80106f39:	e9 1b f5 ff ff       	jmp    80106459 <alltraps>

80106f3e <vector123>:
.globl vector123
vector123:
  pushl $0
80106f3e:	6a 00                	push   $0x0
  pushl $123
80106f40:	6a 7b                	push   $0x7b
  jmp alltraps
80106f42:	e9 12 f5 ff ff       	jmp    80106459 <alltraps>

80106f47 <vector124>:
.globl vector124
vector124:
  pushl $0
80106f47:	6a 00                	push   $0x0
  pushl $124
80106f49:	6a 7c                	push   $0x7c
  jmp alltraps
80106f4b:	e9 09 f5 ff ff       	jmp    80106459 <alltraps>

80106f50 <vector125>:
.globl vector125
vector125:
  pushl $0
80106f50:	6a 00                	push   $0x0
  pushl $125
80106f52:	6a 7d                	push   $0x7d
  jmp alltraps
80106f54:	e9 00 f5 ff ff       	jmp    80106459 <alltraps>

80106f59 <vector126>:
.globl vector126
vector126:
  pushl $0
80106f59:	6a 00                	push   $0x0
  pushl $126
80106f5b:	6a 7e                	push   $0x7e
  jmp alltraps
80106f5d:	e9 f7 f4 ff ff       	jmp    80106459 <alltraps>

80106f62 <vector127>:
.globl vector127
vector127:
  pushl $0
80106f62:	6a 00                	push   $0x0
  pushl $127
80106f64:	6a 7f                	push   $0x7f
  jmp alltraps
80106f66:	e9 ee f4 ff ff       	jmp    80106459 <alltraps>

80106f6b <vector128>:
.globl vector128
vector128:
  pushl $0
80106f6b:	6a 00                	push   $0x0
  pushl $128
80106f6d:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106f72:	e9 e2 f4 ff ff       	jmp    80106459 <alltraps>

80106f77 <vector129>:
.globl vector129
vector129:
  pushl $0
80106f77:	6a 00                	push   $0x0
  pushl $129
80106f79:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106f7e:	e9 d6 f4 ff ff       	jmp    80106459 <alltraps>

80106f83 <vector130>:
.globl vector130
vector130:
  pushl $0
80106f83:	6a 00                	push   $0x0
  pushl $130
80106f85:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106f8a:	e9 ca f4 ff ff       	jmp    80106459 <alltraps>

80106f8f <vector131>:
.globl vector131
vector131:
  pushl $0
80106f8f:	6a 00                	push   $0x0
  pushl $131
80106f91:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106f96:	e9 be f4 ff ff       	jmp    80106459 <alltraps>

80106f9b <vector132>:
.globl vector132
vector132:
  pushl $0
80106f9b:	6a 00                	push   $0x0
  pushl $132
80106f9d:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106fa2:	e9 b2 f4 ff ff       	jmp    80106459 <alltraps>

80106fa7 <vector133>:
.globl vector133
vector133:
  pushl $0
80106fa7:	6a 00                	push   $0x0
  pushl $133
80106fa9:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106fae:	e9 a6 f4 ff ff       	jmp    80106459 <alltraps>

80106fb3 <vector134>:
.globl vector134
vector134:
  pushl $0
80106fb3:	6a 00                	push   $0x0
  pushl $134
80106fb5:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106fba:	e9 9a f4 ff ff       	jmp    80106459 <alltraps>

80106fbf <vector135>:
.globl vector135
vector135:
  pushl $0
80106fbf:	6a 00                	push   $0x0
  pushl $135
80106fc1:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106fc6:	e9 8e f4 ff ff       	jmp    80106459 <alltraps>

80106fcb <vector136>:
.globl vector136
vector136:
  pushl $0
80106fcb:	6a 00                	push   $0x0
  pushl $136
80106fcd:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106fd2:	e9 82 f4 ff ff       	jmp    80106459 <alltraps>

80106fd7 <vector137>:
.globl vector137
vector137:
  pushl $0
80106fd7:	6a 00                	push   $0x0
  pushl $137
80106fd9:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106fde:	e9 76 f4 ff ff       	jmp    80106459 <alltraps>

80106fe3 <vector138>:
.globl vector138
vector138:
  pushl $0
80106fe3:	6a 00                	push   $0x0
  pushl $138
80106fe5:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106fea:	e9 6a f4 ff ff       	jmp    80106459 <alltraps>

80106fef <vector139>:
.globl vector139
vector139:
  pushl $0
80106fef:	6a 00                	push   $0x0
  pushl $139
80106ff1:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106ff6:	e9 5e f4 ff ff       	jmp    80106459 <alltraps>

80106ffb <vector140>:
.globl vector140
vector140:
  pushl $0
80106ffb:	6a 00                	push   $0x0
  pushl $140
80106ffd:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107002:	e9 52 f4 ff ff       	jmp    80106459 <alltraps>

80107007 <vector141>:
.globl vector141
vector141:
  pushl $0
80107007:	6a 00                	push   $0x0
  pushl $141
80107009:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010700e:	e9 46 f4 ff ff       	jmp    80106459 <alltraps>

80107013 <vector142>:
.globl vector142
vector142:
  pushl $0
80107013:	6a 00                	push   $0x0
  pushl $142
80107015:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010701a:	e9 3a f4 ff ff       	jmp    80106459 <alltraps>

8010701f <vector143>:
.globl vector143
vector143:
  pushl $0
8010701f:	6a 00                	push   $0x0
  pushl $143
80107021:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107026:	e9 2e f4 ff ff       	jmp    80106459 <alltraps>

8010702b <vector144>:
.globl vector144
vector144:
  pushl $0
8010702b:	6a 00                	push   $0x0
  pushl $144
8010702d:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107032:	e9 22 f4 ff ff       	jmp    80106459 <alltraps>

80107037 <vector145>:
.globl vector145
vector145:
  pushl $0
80107037:	6a 00                	push   $0x0
  pushl $145
80107039:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010703e:	e9 16 f4 ff ff       	jmp    80106459 <alltraps>

80107043 <vector146>:
.globl vector146
vector146:
  pushl $0
80107043:	6a 00                	push   $0x0
  pushl $146
80107045:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010704a:	e9 0a f4 ff ff       	jmp    80106459 <alltraps>

8010704f <vector147>:
.globl vector147
vector147:
  pushl $0
8010704f:	6a 00                	push   $0x0
  pushl $147
80107051:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107056:	e9 fe f3 ff ff       	jmp    80106459 <alltraps>

8010705b <vector148>:
.globl vector148
vector148:
  pushl $0
8010705b:	6a 00                	push   $0x0
  pushl $148
8010705d:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107062:	e9 f2 f3 ff ff       	jmp    80106459 <alltraps>

80107067 <vector149>:
.globl vector149
vector149:
  pushl $0
80107067:	6a 00                	push   $0x0
  pushl $149
80107069:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010706e:	e9 e6 f3 ff ff       	jmp    80106459 <alltraps>

80107073 <vector150>:
.globl vector150
vector150:
  pushl $0
80107073:	6a 00                	push   $0x0
  pushl $150
80107075:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010707a:	e9 da f3 ff ff       	jmp    80106459 <alltraps>

8010707f <vector151>:
.globl vector151
vector151:
  pushl $0
8010707f:	6a 00                	push   $0x0
  pushl $151
80107081:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107086:	e9 ce f3 ff ff       	jmp    80106459 <alltraps>

8010708b <vector152>:
.globl vector152
vector152:
  pushl $0
8010708b:	6a 00                	push   $0x0
  pushl $152
8010708d:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107092:	e9 c2 f3 ff ff       	jmp    80106459 <alltraps>

80107097 <vector153>:
.globl vector153
vector153:
  pushl $0
80107097:	6a 00                	push   $0x0
  pushl $153
80107099:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010709e:	e9 b6 f3 ff ff       	jmp    80106459 <alltraps>

801070a3 <vector154>:
.globl vector154
vector154:
  pushl $0
801070a3:	6a 00                	push   $0x0
  pushl $154
801070a5:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801070aa:	e9 aa f3 ff ff       	jmp    80106459 <alltraps>

801070af <vector155>:
.globl vector155
vector155:
  pushl $0
801070af:	6a 00                	push   $0x0
  pushl $155
801070b1:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801070b6:	e9 9e f3 ff ff       	jmp    80106459 <alltraps>

801070bb <vector156>:
.globl vector156
vector156:
  pushl $0
801070bb:	6a 00                	push   $0x0
  pushl $156
801070bd:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801070c2:	e9 92 f3 ff ff       	jmp    80106459 <alltraps>

801070c7 <vector157>:
.globl vector157
vector157:
  pushl $0
801070c7:	6a 00                	push   $0x0
  pushl $157
801070c9:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801070ce:	e9 86 f3 ff ff       	jmp    80106459 <alltraps>

801070d3 <vector158>:
.globl vector158
vector158:
  pushl $0
801070d3:	6a 00                	push   $0x0
  pushl $158
801070d5:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801070da:	e9 7a f3 ff ff       	jmp    80106459 <alltraps>

801070df <vector159>:
.globl vector159
vector159:
  pushl $0
801070df:	6a 00                	push   $0x0
  pushl $159
801070e1:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801070e6:	e9 6e f3 ff ff       	jmp    80106459 <alltraps>

801070eb <vector160>:
.globl vector160
vector160:
  pushl $0
801070eb:	6a 00                	push   $0x0
  pushl $160
801070ed:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801070f2:	e9 62 f3 ff ff       	jmp    80106459 <alltraps>

801070f7 <vector161>:
.globl vector161
vector161:
  pushl $0
801070f7:	6a 00                	push   $0x0
  pushl $161
801070f9:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801070fe:	e9 56 f3 ff ff       	jmp    80106459 <alltraps>

80107103 <vector162>:
.globl vector162
vector162:
  pushl $0
80107103:	6a 00                	push   $0x0
  pushl $162
80107105:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010710a:	e9 4a f3 ff ff       	jmp    80106459 <alltraps>

8010710f <vector163>:
.globl vector163
vector163:
  pushl $0
8010710f:	6a 00                	push   $0x0
  pushl $163
80107111:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107116:	e9 3e f3 ff ff       	jmp    80106459 <alltraps>

8010711b <vector164>:
.globl vector164
vector164:
  pushl $0
8010711b:	6a 00                	push   $0x0
  pushl $164
8010711d:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107122:	e9 32 f3 ff ff       	jmp    80106459 <alltraps>

80107127 <vector165>:
.globl vector165
vector165:
  pushl $0
80107127:	6a 00                	push   $0x0
  pushl $165
80107129:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010712e:	e9 26 f3 ff ff       	jmp    80106459 <alltraps>

80107133 <vector166>:
.globl vector166
vector166:
  pushl $0
80107133:	6a 00                	push   $0x0
  pushl $166
80107135:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010713a:	e9 1a f3 ff ff       	jmp    80106459 <alltraps>

8010713f <vector167>:
.globl vector167
vector167:
  pushl $0
8010713f:	6a 00                	push   $0x0
  pushl $167
80107141:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107146:	e9 0e f3 ff ff       	jmp    80106459 <alltraps>

8010714b <vector168>:
.globl vector168
vector168:
  pushl $0
8010714b:	6a 00                	push   $0x0
  pushl $168
8010714d:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107152:	e9 02 f3 ff ff       	jmp    80106459 <alltraps>

80107157 <vector169>:
.globl vector169
vector169:
  pushl $0
80107157:	6a 00                	push   $0x0
  pushl $169
80107159:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010715e:	e9 f6 f2 ff ff       	jmp    80106459 <alltraps>

80107163 <vector170>:
.globl vector170
vector170:
  pushl $0
80107163:	6a 00                	push   $0x0
  pushl $170
80107165:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010716a:	e9 ea f2 ff ff       	jmp    80106459 <alltraps>

8010716f <vector171>:
.globl vector171
vector171:
  pushl $0
8010716f:	6a 00                	push   $0x0
  pushl $171
80107171:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107176:	e9 de f2 ff ff       	jmp    80106459 <alltraps>

8010717b <vector172>:
.globl vector172
vector172:
  pushl $0
8010717b:	6a 00                	push   $0x0
  pushl $172
8010717d:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107182:	e9 d2 f2 ff ff       	jmp    80106459 <alltraps>

80107187 <vector173>:
.globl vector173
vector173:
  pushl $0
80107187:	6a 00                	push   $0x0
  pushl $173
80107189:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010718e:	e9 c6 f2 ff ff       	jmp    80106459 <alltraps>

80107193 <vector174>:
.globl vector174
vector174:
  pushl $0
80107193:	6a 00                	push   $0x0
  pushl $174
80107195:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010719a:	e9 ba f2 ff ff       	jmp    80106459 <alltraps>

8010719f <vector175>:
.globl vector175
vector175:
  pushl $0
8010719f:	6a 00                	push   $0x0
  pushl $175
801071a1:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801071a6:	e9 ae f2 ff ff       	jmp    80106459 <alltraps>

801071ab <vector176>:
.globl vector176
vector176:
  pushl $0
801071ab:	6a 00                	push   $0x0
  pushl $176
801071ad:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801071b2:	e9 a2 f2 ff ff       	jmp    80106459 <alltraps>

801071b7 <vector177>:
.globl vector177
vector177:
  pushl $0
801071b7:	6a 00                	push   $0x0
  pushl $177
801071b9:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801071be:	e9 96 f2 ff ff       	jmp    80106459 <alltraps>

801071c3 <vector178>:
.globl vector178
vector178:
  pushl $0
801071c3:	6a 00                	push   $0x0
  pushl $178
801071c5:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801071ca:	e9 8a f2 ff ff       	jmp    80106459 <alltraps>

801071cf <vector179>:
.globl vector179
vector179:
  pushl $0
801071cf:	6a 00                	push   $0x0
  pushl $179
801071d1:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801071d6:	e9 7e f2 ff ff       	jmp    80106459 <alltraps>

801071db <vector180>:
.globl vector180
vector180:
  pushl $0
801071db:	6a 00                	push   $0x0
  pushl $180
801071dd:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801071e2:	e9 72 f2 ff ff       	jmp    80106459 <alltraps>

801071e7 <vector181>:
.globl vector181
vector181:
  pushl $0
801071e7:	6a 00                	push   $0x0
  pushl $181
801071e9:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801071ee:	e9 66 f2 ff ff       	jmp    80106459 <alltraps>

801071f3 <vector182>:
.globl vector182
vector182:
  pushl $0
801071f3:	6a 00                	push   $0x0
  pushl $182
801071f5:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801071fa:	e9 5a f2 ff ff       	jmp    80106459 <alltraps>

801071ff <vector183>:
.globl vector183
vector183:
  pushl $0
801071ff:	6a 00                	push   $0x0
  pushl $183
80107201:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107206:	e9 4e f2 ff ff       	jmp    80106459 <alltraps>

8010720b <vector184>:
.globl vector184
vector184:
  pushl $0
8010720b:	6a 00                	push   $0x0
  pushl $184
8010720d:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107212:	e9 42 f2 ff ff       	jmp    80106459 <alltraps>

80107217 <vector185>:
.globl vector185
vector185:
  pushl $0
80107217:	6a 00                	push   $0x0
  pushl $185
80107219:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010721e:	e9 36 f2 ff ff       	jmp    80106459 <alltraps>

80107223 <vector186>:
.globl vector186
vector186:
  pushl $0
80107223:	6a 00                	push   $0x0
  pushl $186
80107225:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010722a:	e9 2a f2 ff ff       	jmp    80106459 <alltraps>

8010722f <vector187>:
.globl vector187
vector187:
  pushl $0
8010722f:	6a 00                	push   $0x0
  pushl $187
80107231:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107236:	e9 1e f2 ff ff       	jmp    80106459 <alltraps>

8010723b <vector188>:
.globl vector188
vector188:
  pushl $0
8010723b:	6a 00                	push   $0x0
  pushl $188
8010723d:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107242:	e9 12 f2 ff ff       	jmp    80106459 <alltraps>

80107247 <vector189>:
.globl vector189
vector189:
  pushl $0
80107247:	6a 00                	push   $0x0
  pushl $189
80107249:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010724e:	e9 06 f2 ff ff       	jmp    80106459 <alltraps>

80107253 <vector190>:
.globl vector190
vector190:
  pushl $0
80107253:	6a 00                	push   $0x0
  pushl $190
80107255:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010725a:	e9 fa f1 ff ff       	jmp    80106459 <alltraps>

8010725f <vector191>:
.globl vector191
vector191:
  pushl $0
8010725f:	6a 00                	push   $0x0
  pushl $191
80107261:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107266:	e9 ee f1 ff ff       	jmp    80106459 <alltraps>

8010726b <vector192>:
.globl vector192
vector192:
  pushl $0
8010726b:	6a 00                	push   $0x0
  pushl $192
8010726d:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107272:	e9 e2 f1 ff ff       	jmp    80106459 <alltraps>

80107277 <vector193>:
.globl vector193
vector193:
  pushl $0
80107277:	6a 00                	push   $0x0
  pushl $193
80107279:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010727e:	e9 d6 f1 ff ff       	jmp    80106459 <alltraps>

80107283 <vector194>:
.globl vector194
vector194:
  pushl $0
80107283:	6a 00                	push   $0x0
  pushl $194
80107285:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010728a:	e9 ca f1 ff ff       	jmp    80106459 <alltraps>

8010728f <vector195>:
.globl vector195
vector195:
  pushl $0
8010728f:	6a 00                	push   $0x0
  pushl $195
80107291:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107296:	e9 be f1 ff ff       	jmp    80106459 <alltraps>

8010729b <vector196>:
.globl vector196
vector196:
  pushl $0
8010729b:	6a 00                	push   $0x0
  pushl $196
8010729d:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801072a2:	e9 b2 f1 ff ff       	jmp    80106459 <alltraps>

801072a7 <vector197>:
.globl vector197
vector197:
  pushl $0
801072a7:	6a 00                	push   $0x0
  pushl $197
801072a9:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801072ae:	e9 a6 f1 ff ff       	jmp    80106459 <alltraps>

801072b3 <vector198>:
.globl vector198
vector198:
  pushl $0
801072b3:	6a 00                	push   $0x0
  pushl $198
801072b5:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801072ba:	e9 9a f1 ff ff       	jmp    80106459 <alltraps>

801072bf <vector199>:
.globl vector199
vector199:
  pushl $0
801072bf:	6a 00                	push   $0x0
  pushl $199
801072c1:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801072c6:	e9 8e f1 ff ff       	jmp    80106459 <alltraps>

801072cb <vector200>:
.globl vector200
vector200:
  pushl $0
801072cb:	6a 00                	push   $0x0
  pushl $200
801072cd:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801072d2:	e9 82 f1 ff ff       	jmp    80106459 <alltraps>

801072d7 <vector201>:
.globl vector201
vector201:
  pushl $0
801072d7:	6a 00                	push   $0x0
  pushl $201
801072d9:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801072de:	e9 76 f1 ff ff       	jmp    80106459 <alltraps>

801072e3 <vector202>:
.globl vector202
vector202:
  pushl $0
801072e3:	6a 00                	push   $0x0
  pushl $202
801072e5:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801072ea:	e9 6a f1 ff ff       	jmp    80106459 <alltraps>

801072ef <vector203>:
.globl vector203
vector203:
  pushl $0
801072ef:	6a 00                	push   $0x0
  pushl $203
801072f1:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801072f6:	e9 5e f1 ff ff       	jmp    80106459 <alltraps>

801072fb <vector204>:
.globl vector204
vector204:
  pushl $0
801072fb:	6a 00                	push   $0x0
  pushl $204
801072fd:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107302:	e9 52 f1 ff ff       	jmp    80106459 <alltraps>

80107307 <vector205>:
.globl vector205
vector205:
  pushl $0
80107307:	6a 00                	push   $0x0
  pushl $205
80107309:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010730e:	e9 46 f1 ff ff       	jmp    80106459 <alltraps>

80107313 <vector206>:
.globl vector206
vector206:
  pushl $0
80107313:	6a 00                	push   $0x0
  pushl $206
80107315:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010731a:	e9 3a f1 ff ff       	jmp    80106459 <alltraps>

8010731f <vector207>:
.globl vector207
vector207:
  pushl $0
8010731f:	6a 00                	push   $0x0
  pushl $207
80107321:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107326:	e9 2e f1 ff ff       	jmp    80106459 <alltraps>

8010732b <vector208>:
.globl vector208
vector208:
  pushl $0
8010732b:	6a 00                	push   $0x0
  pushl $208
8010732d:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107332:	e9 22 f1 ff ff       	jmp    80106459 <alltraps>

80107337 <vector209>:
.globl vector209
vector209:
  pushl $0
80107337:	6a 00                	push   $0x0
  pushl $209
80107339:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010733e:	e9 16 f1 ff ff       	jmp    80106459 <alltraps>

80107343 <vector210>:
.globl vector210
vector210:
  pushl $0
80107343:	6a 00                	push   $0x0
  pushl $210
80107345:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010734a:	e9 0a f1 ff ff       	jmp    80106459 <alltraps>

8010734f <vector211>:
.globl vector211
vector211:
  pushl $0
8010734f:	6a 00                	push   $0x0
  pushl $211
80107351:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107356:	e9 fe f0 ff ff       	jmp    80106459 <alltraps>

8010735b <vector212>:
.globl vector212
vector212:
  pushl $0
8010735b:	6a 00                	push   $0x0
  pushl $212
8010735d:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107362:	e9 f2 f0 ff ff       	jmp    80106459 <alltraps>

80107367 <vector213>:
.globl vector213
vector213:
  pushl $0
80107367:	6a 00                	push   $0x0
  pushl $213
80107369:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010736e:	e9 e6 f0 ff ff       	jmp    80106459 <alltraps>

80107373 <vector214>:
.globl vector214
vector214:
  pushl $0
80107373:	6a 00                	push   $0x0
  pushl $214
80107375:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010737a:	e9 da f0 ff ff       	jmp    80106459 <alltraps>

8010737f <vector215>:
.globl vector215
vector215:
  pushl $0
8010737f:	6a 00                	push   $0x0
  pushl $215
80107381:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107386:	e9 ce f0 ff ff       	jmp    80106459 <alltraps>

8010738b <vector216>:
.globl vector216
vector216:
  pushl $0
8010738b:	6a 00                	push   $0x0
  pushl $216
8010738d:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107392:	e9 c2 f0 ff ff       	jmp    80106459 <alltraps>

80107397 <vector217>:
.globl vector217
vector217:
  pushl $0
80107397:	6a 00                	push   $0x0
  pushl $217
80107399:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010739e:	e9 b6 f0 ff ff       	jmp    80106459 <alltraps>

801073a3 <vector218>:
.globl vector218
vector218:
  pushl $0
801073a3:	6a 00                	push   $0x0
  pushl $218
801073a5:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801073aa:	e9 aa f0 ff ff       	jmp    80106459 <alltraps>

801073af <vector219>:
.globl vector219
vector219:
  pushl $0
801073af:	6a 00                	push   $0x0
  pushl $219
801073b1:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801073b6:	e9 9e f0 ff ff       	jmp    80106459 <alltraps>

801073bb <vector220>:
.globl vector220
vector220:
  pushl $0
801073bb:	6a 00                	push   $0x0
  pushl $220
801073bd:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801073c2:	e9 92 f0 ff ff       	jmp    80106459 <alltraps>

801073c7 <vector221>:
.globl vector221
vector221:
  pushl $0
801073c7:	6a 00                	push   $0x0
  pushl $221
801073c9:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801073ce:	e9 86 f0 ff ff       	jmp    80106459 <alltraps>

801073d3 <vector222>:
.globl vector222
vector222:
  pushl $0
801073d3:	6a 00                	push   $0x0
  pushl $222
801073d5:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801073da:	e9 7a f0 ff ff       	jmp    80106459 <alltraps>

801073df <vector223>:
.globl vector223
vector223:
  pushl $0
801073df:	6a 00                	push   $0x0
  pushl $223
801073e1:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801073e6:	e9 6e f0 ff ff       	jmp    80106459 <alltraps>

801073eb <vector224>:
.globl vector224
vector224:
  pushl $0
801073eb:	6a 00                	push   $0x0
  pushl $224
801073ed:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801073f2:	e9 62 f0 ff ff       	jmp    80106459 <alltraps>

801073f7 <vector225>:
.globl vector225
vector225:
  pushl $0
801073f7:	6a 00                	push   $0x0
  pushl $225
801073f9:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801073fe:	e9 56 f0 ff ff       	jmp    80106459 <alltraps>

80107403 <vector226>:
.globl vector226
vector226:
  pushl $0
80107403:	6a 00                	push   $0x0
  pushl $226
80107405:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010740a:	e9 4a f0 ff ff       	jmp    80106459 <alltraps>

8010740f <vector227>:
.globl vector227
vector227:
  pushl $0
8010740f:	6a 00                	push   $0x0
  pushl $227
80107411:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107416:	e9 3e f0 ff ff       	jmp    80106459 <alltraps>

8010741b <vector228>:
.globl vector228
vector228:
  pushl $0
8010741b:	6a 00                	push   $0x0
  pushl $228
8010741d:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107422:	e9 32 f0 ff ff       	jmp    80106459 <alltraps>

80107427 <vector229>:
.globl vector229
vector229:
  pushl $0
80107427:	6a 00                	push   $0x0
  pushl $229
80107429:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010742e:	e9 26 f0 ff ff       	jmp    80106459 <alltraps>

80107433 <vector230>:
.globl vector230
vector230:
  pushl $0
80107433:	6a 00                	push   $0x0
  pushl $230
80107435:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010743a:	e9 1a f0 ff ff       	jmp    80106459 <alltraps>

8010743f <vector231>:
.globl vector231
vector231:
  pushl $0
8010743f:	6a 00                	push   $0x0
  pushl $231
80107441:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107446:	e9 0e f0 ff ff       	jmp    80106459 <alltraps>

8010744b <vector232>:
.globl vector232
vector232:
  pushl $0
8010744b:	6a 00                	push   $0x0
  pushl $232
8010744d:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107452:	e9 02 f0 ff ff       	jmp    80106459 <alltraps>

80107457 <vector233>:
.globl vector233
vector233:
  pushl $0
80107457:	6a 00                	push   $0x0
  pushl $233
80107459:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010745e:	e9 f6 ef ff ff       	jmp    80106459 <alltraps>

80107463 <vector234>:
.globl vector234
vector234:
  pushl $0
80107463:	6a 00                	push   $0x0
  pushl $234
80107465:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010746a:	e9 ea ef ff ff       	jmp    80106459 <alltraps>

8010746f <vector235>:
.globl vector235
vector235:
  pushl $0
8010746f:	6a 00                	push   $0x0
  pushl $235
80107471:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107476:	e9 de ef ff ff       	jmp    80106459 <alltraps>

8010747b <vector236>:
.globl vector236
vector236:
  pushl $0
8010747b:	6a 00                	push   $0x0
  pushl $236
8010747d:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107482:	e9 d2 ef ff ff       	jmp    80106459 <alltraps>

80107487 <vector237>:
.globl vector237
vector237:
  pushl $0
80107487:	6a 00                	push   $0x0
  pushl $237
80107489:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010748e:	e9 c6 ef ff ff       	jmp    80106459 <alltraps>

80107493 <vector238>:
.globl vector238
vector238:
  pushl $0
80107493:	6a 00                	push   $0x0
  pushl $238
80107495:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010749a:	e9 ba ef ff ff       	jmp    80106459 <alltraps>

8010749f <vector239>:
.globl vector239
vector239:
  pushl $0
8010749f:	6a 00                	push   $0x0
  pushl $239
801074a1:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801074a6:	e9 ae ef ff ff       	jmp    80106459 <alltraps>

801074ab <vector240>:
.globl vector240
vector240:
  pushl $0
801074ab:	6a 00                	push   $0x0
  pushl $240
801074ad:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801074b2:	e9 a2 ef ff ff       	jmp    80106459 <alltraps>

801074b7 <vector241>:
.globl vector241
vector241:
  pushl $0
801074b7:	6a 00                	push   $0x0
  pushl $241
801074b9:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801074be:	e9 96 ef ff ff       	jmp    80106459 <alltraps>

801074c3 <vector242>:
.globl vector242
vector242:
  pushl $0
801074c3:	6a 00                	push   $0x0
  pushl $242
801074c5:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801074ca:	e9 8a ef ff ff       	jmp    80106459 <alltraps>

801074cf <vector243>:
.globl vector243
vector243:
  pushl $0
801074cf:	6a 00                	push   $0x0
  pushl $243
801074d1:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801074d6:	e9 7e ef ff ff       	jmp    80106459 <alltraps>

801074db <vector244>:
.globl vector244
vector244:
  pushl $0
801074db:	6a 00                	push   $0x0
  pushl $244
801074dd:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801074e2:	e9 72 ef ff ff       	jmp    80106459 <alltraps>

801074e7 <vector245>:
.globl vector245
vector245:
  pushl $0
801074e7:	6a 00                	push   $0x0
  pushl $245
801074e9:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801074ee:	e9 66 ef ff ff       	jmp    80106459 <alltraps>

801074f3 <vector246>:
.globl vector246
vector246:
  pushl $0
801074f3:	6a 00                	push   $0x0
  pushl $246
801074f5:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801074fa:	e9 5a ef ff ff       	jmp    80106459 <alltraps>

801074ff <vector247>:
.globl vector247
vector247:
  pushl $0
801074ff:	6a 00                	push   $0x0
  pushl $247
80107501:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107506:	e9 4e ef ff ff       	jmp    80106459 <alltraps>

8010750b <vector248>:
.globl vector248
vector248:
  pushl $0
8010750b:	6a 00                	push   $0x0
  pushl $248
8010750d:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107512:	e9 42 ef ff ff       	jmp    80106459 <alltraps>

80107517 <vector249>:
.globl vector249
vector249:
  pushl $0
80107517:	6a 00                	push   $0x0
  pushl $249
80107519:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010751e:	e9 36 ef ff ff       	jmp    80106459 <alltraps>

80107523 <vector250>:
.globl vector250
vector250:
  pushl $0
80107523:	6a 00                	push   $0x0
  pushl $250
80107525:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010752a:	e9 2a ef ff ff       	jmp    80106459 <alltraps>

8010752f <vector251>:
.globl vector251
vector251:
  pushl $0
8010752f:	6a 00                	push   $0x0
  pushl $251
80107531:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107536:	e9 1e ef ff ff       	jmp    80106459 <alltraps>

8010753b <vector252>:
.globl vector252
vector252:
  pushl $0
8010753b:	6a 00                	push   $0x0
  pushl $252
8010753d:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107542:	e9 12 ef ff ff       	jmp    80106459 <alltraps>

80107547 <vector253>:
.globl vector253
vector253:
  pushl $0
80107547:	6a 00                	push   $0x0
  pushl $253
80107549:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010754e:	e9 06 ef ff ff       	jmp    80106459 <alltraps>

80107553 <vector254>:
.globl vector254
vector254:
  pushl $0
80107553:	6a 00                	push   $0x0
  pushl $254
80107555:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010755a:	e9 fa ee ff ff       	jmp    80106459 <alltraps>

8010755f <vector255>:
.globl vector255
vector255:
  pushl $0
8010755f:	6a 00                	push   $0x0
  pushl $255
80107561:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107566:	e9 ee ee ff ff       	jmp    80106459 <alltraps>

8010756b <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
8010756b:	55                   	push   %ebp
8010756c:	89 e5                	mov    %esp,%ebp
8010756e:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107571:	8b 45 0c             	mov    0xc(%ebp),%eax
80107574:	83 e8 01             	sub    $0x1,%eax
80107577:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010757b:	8b 45 08             	mov    0x8(%ebp),%eax
8010757e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107582:	8b 45 08             	mov    0x8(%ebp),%eax
80107585:	c1 e8 10             	shr    $0x10,%eax
80107588:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010758c:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010758f:	0f 01 10             	lgdtl  (%eax)
}
80107592:	c9                   	leave  
80107593:	c3                   	ret    

80107594 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107594:	55                   	push   %ebp
80107595:	89 e5                	mov    %esp,%ebp
80107597:	83 ec 04             	sub    $0x4,%esp
8010759a:	8b 45 08             	mov    0x8(%ebp),%eax
8010759d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801075a1:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801075a5:	0f 00 d8             	ltr    %ax
}
801075a8:	c9                   	leave  
801075a9:	c3                   	ret    

801075aa <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801075aa:	55                   	push   %ebp
801075ab:	89 e5                	mov    %esp,%ebp
801075ad:	83 ec 04             	sub    $0x4,%esp
801075b0:	8b 45 08             	mov    0x8(%ebp),%eax
801075b3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801075b7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801075bb:	8e e8                	mov    %eax,%gs
}
801075bd:	c9                   	leave  
801075be:	c3                   	ret    

801075bf <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801075bf:	55                   	push   %ebp
801075c0:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801075c2:	8b 45 08             	mov    0x8(%ebp),%eax
801075c5:	0f 22 d8             	mov    %eax,%cr3
}
801075c8:	5d                   	pop    %ebp
801075c9:	c3                   	ret    

801075ca <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801075ca:	55                   	push   %ebp
801075cb:	89 e5                	mov    %esp,%ebp
801075cd:	8b 45 08             	mov    0x8(%ebp),%eax
801075d0:	05 00 00 00 80       	add    $0x80000000,%eax
801075d5:	5d                   	pop    %ebp
801075d6:	c3                   	ret    

801075d7 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801075d7:	55                   	push   %ebp
801075d8:	89 e5                	mov    %esp,%ebp
801075da:	8b 45 08             	mov    0x8(%ebp),%eax
801075dd:	05 00 00 00 80       	add    $0x80000000,%eax
801075e2:	5d                   	pop    %ebp
801075e3:	c3                   	ret    

801075e4 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801075e4:	55                   	push   %ebp
801075e5:	89 e5                	mov    %esp,%ebp
801075e7:	53                   	push   %ebx
801075e8:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];  
801075eb:	e8 88 b8 ff ff       	call   80102e78 <cpunum>
801075f0:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
801075f6:	05 60 23 11 80       	add    $0x80112360,%eax
801075fb:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801075fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107601:	66 c7 40 7c ff ff    	movw   $0xffff,0x7c(%eax)
80107607:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010760a:	66 c7 40 7e 00 00    	movw   $0x0,0x7e(%eax)
80107610:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107613:	c6 80 80 00 00 00 00 	movb   $0x0,0x80(%eax)
8010761a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010761d:	0f b6 90 81 00 00 00 	movzbl 0x81(%eax),%edx
80107624:	83 e2 f0             	and    $0xfffffff0,%edx
80107627:	83 ca 0a             	or     $0xa,%edx
8010762a:	88 90 81 00 00 00    	mov    %dl,0x81(%eax)
80107630:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107633:	0f b6 90 81 00 00 00 	movzbl 0x81(%eax),%edx
8010763a:	83 ca 10             	or     $0x10,%edx
8010763d:	88 90 81 00 00 00    	mov    %dl,0x81(%eax)
80107643:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107646:	0f b6 90 81 00 00 00 	movzbl 0x81(%eax),%edx
8010764d:	83 e2 9f             	and    $0xffffff9f,%edx
80107650:	88 90 81 00 00 00    	mov    %dl,0x81(%eax)
80107656:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107659:	0f b6 90 81 00 00 00 	movzbl 0x81(%eax),%edx
80107660:	83 ca 80             	or     $0xffffff80,%edx
80107663:	88 90 81 00 00 00    	mov    %dl,0x81(%eax)
80107669:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010766c:	0f b6 90 82 00 00 00 	movzbl 0x82(%eax),%edx
80107673:	83 ca 0f             	or     $0xf,%edx
80107676:	88 90 82 00 00 00    	mov    %dl,0x82(%eax)
8010767c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010767f:	0f b6 90 82 00 00 00 	movzbl 0x82(%eax),%edx
80107686:	83 e2 ef             	and    $0xffffffef,%edx
80107689:	88 90 82 00 00 00    	mov    %dl,0x82(%eax)
8010768f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107692:	0f b6 90 82 00 00 00 	movzbl 0x82(%eax),%edx
80107699:	83 e2 df             	and    $0xffffffdf,%edx
8010769c:	88 90 82 00 00 00    	mov    %dl,0x82(%eax)
801076a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a5:	0f b6 90 82 00 00 00 	movzbl 0x82(%eax),%edx
801076ac:	83 ca 40             	or     $0x40,%edx
801076af:	88 90 82 00 00 00    	mov    %dl,0x82(%eax)
801076b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b8:	0f b6 90 82 00 00 00 	movzbl 0x82(%eax),%edx
801076bf:	83 ca 80             	or     $0xffffff80,%edx
801076c2:	88 90 82 00 00 00    	mov    %dl,0x82(%eax)
801076c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076cb:	c6 80 83 00 00 00 00 	movb   $0x0,0x83(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801076d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d5:	66 c7 80 84 00 00 00 	movw   $0xffff,0x84(%eax)
801076dc:	ff ff 
801076de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e1:	66 c7 80 86 00 00 00 	movw   $0x0,0x86(%eax)
801076e8:	00 00 
801076ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ed:	c6 80 88 00 00 00 00 	movb   $0x0,0x88(%eax)
801076f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f7:	0f b6 90 89 00 00 00 	movzbl 0x89(%eax),%edx
801076fe:	83 e2 f0             	and    $0xfffffff0,%edx
80107701:	83 ca 02             	or     $0x2,%edx
80107704:	88 90 89 00 00 00    	mov    %dl,0x89(%eax)
8010770a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010770d:	0f b6 90 89 00 00 00 	movzbl 0x89(%eax),%edx
80107714:	83 ca 10             	or     $0x10,%edx
80107717:	88 90 89 00 00 00    	mov    %dl,0x89(%eax)
8010771d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107720:	0f b6 90 89 00 00 00 	movzbl 0x89(%eax),%edx
80107727:	83 e2 9f             	and    $0xffffff9f,%edx
8010772a:	88 90 89 00 00 00    	mov    %dl,0x89(%eax)
80107730:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107733:	0f b6 90 89 00 00 00 	movzbl 0x89(%eax),%edx
8010773a:	83 ca 80             	or     $0xffffff80,%edx
8010773d:	88 90 89 00 00 00    	mov    %dl,0x89(%eax)
80107743:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107746:	0f b6 90 8a 00 00 00 	movzbl 0x8a(%eax),%edx
8010774d:	83 ca 0f             	or     $0xf,%edx
80107750:	88 90 8a 00 00 00    	mov    %dl,0x8a(%eax)
80107756:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107759:	0f b6 90 8a 00 00 00 	movzbl 0x8a(%eax),%edx
80107760:	83 e2 ef             	and    $0xffffffef,%edx
80107763:	88 90 8a 00 00 00    	mov    %dl,0x8a(%eax)
80107769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010776c:	0f b6 90 8a 00 00 00 	movzbl 0x8a(%eax),%edx
80107773:	83 e2 df             	and    $0xffffffdf,%edx
80107776:	88 90 8a 00 00 00    	mov    %dl,0x8a(%eax)
8010777c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010777f:	0f b6 90 8a 00 00 00 	movzbl 0x8a(%eax),%edx
80107786:	83 ca 40             	or     $0x40,%edx
80107789:	88 90 8a 00 00 00    	mov    %dl,0x8a(%eax)
8010778f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107792:	0f b6 90 8a 00 00 00 	movzbl 0x8a(%eax),%edx
80107799:	83 ca 80             	or     $0xffffff80,%edx
8010779c:	88 90 8a 00 00 00    	mov    %dl,0x8a(%eax)
801077a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a5:	c6 80 8b 00 00 00 00 	movb   $0x0,0x8b(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801077ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077af:	66 c7 80 94 00 00 00 	movw   $0xffff,0x94(%eax)
801077b6:	ff ff 
801077b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077bb:	66 c7 80 96 00 00 00 	movw   $0x0,0x96(%eax)
801077c2:	00 00 
801077c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c7:	c6 80 98 00 00 00 00 	movb   $0x0,0x98(%eax)
801077ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d1:	0f b6 90 99 00 00 00 	movzbl 0x99(%eax),%edx
801077d8:	83 e2 f0             	and    $0xfffffff0,%edx
801077db:	83 ca 0a             	or     $0xa,%edx
801077de:	88 90 99 00 00 00    	mov    %dl,0x99(%eax)
801077e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e7:	0f b6 90 99 00 00 00 	movzbl 0x99(%eax),%edx
801077ee:	83 ca 10             	or     $0x10,%edx
801077f1:	88 90 99 00 00 00    	mov    %dl,0x99(%eax)
801077f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077fa:	0f b6 90 99 00 00 00 	movzbl 0x99(%eax),%edx
80107801:	83 ca 60             	or     $0x60,%edx
80107804:	88 90 99 00 00 00    	mov    %dl,0x99(%eax)
8010780a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010780d:	0f b6 90 99 00 00 00 	movzbl 0x99(%eax),%edx
80107814:	83 ca 80             	or     $0xffffff80,%edx
80107817:	88 90 99 00 00 00    	mov    %dl,0x99(%eax)
8010781d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107820:	0f b6 90 9a 00 00 00 	movzbl 0x9a(%eax),%edx
80107827:	83 ca 0f             	or     $0xf,%edx
8010782a:	88 90 9a 00 00 00    	mov    %dl,0x9a(%eax)
80107830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107833:	0f b6 90 9a 00 00 00 	movzbl 0x9a(%eax),%edx
8010783a:	83 e2 ef             	and    $0xffffffef,%edx
8010783d:	88 90 9a 00 00 00    	mov    %dl,0x9a(%eax)
80107843:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107846:	0f b6 90 9a 00 00 00 	movzbl 0x9a(%eax),%edx
8010784d:	83 e2 df             	and    $0xffffffdf,%edx
80107850:	88 90 9a 00 00 00    	mov    %dl,0x9a(%eax)
80107856:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107859:	0f b6 90 9a 00 00 00 	movzbl 0x9a(%eax),%edx
80107860:	83 ca 40             	or     $0x40,%edx
80107863:	88 90 9a 00 00 00    	mov    %dl,0x9a(%eax)
80107869:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010786c:	0f b6 90 9a 00 00 00 	movzbl 0x9a(%eax),%edx
80107873:	83 ca 80             	or     $0xffffff80,%edx
80107876:	88 90 9a 00 00 00    	mov    %dl,0x9a(%eax)
8010787c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787f:	c6 80 9b 00 00 00 00 	movb   $0x0,0x9b(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107886:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107889:	66 c7 80 9c 00 00 00 	movw   $0xffff,0x9c(%eax)
80107890:	ff ff 
80107892:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107895:	66 c7 80 9e 00 00 00 	movw   $0x0,0x9e(%eax)
8010789c:	00 00 
8010789e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a1:	c6 80 a0 00 00 00 00 	movb   $0x0,0xa0(%eax)
801078a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ab:	0f b6 90 a1 00 00 00 	movzbl 0xa1(%eax),%edx
801078b2:	83 e2 f0             	and    $0xfffffff0,%edx
801078b5:	83 ca 02             	or     $0x2,%edx
801078b8:	88 90 a1 00 00 00    	mov    %dl,0xa1(%eax)
801078be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c1:	0f b6 90 a1 00 00 00 	movzbl 0xa1(%eax),%edx
801078c8:	83 ca 10             	or     $0x10,%edx
801078cb:	88 90 a1 00 00 00    	mov    %dl,0xa1(%eax)
801078d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d4:	0f b6 90 a1 00 00 00 	movzbl 0xa1(%eax),%edx
801078db:	83 ca 60             	or     $0x60,%edx
801078de:	88 90 a1 00 00 00    	mov    %dl,0xa1(%eax)
801078e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e7:	0f b6 90 a1 00 00 00 	movzbl 0xa1(%eax),%edx
801078ee:	83 ca 80             	or     $0xffffff80,%edx
801078f1:	88 90 a1 00 00 00    	mov    %dl,0xa1(%eax)
801078f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078fa:	0f b6 90 a2 00 00 00 	movzbl 0xa2(%eax),%edx
80107901:	83 ca 0f             	or     $0xf,%edx
80107904:	88 90 a2 00 00 00    	mov    %dl,0xa2(%eax)
8010790a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790d:	0f b6 90 a2 00 00 00 	movzbl 0xa2(%eax),%edx
80107914:	83 e2 ef             	and    $0xffffffef,%edx
80107917:	88 90 a2 00 00 00    	mov    %dl,0xa2(%eax)
8010791d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107920:	0f b6 90 a2 00 00 00 	movzbl 0xa2(%eax),%edx
80107927:	83 e2 df             	and    $0xffffffdf,%edx
8010792a:	88 90 a2 00 00 00    	mov    %dl,0xa2(%eax)
80107930:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107933:	0f b6 90 a2 00 00 00 	movzbl 0xa2(%eax),%edx
8010793a:	83 ca 40             	or     $0x40,%edx
8010793d:	88 90 a2 00 00 00    	mov    %dl,0xa2(%eax)
80107943:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107946:	0f b6 90 a2 00 00 00 	movzbl 0xa2(%eax),%edx
8010794d:	83 ca 80             	or     $0xffffff80,%edx
80107950:	88 90 a2 00 00 00    	mov    %dl,0xa2(%eax)
80107956:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107959:	c6 80 a3 00 00 00 00 	movb   $0x0,0xa3(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107960:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107963:	05 b8 00 00 00       	add    $0xb8,%eax
80107968:	89 c3                	mov    %eax,%ebx
8010796a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010796d:	05 b8 00 00 00       	add    $0xb8,%eax
80107972:	c1 e8 10             	shr    $0x10,%eax
80107975:	89 c1                	mov    %eax,%ecx
80107977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797a:	05 b8 00 00 00       	add    $0xb8,%eax
8010797f:	c1 e8 18             	shr    $0x18,%eax
80107982:	89 c2                	mov    %eax,%edx
80107984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107987:	66 c7 80 8c 00 00 00 	movw   $0x0,0x8c(%eax)
8010798e:	00 00 
80107990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107993:	66 89 98 8e 00 00 00 	mov    %bx,0x8e(%eax)
8010799a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010799d:	88 88 90 00 00 00    	mov    %cl,0x90(%eax)
801079a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a6:	0f b6 88 91 00 00 00 	movzbl 0x91(%eax),%ecx
801079ad:	83 e1 f0             	and    $0xfffffff0,%ecx
801079b0:	83 c9 02             	or     $0x2,%ecx
801079b3:	88 88 91 00 00 00    	mov    %cl,0x91(%eax)
801079b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079bc:	0f b6 88 91 00 00 00 	movzbl 0x91(%eax),%ecx
801079c3:	83 c9 10             	or     $0x10,%ecx
801079c6:	88 88 91 00 00 00    	mov    %cl,0x91(%eax)
801079cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079cf:	0f b6 88 91 00 00 00 	movzbl 0x91(%eax),%ecx
801079d6:	83 e1 9f             	and    $0xffffff9f,%ecx
801079d9:	88 88 91 00 00 00    	mov    %cl,0x91(%eax)
801079df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e2:	0f b6 88 91 00 00 00 	movzbl 0x91(%eax),%ecx
801079e9:	83 c9 80             	or     $0xffffff80,%ecx
801079ec:	88 88 91 00 00 00    	mov    %cl,0x91(%eax)
801079f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f5:	0f b6 88 92 00 00 00 	movzbl 0x92(%eax),%ecx
801079fc:	83 e1 f0             	and    $0xfffffff0,%ecx
801079ff:	88 88 92 00 00 00    	mov    %cl,0x92(%eax)
80107a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a08:	0f b6 88 92 00 00 00 	movzbl 0x92(%eax),%ecx
80107a0f:	83 e1 ef             	and    $0xffffffef,%ecx
80107a12:	88 88 92 00 00 00    	mov    %cl,0x92(%eax)
80107a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1b:	0f b6 88 92 00 00 00 	movzbl 0x92(%eax),%ecx
80107a22:	83 e1 df             	and    $0xffffffdf,%ecx
80107a25:	88 88 92 00 00 00    	mov    %cl,0x92(%eax)
80107a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2e:	0f b6 88 92 00 00 00 	movzbl 0x92(%eax),%ecx
80107a35:	83 c9 40             	or     $0x40,%ecx
80107a38:	88 88 92 00 00 00    	mov    %cl,0x92(%eax)
80107a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a41:	0f b6 88 92 00 00 00 	movzbl 0x92(%eax),%ecx
80107a48:	83 c9 80             	or     $0xffffff80,%ecx
80107a4b:	88 88 92 00 00 00    	mov    %cl,0x92(%eax)
80107a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a54:	88 90 93 00 00 00    	mov    %dl,0x93(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5d:	83 c0 74             	add    $0x74,%eax
80107a60:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107a67:	00 
80107a68:	89 04 24             	mov    %eax,(%esp)
80107a6b:	e8 fb fa ff ff       	call   8010756b <lgdt>
  loadgs(SEG_KCPU << 3);
80107a70:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107a77:	e8 2e fb ff ff       	call   801075aa <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7f:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107a85:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107a8c:	00 00 00 00 
}
80107a90:	83 c4 24             	add    $0x24,%esp
80107a93:	5b                   	pop    %ebx
80107a94:	5d                   	pop    %ebp
80107a95:	c3                   	ret    

80107a96 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107a96:	55                   	push   %ebp
80107a97:	89 e5                	mov    %esp,%ebp
80107a99:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a9f:	c1 e8 16             	shr    $0x16,%eax
80107aa2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107aa9:	8b 45 08             	mov    0x8(%ebp),%eax
80107aac:	01 d0                	add    %edx,%eax
80107aae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107ab1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ab4:	8b 00                	mov    (%eax),%eax
80107ab6:	83 e0 01             	and    $0x1,%eax
80107ab9:	85 c0                	test   %eax,%eax
80107abb:	74 17                	je     80107ad4 <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107abd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ac0:	8b 00                	mov    (%eax),%eax
80107ac2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ac7:	89 04 24             	mov    %eax,(%esp)
80107aca:	e8 08 fb ff ff       	call   801075d7 <p2v>
80107acf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ad2:	eb 4b                	jmp    80107b1f <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107ad4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107ad8:	74 0e                	je     80107ae8 <walkpgdir+0x52>
80107ada:	e8 03 b0 ff ff       	call   80102ae2 <kalloc>
80107adf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ae2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107ae6:	75 07                	jne    80107aef <walkpgdir+0x59>
      return 0;
80107ae8:	b8 00 00 00 00       	mov    $0x0,%eax
80107aed:	eb 47                	jmp    80107b36 <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107aef:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107af6:	00 
80107af7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107afe:	00 
80107aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b02:	89 04 24             	mov    %eax,(%esp)
80107b05:	e8 5b d5 ff ff       	call   80105065 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0d:	89 04 24             	mov    %eax,(%esp)
80107b10:	e8 b5 fa ff ff       	call   801075ca <v2p>
80107b15:	83 c8 07             	or     $0x7,%eax
80107b18:	89 c2                	mov    %eax,%edx
80107b1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b1d:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107b1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b22:	c1 e8 0c             	shr    $0xc,%eax
80107b25:	25 ff 03 00 00       	and    $0x3ff,%eax
80107b2a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b34:	01 d0                	add    %edx,%eax
}
80107b36:	c9                   	leave  
80107b37:	c3                   	ret    

80107b38 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107b38:	55                   	push   %ebp
80107b39:	89 e5                	mov    %esp,%ebp
80107b3b:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107b3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b41:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b46:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107b49:	8b 55 0c             	mov    0xc(%ebp),%edx
80107b4c:	8b 45 10             	mov    0x10(%ebp),%eax
80107b4f:	01 d0                	add    %edx,%eax
80107b51:	83 e8 01             	sub    $0x1,%eax
80107b54:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b59:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107b5c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107b63:	00 
80107b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b67:	89 44 24 04          	mov    %eax,0x4(%esp)
80107b6b:	8b 45 08             	mov    0x8(%ebp),%eax
80107b6e:	89 04 24             	mov    %eax,(%esp)
80107b71:	e8 20 ff ff ff       	call   80107a96 <walkpgdir>
80107b76:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107b79:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107b7d:	75 07                	jne    80107b86 <mappages+0x4e>
      return -1;
80107b7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b84:	eb 48                	jmp    80107bce <mappages+0x96>
    if(*pte & PTE_P)
80107b86:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b89:	8b 00                	mov    (%eax),%eax
80107b8b:	83 e0 01             	and    $0x1,%eax
80107b8e:	85 c0                	test   %eax,%eax
80107b90:	74 0c                	je     80107b9e <mappages+0x66>
      panic("remap");
80107b92:	c7 04 24 78 8c 10 80 	movl   $0x80108c78,(%esp)
80107b99:	e8 9c 89 ff ff       	call   8010053a <panic>
    *pte = pa | perm | PTE_P;
80107b9e:	8b 45 18             	mov    0x18(%ebp),%eax
80107ba1:	0b 45 14             	or     0x14(%ebp),%eax
80107ba4:	83 c8 01             	or     $0x1,%eax
80107ba7:	89 c2                	mov    %eax,%edx
80107ba9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107bac:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107bb4:	75 08                	jne    80107bbe <mappages+0x86>
      break;
80107bb6:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107bb7:	b8 00 00 00 00       	mov    $0x0,%eax
80107bbc:	eb 10                	jmp    80107bce <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80107bbe:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107bc5:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107bcc:	eb 8e                	jmp    80107b5c <mappages+0x24>
  return 0;
}
80107bce:	c9                   	leave  
80107bcf:	c3                   	ret    

80107bd0 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107bd0:	55                   	push   %ebp
80107bd1:	89 e5                	mov    %esp,%ebp
80107bd3:	53                   	push   %ebx
80107bd4:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107bd7:	e8 06 af ff ff       	call   80102ae2 <kalloc>
80107bdc:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107bdf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107be3:	75 0a                	jne    80107bef <setupkvm+0x1f>
    return 0;
80107be5:	b8 00 00 00 00       	mov    $0x0,%eax
80107bea:	e9 98 00 00 00       	jmp    80107c87 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80107bef:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107bf6:	00 
80107bf7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107bfe:	00 
80107bff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c02:	89 04 24             	mov    %eax,(%esp)
80107c05:	e8 5b d4 ff ff       	call   80105065 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107c0a:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80107c11:	e8 c1 f9 ff ff       	call   801075d7 <p2v>
80107c16:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107c1b:	76 0c                	jbe    80107c29 <setupkvm+0x59>
    panic("PHYSTOP too high");
80107c1d:	c7 04 24 7e 8c 10 80 	movl   $0x80108c7e,(%esp)
80107c24:	e8 11 89 ff ff       	call   8010053a <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107c29:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107c30:	eb 49                	jmp    80107c7b <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c35:	8b 48 0c             	mov    0xc(%eax),%ecx
80107c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3b:	8b 50 04             	mov    0x4(%eax),%edx
80107c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c41:	8b 58 08             	mov    0x8(%eax),%ebx
80107c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c47:	8b 40 04             	mov    0x4(%eax),%eax
80107c4a:	29 c3                	sub    %eax,%ebx
80107c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4f:	8b 00                	mov    (%eax),%eax
80107c51:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107c55:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107c59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107c5d:	89 44 24 04          	mov    %eax,0x4(%esp)
80107c61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c64:	89 04 24             	mov    %eax,(%esp)
80107c67:	e8 cc fe ff ff       	call   80107b38 <mappages>
80107c6c:	85 c0                	test   %eax,%eax
80107c6e:	79 07                	jns    80107c77 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107c70:	b8 00 00 00 00       	mov    $0x0,%eax
80107c75:	eb 10                	jmp    80107c87 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107c77:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107c7b:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80107c82:	72 ae                	jb     80107c32 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107c84:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107c87:	83 c4 34             	add    $0x34,%esp
80107c8a:	5b                   	pop    %ebx
80107c8b:	5d                   	pop    %ebp
80107c8c:	c3                   	ret    

80107c8d <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(struct cpu *c)
{
80107c8d:	55                   	push   %ebp
80107c8e:	89 e5                	mov    %esp,%ebp
80107c90:	83 ec 18             	sub    $0x18,%esp
  c->kpgdir = setupkvm();
80107c93:	e8 38 ff ff ff       	call   80107bd0 <setupkvm>
80107c98:	8b 55 08             	mov    0x8(%ebp),%edx
80107c9b:	89 42 04             	mov    %eax,0x4(%edx)
  switchkvm(c);
80107c9e:	8b 45 08             	mov    0x8(%ebp),%eax
80107ca1:	89 04 24             	mov    %eax,(%esp)
80107ca4:	e8 02 00 00 00       	call   80107cab <switchkvm>
}
80107ca9:	c9                   	leave  
80107caa:	c3                   	ret    

80107cab <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(struct cpu *c)
{
80107cab:	55                   	push   %ebp
80107cac:	89 e5                	mov    %esp,%ebp
80107cae:	83 ec 18             	sub    $0x18,%esp
  flushTLB();
80107cb1:	e8 26 09 00 00       	call   801085dc <flushTLB>
  lcr3(v2p(c->kpgdir));   // switch to the kernel page table
80107cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80107cb9:	8b 40 04             	mov    0x4(%eax),%eax
80107cbc:	89 04 24             	mov    %eax,(%esp)
80107cbf:	e8 06 f9 ff ff       	call   801075ca <v2p>
80107cc4:	89 04 24             	mov    %eax,(%esp)
80107cc7:	e8 f3 f8 ff ff       	call   801075bf <lcr3>

}
80107ccc:	c9                   	leave  
80107ccd:	c3                   	ret    

80107cce <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107cce:	55                   	push   %ebp
80107ccf:	89 e5                	mov    %esp,%ebp
80107cd1:	53                   	push   %ebx
80107cd2:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80107cd5:	e8 8b d2 ff ff       	call   80104f65 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107cda:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107ce0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107ce7:	83 c2 0c             	add    $0xc,%edx
80107cea:	89 d3                	mov    %edx,%ebx
80107cec:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107cf3:	83 c2 0c             	add    $0xc,%edx
80107cf6:	c1 ea 10             	shr    $0x10,%edx
80107cf9:	89 d1                	mov    %edx,%ecx
80107cfb:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107d02:	83 c2 0c             	add    $0xc,%edx
80107d05:	c1 ea 18             	shr    $0x18,%edx
80107d08:	66 c7 80 a4 00 00 00 	movw   $0x67,0xa4(%eax)
80107d0f:	67 00 
80107d11:	66 89 98 a6 00 00 00 	mov    %bx,0xa6(%eax)
80107d18:	88 88 a8 00 00 00    	mov    %cl,0xa8(%eax)
80107d1e:	0f b6 88 a9 00 00 00 	movzbl 0xa9(%eax),%ecx
80107d25:	83 e1 f0             	and    $0xfffffff0,%ecx
80107d28:	83 c9 09             	or     $0x9,%ecx
80107d2b:	88 88 a9 00 00 00    	mov    %cl,0xa9(%eax)
80107d31:	0f b6 88 a9 00 00 00 	movzbl 0xa9(%eax),%ecx
80107d38:	83 c9 10             	or     $0x10,%ecx
80107d3b:	88 88 a9 00 00 00    	mov    %cl,0xa9(%eax)
80107d41:	0f b6 88 a9 00 00 00 	movzbl 0xa9(%eax),%ecx
80107d48:	83 e1 9f             	and    $0xffffff9f,%ecx
80107d4b:	88 88 a9 00 00 00    	mov    %cl,0xa9(%eax)
80107d51:	0f b6 88 a9 00 00 00 	movzbl 0xa9(%eax),%ecx
80107d58:	83 c9 80             	or     $0xffffff80,%ecx
80107d5b:	88 88 a9 00 00 00    	mov    %cl,0xa9(%eax)
80107d61:	0f b6 88 aa 00 00 00 	movzbl 0xaa(%eax),%ecx
80107d68:	83 e1 f0             	and    $0xfffffff0,%ecx
80107d6b:	88 88 aa 00 00 00    	mov    %cl,0xaa(%eax)
80107d71:	0f b6 88 aa 00 00 00 	movzbl 0xaa(%eax),%ecx
80107d78:	83 e1 ef             	and    $0xffffffef,%ecx
80107d7b:	88 88 aa 00 00 00    	mov    %cl,0xaa(%eax)
80107d81:	0f b6 88 aa 00 00 00 	movzbl 0xaa(%eax),%ecx
80107d88:	83 e1 df             	and    $0xffffffdf,%ecx
80107d8b:	88 88 aa 00 00 00    	mov    %cl,0xaa(%eax)
80107d91:	0f b6 88 aa 00 00 00 	movzbl 0xaa(%eax),%ecx
80107d98:	83 c9 40             	or     $0x40,%ecx
80107d9b:	88 88 aa 00 00 00    	mov    %cl,0xaa(%eax)
80107da1:	0f b6 88 aa 00 00 00 	movzbl 0xaa(%eax),%ecx
80107da8:	83 e1 7f             	and    $0x7f,%ecx
80107dab:	88 88 aa 00 00 00    	mov    %cl,0xaa(%eax)
80107db1:	88 90 ab 00 00 00    	mov    %dl,0xab(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107db7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107dbd:	0f b6 90 a9 00 00 00 	movzbl 0xa9(%eax),%edx
80107dc4:	83 e2 ef             	and    $0xffffffef,%edx
80107dc7:	88 90 a9 00 00 00    	mov    %dl,0xa9(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107dcd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107dd3:	66 c7 40 14 10 00    	movw   $0x10,0x14(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107dd9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107ddf:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107de6:	8b 52 08             	mov    0x8(%edx),%edx
80107de9:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107def:	89 50 10             	mov    %edx,0x10(%eax)
  ltr(SEG_TSS << 3);
80107df2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80107df9:	e8 96 f7 ff ff       	call   80107594 <ltr>
  if(p->pgdir == 0)
80107dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80107e01:	8b 40 04             	mov    0x4(%eax),%eax
80107e04:	85 c0                	test   %eax,%eax
80107e06:	75 0c                	jne    80107e14 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80107e08:	c7 04 24 8f 8c 10 80 	movl   $0x80108c8f,(%esp)
80107e0f:	e8 26 87 ff ff       	call   8010053a <panic>
  // lcr3(v2p(p->pgdir));  // switch to new address space
  flushTLB();
80107e14:	e8 c3 07 00 00       	call   801085dc <flushTLB>
  popcli();
80107e19:	e8 8b d1 ff ff       	call   80104fa9 <popcli>
}
80107e1e:	83 c4 14             	add    $0x14,%esp
80107e21:	5b                   	pop    %ebx
80107e22:	5d                   	pop    %ebp
80107e23:	c3                   	ret    

80107e24 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107e24:	55                   	push   %ebp
80107e25:	89 e5                	mov    %esp,%ebp
80107e27:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80107e2a:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107e31:	76 0c                	jbe    80107e3f <inituvm+0x1b>
    panic("inituvm: more than a page");
80107e33:	c7 04 24 a3 8c 10 80 	movl   $0x80108ca3,(%esp)
80107e3a:	e8 fb 86 ff ff       	call   8010053a <panic>
  mem = kalloc();
80107e3f:	e8 9e ac ff ff       	call   80102ae2 <kalloc>
80107e44:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107e47:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107e4e:	00 
80107e4f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107e56:	00 
80107e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5a:	89 04 24             	mov    %eax,(%esp)
80107e5d:	e8 03 d2 ff ff       	call   80105065 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107e62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e65:	89 04 24             	mov    %eax,(%esp)
80107e68:	e8 5d f7 ff ff       	call   801075ca <v2p>
80107e6d:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107e74:	00 
80107e75:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107e79:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107e80:	00 
80107e81:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107e88:	00 
80107e89:	8b 45 08             	mov    0x8(%ebp),%eax
80107e8c:	89 04 24             	mov    %eax,(%esp)
80107e8f:	e8 a4 fc ff ff       	call   80107b38 <mappages>
  memmove(mem, init, sz);
80107e94:	8b 45 10             	mov    0x10(%ebp),%eax
80107e97:	89 44 24 08          	mov    %eax,0x8(%esp)
80107e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e9e:	89 44 24 04          	mov    %eax,0x4(%esp)
80107ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea5:	89 04 24             	mov    %eax,(%esp)
80107ea8:	e8 87 d2 ff ff       	call   80105134 <memmove>
}
80107ead:	c9                   	leave  
80107eae:	c3                   	ret    

80107eaf <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107eaf:	55                   	push   %ebp
80107eb0:	89 e5                	mov    %esp,%ebp
80107eb2:	53                   	push   %ebx
80107eb3:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107eb6:	8b 45 0c             	mov    0xc(%ebp),%eax
80107eb9:	25 ff 0f 00 00       	and    $0xfff,%eax
80107ebe:	85 c0                	test   %eax,%eax
80107ec0:	74 0c                	je     80107ece <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107ec2:	c7 04 24 c0 8c 10 80 	movl   $0x80108cc0,(%esp)
80107ec9:	e8 6c 86 ff ff       	call   8010053a <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107ece:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ed5:	e9 a9 00 00 00       	jmp    80107f83 <loaduvm+0xd4>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107edd:	8b 55 0c             	mov    0xc(%ebp),%edx
80107ee0:	01 d0                	add    %edx,%eax
80107ee2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107ee9:	00 
80107eea:	89 44 24 04          	mov    %eax,0x4(%esp)
80107eee:	8b 45 08             	mov    0x8(%ebp),%eax
80107ef1:	89 04 24             	mov    %eax,(%esp)
80107ef4:	e8 9d fb ff ff       	call   80107a96 <walkpgdir>
80107ef9:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107efc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f00:	75 0c                	jne    80107f0e <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80107f02:	c7 04 24 e3 8c 10 80 	movl   $0x80108ce3,(%esp)
80107f09:	e8 2c 86 ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
80107f0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f11:	8b 00                	mov    (%eax),%eax
80107f13:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f18:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1e:	8b 55 18             	mov    0x18(%ebp),%edx
80107f21:	29 c2                	sub    %eax,%edx
80107f23:	89 d0                	mov    %edx,%eax
80107f25:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107f2a:	77 0f                	ja     80107f3b <loaduvm+0x8c>
      n = sz - i;
80107f2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f2f:	8b 55 18             	mov    0x18(%ebp),%edx
80107f32:	29 c2                	sub    %eax,%edx
80107f34:	89 d0                	mov    %edx,%eax
80107f36:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107f39:	eb 07                	jmp    80107f42 <loaduvm+0x93>
    else
      n = PGSIZE;
80107f3b:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80107f42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f45:	8b 55 14             	mov    0x14(%ebp),%edx
80107f48:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80107f4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107f4e:	89 04 24             	mov    %eax,(%esp)
80107f51:	e8 81 f6 ff ff       	call   801075d7 <p2v>
80107f56:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107f59:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107f5d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107f61:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f65:	8b 45 10             	mov    0x10(%ebp),%eax
80107f68:	89 04 24             	mov    %eax,(%esp)
80107f6b:	e8 f8 9d ff ff       	call   80101d68 <readi>
80107f70:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107f73:	74 07                	je     80107f7c <loaduvm+0xcd>
      return -1;
80107f75:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f7a:	eb 18                	jmp    80107f94 <loaduvm+0xe5>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80107f7c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f86:	3b 45 18             	cmp    0x18(%ebp),%eax
80107f89:	0f 82 4b ff ff ff    	jb     80107eda <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80107f8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f94:	83 c4 24             	add    $0x24,%esp
80107f97:	5b                   	pop    %ebx
80107f98:	5d                   	pop    %ebp
80107f99:	c3                   	ret    

80107f9a <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107f9a:	55                   	push   %ebp
80107f9b:	89 e5                	mov    %esp,%ebp
80107f9d:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107fa0:	8b 45 10             	mov    0x10(%ebp),%eax
80107fa3:	85 c0                	test   %eax,%eax
80107fa5:	79 0a                	jns    80107fb1 <allocuvm+0x17>
    return 0;
80107fa7:	b8 00 00 00 00       	mov    $0x0,%eax
80107fac:	e9 c1 00 00 00       	jmp    80108072 <allocuvm+0xd8>
  if(newsz < oldsz)
80107fb1:	8b 45 10             	mov    0x10(%ebp),%eax
80107fb4:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107fb7:	73 08                	jae    80107fc1 <allocuvm+0x27>
    return oldsz;
80107fb9:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fbc:	e9 b1 00 00 00       	jmp    80108072 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80107fc1:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fc4:	05 ff 0f 00 00       	add    $0xfff,%eax
80107fc9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107fd1:	e9 8d 00 00 00       	jmp    80108063 <allocuvm+0xc9>
    mem = kalloc();
80107fd6:	e8 07 ab ff ff       	call   80102ae2 <kalloc>
80107fdb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107fde:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107fe2:	75 2c                	jne    80108010 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80107fe4:	c7 04 24 01 8d 10 80 	movl   $0x80108d01,(%esp)
80107feb:	e8 b0 83 ff ff       	call   801003a0 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80107ff0:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ff3:	89 44 24 08          	mov    %eax,0x8(%esp)
80107ff7:	8b 45 10             	mov    0x10(%ebp),%eax
80107ffa:	89 44 24 04          	mov    %eax,0x4(%esp)
80107ffe:	8b 45 08             	mov    0x8(%ebp),%eax
80108001:	89 04 24             	mov    %eax,(%esp)
80108004:	e8 6b 00 00 00       	call   80108074 <deallocuvm>
      return 0;
80108009:	b8 00 00 00 00       	mov    $0x0,%eax
8010800e:	eb 62                	jmp    80108072 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80108010:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108017:	00 
80108018:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010801f:	00 
80108020:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108023:	89 04 24             	mov    %eax,(%esp)
80108026:	e8 3a d0 ff ff       	call   80105065 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010802b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010802e:	89 04 24             	mov    %eax,(%esp)
80108031:	e8 94 f5 ff ff       	call   801075ca <v2p>
80108036:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108039:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108040:	00 
80108041:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108045:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010804c:	00 
8010804d:	89 54 24 04          	mov    %edx,0x4(%esp)
80108051:	8b 45 08             	mov    0x8(%ebp),%eax
80108054:	89 04 24             	mov    %eax,(%esp)
80108057:	e8 dc fa ff ff       	call   80107b38 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
8010805c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108063:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108066:	3b 45 10             	cmp    0x10(%ebp),%eax
80108069:	0f 82 67 ff ff ff    	jb     80107fd6 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
8010806f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108072:	c9                   	leave  
80108073:	c3                   	ret    

80108074 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108074:	55                   	push   %ebp
80108075:	89 e5                	mov    %esp,%ebp
80108077:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010807a:	8b 45 10             	mov    0x10(%ebp),%eax
8010807d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108080:	72 08                	jb     8010808a <deallocuvm+0x16>
    return oldsz;
80108082:	8b 45 0c             	mov    0xc(%ebp),%eax
80108085:	e9 a4 00 00 00       	jmp    8010812e <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
8010808a:	8b 45 10             	mov    0x10(%ebp),%eax
8010808d:	05 ff 0f 00 00       	add    $0xfff,%eax
80108092:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108097:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010809a:	e9 80 00 00 00       	jmp    8010811f <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010809f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801080a9:	00 
801080aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801080ae:	8b 45 08             	mov    0x8(%ebp),%eax
801080b1:	89 04 24             	mov    %eax,(%esp)
801080b4:	e8 dd f9 ff ff       	call   80107a96 <walkpgdir>
801080b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801080bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080c0:	75 09                	jne    801080cb <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
801080c2:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801080c9:	eb 4d                	jmp    80108118 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
801080cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080ce:	8b 00                	mov    (%eax),%eax
801080d0:	83 e0 01             	and    $0x1,%eax
801080d3:	85 c0                	test   %eax,%eax
801080d5:	74 41                	je     80108118 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
801080d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080da:	8b 00                	mov    (%eax),%eax
801080dc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801080e4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801080e8:	75 0c                	jne    801080f6 <deallocuvm+0x82>
        panic("kfree");
801080ea:	c7 04 24 19 8d 10 80 	movl   $0x80108d19,(%esp)
801080f1:	e8 44 84 ff ff       	call   8010053a <panic>
      char *v = p2v(pa);
801080f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080f9:	89 04 24             	mov    %eax,(%esp)
801080fc:	e8 d6 f4 ff ff       	call   801075d7 <p2v>
80108101:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108104:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108107:	89 04 24             	mov    %eax,(%esp)
8010810a:	e8 3a a9 ff ff       	call   80102a49 <kfree>
      *pte = 0;
8010810f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108112:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108118:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010811f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108122:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108125:	0f 82 74 ff ff ff    	jb     8010809f <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
8010812b:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010812e:	c9                   	leave  
8010812f:	c3                   	ret    

80108130 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108130:	55                   	push   %ebp
80108131:	89 e5                	mov    %esp,%ebp
80108133:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108136:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010813a:	75 0c                	jne    80108148 <freevm+0x18>
    panic("freevm: no pgdir");
8010813c:	c7 04 24 1f 8d 10 80 	movl   $0x80108d1f,(%esp)
80108143:	e8 f2 83 ff ff       	call   8010053a <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108148:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010814f:	00 
80108150:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108157:	80 
80108158:	8b 45 08             	mov    0x8(%ebp),%eax
8010815b:	89 04 24             	mov    %eax,(%esp)
8010815e:	e8 11 ff ff ff       	call   80108074 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108163:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010816a:	eb 48                	jmp    801081b4 <freevm+0x84>
    if(pgdir[i] & PTE_P){
8010816c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010816f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108176:	8b 45 08             	mov    0x8(%ebp),%eax
80108179:	01 d0                	add    %edx,%eax
8010817b:	8b 00                	mov    (%eax),%eax
8010817d:	83 e0 01             	and    $0x1,%eax
80108180:	85 c0                	test   %eax,%eax
80108182:	74 2c                	je     801081b0 <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108184:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108187:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010818e:	8b 45 08             	mov    0x8(%ebp),%eax
80108191:	01 d0                	add    %edx,%eax
80108193:	8b 00                	mov    (%eax),%eax
80108195:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010819a:	89 04 24             	mov    %eax,(%esp)
8010819d:	e8 35 f4 ff ff       	call   801075d7 <p2v>
801081a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801081a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081a8:	89 04 24             	mov    %eax,(%esp)
801081ab:	e8 99 a8 ff ff       	call   80102a49 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801081b0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801081b4:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801081bb:	76 af                	jbe    8010816c <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801081bd:	8b 45 08             	mov    0x8(%ebp),%eax
801081c0:	89 04 24             	mov    %eax,(%esp)
801081c3:	e8 81 a8 ff ff       	call   80102a49 <kfree>
}
801081c8:	c9                   	leave  
801081c9:	c3                   	ret    

801081ca <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801081ca:	55                   	push   %ebp
801081cb:	89 e5                	mov    %esp,%ebp
801081cd:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801081d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801081d7:	00 
801081d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801081db:	89 44 24 04          	mov    %eax,0x4(%esp)
801081df:	8b 45 08             	mov    0x8(%ebp),%eax
801081e2:	89 04 24             	mov    %eax,(%esp)
801081e5:	e8 ac f8 ff ff       	call   80107a96 <walkpgdir>
801081ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801081ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801081f1:	75 0c                	jne    801081ff <clearpteu+0x35>
    panic("clearpteu");
801081f3:	c7 04 24 30 8d 10 80 	movl   $0x80108d30,(%esp)
801081fa:	e8 3b 83 ff ff       	call   8010053a <panic>
  *pte &= ~PTE_U;
801081ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108202:	8b 00                	mov    (%eax),%eax
80108204:	83 e0 fb             	and    $0xfffffffb,%eax
80108207:	89 c2                	mov    %eax,%edx
80108209:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010820c:	89 10                	mov    %edx,(%eax)
}
8010820e:	c9                   	leave  
8010820f:	c3                   	ret    

80108210 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108210:	55                   	push   %ebp
80108211:	89 e5                	mov    %esp,%ebp
80108213:	53                   	push   %ebx
80108214:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108217:	e8 b4 f9 ff ff       	call   80107bd0 <setupkvm>
8010821c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010821f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108223:	75 0a                	jne    8010822f <copyuvm+0x1f>
    return 0;
80108225:	b8 00 00 00 00       	mov    $0x0,%eax
8010822a:	e9 fd 00 00 00       	jmp    8010832c <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
8010822f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108236:	e9 d0 00 00 00       	jmp    8010830b <copyuvm+0xfb>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010823b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010823e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108245:	00 
80108246:	89 44 24 04          	mov    %eax,0x4(%esp)
8010824a:	8b 45 08             	mov    0x8(%ebp),%eax
8010824d:	89 04 24             	mov    %eax,(%esp)
80108250:	e8 41 f8 ff ff       	call   80107a96 <walkpgdir>
80108255:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108258:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010825c:	75 0c                	jne    8010826a <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
8010825e:	c7 04 24 3a 8d 10 80 	movl   $0x80108d3a,(%esp)
80108265:	e8 d0 82 ff ff       	call   8010053a <panic>
    if(!(*pte & PTE_P))
8010826a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010826d:	8b 00                	mov    (%eax),%eax
8010826f:	83 e0 01             	and    $0x1,%eax
80108272:	85 c0                	test   %eax,%eax
80108274:	75 0c                	jne    80108282 <copyuvm+0x72>
      panic("copyuvm: page not present");
80108276:	c7 04 24 54 8d 10 80 	movl   $0x80108d54,(%esp)
8010827d:	e8 b8 82 ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
80108282:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108285:	8b 00                	mov    (%eax),%eax
80108287:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010828c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010828f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108292:	8b 00                	mov    (%eax),%eax
80108294:	25 ff 0f 00 00       	and    $0xfff,%eax
80108299:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010829c:	e8 41 a8 ff ff       	call   80102ae2 <kalloc>
801082a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
801082a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801082a8:	75 02                	jne    801082ac <copyuvm+0x9c>
      goto bad;
801082aa:	eb 70                	jmp    8010831c <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
801082ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082af:	89 04 24             	mov    %eax,(%esp)
801082b2:	e8 20 f3 ff ff       	call   801075d7 <p2v>
801082b7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082be:	00 
801082bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801082c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801082c6:	89 04 24             	mov    %eax,(%esp)
801082c9:	e8 66 ce ff ff       	call   80105134 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
801082ce:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801082d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801082d4:	89 04 24             	mov    %eax,(%esp)
801082d7:	e8 ee f2 ff ff       	call   801075ca <v2p>
801082dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801082df:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801082e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
801082e7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082ee:	00 
801082ef:	89 54 24 04          	mov    %edx,0x4(%esp)
801082f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082f6:	89 04 24             	mov    %eax,(%esp)
801082f9:	e8 3a f8 ff ff       	call   80107b38 <mappages>
801082fe:	85 c0                	test   %eax,%eax
80108300:	79 02                	jns    80108304 <copyuvm+0xf4>
      goto bad;
80108302:	eb 18                	jmp    8010831c <copyuvm+0x10c>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108304:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010830b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010830e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108311:	0f 82 24 ff ff ff    	jb     8010823b <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108317:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010831a:	eb 10                	jmp    8010832c <copyuvm+0x11c>

bad:
  freevm(d);
8010831c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010831f:	89 04 24             	mov    %eax,(%esp)
80108322:	e8 09 fe ff ff       	call   80108130 <freevm>
  return 0;
80108327:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010832c:	83 c4 44             	add    $0x44,%esp
8010832f:	5b                   	pop    %ebx
80108330:	5d                   	pop    %ebp
80108331:	c3                   	ret    

80108332 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108332:	55                   	push   %ebp
80108333:	89 e5                	mov    %esp,%ebp
80108335:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108338:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010833f:	00 
80108340:	8b 45 0c             	mov    0xc(%ebp),%eax
80108343:	89 44 24 04          	mov    %eax,0x4(%esp)
80108347:	8b 45 08             	mov    0x8(%ebp),%eax
8010834a:	89 04 24             	mov    %eax,(%esp)
8010834d:	e8 44 f7 ff ff       	call   80107a96 <walkpgdir>
80108352:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108355:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108358:	8b 00                	mov    (%eax),%eax
8010835a:	83 e0 01             	and    $0x1,%eax
8010835d:	85 c0                	test   %eax,%eax
8010835f:	75 07                	jne    80108368 <uva2ka+0x36>
    return 0;
80108361:	b8 00 00 00 00       	mov    $0x0,%eax
80108366:	eb 25                	jmp    8010838d <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108368:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010836b:	8b 00                	mov    (%eax),%eax
8010836d:	83 e0 04             	and    $0x4,%eax
80108370:	85 c0                	test   %eax,%eax
80108372:	75 07                	jne    8010837b <uva2ka+0x49>
    return 0;
80108374:	b8 00 00 00 00       	mov    $0x0,%eax
80108379:	eb 12                	jmp    8010838d <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
8010837b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010837e:	8b 00                	mov    (%eax),%eax
80108380:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108385:	89 04 24             	mov    %eax,(%esp)
80108388:	e8 4a f2 ff ff       	call   801075d7 <p2v>
}
8010838d:	c9                   	leave  
8010838e:	c3                   	ret    

8010838f <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010838f:	55                   	push   %ebp
80108390:	89 e5                	mov    %esp,%ebp
80108392:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108395:	8b 45 10             	mov    0x10(%ebp),%eax
80108398:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010839b:	e9 87 00 00 00       	jmp    80108427 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
801083a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801083a3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801083ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801083b2:	8b 45 08             	mov    0x8(%ebp),%eax
801083b5:	89 04 24             	mov    %eax,(%esp)
801083b8:	e8 75 ff ff ff       	call   80108332 <uva2ka>
801083bd:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801083c0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801083c4:	75 07                	jne    801083cd <copyout+0x3e>
      return -1;
801083c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801083cb:	eb 69                	jmp    80108436 <copyout+0xa7>
    n = PGSIZE - (va - va0);
801083cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801083d0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801083d3:	29 c2                	sub    %eax,%edx
801083d5:	89 d0                	mov    %edx,%eax
801083d7:	05 00 10 00 00       	add    $0x1000,%eax
801083dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801083df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083e2:	3b 45 14             	cmp    0x14(%ebp),%eax
801083e5:	76 06                	jbe    801083ed <copyout+0x5e>
      n = len;
801083e7:	8b 45 14             	mov    0x14(%ebp),%eax
801083ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801083ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083f0:	8b 55 0c             	mov    0xc(%ebp),%edx
801083f3:	29 c2                	sub    %eax,%edx
801083f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083f8:	01 c2                	add    %eax,%edx
801083fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083fd:	89 44 24 08          	mov    %eax,0x8(%esp)
80108401:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108404:	89 44 24 04          	mov    %eax,0x4(%esp)
80108408:	89 14 24             	mov    %edx,(%esp)
8010840b:	e8 24 cd ff ff       	call   80105134 <memmove>
    len -= n;
80108410:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108413:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108416:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108419:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010841c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010841f:	05 00 10 00 00       	add    $0x1000,%eax
80108424:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108427:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010842b:	0f 85 6f ff ff ff    	jne    801083a0 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108431:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108436:	c9                   	leave  
80108437:	c3                   	ret    

80108438 <pageFault>:

#define nextIndex(x) ((x+1) %2)

void pageFault(uint *va){
80108438:	55                   	push   %ebp
80108439:	89 e5                	mov    %esp,%ebp
8010843b:	83 ec 38             	sub    $0x38,%esp
 
  pte_t *pte, *kpte;
 // void * m;
  uint *oldVa1, *oldVa2;

      oldVa1 =cpu->tlb[cpu->tlbIndex];
8010843e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108444:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010844b:	8b 92 c8 00 00 00    	mov    0xc8(%edx),%edx
80108451:	83 c2 30             	add    $0x30,%edx
80108454:	8b 04 90             	mov    (%eax,%edx,4),%eax
80108457:	89 45 f4             	mov    %eax,-0xc(%ebp)
      oldVa2 =cpu->tlb[(cpu->tlbIndex+1)% TLBSZ];
8010845a:	65 8b 0d 00 00 00 00 	mov    %gs:0x0,%ecx
80108461:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108467:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
8010846d:	8d 50 01             	lea    0x1(%eax),%edx
80108470:	89 d0                	mov    %edx,%eax
80108472:	c1 f8 1f             	sar    $0x1f,%eax
80108475:	c1 e8 1f             	shr    $0x1f,%eax
80108478:	01 c2                	add    %eax,%edx
8010847a:	83 e2 01             	and    $0x1,%edx
8010847d:	29 c2                	sub    %eax,%edx
8010847f:	89 d0                	mov    %edx,%eax
80108481:	83 c0 30             	add    $0x30,%eax
80108484:	8b 04 81             	mov    (%ecx,%eax,4),%eax
80108487:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf( "%p %p\n",oldVa1,oldVa2);

      if (oldVa1 != 0 ){
8010848a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010848e:	0f 84 ad 00 00 00    	je     80108541 <pageFault+0x109>
        
        pte = walkpgdir( cpu->kpgdir, (void *) oldVa1, 0);
80108494:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010849a:	8b 40 04             	mov    0x4(%eax),%eax
8010849d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801084a4:	00 
801084a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084a8:	89 54 24 04          	mov    %edx,0x4(%esp)
801084ac:	89 04 24             	mov    %eax,(%esp)
801084af:	e8 e2 f5 ff ff       	call   80107a96 <walkpgdir>
801084b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
        *pte=0;
801084b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084ba:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        cpu->tlb[cpu->tlbIndex]=0;
801084c0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801084c6:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801084cd:	8b 92 c8 00 00 00    	mov    0xc8(%edx),%edx
801084d3:	83 c2 30             	add    $0x30,%edx
801084d6:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)

        if ( PDX(oldVa2)!= PDX(oldVa1) ){
801084dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084e0:	c1 e8 16             	shr    $0x16,%eax
801084e3:	89 c2                	mov    %eax,%edx
801084e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e8:	c1 e8 16             	shr    $0x16,%eax
801084eb:	39 c2                	cmp    %eax,%edx
801084ed:	74 52                	je     80108541 <pageFault+0x109>
            // cprintf("here1");
            kpte= cpu->kpgdir +PDX(oldVa1);
801084ef:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801084f5:	8b 40 04             	mov    0x4(%eax),%eax
801084f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084fb:	c1 ea 16             	shr    $0x16,%edx
801084fe:	c1 e2 02             	shl    $0x2,%edx
80108501:	01 d0                	add    %edx,%eax
80108503:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (kpte && (*kpte & PTE_P)){
80108506:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010850a:	74 35                	je     80108541 <pageFault+0x109>
8010850c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010850f:	8b 00                	mov    (%eax),%eax
80108511:	83 e0 01             	and    $0x1,%eax
80108514:	85 c0                	test   %eax,%eax
80108516:	74 29                	je     80108541 <pageFault+0x109>
                char * v = p2v(PTE_ADDR(*kpte));                
80108518:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010851b:	8b 00                	mov    (%eax),%eax
8010851d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108522:	89 04 24             	mov    %eax,(%esp)
80108525:	e8 ad f0 ff ff       	call   801075d7 <p2v>
8010852a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                kfree(v);
8010852d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108530:	89 04 24             	mov    %eax,(%esp)
80108533:	e8 11 a5 ff ff       	call   80102a49 <kfree>
                *kpte=0;  
80108538:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010853b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
            }
         }
      }

      pte  = walkpgdir( proc->pgdir, (void *) va, 0);
80108541:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108547:	8b 40 04             	mov    0x4(%eax),%eax
8010854a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108551:	00 
80108552:	8b 55 08             	mov    0x8(%ebp),%edx
80108555:	89 54 24 04          	mov    %edx,0x4(%esp)
80108559:	89 04 24             	mov    %eax,(%esp)
8010855c:	e8 35 f5 ff ff       	call   80107a96 <walkpgdir>
80108561:	89 45 ec             	mov    %eax,-0x14(%ebp)
      kpte = walkpgdir( cpu->kpgdir, (void *) va, 1);
80108564:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010856a:	8b 40 04             	mov    0x4(%eax),%eax
8010856d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80108574:	00 
80108575:	8b 55 08             	mov    0x8(%ebp),%edx
80108578:	89 54 24 04          	mov    %edx,0x4(%esp)
8010857c:	89 04 24             	mov    %eax,(%esp)
8010857f:	e8 12 f5 ff ff       	call   80107a96 <walkpgdir>
80108584:	89 45 e8             	mov    %eax,-0x18(%ebp)
        
      *kpte=*pte;
80108587:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010858a:	8b 10                	mov    (%eax),%edx
8010858c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010858f:	89 10                	mov    %edx,(%eax)

      cpu->tlb[cpu->tlbIndex]=va;
80108591:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108597:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010859e:	8b 92 c8 00 00 00    	mov    0xc8(%edx),%edx
801085a4:	8d 4a 30             	lea    0x30(%edx),%ecx
801085a7:	8b 55 08             	mov    0x8(%ebp),%edx
801085aa:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      cpu->tlbIndex= (cpu->tlbIndex+1)% TLBSZ;
801085ad:	65 8b 0d 00 00 00 00 	mov    %gs:0x0,%ecx
801085b4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801085ba:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
801085c0:	8d 50 01             	lea    0x1(%eax),%edx
801085c3:	89 d0                	mov    %edx,%eax
801085c5:	c1 f8 1f             	sar    $0x1f,%eax
801085c8:	c1 e8 1f             	shr    $0x1f,%eax
801085cb:	01 c2                	add    %eax,%edx
801085cd:	83 e2 01             	and    $0x1,%edx
801085d0:	29 c2                	sub    %eax,%edx
801085d2:	89 d0                	mov    %edx,%eax
801085d4:	89 81 c8 00 00 00    	mov    %eax,0xc8(%ecx)
            
        
}
801085da:	c9                   	leave  
801085db:	c3                   	ret    

801085dc <flushTLB>:

void flushTLB(){
801085dc:	55                   	push   %ebp
801085dd:	89 e5                	mov    %esp,%ebp
801085df:	83 ec 28             	sub    $0x28,%esp

    int i;
    for( i= 0 ; i< TLBSZ ; i++){
801085e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801085e9:	e9 88 00 00 00       	jmp    80108676 <flushTLB+0x9a>
      if (cpu->tlb[i]){
801085ee:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801085f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801085f7:	83 c2 30             	add    $0x30,%edx
801085fa:	8b 04 90             	mov    (%eax,%edx,4),%eax
801085fd:	85 c0                	test   %eax,%eax
801085ff:	74 71                	je     80108672 <flushTLB+0x96>
        pte_t *kpte= (cpu->kpgdir +PDX(cpu->tlb[i]));
80108601:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108607:	8b 50 04             	mov    0x4(%eax),%edx
8010860a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108610:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108613:	83 c1 30             	add    $0x30,%ecx
80108616:	8b 04 88             	mov    (%eax,%ecx,4),%eax
80108619:	c1 e8 16             	shr    $0x16,%eax
8010861c:	c1 e0 02             	shl    $0x2,%eax
8010861f:	01 d0                	add    %edx,%eax
80108621:	89 45 f0             	mov    %eax,-0x10(%ebp)

        if (kpte && (*kpte & PTE_P)){
80108624:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108628:	74 35                	je     8010865f <flushTLB+0x83>
8010862a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010862d:	8b 00                	mov    (%eax),%eax
8010862f:	83 e0 01             	and    $0x1,%eax
80108632:	85 c0                	test   %eax,%eax
80108634:	74 29                	je     8010865f <flushTLB+0x83>
            char * v = p2v( PTE_ADDR(*kpte) );           
80108636:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108639:	8b 00                	mov    (%eax),%eax
8010863b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108640:	89 04 24             	mov    %eax,(%esp)
80108643:	e8 8f ef ff ff       	call   801075d7 <p2v>
80108648:	89 45 ec             	mov    %eax,-0x14(%ebp)
            kfree(v);
8010864b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010864e:	89 04 24             	mov    %eax,(%esp)
80108651:	e8 f3 a3 ff ff       	call   80102a49 <kfree>
             *kpte=0;   
80108656:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108659:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        }
        cpu->tlb[i]=0;
8010865f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108665:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108668:	83 c2 30             	add    $0x30,%edx
8010866b:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
}

void flushTLB(){

    int i;
    for( i= 0 ; i< TLBSZ ; i++){
80108672:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108676:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010867a:	0f 8e 6e ff ff ff    	jle    801085ee <flushTLB+0x12>
      }
     
    

    }
    memset(cpu->kpgdir, 0, PGSIZE/2);
80108680:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108686:	8b 40 04             	mov    0x4(%eax),%eax
80108689:	c7 44 24 08 00 08 00 	movl   $0x800,0x8(%esp)
80108690:	00 
80108691:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108698:	00 
80108699:	89 04 24             	mov    %eax,(%esp)
8010869c:	e8 c4 c9 ff ff       	call   80105065 <memset>
}
801086a1:	c9                   	leave  
801086a2:	c3                   	ret    
