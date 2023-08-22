/*
Developer: Víctor Díaz Iglesias

The goal is to overcome as many waves of enemies as possible, achieving the highest score.
There are 3 types of enemy waves, and with the destruction of each wave, the enemies' health increases, adding difficulty.

Controls are done using both the mouse and keyboard:
    "SPACE" key activates and deactivates the pause menu.
    "b / B" key changes the player's attack type:
        Attack 1 generates attacks without any limit.
        Attack 2 generates more powerful attacks, but one at a time. If there's an attack on the screen by the player, it's not possible to perform a new attack.

    Left-click fixes the target with the mouse pointer, and each click creates a new attack.
    Right-click fixes the target with the mouse pointer, and the click indicates the point where the character will move to.



The code consists of:
    - Classes for managing different elements (character, bullet, explosion, enemyAttack, enemy, enemyWaveManager).
    - Multiple lists for storing, managing, and deleting attacks and enemies.
    - Setup and Draw, where the game menus are easily managed by calling various functions responsible for each part.
    - Game functions responsible for game development and menus.
    - Interaction functions that control user interaction with the keyboard, mouse, and interface elements.

To accomplish this project, the code has been developed comprehensively. Visually, original designs and images from the freepek image gallery have been used.


Resources and References:
    Processing. (n.d.). Retrieved from https://processing.org/
    Upklyak. (n.d.). Juego de fuegos artificiales púrpuras que explotan: efecto de explosión de sprites de animación [Vector Image]. Retrieved from https://www.freepik.es/vector-gratis/juego-fuegos-artificiales-purpuras-que-explotan-efecto-explosion-sprites-animacion_21845823.htm#query=sprite%20sheet%20laser&position=39&from_view=search&track=ais
    Upklyak. (n.d.). Hoja de sprite de animación de secuencia de explosión de bomba [IVector Image]. Retrieved from https://www.freepik.es/vector-gratis/hoja-sprite-animacion-secuencia-explosion-bomba_29084609.htm#query=sprite%20sheet%20attack&position=1&from_view=search&track=ais
    Upklyak. (n.d.). Pistola que destella humo, destellos de fuego y nubes de disparos: pistola de explosión, escopeta boca, movimiento explosivo, senderos de balas y armas aisladas sobre fondo negro ilustración 3D realista conjunto de iconos [Vector Image]. Retrieved from https://www.freepik.es/vector-gratis/pistola-destella-humo-destellos-fuego-nubes-disparos-pistola-explosion-escopeta-boca-movimiento-explosivo-senderos-balas-armas-aisladas-sobre-fondo-negro-ilustracion-3d-realista-conjunto-iconos_10798305.htm#query=spritesheet%20bullet&position=28&from_view=search&track=ais
    Vectorpouch. (n.d.). Planetas en el espacio exterior con satélites y meteoritos [Vector Image]. Retrieved from https://www.freepik.es/vector-gratis/planetas-espacio-exterior-satelites-meteoritos-ilustracion_6690897.htm#query=space%20planet&position=1&from_view=search&track=aisis

*/



//Game Variables
Character character;
EnemyWaveManager waveManager;
ArrayList<Enemy> enemies;
ArrayList<EnemyAttack> enemyAttacks;
ArrayList<Bullet> bullets;
ArrayList<Explosion> explosions;
int frameSize, typeAttack, tempAttack, score, attackDamange, waveEnemy, controlWaveEnemy;
boolean isPaused, isHome, isInfo, restart, isAttackBullet, isAttackExplosion;
float homeX, homeSpeed;


//UI Variables
PFont font;
PImage imgBackgroundHome;
PImage imgBackground;
PImage imgStart;
PImage imgLogo;
PImage imgMenu;
PImage imgPlay;
PImage imgReset;
PImage imgSoundOff;
PImage imgSoundOn;
PImage imgInfo;
PImage imgIngoGame;
PImage imgButtonBack;
PImage imgButtonBullet;
PImage imgButtonBulletSelect;
PImage imgButtonExplosion;
PImage imgButtonExplosionSelect;


//USED CLASSES
//Class that manages the player-controlled character
class Character {
    // Character variables
    float posX, posY, life, lifeUI, totalLife, velocity, targetX, targetY;
    boolean isMoving;
    
    // Animation variables
    PImage spriteSheetCharStatic;
    PImage spriteSheetCharMove;
    PImage spriteSheetCharDie;
    
    PImage[] animationFramesCharStatic;
    PImage[] animationFramesCharMove;
    PImage[] animationFramesCharDie;
    
