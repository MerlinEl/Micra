/ This is used by 3dsmax to load the correct parser

string description = "Simple Glass Shader";

//------------------------------------
float4x4 worldViewProj : WorldViewProjection;
float4x4 world   : World;
float4x4 worldInverseTranspose : WorldInverseTranspose;
float4x4 viewInverse : ViewInverse;

	texture diffuseTexture : Diffuse
	<
		string ResourceName = "default_color.dds";
	>;

	float4 g_lightPos : Position < 
		string UIName = "Light Direction";
		string Object = "TargetLight";
		int RefID = 0;
	> = {10, 10, 10,1};
	
	float4 g_lightColor : LightColor
	<
    	//string UIName = "Diffuse";
    	int LightRef = 0;
	> = {1.0f, 1.0f, 1.0f, 1.0f};

	float4 g_lightAmbient : Ambient
	<
    	string UIWidget = "Ambient";
    	string UIName = "Ambient";
    	string Space = "material";
	> = {1.0f, 1.0f, 1.0f, 1.0f};
	
	float4 g_materialDiffuse : Diffuse
	<
    	string UIWidget = "Diffuse";
    	string UIName = "Diffuse";
    	string Space = "material";
	> = {1.0f, 1.0f, 1.0f, 1.0f};
	
	float4 g_materialSpecular : Specular
	<
		string UIWidget = "Specular";
		string UIName = "Specular";
		string Space = "material";
	> = {1.0f, 1.0f, 1.0f, 1.0f};

//#endif

float g_shininess : SpecularPower
<
    string UIWidget = "slider";
    float UIMin = 1.0;
    float UIMax = 128.0;
    float UIStep = 1.0;
    string UIName = "specular power";
> = 30.0;

float g_rimpower
<
    string UIWidget = "slider";
    float UIMin = 0.0;
    float UIMax = 64.0;
    float UIStep = 0.1;
    string UIName = "rim power";
> = 3.0;

float g_rimstrength
<
    string UIWidget = "slider";
    float UIMin = 0.0;
    float UIMax = 10.0;
    float UIStep = 0.01;
    string UIName = "rim strength";
> = 0.5;

float g_transparency
<
    string UIWidget = "slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
    float UIStep = 0.01;
    string UIName = "Opacity";
> = 0.5;

bool g_rim <
	string UIName = "Rim for Light";
> = true;

//------------------------------------
struct vertexInput {
    float3 position				: POSITION;
    float3 normal				: NORMAL;
    float4 texCoordDiffuse		: TEXCOORD0;
};

struct vertexOutput {
    float4 hPosition		: POSITION;
    float4 texCoordDiffuse	: TEXCOORD0;
    float4 diffAmbColor		: COLOR0;
    float4 specCol			: COLOR1;
};


void	lighting_twosided_spec_rim( float3 N, float3 L, float3 E, float3 H,
		out float4 outdiffcolor, out float4 outspec)
{
	//calculate the diffuse and specular contributions
    float  diff = abs(dot(N,L));
    float  specsign = dot(N,H);
    float  spec = pow( abs(specsign) , g_shininess );
    if (specsign <= 0){
    	spec *= (1-g_transparency);
    }
    //float  rim = pow( max(0 , (1-dot(N,E)) ) , shininess );
    float rim;
    if (g_rim){
    	rim = dot(N,L);
    }
    else{
    	rim = dot(N,E);
    }
    rim = pow(1-abs(rim), g_rimpower) * g_rimstrength;
       

	//output diffuse
    float4 ambColor = g_materialDiffuse * g_lightAmbient;
    float4 diffColor = g_materialDiffuse * diff * g_lightColor ;
    outdiffcolor = diffColor + ambColor;

	//output specular
	spec += rim;
    float4 specColor = g_materialSpecular * g_lightColor * spec;
    outspec = specColor;
    specColor.w = 0;
    
    // rimlight
    outdiffcolor.w = spec + g_transparency;
}

