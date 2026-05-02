import { GameState, Pipe } from '../common/Types';

export default class GameService {
  public birdY: number = 120;
  public velocity: number = 0;
  public gravity: number = 0.6;
  public lift: number = -8;
  public pipes: Pipe[] = [];
  public score: number = 0;
  public state: GameState = GameState.READY;
  private pipeIdCounter: number = 0;

  reset(): void {
    this.birdY = 120;
    this.velocity = 0;
    this.pipes = [];
    this.score = 0;
    this.state = GameState.READY;
    this.pipeIdCounter = 0;
  }

  flap(): void {
    this.velocity = this.lift;
  }

  update(): void {
    if (this.state !== GameState.PLAYING) {
      return;
    }

    this.velocity += this.gravity;
    this.birdY += this.velocity;

    const updatedPipes: Pipe[] = [];

    for (let pipe of this.pipes) {
      const newX = pipe.x - 1;

      if (newX > -60) {
        updatedPipes.push({
          x: newX,
          topY: pipe.topY,
          bottomY: pipe.bottomY,
          passed: pipe.passed
        });
      }
    }

    for (let i = 0; i < updatedPipes.length; i++) {
      const pipe = updatedPipes[i];

      if (!pipe.passed && pipe.x + 52 < 72) {
        updatedPipes[i] = {
          x: pipe.x,
          topY: pipe.topY,
          bottomY: pipe.bottomY,
          passed: true
        };
        this.score++;
      }
    }

    this.pipes = updatedPipes;
  }

  addPipe(): void {
    const lastPipe = this.pipes[this.pipes.length - 1];
    if (!lastPipe || lastPipe.x < 100) {
      const now = new Date();
      const topY = now.getMilliseconds() % 50 - 100;
      const bottomY = now.getMilliseconds() % 20 + 140;
      this.pipes.push({
        x: 210,
        topY,
        bottomY,
        passed: false
      });
    }
  }
}
