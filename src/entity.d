module entity;

import std.random;
import dsfml.graphics;
import gameevent;
import game,app;

//--------------------------------------------------------------------------------------------------------------------    

enum  {
	DEAD=0,
	QUIESCENT=1,
	ALIVE=2,
	DIE=3,
	DYING=4,
	RESPAWN=5,
	EXPLODE=6 
}

alias Vector2f v2f;

//--------------------------------------------------------------------------------------------------------------------    
// entity class.  entity initialisation, ai and optionally drawing are done by component delegates 
// defined in behaviours.d and assigned in game.initialise()

class Entity {
 
 	void delegate(Entity) draw_component, behaviour, init;
 	string name;
 	App app;
 	int id,status,state,life,explosion_bits,xpix,ypix,dispersion,wait,soundctr,spawndelay,extent;
 	bool enemy, on_screen, fire_bullet,drawhud,touching_player, translate;
 	v2f worldpos,screenpos;
 	Game game;
 	Clock clock;
    float nextfire, next ;
    Color color, hudcolor, explosion_color ;
    Entity parent,target ;
    RectangleShape shape,hudshape;
    Sprite sprite;
    
 	//player specific 
    RectangleShape sprite2;
    float deadtimer;
    v2f dpos;
    v2f offset;
    float speed;
    int direction;
    float dx,dy,ddx,ddy,dmax;
    float dspeed;
    float maxspeed;
    int miny,maxy;
    int screenx_r;
    int screenx_l;
    int nextbomb,nextthink,framecount;
    int thrust;
    int lastthrust;
    bool reversing,firing,picked;
 
 	//--------------------------------------------------------------------------------------------------------------------    

 	this ( int id, 
 		string name, 
 		App app, 
 		Game game,  
 		void delegate (Entity ) init_plugin,  
 		void delegate (Entity ) behaviour_plugin ) 
	{ 

        draw_component=null;
        this.name=name  ;
        this.app=app;
        this.game=game;
        behaviour=behaviour_plugin;
        init=init_plugin;

        this.id=id;
        reset();
        
        
	}
	//--------------------------------------------------------------------------------------------------------------------    

	
	void reset() { 
		
        clock= new Clock();
        nextfire=1.0;
        worldpos=v2f(0,0);
        status=ALIVE;
        state=0;
        translate=true;
        enemy=true;
        screenpos=v2f(0,0);
        on_screen=false;
        explosion_color= Color.White;
        explosion_bits=40;
        xpix=4;
        ypix=4;
        dispersion=0;
        drawhud=false;
        parent=null; 
        touching_player=false;
        hudcolor=Color.White;
        hudshape=new RectangleShape();
        hudshape.size=v2f(10,10);
        hudshape.origin=v2f(5,5);

        init(this );

        hudshape.fillColor=hudcolor;
        sprite=game.sprite_mgr.get_sprite_ref(name);
	}
	
	//--------------------------------------------------------------------------------------------------------------------    

	void set_sprite(string name) { 
        sprite=game.sprite_mgr.get_sprite_ref(name);
	}
	//--------------------------------------------------------------------------------------------------------------------    

	FloatRect getGlobalBounds(){
		if (sprite !is null){
			return sprite.getGlobalBounds();
		}	
		else{
			return shape.getGlobalBounds();
		}
	}
	//--------------------------------------------------------------------------------------------------------------------    

	void update() { 

		if(status!=DEAD && (sprite !is null || shape !is null )){

			if(status==EXPLODE){
	            dispersion+=3;
			}
			if(dispersion>200){
	            status=DEAD;
	            return;
			}
	        
	        behaviour(this);
	
			if (status==DIE){
	                status=EXPLODE;
			}
	        on_screen=app.globals.on_screen(worldpos);
			auto x=worldpos.x ;
			auto y=worldpos.y ;
		 
			if (translate) {
	            screenpos=app.globals.screen_pos(worldpos);
				if (x>app.globals.worldwidth){
	                x-=app.globals.worldwidth;
					if(x<0){ 
	                   x+=app.globals.worldwidth;
	                }
	        	}
	        }
	        else{
	             screenpos.y=y;
	             on_screen=true;
			}	
	        if (sprite !is null )
	        	sprite.position=screenpos;
	
			if (on_screen && status==ALIVE){
	                collisioncheck();
			}
			worldpos=v2f(x,y);
	
		}
	}

    //--------------------------------------------------------------------------------------------------------------------    
	void set_draw_component(void delegate(Entity) func) { 

        draw_component=func;
	}
	//--------------------------------------------------------------------------------------------------------------------    
	void draw() { 
			
		 
		if(status>QUIESCENT && status!=RESPAWN){

			if(on_screen){
                sprite.position=screenpos;
				if(draw_component !is null ){
                    draw_component(this);
                }
                else {
                    app.win.draw(sprite);
                }
            }  
		
			if(drawhud && status==ALIVE){
                hudshape.fillColor=hudcolor;
                game.hud.draw_entity(hudshape,worldpos);
			}
		}
	}
	//--------------------------------------------------------------------------------------------------------------------    
	void collisioncheck() { 

        touching_player=false;
        if ( dispersion==0 || name=="human" ){
			if(game.player.status==ALIVE){
				if(app.globals.intersects(this, game.player)){
	                touching_player=true;
					if(enemy){
	                    game.player.kill();
	                    kill();
					}
				}
			}
		}
		if((enemy && name != "bullet" && name != "bomb" ) || name=="human"){
			if(game.laser_mgr.check_hit(this)){
                kill()  ;		
			}
		}
	}		
    //--------------------------------------------------------------------------------------------------------------------    
 
	void kill() { 
		if(app.config.nodie && name=="player"){
            return;
        }
		if(status==ALIVE){
            speed=0;
            status=DIE;
            clock.restart();
			if(name!="player"){
                game.event_handler.notify(gameevent.DIED,this);
			}
		}
	}
}