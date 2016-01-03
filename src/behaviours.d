module behaviours;

import std.random, std.math;
import dsfml.graphics;
import game, entity, gameevent,app, particle;
import std.stdio;

// constants;
enum {
	LANDER_DROPPING=0,  
	LANDER_SEARCHING=1,  
	HOVER_HEIGHT=100,  
	HUMAN_GROUND=2,  
	HUMAN_CARRIED=3,  
	HUMAN_DROPPED=4,  
	LANDER_GRABBING=5,  
	LANDER_ABDUCTING=6,  
	LANDER_MUTATED=7,  
	HUMAN_PICKED=8,   
	BAITER_WAIT=9,  
	BAITER_SPAWN=10,  
	BAITER_ATTACK=11,  
	LANDER_WAITING=12,  
	LANDER_MUTATE=13   
};
 

alias Vector2f v2f;

//#######################################################################################################################
//# particle system plugins
//#######################################################################################################################
auto  move_explosion() { 

	auto _move = delegate void (Particle p) { 
	
       auto position=v2f(p.pos.x,p.pos.y);
       position+=v2f(p.dx,p.dy);
       p.pos=position;
       if (p.pos.y < 160) 
           p.active=0; 
	};
    return _move;
} 
//#######################################################################################################################
auto  init_explosion(Entity e) { 

	auto _initialise = delegate void(Particle p) { 

        p.dir=PI* uniform(0.0,2.0);
        p.speed= uniform(5,20);
        p.dx= cos(p.dir) * p.speed;
        p.dy=  sin(p.dir) * p.speed;
        p.life=uniform(50,100);
        p.rad=5;
        p.fillcolor=e.explosion_color;
        p.outcolor=e.explosion_color ;
        p.points=4;
        p.alpha=255;
	}; 
    return _initialise;
}  
//#######################################################################################################################
auto  init_world_explosion() { 

	auto _initialise = delegate void(Particle p) { 

        p.dir=PI* uniform(0.0,2.0);
        p.speed= uniform(1,3);
        p.dx= cos(p.dir) * p.speed;
        p.dy=  sin(p.dir) * p.speed;
        p.life=200;
        p.rad=3;
        p.fillcolor=Color(200,150,0);
        p.outcolor=Color(200,150,0);
        p.points=4;
        p.alpha=255;
	};
	
    return _initialise;
} 
//#######################################################################################################################
auto  init_player_explosion(Entity ent) { 

	auto _initialise = delegate void(Particle p) { 

        p.dir=PI* uniform(0.0,2.0);
        p.speed= uniform(5,40);
        p.dx= cos(p.dir) * p.speed;
        p.dy=  sin(p.dir) * p.speed;
        p.life=uniform(50,100);
        p.rad=10;
        p.fillcolor=ent.explosion_color;
        p.outcolor=ent.explosion_color ;
        p.points=4;
        p.alpha=255;
	};
    return _initialise;

} 
//#######################################################################################################################
auto  move_player_explosion() { 

	auto _move = delegate void (Particle p) { 

       auto position=v2f(p.pos.x,p.pos.y);
       position+=v2f(p.dx,p.dy);
       p.pos=position;
       p.dx/=1.05;
       p.dy/=1.05;
       p.dy+=0.1;
       p.rad/=1.01;
       auto r=p.fillcolor.r;
       auto g=p.fillcolor.g;
       auto b=p.fillcolor.b;
       auto a=p.fillcolor.a;
       if (g > 3 && b > 3){
           g-=3;
           b-=3;
       } 
       p.fillcolor= Color(r,g,b);
       p.outcolor= Color(r,g,b);
        
	} ;
	
    return _move;
} 
//#######################################################################################################################
auto  star() { 

	auto _move = delegate void (Particle p) { };
    return _move;
} 
//#######################################################################################################################
auto  star_init(App app) { 

	auto _initialise = delegate void(Particle p) { 

        p.pos=v2f(uniform(-200F,uniform(0,app.win.size.x)+200F),uniform(160F,app.win.size.y-200F));
        p.dx=0;
        p.dy=0;
        p.life=uniform(40,60);
        p.rad=1;
        p.fillcolor=randcol2();
        p.outcolor=randcol2();
        p.points=6;
        p.alpha=255;
        p.xmax=app.win.size.x;
        p.depth=2;
	};
    return _initialise;
} 
 
