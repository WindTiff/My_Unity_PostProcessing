using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class BloomControl : PostEffectsBase
{
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

    public Shader possShader;
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

            material.SetFloat("_Intensity", Intensity);
            material.SetFloat("_Threshold", Threshold);
            material.SetColor("_ColorFilter", ColorFilter);

            RenderTexture rt1 = RenderTexture.GetTemporary(source.width >> DownSample, source.height >> DownSample, 0, source.format);
            RenderTexture rt2 = RenderTexture.GetTemporary(source.width >> DownSample, source.height >> DownSample, 0, source.format);


            Graphics.Blit(source, rt1);
            Graphics.Blit(rt1, rt2, material, 0);

            for (int i = 0; i < IterationTimes; i++)
            {
                Graphics.Blit(rt2, rt1, material,1);
                Graphics.Blit(rt1, rt2, material,1);

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
