// This file will execute once time, only to convert the old saved waystones to the new format
import { world, system } from "@minecraft/server";
system.runTimeout(() => {
    const dynamics = world.getDynamicPropertyIds();
    if (!dynamics.includes("sw:7.0"))
        return convert_v7_0();
    if (!dynamics.includes("sw:7.3"))
        return convert_v7_3();
}, 1);
function convert_v7_0() {
    const allDynamics = world.getDynamicPropertyIds().filter(id => id.startsWith("ws:waystone"));
    for (const waystonePoints of allDynamics) {
        const dynamic = world.getDynamicProperty(waystonePoints);
        if (typeof dynamic != "string")
            continue;
        const allWaystones = JSON.parse(dynamic);
        for (const waystone of allWaystones)
            world.setDynamicProperty(`simple_waystone:${waystone[4]}:${waystone[2]}:${waystone[1][0]},${waystone[1][1]},${waystone[1][2]}`, JSON.stringify({ name: waystone[0], owner: waystone[3] }));
        world.setDynamicProperty(waystonePoints, undefined);
    }
    const allWaystone = world.getDynamicPropertyIds().filter(id => id.startsWith("simple_waystone:private:") || id.startsWith("simple_waystone:public:"));
    const allClaimWaystone = world.getDynamicPropertyIds().filter(id => id.startsWith("ws:{'x':"));
    for (const claimWay of allClaimWaystone) {
        const dynamic = world.getDynamicProperty(claimWay);
        if (typeof dynamic != "string")
            continue;
        const allPlayers = JSON.parse(dynamic);
        const match = claimWay.match(/\{.*?\}/);
        const pos = JSON.parse((match ? match[0] : "").replaceAll("'", "\""));
        const oldWaystone = allWaystone.find(id => id.endsWith(`:${pos.x},${pos.y},${pos.z}`));
        const dimension = oldWaystone ? (oldWaystone.split(":")[3] ? `minecraft:${oldWaystone.split(":")[3]}` : "minecraft:overworld") : "minecraft:overworld";
        for (const playerId of allPlayers)
            world.setDynamicProperty(`simple_waystone:claim:${dimension}:${pos.x},${pos.y},${pos.z}:${playerId}`, 0);
        world.setDynamicProperty(claimWay, undefined);
    }
    world.setDynamicProperty("sw:7.0", true);
    convert_v7_3();
}
function convert_v7_3() {
    world.setDynamicProperty("simple_waystone:conversion_v7.0", undefined);
    const allDynamics = world.getDynamicPropertyIds().filter(id => id.startsWith("simple_waystone:"));
    for (const waystonePoints of allDynamics) {
        const dynamic = world.getDynamicProperty(waystonePoints);
        if (typeof dynamic != "string" && typeof dynamic != "number")
            continue;
        const info = typeof dynamic == "number" ? 0 : JSON.parse(dynamic);
        if (info == undefined)
            continue;
        const [prefix, access, dimensionPre, dimensionId, pos, id] = waystonePoints.split(":");
        world.setDynamicProperty(`${access}/${dimensionId}/${pos}${id ? `/${id}` : ""}`, typeof info != "number" ? `${info.owner}/${info.name}` : true);
        world.setDynamicProperty(waystonePoints, undefined);
    }
    world.setDynamicProperty("sw:7.3", true);
}
