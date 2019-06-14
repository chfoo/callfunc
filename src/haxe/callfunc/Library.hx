package callfunc;

interface Library extends Disposable {
    public function newFunction(name:String, ?params:Array<DataType>, ?returnType:DataType):Function;
}
