export const levelBlocks = {
    15: [
        "end_rod",
        "ray:sea_torch",
        "ray:torch",
        "shroomlight",
        "froglight",
        "blaze",
        "lantern",
        "lava_bucket",
        "glowstone",
        "minecraft:campfire",
        "beacon",
        "lit_pumpkin",
        "torch",
    ],
    11: [
        "sea_pickle",
        "fire_charge",
        "breeze_rod",
        "open_eyeblossom",
        "glow_frame",
        "minecraft:magma",
        "magma_cream",
        "glow_berries",
        "glow_ink",
        "soul_torch",
        "soul_campfire",
        "soul_lantern",
        "crying_obsidian",
        "enchanting_table",
    ],
    8: ["firefly_bush", "sculk", "amethyst_cluster", "redstone_torch", "catalyst", "redstone_block", "redstone_ore", "redstone"],
};


//GetLightLevel 

export function getLevelForTypeId(typeId) {
    for (const level in levelBlocks) {
        for (const block of levelBlocks[level]) {
            if (typeId?.includes(block)) {
                return level;
            }
        }
    }

    return null;
}