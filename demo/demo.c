struct node {
  struct node *prev;
  struct node *next;
};

int valid(struct node* n)
{
  return n->next && n->next->prev == n &&
         n->prev && n->prev->next == n;
}

int is_cyclic(struct node* n)
{
  struct node* next = n;
  do {
    next = next->next;
  } while (next && next != n);
  return next == n;
}

