// File    : SingleTexWithVColorsAndAlpha_ForMaxAndMaya.fx
// Author  : Yannick Puech - http://ypuechweb.free.fr/
// Purpose : Display the texture with vertex colors and alpha
//           This FX works only with 3ds max and Maya

#ifdef _3DSMAX_

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
	
#else //if defined(_MAYA_)

	sampler2D diffuseTexture;
	
	// Rendering method for the colors of the shader
	bool Modulate2X;
	
#endif

#ifdef _3DSMAX_
	
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
	
//#else if defined(_MAYA_)

#endif

// Transforms

#ifdef _3DSMAX_

	float4x3 mWorldView  : WORLDVIEW;
	float4x4 mProjection : PROJECTION;
	float4x4 mWorldProj  : WORLDVIEWPROJ;

#else //if defined(MAYA)

	float4x4 mWorldView  : WorldView;
	float4x4 mWorldProj  : WorldViewProjection;

#endif

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

#ifdef _3DSMAX_
	VSTEXTURE_OUTPUT mainVS(VSTEXTURE_INPUT In)
#else //if defined(_MAYA_)
	void mainVS(float4 Vertex       : POSITION0,
             	float4 TexCoord     : TEXCOORD0,
             	float4 VertColor    : COLOR0,
             	out float4 Position : POSITION0,
             	out float2 UV       : TEXCOORD2,
             	out float4 Diffuse  : COLOR0
				)
#endif
{
	#ifdef _3DSMAX_
		VSTEXTURE_OUTPUT Out = (VSTEXTURE_OUTPUT)0;
	  
	    float3 P = mul(In.Position, mWorldView);            // Position (view space)
	   
	    Out.Position  = mul(float4(P, 1), mProjection);  	// Projected position
	    Out.Diffuse   = In.VertColor;
	    Out.Diffuse.a = In.VertAlpha.x;
	    Out.TexCoord  = In.TexCoord;                        // Texture coordinate
	    
	    return Out;
	#else //if defined(_MAYA_)
		Position = mul(Vertex, mWorldProj);
		UV       = TexCoord.xy;
    	Diffuse  = VertColor;
	#endif
}

#ifdef _3DSMAX_
	float4 mainPS(VSTEXTURE_OUTPUT In) : COLOR0
#else //if defined(_MAYA_)
	float4 mainPS(float2 UV : TEXCOORD2, float4 Diffuse : COLOR0) : COLOR1
#endif
{
	float4 PixelColor;
	
	#ifdef _3DSMAX_
		PixelColor.rgb = tex2D(diffuseTexture, In.TexCoord).rgb * In.Diffuse.rgb;
		PixelColor.a = In.Diffuse.a;
	#else //if defined(_MAYA_)
		PixelColor.rgb = tex2D(diffuseTexture, UV).rgb * Diffuse.rgb;
		PixelColor.a = Diffuse.a;
	#endif
		
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
		#ifdef _3DSMAX_
		
			AlphaBlendEnable = true;
	        SrcBlend         = SRCALPHA;
	        DestBlend        = INVSRCALPHA;
	        
	        VertexShader = compile vs_1_1 mainVS();
	        PixelShader  = compile ps_1_1 mainPS();
		
		#else //if defined(_MAYA_)
		
			VertexShader = compile vs_1_1 mainVS();
			
			ZEnable = true;
			ZWriteEnable = true;
		    ZFunc = LEqual;
			CullMode = Back;

			PixelShader = compile ps_1_1 mainPS();
		
		#endif
	}
}
