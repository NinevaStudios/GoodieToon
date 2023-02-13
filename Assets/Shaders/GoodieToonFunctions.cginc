#include "AutoLight.cginc"
#include "UnityCG.cginc"

struct v2f  // also used as g2f
{
    half4 pos : SV_POSITION;
    half3 worldNormal : NORMAL;
    half3 normal : TEXCOORD0;
    half2 uv : TEXCOORD1;
    half2 uv_shadow: TEXCOORD4;
    half3 view : TEXCOORD5;
    LIGHTING_COORDS(0, 2)
    UNITY_FOG_COORDS(3)
};


half3 calc_surface(half3 target, half3 normal, half lit = 1.0, half4 shadowColor = half4(0, 0, 0, 1), half smooth = 1.0, half offset = 0.0)
{
    half3 ownShadow = dot(_WorldSpaceLightPos0.xyz, normal) + offset;
    ownShadow = smoothstep(0.0, smooth, ownShadow);
    ownShadow = lerp(shadowColor, target, ownShadow);
    lit *= shadowColor.a;
    return lerp(target + target * lit, ownShadow * lit, lit);
}

half3 calc_shadow(half3 target, v2f vertex, half4 shadowColor = half4(0, 0, 0, 1))
{
    half3 dropShadow = LIGHT_ATTENUATION(vertex);
    return lerp(target, shadowColor, (1.0 - dropShadow) * shadowColor.a);
}

half3 calc_specular(half3 target, half3 normal, half3 viewDirection, half4 color = half4(1, 1, 1, 1), half smooth = 1.0, half size = 0.5)
{
    half3 dir = normalize(_WorldSpaceLightPos0 + normalize(viewDirection));
    half dotL = dot(normal, dir);

    half specular = pow(dotL, 1.0 / (size * size));
    specular = smoothstep(0.0, smooth + 0.0001, specular);
    return lerp(target, color, specular * color.a);
}

half3 calc_rim(half3 target, half3 normal, half3 viewDirection, half4 color = half4(1, 1, 1, 1), half smooth = 1.0, half size = 0.5)
{
    half3 rim = 1.0 - dot(viewDirection, normal);
    rim = smoothstep(-size - smooth, -size + smooth, rim);
    return lerp(target, color, rim * color.a);
}


half2 FIXED_TEX(float4 vertex, float3 normal, sampler2D _Texture, half4 _Texture_ST)
{
    half2 uv_x = TRANSFORM_TEX(mul(unity_ObjectToWorld, vertex).yz, _Texture);
    half2 uv_y = TRANSFORM_TEX(mul(unity_ObjectToWorld, vertex).xz, _Texture);
    half2 uv_z = TRANSFORM_TEX(mul(unity_ObjectToWorld, vertex).xy, _Texture);

    half2 uv_xy = lerp(uv_y, uv_x, normal.x);
    half2 uv_xyz = lerp(uv_xy, uv_z, normal.z);

    return uv_xyz;
}