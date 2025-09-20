// src/index.ts
import {
  Entity as Entity5,
  EntityEquippableComponent,
  EntityItemComponent as EntityItemComponent4,
  EntityOnFireComponent,
  EquipmentSlot,
  ItemStack as ItemStack4,
  Player as Player4,
  system,
  world as world5
} from "@minecraft/server";

// src/types/constants.ts
var ItemIlumination = {
  "minecraft:torch": 12,
  "minecraft:end_rod": 13,
  "minecraft:shroomlight": 11,
  "minecraft:soul_torch": 13,
  "minecraft:glowstone": 12,
  "minecraft:lantern": 11,
  "minecraft:end_crystal": 9,
  "minecraft:soul_lantern": 12,
  "minecraft:redstone_block": 4,
  "minecraft:redstone_torch": 6,
  "minecraft:glowstone_dust": 7,
  "minecraft:lit_pumpkin": 10,
  "minecraft:sea_lantern": 12,
  "minecraft:pearlescent_froglight": 10,
  "minecraft:verdant_froglight": 10,
  "minecraft:ochre_froglight": 10,
  "minecraft:crying_obsidian": 2,
  "minecraft:campfire": 12,
  "minecraft:dragon_breath": 7,
  "minecraft:ender_eye": 5,
  "minecraft:fire_charge": 7,
  "minecraft:nether_star": 8,
  "minecraft:experience_bottle": 7,
  "minecraft:soul_campfire": 13,
  "minecraft:blaze_rod": 6,
  "minecraft:enchanting_table": 9,
  "minecraft:blaze_powder": 6,
  "minecraft:ender_chest": 9,
  "minecraft:glow_ink_sac": 6,
  "minecraft:glow_berries": 6,
  "minecraft:magma": 3,
  "minecraft:glow_lichen": 6,
  "minecraft:vault": 8,
  "minecraft:beacon": 15,
  "minecraft:lava_bucket": 15
};
var EntityIlumination = {
  "minecraft:blaze": 6,
  "minecraft:glow_squid": 6,
  "minecraft:magma_cube": 3
};
var WaterLoggable = [
  "minecraft:end_rod",
  "minecraft:shroomlight",
  "minecraft:soul_lantern",
  "minecraft:glowstone_dust",
  "minecraft:glowstone",
  "minecraft:sea_lantern",
  "minecraft:pearlescent_froglight",
  "minecraft:verdant_froglight",
  "minecraft:ochre_froglight",
  "minecraft:glow_squid"
];
var TransparentBlocks = [
  "glass",
  "leaves",
  "trapdoor",
  "fence",
  "wall",
  "carpet",
  "scaffolding",
  "slab",
  // TODO: Filter,
  "stair",
  "iron_bars",
  "slime",
  "honey_block",
  "ladder",
  "bed",
  "chest",
  "grindstone",
  "anvil",
  "sign",
  "composter",
  "campfire",
  "stonecutter_block",
  "lectern",
  "shulker",
  "pot",
  "rail",
  "pressure_plate",
  "wire",
  "redstone_wire",
  "repeater",
  "comparator",
  "bell",
  "lever",
  "button",
  "banner",
  "torch",
  "lantern",
  "candle",
  "enchanting_table",
  "leaves",
  "sapling",
  "fern",
  "tall_grass",
  "short_grass",
  "vines",
  "sculk_vein",
  "sculk_shrieker",
  "sculk_sensor",
  "spawner",
  "vine",
  "bamboo_sapling",
  "azalea",
  "dripleaf",
  "snow_layer",
  "amethyst_bud",
  "amethyst_cluster",
  "egg",
  "end_portal_frame",
  "spore_blossom",
  "pointed_dripstone",
  "web",
  "chain",
  "double_plant",
  "flower",
  "wither_rose",
  "pitcher_plant",
  "pink_petals",
  "eyeblossom",
  "air",
  "light_block"
];
var HeartBeatedLights = [
  "torch",
  "lit_pumpkin",
  "minecraft:lantern",
  "minecraft:soul_lantern",
  "campfire",
  "minecraft:magma"
];