//#######################################################################################################################
//# entity plugins follow...
//#######################################################################################################################

auto  null_ai( ) { 

	auto _ai = delegate void  (Entity p) { };
    return _ai;
} 
//#######################################################################################################################
//# replacement draw component for entities, implements explosions/materialisations. dispersion attribute controls
//# the spread of sprite fragments
auto  fancy_draw() { 

	auto _func=delegate void(Entity e) { 

        if (e.dispersion > 4){
            auto texr=e.sprite.textureRect;
            auto bith=texr.height/e.ypix;
            auto bitw=texr.width/e.xpix;
            auto bitx=texr.left;
         	auto bity=texr.top;
            for (int i=0; i < e.xpix ; i++ ) {
                for (int j=0; j < e.ypix ; j++ ) {
                    auto s=new Sprite(e.sprite.getTexture());
                    s.textureRect=IntRect(bitx+(bitw*i),bity+(bith*j),bitw*2,bith*2);
                    s.position=e.screenpos+v2f(e.dispersion*(i-e.xpix/2), e.dispersion*(j-e.ypix/2));
                    e.app.win.draw(s);
                } 
            }         
        }else{
            e.app.win.draw(e.sprite);
		} 
    };    
    return _func;
    
}    

//#######################################################################################################################
auto  player_init() { 

	auto _initialise = delegate void(Entity e) { 

        e.worldpos=v2f(e.app.globals.worldposx+200,300);
        e.deadtimer=4.0;
        e.status=entity.ALIVE;
        e.dpos=v2f(0,0);
        e.explosion_bits=300;
        e.explosion_color=Color.White;
        e.sprite2=new RectangleShape(v2f(20,30));
        e.sprite2.fillColor=Color.Black;
        e.sprite2.origin=v2f(10,15);
        e.offset=v2f(-50,0);
        e.speed=0;
        e.direction=1;
        e.dy=0;
        e.dspeed=e.app.config.player_dspeed ;            
        e.maxspeed=e.app.config.player_max_speed;
        e.miny=180;
        e.maxy=e.app.win.size.y-20;
        e.screenx_r=200;
        e.screenx_l=e.app.win.size.x-200;
        e.screenpos=v2f(e.screenx_r,0);
        e.enemy=false;
        e.drawhud=true;
        e.nextbomb=0;
        e.thrust=0;
        e.lastthrust=0;
        e.translate=false;
	};
    return _initialise;
} 
//#######################################################################################################################
auto  player_control() { 

	auto _control = delegate void(Entity p) { 

        auto ww= p.app.config.worldwidth;

        // death sequence;
        //------------------------------------------------------------------------;
        switch (p.status) {
        	
        	case entity.DIE:
            	p.clock.restart();
            	p.status=entity.DYING;

            	if (p.direction==1)  
                	p.set_sprite("player_d");
            	else  
                	p.set_sprite("player_dr");
            	break;

        	case entity.DYING:
	            if (p.clock.getElapsedTime().asSeconds() > 1.0){
	                p.game.event_handler.notify(gameevent.PLAYER_DIED, p);
	                p.status=entity.RESPAWN;
	                p.clock.restart();
	            } 
	            break;

       		case entity.RESPAWN:

		        if (p.clock.getElapsedTime().asSeconds() > p.deadtimer){
		            p.game.event_handler.notify(gameevent.PLAYER_SPAWN,p);
		            p.status=entity.ALIVE;
		            if (p.direction == 1)  
		                p.set_sprite("player");
		            else  
		                p.set_sprite("player_r") ;
		            p.worldpos.x=0;
		        }    
		        break;
		
			default : 
			
		        auto x=p.worldpos.x;
		        auto y=p.worldpos.y;
		        p.sprite2.fillColor=Color.Black; 
		        p.thrust=0;
		
		        // process keyboard input;
		        //------------------------------------------------------------------------;
		        if (p.app.globals.input("UP") && y > p.miny ) 
		
		            y-=p.app.config.player_dy;
		
		        if (p.app.globals.input("DOWN") && y < p.maxy) 
		
		            y+=p.app.config.player_dy;
		
		        if (p.app.globals.input("THRUST")){
		
		            p.thrust=1;
		            p.sprite2.fillColor=Color.Red;
		            if (abs(p.speed) < p.maxspeed) 
		                p.speed+=p.dspeed*p.direction;
				} 
		        if (p.app.globals.input("REVERSE")){
		
		            p.direction=-p.direction;
		            p.offset=-p.offset;
		            p.reversing=true;
		            if (p.direction == 1) 
		                p.set_sprite("player");
		            else  
		                p.set_sprite("player_r");
				} 
		        auto psx=p.screenpos.x;
		        auto psy=p.screenpos.y;
		
		        if (p.app.globals.input("FIRE")){
		
		             
		            p.game.laser_mgr.fire(v2f(psx+40*p.direction,psy) , p.direction);
		            p.firing=true;
		            p.game.event_handler.notify(gameevent.FIRE,p);
				} 
		        if (p.app.globals.input("BOMB")){
		
		            p.game.event_handler.notify(gameevent.SMARTBOMB, p);
		            p.nextbomb=10;
				} 
		        //#------------------------------------------------------------------------    
		        if (p.thrust != p.lastthrust){
		
		            p.lastthrust=p.thrust;
		            if (p.thrust==0) 
		                p.game.event_handler.notify(gameevent.NOTHRUST, p);
		            else  
		                p.game.event_handler.notify(gameevent.THRUST, p);
				} 
		        if (p.nextbomb > 0){
		            p.nextbomb-=1; 
		            if (p.nextbomb==0) 
		                p.game.event_handler.notify(gameevent.SMARTBOMB, p);
				} 
		        //# update position
		
		        if (p.direction==1 && p.screenpos.x > p.screenx_r) {
		            psx-=10;
		        }
		        if (p.direction==-1 && p.screenpos.x < p.screenx_l) {
		            psx+=10;
		        }
				
		        p.speed/=1.01;
		        x+=p.speed;
		 
		        if (x < 0) x=ww;
		        if (x > ww) x=0;
		
		        p.worldpos=v2f(x,y);
		        p.screenpos=v2f(psx,psy);
 				 
        } 
	} ;
    return _control;
} 

