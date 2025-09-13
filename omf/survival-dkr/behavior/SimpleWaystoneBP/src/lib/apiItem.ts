import { world, system, Player } from "@minecraft/server"
import { apiWarn } from "./warn"

export const apiItem = new class apiItem {
  [key: string]: (player: Player) => boolean

  "ws:warpstone"(player: Player): false {
    player.setDynamicProperty("warpstoneCooldown", Math.floor(new Date().getTime() / 1000) +59)
    apiWarn.notify(player, "", {sound: "simple_waystone.block.waystone.teleport", delaySound: 1})
    return false
  }

  "ws:golden_feather"(player: Player): boolean {
    if(player.getGameMode() == "creative") return false
    const item = player.getComponent("equippable")?.getEquipment("Mainhand")
    if(!item || item.typeId != "ws:golden_feather") return true
    apiWarn.notify(player, "", {sound: "simple_waystone.item.golden_feather.used", delaySound: 1})
    if(item.amount -1 < 1){
      player.getComponent("equippable")?.setEquipment("Mainhand", undefined)
      return false
    }

    item.amount -= 1
    player.getComponent("equippable")?.setEquipment("Mainhand", item)
    return false
  }

  "ws:return_scroll"(player: Player): boolean {
    if(player.getGameMode() == "creative") return false
    const item = player.getComponent("equippable")?.getEquipment("Mainhand")
    if(!item || item.typeId != "ws:return_scroll") return true
    const comp = item.getComponent("durability")
    if(!comp) return true
    apiWarn.notify(player, "", {sound: "simple_waystone.item.return_scroll.used", delaySound: 1})
    if(comp.damage +1 > comp.maxDurability){
      player.getComponent("equippable")?.setEquipment("Mainhand", undefined)
      return false
    }
    comp.damage += 1
    player.getComponent("equippable")?.setEquipment("Mainhand", item)
    return false
  }
}