                                                                            
/*! 
 *  GATEWARY ZIGBEE WIFI  *
 *  Version:		2.0
 *  Modified by:	Esteban González Moreno
 *  Nodo Gateway
 *
 */

/******************************************************************************
 * Includes            Includes of the Sensor Board and Communications modules used
 ******************************************************************************/
//#include <Wasp232.h>    //Include always this library when you are using the Wasp232 functions  
#include <WaspWIFI.h>
/******************************************************************************
 * Definitions & Variable Declarations
 *****************************************************************************/
// TCP server settings
/////////////////////////////////
#define REMOTE_PORT 80
#define LOCAL_PORT 2000
// define timeout for listening to messages
#define TIMEOUT 10000
 
 
int data, i, intID, indx;
int lenFrame=0;
int cont=0;
int contFrameRx=0;
int flagFrame=0;
int dataRead[512];
int flagRx=0;
unsigned int addressRx;
char sensdata[300];

// variable to measure time
unsigned long previous;

/////////////////////////////////
/////////////////////////////////
// WiFi AP settings (CHANGE TO USER'S AP)
/////////////////////////////////
#define ESSID "libelium_AP"
#define AUTHKEY "proinnova2015"
//#define ESSID "belkin.cb9"
//#define AUTHKEY "9e6ce6e3"
char HOST[] = "papvidadigital-test.com";
char URL[]  = "GET /nodos/sensiteso.php?data=";

// Array that saves the last 4 digits of the serial number of each XBee module that has to be recognized 
// Each one of them has to get an "Ix" designator being x the position of the serial number in the array
unsigned int addressID[]={
  0x42ED,
  0x61ED,
  0x61EF,
  0x61F3,
  0x61F4,
  0x61F5,  
  0x5442,
  0x36F3,
  0x14C5,
  0x6F59
};

int numID=10;

char  TIME_STAMP[3] = "TS";
char  timeStamp[20];
char  ID[3];
char  CONNECTOR_A[6] = "TmpS";
char  CONNECTOR_B[7] = "TmpI";
char  CONNECTOR_C[5] = "HumS";
char  BATTERY[4] = "BAT";

float voltemp;
float connectorAFloatValue;
float connectorBFloatValue;
float connectorCFloatValue;
float batteryLevelFloatValue;

char  connectorAString[10];
char  connectorBString[10];
char  connectorCString[10];

int   batteryLevel;
int   batteryLevelWasp;
char  batteryLevelString[10];

/**********************************************/
/**** TEST MODE  value != 0 for printing,******/
/**********************************************/
int USB_TEST = 1;


void setup() {

  // Power on the USB for viewing data in the serial monitor.  
  // Note : if you are using the socket 0 for communication, 
  // for viewing data in the serial monitor, you should open
  // the USB at the same speed. 
  USB.ON();

  
  // Powers on the module and assigns the UART in socket0
 // W232.ON(SOCKET0);        // USED IN THE wasp232lib
  Utils.setMuxSocket0();
  pinMode(XBEE_PW,OUTPUT);
  digitalWrite(XBEE_PW,HIGH);
  WaspRegister |=REG_SOCKET0;
  
  // Configure the baud rate of the module
 // W232.baudRateConfig(9600);      // USED IN THE wasp232lib
  beginSerial(115200, SOCKET0);

  // Configure the parity bit as disabled 
//  W232.parityBit(NONE);      // USED IN THE wasp232lib
  cbi(UCSR0C, UPM01);
  cbi(UCSR0C, UPM00);

  // Use one stop bit configuration
//  W232.stopBitConfig(1);     // USED IN THE wasp232lib
  cbi(UCSR0C, USBS0);
  
  // Print hello message
  if(USB_TEST)   USB.println("Seccion de Set-Up - ZigBee-Receiver-WiFi - V1");

  //W232.OFF();    // USED IN THE wasp232lib
}



