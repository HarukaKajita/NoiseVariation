using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;
using System.Linq;

public class DissolveShaderInspector : ShaderGUI
{
  #region MaterialProperties
  MaterialProperty MainTex;
  MaterialProperty Color;
  MaterialProperty Threshold;
  MaterialProperty ThresholdWidth;
  MaterialProperty NoiseType;
  MaterialProperty DivergenceNoiseAmp;
  MaterialProperty MaskTex;
  MaterialProperty NoiseDimension;
  MaterialProperty NoiseScale;
  MaterialProperty MainScrollSpeed;
  MaterialProperty MainScrollVector;
  MaterialProperty MaskScrollSpeed;
  MaterialProperty MaskScrollVector;
  MaterialProperty EmissionColor;
  MaterialProperty EdgeWidth;
  MaterialProperty Cull;
  MaterialProperty SrcFactor;
  MaterialProperty DstFactor;
  MaterialProperty UseMaultipleBlend;
  #endregion


  //Indirect Props
  float thresholdSliderVal;
  enum Blending
  {
    AlphaBlend,
    Add,
    Mul
  }
  Blending blendingMode;
  //Function

  public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
  {
    Material material = materialEditor.target as Material;
    Shader shader = material.shader;

    //find props
    MainTex = FindProperty("_MainTex", props, false);
    Color = FindProperty("_Color", props, false);
    Threshold = FindProperty("_Threshold", props, false);
    ThresholdWidth = FindProperty("_ThresholdGradWidth", props, false);
    NoiseType = FindProperty("_NoiseType", props, false);
    DivergenceNoiseAmp = FindProperty("_DivergenceNoiseAmp", props, false);
    MaskTex = FindProperty("_MaskTex", props, false);
    NoiseDimension = FindProperty("_NoiseDimension", props, false);
    NoiseScale = FindProperty("_NoiseScale", props, false);
    MainScrollSpeed = FindProperty("_MainScrollSpeed", props, false);
    MainScrollVector = FindProperty("_MainScrollVec", props, false);
    MaskScrollSpeed = FindProperty("_MaskScrollSpeed", props, false);
    MaskScrollVector = FindProperty("_MaskScrollVec", props, false);
    EmissionColor = FindProperty("_EmissionColor", props, false);
    EdgeWidth = FindProperty("_EdgeWidth", props, false);
    Cull = FindProperty("_Cull", props, false);
    SrcFactor = FindProperty("_SrcFactor", props, false);
    DstFactor = FindProperty("_DstFactor", props, false);
    UseMaultipleBlend = FindProperty("_UseMultipleBlend", props, false);

    // EditorGUIUtility.labelWidth = 0f;

    materialEditor.ShaderProperty(MainTex, MainTex.displayName);
    materialEditor.ShaderProperty(Color, Color.displayName);
    materialEditor.ShaderProperty(ThresholdWidth, ThresholdWidth.displayName);
    var thresholdW = ThresholdWidth.floatValue;

    thresholdSliderVal = EditorGUILayout.Slider(Threshold.displayName, thresholdSliderVal, 0, 1, GUILayout.MinWidth(300));
    float remapValue = (1 + thresholdW) * thresholdSliderVal;
    Threshold.floatValue = remapValue;

    materialEditor.ShaderProperty(NoiseType, NoiseType.displayName);
    materialEditor.ShaderProperty(DivergenceNoiseAmp, DivergenceNoiseAmp.displayName);
    var noisetype = NoiseType.floatValue;
    if (noisetype == 0f) materialEditor.ShaderProperty(MaskTex, MaskTex.displayName);
    else materialEditor.ShaderProperty(NoiseDimension, NoiseDimension.displayName);
    materialEditor.ShaderProperty(NoiseScale, NoiseScale.displayName);

    materialEditor.ShaderProperty(MainScrollSpeed, MainScrollSpeed.displayName);
    MainScrollVector.vectorValue = EditorGUILayout.Vector2Field(MainScrollVector.displayName, MainScrollVector.vectorValue, GUILayout.MinWidth(300));

    materialEditor.ShaderProperty(MaskScrollSpeed, MaskScrollSpeed.displayName);
    if (NoiseDimension.floatValue == 0) MaskScrollVector.vectorValue = EditorGUILayout.Vector2Field(MaskScrollVector.displayName, MaskScrollVector.vectorValue, GUILayout.MinWidth(300));
    else MaskScrollVector.vectorValue = EditorGUILayout.Vector3Field(MaskScrollVector.displayName, MaskScrollVector.vectorValue, GUILayout.MinWidth(300));
    materialEditor.ShaderProperty(EmissionColor, EmissionColor.displayName);
    materialEditor.ShaderProperty(EdgeWidth, EdgeWidth.displayName);
    materialEditor.ShaderProperty(Cull, Cull.displayName);
    blendingMode = (Blending)EditorGUILayout.EnumPopup("Blend Mode", blendingMode, GUILayout.Width(300));
    if (blendingMode == Blending.AlphaBlend)
    {
      SrcFactor.floatValue = (float)UnityEngine.Rendering.BlendMode.SrcAlpha;
      DstFactor.floatValue = (float)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha;
      UseMaultipleBlend.floatValue = 0;
    }
    else if (blendingMode == Blending.Add)
    {
      SrcFactor.floatValue = (float)UnityEngine.Rendering.BlendMode.One;
      DstFactor.floatValue = (float)UnityEngine.Rendering.BlendMode.One;
      UseMaultipleBlend.floatValue = 0;
    }
    else
    {
      SrcFactor.floatValue = (float)UnityEngine.Rendering.BlendMode.One;
      DstFactor.floatValue = (float)UnityEngine.Rendering.BlendMode.Zero;
      //乗算フラグ
      UseMaultipleBlend.floatValue = 1;
    }
  }
}