//#######################################################################################################################
auto  player_draw() { 

	auto _draw = delegate void  (Entity p) { 

        p.app.win.draw(p.sprite);
        p.sprite2.position=p.sprite.position+p.offset;
        p.app.win.draw(p.sprite2);
	
	};
    return _draw;
} 

//#######################################################################################################################                 
//#######################################################################################################################
auto  lander_init( ) { 

	auto _initialise = delegate void (Entity p) { 
		
        auto x=uniform(0,p.app.globals.worldwidth);
        auto pp=cast(int)(p.game.player.worldpos.x);
        if (p.id <2) 
            x=uniform(pp+200 ,pp + p.app.win.size.x);
        if (x < 0) 
            x+=p.app.globals.worldwidth;
        p.worldpos=v2f(x,uniform(170,p.app.win.size.y-300));
        p.dx=random_choice(-3F,3F);
        p.dy=0;
        p.status=entity.QUIESCENT;
        p.state=LANDER_WAITING;
        p.drawhud=true;
        p.target=null;
        p.nextfire=uniform(160,200);
        p.hudcolor= Color.Green;
        p.explosion_color= Color.Green;
        p.fire_bullet=false;
        p.nextthink=20;
        p.framecount=0;
        p.enemy=true;
        p.set_draw_component(fancy_draw());
        p.dispersion=0;
        p.xpix=8;
        p.ypix=8;
        p.wait=(cast(int)(p.id)/4)*200 ;                 //#delay before appearing 
	};
    return _initialise;
} 
//#######################################################################################################################
auto  lander_ai() { 

	auto _ai= delegate void(Entity p) { 

        auto ww=p.app.globals.worldwidth;
        auto wy= p.app.win.size.y;

        if (p.status==entity.DIE){
            if (p.target !is null) {
                p.target.picked=false;
            }
            p.game.event_handler.notify(gameevent.LANDERDIE,p) ;   
            return;
		} 
		if (p.status==entity.EXPLODE) {return;}
        // materializing?;

        if (p.dispersion > 1) 
            p.dispersion-=2;    

		auto x=p.worldpos.x;
		auto y=p.worldpos.y;

		final switch (p.state) {
			
			case LANDER_WAITING:

	            p.wait-=1;
	            if (p.wait<=0){
	                p.status=entity.ALIVE;
	                p.state=LANDER_DROPPING;
	                p.game.event_handler.notify(gameevent.MATERIALISE,p);
	                p.dispersion=120;
	                p.dy=2;
	            } 
				break;
				
        	case LANDER_DROPPING:

	            foreach ( e ; p.game.entity_mgr.get_active_list("human")){
	                if (abs(p.worldpos.x-e.worldpos.x) < 10){
	                    if (e.state==HUMAN_GROUND){
	                        p.state=LANDER_GRABBING;
	                        e.state=HUMAN_PICKED;
	                        p.target=e;
	                        return;
                        } 
                    } 
				} 
	            
	            if (y > p.game.world.get_height_at_pos(cast(int)x)-HOVER_HEIGHT){
	                p.state=LANDER_SEARCHING;
	                p.dy=0;		
				} 
	            
	            break;			
				
        	case LANDER_SEARCHING:
				assert(x>=0,"x < 0");
	            auto l=p.game.entity_mgr.get_active_list("human");
	            foreach ( e ; l ){
	                if (abs(p.worldpos.x-e.worldpos.x) < 10){
	                    if (e.state==HUMAN_GROUND){
	
	                        p.state=LANDER_GRABBING;
	                        p.fire_bullet=true;
	                        p.game.entity_mgr.get_entity("human", e.id).picked=true;
	                        p.dy=p.app.globals.get_curr_level_info()["lander_grab"];
	                        p.target=e;
	                        return;
                        } 
                    } 
				} 
	            if (y >= p.game.world.get_height_at_pos(cast(int)x)-HOVER_HEIGHT) 
	                p.dy=-3;
	            else  
	            	if  (y < p.game.world.get_height_at_pos(cast(int)x)-HOVER_HEIGHT) 
	                	p.dy=3;
				break;
				
        	case LANDER_GRABBING:

	            p.dx=0;
	            if (p.worldpos.y > p.target.worldpos.y) {
	
	                p.state=LANDER_ABDUCTING;
	                p.fire_bullet=true;
	                p.dy=p.app.globals.get_curr_level_info()["lander_abduct"];
	                p.target.parent=p;
	                p.target.state=HUMAN_CARRIED;
	                p.game.event_handler.notify(gameevent.ABDUCT,p);
				} 
	            break;

        	case LANDER_ABDUCTING:

	            if (y < 200) {
	
	                if (p.target.status==entity.DEAD){
	                    p.target=null;
	                    p.state=LANDER_DROPPING;
	                    p.dy=2;
	                    p.dx=random_choice(-3F,3F);
	                    return;
					} 
	                p.state=LANDER_MUTATE;
	            } 
	               
				break;
				
       		case LANDER_MUTATE:

                p.nextfire=60;
                p.set_sprite("mutant");
                p.hudcolor=Color(100,50,200);
                p.explosion_color=Color(100,50,200);
                p.dy=0;
                if (p.target) 
                    p.target.status=entity.DEAD;
                p.soundctr=40;
                p.state=LANDER_MUTATED;
				break;
				
        	case LANDER_MUTATED:

	            // play mutant sfx while on screen             ;
	            p.soundctr--;
	            if (p.soundctr==0) 
	                if (p.on_screen) 
	                    p.game.event_handler.notify(gameevent.MUTANT,p);
	                p.soundctr=40;
	
	            // think every 20 frames   ;
	            p.nextthink--;
	            if (p.nextthink==0){
	                p.nextthink=20;
	                auto pxd=p.game.player.worldpos.x-p.worldpos.x;
	                auto pxd2=pxd;
	                if (pxd < -p.app.globals.worldwidth/2) 
	                    pxd2+=p.app.globals.worldwidth;
	                p.dx=copysign(10,pxd2);
	                p.dy=0;
	                if (abs(y-p.game.player.worldpos.y) > 20) 
	                    p.dy=copysign(4, p.game.player.worldpos.y-y);
	                else   
	                    p.dy=6;
				} 
	            x=x+random_choice([-10,0,0,0,10]);
	            y=y+random_choice([-3,0,0,0,3]);
		} 
        x+=p.dx;
        if (x < 0)   x=ww;
        if (x > ww)   x=0 ;   
        y+=p.dy ;     
	 
        p.worldpos=v2f(x,y);
        p.framecount+=1;

        if (p.framecount > p.nextfire){

            p.fire_bullet=true;
            p.framecount=0;
		} 
        if (p.fire_bullet && p.on_screen && p.game.player.status==entity.ALIVE){

            p.game.fire_bullet(p.worldpos) ; 
            p.game.event_handler.notify(gameevent.FIRED_AT_PLAYER,p);
            p.fire_bullet=false  ;  
		} 
	 };
     return _ai;
} 
//#######################################################################################################################
auto  bullet_init() { 

	auto _initialise = delegate void(Entity p ) {

        p.worldpos=v2f(0,0);
        p.life=1000;
        p.status=entity.DEAD;
        p.dpos=v2f(0,0);
	} ;
    return _initialise;
} 
//#######################################################################################################################    
auto  bullet_spawn(v2f pos,float dir,float speed) { 

	auto  _spawn= delegate void(Entity e) {

        e.worldpos=pos;
        e.life=200;
        auto dx= cos(dir) * speed;
        auto dy= sin(dir) * speed;
        e.dpos=v2f(dx,dy);
        e.speed=speed;
	};
    return _spawn ;
} 
//#######################################################################################################################
auto  bullet_ai() { 

	auto _ai= delegate void(Entity p) {
        if (p.status==entity.EXPLODE) 
            p.status=entity.DEAD;
        p.worldpos+=p.dpos;
        p.life--;
        if (p.life==0) 
            p.status=entity.DEAD;
	};
    return _ai ;
} 
//#######################################################################################################################   
auto  human_init() { 

	auto  _initialise= delegate void(Entity p) { 

        auto x=uniform(0,p.app.globals.worldwidth);

        p.worldpos=v2f(x,0);
        p.dx=random_choice(-0.1,0.1);
        p.dy=0;
        p.explosion_color=Color(255,0,255);
        p.status=entity.ALIVE;
        p.state=HUMAN_GROUND;
        p.drawhud=true;
        p.enemy=false;
        p.picked=false;
        p.hudcolor=Color.Magenta;
        p.dispersion=80;
        p.xpix=2;
        p.ypix=5;
        p.set_draw_component(fancy_draw());

	};
    return _initialise;
}
//#######################################################################################################################
auto  human_ai() { 

	auto _ai = delegate void(Entity p) { 

		scope(failure){ writefln ("state %s ",p.state); } 
        auto ww=p.app.globals.worldwidth;
        auto wy=p.app.win.size.y;

		if(p.status==entity.DIE){
            p.game.event_handler.notify(gameevent.HUMANDIE,p);
            p.status=entity.DEAD;
		}
		if(p.dispersion>1){
            p.dispersion-=1;
		}
		
        auto x=p.worldpos.x;
        auto y=p.worldpos.y;
        x+=p.dx;
		if(x<0)x=ww;
		if(x>ww)x=0;

		switch (p.state) {
			
			case HUMAN_GROUND :
	           y = p.game.world.get_height_at_pos(x);
			   break;
			   
			case  HUMAN_CARRIED:
	
				if(p.parent !is null){
					if(p.parent.status!=entity.ALIVE){
	
	                    p.state=HUMAN_DROPPED;
	                    p.game.event_handler.notify(gameevent.HUMANDROPPED,p);
	                    p.parent=null;
	                    return;
					}
				}	
	            x=p.parent.worldpos.x;
	            y=p.parent.worldpos.y+30;
				if(p.parent.name=="player" && y>p.game.world.get_height_at_pos(x)){
	                p.game.event_handler.notify(gameevent.HUMAN_LANDED_SAFE,p);
	                p.state=HUMAN_GROUND;
	                p.parent=null;
				}
				break;
				
			case HUMAN_DROPPED : 
	
	        	p.dy+=0.05;
				if(y>p.game.world.get_height_at_pos(x)){
	
					if(p.dy>6){
	                	p.kill();
	               	}
	            	else{
	                	p.state=HUMAN_GROUND;
	                	p.game.event_handler.notify(gameevent.HUMAN_LANDED_SAFE,p);
					}
	           	}
				if(p.touching_player){
	
	            	p.parent=p.game.player;
	            	p.state=HUMAN_CARRIED;
	            	p.game.event_handler.notify(gameevent.PLAYER_CAUGHT_HUMAN,p);
				}
				break;
				
			default : 
				break;
		}
        y+=p.dy      ;
        p.worldpos=v2f(x,y);
	 };
     return _ai;
}

