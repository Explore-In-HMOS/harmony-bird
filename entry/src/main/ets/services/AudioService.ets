import { media } from '@kit.MediaKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import GlobalContext from '../common/GlobalContex';
import { hilog } from '@kit.PerformanceAnalysisKit';

interface FileDescriptor {
  fd: number;
  offset: number;
  length: number;
}

export default class AudioService {
  private static avPlayer: media.AVPlayer | null = null;

  static async initialize(resource: string): Promise<void> {
    if (AudioService.avPlayer) {
      await AudioService.avPlayer.release();
    }

    const context = GlobalContext.getInstance().getCustomContext() as common.UIAbilityContext;
    const fdInfo = await context.resourceManager.getRawFd(resource);
    const fileDescriptor: FileDescriptor = {
      fd: fdInfo.fd,
      offset: fdInfo.offset,
      length: fdInfo.length
    };

    const avPlayerInstance = await media.createAVPlayer();
    avPlayerInstance.fdSrc = fileDescriptor;

    avPlayerInstance.on('error', (err) => {
      hilog.error(0x1234,'[Audio]',`[AVPlayer] Error: ${JSON.stringify(err)}`);
    });

    avPlayerInstance.on('stateChange', async (state: string) => {
      hilog.info(0x1311,'[Audio]','here on')
      if (state === 'initialized') {
        await avPlayerInstance.prepare();
      } else if (state === 'prepared') {
        await avPlayerInstance.play();
      }
    });

    AudioService.avPlayer = avPlayerInstance;
  }

  static async play(resource: string): Promise<void> {
    await AudioService.initialize(resource);
  }
}