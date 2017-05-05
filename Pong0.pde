import ddf.minim.*;   // Librerias
import processing.serial.*;

String nomPuerSerial = "COM3";  // Puerto del arduino
Serial arduino;
Minim minim;
AudioPlayer sonidoPared, sonidoBarra;
PImage bola, barra_p1, barra_p2, fondo;
float barra_p1_posicion, barra_p2_posicion;
float bolaX, bolaY;
float velVert, velHor;   // Declaración de variables
String[] value;
int p1_puntuacion=0;
int p2_puntuacion=0;
PFont f;
int cuenta=0;

void setup()
{
  size(520,360);  // Tamaño de pantalla
  if(nomPuerSerial.equals("")) buscarArduino();   // Conexión arduino
  else arduino = new Serial(this, nomPuerSerial, 9600);
  imageMode(CENTER);
  bola = loadImage("bola.png");
  barra_p1 = loadImage("bate.png");   // Carga de imagenes
  barra_p2 = loadImage("bate.png");
  fondo = loadImage("fondo.png");
  f = createFont("Arial",16,true); // Fuente
  textFont(f,16);
  minim = new Minim(this);
  sonidoPared = minim.loadFile("pared.mp3");
  sonidoBarra = minim.loadFile("bate.mp3");   // Carga de sonidos
  barra_p1_posicion = barra_p1.width/2;
  barra_p2_posicion = barra_p2.width/2;  // Posición de barras
  resetBola();
}

void resetBola()     // Velocidad y movimiento de la bola
{
  bolaX = 260;
  bolaY = 180;
  velVert = random(-12,12);
  velHor = random(-6,6);
  if (velVert<0) { velVert=velVert-3; }
  if (velVert>=0) { velVert=velVert+3; }
}

void draw()
{    // Dibujar el fondo y la puntuación
  image(fondo,width/2,height/2,width,height);    
  text("Jugador 1: "+p1_puntuacion+"\n Jugador 2: "+p2_puntuacion,10,100);
  cuenta++;
  // Incrementar Velocidad
  if (cuenta==200) {
    cuenta=0;
    if (velVert<0) { velVert--; }
    if (velVert>0) { velVert++; }
  }
  // Mover la barra
  if((arduino != null) && (arduino.available()>0)) {
    String message = arduino.readStringUntil('\n');
    if(message != null) {
      value = split(message, '|');
      if (value.length==2) {
        barra_p1_posicion = map(int(trim(value[0])),0,1024,0,width);
        barra_p2_posicion = map(int(trim(value[1])),0,1024,0,width);
      }
    }
  }
  
  // Dibujar barras
  image(barra_p1,barra_p1_posicion,height-barra_p1.height);
  image(barra_p2,barra_p2_posicion,barra_p2.height);
  
  

  // Calcular la posicion de la pelota y asegurarse que se quede en escena
  bolaX = bolaX + velHor;
  bolaY = bolaY + velVert;
  if(bolaY >= height) { p1_puntuacion++; resetBola(); }
  if(bolaY <= 0) { p2_puntuacion++; resetBola(); }
  if(bolaX >= width) rebotePared();
  if(bolaX <= 0) rebotePared();

  // Insertar la pelota en la posicion y orientacion correcta
  translate(bolaX,bolaY);
  if(velVert > 0) rotate(-sin(velHor/velVert));
  else rotate(PI-sin(velHor/velVert));
  image(bola,0,0);
  
  // Colision entre pelota y barra
  if(barra_p1_Colisionbola()) {
    float distDebarra_p1_Center = barra_p1_posicion-bolaX;
    velHor = -distDebarra_p1_Center/10;
    velVert = -velVert;
    bolaY = height-(barra_p1.height*2);
    sonidoBarra.rewind();
    sonidoBarra.play();
  }
  
  if(barra_p2_Colisionbola()) {
    float distDebarra_p2_Center = barra_p2_posicion-bolaX;
    velHor = -distDebarra_p2_Center/10;
    velVert = -velVert;
    bolaY = (barra_p2.height*2);
    sonidoBarra.rewind();
    sonidoBarra.play();
  }
  
}
// Cuando la bola colisiona la barra acción
boolean barra_p1_Colisionbola()
{
  float distDebarra_p1_Center = barra_p1_posicion-bolaX;
  return (bolaY > height-(barra_p1.height*2)) && (bolaY < height-(barra_p1.height/2)) && (abs(distDebarra_p1_Center)<barra_p1.width/2);
}

boolean barra_p2_Colisionbola()
{
  float distDebarra_p2_Center = barra_p2_posicion-bolaX;
  return (bolaY < (barra_p2.height*2)) && (bolaY > (barra_p2.height/2)) && (abs(distDebarra_p2_Center)<barra_p2.width/2);
}

// El rebote de la bola con la pared, dirección y sonido
void rebotePared()
{
  velHor = -velHor; 
  sonidoPared.rewind();
  sonidoPared.play();
}


void stop()
{
  arduino.stop();
}

void buscarArduino()   // Buscar el arduino
{
  try {
    for(int i=0; i<Serial.list().length ;i++) {
      if(Serial.list()[i].contains("tty.usb")) {
        arduino = new Serial(this, Serial.list()[i], 9600);
      }
    }  // Si hay error lo informa
  } catch(Exception e) {
   
  }
}