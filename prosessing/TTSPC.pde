import processing.video.*;

//定数
final int max = 30;//親
final int cMax = 20;//子
final int gMax = 10;//孫
final String ftmovie = "movie",
             ftpict = "image", 
             ftpro = "program",
             fthide = "hide";//filetype
             
/*基本*/
Movie[] mov = new Movie[max];//動画
boolean[] isloop = new boolean[max];//動画がループするかどうか
PImage[] sec = new PImage[max];//画像
String[] name = new String[max];//ファイル名
String[] mode = new String[max];//モード切替
String[] ratio= new String[max];//比
String[] ftback = new String[max];//filetype
color[] BGRGB = new color[max];//背景色
float[] time = new float[max];//シーン有効時間
         
/*外部参照関連*/
XML program;//program.xml管理
XML[] config = new XML[max];//シーン管理
XML XMback, XMsec, XMmin, XMhour;//clock用
JSONObject Settings;//設定管理

/*制御関連*/
PVector centerPos;//中心座標
PVector imageSize;//表示中の画像サイズ
PVector[][] anyPos = new PVector[max][cMax];//任意座標
int dsate = 0;//draw_sate面切り替え
int check = 0;//面切り替えチェック
float passage;//シーン開始時間
float timer;//タイマー
boolean ready = false;//準備完了

/*clockモード*/
PImage[] minu = new PImage[max],//秒針画像
         hour = new PImage[max],//長針画像
         back = new PImage[max];//短針画像
PVector[] secAxis = new PVector[max],
          minAxis = new PVector[max],
          hourAxis = new PVector[max],//軸座標
          clockPos = new PVector[max];//時計座標
int[] secWeight = new int[max],//秒針長さ
      minWeight = new int[max],//長針長さ
      hourWeight = new int[max];//短針長さ
int[] dialWidth = new int[max];//盤面太さ
float[] clockSize = new float[max];//基準サイズ
float secondsRadius;//秒針長さ
float minutesRadius;//長針長さ
float hoursRadius;//短針長さ
float clockDiameter;//時計円サイズ
float dialRadius;
float dialRadius2;
float dialRadius3;//盤表示用
color[] bCRGB = new color[max],//時計円
        DialRGB = new color[max];//時計盤
String[] ftsec = new String[max],
         ftmin = new String[max],
         fthour = new String[max];//filetype
color[] secRGB = new color[max],
        minRGB = new color[max],
        hourRGB = new color[max];//針色
boolean[] minSmooth = new boolean[max],
        hourSmooth = new boolean[max];//滑らかな針

/*pulsモード*/
PImage[][] backPlus = new PImage[max][max];//to画像
XML plus;//+用
XML[] display = new XML[cMax];//フェード用
XML[] move = new XML[gMax];//+用移動管理
int[] fade = new int[max];//切替面数
float[] transparency = new float[max];//透明度
float[][] timing = new float[max][cMax];//フェード開始時間
float[][] duration = new float[max][cMax];//フェード時間
String[][] ratioPlus= new String[max][cMax];//to比
String[][] ftbackPlus = new String[max][cMax];//tofiletype
/*moving用関数*/
PVector[][][] moveBegin = new PVector[max][cMax][gMax];//初期座標
PVector[][][] moveEnd = new PVector[max][cMax][gMax];//最後座標
PVector[][][] moveDist = new PVector[max][cMax][gMax];//差分座標
float[][][] moveStart = new float[max][cMax][gMax];//開始時間
float[][][] moveDuration = new float[max][cMax][gMax];//継続時間
String[][][] moveBehavior = new String[max][cMax][gMax];//移動挙動
float[][][] percent = new float[max][cMax][gMax];//進捗
boolean[][][] isMoving = new boolean[max][cMax][gMax];//動くかどうか
boolean[][][] movingEnd = new boolean[max][cMax][gMax];//移動終了
int msate = 0;//moving_sate

