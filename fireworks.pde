ArrayList<BaseFirework> fireworks;
color[][] colorPalettes = {
  { color(255, 100, 150), color(100, 200, 255), color(150, 255, 150),
    color(255, 200, 100), color(200, 100, 255), color(255, 255, 100) }
};
color[] currentPalette;

void setup() {
  size(800, 800);
  fireworks = new ArrayList<BaseFirework>();
  currentPalette = colorPalettes[0];

}

void draw() {
  // クロマキーしたい。目がちかちかするので注意。
  // background(0, 255, 0);

  fill(0, 25);
  rect(0, 0, width, height);
  
  if (random(1) < 0.03) {
    if (random(1) < 0.7) {
      fireworks.add(new Firework());
    } else {
      fireworks.add(new BigFirework());
    }
  }
  
  for (int i = fireworks.size() - 1; i >= 0; i--) {
    BaseFirework fw = fireworks.get(i);
    fw.update();
    fw.show();
    if (fw.isDone()) {
      fireworks.remove(i);
    }
  }
}

// ==========================
// 共通インターフェース
abstract class BaseFirework {
  abstract void update();
  abstract void show();
  abstract boolean isDone();
}

// ==========================
// 通常の花火
class Firework extends BaseFirework {
  Particle launch;
  ArrayList<Particle> exploded;
  boolean explodedFlag = false;
  color fireworkColor;
  
  Firework() {
    fireworkColor = currentPalette[int(random(currentPalette.length))];
    launch = new Particle(new PVector(random(width), height), new PVector(0, random(-12, -8)), fireworkColor, false);
    exploded = new ArrayList<Particle>();
  }
  
  void update() {
    if (!explodedFlag) {
      launch.applyForce(new PVector(0, 0.2));
      launch.update();
      if (launch.vel.y >= 0) {
        explodedFlag = true;
        explode();
      }
    } else {
      for (Particle p : exploded) {
        p.applyForce(new PVector(0, 0.1));
        p.update();
      }
    }
  }
  
  void explode() {
    for (int i = 0; i < 100; i++) {
      PVector dir = PVector.random2D();
      dir.mult(random(2, 6));
      exploded.add(new Particle(launch.pos.copy(), dir, fireworkColor, true));
    }
  }
  
  void show() {
    if (!explodedFlag) {
      launch.show();
    } else {
      for (Particle p : exploded) {
        p.show();
      }
    }
  }
  
  boolean isDone() {
    if (!explodedFlag) return false;
    for (Particle p : exploded) {
      if (!p.isDead()) return false;
    }
    return true;
  }
}

// ==========================
// より大きな花火
class BigFirework extends BaseFirework {
  Particle launch;
  ArrayList<Particle> exploded;
  boolean explodedFlag = false;
  color fireworkColor;
  
  BigFirework() {
    fireworkColor = color(random(255), random(255), random(255));
    launch = new Particle(new PVector(random(width), height), new PVector(0, random(-15, -10)), fireworkColor, false);
    exploded = new ArrayList<Particle>();
  }
  
  void update() {
    if (!explodedFlag) {
      launch.applyForce(new PVector(0, 0.2));
      launch.update();
      if (launch.vel.y >= 0) {
        explodedFlag = true;
        explode();
      }
    } else {
      for (Particle p : exploded) {
        p.applyForce(new PVector(0, 0.08));  // 少し軽い
        p.update();
      }
    }
  }
  
  void explode() {
    for (int i = 0; i < 250; i++) {
      PVector dir = PVector.random2D();
      dir.mult(random(3, 8));
      color col = color(random(200, 255), random(200, 255), random(200, 255));
      exploded.add(new Particle(launch.pos.copy(), dir, col, true, 3.0));
    }
  }
  
  void show() {
    if (!explodedFlag) {
      launch.show();
    } else {
      for (Particle p : exploded) {
        p.show();
      }
    }
  }
  
  boolean isDone() {
    if (!explodedFlag) return false;
    for (Particle p : exploded) {
      if (!p.isDead()) return false;
    }
    return true;
  }
}

// ==========================
// パーティクルクラス
class Particle {
  PVector pos, vel, acc;
  float lifespan = 255;
  color col;
  boolean isExplodedParticle;
  float weight;
  
  Particle(PVector pos, PVector vel, color col, boolean exploded) {
    this(pos, vel, col, exploded, 1.5);
  }
  
  Particle(PVector pos, PVector vel, color col, boolean exploded, float weight) {
    this.pos = pos.copy();
    this.vel = vel.copy();
    this.acc = new PVector();
    this.col = col;
    this.isExplodedParticle = exploded;
    this.weight = weight;
  }
  
  void applyForce(PVector force) {
    acc.add(force);
  }
  
  void update() {
    vel.add(acc);
    pos.add(vel);
    acc.mult(0);
    if (isExplodedParticle) {
      lifespan -= 3;
      vel.mult(0.96);
    }
  }
  
  void show() {
    stroke(red(col), green(col), blue(col), lifespan);
    strokeWeight(weight);
    point(pos.x, pos.y);
  }
  
  boolean isDead() {
    return lifespan < 0;
  }
}
