

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
#include <myLibrary.h>

/******************************************************************************
 * Definitions & Variable Declarations
 *****************************************************************************/
#define WAITTIME 1000


/////////////////////////////////
//#define ESSID_A "Totalplay-3940"
//#define AUTHKEY "B0013940"
//#define ESSID "libelium_AP" //WPA2
//#define AUTHKEY "proinnova2015"
#define ESSID_A "belkin.cb9"
#define AUTHKEY_A "9e6ce6e3"



char  CNT[5];

char* sleepTime = "00:00:30:00";           

// WEB server settings 
/////////////////////////////////
// Host websoft.com.mx
//char HOST[] = "74.50.121.173";

char HOST_AG[] = "websoft.com.mx";

//char HOST[] = "arduino.cc";

char URL_AG[]  = "GET /nodos/sensiteso.php?data=";
//char URL[]  = "GET$http://websoft.com.mx/nodos/date.php";
//char URL[]  = "GET$/asciilogo.txt";

/////////////////////////////////


/////////////////////////////////
// choose socket (SELECT USER'S SOCKET)
///////////////////////////////////////
uint8_t socket=SOCKET0;
///////////////////////////////////////


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
 
    snprintf(timeStamp, sizeof(timeStamp), "%02u:%02u:%02u:%02u:%02u:%02u", RTC.year, RTC.month, RTC.date, RTC.hour,  RTC.minute,  RTC.second );

   if(USB_TEST)   USB.printf("\n");
   if(USB_TEST)   USB.println("Sensando");   
   if(USB_TEST)   USB.printf("\n*** CALL MEASURE ***");
    myObject.measure_Aguilas();
   if(USB_TEST)   USB.printf("\n*** RETURN OF MEASURE***");
   delay(70);

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Send Data
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
   myObject.get_bat();
   if(USB_TEST)    USB.println("get_bat");
    
   myObject.createFrameXBee_AGUILAS();      //CREATES THE DATA FRAME

   if(USB_TEST)    USB.println(sensdata);
    
 // Transmisión WiFi
 
    // Switch ON the WiFi module
    WIFI.ON(socket);
   if(USB_TEST)    USB.println("WiFi ON");

    // Join Network
    if (WIFI.join(ESSID_A))  
    {
        if(USB_TEST)        USB.println(F("Joined AP"));

        // Call the function to create a TCP connection 
        if (WIFI.setTCPclient(DNS,HOST_AG, REMOTE_PORT, LOCAL_PORT)) 
        { 
          if(USB_TEST)USB.println(F("TCP client set"));

            // Now the connection is open, and we can use send and read functions 
            // to control the connection. Send message to the TCP connection 
            WIFI.send(URL_AG);
            WIFI.send(sensdata);
            WIFI.send(" HTTP/1.1\r\n"); 
            WIFI.send("HOST_AG: "); 
            WIFI.send(HOST_AG); 
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
    WIFI.setAuthKey(WPA2,AUTHKEY_A); 

    // 5. Store changes  
    WIFI.storeData();

}


