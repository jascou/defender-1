module entity_mgr;

import entity, app, game;
import dsfml.graphics;

//=========================================================================================================================
// holds an array of entities of a particular type 

class EntityPool
{

    Entity[] pool_list;
    int size, active;
    bool running;
    float time_to_start, delay;

    this()
    {

        size = 0;
        active = 0;
        running = false;
        time_to_start = 0;
        delay = 0;
    }
}
//=========================================================================================================================
// manages the various entity pools 

class EntityMgr
{

    App app;
    Game game;
    EntityPool[string] entity_dict;
    int active;
    Sprite[] adhoc_sprites;
    EntityPool pool;
    Entity[] active_list;

    //#----------------------------------------------------------------------------------      

    this(App app, Game game)
    {

        this.app = app;
        this.game = game;
        active = 0;
    }

    //#----------------------------------------------------------------------------------
    void add_adhoc_sprite(Sprite sprite)
    {
        adhoc_sprites ~= sprite;
    }

    //#----------------------------------------------------------------------------------    
    void clear_adhoc_sprites()
    {
        adhoc_sprites = [];
    }
    //#----------------------------------------------------------------------------------
    Entity create(string name, void delegate(Entity) init, void delegate(Entity) behaviours)
    {

        return new Entity(0, name, app, game, init, behaviours);
    }
    //#----------------------------------------------------------------------------------      
    void create_pool(string name, int number, void delegate(Entity) init,
            void delegate(Entity) behaviours)
    {

        pool = new EntityPool();
        for (int i = 0; i < number; i++)
        {
            pool.pool_list ~= new Entity(i, name, app, game, init, behaviours);

        }
        pool.size = number;
        entity_dict[name] = pool;
    }
    //#----------------------------------------------------------------------------------  
    //# reactivate an entity from a pool (used for firing bullets etc) 
    void spawn(string name, void delegate(Entity) spawn_init_func)
    {

        auto p = entity_dict[name];
        for (int i = 0; i < p.size; i++)
        {
            auto e = p.pool_list[i];
            if (e.status == entity.DEAD)
            {
                e.status = entity.ALIVE;
                spawn_init_func(e);
                p.pool_list[i] = e;
                break;
            }
        }
    }
    //#----------------------------------------------------------------------------------   
    void run(string pool_name)
    {

        entity_dict[pool_name].running = true;
    }
    //#----------------------------------------------------------------------------------       
    void run_delayed(string pool_name, float delay)
    {

        entity_dict[pool_name].running = false;
        entity_dict[pool_name].delay = delay;
    }
    //#----------------------------------------------------------------------------------       
    void stop(string pool_name)
    {

        entity_dict[pool_name].running = false;
        entity_dict[pool_name].delay = 0;
    }
    //#----------------------------------------------------------------------------------           
    void stoplist(string[] poolname_list)
    {

        foreach (name; poolname_list)
        {
            stop(name);
        }
    }

    //#----------------------------------------------------------------------------------            
    void reset(string name)
    {

        foreach (pk; entity_dict.keys())
        {
            foreach (e; entity_dict[pk].pool_list)
            {
                e.reset();
            }
        }
    }
    //#----------------------------------------------------------------------------------         
    void reset_list(string[] name_list)
    {

        foreach (name; name_list)
        {
            reset(name);
        }
    }
    //#----------------------------------------------------------------------------------         
    void do_func(string name, void delegate(Entity) func)
    {

        foreach (e; entity_dict[name].pool_list)
        {
            if (e.status != entity.DEAD)
            {
                func(e);
            }
        }
    }
    //#----------------------------------------------------------------------------------
    void do_list(string[] name_list, void delegate(Entity) func)
    {

        foreach (name; name_list)
        {
            do_func(name, func);
        }
    }

    //#----------------------------------------------------------------------------------                   
    void update()
    {

        foreach (pk; entity_dict.keys())
        {

            if (entity_dict[pk].delay > 0)
            {
                entity_dict[pk].delay -= 1;
                if (entity_dict[pk].delay == 0)
                {
                    entity_dict[pk].running = true;
                }
            }
            auto e_cnt = 0;
            foreach (e; get_active_list(pk))
            {
                e.update();
                e_cnt += 1;
            }
            entity_dict[pk].active = e_cnt;

        }
    }
    //#----------------------------------------------------------------------------------    
    ref Entity[] get_active_list(string pool_name)
    {

        active_list.length = 0;

        if (entity_dict[pool_name].running)
        {

            foreach (e; entity_dict[pool_name].pool_list)
            {
                if (e.status != entity.DEAD)
                {
                    active_list ~= e;
                }
            }
        }
        return active_list;
    }

    //#----------------------------------------------------------------------------------
    //# used by smartbomb
    Entity[] get_all_onscreen_enemies()
    {

        Entity[] list;
        foreach (pk; entity_dict.keys())
        {
            get_active_list(pk);
            foreach (e; active_list)
            {
                if (e.on_screen && e.enemy && e.name != "bomb" && e.name != "bullet")
                {
                    list ~= e;
                }
            }
        }
        return list;
    }
    //#----------------------------------------------------------------------------------   
    Entity get_entity(string pool_name, int id)
    {

        return entity_dict[pool_name].pool_list[id];
    }
    //#----------------------------------------------------------------------------------   
    int active_count(string pool_name)
    {

        return entity_dict[pool_name].active;
    }
    //#----------------------------------------------------------------------------------  
    void draw(RenderTarget rtex)
    {

        foreach (pk; entity_dict.keys())
        {
            if (entity_dict[pk].running)
            {
                foreach (e; entity_dict[pk].pool_list)
                {
                    if (e.status != entity.DEAD)
                    {
                        e.draw(rtex);
                    }
                }
            }
        }

        foreach (s; adhoc_sprites)
        {
            rtex.draw(s);
        }
    }
}
