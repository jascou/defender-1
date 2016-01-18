module globals;

import std.math,std.algorithm,std.typecons,std.conv,std.zip,std.stdio,std.file,std.array;
import dsfml.graphics;
import config,app,entity;

alias Vector2f v2f;
 
//===============================================================================================
// global data / functions 
class Globals {

	static enum {
		NORMAL,
		RECORD,
		PLAYBACK
	}
	
	App app;
	int gamelevel;
	int[string][int] level_info;
	int worldposx, worldwidth;
	Input input_handler;
	Entity player;
	int score,lives,smartbombs;
	ubyte[][string] resources;
	int mode;
	uint frame;
	File recording;
	
	
    // collection of global vars and functions 

	this(App app) { 
         
        this.app=app;
        gamelevel=-1;
        level_info=app.config.LEVEL_INFO;
        worldposx=100;
        worldwidth=app.config.worldwidth;
        input_handler=new Input(this, app.config.inputmap);
        player=null;
        lives=app.config.lives;
        smartbombs=app.config.smartbombs;
        score=0;
        mode=NORMAL;
        frame=0;
        
        auto zip = new ZipArchive(read("resources/resources.pak"));
   
	    foreach (name, am; zip.directory)
	    {
	       zip.expand(am);
	       resources[name]=am.expandedData ;
   		}
	    if (mode==RECORD)
	    {
	    	recording=File("resources/recording","w");
	    }
	    if (mode==PLAYBACK)
	    {
	    	recording=File("resources/recording","r");
	    	input_handler.load_playback(recording);
	    		
	    	 
	    }
	}
    //------------------------------------------------------------------------------------
    ref ubyte[] get_resource(string name){
    	assert(name in resources);
    	return resources[name];
    }
    //------------------------------------------------------------------------------------
	string get_score() { 

        return to!string(score);
    }   
    //------------------------------------------------------------------------------------
    // get current level info dict

	auto get_curr_level_info( ) { 

        return level_info[gamelevel];
    }
    //------------------------------------------------------------------------------------    
    // global worldpos is the camera position in the planet, updated per game loop    
	void update_worldpos(float x) { 

        worldposx=normalise(x);
        if (mode==RECORD)
        {
        	input_handler.record();
        }
        frame++;
    }
    //------------------------------------------------------------------------------------
	auto normalise(float pos) { 

        auto x=pos;
		if(x>worldwidth){
           x-=worldwidth;
        }
		else {
			if(x<0){
            	x+=worldwidth;
            }
		}
        return cast(int)x;
    }
    //------------------------------------------------------------------------------------
    // is an entity on screen 
	bool on_screen(v2f pos) { 

 
        auto x=pos.x;
        auto y=pos.y;

        auto relative_x=x-worldposx;
		if(relative_x<-100){
            relative_x+=worldwidth;
		}
		if((relative_x>-100 && relative_x < app.win.size.x+100)){
            return true;
		}
        return false;
    }
    //------------------------------------------------------------------------------------      
    //return the screen position of an entity given its global position               
	v2f screen_pos(v2f pos) { 

        auto x=pos.x;
        auto y=pos.y;

        auto relative_x=x-worldposx;
		if(relative_x<-100){
            relative_x+=worldwidth;
		}
        return v2f(relative_x, y);
	}
    //------------------------------------------------------------------------------------      
    // return true if key corresponding to <command> is down 
    // mapping is set up from a dict in the global config object

	bool input(string command) { 

        return input_handler.pressed(command);
	}
    //------------------------------------------------------------------------------------          
	auto calc_target_position( v2f player_pos, float player_speed, v2f shooter_pos, int time_in_frames ) { 

        auto target_pos=player_pos+v2f(player_speed*time_in_frames,0);
        auto bullet_distance=distance(shooter_pos,target_pos)  ;
        auto bullet_speed=bullet_distance/time_in_frames    ;

        return tuple!(v2f,float)(target_pos, bullet_speed);
	}
    //------------------------------------------------------------------------------------          
    // calculates angle and speed to fire bullet based on entity position, player position and velocity.x,  and required time (in frames)

	auto get_fire_data ( v2f pos, float time ) { 

        // calculate projected player pos that bullet will hit
 
        auto t = calc_target_position(player.worldpos, player.speed, pos, cast(int)time  );
		auto target_pos=t[0];
		auto speed=t[1];
        auto delta=target_pos-pos;
		if(delta.x>worldwidth){
            delta.x -= worldwidth;
        }
		if(delta.x<-worldwidth){
            delta.x += worldwidth;
		}
        auto dir=atan2(delta.y,delta.x) ;

        return [dir, speed];
 
	}
    //------------------------------------------------------------------------------------      
    // return true if bounding rectangles of two entities intersect

	bool intersects( Entity a, Entity b) { 

		if ( a!=b ){
	
	        auto thisrect=a.getGlobalBounds();
	        auto otherrect=b.getGlobalBounds();
			return thisrect.intersects(otherrect);  
	   	}  
		return false;
	}   
    //------------------------------------------------------------------------------------             
    // return dist between two 2d points

	float distance( v2f p1,v2f p2) { 

        return sqrt(  pow(( p2.y - p1.y ),2) + pow(( p2.x - p1.x ),2) );
	}
    //------------------------------------------------------------------------------------             
    
	 
}            
//===============================================================================================   
class Input {

	Key [string] inputmap;
	bool[string][] playback;
	Globals globals; 
	
	this (Globals g, Tuple!(Keyboard.Key,bool)[string] _inputmap) { 
		
		globals=g;
		
        foreach( string k ; _inputmap.keys()){
            inputmap[k]=new Key(_inputmap[k][0], _inputmap[k][1]);
            
        }
	}
	void load_playback(File rec)
	{
		uint curframe=uint.max;
	 
		foreach(char[]l ; rec.byLine()){
			auto s=to!string(l);
			auto a=split(s);
			auto frm=to!uint(a[0]);
			auto cmd=a[1];
			auto flg=(a[2]=="true");
			 
			if ( frm != curframe ){
				curframe=frm;
				playback.length++;
			}
			playback[curframe][cmd]=flg;
		}
		 
	}
	void record()
	{
		foreach(k;inputmap.keys()){ 
			globals.recording.writefln("%s %s %s ",globals.frame,k, Keyboard.isKeyPressed(inputmap[k].key));
		}
	}
	
	bool pressed(string command) { 

		bool ret=false; 
 
		if(command in inputmap){
		 
			if( keypressed(command)){
				if(inputmap[command].debounced==true){ 
					if (inputmap[command].pressed==false){
						ret=true;
					}
				}
				else{
					ret=true;
				}
				inputmap[command].pressed=true;
            }
			else{
				inputmap[command].pressed=false;
 			}
		}		           
      
        return ret;
	}
	bool keypressed(string command)
	{
		if (globals.mode==Globals.PLAYBACK){
			if (globals.frame < playback.length)
				return playback[globals.frame][command];
			return false;
		}
		else{
			return Keyboard.isKeyPressed(inputmap[command].key);
		}
	}
}
//===============================================================================================   
class Key {

	Keyboard.Key key;
	bool debounced,pressed;
	
	this ( Keyboard.Key key, bool debounced ) { 

        this.key=key;
        this.debounced=debounced;
        pressed=false                ;
	}
}



