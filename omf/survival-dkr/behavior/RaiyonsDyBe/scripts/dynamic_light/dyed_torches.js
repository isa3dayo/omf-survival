import { system, world, BlockPermutation, ItemStack, EquipmentSlot, MolangVariableMap } from "./export";

const hexValues = {
    black: "#565659",
    blue: "#9fa5f5",
    brown: "#c69f83",
    cyan: "#74dcdc",
    gray: "#87898a",
    green: "#b7d473",
    light_blue: "#a0e1f6",
    light_gray: "#c0c0bc",
    lime: "#c1f57a",
    magenta: "#efade9",
    orange: "#f8c69e",
    pink: "#f9ccd9",
    purple: "#d198ef",
    red: "#e6857f",
    white: "#f2f6f5",
    yellow: "#fae89f",
};

const invalidTags = ["minecraft:crop"];
const airBlocksList = [
    "ice",
    "torch",
    "vine",
    "candle",
    "fence",
    "door",
    "slab",
    "glass_pane",
    "carpet",
    "shulker_box",
    "chest",
    "leaves",
    "sapling",
    "redstone",
    "rail",
    "_anvil",
    "_sign",
    "_egg",
    "tulip",
    "daisy",
    "orchid",
    "poppy",
    "dandelion",
    "roots",
    "bush",
    "flower",
    "big_dripleaf",
    "pitcher",
    "allium",
    "rose",
    "cactus",
    "eyeblossom",
    "lily",
    "petal",
    "peony",
    "lilac",
    "bluet",
    "_button",
    "amethyst_bud",
    "amethyst_cluster",
    "pressure_plate",
    "flower",
    "seagrass",
    "minecraft:stonecutter_block",
    "minecraft:large_fern",
    "minecraft:pointed_dripstone",
    "minecraft:brewing_stand",
    "minecraft:cauldron",
    "minecraft:lectern",
    "minecraft:bell",
    "minecraft:enchanting_table",
    "minecraft:grindstone",
    "minecraft:tall_grass",
    "minecraft:bamboo",
    "minecraft:web",
    "minecraft:scaffolding",
    "minecraft:iron_bars",
    "minecraft:ladder",
    "minecraft:sea_pickle",
];

const offsets = {
    South: { x: 0, y: 0, z: -1 },
    North: { x: 0, y: 0, z: 1 },
    West: { x: 1, y: 0, z: 0 },
    East: { x: -1, y: 0, z: 0 },
    Up: { x: 0, y: -1, z: 0 },
};

const brakeOffsets = [
    { x: 0, y: 0, z: -1 },
    { x: 0, y: 0, z: 1 },
    { x: 1, y: 0, z: 0 },
    { x: -1, y: 0, z: 0 },
    { x: 0, y: 1, z: 0 },
];

world.afterEvents.playerBreakBlock.subscribe(({ block, dimension, brokenBlockPermutation }) => {
    if (brokenBlockPermutation.hasTag("custom:torch")) return;
    const { x, y, z } = block.location;

    for (const offset of brakeOffsets) {
        const neighborBlock = dimension.getBlock({ x: x + offset.x, y: y + offset.y, z: z + offset.z });
        if (!neighborBlock.hasTag("custom:torch")) continue;

        const faceOffset = offsets[neighborBlock.permutation.getState("custom:face")];
        const targetBlock = dimension.getBlock({
            x: neighborBlock.location.x + faceOffset.x,
            y: neighborBlock.location.y + faceOffset.y,
            z: neighborBlock.location.z + faceOffset.z,
        });

        if (targetBlock.location.x === x && targetBlock.location.y === y && targetBlock.location.z === z) {
            system.run(() => {
                dimension.playSound("dig.wood", neighborBlock.location, { pitch: getR(0.8, 1) });
                dimension.spawnItem(new ItemStack(neighborBlock.typeId), {
                    x: neighborBlock.location.x,
                    y: neighborBlock.location.y + 0.5,
                    z: neighborBlock.location.z,
                });
                dimension.setBlockType(neighborBlock.location, "minecraft:air");
            });
        }
    }
});

