// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/AlphaTestShader"
{
    Properties
    {
        _Color ("Main Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _Cutoff ("Alpha Cutoff", Range(0,1)) = 0.5
    }
    SubShader
    {
       Tags { "Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout" }

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag           
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _Cutoff;

            struct vertIn
            {
             float4 vertex : POSITION;
             float3 normal : NORMAL;
             float4 texcoord : TEXCOORD0;
            };

            struct vertOut
            {
             float4 pos : SV_POSITION;
             float3 worldNormal : TEXCOORD0;
             float3 worldPos : TEXCOORD1;
             float2 uv : TEXCOORD2;
            };

            vertOut vert(vertIn vIn)
            {
              vertOut vOut;
              //填充结构体
              vOut.pos = UnityObjectToClipPos(vIn.vertex);
              vOut.worldNormal = UnityObjectToWorldNormal(vIn.normal);
              vOut.worldPos = mul(unity_ObjectToWorld, vIn.vertex).xyz;
              vOut.uv = TRANSFORM_TEX(vIn.texcoord, _MainTex);
              return vOut;
            }

            fixed4 frag(vertOut vOut) : SV_Target
            {
              fixed3 worldNormal = normalize(vOut.worldNormal);
              fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(vOut.worldPos));
              fixed4 texColor = tex2D(_MainTex, vOut.uv);

              //Alpha测试，使用Clip函数
              clip(texColor.a - _Cutoff);
              //等价于：
              //if((texColor.a - _Cutoff) < 0.0){                            }
              //  discard;
              //}
          
              fixed3 albedo = texColor.rgb * _Color.rgb;
              fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
              fixed3 diffuse = _LightColor0 * albedo * max(0, dot(worldNormal, worldLightDir));

              return fixed4(ambient + diffuse, 1.0); 
              }
            ENDCG
        }
    }
}
