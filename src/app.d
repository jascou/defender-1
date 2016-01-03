 
module app;

import dsfml.graphics;
import world, entity_mgr, spritemgr, config, globals, soundmgr;
import game,behaviours;
import starfield,entity, lasers, gameevent,  hud;
import std.stdio,std.format,std.algorithm;

class App{
	
	static enum mode {
		WINDOWED=0,  
		FULLSCREEN=1   
	}    ;
 	RenderWindow win;
 	Config config;
 	Globals globals;
 	SceneManager scenemgr;
 	SoundMgr sound_mgr;
 	SpriteMgr sprite_mgr;
 	Clock clock;
 	Game game_engine;
 	Color backgnd;
 	
 	this(mode _mode){
 
        if (_mode==mode.FULLSCREEN) 
            win = new RenderWindow(VideoMode.getDesktopMode(),"", Window.Style.Fullscreen);
        else  
            win = new RenderWindow(VideoMode(700,562),"Hello DSFML!"  );
            
        win.setVerticalSyncEnabled(true);
        win.clear(Color.Black);
        win.display();
        assert ( win !is null ) ;
        
        config=new Config(this);
        globals=new Globals(this);
        clock=new Clock();
        scenemgr=new SceneManager(this);
        sound_mgr=new SoundMgr(this);
        sprite_mgr=new SpriteMgr();
        load_sounds_and_sprites();
        game_engine=new Game(this);
        scenemgr.add_scene(game_engine);
        backgnd=Color.Black;
      	win.clear(backgnd);
    
   };
        
   void run() {
   	        
   	     
        while (win.isOpen())  
		{
			Event event;
		
		    while(win.pollEvent(event)){
                
                if(event.type == event.EventType.KeyPressed && event.key.code== Keyboard.Key.Escape) {
		            win.close();
		        } 
		        if (event.type == event.EventType.Closed ) { 
		            win.close();
		        } 
            }        
            win.clear(backgnd);
            scenemgr.current_scene.update();
            scenemgr.current_scene.draw();
            win.display();
                
            if (! scenemgr.current_scene.running ) { 

                globals.gamelevel+=1;
                game_engine=new Game(this);
                scenemgr.replace_scene(game_engine);
 
			} 
	    } 
	} 
 	        
			        
    void load_sounds_and_sprites(){
    
        sound_mgr.load("background","background.wav",true,20);
        sound_mgr.load("bomberdie","bomberdie.wav",false);
        sound_mgr.load("bullet","bullet.wav",false);
        sound_mgr.load("caughthuman","caughthuman.wav",false);
        sound_mgr.load("die","die.wav",false);
        sound_mgr.load("dropping","dropping.wav",false);
        sound_mgr.load("grabbed","grabbed.wav",false);
        sound_mgr.load("humandie","humandie.wav",false);
        sound_mgr.load("landerdie","landerdie.wav",false);
        sound_mgr.load("laser","laser.wav",false);
        sound_mgr.load("levelstart","levelstart.wav",false);
        sound_mgr.load("materialise","materialise.wav",false);
        sound_mgr.load("mutant","mutant.wav",false);
        sound_mgr.load("placehuman","placehuman.wav",false);
        sound_mgr.load("life","start.wav",false);
        sound_mgr.load("thruster","thruster.wav",false);
        sound_mgr.load("baiterdie","baiterdie.wav",false);
        sound_mgr.load("world_destroyed","laser.wav",false);
        sound_mgr.get("world_destroyed").pitch=0.5;
        
        
        sprite_mgr.load_image("lander", "lander.bmp");
        sprite_mgr.set_animation("lander", 3, spritemgr.ANIM_LOOP,  0.5 );
        sprite_mgr.load_image("mutant", "mutant.bmp");
        sprite_mgr.set_animation("mutant", 6, spritemgr.ANIM_LOOP,   1.0 );
        sprite_mgr.load_image("human","human.bmp");
        sprite_mgr.load_image("bullet", "bullet1.bmp");
        sprite_mgr.set_animation("bullet", 2, spritemgr.ANIM_LOOP, 0.2 );
        sprite_mgr.load_image("player", "ship.bmp");
        sprite_mgr.set_animation("player", 5, spritemgr.ANIM_LOOP,   1.0 );
        sprite_mgr.load_image("player_r", "shipr.bmp");
        sprite_mgr.set_animation("player_r", 5, spritemgr.ANIM_LOOP,   1.0 );
        sprite_mgr.load_image("player_d", "shipd.bmp");
        sprite_mgr.set_animation("player_d", 2, spritemgr.ANIM_LOOP,   0.1 );
        sprite_mgr.load_image("player_dr", "shipd_r.bmp");
        sprite_mgr.set_animation("player_dr", 2, spritemgr.ANIM_LOOP,   0.1 );
        sprite_mgr.load_image("250", "250.bmp");
        sprite_mgr.set_animation("250", 3, spritemgr.ANIM_LOOP,  0.3 );
        sprite_mgr.load_image("500", "500.bmp");
        sprite_mgr.set_animation("500", 3, spritemgr.ANIM_LOOP,  0.3 );
        sprite_mgr.load_image("bomber", "bomber.bmp");
        sprite_mgr.set_animation("bomber", 1, spritemgr.ANIM_NONE,  0 );  
        sprite_mgr.load_image("baiter", "baiter.bmp");
        sprite_mgr.set_animation("baiter", 1, spritemgr.ANIM_NONE,  0 );  
        sprite_mgr.load_image("pod", "pod.bmp");
        sprite_mgr.set_animation("pod", 2, spritemgr.ANIM_LOOP,  0.5 );  
        sprite_mgr.load_image("swarmer", "swarmer.bmp");
        sprite_mgr.set_animation("swarmer", 1, spritemgr.ANIM_NONE,  0 );  
    } 
} 

void trace(T...)(T args)
{
 
	    static if (!T.length)
	    {
	        writeln();
	        stdout.flush();
	    }
	    else
	    {
	        static if (is(T[0] : string))
	        {
	            if (canFind(args[0], "%"))
	            {
	                writefln(args);
	                stdout.flush();
	                return;
	            }
	        }
	
	        // not a string, or not a formatted string
	        writeln(args);
	        stdout.flush();
	    }
	     
}