//------------------------------------
vertexOutput VS_TransformSpecRim(vertexInput IN) 
{
    vertexOutput OUT;
    OUT.hPosition = mul( float4(IN.position.xyz , 1.0) , worldViewProj);
    OUT.texCoordDiffuse = IN.texCoordDiffuse;

	//calculate our vectors N, E, L, and H
	float3 worldEyePos = viewInverse[3].xyz;
    float3 worldVertPos = mul(IN.position, world).xyz;
    float3 worldLightPos = mul(g_lightPos, world).xyz;
	float4 N = mul(IN.normal, worldInverseTranspose); //normal vector
    float3 E = normalize(worldEyePos - worldVertPos); //eye vector
    float3 L = normalize(worldEyePos - worldLightPos ); //light vector
    float3 H = normalize(E + L); //half angle vector

	lighting_twosided_spec_rim(N,L,E,H,OUT.diffAmbColor,OUT.specCol);

    return OUT;
}


//------------------------------------
sampler TextureSampler = sampler_state 
{
    texture = <diffuseTexture>;
    AddressU  = CLAMP;        
    AddressV  = CLAMP;
    AddressW  = CLAMP;
    MIPFILTER = LINEAR;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};


//-----------------------------------
float4 PS_Simple( vertexOutput IN): COLOR
{
  //float4 diffuseTexture = tex2D( TextureSampler, IN.texCoordDiffuse );
  float4 outcolor = IN.diffAmbColor  + IN.specCol;
  
  return outcolor;
}

struct vertexOutputSpec {
    float4 hPosition		: 	POSITION;
    float4 texCoordDiffuse	: 	TEXCOORD0;
    float3 N				:	TEXCOORD1;
    float3 L				:	TEXCOORD2;
    float3 E				:	TEXCOORD3;
    float3 H				:	TEXCOORD4;
};


//------------------------------------
vertexOutputSpec VS_TransformPrep(vertexInput IN) 
{
    vertexOutputSpec OUT;
    OUT.hPosition = mul( float4(IN.position.xyz , 1.0) , worldViewProj);
    OUT.texCoordDiffuse = IN.texCoordDiffuse;

	//calculate our vectors N, E, L, and H
	float3 worldEyePos = viewInverse[3].xyz;
    float3 worldVertPos = mul(IN.position, world).xyz;
    float3 worldLightPos = mul(g_lightPos, world).xyz;
	OUT.N = mul(IN.normal, worldInverseTranspose); //normal vector
   	float3 E = normalize(worldEyePos - worldVertPos); //eye vector
    float3 L = normalize(worldEyePos - worldLightPos ); //light vector
    OUT.H = normalize(E + L); //half angle vector
    
    OUT.E = E;
    OUT.L = L;
	
	return OUT;
}

float3 mynormalize(float3 vec){
	float3 outvec;
	outvec = normalize(vec);
	
	return outvec;
}

//-----------------------------------
float4 PS_SpecRim( vertexOutputSpec IN): COLOR
{
	

	float3 N = mynormalize(IN.N);
	float3 L = mynormalize(IN.L);
	float3 H = mynormalize(IN.H);
	float3 E = mynormalize(IN.E);

	float4 specColor;
	float4 diffColor;
	
  	lighting_twosided_spec_rim(N,L,E,H,diffColor,specColor);
    
    float4 outcolor = diffColor + specColor;
  
  return outcolor;
}

//-----------------------------------
technique pervertex_notex
{
    pass p0 
    {	
    	CullMode = ccw;
    	AlphaBlendEnable	= TRUE;
		DestBlend		= InvSrcAlpha;  
		SrcBlend		= SrcAlpha;
		VertexShader = compile vs_1_1 VS_TransformSpecRim();
		PixelShader  = compile ps_1_1 PS_Simple();
    }
  
    pass p1 
    {		
    	CullMode = cw;
    	AlphaBlendEnable	= TRUE;
		DestBlend		= InvSrcAlpha;  
		SrcBlend		= SrcAlpha;
		VertexShader = compile vs_1_1 VS_TransformSpecRim();
		PixelShader  = compile ps_1_1 PS_Simple();
    }
  
}

technique perpixel_notex
{
    pass p0 
    {	
    	CullMode = ccw;
    	AlphaBlendEnable	= TRUE;
		DestBlend		= InvSrcAlpha;  
		SrcBlend		= SrcAlpha;
		VertexShader = compile vs_1_1 VS_TransformPrep();
		PixelShader  = compile ps_2_0 PS_SpecRim();
    }
  
    pass p1 
    {		
    	CullMode = cw;
    	AlphaBlendEnable	= TRUE;
		DestBlend		= InvSrcAlpha;  
		SrcBlend		= SrcAlpha;
		VertexShader = compile vs_1_1 VS_TransformPrep();
		PixelShader  = compile ps_2_0 PS_SpecRim();
    }
  
}