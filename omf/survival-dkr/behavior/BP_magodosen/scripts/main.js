import { world } from "@minecraft/server";
const FIXED_Y=250, HALF={x:16,y:16,z:16}, WORLD_FLAG_KEY="magodosen_ship_placed", PLAYER_TAG="magodosen_init_done";
function isWithinBox(l,c,h){return Math.abs(l.x-c.x)<=h.x&&Math.abs(l.y-c.y)<=h.y&&Math.abs(l.z-c.z)<=h.z;}
function clamp(v,l,h){return Math.max(l,Math.min(h,v));}
function centerPos(){const s=world.getDefaultSpawnLocation();const y=clamp(FIXED_Y,-64+5,319-5);return {x:Math.floor(s.x),y,z:Math.floor(s.z)};}
function inCore3x3(p,c,yOff=1){return Math.abs(p.x-c.x)<=1&&(p.y===c.y+yOff)&&Math.abs(p.z-c.z)<=1;}
world.afterEvents.playerSpawn.subscribe(async ev=>{const p=ev.player, ow=world.getDimension('overworld'), c=centerPos();
  if(p.getTags().includes(PLAYER_TAG))return;
  try{await p.runCommandAsync(`effect "${p.name}" slow_falling 8 1 true`);}catch{}; try{await p.runCommandAsync(`tp ${c.x} ${c.y+10} ${c.z}`);}catch{};
  let placed=false; try{placed=!!world.getDynamicProperty(WORLD_FLAG_KEY);}catch{}
  if(!placed){
    await ow.runCommandAsync(`fill ${c.x-10} ${c.y} ${c.z-10} ${c.x+10} ${c.y} ${c.z+10} oak_planks`);
    await ow.runCommandAsync(`fill ${c.x-10} ${c.y+1} ${c.z-10} ${c.x+10} ${c.y+2} ${c.z-10} oak_fence`);
    await ow.runCommandAsync(`fill ${c.x-10} ${c.y+1} ${c.z+10} ${c.x+10} ${c.y+2} ${c.z+10} oak_fence`);
    await ow.runCommandAsync(`fill ${c.x-10} ${c.y+1} ${c.z-10} ${c.x-10} ${c.y+2} ${c.z+10} oak_fence`);
    await ow.runCommandAsync(`fill ${c.x+10} ${c.y+1} ${c.z-10} ${c.x+10} ${c.y+2} ${c.z+10} oak_fence`);
    await ow.runCommandAsync(`fill ${c.x-1} ${c.y+1} ${c.z-1} ${c.x+1} ${c.y+1} ${c.z+1} cobblestone`);
    await ow.runCommandAsync(`fill ${c.x-3} ${c.y+2} ${c.z-3} ${c.x+3} ${c.y+3} ${c.z-3} oak_fence`);
    await ow.runCommandAsync(`fill ${c.x-3} ${c.y+2} ${c.z+3} ${c.x+3} ${c.y+3} ${c.z+3} oak_fence`);
    await ow.runCommandAsync(`fill ${c.x-3} ${c.y+2} ${c.z-3} ${c.x-3} ${c.y+3} ${c.z+3} oak_fence`);
    await ow.runCommandAsync(`fill ${c.x+3} ${c.y+2} ${c.z-3} ${c.x+3} ${c.y+3} ${c.z+3} oak_fence`);
    await ow.runCommandAsync(`setblock ${c.x+2} ${c.y+1} ${c.z} chest`);
    await ow.runCommandAsync(`replaceitem block ${c.x+2} ${c.y+1} ${c.z} slot.container 0 white_bed 1 0`);
    await ow.runCommandAsync(`replaceitem block ${c.x+2} ${c.y+1} ${c.z} slot.container 1 white_bed 1 0`);
    await ow.runCommandAsync(`replaceitem block ${c.x+2} ${c.y+1} ${c.z} slot.container 2 white_bed 1 0`);
    await ow.runCommandAsync(`replaceitem block ${c.x+2} ${c.y+1} ${c.z} slot.container 3 white_bed 1 0`);
    await ow.runCommandAsync(`replaceitem block ${c.x+2} ${c.y+1} ${c.z} slot.container 4 white_bed 1 0`);
    await ow.runCommandAsync(`replaceitem block ${c.x+2} ${c.y+1} ${c.z} slot.container 5 bread 10 0`);
    await ow.runCommandAsync(`function magodosen:light_grid`);
    await ow.runCommandAsync(`function magodosen:ship_shape`);
    await ow.runCommandAsync(`setworldspawn ${c.x} ${c.y+2} ${c.z}`);
    try{world.setDynamicProperty(WORLD_FLAG_KEY,1);}catch{}
  }
  try{await p.runCommandAsync(`tp ${c.x} ${c.y+2} ${c.z}`);}catch{};
  try{p.addTag(PLAYER_TAG);}catch{};
});
world.beforeEvents.playerBreakBlock.subscribe(ev=>{const p=ev.block.location, id=ev.block.typeId??"", c=centerPos();
  const allowType=(id==="minecraft:snow"||id==="minecraft:snow_layer"||id==="minecraft:chest");
  const allowArea=inCore3x3(p,c,1);
  if(!allowType&&!allowArea){ if(isWithinBox(p,c,HALF)) ev.cancel=true; }
});
world.afterEvents.playerBreakBlock.subscribe(async ev=>{const dim=ev.block.dimension, pos=ev.block.location, c=centerPos(); if(!inCore3x3(pos,c,1)) return;
  const day=world.getTimeOfDay()<12000;
  if(day){const pool=["minecraft:dirt","minecraft:stone","minecraft:sand","minecraft:gravel"];const pick=pool[Math.floor(Math.random()*pool.length)];await dim.runCommandAsync(`setblock ${pos.x} ${pos.y} ${pos.z} ${pick}`);if(Math.random()<0.08){const a=["cow","sheep","chicken"];const m=a[Math.floor(Math.random()*a.length)];await dim.runCommandAsync(`summon ${m} ${pos.x} ${pos.y+1} ${pos.z}`);}}
  else{const pool=["minecraft:oak_planks","minecraft:spruce_planks","minecraft:stone","minecraft:cobblestone","minecraft:coal_ore","minecraft:iron_ore"];const pick=pool[Math.floor(Math.random()*pool.length)];await dim.runCommandAsync(`setblock ${pos.x} ${pos.y} ${pos.z} ${pick}`);if(Math.random()<0.07){const m=["zombie","skeleton","spider"];const e=m[Math.floor(Math.random()*m.length)];await dim.runCommandAsync(`summon ${e} ${pos.x} ${pos.y+1} ${pos.z}`);}}});