//#######################################################################################################################
//# score decals when humans picked up or returned to surface
auto  score_init() { 

	auto  _initialise= delegate void(Entity e) { 

        e.worldpos=v2f(0,0);
        e.life=1000;
        e.status=entity.DEAD;
        e.dpos=v2f(0,0);
        e.set_sprite("250");
        e.enemy=false;
	};
    return _initialise;
}

//#######################################################################################################################    
auto  score_spawn(Entity p,int score) { 

	auto _spawn = delegate void(Entity e) { 

        auto x=p.worldpos.x;
        auto y=p.worldpos.y;
        auto s=p.game.player.speed;
        e.life=100;
        auto dx=s;
        auto dy=0;
        e.worldpos=v2f(x,y);
        e.dpos=v2f(dx,dy);
		if(score==250){
            e.set_sprite("250");
        }
        else {
            e.set_sprite("500");
        }
	};
	return _spawn   ;
}
	
//#######################################################################################################################
auto  score_ai() { 

	auto _ai = delegate void(Entity p) { 

        p.worldpos+=p.dpos;
        p.life-=1;
		if(p.life==0){
            p.status=entity.DEAD;
        }    
	};
    return _ai ;
}
//#######################################################################################################################     
auto  pod_init() { 

	auto  _initialise= delegate void(Entity p) { 

        auto x=uniform(0,p.app.win.size.x);
        p.worldpos=v2f(x,uniform(170,p.app.win.size.y-300));

        p.drawhud=true;
        p.target=null;
        p.next=3.0;
        p.hudcolor=Color(100,0,255);
        p.explosion_color=Color(200,0,255);
        p.fire_bullet=false;
        p.dispersion=0;
        p.explosion_bits=100;
        p.set_draw_component(fancy_draw());
	};
    return _initialise;
}
//#######################################################################################################################    
auto  pod_ai() { 

	auto _ai = delegate void(Entity p) { 

		if(p.status==entity.DIE){
        // this event will spawn swarmers
            p.game.event_handler.notify(gameevent.POD_DIED,p);
		}
	};		
    return _ai ;
}

