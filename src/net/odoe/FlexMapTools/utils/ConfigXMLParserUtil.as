package net.odoe.FlexMapTools.utils {
import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
import com.esri.ags.layers.ArcGISTiledMapServiceLayer;
import com.esri.ags.layers.FeatureLayer;

import mx.collections.ArrayCollection;

import net.odoe.FlexMapTools.factories.IMapService;
import net.odoe.FlexMapTools.factories.MapService;
import net.odoe.FlexMapTools.vo.Task;

/**
 * XML Parser Utility for a simple XML configuration file.
 * Derived from posting by Adam Estrada http://www.adamestrada.com/2009/12/15/more-on-flex-and-config-xml/
 * @author rrubalcava
 *
 */
public class ConfigXMLParserUtil {
    /**
     * Object used when creating an <code>ArcGISDynamicMapServiceLayer</code>.
     */
    protected static var dLayer:ArcGISDynamicMapServiceLayer;

    /**
     * Object used when creating an <code>ArcGISTiledMapServiceLayer</code>.
     */
    protected static var tLayer:ArcGISTiledMapServiceLayer;

    /**
     * Object used when creating an <code>FeatureLayer</code>.
     */
    protected static var fLayer:FeatureLayer;

    /**
     * Will parse a given <code>XML</code> to find and create Map Service Layers.
     * @param xml
     */
    public static function getLayers(xml:XML):Array {
        var services:Array = [];

        for each (var serviceXML:XML in xml.service) {
            var service:IMapService = new MapService();
            service.name = serviceXML.@name;
            service.url = serviceXML.@url;
            service.alpha = serviceXML.@alpha;
            service.visible = serviceXML.@visible == "true";
            service.visibleLayers = new ArrayCollection(serviceXML.@layers.split(","));
            if (String(serviceXML.@type).toLowerCase() == "dynamic") {
                dLayer = service.asDynamicLayer();
                services.push(dLayer);
            }
            else if (String(serviceXML.@type).toLowerCase() == "tiled") {
                tLayer = service.asTiledLayer();
                services.push(tLayer);
            }
            else if (String(serviceXML.@type).toLowerCase() == "feature") {
                fLayer = service.asFeatureLayer()
                services.push(fLayer);
            }
        }

        return services;
    }

    /**
     * Will parse a given <code>XML</code> to find and create various services.
     * i.e. <code>QueryTask</code>, <code>IdentifyTask</code> or <code>WebService</code>.
     * @param xml
     */
    public static function getServices(xml:XML):Array {
        var queryTasks:Array = [];
        for each (var queryXML:XML in xml.task) {
            var task:Task = new Task();
            task.type = queryXML.@type;
            task.name = queryXML.@name;
            task.url = queryXML.@url;
            queryTasks.push(task);
        }
        return queryTasks;
    }
}
}