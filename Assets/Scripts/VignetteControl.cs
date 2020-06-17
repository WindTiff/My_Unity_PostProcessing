using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class VignetteControl : PostEffectsBase
{

    public Shader possShader;

    public Color VignetteColor; //遮挡部分的颜色

    public Vector2 Center;  //可视部分的位置

    [Range(0,1)]
    public float Intensity; //控制可视部分大小
    [Range(0, 1)]
    public float Smoothness;    //控制可视部分边缘的渐变程度
    [Range(0, 1)]
    public float Roundness; //控制可视部分的宽高比



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
            material.SetVector("_Center", Center);
            material.SetFloat("_Intensity", Intensity);
            material.SetColor("_VignetteColor", VignetteColor);
            material.SetFloat("_Smoothness", Smoothness);

            //在1和相机宽高比之间使用Roudness进行插值
            float ratio = Mathf.Lerp(1, GetComponent<Camera>().aspect, Roundness);
            material.SetFloat("_Ratio", ratio);
            Graphics.Blit(source, destination, material);


        }
        else
        {

            Graphics.Blit(source, destination);
        }
    }

}
