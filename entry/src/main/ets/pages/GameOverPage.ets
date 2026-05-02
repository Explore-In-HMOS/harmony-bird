import GlobalContext from '../common/GlobalContext';
import { GameOverParams } from '../common/Types';
import { common } from '@kit.AbilityKit';
import { PAGES } from '../common/Pages';

@Builder
export function GameOverPageBuilder() {
  GameOverPage()
}

@Entry
@Component
export struct GameOverPage {
  pageInfos: NavPathStack = new NavPathStack();
  @State private score: number = 0;
  @State private highScore: number = 0;
  @State private isNewRecord: boolean = false;
  @State private contentOpacity: number = 0;
  @State private contentScale: number = 0.85;
  private glowOpacity: number = 0.3;
  private context: common.UIAbilityContext | null = null;

  get scoreDiffText(): string {
    if (!this.context) {
      return '';
    }
    if (this.isNewRecord) {
      return this.context.resourceManager.getStringSync($r('app.string.game_over_new_record').id);
    }
    const gap = this.highScore - this.score;
    if (gap <= 0) {
      return this.context.resourceManager.getStringSync($r('app.string.game_over_so_close').id);
    }
    const text: string =
      this.context.resourceManager.getStringSync($r('app.string.game_over_so_close').id);
    return `-${gap} ${text}`;
  }

  get scoreDiffColor(): Resource {
    return this.isNewRecord
      ? $r('app.color.game_over_green')
      : $r('app.color.game_over_grey');
  }

  get performanceLabel(): string {
    if (this.isNewRecord) {
      return '🏆';
    }
    const ratio = this.highScore > 0 ? this.score / this.highScore : 0;
    if (ratio >= 0.9) {
      return '⭐';
    }
    if (ratio >= 0.6) {
      return '👍';
    }
    return '💀';
  }

  private playEntranceAnimations(): void {
    const ui = this.getUIContext();
    ui.animateTo({ duration: 400, curve: Curve.EaseOut }, () => {
      this.contentOpacity = 1;
      this.contentScale = 1;
    });
  }

  aboutToAppear(): void {
    const ctx = GlobalContext.getInstance().getCustomContext();
    if (ctx) {
      this.context = ctx as common.UIAbilityContext;
    }
    setTimeout(() => this.playEntranceAnimations(), 80);
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

        if (this.isNewRecord) {
          Column()
            .width(200)
            .height(200)
            .borderRadius(100)
            .backgroundColor('transparent')
            .shadow({
              radius: 80,
              color: $r('app.color.game_over_gold_bg'),
              offsetX: 0,
              offsetY: 0
            })
            .opacity(this.glowOpacity)
        }

        Column({ space: 3 }) {

          Text($r('app.string.game_over_title'))
            .fontSize(11)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.game_over_white'))
            .letterSpacing(3)

          Text(`${this.score}`)
            .fontSize(40)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.game_over_white'))
            .lineHeight(58)

          Text(this.scoreDiffText)
            .fontSize(12)
            .fontColor(this.scoreDiffColor)
            .fontWeight(FontWeight.Medium)

          Row({ space: 5 }) {
            Text($r('app.string.game_over_best'))
              .fontSize(11)
              .fontColor($r('app.color.game_over_white'))
            Text(`${this.highScore}`)
              .fontSize(13)
              .fontWeight(FontWeight.Bold)
              .fontColor(
                this.isNewRecord
                  ? $r('app.color.game_over_gold')
                  : $r('app.color.game_over_white')
              )
              .padding({
                left: 8,
                right: 8,
                top: 2,
                bottom: 2
              })
              .backgroundColor(
                this.isNewRecord
                  ? $r('app.color.game_over_gold_bg')
                  : $r('app.color.game_over_grey_dark')
              )
              .borderRadius(6)
              .border(
                this.isNewRecord
                  ? { width: 1, color: $r('app.color.game_over_gold_border') }
                  : { width: 0, color: Color.Transparent }
              )
          }
          .margin({ top: 2, bottom: 6 })

          Button($r('app.string.game_over_retry'))
            .width(100)
            .height(28)
            .fontSize(11)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.game_over_white'))
            .backgroundColor($r('app.color.game_over_primary'))
            .borderRadius(18)
            .shadow({
              radius: 10,
              color: $r('app.color.game_over_bg'),
              offsetX: 0,
              offsetY: 3
            })
            .onClick(() => {
              this.pageInfos.pushPathByName(PAGES.GAMEPAGE, null, false);
            })

          Button($r('app.string.game_over_home'))
            .width(100)
            .height(28)
            .fontSize(11)
            .fontColor($r('app.color.game_over_white'))
            .backgroundColor($r('app.color.home_overlay_bg'))
            .border({ width: 1, color: $r('app.color.game_over_grey') })
            .borderRadius(14)
            .onClick(() => {
              this.pageInfos.clear();
              this.pageInfos.pushPathByName(PAGES.HOMEPAGE, null, false);
            })
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .opacity(this.contentOpacity)
        .scale({ x: this.contentScale, y: this.contentScale })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
      const params = context.pathInfo.param as GameOverParams;
      if (params) {
        this.score = params.score;
        this.highScore = params.highScore;
        this.isNewRecord = params.isNewRecord;
      }
    })
    .onBackPressed(() => {
      this.pageInfos.clear();
      return true;
    })
  }
}
