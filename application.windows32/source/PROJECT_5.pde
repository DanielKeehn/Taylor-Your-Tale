import processing.sound.*;
import http.requests.*;
import guru.ttslib.*;   //This is the library that allows for the artificial voice at the end of the game.
TTS tts = new TTS();
SoundFile inGameSong;
SoundFile bellSound;
SoundFile titleSong;
boolean storyOver = false;
String myStory = "";
PImage bg; 
PImage titleScreen;
String player1Text;
String player2Text;
String[] magicWords;
int TURNS = 5;
int curTurn = 0;
String[] playerTexts = new String[TURNS * 2];
int totalTime = 10000;
int savedTime;
int oneSecond = 1000;
int threeSeconds = 3000;
int savedTimeforTimer;
int countdownTime;
String playerStatus = "1";
int currentTime = 10;
int currentCountDownTime = 3;
boolean onTitleScreen = true;
boolean startedSong = false;
boolean startedTitleSong = false;
boolean switchPlayerMode = true;
int switchCountdown = 0;
int globalVariableScore = 0; 


void setup() {
  size(1500,1000);
  bg = loadImage("bg.png");
  titleScreen = loadImage("Title.png");
  player1Text = "";
  player2Text = "";
  magicWords = new String[3];
  magicWords[0] = "WOw";
  magicWords[1] = "l33t";
  magicWords[2] = "n33t";
  
 for(int i = 0; i < TURNS * 2; i++){
    playerTexts[i] = "";
  }
    for(int i = 0; i < 3; i++) {
      String letterSet = "abcdefghijklmnopqrstuvwyz";
      char randomLetter = letterSet.charAt((int) random(letterSet.length()));
      GetRequest get = new GetRequest("https://api.datamuse.com/words?sp=" + randomLetter + "*");
      get.send();
      if(get.getContent() == null) {
        //error in response
      } else {
  
        String response = "{\"data\":" + get.getContent() + "}";
        //println(respons
        JSONObject json = parseJSONObject(response);
        if(json == null) {
          //API call fails
        } else {
          JSONArray wordObjs = json.getJSONArray("data");
          int getLen = wordObjs.size();
          int index =(int) random(getLen);
          int index2 =(int) random(getLen);
          int index3 =(int) random(getLen);
          if(index >= 2) {
            index2 = index - 1;
            index3 = index - 2;
          } else if (index <= getLen - 3) {
            index2 = index + 1;
            index3 = index + 2;
          }
          magicWords[i] = wordObjs.getJSONObject(index).getString("word");
        }    
      }
    }
    bellSound = new SoundFile(this, "Ding Sound Effect.mp3");
    inGameSong = new SoundFile(this, "Taylor_Your_Tale_In_Game.mp3");
    titleSong = new SoundFile(this, "Taylor Your Tail Title.mp3");
    savedTime = millis();
    savedTimeforTimer = millis();
}


