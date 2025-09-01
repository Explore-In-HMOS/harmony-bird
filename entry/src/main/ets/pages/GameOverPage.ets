import { router } from '@kit.ArkUI';

@Entry
@Component
export default struct GameOverPage {
  build() {
    Column() {
      Text('Game Over')
        .fontSize(26)
        .margin({ bottom: 16 })
        .fontColor(Color.Red)
      Button('Retry')
        .onClick(() => {
          router.replaceUrl({ url: 'pages/GamePage' })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
