package net.odoe.FlexMapTools.components {
	import com.esri.ags.Map;
	import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
	import com.esri.ags.layers.ArcGISTiledMapServiceLayer;
	import com.esri.ags.utils.JSON;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.collections.XMLListCollection;
	import mx.core.IUIComponent;
	import mx.events.DragEvent;
	import mx.logging.ILogger;
	import mx.managers.DragManager;
	import mx.rpc.AsyncResponder;
	import mx.rpc.AsyncToken;
	import mx.rpc.Responder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import net.odoe.FlexMapTools.utils.LogUtil;
	
	import spark.components.List;
	import spark.components.supportClasses.SkinnableComponent;

	/**
	 * Custom component to display list of MapServer services that can be dragged
	 * to a Map.
	 * @author rrubalcava
	 */
	public class ServiceList extends SkinnableComponent implements IDisposable {
		
		public namespace sitemapNS = "http://www.sitemaps.org/schemas/sitemap/0.9";
		
		protected static const logger:ILogger = LogUtil.getLogger(ServiceList);
		
		/**
		 * Constructor
		 */
		public function ServiceList() {
			super();
		}
		
		[SkinPart(type="required")]
		/**
		 * List that will hold services names and urls.
		 * @default 
		 */
		public var servicesList:List;
		
		/**
		 * Target map that will be used to drag items to.
		 * @default 
		 */
		protected var _map:Map;
		
		/**
		 * Dataprovider for <code>servicesList</code>.
		 * @default 
		 */
		protected var dataList:IList;
		
		/**
		 * Vector object that will keep track of URLs added to Map.
		 * @default 
		 */
		protected var vUrls:Vector.<String>;
		
		/**
		 * Parses <code>ServiceItem</code> object into a layer to be added to the Map.
		 * @param item
		 */
		protected function addLayerToMap(item:ServiceItem):void {
			logger.debug("add layer to map: {0}", item.url);
			var i:uint = 0;
			var x:uint = vUrls.length;
			for (i; i < x; i = i + 1) {
				if (!vUrls[i]) {
					vUrls[i] = item.url;
					break;
				}
			}
			
			var jsonurl:String = "?f=json&pretty=false";
			var url:String = item.url + jsonurl;
			
			var srv:HTTPService = new HTTPService();
			srv.url = url;
			srv.resultFormat = "text";
			var token:AsyncToken = srv.send();
			token.addResponder(new Responder(onJSONResult_handler, onFault_handler));
			
			function onJSONResult_handler(event:ResultEvent):void {
				var data:String = event.result.toString();
				data = data.replace( /\s/g, '' );
				var details:Object = JSON.decode(data);
				if (!details["singleFusedMapCache"]) {
					var dLayer:ArcGISDynamicMapServiceLayer = new ArcGISDynamicMapServiceLayer();
					dLayer.url = item.url;
					_map.addLayer(dLayer);
				}
				else {
					var tLayer:ArcGISTiledMapServiceLayer = new ArcGISTiledMapServiceLayer();
					tLayer.url = item.url;
					_map.addLayer(tLayer);	
				}
			}
		}
		
		/**
		 * Checks to see if current URL has already been added to Map.
		 * @param url
		 * @return 
		 */
		protected function isInMap(url:String):Boolean {
			var i:uint = 0;
			var x:uint = vUrls.length;
			for (i; i < x; i = i + 1) {
				if (vUrls[i] == url)
					return true;
			}
			return false;
		}
		
		/**
		 * Handle Drag function to Map.
		 * @param event
		 */
		protected function onDragToMapDrop_handler(event:DragEvent):void {
			var items:Vector.<Object> = event.dragSource.dataForFormat("itemsByIndex") as Vector.<Object>;
			var item:ServiceItem = items[0] as ServiceItem;
			if (!isInMap(item.url))
				addLayerToMap(item);
			else
				logger.debug("layer already exist in map: {0}", item.url);
		}
		
		/**
		 * Allow Drag to occur on Map.
		 * @param event
		 */
		protected function onDragToMapEnter_handler(event:DragEvent):void {
			DragManager.acceptDragDrop(event.target as IUIComponent);
		}
		
		/**
		 * Handles errors when data is being accessed.
		 * @param event
		 * @param token
		 */
		protected function onFault_handler(event:FaultEvent, token:Object = null):void {
			logger.fatal("An error has occured: {0}", event.fault);
		}
		
		/**
		 * Handles the results of accessing the SiteMap.
		 * @param event
		 * @param token
		 */
		protected function onServiceResults_handler(event:ResultEvent, token:Object = null):void {
			var xml:XML = event.result as XML;
			var xmlColl:XMLListCollection = new XMLListCollection(xml.children());
			var list:Array = [];
			var qn:QName = new QName(sitemapNS, "loc");
			var sxml:XML;
			for each (sxml in xmlColl) {
				var url:String = sxml[qn].text();
				var tmp:Array = url.split("/");
				var i:uint = tmp.length;
				if (tmp[i-1] == "MapServer") {
					var item:ServiceItem = new ServiceItem();
					item.type = tmp[i-1];
					item.name = tmp[i-2];
					item.url = url;
					list.push(item);
				}
			}
			list.sortOn("name");
			dataList = new ArrayList(list);
			vUrls = new Vector.<String>(list.length);
			servicesList.dataProvider = dataList;
		}
		
		/**
		 * Cleans up all data.
		 */
		public function dispose():void {
			_map.removeEventListener(DragEvent.DRAG_ENTER, onDragToMapEnter_handler);
			_map.removeEventListener(DragEvent.DRAG_DROP, onDragToMapDrop_handler);
			_map = null;
			
			dataList.removeAll();
			dataList = null;
			
			vUrls = null;
			
			servicesList = null;
		}
		
		/**
		 * Takes URL for a ArcGIS Server Rest directory and
		 * will attempt to extract the SiteMap.
		 * @param directory
		 */
		public function loadServices(directory:String):void {
			var service:HTTPService = new HTTPService();
			var sitemap:String = "/?f=sitemap";
			var url:String = directory + sitemap;
			service.url = url;
			service.resultFormat = "e4x";
			var token:AsyncToken = service.send();
			token.addResponder(new AsyncResponder(onServiceResults_handler, onFault_handler));
		}
		
		/**
		 * Setter for the map.
		 * @param value
		 */
		public function set map(value:Map):void {
			if (_map != value) {
				_map = value;
				_map.addEventListener(DragEvent.DRAG_ENTER, onDragToMapEnter_handler, false, 0, true);
				_map.addEventListener(DragEvent.DRAG_DROP, onDragToMapDrop_handler, false, 0, true);
			}
		}
	}
}

import flash.events.EventDispatcher;
[Bindable]
internal class ServiceItem extends EventDispatcher {
	public var name:String;
	public var type:String;
	public var url:String;
}