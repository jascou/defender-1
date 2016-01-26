module attract;

import dsfml.graphics;
import app, game, behaviours, characters, starfield;

alias Vector2f v2f;
//--------------------------------------------------------------------------------------------------------------------    

class Attract : Scene
{

    Sprite t, t2, t3, t4;
    int disp, disp2;
    ColorCycle cols, cols2, cols3;
    Starfield starfield;

    //--------------------------------------------------------------------------------------------------------------------    

    this(App app)
    {

        super(app);

        t = app.sprite_mgr.make_sprite("title");
        t.origin = v2f(t.getLocalBounds().width / 2, t.getLocalBounds().height / 2);
        t.position = v2f(10 + app.win.size.x / 2, 330);
        disp = 400;

        t2 = app.sprite_mgr.make_sprite("title2");
        t2.position = v2f(10 + app.win.size.x / 2, 330);
        t2.origin = v2f(t2.getLocalBounds().width / 2, t2.getLocalBounds().height / 2);
        disp2 = 400;

        t3 = app.sprite_mgr.make_sprite("title3");
        t3.position = v2f((app.win.size.x - t3.getLocalBounds().width) / 2, -100);

        t4 = app.sprite_mgr.make_sprite("title4");
        t4.position = v2f((app.win.size.x - t4.getLocalBounds().width) / 2, -100);

        cols = new ColorCycle();
        cols2 = new ColorCycle();
        cols3 = new ColorCycle([Color.Yellow, Color.Red]);
        characters.set_string("", "PRESS ANY KEY", v2f(app.win.size.x / 2 - 160,
                app.win.size.y - 120), justify.LEFT);

        starfield = new Starfield(app, particle_system);
    }

    //--------------------------------------------------------------------------------------------------------------------    
    override void update(Event e)
    {

        if (app.globals.input("PAUSE"))
        {
            pause = !pause;
        }
        if (pause)
            return;

        if (e.type == e.EventType.TextEntered)
        {

            running = false;
        }
        t2.color = cols.next(20);
        t4.color = cols2.next(3);
        t3.color = cols3.next(5);

        starfield.update();
        particle_system.update(10);

        if (disp > 0)
            disp -= 2;
        if (disp2 > 0)
            disp2 -= 2;

    }

    override void draw(RenderTarget rtex)
    {

        rtex.clear(Color.Black);
        particle_system.draw(rtex);
        rtex.draw(t3);
        rtex.draw(t4);
        fancydraw(rtex, t, disp, 28, 8);
        fancydraw(rtex, t2, disp2, 28, 8);
        characters.draw(rtex);
        app.rtex.display();
    }

    void fancydraw(RenderTarget rtex, Sprite spr, int dispersion, int xpix, int ypix)
    {

        if (dispersion > 14)
        {
            auto texr = spr.textureRect;
            auto bith = texr.height / ypix;
            auto bitw = texr.width / xpix;
            auto bitx = texr.left;
            auto bity = texr.top;
            for (int i = 0; i < xpix; i++)
            {
                for (int j = 0; j < ypix; j++)
                {
                    auto s = new Sprite(spr.getTexture());
                    s.textureRect = IntRect(bitx + (bitw * i), bity + (bith * j), bitw * 2, bith * 2);
                    s.origin = v2f(bitw / 2, bith / 2);
                    s.position = spr.position + v2f(dispersion * (i - xpix / 2),
                            dispersion * (j - ypix / 2));
                    s.color = spr.color;
                    rtex.draw(s);
                }
            }
        }
        else
        {
            rtex.draw(spr);
        }
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
