package net.odoe.FlexMapTools.utils {

/**
 * Iterator functionality based on Duff's Device.
 * Credited to Tom Duff.
 * http://en.wikipedia.org/wiki/Duff's_device
 * @author rrubalcava
 */
public class IteratorUtil {
	/**
	 * Optimized implementation of Duff's Device
     * Based on code sample in High Performance Javascript, page 67.
     * Credit: Jeff Greenberg
	 * @param ar
	 * @param process
	 */
	public static function duffDeviceOptimized(ar:Array, process:Function):void {
		var x:int = ar.length;
		if (x > 0) {
			var t:int = 0;
			var n:int = x % 8;
			while (n--) {
				process(ar[t++]);
			}
			n = Math.floor((x + 7) / 8);
			while (n--) {
				process(ar[t++]);
				process(ar[t++]);
				process(ar[t++]);
				process(ar[t++]);
				process(ar[t++]);
				process(ar[t++]);
				process(ar[t++]);
				process(ar[t++]);
			}
		}
	}
	
	/**
	 * Standard implementation of Duff's Device
     * Based on code sample in High Performance Javascript, page 67.
     * Credit: Jeff Greenberg
	 * @param ar
	 * @param process
	 */
	public static function duffDeviceSwitch(ar:Array, process:Function):void {
		var x:int = ar.length;
		if (x > 0) {
			var t:int = 0;
			var n:int = Math.floor((x + 7) / 8);
			var startAt:int = x % 8
			do {
				switch (startAt) {
					case 0:
						process(ar[t++]);
					case 7:
						process(ar[t++]);
					case 6:
						process(ar[t++]);
					case 5:
						process(ar[t++]);
					case 4:
						process(ar[t++]);
					case 3:
						process(ar[t++]);
					case 2:
						process(ar[t++]);
					case 1:
						process(ar[t++]);
				}
				startAt = 0;
			}
			while (--n > 0);
		}
	}
}
}