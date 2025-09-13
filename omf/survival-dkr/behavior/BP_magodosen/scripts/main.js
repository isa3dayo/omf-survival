import { world } from "@minecraft/server";
const FIXED_Y=250, HALF={x:16,y:16,z:16}, WORLD_FLAG_KEY="magodosen_ship_placed", PLAYER_TAG="magodosen_init_done";
function isWithinBox(l,c,h){return Math.abs(l.x-c.x)<=h.x&&Math.abs(l.y-c.y)<=h.y&&Math.abs(l.z-c.z)<=h.z;}
function clamp(v,l,h){return Math.max(l,Math.min(h,v));}
function centerPos(){const s=world.getDefaultSpawnLocation();const y=clamp(FIXED_Y,-64+5,319-5);return {x:Math.floor(s.x),y,z:Math.floor(s.z)};}
function inCore3x3(p,c,yOff=1){return Math.abs(p.x-c.x)<=1&&(p.y===c.y+yOff)&&Math.abs(p.z-c.z)<=1;}
function choiceDayBlock(){const r=Math.random()*100;if(r<30)return "minecraft:dirt"; if(r<50)return "minecraft:stone"; if(r<70)return "minecraft:sand"; if(r<90)return "minecraft:gravel"; const logs=["minecraft:oak_log","minecraft:spruce_log","minecraft:birch_log","minecraft:jungle_log","minecraft:acacia_log","minecraft:dark_oak_log","minecraft:mangrove_log","minecraft:cherry_log"]; return logs[Math.floor(Math.random()*logs.length)];}
function choiceNightBlock(){const r=Math.random()*100;if(r<40){const logs=["minecraft:oak_log","minecraft:spruce_log","minecraft:birch_log","minecraft:jungle_log","minecraft:acacia_log","minecraft:dark_oak_log","minecraft:mangrove_log","minecraft:cherry_log"];return logs[Math.floor(Math.random()*logs.length)];} if(r<80)return "minecraft:stone"; if(r<85)return "minecraft:iron_ore"; if(r<90)return "minecraft:copper_ore"; if(r<95)return "minecraft:coal_ore"; return "minecraft:lapis_ore";}
world.afterEvents.playerSpawn.subscribe(async ev=>{ if(!ev.initialSpawn) return; const p=ev.player; if(p.getTags().includes(PLAYER_TAG)) return; try{p.addTag(PLAYER_TAG);}catch{}; const ow=world.getDimension('overworld'), c=centerPos();
  try{await p.runCommandAsync(`effect "${p.name}" slow_falling 8 1 true`);}catch{}; try{await p.runCommandAsync(`tp ${c.x} ${c.y+10} ${c.z}`);}catch{};
  let placed=false; try{placed=!!world.getDynamicProperty(WORLD_FLAG_KEY);}catch{}
  if(!placed){
    await ow.runCommandAsync(`fill ${c.x-10} ${c.y} ${c.z-10} ${c.x+10} ${c.y} ${c.z+10} minecraft:oak_planks`);
    await ow.runCommandAsync(`setblock ${c.x-1} ${c.y+1} ${c.z+1} minecraft:dirt`);
    await ow.runCommandAsync(`setblock ${c.x}   ${c.y+1} ${c.z+1} minecraft:sand`);
    await ow.runCommandAsync(`setblock ${c.x+1} ${c.y+1} ${c.z+1} minecraft:dirt`);
    const initLogs=["minecraft:oak_log","minecraft:spruce_log","minecraft:birch_log","minecraft:jungle_log","minecraft:acacia_log","minecraft:dark_oak_log","minecraft:mangrove_log","minecraft:cherry_log"];
    await ow.runCommandAsync(`setblock ${c.x-1} ${c.y+1} ${c.z} minecraft:gravel`);
    await ow.runCommandAsync(`setblock ${c.x}   ${c.y+1} ${c.z} minecraft:dirt`);
    await ow.runCommandAsync(`setblock ${c.x+1} ${c.y+1} ${c.z} ${initLogs[Math.floor(Math.random()*initLogs.length)]}`);
    await ow.runCommandAsync(`setblock ${c.x-1} ${c.y+1} ${c.z-1} minecraft:dirt`);
    await ow.runCommandAsync(`setblock ${c.x}   ${c.y+1} ${c.z-1} minecraft:stone`);
    await ow.runCommandAsync(`setblock ${c.x+1} ${c.y+1} ${c.z-1} minecraft:dirt`);
    await ow.runCommandAsync(`setblock ${c.x+2} ${c.y+1} ${c.z} minecraft:chest`);
    await ow.runCommandAsync(`item replace block ${c.x+2} ${c.y+1} ${c.z} slot.container 0 minecraft:white_bed 1`);
    await ow.runCommandAsync(`item replace block ${c.x+2} ${c.y+1} ${c.z} slot.container 1 minecraft:white_bed 1`);
    await ow.runCommandAsync(`item replace block ${c.x+2} ${c.y+1} ${c.z} slot.container 2 minecraft:white_bed 1`);
    await ow.runCommandAsync(`item replace block ${c.x+2} ${c.y+1} ${c.z} slot.container 3 minecraft:white_bed 1`);
    await ow.runCommandAsync(`item replace block ${c.x+2} ${c.y+1} ${c.z} slot.container 4 minecraft:white_bed 1`);
    await ow.runCommandAsync(`item replace block ${c.x+2} ${c.y+1} ${c.z} slot.container 5 minecraft:bread 10`);
    await ow.runCommandAsync(`execute positioned ${c.x} ${c.y} ${c.z} run function magodosen:torch_grid`);
    await ow.runCommandAsync(`setworldspawn ${c.x} ${c.y+2} ${c.z}`);
    try{world.setDynamicProperty(WORLD_FLAG_KEY,1);}catch{}
  }
  try{await p.runCommandAsync(`tp ${c.x} ${c.y+2} ${c.z}`);}catch{};
});
world.beforeEvents.playerBreakBlock.subscribe(ev=>{const pos=ev.block.location, id=ev.block.typeId??"", c=centerPos();
  const isTorch=(id==="minecraft:torch"||id==="minecraft:wall_torch");
  const chest={x:c.x+2,y:c.y+1,z:c.z}; const isChest=(pos.x===chest.x&&pos.y===chest.y&&pos.z===chest.z&&id==="minecraft:chest");
  const allowType=(id==="minecraft:snow"||id==="minecraft:snow_layer");
  const allowArea=inCore3x3(pos,c,1);
  if(isChest||isTorch){ev.cancel=true;return;}
  if(!allowType&&!allowArea){ if(isWithinBox(pos,c,HALF)) ev.cancel=true; }
});
world.afterEvents.playerBreakBlock.subscribe(async ev=>{const dim=ev.block.dimension, pos=ev.block.location, c=centerPos(); if(!inCore3x3(pos,c,1)) return;
  const isDay=world.getTimeOfDay()<12000;
  if(isDay){const pick=choiceDayBlock(); await dim.runCommandAsync(`setblock ${pos.x} ${pos.y} ${pos.z} ${pick}`); if(Math.random()<0.08){const animals=["cow","sheep","chicken"]; const a=animals[Math.floor(Math.random()*animals.length)]; await dim.runCommandAsync(`summon ${a} ${pos.x} ${pos.y+1} ${pos.z}`);}}
  else{const pick=choiceNightBlock(); await dim.runCommandAsync(`setblock ${pos.x} ${pos.y} ${pos.z} ${pick}`); if(Math.random()<0.07){const mobs=["zombie","skeleton","spider"]; const m=mobs[Math.floor(Math.random()*mobs.length)]; await dim.runCommandAsync(`summon ${m} ${pos.x} ${pos.y+1} ${pos.z}`);}}});