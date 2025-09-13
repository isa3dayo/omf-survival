import { ActionFormData, ModalFormData, MessageFormData } from "@minecraft/server-ui";
import { world, system } from "@minecraft/server";
import { apiWaystoneCreate } from "../lib/apiwaystone/create";
import { apiWaystoneSpace } from "../lib/apiwaystone/space";
import { apiWaystoneInfo } from "../lib/apiwaystone/info";
import { removeWaystone } from "../functions/destroy";
import { apiOrganize } from "../lib/apiOrganize";
import { apiConfig } from "../lib/apiConfig";
import { apiItem } from "../lib/apiItem";
import { apiVec3 } from "../lib/vector";
import { apiWarn } from "../lib/warn";
export const organizeDimension = ["current", "world-nether-end", "world-end-nether", "nether-world-end", "nether-end-world", "end-world-nether", "end-nether-world"];
const organizePublic = ["firstDimension", "lastDimension", "firstList", "lastList"];
export const colorDimension = { "overworld": "§2", "nether": "§4", "the_end": "§u" };
const xpSprite = ["", " - \ue701", " - \ue702", " - \ue703", "\ue700"];
export const waystoneUi = new class waystoneUi {
    createPoint(player, block) {
        new ModalFormData()
            .title(`ui.simple_waystone:waystone.create.title`)
            .textField("ui.simple_waystone:waystone.create.textField", "ui.simple_waystone:waystone.create.textFieldHold")
            .toggle("ui.simple_waystone:waystone.create.toggle")
            .submitButton("ui.simple_waystone:waystone.create.button")
            .show(player).then(r => {
            if (r.canceled || r.formValues == undefined)
                return;
            const [name, access] = r.formValues;
            if (typeof name != "string" || typeof access != "boolean")
                return apiWarn.notify(player, "warning.simple_waystone:waystone.failCreateWaystone", { type: "action_bar", sound: "simple_waystone.warn.break" });
            if (!name)
                return apiWarn.notify(player, "warning.simple_waystone:waystone.failCreateWaystone", { type: "action_bar", sound: "simple_waystone.warn.break" });
            if (name.replaceAll(/§./g, "").replaceAll("§", "").length < 1)
                return apiWarn.notify(player, "warning.simple_waystone:waystone.failCreateWaystone", { type: "action_bar", sound: "simple_waystone.warn.break" });
            const created = apiWaystoneCreate.createPoint(player, { name: name, access: access, pos: block.location });
            if (typeof created != "string")
                return;
            apiWaystoneSpace.setOn(player, block);
            apiWarn.notify(player, { translate: "warning.simple_waystone:waystone.createWaystone", with: [`${colorDimension[player.dimension.id.replace("minecraft:", "")]}${created}`] }, { type: "action_bar", sound: "simple_waystone.block.waystone.registered" });
        });
    }
    waystoneList(player, waystone, item) {
        const config = apiConfig.getConfig(player);
        const waystones = apiOrganize.organizeDimension(player, apiWaystoneInfo.getWaystoneList(player));
        if (!waystones || waystones?.length < 1)
            return apiWarn.notify(player, "warning.simple_waystone:waystone.failFindWaystones", { type: "action_bar", sound: "simple_waystone.warn.bass" });
        const buttons = waystones.map(value => {
            const cost = apiWaystoneSpace.calculateCost(player, value);
            return { id: `${colorDimension[value.world]}${value.name}§r${cost > 3 ? " - §l§2" + xpSprite[4] + cost + "§r" : xpSprite[cost]}`, cost: cost, type: value.type };
        });
        if (buttons.length < 1)
            return apiWarn.notify(player, "warning.simple_waystone:waystone.failFindWaystones", { type: "action_bar", sound: "simple_waystone.warn.bass" });
        const form = new ActionFormData()
            .title(item ? { translate: `item.${item.typeId}` } : { translate: "ui.simple_waystone:waystone.list.title", with: [waystone ? ` - ${colorDimension[waystone.world]}${waystone.name}§r` : ""] })
            .body("ui.simple_waystone:waystone.list.body");
        buttons.forEach(button => { config.showPublic ? form.button({ "rawtext": [{ "text": `${button.id}\n` }, { "translate": `ui.simple_waystone:waystone.list.${button.type}` }] }) : form.button(button.id); });
        form.show(player).then(r => {
            if (r.canceled || r.selection == undefined)
                return;
            const button = buttons[r.selection];
            const selected = waystones[r.selection];
            if (!selected || !button || (selected.name == waystone?.name && apiVec3.compare(selected.pos, waystone.pos)))
                return apiWarn.notify(player, "warning.simple_waystone:waystone.tpCurrentWaystone", { type: "action_bar" });
            if (player.level < button.cost && player.getGameMode() != "creative")
                return apiWarn.notify(player, "warning.simple_waystone:waystone.insufficientXp", { sound: "simple_waystone.warn.bass" });
            if (!waystone && item) {
                const execute = apiItem[item.typeId];
                if (execute)
                    if (execute(player))
                        return apiWarn.notify(player, "warning.simple_waystone:waystone.invalidTeleportItem", { type: "action_bar", sound: "simple_waystone.warn.break" });
            }
            if (!item)
                apiWarn.notify(player, "", { sound: "simple_waystone.block.waystone.teleport", delaySound: 1 });
            if (player.getGameMode() != "creative")
                player.addLevels(-button.cost);
            player.teleport({ x: selected.pos.x + 0.5, y: selected.pos.y, z: selected.pos.z + 0.5 }, { dimension: world.getDimension(selected.world) });
            system.runTimeout(() => {
                try {
                    const block = player.dimension.getBlock(selected.pos);
                    if (!block)
                        return;
                    if (!block.getTags().includes("simple_waystone:waystone")) {
                        removeWaystone(selected.pos, player.dimension.id);
                        apiWarn.notify(player, "warning.simple_waystone:waystone.corrupted", { type: "action_bar", sound: "simple_waystone.warn.bass" });
                    }
                }
                catch { }
            }, 20);
        });
    }
    settingsMenu(player, waystone) {
        const owner = waystone.owner;
        if (owner != player.id)
            return apiWarn.notify(player, "warning.simple_waystone:waystone.notOwner", { sound: "simple_waystone.warn.bass" });
        new ActionFormData()
            .title("ui.simple_waystone:waystone.settingsMenu.title")
            .body("ui.simple_waystone:waystone.settingsMenu.body")
            .button("ui.simple_waystone:waystone.settingsMenu.title")
            .button("ui.simple_waystone:waystone.removeWaystone.title")
            .show(player).then(r => {
            if (r.canceled || r.selection == undefined)
                return;
            if (r.selection == 0)
                return this.settingsWaystone(player);
            return this.removeWaystones(player);
        });
    }
    settingsWaystone(player) {
        const config = apiConfig.getConfig(player);
        new ModalFormData()
            .title("ui.simple_waystone:waystone.settingsMenu.title")
            .toggle("ui.simple_waystone:waystone.settings.toggle.organize", config.organize)
            .dropdown("ui.simple_waystone:waystone.settings.dropdown.organizeDimension", organizeDimension.map(value => (`ui.simple_waystone:waystone.settings.dropdown.organizeDimension.${value}`)), config.organizeDimension)
            .dropdown("ui.simple_waystone:waystone.settings.dropdown.showDimension", ["ui.simple_waystone:waystone.settings.dropdown.showDimension.all", "ui.simple_waystone:waystone.settings.dropdown.showDimension.world", "ui.simple_waystone:waystone.settings.dropdown.showDimension.nether", "ui.simple_waystone:waystone.settings.dropdown.showDimension.end"], config.showDimension)
            .dropdown("ui.simple_waystone:waystone.settings.dropdown.organizePublic", organizePublic.map(value => (`ui.simple_waystone:waystone.settings.dropdown.organizePublic.${value}`)), config.organizePublic)
            .toggle("ui.simple_waystone:waystone.settings.toggle.showPublic", config.showPublic)
            .submitButton("ui.simple_waystone:waystone.create.button")
            .show(player).then(r => {
            if (r.canceled)
                return apiWarn.notify(player, "warning.simple_waystone:waystone.cancelSettings", { type: "action_bar", sound: "simple_waystone.warn.break" });
            const options = r.formValues;
            config.organize = options[0];
            config.organizeDimension = options[1];
            config.showDimension = options[2];
            config.organizePublic = options[3];
            config.showPublic = options[4];
            player.setDynamicProperty("config", JSON.stringify(config));
            apiWarn.notify(player, "warning.simple_waystone:waystone.saveSettings", { type: "action_bar", sound: "simple_waystone.warn.levelup" });
        });
    }
    removeWaystones(player) {
        const allWaystones = apiOrganize.organizeDimension(player, apiWaystoneInfo.getWaystoneList(player, true));
        if (!allWaystones || allWaystones.length < 1)
            return;
        const myWaystones = allWaystones.filter(way => way.owner == player.id);
        if (myWaystones.length < 1)
            return apiWarn.notify(player, "warning.simple_waystone:waystone.failFindWaystones", { type: "action_bar", sound: "simple_waystone.warn.bass" });
        const form = new ActionFormData()
            .title("ui.simple_waystone:waystone.removeWaystone.title")
            .body("ui.simple_waystone:waystone.removeWaystone.body");
        myWaystones.forEach(button => { form.button({ "rawtext": [{ "text": `${colorDimension[button.world]}${button.name}§r\n` }, { "translate": `ui.simple_waystone:waystone.list.${button.type}` }] }); });
        form.show(player).then(r => {
            if (r.canceled || r.selection == undefined)
                return;
            const selected = myWaystones[r.selection];
            if (!selected)
                return;
            new MessageFormData()
                .title("ui.simple_waystone:waystone.removeWaystone.title")
                .body({ translate: "ui.simple_waystone:waystone.removeWaystone.confirm.body", with: [`${colorDimension[selected.world]}${selected.name}§r`] })
                .button1("ui.simple_waystone:waystone.no")
                .button2("ui.simple_waystone:waystone.yes")
                .show(player).then(r => {
                if (r.canceled || r.selection == 0) {
                    return apiWarn.notify(player, "warning.simple_waystone:waystone.dontDeletedWaystones", { type: "action_bar", sound: "simple_waystone.warn.break" });
                }
                removeWaystone(selected.pos, selected.world);
                apiWarn.notify(player, { translate: "warning.simple_waystone:waystone.deletedWaystones", with: [`${colorDimension[selected.world]}${selected.name}§r`] }, { type: "action_bar", sound: "simple_waystone.block.waystone.unregistered" });
            });
        });
    }
};
