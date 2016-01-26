module app;

import std.stdio, std.format, std.algorithm, std.random;
import dsfml.graphics;
import world, entity_mgr, spritemgr, config;
import globals, soundmgr, particle, characters;
import game, attract, gameover, behaviours, logosmash, crtshader;
import starfield, entity, lasers, gameevent, hud;

//=========================================================================================================================
//=========================================================================================================================
//=========================================================================================================================

void main()
{

    //auto app= new App(App.mode.WINDOWED); 
    auto app = new App(App.mode.FULLSCREEN);

    app.run();
}

/*
TBD :   
	   bomber spawn position
       bomb laser hit
	   baiters are too stupid
	   baiters not respawning after die
	   bullet time dropping too fast in levels
	   fix mountain explode 
*/

//=========================================================================================================================
//=========================================================================================================================
//=========================================================================================================================

class App
{

    static enum mode
    {
        WINDOWED = 0,
        FULLSCREEN = 1
    };
    static enum
    {
        LEVEL,
        LEVEL_END,
        GAMEOVER,
        ATTRACT
    };
    RenderWindow win;
    RenderTexture rtex;
    Sprite rsprite;
    Config config;
    Globals globals;
    SceneManager scenemgr;
    SoundMgr sound_mgr;
    SpriteMgr sprite_mgr;
    Clock clock;
    Game game_engine;
    Color backgnd;

    this(mode _mode)
    {

        rndGen.seed(0);

        if (_mode == mode.FULLSCREEN)
            win = new RenderWindow(VideoMode.getDesktopMode(), "", Window.Style.Fullscreen);
        else
            win = new RenderWindow(VideoMode(700, 562), "Hello DSFML!");

        win.setVerticalSyncEnabled(true);
        win.setMouseCursorVisible(false);
        win.clear(Color.Black);
        win.display();

        rtex = new RenderTexture();
        rtex.create(win.size.x, win.size.y);
        rsprite = new Sprite();
        rsprite.setTexture(rtex.getTexture());

        config = new Config(this);
        globals = new Globals(this);
        clock = new Clock();
        scenemgr = new SceneManager(this);
        sound_mgr = new SoundMgr(this);
        sprite_mgr = new SpriteMgr(this);
        backgnd = Color.Black;
        run_logosmash(win, this);

        load_sounds_and_sprites();

        scenemgr.add_scene(new Attract(this));

    };

    void run()
    {

        while (win.isOpen())
        {

            Event event, e;

            while (win.pollEvent(event))
            {

                if (event.type == event.EventType.KeyPressed && event.key.code
                        == Keyboard.Key.Escape)
                {
                    win.close();
                }
                if (event.type == event.EventType.Closed)
                {
                    win.close();
                }
                e = event;
            }

            win.clear(backgnd);
            scenemgr.current_scene.update(e);
            scenemgr.current_scene.draw(rtex);
            win.draw(rsprite, scenemgr.current_scene.states);
            win.display();

            if (!scenemgr.current_scene.running)
            {
                switch (scenemgr.current_scene.status)
                {
                case GAMEOVER:

                    config = new Config(this);
                    globals = new Globals(this);
                    scenemgr.replace_scene(new Attract(this));
                    scenemgr.push_scene(new GameOver(this));
                    break;

                case ATTRACT:

                    scenemgr.pop_scene();
                    break;

                default:

                    globals.gamelevel += 1;
                    config.bullet_time -= 20;
                    game_engine = new Game(this);
                    scenemgr.replace_scene(game_engine);
                }
            }
        }
    }

