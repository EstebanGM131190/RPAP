/*
Nodo Calidad del Agua SW1

Localización: Planta de Tratamiento del Iteso
Geolocalización:
  Latitud:  20.605882 N 
  Longitud: -103.418790 W
  
Medio de comunicación: WiFi

Primera instalación: 28 de marzo de 2017 *1

Útlima instalación: noviemvre 2017 *2

*1 Se utilizaron librerías estándar y no las del Iteso para
disminuir posibles conflictos en el flujo del programa

*2 Se modificó la forma de realizar el GET, pues el proveedor actualizó
servidores y hubo conflicto con la forma anterior. Ahora se realiza
con una coneción directa TCP.

 */

// Step 1. Includes of the Sensor Board and Communications modules used

#include <WaspWIFI.h>
#include <WaspSensorSW.h>


#define WAITTIME 1000

// Step 2. Variables declaration

   
char  CONNECTOR_B[4] = "ORP";
char  CONNECTOR_C[3] = "PH";  
char  CONNECTOR_D[5] = "Temp";
char  CONNECTOR_E[4] = "DO";    
char  CONNECTOR_F[4] = "CON";

char sensdata[300];
long  sequenceNumber = 0;       
                                               
char  nodeID[10] = "PT1";                 //NODO CON EL QUE SE VA A TRABAJAR, PARA CHECAR EN ITESO SE TIENE QUE SELEECIONAR UNO QUE YA ESTE DADO DE ALTA

char* sleepTime = "00:00:01:00";         //TIEMPO PARA RECIBIR MEDICIONES      

char data[100];     
char dataDNS[15];

float connectorBFloat_OxyRedPot;
float connectorCFloat_pH; 
float connectorDFloat_Temp;
float connectorEFloat_dissOxy;  
float connectorFFloat_Conduc;    

float connectorBFloat_OxyRedPot_calculated;
float connectorCFloat_pH_calculated; 
float connectorEFloat_dissOxy_calculated;  
float connectorFFloat_Conduc_calculated;    


// Calibration values
#define cal_point_10 2.059
#define cal_point_7 2.11
#define cal_point_4 2.253
// Temperature at which calibration was carried out
#define cal_temp 24.82
// Offset obtained from sensor calibration
#define calibration_offset 0.017
// Calibration of the sensor in normal air
#define air_calibration 1.8956
// Calibration of the sensor under 0% solution
#define zero_calibration 0.0
// Value 1 used to calibrate the sensor
#define point1_cond 12880
// Value 2 used to calibrate the sensor
#define point2_cond 80000
// Point 1 of the calibration 
#define point1_cal 178.92
// Point 2 of the calibration 
#define point2_cal 78.83

pHClass pHSensor;
ORPClass OxyRedPotSensor;
DOClass DissOxySensor;
conductivityClass ConductivitySensor;
pt1000Class TemperatureSensor;

int contador;
char  CNT[5];

char connectorBString_OxyRedPot[10];
char connectorCString_pH[10];
char connectorDString_Temp[10];
char connectorEString_dissOxy[10];  
char connectorFString_Conduc[10];    



int   batteryLevel;
char  batteryLevelString[10];
char  BATTERY[4] = "BAT";

char  TIME_STAMP[3] = "TS";
char  timeStamp[20];

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

// WiFi AP settings (CHANGE TO USER'S AP)
/////////////////////////////////
//#define ESSID "libelium_AP"
//#define AUTHKEY "proinnova2015"
//#define ESSID "INFINITUM148490"      
//#define AUTHKEY "B7DCF0E370"
//#define ESSID "belkin.cb9"      
//#define AUTHKEY "9e6ce6e3"
#define ESSID "libelium_AP" 
#define AUTHKEY "proinnova2015"


