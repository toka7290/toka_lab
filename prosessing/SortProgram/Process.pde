boolean isComplete = false;
int val_min = 0;
int val_max = 0;
int num_bef = 0;
int num_aft = 0;
int num_002 = 0;
void Sort_Process_type_bubble(int num){
  if(!isComplete){
    num_aft = num+1;
    if(num_aft > 1000){
      println(num_aft);
      num_aft = 1000;
    }
    if(variable[num] > variable[num_aft]){
      var_temporary = variable[num];
      variable[num] = variable[num_aft];
      variable[num_aft] = var_temporary;
      Progress = 0;
    }else{
      Progress++;
    }
    if(Progress >= 1000){
      isComplete = true;
      num_aft = 0;
      mode = 0;
      println("2=>0");
      delay(20);
      Progress = 0;
    }
  }
}

void Sort_Process_type_quick(){
  run = true;
  if(!isComplete){
    quicksort(0,1000);
  }
  isComplete = true;
  println("3=>0");
  run = false;
}

void Sort_Process_type_selection(int num){
  run = true;
  if(!isComplete){
    if(variable[num] == val_min){
      var_temporary = variable[num];
      variable[num] = variable[val_min];
      variable[val_min] = var_temporary;
      val_min++;
    }
    if(val_min >= 1000){
      isComplete = true;
      val_min = 0;
      println("4=>0");
      mode = 0;
      delay(20);
      run = false;
    }
  }
}

void Sort_Process_type_insertion(int num){
  run = true;
  if(!isComplete){
    num_bef = num;
    num_aft = num+1;
    if(num_aft > 1000)num_aft = 0;
    if(variable[num_bef] > variable[num_aft]){
      var_temporary = variable[num_aft];
      println(variable[num_aft]+">>>"+ variable[num_bef]);
      num_002 = num_bef;
      while(variable[num_aft] > variable[num_002] && num_002 > 0){
        val_max = variable[num_aft];
        variable[num_aft] = variable[num_002];
        variable[num_002] = val_max;
        num_002--;
      }
      variable[num_002] = var_temporary;
      //if(num_002 < 0)num_002 = 1000;
      //println(num_aft+">>>"+num_002+">>>"+num_bef);
      //variable[num_002] = var_temporary;
      //Progress++;
    }
    if(Progress >= 1000){
      isComplete = true;
      val_min = 0;
      println("5=>0");
      mode = 0;
      delay(20);
      run = false;
    }
  }
}

int med3(int x, int y, int z) {
    if (x < y) {
        if (y < z) return y; else if (z < x) return x; else return z;
    } else {
        if (z < y) return y; else if (x < z) return x; else return z;
    }
}

void quicksort(int left, int right) {
    if (left < right) {
        int i = left, j = right;
        int tmp;
        int pivot = med3(variable[i], variable[i + (j - i) / 2], variable[j]); /* (i+j)/2 ではオーバーフローしてしまう */
        while (true) { /* a[] を pivot 以上と以下の集まりに分割する */
            while (variable[i] < pivot) i++; /* a[i] >= pivot となる位置を検索 */
            while (pivot < variable[j]) j--; /* a[j] <= pivot となる位置を検索 */
            if (i >= j) break;
            tmp = variable[i]; 
            variable[i] = variable[j]; 
            variable[j] = tmp; /* a[i], a[j] を交換 */
            i++; j--;
            delay(1);
        }
        quicksort(left, i - 1);  /* 分割した左を再帰的にソート */
        quicksort(j + 1, right); /* 分割した右を再帰的にソート */
    }
}