// src/systems/tiers/high/index.ts
import { MemoryTier } from "@minecraft/server";

// src/systems/tiers/high/heart-beat.ts
import { BlockPermutation as BlockPermutation2, world as world2 } from "@minecraft/server";

// src/systems/tiers/high/ilumination.ts
import {
  BlockPermutation,
  Entity,
  EntityItemComponent,
  Player,
  world
} from "@minecraft/server";

// src/vector.ts
var Vector = class _Vector {
  x;
  y;
  z;
  constructor(x, y, z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
  static floor(vector) {
    return {
      x: Math.floor(vector.x),
      y: Math.floor(vector.y),
      z: Math.floor(vector.z)
    };
  }
  static equals(vectorA, vectorB) {
    return JSON.stringify(_Vector.floor(vectorA)) === JSON.stringify(_Vector.floor(vectorB));
  }
  static vectorLength(vector) {
    return Math.sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z);
  }
  static multiply(vectorA, value) {
    return {
      x: vectorA.x * (typeof value === "number" ? value : value.x ?? 1),
      y: vectorA.y * (typeof value === "number" ? value : value.y ?? 1),
      z: vectorA.z * (typeof value === "number" ? value : value.z ?? 1)
    };
  }
  static add(vectorA, vectorB) {
    return {
      x: vectorA.x + (vectorB.x ?? 0),
      y: vectorA.y + (vectorB.y ?? 0),
      z: vectorA.z + (vectorB.z ?? 0)
    };
  }
  static absolute(vector) {
    return {
      x: Math.abs(vector.x),
      y: Math.abs(vector.y),
      z: Math.abs(vector.z)
    };
  }
  static subtract(vectorA, vectorB) {
    return {
      x: vectorA.x - (vectorB.x ?? 0),
      y: vectorA.y - (vectorB.y ?? 0),
      z: vectorA.z - (vectorB.z ?? 0)
    };
  }
  static distance(vectorA, vectorB) {
    return Math.hypot(vectorA.x - vectorB.x, vectorA.y - vectorB.y, vectorA.z - vectorB.z);
  }
  static normalize(vector) {
    const len = _Vector.vectorLength(vector);
    return new _Vector(vector.x / len, vector.y / len, vector.z / len);
  }
};