// WEB server settings 
/////////////////////////////////
char HOST[] = "papvidadigital-test.com";
//char HOST[] = "72.9.150.56";
char URL[]  = "GET$/nodos/sensiteso.php?data=";



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

  // Configure the calibration values
  pHSensor.setCalibrationPoints(cal_point_10, 
								cal_point_7, 
								cal_point_4, 
								cal_temp);
  DissOxySensor.setCalibrationPoints(air_calibration, zero_calibration);
  ConductivitySensor.setCalibrationPoints(point1_cond, 
										  point1_cal, 
										  point2_cond, 
										  point2_cal);
  
  SensorSW.ON();
 
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
   USB.println("\n*** CALL MEASURE ***");
   measure();
   USB.println("\n*** RETURN OF MEASURE***");
   delay(70);

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Send Data
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
    get_bat();
    USB.println("get_bat");
    
    //snprintf(sensdata, sizeof(sensdata), "sensiteso.php?data=");
    snprintf(sensdata, sizeof(sensdata),"ID;PT1;AC;TD");
    snprintf(sensdata, sizeof(sensdata),"%s;TS;%s",sensdata,timeStamp);
    snprintf(sensdata, sizeof(sensdata),"%s;BAT;%s",sensdata,batteryLevelString);
    
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_B,connectorBString_OxyRedPot);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_C,connectorCString_pH);
   snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_D,connectorDString_Temp);     
   snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_E,connectorEString_dissOxy);
   snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_F,connectorFString_Conduc);
  
 
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
          USB.println(F("NOT joined"));
    }

    WIFI.OFF();  
    USB.println(F("****************************"));
    
    
    contador=contador+1;
 
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
  USB.println("\n*** BEGIN OF MEASURE ***");
  
  ///////////////////////////////////////////
  // 1. Turn on the board
  /////////////////////////////////////////// 
  SensorSW.ON();
  delay(2000);


  ///////////////////////////////////////////
  // 2. Read sensors
  ///////////////////////////////////////////  

  // Read the temperature sensor
  connectorDFloat_Temp = TemperatureSensor.readTemperature();
  dtostrf(connectorDFloat_Temp,1,2,connectorDString_Temp);
  // Reading of the ORP sensor
  connectorBFloat_OxyRedPot = OxyRedPotSensor.readORP();
  // Apply the calibration offset
  connectorBFloat_OxyRedPot_calculated = connectorBFloat_OxyRedPot - calibration_offset;
  dtostrf(connectorBFloat_OxyRedPot_calculated,1,2,connectorBString_OxyRedPot);  
  // Read the ph sensor
  connectorCFloat_pH = pHSensor.readpH();
  // Convert the value read with the information obtained in calibration
  connectorCFloat_pH_calculated = pHSensor.pHConversion(connectorCFloat_pH,connectorDFloat_Temp);
  dtostrf(connectorCFloat_pH_calculated,1,2,connectorCString_pH);
  // Reading of the Dissolved Oxygen sensor
  connectorEFloat_dissOxy = DissOxySensor.readDO();
  // Conversion from volts into dissolved oxygen percentage
  connectorEFloat_dissOxy_calculated = DissOxySensor.DOConversion(connectorEFloat_dissOxy);
  dtostrf(connectorEFloat_dissOxy_calculated,1,2,connectorEString_dissOxy);
  // Reading of the Conductivity sensor
  connectorFFloat_Conduc = ConductivitySensor.readConductivity();
  // Conversion from resistance into ms/cm
  connectorFFloat_Conduc_calculated = ConductivitySensor.conductivityConversion(connectorFFloat_Conduc);
  dtostrf(connectorFFloat_Conduc_calculated,1,2,connectorFString_Conduc);

  
  ///////////////////////////////////////////
  // 3. Turn off the sensors
  /////////////////////////////////////////// 

  SensorSW.OFF();

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

    // 4. Set Authentication key
    WIFI.setAutojoinAuth(WEP);
    WIFI.setAuthKey(WEP,AUTHKEY); 

    WIFI.setJoinMode(MANUAL); 

    // 5. Store changes  
    WIFI.storeData();
    

}
