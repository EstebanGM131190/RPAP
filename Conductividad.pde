
/*! \file Wasp_test_lib.cpp
 *  \brief Library for managing NODES 
 *
 *
 *  Version:		2.0
 *   
 * AUTORES: SERGIO EDUARDO MERCADO ALVARADO
 *          MARCO ANTONIO RUIZ SANTANA
 * 
 *  Modified by:	Esteban González Moreno
 *  Conductividad
 *   ESTE CÓDIGO SIRVE PARA HACER LA CALIBRACIÓN DEL SENSOR DE CONDUCTIVIDAD.
 * 
 *   TENER EN CUENTA EL TIPO DE AGUA EN EL QUE SE VA A HACER LA MEDICIÓN PARA
 *   SELECCIONAR LAS SOLUCIONES DEL TIPO DE K CORRECTA.
 *  
 */




/******************************************************************************
 * Includes            Includes of the Sensor Board and Communications modules used
 ******************************************************************************/
#include <WaspSensorSW.h>

/******************************************************************************
 * Definitions & Variable Declarations
 *****************************************************************************/
float value_cond;
float value_calculated;

// Value 1 used to calibrate the sensor
#define point1_cond 12880                          //Valor de Siemens que contiene la solución ( menor ).
// Value 2 used to calibrate the sensor
#define point2_cond 80000                          //Valor de Siemens que contiene la solución ( mayor ).

// Point 1 of the calibration 
#define point1_cal 138.00                          //Primer valor obtenido en la consola
// Point 2 of the calibration 
#define point2_cal 44.00                           //Segundo valor obtenido en la consola

conductivityClass ConductivitySensor;

/** THIS LINE IS ONLY FOR verion 2 if you are using verion 3 of waspSensorSW.h this line is not needed */
WaspSensorSW Water;
/****/

void setup()
{
  // Turn ON the Smart Water sensor board and start the USB
  USB.ON();
  
  // Configure the calibration parameters
  ConductivitySensor.setCalibrationPoints(point1_cond, point1_cal, point2_cond, point2_cal);
  delay(2000);
  
  Water.ON();
}

void loop()
{
  // Reading of the Conductivity sensor
  value_cond = ConductivitySensor.readConductivity();

  // Print of the results
  USB.print(F("Conductivity Output Resistance: "));
  USB.print(value_cond);

  // Conversion from resistance into ms/cm
  value_calculated = ConductivitySensor.conductivityConversion(value_cond);
  // Print of the results
  USB.print(F(" Conductivity of the solution (mS/cm): "));
  USB.println(value_calculated); 
}

