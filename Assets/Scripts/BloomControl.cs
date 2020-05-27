using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class BloomControl : PostEffectsBase
{
    public Shader possShader;
    [Range(0,10)]
    public float Intensity;
    [Range(0,5)]
    public float Threshold;
    
    public Color ColorFilter;

    //模糊相关
    [Header("模糊效果降采样倍数")][Range(1,4)]
    public int DownSample;
    [Header("模糊效果迭代次数")][Range(1,3)]
    public int IterationTimes;

    public bool GaussianBlur;
    [Range(0,3)]
    public int BlurRadius;

    private Material possMat;
    public Material material
    {
        get
        {
            possMat = CheckShaderAndCreateMaterial(possShader, possMat);
            return possMat;
        }
    }

                         
          
       
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            //TODO：
            //1.根据参数设置后处理shader当中的变量值
            //2.获取两个渲染缓冲，将原缓冲降采样，在两个缓冲之间交替模糊
            //3.将模糊后的缓冲和原缓冲混合，得到最终效果
                        
            material.SetFloat("_Intensity", Intensity);
            material.SetFloat("_Threshold", Threshold);
            material.SetColor("_ColorFilter", ColorFilter);

            RenderTexture rt1 = RenderTexture.GetTemporary(source.width >> DownSample, source.height >> DownSample, 0, source.format);
            RenderTexture rt2 = RenderTexture.GetTemporary(source.width >> DownSample, source.height >> DownSample, 0, source.format);


            Graphics.Blit(source, rt1);
            Graphics.Blit(rt1, rt2, material, 0);

            for (int i = 0; i < IterationTimes; i++)
            {
                if (GaussianBlur)
                {

                    //第一次高斯模糊，设置offsets，竖向模糊
                    material.SetVector("_offsets", new Vector2(0, BlurRadius));
                    Graphics.Blit(rt2, rt1, material, 3);
                    //第二次高斯模糊，设置offsets，横向模糊
                    material.SetVector("_offsets", new Vector2(BlurRadius, 0));
                    Graphics.Blit(rt1, rt2, material, 3);

                }
                else { 
                    Graphics.Blit(rt2, rt1, material,1);
                    Graphics.Blit(rt1, rt2, material,1);
                
                }


            }

            material.SetTexture("_BlurTex", rt2);

            Graphics.Blit(source, destination, material,2);


            //释放申请的内存
            RenderTexture.ReleaseTemporary(rt1);
            RenderTexture.ReleaseTemporary(rt2);
        }
        else
        {

            Graphics.Blit(source, destination);
        }
    }

}
