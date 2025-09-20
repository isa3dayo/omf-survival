import { world, Player } from "@minecraft/server"

export const apiConfig = new class apiConfig {
  public defaultConfig = {
    organize: false,
    organizeDimension: 0,
    showDimension: 0,
    organizePublic: 0,
    showPublic: true
  }

  getConfig(player: Player | undefined): Config {
    if(!player) return this.defaultConfig

    const dynamic = player.getDynamicProperty(`config`)
    if(!dynamic || typeof dynamic != "string") return this.defaultConfig

    const config = JSON.parse(dynamic)
    if(!this.isConfig(config)){
      player.setDynamicProperty(`config`, JSON.stringify(this.defaultConfig))
      return this.defaultConfig
    }

    return config
  }

  setConfig(player: Player, config: Config): void {
    player.setDynamicProperty(`config`, JSON.stringify(config))
  }

  private isConfig(obj: any): obj is Config {
    return obj &&
    typeof obj === "object" &&
    typeof obj.organize === "boolean" &&
    typeof obj.organizeDimension === "number" &&
    typeof obj.showDimension === "number" &&
    typeof obj.organizePublic === "number" &&
    typeof obj.showPublic === "boolean"
  }
}

interface Config {
  organize: boolean,
  organizeDimension: number,
  showDimension: number,
  organizePublic: number,
  showPublic: boolean
}