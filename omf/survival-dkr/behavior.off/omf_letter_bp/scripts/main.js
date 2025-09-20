import { world } from "@minecraft/server";

function nowIso(){ try { return new Date().toISOString(); } catch { return ""; } }
function out(payload){ console.log(`[OMF-CHAT] ${JSON.stringify(payload)}`); }

async function burnEffect(player, x, y, z){
  try { await player.runCommandAsync(`playsound fire.ignite @a ${x} ${y} ${z} 0.6 1.0`);} catch {}
  try { await player.runCommandAsync(`playsound random.fizz @a ${x} ${y} ${z} 0.4 1.0`);} catch {}
  const parts = ["minecraft:campfire_smoke_particle","minecraft:lava_particle","minecraft:poof","minecraft:basic_smoke_particle"];
  for (const p of parts){ try { await player.runCommandAsync(`particle ${p} ${x} ${y} ${z}`); } catch {} }
  for (let i=0;i<2;i++){ try { await player.runCommandAsync(`particle minecraft:poof ${x} ${y} ${z}`); } catch {} }
  console.log("[OMF-CHAT] particle_ok: burning_combo");
}

function consumeFromInventory(player, typeId, nameTag){
  try {
    const inv = player.getComponent("minecraft:inventory")?.container;
    if (!inv) return false;
    const slot = player.selectedSlot ?? 0;
    const it = inv.getItem(slot);
    if (it && it.typeId === typeId && (it.nameTag ?? "") === (nameTag ?? "")) {
      if ((it.amount ?? 1) > 1) { it.amount = it.amount - 1; inv.setItem(slot, it); }
      else { inv.setItem(slot, undefined); }
      return true;
    }
    const size = inv.size ?? 36;
    for (let i=0;i<size;i++){
      const s = inv.getItem(i);
      if (s && s.typeId === typeId && (s.nameTag ?? "") === (nameTag ?? "")) {
        if ((s.amount ?? 1) > 1) { s.amount = s.amount - 1; inv.setItem(i, s); }
        else { inv.setItem(i, undefined); }
        return true;
      }
    }
  } catch {}
  return false;
}

world.afterEvents.itemUse.subscribe(async (ev) => {
  const player = ev.source;
  if (!player || ev.itemStack?.typeId !== "omf:letter") return;

  const msg = ev.itemStack?.nameTag ?? "";
  const pos = player.location;
  const x = pos.x, y = pos.y + 1, z = pos.z;

  if (!msg.trim()) {
    try {
      await player.runCommandAsync(
        `tellraw @a {"rawtext":[{"text":"§7金床でメッセージ(名づけ)入力しなかったので、${player.name}の手紙は虚空に消えた"}]}`
      );
    } catch {}
    await burnEffect(player, x, y, z);
    consumeFromInventory(player, "omf:letter", "");
    return;
  }

  out({ type:"note_use", time:nowIso(), player: player.name, message: msg });
  try {
    const text = `[手紙] ${player.name}: ${msg}`.replace(/"/g, '\"');
    await player.runCommandAsync(`tellraw @a {"rawtext":[{"text":"${text}"}]}`);
  } catch {}
  await burnEffect(player, x, y, z);
  consumeFromInventory(player, "omf:letter", msg);
});
