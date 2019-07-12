/*! \file Wasp_test_lib.cpp
 *  \brief Library for managing NODES 
 *
 *
 *  Version:		2.0
 *  Modified by:	Esteban González Moreno
 *  Nodo Ambiental Aguilas A1
 *
 *  Colonia Las Águilas
 *  Localización: Río Colotlán 1860, Zapopan
 *  Geolocalización:
 *    Latitud:  20°41'29.25"N
 *    Longitud: 103°28'21.67"O
 * 
 *  Medio de comunicación: WiFi
 *  MAC ID: 0006669C1DEF
 *  Hardware: GPRS+GPS
 */

/******************************************************************************
 * Includes            Includes of the Sensor Board and Communications modules used
 ******************************************************************************/
#include <WaspSensorGas_v20.h>
#include <WaspWIFI.h>



/******************************************************************************
 * Definitions & Variable Declarations
 *****************************************************************************/
#define WAITTIME 1000

// TCP server settings
/////////////////////////////////
#define REMOTE_PORT 80
#define LOCAL_PORT 2000
/////////////////////////////////

/////////////////////////////////
//#define ESSID "Totalplay-3940"
//#define AUTHKEY "B0013940"
//#define ESSID "libelium_AP" //WPA2
//#define AUTHKEY "proinnova2015"
#define ESSID "belkin.cb9"
#define AUTHKEY "9e6ce6e3"

// define timeout for listening to messages
#define TIMEOUT 10000


char  CONNECTOR_A[5] = "Temp";      
char  CONNECTOR_B[4] = "Hum";    
char  CONNECTOR_C[4] = "C02";
char  CONNECTOR_D[4] = "NO2";
char  CONNECTOR_E[3] = "03";
char  CONNECTOR_F[3] = "CO";

char  CNT[5];
char  connectorAString[10];  
char  connectorBString[10];   
char  connectorCString[10];
char  connectorDString[10];
char  connectorEString[10];
char  connectorFString[10];

char sensdata[300];                                               
char  nodeID[10] = "A1";   
char* sleepTime = "00:00:30:00";           
char data[100];     
char dataDNS[15];

char  batteryLevelString[10];
char  BATTERY[4] = "BAT";

char  TIME_STAMP[3] = "TS";
char  timeStamp[20];

char* macAddress="000000000000FFFF"; 
char* filename="FILEDATA.TXT";

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

int   batteryLevel;

long  sequenceNumber = 0;       

uint8_t error;
uint8_t sd_answer;
uint8_t status;          // define variable for communication status
uint8_t divisor = 30;


// WEB server settings 
/////////////////////////////////
// Host websoft.com.mx
//char HOST[] = "74.50.121.173";
char HOST[] = "websoft.com.mx";
//char HOST[] = "arduino.cc";

char URL[]  = "GET /nodos/sensiteso.php?data=";
//char URL[]  = "GET$http://websoft.com.mx/nodos/date.php";
//char URL[]  = "GET$/asciilogo.txt";

/////////////////////////////////


/////////////////////////////////
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


/*****************************/
/*****************************/
void setup() 
{
 RTC.ON();  
  // setup WiFi configuration
    wifi_setup(); 
}

