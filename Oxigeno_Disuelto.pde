
/*! \file Wasp_test_lib.cpp
 *  \brief Library for managing NODES 
 *
 *
 *  Version:		2.0
 *  AUTORES: SERGIO EDUARDO MERCADO ALVARADO
 *           MARCO ANTONIO RUIZ SANTANA
 *  Modified by:	Esteban González Moreno
 *  ESTE CÓDIGO SIRVE PARA HACER LA CALIBRACIÓN DEL SENSOR DE OXIGENO DISUELTO.
 * 
 *  SE CALIBRA PRIMERAMENTE SIN SOLUCIÓN, ÚNICAMENTE EN CONTACTO CON EL AIRE,
 *  PARA DESPUES INTRODUCIR EL SENSOR A LA SOLUCIÓN. 

 */



/******************************************************************************
 * Includes            Includes of the Sensor Board and Communications modules used
 ******************************************************************************/
#include <WaspSensorSW.h>

/******************************************************************************
 * Definitions & Variable Declarations
 *****************************************************************************/

float value_do;
float value_calculated;

// Calibration of the sensor in normal air
#define air_calibration 1.85637
// Calibration of the sensor under 0% solution
#define zero_calibration 0.10583

DOClass DOSensor;

/** THIS LINE IS ONLY FOR verion 2 if you are using verion 3 of waspSensorSW.h this line is not needed */
WaspSensorSW Water;
/****/

void setup()
{
  // Turn ON the Smart Water sensor board and start the USB
  USB.ON();  
  
  // Configure the calibration values
  DOSensor.setCalibrationPoints(air_calibration, zero_calibration);

  Water.ON();
}

void loop()
{
  // Reading of the ORP sensor
  value_do = DOSensor.readDO();

  // Print of the results
  USB.print(F("DO Output Voltage: "));
  USB.print(value_do);

  // Conversion from volts into dissolved oxygen percentage
  value_calculated = DOSensor.DOConversion(value_do);

  // Print of the results
  USB.print(F(" DO Percentage: "));
  USB.println(value_calculated);
  
}


