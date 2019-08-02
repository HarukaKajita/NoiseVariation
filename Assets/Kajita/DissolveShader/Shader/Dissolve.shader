//copyright (c) Kajita Haruka (@kajitaj63b3)
//This shader is written by Kajita Haruka.


Shader "Dissolve"
{
    Properties
    {
        [Main Color]
		_MainTex("Texture", 2D) = "white" {}
		_Color ("Color", color) = (1,1,1,1)

        [Header(Dissolve)]
        _Threshold ("Threshold", Range(0,1)) = 0.5
		_ThresholdGradWidth ("Threshold Gradient Width", Range(0,1)) = 0.1
		
		[Enum(value, 0, perlin, 1, cellular, 2, curl, 3, fbm, 4)]
        _NoiseType ("Noise Type", int) = 1
        _DivergenceNoiseAmp ("DivergenceNoiseAmp", Range(0,100)) = 10
        [NoScaleOffset]
        _MaskTex ("MaskTex (gray scale)", 2D) = "white" {}
        [Enum(2D, 0, 3D, 1)]
        _NoiseDimension ("Noise Dimension", int) =0
		_NoiseScale ("Noise Scale", float) = 5

        [Space(20)]
        [Header(UVScroll)]
        _MainScrollSpeed ("Main Scroll Speed", float) = 0
        _MainScrollVec ("Main Scroll Vec", vector) = (1,1,0,0)
        _MaskScrollSpeed ("Mask Scroll Speed", float) = 0
        _MaskScrollVec ("Mask Scroll Vec", vector) = (1,1,0,0)

        [Header(EdgeEmission)]
        [HDR] _EmissionColor ("Emission Color", color) = (1,0,1,1)
        _EdgeWidth ("Edge Width", Range(0,1)) = 0


        //Settings
        [Space(20)]
        [Header(Setting)]
        [Enum(UnityEngine.Rendering.CullMode)]
        _Cull("Cull", Float) = 0                // Off


        [Enum(Off, 0, On, 1)]
        _ZWrite("ZWrite", Float) = 0            // Off

        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcFactor("Src Factor", Float) = 5     // SrcAlpha

        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstFactor("Dst Factor", Float) = 10    // OneMinusSrcAlpha

        _UseMultipleBlend ("Multiple Blend Flag", int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent-1" "IgnoreProjector" = "True"}
        LOD 100
		Cull [_Cull]
        // ZWrite [_ZWrite]
        Blend [_SrcFactor][_DstFactor]

        GrabPass{}
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

			#include "UnityCG.cginc"
			#include "Assets/Kajita/cginc/Noise.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 mainTexUV : TEXCOORD0;
                float2 maskTexUV : TEXCOORD1;
                float3 objPos : OBJPOS;
                float4 screenPos : SCREENPOS;
                UNITY_FOG_COORDS(2)
                float4 vertex : SV_POSITION;
            };
            
            //Main Texure
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;

            //Dissolve
			float _Threshold;
			float _ThresholdGradWidth;

			uint _NoiseType;
			sampler2D _MaskTex;
			float4 _MaskTex_ST;
            uint _NoiseDimension;
            float _NoiseScale;

            float _DivergenceNoiseAmp;

            //UV SCroll
            float _MainScrollSpeed;
            float2 _MainScrollVec;
            float _MaskScrollSpeed;
            float3 _MaskScrollVec;

            //Edge Emission
            half4 _EmissionColor;
            half _EdgeWidth;

            //乗算合成用フラグ
            bool _UseMultipleBlend;
            sampler2D _GrabTexture;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.mainTexUV = TRANSFORM_TEX(v.uv, _MainTex);
                o.maskTexUV = TRANSFORM_TEX(v.uv, _MaskTex);
                o.objPos = v.vertex;
                o.screenPos = ComputeScreenPos(o.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                float2 mainUV = i.mainTexUV + _MainScrollVec * _MainScrollSpeed * _Time.x;
                float2 maskUV = i.maskTexUV;
                fixed4 mainTexCol = tex2D(_MainTex, mainUV) * _Color;
                float3 noisePos = 0;
                if(_NoiseDimension == 0) noisePos = float3(maskUV, 0);
                else noisePos = float3(i.objPos);
                noisePos += _MaskScrollVec * _MaskScrollSpeed * _Time.x;
				// float maskValue = gradientNoise(noisePos, _NoiseScale, _NoiseType);
				//float maskValue = divergenceNoise(noisePos, _NoiseScale, _NoiseType, _DivergenceNoiseAmp);
				float maskValue = laplacianNoise(noisePos, _NoiseScale, _NoiseType, _DivergenceNoiseAmp);

                //Gradient Dissolve
				float diff = maskValue - lerp(_Threshold, _Threshold+_ThresholdGradWidth, _Threshold);//0~1で動けばグラデ幅分の誤差を吸収してアニメーションするように調整lerp。
				float interpolation = diff > 0;//1:mainTex 0:discard
				float dist = abs(diff);
				interpolation = max(interpolation, 1 - dist / _ThresholdGradWidth);
				fixed4 finalRGBA = fixed4(mainTexCol.rgb , mainTexCol.a * interpolation);
                
                //Edge Emission
                float distFromEdge = diff+_ThresholdGradWidth;
                if(distFromEdge > 0 && distFromEdge < _EdgeWidth) {
                    float emissionInterpolation = distFromEdge / _EdgeWidth;
                    emissionInterpolation = smoothstep(0,1,emissionInterpolation);
                    finalRGBA = lerp(_EmissionColor, finalRGBA, emissionInterpolation);
                }

                //乗算合成用の処理分岐
                if(_UseMultipleBlend){
                    float2 screenUV = i.screenPos.xy / i.screenPos.w;
                    fixed3 grabTexCol = tex2D(_GrabTexture, screenUV);
                    
                    finalRGBA.rgb *= grabTexCol.rgb;
                    finalRGBA.a = 1;
                }
                finalRGBA = saturate(finalRGBA);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    CustomEditor "DissolveShaderInspector"
}
