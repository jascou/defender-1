module starfield;
 
import particle,behaviours,app;
import dsfml.graphics;

//--------------------------------------------------------------------------------------     
// draw stars 
class Starfield {

	App app;
	ParticleSystem pm;
	Clock clock;
	Emitter emitter;
	
	this(App app, ParticleSystem p ){
 
        pm=p;
        this.app=app;
        clock=new Clock();
        emitter=new Emitter(app, 10, 0,  behaviours.star_init(app),  behaviours.star());
	}
	void update( ) { 

		if(clock.getElapsedTime().asMilliseconds()>200){
            pm.trigger(emitter);
            clock.restart() ;
        }
	}
}