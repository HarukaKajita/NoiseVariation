﻿Shader "Noise/NoiseTexture"
{
    Properties
    {
        _NoiseScale ("Noise Scale", Range(0,100)) = 10
        [Enum(value, 0, perlin, 1, cellular, 2)]
        _NoiseType ("Noise Type", int) = 0

        [Toggle] _Use2ndNoise ("Use 2nd Noise", int) = 0
        [Enum(fbm, 0, Curl, 1, Gradient, 2, Divergence, 3, laplacian, 4)]
        _2ndNoiseType ("2nd Noise Type", int) = 0

        [Toggle] _Use3rdNoise ("Use 3rd Noise", int) = 0
        [Enum(fbm, 0, Curl, 1, Gradient, 2, Divergence, 3, laplacian, 4)]
        _3rdNoiseType ("3rd Noise Type", int) = 0
        
        _NoiseAmp ("Noise Amp", Range(0,20)) = 10
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Assets/Kajita/cginc/Noise.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 oPos : OPOS;
            };

            float _NoiseScale;
            float _NoiseAmp;
            uint _NoiseType;
            bool _Use2ndNoise;
            uint _2ndNoiseType;
            bool _Use3rdNoise;
            uint _3rdNoiseType;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.oPos = v.vertex;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 oPos = i.oPos;
                fixed4 col = 1;

                if(_Use3rdNoise == true){
                    //col.rgb = get3rdNoise(oPos, _NoiseScale, _3rdNoiseType, _2ndNoiseType, _NoiseType, _NoiseAmp);
                } else if(_Use2ndNoise == true){
                    col.rgb = get2ndNoise(oPos+10, _NoiseScale, _2ndNoiseType, _NoiseType, _NoiseAmp);
                } else {
                    col.rgb = getNoise(oPos, _NoiseScale, _NoiseType);
                }
                return col;
            }
            ENDCG
        }
    }
}
