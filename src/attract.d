module attract;

import dsfml.graphics;
import app, game, behaviours, characters, starfield;
 
alias Vector2f v2f;
//--------------------------------------------------------------------------------------------------------------------    
            
class Attract : Scene
{
	 
	Sprite t,t2,t3,t4;
	ColorCycle cols,cols2, cols3;
	Starfield starfield;
	
	//--------------------------------------------------------------------------------------------------------------------    

	this ( App app) {

        super(app);
             
        t=app.sprite_mgr.make_sprite("title");
        t.position=v2f(20+(app.win.size.x-t.getLocalBounds().width)/2, 330 );
         
        t2=app.sprite_mgr.make_sprite("title2");
        t2.position=v2f(20+(app.win.size.x-t2.getLocalBounds().width)/2, 330 );
        
        t3=app.sprite_mgr.make_sprite("title3");
        t3.position=v2f( (app.win.size.x-t3.getLocalBounds().width)/2, -100 );
        
        t4=app.sprite_mgr.make_sprite("title4");
        t4.position=v2f( (app.win.size.x-t4.getLocalBounds().width)/2, -100 );
        
        cols=new ColorCycle();
        cols2=new ColorCycle();
        cols3=new ColorCycle( [ Color.Yellow, Color.Red ] );
        characters.set_string("", "PRESS ANY KEY", v2f(app.win.size.x/2-160,app.win.size.y-120),  justify.LEFT);
    	
    	starfield=new Starfield(app,particle_system);
	}
	  

    //--------------------------------------------------------------------------------------------------------------------    
	override void update(Event e ) { 

		if ( app.globals.input("PAUSE")){
        	pause=!pause;	
        }
		if (pause) return; 
 		
 		if (e.type == e.EventType.TextEntered )
 		{
 			 
 			running=false;
 		}
        t2.color=cols.next(20);
		t4.color=cols2.next(3);
		t3.color=cols3.next(5);
        
        starfield.update();
        particle_system.update(10);
	}
    
	override void draw( ) { 
 
 		particle_system.draw();
        app.win.draw(t3);
        app.win.draw(t4);
        app.win.draw(t);
        app.win.draw(t2);
        characters.draw()  ;
	}

}     
 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	