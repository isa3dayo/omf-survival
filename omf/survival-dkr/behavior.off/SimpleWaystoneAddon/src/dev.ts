import { waystonesListId } from "./functions/placeWaystones"
import { world, BlockPermutation } from "@minecraft/server"
import { apiWaystoneInfo } from "./lib/apiwaystone/info"

world.afterEvents.itemUse.subscribe(({source: player, itemStack: item}) => {
  if(!player.hasTag("dev")) return

  if(item.typeId == "minecraft:stick"){
    world.sendMessage(`§l§cIds:§r ${JSON.stringify(world.getDynamicPropertyIds().sort(), null, 2)}`)
    world.sendMessage(`§l§cPublic:§r ${JSON.stringify(apiWaystoneInfo.getPublicWaystones())}`)
    world.sendMessage(`§l§cPrivate:§r ${JSON.stringify(apiWaystoneInfo.getPrivateWaystones(player.id))}`)
    world.sendMessage(`Peso total no mundo: ${world.getDynamicPropertyTotalByteCount()}`)
  }
  if(item.typeId == "minecraft:diamond_sword"){
    world.setDynamicProperty("sw:7.3", undefined)
  }
  if(item.typeId == "minecraft:golden_sword"){
    world.clearDynamicProperties()
    player.clearDynamicProperties()
    world.sendMessage(`reseted all dynamic properties`)
  }
  if(item.typeId == "minecraft:wooden_sword"){
    // waystoneUi.createPoint(player, player.dimension.getBlock(player.location))
  }
})

const score = world.scoreboard.getObjective("waystone_type")

world.afterEvents.entityHitBlock.subscribe(({damagingEntity, hitBlock}) => {
  if(!damagingEntity.hasTag("dev")) return

  if(!hitBlock.getTags().includes("simple_waystone:waystone")) return
  const perm = hitBlock.permutation.getAllStates()
  const type = waystonesListId[score?.getScore(damagingEntity) ?? 0]
  hitBlock?.setPermutation(BlockPermutation.resolve(type ?? "ws:waystone_polished_andesite", perm))
  if(perm["ws:waystone"] == 1){
    hitBlock?.above(1)?.setPermutation(BlockPermutation.resolve(type ?? "ws:waystone_polished_andesite", {"ws:waystone_on": true, "ws:waystone": 2}))
  } else {
    hitBlock.below(1)?.setPermutation(BlockPermutation.resolve(type ?? "ws:waystone_polished_andesite", {"ws:waystone_on": true, "ws:waystone": 1}))
  }

  score?.addScore(damagingEntity, 1)
})