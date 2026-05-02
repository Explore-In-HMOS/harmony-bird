export enum GameState {
  READY = 'READY',
  PLAYING = 'PLAYING',
  GAME_OVER = 'GAME_OVER'
}

export interface Pipe {
  x: number;
  topY: number;
  bottomY: number;
  passed?: boolean;
}

export interface GameOverParams {
  score: number;
  highScore: number;
  isNewRecord: boolean;
}

export interface HomeToGameParams {
  accelEnabled: boolean;
}