void settings(){
  Settings = loadJSONObject("Settings.json");
  program = loadXML(Settings.getString("useProgram_xml"));
  config = program.getChildren("config");
  if(Settings.getInt("Wideth") >= 1 && Settings.getInt("height") >= 1){
    size(Settings.getInt("Wideth"), Settings.getInt("height"));
  }else 
  if(Settings.getInt("Wideth") >= 1 && Settings.getInt("height") == -1){
    size(Settings.getInt("Wideth"), displayHeight);
  }else 
  if(Settings.getInt("Wideth") == -1 && Settings.getInt("height") >= 1){
    size(displayWidth, Settings.getInt("height"));
  }else 
  if(Settings.getInt("Wideth") == -1 && Settings.getInt("height") == -1){
    fullScreen(Settings.getInt("fullscreenTo"));
  }else{
    size(300, 100);
    print("error01-Size is not specified");
  }
}

void setup(){
  frameRate(60);
  background(0);
  centerPos = new PVector(width / 2, height / 2);
  imageSize = new PVector(width, height);
  //loading();
  thread("loading");
  for(int i = 0; i < max; i++){
    transparency[i] = 255;
    for(int o = 0; o < cMax; o++){
      anyPos[i][o] = centerPos.copy();
    }
  }
  while(!ready){
    delay(1);
  }
  print("start -elapsed time "+millis()+" [ms]\n");
}


