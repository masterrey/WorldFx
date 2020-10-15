Shader "lit/MyEarth"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Normal("Normal", 2D) = "white" {}
        _NightLight("Night", 2D) = "white" {}
        _SpecularMask("SpecularMask", 2D) = "white" {}
        _Cloud("Cloud", 2D) = "white" {}
        _FakeLight("FakeLight",Color)=(0,1,0,0)
        _Shininess("Shininess", Float) = 10
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float4 normal: NORMAL;
                float2 uv : TEXCOORD0;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 vertexWorld : TEXCOORD3;
                float3 normal : TEXCOORD2;
                float3 tangentWorld : TEXCOORD4;
                float3 normalWorld : TEXCOORD5;
                float3 binormalWorld : TEXCOORD6;
               
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _FakeLight;
            sampler2D _Cloud;
            sampler2D _NightLight;
            sampler2D _Normal;
            uniform float4 _Normal_ST;
            sampler2D _SpecularMask;
            float _Shininess;

            v2f vert (appdata v)
            {
                v2f o;

                o.normal = UnityObjectToWorldNormal(v.normal);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.vertexWorld = UnityObjectToWorldDir(v.vertex);

                float4x4 modelMatrix = unity_ObjectToWorld;
                float4x4 modelMatrixInverse = unity_WorldToObject;

                o.tangentWorld = normalize(mul(modelMatrix, float4(v.tangent.xyz, 0.0)).xyz);
                o.normalWorld = normalize(mul(v.normal, modelMatrixInverse).xyz);
                o.binormalWorld = normalize(cross(o.normalWorld, o.tangentWorld)* v.tangent.w); // tangent.w is specific to Unity

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {

               //float4 encodedNormal = tex2D(_Normal,i.uv);
               float4 encodedNormal = tex2D(_Normal,_Normal_ST.xy * i.uv + _Normal_ST.zw);//faz funcionar o ajuste de normal na unity
               float3 localCoords = float3(2.0 * encodedNormal.a - 1.0,2.0 * encodedNormal.g - 1.0, 0.0);//fix unity axis error
               localCoords.z = sqrt(1.0 - dot(localCoords, localCoords));
            
               //calcula a direcao da camera
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.vertexWorld);


                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                //textura da nuvem andar
                float2 cuv = float2(i.uv.x+_Time.x*0.01, i.uv.y);
                fixed4 cloud = tex2D(_Cloud, cuv);

                fixed4 ncol = tex2D(_NightLight, i.uv);

                //fixed4 norm = tex2D(_Normal, i.uv);
                fixed4 shinemask = tex2D(_SpecularMask,i.uv);

                //somo a cor na nuvem
                col += cloud;

                //criaçao de matris transposta
                float3x3 local2WorldTranspose = float3x3(i.tangentWorld,i.binormalWorld,i.normalWorld);
                //calculo da normalmap em relaçao ao ponto especifico do vector
                float3 worldNormal =normalize(mul(localCoords, local2WorldTranspose));
                

                float3 lightDirection;
                float attenuation;

                //direçao da luz normalizada
                lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                
               

                //calculo da luz com normalmap
                float ilumin = max(dot(worldNormal, lightDirection), 0);

                //Specular show 
                float specularReflection = pow(max(0.0, dot(reflect(-lightDirection,worldNormal),viewDir)), _Shininess);
                
                
                //calculo da luznoturna
                float iluminNight = max(-dot(i.normal, lightDirection), 0)* ncol;
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);


                return (col*_LightColor0*ilumin)+ _FakeLight+ iluminNight+ specularReflection;
            }
            ENDCG
        }
    }
}
