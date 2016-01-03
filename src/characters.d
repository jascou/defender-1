module characters;

import dsfml.graphics;
import behaviours;
import std.string;

enum justify {
	RIGHT=1,
	LEFT=0
}

class Characters {
 
 	RenderWindow win;
 	Image fontimg;
 	Texture tex;
 	Color randcol;
 	Sprite[][string] strings;
 	string charlist;
 	int cw,ch;
 	
 	
 	this(RenderWindow win) {
 
        this.win=win;
        fontimg=new Image();
        fontimg.loadFromFile("resources/font.bmp");
        fontimg.createMaskFromColor( Color(255,0,255));
        tex=new Texture();
        tex.loadFromImage( fontimg);
        charlist="0123456789:?ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        cw=30;
        ch=tex.getSize().y;
        randcol=behaviours.gen_color();
	}
 	
	void set_string( string name, string _string, v2f pos, justify just ) { 

        strings[name]=get_string_sprite_list(_string, pos,  just);
	}
	
	void remove_string(string name) { 

        strings.remove(name);
	}

	void draw() { 
        foreach ( k ; strings.keys()){
            foreach ( s ; strings[k]) {
                s.color=randcol ;
                win.draw(s);
            }
		}
	}
	
	Sprite get_char_sprite(char _char,v2f pos) { 

        auto offset=indexOf(charlist,_char)*cw;
        auto tex_start=cw*offset;
        auto s=new Sprite(tex);
        s.textureRect=IntRect(offset,0,cw,ch);
        s.position=pos;
        return s;
	}
	
	Sprite[] get_string_sprite_list( string chstring, v2f pos, justify just ) { 

        Sprite[] l;
        int i=0;
        foreach (c ; chstring) { 
			if (c != ' ' ) {
                auto offset=indexOf(charlist,c);
                auto tex_start=cw*offset;
                auto rect=IntRect(tex_start,0,cw,ch);
                auto s=new Sprite(tex);
                s.textureRect=rect;
                auto x=pos.x;
                auto y=pos.y;
				if(just==justify.RIGHT){
                    x=x-(cw*chstring.length+1);
				}
                s.position=v2f(x+(cw*i+1),y);
                l~=s;
            }
            i+=1;
		
		
		}
        return l ;
	}
}

