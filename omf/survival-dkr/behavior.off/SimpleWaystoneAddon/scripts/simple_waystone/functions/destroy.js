import { apiWaystoneSpace } from "../lib/apiwaystone/space";
import { world, system } from "@minecraft/server";
import { apiWaystoneInfo } from "../lib/apiwaystone/info";
import { apiWarn } from "../lib/warn";
world.afterEvents.playerBreakBlock.subscribe(({ brokenBlockPermutation: blockPerm, block: b, dimension, itemStackBeforeBreak: item, player }) => {
    if (blockPerm.type.id.includes("ws:waystone_")) {
        const drop = blockPerm.getItemStack();
        if (drop && !item?.getComponent("enchantable")?.hasEnchantment("minecraft:silk_touch") && player.getGameMode() != "creative")
            dimension.spawnItem(drop, apiWaystoneSpace.setCenterVector(b.location));
        if (blockPerm.getState("ws:waystone_on") == false)
            return;
        const block = blockPerm.getState("ws:waystone") == 1 ? b : b.below(1);
        if (!block)
            return;
        removeWaystone(block.location, dimension.id.replace("minecraft:", ""));
        apiWarn.notify(player, "", { sound: "simple_waystone.block.waystone.unregistered" });
    }
});
const explosed = [];
world.afterEvents.blockExplode.subscribe(({ block: b, explodedBlockPermutation: blockPerm, dimension }) => {
    if (blockPerm.type.id.includes("ws:waystone_")) {
        const newPos = apiWaystoneSpace.getRelativeVector(b.location, blockPerm.getState("ws:waystone") == 1 ? 1 : -1);
        if (!explosed.includes(JSON.stringify(newPos))) {
            const item = blockPerm.getItemStack();
            if (item)
                dimension.spawnItem(item, apiWaystoneSpace.setCenterVector(b.location));
            const index = explosed.push(JSON.stringify(b.location)) - 1;
            system.runTimeout(() => { explosed.splice(index, 1); }, 20);
        }
        if (!blockPerm.getState("ws:waystone_on"))
            return;
        const block = blockPerm.getState("ws:waystone") == 1 ? b : b.below(1);
        if (!block)
            return;
        removeWaystone(block.location, dimension.id.replace("minecraft:", ""));
    }
});
const pistonDirection = [["y", -1], ["y", 1], ["z", 1], ["z", -1], ["x", 1], ["x", -1]];
world.afterEvents.pistonActivate.subscribe(({ block, dimension, isExpanding, piston }) => {
    const direction = block.permutation.getState("facing_direction");
    if (typeof direction != "number")
        return;
    const increase = pistonDirection[direction];
    const locations = piston.getAttachedBlocksLocations();
    if (!increase)
        return;
    system.runTimeout(() => {
        for (let pos of locations) {
            try {
                pos[increase[0]] += increase[1] * (isExpanding ? 1 : -1);
                const block = dimension.getBlock(pos);
                if (!block || !block.typeId.includes("ws:waystone_"))
                    continue;
                const drop = block.getItemStack();
                dimension.setBlockType(pos, "minecraft:air");
                pos[increase[0]] += increase[1] * (isExpanding ? -1 : 1);
                removeWaystone(pos, dimension.id.replace("minecraft:", ""));
                if (drop)
                    dimension.spawnItem(drop, apiWaystoneSpace.setCenterVector(pos));
            }
            catch (e) {
                console.warn(e);
            }
        }
    }, 2);
});
export function removeWaystone(pos, dimension) {
    const allWaystones = apiWaystoneInfo.getAllWaystonesIds();
    const waystone = allWaystones.find(value => value.endsWith(`/${dimension}/${pos.x},${pos.y},${pos.z}`));
    if (!waystone)
        return;
    world.setDynamicProperty(waystone, undefined);
    const claimList = apiWaystoneInfo.getAllClaimWaystonesIds().filter(value => value.startsWith(`claim/${dimension}/${pos.x},${pos.y},${pos.z}`));
    claimList.forEach(way => { world.setDynamicProperty(way, undefined); });
}
