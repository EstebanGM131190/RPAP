                                                                                

/*
Nodo Ambiental P4

Sistema Anillo Primavera
Localización: Terreno Iteso "Planillas" 
              Bosque La Primavera
Geolocalización:
  Latitud:  20°34'48.3456"N
  Longitud: 103°30'38.6064"O
  
Medio de comunicación: GSM
No cel: 3317556820
Primera instalación: 24 de febrero de 2017

 */

// Step 1. Includes of the Sensor Board and Communications modules used

#include <WaspSensorGas_v20.h>
#include <Wasp3G.h>
#define WAITTIME 1000

int8_t answer, GPS_status = 0;
char apn[] = "internet.itelcel.com";
char login[] = "webgprs";
char password[] = "webgprs2002";
char aux_str[300];
char aux_str1[300];
char aux_str2[300];
char sensdata[300];
// define variable for communication status
uint8_t status;

// Step 2. Variables declaration

char  CONNECTOR_A[5] = "Temp";      
char  CONNECTOR_B[4] = "Hum";    
char  CONNECTOR_C[4] = "C02";
char  CONNECTOR_D[4] = "NO2";
char  CONNECTOR_E[3] = "03";
char  CONNECTOR_F[3] = "CO";


long  sequenceNumber = 0;       
                                               
char  nodeID[10] = "P4";                 //NODO CON EL QUE SE VA A TRABAJAR, PARA CHECAR EN ITESO SE TIENE QUE SELEECIONAR UNO QUE YA ESTE DADO DE ALTA

char* sleepTime = "00:00:20:00";         //TIEMPO PARA RECIBIR MEDICIONES      

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


uint8_t error;
uint8_t sd_answer;
// define variable for communication status

char* filename="FILEDATA.TXT";

uint8_t divisor = 30;


// define timeout for listening to messages
#define TIMEOUT 10000

// variable to measure time
unsigned long previous;


void setup() 
{
 RTC.ON();  
  // setup WiFi configuration
 
    contador =0;
 //RTC.setTime(string);              //SE AJUSTA EL VALOR DE NUESTRO RTC 
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
    
    snprintf(sensdata, sizeof(sensdata), "ID;P4;AC;TD");
    
    snprintf(sensdata, sizeof(sensdata),"%s;TS;%s",sensdata,timeStamp);
    snprintf(sensdata, sizeof(sensdata),"%s;BAT;%s",sensdata,batteryLevelString);
    
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_A,connectorAString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_B,connectorBString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_C,connectorCString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_D,connectorDString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_E,connectorEString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_F,connectorFString);
    USB.println(sensdata);    
 
    
 // Transmisión GPRS

              sprintf(aux_str,"GET /nodos/sensiteso.php?data=%s HTTP/1.1\r\nHost: websoft.com.mx\r\nConnection: close\r\n\r\n", sensdata);
 //             sprintf(aux_str, "GET /nodos/sensiteso.php?data=%s", sensdataset);
             USB.println(aux_str);
             
              data_cel_setup();
if (answer == 1){
              USB.println(F("Contactando servidor..."));
               // 6. gets URL from the solicited URL
              status = _3G.readURL("websoft.com.mx", 80, aux_str);
          
              if( status == 1)
              {
                USB.println(F("\nHTTP query OK."));
                USB.print(F("3G answer:"));
  			  USB.println(_3G.buffer_3G);
  
              }
              else
              {
                USB.println(F("\nHTTP query ERROR"));
              }
}

    // 7. Powers off the 3G module
    _3G.OFF();
    USB.println(F("****************************"));
    
    
 
 
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
    SensorGasv20.readValue(SENS_SOCKET2B);
    connectorEFloatValue = SensorGasv20.readValue(SENS_SOCKET2B);    
    //Conversion into a string
   dtostrf(connectorEFloatValue,1,2,connectorEString);
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
   dtostrf(connectorCFloatValue,1,2,connectorCString);
    // Apagado de sensor
    SensorGasv20.setSensorMode(SENS_OFF, SENS_CO2);
    
    USB.printf("\n*** Sensor CO2 leido ***");

    
    USB.printf("\n*** END OF MEASURE***");
}


/**********************************
 *
 *  data_cel_setup - function used to 
 *  configure the 3G parameters 
 *
 ************************************/

void data_cel_setup()
{	USB.ON();
    // 1. activates the 3G module:

	USB.println(F("**************************"));
	// 1. sets operator parameters
    _3G.set_APN(apn, login, password);
	// And shows them
    _3G.show_APN();
    
    USB.println(F("**************************"));
	
	
    answer = _3G.ON();
    if ((answer == 1) || (answer == -3))
    {
	USB.println(F("3G module ready..."));
	answer = _3G.check(60);  

       if (answer == 1)
       
        { 
            USB.println(F("3G module connected to the network..."));
		
		}
		
		else
		{
			 USB.println(F("3G module NOT connected to internet"));
		}

    }
    else
    {
        // Problem with the communication with the 3G module
        USB.println(F("3G module not started")); 
    }
  
  USB.println(F("Set up done"));
}
