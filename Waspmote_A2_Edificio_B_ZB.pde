
/*! \file Wasp_test_lib.cpp
 *  \brief Library for managing NODES 
 *
 *
 *  Version:		2.0
 *  Crea
 *  Modified by:	Esteban González Moreno
 *  Nodo ambiental A2 Edificio B
 *  
 * 
 * Localización: Edificio B - Iteso
 * Geolocalización:
 * Latitud:  20.6080712 N 
 * Longitud: -103.4176272 W
 * 
 * Medio de comunicación: ZigBee
 * ZigBee ID: 013A200 40E5573B
 * 
 * Primera instalación: 4 de abril de 2017
 *  
 */


/******************************************************************************
 * Includes            Includes of the Sensor Board and Communications modules used
 ******************************************************************************/
#include <WaspSensorGas_v20.h>
#include <WaspXBeeZB.h>



/******************************************************************************
 * Definitions & Variable Declarations
 *****************************************************************************/

// The default wait time value is 1000
#define WAITTIME 1000

/********** VARIABLE NOT USED ********************************/
// define timeout for listening to messages
#define TIMEOUT 10000

// Destination MAC address
//////////////////////////////////////////
char RX_ADDRESS[] = "0";
//////////////////////////////////////////
uint8_t  PANID[8]={0x00,0x00,0x00,0x00,0x00,0x00,0x95,0x95};


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

// variable to measure time
unsigned long previous;



/**********************************************/
/**** TEST MODE  value != 0 for printing,******/
/**********************************************/
int USB_TEST = 1;



void setup() 
{ 
  RTC.ON(); 
  USB.ON();  // init USB port
  
  USB.println(F("Nodo Waspmote Edificio B"));

  //////////////////////////
  // 1. init XBee
  //////////////////////////
 
  xbeeZB.ON();
 
  delay(10000);     // 1.5. wait for the module to set the parameters


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
    if(USB_TEST)   USB.printf(RTC.year, RTC.month, RTC.day, RTC.hour,  RTC.minute,  RTC.second );
    snprintf(timeStamp, sizeof(timeStamp), "%02u:%02u:%02u:%02u:%02u:%02u", RTC.year, RTC.month, RTC.date, RTC.hour,  RTC.minute,  RTC.second );

   if(USB_TEST)   USB.printf("\n");
   if(USB_TEST)   USB.println("Sensando");   
   if(USB_TEST)   USB.printf("\n*** CALL MEASURE ***");

   measure();

   if(USB_TEST)   USB.printf("\n*** RETURN OF MEASURE***");
   delay(70);

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Send Data
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
    get_bat();
    if(USB_TEST)    USB.println("get_bat");
    
    if(USB_TEST)    USB.println(timeStamp);
    snprintf(sensdata, sizeof(sensdata), "ID;A2;AC;TD");
    snprintf(sensdata, sizeof(sensdata),"%s;TS;%s",sensdata,timeStamp);
    snprintf(sensdata, sizeof(sensdata),"%s;BAT;%s",sensdata,batteryLevelString);
 
    RTC.getTime();
//   USB.printf(RTC.year, RTC.month, RTC.day, RTC.hour,  RTC.minute,  RTC.second );
    snprintf(timeStamp, sizeof(timeStamp), "%02u:%02u:%02u:%02u:%02u:%02u", RTC.year, RTC.month, RTC.date, RTC.hour,  RTC.minute,  RTC.second );
    if(USB_TEST)    USB.println(timeStamp);
    
    snprintf(sensdata1, sizeof(sensdata1), "ID;A3;AC;TD");
    snprintf(sensdata1, sizeof(sensdata1),"%s;TS;%s",sensdata1,timeStamp);
    snprintf(sensdata1, sizeof(sensdata1),"%s;BAT;%s",sensdata1,batteryLevelString);
    
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_A,connectorAString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_B,connectorBString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_D,connectorDString);
    
    snprintf(sensdata1, sizeof(sensdata1),"%s;%s;%s",sensdata1,CONNECTOR_C,connectorCString);
    snprintf(sensdata1, sizeof(sensdata1),"%s;%s;%s",sensdata1,CONNECTOR_E,connectorEString);
    snprintf(sensdata1, sizeof(sensdata1),"%s;%s;%s",sensdata1,CONNECTOR_F,connectorFString);  

    if(USB_TEST)    USB.println(sensdata);
    if(USB_TEST)    USB.println(sensdata1);

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
/********* ghost code **********/
//  frame.createFrame(ASCII);  
//
//  // 1.2. add frame fields
/********* ghost code **********/
///  frame.addSensor(SENSOR_STR, "Paquete"); 
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
/********* ghost code **********/
//  error = xbeeZB.send( RX_ADDRESS, frame.buffer, frame.length );  
  
   error=xbeeZB.sendXBee(packet); 
    
    if(USB_TEST)  USB.println(F("\n2. Send a packet to the RX node: "));
  
   // check TX flag
   if( error == 0 ){
        if(USB_TEST)  USB.println(F("send ok"));
   }
   else {
        if(USB_TEST) USB.println(F("send error"));
   }

  delay(60000);
  
  xbeeZB.setDestinationParams( packet, macAddress, sensdata1);

