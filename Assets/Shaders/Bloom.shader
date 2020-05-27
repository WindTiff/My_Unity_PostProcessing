Shader "Wind/Bloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    sampler2D _MainTex;
    float4 _MainTex_TexelSize;
    sampler2D _BlurTex;
    float _Intensity;
    float _Threshold;
    fixed4 _ColorFilter;
    float2 _offsets;


    struct separation_v2f{
        float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
    };

    struct blur_v2f{
        float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
        float2 uv1 : TEXCOORD1;  
		float2 uv2 : TEXCOORD2;  
		float2 uv3 : TEXCOORD3;  
		float2 uv4 : TEXCOORD4;
    
    };

    struct gaussianblur_v2f{
        float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
        float4 uv01:TEXCOORD1;
        float4 uv23:TEXCOORD2;
        float4 uv45:TEXCOORD3;
    };

    struct bloom_v2f{
        float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
        float2 uv1 : TEXCOORD1;  
    
    };
    //Pass 0 VF 用于分离出高亮区域
    separation_v2f separation_vert(appdata_img v){

        separation_v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = v.texcoord.xy;
        return o;
    }

    fixed4 separation_frag(separation_v2f i):SV_Target{
        fixed4 color = tex2D(_MainTex, i.uv);
        return saturate(color - _Threshold);
    
    }


    //Pass 1 VF 用于对 Pass0 得到的颜色缓冲进行模糊---------------均值模糊
    blur_v2f blur_vert(appdata_img v){

        blur_v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = v.texcoord.xy;
        o.uv1 = v.texcoord.xy+_MainTex_TexelSize * float2( 1,  1);
        o.uv2 = v.texcoord.xy+_MainTex_TexelSize * float2( -1,  1);
        o.uv3 = v.texcoord.xy+_MainTex_TexelSize * float2( 1,  -1);
        o.uv4 = v.texcoord.xy+_MainTex_TexelSize * float2( -1,  -1);

        return o;
    }

    fixed4 blur_frag(blur_v2f i):SV_Target{
        fixed4 color = tex2D(_MainTex,i.uv);
        color+=tex2D(_MainTex,i.uv1);
        color+=tex2D(_MainTex,i.uv2);
        color+=tex2D(_MainTex,i.uv3);
        color+=tex2D(_MainTex,i.uv4);

        return color*0.2f;
    
    }



    //Pass 2 VF 用于将原缓冲和模糊高亮后的缓冲混合输出
    bloom_v2f bloom_vert(appdata_img v){
        
        bloom_v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = v.texcoord.xy;
        o.uv1 = o.uv.xy;

        return o;
    }



    fixed4 bloom_frag(bloom_v2f i):SV_Target{

        fixed4 original_color = tex2D(_MainTex,i.uv);

        fixed4 blur_color = tex2D(_BlurTex,i.uv1);

        fixed4 color = original_color+_Intensity*blur_color;

        color = clamp(color,0,_ColorFilter);

        return color;
    
    }


    //Pass 3 VF 用于对 Pass0 得到的颜色缓冲进行模糊---------------高斯模糊
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


    ENDCG

    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            //提取高亮部分
            Name "Separation"
         
            CGPROGRAM

            #pragma vertex separation_vert
            #pragma fragment separation_frag
         
            ENDCG
        }

        Pass{
            Name "SimpleBlur"
                        
            CGPROGRAM
            #pragma vertex blur_vert
            #pragma fragment blur_frag

            ENDCG
        
        }

       
        Pass{
            Name "Bloom"

            CGPROGRAM

            #pragma vertex bloom_vert
            #pragma fragment bloom_frag

            ENDCG

        }

        Pass{
            Name "GaussianBlur"
                        
            CGPROGRAM

            #pragma vertex gaussianblur_vert
            #pragma fragment gaussianblur_frag

            ENDCG
        
        }

    }
}