system.beforeEvents.startup.subscribe((initEvent) => {
    initEvent.blockComponentRegistry.registerCustomComponent("custom:torch", {
        onTick: (t) => {
            const { dimension: dim, block } = t;
            const face = block.permutation.getState("custom:face");
            spawnParticles(block.location, block.typeId, dim, face, 1, 3);
        },
        beforeOnPlayerPlace: (e) => {
            system.run(() => {
                e.player.addTag("ray:PlaceBlock");
            });

            let isNotValid;
            const block = e.block;

            const dim = e.dimension;
            const face = e.face;
            const per = e.permutationToPlace;
            const x = block.location.x;
            const y = block.location.y;
            const z = block.location.z;

            if (offsets[face]) {
                const offset = offsets[face];
                const targetBlock = dim.getBlock({
                    x: x + offset.x,
                    y: y + offset.y,
                    z: z + offset.z,
                });
                const belowBlock = dim.getBlock({ x: x, y: y - 1, z: z });
                const aboveBlock = dim.getBlock({ x: x, y: y + 1, z: z });

                const blockType = targetBlock.typeId;
                const blockTags = targetBlock.getTags();

                isNotValid =
                    airBlocksList.some((word) => blockType.includes(word)) ||
                    (belowBlock.typeId === "minecraft:air" && face === "Up") ||
                    ((aboveBlock.typeId.includes("water") || aboveBlock.typeId.includes("seagrass")) && face === "Up") ||
                    blockTags.some((tag) => invalidTags.includes(tag));
            }

            e.cancel = true;

            if (isNotValid || block.isLiquid) return;

            const newPer = BlockPermutation.resolve(per.type.id);
            system.run(() => {
                dim.setBlockPermutation(block.location, newPer.withState("custom:face", face));

                spawnParticles(block.location, per.type.id, dim, face, 1, 1);

                dim.playSound("dig.wood", block.location, { pitch: 0.8 });
            });
            if (e.player.getGameMode() === "Survival") {
                const equip = e.player.getComponent("equippable");

                const mainhand = equip.getEquipment(EquipmentSlot.Mainhand);

                if (mainhand) {
                    const itemStack =
                        mainhand.amount - 1 > 0 ? new ItemStack(per.type.id, mainhand.amount - 1) : new ItemStack("minecraft:air");
                    system.run(() => {
                        equip.setEquipment(EquipmentSlot.Mainhand, itemStack);
                    });
                }
            }
        },
    });
});

function getR(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function spawnParticles(location, typeId, dimension, face, min, max) {
    const { x, y, z } = location;

    const offsets = {
        Up: { x: 0.5, y: 0.75, z: 0.5 },
        North: { x: 0.5, y: 0.9, z: 0.8 },
        South: { x: 0.5, y: 0.9, z: 0.2 },
        East: { x: 0.2, y: 0.9, z: 0.5 },
        West: { x: 0.8, y: 0.9, z: 0.5 },
    };

    const hex = hexValues[typeId.replace("ray:", "").replace("_torch", "")] || "#FFFFFF";
    const { r, g, b, a } = hexToRgba(hex);

    const mv = new MolangVariableMap();
    mv.setFloat("r", r);
    mv.setFloat("g", g);
    mv.setFloat("b", b);
    mv.setFloat("a", a);

    const offset = offsets[face] || { x: 0, y: 0, z: 0 };

    dimension.spawnParticle(
        "ray:light",
        {
            x: x + offset.x,
            y: y + offset.y - 0.2,
            z: z + offset.z,
        },
        mv
    );

    if (getR(min, max) === 1) {
        dimension.spawnParticle("minecraft:basic_smoke_particle", {
            x: x + offset.x,
            y: y + offset.y,
            z: z + offset.z,
        });

        dimension.spawnParticle(
            "ray:basic_flame_particle",
            {
                x: x + offset.x,
                y: y + offset.y,
                z: z + offset.z,
            },
            mv
        );
    }
}

function hexToRgba(hex) {
    hex = hex.replace(/^#/, "");
    const r = parseInt(hex.substring(0, 2), 16) / 255;
    const g = parseInt(hex.substring(2, 4), 16) / 255;
    const b = parseInt(hex.substring(4, 6), 16) / 255;
    const a = hex.length === 8 ? parseInt(hex.substring(6, 8), 16) / 255 : 1;

    return { r, g, b, a };
}
