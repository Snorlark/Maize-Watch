describe('Basic Test Suite', () => {
  it('should run a simple test', () => {
    expect(1 + 1).toBe(2);
  });

  it('should test environment variables', () => {
    expect(process.env.NODE_ENV).toBe('test');
  });
});
