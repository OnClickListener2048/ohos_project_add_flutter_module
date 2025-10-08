import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { FlutterBoostDelegate,FlutterBoostRouteOptions,FlutterBoostSetupOptionsBuilder,FlutterBoost } from 'flutter_boost';
import { GeneratedPluginRegistrant } from '@ohos/flutter_module';
import { FlutterManager } from '@ohos/flutter_ohos';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility implements FlutterBoostDelegate{
  pushNativeRoute(options: FlutterBoostRouteOptions,
    onPageResult?: ((pageName: string, result: Record<string, Object>) => void) | undefined): void {
    throw new Error('Method not implemented.');
  }

  pushFlutterRoute(options: FlutterBoostRouteOptions,
    onPageResult?: ((pageName: string, result: Record<string, Object>) => void) | undefined): void {
    throw new Error('Method not implemented.');
  }

  popRoute(options: FlutterBoostRouteOptions): boolean {
    throw new Error('Method not implemented.');
  }
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    FlutterManager.getInstance().pushUIAbility(this);
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
    FlutterManager.getInstance().popUIAbility(this);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    FlutterManager.getInstance().pushWindowStage(this, windowStage)
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    // 初始化启动参数（建议带上GeneratedPluginRegistrant.getPlugins()）
    const optionsBuilder: FlutterBoostSetupOptionsBuilder = new FlutterBoostSetupOptionsBuilder();
    FlutterBoost.getInstance().setup(this, this.context, (engine) => {
      GeneratedPluginRegistrant.registerWith(engine);
      //引擎初始化成功
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
          return;
        }
        hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      });
    }, optionsBuilder.build())


  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
    FlutterManager.getInstance().popWindowStage(this);
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}