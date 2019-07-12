/*
  ESTE CÓDIGO SIRVE PARA HACER LA CALIBRACIÓN DEL SENSOR DE ORP.
  
  SE CALIBRA UNICAMENTE CON LA SOLUCIÓN DE ORP 
   
  AUTORES: SERGIO EDUARDO MERCADO ALVARADO
           MARCO ANTONIO RUIZ SANTANA
  
  VERSIÓN: 1.0
  
*/

#include <WaspSensorSW.h>

float value_orp;
float value_calculated;

// Offset obtained from sensor calibration
#define calibration_offset 0.017

ORPClass ORPSensor;

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
