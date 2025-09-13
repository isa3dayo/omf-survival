import { world, ItemStack, BlockPermutation, Block, Dimension, Player, Vector3, GameMode } from "@minecraft/server"
import { maxXpCost, maxXpCostDimension } from "../../variables"
import { removeWaystone } from "../../functions/destroy"
import { MessageFormData } from "@minecraft/server-ui"
import { WaystoneInfo } from "./info"
import { apiWarn } from "../warn"

export const apiWaystoneSpace = new class apiWaystoneSpace {
  setBlock(dimension: Dimension, type: string, pos: Vector3, permutation: Record<string, string | number | boolean>){
    dimension.setBlockPermutation(pos, BlockPermutation.resolve(type, permutation))
  }

  setOff(player: Player, block: Block){
    const above = block.above(1)
    if(!above) return
    this.setBlock(player.dimension, block.typeId, block.location, {"ws:waystone": 1})
    this.setBlock(player.dimension, block.typeId, above.location, {"ws:waystone": 2})
  }

  setOn(player: Player, block: Block){
    const above = block.above(1)
    if(!above) return
    this.setBlock(player.dimension, block.typeId, block.location, {"ws:waystone": 1, "ws:waystone_on": true})
    this.setBlock(player.dimension, block.typeId, above.location, {"ws:waystone": 2, "ws:waystone_on": true})
  }

  paintWaystone(player: Player, waystone: Block, dyes: string[]): void {
    const item = player.getComponent("equippable")?.getEquipment("Mainhand")
    if(!item) return

    const indexColor = dyes.findIndex(value => value == item.typeId)
    if(indexColor == -1 || waystone.permutation.getState("ws:waystone_color") == indexColor) return

    waystone.setPermutation(waystone.permutation.withState("ws:waystone_color", indexColor))
    apiWarn.notify(player, "", {sound: "simple_waystone.block.waystone.paint"})

    if(player.getGameMode() == GameMode.creative) return
    if(item.amount -1 < 1){ player.getComponent("equippable")?.setEquipment("Mainhand", undefined); return }
    item.amount -= 1
    player.getComponent("equippable")?.setEquipment("Mainhand", item)
  }

  waystoneToWarpstone(player: Player, waystone: Block): void {
    new MessageFormData()
    .title({translate: "ui.simple_waystone:waystone.list.title", with: [""]})
    .body("ui.simple_waystone:waystone.transform.body")
    .button1("ui.simple_waystone:waystone.yes")
    .button2("ui.simple_waystone:waystone.no")
    .show(player).then(({canceled, selection}) => {
      if(canceled || selection == 1 || !waystone.isValid()) return
      apiWarn.notify(player, "", {sound: "simple_waystone.block.waystone.unregistered"})
      waystone.dimension.spawnItem(new ItemStack("ws:warpstone"), waystone.center())

      removeWaystone(waystone.location, waystone.dimension.id.replace("minecraft:", ""))
      waystone.setType("minecraft:air")
      waystone.above(1)?.setType("minecraft:air")
    })
  }

  calculateCost(player: Player, waystone: WaystoneInfo){
    if(player.dimension.id.replace("minecraft:", "") != waystone.world) return maxXpCostDimension()
    if(maxXpCost() == 0) return 0
    const playerPos = player.location
    const waystonePos = waystone.pos
    const distance = Math.floor(Math.sqrt((waystonePos.x - playerPos.x) ** 2  + (waystonePos.z - playerPos.z) ** 2)) / 1500
    return distance < maxXpCost() ? Math.floor(distance) : maxXpCost()
  }

  setCenterVector(vector: Vector3): Vector3 {
    vector["x"] += 0.5
    vector["z"] += 0.5
    return vector
  }

  getRelativeVector(vector: Vector3, vertical = 1): Vector3 {
    vector["y"] += vertical
    return vector
  }
}