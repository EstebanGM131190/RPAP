/*
Nodo Ambiental A2/A3

Localización: Edificio B - Iteso
Geolocalización:
  Latitud:  20.6080712 N 
  Longitud: -103.4176272 W
  
Medio de comunicación: ZigBee
ZigBee ID: 013A200 40E5573B

Primera instalación: 4 de abril de 2017

*/

// Step 1. Includes of the Sensor Board and Communications modules used

#include <WaspSensorGas_v20.h>
#include <WaspXBeeZB.h>

// El tiempo correcto para WAITTIME es de 1000.
// Valores más pequeños permiten realizar pruebas de manera práctica
//#define WAITTIME 1000
#define WAITTIME 100

// Destination MAC address
//////////////////////////////////////////
char RX_ADDRESS[] = "0";
//////////////////////////////////////////
uint8_t  PANID[8]={0x00,0x00,0x00,0x00,0x00,0x00,0x95,0x95};

// Step 2. Variables declaration

char  CONNECTOR_A[5] = "Temp";      
char  CONNECTOR_B[4] = "Hum";    
char  CONNECTOR_C[4] = "C02";
char  CONNECTOR_D[4] = "NO2";
char  CONNECTOR_E[3] = "O2";
char  CONNECTOR_F[3] = "CO";

char sensdata[300];
char sensdata1[300];
long  sequenceNumber = 0;       
                                               
char  nodeID[10] = "A2";                 // Se definen dos nodos lógicos, dada la longitud límiite de las tramas ZigBee
char  nodeID1[10] = "A3";                // A2 y A3 con diferentes sensores cada uno
char* sleepTime = "00:00:15:00";         // Tiempo de inactividad      

char data[100];     
char dataDNS[15];

float connectorAFloatValue; 
float connectorBFloatValue;  
float connectorCFloatValue;    
float connectorDFloatValue;   
float connectorEFloatValue;
float connectorFFloatValue;

int connectorAIntValue;
int connectorBIntValue;
int connectorCIntValue;
int connectorDIntValue;
int connectorEIntValue;
int connectorFIntValue;

int contador;
char  CNT[5];


char  connectorAString[10];  
char  connectorBString[10];   
char  connectorCString[10];
char  connectorDString[10];
char  connectorEString[10];
char  connectorFString[10];

int   batteryLevel;
char  batteryLevelString[10];
char  BATTERY[4] = "BAT";

char  TIME_STAMP[3] = "TS";
char  timeStamp[20];
packetXBee* packet;
char* macAddress="0000000000000000"; 



uint8_t error;
uint8_t sd_answer;
// define variable for communication status
uint8_t status;

char* filename="FILEDATA.TXT";

uint8_t divisor = 30;



// choose socket (SELECT USER'S SOCKET)
///////////////////////////////////////
uint8_t socket=SOCKET0;
///////////////////////////////////////

// define timeout for listening to messages
#define TIMEOUT 10000

// variable to measure time
unsigned long previous;


void setup() 
{ 
  RTC.ON(); 
  // init USB port
  USB.ON();
  USB.println(F("Nodo Waspmote Edificio B"));

  //////////////////////////
  // 1. init XBee
  //////////////////////////
 
  xbeeZB.ON();
 
    // 1.5. wait for the module to set the parameters
  delay(10000);

  //////////////////////////
  // 2. check XBee's network parameters
  //////////////////////////
  packet=(packetXBee*) calloc(1,sizeof(packetXBee));
  packet->mode=UNICAST;
  checkNetworkParams();
}

