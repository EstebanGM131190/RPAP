                                                                                
/*! \file Wasp_test_lib.cpp
 *  \brief Library for managing NODES 
 *
 *
 *  Version:		2.0
 *  Modified by:	Esteban González Moreno
 * Nodo Ambiental P4
 *
 * Sistema Anillo Primavera
 * Localización: Terreno Iteso "Planillas" 
 *             Bosque La Primavera
 * Geolocalización:
 * Latitud:  20°34'48.3456"N
 * Longitud: 103°30'38.6064"O
 * 
 * Medio de comunicación: GSM
 * No cel: 3317556820
 * Primera instalación: 24 de febrero de 2017
 */


/******************************************************************************
 * Includes            Includes of the Sensor Board and Communications modules used
 ******************************************************************************/
#include <WaspSensorGas_v20.h>
#include <Wasp3G.h>



/******************************************************************************
 * Definitions & Variable Declarations
 *****************************************************************************/
#define WAITTIME 1000

// define timeout for listening to messages
/********* CODE  NOT USED **********/
//#define TIMEOUT 10000


int8_t answer, GPS_status = 0;
char apn[] = "internet.itelcel.com";
char login[] = "webgprs";
char password[] = "webgprs2002";
char aux_str[300];
char aux_str1[300];
char aux_str2[300];
char sensdata[300];


uint8_t status;        // define variable for communication status


char  CONNECTOR_A[5] = "Temp";      
char  CONNECTOR_B[4] = "Hum";    



long  sequenceNumber = 0;       
                                               
char  nodeID[10] = "NPL";                 //NODO CON EL QUE SE VA A TRABAJAR, PARA CHECAR EN ITESO SE TIENE QUE SELEECIONAR UNO QUE YA ESTE DADO DE ALTA

char* sleepTime = "00:00:03:00";         //TIEMPO PARA RECIBIR MEDICIONES      

char data[100];     
char dataDNS[15];

float connectorAFloatValue; 
float connectorBFloatValue;  


int connectorAIntValue;
int connectorBIntValue;


int contador;
char  CNT[5];


char  connectorAString[10];  
char  connectorBString[10];   


int   batteryLevel;
char  batteryLevelString[10];
char  BATTERY[4] = "BAT";

char  TIME_STAMP[3] = "TS";
char  timeStamp[20];

/************ CODE NOT USED ************/
//uint8_t error;
//uint8_t sd_answer;
// define variable for communication status

//char* filename="FILEDATA.TXT";

uint8_t divisor = 30;


// variable to measure time
//unsigned long previous;



/**********************************************/
/**** TEST MODE  value != 0 for printing,******/
/**********************************************/
int USB_TEST = 1;

void setup() 
{
 RTC.ON();  
  // setup WiFi configuration
  /******** CODE NOT USED ******/  
 //    contador =0;
 //RTC.setTime(string);              //SE AJUSTA EL VALOR DE NUESTRO RTC 
}

