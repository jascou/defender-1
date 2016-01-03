module hud;

import dsfml.graphics;
import app;

alias Vector2f v2f;

class Hud {
    
	App app;
	RectangleShape box, blob,line1;
	bool mountains_active;
	float ratio,w,ww,hp0;
	int[] mountain_list;
	 
	
	this( App app) { 

        this.app=app;
        line1=new RectangleShape();
        line1.size=v2f(app.win.size.x, 2);
        line1.position=v2f(0,155);
        line1.fillColor= Color.Red;
        mountains_active=true;
        ratio=app.globals.worldwidth/app.win.size.x ;
        w=app.win.size.x;
        box=new RectangleShape();
        box.size=v2f(((w/ratio)*3/5)+20,120);
        box.origin=v2f(box.size.x/2,0);
        box.position=v2f(w/2, 10 );
        box.outlineColor=Color(150,0,0 );
        box.outlineThickness=3;
        box.fillColor=Color.Transparent;
        hp0=w/2-box.size.x/2;
        blob=new RectangleShape(v2f(2.0,2.0));
        blob.fillColor=Color(200,150,0);

        ww=app.globals.worldwidth;
    }

	void draw() { 

        app.win.draw(line1);
        app.win.draw(box);
		if(mountains_active){
            draw_mountains();
		}
	}

	void draw_entity( Shape hudshape, v2f pos) { 

        auto wpx=app.globals.worldposx;
        auto ypos=(pos.y+150)/10;
        auto p0=pos.x-wpx-w/2;
		if(p0>ww/2){
            p0-=ww;
        } 
		if(p0<-ww/2){
            p0+=ww;
		}
        auto xpos= p0 / ratio  ;
        xpos=(xpos*3/5)+w/2;
        hudshape.position=v2f(xpos,ypos);
        app.win.draw(hudshape);
	}
	void draw_mountains( ) { 

        auto wpx=app.globals.worldposx;
        auto p=wpx-ww/2+w/2-100;
		if(p<0){
            p+=ww;
		}
        auto i=cast(int)(p/ratio) ;
        auto f=1;
        for (int j=0; j < w; j++ ) { 

            i+=1;
			if(i==mountain_list.length){
                i=0;
            }
            auto xpos=(j*3/5)+w/5;
            auto ypos=110-mountain_list[i]/10;
            blob.position=v2f(xpos,ypos);
			if(f==1){
                app.win.draw(blob);
            
            }
            f=-f;
		}
	}
}