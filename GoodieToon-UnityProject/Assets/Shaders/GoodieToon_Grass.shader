// Unlit Shader
// (c) Yaroslav Stadnyk

Shader "Goodie Toon/Grass"
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

	    [Space(10)] [Header(Grass)]
    	[Space(10)] _TopColor("Top Color", Color) = (0.65, 0.9, 0.35, 1)
		_BottomColor("Bottom Color", Color) = (0.12, 0.5, 0.35, 1)

	    [Space(10)] _TessellationUniform("Tessellation", Float) = 10

	    [Space(10)] _HeightMin("Height Min", Float) = 0.2
		_HeightMax("Height Max", Float) = 0.5

    	[Space(10)] _WidthMin("Width Min", Float) = 0.02
		_WidthMax("Width Max", Float) = 0.05

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
        [Space(10)] _RotationMin("Grass Rotation Min", Float) = 0.0
    	_RotationMax("Grass Rotation Max", Float) = 0.5
	    _RotationSpeed("Grass Rotation Speed", Float) = 5.0

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

	    Cull Off

    	CGINCLUDE

    	#include "GoodieToonFunctions.cginc"
    	#include "GoodieToonUtilities.cginc"
    	#include "GoodieToonTessellation.cginc"

    	sampler2D _MainTex;
    	half4 _MainTex_ST;
    	half4 _Color;

    	sampler2D _ShadowTex;
    	half4 _ShadowTex_ST;
    	half4 _ShadowColor;

    	half _Lit;
    	half _Smooth;
    	half _Offset;

    	ENDCG

	    Pass
    	{
			CGINCLUDE

			half _RotationMin;
			half _RotationMax;
			half _RotationSpeed;

			half _HeightMin;
			half _HeightMax;	

			half _WidthMin;
			half _WidthMax;

			v2f geo_vert(v2g v, half4 vertex, half2 texcoord)
			{
                v2f o;
                o.pos = UnityObjectToClipPos(vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.normal = v.normal;
                o.uv = TRANSFORM_TEX(texcoord, _MainTex);
                o.uv_shadow = TRANSFORM_TEX(texcoord, _ShadowTex);
                o.view = WorldSpaceViewDir(vertex);
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                UNITY_TRANSFER_FOG(o, o.pos);
                return o;
			}

			[maxvertexcount(3)]
			void geo(triangle v2g IN[3], inout TriangleStream<v2f> OUT)
			{
				half4 vertex = IN[0].vertex;
				half3 normal = IN[0].normal;
				half4 tangent = IN[0].tangent;
				half3 binormal = cross(normal, tangent) * tangent.w;

				half3x3 transformationMatrix = half3x3
				(
					tangent.x, binormal.x, normal.x,
					tangent.y, binormal.y, normal.y,
					tangent.z, binormal.z, normal.z
				);

				half randValueXYZ = Random(vertex.xyz);
				half randValueYZX = Random(vertex.yzx);

				half bendRotation = _RotationMin + randValueYZX * (_RotationMax - _RotationMin);
				half windRotation = sin(_Time * _RotationSpeed * randValueYZX + randValueXYZ);
				half height = _HeightMin + randValueXYZ * (_HeightMax - _HeightMin);
				half width = _WidthMin + randValueXYZ * (_WidthMax - _WidthMin);

				half3x3 bendRotationMatrix = AngleAxis3x3(bendRotation * windRotation * UNITY_HALF_PI, half3(1, 0, 0));
				half3x3 facingRotationMatrix = AngleAxis3x3(randValueXYZ * UNITY_TWO_PI, half3(0, 0, 1));

				transformationMatrix = mul(mul(transformationMatrix, facingRotationMatrix), bendRotationMatrix);

				OUT.Append(geo_vert(IN[0], vertex + half4(mul(transformationMatrix, half3(width, 0, 0)), 0), half2(0, 0)));
				OUT.Append(geo_vert(IN[0], vertex + half4(mul(transformationMatrix, half3(-width, 0, 0)), 0), half2(1, 0)));
				OUT.Append(geo_vert(IN[0], vertex + half4(mul(transformationMatrix, half3(0, 0, height)), 0), half2(0.5, 1)));
			}

			ENDCG
        }

	    Pass 
        { 
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #pragma geometry geo
            #pragma hull hull
			#pragma domain domain

            half4 _TopColor;
			half4 _BottomColor;

            half4 frag(v2f i) : COLOR
            {
            	half4 color = lerp(_BottomColor, _TopColor, i.uv.y);
                half3 surface = calc_surface(color.rgb, i.worldNormal, _Lit, _ShadowColor, _Smooth, _Offset);
                surface = calc_shadow(surface, i, _ShadowColor);

                UNITY_APPLY_FOG(i.fogCoord, surface);
                
                return half4(surface.x, surface.g, surface.b, color.a);
            }

            ENDCG
        }

	    UsePass "Goodie Toon/Default/SURFACE"
    }

	Fallback "VertexLit"
}