void draw(){
  if(dsate != check){//画面切り替え時に動作
    passage = millis();//起動時からの経過秒
    if(dsate >= config.length){
      dsate = 0;
    }
    check = dsate;
    msate = 0;
    centerPos.set(width / 2, height / 2);
    for(int i = 0; i < max; i++){
      transparency[i] = 255;
      for(int o = 0; o < cMax; o++){
        anyPos[i][o] = centerPos.copy();
        for(int p = 0; p < gMax; p++){
          movingEnd[i][o][p] = false;
        }
      }
    }
  }
  timer = (millis() - passage)/1000;
  
  background(BGRGB[dsate]);
  imageMode(CENTER);
  
  switch(mode[dsate]){
    case "normal+":
      for(int i = fade[dsate]; i >= 0; i--){
        if(isMoving[dsate][i][msate] &&
          moveStart[dsate][i][msate] <= timer){//isMovingがtrueの時時間になったら開始
          if(!movingEnd[dsate][i][msate]){//最後まで来ていなければ
            percent[dsate][i][msate] = map(timer, moveStart[dsate][i][msate], moveStart[dsate][i][msate] + moveDuration[dsate][i][msate], 0, 1);
            switch(moveBehavior[dsate][i][msate]){
              case "accel"://加速
                anyPos[dsate][i].x = moveBegin[dsate][i][msate].x + (percent[dsate][i][msate] * moveDist[dsate][i][msate].x);//a*x
                break;
              case "accel_2"://累乗加速
                anyPos[dsate][i].x = moveBegin[dsate][i][msate].x + (pow(percent[dsate][i][msate], 4) * moveDist[dsate][i][msate].x);//(a^4)*x
                break;
              case "accel_3"://円加速
                anyPos[dsate][i].x = moveBegin[dsate][i][msate].x + (sin(radians(map(percent[dsate][i][msate], 0, 1, 0, 90))) * moveDist[dsate][i][msate].x);//sin(a)*x
                break;
              case "decel"://減速
                anyPos[dsate][i].x += percent[dsate][i][msate] * (moveEnd[dsate][i][msate].x - anyPos[dsate][i].x);//a*(xe-x)
                break;
              case "decel_2"://累乗減速
                anyPos[dsate][i].x += pow(percent[dsate][i][msate], 4) * (moveEnd[dsate][i][msate].x - anyPos[dsate][i].x);//(a^4)*(xe-x)
                break;
              case "decel_3"://円減速
                anyPos[dsate][i].x += sin(radians(map(percent[dsate][i][msate], 0, 1, 0, 90))) * (moveEnd[dsate][i][msate].x - anyPos[dsate][i].x);//sin(a)*(xe-x)
                break;
              case "warp"://ワープ
                anyPos[dsate][i].x = moveEnd[dsate][i][msate].x;
                break;
            }
            if(moveStart[dsate][i][msate] + moveDuration[dsate][i][msate] < timer){//最後に来た場合
              movingEnd[dsate][i][msate] = true;
              msate++;
            }
          }
        }
        print(msate);
        if(i <= 0){//最初
        }else{//二面目から
          switch(ftbackPlus[dsate][i]){
            case ftpict:
              if(timer >= time[dsate]){
                dsate++;
                return;
              }else{
                imageDraw(backPlus[dsate][i], ratioPlus[dsate][i], min(width, height), anyPos[dsate][i]);
              }
              break;
            case fthide:
              break;
          }
          noTint();
          tint(255, transparency[i]);
          if(0 < transparency[i]){
            transparency[i] = map(timer, timing[dsate][i], timing[dsate][i]+duration[dsate][i], 255, 0);
            if(duration[dsate][i] == 0){
              duration[dsate][i] = 0;
            }
          }
        }
      }
    case "normal":
      switch(ftback[dsate]){
        case ftmovie:
          if(mov[dsate].available()){
            mov[dsate].read();
          }
          if(isloop[dsate]){//ループの場合
            mov[dsate].loop();
            imageDraw(mov[dsate], ratio[dsate], min(width, height), anyPos[dsate][0]);
          }else{
            if(mov[dsate].time() >= mov[dsate].duration() ||
               mov[dsate].time() >= time[dsate]){//終点まで来たら切替
              mov[dsate].stop();
              dsate++;
              return;
            }else{
              mov[dsate].play();
              imageDraw(mov[dsate],ratio[dsate], min(width, height), anyPos[dsate][0]);
            }
          }
          break;
        case ftpict:
          if(timer >= time[dsate]){
            dsate++;
            return;
          }else{
            imageDraw(back[dsate], ratio[dsate], min(width, height), anyPos[dsate][0]);
          }
          break;
      }
      break;
    case "clock":
      secondsRadius = clockSize[dsate] * 0.72;
      minutesRadius = clockSize[dsate] * 0.65;
      hoursRadius = clockSize[dsate] * 0.50;
      dialRadius = clockSize[dsate] * 0.80;
      dialRadius2 = clockSize[dsate] * 0.75;
      dialRadius3 = clockSize[dsate] * 0.70;
      clockDiameter = clockSize[dsate] * 1.8;
      centerPos.x = clockPos[dsate].x + (width / 2);
      centerPos.y = clockPos[dsate].y + (height / 2);
      float s = map(second(), 0, 60, 0, TWO_PI);
      float m;
      float h;
      if(minSmooth[dsate]){
        m = map(minute() + norm(second(), 0, 60), 0, 60, 0, TWO_PI);
      }else{
        m = map(minute(), 0, 60, 0, TWO_PI);
      }
      if(hourSmooth[dsate]){
        h = map(hour() + norm(minute(), 0, 60), 0, 24, 0, TWO_PI * 2);
      }else{
        h = map(hour(), 0, 24, 0, TWO_PI * 2);
      }
      switch(ftback[dsate]){
        case ftmovie:
          if(mov[dsate].available()){
            mov[dsate].read();
          }
          if(isloop[dsate]){//ループの場合
            mov[dsate].loop();
            imageDraw(mov[dsate], ratio[dsate], min(width, height), anyPos[dsate][0]);
          }else{
            if(mov[dsate].time() >= mov[dsate].duration() ||
               mov[dsate].time() >= time[dsate]){//終点まで来たら切替
              mov[dsate].stop();
              dsate++;
              return;
            }else{
              mov[dsate].play();
              imageDraw(mov[dsate], ratio[dsate], min(width, height), anyPos[dsate][0]);
            }
          }
          break;
        case ftpict:
          if(timer >= time[dsate]){
            dsate++;
            return;
          }else{
            imageDraw(back[dsate], ratio[dsate], clockDiameter, anyPos[dsate][0]);
          }
          break;  
        case ftpro:
          if(timer >= time[dsate]){
            dsate++;
            return;
          }else{
            //円部分
            fill(bCRGB[dsate]);//次の円を塗りつぶす
            noStroke();//枠なし
            ellipse(centerPos.x, centerPos.y, clockDiameter, clockDiameter);//円描画
            fill(255);//白
            ellipse(centerPos.x, centerPos.y, 10, 10);//中心点描画
            // 盤表示
            fill(DialRGB[dsate]);
            stroke(DialRGB[dsate]);
            strokeWeight(dialWidth[dsate]);
            beginShape(LINES);
            for (int a = 0; a < 360; a+=6) {
              float angle = radians(a);
              float x = centerPos.x + cos(angle) * dialRadius;
              float y = centerPos.y + sin(angle) * dialRadius;
              float x2 = centerPos.x + cos(angle) * dialRadius2;
              float y2 = centerPos.y + sin(angle) * dialRadius2;
              float x3 = centerPos.x + cos(angle) * dialRadius3;
              float y3 = centerPos.y + sin(angle) * dialRadius3;
              vertex(x, y);
              if(a%5 == 0){
                strokeWeight(dialWidth[dsate]*1.5);
                vertex(x3, y3);
              }
              else{
                strokeWeight(dialWidth[dsate]);
                vertex(x2, y2);
              }
            }
          }
          break;
      }
      if(ftsec[dsate] == ftpict){//秒針
        translate(centerPos.x, centerPos.y);
        rotate(s);
        sec[dsate].resize(0, int(clockSize[dsate]));
        image(sec[dsate], secAxis[dsate].x, secAxis[dsate].y);
        rotate(-s);
        translate(-centerPos.x, -centerPos.y);
      }else
      if(ftsec[dsate] == ftpro){
        stroke(secRGB[dsate]);
        strokeWeight(secWeight[dsate]);
        line(centerPos.x, centerPos.y, centerPos.x + cos(s - HALF_PI) * secondsRadius, centerPos.y + sin(s - HALF_PI) * secondsRadius);
      }
      
      if(ftmin[dsate] == ftpict){//分針
        translate(centerPos.x, centerPos.y);
        rotate(m);
        minu[dsate].resize(0, int(clockSize[dsate]));
        image(minu[dsate], minAxis[dsate].x, minAxis[dsate].y);
        rotate(-m);
        translate(-centerPos.x, -centerPos.y);
      }else
      if(ftmin[dsate] == ftpro){
        stroke(minRGB[dsate]);
        strokeWeight(minWeight[dsate]);
        line(centerPos.x, centerPos.y, centerPos.x + cos(m - HALF_PI) * minutesRadius, centerPos.y + sin(m - HALF_PI) * minutesRadius);
      }
      
      if(fthour[dsate] == ftpict){//時針
        translate(centerPos.x, centerPos.y);
        rotate(h);
        hour[dsate].resize(0, int(clockSize[dsate]));
        image(hour[dsate], hourAxis[dsate].x, hourAxis[dsate].y);
        rotate(-h);
        translate(-centerPos.x, -centerPos.y);
      }else
      if(fthour[dsate] == ftpro){
        stroke(hourRGB[dsate]);
        strokeWeight(hourWeight[dsate]);
        line(centerPos.x, centerPos.y, centerPos.x + cos(h - HALF_PI) * hoursRadius, centerPos.y + sin(h - HALF_PI) * hoursRadius);
      }
      break;
    case "void":
      if(timer >= time[dsate]){
        dsate++;
        return;
      }
      break;
    case "debug":
      noStroke();
      fill(255);
      rect(0, 0, width/8, height*0.6);
      fill(255, 255, 0);
      rect(width/8, 0, width/4, height*0.6);
      fill(0, 255, 255);
      rect(width/4, 0, (width/8)*3, height*0.6);
      fill(0, 255, 0);
      rect((width/8)*3, 0, width/2, height*0.6);
      fill(255, 0, 255);
      rect(width/2, 0, (width/8)*5, height*0.6);
      fill(255, 0, 0);
      rect((width/8)*5, 0, (width/8)*6, height*0.6);
      fill(0, 0, 255);
      rect((width/8)*6, 0, (width/8)*7, height*0.6);
      fill(128, 128, 128);
      rect((width/8)*7, 0, width, height*0.6);
      
      fill(0, 0, 255);
      rect(0, height*0.6, width/8, height*0.05);
      fill(0);
      rect(width/8, height*0.6, width/4, height*0.05);
      fill(255, 0, 255);
      rect(width/4, height*0.6, (width/8)*3, height*0.05);
      fill(0);
      rect((width/8)*3, height*0.6, width/2, height*0.05);
      fill(0, 255, 255);
      rect(width/2, height*0.6, (width/8)*5, height*0.05);
      fill(0);
      rect((width/8)*5, height*0.6, (width/8)*6, height*0.05);
      fill(255);
      rect((width/8)*6, height*0.6, (width/8)*7, height*0.05);
      fill(0);
      rect((width/8)*7, height*0.6, width, height*0.05);
      
      fill(16, 0, 128);
      rect(0, height*0.65, width/8, height*0.35);
      fill(64, 0, 128);
      rect(width/4, height*0.65, (width/8)*3, height*0.35);
      setGradient((width/8)*3, height*0.65, (width/8)*6, height*0.35, 0, 255);
      break;
    case "degital":
      //デジタル時計
      break;
  }
  noTint();
}

