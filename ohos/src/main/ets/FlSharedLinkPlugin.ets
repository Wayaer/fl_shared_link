import {
  AbilityAware,
  AbilityPluginBinding,
  FlutterPlugin,
  FlutterPluginBinding,
  Log,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
  NewWantListener,
} from '@ohos/flutter_ohos';
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import { systemShare } from '@kit.ShareKit';
import json from '@ohos.util.json';
import { deviceInfo } from '@kit.BasicServicesKit';

const TAG = "FlSharedLinkPlugin"

/** FlSharedLinkPlugin **/
export default class FlSharedLinkPlugin implements FlutterPlugin, MethodCallHandler, AbilityAware, NewWantListener {
  private channel: MethodChannel | null = null;
  private abilityPluginBinding: AbilityPluginBinding | null = null;
  private lastLaunchParams: AbilityConstant.LaunchParam | null = null;
  private lastWant: Want | null = null

  getUniqueClassName(): string {
    return TAG
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "fl.shared.link");
    this.channel.setMethodCallHandler(this)
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.abilityPluginBinding = binding
    binding.addOnNewWantListener(this)
    this.handleWant(binding.getAbility().launchWant)
  }

  onDetachedFromAbility(): void {
    this.abilityPluginBinding?.removeOnNewWantListener(this)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null)
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case 'getWant':
        if (this.lastWant == null) {
          result.success(null);
          return
        }

        result.success(this.wantToMap(this.lastWant!))
        break;
      case 'getWantSharedData':
        this.getWantSharedData().then((value) => {
          result.success(value)
        })
        break;
      case 'clearCache':
        this.lastWant = null
        this.lastLaunchParams = null
        result.success(true)
        break;
      default:
        result.notImplemented()
    }
  }

  async getWantSharedData(): Promise<Array<Record<string, object | undefined>> | null> {
    if (this.lastWant == null) {
      return null;
    }
    try {
      const result = await systemShare.getSharedData(this.lastWant)
      const records = Array<Record<string, Object | undefined>>();
      result.getRecords().forEach((e) => {
        records.push(this.sharedRecordToMap(e))
      })
      return records;
    } catch (e) {
      Log.d(TAG, 'getWantSharedData error: ' + json.stringify(e))
    }
    return null
  }

  onNewWant(want: Want, launchParams: AbilityConstant.LaunchParam): void {
    this.lastLaunchParams = launchParams
    this.handleWant(want)
  }

  handleWant(want: Want) {
    this.lastWant = want
    this.channel?.invokeMethod('onWant', {
      'want': this.wantToMap(want),
      'launchParams': this.launchParamsToMap()
    });
  }

  sharedRecordToMap(record: systemShare.SharedRecord): Record<string, Object | undefined> {
    return {
      'utd': record.utd,
      'content': record.content,
      'uri': record.uri,
      'title': record.title,
      'label': record.label,
      'description': record.description,
      'thumbnail': record.thumbnail,
      'thumbnailUri': record.thumbnailUri,
      'extraData': record.extraData,
    }
  }

  launchParamsToMap(): Record<string, Object | undefined> | null {
    if (this.lastLaunchParams == null) {
      return null
    }
    let launchReasonMessage: string | undefined = undefined
    let lastExitDetailInfo: Record<string, Object | undefined> | undefined = undefined
    if (deviceInfo.sdkApiVersion >= 18) {
      launchReasonMessage = this.lastLaunchParams.launchReasonMessage
      if (this.lastLaunchParams?.lastExitDetailInfo) {
        lastExitDetailInfo = {
          'pid': this.lastLaunchParams.lastExitDetailInfo?.pid,
          'processName': this.lastLaunchParams.lastExitDetailInfo?.processName,
          'uid': this.lastLaunchParams.lastExitDetailInfo?.uid,
          'exitSubReason': this.lastLaunchParams.lastExitDetailInfo?.exitSubReason,
          'exitMsg': this.lastLaunchParams.lastExitDetailInfo?.exitMsg,
          'rss': this.lastLaunchParams.lastExitDetailInfo?.rss,
          'pss': this.lastLaunchParams.lastExitDetailInfo?.pss,
          'timestamp': this.lastLaunchParams.lastExitDetailInfo?.timestamp,
        }
      }
    }

    return {
      'launchReason': this.lastLaunchParams.launchReason,
      'launchReasonMessage': launchReasonMessage,
      'lastExitReason': this.lastLaunchParams.lastExitReason,
      'lastExitMessage': this.lastLaunchParams.lastExitMessage,
      'lastExitDetailInfo': lastExitDetailInfo,
    }
  }

  wantToMap(want: Want): Record<string, Object | undefined> {
    return {
      'bundleName': want.bundleName,
      'abilityName': want.abilityName,
      'deviceId': want.deviceId,
      'uri': want.uri,
      'type': want.type,
      'flags': want.flags,
      'action': want.action,
      // 'parameters': json.stringify(want.parameters),
      'entities': want.entities,
      'moduleName': want.moduleName,
    }
  }
}