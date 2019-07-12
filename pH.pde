
#include <WaspSensorSW.h>


#include <WaspSensorSW.h>

/*
  ESTE CÓDIGO SIRVE PARA HACER LA CALIBRACIÓN DEL SENSOR DE pH.
  
  SE NECESITAN HACER TRES CALIBRACIONES PARA PODER CALIBRAR EL
  SENSOR DE MANERA CORRECTA.
  
  1.- pH 7,   2.- pH 4,   3.- pH 10
  
  SE NECESITA SENSOR DE TEMPERATURA PARA PODER CALIBRAR DE MANERA
  CORRECTA
  
  AUTORES: SERGIO EDUARDO MERCADO ALVARADO
           MARCO ANTONIO RUIZ SANTANA
  
  VERSIÓN: 1.0
  
*/

#include <WaspSensorSW.h>

float value_pH;
float value_temp;
float value_pH_calculated;

// Calibration values
#define cal_point_10 1.937
#define cal_point_7 2.083
#define cal_point_4 2.236

// Temperature at which calibration was carried out
#define cal_temp 22.98

pHClass pHSensor;
pt1000Class temperatureSensor;
WaspSensorSW Water;

void setup()
{
  USB.ON();
  pHSensor.setCalibrationPoints(cal_point_10, cal_point_7, cal_point_4, cal_temp);
  
  // Turn ON the Smart Water sensor board and start the USB
  Water.ON();
}


void loop()
{
  // Read the ph sensor
  value_pH = pHSensor.readpH();

  // Read the temperature sensor
  value_temp = temperatureSensor.readTemperature();

  // Print the output values
  USB.print(F("pH value: "));
  USB.print(value_pH);
  USB.print(F("volts  | "));  
  USB.print(F(" temperature: "));
  USB.print(value_temp);
  USB.print(F("degrees  | "));  
  
  // Convert the value read with the information obtained in calibration
  value_pH_calculated = pHSensor.pHConversion(value_pH,value_temp);
  USB.print(F(" pH Estimated: "));
  USB.println(value_pH_calculated);
}