    int currentFrame, frameDelay;
    float lastFrameTime;
    
    // Character Builder
    Character(float posX, float posY) {
        this.posX = posX;
        this.posY = posY;
        this.velocity = 5;
        totalLife = 100;
        life = totalLife;
        lifeUI = 0;
        
        // Animation Settings
        frameDelay = 100;
        lastFrameTime = millis();
        
        // Load sprite sheets
        spriteSheetCharStatic = loadImage("Resources/Character/naveStatic.png");
        spriteSheetCharMove = loadImage("Resources/Character/naveMove.png");
        spriteSheetCharDie = loadImage("Resources/Character/naveDie.png");
        
        // Load and split animation frames
        animationFramesCharStatic = loadAnimationFrames(spriteSheetCharStatic, 6, frameSize);
        animationFramesCharMove = loadAnimationFrames(spriteSheetCharMove, 6, frameSize);
        animationFramesCharDie = loadAnimationFrames(spriteSheetCharDie, 6, frameSize);
        
    }
    
    // Function that draws and controls the movement of the character
    void draw() {
        if (isMoving) {
            float dx = targetX - posX;
            float dy = targetY - posY;
            float distance = sqrt(dx * dx + dy * dy);
            
            if (distance > velocity) {
                float ratio = velocity / distance;
                posX += dx * ratio;
                posY += dy * ratio;
                float rotationAngle = atan2(dy, dx);
                
                //Rotate the thruster animation in the character's direction of movement
                pushMatrix();
                translate(posX, posY);
                rotate(rotationAngle + HALF_PI);
                animation(animationFramesCharMove, -frameSize / 2, -frameSize / 2);
                popMatrix();
            } else {
                posX = targetX;
                posY = targetY;
                isMoving = false;
            }
        } else {
            animation(animationFramesCharStatic, posX - frameSize / 2, posY - frameSize / 2);
        }
        
        //When life reaches 0
        if (life <= 0) {
            animation(animationFramesCharDie, posX - frameSize / 2, posY - frameSize / 2);
            menuDie();
        }
        
    }
    
    //Function that generates the animation
    void animation(PImage[] animationFrame, float x, float y) {
        float currentTime = millis();
        float deltaTime = currentTime - lastFrameTime;
        
        if (deltaTime >= frameDelay) {
            currentFrame = (currentFrame + 1) % animationFrame.length;
            lastFrameTime = currentTime;
        }
        image(animationFrame[currentFrame], x, y);
    }
    
    //Function that saves the coordinates of the destination of the movement
    void setDestination(float targetX, float targetY) {
        this.targetX = targetX;
        this.targetY = targetY;
        isMoving = true;
    }
    
    // Function that generates the attacks
    void attack() {
        float directionX = mouseX - posX;
        float directionY = mouseY - posY;
        float directionMagnitude = sqrt(directionX * directionX + directionY * directionY);
        float normalizedDirectionX = directionX / directionMagnitude;
        float normalizedDirectionY = directionY / directionMagnitude;
        
        //Attack type 1
        if (typeAttack == 1 && !isAttackExplosion) {
            Bullet bullet = new Bullet(posX + normalizedDirectionX * frameSize / 2, posY + normalizedDirectionY * frameSize / 2, normalizedDirectionX, normalizedDirectionY);
            bullets.add(bullet);
            tempAttack = typeAttack;
            
            //Attack type 2
        } else if (typeAttack == 2 && !isAttackBullet && !isAttackExplosion) {
            Explosion explosion = new Explosion(posX + normalizedDirectionX * frameSize / 2, posY + normalizedDirectionY * frameSize / 2, normalizedDirectionX, normalizedDirectionY);
            explosions.add(explosion);
            tempAttack = typeAttack;
        }
    }
}

//Class that manages Type 1 attacks
class Bullet {
    //Attack variables 
    float posX, posY, velocityX, velocityY;
    
    //Animation variables
    PImage spriteSheetBullet;
    PImage[] animationFramesBullet;
    
    int currentFrame, frameDelay;
    float lastFrameTime;
    
    //Constructor of the class
    Bullet(float posX, float posY, float directionX, float directionY) {
        this.posX = posX;
        this.posY = posY;
        this.velocityX = directionX * 5;
        this.velocityY = directionY * 5;
        isAttackBullet = true;
        
        // Animation configuration
        currentFrame = 0;
        frameDelay = 100;
        lastFrameTime = millis();
        
        spriteSheetBullet = loadImage("Resources/Character/bulletFire.png");
        animationFramesBullet = loadAnimationFrames(spriteSheetBullet, 9, frameSize);
    }
    
