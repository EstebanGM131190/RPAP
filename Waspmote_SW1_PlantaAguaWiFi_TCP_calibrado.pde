/*! \file Wasp_test_lib.cpp
 *  \brief Library for managing NODES 
 *
 *
 *  Version:		2.0
 *  Crea
 *  Modified by:	Esteban González Moreno
 *  Nodo Calidad del Agua SW1
 *  
 *  Localización: Planta de Tratamiento del Iteso
 *  Geolocalización:
 *  Latitud:  20.605882 N 
 *  Longitud: -103.418790 W
 *  
 *  Medio de comunicación: WiFi
 *  
 *  Primera instalación: 28 de marzo de 2017 *1
 *  
 *  Útlima instalación: noviemvre 2017 *2
 *  
 *  *1 Se utilizaron librerías estándar y no las del Iteso para
 *  disminuir posibles conflictos en el flujo del programa
 *  
 *  2 Se modificó la forma de realizar el GET, pues el proveedor actualizó
 *  servidores y hubo conflicto con la forma anterior. Ahora se realiza
 *  con una coneción directa TCP.
 *  
 */




/******************************************************************************
 * Includes            Includes of the Sensor Board and Communications modules used
 ******************************************************************************/
#include <WaspWIFI.h>
#include <WaspSensorSW.h>


/******************************************************************************
 * Definitions & Variable Declarations
 *****************************************************************************/

#define WAITTIME 1000

char  CONNECTOR_B[4] = "ORP";
char  CONNECTOR_C[3] = "PH";  
char  CONNECTOR_D[5] = "Temp";
char  CONNECTOR_E[4] = "DO";    
char  CONNECTOR_F[4] = "CON";

char  sensdata[300];
long  sequenceNumber = 0;       
                                               
char  nodeID[10] = "PT1";                 //NODO CON EL QUE SE VA A TRABAJAR, PARA CHECAR EN ITESO SE TIENE QUE SELEECIONAR UNO QUE YA ESTE DADO DE ALTA

char* sleepTime = "00:00:25:00";         //TIEMPO PARA RECIBIR MEDICIONES      

  
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

pHClass     pHSensor;
ORPClass    OxyRedPotSensor;
DOClass     DissOxySensor;
conductivityClass ConductivitySensor;
pt1000Class TemperatureSensor;



/**********************************************/
/**** TEST MODE  value != 0 for printing,******/
/**********************************************/
int USB_TEST = 1;


/**** NO TIENE UN USO     ******/
//int contador;
/********************************/

/**** NO TIENE UN USO     ******/
//char  CNT[5];
/**** NO TIENE UN USO     ******/

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

/**** NO TIENE UN USO     ******/
//uint8_t error;
/**** NO TIENE UN USO     ******/
/**** NO TIENE UN USO     ******/
//uint8_t sd_answer;
/**** NO TIENE UN USO     ******/
// define variable for communication status
/**** NO TIENE UN USO     ******/
//uint8_t status;
/**** NO TIENE UN USO     ******/
/**** NO TIENE UN USO     ******/
//char* filename="FILEDATA.TXT";
/**** NO TIENE UN USO     ******/
/**** NO TIENE UN USO     ******/
//uint8_t divisor = 30;
/**** NO TIENE UN USO     ******/

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
#define ESSID "libelium_AP"
#define AUTHKEY "proinnova2015"
//#define ESSID "PACO" 
//#define AUTHKEY "B10FF8602D"


// WEB server settings 
/////////////////////////////////
char HOST[] = "papvidadigital-test.com";
//char HOST[] = "72.9.150.56";
char URL[]  = "GET /nodos/sensiteso.php?data=";



// define timeout for listening to messages
#define TIMEOUT 10000

// variable to measure time
unsigned long previous;


void setup() 
{
 RTC.ON();  
  // setup WiFi configuration
    wifi_setup();
   // contador =0;

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
  /** This may change to Water.ON(); if the library of waspSensorSW is in the version 3.0 **/
  SensorSW.ON();
  
 
}

