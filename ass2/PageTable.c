// PageTable.c ... implementation of Page Table operations
// COMP1521 17s2 Assignment 2
// Written by John Shepherd, September 2017
// Modified by Lean Lynn Oh

#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include "Memory.h"
#include "Stats.h"
#include "PageTable.h"

// Symbolic constants

#define NOT_USED 0
#define IN_MEMORY 1
#define ON_DISK 2

// PTE = Page Table Entry


// typedef struct Node {
  
//   int pageNum;
//   struct Node *next;
//   struct Node *prev;

// }Node;

typedef struct listRep {
 struct PTE *head;
 struct PTE *tail;
}listRep;

typedef struct PTE{
   char status;      // NOT_USED, IN_MEMORY, ON_DISK
   char modified;    // boolean: changed since loaded
   int  frame;       // memory frame holding this page
   int  accessTime;  // clock tick for last access
   int  loadTime;    // clock tick for last time loaded
   int  nPeeks;      // total number times this page read
   int  nPokes;      // total number times this page modified  
   struct PTE *next;
   struct PTE *prev;
   int pageNum;
   // TODO: add more fields here, if needed ...
} PTE;



// The virtual address space of the process is managed
//  by an array of Page Table Entries (PTEs)
// The Page Table is not directly accessible outside
//  this file (hence the static declaration)

static PTE *PageTable;      // array of page table entries
static int  nPages;         // # entries in page table
static int  replacePolicy;  // how to do page replacement
static int  fifoList;       // index of first PTE in FIFO list
static int  fifoLast;       // index of last PTE in FIFO list
static listRep *L;
// Forward refs for private functions

static int findVictim(int);
static void newList();

// initPageTable: create/initialise Page Table data structures

void initPageTable(int policy, int np)
{
   PageTable = malloc(np * sizeof(PTE));
   if (PageTable == NULL) {
      fprintf(stderr, "Can't initialise Memory\n");
      exit(EXIT_FAILURE);
   }

   newList();
   replacePolicy = policy;
   nPages = np;
   fifoList = 0;
   fifoLast = nPages-1;
   
   for (int i = 0; i < nPages; i++) {
      PTE *p = &PageTable[i];
      p->status = NOT_USED;
      p->modified = 0;
      p->frame = NONE;
      p->accessTime = NONE;
      p->loadTime = NONE;
      p->nPeeks = p->nPokes = 0;
      p->next = NULL;
      p->prev = NULL;
      p->pageNum = 0;

   }
}

//create list
void newList()
{
   L = malloc(sizeof(struct listRep));
   assert(L != NULL);
   L->head = NULL;
   L->tail = NULL;
   
}

// requestPage: request access to page pno in mode
// returns memory frame holding this page
// page may have to be loaded
// PTE(status,modified,frame,accessTime,nextPage,nPeeks,nWrites)