void loop()
{
  RTC.ON(); 
  USB.println("Inicio"); 

  RTC.getTime();
//   USB.printf(RTC.year, RTC.month, RTC.day, RTC.hour,  RTC.minute,  RTC.second );
    snprintf(timeStamp, sizeof(timeStamp), "%02u:%02u:%02u:%02u:%02u:%02u", RTC.year, RTC.month, RTC.date, RTC.hour,  RTC.minute,  RTC.second );

   USB.printf("\n");
   USB.println("Sensando");   
   USB.printf("\n*** CALL MEASURE ***");
   measure();
   USB.printf("\n*** RETURN OF MEASURE***");
   delay(70);

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Send Data
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
    get_bat();
    USB.println("get_bat");
    
    USB.println(timeStamp);
    snprintf(sensdata, sizeof(sensdata), "ID;A2;AC;TD");
    snprintf(sensdata, sizeof(sensdata),"%s;TS;%s",sensdata,timeStamp);
    snprintf(sensdata, sizeof(sensdata),"%s;BAT;%s",sensdata,batteryLevelString);
 
    RTC.getTime();
//   USB.printf(RTC.year, RTC.month, RTC.day, RTC.hour,  RTC.minute,  RTC.second );
    snprintf(timeStamp, sizeof(timeStamp), "%02u:%02u:%02u:%02u:%02u:%02u", RTC.year, RTC.month, RTC.date, RTC.hour,  RTC.minute,  RTC.second );
    USB.println(timeStamp);
    
    snprintf(sensdata1, sizeof(sensdata1), "ID;A3;AC;TD");
    snprintf(sensdata1, sizeof(sensdata1),"%s;TS;%s",sensdata1,timeStamp);
    snprintf(sensdata1, sizeof(sensdata1),"%s;BAT;%s",sensdata1,batteryLevelString);
    
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_A,connectorAString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_B,connectorBString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_D,connectorDString);
    
    snprintf(sensdata1, sizeof(sensdata1),"%s;%s;%s",sensdata1,CONNECTOR_C,connectorCString);
    snprintf(sensdata1, sizeof(sensdata1),"%s;%s;%s",sensdata1,CONNECTOR_E,connectorEString);
    snprintf(sensdata1, sizeof(sensdata1),"%s;%s;%s",sensdata1,CONNECTOR_F,connectorFString);  

    USB.println(sensdata);
    USB.println(sensdata1);

  // Transmisión ZigBee   
  //////////////////////////
  // 1. create frame
  //////////////////////////  
    xbeeZB.ON();
  //xbeeZB.sendCommandAT("DA");  
  delay(5000);
  checkNetworkParams();
  
    xbeeZB.setDestinationParams( packet, macAddress, sensdata);

//  // 1.1. create new frame
//  frame.createFrame(ASCII);  
//
//  // 1.2. add frame fields
//  frame.addSensor(SENSOR_STR, "Paquete"); 
//  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel() ); 
//  
//  USB.println(F("\n1. Created frame to be sent"));
//  frame.showFrame();
//
//  //////////////////////////
//  // 2. send packet
//  //////////////////////////  
//
//  // send XBee packet
//  error = xbeeZB.send( RX_ADDRESS, frame.buffer, frame.length );  
  
   error=xbeeZB.sendXBee(packet); 
    
  USB.println(F("\n2. Send a packet to the RX node: "));
  
  // check TX flag
  if( error == 0 )
  {
    USB.println(F("send ok"));
    
  }
  else 
  {
    USB.println(F("send error"));
    
  }

  delay(60000);
  
    xbeeZB.setDestinationParams( packet, macAddress, sensdata1);

//  //////////////////////////
//  // 2. send packet
//  //////////////////////////  
//
//  // send XBee packet
//  error = xbeeZB.send( RX_ADDRESS, frame.buffer, frame.length );  
  
   error=xbeeZB.sendXBee(packet); 
    
  USB.println(F("\n2. Send a packet to the RX node: "));
  
  // check TX flag
  if( error == 0 )
  {
    USB.println(F("send ok"));
    
  }
  else 
  {
    USB.println(F("send error"));
    
  }
 // Tarea Final del Loop   
      USB.printf("Going to Sleepe with: ", sleepTime);
      USB.println(sleepTime);      
      PWR.deepSleep(sleepTime,RTC_OFFSET,RTC_ALM1_MODE1,ALL_OFF);

}  
    
 

/*******************************************
 *
 *  checkNetworkParams - Check operating
 *  network parameters in the XBee module
 *
 *******************************************/
