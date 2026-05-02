import GameService from '../services/GameService';
import AudioService from '../services/AudioService';
import ScoreService from '../services/ScoreServices';
import { GameState, Pipe, GameOverParams } from '../common/Types';
import { sensor, vibrator } from '@kit.SensorServiceKit';

const FLAP_THRESHOLD = 8.0;
const FLAP_COOLDOWN_MS = 300;

export class GameViewModel {
  public birdY: number = 120;
  public flapIndex: number = 0;
  public score: number = 0;
  public pipes: Pipe[] = [];
  public gameState: GameState = GameState.READY;
  public accelEnabled: boolean = true;
  public onStateChanged: (() => void) | null = null;
  public onGameOver: ((params: GameOverParams) => void) | null = null;
  private game: GameService = new GameService();
  private gameInterval?: number;
  private pipeTimer: number = 0;
  private lastFlapTime: number = 0;
  private crownAccumulator: number = 0;
  private readonly CROWN_THRESHOLD: number = 2.0;

  public start(accelEnabled: boolean = true): void {
    this.startGameLoop();
    if (accelEnabled) {
      this.startAccelerometer();
    }
  }

  public destroy(): void {
    this.stopGameLoop();
    this.stopAccelerometer();
  }

  private startGameLoop(): void {
    this.pipeTimer = 0;
    this.gameInterval = setInterval(() => {
      if (this.game.state === GameState.PLAYING) {
        this.game.update();
        this.checkCollisions();

        if (this.pipeTimer++ >= 45) {
          this.game.addPipe();
          this.pipeTimer = 0;
        }

        this.flapIndex++;
        this.score = this.game.score;
        this.birdY = this.game.birdY;
        this.pipes = this.game.pipes;
      }

      this.gameState = this.game.state;
      this.notifyUI();
    }, 30);
  }

  private stopGameLoop(): void {
    if (this.gameInterval) {
      clearInterval(this.gameInterval);
      this.gameInterval = undefined;
    }
  }

  private notifyUI(): void {
    if (this.onStateChanged) {
      this.onStateChanged();
    }
  }

  public async handleTap(): Promise<void> {
    if (this.game.state === GameState.READY) {
      this.game.state = GameState.PLAYING;
      this.triggerHaptic();
      await AudioService.play('swoosh.mp3');
    } else if (this.game.state === GameState.PLAYING) {
      this.game.flap();
      this.triggerHaptic();
      await AudioService.play('wing.mp3');
    }
  }

  public handleCrown(angularVelocity: number): void {
    if (angularVelocity === 0) {
      return;
    }

    this.crownAccumulator += Math.abs(angularVelocity);

    if (this.crownAccumulator >= this.CROWN_THRESHOLD) {
      this.crownAccumulator = 0;
      const now = Date.now();
      if (now - this.lastFlapTime < FLAP_COOLDOWN_MS) {
        return;
      }
      this.lastFlapTime = now;
      this.handleTap();
    }
  }

  private startAccelerometer(): void {
    if (!this.accelEnabled) {
      return;
    }
    try {
      sensor.on(sensor.SensorId.ACCELEROMETER, (data) => {
        if (data.y > FLAP_THRESHOLD) {
          const now = Date.now();
          if (now - this.lastFlapTime < FLAP_COOLDOWN_MS) {
            return;
          }
          this.lastFlapTime = now;
          this.handleTap();
        }
      }, { interval: 50000000 });
    } catch (err) {
      console.warn('[Accelerometer] Sensor unavailable, tap-only mode active.');
    }
  }

  private stopAccelerometer(): void {
    try {
      sensor.off(sensor.SensorId.ACCELEROMETER);
    } catch (_) {
    }
  }

  private triggerHaptic(): void {
    try {
      vibrator.startVibration(
        { type: 'time', duration: 30 },
        { id: 0, usage: 'touch' }
      );
    } catch (_) {
    }
  }

  private checkCollisions(): void {
    if (this.game.birdY > 400 || this.game.birdY <= 0) {
      this.triggerGameOver();
      return;
    }

    for (const pipe of this.game.pipes) {
      const birdRight = 72 + 30;
      const birdLeft = 72;
      const pipeRight = pipe.x + 52;
      const pipeLeft = pipe.x;

      if (birdRight > pipeLeft && birdLeft < pipeRight) {
        const birdBottom = this.game.birdY + 30;
        const birdTop = this.game.birdY;
        const pipeTopBottom = pipe.topY + 120;
        const pipeBottomTop = pipe.bottomY + 30;
        if (birdTop < pipeTopBottom || birdBottom > pipeBottomTop) {
          this.triggerGameOver();
          return;
        }
      }
    }
  }

  private async triggerGameOver(): Promise<void> {
    if (this.game.state === GameState.GAME_OVER) {
      return;
    }
    this.game.state = GameState.GAME_OVER;
    this.gameState = GameState.GAME_OVER;
    this.stopGameLoop();
    this.stopAccelerometer();

    await AudioService.play('hit.mp3');
    await AudioService.play('die.mp3');

    const finalScore = this.game.score;
    const isNewRecord = await ScoreService.saveIfHighScore(finalScore);
    const highScore = await ScoreService.getHighScore();

    if (this.onGameOver) {
      this.onGameOver({ score: finalScore, highScore, isNewRecord });
    }
  }
}