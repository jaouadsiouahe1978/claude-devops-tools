const Calculator = require('../src/calculator');

describe('Calculator', () => {
  let calc;

  beforeEach(() => {
    calc = new Calculator();
  });

  describe('add', () => {
    it('should add two positive numbers', () => {
      expect(calc.add(2, 3)).toBe(5);
    });

    it('should add negative numbers', () => {
      expect(calc.add(-2, -3)).toBe(-5);
    });

    it('should add mixed numbers', () => {
      expect(calc.add(5, -3)).toBe(2);
    });
  });

  describe('subtract', () => {
    it('should subtract two numbers', () => {
      expect(calc.subtract(10, 4)).toBe(6);
    });

    it('should handle negative results', () => {
      expect(calc.subtract(3, 5)).toBe(-2);
    });
  });

  describe('multiply', () => {
    it('should multiply two numbers', () => {
      expect(calc.multiply(4, 5)).toBe(20);
    });

    it('should handle multiplication by zero', () => {
      expect(calc.multiply(5, 0)).toBe(0);
    });

    it('should multiply negative numbers', () => {
      expect(calc.multiply(-3, -4)).toBe(12);
    });
  });

  describe('divide', () => {
    it('should divide two numbers', () => {
      expect(calc.divide(20, 4)).toBe(5);
    });

    it('should throw error on division by zero', () => {
      expect(() => calc.divide(10, 0)).toThrow('Division by zero');
    });

    it('should handle decimal division', () => {
      expect(calc.divide(10, 3)).toBeCloseTo(3.333, 2);
    });
  });

  describe('power', () => {
    it('should calculate power', () => {
      expect(calc.power(2, 3)).toBe(8);
    });

    it('should handle power of zero', () => {
      expect(calc.power(5, 0)).toBe(1);
    });
  });

  describe('sqrt', () => {
    it('should calculate square root', () => {
      expect(calc.sqrt(16)).toBe(4);
    });

    it('should throw error for negative numbers', () => {
      expect(() => calc.sqrt(-1)).toThrow('Cannot compute square root of negative number');
    });
  });
});
