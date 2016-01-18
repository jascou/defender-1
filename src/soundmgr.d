module soundmgr;

import dsfml.audio;
import app;

//--------------------------------------------------------------------------------------     

class MySound {

	SoundBuffer soundbuf;	
	Sound sound;
	
	this (App app, string filename, int volume) { 

        soundbuf=new SoundBuffer();
        soundbuf.loadFromMemory(app.globals.get_resource(filename)); 
        sound=new Sound();
        sound.setBuffer(soundbuf);
        sound.volume=volume;
	}
	
	void setloop( bool b ) { 
        sound.isLooping(b);
	}
}
//----------------------------------------------------------------------------------------
class SoundMgr {
     
    App app;
    MySound[string] sounds;
    bool mute;
    //----------------------------------------------------------------------------------------
	this (App app) { 
        
        this.app=app;
        mute=app.config.mute;
	}
	//----------------------------------------------------------------------------------------
	void load( string name, string filename, bool looping, int volume=100) { 

        auto s=new MySound(app, filename, volume);
        s.setloop(looping);
        sounds[name]=s;
	}
	//----------------------------------------------------------------------------------------
	Sound get(string name) { 

		if(name in sounds){
            return sounds[name].sound;
		}
        return null;
	}
    //----------------------------------------------------------------------------------------
	void play(string name) { 

		if(mute){return; }
 
		if(name in sounds){
			if(sounds[name].sound.status()==SoundSource.Status.Playing){
	                sounds[name].sound.stop();
			}
	        sounds[name].sound.play();
		}
	}
	//----------------------------------------------------------------------------------------
	void stop(string name) { 

		if(name in sounds){
            sounds[name].sound.stop();
		}
	}
    //----------------------------------------------------------------------------------------
	void stopall() { 

        foreach ( name ; sounds.keys()){
            sounds[name].sound.stop();
        }
	}
}


