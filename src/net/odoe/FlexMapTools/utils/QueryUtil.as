package net.odoe.FlexMapTools.utils {
import com.esri.ags.geometry.Geometry;
import com.esri.ags.tasks.supportClasses.Query;

/**
 * Purpose of this Object is to create Query objects with specific parameters.
 * @author rrubalcava
 */
public class QueryUtil {
    /**
     * Purpose of this function is produce a Query object that will be based on a given Geometry.
     * @param geometry Geometry
     * @param outFields Array
     * @param returnGeometry Boolean
     * @return Query
     */
    public static function queryByGeometry(geometry:Geometry, outFields:Array, returnGeometry:Boolean = true):Query {
        var query:Query = new Query();
        query.geometry = geometry;
        query.outFields = outFields;
        query.returnGeometry = returnGeometry;

        return query;
    }

    /**
     * Purpose of this function is produce a Query object that will be based on a given where clause.
     * @param where String
     * @param outFields Array
     * @param returnGeometry Boolean
     * @return Query
     */
    public static function queryByWhere(where:String, outFields:Array, returnGeometry:Boolean = true):Query {
        var query:Query = new Query();
        query.where = where;
        query.outFields = outFields;
        query.returnGeometry = returnGeometry;

        return query;
    }

    /**
     * Purpose of this function is produce a Query object that will be based on a given where clause.
     * @param items Array
     * @param fieldName String
     * @return String
     */
    public static function queryStringFromArray(items:Array, fieldName:String):String {
        var where:String = "";
        for each(var item:String in items) {
            if (item != "") where += fieldName + " = " + item + " OR ";
        }
        var trim:int = where.length - 4;
        return where.substr(0, trim);
    }
}
}