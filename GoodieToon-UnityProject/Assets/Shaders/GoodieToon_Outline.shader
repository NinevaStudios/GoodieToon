// Unlit Shader
// (c) Yaroslav Stadnyk

Shader "Goodie Toon/Outline"
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

        [Space(10)] [Header(Outline)]
        [Space(10)] _OutlineColor("Color", Color) = (0.0, 0.0, 0.0, 1.0)
        _OutlineSize("Size", float) = 0.5

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
            "RenderType" = "Opaque"
            "LightMode" = "ForwardBase"
            "PassFlags" = "OnlyDirectional"
        }

        CGINCLUDE

        #include "GoodieToonFunctions.cginc"
        #include "GoodieToonUtilities.cginc"

        half4 _OutlineColor;
        half _OutlineSize;

        ENDCG

	    UsePass "Goodie Toon/Default/SURFACE"

        Pass     
        {
            Name "OUTLINE"

            Blend Off         
            Cull Front         
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

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