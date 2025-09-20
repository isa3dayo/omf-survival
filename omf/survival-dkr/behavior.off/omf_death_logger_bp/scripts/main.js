// Summary:
//   OMF Death Logger (Console Only)
//   - Subscribes to world.afterEvents.entityDie
//   - Logs ONLY player deaths to console as JSON (coords, dimension, cause, killer info)
//   - Does NOT subscribe to any chat APIs (no before/after/legacy), so no chat warnings.
//
// Log example:
//   [OMF-DEATH] {"type":"death","time":"2025-09-15T00:25:58.157Z","player":"misao139","deathCause":"entityAttack","position":{"x":-52.7,"y":63,"z":-11.7},"dimension":"minecraft:overworld","killerName":"","killerType":"minecraft:zombie"}

import { world } from "@minecraft/server";

function isoNow(){ try { return new Date().toISOString(); } catch { return ""; } }
function round1(n){ try { return Math.round(n * 10)/10; } catch { return n; } }
function safeDimId(dim){
  try { return dim?.id ?? ""; } catch { return ""; }
}
function deathCauseStr(ds){
  try { return ds?.cause ?? "unknown"; } catch { return "unknown"; }
}
function killerName(ds){
  try { return ds?.damagingEntity?.nameTag || ds?.damagingEntity?.name || ""; } catch { return ""; }
}
function killerType(ds){
  try { return ds?.damagingEntity?.typeId || ""; } catch { return ""; }
}

world.afterEvents.entityDie.subscribe((ev) => {
  const dead = ev?.deadEntity;
  if (!dead || dead.typeId !== "minecraft:player") return;

  let pos = {x:0,y:0,z:0};
  try {
    pos = { x: round1(dead.location.x), y: Math.floor(dead.location.y), z: round1(dead.location.z) };
  } catch {}

  const payload = {
    type: "death",
    time: isoNow(),
    player: (dead.name ?? dead.nameTag ?? ""),
    deathCause: deathCauseStr(ev.damageSource),
    position: pos,
    dimension: safeDimId(dead.dimension),
    killerName: killerName(ev.damageSource),
    killerType: killerType(ev.damageSource)
  };

  console.log(`[OMF-DEATH] ${JSON.stringify(payload)}`);
});