// src/systems/tiers/high/ilumination.ts
var LightingEngine = class _LightingEngine {
  lights;
  source;
  center;
  isWaterLoggable;
  maxIlumination;
  constructor(source) {
    if (source instanceof Entity) {
      const entityItemComponent = source.getComponent(EntityItemComponent.componentId);
      const itemStack2 = entityItemComponent?.itemStack;
      const sourceDimension = world.getDimension(source.dimension.id);
      this.source = { entity: source, itemStack: itemStack2, dimension: sourceDimension };
    } else
      this.source = source;
    const { entity, itemStack } = this.source;
    this.maxIlumination = ItemIlumination[itemStack?.typeId ?? ""] ?? EntityIlumination[entity.typeId] ?? 12;
    this.isWaterLoggable = WaterLoggable.includes(itemStack?.typeId ?? entity.typeId);
    this.center = Vector.floor(this.source.entity.location);
    this.lights = /* @__PURE__ */ new Set();
  }
  onInterval() {
    const { entity, dimension } = this.source;
    if (!entity?.isValid())
      return this.clear();
    if (!Vector.equals(this.center, Vector.floor(entity.location)) || this.lights.size == 0)
      this.onPositionUpdate();
    for (const light of this.lights) {
      light.update(dimension, {
        waterLoggable: this.isWaterLoggable
      });
    }
    if (dimension.id !== entity.dimension.id)
      this.source.dimension = world.getDimension(entity?.dimension.id ?? "overworld");
  }
  onPositionUpdate() {
    const { entity } = this.source;
    this.clear();
    if (!entity?.isValid())
      return;
    this.center = Vector.floor(entity.location);
    this.computeLights();
  }
  clear() {
    for (const light of this.lights) {
      const lightBlock = this.source.dimension.getBlock(light.position);
      if (lightBlock?.typeId.includes("light_block")) {
        lightBlock.setType(lightBlock.typeId.includes("water") ? lightBlock.typeId : "minecraft:air");
      }
    }
    this.lights.clear();
  }
  computeLights() {
    for (let y = this.center.y; y <= this.center.y + 1; y++) {
      for (let x = this.center.x - 1; x <= this.center.x + 1; x++) {
        for (let z = this.center.z - 1; z <= this.center.z + 1; z++) {
          const position = { x, y, z };
          const block = this.source.dimension.getBlock(position);
          if (!block)
            continue;
          if (Vector.equals(this.center, position)) {
            const isWaterFlow = this.isWaterLoggable && block.permutation.getState("water_depth") != 0;
            if (!_LightingEngine.isUpdatable(block, this.isWaterLoggable) && !isWaterFlow)
              return;
            this.addLight(block);
            continue;
          }
          if (!_LightingEngine.isUpdatable(block, this.isWaterLoggable))
            continue;
          const direction = { x: 0, z: 0, y: Math.sign(y - this.center.y) };
          if (x !== this.center.x)
            direction.x = Math.sign(x - this.center.x);
          else
            direction.z = Math.sign(z - this.center.z);
          const blockAbove = this.source.dimension.getBlock({
            x: direction.x !== 0 ? this.center.x : x,
            y,
            z: direction.z !== 0 ? this.center.z : z
          });
          const sideBlock = this.source.dimension.getBlock({ x, y: this.center.y, z });
          if (!_LightingEngine.isUpdatable(blockAbove, this.isWaterLoggable) && !_LightingEngine.isUpdatable(sideBlock, this.isWaterLoggable))
            continue;
          this.rayCast(direction);
        }
      }
    }
  }
  rayCast(direction) {
    let currentPosition = { ...this.center };
    const { dimension, entity } = this.source;
    const maxStep = entity instanceof Player ? 2 : 1;
    for (let _ = 0; _ < maxStep; _++) {
      currentPosition.x += direction.x;
      currentPosition.z += direction.z;
      currentPosition.y += direction.y;
      currentPosition = Vector.floor(currentPosition);
      const blockAtPosition = dimension.getBlock(currentPosition);
      if (!blockAtPosition || !_LightingEngine.isRaycastable(blockAtPosition, this.isWaterLoggable))
        break;
      this.addLight(blockAtPosition);
    }
  }
  addLight(block, lightIntensity) {
    this.lights.add(
      new Light(block.location, {
        maxIntensity: this.maxIlumination,
        lightIntensity
      })
    );
  }
  get sourceItem() {
    return this.source?.itemStack;
  }
  static isUpdatable(block, waterLogableSource) {
    if (!block)
      return false;
    const { typeId } = block;
    const canIluminateUnderwater = waterLogableSource && block.permutation.getState("liquid_depth") == 0;
    return typeId.includes("light_block") || block.isAir || canIluminateUnderwater;
  }
  static isRaycastable(block, waterLogableSource) {
    const { typeId } = block;
    if (!waterLogableSource && typeId.includes("water"))
      return true;
    return TransparentBlocks.some((typeId2) => typeId2.includes(typeId2));
  }
};
var Light = class {
  position;
  lightIntensity;
  maxIntensity;
  constructor(position, lightOptions) {
    this.position = position;
    this.maxIntensity = lightOptions.maxIntensity;
    this.lightIntensity = lightOptions.lightIntensity ?? this.maxIntensity;
  }
  update(dimension, lightUpdateOptions) {
    const block = dimension.getBlock(this.position);
    const { waterLoggable } = lightUpdateOptions;
    if (!block || !LightingEngine.isUpdatable(block, waterLoggable ?? false))
      return;
    block.setPermutation(
      BlockPermutation.resolve("minecraft:light_block", {
        block_light_level: lightUpdateOptions.lightIntensity ?? this.lightIntensity
      })
    );
    if (block.typeId.includes("water"))
      block.setWaterlogged(true);
  }
};

