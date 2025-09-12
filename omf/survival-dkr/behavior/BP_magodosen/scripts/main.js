import { world } from "@minecraft/server";
const SHIP_Y_OFFSET_TEST = 20;
const SHIP_Y_OFFSET_PROD = 100;
const USE_TEST_HEIGHT = true;
const SHIP_HALF_SIZE = { x: 16, y: 8, z: 16 };
const STRUCTURE_NAME = "magodosen_ship";
const WORLD_FLAG_KEY = "magodosen_ship_placed";
const MARKER_BLOCK = "minecraft:lodestone";
function isWithinBox(loc, center, half){return Math.abs(loc.x-center.x)<=half.x&&Math.abs(loc.y-center.y)<=half.y&&Math.abs(loc.z-center.z)<=half.z;}
function getDayNightState(){const t=world.getTimeOfDay();return (t<12000)?"day":"night";}
function getCenterFromWorldSpawn(){const s=world.getDefaultSpawnLocation();return {x:Math.floor(s.x),y:Math.floor(s.y+(USE_TEST_HEIGHT?SHIP_Y_OFFSET_TEST:SHIP_Y_OFFSET_PROD)),z:Math.floor(s.z)};}
async function isShipAlreadyPlaced(dim, center){
  try{const f=world.getDynamicProperty(WORLD_FLAG_KEY);if(f)return true;}catch(e){}
  try{const markerPos={x:center.x,y:center.y-1,z:center.z};const block=dim.getBlock(markerPos);if(block&&block.typeId===MARKER_BLOCK)return true;}catch(e){}
  return false;
}
async function markShipPlaced(dim, center){
  try{world.setDynamicProperty(WORLD_FLAG_KEY,1);}catch(e){}
  try{await dim.runCommandAsync(`setblock ${center.x} ${center.y - 1} ${center.z} ${MARKER_BLOCK}`);}catch(e){}
}
world.afterEvents.playerSpawn.subscribe(async (ev)=>{
  if(!ev.initialSpawn)return;
  const player=ev.player;const overworld=world.getDimension("overworld");const center=getCenterFromWorldSpawn();
  try{await player.runCommandAsync(`effect "${player.name}" slow_falling 8 1 true`);}catch(e){}
  try{await player.runCommandAsync(`tp ${center.x} ${center.y + 10} ${center.z}`);}catch(e){}
  if(!(await isShipAlreadyPlaced(overworld, center))){
    try{await overworld.runCommandAsync(`structure load ${STRUCTURE_NAME} ${center.x} ${center.y} ${center.z}`);}catch{await overworld.runCommandAsync(`execute positioned ${center.x} ${center.y} ${center.z} run function magodosen:build_ship`);}
    await overworld.runCommandAsync(`execute positioned ${center.x} ${center.y} ${center.z} run function magodosen:lightproof`);
    await overworld.runCommandAsync(`execute positioned ${center.x} ${center.y} ${center.z} run function magodosen:place_signs`);
    await overworld.runCommandAsync(`setworldspawn ${center.x} ${center.y + 2} ${center.z}`);
    await markShipPlaced(overworld, center);
  }
  try{await player.runCommandAsync(`tp ${center.x} ${center.y + 2} ${center.z}`);}catch(e){}
});
world.beforeEvents.playerBreakBlock.subscribe((ev)=>{
  const pos=ev.block.location;const center=getCenterFromWorldSpawn();
  if(isWithinBox(pos, center, SHIP_HALF_SIZE)){ev.cancel=true;}
});
world.afterEvents.playerBreakBlock.subscribe(async (ev)=>{
  const dim=ev.block.dimension;const pos=ev.block.location;const center=getCenterFromWorldSpawn();
  const rel={x:pos.x-center.x,y:pos.y-center.y,z:pos.z-center.z};const inCore3x3=Math.abs(rel.x)<=1&&rel.y===0&&Math.abs(rel.z)<=1;if(!inCore3x3)return;
  const state=getDayNightState();
  if(state==="day"){
    const pool=["minecraft:dirt","minecraft:stone","minecraft:sand","minecraft:gravel"];const pick=pool[Math.floor(Math.random()*pool.length)];
    await dim.runCommandAsync(`setblock ${pos.x} ${pos.y} ${pos.z} ${pick}`);
    if(Math.random()<0.08){const animals=["cow","sheep","chicken"];const a=animals[Math.floor(Math.random()*animals.length)];await dim.runCommandAsync(`summon ${a} ${pos.x} ${pos.y + 1} ${pos.z}`);}
  }else{
    const pool=["minecraft:oak_planks","minecraft:spruce_planks","minecraft:stone","minecraft:cobblestone","minecraft:coal_ore","minecraft:iron_ore"];const pick=pool[Math.floor(Math.random()*pool.length)];
    await dim.runCommandAsync(`setblock ${pos.x} ${pos.y} ${pos.z} ${pick}`);
    if(Math.random()<0.07){const mobs=["zombie","skeleton","spider"];const m=mobs[Math.floor(Math.random()*mobs.length)];await dim.runCommandAsync(`summon ${m} ${pos.x} ${pos.y + 1} ${pos.z}`);}
  }
});
