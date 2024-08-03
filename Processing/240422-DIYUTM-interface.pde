import controlP5.*;
import processing.serial.*;

ControlP5 cp5;
Serial port;

int graphX = 75;
int graphY = 130;
int graphWidth = 600;
int graphHeight = 300;
ArrayList<Float> distances = new ArrayList<Float>();
ArrayList<Float> weights = new ArrayList<Float>();
//int currentIndex = 0;
float minDistance = Float.MAX_VALUE;
float maxDistance = Float.MIN_VALUE;
float minWeight = Float.MAX_VALUE;
float maxWeight = Float.MIN_VALUE;

Textfield commandInput;
Textlabel incomingMessageLabel;
Textlabel xAxisLabel;
Textlabel yAxisLabel;

void setup() {
  size(750, 500);
  cp5 = new ControlP5(this);
  
  // Create buttons
  cp5.addButton("moveUp")
     .setPosition(75, 20)
     .setSize(80, 30)
     .setCaptionLabel("Move Up");
     
  cp5.addButton("moveDown")
     .setPosition(175, 20)
     .setSize(80, 30)
     .setCaptionLabel("Move Down");
     
  cp5.addButton("tareScale")
     .setPosition(275, 20)
     .setSize(80, 30)
     .setCaptionLabel("Tare Scale");
     
  // Create buttons for stop and clear
  cp5.addButton("stop")
     .setPosition(375, 70)
     .setSize(80, 30)
     .setCaptionLabel("Stop");
     
  cp5.addButton("clear")
     .setPosition(485, 70)
     .setSize(80, 30)
     .setCaptionLabel("Clear");
     
  cp5.addButton("save")
     .setPosition(595, 70)
     .setSize(80, 30)
     .setCaptionLabel("Save");
  
  // Initialize serial port
  port = new Serial(this, "COM3", 115200);
  
  // Create text input box
  commandInput = cp5.addTextfield("command")
                    .setPosition(375, 20)
                    .setSize(200, 30)
                    .setAutoClear(true)
                    .setLabel("Enter Command");
                    
  // Create button to send command
  cp5.addButton("sendCommand")
     .setPosition(595, 20)
     .setSize(80, 30)
     .setCaptionLabel("Send");
  
  // Create label for incoming message
  incomingMessageLabel = cp5.addTextlabel("incomingMessage")
                             .setPosition(445, 55)
                             .setColor(color(0))
                             .setText("");
}

void draw() {
  background(200);
  
  // Draw axes with scale
  drawAxesWithScale();
  
  // Draw graph
  drawGraph();
}

void drawAxesWithScale() {
  // Draw X-axis with scale
  stroke(0);
  line(graphX, graphY + graphHeight, graphX + graphWidth, graphY + graphHeight); // X-axis
  float xStep = (maxDistance - minDistance) / 10;
  for (int i = 0; i <= 10; i++) {
    float x = map(minDistance + i * xStep, minDistance, maxDistance, graphX, graphX + graphWidth);
    line(x, graphY + graphHeight, x, graphY + graphHeight + 5); // Tick mark
    textAlign(CENTER, TOP);
    text(nf(minDistance + i * xStep, 0, 2), x, graphY + graphHeight + 10); // Label
  }
  
  // Draw Y-axis with scale and grid lines
  line(graphX, graphY, graphX, graphY + graphHeight); // Y-axis
  float yStep = (maxWeight - minWeight) / 10;
  for (int i = 0; i <= 10; i++) {
    float y = map(minWeight + i * yStep, minWeight, maxWeight, graphY + graphHeight, graphY);
    line(graphX, y, graphX - 5, y); // Tick mark
    textAlign(RIGHT, CENTER);
    text(nf(minWeight + i * yStep, 0, 2), graphX - 10, y); // Label
    
    // Draw horizontal grid lines
    stroke(100);
    line(graphX, y, graphX + graphWidth, y);
    stroke(0);
  }
}

void moveUp() {
  port.write("mu\n");
}

void moveDown() {
  port.write("md\n");
}

void tareScale() {
  port.write("t\n");
}

void stop() {
  port.write("s\n");
}

void clear() {
  port.write("c\n");
  clearGraph();
}

void clearGraph() {
  distances.clear();
  weights.clear();
  minDistance = Float.MAX_VALUE;
  maxDistance = Float.MIN_VALUE;
  minWeight = Float.MAX_VALUE;
  maxWeight = Float.MIN_VALUE;
}

void save() {
  selectOutput("Select a file to save:", "saveFile");
}

void saveFile(File selection) {
  if (selection == null) {
    println("Save dialog canceled");
  } else {
    try {
      PrintWriter writer = new PrintWriter(selection);
      for (int i = 0; i < distances.size(); i++) {
        writer.println(distances.get(i) + "," + weights.get(i));
      }
      writer.close();
      println("File saved successfully!");
    } catch (IOException e) {
      println("Error saving file: " + e.getMessage());
    }
  }
}

void sendCommand() {
  String command = commandInput.getText();
  if (!command.isEmpty()) {
    port.write(command + "\n");
    commandInput.clear();
  }
}

void serialEvent(Serial p) {
  String message = p.readStringUntil('\n');
  if (message != null) {
    // Check if the message contains a comma
    if (message.contains(",")) {
      // Assuming the received data is in the format "distance,weight"
      String[] data = message.trim().split(",");
      if (data.length == 2) {
        float distance = float(data[0]);
        float weight = float(data[1]);
        
        // Update min and max values for distance and weight
        if (distance < minDistance) minDistance = distance;
        if (distance > maxDistance) maxDistance = distance;
        if (weight < minWeight) minWeight = weight;
        if (weight > maxWeight) maxWeight = weight;
        
        // Add data to lists
        distances.add(distance);
        weights.add(weight);
      }
    } else {
      // Display the message in the label
      incomingMessageLabel.setText(message);
    }
  }
}

void drawGraph() {
  // Plot data
  noFill();
  beginShape();
  for (int i = 0; i < distances.size(); i++) {
    float x = map(distances.get(i), minDistance, maxDistance, graphX, graphX + graphWidth);
    float y = map(weights.get(i), minWeight, maxWeight, graphY + graphHeight, graphY);
    vertex(x, y);
  }
  endShape();
  
  // Add label for last point
  if (!distances.isEmpty()) {
    float lastX = map(distances.get(distances.size() - 1), minDistance, maxDistance, graphX, graphX + graphWidth);
    float lastY = map(weights.get(weights.size() - 1), minWeight, maxWeight, graphY + graphHeight, graphY);
    
    // Set text and background color
    fill(255); // Text color
    int labelBgColor = color(50, 150, 200); // Background color
    textSize(12); // Text size
    textAlign(CENTER, CENTER);
    String labelText = nf(distances.get(distances.size() - 1), 0, 2) + ", " + nf(weights.get(weights.size() - 1), 0, 2);
    
    // Get text width and height
    float labelWidth = textWidth(labelText) + 10;
    float labelHeight = textAscent() + textDescent() + 5;
    
    // Draw background
    fill(labelBgColor);
    rectMode(CENTER);
    rect(lastX, lastY - 10, labelWidth, labelHeight);
    
    // Draw text
    fill(0); // Text color
    text(labelText, lastX, lastY - 10);
  }
}