int requestPage(int pno, char mode, int time)
{
   if (pno < 0 || pno >= nPages) {
      fprintf(stderr,"Invalid page reference\n");
      exit(EXIT_FAILURE);
   }

   PTE *p = &PageTable[pno];
   int fno; // frame number
   switch (p->status) {
   case NOT_USED:
   case ON_DISK:
      countPageFault(); // count page fault
      fno = findFreeFrame();
      if (fno == NONE) {
         int vno = findVictim(time);
#ifdef DBUG
         printf("Evict page %d\n",vno);
#endif
         // TODO:
         // if victim page modified, save its frame
         // collect frame# (fno) for victim page
         // update PTE for victim page
         // - new status
         // - no longer modified
         // - no frame mapping
         // - not accessed, not loaded
		 
      	PTE *v = &PageTable[vno];
		if(v->modified != 0)
		 	saveFrame(v->frame);
	    v->status = ON_DISK;
        fno = v->frame;
        v->modified = 0;
        v->frame = NONE;
        v->accessTime = NONE;
        v->loadTime = NONE;  
      }
      printf("Page %d given frame %d\n",pno,fno);

      //append to the list 
      if (L->head == NULL){
        p->pageNum = pno;
        p->next = NULL;
        p->prev = NULL;
        L->head = L->tail = p;
        fifoList = pno;

      }else{
        p->pageNum = pno;
        p->next = NULL;
        p->prev = L->tail;
        L->tail->next = p;
        L->tail = p;
        fifoLast = pno;

      }

      //PTE *curr;
	  // for (curr = L->head; curr != NULL; curr = curr->next)
	  // 	printf("%d\n",curr->pageNum);

      // TODO:
      // load page pno into frame fno
      // update PTE for page
      // - new status
      // - not yet modified
      // - associated with frame fno
      // - just loaded
    
      loadFrame(fno, pno, time);
      p->status = IN_MEMORY;
      p->frame = fno;
      p->loadTime = time;
      p->pageNum = pno;


      break;
   case IN_MEMORY:
      
      if(replacePolicy == REPL_LRU){
        // more than one node in list
        if(p == L->head &&  L->head->next != NULL){
        	//in front of the list
            fifoList = p->next->pageNum;
            L->head = p->next;
            p->next->prev = NULL;
            p->next = NULL;
            p->prev = L->tail;
            L->tail->next = p;
            L->tail = p;
      
         }else if(p->next != NULL && p->prev != NULL){
         	// in the middle of the list
            p->prev->next = p->next;
            p->next->prev = p->prev;
            fifoList = p->next->pageNum;
            p->next = NULL;
            p->prev = L->tail;
            L->tail->next = p;
            L->tail = p; 
         }

         fifoLast = pno;
      }
   	
   	  //count hits
      countPageHit();
      break;
   default:
      fprintf(stderr,"Invalid page status\n");
      exit(EXIT_FAILURE);
   }

   if (mode == 'r')
      p->nPeeks++;
   else if (mode == 'w') {
      p->nPokes++;
      p->modified = 1;
   }
   p->accessTime = time;
   return p->frame;
}

//remove the first node from the list 
int find_victim(){
	int vic = L->head->pageNum;
	PTE *tmp; 
	tmp = L->head;
	L->head = L->head->next;
	L->head->prev = NULL;
	tmp->next = NULL;
	tmp->prev = NULL;
    fifoList = L->head->pageNum;
	return vic;
}

// findVictim: find a page to be replaced
// uses the configured replacement policy
static int findVictim(int time)
{
   int victim = 0;
   switch (replacePolicy) {
   case REPL_LRU:
      // TODO: implement LRU strategy
    	victim = find_victim();
    
      break;
   case REPL_FIFO:
      // TODO: implement FIFO strategy
	    victim = find_victim(); 
	    
      break;
   case REPL_CLOCK:
      return 0;
   }
   return victim;
}

// showPageTableStatus: dump page table
// PTE(status,modified,frame,accessTime,nextPage,nPeeks,nWrites)

void showPageTableStatus(void)
{
	
   char *s;
   printf("%4s %6s %4s %6s %7s %7s %7s %7s\n",
          "Page","Status","Mod?","Frame","Acc(t)","Load(t)","#Peeks","#Pokes");
   for (int i = 0; i < nPages; i++) {
      PTE *p = &PageTable[i];
      printf("[%02d]", i);
      switch (p->status) {
      case NOT_USED:  s = "-"; break;
      case IN_MEMORY: s = "mem"; break;
      case ON_DISK:   s = "disk"; break;
      }
      printf(" %6s", s);
      printf(" %4s", p->modified ? "yes" : "no");
      if (p->frame == NONE)
         printf(" %6s", "-");
      else
         printf(" %6d", p->frame);
      if (p->accessTime == NONE)
         printf(" %7s", "-");
      else
         printf(" %7d", p->accessTime);
      if (p->loadTime == NONE)
         printf(" %7s", "-");
      else
         printf(" %7d", p->loadTime);
      printf(" %7d", p->nPeeks);
      printf(" %7d", p->nPokes);
      printf("\n");
   }
}
