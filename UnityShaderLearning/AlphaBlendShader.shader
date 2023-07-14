Shader "Unlit/AlphaBlendShader"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _AlphaScale ("Alpha Scale", Range(0, 1)) = 1 
    }
    SubShader
    {
      Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RendeerType" = "Transparent"}

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
           
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _AlphaScale;

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
              //Ìî³ä½á¹¹Ìå
              vOut.pos = UnityObjectToClipPos(vIn.vertex);
              vOut.worldNormal = UnityObjectToWorldNormal(vIn.normal);
              vOut.worldPos = mul(unity_ObjectToWorld, vIn.vertex).xyz;
              vOut.uv = TRANSFORM_TEX(vIn.texcoord, _MainTex);
              return vOut;
            }

            fixed4 frag(vertOut vOut) : SV_TARGET
            {
              fixed3 worldNormal = normalize(vOut.worldNormal);
              fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(vOut.worldPos));
              fixed4 texColor = tex2D(_MainTex, vOut.uv);
              fixed3 albedo = texColor.rgb * _Color.rgb;
              fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
              fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

              return fixed4(ambient+diffuse,texColor.a * _AlphaScale);
            }

            ENDCG
        }
    }
    FallBack "Transparent/VertexLit"
}
