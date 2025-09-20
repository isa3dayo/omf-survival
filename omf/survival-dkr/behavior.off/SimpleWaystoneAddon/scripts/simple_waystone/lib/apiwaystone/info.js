import { world } from "@minecraft/server";
import { apiOrganize } from "../apiOrganize";
import { apiConfig } from "../apiConfig";
export const apiWaystoneInfo = new class apiWaystoneInfo {
    getAllWaystonesIds() {
        return world.getDynamicPropertyIds().filter(way => way.startsWith(`private/`) || way.startsWith(`public/`));
    }
    getAllClaimWaystonesIds() {
        return world.getDynamicPropertyIds().filter(way => way.startsWith(`claim/`));
    }
    getWaystoneList(player, ignoreConfig = false) {
        const config = apiConfig.getConfig(player);
        const publicWay = (ignoreConfig ? true : config.showPublic) ? this.getPublicWaystones() : [];
        const privateWay = this.getPrivateWaystones(player.id);
        const claimWay = this.getClaimWaystones(player.id);
        return apiOrganize.organize([...publicWay, ...privateWay, ...claimWay], !config.organize);
    }
    getPrivateWaystones(playerId) {
        const dynamics = world.getDynamicPropertyIds().filter(value => value.startsWith("private/"));
        const allWaystone = dynamics
            .map(point => {
            const formated = this.formatRawInfo(point);
            if (!formated)
                return null;
            const value = world.getDynamicProperty(point);
            if (typeof value != "string")
                return null;
            const savedInfo = value.split("/");
            const owner = savedInfo.shift();
            const name = savedInfo.join("/");
            if (!owner)
                return null;
            return {
                ...formated,
                name: name,
                owner: owner
            };
        })
            .filter(value => value !== null);
        if (!playerId)
            return allWaystone;
        return allWaystone.filter(value => value.owner == playerId);
    }
    getPublicWaystones() {
        const dynamics = world.getDynamicPropertyIds().filter(value => value.startsWith("public/"));
        return dynamics.map(point => {
            const formated = this.formatRawInfo(point);
            if (!formated)
                return null;
            const value = world.getDynamicProperty(point);
            if (typeof value != "string")
                return null;
            const savedInfo = value.split("/");
            const owner = savedInfo.shift();
            const name = savedInfo.join("/");
            if (!owner)
                return null;
            return {
                ...formated,
                name: name,
                owner: owner
            };
        })
            .filter(value => value !== null);
    }
    getClaimWaystones(playerId) {
        const allWaystonesId = world.getDynamicPropertyIds().filter(way => way.startsWith(`private/`));
        const claimList = world.getDynamicPropertyIds().filter(way => way.startsWith(`claim/`) && way.endsWith(playerId));
        return claimList
            .map(claim => {
            const [_, dimensionId, rawPos, playerId] = claim.split("/");
            if (!dimensionId || !rawPos || !playerId)
                return null;
            const idToFind = `${dimensionId}/${rawPos}`;
            const point = allWaystonesId.find(way => way.endsWith(idToFind));
            if (!point)
                return null;
            const formated = this.formatRawInfo(point);
            if (!formated)
                return null;
            const value = world.getDynamicProperty(point);
            if (typeof value != "string")
                return null;
            const savedInfo = value.split("/");
            const owner = savedInfo.shift();
            const name = savedInfo.join("/");
            if (!owner)
                return null;
            return {
                ...formated,
                name: name,
                owner: owner
            };
        })
            .filter(value => value !== null);
    }
    formatRawInfo(rawInfo) {
        const [access, dimensionId, rawPos] = rawInfo.split("/");
        if (!access || !dimensionId || !rawPos)
            return;
        const [posX, posY, posZ] = rawPos.split(",").map(value => parseInt(value));
        if (!posX || !posY || !posZ)
            return;
        return {
            pos: { x: posX, y: posY, z: posZ },
            world: dimensionId,
            type: access
        };
    }
    findWaystone(pos, dimension) {
        const waystones = this.getAllWaystonesIds();
        const idToFind = `${dimension.replace("minecraft:", "")}/${pos.x},${pos.y},${pos.z}`;
        const waystoneId = waystones.find(way => way.endsWith(idToFind));
        if (!waystoneId)
            return;
        const formated = this.formatRawInfo(waystoneId);
        if (!formated)
            return;
        const value = world.getDynamicProperty(waystoneId);
        if (typeof value != "string")
            return;
        const savedInfo = value.split("/");
        const owner = savedInfo.shift();
        const name = savedInfo.join("/");
        if (!owner)
            return;
        return {
            ...formated,
            name: name,
            owner: owner
        };
    }
};
