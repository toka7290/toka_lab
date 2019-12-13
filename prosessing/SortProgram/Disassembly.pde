void Sort_Disassembly_Main(){
  run = true;
  do{
    int address_before = int(random(0,1000));
    int address_after = int(random(0,1000));
    var_temporary = variable[address_before];
    variable[address_before] = variable[address_after];
    variable[address_after] = var_temporary;
  }while(random(0,1000)!=500);
  isComplete = false;
  println("1=>0");
  run = false;
}
