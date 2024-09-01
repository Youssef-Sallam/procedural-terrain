#include ../includes/simplexNoise2d.glsl

uniform float uTime;
uniform float uSpeed;
uniform float uPositionFrequency;
uniform float uStrength;
uniform float uWarpedFrequency;
uniform float uWarpedStrength;

varying vec3 vPosition;
varying float vUpDot;

float getElevation(vec2 position) {
    vec2 warpedPosition = position;
    warpedPosition += uTime * uSpeed;
    warpedPosition += simplexNoise2d(warpedPosition * uWarpedFrequency * uPositionFrequency) * uWarpedStrength;

    float elevation = 0.0;
    elevation += simplexNoise2d(warpedPosition * uPositionFrequency) / 2.0;
    elevation += simplexNoise2d(warpedPosition * uPositionFrequency * 2.0) / 4.0;
    elevation += simplexNoise2d(warpedPosition * uPositionFrequency * 4.0) / 8.0;

    float elevationSign = sign(elevation);
    elevation = pow(abs(elevation), 2.0) * elevationSign;

    elevation *= uStrength;

    return elevation;
}

void main() {
    // Neighbours positions
    float shift = 0.01;
    vec3 positionA = position.xyz + vec3(shift, 0.0, 0.0);
    vec3 positionB = position.xyz + vec3(0.0, 0.0, -shift);

    // Elevation
    float elevation = getElevation(csm_Position.xz);
    csm_Position.y += elevation;
    positionA.y = getElevation(positionA.xz);
    positionB.y = getElevation(positionB.xz);

    // Calculate new normal
    vec3 toA = normalize(positionA - csm_Position);
    vec3 toB = normalize(positionB - csm_Position);
    csm_Normal = cross(toA, toB);

    // Varyings
    vPosition = csm_Position;
    vPosition.xz += uTime * uSpeed;
    vUpDot = dot(csm_Normal, vec3(0.0, 1.0, 0.0));
}