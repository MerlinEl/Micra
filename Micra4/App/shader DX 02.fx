// File    : SingleTexWithVColorsAndAlpha_ForMaxAndMaya.fx
// Author  : Yannick Puech - http://ypuechweb.free.fr/
// Purpose : Display the texture with vertex colors and alpha
//           This FX works only with 3ds max 

texture Tex : DIFFUSEMAP <
	string name = ""; 
	string UIName = "Texture";
>;

// Sampler with bilinear filtering
sampler diffuseTexture = sampler_state
{
	Texture   = (Tex);
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = POINT;   
};

// Rendering method for the colors of the shader
bool Modulate2X <
	string UIName = "Modulate2X";
	string UIType = "Checkbox";
> = true;


// Some semantics to get the right mapping channel
// Vertex UVs
int texcoord0 : Texcoord
<
	int Texcoord = 0;
	int MapChannel = 1;
>;

// Vertex colors
int texcoord1 : Texcoord
<
	int Texcoord = 1;
	int MapChannel = 0;
>;

// Vertex alpha
int texcoord2 : Texcoord
<
	int Texcoord = 2;
	int MapChannel = -2;
>;
	

// Transforms
float4x3 mWorldView  : WORLDVIEW;
float4x4 mProjection : PROJECTION;
float4x4 mWorldProj  : WORLDVIEWPROJ;

// Vertex shader input and output struct
struct VSTEXTURE_INPUT
{
	float4 Position  : POSITION0;
	float2 TexCoord  : TEXCOORD0;
	float4 VertColor : TEXCOORD1;
	float4 VertAlpha : TEXCOORD2;
};
	
struct VSTEXTURE_OUTPUT
{
	float4 Position : POSITION0;
	float4 Diffuse  : COLOR0;
	float2 TexCoord : TEXCOORD0;
};

VSTEXTURE_OUTPUT mainVS(VSTEXTURE_INPUT In)

{
	VSTEXTURE_OUTPUT Out = (VSTEXTURE_OUTPUT)0;
  
	float3 P = mul(In.Position, mWorldView);            // Position (view space)
   
	Out.Position  = mul(float4(P, 1), mProjection);  	// Projected position
	Out.Diffuse   = In.VertColor;
	Out.Diffuse.a = In.VertAlpha.x;
	Out.TexCoord  = In.TexCoord;                        // Texture coordinate
	
	return Out;
}

	float4 mainPS(VSTEXTURE_OUTPUT In) : COLOR0

{
	float4 PixelColor;
	
		PixelColor.rgb = tex2D(diffuseTexture, In.TexCoord).rgb * In.Diffuse.rgb;
		PixelColor.a = In.Diffuse.a;

		
	if( Modulate2X == true )
	{
		PixelColor.rgb *= 2.0f;
	}

	return PixelColor;
}

technique TTextured
{
	pass p0
	{
		AlphaBlendEnable = true;
		SrcBlend         = SRCALPHA;
		DestBlend        = INVSRCALPHA;
		
		VertexShader = compile vs_1_1 mainVS();
		PixelShader  = compile ps_1_1 mainPS();
	}
}
