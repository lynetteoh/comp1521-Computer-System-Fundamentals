// ADT for a FIFO queue
// COMP1521 17s2 Week01 Lab Exercise
// Written by John Shepherd, July 2017
// Modified by Lean Lynn Oh

#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include "Queue.h"

typedef struct QueueNode {
   int jobid;  // unique job ID
   int size;   // size/duration of job
   struct QueueNode *next;
} QueueNode;

struct QueueRep {
   int nitems;      // # of nodes
   QueueNode *head; // first node
   QueueNode *tail; // last node
};


static
QueueNode *makeQueueNode(int id, int size)
{
   QueueNode *new;
   new = malloc(sizeof(struct QueueNode));
   assert(new != NULL);
   new->jobid = id;
   new->size = size;
   new->next = NULL;
   return new;
}




// make a new empty Queue
Queue makeQueue()
{
   Queue new;
   new = malloc(sizeof(struct QueueRep));
   assert(new != NULL);
   new->nitems = 0; new->head = new->tail = NULL;
   return new;
}

// release space used by Queue
void  freeQueue(Queue q)
{
   assert(q != NULL);
   QueueNode *curr = q->head, *temp;
   while(curr != NULL){
	temp = curr;
   	curr = curr->next;
	free(temp);
   }
   free(q);
}

// add a new item to tail of Queue
void  enterQueue(Queue q, int id, int size)
{
   assert(q != NULL);
   QueueNode *new = makeQueueNode(id, size);
   if(q->head == NULL)
	  q->head = new;
   else
	  q->tail->next = new;
   q->tail = new;
   q->nitems++;

}

// remove item on head of Queue
int   leaveQueue(Queue q)
{
   assert(q != NULL);
   QueueNode *curr;
   int jobid = 0;
   if(q->nitems == 0)
	  return 0;
   
   curr = q->head;
   jobid = curr->jobid;	
   q->head = q->head->next;
   free(curr);
   q->nitems--;
   return jobid; // replace this statement
}

// count # items in Queue
int   lengthQueue(Queue q)
{
   assert(q != NULL);
   return q->nitems;
}

// return total size in all Queue items
int   volumeQueue(Queue q)
{
   assert(q != NULL);
   if(q->nitems == 0)
	  return 0;

   QueueNode *curr;
   int sum = 0;
   for (curr = q->head; curr != NULL; curr = curr->next){
	sum +=curr->size;
   }
   return sum; // replace this statement
}

// return size/duration of first job in Queue
int   nextDurationQueue(Queue q)
{
   assert(q != NULL);
   if(q->nitems == 0)
	  return 0;
   return (q->head->size); // replace this statement
}


// display jobid's in Queue
void showQueue(Queue q)
{
   QueueNode *curr;
   curr = q->head;
   while (curr != NULL) {
      printf(" (%d,%d)", curr->jobid, curr->size);
      curr = curr->next;
   }
}
