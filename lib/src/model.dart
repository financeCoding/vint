part of simple_mvp;

/**
* The base class for model classes. It manages attribute changes, and persistence.
*/
abstract class Model {
  Storage storage;
  ModelAttributes attributes;
  ModelList modelList;

  final ModelEvents on = new ModelEvents();

  Model(Map attributes, [this.modelList]){
    this.attributes = new ModelAttributes(this, attributes);
    storage = new Storage({
        "read" : rootUrl,
        "create" : createUrl,
        "update" : updateUrl,
        "destroy" : destroyUrl});
  }

  /**
  * Abstract property to be overridden by subclasses. It's used by Storage.
  * By default [createUrl], [updateUrl], and [destroyUrl] are equal to [rootUrl].
  */
  String get rootUrl;
  String get createUrl => rootUrl;
  String get updateUrl => rootUrl;
  String get destroyUrl => rootUrl;

  get id => attributes["id"];

  bool get saved => attributes.hasId();

  Future save(){
    var f = saved ? storage.update(id, attributes) : storage.create(attributes);
    f.then((attrs) => attributes.reset(attrs));
    return f;
  }

  Future destroy(){
    if(modelList != null){
      modelList.remove(this);
    }
    return storage.destroy(id);
  }

  operator [] (String name) => attributes[name];

  operator []= (String name, value) => attributes[name] = value;

  noSuchMethod(InvocationMirror invocation){
    if(invocation.isGetter){
      return this[invocation.memberName];
    } else if (invocation.isSetter){
      var propertyName = _removeEqualsSign(invocation.memberName);
      return this[propertyName] = invocation.positionalArguments[0];
    }

    throw new NoSuchMethodError(this, invocation.memberName, invocation.positionalArguments, invocation.namedArguments);
  }

  _removeEqualsSign(String setter)
    => setter.substring(0, setter.length - 1);
}