//#######################################################################################################################
auto  swarmer_init() { 

	auto  _initialise= delegate void(Entity p) { 

        auto x=p.worldpos.x;
        auto y=p.worldpos.y;
        p.status=entity.DEAD;
        p.drawhud=true;
        p.target=null;
        p.next=3.0;
        p.hudcolor=Color(255,0,0);
        p.explosion_color=Color(255,0,0);
        p.explosion_bits=10;
        p.fire_bullet=false;
        p.set_draw_component(fancy_draw());
	};
    return _initialise;
}
//#######################################################################################################################  
auto  swarmer_spawn(Entity e) { 

	auto  _spawn= delegate void(Entity p) { 

        auto x=e.worldpos.x;
        auto y=e.worldpos.y;
        p.worldpos=v2f(x,y);
        p.status=entity.ALIVE;
        p.drawhud=true;
        p.target=null;
        p.next=3.0;
        p.hudcolor=Color(255,0,0);
        p.explosion_color=Color(255,0,0);
        p.fire_bullet=false;
        p.dy=random_choice([-1,0,1]);
        p.dx=random_choice([-1,0,1]);
        p.ddx=random_choice([-1,0,1]);
        p.ddy=random_choice([-1,0,1]);
        p.dmax=uniform(5,10);
	};
    return _spawn;
}
//#######################################################################################################################     
auto  swarmer_ai() { 

	auto _ai = delegate void(Entity p) { 

		if(p.status==entity.DIE || p.status==entity.EXPLODE ){
            return;
		}
        auto x=p.worldpos.x;
        auto y=p.worldpos.y;
        p.dx+=p.ddx;
        p.dy+=p.ddy;
		if(abs(p.dx)>p.dmax){
            p.ddx=-p.ddy;
        }
		if(abs(p.dy)>p.dmax){
            p.ddy=-p.ddy  ;
		}	
        x+=p.dx;
        y+=p.dy;

        auto pxd=p.game.player.worldpos.x-p.worldpos.x;
        auto pxd2=pxd;
		if (pxd<-p.app.globals.worldwidth/2){
            pxd2+=p.app.globals.worldwidth;
		}
	
        auto dx=copysign(4,pxd2)       ;
        auto dy=copysign(4, p.game.player.worldpos.y-y);

        x+=dx;
        y+=dy;

        p.worldpos=v2f(x,y);
	};
    return _ai ;
}
//#######################################################################################################################
auto  baiter_init() { 

	auto  _initialise= delegate void(Entity p) { 

        p.worldpos=v2f(0,0);

        p.status=entity.QUIESCENT;
        p.state=BAITER_WAIT;
        p.drawhud=true;
        p.target=null;
        p.nextfire=120;
        p.framecount=0;
        p.dispersion=150;
        p.xpix=8;
        p.ypix=3;
        p.draw_component=fancy_draw();
        p.hudcolor=Color(0,180,0);
        p.explosion_color=Color(0,180,0);
        p.explosion_bits=20;
        p.fire_bullet=false;
        p.spawndelay=uniform(60,300);
        p.nextthink=40;
        p.dx=0;
        p.dy=0;
        p.enemy=true;
	};

    return _initialise;

}
//#######################################################################################################################  

