/*
Nodo Ambiental Aguilas A1

Colonia Las Águilas
Localización: Río Colotlán 1860, Zapopan
Geolocalización:
  Latitud:  20°41'29.25"N
  Longitud: 103°28'21.67"O
  
Medio de comunicación: WiFi
MAC ID: 0006669C1DEF
Hardware: GPRS+GPS
Instalación completa con todos los sensores: 7 de marzo de 2016

 */

// Step 1. Includes of the Sensor Board and Communications modules used

#include <WaspSensorGas_v20.h>
#include <WaspWIFI.h>

#define WAITTIME 1000
//#define WAITTIME 10

// Step 2. Variables declaration

char  CONNECTOR_A[5] = "Temp";      
char  CONNECTOR_B[4] = "Hum";    
char  CONNECTOR_C[4] = "C02";
char  CONNECTOR_D[4] = "NO2";
char  CONNECTOR_E[3] = "03";
char  CONNECTOR_F[3] = "CO";

char sensdata[300];

long  sequenceNumber = 0;       
                                               
char  nodeID[10] = "A1";   

char* sleepTime = "00:00:30:00";           

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

char* macAddress="000000000000FFFF"; 



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

// define timeout for listening to messages
#define TIMEOUT 10000

// variable to measure time
unsigned long previous;


void setup() 
{
 RTC.ON();  
  // setup WiFi configuration
    wifi_setup();
    contador =0;
 
}

void loop()
{
  RTC.ON(); 
  USB.println("Inicio"); 
 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 // Init after DeepSleep
 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Measure
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
    
    snprintf(sensdata, sizeof(sensdata),"ID;%s;AC;TD",nodeID);   
    snprintf(sensdata, sizeof(sensdata),"%s;TS;%s",sensdata,timeStamp);
    snprintf(sensdata, sizeof(sensdata),"%s;BAT;%s",sensdata,batteryLevelString);
    
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_A,connectorAString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_B,connectorBString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_C,connectorCString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_D,connectorDString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_E,connectorEString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_F,connectorFString);  

    USB.println(sensdata);
    

//
//    USB.print(F("body:"));
//    USB.println(body);
    
    
 // Transmisión WiFi
 
    // 1. Switch ON the WiFi module
    WIFI.ON(socket);
    USB.println("WiFi ON");
//    itoa(DNS,dataDNS,15);
//    USB.println(dataDNS);  
    
    // 2. Join Network
    if (WIFI.join(ESSID))  
    {
        USB.println(F("Joined AP"));

        // 3. Call the function to create a TCP connection 
        if (WIFI.setTCPclient(DNS,HOST, REMOTE_PORT, LOCAL_PORT)) 
        { 
            USB.println(F("TCP client set"));

            // 4. Now the connection is open, and we can use send and read functions 
            // to control the connection. Send message to the TCP connection 
            WIFI.send(URL);
            WIFI.send(sensdata);
            WIFI.send(" HTTP/1.1\r\n"); 
            WIFI.send("Host: "); 
            WIFI.send(HOST); 
            WIFI.send("\r\n");
            WIFI.send("Connection: Close\r\n"); 
            WIFI.send("\r\n\r\n");

            // 5. Reads an answer from the TCP connection (NOBLO means NOT BLOCKING)
            USB.println(F("Listen to TCP socket:"));
            previous=millis();
            while(millis()-previous<TIMEOUT)
            {
                if(WIFI.read(NOBLO)>0)
                {
                    for(int j=0; j<WIFI.length; j++)
                    {
                        USB.print(WIFI.answer[j],BYTE);
                    }
                    USB.println();
                }

                // Condition to avoid an overflow (DO NOT REMOVE)
                if (millis() < previous)
                {
                    previous = millis();	
                }
            }

            // 6. Closes the TCP connection. 
            USB.println(F("Close TCP socket"));
            WIFI.close(); 
        } 
        else
        {
            USB.println(F("TCP client NOT set"));
        }
        // 7. Leaves AP
        WIFI.leave();
    }
    else
    {
        USB.println(F("NOT Connected to AP"));
    }

    WIFI.OFF();  
    USB.println(F("****************************"));
    delay(3000); 
    
    
 // Tarea Final del Loop   
      USB.printf("Going to Sleepe with: ", sleepTime);
      USB.println(sleepTime);      
      PWR.deepSleep(sleepTime,RTC_OFFSET,RTC_ALM1_MODE1,ALL_OFF);


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
    
    // Configuración de sensor O3
    SensorGasv20.configureSensor(SENS_SOCKET2B, 1, 10);
    
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
    
    // Encendido de sensor O3
    SensorGasv20.setSensorMode(SENS_ON, SENS_SOCKET2B);

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
    Utils.float2String(connectorFFloatValue, connectorFString, 2);
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
    Utils.float2String(connectorAFloatValue, connectorAString, 2);   

    USB.printf("\n*** Sensor Temp leido ***");

    // Lectura de sensor Hum
    // Tiempo de respuesta/espera
    delay(13*WAITTIME);
    //First dummy reading for analog-to-digital converter channel selection
    SensorGasv20.readValue(SENS_HUMIDITY);
    //Sensor temperature reading
    connectorBFloatValue = SensorGasv20.readValue(SENS_HUMIDITY);
    //Conversion into a string
    Utils.float2String(connectorBFloatValue, connectorBString, 2);  

    USB.printf("\n*** Sensor Hum leido ***");

    // Lectura de sensor NO2
    // Tiempo de respuesta/espera
    delay(15*WAITTIME);
    //First dummy reading to set analog-to-digital channel
    SensorGasv20.readValue(SENS_SOCKET3B);
    connectorDFloatValue = SensorGasv20.readValue(SENS_SOCKET3B);    
    //Conversion into a string
    Utils.float2String(connectorDFloatValue, connectorDString, 2);
    // Apagado de sensor
    SensorGasv20.setSensorMode(SENS_OFF, SENS_SOCKET3B);

    USB.printf("\n*** Sensor NO2 leido ***");

    // Lectura de sensor O3
    // Tiempo de respuesta/espera
    // Junto con NO2
    //First dummy reading to set analog-to-digital channel
    SensorGasv20.readValue(SENS_SOCKET2B);
    connectorEFloatValue = SensorGasv20.readValue(SENS_SOCKET2B);    
    //Conversion into a string
    Utils.float2String(connectorEFloatValue, connectorEString, 2);
    // Apagado de sensor
    SensorGasv20.setSensorMode(SENS_OFF, SENS_SOCKET2B);
    
    USB.printf("\n*** Sensor O3 leido ***");
    
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
    Utils.float2String(connectorCFloatValue, connectorCString, 2);
    // Apagado de sensor
    SensorGasv20.setSensorMode(SENS_OFF, SENS_CO2);
    
    USB.printf("\n*** Sensor CO2 leido ***");

    
    USB.printf("\n*** END OF MEASURE***");
}


/**********************************
 *
 *  wifi_setup - function used to 
 *  configure the WIFI parameters 
 *
 ************************************/
void wifi_setup()
{
    // Switch ON the WiFi module on the desired socket
    if( WIFI.ON(socket) == 1 )
    {
        USB.println(F("Wifi switched ON"));
    }
    else
    {
        USB.println(F("Wifi did not initialize correctly"));
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







