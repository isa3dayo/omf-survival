import { world, system, EquipmentSlot, BlockPermutation, ItemStack } from "./export.js";

import { getLevelForTypeId } from "./levels.js";

import { underWater } from "./underwater.js";

import { parseCoordinates } from "./utilities.js";

//Entity Variables
let getAllEntities;
let entities;

//GetEntities
system.run(() => {
    getAllEntities = () =>
        ["overworld", "nether", "the_end"].flatMap((dim) => world.getDimension(dim).getEntities({ tags: ["RDL"] }));
    entities = getAllEntities();
});

//RunInterval
system.runInterval(() => {
    entities.forEach((e) => {
        if (!e.isValid) return;

        if (e.location.y <= -64 || e.location.y >= 315) return;

        //Level
        let level = 0;

        //Underwater

        let underWaterValid = false;

        //Player
        if (e.typeId === "minecraft:player") {
            const equipment = e.getComponent("equippable");

            const slot = {
                mainhand: equipment.getEquipment(EquipmentSlot.Mainhand),
                offhand: equipment.getEquipment(EquipmentSlot.Offhand),
                head: equipment.getEquipment(EquipmentSlot.Head),
            };
            if (slot.mainhand?.typeId.startsWith("ray:item.")) {
                equipment.setEquipment(EquipmentSlot.Mainhand, new ItemStack(slot.mainhand.typeId.replace("ray:item.", "ray:")));
            }

            if (slot.head?.hasTag("ray:miner_helmet")) {
                level = 15;

                if (slot.head?.typeId.includes("sea")) {
                    underWaterValid = true;
                }
            } else {
                const mainhandLevel = getLevelForTypeId(slot.mainhand?.typeId) || 0;

                const offhandLevel = getLevelForTypeId(slot.offhand?.typeId) || 0;

                if (offhandLevel > 0) {
                    if (underWater.some((word) => slot.offhand?.typeId.includes(word))) {
                        underWaterValid = true;
                    }
                    level = offhandLevel;
                } else if (mainhandLevel > 0) {
                    if (underWater.some((word) => slot.mainhand?.typeId.includes(word))) {
                        underWaterValid = true;
                    }
                    level = mainhandLevel;
                }
            }
        } else {
            //Non-Player

            if (e?.hasTag("RDL:fire") && !e?.getComponent("onfire")) {
                e.removeTag("RDL:fire");
                e.removeTag("RDL");
                system.run(() => {
                    entities = getAllEntities();
                });
            }

            if (e.typeId === "minecraft:glow_squid") {
                underWaterValid = true;
            }
            level = 15;
        }
        if (level === 0) return;

        const dimension = e.dimension;

        const { x, y, z } = e.location;

        const baseX = Math.floor(x);
        const baseY = Math.floor(y);
        const baseZ = Math.floor(z);

        const inWater =
            (dimension.getBlock({ x: x, y: y + 1, z: z })?.typeId.includes("water") ||
                dimension.getBlock({ x: x, y: y + 1, z: z })?.isWaterlogged) &&
            (dimension.getBlock({ x: x, y: y, z: z })?.typeId.includes("water") ||
                dimension.getBlock({ x: x, y: y, z: z })?.isWaterlogged);
        let searchOffsets;

        if (!inWater) {
            searchOffsets = [
                { dx: 0, dy: 0, dz: 0 },
                { dx: 0, dy: 1, dz: 0 },
                { dx: 1, dy: 0, dz: 0 },
                { dx: 1, dy: 1, dz: 0 },
                { dx: -1, dy: 0, dz: 0 },
                { dx: -1, dy: 1, dz: 0 },
                { dx: 0, dy: 0, dz: 1 },
                { dx: 0, dy: 1, dz: 1 },
                { dx: 0, dy: 0, dz: -1 },
                { dx: 0, dy: 1, dz: -1 },
            ];
        } else if (inWater) {
            searchOffsets = [
                { dx: 1, dy: 0, dz: 0 },
                { dx: 1, dy: 1, dz: 0 },
                { dx: -1, dy: 0, dz: 0 },
                { dx: -1, dy: 1, dz: 0 },
                { dx: 0, dy: 0, dz: 1 },
                { dx: 0, dy: 1, dz: 1 },
                { dx: 0, dy: 0, dz: -1 },
                { dx: 0, dy: 1, dz: -1 },
            ];
        }
        let targetBlock = null;
        let liquidDepth = null;
        for (const offset of searchOffsets) {
            const block = dimension.getBlock({
                x: baseX + offset.dx,
                y: baseY + offset.dy,
                z: baseZ + offset.dz,
            });

            if (
                (block?.typeId === "minecraft:air" && !inWater) ||
                (!inWater && block?.typeId.startsWith(`minecraft:light_block_${level}`)) ||
                (block?.typeId.startsWith(`minecraft:light_block_${level}`) &&
                    inWater &&
                    block?.isWaterlogged &&
                    underWaterValid) ||
                (block?.typeId.includes("water") && underWaterValid && inWater)
            ) {
                liquidDepth = block.permutation.getState("liquid_depth") ?? -1;
                targetBlock = { x: baseX + offset.dx, y: baseY + offset.dy, z: baseZ + offset.dz };

                break;
            }
        }

        if (targetBlock) {
            world.setDynamicProperty(`RDL,X:${targetBlock.x},Y:${targetBlock.y},Z:${targetBlock.z},D:${e.dimension.id}`, level);

            //Block Data
            if (
                world.getDynamicProperty(`BD,X:${targetBlock.x},Y:${targetBlock.y},Z:${targetBlock.z},D:${e.dimension.id}`) ===
                undefined
            ) {
                world.setDynamicProperty(
                    `BD,X:${targetBlock.x},Y:${targetBlock.y},Z:${targetBlock.z},D:${e.dimension.id}`,
                    liquidDepth
                );
            }
        }
    });

    world
        .getDynamicPropertyIds()
        .filter((wp) => wp.startsWith("RDL"))
        .map((wp) => {
            if (wp.startsWith("RDL")) {
                const c = parseCoordinates(wp);
                if (world.getDimension(c.dimension).getBlock({ x: c.x, y: c.y, z: c.z }) !== undefined) {
                    const lv = world.getDynamicProperty(wp).toString();

                    const cd = world.getDimension(c.dimension);

                    if (world.getDynamicProperty(wp) > 0) {
                        const getBlock = cd.getBlock({ x: c.x, y: c.y, z: c.z })?.typeId;
                        if (getBlock !== undefined) {
                            if (getBlock === "minecraft:air" || getBlock.includes("water")) {
                                cd.setBlockPermutation(
                                    { x: c.x, y: c.y, z: c.z },
                                    BlockPermutation.resolve(`minecraft:light_block_${lv}`)
                                );
                            }
                        }
                    }

                    if (world.getDynamicProperty(wp) === 0) {
                        const getBlock = cd.getBlock({ x: c.x, y: c.y, z: c.z });
                        if (getBlock?.typeId.startsWith("minecraft:light_block")) {
                            world
                                .getDynamicPropertyIds()
                                .filter((bd) => bd.startsWith("BD"))
                                .map((bd) => {
                                    if (bd.startsWith("BD")) {
                                        const cD = parseCoordinates(bd);
                                        if (cD.x === c.x && cD.y === c.y && cD.z === c.z) {
                                            if (world.getDynamicProperty(bd) > -1) {
                                                cd.setBlockPermutation(
                                                    { x: c.x, y: c.y, z: c.z },
                                                    BlockPermutation.resolve("minecraft:flowing_water").withState(
                                                        "liquid_depth",
                                                        world.getDynamicProperty(bd)
                                                    )
                                                );

                                                world.setDynamicProperty(bd, undefined);
                                            } else {
                                                cd.setBlockPermutation(
                                                    { x: c.x, y: c.y, z: c.z },
                                                    BlockPermutation.resolve("minecraft:air")
                                                );
                                                world.setDynamicProperty(bd, undefined);
                                            }
                                        }
                                    }
                                });
                        }
                        world.setDynamicProperty(wp, undefined);
                    }
                    if (world.getDynamicProperty(wp) !== undefined) {
                        world.setDynamicProperty(wp, 0);
                    }
                }
            }
        });
}, 3);

