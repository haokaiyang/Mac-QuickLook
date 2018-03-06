//
//  GLTFShaderModifierSurface_pbrSpecularGlossiness_doubleSidedWorkaround.shader
//  GLTFSceneKit
//
//  Created by magicien on 10/21/17.
//  Copyright © 2017 DarkHorse. All rights reserved.
//

constant float3 dielectricSpecular = float3(0.04, 0.04, 0.04);
constant float invDielect = 1.0 - dielectricSpecular.r;
constant float epsilon = 1e-6;

float calcPerceivedBrightness(float3 color) {
    return sqrt(0.299 * color.r * color.r + 0.587 * color.g * color.g + 0.114 * color.b * color.b);
}

float calcMetalness(float3 diffuse, float3 specular, float invSpecular) {
    float d = calcPerceivedBrightness(diffuse);
    float s = calcPerceivedBrightness(specular);
    if (s < dielectricSpecular.r) {
        return 0.0;
    }

    float a = dielectricSpecular.r;
    float b = d * invSpecular / invDielect + s - 2.0 * dielectricSpecular.r;
    float c = dielectricSpecular.r - s;
    float D = fmax(b * b - 4.0 * a * c, 0.0);
    return clamp((-b + sqrt(D)) / (2.0 * a), 0.0, 1.0);
}

#pragma arguments

float diffuseFactorR;
float diffuseFactorG;
float diffuseFactorB;
float diffuseFactorA;
float specularFactorR;
float specularFactorG;
float specularFactorB;
float emissiveFactorR;
float emissiveFactorG;
float emissiveFactorB;

#pragma body

// Use a multiply texture as a specular texture
// because a specular texture is overwritten by a metalness texture for PBR.
_surface.specular = _surface.multiply;
_surface.multiply= float4(1, 1, 1, 1);

float4 diffuse = _surface.diffuse * float4(diffuseFactorR, diffuseFactorG, diffuseFactorB, diffuseFactorA);
float3 specular = _surface.specular.rgb * float3(specularFactorR, specularFactorG, specularFactorB);
float invSpecular = 1.0 - fmax(fmax(specular.r, specular.g), specular.b);
float metalness = calcMetalness(diffuse.rgb, specular, invSpecular);
// It seems max number of arguments is 10, so omit glossinessFactor...
// float roughness = 1.0 - _surface.specular.a * glossinessFactor;
float roughness = 1.0 - _surface.specular.a;

float3 baseColorFromDiffuse = diffuse.rgb * (invSpecular / invDielect / fmax(1.0 - metalness, epsilon));
float3 baseColorFromSpecular = specular - dielectricSpecular * (1.0 - metalness) * (1.0 / fmax(metalness, epsilon));
float3 baseColor = clamp(
mix(baseColorFromDiffuse, baseColorFromSpecular, metalness * metalness),
float3(0, 0, 0),
float3(1, 1, 1));

_surface.diffuse = float4(baseColor, diffuse.a);
_surface.metalness = metalness;
_surface.roughness = roughness;
_surface.emission.rgb *= float3(emissiveFactorR, emissiveFactorG, emissiveFactorB);

if(_surface.normal.z < 0){
    _surface.normal *= -1.0;
}

