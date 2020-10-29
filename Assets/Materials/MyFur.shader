Shader "Unlit/MyFur"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _FurTex("Fur", 2D) = "white" {}
        _Color("Color",Color) = (1,1,1,1)
        _Shininess("Shininess", Float) = 10
        _FurLength("FurLength", Float) = 1
    }


        Category{
              Tags { "RenderType" = "Transparent" "IgnoreProjector" = "True" "Queue" = "Transparent" }
        Cull Off
        ZWrite On
        Blend SrcAlpha OneMinusSrcAlpha

               LOD 100
           SubShader
           {
               Pass
               {
                 
                   CGPROGRAM
                   #pragma target 3.0
                   #pragma vertex vert
                   #pragma fragment frag
                   // make fog work
                   #pragma multi_compile_fog

                   #include "UnityCG.cginc"

                   struct appdata
                   {
                       float4 vertex : POSITION;
                       float2 uv : TEXCOORD0;
                       float4 normal: NORMAL;
                       float4 color: COLOR;
                   };

                   struct v2f
                   {
                       float2 uv : TEXCOORD0;
                       UNITY_FOG_COORDS(1)
                       float4 vertex : SV_POSITION;
                       float3 worldNormal:TEXCOORD1;
                       float3 vertexWorld : TEXCOORD2;
                   };

                   sampler2D _MainTex;
                   float4 _MainTex_ST;
                   sampler2D _FurTex;
                   float4 _Color;
                   float _Shininess;
                   v2f vert(appdata v)
                   {
                       v2f o;
                       o.vertex = UnityObjectToClipPos(v.vertex);
                       o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                       o.worldNormal = UnityObjectToWorldNormal(v.normal);
                       o.vertexWorld = mul(unity_ObjectToWorld,o.vertex).xyz
                       UNITY_TRANSFER_FOG(o,o.vertex);
                       return o;
                   }

                   fixed4 frag(v2f i) : SV_Target
                   {
                       fixed3 worldNormal = normalize(i.worldNormal);
                       fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                       fixed3 worldView = normalize(_WorldSpaceCameraPos.xyz - i.vertexWorld.xyz);
                       fixed3 worldHalf = normalize(worldView + worldLight);

                       // sample the texture
                       fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color;
                       fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                       fixed3 diffuse = albedo * saturate(dot(worldNormal, worldLight));
                       fixed3 specular = pow(saturate(dot(worldNormal, worldHalf)), _Shininess);

                       float3 finaloutput = albedo * (ambient + diffuse + specular);
                      
                           // apply fog
                           UNITY_APPLY_FOG(i.fogCoord, albedo);

                           return float4(finaloutput,1);
                       }
                       ENDCG
                   }
                   
                   Pass 
                      {
                        CGPROGRAM
                        #pragma vertex vert
                        #pragma fragment frag
                           // make fog work
                        #pragma multi_compile_fog
                        #define furdistance 0.001;
                        #include "FurPass.cginc"
                        ENDCG
                       
                       }
                    Pass
                      {
                        CGPROGRAM
                        #pragma vertex vert
                        #pragma fragment frag
                        // make fog work
                     #pragma multi_compile_fog
                     #define furdistance 0.002;
                     #include "FurPass.cginc"
                     ENDCG

                    }
                           Pass
                      {
                        CGPROGRAM
                        #pragma vertex vert
                        #pragma fragment frag
                        // make fog work
                     #pragma multi_compile_fog
                     #define furdistance 0.003;
                     #include "FurPass.cginc"
                     ENDCG

                    }
                       Pass
                   {
                     CGPROGRAM
                     #pragma vertex vert
                     #pragma fragment frag
                     // make fog work
                  #pragma multi_compile_fog
                  #define furdistance 0.004;
                  #include "FurPass.cginc"
                  ENDCG

                   }
                       Pass
                   {
                     CGPROGRAM
                     #pragma vertex vert
                     #pragma fragment frag
                     // make fog work
                  #pragma multi_compile_fog
                  #define furdistance 0.005;
                  #include "FurPass.cginc"
                  ENDCG

                   }
                       Pass
                   {
                     CGPROGRAM
                     #pragma vertex vert
                     #pragma fragment frag
                     // make fog work
                  #pragma multi_compile_fog
                  #define furdistance 0.006;
                  #include "FurPass.cginc"
                  ENDCG

                   }
                       Pass
                   {
                     CGPROGRAM
                     #pragma vertex vert
                     #pragma fragment frag
                     // make fog work
                  #pragma multi_compile_fog
                  #define furdistance 0.007;
                  #include "FurPass.cginc"
                  ENDCG

                   }
                       Pass
                   {
                     CGPROGRAM
                     #pragma vertex vert
                     #pragma fragment frag
                     // make fog work
                  #pragma multi_compile_fog
                  #define furdistance 0.008;
                  #include "FurPass.cginc"
                  ENDCG

                   }
                       Pass
                   {
                     CGPROGRAM
                     #pragma vertex vert
                     #pragma fragment frag
                     // make fog work
                  #pragma multi_compile_fog
                  #define furdistance 0.009;
                  #include "FurPass.cginc"
                  ENDCG

                   }
                        Pass
                    {
                      CGPROGRAM
                      #pragma vertex vert
                      #pragma fragment frag
                      // make fog work
                   #pragma multi_compile_fog
                   #define furdistance 0.01;
                   #include "FurPass.cginc"
                   ENDCG

                    }
                               Pass
                           {
                             CGPROGRAM
                             #pragma vertex vert
                             #pragma fragment frag
                             // make fog work
                          #pragma multi_compile_fog
                          #define furdistance 0.011;
                          #include "FurPass.cginc"
                          ENDCG

                           }

                    
           }

           
        }

}
