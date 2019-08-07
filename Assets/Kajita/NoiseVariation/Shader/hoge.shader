Shader "Noise/hoge"
{
    Properties
    {
        _NoiseScale ("Noise Scale", Range(0,100)) = 10
        [Enum(Plain, 0, Gradient, 1, Divergence, 2, laplacian, 3)]
        _NoiseLigic ("Noise Logic", int) = 0
        [Enum(value, 0, perlin, 1, cellular, 2, curl, 3, fbm, 4)]
        _NoiseType ("Noise Type", int) = 0
        _NoiseAmp ("Noise Amp", Range(0,10)) = 10
        _Epsilon ("Epsilon", Range(0,1)) = 1
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
            float _Epsilon;
            uint _NoiseType;
            float _NoiseAmp;

            //float3 getNoise(float3 pos, float scale, int type);

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
                fixed4 col = fixed4((fixed3)hogeNoise(i.oPos, _NoiseScale, _NoiseType, _NoiseAmp, _Epsilon), 1);
                
                //fixed4 col = (fixed4)divergenceNoise(oPos, _NoiseScale, _NoiseType, _NoiseAmp);
                return col;
            }

            
            ENDCG
        }
    }
}
