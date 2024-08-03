#include <AccelStepper.h>
#include "HX711.h"

// Define stepper motor connections and parameters
#define STEP_PIN_1 2
#define DIR_PIN_1 3
#define STEP_PIN_2 4
#define DIR_PIN_2 5

// Constants for conversion
const float STEPS_PER_MM = 545.22;
const float MM_INCREMENT = 0.1; // Increment in millimeters for weight measurement

const int MaxSpeed = 500;
const int Accel = 100;
const long Limit = 50000;



// Create instances of the AccelStepper class for both stepper motors
AccelStepper stepper1(AccelStepper::DRIVER, STEP_PIN_1, DIR_PIN_1);
AccelStepper stepper2(AccelStepper::DRIVER, STEP_PIN_2, DIR_PIN_2);

// Define HX711 circuit and gain factor
#define DOUT_PIN 6
#define CLK_PIN 7
#define SCALE_OFFSET 4294763010
#define SCALE_FACTOR 23.822133 // Adjust this value based on your calibration

// Create instance of the HX711 class
HX711 scale;

// Define variables to keep track of the current position and target position for both steppers
float currentPosition1_mm = 0;
float currentPosition2_mm = 0;
float relativePosition_mm = 0; // Initialize relative position to 0

float myData[300];

void setup() {
  // Set up serial communication
  Serial.begin(115200);

  // Set the maximum speed and acceleration for both steppers
  stepper1.setMaxSpeed(MaxSpeed);
  stepper1.setAcceleration(Accel);
  stepper2.setMaxSpeed(MaxSpeed);
  stepper2.setAcceleration(Accel);

  // Set the initial position to 0 for both steppers
  stepper1.setCurrentPosition(0);
  stepper2.setCurrentPosition(0);

  // Initialize the HX711 sensor
  scale.begin(DOUT_PIN, CLK_PIN);
  scale.set_offset(SCALE_OFFSET);
  scale.set_scale(SCALE_FACTOR);
  scale.tare(); // Reset the scale to zero initially
}

void loop() {

  // Check if data is available on the serial port
  if (Serial.available() > 0) {
    // Read the incoming byte
    String input = Serial.readStringUntil('\n');
    input.trim(); // Remove leading and trailing whitespaces
    if (input.equals("t")) {
        Serial.println("Taring the scale...");
        scale.tare(); // Tare the scale
    }
    if (input.equals("p")) {
        for (int i = 0; i < sizeof(myData) / sizeof(myData[0]); i++) {
        Serial.println(myData[i]);
    }
    }
    float relativePosition_mm = input.toFloat();
    //relativePosition_mm = Serial.parseInt();
    Serial.print("New Relative Position: ");
    Serial.println(relativePosition_mm);
  
  
  // Determine the direction of movement based on the sign of relativePosition_mm
  int direction = (relativePosition_mm > 0) ? 1 : -1;

  // Calculate the target position
  float target_mm = currentPosition1_mm + relativePosition_mm;
  //Serial.print("Relative Position: ");
  //Serial.println(relativePosition_mm);
  //Serial.print("Target Position: ");
  //Serial.println(target_mm);
  //Serial.print("Direction: ");
  //Serial.println(direction);

  // Check if movement is needed (avoiding division by zero)
  if (relativePosition_mm != 0 && MM_INCREMENT != 0) {
    // Initialize mm to 0
    float mm = 0.0;
    int dt = 0;

    // Loop until the current position reaches or exceeds the target position
    while ((direction > 0 && currentPosition1_mm < target_mm) || (direction < 0 && currentPosition1_mm > target_mm)) {

      // Convert millimeters to steps
      long newSteps = round(STEPS_PER_MM * MM_INCREMENT * direction);

        // Move both steppers by the increment
        stepper1.move(newSteps);
        stepper2.move(newSteps);

        // Update the current positions for both steppers
        currentPosition1_mm += MM_INCREMENT * direction;
        currentPosition2_mm += MM_INCREMENT * direction;

        // Increment mm and dt
        mm += MM_INCREMENT * direction;
        dt += 1;

        // Wait for both movements to complete
        while (stepper1.distanceToGo() != 0 || stepper2.distanceToGo() != 0) {
      stepper1.run();
      stepper2.run();
    }
    

    // Read sensor data
    double weight = scale.get_units(); // Get the weight reading in kilograms

    // Print weight reading for the current increment
    Serial.print("Increment (mm): ");
    Serial.print(mm);
    Serial.print(" , Weight (kg): ");
    Serial.println(weight);

    // Add data to myData
    myData[dt] = weight;


    // Check if weight is over 10,000
        if (weight > Limit) {
            Serial.print("Over limit: ");
            Serial.print(Limit);
            Serial.print(" , Weight (kg): ");
            Serial.println(weight);
            break; // End the while loop
        }

    delay(100); // Add a small delay for stability
    }
  }
  }

  // Reset the current positions of both steppers to 0
  currentPosition1_mm = 0;
  currentPosition2_mm = 0;
  stepper1.setCurrentPosition(0);
  stepper2.setCurrentPosition(0);

  // Wait for a moment before checking serial port again
  delay(100);
}
