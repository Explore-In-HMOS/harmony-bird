import { media } from '@kit.MediaKit';
import { audio } from '@kit.AudioKit';
import { common } from '@kit.AbilityKit';
import GlobalContext from '../common/GlobalContext';
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

    avPlayerInstance.on('audioInterrupt', (interruptEvent: audio.InterruptEvent) => {
      if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_FORCE) {
        switch (interruptEvent.hintType) {
          case audio.InterruptHint.INTERRUPT_HINT_PAUSE:
          case audio.InterruptHint.INTERRUPT_HINT_STOP:
            break;
          default:
            break;
        }
      }
    });

    avPlayerInstance.on('audioOutputDeviceChangeWithInfo', () => {
      hilog.info(0x1234, '[Audio]', 'Audio output device changed');
    });

    avPlayerInstance.on('error', (err) => {
      hilog.error(0x1234, '[Audio]', `[AVPlayer] Error: ${JSON.stringify(err)}`);
    });

    avPlayerInstance.on('stateChange', async (state: string) => {
      hilog.info(0x1311, '[Audio]', 'here on');
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
