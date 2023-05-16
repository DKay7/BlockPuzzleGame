import processing.serial.*;
import java.io.InputStreamReader;

Serial serial; // создаем объект последовательного порта
String received; // данные, получаемые с последовательного порта

int GRID_SIZE = 160;
int MAP_SIZE_X = 4;
int MAP_SIZE_Y = 5;
int MENU_SIZE = 200;
int DEFAULT_TEXT_SIZE = 25;
int[] DEFAULT_COLOR = {255, 255, 255};
int[] BTN_TIMER_COLOR = {52, 78, 92};
int[] DEFAULT_STROKE_COLOR = {255, 255, 255};
boolean mouse_over_btn = false;
int[] BTN = {MAP_SIZE_X * GRID_SIZE, 0, MENU_SIZE, GRID_SIZE / 2};
int[] TIMER_BOX = {MAP_SIZE_X * GRID_SIZE, GRID_SIZE / 2, MENU_SIZE, GRID_SIZE / 2};

int start_time = 0, stop_time = 0;
boolean game_running = false;  
boolean was_game_finished = false;
boolean update_map = false;
boolean update_map_generating_text = true;
String getMap() {
  try {
    Process process = Runtime.getRuntime().exec("/home/danny/programmings/BlocksPuzzle/sketch_230516d/generate-initial-map");
    BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
    return reader.readLine();
  } catch(Exception exc) {
    exc.printStackTrace();
    return "";
  }
}

void settings() {
    size(MAP_SIZE_X * GRID_SIZE + MENU_SIZE, MAP_SIZE_Y * GRID_SIZE);
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
    String port = Serial.list()[0];
    serial = new Serial(this, port, 9600);
    textSize(DEFAULT_TEXT_SIZE);

}

void draw() {    
    if (update_map) {
        update_map = false;
        drawInitialMap();
    }
    
        
    if (update_map_generating_text) {
        background(51);
        update_map_generating_text = false;
        update_map = true;
        fill(255, 255, 255);
        textAlign(CENTER, CENTER);
        text("Generating map...", 0, 0, MAP_SIZE_X * GRID_SIZE, MAP_SIZE_Y * GRID_SIZE);
    }
    
    mouse_over_btn = overRect(BTN[0], BTN[1], BTN[2], BTN[3]);
    drawButton();
    drawTimer();

    if (serial.available() > 0) {
        was_game_finished = serial.read() != 0;
    }

    if (was_game_finished && game_running) {
        serial.clear();
        stop_timer();
        update_map_generating_text = true;
        background(51);
        fill(255, 255, 255);
        textAlign(CENTER, CENTER);
        text("You win!", 0, 0, MAP_SIZE_X * GRID_SIZE, MAP_SIZE_Y * GRID_SIZE);
    }

}

void drawInitialMap() {

    String str = getMap();
    draw_map_background_grid();

    String parts[] = str.strip().split(";");
    
    for (String token : parts) {
        int[] block_data = new int[8];
        int idx = 0;
    
        for (String num_str : token.strip().split(" ")) {
            block_data[idx] = Integer.parseInt(num_str);
            ++idx;
        }
        fill(block_data[4], block_data[5], block_data[6]);
        stroke(255, 255, 255);
        rect(block_data[0] * GRID_SIZE, block_data[1] * GRID_SIZE, block_data[2] * GRID_SIZE, block_data[3] * GRID_SIZE);
        fill(DEFAULT_COLOR[0], DEFAULT_COLOR[1], DEFAULT_COLOR[2]);
    }
}

void drawButton() {
    String btn_text = "Start!";
    int[] btn_color = {34, 139, 34};
    
    if (game_running) {
        btn_text = "Game in process";
        btn_color = BTN_TIMER_COLOR;
    }
    
    fill(btn_color[0], btn_color[1], btn_color[2]);
    rect(BTN[0], BTN[1], BTN[2], BTN[3]);
    fill(255, 255, 255);
    textAlign(CENTER, CENTER);
    text(btn_text, BTN[0], BTN[1], BTN[2], BTN[3]);
    fill(DEFAULT_COLOR[0], DEFAULT_COLOR[1], DEFAULT_COLOR[2]);
}

void drawTimer() {
    fill(BTN_TIMER_COLOR[0], BTN_TIMER_COLOR[1], BTN_TIMER_COLOR[2]);
    rect(TIMER_BOX[0], TIMER_BOX[1], TIMER_BOX[2], TIMER_BOX[3]);
    fill(255, 255, 255);
    textAlign(CENTER, CENTER);
    String time = Integer.toString(timerMinute()) + ":" + Integer.toString(timerSecond()) + ":" + Integer.toString(timerMilliseconds());
    text(time, TIMER_BOX[0], TIMER_BOX[1], TIMER_BOX[2], TIMER_BOX[3]);
    fill(DEFAULT_COLOR[0], DEFAULT_COLOR[1], DEFAULT_COLOR[2]);
}

void mousePressed() {
  if (mouse_over_btn && !game_running) {
      was_game_finished = false;
      start_timer();
  }
}


boolean overRect(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

void start_timer() {
    start_time = millis();
    stop_time = 0;
    game_running = true;
}

void stop_timer() {
    if (game_running)
        stop_time = millis();
    game_running = false;
}

int getElapsedTime() {
    int elapsed;
    if (game_running) {
         elapsed = (millis() - start_time);
    }
    else {
        elapsed = (stop_time - start_time);
    }
    return elapsed;
}

int timerMilliseconds() {
    return getElapsedTime() % 1000;
}

int timerSecond() {
  return (getElapsedTime() / 1000) % 60;
}

int timerMinute() {
  return (getElapsedTime() / (1000*60)) % 60;
}
    
