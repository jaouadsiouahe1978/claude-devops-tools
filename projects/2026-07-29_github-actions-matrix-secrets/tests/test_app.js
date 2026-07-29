describe('Math operations', () => {
  function add(a, b) {
    return a + b;
  }

  function subtract(a, b) {
    return a - b;
  }

  function multiply(a, b) {
    return a * b;
  }

  function divide(a, b) {
    if (b === 0) {
      throw new Error('Cannot divide by zero');
    }
    return a / b;
  }

  test('add positive numbers', () => {
    expect(add(2, 3)).toBe(5);
  });

  test('add negative numbers', () => {
    expect(add(-1, 1)).toBe(0);
  });

  test('subtract numbers', () => {
    expect(subtract(5, 3)).toBe(2);
  });

  test('multiply numbers', () => {
    expect(multiply(4, 5)).toBe(20);
  });

  test('divide numbers', () => {
    expect(divide(10, 2)).toBe(5);
  });

  test('divide by zero throws error', () => {
    expect(() => divide(10, 0)).toThrow('Cannot divide by zero');
  });
});

describe('Environment variables', () => {
  test('can access environment variables', () => {
    process.env.TEST_VAR = 'test-value';
    expect(process.env.TEST_VAR).toBe('test-value');
  });
});

describe('Matrix support', () => {
  test('verify Node.js version', () => {
    const version = process.versions.node;
    expect(version).toBeDefined();
    console.log(`Running on Node.js ${version}`);
  });
});
