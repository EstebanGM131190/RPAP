
                                                                           
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
#include <WaspWIFI.h>
#include <myLibrary.h>
#include <WaspSensorGas_v20.h>


/******************************************************************************
 * Definitions & Variable Declarations
 *****************************************************************************/

char  CONNECTOR_A[6] = "TmpS";
char  CONNECTOR_B[7] = "TmpI";
char  CONNECTOR_C[5] = "HumS";


void setup() {

  // Power on the USB for viewing data in the serial monitor.  
  // Note : if you are using the socket 0 for communication, 
  // for viewing data in the serial monitor, you should open
  // the USB at the same speed. 
  USB.ON();

  
  // Powers on the module and assigns the UART in socket0
  Utils.setMuxSocket0();
  pinMode(XBEE_PW,OUTPUT);
  digitalWrite(XBEE_PW,HIGH);
  WaspRegister |=REG_SOCKET0;
  
  // Configure the baud rate of the module
  beginSerial(115200, SOCKET0);

  // Configure the parity bit as disabled 
  cbi(UCSR0C, UPM01);
  cbi(UCSR0C, UPM00);

  // Use one stop bit configuration
  cbi(UCSR0C, USBS0);
  
  // Print hello message
  if(USB_TEST)   USB.println("Seccion de Set-Up - ZigBee-Receiver-WiFi - V1");

}



void loop() 
{
    myObject.RxTemp();
    contFrameRx++;
 
    if(flagRx==1){ // API x92
        if(USB_TEST)
        {
           USB.println();
           USB.println("Frame ZigBee (Char): ");
           USB.print("lenFrame: ");USB.println(lenFrame);
           for (i=0; i<(lenFrame+1); i++) {
               USB.print(dataRead[i], HEX);
               USB.print(":");
           }
        }
    
    myObject.measure();
    if(intID !=0){
        myObject.createFrameXBee();
        myObject.get_bat();
        if(USB_TEST){
            USB.println();   
            USB.println("Valores:"); 
            USB.print("AD0: ");        USB.println(connectorAString);
            USB.print("AD1: ");        USB.println(connectorBString);
            USB.print("AD2: ");        USB.println(connectorCString);
            USB.print("BAT: ");        USB.println(batteryLevelString);
            USB.println(sensdata);
            USB.print("BAT: ");        USB.println(batteryLevelWasp);
            USB.print("Cont Frames: ");USB.println(contFrameRx);   
        }
        myObject.transmitFrame();   
     }
    flagRx=0;
  }

  // Cuando la trama Waspmote es recibida:
  //    - se extrae del campo "Received RF data" de la trama ZigBee 0x90 la trama TD y obtienen los valores de los sensores en "measure()"
  //    - en "transmitFrameXBee()" se forman las lineas del protocolo HTTP para el envio de la trama TD utilizando el comando GET
  //      (en esta versión de programa solo se muestra en pantalla, no se transmite)
 
   if (flagRx==2){  // API x90
       if(USB_TEST){
           USB.println();USB.println("Frame Waspmote: ");
           for (i = 15; i < lenFrame; i++) {
               USB.print(char(dataRead[i]));
           }
       }
      myObject.createFrameWasp();      // CREATE THE WASP DATA FRAME
  
      if(USB_TEST)  USB.println(sensdata);
       myObject.transmitFrame();
      flagRx=0;
    }

}









