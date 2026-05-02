import ScoreService from '../services/ScoreServices';
import { HomeToGameParams } from '../common/Types';
import { PAGES } from '../common/Pages';

@Builder
export function HomePageBuilder() {
  HomePage()
}

@Entry
@Component
export struct HomePage {
  pageInfos: NavPathStack = new NavPathStack();
  @State highScore: number = 0;
  @State accelEnabled: boolean = true;
  @State contentOpacity: number = 0;
  @State contentTranslateY: number = 20;

  aboutToAppear(): void {
    ScoreService.getHighScore().then((score) => {
      this.highScore = score;
    });

    const ui = this.getUIContext();

    ui.animateTo({ duration: 400, curve: Curve.EaseOut }, () => {
      this.contentOpacity = 1;
      this.contentTranslateY = 0;
    });
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Center }) {

        Image($r('app.media.background_day1'))
          .width('100%')
          .height('100%')

        Column()
          .width('100%')
          .height('100%')
          .backgroundColor($r('app.color.home_overlay_bg'))

        Column({ space: 0 }) {

          Text($r('app.string.home_title'))
            .fontSize(20)
            .fontWeight(FontWeight.Bolder)
            .fontColor($r('app.color.game_over_white'))
            .letterSpacing(1)
            .margin({ bottom: 16, top: 10 })

          Row({ space: 6 }) {
            Text('🏆')
              .fontSize(13)
            Text(this.highScore > 0 ? this.highScore.toString() : '-')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.game_over_gold'))
          }
          .padding({
            left: 16,
            right: 16,
            bottom: 3,
            top: 3
          })
          .backgroundColor($r('app.color.home_overlay_bg'))
          .borderRadius(20)
          .margin({ bottom: 14 })
          .border({ width: 1, color: $r('app.color.game_over_grey_dark') })

          Row({ space: 8 }) {
            Text('📳')
              .fontSize(12)
            Text($r('app.string.home_shake_to_play'))
              .fontSize(11)
              .fontColor($r('app.color.game_over_white'))
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.accelEnabled })
              .width(36)
              .height(20)
              .selectedColor($r('app.color.game_over_primary'))
              .onChange((isOn: boolean) => {
                this.accelEnabled = isOn;
              })
          }
          .width(180)
          .padding({
            left: 12,
            right: 12,
            top: 8,
            bottom: 8
          })
          .backgroundColor($r('app.color.home_overlay_bg'))
          .borderRadius(14)
          .border({ width: 1, color: $r('app.color.game_over_grey_dark') })
          .margin({ bottom: 18 })

          Button($r('app.string.home_play'))
            .width(130)
            .height(38)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.game_over_white'))
            .backgroundColor($r('app.color.game_over_primary'))
            .borderRadius(21)
            .shadow({
              radius: 12,
              color: $r('app.color.game_over_bg'),
              offsetX: 0,
              offsetY: 4
            })
            .onClick(() => {
              const params: HomeToGameParams = { accelEnabled: this.accelEnabled };
              this.pageInfos.pushPathByName(PAGES.GAMEPAGE, params, false);
            })
        }
        .width('95%')
        .height('95%')
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .opacity(this.contentOpacity)
        .translate({ y: this.contentTranslateY })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .onBackPressed(() => true)
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
  }
}