    // Draw atack
    void draw() {
        posX += velocityX;
        posY += velocityY;
        
        // Calculate rotation angle and draw the animation in its correct orientation
        float rotationAngle = atan2( -velocityY, -velocityX);
        
        pushMatrix();  
        translate(posX, posY); 
        rotate(rotationAngle);  
        animation(animationFramesBullet);
        popMatrix();  
    }
    
    // Generate attack animations
    void animation(PImage[] animationFrame) {
        float currentTime = millis();
        float deltaTime = currentTime - lastFrameTime;
        
        if (deltaTime >= frameDelay) {
            currentFrame = (currentFrame + 1) % animationFrame.length;
            lastFrameTime = currentTime;
        }
        
        image(animationFrame[currentFrame], -frameSize / 2, -frameSize / 2);  // Draw at relative center
    }
    
    // If the attack goes off-screen
    boolean isOffScreen() {
        return posX < 0 || posX > width || posY < 0 || posY > height;
    }
    
    // If the attack collides with the enemy
    boolean collidesWithEnemy() {
        for (int i = 0; i < enemies.size(); i++) {
            if (enemies.get(i) != null) {
                Enemy enemy = enemies.get(i);
                float distanceX = abs(posX - enemy.posX);
                float distanceY = abs(posY - enemy.posY);
                
                // Check collision considering the height difference.
                if (distanceX < frameSize - 40 && distanceY < frameSize - 40) {
                    enemy.life -= attackDamange;
                    return true;
                }
            }
        }
        return false;
    }
    
}

// Class that manages Type 2 attacks
class Explosion {
    // Attack variables
    float posX, posY, velocityX, velocityY;
    
    // Animation variables
    PImage spriteSheetExplosion;
    PImage[] animationFramesExplosion;
    
    int currentFrame, frameDelay;
    float lastFrameTime;
    
    // Class constructor
    Explosion(float posX, float posY, float directionX, float directionY) {
        this.posX = posX;
        this.posY = posY;
        this.velocityX = directionX * 5;
        this.velocityY = directionY * 5;
        isAttackExplosion = true;
        
        // Animation configuration
        currentFrame = 0;
        frameDelay = 100;
        lastFrameTime = millis();
        
        spriteSheetExplosion = loadImage("Resources/Character/bulletExplosion.png");
        animationFramesExplosion = loadAnimationFrames(spriteSheetExplosion, 9, frameSize);
    }
    
    // Draw the attack
    void draw() {
        posX += velocityX;
        posY += velocityY;
        
        // Calculate rotation angle and draw the animation in its correct orientation
        float rotationAngle = atan2(-velocityY, -velocityX);
        
        pushMatrix();  
        translate(posX, posY);  
        rotate(rotationAngle);  
        animation(animationFramesExplosion);
        popMatrix(); 
    }
    
    // Manage class animations
    void animation(PImage[] animationFrame) {
        float currentTime = millis();
        float deltaTime = currentTime - lastFrameTime;
        
        if (deltaTime >= frameDelay) {
            currentFrame = (currentFrame + 1) % animationFrame.length;
            lastFrameTime = currentTime;
        }
        
        image(animationFrame[currentFrame], -frameSize / 2, -frameSize / 2); 
    }
    
    // If the attack goes off-screen
    boolean isOffScreen() {
        return posX < 0 || posX > width || posY < 0 || posY > height;
    }
    
    // If the attack collides with an enemy
    boolean collidesWithEnemy() {
        for (int i = 0; i < enemies.size(); i++) {
            if (enemies.get(i) != null) {
                Enemy enemy = enemies.get(i);
                float distanceX = abs(posX - enemy.posX);
                float distanceY = abs(posY - enemy.posY);
                
                // Check collision considering the height difference
                if (distanceX < frameSize - 40 && distanceY < frameSize - 40) {
                    enemy.life -= attackDamange * 3;
                    return true;
                }
            }
        }
        return false;
    }  
}


// Class that manages enemy attacks
class EnemyAttack {
    // Attack variables
    float posX, posY, velocityX, velocityY;
    
    // Animation variables
    PImage spriteSheetEnemyAttack;
    PImage[] animationFramesEnemyAttack;
    
    int currentFrame, frameDelay;
    float lastFrameTime;
    
