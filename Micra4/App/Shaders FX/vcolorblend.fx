//////////////////////////////////////////////////
// mix two textures based on vcolor/valpha
// optionally multiply with vcolor and/or simple lighting
//
// three techniques
//   Blend2_AB just AB Base textures
//   Blend2_AB_om mix and apply overlay/multiply textures)
//   Blend4_ABCD  mix based on VertexColor, where D textures weight is (1-sum(RGB))
// history
//   29.10.2007: Blend4 textures
//   dont remember: Blend2_AB_om multiply/overlay
//   dont remember: Blend2_AB first version just base
//
// Christoph 'CrazyButcher' Kubisch - www.luxinia.de


///////////////////////////////////////////////////
// Tweakables

// the textures first
texture aTexture : MapA < 
	string UIName = "Tex A";
	int Texcoord = 0;		// the TEXCOORDx number in APP_INPUT
	int MapChannel = 1;		// the UV Channel in 3dsmax
>;
	
texture bTexture : MapB < 
	string UIName = "Tex B";
	int Texcoord = 1;
	int MapChannel = 1;	
>;


texture aoTexture : MapAO < 
	string UIName = "Tex A Overlay / C";
	int Texcoord = 4;
	int MapChannel = 1;	
>;
	
texture boTexture : MapBO < 
	string UIName = "Tex B Overlay / D";
	int Texcoord = 5;
	int MapChannel = 1;	
>;

texture amTexture : MapAO < 
	string UIName = "Tex A Multiply";
	int Texcoord = 6;
	int MapChannel = 1;	
>;
	
texture bmTexture : MapBO < 
	string UIName = "Tex B Multiply";
	int Texcoord = 7;
	int MapChannel = 1;	
>;
	
	
// LightDirection is in WorldSpace
float3 lightDir : Direction 
<  
	string UIName = "Target Light";
	string Object = "TargetLight";
> = {-0.577, -0.577, 0.577};

bool g_MulColor <
	string UIName = "Multiply with VColor (Blend2) or VAlpha (Blend4)";
> = false;

bool g_MulLight <
	string UIName = "Lit";
> = true;

bool g_BlendAlpha <
	string UIName = "Toggle Blend2 via VAlpha / VColor";
> = true;

///////////////////////////////////////////////////
// Internals


// some matrices we need, the : links our variable with some 3dsmax internal
float4x4 World      : 		WORLD;
float4x4 View       : 		VIEW;
float4x4 Projection : 		PROJECTION;
float4x4 WorldViewProj : 	WORLDVIEWPROJ;
float4x4 WorldView : 		WORLDVIEW;


int texcoord2 : Texcoord
<
	int Texcoord = 2;
	int MapChannel = 0;		// 3dsmax vertex color
>;
int texcoord3 : Texcoord
<
	int Texcoord = 3;
	int MapChannel = -2;	// 3dsmax vertex alpha
>;

// turn our textures into samplers
// a sampler is basically a texture with extra information
// such as texture filtering
// in our case we set all to trilinear filtering

sampler aSampler = sampler_state
{
    Texture   = (aTexture);
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};


