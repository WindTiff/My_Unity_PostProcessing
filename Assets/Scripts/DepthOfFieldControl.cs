using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteInEditMode]
public class DepthOfFieldControl : PostEffectsBase
{
    public Shader possShader;

    private Material possMat;

    [Header("景深效果焦点距离")]
    [Range(0,1)]
    public float FocusDistance;


    [Header("模糊效果降采样倍数")]
    [Header("=====模糊相关=====")]
    [Range(1, 4)]
    public int DownSample;
    [Header("模糊效果迭代次数")]
    [Range(1, 3)]
    public int IterationTimes;
    [Header("模糊半径")]
    [Range(0, 3)]
    public int BlurRadius;


    public Material material
    {
        get
        {
            possMat = CheckShaderAndCreateMaterial(possShader, possMat);
            return possMat;
        }
    }


    private void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.Depth;
    }

    void OnDisable()
    {
        GetComponent<Camera>().depthTextureMode &= ~DepthTextureMode.Depth;
    }


    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {

            RenderTexture rt1 = RenderTexture.GetTemporary(source.width >> DownSample, source.height >> DownSample, 0, source.format);
            RenderTexture rt2 = RenderTexture.GetTemporary(source.width >> DownSample, source.height >> DownSample, 0, source.format);


            Graphics.Blit(source, rt1);
            Graphics.Blit(rt1, rt2, material, 0);

            for (int i = 0; i < IterationTimes; i++)
            {
             

                //第一次高斯模糊，设置offsets，竖向模糊
                material.SetVector("_offsets", new Vector2(0, BlurRadius));
                Graphics.Blit(rt2, rt1, material, 0);
                //第二次高斯模糊，设置offsets，横向模糊
                material.SetVector("_offsets", new Vector2(BlurRadius, 0));
                Graphics.Blit(rt1, rt2, material, 0);

                
        

            }

            material.SetTexture("_BlurTex", rt2);
            material.SetFloat("_FocusDistance", FocusDistance);

            Graphics.Blit(source, destination, material, 1);


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