auto  baiter_ai() { 

	auto _ai = delegate void(Entity p) { 

		if(p.status==entity.DIE){
            p.game.event_handler.notify(gameevent.BAITERDIE,p);
            return;
		}
		if (p.status==entity.EXPLODE) {return;}

		if(p.state==BAITER_WAIT){

			if(p.game.number_landers<13){
                p.state=BAITER_SPAWN;
            }
            else 
                return;
		}
		if (p.state==BAITER_SPAWN){
        	p.spawndelay-=1;
			if(p.spawndelay==0){
                p.state=BAITER_ATTACK;
                p.status=entity.ALIVE;
                p.worldpos=v2f(p.game.player.worldpos.x+uniform(800,1000)*p.game.player.direction,uniform(400,600));
                p.game.event_handler.notify(gameevent.MATERIALISE,p);
        	}
        	else 
            	return;
		}
		if(p.dispersion>1){
        	p.dispersion-=3   ;
		}
        auto x=p.worldpos.x;
        auto y=p.worldpos.y;

        p.nextthink-=1;
		if(p.nextthink==0){
            p.nextthink=60;
            auto pxd=p.game.player.screenpos.x-p.screenpos.x;
			if(p.on_screen){

                p.dx=p.game.player.speed+copysign(random_choice(0,10),pxd) ;
            }
            else 
                p.dx=copysign(p.game.player.speed+10, -pxd);

            p.dy=copysign(2, p.game.player.worldpos.y-y);
		}

        x+=p.dx;
        y+=p.dy;

        p.worldpos=v2f(x,y);
	} ;
    return _ai ;
}
//#######################################################################################################################
//#######################################################################################################################
//# misc utilities 
//#######################################################################################################################

