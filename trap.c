#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "x86.h"
#include "traps.h"
#include "spinlock.h"

// Interrupt descriptor table (shared by all CPUs).
struct gatedesc idt[256];
extern uint vectors[];  // in vectors.S: array of 256 entry pointers
struct spinlock tickslock;
uint ticks;
extern void pageFault(uint *va);


void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
  
  initlock(&tickslock, "time");
}

void
idtinit(void)
{
  lidt(idt, sizeof(idt));
}

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(proc->killed)
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
  }
  
 uint *va;
 // char *mem;
 //  uint a;
  switch(tf->trapno){
 
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
    break;
  

  case T_PGFLT:


       va =(uint*) rcr2();
      
      if ((uint) va <= proc->sz){
          pte_t *pte, *kpte;
     // void * m;
      uint *oldVa1, *oldVa2;

          oldVa1 =cpu->tlb[cpu->tlbIndex];
          oldVa2 =cpu->tlb[(cpu->tlbIndex+1)% TLBSZ];
         // cprintf( "%p %p\n",oldVa1,oldVa2);

          if (oldVa1 != 0 ){
            
            pte = walkpgdir( cpu->kpgdir, (void *) oldVa1, 0);
            *pte=0;
            cpu->tlb[cpu->tlbIndex]=0;

            if ( PDX(oldVa2)!= PDX(oldVa1) ){
                // cprintf("here1");
                kpte= cpu->kpgdir +PDX(oldVa1);
                if (kpte && (*kpte & PTE_P)){
                    char * v = p2v(PTE_ADDR(*kpte));                
                    kfree(v);
                    *kpte=0;  
                }
             }
          }

          pte  = walkpgdir( proc->pgdir, (void *) va, 0);
          kpte = walkpgdir( cpu->kpgdir, (void *) va, 1);
            
          *kpte=*pte;

          cpu->tlb[cpu->tlbIndex]=va;
          cpu->tlbIndex= (cpu->tlbIndex+1)% TLBSZ;
            
        break;
      }else {

      }
      // a = PGROUNDDOWN(rcr2());
    
      // mem = kalloc();
      // memset(mem, 0, PGSIZE);
      // mappages(proc->pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
      
 
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
