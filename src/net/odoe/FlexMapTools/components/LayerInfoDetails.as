package net.odoe.FlexMapTools.components {
	import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
	import com.esri.ags.layers.ArcGISTiledMapServiceLayer;
	import com.esri.ags.layers.Layer;
	import com.esri.ags.layers.supportClasses.AllDetails;
	import com.esri.ags.layers.supportClasses.LayerDetails;
	import com.esri.ags.layers.supportClasses.LayerInfo;
	import com.esri.ags.renderers.ClassBreaksRenderer;
	import com.esri.ags.renderers.SimpleRenderer;
	import com.esri.ags.renderers.UniqueValueRenderer;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.logging.ILogger;
	import mx.rpc.AsyncResponder;
	import mx.utils.ObjectUtil;
	
	import net.odoe.FlexMapTools.components.events.LayerInfoDetailsEvent;
	import net.odoe.FlexMapTools.utils.LogUtil;
	
	import spark.components.DataGroup;
	import spark.components.supportClasses.SkinnableComponent;
	
	/**
	 * This component holds detailed information on all layers within a given service.
	 * @author rrubalcava
	 */
	public class LayerInfoDetails extends SkinnableComponent implements IDisposable {
		protected static const logger:ILogger = LogUtil.getLogger(LayerInfoDetails);
		
		/**
		 * Constructor
		 */
		public function LayerInfoDetails() {
			super();
		}
		
		[SkinPart(required="true")]
		/**
		 * List that will display the <code>LayerInfos</code> data.
		 * @default
		 */
		public var layerControl:DataGroup;
		
		[Bindable]
		/**
		 * Backing variable for ready-only property <code>layer</code>.
		 * @default
		 */
		protected var _layer:Layer;
		
		/**
		 * Collection that will contain the <code>LayerInfos</code> data.
		 * @default
		 */
		protected var infos:ArrayCollection;
		
		/**
		 * Function will be verify that defaultVisibility value will match the vivisbleLayers of an <code>ArcGISDynamicMapServiceLayer</code>.
		 * @param layerInfo
		 */
		protected function cleanLayerInfos(layerInfo:LayerInfo):void {
			var ac:ArrayCollection = (_layer as ArcGISDynamicMapServiceLayer).visibleLayers;
			layerInfo.defaultVisibility = ac.contains(String(layerInfo.id));
		}
		
		/**
		 * Function will extract LayerInfos data from the given service.
		 */
		protected function findLayerDetails():void {
			var layerInfos:Array;
			if (_layer is ArcGISDynamicMapServiceLayer)
				layerInfos = ArcGISDynamicMapServiceLayer(_layer).layerInfos;
			else if (_layer is ArcGISTiledMapServiceLayer)
				layerInfos = ArcGISTiledMapServiceLayer(_layer).layerInfos;
			else
				logger.warn("Not a layer I care about, do nothing");
			
			if (layerInfos) {
				var rootLayers:Array = findRootLayers(layerInfos);
				for each (var layerInfo:LayerInfo in rootLayers) {
					logger.debug("check layerInfo: {0}", layerInfo);
					trace("layer name = "+ layerInfo.name + " , layer defaultVisibility = " + layerInfo.defaultVisibility);
					// You may need to use this function in your application
					// if you define visible layers differently
					/*if (_layer is ArcGISDynamicMapServiceLayer)
						this.cleanLayerInfos(layerInfo);*/
					var info:LayerData = new LayerData();
					info.map = _layer.map;
					info.layerID = layerInfo.id;
					info.layerInfo = layerInfo;
					
					if (_layer is ArcGISDynamicMapServiceLayer) {
						ArcGISDynamicMapServiceLayer(_layer).getAllDetails(new AsyncResponder(getAllDetailsResult, null, info));
					}
					else {
						infos.addItem(info);
					}
				}
			}
			
			function getAllDetailsResult(allDetails:AllDetails, token:Object = null):void {
				var item:LayerData = token as LayerData;
				var lDetails:LayerDetails;
				for each (lDetails in allDetails.layersDetails) {
					if (lDetails.drawingInfo && lDetails.name == item.layerInfo.name) {
						if (lDetails.drawingInfo.renderer is UniqueValueRenderer) {
							var uv:UniqueValueRenderer = lDetails.drawingInfo.renderer as UniqueValueRenderer;
							item.rend = uv;
						}
						else if (lDetails.drawingInfo.renderer is SimpleRenderer) {
							var simple:SimpleRenderer = lDetails.drawingInfo.renderer as SimpleRenderer
							item.rend = simple;
						}
						else if (lDetails.drawingInfo.renderer is ClassBreaksRenderer) {
							var cb:ClassBreaksRenderer = lDetails.drawingInfo.renderer as ClassBreaksRenderer;
							item.rend = cb;
						}
						item.maxScale = lDetails.maxScale;
						item.minScale = lDetails.minScale;
						infos.addItem(item);
					}
				}
				var sortField:SortField = new SortField();
				sortField.name = "layerID";
				sortField.numeric = true;
				var sort:Sort = new Sort();
				sort.fields = [sortField];
				infos.sort = sort;
				infos.refresh();
			}
			
			function findRootLayers(layerInfos:Array):Array {
				var roots:Array = [];
				for each (var layerInfo:LayerInfo in layerInfos) {
					// ArcGIS: parentLayerId is -1
					// ArcIMS: parentLayerId is NaN
					if (isNaN(layerInfo.parentLayerId) || layerInfo.parentLayerId == -1) {
						roots.push(layerInfo);
					}
				}
				return roots;
			}
		}
		
		/**
		 * Function will adjust the visible layers of a Layer based on changes made in <code>layerControl</code>
		 * @param strIndex
		 */
		protected function layerVisibility(index:int):void {
			var ac:ArrayCollection = (_layer as ArcGISDynamicMapServiceLayer).visibleLayers;
			// In some environments, you may need to check by string, not int
			// My visible layers are defined by a config file and stored as strings
			// so be aware, you may need to modify this fit your needs
			if (ac.contains(index))
				ac.removeItemAt(ac.getItemIndex(index));
			else
				ac.addItem(index);
			// once a visible layer has been added or removed, need to refresh the service
			_layer.refresh();
		}
		
		/**
		 * Function to process any changes made in <code>layerControl</code>.
		 * @param e
		 */
		protected function onLayerInfoDetailsUpdated(e:LayerInfoDetailsEvent):void {
			logger.debug("layer info details updated, layer id = {0} | visible = {1}", e.layerID, e.visible);
			e.stopImmediatePropagation();
			if (_layer is ArcGISDynamicMapServiceLayer) {
				var ac:ArrayCollection = (_layer as ArcGISDynamicMapServiceLayer).visibleLayers;
				this.layerVisibility(e.layerID);
			}
		}
		
		override protected function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			logger.debug("adding part to skinnable component: {0}", instance);
			if (instance == layerControl) {
				infos = new ArrayCollection();
				layerControl.dataProvider = infos;
				layerControl.addEventListener(LayerInfoDetailsEvent.VISIBLE_LAYER_ID, onLayerInfoDetailsUpdated);
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			logger.debug("remove part to skinnable component: {0}", instance);
			if (instance == layerControl)
				layerControl.removeEventListener(LayerInfoDetailsEvent.VISIBLE_LAYER_ID, onLayerInfoDetailsUpdated);
		}
		
		/**
		 * Clean up function for this object.
		 */
		public function dispose():void {
			logger.debug("set object properties to null");
			if (infos)
				infos = null;
			if (_layer)
				_layer = null;
		}
		
		/**
		 * Read-only setter for Layer object.
		 * @param value
		 */
		public function set layer(value:Layer):void {
			if (_layer != value) {
				_layer = value;
				logger.warn("Setting layer");
				this.findLayerDetails();
			}
		}
	}
}

import com.esri.ags.Map;
import com.esri.ags.layers.supportClasses.LayerInfo;

import flash.events.EventDispatcher;

[Bindable]
internal class LayerData extends EventDispatcher {
	public var map:Map;
	public var layerID:uint;
	public var layerInfo:LayerInfo;
	public var rend:*;
	public var maxScale:Number;
	public var minScale:Number;
}