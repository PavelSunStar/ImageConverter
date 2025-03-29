import controlP5.*;

//win size
int winXX = 400;
int winYY = 200;

//butt
boolean buttonPressed = false;
int buttonX = 5, buttonY = 5, buttonW = 150, buttonH = 15;

//sweech
boolean isRGB565 = true;  // Переменная для переключения форматов
int swX = 160, swY = 5, swW = 100, swH = 15;

//Text input
ControlP5 cp5;
Textfield textField;
String fileName = "";

//files
String filePath = "Файл не выбран";
String folderPath = "Папка не выбрана";
File[] files;

//picture
PImage img = null;
String imgPath = "";

//Array
ArrayList<String> lines = new ArrayList<String>();
ArrayList<String> head = new ArrayList<String>();
String line = "";
int spriteCont = 0;
int skipImg = 0;
String skipString = "";
int imgSize = 0;
int pos1, pos2, pos3, pos4;

// Список поддерживаемых расширений
String[] supportedExtensions = {".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff", ".wbmp", ".JPG", ".JPEG", ".PNG", ".GIF", ".BMP", ".TIF", ".TIF", ".TIFF", ".WBMP"};


void setup() {
  size(400, 200);
  
  // Вычисляем координаты для центрирования окна
  int x = (displayWidth - width) / 2;
  int y = (displayHeight - height) / 2;
  
  // Устанавливаем позицию окна
  surface.setLocation(x, y);

  // Инициализируем библиотеку ControlP5
  cp5 = new ControlP5(this);

  // Создаем текстовое поле для ввода имени файла
  textField = cp5.addTextfield("")
    .setPosition(270, 5)
    .setSize(100, 20)
    .setColorBackground(color(255))
    .setAutoClear(false)
    .setColor(color(0));
}


void draw() {
  background(240);

// Рисуем кнопку
  fill(buttonPressed ? color(150) : color(200));
  rect(buttonX, buttonY, buttonW, buttonH, 10);  
  fill(0);
  textAlign(CENTER, CENTER);
  text("Открыть файл", buttonX + buttonW / 2, buttonY + buttonH / 2);
  
//Check box
  fill(200);
  rect(swX, swY, swW, swH, 10);
  fill(0);
  textAlign(CENTER, CENTER);
  text("Формат: " + (isRGB565 ? "RGB565" : "RGB332"), swX + swW / 2, swY + swH / 2);
  
  // Показываем путь к файлу
  //textAlign(LEFT, CENTER);
  //text(filePath, 20, height - 40);
  
  if (img != null) {
     image(img, 0, 25);  // Рисуем изображение немного ниже кнопки

  }  
}

void mousePressed() {
//butt  
  if (mouseX > buttonX && mouseX < buttonX + buttonW &&
      mouseY > buttonY && mouseY < buttonY + buttonH) {
    buttonPressed = true;
    selectInput("Выберите файл:", "fileSelected");
  }
  
//sweech
  // Проверяем клик по кнопке
  if (mouseX > swX && mouseX < swX + swW &&
      mouseY > swY && mouseY < swY + swH) {
    isRGB565 = !isRGB565;  // Переключаем формат
    println("Выбран формат: " + (isRGB565 ? "RGB565" : "RGB332"));
  }
}

void mouseReleased() {
  buttonPressed = false;
}