// src/systems/tiers/high/heart-beat.ts
var HeartBeatLightEngine = class extends LightingEngine {
  minIlumination;
  lights;
  constructor(source) {
    super(source);
    this.minIlumination = Math.floor(this.maxIlumination / 2);
    this.lights = /* @__PURE__ */ new Set();
  }
  onInterval() {
    const { entity, dimension } = this.source;
    if (!entity.isValid())
      return this.clear();
    if (!Vector.equals(this.center, Vector.floor(entity.location)) || this.lights.size == 0)
      this.onPositionUpdate();
    try {
      for (const light of this.lights) {
        const random = Math.random();
        const entityVelocity = entity.getVelocity();
        const entityIsMoving = entityVelocity.x > 0 || entityVelocity.y > 0 || entityVelocity.z > 0;
        const updatable = random <= 0.6 && entityIsMoving;
        if (!updatable && light.placed)
          continue;
        light.update(dimension, {
          waterLoggable: this.isWaterLoggable,
          updateIntensity: updatable,
          lightIntensity: !entityIsMoving && !light.placed ? this.maxIlumination : Math.round(this.lerp(this.maxIlumination, light.lightIntensity, 0.5))
        });
      }
    } catch {
    }
    if (dimension.id !== entity.dimension.id)
      this.source.dimension = world2.getDimension(entity?.dimension.id ?? "overworld");
  }
  addLight(block, lightIntensity) {
    this.lights.add(
      new HeartBeatLight(block.location, {
        stoking: true,
        maxIntensity: this.maxIlumination,
        minIntensity: this.minIlumination,
        lightIntensity
      })
    );
  }
  lerp(x, y, t) {
    return (1 - t) * x + t * y;
  }
};
var HeartBeatLight = class extends Light {
  stoking;
  placed = false;
  minIntensity;
  constructor(position, options) {
    super(position, options);
    const { stoking, minIntensity, lightIntensity } = options;
    this.position = position;
    this.stoking = stoking;
    this.minIntensity = minIntensity;
    this.lightIntensity = lightIntensity ?? stoking ? minIntensity : this.maxIntensity;
    if (Math.random() <= 0.4)
      this.updateLightIntensity();
  }
  toggleStoking() {
    this.stoking = !this.stoking;
  }
  updateLightIntensity() {
    const sign = this.stoking ? 2 : -2;
    const limit = this.stoking ? this.maxIntensity : this.minIntensity;
    this.lightIntensity = this.lightIntensity + sign;
    if (Math.abs(limit - this.lightIntensity) <= 0)
      this.toggleStoking();
  }
  update(dimension, lightUpdateOptions) {
    const block = dimension.getBlock(this.position);
    const { waterLoggable, updateIntensity } = lightUpdateOptions;
    if (!block || !HeartBeatLightEngine.isUpdatable(block, waterLoggable))
      return false;
    if (updateIntensity)
      this.updateLightIntensity();
    if (!this.placed)
      this.placed = true;
    block.setPermutation(
      BlockPermutation2.resolve("minecraft:light_block", {
        block_light_level: lightUpdateOptions.lightIntensity ?? this.lightIntensity
      })
    );
    return true;
  }
};

// src/systems/tiers/high/index.ts
var lightEngineTier = {
  tiers: /* @__PURE__ */ new Set([MemoryTier.High, MemoryTier.SuperHigh]),
  capabilities: /* @__PURE__ */ new Set([
    2 /* DynamicLight */,
    1 /* EntityLight */,
    0 /* HeartBeat */
  ]),
  heartBeat: HeartBeatLightEngine,
  lightingEngine: LightingEngine
};

// src/systems/tiers/mid/index.ts
import { MemoryTier as MemoryTier2 } from "@minecraft/server";

