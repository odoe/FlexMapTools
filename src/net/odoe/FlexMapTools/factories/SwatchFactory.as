/**
 * Created by IntelliJ IDEA.
 * User: odoe
 * Date: Sep 1, 2010
 * Time: 8:29:44 PM
 * To change this template use File | Settings | File Templates.
 */
package net.odoe.FlexMapTools.factories {
import com.esri.ags.symbols.PictureMarkerSymbol;
import com.esri.ags.symbols.SimpleFillSymbol;
import com.esri.ags.symbols.SimpleLineSymbol;
import com.esri.ags.symbols.SimpleMarkerSymbol;

import flash.display.Loader;
import flash.events.Event;
import flash.system.LoaderContext;

import mx.core.UIComponent;
import mx.logging.ILogger;

import net.odoe.FlexMapTools.utils.LogUtil;

import spark.primitives.BitmapImage;

public class SwatchFactory {
	protected static var logger:ILogger = LogUtil.getLogger(SwatchFactory);
	
	public function SwatchFactory() {
	}
	
	// this method was derived from the Dynamic Legend Widget for Flex Viewer 2.0
	// by Robert Scheitlin. Thanks for doing the leg work on build symbology from
	// LayerDetails information
	// http://www.arcgis.com/home/item.html?id=f60406b9f52340d59eb557bf64136af6
	public function drawSwatch(rend:*):Swatch {
		var swatch:Swatch = new Swatch();
		var uic:UIComponent;
		logger.debug("draw swatch based on symbol: {0}", rend.symbol);
		if (rend.symbol is SimpleMarkerSymbol) {
			switch (rend.symbol.style) {
				case "circle":
					var crSMSline:SimpleLineSymbol = new SimpleLineSymbol("solid", rend.symbol.outline.color ? rend.symbol.outline.color : 0x000000, rend.symbol.outline.alpha ? rend.symbol.outline.alpha : 1, rend.symbol.outline.width);
					var SMSCircle:SimpleMarkerSymbol = new SimpleMarkerSymbol(rend.symbol.style, rend.symbol.size, rend.symbol.color ? rend.symbol.color : 0x000000, rend.symbol.alpha ? rend.symbol.alpha : 1, rend.symbol.xoffset, rend.symbol.yoffset, rend.symbol.angle, crSMSline);
					uic = SMSCircle.createSwatch(30, 18);
					uic.left = 5;
					uic.top = 1;
					uic.bottom = 1;
					break;
				case "cross":
					var cSMSline:SimpleLineSymbol = new SimpleLineSymbol("solid", rend.symbol.outline.color ? rend.symbol.outline.color : 0x000000, rend.symbol.outline.alpha ? rend.symbol.outline.alpha : 1, rend.symbol.outline.width);
					var SMSCross:SimpleMarkerSymbol = new SimpleMarkerSymbol(rend.symbol.style, rend.symbol.size, rend.symbol.color ? rend.symbol.color : 0x000000, rend.symbol.alpha ? rend.symbol.alpha : 1,
																			 rend.symbol.xoffset, rend.symbol.yoffset, rend.symbol.angle, cSMSline);
					uic = SMSCross.createSwatch(30, 18);
					uic.left = 5;
					uic.top = 1;
					uic.bottom = 1;
					break;
				case "diamond":
					var dSMSline:SimpleLineSymbol = new SimpleLineSymbol("solid", rend.symbol.outline.color ? rend.symbol.outline.color : 0x000000, rend.symbol.outline.alpha ? rend.symbol.outline.alpha : 1, rend.symbol.outline.width);
					var SMSDiamond:SimpleMarkerSymbol = new SimpleMarkerSymbol(rend.symbol.style, rend.symbol.size, rend.symbol.color ? rend.symbol.color : 0x000000, rend.symbol.alpha ? rend.symbol.alpha : 1,
																			   rend.symbol.xoffset, rend.symbol.yoffset, rend.symbol.angle, dSMSline);
					uic = SMSDiamond.createSwatch(30, 18);
					uic.left = 5;
					uic.top = 1;
					uic.bottom = 1;
					break;
				case "square":
					var sSMSline:SimpleLineSymbol = new SimpleLineSymbol("solid", rend.symbol.outline.color ? rend.symbol.outline.color : 0x000000, rend.symbol.outline.alpha ? rend.symbol.outline.alpha : 1, rend.symbol.outline.width);
					var SMSSquare:SimpleMarkerSymbol = new SimpleMarkerSymbol(rend.symbol.style, rend.symbol.size, rend.symbol.color ? rend.symbol.color : 0x000000, rend.symbol.alpha ? rend.symbol.alpha : 1,
																			  rend.symbol.xoffset, rend.symbol.yoffset, rend.symbol.angle, sSMSline);
					uic = SMSSquare.createSwatch(30, 18);
					uic.left = 5;
					uic.top = 1;
					uic.bottom = 1;
					break;
				case "triangle":
					var tSMSline:SimpleLineSymbol = new SimpleLineSymbol("solid", rend.symbol.outline.color ? rend.symbol.outline.color : 0x000000, rend.symbol.outline.alpha ? rend.symbol.outline.alpha : 1, rend.symbol.outline.width);
					var SMSTri:SimpleMarkerSymbol = new SimpleMarkerSymbol(rend.symbol.style, rend.symbol.size, rend.symbol.color ? rend.symbol.color : 0x000000, rend.symbol.alpha ? rend.symbol.alpha : 1,
																		   rend.symbol.xoffset, rend.symbol.yoffset, rend.symbol.angle, tSMSline);
					uic = SMSTri.createSwatch(30, 18);
					uic.left = 5;
					uic.top = 1;
					uic.bottom = 1;
					break;
				case "x":
					var xSMSline:SimpleLineSymbol = new SimpleLineSymbol("solid", rend.symbol.outline.color ? rend.symbol.outline.color : 0x000000, rend.symbol.outline.alpha ? rend.symbol.outline.alpha : 1, rend.symbol.outline.width);
					var SMSX:SimpleMarkerSymbol = new SimpleMarkerSymbol(rend.symbol.style, rend.symbol.size, rend.symbol.color ? rend.symbol.color : 0x000000, rend.symbol.alpha ? rend.symbol.alpha : 1,
																		 rend.symbol.xoffset, rend.symbol.yoffset, rend.symbol.angle, xSMSline);
					uic = SMSX.createSwatch(30, 18);
					uic.left = 5;
					uic.top = 1;
					uic.bottom = 1;
					break;
				default:
					break;
			}
		}
		else if (rend.symbol is SimpleLineSymbol) {
			var line:SimpleLineSymbol = new SimpleLineSymbol(rend.symbol.style, rend.symbol.color ? rend.symbol.color : 0x000000, rend.symbol.alpha ? rend.symbol.alpha : 1, rend.symbol.width);
			uic = line.createSwatch(30, 18);
			uic.left = 5;
			uic.top = 1;
			uic.bottom = 1;
		}
		else if (rend.symbol is SimpleFillSymbol) {
			var sSFSline:SimpleLineSymbol;
			if (rend.symbol.outline)
				sSFSline = new SimpleLineSymbol(rend.symbol.outline.style, rend.symbol.outline.color ? rend.symbol.outline.color : 0x000000, rend.symbol.outline.alpha ? rend.symbol.outline.alpha : 1, rend.symbol.outline.width);
			var SFSRect:SimpleFillSymbol = new SimpleFillSymbol(rend.symbol.style, rend.symbol.color ? rend.symbol.color : 0x000000, rend.symbol.alpha ? rend.symbol.alpha : 1, sSFSline ? sSFSline : null);
			uic = SFSRect.createSwatch(30, 18);
			uic.left = 5;
			uic.top = 1;
			uic.bottom = 1;
		}
		else if (rend.symbol is PictureMarkerSymbol) {
			var bmp:BitmapImage = new BitmapImage();
			var _loader:Loader = new Loader();
			var lc:LoaderContext = new LoaderContext(false);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
					bmp.smooth = true;
					bmp.source = e.currentTarget.content;
					bmp.top = 1;
					bmp.bottom = 1;
					bmp.left = 5;
					bmp.rotation = rend.symbol.angle;
				}
				);
			_loader.loadBytes(rend.symbol.source, lc);
			swatch.bmp = bmp;
		}
		else {
			logger.fatal("no symbology defined for given renderer: {0}", rend);
		}
		swatch.uic = uic;
		if (rend.label)
			swatch.description = rend.label;
		else
			swatch.description = "";
		
		return swatch;
	}
}
}
import mx.core.UIComponent;

import spark.primitives.BitmapImage;

internal class Swatch {
	public var uic:UIComponent;
	public var bmp:BitmapImage;
	public var description:String;
}