void checkNetworkParams()
{
  // 1. get operating 64-b PAN ID
  xbeeZB.getOperating64PAN();

  // 2. wait for association indication
  xbeeZB.getAssociationIndication();

  while( xbeeZB.associationIndication != 0 )
  {   
    printAssociationState();

    delay(2000);

    // get operating 64-b PAN ID
    xbeeZB.getOperating64PAN();

    USB.print(F("operating 64-b PAN ID: "));
    USB.printHex(xbeeZB.operating64PAN[0]);
    USB.printHex(xbeeZB.operating64PAN[1]);
    USB.printHex(xbeeZB.operating64PAN[2]);
    USB.printHex(xbeeZB.operating64PAN[3]);
    USB.printHex(xbeeZB.operating64PAN[4]);
    USB.printHex(xbeeZB.operating64PAN[5]);
    USB.printHex(xbeeZB.operating64PAN[6]);
    USB.printHex(xbeeZB.operating64PAN[7]);
    USB.println();     

    xbeeZB.getAssociationIndication();
  }

  USB.println(F("\nJoined a network!"));

  // 3. get network parameters 
  xbeeZB.getOperating16PAN();
  xbeeZB.getOperating64PAN();
  xbeeZB.getChannel();

  USB.print(F("operating 16-b PAN ID: "));
  USB.printHex(xbeeZB.operating16PAN[0]);
  USB.printHex(xbeeZB.operating16PAN[1]);
  USB.println();

  USB.print(F("operating 64-b PAN ID: "));
  USB.printHex(xbeeZB.operating64PAN[0]);
  USB.printHex(xbeeZB.operating64PAN[1]);
  USB.printHex(xbeeZB.operating64PAN[2]);
  USB.printHex(xbeeZB.operating64PAN[3]);
  USB.printHex(xbeeZB.operating64PAN[4]);
  USB.printHex(xbeeZB.operating64PAN[5]);
  USB.printHex(xbeeZB.operating64PAN[6]);
  USB.printHex(xbeeZB.operating64PAN[7]);
  USB.println();

  USB.print(F("channel: "));
  USB.printHex(xbeeZB.channel);
  USB.println();

}





/*******************************************
 *
 *  printAssociationState - Print the state 
 *  of the association flag
 *
 *******************************************/
void printAssociationState()
{
  switch(xbeeZB.associationIndication)
  {
  case 0x00  :  
    USB.println(F("Successfully formed or joined a network"));
    break;
  case 0x21  :  
    USB.println(F("Scan found no PANs"));
    break;    
  case 0x22  :  
    USB.println(F("Scan found no valid PANs based on current SC and ID settings"));
    break;    
  case 0x23  :  
    USB.println(F("Valid Coordinator or Routers found, but they are not allowing joining (NJ expired)"));
    break;    
  case 0x24  :  
    USB.println(F("No joinable beacons were found"));
    break;    
  case 0x25  :  
    USB.println(F("Unexpected state, node should not be attempting to join at this time"));
    break;
  case 0x27  :  
    USB.println(F("Node Joining attempt failed"));
    break;
  case 0x2A  :  
    USB.println(F("Coordinator Start attempt failed"));
    break;
  case 0x2B  :  
    USB.println(F("Checking for an existing coordinator"));
    break;
  case 0x2C  :  
    USB.println(F("Attempt to leave the network failed"));
    break;
  case 0xAB  :  
    USB.println(F("Attempted to join a device that did not respond."));
    break;
  case 0xAC  :  
    USB.println(F("Secure join error: network security key received unsecured"));
    break;
  case 0xAD  :  
    USB.println(F("Secure join error: network security key not received"));
    break;
  case 0xAF  :  
    USB.println(F("Secure join error: joining device does not have the right preconfigured link key"));
    break;
  case 0xFF  :  
    USB.println(F("Scanning for a ZigBee network (routers and end devices)"));
    break;
  default    :  
    USB.println(F("Unkown associationIndication"));
    break;  
  }
}

void get_bat()
{
    PWR.getBatteryLevel();
    // Getting Battery Level
    batteryLevel = PWR.getBatteryLevel();
    // Conversion into a string
    itoa(batteryLevel, batteryLevelString, 10);
}