    // Class constructor
    EnemyAttack(float posX, float posY, float directionX, float directionY) {
        this.posX = posX;
        this.posY = posY;
        this.velocityX = directionX * 5;
        this.velocityY = directionY * 5;
        
        // Animation configuration
        currentFrame = 0;
        frameDelay = 100;
        lastFrameTime = millis();
        
        spriteSheetEnemyAttack = loadImage("Resources/Character/enemyAttack.png");
        animationFramesEnemyAttack = loadAnimationFrames(spriteSheetEnemyAttack, 9, frameSize);
    }
    
    // Draw enemy attacks
    void draw() {
        posX += velocityX;
        posY += velocityY;
        
        // Calculate rotation angle and draw the animation in its correct orientation
        float rotationAngle = atan2(-velocityY, -velocityX);
        
        pushMatrix();  
        translate(posX, posY);  
        rotate(rotationAngle);  
        animation(animationFramesEnemyAttack);
        popMatrix(); 
    }
    
    // Manage class animations
    void animation(PImage[] animationFrame) {
        float currentTime = millis();
        float deltaTime = currentTime - lastFrameTime;
        
        if (deltaTime >= frameDelay) {
            currentFrame = (currentFrame + 1) % animationFrame.length;
            lastFrameTime = currentTime;
        }
        
        image(animationFrame[currentFrame], -frameSize / 2, -frameSize / 2);  
    }
    
    // If the attack goes off-screen
    boolean isOffScreen() {
        return posX < 0 || posX > width || posY < 0 || posY > height;
    }
    
    // If the attack collides with the character
    boolean collidesWithCharacter() {
        float distanceX = abs(posX - character.posX);
        float distanceY = abs(posY - character.posY);
        
        // Check collision considering the height difference
        if (distanceX < frameSize - 50 && distanceY < frameSize - 50) {
            character.life -= 2;
            character.lifeUI += 2;
            return true;
        }
        
        return false;
    }  
}


// Class that manages enemies
class Enemy {
    // Enemy variables
    float posX, posY, life, lifeBar, attackTimer, nextAttackTimer;
    boolean lifeControl;
    
    // Animation variables
    PImage spriteSheetRobotMovement;
    PImage spriteSheetRobotDie;
    
    PImage[] animationFramesRobotMovement;
    PImage[] animationFramesRobotDie;
    
    int currentFrame, frameDelay;
    float lastFrameTime;
    
    // Class constructor
    Enemy(float posX, float posY) {
        // Enemy variables
        this.posX = posX;
        this.posY = posY;
        life = 100;
        lifeControl = false;
        
        // Attack configuration
        attackTimer = 0;
        nextAttackTimer = random(3000, 5000);
        
        // Animation configuration
        frameDelay = 100;
        lastFrameTime = millis();
        
        // Load sprite sheets
        spriteSheetRobotMovement = loadImage("Resources/Character/robotMovement.png");
        spriteSheetRobotDie = loadImage("Resources/Character/robotDie.png");
        
        // Load and divide animation frames
        animationFramesRobotMovement = loadAnimationFrames(spriteSheetRobotMovement, 7, frameSize);
        animationFramesRobotDie = loadAnimationFrames(spriteSheetRobotDie, 7, frameSize);
    }
    
    // Draw enemies
    void draw() {
        // If life is greater than 0
        if (life > 0) {
            // Draw the enemy and its life bar
            animation(animationFramesRobotMovement);
            stroke(255);
            fill(0, 255, 0);
            rect(posX - 22, posY - 50, life / 4, 5, 3);
            
            // Generate their attacks
            float deltaTime = millis() - lastFrameTime;
            attackTimer += deltaTime;
            
            if (attackTimer >= nextAttackTimer) {
                attack();
                attackTimer = 0;
                nextAttackTimer = random(3000, 5000);
            }
            lastFrameTime = millis();
            
            // If out of life
        } else if (life <= 0) {
            animation(animationFramesRobotDie);
            if (currentFrame == animationFramesRobotDie.length - 1) {
                lifeControl = true;
            }
        }
    }
    
    // Manage class animations
    void animation(PImage[] animationFrame) {
        float currentTime = millis();
        float deltaTime = currentTime - lastFrameTime;
        
        if (deltaTime >= frameDelay) {
            currentFrame = (currentFrame + 1) % animationFrame.length;
            lastFrameTime = currentTime;
        }
        
        image(animationFrame[currentFrame], posX - frameSize / 2, posY - frameSize / 2);
    }
    
    // Generate enemy attacks
    void attack() {
        float directionX = character.posX - posX;
        float directionY = character.posY - posY;
        float directionMagnitude = sqrt(directionX * directionX + directionY * directionY);
        float normalizedDirectionX = directionX / directionMagnitude;
        float normalizedDirectionY = directionY / directionMagnitude;
        
        EnemyAttack enemyAttack = new EnemyAttack(posX + normalizedDirectionX * frameSize / 2, posY + normalizedDirectionY * frameSize / 2, normalizedDirectionX, normalizedDirectionY);
        enemyAttacks.add(enemyAttack);
    }
    
