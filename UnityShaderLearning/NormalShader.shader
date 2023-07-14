Shader "Unlit/NormalShader"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Float) = 1.0
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    //��һ�ַ�����ͼʵ�ַ�ʽ�������߿ռ��м���
    SubShader
    {
       Tags { "LightMode" = "ForwardBase"}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag          
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Specular;
            float _Gloss;

            struct vertIn
            {
             float4 vertex : POSITION;
             float3 normal : NORMAL;
             float4 tangent : TANGENT;
             float4 texcoord : TEXCOORD0;
            };

            struct vertOut
            {
             float4 pos : SV_POSITION;
             float4 uv : TEXCOORD0;
             float3 lightDir : TEXCOORD1;
             float3 viewDir : TEXCOORD2; 
            };

            vertOut vert(vertIn vIn)
            {
              vertOut vOut;
              vOut.pos = UnityObjectToClipPos(vIn.vertex);
              //��ȡ����ͷ�����ͼƫ����
              vOut.uv.xy = vIn.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
              vOut.uv.zw = vIn.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

              //���㸱����
              float3 binormal = cross( normalize(vIn.normal), normalize(vIn.tangent.xyz))
              * vIn.tangent.w;

              //������ģ�Ϳռ�ת��Ϊ���߿ռ�ı任����
              float3x3 rotation = float3x3(vIn.tangent.xyz, binormal, vIn.normal);
              //or : TANGENT_SPACE_ROTATION

              //�����շ���������ģ�Ϳռ�任�����߿ռ�
              vOut.lightDir = mul(rotation, ObjSpaceLightDir(vIn.vertex)).xyz;
              //���۲췽��������ģ�Ϳռ�任�����߿ռ�
              vOut.viewDir = mul(rotation,ObjSpaceViewDir(vIn.vertex)).xyz;

              return vOut;
            }

            fixed4 frag(vertOut vOut) : SV_Target
            {
              fixed3 tangentLightDir = normalize(vOut.lightDir);
              fixed3 tangentViewDir = normalize(vOut.viewDir);

              //��ȡ������ͼ������Ԫ������texel��
              fixed4 packedNormal = tex2D(_BumpMap,vOut.uv.zw);
              fixed3 tangentNormal;


              //��������Ϊ������ͼ��ʹ�����ú���
              tangentNormal = UnpackNormal(packedNormal);
              tangentNormal.xy *= _BumpScale;
              tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));
              //�����߿ռ������¼������(Blinn Phong)
              fixed3 albedo = tex2D(_MainTex, vOut.uv).rgb * _Color.rgb;

              fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

              fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal,tangentLightDir));

              fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);

              fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, 
              halfDir)), _Gloss);

              return fixed4(ambient + diffuse + specular, 1.0);
            }

            ENDCG
        }
    }
    FallBack "Specular"
}
