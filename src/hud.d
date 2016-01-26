module hud;

import dsfml.graphics;
import app;

alias Vector2f v2f;
//-----------------------------------------------------------------------------------------------------------------
// draws the scanner, lives, and bombs

class Hud
{

    App app;
    RectangleShape box, blob, line1, box2;
    bool mountains_active;
    float ratio, w, ww, hp0;
    int[] mountain_list;
    Sprite life, bomb;
    Color[] colorlist;

    this(App app)
    {

        this.app = app;
        colorlist = [Color.Blue, Color.Red, Color.Green, Color.Cyan, Color.Yellow];
        line1 = new RectangleShape();
        line1.size = v2f(app.win.size.x, 3);
        line1.position = v2f(0, 145);
        line1.fillColor = colorlist[app.globals.gamelevel % 5];
        mountains_active = true;
        ratio = app.globals.worldwidth / app.win.size.x;
        w = app.win.size.x;
        box = new RectangleShape();
        box.size = v2f(((w / ratio) * 3 / 5) + 20, 120);
        box.origin = v2f(box.size.x / 2, 0);
        box.position = v2f(w / 2, 10);
        box.outlineColor = Color.White;
        box.outlineThickness = 3;
        box.fillColor = Color.Transparent;
        box2 = new RectangleShape();
        box2.size = v2f(w / 1.65, 145);
        box2.origin = v2f(box2.size.x / 2, 0);
        box2.position = v2f(w / 2, 0);
        box2.outlineColor = colorlist[app.globals.gamelevel % 5];
        box2.outlineThickness = 3;
        box2.fillColor = Color.Transparent;

        hp0 = w / 2 - box.size.x / 2;
        blob = new RectangleShape(v2f(2.0, 2.0));
        blob.fillColor = Color(200, 150, 0);

        ww = app.globals.worldwidth;
        life = app.sprite_mgr.get_sprite_ref("shiplife");
        life.scale = v2f(0.6, 0.6);
        bomb = app.sprite_mgr.get_sprite_ref("smartbomb");
        bomb.color = Color(200, 200, 200);
        bomb.scale = v2f(0.7, 0.7);
    }

    void draw(RenderTarget rtex)
    {

        rtex.draw(line1);
        rtex.draw(box2);
        rtex.draw(box);

        foreach (int i; 0 .. 4)
        {
            if (i < app.globals.lives)
            {
                life.position = v2f(230 - (i * 50), 60);
                rtex.draw(life);
            }
        }
        foreach (int i; 0 .. 4)
        {
            if (i < app.globals.smartbombs)
            {
                bomb.position = v2f(280, 80 - (i * 20));
                rtex.draw(bomb);
            }
        }
        if (mountains_active)
        {
            draw_mountains(rtex);
        }
    }

    void draw_entity(Shape hudshape, v2f pos, RenderTarget rtex)
    {

        auto wpx = app.globals.worldposx;
        auto ypos = (pos.y + 150) / 10;
        auto p0 = pos.x - wpx - w / 2;
        if (p0 > ww / 2)
        {
            p0 -= ww;
        }
        if (p0 < -ww / 2)
        {
            p0 += ww;
        }
        auto xpos = p0 / ratio;
        xpos = (xpos * 3 / 5) + w / 2;
        hudshape.position = v2f(xpos, ypos);
        rtex.draw(hudshape);
    }

    void draw_mountains(RenderTarget rtex)
    {

        auto wpx = app.globals.worldposx;
        auto p = wpx - ww / 2 + w / 2 - 100;
        if (p < 0)
        {
            p += ww;
        }
        auto i = cast(int)(p / ratio);
        auto f = 1;
        for (int j = 0; j < w; j++)
        {

            i += 1;
            if (i == mountain_list.length)
            {
                i = 0;
            }
            auto xpos = (j * 3 / 5) + w / 5;
            auto ypos = 110 - mountain_list[i] / 10;
            blob.position = v2f(xpos, ypos);
            if (f == 1)
            {
                rtex.draw(blob);

            }
            f = -f;
        }
    }
}
