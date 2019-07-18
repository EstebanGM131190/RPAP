/*! \def myLibrary_h
 \brief The library flag
 */
#ifndef myLibrary_h
#define myLibrary_h

/******************************************************************************
 * Includes
 ******************************************************************************/

#include <inttypes.h>
#include "WaspWIFI.h"
/******************************************************************************
 * Definitions & Declarations
 ******************************************************************************/


#define GATEWAY     1
#define	AGUILAS		2
#define PLANTA		3


// TCP server settings
/////////////////////////////////
#define REMOTE_PORT 80
#define LOCAL_PORT 2000

// define timeout for listening to messages
#define TIMEOUT 10000

/////////////////////////////////
/////////////////////////////////
// WiFi AP settings (CHANGE TO USER'S AP)
/////////////////////////////////
#define ESSID "libelium_AP"
#define AUTHKEY "proinnova2015"
//#define ESSID "belkin.cb9"
//#define AUTHKEY "9e6ce6e3"
#define HOST "papvidadigital-test.com"
#define URL "GET /nodos/sensiteso.php?data="

/**********************************************/
/**** TEST MODE  value != 0 for printing,******/
/**********************************************/
#define USB_TEST  1


/********************************/
/*** ZIGBEE FRAME DEFINITIONS ***/
/********************************/
#define Start_Frame  126
#define Frame_TYPE_90  144
#define Frame_TYPE_92  146

/******************************************************************************
 Variable Declarations
 *****************************************************************************/

 // Array that saves the last 4 digits of the serial number of each XBee module that has to be recognized 
// Each one of them has to get an "Ix" designator being x the position of the serial number in the array
static unsigned int addressID[]={
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

static int lenFrame=0;
static int cont=0;
static int contFrameRx=0;
static int flagFrame=0;
static int dataRead[512];
static int flagRx=0;
static unsigned int addressRx;
static char sensdata[300];
static char dataDNS[15];

// variable to measure time
static unsigned long previous;


static int i; 
static int intID; 
static int indx;
static int numID=10;

static char  TIME_STAMP[3] = "TS";
static char  timeStamp[20];
static char  ID[3];

/// GATEWAY VARIABLES
static char  CONNECTOR_A_GATE[6] = "TmpS";
static char  CONNECTOR_B_GATE[7] = "TmpI";
static char  CONNECTOR_C_GATE[5] = "HumS";

// LAS AGUILAS NODE VARIABLES
static char  CONNECTOR_A_AGUILAS[5] = "Temp";      
static char  CONNECTOR_B_AGUILAS[4] = "Hum";    
static char  CONNECTOR_C_AGUILAS[4] = "C02";
static char  CONNECTOR_D_AGUILAS[4] = "NO2";
static char  CONNECTOR_E_AGUILAS[3] = "03";
static char  CONNECTOR_F_AGUILAS[3] = "CO";

static char  nodeID_AGUILAS[10] = "A1";   


static char  BATTERY[4] = "BAT";



static char* macAddress="000000000000FFFF"; 
static char* filename="FILEDATA.TXT";

static float voltemp;
static float connectorAFloatValue;
static float connectorBFloatValue;
static float connectorCFloatValue;
static float connectorDFloatValue;   
static float connectorEFloatValue;
static float connectorFFloatValue;


static int connectorAIntValue;
static int connectorBIntValue;
static int connectorCIntValue;
static int connectorDIntValue;
static int connectorEIntValue;
static int connectorFIntValue;

static float batteryLevelFloatValue;

static char  connectorAString[10];
static char  connectorBString[10];
static char  connectorCString[10];
static char  connectorDString[10];
static char  connectorEString[10];
static char  connectorFString[10];


static int   batteryLevel;
static int   batteryLevelWasp;
static char  batteryLevelString[10];


/******************************************************************************
 * Class
 ******************************************************************************/

//! myLibrary Class
/*!
  defines all the variables and functions used 
 */
class myLibrary
{

  /// private methods //////////////////////////
private:
	void wifi_setup();

  /// public methods and attributes ////////////
public:
	void RxTemp();
	void measure();
	void createFrameXBee();
	void createFrameXBee_AGUILAS();
    void createFrameWasp() ;
	void get_bat();
	void transmitFrame();
	
	myLibrary();  
	void ON();
	//WaspWIFI();	
};

extern myLibrary myObject;

#endif 