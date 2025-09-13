export const apiConfig = new class apiConfig {
    constructor() {
        this.defaultConfig = {
            organize: false,
            organizeDimension: 0,
            showDimension: 0,
            organizePublic: 0,
            showPublic: true
        };
    }
    getConfig(player) {
        if (!player)
            return this.defaultConfig;
        const dynamic = player.getDynamicProperty(`config`);
        if (!dynamic || typeof dynamic != "string")
            return this.defaultConfig;
        const config = JSON.parse(dynamic);
        if (!this.isConfig(config)) {
            player.setDynamicProperty(`config`, JSON.stringify(this.defaultConfig));
            return this.defaultConfig;
        }
        return config;
    }
    setConfig(player, config) {
        player.setDynamicProperty(`config`, JSON.stringify(config));
    }
    isConfig(obj) {
        return obj &&
            typeof obj === "object" &&
            typeof obj.organize === "boolean" &&
            typeof obj.organizeDimension === "number" &&
            typeof obj.showDimension === "number" &&
            typeof obj.organizePublic === "number" &&
            typeof obj.showPublic === "boolean";
    }
};
