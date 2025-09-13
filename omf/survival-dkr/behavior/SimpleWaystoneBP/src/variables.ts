import { world } from "@minecraft/server"

export function maxXpCost(){
  const score = world.scoreboard.getObjective("simple_waystone_cost_xp")?.getScore("xp")
  return score == undefined ? 3 : (score < 0 ? 0 : score)
}

export function maxXpCostDimension(){
  const score = world.scoreboard.getObjective("simple_waystone_cost_xp")?.getScore("xp_dimension")
  return score == undefined ? 3 : (score < 0 ? 0 : score)
}