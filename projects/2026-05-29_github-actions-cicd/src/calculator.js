class Calculator {
  add(a, b) {
    return a + b;
  }

  subtract(a, b) {
    return a - b;
  }

  multiply(a, b) {
    return a * b;
  }

  divide(a, b) {
    if (b === 0) {
      throw new Error('Division by zero');
    }
    return a / b;
  }

  power(base, exponent) {
    return Math.pow(base, exponent);
  }

  sqrt(num) {
    if (num < 0) {
      throw new Error('Cannot compute square root of negative number');
    }
    return Math.sqrt(num);
  }
}

module.exports = Calculator;