sampler bSampler = sampler_state
{
    Texture   = (bTexture);
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

sampler aoSampler = sampler_state
{
    Texture   = (aoTexture);
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

sampler boSampler = sampler_state
{
    Texture   = (boTexture);
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

sampler amSampler = sampler_state
{
    Texture   = (amTexture);
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

sampler bmSampler = sampler_state
{
    Texture   = (bmTexture);
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

///////////////////////////////////////////////////
// Shaders
///////////////////////////////////////////////////


// the 
struct APP_INPUT
{
	float3 Pos  : POSITION;
	float3 Norm : NORMAL;
	float2 ATex  : TEXCOORD0;
	float2 BTex : TEXCOORD1;
	float3 Color : TEXCOORD2;	// vertex color
	float3 Alpha : TEXCOORD3;	// vertex alpha
	
	float2 ATexO  : TEXCOORD4;
	float2 BTexO : TEXCOORD5;
	
	float2 ATexM  : TEXCOORD6;
	float2 BTexM : TEXCOORD7;
};

// the data our vertex shader outputs
// we don't need to write all values
struct VS_OUTPUT
{
	float4 Pos : POSITION;		// MUST Be written to
	float4 Color: COLOR0;
	float4 Light: COLOR1;
	float2 ATex :TEXCOORD0;
	float2 BTex : TEXCOORD1;
	
	float2 ATexO  : TEXCOORD2;
	float2 BTexO : TEXCOORD3;
	float2 ATexM  : TEXCOORD4;
	float2 BTexM : TEXCOORD5;
};


///////////////////////////////////////////////////
//	Vertex
//
//	Vertex-Shader gets data from Application (3dsmax)
//	and should write to the data needed in the pixelshader

VS_OUTPUT VS(APP_INPUT In)
{

    VS_OUTPUT Out = (VS_OUTPUT)0;
    float3 L = lightDir;	// parallel light for simplicity (world space)
    
    // via multiplication we turn our Points/Normals (in object space)
    // into the space we need
    // we do lighting in world space, because max gives us lightDir in that
    
    float3 P = mul(float4(In.Pos, 1),(float4x4)World);  // position (world space)
    float3 N = normalize(mul(In.Norm,(float3x3)World)); // normal (world space)
    
    // straight turn position from object->projected 
    // (that is a -1,+1 box which is our viewport)
    Out.Pos  = mul(float4(In.Pos,1),WorldViewProj);    // position (projected)
	
    // write texcoords
	Out.ATex = In.ATex;
	Out.BTex = In.BTex;
	
	// output vertexcolor as single vector
	Out.Color.xyz = In.Color;
	Out.Color.w = In.Alpha.x;
	
	// store lighting
	// light influence is dotproduct of Normal and LightDirection
	// for normalized vectors the dotproduct is the cosine of the angle between 
	// them, that means the output of dot can be -1 to +1
	// +1 = vectors are pointing in same direction
	// 0 = vectors are perpendicular (90° angle)
	// -1 = vectors are pointing in opposite direction
	// anything below is "backfacing to the light" therefore we stop at 0
	// saturate keeps values between 0 and 1
	// we add the 0.2 for a little ambient light
	Out.Light = saturate(dot(N, L)) + 0.2;
	
	return Out;
   
}

VS_OUTPUT VS_full(APP_INPUT In)
{

	// same as above just writing more texcoords
    VS_OUTPUT Out = (VS_OUTPUT)0;
    float3 L = lightDir;
    float3 P = mul(float4(In.Pos, 1),(float4x4)World);  // position (view space)
    float3 N = normalize(mul(In.Norm,(float3x3)World)); // normal (view space)
    Out.Pos  = mul(float4(In.Pos,1),WorldViewProj);    // position (projected)
	
	Out.ATex = In.ATex;
	Out.BTex = In.BTex;
	Out.ATexO = In.ATexO;
	Out.BTexO = In.BTexO; 
	Out.ATexM = In.ATexM;
	Out.BTexM = In.BTexM; 
	Out.Color.xyz = In.Color;
	Out.Color.w = In.Alpha.x;
	Out.Light = saturate(dot(N, L)) + 0.2;
	
	return Out;
   
}


///////////////////////////////////////////////////
//	Pixel
//
//	Every pixel must write to color
//	and gets as input the data from the vertex shader
float4 PS(VS_OUTPUT In) : COLOR
{
	// fetch texel from the textures using the texturecoords
	// passed from VertexShader
    float4 colora = tex2D(aSampler, In.ATex);
    float4 colorb = tex2D(bSampler, In.BTex);
    float4 color;
    
    // note about the "if"
    // in ps_2_0 profile (as used here, see further down)
    // everything will be calculated
    // so pixelshader cost is always both paths
    // only since pixel shader 3 we have real conditional
    // "ifs", however even those come with a small cost
    
    // decide whether to blend via vertexalpha or vertexcolor intensity
    if (g_BlendAlpha)
		color =  lerp(colora,colorb,In.Color.w);
    else							// the dot product here makes intensity out of RGB
    	color = lerp(colora,colorb,dot(In.Color.xyz,float3(0.3f, 0.59f, 0.11f)));
    
    // in case user wants to have visible vertexcolors
    if (g_MulColor)
    	color *= In.Color;
    
    // and if lighting should be applied
    if (g_MulLight)
    	color *= In.Light;
    
    return color;
}


// a function to perform overlay blending
float4 overlay(float4 a,float4 b)
{
	float4 color;
	
	// overlay has two output possbilities
	// which is taken is decided if pixel value
	// is below half or not
	// step(x,y): x <= y ? 0 : 1;
	
	color = step(a,0.5);
	
	
	
	// we pick either solution
	// depending on pixel
	
	// first is case of < 0.5
	// second is case for >= 0.5
	
	// interpolate between the two, 
	// using color as influence value
	color = lerp((a*b*2),(1.0-(2.0*(1.0-a)*(1.0-b))),color);
	
	return color;
}


float4 PS_AB_om(VS_OUTPUT In) : COLOR
{
	// first grab diffuse
    float4 colora = tex2D(aSampler, In.ATex);
    float4 colorb = tex2D(bSampler, In.BTex);
    
    // overlay
    colora = overlay(colora,tex2D(aoSampler,In.ATexO));
    colorb = overlay(colorb,tex2D(boSampler,In.BTexO));
    
    // multiply
    colora *= tex2D(amSampler, In.ATexM);
    colorb *= tex2D(bmSampler, In.BTexM);
    
  
    float4 color;
    if (g_BlendAlpha)
		color =  lerp(colora,colorb,In.Color.w);
    else
    	color = lerp(colora,colorb,dot(In.Color.xyz,float3(0.3f, 0.59f, 0.11f)));

    if (g_MulColor)
    	color *= In.Color;

    if (g_MulLight)
    	color *= In.Light;
    
    return color;	
}

float4 PS_ABCD(VS_OUTPUT In) : COLOR
{
	// first grab diffuse
    float4 colora = tex2D(aSampler, In.ATex);
    float4 colorb = tex2D(bSampler, In.BTex);
    float4 colorc = tex2D(aoSampler,In.ATexO);
	float4 colord = tex2D(boSampler,In.BTexO);
	
	float4 weight = float4(In.Color.xyz,saturate(1-dot(In.Color.xyz,float3(1,1,1))));
	// normalize
	weight /= dot(float4(1,1,1,1),weight);
	
	float4 color = (weight.x*colora) + (weight.y*colorb) + (colorc*weight.z) + (colord*weight.w);
	
    if (g_MulColor)
		color *= In.Color.w;

    if (g_MulLight)
    	color *= In.Light;
    
    return color;	
}

///////////////////////////////////////////////////
//	Techniques
//
//	a technique is basically the vertex/pixel shader pair
//	that is used for rendering
//	you can pick the technique you like in max itself
//	


technique Blend2_AB
{
	// techniques are made of passes 
	// each pass means one drawcall
	// you cannot access previous pass' results
	// only do blending like additive/multiply
	// or do alphamasking
	
    pass P0	
    {
	    // by default max does alphablend = transparency
	    // we dont want that
    	AlphaBlendEnable	= FALSE;	
    									
    												
    	// we must compile our shaders for the graphics card
    	// the argument after compile is the profile
    	// each profile has certain capabilities/limits in complexity
    	
    	// vs_1_1 is sufficient for most simple vertex-shaders
        VertexShader = compile vs_1_1 VS();	
        
        // ps_2_0 is shadermodel 2.0 pixelshader
        // which also is sufficient for most stuff
        PixelShader  = compile ps_2_0 PS();
    }  
}

// same as above but now we use overlay and multiply textures
technique Blend2_AB_MultiplyOverlay
{
    pass P0
    {
    	AlphaBlendEnable	= FALSE;
        VertexShader = compile vs_1_1 VS_full();
        PixelShader  = compile ps_2_0 PS_AB_om();
    }  
}

technique Blend4_ABCD
{
    pass P0
    {
    	AlphaBlendEnable	= FALSE;
        VertexShader = compile vs_1_1 VS_full();
        PixelShader  = compile ps_2_0 PS_ABCD();
    }  
}