package net.odoe.FlexMapTools.components {
import com.esri.ags.Map;
import com.esri.ags.geometry.MapPoint;
import com.esri.ags.utils.WebMercatorUtil;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.controls.Image;

import spark.components.Label;
import spark.components.SkinnableContainer;

/**
 * Custom Map object that can reposition the ESRI logo and display Lat/Long coordinates.
 * @author rrubalcava
 **/
public class FMap extends Map {
    public function FMap() {
        super();
    }

    /**
     * Numeric position for Bottom value of ESRI logo.
     * @default
     */
    public var logoToBottom:Number = 0;

    /**
     * Boolean to display Lat/Long coordinates.
     * @default
     */
    public var showLatLong:Boolean = false;

    /**
     * Label that will be used to display Lat/Long coordinates.
     * @default
     */
    protected var latLong:Label;

    /**
     * Skinnable container for <code>latLong</code> label.
     * @default
     */
    protected var labelArea:SkinnableContainer;

    override protected function createChildren():void {
        super.createChildren();

        if (logoToBottom > 0) {
            var i:uint = 0;
            var x:uint = this.staticLayer.numChildren;
            for (i; i < x; i++) {
                // logo should be only image object in staticlayer
                // but this could change in future releases
                if (this.staticLayer.getChildAt(i) is Image) {
                    // set the bottom property of the image
                    (this.staticLayer.getChildAt(i) as Image).bottom = logoToBottom;
                }
            }
        }

        if (showLatLong) {
            labelArea = new SkinnableContainer();
            latLong = new Label();
            // check for css style name, can be managed in main application
            // with normal font/color styles or a skin
            labelArea.styleName = "latLongText";
            labelArea.bottom = 2;
            labelArea.left = 5;
            latLong.text = "Coordinates";
            // add label to group
            labelArea.addElement(latLong);
            // add group to the staticLayer
            this.staticLayer.addElement(labelArea);

            // update the text with the MouseMove event on the map
            this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove_handler, false, 0, true);
        }

        this.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage_handler, false, 0, true);
    }

    /**
     * Will update <code>latLong</code> label text to display current Map coordinates.
     * @param e
     */
    protected function onMouseMove_handler(e:MouseEvent):void {
        if (this.spatialReference && this.spatialReference.wkid == 102113) {
            const mapPoint:MapPoint = this.toMapFromStage(e.stageX, e.stageY);
            const coord:MapPoint = WebMercatorUtil.webMercatorToGeographic(mapPoint) as MapPoint;
            latLong.text = "Lat: " + coord.y.toFixed(6)
                    + " / Long: " + coord.x.toFixed(6);
        }
    }

    /**
     * When Map is removed from stage, will remove all Event Listeners and set values to null.
     * @param e
     */
    protected function onRemovedFromStage_handler(e:Event):void {
        this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage_handler);

        if (this.hasEventListener(MouseEvent.MOUSE_MOVE))
            this.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove_handler);

        if (labelArea && labelArea.contains(latLong))
            labelArea.removeElement(latLong);

        labelArea = null;
        latLong = null;
    }

}
}