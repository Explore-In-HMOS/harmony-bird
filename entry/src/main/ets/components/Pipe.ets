import { Pipe } from '../common/Types';

@Component
export default struct PipeView {
  @Prop pipe: Pipe;

  build() {
    Stack() {
      Image($r('app.media.pipe_green'))
        .width('10%')
        .height('60%')
        .position({ x: this.pipe.x, y: this.pipe.topY })
        .rotate({ angle: 180 })
      Image($r('app.media.pipe_red'))
        .width('10%')
        .height('60%')
        .position({ x: this.pipe.x, y: this.pipe.bottomY })
    }
    .width('100%')
    .height('100%')
  }
}