boolean isNumber(String num) {
  try {
      Integer.parseInt(num);
      return true;
    }
    catch (NumberFormatException e) {
      return false;
  }
}

void imageDraw(PImage img, String rat, float maxsize, PVector pos){
  switch(rat){
    case "1:1":
      image(img, pos.x, pos.y, maxsize, maxsize);
      imageSize.set(maxsize, maxsize);
      break;
    case "4:3":
      image(img, pos.x, pos.y, (maxsize/3)*4, maxsize);
      imageSize.set((maxsize/3)*4, maxsize);
      break;
    case "16:9":
      image(img, pos.x, pos.y, (maxsize/9)*16, maxsize);
      imageSize.set((maxsize/9)*16, maxsize);
      break;
  }
}

void setGradient(float x, float y, float w, float h, color c1, color c2){
  for (float i = x; i <= x+w; i++) {
    stroke(lerpColor(c1, c2, map(i, x, x+w, 0, 1)));
    line(i, y, i, y+h);
  }
}
/*clock*//*degital(仮)*/
XML clock;
XML[] object = new XML[cMax];
XML[] moveClock = new XML[gMax];

void loading(){
  for(int i = 0; i < config.length; i++){
    //デフォルト値
    isloop[i] = false;
    mode[i] = config[i].getString("mode");
    //色
    if(config[i].getString("background").contains(",")){//RGBの場合
      String[] rgb = config[i].getString("background").split(",", 0);
      BGRGB[i] = color(int(rgb[0]),int(rgb[1]),int(rgb[2]));
    }else{//白黒の場合
      BGRGB[i] = config[i].getInt("background");
    }
    switch(mode[i]){
      case "normal+":
        name[i] = config[i].getString("reference");
        plus = loadXML(name[i]);
        display = plus.getChildren("display");
        fade[i] = display.length-1;
        for(int o =0; o < display.length; o++){
          anyPos[i][o] = new PVector(width / 2, height / 2);
          name[i] = display[o].getString("name");
          if(name[i].contains(".png") || name[i].contains(".gif") || 
             name[i].contains(".jpg") || name[i].contains(".tga")){//画像
            time[i] = config[i].getInt("time");
            if(o == 0){
              back[i] = loadImage("/Media/"+name[i]);
              ratio[i] = display[o].getString("ratio");
              ftback[i] = ftpict;
            }else{
              backPlus[i][o] = loadImage("/Media/"+name[i]);
              ratioPlus[i][o] = display[o].getString("ratio");
              timing[i][o] = display[o].getInt("timing");
              duration[i][o] = display[o].getInt("duration");
              ftbackPlus[i][o] = ftpict;
            }
          }else 
          if(name[i].contains("hide")){//表示しない 
            if(o == 0){
              ftback[i] = fthide;
            }else{
              timing[i][o] = display[o].getInt("timing");
              duration[i][o] = display[o].getInt("duration");
              ftbackPlus[i][o] = fthide;
            }
          }
          if(display[o].hasChildren()){
            move = display[o].getChildren("move");
            for(int p =0; p < move.length; p++){
              isMoving[i][o][p] = movingEnd[i][o][p] = false;
              isMoving[i][o][p] = true;
              moveStart[i][o][p] = move[p].getFloat("startTime");
              moveDuration[i][o][p] = move[p].getFloat("duration");
              moveBehavior[i][o][p] = move[p].getString("behavior");
              String[] pos = move[p].getString("beginPos").split(",",0);
              moveBegin[i][o][p] = new PVector(float(pos[0]), float(pos[1])).add(centerPos);
              pos = move[p].getString("endPos").split(",", 0);
              moveEnd[i][o][p] = new PVector(float(pos[0]), float(pos[1])).add(centerPos);
              moveDist[i][o][p] = PVector.sub(moveEnd[i][o][p], moveBegin[i][o][p]);
            }
          }
        }
        break;
      case "normal":
        name[i] = config[i].getString("name");
        if(name[i].contains(".mp4") || name[i].contains(".mov")){//動画
          mov[i] = new Movie(this, "/Media/"+name[i]);
          ratio[i] = config[i].getString("ratio");
          ftback[i] = ftmovie;
          switch(config[i].getString("switching")){
            case "time":
              time[i] = config[i].getInt("time");
              break;
            case "end":
              time[i] = 2592000;
              break;
            case "loop":
              isloop[i] = true;
              break;
            default:
              time[i] = 0;
              print("warning01-Unknown setting value");
              break;
          }
        }else 
        if(name[i].contains(".png") || name[i].contains(".gif") || 
           name[i].contains(".jpg") || name[i].contains(".tga")){//画像
          time[i] = config[i].getInt("time");
          back[i] = loadImage("/Media/"+name[i]);
          ratio[i] = config[i].getString("ratio");
          ftback[i] = ftpict;
        }
        else if(name[i].contains("program")){//プログラム描画
          time[i] = config[i].getInt("time");
          if(config[i].getString("RGB").contains(",")){//RGBの場合
            String[] rgb = config[i].getString("RGB").split(",", 0);
            bCRGB[i] = color(int(rgb[0]),int(rgb[1]),int(rgb[2]));
          }else{//白黒の場合
            bCRGB[i] = config[i].getInt("RGB");
          }
          if(config[i].getString("DialRGB").contains(",")){//RGBの場合
            String[] rgb = config[i].getString("DialRGB").split(",", 0);
            DialRGB[i] = color(int(rgb[0]),int(rgb[1]),int(rgb[2]));
          }else{//白黒の場合
            DialRGB[i] = config[i].getInt("DialRGB");
          }
          dialWidth[i] = config[i].getInt("Dialwidth");
          ftback[i] = ftpro;
        }
        else if(name[i].contains("hide")){//表示しない 
          time[i] = config[i].getInt("time");
          ftback[i] = fthide;
        }
        break;
      case "clock":
        XMback = config[i].getChild("back");
        name[i] = XMback.getString("usefile");
        if(name[i].contains(".mp4") || name[i].contains(".mov")){//動画
          mov[i] = new Movie(this, "/Media/"+name[i]);
          ratio[i] = XMback.getString("ratio");
          ftback[i] = ftmovie;
          switch(config[i].getString("switching")){
            case "time":
              time[i] = config[i].getInt("time");
              break;
            case "end":
              time[i] = 2592000;
              break;
            case "loop":
              isloop[i] = true;
              break;
            default:
              time[i] = 0;
              print("warning01-Unknown setting value");
              break;
          }
        }else
        if(name[i].contains(".png") || name[i].contains(".gif") || 
           name[i].contains(".jpg") || name[i].contains(".tga")){
          time[i] = config[i].getInt("time");
          back[i] = loadImage("/Media/"+name[i]);
          ratio[i] = XMback.getString("ratio");
          ftback[i] = ftpict;
        }else 
        if(name[i].contains("program")){
          time[i] = config[i].getInt("time");
          if(XMback.getString("RGB").contains(",")){//RGBの場合
            String[] rgb = XMback.getString("RGB").split(",", 0);
            bCRGB[i] = color(int(rgb[0]),int(rgb[1]),int(rgb[2]));
          }else{//白黒の場合
            bCRGB[i] = XMback.getInt("RGB");
          }
          if(XMback.getString("DialRGB").contains(",")){//RGBの場合
            String[] rgb = XMback.getString("DialRGB").split(",", 0);
            DialRGB[i] = color(int(rgb[0]),int(rgb[1]),int(rgb[2]));
          }else{//白黒の場合
            DialRGB[i] = XMback.getInt("DialRGB");
          }
          dialWidth[i] = XMback.getInt("Dialwidth");
          ftback[i] = ftpro;
        }else 
        if(name[i].contains("hide")){
          time[i] = config[i].getInt("time");
          ftback[i] = fthide;
        }
        
        String[] pos = config[i].getString("position").split(",", 0);
        clockPos[i] = new PVector(float(pos[0]),float(pos[1]));
        clockSize[i] = (config[i].getFloat("size")/100)*(height/2);
        
        XMsec = config[i].getChild("sec");
        name[i] = XMsec.getString("usefile");
        if(name[i].contains(".png") || name[i].contains(".gif") || 
           name[i].contains(".jpg") || name[i].contains(".tga")){
          sec[i] = loadImage("/Media/"+name[i]);
          secAxis[i] = new PVector(XMsec.getInt("x"),XMsec.getInt("y"));
          ftsec[i] = ftpict;
        }
        else if(name[i].contains("program")){
          if(XMsec.getString("RGB").contains(",")){//RGBの場合
            String[] rgb = XMsec.getString("RGB").split(",", 0);
            secRGB[i] = color(int(rgb[0]),int(rgb[1]),int(rgb[2]));
          }else{//白黒の場合
            secRGB[i] = XMsec.getInt("RGB");
          }
          secWeight[i] = XMsec.getInt("width");
          ftsec[i] = ftpro;
        }else
        if(name[i].contains("hide")){
          ftsec[i] = fthide;
        }
        
        XMmin = config[i].getChild("min");//分
        if(XMmin.getString("smooth") == null){
          minSmooth[i] = false;
        }else if(XMmin.getString("smooth").contains("true")){
          minSmooth[i] = true;
        }else{
          minSmooth[i] = false;
        }
        name[i] = XMmin.getString("usefile");
        if(name[i].contains(".png") || name[i].contains(".gif") || 
           name[i].contains(".jpg") || name[i].contains(".tga")){
          minu[i] = loadImage("/Media/"+name[i]);
          minAxis[i] = new PVector(XMmin.getInt("x"),XMmin.getInt("y"));
          ftmin[i] = ftpict;
        }
        else if(name[i].contains("program")){
          if(XMmin.getString("RGB").contains(",")){//RGBの場合
            String[] rgb = XMmin.getString("RGB").split(",", 0);
            minRGB[i] = color(int(rgb[0]),int(rgb[1]),int(rgb[2]));
          }else{//白黒の場合
            minRGB[i] = XMmin.getInt("RGB");
          }
          minWeight[i] = XMmin.getInt("width");
          ftmin[i] = ftpro;
        }
        else if(name[i].contains("hide")){
          ftmin[i] = fthide;
        }
        
        XMhour = config[i].getChild("hour");//時
        if(XMhour.getString("smooth").contains("true")){
          hourSmooth[i] = true;
        }else if(XMhour.getString("smooth") == null){
          hourSmooth[i] = false;
        }else{
          hourSmooth[i] = false;
        }
        name[i] = XMhour.getString("usefile");
        if(name[i].contains(".png") || name[i].contains(".gif") || 
           name[i].contains(".jpg") || name[i].contains(".tga")){
          hour[i] = loadImage("/Media/"+name[i]);
          hourAxis[i] = new PVector(XMhour.getInt("x"), XMhour.getInt("y"));
          fthour[i] = ftpict;
        }
        else if(name[i].contains("program")){
          if(XMhour.getString("RGB").contains(",")){//RGBの場合
            String[] rgb = XMhour.getString("RGB").split(",", 0);
            hourRGB[i] = color(int(rgb[0]),int(rgb[1]),int(rgb[2]));
          }else{//白黒の場合
            hourRGB[i] = XMhour.getInt("RGB");
          }
          hourWeight[i] = XMhour.getInt("width");
          fthour[i] = ftpro;
        }
        else if(name[i].contains("hide")){
          fthour[i] = fthide;
        }
       break;
      case "void":
        time[i] = config[i].getInt("time");
        break;
      case "debug":
        break;
      case "degital":
        //デジタル時計
        name[i] = config[i].getString("reference");
        clock = loadXML(name[i]);
        object = clock.getChildren("object");
        for(int o =0; o < display.length; o++){
          String[] pos = object.getString("position").split(",", 0);
          anyPos[i][o] = new PVector(float(pos[0]),float(pos[1]));
        }
        break;
      default:
        break;
    }
    ready = true;
    print(i+1+"\n");
  }
  print("Total loading time "+millis()+" [ms]\n");
}
