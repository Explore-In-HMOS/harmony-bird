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
