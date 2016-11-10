package %PACKAGE%.ios;

import java.io.File;
import java.io.FileInputStream;
import java.util.Map;
import org.yaml.snakeyaml.Yaml;
import org.robovm.apple.foundation.NSAutoreleasePool;
import org.robovm.apple.foundation.NSBundle;
import org.robovm.apple.uikit.UIApplication;
import org.yaml.snakeyaml.Yaml;
import com.badlogic.gdx.backends.iosrobovm.IOSApplication;
import com.badlogic.gdx.backends.iosrobovm.IOSApplicationConfiguration;
import sauce3.Sauce3VM;

public class IOSLauncher extends IOSApplication.Delegate {
    @SuppressWarnings("unchecked")
    protected IOSApplication createApplication() {
        IOSApplicationConfiguration cfg = new IOSApplicationConfiguration();
        cfg.orientationLandscape = true;
        cfg.orientationPortrait = true;

        Yaml yaml = new Yaml();
        Map config;

        try {
            config = (Map<String, Object>)yaml.load(new FileInputStream(new File(NSBundle.getMainBundle().getBundlePath(), "sauce3/project.yml")));
        } catch (Exception e) {
            System.err.println(e.getMessage());
            System.exit(-1);
            return null;
        }

        if (config.containsKey("window")) {
            Map window = (Map<String, Object>)config.get("window");
            if (window.containsKey("orientation")) {
                String orientation = (String)window.get("orientation");

                if (orientation.equals("portrait")) {
                    cfg.orientationLandscape = false;
                    cfg.orientationPortrait = true;
                } else if (orientation.equals("landscape")) {
                    cfg.orientationLandscape = true;
                    cfg.orientationPortrait = false;
                } else if (orientation.equals("sensor")) {
                    cfg.orientationLandscape = true;
                    cfg.orientationPortrait = true;
                }
            }
        }

        return new IOSApplication(new Sauce3VM(config), cfg);
    }

    public static void main(String[] args) {
        NSAutoreleasePool pool = new NSAutoreleasePool();
        UIApplication.main(args, null, IOSLauncher.class);
        pool.close();
    }
}
