+++
title = "OpenGL ES 2.0 Shader in Marmalade"
path = "/blog/2012/10/02/opengl-es-2-dot-0-shader-in-marmalade/"
template = "blog_post.html"

[extra]
date = "2012-10-02"
author = "YJ Park"
tags = ["iwgame", "marmalade"]
+++

Marmalade provide good support for writing custom shaders in it, though it's not easy to get all the information to start writing the first shader in my case, here is some information that I gathered during the process.

I decided to only support Open GL 2.0 Shaders in our games, most current devices support it, and as a small team, supporting older devices is a bit hard since we don't have testers for now, also the architect of 2.0 is simpler and cleaner.

The sample shader's function is to replace non-transparent part of the image to a given color, then the color can be changed programmingly (also by xml thanks to IwGame). Basically the images will be just working as masks, the actually color to be rendered are controlled by the shader. 

I will not cover the basics about Open GL Shaders, there are plenty of information on the web about that, also a PDF doc is included in Marmalade installation, it's a good start point to me, you should read it first to get the concepts.



Marmalade Rendering with Custom Shader
---------------------------------------

Marmalade support shader very well by the [CIwGxShaderTechnique](http://docs.madewithmarmalade.com/native/api_reference/api/classCIwGxShaderTechnique.html) class, to use it, you need to set it to material, here is the snnipet for that:

``` c++
    CIwMaterial* mat = IW_GX_ALLOC_MATERIAL();
    mat->SetTexture(image->getImage2D()->GetMaterial()->GetTexture());
    mat->SetShaderTechnique(shader);
    IwGxSetMaterial(mat);
```
The shader here is a pointer to CIwGxShaderTechnique, and the image is a pointer to CIwGameImage (part of IwGame), if you are not using IwGame, you can use Iw2d, or IwGx directly.

The following function can load a shader from a resource group.
``` c++
CIwGxShaderTechnique* getShader(const char* shaderName) {
    CIwGxShaderTechnique* shaderTemplate = (CIwGxShaderTechnique*)IwGetResManager()->GetResNamed(shaderName, "CIwGxShaderTechnique");
    
    if (shaderTemplate == NULL) {
        return false;
    }
    
    shader = new CIwGxShaderTechnique();
    IwSerialiseOpen("shader-Duplicate.bin", false);
    shaderTemplate->Serialise();
    IwSerialiseClose();

    IwSerialiseOpen("shader-Duplicate.bin", true);
    shader->Serialise();
    IwSerialiseClose();
    return shader;
}
```
Note: since I need multiple instance of the shader for diffrent images with differnt colors, here I use a quick solution with marmalade's serialization, which is NOT thread safe due to the hard code file name.

Load the resource group as this:
``` c++
    IwGetResManager()->LoadGroup("effect/Shaders.group");
```

Files Used
-----------

You need to include the shader files in the asset section of the mkb/mkf file, like this

```
files
{
    [Data]
    (data)
    effect/Shaders.group
}

assets
{
    (data-ram/data-gles1)
    effect/Shaders.group.bin
}
```
Please refer to Marmalade's documents if you are not familiar with the resource compiling process and mkb syntaxes.

Here is data/effect/Shaders.group
```
CIwResGroup
{
    name "PettyFun Environment Shaders"
    shared true

    "./PfMaskEffectShader.itx"
}
```

The content of data/effect/PfMaskEffectShader.itx
```
CIwGxShaderTechnique
{
    name "PfMaskEffectShader"

    param "p_Color" vec4 1 {0.0, 0.0, 1.0, 1.0}
    
    shader "vertex"
    {
        attribute highp vec4 inVert;
        attribute mediump vec2 inUV0;
        
        uniform highp mat4 inPMVMat;
        uniform mediump vec2 inUVOffset;
        uniform mediump vec2 inUVScale;
    
        varying mediump vec2 v_UV0;

        void main(void)
        {
            gl_Position = inPMVMat * inVert;
            
            v_UV0 = inUV0 * inUVScale + inUVOffset;
        }
    }
    shader "fragment"
    {
        uniform sampler2D inSampler0;
        varying mediump vec2 v_UV0;
        uniform mediump vec4 p_Color;

        void main(void)
        {
            mediump vec4 c = texture2D(inSampler0, v_UV0);
            if (c.a < 0.1) {
                gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
            } else {
                gl_FragColor = p_Color;
            }
        }
    } 
}
```
Please read [IwGxShaderTechnique Reference](http://docs.madewithmarmalade.com/native/api_reference/api/group__IwGxShaderTechnique.html) for the list of the attributes that you can use. It took me quite a while to find this document since this is no links to this page on the class reference page. This is VERY useful for writing shaders in Marmalade.

Update Params By Code and XML
------------------------------

the **param** in the shader is for the parameters from your code, change it's value like this.
``` cpp
void PfShaderEffect::SetShaderParam(const char *paramName, CIwGxShaderUniform::CIwGxShaderUniformType type, const void* value) {
    if (Shader == NULL) return;
    
    CIwGxShaderUniform* param = Shader->GetParam(paramName);
    if( param ) {
        param->Set(type, 0, value);
    } else {
        PfTrace("Shader Param Not Exist: %s", paramName);
    }
}

void PfShaderEffect::SetShaderParamAsInt(const char *paramName, int value) {
    SetShaderParam(paramName, CIwGxShaderUniform::INT, &value);
}


void PfShaderEffect::SetShaderParamAsFloat(const char *paramName, float value) {
    SetShaderParam(paramName, CIwGxShaderUniform::FLOAT, &value);
}

void PfShaderEffect::SetShaderParamAsColor(const char *paramName, CIwColour value) {
    float color[4];
    color[0] = 1.0f * value.r / 0xff;
    color[1] = 1.0f * value.g / 0xff;
    color[2] = 1.0f * value.b / 0xff;
    color[3] = 1.0f * value.a / 0xff;
    SetShaderParam(paramName, CIwGxShaderUniform::VEC4, color);
}

void PfShaderEffect::UpdateColorFromAnimation(CIwColour* color, CIwGameAnimInstance *animation) {
    CIwGameAnimFrameVec4* value = (CIwGameAnimFrameVec4*)animation->getCurrentData();
    color->r = value->data.x;
    color->g = value->data.y;
    color->b = value->data.z;
    color->a = value->data.w;
}
```

Since I'm using IwGame, it's very easy to make the color controlled by the XOML animation, all I need to do is to override the UpdateFromAnimation method of CIwGameActor, and handle the color value from it.
``` cpp
bool PfMaskEffect::UpdateFromAnimation(CIwGameAnimInstance *animation) {
    if (PfShaderEffect::UpdateFromAnimation(animation))
        return true;
    
    bool delta = animation->isDelta();
    
    unsigned int element_name = animation->getTargetPropertyHash();
    
    if (element_name == PfHash("Color")) {
        UpdateColorFromAnimation(&Color, animation);
        SetShaderParamAsColor("p_Color", Color);
    } else {
        return false;
    }
        return true;
}
```

Then you can generate smooth color switch animation by pure XML as normal IwGame Animation.
``` xml
    <Template Name="MaskColorTimelineTemplate">
        <Animation Name="MaskColorAnim$name$" Duration="$duration$" Type="vec4">
            <Frame Value="$startcolor$" Time="0" />
            <Frame Value="$endcolor$" Time="$duration$" />
        </Animation>
        <Timeline Name="MaskColorTimeline$name$" AutoPlay="true">
            <Animation Anim="MaskColorAnim$name$" Target="Color" Repeat="1" StartAtTime="0"/>
        </Timeline>
    </Template>

    <Actor ...>
        <FromTemplate Template="MaskColorTimelineTemplate" name="ColorChange" duration="2"
            startcolor="180, 220, 251, 255" endcolor="255, 0, 0, 255" />
    </Actor>
```
This is very flexible and powerful, no need to recompile, just updating plain XML files.
