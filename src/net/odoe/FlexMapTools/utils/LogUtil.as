package net.odoe.FlexMapTools.utils {
import flash.utils.getQualifiedClassName;

import mx.logging.ILogger;
import mx.logging.Log;

public class LogUtil {
    public static function getLogger(c:Class):ILogger {
        var className:String =
                getQualifiedClassName(c).replace("::", ".");
        return Log.getLogger(className);
    }
}
}