#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <math.h>

#define MAX 10

typedef struct {//色管理用の構造体
  int red;
  int green;
  int blue;
} Color;

typedef struct {//画像管理用の構造体
  int width;
  int heght;
  Color **data;
} Image;


void fill_white_canvas(Image image){//キャンバスを白に
  int i,j;
  Color white = {255,255,255};
  //Color green = {128,255};
  for(i=0;i<image.width;i++){
    for(j=0;j<image.heght;j++){
      image.data[i][j] = white;
      //data.data[i][j].blue = j * 4; //グラデーション(未使用)
    }
  }
}

void save_file(Image image){//保存
  FILE *fp;
  if ((fp = fopen("img_x4.ppm", "w")) != NULL){
    fputs("P3\n",fp);//P3モード
    fprintf(fp,"%d %d\n",image.width,image.heght);//サイズ
    fputs("255\n",fp);//最大輝度
    
    int i,j;
    for(i=0;i<image.heght;i++){
      for(j=0;j<image.width;j++){
        fprintf(fp,"%d %d %d\n",image.data[i][j].red,image.data[i][j].green,image.data[i][j].blue);
      }
    }
    
    fclose(fp);
  }
}

Color **make_data(int width, int heght){//メモリ確保
    int i;
    Color **data;
    data = (Color **)malloc(sizeof(Color *) * width);
    for(i=0;i<width;i++) data[i] = (Color *)malloc(sizeof(Color) * heght);
    return data;
}

void draw_line(Image image, int x1, int y1, int x2, int y2, Color linecolor){//線描画
  int i;
  int x = x1,y = y1;

  int dx = abs(x2 - x1);
  int dy = abs(y2 - y1);
  if (dx == 0 && dy == 0) {//そもそも線じゃない,
    return;
  }
  int sx = (x1 < x2) ? 1 : -1;//stepx
  int sy = (y1 < y2) ? 1 : -1;//stepy
  image.data[y][x] = linecolor;//始点を着色
  int dx2 = dx * 2;
  int dy2 = dy * 2;

  if (dy <= dx) {
    int j = -dx;
    for (i = 0; i <= dx; i++) {
      if(
        x >= image.width || x < 0 ||
        y >= image.heght || y < 0 )return;//範囲外で終了
      image.data[y][x] = linecolor;//着色
      x += sx;
      j += dy2;
      if (0 <= j) {
        y += sy;
        j -= dx2;
      }
    }
  } else {
    int j = -dy;
    for (i = 0; i <= dy; i++) {
      if(
        x >= image.width || x < 0 ||
        y >= image.heght || y < 0 )return;//範囲外で終了
      image.data[y][x] = linecolor;
      y += sy;
      j += dx2;
      if (0 <= j) {
        x += sx;
        j -= dy2;
      }
    }
  }
}

void draw_rect(Image image, int x1, int y1, int x2, int y2, Color linecolor){//矩形
  draw_line(image,x1,y1,x1,y2,linecolor);
  draw_line(image,x1,y1,x2,y1,linecolor);
  draw_line(image,x2,y1,x2,y2,linecolor);
  draw_line(image,x1,y2,x2,y2,linecolor);
}
	
void draw_quad(Image image, int x1, int y1, int x2, int y2, int x3, int y3, int x4, int y4, Color linecolor){//四角形
  draw_line(image,x1,y1,x2,y2,linecolor);
  draw_line(image,x2,y2,x3,y3,linecolor);
  draw_line(image,x3,y3,x4,y4,linecolor);
  draw_line(image,x4,y4,x1,y1,linecolor);
}	

void draw_circle(Image image, int cx, int cy,int extent, Color linecolor){//円描画
  double r;
  for(r=0.0;r<2*M_PI;r+=M_1_PI/10000.0){
    double y = sin(r)*extent;
    double x = cos(r)*extent;
    image.data[(int)round(cy+y)][(int)round(cx+x)] = linecolor;
  }
}

void draw_sinewave(Image image, int x1, int y1, int x2, int y2, int extent,double freq,Color linecolor){//正弦
  int dx = abs(x2 - x1);
  int dy = abs(y2 - y1);
  int sx = (x1 < x2) ? 1 : -1;
  int sy = (y1 < y2) ? 1 : -1;
  int x,y;
  int tx = x1,ty = y1;
  for(x=0;x<=dx;x+=sx){
    y = (double)sin(freq*((double)x/dx))*extent + y1;
    draw_line(image,tx,ty,x+x1,y,linecolor);
    tx = x+x1;
    ty = y;
  }
}

