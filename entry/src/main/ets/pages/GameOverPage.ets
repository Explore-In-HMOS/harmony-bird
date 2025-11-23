@Builder
export function GameOverPageBuilder (){
  GameOverPage()
}

@Entry
@Component
export default struct GameOverPage {

  pageInfos: NavPathStack = new NavPathStack();

  build() {

    NavDestination(){
      Column() {
        Text('Game Over')
          .fontSize(26)
          .margin({ bottom: 16 })
          .fontColor(Color.Red)
        Button('Retry')
          .onClick(() => {

            this.pageInfos.pushPathByName('GamePage',null,false)
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

  }.width('100%')
  .height('100%')
  .hideTitleBar(true)
  .onReady((context: NavDestinationContext) => {
  this.pageInfos = context.pathStack;
})
  }
}
