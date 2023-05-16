import processing.serial.*;
import java.io.InputStreamReader;

Serial serial; // создаем объект последовательного порта
String received; // данные, получаемые с последовательного порта

int GRID_SIZE = 160;
int MAP_SIZE_X = 5;
int MAP_SIZE_Y = 5;
int[] DEFAULT_COLOR = {29, 36, 41};
int[] DEFAULT_STROKE_COLOR = {255, 255, 255};


String get_position() {
  try {
    Process process = Runtime.getRuntime().exec("./generate-initial-map");
    BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
    return reader.readLine();
  } catch(Exception exc) {
    exc.printStackTrace();
    return "";
  }
}

void settings() {
    size(MAP_SIZE_X * GRID_SIZE, MAP_SIZE_Y * GRID_SIZE);
}

void draw_map_background_grid() {
  stroke(204, 102, 0);
  for (int x_cord = 0; x_cord < MAP_SIZE_X * GRID_SIZE; x_cord += GRID_SIZE) {
      for (int y_cord = 0; y_cord < MAP_SIZE_Y * GRID_SIZE; y_cord += GRID_SIZE) {
          fill(DEFAULT_COLOR[0], DEFAULT_COLOR[1], DEFAULT_COLOR[2]);
          stroke(DEFAULT_STROKE_COLOR[0], DEFAULT_STROKE_COLOR[1], DEFAULT_STROKE_COLOR[2]);
          rect(x_cord, y_cord, GRID_SIZE, GRID_SIZE);
      }
  }
}

void setup() {
    System.out.println(get_position());
  
    draw_map_background_grid();
    String port = Serial.list()[0];
    serial = new Serial(this, port, 9600);
    
    String str = "0 2 2 2 203 232 50; 1 0 1 2 141 121 160; 2 4 3 1 214 100 199; 4 3 1 1 85 195 70; ";
    
    String parts[] = str.strip().split(";");
    
    for (String token : parts) {
        int[] block_data = new int[8];
        int idx = 0;
    
        for (String num_str : token.strip().split(" ")) {
            block_data[idx] = Integer.parseInt(num_str);
            ++idx;
        }
        fill(block_data[4], block_data[5], block_data[6]);
        rect(block_data[0] * GRID_SIZE, block_data[1] * GRID_SIZE, block_data[2] * GRID_SIZE, block_data[3] * GRID_SIZE);
        fill(DEFAULT_COLOR[0], DEFAULT_COLOR[1], DEFAULT_COLOR[2]);
    }
}

void draw() {
    //if (serial.available() > 0) {
    //    received = serial.readStringUntil('\n');
    //}
    
    //if (received != null)
    //  println(received);
}