void loop()
{
 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 // Init after DeepSleep
 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  RTC.ON(); 
  USB.println("Inicio"); 

    
   RTC.getTime();    // Measure
   if(USB_TEST)  USB.printf(RTC.year, RTC.month, RTC.day, RTC.hour,  RTC.minute,  RTC.second );
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
    
    createFrameXBee();      //CREATES THE DATA FRAME

/* THIS IS NOW A FUNCTION
    snprintf(sensdata, sizeof(sensdata),"ID;%s;AC;TD",nodeID);   
    snprintf(sensdata, sizeof(sensdata),"%s;TS;%s",sensdata,timeStamp);
    snprintf(sensdata, sizeof(sensdata),"%s;BAT;%s",sensdata,batteryLevelString);
    
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_A,connectorAString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_B,connectorBString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_C,connectorCString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_D,connectorDString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_E,connectorEString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_F,connectorFString);  
*/
   if(USB_TEST)    USB.println(sensdata);
    

/************* VARIABHLES NOT USED**********/
//    USB.print(F("body:"));
//    USB.println(body);
    
    
 // Transmisión WiFi
 
    // Switch ON the WiFi module
    WIFI.ON(socket);
   if(USB_TEST)    USB.println("WiFi ON");
  /*********** Variables not Used ***********/
//    itoa(DNS,dataDNS,15);
//    USB.println(dataDNS);  
    
    // Join Network
    if (WIFI.join(ESSID))  
    {
        if(USB_TEST)        USB.println(F("Joined AP"));

        // Call the function to create a TCP connection 
        if (WIFI.setTCPclient(DNS,HOST, REMOTE_PORT, LOCAL_PORT)) 
        { 
          if(USB_TEST)USB.println(F("TCP client set"));

            // Now the connection is open, and we can use send and read functions 
            // to control the connection. Send message to the TCP connection 
            WIFI.send(URL);
            WIFI.send(sensdata);
            WIFI.send(" HTTP/1.1\r\n"); 
            WIFI.send("Host: "); 
            WIFI.send(HOST); 
            WIFI.send("\r\n");
            WIFI.send("Connection: Close\r\n"); 
            WIFI.send("\r\n\r\n");

            // Reads an answer from the TCP connection (NOBLO means NOT BLOCKING)
            if(USB_TEST) USB.println(F("Listen to TCP socket:"));
            previous=millis();
            while(millis()-previous<TIMEOUT)
            {
                if(WIFI.read(NOBLO)>0)
                {
                    for(int j=0; j<WIFI.length; j++)
                    {
                           if(USB_TEST)   USB.print(WIFI.answer[j],BYTE);
                    }
                    USB.println();
                }

                // Condition to avoid an overflow (DO NOT REMOVE)
                if (millis() < previous)
                {
                    previous = millis();	
                }
            }

            //  Closes the TCP connection. 
            if(USB_TEST)USB.println(F("Close TCP socket"));
            WIFI.close(); 
        } 
        else
        {
           if(USB_TEST)   USB.println(F("TCP client NOT set"));
        }
        // Leaves AP
        WIFI.leave();
    }
    else
    {
        if(USB_TEST)   USB.println(F("NOT Connected to AP"));
    }

    WIFI.OFF();  
    if(USB_TEST) USB.println(F("****************************"));
    delay(3000); 
    
    
 // Final assignment of the loop  
      if(USB_TEST)    USB.printf("Going to Sleepe with: ", sleepTime);
      if(USB_TEST)    USB.println(sleepTime);      
      PWR.deepSleep(sleepTime,RTC_OFFSET,RTC_ALM1_MODE1,ALL_OFF);


}


//**************************************************************************************************
//     get_bat()
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


//**************************************************************************************************
//     wifi_setup()
//**************************************************************************************************
//!*************************************************************************************
//!	Name:	wifi_setup()									
//!	Description: Function used to connect to the wifi it has all the necesary configurations
//!           
//!
//!	Param : void														
//!	Returns: void							
//!*************************************************************************************
void wifi_setup()
{
    // Switch ON the WiFi module on the desired socket
    if( WIFI.ON(socket) == 1 )
    {
          if(USB_TEST)  USB.println(F("Wifi switched ON"));
    }
    else
    {
          if(USB_TEST) USB.println(F("Wifi did not initialize correctly"));
    }

    // 1. Configure the transport protocol (UDP, TCP, FTP, HTTP...) 
    WIFI.setConnectionOptions(CLIENT); 
    // 2. Configure the way the modules will resolve the IP address. 
    WIFI.setDHCPoptions(DHCP_ON);    

    // 3. Configure how to connect the AP 
    WIFI.setJoinMode(MANUAL); 
    // 4. Set Authentication key
    WIFI.setAuthKey(WPA2,AUTHKEY); 

    // 5. Store changes  
    WIFI.storeData();

}



//**************************************************************************************************
//     Creat Frame()
//**************************************************************************************************
//!*************************************************************************************
//!	Name:	createFrameXBee()									
//!	Description: Function used to create the XBee data Frame
//!           Works with global variables.
//!           Lot of concatenations.
//!           
//!	Param : void														
//!	Returns: void							
//!*************************************************************************************

void createFrameXBee() {

    // Formación de la trama TD para el sistema de monitoreo.

    memset(sensdata, 0, sizeof(sensdata));
   
    snprintf(sensdata, sizeof(sensdata),"ID;%s;AC;TD",nodeID);   
    snprintf(sensdata, sizeof(sensdata),"%s;TS;%s",sensdata,timeStamp);
    snprintf(sensdata, sizeof(sensdata),"%s;BAT;%s",sensdata,batteryLevelString);
    
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_A,connectorAString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_B,connectorBString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_C,connectorCString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_D,connectorDString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_E,connectorEString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_F,connectorFString);  

}