void fill_bucket_s(Image image,int x,int y, Color color, Color targetcolor){//塗り潰し本体
  image.data[y][x]=color;
  if(image.width > x+1){
    if(image.data[y][x+1].red==targetcolor.red &&
        image.data[y][x+1].green==targetcolor.green &&
        image.data[y][x+1].blue==targetcolor.blue ){
      fill_bucket_s(image,x+1,y,color,targetcolor);
    }
  }
  if(image.heght > y+1){
    if(image.data[y+1][x].red==targetcolor.red &&
        image.data[y+1][x].green==targetcolor.green &&
        image.data[y+1][x].blue==targetcolor.blue ){
      fill_bucket_s(image,x,y+1,color,targetcolor);
    }
  }
  if(0 <= x-1){
    if(image.data[y][x-1].red==targetcolor.red &&
        image.data[y][x-1].green==targetcolor.green &&
        image.data[y][x-1].blue==targetcolor.blue ){
      fill_bucket_s(image,x-1,y,color,targetcolor);
    }
  }
  if(0 <= y-1){
    if(image.data[y-1][x].red==targetcolor.red &&
        image.data[y-1][x].green==targetcolor.green &&
        image.data[y-1][x].blue==targetcolor.blue ){
      fill_bucket_s(image,x,y-1,color,targetcolor);
    }
  }
}

void fill_bucket(Image image,int x,int y, Color color){//塗り潰し
  if(image.data[y][x].red==color.red &&
      image.data[y][x].green==color.green &&
      image.data[y][x].blue==color.blue )return;
  Color targetcolor = image.data[y][x];
  fill_bucket_s(image,x,y,color,targetcolor);
}

void fill_rect(Image image, int x1, int y1, int x2, int y2, Color color){//
  draw_line(image,x1,y1,x1,y2,color);
  draw_line(image,x1,y1,x2,y1,color);
  draw_line(image,x2,y1,x2,y2,color);
  draw_line(image,x1,y2,x2,y2,color);
  int cx = (x1+x2)/2;
  int cy = (y1+y2)/2;
  fill_bucket(image,cx,cy, color);
}

void fill_quad(Image image, int x1, int y1, int x2, int y2, int x3, int y3, int x4, int y4, Color color){
  draw_line(image,x1,y1,x2,y2,color);
  draw_line(image,x2,y2,x3,y3,color);
  draw_line(image,x3,y3,x4,y4,color);
  draw_line(image,x4,y4,x1,y1,color);
  int cx = (x1+x2+x3+x4)/4;
  int cy = (y1+y2+y3+y4)/4;
  fill_bucket(image,cx,cy, color);
}

void fill_circle(Image image, int cx, int cy,int extent, Color color){
  double r;
  for(r=0.0;r<2*M_PI;r+=M_1_PI/10000.0){
    double y = sin(r)*extent;
    double x = cos(r)*extent;
    image.data[(int)round(cy+y)][(int)round(cx+x)] = color;
  }
  fill_bucket(image,cx,cy, color);
}

void replace_color(Image image, Color replace_col, Color color){//色置き換え
  int i,j;
  for(i=0;i<image.width;i++){
    for(j=0;j<image.heght;j++){
      if(image.data[i][j].red==replace_col.red &&
          image.data[i][j].green==replace_col.green&&
          image.data[i][j].blue==replace_col.blue)
      {
        image.data[i][j] = color;
      }
    }
  }
}

int main(void){
  int width = 400;
  int heght = 400;
  Image ppm = {width,heght,make_data(width, heght)};

  fill_white_canvas(ppm);
  
  Color white = {255,255,255},
        black = {0,0,0},
        red = {255,64,0},
        green = {128,255,0},
        blue = {0,128,255},
        yellow = {255,224,0},
        darkblue = {32,64,128};
	//円描画
  draw_circle(ppm,200,200,172,black);
  fill_bucket(ppm,196,196,darkblue);

	//赤の部分
  draw_sinewave(ppm,108,100,208,100,-16,M_PI,black);
  draw_sinewave(ppm,92,196,192,196,-16,M_PI,black);
  draw_line(ppm,108,100,92,196,black);
  draw_line(ppm,208,100,192,196,black);
  fill_bucket(ppm,140,140,red);

	//緑の部分
  draw_sinewave(ppm,220,104,324,104,16,M_PI,black);
  draw_sinewave(ppm,204,200,308,200,16,M_PI,black);
  draw_line(ppm,220,104,204,200,black);
  draw_line(ppm,324,104,308,200,black);
  fill_bucket(ppm,240,140,green);

	//青の部分
  draw_sinewave(ppm,90,208,190,208,-16,M_PI,black);
  draw_sinewave(ppm,74,304,174,304,-16,M_PI,black);
  draw_line(ppm,90,208,74,304,black);
  draw_line(ppm,190,208,174,304,black);
  fill_bucket(ppm,140,240,blue);

	//黄色の部分
  draw_sinewave(ppm,202,212,306,212,16,M_PI,black);
  draw_sinewave(ppm,186,308,290,308,16,M_PI,black);
  draw_line(ppm,202,212,186,308,black);
  draw_line(ppm,306,212,290,308,black);
  fill_bucket(ppm,240,240,yellow);

  save_file(ppm);//保存
  return 0;
}