    // Detect collision with the character
    void collidesWithCharacter() {
        float distanceX = abs(posX - character.posX);
        float distanceY = abs(posY - character.posY);
        
        // Check collision considering the height difference
        if (distanceX < frameSize - 50 && distanceY < frameSize - 50) {
            character.life -= 10;
            character.lifeUI += 10;
        }
    } 
}

// Class that generates enemy waves
class EnemyWaveManager {
    ArrayList<Enemy> enemyWave, enemyWaveD;
    float spacing = 10;
    float blockSpeedX, blockSpeedY, blockSpeedYD; 
    
    // Class constructor
    EnemyWaveManager() {
        blockSpeedX = blockSpeedY = 1;
        blockSpeedYD = -1;
        
        enemies = new ArrayList<Enemy>();
        
        // Wave of type 1 enemies
        if (controlWaveEnemy == 1) {
            int numEnemiesWidth = 8;
            int numEnemiesHeight = 2;
            
            float gridWidth = numEnemiesWidth * (frameSize + spacing) - spacing;
            float gridHeight = numEnemiesHeight * (frameSize + spacing) - spacing;
            
            float startX = (width - gridWidth) / 2;
            float startY = (height - gridHeight) / 2;
            
            for (int i = 0; i < numEnemiesWidth; i++) {
                for (int j = 0; j < numEnemiesHeight; j++) {
                    float posX = startX + (spacing + frameSize) * i;
                    float posY = startY + (spacing + frameSize) * j;
                    
                    enemies.add(new Enemy(posX, posY)); 
                }
            }
        }
        // Wave of type 2 enemies
        if (controlWaveEnemy == 2) {
            enemyWave = new ArrayList<Enemy>();
            enemyWaveD = new ArrayList<Enemy>();
            
            int numEnemiesWidth = 2;
            int numEnemiesHeight = 4;
            
            float gridWidthI = numEnemiesWidth * (frameSize + spacing) - spacing;
            float gridHeightI = numEnemiesHeight * (frameSize + spacing) - spacing;
            
            float startXI = gridWidthI / 2;
            float startYI = gridHeightI / 2;
            
            float gridWidthD = numEnemiesWidth * (frameSize + spacing) - spacing;
            float gridHeightD = numEnemiesHeight * (frameSize + spacing) - spacing;
            
            float startXD =  width - gridWidthD;
            float startYD = height - gridHeightD - 80;
            
            for (int i = 0; i < numEnemiesWidth; i++) {
                for (int j = 0; j < numEnemiesHeight; j++) {
                    float posX = startXI + (spacing + frameSize) * i;
                    float posY = startYI + (spacing + frameSize) * j;
                    
                    enemyWave.add(new Enemy(posX, posY)); 
                }
            }
            
            for (int i = 0; i < numEnemiesWidth; i++) {
                for (int j = 0; j < numEnemiesHeight; j++) {
                    float posX = startXD + (spacing + frameSize) * i;
                    float posY = startYD + (spacing + frameSize) * j;
                    
                    enemyWaveD.add(new Enemy(posX, posY)); 
                }
            }
            
            enemies.addAll(enemyWave);
            enemies.addAll(enemyWaveD);
            
        }
        // Wave of type 3 enemies
        if (controlWaveEnemy == 3) {
            int numEnemiesWidth = 4;
            int numEnemiesHeight = 4;
            
            float gridWidth = numEnemiesWidth * (frameSize + spacing) - spacing;
            float gridHeight = numEnemiesHeight * (frameSize + spacing) - spacing;
            
            float startX = width / 2 - gridWidth / 2;
            float startY = height / 2 - gridHeight / 2 + 50;
            
            for (int i = 0; i < numEnemiesWidth; i++) {
                for (int j = 0; j < numEnemiesHeight; j++) {
                    float posX = startX + (spacing + frameSize) * i;
                    float posY = startY + (spacing + frameSize) * j;
                    
                    enemies.add(new Enemy(posX, posY)); 
                }
            }
            
        }
    }

