package net.odoe.FlexMapTools.factories.graphics {
import com.esri.ags.Graphic;
import com.esri.ags.layers.GraphicsLayer;
import com.esri.ags.symbols.Symbol;

import net.odoe.FlexMapTools.factories.symbols.HighlightSymbols;
import net.odoe.FlexMapTools.factories.symbols.IGraphicSymbols;

/**
 * Abstract class: Do not instantiate
 *
 * @author rrubalcava
 *
 */
public class BaseGraphic {

    /**
     *
     */
    public function BaseGraphic() {
        graphic = new Graphic();
        defaultSymbol = new Symbol();
    }

    /**
     *
     * @default
     */
    protected var defaultSymbol:Symbol;
    /**
     *
     * @default
     */
    protected var graphic:Graphic;

    /**
     * This function will reset the previously selected graphic
     * to its default symbology.
     *
     * @param data Holds attribute information; i.e. from a ListEvent (event.itemRenderer.data).
     * @param graphicsLayer Holds the graphics that can be selected.
     * @return Graphic.
     *
     */
    public function resetDefaultGraphic(data:Object, graphicsLayer:GraphicsLayer):Graphic {
        return null;
    }

    /**
     * This function will save the default graphic symbology
     * highlight the graphic for the currently selected item.
     *
     * @param data Attribute information; i.e. from a ListEvent (event.itemRenderer.data).
     * @param graphicsLayer Graphics that can be selected.
     * @return Higlighted Graphic.
     *
     */
    public function setHighlightGraphic(data:Object, graphicsLayer:GraphicsLayer):Graphic {
        return null;
    }

    /**
     * Purpose of this function is to highlight a Feature in the GraphicsLayer.
     *
     * @param data Attribute object that holds information about feature to highlight.
     * @param graphicsLayer Contains the highlight Graphics.
     * @return Highlighted Graphic.
     */
    protected function featureHighlight(data:Object, graphicsLayer:GraphicsLayer):Graphic {
        if (graphicsLayer) {
            return this.setGraphic(true, data, graphicsLayer);
        }
        return new Graphic();
    }

    /**
     * Purpose of this function is to find Graphics by their Attributes.
     *
     * @param attributes Graphic to find.
     * @param graphicsLayer GraphicsLayer that contains Graphics.
     * @return The found Graphic.
     */
    protected function findGraphicByAttribute(attributes:Object, graphicsLayer:GraphicsLayer):Graphic {
        for each (var _graphic:Graphic in graphicsLayer.graphicProvider) {
            if (_graphic.attributes == attributes) {
                return _graphic;
            }
        }
        return new Graphic();
    }

    /**
     * Purpose of this function is to build the highlighted Symbol.
     *
     * @param graphic
     * @return Symbol
     */
    protected function highLightSymbol(graphic:Graphic):Symbol {
        if (graphic.geometry) {
            var highlight:IGraphicSymbols = new HighlightSymbols();
            return highlight.getSymbol(graphic);
        }

        return new Symbol();
    }

    /**
     * Purpose of this function is to set the Graphic to either a highlighted symbol or default symbol.
     *
     * @param highlight Is the Graphic to be highlighted.
     * @param data Attributes of Graphic to highlight.
     * @param graphicsLayer Contains Graphic to highlight.
     * @return Graphic with requested Symbol.
     */
    protected function setGraphic(highlight:Boolean, data:Object, graphicsLayer:GraphicsLayer):Graphic {
        if (graphicsLayer) {
            var aGraphic:Graphic = this.findGraphicByAttribute(data, graphicsLayer);
            if (highlight) {
                aGraphic.symbol = this.highLightSymbol(aGraphic);
                return aGraphic;
            }
            aGraphic.symbol = this.defaultSymbol;
            return aGraphic;
        }
        return new Graphic();
    }
}
}