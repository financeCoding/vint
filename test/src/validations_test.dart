part of vint_test;

class TestModelValidator implements Validator {
  Map validate(model) {
    if (model.name.isEmpty) {
      return {"name" : ["name cannot be blank"]};
    } else {
      return {};
    }
  }
}

testValidations() {
  group("validations", () {
    var model;
    var validations;

    group("adding validators", () {
      setUp(() {
        model = new TestModel({"name" : "", "age" : "25"});
        validations = new Validations();
      });

      test("using statically defined validators", () {
        validations.addValidator(new TestModelValidator());
        var errors = validations.validate(model);
        expect(errors["name"], equals(["name cannot be blank"]));
      });

      test("using dynamically created validators", () {
        validations.add((m) => !m.name.isEmpty, (m) => {"name" : ["name cannot be blank"]});
        var errors = validations.validate(model);
        expect(errors["name"], equals(["name cannot be blank"]));
      });

      test("notifying the validated object", () {
        var e = new EventCapturer();
        model.on.validation.add(e.callback);

        validations.add((m) => !m.name.isEmpty, (m) => {"name" : ["name cannot be blank"]});
        var errors = validations.validate(model);

        expect(e.event, equals(errors));
      });
    });

    group("presense validator", () {
      setUp(() {
        model = new TestModel({"name" : ""});
        validations = new Validations();
        validations.addValidator(new PresenceValidator("name"));
      });

      test("errors for an empty string", (){
        model.name = "";
        var errors = validations.validate(model);
        expect(errors["name"], isNotNull);
      });

      test("errors for null", () {
        model.name = null;
        var errors = validations.validate(model);
        expect(errors["name"], isNotNull);
      });

      test("doens't error for a non-empty string", (){
        model.name = "jim";
        var errors = validations.validate(model);
        expect(errors["name"], isNull);
      });

      test("doens't error for an object", (){
        model.name = 100;
        var errors = validations.validate(model);
        expect(errors["name"], isNull);
      });
    });

    group("numericality validator", () {
      setUp(() {
        model = new TestModel({"age": ""});
        validations = new Validations();
        validations.addValidator(new NumericalityValidator("age"));
      });

      test("doens't error when string is parseable", (){
        model.age = "25";
        var errors = validations.validate(model);
        expect(errors["age"], isNull);
      });

      test("errors otherwise", (){
        model.age = "sdks";
        var errors = validations.validate(model);
        expect(errors["age"], isNotNull);
      });

      test("doesn't error for null", () {
        model.age = null;
        var errors = validations.validate(model);
        expect(errors["age"], isNull);
      });

    });

    group("dsl", () {
      test("example", (){
        var model = new TestModel({"age": ""});
        var errors = validate().presence("age").numericality("age").of(model);
        expect(errors["age"], equals(["age cannot be blank", "age is not a number"]));
      });
    });
  });
}