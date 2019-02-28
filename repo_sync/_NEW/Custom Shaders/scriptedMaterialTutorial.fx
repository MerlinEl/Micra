/*
First, let's set up all of our constants we are passing into the shader from max.
They don't need real UI setup, but they DO need to be specified as having UI elements
For example:
float sourceUMin < string UIName = "Foo"; > = 0;
works while
float sourceUMin;
does not.  Don't worry about setting the UI because we will be setting it with our scripted material
but that's never an excuse to be dirty! (always set defaults, etc)
*/

float minUCoord < string UIName = "Blank"; > = 0;
//Generally I will preface with "g_" to indicate globals that will be used in the shader, while 'excess' variables won't have it

//#include "myConstants.hlsl"

/*In order to keep things organized, I will put most UI constants in a #include'd hlsl file if there are many
Since you may be using these constants for a variety of things not directly related to the shader (such as
storing data to re-use in an XML export), there can be many and many nonsensical ones.  Better keep these separate, in
a distinct hlsl file.  I won't here to cut down on the number of files you need to open.

One caveat, if you updated the #include'd file, you also need to re-update the actual shader file so max knows to recompile
*/

//Placeholders for strings
int brdf
< string UIName = "BRDFP"; > = 1;

//Material properties
float g_glossiness : SPECULARPOWER
<
    string UIWidget = "slider";
    float UIMin = 2;
    float UIMax = 128;
    float UIStep = 1;
    string UIName = "Glossiness";
> = 40;

float g_reflectance : REFLECTIVITY
<
    string UIWidget = "slider";
    float UIMin = 0;
    float UIMax = 1;
    float UIStep = .01;
    string UIName = "Reflectance";
> = .5;

float4 ambientColor : AMBIENT
<
	string UIName = "Ambient Color";
> = {0.5f, 0.5f, 0.5f, 1.0f};

float4x4 m_world		: World;
float4x4 m_worldInv : 	WorldInverse;	
float4x4 m_wvp		: WorldViewProjection;
float4x4 m_worldView : 	WorldView;
float4x4 m_viewInv    :   ViewInverse;
     
float3 lightPos : POSITION 
< 
    string UIName = "Light Position"; 
    string Object = "PointLight"; 
    string Space = "World"; 
    int refID = 1; 
> = {100.0f, 100.0f, 100.0f}; 
 
//TEXTURE SAMPLERS
//#include "myTextureSamplers.hlsl"
//I'll do the same thing as described above, but for texture samplers.  There can be many, so
//for clarity I break them out.  However I will list then inline here.
texture g_DiffuseTexture : DIFFUSE
<
    string Name = "D.png";
    string UIName = "DiffuseTexture";
    string TextureType = "2D";
>;
sampler2D baseTexture = sampler_state
{
    Texture = <g_DiffuseTexture>;
	Addressu = CLAMP;
	Addressv = CLAMP;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

texture g_NormalTexture : NORMAL
<
    string Name = "N.png";
    string UIName = "NormalTexture";
    string TextureType = "2D";
>;
sampler2D normTexture = sampler_state
{
	Addressu = CLAMP;
	Addressv = CLAMP;
    Texture = <g_NormalTexture>;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

/////STRUCTS///////////
struct VS_IN
{
    float4 Position0 : POSITION0;
    float3 Normal0   : NORMAL0;
    float3 Tangent0  : TANGENT0;
    float3 Binormal0 : BINORMAL0;
    float2 TexUV      : TEXCOORD0;
};
 
struct VS_OUT
{
    float4 Position	: POSITION;
    float2 TexUV: TEXCOORD0;
    float3 lightVec	: TEXCOORD1;
    float3 eyeVec	: TEXCOORD2;
    float3 halfVec	: TEXCOORD3;
};

//Max's UV's are offset by -1 in the y, so we fix it with an appropriately named function
float2 fixMaxStupidUVProblem(float2 uv)
{
	uv.y += 1.0;
	return uv;
}

//Here is my shader code, nothing interesting.  In fact, very dumbed down for tutorial purposes.

/////VERTEX SHADER////////////
VS_OUT ourVS( VS_IN In)
{
	VS_OUT Out;
	
	In.TexUV = fixMaxStupidUVProblem(In.TexUV);
	Out.TexUV = In.TexUV;
	
    Out.Position = mul(In.Position0, m_wvp);
    
    float3 WorldPos = mul(In.Position0, m_world);

    float3x3 tangentSpace;
        tangentSpace[0] = In.Binormal0;
        tangentSpace[1] = In.Tangent0;
        tangentSpace[2] = In.Normal0;

    float3 osLPos = mul(lightPos, m_worldInv);
    float3 osLVec = osLPos.xyz - WorldPos.xyz;
    Out.lightVec = mul(tangentSpace, osLVec);
    
    float4 camPos = mul(m_viewInv[3], m_worldInv);
    float3 viewDir = camPos.xyz - In.Position0.xyz;
    Out.eyeVec = mul(tangentSpace, viewDir);

    Out.halfVec = normalize(mul(tangentSpace, (viewDir + lightPos)));
    
    return Out;
}

///////PIXEL SHADER////////////////
float4 ourPS (VS_OUT In) : COLOR
{	
    float4  diffuseMap =	tex2D(baseTexture, In.TexUV);
    float3  normalMap =	tex2D(normTexture, In.TexUV);
    float   specMap	=	tex2D(specularTexture, In.TexUV).r;
	
    float3  E = normalize(In.eyeVec);
    float3  L = normalize(In.lightVec);
    float3   H = normalize(L + E);

    normalMap = normalMap * 2 - 1;
    float3 N = float3(normalMap.x, normalMap.y, normalMap.z);
	
    float NdotL =  saturate(dot(N, L)); //angle1
    float3  diffuseColor = NdotL * diffuseMap.xyz;
    
    float   NdotH = saturate(dot(N, H));
    float   specLevel = pow(NdotH, RM_GlossinessP);
    float3 specular = specLevel * specMap * RM_SpecMultP;

    float3 lightComp = (diffuseColor + specular + g_AmbientIntensity) * light1Color;
    float4 ret = float4(lightComp, diffuseMap.a);
	
    return ret;
}

//I'll list two techniques here to demonstrate a scripted material feature, even though they are both the same
technique ourTechnique0
{
    pass P0
    {          
        VertexShader = compile vs_2_0 ourVS();
        PixelShader  = compile ps_2_0 ourPS(); 
    } 
}

technique ourTechnique1
{
    pass P0
    {          
        VertexShader = compile vs_2_0 ourVS();
        PixelShader  = compile ps_2_0 ourPS(); 
    } 
}