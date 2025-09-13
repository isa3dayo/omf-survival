import { world, system, ItemStack } from "@minecraft/server";
import { apiWaystoneSpace } from "../lib/apiwaystone/space";
import { apiWaystoneInfo } from "../lib/apiwaystone/info";
import { apiWaystoneSave } from "../lib/apiwaystone/save";
import { waystoneUi } from "../ui/mainUi";
import { apiWarn } from "../lib/warn";
const replaceBlock = ["minecraft:air", "minecraft:lava", "minecraft:water"];
world.beforeEvents.worldInitialize.subscribe((data) => {
    data.blockComponentRegistry.registerCustomComponent("ws:waystone", {
        beforeOnPlayerPlace: e => {
            const { block, dimension, player } = e;
            const up = block.above(1);
            if (!up || !player)
                return;
            if (!replaceBlock.includes(up.typeId) || up.location.y >= dimension.heightRange.max) {
                e.cancel = true;
                return;
            }
            system.runTimeout(() => {
                apiWaystoneSpace.setOff(player, block);
                waystoneUi.createPoint(player, block);
            });
        },
        onPlayerInteract: e => {
            const { block: b, player } = e;
            const perm = b.permutation.getAllStates();
            const block = perm["ws:waystone"] == 1 ? b : b.below(1);
            if (!player || !block)
                return;
            if (perm["ws:waystone_on"] == false)
                return waystoneUi.createPoint(player, block);
            if (dyes.includes(player.getComponent("equippable")?.getEquipment("Mainhand")?.typeId || "bedrock_awakening:null_item"))
                return apiWaystoneSpace.paintWaystone(player, block, dyes);
            const waystone = apiWaystoneInfo.findWaystone(block, block.dimension.id);
            if (!waystone) {
                apiWaystoneSpace.setOff(player, block);
                return apiWarn.notify(player, "warning.simple_waystone:waystone.corrupted", { type: "action_bar", sound: "simple_waystone.warn.bass" });
            }
            if (waystone.owner == player.id && player.getComponent("equippable")?.getEquipment("Mainhand")?.typeId == "minecraft:brush")
                return apiWaystoneSpace.waystoneToWarpstone(player, block);
            if (apiWaystoneSave.saveClaimWaystone(player, waystone))
                return;
            if (player.isSneaking)
                return waystoneUi.settingsMenu(player, waystone);
            waystoneUi.waystoneList(player, waystone);
        }
    });
    data.itemComponentRegistry.registerCustomComponent("ws:warpstone", {
        onUse: ({ source: player, itemStack: item }) => {
            if (!item)
                return;
            if (player.getGameMode() == "creative") {
                player.setDynamicProperty("warpstoneCooldown", Math.floor(new Date().getTime() / 1000) - 1);
                return waystoneUi.waystoneList(player, undefined, item);
            }
            const date = Math.floor(new Date().getTime() / 1000);
            const cooldownEnd = player.getDynamicProperty("warpstoneCooldown") ?? new Date().getTime() / 1000 - 1;
            if (date < cooldownEnd && item.typeId == "ws:warpstone")
                return apiWarn.notify(player, { translate: "warning.simple_waystone:warpstone.cooldown", with: [`${cooldownEnd - date}s`] }, { type: "action_bar" });
            waystoneUi.waystoneList(player, undefined, item);
        }
    });
    data.itemComponentRegistry.registerCustomComponent("ws:return_scroll", {
        onUse: ({ source: player, itemStack: item }) => {
            waystoneUi.waystoneList(player, undefined, item);
        },
        onHitEntity: ({ attackingEntity: player, itemStack: item }) => {
            if (!item) {
                const newItem = new ItemStack("ws:return_scroll");
                const durability = newItem.getComponent("durability");
                if (!durability)
                    return;
                durability.damage = 9;
                player.getComponent("equippable")?.setEquipment("Mainhand", newItem);
                return;
            }
            const durability = item.getComponent("durability");
            if (!durability)
                return;
            durability.damage = durability.damage - 2;
            player.getComponent("equippable")?.setEquipment("Mainhand", item);
        }
    });
});
const dyes = [
    "minecraft:white_dye",
    "minecraft:light_gray_dye",
    "minecraft:gray_dye",
    "minecraft:black_dye",
    "minecraft:brown_dye",
    "minecraft:red_dye",
    "minecraft:orange_dye",
    "minecraft:yellow_dye",
    "minecraft:lime_dye",
    "minecraft:green_dye",
    "minecraft:cyan_dye",
    "minecraft:light_blue_dye",
    "minecraft:blue_dye",
    "minecraft:purple_dye",
    "minecraft:magenta_dye",
    "minecraft:pink_dye"
];
