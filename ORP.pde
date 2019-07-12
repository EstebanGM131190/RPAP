
/*! \file Wasp_test_lib.cpp
 *  \brief Library for managing NODES 
 *
 *
 *  Version:		2.0
 *  AUTORES: SERGIO EDUARDO MERCADO ALVARADO
 *           MARCO ANTONIO RUIZ SANTANA
 *  Modified by:	Esteban González Moreno
 *
 *  ESTE CÓDIGO SIRVE PARA HACER LA CALIBRACIÓN DEL SENSOR DE ORP.
 * 
 *  SE CALIBRA UNICAMENTE CON LA SOLUCIÓN DE ORP 
 *
 *  
 */



/******************************************************************************
 * Includes            Includes of the Sensor Board and Communications modules used
 ******************************************************************************/
#include <WaspSensorSW.h>

/******************************************************************************
 * Definitions & Variable Declarations
 *****************************************************************************/

float value_orp;
float value_calculated;

// Offset obtained from sensor calibration
#define calibration_offset 0.017

ORPClass ORPSensor;

/** THIS LINE IS ONLY FOR verion 2 if you are using verion 3 of waspSensorSW.h this line is not needed */
WaspSensorSW Water;
/****/

void setup()
{
  // Turn on the Smart Water sensor board and start the USB
  USB.ON();  
  Water.ON();
}

void loop()
{
  // Reading of the ORP sensor
  value_orp = ORPSensor.readORP();

  // Apply the calibration offset
  value_calculated = value_orp - calibration_offset;

  // Print of the results
  USB.print(F(" ORP Estimated: "));
  USB.print(value_calculated);
  USB.println(F(" volts"));  
}