void loop()
{
    RTC.ON(); 
  
    if(USB_TEST) USB.println("Inicio"); 
    RTC.getTime();
    // USB.printf(RTC.year, RTC.month, RTC.day, RTC.hour,  RTC.minute,  RTC.second );
    
    snprintf(timeStamp, sizeof(timeStamp), "%02u:%02u:%02u:%02u:%02u:%02u", RTC.year, RTC.month, RTC.date, RTC.hour,  RTC.minute,  RTC.second );
    
    if(USB_TEST) USB.printf("\n");
    if(USB_TEST) USB.println("Sensando");   
    if(USB_TEST) USB.println("\n*** CALL MEASURE ***");
    measure();
    if(USB_TEST) USB.println("\n*** RETURN OF MEASURE***");
    delay(70);

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Send Data
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
    get_bat();
    if(USB_TEST) USB.println("get_bat");
    createFrameXBee();

    if(USB_TEST) USB.println(sensdata);
    
    

    
 // Transmisión WiFi
 
    // 1. Switch ON the WiFi module
    WIFI.ON(socket);
    if(USB_TEST) USB.println("WiFi ON");

    if(USB_TEST) USB.println(dataDNS);  
    
    // 2. Join Network
    if (WIFI.join(ESSID))  
    {
        if(USB_TEST) USB.println(F("Joined AP"));

        // 3. Call the function to create a TCP connection 
        if (WIFI.setTCPclient(DNS,HOST, REMOTE_PORT, LOCAL_PORT)) 
        { 
           if(USB_TEST)  USB.println(F("TCP client set"));

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
            if(USB_TEST) USB.printf("Sensdata ", sensdata);
            // 5. Reads an answer from the TCP connection (NOBLO means NOT BLOCKING)
            if(USB_TEST) USB.println(F("Listen to TCP socket:"));
            previous=millis();
            while(millis()-previous<TIMEOUT)
            {
                if(WIFI.read(NOBLO)>0)
                {
                    for(int j=0; j<WIFI.length; j++)
                    {
                    if(USB_TEST) USB.print(WIFI.answer[j],BYTE);
                    }
                    if(USB_TEST) USB.println();
                }

                // Condition to avoid an overflow (DO NOT REMOVE)
                if (millis() < previous)
                {
                    previous = millis();	
                }
            }

            // 6. Closes the TCP connection. 
     if(USB_TEST) USB.println(F("Close TCP socket"));
            WIFI.close(); 
        } 
        else
        {
           if(USB_TEST)  USB.println(F("TCP client NOT set"));
        }
        // 7. Leaves AP
        WIFI.leave();
    }
    else
    {
       if(USB_TEST) USB.println(F("NOT joined"));
    }

    WIFI.OFF();  
    if(USB_TEST) USB.println(F("****************************"));
    
   /********************************/
    //contador=contador+1;  Line not used
   /*********************************/

   // Tarea Final del Loop   
    if(USB_TEST) USB.printf("Going to Sleepe with: ", sleepTime);
    if(USB_TEST)  USB.println(sleepTime);      
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
  if(USB_TEST) USB.println("\n*** BEGIN OF MEASURE ***");
  
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
        if(USB_TEST) USB.println(F("Wifi switched ON"));
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
    WIFI.setAutojoinAuth(WEP);
    WIFI.setAuthKey(WEP,AUTHKEY); 


    // 5. Saves current configuration.
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
   
    snprintf(sensdata, sizeof(sensdata),"ID;PT1;AC;TD");
    snprintf(sensdata, sizeof(sensdata),"%s;TS;%s",sensdata,timeStamp);
    snprintf(sensdata, sizeof(sensdata),"%s;BAT;%s",sensdata,batteryLevelString);
    
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_B,connectorBString_OxyRedPot);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_C,connectorCString_pH);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_D,connectorDString_Temp);     
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_E,connectorEString_dissOxy);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_F,connectorFString_Conduc);

}
