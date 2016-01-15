module gameevent;

import app,entity;

enum {
	DIED=0,
	FIRED_AT_PLAYER=1,
	HUMAN_LANDED_SAFE=2,
	PLAYER_CAUGHT_HUMAN=3,
	PLAYER_DIED=4,
	SMARTBOMB=5,
	POD_DIED=6,
	GAME_START=7,
	GAME_STOP=8,
	FIRE=9,
	THRUST=10,
	NOTHRUST=11,
	MATERIALISE=12,
	LANDERDIE=13,
	BOMBERDIE=14,
	HUMANDIE=15,
	ABDUCT=16,
	HUMANDROPPED=17,
	MUTANT=18,
	BAITERDIE=19,
	PLAYER_SPAWN=20,
	WORLD_DESTROYED=21,
	GAMEOVER=22
}

class EventHandler {

	void delegate (Entity)[][int] entity_events;
	void delegate ()[][int] events;
	
	this() { }

	void add( int event, void delegate(Entity) callback ) { 
 
		if( event in entity_events ){
            entity_events[event]~=callback;
        }
        else{
            entity_events[event]=[callback];
 		}        
	}
	void add( int event, void delegate() callback ) { 
 
		if( event in events ){
            events[event]~=callback;
        }
        else{
            events[event]=[callback];
 		}        
	}
	void notify( int event, Entity obj=null ) { 

		if (obj !is null)
		{
			if(event in entity_events){
				foreach (listener ; entity_events[event] ) {
	                listener(obj);
				}
			}
		}
		if(event in events){
			foreach (listener ; events[event] ) {
                listener();
			}
		}
	}
}

