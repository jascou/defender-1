module gameover;

import dsfml.graphics;
import app, characters, starfield;

alias Vector2f v2f;
//--------------------------------------------------------------------------------------------------------------------    

class GameOver : Scene
{

    Starfield starfield;

    //--------------------------------------------------------------------------------------------------------------------    

    this(App app)
    {
        super(app);
        characters.set_string("", "GAME OVER", v2f(app.win.size.x / 2 - 160,
                app.win.size.y / 2), justify.LEFT);

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
            status = app.ATTRACT;
            running = false;
        }

        starfield.update();
        particle_system.update(0);

    }

    override void draw(RenderTarget rtex)
    {

        rtex.clear(Color.Black);
        particle_system.draw(rtex);
        characters.draw(rtex);
        app.rtex.display();
    }

}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
