module lasers;

import dsfml.graphics;
import entity, std.math, std.random;
import behaviours,app,game;
 
alias Vector2f v2f;

const LASER_POOL=10;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class LaserMgr {
     
    App app;
    Game game;
    Entity[] laserlist;
	bool run;
	 
	Color[] colors;
	int colorindex;
	int current; 
	
    //---------------------------------------------------------------------------------------------------------------------
	this(App app, Game game ) { 
		
        this.app=app;
        game=game;
        gen_colors(3);
        colorindex=0;
        run=true;
		
        foreach( int i ; 0..LASER_POOL){
            auto b=new Entity(i, "laser", app, game,  laser_init(),  laser_control() );
            b.shape=new RectangleShape();
            laserlist~=b;
		}
        current=0;
    }
    //---------------------------------------------------------------------------------------------------------------------
	void update( ) { 

		if(!run){
            return;
        }          
        foreach ( b ; laserlist) {
			if(b.status==entity.ALIVE){
                b.update();
            }
		}
    }
    //---------------------------------------------------------------------------------------------------------------------        
	void draw( ) { 

		if(!run){
            return;
        }
        foreach (l ; laserlist){
			if(l.status==entity.ALIVE){
                l.shape.fillColor=l.color;
                l.shape.position=v2f(l.worldpos.x,l.worldpos.y);
                app.win.draw(l.shape); 
   				foreach (i; 0..10){
   					
   					float px;
   					if ( l.extent > 0 ){
   						px=uniform(l.worldpos.x,l.worldpos.x + l.extent );
   					}
   					else{
   						px=uniform(l.worldpos.x+l.extent,l.worldpos.x  );
   					}
   					l.shape.position=v2f(px,l.worldpos.y-2);
   					l.shape.size=v2f(uniform(2,20),1);
   					app.win.draw(l.shape);
   					l.shape.position=v2f(px,l.worldpos.y+6);
   					l.shape.size=v2f(uniform(2,20),1);
   					app.win.draw(l.shape);
   				}
            }
		}
	}
    //---------------------------------------------------------------------------------------------------------------------            
	void fire( v2f pos, int dir) { 

        current+=1;
		if(current==LASER_POOL){
            current=0;
		}
        auto b=laserlist[current];
        b.status=entity.ALIVE;
        b.worldpos=pos;
        b.life=200;
        b.dpos=v2f(dir*15,0);
        b.extent=20;
        b.color=nextcolor();
        laserlist[current]=b;
	}
    //---------------------------------------------------------------------------------------------------------------------    
	bool check_hit(Entity ent) { 

        //tbd: debug hits not working - world boundary??? 
        
         foreach ( int i ; 0..LASER_POOL){

	        auto b=laserlist[i];
			if(b.status==entity.ALIVE){
                 
				if(app.globals.intersects(b,ent)){
                    b.status=entity.DEAD ;
                    laserlist[i]=b;
                    return true;
				}
                auto ent_b=ent.sprite.getLocalBounds();

                auto x1=b.screenpos.x ;
                auto x2=b.screenpos.x + b.extent ;
                if  ( x1 < ent.screenpos.x && x2 >  ent.screenpos.x  
                      && b.screenpos.y > ent.screenpos.y-ent_b.height/2  
                      && b.screenpos.y < ent.screenpos.y+ent_b.height/2){
                    b.status=entity.DEAD ;
                    laserlist[i]=b;
                    return true;
				}
            }
		}
        return false;   
    }
	//---------------------------------------------------------------------------------------------------------------------    
	void gen_colors(int delta){
		
		auto cols=[ Color.Yellow, Color.Cyan, Color.Green, Color.Blue, Color.Magenta , Color.Red ];
		foreach ( Color c; cols ){
			foreach ( int i; 0..delta ){
				colors~=c;
			}
		}
	}
	//---------------------------------------------------------------------------------------------------------------------    
	Color nextcolor(){
		
		auto col=colors[colorindex];
		colorindex++;
		if ( colorindex == colors.length )
		{
			colorindex=0;
		}
		return col;
	}
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// entity plugins 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

auto laser_init() { 

	auto _initialise = delegate void(Entity p) { 

        p.worldpos=v2f(0,0);
        p.life=200;
        p.status=entity.DEAD;
        p.dpos=v2f(0,0);
        p.shape=new RectangleShape();
        p.color=Color.Yellow;
        p.extent=0;
        p.translate=false;
        p.enemy=false;
 	};
 	return _initialise;
 }
 

//---------------------------------------------------------------------------------------------------------------------
auto  laser_control() { 

	auto _ai=delegate void(Entity p) { 

        p.worldpos+=p.dpos;
 
		if(abs(p.extent)<p.app.win.size.x){
            p.extent+=cast(int)p.dpos.x*5;
        }
		if ( p.worldpos.x<0 || p.worldpos.x>p.app.win.size.x ){
            p.status=entity.DEAD;
        }
        p.shape.size=v2f(p.extent,3);
        p.life-=1;
		if(p.life==0){
            p.status=entity.DEAD;
        }
	};
    return _ai ;
}
//---------------------------------------------------------------------------------------------------------------------
auto make_laser_shape() { 

	auto _make = delegate Shape() { 
        auto p=new RectangleShape();

        return p;
	};
    return _make;
}
 