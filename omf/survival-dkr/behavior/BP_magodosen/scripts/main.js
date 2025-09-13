import { world, ItemStack } from "@minecraft/server";

// ===== 設定 =====
const FIXED_Y = 250;
const HALF = { x: 16, y: 16, z: 16 };           // 保護AABB
const WORLD_FLAG_KEY = "magodosen_ship_placed";
const PLAYER_TAG = "magodosen_init_done";

function isWithinBox(loc, c, h){ return Math.abs(loc.x-c.x)<=h.x && Math.abs(loc.y-c.y)<=h.y && Math.abs(loc.z-c.z)<=h.z; }
function clamp(v, lo, hi){ return Math.max(lo, Math.min(hi, v)); }
function centerPos(){ const s=world.getDefaultSpawnLocation(); const y=clamp(FIXED_Y,-64+5,319-5); return {x:Math.floor(s.x), y, z:Math.floor(s.z)}; }
function inCore3x3(pos, c, yOffset=1){ return Math.abs(pos.x-c.x)<=1 && (pos.y===c.y+yOffset) && Math.abs(pos.z-c.z)<=1; }

// 昼の資源
function choiceDayBlock(){
  const r = Math.random()*100;
  if (r < 30) return "minecraft:dirt";
  if (r < 50) return "minecraft:stone";
  if (r < 70) return "minecraft:sand";
  if (r < 90) return "minecraft:gravel";
  const logs = ["minecraft:oak_log","minecraft:spruce_log","minecraft:birch_log","minecraft:jungle_log","minecraft:acacia_log","minecraft:dark_oak_log","minecraft:mangrove_log","minecraft:cherry_log"];
  return logs[Math.floor(Math.random()*logs.length)];
}

// 夜の資源
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

async function fillChestWithAPI(dim, pos){
  try{
    const block = dim.getBlock(pos);
    const inv = block.getComponent("minecraft:inventory");
    if (!inv || !inv.container) return false;
    const chest = inv.container;
    chest.setItem(0, new ItemStack("minecraft:white_bed", 1));
    chest.setItem(1, new ItemStack("minecraft:white_bed", 1));
    chest.setItem(2, new ItemStack("minecraft:white_bed", 1));
    chest.setItem(3, new ItemStack("minecraft:white_bed", 1));
    chest.setItem(4, new ItemStack("minecraft:white_bed", 1));
    chest.setItem(5, new ItemStack("minecraft:bread", 10));
    return true;
  }catch(e){
    console.warn("[magodosen] chest fill failed:", e);
    return false;
  }
}

world.afterEvents.playerSpawn.subscribe(async (ev)=>{
  if (!ev.initialSpawn) return; // そのプレイヤーの初回だけ
  const p = ev.player;
  if (p.getTags().includes(PLAYER_TAG)) return; // 既に初期化済み

  // 先にタグ付け（以後TP防止）
  try { p.addTag(PLAYER_TAG); } catch {}

  const ow = world.getDimension("overworld");
  const c = centerPos();

  // 仮TP＆落下緩和
  try { await p.runCommandAsync(`effect "${p.name}" slow_falling 8 1 true`);} catch {}
  try { await p.runCommandAsync(`tp ${c.x} ${c.y + 10} ${c.z}`);} catch {}

  // 拠点生成（ワールド一度だけ）
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

    // 照明：たいまつ格子（先に置く）
    try { await ow.runCommandAsync(`execute positioned ${c.x} ${c.y} ${c.z} run function magodosen:torch_grid`);} catch {}

    // チェスト＋中身（APIで投入）
    try {
      await ow.runCommandAsync(`setblock ${c.x+2} ${c.y+1} ${c.z} minecraft:chest`);
      await fillChestWithAPI(ow, {x:c.x+2, y:c.y+1, z:c.z});
    } catch(e) {
      console.warn("[magodosen] chest placement/fill error:", e);
    }

    // リスポーンを中央へ
    try { await ow.runCommandAsync(`setworldspawn ${c.x} ${c.y + 2} ${c.z}`);} catch {}

    try { world.setDynamicProperty(WORLD_FLAG_KEY, 1); } catch {}
  }

  // 最終TP（初回のみ）
  try { await p.runCommandAsync(`tp ${c.x} ${c.y + 2} ${c.z}`);} catch {}
});

// 破壊可否：床は保護、資源3×3と雪は破壊可、チェスト＆松明は保護
world.beforeEvents.playerBreakBlock.subscribe((ev)=>{
  const pos = ev.block.location;
  const id = ev.block.typeId ?? "";
  const c = centerPos();

  const isTorch = (id === "minecraft:torch" || id === "minecraft:wall_torch");
  const chest = { x: c.x + 2, y: c.y + 1, z: c.z };
  const isChest = (pos.x===chest.x && pos.y===chest.y && pos.z===chest.z && id==="minecraft:chest");

  const allowByType = (id === "minecraft:snow" || id === "minecraft:snow_layer");
  const allowByArea = inCore3x3(pos, c, 1);

  if (isChest || isTorch) { ev.cancel = true; return; }
  if (!allowByType && !allowByArea) {
    if (isWithinBox(pos, c, HALF)) ev.cancel = true;
  }
});

// 資源更新
world.afterEvents.playerBreakBlock.subscribe(async (ev)=>{
  const dim = ev.block.dimension;
  const pos = ev.block.location;
  const c = centerPos();
  if (!inCore3x3(pos, c, 1)) return;

  const isDay = world.getTimeOfDay() < 12000;
  if (isDay) {
    const pick = choiceDayBlock();
    await dim.runCommandAsync(`setblock ${pos.x} ${pos.y} ${pos.z} ${pick}`);
    if (Math.random() < 0.08) { // 動物低確率
      const animals = ["cow","sheep","chicken"];
      const a = animals[Math.floor(Math.random()*animals.length)];
      await dim.runCommandAsync(`summon ${a} ${pos.x} ${pos.y + 1} ${pos.z}`);
    }
  } else {
    const pick = choiceNightBlock();
    await dim.runCommandAsync(`setblock ${pos.x} ${pos.y} ${pos.z} ${pick}`);
    if (Math.random() < 0.07) { // 敵対Mob低確率
      const mobs = ["zombie","skeleton","spider"];
      const m = mobs[Math.floor(Math.random()*mobs.length)];
      await dim.runCommandAsync(`summon ${m} ${pos.x} ${pos.y + 1} ${pos.z}`);
    }
  }
});
