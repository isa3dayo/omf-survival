import { world, Player, Vector3 } from "@minecraft/server"
import { WaystoneInfo } from "./apiwaystone/info"
import { organizeDimension } from "../ui/mainUi"
import { apiConfig } from "./apiConfig"

const showDimension = [["overworld", "nether", "the_end"], ["overworld"], ["nether"], ["the_end"]]
const dimensionList: { [key: string]: string } = {"world": "overworld", "nether": "nether", "end": "the_end"}
const currentDimension: { [key: string]: number } = {"minecraft:overworld": 1, "minecraft:nether": 3, "minecraft:the_end": 5}

export const apiOrganize = new class apiOrganize {
  organize(list: WaystoneInfo[], alphabetical = true): WaystoneInfo[] {
    const waystones = list
    if(alphabetical) return waystones.sort((a, z) => { return z.name.localeCompare(a.name)})
    return waystones.sort((a, z) => { return a.name.localeCompare(z.name)})
  }

  organizeDimension(player: Player, list: WaystoneInfo[]): WaystoneInfo[] | undefined {
    const config = apiConfig.getConfig(player)
    const show = showDimension[config.showDimension], organize = config.organizeDimension, dimensionIndex = currentDimension[player.dimension.id]
    if(show == undefined || dimensionIndex == undefined) return

    const dimensionOrder = organizeDimension[organize == 0 ? dimensionIndex : organize]
    if(!dimensionOrder) return

    const publicWay = list.filter(value => value.type == "public").filter(value => show.includes(value.world))
    const privateWay = list.filter(value => value.type == "private").filter(value => show.includes(value.world))
    const order = dimensionOrder.split("-").map(value => (`${dimensionList[value]}`))
    const wayPublic = publicWay.sort((a, b) => order.indexOf(a.world) - order.indexOf(b.world))
    const wayPrivate = privateWay.sort((a, b) => order.indexOf(a.world) - order.indexOf(b.world))
    const sortedFirst = [...wayPublic, ...wayPrivate]
    const sortedLast = [...wayPrivate, ...wayPublic]
    if(config.organizePublic < 2) return config.organizePublic == 0 ? sortedFirst.sort((a, b) => order.indexOf(a.world) - order.indexOf(b.world)) : sortedLast.sort((a, b) => order.indexOf(a.world) - order.indexOf(b.world))
    return config.organizePublic == 2 ? sortedFirst : sortedLast
  }

  sameNames(name: string, waystones: WaystoneInfo[], index?: number){
    const waystonesName = waystones.map(obj => obj.name)
    let newName = name
    if(typeof index == "number") waystonesName.splice(index, 1)
    let counter = 1
    while(waystonesName.includes(newName)){
      newName = `${name} (${counter})`
      counter++
    }
    return newName
  }

  sortPos(pos: Vector3): string { return JSON.stringify({x: pos.x, y: pos.y, z: pos.z}) }
}