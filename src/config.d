
module config;
import std.typecons;
import dsfml.graphics;
import app;

const WORLD_SCREENS=10;

class Config {
    
    static int[string][int] LEVEL_INFO;
    static this () {
    	
    	LEVEL_INFO=
    	  [ 10 : [ "landers": 1 , "humans" : 0 , "pods" : 1, "swarmers" : 7,  "baiters": 1, "lander_grab" : 2, "lander_abduct" : -1 ] , 

             0 : [ "landers": 12, "humans" : 10, "pods" : 0, "swarmers" : 0,  "baiters": 2, "lander_grab" : 2, "lander_abduct" : -1 ] ,

             1 : [ "landers": 20, "humans" : 15 , "pods" : 2, "swarmers" : 7, "baiters": 2, "lander_grab" : 5, "lander_abduct" : -3 ] ,

             2 : [ "landers": 30, "humans" : 20 , "pods" : 3, "swarmers" : 7, "baiters": 3, "lander_grab" : 6, "lander_abduct" : -4 ] 

            ];
	}
    
	int worldwidth;
	Keyboard k;
	Tuple!(Keyboard.Key,bool)[string] inputmap;
	float player_dy,player_dspeed,player_max_speed,bullet_speed;
	bool nodie,mdebug,mute;
	int bullet_time;
	
	this(App app){

        worldwidth=WORLD_SCREENS*app.win.size.x  ;
        alias Keyboard.Key k;

        // name, keyboard key, de-bounced
        inputmap=[ 
                       "UP": tuple(k.Q, false),  
                       "DOWN": tuple(k.A,false), 
                       "THRUST": tuple(k.Return,false), 
                       "FIRE":tuple(k.O,true), 
                       "REVERSE":tuple(k.Space,true),  
                       "BOMB":tuple(k.BackSpace,true)
                  ];

        player_dy=8;
        player_dspeed=1;
        player_max_speed=20;
        bullet_speed=200;
        nodie=false;
        mdebug=false;
        mute=false;
        bullet_time=120;
	
	}
}
