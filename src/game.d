module game;

import std.random,std.format;
import dsfml.graphics;
import app, world, entity_mgr, spritemgr,config,globals, soundmgr;
import starfield,entity,  lasers, gameevent,  hud, particle, characters, behaviours;
 
//--------------------------------------------------------------------------------------------------------------------    
            
class Game : Scene 
{
	static enum { LEVEL, LEVEL_END, GAMEOVER };
	
	EntityMgr entity_mgr;
	Entity player; 
	int number_landers;
	World world;
	LaserMgr laser_mgr;
	Hud hud;
	Starfield starfield;
	int number_pods,number_swarmers,number_baiters,number_humans, number_bombers;
    int counter;
    int[string] levinfo;
	int humans_active;
	
	//--------------------------------------------------------------------------------------------------------------------    

	this ( App app) {

        super(app);
        clock=new Clock();
        clock.restart();
        levinfo=app.globals.get_curr_level_info();
        pause=0;
        game_initialise();
    	status=LEVEL;  
    	humans_active=0;  
	}
	//--------------------------------------------------------------------------------------------------------------------    

	void game_initialise() { 
		
		entity_mgr=new EntityMgr(app,this);	
        //set event listeners. The first argument is the event type, the second is a function returning a delegate.
        auto handler=event_handler  ;
        handler.add(gameevent.DIED, 				explosion()) ;
        handler.add(gameevent.DIED, 				update_score())        ;
        handler.add(gameevent.PLAYER_DIED, 			player_died());
        handler.add(gameevent.PLAYER_DIED, 			player_explosion());
        handler.add(gameevent.PLAYER_DIED, 			stopsound("all"));
        handler.add(gameevent.PLAYER_DIED, 			sound("die"));
        handler.add(gameevent.PLAYER_SPAWN,			sound("background"));
        handler.add(gameevent.SMARTBOMB, 			smartbomb());
        handler.add(gameevent.PLAYER_CAUGHT_HUMAN,  score(250));
        handler.add(gameevent.HUMAN_LANDED_SAFE,  	score(500));
        handler.add(gameevent.POD_DIED,  			spawn_swarmers());
        handler.add(gameevent.GAME_START, 			sound("background"));
        handler.add(gameevent.GAME_START, 			sound("levelstart"));
        handler.add(gameevent.THRUST, 				sound("thruster"));
        handler.add(gameevent.NOTHRUST,  			stopsound("thruster"));
        handler.add(gameevent.FIRE, 				sound("laser"));
        handler.add(gameevent.ABDUCT, 				sound("grabbed"));
        handler.add(gameevent.HUMANDIE, 			sound("humandie"));
        handler.add(gameevent.PLAYER_CAUGHT_HUMAN, 	sound("caughthuman"));
        handler.add(gameevent.HUMAN_LANDED_SAFE, 	sound("placehuman"));
        handler.add(gameevent.HUMAN_LANDED_SAFE,  	update_score(250));
        handler.add(gameevent.MATERIALISE, 			sound("materialise"));
        handler.add(gameevent.FIRED_AT_PLAYER, 		sound("bullet"));
        handler.add(gameevent.LANDERDIE, 			sound("landerdie"));
        handler.add(gameevent.LANDERDIE, 			stopsound("laser"));
        handler.add(gameevent.HUMANDROPPED, 		sound("dropping"));
        handler.add(gameevent.MUTANT, 				sound("mutant"));
        handler.add(gameevent.BAITERDIE, 			sound("baiterdie"));
        handler.add(gameevent.BOMBERDIE, 			sound("bomberdie"));
        handler.add(gameevent.GAMEOVER, 			game_over());

	 
        //init laser pool

        laser_mgr=new LaserMgr(app,this);

        //init hud, world and starfield

        hud=new Hud(app);
        world=new World(app);
        hud.mountain_list=world.hudlist;
        starfield=new Starfield(app, particle_system);

        //set up player

        player=entity_mgr.create("player",  player_init(), player_control());
        player.set_draw_component(player_draw());
        app.globals.player=player;

        //init enemy pool

        number_landers=levinfo["landers"];
        entity_mgr.create_pool("lander", number_landers, lander_init(), lander_ai() ) ;
        entity_mgr.run_delayed("lander", 180 );

        number_pods=levinfo["pods"];
        entity_mgr.create_pool("pod", number_pods, pod_init(), pod_ai() ) ;
        entity_mgr.run("pod");

        number_swarmers=levinfo["pods"]*levinfo["swarmers"];
        entity_mgr.create_pool("swarmer", number_swarmers, swarmer_init(), swarmer_ai() ) ;
        entity_mgr.run("swarmer");

        number_baiters=levinfo["baiters"];
        entity_mgr.create_pool("baiter", number_baiters, baiter_init(), baiter_ai() ) ;
        entity_mgr.run("baiter");

		number_bombers=levinfo["bombers"];
        entity_mgr.create_pool("bomber", number_bombers, bomber_init(), bomber_ai() ) ;
        entity_mgr.run("bomber");

        //init human pool

        number_humans=levinfo["humans"];
        entity_mgr.create_pool("human", number_humans, human_init( ), human_ai( ) ) ;
        entity_mgr.run("human");

        //init bullet/bomb pools

        entity_mgr.create_pool("bullet", 10 , bullet_init(), bullet_ai() ) ;
        entity_mgr.run("bullet");

		entity_mgr.create_pool("bomb", 20 , bomb_init(), bomb_ai() ) ;
        entity_mgr.run("bomb");

        //score decals

        entity_mgr.create_pool("score", 5 , score_init(), score_ai() ) ;
        entity_mgr.run("score");

        event_handler.notify(gameevent.GAME_START ) ;


	}