void loop()
{
  RTC.ON(); 
   if(USB_TEST)  USB.println("Inicio"); 

   RTC.getTime();
//   USB.printf(RTC.year, RTC.month, RTC.day, RTC.hour,  RTC.minute,  RTC.second );
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
    
    
    createFrameXBee(); // Create the DATA FRAME
    /*  
    snprintf(sensdata, sizeof(sensdata), "ID;NPL;AC;TD");
    
    snprintf(sensdata, sizeof(sensdata),"%s;TS;%s",sensdata,timeStamp);
    snprintf(sensdata, sizeof(sensdata),"%s;BAT;%s",sensdata,batteryLevelString);
    
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_A,connectorAString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_B,connectorBString);
    */
   if(USB_TEST)    USB.println(sensdata);    
 
    
 // Transmisión GPRS

              sprintf(aux_str,"GET /nodos/sensiteso.php?data=%s HTTP/1.1\r\nHost: papvidadigital-test.com\r\nConnection: close\r\n\r\n", sensdata);
 /**** INCOMPLETE GHOST CODE *****/
 //           sprintf(aux_str, "GET /nodos/sensiteso.php?data=%s", sensdataset);

   if(USB_TEST)             USB.println(aux_str);             

   data_cel_setup();      // function used to do the set up of the 3G connection 

   if (answer == 1){
              if(USB_TEST)  USB.println(F("Contactando servidor..."));
               // 6. gets URL from the solicited URL
              status = _3G.readURL("papvidadigital-test.com", 80, aux_str);
          
              if( status == 1)
              {
                   if(USB_TEST)  USB.println(F("\nHTTP query OK."));
                   if(USB_TEST)  USB.print(F("3G answer:"));
                   if(USB_TEST) USB.println(_3G.buffer_3G);
  
              }
              else
              {
                   if(USB_TEST) USB.println(F("\nHTTP query ERROR"));
              }
}

    // 7. Powers off the 3G module
    _3G.OFF();
    if(USB_TEST)     USB.println(F("****************************"));
    
    
 
 /**** GHOST CODE***********/
 // Tarea Final del Loop   
//      USB.printf("Going to Sleepe with: ", sleepTime);
//      USB.println(sleepTime);      
//      PWR.deepSleep(sleepTime,RTC_OFFSET,RTC_ALM1_MODE1,ALL_OFF);


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
    PWR.getBatteryLevel();                         // DUMMY READ
    batteryLevel = PWR.getBatteryLevel();          // Getting Battery Level
    itoa(batteryLevel, batteryLevelString, 10);    // Conversion into a string
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
    if(USB_TEST) USB.printf("\n*** BEGIN OF MEASURE ***");
  
  /**********/
  // Encendido de tarjeta de sensores
  /**********/
    SensorGasv20.ON();             // SENSOR BOARD TURN ON
    delay(WAITTIME);
    if(USB_TEST) USB.printf("\n*** Tarjeta de gases encendida ***");
   
   /********************************************/
   //
   // Configuración de sensores
   // 
   // Temp - Temperatura - No necesita ser configurado ni encendido
    
   // Hum - Humedad - No necesita ser configurado ni encendido
    
   
   //
   // Lectura de sensores - apagado tras lectura
   //
   /**********************************************/ 

  /****** TEMOPERATURE AND HUMIDITY SENSOR DOESNT NEED CONFIGURATION ******/      
   delay(WAITTIME);
   //First dummy reading for analog-to-digital converter channel selection
   SensorGasv20.readValue(SENS_TEMPERATURE);
   //Sensor temperature reading
   connectorAFloatValue = SensorGasv20.readValue(SENS_TEMPERATURE);
   //Conversion into a string
   dtostrf(connectorAFloatValue,1,2,connectorAString);  

   if(USB_TEST) USB.printf("\n*** Sensor Temp leido ***");

   delay(13*WAITTIME);                                              // Humidity sensor read  and wait time
   SensorGasv20.readValue(SENS_HUMIDITY);                           //First dummy reading for analog-to-digital converter channel selection
   connectorBFloatValue = SensorGasv20.readValue(SENS_HUMIDITY);    //Sensor temperature reading
   dtostrf(connectorBFloatValue,1,2,connectorBString);              //Conversion into a string

   if(USB_TEST)  USB.printf("\n*** Sensor Hum leido ***");    
   if(USB_TEST) USB.printf("\n*** END OF MEASURE***");
}



//**************************************************************************************************
//     CEL DATA SETUP
//**************************************************************************************************
//!*************************************************************************************
//!	Name:	data_cel_setup()									
//!	Description: Function used to get do the celular connection setup
//!	Param : void														
//!	Returns: void							
//!*************************************************************************************

void data_cel_setup()
{	
     USB.ON();
     if(USB_TEST) USB.println(F("**************************"));
	// 1. sets operator parameters
    _3G.set_APN(apn, login, password);
	// And shows them
    _3G.show_APN();
    
     if(USB_TEST) USB.println(F("**************************"));
	
	
    answer = _3G.ON();        //activates the 3G module:
    if ((answer == 1) || (answer == -3))
    {
	if(USB_TEST) USB.println(F("3G module ready..."));
	
        answer = _3G.check(60);  // 1 for connected null for not connected

       if (answer)
        { 
               if(USB_TEST) USB.println(F("3G module connected to the network..."));		
        }
	else
	{
	    if(USB_TEST) USB.println(F("3G module NOT connected to internet"));
	}

    }
    else
    {
           if(USB_TEST) USB.println(F("3G module not started"));     // Problem with the communication with the 3G module
    }
     if(USB_TEST) USB.println(F("Set up done"));
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
   
    snprintf(sensdata, sizeof(sensdata), "ID;NPL;AC;TD");
    
    snprintf(sensdata, sizeof(sensdata),"%s;TS;%s",sensdata,timeStamp);
    snprintf(sensdata, sizeof(sensdata),"%s;BAT;%s",sensdata,batteryLevelString);
    
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_A,connectorAString);
    snprintf(sensdata, sizeof(sensdata),"%s;%s;%s",sensdata,CONNECTOR_B,connectorBString);

}


