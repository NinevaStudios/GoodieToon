// Unlit Shader
// (c) Yaroslav Stadnyk

Shader "Goodie Toon/Fixed"
{
    Properties
    {
        [Header(Main)] [Space(10)] _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)

        [Space(20)] [Header(Shadow)] [Space(10)] _ShadowTex ("Texture", 2D) = "white" {}
        _ShadowColor ("Color", Color) = (0.0, 0.0, 0.0, 1.0)

        [Space(10)] _Lit ("Lit", float) = 0.5
        _Smooth ("Lit Smooth", float) = 0.5
        _Offset ("Lit Offset", float) = 0.25

        [Space(20)] [Header(Specular)] [Space(10)] _SpecularColor("Color", Color) = (1.0, 1.0, 1.0, 0.05)
        _SpecularSize("Size", Float) = 0.1
        _SpecularSmooth("Smooth", Float) = 0.0

        [Space(20)] [Header(Rim)] [Space(10)] _RimColor("Color", Color) = (1.0, 1.0, 1.0, 0.05)
        _RimSize("Size", float) = 1.0
        _RimSmooth("Smooth", float) = 1.0

        [Space(20)] [Header(Animation)] [Space(10)] _MovingVector ("Moving", Vector) = (0.0, 0.0, 0.0, 0.0)
    }
    SubShader
    {
        Tags
        { 
            "RenderType" = "Opaque"
            "LightMode" = "ForwardBase"
            "PassFlags" = "OnlyDirectional"
        }
        
        CGINCLUDE

        #include "GoodieToonFunctions.cginc"

        sampler2D _MainTex;
        half4 _MainTex_ST;
        half4 _Color;

        sampler2D _ShadowTex;
        half4 _ShadowTex_ST;
        half4 _ShadowColor;

        half _Lit;
        half _Smooth;
        half _Offset;

        half4 _SpecularColor;
        half _SpecularSize;
        half _SpecularSmooth;

        half4 _RimColor;
        half _RimSize;
        half _RimSmooth;

        ENDCG

        Pass 
        { 
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            half3 _MovingVector;

            v2f vert(appdata_base v) 
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.normal = v.normal;
                o.uv = FIXED_TEX(v.vertex, v.normal, _MainTex, _MainTex_ST);
                o.uv_shadow = TRANSFORM_TEX(v.texcoord, _ShadowTex);
                o.view = WorldSpaceViewDir(v.vertex);
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                UNITY_TRANSFER_FOG(o, o.pos);
                return o;
            }

            half4 frag(v2f i) : COLOR
            {
                half3 movingOffset = sin(_MovingVector * _Time);

                half4 texColor = tex2D(_MainTex, i.uv + movingOffset) * _Color;
                half4 texShadowColor = tex2D(_ShadowTex, i.uv_shadow) * _ShadowColor;

                half3 surface = calc_surface(texColor.rgb, i.worldNormal, _Lit, texShadowColor, _Smooth, _Offset);
                surface = calc_specular(surface, i.worldNormal, i.view, _SpecularColor, _SpecularSmooth, _SpecularSize);
                surface = calc_shadow(surface, i, texShadowColor);
                surface = calc_rim(surface, i.worldNormal, i.view, _RimColor, _RimSmooth, _RimSize);

                UNITY_APPLY_FOG(i.fogCoord, surface);
                
                return half4(surface.x, surface.g, surface.b, texColor.a);
            } 

            ENDCG 
        } 
    } 
    
    Fallback "VertexLit"
}