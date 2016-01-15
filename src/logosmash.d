module logosmash;

import std.stdio,std.random,std.conv, std.concurrency, std.string;
 
import dsfml.graphics;
import dsfml.system;
 
import app;

__gshared float[] data;

void update(RenderWindow win, VertexArray dots, int index, float dotsize, float x, float y )
{
  
	auto v=dots[index*4];
	y=win.size.y-y;
    v.position=Vector2f(x,y);
 
    dots[index*4]=v;
    v.position.x+=dotsize;
    dots[index*4+1]=v;
    v.position.y+=dotsize;
    dots[index*4+2]=v;
    v.position.x-=dotsize;
    dots[index*4+3]=v;
	
}	
 

void make_ball( float x, 
	               float y, 
	               float dotsize, 
	               Color c,
	               int index,
	               VertexArray dots, 
	               RenderWindow window)
{
	    
    auto v=Vertex();
    v.position.x=cast(float)x ;
    v.position.y=window.size.y-cast(float)y ;
 
    v.color= c;
    
    dots[index*4]=v;
    v.position.x+=dotsize;
    dots[index*4+1]=v;
    v.position.y+=dotsize;
    dots[index*4+2]=v;
    v.position.x-=dotsize;
    dots[index*4+3]=v;
 
}

int init_smash(VertexArray dots, float dotsize, Image image, RenderWindow window)
{
	
	auto image_width=image.getSize().x;
    auto image_height=image.getSize().y;
 
	int count=0;
   
    make_ball(-10F, 
            	500F, 
            	dotsize, 
            	Color.White, 
            	count,
            	dots, 
  		        window);
	
    auto velx=0F;
    auto vely=0F;

    for (int y = 0; y < image_height; y++)
    {
        for (int x = 0; x < image_width; x++)
        {
        	auto col=image.getPixel(x,y);
        	if ( col==Color(0,0,0))
                continue;
  
 			count++;
           
            float xp=(dotsize)*  x  ;
            float yp=(dotsize) * (image_height - y );
            make_ball(xp+400F, 
	            	yp+400F, 
	            	dotsize, 
	            	col, 
	            	count,
	            	dots, 
	            	window);           
        }
    }
 
    return count;
    
}
 
void bg_loaddata( Tid ownerTid ){
	
	auto d=File("resources/logosmash");

	foreach( s; d.byLine() ){
		data~=to!float(strip(to!string(s))); 	 
	}
	 
}

void run_logosmash(RenderWindow window, App app ) {

	auto t=spawn(&bg_loaddata,thisTid);
	sleep(milliseconds(500));
	Image image;
    image = new Image();
    image.loadFromMemory(app.globals.get_resource("dsfml.bmp"));
    auto image_width=image.getSize().x;
    auto image_height=image.getSize().y;
    
	auto dots=new VertexArray(PrimitiveType.Quads,((image_width*image_height)+1)*4); 
    auto clock=new Clock();
	auto data_index=0;
	auto dotsize=4.0F;
    auto bits=init_smash(dots,dotsize, image,window);
    
    window.setMouseCursorVisible(false);
    window.clear(Color.Black);
	window.display();
	
	win: while (window.isOpen())
	{
		Event event;
	
	    while(window.pollEvent(event)){
	        if(event.type == event.EventType.KeyPressed  ){
	            
	            break win;
	        }  
	    }
 
	    window.clear(Color.Black);
        for ( int count=0; count <= bits; count++){
        	update(window, dots,count, dotsize, data[data_index],data[data_index+1]);
        	data_index+=2;
        	if (data_index >= data.length)
        	{
        		break win;
        	}
        }
	    window.draw(dots);
	    window.display();
     }  
	 
}