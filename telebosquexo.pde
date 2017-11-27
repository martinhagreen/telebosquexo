//antes de executar isto, temos que ter subido no arduino, o sketch de StandardFirmata incluido nos exemplos de Arduino
import processing.serial.*;
import cc.arduino.*;
import ddf.minim.*;

Arduino arduino;
Minim minim;
AudioInput in;

float posX, posY, prevX, prevY;
float red, green, blue;
PImage marco;
int buttonState;
int lastButtonState = 0;
int buttonPushCounter;
boolean borrar, guardar;
float barWidth=300.0;   
float hueVal;  
float hue;

void setup() {
  size(1920, 1080);
  //fullScreen(1);
  background(0);
  
  noStroke();
  fill(150);
  rect(65, 59, width-65*2, height-68*2);
 
  colorMode(HSB);
  marco = loadImage("telebosquexo_marco_negro.png");
  
  println(Arduino.list()); //este comando imprime na consola a lista dos portos
  arduino = new Arduino(this, "/dev/tty.usbmodem1421", 57600); //sustituir polo porto onde temos conectado o arduino
  
  minim = new Minim(this);
  in = minim.getLineIn();
  
  //inicializamos todolos pins do Arduino coma entradas
  for (int i = 0; i <= 13; i++){
    arduino.pinMode(i, Arduino.INPUT);
  }
  
  //posicion inicial do punteiro 
  prevX = map(arduino.analogRead(1), 0, 1023, width - 70, 70);
  prevY = map(arduino.analogRead(0), 1023, 0, height- 118, 65);    
}


void draw() {
  //mapeamos os valores analóxicos dos potenciómetros coa posición en pantalla
  posX = map(arduino.analogRead(1), 0, 1023, width - 70, 70);
  posY =  map(arduino.analogRead(0), 1023, 0, height - 118, 65);
  //entrada dixital to boton
  buttonState = arduino.digitalRead(7);
  //mapeamos o valor analóxico do terceiro potenciometro para o cambio de cor
  hue = map(arduino.analogRead(3), 0, 1023, 0, 255);
 
  
  strokeWeight(4 * in.left.level() * 100); //grosor da liña afectada pola entrada de audio (volume)
  stroke(hue, 255, 255); //color afectado pola variable que modificamos
  line(prevX, prevY, posX, posY); //Debuxamos a liña
  
  //igualamos as posicións para ter unha liña continua
  prevX = posX;
  prevY = posY;
  
  //ó ter usado un pushbutton (dos que se quedan pulsados), facemos esta pequena lóxica para poder ter un contador cada vez que o pulsamos
  //e aumentar a variable buttonPushCounter cada vez que o botón cambia de estado
  if (buttonState != lastButtonState) {
    if (arduino.digitalRead(7) == arduino.HIGH) {
      buttonPushCounter++;
      borrar = true;
    } else {
      buttonPushCounter++;
      borrar = true; 
    }
   delay(50);
  }else {
    borrar = false;
  
  }
  //igualamos o estado do botón para a seguinte volta no loop
  lastButtonState = buttonState;
  
  strokeWeight(4);
  
  //Aquí gardamos a imaxe e borramos a pantalla
  if(borrar){
    saveFrame("sketch-######.png");
    noStroke();
    fill(150);
    rect(65, 59, width-65*2, height-68*2);
  } 
   
   //imaxe superior
   image(marco, 0, 0);
   hueVal= drawSlider(1550.0, 1010.0, barWidth, 30.0, hueVal); 
   hueVal = hue;
 
}

//o slider das cores
float drawSlider(float xPos, float yPos, float sWidth, float sHeight, float hueVal){
   fill(0);
   noStroke();
   rect(xPos-5,yPos-4,sWidth+10,sHeight+10);  //fondo branco para o slider
  
   float sliderPos=map(hueVal,0.0,255.0,0.0,sWidth); 
  
   for(int i=0;i<sWidth;i++){  
       float hueValue=map(i,0.0,sWidth,0.0,255.0);  
       stroke(hueValue,255,255);
       line(xPos+i,yPos,xPos+i,yPos+sHeight);
    }
  
    stroke(255);
    fill(hueVal,255,255);  
    rect(sliderPos+xPos-3,yPos-5,6,sHeight+10);  //Este é o slider
    rect(sWidth+1200, yPos, sHeight,sHeight); // Rectángulo onde se ve o color seleccionado
    return hueVal;
}


void stop(){
  in.close();
  minim.stop();
  super.stop();
}