void fileSelected(File file) {
  if (file != null) {
    filePath = file.getAbsolutePath(); // Полный путь к файлу
    folderPath = file.getParent();     // Папка, где находится файл

    println("Файл: " + filePath);
    println("Папка: " + folderPath);

    // Получаем список файлов в папке
    File folder = new File(folderPath);
    files = folder.listFiles();
    
    if (files != null) {
//Обнуление
      lines.clear(); head.clear(); 
      skipString = "";
      spriteCont = 0;
      int temp = 0;
          
      println("Файлы в папке:");
      for (File f : files) {
        println(f.getName()); // Выводим только имя файла        
        
        imgPath = f.getAbsolutePath();
        // Проверяем расширение файла
        boolean isValidExtension = false;
        for (String ext : supportedExtensions) {
          if (imgPath.toLowerCase().endsWith(ext.toLowerCase())) {
            isValidExtension = true;
            break;
          }
        }
        
        if (isValidExtension) {
          img = null; img = loadImage(imgPath); noStroke();  // Отключаем контуры для изображения
          
          if (img != null) {
            image(img, 0, 20);  // Рисуем изображение немного ниже кнопки
        
            // Выводим информацию о изображении в консоль
            println("Изображение загружено: " + folderPath);
            println("Изображение загружено: " + imgPath);
            println("Ширина изображения: " + img.width);
            println("Высота изображения: " + img.height);
            
//Увеличиваем окно если картинка привышает размер окна            
            if ((winXX < img.width + 5) || (winYY < img.height + 5)) 
            {
              winXX = img.width + 5;
              winYY = img.height + 5;
              surface.setSize(winXX, winYY);
            }
            
//Запись пропусков    
            pos1 = (imgSize >>24) & 0xFF;
            pos2 = (imgSize >>16) & 0xFF;
            pos3 = (imgSize >>8) & 0xFF;
            pos4 = imgSize & 0xFF;
            skipString += "0x" + hex(pos1, 2) + ", " +
                          "0x" + hex(pos2, 2) + ", " +
                          "0x" + hex(pos3, 2) + ", " +
                          "0x" + hex(pos4, 2) + ", //" + imgSize + "\n    ";
            imgSize += img.width * img.height * ((isRGB565) ? 2 : 1) + 4;//Размер картинки
            temp++; if (temp == 10){temp = 0; skipString += "\n    ";}  //Переход каждые 10 значений
           
//Заполняем размер картинки 4 байт             
            int xh = (img.width >> 8) & 0xFF;  int xl = img.width & 0xFF;
            int yh = (img.height >> 8) & 0xFF; int yl = img.height &0xFF; 
            line = "    0x" + hex(xh, 2) + ", 0x" + hex(xl, 2) + 
                     ", 0x" + hex(yh, 2) + ", 0x" + hex(yl, 2) + ", //" + img.width + " x " + img.height;
            lines.add(line);
            
//заполнение самой картинки            
            for (int y = 0; y < img.height; y++){
              line = "    ";
              for (int x = 0; x < img.width; x++){
                int c = img.get(x, y);
                int r = (int) red(c);
                int g = (int) green(c);
                int b = (int) blue(c);
                
                if (isRGB565){
                  int col_h = (getColor(r, g, b) >> 8) & 0xFF;
                  int col_l = getColor(r, g, b) & 0xFF;
                  line += "0x" + hex(col_l, 2) + ", 0x" + hex(col_h, 2) + ", ";
                } else {
                  line += "0x" + hex(getColor(r,g,b),2) + ", ";
                }                
              }
              
              lines.add(line);
            }

//Подщёт к-во картинок  
            lines.add("");
            spriteCont++;
          }
        }
      }

      if (!lines.isEmpty()) {
        int lastIndex = lines.size() - 1;  // Индекс последней строки
        String lastLine = lines.get(lastIndex);  

        if (!lastLine.isEmpty()) {
          // Удаляем последний символ
          lastLine = lastLine.substring(0, lastLine.length() - 2);
          lastLine += "\n};";
          lines.set(lastIndex, lastLine);  // Обновляем строку в списке
        }
      }
      
      // Убираем последний символ, если строка не пуста
      if (skipString.length() > 0) {
          skipString = skipString.substring(0, skipString.length() - 2);
          println(skipString);
      }
      
//Заполнение библиотеки *.h  
//Начало      
      line = "#pragma once\n"; head.add(line);
      line = "#define " + textField.getText() + "_NUM_SPRITES " + spriteCont; head.add(line);
      line = "#define " + textField.getText() + "_COLOR_BIT " + ((isRGB565) ? "16" : "8") + "\n"; head.add(line);
      line = "const uint8_t _" + textField.getText() + "[] PROGMEM = {"; head.add(line);
      line = "    " + ((isRGB565) ? "0x10" : "0x08") + ", 0x" + hex(spriteCont, 2) + ", //COLOR_BIT, NUM_SPRITES\n"; head.add(line);
      line = "    //Sprite positions\n    " + skipString; head.add(line);
      head.add("    //Sprites data");
      head.addAll(lines.subList(0, lines.size() - 1));
      head.add("};");
      
      saveStrings(folderPath + "\\" + textField.getText() + ".h", head.toArray(new String[0]));
      spriteCont = 0;
      imgSize = 0;
    } else {
      println("Ошибка: Не удалось получить список файлов.");
    }
  } else {
    filePath = "Файл не выбран";
    folderPath = "Папка не выбрана";
  }
}

public int getColor(int r, int g, int b) {
  int col;
  
  if (isRGB565){
    //col = ((int)map(r, 0, 256, 0, 32) & 0b11111) << 11;  // Масштабируем красный и сдвигаем влево на 11 бит
    //col |= ((int)map(g, 0, 256, 0, 64) & 0b111111) << 5;      // Масштабируем зелёный и сдвигаем на 5 бита
    //col |= (int)map(b, 0, 256, 0, 32) & 0b11111;           // Масштабируем синий и оставляем 5 бита
    col = ((r * 31 / 255) & 0b11111) << 11 |
          ((g * 63 / 255) & 0b111111) << 5 |
          ((b * 31 / 255) & 0b11111);  
} else {  
    // Масштабируем значения от 0-255 к нужным диапазонам и сдвигаем биты    col = ((r * 255 / 31) & 0b11111) << 11 |
    col = ((r * 7 / 255) & 0b111) << 5 |
          ((g * 7 / 255) & 0b111) << 2 |
          ((b * 3 / 255) & 0b11); 
    
    //col =  ((int)map(r, 0, 256, 0, 8) & 0b111) << 5;  // Масштабируем красный и сдвигаем влево на 5 бит
    //col |= ((int)map(g, 0, 256, 0, 8) & 0b111) << 2;      // Масштабируем зелёный и сдвигаем на 2 бита
    //col |= (int)map(b, 0, 256, 0, 4) & 0b11;           // Масштабируем синий и оставляем 2 бита
  }
    
  return col;
}
