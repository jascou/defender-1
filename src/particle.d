module particle;

import std.random;
import dsfml.graphics;
import app;

alias Vector2f v2f;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////       
class ParticleSystem {

	App app;
	Emitter [] emitters;
	Particle [] pool;
	int poolfree;
	bool run;
	
	this(App app) { 
		
        this.app=app;
        pool.length=400;
        poolfree=400;
        run=true;
        foreach (int i; 0..pool.length){
        	pool[i]=new Particle();
        }
	}
	
    // trigger a system with an emitter object, from a particle pool
	void trigger(Emitter emitter ) { 

        // if we maxed out the particle pool, enlarge it
		if(poolfree<emitter.number_particles){
			auto required=emitter.number_particles-poolfree;
            pool.length+=required;
            poolfree+=required;
            foreach (int i; 0..required){
            	pool~=new Particle();
            } 
		}
        auto c=emitter.number_particles;
        foreach (int i; 0..pool.length-1) { 
            auto p=pool[i];
            if (!p.active){
				p.reset(emitter.pos, emitter.init, emitter.behaviours);
            }
            c-=1;
			
			if(c==0){
                break;
			}
		}
        poolfree-=emitter.number_particles ;
	}
            
    // update all active particles       
	bool update(float shift) { 

		if(!run){
			return false;
		}
		
        auto active=0;
        foreach (int i ; 0..pool.length-1) { 
			if(pool[i].active){
                pool[i].update(shift);
                active+=1;
			}
		}
        poolfree=pool.length-active;
        return (active>0);
	}
	
    // draw all active particles     
	void draw( ) { 

		 if(!run){
             return;
		 }
         foreach (int i ; 0..pool.length-1 ) { 
			if(pool[i].active==1){
               app.win.draw(pool[i].get_sprite());
			}
		 }
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
	int depth,life, points,alpha,xmax;
	v2f pos;
	float dir,speed,dx,dy,rad;
	Color fillcolor,outcolor;
	bool active;
	CircleShape circ;
	
	this (  ) { 
        
        depth=1;
        dir=0;
        speed=0;
        dx=0;
        dy=0;
        life=0;
        rad=0;
        fillcolor=Color.Red;
        outcolor=Color.White;
        points=20;
        alpha=255;
        active = false;

        circ = new CircleShape();
        circ.fillColor = fillcolor;
        circ.outlineColor = outcolor;
        circ.outlineThickness = 1;
        circ.radius = rad;
        circ.position = pos;
        circ.pointCount=points;
	}
//--------------------------------------------------------------------------------------   
	void reset( v2f pos, void delegate (Particle) init, void delegate (Particle) behaviours) { 

        this.pos=pos;
        depth=1;
        init(this);
        this.behaviours=behaviours;
        active=true;
        circ.pointCount=points;
        circ.fillColor = fillcolor;
        circ.outlineColor = outcolor;
	}
//--------------------------------------------------------------------------------------     
	CircleShape get_sprite( ) { 

         return circ;
	}
//--------------------------------------------------------------------------------------           
	void update(float shift) { 

        behaviours(this);
        pos.x-=shift/depth;
        circ.fillColor=fillcolor;
        circ.outlineColor=outcolor;
        life-=1;
		if(life<0){
            active=false;
		}
        circ.position=pos     ;
        circ.radius=rad;
	}
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////      
