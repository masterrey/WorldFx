

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
float _FurLength;
v2f vert(appdata v)
{
    v2f o;
    float3 myvertex = v.vertex.xyz + v.normal * _FurLength* furdistance;
    o.vertex = UnityObjectToClipPos(float4(myvertex, 1));
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.vertexWorld = mul(unity_ObjectToWorld, o.vertex).xyz
        UNITY_TRANSFER_FOG(o, o.vertex);
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
    float alpha = tex2D(_FurTex, i.uv.xy).rgb
        // apply fog
        UNITY_APPLY_FOG(i.fogCoord, albedo);

        return float4(finaloutput,alpha);
}

