// Unlit Shader
// (c) Yaroslav Stadnyk

Shader "Goodie Toon/Transparent"
{
    Properties
    {
        [Header(Main)]
        [Space(10)] [KeywordEnum(Local, World)] _MainTexSpace ("Texture Space", int) = 0
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)

        [Space(10)] [Header(Shadow)]
        [Space(10)] _ShadowTex ("Texture", 2D) = "white" {}
        _ShadowColor ("Color", Color) = (0.0, 0.0, 0.0, 1.0)

        [Space(10)] _Lit ("Lit", float) = 0.5
        _Smooth ("Lit Smooth", float) = 0.5
        _Offset ("Lit Offset", float) = 0.25

        [Space(10)] [Header(Specular)]
        [Space(10)] [Toggle(SPECULAR)] _Specular ("Specular Enabled", float) = 0
        _SpecularColor("Color", Color) = (1.0, 1.0, 1.0, 0.05)
        _SpecularSize("Size", Float) = 0.1
        _SpecularSmooth("Smooth", Float) = 0.0

        [Space(10)] [Header(Rim)]
        [Space(10)] [Toggle(RIM)] _Rim ("Rim Enabled", float) = 0
        _RimColor("Color", Color) = (1.0, 1.0, 1.0, 0.05)
        _RimSize("Size", float) = 1.0
        _RimSmooth("Smooth", float) = 1.0

        [Space(10)] [Header(Animations)]
        [Space(10)] [Toggle(MOVING_ANIMATION)] _MovingAnimation ("Moving Enabled", float) = 0
        _MovingVector ("Moving", Vector) = (0.0, 0.0, 0.0, 0.0)
    }
    SubShader
    {
        Tags
        { 
            "RenderType" = "Transparent"
            "LightMode" = "ForwardBase"
            "PassFlags" = "OnlyDirectional"

            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
        }

        CGINCLUDE

        #include "GoodieToonFunctions.cginc"

        // Each keyword must start with the property name followed by _<Enum Value>. All in uppercase.
        #pragma multi_compile _MAINTEXSPACE_LOCAL _MAINTEXSPACE_WORLD
        #pragma multi_compile _ SPECULAR
        #pragma multi_compile _ RIM
        #pragma multi_compile _ MOVING_ANIMATION

        sampler2D _MainTex;
        half4 _MainTex_ST;
        half4 _Color;

        sampler2D _ShadowTex;
        half4 _ShadowTex_ST;
        half4 _ShadowColor;

        half _Lit;
        half _Smooth;
        half _Offset;

        #ifdef SPECULAR
        half4 _SpecularColor;
        half _SpecularSize;
        half _SpecularSmooth;
        #endif

        #ifdef RIM
        half4 _RimColor;
        half _RimSize;
        half _RimSmooth;
        #endif

        #ifdef MOVING_ANIMATION
        half3 _MovingVector;
        #endif

        ENDCG

        Pass 
        {
            Name "SURFACE"

            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            v2f vert(appdata_base v) 
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.normal = v.normal;

                #ifdef _MAINTEXSPACE_WORLD
                o.uv = FIXED_TEX(v.vertex, v.normal, _MainTex, _MainTex_ST);
                #else
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                #endif

                o.uv_shadow = TRANSFORM_TEX(v.texcoord, _ShadowTex);
                o.view = WorldSpaceViewDir(v.vertex);
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                UNITY_TRANSFER_FOG(o, o.pos);
                return o;
            }

            half4 frag(v2f i) : COLOR
            {
                #ifdef MOVING_ANIMATION
                i.uv += _MovingVector * _Time;
                #endif

                half4 texColor = tex2D(_MainTex, i.uv) * _Color;
                half4 texShadowColor = tex2D(_ShadowTex, i.uv_shadow) * _ShadowColor;

                half3 surface = calc_surface(texColor.rgb, i.worldNormal, _Lit, texShadowColor, _Smooth, _Offset);

                #ifdef SPECULAR
                surface = calc_specular(surface, i.worldNormal, i.view, _SpecularColor, _SpecularSmooth, _SpecularSize);
                #endif

                surface = calc_shadow(surface, i, texShadowColor);

                #ifdef RIM
                surface = calc_rim(surface, i.worldNormal, i.view, _RimColor, _RimSmooth, _RimSize);
                #endif

                UNITY_APPLY_FOG(i.fogCoord, surface);

                return half4(surface.x, surface.g, surface.b, texColor.a);
            }

            ENDCG 
        } 
    } 
    
    Fallback "VertexLit"
}

