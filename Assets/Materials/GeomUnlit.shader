Shader "Unlit/GeomUnlit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Dist("distortion", 2D) = "white" {}
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
            #pragma geometry geom
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

            struct v2g
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD2;
                float4 color: COLOR;
            };
            struct g2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD2;
                float4 color: COLOR;
            };

            sampler2D _MainTex;
            sampler2D _Dist;
            float4 _MainTex_ST;
            float4 _Dist_ST;

            v2g vert (appdata v)
            {
                g2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.normal = v.normal;
                o.color = v.color;
                return o;
            }
            [maxvertexcount(64)]
            void geom(triangle v2g i[3],inout TriangleStream<g2f> triStream)
            {
                g2f o;



              

                o.uv = i[0].uv;
                o.vertex = i[0].vertex;
                o.normal= i[0].normal;
                o.color = i[0].color;
                triStream.Append(o);

                o.uv = i[1].uv;
                o.vertex = i[1].vertex;
                o.normal = i[1].normal;
                o.color = i[1].color;
                triStream.Append(o);

                o.uv = i[2].uv;
                o.vertex = i[2].vertex;
                o.normal = i[2].normal;
                o.color = i[2].color;
                triStream.Append(o);

                
                for (int inter = 0; inter <20; inter++)
                {
                   
                    o.uv = i[0].uv;
                    o.vertex = i[0].vertex + float4(-0.02+ inter*0.1, 0, 0, 0);
                    o.normal = i[0].normal;
                    o.color = i[0].color;
                    triStream.Append(o);

                    o.uv = i[1].uv;
                    o.vertex = i[0].vertex + float4(0.02+ inter * 0.1, 0, 0, 0);
                    o.normal = i[1].normal;
                    o.color = i[1].color;
                    triStream.Append(o);

                    o.uv = i[2].uv;
                    fixed4 col = tex2Dlod(_Dist, float4(_Dist_ST.xy * i[0].uv + _Dist_ST.zw,0,0));
                    o.vertex = i[0].vertex + float4(inter * 0.1 + (sin(_Time.z+ i[0].vertex.x)*0.05), -5*col.y, 1*col.x, 0);
                    o.normal = i[2].normal;
                    o.color = i[2].color*2;
                    triStream.Append(o);
                }
                triStream.RestartStrip();
            }

            fixed4 frag (g2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv)*i.color;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
