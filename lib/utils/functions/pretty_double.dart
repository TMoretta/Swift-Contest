String prettyDouble(double value) {
  // se non ho parte frazionaria, stampo solo l’intero
  if (value == value.truncateToDouble()) {
    return value.toInt().toString();
  }
  return value.toString();
}