    void load_sounds_and_sprites()
    {

        sound_mgr.load("background", "background.wav", true, 20);
        sound_mgr.load("bomberdie", "bomberdie.wav", false);
        sound_mgr.load("bullet", "bullet.wav", false);
        sound_mgr.load("caughthuman", "caughthuman.wav", false);
        sound_mgr.load("die", "die.wav", false);
        sound_mgr.load("dropping", "dropping.wav", false);
        sound_mgr.load("grabbed", "grabbed.wav", false);
        sound_mgr.load("humandie", "humandie.wav", false);
        sound_mgr.load("landerdie", "landerdie.wav", false);
        sound_mgr.load("bomberdie", "bomberdie.wav", false);
        sound_mgr.load("laser", "laser.wav", false);
        sound_mgr.load("levelstart", "levelstart.wav", false);
        sound_mgr.load("materialise", "materialise.wav", false);
        sound_mgr.load("mutant", "mutant.wav", false);
        sound_mgr.load("placehuman", "placehuman.wav", false);
        sound_mgr.load("life", "start.wav", false);
        sound_mgr.load("thruster", "thruster.wav", false);
        sound_mgr.load("baiterdie", "baiterdie.wav", false);
        sound_mgr.load("world_destroyed", "laser.wav", false);
        sound_mgr.get("world_destroyed").pitch = 0.5;

        sprite_mgr.load_image("lander", "lander.bmp");
        sprite_mgr.set_animation("lander", 3, spritemgr.ANIM_LOOP, 0.5);
        sprite_mgr.load_image("mutant", "mutant.bmp");
        sprite_mgr.set_animation("mutant", 6, spritemgr.ANIM_LOOP, 1.0);
        sprite_mgr.load_image("human", "human.bmp");
        sprite_mgr.load_image("bullet", "bullet1.bmp");
        sprite_mgr.set_animation("bullet", 2, spritemgr.ANIM_LOOP, 0.2);
        sprite_mgr.load_image("player", "ship.bmp");
        sprite_mgr.set_animation("player", 5, spritemgr.ANIM_LOOP, 1.0);
        sprite_mgr.load_image("player_r", "shipr.bmp");
        sprite_mgr.set_animation("player_r", 5, spritemgr.ANIM_LOOP, 1.0);
        sprite_mgr.load_image("player_d", "shipd.bmp");
        sprite_mgr.set_animation("player_d", 2, spritemgr.ANIM_LOOP, 0.1);
        sprite_mgr.load_image("player_dr", "shipd_r.bmp");
        sprite_mgr.set_animation("player_dr", 2, spritemgr.ANIM_LOOP, 0.1);
        sprite_mgr.load_image("250", "250.bmp");
        sprite_mgr.set_animation("250", 3, spritemgr.ANIM_LOOP, 0.3);
        sprite_mgr.load_image("500", "500.bmp");
        sprite_mgr.set_animation("500", 3, spritemgr.ANIM_LOOP, 0.3);
        sprite_mgr.load_image("bomber", "bomber.bmp");
        sprite_mgr.set_animation("bomber", 1, spritemgr.ANIM_NONE, 0);
        sprite_mgr.load_image("baiter", "baiter.bmp");
        sprite_mgr.set_animation("baiter", 1, spritemgr.ANIM_NONE, 0);
        sprite_mgr.load_image("pod", "pod.bmp");
        sprite_mgr.set_animation("pod", 2, spritemgr.ANIM_LOOP, 0.5);
        sprite_mgr.load_image("swarmer", "swarmer.bmp");
        sprite_mgr.set_animation("swarmer", 1, spritemgr.ANIM_NONE, 0);
        sprite_mgr.load_image("bomb", "bomb.bmp");
        sprite_mgr.set_animation("bomb", 1, spritemgr.ANIM_NONE, 0);
        sprite_mgr.load_image("smartbomb", "smartbomb.bmp");
        sprite_mgr.set_animation("smartbomb", 1, spritemgr.ANIM_NONE, 0);
        sprite_mgr.load_image("shiplife", "shiplife.bmp");
        sprite_mgr.set_animation("shiplife", 1, spritemgr.ANIM_NONE, 0);
        sprite_mgr.load_image("title", "title.bmp");
        sprite_mgr.set_animation("title", 1, spritemgr.ANIM_NONE, 0);
        sprite_mgr.load_image("title2", "title2.bmp");
        sprite_mgr.set_animation("title2", 1, spritemgr.ANIM_NONE, 0);
        sprite_mgr.load_image("title3", "title3.bmp");
        sprite_mgr.set_animation("title3", 1, spritemgr.ANIM_NONE, 0);
        sprite_mgr.load_image("title4", "title4.bmp");
        sprite_mgr.set_animation("title4", 1, spritemgr.ANIM_NONE, 0);
        sprite_mgr.load_image("thrust", "thrust.bmp");
        sprite_mgr.set_animation("thrust", 2, spritemgr.ANIM_LOOP, 0.2);
        sprite_mgr.load_image("thrust_r", "thrust_r.bmp");
        sprite_mgr.set_animation("thrust_r", 2, spritemgr.ANIM_LOOP, 0.2);

    }
}

//=========================================================================================================================
class SceneManager
{

    App app;
    Scene[] scenelist;
    int currscene;
    Scene current_scene;

    this(App app)
    {

        this.app = app;
        currscene = 0;
    }

    void add_scene(Scene scene)
    {

        scenelist ~= scene;
        current_scene = scenelist[currscene];
    }

    void replace_scene(Scene scene)
    {

        current_scene.app = null;
        scenelist[$ - 1] = scene;
        current_scene = scenelist[currscene];
    }

    void push_scene(Scene scene)
    {

        scenelist ~= scene;
        currscene++;
        current_scene = scenelist[currscene];
    }

    void pop_scene()
    {
        scenelist.length--;
        currscene--;
        current_scene = scenelist[currscene];
    }
}

//=========================================================================================================================
class Scene
{

    App app;
    SpriteMgr sprite_mgr;
    ParticleSystem particle_system;
    EventHandler event_handler;
    SoundMgr sound_mgr;
    Characters characters;
    Clock clock;
    int status;
    bool running, pause;
    CRTShader crtshader;
    RenderStates states;

    this(App app)
    {

        this.app = app;
        sprite_mgr = app.sprite_mgr;
        particle_system = new ParticleSystem(app);
        event_handler = new EventHandler();
        sound_mgr = app.sound_mgr;
        characters = new Characters(app);
        crtshader = new CRTShader(app.win);
        states = RenderStates.Default;
        states.shader = crtshader.mshader;
        running = true;

    }

    abstract void draw(RenderTarget t);
    abstract void update(Event event);
}

//=========================================================================================================================
// util functions
//=========================================================================================================================
void trace(T...)(T args)
{

    static if (!T.length)
    {
        writeln();
        stdout.flush();
    }
    else
    {
        static if (is(T[0] : string))
        {
            if (canFind(args[0], "%"))
            {
                writefln(args);
                stdout.flush();
                return;
            }
        }

        // not a string, or not a formatted string
        writeln(args);
        stdout.flush();
    }

}
//=========================================================================================================================
T random_choice(T)(T t1, T t2)
{

    return (uniform(0, 2) == 1) ? t1 : t2;
}
//=========================================================================================================================
T random_choice(T)(T[] t1)
{

    return t1[uniform(0, t1.length)];
}
//=========================================================================================================================
