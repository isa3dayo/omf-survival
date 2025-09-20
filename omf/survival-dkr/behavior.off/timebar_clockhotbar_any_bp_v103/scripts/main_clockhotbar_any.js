import { world, system } from "@minecraft/server";

const pad2 = n => n.toString().padStart(2, "0");

function mcClockHHMM(ticks) {
  const h = Math.floor(((ticks / 1000) + 6) % 24);
  const m = Math.floor(((ticks % 1000) * 60) / 1000);
  return `${pad2(h)}:${pad2(m)}`;
}

function realClockHHMM() {
  const d = new Date();
  return `${pad2(d.getHours())}:${pad2(d.getMinutes())}`;
}

/** Hotbar(0-8)のどこかに時計があれば true */
function hasClockInHotbar(player) {
  try {
    const inv = player.getComponent("minecraft:inventory")?.container;
    if (!inv) return false;
    for (let i = 0; i <= 8; i++) {
      const it = inv.getItem(i);
      if (it?.typeId === "minecraft:clock") return true;
    }
  } catch {}
  return false;
}

system.runInterval(() => {
  const mc = mcClockHHMM(world.getTimeOfDay());
  const rt = realClockHHMM();

  for (const p of world.getAllPlayers()) {
    if (hasClockInHotbar(p)) {
      // Format with space: R 12:00 / M 10:00
      p.onScreenDisplay.setActionBar(`§6R ${rt} / M ${mc}`);
    } else {
      p.onScreenDisplay.setActionBar("");
    }
  }
}, 20);
