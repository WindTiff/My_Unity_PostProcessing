Shader "Wind/Vignette"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            
            sampler2D _MainTex;
            fixed4 _VignetteColor;
            float2 _Center;
            float _Intensity;
            float _Smoothness;
            float _Ratio;



            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy;
                return o;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                //得到像素uv和中心点的距离
                //Ratio负责控制可视部分的形状
                float d = distance(float2(_Center.x*_Ratio,_Center.y),float2(i.uv.x*_Ratio,i.uv.y));

                //使用距离（0，1.414）进行插值得到c
                float c = smoothstep((1-_Intensity)*(1-_Smoothness),1-_Intensity,d);
                //使用c对像素原颜色和Vignette颜色进行插值得到最终的颜色
                fixed4 col = lerp( tex2D(_MainTex, i.uv),_VignetteColor,c);

                return col;
            }
            ENDCG
        }
    }
}
