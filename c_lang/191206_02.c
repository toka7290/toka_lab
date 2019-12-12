#include <stdio.h>

typedef struct _data{		
  char name[6];
  int point;
} Data;

int read_data(char *filename,Data *data);

int main(void){
  Data data[200];
  int i,sum=0,num = 0;
  double ave = 0.0;
  num = read_data("data.txt",data);
  for(i=0;i<num;i++){
    sum += data[i].point;
  }
  ave = (double)sum/num;

  printf("ave=%6.2lf\n",ave);
  return 0;
}

int read_data(char *filename, Data *data){
  char dummy[10];
  int num = 0;
  FILE *fp;
  fp = fopen(filename, "r");
  if(fp==NULL){
    fprintf(stderr,"file open error!");
    return -1;
  }
  fscanf(fp, "%s %s", dummy, dummy);
  while(fscanf( fp, "%s %d", data[num].name, &data[num].point) != EOF){
    printf("[%3d] %s : %3d\n", num+1, data[num].name, data[num].point);
    num++;
  }
  fclose(fp);
  return num;
}