//Sea Torch Item
world.afterEvents.entitySpawn.subscribe(({ entity }) => {
    if (!entity.isValid) return;
    if (entity.hasComponent("minecraft:item")) {
        const itemComponent = entity.getComponent("minecraft:item");
        const itemStack = itemComponent.itemStack;

        if (itemStack.typeId === "minecraft:underwater_torch") {
            const itemStackAmount = itemComponent.itemStack.amount;
            const torch = new ItemStack("ray:sea_torch", itemStackAmount);
            entity.dimension.spawnItem(torch, entity.location);
            entity.remove();
        }
    }
});

//Update entities

function reset_entities(entity) {
    system.run(() => {
        if (entity.isValid) {
            entity.addTag("RDL");
        }

        getAllEntities = () =>
            ["overworld", "nether", "the_end"].flatMap((dim) => world.getDimension(dim).getEntities({ tags: ["RDL"] }));
        entities = getAllEntities();
    });
}

world.afterEvents.entitySpawn.subscribe(({ entity }) => {
    if (!entity.isValid) return;

    if (getLevelForTypeId(entity.getComponent("item")?.itemStack?.typeId)) {
        reset_entities(entity);
    }

    if (entity.typeId === "minecraft:glow_squid") {
        reset_entities(entity);
    }

    if (entity.typeId === "minecraft:blaze") {
        reset_entities(entity);
    }
});

world.afterEvents.entityHurt.subscribe(({ hurtEntity, damageSource }) => {
    if (damageSource.cause === "fire" || damageSource.cause === "lava" || damageSource.cause === "fireTick") {
        reset_entities(hurtEntity);
        hurtEntity.addTag("RDL:fire");
    }
});

world.afterEvents.playerJoin.subscribe(() => {
    system.run(() => {
        entities = getAllEntities();
    });
});

world.afterEvents.playerSpawn.subscribe(({ player }) => {
    reset_entities(player);
});

world.beforeEvents.entityRemove.subscribe(({ removedEntity }) => {
    if (removedEntity.typeId === "minecraft:player") {
        system.run(() => {
            entities = getAllEntities();
        });
    }
});

world.beforeEvents.playerLeave.subscribe(() => {
    system.run(() => {
        entities = getAllEntities();
    });
});