    // Draw enemy waves
    void drawEnemyWave() {
        if (controlWaveEnemy == 1) {
            for (Enemy enemy : enemies) {
                enemy.draw();
                enemy.posX -= blockSpeedX;
                
                if (enemy.posX < 0 + frameSize / 2 || enemy.posX > width - frameSize / 2) {
                    blockSpeedX *= -1;
                    break;
                }
            }
        } else if (controlWaveEnemy == 2) {
            for (Enemy enemy : enemyWave) {
                enemy.draw();
                enemy.posY -= blockSpeedY;
                
                if (enemy.posY < 0 + frameSize / 2 + 20 || enemy.posY > height - frameSize / 2) {
                    blockSpeedY *= -1;
                    break;
                }
            }
            for (Enemy enemy : enemyWaveD) {
                enemy.draw();
                enemy.posY -= blockSpeedYD;
                
                if (enemy.posY < 0 + frameSize / 2 + 20 || enemy.posY > height - frameSize / 2) {
                    blockSpeedYD *= -1;
                    break;
                }
            }
        } else if (controlWaveEnemy == 3) {
            for (Enemy enemy : enemies) {
                enemy.draw();
            }
        }  
    }
}




//SETUP y DRAW
//Setup
void setup() {
    // General settings
    size(1280, 720);
    frameSize = 80;
    score = 0;
    isHome = true;
    isPaused = restart = isInfo = false;
    
    // Interface element configurations
    font = createFont("Arial Bold", 20);
    textFont(font);
    
    homeX = 0;
    homeSpeed = 1;
    
    imgBackgroundHome = loadImage("Resources/Backgrounds/backgroundHome.jpg");
    imgBackground = loadImage("Resources/Backgrounds/backgroundLevel1.jpg");
    imgLogo = loadImage("Resources/UI/logo.png");
    imgStart = loadImage("Resources/UI/buttonStart.png");
    imgMenu = loadImage("Resources/UI/menuPause.png");
    imgPlay = loadImage("Resources/UI/buttonPlay.png");
    imgReset = loadImage("Resources/UI/buttonReset.png");
    imgSoundOff = loadImage("Resources/UI/buttonSoundOff.png");
    imgSoundOn = loadImage("Resources/UI/buttonSoundOn.png");
    imgInfo = loadImage("Resources/UI/buttonInfo.png");
    imgIngoGame = loadImage("Resources/UI/infoGame.png");
    imgStart = loadImage("Resources/UI/buttonStart.png");
    imgButtonBack = loadImage("Resources/UI/buttonBack.png");
    imgButtonBullet = loadImage("Resources/UI/buttonBullet.png");
    imgButtonBulletSelect = loadImage("Resources/UI/buttonBulletSelect.png");
    imgButtonExplosion = loadImage("Resources/UI/buttonExplosion.png");
    imgButtonExplosionSelect = loadImage("Resources/UI/buttonExplosionSelect.png");
    
    // Create characters and configurations
    typeAttack = 1;
    isAttackExplosion = isAttackBullet = false;
    attackDamange = 34;
    waveEnemy = 1;
    controlWaveEnemy = 1;
    bullets = new ArrayList<Bullet>();
    explosions = new ArrayList<Explosion>();
    enemyAttacks = new ArrayList<EnemyAttack>();
    character = new Character(width / 2, height - 50);
    waveManager = new EnemyWaveManager();
}

// Draw function
void draw() {
    // Restart the game
    if (restart) {
        setup();
    }
    
    // Home screen
    if (isHome) {
        menuHome();
        // Info screen
        if (isInfo) {
            menuInfo();
        }
    }
    // Game paused
    else if (isPaused) {
        menuPause();
        // Info screen
        if (isInfo) {
            menuInfo();
        }
    }
    // Game over
    else if (character.life < 0) {
        menuDie();
    }
    // Game running
    else {
        menuGame();
    }
}




//GAME FUNCTIONS
//Draws scene and interface
void userInterface() {
    //Background image
    image(imgBackground, 0, 0);

    //Character's life
    stroke(255);
    fill(200,200,200,120);
    rect(width - character.totalLife - 20, height - 20, character.totalLife, 10, 5);
    noStroke();
    fill(0,255,0);
    rect(width - character.totalLife - 20 + character.lifeUI, height - 20, character.life, 10, 5);

    //Attack type, changes with b/B key
    if (typeAttack == 1) {
        image(imgButtonBulletSelect, width - 150, height - 100, 60, 60);
        image(imgButtonExplosion, width - 80, height - 100, 60, 60);
    } else if (typeAttack == 2) {
        image(imgButtonBullet, width - 150, height - 100, 60, 60);
        image(imgButtonExplosionSelect, width - 80, height - 100, 60, 60);
    }

    //Score text
    textAlign(LEFT, BOTTOM);
    textSize(15);
    fill(255);
    text("Score", 10, height - 30);
    textSize(20);
    fill(255);
    text(str(score), 10, height - 10);
}