void draw() {
  if (onTitleScreen == true) {
    if (startedTitleSong == false) {
      titleSong.loop();
      startedTitleSong = true;
    }
     background(titleScreen); 
     fill(58, 59, 60);
     rect(600, 850, 200, 80);
     textSize(60);
     fill(204, 0, 0);
     text("Play", 645 , 910);
     if (overRect(600, 850, 200, 80)) {  
       cursor(HAND);
       strokeWeight(4);
     } else {
       cursor(ARROW);
       strokeWeight(1);
     }
  } else if (onTitleScreen == false) {
    if (startedSong == false) {
      titleSong.stop();
      inGameSong.loop();
      startedSong = true;
      savedTime = millis();
      savedTimeforTimer = millis();
      countdownTime = millis();
    } else {
      background(bg);  
      fill(255);
      textSize(32);
      text(magicWords[0], 100, 400);
      text(magicWords[1], 100, 500);
      text(magicWords[2], 100, 600);
      textSize(75);
      fill(255, 0, 0);
      if (currentTime == 10) {
        text(currentTime, 1280, 250);
      } else {
        text(currentTime, 1310, 250);
      }
      textSize(16);
      fill(0);
      if(curTurn < 10){
        if (switchPlayerMode == true) {
          fill(255,0,0);
          textSize(95);
          if (curTurn == 0) {
             text("GET READY!", 475, 400);
          } else {
            text("SWITCH PLAYERS!", 350, 400);
          }
          text(currentCountDownTime, 700, 500);
          int changeTimer = millis() - savedTimeforTimer;
          if (changeTimer > oneSecond) {
              currentCountDownTime = currentCountDownTime - 1;
              savedTimeforTimer = millis();
            }
          int endSwitchMode = millis() - countdownTime;
          if (endSwitchMode > threeSeconds) {
            savedTime = millis();
            savedTimeforTimer = millis();
            countdownTime = millis();
            currentCountDownTime = 3;
            switchPlayerMode = false;
          }
        } else if (switchPlayerMode == false) {
          fill(255);
          for(int i = 0; i < curTurn + 1; i++){
            if(i % 2 == 0) {
              fill(0);
              //player 1
            } else {
              fill(150,150,0);
              //player 2
            }
            text(playerTexts[i],330, 220 + i * 60, 800, 220 + i * 60 + 20);
          }
          int changeTimer = millis() - savedTimeforTimer;
          if (changeTimer > oneSecond) {
              currentTime = currentTime - 1;
              savedTimeforTimer = millis();
            }
            int passedTime = millis() - savedTime;
          if (passedTime > totalTime) {
            bellSound.play();
            if(playerStatus.equals("1")) {
              playerStatus = "2";
            } else {
              playerStatus = "1";
            }
            currentTime = 10;
            savedTime = millis();
            savedTimeforTimer = millis();
            countdownTime = millis();
            curTurn++;
            switchPlayerMode = true;
          }
          fill(255,0,0);
          textSize(72);
          text(playerStatus,950,960); 
          fill(0);
          textSize(16);
          }
      } else {
        storyOver = true;
        inGameSong.stop();
        for(int i = 0; i < 10; i++){
          if(i % 2 == 0) {
            fill(0);
            //player 1
          } else {
            fill(150,150,0);
            //player 2
          }
          text(playerTexts[i],330, 220 + i * 60, 800, 220 + i * 60 + 20);
        }
        String finalStory = "";
        for(String playerText : playerTexts) {
          finalStory += playerText;
        }
        int score = 0;
        for(int i = 0; i <3; i++) {
          if(finalStory.indexOf(magicWords[i]) != -1) {
            score++;
          }
        }
        fill(255);
        textSize(28);
        text("Magic Words Included", 1190, 400);
        textSize(32);
        text(score,1325,440);
        textSize(28);
        int wordCount = 0;
        char ch[]= new char[finalStory.length()];     
        for(int i=0;i<finalStory.length();i++) {  
          ch[i]= finalStory.charAt(i);  
          if( ((i>0)&&(ch[i]!=' ')&&(ch[i-1]==' ')) || ((ch[0]!=' ')&&(i==0)) ) {
             wordCount++;  
           }
        }
        text("Word Count", 1250, 500);
        textSize(32);
        if (wordCount < 10) {
          text(wordCount, 1325, 540);
        } else if (wordCount >= 10 && wordCount < 100) {
          text(wordCount, 1310, 540);
        } else {
          text(wordCount, 1300, 540);
        }
        
        fill(255);
        rect(1250, 900, 200, 80);
        textSize(35);
        fill(0);
        text("Play Story", 1265 , 952);
        fill(255);
        rect(50, 900, 200, 80);
        fill(0);
        text("Save Story", 65 , 952);
        textSize(16);
        if (overRect(1250, 900, 200, 80) == true || overRect(50, 900, 200, 80) == true) {
          cursor(HAND);
        } else {
          cursor(ARROW);
        }
        myStory = finalStory;
        globalVariableScore = score;
      }
    
    }    
   }
} 


void keyPressed() {
  if(curTurn < 10) {
    if (keyCode == BACKSPACE) {
      if (playerTexts[curTurn].length() > 0) {
        playerTexts[curTurn] = playerTexts[curTurn].substring(0, playerTexts[curTurn].length()-1);
      }
    } else if (keyCode == DELETE) {
        playerTexts[curTurn] = "";
    } else if (keyCode != SHIFT && keyCode != CONTROL && keyCode != ALT) {
        playerTexts[curTurn] = playerTexts[curTurn] + key;
    }  
  }
}


void mousePressed() {
 if (onTitleScreen == true) {
   if (overRect(600, 850, 200, 80)) {
     onTitleScreen = false;
   }
 } else {
   if (storyOver == true) {
     if (overRect(1250, 900, 200, 80) == true) {
       if (globalVariableScore == 3) {
         tts.speak(myStory);
       } else {
         tts.speak("Sorry, you cannot hear the story unless you use all the magic words");
       }
    } else if (overRect(50, 900, 200, 80) == true) {
      if (globalVariableScore == 3) {
          tts.speak("Your story was saved as an image. You can view it in the game folder");
          saveFrame("myStory-######.png");
      } else {
        tts.speak("Sorry, you cannot save the story unless you use all the magic words");
      }
    }
   }
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
