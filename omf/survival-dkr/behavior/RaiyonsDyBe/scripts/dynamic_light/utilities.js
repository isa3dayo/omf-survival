
//GetLightLevel

export function parseCoordinates(propertyString) {
    const regex = /^[A-Z]+,X:(-?\d+),Y:(-?\d+),Z:(-?\d+),D:([\w:]+)/;
    const match = propertyString.match(regex);

    const x = parseInt(match[1], 10);
    const y = parseInt(match[2], 10);
    const z = parseInt(match[3], 10);
    const dimension = match[4];

    return { x, y, z, dimension };
}

//Offhand
