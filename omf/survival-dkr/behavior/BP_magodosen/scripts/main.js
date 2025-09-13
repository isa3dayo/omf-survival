import { world } from "@minecraft/server";

// ===== 設定 =====
const FIXED_Y = 250;
const HALF = { x: 16, y: 16, z: 16 };           // 保護AABB
const WORLD_FLAG_KEY = "magodosen_ship_placed";
const PLAYER_TAG = "magodosen_init_done";

function isWithinBox(loc, c, h){ return Math.abs(loc.x-c.x)<=h.x && Math.abs(loc.y-c.y)<=h.y && Math.abs(loc.z-c.z)<=h.z; }
function clamp(v, lo, hi){ return Math.max(lo, Math.min(hi, v)); }
function centerPos(){ const s=world.getDefaultSpawnLocation(); const y=clamp(FIXED_Y,-64+5,319-5); return {x:Math.floor(s.x), y, z:Math.floor(s.z)}; }
function inCore3x3(pos, c, yOffset=1){ return Math.abs(pos.x-c.x)<=1 && (pos.y===c.y+yOffset) && Math.abs(pos.z-c.z)<=1; }

// 昼の資源（重み）: 土30, 石20, 砂20, 砂利20, 原木10
function choiceDayBlock(){
  const r = Math.random()*100;
  if (r < 30) return "minecraft:dirt";
  if (r < 50) return "minecraft:stone";
  if (r < 70) return "minecraft:sand";
  if (r < 90) return "minecraft:gravel";
  const logs = ["minecraft:oak_log","minecraft:spruce_log","minecraft:birch_log","minecraft:jungle_log","minecraft:acacia_log","minecraft:dark_oak_log","minecraft:mangrove_log","minecraft:cherry_log"];
  return logs[Math.floor(Math.random()*logs.length)];
}

// 夜の資源（重み）: 原木40, 石40, 鉄5, 銅5, 石炭5, ラピス5
function choiceNightBlock(){
  const r = Math.random()*100;
  if (r < 40) {
    const logs = ["minecraft:oak_log","minecraft:spruce_log","minecraft:birch_log","minecraft:jungle_log","minecraft:acacia_log","minecraft:dark_oak_log","minecraft:mangrove_log","minecraft:cherry_log"];
    return logs[Math.floor(Math.random()*logs.length)];
  }
  if (r < 80) return "minecraft:stone";
  if (r < 85) return "minecraft:iron_ore";
  if (r < 90) return "minecraft:copper_ore";
  if (r < 95) return "minecraft:coal_ore";
  return "minecraft:lapis_ore";
}

world.afterEvents.playerSpawn.subscribe(async (ev)=>{
  const p = ev.player;
  const ow = world.getDimension("overworld");
  const c = centerPos();

  if (p.getTags().includes(PLAYER_TAG)) return;

  try { await p.runCommandAsync(`effect "${p.name}" slow_falling 8 1 true`);} catch {}
  try { await p.runCommandAsync(`tp ${c.x} ${c.y + 10} ${c.z}`);} catch {}

  let placed = false; try { placed = !!world.getDynamicProperty(WORLD_FLAG_KEY); } catch {}
  if (!placed) {
    await ow.runCommandAsync(`fill ${c.x-10} ${c.y} ${c.z-10} ${c.x+10} ${c.y} ${c.z+10} minecraft:oak_planks`);

    // 初期資源（Y+1）
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

    // チェスト（保護対象）
    await ow.runCommandAsync(`setblock ${c.x+2} ${c.y+1} ${c.z} minecraft:chest`);
    await ow.runCommandAsync(`replaceitem block ${c.x+2} ${c.y+1} ${c.z} slot.container 0 minecraft:white_bed 1`);
    await ow.runCommandAsync(`replaceitem block ${c.x+2} ${c.y+1} ${c.z} slot.container 1 minecraft:white_bed 1`);
    await ow.runCommandAsync(`replaceitem block ${c.x+2} ${c.y+1} ${c.z} slot.container 2 minecraft:white_bed 1`);
    await ow.runCommandAsync(`replaceitem block ${c.x+2} ${c.y+1} ${c.z} slot.container 3 minecraft:white_bed 1`);
    await ow.runCommandAsync(`replaceitem block ${c.x+2} ${c.y+1} ${c.z} slot.container 4 minecraft:white_bed 1`);
    await ow.runCommandAsync(`replaceitem block ${c.x+2} ${c.y+1} ${c.z} slot.container 5 minecraft:bread 10`);

    // 照明
    await ow.runCommandAsync(`execute positioned ${c.x} ${c.y} ${c.z} run function magodosen:light_grid`);

    await ow.runCommandAsync(`setworldspawn ${c.x} ${c.y + 2} ${c.z}`);
    try { world.setDynamicProperty(WORLD_FLAG_KEY, 1); } catch {}
  }

  try { await p.runCommandAsync(`tp ${c.x} ${c.y + 2} ${c.z}`);} catch {}
  try { p.addTag(PLAYER_TAG); } catch {}
});

// 破壊可否：床は保護、資源3×3と雪は破壊可、チェストは保護（破壊不可）
world.beforeEvents.playerBreakBlock.subscribe((ev)=>{
  const pos = ev.block.location;
  const id = ev.block.typeId ?? "";
  const c = centerPos();

  // チェスト座標
  const chest = { x: c.x + 2, y: c.y + 1, z: c.z };
  const isChest = (pos.x===chest.x && pos.y===chest.y && pos.z===chest.z && id==="minecraft:chest");

  // 許可対象
  const allowByType = (id === "minecraft:snow" || id === "minecraft:snow_layer");
  const allowByArea = inCore3x3(pos, c, 1);

  // チェストは保護
  if (isChest) { ev.cancel = true; return; }

  if (!allowByType && !allowByArea) {
    if (isWithinBox(pos, c, HALF)) ev.cancel = true;
  }
});

// 資源3×3（Y+1）の昼夜更新＋スポーン
world.afterEvents.playerBreakBlock.subscribe(async (ev)=>{
  const dim = ev.block.dimension;
  const pos = ev.block.location;
  const c = centerPos();
  if (!inCore3x3(pos, c, 1)) return;

  const isDay = world.getTimeOfDay() < 12000;
  if (isDay) {
    const pick = choiceDayBlock();
    await dim.runCommandAsync(`setblock ${pos.x} ${pos.y} ${pos.z} ${pick}`);
    if (Math.random() < 0.08) { // 昼：低確率で動物（継続）
      const animals = ["cow","sheep","chicken"];
      const a = animals[Math.floor(Math.random()*animals.length)];
      await dim.runCommandAsync(`summon ${a} ${pos.x} ${pos.y + 1} ${pos.z}`);
    }
  } else {
    const pick = choiceNightBlock();
    await dim.runCommandAsync(`setblock ${pos.x} ${pos.y} ${pos.z} ${pick}`);
    if (Math.random() < 0.07) { // 夜：低確率で敵対Mob
      const mobs = ["zombie","skeleton","spider"];
      const m = mobs[Math.floor(Math.random()*mobs.length)];
      await dim.runCommandAsync(`summon ${m} ${pos.x} ${pos.y + 1} ${pos.z}`);
    }
  }
});
