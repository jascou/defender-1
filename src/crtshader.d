module crtshader;

import dsfml.graphics, dsfml.window;

class CRTShader
{

    string vert;
    string frag;
    Shader mshader;
    int pal_length;
    float time;

    this(RenderWindow win)
    {
        if (!Shader.isAvailable())
        {
            throw new Exception("Shaders not available");
        }

        time = 0.0F;

        vert = r"void main()
        {
            vec4 vertex = gl_Vertex;
            gl_Position = gl_ModelViewProjectionMatrix * vertex;
            gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
            gl_FrontColor = gl_Color;
        }
        ";
        frag = r" 
 		uniform sampler2D texture;
 		float blur_radius=0.002f;
 		
        void main() {
	        vec2 q = gl_TexCoord[0].st; 
	
	        vec3 col = texture2D(texture,vec2(q.x,q.y)).xyz;
	        col *= 0.3+0.7*sin( q.y*1500.0);
	        //col *= vec3(1.5,1.5,1.5);
	        
	        vec2 offx = vec2(blur_radius, 0.0);
    		vec2 offy = vec2(0.0, blur_radius);

    		vec4 pixel = texture2D(texture, gl_TexCoord[0].xy) * 4.0 +
		                 texture2D(texture, gl_TexCoord[0].xy - offx) * 2.0 +
		                 texture2D(texture, gl_TexCoord[0].xy + offx)* 2.0 +
		                 texture2D(texture, gl_TexCoord[0].xy - offy) * 2.0 +
		                 texture2D(texture, gl_TexCoord[0].xy + offy) * 2.0 +
		                 texture2D(texture, gl_TexCoord[0].xy - offx - offy) * 1.0 +
		                 texture2D(texture, gl_TexCoord[0].xy - offx + offy) * 1.0 +
		                 texture2D(texture, gl_TexCoord[0].xy + offx - offy) * 1.0 +
		                 texture2D(texture, gl_TexCoord[0].xy + offx + offy) * 1.0;

     
        	gl_FragColor = gl_Color * mix(vec4( col,1.0),pixel,0.05) ;   

        }
        ";
        mshader = new Shader();
        if (!mshader.loadFromMemory(vert, Shader.Type.Vertex))
        {
            throw new Exception("Shader loader exception");
        }
        if (!mshader.loadFromMemory(frag, Shader.Type.Fragment))
        {
            throw new Exception("Shader loader exception");
        }

        mshader.setParameter("texture", Shader.CurrentTexture);
        mshader.setParameter("uResolution", cast(float) win.size.x, cast(float) win.size.y);

    }

}
