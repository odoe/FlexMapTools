package net.odoe.FlexMapTools.components {
import com.esri.ags.Graphic;
import com.esri.ags.Map;
import com.esri.ags.events.MapMouseEvent;
import com.esri.ags.geometry.Geometry;
import com.esri.ags.geometry.MapPoint;
import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
import com.esri.ags.layers.ArcGISTiledMapServiceLayer;
import com.esri.ags.layers.GraphicsLayer;
import com.esri.ags.layers.Layer;
import com.esri.ags.symbols.SimpleFillSymbol;
import com.esri.ags.symbols.SimpleLineSymbol;
import com.esri.ags.symbols.SimpleMarkerSymbol;
import com.esri.ags.symbols.Symbol;
import com.esri.ags.tasks.IdentifyTask;
import com.esri.ags.tasks.supportClasses.IdentifyParameters;
import com.esri.ags.tasks.supportClasses.IdentifyResult;

import flash.events.MouseEvent;
import flash.utils.getQualifiedClassName;

import mx.collections.ArrayCollection;
import mx.collections.IList;
import mx.logging.ILogger;
import mx.rpc.AsyncResponder;

import net.odoe.FlexMapTools.utils.LayerUtil;
import net.odoe.FlexMapTools.utils.LogUtil;

import spark.components.Button;
import spark.components.ComboBox;
import spark.components.List;
import spark.components.supportClasses.SkinnableComponent;
import spark.events.DropDownEvent;

/**
 * Identify tool used to identify features on a <code>Map</code>.
 * @author rrubalcava
 */
public class IdentifyTool extends SkinnableComponent implements IIdentifyTool {

    protected static const logger:ILogger = LogUtil.getLogger(IdentifyTool);

    /**
     * Constructor
     */
    public function IdentifyTool() {
        super();
    }

    [SkinPart(required="true")]
    /**
     * Button that will reset the state of the Identify tool.
     * @default
     */
    public var btnIdentify:Button;

    [SkinPart(required="true")]
    /**
     * <code>ComboBox</code> that will display the list of layers in a service.
     * @default
     */
    public var cbLayers:ComboBox;

    [SkinPart(required="true")]
    /**
     * <code>List</code> that will hold IdentifyResults.
     * @default
     */
    public var idList:List;
    /**
     * Constant for Identify color.
     * @default
     */
    protected const ID_COLOR:Number = 0x00FF00;

    /**
     * The <code>Layer</code> that will be the source for the Identify Tool.
     * @default
     */
    protected var _layer:Layer;
    /**
     * Application <code>Map</code> that will be used to zoom to identified features.
     * @default
     */
    protected var _map:Map;

    /**
     * <code>GraphicsLayer</code> to hold results.
     * @default
     */
    protected var _resultGraphics:GraphicsLayer;

    /**
     * Temporary <code>GraphicsLayer</code> that will hold the identified point.
     * @default
     */
    protected var idLayer:GraphicsLayer;

    /**
     * The identified location.
     * @default
     */
    protected var idPoint:MapPoint;

    /**
     * <code>IdentifyTask</code> used to send requests.
     * @default
     */
    protected var idTask:IdentifyTask;

    [Bindable]
    /**
     * Holds the names of layers in a service.
     * @default
     */
    protected var infos:IList;

    /**
     * Current ID of for a layer in a service.
     * @default
     */
    protected var layerId:String;

    [Bindable]
    /**
     * Holds the identify results to be displayed in a list.
     * @default
     */
    protected var listColl:ArrayCollection;

    /**
     * Clear all Identify Results.
     */
    protected function clearData():void {
        if (listColl) {
            var inf:InfoData;
            for each (inf in listColl) {
                inf = null;
            }
            listColl.removeAll();
        }
    }

    /**
     * Assign the symbology base on Geometry type.
     * @param type
     * @return
     */
    protected function graphicSymbology(type:String):Symbol {
        switch (type) {
            case Geometry.MAPPOINT:
                var p:SimpleMarkerSymbol = new SimpleMarkerSymbol();
                p.color = ID_COLOR;
                p.style = "diamond";
                p.size = 15;
                p.alpha = 0.5;
                return p;
                break;
            case Geometry.POLYLINE:
                var l:SimpleLineSymbol = new SimpleLineSymbol();
                l.color = ID_COLOR;
                l.style = "solid";
                l.alpha = 0.5;
                l.width = 3;
                return l;
                break;
            case Geometry.POLYGON:
                var poly:SimpleFillSymbol = new SimpleFillSymbol();
                poly.color = ID_COLOR;
                poly.alpha = 0.5;
                return poly;
                break;
        }
        return new Symbol();
    }

    /**
     * Identify a point on the <code>map</code> or prepare <code>map</code> to perform Identify Task.
     */
    protected function identifyLayer():void {
        if (idPoint)
            sendParams();
        else {
            // do this to prevent multiple handlers being assigned
            if (_map.hasEventListener(MapMouseEvent.MAP_CLICK))
                _map.removeEventListener(MapMouseEvent.MAP_CLICK, onMapClicked_handler);

            _map.addEventListener(MapMouseEvent.MAP_CLICK, onMapClicked_handler, false, 0, true);
            _map.openHandCursorVisible = false;
        }
    }

    /**
     * Parse Identify Results to display on <code>map</code> and <code>idList</code>.
     * @param results
     */
    protected function iterateResults(results:Array):void {
        var field:String;
        var idResult:IdentifyResult;
        for each (idResult in results) {
            _resultGraphics.add(idResult.feature);
            var g:Graphic = idResult.feature;
            logger.debug("identify results for list = {0}", g.attributes.toString());

            var obj:Object = g.attributes;
            var title:String = idResult.layerName;
            var content:String = "";
            // Build the content string
            // You can use certain HTML tags and then use TextFlow and TextFlowUtil
            // in your ItemRenderer to display content
            for (field in obj) {
                if (field != "Shape_Area" && field != "Shape_Leng" && field != "Shape" && field != "Shape.Len" && field != "INTERNET" && field != "INTRANET") {
                    content += "<p><span fontWeight='bold'>" + field.toUpperCase() + "</span>: " + obj[field] + "</p>";
                }
            }
            var infoData:InfoData = new InfoData();
            idResult.feature.symbol = graphicSymbology(idResult.feature.geometry.type);
            infoData.title = idResult.layerName;
            infoData.content = content;
            infoData.graphic = idResult.feature;
            listColl.addItem(infoData);
        }
    }

    /**
     * Label Function for <code>cbLayer</code> ComboBox.
     * @param item
     * @return
     */
    protected function layerLabels(item:Object):String {
        return item.name;
    }

    /**
     * Reset the Identify Tool to perform a new Identify Task.
     * @param event
     */
    protected function onButtonClicked_handler(event:MouseEvent):void {
        idPoint = null;
        identifyLayer();
    }

    /**
     * Perform an Identify Task on currently selected Layer in Service using existing point on <code>map</code>.
     * @param event
     */
    protected function onCbLayersClose_handler(event:DropDownEvent):void {
        if (event.currentTarget.selectedItem) {
            logger.debug("layer from list chosen: id = {0}, name = {1}", event.currentTarget.selectedItem.id, event.currentTarget.selectedItem.name);
            layerId = event.currentTarget.selectedItem.id;
            identifyLayer();
        }
    }

    /**
     * Capture any erros when using Identify Task.
     * @param fault
     * @param clickGraphic
     */
    protected function onFault(fault:Object, clickGraphic:Graphic = null):void {
        logger.warn("identify error");
        _map.removeEventListener(MapMouseEvent.MAP_CLICK, onMapClicked_handler);
    }


    /**
     * Zoom the <code>map</code> to selected item.
     * @param event
     */
    protected function onIdListDoubleCliked_handler(event:MouseEvent):void {
        logger.debug("idList double cliked", event.currentTarget);
        if (event.currentTarget.selectedItem && event.currentTarget.selectedItem is InfoData) {
            // use the graphic in InfoData to zoom the map
            var g:Graphic = event.currentTarget.selectedItem.graphic;
            if (g.geometry.type != Geometry.MAPPOINT)
                _map.extent = g.geometry.extent.expand(2);
            else {
                try {
                    _map.centerAt(g.geometry as MapPoint);
                    if (_map.lods)
                        _map.level = _map.lods.length - 2;
                }
                catch (e:Error) {
                    logger.warn("error in zooming to point, ", e.message);
                }
            }
        }
    }

    /**
     * Handle results of Identify Task.
     * @param results
     * @param clickGraphic
     */
    protected function onIdentifyResults_handler(results:Array, clickGraphic:Graphic = null):void {
        if (results && results.length > 0)
            iterateResults(results);
    }

    /**
     *
     * @param event
     */
    protected function onMapClicked_handler(event:MapMouseEvent):void {
        logger.debug("map clicked, send identify request");
        _map.removeEventListener(MapMouseEvent.MAP_CLICK, onMapClicked_handler);
        _map.openHandCursorVisible = true;
        idPoint = event.mapPoint;
        sendParams();
    }

    override protected function partAdded(partName:String, instance:Object):void {
        super.partAdded(partName, instance);
        logger.debug("adding part to skinnable component: {0}", instance);
        if (instance == cbLayers) {
            cbLayers.dataProvider = infos;
            cbLayers.labelFunction = layerLabels;
            cbLayers.addEventListener(DropDownEvent.CLOSE, onCbLayersClose_handler, false, 0, true);
            layerId = "0";
            if (infos)
                cbLayers.selectedIndex = 0;
        }
        else if (instance == btnIdentify)
            btnIdentify.addEventListener(MouseEvent.CLICK, onButtonClicked_handler, false, 0, true);
        else if (instance == idList) {
            listColl = new ArrayCollection();
            idList.dataProvider = listColl;
            // try adding an event listener, will zoom map
            idList.addEventListener(MouseEvent.DOUBLE_CLICK, onIdListDoubleCliked_handler, false, 0, true);
        }
    }

    override protected function partRemoved(partName:String, instance:Object):void {
        super.partRemoved(partName, instance);
        logger.debug("remove part to skinnable component: {0}", instance);
        if (instance == cbLayers)
            cbLayers.removeEventListener(DropDownEvent.CLOSE, onCbLayersClose_handler);
        else if (instance == btnIdentify)
            btnIdentify.removeEventListener(MouseEvent.CLICK, onButtonClicked_handler);
        else if (instance == idList)
            idList.removeEventListener(MouseEvent.DOUBLE_CLICK, onIdListDoubleCliked_handler);
    }


    /**
     * Build Identify Paremeters and execute Identify Task.
     */
    protected function sendParams():void {
        _resultGraphics.clear();
        clearData();
        var idParams:IdentifyParameters = new IdentifyParameters();
        idParams.layerIds = [layerId];
        idParams.tolerance = 2;
        idParams.returnGeometry = true;
        idParams.geometry = idPoint;
        idParams.width = _map.width;
        idParams.height = _map.height;
        idParams.mapExtent = _map.extent;
        idParams.spatialReference = _map.spatialReference;
        idParams.layerOption = "all";
        var idSym:SimpleMarkerSymbol = new SimpleMarkerSymbol("x", 12, 0xFF0000);
        var g:Graphic = new Graphic(idPoint, idSym);
        idLayer.clear();
        idLayer.add(g);
        idTask.execute(idParams, new AsyncResponder(onIdentifyResults_handler, onFault, g));
    }

    /**
     * Cleans up Tool and prepares for GC.
     */
    public function dispose():void {
        logger.warn("identify tool destroyed, set values to null");
        cbLayers.removeEventListener(DropDownEvent.CLOSE, onCbLayersClose_handler);
        btnIdentify.removeEventListener(MouseEvent.CLICK, onButtonClicked_handler);
        idList.removeEventListener(MouseEvent.DOUBLE_CLICK, onIdListDoubleCliked_handler);
        _map.removeEventListener(MapMouseEvent.MAP_CLICK, onMapClicked_handler);
        clearData();
        idLayer.clear();
        _map.removeLayer(idLayer);
        _layer = null;
        _map = null;
        _resultGraphics = null;
        idTask = null;
        layerId = null;
        idPoint = null;
        listColl = null;
    }

    /**
     * Source Layer to perform Identify.
     * @param value
     */
    public function set layer(value:Layer):void {
        if (_layer != value) {
            _layer = value;
            var url:String;
            if (_layer is ArcGISDynamicMapServiceLayer)
                url = ArcGISDynamicMapServiceLayer(_layer).url;
            else if (_layer is ArcGISTiledMapServiceLayer)
                url = ArcGISTiledMapServiceLayer(_layer).url;

            idTask = new IdentifyTask();
            idTask.url = url;
            idTask.showBusyCursor = true;
            idTask.concurrency = "last";
            infos = LayerUtil.findLayerDetails(_layer);
            if (cbLayers)
                cbLayers.selectedIndex = 0;
            logger.debug("LayerInfos have been loaded: url = {0}", idTask.url);
        }
    }

    /**
     * Source Map of Identify Features.
     * @param value
     */
    public function set map(value:Map):void {
        if (_map != value) {
            _map = value;
            idLayer = new GraphicsLayer();
            _map.addLayer(idLayer);
        }
    }

    /**
     * GraphicsLayer that will display Identify Results.
     * @param value
     */
    public function set resultGraphics(value:GraphicsLayer):void {
        _resultGraphics = value;
    }
}
}

import com.esri.ags.Graphic;

import flash.events.EventDispatcher;

internal class InfoData extends EventDispatcher {
    /**
     * Formatted string of attrbutes.
     * @default
     */
    public var content:String;
    /**
     * Graphic object of identified item.
     * @default
     */
    public var graphic:Graphic;
    /**
     * Main title text for identified data.
     * @default
     */
    public var title:String;
}