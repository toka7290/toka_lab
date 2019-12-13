int mode = 1;
int type = 2;
boolean run = false;

int[] variable = new int[1001];
int var_temporary;
int Progress = 0;
void setup(){
  size(1280,720);
  for(int num = 0; num <= 1000; num++){
    variable[num] = num;
  }
  strokeCap(SQUARE);
  strokeWeight(2);
  strokeJoin(MITER);
}

void draw(){
  clear();
  background(255);
  for(int num = 0; num <= 1000; num++){
    switch(mode){
      case 1:
        thread("Sort_Disassembly_Main");
        mode = 0;
        break;
      case 2:
        Sort_Process_type_bubble(num);
        break;
      case 3:
        thread("Sort_Process_type_quick");
        mode = 0;
        break;
      case 4:
        Sort_Process_type_selection(num);
        break;
      case 5:
        Sort_Process_type_insertion(num);
        break;
      default:
        break;
    }
    line(width*num/1000,height,width*num/1000,height-(height*variable[num]/1000));
  }
}

void keyPressed(){
  switch(keyCode){
    case ENTER:
      if(mode==0)mode = type;
      break;
    case BACKSPACE:
      if(mode==0)mode = 1;
      break;
    case TAB:
      isComplete = true;
      println(variable);
      break;
    default:
      break;
  }
  switch(key){
    case '1':
      type = 2;
      println("type=1");
      break;
    case '2':
      type = 3;
      println("type=2");
      break;
    case '3':
      type = 4;
      println("type=3");
      break;
    case '4':
      type = 5;
      println("type=4");
      break;
    default:
      break;
  }
}
