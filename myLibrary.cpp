/******************************************************************************
 * Includes
 ******************************************************************************/
#include "myLibrary.h"
#include "WaspWIFI.h"

#ifndef __WPROGRAM_H__
#include <WaspClasses.h>
#endif





/******************************************************************************
 * User API
 ******************************************************************************/


/******************************************************************************
 * PRIVATE FUNCTIONS                                                          *
 ******************************************************************************/


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

void myLibrary::wifi_setup(){
//Switch ON the WiFi module on the desired socket
    if( WIFI.ON(SOCKET1) == 1 )
    {
        if(USB_TEST)  USB.println(F("WiFi switched ON"));
    }
    else
    {
        if(USB_TEST)  USB.println(F("WiFi did not initialize correctly"));
    }



    // 1. Configure the transport protocol (UDP, TCP, FTP, HTTP...) 
    WIFI.setConnectionOptions(CLIENT); 
    // 2. Configure the way the modules will resolve the IP address. 
    WIFI.setDHCPoptions(DHCP_ON);    

    // 3. Configure how to connect the AP 

    // 4. Set Authentication key
    WIFI.setJoinMode(MANUAL); 
    WIFI.setAuthKey(WPA1,AUTHKEY); 



    // 5. Store changes  
    WIFI.storeData();
    if(USB_TEST)  USB.println(F("WiFi Ready"));
    WIFI.OFF();
}
/******************************************************************************
 * PUBLIC FUNCTIONS
 ******************************************************************************/

//**************************************************************************************************
//     get_bat()
//**************************************************************************************************
//!*************************************************************************************
//!	Name:	get_bat()									
//!	Description: Function used to get the current value of the battery and save it into the variable batteryLevelString
//!	Param : void														
//!	Returns: void							
//!*************************************************************************************

void myLibrary::get_bat(){
    PWR.getBatteryLevel();
    // Getting Battery Level
    batteryLevelWasp = PWR.getBatteryLevel();
    // Conversion into a string
}



//**************************************************************************************************
//     Creat Frame Wasp()
//**************************************************************************************************
//!*************************************************************************************
//!	Name:	createFrameWasp()									
//!	Description: Function used to create the Waspmote data Frame
//!           Works with global variables.
//!           Lot of concatenations.
//!           
//!	Param : void														
//!	Returns: void							
//!*************************************************************************************



void myLibrary::createFrameWasp(){
    // Formación de la trama TD para el sistema de monitoreo.
    
    memset(sensdata, 0, sizeof(sensdata));
    // Se extrae la trama TD de la trama ZigBee, la cual es transmitida dentro de una 
    // trama 0x90. Los datos a extraer comienzan a partir del byte 15 de la trama ZigBee.
    //

    for (i = 15; i < lenFrame; i++) {
        snprintf(sensdata, sizeof(sensdata), "%s%c", sensdata, dataRead[i]);
    }
}


//**************************************************************************************************
//     TRANSMIT FRAME
//**************************************************************************************************
//!*************************************************************************************
//!	Name:	transmitFrame()									
//!	Description: Function used to TRANSMIT the DATA FRAME
//!           Works with global variables.
//!           Lot of concatenations.
//!           
//!	Param : void														
//!	Returns: void							
//!*************************************************************************************

void myLibrary::transmitFrame(){

    wifi_setup();
    delay(1000);
    // Transmisión WiFi
 
    // 1. Switch ON the WiFi module
    WIFI.ON(SOCKET1);
    delay(1000);
    if(USB_TEST)  USB.println("WiFi ON");
    
    // 2. Join Network
    if (WIFI.join(ESSID))  
    {
        if(USB_TEST)  USB.println(F("Joined AP"));
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

            // 5. Reads an answer from the TCP connection (NOBLO means NOT BLOCKING)
             if(USB_TEST)  USB.println(F("Listen to TCP socket:"));
             
			 previous=millis();
             while(millis()-previous<TIMEOUT)
             {
                 if(WIFI.read(NOBLO)>0)
                 {
                    for(int j=0; j<WIFI.length; j++)
                    {
                        if(USB_TEST)  USB.print(WIFI.answer[j],BYTE);
                    }
                    if(USB_TEST)  USB.println();
                 }

                 // Condition to avoid an overflow (DO NOT REMOVE)
                 if (millis() < previous)
                 {
                    previous = millis();	
                 }
             }

            // 6. Closes the TCP connection. 
             if(USB_TEST)  USB.println(F("Close TCP socket"));
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
        if(USB_TEST)  USB.println(F("NOT Connected to AP"));
     }
     delay(1000);
     WIFI.OFF();  
     if(USB_TEST)  USB.println(F("****************************"));
    

  return;
  }
//**************************************************************************************************
//     Creat Frame XBEE()
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