//  //////////////////////////
//  // 2. send packet
//  //////////////////////////  
//
//  // send XBee packet
/********* ghost code **********/
//  error = xbeeZB.send( RX_ADDRESS, frame.buffer, frame.length );  
  
   error=xbeeZB.sendXBee(packet); 
    
   if(USB_TEST)  USB.println(F("\n2. Send a packet to the RX node: "));
  
  // check TX flag
  if( error == 0 )
  {
      if(USB_TEST)  USB.println(F("send ok"));
    
  }
  else 
  {
      if(USB_TEST) USB.println(F("send error"));
    
  }
 // Final assignment of the loop   
    if(USB_TEST)      USB.printf("Going to Sleepe with: ", sleepTime);
    if(USB_TEST)      USB.println(sleepTime);      
    if(USB_TEST)      PWR.deepSleep(sleepTime,RTC_OFFSET,RTC_ALM1_MODE1,ALL_OFF);

}  
    
 

 
//**************************************************************************************************
//  checkNetworkParams
//**************************************************************************************************
//!*************************************************************************************
//!	Name:	get_bat()									
//!	Description: Check operating network parameters in the XBee module
//!	Param : void														
//!	Returns: void							
//!*************************************************************************************
void checkNetworkParams()
{
  // 1. get operating 64-b PAN ID
  xbeeZB.getOperating64PAN();

  // 2. wait for association indication
  xbeeZB.getAssociationIndication();

  while( xbeeZB.associationIndication != 0 )
  {   
    if(USB_TEST)    printAssociationState();

    delay(2000);

    // get operating 64-b PAN ID
    xbeeZB.getOperating64PAN();

    if(USB_TEST)    USB.print(F("operating 64-b PAN ID: "));
    if(USB_TEST)    USB.printHex(xbeeZB.operating64PAN[0]);
    if(USB_TEST)    USB.printHex(xbeeZB.operating64PAN[1]);
    if(USB_TEST)    USB.printHex(xbeeZB.operating64PAN[2]);
    if(USB_TEST)    USB.printHex(xbeeZB.operating64PAN[3]);
    if(USB_TEST)    USB.printHex(xbeeZB.operating64PAN[4]);
    if(USB_TEST)    USB.printHex(xbeeZB.operating64PAN[5]);
    if(USB_TEST)    USB.printHex(xbeeZB.operating64PAN[6]);
    if(USB_TEST)    USB.printHex(xbeeZB.operating64PAN[7]);
    if(USB_TEST)    USB.println();     

    xbeeZB.getAssociationIndication();
  }

    if(USB_TEST)  USB.println(F("\nJoined a network!"));

  // 3. get network parameters 
  xbeeZB.getOperating16PAN();
  xbeeZB.getOperating64PAN();
  xbeeZB.getChannel();

    if(USB_TEST)  USB.print(F("operating 16-b PAN ID: "));
    if(USB_TEST)  USB.printHex(xbeeZB.operating16PAN[0]);
    if(USB_TEST)  USB.printHex(xbeeZB.operating16PAN[1]);
    if(USB_TEST)  USB.println();

    if(USB_TEST)  USB.print(F("operating 64-b PAN ID: "));
    if(USB_TEST)  USB.printHex(xbeeZB.operating64PAN[0]);
    if(USB_TEST)  USB.printHex(xbeeZB.operating64PAN[1]);
    if(USB_TEST)  USB.printHex(xbeeZB.operating64PAN[2]);
    if(USB_TEST)  USB.printHex(xbeeZB.operating64PAN[3]);
    if(USB_TEST)  USB.printHex(xbeeZB.operating64PAN[4]);
    if(USB_TEST)  USB.printHex(xbeeZB.operating64PAN[5]);
    if(USB_TEST)  USB.printHex(xbeeZB.operating64PAN[6]);
    if(USB_TEST)  USB.printHex(xbeeZB.operating64PAN[7]);
    if(USB_TEST)  USB.println();

    if(USB_TEST)  USB.print(F("channel: "));
    if(USB_TEST)  USB.printHex(xbeeZB.channel);
    if(USB_TEST)  USB.println();

}





 
//**************************************************************************************************
//  printAssociationState -
//**************************************************************************************************
//!*************************************************************************************
//!	Name:	get_bat()									
//!	Description: Print the state of the association flag
//!	Param : void														
//!	Returns: void							
//!*************************************************************************************
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