// src/systems/tiers/mid/ilumination.ts
import {
  BlockPermutation as BlockPermutation3,
  Entity as Entity3,
  EntityItemComponent as EntityItemComponent2,
  Player as Player2,
  world as world3
} from "@minecraft/server";
var LightingEngine2 = class _LightingEngine {
  lights;
  source;
  center;
  isWaterLoggable;
  maxIlumination;
  constructor(source) {
    if (source instanceof Entity3) {
      const entityItemComponent = source.getComponent(EntityItemComponent2.componentId);
      const itemStack2 = entityItemComponent?.itemStack;
      const sourceDimension = world3.getDimension(source.dimension.id);
      this.source = { entity: source, itemStack: itemStack2, dimension: sourceDimension };
    } else
      this.source = source;
    const { entity, itemStack } = this.source;
    this.maxIlumination = ItemIlumination[itemStack?.typeId ?? ""] ?? EntityIlumination[entity.typeId] ?? 0;
    this.isWaterLoggable = WaterLoggable.includes(itemStack?.typeId ?? entity.typeId);
    this.center = Vector.floor(this.source.entity.location);
    this.lights = /* @__PURE__ */ new Set();
  }
  onInterval() {
    const { entity, dimension } = this.source;
    if (!entity?.isValid())
      return this.clear();
    if (!Vector.equals(this.center, Vector.floor(entity.location)) || this.lights.size == 0)
      this.onPositionUpdate();
    for (const light of this.lights) {
      light.update(dimension, {
        waterLoggable: this.isWaterLoggable
      });
    }
    if (dimension.id !== entity.dimension.id)
      this.source.dimension = world3.getDimension(entity?.dimension.id ?? "overworld");
  }
  onPositionUpdate() {
    const { entity } = this.source;
    this.clear();
    if (!entity?.isValid())
      return;
    this.center = Vector.floor(entity.location);
    this.computeLights();
  }
  clear() {
    for (const light of this.lights) {
      const lightBlock = this.source.dimension.getBlock(light.position);
      if (lightBlock?.typeId.includes("light_block")) {
        lightBlock.setType(lightBlock.typeId.includes("water") ? lightBlock.typeId : "minecraft:air");
      }
    }
    this.lights.clear();
  }
  computeLights() {
    for (let y = this.center.y; y <= this.center.y + 1; y++) {
      for (let x = this.center.x - 1; x <= this.center.x + 1; x++) {
        for (let z = this.center.z - 1; z <= this.center.z + 1; z++) {
          const position = { x, y, z };
          const block = this.source.dimension.getBlock(position);
          if (!block)
            continue;
          if (Vector.equals(this.center, position)) {
            const isWaterFlow = this.isWaterLoggable && block.permutation.getState("water_depth") != 0;
            if (!_LightingEngine.isUpdatable(block, this.isWaterLoggable) && !isWaterFlow)
              return;
            this.addLight(block);
            continue;
          }
          if (!_LightingEngine.isUpdatable(block, this.isWaterLoggable))
            continue;
          const direction = { x: 0, z: 0, y: Math.sign(y - this.center.y) };
          if (x !== this.center.x)
            direction.x = Math.sign(x - this.center.x);
          else
            direction.z = Math.sign(z - this.center.z);
          const blockAbove = this.source.dimension.getBlock({
            x: direction.x !== 0 ? this.center.x : x,
            y,
            z: direction.z !== 0 ? this.center.z : z
          });
          const sideBlock = this.source.dimension.getBlock({ x, y: this.center.y, z });
          if (!_LightingEngine.isUpdatable(blockAbove, this.isWaterLoggable) && !_LightingEngine.isUpdatable(sideBlock, this.isWaterLoggable))
            continue;
          this.rayCast(direction);
        }
      }
    }
  }
  rayCast(direction) {
    let currentPosition = { ...this.center };
    const { dimension, entity } = this.source;
    const maxStep = entity instanceof Player2 ? 2 : 1;
    for (let _ = 0; _ < maxStep; _++) {
      currentPosition.x += direction.x;
      currentPosition.z += direction.z;
      currentPosition.y += direction.y;
      currentPosition = Vector.floor(currentPosition);
      const blockAtPosition = dimension.getBlock(currentPosition);
      if (!blockAtPosition || !_LightingEngine.isRaycastable(blockAtPosition, this.isWaterLoggable))
        break;
      this.addLight(blockAtPosition);
    }
  }
  addLight(block, lightIntensity) {
    this.lights.add(
      new Light2(block.location, {
        maxIntensity: this.maxIlumination,
        lightIntensity
      })
    );
  }
  get sourceItem() {
    return this.source?.itemStack;
  }
  static isUpdatable(block, waterLogableSource) {
    if (!block)
      return false;
    const { typeId } = block;
    const canIluminateUnderwater = waterLogableSource && block.permutation.getState("liquid_depth") == 0;
    return typeId.includes("light_block") || block.isAir || canIluminateUnderwater;
  }
  static isRaycastable(block, waterLogableSource) {
    const { typeId } = block;
    if (!waterLogableSource && (typeId.includes("water") || block.isWaterlogged))
      return true;
    return TransparentBlocks.some((typeId2) => typeId2.includes(typeId2));
  }
};
var Light2 = class {
  position;
  lightIntensity;
  maxIntensity;
  constructor(position, lightOptions) {
    this.position = position;
    this.maxIntensity = lightOptions.maxIntensity;
    this.lightIntensity = lightOptions.lightIntensity ?? this.maxIntensity;
  }
  update(dimension, lightUpdateOptions) {
    const block = dimension.getBlock(this.position);
    const { waterLoggable } = lightUpdateOptions;
    if (!block || !LightingEngine2.isUpdatable(block, waterLoggable ?? false))
      return;
    block.setPermutation(
      BlockPermutation3.resolve("minecraft:light_block", {
        block_light_level: lightUpdateOptions.lightIntensity ?? this.lightIntensity
      })
    );
    if (block.typeId.includes("water"))
      block.setWaterlogged(true);
  }
};

