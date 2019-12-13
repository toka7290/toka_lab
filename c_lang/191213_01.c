#include <stdio.h>
#include <stdlib.h>
#include <string.h>//必要！！

typedef struct _node {
  char name[6];
  int point;
  struct _node *next;
} NODE; 

void print_all_node( NODE * top );
int get_data( char *fname, NODE *top );
NODE *append_node(NODE * tail, char * name, int data);
void print_name(NODE * top,int point);
int search_min(NODE * top);
int search_max(NODE * top);

int main(int argc, char * argv[])
{
  if(argc != 2){
    fprintf(stderr, "usage: %s [data-file]¥n", argv[0]);
    return -1;
  }
  int num;
  NODE top;
  top.next = NULL;
  num = get_data( argv[1], &top );

  if( num > 0 ){
    int point;//点数を一時的に格納
    print_all_node(&top);
    point = search_min(&top);
    print_name(&top, point);
    point = search_max(&top);
    print_name(&top,point);
  }
  return 0;
}

int get_data(char * fname, NODE * top)
{
  FILE * fp = fopen( fname, "r" );
  if(fp == NULL){
    fprintf( stderr, "file [%s] open error!¥n", fname );
    return -1;
  }

  int num = 0, data;
  NODE *tail = top;
  char name[6];//別に[6]はいらないと思う
  char dummy[10];
  fscanf(fp, "%s %s", dummy, dummy);//一行目読み飛し
  while( fscanf( fp,"%s %d", name, &data ) != EOF ) {
    //printf("%s",name);//debug
    tail = append_node( tail, name, data );
    if(tail == NULL) break;
    num++;
  }
  fclose(fp);
  return num;
}

NODE *append_node(NODE * tail, char * name, int data)
{
  NODE * node;
  node = (NODE *) malloc( sizeof (NODE) );
  if(node == NULL) {
    fprintf( stderr, "error: cannot allocate memory!\n" );
    return NULL;
  }
  tail->next = node;

  strcpy(node->name, name);//node.nameにコピー。こいつが一番楽
  node->point = data;
  node->next = NULL;

  return node;
}

void print_name(NODE * top,int point_)
{//名前だけ印字
  NODE *node = top->next;
  while( node != NULL ){
    if(point_ == node->point){
      printf( "%s\n", node->name);
    }
    node = node->next;
  }
  return;
}

int search_min(NODE * top)
{//最低点数の洗い出し
  NODE *node = top->next;
  printf("#####################\n");
  int minpoint = 100;
  while( node != NULL ){
    if(minpoint > node->point)minpoint = node->point;
    node = node->next;
  }
  printf( "min point : %3d\n", minpoint);
  return minpoint;
}

int search_max(NODE * top)
{//最高点の検索
  NODE *node = top->next;
  printf("#####################\n");
  int maxpoint = 0;
  while( node != NULL ){
    if(maxpoint < node->point)maxpoint = node->point;
    node = node->next;
  }
  printf( "max point : %3d\n", maxpoint);
  return maxpoint;
}

void print_all_node(NODE * top)
{//全て表示
  NODE *node = top->next;
  while( node != NULL ){
    printf( "%s : %3d\n", node->name ,node->point );
    node = node->next;
  }
  return;
}
