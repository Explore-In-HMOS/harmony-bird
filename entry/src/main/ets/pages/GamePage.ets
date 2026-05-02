import { GameViewModel } from '../viewmodels/GameViewModel';
import { Pipe, GameOverParams, HomeToGameParams } from '../common/Types';
import Bird from '../components/Bird';
import PipeView from '../components/Pipe';
import { window } from '@kit.ArkUI';
import GlobalContext from '../common/GlobalContext';
import { PAGES } from '../common/Pages';

@Builder
export function GamePageBuilder() {
  GamePage()
}

@Entry
@Component
struct GamePage {
  private vm: GameViewModel = new GameViewModel();
  private pipeUpdateInterval?: number;
  @State afkPipe: Pipe[] = []
  @State flapIndex: number = 0;
  @State score: number = 0;
  @State birdY: number = 120;
  pageInfos: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    window.getLastWindow(
      GlobalContext.getInstance().getCustomContext())
      .then((win) => {
        win.setWindowKeepScreenOn(true);
      });

    this.vm.onStateChanged = () => {
      this.flapIndex = this.vm.flapIndex;
      this.score = this.vm.score;
      this.birdY = this.vm.birdY;
    };

    this.vm.onGameOver = (params: GameOverParams) => {
      this.pageInfos.pushPathByName(PAGES.GAMEOVERPAGE, params, false);
    };

    this.pipeUpdateInterval = setInterval(() => {
      this.afkPipe = this.vm.pipes;
    }, 300);
  }

  aboutToDisappear(): void {
    window.getLastWindow(
      GlobalContext.getInstance().getCustomContext())
      .then((win) => {
        win.setWindowKeepScreenOn(false);
      });

    this.vm.destroy();
    if (this.pipeUpdateInterval) {
      clearInterval(this.pipeUpdateInterval);
      this.pipeUpdateInterval = undefined;
    }
  }

  private handleTap(): void {
    this.vm.handleTap();
  }

  build() {
    NavDestination() {
      Stack() {
        Image($r('app.media.background_day1'))
          .width('100%')
          .height('100%')

        ForEach(
          this.afkPipe,
          (pipe: Pipe) => {
            PipeView({ pipe })
          },
          (pipe: Pipe) => `${pipe.x}`
        )

        Bird({ birdY: this.birdY, flapIndex: this.flapIndex })

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
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .focusable(true)
    .defaultFocus(true)
    .onDigitalCrown((event: CrownEvent) => {
      event.stopPropagation();
      this.vm.handleCrown(event.angularVelocity);
    })
    .onBackPressed(() => true)
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
      const params = context.pathInfo.param as HomeToGameParams;
      const accelEnabled = params ? params.accelEnabled : true;
      this.vm.start(accelEnabled);
    })
  }
}
