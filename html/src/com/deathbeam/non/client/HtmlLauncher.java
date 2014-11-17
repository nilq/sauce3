package com.deathbeam.non.client;

import java.io.IOException;

import com.badlogic.gdx.ApplicationListener;
import com.badlogic.gdx.backends.gwt.GwtApplication;
import com.badlogic.gdx.backends.gwt.GwtApplicationConfiguration;
import com.badlogic.gdx.utils.JsonValue;
import com.deathbeam.non.Game;
import com.deathbeam.non.Utils;

public class HtmlLauncher extends GwtApplication {
		private JsonValue conf;
		
        @Override
        public GwtApplicationConfiguration getConfig () {
        		try {
					conf = Utils.configure();
					return new GwtApplicationConfiguration(conf.get("resolution").asIntArray()[0], conf.get("resolution").asIntArray()[1]);
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
					return null;
				}
        }

        @Override
        public ApplicationListener getApplicationListener () {
                return new Game(conf);
        }
}