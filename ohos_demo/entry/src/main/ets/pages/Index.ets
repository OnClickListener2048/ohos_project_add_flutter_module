import { FlutterPage } from '@ohos/flutter_ohos';
import { FlutterBoostEntry,FlutterBoost } from 'flutter_boost';
import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  private flutterEntries: Array<FlutterBoostEntry> = [];

  build() {
    Column() {
      Tabs({
        index: this.currentIndex,
        barPosition: BarPosition.End
      }) {
        ForEach([new TabItem(0,"111"),new TabItem(1,"2222"),new TabItem(2,"3333")], (item: TabItem) => {
          TabContent() {
            Column() {
              this.Content()
            }
          }
          .tabBar(this.CardTab(item))
        }, (item: TabItem, index?: number) => index + JSON.stringify(item))
      }
      .vertical(false)
      .barWidth("100%")
      .barHeight("56vp")
      .layoutWeight(1)
      .barMode(BarMode.Fixed)
      .align(Alignment.Center)
      .onChange((index: number) => {
        this.currentIndex = index;

        if (this.currentIndex == 1) {
          this.flutterEntries[0]?.aboutToAppear();
          this.flutterEntries[0]?.onPageShow();
          this.flutterEntries[1]?.onPageHide();
        } else if (this.currentIndex == 2) {
          this.flutterEntries[1]?.aboutToAppear();
          this.flutterEntries[1]?.onPageShow();
          this.flutterEntries[0]?.onPageHide();
        }
      })
    }
    .backgroundColor("#F1F3F5")
  }

  // 组件生命周期
  aboutToAppear() {
    console.info('MyComponent aboutToAppear');

    const firstFlutterEntry = new FlutterBoostEntry(getContext(this), {
      uri: 'mainPage'
    });

    const secondFlutterEntry = new FlutterBoostEntry(getContext(this), {
      uri: 'simplePage'
    });

    this.flutterEntries.push(firstFlutterEntry);
    this.flutterEntries.push(secondFlutterEntry);
  }

  // 组件生命周期
  aboutToDisappear() {
    console.info('MyComponent aboutToDisappear');
  }

  // 只有被@Entry装饰的组件才可以调用页面的生命周期
  onPageShow() {
    console.info('Index onPageShow');
  }

  // 只有被@Entry装饰的组件才可以调用页面的生命周期
  onPageHide() {
    console.info('Index onPageHide');
  }

  @Builder
  CardTab(item: TabItem) {
    Column() {
      Image($r('app.media.startIcon'))
        .width("21vp")
        .height("21vp")
        .objectFit(ImageFit.Contain)
        .margin({
          top: "4vp",
          bottom: "5.5vp"
        })
      Text(item.title)
        .fontSize("10fp")
        .fontColor(this.currentIndex === item.index ?
          "#007DFF" : "#66000000")
    }
    .justifyContent(FlexAlign.Center)
    .width("100%")
    .height("100%")
  }

  @Builder
  Content() {
    if (this.currentIndex === 0) {
      Column() {
        Button('打开FlutterEntry')
          .onClick(() => {
            router.pushUrl({ url: 'simplePage', params: {
              uri: 'simplePage',
              params: {}
            } }).then(() => {
              console.info('Succeeded in jumping to the second page.')
            })
          })
      }
    } else if (this.currentIndex === 1) {
      FlutterPage({ viewId: this.flutterEntries[0]?.getFlutterView()?.getId() })
    } else if (this.currentIndex === 2) {
      FlutterPage({ viewId: this.flutterEntries[1]?.getFlutterView()?.getId() })
    } else {
      Text("内容" + this.currentIndex)
        .fontSize("20fp")
        .fontColor(Color.Black)
        .fontWeight(500)
    }
  }

  // 拦截返回键
  onBackPress(): boolean | void {
    FlutterBoost.getInstance().getPlugin()?.onBackPressed();
    return true;
  }
}

class TabItem{
  constructor(index: number | undefined, title: string | undefined) {
    this.index = index;
    this.title = title;
  }

  index:number|undefined;
  title:string|undefined
}