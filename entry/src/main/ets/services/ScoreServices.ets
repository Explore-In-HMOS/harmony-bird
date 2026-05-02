import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import GlobalContext from '../common/GlobalContext';

const STORE_NAME = 'game_prefs';
const KEY_HIGH_SCORE = 'high_score';
const DOMAIN = 0x0000;

export default class ScoreService {
  static async getHighScore(): Promise<number> {
    try {
      const context = GlobalContext.getInstance().getCustomContext() as common.UIAbilityContext;
      const store = preferences.getPreferencesSync(context, { name: STORE_NAME });
      const value = store.getSync(KEY_HIGH_SCORE, 0);
      return value as number;
    } catch (err) {
      hilog.error(DOMAIN, '[ScoreService]', `getHighScore failed: ${JSON.stringify(err)}`);
      return 0;
    }
  }

  static async saveIfHighScore(score: number): Promise<boolean> {
    try {
      const context = GlobalContext.getInstance().getCustomContext() as common.UIAbilityContext;
      const store = preferences.getPreferencesSync(context, { name: STORE_NAME });
      const current = store.getSync(KEY_HIGH_SCORE, 0) as number;

      if (score > current) {
        store.putSync(KEY_HIGH_SCORE, score);
        await store.flush();
        return true;
      }
      return false;
    } catch (err) {
      hilog.error(DOMAIN, '[ScoreService]', `saveIfHighScore failed: ${JSON.stringify(err)}`);
      return false;
    }
  }
}
