using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetectionControl : PostEffectsBase
{
    private Material possMat;
    public Shader possShader;

    public Color EdgeColor;
    public Color NonEdgeColor;



    public Material material
    {
        get
        {
            possMat = CheckShaderAndCreateMaterial(possShader, possMat);
            return possMat;
        }
    }


    [Range(1, 5)]
    public int sampleRange = 1;
    [Range(0, 1.0f)]
    public float normalDiffThreshold = 0.2f;
    [Range(0, 5.0f)]
    public float depthDiffThreshold = 2.0f;


    private void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    private void OnDisable()
    {
        GetComponent<Camera>().depthTextureMode = DepthTextureMode.None;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        material.SetColor("_EdgeColor", EdgeColor);
        material.SetColor("_NonEdgeColor", NonEdgeColor);
        material.SetFloat("_SampleRange", sampleRange);
        material.SetFloat("_NormalDiffThreshold", normalDiffThreshold);
        material.SetFloat("_DepthDiffThreshold", depthDiffThreshold);
        Graphics.Blit(source, destination, material);

    }
}
