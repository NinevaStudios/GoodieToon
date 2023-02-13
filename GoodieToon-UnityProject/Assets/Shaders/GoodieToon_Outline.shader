// Unlit Shader
// (c) Yaroslav Stadnyk

Shader "Goodie Toon/Outline"
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

        [Space(20)] [Header(Outline)] [Space(10)] _OutlineColor("Color", Color) = (0.0, 0.0, 0.0, 1.0)
        _OutlineSize("Size", float) = 0.5
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
        #include "GoodieToonUtilities.cginc"

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

	    UsePass "Goodie Toon/Base/PASS"

        Pass     
        {
            Name "PASS"

            Blend Off         
            Cull Front         
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            half4 _OutlineColor;
            half _OutlineSize;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex + normalize(v.vertex) * _OutlineSize / GetWorldScale());
                return o;
            }

            half4 frag(v2f i) : COLOR
            {
                return _OutlineColor;
            }         
            
            ENDCG     
        }
    }

    Fallback "VertexLit"
}