void loop() 
{
    RxTemp();
    contFrameRx++;
 
    if(flagRx==1){
        if(USB_TEST)
        {
           USB.println();USB.println("Frame ZigBee (Char): ");
           USB.print("lenFrame: ");USB.println(lenFrame);
           for (i=0; i<(lenFrame+1); i++) {
               USB.print(dataRead[i], HEX);USB.print(":");
           }
        }
    
    measure();
    if(intID !=0){   
        if(USB_TEST){
            USB.println();   
            USB.println("Valores:");
            USB.print("AD0: "); USB.println(connectorAString);
            USB.print("AD1: "); USB.println(connectorBString);
            USB.print("AD2: "); USB.println(connectorCString);
            USB.print("BAT: "); USB.println(batteryLevelString);
        }
        createFrameXBee();
        get_bat();
        if(USB_TEST){
            USB.println(sensdata);
            USB.print("BAT: ");USB.println(batteryLevelWasp);
            USB.print("Cont Frames: ");USB.println(contFrameRx);   
        }
        transmitFrame();   
     }
    flagRx=0;
  }

  // Cuando la trama Waspmote es recibida:
  //    - se extrae del campo "Received RF data" de la trama ZigBee 0x90 la trama TD y obtienen los valores de los sensores en "measure()"
  //    - en "transmitFrameXBee()" se forman las lineas del protocolo HTTP para el envio de la trama TD utilizando el comando GET
  //      (en esta versión de programa solo se muestra en pantalla, no se transmite)
 
   if (flagRx==2){
       if(USB_TEST){
           USB.println();
           USB.println("Frame Waspmote: ");
           for (i = 15; i < lenFrame; i++) {
               USB.print(char(dataRead[i]));
           }
       }
      createFrameWasp();      // CREATE THE WASP DATA FRAME
  
      if(USB_TEST)  USB.println(sensdata);
  
  
      // transmitFrame();
  
      flagRx=0;
    }

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

void RxTemp(){
    cont=0;
    flagFrame=0;
    memset(dataRead, 0, sizeof(dataRead));
    serialFlush(SOCKET0);
 
    while (flagRx==0){
         if (serialAvailable(SOCKET0)){

        // Read one byte from the buffer
        //char data = W232.read();
     //      data =serialRead(SOCKET0);
             dataRead[cont] = serialRead(SOCKET0);
                 if (cont==3) {
                     if((dataRead[0] == 126) && ((dataRead[3] == 146)||(dataRead[3] == 144))) {
                     // Se almacena la longitud de la trama recibida
                         lenFrame=dataRead[1] * 256 + dataRead[2] + 3;
                         flagFrame=1;
                     }else{cont=0;}
                 }
                if ((cont==lenFrame)&&(flagFrame==1)){
                    flagRx=(146-dataRead[3])/2+1;
                    cont=0; flagFrame=0;serialFlush(SOCKET0);
                }     
                cont++;
           /*******GHOST CODE*********/
//          if (flagCont==1){cont=0; flagCont=0;serialFlush(SOCKET0)} 
  
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
void measure() {

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
void createFrameXBee() {

// Formación de la trama TD para el sistema de monitoreo.

  memset(sensdata, 0, sizeof(sensdata));
  /************** GHOST CODE **********/
//  snprintf(sensdata, sizeof(sensdata), "GET http://papvidadigital.com/nodosa/sensiteso.php?data=");
//  snprintf(sensdata, sizeof(sensdata), "GET http://papvidadigital-test.com/nodos/sensiteso.php?data=ID");
  snprintf(sensdata, sizeof(sensdata), "ID;I%u;AC;TD;", intID);
  
  snprintf(sensdata, sizeof(sensdata),"%sTN;0", sensdata);
  snprintf(sensdata, sizeof(sensdata), "%s;%s;%s", sensdata, BATTERY, batteryLevelString);
  snprintf(sensdata, sizeof(sensdata), "%s;%s;%s", sensdata, CONNECTOR_A, connectorAString);
  snprintf(sensdata, sizeof(sensdata), "%s;%s;%s", sensdata, CONNECTOR_B, connectorBString);
  snprintf(sensdata, sizeof(sensdata), "%s;%s;%s", sensdata, CONNECTOR_C, connectorCString);

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
void createFrameWasp() {

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

void transmitFrame()
{
    wifi_setup();
    delay(100);
    // Transmisión WiFi
 
    // 1. Switch ON the WiFi module
    WIFI.ON(SOCKET1);
    if(USB_TEST)  USB.println("WiFi ON");
    //    itoa(DNS,dataDNS,15);
    //    USB.println(dataDNS);  
    
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
    
    WIFI.OFF();  
    if(USB_TEST)  USB.println(F("****************************"));
    

  return;
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
    batteryLevelWasp = PWR.getBatteryLevel();
    // Conversion into a string
}
