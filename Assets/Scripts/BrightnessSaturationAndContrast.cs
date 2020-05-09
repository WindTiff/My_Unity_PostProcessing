using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class BrightnessSaturationAndContrast : PostEffectsBase
{
    public Shader possShader;
    private Material possMat;
    public Material material {
        get {
            possMat = CheckShaderAndCreateMaterial(possShader, possMat);
            return possMat;
        }
    }
    [Range(0.0f, 3.0f)]
    public float brightness = 1.0f;
    [Range(0.0f,3.0f)]
    public float saturation = 1.0f;
    [Range(0.0f,3.0f)]
    public float constrast = 1.0f;

    

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {

            material.SetFloat("_Brightness", brightness);
            material.SetFloat("_Saturation", saturation);
            material.SetFloat("_Contrast", constrast);

            Graphics.Blit(source, destination, material);


        }
        else {
            
            Graphics.Blit(source, destination);
        }
    }






}
