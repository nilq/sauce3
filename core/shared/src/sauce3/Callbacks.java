package sauce3;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Application.ApplicationType;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.lib.jse.CoerceJavaToLua;

public class Callbacks {
    private Sauce3VM vm;
    private LuaValue root;
    private boolean enabled;

    public Callbacks(Sauce3VM vm) {
        this.vm = vm;
    }

    public void enable() {
        enabled = true;
        root = vm.lua.get("sauce3");
    }

    public void load() {
        runCallback("load");
    }

    public void run() {
        runCallback("run");
    }

    public void resize(int width, int height) {
        runCallback("resize", width, height);
    }

    public void visible(boolean isVisible) {
        runCallback("visible", isVisible);
    }

    public void quit() {
        runCallback("_quit");
    }

    public void keypressed(int keycode) {
        runCallback("_keypressed", keycode);
    }

    public void keyreleased(int keycode) {
        runCallback("_keyreleased", keycode);
    }

    public void textinput(String character) {
        runCallback("textinput", character);
    }

    public void touchpressed(int x, int y, int pointer) {
        runCallback("touchpressed", x, y, pointer);
    }

    public void mousepressed(int x, int y, int buttoncode) {
        runCallback("_mousepressed", x, y, buttoncode);
    }

    public void touchreleased(int x, int y, int pointer) {
        runCallback("touchreleased", x, y, pointer);
    }

    public void mousereleased(int x, int y, int buttoncode) {
        runCallback("_mousereleased", x, y, buttoncode);
    }

    public void touchmoved(int x, int y, int pointer) {
        runCallback("touchmoved", x, y, pointer);
    }

    public void mousemoved(int x, int y) {
        runCallback("mousemoved", x, y);
    }

    public void mousescrolled(int amount) {
        runCallback("mousescrolled", amount);
    }

    private void runCallback(String name, Object... args) {
        if (!enabled) return;
        if (vm.lua == null) return;

        LuaValue callback = root.get(name);
        if (!callback.isfunction()) return;

        switch (args.length) {
            case 0: callback.call(); break;
            case 1: callback.call(CoerceJavaToLua.coerce(args[0])); break;
            case 2: callback.call(CoerceJavaToLua.coerce(args[0]), CoerceJavaToLua.coerce(args[1])); break;
            case 3: callback.call(CoerceJavaToLua.coerce(args[0]), CoerceJavaToLua.coerce(args[1]), CoerceJavaToLua.coerce(args[2])); break;
        }
    }
}