    //--------------------------------------------------------------------------------------------------------------------    
	override void update(Event e ) { 

	 	switch (status) {
	 		case LEVEL      : update_level();     break;
	 		case LEVEL_END  : update_level_end(); break;
			default         :                     break;
	 	}
	}
	//--------------------------------------------------------------------------------------------------------------------    
	void update_level() { 
		
		if ( app.globals.input("PAUSE")){
        	pause=!pause;	
        }
		if (pause) return; 
		
        player.update();
        auto speed=player.speed;
        laser_mgr.update();
        starfield.update();
        particle_system.update(speed/2 );
        sprite_mgr.update();
        app.globals.update_worldpos(player.worldpos.x-player.screenpos.x );
 
        entity_mgr.update();

        //if level beaten, stop everything and switch to alternate update routine that will do the end of level stuff. when this finishes 
        //the current game instance will terminate, a new one will be created to host the next level      
		if(number_landers==0){
            
            status=LEVEL_END;
            characters.set_string("levelend", format("ATTACK WAVE %s COMPLETED" ,(app.globals.gamelevel+1)), v2f(450,300), justify.LEFT );
            humans_active=entity_mgr.active_count("human");
            clock.restart();
            counter=0;
            particle_system.run=false;
            world.active=false;
            laser_mgr.run=false;
            player.status=entity.DEAD;
            entity_mgr.stoplist(["bullet", "lander", "human", "baiter", "pod", "swarmer", "human"]);
		}

        //if no humans left, blow up the mountains

		if (entity_mgr.active_count("human")==0 && world.active){

            explode_mountains();
		}
		
        characters.set_string("score", app.globals.get_score(), v2f(250,100), justify.RIGHT);
	}
    //-------------------------------------------------------------------------------------------------------------------- 
	void update_level_end( ) { 

		sleep(milliseconds(100));
		
		if(clock.getElapsedTime().asSeconds()>3){
            running=false;
		}
		if(counter<humans_active){
			if(clock.getElapsedTime().asMilliseconds()>50){
                clock.restart();
                auto s=sprite_mgr.make_sprite("human");
                s.position=v2f( 400+counter*60,450);
                entity_mgr.add_adhoc_sprite(s);
                counter+=1;
			}
		}
	}	
    //-------------------------------------------------------------------------------------------------------------------- 
	override void draw( ) { 
 
        particle_system.draw();
        world.draw();
        player.draw();
        entity_mgr.draw();
        laser_mgr.draw() ;
        hud.draw();
        characters.draw()  ;
	}

    //--------------------------------------------------------------------------------------------------------------------    
	auto explosion( ) { 

		auto _func=delegate void(Entity obj) { 

			if(obj.on_screen  && obj.name!="bullet"){

                auto e=new Emitter(app, obj.explosion_bits, 0,  init_explosion(obj), move_explosion());
                e.pos=obj.screenpos;
                particle_system.trigger(e);
			}
		};
        return _func;
    }
    //--------------------------------------------------------------------------------------------------------------------
	auto player_explosion( ) { 

		auto _func=delegate void(Entity obj) { 

			assert(particle_system);
            auto e=new Emitter(app, obj.explosion_bits, 0,  init_player_explosion(obj),   move_player_explosion()  );
            e.pos=obj.screenpos;
            particle_system.trigger(e);
		};
        return _func;
    }
	