// src/systems/tiers/mid/index.ts
var lightEngineTier2 = {
  tiers: /* @__PURE__ */ new Set([MemoryTier2.Mid]),
  capabilities: /* @__PURE__ */ new Set([
    2 /* DynamicLight */,
    1 /* EntityLight */
  ]),
  lightingEngine: LightingEngine2
};

// src/systems/tiers/low/index.ts
import { MemoryTier as MemoryTier3 } from "@minecraft/server";

// src/systems/tiers/low/ilumination.ts
import {
  BlockPermutation as BlockPermutation4,
  Entity as Entity4,
  EntityItemComponent as EntityItemComponent3,
  Player as Player3,
  world as world4
} from "@minecraft/server";
var LightingEngine3 = class _LightingEngine {
  lights;
  source;
  center;
  isWaterLoggable;
  maxIlumination;
  constructor(source) {
    if (source instanceof Entity4) {
      const entityItemComponent = source.getComponent(EntityItemComponent3.componentId);
      const itemStack2 = entityItemComponent?.itemStack;
      if (!itemStack2)
        return;
      const sourceDimension = world4.getDimension(source.dimension.id);
      this.source = { entity: source, itemStack: itemStack2, dimension: sourceDimension };
    } else
      this.source = source;
    const { entity, itemStack } = this.source;
    this.maxIlumination = ItemIlumination[itemStack?.typeId ?? ""] ?? EntityIlumination[entity.typeId] ?? 0;
    this.isWaterLoggable = WaterLoggable.includes(itemStack?.typeId ?? entity.typeId);
    this.center = Vector.floor(this.source.entity.location);
    this.lights = /* @__PURE__ */ new Set();
  }
  onInterval() {
    const { entity, dimension } = this.source;
    if (!entity?.isValid())
      return this.clear();
    if (!Vector.equals(this.center, Vector.floor(entity.location)) || this.lights.size == 0)
      this.onPositionUpdate();
    for (const light of this.lights) {
      light.update(dimension, {
        waterLoggable: this.isWaterLoggable
      });
    }
    if (dimension.id !== entity.dimension.id)
      this.source.dimension = world4.getDimension(entity?.dimension.id ?? "overworld");
  }
  onPositionUpdate() {
    const { entity } = this.source;
    this.clear();
    if (!entity?.isValid())
      return;
    this.center = Vector.floor(entity.location);
    this.computeLights();
  }
  clear() {
    for (const light of this.lights) {
      const lightBlock = this.source.dimension.getBlock(light.position);
      if (lightBlock?.typeId.includes("light_block")) {
        lightBlock.setType(lightBlock.typeId.includes("water") ? lightBlock.typeId : "minecraft:air");
      }
    }
    this.lights.clear();
  }
  computeLights() {
    for (let y = this.center.y; y <= this.center.y + 1; y++) {
      for (let x = this.center.x - 1; x <= this.center.x + 1; x++) {
        for (let z = this.center.z - 1; z <= this.center.z + 1; z++) {
          const position = { x, y, z };
          const block = this.source.dimension.getBlock(position);
          if (!block)
            continue;
          if (Vector.equals(this.center, position)) {
            const isWaterFlow = this.isWaterLoggable && block.permutation.getState("water_depth") != 0;
            if (!_LightingEngine.isUpdatable(block, this.isWaterLoggable) && !isWaterFlow)
              return;
            this.addLight(block);
            continue;
          }
          if (!_LightingEngine.isUpdatable(block, this.isWaterLoggable))
            continue;
          const direction = { x: 0, z: 0, y: Math.sign(y - this.center.y) };
          if (x !== this.center.x)
            direction.x = Math.sign(x - this.center.x);
          else
            direction.z = Math.sign(z - this.center.z);
          const blockAbove = this.source.dimension.getBlock({
            x: direction.x !== 0 ? this.center.x : x,
            y,
            z: direction.z !== 0 ? this.center.z : z
          });
          const sideBlock = this.source.dimension.getBlock({ x, y: this.center.y, z });
          if (!_LightingEngine.isUpdatable(blockAbove, this.isWaterLoggable) && !_LightingEngine.isUpdatable(sideBlock, this.isWaterLoggable))
            continue;
          this.rayCast(direction);
        }
      }
    }
  }
  rayCast(direction) {
    let currentPosition = { ...this.center };
    const { dimension, entity } = this.source;
    const maxStep = entity instanceof Player3 ? 2 : 1;
    for (let _ = 0; _ < maxStep; _++) {
      currentPosition.x += direction.x;
      currentPosition.z += direction.z;
      currentPosition.y += direction.y;
      currentPosition = Vector.floor(currentPosition);
      const blockAtPosition = dimension.getBlock(currentPosition);
      if (!blockAtPosition || !_LightingEngine.isRaycastable(blockAtPosition, this.isWaterLoggable))
        break;
      this.addLight(blockAtPosition);
    }
  }
  addLight(block, lightIntensity) {
    this.lights.add(
      new Light3(block.location, {
        maxIntensity: this.maxIlumination,
        lightIntensity
      })
    );
  }
  get sourceItem() {
    return this.source?.itemStack;
  }
  static isUpdatable(block, waterLogableSource) {
    if (!block)
      return false;
    const { typeId } = block;
    const canIluminateUnderwater = waterLogableSource && block.permutation.getState("liquid_depth") == 0;
    return typeId.includes("light_block") || block.isAir || canIluminateUnderwater;
  }
  static isRaycastable(block, waterLogableSource) {
    const { typeId } = block;
    if (!waterLogableSource && (typeId.includes("water") || block.isWaterlogged))
      return true;
    return TransparentBlocks.some((typeId2) => typeId2.includes(typeId2));
  }
};
var Light3 = class {
  position;
  lightIntensity;
  maxIntensity;
  constructor(position, lightOptions) {
    this.position = position;
    this.maxIntensity = lightOptions.maxIntensity;
    this.lightIntensity = lightOptions.lightIntensity ?? this.maxIntensity;
  }
  update(dimension, lightUpdateOptions) {
    const block = dimension.getBlock(this.position);
    const { waterLoggable } = lightUpdateOptions;
    if (!block || !LightingEngine3.isUpdatable(block, waterLoggable ?? false))
      return;
    block.setPermutation(
      BlockPermutation4.resolve("minecraft:light_block", {
        block_light_level: lightUpdateOptions.lightIntensity ?? this.lightIntensity
      })
    );
    if (block.typeId.includes("water"))
      block.setWaterlogged(true);
  }
};

