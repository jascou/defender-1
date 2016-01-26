module world;

import std.random, std.stdio;
import dsfml.graphics;
import app;

alias Vector2f v2f;

//--------------------------------------------------------------------------------------     
// draws mountains at current player pos

class World
{

    App app;
    int ww, maxh, pos, dp;
    int[] bloblist, hudlist;
    bool active;
    RectangleShape blob;

    this(App app)
    {

        this.app = app;
        ww = app.config.worldwidth;
        active = true;
        maxh = 200;
        pos = 0;
        dp = 1;

        foreach (i; 0 .. ww)
        {
            bloblist ~= pos;
            pos += dp;
            if ((pos >= maxh || pos <= 0))
            {
                dp = -dp;
            }
            else
            {
                if (uniform(0, 100) == 1)
                {
                    dp = -dp;
                }
            }
        }
        pos = 0;
        for (int i = ww - 1; i > 0; i--)
        {
            if (pos >= bloblist[i])
            {
                break;
            }
            bloblist[i] = pos;
            pos += 1;
        }
        auto ratio = cast(int)(ww / app.win.size.x);
        auto c = 0;
        foreach (i; bloblist)
        {
            c += 1;
            if (c == ratio)
            {
                c = 0;
                hudlist ~= i;
            }
        }
        blob = new RectangleShape();
        blob.size = v2f(2.0, 2.0);
        blob.fillColor = Color(200, 150, 0);
    }

    void draw(RenderTarget rtex)
    {

        if (!active)
        {
            return;
        }

        auto p = cast(int)(app.globals.worldposx);
        auto w = app.win.size.x;
        auto h = app.win.size.y;
        auto x = 0;
        auto f = 1;

        foreach (int i; p .. p + w)
        {
            x += 1;
            auto ii = i;
            if (i >= ww - 1)
            {
                ii = (i - ww) + 1;
            }
            assert(ii >= 0);
            assert(ii < ww);

            if (f == 1)
            {
                blob.position = v2f(x, h - bloblist[ii]);
                rtex.draw(blob);
            }
            f = -f;
        }
    }

    int get_height_at_pos(float x)
    {

        if (cast(int) x < bloblist.length)
        {
            return app.win.size.y - bloblist[cast(int)(x)];
        }
        return 0;
    }
}
