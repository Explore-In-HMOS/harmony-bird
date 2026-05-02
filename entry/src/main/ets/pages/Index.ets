@Entry
@Component
struct Index {
  pageStack: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.pageStack) {
    }
    .onAppear(() => {
      this.pageStack.pushPathByName('HomePage', null, false);
    })
    .hideNavBar(true)
  }
}
