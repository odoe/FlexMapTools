package net.odoe.FlexMapTools.renderers {
import com.esri.ags.Graphic;
import com.esri.ags.renderers.Renderer;
import com.esri.ags.symbols.Symbol;

import net.odoe.FlexMapTools.factories.symbols.DefaultSymbols;
import net.odoe.FlexMapTools.factories.symbols.IGraphicSymbols;

/**
 * This renderer can be used to set symbology for <code>GraphicsLayer</code>
 * @author rrubalcava
 *
 */
public class DefaultGraphicRenderer extends Renderer {
    protected var defaultSymbol:IGraphicSymbols = new DefaultSymbols();

    override public function getSymbol(graphic:Graphic):Symbol {
        return defaultSymbol.getSymbol(graphic);
    }
}
}