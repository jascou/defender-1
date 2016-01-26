module json;

import std.stdio, std.json, std.array;

//=========================================================================================================================
// helper class for accessing a .json config file 

class Json
{

    string config_str;
    JSONValue json;

    this()
    {
    }
    //=========================================================================================================================
    this(string filename)
    {

        File f;
        try
        {
            f = File(filename, "r");
        }
        catch throw new Exception("File " ~ filename ~ " not found");

        string line;
        while ((line = f.readln()) !is null && !f.eof)
        {
            config_str ~= line;
        }
        json = parseJSON(config_str);
        f.close();
    }
    //=========================================================================================================================
    void loadstring(string str)
    {
        config_str = str;
        json = parseJSON(config_str);
    }

    //=========================================================================================================================
    JSONValue getPath(string path)
    {

        auto node = json;
        auto pathlist = split(path, "/");
        foreach (nodename; pathlist)
        {
            node = node[nodename];
        }
        return node;
    }
    //=========================================================================================================================
    int getInt(string path, int _default = 0)
    {
        return cast(int) getPath(path).integer;
    }
    //=========================================================================================================================
    float getFloat(string path, float _default = 0F)
    {
        return getPath(path).floating;
    }
    //=========================================================================================================================
    string getString(string path, string _default = "")
    {
        return getPath(path).str;
    }
    //=========================================================================================================================
    bool getBool(string path, bool _default = false)
    {
        return getPath(path).str == "true";
    }
    //=========================================================================================================================

}

unittest
{

    string t = "
{
    \"bouncy\" : {
    	\"space\" : {
		    \"iterations\" : 2,
		    \"gravity\" : -7000.0,
		    \"step\" :  0.005,
		    \"platforms\" : 8,
		    \"balls\" : 1000
		},
		\"balls\" : {
    		\"min_radius\" : 7.0,
    		\"max_radius\" : 15.0
    	}
    }
}";

    auto config = new Json();
    config.loadstring(t);
    assert(config.getInt("bouncy/space/iterations", 0) == 2);
    assert(0 == 1);

}
