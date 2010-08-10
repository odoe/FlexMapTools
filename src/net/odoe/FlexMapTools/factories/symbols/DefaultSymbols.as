package net.odoe.FlexMapTools.factories.symbols {
import com.esri.ags.symbols.SimpleFillSymbol;
import com.esri.ags.symbols.SimpleLineSymbol;
import com.esri.ags.symbols.SimpleMarkerSymbol;
import com.esri.ags.symbols.Symbol;

public class DefaultSymbols extends BaseSymbols {
    override protected function getLineSymbol():Symbol {
        lineSymbol = new SimpleLineSymbol();
        lineSymbol.color = 0xFFFF00;
        lineSymbol.width = 6;
        lineSymbol.alpha = 0.75;

        return lineSymbol;
    }

    override protected function getPolySymbol():Symbol {
        polySymbol = new SimpleFillSymbol;
        polySymbol.style = "solid";
        polySymbol.color = 0xFFFF00;
        polySymbol.alpha = 0.3;
        polySymbol.outline = getOutline();

        return polySymbol;
    }

    override protected function getPointSymbol():Symbol {
        pointSymbol = new SimpleMarkerSymbol;
        pointSymbol.style = "circle";
        pointSymbol.color = 0x00FFFF;
        pointSymbol.size = 10;
        pointSymbol.alpha = .9;
        pointSymbol.outline = getOutline();

        return pointSymbol;
    }

    override protected function getOutline():SimpleLineSymbol {
        outline = new SimpleLineSymbol;
        outline.style = "solid";
        outline.color = 0x0000CD;
        outline.width = 2;

        return outline;
    }

}
}