import { world, EquipmentSlot, ItemStack } from "@minecraft/server";

const swapItems = ["minecraft:torch", "minecraft:redstone_torch", "minecraft:soul_torch", "minecraft:lava_bucket"];

world.afterEvents.itemUse.subscribe(({ source, itemStack }) => {
    const p = source;
    if (!p.hasTag("ray:PlaceBlock")) {
        const equip = p.getComponent("equippable");
        const getEquipment = (slot) => equip.getEquipment(slot);

        if (itemStack?.typeId.includes("shield") || itemStack?.typeId.includes("totem_of_undying")) return;

        if (
            getEquipment(EquipmentSlot.Offhand)?.typeId.includes("shield") ||
            getEquipment(EquipmentSlot.Offhand)?.typeId.includes("totem_of_undying")
        )
            return;

        if (
            swapItems.some((w) => itemStack.typeId.includes(w)) ||
            (itemStack.typeId.includes("ray") && itemStack.typeId.includes("torch"))
        ) {
            if (getEquipment(EquipmentSlot.Offhand)) {
                equip.setEquipment(EquipmentSlot.Mainhand, getEquipment(EquipmentSlot.Offhand));
            } else {
                equip.setEquipment(EquipmentSlot.Mainhand, new ItemStack("minecraft:air"));
            }

            p.runCommand(`replaceitem entity @s slot.weapon.offhand 0 ${itemStack.typeId} ${itemStack.amount}`);
        }
    } else {
        p.removeTag("ray:PlaceBlock");
    }
});

world.afterEvents.playerPlaceBlock.subscribe(({ player }) => {
    player.addTag("ray:PlaceBlock");
});

world.afterEvents.itemStartUseOn.subscribe(({ source }) => {
    source.addTag("ray:PlaceBlock");
});
