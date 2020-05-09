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
            Name "Blur"
                        
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

    }
}