    //--------------------------------------------------------------------------------------------------------------------
	auto update_score( int val=-1) { 

		auto _func=delegate void(Entity obj) { 

			if(val!=-1){
                app.globals.score+=val;
            }
            else{
				if(obj.name=="lander"){
                    number_landers-=1;
                    app.globals.score+=150;
				}
				if(obj.name=="baiter"){
                    app.globals.score+=200;
				}
			}
		};
        return _func;
    }    
    //--------------------------------------------------------------------------------------------------------------------
	auto player_died( ) { 

		auto _func=delegate void(Entity obj) { 

            entity_mgr.stoplist(["lander", "baiter", "swarmer", "pod"]);
            entity_mgr.do_list(["lander", "swarmer", "baiter", "pod"], behaviours.randomize_position()) ;
            entity_mgr.run_delayed("lander", 300 );
            entity_mgr.run_delayed("baiter", 300 );
            entity_mgr.run_delayed("swarmer", 300 );
            foreach ( e ; entity_mgr.get_active_list("human")){
                e.state=HUMAN_GROUND;
                e.parent=null;
			}
            app.globals.lives--;
            app.globals.smartbombs=3;
     
		};
        return _func;
    }
    //--------------------------------------------------------------------------------------------------------------------
	auto game_over(){
		
		return () {
			status=GAMEOVER;
            running=false;
        };
	}
	
	//--------------------------------------------------------------------------------------------------------------------
	
	auto smartbomb( ) { 

		auto _func=delegate void(Entity obj) { 

			if (app.globals.smartbombs == 0 ) return;
			
            foreach ( e ; entity_mgr.get_all_onscreen_enemies()){
                e.kill();
			}

		};	
        return _func;
    }
    //--------------------------------------------------------------------------------------------------------------------
	auto spawn_swarmers( ) { 

		auto _func=delegate void(Entity obj) { 

            for (int s=0; s < levinfo["swarmers"]; s++){

                entity_mgr.spawn("swarmer", swarmer_spawn(obj));
			}
		};
        return _func;
    }
    //--------------------------------------------------------------------------------------------------------------------
	void fire_bullet( v2f pos ) { 

        auto time=app.config.bullet_time;   //required travel time in frames 
        auto f=app.globals.get_fire_data(pos, time);
        auto dir=f[0];
        auto speed=f[1];
		if( speed<50 && speed > 5 ){
			if ( random_choice( true,false )){
                dir+=0.3;
            }
            entity_mgr.spawn("bullet", bullet_spawn(pos,dir,speed));
		}		
	}
	//--------------------------------------------------------------------------------------------------------------------
	void fire_bomb( v2f pos ) { 

        entity_mgr.spawn("bomb", bomb_spawn(pos));		
	}
    //--------------------------------------------------------------------------------------------------------------------
	auto score(int id) { 

		auto _func=delegate void(Entity obj) { 

            entity_mgr.spawn("score", score_spawn(obj,id ));
		};
        return _func;
	}
    //--------------------------------------------------------------------------------------------------------------------
	auto  sound(string name) { 

		auto _func=delegate void( ) { 

            sound_mgr.play(name);
		};
        return _func;
	}
//--------------------------------------------------------------------------------------------------------------------
	auto  stopsound(string name) {  

		auto _func=delegate void( ) { 

			if(name=="all"){
                sound_mgr.stopall();
            }
            else{
                sound_mgr.stop(name);
			}  
        };    
        return _func;
    }
 //--------------------------------------------------------------------------------------------------------------------   
	void explode_mountains( ) { 

        world.active=false   ;
        hud.mountains_active=false;

        sound_mgr.play("world_destroyed");
        auto p=player.worldpos.x;

        auto p1=0;
        auto p2=app.globals.worldwidth ;
        auto s=10;

        for (int i=p1; i<p2; i+=s ) { 
			 
            auto e=new Emitter(app, 4, 0,  init_world_explosion(),  move_explosion()  );
            e.pos=app.globals.screen_pos(v2f(i, world.get_height_at_pos(i)));
            particle_system.trigger(e)   ;
		}
        foreach ( e ; entity_mgr.get_active_list("lander")){
            e.state=LANDER_MUTATE;
            e.status=entity.ALIVE;
            e.dispersion=0;
		}
	}
}
 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	