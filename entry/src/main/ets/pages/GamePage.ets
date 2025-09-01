import GameService from '../services/GameService';
import AudioService from '../services/AudioService';
import { GameState, Pipe } from '../common/Types';
import Bird from '../components/Bird';
import PipeView from '../components/Pipe';
import router from '@ohos.router';

@Entry
@Component
struct GamePage {
  private game: GameService = new GameService();
  private gameInterval?: number;
  @State state: GameState = GameState.READY;
  @State flapIndex: number = 0;
  @State score: number = 0;
  @State afkPipe: Pipe[] = []

  aboutToAppear(): void {
    this.startGameLoop();
  }

  aboutToDisappear(): void {
    this.stopGameLoop();
  }

  private pipeTimer: number = 0;
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
      }
      this.state = this.game.state;
    }, 30);
  }

  private stopGameLoop(): void {
    if (this.gameInterval) {
      clearInterval(this.gameInterval);
      this.gameInterval = undefined;
    }
  }

  private async handleTap() {
    this.afkPipe = this.game.pipes
    if (this.game.state === GameState.READY) {
      this.game.state = GameState.PLAYING;
      await AudioService.play('swoosh.mp3');
    } else if (this.game.state === GameState.PLAYING) {
      this.game.flap();
      await AudioService.play('wing.mp3');
    }
  }

  private async gameOver() {
    this.game.state = GameState.GAME_OVER;
    await AudioService.play('hit.mp3');
    await AudioService.play('die.mp3');
    this.stopGameLoop();
    router.pushUrl({ url: 'pages/GameOverPage' });
  }

  private checkCollisions(): void {
    if (this.game.birdY > 400 || this.game.birdY <= 0) {
      this.gameOver();
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
        const pipeBottomTop = pipe.bottomY + 30
        if (birdTop < pipeTopBottom || birdBottom > pipeBottomTop) {
          this.gameOver();
          return;
        }
      }
    }
  }

  build() {
    Column() {
      Stack() {
        Image($r("app.media.background_day1"))
          .width('100%')
          .height('100%')
        ForEach(
          this.afkPipe,
          (pipe: Pipe) => {
            PipeView({ pipe })
          },
          (pipe: Pipe, index: number) => `${pipe.x}_${index}`
        )
        Bird({ birdY: this.game.birdY, flapIndex: this.flapIndex })
        Text(this.score.toString())
          .fontSize(30)
          .fontColor(Color.White)
          .position({ x: '46%', y: '5%' })
      }
      .width('100%')
      .height('100%')
      .gesture(
        TapGesture()
          .onAction(() => this.handleTap())
      )
    }
  }
}