//**************************************************************************************************
//     get_battery level
//**************************************************************************************************
//!*************************************************************************************
//!	Name:	get_bat()									
//!	Description: Function used to get the current value of the battery and save it into the variable batteryLevelString
//!	Param : void														
//!	Returns: void							
//!*************************************************************************************

void get_bat()
{
    PWR.getBatteryLevel();
    // Getting Battery Level
    batteryLevel = PWR.getBatteryLevel();
    // Conversion into a string
    itoa(batteryLevel, batteryLevelString, 10);
}



//**************************************************************************************************
//     measure()
//**************************************************************************************************
//!*************************************************************************************
//!	Name:	measure()									
//!	Description: Function used to measure the sensors values of the waspmote and save them into various strings
//!              connectorDString_Temp        Temperature string
//!              connectorBString_OxyRedPot   ORP  string
//!              connectorCString_pH          PH   string
//!              connectorEString_dissOxy     Disolved Oxygen string
//!              connectorFString_Conduc      Conductiviti String
//!
//!	Param : void														
//!	Returns: void							
//!*************************************************************************************
void measure()
{
  USB.printf("\n*** BEGIN OF MEASURE ***");
  
  //
  // Sensor board on
    SensorGasv20.ON();
    delay(WAITTIME);
    if(USB_TEST) USB.printf("\n*** Tarjeta de gases encendida ***");
  //
  // Sensor configuration
  // 
    // Temp - Temperature - Doesnt need to be configured or turned on
    
    // Hum - Humidity - Doesnt need to be configured or turned on
    
    // CO2 Sensor Configuration 
    SensorGasv20.configureSensor(SENS_CO2, 7);
    
    // NO2 Sensor Configuration
    SensorGasv20.configureSensor(SENS_SOCKET3B, 1, 2);
    
    // O3 Sensor Configuration
    SensorGasv20.configureSensor(SENS_SOCKET2B, 1, 10);
    
    // CO Sensor Configuration
    SensorGasv20.configureSensor(SENS_SOCKET4CO, 1, 100);
 
    if(USB_TEST)  USB.printf("\n*** Sensores configurados ***");
  //
  // Sensors ON
  //
    
    // CO2 
    SensorGasv20.setSensorMode(SENS_ON, SENS_CO2); 

    // NO2
    SensorGasv20.setSensorMode(SENS_ON, SENS_SOCKET3B);
    
    // O3
    SensorGasv20.setSensorMode(SENS_ON, SENS_SOCKET2B);

    // CO
    SensorGasv20.setSensorMode(SENS_ON, SENS_SOCKET4CO);
    
    if(USB_TEST) USB.printf("\n*** Sensores encendidos ***");
    
  //
  // Sensor READ - shutted down after sensing
  //
    // CO
    // Delay time
    delay(WAITTIME);
    //First dummy reading to set analog-to-digital channel
    SensorGasv20.readValue(SENS_SOCKET4CO);
    connectorFFloatValue = SensorGasv20.readValue(SENS_SOCKET4CO);    
    //Conversion into a string
    Utils.float2String(connectorFFloatValue, connectorFString, 2);
    // shut it off
    SensorGasv20.setSensorMode(SENS_OFF, SENS_SOCKET2B);
    
    if(USB_TEST)  USB.printf("\n*** Sensor CO leido ***");
    
    // Temperature sensor read
    delay(WAITTIME);
    //First dummy reading for analog-to-digital converter channel selection
    SensorGasv20.readValue(SENS_TEMPERATURE);
    //Sensor temperature reading
    connectorAFloatValue = SensorGasv20.readValue(SENS_TEMPERATURE);
    //Conversion into a string
    Utils.float2String(connectorAFloatValue, connectorAString, 2);   

    if(USB_TEST)  USB.printf("\n*** Sensor Temp leido ***");

    // Humidity READ
    delay(13*WAITTIME);
    //First dummy reading for analog-to-digital converter channel selection
    SensorGasv20.readValue(SENS_HUMIDITY);
    //Sensor temperature reading
    connectorBFloatValue = SensorGasv20.readValue(SENS_HUMIDITY);
    //Conversion into a string
    Utils.float2String(connectorBFloatValue, connectorBString, 2);  

    if(USB_TEST)  USB.printf("\n*** Sensor Hum leido ***");

    // NO2 Sensor READ
    delay(15*WAITTIME);
    //First dummy reading to set analog-to-digital channel
    SensorGasv20.readValue(SENS_SOCKET3B);
    connectorDFloatValue = SensorGasv20.readValue(SENS_SOCKET3B);    
    //Conversion into a string
    Utils.float2String(connectorDFloatValue, connectorDString, 2);
    // Apagado de sensor
    SensorGasv20.setSensorMode(SENS_OFF, SENS_SOCKET3B);

    if(USB_TEST)   USB.printf("\n*** Sensor NO2 leido ***");

    // O3 Sensor READ
    SensorGasv20.readValue(SENS_SOCKET2B);
    connectorEFloatValue = SensorGasv20.readValue(SENS_SOCKET2B);    
    //Conversion into a string
    Utils.float2String(connectorEFloatValue, connectorEString, 2);
    // turn off sensor
    SensorGasv20.setSensorMode(SENS_OFF, SENS_SOCKET2B);
    
    if(USB_TEST)  USB.printf("\n*** Sensor O3 leido ***");
    
    // CO2 sensor READ
    delay(60*WAITTIME);
    //First dummy reading to set analog-to-digital channel
    SensorGasv20.readValue(SENS_CO2);
    connectorCFloatValue = SensorGasv20.readValue(SENS_CO2);    
    //Conversion into a string
    Utils.float2String(connectorCFloatValue, connectorCString, 2);
    // sensor off
    SensorGasv20.setSensorMode(SENS_OFF, SENS_CO2);
    
    if(USB_TEST)   USB.printf("\n*** Sensor CO2 leido ***");
    if(USB_TEST)   USB.printf("\n*** END OF MEASURE***");
}

