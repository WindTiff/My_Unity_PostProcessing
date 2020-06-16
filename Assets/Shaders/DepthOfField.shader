Shader "Wind/DepthOfField"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    CGINCLUDE

        #include "UnityCG.cginc"

        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        sampler2D _CameraDepthTexture;
        float _FocusDistance;
        sampler2D _BlurTex;
        float2 _offsets;


        struct gaussianblur_v2f{
            float4 pos : SV_POSITION;
		    float2 uv : TEXCOORD0;
            float4 uv01:TEXCOORD1;
            float4 uv23:TEXCOORD2;
            float4 uv45:TEXCOORD3;
        };


        struct blend_v2f{
            float4 pos : SV_POSITION;
		    float2 uv : TEXCOORD0;
            float2 uv1 : TEXCOORD1;  
    
        };


        //用于高斯模糊的VS 和 FS
        gaussianblur_v2f gaussianblur_vert(appdata_img v){
            gaussianblur_v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord.xy;

            _offsets *= _MainTex_TexelSize.xy;

            o.uv01 = v.texcoord.xyxy + _offsets.xyxy * float4(1, 1, -1, -1);
		    o.uv23 = v.texcoord.xyxy + _offsets.xyxy * float4(1, 1, -1, -1) * 2.0;
		    o.uv45 = v.texcoord.xyxy + _offsets.xyxy * float4(1, 1, -1, -1) * 3.0;

            return o;
        }

        fixed4 gaussianblur_frag(gaussianblur_v2f i):SV_Target{
            fixed4 color = fixed4(0,0,0,0);
		    color += 0.4 * tex2D(_MainTex, i.uv);
		    color += 0.15 * tex2D(_MainTex, i.uv01.xy);
		    color += 0.15 * tex2D(_MainTex, i.uv01.zw);
		    color += 0.10 * tex2D(_MainTex, i.uv23.xy);
		    color += 0.10 * tex2D(_MainTex, i.uv23.zw);
		    color += 0.05 * tex2D(_MainTex, i.uv45.xy);
		    color += 0.05 * tex2D(_MainTex, i.uv45.zw);
		    return color;

    
        }

        //用于混合的 VS 和 FS

        blend_v2f blend_vert (appdata_img v)
        {
            blend_v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord.xy;
            o.uv1 = o.uv.xy;
            return o;
        }

        fixed4 blend_frag (blend_v2f i) : SV_Target
        {
                
            fixed4 original_color = tex2D(_MainTex,i.uv);

            fixed4 blur_color = tex2D(_BlurTex,i.uv1);

            float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
            depth = Linear01Depth(depth);

            float lerp_fac = abs(_FocusDistance-depth);

            fixed4 color = lerp(original_color,blur_color,lerp_fac);

           
            return color;

        }
        
    ENDCG

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass    //模糊Pass
        {

            CGPROGRAM
            #pragma vertex gaussianblur_vert
            #pragma fragment gaussianblur_frag
 
            ENDCG


        }

        Pass    //混合Pass
        {
        
           CGPROGRAM
            #pragma vertex blend_vert
            #pragma fragment blend_frag
 
            ENDCG
        
        
        }
    }
}
