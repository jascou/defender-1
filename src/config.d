module config;

import std.typecons,std.conv;
import dsfml.graphics;
import app,json;

const WORLD_SCREENS=10;
alias Keyboard.Key k;

class Config {
    
    
	int worldwidth;
	int[string][int] LEVEL_INFO; 
	Tuple!(Keyboard.Key,bool)[string] inputmap;
	float player_dy,player_dspeed,player_max_speed;
	bool nodie,mdebug,mute;
	int bullet_time,lives,smartbombs;
	Json configfile;
	k[string] keymap;
	
	this(App app){

        configfile=new Json("resources/defender.json");
        worldwidth=WORLD_SCREENS*app.win.size.x  ;
        
		keymap=[ 
			  "A" :  k.A ,
			  "B" :  k.B ,
			  "C" :  k.C ,
			  "D" :  k.D ,
			  "E" :  k.E ,
			  "F" :  k.F ,
			  "G" :  k.G ,
			  "H" :  k.H ,
			  "I" :  k.I ,
			  "J" :  k.J ,
			  "K" :  k.K ,
			  "L" :  k.L ,
			  "M" :  k.M ,
			  "N" :  k.N ,
			  "O" :  k.O ,
			  "P" :  k.P ,
			  "Q" :  k.Q ,
			  "R" :  k.R ,
			  "S" :  k.S ,
			  "T" :  k.T ,
			  "U" :  k.U ,
			  "V" :  k.V ,
			  "W" :  k.W ,
			  "X" :  k.X ,
			  "Y" :  k.Y ,
			  "Z" :  k.Z ,
			  "Num0" :  k.Num0 ,
			  "Num1" :  k.Num1 ,
			  "Num2" :  k.Num2 ,
			  "Num3" :  k.Num3 ,
			  "Num4" :  k.Num4 ,
			  "Num5" :  k.Num5 ,
			  "Num6" :  k.Num6 ,
			  "Num7" :  k.Num7 ,
			  "Num8" :  k.Num8 ,
			  "Num9" :  k.Num9 ,
			  "Escape" :  k.Escape ,
			  "LControl" :  k.LControl ,
			  "LShift" :  k.LShift ,
			  "LAlt" :  k.LAlt ,
			  "LSystem" :  k.LSystem ,
			  "RControl" :  k.RControl ,
			  "RShift" :  k.RShift ,
			  "RAlt" :  k.RAlt ,
			  "RSystem" :  k.RSystem ,
			  "Menu" :  k.Menu ,
			  "LBracket" :  k.LBracket ,
			  "RBracket" :  k.RBracket ,
			  "SemiColon" :  k.SemiColon ,
			  "Comma" :  k.Comma ,
			  "Period" :  k.Period ,
			  "Quote" :  k.Quote ,
			  "Slash" :  k.Slash ,
			  "BackSlash" :  k.BackSlash ,
			  "Tilde" :  k.Tilde ,
			  "Equal" :  k.Equal ,
			  "Dash" :  k.Dash ,
			  "Space" :  k.Space ,
			  "Return" :  k.Return ,
			  "BackSpace" :  k.BackSpace ,
			  "Tab" :  k.Tab ,
			  "PageUp" :  k.PageUp ,
			  "PageDown" :  k.PageDown ,
			  "End" :  k.End ,
			  "Home" :  k.Home ,
			  "Insert" :  k.Insert ,
			  "Delete" :  k.Delete ,
			  "Add" :  k.Add ,
			  "Subtract" :  k.Subtract ,
			  "Multiply" :  k.Multiply ,
			  "Divide" :  k.Divide ,
			  "Left" :  k.Left ,
			  "Right" :  k.Right ,
			  "Up" :  k.Up ,
			  "Down" :  k.Down ,
			  "Numpad0" :  k.Numpad0 ,
			  "Numpad1" :  k.Numpad1 ,
			  "Numpad2" :  k.Numpad2 ,
			  "Numpad3" :  k.Numpad3 ,
			  "Numpad4" :  k.Numpad4 ,
			  "Numpad5" :  k.Numpad5 ,
			  "Numpad6" :  k.Numpad6 ,
			  "Numpad7" :  k.Numpad7 ,
			  "Numpad8" :  k.Numpad8 ,
			  "Numpad9" :  k.Numpad9 ,
			  "F1" :  k.F1 ,
			  "F2" :  k.F2 ,
			  "F3" :  k.F3 ,
			  "F4" :  k.F4 ,
			  "F5" :  k.F5 ,
			  "F6" :  k.F6 ,
			  "F7" :  k.F7 ,
			  "F8" :  k.F8 ,
			  "F9" :  k.F9 ,
			  "F10" :  k.F10 ,
			  "F11" :  k.F11 ,
			  "F12" :  k.F12 ,
			  "F13" :  k.F13 ,
			  "F14" :  k.F14 ,
			  "F15" :  k.F15 ,
			  "Pause" :  k.Pause 
		];


		auto UP=keymap[configfile.getString("inputmap/up")];	
		auto DOWN=keymap[configfile.getString("inputmap/down")];		
		auto THRUST=keymap[configfile.getString("inputmap/thrust")];		
		auto FIRE=keymap[configfile.getString("inputmap/fire")];		
		auto REVERSE=keymap[configfile.getString("inputmap/reverse")];		
		auto BOMB=keymap[configfile.getString("inputmap/bomb")];		
		auto PAUSE=keymap[configfile.getString("inputmap/pause")];		
			
        // name, keyboard key, de-bounced
        inputmap=[ 
                       "UP": tuple(UP, false),  
                       "DOWN": tuple(DOWN,false), 
                       "THRUST": tuple(THRUST,false), 
                       "FIRE":tuple(FIRE,true), 
                       "REVERSE":tuple(REVERSE,true),  
                       "BOMB":tuple(BOMB,true),
                       "PAUSE":tuple(PAUSE,true)
                  ];

        player_dy=configfile.getInt("player_dy");
        player_dspeed=configfile.getInt("player_dspeed");
        player_max_speed=configfile.getInt("player_max_speed");
        nodie=configfile.getBool("immortal");
        mdebug=false;
        mute=configfile.getBool("mute");
        bullet_time=configfile.getInt("bullet_time");
        lives=configfile.getInt("lives");
        smartbombs=configfile.getInt("smartbombs");
        
        foreach(int level; 0..13 ){
        	auto path="level_info";
        	auto leveldict=configfile.getPath(path).object[to!string(level)];
        	foreach (string s; [ "landers", "humans" , "pods" , "bombers" , "swarmers" , "baiters", "lander_grab" , "lander_abduct" ]){
				LEVEL_INFO[level][s]=to!int(leveldict.object[s].integer);
        	}

        }
	
	}
}