//Draws pause menu
void menuPause() {
    imageMode(CENTER);
    //Draws background
    fill(50, 50, 50, 5);
    noStroke();
    rect(0, 0, width, height);
    //Draws menu and buttons
    image(imgMenu, width / 2 , height / 2);
    image(imgPlay, width / 2 - 100, height / 2 + 70);
    image(imgReset, width / 2 + 100, height / 2 + 70);
    image(imgInfo, width / 2 + 350 , height / 2 - 130);
    //Draw text on each button
    textSize(20);
    textAlign(CENTER, CENTER);
    fill(0);
    text("Play Game", width / 2 - 100, height / 2 + imgPlay.height / 2 + 90);
    text("Reset Game", width / 2 + 100, height / 2 + imgReset.height / 2 + 90);
    //Score text
    textSize(15);
    fill(200);
    text("Score", width / 2 , height / 2 - 80);
    textSize(40);
    fill(255);
    text(str(score), width / 2, height / 2 - 50);
}

//Draws home menu
void menuHome() {
    imageMode(CORNER);
    image(imgBackgroundHome, homeX, 0);
    homeX -= homeSpeed;
    if (homeX <= -imgBackgroundHome.width + width || homeX >= 0) {
        homeSpeed *= -1;
    }
    image(imgStart, width / 2 - imgStart.width / 2, height / 2);
    image(imgLogo, width / 2 - imgLogo.width / 2, 50);
    image(imgInfo, width - imgInfo.width - 10, 10);
}

//Draws the game
void menuGame() {
    imageMode(CORNER);
    userInterface();

    character.draw();
    waveManager.drawEnemyWave();

    //Selected attack type 1
    if (tempAttack == 1) {
        for (int i = bullets.size() - 1; i >= 0; i--) {
            Bullet bullet = bullets.get(i);
            bullet.draw();

            if (bullet.isOffScreen() || bullet.collidesWithEnemy()) {
                bullets.remove(i);
            }
        }

    //Selected attack type 2
    } else if (tempAttack == 2) {
        for (int i = explosions.size() - 1; i >= 0; i--) {
            Explosion explosion = explosions.get(i);
            explosion.draw();

            if (explosion.isOffScreen() || explosion.collidesWithEnemy()) {
                explosions.remove(i);
                isAttackExplosion = false;
            }
        }
    }

    //No attacks on screen
    if (bullets.isEmpty()) {
        isAttackBullet = false;
    }

    //Managing enemies
    for (int i = enemies.size() - 1; i >= 0; i--) {
        Enemy enemy = enemies.get(i);
        if (enemy != null) {
            if (enemy.lifeControl) {
                if (controlWaveEnemy == 2) {
                    if (waveManager.enemyWave.contains(enemy)) {
                        waveManager.enemyWave.remove(enemy);
                    } else if (waveManager.enemyWaveD.contains(enemy)) {
                        waveManager.enemyWaveD.remove(enemy);
                    }
                }

                enemies.remove(i);

                score += 5 * waveEnemy;
            } else {
                enemy.draw();
            }

            enemy.collidesWithCharacter();  
        }
    }

    //Managing enemy attacks
    for (int i = enemyAttacks.size() - 1; i >= 0; i--) {
        EnemyAttack enemyAttack = enemyAttacks.get(i);
        enemyAttack.draw();

        if (enemyAttack.isOffScreen() || enemyAttack.collidesWithCharacter()) {
            enemyAttacks.remove(i);
        }
    }

    //Generate a new wave of enemies with increased difficulty
    if (enemies.size() == 1) {

        attackDamange = (attackDamange > 1) ? attackDamange - 3 : 1;

        controlWaveEnemy ++;
        controlWaveEnemy = (controlWaveEnemy == 4) ? 1 : controlWaveEnemy;

        waveEnemy++;
        waveManager = new EnemyWaveManager();

    }
}


//Draws the game over menu
void menuDie() {
    imageMode(CENTER);
    //Draws background
    fill(50, 50, 50, 5);
    noStroke();
    rect(0, 0, width, height);
    //Draws menu and buttons
    image(imgMenu, width / 2 , height / 2);
    image(imgReset, width / 2, height / 2 + 70);
    //Draw text on each button
    textSize(20);
    textAlign(CENTER, CENTER);
    fill(0);
    text("Reset Game", width / 2, height / 2 + imgReset.height / 2 + 90);
    //Score text
    textSize(15);
    fill(200);
    text("Score", width / 2 , height / 2 - 80);
    textSize(40);
    fill(255);
    text(str(score), width / 2, height / 2 - 50);
    text("Game Over", width / 2, height / 2 - 140);

}

