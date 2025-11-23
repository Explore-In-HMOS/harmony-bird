import { GameState, Pipe } from '../common/Types';

export default class GameService {
  public birdY: number = 120;
  public velocity: number = 0;
  public gravity: number = 0.6;
  public lift: number = -8;
  public pipes: Pipe[] = [];
  public score: number = 0;
  public state: GameState = GameState.READY;

  reset(): void {
    this.birdY = 120;
    this.velocity = 0;
    this.pipes = [];
    this.score = 0;
    this.state = GameState.READY;
  }

  flap(): void {
    this.velocity = this.lift;
  }

  update(): void {
    if (this.state !== GameState.PLAYING) {return;}

    this.velocity += this.gravity;
    this.birdY += this.velocity;

    const updatedPipes: Pipe[] = [];
    for (let pipe of this.pipes) {
      const newX = pipe.x - 1;
      if (newX > -52) {
        updatedPipes.push({
          x: newX,
          topY: pipe.topY,
          bottomY: pipe.bottomY,
          passed: pipe.passed
        });
      }
    }
    this.pipes = updatedPipes;

    for (let i = 0; i < this.pipes.length; i++) {
      const pipe = this.pipes[i];
      if (!pipe.passed && pipe.x + 52 < 72) {
        this.pipes[i].passed = true;
        this.score++;
      }
    }
    this.pipes = this.pipes.filter(pipe => pipe.x > -60);

  }

  addPipe(): void {
    const lastPipe = this.pipes[this.pipes.length - 1];
    if (!lastPipe || lastPipe.x < 140) {
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
