module spritemgr;
import dsfml.graphics;
import app;

alias Vector2f v2f;

enum
{
    SHAPE = 1,
    TEXTURE = 2,
    ANIM_NONE = 3,
    ANIM_ONESHOT = 4,
    ANIM_LOOP = 5
}
//--------------------------------------------------------------------------------------     
// sprite class holds texture, sprite and animation details 

class MySprite
{

    Texture texture;
    Sprite sprite;
    Shape shape;
    int imgtype, animation_mode, animation_frames, curr_frame, sprite_width, sprite_height;
    double animation_length;
    Clock clock;
    string name;

    this()
    {

        animation_mode = ANIM_NONE;
        animation_frames = 1;
        animation_length = 0;
        curr_frame = 0;
        sprite_width = 0;
        sprite_height = 0;
        clock = new Clock();
        name = "";
    }
}

//-----------------------------------------------------------------------------------------------------
// manage sprites and animation 

class SpriteMgr
{

    App app;
    MySprite[string] images;

    this(App app)
    {
        this.app = app;
    }

    void load_image(string name, string image_name)
    {

        auto image = new Image();
        image.loadFromMemory(app.globals.get_resource(image_name));
        image.createMaskFromColor(Color.Magenta);
        auto tex = new Texture();
        tex.loadFromImage(image);
        auto img = new MySprite();
        img.name = name;
        img.texture = tex;
        img.imgtype = TEXTURE;
        img.animation_frames = 1;
        img.animation_mode = ANIM_NONE;
        img.sprite_width = img.texture.getSize().x;
        img.sprite_height = img.texture.getSize().y;
        img.sprite = new Sprite();
        img.sprite.setTexture(img.texture);
        img.sprite.textureRect = IntRect(0, 0, img.sprite_width, img.sprite_height);
        img.sprite.origin = v2f(img.sprite_width / 2, img.sprite_height / 2);
        images[name] = img;
    }

    void load_shape(string name, Shape delegate() makeshape)
    {

        auto image = new MySprite();
        image.imgtype = SHAPE;
        image.shape = makeshape();
        images[name] = image;
    }

    void set_animation(string name, int frames, int mode, double length)
    {

        auto img = images[name];
        img.animation_frames = frames;
        img.sprite_width = img.texture.getSize().x / frames;

        img.sprite = new Sprite();
        img.sprite.setTexture(img.texture);
        img.sprite.textureRect = IntRect(0, 0, img.sprite_width, img.sprite_height);
        img.sprite.origin = v2f(img.sprite_width / 2, img.sprite_height / 2);
        img.animation_mode = mode;
        img.animation_length = length;
    }

    auto make_sprite(string name)
    {

        assert(name in images, "Could not find " ~ name);
        auto img = images[name];
        img.sprite = new Sprite();
        img.sprite.setTexture(img.texture);
        img.sprite.textureRect = IntRect(0, 0, img.sprite_width, img.sprite_height);
        return img.sprite;
    }

    Sprite get_sprite_ref(string name)
    {

        if (name in images)
        {
            auto img = images[name];
            return img.sprite;
        }
        return null;
    }

    void update()
    {

        foreach (key; images.keys())
        {

            auto i = images[key];
            if (i.imgtype != SHAPE && i.animation_mode != ANIM_NONE)
            {

                if (i.clock.getElapsedTime()
                        .asMilliseconds() > i.animation_length * 1000 / i.animation_frames)
                {
                    i.clock.restart();
                    i.curr_frame += 1;
                    if (i.curr_frame == i.animation_frames)
                    {
                        if (i.animation_mode == ANIM_LOOP)
                        {
                            i.curr_frame = 0;
                        }
                        else
                        {
                            i.curr_frame = i.animation_frames - 1;
                        }
                    }
                }
                i.sprite.textureRect = IntRect(i.sprite_width * i.curr_frame, 0,
                        i.sprite_width, i.sprite_height);
            }
        }
    }
}