auto  make_bullet_shape() { 

	auto _make = delegate Drawable() { 

        auto s=new RectangleShape();
        s.size=v2f(7,7);
        s.fillColor=Color(255,255,255);
        s.origin=v2f(3,3);

        return s;
	};
    return _make;
}
//#######################################################################################################################
auto  randomize_position() { 

	auto inner = delegate void(Entity e) { 

        auto p=randpos(e.app);
        e.worldpos=p;
	};
    return inner;
}

//#######################################################################################################################
auto  randpos(App app) { 

    return   v2f(uniform(200, app.globals.worldwidth), uniform(200, app.win.size.y/2));
}
//#######################################################################################################################
Vector2f randpos2(App app) { 

    return v2f( 0 , uniform(0, app.win.size.y ) );
}

//#######################################################################################################################
ubyte clamp(ubyte col) { 

	if(col<0){
        return 0;
    }
	if(col>255){
        return 255;
    }    
    return col;
}
//#######################################################################################################################    
auto  gen_color() { 

    /*pattern=it.cycle([ (1,0,-1 ), (0,1,0), (-1, 0,1), (0,-1, 0 ) ]);
    dr,dg,db=pattern.next();
    r=0;
    g=0;
    b=255;
    i=0;

    while true:

        i+=1 ;
        r+= dr ;
        g+= dg;
        b+= db;

		if(i==255){
            i=0;
            dr,dg,db=pattern.next();


        yield  Color(r,g,b);
    */
    return Color.White;
}
//#######################################################################################################################      
auto  randcol2() { 

    return  Color(cast(ubyte)uniform(0,255),cast(ubyte)uniform(0,255), cast(ubyte)uniform(0,255));
}
 