// src/systems/tiers/low/index.ts
var lightEngineTier3 = {
  tiers: /* @__PURE__ */ new Set([MemoryTier3.SuperLow, MemoryTier3.Low]),
  capabilities: /* @__PURE__ */ new Set([
    2 /* DynamicLight */
  ]),
  lightingEngine: LightingEngine3
};

// src/systems/index.ts
var engines = [lightEngineTier, lightEngineTier2, lightEngineTier3];
function getIluminationSystem(memoryTier) {
  for (const engine of engines) {
    if (engine.tiers.has(memoryTier))
      return engine;
  }
  return lightEngineTier3;
}

// src/index.ts
var LightEngineTier = getIluminationSystem(system.serverSystemInfo.memoryTier);
var IluminationEngines = /* @__PURE__ */ new Map();
var iluminatedEntities = Object.keys(EntityIlumination);
var iluminatedItems = Object.keys(ItemIlumination);
system.runInterval(() => {
  for (const player of world5.getPlayers()) {
    handleEntity(player);
    if (!LightEngineTier.capabilities.has(1 /* EntityLight */))
      continue;
    const renderableEntities = player.dimension.getEntities({
      location: player.location,
      maxDistance: 300,
      excludeTypes: ["minecraft:player"]
    });
    for (const entity of renderableEntities) {
      const engine = IluminationEngines.get(entity.id);
      if (!iluminatedEntities.includes(entity.typeId) && !entity.hasComponent(EntityOnFireComponent.componentId)) {
        const itemStack = entity.getComponent(EntityItemComponent4.componentId)?.itemStack;
        if (!itemStack || !iluminatedItems.includes(itemStack.typeId) && !itemEmitsLight(itemStack)) {
          engine?.clear();
          continue;
        }
      }
      handleEntity(entity);
    }
  }
  for (const [entityId, engine] of IluminationEngines) {
    if (world5.getEntity(entityId))
      continue;
    engine.clear();
    IluminationEngines.delete(entityId);
  }
}, 2);
function handleEntity(entity) {
  let engine;
  if (entity instanceof Player4) {
    const playerEquipment = entity.getComponent(EntityEquippableComponent.componentId);
    const mainHand = playerEquipment.getEquipment(EquipmentSlot.Mainhand);
    if (!mainHand || !iluminatedItems.includes(mainHand.typeId) && !itemEmitsLight(mainHand)) {
      const engine2 = IluminationEngines.get(entity.id);
      return engine2?.clear();
    }
    engine = constructLightEngine({ entity, itemStack: mainHand, dimension: world5.getDimension(entity.dimension.id) });
  } else
    engine = constructLightEngine(entity);
  if (!engine)
    return;
  IluminationEngines.set(entity.id, engine);
  engine?.onInterval();
}
function itemEmitsLight(itemStack) {
  const itemTags = itemStack.getTags();
  const dynamicLightTag = itemTags.find((tag) => tag.startsWith("dynamic_light:"));
  return dynamicLightTag !== void 0;
}
function isHeartbeated(source) {
  if (!LightEngineTier.capabilities.has(0 /* HeartBeat */))
    return false;
  if (!source)
    return false;
  if (source instanceof Entity5) {
    return source.hasComponent(EntityOnFireComponent.componentId);
  }
  return HeartBeatedLights.some((keyword) => source.typeId.includes(keyword)) || source.hasTag("heartbeat_lighting");
}
function constructLightEngine(source) {
  const entity = source instanceof Entity5 ? source : source.entity;
  const lightEngine = IluminationEngines.get(entity.id);
  const sourceItem = lightEngine?.sourceItem?.typeId;
  if (lightEngine && (source instanceof Entity5 || sourceItem == source?.itemStack?.typeId)) {
    return lightEngine;
  }
  const entityOnFire = entity.hasComponent(EntityOnFireComponent.componentId);
  const itemStack = getItem(source instanceof Entity5 ? source : source?.itemStack);
  if (!itemStack && !iluminatedEntities.includes(entity.typeId) && !entityOnFire)
    return;
  lightEngine?.clear();
  if (isHeartbeated(itemStack ?? entity) && LightEngineTier.heartBeat)
    return new LightEngineTier.heartBeat(source);
  return new LightEngineTier.lightingEngine(source);
}
function getItem(source) {
  if (!source)
    return;
  if (source instanceof ItemStack4)
    return source;
  const entityItemComponent = source.getComponent(EntityItemComponent4.componentId);
  return entityItemComponent?.itemStack;
}
