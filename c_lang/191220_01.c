#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define LEVEL 21

typedef struct {
  char name[6];
  int point;
} Data;

typedef struct _node {
  Data data;
  struct _node * prev;
  struct _node * next;
} NODE; 

void print_all_node( NODE * top );
int get_data( char * fname, NODE * top );
NODE * append_node(NODE * tail, Data * data);
NODE * insert_node(NODE * prev, Data * data);
NODE * del_node(NODE * target );
void print_name(NODE * top, int point);
int search_min(NODE * top);
int search_max(NODE * top);
void append_max(NODE * top, int point_);
void delete_max(NODE * top, int point_);
void get_freq5(int * freq, NODE * top);
void show_hist(int * freq);
void free_node(NODE * top);


int main(int argc, char * argv[]){
  if(argc != 2){
    fprintf(stderr, "usage: %s [data-file]¥n", argv[0]);
    return -1;
  }
  int num;
  NODE top;
  top.next = NULL;
  num = get_data( argv[1], &top );

  if( num > 0 ){
    int point;
    /* 
    int freq[LEVEL] = {0};
    get_freq5(freq,&top);
    show_hist(freq);
    */
    point = search_min(&top);
    print_name(&top, point);
    point = search_max(&top);
    print_name(&top, point);
    delete_max(&top,point);
    print_all_node(&top);
  }
  free_node(&top);
  return 0;
}

int get_data(char * fname, NODE * top){//データ読み込み
  FILE * fp = fopen( fname, "r" );
  if(fp == NULL){
    fprintf( stderr, "file [%s] open error!¥n", fname );
    return -1;
  }

  int num = 0;
  Data data;
  NODE * tail = top;
  char dummy[10];
  fscanf(fp, "%s %s", dummy, dummy);
  while( fscanf( fp,"%s %d", data.name, &data.point ) != EOF ) {
    //printf("%s",name);
    tail = append_node( tail, &data );
    if(tail == NULL) break;
    num++;
  }

  fclose(fp);
  return num;
}

NODE * append_node(NODE * tail, Data * data){//tailは1つ前のnode
  NODE *  node;
  node = (NODE * ) malloc( sizeof (NODE) );
  if(node == NULL) {
    fprintf( stderr, "error: cannot allocate memory!\n" );
    return NULL;
  }
  tail->next = node;//tailの次はnode

  strcpy(node->data.name, data->name);//data入力
  node->data.point = data->point;//data入力
  node->next = NULL;//nodeの次はまだ作られていない
  node->prev = tail;//nodeの一つ前はtail

  return node;
}

NODE * insert_node(NODE * prev, Data * data){//未使用
  NODE * node = (NODE * ) malloc( sizeof (NODE) );
  if(node == NULL) {
    fprintf( stderr, "error: cannot allocate memory!\n" );
    return NULL;
  }
  node->next->prev = node;
  node->next = prev->next;
  prev->next = node;

  strcpy(node->data.name, data->name);
  node->data.point = data->point;
  node->prev = prev;

  return node;
}

NODE * del_node(NODE * target){//削除
  NODE * prev = target->prev;//targetの次のnode
  NODE * next = target->next;//targetの前のnode

  next->prev = prev;
  prev->next = next;
  free( target );

  return prev;
}

void get_freq5(int * freq, NODE * top){//未使用
  NODE * node = top->next;
  while( node != NULL ){
    freq[node->data.point/5]++;
    node = node->next;
  }
  return;
}

void show_hist(int * freq){//未使用
  int i,j;
  puts("#########################");
  for(i=0;i<LEVEL;i++){
    for(j=0;j<freq[i];j++){
      putc('* ',stdout);
    }
    putc('\n',stdout);
  }
  return;
}

void print_name(NODE * top,int point_){//point_と合致するnameを印字
  NODE * node = top->next;
  puts("-------------------------");
  while( node != NULL ){
    if(point_ == node->data.point){
      printf( "%s\n", node->data.name);
    }
    node = node->next;
  }
  puts("-------------------------");
  return;
}

void append_max(NODE * top,int point_){//最大得点の1つ後ろに"*max*"を追加
  NODE * node = top->next;
  while(node != NULL){
    if(point_ == node->data.point){
      Data max;
      strcpy(max.name,"* max* ");
      max.point = 111;
      node = insert_node(node,&max);
    }
    node = node->next;
  }
  return;
}

void delete_max(NODE * top,int point_){//pointと合致するnodeを削除
  NODE * node = top->next;
  while(node != NULL){
    if(point_ == node->data.point){
      node = del_node(node);
    }
    node = node->next;
  }
  return;
}

int search_min(NODE * top){//最低点を検索
  NODE * node = top->next;
  puts("#########################");
  int minpoint = 100;
  while(node != NULL){
    if(minpoint > node->data.point)minpoint = node->data.point;
    node = node->next;
  }
  printf( "min point : %3d\n", minpoint);
  return minpoint;
}

int search_max(NODE * top){//最高点を検索
  NODE * node = top->next;
  puts("#########################");
  int maxpoint = 0;
  while(node != NULL){
    if(maxpoint < node->data.point)maxpoint = node->data.point;
    node = node->next;
  }
  printf("max point : %3d\n", maxpoint);
  return maxpoint;
}

void print_all_node(NODE * top){//全てのnodeを印字
  NODE * node = top->next;
  while( node != NULL ){
    printf( "%s : %3d\n", node->data.name ,node->data.point );
    node = node->next;
  }
  return;
}

void free_node(NODE * top){//メモリ解放
  NODE * node = top->next;
  NODE * temp;
  while(node!=NULL){
    temp = node;
    node = node->next;
    free(temp);
  }
  return;
}
