import { world } from "@minecraft/server";
import { colorDimension } from "../../ui/mainUi";
import { apiWarn } from "../warn";
export const apiWaystoneSave = new class ApiWaystoneSave {
    saveWaystone(waystoneId, waystoneInfo) {
        if (world.getDynamicProperty(waystoneId) != undefined)
            return false;
        world.setDynamicProperty(waystoneId, waystoneInfo);
        return true;
    }
    saveClaimWaystone(player, waystone) {
        if (waystone.type == "public")
            return false;
        if (waystone.owner == player.id)
            return false;
        if (world.getDynamicProperty(`claim/${waystone.world}/${waystone.pos.x},${waystone.pos.y},${waystone.pos.z}/${player.id}`) != undefined)
            return false;
        world.setDynamicProperty(`claim/${waystone.world}/${waystone.pos.x},${waystone.pos.y},${waystone.pos.z}/${player.id}`, 0);
        apiWarn.notify(player, { translate: "warning.simple_waystone:waystone.claimWaystone", with: [`${colorDimension[waystone.world]}${waystone.name}`] }, { type: "action_bar", sound: "simple_waystone.warn.levelup" });
        return true;
    }
};
