module lasers;

import dsfml.graphics;
import entity, std.math, std.random, std.typecons;
import behaviours, app, game;

alias Vector2f v2f;

const LASER_POOL = 20;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class LaserMgr
{

    App app;
    Game game;
    Entity[] laserlist;
    bool run;

    Color[] colors;
    int colorindex;
    int current;
    Tuple!(float, float)[40][LASER_POOL] black_positions;
    RectangleShape black;

    //---------------------------------------------------------------------------------------------------------------------
    this(App app, Game game)
    {

        this.app = app;
        game = game;
        gen_colors(3);
        colorindex = 0;
        run = true;

        foreach (int laser; 0 .. LASER_POOL)
        {
            auto b = new Entity(laser, "laser", app, game, laser_init(), laser_control());
            b.shape = new RectangleShape();
            laserlist ~= b;
            float x, d;
            x = 0;
            foreach (int j; 0 .. 40)
            {
                x += uniform(5.0, 30.0);
                d = uniform(5.0, 10.0);
                black_positions[laser][j] = tuple!(float, float)(x, d);
            }
        }

        black = new RectangleShape();
        black.fillColor = Color.Black;
        current = 0;
    }
    //---------------------------------------------------------------------------------------------------------------------
    void update()
    {

        if (!run)
        {
            return;
        }
        foreach (b; laserlist)
        {
            if (b.status == entity.ALIVE)
            {
                b.update();
            }
        }
    }
    //---------------------------------------------------------------------------------------------------------------------        
    void draw(RenderTarget rtex)
    {

        if (!run)
        {
            return;
        }
        foreach (l; laserlist)
        {
            if (l.status == entity.ALIVE)
            {
                l.shape.fillColor = l.color;
                l.shape.position = v2f(l.worldpos.x, l.worldpos.y);
                rtex.draw(l.shape);
                auto s = (l.dpos.x < 0) ? -1 : 1;
                foreach (int i; 0 .. 40)
                {
                    black.position = l.offset + v2f(s * black_positions[l.id][i][0], 0.0);
                    black.size = v2f(black_positions[l.id][i][1], 5);
                    rtex.draw(black);
                }
            }
        }
    }
    //---------------------------------------------------------------------------------------------------------------------            
    void fire(v2f pos, int dir)
    {

        current += 1;
        if (current == LASER_POOL)
        {
            current = 0;
        }
        auto b = laserlist[current];
        b.status = entity.ALIVE;
        b.worldpos = pos;
        b.offset = pos;
        b.life = 50;
        b.dpos = v2f(dir * 8, 0);
        b.extent = 20;
        b.color = nextcolor();
        laserlist[current] = b;
    }
    //---------------------------------------------------------------------------------------------------------------------    
    bool check_hit(Entity ent)
    {

        //tbd: debug hits not working - world boundary??? 

        foreach (int i; 0 .. LASER_POOL)
        {

            auto b = laserlist[i];
            if (b.status == entity.ALIVE)
            {

                if (app.globals.intersects(b, ent))
                {
                    b.status = entity.DEAD;
                    laserlist[i] = b;
                    return true;
                }
                /*auto ent_b=ent.sprite.getLocalBounds();

                auto x1=b.screenpos.x ;
                auto x2=b.screenpos.x + b.extent ;
                if  ( x1 < ent.screenpos.x && x2 >  ent.screenpos.x  
                      && b.screenpos.y > ent.screenpos.y-ent_b.height/2  
                      && b.screenpos.y < ent.screenpos.y+ent_b.height/2){
                    b.status=entity.DEAD ;
                    laserlist[i]=b;
                    return true;
				}*/
            }
        }
        return false;
    }
    //---------------------------------------------------------------------------------------------------------------------    
    void gen_colors(int delta)
    {

        auto cols = [Color.Yellow, Color.Cyan, Color.Green, Color.Magenta, Color(255, 100, 0)];
        foreach (Color c; cols)
        {
            foreach (int i; 0 .. delta)
            {
                colors ~= c;
            }
        }
    }
    //---------------------------------------------------------------------------------------------------------------------    
    Color nextcolor()
    {

        auto col = colors[colorindex];
        colorindex++;
        if (colorindex == colors.length)
        {
            colorindex = 0;
        }
        return col;
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// entity plugins 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

auto laser_init()
{

    auto _initialise = delegate void(Entity p) {

        p.worldpos = v2f(0, 0);
        p.life = 50;
        p.status = entity.DEAD;
        p.dpos = v2f(0, 0);
        p.shape = new RectangleShape();
        p.color = Color.Yellow;
        p.extent = 0;
        p.translate = false;
        p.enemy = false;
    };
    return _initialise;
}

//---------------------------------------------------------------------------------------------------------------------
auto laser_control()
{

    auto _ai = delegate void(Entity p) {

        p.worldpos += p.dpos;

        if (abs(p.extent) < p.app.win.size.x)
        {
            p.extent += cast(int) p.dpos.x * 5;
        }
        if (p.worldpos.x < 0 || p.worldpos.x > p.app.win.size.x)
        {
            p.status = entity.DEAD;
        }
        p.shape.size = v2f(p.extent, 5);
        p.life -= 1;
        if (p.life == 0)
        {
            p.status = entity.DEAD;
        }
    };
    return _ai;
}
//---------------------------------------------------------------------------------------------------------------------
auto make_laser_shape()
{

    auto _make = delegate Shape() { auto p = new RectangleShape(); return p; };
    return _make;
}
