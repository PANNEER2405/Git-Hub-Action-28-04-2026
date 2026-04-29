// test.js

console.log("Running tests...");

// Function
function add(a, b) {
  return a + b;
}

// Test case 1
if (add(2, 3) !== 5) {
  console.error("❌ Test Failed: 2 + 3 should be 5");
  process.exit(1);
}

// Test case 2
if (add(1, 1) !== 2) {
  console.error("❌ Test Failed: 1 + 1 should be 2");
  process.exit(1);
}

// If all passed
console.log("✅ All tests passed!");
process.exit(0);