void measure()
{
  USB.printf("\n*** BEGIN OF MEASURE ***");
  
  //
  // Encendido de tarjeta de sensores
    SensorGasv20.ON();
    delay(WAITTIME);
    USB.printf("\n*** Tarjeta de gases encendida ***");
  //
  // Configuración de sensores
  // 
    // Temp - Temperatura - No necesita ser configurado ni encendido
    
    // Hum - Humedad - No necesita ser configurado ni encendido
    
    // Configuración de sensor CO2  
    SensorGasv20.configureSensor(SENS_CO2, 7);
    
    // Configuración de sensor NO2
    SensorGasv20.configureSensor(SENS_SOCKET3B, 1, 2);
    
    // Configuración de sensor O2
    SensorGasv20.configureSensor(SENS_O2, 1);
    
    // Configuración de sensor CO
    SensorGasv20.configureSensor(SENS_SOCKET4CO, 1, 100);
 
     USB.printf("\n*** Sensores configurados ***");
  //
  // Encendido de sensores
  //
    // Temp - Temperatura - No necesita ser configurado ni encendido
    
    // Hum - Humedad - No necesita ser configurado ni encendido
    
    // Encendido de sensor CO2
    SensorGasv20.setSensorMode(SENS_ON, SENS_CO2); 

    // Encendido de sensor NO2
    SensorGasv20.setSensorMode(SENS_ON, SENS_SOCKET3B);
    
    // Encendido de sensor O2: No necesita ser encendido
 
    // Encendido de sensor CO
    SensorGasv20.setSensorMode(SENS_ON, SENS_SOCKET4CO);
    
    USB.printf("\n*** Sensores encendidos ***");
    
  //
  // Lectura de sensores - apagado tras lectura
  //
    // Lectura de sensor CO
    // Tiempo de respuesta/espera
    delay(WAITTIME);
    //First dummy reading to set analog-to-digital channel
    SensorGasv20.readValue(SENS_SOCKET4CO);
    connectorFFloatValue = SensorGasv20.readValue(SENS_SOCKET4CO);    
    //Conversion into a string
    dtostrf(connectorFFloatValue,1,2,connectorFString);
    
    // Apagado de sensor
    SensorGasv20.setSensorMode(SENS_OFF, SENS_SOCKET2B);
    
    USB.printf("\n*** Sensor CO leido ***");
    
    // Lectura de sensor Temp
    // Tiempo de respuesta/espera
    delay(WAITTIME);
    //First dummy reading for analog-to-digital converter channel selection
    SensorGasv20.readValue(SENS_TEMPERATURE);
    //Sensor temperature reading
    connectorAFloatValue = SensorGasv20.readValue(SENS_TEMPERATURE);
    //Conversion into a string
     dtostrf(connectorAFloatValue,1,2,connectorAString);  

    USB.printf("\n*** Sensor Temp leido ***");

    // Lectura de sensor Hum
    // Tiempo de respuesta/espera
    delay(13*WAITTIME);
    //First dummy reading for analog-to-digital converter channel selection
    SensorGasv20.readValue(SENS_HUMIDITY);
    //Sensor temperature reading
    connectorBFloatValue = SensorGasv20.readValue(SENS_HUMIDITY);
    //Conversion into a string
   dtostrf(connectorBFloatValue,1,2,connectorBString);  

    USB.printf("\n*** Sensor Hum leido ***");

    // Lectura de sensor NO2
    // Tiempo de respuesta/espera
    delay(15*WAITTIME);
    //First dummy reading to set analog-to-digital channel
    SensorGasv20.readValue(SENS_SOCKET3B);
    connectorDFloatValue = SensorGasv20.readValue(SENS_SOCKET3B);    
    //Conversion into a string
   dtostrf(connectorDFloatValue,1,2,connectorDString);
    // Apagado de sensor
    SensorGasv20.setSensorMode(SENS_OFF, SENS_SOCKET3B);

    USB.printf("\n*** Sensor NO2 leido ***");

    // Lectura de sensor O3
    // Tiempo de respuesta/espera
    // Junto con NO2
    //First dummy reading to set analog-to-digital channel
    SensorGasv20.readValue(SENS_O2);
    connectorEFloatValue = SensorGasv20.readValue(SENS_O2);    
    //Conversion into a string
   dtostrf(connectorEFloatValue,1,2,connectorEString);
    // Apagado de sensor: O2 no necesita ser encendido/apagado
     
    USB.printf("\n*** Sensor O2 leido ***");
    
    // Lectura de sensor CO2
    // Tiempo de respuesta/espera
    delay(15*WAITTIME);
    delay(15*WAITTIME);
    delay(15*WAITTIME);
    delay(15*WAITTIME); 
    //First dummy reading to set analog-to-digital channel
    SensorGasv20.readValue(SENS_CO2);
    connectorCFloatValue = SensorGasv20.readValue(SENS_CO2);    
    //Conversion into a string
   dtostrf(connectorCFloatValue,1,2,connectorCString);
    // Apagado de sensor
    SensorGasv20.setSensorMode(SENS_OFF, SENS_CO2);
    
    USB.printf("\n*** Sensor CO2 leido ***");

    
    USB.printf("\n*** END OF MEASURE***");
}


