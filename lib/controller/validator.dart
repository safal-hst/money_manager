class Validator {
  static String? emptyValidate(String? value) {
    if (value == null || value.isEmpty) {
      return "This field cannot be blank !";
    }
    return null;
  }

  static String? validateDropdownValue(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a category !';
    }
    return null;
  }
}
