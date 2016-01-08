
module config;
import std.typecons;
import dsfml.graphics;
import app;

const WORLD_SCREENS=10;

class Config {
    
    static int[string][int] LEVEL_INFO;
    static this () {
    	
    	LEVEL_INFO=
    	  [   

             0 : [ "landers": 12, "humans" : 10, "pods" : 0, "bombers" : 0, "swarmers" : 0,  "baiters": 0, "lander_grab" : 2, "lander_abduct" : -1 ] ,

             1 : [ "landers": 20, "humans" : 10 , "pods" : 1, "bombers" : 2, "swarmers" : 7, "baiters": 1, "lander_grab" : 5, "lander_abduct" : -3 ] ,

             2 : [ "landers": 25, "humans" : 10 , "pods" : 2, "bombers" : 3, "swarmers" : 7, "baiters": 2, "lander_grab" : 6, "lander_abduct" : -4 ] ,
             
             3 : [ "landers": 30, "humans" : 10 , "pods" : 3, "bombers" : 4, "swarmers" : 10, "baiters": 3, "lander_grab" : 7, "lander_abduct" : -5 ] ,
             
             4 : [ "landers": 35, "humans" : 10 , "pods" : 4, "bombers" : 5, "swarmers" : 15, "baiters": 4, "lander_grab" : 8, "lander_abduct" : -6 ] ,
             
             5 : [ "landers": 35, "humans" : 8 , "pods" : 4, "bombers" : 6, "swarmers" : 15, "baiters": 5, "lander_grab" : 8, "lander_abduct" : -7 ] ,
             
             6 : [ "landers": 35, "humans" : 7 , "pods" : 4, "bombers" : 7, "swarmers" : 15, "baiters": 6, "lander_grab" : 8, "lander_abduct" : -7 ] ,
               
			 7 : [ "landers": 40, "humans" : 6,  "pods" : 4, "bombers" : 8, "swarmers" : 15, "baiters": 7, "lander_grab" : 9, "lander_abduct" : -8 ] ,
                 
             8 : [ "landers": 40, "humans" : 5 , "pods" : 4, "bombers" : 9, "swarmers" : 15, "baiters": 8, "lander_grab" : 9, "lander_abduct" : -8 ]
                   

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
        mute=true;
        bullet_time=120;
	
	}
}
