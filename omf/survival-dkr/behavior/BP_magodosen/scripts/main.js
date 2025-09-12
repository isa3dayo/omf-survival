import { world } from "@minecraft/server";

const SHIP_Y_OFFSET_TEST = 20;
const SHIP_Y_OFFSET_PROD = 100;
const USE_TEST_HEIGHT = true;
const SHIP_HALF_SIZE = { x: 16, y: 8, z: 16 };
const STRUCTURE_NAME = "magodosen_ship";
const WORLD_TAG_PLACED = "magodosen_ship_placed";

function isWithinBox(loc, center, half) {
  return Math.abs(loc.x - center.x) <= half.x &&
         Math.abs(loc.y - center.y) <= half.y &&
         Math.abs(loc.z - center.z) <= half.z;
}

function getDayNightState() {
  const t = world.getTimeOfDay();
  return (t < 12000) ? "day" : "night";
}

world.afterEvents.playerSpawn.subscribe(async (ev) => {
  if (!ev.initialSpawn) return;
  const player = ev.player;
  const overworld = world.getDimension("overworld");
  const yoff = USE_TEST_HEIGHT ? SHIP_Y_OFFSET_TEST : SHIP_Y_OFFSET_PROD;

  if (!world.getDynamicProperty(WORLD_TAG_PLACED)) {
    const sp = player.location;
    const center = { x: Math.floor(sp.x), y: Math.floor(sp.y + yoff), z: Math.floor(sp.z) };

    try {
      await overworld.runCommandAsync(`structure load ${STRUCTURE_NAME} ${center.x} ${center.y} ${center.z}`);
    } catch {
      await overworld.runCommandAsync(`function magodosen:build_ship`);
    }
    await overworld.runCommandAsync(`function magodosen:lightproof`);
    await overworld.runCommandAsync(`function magodosen:place_signs`);
    await player.runCommandAsync(`tp ${center.x} ${center.y + 2} ${center.z}`);
    world.setDynamicProperty(WORLD_TAG_PLACED, 1);
  }
});

world.beforeEvents.playerBreakBlock.subscribe((ev) => {
  const pos = ev.block.location;
  const wspawn = world.getDefaultSpawnLocation();
  const center = {
    x: Math.floor(wspawn.x),
    y: Math.floor(wspawn.y + (USE_TEST_HEIGHT ? SHIP_Y_OFFSET_TEST : SHIP_Y_OFFSET_PROD)),
    z: Math.floor(wspawn.z),
  };
  if (isWithinBox(pos, center, SHIP_HALF_SIZE)) {
    ev.cancel = true;
  }
});

world.afterEvents.playerBreakBlock.subscribe(async (ev) => {
  const dim = ev.block.dimension;
  const pos = ev.block.location;
  const wspawn = world.getDefaultSpawnLocation();
  const center = {
    x: Math.floor(wspawn.x),
    y: Math.floor(wspawn.y + (USE_TEST_HEIGHT ? SHIP_Y_OFFSET_TEST : SHIP_Y_OFFSET_PROD)),
    z: Math.floor(wspawn.z),
  };
  const rel = { x: pos.x - center.x, y: pos.y - center.y, z: pos.z - center.z };
  const inCore3x3 = Math.abs(rel.x) <= 1 && rel.y === 0 && Math.abs(rel.z) <= 1;
  if (!inCore3x3) return;

  const state = getDayNightState();
  if (state === "day") {
    const pool = ["minecraft:dirt", "minecraft:stone", "minecraft:sand", "minecraft:gravel"];
    const pick = pool[Math.floor(Math.random() * pool.length)];
    await dim.runCommandAsync(`setblock ${pos.x} ${pos.y} ${pos.z} ${pick}`);
    if (Math.random() < 0.08) {
      const animals = ["cow", "sheep", "chicken"];
      const a = animals[Math.floor(Math.random() * animals.length)];
      await dim.runCommandAsync(`summon ${a} ${pos.x} ${pos.y + 1} ${pos.z}`);
    }
  } else {
    const pool = ["minecraft:oak_planks", "minecraft:spruce_planks", "minecraft:stone",
                  "minecraft:cobblestone", "minecraft:coal_ore", "minecraft:iron_ore"];
    const pick = pool[Math.floor(Math.random() * pool.length)];
    await dim.runCommandAsync(`setblock ${pos.x} ${pos.y} ${pos.z} ${pick}`);
    if (Math.random() < 0.07) {
      const mobs = ["zombie", "skeleton", "spider"];
      const m = mobs[Math.floor(Math.random() * mobs.length)];
      await dim.runCommandAsync(`summon ${m} ${pos.x} ${pos.y + 1} ${pos.z}`);
    }
  }
});