#include <SPI.h>
#include <MFRC522.h>

#define RST_PIN         9 
#define SS_PIN          10
#define LED_PIN         7
MFRC522 mfrc522(SS_PIN, RST_PIN);

// TODO DO NOT FORGET TO sudo chmod a+rw /dev/ttyACM0

void setup() {
    Serial.begin(9600);
	  SPI.begin();
	  mfrc522.PCD_Init();
    pinMode(LED_PIN, OUTPUT);
	  delay(4);				
}

void loop() {
	  if (mfrc522.PICC_IsNewCardPresent()) {
        Serial.println(1);
        delay(5);
        digitalWrite(LED_PIN, HIGH);
    }    
    else {
        Serial.flush();
        digitalWrite(LED_PIN, LOW);
        delay(500);
    }

}