//Draws the instructions menu
void menuInfo() {
    imageMode(CENTER);
    //Draws background
    fill(50, 50, 50, 5);
    noStroke();
    rect(0, 0, width, height);
    //Draws menu and buttons
    image(imgMenu, width / 2 , height / 2);
    image(imgIngoGame, width / 2 , height / 2);
    image(imgButtonBack, width / 2 - 350 , height / 2 - 130);
    // Game information
    textSize(30);
    textAlign(CENTER, CENTER);
    fill(200);
    text("How to play", width / 2 + 50, height / 2 - 160);
}

//Loads animation sprite sheets
PImage[] loadAnimationFrames(PImage spriteSheet, int numFrames, int frameSize) {
    PImage[] animationFrames = new PImage[numFrames];
    for (int i = 0; i < numFrames; i++) {
        int x = i * frameSize;
        int y = 0;
        animationFrames[i] = spriteSheet.get(x, y, frameSize, frameSize);
    }
    return animationFrames;
}


//INTERACTION FUNCTIONS
//Detects key press
void keyPressed() {
    //Activates pause menu
    if (keyCode == ' ' && !isHome) {
        isPaused = !isPaused;
        
        //Change attack type
    } else if (key == 'b' || key == 'B') {
        typeAttack = (typeAttack == 1) ? 2 : 1;
    }
}


//Detects mouse press
void mousePressed() {
    //If the game is running
    if (!isHome && !isPaused && character.life > 0) {
        //With left click, set and launch the attack
        if (mouseButton == LEFT) {
            character.attack();
            
            //With right click, set the destination for character movement
        } else if (mouseButton == RIGHT) {
            character.setDestination(mouseX, mouseY);
        }
    }
}


//Detects mouse release
void mouseReleased() {
    //In the pause menu
    if (isPaused && !isInfo) {
        if (mouseX > width / 2 - 100 - imgPlay.width / 2 && mouseX < width / 2 - 100 + imgPlay.width / 2 && mouseY > height / 2 + 70 - imgPlay.height / 2 && mouseY < height / 2 + 70 + imgPlay.height / 2) {
            // Modify pause state
            isPaused = false;
        } else if (mouseX > width / 2 + 100 - imgReset.width / 2 && mouseX < width / 2 + 100 + imgReset.width / 2 && mouseY > height / 2 + 70 - imgReset.height / 2 && mouseY < height / 2 + 70 + imgReset.height / 2) {
            // Reset the game
            isPaused = false;
            isHome = true;
            restart = true;
        } else if (mouseX >= width / 2 + 350 - imgButtonBack.width / 2 && mouseX <= width / 2 + 350 + imgButtonBack.width / 2 && mouseY >= height / 2 - 130 - imgButtonBack.height / 2 && mouseY <= height / 2 - 130 + imgButtonBack.height / 2) {
            // Close info
            isInfo = true;
        }
    }
    
    //In the home menu
    if (isHome && !isInfo) {
        if (mouseX >= width / 2 - imgStart.width / 2 && mouseX <= width / 2 + imgStart.width / 2 && mouseY >= height / 2 && mouseY <= height / 2 + imgStart.height) {
            // Start the game
            isHome = false;
            isPaused = false;
        }
        if (mouseX >= width - imgInfo.width - 10 && mouseX <= width - 10 && mouseY >= 10 && mouseY <= 10 + imgInfo.height) {
            // Actions to perform when imgInfo image is clicked
            isInfo = true;
        }
        
    }
    
    // Character with no life
    if (character.life < 0) {
        if (mouseX >= width / 2 - imgReset.width / 2 && mouseX <= width / 2 + imgReset.width / 2 && mouseY >= height / 2 - imgReset.height / 2 && mouseY <= height / 2 + imgReset.height / 2) {
            // Reset the game
            isPaused = false;
            isHome = true;
            restart = true;
        }
    }
    
    //In the information menu
    if (isInfo && isHome || isInfo && isPaused) {
        if (mouseX >= width / 2 - 350 - imgButtonBack.width / 2 && mouseX <= width / 2 - 350 + imgButtonBack.width / 2 && mouseY >= height / 2 - 130 - imgButtonBack.height / 2 && mouseY <= height / 2 - 130 + imgButtonBack.height / 2) {
            // Close info
            isInfo = false;
        }
    }
}
