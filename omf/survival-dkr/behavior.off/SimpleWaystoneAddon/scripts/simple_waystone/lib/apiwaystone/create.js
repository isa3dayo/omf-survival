import { apiOrganize } from "../apiOrganize";
import { apiWaystoneInfo } from "./info";
import { apiWaystoneSave } from "./save";
import { apiWarn } from "../warn";
export const apiWaystoneCreate = new class ApiWaystoneCreate {
    createPoint(player, info) {
        const name = apiOrganize.sameNames(info.name, [...apiWaystoneInfo.getPrivateWaystones(player.id), ...apiWaystoneInfo.getPublicWaystones()].filter(way => way.owner == player.id).filter(way => way.type == (info.access ? "public" : "private")));
        const created = apiWaystoneSave.saveWaystone(`${info.access ? "public" : "private"}/${player.dimension.id.replace("minecraft:", "")}/${info.pos.x},${info.pos.y},${info.pos.z}`, `${player.id}/${name}`);
        if (!created)
            return apiWarn.notify(player, "warning.simple_waystone:waystone.failCreateWaystone", { type: "action_bar", sound: "simple_waystone.warn.break" });
        return name;
    }
};
