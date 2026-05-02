@Component
export default struct Bird {
  @Prop birdY: number;
  @Prop flapIndex: number;
  private readonly frames: Resource[] = [
    $r('app.media.bluebird_upflap'),
    $r('app.media.bluebird_midflap'),
    $r('app.media.bluebird_downflap')
  ];

  build() {
    Image(this.frames[this.flapIndex % this.frames.length])
      .width(24)
      .height(24)
      .position({ x: 72, y: this.birdY });
  }
}
