const apiKey = 'bf66f8-23662d-4b6e45-ec27cc-a98eaa';
const accountNumber = '3546176055';
const ifsc = 'KKBK0000495';
const orderId = `TEST_${Date.now()}`;

async function testEndpoints() {
  console.log('=============== TESTING BANK VERIFICATION APIS ===============\n');

  // 1. Penny Drop API
  const pennyUrl = `https://api.finpayultra.com/api/bank-varification-live?api_key=${apiKey}&orderid=${orderId}&account_number=${accountNumber}&ifsc=${ifsc}`;
  console.log(`1️⃣ Testing Penny Drop API (bank-varification-live):`);
  console.log(`URL: ${pennyUrl}`);
  try {
    const res = await fetch(pennyUrl, { method: 'GET' });
    const text = await res.text();
    console.log(`HTTP Status: ${res.status}`);
    console.log(`Response: ${text}\n`);
  } catch (err) {
    console.error(`Fetch Error: ${err.message}\n`);
  }

  // 2. Simple Bank Verification API
  const simpleUrl = `https://api.finpayultra.com/api/bank-varification?api_key=${apiKey}&orderid=${orderId}&account_number=${accountNumber}&ifsc=${ifsc}`;
  console.log(`2️⃣ Testing Simple Bank Verification API (bank-varification):`);
  console.log(`URL: ${simpleUrl}`);
  try {
    const res = await fetch(simpleUrl, { method: 'GET' });
    const text = await res.text();
    console.log(`HTTP Status: ${res.status}`);
    console.log(`Response: ${text}\n`);
  } catch (err) {
    console.error(`Fetch Error: ${err.message}\n`);
  }
}

testEndpoints();
