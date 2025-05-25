int parseStringToInt(String str) {
  // Implement robust parsing here, handling '+', '-', '0x', '0b' etc.
  // For simplicity, a basic parse:
  if (str.startsWith('0x')) {
    return int.parse(str.substring(2), radix: 16);
  }

  if (str.startsWith('0b')) {
    return int.parse(str.substring(2), radix: 2);
  }

  return int.parse(str);
}
