Shader "Noise/3D"
{
    Properties
    {
        _NoiseScale ("Noise Scale", Range(0,100)) = 10
        [Enum(value, 0, perlin, 1, cellular, 2)]
        _NoiseType ("Noise Type", int) = 0
        _NoiseAmp ("Noise Amp", Range(0,100)) = 10
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
            uint _NoiseLigic;
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
                fixed4 col = fixed4(getNoise3D(i.oPos + 100, _NoiseScale, _NoiseType), 1);
                
                return col;
            }

            
            ENDCG
        }
    }
}
