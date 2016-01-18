module particle;

import std.random;
import dsfml.graphics;
import app;

alias Vector2f v2f;

//=====================================================================================================================================
// slow particle system !

class ParticleSystem {

	App app;
	Emitter [] emitters;
	Particle [] pool;
	int poolfree;
	bool run;
	VertexArray particles;
	
	this(App app) { 
		
        this.app=app;
        pool.length=20 ;
        poolfree=20;
        run=true;
        particles=new VertexArray(PrimitiveType.Quads,pool.length*4);
        foreach ( int i; 0..pool.length){
        	pool[i]=new Particle();
        }
	}
	
    // trigger a system with an emitter object, from a particle pool
	void trigger(Emitter emitter ) { 
		 
        // if we maxed out the particle pool, enlarge it
		if(poolfree<emitter.number_particles){
			auto required=emitter.number_particles-poolfree;
            poolfree+=required;
            foreach (int i; 0..required){
            	pool~=new Particle();
            	foreach(int j; 0..4){
            		auto v=Vertex();
            		v.position=v2f(0,0);
            		particles.append(v);
            	}
            } 
		}
        auto c=emitter.number_particles;
        foreach (int i; 0..pool.length-1) { 
            auto p=pool[i];
            if (!p.active){
				p.reset(emitter.pos, emitter.init, emitter.behaviours);
				c-=1;
            }
			if(c==0){
                break;
			}
		}
        poolfree-=emitter.number_particles ;
	}
            
    // update all active particles and update the vertex array holding
    // the quad primitives    
	bool update(float shift) { 
 
		if(!run){return false;}
		
        auto active=0;
        foreach (int i ; 0..pool.length-1) { 
         
			if(pool[i].active){
                pool[i].update(shift);
                active+=1;
            }
			else{
				pool[i].pos=v2f(-100,-100);
			}
            auto v=Vertex();
            v.color=pool[i].fillcolor;
            v.position.x=pool[i].pos.x;
            v.position.y=pool[i].pos.y;
            particles[i*4]=v;
            v.position.x+=pool[i].rad;
            particles[i*4+1]=v;
            v.position.y+=pool[i].rad;
            particles[i*4+2]=v;
            v.position.x-=pool[i].rad;
            particles[i*4+3]=v;
  
		}
        poolfree=pool.length-active;
 
        return (active>0);
	}
	
    // draw all active particles     
	void draw( ) { 

		 if(!run){ return;}
		 app.win.draw(particles);
     }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////              
class Emitter {

	App app;
	int number_particles;
	int type;
	bool active;
	void delegate(Particle) init, behaviours;
	v2f pos;
	
    // defines parameters for triggering a system 

	this ( App app, int number, int type, void delegate(Particle) init, void delegate(Particle) behaviours ) { 

         this.app=app;
         number_particles=number ;
         type=type;
         active=true;
         this.init=init;
         this.behaviours=behaviours;
         pos=v2f(0,0);
	}
 
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////       
class Particle {

	void delegate (Particle) behaviours;
	int depth,life,alpha,xmax;
	v2f pos;
	float dir,speed,dx,dy,rad;
	Color fillcolor;
	bool active;
 
	
	this (  ) { 
        
        depth=1;
        dir=0;
        speed=0;
        dx=0;
        dy=0;
        life=0;
        rad=0;
        fillcolor=Color.Red;
        alpha=255;
        active = false;
 
	}
//--------------------------------------------------------------------------------------   
	void reset( v2f pos, void delegate (Particle) init, void delegate (Particle) behaviours) { 

        this.pos=pos;
        depth=1;
        init(this);
        this.behaviours=behaviours;
        active=true;
	}
 
//--------------------------------------------------------------------------------------           
	void update(float shift) { 

        behaviours(this);
        pos.x-=shift/depth;
        life-=1;
		if(life<0){
            active=false;
            pos=v2f(-100,-100);
		}
	}
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////      
