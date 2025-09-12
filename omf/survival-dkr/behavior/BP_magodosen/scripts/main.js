import { world } from "@minecraft/server";
const OFFSET=300, HALF={x:16,y:8,z:16};
const STRUCTURE_NAME="magodosen_ship", WORLD_FLAG_KEY="magodosen_ship_placed", MARKER_BLOCK="minecraft:lodestone";
const BUILD_MIN_Y=-64, BUILD_MAX_Y=319;
function clamp(v,l,h){return Math.max(l,Math.min(h,v));}
function isWithinBox(l,c,h){return Math.abs(l.x-c.x)<=h.x&&Math.abs(l.y-c.y)<=h.y&&Math.abs(l.z-c.z)<=h.z;}
function getSurfaceY(dim,x,z){for(let y=BUILD_MAX_Y;y>=BUILD_MIN_Y;y--){try{const b=dim.getBlock({x,y,z});if(b&&b.typeId&&b.typeId!=="minecraft:air"&&b.typeId!=="minecraft:cave_air"&&b.typeId!=="minecraft:void_air") return y+1;}catch{}}return 64;}
function computeCenter(){const s=world.getDefaultSpawnLocation();const d=world.getDimension("overworld");const top=getSurfaceY(d,Math.floor(s.x),Math.floor(s.z));const y=clamp(top+OFFSET,BUILD_MIN_Y+5,BUILD_MAX_Y-5);return {x:Math.floor(s.x),y,z:Math.floor(s.z)};}
async function placedAlready(dim,c){try{if(world.getDynamicProperty(WORLD_FLAG_KEY))return true;}catch{}try{const b=dim.getBlock({x:c.x,y:c.y-1,z:c.z});if(b&&b.typeId===MARKER_BLOCK)return true;}catch{}return false;}
async function markPlaced(dim,c){try{world.setDynamicProperty(WORLD_FLAG_KEY,1);}catch{}try{await dim.runCommandAsync(`setblock ${c.x} ${c.y-1} ${c.z} ${MARKER_BLOCK}`);}catch{}}
world.afterEvents.playerSpawn.subscribe(async ev=>{if(!ev.initialSpawn)return;const p=ev.player,d=world.getDimension("overworld"),c=computeCenter();
try{await p.runCommandAsync(`effect "${p.name}" slow_falling 8 1 true`);}catch{};try{await p.runCommandAsync(`tp ${c.x} ${c.y+10} ${c.z}`);}catch{};
if(!(await placedAlready(d,c))){await d.runCommandAsync(`fill ${c.x-2} ${c.y} ${c.z-2} ${c.x+2} ${c.y} ${c.z+2} stone`);
  try{await d.runCommandAsync(`structure load ${STRUCTURE_NAME} ${c.x} ${c.y} ${c.z}`);}catch{await d.runCommandAsync(`execute positioned ${c.x} ${c.y} ${c.z} run function magodosen:build_ship`);}
  await d.runCommandAsync(`execute positioned ${c.x} ${c.y} ${c.z} run function magodosen:lightproof`);
  await d.runCommandAsync(`execute positioned ${c.x} ${c.y} ${c.z} run function magodosen:place_signs`);
  await d.runCommandAsync(`setworldspawn ${c.x} ${c.y+2} ${c.z}`);await markPlaced(d,c);}
try{await p.runCommandAsync(`tp ${c.x} ${c.y+2} ${c.z}`);}catch{};});
world.beforeEvents.playerBreakBlock.subscribe(ev=>{const c=computeCenter();if(isWithinBox(ev.block.location,c,HALF))ev.cancel=true;});
world.afterEvents.playerBreakBlock.subscribe(async ev=>{const dim=ev.block.dimension,pos=ev.block.location,c=computeCenter();const r={x:pos.x-c.x,y:pos.y-c.y,z:pos.z-c.z};if(!(Math.abs(r.x)<=1&&r.y===0&&Math.abs(r.z)<=1))return;
const day=world.getTimeOfDay()<12000;if(day){const pool=["minecraft:dirt","minecraft:stone","minecraft:sand","minecraft:gravel"];const pick=pool[Math.floor(Math.random()*pool.length)];await dim.runCommandAsync(`setblock ${pos.x} ${pos.y} ${pos.z} ${pick}`);if(Math.random()<0.08){const a=["cow","sheep","chicken"];const m=a[Math.floor(Math.random()*a.length)];await dim.runCommandAsync(`summon ${m} ${pos.x} ${pos.y+1} ${pos.z}`);}}
else{const pool=["minecraft:oak_planks","minecraft:spruce_planks","minecraft:stone","minecraft:cobblestone","minecraft:coal_ore","minecraft:iron_ore"];const pick=pool[Math.floor(Math.random()*pool.length)];await dim.runCommandAsync(`setblock ${pos.x} ${pos.y} ${pos.z} ${pick}`);if(Math.random()<0.07){const m=["zombie","skeleton","spider"];const e=m[Math.floor(Math.random()*m.length)];await dim.runCommandAsync(`summon ${e} ${pos.x} ${pos.y+1} ${pos.z}`);}}});