void myLibrary::createFrameXBee(){
// Formación de la trama TD para el sistema de monitoreo.

  memset(sensdata, 0, sizeof(sensdata));
  snprintf(sensdata, sizeof(sensdata), "ID;I%u;AC;TD;", intID);  
  snprintf(sensdata, sizeof(sensdata),"%sTN;0", sensdata);
  snprintf(sensdata, sizeof(sensdata), "%s;%s;%s", sensdata, BATTERY, batteryLevelString);
  snprintf(sensdata, sizeof(sensdata), "%s;%s;%s", sensdata, CONNECTOR_A, connectorAString);
  snprintf(sensdata, sizeof(sensdata), "%s;%s;%s", sensdata, CONNECTOR_B, connectorBString);
  snprintf(sensdata, sizeof(sensdata), "%s;%s;%s", sensdata, CONNECTOR_C, connectorCString);

}
//**************************************************************************************************
//     RX TEMP
//**************************************************************************************************
//!*************************************************************************************
//!	Name:	RxTemp()									
//!	Description: 
//!	Param : void														
//!	Returns: void							
//!*************************************************************************************
void myLibrary::RxTemp(){
    cont=0;
    flagFrame=0;
    memset(dataRead, 0, sizeof(dataRead));
    serialFlush(SOCKET0);
 
    while (flagRx==0){
         if (serialAvailable(SOCKET0)){
        // Read one byte from the buffer
             dataRead[cont] = serialRead(SOCKET0);
                 if (cont==3) {
                     if((dataRead[0] == Start_Frame) && ((dataRead[3] == Frame_TYPE_92)||(dataRead[3] == Frame_TYPE_90))) {
                     // Se almacena la longitud de la trama recibida
                         lenFrame = dataRead[1] * 256 + dataRead[2] + 3;
						 // si dataRead corresponde al MSB que es 0 y data read 2 al LSB que contiene el numero de tramas entre
						 //lenght y el check sum? porque se multiplica entre 256 y porque se suma 3
						 
                         flagFrame=1;
                     }else{cont=0;}
                 }
                 if ((cont==lenFrame)&&(flagFrame==1)){
                    flagRx=((Frame_TYPE_92-dataRead[3])/2)+1;
                    cont=0; 
					flagFrame=0;
					serialFlush(SOCKET0);
                 }     
                 cont++;
  
         }
     }
}

//**************************************************************************************************
//     measure()
//**************************************************************************************************
//!*************************************************************************************
//!	Name:	measure()									
//!	Description: Function used to measure the sensors values of the waspmote and save them into various strings
//!              connectorAString_Temp       
//!              connectorBString_OxyRedPot  
//!              connectorCString_pH         
//!
//!	Param : void														
//!	Returns: void							
//!*************************************************************************************

void myLibrary::measure(){
    // Identifica el número de serie del Nodo y le asigna
    // el identificador para red de monitoreo: "IDx"
    intID=0;
    addressRx=dataRead[10]*256+dataRead[11];
    for (i=0; i<=numID-1; i++){
        if(addressID[i]==addressRx){
            intID=i+1;
        }
    }

    indx=lenFrame-8;
    
    // Lectura de valores de los sensores y conversión a voltaje
    //
    // Valor hexadecimal correspondiente a los 2 bytes del valor
    // leido por el primer sensor (A0)- Temperatura del Suelo
    // T C = valor leido en V * (R1+R2)/R2)*41.67 - 40
    // T C = valor leido * (1200/1.023) * ((16.8 kohms)/6.8 kohms) * 41.67 - 40
    connectorAFloatValue = ((dataRead[indx] * 256 + dataRead[indx+1]) * 1.200 / 1023)*102.92 - 40;
    dtostrf(connectorAFloatValue, 1, 2, connectorAString);
 
    //  // Valor hexadecimal correspondiente a los 2 bytes del valor
    //  // leido por el segundo sensor (A1) - Sensor pendiente de colocar
    connectorBFloatValue = (dataRead[indx+2] * 256 + dataRead[indx+3]) * 1200.00 / 1023;
    dtostrf(connectorBFloatValue, 1, 2, connectorBString);
    
    //  // Valor hexadecimal correspondiente a los 2 bytes del valor
    //  // leido por el tercer sensor (A2) - Humedad del Suelo
    // VWC = valor leido en V * rectaVWC
    // valor leído en V = valor leído * (1200/1.023) * ((16.8 kohms)/6.8 kohms)
    voltemp = (dataRead[indx+4] * 256 + dataRead[indx+5]) * ( 1.200 / 1023)*2.47;
    if (voltemp<1.1){
        connectorCFloatValue = voltemp*10-1;
    }
    if ((voltemp>=1.1)&&(voltemp<1.3)){
        connectorCFloatValue = voltemp*25-17.5;
    }
    if ((voltemp>=1.3)&&(voltemp<1.82)){
        connectorCFloatValue = voltemp*48.08-47.5;
    }    
    if (voltemp>=1.82){
        connectorCFloatValue = voltemp*26.32-7.89;
    }
  
    dtostrf(connectorCFloatValue, 1, 2, connectorCString);

    //  // Valor hexadecimal correspondiente a los 2 bytes del valor
    //  // del voltaje del módulo XBee
    batteryLevelFloatValue = (dataRead[indx+6] * 256 + dataRead[indx+7]) * 120.0 /(1023*3.3);
    dtostrf(batteryLevelFloatValue, 1, 2, batteryLevelString);
    
  return;
}

myLibrary::myLibrary(){
}

void myLibrary::ON()
{
}


/// Preinstantiate Objects /////////////////////////////////////////////////////
myLibrary myObject = myLibrary();