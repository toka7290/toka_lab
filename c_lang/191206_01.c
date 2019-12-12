#include <stdio.h>

typedef struct _matrix{//_matrix は省略可
    int row;
    int col;
    int **data;
} Matrix;

int **read_matrix(char *filename,int *row,int *col);
int **make_matrix(int row,int col);
void sum_matrix(Matrix *matrix_a, Matrix *matrix_b, Matrix *matrix_res);
void sub_matrix(Matrix *matrix_a, Matrix *matrix_b, Matrix *matrix_res);
void ptint_matrix(Matrix *matrix);
void save_matrix(char *filename,Matrix *matrix);

int main(int argc, char *argv[]){
    if(argc != 5){//例外処理
        fprintf(stderr,"number of args is different\n");
        return -1;
    }
    Matrix a,b,c,d;
    a.data = read_matrix(argv[1],&a.row,&a.col);
    b.data = read_matrix(argv[2],&b.row,&b.col);
    if(a.row != b.row ||a.col != b.col){//例外処理
      fprintf(stderr,"size miss match\n");
      return -1;
    }
    c.data = make_matrix(a.row,a.col);
    c.row = a.row;//sum_matrix内で同一の処理をしているので省略可
    c.col = a.col;
    d.data = make_matrix(a.row,a.col);
    d.row = d.row;
    d.col = d.col;
    sum_matrix(&a,&b,&c);
    sub_matrix(&a,&b,&d);
    printf("[wa]\n");
    ptint_matrix(&c);
    printf("[sa]\n");
    ptint_matrix(&d);
    save_matrix(argv[3],&c);
    save_matrix(argv[4],&d);

    return 0;
}

int **read_matrix(char *filename,int *row,int *col){
    FILE *fp;
    int a;
    fp = fopen(filename, "r");
    if(fp==NULL){
        fprintf(stderr,"file open error!");
        return NULL;
    }
    fscanf(fp,"%d %d",row,col);

    int **data,i,j;
    data = make_matrix(*row,*col);
    for(i=0; i<*row; i++){
        for(j=0; j<*col; j++){
            fscanf(fp,"%d",&data[i][j]);
        }
    }
    fclose(fp);
    return data;
}

int **make_matrix(int row,int col){
    int i;
    int **matrix;
    matrix = (int **)malloc(sizeof(int *) * row);
    for(i=0;i<row;i++) matrix[i] = (int *)malloc(sizeof(int) * col);
    return matrix;
}

void ptint_matrix(Matrix *matrix){
    int i,j;
    for(i=0; i<matrix->row; i++){
        for(j=0; j<matrix->col; j++){
            printf(" %2d",matrix->data[i][j]);
        }
        printf("\n");
    }
    return ;
}

void save_matrix(char *filename,Matrix *matrix){
    FILE *fp;
    fp = fopen(filename,"w");
    int i,j;
    for(i=0; i<matrix->row; i++){
        for(j=0; j<matrix->col; j++){
            fprintf(fp,"%3d", matrix->data[i][j]);
        }
        fprintf(fp,"\n");
    }
    fclose(fp);
    return;
}


void sum_matrix(Matrix *matrix_a, Matrix *matrix_b, Matrix *matrix_res){
    int i,j;
    for(i=0; i<matrix_a->row; i++){
        for(j=0; j<matrix_a->col; j++){
            matrix_res->data[i][j]= matrix_a->data[i][j]+matrix_b->data[i][j];
        }
    }
    matrix_res->row = matrix_a->row;//main()内で処理しているのならば省略可
    matrix_res->col = matrix_a->col;
    return;
}

void sub_matrix(Matrix *matrix_a, Matrix *matrix_b, Matrix *matrix_res){
    int i,j;
    for(i=0; i<matrix_a->row; i++){
        for(j=0; j<matrix_a->col; j++){
            matrix_res->data[i][j] = matrix_a->data[i][j]-matrix_b->data[i][j];
        }
    }
    matrix_res->row = matrix_a->row;
    matrix_res->col = matrix_a->col;
    return ;
}
