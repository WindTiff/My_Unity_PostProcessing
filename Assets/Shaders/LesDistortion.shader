Shader "Hidden/LesDistortion"
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
            float2 _Center;
            float _IntensityX;
            float _IntensityY;
            float _Scale;

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };


            //鱼眼畸变效果
            float2 fisheye(float2 uv)
            {
                float2	n_uv = (uv - _Center) * 2.0;
 
	            float2 r_uv;
	            r_uv.x = (1 - n_uv.y * n_uv.y) * _IntensityY * (n_uv.x);
	            r_uv.y = (1 - n_uv.x * n_uv.x) * _IntensityX * (n_uv.y);
	            return(uv* _Scale - r_uv);
            }


            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy;
                return o;
            }

            

            fixed4 frag (v2f i) : SV_Target
            {
                float2 trans_uv = fisheye(i.uv);

                fixed4 col = tex2D(_MainTex, trans_uv);
  
                return col;
            }
            ENDCG
        }
    }
}
