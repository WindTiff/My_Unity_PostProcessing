using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LensDistortionControl : PostEffectsBase
{

    private Material possMat;
    public Shader possShader;



    public Vector2 Center;  //可视部分的位置

    public float IntensityX;
    public float IntensityY;
    public float Scale;










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
            material.SetFloat("_IntensityX", IntensityX);
            material.SetFloat("_IntensityY", IntensityY);
            material.SetFloat("_Scale", Scale);

            Graphics.Blit(source, destination, material);


        }
        else
        {

            Graphics.Blit(source, destination);
        }
    }
}
